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

struct FullScreenAddonView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var didAppear: Bool = false

    let addons = GetStartedElement.addons
    let namespace: Namespace.ID
    var didTapExit: () -> Void

    var body: some View {
        ZStack {
            HStack {
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

            VStack {
                Text(addons.title)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(addons.color)
                    .brightness(colorScheme == .dark ? 0.95 : 0)
                    .matchedGeometryEffect(id: addons.title, in: namespace)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(16)
                Spacer()
            }
        }
        .onAppear {
            didAppear = true
        }
    }
}

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
                    }
                    Text(description.uppercased())
                        .fontWidth(.condensed)
                        .font(.caption2)
                        .foregroundStyle(color.opacity(0.6))
                        .brightness(colorScheme == .dark ? 0.9 : 0)
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

extension GetStartedFeature {
    struct ViewState: Equatable {
        var selectedElement: GetStartedElement?
        init(_ state: State) {
            selectedElement = state.selectedElement
        }
    }
}

struct GetStartedView: View {
    let store: StoreOf<GetStartedFeature>

    @Environment(\.colorScheme) private var colorScheme
    @Namespace private var namespace

    var body: some View {
        WithViewStore(store, observe: GetStartedFeature.ViewState.init, send: GetStartedFeature.Action.view) { viewStore in
            ScrollView {
                VStack(spacing: 8) {
                    if let selectedElement = viewStore.selectedElement {
                        switch selectedElement {
                        case .addons:
                            FullScreenAddonView(namespace: namespace, didTapExit: {
                                viewStore.send(.updateSelectedElement(nil), animation: .default)
                            })
                        case .gearing:
                            Text("Gearing")
                        }
                    } else {
                        ForEach(GetStartedElement.allCases) { element in
                            ImageBlurRowView(title: element.title, description: element.description, color: element.color, imageName: element.imageName, namespace: namespace, didTap: {

                                viewStore.send(.updateSelectedElement(element), animation: .default)
                            })
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase.isIdentity ? 1 : (max(0.75, 1 * phase.value / 3)))
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, viewStore.selectedElement == nil ? 64 : 0)
            }
            .scrollIndicators(.hidden)
        }
    }
}

#Preview {
    GetStartedView(store: .init(initialState: .init()) {
        GetStartedFeature()
    })
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
