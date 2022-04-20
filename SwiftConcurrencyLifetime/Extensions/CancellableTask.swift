import Combine

final class CancellableTask<Success: Sendable, Failure: Error>: Sendable, Cancellable {
    let task: Task<Success, Failure>

    init(_ task: Task<Success, Failure>) {
        self.task = task
    }

    deinit {
        cancel()
    }

    func cancel() {
        task.cancel()
    }
}

extension CancellableTask {
    private func asAnyCancellable() -> AnyCancellable {
        .init { self.cancel() }
    }

    func store(in cancellables: inout Set<AnyCancellable>) {
        asAnyCancellable().store(in: &cancellables)
    }
}

extension Task {
    func asCancellableTask() -> CancellableTask<Success, Failure> {
        CancellableTask(self)
    }

    func store(in cancellables: inout Set<AnyCancellable>) {
        asCancellableTask().store(in: &cancellables)
    }
}
