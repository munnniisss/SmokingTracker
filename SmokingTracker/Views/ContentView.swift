import SwiftUI

struct ContentView: View {
	@StateObject private var viewModel = SmokingViewModel()

	var body: some View {
		TabView {
			SessionView(viewModel: viewModel)
				.tabItem {
					Label("Сессия", systemImage: "clock")
				}

			AnalyticsView(viewModel: viewModel)
				.tabItem {
					Label("Аналитика", systemImage: "chart.bar")
				}

			HistoryView(viewModel: viewModel)
				.tabItem {
					Label("История", systemImage: "list.bullet")
				}

			SettingsView(viewModel: viewModel)
				.tabItem {
					Label("Настройки", systemImage: "gear")
				}

			FunView(viewModel: viewModel)
				.tabItem {
					Label("Развлекаловка", systemImage: "face.smiling")
				}
		}
		.preferredColorScheme(themeColorScheme)
	}

	private var themeColorScheme: ColorScheme? {
		switch viewModel.theme {
		case "light": return .light
		case "dark": return .dark
		default: return nil
		}
	}
}
