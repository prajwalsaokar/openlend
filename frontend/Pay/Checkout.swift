//
//  Checkout.swift
//  Pay
//
//  Created by Tanishk Deo on 10/14/23.
//

import Foundation

struct Checkout : Codable {
    let paymentIntent: String
    let ephemeralKey: String
    let customer: String
    let publishableKey : String
    
}
