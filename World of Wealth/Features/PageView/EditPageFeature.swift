//
//  EditPageFeature.swift
//  World of Wealth
//
//  Created by Brett Rosen on 12/14/23.
//

import ComposableArchitecture
import Foundation

@Reducer
struct EditPageFeature {
    struct State: Equatable {
        var page: Page

        // Before edits were made, useful for reverting
        var initialPage: Page

        init(page: Page) {
            self.page = page
            self.initialPage = page
        }
    }

    enum Action: Equatable, FeatureAction {
        enum ViewAction: Equatable {
            case didTapAddContent(ContentBlock)
            case didTapCompleteEdit
            case didTapCancel
        }

        enum ReducerAction: Equatable {

        }

        enum DelegateAction: Equatable {
            case didComplete(newPage: Page)
            case didCancel(initialPage: Page)
        }

        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
        case editingContentBlock(IdentifiedActionOf<ContentBlockEditFeature>)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                switch action {
                case let .didTapAddContent(content):
                    state.page.content.append(content)
                    return .none
                case .didTapCompleteEdit:
                    return .send(.delegate(.didComplete(newPage: state.page)))
                case .didTapCancel:
                    return .send(.delegate(.didCancel(initialPage: state.initialPage)))
                }
            case let .reducer(action):
                switch action {

                }
            case .delegate:
                return .none
            case .editingContentBlock:
                return .none
            }
        }
        .forEach(\.page.content, action: \.editingContentBlock) {
            ContentBlockEditFeature()
        }
    }
}
