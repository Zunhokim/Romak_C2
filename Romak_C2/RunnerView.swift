//
//  RunnerView.swift
//  Romak_C2
//
//  Created by 준호 on 4/13/25.
//

import SwiftUI

struct RunnerView: View {
    var body: some View {
        ZStack{
            Image("PageBG")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
            }
            .navigationTitle("Runner Mode")
        }
    }
}

#Preview {
    NavigationView {
        RunnerView()
    }
}
