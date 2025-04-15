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
    
    var currentQuestion: Question? {
        let total = mentorQuestions.count
        guard total > 0, currentIndex < total else { return nil }
        return mentorQuestions[currentIndex]
    }

    @State private var currentIndex: Int = 0
    @State private var isShowingAddPopup = false
    @State private var isEditing = false
    @State private var newQuestionContent = ""

    var body: some View {
        let total = mentorQuestions.count

        ZStack {
            Image("PageBG")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 24) {
                Spacer()

                // 질문 인덱스 표시
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

                // 순환형 이동 버튼
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

                Spacer()

                // 좌우 하단 버튼 (수정/삭제)
                HStack {
                    // 수정 버튼
                    Button(action: {
                        if let q = currentQuestion {
                            newQuestionContent = q.content
                            isEditing = true
                        }
                    }) {
                        Image(systemName: "pencil")
                            .font(.title2)
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .clipShape(Circle())
                    }

                    Spacer()

                    // 삭제 버튼
                    Button(action: deleteCurrentQuestion) {
                        Image(systemName: "trash")
                            .font(.title2)
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 60)
        }
        .navigationTitle("Mentor Mode")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add") {
                    isShowingAddPopup = true
                }
            }
        }
        // 추가/수정 팝업
        .sheet(isPresented: Binding(get: {
            isShowingAddPopup || isEditing
        }, set: { newValue in
            if !newValue {
                isShowingAddPopup = false
                isEditing = false
                newQuestionContent = ""
            }
        })) {
            VStack(spacing: 20) {
                Text(isEditing ? "질문 수정" : "새 질문 추가")
                    .font(.headline)

                TextField("질문 내용을 입력하세요", text: $newQuestionContent)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                HStack {
                    Button("취소", role: .cancel) {
                        isShowingAddPopup = false
                        isEditing = false
                        newQuestionContent = ""
                    }

                    Button(isEditing ? "수정" : "추가") {
                        if isEditing {
                            updateQuestion()
                        } else {
                            addQuestion()
                        }
                        isShowingAddPopup = false
                        isEditing = false
                    }
                }
            }
            .padding()
            .presentationDetents([.height(200)])
        }
    }

    // MARK: - CRUD 함수

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

    private func deleteCurrentQuestion() {
        guard let question = currentQuestion else { return }

        context.delete(question)
        try? context.save()

        // 현재 인덱스가 삭제 후 유효한 범위로 조정
        currentIndex = max(0, min(currentIndex, mentorQuestions.count - 2))
    }

    private func updateQuestion() {
        guard let question = currentQuestion else { return }
        question.content = newQuestionContent
        try? context.save()
        newQuestionContent = ""
    }
}
