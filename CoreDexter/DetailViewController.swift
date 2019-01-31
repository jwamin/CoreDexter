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
    
    private var animating = false
    
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
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[imageview(<=300)]", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[imageview]-[label]", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint(item: imageview, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        imageview.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        NSLayoutConstraint(item: imageview, attribute: .height, relatedBy: .equal, toItem: imageview, attribute: .width, multiplier: 1.0, constant: 0).isActive = true
        
        NSLayoutConstraint.activate(constraints)
        
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
         imageview.isUserInteractionEnabled = true
        imageview.addGestureRecognizer(gesture)
        

    }

    @objc func tap(_ sender:UITapGestureRecognizer){
        

        if(sender.state != .ended){
            print("ended")
            return
        }
        
        if(animating){
            return
        } else {
            print("will anim")
            animating = true
        }
        
        guard let imageview = imageview else {
            return
        }
        
        //configure transations
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setCompletionBlock {
            self.animating = false
        }
        
        //tap animation
        let keyframeAnimation = CAKeyframeAnimation(keyPath: "transform")
        
        keyframeAnimation.values = [
            CATransform3DMakeAffineTransform(CGAffineTransform.identity),
            CATransform3DMakeAffineTransform(CGAffineTransform(scaleX: 0.8, y: 0.8)),
            CATransform3DMakeAffineTransform(CGAffineTransform(scaleX: 1.2, y: 1.2).concatenating(CGAffineTransform(translationX: 0, y: 20))),
            CATransform3DMakeAffineTransform(CGAffineTransform.identity)
        ]
        
        keyframeAnimation.keyTimes = [0,0.2,0.8,1]
        keyframeAnimation.duration = 0.5
        
        //add animation
        imageview.layer.add(keyframeAnimation, forKey: "animation")

        //commit animation
        CATransaction.commit()
        
        
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

