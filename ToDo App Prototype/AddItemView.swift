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
    @State private var smartInput: String = ""
    @State private var isParsingAI = false
    @State private var aiError: String? = nil
    
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
                        DatePicker("Select Due Date & Time", selection: $dueDateValue, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(GraphicalDatePickerStyle())
                    }
                } header: {
                    Text("Due Date")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Text("Smart Input (AI)")
                                .font(.headline)
                            Text("BETA")
                                .font(.caption2)
                                .bold()
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.yellow.opacity(0.8))
                                .foregroundColor(.black)
                                .clipShape(Capsule())
                        }
                        Text("Type a task in plain English and let AI fill the form for you!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("e.g. Buy groceries tomorrow at 5pm, high priority", text: $smartInput)
                            .padding(10)
                            .background(Color.gray.opacity(0.12))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                            )
                        HStack(spacing: 12) {
                            Button {
                                isParsingAI = true
                                aiError = nil
                                AIService.shared.parseTaskWithAI(input: smartInput) { parsed in
                                    DispatchQueue.main.async {
                                        isParsingAI = false
                                        guard let parsed = parsed else {
                                            aiError = "Could not parse task. Try rephrasing."
                                            return
                                        }
                                        title = parsed.title
                                        var parsedDate: Date? = nil
                                        if let due = parsed.dueDate {
                                            let isoFormatter = ISO8601DateFormatter()
                                            parsedDate = isoFormatter.date(from: due)
                                            if parsedDate == nil {
                                                let fallbackFormatter = DateFormatter()
                                                fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                                                fallbackFormatter.locale = Locale(identifier: "en_US_POSIX")
                                                parsedDate = fallbackFormatter.date(from: due)
                                            }
                                        }
                                        if parsedDate == nil, let human = parsed.humanReadableDueDate {
                                            let fallbackFormatter = DateFormatter()
                                            fallbackFormatter.dateStyle = .medium
                                            fallbackFormatter.timeStyle = .short
                                            fallbackFormatter.locale = Locale(identifier: "en_US_POSIX")
                                            parsedDate = fallbackFormatter.date(from: human)
                                        }
                                        if let parsedDate = parsedDate {
                                            dueDate = parsedDate
                                            dueDateValue = parsedDate
                                            showDatePicker = true
                                        } else if parsed.dueDate != nil || parsed.humanReadableDueDate != nil {
                                            aiError = "AI found a date but couldn't parse it. Please edit manually."
                                        }
                                        if let parsedPriority = parsed.priority, let p = Priority(rawValue: parsedPriority.lowercased()) {
                                            priority = p
                                        }
                                        if !parsed.title.isEmpty {
                                            title = parsed.title
                                        }
                                        if let desc = parsed.humanReadableDueDate, itemDescription.isEmpty {
                                            itemDescription = desc
                                        }
                                    }
                                }
                            } label: {
                                if isParsingAI {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                                        .frame(width: 24, height: 24)
                                } else {
                                    Label("Parse with AI", systemImage: "wand.and.stars")
                                        .font(.body.bold())
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.purple)
                            .disabled(isParsingAI || smartInput.isEmpty)
                            if let aiError = aiError {
                                Text(aiError)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .lineLimit(2)
                            }
                        }
                    }
                    .padding(.vertical, 4)
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
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Item.self, configurations: config)
    
    return AddItemView()
        .modelContainer(container)
} 