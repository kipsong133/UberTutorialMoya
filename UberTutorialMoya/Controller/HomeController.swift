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
private let annotationIdentifer = "DiverAnnotation"

class HomeController: UIViewController {
    
    //MARK: - Properties
    
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    private let inputActivationView =  LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    
    private var user: User? {
        didSet { locationInputView.user = user }
    } 
    
    private final let locationInputViewHeight: CGFloat = 200
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserLoggedIn()
        enableLocationService()
  
//        signOut()
        
    }
    
    //MARK: - API
    
    /* 사용자 정보 fectch 메소드 */ 
    func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Service.shared.fetchUserData(uid: currentUid) { (user) in 
            self.user = user
        }
    }
    
    func fetchDrivers() {
        guard let location = locationManager?.location else { return }
        Service.shared.fetchDrivers(location: location) { (driver) in
            
            // 지도에 Pin을 생성하기 위한 코드
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            print("DEBUG: Driver's Coordinate is \(coordinate)")
            var driverIsVisible: Bool {
                return self.mapView.annotations.contains(where: { annotation -> Bool in
                    guard let driverAnno = annotation as? DriverAnnotation else { return false }
                    
                    if driverAnno.uid == driver.uid {
                        // 드라이버의 uid 와 점찍었던 uid가 같다면, 아래 코드를 실행하는 조건절
                        driverAnno.updateAnnotationPosition(withCoordinate: coordinate)
                        return true
                    }
                    return false 
                })
            }
            
            if !driverIsVisible {
                self.mapView.addAnnotation(annotation)    
            }
            
            
        }
    }
    
    
    
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
            configure()
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
    
    func configure() {
        configureUI()
        fetchUserData()
        fetchDrivers()
    }
    
    
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
        mapView.delegate = self
        
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
        tableView.tableFooterView = UIView()
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        
        
        view.addSubview(tableView)
        
    }
    
    
}


//MARK: - MKMapViewDelegate

extension HomeController: MKMapViewDelegate {
    
    // annotation의 이미지를 변경. (PinPoint 이미지 변경코드)
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifer)
            view.image = #imageLiteral(resourceName: "chevron-sign-to-right")
            return view
        }
        
        return nil
    }
    
}


//MARK: - Location Services

extension HomeController {
    
    func enableLocationService() {
        
        switch locationManager?.authorizationStatus {    // iOS14로 넘어오면서 변경됨  
        // "CLLocationManager.authorizationStatus() -> locationManager.authorizationStatus" 로
        case .notDetermined:
            print("DEBUG: Not determined..")
            locationManager?.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("DEBUG: Auth always...")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            locationManager?.requestAlwaysAuthorization()
            print("DEBUG: Auth when in use..")
        default:
            break
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
        
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
        }) { (_) in
            self.locationInputView.removeFromSuperview() //  뷰가 많이 있을 때 한 번에 제거해주는 메소드
            UIView.animate(withDuration: 0.3, animations: {
                self.inputActivationView.alpha = 1
            })
        }
    }
    
    
}

//MARK: - TableViewDelegate / DataSource

extension HomeController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Test"
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        return cell
    }
    
    
}
