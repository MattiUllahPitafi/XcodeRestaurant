import SwiftUI

struct SaveMenuNameView: View {
    @Binding var menuName: String
    @Binding var isPresented: Bool
    let onSave: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Menu Name").font(.headline)) {
                    TextField("e.g., My Favorite Order, Family Dinner...", text: $menuName)
                        .autocapitalization(.words)
                }
                
                Section(footer: Text("Give your menu selection a memorable name so you can easily find it later.")) {
                    Button {
                        onSave()
                        isPresented = false
                    } label: {
                        HStack {
                            Spacer()
                            Text("Save Menu")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(menuName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Save Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

