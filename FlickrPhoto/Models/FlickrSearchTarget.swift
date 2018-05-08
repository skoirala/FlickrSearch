import Foundation
import Moya

struct FlickrSearchTarget: FlickrSearchTargetType {
    let search: FlickrSearch
    let page: UInt32

    static func text(_ text: String) -> FlickrSearchTarget {
        return FlickrSearchTarget(search: .search(text))
    }

    static func user(_ userId: String) -> FlickrSearchTarget {
        return FlickrSearchTarget(search: .userPhotos(userId))
    }

    init(search: FlickrSearch) {
        self.init(search: search,
                  page: 0)
    }

    private init(search: FlickrSearch, page: UInt32) {
        self.page = page
        self.search = search
    }

    func target(for page: UInt32) -> FlickrSearchTarget {
        return FlickrSearchTarget(search: search,
                                  page: page)
    }

    var baseURL: URL {
        return URL(string: "https://api.flickr.com")!
    }

    var path: String {
        return search.path
    }

    var method: Moya.Method {
        return .get
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        return .requestParameters(parameters: params,
                                  encoding: URLEncoding.default)
    }

    var params: [String: String] {
        return search.params
            .merging(["page": "\(page)", "api_key": App.apiKey]) { $1 }
    }

    var headers: [String: String]? {
        return nil
    }

    private var flickrMethod: String {
        return search.path
    }
}

extension FlickrSearchTarget: PaginationTargetType {
    func next(after page: PageDetailType) -> FlickrSearchTarget {
        return target(for: page.page + 1)
    }
}
