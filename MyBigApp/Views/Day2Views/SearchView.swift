//
//  SearchView.swift
//  MyBigApp
//
//  Created by Alexander Saadia on 04/03/26.
//

import SwiftUI

struct SearchView: View {
    var body: some View {
        NavigationStack {
            VStack {
                
                Spacer()
                    .containerRelativeFrame(.vertical, count: 5, span: 1, spacing: 0)
                
                HStack {
                    
                    Spacer()
                    
                    Rectangle()
                        .frame(width: 100, height: 100)
                    
                    VStack {
                        HStack {
                            Text ("Wildest Dreams")
                                .font(.system(size: 30.0, weight: .semibold, design: .default))
                            Spacer()
                        }
                        HStack {
                            Text ("Tylor Swift")
                            
                            Spacer()
                        }
                    }
                }
                .padding(5)
                
                Spacer()
                
                HStack {
                    
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 50.0))
                        .foregroundStyle(.theBlue)
                    
                    Spacer()
                        .containerRelativeFrame(.horizontal, count: 90, span: 32, spacing: 0)
                    
                    
                    
                    Text("Remove from                Favorites")
                        .foregroundStyle(.blue)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 50.0))
                        .foregroundStyle(.darkRed)
                    
                }
                .padding(15)
                
                
                
                HStack {
                    VStack {
                        HStack {
                            Text ("Store Links")
                                .font(.system(size: 25.0, weight: .semibold, design: .default))
                            Spacer()
                        }
                        .padding(2)
                        
                        HStack {
                            Text ("View artist")
                                .foregroundStyle(.blue)
                            Spacer()
                        }
                        .padding(2)
                        
                        HStack {
                            Text ("View album")
                                .foregroundStyle(.blue)
                            
                            Spacer()
                        }
                        .padding(2)
                    }
                    Spacer()
                }
                .padding(10)
                
                Spacer()
                    .containerRelativeFrame(.vertical, count: 3, span: 2, spacing: 0)
                
            }
            
            .toolbar {
                
                ToolbarItem(placement: .topBarLeading) {
                    
                    Button(action: {
                        
                    }) {
                        Image(systemName: "chevron.left")
                        
                    }
                }
            }
        }
    }
}

#Preview {
    MusicView()
}
