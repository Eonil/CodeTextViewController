//
//  main.swift
//  PerfTest
//
//  Created by Hoon H. on 2014/12/30.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation


//final class Processor1: BlockDetectionProcessorDelegate {
//	func onBlockNone(range:UTF16Range) {
//		
//	}
//	func onBlockIncomplete(range:UTF16Range) {
//		
//	}
//	func onBlockComplete(range:UTF16Range) {
//		println(range)
//	}
//}
//let	p1	=	Processor1()

////

let	def	=	MultiblockDefinition(blocks: [
	BlockDefinition(startMark: "/*", endMark: "*/"),
	BlockDefinition(startMark: "//", endMark: "\n"),
	])
let	src	=	String(contentsOfFile: "/Users/Eonil/Workshop/Sandbox3/CodeTextViewController/TesterApp/test-example-5000kb.rs", encoding: NSUTF8StringEncoding, error: nil)!
let	d	=	CodeData(target: NSMutableAttributedString(string: src))
let	s	=	MultiblockDetectionState.None(position: 0)
let	p	=	BlockDetectionProcessor(definition: def, state: s, data: d)


//p.delegate	=	p1
while p.available {
	p.step()
}

println("DONE!")
