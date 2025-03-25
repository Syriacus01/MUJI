//  UserModel.swift
//  Created by 조수원 on 3/18/25

import UIKit

// MARK: 사용자 정보 데이터 모델
struct UserModel {
    var name: String
    var age: Int
    var profileImage: UIImage
    var musicGenre: [String]      // 음악 장르
    var userInfo: Bool = false  // 사용자 정보 있는지 여부 = 기본값은 사용자 정보 없음
}
