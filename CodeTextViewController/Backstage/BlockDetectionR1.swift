////
////  BlockDetectionR1.swift
////  CodeTextViewController
////
////  Created by Hoon H. on 2014/12/29.
////  Copyright (c) 2014 Eonil. All rights reserved.
////
//
//import Foundation
//
//
//
/////
/////	Needs three integers to store state at maximum.
/////
/////
/////
/////	State transitions.
/////
/////	-	None -> Incomplete
/////	-	Incomplete -> Complete
/////	-	Complete -> None
/////
/////	None state can become Incomplete state without cursor advancing.
/////	Incomplete state can become Complete state, but cursor must be advanced.
/////	Complete state can becmoe None state, and cursor must be advanced.
/////
/////
/////
/////	Example states.
/////
/////		0	---		`None`.
/////
/////		1	---		First `None`, second `Incomplete` with zero-length selection.
/////			'/'
/////		2	---		No state. Detector jumps starter mark at once.
/////			'*'
/////		3	---		`Incomplete` with `1..<3` range.
/////			A
/////		4	---		`Incomplete` with `1..<4` range.
/////			'*'
/////		5	---		No state. Detector jumps starter mark at once.
/////			'/'
/////		6	---		First `Complete` with `1..<6` range, second `None`.
/////
/////		7	---		`None` continues.
/////
/////
//struct BlockDetection {
//	class Definition {
//		let	startMark:String
//		let	endMark:String
//		init(startMark:String, endMark:String) {
//			self.startMark	=	startMark
//			self.endMark	=	endMark
//		}
//		
//		var	startMarkUnicodeScalarCount:UDistance {
//			get {
//				return	countElements(startMark.unicodeScalars)
//			}
//		}
//		var	endMarkUnicodeScalarCount:UDistance {
//			get {
//				return	countElements(startMark.unicodeScalars)
//			}
//		}
//	}
//	enum State: Printable {
//		case None(position:UIndex)
//		case Incomplete(selection:URange)
//		case Complete(selection:URange)
//	
//		var selection:URange {
//			get {
//				switch self {
//				case .None(let s):
//					return	s.position..<s.position
//				case .Incomplete(let s):
//					return	s.selection
//				case .Complete(let s):
//					return	s.selection
//				}
//			}
//		}
//		mutating func step(&definition:Definition, data:CodeData) {
//			switch self {
//			case .None(let s):
//				let	p	=	s.position
//				let	s	=	data.unicodeScalars.substringFromIndex(p)
//				if s.hasPrefix(definition.startMark) {
//					let	p1	=	advance(p, definition.startMarkUnicodeScalarCount)
//					self	=	State.Incomplete(selection: URange(start: p, end: p1))
//					
//				} else {
//					let	p1	=	p.successor()
//					self	=	State.None(position: p1)
//				}
//				
//			case .Incomplete(let s):
//				let	p	=	s.selection.endIndex
//				let	x	=	data.unicodeScalars.substringFromIndex(p)
//				if x.hasPrefix(definition.endMark) {
//					let	p2	=	advance(p, countElements(definition.endMark))
//					self	=	State.Complete(selection: URange(start: s.selection.startIndex, end: p2))
//				} else {
//					let	p2	=	p.successor()
//					self	=	State.Incomplete(selection: URange(start: s.selection.startIndex, end: p2))
//				}
//				
//			case .Complete(let s):
//				self	=	State.None(position: s.selection.endIndex)
//			}
//		}
//		var description:String {
//			get {
//				switch self {
//				case .None(let s):
//					return	"None"
//				case .Incomplete(_):
//					return	"Incomplete"
//				case .Complete(_):
//					return	"Complete"
//				}
//			}
//		}
//	}
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
/////	MARK:
/////	MARK:	Unit Test
//
//extension UnitTest {
//	static func testBlockDetection() {
//		test1()
//		test2()
//	}
//	
//	private static func test1() {
//		let	d	=	CodeData(target: NSMutableAttributedString(string: "ABCD"))
//		let	p	=	d.unicodeScalars.startIndex
//		
//		let	def	=	BlockDetection.Definition(startMark: "A", endMark: "C")
//		var	s	=	BlockDetectionState.None(position: d.unicodeScalars.startIndex)
//		
//		s.step(&def, data: d)
//		println(s)
//		println(s.selectionInDataForTest(d))
//		println(s.restInDataForTest(d))
//		assert(s.selectionInDataForTest(d) == "A")
//		assert(s.restInDataForTest(d) == "BCD")
//		assert(s == BlockDetectionState.Incomplete(selection: URange(start: p, end: p.successor())))
//		
//		s.step(&def, data: d)
//		assert(s.selectionInDataForTest(d) == "AB")
//		assert(s.restInDataForTest(d) == "CD")
//		assert(s == BlockDetectionState.Incomplete(selection: URange(start: p, end: p.successor().successor())))
//		
//		s.step(&def, data: d)
//		println(s)
//		println(s.selectionInDataForTest(d))
//		println(s.restInDataForTest(d))
//		assert(s.selectionInDataForTest(d) == "ABC")
//		assert(s.restInDataForTest(d) == "D")
//		assert(s == BlockDetectionState.Complete(selection: URange(start: p, end: p.successor().successor().successor())))
//		
//		s.step(&def, data: d)
//		println(s)
//		println(s.selectionInDataForTest(d))
//		println(s.restInDataForTest(d))
//		assert(s.selectionInDataForTest(d) == "")
//		assert(s.restInDataForTest(d) == "D")
//		assert(s == BlockDetectionState.None(position: p.successor().successor().successor()))
//		
//		s.step(&def, data: d)
//		println(s)
//		println(s.selectionInDataForTest(d))
//		println(s.restInDataForTest(d))
//		assert(s.selectionInDataForTest(d) == "")
//		assert(s.restInDataForTest(d) == "")
//		assert(s == BlockDetectionState.None(position: p.successor().successor().successor().successor()))
//	}
//	private static func test2() {
//		let	d	=	CodeData(target: NSMutableAttributedString(string: "abc/*def*/ghi"))
//		let	p	=	d.unicodeScalars.startIndex
//		
//		let	def	=	BlockDetection.Definition(startMark: "/*", endMark: "*/")
//		var	s	=	BlockDetectionState.None(position: d.unicodeScalars.startIndex)
//		
//		s.step(&def, data: d)
//		assert(s.isNone())
//		
//		s.step(&def, data: d)
//		assert(s.isNone())
//		
//		s.step(&def, data: d)
//		assert(s.isNone())
//		assert(s.restInDataForTest(d) == "/*def*/ghi")
//		
//		s.step(&def, data: d)
//		assert(s.isIncomplete())
//		assert(s.selectionInDataForTest(d) == "/*")
//		
//		s.step(&def, data: d)
//		assert(s.isIncomplete())
//		assert(s.selectionInDataForTest(d) == "/*d")
//		
//		s.step(&def, data: d)
//		assert(s.isIncomplete())
//		assert(s.selectionInDataForTest(d) == "/*de")
//		
//		s.step(&def, data: d)
//		assert(s.isIncomplete())
//		assert(s.selectionInDataForTest(d) == "/*def")
//		
//		s.step(&def, data: d)
//		assert(s.isComplete())
//		assert(s.selectionInDataForTest(d) == "/*def*/")
//		
//		s.step(&def, data: d)
//		assert(s.isNone())
//		assert(s.selectionInDataForTest(d) == "")
//		assert(s.restInDataForTest(d) == "ghi")
//		
//		s.step(&def, data: d)
//		assert(s.isNone())
//		assert(s.selectionInDataForTest(d) == "")
//		assert(s.restInDataForTest(d) == "hi")
//		
//		s.step(&def, data: d)
//		assert(s.isNone())
//		assert(s.selectionInDataForTest(d) == "")
//		assert(s.restInDataForTest(d) == "i")
//		
//		s.step(&def, data: d)
//		assert(s.isNone())
//		assert(s.selectionInDataForTest(d) == "")
//		assert(s.restInDataForTest(d) == "")
//	}
//}
//
//extension BlockDetectionState {
//	func isNone() -> Bool {
//		switch self {
//		case .None(let s):			return	true
//		default:					return	false
//		}
//	}
//	func isIncomplete() -> Bool {
//		switch self {
//		case .Incomplete(let s):	return	true
//		default:					return	false
//		}
//	}
//	func isComplete() -> Bool {
//		switch self {
//		case .Complete(let s):		return	true
//		default:					return	false
//		}
//	}
//	func selectionInDataForTest(data:CodeData) -> String {
//		switch self {
//		case .None(let s):
//			return	""
//		case .Incomplete(let s):
//			return	String(data.unicodeScalars[s.selection])
//		case .Complete(let s):
//			return	String(data.unicodeScalars[s.selection])
//		}
//	}
//	func restInDataForTest(data:CodeData) -> String {
//		switch self {
//		case .None(let s):
//			return	String(data.unicodeScalars[s.position..<data.unicodeScalars.endIndex])
//		case .Incomplete(let s):
//			return	String(data.unicodeScalars[s.selection.endIndex..<data.unicodeScalars.endIndex])
//		case .Complete(let s):
//			return	String(data.unicodeScalars[s.selection.endIndex..<data.unicodeScalars.endIndex])
//		}
//	}
//}
//
//
//
//
//
//
//
