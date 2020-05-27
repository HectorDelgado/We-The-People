//
//  Reachability.swift
//  We The People
//
//  Created by Hector Delgado on 5/26/20.
//  Copyright © 2020 Hector Delgado. All rights reserved.
//

import UIKit
import Network

public class Reachability {
    static let shared = Reachability()
    
    private(set) var connectionIsAvailable = false {
        didSet {
            print("Connection now: \(connectionIsAvailable)")
        }
    }
    
    private init() {
        let monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.connectionIsAvailable = true
            } else {
                self.connectionIsAvailable = false
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    func errorAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Oops!", message: "Network connection not detected!\nTry again later.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert
    }
}
