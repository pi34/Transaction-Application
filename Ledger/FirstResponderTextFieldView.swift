//
//  FirstResponderTextFieldView.swift
//  Ledger
//
//  Created by Riya Manchanda on 02/05/21.
//

import SwiftUI

struct FirstResponderTextField: UIViewRepresentable {
    
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType?
    var font: UIFont?
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        @Binding var text: String
        var becameFirstReponder = false
        
        init(text: Binding<String>) {
            self._text = text
        }
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }
    
    func makeUIView(context: Context) -> some UIView {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.placeholder = placeholder
        textField.font = font ?? UIFont(name: "Helvetica Neue", size: 16)
        textField.keyboardType = keyboardType ?? .default
        return textField
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if !context.coordinator.becameFirstReponder {
            uiView.becomeFirstResponder()
            context.coordinator.becameFirstReponder = true
        }
    }
}
