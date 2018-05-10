import UIKit
import RxSwift
import RxCocoa
import Alamofire

enum ImageDownloadSource {
    case cache(UIImage), remote(UIImage)
}

enum ProgressImage {
    case progress(Float)
    case image(UIImage)
}

class ImageDownloader {

    static let shared = ImageDownloader()
    private init() {
        cache.countLimit = 50
        cache.totalCostLimit = 100
    }

    private let cache = NSCache<NSString, UIImage>()

    private let serialQueueScheduler = SerialDispatchQueueScheduler(qos: .default)

    func imageFor(_ urlString: String) -> Driver<ImageDownloadSource> {
        if let image = cache.object(forKey: urlString as NSString) {
            return Driver.just(.cache(image))
        }

        guard let url = URL(string: urlString as String) else {
            return Driver.just(.cache(UIImage()))
        }
        let request = URLRequest(url: url)
        return URLSession.shared.rx
            .data(request: request)
            .subscribeOn(serialQueueScheduler)
            .map { UIImage(data: $0) ?? UIImage() }
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] image in
                self?.cache.setObject(image,
                                     forKey: urlString as NSString)
            })
            .map { .remote($0) }
            .asDriver(onErrorJustReturn: .remote(UIImage()))
    }

    func imageWithProgress(_ urlString: String) -> Driver<ProgressImage> {
        if let image = cache.object(forKey: urlString as NSString) {
            return Driver.just(.image(image))
        }

        return Observable<ProgressImage>.create { observer -> Disposable in

            let task = Alamofire.request(urlString).downloadProgress { progress in
                    observer.onNext(.progress(Float(progress.fractionCompleted)))
                }.response { defaultResponse in

                    guard let data = defaultResponse.data,
                        let photo = UIImage(data: data) else {
                            observer.onCompleted()
                            return
                    }

                    observer.onNext(.image(photo))
                    observer.onCompleted()
            }

            return Disposables.create {
                task.cancel()
            }
            }.do(onNext: { [weak self] progressImage in
                if case .image(let image) = progressImage {
                    self?.cache.setObject(image,
                                         forKey: urlString as NSString)

                }
            }).asDriver(onErrorJustReturn: .image(UIImage()))

    }
}
