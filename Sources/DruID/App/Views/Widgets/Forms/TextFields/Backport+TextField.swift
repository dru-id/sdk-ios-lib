//
//  File.swift
//  
//
//  Created on 28/5/22.
//

import SwiftUI

public enum TextInputAutocapitalization {
    case never, words, sentences, characters
    
    @available(iOS 15.0, *)
    var toOriginal: SwiftUI.TextInputAutocapitalization {
        switch self {
        case .never: return .never
        case .words: return .words
        case .sentences: return .sentences
        case .characters: return .characters
        }
    }
}

public struct Backport<Content> {
    public let content: Content

    public init(_ content: Content) {
        self.content = content
    }
}

public extension View {
    var backport: Backport<Self> { Backport(self) }
}

public extension Backport where Content: View {
    
    @ViewBuilder
    func textInputAutocapitalization(_ autocapitalization: TextInputAutocapitalization?) -> some View {
        if #available(iOS 15.0, *) {
            content.textInputAutocapitalization(autocapitalization?.toOriginal)
        } else {
            content
        }
    }
}

public extension Backport where Content: View {
    enum SubmitLabel {
        case done, go, send, join, route, search, `return`, next, `continue`
        
        @available(iOS 15.0, *)
        var toOriginal: SwiftUI.SubmitLabel {
            switch self {
            case .done: return .done
            case .go: return .go
            case .send: return .send
            case .join: return .join
            case .route: return .route
            case .search: return .search
            case .return: return .return
            case .next: return .next
            case .continue: return .continue
            }
        }
    }
    
    @ViewBuilder
    func submitLabel(_ submitLabel: SubmitLabel) -> some View {
        if #available(iOS 15.0, *) {
            content.submitLabel(submitLabel.toOriginal)
        } else {
            content
        }
    }
}

public extension Backport where Content: View {
    @ViewBuilder
    func onSubmit(_ action: @escaping (() -> Void)) -> some View {
        if #available(iOS 15.0, *) {
            content.onSubmit(action)
        } else {
            content
        }
    }
}

@available(iOS 15, *)
private struct FocusModifier<Field: Hashable>: ViewModifier {

    @FocusState var focused: Field?
    @Binding var state: Field
    let field: Field

    init(_ state: Binding<Field>, field: Field){
        self._state = state
        self.field = field
    }

    func body(content: Content) -> some View {
        content.focused($focused, equals: field)
            .onChange(of: state, perform: changeFocus)
    }

    private func changeFocus(_ value: Field){
        focused = value
    }
}

public extension Backport where Content: View {

    @ViewBuilder
    func focused<Field: Hashable>(_ binding: Binding<Field>, equals: Field) -> some View {
        if #available(iOS 15, *) {
            content.modifier(FocusModifier(binding, field: equals))
        } else {
            content
        }
    }
    
    @ViewBuilder
    func configureTextField<Field: Hashable>(
        keyboard: UIKeyboardType = .default,
        contentType: UITextContentType? = nil,
        submitLabel: SubmitLabel,
        focusState: Binding<Field>,
        field: Field,
        nextField: Field?
    ) -> some View {
        if #available(iOS 15, *) {
            content
                .keyboardType(keyboard)
                .textContentType(contentType)
                .submitLabel(submitLabel.toOriginal)
                .modifier(FocusModifier(focusState, field: field))
                .onSubmit {
                    guard let next = nextField else { return }
                    focusState.wrappedValue = next
                }
        } else {
            content
                .keyboardType(keyboard)
                .textContentType(contentType)
        }
    }
    
    @ViewBuilder
    func configureTextField<Field: Hashable>(
        keyboard: UIKeyboardType = .default,
        contentType: UITextContentType? = nil,
        submitLabel: SubmitLabel,
        focusState: Binding<Field>,
        field: Field,
        _ onSubmit: @escaping (() -> Void)
    ) -> some View {
        if #available(iOS 15, *) {
            content
                .keyboardType(keyboard)
                .textContentType(contentType)
                .submitLabel(submitLabel.toOriginal)
                .modifier(FocusModifier(focusState, field: field))
                .onSubmit(onSubmit)
        } else {
            content
                .keyboardType(keyboard)
                .textContentType(contentType)
        }
    }
    
    @ViewBuilder
    func configureTextField(
        submitCondition: Bool,
        keyboard: UIKeyboardType = .default,
        contentType: UITextContentType? = nil,
        submitLabel: SubmitLabel
    ) -> some View {
        if submitCondition {
            if #available(iOS 15, *) {
                content
                    .keyboardType(keyboard)
                    .textContentType(contentType)
                    .submitLabel(submitLabel.toOriginal)
            } else {
                content
                    .keyboardType(keyboard)
                    .textContentType(contentType)
            }
        } else {
            content
                .keyboardType(keyboard)
                .textContentType(contentType)
        }
    }
    
    @ViewBuilder
    func configureTextField(
        submitCondition: Bool,
        keyboard: UIKeyboardType = .default,
        contentType: UITextContentType? = nil,
        submitLabel: SubmitLabel,
        _ onSubmit: @escaping (() -> Void)
    ) -> some View {
        if submitCondition {
            if #available(iOS 15, *) {
                content
                    .keyboardType(keyboard)
                    .textContentType(contentType)
                    .submitLabel(submitLabel.toOriginal)
                    .onSubmit(onSubmit)
            } else {
                content
                    .keyboardType(keyboard)
                    .textContentType(contentType)
            }
        } else {
            content
                .keyboardType(keyboard)
                .textContentType(contentType)
        }
    }
}
