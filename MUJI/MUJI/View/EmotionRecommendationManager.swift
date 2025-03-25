//
//  EmotionRecommendationManager.swift
//  MUJI
//
//  Created by Uihyun.Lee on 3/23/25.
//


import CoreLocation
import Foundation


final class EmotionRecommendationManager {

    static let shared = EmotionRecommendationManager()

    private init() {}

    func getRecommendation(
        
        emotion: String,
        comment: String,
        location: CLLocationCoordinate2D,
        user: UserModel?,
        completion: @escaping ([String]) -> Void
    ) {
        //UserViewModel.shared.fetchUser()// 업데이트 해줄것
        FetchWeather.shared.fetchWeather(lat: "\(location.latitude)", lon: "\(location.longitude)") { weatherInfo in
            UserViewModel.shared.fetchUser()

            Task {
                let result = await SearchChatGPT.shared.search(
                    location: EmotionViewModel.shared.emotions.last?.address ?? "",
                    weather: weatherInfo,
                    emotion: comment,
                    age: user?.age ?? 0,
                    genre: user?.musicGenre.joined(separator: ", ") ?? "pop"
                )

                let lines = result.split(separator: "\n").map { String($0) }
                completion(lines)
            }
        }
    }
}
