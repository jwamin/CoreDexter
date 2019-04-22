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
            return .johto
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
    case johto = 3
    case hoenn = 4
    case sinnoh = 5
    case unova = 8
    case kalos = 12
    case alola
    public func string() -> String{
        switch self {
        case .kanto:
            return "Kanto"
        case .johto:
            return "Johto"
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
        case .johto:
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
        case .johto:
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
    
    class func ezColor(r:CGFloat,g:CGFloat,b:CGFloat)->UIColor{
        
        func decimalize(color:CGFloat)->CGFloat{
            return color/255.0
        }
        
        return UIColor(red: decimalize(color: r), green: decimalize(color: g), blue: decimalize(color: b), alpha: 1.0)
        
    }
    
    public static let basicallyAwfulRed = ezColor(r: 252, g: 5, b: 0)
    
    public static let bulbasaurGreen:UIColor = ezColor(r: 0, g: 153, b: 14)
    
    public static let squirtleBlue:UIColor = ezColor(r: 37, g: 180, b: 224)
    
    public static let charmanderRed:UIColor = ezColor(r: 221, g: 31, b: 0)
    
    public static let koffingPurple:UIColor = ezColor(r: 86, g: 0, b: 107)
    
    public static let pikachuYellow:UIColor = ezColor(r: 248, g: 208, b: 48)
    
    public static let normalGrey:UIColor = ezColor(r: 255, g: 255, b: 255)
    
    public static let flyingPurple:UIColor = ezColor(r: 25, g: 133, b: 158)
    
    public static let fightingBrown:UIColor = ezColor(r: 153, g: 124, b: 97)
    
    public static let fairyPink:UIColor = ezColor(r: 255, g: 141, b: 141)
    
    public static let sandshrew:UIColor = ezColor(r: 178, g: 97, b: 0)
    
    public static let gengarPurple:UIColor = ezColor(r: 47, g: 0, b: 58)
    
    public static let caterpieGreen:UIColor = ezColor(r: 144, g: 214, b: 145)
    
    public static let geodude:UIColor = ezColor(r: 61, g: 33, b: 1)
    
    public static let dewgong:UIColor = ezColor(r: 145, g: 219, b: 237)
 
    public static let gyarados:UIColor = ezColor(r: 112, g: 56, b: 248)
    
    public static let steelix:UIColor = ezColor(r: 155, g: 155, b: 155)
    
    public static let mewPink:UIColor = ezColor(r: 168, g: 0, b: 168)
    
    public static let darkType:UIColor = ezColor(r: 24, g: 27, b: 28)

    //Gavin
    
    public static let lightBlue:UIColor = ezColor(r: 211, g: 240, b: 249)
    
}


public enum ElementalType : String, Codable, CaseIterable {
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
    
    public static func rawStrings() -> [String]{
        
         return ElementalType.allCases.map{ element in
            element.rawValue
        }
        
    }
    
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
            return(.black,.normalGrey)
        case .steel:
            return(.white,.steelix)
    }
    }
}
