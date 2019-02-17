//
//  ViewController.swift
//  001
//
//  Created by Joss Manger on 1/27/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit
import SpriteKit

import SceneKit
//import PlaygroundSupport

#if os(OSX)
import Cocoa
typealias Color = NSColor
typealias Image = NSImage
typealias ViewController = NSViewController
typealias View = NSView
typealias Rect = NSRect
#else
import UIKit
typealias Color = UIColor
typealias Image = UIImage
typealias ViewController = UIViewController
typealias View = UIView
typealias Rect = CGRect
#endif

let DEBUG = false

let colors:[Color] = [
    Color.red,
    Color.orange,
    Color.yellow,
    Color.green,
    Color.blue,
    Color.purple
]

let MAX = 151

struct PokemonSpriteData{
    var name:String
    var number:Int
    var img:Image?
}

class SKViewController:ViewController, SCNSceneRendererDelegate, CAAnimationDelegate {
    
    var scene:SCNScene!
    var scnView:SCNView!
    let cameraNode:SCNNode = SCNNode()
    var tasks:DispatchGroup!
    var pokedex:[Int:PokemonSpriteData] = [:]
    var layers:[CAAnimationGroup:SCNNode] = [:]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        scnView = SCNView(frame: view.frame)
        scnView.translatesAutoresizingMaskIntoConstraints = false
        if(DEBUG){
            scnView.showsStatistics = true
        }
        scnView.allowsCameraControl = true
        view.addSubview(scnView)
        scene = SCNScene()
        
        let views = ["scnView":scnView]
        var constraints:[NSLayoutConstraint] = [NSLayoutConstraint]()
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[scnView]-0-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[scnView]-0-|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(constraints)
        
        
        scnView.scene = scene
        scnView.delegate = self
        scnView.backgroundColor = Color.gray
        self.setupScene()
        
        //create dispatch group
        tasks = DispatchGroup()
        
        //add background URLSessions, with index, to dispatch group
        for index in 1...MAX{
            let task = createTask(index: index)
            task.resume()
        }
        
        
    }
    
    func createTask(index:Int)->URLSessionDataTask{
        
        tasks.enter()
        
        guard let url = URL(string:"https://pokeapi.co/api/v2/pokemon/\(index)/") else {
            fatalError()
        }
        
        return URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if(error != nil){
                fatalError(error.debugDescription)
            }
            
            guard let data = data else {
                return
            }
            DispatchQueue.global(qos: .utility).async {
                
                
                do{
                    let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]
                    
                    
                    guard let name = dict["name"] as? String, let number = dict["id"] as? Int else {
                        fatalError()
                    }
                    
                    self.pokedex[index] = PokemonSpriteData(name: name, number: number, img: nil)
                    
                    let spritesDict = dict["sprites"] as! [String:Any]
                    let imgUrl = URL(string:spritesDict["front_default"]! as! String)!
                    
                    let imageTask = URLSession.shared.dataTask(with: imgUrl, completionHandler: {
                        (data,response,error) in
                        
                        let image = Image(data: data!)
                        
                        self.pokedex[index]!.img = image!
                        
                        //notify DispatchGroup that we are done with this particular last
                        self.tasks.leave()
                        
                        
                    })
                    imageTask.resume()
                    
                } catch {
                    print(error)
                }
            }
            
        })
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        print("call",flag)
        
        if(flag){
            let group = anim as! CAAnimationGroup
            if let node:SCNNode = layers[group]{
                node.geometry = nil
                node.removeFromParentNode()
                layers.removeValue(forKey: group)
                
            }
        }
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        print("started")
    }
    
    func addAndAnimatePlane(_ image:Image?){
        
        let multiples = [1,2,0.5]
        let size:CGFloat = CGFloat(1 *  multiples[multiples.randomIndex])
        let box = SCNPlane(width: size, height: size)
        box.materials.first?.diffuse.contents = image ?? colors[colors.randomIndex]
        box.materials.first?.isDoubleSided = true
        let node = SCNNode(geometry: box)
        
        let randomPostionsX = Float.random(min:-3,max:3)
        let randomPositionY = Float.random(min:-3,max:3)
        let randomPositionZ = Float.random(min:-10,max:Float(cameraNode.position.z))
        
        node.position = SCNVector3Make(Float(randomPostionsX), Float(randomPositionY), Float(randomPositionZ))
        
        node.opacity = 0
        node.scale = SCNVector3(0.6, 0.6, 0.6)
        
        scene.rootNode.addChildNode(node)
        
        let group = CAAnimationGroup()
        group.duration = 10
        
        let opacity1 = CABasicAnimation(keyPath: "opacity")
        opacity1.fromValue = 0.0
        opacity1.toValue = 1.0
        opacity1.duration = 0.1
        opacity1.beginTime = 0
        opacity1.fillMode = .forwards
        
        let scale = CABasicAnimation(keyPath: "scale")
        scale.fromValue = SCNVector3Make(0.6, 0.6, 0.6)
        scale.toValue = SCNVector3Make(1, 1, 1)
        scale.duration = 0.1
        scale.beginTime = 0
        scale.fillMode = .forwards
        
        let position = CABasicAnimation(keyPath: "position")
        position.fromValue = node.position
        position.toValue = SCNVector3(node.position.x, node.position.y, cameraNode.position.z)
        position.duration = 9.9
        position.beginTime = 0.1
        position.fillMode = .forwards
        
        let opacity2 = CABasicAnimation(keyPath: "opacity")
        opacity2.fromValue = 1.0
        opacity2.toValue = 0.0
        opacity2.duration = 0.1
        opacity2.beginTime = 9.9
        opacity2.fillMode = .forwards
        
        let scale2 = CABasicAnimation(keyPath: "scale")
        scale2.fromValue = SCNVector3Make(1, 1, 1)
        scale2.toValue = SCNVector3Make(0.6, 0.6, 0.6)
        scale2.duration = 1.1
        scale2.beginTime = 9.9
        scale2.fillMode = .forwards
        
        group.animations = [opacity1,scale,position,scale2,opacity2]
        group.fillMode = .forwards
        group.isRemovedOnCompletion = true
        layers[group] = node
        group.delegate = self
        node.addAnimation(group, forKey: "all")
        
    }
    
    func setupScene(){
        
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 3)
        scene.rootNode.addChildNode(cameraNode)
        scnView.pointOfView = cameraNode
        
        //debug positioning
        if(DEBUG){
            let box = SCNPlane(width: 1, height: 1)
            box.materials.first?.diffuse.contents = Color.black.cgColor
            let node = SCNNode(geometry: box)
            scene.rootNode.addChildNode(node)
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { (timer) in
            if let pokemon = self.pokedex.randomElement() {
                if let img = pokemon.value.img{
                    DispatchQueue.main.async {
                        
                        self.addAndAnimatePlane(img)
                        
                    }
                }
                
            }
            
        }
        
    }
    
}

// MARK: Float Extension

public extension Float {
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: Float {
        return Float(arc4random()) / 0xFFFFFFFF
    }
    
    /// Random float between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random float point number between 0 and n max
    public static func random(min: Float, max: Float) -> CGFloat {
        return CGFloat(Float.random * (max - min) + min)
    }
}

public extension Array {
    public var randomIndex:Int{
        return Int(arc4random_uniform(UInt32(self.count)))
    }
}




