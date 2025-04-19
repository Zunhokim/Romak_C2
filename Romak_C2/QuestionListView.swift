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
    case dateDescending = "최신순"
    case dateAscending = "오래된순"
    case ratingDescending = "평 높은순"
    case ratingAscending = "평 낮은순"
    
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
                    VStack(spacing: 16) {
                        // 필터 카드들
                        HStack(spacing: 8) {
                            // 유저 분류 필터
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "person.2.fill")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 12))
                                    Text("유저 분류")
                                        .font(.custom("GmarketSansTTFBold", size: 14))
                                        .foregroundColor(.black)
                                        .padding(.top, 4)
                                        .padding(.bottom, 4)
                                }
                                Picker("", selection: $selectedUser) {
                                    ForEach(UserFilter.allCases) { user in
                                        Text(user.rawValue).tag(user)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: .infinity)
                                .padding(4)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(8)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)

                            // 제시 여부 필터
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "eye.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 12))
                                    Text("제시 여부")
                                        .font(.custom("GmarketSansTTFBold", size: 14))
                                        .foregroundColor(.black)
                                        .padding(.top, 4)
                                        .padding(.bottom, 4)
                                }
                                Picker("", selection: $selectedVisibility) {
                                    ForEach(VisibilityFilter.allCases) { visibility in
                                        Text(visibility.rawValue).tag(visibility)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: .infinity)
                                .padding(4)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(8)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)

                            // 정렬 필터
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "arrow.up.arrow.down")
                                        .foregroundColor(.purple)
                                        .font(.system(size: 12))
                                    Text("정렬")
                                        .font(.custom("GmarketSansTTFBold", size: 14))
                                        .foregroundColor(.black)
                                        .padding(.top, 4)
                                        .padding(.bottom, 4)
                                }
                                Picker("", selection: $selectedSort) {
                                    ForEach(SortOption.allCases) { option in
                                        Text(option.rawValue).tag(option)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: .infinity)
                                .padding(4)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(8)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
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
                                        Text(question.isDefault ? "기본 질문" : formatDate(question.dateAdded))
                                            .foregroundColor(.black)
                                            .font(.custom("GmarketSansTTFLight", size: 12))
                                        
                                        Text(question.content)
                                            .foregroundColor(.black)
                                            .font(.custom("GmarketSansTTFMedium", size: 16))
                                            .lineSpacing(8)
                                            .padding(.top, 5)
                                            .padding(.bottom, 5)

                                        HStack {
                                            Text(question.mode == .mentor ? "멘토 모드" : "러너 모드")
                                                .foregroundColor(question.mode == .mentor ? Color(hex: "#F9BF64") : Color(hex: "#F08484"))
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
