//  EmotionModel.swift
//  Created by 조수원 on 3/17/25

import Foundation
import UIKit

// MARK: 감정 기록 데이터 모델
struct EmotionModel {
    var emotion: String    // 사용자가 사용한 이모지 : 😄😭😡 etc.
    var comment: String    // 사용자가 남긴 간단 코멘트
    var latitude: Double   // 사용자의 위치 좌표 : 위도
    var longitude: Double  // 사용자의 위치 좌표 : 경도
    var address: String    // 사용자의 현재 주소
    var date: Date         // 사용자가 기록한 날짜
}
