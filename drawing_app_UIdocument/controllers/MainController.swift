
import UIKit

class Main_Controller: UIViewController {
    
    let TOTAL_CHILDREN = 5
    
    var canvas_controller_reference: Canvas_Controller? = nil
    var draw_controller_reference: Draw_Controller? = nil
    var document: Document? = nil
    var old_drawing_mode: Drawing_Modes = .move
    var old_segmented_index: Int = 0
    var use_default_image = false
    
    @IBAction func toolbar_draw_button_press(_ sender: UIBarButtonItem) {
        change_toolbar(Draw_Container)
    }
    @IBAction func toolbar_color_button_press(_ sender: UIBarButtonItem) {
        change_toolbar(Color_Container)
    }
    @IBAction func toolbar_emojis_button_press(_ sender: UIBarButtonItem) {
        change_toolbar(Emojis_Container)
    }
    @IBAction func toolbar_utilities_button_press(_ sender: UIBarButtonItem) {
        change_toolbar(Utilities_Container)
    }
    
    private func change_toolbar(_ container: UIView){
        // draw any emoji label added to the view & remove the label
        if Emojis_Container.isHidden == false { 
            canvas_controller_reference?.draw_and_remove_emojis()
        }
        
        Draw_Container.isHidden = true
        Utilities_Container.isHidden = true
        Color_Container.isHidden = true
        Emojis_Container.isHidden = true
        
        container.isHidden = false
        
        if Draw_Container.isHidden == true && Color_Container.isHidden == true {
            canvas_controller_reference?.drawing_mode = .move
            old_segmented_index = draw_controller_reference?.segmented_control_outlet.selectedSegmentIndex ?? 0
            draw_controller_reference?.segmented_control_outlet.selectedSegmentIndex = 0;
        } else {
            canvas_controller_reference?.drawing_mode = old_drawing_mode
            draw_controller_reference?.segmented_control_outlet.selectedSegmentIndex = old_segmented_index;
        }
    }
    
    // container outlets
    // should be called views, not containers ... the actual container controllers are accessible in the segue
    @IBOutlet weak var Draw_Container: UIView!
    @IBOutlet weak var Utilities_Container: UIView!
    @IBOutlet weak var Color_Container: UIView!
    @IBOutlet weak var Emojis_Container: UIView!
    
    @IBOutlet weak var buttons_wrapper_outlet: Buttons_Wrapper!
    
    // toolbar button outlets
    @IBOutlet weak var toolbar_draw_button: UIBarButtonItem!
    @IBOutlet weak var toolbar_color_button: UIBarButtonItem!
    @IBOutlet weak var toolbar_emojis_button: UIBarButtonItem!
    @IBOutlet weak var toolbar_utilities_button: UIBarButtonItem!
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                
        switch segue.destination {
        
        case let canvas_controller as Canvas_Controller:
            canvas_controller.main_controller_reference = self
            self.canvas_controller_reference = canvas_controller
            self.buttons_wrapper_outlet.canvas_controller_reference = canvas_controller
            self.addChild(canvas_controller)
        default:
            break
        }
        
        if self.children.count == TOTAL_CHILDREN {
            
            for child in self.children {
                if let child = child as? Canvas_Controller {
                    if use_default_image == true {
                        child.use_default_image = true
                    }
                }
                if let child = child as? Draw_Controller {
                    child.canvas_controller_reference = self.canvas_controller_reference
                    child.main_controller_reference = self
                    self.draw_controller_reference = child
                }
                else if let child = child as? Color_Controller {
                    child.canvas_controller_reference = self.canvas_controller_reference
                }
                else if let child = child as? Emoji_Controller {
                    child.canvas_controller_reference = self.canvas_controller_reference
                }
                else if let child = child as? Utility_Controller {
                    child.canvas_controller_reference = self.canvas_controller_reference
                    child.main_controller_reference = self
                    if document?.documentState != .normal {
                        child.document = self.document
                        child.load_document()
                    }
                }
            }
        }
    }
    
}



