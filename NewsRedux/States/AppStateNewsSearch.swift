//
//  AppStateNewsSearch.swift
//  NewsRedux
//
//  Created by Ziurin, Maksim on 2019/12/27.
//  Copyright © 2019 Ziurin, Maksim. All rights reserved.
//

import Foundation

// MARK: State Types

struct NewsSearchResult: Codable {
    let status: String
    let totalResults: Int,
    articles: [Article]
}

enum ErrorDisplayNewsSearchRequest { case request, complete }

enum NewsSearchResultDisplay {
    case empty, loading, error(ErrorDisplayNewsSearchRequest, Error), results([Article])
}

struct NewsSearchState {
    var display: NewsSearchResultDisplay
    var searchQuery: String
}
