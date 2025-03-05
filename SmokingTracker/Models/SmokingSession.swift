import Foundation

struct SmokingSession: Identifiable, Codable {
	let id: UUID
	let startTime: Date
	let endTime: Date?
	var note: String?
	var mood: Int? // 1-5 (звёзды)

	var duration: TimeInterval? {
		guard let end = endTime else { return nil }
		return end.timeIntervalSince(startTime)
	}

	init(id: UUID = UUID(), startTime: Date, endTime: Date? = nil, note: String? = nil, mood: Int? = nil) {
		self.id = id
		self.startTime = startTime
		self.endTime = endTime
		self.note = note
		self.mood = mood
	}
}
