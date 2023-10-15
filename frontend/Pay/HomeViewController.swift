//
//  HomeViewController.swift
//  Pay
//
//  Created by Tanishk Deo on 10/14/23.
//

import UIKit
import StripePaymentSheet

class HomeViewController: UITableViewController {
    
    

    var requests = Model.shared.request
    
    var loans = Model.shared.loans
    
    
//    @IBOutlet weak var checkoutButton: UIButton!
    

    

    override func viewDidLoad() {
        super.viewDidLoad()
        Model.shared.fillBonds()
        requests = Model.shared.request
        
        loans = Model.shared.loans
        self.tableView.reloadData()
//        tableView.clipsToBounds = false
//        checkoutButton.addTarget(self, action: #selector(didTapCheckoutButton), for: .touchUpInside)
//        checkoutButton.isEnabled = false
        
       
      }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return requests.count
        } else {
            return loans.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "My Requests"
        } else {
            return "My Loans"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BondCell", for: indexPath) as! BondCell

        if indexPath.section == 0 {
            cell.setupCell(bond: requests[indexPath.row])
        } else {
            cell.setupCell(bond: loans[indexPath.row])
        }
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = UIFont.boldSystemFont(ofSize: 24.0)
        header?.textLabel?.textColor = .black
    }

    
    
    
    
    

        // Do any additional setup after loading the view.
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
