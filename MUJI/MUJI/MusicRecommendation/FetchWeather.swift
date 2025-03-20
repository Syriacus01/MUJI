//
//  FetchWeather 2.swift
//  MUJI
//
//  Created by 윤태한 on 3/19/25.
//

/*
FetchWeather().fetchWeather(lat: "37.56", lon: "126.97") { weatherInfo in
    print(weatherInfo)
    Task {
        print("ChatGPT에 요청을 시작합니다.")
        let songs = await SearchChatGPT().search(input: weatherInfo)
        
        if !songs.isEmpty {
            print("=========== 추천 노래 리스트 ===========\n\(songs)")
            print("====================================")
        } else {
            print("ChatGPT로부터 추천 노래를 받지 못했습니다.")
        }
    }
}*/

import Foundation

class FetchWeather {
    
    let weatherAPIKey = ""
    
    // MARK: - 날씨 API 호출 함수 (위도와 경도를 문자열 매개변수로 받음)
    func fetchWeather(lat: String, lon: String, completion: @escaping (String) -> Void) {
        let weatherURLString = "/data/3.0/onecall?lat=\(lat)&lon=\(lon)&lang=kr&appid=\(weatherAPIKey)"
        
        guard let weatherURL = URL(string: weatherURLString) else {
            print("잘못된 URL입니다.")
            return
        }
        
        URLSession.shared.dataTask(with: weatherURL) { data, response, error in
            if let error = error {
                print("에러 발생: \(error)")
                return
            }
            
            guard let data = data else {
                print("데이터가 없습니다.")
                return
            }
            
            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                let current = weatherResponse.current
                
                // 체감 온도 변환: 켈빈(K)을 섭씨(℃)로 변환
                let feelsLikeCelsius = current.feels_like - 273.15
                let description = current.weather.first?.description ?? "날씨 정보 없음"
                
                // ChatGPT에게 노래 추천 요청
                let weatherInfo = "현재 날씨는 '\(description)', 체감 온도는 \(String(format: "%.2f", feelsLikeCelsius))℃."
                completion(weatherInfo)
                
            } catch {
                print("디코딩 에러: \(error)")
            }
        }.resume()
    }
}
