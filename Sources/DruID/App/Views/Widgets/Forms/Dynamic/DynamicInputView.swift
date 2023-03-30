//
//  InputView.swift
//  
//
//  Created on 7/2/23.
//

import SwiftUI

struct DynamicInputView: View {
    
    @StateObject var model: FormItemModel
    
    var body: some View {
        if let fieldItem = model.fieldItem {
            let optionalString = model.fieldItem?.required == false ? " \(Strings.register_optional_text)" : ""
            switch fieldItem.field.type {
            case .string, .nationalId:
                textFieldView(
                    title: fieldItem.displayName + optionalString,
                    placeholder: fieldItem.placeholder ?? "",
                    error: model.inputError,
                    text: $model.inputValue.toNonOptional(),
                    keyboard: .default,
                    disabled: !model.editable,
                    isLastInput: model.isLastInput,
                    autocapitalization: .words,
                    onSubmit: model.onSubmit
                )
            case .email:
                textFieldView(
                    title: fieldItem.displayName + optionalString,
                    placeholder: fieldItem.placeholder ?? "",
                    error: model.inputError,
                    text: $model.inputValue.toNonOptional(),
                    keyboard: .emailAddress,
                    contentType: .emailAddress,
                    disabled: !model.editable,
                    isLastInput: model.isLastInput,
                    onSubmit: model.onSubmit
                )
            case .password:
                secureTextFieldView(
                    title: fieldItem.displayName + optionalString,
                    placeholder: fieldItem.placeholder ?? "",
                    error: model.inputError,
                    text: $model.inputValue.toNonOptional(),
                    keyboard: .default,
                    isLastInput: model.isLastInput,
                    onSubmit: model.onSubmit
                )
            case .phone, .phoneNumber:
                textFieldView(
                    title: fieldItem.displayName + optionalString,
                    placeholder: fieldItem.placeholder ?? "",
                    error: model.inputError,
                    text: $model.inputValue.toNonOptional(),
                    keyboard: .phonePad,
                    contentType: .telephoneNumber,
                    disabled: !model.editable,
                    isLastInput: model.isLastInput,
                    onSubmit: model.onSubmit
                )
            case .dropdown, .choice:
                CustomPickerView(
                    title: fieldItem.displayName + optionalString,
                    placeholder: fieldItem.placeholder ?? "",
                    values: fieldItem.field.values?.map { CustomPickerView.PickerModel(id: $0.id, value: $0.value) } ?? [],
                    selectedValueId: $model.inputValue,
                    error: model.inputError
                )
                .padding(.top)
            case .localDate:
                CustomDatePickerView(
                    title: fieldItem.displayName + optionalString,
                    placeholder: fieldItem.placeholder ?? "",
                    dateRange: dateRange,
                    selectedDate: .init(get: {
                        model.inputValueToDate()
                    }, set: { date in
                        model.dateToInputValueString(date: date)
                    }),
                    error: model.inputError
                )
                .padding(.top)
            default:
                Text("Unparsed field: \(fieldItem.field.type.rawValue)").padding(.top)
            }
        } else if let assertion = model.assertion {
            AssertionView(
                checked: $model.assertionValue,
                text: assertion.displayName,
                links: model.assertion?.links?.map { AssertionView.LinkData(text: $0.displayName, url: $0.url) } ?? [],
                additionalInfo: model.assertion?.extended,
                error: model.inputError
            )
            .padding(.top)
        }
    }
    
    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: 1900, month: 1, day: 1)
        let endComponents = calendar.dateComponents(.init([.year, .month, .day]), from: Date())
        return calendar.date(from:startComponents)!
        ...
        calendar.date(from:endComponents)!
    }()
    
    func textFieldView(
        title: String,
        placeholder: String,
        error: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default,
        contentType: UITextContentType? = nil,
        disabled: Bool = false,
        isLastInput: Bool = false,
        autocapitalization: TextInputAutocapitalization = .never,
        onSubmit: @escaping (() -> Void)
    ) -> some View {
        return TextFieldView(
            title: title,
            placeholder: placeholder,
            error: error,
            disabled: disabled,
            text: text
        )
        .backport.configureTextField(
            submitCondition: isLastInput,
            keyboard: keyboard,
            contentType: contentType,
            submitLabel: .continue
        ) {
            onSubmit()
        }
        .backport.configureTextField(
            submitCondition: !isLastInput,
            keyboard: keyboard,
            contentType: contentType,
            submitLabel: .next
        )
        .backport.textInputAutocapitalization(autocapitalization)
        .padding(.top)
    }
    
    func secureTextFieldView(
        title: String,
        placeholder: String,
        error: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default,
        contentType: UITextContentType? = nil,
        isLastInput: Bool = false,
        onSubmit: @escaping (() -> Void)
    ) -> some View {
        return SecureFieldView(
            title: title,
            placeholder: placeholder,
            error: error,
            text: text
        )
        .backport.configureTextField(
            submitCondition: isLastInput,
            keyboard: keyboard,
            contentType: contentType,
            submitLabel: .continue
        ) {
            onSubmit()
        }
        .backport.configureTextField(
            submitCondition: !isLastInput,
            keyboard: keyboard,
            contentType: contentType,
            submitLabel: .next
        )
        .backport.textInputAutocapitalization(.never)
        .padding(.top)
    }
}
