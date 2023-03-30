//
//  SwiftUIView.swift
//
//
//  Created on 25/5/22.
//

import SwiftUI

struct SecureFieldView: View {
    
    let title: String
    let placeholder: String
    let error: String
    let disabled: Bool
    @Binding var text: String
    @State private var showPassword = false
    
    init(
        title: String,
        placeholder: String = "",
        error: String = "",
        disabled: Bool = false,
        text: Binding<String>
    ) {
        self.title = title
        self.placeholder = placeholder
        self.error = error
        self.disabled = disabled
        self._text = text
    }
    
    var body: some View {
        
        ZStack {
            SecureField(placeholder, text: $text)
                .modifier(
                    TextFieldStylizer(title: title, error: error, disabled: disabled, showPlaceHolder: text.isEmpty, placeholder: placeholder) {
                        secureImage
                    }
                )
                .opacity(showPassword ? 0 : 1)
            TextField(placeholder, text: $text)
                .modifier(
                    TextFieldStylizer(title: title, error: error, disabled: disabled, showPlaceHolder: text.isEmpty, placeholder: placeholder) {
                        secureImage
                    }
                )
                .opacity(showPassword ? 1 : 0)
        }
    }
    
    var secureImage: some View {
        Image(systemName: showPassword ? "eye.slash" : "eye")
            .foregroundColor(Color.gray)
            .onTapGesture { self.showPassword.toggle() }
    }
}

struct TextFieldStylizer<RightContent>: ViewModifier where RightContent: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let title: String
    let error: String
    let disabled: Bool
    let showPlaceHolder: Bool
    let placeholder: String
    let rightView: () -> RightContent?
    
    init(
        title: String,
        error: String,
        disabled: Bool,
        showPlaceHolder: Bool = false,
        placeholder: String = "",
        @ViewBuilder rightView: @escaping () -> RightContent
    ) {
        self.title = title
        self.error = error
        self.disabled = disabled
        self.showPlaceHolder = showPlaceHolder
        self.placeholder = placeholder
        self.rightView = rightView
    }
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .foregroundColor(titleForegroundColor())
                .font(.footnote)
                .opacity(title.isEmpty ? 0 : 1)
                .frame(height: title.isEmpty ? 0 : nil)
            Spacer()
                .frame(height: title.isEmpty ? 0 : 10)
            ZStack(alignment: .leading) {
                HStack {
                    ZStack {
                        if showPlaceHolder {
                            Text(placeholder)
                                .font(.callout)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(height: 38)
                                .foregroundColor(placeholderForegroundColor())
                        }
                        content
                            .font(.callout)
                            .foregroundColor(contentForegroundColor())
                            .frame(height: 38)
                    }
                    rightView()
                }
                .padding(.horizontal, 10)
                .background(backgroundColor())
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(error.isEmpty ? Color.textFieldBorder : Color.redError)
                )
            }
            Spacer()
                .frame(height: error.isEmpty ? 0 : 10)
            Text(error)
                .foregroundColor(.redError)
                .font(.footnote.weight(.semibold))
                .opacity(error.isEmpty ? 0 : 1)
                .frame(height: error.isEmpty ? 0 : nil)
        }
    }
    
    // For future dark mode support, add to this methods a check to 'colorScheme == .dark' to return different colors
    
    private func placeholderForegroundColor() -> Color {
        return .black.opacity(0.3)
    }
    
    private func titleForegroundColor() -> Color {
        return .black.opacity(0.6)
    }
    
    private func contentForegroundColor() -> Color {
        return Color.init(white: disabled ? 0.7 : 0)
    }
    
    private func backgroundColor() -> Color {
        return disabled ? Color.textFieldBorder : Color.clear
    }
}

extension TextFieldStylizer where RightContent == EmptyView {
    init(title: String, error: String = "", disabled: Bool = false, showPlaceHolder: Bool = false, placeholder: String = "") {
        self.title = title
        self.error = error
        self.disabled = disabled
        self.showPlaceHolder = showPlaceHolder
        self.placeholder = placeholder
        self.rightView = { nil }
    }
}

extension View {
    
    func styledTextField(title: String, error: String = "") -> some View {
        modifier(TextFieldStylizer(title: title, error: error))
    }
    
    func styledTextField<RightContent: View>(
        title: String,
        error: String,
        disabled: Bool,
        showPlaceHolder: Bool = false,
        placeholder: String = "",
        @ViewBuilder rightView: @escaping () -> RightContent
    ) -> some View {
        modifier(TextFieldStylizer(title: title, error: error, disabled: disabled, showPlaceHolder: showPlaceHolder, placeholder: placeholder, rightView: rightView))
    }
}

struct TextFieldView<Content>: View where Content: View {
    
    let title: String
    let placeholder: String
    let error: String
    @Binding var text: String
    let disabled: Bool
    let rightView: () -> Content?
    
    init(
        title: String,
        placeholder: String = "",
        error: String = "",
        text: Binding<String>,
        disabled: Bool = false,
        @ViewBuilder rightView: @escaping () -> Content?
    ) {
        self.title = title
        self.placeholder = placeholder
        self.error = error
        self._text = text
        self.disabled = disabled
        self.rightView = rightView
    }
    
    var body: some View {
        TextField("", text: $text)
            .disabled(disabled)
            .font(.callout)
            .styledTextField(title: title, error: error, disabled: disabled, showPlaceHolder: text.isEmpty, placeholder: placeholder, rightView: rightView)
    }
}

extension TextFieldView where Content == EmptyView {
    init(
        title: String,
        placeholder: String = "",
        error: String = "",
        disabled: Bool = false,
        text: Binding<String>
    ) {
        self.title = title
        self.placeholder = placeholder
        self.error = error
        self._text = text
        self.disabled = disabled
        self.rightView = { nil }
    }
}

struct TextFieldView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(spacing: 30) {
            
            TextFieldView(
                title: "Username",
                placeholder: "Required",
                error: "Campo obligatorio",
                text: .constant("")
            ) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.gray)
                    .onTapGesture { }
            }
            
            TextField("Simple", text: .constant("Pepe"))
                .styledTextField(
                    title: "Username",
                    error: "",
                    disabled: true
                ) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color.gray)
                        .onTapGesture { }
                }
            
            TextField("Simple", text: .constant("Pepe"))
                .styledTextField(
                    title: "Username",
                    error: "",
                    disabled: false
                ) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color.gray)
                        .onTapGesture { }
                }
            
            SecureFieldView(
                title: "Password",
                placeholder: "Mandatory",
                error: "Debe tener al menos 8 caracteres",
                text: .constant("Juan")
            )
        }
        .background(Color.white)
        //        .preferredColorScheme(.dark)
        .padding()
        
    }
}

