import UIKit

extension UICollectionView {

    func register(views: [String: UICollectionReusableView.Type]) {
        for (kind, view) in views {
            register(view,
                     forSupplementaryViewOfKind: kind,
                     withReuseIdentifier: view.reuseIdentifier)
        }
    }

    func register(cells: [UICollectionViewCell.Type]) {
        for type in cells {
            register(type, forCellWithReuseIdentifier: type.reuseIdentifier)
        }
    }

    func dequeueSupplementaryView<T: UICollectionReusableView>(kind: String,
                                                               for indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: kind,
                                                withReuseIdentifier: T.reuseIdentifier,
                                                for: indexPath) as! T
    }

    func dequeueCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}
