//
//  InputAlert.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/10.
//

import SwiftUI
import Combine

class InputAlertController: UIViewController {

  @Binding private var text: String
  private let alertTitle: String
  private var message: String?
  private var completion: () -> Void
  private var isPresented: Binding<Bool>?
  private var cancellable: AnyCancellable?

  init(title: String, message: String?, text: Binding<String>, completion: @escaping () -> Void, isPresented: Binding<Bool>?) {
    self.alertTitle = title
    self.message = message
    self._text = text
    self.completion = completion
    self.isPresented = isPresented
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }


  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    presentAlertController()
  }

  private func presentAlertController() {
    guard cancellable == nil else { return }

    let vc = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
    vc.addTextField { [weak self] textField in
      guard let self = self else { return }
      self.cancellable = NotificationCenter.default
        .publisher(for: UITextField.textDidChangeNotification, object: textField)
        .map { ($0.object as? UITextField)?.text ?? "" }
        .assign(to: \.text, on: self)
    }
    let cancelAction = UIAlertAction(title: "취소", style: .cancel) { [weak self] _ in
      self?.isPresented?.wrappedValue = false
    }
    let addAction = UIAlertAction(title: "추가하기", style: .default) { [weak self] _ in
      self?.completion()
      self?.isPresented?.wrappedValue = false
    }
    vc.addAction(cancelAction)
    vc.addAction(addAction)
    present(vc, animated: true, completion: nil)
  }
}

struct InputAlert {
  let title: String
  let message: String?
  @Binding var text: String
  var completion: () -> Void
  var isPresented: Binding<Bool>? = nil

  func dismissable(_ isPresented: Binding<Bool>) -> InputAlert {
    InputAlert(title: title, message: message, text: $text, completion: completion, isPresented: isPresented)
  }
}

extension InputAlert: UIViewControllerRepresentable {

  typealias UIViewControllerType = InputAlertController

  func makeUIViewController(context: UIViewControllerRepresentableContext<InputAlert>) -> UIViewControllerType {
    InputAlertController(title: title, message: message, text: $text, completion: completion, isPresented: isPresented)
  }

  func updateUIViewController(_ uiViewController: UIViewControllerType,
                              context: UIViewControllerRepresentableContext<InputAlert>) {
    // no update needed
  }
}

struct InputAlertWrapper<PresentingView: View>: View {
  @Binding var isPresented: Bool
  let presentingView: PresentingView
  let content: () -> InputAlert

  var body: some View {
    ZStack {
      if (isPresented) { content().dismissable($isPresented) }
      presentingView
    }
  }
}

extension View {
  func inputAlert(
    isPresented: Binding<Bool>,
    content: @escaping () -> InputAlert
  ) -> some View {
    InputAlertWrapper(
      isPresented: isPresented,
      presentingView: self,
      content: content
    )
  }
}
