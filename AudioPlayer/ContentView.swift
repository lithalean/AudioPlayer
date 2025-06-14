//
//  ContentView.swift
//  AudioPlayer
//
//  Created by Tyler Allen on 6/14/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            VStack(alignment: .leading, spacing: 12) {
                SidebarItem(title: "Albums", systemImage: "square.grid.2x2", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                
                SidebarItem(title: "Songs", systemImage: "music.note.list", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                
                Divider()
                
                Button(action: {
                    // Add music action
                }) {
                    Label("Add Music", systemImage: "plus")
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
                
                Spacer()
            }
            .padding()
            .frame(minWidth: 200)
        } detail: {
            // Main content area
            Group {
                switch selectedTab {
                case 0:
                    Text("Albums View") // Placeholder until we create AlbumsView
                case 1:
                    Text("Songs View")  // Placeholder until we create SongsView
                default:
                    Text("Albums View")
                }
            }
        }
    }
}

struct SidebarItem: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                    .frame(width: 20)
                Text(title)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .foregroundColor(isSelected ? .accentColor : .primary)
    }
}

#Preview {
    ContentView()
}
