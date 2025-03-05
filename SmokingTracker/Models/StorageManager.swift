import Foundation

class StorageManager {
	private let sessionsKey = "smokingSessions"

	func saveSessions(_ sessions: [SmokingSession]) {
		if let encoded = try? JSONEncoder().encode(sessions) {
			UserDefaults.standard.set(encoded, forKey: sessionsKey)
		}
	}

	func loadSessions() -> [SmokingSession] {
		if let data = UserDefaults.standard.data(forKey: sessionsKey),
		   let decoded = try? JSONDecoder().decode([SmokingSession].self, from: data) {
			return decoded
		}
		return []
	}
}
