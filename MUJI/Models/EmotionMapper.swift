// EmotionMapper.swift
// Created by 조수원 on 3/24/25

import Foundation

struct EmotionMapper {
    static func map(_ emoji: String) -> String {
        switch emoji {
        case "😀": return "행복"
        case "😡": return "화남"
        case "😶": return "평온"
        case "😭": return "슬픔"
        case "🤒": return "아픔"
        default: return "-"
        }
    }
}

struct EmotionColorMapper {
    static func map(_ emotion: String) -> String {
        switch emotion {
        case "행복": return "255,186,133"
        case "화남": return "255,126,126"
        case "평온": return "134,229,127"
        case "슬픔": return "178,204,255"
        case "아픔": return "213,213,213"
        default: return "134,229,127" // 기본 색상
        }
    }
}
