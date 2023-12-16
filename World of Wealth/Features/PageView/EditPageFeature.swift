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
    @Dependency(\.pageClient) var pageClient

    struct State: Equatable {
        var page: Page

        // Before edits were made, useful for reverting
        var initialPage: Page

        init(page: Page) {
            self.page = page
            self.initialPage = page
        }
    }

    enum Action: FeatureAction {
        enum ViewAction: Equatable {
            case didTapAddContent(ContentBlock)
            case didTapDelete(IndexSet)
            case didMove(from: IndexSet, to: Int)
            case didTapCompleteEdit
            case didTapCancel
        }

        enum ReducerAction {
            case updatePageEffect(Result<Success, Error>)
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
                case let .didTapDelete(indexSet):
                    state.page.content.remove(atOffsets: indexSet)
                    return .none
                case let .didMove(from, to):
                    state.page.content.move(fromOffsets: from, toOffset: to)
                    return .none
                case .didTapCompleteEdit:
                    return .run { [state] send in
                        await send(.reducer(.updatePageEffect(
                            Result { try await pageClient.edit(state.page) }
                        )))
                    }
                case .didTapCancel:
                    return .send(.delegate(.didCancel(initialPage: state.initialPage)))
                }
            case let .reducer(action):
                switch action {
                case .updatePageEffect(.success):
                    return .send(.delegate(.didComplete(newPage: state.page)))
                case .updatePageEffect(.failure):
                    return .none
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

@Reducer
struct ContentBlockEditFeature {
    typealias State = ContentBlock

    enum Action: Equatable, FeatureAction {
        enum ViewAction: Equatable {
            case updateContentBlock(String)
        }

        enum ReducerAction: Equatable {

        }

        enum DelegateAction: Equatable {

        }

        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }

    var body: some Reducer<ContentBlock, Action> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                switch action {
                case let .updateContentBlock(value):
                    switch state {
                    case let .title(title):
                        state = .title(.init(id: title.id, value: value))
                    case let .paragraph(paragraph):
                        state = .paragraph(.init(id: paragraph.id, value: value))
                    default:
                        break
                    }
                    return .none
                }
            case let .reducer(action):
                switch action {

                }
            case .delegate:
                return .none
            }
        }
    }
}
