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
        
          super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        container = nil
        initialiser = nil
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
    
    func testBThereArePokemon() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pokemon")
        do{
          let pokemon = try container.viewContext.fetch(fetchRequest) as! [Pokemon]
            print(pokemon.count)
            XCTAssertGreaterThan(pokemon.count, 0, "pokemon were not returned")
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
    
    
}
