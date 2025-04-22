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
        allQuestions.filter { $0.mode == .mentor && $0.averageRating >= 2.0 }
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
    @State private var isShowingDeleteAlert = false
    @State private var sliderValue: Double = 0.0
    @State private var tempRating: Double = 0
    @State private var refreshID = UUID()
    @State private var showHiddenAlert = false

    var body: some View {
        let total = mentorQuestions.count

        ZStack {
            Image("PageBG")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // 1. 질문 번호 표시
                    Text("Mentor Mode")
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
                                    
                                    let widthPerStar: CGFloat = 30 + 4 // 별 + 간격 기준

                                    HStack(spacing: 4) {
                                        ForEach(1...5, id: \.self) { i in
                                            Image(systemName: i <= Int(tempRating.rounded()) ? "star.fill" : "star")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(.yellow)
                                        }
                                    }
                                    .contentShape(Rectangle()) // 여기까지만 터치 영역으로 설정
                                    .gesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { value in
                                                let totalWidth = widthPerStar * 5
                                                let x = min(max(0, value.location.x), totalWidth)
                                                let newRating = Int(x / widthPerStar)
                                                tempRating = Double(newRating)
                                            }
                                            .onEnded { _ in
                                                submitRating(Int(tempRating))
                                            }
                                    )

                                    Spacer()
                                }
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
                }
            }
        }
        .id(refreshID)
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
            .presentationDetents([.fraction(0.4)])
        }
        .alert("질문 제외 알림", isPresented: $showHiddenAlert) {
            Button("확인", role: .cancel) {
                currentIndex = 0
            }
        } message: {
                Text("점수가 낮아 질문이 제시 되지 않습니다.\n전체 질문 리스트에서 삭제된 질문을 조회할 수 있습니다.")
            
        }
    }

    // MARK: - 별점 평가
    private func submitRating(_ stars: Int) {
        guard let question = currentQuestion else { return }

        question.ratingHistory.append(Double(stars))
        try? context.save()

        // 👉 평균 점수가 2 이하인 경우 Alert + 리프레시
        if question.averageRating < 2.0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showHiddenAlert = true
            }
        } else {
            showRatedMessage = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                showRatedMessage = false
            }
        }
    }


    // MARK: - CRUD
    private func addQuestion() {
        guard !newQuestionContent.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let new = Question(
            id: Int.random(in: 1000...9999),
            mode: .mentor,
            content: newQuestionContent,
            ratingHistory: [3.0]
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
