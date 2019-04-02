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
        
        
        guard let font = UIFont(name: "MajorMonoDisplay-Regular", size: UIFont.labelFontSize) else {
            fatalError()
        }
        print(imgview.bounds)
        imgview.layer.borderWidth = 1.0
        imgview.layer.borderColor = UIColor.black.cgColor
        
        mainLabel.numberOfLines = 0
        mainLabel.lineBreakMode = .byWordWrapping
        
        mainLabel.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: font)
        mainLabel.adjustsFontForContentSizeCategory = true
    }
    
    override func safeAreaInsetsDidChange() {
        print("safe area insets changed!")
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imgview.layer.cornerRadius = self.imgview.bounds.height / 2
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


class ElementLabel : UILabel {
    var typeString:String?{
        didSet{
            if let validString = typeString{
                element = ElementalType(rawValue: validString)
                return
            }
            self.text = ""
            self.isHidden = true
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
            self.text = element.rawValue
            self.sizeToFit()
            self.isHidden = false
        }
    }
    
}
