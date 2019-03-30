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

    var stack:NSPersistentContainer!
    var initialiser:PokeModel!
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        print("set up")
        stack = NSPersistentContainer(name: "CoreDexter")
        stack.loadPersistentStores { (description, error) in
            if (error != nil) {
                XCTFail()
            }
        }
        initialiser = PokeModel(APP_REGION)
        initialiser.managedObjectContext = stack.viewContext
        initialiser.checkAndLoadData()
        
       
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        stack = nil
        initialiser = nil
    }

    func testThereArePokemon() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pokemon")
        do{
          let pokemon = try stack.viewContext.fetch(fetchRequest) as! [Pokemon]
            print(pokemon.count)
            XCTAssertGreaterThan(pokemon.count, 0, "pokemon were returned")
        } catch {
            XCTFail("request unsuccessful")
            
        }
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testThereAreRegions() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Region")
        do{
            let region = try stack.viewContext.fetch(fetchRequest) as! [Region]
            print(region,region.count)
            XCTAssertGreaterThan(region.count, 0, "there are regions returned")
        } catch {
            XCTFail("request unsuccessful")
            
        }
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testRegionsdelete() {
        
        AppDelegate.deleteAllData("Region", persistentContainer: stack)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Region")
        do{
            let region = try stack.viewContext.fetch(fetchRequest) as! [Region]
            print(region)
            XCTAssert(region.count==0, "Regions have not been deleted")
        } catch {
            XCTFail("request unsuccessful")
            
        }
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPokemonDelete(){
        AppDelegate.deleteAllData("Pokemon", persistentContainer: stack)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pokemon")
        do{
            let pokemon = try stack.viewContext.fetch(fetchRequest) as! [Pokemon]
            print(pokemon)
            XCTAssert(pokemon.count==0, "Pokemon have not been deleted")
        } catch {
            XCTFail("request unsuccessful")
            
        }
    }
    
    
}
