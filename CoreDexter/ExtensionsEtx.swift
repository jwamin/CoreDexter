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

enum RegionIndex:Int{
    case national = 1
    case kanto = 2
    case jhoto = 3
    case hoenn = 4
    case sinnoh = 5
    case unova = 8
    case kalos = 12
    case alola
    func string() -> String{
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
    func startIndex(index:Int)->String{
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
    func physicalRegion() -> String{
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
