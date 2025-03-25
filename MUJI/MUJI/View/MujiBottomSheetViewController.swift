import UIKit

class MujiBottomSheetViewController: UIViewController {

    private var currentViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        updateContent(for: 0) // 기본적으로 감정지도 뷰 표시
    }
    
    // 모달 내부에서 컨텐츠를 변경하는 함수
    func updateContent(for index: Int) {
        //print("updateContent 호출됨 - index: \(index)")

       
        currentViewController?.willMove(toParent: nil)
        currentViewController?.view.removeFromSuperview()
        currentViewController?.removeFromParent()

        // 개별적으로 완성한뷰 여기에 추가
        switch index {
        case 0:
            currentViewController = MujiEmotionMapViewController()
        case 1:
            currentViewController = PlayMusicViewController() // 음악 뷰
        case 2:
            currentViewController = MainTabBarController()//프로필뷰
        default:
            return
        }

        guard let newVC = currentViewController else { return }

        addChild(newVC)
        newVC.view.frame = view.bounds
        view.addSubview(newVC.view)
        newVC.didMove(toParent: self)

        //UI 강제 업데이트
        DispatchQueue.main.async {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            //print("updateContent UI 강제 업데이트")
        }
    }
}

