import UIKit
import RxSwift

class ImageViewerLoadingCell: UICollectionViewCell {

    private var loadingIndicator: UIActivityIndicatorView!

    override func prepareForReuse() {
        super.prepareForReuse()
        loadingIndicator.startAnimating()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.color = .white
        loadingIndicator.startAnimating()
        contentView.addSubview(loadingIndicator)

        NSLayoutConstraint.activate ([
            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ]
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
