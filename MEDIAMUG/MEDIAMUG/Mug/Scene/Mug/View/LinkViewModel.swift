//
//  LinkViewModel.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/10.
//

import Combine
import LinkPresentation

class LinkViewModel: ObservableObject, Identifiable, Hashable {

  private var cancellables = Set<AnyCancellable>()

  // MARK: - Output
  @Published var loading: Bool = true

  @Published var icon: UIImage?
  @Published var host: String = ""
  @Published var videoUrl: URL?
  @Published var image: UIImage?
  @Published var title: String = ""
  @Published var dateString: String = ""

  @Published var url: URL?
  @Published var deleteHandler: ((String) -> Void)?

  private(set) var linkItem: LinkItem
  init(title: String, image: UIImage) {
    self.title = title
    self.image = image
    self.linkItem = LinkItem(urlString: "")
  }

  init(linkItem: LinkItem, deleteHandler: ((String) -> Void)?) {
    self.linkItem = linkItem
    self.deleteHandler = deleteHandler
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
    Timer.publish(every: 1, on: .main, in: .default)
      .autoconnect()
      .map { [weak self] _ in
        guard let linkItem = self?.linkItem else { return "" }
        let createdAt = linkItem.createdAt
        let now = Date()
        let timeDistance = createdAt.distance(to: now)
        let min_seconds: TimeInterval = 60
        let hour_seconds: TimeInterval = 3600
        let day_seconds: TimeInterval = 86400
        switch timeDistance {
        case (0..<min_seconds):
          return "just now"
        case (min_seconds..<(2 * min_seconds)):
          return "1 minute ago"
        case ((2 * min_seconds)..<(60 * min_seconds)):
          let minutes = (timeDistance / min_seconds).dateTime
          return "\(minutes) minutes ago"
        case (hour_seconds..<(2 * hour_seconds)):
          return "1 hour ago"
        case ((2 * hour_seconds)..<(24 * hour_seconds)):
          let hours = (timeDistance / hour_seconds).dateTime
          return "\(hours) hours ago"
        case (day_seconds..<(2 * day_seconds)):
          return "1 day ago"
        case ((2 * day_seconds)..<(7 * day_seconds)):
          let days = (timeDistance / day_seconds).dateTime
          return "\(days) days ago"
        default:
          let formatter = DateFormatter()
          formatter.formatterBehavior = .behavior10_4
          formatter.dateStyle = .long
          formatter.timeStyle = .none
          return formatter.string(from: createdAt)
        }
      }
      .receive(on: DispatchQueue.main)
      .assign(to: \.dateString, on: self)
      .store(in: &cancellables)
  }

  func loadMetadata() {
    guard let url = URL(string: linkItem.urlString) else {
      return
    }
    let metadataProvider = LPMetadataProvider()
    metadataProvider.startFetchingMetadata(for: url) { [weak self] (metadata, error) in
      guard let data = metadata, error == nil else {
        return
      }
      data.imageProvider?.loadObject(ofClass: UIImage.self) { image, error  in
        if let image = image as? UIImage {
          DispatchQueue.main.async {
            self?.image = image
          }
        }
      }
      data.iconProvider?.loadObject(ofClass: UIImage.self) { icon, error in
        if let icon = icon as? UIImage {
          DispatchQueue.main.async {
            self?.icon = icon
          }
        }
      }
      DispatchQueue.main.async {
        self?.url = data.url
        self?.host = data.url?.host ?? ""
        self?.title = data.title ?? ""
        self?.videoUrl = data.remoteVideoURL
//        self?.loading = false
      }
    }
  }
}
