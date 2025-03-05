import SwiftUI

struct HistoryView: View {
	@ObservedObject var viewModel: SmokingViewModel

	var body: some View {
		List {
			ForEach(viewModel.sessions.reversed()) { session in
				if let duration = session.duration {
					HStack {
						VStack(alignment: .leading) {
							Text("Начало: \(viewModel.formatDate(session.startTime))")
							Text("Длительность: \(viewModel.formatDuration(duration))")
							if let note = session.note {
								Text("Заметка: \(note)")
									.font(.caption)
									.foregroundColor(.gray)
							}
							if let mood = session.mood {
								Text("Настроение: \(String(repeating: "★", count: mood))")
									.font(.caption)
									.foregroundColor(.yellow)
							}
						}
						Spacer()
						Button(action: {
							viewModel.deleteSession(session)
						}) {
							Image(systemName: "trash")
								.foregroundColor(.red)
						}
					}
				}
			}
		}
		.navigationTitle("История")
	}
}
