import RxSwift
import  RxCocoa
import Action

protocol FlickrPhotoSearchViewModelType {

    var initialSearch: String { get }
    var searchEnabled: Bool { get }
    
    func bind(searchText: BehaviorRelay<String>)
    func bind(nextPageTrigger: ControlEvent<Void>) 
    func showPhotoView(at indexPath: IndexPath)

    var errorText: Driver<String> { get }
    var hasError: Driver<Bool> { get }

    var model: Driver<[SectionItem<Photo>]> { get }
    var canLoadNextPage: Driver<Bool> { get }
    var isLoading: Driver<Bool> { get }
    var searchResultChanged: Driver<Bool> { get }
}
