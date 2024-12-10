import SwiftUI
import ComposableArchitecture

@Reducer
struct AppReducer {
  @ObservableState
  struct State: Equatable {
    @Presents var destination: Destination.State?
  }
  enum Action {
    case buttonTapped
    case destination(PresentationAction<Destination.Action>)
  }
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        
      case .buttonTapped:
        state.destination = .sheet(SheetReducer.State())
        return .none
        
      case .destination:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
  }
  
  @Reducer(state: .equatable)
  public enum Destination {
    case sheet(SheetReducer)
  }
}

struct AppViewTCA: View {
  @Bindable var store: StoreOf<AppReducer>
  
  var body: some View {
    Button("Tap") {
      self.store.send(.buttonTapped)
    }
    .navigationTitle("TCA")
    .sheet(item: $store.scope(
      state: \.destination?.sheet,
      action: \.destination.sheet
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
    var values: IdentifiedArrayOf<FuckbarClient.Model> = []
  }
  enum Action {
    case task
    case fuckbarResponse(FuckbarClient.Model)
    case cancelButtonTapped
  }
  
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.fuckbar) var fuckbar
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        
      case let .fuckbarResponse(value):
        state.values.append(value)
        return .none
        
      case .cancelButtonTapped:
        return .run { _ in await self.dismiss() }
        
      case .task:
        return .run { send in
          for await value in self.fuckbar.values() {
            await send(.fuckbarResponse(value))
          }
        }
      }
    }
  }
}

struct SheetViewTCA: View {
  @Bindable var store: StoreOf<SheetReducer>
  
  var body: some View {
    NavigationStack {
      List {
        ForEach(self.store.values) { value in
          Text(value.rawValue.description)
        }
      }
      .listStyle(.plain)
      .navigationTitle("Sheet")
      .task { await self.store.send(.task).finish() }
      .toolbar {
        Button("Cancel") {
          self.store.send(.cancelButtonTapped)
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    AppViewTCA(store: StoreOf<AppReducer>(
      initialState: AppReducer.State()
    ) {
      AppReducer()
    })
  }
}
