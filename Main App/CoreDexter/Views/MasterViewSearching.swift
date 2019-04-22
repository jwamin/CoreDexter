//
//  MasterViewSearching.swift
//  CoreDexter
//
//  Created by Joss Manger on 4/22/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit
import CoreData
import PokeAPIKit

extension MasterViewController : UISearchResultsUpdating{
    
    func initialiseSearchController(){
        
        searchController = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchController
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        //self.definesPresentationContext = false

    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        
        var andPredicate:NSCompoundPredicate? = nil
        
        //let searchFetch:NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        
        if searchController.searchBar.text!.count>0 {
        
        let whitespace = CharacterSet.whitespaces
        let strippedString = searchController.searchBar.text!.trimmingCharacters(in: whitespace)
        let searchItems = strippedString.components(separatedBy: " ")
        
        let predicates = searchItems.map{ searchString in
            return findMatches(searchString.lowercased())
        }
        
        andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        }
        
        if(showingFavs){
            if let and = andPredicate{
                andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [and,FAVOURITES_PREDICATE])
            } else {
                andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [FAVOURITES_PREDICATE])
            }
        }
        
        do {
            fetchedResultsController.fetchRequest.predicate = andPredicate
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func findMatches(_ str:String)-> NSCompoundPredicate{
        
        var searchItemsPredicate = [NSPredicate]()
        
        //element matches
        
        var elementMatch = false
        
        for elementString in ElementalType.rawStrings(){
            
            if elementString.contains(str){
                
                let elementPredicate = NSPredicate(format: "type1 CONTAINS[cd] %@", str)
                let element2Predicate = NSPredicate(format: "type2 CONTAINS[cd] %@", str)
                
                let orPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [elementPredicate,element2Predicate])
                
                searchItemsPredicate.append(orPredicate)
                elementMatch = true
                break
                
            }
            
        }
        
        
        //if(!elementMatch){
            
            let namePredicate = NSPredicate(format: "name CONTAINS[cd] %@", str)
            searchItemsPredicate.append(namePredicate)
            
        //}
        
            
        
        
        return NSCompoundPredicate(orPredicateWithSubpredicates: searchItemsPredicate)
        
    }
    
}

extension MasterViewController : UISearchBarDelegate{
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        print("cancelled")
        //updateSearchResults(for: searchController)
        
    }
 
}

extension MasterViewController : UISearchControllerDelegate {
    
    func didDismissSearchController(_ searchController: UISearchController) {
        print("dismissed",searchController.searchBar.text)
        
    }
    
}
