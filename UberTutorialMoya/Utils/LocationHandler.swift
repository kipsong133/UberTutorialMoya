//
//  LocationHandler.swift
//  UberTutorialMoya
//
//  Created by 김우성 on 2021/02/15.
//

import CoreLocation


class LocationHandler: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationHandler()
    var locationManager: CLLocationManager!
    var location: CLLocation?
 
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
   
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // iOS 14로 넘어오면서 매소드가 변경된 부분임.
        // 기존 : locationManager(_ manager:didChagneAuthorization status:)
        // 앱을 사용중이 아닌 경우에도 허용할 것인지 사용자에게 물어보는 코드
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
}
