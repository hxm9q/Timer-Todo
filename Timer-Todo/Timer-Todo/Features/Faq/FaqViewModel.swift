import Foundation

final class FAQViewModel: BaseViewModel<Void> {
    
    struct FAQEntry {
        let question: String
        let answer: String
    }
    
    let faqItems: [FAQEntry] = [
        FAQEntry(
            question: "Зачем 1 секунда в тестовом режиме?",
            answer: "Чтобы ты мог быстро проверить игру и таймер без ожидания 25 минут. В реальном режиме вернём 25 минут."
        ),
        FAQEntry(
            question: "Как работает мини-игра?",
            answer: "Тапай по кругу во время перерыва, набирай очки. Это награда за продуктивность!"
        ),
        FAQEntry(
            question: "Куда деваются задачи после выхода?",
            answer: "Сейчас данные общие для всех. Позже добавим разделение по пользователям."
        ),
        FAQEntry(
            question: "Как сбросить прогресс?",
            answer: "Пока кнопки нет, но можно удалить приложение — все данные сотрутся."
        ),
        FAQEntry(
            question: "Можно ли менять длительность Pomodoro?",
            answer: "Пока нет, но это одна из следующих фич — кастомное время работы/перерыва."
        )
    ]
    
}
