//
//  ViewController.swift
//  GForm
//
//  Created by Kennan Trevyn Zenjaya on 01/01/21.
//

import LBTAComponents
import Firebase

class FormListController: UITableViewController {
    
    var refreshController = UIRefreshControl()

    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        observeNumberOfForms()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(observeNumberOfForms), name: NSNotification.Name(rawValue: "reloadFormList"), object: nil)
        
        setupNavbar()
        setupRefreshController()
        
        tableView.showsVerticalScrollIndicator = false
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cellId")
        
        if forms.count != 0 {
            
            let view = UIView()
            
            let titleLabel = UILabel()
            titleLabel.text = forms[indexPath.row].title
            titleLabel.textColor = UIColor.label
            titleLabel.font = UIFont.systemFont(ofSize: eighteen, weight: .bold)
            
            let dateCreationLabel = UILabel()
            
            let date = Date(timeIntervalSince1970: forms[indexPath.row].creationTimestamp!.doubleValue)
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "dd MMM yyyy" //Specify your format that you want
            let strDate = dateFormatter.string(from: date)
            
            dateCreationLabel.text = strDate
            dateCreationLabel.textColor = UIColor.label
            dateCreationLabel.font = UIFont.systemFont(ofSize: fourteen, weight: .regular)
            
            let uidLabel = UILabel()
            uidLabel.text = " \(forms[indexPath.row].uid ?? "") "
            uidLabel.textColor = .white
            uidLabel.backgroundColor = hexStringToUIColor(hex: "#375ECC")
            uidLabel.font = UIFont.systemFont(ofSize: fourteen, weight: .regular)
            uidLabel.layer.cornerRadius = three
            uidLabel.clipsToBounds = true
            
            let statusLabel = UILabel()
            statusLabel.text = " \(forms[indexPath.row].status ?? "") "
            statusLabel.textColor = .white
            statusLabel.backgroundColor = .systemGreen
            statusLabel.font = UIFont.systemFont(ofSize: fourteen, weight: .regular)
            statusLabel.layer.cornerRadius = three
            statusLabel.clipsToBounds = true
            
            if forms[indexPath.row].status == "Unpublished" {
                statusLabel.alpha = 0
            }
            
            let nORLabel = UILabel()
            nORLabel.text = "\(forms[indexPath.row].numberOfResponse ?? 0) Responses"
            nORLabel.textColor = UIColor.label
            nORLabel.font = UIFont.systemFont(ofSize: fourteen, weight: .medium)
            
            cell.addSubview(view)
            view.addSubview(titleLabel)
            view.addSubview(dateCreationLabel)
            view.addSubview(uidLabel)
            view.addSubview(statusLabel)
            view.addSubview(nORLabel)
            
            nORLabel.anchor(dateCreationLabel.topAnchor, left: nil, bottom: dateCreationLabel.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: twentyFour, widthConstant: 0, heightConstant: 0)
            
            statusLabel.anchor(uidLabel.topAnchor, left: uidLabel.rightAnchor, bottom: uidLabel.bottomAnchor, right: nil, topConstant: 0, leftConstant: eight, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            
            uidLabel.anchor(dateCreationLabel.topAnchor, left: dateCreationLabel.rightAnchor, bottom: dateCreationLabel.bottomAnchor, right: nil, topConstant: 0, leftConstant: eight, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            
            dateCreationLabel.anchor(titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: nil, right: nil, topConstant: four, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            
            titleLabel.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: ten, leftConstant: twentyFour, bottomConstant: 0, rightConstant: 0, widthConstant: twoHundred, heightConstant: 0)
            
            view.fillSuperview()
            
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if forms[indexPath.row].status == "Published" {
            
            let responseListController = ResponseListController(style: .insetGrouped)
            responseListController.formID = forms[indexPath.row].id
            responseListController.formTitle = forms[indexPath.row].title
            responseListController.numberOfResponse = forms[indexPath.row].numberOfResponse
            navigationController?.pushViewController(responseListController, animated: true)
            
        } else {
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let popUp = UIAlertController(title: "Confirmation", message: "Are you sure want to delete this form?", preferredStyle: .alert)
            popUp.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                
                tableView.isUserInteractionEnabled = false
                
                var barButton = UIBarButtonItem(customView: self.activityIndicator)
                self.navigationItem.rightBarButtonItem = barButton

                self.activityIndicator.startAnimating()
                
                guard let currentUID = Auth.auth().currentUser?.uid else {
                    return
                }
                
                let formID = forms[indexPath.row].id
                
                // CHECK NUMBER OF ELEMENT
                Database.database().reference().child("Forms").child(formID!).child("Other").observeSingleEvent(of: .value) { (snapshot) in
                    
                    guard let dictionary = snapshot.value as? [String: AnyObject] else {
                        return
                    }
                    
                    let numberOfElement = dictionary["Element Count"] as? Int
                    let numberOfResponse = dictionary["Number of Response"] as? Int
                    
                    if numberOfElement! > 0 {
                        
                        Database.database().reference().child("Forms").child(formID!).child("Elements").observe(.childAdded) { (snapshot) in
                            
                            let elementID = snapshot.key
                            Database.database().reference().child("Elements").child(elementID).removeValue { (error, ref) in
                                
                                
                                
                            }
                            
                        }
                        
                        if (numberOfResponse! > 0) {
                            
                            Database.database().reference().child("Forms").child(formID!).child("Responses").observe(.childAdded) { (snapshot) in
                                
                                let responseID = snapshot.key
                                Database.database().reference().child("Responses").child(responseID).removeValue { (error, ref) in
                                    
                                    
                                    
                                }
                                
                            }
                            
                        } else {
                            
                        }
                        
                        Database.database().reference().child("Users").child(currentUID).child("Forms").child(formID!).removeValue { (error, ref) in
                            
                            if error != nil {
                                print(error!)
                                return
                            }
                            
                            Database.database().reference().child("Forms").child(formID!).removeValue { (error, ref) in
                                
                                if error != nil {
                                    print(error!)
                                    return
                                }
                                
                                Database.database().reference().child("Users").child(currentUID).child("Other").observeSingleEvent(of: .value) { (snapshot) in
                                    
                                    guard let dictionary = snapshot.value as? [String: AnyObject] else {
                                        return
                                    }
                                    
                                    let numberOfForms = dictionary["Number of Forms"] as? Int
                                    
                                    let numberOfFormsAfter = numberOfForms! - 1
                                    let numberOfFormsAfterValue = ["Number of Forms": numberOfFormsAfter]
                                    
                                    Database.database().reference().child("Users").child(currentUID).child("Other").updateChildValues(numberOfFormsAfterValue) { (error, ref) in
                                        
                                        if error != nil {
                                            print(error!)
                                            return
                                        }
                                        
                                        DispatchQueue.main.async {
                                            
                                            tableView.isUserInteractionEnabled = true
                                            
                                            self.activityIndicator.stopAnimating()
                                            barButton = UIBarButtonItem(image: UIImage(named: "addIcon"), style: .plain, target: self, action: #selector(self.addNewForm))
                                            self.navigationItem.rightBarButtonItem = barButton
                                            
                                            forms.remove(at: indexPath.row)
                                            tableView.deleteRows(at: [indexPath], with: .fade)
                                            
                                            if forms.count == 0 {
                                                self.observeNumberOfForms()
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    } else {
                        
                        Database.database().reference().child("Users").child(currentUID).child("Forms").child(formID!).removeValue { (error, ref) in
                            
                            if error != nil {
                                print(error!)
                                return
                            }
                            
                            Database.database().reference().child("Forms").child(formID!).removeValue { (error, ref) in
                                
                                if error != nil {
                                    print(error!)
                                    return
                                }
                                
                                Database.database().reference().child("Users").child(currentUID).child("Other").observeSingleEvent(of: .value) { (snapshot) in
                                    
                                    guard let dictionary = snapshot.value as? [String: AnyObject] else {
                                        return
                                    }
                                    
                                    let numberOfForms = dictionary["Number of Forms"] as? Int
                                    
                                    let numberOfFormsAfter = numberOfForms! - 1
                                    let numberOfFormsAfterValue = ["Number of Forms": numberOfFormsAfter]
                                    
                                    Database.database().reference().child("Users").child(currentUID).child("Other").updateChildValues(numberOfFormsAfterValue) { (error, ref) in
                                        
                                        if error != nil {
                                            print(error!)
                                            return
                                        }
                                        
                                        DispatchQueue.main.async {
                                            
                                            tableView.isUserInteractionEnabled = true
                                            
                                            self.activityIndicator.stopAnimating()
                                            barButton = UIBarButtonItem(image: UIImage(named: "addIcon"), style: .plain, target: self, action: #selector(self.addNewForm))
                                            self.navigationItem.rightBarButtonItem = barButton
                                            
                                            forms.remove(at: indexPath.row)
                                            tableView.deleteRows(at: [indexPath], with: .fade)
                                            
                                            if forms.count == 0 {
                                                self.observeNumberOfForms()
                                            }
                                            
                                        }
                                        
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
        
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let action = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completionHandler) in
            self?.handleEditForm(indexPath: indexPath)
            completionHandler(true)
        }
        action.backgroundColor = .systemBlue

        return UISwipeActionsConfiguration(actions: [action])
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sixtyEight
    }

}

extension FormListController {
    
    private func setupNavbar() {
        
        navigationItem.title = "Forms"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.setRightBarButton(UIBarButtonItem(image: UIImage(named: "addIcon"), style: .plain, target: self, action: #selector(addNewForm)), animated: true)
        
        activityIndicator.style = .medium
        
    }
    
    private func setupRefreshController() {
        
        refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshController.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshController)
        
    }
    
    @objc func refresh(_ sender: AnyObject) {
        observeNumberOfForms()
    }
    
    @objc private func observeNumberOfForms() {
        
        forms.removeAll()
        
        self.tableView.isUserInteractionEnabled = false
        
        var barButton = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.rightBarButtonItem = barButton

        activityIndicator.startAnimating()
        
        guard let currentUID = Auth.auth().currentUser?.uid else {
            return
        }
        
        Database.database().reference().child("Users").child(currentUID).child("Other").observeSingleEvent(of: .value) { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let numberOfForms = dictionary["Number of Forms"] as? Int
            
            if numberOfForms == 0 {
                
                self.refreshController.endRefreshing()
                
                self.activityIndicator.stopAnimating()
                
                barButton = UIBarButtonItem(image: UIImage(named: "addIcon"), style: .plain, target: self, action: #selector(self.addNewForm))
                self.navigationItem.rightBarButtonItem = barButton
                
                self.tableView.isUserInteractionEnabled = true
                self.tableView.reloadData()
                
            } else {
                
                self.observeForm()
                
            }
            
        }
        
    }
    
    private func observeForm() {
        
        guard let currentUID = Auth.auth().currentUser?.uid else {
            return
        }
        
        Database.database().reference().child("Users").child(currentUID).child("Forms").observe(.childAdded, with: { (snapshot) in
            
            let formID = snapshot.key
            Database.database().reference().child("Forms").child(formID).child("Other").observeSingleEvent(of: .value) { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let formTitle = dictionary["Title"] as? String
                let uid = dictionary["UID"] as? String
                let creationTimestamp = dictionary["Creation Timestamp"] as? NSNumber
                let numberOfResponse = dictionary["Number of Response"] as? Int
                let status = dictionary["Status"] as? String
                
                let form = Form()
                form.id = formID
                form.uid = uid
                form.title = formTitle
                form.creationTimestamp = creationTimestamp
                form.numberOfResponse = numberOfResponse
                form.status = status
                forms.append(form)
                
                DispatchQueue.main.async {
                    
                    self.refreshController.endRefreshing()
                    
                    self.activityIndicator.stopAnimating()
                    let barButton = UIBarButtonItem(image: UIImage(named: "addIcon"), style: .plain, target: self, action: #selector(self.addNewForm))
                    self.navigationItem.rightBarButtonItem = barButton
                    
                    self.tableView.isUserInteractionEnabled = true
                    self.tableView.reloadData()
                    
                }
                
            } withCancel: { (error) in
                
                
                
            }

        }, withCancel: nil)
        
    }
    
    @objc private func addNewForm() {
        
        let alert = UIAlertController(title: "Add new Form", message: "Enter your form title", preferredStyle: .alert)
        alert.addTextField { (textfield) in
            textfield.placeholder = "Title"
            textfield.layer.borderWidth = 0
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [self] (_) in
            
            self.tableView.isUserInteractionEnabled = false
            
            var barButton = UIBarButtonItem(customView: self.activityIndicator)
            self.navigationItem.rightBarButtonItem = barButton

            self.activityIndicator.startAnimating()
            
            let formTitle = alert.textFields![0].text
            
            if formTitle != "" {
                
                guard let currentUID = Auth.auth().currentUser?.uid else {
                    return
                }
                
                let formRef = Database.database().reference().child("Forms")
                let formKey = formRef.childByAutoId().key
                let formIDValue = [formKey: 1]
                
                let timeStampNow = Double(NSDate().timeIntervalSince1970)
                let formUID = self.randomString(length: 6)
                
                let formValue = ["Title": formTitle as Any, "UID": formUID, "Element Count": 0, "Creation Timestamp": timeStampNow, "Number of Response": 0, "Status": "Unpublished"] as [String : Any]
                
                Database.database().reference().child("Users").child(currentUID).child("Other").observeSingleEvent(of: .value) { (snapshot) in
                    
                    guard let dictionary = snapshot.value as? [String: AnyObject] else {
                        return
                    }
                    
                    let numberOfForms = dictionary["Number of Forms"] as? Int
                    
                    let numberOfFormsAfter = numberOfForms! + 1
                    let numberOfFormsAfterValue = ["Number of Forms": numberOfFormsAfter]
                    
                    Database.database().reference().child("Users").child(currentUID).child("Other").updateChildValues(numberOfFormsAfterValue) { (error, ref) in
                        
                        if error != nil {
                            print(error!)
                            return
                        }
                        
                        Database.database().reference().child("Users").child(currentUID).child("Forms").updateChildValues(formIDValue) { (error, ref) in
                            
                            if error != nil {
                                print(error!)
                                return
                            }
                            
                            formRef.child(formKey!).child("Other").updateChildValues(formValue as [AnyHashable : Any]) { (error, ref) in
                                
                                if error != nil {
                                    print(error!)
                                    return
                                }
                                
                                DispatchQueue.main.async {
                                    
                                    self.tableView.isUserInteractionEnabled = true
                                    
                                    self.activityIndicator.stopAnimating()
                                    barButton = UIBarButtonItem(image: UIImage(named: "addIcon"), style: .plain, target: self, action: #selector(self.addNewForm))
                                    self.navigationItem.rightBarButtonItem = barButton
                                    
                                    self.observeNumberOfForms()
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            } else {
                
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    private func handleEditForm(indexPath: IndexPath) {
        
        if forms[indexPath.row].status == "Published" {
            
            let alert = UIAlertController(title: "Your form is already published.", message: "", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (_) in

                self.navigationController?.popViewController(animated: true)

            }))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            let formController = FormController(style: .insetGrouped)
            formController.formID = forms[indexPath.row].id
            formController.formTitle = forms[indexPath.row].title
            formController.formStatus = forms[indexPath.row].status
            navigationController?.pushViewController(formController, animated: true)
            
        }
        
    }
    
    private func randomString(length: Int) -> String {
        
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
        
    }
    
}

