//
//  UITableView+Dequeueing.swift
//  PostLoaderIOS
//
//  Created by Fernando Luiz Goulart on 15/08/22.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        // swiftlint:disable:next force_cast
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
