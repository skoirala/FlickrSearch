import UIKit
import RxSwift

class ImageCollectionViewCell: UICollectionViewCell {

    let imageView: UIImageView

    let progressView: DownloadProgressView

    var disposeBag: DisposeBag = DisposeBag()

    private let scrollView: UIScrollView

    override init(frame: CGRect) {
        scrollView = UIScrollView(frame: .zero)
        imageView = UIImageView(frame: .zero)
        progressView = DownloadProgressView(frame: .zero)
        super.init(frame: frame)
        createViews()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressView.progress = 0
        CATransaction.commit()

        progressView.isHidden = false
        disposeBag = DisposeBag()
    }

    func createViews() {

        scrollView.maximumZoomScale = 2.0
        scrollView.minimumZoomScale = 1.0
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self

        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(tapped))
        tap.numberOfTapsRequired = 2
        tap.identifier = zoomingScrollViewTapGestureRecognizer
        scrollView.addGestureRecognizer(tap)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)

        progressView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(progressView)
    }

    @objc func tapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let zoomRect = scrollView.zoomRectForScale(scale: scrollView.maximumZoomScale,
                                                   center: tapGestureRecognizer.location(in: scrollView))
        scrollView.zoom(to: zoomRect, animated: true)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: contentView.rightAnchor),

            imageView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            progressView.widthAnchor.constraint(equalTo: contentView.widthAnchor,
                                                multiplier: 0.5),
            progressView.widthAnchor.constraint(equalTo: progressView.heightAnchor),
            progressView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
    }
}

extension ImageCollectionViewCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
