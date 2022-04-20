import Combine
import SwiftUI

@MainActor
class ExampleViewModel: ObservableObject {
    @Published private(set) var screenOrientationFromPublisher: UIDeviceOrientation = .portrait
    @Published private(set) var screenOrientationFromSequence: UIDeviceOrientation = .portrait

    private var cancellables = Set<AnyCancellable>()

    init() {
        UIDevice.current.isBatteryMonitoringEnabled = true

        screenOrientationPublisher()
            .sink { [weak self] orientation in
                print("New publisher value:", orientation)
                self?.screenOrientationFromPublisher = orientation
            }
            .store(in: &cancellables)

        Task { [weak self] in
            guard let screenOrientationSequence = await self?.screenOrientationSequence() else {
                return
            }

            for await orientation in screenOrientationSequence {
                print("New sequence value:", orientation)
                self?.screenOrientationFromSequence = orientation
            }
        }
    }

    deinit {
        print("Bye-bye, \(ExampleViewModel.self)!")
    }

    private func screenOrientationPublisher() -> AnyPublisher<UIDeviceOrientation, Never> {
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .map { _ in UIDevice.current.orientation }
            .eraseToAnyPublisher()
    }

    private func screenOrientationSequence() async -> AsyncMapSequence<NotificationCenter.Notifications, UIDeviceOrientation> {
        NotificationCenter.default.notifications(named: UIDevice.orientationDidChangeNotification)
            .map { _ in UIDevice.current.orientation }
    }
}

struct ExampleView: View {
    @StateObject private var viewModel: ExampleViewModel
    @Environment(\.dismiss) var dismiss

    init() {
        _viewModel = .init(wrappedValue: ExampleViewModel())
    }

    var body: some View {
        VStack {
            Text("Screen Orientation (Publisher): \(viewModel.screenOrientationFromPublisher.description)")
            Text("Screen Orientation (Sequence): \(viewModel.screenOrientationFromSequence.description)")

            Button("Dismiss") {
                dismiss()
            }
            .padding()
        }
        .navigationTitle(Text("ExampleView"))
    }
}
