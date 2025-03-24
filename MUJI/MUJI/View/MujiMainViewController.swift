import UIKit
import MapKit
import CoreLocation

class MujiMainViewController: UIViewController, UITabBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    private let mapView = MKMapView() // 지도 항상 유지
    private let tabBarView = UITabBar() // 커스텀 탭바
    private var bottomSheetVC: MujiBottomSheetViewController? // 모달을 한 번만 생성하여 유지
    private let locationManager = CLLocationManager() // 위치 관리자 추가
    private var annotations: [MKPointAnnotation] = [] // 이모지 PIN 저장 배열

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()    // 지도 설정
        setupTabBar()     // 기존 setupTabBar 유지
        setupLocationManager() // 위치 관리자 설정
        
        for emotion in EmotionViewModel.shared.emotionPins {
            let coordinate = CLLocationCoordinate2D(latitude: emotion.latitude, longitude: emotion.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = emotion.comment
            annotation.subtitle = emotion.emotion
            mapView.addAnnotation(annotation)
            annotations.append(annotation)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSheetView() // 모달 시트 생성

        // 탭바를 다시 추가 (최상위 유지)
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.addSubview(self.tabBarView)
                window.bringSubviewToFront(self.tabBarView)
            }
        }
    }

    // 지도(MapView) 설정
    private func setupMapView() {
        mapView.frame = view.bounds
        mapView.mapType = .standard
        mapView.isUserInteractionEnabled = true
        mapView.showsUserLocation = true // 현재 위치 아이콘 표시
        mapView.delegate = self
        view.addSubview(mapView)
    }

    // 위치 관리자 설정
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization() // 위치 권한 요청
        locationManager.startUpdatingLocation() // 현재 위치 가져오기 시작
    }

    // 위치 업데이트 감지
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        updateMapRegion(to: location) // 지도 업데이트
        locationManager.stopUpdatingLocation() // 위치 업데이트 중지 (배터리 절약)
    }

    // 위치 업데이트 실패 처리
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(" 위치 업데이트 실패: \(error.localizedDescription)")
    }

    // 지도 확대 및 현재 위치 설정
    private func updateMapRegion(to location: CLLocation) {
        let coordinate = location.coordinate
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 1000, // 확대 정도 조절
            longitudinalMeters: 1000
        )
        mapView.setRegion(region, animated: true)
    }

    // 기존 탭바 설정 유지
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
        let musicItem = UITabBarItem(title: "음악", image: UIImage(systemName: "music.note"), tag: 1)
        let profileItem = UITabBarItem(title: "프로필", image: UIImage(systemName: "person.circle"), tag: 2)

        tabBarView.items = [emotionItem, musicItem, profileItem]
        tabBarView.selectedItem = emotionItem
    }

    // BottomSheet 설정 및 생성
    private func setupSheetView() {
        guard bottomSheetVC == nil else {
            return
        }

        let bottomSheet = MujiBottomSheetViewController()
        bottomSheet.modalPresentationStyle = .pageSheet

        // UISheetPresentationController 설정
        if let sheet = bottomSheet.sheetPresentationController {
            let smallDetent = UISheetPresentationController.Detent.custom { _ in 100} // 스몰 크기 설정
            sheet.detents = [smallDetent, .medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium

            // 기본 크기를 스몰로 설정
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                sheet.animateChanges {
                    sheet.selectedDetentIdentifier = sheet.detents.first { $0 == smallDetent }?.identifier
                }
            }
        }

        bottomSheet.isModalInPresentation = true
        bottomSheetVC = bottomSheet

        present(bottomSheet, animated: true) {
            // 처음 실행 시 감정지도 탭 설정
            self.bottomSheetVC?.updateContent(for: 0)
        }
    }

    // 감정 이모지 핀 추가 기능 (기존 이모지가 있으면 삭제 후 추가)
    func addEmojiAnnotation(emoji: String, emotion: String) {
        guard let location = locationManager.location else { return }
        let coordinate = location.coordinate

        // 기존 이모지가 존재하는지 확인 후 삭제
        removeNearbyAnnotations(near: coordinate)

        // 새로운 이모지 추가
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = emotion
        annotation.subtitle = emoji
        mapView.addAnnotation(annotation)
        annotations.append(annotation)
    }

    // 근처(50m 이내)에 있는 기존 이모지 PIN 삭제
    private func removeNearbyAnnotations(near coordinate: CLLocationCoordinate2D) {
        let threshold: Double = 50.0 // 오차 범위 (50m)

        let closeAnnotations = mapView.annotations.compactMap { annotation -> MKPointAnnotation? in
            guard let annotation = annotation as? MKPointAnnotation else { return nil }
            let pinLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            return pinLocation.distance(from: userLocation) < threshold ? annotation : nil
        }

        // CoreData에서 삭제할 좌표 리스트
        let coordinatesToDelete = closeAnnotations.map { $0.coordinate }

        // 지도에서 제거
        closeAnnotations.forEach { annotation in
            mapView.removeAnnotation(annotation)
            if let index = annotations.firstIndex(where: { $0 === annotation }) {
                annotations.remove(at: index)
            }
        }

        // CoreData에서 한 번에 삭제
        EmotionViewModel.shared.deleteEmotions(at: coordinatesToDelete)
    }


    // 지도에서 이모지 표시 (MKAnnotationView 커스텀)
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }

        let identifier = "emojiAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }

        if let subtitle = annotation.subtitle, let emoji = subtitle {
            let label = UILabel()
            label.text = emoji
            label.font = UIFont.systemFont(ofSize: 30)
            label.sizeToFit()
            annotationView?.image = label.asImage()
        }

        return annotationView
    }

    func changeSheetToSmallSize() {
        if let sheet = bottomSheetVC?.sheetPresentationController {
            let smallDetent = UISheetPresentationController.Detent.custom { _ in 100 }
            DispatchQueue.main.async {
                sheet.animateChanges {
                    sheet.detents = [smallDetent, .medium(), .large()]
                    sheet.selectedDetentIdentifier = smallDetent.identifier
                }
            }
        }
    }
    func changeSheetToLargeSize() {
        if let sheet = bottomSheetVC?.sheetPresentationController {
            DispatchQueue.main.async {
                sheet.animateChanges {
                    sheet.detents = [.medium(), .large()]
                    sheet.selectedDetentIdentifier = .large
                }
            }
        }
    }


    // 탭 클릭 감지 및 화면 변경
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        bottomSheetVC?.updateContent(for: item.tag)
    }
} 
