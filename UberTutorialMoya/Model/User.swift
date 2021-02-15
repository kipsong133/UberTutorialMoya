//
//  User.swift
//  UberTutorialMoya
//
//  Created by 김우성 on 2021/02/15.
//
import CoreLocation


struct User {
    let fullname: String
    let email: String
    let accountType: Int
    var location: CLLocation?
    let uid: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.accountType = dictionary["accountType"] as? Int ?? 0
    } 
}
