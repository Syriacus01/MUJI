//
//  Models.swift
//  MUJI
//
//  Created by 원대한 on 3/19/25.
//

import UIKit

// MARK: - 감정 통계 모델
struct EmotionStat: Codable {
    let emoji: String
    let label: String
    let percentage: Int
    // UIColor는 Codable이 아니므로 색상 값을 RGB 문자열로 저장
    let primaryColor: String
    let secondaryColor: String
    
    // String에서 UIColor 생성 헬퍼 메서드
    func getPrimaryColor() -> UIColor {
        return UIColor.fromRGBString(primaryColor) ?? UIColor(red: 1, green: 0.82, blue: 0.82, alpha: 1)
    }
    
    func getSecondaryColor() -> UIColor {
        return UIColor.fromRGBString(secondaryColor) ?? UIColor(red: 1, green: 0.69, blue: 0.69, alpha: 1)
    }
    
    // 색상 배열 리턴
    func getColors() -> [UIColor] {
        return [getPrimaryColor(), getSecondaryColor()]
    }
}

// MARK: - 최근 활동 모델
struct ActivityItem: Codable {
    let icon: String
    let text: String
    let time: String
}

// MARK: - 플레이리스트 노래 모델
struct UserSong: Codable {
    let id: String
    let title: String
    let artist: String
    let emotion: String
}

// MARK: - 데이터 매니저
class DataManager {
    static let shared = DataManager()
    
    // JSON 문자열에서 감정 통계 데이터 파싱
    func parseEmotionStats(from jsonString: String) -> [EmotionStat]? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        
        do {
            let emotions = try JSONDecoder().decode([EmotionStat].self, from: data)
            return emotions
        } catch {
            print("감정 통계 파싱 오류: \(error)")
            return nil
        }
    }
    
    // JSON 문자열에서 활동 아이템 파싱
    func parseActivityItems(from jsonString: String) -> [ActivityItem]? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        
        do {
            let activities = try JSONDecoder().decode([ActivityItem].self, from: data)
            return activities
        } catch {
            print("활동 아이템 파싱 오류: \(error)")
            return nil
        }
    }
    
    // JSON 문자열에서 노래 데이터 파싱
    func parseSongs(from jsonString: String) -> [UserSong]? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        
        do {
            let songs = try JSONDecoder().decode([UserSong].self, from: data)
            return songs
        } catch {
            print("노래 데이터 파싱 오류: \(error)")
            return nil
        }
    }
    
    // 샘플 감정 통계 JSON 문자열 생성
    func getSampleEmotionStatsJson() -> String {
        """
        [
            {
                "emoji": "😊",
                "label": "행복",
                "percentage": 45,
                "primaryColor": "255,210,210",
                "secondaryColor": "255,176,176"
            },
            {
                "emoji": "😔",
                "label": "슬픔",
                "percentage": 25,
                "primaryColor": "210,227,255",
                "secondaryColor": "176,201,255"
            },
            {
                "emoji": "😠",
                "label": "화남",
                "percentage": 15,
                "primaryColor": "255,225,210",
                "secondaryColor": "255,204,176"
            },
            {
                "emoji": "😌",
                "label": "평온",
                "percentage": 15,
                "primaryColor": "210,255,227",
                "secondaryColor": "176,255,212"
            }
        ]
        """
    }
    
    // 샘플 활동 아이템 JSON 문자열 생성
    func getSampleActivityItemsJson() -> String {
        """
        [
            {
                "icon": "music.note",
                "text": "새로운 플레이리스트 '차분한 아침' 생성",
                "time": "2시간 전"
            },
            {
                "icon": "heart.fill",
                "text": "'에잇' 노래를 좋아요 표시했습니다",
                "time": "어제"
            },
            {
                "icon": "person.2.fill",
                "text": "친구 5명이 당신의 플레이리스트를 구독했습니다",
                "time": "3일 전"
            }
        ]
        """
    }
    
    // 샘플 노래 JSON 문자열 생성
    func getSampleSongsJson() -> String {
        """
        [
            {
                "id": "1",
                "title": "봄날",
                "artist": "BTS",
                "emotion": "행복"
            },
            {
                "id": "2",
                "title": "눈의 꽃",
                "artist": "박효신",
                "emotion": "평온"
            },
            {
                "id": "3",
                "title": "FAKE LOVE",
                "artist": "BTS",
                "emotion": "슬픔"
            },
            {
                "id": "4",
                "title": "좋은 날",
                "artist": "아이유",
                "emotion": "행복"
            },
            {
                "id": "5",
                "title": "에잇",
                "artist": "아이유",
                "emotion": "슬픔"
            }
        ]
        """
    }
}

// MARK: - UIColor 확장
extension UIColor {
    // RGB 문자열에서 UIColor 생성
    static func fromRGBString(_ rgbString: String) -> UIColor? {
        let components = rgbString.components(separatedBy: ",")
        guard components.count >= 3,
              let red = Float(components[0]),
              let green = Float(components[1]),
              let blue = Float(components[2]) else {
            return nil
        }
        
        return UIColor(
            red: CGFloat(red/255.0),
            green: CGFloat(green/255.0),
            blue: CGFloat(blue/255.0),
            alpha: 1.0
        )
    }
}
