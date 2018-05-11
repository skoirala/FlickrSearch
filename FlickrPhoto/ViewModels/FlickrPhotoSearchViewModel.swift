import RxSwift
import RxCocoa
import Moya
import Action
import RxDataSources

class FlickrPhotoSearchViewModel: FlickrPhotoViewModelType {

    func bind(searchText: PublishRelay<String>) {
        searchText.bind(to: self.searchText)
            .disposed(by: disposeBag)
    }

    let searchRequest: FlickerSearchRequest
    let disposeBag = DisposeBag()
    let router: Router
    let title: Driver<String>
    let nextPageTrigger: PublishRelay<()>

    private let searchText: PublishRelay<String>

    required init(search: FlickrSearchTarget,
                  router: Router) {
        self.router = router
        
        nextPageTrigger = PublishRelay()
        searchText = PublishRelay()

        // triggers event initially
        let searchTarget = BehaviorRelay<FlickrSearchTarget>(value: search)

        title = searchTarget.map { $0.contentTitle }
                    .asDriver(onErrorJustReturn: "")

        searchText.map { FlickrSearchTarget.text($0) }
            .bind(to: searchTarget)
            .disposed(by: disposeBag)

        searchRequest = FlickerSearchRequest(target: searchTarget,
                                             nextTrigger: nextPageTrigger)
    }
}
