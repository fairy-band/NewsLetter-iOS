
//
//  HomeView.swift
//  NewsLetter
//
//  Created by 이원빈 on 11/22/25.
//

import SwiftUI

import ComposableArchitecture

struct HomeView: View {
    @Bindable var store: StoreOf<HomeReducer>

    @State private var isPresentJobChangeConfirmAlert = false
    @State private var pendingJobChangeCommit: (() -> Void)?

    var body: some View {
        TabView(selection: $store.selectedTab) {
            NavigationStack(path: $store.scope(state: \.recommendPath, action: \.recommendPath)) {
                RecommendView(
                    store: store.scope(state: \.recommendState, action: \.recommend),
                    selectedIndex: $store.selectedIndex,
                    settingButtonTapHandler: { store.send(.settingPressed) }
                )
            } destination: { store in
                switch store.case {
                case .setting(let store):
                    SettingView(store: store)
                }
            }
            .tabItem {
                Image("recommendation_icon")
                Text("추천")
            }
            .tag(HomeReducer.Tab.recommend)

            NavigationStack {
                ExploreView(store: store.scope(state: \.exploreState, action: \.explore))
            }
            .tabItem {
                Image("explore_icon")
                Text("탐색")
            }
            .tag(HomeReducer.Tab.explore)

            NavigationStack {
                ArchiveView(store: store.scope(state: \.archiveState, action: \.archive))
            }
            .tabItem {
                Image("bookmark_icon")
                Text("보관함")
            }
            .tag(HomeReducer.Tab.archive)
        }
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomTabBar(selectedTab: $store.selectedTab)
        }
        .overlay {
            if store.isPresentModal, let selectedIndex = store.selectedIndex {
                SingleModalView(
                    isPresented: $store.isPresentModal,
                    index: selectedIndex,
                    cardData: store.recommendState.cardData[selectedIndex],
                    pointColor: store.recommendState.cardColors[selectedIndex].sub,
                    firstLookHandler: { store.isPresentNotificationPermissionBottomSheet = true }
                )
                .frame(width: Device.width)
                .transition(.opacity)
                .zIndex(Z.carouselModal)
            }
        }
        .overlay {
            if store.isPresentExploreCard, let (card, colorPaletteName) = store.exploreState.selectedCard {
                ExploreCardModalView(
                    isPresented: $store.isPresentExploreCard,
                    cardData: card,
                    pointColor: colorPaletteName.color.toChangeColor()
                )
                .frame(width: Device.width)
                .transition(.opacity)
                .zIndex(Z.carouselModal)
            }
        }
        .draggableBottomSheet(
            isShow: $store.isPresentOnboardingJobBottomSheet,
            dismissHandler: {
                store.send(.recommend(.onboardingJobDetailConfirmed(preferences: nil, workingExperience: nil)))
            }
        ) {
            JobDetailBottomSheet(
                isCategoryChanged: store.recommendState.isCategoryChanged,
                requestChangeConfirmation: requestJobChangeConfirmation
            ) { selectedJobCategory, selectedCareer in
                onboardingJobDetailBottomSheetConfirmHandler(
                    selectedJobCategory: selectedJobCategory,
                    selectedCareer: selectedCareer
                )
            }
        }
        .draggableBottomSheet(
            isShow: $store.isPresentNotificationPermissionBottomSheet,
            dismissHandler: { UserActionHistory.deniedDateWhenSetNotification = Date() }
        ) {
            NotificationPermissionBottomSheet(
                isPresented: $store.isPresentNotificationPermissionBottomSheet,
                successHandler: {
                    store.send(.recommend(.registerUser))
                    store.isPresentToastMessage = true
                }
            )
        }
        .draggableBottomSheet(
            isShow: $store.isPresentNewsletterReportBottomSheet,
            dismissHandler: {},
            cornerRadius: 24,
            showHandleBar: false
        ) {
            NewsletterReportBottomSheet(
                isPresented: $store.isPresentNewsletterReportBottomSheet,
                submitHandler: { dto in
                    store.send(.submitNewsletterReport(dto))
                }
            )
        }
        .toastMessage(
            isPresented: $store.isPresentToastMessage,
            text: "뉴스레터 알림이 신청되었어요",
            bottomPadding: 0
        )
        .reportSuccessToast(
            isPresented: $store.isPresentReportSuccessToast,
            padding: (UIDevice.isSmallScreen ? 24 : 50) + (UIDevice.isSmallScreen ? 36 : 48) + 8
        )
        .reportSuccessToast(
            isPresented: $store.isPresentJobChangeToastMessage,
            text: "변경이 완료되었어요",
            edge: .bottom,
            padding: 75,
            backgroundColor: Color(hex: 0x3F4247),
            textColor: .white
        )
        .confirmAlertDialog(
            isPresented: $isPresentJobChangeConfirmAlert,
            message: JobDetailBottomSheet.changeConfirmationMessage,
            confirmTitle: "변경하기",
            confirmHandler: {
                pendingJobChangeCommit?()
                pendingJobChangeCommit = nil
            }
        )
        .animation(.easeInOut, value: store.isPresentModal)
        .animation(.easeInOut, value: store.isPresentExploreCard)
    }
    
    private func requestJobChangeConfirmation(commit: @escaping () -> Void) {
        pendingJobChangeCommit = commit
        isPresentJobChangeConfirmAlert = true
    }

    private func onboardingJobDetailBottomSheetConfirmHandler(
        selectedJobCategory: Set<Int>,
        selectedCareer: Int
    ) {
        let preferences = selectedJobCategory.map { Preference.allCases[$0] }
        let workingExperience = WorkingExperience.allCases[selectedCareer]
        store.send(.recommend(.onboardingJobDetailConfirmed(
            preferences: preferences,
            workingExperience: workingExperience
        )))
        store.isPresentOnboardingJobBottomSheet = false
        store.isPresentJobChangeToastMessage = true
    }
}

#Preview {
    HomeView(store: Store(initialState: HomeReducer.State()) {
        HomeReducer()
    })
}
