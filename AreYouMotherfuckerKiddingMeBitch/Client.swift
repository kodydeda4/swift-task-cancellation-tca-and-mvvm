import Dependencies
import DependenciesMacros
import SwiftUI

@DependencyClient
struct FuckbarClient: Sendable {
  var values: @Sendable () -> AsyncStream<Model> = { .finished }
  
  struct Model: Identifiable, Sendable, Equatable {
    let id: UUID
    let rawValue: Int
  }
}

extension FuckbarClient: DependencyKey {
  static var liveValue = Self {
    AsyncStream { continuation in
      let task = Task {
        while !Task.isCancelled {
          // You must check !Task.isCancelled
          // to short-circuit work
          let value = Model(
            id: UUID(),
            rawValue: Int.random(in: 1..<100)
          )
          continuation.yield(value)
          print("Client \(Date()) \(value)")
          try? await Task.sleep(for: .seconds(1))
        }
      }
      continuation.onTermination = { _ in
        print("canceled stream")
        task.cancel()
      }
    }
  }
}

extension DependencyValues {
  var fuckbar: FuckbarClient {
    get { self[FuckbarClient.self] }
    set { self[FuckbarClient.self] = newValue }
  }
}
