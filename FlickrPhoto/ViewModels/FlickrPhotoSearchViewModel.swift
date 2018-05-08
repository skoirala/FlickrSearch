import RxSwift
import RxCocoa
import Moya
import Action
import RxDataSources

class FlickrPhotoSearchViewModel {

    enum ResultType {
        case reset
        case nextPage(PhotoResponse)
    }

    func showPhotoView(at indexPath: IndexPath) {
        router.showImageCollection(at: indexPath, with: searchRequest)
    }

    var model: Driver<[SectionItem<Photo>]> {
        return searchRequest.model
            .map { [SectionItem(model: "", items: $0)] }

    }

    var canLoadNextPage: Driver<Bool> {
        return searchRequest.canLoadNextPage.debug()
    }

    var isLoading: Driver<Bool> {
        return searchRequest.isLoading
    }

    var emptyResult: Driver<Bool> {
        return searchRequest.isResultEmpty
    }

    var searchResultChanged: Driver<Bool> {
        return searchRequest.isLoadingNewTarget
    }

    func bind(searchText: PublishRelay<String>) {
        searchText.bind(to: self.searchText)
            .disposed(by: disposeBag)
    }

    func bind(nextPageTrigger: ControlEvent<Void>) {
        nextPageTrigger.bind(to: self.nextPageTrigger)
            .disposed(by: disposeBag)
    }

    let searchRequest: FlickerSearchRequest

    let search: FlickrSearchTarget
    let searchEnabled: Bool

    private let disposeBag = DisposeBag()
    private let router: Router

    private let nextPageTrigger: PublishRelay<()>
    private let searchText: PublishRelay<String>

    required init(search: FlickrSearchTarget,
                  router: Router,
                  searchEnabled: Bool) {
        self.search = search
        self.router = router
        self.searchEnabled = searchEnabled

        nextPageTrigger = PublishRelay()
        searchText = PublishRelay()

        // triggers event initially
        let searchTarget = BehaviorRelay<FlickrSearchTarget>(value: search)

        searchText.map { FlickrSearchTarget.text($0) }
            .bind(to: searchTarget)
            .disposed(by: disposeBag)

        searchRequest = FlickerSearchRequest(target: searchTarget,
                                             nextTrigger: nextPageTrigger)
    }
}
