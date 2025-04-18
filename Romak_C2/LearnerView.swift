//
//  RunnerView.swift
//  Romak_C2
//
//  Created by 준호 on 4/13/25.
//

import SwiftUI
import SwiftData

struct LearnerView: View {
    @Environment(\.modelContext) private var context
    @Query private var allQuestions: [Question]

    var learnerQuestions: [Question] {
        allQuestions.filter { $0.mode == .learner }
    }

    var currentQuestion: Question? {
        let total = learnerQuestions.count
        guard total > 0, currentIndex < total else { return nil }
        return learnerQuestions[currentIndex]
    }

    @State private var currentIndex: Int = 0
    @State private var isShowingAddPopup = false
    @State private var isEditing = false
    @State private var newQuestionContent = ""
    @State private var showRatedMessage = false
    @State private var isShowingDeleteAlert = false

    var body: some View {
        let total = learnerQuestions.count

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
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom("GmarketSansTTFBold", size: 24))

                if let question = currentQuestion {
                    Text(question.content)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.custom("GmarketSansTTFLight", size: 20))
                } else {
                    Text("질문이 없습니다.")
                        .foregroundColor(.black)
                        .font(.custom("GmarketSansTTFLight", size: 20))
                }

                Spacer()

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
                        .font(.title)

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

                HStack(spacing: 40) {
                    // 🔸 Previous 버튼
                    Button(action: {
                        currentIndex = (currentIndex - 1 + total) % total
                    }) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(total == 0 ? Color.gray.opacity(0.4) : Color(hex: "#FBF6A4"))
                            .frame(width: 140, height: 60)
                            .overlay(
                                Text("Previous")
                                    .font(.headline)
                                    .foregroundColor(total == 0 ? .gray : .black)
                            )
                    }
                    .disabled(total == 0)

                    // 🔸 Next 버튼
                    Button(action: {
                        currentIndex = (currentIndex + 1) % total
                    }) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(total == 0 ? Color.gray.opacity(0.4) : Color(hex: "F08484"))
                            .frame(width: 140, height: 60)
                            .overlay(
                                Text("Next")
                                    .font(.headline)
                                    .foregroundColor(total == 0 ? .gray : .white)
                            )
                    }
                    .disabled(total == 0)
                }


                Spacer()

                HStack {
                    Button(action: {
                        if let q = currentQuestion {
                            newQuestionContent = q.content
                            isEditing = true
                        }
                    }) {
                        Image(systemName: "pencil")
                            .font(.title)
                            .padding()
                            .foregroundColor(currentQuestion == nil ? .gray.opacity(0.4) : .blue)
                            .clipShape(Circle())
                    }
                    .disabled(currentQuestion == nil)


                    Spacer()

                    Button(action: {
                        isShowingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .font(.title)
                            .padding()
                            .foregroundColor(currentQuestion == nil ? .gray.opacity(0.4) : .red)
                            .clipShape(Circle())
                    }
                    .disabled(currentQuestion == nil) // ✅ 조건에 따라 비활성화
                    .alert("정말 이 질문을 삭제할까요?\n삭제된 질문은 복구되지 않습니다!", isPresented: $isShowingDeleteAlert) {
                        Button("삭제", role: .destructive) {
                            deleteCurrentQuestion()
                        }
                        Button("취소", role: .cancel) {}
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 60)
            }
            .padding()

        }
        .navigationTitle("Learner Mode")
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
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)

                    Button(isEditing ? "수정" : "추가") {
                        if isEditing {
                            updateQuestion()
                        } else {
                            addQuestion()
                        }
                        isShowingAddPopup = false
                        isEditing = false
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
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
            mode: .learner, // ✅ learner로 저장
            content: newQuestionContent,
            ratingHistory: []
        )

        context.insert(new)
        try? context.save()
        newQuestionContent = ""
        currentIndex = learnerQuestions.count - 1
    }

    private func deleteCurrentQuestion() {
        guard let question = currentQuestion else { return }

        context.delete(question)
        try? context.save()
        currentIndex = max(0, min(currentIndex, learnerQuestions.count - 2))
    }

    private func updateQuestion() {
        guard let question = currentQuestion else { return }
        question.content = newQuestionContent
        try? context.save()
        newQuestionContent = ""
    }
}
