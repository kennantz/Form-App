//
//  ResponseController.swift
//  GForm
//
//  Created by Kennan Trevyn Zenjaya on 08/01/21.
//

import LBTAComponents
import Firebase

class ResponseListController: UITableViewController {
    
    var formID: String?
    
    var numberOfResponse: Int? {
        didSet {
            if numberOfResponse == 0 {
                noResponseLabel.alpha = 1
            } else {
                noResponseLabel.alpha = 0
                observeUserResponseList()
            }
        }
    }
    
    var formTitle: String? {
        didSet {
            navigationItem.title = formTitle
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavbar()
        setupRefreshController()
        
        view.addSubview(noResponseLabel)
        
        noResponseLabel.centerXAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerXAnchor).isActive = true
        noResponseLabel.centerYAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerYAnchor).isActive = true
        noResponseLabel.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: thirty)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userResponseLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        cell.textLabel?.text = userResponseLists[indexPath.row].name
        cell.detailTextLabel?.text = userResponseLists[indexPath.row].email
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let responseController = ResponseController(style: .insetGrouped)
        responseController.responseID = userResponseLists[indexPath.row].id
        navigationController?.pushViewController(responseController, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Responses"
    }
    
}

extension ResponseListController {
    
    private func setupNavbar() {
        
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
        observeUserResponseList()
    }
    
    private func observeUserResponseList() {
        
        userResponseLists.removeAll()
        
        self.tableView.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        
        Database.database().reference().child("Forms").child(formID!).child("Responses").observe(.childAdded) { (snapshot) in
            
            let responseID = snapshot.key
            Database.database().reference().child("Responses").child(responseID).child("Other").observeSingleEvent(of: .value) { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let userResponseID = dictionary["User ID"] as? String
                
                Database.database().reference().child("Users").child(userResponseID!).child("Profile").observeSingleEvent(of: .value) { (snapshot) in
                    
                    guard let dictionary1 = snapshot.value as? [String: AnyObject] else {
                        return
                    }
                    
                    let userResponseName = dictionary1["Name"] as? String
                    let userResponseEmail = dictionary1["Email"] as? String
                    
                    let userResponse = UserResponseList()
                    userResponse.id = responseID
                    userResponse.name = userResponseName
                    userResponse.email = userResponseEmail
                    userResponseLists.append(userResponse)
                    
                    DispatchQueue.main.async {
                        
                        self.refreshController.endRefreshing()
                        
                        self.activityIndicator.stopAnimating()
                        
                        self.tableView.isUserInteractionEnabled = true
                        
                        self.tableView.reloadData()
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
}
