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
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var font:UIFont!
    
    var pokemonData:PokemonViewStruct?
    
    var nameLabel:UILabel!
    var numberLabel:UILabel!
    
    var detailStackView:UIStackView!
    
    @IBOutlet var layerColor:UIColor!
    
    var player:AVPlayer!
    var imageview:UIImageView!
    
    var viewIsSetup:Bool = false
    
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
       
        print("view did load")
        
    
       
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
                print("cry is ready")
                return
            case AVPlayerItem.Status.failed:
                print("couldn't get cry")
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
    };
    
    func setupView(){
        
        if viewIsSetup {
            return;
        }
        
        print("instantiating video player")
        
        let activity = UIActivityIndicatorView(style: .gray)
        activity.hidesWhenStopped = true
        activity.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activity)
        
        let myurl = URL(string: criesBaseUrl+self.title!.lowercased().replacingOccurrences(of: "-", with: "")+criesUrlSuffix)!
        player = AVPlayer(url: myurl)
        player.actionAtItemEnd = .pause
        
        player.currentItem!.addObserver(self, forKeyPath: "status", options: [], context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resetPlayer(_:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        
        
        self.font = MasterViewController.font
        
        numberLabel = UILabel()
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.text = "001"
        numberLabel.font = font
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Bulbasaur"
        nameLabel.font = font
        
        detailStackView = UIStackView()
        detailStackView.translatesAutoresizingMaskIntoConstraints = false
        detailStackView.axis = .vertical
        
        detailStackView.addArrangedSubview(numberLabel)
        detailStackView.addArrangedSubview(nameLabel)
        
        contentView.addSubview(detailStackView)
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.font = UIFontMetrics(forTextStyle: UIFont.TextStyle.body).scaledFont(for: font)
        
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
        viewIsSetup = true
        
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
        print("view will appear")
        if let _ = self.img{
            setupView()
            guard let pokemonData = self.pokemonData else{
                return
            }
            //refactor to function
            numberLabel.text = pokemonData.idString
            nameLabel.text = pokemonData.name
            descriptionLabel.text = pokemonData.description
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player)
    }

    
    override func viewSafeAreaInsetsDidChange() {

        super.viewSafeAreaInsetsDidChange()
        if let _ = self.img{
            layoutConstraints()
        }

    }

//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        layoutConstraints()
//    }

    
    private func updateRadius(){
        guard let container = imageview.superview else {
            return
        }
        
        container.layer.cornerRadius = container.bounds.width / 2
        return
        
    }
    
    
    private func layoutConstraints(){
        
        guard let imageContainer = imageview.superview else {
            return
        }
        
        if (!constraints.isEmpty){
            print("regenerating constraints")
            NSLayoutConstraint.deactivate(constraints)
            constraints.removeAll()
        } else {
            print("generating constraints for the first time")
        }
        
        let views:[String:UIView] = ["imgcontainer":imageContainer,"imgview":imageview,"label":descriptionLabel,"contentView":contentView,"stackView":detailStackView]
        
        //Content Hugging Priority - The higher this priority is, the more a view resists growing larger than its intrinsic content size.
        //Content Compression Resistance Priority - The higher this priority is, the more a view resists shrinking smaller than its intrinsic content size.
        
        imageContainer.setContentHuggingPriority(UILayoutPriority(rawValue: 750), for: .horizontal)
        imageContainer.setContentHuggingPriority(UILayoutPriority(rawValue: 750), for: .vertical)
        
        imageview.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 250), for: .vertical)
        imageview.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 250), for: .horizontal)
        
        //imgcontainer height and width
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[imgcontainer(<=300)]", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[imgcontainer(>=150)]", options: [], metrics: nil, views: views)
        
        //fix img container to the top of the safe area with standard spacing
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[imgcontainer]", options: [], metrics: nil, views: views)
        
        //imageview inside the uiview - costrain to match container
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imgview]-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[imgview]-|", options: [], metrics: nil, views: views)
        
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imgcontainer]-[stackView]-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[stackView]", options: [], metrics: nil, views: views)

 
        
        //constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[stackView]", options: [], metrics: nil, views: views)
        
        //constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[label(100@20)]", options: [], metrics: nil, views: views)
        

        
        //stackView
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label(>=stackView)]-|", options: [], metrics: nil, views: views)

        
        //let centerYConstraint = NSLayoutConstraint(item: descriptionLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0)
        //centerYConstraint.priority = UILayoutPriority(rawValue: 750)
        
        constraints += [
            
            /*NSLayoutConstraint(item: imageContainer, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0),*/
            NSLayoutConstraint(item: imageContainer, attribute: .height, relatedBy: .equal, toItem: imageContainer, attribute: .width, multiplier: 1.0, constant: 0)//,
            //centerYConstraint,
            
            //NSLayoutConstraint(item: detailDescriptionLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0),
            
            //imageContainer.topAnchor.constraint(equalTo: contentView.topAnchor)//,
            //imageContainer.bottomAnchor.constraint(equalTo: detailDescriptionLabel.topAnchor)
            
        ]
        
        NSLayoutConstraint.activate(constraints)
        view.layoutIfNeeded()
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
        
        
        if let label = descriptionLabel {
            
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
