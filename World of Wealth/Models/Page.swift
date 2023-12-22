//
//  Page.swift
//  World of Wealth
//
//  Created by Brett Rosen on 11/30/23.
//

import BetterCodable
import Foundation
import IdentifiedCollections
import SwiftUI

struct Page: Equatable, Codable {
    var id: String // Changing this type to Page.ID brought an issue decoding w/ Firebase

    @DefaultCodable<DefaultEmptyContentBlocksStrategy>
    var content: IdentifiedArrayOf<ContentBlock> = []

    enum ID: String, Equatable, RawRepresentable, Identifiable, Codable {
        case addons
        case gearing
        case transmog
        case professions
        case flipping
        case sniping

        var id: Self { self }

        static var getStartedIDs: IdentifiedArrayOf<Self> = [.addons, .gearing]
        static var makeGoldIDs: IdentifiedArrayOf<Self> = [.transmog, .professions, .flipping, .sniping]

        var title: String {
            switch self {
            case .addons: return "Addons"
            case .gearing: return "Gearing"
            case .transmog: return "Transmog"
            case .professions: return "Professions"
            case .flipping: return "Flipping"
            case .sniping: return "Sniping"
            }
        }

        var description: String {
            switch self {
            case .addons: return "Maximize profits"
            case .gearing: return "Speed up gains"
            case .transmog: return "Target appearance collectors"
            case .professions: return "Fuel the market"
            case .flipping: return "Buy low, sell high"
            case .sniping: return "Catch rare deals"
            }
        }

        var color: Color {
            switch self {
            case .addons: return .cyan
            case .gearing: return .yellow
            case .transmog: return .purple
            case .professions: return .blue
            case .flipping: return .orange
            case .sniping: return .red
            }
        }

        var imageName: String {
            switch self {
            case .addons: return "Addons"
            case .gearing: return "Gearing"
            case .transmog: return "Transmog"
            case .professions: return "Professions"
            case .flipping: return "Flipping"
            case .sniping: return "Sniping"
            }
        }
    }
}

enum ContentBlock: Equatable, Codable, Identifiable {
    case title(ContentTitle)
    case paragraph(ContentParagraph)
    case image(url: String) // URL
    case divider(id: String)
    case spacer(id: String)
    case hyperlink(ContentHyperlink)

    var id: String {
        switch self {
        case let .title(title): return title.id
        case let .paragraph(paragraph): return paragraph.id
        case let .image(url): return url
        case let .divider(id): return id
        case let .spacer(id): return id
        case let .hyperlink(hyperlink): return hyperlink.id
        }
    }
}

struct ContentTitle: Equatable, Codable, Identifiable {
    var id: String = UUID().uuidString
    var value: String
}

struct ContentParagraph: Equatable, Codable, Identifiable {
    var id: String = UUID().uuidString
    var value: String
}

struct ContentHyperlink: Equatable, Codable, Identifiable {
    var id: String = UUID().uuidString
    var label: String
    var urlString: String
}
