internal import Combine
import Foundation

extension Publisher {
    /// Emits `(previous, current)` pairs
    func pairwise() -> AnyPublisher<(Output, Output), Failure> {
        self
            .zip(self.dropFirst())
            .eraseToAnyPublisher()
    }

    /// Emits only when an Equatable optional property changes (non-nil → non-nil)
    func changes<Value: Equatable>(
        of keyPath: KeyPath<Output, Value?>
    ) -> AnyPublisher<(old: Value, new: Value), Failure> {
        self
            .pairwise()
            .compactMap { prev, cur in
                guard
                    let old = prev[keyPath: keyPath],
                    let new = cur[keyPath: keyPath],
                    old != new
                else { return nil }
                return (old, new)
            }
            .eraseToAnyPublisher()
    }
}
