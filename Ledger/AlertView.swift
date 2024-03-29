//
//  AlertView.swift
//  Ledger
//
//  Created by Riya Manchanda on 30/04/21.
//

import SwiftUI

struct ModalView<Parent: View, Content: View>: View {
    @Environment(\.modalStyle) var style: AnyModalStyle
    
    @Binding var isPresented: Bool
    
    var parent: Parent
    var content: Content
    
    let backgroundRectangle = Rectangle()
    
    var body: some View {
        ZStack {
            parent
            
            if isPresented {
                style.makeBackground(
                    configuration: ModalStyleBackgroundConfiguration(
                        background: backgroundRectangle
                    ),
                    isPresented: $isPresented
                )
                style.makeModal(
                    configuration: ModalStyleModalContentConfiguration(
                        content: AnyView(content)
                    ),
                    isPresented: $isPresented
                )
            }
        }
        .animation(style.animation)
    }
    
    init(isPresented: Binding<Bool>, parent: Parent, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.parent = parent
        self.content = content()
    }
}

extension View {
    func modal<ModalBody: View>(
            isPresented: Binding<Bool>,
            @ViewBuilder modalBody: () -> ModalBody
    ) -> some View {
        ModalView(
            isPresented: isPresented,
            parent: self,
            content: modalBody
        )
    }
}

protocol ModalStyle {
    associatedtype Background: View
    associatedtype Modal: View
    
    var animation: Animation? { get }
    
    func makeBackground(configuration: BackgroundConfiguration, isPresented: Binding<Bool>) -> Background
    func makeModal(configuration: ModalContentConfiguration, isPresented: Binding<Bool>) -> Modal
    
    typealias BackgroundConfiguration = ModalStyleBackgroundConfiguration
    typealias ModalContentConfiguration = ModalStyleModalContentConfiguration
}

extension ModalStyle {
    func anyMakeBackground(configuration: BackgroundConfiguration, isPresented: Binding<Bool>) -> AnyView {
        AnyView(
            makeBackground(configuration: configuration, isPresented: isPresented)
        )
    }
    
    func anyMakeModal(configuration: ModalContentConfiguration, isPresented: Binding<Bool>) -> AnyView {
        AnyView(
            makeModal(configuration: configuration, isPresented: isPresented)
        )
    }
}

public struct AnyModalStyle: ModalStyle {
    let animation: Animation?
    
    private let _makeBackground: (ModalStyle.BackgroundConfiguration, Binding<Bool>) -> AnyView
    private let _makeModal: (ModalStyle.ModalContentConfiguration, Binding<Bool>) -> AnyView
    
    init<Style: ModalStyle>(_ style: Style) {
        self.animation = style.animation
        self._makeBackground = style.anyMakeBackground
        self._makeModal = style.anyMakeModal
    }
    
    func makeBackground(configuration: ModalStyle.BackgroundConfiguration, isPresented: Binding<Bool>) -> AnyView {
        return self._makeBackground(configuration, isPresented)
    }
    
    func makeModal(configuration: ModalStyle.ModalContentConfiguration, isPresented: Binding<Bool>) -> AnyView {
        return self._makeModal(configuration, isPresented)
    }
}

struct ModalStyleKey: EnvironmentKey {
    public static let defaultValue: AnyModalStyle = AnyModalStyle(DefaultModalStyle())
}

extension EnvironmentValues {
    var modalStyle: AnyModalStyle {
        get {
            return self[ModalStyleKey.self]
        }
        set {
            self[ModalStyleKey.self] = newValue
        }
    }
}

extension View {
    func modalStyle<Style: ModalStyle>(_ style: Style) -> some View {
        self
            .environment(\.modalStyle, AnyModalStyle(style))
    }
}


struct ModalStyleBackgroundConfiguration {
    let background: Rectangle
}

struct ModalStyleModalContentConfiguration {
    let content: AnyView
}


struct DefaultModalStyle: ModalStyle {
    let animation: Animation? = .easeInOut(duration: 0.2)
    
    func makeBackground(configuration: ModalStyle.BackgroundConfiguration, isPresented: Binding<Bool>) -> some View {
        configuration.background
            .edgesIgnoringSafeArea(.all)
            .foregroundColor(.black)
            .opacity(0.3)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .zIndex(1000)
            .onTapGesture {
                isPresented.wrappedValue = false
            }
    }
    
    func makeModal(configuration: ModalStyle.ModalContentConfiguration, isPresented: Binding<Bool>) -> some View {
        configuration.content
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .zIndex(1001)
    }
}


