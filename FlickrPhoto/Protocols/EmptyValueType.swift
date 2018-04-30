import Foundation

protocol EmptyValueType {
    static var emptyValue: Self { get }
}

extension Array: EmptyValueType {
    static var emptyValue: [Element] { return [] }
}
