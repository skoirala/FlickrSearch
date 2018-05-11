import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import CHTCollectionViewWaterfallLayout

typealias GalleryViewController = UIViewController & UICollectionViewDelegate & CHTCollectionViewDelegateWaterfallLayout

class BaseGalleryViewController<T: FlickrPhotoViewModelType>: GalleryViewController {

    let viewModel: T!
    var collectionViewLayout: CHTCollectionViewWaterfallLayout!
    var collectionView: UICollectionView!

    let disposeBag = DisposeBag()

    private weak var dataSource: RxCollectionViewSectionedReloadDataSource<SectionItem<Photo>>!

    private var activityIndicatorView: UIActivityIndicatorView!
    private var errorView: UIView!
    private var errorLabel: UILabel!

    init(with viewModel: T) {
        self.viewModel = viewModel

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

    }

    private func setupViewModel() {
        viewModel.bind(nextPageTrigger: collectionView.rx.reachedBottom)

        let dataSource = RxCollectionViewSectionedReloadDataSource(configureCell: { [weak self] (dataSource: DataSourceType<Photo>, collectionView: UICollectionView, indexPath: IndexPath, photo: Photo) -> UICollectionViewCell in
            guard let strongSelf = self else { return UICollectionViewCell() }
            return strongSelf.configureCell(dataSource: dataSource,
                                            collectionView: collectionView,
                                            indexPath: indexPath,
                                            photo: photo)

        })

        dataSource.configureSupplementaryView = {[weak self] (dataSource: DataSourceType<Photo>,
                                                                collectionView: UICollectionView,
                                                                kind: String,
                                                                indexPath: IndexPath) -> UICollectionReusableView in
            guard let strongSelf = self else { return UICollectionReusableView() }
            return strongSelf.configureSupplementaryView(dataSource: dataSource,
                                                         collectionView: collectionView,
                                                         kind: kind,
                                                         indexPath: indexPath)

        }

        viewModel.model
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        self.dataSource = dataSource
    }

    private func setupView() {
        collectionView.delegate = self

        collectionView.register(cells: [PhotoCollectionViewCell.self])

        collectionView.register(views: [CHTCollectionElementKindSectionFooter: LoadingIndicatorSupplementaryView.self])
        collectionView.collectionViewLayout = self.collectionViewLayout
    }

    private func setupBindings() {

        viewModel.emptyResult
            .map { isEmpty in !isEmpty }
            .drive(errorView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.emptyResult
            .filter { $0 == true }
            .map { _ in "No results found" }
            .drive(errorLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.title.drive(rx.title)
            .disposed(by: disposeBag)

        viewModel.canLoadNextPage.asObservable().subscribe(onNext: { [weak self] shows in
            guard let strongSelf = self else { return }
            if shows {
                strongSelf.collectionViewLayout.footerHeight = 50
            } else {
                strongSelf.collectionViewLayout.footerHeight = 0
            }
        }).disposed(by: disposeBag)

        viewModel.searchResultChanged
            .drive(activityIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
    }
    
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

    func createHeaderView(for collectionView: UICollectionView,
                          at indexPath: IndexPath) -> UICollectionReusableView {
        fatalError("Not implemented base class should implement")
    }

    private func createFooterView(for collectionView: UICollectionView,
                                  at indexPath: IndexPath) -> UICollectionReusableView {
        let loadingView: LoadingIndicatorSupplementaryView = collectionView.dequeueSupplementaryView(kind: CHTCollectionElementKindSectionFooter, for: indexPath)
        return loadingView
    }
}

// MARK: Private methods

extension BaseGalleryViewController {

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

    private func showPhotoViewController(for photo: PhotoURL,
                                         at indexPath: IndexPath) {
        viewModel.showPhotoView(at: indexPath)
    }

}
