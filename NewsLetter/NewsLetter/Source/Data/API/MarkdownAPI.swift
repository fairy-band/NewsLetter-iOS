//
//  MarkdownAPI.swift
//  NewsLetter
//
//  Created by Claude on 8/4/26.
//

import Foundation

import Moya

enum MarkdownAPI {
    case fetchMarkdown(exposureContentId: Int, userId: Int)
}

extension MarkdownAPI: TargetType {
    var baseURL: URL {
        return URL(string: "\(AppInfo.baseURL)")!
    }

    var path: String {
        switch self {
        case .fetchMarkdown(let exposureContentId, _):
            return "/api/newsletters/exposure-contents/\(exposureContentId)/markdown"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        switch self {
        case .fetchMarkdown(_, let userId):
            return .requestParameters(
                parameters: ["userId": userId],
                encoding: URLEncoding.queryString
            )
        }
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
