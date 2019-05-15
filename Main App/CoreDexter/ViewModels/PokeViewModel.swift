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
    

    private let pokeDataLoader:PokeDataLoader
    
    public private(set) var currentImageData:Data?
    
    var loadingDelegate:LoadingProtocol?
    
    public private(set) var currentPokemon:PokemonViewStruct? {
        didSet{
            guard let curdata = currentPokemon else {
                return
            }
            
            self.getImageforID(id: curdata.dataID) { (image) in
                self.currentImageData = image.pngData()
            }
            
            loadingDelegate?.loadingDone(self)
            
        }
    }
    
    public var pokemonARModel:PokeARModel{
        get{
            guard let currentPokemon = currentPokemon, let imageData = currentImageData else {
                fatalError()
            }
            return PokeARModel(number: currentPokemon.idString, name: currentPokemon.name, spriteData: imageData, height: currentPokemon.height)
        }
    }
    
    

    
    init(delegate:LoadingProtocol?) {
        
        loadingDelegate = delegate
        
        let initialiser = PokeDataLoader(APP_REGION)
        pokeDataLoader = initialiser
        
        if(!PokeDataLoader.datasetCheck()){
            pokeDataLoader.loadData()
            pokeDataLoader.loadDelegate = loadingDelegate
            loadingDelegate?.loadingInProgress()
        } else {
            loadingDelegate?.loadingDone(self)
        }
        
    }
    
    deinit {
        print("pokeviewmodel deallocated")
    }
    
    //MARK: Current View Model
    
    public func setCurrentPokemonViewStruct(id:NSManagedObjectID){
        
        let detail = pokeDataLoader.getItem(id: id)
        
        let idNumber = Int(detail.id).digitString()
        let regionId = Int(detail.region_id).digitString()
        let physicalRegion = Generation(rawValue: detail.generation!)
        
        guard let generation = detail.generation, let name = detail.name, let physicalRegionString = physicalRegion?.getRegion().string(), let type1 = detail.type1, let description = detail.initialDesc, let genus = detail.genus else {
            return
        }
        
        let debugString = "\(detail.name ?? "")\nNational Index:\(idNumber)\nRegional Index:\(regionId)\n\(detail.generation ?? "")\n\(physicalRegion?.getRegion().string() ?? "")\n\(detail.type1 ?? "")\n\(detail.type2 ?? "")\n\n\(detail.initialDesc ?? "")"
        
        let returnItem = PokemonViewStruct(dataID: id, isFavourite:detail.favourite, name: name,  idString: idNumber, regionId: "\(regionId)", description: description, type1: type1, type2: detail.type2, generation: generation, region: physicalRegionString, debugString: debugString, genus: genus, height: Int(detail.height), weight: Int(detail.weight))
        
        //print("returning \(returnItem.genus) \(detail.initialDesc)")
        
        currentPokemon = returnItem
        
    }
    
    
    //MARK: Favourites
    
    public func updateFavouriteForPokemon(id:NSManagedObjectID?,callback:((_ id:NSManagedObjectID,_ favourite:Bool)->Void)?){
 
        let workingID:NSManagedObjectID
        
        if let id = id {
            workingID = id
        } else {
            workingID = currentPokemon!.dataID
        }
        
        pokeDataLoader.updateFavourite(id: workingID) { (returnedID, isFavourite) in
            if(self.currentPokemon?.dataID == workingID){
                print("updating current pokemon")
                self.currentPokemon?.isFavourite = isFavourite
        } else {
            callback?(returnedID,isFavourite)
        }
        }
        
    }
    
    //MARK: Images
    
    public func getImageforID(id:NSManagedObjectID, callback:@escaping ((UIImage)->())) -> URLSessionDataTask?{
        
        let poke = pokeDataLoader.managedObjectContext.object(with: id) as! Pokemon
        
        let maybeRequest:URLSessionDataTask?
        
        //get image from model
        maybeRequest = pokeDataLoader.getImage(item: poke) { [weak poke] (img, filename) in

            
            if(poke != nil && filename != nil && poke!.front_sprite_filename == nil){
                poke!.front_sprite_filename = filename
                print("updated managedObject")
            }
            
                callback(img)
            
        }
        
        return maybeRequest
        
    }
    
    //MARK: Reset Delegate
    
    public func assignDelegate(delegate:ResetProtocol){
        pokeDataLoader.delegate = delegate
    }
    
    public func resetDelegate(){
        pokeDataLoader.delegate = nil
    }
    
}


public struct PokemonViewStruct{
    public let dataID:NSManagedObjectID
    public var isFavourite:Bool
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
