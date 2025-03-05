import SwiftUI

struct SettingsView: View {
	@ObservedObject var viewModel: SmokingViewModel
	@FocusState private var isPackCostFocused: Bool
	@State private var packCostText: String = "" // Временное текстовое значение для ввода

	var body: some View {
		Form {
			Section(header: Text("Дневной лимит")) {
				Stepper("Лимит: \(viewModel.dailyLimit) покуров", value: $viewModel.dailyLimit, in: 1...20)
			}

			Section(header: Text("Цель на неделю")) {
				Stepper("Цель: \(viewModel.weeklyGoal) покуров", value: $viewModel.weeklyGoal, in: 1...50)
			}

			Section(header: Text("Перерыв между покурами")) {
				Picker("Интервал", selection: $viewModel.breakInterval) {
					Text("30 мин").tag(TimeInterval(1800))
					Text("1 час").tag(TimeInterval(3600))
					Text("2 часа").tag(TimeInterval(7200))
				}
			}

			Section(header: Text("Тема")) {
				Picker("Тема приложения", selection: $viewModel.theme) {
					Text("Системная").tag("system")
					Text("Светлая").tag("light")
					Text("Тёмная").tag("dark")
				}
				.pickerStyle(.segmented)
			}

			Section(header: Text("Вызов")) {
				Picker("Длительность вызова", selection: $viewModel.challengeDuration) {
					Text("12 часов").tag(TimeInterval(43200))
					Text("24 часа").tag(TimeInterval(86400))
					Text("48 часов").tag(TimeInterval(172800))
				}
				Button(viewModel.challengeActive ? "Вызов активен" : "Начать вызов") {
					if !viewModel.challengeActive {
						viewModel.startChallenge()
					}
				}
				.disabled(viewModel.challengeActive)
			}

			Section(header: Text("Финансы")) {
				HStack {
					TextField("Стоимость пачки (руб)", text: $packCostText)
						.keyboardType(.decimalPad)
						.focused($isPackCostFocused)
						.onAppear {
							packCostText = String(format: "%.2f", viewModel.packCost) // Начальное значение
						}
					Button("Готово") {
						if let newCost = Double(packCostText.replacingOccurrences(of: ",", with: ".")) {
							viewModel.packCost = newCost // Сохраняем введённое значение
						}
						isPackCostFocused = false // Закрываем клавиатуру
					}
					.foregroundColor(.blue)
				}
				Stepper("Сигарет в пачке: \(viewModel.cigarettesPerPack)", value: $viewModel.cigarettesPerPack, in: 1...30)
			}

			Section(header: Text("Совет дня")) {
				Text(QuitTips.randomTip())
			}
		}
		.navigationTitle("Настройки")
	}
}
