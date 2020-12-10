//
//  StrokeOptions.swift
//  drawing_app
//
//  Created by Field Employee on 11/11/20.
//

import UIKit

struct Stroke_Options : Equatable {
    var color: UIColor = UIColor.blue
    var width: CGFloat = 1.0
    
    var opacity: CGFloat = 1.0 {
        didSet {
            self.color = self.color.withAlphaComponent(self.opacity)
        }
    }
}
