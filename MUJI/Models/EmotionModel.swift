//
//  EmotionModel.swift
//  MUJI
//
//  Created by 조수원 on 3/17/25.
//

import Foundation
import UIKit

// MARK: 맵 뷰 감정 기록 데이터 모델
struct EmotionModel {
    var emotion: String   // 이모지 : 😄😭😡🤢 etc.
    var comment: String   // 간단 코멘트
    var latitude: Double  // 위도
    var longitude: Double // 경도
    var address: String   // 변환 주소
    var date: Date        // 날짜
}
