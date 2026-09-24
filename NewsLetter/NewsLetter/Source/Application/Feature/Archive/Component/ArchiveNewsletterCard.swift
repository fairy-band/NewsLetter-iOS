//
//  ArchiveNewsletterCard.swift
//  NewsLetter
//

import SwiftUI

struct ArchiveNewsletterCard: View {
    let content: ArchiveNewsletter
    let showsBookmark: Bool
    let bookmarkTapHandler: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                Text(content.title)
                    .font(.body15_bold)
                    .foregroundStyle(ColorPalette.gray950)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)

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
                }
            }

            Spacer(minLength: 24)

            HStack(spacing: 8) {
                Text(content.keyword)
                Rectangle()
                    .fill(ColorPalette.gray950.opacity(0.1))
                    .frame(width: 1, height: 14)
                Text(content.newsletterName)
            }
            .font(.body13_regular)
            .foregroundStyle(ColorPalette.gray950.opacity(0.5))
        }
        .padding(32)
        .frame(maxWidth: .infinity, minHeight: 224, alignment: .leading)
        .background(content.color.color)
        .clipShape(RoundedRectangle(cornerRadius: 30))
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
        bookmarkTapHandler: {}
    )
    .padding()
}
