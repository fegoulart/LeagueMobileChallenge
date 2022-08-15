//
//  PostCell.swift
//  PostLoaderIOS
//
//  Created by Fernando Luiz Goulart on 15/08/22.
//

import UIKit

public final class PostCell: UITableViewCell {
    @IBOutlet private(set) public var userContainer: UIView!
    @IBOutlet private(set) public var postContainer: UIView!
    @IBOutlet private(set) public var userImageView: UIImageView!
    @IBOutlet private(set) public var userNameLabel: UILabel!
    @IBOutlet private(set) public var postTitleLabel: UILabel!
    @IBOutlet private(set) public var postBodyLabel: UILabel!
}
