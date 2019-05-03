//
//  MasterViewControllerInfoExtension.swift
//  CoreDexter
//
//  Created by Joss Manger on 5/2/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit

extension MasterViewController {
    
    func showInfoScreen(){
        
        let aboutScreen = AboutScreenViewController(nibName: nil, bundle: nil)
        let navigationController = UINavigationController(rootViewController: aboutScreen)
        aboutScreen.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(dismissSelf))
        //navigationController.navigationItem.hidesBackButton = false
        self.present(navigationController, animated: true, completion: nil)
        
        
    }
    
    @objc func dismissSelf(){
        dismiss(animated: true, completion: nil)
    }
    
}
