//  EmotionRecordModel.swift
//  Created by 조수원 on 3/23/25

struct EmotionRecord: Codable {
    let emoji: String
    let comment: String
    let latitude: Double
    let longitude: Double
}
