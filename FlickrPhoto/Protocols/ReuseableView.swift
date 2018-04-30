import UIKit

protocol ReusableView {
    static var reuseIdentifier: String { get }
}

extension ReusableView where Self: UICollectionReusableView {
    static var reuseIdentifier: String {
        return self.description()
    }
}

extension UICollectionReusableView: ReusableView {}
