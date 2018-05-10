import RxSwift
import RxCocoa
import Moya
import Action

class PaginationRequest<T: PaginationTargetType, M: Decodable & EmptyValueType, P: PageDetailType & EmptyValueType> {

    let page: BehaviorRelay<P>
    let disposeBag: DisposeBag
    
    let model: BehaviorRelay<M>

    let isLoadingNewTarget: Driver<Bool>
    let isLoading: Driver<Bool>
    let hasNextPage: Driver<Bool>

    let request: Request<T, M>

    enum PageOption {
        case new
        case nextPage
        case pageEnd
    }

    init(targetTrigger: BehaviorRelay<T>,
         nextPageTrigger: PublishRelay<()>,
         pageMapping: @escaping (M) -> P) {

        model = BehaviorRelay(value: .emptyValue)
        page = BehaviorRelay(value: .emptyValue)
        disposeBag = DisposeBag()

        let pageOptions = BehaviorSubject<PageOption>(value: .new)

        let sharedPageOptions = pageOptions.share(replay: 1,
                                                  scope: .forever)

        let enabled = sharedPageOptions.map { option -> Bool in
            switch option {
            case .new:
                return true
            case .nextPage:
                return true
            case .pageEnd:
                return false
            }
        }

        let sharedTarget = targetTrigger.share(replay: 1, scope: .forever)
        let sharedNextPageTrigger = nextPageTrigger.share(replay: 1, scope: .forever)

        sharedTarget.map { _ in P.emptyValue }
            .bind(to: page)
            .disposed(by: disposeBag)

        hasNextPage = page.map { pageDetail in
            pageDetail.pages > pageDetail.page
            }.asDriver(onErrorJustReturn: false)
            .startWith(false)

        hasNextPage.map { has in
            if has {
                return PageOption.nextPage
            }
            return PageOption.pageEnd
        }.drive(pageOptions)
        .disposed(by: disposeBag)

        sharedTarget.map { _ in PageOption.new }
            .bind(to: pageOptions)
            .disposed(by: disposeBag)

        let pageTarget = sharedTarget.withLatestFrom(page) { target, page in
            return target.next(after: page)
        }.share(replay: 1, scope: .forever)

        let nextPageTarget = sharedNextPageTrigger.withLatestFrom(targetTrigger)
            .withLatestFrom(page) { target, page in
                return target.next(after: page)
        }.share(replay: 1, scope: .forever)

        request = Request(loadTrigger: Observable.merge(pageTarget, nextPageTarget),
                          enabledIf:enabled)

        let elements = request.model

        elements.drive(model)
        .disposed(by: disposeBag)

        elements
            .map(pageMapping)
            .drive(page)
            .disposed(by: disposeBag)
        isLoading = request.isLoading

        isLoadingNewTarget = Observable.merge(targetTrigger.asObservable().map {_ in true },
                                              isLoading.asObservable().filter { $0 == false })
                                        .asDriver(onErrorJustReturn: false)
    }
}
