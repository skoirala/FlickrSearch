import RxSwift
import RxCocoa
import Moya
import Action

class RxPaginationRequest<T: TargetType, M: EmptyValueType & Decodable>: RxPaginationRequestType {

    typealias Page = PageDetail

    let loadTrigger: PublishRelay<T>
    let resetPages: PublishRelay<()>

    let model: Driver<M>
    let isLoading: Driver<Bool>
    let hasNextPage: Driver<Bool>

    let currentPage: BehaviorRelay<PageDetail>

    private let disposeBag: DisposeBag
    private let action: Action<T, M>

    init(pageMapping: @escaping (M) -> Page) {

        resetPages = PublishRelay()
        loadTrigger = PublishRelay()

        disposeBag = DisposeBag()
        currentPage = BehaviorRelay(value: PageDetail.emptyValue)
        
        let provider = MoyaProvider<T>()
        let model = BehaviorRelay(value: M.emptyValue)
        self.model = model.asDriver()

        resetPages.map {_ in PageDetail.emptyValue }
            .bind(to: currentPage)
            .disposed(by: disposeBag)
        
        hasNextPage = currentPage.map { pageDetail in
            pageDetail.pages > pageDetail.page
            }.asDriver(onErrorJustReturn: false)
            .startWith(false)

        action = Action { target in
            return provider.rx.request(target)
                .map(M.self)
        }
        isLoading = action.executing.asDriver(onErrorJustReturn: false)

        action.elements
            .map(pageMapping)
            .bind(to: currentPage)
            .disposed(by: disposeBag)

        action.elements
            .bind(to: model)
            .disposed(by: disposeBag)

        loadTrigger
            .asObservable()
            .subscribe(action.inputs)
            .disposed(by: disposeBag)

    }
}
