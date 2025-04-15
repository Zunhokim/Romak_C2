//
//  MentorView.swift
//  Romak_C2
//
//  Created by 준호 on 4/13/25.
//

import SwiftUI
import SwiftData

struct MentorView: View {
    @Environment(\.modelContext) private var context
    @Query private var allQuestions: [Question]
    
    var mentorQuestions: [Question] {
        allQuestions.filter { $0.mode == .mentor }
    }

    @State private var currentIndex: Int = 0
    @State private var isShowingAddPopup = false
    @State private var newQuestionContent = ""

    var body: some View {
        let total = mentorQuestions.count
        let currentQuestion = total > 0 ? mentorQuestions[currentIndex] : nil

        ZStack {
            Image("PageBG")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 24) {
                Spacer()

                // 질문 번호
                if total > 0 {
                    Text("\(currentIndex + 1) / \(total)")
                        .font(.headline)
                        .foregroundColor(.black)
                }

                Text("Question!")
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)

                if let question = currentQuestion {
                    Text(question.content)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                        .foregroundColor(.black)
                        .padding(.horizontal)
                } else {
                    Text("질문이 없습니다.")
                        .foregroundColor(.black)
                }

                // 별점 + 수치
                if let question = currentQuestion {
                    VStack(spacing: 8) {
                        HStack(spacing: 4) {
                            ForEach(0..<5) { i in
                                Image(systemName: i < Int(question.rating.rounded()) ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                            }
                        }
                        .font(.title2)

                        Text("\(question.rating, specifier: "%.1f")점")
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }
                }

                Spacer()

                // 순환형 버튼
                HStack(spacing: 40) {
                    Button(action: {
                        currentIndex = (currentIndex - 1 + total) % total
                    }) {
                        Text("Previous")
                            .foregroundColor(.black)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color(hex: "#FBF6A4"))
                            .cornerRadius(12)
                    }

                    Button(action: {
                        currentIndex = (currentIndex + 1) % total
                    }) {
                        Text("Next")
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color(hex: "#F08484"))
                            .cornerRadius(12)
                    }
                }
                .padding(.bottom, 40)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Mentor Mode")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add") {
                    isShowingAddPopup = true
                }
            }
        }
        // 커스텀 팝업
        .sheet(isPresented: $isShowingAddPopup) {
            VStack(spacing: 20) {
                Text("새 질문 추가")
                    .font(.headline)

                TextField("질문 내용을 입력하세요", text: $newQuestionContent)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                HStack {
                    Button("취소", role: .cancel) {
                        isShowingAddPopup = false
                        newQuestionContent = ""
                    }

                    Button("추가") {
                        addQuestion()
                        isShowingAddPopup = false
                    }
                }
            }
            .padding()
            .presentationDetents([.height(250)]) // 고정 높이 시트
        }
    }

    private func addQuestion() {
        guard !newQuestionContent.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let new = Question(
            id: Int.random(in: 1000...9999),
            mode: .mentor,
            content: newQuestionContent,
            rating: 0.0
        )

        context.insert(new)
        try? context.save()
        newQuestionContent = ""
        currentIndex = mentorQuestions.count - 1
    }
}
