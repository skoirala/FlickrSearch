import RxSwift
import  RxCocoa
import Action

protocol FlickrPhotoViewModelType {
    
    var router: Router { get }

    var searchRequest: FlickerSearchRequest { get }

    var disposeBag: DisposeBag { get }
    
    var nextPageTrigger: PublishRelay<()> { get }

    var model: Driver<[SectionItem<Photo>]> { get }

    var canLoadNextPage: Driver<Bool> { get }

    var isLoading: Driver<Bool> { get }

    var emptyResult: Driver<Bool> { get }

    var searchResultChanged: Driver<Bool> { get }

    var title: Driver<String> { get }

    func bind(nextPageTrigger: ControlEvent<Void>)

    func showPhotoView(at indexPath: IndexPath)
}

extension FlickrPhotoViewModelType {

    var model: Driver<[SectionItem<Photo>]> {
        return searchRequest.model
            .map { [SectionItem(model: "", items: $0)] }
    }

    var canLoadNextPage: Driver<Bool> {
        return searchRequest.canLoadNextPage
    }

    var isLoading: Driver<Bool> {
        return searchRequest.isLoading
    }

    var emptyResult: Driver<Bool> {
        return searchRequest.isResultEmpty
    }

    var searchResultChanged: Driver<Bool> {
        return searchRequest.isLoadingNewTarget
    }

    func bind(nextPageTrigger: ControlEvent<Void>) {
        nextPageTrigger.bind(to: self.nextPageTrigger)
            .disposed(by: disposeBag)
    }

    func showPhotoView(at indexPath: IndexPath) {
        router.showImageCollection(at: indexPath, with: searchRequest)
    }
}
