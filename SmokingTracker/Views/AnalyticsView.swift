import SwiftUI
import Charts

struct AnalyticsView: View {
	@ObservedObject var viewModel: SmokingViewModel

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 15) {
				Text("Аналитика")
					.font(.title2)
					.bold()

				if viewModel.sessions.isEmpty {
					Text("Нет данных")
				} else {
					Text("Всего покуров: \(viewModel.totalSessions)")
					Text("Среднее время: \(viewModel.averageDuration.map(viewModel.formatDuration) ?? "0с")")
					Text("Общее время: \(viewModel.totalDuration.map(viewModel.formatDuration) ?? "0с")")
					Text("Сегодня: \(viewModel.todaySessions.count)")
					Text("Сохранённое время: \(viewModel.formatDuration(viewModel.savedTime))")
					Text("Сэкономленные деньги: \(String(format: "%.2f руб", viewModel.savedMoney))")
					Text(viewModel.absurdStats)
						.font(.subheadline)
						.foregroundColor(.gray)

					Text("Прогресс недели: \(viewModel.weekSessions.count)/\(viewModel.weeklyGoal)")
						.font(.headline)
						.padding(.top, 10)
					ProgressView(value: viewModel.weeklyProgress)
						.progressViewStyle(.linear)

					Text("Здоровье босса 'Никотин': \(viewModel.bossHealth)%")
						.font(.headline)
						.padding(.top, 10)
					ProgressView(value: Double(viewModel.bossHealth) / 100.0)
						.progressViewStyle(.linear)
						.tint(.red)

					Text("До апокалипсиса лёгких: \(viewModel.apocalypseCigarettesLeft) сигарет")
						.font(.headline)
						.padding(.top, 10)

					Text("Состояние аватара: \(viewModel.avatarDescription)")
						.font(.subheadline)
						.padding(.top, 10)

					Text("Покуры по часам дня")
						.font(.headline)
						.padding(.top, 10)
					Chart {
						ForEach(Array(viewModel.sessionsByHour().enumerated()), id: \.offset) { index, count in
							BarMark(x: .value("Час", index), y: .value("Покуры", count))
						}
					}
					.frame(height: 200)

					Text("Тренд зависимости (30 дней)")
						.font(.headline)
						.padding(.top, 10)
					Chart {
						ForEach(viewModel.dependencyTrend(), id: \.date) { trend in
							LineMark(
								x: .value("Дата", trend.date, unit: .day),
								y: .value("Покуры", trend.count)
							)
						}
					}
					.frame(height: 200)
				}
			}
			.padding()
		}
	}
}
