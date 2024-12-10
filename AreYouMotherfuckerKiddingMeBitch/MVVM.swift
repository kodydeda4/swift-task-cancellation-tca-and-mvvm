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
  
  func task() async {
    await withTaskGroup(of: Void.self) { taskGroup in
      taskGroup.addTask {
        for await value in await self.fuckbar.values() {
          await MainActor.run {
            _ = self.values.append(value)
          }
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
      .task { await self.model.task() }
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
