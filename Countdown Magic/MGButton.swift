//
//  MGButton.swift
//  Countdown Magic
//
//  Created by George Potosky 2019.
//  GeozWorld Enterprises (tm). All rights reserved.
//


import Foundation
import UIKit

//* - Create custom button
class MGButton: UIButton {
    required init?(coder Decoder: NSCoder) {
        super.init(coder: Decoder)
        let borderColor = UIColor.clear
        let buttonColor = UIColor.clear
        self.layer.cornerRadius = 5.0;
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = 1.0
        self.backgroundColor = buttonColor
        self.tintColor = borderColor
    }
}
