//
//  AlertUIModel+APIError.swift
//  
//
//  Created on 18/1/23.
//

import Foundation

extension AlertUIModel {
    
    init(error: Error) {
        if let error = error as? APIError {
            self.init(apiError: error)
        } else {
            self.init(title: Strings.common_unknown_error_text)
        }
    }
    
    init(apiError: APIError) {
        self.init(title: apiError.localizedDescription + ". \(String(describing: apiError))")
    }
}
