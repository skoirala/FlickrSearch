import RxSwift
import RxCocoa

protocol RxPaginationRequestType: RxRequestType {

    associatedtype Page: PageDetailType
    var hasNextPage: Driver<Bool> { get }
    var currentPage: BehaviorRelay<PageDetail> { get }
}
