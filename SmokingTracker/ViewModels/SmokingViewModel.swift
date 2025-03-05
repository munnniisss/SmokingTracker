import Foundation
import Combine
import UserNotifications

class SmokingViewModel: ObservableObject {
	@Published var sessions: [SmokingSession] = []
	@Published var currentSession: SmokingSession?
	@Published var dailyLimit: Int = 5
	@Published var weeklyGoal: Int = 20
	@Published var breakInterval: TimeInterval = 3600
	@Published var timeUntilNext: TimeInterval?
	@Published var savedTime: TimeInterval = 0
	@Published var theme: String = "system"
	@Published var challengeActive: Bool = false
	@Published var challengeDuration: TimeInterval = 86400
	@Published var challengeTimeLeft: TimeInterval?
	@Published var packCost: Double = 200.0
	@Published var cigarettesPerPack: Int = 20
	@Published var bossHealth: Int = 100
	@Published var apocalypseCigarettesLeft: Int = 10000
	@Published var avatarState: Int = 0
	@Published var latestMeme: String = "" // Для отображения мема в "Развлекаловке"
	@Published var latestPenalty: String = "" // Для штрафа
	private var timer: Timer?
	private let storageManager = StorageManager()

	private let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .short
		return formatter
	}()

	init() {
		sessions = storageManager.loadSessions()
		requestNotificationPermission()
		updateTimeUntilNext()
		calculateSavedTime()
		updateChallenge()
		updateAvatarState()
	}

	// Управление сессиями
	func startSession(note: String? = nil, mood: Int? = nil) {
		currentSession = SmokingSession(startTime: Date(), note: note, mood: mood)
		startTimer()
		timeUntilNext = nil
	}

	func endSession() {
		timer?.invalidate()
		timer = nil
		if let session = currentSession {
			let completedSession = SmokingSession(id: session.id, startTime: session.startTime, endTime: Date(), note: session.note, mood: session.mood)
			sessions.append(completedSession)
			storageManager.saveSessions(sessions)
			currentSession = nil
			checkDailyLimit()
			startBreakTimer()
			calculateSavedTime()
			updateBossHealth(damage: 5)
			updateApocalypseCigarettes()
			updateAvatarState()
			latestMeme = SmokeMemes.randomMeme() // Обновляем мем
		}
	}

	func deleteSession(_ session: SmokingSession) {
		sessions.removeAll { $0.id == session.id }
		storageManager.saveSessions(sessions)
		calculateSavedTime()
		updateAvatarState()
	}

	// Аналитика
	var totalSessions: Int { sessions.count }

	var averageDuration: TimeInterval? {
		let durations = sessions.compactMap { $0.duration }
		guard !durations.isEmpty else { return nil }
		return durations.reduce(0, +) / Double(durations.count)
	}

	var totalDuration: TimeInterval? {
		let durations = sessions.compactMap { $0.duration }
		guard !durations.isEmpty else { return nil }
		return durations.reduce(0, +)
	}

	var todaySessions: [SmokingSession] {
		return sessions.filter { Calendar.current.isDateInToday($0.startTime) }
	}

	var weekSessions: [SmokingSession] {
		let calendar = Calendar.current
		let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
		return sessions.filter { $0.startTime > weekAgo }
	}

	func sessionsPerDay() -> [Int] {
		let calendar = Calendar.current
		let today = Date()
		var counts = [Int](repeating: 0, count: 7)
		for session in sessions {
			if let daysAgo = calendar.dateComponents([.day], from: session.startTime, to: today).day, daysAgo < 7 {
				counts[6 - daysAgo] += 1
			}
		}
		return counts
	}

	var weeklyProgress: Double {
		let weekCount = weekSessions.count
		return weekCount > weeklyGoal ? 0 : Double(weeklyGoal - weekCount) / Double(weeklyGoal)
	}

	func sessionsByHour() -> [Int] {
		var hours = [Int](repeating: 0, count: 24)
		for session in todaySessions {
			let hour = Calendar.current.component(.hour, from: session.startTime)
			hours[hour] += 1
		}
		return hours
	}

	func dependencyTrend() -> [(date: Date, count: Int)] {
		let calendar = Calendar.current
		let monthAgo = calendar.date(byAdding: .day, value: -30, to: Date())!
		var trend: [Date: Int] = [:]
		for session in sessions where session.startTime > monthAgo {
			let day = calendar.startOfDay(for: session.startTime)
			trend[day, default: 0] += 1
		}
		return trend.map { ($0.key, $0.value) }.sorted { $0.date < $1.date }
	}

	// Сохранённое время
	private func calculateSavedTime() {
		let avgDuration = averageDuration ?? 300
		let expectedSessions = Double(sessions.count) * 1.5
		savedTime = (expectedSessions * avgDuration) - (totalDuration ?? 0)
	}

	// Подсчёт денег
	var savedMoney: Double {
		let totalCigarettes = Double(totalSessions)
		let packsSmoked = totalCigarettes / Double(cigarettesPerPack)
		let expectedPacks = Double(sessions.count) * 1.5 / Double(cigarettesPerPack)
		return (expectedPacks - packsSmoked) * packCost
	}

	// Битва с боссом
	private func updateBossHealth(damage: Int) {
		bossHealth = max(0, bossHealth - damage)
		if bossHealth == 0 {
			notifyBossDefeated()
			bossHealth = 100
		}
	}

	private func notifyBossDefeated() {
		let content = UNMutableNotificationContent()
		content.title = "Никотин повержен!"
		content.body = "Ты нанёс финальный удар! Босс пал, но он вернётся..."
		content.sound = .default
		let request = UNNotificationRequest(identifier: "bossDefeated", content: content, trigger: nil)
		UNUserNotificationCenter.current().add(request)
	}

	// Таймер до апокалипсиса
	private func updateApocalypseCigarettes() {
		apocalypseCigarettesLeft = max(0, apocalypseCigarettesLeft - 1)
		if apocalypseCigarettesLeft == 0 {
			notifyApocalypse()
			apocalypseCigarettesLeft = 10000
		}
	}

	private func notifyApocalypse() {
		let content = UNMutableNotificationContent()
		content.title = "Апокалипсис лёгких!"
		content.body = "Ты выкурил 10000 сигарет. Теперь ты официально дракон!"
		content.sound = .default
		let request = UNNotificationRequest(identifier: "apocalypse", content: content, trigger: nil)
		UNUserNotificationCenter.current().add(request)
	}

	// Курящий аватар
	private func updateAvatarState() {
		let total = totalSessions
		avatarState = min(5, total / 10)
	}

	var avatarDescription: String {
		switch avatarState {
		case 0: return "Чистый и свежий, как утренний бриз!"
		case 1: return "Лёгкий налёт дыма, но ещё держишься."
		case 2: return "Кашель появился, глаза слезятся."
		case 3: return "Дым в волосах, запах везде."
		case 4: return "Прокуренный ветеран, лёгкие в шоке."
		case 5: return "Ты — ходячий дымогенератор!"
		default: return "Состояние неизвестно."
		}
	}

	// Счётчик абсурда
	var absurdStats: String {
		let whales = totalSessions / 50
		let earthTrips = Double(totalSessions) * 0.001
		return "Прокурил \(whales) китов и \(String(format: "%.2f", earthTrips)) раз обогнул Землю дымом!"
	}

	// Режим вызова
	func startChallenge() {
		challengeActive = true
		challengeTimeLeft = challengeDuration
		startChallengeTimer()
	}

	private func startChallengeTimer() {
		timer?.invalidate()
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
			guard let self = self else { return }
			if let time = self.challengeTimeLeft, time > 0 {
				self.challengeTimeLeft = time - 1
			} else {
				self.timer?.invalidate()
				self.challengeActive = false
				self.challengeTimeLeft = nil
				self.notifyChallengeSuccess()
			}
		}
	}

	private func updateChallenge() {
		if challengeActive, let lastSession = sessions.last?.endTime {
			let elapsed = Date().timeIntervalSince(lastSession)
			if elapsed < challengeDuration {
				challengeTimeLeft = challengeDuration - elapsed
				startChallengeTimer()
			}
		}
	}

	private func notifyChallengeSuccess() {
		let content = UNMutableNotificationContent()
		content.title = "Вызов пройден!"
		content.body = "Ты молодец! Выдержал \(formatDuration(challengeDuration)) без курения."
		content.sound = .default
		let request = UNNotificationRequest(identifier: "challengeSuccess", content: content, trigger: nil)
		UNUserNotificationCenter.current().add(request)
	}

	// Форматирование
	func formatDuration(_ duration: TimeInterval) -> String {
		let formatter = DateComponentsFormatter()
		formatter.allowedUnits = [.hour, .minute, .second]
		formatter.unitsStyle = .abbreviated
		return formatter.string(from: duration) ?? "0с"
	}

	func formatDate(_ date: Date) -> String {
		dateFormatter.string(from: date)
	}

	// Таймер перерыва
	private func startBreakTimer() {
		timeUntilNext = breakInterval
		timer?.invalidate()
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
			guard let self = self else { return }
			if let time = self.timeUntilNext, time > 0 {
				self.timeUntilNext = time - 1
			} else {
				self.timer?.invalidate()
				self.timeUntilNext = nil
			}
		}
	}

	private func updateTimeUntilNext() {
		if let lastSession = sessions.last, let endTime = lastSession.endTime {
			let elapsed = Date().timeIntervalSince(endTime)
			if elapsed < breakInterval {
				timeUntilNext = breakInterval - elapsed
				startBreakTimer()
			}
		}
	}

	// Уведомления
	private func requestNotificationPermission() {
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
	}

	private func checkDailyLimit() {
		let todayCount = todaySessions.count
		if todayCount > dailyLimit {
			latestPenalty = FunnyPenalties.randomPenalty() // Сохраняем штраф
			let content = UNMutableNotificationContent()
			content.title = "Лимит превышен!"
			content.body = "Вы покурили \(todayCount) раз при лимите \(dailyLimit). Штраф: \(latestPenalty)"
			content.sound = .default
			let request = UNNotificationRequest(identifier: "limitExceeded", content: content, trigger: nil)
			UNUserNotificationCenter.current().add(request)
		}
	}

	private func startTimer() {
		timer?.invalidate()
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
			self?.objectWillChange.send()
		}
	}
}
