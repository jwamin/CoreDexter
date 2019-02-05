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
        
        //create region object
        let region = Region(context: context)
        
        
        //loop through pokemenz
        for pokemen in pokeArray{
            
            let pokemon = Pokemon(context: context)
            pokemon.name = pokemen.name
            pokemon.generation = pokemen.generation
            pokemon.region = region
            pokemon.id = Int16(pokemen.index)!
            
            //getImage(id: pokemon.objectID)
            
            //add as set to region
            region.pokemon?.adding(pokemon)
            
        }
        
        
        
        //commit to cd
        
        
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
                let speciesInfo = pokeAny["pokemon_species"] as! [String:String]
                let name = speciesInfo["name"]
                let number = String(pokeAny["entry_number"] as! Int)
                let generation = ""
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
    
    
    public func getImage(item:Pokemon,callback:((_ img:UIImage,_ filePath:String)->Void)?){
        
        guard let url = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/"+String(item.id)+".png") else {
            return
        }
        URLSession.shared.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            if (error != nil){
                print("err")
                return
            }
            
            guard let data = data else {
                return
            }
            
            
            let fileManager = FileManager.default
            do{
                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                let filename = "\(Int(item.id).digitString()).png"
                let fileURL = documentDirectory.appendingPathComponent(filename)
                
                guard let image = UIImage(data: data) else {
                    return
                }
                
                do{
                    
                    guard let imgdata = image.pngData() else {
                        return
                    }
                    
                    try imgdata.write(to: fileURL)
                    
                    
                    if let callback = callback{
                        callback(image,filename)
                    }
                    
                    
                    print("success!")
                    
                    
                } catch {
                    print("write failed")
                }
                
            } catch {
                print("error")
            }
            
            
            
            //                guard let imgdata = item.front_sprite, let img = UIImage(data: imgdata) else {
            //                    return
            //                }
            //
            //
            //                DispatchQueue.main.async {
            //
            //                    guard let cell = self.tableView.cellForRow(at: indexpath) as? PokeCellTableViewCell else {
            //                        return
            //                    }
            //
            //                    print("distpatching main with image \(indexpath)")
            //                     cell.imgview.image = img
            //                }
            
            
            
        }).resume()
    }
    
    func saveChanges(){
        if(self.managedObjectContext.hasChanges){
            do{
                try self.managedObjectContext.save()
                print("saved on scroll end")
            } catch {
                print("no worky")
            }
        }
    }
    
}
