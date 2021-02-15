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
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let startLocationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let linkingView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    
    private let destinationLocationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var startingLocationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Current Location"
        tf.backgroundColor = .systemGroupedBackground
        tf.isEnabled = false
        tf.font = UIFont.systemFont(ofSize: 14)
        
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        tf.leftView = paddingView
        tf.leftViewMode = .always

        return tf
    }()
    
    private lazy var destinationLocationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter a destination.."
        tf.backgroundColor = .lightGray
        tf.returnKeyType = .search
        tf.font = UIFont.systemFont(ofSize: 14)
        
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        tf.leftView = paddingView
        tf.leftViewMode = .always
        return tf
    }()
    
    
    //MARK: - Liftcycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        
        addSubview(backButton)
        backButton.anchor(top: topAnchor, left: leftAnchor, paddingTop: 44, paddingLeft: 12,
                          width: 24, height: 25)
        
        addSubview(titleLabel)
        titleLabel.centerY(inView: backButton)
        titleLabel.centerX(inView: self)
        
        addSubview(startingLocationTextField)
        startingLocationTextField.anchor(
            top: backButton.bottomAnchor,
            left: leftAnchor, right: rightAnchor,
            paddingTop: 4,
            paddingLeft: 40,
            paddingRight: 40,
            height: 30)
        
        addSubview(destinationLocationTextField)
        destinationLocationTextField.anchor(
            top: startingLocationTextField.bottomAnchor,
            left: leftAnchor, right: rightAnchor,
            paddingTop: 12,
            paddingLeft: 40,
            paddingRight: 40,
            height: 30)
        
        addSubview(startLocationIndicatorView)
        startLocationIndicatorView.centerY(inView: startingLocationTextField,
                                           leftAnchor: leftAnchor, paddingLeft: 20)
        startLocationIndicatorView.setDimensions(height: 6, width: 6)
        startLocationIndicatorView.layer.cornerRadius = 6 / 2
        
        
        addSubview(destinationLocationIndicatorView)
        destinationLocationIndicatorView.centerY(inView: destinationLocationTextField,
                                           leftAnchor: leftAnchor, paddingLeft: 20)
        destinationLocationIndicatorView.setDimensions(height: 6, width: 6)
        
        addSubview(linkingView)
        linkingView.centerX(inView: startLocationIndicatorView)
        linkingView.anchor(top: startLocationIndicatorView.bottomAnchor,
                           bottom: destinationLocationIndicatorView.topAnchor,
                           paddingTop: 4,
                           paddingBottom: 4,
                           width: 0.5)
        
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Actions
    
    @objc func handleBackTapped() {
        delegate?.dismissLocationInputView()
    }
    
    
    
    

}
