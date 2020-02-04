//
//  PSClickWrapTextView.swift
//  
//
//  Created by Tim Morse on 2/4/20.
//

import UIKit

public class PSClickWrapTextView: UITextView {
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override public var contentSize: CGSize {
        didSet {
            isScrollEnabled = true
            var topCorrection = (bounds.size.height - contentSize.height * zoomScale) / 2.0
            topCorrection = max(0, topCorrection)
            contentInset = UIEdgeInsets(top: topCorrection, left: 0, bottom: 0, right: 0)
            
        }
    }
}
