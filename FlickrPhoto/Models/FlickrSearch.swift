import Foundation

enum FlickrSearch {
    case userPhotos(String)
    case search(String)
}

extension FlickrSearch {

    var params: [String: String] {
        return requestParams.merging(defaultParams) { $1 }
    }

    var path: String {
        return "services/rest"
    }

    var requestParams: [String: String] {
        switch self {
        case .search(let text):
            return ["text": text,
                    "method": "flickr.photos.search"]
        case .userPhotos(let userId):
            return ["user_id": userId,
                    "method": "flickr.photos.search"]
        }
    }

    var defaultParams: [String: String] {
        return [
            "extras": "url_sq,url_t,url_s,url_q,url_m,url_n,url_z,url_c,url_l,url_o,format,date_upload,owner_name",
            "per_page": "20",
            "format": "json",
            "nojsoncallback": "1"
        ]

    }
}
