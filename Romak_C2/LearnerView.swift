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

    var visibleQuestions: [Question] {
        learnerQuestions.filter { $0.averageRating >= 2.0 }
    }

    var currentQuestion: Question? {
        let total = visibleQuestions.count
        guard total > 0, currentIndex < total else { return nil }
        return visibleQuestions[currentIndex]
    }

    @State private var currentIndex: Int = 0
    @State private var isShowingAddPopup = false
    @State private var isEditing = false
    @State private var newQuestionContent = ""
    @State private var showRatedMessage = false
    @State private var isShowingDeleteAlert = false
    @State private var tempRating: Double = 0
    @State private var showLowRatingMessage = false
    @State private var toastOffset: CGFloat = 1000 // 화면 밖으로 시작

    var body: some View {
        let total = visibleQuestions.count

        ZStack {
            Image("PageBG")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // 1. 상단 타이틀
                    Text("Learner Mode")
                        .font(.custom("Lemon-Regular", size: 28))
                        .foregroundColor(.black)
                        .frame(height: geometry.size.height * 0.20)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Text("\(currentIndex + 1) / \(total)")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(height: geometry.size.height * 0.05)
                        .frame(maxWidth: .infinity, alignment: .center)

                    // 2. 제목
                    Text("Question!")
                        .font(.custom("GmarketSansTTFBold", size: 24))
                        .foregroundColor(.black)
                        .frame(height: geometry.size.height * 0.05)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // 3. 질문 내용
                    if let question = currentQuestion {
                        VStack {
                            Text(question.content)
                                .font(.custom("GmarketSansTTFMedium", size: 20))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                                .lineSpacing(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 10)
                            Spacer()
                        }
                        .frame(height: geometry.size.height * 0.20)
                    } else {
                        Text("질문이 없습니다.")
                            .font(.custom("GmarketSansTTFMedium", size: 20))
                            .foregroundColor(.black)
                            .frame(height: geometry.size.height * 0.20)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    // 4. 별점
                    if let question = currentQuestion {
                        VStack(spacing: 8) {
                            GeometryReader { geo in
                                HStack(spacing: 4) {
                                    Spacer()
                                    ForEach(1...5, id: \.self) { i in
                                        Image(systemName: i <= Int(tempRating) ? "star.fill" : "star")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.yellow)
                                    }
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { value in
                                            let widthPerStar = geo.size.width / 5
                                            let newRating = min(5, max(1, Int(value.location.x / widthPerStar) + 1))
                                            tempRating = Double(newRating)
                                        }
                                        .onEnded { _ in
                                            submitRating(Int(tempRating))
                                        }
                                )
                            }
                            .frame(height: 40)

                            Text("\(question.averageRating, specifier: "%.1f")점")
                                .font(.custom("GmarketSansTTFBold", size: 14))
                                .foregroundColor(.black)

                            if showRatedMessage {
                                Text("평가 완료!")
                                    .font(.custom("GmarketSansTTFBold", size: 14))
                                    .foregroundColor(.green)
                            }
                        }
                        .frame(height: geometry.size.height * 0.10)
                        .frame(maxWidth: .infinity)
                    }

                    // 5. 이동 버튼
                    HStack(spacing: 40) {
                        Button(action: {
                            currentIndex = (currentIndex - 1 + total) % total
                            tempRating = currentQuestion?.averageRating ?? 0
                        }) {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(total == 0 ? Color.gray.opacity(0.4) : Color(hex: "#FBF6A4"))
                                .frame(width: 140, height: 60)
                                .overlay(
                                    Text("Previous")
                                        .font(.custom("Lemon-Regular", size: 14))
                                        .foregroundColor(total == 0 ? .gray : .black)
                                )
                        }
                        .disabled(total == 0)

                        Button(action: {
                            currentIndex = (currentIndex + 1) % total
                            tempRating = currentQuestion?.averageRating ?? 0
                        }) {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(total == 0 ? Color.gray.opacity(0.4) : Color(hex: "F08484"))
                                .frame(width: 140, height: 60)
                                .overlay(
                                    Text("Next")
                                        .font(.custom("Lemon-Regular", size: 14))
                                        .foregroundColor(total == 0 ? .gray : .white)
                                )
                        }
                        .disabled(total == 0)
                    }
                    .frame(height: geometry.size.height * 0.15)

                    // 6. 수정/삭제 버튼
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
                        .disabled(currentQuestion == nil)
                        .alert("정말 이 질문을 삭제할까요?\n삭제된 질문은 복구되지 않습니다!", isPresented: $isShowingDeleteAlert) {
                            Button("삭제", role: .destructive) {
                                deleteCurrentQuestion()
                            }
                            Button("취소", role: .cancel) {}
                        }
                    }
                    .padding(.horizontal)
                    .frame(height: geometry.size.height * 0.25)
                }
                .padding()
                .onAppear {
                    tempRating = currentQuestion?.averageRating ?? 0
                    checkLowRatingQuestions()
                }
            }
            
            // 토스트 메시지
            VStack {
                Spacer()
                if showLowRatingMessage {
                    Text("낮은 평점으로 인해 질문이 제시 되지 않습니다.")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(15)
                        .padding(.bottom, 150)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: showLowRatingMessage)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("추가") {
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
            VStack(spacing: 24) {
                Text(isEditing ? "질문 수정" : "새 질문 추가")
                    .font(.custom("GmarketSansTTFBold", size: 18))
                    .padding(.top, 10)

                TextEditor(text: $newQuestionContent)
                    .frame(height: 100)
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)

                HStack(spacing: 20) {
                    Button("취소", role: .cancel) {
                        isShowingAddPopup = false
                        isEditing = false
                        newQuestionContent = ""
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.3))
                    .foregroundColor(.black)
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

                Spacer()
            }
            .padding()
            .presentationDetents([.fraction(0.4)]) // 🔸 시트 높이 늘림
        }

    }

    private func submitRating(_ stars: Int) {
        guard let question = currentQuestion else { return }
        question.ratingHistory.append(Double(stars))
        try? context.save()
        showRatedMessage = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showRatedMessage = false
        }
        
        // 평점이 2.0 미만으로 내려갔는지 확인
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            let lowRatingQuestions = learnerQuestions.filter { $0.averageRating < 2.0 }
            if !lowRatingQuestions.isEmpty {
                showLowRatingMessage = true
                // 현재 질문이 마지막 질문이고 평점이 2.0 미만이면 첫 번째 질문으로 이동
                if currentIndex == visibleQuestions.count - 1 && question.averageRating < 2.0 {
                    currentIndex = 0
                    tempRating = currentQuestion?.averageRating ?? 0
                }
                // 3초 후에 메시지 숨기기
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showLowRatingMessage = false
                }
            }
        }
    }
    
    // 낮은 평점 질문 확인
    private func checkLowRatingQuestions() {
        let lowRatingQuestions = learnerQuestions.filter { $0.averageRating < 2.0 }
        if !lowRatingQuestions.isEmpty {
            showLowRatingMessage = true
            // 3초 후에 메시지 숨기기
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showLowRatingMessage = false
            }
        } else {
            showLowRatingMessage = false
        }
    }

    private func addQuestion() {
        guard !newQuestionContent.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let new = Question(
            id: Int.random(in: 1000...9999),
            mode: .learner,
            content: newQuestionContent,
            ratingHistory: [3.0] // 기본 평점 3.0으로 설정
        )
        context.insert(new)
        try? context.save()
        newQuestionContent = ""
        currentIndex = visibleQuestions.count - 1
    }

    private func deleteCurrentQuestion() {
        guard let question = currentQuestion else { return }
        context.delete(question)
        try? context.save()
        currentIndex = max(0, min(currentIndex, visibleQuestions.count - 2))
    }

    private func updateQuestion() {
        guard let question = currentQuestion else { return }
        question.content = newQuestionContent
        try? context.save()
        newQuestionContent = ""
    }
}
