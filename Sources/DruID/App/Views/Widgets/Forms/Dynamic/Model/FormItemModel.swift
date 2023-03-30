//
//  FormItemModel.swift
//
//
//  Created on 1/2/23.
//

import Foundation
import SwiftUI

class FormItemModel: Identifiable, ObservableObject {
    let id: String = UUID.init().uuidString
    let fieldItem: EntrypointSettingsResponseData.FieldItemData?
    let assertion: EntrypointSettingsResponseData.AssertionItemData?
    @Published var inputValue: String? = nil {
        didSet { guard inputValue != oldValue, !inputError.isEmpty, validate() else { return } }
    }
    @Published var inputError: String = ""
    @Published var assertionValue: Bool = false {
        didSet {
            if assertionValue != oldValue, !inputError.isEmpty {
                validate()
            }
            onAssertionToggle?()
        }
    }
    let isLastInput: Bool
    let isFirstAssertion: Bool
    let onAssertionToggle: (() -> Void)?
    let onSubmit: (() -> Void)
    @Published var editable = true
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        if let format = fieldItem?.format {
            dateFormatter.dateFormat = format
        } else {
            dateFormatter.dateFormat = "dd/MM/yyyy"
        }
        dateFormatter.locale = Locale.current
        return dateFormatter
    }()
    
    init(
        fieldItem: EntrypointSettingsResponseData.FieldItemData? = nil,
        assertion: EntrypointSettingsResponseData.AssertionItemData? = nil,
        isLastInput: Bool = false,
        isFirstAssertion: Bool = false,
        onAssertionToggle: (() -> Void)? = nil,
        onSubmit: @escaping (() -> Void)
    ) {
        self.fieldItem = fieldItem
        self.assertion = assertion
        self.isLastInput = isLastInput
        self.isFirstAssertion = isFirstAssertion
        self.onAssertionToggle = onAssertionToggle
        self.onSubmit = onSubmit
    }
    
    @discardableResult
    public func validate() -> Bool {
        var isValid = true
        if let fieldItem = fieldItem {
            if fieldItem.required && (inputValue == nil || inputValue?.isEmpty == true) {
                isValid = false
                inputError = fieldItem.validations?.empty?.message ?? Strings.common_mandatory_text
            } else if let regex = fieldItem.validations?.regex,
                      let inputValue = inputValue,
                      !inputValue.isEmpty,
                      !inputValue.matches(regex.pattern) {
                isValid = false
                inputError = regex.message
            } else {
                inputError = ""
            }
        } else if let assertion = assertion {
            if assertion.mandatory && !assertionValue {
                isValid = false
                inputError = Strings.common_mandatory_text
            } else {
                inputError = ""
            }
        }
        return isValid
    }
}

extension FormItemModel {
    
    func inputValueToDate() -> Date? {
        if let inputValue = inputValue {
            return dateFormatter.date(from: inputValue) ?? Date()
        }
        return nil
    }
    
    func dateToInputValueString(date: Date?) {
        if let date = date {
            inputValue = dateFormatter.string(from: date)
        } else {
            inputValue = nil
        }
    }
    
    func toRequestDictionary() -> [String:Dictionary<String, AnyEncodable>]? {
        if let inputValue = inputValue, let fieldItem = fieldItem {
            var parent = [String:Dictionary<String, AnyEncodable>]()
            var dict: [String:AnyEncodable] = [:]
            dict["objectType"] = AnyEncodable(value: fieldItem.field.objectType)
            dict["value"] = AnyEncodable(value: inputValue)
            parent[fieldItem.id] = dict
            return parent
        }
        return nil
    }
    
}



