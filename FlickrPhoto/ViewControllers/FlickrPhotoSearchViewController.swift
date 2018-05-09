import UIKit
import RxSwift
import RxCocoa
import Moya
import RxDataSources
import CHTCollectionViewWaterfallLayout

class FlickrPhotoSearchViewController: BaseGalleryViewController {

    private let searchText: PublishRelay<String>!
    private var searchViewController: UISearchController!

    override init(with viewModel: FlickrPhotoSearchViewModel) {

        searchText = PublishRelay<String>()

        super.init(with: viewModel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if viewModel.searchEnabled {
            collectionView.register(views: [CHTCollectionElementKindSectionHeader: SearchBarSupplmentaryView.self])
            collectionViewLayout.headerHeight = 44.0
            collectionViewLayout.headerInset = UIEdgeInsets(top: 0,
                                                            left: 0,
                                                            bottom: 20,
                                                            right: 0)
        }

        definesPresentationContext = true

        let textSelected = PublishRelay<String>()
        let searchSuggestionViewModel = SuggestionsSearchViewModel(searchSelected: textSelected)

        let suggestionsViewController = SearchSuggestionsViewController(viewModel: searchSuggestionViewModel)
        searchViewController = UISearchController(searchResultsController: suggestionsViewController)
        searchViewController.searchResultsUpdater = suggestionsViewController
        searchViewController.searchBar.keyboardAppearance = .dark
        searchViewController.hidesNavigationBarDuringPresentation = true
        searchViewController.dimsBackgroundDuringPresentation = false
        collectionView.alwaysBounceVertical = true

        textSelected.bind(to: searchText)
            .disposed(by: disposeBag)
        textSelected.map { _ in false }
            .bind(to: searchViewController.rx.isActive)
            .disposed(by: disposeBag)

        viewModel.bind(searchText: searchText)

        let searchBar = searchViewController.searchBar

        searchBar.rx.searchChangedOnReturn
            .bind(to: searchText)
            .disposed(by: disposeBag)

        searchBar.rx.searchButtonClicked
            .map { _ in false }
            .bind(to: searchViewController.rx.isActive)
            .disposed(by: disposeBag)

        searchBar.rx.cancelButtonClicked
            .map { _ in false }
            .bind(to: searchViewController.rx.isActive)
            .disposed(by: disposeBag)

    }

    @objc
    override func createHeaderView(for collectionView: UICollectionView,
                                   at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView: SearchBarSupplmentaryView = collectionView.dequeueSupplementaryView(
            kind: CHTCollectionElementKindSectionHeader,
            for: indexPath
        )

        let searchbar = searchViewController.searchBar
        headerView.searchBar = searchbar

        return headerView
    }
}

class UserProfileViewController: BaseGalleryViewController {

    override init(with viewModel: FlickrPhotoSearchViewModel) {
        super.init(with: viewModel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let owner = PhotoOwner(identifier: "114796293@N07",
                               name: "")

//        let provider = MoyaProvider<FlickrSearchTarget>(plugins: [NetworkLoggerPlugin()])
//        provider.rx.request(.init(search: .userDetail(owner)))
//            .mapString()
//            .subscribe(onSuccess: { response in
//                print("Success \(response)")
//            }) { error in
//
//        }

    }
}
