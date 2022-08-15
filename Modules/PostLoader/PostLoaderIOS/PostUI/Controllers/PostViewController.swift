//
//  PostViewController.swift
//  PostLoaderIOS
//
//  Created by Fernando Luiz Goulart on 15/08/22.
//

import Foundation

import UIKit
import PostLoader

public protocol PostViewControllerDelegate {
    func didRequestPostRefresh()
}

public final class PostViewController: UITableViewController,
                                        UITableViewDataSourcePrefetching,
                                        PostLoadingView,
                                        PostErrorView {
    @IBOutlet private(set) public var errorView: ErrorView?

    private var loadingControllers = [IndexPath: PostCellController]()

    private var tableModel = [PostCellController]() {
        didSet { tableView.reloadData() }
    }

    public var delegate: PostViewControllerDelegate?

    public override func viewDidLoad() {
        super.viewDidLoad()

        refresh()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.sizeTableHeaderToFit()
    }

    @IBAction private func refresh() {
        delegate?.didRequestPostRefresh()
    }

    public func display(_ cellControllers: [PostCellController]) {
        loadingControllers = [:]
        tableModel = cellControllers
    }

    public func display(_ viewModel: FeedLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }

    public func display(_ viewModel: FeedErrorViewModel) {
        errorView?.message = viewModel.message
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view(in: tableView)
    }

    public override func tableView(
        _ tableView: UITableView,
        didEndDisplaying cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }

    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
        return controller
    }

    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        loadingControllers[indexPath]?.cancelLoad()
        loadingControllers[indexPath] = nil
    }
}
