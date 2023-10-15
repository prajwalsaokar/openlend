//
//  BondCell.swift
//  Pay
//
//  Created by Tanishk Deo on 10/14/23.
//

import UIKit

class BondCell: UITableViewCell {
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var purposeLabel: UILabel!
    @IBOutlet weak var aprLabel: UILabel!
    @IBOutlet weak var statusLabel: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(bond: Bond) {

        amountLabel.text = "$\(String(format: "%.2f", bond.bondAmt))"
        purposeLabel.text = bond.purpose
        aprLabel.text = "\(String(format: "%.2f", bond.apr))%"

        timeLabel.text = bond.repaymentTime.formatted(date: .abbreviated, time: .omitted)
        
        statusLabel.isUserInteractionEnabled = false
        
        if Bool.random() {
            statusLabel.setTitle("Received", for: .normal)
            statusLabel.configuration?.baseForegroundColor = UIColor.systemGreen
            statusLabel.configuration?.baseBackgroundColor = #colorLiteral(red: 0, green: 1, blue: 0, alpha: 1)
        } else {
            statusLabel.setTitle("Pending", for: .normal)
            statusLabel.configuration?.baseBackgroundColor = .red
            statusLabel.configuration?.baseForegroundColor = .systemRed
        }
        
        // add shadow on cell
        containerView.layer.cornerRadius = 12.0
        containerView.layer.masksToBounds = false
        containerView.layer.shadowRadius = 2.0
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
