//
//  PostImagePresenter.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 15/08/22.
//

public protocol PostView {
    associatedtype Image

    func display(_ model: PostViewModel<Image>)
}

public final class PostPresenter<View: PostView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?

    public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }

    public func didStartLoadingUser(for model: Post) {
        view.display(
            PostViewModel(
                userName: nil,
                userImage: nil,
                postTitle: model.title,
                postBody: model.body,
                isLoading: true
            )
        )
    }

    public func didSFinishLoadingUser(for model: Post, for user: User) {
        view.display(
            PostViewModel(
                userName: user.name,
                userImage: nil,
                postTitle: model.title,
                postBody: model.body,
                isLoading: false
            )
        )
    }

    public func didFinishLoadingUser(with error: Error, for model: Post) {
        view.display(
            PostViewModel(
                userName: nil,
                userImage: nil,
                postTitle: model.title,
                postBody: model.body,
                isLoading: false
            )
        )
    }

    public func didStartLoadingImageData(for model: Post, user: User) {
        view.display(
            PostViewModel(
                userName: user.name,
                userImage: nil,
                postTitle: model.title,
                postBody: model.body,
                isLoading: true
            )
        )
    }

    public func didFinishLoadingImageData(with data: Data, for model: Post, user: User) {
        let image = imageTransformer(data)
        view.display(
            PostViewModel(
                userName: user.name,
                userImage: image,
                postTitle: model.title,
                postBody: model.body,
                isLoading: false
            )
        )
    }

    public func didFinishLoadingImageData(with error: Error, for model: Post, for user: User) {
        view.display(
            PostViewModel(
                userName: user.name,
                userImage: nil,
                postTitle: model.title,
                postBody: model.body,
                isLoading: false
            )
        )
    }
}
