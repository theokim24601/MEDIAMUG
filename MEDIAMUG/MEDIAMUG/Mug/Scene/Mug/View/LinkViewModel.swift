//
//  LinkViewModel.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/10.
//

import Foundation
import LinkPresentation

class LinkViewModel: ObservableObject, Identifiable, Hashable {

  @Published var dateString: String = ""
  @Published var title: String = ""
  @Published var host: String = ""
  @Published var image: UIImage?
  @Published var icon: UIImage?
  @Published var videoUrl: URL?
  @Published var url: URL?
  @Published var deleteHandler: ((String) -> Void)?
  @Published var fakeItem: Bool = true

  private(set) var linkItem: LinkItem
  init(title: String, image: UIImage) {
    self.title = title
    self.image = image
    self.linkItem = LinkItem(urlString: "")
  }

  init(linkItem: LinkItem, deleteHandler: ((String) -> Void)?) {
    self.linkItem = linkItem
    self.deleteHandler = deleteHandler

    if linkItem.urlString == "" {
      return
    }
    fakeItem.toggle()
    self.loadUpdateDate()
    self.loadMetadata()
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(linkItem.id)
  }

  static func == (lhs: LinkViewModel, rhs: LinkViewModel) -> Bool {
    lhs.linkItem.id == rhs.linkItem.id
  }
}

extension LinkViewModel {
  func loadUpdateDate() {
    dateString = linkItem.createdAt.stringYYYYMMDD(with: ". ")
  }

  func loadMetadata() {
    guard let url = URL(string: linkItem.urlString) else {
      self.url = URL(string: "https://apple.com")
      return
    }
    let metadataProvider = LPMetadataProvider()
    metadataProvider.startFetchingMetadata(for: url) { (metadata, error) in
      guard let data = metadata, error == nil else {
        return
      }
      data.imageProvider?.loadObject(ofClass: UIImage.self) { image, error  in
        if let image = image as? UIImage {
          DispatchQueue.main.async {
            self.image = image
          }
        }
      }
      data.iconProvider?.loadObject(ofClass: UIImage.self) { icon, error in
        if let icon = icon as? UIImage {
          DispatchQueue.main.async {
            self.icon = icon
          }
        }
      }
      DispatchQueue.main.async {
        self.url = data.url
        self.host = data.url?.host ?? ""
        self.title = data.title ?? ""
        self.videoUrl = data.remoteVideoURL
      }
    }
  }
}
