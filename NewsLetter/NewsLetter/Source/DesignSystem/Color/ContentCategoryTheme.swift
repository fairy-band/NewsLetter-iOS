//
//  ContentCategoryTheme.swift
//  NewsLetter
//

import SwiftUI

enum ContentCategoryTheme: String, Codable {
    case android
    case iOS
    case frontend
    case backend
    case devops
    case ai
    case general

    init(preference: Preference) {
        switch preference {
        case .android: self = .android
        case .iOS: self = .iOS
        case .frontend: self = .frontend
        case .backend: self = .backend
        case .devops: self = .devops
        case .ai: self = .ai
        }
    }

    var colorSet: ColorSet {
        switch self {
        case .android:
            return (ColorPalette.pointGreen300, ColorPalette.pointGreen600)
        case .iOS:
            return (ColorPalette.pointPink300, ColorPalette.pointPink600)
        case .frontend:
            return (ColorPalette.pointMint300, ColorPalette.pointMint700)
        case .backend:
            return (ColorPalette.pointPurple200, ColorPalette.pointPurple600)
        case .devops:
            return (ColorPalette.pointBlue300, ColorPalette.pointBlue600)
        case .ai:
            return (ColorPalette.pointLemonYellow300, ColorPalette.pointLemonYellow700)
        case .general:
            return (ColorPalette.pointLemonYellow300, ColorPalette.pointLemonYellow700)
        }
    }

    var cardBackgroundColor: Color {
        colorSet.main
    }

    var detailColor: Color {
        colorSet.sub
    }

    static func resolve(for card: Card) -> Self {
        let text = [card.title, card.topKeyword, card.newsletterName, card.summary]
            .joined(separator: " ")
            .lowercased()

        if text.contains(anyOf: ["인공지능", "gpt", "openai", "claude", "머신러닝", "machine learning", "딥러닝", "deep learning", "생성형", "generative", "langchain", "prompt", "vector db"])
            || text.range(of: #"(?<![a-z0-9])(ai|llms?|rag)(?![a-z0-9])"#, options: .regularExpression) != nil {
            return .ai
        }

        if text.contains(anyOf: ["android", "안드로이드", "kotlin", "jetpack", "compose", "gradle"]) {
            return .android
        }

        if text.contains(anyOf: ["ios", "swift", "swiftui", "uikit", "xcode", "애플"]) {
            return .iOS
        }

        if text.contains(anyOf: ["react", "vue", "angular", "javascript", "typescript", "next.js", "nextjs", "css", "frontend", "프론트엔드"]) {
            return .frontend
        }

        if text.contains(anyOf: ["docker", "kubernetes", "k8s", "terraform", "devops", "ci/cd", "github actions", "nginx", "linux", "cloud", "aws", "gcp", "azure", "인프라"]) {
            return .devops
        }

        if text.contains(anyOf: ["backend", "백엔드", "spring", "java", "postgres", "mysql", "database", "sql", "redis", "kafka", "server", "api", "http", "python"]) {
            return .backend
        }

        return .general
    }
}

private extension String {
    func contains(anyOf keywords: [String]) -> Bool {
        keywords.contains { contains($0) }
    }
}

extension Card {
    var categoryTheme: ContentCategoryTheme {
        ContentCategoryTheme.resolve(for: self)
    }
}
