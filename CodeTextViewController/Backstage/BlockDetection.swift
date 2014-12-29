//
//  BlockDetection.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2014/12/29.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation










///
///	Needs three integers to store state at maximum.
///
///
///
///	State transitions.
///
///	-	None -> Incomplete
///	-	Incomplete -> Complete
///	-	Complete -> None
///
///	None state can become Incomplete state without cursor advancing.
///	Incomplete state can become Complete state, but cursor must be advanced.
///	Complete state can becmoe None state, and cursor must be advanced.
///
///
///
///	Example states.
///
///		0	---		`None`.
///
///		1	---		First `None`, second `Incomplete` with zero-length selection.
///			'/'
///		2	---		No state. Detector jumps starter mark at once.
///			'*'
///		3	---		`Incomplete` with `1..<3` range.
///			A
///		4	---		`Incomplete` with `1..<4` range.
///			'*'
///		5	---		No state. Detector jumps starter mark at once.
///			'/'
///		6	---		First `Complete` with `1..<6` range, second `None`. Second phase will not happend at the end of data.
///
///		7	---		`None` continues.
///
///
struct BlockDetection {
	class Definition {
		let	startMark:String
		let	endMark:String
		init(startMark:String, endMark:String) {
			self.startMark	=	startMark
			self.endMark	=	endMark
		}
		
		var	startMarkUnicodeScalarCount:UDistance {
			get {
				return	countElements(startMark.unicodeScalars)
			}
		}
		var	endMarkUnicodeScalarCount:UDistance {
			get {
				return	countElements(startMark.unicodeScalars)
			}
		}
	}
	struct State {
		var	mode:Mode
		var	selection:URange
		
		enum Mode {
			case None
			case Incomplete
			case Complete
		}
		mutating func step(definition:Definition, data:CodeData) {
			assert(selection.endIndex < data.unicodeScalars.endIndex)
			
			switch mode {
			case .None:
				assert(selection.startIndex == selection.endIndex)
				let	p	=	selection.startIndex
				let	s	=	data.unicodeScalars.substringFromIndex(p)
				if s.hasPrefix(definition.startMark) {
					let	p1		=	advance(p, definition.startMarkUnicodeScalarCount)
					mode		=	Mode.Incomplete
					selection	=	URange(start: p, end: p1)
					
				} else {
					let	p1	=	p.successor()
					mode		=	Mode.None
					selection	=	p1..<p1
				}
				
			case .Incomplete:
				let	p	=	selection.endIndex
				let	x	=	data.unicodeScalars.substringFromIndex(p)
				if x.hasPrefix(definition.endMark) {
					let	p2		=	advance(p, countElements(definition.endMark))
					mode		=	Mode.Complete
					selection	=	URange(start: selection.startIndex, end: p2)
				} else {
					let	p2	=	p.successor()
					mode		=	Mode.Incomplete
					selection	=	URange(start: selection.startIndex, end: p2)
				}
				
			case .Complete:
				mode		=	Mode.None
				selection	=	selection.endIndex..<selection.endIndex
			}
		}
	}
}

















































///	MARK:
///	MARK:	Unit Test

extension UnitTest {
	static func testBlockDetection() {
		test1()
		test2()
		test3IncompleteFragment()
	}
	
	private static func test1() {
		let	d	=	CodeData(target: NSMutableAttributedString(string: "ABCD"))
		let	p	=	d.unicodeScalars.startIndex
		
		let	def	=	BlockDetection.Definition(startMark: "A", endMark: "C")
		var	s	=	BlockDetection.State(mode: BlockDetection.State.Mode.None, selection: d.unicodeScalars.startIndex..<d.unicodeScalars.startIndex)
		
		s.step(def, data: d)
		println(s)
		println(s.selectionInDataForTest(d))
		println(s.restInDataForTest(d))
		assert(s.selectionInDataForTest(d) == "A")
		assert(s.restInDataForTest(d) == "BCD")
		assert(s.mode == .Incomplete)
		assert(s.selection == p..<p.successor())
		
		s.step(def, data: d)
		assert(s.selectionInDataForTest(d) == "AB")
		assert(s.restInDataForTest(d) == "CD")
		assert(s.mode == .Incomplete)
		assert(s.selection == p..<p.successor().successor())
		
		s.step(def, data: d)
		println(s)
		println(s.selectionInDataForTest(d))
		println(s.restInDataForTest(d))
		assert(s.selectionInDataForTest(d) == "ABC")
		assert(s.restInDataForTest(d) == "D")
		assert(s.mode == .Complete)
		assert(s.selection == p..<p.successor().successor().successor())
		
		s.step(def, data: d)
		println(s)
		println(s.selectionInDataForTest(d))
		println(s.restInDataForTest(d))
		assert(s.selectionInDataForTest(d) == "")
		assert(s.restInDataForTest(d) == "D")
		assert(s.mode == .None)
		assert(s.selection == p.successor().successor().successor()..<p.successor().successor().successor())
		
		s.step(def, data: d)
		println(s)
		println(s.selectionInDataForTest(d))
		println(s.restInDataForTest(d))
		assert(s.selectionInDataForTest(d) == "")
		assert(s.restInDataForTest(d) == "")
		assert(s.mode == .None)
		assert(s.selection == p.successor().successor().successor().successor()..<p.successor().successor().successor().successor())
	}
	private static func test2() {
		let	d	=	CodeData(target: NSMutableAttributedString(string: "abc/*def*/ghi"))
		let	p	=	d.unicodeScalars.startIndex
		
		let	def	=	BlockDetection.Definition(startMark: "/*", endMark: "*/")
		var	s	=	BlockDetection.State(mode: BlockDetection.State.Mode.None, selection: d.unicodeScalars.startIndex..<d.unicodeScalars.startIndex)
		
		s.step(def, data: d)
		assert(s.isNone())
		
		s.step(def, data: d)
		assert(s.isNone())
		
		s.step(def, data: d)
		assert(s.isNone())
		assert(s.restInDataForTest(d) == "/*def*/ghi")
		
		s.step(def, data: d)
		assert(s.isIncomplete())
		assert(s.selectionInDataForTest(d) == "/*")
		
		s.step(def, data: d)
		assert(s.isIncomplete())
		assert(s.selectionInDataForTest(d) == "/*d")
		
		s.step(def, data: d)
		assert(s.isIncomplete())
		assert(s.selectionInDataForTest(d) == "/*de")
		
		s.step(def, data: d)
		assert(s.isIncomplete())
		assert(s.selectionInDataForTest(d) == "/*def")
		
		s.step(def, data: d)
		assert(s.isComplete())
		assert(s.selectionInDataForTest(d) == "/*def*/")
		
		s.step(def, data: d)
		assert(s.isNone())
		assert(s.selectionInDataForTest(d) == "")
		assert(s.restInDataForTest(d) == "ghi")
		
		s.step(def, data: d)
		assert(s.isNone())
		assert(s.selectionInDataForTest(d) == "")
		assert(s.restInDataForTest(d) == "hi")
		
		s.step(def, data: d)
		assert(s.isNone())
		assert(s.selectionInDataForTest(d) == "")
		assert(s.restInDataForTest(d) == "i")
		
		s.step(def, data: d)
		assert(s.isNone())
		assert(s.selectionInDataForTest(d) == "")
		assert(s.restInDataForTest(d) == "")
	}
	private static func test3IncompleteFragment() {
		let	d	=	CodeData(target: NSMutableAttributedString(string: "abc/*def"))
		let	p	=	d.unicodeScalars.startIndex
		
		let	def	=	BlockDetection.Definition(startMark: "/*", endMark: "*/")
		var	s	=	BlockDetection.State(mode: BlockDetection.State.Mode.None, selection: d.unicodeScalars.startIndex..<d.unicodeScalars.startIndex)
		
		s.step(def, data: d)
		assert(s.isNone())
		
		s.step(def, data: d)
		assert(s.isNone())
		
		s.step(def, data: d)
		assert(s.isNone())
		assert(s.restInDataForTest(d) == "/*def")
		
		s.step(def, data: d)
		assert(s.isIncomplete())
		assert(s.selectionInDataForTest(d) == "/*")
		
		s.step(def, data: d)
		assert(s.isIncomplete())
		assert(s.selectionInDataForTest(d) == "/*d")
		
		s.step(def, data: d)
		assert(s.isIncomplete())
		assert(s.selectionInDataForTest(d) == "/*de")
		assert(s.selection.endIndex < d.unicodeScalars.endIndex)
		
		s.step(def, data: d)
		assert(s.isIncomplete())
		assert(s.selectionInDataForTest(d) == "/*def")
		
		//	Further stepping undefined.
		//	User must stop stepping by investigating selection.
		//	Stepping at last is not allowed, but if the state is `Complete` 
		//	it will be changed into `None` once.
		assert(s.selection.endIndex == d.unicodeScalars.endIndex)
	}
}

extension BlockDetection.State {
	func isNone() -> Bool {
		return	mode == .None
	}
	func isIncomplete() -> Bool {
		return	mode == .Incomplete
	}
	func isComplete() -> Bool {
		return	mode == .Complete
	}
	func selectionInDataForTest(data:CodeData) -> String {
		return	String(data.unicodeScalars[selection])
	}
	func restInDataForTest(data:CodeData) -> String {
		return	String(data.unicodeScalars[selection.endIndex..<data.unicodeScalars.endIndex])
	}
}

















































