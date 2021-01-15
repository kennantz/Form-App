//
//  LandingPageController.swift
//  GForm
//
//  Created by Kennan Trevyn Zenjaya on 01/01/21.
//

import LBTAComponents
import Firebase

class LandingPageDataSourceController: DatasourceController {
    
    lazy var bg: UIView = {
        let view = UIView()
        view.backgroundColor = hexStringToUIColor(hex: "#375ECC")
        return view
    }()
    
    lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.setTitle("CREATE AN ACCOUNT", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: eighteen)
        button.layer.cornerRadius = eight
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        return button
    }()
    
    lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.setTitle("SIGN IN", for: .normal)
        button.setTitleColor(hexStringToUIColor(hex: "#375ECC"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: eighteen)
        button.layer.cornerRadius = eight
        button.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        return button
    }()
    
    lazy var easierLabel2: UILabel = {
        let label = UILabel()
        label.text = "Forms"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: twentyEight, weight: .bold)
        label.minimumScaleFactor = 0.1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var easierLabel1: UILabel = {
        let label = UILabel()
        label.text = "Easily create & share"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: twentyEight, weight: .regular)
        label.minimumScaleFactor = 0.1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: fourty, weight: .bold)
        label.minimumScaleFactor = 0.1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var bagIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Little Bag")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(bg)
        view.addSubview(signUpButton)
        view.addSubview(signInButton)
        view.addSubview(easierLabel2)
        view.addSubview(easierLabel1)
        view.addSubview(welcomeLabel)
        view.addSubview(bagIcon)
        
        bagIcon.anchor(nil, left: welcomeLabel.leftAnchor, bottom: welcomeLabel.topAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: fourty, rightConstant: 0, widthConstant: fiftyFour, heightConstant: fiftyFour)
        
        welcomeLabel.anchor(nil, left: easierLabel1.leftAnchor, bottom: easierLabel1.topAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: fourteen, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        easierLabel1.anchor(nil, left: easierLabel2.leftAnchor, bottom: easierLabel2.topAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        easierLabel2.anchor(nil, left: signInButton.leftAnchor, bottom: signInButton.topAnchor, right: signInButton.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: thirty, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        signInButton.anchor(nil, left: signUpButton.leftAnchor, bottom: signUpButton.topAnchor, right: signUpButton.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: fourteen, rightConstant: 0, widthConstant: 0, heightConstant: fiftyFive)
        
        signUpButton.anchor(nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: thirtyFour, bottomConstant: fiftyEight, rightConstant: thirtyFour, widthConstant: 0, heightConstant: fiftyFive)
        
        bg.fillSuperview()
        
    }
    
    @objc func handleSignIn() {
        
        let signInController = UINavigationController(rootViewController: SignInController(style: .insetGrouped))
        
        if #available(iOS 13.0, *) {
            signInController.modalPresentationStyle = .fullScreen
        } else {
            // Fallback on earlier versions
        }

        present(signInController, animated: true, completion: {})
        
    }
    
    @objc func handleSignUp() {
        
        let signUpController = UINavigationController(rootViewController: SignUpController(style: .insetGrouped))
        
        if #available(iOS 13.0, *) {
            signUpController.modalPresentationStyle = .fullScreen
        } else {
            // Fallback on earlier versions
        }

        present(signUpController, animated: true, completion: {})
        
    }
    
    @objc func handleDismiss() {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
