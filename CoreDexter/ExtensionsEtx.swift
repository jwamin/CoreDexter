//
//  ExtensionsEtx.swift
//  CoreDexter
//
//  Created by Joss Manger on 2/1/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import Foundation

public extension Int{
    
    func digitString()->String{
        switch self {
        case let i where i<10:
            return "00"+String(self);
        case let i where i<100:
            return "0"+String(self);
        default:
            return String(self)
        }
    }
    
}
