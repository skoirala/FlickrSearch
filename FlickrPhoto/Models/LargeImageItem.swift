import Foundation
import RxDataSources

enum LargeImageItem {
    case photo(Photo)
    case loading
}

extension LargeImageItem: IdentifiableType {
    var identity: String {
        switch self {
        case .photo(let photo):
            return photo.identity
        case .loading:
            return "loading"
        }
    }
}

extension LargeImageItem: Equatable {
    static func == (lhs: LargeImageItem, rhs: LargeImageItem) -> Bool {
        switch (lhs, rhs) {
        case let (.photo(p1), .photo(p2)):
            return p1 == p2
        case (.loading, .loading):
            return true
        case (_, _): return false

        }
    }
}
