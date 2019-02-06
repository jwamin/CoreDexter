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

final class PokeViewModel{
    
    let pokeModel:PokeModel
    
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
    
    public func pokemonLabelString(id:NSManagedObjectID)->String{
        let detail = pokeModel.getItem(id: id)
        let id = Int(detail.id).digitString()
        let regionId = Int(detail.region_id).digitString()
        return "\(detail.name ?? "")\nNational Index:\(id)\nRegional Index:\(regionId)\n\(detail.generation ?? "")\n\(detail.region!.name ?? "")\n\(detail.type1 ?? "")\n\(detail.initialDesc ?? "")"
    }
    
}
