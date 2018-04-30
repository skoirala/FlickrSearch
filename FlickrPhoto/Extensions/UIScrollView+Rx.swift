import RxSwift
import RxCocoa

extension Reactive where Base: UIScrollView {

    var reachedBottom: ControlEvent<Void> {
        let event = base.rx.observe(CGPoint.self, "contentOffset")
            .observeOn(MainScheduler.instance)
            .flatMap { [weak base] contentOffset -> Observable<Void> in
                guard let scrollView = base else {
                    return Observable.empty()
                }

                let visibleHeight = scrollView.frame.height
                    - scrollView.contentInset.top
                    - scrollView.contentInset.bottom
                let actualOffset = scrollView.contentOffset.y + scrollView.contentInset.top
                let threshold = max(0.0,
                                    scrollView.contentSize.height - visibleHeight)
                return actualOffset > threshold ? Observable.just(()) :
                    Observable.empty().throttle(1.0, scheduler: MainScheduler.instance)
        }
        return ControlEvent(events: event)
    }
}
