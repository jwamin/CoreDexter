//
//  CaptureButton.swift
//  PokeCamera
//
//  Created by Joss Manger on 4/9/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit

class CaptureButton: UIButton {
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    let captureButtonDimension:CGFloat = 60
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    convenience init() {
        self.init(frame:.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp(){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 3
        self.layer.cornerRadius = captureButtonDimension / 2
        self.backgroundColor = UIColor.clear
    }
    
    override var isHighlighted: Bool{
        didSet {
            backgroundColor = isHighlighted ? UIColor.white : UIColor.clear
        }
    }

}
