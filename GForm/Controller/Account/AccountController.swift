//
//  AccountController.swift
//  GForm
//
//  Created by Kennan Trevyn Zenjaya on 01/01/21.
//

import LBTAComponents
import Firebase

class AccountController: UITableViewController {
    
    var refreshController = UIRefreshControl()

    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        observeUserData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(observeUserData), name: NSNotification.Name(rawValue: "reloadAccountData"), object: nil)
        
        setupNavbar()
        setupRefreshController()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 3
        } else if section == 1 {
            return 4
        }
        
        return 1
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cellId")
        
        if indexPath.section == 0 {
            
            if userDatas.count != 0 {
                if indexPath.row == 0 {
                    cell.textLabel?.text = "Name"
                    cell.detailTextLabel?.text = userDatas[0].name ?? ""
                } else if indexPath.row == 1 {
                    cell.textLabel?.text = "Email"
                    cell.detailTextLabel?.text = userDatas[0].email ?? ""
                } else {
                    cell.textLabel?.text = "UID"
                    cell.detailTextLabel?.text = userDatas[0].uid ?? ""
                }
            }
            
        } else if indexPath.section == 1 {
            
            if userDatas.count != 0 {
                if indexPath.row == 0 {
                    cell.textLabel?.text = "Developer Options"
                } else if indexPath.row == 1 {
                    cell.textLabel?.text = "Terms of Use"
                } else if indexPath.row == 2 {
                    cell.textLabel?.text = "Privacy Policy"
                } else {
                    cell.textLabel?.text = "Help Center"
                }
            }
            
            cell.accessoryType = .disclosureIndicator
            
        } else {
            
            if userDatas.count != 0 {
                cell.textLabel?.text = "Log Out"
            }
            
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 2 {
            if indexPath.row == 0 {
                handleLogOut()
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let developerController = DeveloperController(style: .insetGrouped)
                navigationController?.pushViewController(developerController, animated: true)
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Profile"
        }
        return ""
    }

}

extension AccountController {
    
    private func setupNavbar() {
        
        navigationItem.title = "Account"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let barButton = UIBarButtonItem(customView: self.activityIndicator)
        self.navigationItem.rightBarButtonItem = barButton
        
        self.activityIndicator.style = .medium
        
    }
    
    private func setupRefreshController() {
        
        refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshController.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshController)
        
    }
    
    @objc func refresh(_ sender: AnyObject) {
        observeUserData()
    }
    
    @objc private func observeUserData() {
        
        self.tableView.isUserInteractionEnabled = false
        
        userDatas.removeAll()
        
        self.activityIndicator.startAnimating()
        
        guard let currentUID = Auth.auth().currentUser?.uid else {
            return
        }
        
        Database.database().reference().child("Users").child(currentUID).child("Profile").observeSingleEvent(of: .value) { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let userName = dictionary["Name"] as? String
            let userEmail = dictionary["Email"] as? String
            
            let userData = UserData()
            userData.uid = currentUID
            userData.name = userName
            userData.email = userEmail
            userDatas.append(userData)
            
            DispatchQueue.main.async {
                
                self.refreshController.endRefreshing()
                
                self.tableView.isUserInteractionEnabled = true
                
                self.activityIndicator.stopAnimating()
                
                self.tableView.reloadData()
                
            }
            
        }
        
    }
    
    private func handleLogOut() {
        
        let popUp = UIAlertController(title: logoutConfirmationTitle, message: logoutConfirmationMessage, preferredStyle: .alert)
        popUp.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            do {
                try Auth.auth().signOut()
            } catch let logoutError{
                print(logoutError)
            }
            
            let landingPageController = LandingPageDataSourceController()
            landingPageController.isModalInPresentation = true
            self.present(landingPageController, animated: true, completion: nil)
            
        }))
        popUp.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        self.present(popUp, animated: true) {}
        
    }
    
}


