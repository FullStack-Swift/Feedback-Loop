import UIKit
import Combine

class MainTableViewCell: UITableViewCell {
  
  let image = UIImageView(image: UIImage(systemName: "square"))
  let titleView = UILabel()
  let deleteButton = UIButton(type: .system)
  let tapGesture = UITapGestureRecognizer()
  
  var cancellables: Set<AnyCancellable> = []
  
  override func prepareForReuse() {
    super.prepareForReuse()
    cancellables = []
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.isUserInteractionEnabled = false
    addGestureRecognizer(tapGesture)
    deleteButton.setTitle("Delete", for: .normal)
    deleteButton.setTitleColor(.gray, for: .normal)
    let rootStackView = UIStackView(arrangedSubviews: [
      image,
      titleView,
      deleteButton,
    ])
    image.tintColor = .black
    image.translatesAutoresizingMaskIntoConstraints = false
    image.heightAnchor.constraint(equalToConstant: 20).isActive = true
    image.widthAnchor.constraint(equalToConstant: 20).isActive = true
    rootStackView.alignment = .center
    rootStackView.spacing = 10
    rootStackView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(rootStackView)
    NSLayoutConstraint.activate([
      rootStackView.topAnchor.constraint(equalTo: topAnchor),
      rootStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
      rootStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      rootStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func bind(_ data: Any) {
    guard let data = data as? Todo else {
      return
    }
    image.image = data.isCompleted ? UIImage(systemName: "checkmark.square") : UIImage(systemName: "square")
    titleView.text = data.title
    
  }
  
}
