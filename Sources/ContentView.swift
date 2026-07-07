import SwiftUI
import SwiftData

struct ContentView: View {
    // Menghubungkan ke database
    @Environment(\.modelContext) private var context
    
    // Mengambil data Task secara otomatis (Diurutkan dari tenggat waktu terdekat)
    @Query(sort: \TaskItem.dueDate) private var tasks: [TaskItem]
    
    // Mengambil data Pengeluaran
    @Query(sort: \ExpenseItem.date, order: .reverse) private var expenses: [ExpenseItem]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // 1. Bagian Header Sapaan
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Halo, Mahasiswa! 👋")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                        
                        Text("Siap untuk produktif hari ini?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // 2. Kartu Progress (Menghitung Data Asli)
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Ringkasan Hari Ini")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                            
                            // Menghitung jumlah tugas yang belum selesai
                            let pendingTasks = tasks.filter { !$0.isCompleted }.count
                            Text("\(pendingTasks) Tugas Menunggu")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            // Menghitung total pengeluaran
                            let totalExpense = expenses.reduce(0) { $0 + $1.amount }
                            Text("Total Keluar: Rp\(Int(totalExpense))")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 45))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(20)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)

                    // 3. Tombol Tambah Data Cepat
                    HStack {
                        Button(action: addTask) {
                            Label("Tugas Baru", systemImage: "plus.circle.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(12)
                        }
                        
                        Button(action: addExpense) {
                            Label("Pengeluaran", systemImage: "banknote.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .foregroundColor(.green)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)

                    // 4. Judul Daftar Jadwal
                    Text("Agenda Kamu")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    // 5. Daftar Kartu Tugas dari Database
                    if tasks.isEmpty {
                        Text("Belum ada tugas. Yeay! 🎉")
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    } else {
                        VStack(spacing: 15) {
                            ForEach(tasks) { task in
                                TaskCardView(task: task)
                            }
                            .onDelete(perform: deleteTasks) // Bisa di-swipe untuk hapus
                        }
                    }
                }
                .padding(.bottom, 30)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - FUNGSI DATABASE
    
    // Menambah data contoh (Bisa diganti dengan form input nantinya)
    private func addTask() {
        let newTask = TaskItem(title: "Tugas Baru", dueDate: .now.addingTimeInterval(86400), taskType: "Tugas")
        context.insert(newTask)
    }
    
    private func addExpense() {
        let newExpense = ExpenseItem(title: "Makan Siang", amount: 25000)
        context.insert(newExpense)
    }
    
    private func deleteTasks(offsets: IndexSet) {
        for index in offsets {
            context.delete(tasks[index])
        }
    }
}

// MARK: - DESAIN KARTU TUGAS
struct TaskCardView: View {
    @Bindable var task: TaskItem // @Bindable agar bisa dicentang dan simpan ke database
    
    var body: some View {
        HStack(spacing: 15) {
            // Tombol Centang Interaktif
            Button {
                withAnimation {
                    task.isCompleted.toggle()
                }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.headline)
                    // Coret teks jika sudah selesai
                    .strikethrough(task.isCompleted, color: .gray)
                    .foregroundColor(task.isCompleted ? .gray : .primary)
                
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .font(.caption)
                    Text(task.dueDate, format: .dateTime.day().month().hour().minute())
                        .font(.subheadline)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Label Kategori (Pil)
            Text(task.taskType)
                .font(.caption)
                .fontWeight(.bold)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(Color.orange.opacity(0.15))
                .foregroundColor(.orange)
                .cornerRadius(10)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
        // Efek transparan jika tugas selesai
        .opacity(task.isCompleted ? 0.6 : 1.0)
    }
}
