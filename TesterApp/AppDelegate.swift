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
		
//		let	p	=	NSBundle.mainBundle().pathForResource("text-example2-500kb", ofType: "rs")!
		let	p	=	NSBundle.mainBundle().pathForResource("text-example2-50kb", ofType: "rs")!
//		let	p	=	NSBundle.mainBundle().pathForResource("test-example-50kb", ofType: "rs")!
//		let	p	=	NSBundle.mainBundle().pathForResource("test-example-1kb", ofType: "rs")!
//		let	p	=	NSBundle.mainBundle().pathForResource("test-example", ofType: "rs")!
		let	s	=	NSString(contentsOfFile: p, encoding: NSUTF8StringEncoding, error: nil)!
		vc.codeTextViewController.codeTextView.typingAttributes	=	[
			NSForegroundColorAttributeName:	NSColor.redColor(),
		]
		vc.codeTextViewController.codeTextStorage.mutableString.appendString(s)
		vc.codeTextViewController.codeTextView.font	=	NSFont(name: "Menlo", size: NSFont.smallSystemFontSize())
		vc.codeTextViewController.codeTextView.layoutManager!.backgroundLayoutEnabled	=	true
		
		////
		
		vc.codeTextViewController.coloringController	=	BlockColoringController(storage: vc.codeTextViewController.codeTextStorage)
		
		assert(vc.codeTextViewController.codeTextStorage.editingDelegate === vc.codeTextViewController)
//		self.codeTextStorageShouldProcessCharacterEditing(vc.codeTextViewController.codeTextStorage, range: NSRange(location: 0, length: 0))
	}
}








