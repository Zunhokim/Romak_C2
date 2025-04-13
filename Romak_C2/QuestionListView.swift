//
//  QuestionListView.swift
//  Romak_C2
//
//  Created by 준호 on 4/13/25.
//

import SwiftUI

struct QuestionListView: View {
    var body: some View {
        ZStack{
            Image("PageBG")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
            }
            .navigationTitle("전체 질문 목록")
        }
    }
}


#Preview {
    NavigationView {
        QuestionListView()
    }
}
