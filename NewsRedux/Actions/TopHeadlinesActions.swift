//
//  NewsActions.swift
//  NewsRedux
//
//  Created by Ziurin, Maksim on 2019/12/25.
//  Copyright © 2019 Ziurin, Maksim. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftThunk

struct DisplayGetNewsResults: Action {
    let display: GetNewsResultDisplay
}

struct DisplayNewsSearchResults: Action {
    let display: NewsSearchResultDisplay
}

struct GetNewsResultCellOnScreen: Action {
    let index: Int
}

struct GetNewsResultErrorDisplayRequestCompleted: Action { }

func newsReducer(_ action: Action, state: NewsState?) -> NewsState {
    var value: NewsState = state ?? NewsState(display: .empty, searchQuery: "")
    switch action {
    case let results as DisplayGetNewsResults:
        value.display = results.display
    case is GetNewsResultErrorDisplayRequestCompleted:
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

class NewsActions {
    static func executeGetTopHeadlines() -> Thunk<AppState> {
        return Thunk<AppState> { dispatch, getState in
            dispatch(DisplayGetNewsResults(display: .loading))
            queryGetNewsApi(url: "https://newsapi.org/v2/top-headlines?country=us&apiKey=2159dff3238f4299b65a8c3987216e7d") { page, error in
                if let pageOne = page {
                    dispatch(DisplayGetNewsResults(display: .results(pageOne)))
                } else {
                    dispatch(DisplayGetNewsResults(display: .error(.request, error ?? FakeError())))
                }
            }
        }
    }
    
    static func executeNewsSearch() -> Thunk<AppState> {
        return Thunk<AppState> { dispatch, getState in
            dispatch(DisplayGetNewsResults(display: .loading))
            queryGetNewsApi(url: "https://newsapi.org/v2/everything?q=&language=en&apiKey=2159dff3238f4299b65a8c3987216e7d") { page, error in
                if let pageOne = page {
                    dispatch(DisplayGetNewsResults(display: .results(pageOne)))
                } else {
                    dispatch(DisplayGetNewsResults(display: .error(.request, error ?? FakeError())))
                }
            }
        }
    }
}

// MARK: API call

fileprivate func queryGetNewsApi(url: String, completion: @escaping ([Article]?, Error?) -> Void) {
    let search = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    
    print("request: \(search)")

    // NOTE: adding a one second delay to allow now-loading indicator to display
    let deadline: DispatchTime = .now() + 1.0
    DispatchQueue.main.asyncAfter(deadline: deadline) {
        URLSession.shared.dataTask(with: URL(string: search)!) { (data, response, error) in
            var pageOfResults: [Article]?
            var clientError = error
            // catch http status errors here
            if error == nil, let response = response as? HTTPURLResponse, response.statusCode >= 300 {
                clientError = FakeError()
            }
            if clientError == nil, let data = data, let result = try? JSONDecoder().decode(GetNewsResult.self, from: data) {
                pageOfResults = result.articles
            }
            DispatchQueue.main.async {
                completion(pageOfResults, clientError)
            }
        }.resume()
    }
}
