//
//  LinkView.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/09.
//

import SwiftUI
import AVKit

struct LinkView: View {
  @StateObject var viewModel: LinkViewModel
  @State var width: CGFloat
  @State var showingSheet = false

  var body: some View {
    VStack {
      if isMac {
        createCatalystLink()
      } else {
        createIOSLink()
      }
    }.frame(width: width)
  }
}


// MARK: - iOS
extension LinkView {
  func createIOSLink() -> some View {
    VStack {
      if let url = viewModel.url {
        Link(destination: url) {
          VStack {
            createIOSMediaView()
            createThumbnailView()
            createTitleView()
          }
        }
        .contextMenu {
          createCopyButton()
          createDeleteButton()
        }
      }
    }
    .padding(.bottom, 8)
  }

  func createIOSMediaView() -> some View {
    HStack(spacing: 8) {
      Image(uiImage: viewModel.icon)
        .resizable()
        .scaledToFit()
        .frame(height: 32)

      Text(viewModel.host)
        .multilineTextAlignment(.leading)
        .font(Font.system(size: 14, weight: .medium))
        .foregroundColor(.secondary)
      Spacer()
    }
    .padding(.horizontal, 8)
  }
}

// MARK: - Catalyst
extension LinkView {
  func createCatalystLink() -> some View {
    VStack {
      if let url = viewModel.url {
        Link(destination: url) {
          VStack {
            createCatalystMediaView()
            createThumbnailView()
            createTitleView()
          }
        }
        .contextMenu {
          createCopyButton()
          createDeleteButton()
        }
      }
    }
    .padding(.bottom, 8)
  }

  func createCatalystMediaView() -> some View {
    HStack(spacing: 8) {
      Image(uiImage: viewModel.icon)
        .resizable()
        .scaledToFit()
        .frame(height: 32)

      Text(viewModel.host)
        .multilineTextAlignment(.leading)
        .font(Font.system(size: 14, weight: .medium))
        .foregroundColor(.secondary)
      Spacer()
    }
    .padding(.horizontal, 8)
  }
}

// MARK: - Shared
extension LinkView {
  func createThumbnailView() -> some View {
    Image(uiImage: viewModel.image)
      .resizable()
      .scaledToFit()
      .frame(width: width, height: viewModel.image.size.height * width / viewModel.image.size.width)
      .cornerRadius(5)
  }

  func createTitleView() -> some View {
    VStack(spacing: 4) {
      HStack {
        Text(viewModel.title)
          .multilineTextAlignment(.leading)
          .lineLimit(3)
          .font(Font.system(size: 18, weight: .bold))
          .foregroundColor(Color.primary)
        Spacer()
      }

      HStack(spacing: 8) {
        Text(viewModel.dateString)
          .multilineTextAlignment(.leading)
          .lineLimit(1)
          .font(Font.system(size: 13, weight: .medium))
          .foregroundColor(Color.secondary)
        Spacer()
      }
    }
    .padding(.horizontal, 8)
  }

  func createMoreButton() -> some View {
    Button(action: {
      showingSheet = true
    }) {
      Image(systemName: "ellipsis")
        .imageScale(.large)
        .foregroundColor(.secondary)
    }.actionSheet(isPresented: $showingSheet) {
      ActionSheet(
        title: Text("More"),
        message: nil,
        buttons: [
          .destructive(Text("Delete")) {
            viewModel.deleteHandler?(viewModel.linkItem.id)
          },
          .default(Text("Copy Link")) {
            UIPasteboard.general.string = viewModel.linkItem.urlString
          },
          .cancel(Text("Cancel"))])
    }
  }

  func createCopyButton() -> some View {
    Button(action: {
      UIPasteboard.general.string = viewModel.linkItem.urlString
    }) {
      Label("Copy", systemImage: "doc.on.doc")
    }
  }

  func createDeleteButton() -> some View {
    Button(action: {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        viewModel.deleteHandler?(viewModel.linkItem.id)
      }
    }) {
      Label("Delete", systemImage: "trash")
    }
  }
}

struct LinkView_Previews: PreviewProvider {
  static var previews: some View {
    LinkView(viewModel: LinkViewModel(title: "제목임당", image: UIImage(named: "bg_default")!), width: 320)
  }
}
