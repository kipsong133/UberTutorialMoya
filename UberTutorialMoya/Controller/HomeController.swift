//
//  HomeController.swift
//  UberTutorialMoya
//
//  Created by 김우성 on 2021/02/14.
//

import UIKit
import Firebase
import MapKit

private let reuseIdentifier = "LocationCell"

class HomeController: UIViewController {
    
    //MARK: - Properties
    
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private let inputActivationView =  LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    
    private final let locationInputViewHeight: CGFloat = 200
    
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
        inputActivationView.alpha = 0
        inputActivationView.delegate = self
        
        UIView.animate(withDuration: 2) { 
            self.inputActivationView.alpha = 1
        }
        
        configureTableView()

    }
    
    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame

        // 사용자 위치를 표시하는 코드
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    
    func configureLocationInputView() {
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor,
                                 height: locationInputViewHeight)
        locationInputView.alpha = 0
        locationInputView.delegate = self
        UIView.animate(withDuration: 0.5, animations: {
            self.locationInputView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.frame.origin.y = self.locationInputViewHeight
            })
        }
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        
        
        view.addSubview(tableView)
        
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

//MARK: - LocationInputActivationViewDelegate

extension HomeController: LocationInputActivationViewDelegate {
    func presentLocationInputView() {
        inputActivationView.alpha = 0
        configureLocationInputView()
    }
    
    
}

//MARK: - LocationInputViewDelegate

extension HomeController: LocationInputViewDelegate {
    func dismissLocationInputView() {
        locationInputView.removeFromSuperview() //  뷰가 많이 있을 때 한 번에 제거해주는 메소드
        
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
        }) { (_) in
            
            UIView.animate(withDuration: 0.3, animations: {
                self.inputActivationView.alpha = 1
            })
        }
    }
    
    
}

//MARK: - TableViewDelegate, DataSource

extension HomeController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        return cell
    }
    
    
}
