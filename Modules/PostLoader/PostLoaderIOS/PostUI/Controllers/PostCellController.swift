//
//  PostImageCellController.swift
//  PostLoaderIOS
//
//  Created by Fernando Luiz Goulart on 15/08/22.
//

import UIKit
import PostLoader

public protocol PostCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public final class PostCellController: PostImageView {
    public typealias Image = UIImage

    private let delegate: PostCellControllerDelegate
    private var cell: PostCell?

    public init(delegate: PostCellControllerDelegate) {
        self.delegate = delegate
    }

    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delegate.didRequestImage()
        return cell!
    }

    func preload() {
        delegate.didRequestImage()
    }

    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }

    public func display(_ viewModel: PostImageViewModel<UIImage>) {
        cell?.postBodyLabel = viewModel.


        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.feedImageView.setImageAnimated(viewModel.image)
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
        cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        cell?.onRetry = delegate.didRequestImage
    }

    private func releaseCellForReuse() {
        cell = nil
    }
}
