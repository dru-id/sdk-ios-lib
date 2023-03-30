//
//  ColorModel.swift
//  
//
//  Created on 17/1/23.
//

import Foundation
import SwiftUI

public class ColorModel: Codable {
    public let primaryColor: Color
    public let secondaryColor: Color
    public let textOverPrimaryColor: Color
    
    public init(
        primaryColor: Color = Color(red: 0.757, green: 0.82, blue: 0),
        secondaryColor: Color = Color(red: 0.227, green: 0.557, blue: 0.722),
        textOverPrimaryColor: Color = Color.white
    ) {
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.textOverPrimaryColor = textOverPrimaryColor
    }
}
