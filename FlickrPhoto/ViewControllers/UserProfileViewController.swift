import Foundation

class UserProfileViewController<T: UserPhotosViewModel>: BaseGalleryViewController<T> {

    override init(with viewModel: T) {
        super.init(with: viewModel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
