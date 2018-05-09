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

        let owner = PhotoOwner(identifier: "68329145@N05",
                               name: "")

        let searchTarget: FlickrSearchTarget = .user(owner)

        let viewModel = FlickrPhotoSearchViewModel(search: searchTarget,
                                                   router: self,
                                                   searchEnabled: true)

        let rootViewController = FlickrPhotoSearchViewController(with: viewModel)
        navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.tintColor = .white
        navigationController.navigationBar.isTranslucent = true
        window.rootViewController = navigationController
    }

    func showImageCollection(at indexPath: IndexPath,
                             with searchResult: FlickerSearchRequest) {
        let viewModel = ImageViewerViewModel(router: self,
                                                 searchRequest: searchResult,
                                                 selectedItemIndex: indexPath.item)
        let imageCollectionViewController = ImageViewerViewController(with: viewModel)
        self.navigationController?.pushViewController(imageCollectionViewController, animated: true)
    }

    func showUser(photo: Photo) {

        let searchTarget: FlickrSearchTarget = .user(photo.owner)

        let viewModel = FlickrPhotoSearchViewModel(search: searchTarget,
                                                   router: self,
                                                   searchEnabled: false)
        let viewController = UserProfileViewController(with: viewModel)
        navigationController.pushViewController(viewController,
                                                animated: true)
    }
}
