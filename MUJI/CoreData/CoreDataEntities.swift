//
//  CoreDataEntities.swift
//  MUJI
//
//  Created by 조수원 on 3/18/25.
//

import Foundation
import CoreData
import UIKit

// MARK: 유저 정보 엔티티
@objc
class UserEntity: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var age: Int
    @NSManaged var profileImage: Data
    @NSManaged var musicGenre: String
}

// MARK: 감정 기록 엔티티
@objc
class EmotionEntity: NSManagedObject {
    @NSManaged var emotion: String
    @NSManaged var comment: String
    @NSManaged var location: String
    @NSManaged var date: Date
}

// MARK: GPT API로 보낼 엔티티
@objc
class GptApiSendEntity: NSManagedObject {
    @NSManaged var userAge: Int
    @NSManaged var userMusicGenre: String
    @NSManaged var userAddress: String
}

// MARK: GPT가 추천한 노래 엔티티
@objc
class GptApiRecommendEntity: NSManagedObject {
    @NSManaged var artistName: String
    @NSManaged var title: String
}


// MARK: GPT API -> Apple Music API로 보낼 엔티티
@objc
class AppleMusicApiSendEntity: NSManagedObject {
    @NSManaged var artistName: String
    @NSManaged var title: String
}

// MARK: 사용자가 재생한 곡 누적 플레이리스트 엔티티
@objc
class UserListeningEntity: NSManagedObject {
    @NSManaged var artistName: String
    @NSManaged var title: String
    @NSManaged var emotion: String
}
