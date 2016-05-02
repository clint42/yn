//
//  UIColorExtension.swift
//  yn
//
//  Created by Aurelien Prieur on 30/04/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static func purpleYn(alpha alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: 136/255, green: 73/255, blue: 156/255, alpha: alpha)
    }
    
    static func blueYn(alpha alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: 45/255, green: 104/255, blue: 170/255, alpha: alpha)
    }
}