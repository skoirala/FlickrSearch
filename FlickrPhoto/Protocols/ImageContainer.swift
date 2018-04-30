import UIKit
import RxSwift
import RxCocoa

protocol ImageContainer: class {
    var imageView: UIImageView { get }
}

extension Reactive where Base: ImageContainer {
    var downloadedImage: Binder<ImageDownloadSource> {
        return Binder<ImageDownloadSource>(self.base) { imageContainer, imageSource in
            switch imageSource {
            case .cache(let image):
                imageContainer.imageView.image = image
            case .remote(let image):
                imageContainer.imageView.alpha = 0
                UIView.animate(withDuration: 0.5, animations: {
                    imageContainer.imageView.image = image
                    imageContainer.imageView.alpha = 1
                })
            }
        }
    }
}

extension PhotoCollectionViewCell: ImageContainer {}
