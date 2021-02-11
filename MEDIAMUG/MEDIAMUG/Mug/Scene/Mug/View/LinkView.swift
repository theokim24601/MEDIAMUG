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
//  @State var animate: Bool = true
//  var style = AStyle = .classic()

  var body: some View {
    VStack(spacing: 8) {
//      if viewModel.loading {
////        createLoadingView()
//      } else {
        if let url = viewModel.url {
          createThumbView()
          createNormalLinkView(url: url)
        }
//      }
    }.frame(width: width)
  }

//  func createLoadingView() -> some View {
//    AnimatedGradientView1()
////      HStack {
////        VStack {
////
//////          Spacer()
//////
//////          ScalingDotsIndicatorView()
//////            .frame(width: 60, height: 60)
//////            .foregroundColor(.red)
//////          Spacer()
////        }
//////          .scaledToFit()
//////        }
////      }
//    .frame(width: width, height: 200)
//    .background(Color.secondary.opacity(0.05))
//    .cornerRadius(5)
//  }

  func createThumbView() -> some View {
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
    .padding(.horizontal, 8)
  }

  func createNormalLinkView(url: URL) -> some View {
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
            .frame(width: width, height: image.size.height * width / image.size.width)
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

struct LinkView_Previews: PreviewProvider {
  static var previews: some View {
    LinkView(viewModel: LinkViewModel(title: "제목임당", image: UIImage(named: "bg_all")!), width: 320)
  }
}
