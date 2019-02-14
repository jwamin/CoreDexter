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
    let nationalIndex:String
    var type1:String?
    var type2:String?
    var description:String?
}

protocol ResetProtocol {
    func resetDone()
}

class PokeModel{

    let region:RegionIndex
    var delegate:ResetProtocol?
    let dispatchGroup = DispatchGroup.init()
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
        
        print("no pokedata")
        returnTask()?.resume()
        
        dispatchGroup.notify(queue: .main) {
            print("loaded",self.pokeArray.first!)
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
            self.pokeArray = []
            for (index,poke) in pokeDict.enumerated(){
                let pokeAny = poke as! [String:Any]
                let speciesInfo = pokeAny["pokemon_species"] as! [String:String]
                let regionNumber = index+1
                if let urlString = speciesInfo["url"]{
                    self.getSpeciesDataforPokemon(urlString: urlString,regionIndex:regionNumber)
                }
            }
            

                self.dispatchGroup.leave()
            
            
            })
        return task
    }
    
    private func getDataforPokemon(regionIndex:Int){
        
        let urlString = "https://pokeapi.co/api/v2/pokemon/"+String(regionIndex)
        
        guard let url = URL(string: urlString) else {
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
            
            let pokeDict:[String:Any]
            do{
                pokeDict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]
            } catch {
                print(error.localizedDescription)
                self.dispatchGroup.leave()
                return
            }
            //print(pokeDict)
            
            var thisPokeIndex = 0
            
            for (index, poke) in self.pokeArray.enumerated(){
                if(poke.index == String(regionIndex)){
                    thisPokeIndex = index
                    break
                }
            }
            
            let typesarray = pokeDict["types"] as! [[String:Any]]
            
            for type in typesarray{
                let stringDict = type as! [String:Any]
               
                switch stringDict["slot"] as! Int{
                case 1:
                    self.pokeArray[thisPokeIndex].type1 = (stringDict["type"] as! [String:String])["name"]!
                case 2:
                    self.pokeArray[thisPokeIndex].type2 = (stringDict["type"] as! [String:String])["name"]!
                default:
                    continue
                }
            }
            //print(self.pokeArray[thisPokeIndex])
            
            //print(poke)
            
            //process pokedata and
            self.dispatchGroup.leave()
            
            
            
            
        }).resume()
        
        
    }
    
    private func getSpeciesDataforPokemon(urlString:String,regionIndex:Int){
        
        dispatchGroup.enter()
        
        guard let url = URL(string: urlString) else {
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
            
            let pokeDict:[String:Any]
            do{
                pokeDict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]
            } catch {
                fatalError()
            }
            //print(pokeDict)
            let name = pokeDict["name"] as! String
            let number = String(pokeDict["id"] as! Int)
            let generationDict = pokeDict["generation"] as! [String:String]
            let generation = generationDict["name"] ?? ""
            let region = self.region.string()
            let textEntriesDict = pokeDict["flavor_text_entries"] as! [[String:Any]]
            let message = textEntriesDict[textEntriesDict.count-1]["flavor_text"] as! String
            let poke = PokeData(name: name, region: region, generation: generation, index: String(regionIndex), nationalIndex: number, type1: nil, type2: nil, description: message)
            self.pokeArray.append(poke)
            //print(poke)
            
            //process pokedata and
            self.getDataforPokemon(regionIndex: regionIndex)
            
            
  
            
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
                print("file doesnt exist",item.front_sprite_filename)
                return
            }
            print("no callback, so pointless")
            return
            }
        } else {
            print("no filename, will load",item.id)
           loadImage(item: item, callback: callback)
        }
        
       
}

    private func loadImage(item:Pokemon,callback:((_ img:UIImage,_ filePath:String?)->Void)?){
    
        DispatchQueue.global().async {
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


