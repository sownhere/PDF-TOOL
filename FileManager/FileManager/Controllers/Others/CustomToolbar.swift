import UIKit

class CustomToolbar: UIView {
    var buttons: [UIButton] = []
    var buttonAction: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupToolbar()
        refreshToolbarState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupToolbar() {
        let buttonDetails = [
            ("scissors", "Cut"),
            ("doc.on.doc", "Copy"),
            ("pencil", "Rename"),
            ("trash", "Delete")
        ]
        let buttonCount = buttonDetails.count
        let buttonWidth = self.frame.size.width / CGFloat(buttonCount)

        for (index, detail) in buttonDetails.enumerated() {
            let button = UIButton(type: .system)
            button.frame = CGRect(x: CGFloat(index) * buttonWidth, y: 5, width: buttonWidth, height: self.frame.size.height - 5)
            
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: detail.0)
            config.title = detail.1
            config.imagePadding = 5
            config.imagePlacement = .top
            button.configuration = config
            button.tintColor = .black
            
            button.tag = index
            button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
            
            addSubview(button)
            buttons.append(button)
        }
    }

    @objc private func buttonPressed(_ sender: UIButton) {
        buttonAction?(sender.tag)
    }


}
// CustomToolbar.swift

extension CustomToolbar {
    func refreshToolbarState() {
        let stateManager = ToolbarStateManager.shared
        let hasSelectedItems = !stateManager.selectedItems.isEmpty
        let hasCutItems = !stateManager.cutItems.isEmpty
        let hasCopyItems = !stateManager.copyItems.isEmpty
        
        // Update button titles and enabled states
        buttons[0].isEnabled = hasSelectedItems || hasCutItems  // Cut/Paste
        buttons[0].setTitle(hasCutItems ? "Paste" : "Cut", for: .normal)
        
        buttons[1].isEnabled = hasSelectedItems || hasCopyItems  // Cut/Paste
        buttons[1].setTitle(hasCopyItems ? "Paste" : "Copy", for: .normal)
        buttons[2].isEnabled = hasSelectedItems && stateManager.selectedItems.count == 1  // Rename
        buttons[3].isEnabled = hasSelectedItems  // Delete
    }
}
