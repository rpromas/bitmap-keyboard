//
//  KeyboardViewController.swift
//  BitmapKeyboard
//
//  Created by Romas on 01/04/2026.
//

import UIKit
import SwiftUI

class KeyboardViewController: UIInputViewController {
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bitmapKeyboardViewController = UIHostingController(
            rootView: BitmapKeyboardView(
                onData: { [weak self] textualData in
                    guard let self else { return }
                    self.textDocumentProxy.insertText("\(textualData)")

                },
                dismissKeyboard: { [weak self] in
                    self?.dismissKeyboard()
                },
                keyboardHeight: UIScreen.main.bounds.height * 0.4,
                needsInputModeSwitchKey: self.needsInputModeSwitchKey,
                nextKeyboardAction: #selector(self.handleInputModeList(from:with:)),
                backgroundColor: .clear
            ))

        let bitmapKeyboardView = bitmapKeyboardViewController.view!
        bitmapKeyboardView.translatesAutoresizingMaskIntoConstraints = false
        bitmapKeyboardView.backgroundColor = .clear
        
        self.addChild(bitmapKeyboardViewController)
        self.view.addSubview(bitmapKeyboardView)
        bitmapKeyboardViewController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            bitmapKeyboardView.leftAnchor.constraint(equalTo: view.leftAnchor),
            bitmapKeyboardView.topAnchor.constraint(equalTo: view.topAnchor),
            bitmapKeyboardView.rightAnchor.constraint(equalTo: view.rightAnchor),
            bitmapKeyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
    }

}
