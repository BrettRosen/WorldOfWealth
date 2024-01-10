//
//  EditPageView.swift
//  World of Wealth
//
//  Created by Brett Rosen on 12/15/23.
//

import ComposableArchitecture
import Foundation
import SwiftUI

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
            List {
                ForEachStore(store.scope(state: \.page.content, action: EditPageFeature.Action.editingContentBlock)) { store in
                    ContentBlockEditView(store: store)
                }
                .onDelete { indexSet in
                    viewStore.send(.didTapDelete(indexSet), animation: .default)
                }
                .onMove { from, to in
                    viewStore.send(.didMove(from: from, to: to), animation: .default)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Menu("", systemImage: "plus") {
                        Button(action: {
                            viewStore.send(.didTapAddContent(.title(.init(value: ""))))
                        }) {
                            Text("Title")
                        }
                        Button(action: {
                            viewStore.send(.didTapAddContent(.paragraph(.init(value: ""))))
                        }) {
                            Text("Paragraph")
                        }
                        Button(action: {
                            viewStore.send(.didTapAddContent(.hyperlink(.init(label: "", urlString: ""))))
                        }) {
                            Text("Link")
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
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: {
                        viewStore.send(.didTapCompleteEdit, animation: .spring(.bouncy))
                    }) {
                        Text("Save")
                            .font(.callout)
                            .foregroundStyle(.green)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 4)
                    Button(action: {
                        viewStore.send(.didTapCancel, animation: .default)
                    }) {
                        Text("Cancel")
                            .font(.callout)
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                    EditButton()
                }
            }
            .onAppear {
                didAppear = true
            }
        }
    }
}

extension ContentBlockEditFeature {
    struct ViewState {
        init(_ state: ContentBlock) {

        }
    }
}

struct ContentBlockEditView: View {
    let store: StoreOf<ContentBlockEditFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }, send: ContentBlockEditFeature.Action.view) { viewStore in

            switch viewStore.state {
            case let .title(title):
                TextField("Title textfield", text: viewStore.binding(get: { state in
                    title.value
                }, send: ContentBlockEditFeature.Action.ViewAction.updateContentBlock), prompt: Text("Title"))
                    .font(.caption)
                    .fontWeight(.bold)
            case let .paragraph(paragraph):
                TextEditor(text: viewStore.binding(get: { state in
                    paragraph.value
                }, send: ContentBlockEditFeature.Action.ViewAction.updateContentBlock))
                    .font(.caption2)
                    .frame(height: 120)
            case let .hyperlink(hyperlink):
                VStack {
                    TextField(
                        "Link textfield title",
                        text: viewStore.binding(
                            get: { state in hyperlink.label },
                            send: ContentBlockEditFeature.Action.ViewAction.updateContentBlock),
                        prompt: Text("Link Title")
                    )
                    .font(.caption2)
                    TextField(
                        "Link textfield url",
                        text: viewStore.binding(
                            get: { state in hyperlink.urlString },
                            send: ContentBlockEditFeature.Action.ViewAction.updateHyperlinkURL),
                        prompt: Text("Link URL")
                    )
                    .font(.caption2)
                }
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
                .font(.caption2)
            case .spacer:
                HStack {
                    Image(systemName: "space")
                        .rotationEffect(.degrees(90))
                    Text("Spacer")
                }
                .font(.caption2)
            }
        }
    }
}
