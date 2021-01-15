//
//  SIgnInController.swift
//  GForm
//
//  Created by Kennan Trevyn Zenjaya on 01/01/21.
//

import LBTAComponents
import Firebase

class SignInController: UITableViewController, UITextFieldDelegate {
    
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    
    let signInButton = UIButton(type: .system)
    let signInButtonLoadingAnimation = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    let haventJoinedYetLabel: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Haven't joined yet?", for: .normal)
        button.setTitleColor(UIColor(r: 162, g: 162, b: 162), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: sixteen)
        button.layer.borderWidth = 0
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavbar()
        
        view.addSubview(haventJoinedYetLabel)
        
        haventJoinedYetLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        haventJoinedYetLabel.anchor(nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: twenty, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleKeyboardDismiss)))
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 2 {
            
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "cellId3")
            
            signInButton.backgroundColor = hexStringToUIColor(hex: "#375ECC")
            signInButton.setTitle("SIGN IN", for: .normal)
            signInButton.setTitleColor(.white, for: .normal)
            signInButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: eighteen)
            signInButton.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
            signInButton.isUserInteractionEnabled = true
            
            cell.addSubview(signInButton)
            signInButton.addSubview(signInButtonLoadingAnimation)
            
            signInButtonLoadingAnimation.fillSuperview()
            
            signInButton.fillSuperview()
            
            cell.contentView.isUserInteractionEnabled = false
            
            return cell
            
        } else if indexPath.section == 1 {
            
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "cellId2")
            
            let view = UIView()
            
            cell.addSubview(view)
            view.addSubview(passwordTextField)
            
            view.fillSuperview()
            
            passwordTextField.delegate = self
            passwordTextField.isSecureTextEntry = true
            passwordTextField.placeholder = "Enter your password"
            passwordTextField.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: fourteen, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            
            cell.contentView.isUserInteractionEnabled = false
            
            return cell
            
        }
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cellId1")
        
        let view = UIView()
        
        cell.addSubview(view)
        view.addSubview(emailTextField)
        
        view.fillSuperview()
        
        emailTextField.delegate = self
        emailTextField.keyboardType = .emailAddress
        emailTextField.placeholder = "Enter your email"
        emailTextField.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: fourteen, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        cell.contentView.isUserInteractionEnabled = false
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Email"
        } else if section == 1 {
            return "Password"
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return fiftyFive
    }
    
}

extension SignInController {
    
    private func setupNavbar() {
        
        navigationItem.title = "Sign In"
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    @objc private func handleSignIn() {
        
        let email = emailTextField.text
        let password = passwordTextField.text
        
        if email == "" || password == "" {
            
            let popUp = UIAlertController(title: "We're sorry for the inconvenience", message: "Please fill in all data required", preferredStyle: .alert)
            popUp.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                
            }))
            
            self.present(popUp, animated: true) {}
            
        } else {
            
            signInButton.setTitle("", for: .normal)
            signInButtonLoadingAnimation.startAnimating()
            handleKeyboardDismiss()
            
            Auth.auth().signIn(withEmail: email!, password: password!) { (user, error) in
                
                if error != nil{
                    
                    let popUp = UIAlertController(title: "We're sorry for the inconvenience", message: error?.localizedDescription, preferredStyle: .alert)
                    popUp.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        
                        self.emailTextField.text = ""
                        self.passwordTextField.text = ""
                        
                        self.signInButtonLoadingAnimation.stopAnimating()
                        self.signInButton.setTitle("SIGN IN", for: .normal)
                        
                    }))
                    
                    self.present(popUp, animated: true) {}
                    
                } else {
                    
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadHomeController"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadFormList"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadAccountData"), object: nil)
                    
                }
                
            }
            
        }
        
    }
    
    @objc func handleSignUp() {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleKeyboardDismiss()
        return true
    }
    
    @objc func handleKeyboardDismiss() {
        
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
    }
    
}
