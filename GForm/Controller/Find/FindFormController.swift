//
//  FindFormController.swift
//  GForm
//
//  Created by Kennan Trevyn Zenjaya on 01/01/21.
//

import LBTAComponents
import Firebase

class FindFormController: UITableViewController, UITextFieldDelegate {

    var refreshController = UIRefreshControl()
    
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    lazy var enterFormIDLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter Form ID"
        label.textAlignment = .center
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: fourteen, weight: .medium)
        return label
    }()
    
    lazy var formIDTextField: UITextField = {
        let textfield = UITextField()
        textfield.delegate = self
        textfield.backgroundColor = .tertiarySystemFill
        textfield.placeholder = "Form ID"
        textfield.textColor = .label
        textfield.layer.cornerRadius = eight
        textfield.clipsToBounds = true
        return textfield
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if forms.count != 0 {
            
        } else {
            observeAllFormUID()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupNavbar()
        setupRefreshController()
        
        view.addSubview(formIDTextField)
        view.addSubview(enterFormIDLabel)
        
        enterFormIDLabel.centerXAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerXAnchor).isActive = true
        enterFormIDLabel.anchor(nil, left: nil, bottom: formIDTextField.topAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: eight, rightConstant: 0, widthConstant: view.frame.width, heightConstant: thirty)
        
        let namePaddingRect = CGRect(x: 0, y: 0, width: 15, height: self.formIDTextField.frame.height)
        let namePadding = UIView(frame: namePaddingRect)
        formIDTextField.leftView = namePadding
        formIDTextField.rightView = namePadding
        formIDTextField.leftViewMode = UITextField.ViewMode.always
        formIDTextField.rightViewMode = UITextField.ViewMode.always
        formIDTextField.centerXAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerXAnchor).isActive = true
        formIDTextField.centerYAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerYAnchor).isActive = true
        formIDTextField.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: twoHundred, heightConstant: fourty)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleKeyboardDismiss)))
        
    }

}

extension FindFormController {
    
    private func setupNavbar() {
        
        navigationItem.title = "Find"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        activityIndicator.style = .medium
        
    }
    
    private func setupRefreshController() {
        
        refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshController.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshController)
        
    }
    
    @objc func refresh(_ sender: AnyObject) {
        observeAllFormUID()
    }
    
    private func observeAllFormUID() {
        
        forms.removeAll()
        
        self.tableView.isUserInteractionEnabled = false
        
        let barButton = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.rightBarButtonItem = barButton

        activityIndicator.startAnimating()
        
        Database.database().reference().child("Forms").observe(.childAdded) { (snapshot) in
            
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
                    
                    self.tableView.isUserInteractionEnabled = true
                    self.tableView.reloadData()
                    
                }
                
            }
            
        } withCancel: { (error) in
            
        }

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let formIDSearched = textField.text
        
        if formIDSearched == "" {
            
        } else {
            
            var counter = 1
            
            for item in forms {
                
                if item.status == "Unpublished" {
                    
                    let popUp = UIAlertController(title: "We're sorry for the inconvenience", message: "Form ID not found, please try again.", preferredStyle: .alert)
                    popUp.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        textField.text = ""
                    }))
                    
                    self.present(popUp, animated: true) {}
                    
                    break
                    
                } else {
                    
                    if item.uid == formIDSearched {
                        
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        
                        let fillFormController = FillFormController(style: .insetGrouped)
                        fillFormController.formID = item.id
                        fillFormController.formTitle = item.title
                        textField.text = ""
                        navigationController?.pushViewController(fillFormController, animated: true)
                        break
                        
                    } else {
                        
                        if counter != forms.count {
                            counter += 1
                        } else {
                            
                            let popUp = UIAlertController(title: "We're sorry for the inconvenience", message: "Form ID not found, please try again.", preferredStyle: .alert)
                            popUp.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                textField.text = ""
                            }))
                            
                            self.present(popUp, animated: true) {}
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleKeyboardDismiss()
        return true
    }
    
    @objc func handleKeyboardDismiss() {
        
        formIDTextField.resignFirstResponder()
        
    }
    
}

