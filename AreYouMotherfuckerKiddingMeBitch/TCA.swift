import SwiftUI
import ComposableArchitecture

@Reducer
struct AppReducer {
  @ObservableState
  struct State: Equatable {
    @Presents var sheet: SheetReducer.State?
  }
  enum Action {
    case buttonTapped
    case sheet(PresentationAction<SheetReducer.Action>)
  }
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        
      case .buttonTapped:
        state.sheet = SheetReducer.State()
        return .none
        
      case .sheet:
        return .none
      }
    }
    .ifLet(\.$sheet, action: \.sheet) {
      SheetReducer()
    }
  }
}

struct AppViewTCA: View {
  @Bindable var store = StoreOf<AppReducer>(
    initialState: AppReducer.State()
  ) {
    AppReducer()
  }
  
  var body: some View {
    Button("Tap") {
      self.store.send(.buttonTapped)
    }
    .navigationTitle("TCA")
    .sheet(item: $store.scope(
      state: \.sheet,
      action: \.sheet
    )) { store in
      SheetViewTCA(store: store)
    }
  }
}

// MARK: - Sheet

@Reducer
struct SheetReducer {
  @ObservableState
  struct State: Equatable {
    //...
  }
  enum Action {
    case task
    case cancelButtonTapped
  }
  
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.fuckbar) var fuckbar
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        
      case .cancelButtonTapped:
        return .run { _ in await self.dismiss() }
        
      case .task:
        return .run { _ in
          for await _ in await self.fuckbar.values() {}
        }
      }
    }
  }
}

struct SheetViewTCA: View {
  @Bindable var store: StoreOf<SheetReducer>
  
  var body: some View {
    NavigationStack {
      Text("Sheet")
    }
    .task { await self.store.send(.task).finish() }
    .toolbar {
      Button("Cancel") {
        self.store.send(.cancelButtonTapped)
      }
    }
  }
}

#Preview {
  NavigationStack {
    AppViewTCA()
  }
}
