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
    func clear_paths()
}

class Canvas_View: UIView, UIDropInteractionDelegate {
    
    var delegate: Canvas_View_Delegate? = nil
    
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
    
    var background_image: UIImage? {
        didSet {
            self.delegate?.clear_paths()
        }
    }
    
    var latest_rect: CGRect?
    
    override func draw(_ rect: CGRect){
        super.draw(rect)
        background_image?.draw(in: bounds)
        
        delegate?.draw_paths(latest_rect)
        
        Custom_Renderer.shared.redraw_path = nil 
        
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


// Gesture Recognition Extension
extension Canvas_View
{
    func add_gesture_recognizers(to view: UIView) {
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.selectSubview(by:))))
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.selectAndMoveSubview(by:))))
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

    @objc func selectSubview(by recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            selectedSubview = recognizer.view
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
    
    func enableRecognizers() {
        if let scrollView = superview as? UIScrollView {
            // if we are in a scroll view, disable its recognizers
            // so that ours will get the touch events instead
            scrollView.panGestureRecognizer.isEnabled = false
            scrollView.pinchGestureRecognizer?.isEnabled = false
        }
        if gestureRecognizers == nil || gestureRecognizers!.count == 0 {
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
    /*
    @objc func selectAndSendSubviewToBack(by recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            if let view = recognizer.view, let index = subviews.index(of: view) {
                selectedSubview = view
                exchangeSubview(at: 0, withSubviewAt: index)
                delegate?.emojiArtViewDidChange(self)
            }
        }
    }*/
}





