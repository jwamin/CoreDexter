//
//  AppDelegate.swift
//  CoreDexter
//
//  Created by Joss Manger on 1/30/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

#if MY_DEBUG_FLAG
    let debug = true
#else
    let debug = false
#endif

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
         print("debug in operation: \(debug)")
        
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self

        let masterNavigationController = splitViewController.viewControllers[0] as! UINavigationController
        let controller = masterNavigationController.topViewController as! MasterViewController
        controller.managedObjectContext = persistentContainer.viewContext
        
        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: Bundle.main)
        let loadingScreen = storyboard.instantiateViewController(withIdentifier: "loadingScreen")
        controller.loadingView = loadingScreen.view
        
        
        splitViewController.view.addSubview(loadingScreen.view)
        
        
        let reset = UserDefaults.standard.object(forKey: "reset") as? Bool ?? false
        print("reset",reset)
        if(reset){
            resetAll()
        }
        
        return true
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.img == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
    
    func targetDisplayModeForAction(in svc: UISplitViewController) -> UISplitViewController.DisplayMode {
        switch svc.displayMode {
        case .allVisible:
            return .primaryHidden
        default:
            return .automatic
        }
    }
    
    // MARK: - Core Data stack
    
    var context:NSManagedObjectContext!
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "CoreDexter")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        context = container.viewContext
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func resetAll(){
        UserDefaults.standard.set(false, forKey: "reset")
        AppDelegate.deleteAllData("Region",persistentContainer: persistentContainer)
        AppDelegate.deleteAllData("Pokemon",persistentContainer: persistentContainer)
        AppDelegate.clearAllFilesFromTempDirectory()
    }
    
    class func clearAllFilesFromTempDirectory(){
        
        
        let fileManager = FileManager.default
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let directoryContents: [String] = try! fileManager.contentsOfDirectory(atPath: dirPath)
        
        if directoryContents.count != 0 {
            for path in directoryContents {
                let fullPath = dirPath.appending("/"+path)
                do{
                    try fileManager.removeItem(atPath: fullPath)
                    print("successfully deleted \(fullPath)")
                } catch {
                    print("that didnt work \(fullPath)")
                }
            }
        } else {
            print("\(dirPath) is empty")
        }
    }
    
    class func deleteAllData(_ entity:String,persistentContainer:NSPersistentContainer) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                persistentContainer.viewContext.delete(objectData)
            }
            print("\(entity) delete successful")
            
//            let deleteRequrest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//            deleteRequrest.resultType = .resultTypeObjectIDs
//            let results = try persistentContainer.viewContext.execute(deleteRequrest) as? NSBatchDeleteResult
//            let objectIDArray = results?.result as? [NSManagedObjectID]
//            let changes = [NSDeletedObjectsKey : objectIDArray]
//            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [persistentContainer.viewContext])
//
//
        } catch let error {
            print("Detele all data in \(entity) error :", error)
        }
    }
    
}

