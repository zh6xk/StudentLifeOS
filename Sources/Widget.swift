import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), title: "Tugas Kampus", description: "Memuat data...")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), title: "Tugas Kampus", description: "Siap belajar hari ini!")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        guard let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.studentlife.shared"
        ) else {
            completion(Timeline(entries: [SimpleEntry(date: Date(), title: "Error", description: "App Group tidak ditemukan")], policy: .atEnd))
            return
        }
        let storeURL = groupURL.appendingPathComponent("StudentLifeOS.sqlite")
        let config = ModelConfiguration(schema: Schema([TaskItem.self]), url: storeURL)

        do {
            let container = try ModelContainer(for: TaskItem.self, configurations: config)
            let fetchContext = ModelContext(container)
            var descriptor = FetchDescriptor<TaskItem>(
                predicate: #Predicate { $0.isCompleted == false },
                sortBy: [SortDescriptor(\.dueDate)]
            )
            descriptor.fetchLimit = 1
            let nearestTask = try fetchContext.fetch(descriptor).first

            let entry: SimpleEntry
            if let task = nearestTask {
                entry = SimpleEntry(date: Date(), title: task.title, description: "Deadline: \(task.dueDate.formatted(date: .abbreviated, time: .shortened))")
            } else {
                entry = SimpleEntry(date: Date(), title: "Tidak ada tugas", description: "Semua tugas sudah selesai!")
            }
            completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(900))))
        } catch {
            completion(Timeline(entries: [SimpleEntry(date: Date(), title: "Error", description: "\(error.localizedDescription)")], policy: .atEnd))
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let description: String
}

struct StudentLifeOSWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.title)
                .font(.headline)
                .bold()
                .foregroundColor(.blue)
            
            Text(entry.description)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

@main
struct StudentLifeOSWidget: Widget {
    let kind: String = "StudentLifeOSWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            StudentLifeOSWidgetEntryView(entry: entry)
                .containerBackground(Color.white, for: .widget)
        }
        .configurationDisplayName("StudentLifeOS Widget")
        .description("Pantau tugas kampusmu dari layar utama.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
