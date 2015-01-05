//
//  AppDelegate.swift
//  TesterApp
//
//  Created by Hoon H. on 2014/12/29.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTextStorageDelegate {
	
	@IBOutlet weak var window: NSWindow!
	
	let	vc	=	CodeTextScrollViewController()
	
	func applicationDidFinishLaunching(aNotification: NSNotification) {
		window.contentView	=	vc.scrollView
		
		let	p	=	NSBundle.mainBundle().pathForResource("test-example-5000kb", ofType: "rs")!
//		let	p	=	NSBundle.mainBundle().pathForResource("test-example-1kb", ofType: "rs")!
//		let	p	=	NSBundle.mainBundle().pathForResource("test-example", ofType: "rs")!
		let	s	=	NSString(contentsOfFile: p, encoding: NSUTF8StringEncoding, error: nil)!
		vc.codeTextViewController.codeTextView.typingAttributes	=	[
			NSForegroundColorAttributeName:	NSColor.redColor(),
		]
		vc.codeTextViewController.codeTextStorage.mutableString.appendString(s)
		vc.codeTextViewController.codeTextView.font	=	NSFont(name: "Menlo", size: NSFont.smallSystemFontSize())
		vc.codeTextViewController.codeTextStorage.delegate	=	self
		
		sh	=	CodeTextViewSyntaxHighlightingController(target: vc.codeTextViewController.codeTextStorage, view:vc.codeTextViewController.codeTextView)
		sh!.startProcessingFromLocation(0)
	}
	
	func textStorageWillProcessEditing(notification: NSNotification) {
		let	ched	=	(UInt(vc.codeTextViewController.codeTextStorage.editedMask) & NSTextStorageEditedOptions.Characters.rawValue) == NSTextStorageEditedOptions.Characters.rawValue
		if ched {
			let	r	=	vc.codeTextViewController.codeTextStorage.editedRange
			sh!.stopProcessing()
			sh!.startProcessingFromLocation(r.location)
		}
	}
//	func textStorageDidProcessEditing(notification: NSNotification) {
//	}
	
	private var	sh:CodeTextViewSyntaxHighlightingController?
}








