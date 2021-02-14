//
//  AuthButton.swift
//  UberTutorialMoya
//
//  Created by 김우성 on 2021/02/14.
//

import UIKit
/* 서브클래스를 통한 버튼 클래스 생성 */
// 방법은 2 가지가 있음.
// 1. 이 파일과 같이 class에 UIButton(내가원하는 객체)를 상속받아서 서브클래스를 만들고 그 클래스를 활용하는 방법
// 2. extension UIButton(내가원하는 객체)를 만든 다음에 그 내부에 func ~~~()를 통해서 메소드로 객체를 생성하는 방법이 있음.

class AuthButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setTitleColor(UIColor(white: 1, alpha: 0.5), for: .normal)
        backgroundColor = .mainBlueTint
        layer.cornerRadius = 5
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
