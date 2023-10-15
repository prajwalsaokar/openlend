//
//  Bond.swift
//  Pay
//
//  Created by Tanishk Deo on 10/14/23.
//

import Foundation

struct Bond {
    
    let id : String
    let loanerId : String
    let purchaserId : String
    let bondAmt : Double
    var apr: Double
    let repaymentTime : Date
    let riskLevel : String
    let purpose: String
    
}

struct LoanRequest {
    let id : String
    let status : String
    let bondAmt : Double
    let apr: Double
    let repaymentTime : Date
}

struct LoanIssue {
    let id : String
    let purpose: String
    let bondAmt : Double
    let apr: Double
    let repaymentTime : Date
    let riskLevel : Double
}

struct MarketBond {
    let id : String
    let purpose: String
    let bondAmt : Double
    let apr: Double
    let repaymentTime : Date
    let riskLevel : Double
}
