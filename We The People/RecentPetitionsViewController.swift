//
//  RecentPetitionsViewController.swift
//  We The People
//
//  Created by Hector Delgado on 5/15/20.
//  Copyright © 2020 Hector Delgado. All rights reserved.
//

import UIKit
import SwiftyJSON

class RecentPetitionsViewController: UIViewController {

    @IBOutlet weak var petitionsTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=25"
    
    var petitions = [Petition]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        petitionsTableView.dataSource = self
        petitionsTableView.delegate = self
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.loadJSON { [weak self](isSuccess, jsonData) in
                if isSuccess {
                    if let json = jsonData {
                        let results = json["results"]

                        for i in 0..<results.count {
                            if let title = results[i]["title"].string,
                                let body = results[i]["body"].string,
                                let signatureCount = results[i]["signatureCount"].int,
                                let signaturesNeeded = results[i]["signaturesNeeded"].int {
                                self?.petitions.append(Petition(petitionTitle: title, petitionBody: body, signatureCount: signatureCount, signaturesNeeded: signaturesNeeded))
                                
                                DispatchQueue.main.async {
                                    self?.activityIndicator.isHidden = true
                                    self?.activityIndicator.stopAnimating()
                                    self?.petitionsTableView.reloadData()
                                }
                            }
                        }
                    }
                } else {
                    self?.displayError(alertTitle: "Error", alertMessage: "There was an error retrieving the data.", actionTitle: "OK", handler: nil)
                }
            }
        }
    }
    
    private func loadJSON(isSuccess: (Bool, JSON?) -> ()) {
        if let url = URL(string: urlString) {
            if let data = try?  Data(contentsOf: url) {
                if let json = try? JSON(data: data) {
                    isSuccess(true, json)
                    return
                }
            }
        }
        
        isSuccess(false, nil)
    }
    
    private func displayError(alertTitle: String?, alertMessage: String?, actionTitle: String?, handler: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: actionTitle, style: .default, handler: handler))
        self.present(alertController, animated: true)
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

extension RecentPetitionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petitions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pCell") as! PetitionsCell
        let petition = petitions[indexPath.row]
        cell.updateView(petition: petition)
        
    
        return cell
    }
    
    
}
