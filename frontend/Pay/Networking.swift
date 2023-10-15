//
//  Networking.swift
//  Pay
//
//  Created by Tanishk Deo on 10/14/23.
//

import Foundation
import Alamofire


struct LoginResponse: Decodable {
    // Define the structure of your response, matching the JSON structure
    let token: String
    // Add other properties as needed
}


class Networking {
    
    
    static let shared = Networking()
    
    
    func signup(first: String, last: String, email: String, password: String, completion: @escaping (RegisterResponse?) -> Void) {
        let url = "http://localhost:8000/api/register/"

        let parameters: Parameters = [
            "first_name" : first,
            "last_name" : last,
            "email": email,
            "password": password
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseDecodable(of: RegisterResponse.self) { response in
            
            switch response.result {
            case .success(let res):
                completion(res)
            case .failure(_):
                completion(nil)
            }
            
            
        }
    }
    
    func login(email: String, password: String, completion: @escaping (LoginResponse?) -> Void) {
        
        let url = "http://localhost:8000/api/token-auth/"

        let parameters: Parameters = [
            "username": email,
            "password": password
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseDecodable(of: LoginResponse.self) { response in
            switch response.result {
            case .success(let res):
                completion(res)
            case .failure(_):
                completion(nil)
            }
            
            
        }
        
    }
    
    func acceptSocket() {
        let url = URL(string: "ws://localhost:8000/socket")!
        var request = URLRequest(url: url)
        let socket = URLSession.shared.webSocketTask(with: request)

        socket.resume()

        socket.receive { result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    // Handle received data
                    let receivedText = String(data: data, encoding: .utf8)
                    print("Received data: \(receivedText ?? "")")
                case .string(let text):
                    // Handle received text
                    print("Received text: \(text)")
                @unknown default:
                    fatalError()
                }
            case .failure(let error):
                // Handle error
                print("WebSocket error: \(error)")
            }
        }

        // Sending data example
        let message = URLSessionWebSocketTask.Message.string("Hello, WebSocket!")
        socket.send(message) { error in
            if let error = error {
                print("WebSocket send error: \(error)")
            } else {
                print("Message sent successfully")
            }
        }

        // Keep the program alive to receive WebSocket events
        dispatchMain()
    }
    
    
}



struct RegisterResponse : Codable {
    let email : String
    let password : String
    let first_name : String
    let last_name : String
}




