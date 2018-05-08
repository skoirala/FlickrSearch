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

    init(targetTrigger: BehaviorRelay<T>,
         nextPageTrigger: PublishRelay<()>,
         pageMapping: @escaping (M) -> P) {

        model = BehaviorRelay(value: .emptyValue)
        page = BehaviorRelay(value: .emptyValue)
        disposeBag = DisposeBag()

        targetTrigger.map { _ in P.emptyValue }
            .bind(to: page)
            .disposed(by: disposeBag)

        hasNextPage = page.map { pageDetail in
            pageDetail.pages > pageDetail.page
            }.asDriver(onErrorJustReturn: false)
            .startWith(false)

        let pageTarget = targetTrigger.withLatestFrom(page) { target, page in
            return target.next(after: page)
        }.share()

        let nextPageTarget = nextPageTrigger.withLatestFrom(targetTrigger)
            .withLatestFrom(page) { target, page in
                return target.next(after: page)
        }.share()

        request = Request(loadTrigger: Observable.merge(pageTarget, nextPageTarget))

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
