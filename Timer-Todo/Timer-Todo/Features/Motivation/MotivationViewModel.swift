import Foundation
import Combine

final class MotivationViewModel: BaseViewModel<Void> {
    
    @Published var currentQuote: String = ""
    
    override init() {
        super.init()
        Logger.log(.info, "MotivationViewModel init")
        loadRandomQuote()
    }
    
    func loadRandomQuote() {
        Logger.log(.info, "Загружаем случайную цитату")
        currentQuote = Quotes.random()
        Logger.log(.info, "Цитата загружена: \"\(currentQuote)\"")
    }
    
}
