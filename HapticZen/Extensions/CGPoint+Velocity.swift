import CoreGraphics
import Foundation

extension CGPoint {
    /// Computes the Euclidean distance to another point.
    func distance(to other: CGPoint) -> CGFloat {
        let dx = other.x - self.x
        let dy = other.y - self.y
        return sqrt(dx * dx + dy * dy)
    }

    /// Computes the velocity (points per second) given a previous point and elapsed time.
    func velocity(from previous: CGPoint, timeDelta: TimeInterval) -> CGFloat {
        guard timeDelta > 0 else { return 0 }
        let dist = distance(to: previous)
        return dist / CGFloat(timeDelta)
    }

    /// Interpolates linearly between `self` and `other` by fraction `t` in [0, 1].
    func interpolated(to other: CGPoint, t: CGFloat) -> CGPoint {
        let clampedT = max(0, min(1, t))
        return CGPoint(
            x: self.x + (other.x - self.x) * clampedT,
            y: self.y + (other.y - self.y) * clampedT
        )
    }
}
