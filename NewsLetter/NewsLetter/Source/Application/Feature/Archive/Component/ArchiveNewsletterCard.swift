//
//  ArchiveNewsletterCard.swift
//  NewsLetter
//

import SwiftUI

struct ArchiveNewsletterCard: View {
    let content: ArchiveNewsletter
    let showsBookmark: Bool
    let bookmarkTapHandler: () -> Void
    let contentTapHandler: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: contentTapHandler) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(content.title)
                        .font(.body15_bold)
                        .foregroundStyle(ColorPalette.gray950)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.trailing, showsBookmark ? 40 : 0)

                    Spacer(minLength: 0)

                    HStack(spacing: 8) {
                        Text(content.keyword)
                            .lineLimit(1)
                        Rectangle()
                            .fill(ColorPalette.gray950.opacity(0.1))
                            .frame(width: 1, height: 14)
                        Text(content.newsletterName)
                            .lineLimit(1)
                    }
                    .font(.body13_regular)
                    .foregroundStyle(ColorPalette.gray950.opacity(0.5))
                }
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(content.title)

            if showsBookmark {
                Button(action: bookmarkTapHandler) {
                    Image("bookmark_icon_selected")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 22)
                        .foregroundStyle(ColorPalette.gray950)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("저장 해제")
                .padding(.top, 16)
                .padding(.trailing, 16)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 112, maxHeight: 112, alignment: .leading)
        .background(content.color.color)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ArchiveNewsletterCard(
        content: .init(
            id: 1,
            title: "네온, PostgreSQL 전문가도\n놓친 치명적 실수",
            keyword: "PostgreSQL",
            newsletterName: "데브 위클리",
            color: .blue
        ),
        showsBookmark: true,
        bookmarkTapHandler: {},
        contentTapHandler: {}
    )
    .padding()
}
