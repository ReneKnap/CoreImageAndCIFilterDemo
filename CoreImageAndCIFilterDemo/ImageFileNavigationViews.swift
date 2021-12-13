//
//  ImageNavigation.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 12.12.21.
//

import SwiftUI
import Combine


struct ImageFileNavigation: View {
    @EnvironmentObject
    var vm: FilterEditor.ViewModel
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                imageIO
                
                Spacer()
                
                toggles
            }
            
            Headline("Settings")
        }.frame(height: minimumTappableLenght)
        .padding(.horizontal, 10)
    }
    
    var imageIO: some View {
        HStack(spacing: 0) {
            IconButton(systemName: "square.and.arrow.down", yOffset: -2) {
                withAnimation {
                    vm.isShowPicker.toggle()
                }
            }
            
            IconButton(systemName: "square.and.arrow.up", yOffset: -2) {
                vm.save()
            }.disabled(vm.filteredImage == nil)
            .alert(isPresented: $vm.showImageSavedAlert) {
                Alert(
                    title: Text("Saved"),
                    message: Text("Image is saved to your Album")
                )
            }
        }
    }
    
    var toggles: some View {
        HStack(spacing: 5) {
            IconToggle(isActive: $vm.isChainingOn, systemName: "plus.rectangle.on.rectangle")
            IconToggle(isActive: $vm.isFaceDetectionOn, systemName: "face.dashed")
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
