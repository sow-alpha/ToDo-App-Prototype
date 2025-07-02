//
//  ToDo_App_PrototypeApp.swift
//  ToDo App Prototype
//
//  Created by Alpha Sow on 6/9/25.
//

import SwiftUI
import SwiftData

@main
struct ToDo_App_PrototypeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    addSampleDataIfNeeded()
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func addSampleDataIfNeeded() {
        let context = sharedModelContainer.mainContext
        let fetchDescriptor = FetchDescriptor<Item>()
        
        do {
            let existingItems = try context.fetch(fetchDescriptor)
            if existingItems.isEmpty {
                // Add sample data
                let sampleItems = [
                    Item(title: "Complete project proposal", priority: .high, completed: false, itemDescription: "Finish the client proposal document"),
                    Item(title: "Review client feedback", priority: .high, completed: true, itemDescription: "Go through recent client comments"),
                    Item(title: "Schedule team meeting", priority: .medium, completed: false, itemDescription: "Set up weekly team sync"),
                    Item(title: "Update documentation", priority: .medium, completed: false, itemDescription: "Update API documentation"),
                    Item(title: "Organize desk workspace", priority: .low, completed: false, itemDescription: "Clean up desk area"),
                    Item(title: "Read industry newsletter", priority: .low, completed: true, itemDescription: "Stay updated with latest trends")
                ]
                
                for item in sampleItems {
                    context.insert(item)
                }
                
                try context.save()
            }
        } catch {
            print("Error adding sample data: \(error)")
        }
    }
}
