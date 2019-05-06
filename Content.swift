//
//  Content.swift
//  CoreDexter
//
//  Created by Joss Manger on 5/2/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import Foundation
import CoreText

var plist:NSDictionary? = {
    if  let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
        let xml = FileManager.default.contents(atPath: path)
    {
        return (try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil)) as? NSDictionary
    }
    return nil
}()

enum TextStyle{
    case title
    case subtitle
    case body
    case small
    case copy
}

let attributed:NSAttributedString = {

    let attrString = NSMutableAttributedString(string: "I/O By Joss Manger \n\n @github/jwamin", attributes:nil)
    attrString.addAttributes([NSAttributedString.Key.link:githubURL], range: NSRange(22...attrString.length-1))
    
    return NSAttributedString(attributedString: attrString)
}()

let messages:[[String:TextStyle]] = [
    ["\(plist!.object(forKey: "CFBundleName")!)":.title],
    ["The CoreData Pokedex with AR sprite camera":.subtitle],
        ["v.\(plist!.object(forKey: "CFBundleShortVersionString")!) (\(plist!.object(forKey: "CFBundleVersion")!))":.small],
    [attributed.string:.subtitle],
    ["Design consultation by Gavin Buckland":.body],
    ["Data and sprites from PokeAPI.co":.body],
    ["Cries from Pokeshowdown, requested on an ad-hoc basis":.body],
    ["fonts by Google Fonts":.body],
    ["All Characters, names and content and are ©Nintendo and affiliates.":.body],
    ["Data, sprites and other assets are freely available online and are intended as fair use.\n This app is a personal fan project built for educational purposes. It generates no revenue.":.small],
    ["Produced by JM in 2019":.small]
]

let githubURL:URL = URL(string: "https://github.com/jwamin")!



