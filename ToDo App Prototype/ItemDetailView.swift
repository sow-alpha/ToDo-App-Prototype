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
    
    init(item: Item) {
        self.item = item
        self._title = State(initialValue: item.title)
        self._itemDescription = State(initialValue: item.itemDescription)
        self._priority = State(initialValue: item.priority)
        self._completed = State(initialValue: item.completed)
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
                            HStack {
                                Image(systemName: priority.icon)
                                    .foregroundColor(Color(priority.color))
                                Text(priority.displayName)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
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
                        saveChanges()
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        item.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        item.itemDescription = itemDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        item.priority = priority
        item.completed = completed
        
        try? modelContext.save()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Item.self, configurations: config)
    
    let sampleItem = Item(title: "Sample Task", priority: .high, completed: false, itemDescription: "This is a sample task description")
    
    return ItemDetailView(item: sampleItem)
        .modelContainer(container)
} 