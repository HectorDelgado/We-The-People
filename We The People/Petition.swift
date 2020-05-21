//
//  Petition.swift
//  We The People
//
//  Created by Hector Delgado on 5/15/20.
//  Copyright © 2020 Hector Delgado. All rights reserved.
//

import Foundation

class Petition {
    let petitionTitle: String
    let petitionBody: String
    let signatureCount: Int
    let signaturesNeeded: Int
    
    init(petitionTitle: String, petitionBody: String, signatureCount: Int, signaturesNeeded: Int) {
        self.petitionTitle = petitionTitle
        self.petitionBody = petitionBody
        self.signatureCount = signatureCount
        self.signaturesNeeded = signaturesNeeded
    }
}
