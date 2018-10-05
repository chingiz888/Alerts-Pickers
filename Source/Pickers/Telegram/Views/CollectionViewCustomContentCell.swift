//
//  CollectionViewCustomContentCell.swift
//  Alerts&Pickers
//
//  Created by Lex on 05.10.2018.
//  Copyright © 2018 Supreme Apps. All rights reserved.
//

import Foundation

import UIKit

public final class CollectionViewCustomContentCell<CustomContentView: UIView>: UICollectionViewCell {
    
    lazy var customContentView: CustomContentView = {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFill
        $0.maskToBounds = true
        return $0
    }(CustomContentView())
    
    lazy var unselectedCircle: UIView = {
        $0.backgroundColor = .clear
        $0.borderWidth = 2
        $0.borderColor = .white
        $0.maskToBounds = false
        return $0
    }(UIView())
    
    lazy var selectedCircle: UIView = {
        $0.backgroundColor = .clear
        $0.borderWidth = 2
        $0.borderColor = .white
        $0.maskToBounds = false
        return $0
    }(UIView())
    
    lazy var selectedPoint: UIView = {
        $0.backgroundColor = UIColor(hex: 0x007AFF)
        return $0
    }(UIView())
    
    fileprivate let inset: CGFloat = 6
    
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
        
        let unselected: UIView = UIView()
        unselected.addSubview(customContentView)
        unselected.addSubview(unselectedCircle)
        backgroundView = unselected
        
        let selected: UIView = UIView()
        selected.addSubview(selectedCircle)
        selected.addSubview(selectedPoint)
        selectedBackgroundView = selected
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        customContentView.frame = contentView.bounds
        customContentView.cornerRadius = 12
        
        updateSelectionAppearance()
    }
    
    func updateSelectionAppearance() {
        updateAppearance(forCircle: unselectedCircle)
        updateAppearance(forCircle: selectedCircle)
        updateAppearance(forPoint: selectedPoint)
    }
    
    func updateAppearance(forCircle view: UIView) {
        view.frame.size = CGSize(width: 28, height: 28)
        view.frame.origin.x = customContentView.bounds.width - unselectedCircle.bounds.width - inset
        view.frame.origin.y = inset
        view.circleCorner = true
        view.shadowColor = UIColor.black.withAlphaComponent(0.4)
        view.shadowOffset = .zero
        view.shadowRadius = 4
        view.shadowOpacity = 0.2
        view.shadowPath = UIBezierPath(roundedRect: unselectedCircle.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: unselectedCircle.bounds.width / 2, height: unselectedCircle.bounds.width / 2)).cgPath
        view.shadowShouldRasterize = true
        view.shadowRasterizationScale = UIScreen.main.scale
        view.isHidden = !showSelectionCircles
    }
    
    func updateAppearance(forPoint view: UIView) {
        view.frame.size = CGSize(width: unselectedCircle.width - unselectedCircle.borderWidth * 2, height: unselectedCircle.height - unselectedCircle.borderWidth * 2)
        view.center = selectedCircle.center
        view.circleCorner = true
        view.isHidden = !showSelectionCircles
    }
    
    override public func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        layoutIfNeeded()
    }
}
