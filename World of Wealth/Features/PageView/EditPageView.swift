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

            ZStack {
                List {
                    ForEachStore(store.scope(state: \.page.content, action: EditPageFeature.Action.editingContentBlock)) { store in

                        ContentBlockEditView(store: store)
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
                    .font(.title)
            case let .paragraph(paragraph):
                TextField("Paragraph textfield", text: viewStore.binding(get: { state in
                    paragraph.value
                }, send: ContentBlockEditFeature.Action.ViewAction.updateContentBlock), prompt: Text("Paragraph"))
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
    }
}
