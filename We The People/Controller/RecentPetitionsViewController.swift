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
    
    private var baseURL = "https://api.whitehouse.gov/v1/petitions.json?"
    
    var unfilteredPetitions = [Petition]()
    var filteredPetitions = [Petition]()
    var currentPetitions = [Petition]()
    
    
    var limit = 25
    var offset = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        petitionsTableView.dataSource = self
        petitionsTableView.delegate = self
        
        title = "Petitions \(offset + 1)-\(limit)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(displayOptions))
        
        //baseURL.append("limit=\(limit)&offset=\(offset)")
        let url = "\(baseURL)limit=\(limit)&offset=\(offset)"
        getJSON(for: url)
    }
    
    /// Retrieves the JSON data from the specified URL.
    /// - Parameter jsonData: Block of code that exectues when the data has been successfully retrieved.
    /// - Returns: The JSON data that was found.
    private func getJSON(for urlString: String) {
        // Get URL results using GCD background thread
        DispatchQueue.global(qos: .userInitiated).async {
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    if let json = try? JSON(data: data) {
                        // Once results are found, switch back to main thread.
                        DispatchQueue.main.async {
                            self.parseJSON(for: json)
                        }
                    } else {
                        self.displayError(alertTitle: "Oops", alertMessage: "There was an error getting the data\n(BAD JSON DATA)", actionTitle: "OK", handler: nil)
                    }
                } else {
                    self.displayError(alertTitle: "Oops", alertMessage: "There was an error getting the data\n(BAD DATA)", actionTitle: "OK", handler: nil)
                }
            } else {
                self.displayError(alertTitle: "Oops", alertMessage: "There was an error getting the data\n(INVALID URL)", actionTitle: "OK", handler: nil)
            }
        }
    }
    
    /// Parses through the  JSON object to initialize the array of unfiltered Petition objects
    /// - Parameter jsonData: The JSON object to be parsed.
    private func parseJSON(for jsonData: JSON) {
        if jsonData.count > 0 {
            let jsonResults = jsonData["results"]
            var tempArray = [Petition]()
            
            for i in 0..<jsonResults.count {
                if let petitionID = jsonResults[i]["id"].string,
                    let title = jsonResults[i]["title"].string,
                    let body = jsonResults[i]["body"].string,
                    let signatureCount = jsonResults[i]["signatureCount"].int,
                    let signaturesNeeded = jsonResults[i]["signaturesNeeded"].int {
                    
                    tempArray.append(Petition(petitionID: petitionID, title: title, body: body, signatureCount: signatureCount, signaturesNeeded: signaturesNeeded))
                    //unfilteredPetitions.removeAll()
                    //unfilteredPetitions.append(Petition(petitionID: petitionID, title: title, body: body, signatureCount: signatureCount, signaturesNeeded: signaturesNeeded))
                }
            }
            
            unfilteredPetitions.removeAll()
            unfilteredPetitions.append(contentsOf: tempArray)
            updateUI(with: unfilteredPetitions)
        }
    }
    
    private func pauseUI() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        // Pause buttons
    }
    
    /// Updates the UI to display the array of Petition objects.
    /// - Parameter petitions: The array to display.
    private func updateUI(with petitions: [Petition]) {
        currentPetitions.removeAll()
        currentPetitions.append(contentsOf: petitions)
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        petitionsTableView.reloadData()
    }
    
    private func displayError(alertTitle: String?, alertMessage: String?, actionTitle: String?, handler: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: actionTitle, style: .default, handler: handler))
        self.present(alertController, animated: true)
    }
    
    private func filter(petitions: [Petition], by keyword: String) {
        let lowerKeyword = keyword.lowercased()
        var tempArray = [Petition]()
        
        for petition in petitions {
            if petition.title.lowercased().contains(lowerKeyword) {
                tempArray.append(petition)
            }
        }
        updateUI(with: tempArray)
    }
    
    @objc private func displayOptions() {
        let alertController = UIAlertController(title: nil, message: "Choose an option", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Search", style: .default, handler: { _ in
            self.displaySearchAlert()
        }))
        alertController.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
            self.updateUI(with: self.unfilteredPetitions)
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alertController, animated: true)
    }
    
    private func displaySearchAlert() {
        let alertController = UIAlertController(title: "Search for", message: nil, preferredStyle: .alert)
        alertController.addTextField { (uiTextField) in
            uiTextField.placeholder = "keyword"
        }
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            if let title = alertController.textFields?.first?.text, title.count > 0 {
                self.filter(petitions: self.currentPetitions, by: title)
            }
        }))
        present(alertController, animated: true)
    }
    
    @IBAction func previousBtnTapped(_ sender: UIButton) {
        if offset >= 25 {
            offset -= 25
            title = "Petitions \(offset + 1)-\(offset + limit)"
            
            let url = "\(baseURL)limit=\(limit)&offset=\(offset)"
            getJSON(for: url)
        }
    }
    
    @IBAction func nextBtnTapped(_ sender: UIButton) {
        offset += 25
        title = "Petitions \(offset + 1)-\(offset + limit)"
        
        let url = "\(baseURL)limit=\(limit)&offset=\(offset)"
        pauseUI()
        getJSON(for: url)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "SOMEEE"
        navigationItem.backBarButtonItem = backItem
        
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//        if segue.identifier == "webViewSegue" {
//            if let vc = segue.destination as? WebViewController {
//                vc.petition =
//            }
//        }
//    }
}

extension RecentPetitionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentPetitions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pCell") as! PetitionsCell
        let petition = currentPetitions[indexPath.row]
        cell.updateView(petition: petition)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        CurrentPetition.shared.builder(petition: currentPetitions[indexPath.row])
        
    }
}
