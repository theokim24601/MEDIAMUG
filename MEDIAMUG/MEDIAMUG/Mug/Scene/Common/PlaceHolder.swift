//
//  PlaceHolder.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/10.
//

import SwiftUI

struct PlaceHolder<T: View>: ViewModifier {
  var placeHolder: T
  @Binding var text: String
  func body(content: Content) -> some View {
    ZStack(alignment: .leading) {
      if text.isEmpty { placeHolder }
      content
    }
  }
}

extension View {
  func placeHolder<T:View>(_ holder: T, text: Binding<String>) -> some View {
    self.modifier(PlaceHolder(placeHolder:holder, text: text))
  }
}
