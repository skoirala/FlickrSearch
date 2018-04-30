import UIKit

import RxSwift
import RxCocoa

class Router {
    private weak var window: UIWindow!
    private var navigationController: UINavigationController!

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        Logging.URLRequests = { _ in
            return false
        }

        let paginationRequest = RxPaginationRequest<SearchFlickrPhoto, PhotoResponse> { photoResponse in
            return photoResponse.pageDetail
        }

        let searchResult = FlickerSearchRequest(paginationRequest: paginationRequest)
        let viewModel = FlickrPhotoSearchViewModel(initialSearch: "Wild Animals",
                                                   router: self,
                                                   flickrSearchRequest: searchResult,
                                                   searchEnabled: true)

        let rootViewController = FlickrPhotoSearchViewController(with: viewModel)
        navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.tintColor = .white
        navigationController.navigationBar.isTranslucent = true
        window.rootViewController = navigationController
    }

    func showImageCollection(at indexPath: IndexPath,
                             with searchResult: PaginatedSearchRequestType) {
        let viewModel = ImageViewerViewModel(router: self,
                                                 searchRequest: searchResult,
                                                 selectedItemIndex: indexPath.item)
        let imageCollectionViewController = ImageViewerViewController(with: viewModel)
        self.navigationController?.pushViewController(imageCollectionViewController, animated: true)
    }

    func showUser(photo: Photo,
                  with searchResult: PaginatedSearchRequestType) {
        let paginationRequest = RxPaginationRequest<SearchFlickrPhoto, PhotoResponse> { photoResponse in
            return photoResponse.pageDetail
        }

        let searchResult = FlickerSearchRequest(userId: photo.owner,
                                                paginationRequest: paginationRequest)
        let viewModel = FlickrPhotoSearchViewModel(initialSearch: photo.ownerName,
                                                   router: self,
                                                   flickrSearchRequest: searchResult,
                                                   searchEnabled: false)
        let viewController = FlickrPhotoSearchViewController(with: viewModel)
        navigationController.pushViewController(viewController,
                                                animated: true)
    }
}
