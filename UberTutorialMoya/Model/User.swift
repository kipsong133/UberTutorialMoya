//
//  User.swift
//  UberTutorialMoya
//
//  Created by 김우성 on 2021/02/15.
//

struct User {
    let fullname: String
    let email: String
    let accountType: Int
    
    init(dictionary: [String: Any]) {
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.accountType = dictionary["accountType"] as? Int ?? 0
    } 
}
