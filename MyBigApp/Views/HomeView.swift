//
//  HomeView.swift
//  MyBigApp
//
//  Created by Alexander Saadia on 02/03/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        
        Spacer()
        
        Text ("Activities")
        VStack {
            ActivityView(activity: "Running", timesWeekly: "2/7 this week", percentage: "29%")
            ActivityView(activity: "Walking", timesWeekly: "1/7 this week", percentage: "7%")
            ActivityView(activity: "Walking", timesWeekly: "1/7 this week", percentage: "7%")
            ActivityView(activity: "Walking", timesWeekly: "1/7 this week", percentage: "7%")
            ActivityView(activity: "Walking", timesWeekly: "1/7 this week", percentage: "7%")
            ActivityView(activity: "Walking", timesWeekly: "1/7 this week", percentage: "7%")
            ActivityView(activity: "Walking", timesWeekly: "1/7 this week", percentage: "7%")
            
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

