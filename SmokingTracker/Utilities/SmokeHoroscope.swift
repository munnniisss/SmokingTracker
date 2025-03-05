import Foundation

struct SmokeHoroscope {
	static let predictions = [
		"Сегодня ты выкуришь 3 сигареты, и соседский пёс украдёт зажигалку.",
		"Звёзды говорят: спрячь пачку, иначе бабушка найдёт и устроит лекцию.",
		"Твой день пройдёт в дыму, но кофе спасёт ситуацию.",
		"Никотин шепчет: 'ещё одну', но ты сильнее этого шёпота!",
		"К вечеру ты решишь бросить, но найдешь сигарету под диваном."
	]

	static func dailyPrediction(sessionCount: Int) -> String {
		let daySeed = Calendar.current.component(.day, from: Date())
		let index = (daySeed + sessionCount) % predictions.count
		return predictions[index]
	}
}
