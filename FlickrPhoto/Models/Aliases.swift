import RxSwift
import RxDataSources

typealias SectionItem<T> = AnimatableSectionModel<String, T> where T: IdentifiableType, T: Equatable
typealias DataSourceType<T> = CollectionViewSectionedDataSource<SectionItem<T>> where T: IdentifiableType, T: Equatable
