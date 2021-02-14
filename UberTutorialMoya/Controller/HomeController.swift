//
//  HomeController.swift
//  UberTutorialMoya
//
//  Created by 김우성 on 2021/02/14.
//

import UIKit
import Firebase

class HomeController: UIViewController {
    
    //MARK: - Properties
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserLoggedIn()
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
    
    
}
