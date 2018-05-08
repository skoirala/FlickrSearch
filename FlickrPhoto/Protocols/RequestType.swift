import RxSwift
import RxCocoa
import Moya

protocol RequestType {

    associatedtype RequestTarget: TargetType

    associatedtype Model: EmptyValueType & Decodable

    var loadTrigger: Observable<RequestTarget> { get }

    var isLoading: Driver<Bool> { get }

    var model: Driver<Model> { get }
}
