//
//  RequestApi.swift
//  NewsRedux
//
//  Created by Ziurin, Maksim on 2019/12/27.
//  Copyright © 2019 Ziurin, Maksim. All rights reserved.
//

import Foundation

class NewsApi {
    static func doQuery(url: String, completion: @escaping ([Article]?, Error?) -> Void) {
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
                if clientError == nil, let data = data, let result = try? JSONDecoder().decode(NewsSearchResult.self, from: data) {
                    pageOfResults = result.articles
                }
                DispatchQueue.main.async {
                    completion(pageOfResults, clientError)
                }
            }.resume()
        }
    }
}
