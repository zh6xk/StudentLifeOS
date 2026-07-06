import SwiftUI
import SwiftData
import WidgetKit

struct ContentView: View {
    var body: some View {
        TabView {
            TaskView().tabItem { Label("Tugas", systemImage: "list.bullet.clipboard") }
            ExpenseView().tabItem { Label("Keuangan", systemImage: "rupiahsign.circle") }
        }
    }
}

struct TaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [TaskItem]
    var body: some View {
        NavigationStack {
            List {
                ForEach(tasks) { task in
                    VStack(alignment: .leading) {
                        Text(task.title).font(.headline)
                        Text(task.taskType).font(.caption).foregroundColor(.gray)
                    }
                }.onDelete(perform: deleteTasks)
            }
            .navigationTitle("Tugas (Tahap 1)")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Tambah") {
                        modelContext.insert(TaskItem(title: "Tugas Baru", taskType: "Kampus"))
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
            }
        }
    }
    private func deleteTasks(offsets: IndexSet) {
        for index in offsets { modelContext.delete(tasks[index]) }
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct ExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var expenses: [ExpenseItem]
    var body: some View {
        NavigationStack {
            List {
                ForEach(expenses) { expense in
                    HStack {
                        Text(expense.title)
                        Spacer()
                        Text("Rp \(expense.amount, specifier: "%.0f")")
                    }
                }.onDelete(perform: deleteExpenses)
            }
            .navigationTitle("Pengeluaran")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Tambah") {
                        modelContext.insert(ExpenseItem(title: "Makan Siang", amount: 25000))
                    }
                }
            }
        }
    }
    private func deleteExpenses(offsets: IndexSet) {
        for index in offsets { modelContext.delete(expenses[index]) }
    }
}
