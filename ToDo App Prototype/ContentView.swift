import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var showingAddItem = false
    @State private var isEditing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.2)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Summary Cards
                        HStack(spacing: 12) {
                            SummaryCard(
                                title: "Total",
                                count: items.count,
                                color: .gray
                            )
                            
                            SummaryCard(
                                title: "Active",
                                count: items.filter { !$0.completed }.count,
                                color: .blue
                            )
                            
                            SummaryCard(
                                title: "Done",
                                count: items.filter { $0.completed }.count,
                                color: .cyan
                            )
                        }
                        .padding(.horizontal)
                        
                        // Priority Sections
                        VStack(spacing: 16) {
                            ForEach(Priority.allCases, id: \.self) { priority in
                                PrioritySection(
                                    priority: priority,
                                    items: items.filter { $0.priority == priority },
                                    isEditing: isEditing
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(isEditing ? "Done" : "Edit") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isEditing.toggle()
                        }
                    }
                    .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddItem = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView()
            }
        }
    }
}

struct SummaryCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct PrioritySection: View {
    let priority: Priority
    let items: [Item]
    let isEditing: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack {
                Image(systemName: priority.icon)
                    .foregroundColor(Color(priority.color))
                    .font(.system(size: 20, weight: .semibold))
                
                Text("\(priority.displayName) Priority")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(items.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .foregroundColor(.secondary)
            }
            
            // Todo Items
            VStack(spacing: 8) {
                if items.isEmpty {
                    HStack {
                        Spacer()
                        Text("No \(priority.displayName.lowercased()) priority tasks")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 16)
                        Spacer()
                    }
                } else {
                    ForEach(items) { item in
                        NavigationLink(destination: ItemDetailView(item: item)) {
                            ItemRow(item: item, isEditing: isEditing)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

struct ItemRow: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var item: Item
    let isEditing: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                toggleCompletion()
            }) {
                Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.completed ? .green : .gray)
                    .font(.system(size: 20))
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.body)
                    .foregroundColor(item.completed ? .secondary : .primary)
                    .strikethrough(item.completed)
                    .animation(.easeInOut(duration: 0.2), value: item.completed)
                
                if !item.itemDescription.isEmpty {
                    Text(item.itemDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                if let due = item.dueDate {
                    Text("Due: \(due, formatter: dateFormatter)")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            if isEditing {
                Button(action: {
                    // Delete action
                    deleteItem()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.system(size: 16))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
        .opacity(item.completed ? 0.6 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: item.completed)
    }
    
    private func toggleCompletion() {
        withAnimation(.easeInOut(duration: 0.2)) {
            item.completed.toggle()
            try? modelContext.save()
        }
    }
    
    private func deleteItem() {
        withAnimation(.easeInOut(duration: 0.2)) {
            modelContext.delete(item)
            try? modelContext.save()
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modelContainer(for: Item.self, inMemory: true)
    }
}
