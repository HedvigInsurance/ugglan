import Foundation

final class AnyTask: Equatable {
    static func == (lhs: AnyTask, rhs: AnyTask) -> Bool {
        lhs.taskHashValue == rhs.taskHashValue
    }

    /// Call this cancellation block to cancel the task manually.
    let cancel: () -> Void
    /// Checks whether the task is cancelled.
    var isCancelled: Bool { isCancelledBlock() }

    private let isCancelledBlock: () -> Bool

    deinit {
        // On deinit, if the task is not cancelled then cancel it
        if !isCancelled { cancel() }
    }

    var taskHashValue: Int

    /// Constructs an AnyTask from the provided Task.
    /// The provided task is held strongly until AnyTask is
    /// deinitted.
    /// - Parameter task: The task to construct with.
    init<S, E>(
        _ task: Task<S, E>
    ) {
        taskHashValue = task.hashValue
        cancel = task.cancel
        isCancelledBlock = { task.isCancelled }
    }
}

extension Task {
    var eraseToAnyTask: AnyTask { .init(self) }
}
