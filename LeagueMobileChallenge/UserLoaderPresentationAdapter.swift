//
//  UserDataLoaderPresentationAdapter.swift
//  LeagueMobileChallenge
//
//  Created by Fernando Luiz Goulart on 15/08/22.
//  Copyright © 2022 Kelvin Lau. All rights reserved.
//

import Foundation
import PostLoader
import PostLoaderIOS

final class UserLoaderPresentationAdapter<View: PostView, Image>: PostCellControllerDelegate where View.Image == Image {

    private let model: Post
    private let userImageLoader: UserImageDataLoader
    private let userLoader: UserLoader
    private var imageLoaderTask: UserImageDataLoaderTask?
    private var userLoaderTask: UserLoaderTask?
    
    var presenter: PostPresenter<View, Image>?

    init(
        model: Post,
        userImageLoader: UserImageDataLoader,
        userLoader: UserLoader
    ) {
        self.model = model
        self.userImageLoader = userImageLoader
        self.userLoader = userLoader
    }

    func didRequestUser() {
        presenter?.didStartLoadingUser(for: model)
        guard let userId = model.userId else {
            self.presenter?.didFinishLoadingUser(with: RemoteUserLoader.Error.invalidData, for: model)
            return
        }
        let myPost = model
        self.userLoaderTask = self.userLoader.load(userId: userId) { [weak self, myPost] result in
            switch result {
            case .success(let user):

                guard let updatedUser: User = user else {
                    self?.presenter?.didFinishLoadingUser(with: RemoteUserLoader.Error.invalidData, for: myPost)
                    return
                }
                self?.presenter?.didFinishLoadingUser(for: myPost, for: updatedUser)
                guard let imageUrl = updatedUser.imageUrl else {
                    return
                }
                self?.presenter?.didStartLoadingImageData(for: myPost, user: updatedUser)
                self?.userImageLoader.loadUserImageData(
                    url: imageUrl,
                    userId: updatedUser.id
                ) { [weak self] result in
                    switch result {
                    case .success(let data):
                        self?.presenter?.didFinishLoadingImageData(with: data, for: myPost, user: updatedUser)
                    case .failure(let error):
                        self?.presenter?.didFinishLoadingImageData(with: error, for: myPost, for: updatedUser)
                    }
                }
            case .failure(let error):
                self?.presenter?.didFinishLoadingUser(with: error, for: myPost)
            }
        }
    }

    func didCancelUserRequest() {
        userLoaderTask?.cancel()
    }
}
