//
//  ContentView.swift
//  Romak_C2
//
//  Created by 준호 on 4/13/25.
//

import SwiftUI
import SwiftData

struct  ContentView: View {
    @Environment(\.modelContext) private var context

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
                            SquareButtonYellow(title: "Mentor", color: Color(hex: "#FBF6A4"))
                        }
                        NavigationLink(destination: LearnerView()) {
                            SquareButtonRed(title: "Learner", color: Color(hex: "#F08484"))
                        }
                    }

                    Spacer()
                }

                // ✅ 하단 고정 Show All Questions 버튼
                VStack {
                    Spacer()
                    NavigationLink(destination: QuestionListView()) {
                        Text("Show All Questions >")
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .underline()
                            .padding(.bottom, 80) // 바닥에서 살짝 위로 띄움
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            preloadDefaultQuestionsIfNeeded()
        }
    }

    private func preloadDefaultQuestionsIfNeeded() {
        let descriptor = FetchDescriptor<Question>(
            predicate: #Predicate { $0.isDefault == true }
        )

        if let result = try? context.fetch(descriptor), !result.isEmpty {
            return
        }

        let mentorDefaults = [
            "요즘 아카데미 생활은 좀 어때요?",
            "아카데미에서 이루고 싶은 목표가 한 가지 있다면 무엇인가요?",
            "최근에 가장 흥미롭게 배운 내용이 있다면 무엇인가요?",
            "CBL에 대한 이해가 잘 되어가고 있나요?",
            "본인이 생각하는 성공한 프로젝트의 기준은 뭐에요?",
            "앞으로 아카데미에서 어떤 기술을 더 배우고 싶나요?",
            "아카데미에서 가장 얻어 가고 싶은 스킬은 어떤거에요?",
            "멘토링을 신청한 이유가 어떤건지 물어봐도 될까요?",
            "지금까지 아카데미에서 받은 Care & Support 중, 가장 기억에 남는 건?",
            "아카데미 생활 중 스트레스를 받는다면, 어떻게 관리 하고 있어요?",
            "앞으로 아카데미 이후에, 어떤 진로로 갈지 계획이 있나요?",
            "멘티에게 꼭 해주고 싶은 조언이 있다면?",
            "[시기에 따라 다르게]\n\n이번 첼린지/브릿지 때는 어떤걸 배웠어요?",
            "아카데미에서 가장 편한 사람이 있어요?",
            "[세션에 따라 다르게]\n\n생활 패턴은 좀 어때요? 피곤 하지는 않아요?"
        ]

        for (i, content) in mentorDefaults.enumerated() {
            let q = Question(id: 1000 + i, mode: .mentor, content: content, ratingHistory: [3.0], isDefault: true)
            context.insert(q)
        }

        let learnerDefaults = [
            "멘토는 어떻게 아카데미에 자리 잡게 됐어요?",
            "어려웠던 사람만!\n\n개발 또는 디자인이 너무 어려운데, 어떻게 공부해야 할까요?",
            "프로젝트를 진행 할 때, 주로 어떤 역할을 맡으셨어요?",
            "실무와 아카데미의 첼린지를 수행하는건 어떤 차이가 있을까요?",
            "일치하는 사람만!\n\n개발자로 성장 하려면 가장 중요한 역량이 뭘까요?",
            "첼린지를 할 때, 막혔던 경험이 있나요? 있다면 어떻게 해결 하셨나요?",
            "내 분야에 맞게!\n\n공부 할 때 추천하는 방식이 있나요?\n(개발, 디자인, 비즈니스 등)",
            "가장 기억에 남는 프로젝트는 어떤거에요?",
            "아카데미 생활을 하면서 가장 도움이 되는 팁이 있다면 어떤거에요?",
            "멘토가 생각하는 가장 좋은 팀워크란 어떤거에요?",
            "시간 관리를 어떻게 하는게 가장 효율적일까요?",
            "도메인 세션, 해당 되는 사람만!\n\n개발이랑 디자인을 다 잘해야 할 것 같아서 걱정이에요.",
            "이거 하나는 꼭 아카데미에서 챙겨 가야 한다면 어떤게 있을까요?",
            "해당 되는 사람만!\n\n다른 러너들이랑 더 친해지고 싶은데, 기회가 없는 것 같아 아쉬울 때가 있어요!",
            "주말이나 쉬는 날엔 주로 어떤 걸 하면서 시간을 보내시나요?"
        ]

        for (i, content) in learnerDefaults.enumerated() {
            let q = Question(id: 2000 + i, mode: .learner, content: content, ratingHistory: [3.0], isDefault: true)
            context.insert(q)
        }
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
                    .font(.custom("Lemon-Regular", size: 20))
                    .foregroundColor(.black)
                    .padding(.top, 10)
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
                    .font(.custom("Lemon-Regular", size: 20))
                    .foregroundColor(.white)
                    .padding(.top, 10)
            }
        }
        .contentShape(Rectangle())
    }
}

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        if hexSanitized.count == 6 {
            hexSanitized = "FF" + hexSanitized
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
