import Feedback
import SwiftUI
import UIKit
import Combine

final class RootViewController: UIViewController {

  private let store: Store<RootState, RootAction>
  
  private let viewStore: ViewStore<RootState, RootAction>
  
  init(store: Store<RootState, RootAction>? = nil) {
    let unwrapStore = store ?? Store(initial: RootState(), feedbacks: [RootFeedback.rootFeeback], reducer: RootReducer, dependency: ())
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private var cancellables: Set<AnyCancellable> = []
  
  private var viewController = UIViewController() {
    willSet {
      viewController.willMove(toParent: nil)
      viewController.view.removeFromSuperview()
      viewController.removeFromParent()
      addChild(newValue)
      newValue.view.frame = self.view.frame
      view.addSubview(newValue.view)
      newValue.didMove(toParent: self)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    viewStore.publisher.rootScreen.sink { [weak self] screen in
      guard let self = self else {return}
      switch screen {
      case .main:
        let vc = MainViewController(store: self.store.scope(state: \.mainState, action: RootAction.mainAction))
        let nav = UINavigationController(rootViewController: vc)
        self.viewController = nav
      case .auth:
        let vc = AuthViewController(store: self.store.scope(state: \.authState, action: RootAction.authAction))
        self.viewController = vc
      }
    }
    .store(in: &cancellables)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
}
