//
//  SignupViewController.swift
//  Pay
//
//  Created by Tanishk Deo on 10/14/23.
//

import UIKit

class SignupViewController: UITableViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var contentView: UIView!
    
    
    @IBOutlet weak var emailField: UITextField! {
        didSet {
            emailField.keyboardType = UIKeyboardType.emailAddress
            emailField.delegate = self
        }
    }
    
    @IBOutlet weak var passwordField: UITextField! {
        didSet {
            passwordField.delegate = self
            passwordField.disableAutoFill()
        }
    }
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecognizer: ))))

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    @objc private func viewTapped(gestureRecognizer: UIGestureRecognizer){
        view.endEditing(true)
    }
    @IBOutlet weak var firstField: UITextField!
    
    @IBOutlet weak var lastField: UITextField!
    private func signupUser() {
        errorLabel.isHidden = true
        activity.startAnimating()
        if checkValidation()  {
            let first = firstField.text!
            let last = lastField.text!
            let email = emailField.text!
            let password = passwordField.text!
            
            Networking.shared.signup(first: first, last: last, email: email, password: password) { [weak self] response in
                
                if response != nil {
                    
                    self?.performSegue(withIdentifier: "Main", sender: nil)
                    UserDefaults.standard.set(true, forKey: "loggedin")
                    UserDefaults.standard.synchronize()
                }
                
                else {
                    self?.showError(with: "Error")
                }
                
            }
            
            
        }
        
    }
    
    
    private func checkValidation() -> Bool {
        if let email = emailField.text, let password = passwordField.text {
            if !email.isEmpty, !password.isEmpty {
                if isPasswordValid(password){
                    if isEmailValid(email) {
                        return true
                    } else {
                        showError(with:"Email is invalid")
                    }
                } else {
                    showError(with:"Passwords must be at least 6 characters")
                }
            } else {
                showError(with:"Please fill in all fields")
            }
        }
        return false
    }
    
    
    private func isPasswordValid(_ password : String) -> Bool{
        return password.count >= 6
        
    }
    
    
    private func isEmailValid(_ email:String) -> Bool {
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: email)
        return result
    }
    
    private func showError(with text: String) {
        errorLabel.text = text
        errorLabel.isHidden = false
        activity.stopAnimating()
    }
    
    
    @IBAction func signup(_ sender: UIButton? = nil) {
        signupUser()
    }
    
    
    
    
    
    
    
    
    
    

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension UITextField {
    func disableAutoFill() {
        if #available(iOS 12, *) {
            textContentType = .oneTimeCode
        } else {
            textContentType = .init(rawValue: "")
        }
    }
}
