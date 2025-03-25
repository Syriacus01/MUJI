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
    var emotions: [EmotionModel] = [] // 배열
    var emotionPins: [EmotionModel] = []
    
    // MARK: 사용자가 입력한 감정 이모지 데이터 불러오기
    func fetchEmotions() {
        let context = CoreDataManager.shared.mainContext
        let fetchRequest: NSFetchRequest<EmotionEntity> = EmotionEntity.fetchRequest()
        
        do {
            self.emotions = try context.fetch(fetchRequest).map { entity in
                EmotionModel(
                    emotion: entity.emotion ?? "",
                    comment: entity.comment ?? "",
                    latitude: entity.latitude,
                    longitude: entity.longitude,
                    address: entity.location ?? "",
                    date: entity.date ?? Date()
                )
            }
            //self.emotionPins = self.emotions

            print("emotions 배열: \(emotions.count)")
            print("emotionPins 배열: \(emotionPins.count)")

        } catch {
            print("이모지 기록 데이터 불러오기 실패")
        }

        onUpdate?()
        updateEmotionView()
    }
    func fetchEmotionsPin() {
        let context = CoreDataManager.shared.mainContext
        let fetchRequest: NSFetchRequest<EmotionEntity> = EmotionEntity.fetchRequest()
        
        do {
            self.emotionPins = try context.fetch(fetchRequest).map { entity in
                EmotionModel(
                    emotion: entity.emotion ?? "",
                    comment: entity.comment ?? "",
                    latitude: entity.latitude,
                    longitude: entity.longitude,
                    address: entity.location ?? "",
                    date: entity.date ?? Date()
                )
            }
            //self.emotionPins = self.emotions

            print("emotions 배열: \(emotions.count)")
            print("emotionPins 배열: \(emotionPins.count)")

        } catch {
            print("이모지 기록 데이터 불러오기 실패")
        }

        onUpdate?()
        //updateEmotionView()
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
        newEmotion.isPin = false
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
    // MARK: 감정 이모지 데이터 삭제용 배열
    func addEmotionPins(emotion: String, comment: String, latitude: Double, longitude: Double) {
        let context = CoreDataManager.shared.mainContext
        
        let newEmotion = EmotionEntity(context: context)
        
        newEmotion.emotion = emotion
        newEmotion.comment = comment
        newEmotion.latitude = latitude
        newEmotion.longitude = longitude
        newEmotion.date = Date()
        newEmotion.isPin = true
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
            self.fetchEmotionsPin()
        }
    }
    // MARK: 사용자가 기록한 감정 이모지 통계 (퍼센트)
    func getEmotionPercentage() -> [String: Double] {
        var emotionCount: [String: Int] = [:]
        
        for emotion in emotions {
            emotionCount[emotion.emotion, default: 0] += 1
        }
        let totalCount = emotionCount.values.reduce(0, +) // 전체 감정 개수
        guard totalCount > 0 else { return [:] }
        
        var percentage: [String: Double] = [:]
        for (emotion, count) in emotionCount {
            let percent = (Double(count) / Double(totalCount)) * 100
            percentage[emotion] = round(percent * 10) / 10.0
        }
        return percentage
    }
    //50m이내 중복 핀 처리할때 배열에서 삭제하는 함수
    func deleteEmotions(at coordinates: [CLLocationCoordinate2D]) {
        let context = CoreDataManager.shared.mainContext
        let fetchRequest: NSFetchRequest<EmotionEntity> = EmotionEntity.fetchRequest()

        do {
            let results = try context.fetch(fetchRequest)

            for entity in results {
                //isPin이 true인 데이터만 삭제 대상으로
                guard entity.isPin else { continue }

                let entityLocation = CLLocation(latitude: entity.latitude, longitude: entity.longitude)

                for coord in coordinates {
                    let target = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
                    if entityLocation.distance(from: target) <= 50 {
                        context.delete(entity)
                        break
                    }
                }
            }

            CoreDataManager.shared.saveContext()
            self.fetchEmotionsPin() // 핀 배열만 갱신

        } catch {
            print("여러 이모지 삭제 중 오류 발생: \(error)")
        }
    }

    func updateEmotionView() {
        let percentages = getEmotionPercentage()
        
        let stats: [EmotionStat] = percentages.map { (emoji, percent) in
            let label = EmotionMapper.map(emoji)
            let Color = EmotionColorMapper.map(label)
            print("저장된 감정 갯수: \(emotions.count)")
            
            return EmotionStat(
                emoji: emoji,
                label: label,
                percentage: Int(percent),
                primaryColor: Color,
                secondaryColor: Color
            )
        }
        if let jsonString = convertEmotionJSONString(stats) {
            UserDefaultsManager.shared.saveEmotionStats(jsonString)
        }
    }
    
    private func convertEmotionJSONString(_ stats: [EmotionStat]) -> String? {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(stats) {
            return String(data: jsonData, encoding: .utf8)
        }
        return nil
    }
}
