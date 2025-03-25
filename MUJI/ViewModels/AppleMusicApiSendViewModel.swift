//  AppleMusicApiSendViewModel.swift
//  Created by 조수원 on 3/19/25

import Foundation
import CoreData

// MARK: GPT API -> Apple Music API로 전송하는 로직
class AppleMusicApiSendViewModel {
    
    static let shared = AppleMusicApiSendViewModel()
    private init() {}
    
    var onUpdate: (() -> Void)? // 뷰에서 UI 업데이트 하실 때 onUpdate 가져가서 실행해주시면 돼요

    var artistName: String = ""
    var title: String = ""
    
// MARK: GPT API를 Apple Music API에 보낼 수 있도록 변환
    func prepareAppleMusicApiData(from gptResponse: GptRecommendModel) -> AppleMusicApiSendModel {
        return AppleMusicApiSendModel(
            artistName: gptResponse.artistName,
            title: gptResponse.title
        )
    }
    
// MARK: Apple Music API에 데이터 요청
    func sendToAppleMusicApi(appleMusicData: AppleMusicApiSendModel) {
        self.artistName = appleMusicData.artistName
        self.title = appleMusicData.title
        
// MARK: MusicKit 추가 예정

        onUpdate?()
    }
}
