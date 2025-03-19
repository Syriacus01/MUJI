//  EmotionViewModel.swift
//  Created by 조수원 on 3/19/25

import Foundation
import CoreData

// MARK: 사용자가 맵 뷰에 남긴 감정 이모지 데이터 관리 로직
class EmotionViewModel {

    var onUpdate: (() -> Void)? // 뷰에서 UI 업데이트 하실 때 onUpdate 가져가서 실행해주시면 돼요

    var emotions: [EmotionModel] = []
    
// MARK: 사용자가 입력한 감정 이모지 데이터 불러오기
    func fetchEmotions() {
        let context = CoreDataManager.shared.mainContext
  
        let fetchRequest: NSFetchRequest<EmotionEntity> = EmotionEntity.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest) // 사용자가 입력한 감정 이모지 불러오기

            emotions = results.map { entity in
                let dateValue = entity.date ?? Date()
                
                return EmotionModel(
                    emotion: entity.emotion ?? "",
                    comment: entity.comment ?? "",
                    latitude: entity.latitude,
                    longitude: entity.longitude,
                    address: entity.location ?? "",
                    date: dateValue
                )
            }
        } catch {
            print("이모지 기록 데이터 불러오기 실패" )
        }
        onUpdate?()
    }
    
// MARK: 감정 이모지 데이터 추가
    func addEmotion(emotion: String, comment: String, latitude: Double, longitude: Double) {
        let context = CoreDataManager.shared.mainContext

        let newEmotion = EmotionEntity(context: context)
        
        newEmotion.emotion = emotion
        newEmotion.comment = comment       
        newEmotion.latitude = latitude
        newEmotion.longitude = longitude
        newEmotion.date = Date()
        
        CoreDataManager.shared.saveContext()
        fetchEmotions()
    }
    
// MARK: 사용자가 기록한 감정 이모지 통계
    func getEmotionStatistics() -> [String: Int] {
        var stats: [String: Int] = [:]
        for emotionModel in emotions {
            stats[emotionModel.emotion, default: 0] += 1
        }
        return stats
    }
}
