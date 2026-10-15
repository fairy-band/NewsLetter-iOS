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

    @ObservableState
    struct State {
        var home = HomeReducer.State()
        var isLoading: Bool = false
        var isFirstAppear: Bool = true
        var isRemoteConfigResolved: Bool = false
        var updateStatus: UpdateStatus = .none
        var pendingSharedContentID: Int?
    }

    enum Action {
        case home(HomeReducer.Action)
        case onAppear
        case onSceneActive
        case remoteConfigResponse(Result<FirebaseConfig, Error>)
        case setUpdateStatus(UpdateStatus)
        case openURL(URL)
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
                state.isRemoteConfigResolved = true

                let currentVersion = AppInfo.appVersion
                if currentVersion.compare(config.minVersion, options: .numeric) == .orderedAscending {
                    state.updateStatus = .forced(storeURL: config.storeURL, message: config.updateMessage)
                } else if currentVersion.compare(config.latestVersion, options: .numeric) == .orderedAscending {
                    state.updateStatus = .optional(storeURL: config.storeURL, message: config.updateMessage)
                } else {
                    state.updateStatus = .none
                }
                return openPendingSharedContent(&state)

            case .remoteConfigResponse(.failure(let error)):
                print("Remote Config Fetch Error: \(error.localizedDescription)")
                state.isLoading = false
                state.isRemoteConfigResolved = true
                state.updateStatus = .none
                return openPendingSharedContent(&state)
            case let .setUpdateStatus(status):
                state.updateStatus = status
                return .none

            case let .openURL(url):
                guard ShareApi.isKakaoTalkSharingUrl(url) else { return .none }
                let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
                guard let sharedContentID = queryItems
                    .first(where: { $0.name == "exposureContentId" })?
                    .value
                    .flatMap(Int.init) else {
                    return .none
                }

                guard state.isRemoteConfigResolved else {
                    state.pendingSharedContentID = sharedContentID
                    return .none
                }

                guard case .forced = state.updateStatus else {
                    return .send(.home(.openSharedContent(sharedContentID)))
                }
                return .none

            default:
                return .none
            }
        }
    }

    private func openPendingSharedContent(_ state: inout State) -> Effect<Action> {
        guard case .forced = state.updateStatus else {
            guard let sharedContentID = state.pendingSharedContentID else { return .none }
            state.pendingSharedContentID = nil
            return .send(.home(.openSharedContent(sharedContentID)))
        }
        state.pendingSharedContentID = nil
        return .none
    }
}
