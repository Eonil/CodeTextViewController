//
//  AppDelegate.swift
//  TesterApp
//
//  Created by Hoon H. on 2014/12/29.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTextStorageDelegate, CodeTextStorageDelegate, BlockColoringControllerDelegate {
	
	@IBOutlet weak var window: NSWindow!
	
	let	vc	=	CodeTextScrollViewController()
	
	var	sh	:	BlockColoringController?
	
	func syntaxHighlightingDidInvalidateDisplay() {
		let	lm	=	vc.codeTextViewController.codeTextView.layoutManager!
		let	b1	=	vc.codeTextViewController.codeTextView.bounds
		let	r1	=	lm.glyphRangeForBoundingRectWithoutAdditionalLayout(b1, inTextContainer: vc.codeTextViewController.codeTextView.textContainer!)
		let	r2	=	lm.characterRangeForGlyphRange(r1, actualGlyphRange: nil)
		vc.codeTextViewController.codeTextView.layoutManager!.invalidateDisplayForCharacterRange(r2)
	}
	func codeTextStorageShouldProcessCharacterEditing(sender: CodeTextStorage, range: NSRange) {
		if sh == nil {
			sh	=	BlockColoringController(storage: sender, layout: vc.codeTextViewController.codeTextView.layoutManager!)
			sh!.delegate	=	self
		}
		if sh!.isProcessing {
			sh!.stopProcessing()
		}
		sh!.startProcessingFromUTF16Location(range.location)
	}
	
	func applicationDidFinishLaunching(aNotification: NSNotification) {
		window.contentView	=	vc.scrollView
		
		let	p	=	NSBundle.mainBundle().pathForResource("text-example2-50kb", ofType: "rs")!
//		let	p	=	NSBundle.mainBundle().pathForResource("text-example2-500kb", ofType: "rs")!
//		let	p	=	NSBundle.mainBundle().pathForResource("test-example-500kb", ofType: "rs")!
//		let	p	=	NSBundle.mainBundle().pathForResource("test-example-1kb", ofType: "rs")!
//		let	p	=	NSBundle.mainBundle().pathForResource("test-example", ofType: "rs")!
		let	s	=	NSString(contentsOfFile: p, encoding: NSUTF8StringEncoding, error: nil)!
		vc.codeTextViewController.codeTextView.typingAttributes	=	[
			NSForegroundColorAttributeName:	NSColor.redColor(),
		]
		vc.codeTextViewController.codeTextStorage.mutableString.appendString(s)
		vc.codeTextViewController.codeTextView.font	=	NSFont(name: "Menlo", size: NSFont.smallSystemFontSize())
		
		vc.codeTextViewController.codeTextStorage.codeTextStorageDelegate	=	self
		
		////
		
		self.codeTextStorageShouldProcessCharacterEditing(vc.codeTextViewController.codeTextStorage, range: NSRange(location: 0, length: 0))
	}
}








