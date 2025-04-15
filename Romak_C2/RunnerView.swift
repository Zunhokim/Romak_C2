//
//  RunnerView.swift
//  Romak_C2
//
//  Created by 준호 on 4/13/25.
//

import SwiftUI

struct RunnerView: View {
    var body: some View {
        NavigationStack {
            ZStack{
                Image("PageBG")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .allowsHitTesting(false) // 터치 이벤트 무시
                
                VStack {
                    Spacer()
                }
                .navigationTitle("Runner Mode")
            }
        }
    }
}
