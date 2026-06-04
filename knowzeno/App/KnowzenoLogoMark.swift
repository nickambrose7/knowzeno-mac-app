//
//  KnowzenoLogoMark.swift
//  knowzeno
//

import SwiftUI

struct KnowzenoLogoMark: View {
    var body: some View {
        ZStack {
            TopLogoPanel()
                .fill(Color(red: 0.06, green: 0.55, blue: 0.56))

            LeftLogoPanel()
                .fill(Color(red: 0.02, green: 0.43, blue: 0.52))

            RightLogoPanel()
                .fill(Color(red: 0.96, green: 0.61, blue: 0.10))
        }
        .overlay {
            LogoOpening()
                .fill(.black)
                .blendMode(.destinationOut)
        }
        .compositingGroup()
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}

private struct TopLogoPanel: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: scaled(CGPoint(x: 10, y: 32), in: rect))
        path.addQuadCurve(
            to: scaled(CGPoint(x: 18, y: 25), in: rect),
            control: scaled(CGPoint(x: 11, y: 28), in: rect)
        )
        path.addLine(to: scaled(CGPoint(x: 42, y: 10), in: rect))
        path.addQuadCurve(
            to: scaled(CGPoint(x: 58, y: 10), in: rect),
            control: scaled(CGPoint(x: 50, y: 5), in: rect)
        )
        path.addLine(to: scaled(CGPoint(x: 82, y: 25), in: rect))
        path.addQuadCurve(
            to: scaled(CGPoint(x: 90, y: 32), in: rect),
            control: scaled(CGPoint(x: 89, y: 28), in: rect)
        )
        path.addQuadCurve(
            to: scaled(CGPoint(x: 83, y: 41), in: rect),
            control: scaled(CGPoint(x: 91, y: 38), in: rect)
        )
        path.addLine(to: scaled(CGPoint(x: 62, y: 54), in: rect))
        path.addCurve(
            to: scaled(CGPoint(x: 38, y: 54), in: rect),
            control1: scaled(CGPoint(x: 59, y: 46), in: rect),
            control2: scaled(CGPoint(x: 41, y: 46), in: rect)
        )
        path.addLine(to: scaled(CGPoint(x: 17, y: 41), in: rect))
        path.addQuadCurve(
            to: scaled(CGPoint(x: 10, y: 32), in: rect),
            control: scaled(CGPoint(x: 9, y: 38), in: rect)
        )
        path.closeSubpath()

        return path
    }
}

private struct LeftLogoPanel: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: scaled(CGPoint(x: 8, y: 40), in: rect))
        path.addLine(to: scaled(CGPoint(x: 37, y: 58), in: rect))
        path.addQuadCurve(
            to: scaled(CGPoint(x: 49, y: 69), in: rect),
            control: scaled(CGPoint(x: 43, y: 62), in: rect)
        )
        path.addLine(to: scaled(CGPoint(x: 49, y: 94), in: rect))
        path.addLine(to: scaled(CGPoint(x: 13, y: 73), in: rect))
        path.addQuadCurve(
            to: scaled(CGPoint(x: 8, y: 65), in: rect),
            control: scaled(CGPoint(x: 8, y: 72), in: rect)
        )
        path.addLine(to: scaled(CGPoint(x: 8, y: 40), in: rect))
        path.closeSubpath()

        return path
    }
}

private struct RightLogoPanel: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: scaled(CGPoint(x: 92, y: 40), in: rect))
        path.addLine(to: scaled(CGPoint(x: 63, y: 58), in: rect))
        path.addQuadCurve(
            to: scaled(CGPoint(x: 51, y: 69), in: rect),
            control: scaled(CGPoint(x: 57, y: 62), in: rect)
        )
        path.addLine(to: scaled(CGPoint(x: 51, y: 94), in: rect))
        path.addLine(to: scaled(CGPoint(x: 87, y: 73), in: rect))
        path.addQuadCurve(
            to: scaled(CGPoint(x: 92, y: 65), in: rect),
            control: scaled(CGPoint(x: 92, y: 72), in: rect)
        )
        path.addLine(to: scaled(CGPoint(x: 92, y: 40), in: rect))
        path.closeSubpath()

        return path
    }
}

private struct LogoOpening: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let circleDiameter = rect.width * 0.26
        let circleOrigin = CGPoint(
            x: rect.midX - circleDiameter / 2,
            y: rect.minY + rect.height * 0.43
        )
        let channelWidth = rect.width * 0.12
        let channelRect = CGRect(
            x: rect.midX - channelWidth / 2,
            y: circleOrigin.y + circleDiameter * 0.58,
            width: channelWidth,
            height: rect.maxY - circleOrigin.y
        )

        path.addEllipse(in: CGRect(origin: circleOrigin, size: CGSize(width: circleDiameter, height: circleDiameter)))
        path.addRect(channelRect)
        return path
    }
}

nonisolated private func scaled(_ point: CGPoint, in rect: CGRect) -> CGPoint {
    CGPoint(
        x: rect.minX + rect.width * point.x / 100,
        y: rect.minY + rect.height * point.y / 100
    )
}

#Preview {
    KnowzenoLogoMark()
        .frame(width: 128, height: 128)
        .padding()
}
