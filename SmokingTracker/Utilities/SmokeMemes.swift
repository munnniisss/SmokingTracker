import Foundation

struct SmokeMemes {
	static let memes = [
		"Когда мама сказала бросить, а ты уже на второй пачке.",
		"Курил 5 минут, кашлял 10 — новый рекорд!",
		"Сигареты — это как Wi-Fi: чем ближе, тем сложнее отказаться.",
		"Жизнь — дым, а я — генератор этого дыма.",
		"Бросаю курить... завтра, как всегда."
	]

	static func randomMeme() -> String {
		memes.randomElement() ?? memes[0]
	}
}
