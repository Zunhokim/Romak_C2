//
//  MentorView.swift
//  Romak_C2
//
//  Created by 준호 on 4/13/25.
//

import SwiftUI
import SwiftData

struct MentorView: View {
    
    @Environment(\.modelContext) private var context // DB context
    
    @Query private var allQuestions: [Question]
    
    var mentorQuestions: [Question] {
        allQuestions.filter { $0.mode == .mentor }
    }
    @State private var isShowingAddPopup = false
    @State private var newQuestionContent = ""
    
    var body: some View {
        ZStack{
            Image("PageBG")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                List {
                    ForEach(mentorQuestions) { question in
                        VStack(alignment: .leading) {
                            Text(question.content)
                                .font(.headline)
                            Text("⭐️ \(question.rating, specifier: "%.1f")")
                                .font(.subheadline)
                        }
                        .padding(.vertical, 4)
                    }
                    .scrollContentBackground(.hidden)
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
            
            //팝업 모달
            .alert("새 질문 추가", isPresented: $isShowingAddPopup) {
                TextField("질문 내용을 입력하세요", text: $newQuestionContent)
                Button("추가", action: addQuestion)
                Button("취소", role: .cancel) {}
            }
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
    }
}

