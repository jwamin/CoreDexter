//
//  ViewControllerActions.swift
//  PokeCamera
//
//  Created by Joss Manger on 4/24/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import ARKit

extension PokeCameraViewController {
    
    
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
        self.view.addSubview(exposureView)
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
    
    
    @objc public func dismissz(){
        dismiss(animated: true, completion: nil)
    }

}


