//
//  SharedContentClient.swift
//  NewsLetter
//

import ComposableArchitecture

@DependencyClient
struct SharedContentClient {
    static let apiClient = MoyaAPIClient()

    var fetchSharedContents: (FetchSharedContentsRequestDTO) async throws -> [Card]
    var updateSharedContent: (UpdateSharedContentRequestDTO) async throws -> Void
}

extension DependencyValues {
    var sharedContentClient: SharedContentClient {
        get { self[SharedContentClient.self] }
        set { self[SharedContentClient.self] = newValue }
    }
}

extension SharedContentClient: DependencyKey {
    static let liveValue = SharedContentClient(
        fetchSharedContents: { requestDTO in
            let response = try await apiClient.request(SharedContentAPI.fetchSharedContents(requestDTO))
            return try response.map(SharedContentListResponseDTO.self).toDomain()
        },
        updateSharedContent: { requestDTO in
            _ = try await apiClient.request(SharedContentAPI.updateSharedContent(requestDTO))
        }
    )

    static let previewValue = SharedContentClient(
        fetchSharedContents: { _ in [] },
        updateSharedContent: { _ in }
    )

    static let testValue = previewValue
}
