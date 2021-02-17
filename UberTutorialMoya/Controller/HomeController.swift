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

// enum을 활용하여 이미지를 묶어둠.
private enum ActionButtonConfiguration {
    case showMenu
    case dissmissActionView
    
    init() {
        self = .showMenu
    }
}

class HomeController: UIViewController {
    
    //MARK: - Properties
    
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    
    private let inputActivationView =  LocationInputActivationView()
    private let rideActionView = RideActionView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    private var searchResult = [MKPlacemark]()
    private final let locationInputViewHeight: CGFloat = 200
    private var actionButtonConfig = ActionButtonConfiguration()
    private var route: MKRoute?

    private var user: User? {
        didSet { locationInputView.user = user }
    } 
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserLoggedIn()
        enableLocationService()
  
//        signOut()
        
    }
    
    //MARK: - Selectors
    
    @objc func actionButtonPressed() {
        switch actionButtonConfig {
        case .showMenu:
            print("DEBUG: Handle show menu..")
        case .dissmissActionView: 
            // 핀포인트를 제거해주는 커스텀메소드
            removeAnnotationsAndOverlays()
            // 검색한 이후 뒤로가거버튼을 눌렀을 때, 아래코드가 호출됨. 경로에 Zoom-In된 것을 Zoom-Out해줌.
            mapView.showAnnotations(mapView.annotations, animated: true)
            
            // 검색화면에서 한번 뒤로가기 클릭하면 다시 원래 이미지인 .showMenu로 돌아오록 처리한 코드
            UIView.animate(withDuration: 0.3) { 
                self.inputActivationView.alpha = 1
                self.configureActionButton(config: .showMenu)
            }
            

        }
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
    
    fileprivate func configureActionButton(config: ActionButtonConfiguration) { // ActionButtonConfiguration이 private이라서 
                                                                                // fileprivate을 붙여야함.
        switch config {
        case .showMenu:
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .showMenu
        case .dissmissActionView:
            actionButton.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            actionButtonConfig = .dissmissActionView
        }
    }
    
    
    func configureUI() {
        configureMapView()
        configureRideActionView()
        
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                            paddingTop: 16, paddingLeft: 20, width: 30, height: 30)
        
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputActivationView.anchor(top: actionButton.bottomAnchor, paddingTop: 32)
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
    
    func configureRideActionView() {
        view.addSubview(rideActionView)
        rideActionView.frame = CGRect(x: 0, y: view.frame.height - 300,
                                      width: view.frame.width, height: 300)

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
        
    
    
    func dissmissLocationView(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
            self.locationInputView.removeFromSuperview() //  뷰가 많이 있을 때 한 번에 제거해주는 메소드
        }, completion: completion)
    }
    
}



//MARK: - MapView Helper Functions

private extension HomeController {
    func searchBy(naturalLanguateQuery: String, completion: @escaping([MKPlacemark]) -> Void) {
        var results = [MKPlacemark]()
        
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguateQuery
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else { return }
            
            response.mapItems.forEach( { (item) in
                results.append(item.placemark)
            })
            completion(results)
        }
    }
    
    
    func generatePolyline(toDestination destination: MKMapItem) {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { (response, error) in
            guard let response = response else { return }
            self.route = response.routes[0]
            guard let polyline = self.route?.polyline else { return }
            self.mapView.addOverlay(polyline)
            
        }
        
    }
    
    func removeAnnotationsAndOverlays() {
        // 아래 코드를 통해서 뒤로가기를 누르면 annotation(핀포인트)를 제거할 수 있음.
        mapView.annotations.forEach { (annotation) in
            if let anno = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(anno)
            }
        }
        
        // 경로를 제거할 수 있는 로직
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
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
    
    // 목적지를 찍으면 목적지와 출발지 사이에 가는 경로를 그려주는 메소드
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route { 
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .mainBlueTint
            lineRenderer.lineWidth = 3
            return lineRenderer
        }
        return MKOverlayRenderer()
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
    // 검색 시, 검색한 값에 대한 데이터를 가져와주는 메소드
    func executeSearch(query: String) {
        searchBy(naturalLanguateQuery: query) { (results) in
            self.searchResult = results
            self.tableView.reloadData()
        }
    }
    
    func dismissLocationInputView() {
        dissmissLocationView { (_) in
            UIView.animate(withDuration: 0.5, animations: { 
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
        return section == 0 ? 2 : searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        
        if indexPath.section == 1 {
            cell.placemark = searchResult[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 사용자가 선택한 목적지에 PinPoint가 찍히도록 하는 코드
        let selectedPlacemark = searchResult[indexPath.row]
        
        
        configureActionButton(config: .dissmissActionView)
        
        let destination = MKMapItem(placemark: selectedPlacemark)
        generatePolyline(toDestination: destination)
        
        
        dissmissLocationView { (_) in
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedPlacemark.coordinate
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)   // PinPoint가 커지도록 하는 코드
            
            // 운전자가 아닌 핀포인트(Annotation)을 찾아서 상수에 할당.
            // 짧은 코드를 통해서 annotations 중에서 출발점을 찾게된 것이고 최 하단에 있는 ShowAnnotation에서 zoom in 해준다.
            let annotations = self.mapView.annotations.filter({ !$0.isKind(of: DriverAnnotation.self) })
            
            self.mapView.showAnnotations(annotations, animated: true)
        }
    }
    
    
    
}
