import UIKit
import RxSwift
import RxCocoa
import CHTCollectionViewWaterfallLayout

class FlickrPhotoSearchViewController<T: FlickrPhotoSearchViewModel>: BaseGalleryViewController<T> {

    private var searchViewController: UISearchController!

    override init(with viewModel: T) {

        super.init(with: viewModel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(views: [CHTCollectionElementKindSectionHeader: SearchBarSupplmentaryView.self])
        collectionViewLayout.headerHeight = 44.0
        collectionViewLayout.headerInset = UIEdgeInsets(top: 0,
                                                        left: 0,
                                                        bottom: 20,
                                                        right: 0)

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

        textSelected.map { _ in false }
            .bind(to: searchViewController.rx.isActive)
            .disposed(by: disposeBag)

        viewModel.bind(searchText: textSelected)

        let searchBar = searchViewController.searchBar

        searchBar.rx.searchChangedOnReturn
            .bind(to: textSelected)
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
