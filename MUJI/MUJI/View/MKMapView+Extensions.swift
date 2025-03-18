import MapKit
import CoreLocation

extension MKMapView {
    
    /// 지도 확대 및 현재 위치 설정
    func updateRegion(to location: CLLocation) {
        let coordinate = location.coordinate
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 1000, // 확대 정도 조절
            longitudinalMeters: 1000
        )
        self.setRegion(region, animated: true)
    }
}
