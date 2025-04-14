//
//  ContentView.swift
//  Romak_C2
//
//  Created by 준호 on 4/13/25.
//

import SwiftUI

struct  ContentView: View {
    var body: some View {
        ZStack {
            
            Image("HomeBG")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // 가운데 정사각형 멘토/러너 버튼 가로 배치
                HStack(spacing: 20) {
                    // 멘토 모드 버튼
                    NavigationLink(destination: MentorView()) {
                        SquareButton(title: "Mentor", color: Color(hex: "#FBF6A4"))
                    }
                    
                    // 러너 모드 버튼
                    NavigationLink(destination: RunnerView()) {
                        SquareButton(title: "Learner", color: Color(hex: "#F08484"))
                    }
                }
                
                Spacer()
                
                // 하단 텍스트 버튼
                NavigationLink(destination: QuestionListView()) {
                    Text("Show All Questions")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .underline()
                        .padding(.bottom, 40)
                }
            }
        }
        
    }
}

struct SquareButton: View {
    var title: String
    var color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(color.opacity(1))
                .frame(width: 140, height: 140)
            
            Text(title)
                .font(.headline)
        }
    }
}


extension Color {
    // 16진수 색상 코드로부터 색상 생성
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        
        if hexSanitized.count == 6 {
            hexSanitized = "FF" + hexSanitized // #RRGGBB 형식에서 #AARRGGBB로 변환
        }
        
        if let hexValue = Int(hexSanitized, radix: 16) {
            let a = CGFloat((hexValue >> 24) & 0xff) / 255.0
            let r = CGFloat((hexValue >> 16) & 0xff) / 255.0
            let g = CGFloat((hexValue >> 8) & 0xff) / 255.0
            let b = CGFloat(hexValue & 0xff) / 255.0
            self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
        } else {
            self.init(.sRGB, red: 0, green: 0, blue: 0)
        }
    }
}

#Preview {
    NavigationView {
        ContentView()
    }
}
