import RxSwift
import RxCocoa

class ImageViewerViewModel {

    let selectedItemIndex: Int

    let publishRelay: PublishRelay<()>
    let models: Driver<[SectionItem<LargeImageItem>]>

    private let disposeBag: DisposeBag
    private let router: Router
    private let searchRequest: PaginatedSearchRequestType

    init(router: Router,
         searchRequest: PaginatedSearchRequestType,
         selectedItemIndex: Int) {
        self.router = router
        self.searchRequest = searchRequest
        self.selectedItemIndex = selectedItemIndex

        disposeBag = DisposeBag()
        publishRelay = PublishRelay()
        publishRelay.bind(to: searchRequest.nextPageTrigger)
            .disposed(by: disposeBag)

        self.models = Driver.combineLatest(searchRequest.models, searchRequest.hasNextPage) { models, loading  in
            if loading {
                let items = models.map { LargeImageItem.photo($0) }
                let loadingItem = LargeImageItem.loading
                return items + [loadingItem]
            }
            return models.map { LargeImageItem.photo($0) }
            }.map { [SectionItem(model: "", items: $0)] }
    }

    func progressiveImage(for photo: Photo) -> Driver<ProgressImage> {
        guard let photoUrl = photo.photoURLs.last else {
            return Driver<ProgressImage>.empty()
        }
        return ImageDownloader.shared
            .imageWithProgress(photoUrl.url)
    }

    func showUser(for photo: Photo) {
        router.showUser(photo: photo, with: searchRequest)
    }
}
