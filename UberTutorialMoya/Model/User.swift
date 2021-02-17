//
//  User.swift
//  UberTutorialMoya
//
//  Created by 김우성 on 2021/02/15.
//
// 이 파일은 탑승자나 운전자가 회원가입을 할 때, 필요한 정보들을 Model로 구성한 파일입니다.
// 이름, 이메일, 종류(탑승자 혹은 운전자) 위치정보, uid(firebase에서 id로 사용되는) 등을 input합니다.
// 여기서 부여된 uid에 따라서 같은 사용자인지 확인합니다.


import CoreLocation

enum AccountType: Int {
    case passenger
    case driver
}


struct User {
    let fullname: String
    let email: String
    var accountType: AccountType! // 운전자 혹은 탑승자로 반드시 결정해야하므로 "!" 를 사용했습니다.
    var location: CLLocation?
    let uid: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        
        if let index = dictionary["accountType"] as? Int {
            self.accountType = AccountType(rawValue: index)  
        }
    } 
}
