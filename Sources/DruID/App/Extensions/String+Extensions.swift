//
//  String+Extensions.swift
//  
//
//  Created on 1/2/23.
//

import Foundation

extension String {
    
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
