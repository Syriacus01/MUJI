//  GptRecommendViewModel.swift
//  Created by 조수원 on 3/19/25

import Foundation
import CoreData

// MARK: GPT API가 추천해준 노래
class GptRecommendViewModel {
    
    static let shared = GptRecommendViewModel()
    private init() {}
    
    var onUpdate: (() -> Void)?
    var recommendList: [GptRecommendModel] = [] // GPT API가 추천해준 노래 목록
    
// MARK: GPT API 추천해준 노래 리스트 가져오기
    func fetchRecommend() async {
        guard let url = URL(string: "https://www.dddddd.com") else {
            print("없는 주소입니다.")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("GPT API가 추천해준 노래 리스트를 가져오는데 성공했습니다.")

                if let decodedData = try? JSONDecoder().decode([GptRecommendModel].self, from: data) {
                    DispatchQueue.main.async {
                        self.recommendList = decodedData
                        self.onUpdate?()
                    }
                } else {
                    print("JSON 디코딩 실패")
                }
            } else {
                print("GPT API 요청하는데 실패했습니다.")
            }
        } catch {
            print("네트워크 오류가 발생했습니다.")
        }
    }
}
