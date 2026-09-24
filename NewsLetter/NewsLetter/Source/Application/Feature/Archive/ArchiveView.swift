//
//  ArchiveView.swift
//  NewsLetter
//

import SwiftUI

import ComposableArchitecture

struct ArchiveView: View {
    private enum Metric {
        static let horizontalPadding: CGFloat = 16
        static let cardSpacing: CGFloat = 12
    }

    @Bindable var store: StoreOf<ArchiveReducer>

    private var contents: [ArchiveNewsletter] {
        store.selectedSection == .saved ? store.savedContents : store.sharedContents
    }

    var body: some View {
        VStack(spacing: 0) {
            sectionTabs
            contentList
        }
        .background(Color.black.ignoresSafeArea())
    }

    private var sectionTabs: some View {
        HStack(spacing: 0) {
            ForEach(ArchiveSection.allCases, id: \.self) { section in
                Button {
                    store.send(.sectionSelected(section))
                } label: {
                    VStack(spacing: 14) {
                        Text(section.title)
                            .font(section == store.selectedSection ? .body16_bold : .body16_medium)
                            .foregroundStyle(section == store.selectedSection ? Color.white : Color(hex: 0x6B7580))

                        Rectangle()
                            .fill(Color.white)
                            .frame(height: 4)
                            .opacity(section == store.selectedSection ? 1 : 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(section == store.selectedSection ? .isSelected : [])
            }
        }
        .frame(height: 56)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(ColorPalette.gray800)
                .frame(height: 1)
        }
    }

    private var contentCount: some View {
        HStack(spacing: 8) {
            Text("전체")
                .foregroundStyle(Color.white)
            Text("\(contents.count)")
                .foregroundStyle(ColorPalette.gray400)
            Spacer()
        }
        .font(.body16_bold)
        .padding(.horizontal, Metric.horizontalPadding)
        .padding(.top, 14)
        .padding(.bottom, 16)
    }

    private var contentList: some View {
        ScrollView {
            VStack(spacing: 0) {
                contentCount

                LazyVStack(spacing: Metric.cardSpacing) {
                    ForEach(contents) { content in
                        ArchiveNewsletterCard(
                            content: content,
                            showsBookmark: store.selectedSection == .saved,
                            bookmarkTapHandler: {
                                store.send(.savedContentRemoved(content.id))
                            }
                        )
                    }
                }
                .padding(.horizontal, Metric.horizontalPadding)
            }
            .padding(.bottom, 24)
        }
    }
}

#Preview {
    ArchiveView(store: Store(initialState: ArchiveReducer.State(selectedSection: .shared)) {
        ArchiveReducer()
    })
}
