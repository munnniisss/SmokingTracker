import SwiftUI

struct SessionView: View {
	@ObservedObject var viewModel: SmokingViewModel
	@State private var note: String = ""
	@State private var mood: Int = 3
	@State private var showSmoke: Bool = false

	var body: some View {
		VStack(spacing: 20) {
			if let session = viewModel.currentSession {
				Text("Идёт покур")
					.font(.title2)
				Text("Начало: \(viewModel.formatDate(session.startTime))")
					.font(.subheadline)
				Text("Время: \(currentDuration(session))")
					.font(.headline)
				Button("Закончить покур") {
					viewModel.endSession()
				}
				.buttonStyle(.borderedProminent)
				.tint(.red)
			} else {
				Text("Нет активной сессии")
					.font(.title2)
				TextField("Заметка (необязательно)", text: $note)
					.textFieldStyle(.roundedBorder)
				Picker("Настроение", selection: $mood) {
					ForEach(1...5, id: \.self) { i in
						Text("\(i) ★").tag(i)
					}
				}
				.pickerStyle(.segmented)

				Button("Начать покур") {
					viewModel.startSession(note: note.isEmpty ? nil : note, mood: mood)
					note = ""
					withAnimation(.easeOut(duration: 2)) {
						showSmoke = true
					}
					DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
						showSmoke = false
					}
				}
				.buttonStyle(.borderedProminent)
				.tint(.green)
				.overlay(
					ZStack {
						if showSmoke {
							SmokeAnimation()
								.frame(width: 100, height: 100)
								.offset(y: -50)
						}
					}
				)

				if let time = viewModel.timeUntilNext {
					Text("До следующего: \(viewModel.formatDuration(time))")
						.font(.subheadline)
						.foregroundColor(.gray)
				} else {
					Text(MotivationalQuotes.randomQuote())
						.font(.subheadline)
						.italic()
						.multilineTextAlignment(.center)
				}
			}

			if viewModel.challengeActive, let time = viewModel.challengeTimeLeft {
				Text("Вызов: \(viewModel.formatDuration(time))")
					.font(.subheadline)
					.foregroundColor(.blue)
			}
		}
		.padding()
	}

	private func currentDuration(_ session: SmokingSession) -> String {
		if let duration = session.duration {
			return viewModel.formatDuration(duration)
		}
		return viewModel.formatDuration(Date().timeIntervalSince(session.startTime))
	}
}

struct SmokeAnimation: View {
	@State private var opacity: Double = 0.5

	var body: some View {
		ZStack {
			ForEach(0..<5) { i in
				Circle()
					.frame(width: CGFloat(i * 20), height: CGFloat(i * 20))
					.foregroundColor(Color.gray.opacity(opacity))
					.offset(y: -CGFloat(i * 10))
					.animation(
						Animation.easeOut(duration: 2)
							.repeatForever(autoreverses: false)
							.delay(Double(i) * 0.2),
						value: opacity
					)
			}
		}
		.onAppear {
			opacity = 0
		}
	}
}
