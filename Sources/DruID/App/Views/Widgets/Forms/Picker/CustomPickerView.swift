//
//  PickerView.swift
//
//
//  Created on 9/2/23.
//

import SwiftUI

struct CustomPickerView: View {
    
    @Binding var selectedValueId: String?
    @State private var hiddenSelectedValueId: String = ""
    private var title: String = ""
    private let error: String
    private let placeholder: String
    private var values: [PickerModel]
    
    init(
        title: String,
        placeholder: String,
        values: [PickerModel],
        selectedValueId: Binding<String?>,
        error: String = ""
    ) {
        self.title = title
        self.placeholder = placeholder
        self.values = values
        self._selectedValueId = selectedValueId
        self.error = error
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .foregroundColor(.black.opacity(0.6))
                .font(.footnote)
                .opacity(title.isEmpty ? 0 : 1)
                .frame(height: title.isEmpty ? 0 : nil)
            
            Spacer()
                .frame(height: title.isEmpty ? 0 : 10)
            
            NavigationLink {
                Form {
                    Picker(title, selection: $hiddenSelectedValueId) {
                        ForEach(values, id: \.id) { model in
                            Text(model.value)
                        }
                    }
                    .pickerStyle(.inline)
                    .accentColor(.black)
                    .onChange(of: hiddenSelectedValueId, perform: { _ in
                        self.selectedValueId = hiddenSelectedValueId
                    })
                }
            } label: {
                HStack {
                    if selectedValueId == nil {
                        Text(placeholder)
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .foregroundColor(.black.opacity(0.6))
                    } else {
                        Text(getSelectedValue(selectedValueId: hiddenSelectedValueId))
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .foregroundColor(.black)
                    }
                    Image(systemName: "chevron.right")
                        .foregroundColor(.black.opacity(0.4))
                }
            }
            .frame(height: 38)
            .frame(maxWidth: .infinity,alignment: .leading)
            .padding(.init(top: 0, leading: .spacingM, bottom: 0, trailing: .spacingXS))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.textFieldBorder)
            )
            
            Spacer()
                .frame(height: error.isEmpty ? 0 : 10)
            Text(error)
                .foregroundColor(.redError)
                .font(.footnote.weight(.semibold))
                .opacity(error.isEmpty ? 0 : 1)
                .frame(height: error.isEmpty ? 0 : nil)
        }
    }
    
    func getSelectedValue(selectedValueId: String) -> String {
        return values.first { model in
            model.id == selectedValueId
        }?.value ?? ""
    }
}

extension CustomPickerView {
    
    struct PickerModel {
        let id: String
        let value: String
    }
    
}

struct CustomPickerView_Previews: PreviewProvider {
    
    @State private var selectedDate: Date = Date()
    
    static var previews: some View {
        NavigationView {
            CustomPickerView(
                title: "Picker title",
                placeholder: "Select one",
                values: [.init(id: "1", value: "value 1"), .init(id: "2", value: "value 2")],
                selectedValueId: .constant(nil),
                error: "Mandatory error"
            )
            .padding()
        }
    }
    
}

