import UIKit

public final class CollectionViewPhotoCell: CollectionViewCustomContentCell<UIImageView> {
    
    public var visibleArea: CGRect = .zero {
        didSet {
            guard visibleArea != oldValue else {
                return
            }
            updateAllSelectionelementsLayout()
        }
    }
    
    public override func centerPointForSelection() -> CGPoint {
        
        guard visibleArea != .zero else {
            return super.centerPointForSelection()
        }
        
        let frameInContent = convert(visibleArea, to: self.contentView)
        
        let minX = self.contentView.bounds.minX + selectionSize.width / 2.0 + inset
        let desiredX = frameInContent.maxX - selectionSize.width / 2.0 - inset
        let x = max(minX, desiredX)
        
        let y = self.contentView.bounds.minY + selectionSize.height / 2.0 + inset
        
        
        return CGPoint(x: x, y: y)
    }
    
}
