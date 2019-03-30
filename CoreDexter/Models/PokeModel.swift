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
import PokeAPIKit

struct PokeData {
    let name:String
    let region:String
    let generation:String
    let index:String
    let nationalIndex:String
    var type1:String?
    var type2:String?
    var description:String?
}

// MARK: - Protocol

protocol ResetProtocol {
    func resetDone()
}

// MARK: - Model

class PokeModel{

    let region:RegionIndex
    var delegate:ResetProtocol?
    var dispatchGroup:DispatchGroup!
    var pokeArray:[PokeData] = []
    
    weak var managedObjectContext:NSManagedObjectContext!
    
    init(_ injectedRegion:RegionIndex){
        
            region = injectedRegion
            print("initialised")
        
    }
    
    func getItem(id:NSManagedObjectID)->Pokemon{
        return managedObjectContext.object(with: id) as! Pokemon
    }
    
    func checkAndLoadData(){
        
        if(datasetCheck()){
            return
        }
        
        dispatchGroup = DispatchGroup()
        
        print("no pokedata, reloading from PokeAPI")
        returnTask()?.resume()
        
        dispatchGroup.notify(queue: .main) {
            print("loaded",self.pokeArray.first)
            print(self.pokeArray.count)
            self.coreDataProcess()
        }
        
    }
    
    private func coreDataProcess(){
        guard let context = self.managedObjectContext else{
            return
        }
        
        //create region object
        let region = Region(context: context)
        // do this. loop through and find regions. if region exists, add pokemon, if not, create region and add pokemon
        //print(pokeArray)
        //loop through pokemenz
        for pokemen in pokeArray{
            
            let pokemon = Pokemon(context: context)
            pokemon.name = pokemen.name
            pokemon.generation = pokemen.generation
            pokemon.region = region
            pokemon.id = Int16(pokemen.nationalIndex)!
            pokemon.region_id = Int16(pokemen.index)!
            pokemon.type1 = pokemen.type1 ?? nil
            pokemon.type2 = pokemen.type2 ?? nil
            pokemon.initialDesc = pokemen.description ?? ""
            
            //add as set to region
            region.pokemon?.adding(pokemon)
            
        }
        
        //commit to cd
        do {
            try context.save()
            print("context saved")
            delegate?.resetDone()
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
        
        let regionFetch:NSFetchRequest<Region> = Region.fetchRequest()
        var regionList:[Region] = []
        do {
            regionList = try context.fetch(regionFetch) as [Region]
        } catch {
            fatalError()
        }
        
        guard let kanto = regionList.first, let pokemon = kanto.pokemon else {
            return false
        }
        
        if(pokemon.count>0){
            
            return true
            
        }
        
        //check coredata for region and check region has pokemon objects
        return false
        
    }
    
    func returnTask() -> URLSessionDataTask?{
        
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokedex/"+String(region.rawValue)) else {
            return nil
        }
        
        self.dispatchGroup.enter()
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if(error != nil){
                fatalError()
            }
            print("inside return callback")
            guard let data = data else {
                fatalError("no data")
            }

            let decoder = JSONDecoder()
            
            var pokedex:Pokedex
            
            do{
                pokedex = try decoder.decode(Pokedex.self, from: data)
            } catch {
                fatalError(error.localizedDescription)
            }
            
            let pokeDict = pokedex.pokemon_entries
            self.pokeArray = []
            
            for poke in pokeDict{
                let regionNumber = poke.entry_number
                let urlString = poke.pokemon_species.url.absoluteString
                self.getSpeciesDataforPokemon(urlString: urlString,regionIndex:regionNumber)
            }
            

            
             self.dispatchGroup.leave()
            
            })
        return task
    }
    
    private func getSpeciesDataforPokemon(urlString:String,regionIndex:Int){
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        self.dispatchGroup.enter()
        
        URLSession.shared.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            if (error != nil){
                print(error?.localizedDescription, "\(regionIndex) dropped from species info, retrying..")
                self.getSpeciesDataforPokemon(urlString: urlString, regionIndex: regionIndex)
                //self.dispatchGroup.leave()
                return
            }
            
            guard let data = data else {
                return
            }
            
            let speciesInfo:Species
            let decoder = JSONDecoder()
            
            do {
                speciesInfo = try decoder.decode(Species.self, from: data)
            } catch {
                fatalError(error.localizedDescription)
            }
            
            let name = speciesInfo.name
            let number = String(speciesInfo.id)
            let generation = speciesInfo.generation.name
            let region = self.region.string()
            
            print(region)
            
            //let message = speciesInfo.flavor_text_entries[speciesInfo.flavor_text_entries.count-1].flavor_text
            var message:String = ""
            
            for entry in speciesInfo.flavor_text_entries{
                if(entry.language.name=="en"){
                    message = entry.flavor_text
                    break
                }
            }
            
            let poke = PokeData(name: name, region: region, generation: generation, index: String(regionIndex), nationalIndex: number, type1: nil, type2: nil, description: message)
            self.pokeArray.append(poke)
            //print(poke)
            print(regionIndex)
            //process pokedata and
            self.getDataforPokemon(regionIndex: regionIndex)
            
            
            
            
        }).resume()
        
        
    }
    
    
    private func getDataforPokemon(regionIndex:Int){
        
        let urlString = "https://pokeapi.co/api/v2/pokemon/"+String(regionIndex)
        
        guard let url = URL(string: urlString) else {
            return
        }
        URLSession.shared.dataTask(with: url, completionHandler: {
            [unowned self] (data, response, error) in
            
            if (error != nil){
                print(error?.localizedDescription, "\(regionIndex) dropped from deep pokemon info, retrying...")
                self.getDataforPokemon(regionIndex: regionIndex)
                //self.dispatchGroup.leave()
                return
            }
            
            guard let data = data else {
                return
            }
            
            let decoder = JSONDecoder()
            let pokemon:PokemonStruct
            do {
                pokemon = try decoder.decode(PokemonStruct.self, from: data)
            } catch {
                fatalError(error.localizedDescription)
            }
            
            var thisPokeIndex = 0
            
            for (index, poke) in self.pokeArray.enumerated(){
                if(poke.index == String(regionIndex)){
                    thisPokeIndex = index
                    break
                }
            }
            
            let typesarray = pokemon.types
            
            for type in typesarray{
                
                //err not so sure about this?
                switch type.slot{
                case 1:
                    self.pokeArray[thisPokeIndex].type1 = type.type.name
                case 2:
                    self.pokeArray[thisPokeIndex].type2 = type.type.name
                default:
                    continue
                }
                
            }

            
            //process pokedata and
            self.dispatchGroup.leave()
            //..the dispatch group
            
            
            
        }).resume()
        
        
    }
    

    
    public func getImage(item:Pokemon,callback:((_ img:UIImage,_ filePath:String?)->Void)?){
        
        if let sprite_filename = item.front_sprite_filename{
            
            DispatchQueue.global().async {
            
            let filepaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            if let dirpath = filepaths.first{
                let imageurl = URL(fileURLWithPath: dirpath).appendingPathComponent(sprite_filename)
                
                var boolPointer = ObjCBool(booleanLiteral: false)
                
                if (FileManager.default.fileExists(atPath: imageurl.path, isDirectory: &boolPointer)){
                    print("using existing file")
                    guard let img = UIImage(contentsOfFile: imageurl.path) else {
                        return
                    }
                    
                    guard let callback = callback else {
                        print("no callback, so pointless")
                        return
                    }
                    
                    callback(img,nil)
                    print("loading cell image", imageurl.path)
                    return
                
                    
                }
                print("file doesnt exist \(item.front_sprite_filename!)")
                return
            }
            print("no callback, so pointless")
            return
            }
        } else {
            print("no filename, will load",item.id)
           loadImage(item: item, callback: callback,nil)
        }
        
       
}

    public func loadImage(item:Pokemon,callback:((_ img:UIImage,_ filePath:String?)->Void)?,_ secondaryCallback:(()->Void)?){
    
        DispatchQueue.global().async {
            guard let url = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/"+String(item.id)+".png") else {
                return
            }
            URLSession.shared.dataTask(with: url, completionHandler: {
                (data, response, error) in
                
                if (error != nil){
                    print(error?.localizedDescription)
                    self.dispatchGroup.leave()
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
                        
                        if let secondaryCallback = secondaryCallback{
                            secondaryCallback()
                        }
                        
                        
                        print("getting image from github success!",item.id)
                        
                        
                    } catch {
                        print("write failed")
                    }
                    
                } catch {
                    print("error")
                }
                
                
            }).resume()
        }
    }
        
        
    }


