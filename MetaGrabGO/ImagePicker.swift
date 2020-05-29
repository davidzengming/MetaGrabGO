//
//  ImagePicker.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-11-26.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import Foundation
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isImagePickerShown: Bool
    @Binding var image: Image?
    @Binding var data: Data?
    @Binding var currentImages: [UUID]
    @Binding var imagesDict: [UUID: Image]
    @Binding var dataDict: [UUID: Data]
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        let maxNumImages = 3
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage

            self.parent.image = Image(uiImage: uiImage!)
            self.parent.data = uiImage!.pngData()

            if self.parent.currentImages.count < self.maxNumImages {
                let newImageId = UUID()
                self.parent.currentImages.append(newImageId)
            }

            self.parent.isImagePickerShown = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.parent.isImagePickerShown = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }
}
