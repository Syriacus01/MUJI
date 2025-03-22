//  UserViewModel.swift
//  Created by 조수원 on 3/18/25

import Foundation
import UIKit
import CoreData

// MARK: Core Data에서 사용자 정보를 불러오고 수정, 삭제하는 로직
class UserViewModel: ObservableObject {
    
    static let shared = UserViewModel()
    private init() {}
    
    var onUpdate: (() -> Void)?
    
    @Published var user: UserModel? // 현재 사용자 정보 (없을 수도 있어서 옵셔널처리)
    
// MARK: 사용자 정보 불러오기
    func fetchUser() {
        let context = CoreDataManager.shared.mainContext
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest) // 사용자 정보가 있는지 UserEntity를 가져오고
            
            if let entity = results.first { // 저장된 데이터가 있으면 UserModel로 변환
                user = UserModel(
                    name: entity.name ?? "", // 사용자 이름 (기본값은 "")
                    age: Int(entity.age), // 사용자 나이 (Int로 변환)
                    profileImage: {
                        if let data = entity.profileImage {
                            return UIImage(data: data) ?? UIImage() // 사용자 프로필 이미지 변환
                        } else {
                            return UIImage()
                        }
                    }(),
                    musicGenre: entity.musicGenre ?? "" // 사용자가 선택한 음악 장르 (기본값은 "")
                )
            } else { // 사용자 정보 데이터가 없으면
                user = nil
            }
        } catch {
            print("사용자 정보를 불러오는데 실패했습니다.")
            user = nil
        }
        onUpdate?() // UI update
    }

// MARK: 사용자 정보 업데이트 (없으면 만들고, 있으면 수정함)
    func updateUser(name: String, age: Int, profileImage: UIImage, musicGenre: String) {
        let context = CoreDataManager.shared.mainContext
        
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest() // 사용자 정보 있는지 확인
        do {
            let results = try context.fetch(fetchRequest)
            
            if let entity = results.first { // 사용자 정보가 있으면 첫 번째 사용자 정보를 가져와서 수정
                // 수정된 값을 업데이트
                entity.name = name
                entity.age = Int64(age)
                entity.musicGenre = musicGenre
                if let imageData = profileImage.pngData() {
                    entity.profileImage = imageData
                } // UIImage를 Data로 변환해서 저장
            } else { // 사용자 정보가 없으면 새로 만들어야함
                let newUser = UserEntity(context: context)
                newUser.name = name
                newUser.age = Int64(age)
                newUser.musicGenre = musicGenre
                
                if let imageData = profileImage.pngData() {
                    newUser.profileImage = imageData
                } // UIImage를 Data로 변환해서 저장
            }
            CoreDataManager.shared.saveContext() // 변경된 사용자 정보 저장
        } catch {
            print("사용자 정보 저장에 실패했습니다.")
        }
        fetchUser() // 사용자 정보 저장 후 다시 불러오기
    }
// MARK: 사용자 정보 삭제
    func deleteUser() {
        let context = CoreDataManager.shared.mainContext

        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        do { // Core Data에서 사용자 정보를 가져오고
            let results = try context.fetch(fetchRequest)
            // 사용자 정보가 있으면 삭제하기
            if let entity = results.first {
                context.delete(entity) // Core Data에서 삭제
                CoreDataManager.shared.saveContext() // 사용자 정보를 삭제한 뒤 저장
            }
            user = nil // 사용자 정보를 삭제한 뒤 사용자 정보는 nil이 되게함
        } catch { // 만약 사용자 정보 삭제를 못한다면
            print("사용자 정보 삭제에 실패하였습니다.")
        }
        onUpdate?() // UI update
    }
    
// MARK: UserDefaults -> Core Data로 변환
    func userDefaultsToCoreData() {
        guard let userDict = UserDefaults.standard.dictionary(forKey: "user") else {
            print("키 or 값이 저장되어 있지 않습니다.")
            return
        }
        let context = CoreDataManager.shared.mainContext
        
        let userEntity = UserEntity(context: context)
        
        if let name = userDict["name"] as? String {
            userEntity.name = name
        }
        if let age = userDict["age"] as? Int {
            userEntity.age = Int64(age)
        }
        if let genres = userDict["genres"] as? [String] {
            userEntity.musicGenre = genres.joined(separator: ", ") ?? ""
        }
        if let imageData = userDict["profileImageData"] as? Data {
            userEntity.profileImage = imageData
        }
        do {
            try context.save()
            print("새로운 UserEntity를 생성하여 저장하였습니다.")
        } catch {
            print("Core Data 저장 실패")
        }
        UserDefaults.standard.removeObject(forKey: "user")
        print("UserDefaults에서 'user' 키의 값을 제거하였습니다.")
        
        fetchUser()
    }
}
