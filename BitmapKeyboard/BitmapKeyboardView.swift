//
//  BitmapKeyboardView.swift
//  BitmapKeyboard
//
//  Created by Romas on 01/04/2026.
//

import SwiftUI

struct BitmapKeyboardView: View {
    var onData: (String) -> Void
    var dismissKeyboard: () -> Void
    
    let keyboardHeight: CGFloat
    
    var needsInputModeSwitchKey: Bool = false
    var nextKeyboardAction: Selector? = nil
    
    var backgroundColor: Color
    
    private static let useUltraHdCapybara = true
    
    @State private var images: [String] = (1...(useUltraHdCapybara ? 13 : 12)).map {"capybara\($0)"}
    
    private let columns = 4
    private let rowSpacing: Double = 8.0

    var body: some View {
        GeometryReader { geo in
            
            // using bigRowCount for images and a single small row (half size of big row) for custom buttons like delete
            let bigRowCount = ceil(Double(images.count) / Double(columns))
            let rowCount = bigRowCount + 1 // single small row
            
            // usableHeight = height without row spacing
            let usableHeight = (geo.size.height - (rowCount - 1) * rowSpacing)
            
            // some math to make delete button be equal to half size of image
            let smallItemSize = usableHeight / (bigRowCount * 2 + 1)
            let bigItemSize = smallItemSize * 2
            
            VStack(spacing: rowSpacing) {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(bigItemSize)), count: columns),
                    spacing: rowSpacing
                ) {
                    ForEach(images, id: \.self) { image in
                        Button(action: {
                            if let imagePngData = ImageUtils.imageToPngData(image) {
                                let imageKey = SharedTemporaryImageStorage.shared.append(imagePngData: imagePngData)
                                onData(ImageUtils.embedImageInTags(imageKey))
                            }
                        }, label: {
                            Image(image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: bigItemSize)
                        })
                    }
                }
                HStack(alignment: .center, spacing: 16) {
                    Button(action: {
                        onData(ImageUtils.deleteToken)
                    }, label: {
                        Image(systemName: "delete.left")
                            .resizable()
                            .scaledToFit()
                            .frame(height: smallItemSize)
                            .foregroundStyle(.red.opacity(0.8))
                    })
                    
                    Button(action: {
                        dismissKeyboard()
                    }, label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .resizable()
                            .scaledToFit()
                            .frame(height: smallItemSize)
                            .foregroundStyle(.primary.opacity(0.8))
                    })
                    
                    if needsInputModeSwitchKey &&  nextKeyboardAction != nil{
                        Button(action: {}, label: {
                            Image(systemName: "globe")
                                .resizable()
                                .scaledToFit()
                                .frame(height: smallItemSize)
                                .foregroundStyle(.black.opacity(0.8))
                                .padding(.all, 8)
                                .overlay(NextKeyboardButtonOverlay(action: nextKeyboardAction!))
                                .background( RoundedRectangle(cornerRadius: 8)
                                    .fill(.white.opacity(0.8))
                                )
                        })
                    }
                }.frame(maxWidth: .infinity)
            }
        }
        .frame(height: keyboardHeight)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
    }
}

#Preview {
    BitmapKeyboardView(
        onData: {_ in }, dismissKeyboard: {},
        keyboardHeight: 350, backgroundColor: .green)
}

struct NextKeyboardButtonOverlay: UIViewRepresentable {
    let action: Selector
    
    func makeUIView(context: Context) -> UIButton {
        let button = UIButton()
        button.addTarget(nil, action: action, for: .allTouchEvents)
        return button
    }
    func updateUIView(_ button: UIButton, context: Context) {}
}
