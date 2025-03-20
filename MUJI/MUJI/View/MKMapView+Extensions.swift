import MapKit
import CoreLocation

extension MKMapView {
    
    /// 지도 확대 및 현재 위치 설정
    private func updateMapRegion(to location: CLLocation) {
        let coordinate = location.coordinate
        let region = MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            )
            //mapView.setRegion(region, animated: true)
        // 현재 위치보다 아래쪽을 지도 중심으로 설정하여 사용자가 위쪽에 보이도록 함
        let adjustedCoordinate = CLLocationCoordinate2D(
            latitude: coordinate.latitude - 0.002, // 조절 가능 (값이 크면 더 위로)
            longitude: coordinate.longitude
        )

        // 카메라 사용하여 위치 미세 조정
        let camera = MKMapCamera()
        camera.centerCoordinate = adjustedCoordinate
        camera.altitude = 800 // 높을수록 더 넓은 영역이 보임
        camera.pitch = 0

       // mapView.setCamera(camera, animated: true)
    }

}
