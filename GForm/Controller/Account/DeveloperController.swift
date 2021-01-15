//
//  DeveloperController.swift
//  GForm
//
//  Created by Kennan Trevyn Zenjaya on 05/01/21.
//

import LBTAComponents

class DeveloperController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavbar()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cellId")
        if indexPath.row == 0 {
            cell.textLabel?.text = "Setup Menu"
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            let setupMenuController = SetupMenuController(style: .insetGrouped)
            navigationController?.pushViewController(setupMenuController, animated: true)
        }
        
    }
    
}

extension DeveloperController {
    
    private func setupNavbar() {
        
        navigationItem.title = "Developer"
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
}
