import UIKit

import RxSwift
import RxCocoa
import RxDataSources

class SearchSuggestionsViewController: UITableViewController {
    private let disposeBag = DisposeBag()

    private var viewModel: SuggestionsSearchViewModel!
    private var messageBackgroundView: UIView!

    init(viewModel: SuggestionsSearchViewModel) {
        self.viewModel = viewModel
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        setupViewModel()
    }

    func createViews() {
        tableView.dataSource = nil
        tableView.insetsContentViewsToSafeArea = false
        tableView.contentInsetAdjustmentBehavior = .never

        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        messageBackgroundView = UIView(frame: .zero)
        messageBackgroundView.backgroundColor = UIColor.groupTableViewBackground

        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.darkGray
        label.text = "No such category is defined locally.\n Press search button to search text from flickr"

        messageBackgroundView.addSubview(label)

        NSLayoutConstraint.activate (
            [label.centerXAnchor.constraint(equalTo: messageBackgroundView.centerXAnchor),
             label.centerYAnchor.constraint(equalTo: messageBackgroundView.centerYAnchor),
             label.leftAnchor.constraint(greaterThanOrEqualTo: messageBackgroundView.leftAnchor, constant: 20),
             label.rightAnchor.constraint(lessThanOrEqualTo: messageBackgroundView.rightAnchor, constant: -20)])

        tableView.backgroundView = messageBackgroundView
    }

    private func setupViewModel() {
        let dataSource = RxTableViewSectionedReloadDataSource<SuggestionCategory>(configureCell: configureCell)
        dataSource.titleForHeaderInSection = { dataSource, index in
            let category = dataSource.sectionModels[index]
            return category.title
        }

        viewModel.categoriesObservable
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        viewModel.isMessageHidden
            .drive(messageBackgroundView.rx.isHidden)
            .disposed(by: disposeBag)

        tableView.rx
            .modelSelected(String.self)
            .bind(to: viewModel.searchSelected)
            .disposed(by: disposeBag)
    }

    private func configureCell(dataSource: TableViewSectionedDataSource<SuggestionCategory>,
                               tableView: UITableView,
                               indexPath: IndexPath,
                               text: String) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.text = text
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        return cell
    }

}

extension SearchSuggestionsViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.lowercased() else {
            return
        }
        viewModel.searchTextChange.accept(text)
    }
}
