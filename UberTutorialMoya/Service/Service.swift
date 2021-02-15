//
//  Service.swift
//  UberTutorialMoya
//
//  Created by 김우성 on 2021/02/15.
//

import Firebase

let DB_REF = Database.database().reference()    //  Firebase에 접속하는 코드라고 생각하면됨.
let REF_USERS = DB_REF.child("users")

struct Service {
    // 네트워크 통신을 구현하는 데 Service가 싱글톤으로 구성되는 것이 적합.
    // 여러 가지 이유가 있지만, 여러번 통신하면 data낭비, 기기 메모리 낭비 등 불필요한 작업이 생기므로.
    static let shared = Service()
    let currentUid = Auth.auth().currentUser?.uid   // 모든 유저의 정보를 가져오지 않기 위한 코드
    
    func fetchUserData(completion: @escaping(User) -> Void) {
        print("DEBUG: Current uid is \(currentUid!)")        
        // 아래 코드 설명 (까먹을까봐 메모)
        // Database에 접속 -> 그중에서 "users" 항목으로 접속 -> 그 중에서 현재 접속한 uid로 접속 -> 그리고 .value로 설정하여 값을 가져오고
        // 그 결과물을 snapshot에 넘김. 그래서 snapshot.value 를 프린트 해보면 uid가 나타나게 됨.
        REF_USERS.child(currentUid!).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let user = User(dictionary: dictionary)
            completion(user)
        }
    }
}


