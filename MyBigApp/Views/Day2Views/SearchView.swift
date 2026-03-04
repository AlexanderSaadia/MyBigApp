//
//  SearchView.swift
//  MyBigApp
//
//  Created by Alexander Saadia on 04/03/26.
//

import SwiftUI

struct SearchView: View {
    var body: some View {
        VStack {
            HStack {
              
                Spacer()
                
                Rectangle()
                    .frame(width: 100, height: 100)
                
                VStack {
                    HStack {
                        Text ("Wildest Dreams")
                            .font(.system(size: 25.0, weight: .semibold, design: .default))
                        Spacer()
                    }
                    HStack {
                        Text ("Tylor Swift")
                        
                        Spacer()
                    }
                }
            }
            
            Spacer()
            
            HStack {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 50.0))
                    .foregroundStyle(.blue)
                
                Spacer()
                
                Text("Remove from Favorites")
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 50.0))
                    .foregroundStyle(.red)
                    
            }
            
            Spacer()
            
            HStack {
                VStack {
                    HStack {
                        Text ("Store Links")
                            .font(.system(size: 25.0, weight: .semibold, design: .default))
                    }
                    HStack {
                        Text ("View artist")
                            .foregroundStyle(.blue)
                    }
                    HStack {
                        Text ("View album")
                            .foregroundStyle(.blue)
                    }
                }
                Spacer()
            }
          
            
        }
        
        
    }
}


#Preview {
    MusicView()
}
