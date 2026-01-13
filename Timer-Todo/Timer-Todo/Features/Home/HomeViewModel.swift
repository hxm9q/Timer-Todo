import Foundation
import Combine

struct HomeOverview {
    var pomodoro: PomodoroState
    var tasks: [TaskItem]
}

final class HomeViewModel: BaseViewModel<HomeOverview> {
    
    @Published var newTaskTitle: String = ""
    
    private var timer: Timer?
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        Logger.log(.info, "HomeViewModel инициализирован")
        Task { await loadData() }
        NotificationCenter.default.publisher(for: TaskService.tasksDidChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Logger.log(.info, "HomeViewModel: получено уведомление об изменении задач")
                Task { await self?.loadData() }
            }
            .store(in: &cancellables)
    }
    
    func loadData() async {
        Logger.log(.info, "Начало загрузки данных для Home")
        viewState = .loading
        
        do {
            let tasks = try await TaskService.shared.getTodayTasks()
            
            let overview = HomeOverview(
                pomodoro: PomodoroState(),
                tasks: tasks
            )
            
            viewState = .loaded(overview)
            Logger.log(.info, "Данные успешно загружены: \(tasks.count) задач")
        } catch {
            Logger.log(.error, "Ошибка при загрузке данных Home: \(error.localizedDescription)")
            handleError(error)
        }
    }
    
    func toggleTaskCompletion(_ task: TaskItem) async {
        Logger.log(.info, "Переключение статуса задачи в Home: \"\(task.title)\" (id: \(task.id))")
        do {
            try await TaskService.shared.toggleCompletion(task)
            Logger.log(.info, "Статус задачи успешно изменён")
            await loadData()
        } catch {
            Logger.log(.error, "Ошибка при переключении статуса задачи: \(error.localizedDescription)")
            handleError(error)
        }
    }
    
    func startOrPausePomodoro() {
        guard case .loaded(var overview) = viewState else { return }
        
        Logger.log(.info, "Управление Pomodoro: текущий статус running=\(overview.pomodoro.isRunning)")
        
        var pomodoro = overview.pomodoro
        
        if pomodoro.isRunning {
            pomodoro.isRunning = false
            stopTimer()
            Logger.log(.info, "Pomodoro поставлен на паузу")
        } else {
            pomodoro.isRunning = true
            pomodoro.isPaused = false
            startTimer()
            Logger.log(.info, "Pomodoro запущен/возобновлён")
        }
        
        overview.pomodoro = pomodoro
        viewState = .loaded(overview)
    }
    
    func addQuickTask() async {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        Logger.log(.info, "Добавление быстрой задачи в Home: \"\(trimmed)\"")
        
        let newTask = TaskItem(title: trimmed)
        
        do {
            try await TaskService.shared.addTask(newTask)
            Logger.log(.info, "Быстрая задача успешно добавлена")
            await loadData()
            newTaskTitle = ""
        } catch {
            Logger.log(.error, "Ошибка при добавлении быстрой задачи: \(error.localizedDescription)")
            handleError(error)
        }
    }
    
    func resetPomodoro() {
        guard case .loaded(var overview) = viewState else { return }
        
        Logger.log(.info, "Сброс Pomodoro")
        
        overview.pomodoro = PomodoroState()
        stopTimer()
        
        viewState = .loaded(overview)
        Logger.log(.info, "Pomodoro сброшен")
    }
    
    private func startTimer() {
        stopTimer()
        
        Logger.log(.info, "Таймер Pomodoro запущен")
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            guard case .loaded(var overview) = self.viewState else { return }
            
            var pomodoro = overview.pomodoro
            
            if pomodoro.remainingSeconds > 0 {
                pomodoro.remainingSeconds -= 1
            } else {
                self.handlePhaseCompletion(&pomodoro)
            }
            
            overview.pomodoro = pomodoro
            self.viewState = .loaded(overview)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        Logger.log(.info, "Таймер Pomodoro остановлен")
    }
    
    private func handlePhaseCompletion(_ pomodoro: inout PomodoroState) {
        stopTimer()
        
        if pomodoro.phase == .work {
            pomodoro.phase = .breakTime
            pomodoro.remainingSeconds = 5 * 60
            pomodoro.isRunning = false
            
            print("Рабочий блок завершён! Начинаем перерыв")
        } else {
            pomodoro.phase = .work
            pomodoro.remainingSeconds = 25 * 60
            pomodoro.isRunning = false
            
            print("Перерыв завершён. Готов к новому фокусу!")
        }
    }
    
}
