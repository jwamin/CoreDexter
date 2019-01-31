//
//  DetailViewController.swift
//  CoreDexter
//
//  Created by Joss Manger on 1/30/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    var imageview:UIImageView!
    
    var img:UIImage?{
        didSet{
            print("set image")
            imageview.image = img!
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.numberOfLines = 0
                label.text = "\(detail.name) \n \(detail.id) \n \(detail.generation) \n \(detail.region!.name) \n \(detail.type1) \n \(detail.initialDesc)"//detail.timestamp!.description
            } else {
                return
            }
        } else {
            return
        }
        
        imageview = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 300, height: 300)))
        imageview.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(imageview)
        
        let views:[String:UIView] = ["imageview":imageview,"label":detailDescriptionLabel]
        
        var constraints = [NSLayoutConstraint]()
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[imageview(==300)]", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[imageview]-[label]", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint(item: imageview, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: imageview, attribute: .height, relatedBy: .equal, toItem: imageview, attribute: .width, multiplier: 1.0, constant: 0).isActive = true
        
        NSLayoutConstraint.activate(constraints)
        
        
    
        

    }

    
    override func viewWillAppear(_ animated: Bool) {
        getImage()
    }
    
    private func getImage(){
        
        DispatchQueue.global().async {
            
       
        
        guard let detail = self.detailItem else {
            return
        }
        guard let url = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/"+String(detail.id)+".png") else {
            return
        }
        URLSession.shared.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            if (error != nil){
                print("err")
                return
            }
            
            guard let data = data else {
                return
            }
            
            DispatchQueue.main.async {
                print("distpatching main")
                self.img = UIImage(data: data)
            }
            
            
            
        }).resume()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        configureView()
    }

    var detailItem: Pokemon? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

