//
//  UIRefreshControl+Helpers.swift
//  PostLoaderIOS
//
//  Created by Fernando Luiz Goulart on 15/08/22.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
