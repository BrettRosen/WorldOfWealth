//
//  GetStartedView.swift
//  World of Wealth
//
//  Created by Brett Rosen on 11/23/23.
//

import ComposableArchitecture
import Foundation
import SwiftUI

let screen = UIScreen.main.bounds

struct ImageBlurRowView: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let description: String
    let color: Color
    var imageName: String? = nil
    var namespace: Namespace.ID
    var didTap: () -> Void

    var imageExists: Bool { imageName != nil }

    var body: some View {
        Button(action: didTap) {
            ZStack(alignment: .bottom) {
                SemicircleShape()
                    .fill(color.opacity(0.3))
                    .frame(height: imageExists ? 250 : 120)
                    .blur(radius: 90)
                    .offset(y: imageExists ? 0 : 150)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .brightness(0.6)

                if let imageName = imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .offset(y: 120)
                        .clipped()
                }

                VStack(spacing: 4) {
                    if imageExists {
                        VStack(spacing: 4) {
                            Text(title)
                                .font(.title2)
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(color)
                                .brightness(colorScheme == .dark ? 0.9 : 0)
                                .matchedGeometryEffect(id: title, in: namespace)
                        }
                    } else {
                        Spacer()
                        Text(title)
                            .font(.title2)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(color)
                            .brightness(colorScheme == .dark ? 0.9 : 0)
                            .matchedGeometryEffect(id: title, in: namespace)
                    }
                    Text(description.uppercased())
                        .fontWidth(.condensed)
                        .font(.caption2)
                        .foregroundStyle(color.opacity(0.6))
                        .brightness(colorScheme == .dark ? 0.9 : 0)
                        .matchedGeometryEffect(id: description, in: namespace)

                    Spacer()
                }
                .padding(.top, imageExists ? 30 : 0)
            }
            .fontWeight(.semibold)
            .frame(height: imageExists ? 250 : 120)
            .background(Color.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
            .background {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(.thinMaterial)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
            }
            .background(Color.primary.opacity(0.2), in: RoundedRectangle(cornerRadius: 30, style: .continuous).stroke())
        }
        .buttonStyle(.plain)
    }
}

extension PageListFeature {
    struct ViewState: Equatable {
        var pageIDs: IdentifiedArrayOf<Page.ID>
        var isPageSelected: Bool
        init(_ state: State) {
            pageIDs = state.pageIDs
            isPageSelected = state.selectedPageState != nil
        }
    }
}

struct PageListView: View {
    let store: StoreOf<PageListFeature>

    @Environment(\.colorScheme) private var colorScheme
    @Namespace private var namespace

    var body: some View {
        WithViewStore(store, observe: PageListFeature.ViewState.init, send: PageListFeature.Action.view) { viewStore in
            VStack(spacing: 8) {
                IfLetStore(store.scope(state: \.selectedPageState, action: \.page)) { store in
                    PageView(store: store, namespace: namespace, didTapExit: {
                        viewStore.send(.updatedSelectedPageID(nil), animation: .default)
                    })
                } else: {
                    ScrollView {
                        ForEach(viewStore.pageIDs) { pageID in
                            ImageBlurRowView(title: pageID.title, description: pageID.description, color: pageID.color, imageName: pageID.imageName, namespace: namespace, didTap: {

                                viewStore.send(.updatedSelectedPageID(pageID), animation: .default)
                            })
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase.isIdentity ? 1 : (max(0.75, 1 * phase.value / 3)))
                            }
                        }
                        .padding(.top, 64)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .padding(.horizontal, 8)
        }
    }
}

#Preview {
    PageListView(store: .init(initialState: .init(pageIDs: Page.ID.getStartedIDs), reducer:  { PageListFeature() }))
}

struct SemicircleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.maxY),
                    radius: rect.width / 2,
                    startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: 180),
                    clockwise: true)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
