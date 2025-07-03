//
//  AddItemView.swift
//  ToDo App Prototype
//
//  Created by Alpha Sow on 6/9/25.
//

import SwiftUI
import SwiftData

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var itemDescription: String = ""
    @State private var priority: Priority = .medium
    @State private var dueDate: Date? = nil
    @State private var dueDateValue = Date()
    @State private var showDatePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Task Details") {
                    TextField("Task Title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Description (optional)", text: $itemDescription, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            Text(priority.displayName)
                                .tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section {
                    Toggle(isOn: $showDatePicker) {
                        Text(dueDate != nil ? "Due: \(dueDate!, formatter: dateFormatter)" : "Set Due Date")
                    }
                    if showDatePicker {
                        DatePicker("Select Due Date", selection: $dueDateValue, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                    }
                } header: {
                    Text("Due Date")
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let finalDueDate = showDatePicker ? dueDateValue : nil
                        addItem(dueDate: finalDueDate)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func addItem(dueDate: Date?) {
        let newItem = Item(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            priority: priority,
            completed: false,
            itemDescription: itemDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            dueDate: dueDate
        )
        
        modelContext.insert(newItem)
        try? modelContext.save()
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Item.self, configurations: config)
    
    return AddItemView()
        .modelContainer(container)
} 