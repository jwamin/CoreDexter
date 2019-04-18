//
//  Subclasses.swift
//  CoreDexter
//
//  Created by Joss Manger on 4/18/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit
import PokeAPIKit

@IBDesignable
class ElementLabel : UIView {
    
    let label = UILabel()
    private var myConstraints: [NSLayoutConstraint]?
    
    var typeString:String?{
        didSet{
            if let validString = typeString{
                element = ElementalType(rawValue: validString)
                return
            }
            self.label.text = "None"
            self.alpha = 0.0
            self.layoutIfNeeded()
        }
    }
    
    init(){
        super.init(frame: .zero)
        setupLabel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        setupLabel()
    }
    
    func setupLabel(){
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 999), for: .horizontal) // this one
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 999), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 999), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 999), for: .vertical)
        self.addSubview(label)
    }
    
    private var element:ElementalType?{
        didSet{
            guard let element = element else {
                return
            }
            let colors = element.getColors()
            self.backgroundColor = colors.backgroundColor
            self.label.textColor = colors.textColor
            self.label.font = bodyFont()
            self.label.text = element.rawValue.capitalized
            self.clipsToBounds = true
            self.isHidden = false
            self.alpha = 1.0
            self.sizeToFit()
            self.layoutIfNeeded()
            
        }
    }
    
    private func fixupCorner(){
        sizeToFit()
        self.layer.cornerRadius = self.bounds.height / 2
        
    }
    
    override func updateConstraints() {
    
        if myConstraints == nil{
            var constraints = [NSLayoutConstraint]()
            //let layoutGuide = self.layoutMarginsGuide
            let views = ["label":label]
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "|-15-[label]-15-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[label]-5-|", options: [], metrics: nil, views: views)
            
            constraints += [
                label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ]
            
            NSLayoutConstraint.fixPriorities(forConstraints: &constraints, withPriority: UILayoutPriority(999))
            
            myConstraints = constraints
            NSLayoutConstraint.activate(constraints)
        }
        super.updateConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fixupCorner()
    }
    
    override func prepareForInterfaceBuilder() {
        setupLabel()
        invalidateIntrinsicContentSize()
        //fixupCorner()
        self.element = .dragon
    }
    
}

class RingImageView : UIView{
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.width / 2
    }
}

