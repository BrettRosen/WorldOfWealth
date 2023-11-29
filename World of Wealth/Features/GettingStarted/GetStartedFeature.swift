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
struct GetStartedFeature {
    struct State: Equatable {
        var selectedElement: GetStartedElement?
    }

    enum Action: Equatable, FeatureAction {
        enum ViewAction: Equatable {
            case updateSelectedElement(GetStartedElement?)
        }

        enum ReducerAction: Equatable {

        }

        enum DelegateAction: Equatable {

        }

        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                switch action {
                case let .updateSelectedElement(element):
                    state.selectedElement = element
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

enum GetStartedElement: String, CaseIterable, Identifiable {
    case addons
    case gearing
    var id: Self { self }
    var title: String {
        switch self {
        case .addons: return "Addons"
        case .gearing: return "Gearing"
        }
    }
    var description: String {
        switch self {
        case .addons: return "Maximize profits"
        case .gearing: return "Speed up gains"
        }
    }
    var color: Color {
        switch self {
        case .addons: return .cyan
        case .gearing: return .yellow
        }
    }
    var imageName: String {
        switch self {
        case .addons: return "Addons"
        case .gearing: return "Gearing"
        }
    }
}
