//
//  PetitionsCell.swift
//  We The People
//
//  Created by Hector Delgado on 5/15/20.
//  Copyright © 2020 Hector Delgado. All rights reserved.
//

import UIKit

@IBDesignable
class PetitionsCell: UITableViewCell {
    
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellSubtitle: UILabel!
    @IBOutlet weak var cellSignatureCount: UILabel!
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var cellColor: UIColor = UIColor.white {
        didSet {
            self.backgroundColor = cellColor
        }
    }
    
    
    func updateView(petition: Petition) {
//        self.cellTitle = petition.petitionTitle
//        self.cellSubtitle = petition.petitionBody
//
//        textLabel?.text = petition.petitionTitle
//        detailTextLabel?.text = petition.petitionBody
        cellTitle.text = petition.title
        cellSubtitle.text = petition.body
        cellSignatureCount.text = "\(petition.signatureCount)/\(petition.signaturesNeeded)"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        //self.layer.borderWidth  = CGFloat(4.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
