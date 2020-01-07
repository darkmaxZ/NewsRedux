//
//  TopHeadlinesActions.swift
//  NewsRedux
//
//  Created by Ziurin, Maksim on 2019/12/25.
//  Copyright © 2019 Ziurin, Maksim. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftThunk

struct DisplayGetTopHeadlinesResults: Action {
    let display: GetTopHeadlinesResultDisplay
}

struct GetTopHeadlinesResultCellOnScreen: Action {
    let index: Int
}

struct GetTopHeadlinesResultErrorDisplayRequestCompleted: Action { }

func topHeadlinesReducer(_ action: Action, state: TopHeadlinesState?) -> TopHeadlinesState {
    var value: TopHeadlinesState = state ?? TopHeadlinesState(display: .empty)
    switch action {
    case let results as DisplayGetTopHeadlinesResults:
        value.display = results.display
    case is GetTopHeadlinesResultErrorDisplayRequestCompleted:
        if case .error(let request, let code) = value.display, request == .request {
            value.display = .error(.complete, code)
        }
    default:
        break
    }
    return value
}

// MARK: API Thunk Version

struct FakeError: Error {}

class TopHeadlinesActions {
    static func executeGetTopHeadlines() -> Thunk<AppState> {
        return Thunk<AppState> { dispatch, getState in
            dispatch(DisplayGetTopHeadlinesResults(display: .loading))
            NewsApi.doQuery(url: "https://newsapi.org/v2/top-headlines?country=us&apiKey=2159dff3238f4299b65a8c3987216e7d") { page, error in
                if let pageOne = page {
                    dispatch(DisplayGetTopHeadlinesResults(display: .results(pageOne)))
                } else {
                    dispatch(DisplayGetTopHeadlinesResults(display: .error(.request, error ?? FakeError())))
                }
            }
        }
    }
}
