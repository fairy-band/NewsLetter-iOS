//
//  BottomTabBar.swift
//  NewsLetter
//

import SwiftUI

struct BottomTabBar: View {
    private struct Item: Identifiable {
        let tab: HomeReducer.Tab
        let title: String
        let iconName: String

        var id: HomeReducer.Tab { tab }
    }

    private static let items = [
        Item(tab: .recommend, title: "추천", iconName: "recommendation_icon"),
        Item(tab: .explore, title: "탐색", iconName: "explore_icon"),
        Item(tab: .archive, title: "보관함", iconName: "bookmark_icon")
    ]

    @Binding var selectedTab: HomeReducer.Tab

    var body: some View {
        let isDarkBackground = selectedTab != .recommend

        HStack(spacing: 0) {
            ForEach(Self.items) { item in
                tabButton(for: item)
            }
        }
        .frame(height: 56)
        .background(isDarkBackground ? Color.black : ColorPalette.white)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(isDarkBackground ? ColorPalette.gray800 : ColorPalette.gray200)
                .frame(height: 1)
        }
        .background((isDarkBackground ? Color.black : ColorPalette.white).ignoresSafeArea(edges: .bottom))
    }

    private func tabButton(for item: Item) -> some View {
        let isSelected = selectedTab == item.tab
        let isDarkBackground = selectedTab != .recommend
        let iconName = item.tab == .archive && isSelected ? "bookmark_icon_selected" : item.iconName
        let foregroundColor = isSelected
            ? (isDarkBackground ? Color.white : Color(hex: 0x121314))
            : Color(hex: 0x6B7580)

        return Button {
            selectedTab = item.tab
        } label: {
            VStack(spacing: 6) {
                Image(iconName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 22)

                Text(item.title)
                    .font(isSelected ? .caption11_bold : .caption11_medium)
            }
            .foregroundStyle(foregroundColor)
            .padding(.top, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    BottomTabBar(selectedTab: .constant(.recommend))
}
