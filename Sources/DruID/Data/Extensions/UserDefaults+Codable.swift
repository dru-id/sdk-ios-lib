//
//  UserDefaults+Codable.swift
//  
//
//  Created on 9/1/23.
//

import Foundation

extension UserDefaults {
    
    enum Key: String {
        case currentMeeting
    }
    
    subscript<T: Codable>(codable key: Key) -> T? {
        get {
            guard let data = object(forKey: key.rawValue) as? Data else { return nil }
            return try? JSONDecoder().decode(T.self, from: data)
        }
        
        set {
            set(try? JSONEncoder().encode(newValue), forKey: key.rawValue)
        }
    }
}
