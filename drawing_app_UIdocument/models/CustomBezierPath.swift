//
//  CustomBezierPath.swift
//  drawing_app
//
//  Created by Field Employee on 11/1/20.
//

import UIKit

class Custom_Bezier_Path: UIBezierPath {
    var stroke_options: Stroke_Options?
    var is_fill: Bool?
    var mode: Drawing_Modes?
    var label: UILabel? = nil
    
    init(_ stroke_options: Stroke_Options, _ mode: Drawing_Modes = .pencil, _ is_fill: Bool = false){
        self.stroke_options = stroke_options
        self.mode = mode
        self.is_fill = is_fill
        super.init()
        
        if self.mode == .eraser {
            self.stroke_options?.color = UIColor.white
        }
        self.lineCapStyle = .round
        self.lineJoinStyle = .round
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}



