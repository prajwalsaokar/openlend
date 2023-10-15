//
//  ViewController.swift
//  Pay
//
//  Created by Tanishk Deo on 10/13/23.
//

import UIKit

class LoginViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var email: UITextField! {
        didSet {
            email.delegate = self
        }
    }
    @IBOutlet weak var password: UITextField! {
        didSet {
            password.delegate = self
        }
    }
    @IBOutlet weak var error: UILabel!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecognizer: ))))
        // Do any additional setup after loading the view.
    }


    
    @objc private func viewTapped(gestureRecognizer: UIGestureRecognizer){
        view.endEditing(true)
    }
    
    @IBAction func login(_ sender: UIButton? = nil) {
        error.isHidden = true
        activity.startAnimating()
        if email?.text != nil, password?.text != nil, !email.text!.isEmpty, !password.text!.isEmpty{
            
            login()

                
        } else {
            showError(with: "Please fill in all fields")
        }
    }
    
    private func login() {
        
        let email = email.text!
        let password = password.text!
        
        Networking.shared.login(email: email, password: password) {
            [weak self] response in
            if response != nil {
                UserDefaults.standard.set(true, forKey: "loggedin")
                UserDefaults.standard.synchronize()
                self?.performSegue(withIdentifier: "Main", sender: nil)
            } else {
                self?.showError(with: "Error")
            }
        }
        
    }
    
    private func showError(with text: String) {
        error.isHidden = false
        activity.stopAnimating()
        activity.isHidden = true
        error.text = text
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if email.isFirstResponder {
            password.becomeFirstResponder()
        } else if password.isFirstResponder {
            login()
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Main", let tab = segue.destination as? UITabBarController, let nav = tab.viewControllers?[0] as? UINavigationController, let vc = nav.topViewController as? HomeViewController {
            // ...
        }
    }
    
    
    
    


}

