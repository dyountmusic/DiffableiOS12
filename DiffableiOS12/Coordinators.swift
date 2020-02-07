//
//  SearchCoordinator.swift
//  DiffableiOS12
//
//  Created by Daniel Yount on 2/7/20.
//  Copyright © 2020 Daniel Yount. All rights reserved.
//

import Foundation

final class Coordinators {
    static let search = SearchCoordinator()
}

class SearchCoordinator {
    var cachedRecentResults = [Employee]()
}
