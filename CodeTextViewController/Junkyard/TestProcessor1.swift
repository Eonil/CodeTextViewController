////
////  TestProcessor1.swift
////  CodeTextViewController
////
////  Created by Hoon H. on 2014/12/27.
////  Copyright (c) 2014 Eonil. All rights reserved.
////
//
//import Foundation
//
//
//
//class TestProcessor1: CodeSyntaxHighlightingProcessor {
//	override func done() -> Bool {
//		return	idx < text.length
//	}
//	override func step() {
//		if done() == false {
//			let	aa	=	[
//				NSForegroundColorAttributeName:	NSColor.grayColor(),
//			]
//			let	r	=	NSRange(location: idx, length: 1)
//			text.setAttributes(aa, range: r)
//		}
//	}
//	override func invalidateRange(range: NSRange) {
//		idx	=	0
//	}
//	
//	var	idx	=	0
//}
//
//
//
