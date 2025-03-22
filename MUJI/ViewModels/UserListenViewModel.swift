//  UserListenViewModel.swift
//  Created by 조수원 on 3/19/25

import Foundation
import CoreData

// MARK: 사용자가 재생한 노래 데이터를 불러오고 수정, 삭제하는 로직
class UserListenViewModel {
    
    static let shared = UserListenViewModel()
    private init() {}
    
    var onUpdate: (() -> Void)?
    var listeningList: [UserListenModel] = [] // Core Data에서 불러온 데이터를 배열로 저장
    
// MARK: 사용자가 재생한 노래 불러오기
    func fetchUserListening() {
        let context = CoreDataManager.shared.mainContext
        
        let fetchRequest: NSFetchRequest<UserListeningEntity> = UserListeningEntity.fetchRequest()
        do { // 사용자가 재생한 노래를 Core Data에서 가져오고
            let results = try context.fetch(fetchRequest)

            listeningList = results.map { entity in // 저장된 데이터가 있으면 UserModel로 변환
                UserListenModel(
                    artistName: entity.artistName ?? "", // 아티스트 이름
                    title: entity.title ?? "", // 노래 제목
                    emotion: entity.emotion ?? "" // 이모지 종류
                )
            }
        } catch {
            print("사용자가 재생한 노래가 없습니다.")
        }
        onUpdate?()
    }
    
// MARK: 사용자가 재생한 새로운 노래 추가
    func addUserListening(artistName: String, title: String, emotion: String) {
        let context = CoreDataManager.shared.mainContext
        
        let newListening = UserListeningEntity(context: context)
        newListening.artistName = artistName
        newListening.title = title
        newListening.emotion = emotion

        CoreDataManager.shared.saveContext() // 새로 추가한 노래를 데이터에 저장
        fetchUserListening()
    }
    
// MARK: 사용자가 재생했던 노래 데이터 삭제
    func deleteUserListening(at index: Int) {
        guard index >= 0 && index < listeningList.count else { return }
        let target = listeningList[index] // 삭제 하고 싶은 노래의 데이터를 인덱스로 가져옴
        
        let context = CoreDataManager.shared.mainContext

        let fetchRequest: NSFetchRequest<UserListeningEntity> = UserListeningEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "artistName == %@", target.artistName) // 아티스트 명으로 데이터에 있는지 검색하기
        do { // 데이터에서 검색이 된다면
            if let entityToDelete = try context.fetch(fetchRequest).first {
                context.delete(entityToDelete) // 데이터에서 삭제
                CoreDataManager.shared.saveContext()
            }
        } catch {
            print("사용자가 재생한 노래가 삭제되지 않았습니다.")
        }
        fetchUserListening()
    }
}
