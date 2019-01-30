//
//  InitialiserModel.swift
//  CoreDexter
//
//  Created by Joss Manger on 1/30/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit
import Foundation

struct PokeData {
    let name:String
    let region:String
    let generation:String
    let index:String
}

class Initialiser{
    
    let max = 151
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let dispatchGroup = DispatchGroup.init()
    var pokeArray:[PokeData] = []
    init(){
        print(delegate)
        
        
        
    }
    
    func returnTask(index:Int) -> URLSessionDataTask?{
        
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokedex/2") else {
            return nil
        }
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                
            if(error != nil){
                fatalError()
            }
            
            guard let data = data else {
                fatalError("no data")
            }
            
            let dexString = String(bytes: data, encoding: .utf8)!
            let dexDict:[String:Any]
            do{
            dexDict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]
            } catch {
                fatalError()
            }
            
            let pokeDict = dexDict["pokemon_entries"] as! [Any]
            var pokies:[PokeData] = []
            for poke in pokeDict{
                let pokeAny = poke as! [String:Any]
                let name = "whaaa"
                let number = String(index)
                let generation = "generation-i"
                let region = dexDict["name"] as! String
                let poke = PokeData(name: name, region: region, generation: generation, index: number)
                pokies.append(poke)
            }
            
            
            
            DispatchQueue.main.async {
                self.pokeArray = pokies
            }
            
            
            self.dispatchGroup.leave()
            
            })
        return task
    }
    
}
