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
	init(storage:CodeTextStorage) {
		self.storage	=	storage
	}
	var storage:CodeTextStorage
	func onBlockNone(range: UTF16Range) {
		if noneRangeUnion == nil {
			noneRangeUnion	=	range
		} else {
			noneRangeUnion!.endIndex	=	range.endIndex
		}
	}
	func onBlockIncomplete(range: UTF16Range) {
		if let r = noneRangeUnion {
			storage.text.removeAttribute(NSForegroundColorAttributeName, range: NSRange.fromUTF16Range(range))
			noneRangeUnion	=	nil
		}
		
		////
		
		let	distFromStart	=	range.endIndex - 0
		switch distFromStart {
		case 0, 1, 2, 4, 8:
			storage.text.addAttribute(NSForegroundColorAttributeName, value: NSColor.greenColor(), range: NSRange.fromUTF16Range(range))
			debugLog("incompletion coloring update")
			break
			
		default:
			break
		}
	}
	func onBlockComplete(range: UTF16Range) {
		storage.text.addAttribute(NSForegroundColorAttributeName, value: NSColor.greenColor(), range: NSRange.fromUTF16Range(range))
	}
	private var	noneRangeUnion	:	UTF16Range?
}

////

let	def	=	MultiblockDefinition(blocks: [
	BlockDefinition(startMark: "/*", endMark: "*/"),
	BlockDefinition(startMark: "//", endMark: "\n"),
	])
let	src	=	String(contentsOfFile: "/Users/Eonil/Workshop/Sandbox3/CodeTextViewController/TesterApp/text-example2-500kb.rs", encoding: NSUTF8StringEncoding, error: nil)!
let	a	=	CodeTextStorage()
a.text.replaceCharactersInRange(NSRange(location: 0, length: 0), withString: src)
let	d	=	CodeData(target: a.text)
let	s	=	MultiblockDetectionState.none(selection: 0..<0)
let	del	=	Processor1(storage: a)
let	p	=	BlockDetectionProcessor<Processor1>(definition: def, state: s, data: d)

let	de1	=	Unmanaged<Processor1>.passUnretained(del)

println("start processing")
while p.available {
	p.stepOpt(de1)
}
println("end processing")

println()
println("DONE!")
