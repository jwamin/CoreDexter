//
//  MasterViewController.swift
//  CoreDexter
//
//  Created by Joss Manger on 1/30/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit
import PokeAPIKit
import CoreData

//typealias font = MasterViewController.font

// MARK: - (V)iew

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate,ResetProtocol,LoadingProtocol {
    
    // MARK: - IVars
    static var font:UIFont = {
        guard let font = UIFont(name: "MajorMonoDisplay-Regular", size: UIFont.labelFontSize) else {
            fatalError()
        }
        return font
    }()
    
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    weak var loadingView:UIView? = nil
    var viewModel:PokeViewModel!
    var scrollLoading = false
    
    // MARK: - ViewController Lifecycle
    var isLoading:Bool = false
    func animateLoading(){
        guard let loadingView = self.loadingView, let pokedexImageView = loadingView.subviews[0] as? UIImageView else {
            return
        }
        
        UIView.animateKeyframes(withDuration: 0.5, delay: 1.0, options: [], animations: {
            pokedexImageView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
        }) { (complete) in
                UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 5, initialSpringVelocity: 30, options: [.beginFromCurrentState], animations: {
                    pokedexImageView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
                    
                }, completion: { (complete) in
                    if(complete){
                        if(self.isLoading){
                            self.animateLoading()
                        }
                    }
                })
            
        }
    }
    
    func removeLoadingScreen(){
        
        guard let loadingView = self.loadingView, let pokedexImageView = loadingView.subviews[0] as? UIImageView else {
            return
        }
        
        pokedexImageView.layer.removeAllAnimations()
        
        UIView.animateKeyframes(withDuration: 1.0, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.3, animations: {
                self.loadingView!.alpha = 0.0
            })
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.2, animations: {
                self.loadingView?.subviews[0].transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.7, animations: {
                self.loadingView?.subviews[0].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            })
        }, completion: { (complete) in
            if(complete){
                print(self.loadingView!.superview)
                self.loadingView?.removeFromSuperview()
                self.loadingView = nil
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //navigationItem.leftBarButtonItem = editButtonItem
        
        tableView.scrollsToTop = true
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableView.automaticDimension
        
        guard let font = UIFont(name: "MajorMonoDisplay-Regular", size: UIFont.labelFontSize) else {
            fatalError()
        }
        
        //refactor this to IB?
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font:UIFontMetrics(forTextStyle: .headline).scaledFont(for:font),
            NSAttributedString.Key.foregroundColor:UIColor.yellow
        ]
        
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(fileinfo(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        let activityview = UIActivityIndicatorView(style: .gray)
        activityview.hidesWhenStopped = true
        let addActivityView = UIBarButtonItem(customView: activityview)
        navigationItem.leftBarButtonItem = addActivityView
        activityview.startAnimating()
        
        
        viewModel = PokeViewModel(delegate:self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        self.splitViewController?.preferredDisplayMode = UISplitViewController.DisplayMode.automatic
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
            alert.message = fileURLs.count.digitString()+" sprites cached"
            alert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: {(action) in
                self.callReset()
            }))
            alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } catch {
            print("nah")
        }
        
    }
    
    func callReset(){
        print("reset done")
        (navigationItem.leftBarButtonItem?.customView as! UIActivityIndicatorView).startAnimating()
        viewModel = nil
        
        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: Bundle.main)
        let loadingScreen = storyboard.instantiateViewController(withIdentifier: "loadingScreen")
        self.loadingView = loadingScreen.view
        loadingScreen.view.alpha = 0.0
        self.navigationController?.view.addSubview(loadingScreen.view)
        
        UIView.animate(withDuration: 0.5, animations: {
           
                loadingScreen.view.alpha = 1.0
            
        }) { [unowned self] (complete) in
            let delegate = UIApplication.shared.delegate as! AppDelegate
            delegate.resetAll()
            self.viewModel = PokeViewModel(delegate: self)
            self.viewModel.assignDelegate(delegate:self)
            self._fetchedResultsController = nil
            print(self.fetchedResultsController)
            self.fetchedResultsController.delegate = self
            self.tableView.reloadData()
            print("reloaded")
        }
        

    }
    
    
    // MARK: - Delegate Methods
    
    func loadingInProgress() {
        print("loading in progress")
        
        isLoading = true
        animateLoading()
        
        

        
    }
    
    func loadingDone() {
        print("loading done")
        isLoading = false
        removeLoadingScreen()
    }
    
    func resetDone() {
        viewModel.resetDelegate()
        tableView.reloadData()
        (navigationItem.leftBarButtonItem?.customView as! UIActivityIndicatorView).stopAnimating()
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                
                print("prepare for segue")
                //if there's nothing selected, none of this works
                
                let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController

                
                controller.title = object.name?.capitalized

                viewModel.getImageforID(id: object.objectID, callback: { [unowned controller,unowned self] (img) in
                    controller.img = img
                    let pokemonData = self.viewModel.pokemonViewModel(id: object.objectID)
                    controller.pokemonData = pokemonData
                })
                
                if(self.splitViewController?.displayMode == UISplitViewController.DisplayMode.primaryOverlay){
                    UIView.animate(withDuration: 0.3, animations: {
                        self.splitViewController?.preferredDisplayMode = UISplitViewController.DisplayMode.primaryHidden
                    }) { (complete) in
                        self.splitViewController?.preferredDisplayMode = UISplitViewController.DisplayMode.automatic
                    }
                }
      
                
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                //controller.setupView()
            }
        }
    }
    
    
    // MARK: - Scroll view
    
    override func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        print("should scroll to top?")
        return true
    }
    
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if(!scrollView.isTracking){
            print("did end decelerating and not tracking")
             endScroll()
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if(decelerate){
            print("did end tracking and is still scrolling")
        } else {
            print("did end tracking and is stopped")
            endScroll()
        }
        
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let regionContainer = fetchedResultsController.sections?[section], let objects = regionContainer.objects{
            let header = FontedHeaderView()
            header.contentView.backgroundColor = .basicallyAwfulRed
            header.textLabel?.font = MasterViewController.font.withSize(UIFont.labelFontSize)
            //header.textLabel?.textColor = .yellow
            let pokemon = objects[0] as! Pokemon
            print(pokemon.region?.name)
            header.textLabel!.text = pokemon.region!.name
            
            return header
        }
       
        return nil
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
        cell.layoutIfNeeded()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 40.0
//    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if(indexPath.row == tableView.indexPathsForVisibleRows!.last!.row){
            //end of loading
            (navigationItem.leftBarButtonItem?.customView as! UIActivityIndicatorView).stopAnimating()
        }

        cell.layoutIfNeeded()
        let pokeCell = cell as! PokeCellTableViewCell
        pokeCell.updateCircle()
        DispatchQueue.global(qos: .background).async {
            
            //asynchronously requests image if there is none
            self.getImageForCell(at: indexPath)
            
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.prepareForReuse()
    }
    
    func configureCell(_ cell: UITableViewCell, withPokemon pokemon: Pokemon) {
        let pokeCell = cell as! PokeCellTableViewCell
        
        //leave image loading to willDisplay
        //let labeltext = (Int(pokemon.id) == 60) ? "This is hopefully a really reallyl ong label to check if self sizing is still working" : "\(Int(pokemon.id).digitString()) - \((pokemon.name ?? "Missingno").capitalized)"
        let labeltext = "\(Int(pokemon.id).digitString()) - \((pokemon.name ?? "Missingno").capitalized)"
        pokeCell.mainLabel.text = labeltext //event.timestamp!.description
        pokeCell.type1Label.typeString = pokemon.type1
        pokeCell.type2Label.typeString = pokemon.type2
        pokeCell.mainLabel.sizeToFit()
        
    }
    
    // MARK: - Custom
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    
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
                    cell.layoutIfNeeded()
                }
            }
        
        
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<Pokemon> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        print("loading frc")
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "region", cacheName: "Master")
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
        if(!scrollLoading){
            switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                if let indexPath = indexPath{
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
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

