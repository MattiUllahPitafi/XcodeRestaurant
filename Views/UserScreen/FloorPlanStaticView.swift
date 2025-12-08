import SwiftUI

struct FloorPlanStaticView: View {
    let tables: [Table]
    var onSelect: (Table) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // 🎤 Stage
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.purple.opacity(0.9))
                    .frame(width: 200, height: 60)
                    .overlay(Text("🎤 Stage").foregroundColor(.white).bold())
                
                // Stage Side Tables
                if !tables.filter({ $0.location.lowercased() == "stage" }).isEmpty {
                    VStack(spacing: 10) {
                        Text("🎭 Stage Side Tables")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                    ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(tables.filter { $0.location.lowercased() == "stage" }) { table in
                                    TableCapacityView(table: table)
                                        .onTapGesture {
                                            if table.status.lowercased() == "available" {
                                                onSelect(table)
                                            }
                                        }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // 🪟 Window + 🧱 Wall Side Layout
                    HStack(alignment: .top, spacing: 50) {
                        
                        // 🪟 Window Side
                        if !tables.filter({ $0.location.lowercased() == "window" }).isEmpty {
                            VStack(spacing: 20) {
                                Text("🪟 Window Side")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                
                                VStack(spacing: 10) {
                                    ForEach(tables.filter { $0.location.lowercased() == "window" }) { table in
                                        TableCapacityView(table: table)
                                            .onTapGesture {
                                                if table.status.lowercased() == "available" {
                                                    onSelect(table)
                                                }
                                            }
                                    }
                                }
                                .frame(width: 140)
                            }
                        }
                        
                        Spacer(minLength: 50)
                        
                        // 🧱 Wall Side
                        if !tables.filter({ $0.location.lowercased() == "wall" }).isEmpty {
                            VStack(spacing: 20) {
                                Text("🧱 Wall Side")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                VStack(spacing: 10) {
                                    ForEach(tables.filter { $0.location.lowercased() == "wall" }) { table in
                                        TableCapacityView(table: table)
                                            .onTapGesture {
                                                if table.status.lowercased() == "available" {
                                                    onSelect(table)
                                                }
                                            }
                                    }
                                }
                                .frame(width: 140)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // 🚪 Bottom row
                    HStack(spacing: 100) {
                        VStack {
                            Image(systemName: "stairs")
                                .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.red)
                            Text("Stairs").font(.caption)
                        }
                        VStack {
                            Image(systemName: "door.left.hand.open")
                                .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.orange)
                            Text("Enterence").font(.caption)
                        }
                        VStack {
                            Image(systemName: "toilet")
                                .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.green)
                            Text("Washroom").font(.caption)
                        }
                    }
                    .padding(.top, 20)
                }
            }
        }
    }
}

// MARK: - Reusable Table Capacity View
struct TableCapacityView: View {
    let table: Table
    
    var body: some View {
        let isAvailable = table.status.lowercased() == "available"
        let tableColor: Color = isAvailable ? Color.yellow.opacity(0.8) : Color.gray.opacity(0.4)
        let borderColor: Color = isAvailable ? Color.green : Color.gray
        
        VStack(spacing: 4) {
            // Shapes for different capacities
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
            } else { // capacity 8 or more
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
            
            // Capacity label
            Text("Cap: \(table.capacity)")
                .font(.caption2)
                .foregroundColor(.primary)
            
            // Status label
            Text(table.status)
                .font(.caption2)
                .foregroundColor(.red)
        }
        .padding(4)
        .frame(minWidth: 60)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isAvailable ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: 1)
        )
        .opacity(isAvailable ? 1.0 : 0.6)
        .contentShape(RoundedRectangle(cornerRadius: 8))
    }
}

//
//import SwiftUI
//
//struct FloorPlanStaticView: View {
//    let tables: [Table]
//    var onSelect: (Table) -> Void
//
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 40) {
//
//                // 🎤 Stage
//                RoundedRectangle(cornerRadius: 8)
//                    .fill(Color.purple.opacity(0.9))
//                    .frame(width: 200, height: 60)
//                    .overlay(Text("🎤 Stage").foregroundColor(.white).bold())
//
//                //  Stage Side Tables
//                if !tables.filter({ $0.location.lowercased() == "stage" }).isEmpty {
//                    VStack(spacing: 20) {
//                        Text("🎭 Stage Side Tables")
//                            .font(.headline)
//                            .foregroundColor(.purple)
//
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 30) {
//                                ForEach(tables.filter { $0.location.lowercased() == "stage" }) { table in
//                                    TableCapacityView(table: table)
//                                        .onTapGesture {
//                                            if table.status.lowercased() == "available" {
//                                                onSelect(table)
//                                            } else {
//                                                // optional: give haptic/visual feedback for unavailable table
//                                            }
//                                        }
//
//                                }
//                                .padding(.horizontal)
//                            }
//                        }
//                    }
//
//                    // 🪟 Window + 🧱 Wall Side Layout
//                    HStack(alignment: .top, spacing: 50) {
//
//                        // 🪟 Window Side
//                        if !tables.filter({ $0.location.lowercased() == "window" }).isEmpty {
//                            VStack(spacing: 20) {
//                                Text("🪟 Window Side")
//                                    .font(.headline)
//                                    .foregroundColor(.blue)
//
//                                VStack(spacing: 25) {
//                                    ForEach(tables.filter { $0.location.lowercased() == "window" }) { table in
//                                        TableCapacityView(table: table)
//                                            .background(
//                                                RoundedRectangle(cornerRadius: 8)
//                                                    .fill(table.status.lowercased() == "available"
//                                                          ? Color.yellow.opacity(0.8)
//                                                          : Color.gray.opacity(0.3))
//                                            )
//                                            .overlay(
//                                                RoundedRectangle(cornerRadius: 8)
//                                                    .stroke(table.status.lowercased() == "available" ? Color.green : Color.gray, lineWidth: 2)
//                                            )
//                                            .onTapGesture {
//                                                if table.status.lowercased() == "available" {
//                                                    onSelect(table)
//                                                }
//                                            }
//                                            .opacity(table.status.lowercased() == "available" ? 1.0 : 0.6)
//
//                                    }
//                                }
//                                .frame(width: 140)
//                            }
//
//                            Spacer(minLength: 50)
//
//                            // 🧱 Wall Side
//                            if !tables.filter({ $0.location.lowercased() == "wall" }).isEmpty {
//                                VStack(spacing: 20) {
//                                    Text("🧱 Wall Side")
//                                        .font(.headline)
//                                        .foregroundColor(.gray)
//
//                                    VStack(spacing: 25) {
//                                        ForEach(tables.filter { $0.location.lowercased() == "wall" }) { table in
//                                            TableCapacityView(table: table)
//                                                .background(
//                                                    RoundedRectangle(cornerRadius: 8)
//                                                        .fill(table.status.lowercased() == "available"
//                                                              ? Color.yellow.opacity(0.8)
//                                                              : Color.gray.opacity(0.3))
//                                                )
//                                                .overlay(
//                                                    RoundedRectangle(cornerRadius: 8)
//                                                        .stroke(table.status.lowercased() == "available" ? Color.green : Color.gray, lineWidth: 2)
//                                                )
//                                                .onTapGesture {
//                                                    if table.status.lowercased() == "available" {
//                                                        onSelect(table)
//                                                    }
//                                                }
//                                                .opacity(table.status.lowercased() == "available" ? 1.0 : 0.6)
//
//                                        }
//                                    }
//                                    .frame(width: 140)
//                                }
//                            }
//                                .padding(.horizontal, 20)
//
//                            // 🚪 Bottom row
//                            HStack(spacing: 60) {
//                                VStack {
//                                    Image(systemName: "door.left.hand.open")
//                                        .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.red)
//                                    Text("Entrance").font(.caption)
//                                }
//                                VStack {
//                                    Image(systemName: "stairs")
//                                        .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.orange)
//                                    Text("Stairs").font(.caption)
//                                }
//                                VStack {
//                                    Image(systemName: "toilet")
//                                        .resizable().scaledToFit().frame(width: 40, height: 40).foregroundColor(.green)
//                                    Text("Washroom").font(.caption)
//                                }
//                            }
//                            .padding(.top, 20)
//                        }
//
//                    }
//                }
//            }
//        }
//
//            // MARK: - Reusable Table Capacity View
//            struct TableCapacityView: View {
//                let table: Table
//
//                var body: some View {
//                    // ✅ Compute availability and colors once
//                    let isAvailable = table.status.lowercased() == "available"
//                    let tableColor: Color = isAvailable ? Color.yellow.opacity(0.8) : Color.gray.opacity(0.4)
//                    let borderColor: Color = isAvailable ? Color.green : Color.gray
//
//                    VStack(spacing: 6) {
//                        // Table shapes depending on capacity
//                        if table.capacity == 2 {
//                            HStack(spacing: 6) {
//                                Text("🪑")
//                                Rectangle()
//                                    .fill(tableColor)
//                                    .frame(width: 40, height: 20)
//                                    .cornerRadius(4)
//                                Text("🪑")
//                            }
//                        } else if table.capacity == 4 {
//                            VStack(spacing: 6) {
//                                Text("🪑")
//                                HStack(spacing: 6) {
//                                    Text("🪑")
//                                    Rectangle()
//                                        .fill(tableColor)
//                                        .frame(width: 60, height: 30)
//                                        .cornerRadius(6)
//                                    Text("🪑")
//                                }
//                                Text("🪑")
//                            }
//                        } else { // capacity 8 or more
//                            VStack(spacing: 6) {
//                                HStack(spacing: 6) {
//                                    ForEach(0..<4, id: \.self) { _ in Text("🪑") }
//                                }
//                                Rectangle()
//                                    .fill(tableColor)
//                                    .frame(width: 140, height: 30)
//                                    .cornerRadius(6)
//                                HStack(spacing: 6) {
//                                    ForEach(0..<4, id: \.self) { _ in Text("🪑") }
//                                }
//                            }
//                        }
//
//                        // Capacity label
//                        Text("Cap: \(table.capacity)")
//                            .font(.caption2)
//                            .foregroundColor(.primary)
//
//                        // Status label
//                        Text(table.status)
//                            .font(.caption2)
//                            .foregroundColor(.secondary)
//                    }
//                    .padding(8)
//                    .frame(minWidth: 80)
//                    .background(
//                        RoundedRectangle(cornerRadius: 10)
//                            .fill(Color.white) // neutral card background
//                    )
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(borderColor, lineWidth: 1.5)
//                    )
//                    .opacity(isAvailable ? 1.0 : 0.6) // dim if unavailable
//                    .contentShape(RoundedRectangle(cornerRadius: 10))
//                }
//            }
//
//        }
//  //
//    //struct TableCapacityView: View {
//    //    let table: Table
//    //
//    //    var body: some View {
//    //        VStack(spacing: 6) {
//    //            if table.capacity == 2 {
//    //                HStack(spacing: 4) {
//    //                    Text("🪑")
//    //                    Rectangle()
//    //                        .fill(Color.orange.opacity(0.7))
//    //                        .frame(width: 40, height: 20)
//    //                    Text("🪑")
//    //                }
//    //            } else if table.capacity == 4 {
//    //                VStack(spacing: 4) {
//    //                    Text("🪑")
//    //                    HStack(spacing: 4) {
//    //                        Text("🪑")
//    //                        Rectangle()
//    //                            .fill(Color.orange.opacity(0.7))
//    //                            .frame(width: 60, height: 30)
//    //                        Text("🪑")
//    //                    }
//    //                    Text("🪑")
//    //                }
//    //            } else if table.capacity == 8 {
//    //                VStack(spacing: 4) {
//    //                    HStack(spacing: 4) {
//    //                        ForEach(0..<4, id: \.self) { _ in Text("🪑") }
//    //                    }
//    //                    Rectangle()
//    //                        .fill(Color.orange.opacity(0.7))
//    //                        .frame(width: 140, height: 30)
//    //                    HStack(spacing: 4) {
//    //                        ForEach(0..<4, id: \.self) { _ in Text("🪑") }
//    //                    }
//    //                }
//    //            }
//    //
//    //            Text("Cap: \(table.capacity)")
//    //                .font(.caption2)
//    //                .foregroundColor(.secondary)
//    //        }
//    //        .padding(6)
//    //        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
//    //    }
//    //}
//}
