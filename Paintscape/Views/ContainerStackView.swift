//
//  ContainerStackView.swift
//  Paintscape
//
//  Created by AC on 8/30/23.
//

import UIKit

class ContainerStackView : UIStackView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, with: event)
        if result == self { return nil }
        return result
    }
}
