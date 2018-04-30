import RxSwift
import RxCocoa
import Moya

protocol RxRequestType {

    associatedtype RequestTarget: TargetType

    associatedtype Model: EmptyValueType & Decodable

    var loadTrigger: PublishRelay<RequestTarget> { get }

    var isLoading: Driver<Bool> { get }

    var model: Driver<Model> { get }
}
