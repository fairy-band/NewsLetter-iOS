//
//  BookmarkClient.swift
//  NewsLetter
//

import ComposableArchitecture

@DependencyClient
struct BookmarkClient {
    static let apiClient = MoyaAPIClient()

    var fetchBookmarks: (FetchBookmarksRequestDTO) async throws -> [Card]
    var updateBookmark: (UpdateBookmarkRequestDTO) async throws -> Void
}

extension DependencyValues {
    var bookmarkClient: BookmarkClient {
        get { self[BookmarkClient.self] }
        set { self[BookmarkClient.self] = newValue }
    }
}

extension BookmarkClient: DependencyKey {
    static let liveValue = BookmarkClient(
        fetchBookmarks: { requestDTO in
            let response = try await apiClient.request(BookmarkAPI.fetchBookmarks(requestDTO))
            return try response.map(BookmarkListResponseDTO.self).toDomain()
        },
        updateBookmark: { requestDTO in
            _ = try await apiClient.request(BookmarkAPI.updateBookmark(requestDTO))
        }
    )

    static let previewValue = BookmarkClient(
        fetchBookmarks: { _ in [] },
        updateBookmark: { _ in }
    )

    static let testValue = previewValue
}
