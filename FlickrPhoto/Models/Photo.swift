import RxDataSources

struct Photo {
    let identifier: String
    let farm: Int
    let owner: String
    let server: String
    let title: String
    let ownerName: String
    let dateUpload: String

    let photoURLs: [PhotoURL]
}

struct PhotoURL {
    let width: Float
    let height: Float
    let url: String
}

// MARK: Decodable

enum PhotoDecodingError: Error {
    case invalidAttributeType(String)
}

extension Photo: Decodable {
    enum CodingKeys: String, CodingKey {
        case identifier = "id", farm, owner, server, title, ownerName = "ownername", dateupload
    }

    enum PhotoURLAttributeKeys: String, CodingKey {
        case heightC = "height_c", heightL = "height_l", heightM = "height_m", heightN = "height_n", heightQ = "height_q", heightS = "height_s", heightSq = "height_sq", heightT = "height_t", heightZ = "height_z",
            widthC = "width_c", widthL = "width_l", widthM = "width_m", widthN = "width_n", widthq = "width_q", widthS = "width_s", widthSq = "width_sq", widthT = "width_t", widthZ = "width_z",
            urlC = "url_c", urlL = "url_l", urlM = "url_m", urlN = "url_n", urlQ = "url_q", urlS = "url_s", urlSq = "url_sq", urlT = "url_t", urlZ = "url_z"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try identifier = container.decode(String.self, forKey: .identifier)
        try farm = container.decode(Int.self, forKey: .farm)
        try owner = container.decode(String.self, forKey: .owner)
        try server = container.decode(String.self, forKey: .server)
        try title = container.decode(String.self, forKey: .title)
        try ownerName = container.decode(String.self, forKey: .ownerName)
        try dateUpload = container.decode(String.self, forKey: .dateupload)

        let sizeTypes = ["c", "l", "m", "n", "q", "sq", "t", "z"]
        let photoUrlContainer = try decoder.container(keyedBy: PhotoURLAttributeKeys.self)

        try photoURLs = sizeTypes.reduce([]) { partial, sizeAttr in
            let heightRaw = "height_\(sizeAttr)"
            let widthRaw = "width_\(sizeAttr)"
            let urlRaw = "url_\(sizeAttr)"

            guard let heightAttr = PhotoURLAttributeKeys(rawValue: heightRaw),
                let widthAttr = PhotoURLAttributeKeys(rawValue: widthRaw),
                let urlAttr = PhotoURLAttributeKeys(rawValue: urlRaw) else {
                    throw PhotoDecodingError.invalidAttributeType("\(heightRaw), \(widthRaw), \(urlRaw)")
            }

            guard let url = try? photoUrlContainer.decode(String.self, forKey: urlAttr) else {
                return partial
            }

            let width: Float
            let height: Float

            if let widthValue = try? photoUrlContainer.decode(Float.self, forKey: widthAttr) {
                width = widthValue
            } else if let widthString = try? photoUrlContainer.decode(String.self, forKey: widthAttr),
                let widthValue = Float(widthString) {
                width = widthValue
            } else {
                throw PhotoDecodingError.invalidAttributeType(widthRaw)
            }

            if let heightValue = try? photoUrlContainer.decode(Float.self, forKey: heightAttr) {
                height = heightValue
            } else if let heightString = try? photoUrlContainer.decode(String.self, forKey: heightAttr),
                let heightValue = Float(heightString) {
                height = heightValue
            } else {
                throw PhotoDecodingError.invalidAttributeType(heightRaw)
            }

            return partial + [PhotoURL(width: width, height: height, url: url)]
            }.sorted(by: { url1, url2 in
                return url1.width < url2.width
            })
    }
}

extension Photo: IdentifiableType, Hashable, Equatable {

    typealias Identity = String

    var identity: String {
        return owner + server + "\(farm)"
    }

    var hashValue: Int {
        return identity.hashValue
    }

    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.identity == rhs.identity
    }
}
