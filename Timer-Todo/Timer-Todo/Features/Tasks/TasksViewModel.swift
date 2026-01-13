import UIKit
import Combine

final class TasksViewModel: BaseViewModel<[TaskItem]> {
    
    enum Filter: String, CaseIterable {
        case all = "Все"
        case active = "Активные"
        case completed = "Выполненные"
    }
    
    @Published var currentFilter: Filter = .all
    @Published var searchText: String = ""
    @Published var showAddSheet: Bool = false
    
    @Published var newTitle: String = ""
    @Published var newPriority: TaskItem.Priority = .medium
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        Logger.log(.info, "TasksViewModel инициализирован")
        Task { await loadTasks() }
        
        NotificationCenter.default.publisher(for: TaskService.tasksDidChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Logger.log(.info, "TasksViewModel: получено уведомление об изменении задач")
                Task { await self?.loadTasks() }
            }
            .store(in: &cancellables)
    }
    
    func loadTasks() async {
        Logger.log(.info, "Начало загрузки задач")
        viewState = .loading
        do {
            let tasks = try await TaskService.shared.getAllTasks()
            viewState = .loaded(tasks)
            Logger.log(.info, "Загружено \(tasks.count) задач")
        } catch {
            Logger.log(.error, "Ошибка при загрузке задач: \(error.localizedDescription)")
            handleError(error)
        }
    }
    
    func toggleCompletion(_ task: TaskItem) async {
        Logger.log(.info, "Переключение статуса задачи: \(task.title) (id: \(task.id))")
        do {
            try await TaskService.shared.toggleCompletion(task)
            Logger.log(.info, "Статус задачи успешно изменён")
            await loadTasks()
        } catch {
            Logger.log(.error, "Ошибка при переключении статуса задачи: \(error.localizedDescription)")
            handleError(error)
        }
    }
    
    func deleteTask(_ task: TaskItem) async {
        Logger.log(.info, "Удаление задачи: \(task.title) (id: \(task.id))")
        do {
            try await TaskService.shared.deleteTask(task)
            Logger.log(.info, "Задача успешно удалена")
            await loadTasks()
        } catch {
            Logger.log(.error, "Ошибка при удалении задачи: \(error.localizedDescription)")
            handleError(error)
        }
    }
    
    func addTask() async {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            Logger.log(.warning, "Попытка добавить пустую задачу — проигнорировано")
            return
        }
        
        Logger.log(.info, "Добавление новой задачи: \"\(trimmed)\", приоритет: \(newPriority)")
        
        let newTask = TaskItem(title: trimmed, priority: newPriority)
        
        do {
            try await TaskService.shared.addTask(newTask)
            Logger.log(.info, "Задача успешно добавлена")
            await loadTasks()
            newTitle = ""
            newPriority = .medium
            showAddSheet = false
        } catch {
            Logger.log(.error, "Ошибка при добавлении задачи: \(error.localizedDescription)")
            handleError(error)
        }
    }
    
    var filteredTasks: [TaskItem] {
        guard case .loaded(let allTasks) = viewState else { return [] }
        
        var result = allTasks
        
        if !searchText.isEmpty {
            result = result.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        switch currentFilter {
        case .active:    result = result.filter { !$0.isCompleted }
        case .completed: result = result.filter { $0.isCompleted }
        case .all:       break
        }
        
        return result
    }
    
}
