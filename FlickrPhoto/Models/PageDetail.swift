import Foundation

struct PageDetail: PageDetailType {
    let page: UInt32
    let pages: UInt32
    let perpage: UInt32
    let total: UInt32

}

extension PageDetail: EmptyValueType {
    static var emptyValue: PageDetail {
        return PageDetail(page: 0,
                          pages: 0,
                          perpage: 0,
                          total: 0)
    }

}
