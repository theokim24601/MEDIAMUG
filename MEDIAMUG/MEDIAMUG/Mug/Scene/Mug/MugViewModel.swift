//
//  MugViewModel.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/08.
//

import SwiftUI
import Combine

final class MugViewModel: ObservableObject, Identifiable {

  private var cancellables = Set<AnyCancellable>()

  // MARK: - Input
  enum Input {
    case onAppear
    case newLink
    case newLinkFromClip
    case copyClip(String)
    case deleteLink(String)
  }

  func apply(_ input: Input) {
    switch input {
    case .onAppear: onAppearSubject.send(())
    case .newLink: newLinkSubject.send(newLink)
    case .newLinkFromClip: newLinkSubject.send(clipString)
    case .copyClip(let clipString): copyClipSubject.send(clipString)
    case .deleteLink(let linkId): deleteSubject.send(linkId)
    }
  }
  private let onAppearSubject = PassthroughSubject<Void, Never>()
  private let newLinkSubject = PassthroughSubject<String, Never>()
  private let copyClipSubject = PassthroughSubject<String, Never>()
  private let deleteSubject = PassthroughSubject<String, Never>()

  // MARK: - Output
  @Published var dataSource: [LinkViewModel] = []
  @Published var newLink = ""
  @Published var showError = false
  @Published var showInputPopup = false
  @Published var showClipboardToast = false
  var clipString = ""
  var errorMessage = ""

  private let responseSubject = PassthroughSubject<[LinkItem], Never>()
  private let errorSubject = PassthroughSubject<Error, Never>()
//  private let trackingSubject = PassthroughSubject<LogEvent, Never>()

  private let mugService: MugService
  init(
    mugService: MugService
  ) {
    self.mugService = mugService

    bindInputs()
    bindOutputs()
  }

  private func bindInputs() {
    let reloadPublisher = onAppearSubject
      .flatMap { [mugService] _ in
        mugService.getLinkItems()
          .catch { [weak self] error -> Empty<[LinkItem], Never> in
            self?.errorSubject.send(error)
            return .init()
          }
      }
      .share()

    let newLinkPublisher = newLinkSubject
      .flatMap { [mugService] urlString in
        mugService.addNewLink(urlString: urlString)
          .catch { [weak self] error -> Empty<[LinkItem], Never> in
            self?.errorSubject.send(error)
            return .init()
          }
      }
      .share()

    let deletePublisher = deleteSubject
      .flatMap { [mugService] id in
        mugService.deleteLink(id: id)
          .catch { [weak self] error -> Empty<[LinkItem], Never> in
            self?.errorSubject.send(error)
            return .init()
          }
      }
      .share()

    Publishers.Merge3(reloadPublisher, newLinkPublisher, deletePublisher)
      .subscribe(responseSubject)
      .store(in: &cancellables)

    copyClipSubject
      .handleEvents(receiveOutput: { [weak self] clipString in
        self?.clipString = clipString
      })
      .flatMap { [mugService] urlString in
        mugService.existLink(urlString: urlString)
          .map { !$0 && urlString.refineLink() != nil }
          .catch { [weak self] error -> Empty<Bool, Never> in
            self?.errorSubject.send(error)
            return .init()
          }
      }
      .receive(on: DispatchQueue.main)
      .assign(to: \.showClipboardToast, on: self)
      .store(in: &cancellables)

//    onAppearSubject
//      .map { .topics }
//      .subscribe(trackingSubject)
//      .store(in: &cancellables)
//
//    trackingSubject
//      .sink(receiveValue: loggingService.event)
//      .store(in: &cancellables)
  }

  private func bindOutputs() {
    responseSubject
      .map {
        $0.map { [weak self] linkItem in
          LinkViewModel(linkItem: linkItem, deleteHandler: self?.deleteHandler)
        }
      }
      .receive(on: DispatchQueue.main)
      .assign(to: \.dataSource, on: self)
      .store(in: &cancellables)

    newLinkSubject
      .map { _ in "" }
      .receive(on: DispatchQueue.main)
      .assign(to: \.newLink, on: self)
      .store(in: &cancellables)

    errorSubject
      .handleEvents(receiveOutput: { [weak self] error in
        self?.errorMessage = "유효한 링크가 아닙니다"
      })
      .map { _ in true }
      .assign(to: \.showError, on: self)
      .store(in: &cancellables)
  }

  func deleteHandler(linkId: String) {
    apply(.deleteLink(linkId))
  }
}
