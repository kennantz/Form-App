//
//  SetupMenuController.swift
//  GForm
//
//  Created by Kennan Trevyn Zenjaya on 05/01/21.
//

import LBTAComponents
import Firebase

class SetupColumnController: UITableViewController {
    
    var navTitle: String? {
        didSet {
            navigationItem.title = navTitle
        }
    }
    
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    lazy var noElementLabel: UILabel = {
        let label = UILabel()
        label.text = "No menus yet."
        label.textAlignment = .center
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: fourteen, weight: .regular)
        label.alpha = 0
        return label
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        observeNumberOfColumn()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavbar()
        
        view.addSubview(noElementLabel)
        
        noElementLabel.centerXAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerXAnchor).isActive = true
        noElementLabel.centerYAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerYAnchor).isActive = true
        noElementLabel.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: thirty)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return developerMenus.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cellId")
        if developerMenus.count != 0 {
            cell.textLabel?.text = developerMenus[indexPath.row].title
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let menuID = developerMenus[indexPath.row].id
            
            let popUp = UIAlertController(title: deleteDeveloperMenuConfirmationTitle, message: deleteDeveloperMenuConfirmationMessage, preferredStyle: .alert)
            popUp.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                
                var barButton = UIBarButtonItem(customView: self.activityIndicator)
                self.navigationItem.rightBarButtonItem = barButton
                
                self.navigationController?.navigationBar.isUserInteractionEnabled = false
                self.navigationController?.view.isUserInteractionEnabled = false

                self.activityIndicator.startAnimating()
                
                Database.database().reference().child("Developer").child("Other").observeSingleEvent(of: .value) { (snapshot) in
                    
                    guard let dictionary = snapshot.value as? [String: AnyObject] else {
                        return
                    }
                    
                    let menusCount = dictionary["Menus Count"] as? Int
                    let menusCountAfter = menusCount! - 1
                    let menusCountAfterValue = ["Menus Count": menusCountAfter]
                    
                    Database.database().reference().child("Developer").child("Other").updateChildValues(menusCountAfterValue) { (error, ref) in
                        
                        if error != nil {
                            print(error!)
                            return
                        }
                        
                        Database.database().reference().child("Developer").child("Menus").child(menuID!).removeValue { (error, ref) in
                            
                            if error != nil {
                                print(error!)
                                return
                            }
                            
                            self.activityIndicator.stopAnimating()
                            
                            barButton = UIBarButtonItem(image: UIImage(named: "addIcon"), style: .plain, target: self, action: #selector(self.addNewColumn))
                            self.navigationItem.rightBarButtonItem = barButton
                            
                            self.navigationController?.navigationBar.isUserInteractionEnabled = true
                            self.navigationController?.view.isUserInteractionEnabled = true
                            
                            developerMenus.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .fade)
                            
                            if elements.count == 0 {
                                self.observeNumberOfColumn()
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
    
}

extension SetupColumnController {
    
    private func setupNavbar() {
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.setRightBarButton(UIBarButtonItem(image: UIImage(named: "addIcon"), style: .plain, target: self, action: #selector(addNewColumn)), animated: true)
        
    }
    
    private func observeNumberOfColumn() {
        
        developerMenus.removeAll()
        
        var barButton = UIBarButtonItem(customView: self.activityIndicator)
        self.navigationItem.rightBarButtonItem = barButton
        
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        self.navigationController?.view.isUserInteractionEnabled = false

        self.activityIndicator.startAnimating()
        
        Database.database().reference().child("Developer").child("Other").observeSingleEvent(of: .value) { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let menusCount = dictionary["Menus Count"] as? Int
            
            if menusCount != 0 {
                
                DispatchQueue.main.async {
                    self.noElementLabel.alpha = 0
                    self.observeColumns()
                }
                
            } else {
                
                DispatchQueue.main.async {
                    
                    developerMenus.removeAll()
                    
                    self.noElementLabel.alpha = 1
                    
                    self.activityIndicator.stopAnimating()
                    
                    barButton = UIBarButtonItem(image: UIImage(named: "addIcon"), style: .plain, target: self, action: #selector(self.addNewColumn))
                    self.navigationItem.rightBarButtonItem = barButton
                    
                    self.navigationController?.navigationBar.isUserInteractionEnabled = true
                    self.navigationController?.view.isUserInteractionEnabled = true
                    
                    self.tableView.reloadData()
                    
                }
                
            }
            
        }
        
    }
    
    private func observeColumns() {
        
        developerMenus.removeAll()
        
        Database.database().reference().child("Developer").child("Menus").observe(.childAdded) { (snapshot) in
            
            let menuID = snapshot.key
            Database.database().reference().child("Developer").child("Menus").child(menuID).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let menuName = dictionary["Title"] as? String
                
                let developerMenu = DeveloperMenu()
                developerMenu.id = menuID
                developerMenu.title = menuName
                developerMenus.append(developerMenu)
                
                DispatchQueue.main.async {
                    
                    self.activityIndicator.stopAnimating()
                    
                    let barButton = UIBarButtonItem(image: UIImage(named: "addIcon"), style: .plain, target: self, action: #selector(self.addNewColumn))
                    self.navigationItem.rightBarButtonItem = barButton
                    
                    self.navigationController?.navigationBar.isUserInteractionEnabled = true
                    self.navigationController?.view.isUserInteractionEnabled = true
                    
                    self.tableView.reloadData()
                    
                }
                
            }
            
        }
        
    }
    
    @objc private func addNewColumn() {
        
        Database.database().reference().child("Developer").child("Menus").removeAllObservers()
        
        let alert = UIAlertController(title: "Add new column", message: "", preferredStyle: .alert)
        alert.addTextField { (textfield) in
            textfield.placeholder = "Menu name"
            textfield.layer.borderWidth = 0
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (_) in
            
            let menuName = alert.textFields![0].text
            
            if menuName != "" {
                
                var barButton = UIBarButtonItem(customView: self.activityIndicator)
                self.navigationItem.rightBarButtonItem = barButton
                
                self.navigationController?.navigationBar.isUserInteractionEnabled = false
                self.navigationController?.view.isUserInteractionEnabled = false

                self.activityIndicator.startAnimating()
                
                let newMenuValue = ["Title": menuName]
                
                Database.database().reference().child("Developer").child("Other").observeSingleEvent(of: .value) { (snapshot) in
                    
                    guard let dictionary = snapshot.value as? [String: AnyObject] else {
                        return
                    }
                    
                    let menusCount = dictionary["Menus Count"] as? Int
                    let menusCountAfter = menusCount! + 1
                    let menusCountAfterValue = ["Menus Count": menusCountAfter]
                    
                    Database.database().reference().child("Developer").child("Other").updateChildValues(menusCountAfterValue) { (error, ref) in
                        
                        if error != nil {
                            print(error!)
                            return
                        }
                        
                        Database.database().reference().child("Developer").child("Menus").childByAutoId().updateChildValues(newMenuValue as [AnyHashable : Any]) { (error, ref) in
                            
                            if error != nil {
                                print(error!)
                                return
                            }
                            
                            self.activityIndicator.stopAnimating()
                            
                            barButton = UIBarButtonItem(image: UIImage(named: "addIcon"), style: .plain, target: self, action: #selector(self.addNewColumn))
                            self.navigationItem.rightBarButtonItem = barButton
                            
                            self.navigationController?.navigationBar.isUserInteractionEnabled = true
                            self.navigationController?.view.isUserInteractionEnabled = true
                            
                            self.observeColumns()
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
