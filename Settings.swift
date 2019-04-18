//
//  Settings.swift
//  CoreDexter
//
//  Created by Joss Manger on 2/6/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit
import PokeAPIKit

fileprivate let font = UIFont(name: "MajorMonoDisplay-Regular", size: UIFont.labelFontSize)
fileprivate let bodyfont = UIFont(name: "Rubik-Light", size: UIFont.systemFontSize)

var headingFont:()->UIFont = {
    guard let font = font else {
        fatalError()
    }
    return UIFontMetrics(forTextStyle: .headline).scaledFont(for:font)
}

var bodyFont:()->UIFont = {
    guard let bodyfont = bodyfont else {
        fatalError()
    }
    return UIFontMetrics(forTextStyle: .body).scaledFont(for:bodyfont)
}

let setRegion:RegionIndex? = {
    if let string = UserDefaults.standard.value(forKey: "region") as? String, let inte = Int(string){
        return RegionIndex(rawValue: inte)
    }
   return nil
}()

let APP_REGION:RegionIndex = (setRegion != nil) ? setRegion! : .national

let criesBaseUrl = "https://play.pokemonshowdown.com/audio/cries/"

let criesUrlSuffix = ".mp3"

let lorem = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Nunc id cursus metus aliquam eleifend mi in nulla posuere. Tristique sollicitudin nibh sit amet. Pellentesque diam volutpat commodo sed egestas egestas fringilla. Diam sollicitudin tempor id eu nisl nunc mi ipsum faucibus. Egestas sed tempus urna et pharetra pharetra massa massa. Condimentum id venenatis a condimentum vitae sapien pellentesque. Ante in nibh mauris cursus mattis. Porttitor lacus luctus accumsan tortor posuere ac ut consequat semper. Velit sed ullamcorper morbi tincidunt ornare massa eget egestas. Enim lobortis scelerisque fermentum dui. Amet justo donec enim diam vulputate ut. Vel facilisis volutpat est velit egestas dui id ornare. Pellentesque diam volutpat commodo sed egestas egestas fringilla phasellus faucibus. Amet mattis vulputate enim nulla aliquet porttitor lacus.

Curabitur gravida arcu ac tortor dignissim. Habitant morbi tristique senectus et netus et malesuada fames ac. Nulla facilisi etiam dignissim diam quis enim lobortis scelerisque. Consectetur adipiscing elit duis tristique sollicitudin. Nunc sed velit dignissim sodales ut eu sem integer vitae. Id nibh tortor id aliquet. Scelerisque eleifend donec pretium vulputate sapien nec. Lectus vestibulum mattis ullamcorper velit sed ullamcorper morbi tincidunt ornare. Faucibus interdum posuere lorem ipsum dolor. Amet consectetur adipiscing elit pellentesque. In egestas erat imperdiet sed euismod nisi. Aliquet risus feugiat in ante metus dictum. Pellentesque eu tincidunt tortor aliquam nulla facilisi. Amet purus gravida quis blandit. Risus ultricies tristique nulla aliquet enim tortor. Nisi lacus sed viverra tellus in hac. Maecenas ultricies mi eget mauris pharetra et ultrices neque.

Aenean sed adipiscing diam donec adipiscing tristique risus nec feugiat. Massa placerat duis ultricies lacus sed turpis tincidunt id aliquet. Lobortis mattis aliquam faucibus purus in massa tempor nec feugiat. Et leo duis ut diam quam nulla. Vitae proin sagittis nisl rhoncus mattis rhoncus urna neque. Diam vel quam elementum pulvinar. Eget egestas purus viverra accumsan in nisl. Vel turpis nunc eget lorem. Urna duis convallis convallis tellus id interdum. Pellentesque adipiscing commodo elit at imperdiet dui. Iaculis at erat pellentesque adipiscing. Iaculis eu non diam phasellus. Netus et malesuada fames ac turpis egestas integer eget. Sit amet consectetur adipiscing elit ut. Et egestas quis ipsum suspendisse ultrices gravida dictum. Amet purus gravida quis blandit turpis cursus in hac.

Elit ullamcorper dignissim cras tincidunt lobortis feugiat vivamus at augue. Volutpat est velit egestas dui id ornare arcu odio ut. Morbi tristique senectus et netus et malesuada. In cursus turpis massa tincidunt dui ut ornare lectus. Imperdiet sed euismod nisi porta. Convallis convallis tellus id interdum velit laoreet id donec. Aenean et tortor at risus viverra adipiscing at in tellus. Eu non diam phasellus vestibulum lorem sed risus. Convallis posuere morbi leo urna molestie at. Nulla pharetra diam sit amet nisl suscipit adipiscing. Erat pellentesque adipiscing commodo elit. Venenatis cras sed felis eget. Diam phasellus vestibulum lorem sed. Tortor aliquam nulla facilisi cras fermentum odio eu.

Cum sociis natoque penatibus et magnis dis parturient montes nascetur. Quis viverra nibh cras pulvinar mattis nunc sed. Faucibus et molestie ac feugiat. Magna ac placerat vestibulum lectus mauris. Ipsum dolor sit amet consectetur adipiscing elit. Morbi tristique senectus et netus et malesuada fames ac. Sit amet risus nullam eget felis eget nunc lobortis mattis. Diam sollicitudin tempor id eu nisl nunc mi ipsum. Sit amet porttitor eget dolor morbi non arcu risus. Sit amet purus gravida quis blandit. Facilisi morbi tempus iaculis urna id volutpat lacus. Feugiat scelerisque varius morbi enim.
"""
