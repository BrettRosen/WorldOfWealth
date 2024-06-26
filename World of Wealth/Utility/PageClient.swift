//
//  PageClient.swift
//  World of Wealth
//
//  Created by Brett Rosen on 11/30/23.
//

import ComposableArchitecture
import Foundation

enum PageClientError: Error, Equatable {
    
}

@DependencyClient
struct PageClient {
    var load: (_ pageID: Page.ID) async throws -> Page
    var edit: (_ page: Page) async throws -> Success
}

extension PageClient: DependencyKey {
  static let liveValue = PageClient(
    load: { id in try await Networking.fetchPage(id: id) },
    edit: { page in try await Networking.updatePage(page: page) }
  )
}

extension DependencyValues {
    var pageClient: PageClient {
        get { self[PageClient.self] }
        set { self[PageClient.self] = newValue }
    }
}
