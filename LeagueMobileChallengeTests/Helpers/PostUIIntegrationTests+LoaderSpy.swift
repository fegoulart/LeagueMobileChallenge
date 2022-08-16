//
//  FeeeUIIntegrationTests+LoaderSpy
//  LeagueMobileChallenge
//
//  Created by Fernando Luiz Goulart on 16/08/22.
//  Copyright © 2022 Kelvin Lau. All rights reserved.
//

import Foundation
import PostLoader
import PostLoaderIOS

extension PostUIIntegrationTests {

    class LoaderSpy: PostLoader, UserLoader, UserImageDataLoader {

        // MARK: - PostLoader

        private var postRequests = [(PostLoader.Result) -> Void]()

        var loadPostCallCount: Int {
            return postRequests.count
        }

        func load(completion: @escaping (PostLoader.Result) -> Void) {
            postRequests.append(completion)
        }

        func completeFeedLoading(with feed: [Post] = [], at index: Int = 0) {
            postRequests[index](.success(feed))
        }

        func completeFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            postRequests[index](.failure(error))
        }

        // MARK: - FeedImageDataLoader

        // swiftlint:disable:next nesting
        private struct ImageTaskSpy: UserImageDataLoaderTask {
            let cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }

        private var imageRequests = [(userId: Int, completion: (UserImageDataLoader.Result) -> Void)]()

        var loadedUserImages: [Int] {
            return imageRequests.map { $0.userId }
        }

        private(set) var cancelledImageURLs = [Int]()

        func loadUserImageData(
            url: URL,
            userId: Int,
            completion: @escaping (UserImageDataLoader.Result) -> Void
        ) -> UserImageDataLoaderTask {
            imageRequests.append((userId, completion))
            return ImageTaskSpy { [weak self] in self?.cancelledImageURLs.append(userId) }
        }

        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completion(.success(imageData))
        }

        func completeImageLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            imageRequests[index].completion(.failure(error))
        }

        // MARK: - UserDataLoader

        // swiftlint:disable:next nesting
        private struct UserTaskSpy: UserLoaderTask {
            let cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }

        private var userRequests = [(userId: Int, completion: (UserLoader.Result) -> Void)]()

        var loadedUsers: [Int] {
            return userRequests.map { $0.userId }
        }

        private(set) var cancelledUserIds = [Int]()

        func load(userId: Int, completion: @escaping (UserLoader.Result) -> Void) -> UserLoaderTask? {
            userRequests.append((userId, completion))
            return UserTaskSpy { [weak self] in self?.cancelledUserIds.append(userId) }
        }
    }
}
