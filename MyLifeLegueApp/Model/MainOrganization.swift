//
//  ContentView.swift
//  MyBigApp
//
//  Created by Alexander Saadia on 02/03/26.
//

import SwiftUI

struct PickerView: View {
    
    @State private var showActivity = false
    
    var body: some View {
        NavigationStack {
            TabView {
                
                Group {
                    if showActivity {
                        ActivitiesView()
                    } else {
                        HomeView()
                    }
                }
                .tabItem {
                    Image(systemName: "house.fill")
                }
                .tag(1)
                
                CalendarView()
                    .tabItem { Image(systemName: "calendar") }
                    .tag(2)
                
                AddActivityView()
                    .tabItem { Image(systemName: "plus.circle.fill") }
                    .tag(3)
                
                JournalView()
                    .tabItem { Image(systemName: "book.fill") }
                    .tag(4)
                
                AIView()
                    .tabItem { Image(systemName: "square.fill") }
                    .tag(5)
            }
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(showActivity ? "Back" : "Activities") {
                        showActivity.toggle()
                    }
                }
            }
        }
    }
}

#Preview {
    PickerView()
}
