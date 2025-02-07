/*
 * M9r
 * Copyright (C) 2025  MAINTAINERS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import SwiftUI

struct QueueItem: View {
    var relativeItemPosition: ComparisonResult?
    var item: Song
    
    var body: some View {
        HStack {
            Group {
                if relativeItemPosition == .orderedSame {
                    Label("Now Playing", systemImage: "speaker.wave.2")
                        .symbolRenderingMode(.multicolor)
                        .fontWeight(.semibold)
                } else {
                    Color.clear
                }
            }
            .frame(width: 16, height: 16)
            
            Text(verbatim: item.title ?? "")
                .fontWeight(
                    relativeItemPosition == .orderedSame ? .semibold : .regular
                )
                .foregroundStyle(
                    relativeItemPosition == .orderedAscending ? .secondary : .primary
                )
        }
    }
}

#Preview {
    @Previewable var song: Song = LibraryPreviewSupport.song
    List {
        QueueItem(relativeItemPosition: .orderedAscending,
                  item: song)
        QueueItem(relativeItemPosition: .orderedSame,
                  item: song)
        QueueItem(relativeItemPosition: .orderedDescending,
                  item: song)
        QueueItem(relativeItemPosition: nil,
                  item: song)
    }
    .padding()
}
