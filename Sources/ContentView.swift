import SwiftUI
import SwiftData
import WidgetKit

// MARK: - Theme & Colors
struct Theme {
    static let navy = Color(red: 10/255, green: 38/255, blue: 71/255)
    static let background = Color(red: 242/255, green: 244/255, blue: 247/255)
    static let greenAccent = Color(red: 43/255, green: 155/255, blue: 133/255)
    static let orangeAccent = Color(red: 253/255, green: 228/255, blue: 209/255)
    static let orangeText = Color(red: 220/255, green: 120/255, blue: 80/255)
    static let lightBlueAccent = Color(red: 205/255, green: 225/255, blue: 244/255)
    static let lightBlueText = Color(red: 80/255, green: 130/255, blue: 180/255)
}

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Home", systemImage: "house.fill") }
            TaskView()
                .tabItem { Label("Tugas", systemImage: "list.bullet.clipboard") }
            ExpenseView()
                .tabItem { Label("Keuangan", systemImage: "rupiahsign.circle") }
        }
        .tint(Theme.navy)
    }
}

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [TaskItem]
    @Query private var expenses: [ExpenseItem]
    
    var body: some View {
        ZStack(alignment: .top) {
            Theme.background.ignoresSafeArea()
            
            // Curved Header Background
            Theme.navy
                .clipShape(RoundedCorner(radius: 30, corners: [.bottomLeft, .bottomRight]))
                .frame(height: 180)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        Text("Search").foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(10)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(10)
                    
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .font(.title2)
                            .foregroundColor(.white)
                            .overlay(
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 8, y: -8)
                            )
                    }
                    .padding(.leading, 10)
                }
                .padding(.horizontal)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Total Pengeluaran Card
                        let totalExpense = expenses.reduce(0) { $0 + $1.amount }
                        DashboardCard {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "creditcard.fill")
                                        .foregroundColor(Theme.greenAccent)
                                        .padding(8)
                                        .background(Theme.greenAccent.opacity(0.2))
                                        .cornerRadius(8)
                                    Spacer()
                                    Text("Bulan Ini")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Theme.lightBlueAccent)
                                        .foregroundColor(Theme.lightBlueText)
                                        .clipShape(Capsule())
                                }
                                
                                Text("Total Pengeluaran")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.top, 5)
                                
                                HStack {
                                    Text("Rp \(totalExpense, specifier: "%.0f")")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    Spacer()
                                    Text("+ 0%")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Theme.greenAccent)
                                        .foregroundColor(.white)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Tasks Cards
                        HStack(spacing: 15) {
                            let completedTasks = tasks.filter { $0.isCompleted }.count
                            let totalTasksCount = tasks.count
                            let pendingTasks = totalTasksCount - completedTasks
                            
                            DashboardCard {
                                VStack(alignment: .leading, spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Theme.lightBlueText)
                                        .padding(8)
                                        .background(Theme.lightBlueAccent)
                                        .cornerRadius(8)
                                    
                                    Text("Tugas\nSelesai")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    Text("\(completedTasks) dari \(totalTasksCount)")
                                        .font(.caption)
                                        .foregroundColor(Theme.greenAccent)
                                        .fontWeight(.medium)
                                }
                            }
                            
                            DashboardCard {
                                VStack(alignment: .leading, spacing: 10) {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(Theme.orangeText)
                                        .padding(8)
                                        .background(Theme.orangeAccent)
                                        .cornerRadius(8)
                                    
                                    Text("Tugas\nPending")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    Text("\(pendingTasks) tugas")
                                        .font(.caption)
                                        .foregroundColor(Theme.orangeText)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Recent Activity
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("Aktivitas Terbaru")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Spacer()
                                Text("Lihat Semua")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.navy)
                            }
                            
                            DashboardCard {
                                VStack(spacing: 0) {
                                    if expenses.isEmpty && tasks.isEmpty {
                                        Text("Belum ada aktivitas")
                                            .foregroundColor(.gray)
                                            .padding()
                                    } else {
                                        ForEach(Array(expenses.prefix(2).enumerated()), id: \.element.id) { index, expense in
                                            ActivityRow(icon: "creditcard.fill", iconColor: Theme.greenAccent, iconBg: Theme.greenAccent.opacity(0.2), title: expense.title, subtitle: expense.date.formatted(date: .abbreviated, time: .omitted), value: String(format: "Rp %.0f", expense.amount), valueColor: Theme.greenAccent)
                                            Divider().padding(.vertical, 10)
                                        }
                                        
                                        ForEach(Array(tasks.prefix(2).enumerated()), id: \.element.id) { index, task in
                                            ActivityRow(icon: "doc.text.fill", iconColor: Theme.orangeText, iconBg: Theme.orangeAccent, title: task.title, subtitle: task.dueDate.formatted(date: .abbreviated, time: .omitted), value: task.isCompleted ? "Selesai" : "Pending", valueColor: task.isCompleted ? Theme.greenAccent : Theme.orangeText)
                                            if index != min(tasks.count, 2) - 1 {
                                                Divider().padding(.vertical, 10)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
    }
}

struct ActivityRow: View {
    var icon: String
    var iconColor: Color
    var iconBg: Color
    var title: String
    var subtitle: String
    var value: String
    var valueColor: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
                .background(iconBg)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(valueColor)
        }
    }
}

struct DashboardCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
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
