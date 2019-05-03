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
        
        //HERE WE ARE BACK TO THE OLD QUESTION
        //LABELS IN THE TABLE VIEW MUST BREAK A CONSTRAINT IN ORDER TO BE EQUAL WIDTH
        //CONTAINER CAN'T TAKE THE INTRINSIC SIZE OF ITS LABEL IF IT IS FORCED BY STACKVIEW TO HAVE EQUAL WIDTH TO ITS SIBLING
        
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 999), for: .horizontal) // this one
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 999), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 999), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 999), for: .vertical)
        self.clipsToBounds = true
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
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "|-15@250-[label]-15@250-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-5@250-[label]-5@250-|", options: [], metrics: nil, views: views)
            
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

@IBDesignable
class RingImageView : UIView{
    
    var imageview:UIImageView!
    
    override init(frame: CGRect) {
        imageview = UIImageView()
        
        super.init(frame: frame)
        self.addSubview(imageview)
        //set border aand background color of container
        setupView()
        
    }
    
    func setupView(){
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.layer.zPosition = 2
        self.layer.backgroundColor = UIColor.squirtleBlue.cgColor
        self.layer.borderColor = UIColor.black.cgColor
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isUserInteractionEnabled = true
        //borderwidth composites above the layer contents... interesting
        self.layer.borderWidth = 5.0
        self.layer.zPosition = -1
        self.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func prepareForInterfaceBuilder() {
        imageview = UIImageView()
        self.addSubview(imageview)
        setupView()
        imageview.image = UIImage(named: "test")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.width / 2
    }
}


class ArrangedUILabel : UITextView{
    
    var animated = false
    
    override var contentSize: CGSize{
        didSet{
            centerAlign()
        }
    }
    
    private let leftRightInset:CGFloat = 50.0
    
    func centerAlign() {
        var topCorrect = (self.bounds.size.height - self.contentSize.height * self.zoomScale) / 2
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
        self.contentInset.top = topCorrect
        self.contentInset.left = leftRightInset
        self.contentInset.right = leftRightInset
    }
    
}
