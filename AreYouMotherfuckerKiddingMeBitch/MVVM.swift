import SwiftUI
import SwiftUINavigation
import Dependencies
import IdentifiedCollections

@Observable
@MainActor
final class AppModel {
  var destination: Destination? { didSet { self.bind() } }
  
  @CasePathable
  enum Destination {
    case sheet(SheetModel)
  }
  
  func buttonTapped() {
    self.destination = .sheet(SheetModel())
  }
  
  private func bind() {
    switch destination {
      
    case let .sheet(model):
      model.dismiss = { [weak self] in
        self?.destination = .none
      }
    case .none:
      break
    }
  }
}

struct AppViewMVVM: View {
  @Bindable var model: AppModel
  
  var body: some View {
    Button("Tap") {
      self.model.buttonTapped()
    }
    .navigationTitle("MVVM")
    .sheet(item: $model.destination.sheet) { model in
      SheetViewMVVM(model: model)
    }
  }
}

// MARK: - Sheet

@Observable
@MainActor
final class SheetModel: Identifiable {
  let id = UUID()
  var values: IdentifiedArrayOf<FuckbarClient.Model> = []
  var dismiss: () -> Void = unimplemented("SheetModel.dismiss")
  
  @ObservationIgnored
  @Dependency(\.fuckbar) var fuckbar
  
  func cancelButtonTapped() {
    self.dismiss()
  }
  
  var task: Task<Void, Never> {
    Task.detached {
      for await value in await self.fuckbar.values() {
        _ = await MainActor.run {
          self.values.append(value)
        }
      }
    }
  }
}

struct SheetViewMVVM: View {
  @Bindable var model = SheetModel()
  
  var body: some View {
    NavigationStack {
      List {
        ForEach(self.model.values) { value in
          Text(value.rawValue.description)
        }
      }
      .listStyle(.plain)
      .navigationTitle("Sheet")
      .task { await self.model.task.cancellableValue }
      .toolbar {
        Button("Cancel") {
          self.model.cancelButtonTapped()
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    AppViewMVVM(model: AppModel())
  }
}
