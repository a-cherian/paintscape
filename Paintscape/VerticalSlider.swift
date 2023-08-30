//
//  VerticalSlider.swift
//
//  Created by Coder-256 on 8/23/16.
//  Copyright © 2016 Coder-256. All rights reserved.
//
// https://gist.github.com/Coder-256/01c6f8df7043bf7a2a7e100015a533c0

import UIKit

/// A view containing a vertically rotated UISlider.
class VerticalSlider: UIView {
    
    // MARK: Properties
    
    public internal(set) var slider : UISlider
    public var centerLocked : Bool = false {
        didSet {
            centerLockUpdate()
        }
    }
    private var centerWasLocked : Bool = false
    public var flexibleWidth : Bool = true {
        didSet {
            self.setNeedsLayout()
        }
    }
    var minimumValue: Float = Float(Int8.min) {
        didSet {
            slider.minimumValue = minimumValue
        }
    }
    var maximumValue: Float = Float(Int8.max) {
        didSet {
            slider.maximumValue = maximumValue
        }
    }
    var snapToInt: Bool = false
    private var oldValue : Float = 0
    public internal(set) var dragging : Bool = false
    
    /// Handler for value change.
    public var valueChanged: ((UISlider?) -> Void)?
    
    /// Handler for slider release.
    public var released:     ((UISlider?) -> Void)?
    
    // MARK: - Initialization
    
    required public init?(coder aDecoder: NSCoder) {
        // Init properties before super init because Swift (even though they are only defined in the subclass...)
        self.slider = UISlider()
        
        super.init(coder: aDecoder)
        continueInit()
    }
    
    public override init(frame: CGRect) {
        self.slider = UISlider()
        
        super.init(frame: frame)
        continueInit()
    }
    
    func continueInit() {
        self.backgroundColor = UIColor.clear
        
        slider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        slider.translatesAutoresizingMaskIntoConstraints = true
        addSubview(slider)
        slider.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        
        slider.addTarget(self,
                         action: #selector(sliderTouchStart(sender:)),
                         for: .touchDown)
        
        slider.addTarget(self,
                         action: #selector(sliderReleased(sender:)),
                         for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        slider.addTarget(self,
                         action: #selector(sliderValueChanged(sender:)),
                         for: .valueChanged)
        
        centerLockUpdate()
        
        slider.minimumValue = minimumValue
        slider.maximumValue = maximumValue
    }
    
    // MARK: - Methods
    
    override public func layoutSubviews() {
        slider.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        slider.bounds = CGRect(x: 0, y: 0, width: self.bounds.height, height: self.bounds.width)
        boundsDidChange()
    }
    
    private func boundsDidChange() {
        self.dragging = false
        if centerLocked {
            slider.value = 0
        }
    }
    
    @objc private func sliderReleased(sender: UISlider!) {
        self.dragging = false
        if centerLocked {
            slider.value = 0
        }
        
        self.released?(sender)
    }
    
    @objc private func sliderValueChanged(sender: UISlider!) {
        if snapToInt {
            //slider.value = Float(Int8(slider.value))
            slider.value = roundf(slider.value)
        }
        if slider.value == oldValue { return }
        oldValue = slider.value
        
        self.valueChanged?(sender)
    }
    
    @objc private func sliderTouchStart(sender: UISlider!) {
        self.dragging = true
    }
    
    internal func centerLockUpdate() {
        if centerWasLocked == centerLocked { return }
        centerWasLocked = centerLocked
        
        if centerLocked {
            slider.value = 0
        }
    }
    
}
