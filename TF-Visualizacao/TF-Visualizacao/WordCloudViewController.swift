//
//  ViewController.swift
//  WordCloudTest
//
//  Created by Max Zorzetti on 11/06/19.
//  Copyright © 2019 maxzorzetti. All rights reserved.
//

import UIKit
import JavaScriptCore
import WebKit

class WordCloudViewController: UIViewController {

    private static let htmlWordCloudFile = "wordcloud"
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set WKWebView configurations to better fit mobile devices.
        let source: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);";
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let userContentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        userContentController.addUserScript(script)
        
        // Instantiate WebView
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        
        // Configure WebView's scroll view
        let scrollView = webView.scrollView
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        // Make it so tapping WKWebView refreshes the word cloud
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.delegate = self
        webView.addGestureRecognizer(tapGesture)
        
        // Wrap up and load the .html file
        view.addSubview(webView)
        view.translatesAutoresizingMaskIntoConstraints = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(webView.constrainedExpansion(inside: view))
        
        loadPage()
    }
    
    /// Draws a word cloud with the last words that were set using `setWords(_:)`.
    func drawCloud() {
        execute(command: "drawCloud()")
    }
    
    /// Set the words and their respective sizes to be rendered on the next word cloud draw call.
    /// Maximum word size should be about 500.
    ///
    /// - Parameter words: An array of tuples representing a word and its size.
    func setWords(_ words: [(word: String, size: Int)]) {
        var command = "frequency_list = ["
        for jsObject in words.map({ "{text: '\($0.word)', size: \($0.size)}" }) {
            command.append(jsObject)
            command.append(", ")
        }
        command.removeLast(2)
        command.append("]")
        
        execute(command: command)
    }
    
    /// Fires when the view is tapped, generating a new word cloud.
    @objc private func handleTap() {
        drawCloud()
    }
    
    /// Fires when the .html file has finished loading.
    private func handlePageLoad() {
        // Configure WebView's scroll view
        let scrollView = webView.scrollView
        scrollView.isScrollEnabled = false
        scrollView.panGestureRecognizer.isEnabled = false
        scrollView.contentInsetAdjustmentBehavior = .never
        
        setWordCloudSize(view.frame.size)
        drawCloud()
    }
    
    /// Attempts to execute a JavaScript command inside the web view.
    ///
    /// - Parameter command: The command to be executed
    private func execute(command: String) {
        webView.evaluateJavaScript(command) { (result, error) in
            print(result ?? error?.localizedDescription ?? "'\(command)' executed")
        }
    }

    /// Loads the .html file containing the word cloud.
    private func loadPage() {
        if let url = Bundle.main.url(forResource: WordCloudViewController.htmlWordCloudFile, withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }
    
    /// Sets the size of the word cloud inside the web view.
    ///
    /// - Parameter size: The new size of the word cloud
    private func setWordCloudSize(_ size: CGSize) {
        // Yields the following, harmless, error: "JavaScript execution returned a result of an unsupported type"
        let resizeCommand = "layout.size([\(size.width), \(size.height)])"
        execute(command: resizeCommand)
    }
    
    /// Fires when the device is rotated.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        setWordCloudSize(size)
        drawCloud()
    }
}

extension WordCloudViewController: WKNavigationDelegate {
    
    /// Fires when the web view has finished loading the .html file containing the word cloud.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        handlePageLoad()
    }
}

extension WordCloudViewController: UIScrollViewDelegate {
    
    /// Stops the web view from zooming in when double-tapped. Might be unnecessary.
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
    
    /// Same as above.
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    
    /// Forcefully stops the view from scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset = .zero//CGPoint(x: 15, y: 15)
    }
}

extension WordCloudViewController: UIGestureRecognizerDelegate {

    /// Allows the use of gesture recognizers on the web view.
    /// Without this, gestures are delegated to the web engine of the view.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
