//
//  PetitionsCell.swift
//  We The People
//
//  Created by Hector Delgado on 5/15/20.
//  Copyright © 2020 Hector Delgado. All rights reserved.
//

import UIKit

class PetitionsCell: UITableViewCell {
    
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellSubtitle: UILabel!
    @IBOutlet weak var cellSignatureCount: UILabel!
    
    
    func updateView(petition: Petition) {
//        self.cellTitle = petition.petitionTitle
//        self.cellSubtitle = petition.petitionBody
//
//        textLabel?.text = petition.petitionTitle
//        detailTextLabel?.text = petition.petitionBody
        cellTitle.text = petition.petitionTitle
        cellSubtitle.text = petition.petitionBody
        cellSignatureCount.text = "\(petition.signatureCount)/\(petition.signaturesNeeded)"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
