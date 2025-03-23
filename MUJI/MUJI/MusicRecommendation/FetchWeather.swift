//
//  FetchWeather 2.swift
//  MUJI
//
//  Created by 윤태한 on 3/19/25.
//

/* ===================== 사용 예시 =====================
FetchWeather().fetchWeather(lat: "37.56", lon: "126.97") { weatherInfo in
    Task {
        let songs = await SearchChatGPT().search(location: "서울시 관악구 남부순환로", weather: weatherInfo, emotion: "행복함", age: 26, genre: "힙합")
        
        if !songs.isEmpty {
            print("============== 추천 노래 리스트 ==============\n\(songs)")
            print("==========================================")
            print("노래 추천 완료.")
        } else {
            print("ChatGPT로부터 추천 노래를 받지 못했습니다.")
        }
    }
}
 ========================= 사용 예시 =====================*/

import Foundation

class FetchWeather {
    static let shared = FetchWeather()
    
    let weatherAPIKey: String = {
        guard let key = ProcessInfo.processInfo.environment["WEATHER_API_KEY"] else {
            fatalError("API_KEY가 없음.")
        }
        return key
    }()
    let weatherURL: String = {
        guard let key = ProcessInfo.processInfo.environment["WEATHER_URL"] else {
            fatalError("API_KEY가 없음.")
        }
        return key
    }()
    
    
    func fetchWeather(lat: String, lon: String, completion: @escaping (String) -> Void) {
        
        let weatherURLString = weatherURL + "\(lat)&lon=\(lon)&lang=kr&appid=\(weatherAPIKey)"
        
        guard let weatherURL = URL(string: weatherURLString) else {
            print("잘못된 URL")
            return
        }
        
        URLSession.shared.dataTask(with: weatherURL) { data, response, error in
            if let error = error {
                print("에러발생: \(error)")
                return
            }
            guard let data = data else {
                print("데이터가 없습니다.")
                return
            }
            
            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                let current = weatherResponse.current
                
                let feelsLikeCelsius = current.feels_like - 273.15
                let description = current.weather.first?.description ?? "날씨 정보 없음"
                
                let weatherInfo = "현재 날씨: \(description), 체감 온도: \(String(format: "%.2f", feelsLikeCelsius))℃"
                completion(weatherInfo)
                
            } catch {
                print("디코딩 에러: \(error)")
            }
            
        }.resume()
    }
}
