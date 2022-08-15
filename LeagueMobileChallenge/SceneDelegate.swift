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
                ΩpostLoader: makeRemotePostLoader(completion: <#(Result<PostLoader, Error>) -> ()#>),
                userLoader: makeLocalUserLoaderWithRemoteFallback(),
                userImageDataLoader: makeLocalUserImageDataLoaderWithRemoteFallback()
            )
        )

        window?.makeKeyAndVisible()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        localUserLoader.validateCache { _ in }
    }


    private func makeRemotePostLoader(completion: @escaping (Swift.Result<PostLoader, Error>) -> ()) {

        DispatchQueue.global().async {
            self.remoteUserSessionTokenLoader.load { result in
                switch result {
                case .success(let token):
                    let remoteURL = URL(string: "https://engineering.league.dev/challenge/api/posts")!
                    let remotePostLoader = RemotePostLoader(url: remoteURL, client: self.httpClient) { return token }
                    completion(.success(remotePostLoader))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    private func makeLocalUserLoaderWithRemoteFallback(completion: @escaping (Swift.Result<UserLoader, Error>)) {

        DispatchQueue.global().async {
            self.remoteUserSessionTokenLoader.load { result in
                switch result {
                case .success(let token):
                    let remoteURL = URL(string: "https://engineering.league.dev/challenge/api/users")!
                    let remoteUserLoader = RemoteUserLoader(url: remoteURL, client: self.httpClient) { return token }
                    let localUserLoader = LocalUserLoader(store: self.store, currentDate: Date.init)
                    let userLoader = UserLoaderWithFallbackComposite(primary: localUserLoader, fallback: remoteUserLoader)
                    completion(.success(userLoader))
                    //completion(.success(UserLoaderWithFallbackComposite(primary: localUserLoader, fallback: remoteUserLoader)))
                case .failure(let error):
                    //completion(.failure(error))
                }
            }
        }



//
//        let remoteURL = URL(string: "https://engineering.league.dev/challenge/api/users")!
//
//        let remoteUserLoader = RemoteUserLoader(url: remoteURL, client: httpClient) { [weak self] in
//            guard let self = self else { return "" }
//            DispatchQueue.global().async {
//                self.remoteUserSessionTokenLoader.load { result in
//                    self.unsecureAPIToken = try? result.get()
//                }
//            }
//        }
//        let localUserLoader = LocalUserLoader(store: store, currentDate: Date.init)
//
//        return UserLoaderWithFallbackComposite(primary: localUserLoader, fallback: remoteUserLoader)
    }

    private func makeLocalUserImageDataLoaderWithRemoteFallback() -> UserImageDataLoader {
        let remoteUserImageDataLoader = RemoteUserImageDataLoader(client: httpClient)
        let localUserImageDataLoader = LocalUserImageDataLoader(store: store)

        return UserImageDataLoaderWithFallbackComposite(primary: localUserImageDataLoader, fallback: remoteUserImageDataLoader)

    }

}
