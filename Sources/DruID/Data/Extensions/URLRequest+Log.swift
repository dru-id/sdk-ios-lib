//
//  URLRequest+Log.swift
//  
//
//  Created on 19/1/23.
//

import Foundation

extension URLRequest {
    func log() {
        print("\n - - - - - - - - - - REQUEST - - - - - - - - - - \n")
        defer { print("\n - - - - - - - - - -  END - - - - - - - - - - \n") }
        
        if let httpMethod = httpMethod, let url = url {
            print("\(httpMethod) \(url)\n")
        }
        print("Headers:")
        print(allHTTPHeaderFields ?? "" + "\n")
        if let body = String(data: httpBody ?? Data(), encoding: .utf8) {
            print("Body:")
            print(body + "\n")
        }
    }
}
