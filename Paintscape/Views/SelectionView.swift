//
//  SelectionView.swift
//  Paintscape
//
//  Created by AC on 9/21/23.
//

import UIKit

class SelectionView : UIView {
    var selection: UIImageView = UIImageView()
    var border: UIImageView = UIImageView()
    
    override init(frame: CGRect = CGRect()) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        addSubview(selection)
        addSubview(border)
        
        selection.layer.magnificationFilter = CALayerContentsFilter.nearest
        selection.translatesAutoresizingMaskIntoConstraints = false
        selection.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        
        border.layer.magnificationFilter = CALayerContentsFilter.nearest
        border.translatesAutoresizingMaskIntoConstraints = false
        border.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clearView() {
        selection.image = nil
        border.image = nil
    }
    
    func setImage(image: UIImage) {
        selection.image = image
        setBorder(width: image.size.width, height: image.size.height)
    }
    
    func setBorder(width: CGFloat, height: CGFloat) {
        border.image = UIImage(named: "border.png")?.scale(width: width, height: height)
    }
}
