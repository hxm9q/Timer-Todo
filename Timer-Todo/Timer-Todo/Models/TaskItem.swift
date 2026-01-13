import Foundation

struct TaskItem: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var isCompleted: Bool = false
    var priority: Priority = .medium
    
    enum Priority: String, Codable, CaseIterable {
        case high = "Высокий"
        case medium = "Средний"
        case low = "Низкий"
    }
}
