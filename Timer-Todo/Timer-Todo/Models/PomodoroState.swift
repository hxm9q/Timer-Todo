import Foundation

struct PomodoroState {
    var remainingSeconds: Int = 25 * 60
    var isRunning: Bool = false
    var isPaused: Bool = false
    var phase: Phase = .work
    
    var totalSeconds: Int {
        phase == .work ? 25 * 60 : 5 * 60
    }
    
    var progress: Double {
        Double(remainingSeconds) / Double(totalSeconds)
    }
    
    enum Phase: String {
        case work = "Фокус"
        case breakTime = "Перерыв"
    }
}
