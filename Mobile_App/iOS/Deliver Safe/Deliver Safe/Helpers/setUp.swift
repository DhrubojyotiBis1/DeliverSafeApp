//
//  setUp.swift
//  BAZARO
//
//  Created by Dhrubojyoti on 07/01/20.
//  Copyright © 2020 Dhrubojyoti. All rights reserved.
//

import UIKit

public class setUp{
    
    public func makeCardView(forView view:UIView,withShadowHight shadowHight:Double,shadowWidth:Double,shadowOpacity:Float,shadowRadius:CGFloat){
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOffset = CGSize(width: shadowWidth, height: shadowHight)
        view.layer.shadowOpacity = shadowOpacity
        view.layer.shadowRadius = shadowRadius
    }
    
    public func makeCardView(forButton button:UIButton ,withShadowHight shadowHight:Double,shadowWidth:Double,shadowOpacity:Float,shadowRadius:CGFloat,cornerRadius:CGFloat){
        button.layer.masksToBounds = false
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: shadowWidth, height: shadowHight)
        button.layer.shadowOpacity = shadowOpacity
        button.layer.shadowRadius = shadowRadius
        button.layer.cornerRadius = cornerRadius
        
    }
}

extension UIButton{
    func rounded(leftCorner:Bool,withWidth width:Double ,andHight hight:Double){
        
        
        var maskPath1 = UIBezierPath()
        if leftCorner {
             maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.topLeft , .bottomLeft],
            cornerRadii: CGSize(width: width, height: width))
        }else{
             maskPath1 = UIBezierPath(roundedRect: bounds,
                                      byRoundingCorners: [.topRight , .bottomRight],
            cornerRadii: CGSize(width: width, height: width))
        }
        
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
}


extension UILabel {

    var isTruncated: Bool {

        guard let labelText = text else {
            return false
        }

        let labelTextSize = (labelText as NSString).boundingRect(
            with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: font as Any],
            context: nil).size

        return labelTextSize.height > bounds.size.height
    }
}
