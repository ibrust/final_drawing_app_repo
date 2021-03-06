//
//  Canvas.swift
//  drawing_app
//
//  Created by Field Employee on 10/29/20.
//

import UIKit

protocol Canvas_View_Delegate{
    func start_touch(touches: Set<UITouch>, event: UIEvent?)
    func mid_touch(touches: Set<UITouch>, event: UIEvent?)
    func end_touch(touches: Set<UITouch>, event: UIEvent?)
    func draw_paths(_ rect: CGRect?)
    func refresh_background_image()
}

class Canvas_View: UIView, UIDropInteractionDelegate {
    
    var delegate: Canvas_View_Delegate? = nil
    var draw_emojis = false
    var needs_refresh = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    private func setup(){
        addInteraction(UIDropInteraction(delegate: self))
        self.clearsContextBeforeDrawing = false
        self.backgroundColor = .clear
        self.isOpaque = false
    }
    
    var background_image: UIImage?
    
    var latest_rect: CGRect?
    
    override func draw(_ rect: CGRect){
        super.draw(rect)
        
        if needs_refresh == true {
            self.delegate?.refresh_background_image()
            needs_refresh = false
        }
        
        if draw_emojis == true {
            draw_emojis = false
            needs_refresh = true
            selectedSubview = nil
            
            let emoji_labels_array = self.subviews.compactMap { $0 as? UILabel }
            emoji_labels_array.forEach {
                $0.drawText(in: $0.frame)
                $0.removeFromSuperview()
            }
            background_image = self.asImage()
        }
        else {
            background_image?.draw(in: bounds)
        }
        delegate?.draw_paths(latest_rect)
        Custom_Renderer.shared.redraw_path = nil
    }
    
    func draw_and_remove_emojis(){
        draw_emojis = true
        needs_refresh = false
        setNeedsDisplay()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        delegate?.start_touch(touches: touches, event: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        delegate?.mid_touch(touches: touches, event: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        delegate?.end_touch(touches: touches, event: event)
    }
}

// functions for dragging emojis / text onto canvas
extension Canvas_View {
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSAttributedString.self) { providers in
            let drop_point = session.location(in: self)
            for attributed_string in providers as? [NSAttributedString] ?? [] {
                self.add_label(with: attributed_string, centered_at: drop_point)
            }
        }
    }
    
    func add_label(with attributed_string: NSAttributedString, centered_at point: CGPoint) {
        let label = UILabel()
        label.backgroundColor = .clear
        label.attributedText = attributed_string
        label.sizeToFit()
        label.center = point
        add_gesture_recognizers(to: label)
        addSubview(label)
    }
}


// gesture recognizers for canvas / emoji labels
extension Canvas_View
{
    func add_gesture_recognizers(to view: UIView) {
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.selectSubview(by:))))
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.selectAndMoveSubview(by:))))
    }
    
    @objc func selectSubview(by recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            selectedSubview = recognizer.view
            // send the UILabel to the back of the subview stack - used to handle overlapping label issues
            if let view = recognizer.view, let index = subviews.firstIndex(of: view) {
                selectedSubview = view
                exchangeSubview(at: 0, withSubviewAt: index)
            }
        }
    }

    var selectedSubview: UIView? {
        get { return subviews.filter { $0.layer.borderWidth > 0 }.first }
        set {
            subviews.forEach { $0.layer.borderWidth = 0 }
            newValue?.layer.borderWidth = 1
            if newValue != nil {
                enableRecognizers()
            } else {
                disableRecognizers()
            }
        }
    }
    
    @objc func selectAndMoveSubview(by recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            if selectedSubview != nil, recognizer.view != nil {
                selectedSubview = recognizer.view
            }
        case .changed, .ended:
            if selectedSubview != nil {
                recognizer.view?.center = recognizer.view!.center.offset(by: recognizer.translation(in: self))
                recognizer.setTranslation(CGPoint.zero, in: self)
            }
        default:
            break
        }
    }
    
    // unlike add_gesture_recognizers which adds gestures to the new emoji UILabel,
    // this manages the recognizers on the canvas view & scroll view
    func enableRecognizers() {
        if let scrollView = superview as? UIScrollView {
            // if we're in a scroll view, disable its recognizers so that we'll get the touch events instead
            scrollView.panGestureRecognizer.isEnabled = false
            scrollView.pinchGestureRecognizer?.isEnabled = false
        }
        if gestureRecognizers == nil || gestureRecognizers!.count == 0 {
            // if the tap gesture isn't handled by the label, it'll be handled by the canvas view
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.deselectSubview)))
            addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(self.resizeSelectedLabel(by:))))
        } else {
            gestureRecognizers?.forEach { $0.isEnabled = true }
        }
    }
    
    func disableRecognizers() {
        if let scrollView = superview as? UIScrollView {
            // if we are in a scroll view, re-enable its recognizers
            scrollView.panGestureRecognizer.isEnabled = true
            scrollView.pinchGestureRecognizer?.isEnabled = true
        }
        gestureRecognizers?.forEach { $0.isEnabled = false }
    }
    
    @objc func deselectSubview() {
        selectedSubview = nil
    }
    
    @objc func resizeSelectedLabel(by recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            if let label = selectedSubview as? UILabel {
                label.attributedText = label.attributedText?.withFontScaled(by: recognizer.scale)
                label.stretchToFit()
                recognizer.scale = 1.0
            }
        default:
            break
        }
    }
    
}





