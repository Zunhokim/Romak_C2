//
//  QuestionListView.swift
//  Romak_C2
//
//  Created by 준호 on 4/13/25.
//

import SwiftUI
import SwiftData

struct QuestionListView: View {
    @Query private var allQuestions: [Question] // 전체 질문 가져오기

    var body: some View {
        NavigationStack {
            ZStack {
                Image("PageBG")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                VStack {
                    if allQuestions.isEmpty {
                        Text("아직 추가된 질문이 없어요.")
                            .foregroundColor(.white)
                            .font(.title3)
                            .padding()
                    } else {
                        // 🔧 정렬 미리 분리
                        let sortedQuestions = allQuestions.sorted { $0.dateAdded > $1.dateAdded }

                        List {
                            ForEach(sortedQuestions) { question in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(question.content)
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Text("모드: \(question.mode == .mentor ? "멘토" : "러너")")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    Text("⭐️ \(question.averageRating, specifier: "%.1f")")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal)
                    }
                }
                .navigationTitle("All Question List")
            }
        }
    }
}
