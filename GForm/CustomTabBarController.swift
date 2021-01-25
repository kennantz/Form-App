//
//  CustomTabbarController.swift
//  GForm
//
//  Created by Kennan Trevyn Zenjaya on 01/01/21.
//

import LBTAComponents
import Firebase

class CustomTabBarController: UITabBarController {
    
    let formsController: UINavigationController = {
        let forms = FormListController()
        let formsMenuController = UINavigationController(rootViewController: forms)
        formsMenuController.title = "Forms"
        formsMenuController.tabBarItem.image = UIImage(named: "formIcon")
        return formsMenuController
    }()
    
    let accountController: UINavigationController = {
        let account = AccountController(style: .insetGrouped)
        let accountMenuController = UINavigationController(rootViewController: account)
        accountMenuController.title = "Account"
        accountMenuController.tabBarItem.image = UIImage(named: "accountIcon")
        return accountMenuController
    }()
    
    private let splashView = UIView()
    private let iconImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSplashScreen()
        
        viewControllers = [formsController, accountController]
        tabBar.isTranslucent = true
        
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: 1000, height: 0)
        topBorder.backgroundColor = UIColor(r: 229, g: 231, b: 255).cgColor
        tabBar.clipsToBounds = true
        tabBar.layer.addSublayer(topBorder)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

            self.scaleDownAnimation()

        }
        
    }
    
}

extension CustomTabBarController {
    
    private func setupSplashScreen() {
        
        splashView.backgroundColor = hexStringToUIColor(hex: "#375ECC")
        
        iconImageView.image = UIImage(named: "splashIcon")
        iconImageView.contentMode = .scaleAspectFit
        
        view.addSubview(splashView)
        splashView.addSubview(iconImageView)
        
        iconImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        iconImageView.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: seventyFour, heightConstant: seventyFour)
        
        splashView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
    }
    
    func scaleDownAnimation() {
        
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseIn, animations: {
            
            self.iconImageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            
        }) { (success) in
            
            self.scaleUpAnimation()
            
        }
        
    }
    
    func scaleUpAnimation() {
        
        UIView.animate(withDuration: 0.35, delay: 0.1, options: .curveEaseIn, animations: {
            
            self.iconImageView.transform = CGAffineTransform(scaleX: 5, y: 5)
            
            
        }) { (success) in
            
            self.removeSplashScreen()
            
        }
        
    }
    
    func removeSplashScreen() {
        
        splashView.removeFromSuperview()
        
        guard (Auth.auth().currentUser?.uid) != nil else {
            let landingPageController = LandingPageDataSourceController()
            landingPageController.isModalInPresentation = true
            self.present(landingPageController, animated: true, completion: nil)
            return
        }
        
    }
    
}


