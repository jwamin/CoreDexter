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

public enum Generation:String{
    
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
    
    public func getGenerationFromGame(gameString:String)->Generation{
        switch gameString {
        case "red":
            return .gen1
        case"blue":
            return .gen1
        case"gold":
            return .gen2
        case"silver":
            return .gen2
        case"ruby":
             return .gen3
        case"sapphire":
             return .gen3
        case"diamond":
            return .gen3
        case"pearl":
            return .gen3
        case"black":
            return .gen3
        case"white":
            return .gen4
        case"x":
            return .gen6
        case"y":
            return .gen6
        case"sun":
            return .gen6
        case"moon":
            return .gen6
        default:
            fatalError("no matches, might as well knacker the whole lot")
        }
    }
    
    public static let games:[Generation:String] = [
        .gen1:"red",
        .gen2:"gold",
        .gen3:"ruby",
        .gen4:"diamond",
        .gen5:"black",
        .gen6:"x"
    ]
    
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

//Pallet Town

extension UIColor {
    
    static func ezColor(r:CGFloat,g:CGFloat,b:CGFloat)->UIColor{
        func decimalize(color:CGFloat)->CGFloat{
            return color/255.0
        }
        
        return UIColor(red: decimalize(color: r), green: decimalize(color: g), blue: decimalize(color: b), alpha: 1.0)
        
    }
    
    public static let bulbasaurGreen:UIColor = ezColor(r: 203, g: 253, b: 134)
    
    public static let squirtleBlue:UIColor = ezColor(r: 49, g: 181, b: 222)
    
    public static let charmanderRed:UIColor = ezColor(r: 220, g: 148, b: 48)
    
    public static let koffingPurple:UIColor = ezColor(r: 90, g: 54, b: 150)
    
    public static let pikachuYellow:UIColor = ezColor(r: 248, g: 208, b: 48)
    
    public static let normalGrey:UIColor = ezColor(r: 168, g: 168, b: 120)
    
    public static let flyingPurple:UIColor = ezColor(r: 168, g: 144, b: 240)
    
    public static let fightingBrown:UIColor = ezColor(r: 192, g: 48, b: 40)
    
    public static let fairyPink:UIColor = ezColor(r: 238, g: 153, b: 172)
    
    public static let sandshrew:UIColor = ezColor(r: 224, g: 192, b: 104)
    
    public static let gengarPurple:UIColor = ezColor(r: 112, g: 88, b: 152)
    
    public static let caterpieGreen:UIColor = ezColor(r: 168, g: 184, b: 32)
    
    public static let geodude:UIColor = ezColor(r: 168, g: 184, b: 32)
    
    public static let dewgong:UIColor = ezColor(r: 152, g: 216, b: 216)
 
    public static let gyarados:UIColor = ezColor(r: 112, g: 56, b: 248)
    
    public static let steelix:UIColor = ezColor(r: 184, g: 184, b: 208)
    
    public static let mewPink:UIColor = ezColor(r: 248, g: 88, b: 136)
    
    public static let darkType:UIColor = ezColor(r: 112, g: 88, b: 72)

    
}


public enum ElementalType : String, Codable {
    case fire = "fire"
    case water = "water"
    case grass = "grass"
    case electric = "electric"
    case bug = "bug"
    case fairy = "fairy"
    case poison = "poison"
    case flying = "flying"
    case rock = "rock"
    case ground = "ground"
    case normal = "normal"
    case psychic = "psychic"
    case ghost = "ghost"
    case steel = "steel"
    case dark = "dark"
    case dragon = "dragon"
    case ice = "ice"
    
    public func getColors()->(textColor:UIColor,backgroundColor:UIColor){
        
        switch self {
        case .fire:
            return(.white,.charmanderRed)
        case .water:
            return(.white,.squirtleBlue)
        case .grass:
            return(.white,.bulbasaurGreen)
        case .bug:
            return(.white,.caterpieGreen)
        case .psychic:
            return(.white,.mewPink)
        case .dark:
            return(.white,.darkType)
        case .dragon:
            return(.white,.gyarados)
        case .rock:
            return(.white,.geodude)
        case .electric:
            return(.white,.pikachuYellow)
        case .fairy:
            return(.white,.fairyPink)
        case .ghost:
            return(.white,.gengarPurple)
        case .poison:
            return(.white,.koffingPurple)
        case .flying:
            return(.white,.flyingPurple)
        case .ground:
            return(.white,.sandshrew)
        case .ice:
            return(.white,.dewgong)
        case .normal:
            return(.white,.normalGrey)
        case .steel:
            return(.white,.steelix)
    }
    }
}