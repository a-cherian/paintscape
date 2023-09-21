//
//  LabelSlider.swift
//  Paintscape
//
//  Created by AC on 9/20/23.
//
// https://stackoverflow.com/a/45433974

import UIKit

// TO DO: make this actually display the label
class LabelSlider: UISlider {
    var thumbTextLabel: UILabel = UILabel()

    private var thumbFrame: CGRect {
        return thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        thumbTextLabel.frame = thumbFrame
        thumbTextLabel.text = Int(value).description
        thumbTextLabel.textColor = .black
        thumbTextLabel.layer.backgroundColor = UIColor.red.cgColor
        thumbTextLabel.center = CGPoint(x: thumbFrame.midX, y: thumbTextLabel.center.y)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(thumbTextLabel)
        thumbTextLabel.textAlignment = .center
        thumbTextLabel.textColor = .black
        thumbTextLabel.layer.zPosition = layer.zPosition + 1
    }
}
