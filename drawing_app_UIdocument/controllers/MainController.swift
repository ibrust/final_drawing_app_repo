
import UIKit

class Main_Controller: UIViewController {
    
    var canvas_controller_reference: Canvas_Controller? = nil
    let TOTAL_CHILDREN = 5
    var document: Document? = nil
    
    @IBAction func toolbar_draw_button_press(_ sender: UIBarButtonItem) {
        hide_containers()
        Draw_Container.isHidden = false
    }
    @IBAction func toolbar_color_button_press(_ sender: UIBarButtonItem) {
        hide_containers()
        Color_Container.isHidden = false
    }
    @IBAction func toolbar_emojis_button_press(_ sender: UIBarButtonItem) {
        hide_containers()
        Emojis_Container.isHidden = false
    }
    @IBAction func toolbar_utilities_button_press(_ sender: UIBarButtonItem) {
        hide_containers()
        Utilities_Container.isHidden = false
    }
    
    // container outlets
    // should be called views, not containers ... the actual container controllers are accessible in the segue
    @IBOutlet weak var Draw_Container: UIView!
    @IBOutlet weak var Utilities_Container: UIView!
    @IBOutlet weak var Color_Container: UIView!
    @IBOutlet weak var Emojis_Container: UIView!
    
    // toolbar button outlets
    @IBOutlet weak var toolbar_draw_button: UIBarButtonItem!
    @IBOutlet weak var toolbar_color_button: UIBarButtonItem!
    @IBOutlet weak var toolbar_emojis_button: UIBarButtonItem!
    @IBOutlet weak var toolbar_utilities_button: UIBarButtonItem!
    
    private func hide_containers(){
        Draw_Container.isHidden = true
        Utilities_Container.isHidden = true
        Color_Container.isHidden = true
        Emojis_Container.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                
        switch segue.destination {
        
        case let canvas_controller as Canvas_Controller:
            canvas_controller.main_controller_reference = self
            self.canvas_controller_reference = canvas_controller
            self.addChild(canvas_controller)
        default:
            break
        }
        
        if self.children.count == TOTAL_CHILDREN {
            for child in self.children {
                if let child = child as? Draw_Controller {
                    child.canvas_controller_reference = self.canvas_controller_reference
                } else if let child = child as? Color_Controller {
                    child.canvas_controller_reference = self.canvas_controller_reference
                } else if let child = child as? Emoji_Controller {
                    child.canvas_controller_reference = self.canvas_controller_reference
                } else if let child = child as? Utility_Controller {
                    child.canvas_controller_reference = self.canvas_controller_reference
                    child.main_controller_reference = self
                    child.document = self.document
                    child.load_document()
                }
            }
        }
    }
    
}



