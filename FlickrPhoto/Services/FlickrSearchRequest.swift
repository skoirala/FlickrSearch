import RxSwift
import RxCocoa

class FlickerSearchRequest {

    let nextTrigger: PublishRelay<()>

    let searchRequest: PaginationRequest<FlickrSearchTarget, PhotoResponse, PageDetail>!
    enum ResultType {
        case reset
        case nextPage(PhotoResponse)
    }

    var isResultEmpty: Driver<Bool>

    var model: Driver<[Photo]>

    var canLoadNextPage: Driver<Bool> {
        return searchRequest.hasNextPage
    }

    var isLoading: Driver<Bool> {
        return searchRequest.isLoading
    }

    var isLoadingNewTarget: Driver<Bool> {
        return searchRequest.isLoadingNewTarget
    }

    var searchResultChanged: Driver<Bool> {
        return searchRequest.isLoadingNewTarget
    }

    init(target: BehaviorRelay<FlickrSearchTarget>,
         nextTrigger: PublishRelay<()>) {
        self.nextTrigger = nextTrigger

        searchRequest = PaginationRequest(targetTrigger: target,
                                          nextPageTrigger: nextTrigger) { photoResponse in
                                            photoResponse.pageDetail
        }

        model = Observable.merge( target.map { _ in ResultType.reset },
                                  searchRequest.model.map { ResultType.nextPage($0)})
            .scan([]) { partial, searchResult -> [Photo] in
                switch searchResult {
                case .nextPage(let photo):
                    return partial + photo.photos
                case .reset:
                    return []
                }
            }
            .asDriver(onErrorJustReturn: [])

        isResultEmpty = Driver.combineLatest(model, searchRequest.isLoading) { models, isLoading in
            return models.isEmpty && !isLoading
        }
    }
}
