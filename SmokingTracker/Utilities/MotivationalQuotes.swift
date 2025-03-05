import Foundation

struct MotivationalQuotes {
	static let quotes = [
		"Каждый покур, которого ты избегаешь, — шаг к свободе.",
		"Твоё здоровье стоит больше, чем любая сигарета.",
		"Ты сильнее своей привычки!",
		"Свежий воздух лучше дыма.",
		"Сегодня ты ближе к цели, чем вчера."
	]

	static func randomQuote() -> String {
		quotes.randomElement() ?? quotes[0]
	}
}
