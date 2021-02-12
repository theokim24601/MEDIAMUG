//
//  MugView.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/08.
//

import SwiftUI
import Combine
import WaterfallGrid
import ExytePopupView

public struct MugView: View {
  @ObservedObject var viewModel: MugViewModel

  public var body: some View {
    if isMac {
      return AnyView(createCatalystBody())
    } else {
      return AnyView(createIOSBody())
    }
  }
}

// MARK: - Shared
extension MugView {
  func createLogoItem() -> some View {
    Button(action: {
      viewModel.apply(.onAppear)
    }) {
      Image("icon")
        .imageScale(.large)
        .foregroundColor(.primary)
    }
  }

  func createRefreshButton() -> some View {
    Button(action: {
      viewModel.apply(.onAppear)
    }) {
      Image(systemName: "arrow.clockwise")
        .imageScale(.large)
        .foregroundColor(.primary)
    }
  }

  func getColumns(_ size: CGSize) -> Int {
    if isIphone {
      return 2
    } else if isIpad {
      return Int(max(size.width / 320, 3))
    } else {
      return Int(max(size.width / 320, 2))
    }
  }
}

// MARK: - iOS
extension MugView {
  func createIOSBody() -> some View {
    GeometryReader { geometry in
      NavigationView {
        VStack {
          createIOSGrid(geometry.size)
        }
        .navigationTitle("MEDIAMUG")
        .navigationBarItems(
          leading:
            HStack {
              createLogoItem()
            },
          trailing:
            HStack(spacing: 16) {
              createRefreshButton()
              createInputPopButton()
            }
        )
      }
      .navigationViewStyle(StackNavigationViewStyle())
      .onAppear(perform: { viewModel.apply(.onAppear) })
      .popup(isPresented: $viewModel.showInputPopup, type: .toast, position: .bottom, animation: .easeInOut(duration: 0.1), closeOnTap: false) {
        createNewLinkPopup(geometry.size)
      }
      .popup(isPresented: $viewModel.showClipboardToast, type: .floater(), position: .bottom, autohideIn: 10) {
        createClipToast(geometry.size)
      }
      .popup(isPresented: $viewModel.showError, type: .floater(), position: .bottom, autohideIn: 2) {
        createErrorToast(geometry.size)
      }
    }
    .edgesIgnoringSafeArea([.top, .bottom])
    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
      guard let clipString = UIPasteboard.general.string else { return }
      viewModel.apply(.copyClip(clipString))
    }
    .onReceive(NotificationCenter.default.publisher(for: .didAcceptRemoteChanges)) { _ in
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        viewModel.apply(.onAppear)
      }
    }
  }

  func createIOSGrid(_ size: CGSize) -> some View {
    ScrollView(.vertical, showsIndicators: false) {
      createIOSGridBody(size)
        .gridStyle(
          columns: getColumns(size),
          spacing: 16,
          animation: .easeInOut(duration: 0.5)
        )
        .padding(EdgeInsets(top: 32, leading: 8, bottom: 64, trailing: 8))
    }
  }

  func createIOSGridBody(_ size: CGSize) -> some View {
    if viewModel.dataSource.isEmpty {
      return AnyView(WaterfallGrid(0..<1, id:\.self) { _ in
        HStack(spacing: 8) {
          Text("Try adding\nyour first link")
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .font(Font.system(size: 15, weight: .medium))
            .foregroundColor(Color.secondary.opacity(0.8))

          Button(action: {
            viewModel.showInputPopup.toggle()
          }) {
            Image(systemName: "plus.circle")
              .imageScale(.large)
              .foregroundColor(.green)
          }
        }
        .frame(width: calculateIOSLinkViewWidth(size), height: 200)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(20)
      })
    } else {
      return AnyView(WaterfallGrid(viewModel.dataSource, id:\.self) { viewModel in
        LinkView(viewModel: viewModel, width: calculateIOSLinkViewWidth(size))
      })
    }
  }

  func createInputPopButton() -> some View {
    Button(action: {
      viewModel.showInputPopup.toggle()
    }) {
      Image(systemName: "square.and.pencil")
        .imageScale(.large)
        .foregroundColor(.primary)
    }
  }
  
  func createNewLinkPopup(_ size: CGSize) -> some View {
    ZStack {
      VStack {
        Spacer()
      }
      .frame(minWidth: 0,
             maxWidth: .infinity,
             minHeight: 0,
             maxHeight: .infinity)
      .background(Color.black.opacity(0.4))

      VStack(spacing: 8) {
        Text("New Link")
          .font(Font.system(size: 18, weight: .medium))
          .foregroundColor(.black)

        TextField("", text: $viewModel.newLink)
          .placeHolder(Text("Please enter the link")
                        .font(Font.system(size: 14, weight: .medium))
                        .foregroundColor(Color.gray.opacity(0.4)), text: $viewModel.newLink)
          .textContentType(.URL)
          .font(Font.system(size: 14, weight: .medium))
          .foregroundColor(.black)
          .modifier(ClearButton(text: $viewModel.newLink))
          .padding(.top, 8)

        if !viewModel.newLink.isEmpty {
          HStack {
            let validImage = Image(systemName: "checkmark.circle.fill")
              .imageScale(.large)
              .foregroundColor(.green)
            let validText = Text("Valid Link")
              .font(Font.system(size: 14, weight: .medium))
              .foregroundColor(.green)

            let invalidImage = Image(systemName: "xmark.circle.fill")
              .imageScale(.large)
              .foregroundColor(.red)
            let invalidText = Text("Invalid Link. check again")
              .font(Font.system(size: 14, weight: .medium))
              .foregroundColor(.red)

            viewModel.newLink.isValidLink ? validImage : invalidImage
            viewModel.newLink.isValidLink ? validText : invalidText
            Spacer()
          }
        }

        Button(action: {
          if let clipString = UIPasteboard.general.string {
            viewModel.newLink = clipString
          }
        }, label: {
          Label("Paste the clipboard", systemImage: "link")
            .font(Font.system(size: 14, weight: .medium))
            .lineLimit(1)
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 32, maxHeight: 32)
            .foregroundColor(Color.black.opacity(0.3))
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
        })
        .buttonStyle(ScaleEffectButtonStyle())
        .padding(.top, 8)

        HStack(spacing: 8) {
          Button(action: {
            viewModel.newLink = ""
            viewModel.showInputPopup.toggle()
          }, label: {
            Text("Close")
              .font(Font.system(size: 15, weight: .medium))
              .padding()
              .frame(minWidth: 0, maxWidth: .infinity, minHeight: 40, maxHeight: 40)
              .foregroundColor(.gray)
              .background(Color.white)
              .cornerRadius(5)
              .overlay(
                RoundedRectangle(cornerRadius: 5)
                  .stroke(Color.gray.opacity(0.4), lineWidth: 0.5)
              )
          }).buttonStyle(ScaleEffectButtonStyle())

          Button(action: {
            viewModel.apply(.newLink)
            viewModel.showInputPopup.toggle()
          }, label: {
            Text("Add")
              .font(Font.system(size: 15, weight: .medium))
              .padding()
              .frame(minWidth: 0, maxWidth: .infinity, minHeight: 40, maxHeight: 40)
              .foregroundColor(.white)
              .background(viewModel.newLink.isValidLink ? Color.blue : Color.gray)
              .cornerRadius(5)
          })
          .buttonStyle(ScaleEffectButtonStyle())
          .disabled(!viewModel.newLink.isValidLink)
        }
      }
      .padding(EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24))
      .frame(width: min(size.width - 48, 320))
      .background(Color.white)
      .cornerRadius(10.0)
      .shadow(color: .gray, radius: 1)
    }
  }

  func createClipToast(_ size: CGSize) -> some View {
    HStack {
      VStack {
        HStack {
          Text("Copied from the clipboard")
            .lineLimit(1)
            .font(Font.system(size: 13, weight: .medium))
            .foregroundColor(Color.black.opacity(0.8))
          Spacer()
        }
        HStack(spacing: 15) {
          Label(viewModel.clipString, systemImage: "link")
            .multilineTextAlignment(.leading)
            .lineLimit(1)
            .font(Font.system(size: 15, weight: .medium))
            .foregroundColor(.gray)
          Spacer()
        }
      }
      Button(action: {
        viewModel.apply(.newLinkFromClip)
      }) {
        Image(systemName: "plus.circle")
          .imageScale(.large)
          .foregroundColor(.green)
      }
    }
    .padding(EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24))
    .frame(width: min(size.width - 48, 520), height: 68)
    .background(Color.white)
    .cornerRadius(20.0)
    .shadow(color: Color.gray.opacity(0.4), radius: 10)
  }

  func createErrorToast(_ size: CGSize) -> some View {
    HStack(spacing: 15) {
      Text(viewModel.errorMessage)
        .multilineTextAlignment(.leading)
        .lineLimit(1)
        .font(Font.system(size: 15, weight: .medium))
        .foregroundColor(.gray)
      Spacer()
    }
    .padding(EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24))
    .frame(width: min(size.width - 48, 320), height: 52)
    .background(Color.white)
    .cornerRadius(26.0)
    .shadow(color: .gray, radius: 5)
  }

  func calculateIOSLinkViewWidth(_ size: CGSize) -> CGFloat {
    let columns = getColumns(size)
    let padding = CGFloat((columns - 1) * 16 + 16)
    return (size.width - padding) / CGFloat(columns)
  }
}

// MARK: - Catalyst
extension MugView {
  func createCatalystBody() -> some View {
    GeometryReader { geometry in
      NavigationView {
        VStack {
          createCatalystInput(geometry.size)
          createCatalystGrid(geometry.size)
        }
        .navigationTitle("MEDIAMUG")
        .navigationBarItems(
          leading:
            HStack {
              createLogoItem()
            },
          trailing:
            HStack(spacing: 16) {
              createRefreshButton()
            }
        )
      }
      .navigationViewStyle(StackNavigationViewStyle())
      .onAppear(perform: { viewModel.apply(.onAppear) })
    }
    .edgesIgnoringSafeArea([.top, .bottom])
    .onReceive(NotificationCenter.default.publisher(for: .didAcceptRemoteChanges)) { _ in
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        viewModel.apply(.onAppear)
      }
    }
//    .onReceive(NotificationCenter.default.publisher(for: Notification.Name(rawValue: "NSWindowDidBecomeMainNotification"))) { _ in
//      guard let clipString = UIPasteboard.general.string else { return }
//      viewModel.apply(.copyClip(clipString))
//    }
  }

  func createCatalystGrid(_ size: CGSize) -> some View {
    ScrollView(.vertical, showsIndicators: false) {
      WaterfallGrid(viewModel.dataSource, id:\.self) { viewModel in
        LinkView(viewModel: viewModel, width: calculateCatalystLinkViewWidth(size))
      }
      .gridStyle(
        columns: getColumns(size),
        spacing: 16,
        animation: .easeInOut(duration: 0.5)
      )
      .padding(EdgeInsets(top: 32, leading: 8, bottom: 64, trailing: 8))
    }
  }

  func createCatalystInput(_ size: CGSize) -> some View {
    HStack(alignment: .center) {
      Button(action: {
        if let clipString = UIPasteboard.general.string {
          viewModel.newLink = clipString
        }
      }, label: {
        Label("Paste the clipboard", systemImage: "link")
          .font(Font.system(size: 16, weight: .medium))
          .lineLimit(1)
          .padding()
          .frame(minHeight: 32, maxHeight: 32)
          .foregroundColor(Color.primary.opacity(0.6))
          .background(Color.secondary.opacity(0.1))
          .cornerRadius(16)
      })
      .buttonStyle(ScaleEffectButtonStyle())
      .padding(.vertical, 8)

      TextField("", text: $viewModel.newLink)
        .placeHolder(Text("Please enter the link")
                      .font(Font.system(size: 15, weight: .medium))
                      .foregroundColor(Color.secondary.opacity(0.6)), text: $viewModel.newLink)
        .textContentType(.URL)
        .font(Font.system(size: 16, weight: .medium))
        .foregroundColor(.primary)
        .modifier(ClearButton(text: $viewModel.newLink))

      Spacer()

      Button(action: {
        viewModel.apply(.newLink)
      }) {
        Image(systemName: "plus.circle")
          .imageScale(.large)
          .foregroundColor(viewModel.newLink.isValidLink ? .green : .gray)
      }.disabled(!viewModel.newLink.isValidLink)
    }
    .padding(EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24))
    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 48, maxHeight: 48)
  }

  func calculateCatalystLinkViewWidth(_ size: CGSize) -> CGFloat {
    return 312
  }
}

//struct TopicsView_Previews: PreviewProvider {
//  static var previews: some View {
//    MugView(viewModel: MugViewModel(mugService: MugMediaService(mug: MugRepository(context: Core))))
//  }
//}
