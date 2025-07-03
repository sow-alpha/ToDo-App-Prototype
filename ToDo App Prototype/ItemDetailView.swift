//
//  ItemDetailView.swift
//  ToDo App Prototype
//
//  Created by Alpha Sow on 6/9/25.
//

import SwiftUI
import SwiftData

struct ItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var item: Item
    
    @State private var title: String
    @State private var itemDescription: String
    @State private var priority: Priority
    @State private var completed: Bool
    @State private var dueDate: Date?
    @State private var dueDateValue: Date
    @State private var showDatePicker: Bool
    
    init(item: Item) {
        self.item = item
        self._title = State(initialValue: item.title)
        self._itemDescription = State(initialValue: item.itemDescription)
        self._priority = State(initialValue: item.priority)
        self._completed = State(initialValue: item.completed)
        self._dueDate = State(initialValue: item.dueDate)
        self._dueDateValue = State(initialValue: item.dueDate ?? Date())
        self._showDatePicker = State(initialValue: item.dueDate != nil)
    }
    
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
                
                Section("Status") {
                    Toggle("Completed", isOn: $completed)
                        .tint(.green)
                }
                
                Section("Created") {
                    Text(item.timestamp, style: .date)
                        .foregroundColor(.secondary)
                    Text(item.timestamp, style: .time)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        item.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        item.itemDescription = itemDescription.trimmingCharacters(in: .whitespacesAndNewlines)
                        item.priority = priority
                        item.completed = completed
                        item.dueDate = showDatePicker ? dueDateValue : nil
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
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
    
    let sampleItem = Item(title: "Sample Task", priority: .high, completed: false, itemDescription: "This is a sample task description")
    
    return ItemDetailView(item: sampleItem)
        .modelContainer(container)
} 