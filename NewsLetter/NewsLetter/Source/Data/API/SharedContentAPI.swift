//
//  SharedContentAPI.swift
//  NewsLetter
//

import Foundation

import Moya

enum SharedContentAPI {
    case fetchSharedContents(FetchSharedContentsRequestDTO)
}

extension SharedContentAPI: TargetType {
    var baseURL: URL {
        URL(string: AppInfo.baseURL)!
    }

    var path: String {
        switch self {
        case .fetchSharedContents(let dto):
            return "/api/newsletters/shared-contents/\(dto.userId)"
        }
    }

    var method: Moya.Method {
        .get
    }

    var task: Task {
        switch self {
        case .fetchSharedContents(let dto):
            return .requestParameters(
                parameters: ["page": dto.page, "size": dto.size],
                encoding: URLEncoding.queryString
            )
        }
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}
