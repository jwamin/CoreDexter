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
            setImage()
        }
    }
    
    var detailItem: Pokemon? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    //Actions
    @objc func tap(_ sender:UITapGestureRecognizer){
        

        if(sender.state != .ended){
            print("!ended")
            return
        }
        
       tapAnimation()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        configureView()
    }
    
    private func configureView() {
        // Update the user interface for the detail item.
        
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.numberOfLines = 0
                label.textAlignment = .center
                print(detail)
                let id = Int(detail.id).digitString()
                let regionId = Int(detail.region_id).digitString()
                label.text = "\(detail.name ?? "")\nNational Index:\(id)\nRegional Index:\(regionId)\n\(detail.generation ?? "")\n\(detail.region!.name ?? "")\n\(detail.type1 ?? "")\n\(detail.initialDesc ?? "")"//detail.timestamp!.description
            } else {
                return
            }
        } else {
            return
        }
        
        
        imageview = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 300, height: 300)))
        imageview.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageview)
        setImage()
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
    
    private func setImage(){
        guard let imageview = self.imageview, let img = self.img else {
            return
        }
        imageview.image = img
    }
    
    private func tapAnimation(){
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
        
        let animationGroup = CAAnimationGroup()
        
        //tap animation
        let keyframeAnimation = CAKeyframeAnimation(keyPath: "transform")
        
        keyframeAnimation.values = [
            CATransform3DMakeAffineTransform(CGAffineTransform(scaleX: 1, y: 1)),
            CATransform3DMakeAffineTransform(CGAffineTransform(scaleX: 0.6, y: 0.6)),
            CATransform3DMakeAffineTransform(CGAffineTransform(scaleX: 1.3, y: 1.3))
        ]
        
        keyframeAnimation.keyTimes = [0,0.2,0.8]
        keyframeAnimation.duration = 0.5
        keyframeAnimation.fillMode =  .forwards
        
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        let bezier = UIBezierPath()
        
        let start = imageview.layer.position
        let end = CGPoint(x: imageview.layer.position.x, y: imageview.layer.position.y+50.0)
        bezier.move(to: imageview.layer.position)
        
        // Calculate the control points
        let c1 = CGPoint(x: start.x , y: start.y)
        let c2 = CGPoint(x: end.x, y: end.y - 128)
        
        bezier.addCurve(to: end, controlPoint1: c1, controlPoint2: c2)
        
        pathAnimation.path = bezier.cgPath
        pathAnimation.fillMode = .forwards
        pathAnimation.isRemovedOnCompletion = false
        pathAnimation.duration = 0.5
        pathAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        
        let basicAnimation = CABasicAnimation(keyPath: "position")
        basicAnimation.fromValue = end
        basicAnimation.toValue = start
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = true
        basicAnimation.beginTime = 0.5;
        basicAnimation.duration = 0.25;
        
        let scaleBasicAnimation = CABasicAnimation(keyPath: "transform")
        scaleBasicAnimation.fromValue = CATransform3DMakeAffineTransform(CGAffineTransform(scaleX: 1.3, y: 1.3))
        scaleBasicAnimation.toValue = CATransform3DMakeAffineTransform(CGAffineTransform(scaleX: 1, y: 1))
        scaleBasicAnimation.fillMode = .forwards
        scaleBasicAnimation.isRemovedOnCompletion = true
        scaleBasicAnimation.beginTime = 0.5;
        scaleBasicAnimation.duration = 0.25;
        
        animationGroup.animations = [keyframeAnimation,pathAnimation,basicAnimation,scaleBasicAnimation]
        animationGroup.duration = 0.75
        animationGroup.fillMode = .forwards
        
        //add animation
        imageview.layer.add(animationGroup, forKey: "animation")
        
        //commit animation
        CATransaction.commit()
    }
    
    func getImage(){
        if let detail = detailItem, let sprite = detail.front_sprite{
            self.imageview.image = UIImage(data: sprite)
        }
        
    }

}

