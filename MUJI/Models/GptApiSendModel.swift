//  GptApiSendModel.swift
//  Created by 조수원 on 3/18/25

import Foundation
import UIKit

// MARK: GPT API로 보낼 데이터 모델
struct GptApiSendModel: Codable { // API 주고 받을 때 변환을 위해 Codable 채택
    var userAge: Int              // 사용자가 입력한 나이
    var userMusicGenre: String    // 사용자가 선택한 장르
    var userAddress: String       // 사용자의 현재 주소
    var latitude: Double          // 사용자의 위치 좌표 : 위도
    var longitude: Double         // 사용자의 위치 좌표 : 경도
}

