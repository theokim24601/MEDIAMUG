//
//  AppUtils.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/11.
//

import UIKit

enum Device {
  case iphone
  case ipad
  case mac
}

var isIphone: Bool {
  AppUtils.device() == .iphone
}

var isIpad: Bool {
  AppUtils.device() == .ipad
}

var isMac: Bool {
  AppUtils.device() == .mac
}

var isPortrait: Bool {
  AppUtils.isPortrait
}

struct AppUtils {
  static var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
  static var isPortrait : Bool { UIDevice.current.orientation.isPortrait }

  static func device() -> Device {
    if UIDevice.current.userInterfaceIdiom == .pad {
      #if targetEnvironment(macCatalyst)
      return .mac
      #else
      return .ipad
      #endif
    } else {
      return .iphone
    }
  }
}
