//
//  CollectionViewCustomContentCell.swift
//  Alerts&Pickers
//
//  Created by Lex on 05.10.2018.
//  Copyright © 2018 Supreme Apps. All rights reserved.
//

import Foundation

import UIKit

public enum CollectionViewCustomContentCellSelectionElement: Int {
    case selectedCircle
    case unselectedCircle
    case selectedPoint
    
    public static let all: [CollectionViewCustomContentCellSelectionElement] = [.selectedCircle, .unselectedCircle, .selectedPoint]
}

public class CollectionViewCustomContentCell<CustomContentView: UIView>: UICollectionViewCell {
    
    lazy var customContentView: CustomContentView = {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFill
        $0.maskToBounds = true
        return $0
    }(CustomContentView())
    
    public typealias SelectionElement = CollectionViewCustomContentCellSelectionElement
    
    internal let inset: CGFloat = 6
    
    public var selectionSize: CGSize = CGSize(width: 28, height: 28) {
        didSet {
            self.setNeedsLayout()
            self.updateSelectionAppearance()
        }
    }
    
    public var selectionBorderWidth: CGFloat = 2.0 {
        didSet {
            self.setNeedsLayout()
            self.updateSelectionAppearance()
        }
    }
    
    public private(set) var selectionElements: [SelectionElement : UIView] = [:]
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public var showSelectionCircles: Bool = true {
        didSet {
            if showSelectionCircles != oldValue {
                updateSelectionAppearance()
            }
        }
    }
    
    public func setup() {
        backgroundColor = .clear
        
        for element in SelectionElement.all {
            self.selectionElements[element] = createSelectionElement(element)
        }
        
        let unselected: UIView = UIView()
        unselected.addSubview(customContentView)
        unselected.addSubview(selectionElementView(.unselectedCircle))
        backgroundView = unselected
        
        let selected: UIView = UIView()
        selected.addSubview(selectionElementView(.selectedCircle))
        selected.addSubview(selectionElementView(.selectedPoint))
        selectedBackgroundView = selected
    }
    
    private var proposedSelectionCircleSize: CGSize {
        var size = selectionSize
        size.width -= selectionBorderWidth * 2
        size.height -= selectionBorderWidth * 2
        return size
    }
    
    private func selectionElementView(_ element: SelectionElement) -> UIView {
        return self.selectionElements[element]!
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        customContentView.frame = contentView.bounds
        customContentView.cornerRadius = 12
        
        updateSelectionAppearance()
    }
    
    func updateSelectionAppearance() {
        updateSelectionAppearance(.unselectedCircle)
        updateSelectionAppearance(.selectedCircle)
        updateSelectionAppearance(.selectedPoint)
    }
    
    func createSelectionElement(_ element: SelectionElement) -> UIView {
        switch element {
        case .selectedCircle:
            return createView({
                $0.backgroundColor = .clear
                $0.borderWidth = 2
                $0.borderColor = .white
                $0.maskToBounds = false
            })
            
        case .selectedPoint:
            return createView({
                $0.backgroundColor = UIColor(hex: 0x007AFF)
            })
            
        case .unselectedCircle:
            return createView({
                $0.backgroundColor = .clear
                $0.borderWidth = 2
                $0.borderColor = .white
                $0.maskToBounds = false
            })
        }
    }
    
    func createView(_ block: (UIView) -> ()) -> UIView {
        let view = UIView()
        block(view)
        return view
    }
    
    func updateSelectionAppearance(_ element: SelectionElement) {
        switch element {
        case .selectedCircle: updateAppearance(forCircle: selectionElementView(.selectedCircle))
        case .unselectedCircle: updateAppearance(forCircle: selectionElementView(.unselectedCircle))
        case .selectedPoint: updateAppearance(forPoint: selectionElementView(.selectedPoint))
        }
    }
    
    public func centerPointForSelection() -> CGPoint {
        let x = customContentView.bounds.width - selectionSize.width / 2.0 - inset
        let y = inset + selectionSize.height / 2.0
        return CGPoint(x: x, y: y)
    }
    
    public func updateAllSelectionelementsLayout() {
        SelectionElement.all.forEach({updateSelectionLayout(element: $0)})
    }
    
    func updateSelectionLayout(element: SelectionElement) {
        let view = selectionElementView(element)
        view.frame.size = (element == .selectedPoint) ? proposedSelectionCircleSize : selectionSize
        view.center = centerPointForSelection()
    }
    
    func updateAppearance(forCircle view: UIView) {
        
        if view === selectionElementView(.selectedCircle) {
            self.updateSelectionLayout(element: .selectedCircle)
        }
        else if view === selectionElementView(.unselectedCircle) {
            self.updateSelectionLayout(element: .unselectedCircle)
        }
        
        view.center = centerPointForSelection()
        
        view.circleCorner = true
        view.shadowColor = UIColor.black.withAlphaComponent(0.4)
        view.shadowOffset = .zero
        view.shadowRadius = 4
        view.shadowOpacity = 0.2
        view.shadowPath = UIBezierPath(roundedRect: CGRect.init(origin: .zero, size: selectionSize),
                                       byRoundingCorners: .allCorners,
                                       cornerRadii: CGSize(width: selectionSize.width / 2, height: selectionSize.height / 2)).cgPath
        view.shadowShouldRasterize = true
        view.shadowRasterizationScale = UIScreen.main.scale
        view.isHidden = !showSelectionCircles
    }
    
    func updateAppearance(forPoint view: UIView) {
        
        updateSelectionLayout(element: .selectedPoint)
        
        view.circleCorner = true
        view.isHidden = !showSelectionCircles
    }
    
    override public func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        layoutIfNeeded()
    }
}
