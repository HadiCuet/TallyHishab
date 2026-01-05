import SwiftUI
import PhotosUI

struct ImagePicker: View {
    @Binding var imageData: Data?
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        VStack(spacing: 12) {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
                
                Button(role: .destructive) {
                    self.imageData = nil
                    selectedItem = nil
                } label: {
                    Label("Remove Image", systemImage: "trash")
                }
                .buttonStyle(.bordered)
            }
            
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Label(imageData == nil ? "Add Image" : "Change Image", systemImage: "photo")
            }
            .buttonStyle(.bordered)
        }
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        imageData = data
                    }
                }
            }
        }
    }
}
