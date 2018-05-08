import Foundation
import Moya

//enum SearchFlickrPhoto {
//    case search(String)
//    case user(String)
//}
//
//extension SearchFlickrPhoto: RxPaginationTargetType {
//    func next(after page: PageDetailType) -> SearchFlickrPhoto {
//        switch self {
//        case .search(let text, let page):
//            return .search(text, page + 1)
//        case .user(let username, let page):
//            return .user(text, page + 1)
//        }
//    }
//}
//
//extension SearchFlickrPhoto: TargetType {
//
//    var baseURL: URL {
//        return URL(string: "https://api.flickr.com")!
//    }
//
//    var path: String {
//        return "services/rest"
//    }
//
//    var method: Moya.Method {
//        return .get
//    }
//
//    var sampleData: Data {
//        return Data()
//    }
//
//    var task: Task {
//        return .requestParameters(parameters: params,
//                                  encoding: URLEncoding.default)
//    }
//
//    var params: [String: String] {
//        return defaultParams.merging(additionalParams) { $1 }
//    }
//
//    var headers: [String: String]? {
//        return nil
//    }
//
//    private var flickrMethod: String {
//        switch self {
//        case .search:
//            return "flickr.photos.search"
//        }
//    }
//
//    private var additionalParams: [String: String] {
//        switch self {
//        case .search(let text, let page, let userId):
//
//            if let userId = userId {
//                return [
//                    "page": "\(page)",
//                    "user_id": userId
//                ]
//            }
//
//            return [
//                "text": text,
//                "page": "\(page)"
//            ]
//        }
//    }
//
//    private var defaultParams: [String: String] {
//
//        precondition(App.apiKey != nil,
//                     "Api key not given, please put api key to continue using FlickrPhoto.")
//
//        return [
//            "extras": "url_sq,url_t,url_s,url_q,url_m,url_n,url_z,url_c,url_l,url_o,format,date_upload,owner_name",
//            "per_page": "20",
//            "api_key": App.apiKey,
//            "format": "json",
//            "nojsoncallback": "1",
//            "method": flickrMethod
//        ]
//    }
//}
