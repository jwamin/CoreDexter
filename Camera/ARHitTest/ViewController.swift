import ARKit
import PokeAPIKit

public class PokeCameraViewController : UIViewController, UIGestureRecognizerDelegate{
    
    var arView: ARSCNView {
        return self.view as! ARSCNView
    }
    
    var renderer:Renderer!
    var captureButton:CaptureButton!
    
    public static var labelFont:UIFont?
    
    var closeButton:UIButton!
    var titleLable:UILabel!
    
    let debugModeSwitch:Bool = UserDefaults.standard.bool(forKey: "experimental")
    
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
        
        let guide = arView.safeAreaLayoutGuide
        
//        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
//        arView.addGestureRecognizer(pinch)
//        pinch.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        arView.addGestureRecognizer(tap)
        
        
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(didRotate(_:)))
        arView.addGestureRecognizer(rotate)
        rotate.delegate = self
        
        captureButton = CaptureButton()
        
        captureButton.addTarget(self, action: #selector(capture(_:)), for: .touchUpInside)
        captureButton.isUserInteractionEnabled = true
        
        arView.addSubview(captureButton)
        captureButton.widthAnchor.constraint(equalToConstant: captureButton.captureButtonDimension).isActive = true
        captureButton.heightAnchor.constraint(equalToConstant: captureButton.captureButtonDimension).isActive = true
        captureButton.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -20).isActive = true
        captureButton.centerYAnchor.constraint(equalTo: guide.centerYAnchor).isActive = true
        
        closeButton = UIButton()
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("Close", for: .normal)
        
        if let labelFont = PokeCameraViewController.labelFont{
            closeButton.titleLabel?.font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: labelFont)
        }
        
        closeButton.addTarget(self, action: #selector(dismissz), for: .touchUpInside)
        view.addSubview(closeButton)
        
        closeButton.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1.0).isActive = true
        arView.safeAreaLayoutGuide.trailingAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: closeButton.trailingAnchor, multiplier: 1.0).isActive = true
    
        
        if(debugModeSwitch){
            let uiswitch = UISwitch()
            uiswitch.translatesAutoresizingMaskIntoConstraints = false
            uiswitch.addTarget(self, action: #selector(updateDebug(_:)), for: .valueChanged)
            uiswitch.transform = CGAffineTransform(rotationAngle: -.pi / 4)
            arView.addSubview(uiswitch)
            guide.rightAnchor.constraint(equalToSystemSpacingAfter:uiswitch.rightAnchor, multiplier: 1.0).isActive = true
            guide.bottomAnchor.constraint(equalToSystemSpacingBelow:uiswitch.bottomAnchor, multiplier: 2.0).isActive = true
            updateDebug(uiswitch)
        }
        
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
        if let labelFont = PokeCameraViewController.labelFont{
            label.font = UIFontMetrics.init(forTextStyle: .title1).scaledFont(for: labelFont)
        }
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
    
   
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow objects to be translated and rotated at the same time.
        
        if(gestureRecognizer is UIPinchGestureRecognizer){
            return false
        }
        
        return true
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
    

    
}


extension Double {
    func cgFloat()->CGFloat{
        return CGFloat(self)
    }
}
