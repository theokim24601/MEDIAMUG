//
//  SceneDelegate.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/09.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  lazy var contextProvider: CoreDataContextProvider = { CoreDataContextProvider() }()

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = UIHostingController(
        rootView: MugView(
          viewModel: MugViewModel(
            mugService: MugMediaService(
              mug: MugRepository(persistentContainer: contextProvider.persistentContainer)
            )
          )
        )
      )
      self.window = window
      window.makeKeyAndVisible()
    }
  }
}
