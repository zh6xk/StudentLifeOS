import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), title: "Tugas Kampus", description: "Memuat data...")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), title: "Tugas Kampus", description: "Siap belajar hari ini!")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = SimpleEntry(date: Date(), title: "Tugas Terdekat", description: "Fokus belajar iOS hari ini!")
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
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
