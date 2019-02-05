//
//  MasterViewController.swift
//  CoreDexter
//
//  Created by Joss Manger on 1/30/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //navigationItem.leftBarButtonItem = editButtonItem

        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font:UIFont(name: "MajorMonoDisplay-Regular", size: 21)!
        ]
        let addButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(fileinfo(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
      
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc
    func insertNewObject(_ sender: Any) {
        let context = self.fetchedResultsController.managedObjectContext
        let newPokemon = Pokemon(context: context)
        
//        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Favorite"];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stationIdentifier == %@", stID];
//        [fetch setPredicate:predicate];
//        YourObject *obj = [ctx executeRequest:fetch];
        let regionName = "Kanto"
        
        let regionFetch:NSFetchRequest<Region> = Region.fetchRequest()
        regionFetch.returnsDistinctResults = true;
        regionFetch.resultType = .managedObjectResultType
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

    @objc
    func fileinfo(_ sender:Any){
        
        let alert = UIAlertController(title: "File Ifo", message:nil, preferredStyle: .alert)
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do{
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            alert.message = fileURLs.count.digitString()
            alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } catch {
            print("nah")
        }
        
        
        
        
        
        
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
            let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                let selectedCell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as! PokeCellTableViewCell

                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                controller.img = selectedCell.imgview.image
            }
        }
    }

     // MARK: - Scroll view
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("didscroll")
//        if(fetchedResultsController.delegate != nil){
//            fetchedResultsController.delegate = nil
//        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        fetchedResultsController.delegate = self
        print("did end scroll")
        if(self.fetchedResultsController.managedObjectContext.hasChanges){
            do{
            try fetchedResultsController.managedObjectContext.save()
            } catch {
                print("no worky")
            }
        }
    }
    
    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokeCell", for: indexPath) as! PokeCellTableViewCell
        let poke = fetchedResultsController.object(at: indexPath)
        print("loading cell \(indexPath)")
        configureCell(cell, withPokemon: poke)
        //getImage(indexpath: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
    
 
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
                
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

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.global(qos: .background).async {
        let obj = self.fetchedResultsController.object(at: indexPath)
        if(obj.front_sprite_filename == nil){
                print("no image data for cell \(indexPath), attempting background load")
                //self.getImage(indexpath: indexPath)
            }
        }
    }

    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("\(indexPath) will prepare for reuse")
        cell.prepareForReuse()
    }
    
    
    // MARK: - Custom
    
    func configureCell(_ cell: UITableViewCell, withPokemon pokemon: Pokemon) {
        let pokeCell = cell as! PokeCellTableViewCell
        
        DispatchQueue.global().async {
            
        
        if let sprite_filename = pokemon.front_sprite_filename{
            let filepaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            if let dirpath = filepaths.first{
                let imageurl = URL(fileURLWithPath: dirpath).appendingPathComponent(sprite_filename)
            
                var boolPointer = ObjCBool(booleanLiteral: false)
                
                if (FileManager.default.fileExists(atPath: imageurl.path, isDirectory: &boolPointer)){
                    
                
                
            let img = UIImage(contentsOfFile: imageurl.path)
                print("loading cell image", imageurl.path)
                
                DispatchQueue.main.async{
                    pokeCell.imgview.image = img
                }
                }
                //print("skipped")
            }
        } else {
            print("no url")
        }
        }
        pokeCell.mainLabel.text =  "\(Int(pokemon.id).digitString()) - \((pokemon.name ?? "Missingno").capitalized)"//event.timestamp!.description
    }
    
    

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Pokemon> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<Pokemon>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }
    

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
//            break
                print("updating row")
                guard let indexpath = indexPath, let pkmncell = tableView.cellForRow(at: indexpath) else {
                    return
                }
                self.configureCell(pkmncell, withPokemon: anObject as! Pokemon)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)!, withPokemon: anObject as! Pokemon)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         tableView.reloadData()
     }
     */

   
    
}

