import Foundation
import Combine

final class FocusViewModel: BaseViewModel<FocusState> {
    
    @Published var isInGame: Bool = false
    @Published var gameState = GameState()
    
    private var timer: Timer?
    
    override init() {
        super.init()
        Logger.log(.info, "FocusViewModel инициализирован")
        viewState = .loaded(FocusState())
    }
    
    func startSession() {
        Logger.log(.info, "FocusViewModel: Запуск новой сессии фокуса")
        guard case .loaded(var state) = viewState else { return }
        
        state.phase = .work
        state.remainingSeconds = state.phase.durationSeconds
        state.currentCycle = 1
        
        viewState = .loaded(state)
        startTimer()
        Logger.log(.info, "Сессия запущена: фаза \(state.phase), время \(state.remainingSeconds) сек")
    }
    
    func pauseOrResume() {
        guard case .loaded(var state) = viewState else { return }
        
        if state.phase == .idle {
            startSession()
            return
        }
        
        if timer != nil {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    func resetSession() {
        stopTimer()
        viewState = .loaded(FocusState())
        isInGame = false
        gameState = GameState()
    }
    
    func startBreakGame() {
        Logger.log(.info, "Запуск мини-игры в перерыве")
        guard case .loaded(var state) = viewState else { return }
        
        state.phase = .shortBreak
        state.remainingSeconds = state.phase.durationSeconds
        viewState = .loaded(state)
        
        gameState = GameState()
        isInGame = true
        
        startTimer()
    }
    
    func addScore(_ points: Int = 1) {
        gameState.score += Int(Double(points) * gameState.multiplier)
        Logger.log(.info, "Добавлено очков: +\(points), всего: \(gameState.score)")
    }
    
    func endGame() {
        isInGame = false
    }
    
    private func startTimer() {
        stopTimer()
        
        Logger.log(.info, "Таймер запущен")
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            guard case .loaded(var state) = self.viewState else { return }
            
            if state.remainingSeconds > 0 {
                state.remainingSeconds -= 1
            } else {
                self.completePhase(&state)
            }
            
            self.viewState = .loaded(state)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func completePhase(_ state: inout FocusState) {
        stopTimer()
        
        Logger.log(.info, "Фаза завершена: \(state.phase)")
        switch state.phase {
        case .work:
            state.totalCyclesToday += 1
            state.phase = .shortBreak
            state.remainingSeconds = state.phase.durationSeconds
            
        case .shortBreak, .longBreak:
            state.phase = .work
            state.remainingSeconds = state.phase.durationSeconds
            state.currentCycle += 1
            isInGame = false
            
        case .idle:
            break
        }
    }
    
}
