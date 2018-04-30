import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {

     var viewWillAppear: ControlEvent<()> {
        let event = self.methodInvoked(#selector(Base.viewWillAppear(_:))).take(1).map { _ in () }
        return ControlEvent(events: event)

    }

}
