//
//  PostImageCellController.swift
//  PostLoaderIOS
//
//  Created by Fernando Luiz Goulart on 15/08/22.
//

import UIKit
import PostLoader

public protocol PostCellControllerDelegate: AnyObject {
    func didRequestUser()
    func didCancelUserRequest()
}

public final class PostCellController: PostView {
    public typealias Image = UIImage

    private let delegate: PostCellControllerDelegate
    private var cell: PostCell?

    public init(delegate: PostCellControllerDelegate) {
        self.delegate = delegate
    }

    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell
        cell?.userImageView.clipsToBounds = true
        cell?.userImageView.layer.cornerRadius = 25
        delegate.didRequestUser()
        return cell!
    }

    func preload() {
        delegate.didRequestUser()
    }

    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelUserRequest()
    }

    public func display(_ viewModel: PostViewModel<UIImage>) {
        self.cell?.postBodyLabel.text = viewModel.postBody ?? ""
        self.cell?.postTitleLabel.text = viewModel.postTitle ?? ""
        self.cell?.userNameLabel.text = viewModel.userName ?? ""
        self.cell?.postContainer.isShimmering = viewModel.isLoading && viewModel.postTitle == nil
        self.cell?.userContainer.isShimmering = viewModel.isLoading && viewModel.userName == nil &&
        viewModel.userImage == nil
        self.cell?.userImageView.setImageAnimated(viewModel.userImage)
    }

    private func releaseCellForReuse() {
        cell = nil
    }
}
