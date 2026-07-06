import Foundation
import SwiftData

@Model
class ExpenseItem {
    var title: String
    var amount: Double
    var date: Date
    
    init(title: String, amount: Double, date: Date = .now) {
        self.title = title
        self.amount = amount
        self.date = date
    }
}

@Model
class TaskItem {
    var title: String
    var dueDate: Date
    var isCompleted: Bool
    var taskType: String
    
    init(title: String, dueDate: Date = .now, isCompleted: Bool = false, taskType: String = "Kampus") {
        self.title = title
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.taskType = taskType
    }
}
