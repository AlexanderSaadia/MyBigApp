//
//  ContentView.swift
//  MyBigApp
//
//  Created by Alexander Saadia on 02/03/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        TabView {
            
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                }
            
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar.fill")
                }
            
            AddActivityView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                }
            
            JournalView()
                .tabItem {
                    Image(systemName: "book.fill")
                }
                    
            AIView()
                .tabItem {
                    Image(systemName: "square.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}

