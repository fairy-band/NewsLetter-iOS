//
//  SharedContentAPI.swift
//  NewsLetter
//

import Foundation

import Moya

enum SharedContentAPI {
    case fetchSharedContents(FetchSharedContentsRequestDTO)
    case updateSharedContent(UpdateSharedContentRequestDTO)
}

extension SharedContentAPI: TargetType {
    var baseURL: URL {
        URL(string: AppInfo.baseURL)!
    }

    var path: String {
        switch self {
        case .fetchSharedContents(let dto):
            return "/api/newsletters/shared-contents/\(dto.userId)"
        case .updateSharedContent:
            return "/api/newsletters/shared-contents"
        }
    }

    var method: Moya.Method {
        switch self {
        case .fetchSharedContents: return .get
        case .updateSharedContent: return .put
        }
    }

    var task: Task {
        switch self {
        case .fetchSharedContents(let dto):
            return .requestParameters(
                parameters: ["page": dto.page, "size": dto.size],
                encoding: URLEncoding.queryString
            )
        case .updateSharedContent(let dto):
            return .requestJSONEncodable(dto)
        }
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}
