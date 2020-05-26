//
//  CurrentPetition.swift
//  We The People
//
//  Created by Hector Delgado on 5/22/20.
//  Copyright © 2020 Hector Delgado. All rights reserved.
//

import Foundation

class CurrentPetition {
    static let shared = CurrentPetition()
    
    public private(set) var petition = Petition()
    
    private init() {} 
    
    func builder(petition: Petition) {
        self.petition = Petition(petitionID: petition.petitionID, title: petition.title, body: petition.body, signatureCount: petition.signatureCount, signaturesNeeded: petition.signaturesNeeded)
    }
}
