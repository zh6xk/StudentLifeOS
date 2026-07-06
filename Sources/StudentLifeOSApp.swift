import SwiftUI
import SwiftData

@main
struct StudentLifeOSApp: App {
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([TaskItem.self, ExpenseItem.self])
        guard let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.studentlife.shared"
        ) else {
            fatalError("App Group tidak ditemukan, cek project.yml")
        }
        let storeURL = groupURL.appendingPathComponent("StudentLifeOS.sqlite")
        let config = ModelConfiguration(schema: schema, url: storeURL)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Gagal membuat ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
