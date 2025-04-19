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
    case all = "전체"
    case mentor = "멘토"
    case learner = "러너"
    
    var id: String { self.rawValue }
}

enum VisibilityFilter: String, CaseIterable, Identifiable {
    case all = "전체"
    case visible = "제시됨"
    case unvisible = "제외됨"
    
    var id: String { self.rawValue }
}

enum SortOption: String, CaseIterable, Identifiable {
    case dateDescending = "최신순"
    case dateAscending = "오래된순"
    case ratingDescending = "평점 높은순"
    case ratingAscending = "평점 낮은순"
    
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
                    VStack(spacing: 12) {
                        // 유저 분류와 제시 여부 한 줄에 배치
                        HStack(spacing: 12) {
                            // 유저 분류 피커
                            HStack(spacing: 8) {
                                HStack(spacing: 4) {
                                    Image(systemName: "person.2.fill")
                                        .foregroundColor(Color(hex: "#F9BF64"))
                                    Text("유저 분류")
                                        .font(.custom("GmarketSansTTFBold", size: 12))
                                }
                                Picker("유저 분류", selection: $selectedUser) {
                                    ForEach(UserFilter.allCases) { user in
                                        Text(user.rawValue).tag(user)
                                    }
                                }
                                .pickerStyle(.menu)
                                .font(.system(size: 14))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(hex: "AAAAAA"), lineWidth: 1))

                            // 제시 여부 피커
                            HStack(spacing: 8) {
                                HStack(spacing: 4) {
                                    Image(systemName: "eye.fill")
                                        .foregroundColor(Color(hex: "#F08484"))
                                    Text("제시 여부")
                                        .font(.custom("GmarketSansTTFBold", size: 12))
                                }
                                Picker("제시 여부", selection: $selectedVisibility) {
                                    ForEach(VisibilityFilter.allCases) { visibility in
                                        Text(visibility.rawValue).tag(visibility)
                                    }
                                }
                                .pickerStyle(.menu)
                                .font(.system(size: 14))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(hex: "AAAAAA"), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                    // 🔹 리스트
                    if filteredQuestions.isEmpty {
                        Text("조건에 맞는 질문이 없습니다.")
                            .foregroundColor(.black)
                            .font(.title3)
                            .padding()
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            // 정렬 피커를 리스트 위에 배치
                            HStack {
                                Spacer()
                                Picker("정렬", selection: $selectedSort) {
                                    ForEach(SortOption.allCases) { option in
                                        Text(option.rawValue).tag(option)
                                    }
                                }
                                .pickerStyle(.menu)
                                .font(.system(size: 12))
                            }
                            .padding(.horizontal)
                            
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
