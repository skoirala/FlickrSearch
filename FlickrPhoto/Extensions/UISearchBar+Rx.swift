import RxSwift
import RxCocoa

extension Reactive where Base: UISearchBar {

    var searchChangedOnReturn: ControlEvent<String> {
        let source = Observable.deferred { [weak source = self.base as UISearchBar] () -> Observable<String> in
            return (source?.rx.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBarSearchButtonClicked(_:))) ?? Observable.empty())
                .map { a in
                    let searchBar = a[0] as? UISearchBar
                    return searchBar?.text ?? ""
            }
        }
        return ControlEvent(events: source)
    }
}
