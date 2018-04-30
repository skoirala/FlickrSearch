import UIKit

protocol ProgressiveImageDownload: class {
    associatedtype ProgressView: ProgressiveDownloadView where ProgressView: UIView
    var progressView: ProgressView { get }
    var imageView: UIImageView { get }
}

extension ImageCollectionViewCell: ProgressiveImageDownload {}
