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
  @State var showingSheet = false

  var body: some View {
    VStack(spacing: 8) {
      if viewModel.fakeItem {
        Text("z")
      } else {
      if let url = viewModel.url {
        HStack(spacing: 8) {
          if let icon = viewModel.icon {
            Image(uiImage: icon)
              .resizable()
              .scaledToFit()
              .frame(height: 32)
          }
          Text(viewModel.host)
            .multilineTextAlignment(.leading)
            .font(Font.system(size: 14, weight: .medium))
            .foregroundColor(.secondary)
          Spacer()

          Button(action: {
            self.showingSheet = true
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
                  self.viewModel.deleteHandler?(self.viewModel.linkItem.id)
                },
                .default(Text("Copy Link")) {
                  UIPasteboard.general.string = viewModel.linkItem.urlString
                },
                .cancel(Text("Cancel"))])
          }
        }
        .padding(.horizontal, 8)

        Link(destination: url) {
          VStack(spacing: 8) {
//            if let videoUrl = viewModel.videoUrl {
//              let player = AVPlayer(url: videoUrl)
//              VideoPlayer(player: player)
//                .onAppear() {
//                  player.play()
//                }
//                .frame(width: 300, height: 300)
//                .resizable()
//                .scaledToFit()
//            }
            if let image = viewModel.image {
              Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 320, height: image.size.height * 320 / image.size.width)
                .cornerRadius(5)
            }
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
          .padding(.bottom, 8)
        }
      }
      }
    }
  }
}

struct LinkView_Previews: PreviewProvider {
  static var previews: some View {
    LinkView(viewModel: LinkViewModel(title: "제목임당", image: UIImage(named: "bg_all")!))
  }
}
