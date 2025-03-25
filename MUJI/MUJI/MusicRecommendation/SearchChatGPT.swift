//
//  SearchChatGPT.swift
//  MUJI
//
//  Created by 윤태한 on 3/19/25.
//

import Dispatch
import ChatGPTSwift
import Foundation

class SearchChatGPT {
    static let shared = SearchChatGPT()
    let chatGPTAPIKey: String = {
        guard let key = ProcessInfo.processInfo.environment["CHATGPT_API_KEY"] else {
            fatalError("API_KEY가 없음.")
        }
        return key
    }()
    
    func search(location: String, weather: String, emotion: String, age: Int, genre: String) async -> String {
        let para = "현위치는 \(location), \(weather), 감정 상태: \(emotion), 나이: \(age)세, 선호 장르: \(genre)"
        let formalString = "이 조건들과 참조하여 관련된 노래 5개 추천해줘 (다른 글씨는 빼고 가수 - 노래명 그리고 선정이유는 다음줄로 요약해서 출력해줘)"
        
        let api = ChatGPTAPI(apiKey: chatGPTAPIKey)
        
        print("\(para)\n\n위의 조건들을 ChatGPT에 노래 추천 요청을 시작합니다.\n")
        do {
            let response = try await api.sendMessage(text: para + formalString)
            
            return response
        } catch {
            print("에러 발생: \(error)")
            return error.localizedDescription
        }
    }
}

