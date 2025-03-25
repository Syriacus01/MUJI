//
//  CurrentWeather.swift
//  MUJI
//
//  Created by 윤태한 on 3/19/25.
//


struct CurrentWeather: Codable {
    let feels_like: Double
    let weather: [WeatherDetail]
}
