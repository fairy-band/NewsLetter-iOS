//
//  Constants.swift
//  NewsLetter
//
//  Created by 이원빈 on 9/14/25.
//

import Foundation
import SwiftUI

/// ZIndex 상수 정의
enum Z {
    static let cardDefault: Double = 0
    static let cardElevated: Double = 10
    static let carouselModal: Double = 20
    static let bottomSheet: Double = 50
    static let alertDialog: Double = 60
}

typealias ColorSet = (main: Color, sub: Color)

let defaultColorSet: [ColorSet] = [
    (ColorPalette.pointBlue300, ColorPalette.pointBlueTextPrimary),
    (ColorPalette.pointLemonYellow300, ColorPalette.pointLemonYellowTextPrimary),
    (ColorPalette.pointPurple200, ColorPalette.pointPurpleTextPrimary),
    (ColorPalette.pointMint500, ColorPalette.pointMintTextPrimary),
    (ColorPalette.pointPink300, ColorPalette.pointPinkTextPrimary),
    (ColorPalette.pointGreen300, ColorPalette.pointGreenTextPrimary),
    (ColorPalette.pointOrange400, ColorPalette.pointOrangeTextPrimary),
]

extension ContentCategory {
    var colorSet: ColorSet {
        switch self {
        case .backend:  return (ColorPalette.pointPurple200, ColorPalette.pointPurpleTextPrimary)
        case .frontend: return (ColorPalette.pointMint500, ColorPalette.pointMintTextPrimary)
        case .iOS:      return (ColorPalette.pointPink300, ColorPalette.pointPinkTextPrimary)
        case .android:  return (ColorPalette.pointGreen300, ColorPalette.pointGreenTextPrimary)
        case .devops:   return (ColorPalette.pointBlue300, ColorPalette.pointBlueTextPrimary)
        case .ai:       return (ColorPalette.pointLemonYellow300, ColorPalette.pointLemonYellowTextPrimary)
        }
    }
}

extension [Card] {
    // 카테고리가 없거나 알 수 없는 카드는 기존 순환 색상을 사용합니다
    var colorSet: [ColorSet] {
        enumerated().map { index, card in
            card.category?.colorSet ?? defaultColorSet[index % defaultColorSet.count]
        }
    }
}
