//
//  WebViewController.swift
//  We The People
//
//  Created by Hector Delgado on 5/22/20.
//  Copyright © 2020 Hector Delgado. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {

    @IBOutlet weak var petitionTitle: UILabel!
    @IBOutlet weak var petitionBody: UILabel!
    @IBOutlet weak var petitionSignatures: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //navigationItem.backBarButtonItem?.title = "Back"
        print(CurrentPetition.shared.petition.title)
        
        petitionTitle.text = CurrentPetition.shared.petition.title
        petitionBody.text = CurrentPetition.shared.petition.body
        petitionSignatures.text = "\(CurrentPetition.shared.petition.signatureCount)/\(CurrentPetition.shared.petition.signaturesNeeded)"
        
//        let urlString = CurrentPetition.shared.petition.generatePetitionURL()
//        if let url = URL(string: urlString) {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        }
//        //UIApplication.shared.openURL(<#T##url: URL##URL#>)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
