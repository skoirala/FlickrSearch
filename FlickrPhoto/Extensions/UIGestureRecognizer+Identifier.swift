import UIKit

var tapGestureRecognizerIdentifierName = "com.flickrsearch.gestureRecognizer.identifier"

extension UIGestureRecognizer {
    var identifier: String? {
        set {
            objc_setAssociatedObject(self,
                                     &tapGestureRecognizerIdentifierName,
                                     newValue,
                                     .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &tapGestureRecognizerIdentifierName) as? String
        }
    }
}

let navigationBarHidingTapGestureIdentifier = "com.flickrsearch.navigationBarHiding.tapGestureRecognizer"
let zoomingScrollViewTapGestureRecognizer = "com.flickrsearch.scrollViewZoom.tapGestureRecognizer"
