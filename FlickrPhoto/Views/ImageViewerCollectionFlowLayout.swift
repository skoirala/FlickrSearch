import UIKit

class ImageViewerCollectionFlowLayout: UICollectionViewFlowLayout {

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {

        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset,
                                             withScrollingVelocity: velocity)
        }

        let collectionViewSize = collectionView.bounds.size
        let proposedContentOffsetCenterX = proposedContentOffset.x + collectionViewSize.width * 0.5

        let proposedRect = CGRect(x: proposedContentOffset.x,
                                  y: 0,
                                  width: collectionViewSize.width,
                                  height: collectionViewSize.height)

        var candidateAttributes: UICollectionViewLayoutAttributes?

        for attributes in self.layoutAttributesForElements(in: proposedRect)! {
            if attributes.representedElementCategory != .cell {
                continue
            }

            let currentOffset = collectionView.contentOffset

            if (attributes.center.x <= (currentOffset.x + collectionViewSize.width * 0.5) && velocity.x > 0) || (attributes.center.x >= (currentOffset.x + collectionViewSize.width * 0.5) && velocity.x < 0) {
                continue
            }

            if candidateAttributes == nil {
                candidateAttributes = attributes
                continue
            }

            let lastCenterOffset = candidateAttributes!.center.x - proposedContentOffsetCenterX
            let centerOffset = attributes.center.x - proposedContentOffsetCenterX

            if fabsf( Float(centerOffset) ) < fabsf( Float(lastCenterOffset) ) {
                candidateAttributes = attributes
            }
        }

        if candidateAttributes != nil {
            return CGPoint(x: candidateAttributes!.center.x - candidateAttributes!.frame.width * 0.5,
                           y: proposedContentOffset.y)
        } else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
    }

}
