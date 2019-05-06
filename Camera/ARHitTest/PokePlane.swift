//
//  PokePlane.swift
//  PokeCameraApp
//
//  Created by Joss Manger on 4/23/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import ARKit
import PokeAPIKit



public class PokePlane : SCNNode{
    
    public var anchor:ARAnchor?
    
    public init(pokemonData:PokeARModel?) {
        super.init()
        var dimension:CGFloat = pokeDefaultPlainDimension
        var image:UIImage?
        
        if let data = pokemonData{
            dimension = CGFloat(data.height)
            image = UIImage(data: data.sprite)!
        }
        
        //create SCN geometry and node (it's a plane)
        let geometry = SCNPlane(width: dimension, height: dimension)
        //self SCNNode(geometry: geometry)
        //self.pokemonData = pokemonData

        
        self.geometry = geometry
        //setup geometry materials (image)
        geometry.materials.first!.diffuse.contents = image ?? UIColor.red.cgColor
        geometry.materials.first!.isDoubleSided = true
        
        //set bitmask for removal later
        self.categoryBitMask = POKE_PLAIN_CATEGORY_BIT_MASK
        
        //create identity transform to set initial settings
        var identity = matrix_identity_float4x4
        
        // since the height of the plane is 0.3 meters, translate the plane by half its height in the y axis, ensures it appears to "sit" on the floor in the center
        identity.columns.3.y = identity.columns.3.y + Float(dimension)/2

        //pivot
        //identity.columns.3.y = identity.columns.3.y + -Float(dimension)/2
        
        self.simdTransform = identity
        //self.simdPivot = identity
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func addToPlaneAnchor(anchor:ARPlaneAnchor,with node:SCNNode){
        
        print("add to plane anchor called")
        // Check that the object is not already on the plane.
        
        print("added",self.description,"to anchor",anchor)
        
        // Get the object's position in the plane's coordinate system.
        let planePosition = node.convertPosition(position, from: parent)
        
        // Check that the object is not already on the plane.
        guard planePosition.y != 0 else { return }
        
        // Add 10% tolerance to the corners of the plane.
        let tolerance: Float = 0.1
        
        let minX: Float = anchor.center.x - anchor.extent.x / 2 - anchor.extent.x * tolerance
        let maxX: Float = anchor.center.x + anchor.extent.x / 2 + anchor.extent.x * tolerance
        let minZ: Float = anchor.center.z - anchor.extent.z / 2 - anchor.extent.z * tolerance
        let maxZ: Float = anchor.center.z + anchor.extent.z / 2 + anchor.extent.z * tolerance
        
        guard (minX...maxX).contains(planePosition.x) && (minZ...maxZ).contains(planePosition.z) else {
            return
        }
        
        // Move onto the plane if it is near it (within 5 centimeters).
        let verticalAllowance: Float = 0.05
        let epsilon: Float = 0.001 // Do not update if the difference is less than 1 mm.
        let distanceToPlane = abs(planePosition.y)
        if distanceToPlane > epsilon && distanceToPlane < verticalAllowance {
            print("animating")
            SCNTransaction.begin()
            SCNTransaction.animationDuration = CFTimeInterval(distanceToPlane * 500) // Move 2 mm per second.
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            position.y = anchor.transform.columns.3.y
            //updateAlignment(to: anchor.alignment, transform: simdWorldTransform, allowAnimation: false)
            SCNTransaction.commit()
        }
        
        
    }
    
}
