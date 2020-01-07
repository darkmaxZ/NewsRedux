//
//  NewsTableViewCell.swift
//  NewsRedux
//
//  Created by Ziurin, Maksim on 2019/12/25.
//  Copyright © 2019 Ziurin, Maksim. All rights reserved.
//

import UIKit

public class NewsTableViewCell: UITableViewCell {
    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var articleTitle: UILabel!
    public var article: Article?
}
