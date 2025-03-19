//
//  SearchChatGPT.swift
//  MUJI
//
//  Created by 윤태한 on 3/19/25.
//

import Dispatch
import ChatGPTSwift

class SearchChatGPT {
    
    let chatGPTAPIKey = ""
    
    func search(input: String) async -> String {
        let formalString = " 현재 날씨에 어울리는 노래 3개 추천해줘(다른 글씨는 빼고 가수 - 노래명 형식으로 출력해줘)"
        let api = ChatGPTAPI(apiKey: chatGPTAPIKey)
        
        do {
            let response = try await api.sendMessage(text: input + formalString)
            return response
        } catch {
            print("에러 발생: \(error)")
            return error.localizedDescription
        }
    }
}
