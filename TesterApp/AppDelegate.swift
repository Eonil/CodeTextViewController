//
//  AppDelegate.swift
//  TesterApp
//
//  Created by Hoon H. on 2014/12/29.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTextStorageDelegate, CodeTextStorageDelegate, SyntaxHighlightingControllerDelegate {
	
	@IBOutlet weak var window: NSWindow!
	
	let	vc	=	CodeTextScrollViewController()
	
	var	sh	:	SyntaxHighlightingController?
	
	func processingWillStart() {
		
	}
	func processingDidFinish() {
		let	r	=	NSRange(location: 0, length: vc.codeTextViewController.codeTextStorage.length)
		vc.codeTextViewController.codeTextView.needsDisplay	=	true
		vc.codeTextViewController.codeTextView.displayIfNeeded()
	}
	func codeTextStorageShouldProcessCharacterEditing(sender: CodeTextStorage, range: NSRange) {
		if sh == nil {
			sh	=	SyntaxHighlightingController(target: sender.text)
			sh!.delegate	=	self
		}
		if sh!.isProcessing {
			sh!.stopProcessing()
		}
//		sh!.startProcessingFromUTF16Location(range.location)
		sh!.startProcessingFromUTF16Location(0)
	}
	
	func applicationDidFinishLaunching(aNotification: NSNotification) {
		window.contentView	=	vc.scrollView
		
//		let	p	=	NSBundle.mainBundle().pathForResource("test-example-50kb", ofType: "rs")!
//		let	p	=	NSBundle.mainBundle().pathForResource("test-example-1kb", ofType: "rs")!
		let	p	=	NSBundle.mainBundle().pathForResource("test-example", ofType: "rs")!
		let	s	=	NSString(contentsOfFile: p, encoding: NSUTF8StringEncoding, error: nil)!
		vc.codeTextViewController.codeTextView.typingAttributes	=	[
			NSForegroundColorAttributeName:	NSColor.redColor(),
		]
		vc.codeTextViewController.codeTextStorage.mutableString.appendString(s)
		vc.codeTextViewController.codeTextView.font	=	NSFont(name: "Menlo", size: NSFont.smallSystemFontSize())
		
		vc.codeTextViewController.codeTextStorage.codeTextStorageDelegate	=	self
	}
}








