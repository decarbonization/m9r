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

import WebKit

@MainActor final class PluginURLSchemeHandler: NSObject, WKURLSchemeHandler {
    init(plugin: Plugin) {
        self.plugin = plugin
        self.pendingTasks = [:]
    }
    
    private let plugin: Plugin
    private var pendingTasks: [ObjectIdentifier: Task<Void, Never>]
    
    func webView(_ webView: WKWebView, start urlSchemeTask: any WKURLSchemeTask) {
        pendingTasks[ObjectIdentifier(urlSchemeTask)] = Task.detached(priority: .userInitiated) {
            defer {
                Task { @MainActor in
                    self.pendingTasks.removeValue(forKey: ObjectIdentifier(urlSchemeTask))
                }
            }
            do {
                guard let url = urlSchemeTask.request.url else {
                    throw URLError(.badURL, userInfo: [
                        NSLocalizedDescriptionKey: "Request URL is missing",
                    ])
                }
                
                let resourceURL = try self.plugin.resourceURL(url.path(percentEncoded: false))
                try Task.checkCancellation()
                let resourceData = try Data(contentsOf: resourceURL,
                                            options: [.mappedIfSafe])
                try Task.checkCancellation()
                urlSchemeTask.didReceive(URLResponse(url: url,
                                                     mimeType: nil,
                                                     expectedContentLength: resourceData.count,
                                                     textEncodingName: nil))
                try Task.checkCancellation()
                urlSchemeTask.didReceive(resourceData)
                try Task.checkCancellation()
                urlSchemeTask.didFinish()
            } catch {
                if !Task.isCancelled {
                    urlSchemeTask.didFailWithError(error)
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: any WKURLSchemeTask) {
        let deadTask = pendingTasks.removeValue(forKey: ObjectIdentifier(urlSchemeTask))
        deadTask?.cancel()
    }
}
