//
//  QuestionListView.swift
//  Romak_C2
//
//  Created by 준호 on 4/13/25.
//

import Foundation
import SwiftUI
import SwiftData

enum UserFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case mentor = "Mentor"
    case learner = "Learner"
    
    var id: String { self.rawValue }
}

enum VisibilityFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case visible = "Visible"
    case unvisible = "Unvisible"
    
    var id: String { self.rawValue }
}

enum SortOption: String, CaseIterable, Identifiable {
    case dateDescending = "날짜 내림차순"
    case dateAscending = "날짜 오름차순"
    case ratingDescending = "평점 내림차순"
    case ratingAscending = "평점 오름차순"
    
    var id: String { self.rawValue }
}

struct QuestionListView: View {
    @Query private var allQuestions: [Question]
    
    @State private var selectedUser: UserFilter = .all
    @State private var selectedVisibility: VisibilityFilter = .all
    @State private var selectedSort: SortOption = .dateDescending
    
    var filteredQuestions: [Question] {
        var filtered = allQuestions
            .filter { question in
                switch selectedUser {
                case .mentor: return question.mode == .mentor
                case .learner: return question.mode == .learner
                case .all: return true
                }
            }
            .filter { question in
                let avg = question.averageRating
                switch selectedVisibility {
                case .visible: return avg > 2.0
                case .unvisible: return avg <= 2.0
                case .all: return true
                }
            }
        
        switch selectedSort {
        case .dateDescending:
            return filtered.sorted { $0.dateAdded > $1.dateAdded }
        case .dateAscending:
            return filtered.sorted { $0.dateAdded < $1.dateAdded }
        case .ratingDescending:
            return filtered.sorted { $0.averageRating > $1.averageRating }
        case .ratingAscending:
            return filtered.sorted { $0.averageRating < $1.averageRating }
        }
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
                    VStack(spacing: 8) {
                        // 첫 줄: 유저 + 제시
                        HStack {
                            Text("유저 분류")
                                .foregroundColor(.black)
                                .bold()
                            Picker("", selection: $selectedUser) {
                                ForEach(UserFilter.allCases) { user in
                                    Text(user.rawValue).tag(user)
                                }
                            }
                            .pickerStyle(.menu)

                            Text("제시 여부")
                                .foregroundColor(.black)
                                .bold()
                            Picker("", selection: $selectedVisibility) {
                                ForEach(VisibilityFilter.allCases) { visibility in
                                    Text(visibility.rawValue).tag(visibility)
                                }
                            }
                            .pickerStyle(.menu)
                        }

                        // 두 번째 줄: 정렬
                        HStack {
                            Text("정렬")
                                .foregroundColor(.black)
                                .bold()
                            Picker("", selection: $selectedSort) {
                                ForEach(SortOption.allCases) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)

                    // 🔹 리스트
                    if filteredQuestions.isEmpty {
                        Text("조건에 맞는 질문이 없습니다.")
                            .foregroundColor(.black)
                            .font(.title3)
                            .padding()
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(filteredQuestions) { question in
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(formatDate(question.dateAdded))
                                            .foregroundColor(.black)
                                            .font(.custom("GmarketSansTTFLight", size: 12))
                                        
                                        Text(question.content)
                                            .foregroundColor(.black)
                                            .font(.custom("GmarketSansTTFMedium", size: 18))
                                            .padding(.top, 5)
                                            .padding(.bottom, 5)

                                        HStack {
                                            Text("\(question.mode == .mentor ? "멘토" : "러너") 모드로부터 추가")
                                                .foregroundColor(.gray)
                                                .font(.custom("GmarketSansTTFBold", size: 12))
                                            Spacer()
                                            Text("⭐️ \(question.averageRating, specifier: "%.1f")")
                                                .font(.custom("GmarketSansTTFBold", size: 12))
                                        }
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color(hex: "AAAAAA"), lineWidth: 1))
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.top, 4)
                        }
                    }

                    Spacer()
                }
                .padding(.top)
                .navigationTitle("전체 질문 목록")
                .padding(.top, 44)
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm" // ⏰ 시간 포함!
        return formatter.string(from: date)
    }

}
