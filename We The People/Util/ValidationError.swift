//
//  ValidationError.swift
//  We The People
//
//  Created by Hector Delgado on 5/27/20.
//  Copyright © 2020 Hector Delgado. All rights reserved.
//

import Foundation

struct ValidationError: Error {
    enum ErrorKind {
        case invalidURL(String)
        case badData
        case badJSON
        case noItemsFound
    }
    
    //private(set) var fullDescription: String
    private(set) var shortDescription: String
    private(set) var errorType: ErrorKind
    
    init(errorType: ErrorKind) {
        self.errorType = errorType
        
        switch errorType {
        case let .invalidURL(s):
            print("Message is \(s)")
            shortDescription = "Could not parse \(s)"
        case .badData:
            shortDescription = "Bad data found"
        case .badJSON:
            shortDescription = "Bad JSON data"
        case .noItemsFound:
            shortDescription = "No Items Found"
        }
        
    }
}
