//
//  CoreDexterTests.swift
//  CoreDexterTests
//
//  Created by Joss Manger on 3/27/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import XCTest
import CoreData
@testable import CoreDexter

class CoreDexterTests: XCTestCase {

    var container:NSPersistentContainer!
    var initialiser:PokeDataLoader!
    var randomIndex:Int!
    var pokeSet:[Pokemon]!
    var model:PokeViewModel!
    override func setUp() {
      
        // Put setup code here. This method is called before the invocation of each test method in the class.
        print("set up")
        
        container = NSPersistentContainer(name: "CoreDexter")
        //container.persistentStoreDescriptions[0].url = URL(fileURLWithPath: "/dev/null")
        container.loadPersistentStores { (description, error) in
            XCTAssertNil(error)
        }
        
        initialiser = PokeDataLoader(.kanto)
        initialiser.managedObjectContext = container.viewContext
        initialiser.loadData()
        
        model = PokeViewModel(delegate: nil)
        
        let fetchRequest:NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        
        do {
            pokeSet = try container.viewContext.fetch(fetchRequest)
            randomIndex = Int.random(in: 0...pokeSet.count)
        } catch {
            print(error)
        }
        
        
          super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        container = nil
        initialiser = nil
        model = nil
        super.tearDown()
    }

    func testAThereAreRegions() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Region")
        do{
            let region = try container.viewContext.fetch(fetchRequest) as! [Region]
            print(region.count)
            XCTAssertGreaterThan(region.count, 0, "there are no regions returned")
        } catch {
            XCTFail("request unsuccessful")
            
        }
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testRegionsdelete() {
        
        AppDelegate.deleteAllData("Region", persistentContainer: container)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Region")
        do{
            let region = try container.viewContext.fetch(fetchRequest) as! [Region]
            print(region)
            XCTAssert(region.count==0, "Regions have not been deleted")
        } catch {
            XCTFail("request unsuccessful")
            
        }
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testBThereArePokemon() {
        
        XCTAssertGreaterThan(pokeSet.count, 0, "pokemon were not returned")
  
    }
    


    func testPokemonDelete(){
        AppDelegate.deleteAllData("Pokemon", persistentContainer: container)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pokemon")
        do{
            let pokemon = try container.viewContext.fetch(fetchRequest) as! [Pokemon]
            print(pokemon)
            XCTAssert(pokemon.count==0, "Pokemon have not been deleted")
        } catch {
            XCTFail("request unsuccessful")
            
        }
    }
    
    func testToggleFavorites(){
        
        let randomPokemon = pokeSet[randomIndex]
        let randomId = randomPokemon.objectID
        
        initialiser.updateFavourite(id: randomId) { (id, isFavourite) in
            XCTAssertTrue(isFavourite, "chosen pokemon \(randomPokemon.name!) has not been made a favourite")
        }
        
        XCTAssertTrue(randomPokemon.favourite, "view context has not saved \(randomPokemon.name) a favorite")
        
        initialiser.updateFavourite(id: randomId) { (id, isFavourite) in
            XCTAssertFalse(isFavourite, "chosen pokemon \(randomPokemon.name!) has not been unmade a favourite")
        }
        
        XCTAssertTrue(!randomPokemon.favourite, "view context has not been saved \(randomPokemon.name) a favorite")
        
    }
    
    func testSetCurrentPokemon(){
        let randomPokemon = pokeSet[randomIndex]
        let randomId = randomPokemon.objectID
        
        model.setCurrentPokemonViewStruct(id: randomId)
        
        XCTAssertTrue(model.currentPokemon!.name == randomPokemon.name, "model and randomlly selected \(randomPokemon.name) do not match")
        
    }
    
    func testArModelImageSet(){
        
        let randomPokemon = pokeSet[randomIndex]
        let randomId = randomPokemon.objectID
        
        model.setCurrentPokemonViewStruct(id: randomId)
        
        Thread.sleep(forTimeInterval: 0.5)
        
        let arModel = model.pokemonARModel
        XCTAssertTrue(arModel.name==randomPokemon.name, "\(randomPokemon.name) name do not match")
        XCTAssertTrue(arModel.sprite==model.currentImageData, "image data not set correctly")
        XCTAssertTrue(arModel.height==(Float(randomPokemon.height) / 10), "\(randomPokemon.height) name do not match")
        
    }
    
    
}
