import RxDataSources

struct SuggestionCategory {
    let title: String
    var items: [String]
}

extension SuggestionCategory: SectionModelType {

    init(original: SuggestionCategory, items: [String]) {
        self = original
        self.items = items
    }
}
