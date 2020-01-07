//
//  NewsSearchViewController.swift
//  ReduxApp
//
//  Created by Ziurin, Maksim on 2019/12/24.
//  Copyright © 2019 Ziurin, Maksim. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRouter
import Kingfisher

class NewsSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
    StoreSubscriber, Routable  {
    static let identifier = "NewsSearch"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let imageDimensionInPixels: CGFloat = 84
    private var newsArticles: [Article]?
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        mainStore.dispatch(NewsActions.executeNewsSearch())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainStore.subscribe(self) {
            $0.select { $0.newsState.display }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
    }
    
    // MARK: StoreSubscriber

    func newState(state: GetNewsResultDisplay) {
        switch state {
        case .empty:
            activityIndicator.stopAnimating()
            tableView.isHidden = true
            newsArticles = nil
        case .loading:
            activityIndicator.startAnimating()
            tableView.isHidden = true
            newsArticles = nil
        case .error(let request, _):
            activityIndicator.stopAnimating()
            tableView.isHidden = false
            newsArticles = nil
            if request == .request {
                let alert = UIAlertController(title: "Error?", message: "An error occurred", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true)
                mainStore.dispatch(GetNewsResultErrorDisplayRequestCompleted())
            }
        case .results(let articles):
            activityIndicator.stopAnimating()
            tableView.isHidden = false
            newsArticles = articles
        }
        
        tableView.reloadData()
    }
    
    // MARK: Routable
    
    func pushRouteSegment(_ routeElementIdentifier: RouteElementIdentifier, animated: Bool, completionHandler: @escaping RoutingCompletionHandler) -> Routable {
        print("ViewController Routable push \(routeElementIdentifier)")
        
        return self
    }
    
    func popRouteSegment(_ routeElementIdentifier: RouteElementIdentifier, animated: Bool, completionHandler: @escaping RoutingCompletionHandler) {
        print("ViewController Routable pop \(routeElementIdentifier)")
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsArticles?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = newsArticles?[indexPath.row] else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as! NewsTableViewCell
  
        let title = item.title
        let titleAttribs = [ NSAttributedString.Key.foregroundColor: UIColor.black,
                             NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16) ]
        let titleString = NSMutableAttributedString(string: title!, attributes: titleAttribs)
        
        cell.articleTitle.attributedText = titleString
        
        if let resource = item.urlToImage {
            cell.articleImage.kf.setImage(with: URL(string: resource), placeholder: UIImage(named: "placeholder")) { result in
                switch result {
                case .success(let value):
                    cell.articleImage.image = self.resizeImage(image: value.image)
                case .failure(let error):
                    print("Error loading image: \(error)")
                }
            }
        } else {
            cell.articleImage.image = UIImage(named: "placeholder")
        }
        
        cell.article = item
        
        return cell
    }
    
    func resizeImage(image: UIImage) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: imageDimensionInPixels, height: imageDimensionInPixels))
        image.draw(in: CGRect(x: 0, y: 0, width: imageDimensionInPixels, height: imageDimensionInPixels))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var route = mainStore.state.navigationState.route
        route.append(NewsArticleDetailsViewController.identifier)
        // set the data to display on the details screen
        let cell = tableView.cellForRow(at: indexPath) as! NewsTableViewCell
        mainStore.dispatch(SetRouteSpecificData(route: route, data: cell.article!))
        // jump to details screen
        mainStore.dispatch(SetRouteAction(route))
    }
}
