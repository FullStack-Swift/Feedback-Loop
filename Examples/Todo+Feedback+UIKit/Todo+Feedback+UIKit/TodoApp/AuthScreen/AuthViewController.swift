import UIKit
import SwiftUI
import Feedback
import CombineCocoa
import Combine

final class AuthViewController: UIViewController {
  private let store: Store<AuthState, AuthAction>
  
  private var viewStore: ViewStore<AuthState, AuthAction>
  
  init(store: Store<AuthState, AuthAction>? = nil) {
    let unwrapStore = store ?? Store(initial: AuthState(), feedbacks: [], reducer: AuthReducer, dependency: ())
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore)
    super.init(nibName: nil, bundle: nil)
  }
  
  private var cancellables: Set<AnyCancellable> = []
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let buttonLogin = UIButton(type: .system)
    buttonLogin.setTitle("Login", for: .normal)
    buttonLogin.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(buttonLogin)
    NSLayoutConstraint.activate([
      buttonLogin.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
      buttonLogin.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
    ])
    buttonLogin.tapPublisher
      .map{AuthAction.changeRootScreen(.main)}
      .subscribe(viewStore.action)
      .store(in: &cancellables)
  }
  
}
