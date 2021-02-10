//
//  ClearButton.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/10.
//

import SwiftUI

struct ClearButton: ViewModifier {
  @Binding var text: String

  public func body(content: Content) -> some View {
    HStack {
      content
      Spacer()

      if !text.isEmpty {
        Button(
          action: {
            self.text = ""
          }) {
          Image(systemName: "delete.left")
            .foregroundColor(.secondary)
        }
        .padding(.trailing, 8)
      }
    }
  }
}
