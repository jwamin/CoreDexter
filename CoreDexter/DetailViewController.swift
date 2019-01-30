//
//  DetailViewController.swift
//  CoreDexter
//
//  Created by Joss Manger on 1/30/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!


    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.numberOfLines = 0
                label.text = "\(detail.name) \n \(detail.id) \n \(detail.generation) \n \(detail.region!.name) \n \(detail.type1) \n \(detail.initialDesc)"//detail.timestamp!.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    var detailItem: Pokemon? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

