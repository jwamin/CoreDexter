//
//  ExtensionsEtx.swift
//  CoreDexter
//
//  Created by Joss Manger on 2/1/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import Foundation
import UIKit

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

public enum GenerationRegionBridge:String{
    
    case gen1 = "generation-i"
    case gen2 = "generation-ii"
    case gen3 = "generation-iii"
    case gen4 = "generation-iv"
    case gen5 = "generation-v"
    case gen6 = "generation-vi"
    
    public func getRegion()->RegionIndex{
        switch self {
        case .gen1:
            return .kanto
        case .gen2:
            return .jhoto
        case .gen3:
            return .hoenn
        case .gen4:
            return .sinnoh
        case .gen5:
            return .unova
        case .gen6:
            return .kalos
        //this isnt perfect since where does Alola appear?
//        default:
//            return.national
        }
    }
}


public enum RegionIndex:Int{
    case national = 1
    case kanto = 2
    case jhoto = 3
    case hoenn = 4
    case sinnoh = 5
    case unova = 8
    case kalos = 12
    case alola
    public func string() -> String{
        switch self {
        case .kanto:
            return "Kanto"
        case .jhoto:
            return "Jhoto"
        case .hoenn:
            return "Hoenn"
        case .sinnoh:
            return "Sinnoh"
        case .unova:
            return "Unova"
        case .kalos:
            return "Kalos"
        case .alola:
            return "Alola"
        default:
            return "National"
        }
    }
    public func startIndex(index:Int)->String{
        var str = 0
        switch self {
        case .jhoto:
            str = index + 151
        case .hoenn:
            str = index + 251
        case .sinnoh:
            str = index + 386
        case .unova:
            str = index + 493
        case .kalos:
            str = index + 649
        default:
             str = index + 0
        }
        
        return String(str)
    }
    public func physicalRegion() -> String{
        switch self {
        case .kanto:
            return "Japan; Greater Tokyo and bay area."
        case .jhoto:
            return "Japan; Central western Honshu."
        case .hoenn:
            return "Japan; Kyushu and islands."
        case .sinnoh:
            return "Japan; Hokkaido."
        case .unova:
            return "USA; New York City area."
        case .kalos:
            return "France."
        case .alola:
            return "USA; Hawaii."
        default:
            return ""
        }
    }
}


extension UIColor {
    
    public static let bulbasaurGreen:UIColor = UIColor(red: 203/255, green: 253/255, blue: 134/255, alpha: 1.0)
    
    public static let squirtleBlue:UIColor = UIColor(red: 49/255, green: 181/255, blue: 222/255, alpha: 1.0)
    
}
