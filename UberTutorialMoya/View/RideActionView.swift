//
//  RideActionView.swift
//  UberTutorialMoya
//
//  Created by 김우성 on 2021/02/17.
//

import UIKit
import MapKit

protocol RideActionViewDelegate: class {
    func uploadTrip(_ view: RideActionView)
}

class RideActionView: UIView {

    //MARK: - Properties
    
    // "destination"의 값이 변경되면 "RideActionView"의 Label들의 text를 변경.
    var destination: MKPlacemark? {
        didSet {
            titleLabel.text = destination?.name
            addressLabel.text = destination?.address
        }
    }
    
    weak var delegate: RideActionViewDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.text = "Test Adress Title"
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "123 M St, NW Washington DC"
        return label
    }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        label.text = "X"
        
        view.addSubview(label)
        label.centerX(inView: view)
        label.centerY(inView: view)
        
        return view
    }()
    
    private let uberXLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.text = "Uber X"
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("CONFIRM UBERX", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.centerX(inView: self)
        stack.anchor(top: topAnchor, paddingTop: 12)
        
        addSubview(infoView)
        infoView.centerX(inView: self)
        infoView.anchor(top: stack.bottomAnchor, paddingTop: 16)
        infoView.setDimensions(height: 60, width: 60)
        infoView.layer.cornerRadius = 60 / 2
        
        addSubview(uberXLabel)
        uberXLabel.anchor(top: infoView.bottomAnchor, paddingTop: 8)
        uberXLabel.centerX(inView: self)
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = .lightGray
        addSubview(seperatorView)
        seperatorView.anchor(top: uberXLabel.bottomAnchor, left: leftAnchor,
                             right: rightAnchor, paddingTop: 4 ,height: 0.75)
        
        addSubview(actionButton)
        actionButton.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor,
                            paddingLeft: 12, paddingBottom: 12, paddingRight: 12,
                            height: 50)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    
    
    //MARK: - Selecteros
    
    @objc func actionButtonPressed() {
        delegate?.uploadTrip(self)
    }
}
