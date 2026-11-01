//
//  BookmarkAPI.swift
//  NewsLetter
//

import Foundation

import Moya

enum BookmarkAPI {
    case fetchBookmarks(FetchBookmarksRequestDTO)
    case updateBookmark(UpdateBookmarkRequestDTO)
}

extension BookmarkAPI: TargetType {
    var baseURL: URL {
        URL(string: AppInfo.baseURL)!
    }

    var path: String {
        switch self {
        case .fetchBookmarks(let dto):
            return "/api/newsletters/bookmarks/\(dto.userId)"
        case .updateBookmark:
            return "/api/newsletters/bookmarks"
        }
    }

    var method: Moya.Method {
        switch self {
        case .fetchBookmarks: return .get
        case .updateBookmark: return .put
        }
    }

    var task: Task {
        switch self {
        case .fetchBookmarks(let dto):
            return .requestParameters(
                parameters: ["page": dto.page, "size": dto.size],
                encoding: URLEncoding.queryString
            )
        case .updateBookmark(let dto):
            return .requestJSONEncodable(dto)
        }
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}
