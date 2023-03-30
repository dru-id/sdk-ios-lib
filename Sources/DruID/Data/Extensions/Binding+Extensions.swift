//
//  Binding+Extensions.swift
//  
//
//  Created on 8/2/23.
//

import SwiftUI

extension Binding where Value == String? {
    func toNonOptional() -> Binding<String> {
        return Binding<String>(
            get: {
                return self.wrappedValue ?? ""
            },
            set: {
                self.wrappedValue = $0
            }
        )
    }
}
