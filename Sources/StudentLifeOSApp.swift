import SwiftUI
import SwiftData

@main
struct StudentLifeOSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // INI SANGAT PENTING: Mengaktifkan database SwiftData
        .modelContainer(for: [ExpenseItem.self, TaskItem.self])
    }
}
