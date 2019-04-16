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
class ElementLabel : UILabel {
    
    let textInsets = UIEdgeInsets(top: 5,
                                  left: 10,
                                  bottom: 5,
                                  right: 10)
    
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
            self.textColor = colors.textColor
            self.font = MasterViewController.bodyFont
            self.text = element.rawValue.capitalized
            self.clipsToBounds = true
            self.isHidden = false
            self.alpha = 1.0
            self.layoutIfNeeded()
            fixupCorner()
        }
    }


    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return textRect.inset(by: invertedInsets)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
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
