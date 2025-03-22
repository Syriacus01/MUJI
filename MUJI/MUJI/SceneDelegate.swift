//
//  SceneDelegate.swift
//  MUJI
//
//  Created by 조수원 on 3/15/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

// MARK: 코드베이스 구현을 위해 SceneDelegate 수정
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return } // guard let 바인딩으로 UIWindowScene 유효성 검사
        
        let window = UIWindow(windowScene: windowScene)
        // UIWindow 객체 생성 후 유효성 검사를 한 windowScene를 사용해서 초기화
        UserViewModel.shared.fetchUser() // 앱 실행 시 Core Data에 저장된 데이터를 불러옴
        
        let vc = MujiMainViewController()//메인뷰 변경
        window.rootViewController = vc
        self.window = window
        // 하나 이상의 뷰를 포함시키기 위해 프로젝트 첫 세팅 시 ViewController를 rootViewController에 담음
        
        window.makeKeyAndVisible()
        // makeKeyAndVisible 메서드 호출하여 window를 화면에 표시하고 key window로 지정. (key window는 사용자 입력을 받는 window)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

