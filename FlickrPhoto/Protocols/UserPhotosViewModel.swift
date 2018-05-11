import RxSwift
import RxCocoa
import Moya

class UserPhotosViewModel: FlickrPhotoViewModelType {

    let searchRequest: FlickerSearchRequest
    let title: Driver<String>
    let disposeBag = DisposeBag()
    let router: Router

    let nextPageTrigger: PublishRelay<()>

    required init(owner: PhotoOwner,
                  router: Router) {

        let search = FlickrSearchTarget.user(owner)
        self.router = router

        nextPageTrigger = PublishRelay()

        // triggers event initially
        let searchTarget = BehaviorRelay<FlickrSearchTarget>(value: search)

        title = searchTarget.map { $0.contentTitle }
            .asDriver(onErrorJustReturn: "")

        searchRequest = FlickerSearchRequest(target: searchTarget,
                                             nextTrigger: nextPageTrigger)

        let provider = MoyaProvider<FlickrSearchTarget>(plugins: [NetworkLoggerPlugin()])
        provider.rx.request(.init(search: .userDetail(owner))).map(User.self)
            .subscribe(onSuccess: { user in
                print("User: \(user)")
            }) { error in
                print("Error: \(error)")
        }

    }
}
