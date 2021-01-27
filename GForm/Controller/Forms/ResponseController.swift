//
//  ResponseController.swift
//  GForm
//
//  Created by Kennan Trevyn Zenjaya on 08/01/21.
//

import LBTAComponents
import Firebase

class ResponseController: UITableViewController, UITextFieldDelegate {
    
    var formID: String?
    
    var userType: String?
    
    var numberOfResponse: Int? {
        didSet {
            if numberOfResponse == 0 {
                noResponseLabel.alpha = 1
                userResponses.removeAll()
                self.tableView.reloadData()
            } else {
                userResponses.removeAll()
                self.tableView.reloadData()
                noResponseLabel.alpha = 0
                observeResponse()
            }
        }
    }
    
    var refreshController = UIRefreshControl()
    
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    lazy var noResponseLabel: UILabel = {
        let label = UILabel()
        label.text = "No responses yet."
        label.textAlignment = .center
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: fourteen, weight: .regular)
        label.alpha = 0
        return label
    }()
    
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.addTarget(self, action: #selector(handleDatePickerValueChanged), for: .valueChanged)
        return picker
    }()
    
    let dateTextField = UITextField()
    var editAlertController: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavbar()
        setupRefreshController()
        
        view.addSubview(noResponseLabel)
        
        noResponseLabel.centerXAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerXAnchor).isActive = true
        noResponseLabel.centerYAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerYAnchor).isActive = true
        noResponseLabel.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: thirty)
        
        tableView.showsVerticalScrollIndicator = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        Database.database().reference().child("Forms").removeAllObservers()
        Database.database().reference().child("Responses").removeAllObservers()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return userResponses.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userResponses[section].responses!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        
        cell.textLabel?.text = userResponses[indexPath.section].responses![indexPath.row].title
        cell.textLabel?.font = UIFont.systemFont(ofSize: sixteen, weight: .bold)
        cell.textLabel?.numberOfLines = 0
    
        if userResponses[indexPath.section].responses![indexPath.row].dataType == "Date" {
            
            let timestamp = Double((userResponses[indexPath.section].responses![indexPath.row].response!))

            let date = Date(timeIntervalSince1970: timestamp!)
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "dd MMM yyyy" //Specify your format that you want
            let strDate = dateFormatter.string(from: date)

            cell.detailTextLabel?.text = strDate
            
        } else {
            
            cell.detailTextLabel?.text = userResponses[indexPath.section].responses![indexPath.row].response
            
        }
        
        cell.backgroundColor = hexStringToUIColor(hex: userResponses[indexPath.section].responses![indexPath.row].color ?? "")
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let popUp = UIAlertController(title: "Confirmation", message: "Do you want to edit or delete this response?", preferredStyle: .actionSheet)
        popUp.addAction(UIAlertAction(title: "Edit Element", style: .default, handler: { (action) in
            
            self.handleEditResponseElement(indexPath: indexPath)
            
        }))
        popUp.addAction(UIAlertAction(title: "Delete Response", style: .destructive, handler: { (action) in
            
            self.handleDeleteResponse(indexPath: indexPath)
            
        }))
        popUp.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in

        }))
        
        self.present(popUp, animated: true) {}
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Response \(section + 1)"
    }
    
}

extension ResponseController {
    
    private func setupNavbar() {
        
        navigationItem.title = "Responses"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let barButton = UIBarButtonItem(customView: self.activityIndicator)
        navigationItem.rightBarButtonItem = barButton
        
        activityIndicator.style = .medium
        
    }
    
    private func setupRefreshController() {
        
        refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshController.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshController)
        
    }
    
    @objc func refresh(_ sender: AnyObject) {
        observeResponse()
    }
    
    private func observeResponse() {
        
        var counter = 0
        
        userResponses.removeAll()
        
        self.tableView.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        
        guard let currentUID = Auth.auth().currentUser?.uid else {
            return
        }
        
        Database.database().reference().child("Forms").child(formID!).child("Responses").observe(.childAdded, with: { (snapshot) in
            
            let responseID = snapshot.key
            Database.database().reference().child("Responses").child(responseID).child("Other").observeSingleEvent(of: .value) { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let userID = dictionary["User ID"] as? String
                
                if self.userType == "Developer" {
                    
                    counter += 1
                    
                    if currentUID == userID {
                        
                        let userResponse = UserResponse()
                        userResponse.responseID = responseID
                        userResponse.responses = [Response]()
                        userResponses.append(userResponse)
                        
                        if counter == self.numberOfResponse {
                            self.observeElements()
                        }
                        
                    } else {
                        
                        if counter == self.numberOfResponse {
                            
                            if userResponses.count == 0 {
                                self.activityIndicator.stopAnimating()
                                self.noResponseLabel.alpha = 1
                                self.tableView.isUserInteractionEnabled = true
                                self.tableView.reloadData()
                            } else {
                                self.observeElements()
                            }
                             
                        }
                        
                    }
                    
                } else {
                    
                    let userResponse = UserResponse()
                    userResponse.responseID = responseID
                    userResponse.responses = [Response]()
                    userResponses.append(userResponse)
                    
                    if userResponses.count == self.numberOfResponse {
                        self.observeElements()
                    }
                    
                }
                
            }
            
        }, withCancel: nil)
        
    }
    
    private func observeElements() {
        
        for i in 0..<numberOfResponse! {
            
            if self.userType == "Developer" {
                
                if i > userResponses.count - 1 {
                    
                } else {
                    
                    let responseID = userResponses[i].responseID

                    Database.database().reference().child("Responses").child(responseID!).child("Elements").observe(.childAdded) { (snapshot) in

                        let elementID = snapshot.key
                        Database.database().reference().child("Elements").child(elementID).observeSingleEvent(of: .value) { (snapshot) in

                            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                                return
                            }

                            let response = Response()
                            response.elementID = elementID
                            response.title = dictionary["Title"] as? String
                            response.dataType = dictionary["Data Type"] as? String
                            response.seqNo = dictionary["Seq No"] as? String
                            response.color = dictionary["Color"] as? String

                            Database.database().reference().child("Responses").child(responseID!).child("Elements").child(elementID).observeSingleEvent(of: .value) { (snapshot) in

                                guard let dictionary1 = snapshot.value as? [String: AnyObject] else {
                                    return
                                }

                                response.response = dictionary1["Response"] as? String
                                
                                userResponses[i].responses?.append(response)
                                
                                DispatchQueue.main.async {

                                    self.refreshController.endRefreshing()

                                    self.activityIndicator.stopAnimating()
                                
                                    self.tableView.isUserInteractionEnabled = true

                                    self.tableView.reloadData()

                                }

                            }

                        }

                    } withCancel: { (error) in

                    }
                    
                }
                
            } else {
                
                let responseID = userResponses[i].responseID

                Database.database().reference().child("Responses").child(responseID!).child("Elements").observe(.childAdded) { (snapshot) in

                    let elementID = snapshot.key
                    Database.database().reference().child("Elements").child(elementID).observeSingleEvent(of: .value) { (snapshot) in

                        guard let dictionary = snapshot.value as? [String: AnyObject] else {
                            return
                        }

                        let response = Response()
                        response.elementID = elementID
                        response.title = dictionary["Title"] as? String
                        response.dataType = dictionary["Data Type"] as? String
                        response.seqNo = dictionary["Seq No"] as? String
                        response.color = dictionary["Color"] as? String

                        Database.database().reference().child("Responses").child(responseID!).child("Elements").child(elementID).observeSingleEvent(of: .value) { (snapshot) in

                            guard let dictionary1 = snapshot.value as? [String: AnyObject] else {
                                return
                            }

                            response.response = dictionary1["Response"] as? String
                            
                            userResponses[i].responses?.append(response)
                            
                            DispatchQueue.main.async {

                                self.refreshController.endRefreshing()

                                self.activityIndicator.stopAnimating()
                                
                                self.tableView.isUserInteractionEnabled = true

                                self.tableView.reloadData()

                            }

                        }

                    }

                } withCancel: { (error) in

                }
                
            }
            
        }
        
    }
    
    private func handleDeleteResponse(indexPath: IndexPath) {
        
        let popUp = UIAlertController(title: "Confirmation", message: "Are you sure want to delete this response?", preferredStyle: .alert)
        popUp.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            
            self.tableView.isUserInteractionEnabled = false
            self.activityIndicator.startAnimating()
            
            let responseID = userResponses[indexPath.section].responseID
            
            Database.database().reference().child("Forms").child(self.formID!).child("Other").observeSingleEvent(of: .value) { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }

                let numberOfResponse = dictionary["Number of Response"] as? Int
                let numberOfResponseAfter = numberOfResponse! - 1
                let numberOfResponseAfterValue = ["Number of Response": numberOfResponseAfter]
                
                Database.database().reference().child("Forms").child(self.formID!).child("Other").updateChildValues(numberOfResponseAfterValue) { (error, ref) in
                    
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    Database.database().reference().child("Forms").child(self.formID!).child("Responses").child(responseID!).removeValue { (error, ref) in
                        
                        if error != nil {
                            print(error!)
                            return
                        }
                        
                        Database.database().reference().child("Responses").child(responseID!).removeValue { (error, ref) in
                            
                            if error != nil {
                                print(error!)
                                return
                            }
                            
                            DispatchQueue.main.async {
                                
                                self.tableView.isUserInteractionEnabled = true
                                self.activityIndicator.stopAnimating()
                                
                                userResponses.remove(at: indexPath.section)
                                
                                let indexSet = IndexSet(arrayLiteral: indexPath.section)
                                self.tableView.deleteSections(indexSet, with: .automatic)
                                
                                self.tableView.reloadData()
                                
                                if userResponses.count == 0 {
                                    self.noResponseLabel.alpha = 1
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }))
        popUp.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in

        }))
        
        self.present(popUp, animated: true) {}
        
    }
    
    private func handleEditResponseElement(indexPath: IndexPath) {
        
        let responseID = userResponses[indexPath.section].responseID
        let elementID = userResponses[indexPath.section].responses![indexPath.row].elementID
        
        let title = userResponses[indexPath.section].responses![indexPath.row].title
        let currentResponse = userResponses[indexPath.section].responses![indexPath.row].response
        let dataType =  userResponses[indexPath.section].responses![indexPath.row].dataType
        
        editAlertController = UIAlertController(title: title, message: "Enter your new response below", preferredStyle: .alert)
        
        editAlertController!.addTextField { [self] (textField) in
            
            
            textField.layer.borderWidth = 0
            textField.delegate = dateTextField.delegate
            
            if dataType == "Number" {
                
                textField.text = currentResponse
                textField.keyboardType = .numberPad
                
            } else if dataType == "Date" {
                
                let timestamp = Double(currentResponse!)!
                
                let date = Date(timeIntervalSince1970: timestamp)
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
                dateFormatter.locale = NSLocale.current
                dateFormatter.dateFormat = "dd MMM yyyy" //Specify your format that you want
                let strDate = dateFormatter.string(from: date)
                
                textField.text = strDate
                textField.inputView = self.datePicker
                
            } else {
                
                textField.text = currentResponse
                textField.keyboardType = .default
                
            }
            
        }
        editAlertController!.addAction(UIAlertAction(title: "Apply", style: .default, handler: { [self] (_) in
            
            self.tableView.isUserInteractionEnabled = false
            self.activityIndicator.startAnimating()
            
            var elementValue = ["":""]
            
            if dataType == "Date" {
                elementValue = ["Response": String(self.datePicker.date.timeIntervalSince1970)]
                userResponses[indexPath.section].responses![indexPath.row].response = String(self.datePicker.date.timeIntervalSince1970)
            } else {
                elementValue = ["Response": self.editAlertController!.textFields![0].text!]
                userResponses[indexPath.section].responses![indexPath.row].response = self.editAlertController!.textFields![0].text
            }
            
            Database.database().reference().child("Responses").child(responseID!).child("Elements").child(elementID!).updateChildValues(elementValue as [AnyHashable : Any]) { (error, ref) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
                DispatchQueue.main.async {
                    
                    self.tableView.isUserInteractionEnabled = true
                    self.activityIndicator.stopAnimating()
                    
                    self.tableView.reloadData()
                    
                }
                
            }
            
        }))
        editAlertController!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            
        }))
        self.present(editAlertController!, animated: true, completion: nil)
        
    }
    
    @objc private func handleDatePickerValueChanged() {
        
        let timestamp = datePicker.date.timeIntervalSince1970
        
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd MMM yyyy" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        
        editAlertController!.textFields![0].text = strDate
        
    }
    
}
