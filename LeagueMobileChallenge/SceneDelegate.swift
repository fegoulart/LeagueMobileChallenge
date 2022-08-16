//
//  SceneDelegate.swift
//  LeagueMobileChallenge
//
//  Created by Fernando Luiz Goulart on 15/08/22.
//  Copyright © 2022 Kelvin Lau. All rights reserved.
//

import UIKit
import CoreData
import PostLoader

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()

    private lazy var store: UserStore & UserImageDataStore = {
        // swiftlint:disable:next force_try
        try! CoreDataPostStore(
            storeURL: NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("post-store.sqlite")
        )
    }()

    private lazy var localUserLoader: LocalUserLoader = {
        LocalUserLoader(store: store, currentDate: Date.init)
    }()

    private lazy var remoteUserSessionTokenLoader: UserSessionTokenLoader = {
        let remoteURL = URL(string: "https://engineering.league.dev/challenge/api/login")!

        return RemoteUserSessionTokenLoader(url: remoteURL, client: httpClient)
    }()

    convenience init(httpClient: HTTPClient, store: UserStore & UserImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: scene)
        configureWindow()
    }

    func configureWindow() {
        window?.rootViewController = UINavigationController(
            rootViewController: PostUIComposer.postFeedComposedWith(
                postLoader: makeRemotePostLoader(),
                userLoader: makeLocalUserLoaderWithRemoteFallback(),
                userImageDataLoader: makeLocalUserImageDataLoaderWithRemoteFallback()
            )
        )

        window?.makeKeyAndVisible()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        localUserLoader.validateCache { _ in }
    }

    private func makeRemotePostLoader() -> PostLoader {
        let remoteURL = URL(string: "https://engineering.league.dev/challenge/api/posts")!
        let remotePostLoader = RemotePostLoader(url: remoteURL, client: self.httpClient) { [weak self] in
            guard let self = self else { return ""}
            return self.remoteUserSessionTokenLoader.load() ?? ""
        }
        return MainQueueDispatchDecorator(decoratee: remotePostLoader)
    }

    private func makeLocalUserLoaderWithRemoteFallback() -> UserLoader {
        let remoteURL = URL(string: "https://engineering.league.dev/challenge/api/users")!
        let remoteUserLoader = RemoteUserLoader(url: remoteURL, client: self.httpClient) { [weak self] in
            guard let self = self else { return ""}
            return self.remoteUserSessionTokenLoader.load() ?? ""
        }
        let localUserLoader = LocalUserLoader(store: self.store, currentDate: Date.init)
        let userLoader = UserLoaderWithFallbackComposite(primary: localUserLoader, fallback: remoteUserLoader)
        return MainQueueDispatchDecorator(decoratee: userLoader)
    }

    private func makeLocalUserImageDataLoaderWithRemoteFallback() -> UserImageDataLoader {
        let remoteUserImageDataLoader = RemoteUserImageDataLoader(client: httpClient)
        let localUserImageDataLoader = LocalUserImageDataLoader(store: store)

        return MainQueueDispatchDecorator(decoratee: UserImageDataLoaderWithFallbackComposite(
            primary: localUserImageDataLoader,
            fallback: remoteUserImageDataLoader
        ))
    }

}
