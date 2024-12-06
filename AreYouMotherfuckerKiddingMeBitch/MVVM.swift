import SwiftUI
import Dependencies

@Observable
@MainActor
final class AppModel {
  var sheet: SheetModel? { didSet { self.bind() }}
  
  func buttonTapped() {
    self.sheet = SheetModel()
  }
  
  private func bind() {
    self.sheet?.dismiss = { [weak self] in
      self?.sheet = nil
    }
  }
}

struct AppViewMVVM: View {
  @Bindable var model = AppModel()
  
  var body: some View {
    Button("Tap") {
      self.model.buttonTapped()
    }
    .navigationTitle("MVVM")
    .sheet(item: $model.sheet) { model in
      SheetViewMVVM(model: model)
    }
  }
}

// MARK: - Sheet

@Observable
@MainActor
final class SheetModel: Identifiable {
  let id = UUID()
  var dismiss: () -> Void = unimplemented("SheetModel.dismiss")
  
  @ObservationIgnored
  @Dependency(\.fuckbar) var fuckbar
  
  func task() async {
    await Task.detached {
      for await _ in await self.fuckbar.values() {}
    }
    .cancellableValue
  }
  
  func cancelButtonTapped() {
    self.dismiss()
  }
}

struct SheetViewMVVM: View {
  @Bindable var model = SheetModel()
  
  var body: some View {
    NavigationStack {
      Text("Sheet")
    }
    .task { await self.model.task() }
    .toolbar {
      Button("Cancel") {
        self.model.cancelButtonTapped()
      }
    }
  }
}

#Preview {
  NavigationStack {
    AppViewMVVM()
  }
}
