import Foundation

protocol PageDetailType {
    var page: UInt32 { get }
    var pages: UInt32 { get }
    var perpage: UInt32 { get }
    var total: UInt32 { get }
}
