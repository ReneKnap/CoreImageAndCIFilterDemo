//
//  ImageNavigation.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 12.12.21.
//

import SwiftUI
import Combine


struct ImageFileNavigation: View {
    @ObservedObject
    var model: Model
    
    var body: some View {
        HStack(alignment: .center, spacing: 44) {
            Group{
                Button("Load Image") {
                    withAnimation {
                        model.isShowPicker.toggle()
                    }
                }
                Button("Save Image") {
                    let imageSaver = ImageSaver()
                    imageSaver.writeToPhotoAlbum(image: model.currentImage)
                }
                Button("Detect Face") {
                    print("Detect Face")
                }
            }
            .frame(width: 120, height: 44, alignment: .center)
            .background(Color(level: 5))
            .cornerRadius(12)
            .foregroundColor(.white)
        }
    }
}


struct ImagePicker: UIViewControllerRepresentable {

    @Environment(\.presentationMode)
    var presentationMode

    @Binding var image2: UIImage?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

        @Binding var presentationMode: PresentationMode
        @Binding var image2: UIImage?

        init(presentationMode: Binding<PresentationMode>, image2: Binding<UIImage?>) {
            _presentationMode = presentationMode
            _image2 = image2
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            image2 = uiImage
            presentationMode.dismiss()

        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            presentationMode.dismiss()
        }

    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: presentationMode, image2: $image2)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePicker>) {

    }
}


class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
}
