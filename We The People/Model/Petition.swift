//
//  Petition.swift
//  We The People
//
//  Created by Hector Delgado on 5/15/20.
//  Copyright © 2020 Hector Delgado. All rights reserved.
//

import Foundation

class Petition {
    let petitionID: String
    let title: String
    let body: String
    let signatureCount: Int
    let signaturesNeeded: Int
    
    init() {
        self.petitionID = ""
        self.title = ""
        self.body = ""
        self.signatureCount = 0
        self.signaturesNeeded = 0
    }
    
    init(petitionID: String, title: String, body: String, signatureCount: Int, signaturesNeeded: Int) {
        self.petitionID = petitionID
        self.title = title
        self.body = body
        self.signatureCount = signatureCount
        self.signaturesNeeded = signaturesNeeded
    }
    
    func generatePetitionURL() -> String {
        return "https://api.whitehouse.gov/v1/petitions/\(petitionID).json"
    }
}
