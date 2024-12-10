import SwiftUI
import ComposableArchitecture

@main
struct Main: App {
  var body: some Scene {
    WindowGroup {
      RootView()
    }
  }
}

struct RootView: View {
  @Bindable var model = AppModel()
  @Bindable var store = StoreOf<AppReducer>(
    initialState: AppReducer.State(),
    reducer: AppReducer.init
  )
  var body: some View {
    NavigationStack {
      List {
        Section {
          NavigationLink("MVVM") {
            AppViewMVVM(model: self.model)
          }
          NavigationLink("TCA") {
            AppViewTCA(store: self.store)
          }
        } header: {
          Text("This is a demo to see how to cancel view.task() in mvvm & tca.")
            .textCase(.none)
        }
      }
      .navigationTitle("Demo")
    }
  }
}

#Preview {
  RootView()
}
