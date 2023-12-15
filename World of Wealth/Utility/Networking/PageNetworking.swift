//
//  PageNetworking.swift
//  World of Wealth
//
//  Created by Brett Rosen on 11/30/23.
//

import Foundation

extension Networking {
    static func fetchPage(id: Page.ID) async throws -> Page {
        try await Networking.getDocumentOnce(collection: .pages, documentId: id.rawValue)
    }
}
