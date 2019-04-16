//
//  Settings.swift
//  CoreDexter
//
//  Created by Joss Manger on 2/6/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import Foundation
import PokeAPIKit

let setRegion:RegionIndex? = {
    if let string = UserDefaults.standard.value(forKey: "region") as? String, let inte = Int(string){
        return RegionIndex(rawValue: inte)
    }
   return nil
}()

let APP_REGION:RegionIndex = (setRegion != nil) ? setRegion! : .national

let criesBaseUrl = "https://play.pokemonshowdown.com/audio/cries/"

let criesUrlSuffix = ".mp3"
