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
        
        guard !visibleArea.isEmpty && !visibleArea.isNull else {
            return super.centerPointForSelection()
        }
        
        if visibleArea.debugDescription.contains("inf") {
            print("centering. \(visibleArea.debugDescription)")
        }
        
        let frameInContent = convert(visibleArea, to: self.contentView)
        
        let minX = self.contentView.bounds.minX + selectionSize.width / 2.0 + inset
        let desiredX = frameInContent.maxX - selectionSize.width / 2.0 - inset
        let x = max(minX, desiredX)
        
        let y = self.contentView.bounds.minY + selectionSize.height / 2.0 + inset
        
        let centerPoint = CGPoint(x: x, y: y)
        Log(centerPoint)
        return centerPoint
    }
    
}
