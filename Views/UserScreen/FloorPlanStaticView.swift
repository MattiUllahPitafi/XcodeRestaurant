//
//import SwiftUI
//
//struct FloorPlanStaticView: View {
//    let tables: [Table]
//    var onSelect: (Table) -> Void
//
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//
//                // 🎤 Stage
//                RoundedRectangle(cornerRadius: 8)
//                    .fill(Color.purple.opacity(0.9))
//                    .frame(width: 200, height: 60)
//                    .overlay(
//                        Text("🎤 Stage")
//                            .foregroundColor(.white)
//                            .bold()
//                    )
//
//                // 🎭 Stage Side Tables
//                if !tables.filter({ $0.location.lowercased() == "stage" }).isEmpty {
//                    VStack(spacing: 10) {
//                        Text("🎭 Stage Side Tables")
//                            .font(.headline)
//                            .foregroundColor(.purple)
//
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 15) {
//                                ForEach(tables.filter { $0.location.lowercased() == "stage" }) { table in
//                                    TableCapacityView(table: table)
//                                        .onTapGesture {
//                                            onSelect(table)
//                                        }
//                                        .allowsHitTesting(table.status.lowercased() == "available")
//                                }
//                            }
//                            .padding(.horizontal)
//                        }
//                    }
//                }
//
//                // 🪟 Window + 🧱 Wall Layout
//                HStack(alignment: .top, spacing: 50) {
//
//                    // 🪟 Window Side
//                    if !tables.filter({ $0.location.lowercased() == "window" }).isEmpty {
//                        VStack(spacing: 20) {
//                            Text("🪟 Window Side")
//                                .font(.headline)
//                                .foregroundColor(.blue)
//
//                            VStack(spacing: 10) {
//                                ForEach(tables.filter { $0.location.lowercased() == "window" }) { table in
//                                    TableCapacityView(table: table)
//                                        .onTapGesture {
//                                            onSelect(table)
//                                        }
//                                        .allowsHitTesting(table.status.lowercased() == "available")
//                                }
//                            }
//                            .frame(width: 140)
//                        }
//                    }
//
//                    Spacer(minLength: 50)
//
//                    // 🧱 Wall Side
//                    if !tables.filter({ $0.location.lowercased() == "wall" }).isEmpty {
//                        VStack(spacing: 20) {
//                            Text("🧱 Wall Side")
//                                .font(.headline)
//                                .foregroundColor(.gray)
//
//                            VStack(spacing: 10) {
//                                ForEach(tables.filter { $0.location.lowercased() == "wall" }) { table in
//                                    TableCapacityView(table: table)
//                                        .onTapGesture {
//                                            onSelect(table)
//                                        }
//                                        .allowsHitTesting(table.status.lowercased() == "available")
//                                }
//                            }
//                            .frame(width: 140)
//                        }
//                    }
//                }
//                .padding(.horizontal, 20)
//
//                // 🚪 Bottom Icons
//                HStack(spacing: 100) {
//                    VStack {
//                        Image(systemName: "stairs")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 40, height: 40)
//                            .foregroundColor(.red)
//                        Text("Stairs").font(.caption)
//                    }
//
//                    VStack {
//                        Image(systemName: "door.left.hand.open")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 40, height: 40)
//                            .foregroundColor(.orange)
//                        Text("Entrance").font(.caption)
//                    }
//
//                    VStack {
//                        Image(systemName: "toilet")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 40, height: 40)
//                            .foregroundColor(.green)
//                        Text("Washroom").font(.caption)
//                    }
//                }
//                .padding(.top, 20)
//            }
//        }
//    }
//}
//import SwiftUI
//
//struct TableCapacityView: View {
//    let table: Table
//
//    var body: some View {
//        let isAvailable = table.status.lowercased() == "available"
//
//        let tableColor: Color = isAvailable
//            ? Color.yellow.opacity(0.8)
//            : Color.gray.opacity(0.4)
//
//        let borderColor: Color = isAvailable ? .green : .gray
//
//        VStack(spacing: 4) {
//
//            // 🪑 Table Shapes
//            if table.capacity == 2 {
//                HStack(spacing: 4) {
//                    Text("🪑")
//                    Rectangle()
//                        .fill(tableColor)
//                        .frame(width: 25, height: 12)
//                        .cornerRadius(3)
//                    Text("🪑")
//                }
//
//            } else if table.capacity == 4 {
//                VStack(spacing: 4) {
//                    Text("🪑")
//                    HStack(spacing: 4) {
//                        Text("🪑")
//                        Rectangle()
//                            .fill(tableColor)
//                            .frame(width: 40, height: 18)
//                            .cornerRadius(4)
//                        Text("🪑")
//                    }
//                    Text("🪑")
//                }
//
//            } else {
//                VStack(spacing: 4) {
//                    HStack(spacing: 2) {
//                        ForEach(0..<4, id: \.self) { _ in Text("🪑") }
//                    }
//                    Rectangle()
//                        .fill(tableColor)
//                        .frame(width: 90, height: 18)
//                        .cornerRadius(4)
//                    HStack(spacing: 2) {
//                        ForEach(0..<4, id: \.self) { _ in Text("🪑") }
//                    }
//                }
//            }
//
//            // ℹ️ Labels
//            Text("Cap: \(table.capacity)")
//                .font(.caption2)
//
//            Text(table.status)
//                .font(.caption2)
//                .foregroundColor(.red)
//        }
//        .padding(6)
//        .frame(minWidth: 60)
//        .background(
//            RoundedRectangle(cornerRadius: 8)
//                .fill(isAvailable ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.15))
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 8)
//                .stroke(borderColor, lineWidth: 1)
//        )
//        .opacity(isAvailable ? 1.0 : 0.4)
//        .contentShape(RoundedRectangle(cornerRadius: 8))
//    }
//}
//
import SwiftUI

struct FloorPlanStaticView: View {
    let tables: [Table]
    let selectedTableIds: Set<Int>
    var onToggle: (Table) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // 🎤 Stage
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.purple.opacity(0.9))
                    .frame(width: 200, height: 60)
                    .overlay(
                        Text("🎤 Stage")
                            .foregroundColor(.white)
                            .bold()
                    )

                // 🎭 Stage Side Tables
                if tables.contains(where: { $0.location.lowercased() == "stage" }) {
                    VStack(spacing: 10) {
                        Text("🎭 Stage Side Tables")
                            .font(.headline)
                            .foregroundColor(.purple)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(tables.filter { $0.location.lowercased() == "stage" }) { table in
                                    TableCapacityView(
                                        table: table,
                                        isSelected: selectedTableIds.contains(table.tableId)
                                    )
                                    .onTapGesture {
                                        if table.status.lowercased() == "available" {
                                            onToggle(table)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                // 🪟 Window + 🧱 Wall Layout
                HStack(alignment: .top, spacing: 50) {

                    // 🪟 Window Side
                    if tables.contains(where: { $0.location.lowercased() == "window" }) {
                        VStack(spacing: 20) {
                            Text("🪟 Window Side")
                                .font(.headline)
                                .foregroundColor(.blue)

                            VStack(spacing: 10) {
                                ForEach(tables.filter { $0.location.lowercased() == "window" }) { table in
                                    TableCapacityView(
                                        table: table,
                                        isSelected: selectedTableIds.contains(table.tableId)
                                    )
                                    .onTapGesture {
                                        if table.status.lowercased() == "available" {
                                            onToggle(table)
                                        }
                                    }
                                }
                            }
                            .frame(width: 140)
                        }
                    }

                    Spacer(minLength: 50)

                    // 🧱 Wall Side
                    if tables.contains(where: { $0.location.lowercased() == "wall" }) {
                        VStack(spacing: 20) {
                            Text("🧱 Wall Side")
                                .font(.headline)
                                .foregroundColor(.gray)

                            VStack(spacing: 10) {
                                ForEach(tables.filter { $0.location.lowercased() == "wall" }) { table in
                                    TableCapacityView(
                                        table: table,
                                        isSelected: selectedTableIds.contains(table.tableId)
                                    )
                                    .onTapGesture {
                                        if table.status.lowercased() == "available" {
                                            onToggle(table)
                                        }
                                    }
                                }
                            }
                            .frame(width: 140)
                        }
                    }
                }
                .padding(.horizontal, 20)

                // 🚪 Bottom Icons (UNCHANGED)
                HStack(spacing: 100) {
                    VStack {
                        Image(systemName: "stairs")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.red)
                        Text("Stairs").font(.caption)
                    }

                    VStack {
                        Image(systemName: "door.left.hand.open")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.orange)
                        Text("Entrance").font(.caption)
                    }

                    VStack {
                        Image(systemName: "toilet")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.green)
                        Text("Washroom").font(.caption)
                    }
                }
                .padding(.top, 20)
            }
        }
    }
}
import SwiftUI

struct TableCapacityView: View {
    let table: Table
    let isSelected: Bool

    var body: some View {
        let isAvailable = table.status.lowercased() == "available"

        let tableColor: Color = isAvailable
            ? (isSelected ? Color.green.opacity(0.7) : Color.yellow.opacity(0.8))
            : Color.gray.opacity(0.4)

        let borderColor: Color =
            isSelected ? .green : (isAvailable ? .yellow : .gray)

        VStack(spacing: 4) {

            // 🪑 Table Shapes (UNCHANGED)
            if table.capacity == 2 {
                HStack(spacing: 4) {
                    Text("🪑")
                    Rectangle()
                        .fill(tableColor)
                        .frame(width: 25, height: 12)
                        .cornerRadius(3)
                    Text("🪑")
                }

            } else if table.capacity == 4 {
                VStack(spacing: 4) {
                    Text("🪑")
                    HStack(spacing: 4) {
                        Text("🪑")
                        Rectangle()
                            .fill(tableColor)
                            .frame(width: 40, height: 18)
                            .cornerRadius(4)
                        Text("🪑")
                    }
                    Text("🪑")
                }

            } else {
                VStack(spacing: 4) {
                    HStack(spacing: 2) {
                        ForEach(0..<4, id: \.self) { _ in Text("🪑") }
                    }
                    Rectangle()
                        .fill(tableColor)
                        .frame(width: 90, height: 18)
                        .cornerRadius(4)
                    HStack(spacing: 2) {
                        ForEach(0..<4, id: \.self) { _ in Text("🪑") }
                    }
                }
            }

            Text("Cap: \(table.capacity)")
                .font(.caption2)

            Text(isSelected ? "Selected" : table.status)
                .font(.caption2)
                .foregroundColor(isSelected ? .green : .red)
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.green.opacity(0.15) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
        )
        .opacity(isAvailable ? 1.0 : 0.4)
        .contentShape(RoundedRectangle(cornerRadius: 8))
    }
}
