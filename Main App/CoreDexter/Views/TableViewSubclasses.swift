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
    @IBOutlet weak var favBadge: UIImageView!
    
    weak var layoutGuide:UILayoutGuide?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        imgview.layer.borderWidth = 1.0
        imgview.layer.borderColor = UIColor.black.cgColor
        
        favBadge.backgroundColor = .clear
        favBadge.tintColor = .pikachuYellow
        

                mainLabel.numberOfLines = 0
        mainLabel.lineBreakMode = .byWordWrapping
        
        mainLabel.font = headingFont()
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

    func setFavourite(isFavourite:Bool){
     
        favBadge.image = (isFavourite) ? UIImage(named:"fav-fill") : nil
    }
    
    override func prepareForReuse() {
        self.imgview.image = nil
        self.mainLabel.text = nil
        setFavourite(isFavourite: false)
        super.prepareForReuse()
    }
    
}

class FontedHeaderView : UITableViewHeaderFooterView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel?.font = headingFont()
    }
}
