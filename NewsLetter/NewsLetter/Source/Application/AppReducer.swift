//
//  AppReducer.swift
//  NewsLetter
//
//  Created by 이조은 on 7/12/25.
//

import ComposableArchitecture
import Foundation
import KakaoSDKShare

@Reducer
struct AppReducer {
    
    enum UpdateStatus: Equatable {
        case none
        case optional(storeURL: String, message: String)
        case forced(storeURL: String, message: String)
    }

    /// 카카오톡 공유 링크로 진입했을 때 띄울 콘텐츠
    struct SharedContent: Equatable, Identifiable {
        let id: Int
        let contentURL: String
        let colorHex: String
    }

    @ObservableState
    struct State {
        var home = HomeReducer.State()
        var isLoading: Bool = false
        var isFirstAppear: Bool = true
        var updateStatus: UpdateStatus = .none
        var sharedContent: SharedContent?
    }

    enum Action {
        case home(HomeReducer.Action)
        case onAppear
        case onSceneActive
        case remoteConfigResponse(Result<FirebaseConfig, Error>)
        case setUpdateStatus(UpdateStatus)
        case openURL(URL)
        case setSharedContent(SharedContent?)
    }

    @Dependency(\.remoteConfigClient) var remoteConfigClient

    var body: some Reducer<State, Action> {

        Scope(state: \.home, action: \.home) {
            HomeReducer()
        }

        Reduce { state, action in
            switch action {
            case .onAppear, .onSceneActive:
                guard state.isFirstAppear else { return .none }
                state.isFirstAppear = false
                state.isLoading = true
                return .run { send in
                    await send(.remoteConfigResponse(
                        Result { try await self.remoteConfigClient.fetch() }
                    ))
                }
                
            case .remoteConfigResponse(.success(let config)):
                state.isLoading = false

                let currentVersion = AppInfo.appVersion
                if currentVersion.compare(config.minVersion, options: .numeric) == .orderedAscending {
                    state.updateStatus = .forced(storeURL: config.storeURL, message: config.updateMessage)
                } else if currentVersion.compare(config.latestVersion, options: .numeric) == .orderedAscending {
                    state.updateStatus = .optional(storeURL: config.storeURL, message: config.updateMessage)
                } else {
                    state.updateStatus = .none
                }
                return .none

            case .remoteConfigResponse(.failure(let error)):
                print("Remote Config Fetch Error: \(error.localizedDescription)")
                state.isLoading = false
                state.updateStatus = .none
                return .none
            case let .setUpdateStatus(status):
                state.updateStatus = status
                return .none

            case let .openURL(url):
                guard ShareApi.isKakaoTalkSharingUrl(url) else { return .none }
                // 파라미터가 없는 이전 버전의 공유 메시지는 앱 진입만 한다
                let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
                func value(_ name: String) -> String? { items.first { $0.name == name }?.value }
                guard let id = value("exposureContentId").flatMap(Int.init) else { return .none }

                state.sharedContent = SharedContent(
                    id: id,
                    contentURL: value("contentURL") ?? "",
                    colorHex: Self.validHex(value("color")) ?? Self.defaultColorHex
                )
                return .none

            case let .setSharedContent(content):
                state.sharedContent = content
                return .none

            default:
                return .none
            }
        }
    }

    // UIColor(hexCode:)는 잘못된 값에 assert를 걸기 때문에 미리 걸러낸다
    private static let defaultColorHex = "#FE650F"  // ColorPalette.pointOrange500

    private static func validHex(_ hex: String?) -> String? {
        guard let hex else { return nil }
        let digits = hex.hasPrefix("#") ? hex.dropFirst() : Substring(hex)
        guard digits.count == 6, digits.allSatisfy(\.isHexDigit) else { return nil }
        return hex
    }
}
