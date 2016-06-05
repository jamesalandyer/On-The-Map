//
//  CustomButton.swift
//  On The Map
//
//  Created by James Dyer on 6/4/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import UIKit

@IBDesignable
class CustomButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 10.0 {
        didSet{
            setUpView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setTitleColor(.lightGrayColor(), forState: .Highlighted)
        setUpView()
    }
    
    private func setUpView() {
        layer.cornerRadius = cornerRadius
    }

}
