import RxSwift
import RxCocoa
import Action
import Moya

class RxRequest<T: TargetType, M: EmptyValueType & Decodable>: RxRequestType {

    let disposeBag: DisposeBag

    let loadTrigger: PublishRelay<T>
    let model: Driver<M>
    let isLoading: Driver<Bool>

    private let action: Action<T, M>

    init(loadTrigger: PublishRelay<T>) {
        self.loadTrigger = loadTrigger

        disposeBag = DisposeBag()

        let provider = MoyaProvider<T>()

        let model = BehaviorRelay(value: M.emptyValue)

        self.model = model.asDriver()

        action = Action { target in
            return provider.rx.request(target)
                .map(M.self)
        }

        action.elements
            .bind(to: model)
            .disposed(by: disposeBag)

        isLoading = action.executing.asDriver(onErrorJustReturn: false)
    }
}
