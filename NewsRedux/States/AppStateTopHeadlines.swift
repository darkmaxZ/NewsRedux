//
//  AppStateNews.swift
//  ReduxApp
//
//  Created by Ziurin, Maksim on 2019/12/24.
//  Copyright © 2019 Ziurin, Maksim. All rights reserved.
//

import Foundation

// MARK: State Types

struct GetNewsResult: Codable {
    let status: String
    let totalResults: Int,
    articles: [Article]
}

enum ErrorDisplayRequest { case request, complete }

enum GetNewsResultDisplay {
    case empty, loading, error(ErrorDisplayRequest, Error), results([Article])
}

struct NewsState {
    var display: GetNewsResultDisplay
    var searchQuery: String
}

