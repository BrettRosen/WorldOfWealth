//
//  World_of_WealthApp.swift
//  World of Wealth
//
//  Created by Brett Rosen on 11/23/23.
//

import ComposableArchitecture
import Firebase
import SwiftUI

/*

 Top Level Tabs

 1. Getting Started
    - Addons
    - Gearing
 2. Gold Making
    - Transmog Farming
        - List by expansion
            - List of dungeons/raids/open world/etc.
                - Location, Route, GPH, Chase Items, etc
    - Flipping
    - Sniping
    - Etc...
3. Community?
    - Maybe community can add guides or something

 */

@Reducer
struct AppFeature {
    enum Tab: String, Equatable, CaseIterable, Identifiable {
        case get_started
        case make_gold
        case community

        var id: Self { self }

        var imageName: String {
            switch self {
            case .get_started: return "list.bullet.rectangle.portrait"
            case .make_gold: return "dollarsign.circle"
            case .community: return "person.2"
            }
        }
    }

    struct State: Equatable {
        var tab: Tab = .get_started
        var getStartedState: GetStartedFeature.State = .init()
    }

    enum Action: Equatable, FeatureAction {
        enum ViewAction: Equatable {
            case didUpdateTab(Tab)
        }

        enum ReducerAction: Equatable {

        }

        enum DelegateAction: Equatable {

        }

        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
        case getStarted(GetStartedFeature.Action)
    }

    var body: some Reducer<State, Action> {
        CombineReducers {
            Reduce { state, action in
                switch action {
                case let .view(action):
                    switch action {
                    case let .didUpdateTab(tab):
                        state.tab = tab
                        return .none
                    }
                case let .reducer(action):
                    switch action {

                    }
                case .delegate:
                    return .none
                case .getStarted:
                    return .none
                }
            }

            Scope(state: \.getStartedState, action: \.getStarted) {
                GetStartedFeature()
            }
        }
    }
}

extension AppFeature {
    struct ViewState: Equatable {
        var tab: Tab
        var settingsMenuIsVisible: Bool
        init(_ state: State) {
            tab = state.tab
            settingsMenuIsVisible = state.getStartedState.selectedElement == nil
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct World_of_WealthApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    let store: StoreOf<AppFeature> = Store(initialState: .init()) {
        AppFeature()
    }

    var body: some Scene {
        WindowGroup {
            WithViewStore(store, observe: AppFeature.ViewState.init, send: AppFeature.Action.view) { viewStore in
                VStack(spacing: 0) {
                    ZStack(alignment: .topTrailing) {
                        TabView(selection: viewStore.binding(
                            get: \.tab,
                            send: AppFeature.Action.ViewAction.didUpdateTab
                        ).animation()) {
                            ForEach(AppFeature.Tab.allCases) { tab in
                                switch tab {
                                case .get_started:
                                    GetStartedView(store: store.scope(state: \.getStartedState, action: AppFeature.Action.getStarted))
                                case .make_gold:
                                    MakeGoldView()
                                case .community:
                                    Text(tab.rawValue.replacingOccurrences(of: "_", with: " ").uppercased())
                                }
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))

                        Button(action: {

                        }) {
                            Image(systemName: "line.3.horizontal.decrease")
                                .fontWeight(.medium)
                                .padding(8)
                                .padding(.vertical, 4)
                                .background {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Color.matching)
                                        .shadow(color: .primary.opacity(0.1), radius: 0, x: -1, y: -1)
                                        .shadow(color: .primary.opacity(0.1), radius: 0, x: 1, y: 1)
                                }
                                .padding(16)
                                .opacity(viewStore.settingsMenuIsVisible ? 1 : 0)
                        }
                        .buttonStyle(.plain)
                    }

                    HStack {
                        ForEach(AppFeature.Tab.allCases) { tab in
                            Spacer()
                            let isSelected = tab == viewStore.tab
                            Button(action: {
                                viewStore.send(.didUpdateTab(tab), animation: .default)
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: isSelected ? (tab.imageName + ".fill") : tab.imageName)
                                        .contentTransition(isSelected ? .symbolEffect(.replace) : .identity)
                                        .font(.title3)
                                    Text(tab.rawValue.replacingOccurrences(of: "_", with: " ").uppercased())
                                        .fontWidth(.condensed)
                                        .font(.caption2)
                                }
                                .fontWeight(isSelected ? .semibold : .regular)
                                .foregroundStyle(isSelected ? .primary : .secondary)
                                .sensoryFeedback(.impact(flexibility: .soft), trigger: isSelected)
                                .frame(height: 40)
                            }
                            .buttonStyle(.plain)
                            Spacer()
                        }
                    }
                    .padding(.vertical, 4)
                    .padding(.top, 12)
                }
            }
        }
    }
}

struct Page: Equatable {
    var id: String
    var contentBlock: [ContentBlock]
}

enum ContentBlock: Equatable {
    case title(String)
    case paragraph(String)
    case image(String) // URL
}

