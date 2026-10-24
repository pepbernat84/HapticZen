import SwiftUI
import UIKit

struct CanvasView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = CanvasViewModel()
    @State private var isPulsing = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background dark zen palette with ambient meditative breathing glow
                ZStack {
                    Color.zenDarkBackground
                        .ignoresSafeArea()
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.zenGlow.opacity(isPulsing ? 0.12 : 0.08),
                                    Color.zenAccent.opacity(isPulsing ? 0.05 : 0.03),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 20,
                                endRadius: isPulsing ? 220 : 180
                            )
                        )
                        .frame(width: isPulsing ? 440 : 360, height: isPulsing ? 440 : 360)
                        .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.45)
                        .animation(.easeInOut(duration: 4.5).repeatForever(autoreverses: true), value: isPulsing)
                        .onAppear {
                            isPulsing = true
                        }
                }

                // Active Finger Trail / Visual Feedback
                FingerTrailView(
                    dragState: viewModel.dragState,
                    style: appState.preferences.activeVisualStyle(for: appState.preferences.selectedTexture),
                    touchPoints: viewModel.touchPoints,
                    ripples: viewModel.activeRipplePoints,
                    particles: viewModel.activeParticles
                )

                // 3-Finger Tap Gesture Recognizer Layer
                ThreeFingerTapOverlay {
                    viewModel.onDragEnded(texture: appState.preferences.selectedTexture, preferences: appState.preferences)
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        appState.isMenuPresented.toggle()
                    }
                }
            }
            .contentShape(Rectangle())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("accessibility.canvas.label"))
            .accessibilityHint(Text("accessibility.canvas.hint"))
            .accessibilityAddTraits(.allowsDirectInteraction)
            .accessibilityAction(.magicTap) {
                viewModel.onDragEnded(texture: appState.preferences.selectedTexture, preferences: appState.preferences)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    appState.isMenuPresented.toggle()
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        // Edge swipe check: if swipe starts near right edge and moves left, open menu
                        if value.startLocation.x > geometry.size.width - 35 && value.translation.width < -50 {
                            if !appState.isMenuPresented {
                                viewModel.onDragEnded(texture: appState.preferences.selectedTexture, preferences: appState.preferences)
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    appState.isMenuPresented = true
                                }
                            }
                            return
                        }

                        viewModel.onDragChanged(
                            value: value,
                            canvasSize: geometry.size,
                            texture: appState.preferences.selectedTexture,
                            preferences: appState.preferences
                        )
                    }
                    .onEnded { value in
                        viewModel.onDragEnded(texture: appState.preferences.selectedTexture, preferences: appState.preferences)
                    }
            )
            .sheet(isPresented: $appState.isMenuPresented) {
                MenuOverlayView()
                    .environmentObject(appState)
            }
            .onChange(of: appState.isMenuPresented) { isPresented in
                if isPresented {
                    viewModel.onDragEnded(texture: appState.preferences.selectedTexture, preferences: appState.preferences)
                }
            }
            .onChange(of: appState.isStorePresented) { isPresented in
                if isPresented {
                    viewModel.onDragEnded(texture: appState.preferences.selectedTexture, preferences: appState.preferences)
                }
            }
        }
        .sheet(isPresented: $appState.isStorePresented) {
            StoreView()
                .environmentObject(appState)
        }
    }
}

/// A transparent overlay capturing 3-finger taps via UIKit without blocking single-finger drags.
struct ThreeFingerTapOverlay: UIViewRepresentable {
    let action: () -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        let recognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        recognizer.numberOfTouchesRequired = 3
        recognizer.delaysTouchesBegan = false
        recognizer.delaysTouchesEnded = false
        recognizer.delegate = context.coordinator
        view.addGestureRecognizer(recognizer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.action = action
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
        }

        @objc func handleTap() {
            action()
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
    }
}
