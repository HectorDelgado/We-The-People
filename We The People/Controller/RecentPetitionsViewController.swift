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

    ///
    /// IBOutlets
    ///
    @IBOutlet weak var petitionsTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    ///
    /// Properties
    ///
    private let baseURL = "https://api.whitehouse.gov/v1/petitions.json?"
    private let reachability = Reachability.shared
    private var unfilteredPetitions = [Petition]()
    private var filteredPetitions = [Petition]()
    private var currentPetitions = [Petition]()
    private var limit = 25
    private var offset = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        petitionsTableView.dataSource = self
        petitionsTableView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(displayOptions))
        
        if reachability.connectionIsAvailable {
            loadJSON()
        } else {
            displayError(alertTitle: "Oops", alertMessage: "Network connection not detected!\nTry again later.", actionTitle: "Ok", handler: nil)
        }
    }
    
    /// Loads the JSON results of the current url asyncronously.
    /// Uses the Result value of the getResults method to either display an error message or begin to parse the JSON data.
    private func loadJSON() {
        pauseUI()
        
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.getResults(for: "\(self.baseURL)limit=\(self.limit)&offset=\(self.offset)")
            
            DispatchQueue.main.async {
                switch result {
                case let .success(jsonData):
                    self.parseJSON(for: jsonData)
                case let .failure(error):
                    self.updateUI(with: [Petition]())
                    self.displayError(alertTitle: "Oops", alertMessage: error.shortDescription, actionTitle: "OK", handler: nil)
                    print(error)
                }
            }
        }
    }
    
    /// Uses Result and Grand Central Dispatch (GCD) to effeciently retrieve the JSON data from the given url.
    /// A DispatchSemaphore is used to wait until a signal is received meaning either success or failure has occurred..
    /// - Parameter urlString: The url to retrieve data from.
    /// - Returns: A Result value containing either a success or failure, and the associated value in each case.
    private func getResults(for urlString: String) -> Result<JSON, ValidationError> {
        var result: Result<JSON, ValidationError>!
        
        let semaphore = DispatchSemaphore(value: 0)
        
        guard let url = URL(string: urlString) else {
            result = .failure(ValidationError(errorType: .invalidURL(urlString)))
            return result
        }
        guard let data = try? Data(contentsOf: url) else {
            result = .failure(ValidationError(errorType: .badData))
            return result
        }
        guard let json = try? JSON(data: data) else {
            result = .failure(ValidationError(errorType: .badJSON))
            return result
        }
        
        result = .success(json)
        semaphore.signal()
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        return result
    }
    
    /// Parses through the JSON object to create an array of Petition objects
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
                    tempArray.append(
                        Petition(petitionID: petitionID,
                                 title: title,
                                 body: body,
                                 signatureCount: signatureCount,
                                 signaturesNeeded: signaturesNeeded))
                }
            }
            updateUI(with: unfilteredPetitions)
        } else {
            updateUI(with: [Petition]())
        }
    }
    
    /// Stops user interaction by disabling the previous/next buttons and displaying an activity indicator.
    private func pauseUI() {
        previousBtn.isEnabled = false
        nextBtn.isEnabled = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    /// Updates the UI to display the array of Petition objects.
    /// - Parameter petitions: The array to display.
    private func updateUI(with petitions: [Petition]) {
        title = "Petitions \(offset + 1)-\(offset + limit)"
        currentPetitions.removeAll()
        currentPetitions.append(contentsOf: petitions)
        previousBtn.isEnabled = true
        nextBtn.isEnabled = true
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        petitionsTableView.reloadData()
    }
    
    /// Convenience method that displays a simple UIAlertController.
    /// - Parameters:
    ///   - alertTitle: Title for alert.
    ///   - alertMessage: Message for alert.
    ///   - actionTitle: Title for action.
    ///   - handler: Optional handler.
    private func displayError(alertTitle: String?, alertMessage: String?, actionTitle: String?, handler: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: actionTitle, style: .default, handler: handler))
        self.present(alertController, animated: true)
    }
    
    /// Filters through an array of Petitions searching for objects that contain the keyword as a title.
    /// The results are then returned as a Result value.
    /// - Parameters:
    ///   - keyword: The title the user is looking for.
    ///   - petitions: The array of Petition objects to search through.
    /// - Returns: A Result value indicating a success or failure.
    private func filter(by keyword: String, in petitions: [Petition]) -> Result<[Petition], ValidationError> {
        let lowerKeyword = keyword.lowercased()
        var tempArray = [Petition]()
        
        for petition in petitions {
            if petition.title.lowercased().contains(lowerKeyword) {
                tempArray.append(petition)
            }
        }
        
        if tempArray.count == 0 {
            return .failure(ValidationError(errorType: .noItemsFound))
        } else {
            return .success(tempArray)
        }
    }
    
    
    /// Displays a sheet of possible actions when the RightBarButtonItem is clicked.
    /// Possible actions include "Search", "Reset",  and "Cancel"
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
    
    /// Displays a UIAlertController that allows users to search for Petitions by a keyword.
    private func displaySearchAlert() {
        let alertController = UIAlertController(title: "Search for", message: nil, preferredStyle: .alert)
        alertController.addTextField { (uiTextField) in
            uiTextField.placeholder = "keyword"
        }
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            if let title = alertController.textFields?.first?.text, title.count > 0 {
                let results = self.filter(by: title, in: self.currentPetitions)
                
                switch results {
                case let .success(filtered):
                    self.updateUI(with: filtered)
                case let .failure(error):
                    self.displayError(alertTitle: "Oops", alertMessage: error.shortDescription, actionTitle: "OK", handler: nil)
                }
            } else {
                self.displayError(alertTitle: "Oops", alertMessage: "You need to enter a keyword to search for!", actionTitle: "OK", handler: nil)
            }
        }))
        present(alertController, animated: true)
    }
    
    /// Loads the previous 25 Petitions
    @IBAction func previousBtnTapped(_ sender: UIButton) {
        if offset >= 25 {
            offset -= 25
            
            if reachability.connectionIsAvailable {
                loadJSON()
            } else {
                displayError(alertTitle: "Oops", alertMessage: "Network connection not detected!\nTry again later.", actionTitle: "Ok", handler: nil)
            }
        }
    }
    
    /// Loads the next 25 Petitions
    @IBAction func nextBtnTapped(_ sender: UIButton) {
        offset += 25
        
        if reachability.connectionIsAvailable {
            loadJSON()
        } else {
            displayError(alertTitle: "Oops", alertMessage: "Network connection not detected!\nTry again later.", actionTitle: "Ok", handler: nil)
        }
    }
    
    /// Sets up the UIBackButtonItem for the next ViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        
    }
}

/// UITableView delegate and data source methods
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

