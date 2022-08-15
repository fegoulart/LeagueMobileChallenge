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
    func didRequestUserImage()
    func didCancelUserImageRequest()
}

public final class PostCellController: PostView {
    public typealias Image = UIImage

    private let delegate: PostCellControllerDelegate
    private var cell: PostCell?

    public init(delegate: PostCellControllerDelegate) {
        self.delegate = delegate
    }

    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delegate.didRequestUser()
        // delegate.didRequestUserImage()
        return cell!
    }

    func preload() {
        delegate.didRequestUser()
        // delegate.didRequestImage()
    }

    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelUserRequest()
        // delegate.didCancelImageRequest()
    }

    public func display(_ viewModel: PostViewModel<UIImage>) {
        cell?.postBodyLabel.text = viewModel.postBody ?? ""
        cell?.postTitleLabel.text = viewModel.postTitle ?? ""
        cell?.userNameLabel.text = viewModel.userName ?? ""
        cell?.postContainer.isShimmering = viewModel.isLoading && viewModel.postTitle == nil
        cell?.userContainer.isShimmering = viewModel.isLoading && viewModel.userName == nil &&
        viewModel.userImage == nil
        cell?.userImageView.setImageAnimated(viewModel.userImage)
    }

    private func releaseCellForReuse() {
        cell = nil
    }
}
