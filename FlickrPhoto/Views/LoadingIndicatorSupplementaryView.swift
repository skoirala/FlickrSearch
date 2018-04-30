import UIKit

class LoadingIndicatorSupplementaryView: UICollectionReusableView {

    private var activityIndicatorView: UIActivityIndicatorView!

    override func prepareForReuse() {
        super.prepareForReuse()
        activityIndicatorView.startAnimating()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.color = .white
        addSubview(activityIndicatorView)

        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])

        activityIndicatorView.startAnimating()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
