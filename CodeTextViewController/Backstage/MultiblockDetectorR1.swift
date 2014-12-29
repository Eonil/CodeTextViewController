////
////  MultiblockDetection.swift
////  CodeTextViewController
////
////  Created by Hoon H. on 2014/12/29.
////  Copyright (c) 2014 Eonil. All rights reserved.
////
//
//import Foundation
//
/////
/////	Detects blocks for multiple definitions.
/////	Blocks cannot be nested.
/////	Mainly designed to provide incremental tokeniser.
/////
/////
//struct MultiblockDetection {
//	class Definition {
//		let	blocks:[BlockDetection.Definition]
//		init(blocks:[BlockDetection.Definition]) {
//			self.blocks	=	blocks
//		}
//	}
//	
//	enum State {
//		case None(position:UIndex)
//		case Incomplete(subdefintion:BlockDetection.Definition, substate:BlockDetection.State)
//		case Complete(subdefintion:BlockDetection.Definition, substate:BlockDetection.State)
//		
//		var selection:URange {
//			get {
//				switch self {
//				case .None(let s):
//					return	s.position..<s.position
//				case .Incomplete(let s):
//					return	s.substate.selection
//				case .Complete(let s):
//					return	s.substate.selection
//				}
//			}
//		}
//		mutating func step(definition:Definition, data:CodeData) {
//			switch self {
//			case .None(let s):
//				BLOCK_LOOP:
//				for b in definition.blocks {
//					var	s1	=	BlockDetection.State.None(position: s.position)
//					s1.step(b, data: data)
//					switch s1 {
//					case .None(let s2):
//						self	=	State.None(position: s2.position)
//						continue BLOCK_LOOP
//						
//					case .Incomplete(_):
//						self	=	State.Incomplete(subdefintion: b, substate: s1)
//						break BLOCK_LOOP
//						
//					case .Complete(let s2):
//						self	=	State.Complete(subdefintion: b, substate: s1)
//						break BLOCK_LOOP
//					}
//				}
//				
//			case .Incomplete(let s):
//				someStep(s.subdefintion, substate: s.substate, data: data)
//				
//			case .Complete(let s):
//				someStep(s.subdefintion, substate: s.substate, data: data)
//			}
//		}
//		
//		private mutating func someStep(subdefinition:BlockDetection.Definition, substate:BlockDetection.State, data:CodeData) {
//			var	s1	=	substate
//			s1.step(subdefinition, data: data)
//			
//			switch s1 {
//			case .None(let s2):
//				self	=	State.None(position: s2.position)
//				
//			case .Incomplete(_):
//				self	=	State.Incomplete(subdefintion: subdefinition, substate: s1)
//				
//			case .Complete(_):
//				self	=	State.Complete(subdefintion: subdefinition, substate: s1)
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
/////	MARK:
/////	MARK:	Unit Test
//
//extension UnitTest {
//	static func testMultiblockDetection() {
//		test1()
//		test2()
//	}
//	private static func test1() {
//		let	d	=	CodeData(target: NSMutableAttributedString(string: "<a>[b](c)"))
//		let	def	=	MultiblockDetection.Definition(blocks: [
//			BlockDetection.Definition(startMark: "<", endMark: ">"),
//			BlockDetection.Definition(startMark: "(", endMark: ")"),
//			BlockDetection.Definition(startMark: "[", endMark: "]"),
//			])
//		
//		var	s	=	MultiblockDetection.State.None(position: d.unicodeScalars.startIndex)
//		assert(s.selectionInDataForTest(d) == "")
//		assert(s.isNone())
//		
//		s.step(def, data: d)
//		println(s)
//		println(s.selectionInDataForTest(d))
//		assert(s.isIncomplete())
//		assert(s.selectionInDataForTest(d) == "<")
//		
//		s.step(def, data: d)
//		println(s)
//		println(s.selectionInDataForTest(d))
//		assert(s.isIncomplete())
//		assert(s.selectionInDataForTest(d) == "<a")
//		
//		s.step(def, data: d)
//		println(s)
//		println(s.selectionInDataForTest(d))
//		assert(s.isComplete())
//		assert(s.selectionInDataForTest(d) == "<a>")
//		
//		s.step(def, data: d)
//		println(s)
//		println(s.selectionInDataForTest(d))
//		println(s.restInDataForTest(d))
//		assert(s.isNone())
//		assert(s.selectionInDataForTest(d) == "")
//		
//		s.step(def, data: d)
//		println(s)
//		println(s.selectionInDataForTest(d))
//		println(s.restInDataForTest(d))
//		assert(s.isIncomplete())
//		assert(s.selectionInDataForTest(d) == "[")
//		assert(s.restInDataForTest(d) == "b](c)")
//		
//		s.step(def, data: d)
//		println(s)
//		println(s.selectionInDataForTest(d))
//		println(s.restInDataForTest(d))
//		assert(s.isIncomplete())
//		assert(s.selectionInDataForTest(d) == "[b")
//		assert(s.restInDataForTest(d) == "](c)")
//		
//		s.step(def, data: d)
//		println(s)
//		println(s.selectionInDataForTest(d))
//		println(s.restInDataForTest(d))
//		assert(s.isComplete())
//		assert(s.selectionInDataForTest(d) == "[b]")
//		assert(s.restInDataForTest(d) == "(c)")
//		
//		s.step(def, data: d)
//		println(s)
//		println(s.selectionInDataForTest(d))
//		println(s.restInDataForTest(d))
//		assert(s.isNone())
//		assert(s.selectionInDataForTest(d) == "")
//		assert(s.restInDataForTest(d) == "(c)")
//		
//		s.step(def, data: d)
//		println(s.selectionInDataForTest(d))
//		println(s.restInDataForTest(d))
//		assert(s.isIncomplete())
//		assert(s.selection.endIndex.successor().successor() == d.unicodeScalars.endIndex)
//		assert(s.selectionInDataForTest(d) == "(")
//		assert(s.restInDataForTest(d) == "c)")
//		
//		s.step(def, data: d)
//		assert(s.isIncomplete())
//		assert(s.selection.endIndex.successor() == d.unicodeScalars.endIndex)
//		assert(s.selectionInDataForTest(d) == "(c")
//		assert(s.restInDataForTest(d) == ")")
//		
//		s.step(def, data: d)
//		assert(s.isComplete())
//		assert(s.selection.endIndex == d.unicodeScalars.endIndex)
//		assert(s.selectionInDataForTest(d) == "(c)")
//		assert(s.restInDataForTest(d) == "")
//		
//		s.step(def, data: d)
//		assert(s.isNone())
//		assert(s.selection.endIndex == d.unicodeScalars.endIndex)
//		assert(s.selectionInDataForTest(d) == "")
//		assert(s.restInDataForTest(d) == "")
//	}
//	private static func test2() {
//		let	d	=	CodeData(target: NSMutableAttributedString(string: "abc/*def*/ghi"))
//		let	def	=	MultiblockDetection.Definition(blocks: [
//			BlockDetection.Definition(startMark: "/*", endMark: "*/"),
//			])
//		
//		var	s	=	MultiblockDetection.State.None(position: d.unicodeScalars.startIndex)
//		
//		s.step(def, data: d)
//		assert(s.isNone())
//		
//		s.step(def, data: d)
//		assert(s.isNone())
//		
//		s.step(def, data: d)
//		assert(s.isNone())
//		
//		s.step(def, data: d)
//		assert(s.isIncomplete())
//		assert(s.selectionInDataForTest(d) == "/*")
//		
//		s.step(def, data: d)
//		assert(s.isIncomplete())
//		
//		s.step(def, data: d)
//		assert(s.isIncomplete())
//		
//		s.step(def, data: d)
//		assert(s.isIncomplete())
//		
//		s.step(def, data: d)
//		assert(s.isComplete())
//		assert(s.selectionInDataForTest(d) == "/*def*/")
//	}
//}
//
//
//
//
//extension MultiblockDetection.State: Printable {
//	var description:String {
//		get {
//			switch self {
//			case .None(let s):
//				return	"None"
//			case .Incomplete(let s):
//				return	"Incomplete"
//			case .Complete(let s):
//				return	"Complete"
//			}
//		}
//	}
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
//			return	s.substate.selectionInDataForTest(data)
//		case .Complete(let s):
//			return	s.substate.selectionInDataForTest(data)
//		}
//	}
//	func restInDataForTest(data:CodeData) -> String {
//		switch self {
//		case .None(let s):
//			return	String(data.unicodeScalars[s.position..<data.unicodeScalars.endIndex])
//		case .Incomplete(let s):
//			return	s.substate.restInDataForTest(data)
//		case .Complete(let s):
//			return	s.substate.restInDataForTest(data)
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
