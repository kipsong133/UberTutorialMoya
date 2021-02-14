//
//  HomeController.swift
//  UberTutorialMoya
//
//  Created by 김우성 on 2021/02/14.
//

import UIKit
import Firebase
import MapKit

class HomeController: UIViewController {
    
    //MARK: - Properties
    
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private let inputActivationView =  LocationInputActivationView()
    
    
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserLoggedIn()
        enableLocationService()
        
//        signOut()
        view.backgroundColor = .red
        
    }
    
    //MARK: - API
    
    /* 로그인상태인지 아닌지 확인하는 메소드 */
    func checkIfUserLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            // 만약 로그인 상태가 아니라면, 로그인 페이지로 이동
            // 🔥 유의사항으로 DispatchQueue.main 으로 해주어야합니다. 왜냐하면 위에 네트워킹을 한 이후에 UI 구현이므로!!
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            } 
            print("DEBUG: User not logged in..")
            
        } else {
            // 만약 로그인 상태라면 맵킷의 맵을 화면에 구현함.
            configureUI()
            print("DEBUG: User's id is \(Auth.auth().currentUser?.uid)")
        }
    }
    
    /* 로그아웃하는 메소드 */    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("DEBUG: Error signing out")
        }
    }
    
    
    //MARK: - Action
    
    
    //MARK: - Helpers
    
    func configureUI() {
        configureMapView()

        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputActivationView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        
    }
    
    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame

        // 사용자 위치를 표시하는 코드
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    
    
}

//MARK: - Location Services

extension HomeController: CLLocationManagerDelegate {
    
    func enableLocationService() {
        locationManager.delegate = self
        
        switch locationManager.authorizationStatus {    // iOS14로 넘어오면서 변경됨  
        // "CLLocationManager.authorizationStatus() -> locationManager.authorizationStatus" 로
        case .notDetermined:
            print("DEBUG: Not determined..")
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("DEBUG: Auth always...")
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
            print("DEBUG: Auth when in use..")
        default:
            break
        }
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
