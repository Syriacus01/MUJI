//  GptApiSendViewModel.swift
//  Created by 조수원 on 3/19/25

import Foundation
import CoreLocation

// MARK: 사용자 정보 + 맵 뷰에 찍은 핀 데이터를 GPT API에게 전송하기 위한 로직
class GptApiSendViewModel: NSObject, CLLocationManagerDelegate {
    
    static let shared = GptApiSendViewModel()
    private override init() {
        super.init()
        locationManager.delegate = self
    }
    
    var onUpdate: (() -> Void)?
    
    // API에 보내야 하는 사용자 정보
    var userAge: Int = 0
    var userMusicGenre: String = ""
    var userAddress: String = ""
    var userLatitude: Double?
    var userLongitude: Double?

    let locationManager = CLLocationManager()

// MARK: 사용자의 현재 위치 요청
    func requestLocation() {
        locationManager.requestLocation() // 사용자의 현재 위치를 가져옴
    }
    
// MARK: 사용자의 현재 위치를 요청하고 좌표로 변환
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        userLatitude = location.coordinate.latitude // 사용자의 현재 위치를 위도로 저장
        userLongitude = location.coordinate.longitude // 경도로 저장
        print("Latitude: \(userLatitude ?? 0), Longitude: \(userLongitude ?? 0)")
    }
    // 만약 위치 정보를 가져오지 못했을 때
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("사용자의 위치 정보를 가져오지 못했습니다.")
    }
    
// MARK: GPT API로 데이터 보낼 수 있게
    func prepareGptApiData(user: UserModel, address: String) -> GptApiSendModel {
        self.userAge = user.age // 사용자의 나이
        self.userMusicGenre = user.musicGenre.joined(separator: ", ") // 사용자가 선택한 음악 장르
        self.userAddress = address // 사용자의 현재 주소

        return GptApiSendModel(
            userAge: userAge,
            userMusicGenre: userMusicGenre,
            userAddress: userAddress,
            latitude: userLatitude ?? 0.0,  // 위치 정보가 없으면 0으로
            longitude: userLongitude ?? 0.0
        )
    }
    
// MARK: GPT API 호출
    func sendToGptApi(gptData: GptApiSendModel) async {
        guard let url = URL(string: "https://www.dddddd.com") else {
            print("없는 주소입니다.") // 어떤식으로 호출할지를 몰라서 그냥 url로 설정
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "ㅇㅇㅇ"
        request.setValue("ㅇㅇㅇ/json", forHTTPHeaderField: "000")
        // 데이터를 JSON으로 변환
        let requestData = try? JSONEncoder().encode(gptData)
        request.httpBody = requestData
        
        // 비동기 요청
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("GPT API 요청 성공")
                processGptApiResponse(data)
                onUpdate?()
            } else {
                print("GPT API 요청에 실패하였습니다.")
            }
        } catch {
            print("GPT API 요청 중 오류가 발생하였습니다.")
        }
    }
// MARK: GPT API 응답
    func processGptApiResponse(_ data: Data) {
        // GPT API가 응답한 JSON을 디코딩
        if let gptApiResponse = try? JSONDecoder().decode(GptRecommendModel.self, from: data) {
            print("GPT API가 추천한 음악:\(gptApiResponse)")
        } else {
            print("GPT API 디코딩 실패")
        }
    }
}
