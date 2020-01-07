//
//  AppStateNavigation.swift
//  NewsRedux
//
//  Created by Ziurin, Maksim on 2019/12/26.
//  Copyright © 2019 Ziurin, Maksim. All rights reserved.
//

import Foundation
import ReSwiftRouter

struct MultiNavigationState {
    var routeMap: [String: Route]
    var currentState: NavigationState
}
