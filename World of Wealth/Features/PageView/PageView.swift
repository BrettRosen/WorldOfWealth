//
//  PageView.swift
//  World of Wealth
//
//  Created by Brett Rosen on 11/30/23.
//

import ComposableArchitecture
import Foundation
import SwiftUI

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
                                    case let .hyperlink(hyperlink):
                                        Link(hyperlink.label, destination: URL(string: hyperlink.urlString)!)
                                            .font(.title)
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
                                    .font(.footnote)
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
