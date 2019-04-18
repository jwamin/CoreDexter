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
    
    var delegate:LoadingProtocol?
    
    let font:UIFont = headingFont()
    let bodyfont:UIFont = bodyFont()
    
    // no data, just view!
    var pokemonData:PokemonViewStruct?
    
    var genusLabel:UILabel!
    var numberLabel:UILabel!
    
    var typeLabelArray:[ElementLabel]!
    
    var generationLabel:UILabel!
    var regionLabel:UILabel!
    
    var mainStackView:UIStackView!
    var detailStackView:UIStackView!
    
    var imageview:UIImageView!
    var imageOuterContainer:UIView!
    
    var closeButton:UIButton!
    
    //Multimedia
    var player:AVPlayer!
    
    //constraint containers
    var constraints:[NSLayoutConstraint] = []
    var centeriseConstraints:[NSLayoutConstraint] = []
    var closeButtonBottomConstraint:NSLayoutConstraint!
    
    private var viewIsSetup:Bool = false
    private var animating = true
    private var expandedViewActive = false
    
    var img:UIImage?
    
    //MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font:font
        ]
        setupView()
        delegate?.loadingDone(self)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        
        super.viewSafeAreaInsetsDidChange()
        if viewIsSetup {
            //layoutConstraints()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player)
    }
    
    deinit {
        print("deinitialised detail view")
    }
    
    //MARK: View Data population
    
    public func configureView(pokemonData:PokemonViewStruct?) {
        // Update the user interface for the detail item.
        
        guard let data = pokemonData else {
            return
        }
        
        descriptionLabel.text = data.description
        imageview.image = img
        numberLabel.text = "National:\(data.idString)\nRegional:\(data.regionId)"
        
        typeLabelArray[0].typeString = data.type1
        typeLabelArray[1].typeString = data.type2
        
        generationLabel.text = data.generation.capitalized
        regionLabel.text = data.region.capitalized
        
        genusLabel.text = data.genus
        descriptionLabel.text = data.description //+ "\n\n" + lorem
        
    }
    
    private func setImage(){
        guard let imageview = self.imageview, let img = self.img else {
            return
        }
        imageview.image = img
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
        
        if viewIsSetup {
            return;
        }
        //view s
        viewIsSetup = true
        
        print("instantiating video player")
        
        let activity = UIActivityIndicatorView(style: .gray)
        activity.hidesWhenStopped = true
        activity.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activity)
        
        let myurl = URL(string: CRIES_BASE_URL+self.title!.lowercased().replacingOccurrences(of: "-", with: "")+CRIES_URL_SUFFIX)!
        player = AVPlayer(url: myurl)
        player.actionAtItemEnd = .pause
        
        player.currentItem!.addObserver(self, forKeyPath: "status", options: [], context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resetPlayer(_:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        numberLabel = UILabel()
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.numberOfLines = 0
        numberLabel.text = "001"
        numberLabel.font = bodyfont
        
        genusLabel = UILabel()
        genusLabel.translatesAutoresizingMaskIntoConstraints = false
        genusLabel.text = "Seed Pokémon"
        genusLabel.font = bodyfont
        
        detailStackView = UIStackView()
        detailStackView.spacing = 8.0
        detailStackView.translatesAutoresizingMaskIntoConstraints = false
        detailStackView.axis = .vertical
        detailStackView.alignment = .top
        detailStackView.distribution = .equalSpacing
        
        detailStackView.addArrangedSubview(numberLabel)
        detailStackView.addArrangedSubview(genusLabel)
        
        let type1Label = ElementLabel()
        let type2Label = ElementLabel()
        
        type1Label.typeString = pokemonData?.type1
        type2Label.typeString = pokemonData?.type2
        
        typeLabelArray = [type1Label,type2Label]
        
        detailStackView.addArrangedSubview(type1Label)
        detailStackView.addArrangedSubview(type2Label)
        
        generationLabel = UILabel()
        generationLabel.translatesAutoresizingMaskIntoConstraints = false
        generationLabel.font = bodyfont
        generationLabel.text = pokemonData?.generation
        detailStackView.addArrangedSubview(generationLabel)
        
        regionLabel = UILabel()
        regionLabel.translatesAutoresizingMaskIntoConstraints = false
        regionLabel.font = bodyfont
        regionLabel.text = pokemonData?.region
        detailStackView.addArrangedSubview(regionLabel)
        
        //Position description label
        guard let descriptionLabel = self.descriptionLabel else {
            viewIsSetup = false
            return
        }
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.removeFromSuperview()
        descriptionLabel.font = bodyfont
        
        let horizontalDetail = UIStackView()
        horizontalDetail.translatesAutoresizingMaskIntoConstraints = false
        horizontalDetail.axis = .horizontal
        horizontalDetail.alignment = .fill
        horizontalDetail.spacing = 8
        horizontalDetail.backgroundColor = UIColor.red
        
        let mainVerticalStack = UIStackView()
        mainVerticalStack.translatesAutoresizingMaskIntoConstraints = false
        mainVerticalStack.spacing = 8
        mainVerticalStack.axis = .vertical
        mainVerticalStack.distribution = .fill
        mainVerticalStack.alignment = .top
        mainVerticalStack.backgroundColor = .blue
    
        
        //Image container view
        imageOuterContainer = UIView()
        imageOuterContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let imgcontainer = RingImageView()
        imgcontainer.translatesAutoresizingMaskIntoConstraints = false
        imgcontainer.isUserInteractionEnabled = true
        imageview = UIImageView()
        imageview.translatesAutoresizingMaskIntoConstraints = false
        
        imageOuterContainer.addSubview(imgcontainer)
        imgcontainer.addSubview(imageview)
        
        horizontalDetail.addArrangedSubview(imageOuterContainer)
        horizontalDetail.addArrangedSubview(detailStackView)
        //contentView.addSubview(descriptionLabel)
        
        mainVerticalStack.addArrangedSubview(horizontalDetail)
        mainVerticalStack.addArrangedSubview(descriptionLabel)
        
        contentView.addSubview(mainVerticalStack)
        
        
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
        view.addLayoutGuide(imageLayoutGuide)
        
        let closeButtonLayoutGuide = UILayoutGuide()
        view.addLayoutGuide(closeButtonLayoutGuide)
        
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
        closeButton.titleLabel?.font = font
        closeButton.clipsToBounds = false
        closeButton.addTarget(self, action: #selector(imageTap(_:)), for: .touchUpInside)
        view.addSubview(closeButton)
        
        
        
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
    
    //MARK: Layout methods
    
    
    //primary layout
    private func layoutConstraints(){
        
        guard let imageContainer = imageview.superview, let mainStackView = scrollView.subviews.first!.subviews.first! as? UIStackView else {
            print("returning")
            return
        }
        
        if (!constraints.isEmpty){
            print("regenerating constraints")
            NSLayoutConstraint.deactivate(constraints)
            constraints.removeAll()
        } else {
            print("generating constraints for the first time")
        }
        
        let safeArea = view.safeAreaLayoutGuide
        let views = ["stack":mainStackView,"imgcontainer":imageContainer,"imgview":imageview,"button":closeButton,"outer":imageOuterContainer] as [String:Any]
        
        //main vertical stack view constraints
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[stack]-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[stack]-8-|", options: [], metrics: nil, views: views)
        
        
        //Imgview containe
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[outer(==imgcontainer@750)]", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[outer(==imgcontainer@750)]", options: [], metrics: nil, views: views)
        
        //image view constraints
        //affix the image to the inner container
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0@500-[imgview]-0@500-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0@500-[imgview]-0@500-|", options: [], metrics: nil, views: views)
        constraints += [
            imageview.heightAnchor.constraint(equalTo: imageview.widthAnchor),
            imageview.centerXAnchor.constraint(equalTo: imageContainer.centerXAnchor),
            imageview.centerYAnchor.constraint(equalTo: imageContainer.centerYAnchor)
        ]
        
        var pinContainerConstraints = [imageContainer.centerXAnchor.constraint(equalTo: imageContainer.superview!.centerXAnchor),
                                       imageContainer.centerYAnchor.constraint(equalTo: imageContainer.superview!.centerYAnchor)]
        
        NSLayoutConstraint.fixPriorities(forConstraints: &pinContainerConstraints, withPriority: UILayoutPriority(100))
        
        constraints += pinContainerConstraints
        
        //closeButton
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[button(==44)]", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[button(==44)]", options: [], metrics: nil, views: views)
        
        closeButtonBottomConstraint = safeArea.bottomAnchor.constraint(equalTo:closeButton.bottomAnchor, constant: -100)
        closeButtonBottomConstraint.priority = UILayoutPriority(100)
        constraints += [
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButtonBottomConstraint
        ]
        
        NSLayoutConstraint.label(constraints: &constraints, with: "main constraints")
        
        NSLayoutConstraint.activate(constraints)
        view.layoutIfNeeded()

    }
    
    
    // Layout for rearranged views, upon tap on image
    func layoutInPopoverConfiguration(){
        
        guard let container = imageview.superview else {
            return
        }
        
        //if this is first run, fill centerise constraints ivar
        if(centeriseConstraints.isEmpty){
            
            let views:[String:Any] = ["imgcontainer":container,"imgview":imageview,"label":descriptionLabel,"contentView":contentView,"stackView":detailStackView,"button":closeButton,"ilayoutguide":view.layoutGuides[0],"blayoutguide":view.layoutGuides[1]]
            
            let layoutGuides = view.safeAreaLayoutGuide
            
            let widthConstraint =  min(self.view.frame.height, self.view.frame.width)
            print(widthConstraint)
            let imageContainer = container
            let vXConstraint = imageContainer.centerXAnchor.constraint(equalTo: layoutGuides.centerXAnchor)
            let vYConstraint = imageContainer.centerYAnchor.constraint(equalTo: layoutGuides.centerYAnchor)
            
            let metrics = ["maxDimension":(widthConstraint - 16),"layoutHeight":self.view.bounds.height/8]
            
            centeriseConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-8@999-[imgcontainer(==maxDimension)]-8@999-|", options: [], metrics: metrics, views: views)
            
            centeriseConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-8@999-[imgcontainer(==maxDimension)]-8@999-|", options: [], metrics: metrics, views: views)
            
            //this doesnt really work, probably the stack view
            //centeriseConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[imgcontainer][ilayoutguide(==blayoutguide)][button][blayoutguide]|", options: [], metrics: metrics, views: views)
            
            centeriseConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[stackView(==0)]", options: [], metrics: metrics, views: views)
            
            centeriseConstraints += [vXConstraint,vYConstraint]
            
            NSLayoutConstraint.label(constraints: &centeriseConstraints, with: "popover constraints")
            
        }

        // animate layout into new configuration
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 5, initialSpringVelocity: 10, options: [], animations: { [weak self] in
            if(!self!.expandedViewActive){
                NSLayoutConstraint.activate(self!.centeriseConstraints)
                self!.descriptionLabel.alpha = 0.0
                for view in self!.detailStackView.arrangedSubviews{
                    view.isHidden = true
                }
                
                if let elementLabels = self?.typeLabelArray{
                    for elabel in elementLabels{
                        elabel.isHidden = true
                    }
                }
                
                self!.scrollView.isScrollEnabled = false
                self!.detailStackView.isHidden = true
                self!.closeButtonBottomConstraint.constant = 0
            } else {
                NSLayoutConstraint.deactivate(self!.centeriseConstraints)
                self!.descriptionLabel.alpha = 1.0
                
                self!.detailStackView.alpha = 1.0
                for view in self!.detailStackView.arrangedSubviews{
                    view.isHidden = false
                }
                if let elementLabels = self?.typeLabelArray{
                    for elabel in elementLabels{
                        elabel.isHidden = false
                    }
                }
                self!.scrollView.isScrollEnabled = true
                self!.detailStackView.isHidden = false
                self!.closeButtonBottomConstraint.constant = -100
            }
            
            self!.view.layoutIfNeeded()

        }) { [weak self] (complete) in
            if(complete){
                //set ivar
                self!.expandedViewActive = !self!.expandedViewActive
            }
        }
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
