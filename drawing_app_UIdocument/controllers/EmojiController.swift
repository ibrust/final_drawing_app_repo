//
//  EmojiController.swift
//  drawing_app
//
//  Created by Field Employee on 11/5/20.
//

import UIKit

class Emoji_Controller: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,  UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {

    var canvas_controller_reference: Canvas_Controller? = nil
    var adding_emoji = false
    
    @IBOutlet weak var emoji_collection_view_outlet: UICollectionView! {
        didSet {
            emoji_collection_view_outlet.dataSource = self
            emoji_collection_view_outlet.delegate = self
            emoji_collection_view_outlet.dragDelegate = self
            emoji_collection_view_outlet.dropDelegate = self
            emoji_collection_view_outlet.dragInteractionEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func add_emoji(){
        print("ADDING EMOJI FUNC")
        adding_emoji = true
        emoji_collection_view_outlet.reloadSections(IndexSet(integer: 0))
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
            case 0: return 1
            case 1: return emoji_array.count
            default: return 0
        }
    }
    
    private var font: UIFont {
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(24))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emoji_cell", for: indexPath) as? Emoji_Cell ?? Emoji_Cell()
        
            cell.emoji_label_outlet.attributedText = NSAttributedString(string: emoji_array[indexPath.row], attributes: [.font:font])
            return cell
        } else if adding_emoji {
            let cell = emoji_collection_view_outlet.dequeueReusableCell(withReuseIdentifier: "text_input_cell", for: indexPath)
            
            if let input_cell = cell as? Text_Input_Cell {
                input_cell.resignation_handler = { [weak self, unowned input_cell] in
                    if let text = input_cell.text_input_outlet.text {
                        emoji_array = (text.map { String($0)} + emoji_array).uniquified
                    }
                    self?.adding_emoji = false
                    self?.emoji_collection_view_outlet.reloadData()
                }
            }
            
            return cell
        } else {
            let cell = emoji_collection_view_outlet.dequeueReusableCell(withReuseIdentifier: "add_emoji_cell", for: indexPath) as? Add_Emoji_Cell
            cell?.emoji_controller_reference = self
            return cell ?? Add_Emoji_Cell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if adding_emoji && indexPath.section == 0 {
            return CGSize(width: 120, height: 30)
        } else {
            return CGSize(width: 30, height: 30)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let input_cell = cell as? Text_Input_Cell {
            input_cell.text_input_outlet.becomeFirstResponder()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {

        session.localContext = emoji_collection_view_outlet
        return drag_items(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        print("in items for adding to")
        return drag_items(at: indexPath)
    }
    
    private func drag_items(at indexPath: IndexPath) -> [UIDragItem] {
        if !adding_emoji, let attributed_string = (emoji_collection_view_outlet.cellForItem(at: indexPath) as? Emoji_Cell)?.emoji_label_outlet.attributedText {
            
            let drag_item = UIDragItem(itemProvider: NSItemProvider(object: attributed_string))
            drag_item.localObject = attributed_string
            return [drag_item]
        } else {
            return []
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if let indexPath = destinationIndexPath, indexPath.section == 1{
            let is_self = (session.localDragSession?.localContext as? UICollectionView) == emoji_collection_view_outlet
            return UICollectionViewDropProposal(operation: is_self ? .move : .copy, intent: .insertAtDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .cancel)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destination_index_path = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let source_index_path = item.sourceIndexPath {
                if let attributed_string = item.dragItem.localObject as? NSAttributedString {
                    emoji_collection_view_outlet.performBatchUpdates({
                        emoji_array.remove(at: source_index_path.item)
                        emoji_array.insert(attributed_string.string, at: destination_index_path.item)
                        emoji_collection_view_outlet.deleteItems(at: [source_index_path])
                        emoji_collection_view_outlet.insertItems(at: [destination_index_path])
                    })
                    coordinator.drop(item.dragItem, toItemAt: destination_index_path)
                }
            } else {
                let placeholder_context = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destination_index_path, reuseIdentifier: "drop_placeholder_cell"))
                
                item.dragItem.itemProvider.loadObject(ofClass: NSAttributedString.self) { (provider, error) in
                    DispatchQueue.main.async {
                        placeholder_context.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                            if let attributed_string = provider as? NSAttributedString {
                                emoji_array.insert(attributed_string.string, at: insertionIndexPath.item)
                            } else {
                                placeholder_context.deletePlaceholder()
                            }
                        })
                    }
                }
            }
        }
    }
    
}
