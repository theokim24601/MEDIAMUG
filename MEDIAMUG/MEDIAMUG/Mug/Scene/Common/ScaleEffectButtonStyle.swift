//
//  ScaleEffectButtonStyle.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/10.
//

import SwiftUI

struct ScaleEffectButtonStyle: ButtonStyle {
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
      .animation(.spring(response: 0.2, blendDuration: 0.2))
  }
}
