//
//  FormController.swift
//  GForm
//
//  Created by Kennan Trevyn Zenjaya on 01/01/21.
//

import LBTAComponents
import Firebase

class FormController: UITableViewController {

    var formID: String?
    
    var formTitle: String? {
        didSet {
            navigationItem.title = formTitle
        }
    }
    
    var userType: String?
    
    var refreshController = UIRefreshControl()

    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    lazy var noElementLabel: UILabel = {
        let label = UILabel()
        label.text = "No elements yet."
        label.textAlignment = .center
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: fourteen, weight: .regular)
        label.alpha = 0
        return label
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        checkNumberOfElement()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupNavbar()
        setupRefreshController()
        
        view.addSubview(noElementLabel)
        view.addSubview(activityIndicator)
        
        activityIndicator.centerXAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerYAnchor).isActive = true
        activityIndicator.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: thirty)
        
        noElementLabel.centerXAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerXAnchor).isActive = true
        noElementLabel.centerYAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerYAnchor).isActive = true
        noElementLabel.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: thirty)
        
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorColor = .clear
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        cell.textLabel?.text = elements[indexPath.row].title
        cell.textLabel?.font = UIFont.systemFont(ofSize: sixteen, weight: .semibold)
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = "Data Type : \(elements[indexPath.row].dataType ?? "")"
        cell.backgroundColor = hexStringToUIColor(hex: elements[indexPath.row].color ?? "")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let popUp = UIAlertController(title: deleteElementConfirmationTitle, message: deleteElementConfirmationMessage, preferredStyle: .alert)
            popUp.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                
                self.startLoadingSetup()
                
                Database.database().reference().child("Forms").child(self.formID!).child("Other").observeSingleEvent(of: .value) { (snapshot) in
                    
                    guard let dictionary = snapshot.value as? [String: AnyObject] else {
                        return
                    }
                    
                    let elementCount = dictionary["Element Count"] as? Int
                    let elementCountAfter = elementCount! - 1
                    
                    let formValue = ["Element Count": elementCountAfter] as [String : Any]
                    
                    Database.database().reference().child("Forms").child(self.formID!).child("Other").updateChildValues(formValue) { (error, ref) in
                        
                        if error != nil {
                            print(error!)
                            return
                        }
                        
                        Database.database().reference().child("Elements").child(elements[indexPath.row].id!).removeValue { (error, ref) in
                            
                            if error != nil {
                                print(error!)
                                return
                            }
                            
                            Database.database().reference().child("Forms").child(self.formID!).child("Elements").child(elements[indexPath.row].id!).removeValue { (error, ref) in
                                
                                if error != nil {
                                    print(error!)
                                    return
                                }
                                
                                self.endLoadingSetup()
                                
                                elementsDictionary.removeValue(forKey: elements[indexPath.row].id!)
                                elements.remove(at: indexPath.row)
                                tableView.deleteRows(at: [indexPath], with: .fade)
                                
                                if elements.count == 0 {
                                    self.checkNumberOfElement()
                                }
                                
                            }
                            
                        }
                        
                    }
                        
                } withCancel: { (error) in
                    
                }
                
            }))
            popUp.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
            }))
            self.present(popUp, animated: true) {}
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        elementMenus.removeAll()
        let editElementController = EditElementController(style: .insetGrouped)
        editElementController.elementID = elements[indexPath.row].id
        editElementController.selectedTitle = elements[indexPath.row].title
        editElementController.selectedDataType = elements[indexPath.row].dataType
        editElementController.selectedOrder = elements[indexPath.row].seqNo
        editElementController.selectedColor = elements[indexPath.row].color
        navigationController?.pushViewController(editElementController, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Elements"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
    
}

extension FormController {
    
    private func setupNavbar() {
        
        let addButton = UIBarButtonItem(image: UIImage(named: "addIcon"), style: .plain, target: self, action: #selector(addNewElement))
        let editFormNameButton = UIBarButtonItem(image: UIImage(named: "fillIcon"), style: .plain, target: self, action: #selector(changeFormMenu))
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItems = [addButton, editFormNameButton]
        
        activityIndicator.style = .medium
        
    }
    
    private func setupRefreshController() {
        
        refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshController.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshController)
        
    }
    
    @objc func refresh(_ sender: AnyObject) {
        checkNumberOfElement()
    }
    
    private func startLoadingSetup() {
        
        self.tableView.isUserInteractionEnabled = false
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        self.navigationController?.view.isUserInteractionEnabled = false
        
        self.activityIndicator.startAnimating()
        
    }
    
    private func endLoadingSetup() {
        
        self.refreshController.endRefreshing()
        
        self.tableView.isUserInteractionEnabled = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        self.navigationController?.view.isUserInteractionEnabled = true
        
        self.activityIndicator.stopAnimating()
        
    }
    
    private func checkNumberOfElement() {
        
        elements.removeAll()
        elementsDictionary.removeAll()
        
        startLoadingSetup()
        
        Database.database().reference().child("Forms").child(formID!).child("Other").observeSingleEvent(of: .value) { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let elementCount = dictionary["Element Count"] as? Int
            
            if elementCount == 0 {
                
                DispatchQueue.main.async {
                    
                    elements.removeAll()
                    
                    self.noElementLabel.alpha = 1
                    
                    self.endLoadingSetup()
                    self.tableView.reloadData()
                    
                }
                
            } else {
                
                DispatchQueue.main.async {
                    self.noElementLabel.alpha = 0
                    self.observeElement()
                }
                
            }
            
        } withCancel: { (error) in
            
        }
        
    }
    
    private func observeElement() {
        
        Database.database().reference().child("Forms").child(formID!).child("Elements").observe(.childAdded, with: { (snapshot) in
            
            let elementID = snapshot.key
            Database.database().reference().child("Elements").child(elementID).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let element = Element()
                element.id = elementID
                element.title = dictionary["Title"] as? String
                element.dataType = dictionary["Data Type"] as? String
                element.seqNo = dictionary["Seq No"] as? String
                element.color = dictionary["Color"] as? String
                
                elementsDictionary[elementID] = element
                elements = Array(elementsDictionary.values)
                elements.sort(by: { (element1, element2) -> Bool in
                    
                    return (Int(element1.seqNo!)!) < (Int(element2.seqNo!)!)
                    
                })
                
                DispatchQueue.main.async {
                    self.endLoadingSetup()
                    self.tableView.reloadData()
                }
                
            } withCancel: { (error) in
                
            }

        }, withCancel: nil)
        
    }
    
    @objc private func addNewElement() {
        
        let createElementController = CreateElementController(style: .insetGrouped)
        createElementController.formID = formID
        navigationController?.pushViewController(createElementController, animated: true)
        
    }
    
    @objc private func changeFormMenu() {
        
        let alert = UIAlertController(title: "Change Form Title", message: "Enter your new form title", preferredStyle: .alert)
        alert.addTextField { (textfield) in
            textfield.placeholder = "Enter your form title"
            textfield.text = self.navigationItem.title
            textfield.layer.borderWidth = 0
        }
        alert.addAction(UIAlertAction(title: "Apply", style: .default, handler: { [self] (_) in
            
            let newTitle = alert.textFields![0].text
            
            if newTitle != navigationItem.title {
                
                if checkFormTitleAvailability(newtitle: newTitle!, type: userType!) {
                    
                    startLoadingSetup()
                    
                    let newTitleValue = ["Title": newTitle]
                    
                    Database.database().reference().child("Forms").child(formID!).child("Other").updateChildValues(newTitleValue as [AnyHashable : Any]) { (error, ref) in
                        
                        if error != nil {
                            print(error!)
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self.endLoadingSetup()
                            self.navigationItem.title = newTitle
                            self.tableView.reloadData()
                        }
                        
                    }
                    
                } else {
                    
                    let popUp = UIAlertController(title: formTitleAlreadyUsedTitle, message: formTitleAlreadyUsedMessage, preferredStyle: .alert)
                    popUp.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        
                    }))
                    
                    self.present(popUp, animated: true) {}
                    
                }
                
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
}

