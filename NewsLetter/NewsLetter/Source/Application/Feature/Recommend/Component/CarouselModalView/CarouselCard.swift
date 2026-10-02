//
//  CarouselCard.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/19/25.
//

import SwiftUI

struct CarouselCard: View {
    private enum Metric {
        static let height: CGFloat = 366
        static let smallCornerRadius: CGFloat = 4
        static let cornerRadius: CGFloat = 16
        static let padding: CGFloat = 20
        static let shareButtonSize: CGFloat = 44
        static let nextButtonCornerRadius: CGFloat = 100
        static let nextButtonHeight: CGFloat = 44
    }

    @StateObject private var kakaoShareManager = KakaoShareManager()
    @State private var isMarkdownPresented: Bool = false
    let card: Card
    let index: Int
    let pointColor: Color
    let isShareEnabled: Bool
    let isDetailAnalyticsEnabled: Bool
    let isExploreDetailAnalytics: Bool
    var cardType: String = "recommend"
    let isBookmarked: Bool
    let bookmarkTapHandler: () -> Void

    init(
        card: Card,
        index: Int,
        pointColor: Color,
        isShareEnabled: Bool,
        isDetailAnalyticsEnabled: Bool,
        isExploreDetailAnalytics: Bool = false,
        cardType: String = "recommend",
        isBookmarked: Bool = false,
        bookmarkTapHandler: @escaping () -> Void = {}
    ) {
        self.card = card
        self.index = index
        self.pointColor = pointColor
        self.isShareEnabled = isShareEnabled
        self.isDetailAnalyticsEnabled = isDetailAnalyticsEnabled
        self.isExploreDetailAnalytics = isExploreDetailAnalytics
        self.cardType = cardType
        self.isBookmarked = isBookmarked
        self.bookmarkTapHandler = bookmarkTapHandler
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(card.title)
                .fontRangeLimited()
                .font(.head20_bold)
                .foregroundStyle(pointColor)

            HStack(spacing: 6) {
                Text(card.displayLanguage)
                    .font(.caption11_bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .foregroundStyle(ColorPalette.white)
                    .background(
                        RoundedRectangle(cornerRadius: Metric.smallCornerRadius)
                            .fill(pointColor)
                    )

                Text(card.topKeyword)
                    .font(.body13_medium)
                
                Rectangle()
                    .frame(width: 1, height: 14)
                
                Text(card.newsletterName)
                    .fontRangeLimited()
                    .font(.body13_medium)
            }
            .foregroundStyle(pointColor)
            .padding(.top, 4)

            Text(card.summary)
                .fontRangeLimited()
                .font(.body14_regular)
                .padding(.top, 16)
            
            Spacer()
            
            HStack(spacing: 8) {
                Button {
                    isMarkdownPresented = true
                    if isDetailAnalyticsEnabled {
                        if isExploreDetailAnalytics {
                            GA.explore_contents_detail_click(
                                contentType: card.kind.gaContentType,
                                contentTitle: card.title,
                                contentId: card.id
                            )
                        } else if isShareEnabled {
                            GA.main_contents_detail_click(
                                cardType: cardType,
                                contentType: card.kind.gaContentType,
                                contentTitle: card.title,
                                contentId: card.id
                            )
                        }
                    }
                } label: {
                    RoundedRectangle(cornerRadius: Metric.nextButtonCornerRadius)
                        .stroke(.semanticColor.border_secondary, style: .init(lineWidth: 1))
                        .background(ColorPalette.white)
                        .frame(height: Metric.nextButtonHeight)
                        .overlay {
                            Text("원문 보기")
                                .fontRangeLimited()
                                .font(.body14_semiBold)
                                .foregroundStyle(.semanticColor.text_primary)
                        }
                }
                .layoutPriority(1)

                if isShareEnabled {
                    Button {
                        Task {
                            await kakaoShareManager.shareToKakao(
                                title: card.title,
                                id: card.id,
                                textColor: pointColor,
                                contentURL: card.contentURL
                            )
                        }
                    } label: {
                        RoundedRectangle(cornerRadius: Metric.shareButtonSize/2)
                            .stroke(.semanticColor.border_secondary, style: .init(lineWidth: 1))
                            .background(ColorPalette.white)
                            .frame(width: Metric.shareButtonSize, height: Metric.shareButtonSize)
                            .overlay {
                                Image("share_icon")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundStyle(.semanticColor.text_primary)
                            }
                    }
                    .foregroundStyle(.semanticColor.text_primary)
                }

                Button(action: bookmarkTapHandler) {
                    Circle()
                        .fill(ColorPalette.white)
                        .frame(width: Metric.shareButtonSize, height: Metric.shareButtonSize)
                        .overlay {
                            Circle()
                                .stroke(.semanticColor.border_secondary, style: .init(lineWidth: 1))
                            Image(isBookmarked ? "bookmark_icon_selected" : "bookmark_icon")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.semanticColor.text_primary)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isBookmarked ? "저장 해제" : "저장")
            }
            .padding(.top, 16)
        }
        .padding(Metric.padding)
        .frame(height: Metric.height)
        .background(ColorPalette.white)
        .cornerRadius(Metric.cornerRadius)
        .fullScreenCover(isPresented: $isMarkdownPresented) {
            MarkdownDetailView(
                exposureContentId: card.id,
                contentURL: card.contentURL,
                pointColor: pointColor,
                isPresented: $isMarkdownPresented,
                isBookmarked: isBookmarked,
                bookmarkTapHandler: bookmarkTapHandler
            )
        }
    }
}

#Preview {
    CarouselCard(
        card: .stub(),
        index: 0,
        pointColor: ColorPalette.pointPink500,
        isShareEnabled: true,
        isDetailAnalyticsEnabled: true
    )
}
