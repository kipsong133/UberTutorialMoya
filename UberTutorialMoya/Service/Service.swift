//
//  Service.swift
//  UberTutorialMoya
//
//  Created by 김우성 on 2021/02/15.
//
// Firebase에 데이터 송수신에 관련된 메소드를 구현한 파일입니다.



import Firebase
import GeoFire

// Firebase에 table로 이동하는 경로를 저장한 상수.
let DB_REF = Database.database().reference()    //  Firebase에 접속하는 코드라고 생각하면됨.
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATIONS = DB_REF.child("driver-locations")
let REF_TRIPS = DB_REF.child("trips")

struct Service {
    // 네트워크 통신을 구현하는 데 Service가 싱글톤으로 구성되는 것이 적합.
    // 여러 가지 이유가 있지만, 여러번 통신하면 data낭비, 기기 메모리 낭비 등 불필요한 작업이 생기므로.
    static let shared = Service()
    
    
    // 유저가 가입하면 그 정보를 table에 추가하는 메소드.
    func fetchUserData(uid: String, completion: @escaping(User) -> Void) {
//        guard let currentUid = Auth.auth().currentUser?.uid else { return } // 모든 유저의 정보를 가져오지 않기 위한 코드
//        print("DEBUG: Current uid is \(currentUid)")        
        
        // 아래 코드 설명 (까먹을까봐 메모) 
        // Database에 접속 -> 그중에서 "users" 항목으로 접속 -> 그 중에서 현재 접속한 uid로 접속 -> 그리고 .value로 설정하여 값을 가져오고
        // 그 결과물을 snapshot에 넘김. 그래서 snapshot.value 를 프린트 해보면 uid가 나타나게 됨.
        
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            completion(user)
        }
    }
    
    // 운전자로 등록했을 때, 데이터를 fetch 하기 위한 메소드.
    func fetchDrivers(location: CLLocation, completion: @escaping (User)-> Void) {
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        
        REF_DRIVER_LOCATIONS.observe(.value) { (snapshot) in
            geofire.query(at: location, withRadius: 50).observe(.keyEntered, with: { (uid, location) in
                self.fetchUserData(uid: uid, completion: { (user) in
                    var driver = user
                    driver.location = location
                    completion(driver)
                })
            })
        }
    }
    
    // 운전자와 탑승자의 위치정보를 모두 테이블에 업로드하기 위한 메소드.
    func uploadTrip(_ pickupCoordinates: CLLocationCoordinate2D, _ destinationCoordinates: CLLocationCoordinate2D,
                    completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let pickupArray = [pickupCoordinates.latitude, pickupCoordinates.longitude]
        let destinationArray = [destinationCoordinates.latitude, destinationCoordinates.longitude]
        
        let values = ["pickupCoordinates": pickupArray,
                     "destinationCoordinates": destinationArray,
                     "state": TripState.requested.rawValue] as [String : Any]
        
        REF_TRIPS.child(uid).updateChildValues(values, withCompletionBlock: completion)
        
    }

    
}


