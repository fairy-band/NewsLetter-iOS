//
//  SharedContentDTO.swift
//  NewsLetter
//

import Foundation

struct FetchSharedContentsRequestDTO {
    let userId: Int
    let page: Int
    let size: Int

    init(userId: Int, page: Int = 0, size: Int = 100) {
        self.userId = userId
        self.page = page
        self.size = size
    }
}

struct UpdateSharedContentRequestDTO: Encodable {
    let userId: Int
    let exposureContentId: Int
    let isShared: Bool
}

struct SharedContentListResponseDTO: Decodable {
    let sharedContents: [SharedContentCardDTO]

    func toDomain() -> [Card] {
        sharedContents.map { $0.toDomain() }
    }
}

struct SharedContentCardDTO: Decodable {
    let exposureContentId: Int
    let provocativeKeyword: String
    let provocativeHeadline: String
    let summaryContent: String
    let contentURL: String
    let imageURL: String?
    let newsletterName: String
    let language: String
    let categoryName: String?

    enum CodingKeys: String, CodingKey {
        case exposureContentId
        case provocativeKeyword, provocativeHeadline, summaryContent
        case contentURL = "contentUrl"
        case imageURL = "imageUrl"
        case newsletterName, language, categoryName
    }

    func toDomain() -> Card {
        Card(
            id: exposureContentId,
            title: provocativeHeadline,
            topKeyword: provocativeKeyword,
            summary: summaryContent,
            contentURL: contentURL,
            imageURL: imageURL,
            newsletterName: newsletterName,
            language: language,
            kind: .blog,
            categoryName: categoryName
        )
    }
}
