//
//  PokeCellTableViewCell.swift
//  CoreDexter
//
//  Created by Joss Manger on 2/4/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit
import PokeAPIKit

class PokeCellTableViewCell: UITableViewCell {

    @IBOutlet weak var imgview: UIImageView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var type1Label: ElementLabel!
    @IBOutlet weak var type2Label: ElementLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
        print(imgview.bounds)
        imgview.layer.borderWidth = 1.0
        imgview.layer.borderColor = UIColor.black.cgColor
        
        mainLabel.numberOfLines = 0
        mainLabel.lineBreakMode = .byWordWrapping
        
        mainLabel.font = MasterViewController.headingFont
        mainLabel.adjustsFontForContentSizeCategory = true
    }
    
    func updateCircle(){
        self.imgview.layer.cornerRadius = self.imgview.bounds.height / 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCircle()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        self.imgview.image = nil
        self.mainLabel.text = nil
        super.prepareForReuse()
    }
    
}

@IBDesignable
class ElementLabel : UIView {
    
    let label = UILabel()
    private var myConstraints: [NSLayoutConstraint]?
    
    var text:String?{
        didSet{
            self.label.text = text
        }
    }
    
    init(){
        super.init(frame: .zero)
        setupLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        print("awake")
        setupLabel()
    }
    
    func setupLabel(){
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        self.layoutMargins = ElementLabel.standardTextinset
        self.addSubview(label)
    }
    
    override func updateConstraints() {
        print("update constraints")
        if myConstraints == nil{
            var constraints = [NSLayoutConstraint]()
            let layoutGuide = self.layoutMarginsGuide
            let views = ["label":label]
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "|-0-[label]-0-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[label]-0-|", options: [], metrics: nil, views: views)
            myConstraints = constraints
            NSLayoutConstraint.activate(constraints)
        }
        super.updateConstraints()
    }
    
    static let standardTextinset = UIEdgeInsets(top: 5,
                                                left: 10,
                                                bottom: 5,
                                                right: 10)
    
    var textInsets = ElementLabel.standardTextinset {
        didSet{
            invalidateIntrinsicContentSize()
        }
    }
    
    var typeString:String?{
        didSet{
            if let validString = typeString{
                element = ElementalType(rawValue: validString)
                return
            }
            self.text = "None"
            self.alpha = 0.0
            self.layoutIfNeeded()
        }
    }
    private var element:ElementalType?{
        didSet{
            guard let element = element else {
                return
            }
            let colors = element.getColors()
            self.backgroundColor = colors.backgroundColor
            self.label.textColor = colors.textColor
            self.label.font = MasterViewController.bodyFont
            self.text = element.rawValue.capitalized
            self.clipsToBounds = true
            self.isHidden = false
            self.alpha = 1.0
            self.layoutIfNeeded()
            fixupCorner()
        }
    }
    
    override func prepareForInterfaceBuilder() {
        //invalidateIntrinsicContentSize()
        fixupCorner()
        self.element = .dragon
    }
    
    private func fixupCorner(){
        //sizeToFit()
        self.layer.cornerRadius = self.bounds.height / 2
        
    }
    
}


class FontedHeaderView : UITableViewHeaderFooterView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel?.font = MasterViewController.headingFont
    }
}
