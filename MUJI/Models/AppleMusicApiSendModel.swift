//  AppleMusicApiSendModel.swift
//  Created by 조수원 on 3/18/25

import Foundation
import UIKit

// MARK: Apple Music API로 보낼 데이터 모델
struct AppleMusicApiSendModel: Codable { // API 주고 받을 때 변환을 위해 Codable 채택
    var artistName: String               // 아티스트 명
    var title: String                    // 곡 제목
}
