//
//  ArchiveReducer.swift
//  NewsLetter
//

import SwiftUI

import ComposableArchitecture

enum ArchiveSection: CaseIterable {
    case saved
    case shared

    var title: String {
        switch self {
        case .saved: return "내가 저장한"
        case .shared: return "공유받은"
        }
    }
}

enum ArchiveCardColor: CaseIterable {
    case blue
    case lemonYellow
    case purple
    case mint
    case pink
    case orange
    case green

    static let rotation: [ArchiveCardColor] = [
        .blue, .lemonYellow, .purple, .mint, .pink, .orange, .green
    ]

    static func color(for index: Int) -> ArchiveCardColor {
        rotation[index % rotation.count]
    }

    var color: Color {
        switch self {
        case .blue: return ColorPalette.pointBlue300
        case .lemonYellow: return ColorPalette.pointLemonYellow300
        case .purple: return ColorPalette.pointPurple200
        case .mint: return ColorPalette.pointMint300
        case .pink: return ColorPalette.pointPink300
        case .orange: return ColorPalette.pointOrange300
        case .green: return ColorPalette.pointGreen300
        }
    }
}

struct ArchiveNewsletter: Identifiable, Equatable {
    let id: Int
    let title: String
    let keyword: String
    let newsletterName: String
    let color: ArchiveCardColor
    let summary: String
    let contentURL: String
    let language: String
    let kind: Card.Kind

    init(
        id: Int,
        title: String,
        keyword: String,
        newsletterName: String,
        color: ArchiveCardColor,
        summary: String = "뉴스레터 본문 미리보기입니다.",
        contentURL: String = "https://example.com",
        language: String = "KOREAN",
        kind: Card.Kind = .blog
    ) {
        self.id = id
        self.title = title
        self.keyword = keyword
        self.newsletterName = newsletterName
        self.color = color
        self.summary = summary
        self.contentURL = contentURL
        self.language = language
        self.kind = kind
    }

    var card: Card {
        Card(
            id: id,
            title: title,
            topKeyword: keyword,
            summary: summary,
            contentURL: contentURL,
            imageURL: nil,
            newsletterName: newsletterName,
            language: language,
            kind: kind
        )
    }

    init(card: Card, color: ArchiveCardColor) {
        self.init(
            id: card.id,
            title: card.title,
            keyword: card.topKeyword,
            newsletterName: card.newsletterName,
            color: color,
            summary: card.summary,
            contentURL: card.contentURL,
            language: card.language,
            kind: card.kind
        )
    }
}

@Reducer
struct ArchiveReducer {
    @ObservableState
    struct State {
        var selectedSection: ArchiveSection = .saved
        var savedContents: [ArchiveNewsletter] = []
        var sharedContents: [ArchiveNewsletter] = []
        var selectedContent: ArchiveNewsletter?
        var isSavedContentsLoading = false
        var isSharedContentsLoading = false
    }

    enum Action {
        case onAppear
        case fetchSavedContents(Int)
        case savedContentsResponse(Result<[Card], Error>)
        case fetchSharedContents(Int)
        case sharedContentsResponse(Result<[Card], Error>)
        case sectionSelected(ArchiveSection)
        case bookmarkToggled(Card)
        case bookmarkUpdateFinished(Result<Void, Error>, Card, removedContent: ArchiveNewsletter?)
        case contentSelected(ArchiveNewsletter)
        case delegate(Delegate)
    }

    @CasePathable
    enum Delegate {
        case presentArchiveCard
    }

    @Dependency(\.bookmarkClient) var bookmarkClient
    @Dependency(\.sharedContentClient) var sharedContentClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard let userId = UserInfo.userId else { return .none }
                return .merge(
                    state.isSavedContentsLoading ? .none : .send(.fetchSavedContents(userId)),
                    state.isSharedContentsLoading ? .none : .send(.fetchSharedContents(userId))
                )

            case .fetchSavedContents(let userId):
                state.isSavedContentsLoading = true
                return .run { send in
                    do {
                        let cards = try await bookmarkClient.fetchBookmarks(
                            FetchBookmarksRequestDTO(userId: userId)
                        )
                        await send(.savedContentsResponse(.success(cards)))
                    } catch {
                        await send(.savedContentsResponse(.failure(error)))
                    }
                }

            case .savedContentsResponse(.success(let cards)):
                state.savedContents = cards.enumerated().map { index, card in
                    ArchiveNewsletter(card: card, color: ArchiveCardColor.color(for: index))
                }
                state.isSavedContentsLoading = false
                return .none

            case .savedContentsResponse(.failure(let error)):
                state.isSavedContentsLoading = false
                print("[ArchiveReducer] fetchBookmarks error: \(error.localizedDescription)")
                return .none

            case .fetchSharedContents(let userId):
                state.isSharedContentsLoading = true
                return .run { send in
                    do {
                        let cards = try await sharedContentClient.fetchSharedContents(
                            FetchSharedContentsRequestDTO(userId: userId)
                        )
                        await send(.sharedContentsResponse(.success(cards)))
                    } catch {
                        await send(.sharedContentsResponse(.failure(error)))
                    }
                }

            case .sharedContentsResponse(.success(let cards)):
                state.sharedContents = cards.enumerated().map { index, card in
                    ArchiveNewsletter(card: card, color: ArchiveCardColor.color(for: index))
                }
                state.isSharedContentsLoading = false
                return .none

            case .sharedContentsResponse(.failure(let error)):
                state.isSharedContentsLoading = false
                print("[ArchiveReducer] fetchSharedContents error: \(error.localizedDescription)")
                return .none

            case .sectionSelected(let section):
                state.selectedSection = section
                return .none

            case .bookmarkToggled(let card):
                guard let userId = UserInfo.userId else { return .none }

                let removedContent = state.savedContents.first { $0.id == card.id }
                if removedContent != nil {
                    state.savedContents.removeAll { $0.id == card.id }
                } else {
                    state.savedContents.append(
                        ArchiveNewsletter(
                            card: card,
                            color: ArchiveCardColor.color(for: state.savedContents.count)
                        )
                    )
                }

                return .run { send in
                    do {
                        try await bookmarkClient.updateBookmark(
                            UpdateBookmarkRequestDTO(
                                userId: userId,
                                exposureContentId: card.id,
                                isBookmarked: removedContent == nil
                            )
                        )
                        await send(.bookmarkUpdateFinished(.success(()), card, removedContent: removedContent))
                    } catch {
                        await send(.bookmarkUpdateFinished(.failure(error), card, removedContent: removedContent))
                    }
                }

            case .bookmarkUpdateFinished(.success, _, _):
                return .none

            case .bookmarkUpdateFinished(.failure(let error), let card, let removedContent):
                if let removedContent {
                    state.savedContents.append(removedContent)
                } else {
                    state.savedContents.removeAll { $0.id == card.id }
                }
                print("[ArchiveReducer] updateBookmark error: \(error.localizedDescription)")
                return .none

            case .contentSelected(let content):
                state.selectedContent = content
                return .send(.delegate(.presentArchiveCard))

            case .delegate:
                return .none
            }
        }
    }
}

private extension ArchiveNewsletter {
    static let samples: [ArchiveNewsletter] = [
        .init(id: 1, title: "네온, PostgreSQL 전문가도\n놓친 치명적 실수", keyword: "PostgreSQL", newsletterName: "데브 위클리", color: .blue),
        .init(id: 2, title: "Kotlin 객체 싱글톤, Gson\n역직렬화에서 깨지는 이유", keyword: "Kotlin", newsletterName: "안드로이드 위클리", color: .lemonYellow),
        .init(id: 3, title: "SwiftUI에서 달라진\nNavigationStack 활용법", keyword: "Swift", newsletterName: "iOS 위클리", color: .purple),
        .init(id: 4, title: "RAG 파이프라인, 검색 품질을\n끌어올리는 5가지 방법", keyword: "AI", newsletterName: "트렌뉴 AI 레터", color: .mint),
        .init(id: 5, title: "Docker 이미지 크기를 80%\n줄인 멀티스테이지 빌드", keyword: "DevOps", newsletterName: "클라우드 위클리", color: .pink),
        .init(id: 6, title: "프로덕션 장애를 줄이는\n관측 가능성 설계", keyword: "Backend", newsletterName: "서버 레터", color: .green),
        .init(id: 7, title: "모바일 앱 성능을 개선하는\n이미지 캐시 전략", keyword: "iOS", newsletterName: "앱 개발 주간", color: .blue),
        .init(id: 8, title: "코드 리뷰에서 놓치기 쉬운\n동시성 문제", keyword: "Swift", newsletterName: "iOS 위클리", color: .lemonYellow),
        .init(id: 9, title: "디자인 시스템 토큰을\n운영 환경에 연결하는 법", keyword: "Frontend", newsletterName: "프론트엔드 레터", color: .purple),
        .init(id: 10, title: "LLM 기능을 제품에 붙일 때\n먼저 점검할 것들", keyword: "AI", newsletterName: "트렌뉴 AI 레터", color: .mint),
        .init(id: 11, title: "Kubernetes 비용을 줄이는\n리소스 요청값 튜닝", keyword: "DevOps", newsletterName: "클라우드 위클리", color: .pink),
        .init(id: 12, title: "서비스 확장 전에 확인할\n데이터베이스 인덱스", keyword: "PostgreSQL", newsletterName: "데브 위클리", color: .green)
    ]
}
