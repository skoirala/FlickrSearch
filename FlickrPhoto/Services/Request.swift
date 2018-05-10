import RxSwift
import RxCocoa
import Action
import Moya

class Request<T: TargetType, M: EmptyValueType & Decodable>: RequestType {

    let disposeBag: DisposeBag

    let loadTrigger: Observable<T>
    let model: Driver<M>
    let isLoading: Driver<Bool>

    private let action: Action<T, M>

    init(loadTrigger: Observable<T>,
         enabledIf: Observable<Bool>) {
        self.loadTrigger = loadTrigger

        disposeBag = DisposeBag()

        let provider = MoyaProvider<T>(plugins: [NetworkLoggerPlugin()])

        let model = BehaviorRelay(value: M.emptyValue)

        self.model = model.asDriver()

        action = Action (enabledIf: enabledIf) { target in
            return provider.rx.request(target)
                .map(M.self)
        }

        action.elements
            .bind(to: model)
            .disposed(by: disposeBag)
        isLoading = action.executing
            .asDriver(onErrorJustReturn: false)

        loadTrigger.bind(to: action.inputs)
            .disposed(by: disposeBag)

    }
}
