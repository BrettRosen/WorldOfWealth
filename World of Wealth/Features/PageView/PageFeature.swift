//
//  PageFeature.swift
//  World of Wealth
//
//  Created by Brett Rosen on 11/30/23.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct PageFeature {
    @Dependency(\.pageClient) var pageClient

    @CasePathable
    @dynamicMemberLookup
    enum PageState: Equatable {
        case isLoading
        case error
        case page(Page)
        case editing(EditPageFeature.State)

        var page: Page? {
            switch self {
            case let .page(page): return page
            case let .editing(state): return state.page
            default: return .none
            }
        }
    }

    struct State: Equatable {
        var pageID: Page.ID
        var pageState: PageState = .isLoading
    }

    enum Action: Equatable, FeatureAction {
        enum ViewAction: Equatable {
            case didAppear
            case didTapEdit
        }

        enum ReducerAction: Equatable {
            case loadPageResult(TaskResult<Page>)
        }

        enum DelegateAction: Equatable {

        }

        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
        case editPage(EditPageFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                switch action {
                case .didAppear:
                    guard case .isLoading = state.pageState else { return .none }
                    return .run { [state] send in
                        await send(.reducer(.loadPageResult( TaskResult {
                            try await pageClient.load(pageID: state.pageID)
                        })))
                    }
                case .didTapEdit:
                    if case let .editing(editingState) = state.pageState {
                        state.pageState = .page(editingState.page)
                    } else if case let .page(page) = state.pageState {
                        state.pageState = .editing(.init(page: page))
                    }
                    return .none
                }
            case let .reducer(action):
                switch action {
                case let .loadPageResult(.success(page)):
                    state.pageState = .page(page)
                    return .none
                case .loadPageResult(.failure):
                    state.pageState = .error
                    return .none
                }
            case .delegate:
                return .none
            case let .editPage(.delegate(.didComplete(newPage))):
                state.pageState = .page(newPage)
                return .none
            case let .editPage(.delegate(.didCancel(initialPage))):
                state.pageState = .page(initialPage)
                return .none
            case .editPage:
                return .none
            }
        }

        Scope(state: \.pageState, action: .self) {
            Scope(
                state: /PageState.editing,
                action: /Action.editPage
            ) {
                EditPageFeature()
            }
        }
    }
}
