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
                    Image(systemName: "house.fill")
                }
                .tag(1)
            
            FavoritesView()
                .tabItem {
                    Image(systemName: "heart.fill")
                }
                .tag(2)
        }
    }
}
#Preview {
    MusicView()
}
