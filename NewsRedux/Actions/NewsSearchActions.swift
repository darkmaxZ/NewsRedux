//
//  NewsSearchActions.swift
//  NewsRedux
//
//  Created by Ziurin, Maksim on 2019/12/27.
//  Copyright © 2019 Ziurin, Maksim. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftThunk

struct DisplayNewsSearchResults: Action {
    let display: NewsSearchResultDisplay
}

struct NewsSearchResultCellOnScreen: Action {
    let index: Int
}

struct NewsSearchResultErrorDisplayRequestCompleted: Action { }

func newsSearchReducer(_ action: Action, state: NewsSearchState?) -> NewsSearchState {
    var value: NewsSearchState = state ?? NewsSearchState(display: .empty, searchQuery: "")
    switch action {
    case let results as DisplayNewsSearchResults:
        value.display = results.display
    case is NewsSearchResultErrorDisplayRequestCompleted:
        if case .error(let request, let code) = value.display, request == .request {
            value.display = .error(.complete, code)
        }
    default:
        break
    }
    return value
}

// MARK: API Thunk Version

struct NewsSearchError: Error {}

class NewsSearchActions {
    static func executeNewsSearch(_ keywords: String) -> Thunk<AppState> {
        return Thunk<AppState> { dispatch, getState in
            dispatch(DisplayNewsSearchResults(display: .loading))
            NewsApi.doQuery(url: "https://newsapi.org/v2/everything?q=\(keywords)&language=en&apiKey=2159dff3238f4299b65a8c3987216e7d") {
                page, error in
                if let pageOne = page {
                    dispatch(DisplayNewsSearchResults(display: .results(pageOne)))
                } else {
                    dispatch(DisplayNewsSearchResults(display: .error(.request, error ?? NewsSearchError())))
                }
            }
        }
    }
}
