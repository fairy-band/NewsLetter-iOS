//
//  UserInfo.swift
//  NewsLetter
//
//  Created by 이원빈 on 8/1/25.
//

import Foundation

struct UserInfo {
    /// 유저의 유니크 id
    @UserDefaultWrapper(key: "userId", defaultValue: nil)
    static var userId: Int?

    /// 북마크를 저장한 화면의 카테고리를 계정·콘텐츠별로 유지합니다.
    @UserDefaultWrapper(key: "bookmarkCategoryThemes", defaultValue: [:])
    private static var bookmarkCategoryThemes: [String: ContentCategoryTheme]

    static func bookmarkCategoryTheme(for contentID: Int) -> ContentCategoryTheme? {
        guard let userId else { return nil }
        return bookmarkCategoryThemes["\(userId):\(contentID)"]
    }

    static func setBookmarkCategoryTheme(_ theme: ContentCategoryTheme?, for contentID: Int) {
        guard let userId else { return }
        bookmarkCategoryThemes["\(userId):\(contentID)"] = theme
    }

    /// 유저의 카드 정보(하루에 1번 갱신)
    @UserDefaultWrapper(key: "cachedDailyCards", defaultValue: nil)
    static var cachedDailyCards: [Card]?
    
    /// 유저의 탐색탭 카드 정보(하루에 1번 갱신)
    @UserDefaultWrapper(key: "cachedExploreCards", defaultValue: nil)
    static var cachedExploreCards: [ExploreCard]?

    /// 유저가 마지막 API를 호출한 날짜
    @UserDefaultWrapper(key: "lastCardFetchDate", defaultValue: nil)
    static var lastCardFetchDate: Date?
    
    /// 유저가 마지막 탐색탭 카드 API를 호출한 날짜
    @UserDefaultWrapper(key: "lastExploreCardFetchDate", defaultValue: nil)
    static var lastExploreCardFetchDate: Date?

    /// 유저의 유니크 id
    @UserDefaultWrapper(key: "fcmToken", defaultValue: nil)
    static var fcmToken: String?
}
