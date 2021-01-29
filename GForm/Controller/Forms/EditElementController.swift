//
//  EditElementController.swift
//  GForm
//
//  Created by Kennan Trevyn Zenjaya on 02/01/21.
//

import LBTAComponents
import Firebase

class EditElementController: UITableViewController, UIColorPickerViewControllerDelegate {

    let colorPicker = UIColorPickerViewController()
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    var elementID: String?
    
    var selectedTitle: String? {
        didSet {
            
            let menu = ElementMenu()
            menu.element = "Title"
            menu.selectedOption = selectedTitle
            elementMenus.append(menu)
            
        }
    }
    
    var selectedDataType: String? {
        didSet {
            
            let menu = ElementMenu()
            menu.element = "Data Type"
            menu.selectedOption = selectedDataType
            elementMenus.append(menu)
            
        }
    }
    
    var selectedOrder: String? {
        didSet {
            
            let menu = ElementMenu()
            menu.element = "Order"
            menu.selectedOption = selectedOrder
            elementMenus.append(menu)
            
        }
    }
    
    var selectedColor: String? {
        didSet {
            
            let menu = ElementMenu()
            menu.element = "Color"
            menu.selectedOption = selectedColor
            elementMenus.append(menu)
            
            colorPicker.selectedColor = hexStringToUIColor(hex: selectedColor!)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        colorPicker.delegate = self
        
        setupNavbar()
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cellId")
        
        if elementMenus.count != 0 {
            
            cell.textLabel?.text = elementMenus[indexPath.row].element
            cell.detailTextLabel?.text = elementMenus[indexPath.row].selectedOption
            
            if elementMenus[indexPath.row].element == "Color" {
                
                let view = UIView()
                view.backgroundColor = .clear
                
                let colorBox = UIView()
                
                if elementMenus[indexPath.row].selectedOption != "Not Selected" {
                    if elementMenus[indexPath.row].selectedOption == "#FFFFFF" {

                    } else {
                        colorBox.backgroundColor = hexStringToUIColor(hex: elementMenus[indexPath.row].selectedOption!)
                    }
                }
                
                colorBox.layer.borderWidth = 1
                colorBox.layer.borderColor = UIColor.label.cgColor
                
                cell.addSubview(view)
                view.addSubview(colorBox)
                
                colorBox.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
                colorBox.anchor(nil, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: eighty, bottomConstant: 0, rightConstant: 0, widthConstant: twentySix, heightConstant: sixteen)
                
                view.fillSuperview()
                
            }
            
        }
        
        cell.accessoryType = .disclosureIndicator
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            
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
            
        } else if indexPath.row == 1 {
            
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
            
        } else if indexPath.row == 2 {
            
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
            
        } else {
            
            self.present(colorPicker, animated: true, completion: nil)
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elementMenus.count
    }

}

extension EditElementController {
    
    private func setupNavbar() {
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.titleView = setTitle(title: "Edit", subtitle: "Element")
        navigationItem.setRightBarButton(UIBarButtonItem(title: "Apply", style: .plain, target: self, action: #selector(handleApplyChange)), animated: true)
        
        activityIndicator.style = .medium
        
    }
    
    @objc private func handleApplyChange() {
        
        let barButton = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.rightBarButtonItem = barButton

        activityIndicator.startAnimating()
        
        let title = elementMenus[0].selectedOption
        let dataType = elementMenus[1].selectedOption
        let order = elementMenus[2].selectedOption
        let color = elementMenus[3].selectedOption
        
        let elementValue = ["Title": title, "Data Type": dataType, "Seq No": order, "Color": color]
        
        Database.database().reference().child("Elements").child(elementID!).updateChildValues(elementValue as [AnyHashable : Any]) { (error, ref) in
            
            if error != nil {
                print(error!)
                return
            }
            
            let alert = UIAlertController(title: "Element edited!", message: "", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (_) in
                
                self.navigationController?.popViewController(animated: true)
                
            }))
            self.present(alert, animated: true, completion: nil)
            
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
