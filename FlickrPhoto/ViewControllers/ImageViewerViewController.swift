import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Moya
import Action

class ImageViewerViewController: UICollectionViewController {

    private let viewModel: ImageViewerViewModel

    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionItem<LargeImageItem>>!
    private let publishRelay: PublishRelay<()>
    private let disposeBag = DisposeBag()

    private var uploadDateLabel: UILabel!
    private var userNameLabel: UIButton!
    private var closeButton: UIBarButtonItem!

    private var tapGestureRecognizer: UITapGestureRecognizer!

    init(with viewModel: ImageViewerViewModel) {
        self.viewModel = viewModel
        publishRelay = PublishRelay()

        let collectionViewLayout = ImageViewerCollectionFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.minimumLineSpacing = 20
        super.init(collectionViewLayout: collectionViewLayout)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupViewModel()
    }

    private func setupView() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                      action: #selector(tapped))
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.identifier = navigationBarHidingTapGestureIdentifier

        view.addGestureRecognizer(tapGestureRecognizer)
        collectionView!.dataSource = nil
        collectionView!.contentInsetAdjustmentBehavior = .never
        collectionView!.contentInset = .zero
        collectionView!.delegate = self
        collectionView!.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView!.register(cells: [ImageCollectionViewCell.self,
                                         ImageViewerLoadingCell.self])

        uploadDateLabel = UILabel(frame: .zero)
        uploadDateLabel.translatesAutoresizingMaskIntoConstraints = false
        uploadDateLabel.textColor = .white
        uploadDateLabel.font = UIFont.systemFont(ofSize: 12.0)

        userNameLabel = UIButton(frame: .zero)
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.titleLabel?.textColor = .white
        userNameLabel.titleLabel?.numberOfLines = 0
        userNameLabel.titleLabel?.lineBreakMode = .byWordWrapping
        userNameLabel.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        userNameLabel.addTarget(self,
                                action: #selector(userNameClicked),
                                for: .touchUpInside)

        view.addSubview(uploadDateLabel)
        view.addSubview(userNameLabel)

        NSLayoutConstraint.activate([
            uploadDateLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            view.bottomAnchor.constraint(equalTo: uploadDateLabel.bottomAnchor, constant: 40),

            userNameLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            uploadDateLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 4)
            ])
    }

    private func setupViewModel() {
        publishRelay.bind(to: viewModel.publishRelay)
            .disposed(by: disposeBag)

        dataSource = RxCollectionViewSectionedReloadDataSource(configureCell: configureCell)

        viewModel.models.drive(collectionView!.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        rx.viewWillAppear.subscribe(onNext: { [unowned self] in
            let indexPath = IndexPath(item: self.viewModel.selectedItemIndex,
                                      section: 0)
            self.collectionView?.scrollToItem(at: indexPath,
                                              at: .centeredHorizontally,
                                              animated: false)
            self.setAttributes(at: indexPath)
        }).disposed(by: disposeBag)
    }

    private func configureCell(dataSource: DataSourceType<LargeImageItem>,
                               collectionView: UICollectionView,
                               indexPath: IndexPath,
                               item: LargeImageItem) -> UICollectionViewCell {

        guard case .photo(let item) =  item else {
            return collectionView.dequeueCell(for: indexPath) as ImageViewerLoadingCell
        }

        let cell: ImageCollectionViewCell = collectionView.dequeueCell(for: indexPath)

        viewModel.progressiveImage(for: item)
            .drive(cell.rx.progressImage)
            .disposed(by: cell.disposeBag)
        return cell
    }

    @objc func tapped() {
        guard let navigationController = navigationController else {
            return
        }

        if navigationController.isNavigationBarHidden {
            navigationController.setNavigationBarHidden(false, animated: true)
            UIView.animate(withDuration: 0.25) {
                self.userNameLabel.alpha = 1
                self.uploadDateLabel.alpha = 1
            }
        } else {
            navigationController.setNavigationBarHidden(true, animated: true)
            UIView.animate(withDuration: 0.25) {
                self.userNameLabel.alpha = 0
                self.uploadDateLabel.alpha = 0
            }
        }
    }

    @objc func userNameClicked() {
        let targetOffset = collectionView!.contentOffset
        let bounds = collectionView!.bounds
        let targetCenter = CGPoint(x: targetOffset.x + bounds.width * 0.5,
                                   y: bounds.height * 0.5)

        guard let indexPath = collectionView?.indexPathForItem(at: targetCenter) else {
            return
        }

        guard let model = try? dataSource.model(at: indexPath),
            let photo = model as? LargeImageItem else {
                return
        }

        guard case .photo(let item) = photo else {
            return
        }

        viewModel.showUser(for: item)
    }

    func setAttributes(at indexPath: IndexPath) {
        guard let model = try? dataSource.model(at: indexPath),
            let photo = model as? LargeImageItem else {
                return
        }

        guard case .photo(let item) = photo else {
            return
        }

        let ownerName = item.ownerName
        userNameLabel.setTitle(ownerName, for: .normal)

        if let dateInterval = TimeInterval(item.dateUpload) {
            let date = Date(timeIntervalSince1970: dateInterval)
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            let string = formatter.string(from: date)
            uploadDateLabel.text = string
        }

        title = item.title
    }
}

// MARK: UICollectionViewDelegate
extension ImageViewerViewController: UICollectionViewDelegateFlowLayout {

    override func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                            withVelocity velocity: CGPoint,
                                            targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        let targetOffset = targetContentOffset.pointee
        let bounds = scrollView.bounds
        let targetCenter = CGPoint(x: targetOffset.x + bounds.width * 0.5,
                                   y: bounds.height * 0.5)

        guard let indexPath = collectionView?.indexPathForItem(at: targetCenter) else {
            return
        }

        setAttributes(at: indexPath)
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let model = try? dataSource.model(at: indexPath), let item = model as? LargeImageItem else {
            return
        }

        if case .loading = item {
            publishRelay.accept(())
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }

        var size = collectionView.bounds.size
        let sectionInset = flowLayout.sectionInset
        let contentInset = collectionView.contentInset
        size.width -=  sectionInset.left + sectionInset.right + contentInset.left + contentInset.right
        size.height -= sectionInset.top + sectionInset.bottom + contentInset.top + contentInset.bottom
        return view.bounds.size
    }
}

extension ImageViewerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        guard let tapGestureRecognizer = gestureRecognizer.identifier,
            let otherTapGestureRecognizer = otherGestureRecognizer.identifier else {
                return false
        }

        if tapGestureRecognizer == navigationBarHidingTapGestureIdentifier,
            otherTapGestureRecognizer == zoomingScrollViewTapGestureRecognizer {
            return true
        }

        return false
    }
}
