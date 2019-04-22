//
//  FilesystemOperationTests.swift
//  CoreDexterTests
//
//  Created by Joss Manger on 3/27/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import XCTest
import CoreData
import UIKit
@testable import CoreDexter

class FilesystemOperationTests: XCTestCase {
    
    var container:NSPersistentContainer!
    var initialiser:PokeDataLoader!
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        print("set up")
        container = NSPersistentContainer(name: "CoreDexter")
        //container.persistentStoreDescriptions[0].url = URL(fileURLWithPath: "/dev/null")
        container.loadPersistentStores { (description, error) in
            if (error != nil) {
                XCTFail()
            }
        }
        initialiser = PokeDataLoader(.kanto)
        initialiser.managedObjectContext = container.viewContext
        initialiser.loadData()
        
         let imagesLoaded = expectation(description: "Images loaded")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pokemon")
        do{
            let pokemons = try container.viewContext.fetch(fetchRequest) as! [Pokemon]
            
           
            
            let dispatchq = DispatchGroup()
            
 
            
            for pokemon in pokemons{
                dispatchq.enter()
                initialiser.getImage(item: pokemon, callback: { (_,_) in
                    dispatchq.leave()
                })
            }
            
            dispatchq.notify(queue: .main) {
                imagesLoaded.fulfill()
                print("dispatchq done")
            }
            
        } catch {
            XCTFail("request unsuccessful")
            
        }
        
        wait(for: [imagesLoaded], timeout: 20)
        print("ready")
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testImagesLoad() {
        // This is an example of a functional test case.
        let promise = expectation(description: "there are no files in the directory")
        var contents:[URL] = []
        let fileManager = FileManager.default
        do{
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            contents = try! fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil, options: [])
            if(contents.count>0){
                promise.fulfill()
            } else {
                XCTFail("Nothing in document directory")
            }
            
        } catch {
            XCTFail("Failed to get document directory")
        }
        wait(for: [promise], timeout: 20)
        XCTAssertGreaterThan(contents.count, 0)
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testZImagesGetUnloaded(){

        AppDelegate.clearAllFilesFromTempDirectory()

        let promise = expectation(description: "there are no files in the directory")

        var contents:[URL] = []

        let fileManager = FileManager.default
        do{
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                contents = try! fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil, options: [])
            if(contents.count==0){
                promise.fulfill()
            }

        } catch {
            XCTFail("Failed to get document directory")
        }
        wait(for: [promise], timeout: 10)
        XCTAssertEqual(contents.count, 0)
    }
    
}
