//
//  ContentView.swift
//  Romak_C2
//
//  Created by 준호 on 4/13/25.
//

import SwiftUI

struct  ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Image("HomeBG")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                // ✅ 가운데 콘텐츠 (Mentor / Learner 버튼)
                VStack {
                    Spacer()

                    HStack(spacing: 10) {
                        NavigationLink(destination: MentorView()) {
                            SquareButtonYellow(title: "\nMentor", color: Color(hex: "#FBF6A4"))
                        }
                        NavigationLink(destination: LearnerView()) {
                            SquareButtonRed(title: "\nLearner", color: Color(hex: "#F08484"))
                        }
                    }

                    Spacer()
                }

                // ✅ 하단 고정 Show All Questions 버튼
                VStack {
                    Spacer()
                    NavigationLink(destination: QuestionListView()) {
                        Text("Show All Questions")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .underline()
                            .padding(.bottom, 80) // 바닥에서 살짝 위로 띄움
                    }
                }
            }


        }
        .navigationBarHidden(true)
    }
}

struct SquareButtonYellow: View {
    var title: String
    var color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(color.opacity(1))
                .frame(width: 160, height: 180)
            
                VStack {
                    Image("Mentor")
                        .resizable()
                        .frame(width: 90, height: 90)
                    
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.black)
                }
        }
        .contentShape(Rectangle())
    }
}

struct SquareButtonRed: View {
    var title: String
    var color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(color.opacity(1))
                .frame(width: 160, height: 180)
            
                VStack {
                    Image("Learner")
                        .resizable()
                        .frame(width: 90, height: 90)
                    
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                }
        }
        .contentShape(Rectangle())
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
