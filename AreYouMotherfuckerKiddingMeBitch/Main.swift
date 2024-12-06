import SwiftUI

@main
struct AreYouMotherfuckerKiddingMeBitchApp: App {
  var body: some Scene {
    WindowGroup {
      RootView()
    }
  }
}

struct RootView: View {
  var body: some View {
    NavigationStack {
      List {
        Section {
          NavigationLink("TCA") {
            AppViewTCA()
          }
          NavigationLink("MVVM") {
            AppViewMVVM()
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
