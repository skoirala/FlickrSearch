import UIKit

protocol ProgressiveDownloadView: class {
    var progress: CGFloat { get set }
}

extension DownloadProgressView: ProgressiveDownloadView { }
