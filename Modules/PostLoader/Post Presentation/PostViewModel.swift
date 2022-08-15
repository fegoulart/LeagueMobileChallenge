//
//  PostImageViewModel.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 15/08/22.
//

public struct PostViewModel<Image> {
    public let userName: String?
    public let userImage: Image?
    public let postTitle: String?
    public let postBody: String?
    public let isLoading: Bool
}
