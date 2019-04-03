//
//  PokemonViewModel.swift
//  CoreDexter
//
//  Created by Joss Manger on 2/6/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import PokeAPIKit

final class PokeViewModel{
    
    private let pokeModel:PokeModel
    
    init(dependency:PokeModel) {
        pokeModel = dependency
    }
    
    public func getImageforID(id:NSManagedObjectID, callback:@escaping ((UIImage)->())){
        
        let poke = pokeModel.managedObjectContext.object(with: id) as! Pokemon
        
        //get image from model
        pokeModel.getImage(item: poke) { [weak poke] (img, filename) in

            
            if(poke != nil && filename != nil && poke!.front_sprite_filename == nil){
                poke!.front_sprite_filename = filename
            }
            
                callback(img)
  
            
        }
        
    }
    
    public func assignDelegate(delegate:ResetProtocol){
        pokeModel.delegate = delegate
    }
    
    public func resetDelegate(){
        pokeModel.delegate = nil
    }
    
    public func pokemonViewModel(id:NSManagedObjectID)->PokemonViewStruct?{
        
        let detail = pokeModel.getItem(id: id)
        let id = Int(detail.id).digitString()
        let regionId = Int(detail.region_id).digitString()
        let physicalRegion = Generation(rawValue: detail.generation!)
        
        guard let generation = detail.generation, let name = detail.name, let physicalRegionString = physicalRegion?.getRegion().string(), let type1 = detail.type1, let description = detail.initialDesc else {
            return nil
        }
        
        let debugString = "\(detail.name ?? "")\nNational Index:\(id)\nRegional Index:\(regionId)\n\(detail.generation ?? "")\n\(physicalRegion?.getRegion().string() ?? "")\n\(detail.type1 ?? "")\n\(detail.type2 ?? "")\n\n\(detail.initialDesc ?? "")"
        
        let returnItem = PokemonViewStruct(name: name, idString: id, regionId: "\(regionId)", description: description, type1: type1, type2: detail.type2, generation: generation, region: physicalRegionString, debugString: debugString)
        
        print("returning \(returnItem)")
        
        return returnItem
        
    }
    
}


struct PokemonViewStruct{
    let name:String
    let idString:String
    let regionId:String
    let description:String
    let type1:String
    let type2:String?
    let generation:String
    let region:String
    let debugString:String?
}
