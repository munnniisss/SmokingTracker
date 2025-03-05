import SwiftUI

struct FunView: View {
	@ObservedObject var viewModel: SmokingViewModel

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 15) {
				Text("Развлекаловка")
					.font(.title2)
					.bold()

				Text("Гороскоп: \(SmokeHoroscope.dailyPrediction(sessionCount: viewModel.todaySessions.count))")
					.font(.subheadline)
					.padding(.bottom, 10)

				Text("Последний мем:")
					.font(.headline)
				Text(viewModel.latestMeme.isEmpty ? "Покури, чтобы получить мем!" : viewModel.latestMeme)
					.font(.subheadline)
					.italic()
					.multilineTextAlignment(.center)
					.padding(.bottom, 10)

				Text("Босс 'Никотин': \(viewModel.bossHealth)%")
					.font(.headline)
				ProgressView(value: Double(viewModel.bossHealth) / 100.0)
					.progressViewStyle(.linear)
					.tint(.red)

				Text("До апокалипсиса лёгких: \(viewModel.apocalypseCigarettesLeft) сигарет")
					.font(.headline)
					.padding(.top, 10)

				Text("Аватар: \(viewModel.avatarDescription)")
					.font(.subheadline)
					.padding(.top, 10)

				Text(viewModel.absurdStats)
					.font(.subheadline)
					.foregroundColor(.gray)
					.padding(.top, 10)

				if !viewModel.latestPenalty.isEmpty {
					Text("Последний штраф: \(viewModel.latestPenalty)")
						.font(.subheadline)
						.foregroundColor(.red)
						.padding(.top, 10)
				}
			}
			.padding()
		}
	}
}
