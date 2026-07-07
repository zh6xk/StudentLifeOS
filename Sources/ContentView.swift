import SwiftUI
import SwiftData
import WidgetKit

// MARK: - Theme & Colors
struct Theme {
    static let navy = Color(red: 44/255, green: 54/255, blue: 63/255)
    static let background = Color(red: 244/255, green: 241/255, blue: 234/255)
    static let greenAccent = Color(red: 107/255, green: 142/255, blue: 124/255)
    static let orangeAccent = Color(red: 238/255, green: 220/255, blue: 198/255)
    static let orangeText = Color(red: 184/255, green: 123/255, blue: 94/255)
    static let lightBlueAccent = Color(red: 217/255, green: 228/255, blue: 232/255)
    static let lightBlueText = Color(red: 92/255, green: 116/255, blue: 126/255)
}

struct ContentView: View {
    var body: some View {
        DashboardView()
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
                    
                    Menu {
                        Button("Tambah Tugas") {
                            modelContext.insert(TaskItem(title: "Tugas Baru", taskType: "Kampus"))
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                        Button("Tambah Pengeluaran") {
                            modelContext.insert(ExpenseItem(title: "Makan Siang", amount: 25000))
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
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
                                                .onSwipeDelete { modelContext.delete(expense) }
                                            Divider().padding(.vertical, 10)
                                        }
                                        
                                        ForEach(Array(tasks.prefix(2).enumerated()), id: \.element.id) { index, task in
                                            ActivityRow(icon: "doc.text.fill", iconColor: Theme.orangeText, iconBg: Theme.orangeAccent, title: task.title, subtitle: task.dueDate.formatted(date: .abbreviated, time: .omitted), value: task.isCompleted ? "Selesai" : "Pending", valueColor: task.isCompleted ? Theme.greenAccent : Theme.orangeText)
                                                .onSwipeDelete { modelContext.delete(task) }
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

struct SwipeToDeleteModifier: ViewModifier {
    var action: () -> Void
    @State private var offset: CGFloat = 0
    
    func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            if offset < 0 {
                Button(action: {
                    withAnimation {
                        action()
                        offset = 0
                    }
                }) {
                    Image(systemName: "trash")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 70, height: 50)
                        .background(Color.red)
                        .cornerRadius(12)
                }
                .padding(.trailing, 0)
            }
            
            content
                .background(Color.white)
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.width < 0 {
                                offset = value.translation.width
                            }
                        }
                        .onEnded { value in
                            withAnimation {
                                if value.translation.width < -40 {
                                    offset = -80
                                } else {
                                    offset = 0
                                }
                            }
                        }
                )
        }
    }
}

extension View {
    func onSwipeDelete(perform action: @escaping () -> Void) -> some View {
        self.modifier(SwipeToDeleteModifier(action: action))
    }
}
