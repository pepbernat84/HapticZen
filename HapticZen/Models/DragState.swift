import CoreGraphics
import Foundation

/// Represents the instantaneous state of the user's finger drag across the canvas.
struct DragState {
    var isDragging: Bool = false
    var currentPosition: CGPoint = .zero
    var previousPosition: CGPoint = .zero
    var lastTimestamp: TimeInterval = 0
    var velocity: CGFloat = 0 // Points per second
    var totalDistanceTraveled: CGFloat = 0

    /// Updates the drag state with a new position and timestamp, calculating velocity.
    mutating func update(to newPosition: CGPoint, timestamp: TimeInterval = Date().timeIntervalSinceReferenceDate) {
        if !isDragging {
            isDragging = true
            currentPosition = newPosition
            previousPosition = newPosition
            lastTimestamp = timestamp
            velocity = 0
            totalDistanceTraveled = 0
            return
        }

        let timeDelta = timestamp - lastTimestamp
        let stepDistance = currentPosition.distance(to: newPosition)
        totalDistanceTraveled += stepDistance

        if timeDelta > 0.001 {
            // Smooth velocity using a weighted average and clamp raw velocity to avoid astronomical timing spikes
            let rawVelocity = min(2000, stepDistance / CGFloat(timeDelta))
            velocity = (velocity * 0.4) + (rawVelocity * 0.6)
        }

        previousPosition = currentPosition
        currentPosition = newPosition
        lastTimestamp = timestamp
    }

    /// Resets the drag state when touch ends.
    mutating func endDrag() {
        isDragging = false
        velocity = 0
    }
}
