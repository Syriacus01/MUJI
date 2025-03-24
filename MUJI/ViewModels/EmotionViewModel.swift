//  EmotionViewModel.swift
//  Created by 조수원 on 3/19/25

import Foundation
import CoreData
import CoreLocation

// MARK: 사용자가 맵 뷰에 남긴 감정 이모지 데이터 관리 로직
class EmotionViewModel {

    static let shared = EmotionViewModel()
    private init() {}
    
    var onUpdate: (() -> Void)?
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
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                let address = [placemark.administrativeArea,
                               placemark.locality,
                               placemark.thoroughfare]
                    .compactMap { $0 }
                    .joined(separator: " ")
                newEmotion.location = address
            } else {
                newEmotion.location = "위치 정보 없음"
            }
            
            CoreDataManager.shared.saveContext()
            self.fetchEmotions()
        }
    }
    // MARK: 사용자가 기록한 감정 이모지 통계 (퍼센트)
    func getEmotionPercentage() -> [String: Double] {
        var emotionCount: [String: Int] = [:]
        
        for emotion in emotions {
            emotionCount[emotion.emotion, default: 0] += 1
        }
        var percentage: [String: Double] = [:]
        for (emotion, count) in emotionCount {
            percentage[emotion] = Double(count) * 20
        }
        return percentage
    }
    //50m이내 중복 핀 처리할때 배열에서 삭제하는 함수
    func deleteEmotion(near coordinate: CLLocationCoordinate2D) {
        let context = CoreDataManager.shared.mainContext

        let fetchRequest: NSFetchRequest<EmotionEntity> = EmotionEntity.fetchRequest()

        do {
            let results = try context.fetch(fetchRequest)

            for entity in results {
                let entityLocation = CLLocation(latitude: entity.latitude, longitude: entity.longitude)
                let targetLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let distance = entityLocation.distance(from: targetLocation)

                if distance <= 50 {
                    context.delete(entity)
                }
            }

            CoreDataManager.shared.saveContext() //Core Data에 실제 반영
            self.fetchEmotions() //배열(emotions) 최신화

        } catch {
            print("이모지 삭제 중 오류 발생: \(error)")
        }
    }


}
