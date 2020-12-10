//
//  Renderer.swift
//  drawing_app
//
//  Created by Field Employee on 11/1/20.
//

import UIKit


class Custom_Renderer {
    
    static var shared = Custom_Renderer()         // singleton pattern
    var redraw_path: CGMutablePath! = nil
    var redraw_box: CGRect! = nil
    var redraw_points: [CGPoint]! = nil
    private init(){}
    
    func draw_paths(paths: Bezier_Paths?, rect: CGRect?){
        guard let paths = paths else{return}
        
        let context = UIGraphicsGetCurrentContext()
        context?.setShouldAntialias(false)
        
        for bezier_path in paths.paths_array {
            
            if bezier_path.is_fill == false {
    
                // before redrawing, check if the path intersects the redraw area
                if let rect = rect {
                    let path_intersects = bezier_path.cgPath.boundingBox.intersects(rect)
                    if path_intersects == false {
                        continue
                    }
                }
                bezier_path.stroke_options?.color.setStroke()
                bezier_path.lineWidth = bezier_path.stroke_options?.width ?? CGFloat(1)
                bezier_path.stroke()
            } else {
                bezier_path.stroke_options?.color.setFill()
                bezier_path.fill()
            }
        }
        paths.predicted_path?.lineWidth = paths.predicted_path?.stroke_options?.width ?? CGFloat(1)
        paths.predicted_path?.stroke()
    }
    
    func redraw_surrounding_area(_ paths: Bezier_Paths, _ current_line_width: CGFloat, _ canvas: Canvas_View){
        
        if paths.draw_quadratic == true {
            redraw_path = CGMutablePath()
            redraw_points = [paths.n0, paths.n1, paths.n2, paths.n3, paths.p0, paths.p1, paths.p2, paths.current_point, paths.p3, paths.predicted_point].compactMap{ $0 }
            redraw_path.addLines(between: redraw_points)
            redraw_box = redraw_path.boundingBox.insetBy(dx: -current_line_width, dy: -current_line_width)
        } else if redraw_path != nil {
            redraw_points.append(paths.p3)
            if let predicted_point = paths.predicted_point {
                redraw_points.append(predicted_point)
            }
            redraw_path.addLines(between: redraw_points)
            redraw_box = redraw_path.boundingBox.insetBy(dx: -current_line_width, dy: -current_line_width)
        }
        
        canvas.latest_rect = redraw_box ?? canvas.bounds
        canvas.setNeedsDisplay(redraw_box ?? canvas.bounds)
    }
    
    func redraw_full_screen(_ canvas: Canvas_View){
        canvas.latest_rect = canvas.bounds
        canvas.setNeedsDisplay()
    }
    
}


