//
//  InitialiserModel.swift
//  CoreDexter
//
//  Created by Joss Manger on 1/30/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit
import Foundation
import CoreData

struct PokeData {
    let name:String
    let region:String
    let generation:String
    let index:String
}

class Initialiser{
    
    let max = 151
    

    let dispatchGroup = DispatchGroup.init()
    var pokeArray:[PokeData] = [] {
        didSet{
            print("done.. updated")
            print(pokeArray)
        }
    }
    
    weak var managedObjectContext:NSManagedObjectContext!
    
    init(){
     
            print("initialised")

        
    }
    
    func checkAndLoadData(){
        
        if(datasetCheck()){
            return
        }
        
        print("no pokedata")
        returnTask()?.resume()
        
        dispatchGroup.notify(queue: .main) {
            print("loaded")
            self.coreDataProcess()
        }
        
    }
    
    private func coreDataProcess(){
        guard let context = self.managedObjectContext else{
            return
        }
        
        let regionName = "Kanto"
        
        let regionFetch:NSFetchRequest<Region> = Region.fetchRequest()
        let predicate = NSPredicate(format: "name == %@", regionName)
        regionFetch.predicate = predicate
        var regionList:[Region] = []
        do {
            regionList = try context.fetch(regionFetch) as [Region]
            print(regionList)
            print("hello")
        } catch {
            fatalError()
        }
        
        var region:Region
        
        if(regionList.count == 0){
            print("creating new region")
            region = Region(context: context)
            region.name = regionName
        } else {
            region = regionList[0]
            print("using existing region")
        }
        
        let newPokemon = Pokemon(context: context)
        newPokemon.generation = "gen1"
        newPokemon.name = "bulbasaur"
        newPokemon.region = region
        
        newPokemon.id = 1
        newPokemon.initialDesc = "cool initial description for poke"
        newPokemon.type1 = "grass"
        newPokemon.type2 = ""
        
        // If appropriate, configure the new managed object.
        //newPokemon.timestamp = Date()
        
        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    private func datasetCheck()->Bool{
        
        guard let context = self.managedObjectContext else {
            print("no context")
            return false
        }
        
        let regionName = "Kanto"
        
        let regionFetch:NSFetchRequest<Region> = Region.fetchRequest()
        var regionList:[Region] = []
        do {
            regionList = try context.fetch(regionFetch) as [Region]
        } catch {
            fatalError()
        }
        
        //first region
        let isKanto = regionList.first
        
        guard let kanto = isKanto, let pokemon = isKanto?.pokemon else {
            return false
        }
        
        if(pokemon.count>0){
            
            print(pokemon)
            
            return true
            
        }
        
        //check coredata for region and check region has pokemon objects
        return true
        
    }
    
    func returnTask() -> URLSessionDataTask?{
        
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokedex/2") else {
            return nil
        }
        self.dispatchGroup.enter()
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if(error != nil){
                fatalError()
            }
            
            guard let data = data else {
                fatalError("no data")
            }
            
            //let dexString = String(bytes: data, encoding: .utf8)!
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
                print("about to print pokeany")
                print(pokeAny)
                let speciesInfo = pokeAny["pokemon_species"] as! [String:String]
                let name = speciesInfo["name"]
                let number = String(pokeAny["entry_number"] as! Int)
                let generation = "generation-i"
                let region = dexDict["name"] as! String
                let poke = PokeData(name: name!, region: region, generation: generation, index: number)
                pokies.append(poke)
            }
            
            
            
            DispatchQueue.main.async {
                self.pokeArray = pokies
                self.dispatchGroup.leave()
            }
            
            
            
            
            })
        return task
    }
    
}
