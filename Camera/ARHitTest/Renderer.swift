//
//  Renderer.swift
//  ARHitTest
//
//  Created by Joss Manger on 4/6/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//
import PokeAPIKit
import ARKit

class Renderer : NSObject, ARSCNViewDelegate, SCNSceneRendererDelegate{
    
    let scene:SCNScene
    let view:ARSCNView
    var targetView:UILabel!
    
    var statusLabel:UILabel!
    
    var pokemonData:PokeARModel?
    
    var pokePlanes = [PokePlane]()
    
    let updateQueue = DispatchQueue(label: "com.jossy.CoreDexter.pokeCameraARKitQueue")
    
    init(view:ARSCNView){
        self.view = view
        self.scene = view.scene
        
        targetView = UILabel()
        targetView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(targetView)
        
        targetView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        targetView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        //targetView.widthAnchor.constraint(equalToConstant: 10).isActive = true
        //targetView.heightAnchor.constraint(equalTo: targetView.widthAnchor).isActive = true
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.text = ""
        if let labelFont = PokeCameraViewController.labelFont{
            statusLabel.font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: labelFont)
        }
        
        blurView.contentView.addSubview(statusLabel)
        
        statusLabel.centerXAnchor.constraint(equalTo: blurView.centerXAnchor).isActive = true
        statusLabel.centerYAnchor.constraint(equalTo: blurView.centerYAnchor).isActive = true
        
        statusLabel.topAnchor.constraint(equalToSystemSpacingBelow: blurView.contentView.topAnchor, multiplier: 1.0).isActive = true
        statusLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: blurView.contentView.leadingAnchor, multiplier: 1.0).isActive = true
        blurView.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: statusLabel.trailingAnchor, multiplier: 1.0).isActive = true
        blurView.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: statusLabel.bottomAnchor, multiplier: 1.0).isActive = true
        
        
        view.addSubview(blurView)
        
        blurView.heightAnchor.constraint(greaterThanOrEqualTo: statusLabel.heightAnchor).isActive = true
        blurView.widthAnchor.constraint(greaterThanOrEqualTo: statusLabel.widthAnchor).isActive = true
        blurView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1.0).isActive = true
        blurView.leftAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: view.safeAreaLayoutGuide.leftAnchor, multiplier: 1.0).isActive = true
        
        super.init()
        view.delegate = self
        view.debugOptions = []
        self.view.superview?.layoutIfNeeded()
        blurView.clipsToBounds = true
        
        //clean the views up so this is dynamic
        blurView.layer.cornerRadius = 10
        
    }
    
    func updateDebug(debug:Bool){
        view.debugOptions = (debug) ? [.showBoundingBoxes,.showFeaturePoints,.showWorldOrigin] : []
    }
    
    func resetExperience(){
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
//        guard let pointOfView = view.pointOfView, let camera = view.pointOfView?.camera else {
//            return
//        }
//
//        print("location:\(location)\norientation:\(orientation)")
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        

    
        DispatchQueue.main.async {
            let midPoint = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
            
            //first look for existing
            if let scnIntersection = self.getFirstSCNIntersection(point: midPoint){
                if(scnIntersection.node.categoryBitMask == POKE_PLAIN_CATEGORY_BIT_MASK){
                    
                    self.updateQueue.sync {
                        self.targetView.text = "❌"
                        self.statusLabel.text = "Tap to remove sprite"
                    }
                    self.targetView.layer.removeAllAnimations()
                    return
                }
            }
            
            let hits = self.view.hitTest(midPoint, types: [.existingPlane])
            guard let nearestHit = hits.first else {
                self.targetView.text = "🚫"
                self.targetView.layer.removeAllAnimations()
                return
            }
            
            //print(nearestHit)
            
            self.updateQueue.sync {
                self.targetView.text = "⭕️"
                self.statusLabel.text = "Tap to add sprite"
            }
            if(self.targetView.layer.animation(forKey: "scale") == nil){
                
                let animation = CABasicAnimation(keyPath: "transform")
                animation.fromValue = CATransform3DMakeScale(1, 1, 1)
                animation.toValue = CATransform3DMakeScale(2.0, 2.0, 1)
                animation.autoreverses = true
                animation.repeatCount = .infinity
                animation.duration = 0.5
                //self.targetView.layer.transform
                self.targetView.layer.add(animation, forKey: "scale")
            }
            

            
        }
        

    }
    
    func getFirstARIntersection(point:CGPoint)->ARHitTestResult?{
        let hits = self.view.hitTest(point, types: [.existingPlane]) // we will use infinite planes, because whatevs
        return hits.first
    }
    
    func getFirstSCNIntersection(point:CGPoint)->SCNHitTestResult?{
        let pointAdjust = CGPoint(x: point.x, y: point.y-10)
        let hits = self.view.hitTest(pointAdjust, options: nil)
        return hits.first
    }
    
    func addGeometryNode(at point:CGPoint){
        
        if let intersection = getFirstSCNIntersection(point: point){
            print("scn intersection?",intersection.node)
            if(intersection.node.categoryBitMask == POKE_PLAIN_CATEGORY_BIT_MASK){
                removeGeometryNode(node: intersection.node)
                return
            }
 
        }
        
        guard let intersection = getFirstARIntersection(point: point), let anchor = intersection.anchor,let camera = view.session.currentFrame?.camera else {
            print("returning for some reason")
            return
        }
        
       let newnode = PokePlane(pokemonData: pokemonData)
        newnode.anchor = anchor
        //multiply adjustment transform and world transform of insersection together
        let transform = matrix_multiply(newnode.simdTransform, intersection.worldTransform)
        
        //set transform of node to multiplied result of intersection tr
        newnode.simdTransform = transform
        newnode.eulerAngles.y = camera.eulerAngles.y
       
        
        
        //newnode.simdEulerAngles = camera.eulerAngles
        pokePlanes.append(newnode)
        self.scene.rootNode.addChildNode(newnode)
    
    }
    
    func removeGeometryNode(node:SCNNode){
        
        pokePlanes.removeAll { (listNode) -> Bool in
            listNode == node
        }
        node.removeFromParentNode()
        print(pokePlanes.count)
    }
    
    var isDragging = false
    var selectedItem:SCNNode?
    
    var isScaling:Bool = false
    var selectedItemInitialScale:simd_float3?
    
    func setRotation(rotation:Float){
        guard let node = selectedItem else {
            return
        }
        let newValue = (node.eulerAngles.y-Float(rotation))
        var normalized = newValue.truncatingRemainder(dividingBy: 2 * .pi)
        normalized = (normalized + 2 * .pi).truncatingRemainder(dividingBy: 2 * .pi)
        if normalized > .pi {
            normalized -= 2 * .pi
        }
        
        node.eulerAngles.y = normalized
        
    }
    
    func scale(basedOn point:CGPoint,scale:Float){
    
        guard let result = getFirstARIntersection(point: point), let scnhittest = getFirstSCNIntersection(point: point) else {
                return
        }
        
        guard let node = selectedItem else {
            return
        }

        if(!isScaling){
            selectedItemInitialScale = node.simdScale
            isScaling = true
        }
        
        guard let initialScale = selectedItemInitialScale else {
            return
        }
        
        var newSimdScale:simd_float3 = node.simdScale
        print(scale,node.simdScale)
        newSimdScale.x = initialScale.x * scale
        newSimdScale.y = initialScale.y * scale
        node.simdScale = newSimdScale
        
        print(newSimdScale)
    }
    
    
    /// - Tag: DragVirtualObject
    func translate( basedOn screenPos: CGPoint, infinitePlane: Bool, allowAnimation: Bool) {
        guard let cameraTransform = view.session.currentFrame?.camera.transform,
            let result = getFirstARIntersection(point: screenPos), let scnhittest = getFirstSCNIntersection(point: screenPos) else {
                print("something missing")
                return
        }
        
        let node = scnhittest.node
        selectedItem = node
        let planeAlignment: ARPlaneAnchor.Alignment
        if let planeAnchor = result.anchor as? ARPlaneAnchor {
            planeAlignment = planeAnchor.alignment
        } else if result.type == .estimatedHorizontalPlane {
            planeAlignment = .horizontal
        } else if result.type == .estimatedVerticalPlane {
            planeAlignment = .vertical
        } else {
            print("plane?")
            return
        }
        
        /*
         Plane hit test results are generally smooth. If we did *not* hit a plane,
         smooth the movement to prevent large jumps.
         */
        let transform = result.worldTransform
        let isOnPlane = result.anchor is ARPlaneAnchor
        setTransform(node,transform,
                            relativeTo: cameraTransform,
                            smoothMovement: !isOnPlane,
                            alignment: planeAlignment,
                            allowAnimation: allowAnimation)
    }
    
    func setTransform(_ node:SCNNode, _ newTransform: float4x4,
                      relativeTo cameraTransform: float4x4,
                      smoothMovement: Bool,
                      alignment: ARPlaneAnchor.Alignment,
                      allowAnimation: Bool) {
        let c3 = cameraTransform.columns.3
        let cameraWorldPosition = float3(c3.x, c3.y, c3.z)
        
        let newTranslationc3 = newTransform.columns.3
        let translation = float3(newTranslationc3.x,newTranslationc3.y,newTranslationc3.z)
        
        var positionOffsetFromCamera = translation - cameraWorldPosition
        
        // Limit the distance of the object from the camera to a maximum of 10 meters.
        if simd_length(positionOffsetFromCamera) > 10 {
            positionOffsetFromCamera = simd_normalize(positionOffsetFromCamera)
            positionOffsetFromCamera *= 10
        }
        
        /*
         Compute the average distance of the object from the camera over the last ten
         updates. Notice that the distance is applied to the vector from
         the camera to the content, so it affects only the percieved distance to the
         object. Averaging does _not_ make the content "lag".
         */
//        if smoothMovement {
//            let hitTestResultDistance = simd_length(positionOffsetFromCamera)
//
//            // Add the latest position and keep up to 10 recent distances to smooth with.
//            recentVirtualObjectDistances.append(hitTestResultDistance)
//            recentVirtualObjectDistances = Array(recentVirtualObjectDistances.suffix(10))
//
//            let averageDistance = recentVirtualObjectDistances.average!
//            let averagedDistancePosition = simd_normalize(positionOffsetFromCamera) * averageDistance
//            node.simdPosition = cameraWorldPosition + averagedDistancePosition
//        } else {
//            node.simdPosition = cameraWorldPosition + positionOffsetFromCamera
//        }
        node.simdPosition = cameraWorldPosition + positionOffsetFromCamera
       // updateAlignment(to: alignment, transform: newTransform, allowAnimation: allowAnimation)
    }
    
    
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
//        updateQueue.async {
//            for object in self.pokePlanes {
//                object.addToPlaneAnchor(anchor: planeAnchor, with: node)
//            }
//        }
//
//
//    }
//
//    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
//        updateQueue.async {
//            if let sceneNode = self.pokePlanes.first(where: {$0.anchor == anchor}){
//                print("updated")
//                sceneNode.simdPosition = planeAnchor.transform.translation
//                sceneNode.anchor = planeAnchor
//            }
//        }
//
//
//    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState{
        case .notAvailable, .limited:
            pokePlanes.forEach {
                $0.isHidden = true
            }
            updateQueue.sync {
                self.statusLabel.text = "AR Tracking Limited or Not Available"
            }
        case .normal:
            pokePlanes.forEach {
                $0.isHidden = false
            }
            updateQueue.sync {
                self.statusLabel.text = "AR Tracking Is Ready! Move the device around to find a plane..."
            }
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        
        pokePlanes.forEach {
            $0.isHidden = true
        }
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        pokePlanes.forEach {
            $0.isHidden = false
        }
    }
    
}

