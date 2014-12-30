//
//  MultiblockDetectionState.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2014/12/29.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation

///
///	Detects blocks for multiple definitions.
///	Blocks cannot be nested.
///	Mainly designed to provide incremental tokeniser.
///
///
enum MultiblockDetectionState {
	case None(position:UTF16Index)
	case Incomplete(subdefintion:BlockDefinition, substate:BlockDetectionState)
	case Complete(subdefintion:BlockDefinition, substate:BlockDetectionState)
	
	var deinition:BlockDefinition? {
		get {
			switch self {
			case .None(let s):
				return	nil
			case .Incomplete(let s):
				return	s.subdefintion
			case .Complete(let s):
				return	s.subdefintion
			}
		}
	}
	var selection:UTF16Range {
		get {
			switch self {
			case .None(let s):
				return	s.position..<s.position
			case .Incomplete(let s):
				return	s.substate.selection
			case .Complete(let s):
				return	s.substate.selection
			}
		}
	}
	mutating func step(definition:MultiblockDefinition, data:CodeData) {
		assert(selection.endIndex < data.utf16.endIndex)
		
		switch self {
		case .None(let s):
			for b in definition.blocks {
				var	s1	=	BlockDetectionState(mode: BlockDetectionState.Mode.None, selection: s.position..<s.position)
				s1.step(b, data: data)
				switch s1.mode {
				case .None:
					assert(s1.selection.startIndex == s1.selection.endIndex)
					//	No change on position and retry with another detector.
					
				case .Incomplete:
					self	=	MultiblockDetectionState.Incomplete(subdefintion: b, substate: s1)
					return	//	Exit early.
					
				case .Complete:
					self	=	MultiblockDetectionState.Complete(subdefintion: b, substate: s1)
					return	//	Exit early.
				}
			}
			self	=	MultiblockDetectionState.None(position: s.position.successor())	//	Advance position if nothing has been detected.
			
		case .Incomplete(let s):
			someStep(s.subdefintion, substate: s.substate, data: data)
			
		case .Complete(let s):
			someStep(s.subdefintion, substate: s.substate, data: data)
		}
	}
	
	private mutating func someStep(subdefinition:BlockDefinition, substate:BlockDetectionState, data:CodeData) {
		var	s1	=	substate
		s1.step(subdefinition, data: data)
		
		switch s1.mode {
		case .None:
			assert(s1.selection.startIndex == s1.selection.endIndex)
			self	=	MultiblockDetectionState.None(position: s1.selection.startIndex)
			
		case .Incomplete:
			self	=	MultiblockDetectionState.Incomplete(subdefintion: subdefinition, substate: s1)
			
		case .Complete:
			self	=	MultiblockDetectionState.Complete(subdefintion: subdefinition, substate: s1)
		}
	}
}




































///	MARK:
///	MARK:	Unit Test

extension UnitTest {
	static func testMultiblockDetection() {
		test1()
		test2()
		test3CornerCase1()
	}
	private static func test1() {
		let	d	=	CodeData(target: NSMutableAttributedString(string: "<a>[b](c)"))
		let	def	=	MultiblockDefinition(blocks: [
			BlockDefinition(startMark: "<", endMark: ">"),
			BlockDefinition(startMark: "(", endMark: ")"),
			BlockDefinition(startMark: "[", endMark: "]"),
			])
		
		var	s	=	MultiblockDetectionState.None(position: d.utf16.startIndex)
		assert(s.selectionInDataForTest(d) == "")
		assert(s.isNone())
		
		s.step(def, data: d)
		println(s)
		println(s.selectionInDataForTest(d))
		assert(s.isIncomplete())
		assert(s.selectionInDataForTest(d) == "<")
		
		s.step(def, data: d)
		println(s)
		println(s.selectionInDataForTest(d))
		assert(s.isIncomplete())
		assert(s.selectionInDataForTest(d) == "<a")
		
		s.step(def, data: d)
		println(s)
		println(s.selectionInDataForTest(d))
		assert(s.isComplete())
		assert(s.selectionInDataForTest(d) == "<a>")
		
		s.step(def, data: d)
		println(s)
		println(s.selectionInDataForTest(d))
		println(s.restInDataForTest(d))
		assert(s.isNone())
		assert(s.selectionInDataForTest(d) == "")
		
		s.step(def, data: d)
		println(s)
		println(s.selectionInDataForTest(d))
		println(s.restInDataForTest(d))
		assert(s.isIncomplete())
		assert(s.selectionInDataForTest(d) == "[")
		assert(s.restInDataForTest(d) == "b](c)")
		
		s.step(def, data: d)
		println(s)
		println(s.selectionInDataForTest(d))
		println(s.restInDataForTest(d))
		assert(s.isIncomplete())
		assert(s.selectionInDataForTest(d) == "[b")
		assert(s.restInDataForTest(d) == "](c)")
		
		s.step(def, data: d)
		println(s)
		println(s.selectionInDataForTest(d))
		println(s.restInDataForTest(d))
		assert(s.isComplete())
		assert(s.selectionInDataForTest(d) == "[b]")
		assert(s.restInDataForTest(d) == "(c)")
		
		s.step(def, data: d)
		println(s)
		println(s.selectionInDataForTest(d))
		println(s.restInDataForTest(d))
		assert(s.isNone())
		assert(s.selectionInDataForTest(d) == "")
		assert(s.restInDataForTest(d) == "(c)")
		
		s.step(def, data: d)
		println(s.selectionInDataForTest(d))
		println(s.restInDataForTest(d))
		assert(s.isIncomplete())
		assert(s.selection.endIndex.successor().successor() == d.utf16.endIndex)
		assert(s.selectionInDataForTest(d) == "(")
		assert(s.restInDataForTest(d) == "c)")
		
		s.step(def, data: d)
		assert(s.isIncomplete())
		assert(s.selection.endIndex.successor() == d.utf16.endIndex)
		assert(s.selectionInDataForTest(d) == "(c")
		assert(s.restInDataForTest(d) == ")")
		
		s.step(def, data: d)
		assert(s.isComplete())
		assert(s.selection.endIndex == d.utf16.endIndex)
		assert(s.selectionInDataForTest(d) == "(c)")
		assert(s.restInDataForTest(d) == "")
		
		//	Cannot advance anymore.
	}
	private static func test2() {
		let	d	=	CodeData(target: NSMutableAttributedString(string: "abc/*def*/ghi"))
		let	def	=	MultiblockDefinition(blocks: [
			BlockDefinition(startMark: "/*", endMark: "*/"),
			])
		
		var	s	=	MultiblockDetectionState.None(position: d.utf16.startIndex)
		
		s.step(def, data: d)
		assert(s.isNone())
		
		s.step(def, data: d)
		assert(s.isNone())
		
		s.step(def, data: d)
		assert(s.isNone())
		
		s.step(def, data: d)
		assert(s.isIncomplete())
		assert(s.selectionInDataForTest(d) == "/*")
		
		s.step(def, data: d)
		assert(s.isIncomplete())
		
		s.step(def, data: d)
		assert(s.isIncomplete())
		
		s.step(def, data: d)
		assert(s.isIncomplete())
		
		s.step(def, data: d)
		assert(s.isComplete())
		assert(s.selectionInDataForTest(d) == "/*def*/")
	}
	private static func test3CornerCase1() {
		let	d	=	CodeData(target: NSMutableAttributedString(string: "//\n//\n;"))
		let	def	=	MultiblockDefinition(blocks: [
			BlockDefinition(startMark: "//", endMark: "\n"),
			])
		
		var	s	=	MultiblockDetectionState.None(position: d.utf16.startIndex)
		
		s.step(def, data: d)
		assert(s.isIncomplete())
		assert(s.selectionInDataForTest(d) == "//")
		
		s.step(def, data: d)
		assert(s.isComplete())
		assert(s.selectionInDataForTest(d) == "//\n")
		
		s.step(def, data: d)
		assert(s.isNone())
		
		s.step(def, data: d)
		assert(s.isIncomplete())
		assert(s.selectionInDataForTest(d) == "//")
		
		s.step(def, data: d)
		assert(s.isComplete())
		assert(s.selectionInDataForTest(d) == "//\n")
		assert(s.restInDataForTest(d) == ";")
		
		s.step(def, data: d)
		assert(s.isNone())	//	Becomes `None` at same position.
		
		s.step(def, data: d)
		assert(s.isNone())
		assert(s.selection.endIndex == d.utf16.endIndex)
	}
}




extension MultiblockDetectionState: Printable {
	var description:String {
		get {
			switch self {
			case .None(let s):
				return	"None"
			case .Incomplete(let s):
				return	"Incomplete"
			case .Complete(let s):
				return	"Complete"
			}
		}
	}
	func isNone() -> Bool {
		switch self {
		case .None(let s):			return	true
		default:					return	false
		}
	}
	func isIncomplete() -> Bool {
		switch self {
		case .Incomplete(let s):	return	true
		default:					return	false
		}
	}
	func isComplete() -> Bool {
		switch self {
		case .Complete(let s):		return	true
		default:					return	false
		}
	}
	func selectionInDataForTest(data:CodeData) -> String {
		switch self {
		case .None(let s):
			return	""
		case .Incomplete(let s):
			return	s.substate.selectionInDataForTest(data)
		case .Complete(let s):
			return	s.substate.selectionInDataForTest(data)
		}
	}
	func restInDataForTest(data:CodeData) -> String {
		switch self {
		case .None(let s):
			return	String(data.substringWithUTF16Range(s.position..<data.utf16.endIndex))
		case .Incomplete(let s):
			return	s.substate.restInDataForTest(data)
		case .Complete(let s):
			return	s.substate.restInDataForTest(data)
		}
	}
}















