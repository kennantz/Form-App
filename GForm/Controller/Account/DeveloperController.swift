//
//  DeveloperController.swift
//  GForm
//
//  Created by Kennan Trevyn Zenjaya on 05/01/21.
//

import LBTAComponents

class DeveloperController: UITableViewController {
    
    let menus = ["Setup Column", "Forms"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavbar()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cellId")
        cell.textLabel?.text = menus[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            let setupMenuController = SetupColumnController(style: .insetGrouped)
            setupMenuController.navTitle = menus[indexPath.row]
            navigationController?.pushViewController(setupMenuController, animated: true)
        } else if indexPath.row == 1 {
            let devFormListController = DevFormListController(style: .insetGrouped)
            navigationController?.pushViewController(devFormListController, animated: true)
        }
        
    }
    
}

extension DeveloperController {
    
    private func setupNavbar() {
        
        navigationItem.title = "Developer"
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
}
