//
//  PageView.swift
//  World of Wealth
//
//  Created by Brett Rosen on 11/30/23.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct ContentBlockEditFeature {
//    struct State: Equatable, Identifiable {
//        var contentBlock: ContentBlock
//        var id: String { contentBlock.id }
//    }

    enum Action: Equatable, FeatureAction {
        enum ViewAction: Equatable {

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

extension PageFeature {
    struct ViewState: Equatable {
        var pageID: Page.ID
        var pageState: PageState
        init(_ state: State) {
            pageID = state.pageID
            pageState = state.pageState
        }
    }
}

struct PageView: View {
    @Environment(\.colorScheme) private var colorScheme
    // For animations
    @State private var didAppear: Bool = false

    let store: StoreOf<PageFeature>
    let namespace: Namespace.ID
    var didTapExit: () -> Void

    var body: some View {
        WithViewStore(store, observe: PageFeature.ViewState.init, send: PageFeature.Action.view) { viewStore in
            ZStack(alignment: .top) {

                SwitchStore(self.store.scope(state: \.pageState, action: \.self)) { pageState in

                    switch pageState {
                    case let .page(page):
//                        ScrollView {
//                            VStack {
//                                Text(viewStore.pageID.title)
//                                    .frame(maxWidth: .infinity)
//                                    .foregroundStyle(viewStore.pageID.color)
//                                    .brightness(colorScheme == .dark ? 0.95 : 0)
//                                    .matchedGeometryEffect(id: viewStore.pageID.title, in: namespace)
//                                    .font(.title2)
//                                    .fontWeight(.semibold)
//
//                                VStack(spacing: 12) {
//                                    ForEach(page.content) { contentBlock in
//                                        switch contentBlock {
//                                        case let .title(title):
//                                            Text(title.value)
//                                                .font(.title)
//                                        case let .paragraph(paragraph):
//                                            Text(paragraph.value)
//                                                .font(.body)
//                                        case let .image(url):
//                                            AsyncImage(url: URL(string: url)) { image in
//                                                image
//                                            } placeholder: {
//                                                Rectangle()
//                                            }
//                                        case .divider:
//                                            Divider()
//                                        }
//                                    }
//                                }
//                            }
//                            .padding(16)
//                        }
//                        .scrollIndicators(.hidden)

                        VStack {
                            HStack(alignment: .top) {
                                Button(action: {
                                    viewStore.send(.didTapEdit, animation: .default)
                                }) {
                                    Image(systemName: "pencil")
                                        .padding(16)
                                }
                                .buttonStyle(.plain)
                                Spacer()
                                Button(action: didTapExit) {
                                    Image(systemName: "xmark")
                                        .padding(16)
                                        .animation(.easeIn.delay(0.2)) { content in
                                            content.opacity(didAppear ? 1 : 0)
                                        }
                                }
                                .buttonStyle(.plain)
                            }
                            .animation(.easeIn.delay(0.2)) { content in
                                content.opacity(didAppear ? 1 : 0)
                            }
                            Spacer()
                        }
                    case .editing:
                        CaseLet(
                            \PageFeature.PageState.editing,
                             action: PageFeature.Action.editPage,
                             then: EditPageView.init(store:)
                        )
                    case .isLoading:
                        Text("Loading")
                    case .error:
                        Text("Error")
                    }
                }
            }
            .onAppear {
                didAppear = true
                viewStore.send(.didAppear, animation: .default)
            }
        }
    }
}

extension EditPageFeature {
    struct ViewState: Equatable {
        var page: Page
        init(_ state: State) {
            page = state.page
        }
    }
}

struct EditPageView: View {
    let store: StoreOf<EditPageFeature>

    // For animations
    @State private var didAppear: Bool = false

    var body: some View {
        WithViewStore(store, observe: EditPageFeature.ViewState.init, send: EditPageFeature.Action.view) { viewStore in

            ZStack {
                List {
                    VStack(spacing: 12) {
                        Text("Editing")
                        ForEach(viewStore.page.content) { contentBlock in
                            Section {
                                switch contentBlock {
                                case let .title(title):
                                    Text(title.value)
                                        .font(.title)
                                case let .paragraph(paragraph):
                                    Text(paragraph.value)
                                        .font(.body)
                                case let .image(url):
                                    AsyncImage(url: URL(string: url)) { image in
                                        image
                                    } placeholder: {
                                        Rectangle()
                                    }
                                case .divider:
                                    Divider()
                                }
                            }
                        }
                        .onMove { from, to in
                            //viewStore.send()
                        }
                    }
                    .padding(16)
                }

                VStack {
                    HStack(alignment: .top) {
                        HStack {
                            Button(action: {
                                viewStore.send(.didTapCompleteEdit, animation: .spring(.bouncy))
                            }) {
                                Image(systemName: "checkmark")
                            }
                            .buttonStyle(.plain)
                            Menu("", systemImage: "plus") {
                                Button(action: {
                                    viewStore.send(.didTapAddContent(.title(.init(value: "Title"))))
                                }) {
                                    Text("Title")
                                }
                                Button(action: {
                                    viewStore.send(.didTapAddContent(.paragraph(.init(value: "Paragraph"))))
                                }) {
                                    Text("Paragraph")
                                }
                                Button(action: {
                                    viewStore.send(.didTapAddContent(.divider(id: UUID().uuidString)))
                                }) {
                                    Text("Divider")
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(16)

                        Spacer()
                        Button(action: {
                            viewStore.send(.didTapCancel, animation: .default)
                        }) {
                            Text("Cancel")
                                .font(.callout)
                                .padding(16)
                        }
                        .buttonStyle(.plain)
                    }
                    .animation(.easeIn.delay(0.2)) { content in
                        content.opacity(didAppear ? 1 : 0)
                    }
                    Spacer()
                }
            }
            .onAppear {
                didAppear = true
            }
        }
    }
}
