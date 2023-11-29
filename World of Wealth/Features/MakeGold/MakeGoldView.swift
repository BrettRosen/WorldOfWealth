//
//  MakeGoldView.swift
//  World of Wealth
//
//  Created by Brett Rosen on 11/24/23.
//

import Foundation
import SwiftUI

enum MakeGoldElement: String, CaseIterable, Identifiable {
    case transmog
    case professions
    case flipping
    case sniping

    var id: Self { self }
    var title: String {
        switch self {
        case .transmog: return "Transmog"
        case .professions: return "Professions"
        case .flipping: return "Flipping"
        case .sniping: return "Sniping"
        }
    }
    var description: String {
        switch self {
        case .transmog: return "Target appearance collectors"
        case .professions: return "Fuel the market"
        case .flipping: return "Buy low, sell high"
        case .sniping: return "Catch rare deals"
        }
    }
    var color: Color {
        switch self {
        case .transmog: return .purple
        case .professions: return .blue
        case .flipping: return .orange
        case .sniping: return .red
        }
    }
    var imageName: String {
        switch self {
        case .transmog: return "Transmog"
        case .professions: return "Professions"
        case .flipping: return "Flipping"
        case .sniping: return "Sniping"
        }
    }
}

struct MakeGoldView: View {
    @State private var selectedElement: MakeGoldElement?
    @Namespace private var namespace

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                if let selectedElement = selectedElement {
                    switch selectedElement {
                    case .transmog: Text(selectedElement.title)
                    case .professions: Text(selectedElement.title)
                    case .flipping: Text(selectedElement.title)
                    case .sniping: Text(selectedElement.title)
                    }
                } else {
                    ForEach(MakeGoldElement.allCases) { element in
                        ImageBlurRowView(title: element.title, description: element.description, color: element.color, imageName: element.imageName, namespace: namespace, didTap: {

                            withAnimation {
                                selectedElement = element
                            }
                        })
                        .scrollTransition { content, phase in
                            content
                                .scaleEffect(phase.isIdentity ? 1 : (max(0.75, 1 * phase.value / 3)))
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, selectedElement == nil ? 64 : 0)
        }
        .scrollIndicators(.hidden)
    }
}
