//
//  Model.swift
//  Pay
//
//  Created by Tanishk Deo on 10/15/23.
//

import Foundation


class Model {
    
    static let shared = Model()
    
    var market: [Bond] = []
    var request: [Bond] = []
    var loans: [Bond] = []
    
    func fillBonds() {
        for _ in 0..<3 {
            market.append(createBond())
            request.append(createBond())
            loans.append(createBond())
        }
        
    }
    
    func createBond() -> Bond {
        let p = ["Misc", "Business", "Health", "Consumption", "Education", "Consolidation", "Home Improvement", "Credit Card", "House", "Vacation", "Car", "Moving", "Wedding"]
        
        let bond = Bond(id: "1", loanerId: "1", purchaserId: "1", bondAmt: Double.random(in: 50.0 ..< 501.0), apr: Double.random(in: 0.0 ..< 30.0), repaymentTime: randomDateInFuture(), riskLevel: ["A","B","C","D","F"].randomElement()!, purpose: p.randomElement()!)
        
        return bond
    }
             
     func randomDateInFuture() -> Date {
         let currentDate = Date()
         
         // Define the range from 20 seconds to a few days (adjust as needed)
         let lowerBound = currentDate.addingTimeInterval(20)
         let upperBound = currentDate.addingTimeInterval(60)
         
         // Generate a random time interval within the specified range
         let randomTimeInterval = TimeInterval.random(in: lowerBound.timeIntervalSince1970 ..< upperBound.timeIntervalSince1970)
         
         // Create a random date within the range
         let randomDate = Date(timeIntervalSince1970: randomTimeInterval)
         
         return randomDate
     }
}
