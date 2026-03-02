//
//  ContentView.swift
//  MyBigApp
//
//  Created by Alexander Saadia on 02/03/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView(selection: Binding.constant(2)) {
            
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                }
                .tag(1)
            
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar.fill")
                }
                .tag(2)

            AddActivityView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                }
                .tag(3)

            JournalView()
                .tabItem {
                    Image(systemName: "book.fill")
                }
                .tag(4)
                    
            AIView()
                .tabItem {
                    Image(systemName: "square.fill")
                }
                .tag(5)
                
    
        }
    }
}

#Preview {
    ContentView()
}

