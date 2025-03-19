//  CoreDataManager.swift
//  Created by 조수원 on 3/17/25

import CoreData
import UIKit

class CoreDataManager {
    
// MARK: 싱글톤 패턴 적용 : 전역에서 'CoreDataManager.shared' 호출해서 바로 사용할 수 있도록
    static let shared = CoreDataManager()

    private init() {} // 외부에서 인스턴스 추가 못하게 금지
    
// MARK: Core Data 저장소
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MUJI")
        
        // 데이터 로드
        container.loadPersistentStores { _, error in
            if let error = error {
                print("데이터가 로드되지 않았습니다.")
            }
        }
        return container
    }()
    
// MARK: Main Context
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
// MARK: 변경된 정보 저장
    func saveContext() {
        if mainContext.hasChanges {
            do {
                try mainContext.save()
            } catch {
                print("데이터가 저장되지 않았습니다.")
            }
        }
    }
    
// MARK: 새로운 사용자 정보 생성
// 기본값이 공백이어도 nil을 반환할 수 있어서 기본값으로 하나 생성할 수 있게 만들었어요
    func createUser(name: String, age: Int, profileImage: UIImage, musicGenre: String) {
        let newUser = UserEntity(context: mainContext) // 새로운 사용자 생성
        newUser.name = name
        newUser.age = Int64(age)
        newUser.musicGenre = musicGenre
        
        if let imageData = profileImage.pngData() {
            newUser.profileImage = imageData
        } // UIImage를 Data로 변환해서 저장
        
        saveContext() // 새로운 사용자 데이터 저장
    }
    
// MARK: 사용자 정보 불러오기
    
    func fetchUser() -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        
        do {
            let results = try mainContext.fetch(request) // 사용자 정보를 불러오고
            return results.first // 가장 첫 번째 사용자 데이터부터 불러옴 (없으면 nil)
        } catch {
            print("사용자 정보를 불러오지 못했습니다.")
            return nil
        }
    }
    
// MARK: 사용자 정보 수정

    func updateUser(name: String, age: Int, profileImage: UIImage, musicGenre: String) {
        guard let userEntity = fetchUser() else {
            print("사용자 정보가 없습니다.") // 수정할 사용자 정보가 없을 때
            return
        }
        
        userEntity.name = name
        userEntity.age = Int64(age)
        userEntity.musicGenre = musicGenre
        
        if let imageData = profileImage.pngData() {
            userEntity.profileImage = imageData
        } // UIImage를 Data로 변환해서 저장
        
        saveContext() // 수정된 데이터 저장
    }
    
// MARK: 사용자 정보 삭제

    func deleteUser() {
        guard let userEntity = fetchUser() else {
            print("사용자 정보가 없습니다.") // 삭제할 사용자 정보가 없을 때
            return
        }

        mainContext.delete(userEntity) // 사용자 정보가 있으면 Core Data에서 사용자 정보를 삭제
        saveContext() // 삭제된 데이터 저장
    }
}
