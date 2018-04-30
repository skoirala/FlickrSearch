import RxSwift
import RxCocoa

extension Reactive where Base: UISearchController {

    var isActive: Binder<Bool> {
        return Binder<Bool>(self.base) { searchController, active  in
            searchController.isActive = active
        }
    }
}
