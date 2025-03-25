//  UserListenModel.swift
//  Created by 조수원 on 3/18/25

import Foundation
import UIKit

// MARK: 사용자가 재생한 노래 데이터 모델
struct UserListenModel {
    var artistName: String // 아티스트 명
    var title: String      // 곡 제목
    var emotion: String    // 추천 받을 때 입력한 이모지
}
