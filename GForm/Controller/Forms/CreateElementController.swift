//
//  CreateElementController.swift
//  GForm
//
//  Created by Kennan Trevyn Zenjaya on 01/01/21.
//

import LBTAComponents
import Firebase

class CreateElementController: UITableViewController, UIColorPickerViewControllerDelegate {

    var formID: String?
    
    let colorPicker = UIColorPickerViewController()
    
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
        
        observeNumberOfMenu()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        colorPicker.selectedColor = UIColor.white
        colorPicker.delegate = self
        
        setupNavbar()
        
        view.addSubview(noElementLabel)
        
        noElementLabel.centerXAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerXAnchor).isActive = true
        noElementLabel.centerYAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerYAnchor).isActive = true
        noElementLabel.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: thirty)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cellId")
        
        if elementMenus.count != 0 {
            
            cell.textLabel?.text = elementMenus[indexPath.row].element
            cell.detailTextLabel?.text = elementMenus[indexPath.row].selectedOption
            
            if elementMenus[indexPath.row].element == "Color" {
                
                if elementMenus[indexPath.row].selectedOption != "Not Selected" {
                    if elementMenus[indexPath.row].selectedOption == "#FFFFFF" {
                        
                    } else {
                        cell.detailTextLabel?.textColor = hexStringToUIColor(hex: elementMenus[indexPath.row].selectedOption!)
                    }
                }
                
            }
            
        }
        
        cell.accessoryType = .disclosureIndicator
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if elementMenus[indexPath.row].element == "Title" {
            
            let alert = UIAlertController(title: "Add element Title", message: "What is your element title?", preferredStyle: .alert)
            alert.addTextField { (textfield) in
                textfield.placeholder = "Title"
                
                if elementMenus[indexPath.row].selectedOption != "Not Selected" {
                    textfield.text = elementMenus[indexPath.row].selectedOption
                }
                
                textfield.layer.borderWidth = 0
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                
                if alert.textFields![0].text == "" {
                    
                } else {
                    elementMenus[indexPath.row].selectedOption = alert.textFields![0].text
                    self.tableView.reloadData()
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                
            }))
            self.present(alert, animated: true, completion: nil)
            
        } else if elementMenus[indexPath.row].element == "Data Type" {
            
            let alert = UIAlertController(title: "Data Type", message: "Choose element data type", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Short Text", style: .default, handler: { (_) in
                
                elementMenus[indexPath.row].selectedOption = "Short Text"
                self.tableView.reloadData()
                
            }))
            alert.addAction(UIAlertAction(title: "Long Text", style: .default, handler: { (_) in
                
                elementMenus[indexPath.row].selectedOption = "Long Text"
                self.tableView.reloadData()
                
            }))
            alert.addAction(UIAlertAction(title: "Number", style: .default, handler: { (_) in
                
                elementMenus[indexPath.row].selectedOption = "Number"
                self.tableView.reloadData()
                
            }))
            alert.addAction(UIAlertAction(title: "Date", style: .default, handler: { (_) in
                
                elementMenus[indexPath.row].selectedOption = "Date"
                self.tableView.reloadData()
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                
            }))
            self.present(alert, animated: true, completion: nil)
            
        } else if  elementMenus[indexPath.row].element == "Order" {
            
            let alert = UIAlertController(title: "Where it will be ordered?", message: "", preferredStyle: .alert)
            alert.addTextField { (textfield) in
                textfield.placeholder = "Seq No. (eg. 1, 2, 3)"
                
                if elementMenus[indexPath.row].selectedOption != "Not Selected" {
                    textfield.text = elementMenus[indexPath.row].selectedOption
                }
                
                textfield.layer.borderWidth = 0
                textfield.keyboardType = .numberPad
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                
                if alert.textFields![0].text == "" {
                    
                } else {
                    elementMenus[indexPath.row].selectedOption = alert.textFields![0].text
                    self.tableView.reloadData()
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                
            }))
            self.present(alert, animated: true, completion: nil)
            
        } else if elementMenus[indexPath.row].element == "Color" {
            
            self.present(colorPicker, animated: true, completion: nil)
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elementMenus.count
    }

}

extension CreateElementController {
    
    private func setupNavbar() {
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.titleView = setTitle(title: "Create", subtitle: "New Element")
        navigationItem.setRightBarButton(UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(handleAddElement)), animated: true)
        
        activityIndicator.style = .medium
        
    }
    
    private func observeNumberOfMenu() {
        
        elementMenus.removeAll()
        
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
                    self.observeMenus()
                }
                
            } else {
                
                DispatchQueue.main.async {
                    
                    developerMenus.removeAll()
                    
                    self.noElementLabel.alpha = 1
                    
                    self.activityIndicator.stopAnimating()
                    
                    barButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(self.handleAddElement))
                    self.navigationItem.rightBarButtonItem = barButton
                    
                    self.navigationController?.navigationBar.isUserInteractionEnabled = true
                    self.navigationController?.view.isUserInteractionEnabled = true
                    
                    self.tableView.reloadData()
                    
                }
                
            }
            
        }
        
    }
    
    private func observeMenus() {
        
        Database.database().reference().child("Developer").child("Menus").observe(.childAdded) { (snapshot) in
            
            let menuID = snapshot.key
            Database.database().reference().child("Developer").child("Menus").child(menuID).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let menuName = dictionary["Title"] as? String
                
                let menu = ElementMenu()
                menu.element = menuName
                
                
                if menuName == "Color" {
                    menu.selectedOption = "#FFFFFF"
                } else {
                    menu.selectedOption = "Not Selected"
                }
                
                elementMenus.append(menu)
                
                DispatchQueue.main.async {
                    
                    self.activityIndicator.stopAnimating()
                    
                    let barButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(self.handleAddElement))
                    self.navigationItem.rightBarButtonItem = barButton
                    
                    self.navigationController?.navigationBar.isUserInteractionEnabled = true
                    self.navigationController?.view.isUserInteractionEnabled = true
                    
                    self.tableView.reloadData()
                    
                }
                
            }
            
        }
        
    }
    
    @objc private func handleAddElement() {
        
        let title = elementMenus[0].selectedOption
        let dataType = elementMenus[1].selectedOption
        let order = elementMenus[2].selectedOption
        let color = elementMenus[3].selectedOption
        
        if title == "Not Selected" || dataType == "Not Selected" || order == "Not Selected" || color == "Not Selected" {
            
            let popUp = UIAlertController(title: "We're sorry for the inconvenience", message: "Please fill in all data required", preferredStyle: .alert)
            popUp.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                
            }))
            
            self.present(popUp, animated: true) {}
            
        } else {
            
            var barButton = UIBarButtonItem(customView: activityIndicator)
            self.navigationItem.rightBarButtonItem = barButton
            
            self.navigationController?.navigationBar.isUserInteractionEnabled = false
            self.navigationController?.view.isUserInteractionEnabled = false

            activityIndicator.startAnimating()
            
            let elementValue = ["Title": title, "Data Type": dataType, "Seq No": order, "Color": color]
            
            let elementRef = Database.database().reference().child("Elements")
            let elementKey = elementRef.childByAutoId().key
            let elementIDValue = [elementKey: 1]
            
            Database.database().reference().child("Forms").child(formID!).child("Other").observeSingleEvent(of: .value) { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let elementCount = dictionary["Element Count"] as? Int
                let elementCountAfter = elementCount! + 1
                
                let formValue = ["Element Count": elementCountAfter] as [String : Any]
                
                Database.database().reference().child("Forms").child(self.formID!).child("Other").updateChildValues(formValue) { [self] (error, ref) in
                    
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    Database.database().reference().child("Forms").child(self.formID!).child("Elements").updateChildValues(elementIDValue) { (error, ref) in
                        
                        if error != nil {
                            print(error!)
                            return
                        }
                        
                        elementRef.child(elementKey!).updateChildValues(elementValue as [AnyHashable : Any]) { (error, ref) in
                            
                            if error != nil {
                                print(error!)
                                return
                            }
                            
                            DispatchQueue.main.async {
                                
                                let alert = UIAlertController(title: "Add element successfull!", message: "", preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (_) in
                                    
                                    self.observeNumberOfMenu()
                                    self.activityIndicator.stopAnimating()
                                    
                                    barButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(self.handleAddElement))
                                    self.navigationItem.rightBarButtonItem = barButton
                                    
                                    self.navigationController?.navigationBar.isUserInteractionEnabled = true
                                    self.navigationController?.view.isUserInteractionEnabled = true
                                    
                                }))
                                self.present(alert, animated: true, completion: nil)
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            } withCancel: { (error) in
                
            }
            
        }
        
    }
    
    //  Called once you have finished picking the color.
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        
        if viewController.selectedColor != UIColor.white {
            elementMenus[3].selectedOption = hexStringFromColor(color: viewController.selectedColor)
            self.tableView.reloadData()
        }
        
    }
        
    //  Called on every color selection done in the picker.
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        
    }
    
}

