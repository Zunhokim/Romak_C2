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
    @State private var showRatedMessage = false

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

                if total > 0 {
                    Text("\(currentIndex + 1) / \(total)")
                        .font(.headline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                }

                Text("Question!")
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let question = currentQuestion {
                    Text(question.content)
                        .font(.title2)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("질문이 없습니다.")
                        .foregroundColor(.black)
                }
                
                Spacer()

                // 별점 + 평균 + 평가 완료 메시지
                if let question = currentQuestion {
                    VStack(spacing: 8) {
                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { i in
                                Image(systemName: i <= Int(question.averageRating.rounded()) ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                    .onTapGesture {
                                        submitRating(i)
                                    }
                            }
                        }
                        .font(.title2)

                        Text("\(question.averageRating, specifier: "%.1f")점")
                            .font(.subheadline)
                            .foregroundColor(.black)

                        if showRatedMessage {
                            Text("평가 완료!")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }

                Spacer()

                // 이동 버튼
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

                // 수정 / 삭제
                HStack {
                    Button(action: {
                        if let q = currentQuestion {
                            newQuestionContent = q.content
                            isEditing = true
                        }
                    }) {
                        Image(systemName: "pencil")
                            .font(.title2)
                            .padding()
                            .clipShape(Circle())
                    }

                    Spacer()

                    Button(action: deleteCurrentQuestion) {
                        Image(systemName: "trash")
                            .font(.title2)
                            .padding()
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 60)
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

    // MARK: - 별점 평가
    private func submitRating(_ stars: Int) {
        guard let question = currentQuestion else { return }
        question.ratingHistory.append(Double(stars))
        try? context.save()

        showRatedMessage = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showRatedMessage = false
        }
    }

    // MARK: - CRUD
    private func addQuestion() {
        guard !newQuestionContent.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let new = Question(
            id: Int.random(in: 1000...9999),
            mode: .mentor,
            content: newQuestionContent,
            ratingHistory: []
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
        currentIndex = max(0, min(currentIndex, mentorQuestions.count - 2))
    }

    private func updateQuestion() {
        guard let question = currentQuestion else { return }
        question.content = newQuestionContent
        try? context.save()
        newQuestionContent = ""
    }
}
