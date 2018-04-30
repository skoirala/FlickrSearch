import Foundation

struct PhotoResponse {
    let pageDetail: PageDetail
    let photos: [Photo]
    let stat: String
}

extension PhotoResponse: EmptyValueType {
    static var emptyValue: PhotoResponse {
        return PhotoResponse(pageDetail: PageDetail.emptyValue,
                             photos: [],
                             stat: "ok")
    }
}

extension PhotoResponse: Decodable {

    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootContainer.self)
        stat = try rootContainer.decode(String.self, forKey: .stat)
        let photosContainer = try rootContainer.nestedContainer(keyedBy: PhotoContainer.self,
                                                                forKey: .photos)
        let page = try photosContainer.decode(UInt32.self, forKey: .page)
        let pages = try photosContainer.decode(UInt32.self, forKey: .pages)
        let perpage = try photosContainer.decode(UInt32.self, forKey: .perpage)

        let totalPages: UInt32

        if let total = try? photosContainer.decode(UInt32.self,
                                                   forKey: .total) {
            totalPages = total
        } else if let totalString = try? photosContainer.decode(String.self,
                                                                forKey: .total),
            let total = UInt32(totalString) {
            totalPages = total
        } else {
            throw DecodingError.invalidDataType(key: "total")
        }

        try photos = photosContainer.decode([Photo].self, forKey: .photo)
        pageDetail = PageDetail(page: page,
                                pages: pages,
                                perpage: perpage,
                                total: totalPages)
    }

    enum RootContainer: CodingKey { case photos, stat }

    enum PhotoContainer: CodingKey { case page, pages, perpage, total, stat, photo }
}
