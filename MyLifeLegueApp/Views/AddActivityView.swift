//
//  AddActivityView.swift
//  MyBigApp
//
//  Created by Alexander Saadia on 02/03/26.
//

import SwiftUI

struct AddActivityView: View {
    // MARK: - Stored properties
    @Environment(ActivityStore.self) private var activityStore
    @State private var name: String = ""
    @State private var selectedDate: Date = Date()
    @State private var selectedSymbol: String = "figure.walk"
    
    private let symbols = ["figure.walk", "figure.run", "book.fill", "gamecontroller.fill", "basketball.fill", "dumbbell", "figure.pool.swim"]
    
    // MARK: - body
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Activity Details")) {
                    TextField("Activity Name", text: $name)
                    
                    DatePicker("Date", selection: $selectedDate, displayedComponents: [.date])
                }
                
                Section(header: Text("Symbol")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(symbols, id: \.self) { symbol in
                                Image(systemName: symbol)
                                    .font(.title)
                                    .padding(10)
                                    .background(selectedSymbol == symbol ? Color.accentColor.opacity(0.2) : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .onTapGesture {
                                        selectedSymbol = symbol
                                    }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                
                Button(action: addActivity) {
                    Text("Add Activity")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(name.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(name.isEmpty)
            }
            .navigationTitle("Add Activity")
        }
    }
    
    // MARK: - Functions
    private func addActivity() {
        let newActivity = Activity(name: name, date: selectedDate, symbol: selectedSymbol)
        activityStore.addActivity(newActivity)
        
        // Reset fields
        name = ""
        selectedDate = Date()
    }
}

#Preview {
    PickerView()
}
