import ARKit
import PokeAPIKit

public class PokeCameraViewController : UIViewController, UIGestureRecognizerDelegate{
    
    var arView: ARSCNView {
        return self.view as! ARSCNView
    }
    
    var renderer:Renderer!
    var captureButton:CaptureButton!
    
    public var pokeModel:PokeARModel?{
        didSet{
           updateData()
        }
    }
    
    func updateData(){
        guard let pokeModel = pokeModel, let renderer = renderer else {
            return
        }
        renderer.pokemonData = pokeModel
    }
    
    public override func loadView() {
        self.view = ARSCNView(frame: .zero)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        renderer = Renderer(view: arView)
        
        updateData()
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        arView.addGestureRecognizer(pan)
        pan.delegate = self
        
//        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
//        arView.addGestureRecognizer(pinch)
//        pinch.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        arView.addGestureRecognizer(tap)
        
        
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(didRotate(_:)))
        arView.addGestureRecognizer(rotate)
        rotate.delegate = self
        

        let uiswitch = UISwitch()
        uiswitch.translatesAutoresizingMaskIntoConstraints = false
        uiswitch.addTarget(self, action: #selector(updateDebug(_:)), for: .valueChanged)
        uiswitch.transform = CGAffineTransform(rotationAngle: -.pi / 4)
        arView.addSubview(uiswitch)
        
        captureButton = CaptureButton()
        
        captureButton.addTarget(self, action: #selector(capture(_:)), for: .touchUpInside)
        captureButton.isUserInteractionEnabled = true
        arView.addSubview(captureButton)
        
        let guide = arView.safeAreaLayoutGuide
        
        captureButton.widthAnchor.constraint(equalToConstant: captureButton.captureButtonDimension).isActive = true
        captureButton.heightAnchor.constraint(equalToConstant: captureButton.captureButtonDimension).isActive = true
        
        captureButton.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -20).isActive = true
        
        captureButton.centerYAnchor.constraint(equalTo: guide.centerYAnchor).isActive = true
        
        
        
        
        
        guide.rightAnchor.constraint(equalToSystemSpacingAfter: uiswitch.rightAnchor, multiplier: 1.0).isActive = true
       guide.bottomAnchor.constraint(equalToSystemSpacingBelow:uiswitch.bottomAnchor, multiplier: 1.0).isActive = true
        
        updateDebug(uiswitch)
    }
    
    override public func viewWillLayoutSubviews() {
        view.layoutIfNeeded()
    }
    
    lazy var exposureView:UIView = {
        let ev = UIView(frame:self.view.bounds)
        ev.backgroundColor = UIColor.white
        let imgview = UIImageView()
        imgview.backgroundColor = UIColor.white
        imgview.translatesAutoresizingMaskIntoConstraints = false
        ev.addSubview(imgview)
        let safety = ev.safeAreaLayoutGuide
        let cts = [
        imgview.topAnchor.constraint(equalToSystemSpacingBelow: safety.topAnchor, multiplier: 1.0.cgFloat()),
        imgview.leftAnchor.constraint(equalToSystemSpacingAfter: safety.leftAnchor, multiplier: 1.0.cgFloat()),
        safety.bottomAnchor.constraint(equalToSystemSpacingBelow: imgview.bottomAnchor, multiplier: 1.0.cgFloat()),
        safety.trailingAnchor.constraint(equalToSystemSpacingAfter: imgview.trailingAnchor, multiplier: 1.0.cgFloat())
            ]
        NSLayoutConstraint.activate(cts)
        return ev
    }()
    
    lazy var savedLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Saved To Camera Roll"
        //label.font = UIFontMetrics.init(forTextStyle: .caption1).scaledFont(for: UIFont.systemFont(ofSize: 10))
        label.textColor = .white
        label.textAlignment = .center
        let safety = self.view.safeAreaLayoutGuide
        let cts = [
            label.centerXAnchor.constraint(equalTo: safety.centerXAnchor),
            label.widthAnchor.constraint(equalTo: safety.widthAnchor,multiplier: 0.7),
            safety.bottomAnchor.constraint(equalToSystemSpacingBelow: label.bottomAnchor, multiplier: 1.0.cgFloat()),
        ]
        self.view.addSubview(label)
        NSLayoutConstraint.activate(cts)
        label.sizeToFit()
        return label
    }()
    
    @objc func capture(_ sender:CaptureButton){
        print("capture")
        sender.isHighlighted = true
        let image = arView.snapshot()
        sender.isEnabled = false
        exposureView.layer.opacity = 1.0
        let photoView = (self.exposureView.subviews.first! as! UIImageView)
        photoView.layer.opacity = 0.0
        savedLabel.layer.opacity = 0.0
        exposureView.frame = view.frame
        self.view.insertSubview(exposureView, at: 0)
        self.view.insertSubview(savedLabel, belowSubview: exposureView)
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWith:contextInfo:)), nil)
        
    }
    
    @objc func image(image:UIImage, didFinishSavingWith error:Error?,contextInfo:UnsafeMutableRawPointer?){
        print("whooa", image, error, contextInfo)
        let photoView = (self.exposureView.subviews.first! as! UIImageView)
        photoView.image = image
        photoView.layer.opacity = 0
        
        UIView.animateKeyframes(withDuration: 2.0, delay: 0, options: [], animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3, animations: {
                self.exposureView.transform = CGAffineTransform.init(scaleX: 0.7, y: 0.7)
                 self.savedLabel.layer.opacity = 1.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1.0, animations: {
                photoView.layer.opacity = 1.0
            })
            
           // self.exposureView.layer.opacity = 0
            
        }) { (complete) in
            if(complete){
                
                UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 10, initialSpringVelocity: 10, options: [], animations: {
                    
                    self.exposureView.transform = self.exposureView.transform.concatenating(CGAffineTransform.init(scaleX: 0.5, y: 0.5).concatenating(CGAffineTransform.init(translationX: 0, y: -500)))
                        
                    self.exposureView.layer.opacity = 0
                    
                    self.savedLabel.transform = CGAffineTransform(translationX: 0, y: -100)
                    self.savedLabel.layer.opacity = 0.0
                    
                }, completion: { (complete) in
                    if(complete){
                    self.captureButton.isEnabled = true
                    self.exposureView.removeFromSuperview()
                    self.exposureView.layer.opacity = 0
                    self.exposureView.transform = .identity
                    self.savedLabel.layer.opacity = 0
                    self.savedLabel.transform = .identity
                    }
                })
                
                
            }
        }
        
    }
    
    @objc
    func updateDebug(_ sender:UISwitch){
        renderer.updateDebug(debug: sender.isOn)
    }
    
    @objc
    func handleTap(_ recogniser:UITapGestureRecognizer ){
        
        if(recogniser.state == .ended){
             print("you tapped, big whoop")
            guard let state = arView.session.currentFrame?.camera.trackingState else {
                print("no luck this time")
                return
            }
            
            switch state {
            case .normal:
                renderer.addGeometryNode(at: CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY))
            default:
                return
            }
        }
        
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow objects to be translated and rotated at the same time.
        
        if(gestureRecognizer is UIPinchGestureRecognizer){
            return false
        }
        
        return true
    }
    
    /// - Tag: didRotate
    @objc
    func didRotate(_ gesture: UIRotationGestureRecognizer) {
        guard gesture.state == .changed else { return }
        
        /*
         - Note:
         For looking down on the object (99% of all use cases), we need to subtract the angle.
         To make rotation also work correctly when looking from below the object one would have to
         flip the sign of the angle depending on whether the object is above or below the camera...
         */
        renderer.setRotation(rotation: Float(gesture.rotation))
        
        gesture.rotation = 0
    }
    
//    @objc
//    func handlePinch(_ recongniser:UIPinchGestureRecognizer){
//        let location = recongniser.location(in: arView)
//        let scale = Float(recongniser.scale)
//        switch recongniser.state {
//        case .began:
//            print("began")
//            renderer.scale(basedOn:location,scale:scale)
//        case .changed:
//            print("changed")
//            renderer.scale(basedOn:location,scale:scale)
//        case .cancelled:
//            print("cancelled")
//            renderer.isDragging = false
//        case .ended:
//            renderer.isScaling = false
//            renderer.selectedItem = nil
//            print("ended")
//        default:
//            print("something else")
//        }
//
//    }
    
    @objc
    func handlePan(_ recongniser:UIPanGestureRecognizer){

        let touch = recongniser.location(in: arView)

        switch(recongniser.state){
        case .began:
            print("began")
            renderer.isDragging = true
        case .changed:
            print("changed")
            renderer.translate(basedOn: touch, infinitePlane: true, allowAnimation: true)
        case .cancelled:
            print("cancelled")
            renderer.isDragging = false
        case .ended:
            renderer.isDragging = false
            renderer.selectedItem = nil
            print("ended")
        default:
            print("something else")
        }

    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        
        arView.session.run(configuration, options:[])
        
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        arView.session.pause()
    }
    
    @objc public func dismissz(){
        dismiss(animated: true, completion: nil)
    }

    
}


extension Double {
    func cgFloat()->CGFloat{
        return CGFloat(self)
    }
}
