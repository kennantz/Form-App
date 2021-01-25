//
//  ResponseController.swift
//  GForm
//
//  Created by Kennan Trevyn Zenjaya on 08/01/21.
//

import LBTAComponents
import Firebase

class ResponseController: UITableViewController {
    
    var formID: String?
    
    var numberOfResponse: Int? {
        didSet {
            if numberOfResponse == 0 {
                noResponseLabel.alpha = 1
                responseElementsDictionary.removeAll()
                responseElements.removeAll()
                self.tableView.reloadData()
            } else {
                noResponseLabel.alpha = 0
                observeElement()
            }
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
        
        tableView.showsVerticalScrollIndicator = false
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return responseElements.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return responseElements[section].responses!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        
        if responseElements[indexPath.section].dataType == "Date" {
            
            let timestamp = Double(responseElements[indexPath.section].responses![indexPath.row])
            
            let date = Date(timeIntervalSince1970: timestamp!)
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "dd MMM yyyy" //Specify your format that you want
            let strDate = dateFormatter.string(from: date)
            
            cell.textLabel?.text = strDate
            
        } else {
            
            cell.textLabel?.text = responseElements[indexPath.section].responses![indexPath.row]
            
        }
        
        cell.backgroundColor = hexStringToUIColor(hex: responseElements[indexPath.section].color ?? "")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return responseElements[section].title
    }
    
}

extension ResponseController {
    
    private func setupNavbar() {
        
        navigationItem.title = "Responses"
        
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
        observeElement()
    }
    
    private func observeElement() {
        
        responseElementsDictionary.removeAll()
        responseElements.removeAll()
        
        self.tableView.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        
        Database.database().reference().child("Forms").child(formID!).child("Elements").observe(.childAdded, with: { (snapshot) in
            
            let elementID = snapshot.key
            Database.database().reference().child("Elements").child(elementID).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let element = ResponseElement()
                element.id = elementID
                element.title = dictionary["Title"] as? String
                element.dataType = dictionary["Data Type"] as? String
                element.seqNo = dictionary["Seq No"] as? String
                element.color = dictionary["Color"] as? String
                
                var responseArray = [String]()
                
                Database.database().reference().child("Elements").child(elementID).child("Responses").observe(.childAdded) { (snapshot) in
                    
                    let responseID = snapshot.key
                    Database.database().reference().child("Responses").child(responseID).observeSingleEvent(of: .value) { (snapshot) in
                        
                        guard let dictionary1 = snapshot.value as? [String: AnyObject] else {
                            return
                        }
                        
                        let response = dictionary1["Response"] as? String
                        responseArray.append(response!)
                        element.responses = responseArray
                        
                        responseElements.append(element)
                        
                        responseElementsDictionary[elementID] = element
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
                
            } withCancel: { (error) in
                
            }

        }, withCancel: nil)
        
    }
    
}
