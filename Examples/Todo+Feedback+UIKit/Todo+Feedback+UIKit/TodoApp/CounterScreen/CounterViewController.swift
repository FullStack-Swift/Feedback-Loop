import UIKit
import Combine
import Feedback

final class CounterViewController: UIViewController {
  private let store: Store<CounterState, CounterAction>
  private let viewStore: ViewStore<CounterState, CounterAction>
  
  init(store: Store<CounterState, CounterAction>? = nil) {
    let unwrapStore = store ?? Store(initial: CounterState(), feedbacks: [], reducer: CounterReducer, dependency: ())
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private var cancellables: Set<AnyCancellable> = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    let decrementButton = UIButton(type: .system)
    decrementButton.setTitle("−", for: .normal)
    let countLabel = UILabel()
    countLabel.font = .monospacedDigitSystemFont(ofSize: 17, weight: .regular)
    let incrementButton = UIButton(type: .system)
    incrementButton.setTitle("+", for: .normal)
    let rootStackView = UIStackView(arrangedSubviews: [
      decrementButton,
      countLabel,
      incrementButton,
    ])
    rootStackView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(rootStackView)
    NSLayoutConstraint.activate([
      rootStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
      rootStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
    ])
    decrementButton.tapPublisher
      .map{CounterAction.decrement}
      .subscribe(viewStore.action)
      .store(in: &cancellables)
    incrementButton.tapPublisher
      .map{CounterAction.increment}
      .subscribe(viewStore.action)
      .store(in: &cancellables)
    viewStore.publisher
      .map { "\($0.count)" }
      .assign(to: \.text, on: countLabel)
      .store(in: &cancellables)
  }
}
