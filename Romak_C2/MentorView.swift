//
//  MentorView.swift
//  Romak_C2
//
//  Created by 준호 on 4/13/25.
//

import SwiftUI

struct MentorView: View {
    var body: some View {
        ZStack{
            Image("PageBG")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
            }
            .navigationTitle("멘토 모드")
        }
    }
}

#Preview {
    NavigationView {
        MentorView()
    }
}
