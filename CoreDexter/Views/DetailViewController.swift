//
//  DetailViewController.swift
//  CoreDexter
//
//  Created by Joss Manger on 1/30/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit
import AVFoundation

class DetailViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    @IBOutlet var layerColor:UIColor!
    
    var player:AVPlayer!
    var imageview:UIImageView!
    
    var constraints:[NSLayoutConstraint] = []
    
    private var animating = true
    
    var img:UIImage?{
        didSet{
            setImage()
        }
    }
    
    
    var labelText:String = ""{
        didSet{
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("vdl, instantiating video player")
        
        let activity = UIActivityIndicatorView(style: .gray)
        activity.hidesWhenStopped = true
        activity.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activity)
        
        let myurl = URL(string: criesBaseUrl+self.title!.lowercased().replacingOccurrences(of: "-", with: "")+criesUrlSuffix)!
        player = AVPlayer(url: myurl)
        player.actionAtItemEnd = .pause
        
        player.currentItem!.addObserver(self, forKeyPath: "status", options: [], context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resetPlayer(_:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        detailDescriptionLabel.numberOfLines = 0
        detailDescriptionLabel.textAlignment = .center
        detailDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let sharedFrame = CGRect(origin: .zero, size: CGSize(width: 300, height: 300))
        
        let imgcontainer = UIView(frame: sharedFrame)
        imgcontainer.translatesAutoresizingMaskIntoConstraints = false
        imgcontainer.isUserInteractionEnabled = true
        imageview = UIImageView(frame: sharedFrame)
        
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imgcontainer.addSubview(imageview)
        contentView.addSubview(imgcontainer)
        setImage()
        configureView()
        imgcontainer.layer.backgroundColor = layerColor.cgColor
        imgcontainer.layer.borderColor = UIColor.black.cgColor
        
        //borderwidth composites above the layer contents... interesting
        imgcontainer.layer.borderWidth = 5.0
        imgcontainer.layer.zPosition = -1
        imgcontainer.layer.masksToBounds = true
        imageview.layer.zPosition = 2
        
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        imageview.isUserInteractionEnabled = true
        imageview.addGestureRecognizer(gesture)
        
        
        
        layoutConstraints()
        
        
       
    }
    
    //MARK: KVO for AVPlayer Item ready state
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if(object is AVPlayerItem && keyPath == "status"){
            let item = object as! AVPlayerItem
            switch(item.status){
            case AVPlayerItem.Status.readyToPlay:
                animating = false
                (navigationItem.rightBarButtonItem?.customView as! UIActivityIndicatorView).stopAnimating()
                item.removeObserver(self, forKeyPath: "status")
                print("ready?")
                return
            case AVPlayerItem.Status.failed:
                print("fail?")
                let label = UILabel()
                label.numberOfLines = 1
                label.text = "❌"
                label.isUserInteractionEnabled = true
                let tapper = UITapGestureRecognizer(target: self, action: #selector(errorTap))
                label.addGestureRecognizer(tapper)
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: label)
                animating = false
                item.removeObserver(self, forKeyPath: "status")
                return
            default:
                print("something else happeend",player.status)
                return
            }
            
            
        }
    }
    
    @objc
    func errorTap(){
        print("error tap")
        if(player.currentItem?.status == .failed){
            let alert = UIAlertController(title: "Unable to load cry for \(self.title!)", message: "Please connect to the internet and try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(imageview.frame)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player)
    }

    
    override func viewSafeAreaInsetsDidChange() {

        super.viewSafeAreaInsetsDidChange()
        layoutConstraints()

    }


    
    private func updateRadius(){
        guard let container = imageview.superview else {
            return
        }
        container.layoutIfNeeded()
        container.layer.cornerRadius = container.bounds.width / 2
        
        print("updated radius to \(container.layer.cornerRadius)")
    }
    
    
    private func layoutConstraints(){
        
        guard let container = imageview.superview else {
            return
        }
        
        if (!constraints.isEmpty){
            print("regenerating constraints")
            NSLayoutConstraint.deactivate(constraints)
            constraints.removeAll()
        } else {
            print("generating constraints for the first time")
        }
        
        let views:[String:UIView] = ["imgcontainer":container,"imgview":imageview,"label":detailDescriptionLabel,"contentView":contentView]
        
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[imgcontainer(<=300)]", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[label]-0-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[label(100@20)]", options: [], metrics: nil, views: views)
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[imgview]-0-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[imgview]-0-|", options: [], metrics: nil, views: views)
        
        constraints += [
            NSLayoutConstraint(item: container, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: container, attribute: .height, relatedBy: .equal, toItem: container, attribute: .width, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: detailDescriptionLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: detailDescriptionLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0),
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: detailDescriptionLabel.topAnchor)
            
        ]
        
        NSLayoutConstraint.activate(constraints)
         updateRadius()
    }
    
    //Actions
    @objc func tap(_ sender:UITapGestureRecognizer){
        
        
        if(sender.state != .ended){
            print("!ended")
            return
        }
        
        tapGrowlAnimation()
        
    }
    
    @objc
    func resetPlayer(_ notification:NSNotification){
        print("did end playing")
        self.player.seek(to: .zero)
    }
    

    
    private func configureView() {
        // Update the user interface for the detail item.
        
        
        if let label = detailDescriptionLabel {
            
            label.text = labelText
        } else {
            return
        }
        
        
    }
    
    private func setImage(){
        guard let imageview = self.imageview, let img = self.img else {
            return
        }
        imageview.image = img
    }
    
    private func tapGrowlAnimation(){
        
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
            //reset flag on completion
            self.animating = false
            imageview.layer.zPosition = 1
        }
        
        //group animations to run concurrently
        let animationGroup = CAAnimationGroup()
        
        //scale animation, shrink from fullsize and then grow to 1.3x
        let keyframeAnimation = CAKeyframeAnimation(keyPath: "transform")
        
        keyframeAnimation.values = [
            CATransform3DMakeAffineTransform(CGAffineTransform(scaleX: 1, y: 1)),
            CATransform3DMakeAffineTransform(CGAffineTransform(scaleX: 0.6, y: 0.6)),
            CATransform3DMakeAffineTransform(CGAffineTransform(scaleX: 1.3, y: 1.3))
        ]
        
        keyframeAnimation.keyTimes = [0,0.2,0.8]
        keyframeAnimation.duration = 0.5
        keyframeAnimation.fillMode =  .forwards
        
        //animation position on a bezier curve, position naturally curves so it looks more like a pounce!
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        let bezier = UIBezierPath()
        
        let start = imageview.layer.position
        let end = CGPoint(x: imageview.layer.position.x, y: imageview.layer.position.y+50.0)
        
        // Calculate the control points of the curve
        let c1 = CGPoint(x: start.x , y: start.y)
        let c2 = CGPoint(x: end.x, y: end.y - 128)
        
        bezier.move(to: start)
        bezier.addCurve(to: end, controlPoint1: c1, controlPoint2: c2)
        
        //add the curve to the path "position" animation
        pathAnimation.path = bezier.cgPath
        pathAnimation.fillMode = .forwards
        pathAnimation.isRemovedOnCompletion = false
        pathAnimation.duration = 0.5
        pathAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        //animate the translated layer back to the starting position
        let basicAnimation = CABasicAnimation(keyPath: "position")
        basicAnimation.fromValue = end
        basicAnimation.toValue = start
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = true
        basicAnimation.beginTime = 0.5;
        basicAnimation.duration = 0.25;
        
        //scale the layer back to 1
        let scaleBasicAnimation = CABasicAnimation(keyPath: "transform")
        scaleBasicAnimation.fromValue = CATransform3DMakeAffineTransform(CGAffineTransform(scaleX: 1.3, y: 1.3))
        scaleBasicAnimation.toValue = CATransform3DMakeAffineTransform(CGAffineTransform(scaleX: 1, y: 1))
        scaleBasicAnimation.fillMode = .forwards
        scaleBasicAnimation.isRemovedOnCompletion = true
        scaleBasicAnimation.beginTime = 0.5;
        scaleBasicAnimation.duration = 0.25;
        
        //add animations to group, use beginTime attribute to stagger starts
        animationGroup.animations = [keyframeAnimation,pathAnimation,basicAnimation,scaleBasicAnimation]
        animationGroup.duration = 0.75
        animationGroup.fillMode = .forwards
        
        imageview.layer.zPosition = 2
        //add animation to layer
        imageview.layer.add(animationGroup, forKey: "animation")
        
        //commit animation
        CATransaction.commit()
        
        //play player
        player.play()
    }
    
}

extension DetailViewController : UIScrollViewDelegate{
    
}
