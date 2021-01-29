//
//  FillFormController.swift
//  GForm
//
//  Created by Kennan Trevyn Zenjaya on 02/01/21.
//

import LBTAComponents
import Firebase

class FillFormController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var formID: String?
    
    var numberOfElement: Int? {
        didSet {
            if numberOfElement == 0 {
                fillElementsDictionary.removeAll()
                fillElements.removeAll()
                noElementLabel.alpha = 1
                self.tableView.reloadData()
            } else {
                noElementLabel.alpha = 0
                observeElements()
            }
        }
    }
    
    var formTitle: String? {
        didSet {
            navigationItem.title = formTitle
        }
    }
    
    lazy var noElementLabel: UILabel = {
        let label = UILabel()
        label.text = "No elements yet."
        label.textAlignment = .center
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: fourteen, weight: .regular)
        label.alpha = 0
        return label
    }()
    
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavbar()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleKeyboardDismiss))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
        
        view.addSubview(noElementLabel)
        
        noElementLabel.centerXAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerXAnchor).isActive = true
        noElementLabel.centerYAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerYAnchor).isActive = true
        noElementLabel.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: thirty)
        
        tableView.showsVerticalScrollIndicator = false
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cellId")

        if fillElements[indexPath.section].dataType != "Date" {
            
            if fillElements[indexPath.section].dataType == "Long Text" {
                
                let view = UIView()
                
                let responseTextField = UITextView()
                
                cell.addSubview(view)
                view.addSubview(responseTextField)
                
                view.fillSuperview()
                
                responseTextField.delegate = self
                responseTextField.tag = indexPath.section
                
                if fillElements[indexPath.section].response != "" {
                    responseTextField.text = fillElements[indexPath.section].response
                    responseTextField.textColor = .label
                } else {
                    responseTextField.text = "\(fillElements[indexPath.section].dataType ?? "") response here"
                    responseTextField.textColor = .tertiaryLabel
                }
                
                responseTextField.font = UIFont.systemFont(ofSize: eighteen)
                responseTextField.backgroundColor = hexStringToUIColor(hex: fillElements[indexPath.section].color ?? "")
                responseTextField.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: four, leftConstant: fourteen, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
                
            } else {
                
                let view = UIView()
                
                let responseTextField = UITextField()
                
                cell.addSubview(view)
                view.addSubview(responseTextField)
                
                view.fillSuperview()
                
                responseTextField.delegate = self
                responseTextField.tag = indexPath.section
                
                if fillElements[indexPath.section].dataType == "Number" {
                    responseTextField.keyboardType = .numberPad
                } else {
                    responseTextField.keyboardType = .default
                }
                
                if fillElements[indexPath.section].response != "" {
                    responseTextField.text = fillElements[indexPath.section].response
                }
                
                responseTextField.placeholder = "\(fillElements[indexPath.section].dataType ?? "") response here"
                responseTextField.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: fourteen, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
                
            }
            
        } else {
            
            let picker = UIDatePicker()
            
            if #available(iOS 14, *) {
                picker.preferredDatePickerStyle = .wheels
            }
            
            picker.datePickerMode = UIDatePicker.Mode.date
            picker.tag = indexPath.section
            picker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
            
            if fillElements[indexPath.section].response != "" {
                
                let unixTimestamp = Double(fillElements[indexPath.section].response!)
                let date = Date(timeIntervalSince1970: unixTimestamp!)
                
                picker.date = date
                
            } else {
                
                let date = Date()
                
                picker.date = date
                
            }
            
            cell.addSubview(picker)
            
            picker.fillSuperview()
            
        }
        
        cell.contentView.isUserInteractionEnabled = false
        cell.backgroundColor = hexStringToUIColor(hex: fillElements[indexPath.section].color ?? "")
        
        return cell
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fillElements.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fillElements[section].title
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if fillElements[indexPath.section].dataType == "Long Text" {
            return oneFifty
        }
        return fifty
    }
    
}

extension FillFormController {
    
    private func setupNavbar() {
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.setRightBarButton(UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(handleCheckSubmitForm)), animated: true)
        
        activityIndicator.style = .medium
        
    }
    
    private func observeElements() {
        
        fillElementsDictionary.removeAll()
        fillElements.removeAll()
        
        self.tableView.isUserInteractionEnabled = false
        
        var barButton = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.rightBarButtonItem = barButton

        activityIndicator.startAnimating()
        
        Database.database().reference().child("Forms").child(formID!).child("Elements").observe(.childAdded) { (snapshot) in
            
            let elementID = snapshot.key
            Database.database().reference().child("Elements").child(elementID).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let title = dictionary["Title"] as? String
                let dataType = dictionary["Data Type"] as? String
                let seqNo = dictionary["Seq No"] as? String
                let color = dictionary["Color"] as? String
                
                let responseElement = FillElement()
                responseElement.id = elementID
                responseElement.title = title
                responseElement.dataType = dataType
                responseElement.seqNo = seqNo
                responseElement.color = color
                
                let date = Date()
                
                if dataType == "Date" {
                    responseElement.response = String(date.timeIntervalSince1970)
                } else {
                    responseElement.response = ""
                }
                
                fillElements.append(responseElement)
                
                fillElementsDictionary[elementID] = responseElement
                fillElements = Array(fillElementsDictionary.values)
                fillElements.sort(by: { (element1, element2) -> Bool in
                    
                    return (Int(element1.seqNo!)!) < (Int(element2.seqNo!)!)
                    
                })
                
                DispatchQueue.main.async {
                    
                    self.activityIndicator.stopAnimating()
                    
                    barButton = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(self.handleCheckSubmitForm))
                    self.navigationItem.rightBarButtonItem = barButton
                    
                    self.tableView.isUserInteractionEnabled = true
                    
                    self.tableView.reloadData()
                    
                }
                
            } withCancel: { (error) in
                
            }
            
        }
        
    }
    
    @objc private func handleCheckSubmitForm() {
        
        self.tableView.reloadData()
        
        var counter = 0
        
        for item in fillElements {
            
            if item.response == "" {
                
                let popUp = UIAlertController(title: "We're sorry for the inconvenience", message: "Please fill in all field required", preferredStyle: .alert)
                popUp.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    
                    
                }))
                
                self.present(popUp, animated: true) {}
                
                break
                
            } else {
                
                if counter == fillElements.count - 1 {
                    handleSubmitForm()
                } else {
                    counter += 1
                }
                
            }
            
        }
        
    }
    
//    private func handleSubmitForm() {
//
//        guard let currentUID = Auth.auth().currentUser?.uid else {
//            return
//        }
//
//        if numberOfElement == 0 {
//
//        } else {
//
//            self.tableView.isUserInteractionEnabled = false
//
//            var barButton = UIBarButtonItem(customView: activityIndicator)
//            self.navigationItem.rightBarButtonItem = barButton
//
//            activityIndicator.startAnimating()
//
//            var counter = 0
//
//            Database.database().reference().child("Forms").child(self.formID!).child("Other").observeSingleEvent(of: .value) { (snapshot) in
//
//                guard let dictionary = snapshot.value as? [String: AnyObject] else {
//                    return
//                }
//
//                let numberOfResponse = dictionary["Number of Response"] as? Int
//                let numberOfResponseAfter = numberOfResponse! + 1
//                let numberOfResponseAfterValue = ["Number of Response": numberOfResponseAfter]
//
//                Database.database().reference().child("Forms").child(self.formID!).child("Other").updateChildValues(numberOfResponseAfterValue) { (error, ref) in
//
//                    if error != nil {
//                        print(error!)
//                        return
//                    }
//
//                    for item in fillElements {
//
//                        let elementID = item.id
//                        let responseValue = ["Response": item.response, "User ID": currentUID]
//
//                        let responsesRef = Database.database().reference().child("Responses").childByAutoId()
//                        let responseKey = responsesRef.key
//
//                        let responseIDValue = [responseKey: 1]
//
//                        Database.database().reference().child("Elements").child(elementID!).child("Responses").updateChildValues(responseIDValue) { (error, ref) in
//
//                            if error != nil {
//                                print(error!)
//                                return
//                            }
//
//                        }
//
//                        responsesRef.updateChildValues(responseValue as [AnyHashable : Any]) { (error, ref) in
//
//                            if error != nil {
//                                print(error!)
//                                return
//                            }
//
//                            if counter == fillElements.count - 1 {
//
//                                self.activityIndicator.stopAnimating()
//
//                                barButton = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(self.handleCheckSubmitForm))
//                                self.navigationItem.rightBarButtonItem = barButton
//
//                                self.tableView.isUserInteractionEnabled = true
//
//                                let alert = UIAlertController(title: "Your response has been submitted successfully!", message: "Thankyou for filling this form😊", preferredStyle: .alert)
//
//                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (_) in
//
//                                    self.navigationController?.popViewController(animated: true)
//
//                                }))
//                                self.present(alert, animated: true, completion: nil)
//
//                            } else {
//
//                                counter += 1
//
//                            }
//
//                        }
//
//                    }
//
//                }
//
//            }
//
//        }
//
//    }
    
    private func handleSubmitForm() {
            
            self.tableView.isUserInteractionEnabled = false

            var barButton = UIBarButtonItem(customView: activityIndicator)
            self.navigationItem.rightBarButtonItem = barButton

            activityIndicator.startAnimating()

            guard let currentUID = Auth.auth().currentUser?.uid else {
                return
            }

            var counter = 0

            let responsesRef = Database.database().reference().child("Responses").childByAutoId()
            let responseKey = responsesRef.key

            let userIDResponseValue = ["User ID": currentUID]

            responsesRef.child("Other").updateChildValues(userIDResponseValue) { (error, ref) in

                if error != nil {
                    print(error!)
                    return
                }

                let responseIDValue = [responseKey: 1]

                Database.database().reference().child("Forms").child(self.formID!).child("Responses").updateChildValues(responseIDValue) { (error, ref) in

                    if error != nil {
                        print(error!)
                        return
                    }

                    Database.database().reference().child("Forms").child(self.formID!).child("Other").observeSingleEvent(of: .value) { (snapshot) in

                        guard let dictionary = snapshot.value as? [String: AnyObject] else {
                            return
                        }

                        let numberOfResponse = dictionary["Number of Response"] as? Int
                        let numberOfResponseAfter = numberOfResponse! + 1
                        let numberOfResponseAfterValue = ["Number of Response": numberOfResponseAfter]

                        Database.database().reference().child("Forms").child(self.formID!).child("Other").updateChildValues(numberOfResponseAfterValue) { (error, ref) in

                            if error != nil {
                                print(error!)
                                return
                            }

                            for item in fillElements {
                                
                                let elementID = item.id
                                let responseValue = ["Response": item.response]
                                
                                responsesRef.child("Elements").child(elementID!).updateChildValues(responseValue as [AnyHashable : Any]) { (error, ref) in

                                    if error != nil {
                                        print(error!)
                                        return
                                    }
                                    
                                    if counter == fillElements.count - 1 {
                                        
                                        self.activityIndicator.stopAnimating()

                                        barButton = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(self.handleCheckSubmitForm))
                                        self.navigationItem.rightBarButtonItem = barButton

                                        self.tableView.isUserInteractionEnabled = true

                                        let alert = UIAlertController(title: "Your response has been submitted successfully!", message: "Thankyou for filling this form😊", preferredStyle: .alert)

                                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (_) in

                                            self.navigationController?.popViewController(animated: true)

                                        }))
                                        self.present(alert, animated: true, completion: nil)
                                        
                                    } else {
                                        
                                        counter += 1
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }

                    }

                }

            }
            
        }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let index = textField.tag
        fillElements[index].response = textField.text
        self.tableView.reloadSections(IndexSet(integersIn: index...index), with: .none)
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        let index = textView.tag
        
        if textView.text.isEmpty {
            textView.text = "\(fillElements[index].dataType ?? "") response here"
            textView.textColor = UIColor.tertiaryLabel
        } else {
            fillElements[index].response = textView.text
            self.tableView.reloadSections(IndexSet(integersIn: index...index), with: .none)
        }
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.tertiaryLabel {
            textView.text = nil
            textView.textColor = UIColor.label
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func handleKeyboardDismiss() {
        
        self.view.endEditing(true)
        
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker){
            
        let index = sender.tag
        
        fillElements[index].response = String(sender.date.timeIntervalSince1970)
        self.tableView.reloadSections(IndexSet(integersIn: index...index), with: .none)
        
    }
    
}
