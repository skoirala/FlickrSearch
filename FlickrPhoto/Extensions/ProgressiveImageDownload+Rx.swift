import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: ProgressiveImageDownload {

    var progressImage: Binder<ProgressImage> {
        return Binder(self.base) { base, progressiveImage in
            switch progressiveImage {
            case let .image(image):
                UIView.animate(withDuration: 0.33) {
                    self.base.imageView.image = image
                    self.base.progressView.isHidden = true
                }
            case let .progress(fractionCompleted):
                self.base.progressView.isHidden = false
                self.base.progressView.progress = CGFloat(fractionCompleted)
            }
        }
    }
}
