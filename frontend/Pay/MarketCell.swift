//
//  BondCell.swift
//  Pay
//
//  Created by Tanishk Deo on 10/14/23.
//

import UIKit

class MarketCell: UITableViewCell {
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var purposeLabel: UILabel!
    @IBOutlet weak var aprLabel: UILabel!
    @IBOutlet weak var statusLabel: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    var vc: MarketViewController?
    var row: Int?
    
    var amount: Int?
    
    @IBOutlet weak var bidButton: UIButton!
    
    var targetDate: Date!

    
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateTime(_ left: TimeInterval) {
        let minutes = Int(left) / 60
        let seconds = Int(left) % 60
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    
    func setupCell(bond: Bond) {
        
        targetDate = bond.repaymentTime

        amountLabel.text = "$\(String(format: "%.2f", bond.bondAmt))"
        purposeLabel.text = bond.purpose
        aprLabel.text = "\(String(format: "%.2f", bond.apr))%"
        timeLabel.text = bond.repaymentTime.formatted(date: .omitted, time: .shortened)
        

        // Start the timer to update the countdown label every second

        // Initial update of the countdown label
        updateCountdown()
        
        amount = Int(bond.bondAmt)
        
        statusLabel.isUserInteractionEnabled = false
        
        statusLabel.setTitle("\(String(format: "%0.2f", bond.riskLevel))%", for: .normal)
        // add shadow on cell
        containerView.layer.cornerRadius = 12.0
        containerView.layer.masksToBounds = false
        containerView.layer.shadowRadius = 2.0
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: 12.0).cgPath
    }
    
    @objc func updateCountdown() {
        if vc?.hasFinished[row ?? 0] ?? false {
            return
        }
        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: currentDate, to: targetDate)

        guard let minutes = components.minute, let seconds = components.second else {
            return
        }

        // Format the countdown string
        let countdownString = String(format: "%02d:%02d",minutes, seconds)

        // Update the label
        timeLabel.text = countdownString

        // Check if the target date has been reached
        if currentDate >= targetDate {
            timeLabel.text = "Bid Finished!"
            vc!.fetchStripe(amount: amount!)
            vc!.hasFinished[row ?? 0] = true
        }
    }
    
    @IBAction func bidTapped(_ sender: Any) {
        if let amount = amount, let vc = vc {
            vc.presentPickerView(row: row ?? 4, amount: amount)
        }
        
        
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

