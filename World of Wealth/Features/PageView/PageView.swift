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
    @State private var animateContent: Bool = false
    @State private var scrollOffset: CGPoint = .zero

    let store: StoreOf<PageFeature>
    let namespace: Namespace.ID
    var didTapExit: () -> Void

    private func getGradient(from color: Color) -> Color {
        let value = min(0.9, scrollOffset.y / screen.height) * 1.2
        return color.opacity(value)
    }

    var body: some View {
        WithViewStore(store, observe: PageFeature.ViewState.init, send: PageFeature.Action.view) { viewStore in
            ZStack(alignment: .top) {
                Image(viewStore.pageID.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: screen.width)
                    .clipped()
                    .matchedGeometryEffect(id: viewStore.pageID.imageName, in: namespace)

                Color.matching.opacity(0.75)

                LinearGradient(colors: [viewStore.pageID.color.opacity(0.9), getGradient(from: viewStore.pageID.color), getGradient(from: viewStore.pageID.color)], startPoint: .bottom, endPoint: .top)
                    .ignoresSafeArea(edges: .all)
                    .opacity(animateContent ? 1 : 0)
                    .brightness(-0.8)

                SwitchStore(self.store.scope(state: \.pageState, action: \.self)) { pageState in
                    switch pageState {
                    case let .page(page):
                        OffsetObservingScrollView(offset: $scrollOffset) {
                            VStack(alignment: .leading, spacing: 12) {
                                Rectangle()
                                    .fill(.clear)
                                    .frame(height: screen.height * 0.5)

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(viewStore.pageID.title)
                                        .foregroundStyle(.white)
                                        .font(.largeTitle)
                                    Text(viewStore.pageID.description.uppercased())
                                        .fontWidth(.condensed)
                                        .font(.footnote)
                                        .foregroundStyle(viewStore.pageID.color.opacity(0.6))
                                        .brightness(0.9)
                                }
                                .fontWeight(.semibold)
                                .padding(.bottom, 16)

                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(page.content) { contentBlock in
                                        switch contentBlock {
                                        case let .title(title):
                                            Text(title.value)
                                                .font(.title2)
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
                                .foregroundStyle(.white)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                        }
                        .scrollIndicators(.hidden)

                    case .editing:
                        CaseLet(
                            \PageFeature.PageState.editing,
                             action: PageFeature.Action.editPage,
                             then: EditPageView.init(store:)
                        )
                    case .isLoading:
                        VStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .onAppear {
                            viewStore.send(.didAppear, animation: .default)
                            withAnimation(.easeIn) {
                                animateContent = true
                            }
                        }
                    case .error:
                        Text("Error")
                    }
                }

                if case .page = viewStore.pageState {
                    HStack(alignment: .top) {
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
                    .padding(16)
                }
            }
        }
    }
}
