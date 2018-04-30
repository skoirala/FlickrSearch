import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import CHTCollectionViewWaterfallLayout

class FlickrPhotoSearchViewController: UIViewController {

    private let  viewModel: FlickrPhotoSearchViewModelType!
    private let searchText: BehaviorRelay<String>!
    private let disposeBag = DisposeBag()
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionItem<Photo>>!

    private var collectionView: UICollectionView!
    private var activityIndicatorView: UIActivityIndicatorView!
    private var errorView: UIView!
    private var errorLabel: UILabel!

    private var collectionViewLayout: CHTCollectionViewWaterfallLayout!

    private var searchViewController: UISearchController!

    init(with viewModel: FlickrPhotoSearchViewModelType) {
        self.viewModel = viewModel
        searchText = BehaviorRelay<String>(value: viewModel.initialSearch)

        super.init(nibName: nil,
                   bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()

        setupViewModel()
        setupView()
        setupBindings()
    }

    private func createViews() {
        collectionViewLayout = CHTCollectionViewWaterfallLayout()

        if viewModel.searchEnabled {
            collectionViewLayout.headerHeight = 44.0
            collectionViewLayout.headerInset = UIEdgeInsets(top: 0,
                                                            left: 0,
                                                            bottom: 20,
                                                            right: 0)
        }

        collectionViewLayout.columnCount = 2
        collectionViewLayout.minimumColumnSpacing = 5
        collectionViewLayout.minimumInteritemSpacing = 5

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])

        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.color = .white
        view.addSubview(activityIndicatorView)

        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])

        errorView = UIView(frame: .zero)
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.isHidden = true

        errorLabel = UILabel(frame: .zero)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.numberOfLines = 0
        errorLabel.lineBreakMode = .byWordWrapping
        errorLabel.textColor = UIColor.darkGray
        errorLabel.text = ""

        errorView.addSubview(errorLabel)
        view.addSubview(errorView)

        NSLayoutConstraint.activate (
            [errorLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
             errorLabel.centerYAnchor.constraint(equalTo: errorView.centerYAnchor),
             errorLabel.leftAnchor.constraint(greaterThanOrEqualTo: errorView.leftAnchor, constant: 20),
             errorLabel.rightAnchor.constraint(lessThanOrEqualTo: errorView.rightAnchor, constant: -20)])

        NSLayoutConstraint.activate([
            errorView.leftAnchor.constraint(equalTo: view.leftAnchor),
            errorView.rightAnchor.constraint(equalTo: view.rightAnchor),
            errorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

        definesPresentationContext = true

        let textSelected = PublishRelay<String>()
        let searchSuggestionViewModel = SuggestionsSearchViewModel(searchSelected: textSelected)

        let suggestionsViewController = SearchSuggestionsViewController(viewModel: searchSuggestionViewModel)
        searchViewController = UISearchController(searchResultsController: suggestionsViewController)
        searchViewController.searchResultsUpdater = suggestionsViewController
        searchViewController.hidesNavigationBarDuringPresentation = true
        searchViewController.dimsBackgroundDuringPresentation = false
        collectionView.alwaysBounceVertical = true

        textSelected.bind(to: searchText)
                    .disposed(by: disposeBag)
        textSelected.map { _ in false }
            .bind(to: searchViewController.rx.isActive)
            .disposed(by: disposeBag)
    }

    private func setupViewModel() {
        viewModel.bind(searchText: searchText)
        viewModel.bind(nextPageTrigger: collectionView.rx.reachedBottom)

        dataSource = RxCollectionViewSectionedReloadDataSource(configureCell: configureCell)
        dataSource.configureSupplementaryView =  configureSupplementaryView

        viewModel.model
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    private func setupView() {
        collectionView.delegate = self

        collectionView.register(cells: [PhotoCollectionViewCell.self])

        var supplmentaryViews: [String: UICollectionReusableView.Type] = [
            CHTCollectionElementKindSectionFooter: LoadingIndicatorSupplementaryView.self
        ]

        if viewModel.searchEnabled {
            supplmentaryViews[CHTCollectionElementKindSectionHeader] = SearchBarSupplmentaryView.self
        }
        collectionView.register(views: supplmentaryViews)
        collectionView.collectionViewLayout = self.collectionViewLayout
    }

    private func setupBindings() {
        let searchBar = searchViewController.searchBar

        searchBar.rx.searchChangedOnReturn.bind(to: searchText)
            .disposed(by: disposeBag)

        searchBar.rx.searchButtonClicked
            .map { _ in false }
            .bind(to: searchViewController.rx.isActive)
            .disposed(by: disposeBag)

        searchBar.rx.cancelButtonClicked
            .map { _ in false }
            .bind(to: searchViewController.rx.isActive)
            .disposed(by: disposeBag)

        viewModel.hasError.map { has in !has }
            .drive(errorView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.errorText
            .drive(errorLabel.rx.text)
            .disposed(by: disposeBag)

        searchText.bind(to: rx.title)
            .disposed(by: disposeBag)

        viewModel.canLoadNextPage.asObservable().subscribe(onNext: { shows in
            if shows {
                self.collectionViewLayout.footerHeight = 50
            } else {
                self.collectionViewLayout.footerHeight = 0
            }
        }).disposed(by: disposeBag)

        viewModel.searchResultChanged
            .drive(activityIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
    }

}

// MARK: Private methods

extension FlickrPhotoSearchViewController {

    private func configureCell(dataSource: DataSourceType<Photo>,
                               collectionView: UICollectionView,
                               indexPath: IndexPath,
                               photo: Photo) -> UICollectionViewCell {

        let cell: PhotoCollectionViewCell = collectionView.dequeueCell(for: indexPath)

        if photo.photoURLs.isEmpty {
            return cell
        }

        guard let imageUrlString = photo.photoURLs.suffix(3).first?.url else {
            return cell
        }

        let imageDownload = ImageDownloader.shared.imageFor(imageUrlString)

        imageDownload.map { _ in false }
            .startWith(true)
            .drive(cell.activityIndicatorView.rx.isAnimating)
            .disposed(by: cell.disposeBag)

        imageDownload.drive(cell.rx.downloadedImage)
            .disposed(by: cell.disposeBag)
        return cell
    }

    private func configureSupplementaryView(dataSource: DataSourceType<Photo>,
                                            collectionView: UICollectionView,
                                            kind: String,
                                            indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case CHTCollectionElementKindSectionHeader:
            return createHeaderView(for: collectionView, at: indexPath)

        case CHTCollectionElementKindSectionFooter:
            return createFooterView(for: collectionView, at: indexPath)
        default:
            precondition(false, "No such kind of supplementary view exist \(kind)")
        }
        return createHeaderView(for: collectionView,
                                at: indexPath)
    }

    private func createHeaderView(for collectionView: UICollectionView,
                                  at indexPath: IndexPath) -> UICollectionReusableView {

        let headerView: SearchBarSupplmentaryView = collectionView.dequeueSupplementaryView(
            kind: CHTCollectionElementKindSectionHeader,
            for: indexPath
        )

        let searchbar = searchViewController.searchBar
        headerView.searchBar = searchbar

        return headerView
    }

    private func createFooterView(for collectionView: UICollectionView,
                                  at indexPath: IndexPath) -> UICollectionReusableView {
        let loadingView: LoadingIndicatorSupplementaryView = collectionView.dequeueSupplementaryView(kind: CHTCollectionElementKindSectionFooter, for: indexPath)
        return loadingView
    }

    private func showPhotoViewController(for photo: PhotoURL,
                                         at indexPath: IndexPath) {
        viewModel.showPhotoView(at: indexPath)
    }
}

// MARK: UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout
extension FlickrPhotoSearchViewController: UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout {

    func collectionView(_ collectionView: UICollectionView!,
                        layout collectionViewLayout: UICollectionViewLayout!,
                        sizeForItemAt indexPath: IndexPath!) -> CGSize {
        guard let model = try? dataSource.model(at: indexPath),
            let photoModel = model as? Photo,
            let size = photoModel.photoURLs.suffix(3).first else {
                return .zero
        }
        return CGSize(width: CGFloat(size.width), height: CGFloat(size.height))
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard let model = try? dataSource.model(at: indexPath),
            let photo = model as? Photo,
            let photoURL = photo.photoURLs.last else {
                return
        }

        showPhotoViewController(for: photoURL,
                                at: indexPath)
    }
}
