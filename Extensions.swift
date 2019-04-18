//
//  Extensions.swift
//  CoreDexter
//
//  Created by Joss Manger on 4/16/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit


extension NSLayoutConstraint {
    
    static func label(constraints set:inout [NSLayoutConstraint], with identifier:String){
        
        for constraint in set{
            constraint.identifier = identifier
        }
        
    }
    
    static func fixPriorities(forConstraints constraints: inout [NSLayoutConstraint],withPriority priority:UILayoutPriority){
        
        for constraint in constraints{
            constraint.priority = priority
        }
        
    }
    
}
