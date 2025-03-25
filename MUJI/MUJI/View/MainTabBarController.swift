//
//  MainTabBarController.swift
//  MUJI
//
//  Created by 원대한 on 3/18/25.
//


import UIKit


class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
        setupTabBarAppearance()
    }
    
    private func setupViewControllers() {
        // 프로필 뷰 컨트롤러 
        let profileVC = ProfileViewController()
        profileVC.tabBarItem = UITabBarItem(title: "프로필", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        
        // 기본 설정 뷰 컨트롤러 추가
        let defaultSettingsVC = DefaultSettingsViewController()
        defaultSettingsVC.tabBarItem = UITabBarItem(title: "기본값", image: UIImage(systemName: "gear"), selectedImage: UIImage(systemName: "gear"))
        
        // 두 개의 탭을 가진 탭 바 컨트롤러 설정
        viewControllers = [
            UINavigationController(rootViewController: profileVC),
            UINavigationController(rootViewController: defaultSettingsVC)
        ]
    }
    
    private func setupTabBarAppearance() {
        tabBar.tintColor = UIColor(red: 88/255, green: 126/255, blue: 255/255, alpha: 1)
        tabBar.backgroundColor = UIColor.white
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.1
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBar.layer.shadowRadius = 8
    }
}

#Preview {
    MainTabBarController()
}
