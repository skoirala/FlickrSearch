import RxSwift
import RxCocoa
import Moya
import Action
import RxDataSources

class FlickrPhotoSearchViewModel: FlickrPhotoSearchViewModelType {

    func showPhotoView(at indexPath: IndexPath) {
        router.showImageCollection(at: indexPath, with: flickrSearchRequest)
    }

    var model: Driver<[SectionItem<Photo>]> {
        return flickrSearchRequest.models
            .map { [SectionItem(model: "", items: $0)] }
    }

    var canLoadNextPage: Driver<Bool> {
        return flickrSearchRequest.hasNextPage
    }

    var isLoading: Driver<Bool> {
        return flickrSearchRequest.isLoading
    }

    var errorText: Driver<String> {
        return flickrSearchRequest.errorText
    }

    var hasError: Driver<Bool> {
        return flickrSearchRequest.hasError
    }

    var searchResultChanged: Driver<Bool> {
        return flickrSearchRequest.newSearchResultInitialPageLoaded
    }

    func bind(searchText: BehaviorRelay<String>) {
        searchText.bind(to: flickrSearchRequest.searchText)
            .disposed(by: disposeBag)
    }

    func bind(nextPageTrigger: ControlEvent<Void>) {
        nextPageTrigger.bind(to: flickrSearchRequest.nextPageTrigger)
            .disposed(by: disposeBag)
    }

    let initialSearch: String
    let searchEnabled: Bool

    private let flickrSearchRequest: PaginatedSearchRequestType
    private let disposeBag = DisposeBag()
    private let router: Router

    required init(initialSearch: String,
                  router: Router,
                  flickrSearchRequest: PaginatedSearchRequestType,
                  searchEnabled: Bool) {
        self.initialSearch = initialSearch
        self.router = router
        self.flickrSearchRequest = flickrSearchRequest
        self.searchEnabled = searchEnabled
    }
}
