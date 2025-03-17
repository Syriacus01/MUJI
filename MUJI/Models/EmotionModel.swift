//
//  EmotionModel.swift
//  MUJI
//
//  Created by 조수원 on 3/17/25.
//

import Foundation
import UIKit

// MARK: 감정 기록 데이터 모델
struct EmotionModel {
    var emotion: String  // 이모지 : 😄😭😡🤢 etc.
    var comment: String  // 간단 코멘트
    var location: String // 위치 정보
    var date: Date       // 기록 날짜
}
