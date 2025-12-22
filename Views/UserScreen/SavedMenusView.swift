import SwiftUI

struct SavedMenusView: View {
    let restaurantId: Int
    @State private var savedMenus: [CustomMenu] = []
    @State private var showDeleteConfirmation = false
    @State private var menuToDelete: UUID?
    @Environment(\.dismiss) var dismiss
    
    var onSelectMenu: ((CustomMenu) -> Void)?
    
    var body: some View {
        NavigationView {
            List {
                if savedMenus.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bookmark.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No Saved Menus")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Save your favorite menu selections to access them later")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(savedMenus) { menu in
                        SavedMenuRowView(
                            menu: menu,
                            onTap: {
                                onSelectMenu?(menu)
                                dismiss()
                            },
                            onDelete: {
                                menuToDelete = menu.id
                                showDeleteConfirmation = true
                            }
                        )
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                menuToDelete = menu.id
                                showDeleteConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Saved Menus")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Delete Menu", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    menuToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let id = menuToDelete {
                        LocalMenuStorage.shared.deleteCustomMenu(id: id)
                        loadSavedMenus()
                        menuToDelete = nil
                    }
                }
            } message: {
                Text("Are you sure you want to delete this saved menu?")
            }
            .onAppear {
                loadSavedMenus()
            }
        }
    }
    
    private func loadSavedMenus() {
        savedMenus = LocalMenuStorage.shared.loadCustomMenus(for: restaurantId)
            .sorted { $0.createdAt > $1.createdAt } // Most recent first
    }
}

struct SavedMenuRowView: View {
    let menu: CustomMenu
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Menu content - tappable
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(menu.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("Rs \(Int(menu.totalPrice))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                    
                    if let restaurantName = menu.restaurantName {
                        Text(restaurantName)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Label("\(menu.selectedDishes.count) items", systemImage: "fork.knife")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(menu.createdAt, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Delete button - always visible
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.title3)
                    .padding(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

