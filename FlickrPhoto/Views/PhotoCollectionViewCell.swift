import UIKit
import RxSwift

class PhotoCollectionViewCell: UICollectionViewCell {

    var disposeBag: DisposeBag! = DisposeBag()

    let imageView: UIImageView
    let activityIndicatorView: UIActivityIndicatorView

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        imageView.image = nil
    }

    override init(frame: CGRect) {
        imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)

        super.init(frame: frame)
        contentView.clipsToBounds = true
        createViews()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createViews() {
        backgroundColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.color = .white
        contentView.addSubview(activityIndicatorView)
    }

    private func setupConstraints() {
        let views: [String: Any] = ["imageView": imageView]
        ["H:|[imageView]|",
         "V:|[imageView]|"].forEach { format in
            let constraints = NSLayoutConstraint.constraints(withVisualFormat: format,
                                                             options: [],
                                                             metrics: nil,
                                                             views: views)
            contentView.addConstraints(constraints)
        }
        NSLayoutConstraint.activate(
            [activityIndicatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
             activityIndicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)])
    }
}
