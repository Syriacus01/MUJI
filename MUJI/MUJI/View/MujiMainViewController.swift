import UIKit
import MapKit

class MujiMainViewController: UIViewController, UITabBarDelegate {
    
    private let mapView = MKMapView() //  지도 항상 유지
    private let tabBarView = UITabBar() //  커스텀 탭바
    private var bottomSheetVC: MujiBottomSheetViewController? //  모달을 한 번만 생성하여 유지
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()    // 지도 설정
        setupTabBar()     // 탭바 설정
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSheetView() //모달 시트 생성

        //탭바를 다시 추가 (최상위 유지)
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.addSubview(self.tabBarView)
                window.bringSubviewToFront(self.tabBarView)
            }
        }
    }

    //지도(MapView) 설정
    private func setupMapView() {
        mapView.frame = view.bounds
        mapView.mapType = .standard
        mapView.isUserInteractionEnabled = true
        view.addSubview(mapView)
    }

    // 기존 탭바 설정
    private func setupTabBar() {
        let tabBarHeight: CGFloat = 80
        tabBarView.frame = CGRect(
            x: 0,
            y: UIScreen.main.bounds.height - tabBarHeight,
            width: UIScreen.main.bounds.width,
            height: tabBarHeight
        )
        tabBarView.backgroundColor = .white
        tabBarView.tintColor = .systemBlue
        tabBarView.unselectedItemTintColor = .gray
        tabBarView.delegate = self

        let emotionItem = UITabBarItem(title: "감정지도", image: UIImage(systemName: "map"), tag: 0)
        let musicItem = UITabBarItem(title: "음악추천", image: UIImage(systemName: "music.note"), tag: 1)
        let profileItem = UITabBarItem(title: "프로필", image: UIImage(systemName: "person.circle"), tag: 2)

        tabBarView.items = [emotionItem, musicItem, profileItem]
        tabBarView.selectedItem = emotionItem
    }

   
    private func setupSheetView() {
        guard bottomSheetVC == nil else {
            //print("이미 모달이 생성됨")
            return
        }

        //print("새로운 `bottomSheetVC` 생성 중")
        let bottomSheet = MujiBottomSheetViewController()
        bottomSheet.modalPresentationStyle = .pageSheet

        //`UISheetPresentationController` 설정
        if let sheet = bottomSheet.sheetPresentationController {
            let smallDetent = UISheetPresentationController.Detent.custom { _ in 180 } // 스몰 크기 설정
            sheet.detents = [smallDetent, .medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium

            //커스텀 스몰사이즈를 기본 크기로 설정
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                sheet.animateChanges {
                    sheet.selectedDetentIdentifier = sheet.detents.first { $0 == smallDetent }?.identifier
                }
            }
        }

        bottomSheet.isModalInPresentation = true
        bottomSheetVC = bottomSheet
        ///print("`bottomSheetVC` 생성 완료!")

        present(bottomSheet, animated: true) {
            //print("`bottomSheetVC`가 표시됨")

            //처음 실행 시 감정지도 탭설정
            self.bottomSheetVC?.updateContent(for: 0)
        }
    }

    //탭 클릭 감지 및 화면 변경
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //print("탭 선택됨: \(item.tag)")
        bottomSheetVC?.updateContent(for: item.tag)
    }
}
