import RxSwift
import RxCocoa

class FlickerSearchRequest: PaginatedSearchRequestType {

    let isLoading: Driver<Bool>
    let hasNextPage: Driver<Bool>
    let newSearchResultInitialPageLoaded: Driver<Bool>
    let errorText: Driver<String>
    let hasError: Driver<Bool>
    let models: Driver<[Photo]>

    let searchText: BehaviorRelay<String>
    let nextPageTrigger: BehaviorRelay<()>

    private let disposeBag: DisposeBag
    private let paginatedRequest: RxPaginationRequest<SearchFlickrPhoto, PhotoResponse>
    private let currentPage: BehaviorRelay<PageDetail>

    required init(userId: String? = nil,
                  paginationRequest: RxPaginationRequest<SearchFlickrPhoto, PhotoResponse>) {
        self.paginatedRequest = paginationRequest
        searchText = BehaviorRelay(value: "")
        nextPageTrigger = BehaviorRelay(value: ())

        let loading = BehaviorRelay(value: false)
        let hasNextPage = BehaviorRelay(value: false)
        let newSearchResultInitialPageLoaded = BehaviorRelay(value: false)

        self.isLoading = loading.asDriver()
        self.hasNextPage = hasNextPage.asDriver()
        self.newSearchResultInitialPageLoaded = newSearchResultInitialPageLoaded.asDriver()

        let resetPages = BehaviorRelay(value: ())
        disposeBag = DisposeBag()
        let models = BehaviorRelay<[Photo]>(value: [])
        self.models = models.asDriver()
        currentPage = BehaviorRelay(value: PageDetail.emptyValue)

        let currentPageDriver = currentPage.asDriver()

        let sharedSearchText = searchText.asDriver()
        let sharedNextPageTrigger = nextPageTrigger.asDriver()

        sharedSearchText.map { _ in () }
            .drive(resetPages)
            .disposed(by: disposeBag)
        
        let loadAction = sharedSearchText.withLatestFrom(currentPageDriver) { text, page in
            return SearchFlickrPhoto.search(text, page.page + 1, userId)
        }

        let pageTrigger = sharedNextPageTrigger.withLatestFrom(sharedSearchText)
            .withLatestFrom(currentPageDriver) { text, page in
            return SearchFlickrPhoto.search(text, page.page + 1, userId)
        }

        let paginationRequestDriver = Observable.merge(loadAction.asObservable().skip(1),
                                                       pageTrigger.asObservable().skip(1))

        resetPages.bind(to: paginatedRequest.resetPages)
        .disposed(by: disposeBag)

        paginationRequestDriver.bind(to: paginatedRequest.loadTrigger)
            .disposed(by: disposeBag)

        paginatedRequest.isLoading
            .drive(loading)
            .disposed(by: disposeBag)

        paginatedRequest.hasNextPage
            .drive(hasNextPage)
            .disposed(by: disposeBag)

        paginatedRequest.currentPage
            .bind(to: currentPage)
            .disposed(by: disposeBag)

        let elementsDriver = paginatedRequest.model.asDriver()

        elementsDriver.map { $0.pageDetail }
            .drive(currentPage)
            .disposed(by: disposeBag)

        let resultDriver = Driver.merge(elementsDriver.map { SearchResult.append($0.photos) },
                                        sharedSearchText.map { _ in SearchResult.reset })

        resultDriver.scan([]) { partial, searchResult in
            switch searchResult {
            case .append(let photos):
                return partial + photos
            case .reset:
                return []
            }
            }.drive(models)
            .disposed(by: disposeBag)

        self.errorText = Driver.combineLatest(models.asDriver(), elementsDriver, isLoading) { models, elements, loading in
            if elements.photos.count == 0 && elements.pageDetail.total == 0 && models.count == 0 && !loading {
                return "No images found"
            }
            return ""
        }

        self.hasError = Driver.combineLatest(models.asDriver(), elementsDriver, isLoading) { models, elements, loading in
            return elements.photos.count == 0 && elements.pageDetail.total == 0 && models.count == 0 && !loading
        }

        Driver.merge(models.map { _ in false }.asDriver(onErrorJustReturn: false),
                     sharedSearchText.map {_ in true })
            .drive(newSearchResultInitialPageLoaded)
            .disposed(by: disposeBag)

        hasError.map {_ in false }
            .drive(newSearchResultInitialPageLoaded)
            .disposed(by: disposeBag)
    }
}

private enum SearchResult {
    case append([Photo])
    case reset
}
