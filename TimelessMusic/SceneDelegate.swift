//
//  SceneDelegate.swift
//  TimelessMusic
//
//  Created by Example on 2025/03/19.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    /// 앱이 실행될 때(또는 씬이 연결될 때) 호출됩니다.
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        // UIWindowScene이 맞는지 확인
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // 윈도우 생성 및 연결
        window = UIWindow(windowScene: windowScene)
        
        // 왼쪽 탭: 지도
        let leftVC = UIViewController()
        leftVC.view.backgroundColor = .white
        leftVC.tabBarItem = UITabBarItem(title: "Map",
                                         image: UIImage(systemName: "map"),
                                         tag: 0)
        
        // 중앙 탭: 메인 플레이 화면 (MusicKit)
        let centerVC = ViewController()
        centerVC.view.backgroundColor = .white
        centerVC.tabBarItem = UITabBarItem(title: "Play",
                                           image: UIImage(systemName: "music.note"),
                                           tag: 1)
        
        // 오른쪽 탭: 프로필
        let rightVC = UIViewController()
        rightVC.view.backgroundColor = .white
        rightVC.tabBarItem = UITabBarItem(title: "Profile",
                                          image: UIImage(systemName: "person.crop.circle"),
                                          tag: 2)
        
        // 탭 바 컨트롤러 초기화
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [leftVC, centerVC, rightVC]
        
        // 탭 바의 외형 설정 (약간 불투명하게)
        tabBarController.tabBar.isTranslucent = true
        tabBarController.tabBar.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        
        // 루트 뷰 컨트롤러 설정
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // 시스템에 의해 씬이 해제될 때 호출됩니다.
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // 씬이 비활성 상태에서 활성 상태로 전환될 때 호출됩니다.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // 씬이 활성 상태에서 비활성 상태로 전환될 때 호출됩니다.
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // 씬이 백그라운드에서 포그라운드로 전환될 때 호출됩니다.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // 씬이 포그라운드에서 백그라운드로 전환될 때 호출됩니다.
    }
}
