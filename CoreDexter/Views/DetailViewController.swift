//
//  DetailViewController.swift
//  CoreDexter
//
//  Created by Joss Manger on 1/30/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit
import PokeAPIKit
import AVFoundation

class DetailViewController: UIViewController {
    
    //MARK: Instance Variable
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var font:UIFont!
    
    var pokemonData:PokemonViewStruct?
    
    var genusLabel:UILabel!
    var numberLabel:UILabel!
    
    var detailStackView:UIStackView!
    
    var imageview:UIImageView!
    var closeButton:UIButton!
    var viewIsSetup:Bool = false
    
    var player:AVPlayer!
    
    var constraints:[NSLayoutConstraint] = []
    var centeriseConstraints:[NSLayoutConstraint] = []
    var closeButtonBottomConstraint:NSLayoutConstraint!
    
    private var animating = true
    private var expandedViewActive = false
    
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
    
    //MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        print("view did load",self.description)
       
    }
    
    override func viewDidLayoutSubviews() {
        setupView()
        setData()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        
        super.viewSafeAreaInsetsDidChange()
        if viewIsSetup {
            layoutConstraints()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player)
    }
    
    deinit {
        //this runs on a new "prepareForSegue"
        print("deinitialised detail view")
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
    
    //MARK: View Setup
    //Takes over from basic views created in IB
    func setupView(){
        
        if viewIsSetup || pokemonData == nil {
            return;
        }
        
        viewIsSetup = true
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
        
        self.font = MasterViewController.lightFont
        
        numberLabel = UILabel()
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.numberOfLines = 0
        numberLabel.text = "001"
        numberLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        
        genusLabel = UILabel()
        genusLabel.translatesAutoresizingMaskIntoConstraints = false
        genusLabel.text = "Seed Pokémon"
        genusLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        
        detailStackView = UIStackView()
        detailStackView.spacing = 8.0
        detailStackView.translatesAutoresizingMaskIntoConstraints = false
        detailStackView.axis = .vertical
        
        detailStackView.addArrangedSubview(numberLabel)
        detailStackView.addArrangedSubview(genusLabel)
        
        let type1Label = ElementLabel()
        let type2Label = ElementLabel()
        
        type1Label.typeString = pokemonData?.type1
        type2Label.typeString = pokemonData?.type2
        
        detailStackView.addArrangedSubview(type1Label)
        detailStackView.addArrangedSubview(type2Label)
        
        let generationLabel = UILabel()
        generationLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        generationLabel.text = pokemonData?.generation
        detailStackView.addArrangedSubview(generationLabel)
        
        let regionLabel = UILabel()
        regionLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        regionLabel.text = pokemonData?.region
        detailStackView.addArrangedSubview(regionLabel)
        
        contentView.addSubview(detailStackView)
        
        
        //Position description label
        guard let descriptionLabel = self.descriptionLabel else {
            return
        }
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.removeFromSuperview()
        descriptionLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        
        
        //Image container view
        let sharedFrame = CGRect(origin: .zero, size: CGSize(width: 300, height: 300))
        let imgcontainer = UIView(frame: sharedFrame)
        imgcontainer.translatesAutoresizingMaskIntoConstraints = false
        imgcontainer.isUserInteractionEnabled = true
        imageview = UIImageView(frame: sharedFrame)
        imageview.translatesAutoresizingMaskIntoConstraints = false
        
        imgcontainer.addSubview(imageview)
        
        
        contentView.addSubview(imgcontainer)
        contentView.addSubview(descriptionLabel)
        
        setImage()
        configureView()
        
        //set border aand background color of container
        imgcontainer.layer.backgroundColor = UIColor.squirtleBlue.cgColor
        imgcontainer.layer.borderColor = UIColor.black.cgColor
        
        //borderwidth composites above the layer contents... interesting
        imgcontainer.layer.borderWidth = 5.0
        imgcontainer.layer.zPosition = -1
        imgcontainer.layer.masksToBounds = true
        imageview.layer.zPosition = 2
        
        //Add Gesture recognisers for tap of image
        let gesture = UITapGestureRecognizer(target: self, action: #selector(imageTap(_:)))
        imageview.isUserInteractionEnabled = true
        imageview.addGestureRecognizer(gesture)
        
        let imageLayoutGuide = UILayoutGuide()
        imgcontainer.addLayoutGuide(imageLayoutGuide)
        
        let closeButtonLayoutGuide = UILayoutGuide()
        
        closeButton = UIButton(type: .custom)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("-", for: .normal)
        
        //tweak display layer
        closeButton.layer.cornerRadius = 22
        closeButton.layer.borderWidth = 5.0
        closeButton.layer.borderColor = UIColor.black.cgColor
        closeButton.layer.zPosition = 2
        
        closeButton.backgroundColor = UIColor.bulbasaurGreen
        closeButton.setTitleColor(UIColor.black, for: .normal)
        closeButton.titleLabel?.font = MasterViewController.font.withSize(14)
        closeButton.clipsToBounds = false
        closeButton.addTarget(self, action: #selector(imageTap(_:)), for: .touchUpInside)
        view.addSubview(closeButton)
        
        closeButton.addLayoutGuide(closeButtonLayoutGuide)
        
        layoutConstraints()
        
        
    }
    
    //MARK: @objc target actions
    
    @objc func imageTap(_ sender:Any){
        
        if(sender is UITapGestureRecognizer){
            let gr = sender as! UITapGestureRecognizer
            if(gr.state != .ended){
                print("!ended")
                return
            }
            if(!expandedViewActive){
                layoutInPopoverConfiguration()
            } else {
                tapGrowlAnimation()
            }
        } else if (sender is UIButton){
            layoutInPopoverConfiguration()
        }
        
    }
    
    @objc
    func resetPlayer(_ notification:NSNotification){
        print("did end playing")
        self.player.seek(to: .zero)
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
        
        let views:[String:Any] = ["imgcontainer":imageContainer,"imgview":imageview,"label":descriptionLabel,"contentView":contentView,"stackView":detailStackView,"button":closeButton,
                                  "ilayoutguide":imageContainer.layoutGuides.first!,"blayoutguide":closeButton.layoutGuides.first!]
        
 
        //fix img container to the top of the safe area with standard spacing
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-8@500-[imgcontainer]", options: [], metrics: nil, views: views)
        
        //imageview inside the uiview - costrain to match container
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imgview]-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[imgview]-|", options: [], metrics: nil, views: views)
        
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-8@500-[imgcontainer]-[stackView]-8@250-|", options: [], metrics: nil, views: views)
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[stackView]", options: [], metrics: nil, views: views)

        //closeButton
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[button(==44)]", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[button(==44)]", options: [], metrics: nil, views: views)
        
        
        closeButtonBottomConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo:closeButton.bottomAnchor, constant: -100)
        closeButtonBottomConstraint.priority = UILayoutPriority(100)
        constraints += [
            
        closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        closeButtonBottomConstraint
        ]
        
        //stackView
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[stackView]->=8@250-[label]", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[imgcontainer]-8@251-[label]-0@250-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-8@751-[label]-8@751-|", options: [], metrics: nil, views: views)
     
        constraints += [
            
            NSLayoutConstraint(item: imageContainer, attribute: .height, relatedBy: .equal, toItem: imageContainer, attribute: .width, multiplier: 1.0, constant: 0)//,

            
        ]
        
        NSLayoutConstraint.activate(constraints)
        view.layoutIfNeeded()
         updateRadius()
    }
    
    
    func layoutInPopoverConfiguration(){
        
        guard let container = imageview.superview else {
            return
        }
        
        if(centeriseConstraints.isEmpty){
            let views:[String:Any] = ["imgcontainer":container,"imgview":imageview,"label":descriptionLabel,"contentView":contentView,"stackView":detailStackView,"button":closeButton,"ilayoutguide":container.layoutGuides.first!,"blayoutguide":closeButton.layoutGuides.first!]
            let layoutGuides = view.safeAreaLayoutGuide
            let widthConstraint =  min(self.view.frame.height, self.view.frame.width)
            print(widthConstraint)
            let imageContainer = container
            let vXConstraint = imageContainer.centerXAnchor.constraint(equalTo: layoutGuides.centerXAnchor)
            let vYConstraint = imageContainer.centerYAnchor.constraint(equalTo: layoutGuides.centerYAnchor)
            let arConstraint = imageContainer.heightAnchor.constraint(equalTo: imageContainer.widthAnchor)
//            arConstraint.priority = UILayoutPriority(rawValue: 999)
            
            let metrics = ["maxDimension":widthConstraint]
            print(widthConstraint)
            vYConstraint.priority = UILayoutPriority(rawValue: 1000)
            centeriseConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|->=8@500-[imgcontainer(<=maxDimension)]", options: [], metrics: metrics, views: views)
            centeriseConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|->=8@500-[imgcontainer(<=maxDimension)]", options: [], metrics: metrics, views: views)
            
            centeriseConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[imgcontainer][ilayoutguide(==blayoutguide)][button(==44)][blayoutguide]|", options: [], metrics: nil, views: views)
            centeriseConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[button(==44)]->=20@1000-|", options: [], metrics: nil, views: views)
            centeriseConstraints += [vXConstraint,vYConstraint,arConstraint]
        }
        
        
        
        
        
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 5, initialSpringVelocity: 10, options: [], animations: { [weak self] in
            if(!self!.expandedViewActive){
                NSLayoutConstraint.activate(self!.centeriseConstraints)
                self!.descriptionLabel.alpha = 0.0
                self!.closeButtonBottomConstraint.constant = 0
            } else {
                NSLayoutConstraint.deactivate(self!.centeriseConstraints)
                self!.descriptionLabel.alpha = 1.0
                self!.closeButtonBottomConstraint.constant = -100
            }
            
            self!.view.layoutIfNeeded()
            self!.updateRadius()
        }) { [weak self] (complete) in
            if(complete){
                self!.expandedViewActive = !self!.expandedViewActive
            }
        }
    }
    
    
    
    

    

    

    
    //MARK: View Setup
    
    private func configureView() {
        // Update the user interface for the detail item.
        
        
        if let label = descriptionLabel {
            
            label.text = labelText
        } else {
            return
        }
        
        
    }
    
    func setData(){
        
        guard let pokemonData = self.pokemonData else{
            return
        }
        
        numberLabel.text = "National:\(pokemonData.idString)\nRegional:\(pokemonData.regionId)"
        genusLabel.text = pokemonData.genus
        descriptionLabel.text = pokemonData.description
        
    }
    
    private func setImage(){
        guard let imageview = self.imageview, let img = self.img else {
            return
        }
        imageview.image = img
    }
    
    //MARK: Animation
    
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
