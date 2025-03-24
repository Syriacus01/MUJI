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
                let name = entity.name ?? ""
                let age = Int(entity.age)
                let image: UIImage = {
                    if let data = entity.profileImage {
                        return UIImage(data: data) ?? UIImage()
                    } else {
                        return UIImage()
                    }
                }()
                let genres = (entity.musicGenre ?? "").components(separatedBy: ",")
                
                user = UserModel(name: name,
                                 age: age,
                                 profileImage: image,
                                 musicGenre: genres,
                                 userInfo: true
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
            CoreDataManager.shared.saveContext()
            print("유저 정보 코어데이터 저장완료")// 변경된 사용자 정보 저장
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
    
// MARK: 음악 장르 배열 리턴 (문자열로 리턴되게)
    func getGenreArray() -> String {
        return user?.musicGenre.joined(separator: ",") ?? ""
    }
    
// MARK: UserDefaults -> Core Data로 변환
    func userDefaultsToCoreData() {
        print("userDefaultsToCoreData 실행됨")
        
        let defaults = UserDefaults.standard
        let context = CoreDataManager.shared.mainContext
        
        let name = defaults.string(forKey: "profile_name") ?? ""
        let ageString = defaults.string(forKey: "profile_age") ?? ""
        let age = Int(ageString)
        let musicGenre = defaults.stringArray(forKey: "profile_genres") ?? []
        let imageData = defaults.data(forKey: "profile_image") ?? Data()
        
        print("이름: \(name), 나이: \(age), 장르: \(musicGenre)")
        
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        
        do {
            let result = try context.fetch(fetchRequest)
            let userEntity = result.first ?? UserEntity(context: context)
            
            userEntity.name = name
            userEntity.age = Int64(age ?? 0)
            userEntity.musicGenre = musicGenre.joined(separator: ",")
            userEntity.profileImage = imageData
            
            try context.save()
            print("coredata에 저장완료")
            defaults.set(true, forKey: "user_synced_to_coredata")
        } catch {
            print("coredata 저장실패")
        }
        fetchUser()
    }

// GPT API로 저장된 유저 정보 가져올 때 사용
    func getUserInfo() -> (age: Int, genre: String)? {
        guard let user = user else {
            print("저장된 유저 정보 없음")
            return nil
        }
        let genreString = user.musicGenre.joined(separator: ", ")
        return (age: user.age, genre: genreString)
    }
}
