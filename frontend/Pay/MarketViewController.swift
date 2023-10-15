//
//  MarketController.swift
//  Pay
//
//  Created by Tanishk Deo on 10/14/23.
//

import UIKit
import StripePaymentSheet

class MarketViewController: UITableViewController, OverlayDelegate, UIViewControllerTransitioningDelegate{
    
    

    var paymentSheet: PaymentSheet?
    let backendCheckoutUrl = URL(string: "http://localhost:8000/api/pay/create_checkout_session")!

    let hasBid: [Bool] = []
    
    var hasFinished: [Bool] = []
    
    let timer = Timer()
    
    var done = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCell(timer:)), userInfo: nil, repeats: true)
        timer.fire()
        tableView.reloadData()
        hasFinished = Array(repeating: false, count: Model.shared.market.count)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    @objc func updateCell(timer: Timer) {
        
        tableView.reloadData()
    }

    func calculateTimeLeft(for targetDate: Date) -> TimeInterval {
        let currentDate = Date()
        let timeLeft = targetDate.timeIntervalSince(currentDate)
        return max(0, timeLeft)
    }
    
    
    // MARK: - Table view data source
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Model.shared.market.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MarketCell", for: indexPath) as! MarketCell
        
        cell.setupCell(bond: Model.shared.market[indexPath.row])
        cell.vc = self
        cell.row = indexPath.row

        return cell
    }
    
    func bid(row: Int, apr: Double) {
        Model.shared.market[row].apr = apr
        tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        200
    }
    
    let slideVC = OverlayView()
    
    public func presentPickerView(row: Int, amount: Int) {
        slideVC.row = row
        slideVC.delegate = self
        slideVC.modalPresentationStyle = .formSheet
        slideVC.transitioningDelegate = self
        self.present(slideVC, animated: true, completion: nil)
    }
    
    
    public func fetchStripe(amount: Int) {
        
        if done {
            return
        }
         
        done = true
        
        // MARK: Fetch the PaymentIntent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: backendCheckoutUrl)
        request.httpMethod = "POST"
        let param: [String: Int] = ["amount" : amount]
        let encoder = JSONEncoder()
        let data = try? encoder.encode(param)
        request.httpBody = data
            
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard let data = data, let checkout = try? JSONDecoder().decode(Checkout.self, from: (self?.parseData(initial: data))!), let self = self else {
                
                return
            }
            
            
            let publishableKey = checkout.publishableKey
            let customerId = checkout.customer
            let customerEphemeralKeySecret = checkout.ephemeralKey
            let paymentIntentClientSecret = checkout.paymentIntent

          STPAPIClient.shared.publishableKey = publishableKey
          // MARK: Create a PaymentSheet instance
          var configuration = PaymentSheet.Configuration()
          configuration.merchantDisplayName = "Example, Inc."
          configuration.customer = .init(id: customerId, ephemeralKeySecret: customerEphemeralKeySecret)
          // Set `allowsDelayedPaymentMethods` to true if your business handles
          // delayed notification payment methods like US bank accounts.
          configuration.allowsDelayedPaymentMethods = true
          self.paymentSheet = PaymentSheet(paymentIntentClientSecret: paymentIntentClientSecret, configuration: configuration)
            

          DispatchQueue.main.async {
              
              self.didTapCheckoutButton()
          }
        })
        task.resume()
        
    }
    
    func parseData(initial: Data) -> Data {
        var str = String(data: initial, encoding: .utf8)!
        str.removeFirst()
        str.removeLast()
        str = str.replacingOccurrences(of: "\\", with: "")
        return str.data(using: .utf8)!
    }
    
    
    
    @objc func didTapCheckoutButton() {
        // MARK: Start the checkout process
            paymentSheet?.present(from: self) { [weak self] paymentResult in
            // MARK: Handle the payment result
            switch paymentResult {
            case .completed:
            print("Your order is confirmed")
                let url = URL(string: "http://localhost:8000/api/pay/success/\(Model.shared.market[0].id ?? "")" )!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                let email = "tanishk.deo@gmail.com"
                let parameters: [String: Any] = ["email": email]
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: parameters)
                    request.httpBody = jsonData
                } catch {
                    print("Error converting parameters to JSON: \(error.localizedDescription)")
                }

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    // Handle the response here
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        return
                    }

                    // Process the data or response
                    if let data = data {
                        // Parse the data if needed
                        print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
                    }
                    
                }
                
                task.resume()

                
            case .canceled:
            print("Canceled!")
            case .failed(let error):
            print("Payment failed: \(error)")
            }
            }
        
    

    }
    
    func leftUntil(targetDate: Date) -> (days: Int, minutes: Int, seconds: Int) {
        let currentDate = Date()

        // Calculate time difference
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .second], from: currentDate, to: targetDate)

        // Extract components
        let days = components.day ?? 0
        let minutes = components.minute ?? 0
        let seconds = components.second ?? 0

        return (days, minutes, seconds)
    }

    // Example usage
  
    

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
