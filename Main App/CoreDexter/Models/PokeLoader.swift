//
//  InitialiserModel.swift
//  CoreDexter
//
//  Created by Joss Manger on 1/30/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

//import UIKit
import UIKit
import CoreData
import PokeAPIKit

struct PokeData {
    let name:String
    let region:String
    let generation:String
    let index:String
    var regionIndex:String = ""
    let nationalIndex:String
    var type1:String?
    var type2:String?
    var description:String?
    var genus:String?
    var height:Int
    var weight:Int
}

// MARK: - Protocol

protocol ResetProtocol {
    func resetDone()
}

// MARK: - Model

class PokeLoader{

    let region:RegionIndex
    var delegate:ResetProtocol?
    var loadDelegate:LoadingProtocol?
    var dispatchGroup:DispatchGroup!
    var pokeArray:[PokeData] = []
    var appDelegate:AppDelegate!
    
    weak var managedObjectContext:NSManagedObjectContext!
    
    init(_ injectedRegion:RegionIndex,_ appDelegate:AppDelegate?){
        
            region = injectedRegion
            self.appDelegate = appDelegate ?? (UIApplication.shared.delegate as! AppDelegate)
            managedObjectContext = self.appDelegate.persistentContainer.viewContext
            print("initialised")
        
    }
    
    convenience init(_ injectedRegion:RegionIndex){
        self.init(injectedRegion, nil)
    }
    
    deinit {
        print("pokemodel deinitialised")
    }
    
    func getItem(id:NSManagedObjectID)->Pokemon{
        return managedObjectContext.object(with: id) as! Pokemon
    }
    
    func loadData(){
        
        dispatchGroup = DispatchGroup()
        
        print("no pokedata, reloading from PokeAPI")
        getPokedex()?.resume()
        
        dispatchGroup.notify(queue: .main) {
            print("loaded",self.pokeArray.first)
            print(self.pokeArray.count)
            self.coreDataProcess()
        }
        
    }
    
    private func getOrGenerateNextRegion(generation:String)->Region{
        guard let regionEnum = Generation(rawValue: generation), let context = self.managedObjectContext else {
            fatalError()
        }
        
        let name = regionEnum.getRegion().string()
        
        let predicate = NSPredicate(format: "name==%@", argumentArray: [name])
        let fetchRequest = NSFetchRequest<Region>(entityName: "Region")
        fetchRequest.predicate = predicate
        do{
            let result = try context.fetch(fetchRequest)
            print("number of \(name) regions now \(result.count)")
            if let gotRegion = result.first {
                
                return gotRegion
            }
        } catch {
            print("something happened, \(error)")
        }
        
        let region = Region(context: context)
        region.generation = generation
        region.name = name
        return region
    }
    
    private func coreDataProcess(){
        guard let context = self.managedObjectContext else{
            return
        }
        
        //create region object

        guard let pokefirst = pokeArray.first else {
            fatalError()
        }
        
        
        
        var region = getOrGenerateNextRegion(generation: pokefirst.generation)
        
        // do this. loop through and find regions. if region exists, add pokemon, if not, create region and add pokemon
        //print(pokeArray)
        //loop through pokemenz
        for pokemen in pokeArray{
            
            if region.generation! != pokemen.generation{
                
                region = getOrGenerateNextRegion(generation: pokemen.generation)
            }
            
            let pokemon = Pokemon(context: context)
            pokemon.name = pokemen.name
            pokemon.generation = pokemen.generation
            pokemon.region = region
            pokemon.id = Int16(pokemen.nationalIndex)!
            pokemon.region_id = Int16(pokemen.regionIndex)!
            pokemon.type1 = pokemen.type1 ?? nil
            pokemon.type2 = pokemen.type2 ?? nil
            pokemon.initialDesc = pokemen.description ?? ""
            pokemon.genus = pokemen.genus ?? ""
            pokemon.height = Int16(pokemen.height)
            //add as set to region
            region.pokemon?.adding(pokemon)
            
        }
        
            appDelegate.saveContext()
            loadDelegate?.loadingDone(self)
            delegate?.resetDone()
        
        
    }
    
    static func datasetCheck()->Bool{
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let regionFetch:NSFetchRequest<Region> = Region.fetchRequest()
        var regionList:[Region] = []
        do {
            regionList = try context.fetch(regionFetch) as [Region]
        } catch {
            fatalError()
        }
        
        guard let isRegion = regionList.first, let pokemon = isRegion.pokemon else {
            return false
        }
        
        if(pokemon.count>0){
            
            return true
            
        }
        
        //check coredata for region and check region has pokemon objects
        return false
        
    }
    
    func getPokedex() -> URLSessionDataTask?{
        
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
            
            guard let generationEnum = Generation(rawValue: generation) else {
                fatalError()
            }
            
            let region = generationEnum.getRegion().string()
            
            var gameIndex:Int = 0
            for gameindices in speciesInfo.pokedex_numbers{
                print(gameindices.pokedex.name,region,gameindices.pokedex.name == region)
                if(gameindices.pokedex.name == region.lowercased() || gameindices.pokedex.name == "original-"+region.lowercased()){
                    gameIndex = gameindices.entry_number
                }
            }
            
            
            //let message = speciesInfo.flavor_text_entries[speciesInfo.flavor_text_entries.count-1].flavor_text
            var message:String = ""
            
            for entry in speciesInfo.flavor_text_entries{
                if(entry.language.name=="en"){
                    message = entry.flavor_text
                    break
                }
            }
            
            var genusEntry = ""
            for genus in speciesInfo.genera{
                if(genus.language.name=="en"){
                    genusEntry = genus.genus
                    break
                }
            }
            
            let poke = PokeData(name: name, region: region, generation: generation, index: String(speciesInfo.id), regionIndex: String(gameIndex), nationalIndex: number, type1: nil, type2: nil, description: message, genus: genusEntry, height: 0, weight:0)
            
            self.pokeArray.append(poke)
            //print(poke)
            print(speciesInfo.id,poke.regionIndex)
            //process pokedata and
            self.getDataforPokemon(regionIndex: speciesInfo.id)
            
            
            
            
        }).resume()
        
        
    }
    
    
    private func getDataforPokemon(regionIndex:Int){
        
        let urlString = API_URL_ROOT+"pokemon/"+String(regionIndex)
        
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
            
            var thisPokemon = self.pokeArray[thisPokeIndex]
            
            thisPokemon.height = pokemon.height
            thisPokemon.weight = pokemon.weight
            
            let typesarray = pokemon.types
            
            for type in typesarray{
                
                //err not so sure about this?
                switch type.slot{
                case 1:
                    thisPokemon.type1 = type.type.name
                case 2:
                    thisPokemon.type2 = type.type.name
                default:
                    continue
                }
                
            }

            self.pokeArray[thisPokeIndex] = thisPokemon
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
                    //print("using existing file")
                    guard let img = UIImage(contentsOfFile: imageurl.path) else {
                        return
                    }
                    
                    guard let callback = callback else {
                        print("no callback, so pointless")
                        return
                    }
                    
                    callback(img,nil)
                    //print("loading cell image", imageurl.path)
                    return
                
                    
                }
                print("file doesnt exist \(item.front_sprite_filename!)")
                //handle this better
                return
            }
            print("no callback, so pointless")
            return
            }
        } else {
            //print("no filename, will load",item.id)
           loadImage(item: item, callback: callback,nil)
        }
        
       
}

    public func loadImage(item:Pokemon,callback:((_ img:UIImage,_ filePath:String?)->Void)?,_ secondaryCallback:(()->Void)?){
    
        DispatchQueue.global().async {
            guard let url = URL(string:IMAGE_URL+String(item.id)+".png") else {
                return
            }
            URLSession.shared.dataTask(with: url, completionHandler: {
                (data, response, error) in
                
                if (error != nil){
                    print(error?.localizedDescription)
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
                        
                        
                        //print("getting image from github success!",item.id)
                        
                        
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


