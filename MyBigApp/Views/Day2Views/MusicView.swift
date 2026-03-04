//
//  MusicView.swift
//  MyBigApp
//
//  Created by Alexander Saadia on 04/03/26.
//

import SwiftUI

struct MusicView: View {
    var body: some View {
        TabView(selection: Binding.constant(1)) {
            
            SearchView()
                .tabItem {
                    Image(systemName: "text.page.badge.magnifyingglass")
                    Text ("Search")
                }
                .tag(1)
            
            FavoritesView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text ("Favorites")
                }
                .tag(2)
        }
    }
}
#Preview {
    MusicView()
}
