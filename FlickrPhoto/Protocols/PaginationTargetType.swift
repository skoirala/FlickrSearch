import Moya

protocol PaginationTargetType: TargetType {
    func next(after page: PageDetailType) -> Self
}
