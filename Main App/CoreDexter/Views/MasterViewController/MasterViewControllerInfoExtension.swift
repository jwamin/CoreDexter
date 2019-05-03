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

        self.present(aboutScreen, animated: true, completion: nil)
        
        
    }
    
}
