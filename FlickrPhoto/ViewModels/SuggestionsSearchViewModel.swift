import RxSwift
import RxCocoa

class SuggestionsSearchViewModel {

    let searchSelected: PublishRelay<String>
    let searchTextChange: PublishRelay<String>

    let categoriesObservable: Driver<[SuggestionCategory]>!

    let isMessageHidden: Driver<Bool>!

    init(searchSelected: PublishRelay<String>) {
        self.searchSelected = searchSelected
        searchTextChange = PublishRelay()

        let categories = Observable.of(SuggestionCategoriesFactory.categories)

        let text = searchTextChange.asObservable()

        categoriesObservable = Observable.combineLatest(categories, text) {($0, $1)}
            .observeOn(SerialDispatchQueueScheduler(qos: .default))

            .map { (args) -> [SuggestionCategory] in

                let (categories, text) = args

                return categories.reduce([]) { (partial: [SuggestionCategory], category: SuggestionCategory)  in
                    
                    if category.title.lowercased().contains(text) {
                        return partial + [category]
                    }

                    let items = category.items.filter { anItem in
                        anItem.lowercased().contains(text.lowercased())
                    }

                    guard !items.isEmpty else {
                        return partial
                    }

                    return partial + [SuggestionCategory(title: category.title,
                                                     items: items)]
                }
            }.asDriver(onErrorJustReturn: [])

        isMessageHidden = categoriesObservable.map { !$0.isEmpty }
    }
}
