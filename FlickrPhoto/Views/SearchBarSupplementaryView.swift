import UIKit
import RxSwift

class SearchBarSupplmentaryView: UICollectionReusableView {

    var disposeBag = DisposeBag()

    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }

    var searchBar: UISearchBar? {
        didSet {
            guard let searchBar = searchBar else {
                return
            }

            if searchBar.superview != nil {
                searchBar.removeFromSuperview()
            }

            searchBar.barStyle = .black
            searchBar.barTintColor = .black
            searchBar.isTranslucent = true
            searchBar.tintColor = .white
            searchBar.sizeToFit()
            searchBar.placeholder = "Search in flickr"
            addSubview(searchBar)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
