//
//  DruidLogHelper.swift
//
//
//  Created on 16/1/23.
//

import Foundation

public enum DruidLogLevel: Codable {
    case debug, info, error
}

class DruidLogHelper {
    
    static let shared = DruidLogHelper()
    
    private var logLevel: DruidLogLevel = .error
    
    func setLogLevel(logLevel: DruidLogLevel) {
        self.logLevel = logLevel
    }
    
    func log(_ level: DruidLogLevel, message: String) {
        
        switch self.logLevel {
        case .debug: printMessage(message)
        case .info:
            if level == .debug { return }
            printMessage(message)
        case .error:
            if level == .debug || level == .info { return }
            printMessage(message)
        }
        
    }
    
    private func printMessage(_ message: String) {
        print("DruID: " + message)
    }
    
}

