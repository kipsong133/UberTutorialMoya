//
//  LocationInputView.swift
//  UberTutorialMoya
//
//  Created by 김우성 on 2021/02/15.
//

import UIKit

protocol LocationInputViewDelegate: class {
    func dismissLocationInputView()
}


class LocationInputView: UIView {

    //MARK: - Properties
    
    weak var delegate: LocationInputViewDelegate?
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp-1"), for: .normal)
        button.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Liftcycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        
        addSubview(backButton)
        backButton.anchor(top: topAnchor, left: leftAnchor, paddingTop: 44, paddingLeft: 12,
                          width: 24, height: 25)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Actions
    
    @objc func handleBackTapped() {
        delegate?.dismissLocationInputView()
    }
    
    
    
    

}