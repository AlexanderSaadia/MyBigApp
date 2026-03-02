//
//  HomeView.swift
//  MyBigApp
//
//  Created by Alexander Saadia on 02/03/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {

            HStack {
                Text ("Activities")
                
                Spacer()
            }
        VStack {
            ActivityView(activity: "Running", timesWeekly: "2/7 this week", percentage: "29%")
            ActivityView(activity: "Xbox", timesWeekly: "1/7 this week", percentage: "7%")
            ActivityView(activity: "Skiing", timesWeekly: "2/7 this week", percentage: "14%")
            ActivityView(activity: "Skaiting", timesWeekly: "1/7 this week", percentage: "7%")
            ActivityView(activity: "Basketball", timesWeekly: "1/7 this week", percentage: "90%")
            ActivityView(activity: "Walking", timesWeekly: "7/7 this week", percentage: "100%")
            ActivityView(activity: "GYM", timesWeekly: "7/7 this week", percentage: "7%")
            ActivityView(activity: "Swiming", timesWeekly: "3/7 this week", percentage: "30%")
            
        }
        
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    
                } label: {
                    
                    (Image(systemName: "chevron.backward"))
                    }
                }
            }
        }
    }
}



#Preview {
    ContentView()
}

struct ActivityView: View {
    
    let activity: String
    let timesWeekly: String
    let percentage: String
    
    var body: some View {
        
        Rectangle()
            .fill(Color.gray)
            .overlay {
                
                HStack {
                    
                    VStack(alignment: .leading){
                        Text(activity)
                            .font(.system(size: 25.0, weight: .semibold, design: .default))
                        Text(timesWeekly)
                    }
                    
                    Spacer()
                    
                    Text(percentage)
                        .foregroundStyle(.green)
                }
            }
    }
}

