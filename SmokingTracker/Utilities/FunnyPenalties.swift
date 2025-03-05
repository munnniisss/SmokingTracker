import Foundation

struct FunnyPenalties {
	static let penalties = [
		"Спой 'Ой, мороз, мороз' на балконе.",
		"Покури следующую сигарету на одной ноге.",
		"Сделай 5 отжиманий и скажи 'Я сильнее никотина!'",
		"Позвони другу и кашляй 10 секунд без объяснений.",
		"Нарисуй сигарету и съешь рисунок (шутка, просто спрячь его)."
	]

	static func randomPenalty() -> String {
		penalties.randomElement() ?? penalties[0]
	}
}
