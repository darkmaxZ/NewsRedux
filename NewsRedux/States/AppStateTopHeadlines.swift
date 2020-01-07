//
//  AppStateTopHeadlines.swift
//  ReduxApp
//
//  Created by Ziurin, Maksim on 2019/12/24.
//  Copyright © 2019 Ziurin, Maksim. All rights reserved.
//

import Foundation

// MARK: State Types

struct GetTopHeadlinesResult: Codable {
    let status: String
    let totalResults: Int,
    articles: [Article]
}

enum ErrorDisplayTopHeadlinesRequest { case request, complete }

enum GetTopHeadlinesResultDisplay {
    case empty, loading, error(ErrorDisplayTopHeadlinesRequest, Error), results([Article])
}

struct TopHeadlinesState {
    var display: GetTopHeadlinesResultDisplay
}

