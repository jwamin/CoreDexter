//
//  Settings.swift
//  ARHitTest
//
//  Created by Joss Manger on 4/9/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import PokeAPIKit
import SceneKit

let POKE_PLAIN_CATEGORY_BIT_MASK = 34 // random int
let pokeDefaultPlainDimension:CGFloat = 0.3 //meters

extension float4x4 {

var translation: float3 {
    get {
        let translation = columns.3
        return float3(translation.x, translation.y, translation.z)
    }
    set(newValue) {
        columns.3 = float4(newValue.x, newValue.y, newValue.z, columns.3.w)
    }
}

}
