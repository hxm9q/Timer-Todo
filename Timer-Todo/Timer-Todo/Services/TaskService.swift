import Foundation

final class TaskService {
    
    static let shared = TaskService()
    
    static let tasksDidChangeNotification = Notification.Name("tasksDidChangeNotification")
    
    private let tasksKey = "todayTasks"
    
    private var todayTasks: [TaskItem] = []
    
    init() { loadTasks() }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let tasks = try? JSONDecoder().decode([TaskItem].self, from: data) {
            todayTasks = tasks
        } else {
            todayTasks = [
                TaskItem(title: "Закончить дизайн главной"),
                TaskItem(title: "Ответить на письма"),
                TaskItem(title: "Прогулка 30 минут")
            ]
        }
    }
    
    private func saveTasks() {
        if let data = try? JSONEncoder().encode(todayTasks) {
            UserDefaults.standard.set(data, forKey: tasksKey)
            
            NotificationCenter.default.post(name: Self.tasksDidChangeNotification, object: nil)
        }
    }
    
    func getTodayTasks() async throws -> [TaskItem] {
        return todayTasks
    }
    
    func toggleCompletion(_ task: TaskItem) async throws {
        if let index = todayTasks.firstIndex(where: { $0.id == task.id }) {
            todayTasks[index].isCompleted.toggle()
            saveTasks()
        }
    }
    
    func addTask(_ task: TaskItem) async throws {
        todayTasks.append(task)
        saveTasks()
    }
    
    func deleteTask(_ task: TaskItem) async throws {
        todayTasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func getAllTasks() async throws -> [TaskItem] {
        return todayTasks
    }
    
}
