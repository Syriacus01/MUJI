import Foundation
import CoreLocation

struct EmotionEntry {
    let emoji: String
    let emotion: String
    let latitude: Double
    let longitude: Double
    let city: String?
    let country: String?
    let timestamp: Date
}

class TestEmotionViewModel: NSObject, CLLocationManagerDelegate {
    var emotionEntries: [EmotionEntry] = [] // 저장된 감정 데이터를 담을 배열
    private let locationManager = CLLocationManager()
    private var pendingSaveRequest: (emoji: String, emotion: String)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    // 새로운 감정 데이터를 저장 요청
    func saveEmotion(emoji: String, emotion: String) {
        if let location = locationManager.location {
            processEmotionData(emoji: emoji, emotion: emotion, location: location)
        } else {
            pendingSaveRequest = (emoji, emotion) // 위치가 아직 없으면 저장 요청을 대기 상태로 둠
            locationManager.requestLocation() // 위치 업데이트 요청
        }
    }
    
    // 위치 업데이트 시 호출되는 델리게이트 메서드 (필수 구현)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        //print("현재 위치 업데이트됨: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        // 대기 중인 저장 요청이 있으면 위치 업데이트 후 실행
        if let pendingRequest = pendingSaveRequest {
            processEmotionData(emoji: pendingRequest.emoji, emotion: pendingRequest.emotion, location: location)
            pendingSaveRequest = nil
        }
    }
    
    // 위치 가져오기 실패 시 호출되는 델리게이트 메서드
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 가져오기 실패: \(error.localizedDescription)")
    }
    
    // 감정 데이터를 처리하여 배열에 추가하고 출력
    private func processEmotionData(emoji: String, emotion: String, location: CLLocation) {
        fetchGeolocation(for: location) { [weak self] city, country in
            let entry = EmotionEntry(
                emoji: emoji,
                emotion: emotion,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                city: city,
                country: country,
                timestamp: Date()
            )
            
            self?.emotionEntries.append(entry)
            
            // 콘솔에 저장된 데이터 출력 (임시) 데이터에 쪽에 연결할예정
            print("새로운 감정 데이터 추가됨:")
            print("이모지: \(entry.emoji), 감정: \(entry.emotion)")
            print("위치: (\(entry.latitude), \(entry.longitude))")
            print("도시: \(entry.city ?? "알 수 없음"), 국가: \(entry.country ?? "알 수 없음")")
            print("시간: \(entry.timestamp)\n")
            
        }
    }
    
    // 위치 정보를 기반으로 지오로케이션(도시, 국가) 가져오기
    private func fetchGeolocation(for location: CLLocation, completion: @escaping (String?, String?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                completion(nil, nil)
                return
            }
            let city = placemark.locality
            let country = placemark.country
            completion(city, country)
        }
    }
}
