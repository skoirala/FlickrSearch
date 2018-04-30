import UIKit

extension UIScrollView {
    func zoomRectForScale(scale: CGFloat,
                          center: CGPoint) -> CGRect {
        guard let view = delegate?.viewForZooming!(in: self) else {
            return .zero
        }

        var zoomRect = CGRect.zero
        zoomRect.size.height = view.frame.size.height / scale
        zoomRect.size.width  = view.frame.size.width  / scale
        let newCenter =     convert(center, from: view)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
}
