//
//  Paths.swift
//  drawing_app
//
//  Created by Field Employee on 11/10/20.
//

import UIKit

class Bezier_Paths{
    
    var canvas_bounds: CGRect? = nil 
    
    var paths_array: [Custom_Bezier_Path] = []
    var predicted_point: CGPoint? = nil
    var n0: CGPoint? = nil
    var n1: CGPoint? = nil
    var n2: CGPoint? = nil
    var n3: CGPoint? = nil
    var predicted_path: Custom_Bezier_Path? = nil
    var p0: CGPoint! = nil
    var p1: CGPoint! = nil
    var p2: CGPoint! = nil
    var p3: CGPoint! = nil
    
    var current_point: CGPoint! = nil
    var draw_quadratic: Bool = true
    
    func move(to first_point: CGPoint){
        paths_array.last?.move(to: first_point)
        self.n1 = nil
        self.p0 = nil
        self.p1 = nil
        self.p2 = nil
        self.p3 = first_point
        self.current_point = first_point
    }
    
    func add_bezier_path(_ new_bezier_path: Custom_Bezier_Path){
        self.paths_array.append(new_bezier_path)
        guard let stroke_options = new_bezier_path.stroke_options else{return}
        guard let mode = new_bezier_path.mode else{return}
        guard let fill = new_bezier_path.is_fill else{return}
        self.predicted_path = Custom_Bezier_Path(stroke_options, mode, fill)
    }
    
    func draw_quadratic_line(to new_point: CGPoint){
        
        p0 = p1             // p0 is the starting point, it's not directly used in the algorithm
        p1 = p2
        p2 = p3
        p3 = new_point
        
        // use line smoothing
        if p0 != nil && (paths_array.last?.mode == .pencil || paths_array.last?.mode == .eraser) {
            
            if draw_quadratic == true {
                let between_p1p3 = CGPoint(x: (p1.x + p3.x) / 2.0, y: (p1.y + p3.y) / 2.0)
                paths_array.last?.addQuadCurve(to: between_p1p3, controlPoint: p1)
                
                current_point = between_p1p3
                draw_quadratic = false
            } else {
                draw_quadratic = true       // you oscillate between drawing quadratic & not drawing anything
            }
        }

        n0 = n1
        n1 = n2
        n2 = n3
        n3 = self.predicted_point                // I think it is fine if predicted_point is nil
        
        if let predicted_point = self.predicted_point {
            predicted_path?.removeAllPoints()
            predicted_path?.move(to: self.current_point)
            predicted_path?.addQuadCurve(to: predicted_point, controlPoint: self.p3)
        }
    }
    
    func draw_line(to new_point: CGPoint){
        paths_array.last?.addLine(to: new_point)
    }
    
    func draw_ending_line(to new_point: CGPoint){
        predicted_path?.removeAllPoints()
        paths_array.last?.move(to: current_point)
        paths_array.last?.addQuadCurve(to: new_point, controlPoint: p3)
        predicted_point = nil 
    }
    
    func draw_temporary_line(to new_point: CGPoint){
        predicted_path?.removeAllPoints()
        predicted_path?.move(to: self.current_point)
        predicted_path?.addLine(to: new_point)
    }
    
}
