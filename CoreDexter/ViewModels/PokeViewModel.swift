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

protocol LoadingProtocol{
    func loadingInProgress()
    func loadingDone(_ sender:Any)
}

final class PokeViewModel{
    
    private let pokeModel:PokeLoader
    
    public private(set) var currentPokemon:PokemonViewStruct?
    
    var loadingDelegate:LoadingProtocol?
    
    init(delegate:LoadingProtocol?) {
        
        loadingDelegate = delegate
        
        let initialiser = PokeLoader(APP_REGION)
        pokeModel = initialiser
        
        if(!PokeLoader.datasetCheck()){
            pokeModel.loadData()
            pokeModel.loadDelegate = loadingDelegate
            loadingDelegate?.loadingInProgress()
        } else {
            loadingDelegate?.loadingDone(self)
        }
       
        
        
    }
    
    deinit {
        print("pokeviewmodel deallocated")
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
    
    public func setCurrentPokemonViewStruct(id:NSManagedObjectID){
        
        let detail = pokeModel.getItem(id: id)
        let id = Int(detail.id).digitString()
        let regionId = Int(detail.region_id).digitString()
        let physicalRegion = Generation(rawValue: detail.generation!)
        
        guard let generation = detail.generation, let name = detail.name, let physicalRegionString = physicalRegion?.getRegion().string(), let type1 = detail.type1, let description = detail.initialDesc, let genus = detail.genus else {
            return
        }
        
        let debugString = "\(detail.name ?? "")\nNational Index:\(id)\nRegional Index:\(regionId)\n\(detail.generation ?? "")\n\(physicalRegion?.getRegion().string() ?? "")\n\(detail.type1 ?? "")\n\(detail.type2 ?? "")\n\n\(detail.initialDesc ?? "")"
        
        let returnItem = PokemonViewStruct(name: name, idString: id, regionId: "\(regionId)", description: description, type1: type1, type2: detail.type2, generation: generation, region: physicalRegionString, debugString: debugString, genus: genus, height: Int(detail.height), weight: Int(detail.weight))
        
        //print("returning \(returnItem.genus) \(detail.initialDesc)")
        
        currentPokemon = returnItem
        
    }
    
}


public struct PokemonViewStruct{
    public let name:String
    public let idString:String
    public let regionId:String
    public let description:String
    public let type1:String
    public let type2:String?
    public let generation:String
    public let region:String
    public let debugString:String?
    public let genus:String?
    public let height:Int
    public let weight:Int
}
