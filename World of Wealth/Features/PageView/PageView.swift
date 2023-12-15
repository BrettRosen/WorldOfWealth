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
    @State private var scrollOffset: CGPoint = .zero

    let store: StoreOf<PageFeature>
    let namespace: Namespace.ID
    var didTapExit: () -> Void

    var body: some View {
        WithViewStore(store, observe: PageFeature.ViewState.init, send: PageFeature.Action.view) { viewStore in

            ZStack {
                SwitchStore(self.store.scope(state: \.pageState, action: \.self)) { pageState in

                    switch pageState {
                    case let .page(page):
                        OffsetObservingScrollView(offset: $scrollOffset) {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(page.content) { contentBlock in
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
                                    case .spacer:
                                        Rectangle()
                                            .frame(height: 32)
                                            .opacity(0.005)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, screen.height / 4)
                        }
                        .scrollIndicators(.hidden)

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

                    VStack {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(viewStore.pageID.title)
                                    .foregroundStyle(viewStore.pageID.color)
                                    .brightness(colorScheme == .dark ? 0.95 : 0)
                                    .matchedGeometryEffect(id: viewStore.pageID.title, in: namespace)
                                    .font(.largeTitle)
                                    .fontWeight(.semibold)
                                Text(viewStore.pageID.description.uppercased())
                                    .fontWidth(.condensed)
                                    .font(.callout)
                                    .foregroundStyle(viewStore.pageID.color.opacity(0.6))
                                    .brightness(colorScheme == .dark ? 0.9 : 0)
                            }
                            .opacity(max(0.0, 1.0 - (scrollOffset.y / 100.0)))

                            Spacer()
                            Button(action: {
                                viewStore.send(.didTapEdit, animation: .default)
                            }) {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.plain)
                            Button(action: didTapExit) {
                                Image(systemName: "xmark")
                            }
                            .buttonStyle(.plain)
                        }
                        .animation(.easeIn.delay(0.2)) { content in
                            content.opacity(didAppear ? 1 : 0)
                        }

                        Spacer()
                    }
                    .padding(16)
                    .opacity({
                        if case .editing = viewStore.pageState {
                            return 0
                        } else {
                            return 1
                        }
                    }())
                }
            }
            .onAppear {
                viewStore.send(.didAppear, animation: .default)
                didAppear = true
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
                    ForEach(viewStore.page.content) { contentBlock in
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
                            HStack {
                                Image(systemName: "square.fill.and.line.vertical.and.square.fill")
                                    .rotationEffect(.degrees(90))
                                Text("Divider")
                            }
                        case .spacer:
                            HStack {
                                Image(systemName: "space")
                                    .rotationEffect(.degrees(90))
                                Text("Spacer")
                            }
                        }
                    }
                    .onMove { from, to in
                        //viewStore.send()
                    }
                    .padding(.horizontal, 16)
                }

                VStack {
                    HStack(spacing: 16) {
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
                            Button(action: {
                                viewStore.send(.didTapAddContent(.spacer(id: UUID().uuidString)))
                            }) {
                                Text("Spacer")
                            }
                        }
                        .buttonStyle(.plain)

                        Spacer()
                        Button(action: {
                            viewStore.send(.didTapCompleteEdit, animation: .spring(.bouncy))
                        }) {
                            Image(systemName: "checkmark")
                                .padding(8)
                                .background(.thinMaterial, in: Circle())
                        }
                        .buttonStyle(.plain)
                        Button(action: {
                            viewStore.send(.didTapCancel, animation: .default)
                        }) {
                            Text("Cancel")
                                .font(.callout)
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(16)
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
