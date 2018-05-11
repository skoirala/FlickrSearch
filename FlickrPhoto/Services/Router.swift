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

        let searchTarget: FlickrSearchTarget = .text("Wild")

        let viewModel = FlickrPhotoSearchViewModel(search: searchTarget,
                                                   router: self)

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
        let userViewModel = UserPhotosViewModel(owner: photo.owner,
                                                router: self)
        let viewController = UserProfileViewController(with: userViewModel)
        navigationController.pushViewController(viewController,
                                                animated: true)
    }
}
