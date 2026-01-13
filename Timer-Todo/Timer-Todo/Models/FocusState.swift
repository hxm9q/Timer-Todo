import Foundation

struct FocusState {
    var phase: Phase = .idle
    var remainingSeconds: Int = 1
    var currentCycle: Int = 0
    var totalCyclesToday: Int = 0
    
    enum Phase {
        case idle
        case work
        case shortBreak
        case longBreak
        
        var title: String {
            switch self {
            case .idle: return "Готов начать"
            case .work: return "Фокус"
            case .shortBreak: return "Короткий перерыв"
            case .longBreak: return "Длинный перерыв"
            }
        }
        
        var durationSeconds: Int {
            switch self {
            case .work: return 1
            case .shortBreak: return 5 * 60
            case .longBreak: return 15 * 60
            case .idle: return 0
            }
        }
    }
}

struct GameState {
    var score: Int = 0
    var multiplier: Double = 1.0
}
