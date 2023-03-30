//
//  ImageData.swift
//  
//
//  Created on 16/2/23.
//

import UIKit

public struct ImageData {
    public let data: Data
    let image: UIImage?
    
    public init(data: Data) {
        self.data = data
        self.image = UIImage(data: data)
    }
}

public extension Data {
    var toImageData: ImageData? { .init(data: self) }
}
