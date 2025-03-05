import SwiftUI

struct SessionListView: View {
	@ObservedObject var viewModel: SmokingViewModel

	var body: some View {
		List(viewModel.sessions.reversed()) { session in
			if let duration = session.duration {
				Text("Покур: \(viewModel.formatDuration(duration))")
			}
		}
	}
}
