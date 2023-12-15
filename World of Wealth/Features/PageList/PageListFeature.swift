//
//  GetStartedFeature.swift
//  World of Wealth
//
//  Created by Brett Rosen on 11/23/23.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct PageListFeature {
    struct State: Equatable {
        var pageIDs: IdentifiedArrayOf<Page.ID>

        var selectedPageState: PageFeature.State?
    }

    enum Action: Equatable, FeatureAction {
        enum ViewAction: Equatable {
            case updatedSelectedPageID(Page.ID?)
        }

        enum ReducerAction: Equatable {

        }

        enum DelegateAction: Equatable {

        }

        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
        case page(PageFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                switch action {
                case let .updatedSelectedPageID(pageID):
                    if let pageID {
                        state.selectedPageState = .init(pageID: pageID)
                    } else {
                        state.selectedPageState = nil
                    }
                    return .none
                }
            case let .reducer(action):
                switch action {

                }
            case .delegate:
                return .none
            case .page:
                return .none
            }
        }
        .ifLet(\.selectedPageState, action: \.page) {
            PageFeature()
        }
    }
}
