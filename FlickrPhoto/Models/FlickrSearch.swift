import Foundation

enum FlickrSearch {
    case userPhotos(PhotoOwner)
    case search(String)
    case userDetail(PhotoOwner)
}

extension FlickrSearch {

    var params: [String: String] {
        guard case .userDetail(_) = self else {
            return requestParams.merging(defaultParams) { $1 }
        }
        return requestParams
    }

    var path: String {
        return "services/rest"
    }

    var requestParams: [String: String] {
        switch self {
        case .search(let text):
            return ["text": text,
                    "method": "flickr.photos.search"]
        case .userPhotos(let owner):
            return ["user_id": owner.identifier,
                    "method": "flickr.photos.search"]
        case .userDetail(let owner):
            return ["user_id": owner.identifier,
                    "method": "flickr.people.getInfo"]
        }
    }

    var defaultParams: [String: String] {
        return [
            "extras": "url_sq,url_t,url_s,url_q,url_m,url_n,url_z,url_c,url_l,url_o,format,date_upload,owner_name",
            "per_page": "20"
        ]
    }
}
