//
//  CanvasController.swift
//  drawing_app
//
//  Created by Field Employee on 11/5/20.
//

import UIKit

class Canvas_Controller: UIViewController, Canvas_View_Delegate, UIDropInteractionDelegate, UIScrollViewDelegate {
    
    var main_controller_reference: Main_Controller? = nil
    var image_fetcher: ImageFetcher!
    var paths: Bezier_Paths = Bezier_Paths()
    
    var stroke_options: Stroke_Options = Stroke_Options()
    var is_fill: Bool = false
    var polyline_set = false
    
    var canvas_view_outlet: Canvas_View! = Canvas_View()
    var image_view: UIImageView! = UIImageView()
    var regular_view: UIView! = UIView()
    var use_default_image = false
    
    @IBOutlet weak var scroll_view_width: NSLayoutConstraint!
    @IBOutlet weak var scroll_view_height: NSLayoutConstraint!
    
    var current_file: File_Model {
        get {
            var file_obj: File_Model
            if let background_image = self.background_image {
                file_obj = File_Model(base_image: background_image, canvas_image: canvas_view_outlet.asImage())
            } else {
                file_obj = File_Model(base_image: UIImage(named: "Oranges")!, canvas_image: canvas_view_outlet.asImage())
            }
            let emoji_labels = canvas_view_outlet.subviews.compactMap { $0 as?  UILabel }
            for label in emoji_labels {
                if let converted_label = File_Model.Converted_Emoji_Label(label) {
                    file_obj.converted_emojis_array.append(converted_label)
                }
            }
            return file_obj
        }
        set {
            canvas_view_outlet.subviews.compactMap {
                $0 as? UILabel }.forEach { $0.removeFromSuperview() }
        
            DispatchQueue.main.async {
                self.background_image = newValue.get_base_image()
                self.canvas_view_outlet.background_image = newValue.get_canvas_image()
                for converted_label in newValue.converted_emojis_array {
                    let attributed_string = NSAttributedString(string: converted_label.text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(converted_label.font_size))])
                    self.canvas_view_outlet.add_label(with: attributed_string, centered_at: CGPoint(x: converted_label.x, y: converted_label.y))
                }
            }
        }
    }
    
    var drawing_mode: Drawing_Modes = .pencil {
        willSet {
            if newValue == .polyline {
                polyline_set = false
            }
            if newValue == .eraser {
                guard let view_image = merge_imageview_and_canvas() else {return}
                self.paths = Bezier_Paths()
                canvas_view_outlet.background_image = view_image
            }
            if newValue == .move {
                scroll_view_outlet.isScrollEnabled = true
            } else {
                scroll_view_outlet.isScrollEnabled = false
            }
        }
    }
    
    @IBOutlet weak var drop_zone_outlet: UIView! {
        didSet {
            drop_zone_outlet.addInteraction(UIDropInteraction(delegate: self))
            drop_zone_outlet.backgroundColor = UIColor.black
        }
    }

    @IBOutlet var scroll_view_outlet: UIScrollView! {
        didSet {
            scroll_view_outlet.isDirectionalLockEnabled = false
            scroll_view_outlet.minimumZoomScale = 0.1
            scroll_view_outlet.maximumZoomScale = 5.0
            scroll_view_outlet.delegate = self
            scroll_view_outlet.addSubview(canvas_view_outlet)
            scroll_view_outlet.backgroundColor = UIColor.black
        }
    }
    
    var background_image: UIImage? {
        get {
            return image_view.image
        }
        set {
            scroll_view_outlet?.zoomScale = 1.0
            image_view.image = newValue
            canvas_view_outlet.background_image = newValue
            let size = newValue?.size ?? CGSize.zero
            
            regular_view.frame = CGRect(origin: CGPoint.zero, size: size)
            
            scroll_view_outlet?.contentSize = size
            scroll_view_height?.constant = size.height
            scroll_view_width?.constant = size.width
            
            self.scroll_view_outlet.addSubview(regular_view)
            
            image_view.frame = regular_view.bounds
            regular_view.addSubview(image_view)
            canvas_view_outlet.frame = regular_view.bounds
            regular_view.addSubview(canvas_view_outlet)
            
            if let drop_zone_outlet = self.drop_zone_outlet, size.width > 0, size.height > 0 {
                scroll_view_outlet?.zoomScale = max(drop_zone_outlet.bounds.size.width / (size.width / 2), drop_zone_outlet.bounds.size.height / (size.height / 2))
            }
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return regular_view
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scroll_view_height.constant = scroll_view_outlet.contentSize.height
        scroll_view_width.constant = scroll_view_outlet.contentSize.width
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.main_controller_reference?.canvas_controller_reference = self
        self.canvas_view_outlet.delegate = self
        self.paths.predicted_path = Custom_Bezier_Path(self.stroke_options, drawing_mode, is_fill)
        if self.use_default_image == true {
            background_image = UIImage(named: "Oranges")
        }
    }
    
}

// drawing functions
extension Canvas_Controller {
    
    func start_touch(touches: Set<UITouch>, event: UIEvent?) {
        guard let starting_point = touches.first?.location(in: canvas_view_outlet) else {return}
        
        if self.drawing_mode == .polyline {
            if polyline_set == true {
                return
            }
            polyline_set = true
        }
        
        let new_bezier_path = Custom_Bezier_Path(stroke_options, drawing_mode, is_fill)
        if self.drawing_mode == .fill{
            
            guard let view_image = merge_imageview_and_canvas() else {return}

            let x = Int(starting_point.x * UIScreen.main.scale)
            let y = Int(starting_point.y * UIScreen.main.scale)
            
            // async introduced too many bugs for now
            DispatchQueue.global(qos: .userInitiated).sync{ [weak self] in
                guard let color = self?.stroke_options.color else {return}
                let filled_image = view_image.pbk_imageByReplacingColorAt(x, y, withColor: color, tolerance: 10)
                canvas_view_outlet.background_image = filled_image
                self?.paths = Bezier_Paths()
                return
            }
        }
        if drawing_mode != .move {
            self.paths.add_bezier_path(new_bezier_path)
            self.paths.move(to: starting_point)
        }
    }
    
    func mid_touch(touches: Set<UITouch>, event: UIEvent?) {
        
        guard let new_point = touches.first?.location(in: canvas_view_outlet) else {return}
        paths.predicted_point = nil
        
        if let touch = touches.first, let predicted_touches = event?.predictedTouches(for: touch), predicted_touches.count > 0 {
            for one_touch in predicted_touches {
                paths.predicted_point = one_touch.location(in: canvas_view_outlet)
            }
        }
        
        if drawing_mode == .pencil || drawing_mode == .eraser {
            self.paths.draw_quadratic_line(to: new_point)
            Custom_Renderer.shared.redraw_surrounding_area(paths, stroke_options.width, canvas_view_outlet)
        }
        
        else if drawing_mode == .polyline || drawing_mode == .line {
            self.paths.draw_temporary_line(to: new_point)
            Custom_Renderer.shared.redraw_full_screen(canvas_view_outlet)
        }
    }
    
    func end_touch(touches: Set<UITouch>, event: UIEvent?) {
        if drawing_mode == .line {
            guard let end_point = touches.first?.location(in: canvas_view_outlet) else{return}
            self.paths.draw_line(to: end_point)
        }
        if drawing_mode == .polyline {
            guard let end_point = touches.first?.location(in: canvas_view_outlet) else{return}
            self.paths.draw_line(to: end_point)
            self.paths.move(to: end_point)
        }
        else if drawing_mode == .pencil || drawing_mode == .eraser {
            guard let end_point = touches.first?.location(in: canvas_view_outlet) else{return}
            self.paths.draw_ending_line(to: end_point)
        }
        Custom_Renderer.shared.redraw_full_screen(canvas_view_outlet)
    }
    
    func draw_paths(_ rect: CGRect?){
        Custom_Renderer.shared.draw_paths(paths: paths, rect: rect)
    }
    
    func clear_paths(){
        self.paths = Bezier_Paths()
        self.canvas_view_outlet?.setNeedsDisplay()
        polyline_set = false
    }
    
    func reset_background_image(){
        self.canvas_view_outlet.background_image = self.image_view.image
    }
    
    func refresh_background_image(){
        self.background_image = merge_imageview_and_canvas() 
    }
    
    func merge_imageview_and_canvas() -> UIImage? {
        
        self.paths.canvas_bounds = regular_view.bounds
        
        let canvas_image = canvas_view_outlet.asImage()
        let new_size = canvas_view_outlet.frame.size
        
        UIGraphicsBeginImageContextWithOptions(new_size, false, 0.0)

        background_image?.draw(in: CGRect(origin: CGPoint.zero, size: new_size))
        canvas_image.draw(in: CGRect(origin: CGPoint.zero, size: new_size))
        
        guard let view_image = UIGraphicsGetImageFromCurrentImageContext() else {return nil}
        UIGraphicsEndImageContext()
        return view_image
    }
    
    func create_image_from_paths(paths: [Custom_Bezier_Path]) -> UIImage? {
        let new_size = canvas_view_outlet.frame.size
        UIGraphicsBeginImageContextWithOptions(new_size, false, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else {return nil}
        context.setStrokeColor(UIColor.green.cgColor)
        
        for path in paths {
            path.stroke()
        }
        let new_image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return new_image
    }
    
    func draw_and_remove_emojis(){
        self.canvas_view_outlet.draw_and_remove_emojis()
    }
    
}

// drag and drop functions 
extension Canvas_Controller {
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        image_fetcher = ImageFetcher() { [weak self] (url, image) in
            DispatchQueue.main.async {
                guard let self = self else {return}
                self.canvas_view_outlet.subviews.compactMap {
                    $0 as? UILabel }.forEach { $0.removeFromSuperview() }
                self.background_image = image
            }
        }
        session.loadObjects(ofClass: NSURL.self) { nsurls in
            if let url = nsurls.first as? URL {
                self.image_fetcher.fetch(url)
            }
        }
        session.loadObjects(ofClass: UIImage.self) { images in
            if let image = images.first as? UIImage {
                self.image_fetcher.backup = image
            }
        }
    }
}
 
