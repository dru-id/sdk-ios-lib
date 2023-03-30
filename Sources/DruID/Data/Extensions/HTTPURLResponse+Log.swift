//
//  HTTPURLResponse+Log.swift
//  
//
//  Created on 9/1/23.
//

import Foundation

extension HTTPURLResponse {
    func log(data: Data?) {
        
        print("\n - - - - - - - - - - RESPONSE - - - - - - - - - - \n")
        defer { print("\n - - - - - - - - - -  END - - - - - - - - - - \n") }
        let urlString = url?.absoluteString
        let components = NSURLComponents(string: urlString ?? "")
        let path = "\(components?.path ?? "")"
        let query = "\(components?.query ?? "")"
        var output = ""
        if let urlString = urlString {
            output += "\(urlString)"
            output += "\n\n"
        }
        output += "HTTP \(statusCode) \(path)?\(query)\n"
        if let host = components?.host {
            output += "Host: \(host)\n"
        }
        for (key, value) in allHeaderFields {
            output += "\(key): \(value)\n"
        }
        if let body = data {
            output += "\n\(String(data: body, encoding: .utf8) ?? "")\n"
        }
        print(output)
    }
}
