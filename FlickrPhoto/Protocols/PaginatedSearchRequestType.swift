import RxSwift
import RxCocoa

protocol PaginatedSearchRequestType {
    var isLoading: Driver<Bool> { get }
    var hasNextPage: Driver<Bool> { get }
    var newSearchResultInitialPageLoaded: Driver<Bool> { get }
    var models: Driver<[Photo]> { get }

    var hasError: Driver<Bool> { get }
    var errorText: Driver<String> { get }

    var searchText: BehaviorRelay<String> { get }
    var nextPageTrigger: BehaviorRelay<()> { get }
}
