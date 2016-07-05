//
//  MaterialButton.swift
//  StPaul
//
//  Created by Mike Camara on 11/01/2016.
//  Copyright © 2016 Mike Camara. All rights reserved.
//

import UIKit

class MaterialButton: UIButton {
    
    override func awakeFromNib() {
        layer.cornerRadius = 2.0
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
        layer.shadowOpacity = 0.9
        layer.shadowRadius = 7.0
        layer.shadowOffset = CGSizeMake(0.0, 2.0)
    }


   }
