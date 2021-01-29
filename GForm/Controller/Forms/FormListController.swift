//
//  ViewController.swift
//  GForm
//
//  Created by Kennan Trevyn Zenjaya on 01/01/21.
//

import LBTAComponents
import Firebase

class FormListController: UITableViewController {
    
    var numberOfUserFormElement: Int?
    var numberOfDevFormElement: Int?
    
    var refreshController = UIRefreshControl()

    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    lazy var menuSegmentedController: UISegmentedControl = {
        let segmentedController = UISegmentedControl(items: ["Private", "Developer"])
        segmentedController.tintColor = UIColor(r: 13, g: 107, b: 255)
        segmentedController.selectedSegmentIndex = 0
        segmentedController.layer.cornerRadius = eight
        segmentedController.layer.masksToBounds = true
        segmentedController.layer.borderWidth = 1
        segmentedController.layer.borderColor = UIColor(r: 13, g: 107, b: 255).cgColor
        segmentedController.isUserInteractionEnabled = true
        
        if #available(iOS 13.0, *) {
            segmentedController.layer.borderWidth = 0
            segmentedController.backgroundColor = .clear
            segmentedController.selectedSegmentTintColor = UIColor(r: 13, g: 107, b: 255)
            segmentedController.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        } else {
            // Fallback on earlier versions
        }
        
        return segmentedController
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        observeUserNumberOfForms()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(observeUserNumberOfForms), name: NSNotification.Name(rawValue: "reloadFormList"), object: nil)
        
        setupNavbar()
        setupRefreshController()
        
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: fifty)
        
        view.addSubview(menuSegmentedController)
        
        menuSegmentedController.addTarget(self, action: #selector(handleMenuSelected), for: .valueChanged)
        menuSegmentedController.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: twentyFour, bottomConstant: twenty, rightConstant: twentyFour, widthConstant: 0, heightConstant: 0)
        
        tableView.tableHeaderView = view
        
        tableView.showsVerticalScrollIndicator = false
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if menuSegmentedController.selectedSegmentIndex == 0 {
            return privateForms.count
        }
        
        return developerForms.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if privateForms.count != 0 || developerForms.count != 0 {
            
            if menuSegmentedController.selectedSegmentIndex == 0 {
                
                let cell = UITableViewCell(style: .value1, reuseIdentifier: "cellId")
                
                let view = UIView()
                
                let titleLabel = UILabel()
                titleLabel.text = privateForms[indexPath.row].title
                titleLabel.textColor = UIColor.label
                titleLabel.font = UIFont.systemFont(ofSize: eighteen, weight: .bold)
                
                let dateCreationLabel = UILabel()
                
                let date = Date(timeIntervalSince1970: privateForms[indexPath.row].creationTimestamp!.doubleValue)
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
                dateFormatter.locale = NSLocale.current
                dateFormatter.dateFormat = "dd MMM yyyy" //Specify your format that you want
                let strDate = dateFormatter.string(from: date)
                
                dateCreationLabel.text = strDate
                dateCreationLabel.textColor = UIColor.label
                dateCreationLabel.font = UIFont.systemFont(ofSize: fourteen, weight: .regular)
                
                let nORLabel = UILabel()
                nORLabel.text = "\(privateForms[indexPath.row].numberOfResponse ?? 0) Responses"
                nORLabel.textColor = UIColor.label
                nORLabel.font = UIFont.systemFont(ofSize: fourteen, weight: .medium)
                
                cell.addSubview(view)
                view.addSubview(titleLabel)
                view.addSubview(dateCreationLabel)
                view.addSubview(nORLabel)
                
                nORLabel.anchor(dateCreationLabel.topAnchor, left: nil, bottom: dateCreationLabel.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: twentyFour, widthConstant: 0, heightConstant: 0)
                
                dateCreationLabel.anchor(titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: nil, right: nil, topConstant: four, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
                
                titleLabel.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: ten, leftConstant: twentyFour, bottomConstant: 0, rightConstant: 0, widthConstant: twoHundred, heightConstant: 0)
                
                view.fillSuperview()
                
                return cell
                
            }
            
        }
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cellId1")
        
        if privateForms.count != 0 || developerForms.count != 0 {
            
            let view = UIView()
            
            let titleLabel = UILabel()
            titleLabel.text = developerForms[indexPath.row].title
            titleLabel.textColor = UIColor.label
            titleLabel.font = UIFont.systemFont(ofSize: eighteen, weight: .bold)
            
            let dateCreationLabel = UILabel()
            
            let date = Date(timeIntervalSince1970: developerForms[indexPath.row].creationTimestamp!.doubleValue)
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "dd MMM yyyy" //Specify your format that you want
            let strDate = dateFormatter.string(from: date)
            
            dateCreationLabel.text = strDate
            dateCreationLabel.textColor = UIColor.label
            dateCreationLabel.font = UIFont.systemFont(ofSize: fourteen, weight: .regular)
            
            cell.addSubview(view)
            view.addSubview(titleLabel)
            view.addSubview(dateCreationLabel)
            
            dateCreationLabel.anchor(titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: nil, right: nil, topConstant: four, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            
            titleLabel.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: ten, leftConstant: twentyFour, bottomConstant: 0, rightConstant: 0, widthConstant: twoHundred, heightConstant: 0)
            
            view.fillSuperview()
            
        }
        
        return cell
        
    }
    
    private let responseListController = ResponseController(style: .insetGrouped)
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if menuSegmentedController.selectedSegmentIndex == 0 {
            responseListController.userType = "Private"
            responseListController.formID = privateForms[indexPath.row].id
            responseListController.formTitle = privateForms[indexPath.row].title
            responseListController.numberOfResponse = privateForms[indexPath.row].numberOfResponse
        } else {
            responseListController.userType = "Developer"
            responseListController.formID = developerForms[indexPath.row].id
            responseListController.formTitle = developerForms[indexPath.row].title
            responseListController.numberOfResponse = developerForms[indexPath.row].numberOfResponse
        }
        
        navigationController?.pushViewController(responseListController, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            
        if editingStyle == .delete {
            
            if menuSegmentedController.selectedSegmentIndex == 0 {
                
                let popUp = UIAlertController(title: "Confirmation", message: "Are you sure want to delete this form?", preferredStyle: .alert)
                popUp.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                        
                    tableView.isUserInteractionEnabled = false
                        
                    var barButton = UIBarButtonItem(customView: self.activityIndicator)
                    self.navigationItem.rightBarButtonItem = barButton

                    self.activityIndicator.startAnimating()
                        
                    guard let currentUID = Auth.auth().currentUser?.uid else {
                        return
                    }
                        
                    let formID = privateForms[indexPath.row].id!
                        
                    // CHECK NUMBER OF ELEMENT
                    Database.database().reference().child("Forms").child(formID).child("Other").observeSingleEvent(of: .value) { (snapshot) in
                            
                        guard let dictionary = snapshot.value as? [String: AnyObject] else {
                            return
                        }
                            
                        let numberOfElement = dictionary["Element Count"] as? Int
                        let numberOfResponse = dictionary["Number of Response"] as? Int
                            
                        if numberOfElement! > 0 {
                                
                            Database.database().reference().child("Forms").child(formID).child("Elements").observe(.childAdded) { (snapshot) in
                                    
                                let elementID = snapshot.key
                                Database.database().reference().child("Elements").child(elementID).removeValue { (error, ref) in
                                        
                                        
                                        
                                }
                                    
                            }
                                
                            if (numberOfResponse! > 0) {
                                    
                                Database.database().reference().child("Forms").child(formID).child("Responses").observe(.childAdded) {(snapshot) in
                                        
                                    let responseID = snapshot.key
                                    Database.database().reference().child("Responses").child(responseID).removeValue { (error, ref) in
                                            
                                            
                                            
                                    }
                                        
                                }
                                    
                            } else {
                                    
                            }
                                
                            Database.database().reference().child("Users").child(currentUID).child("Forms").child(formID).removeValue { (error, ref) in
                                    
                                if error != nil {
                                    print(error!)
                                    return
                                }
                                    
                                Database.database().reference().child("Forms").child(formID).removeValue { (error, ref) in
                                        
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

                                                if self.menuSegmentedController.selectedSegmentIndex == 0 {
                                                    privateForms.remove(at: indexPath.row)
                                                    tableView.deleteRows(at: [indexPath], with: .fade)
                                                    if privateForms.count == 0 {
                                                        self.observeUserNumberOfForms()
                                                    }
                                                } else {
                                                    developerForms.remove(at: indexPath.row)
                                                    tableView.deleteRows(at: [indexPath], with: .fade)
                                                    if developerForms.count == 0 {
                                                        self.observeUserNumberOfForms()
                                                    }
                                                }

                                            }
                                                
                                        }
                                            
                                    }
                                        
                                }
                                    
                            }
                                
                        } else {
                                
                            Database.database().reference().child("Users").child(currentUID).child("Forms").child(formID).removeValue { (error, ref) in
                                    
                                if error != nil {
                                    print(error!)
                                    return
                                }
                                    
                                Database.database().reference().child("Forms").child(formID).removeValue { (error, ref) in
                                        
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

                                                if self.menuSegmentedController.selectedSegmentIndex == 0 {
                                                    privateForms.remove(at: indexPath.row)
                                                    tableView.deleteRows(at: [indexPath], with: .fade)
                                                    if privateForms.count == 0 {
                                                        self.observeUserNumberOfForms()
                                                    }
                                                } else {
                                                    developerForms.remove(at: indexPath.row)
                                                    tableView.deleteRows(at: [indexPath], with: .fade)
                                                    if developerForms.count == 0 {
                                                        self.observeUserNumberOfForms()
                                                    }
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
                
            } else {
                
                let popUp = UIAlertController(title: "We're sorry for the inconvenience", message: "You can't edit or delete developer forms", preferredStyle: .alert)
                popUp.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    
                }))
                                
                self.present(popUp, animated: true) {}
                
            }
                
        }
            
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if menuSegmentedController.selectedSegmentIndex == 0 {
            
            let fillAction = UIContextualAction(style: .normal, title: "Fill") { [weak self] (fillAction, view, completionHandler) in
                self?.handleFillForm(indexPath: indexPath)
                completionHandler(true)
            }
            fillAction.backgroundColor = .systemBlue
            fillAction.image = UIImage(named: "fillIcon")
            
            let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (editAction, view, completionHandler) in
                self?.handleEditForm(indexPath: indexPath)
                completionHandler(true)
            }
            editAction.backgroundColor = .systemOrange
            editAction.image = UIImage(named: "editIcon")

            return UISwipeActionsConfiguration(actions: [editAction, fillAction])
            
        }
        
        let fillAction = UIContextualAction(style: .normal, title: "Fill") { [weak self] (fillAction, view, completionHandler) in
            self?.handleFillForm(indexPath: indexPath)
            completionHandler(true)
        }
        fillAction.backgroundColor = .systemBlue
        fillAction.image = UIImage(named: "fillIcon")
        
        return UISwipeActionsConfiguration(actions: [fillAction])
        
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
        observeUserNumberOfForms()
    }
    
    @objc func handleMenuSelected() {
        
        self.tableView.reloadData()
        
    }
    
    @objc private func observeUserNumberOfForms() {
        
        privateForms.removeAll()
        developerForms.removeAll()
        
        self.tableView.isUserInteractionEnabled = false
        
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
                
                self.observeDevNumberOfForms()
                
            } else {
                
                self.observeUserForm()
                self.observeDevNumberOfForms()
                
            }
            
        }
        
    }
    
    private func observeUserForm() {
        
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
                let creationTimestamp = dictionary["Creation Timestamp"] as? NSNumber
                let numberOfResponse = dictionary["Number of Response"] as? Int
                
                self.numberOfUserFormElement = dictionary["Element Count"] as? Int
                
                let form = Form()
                form.id = formID
                form.title = formTitle
                form.creationTimestamp = creationTimestamp
                form.numberOfResponse = numberOfResponse
                privateForms.append(form)
                
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
    
    @objc private func observeDevNumberOfForms() {
        
        privateForms.removeAll()
        developerForms.removeAll()
        
        self.tableView.isUserInteractionEnabled = false
        
        var barButton = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.rightBarButtonItem = barButton

        activityIndicator.startAnimating()
        
        Database.database().reference().child("Developer").child("Other").observeSingleEvent(of: .value) { (snapshot) in
            
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
                
                self.observeDevForm()
                
            }
            
        }
        
    }
    
    private func observeDevForm() {
        
        Database.database().reference().child("Developer").child("Forms").observe(.childAdded, with: { (snapshot) in
            
            let formID = snapshot.key
            Database.database().reference().child("Forms").child(formID).child("Other").observeSingleEvent(of: .value) { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let formTitle = dictionary["Title"] as? String
                let creationTimestamp = dictionary["Creation Timestamp"] as? NSNumber
                let numberOfResponse = dictionary["Number of Response"] as? Int
                
                self.numberOfDevFormElement = dictionary["Element Count"] as? Int
                
                let form = Form()
                form.id = formID
                form.title = formTitle
                form.creationTimestamp = creationTimestamp
                form.numberOfResponse = numberOfResponse
                developerForms.append(form)
                
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
                
                if checkFormTitleAvailability(newtitle: formTitle!, type: "Private") {
                    
                    guard let currentUID = Auth.auth().currentUser?.uid else {
                        return
                    }
                    
                    let formRef = Database.database().reference().child("Forms")
                    let formKey = formRef.childByAutoId().key
                    let formIDValue = [formKey: 1]
                    
                    let timeStampNow = Double(NSDate().timeIntervalSince1970)
                    
                    let formValue = ["Title": formTitle as Any, "Element Count": 0, "Creation Timestamp": timeStampNow, "Number of Response": 0] as [String : Any]
                    
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
                                        
                                        self.observeUserNumberOfForms()
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                } else {
                    
                    let popUp = UIAlertController(title: "We're sorry for the inconvenience", message: "Form title is already used", preferredStyle: .alert)
                    popUp.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        
                        DispatchQueue.main.async {
                            
                            self.tableView.isUserInteractionEnabled = true
                            
                            self.activityIndicator.stopAnimating()
                            barButton = UIBarButtonItem(image: UIImage(named: "addIcon"), style: .plain, target: self, action: #selector(self.addNewForm))
                            self.navigationItem.rightBarButtonItem = barButton
                            
                            self.observeUserNumberOfForms()
                            
                        }
                        
                    }))
                    
                    self.present(popUp, animated: true) {}
                    
                }
                
            } else {
                
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    private func handleEditForm(indexPath: IndexPath) {
        
        let formController = FormController(style: .insetGrouped)
        
        if menuSegmentedController.selectedSegmentIndex == 0 {
            formController.formID = privateForms[indexPath.row].id
            formController.formTitle = privateForms[indexPath.row].title
            formController.userType = "Private"
        } else {
            formController.formID = developerForms[indexPath.row].id
            formController.formTitle = developerForms[indexPath.row].title
            formController.userType = "Developer"
        }
        
        navigationController?.pushViewController(formController, animated: true)
        
    }
    
    private func handleFillForm(indexPath: IndexPath) {
        
        let fillFormController = FillFormController(style: .insetGrouped)
        
        if menuSegmentedController.selectedSegmentIndex == 0 {
            fillFormController.formID = privateForms[indexPath.row].id
            fillFormController.formTitle = privateForms[indexPath.row].title
            fillFormController.numberOfElement = numberOfUserFormElement
        } else {
            fillFormController.formID = developerForms[indexPath.row].id
            fillFormController.formTitle = privateForms[indexPath.row].title
            fillFormController.numberOfElement = numberOfDevFormElement
        }
        
        navigationController?.pushViewController(fillFormController, animated: true)
        
    }
    
}

