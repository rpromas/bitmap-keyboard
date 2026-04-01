//
//  ContentView.swift
//  BitmapKeyboardCanvas
//
//  Created by Romas on 01/04/2026.
//
import Foundation

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // TextField hidden behind
            TextField("", text: $textualDataBuffer)
                .focused($isTextFieldFocused)
                .onChange(of: textualDataBuffer) {
                    
                    let imageKeys = ImageUtils.parseTaggedImages(textualDataBuffer);
                    print(imageKeys)
                    for imageKey in imageKeys {
                        if let imageData = SharedTemporaryImageStorage.shared.getImagePngData(forKey: imageKey),
                           let uiImage = UIImage(data: imageData) {
                            images.append(uiImage)
                        }
                    }
                    
                    if textualDataBuffer == ImageUtils.deleteToken && !images.isEmpty
                    {
                        images.removeLast();
                    }
                    
                    if (!textualDataBuffer.isEmpty) {
                        textualDataBuffer = ""
                    }
                }
            
            if images.isEmpty && !isTextFieldFocused {
                VStack(spacing: 24) {
                    Image("capybaraWaiting")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 40)
                    
                    HStack(spacing: 0) {
                        Text("Waiting for input")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        AnimatedDots()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture {
                    isTextFieldFocused = true
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4)) {
                        ForEach(Array(images.enumerated()), id: \.offset) { _, image in
                            Button {
                                copyStickerToPasteboard(image)
                            } label: {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                    }.padding()
                }
                .background(.white)
                .onTapGesture {
                    isTextFieldFocused = true
                }
            }
        }
    }
    
    @State private var textualDataBuffer: String = ""
    @State private var images: [UIImage] = []
    @FocusState private var isTextFieldFocused: Bool
    
    func copyStickerToPasteboard(_ stickerImage: UIImage) {
        UIPasteboard.general.image = stickerImage
    }
}

struct AnimatedDots: View {
    @State private var dotCount = 0
    
    var body: some View {
        Text(String(repeating: ".", count: dotCount))
            .font(.title3)
            .foregroundStyle(.secondary)
            .frame(width: 24, alignment: .leading)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                    dotCount = (dotCount % 3) + 1
                }
            }
    }
}

#Preview {
    ContentView()
}
