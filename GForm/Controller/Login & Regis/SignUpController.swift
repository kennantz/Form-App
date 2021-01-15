//
//  SignUpController.swift
//  GForm
//
//  Created by Kennan Trevyn Zenjaya on 01/01/21.
//

import LBTAComponents
import Firebase

class SignUpController: UITableViewController, UITextFieldDelegate {
    
    let nameTextField = UITextField()
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let confirmPasswordTextField = UITextField()
    
    let signUpButton = UIButton(type: .system)
    let signUpButtonLoadingAnimation = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Already have an account?", for: .normal)
        button.setTitleColor(UIColor(r: 162, g: 162, b: 162), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: sixteen)
        button.layer.borderWidth = 0
        button.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavbar()
        
        view.addSubview(alreadyHaveAccountButton)
        
        alreadyHaveAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        alreadyHaveAccountButton.anchor(nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: twenty, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleKeyboardDismiss)))
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 4 {
            
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "cellId4")
            
            signUpButton.backgroundColor = hexStringToUIColor(hex: "#375ECC")
            signUpButton.setTitle("REGISTER", for: .normal)
            signUpButton.setTitleColor(.white, for: .normal)
            signUpButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: eighteen)
            signUpButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
            signUpButton.isUserInteractionEnabled = true
            
            cell.addSubview(signUpButton)
            signUpButton.addSubview(signUpButtonLoadingAnimation)
            
            signUpButtonLoadingAnimation.fillSuperview()
            
            signUpButton.fillSuperview()
            
            cell.contentView.isUserInteractionEnabled = false
            
            return cell
            
        } else if indexPath.section == 3 {
            
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "cellId3")
            
            let view = UIView()
            
            cell.addSubview(view)
            view.addSubview(confirmPasswordTextField)
            
            view.fillSuperview()
            
            confirmPasswordTextField.delegate = self
            confirmPasswordTextField.isSecureTextEntry = true
            confirmPasswordTextField.placeholder = "Re-type your password"
            confirmPasswordTextField.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: fourteen, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            
            cell.contentView.isUserInteractionEnabled = false
            
            return cell
            
        } else if indexPath.section == 2 {
            
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
            
        } else if indexPath.section == 1 {
            
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
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cellId0")
        
        let view = UIView()
        
        cell.addSubview(view)
        view.addSubview(nameTextField)
        
        view.fillSuperview()
        
        nameTextField.delegate = self
        nameTextField.keyboardType = .default
        nameTextField.placeholder = "Enter your full name"
        nameTextField.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: fourteen, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        cell.contentView.isUserInteractionEnabled = false
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Full Name"
        } else if section == 1 {
            return "Email"
        } else if section == 2 {
            return "Password"
        } else if section == 3 {
            return "Confirm Password"
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return fiftyFive
    }
    
}

extension SignUpController {
    
    private func setupNavbar() {
        
        navigationItem.title = "Sign Up"
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    @objc private func handleSignUp() {
        
        let name = nameTextField.text
        let email = emailTextField.text
        let password = passwordTextField.text
        let confirmPassword = confirmPasswordTextField.text
        
        let emailValidation = validateEmail(enteredEmail: email!)
        let passwordValidation = validatePassword(testStr: password)
        
        if name == "" || email == "" || password == "" || confirmPassword == "" {
            
            let popUp = UIAlertController(title: "We're sorry for the inconvenience", message: "Please fill in all sign up data required", preferredStyle: .alert)
            popUp.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                
            }))
            
            self.present(popUp, animated: true) {}
            
        } else if emailValidation != true {
            
            let popUp = UIAlertController(title: "We're sorry for the inconvenience", message: "Please use a valid email address", preferredStyle: .alert)
            popUp.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.emailTextField.text = ""
            }))
            
            self.present(popUp, animated: true) {}
            
        } else if passwordValidation != true {
            
            let popUp = UIAlertController(title: "We're sorry for the inconvenience", message: "Password must contain at least one uppercase character and number with minimum of 8 characters long", preferredStyle: .alert)
            popUp.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.passwordTextField.text = ""
                self.confirmPasswordTextField.text = ""
            }))
            
            self.present(popUp, animated: true) {}
            
        } else if password != confirmPassword {
            
            let popUp = UIAlertController(title: "We're sorry for the inconvenience", message: "The confirm password confirmation does not match", preferredStyle: .alert)
            popUp.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.passwordTextField.text = ""
                self.confirmPasswordTextField.text = ""
            }))
            
            self.present(popUp, animated: true) {}
            
        } else {
            
            signUpButton.setTitle("", for: .normal)
            signUpButtonLoadingAnimation.startAnimating()
            handleKeyboardDismiss()
            
            Auth.auth().createUser(withEmail: email!, password: password!) { (user, error) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
                //Successfully authenticated user
                guard let uid = user?.user.uid else {
                    return
                }
                
                let profile = ["Name": name, "Email": email]
                let credential = ["Password": password]
                let other = ["Number of Forms": 0]
                
                Database.database().reference().child("Users").child(uid).child("Profile").updateChildValues(profile as [AnyHashable : Any], withCompletionBlock: { (error, ref) in
                    
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    Database.database().reference().child("Users").child(uid).child("Credential").updateChildValues(credential as [AnyHashable : Any], withCompletionBlock: { (error, ref) in
                        
                        if error != nil {
                            print(error!)
                            return
                        }
                        
                        Database.database().reference().child("Users").child(uid).child("Other").updateChildValues(other as [AnyHashable : Any], withCompletionBlock: { (error, ref) in
                            
                            if error != nil {
                                print(error!)
                                return
                            }
                            
                            self.signUpButtonLoadingAnimation.stopAnimating()
                            self.signUpButton.setTitle("SIGN UP", for: .normal)
                            
                            self.handleKeyboardDismiss()
                            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadFormList"), object: nil)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadAccountData"), object: nil)
                            
                        })
                        
                    })
                    
                })
                
            }
            
        }
        
    }
    
    @objc func handleSignIn() {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func validateEmail(enteredEmail: String) -> Bool {
        
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
        
    }
    
    func validatePassword(testStr: String?) -> Bool {
        guard testStr != nil else { return false }
        
        // at least one uppercase,
        // at least one digit
        // at least one lowercase
        // 8 characters total
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}")
        return passwordTest.evaluate(with: testStr)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleKeyboardDismiss()
        return true
    }
    
    @objc func handleKeyboardDismiss() {
        
        nameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        confirmPasswordTextField.resignFirstResponder()
        
    }
    
}

