//
//  MasterViewController.swift
//  CoreDexter
//
//  Created by Joss Manger on 1/30/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit
import CoreData

// MARK: - (V)iew

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - IVars
    
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var viewModel:PokemonViewModel!
    var scrollLoading = false
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //navigationItem.leftBarButtonItem = editButtonItem
        
        let initialiser = PokemonModel(APP_REGION)
        initialiser.managedObjectContext = self.managedObjectContext
        initialiser.checkAndLoadData()
        
        viewModel = PokemonViewModel(dependency: initialiser)
        
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
    
    // MARK: - Actions
    
    @objc
    func fileinfo(_ sender:Any){
        
        let alert = UIAlertController(title: "File Info", message:nil, preferredStyle: .alert)
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

                controller.title = object.name?.capitalized
                controller.labelText = viewModel.pokemonLabelString(id: object.objectID)
                viewModel.getImageforID(id: object.objectID, callback: { (img) in
                    controller.img = img
                })
                
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                
            }
        }
    }
    
    
    // MARK: - Scroll view
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        endScroll()
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        endScroll()
    }
    
    func endScroll(){
        scrollLoading = false
        print("did end scroll")
        if(self.fetchedResultsController.managedObjectContext.hasChanges){
            do{
                try fetchedResultsController.managedObjectContext.save()
                print("saved on scroll end")
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
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.global(qos: .background).async {
            
            //asynchronously requests image if there is none
            self.getImageForCell(at: indexPath)
            
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("\(indexPath) will prepare for reuse")
        cell.prepareForReuse()
    }
    
    func configureCell(_ cell: UITableViewCell, withPokemon pokemon: Pokemon) {
        let pokeCell = cell as! PokeCellTableViewCell
        
        //leave image loading to willDisplay
        
        pokeCell.mainLabel.text =  "\(Int(pokemon.id).digitString()) - \((pokemon.name ?? "Missingno").capitalized)"//event.timestamp!.description
    }
    
    // MARK: - Custom
    

    
    public func getImageForCell(at indexPath:IndexPath){
        
        //send message to model to retrieve or request image for cell
        
        let obj = self.fetchedResultsController.object(at: indexPath)
  
            self.scrollLoading = true
            let id = obj.objectID
            
            viewModel.getImageforID(id: id){ [unowned self] (img:UIImage) in
                
                DispatchQueue.main.async {
                    
                    //cell might have moved out of view, so we test
                    guard let cell = self.tableView.cellForRow(at: indexPath) as? PokeCellTableViewCell else {
                        print("no cell at \(indexPath) ?")
                        return
                    }
                    
                    cell.imgview.image = img
                }
            }
        
        
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
        let sortDescriptor = NSSortDescriptor(key: "region_id", ascending: true)
        
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
        if(scrollLoading){
            return
        }
        tableView.beginUpdates()
        
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        if(scrollLoading){
            return
        }
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
        if(scrollLoading){
            return
        }
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            print("updating row")
            guard let indexpath = indexPath, let pkmncell = tableView.cellForRow(at: indexpath) else {
                print("problem with indexpath and/or cell")
                return
            }
            self.configureCell(pkmncell, withPokemon: anObject as! Pokemon)
        case .move:
            configureCell(tableView.cellForRow(at: indexPath!)!, withPokemon: anObject as! Pokemon)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if(scrollLoading){
            return
        }
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
