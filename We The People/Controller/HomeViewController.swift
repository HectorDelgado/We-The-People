//
//  ViewController.swift
//  We The People
//
//  Created by Hector Delgado on 5/15/20.
//  Copyright © 2020 Hector Delgado. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    let reachability = Reachability.shared

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let connectionAvailable = reachability.connectionIsAvailable
        
        if !connectionAvailable {
            present(reachability.errorAlert(), animated: true)
        }
        
        return connectionAvailable
    }
    
}

