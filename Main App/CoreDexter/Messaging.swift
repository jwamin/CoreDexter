//
//  Messaging.swift
//  CoreDexter
//
//  Created by Joss Manger on 4/21/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import Foundation
import PokeAPIKit

protocol DetailDelegate {
    func requestModel()->PokeARModel
    func updateFavourite() // send message to model to update the favourite status of the current monster
}


protocol ResetProtocol {
    func resetDone()
}

protocol LoadingProtocol{
    func loadingInProgress()
    func loadingDone(_ sender:Any)
}
