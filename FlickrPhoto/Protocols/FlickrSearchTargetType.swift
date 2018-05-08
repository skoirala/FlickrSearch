import Foundation
import Moya

protocol  FlickrSearchTargetType: TargetType {
    var search: FlickrSearch { get }
    var page: UInt32 { get }
}
