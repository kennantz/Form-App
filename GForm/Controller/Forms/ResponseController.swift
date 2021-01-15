//
//  ResponseController.swift
//  GForm
//
//  Created by Kennan Trevyn Zenjaya on 08/01/21.
//

import LBTAComponents
import Firebase

class ResponseController: UITableViewController {
    
    var responseID: String?
    
    var refreshController = UIRefreshControl()
    
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        observeUserResponse()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavbar()
        
        tableView.showsVerticalScrollIndicator = false
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return responseElements.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        
        if responseElements[indexPath.section].dataType == "Date" {
            
            let timestamp = Double(responseElements[indexPath.section].response!)
            
            let date = Date(timeIntervalSince1970: timestamp!)
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "dd MMM yyyy" //Specify your format that you want
            let strDate = dateFormatter.string(from: date)
            
            cell.textLabel?.text = strDate
            
        } else {
            
            cell.textLabel?.text = responseElements[indexPath.section].response
            
        }
        
        cell.textLabel?.numberOfLines = 0
        cell.backgroundColor = hexStringToUIColor(hex: responseElements[indexPath.section].color ?? "")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return responseElements[section].title
    }
    
}

extension ResponseController {
    
    private func setupNavbar() {
        
        navigationItem.title = "Response"
        
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
        observeUserResponse()
    }
    
    private func observeUserResponse() {
        
        responseElementsDictionary.removeAll()
        responseElements.removeAll()
        
        self.tableView.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        
        Database.database().reference().child("Responses").child(responseID!).child("Elements").observe(.childAdded) { (snapshot) in
            
            let elementID = snapshot.key
            Database.database().reference().child("Responses").child(self.responseID!).child("Elements").child(elementID).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let response = dictionary["Response"] as? String
                
                Database.database().reference().child("Elements").child(elementID).observeSingleEvent(of: .value) { (snapshot) in
                    
                    guard let dictionary1 = snapshot.value as? [String: AnyObject] else {
                        return
                    }
                    
                    let title = dictionary1["Title"] as? String
                    let dataType = dictionary1["Data Type"] as? String
                    let seqNo = dictionary1["Seq No"] as? String
                    let color = dictionary1["Color"] as? String
                    
                    let responseElement = ResponseElement()
                    responseElement.id = elementID
                    responseElement.title = title
                    responseElement.dataType = dataType
                    responseElement.seqNo = seqNo
                    responseElement.color = color
                    responseElement.response = response
                    
                    responseElements.append(responseElement)
                    
                    responseElementsDictionary[elementID] = responseElement
                    responseElements = Array(responseElementsDictionary.values)
                    responseElements.sort(by: { (element1, element2) -> Bool in
                        
                        return (Int(element1.seqNo!)!) < (Int(element2.seqNo!)!)
                        
                    })
                    
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
