//
//  main.swift
//  PerfTest
//
//  Created by Hoon H. on 2014/12/30.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation
import AppKit

final class Processor1: BlockDetectionProcessorReaction {
	init(targetString:NSMutableAttributedString) {
		self.targetString	=	targetString
	}
	var targetString:NSMutableAttributedString
	func onBlockNone(range:UTF16Range) {
		
	}
	func onBlockIncomplete(range:UTF16Range) {
		
	}
	func onBlockComplete(range:UTF16Range) {
		targetString.addAttribute(NSForegroundColorAttributeName, value: NSColor.greenColor(), range: NSRange.fromUTF16Range(range))
	}
}

////

let	def	=	MultiblockDefinition(blocks: [
	BlockDefinition(startMark: "/*", endMark: "*/"),
	BlockDefinition(startMark: "//", endMark: "\n"),
	])
let	src	=	String(contentsOfFile: "/Users/Eonil/Workshop/Sandbox3/CodeTextViewController/TesterApp/test-example-5000kb.rs", encoding: NSUTF8StringEncoding, error: nil)!
let	a	=	NSMutableAttributedString(string: src)
let	d	=	CodeData(target: a)
let	s	=	MultiblockDetectionState.None(position: 0)
let	del	=	Processor1(targetString: a)
let	p	=	BlockDetectionProcessor<Processor1>(definition: def, state: s, data: d)

let	de1	=	Unmanaged<Processor1>.passUnretained(del)
while p.available {
	p.stepOpt(de1)
}

println()
println("DONE!")
