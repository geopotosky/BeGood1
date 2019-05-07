//
//  RoundButton.swift
//  Countdown Magic
//
//  Created by George Potosky 2019.
//  GeozWorld Enterprises (tm). All rights reserved.
//

import Foundation
import UIKit

//* - Create custom button
class RoundButton: UIButton {
    required init?(coder Decoder: NSCoder) {
        super.init(coder: Decoder)
        //let borderColor = UIColor(red:0.6,green:1.0,blue:0.6,alpha:1.0)
        //let borderColor = UIColor(red:0.0,green:0.5,blue:1.0,alpha:1.0)
        self.layer.cornerRadius = 20.0;
        //self.layer.borderColor = borderColor.cgColor
        //self.layer.borderWidth = 1.0
        //self.backgroundColor = UIColor(red:0.6,green:1.0,blue:0.6,alpha:1.0)
        //self.backgroundColor = UIColor(red:0.0,green:0.5,blue:1.0,alpha:1.0)
        //self.tintColor = borderColor
    }
}
