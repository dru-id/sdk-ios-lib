//
//  File.swift
//
//
//  Created on 9/2/23.
//

import SwiftUI

struct CustomDatePickerView: View {
    
    @Binding var selectedDate: Date?
    @State private var hiddenDate: Date = Date()
    private var title: String = ""
    private let placeholder: String
    private var dateRange: ClosedRange<Date>
    private let error: String
    
    init(
        title: String,
        placeholder: String,
        dateRange: ClosedRange<Date>,
        selectedDate: Binding<Date?>,
        error: String = ""
    ) {
        self.title = title
        self.placeholder = placeholder
        self.dateRange = dateRange
        self._selectedDate = selectedDate
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
                    DatePicker(
                        title,
                        selection: $hiddenDate,
                        in: dateRange,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .onChange(of: hiddenDate, perform: { _ in
                        self.selectedDate = hiddenDate
                    })
                }
            } label: {
                HStack {
                    if selectedDate == nil {
                        Text(placeholder)
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .foregroundColor(.black.opacity(0.6))
                    } else {
                        Text(hiddenDate, style: .date)
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .foregroundColor(.black)
                    }
                    Image(systemName: "calendar")
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
}


struct CustomDatePickerView_Previews: PreviewProvider {
    
    @State private var selectedDate: Date = Date()
    
    static var previews: some View {
        NavigationView {
            CustomDatePickerView(
                title: "Picker title",
                placeholder: "dd/MM/yyyy",
                dateRange: dateRange(),
                selectedDate: .constant(nil),
                error: "Mandatory error"
            )
            .padding()
        }
    }
    
    static func dateRange() -> ClosedRange<Date> {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: 2021, month: 1, day: 1)
        let endComponents = DateComponents(year: 2021, month: 12, day: 31, hour: 23, minute: 59, second: 59)
        return calendar.date(from:startComponents)!
        ...
        calendar.date(from:endComponents)!
    }
}

