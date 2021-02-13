//
//  AppDelegate.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/09.
//

import UIKit
import CoreData
import CloudKit

#if !targetEnvironment(macCatalyst)
import Firebase
import FirebaseCrashlytics
#endif


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    #if !targetEnvironment(macCatalyst)
    FirebaseApp.configure()
    Crashlytics.crashlytics()
    #endif
    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
}
