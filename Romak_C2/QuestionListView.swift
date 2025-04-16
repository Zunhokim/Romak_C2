//
//  QuestionListView.swift
//  Romak_C2
//
//  Created by 준호 on 4/13/25.
//

import SwiftUI
import SwiftData

enum UserFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case mentor = "Mentor"
    case learner = "Learner"
    
    var id: String { self.rawValue }
}

enum VisibilityFilter: String, CaseIterable, Identifiable {
    case visible = "Visible"
    case unvisible = "Unvisible"
    
    var id: String { self.rawValue }
}

struct QuestionListView: View {
    @Query private var allQuestions: [Question]
    
    @State private var selectedUser: UserFilter = .all
    @State private var selectedVisibility: VisibilityFilter = .visible

    var filteredQuestions: [Question] {
        allQuestions
            .filter { question in
                // 유저 분류 필터링
                switch selectedUser {
                case .mentor: return question.mode == .mentor
                case .learner: return question.mode == .runner
                case .all: return true
                }
            }
            .filter { question in
                // 제시 여부 필터링
                let avg = question.averageRating
                switch selectedVisibility {
                case .visible: return avg > 2.0
                case .unvisible: return avg <= 2.0
                }
            }
            .sorted { $0.dateAdded > $1.dateAdded }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Image("PageBG")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 16) {
                    
                    // 🔹 필터 영역
                    HStack {
                        Text("유저 분류")
                            .foregroundColor(.black)
                        Picker("", selection: $selectedUser) {
                            ForEach(UserFilter.allCases) { user in
                                Text(user.rawValue).tag(user)
                            }
                        }
                        .pickerStyle(.menu)

                        Text("제시 여부")
                            .foregroundColor(.black)
                        Picker("", selection: $selectedVisibility) {
                            ForEach(VisibilityFilter.allCases) { visibility in
                                Text(visibility.rawValue).tag(visibility)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)

                    // 🔹 리스트
                    if filteredQuestions.isEmpty {
                        Text("조건에 맞는 질문이 없습니다.")
                            .foregroundColor(.white)
                            .font(.title3)
                            .padding()
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(filteredQuestions) { question in
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("모드: \(question.mode == .mentor ? "멘토" : "러너")")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)

                                        Text(question.content)
                                            .font(.headline)
                                            .foregroundColor(.black)

                                        HStack {
                                            Text("⭐️ \(question.averageRating, specifier: "%.1f")")
                                            Spacer()
                                            Text(formatDate(question.dateAdded))
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(radius: 2)
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.top, 4)
                        }
                    }

                    Spacer()
                }
                .padding(.top)
                .navigationTitle("All Question List")
                .padding(.top, 44)
            }
        }
    }

    // 날짜 포맷 함수
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}

