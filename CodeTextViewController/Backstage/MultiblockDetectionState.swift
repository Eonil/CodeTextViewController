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
struct MultiblockDetectionState {
	var	substate:BlockDetectionState
	var	subdefinition:BlockDefinition?
	
	var mode:BlockDetectionState.Mode {
		get {
			return	substate.mode
		}
	}
	var selection:UTF16Range {
		get {
			return	substate.selection
		}
	}
	mutating func step(definition:MultiblockDefinition, data:CodeData) {
		assert(selection.endIndex < data.utf16.endIndex)
		
		switch mode {
		case .None:
			for b in definition.blocks {
				var	s1	=	substate
				s1.step(b, data: data)
				switch s1.mode {
				case .None:
					break
					//	No change on position and retry with another detector.
					
				case .Incomplete:	fallthrough
				case .Complete:		fallthrough
				default:
					substate	=	s1
					subdefinition	=	b
					return	//	Exit early.
				}
			}
			
			//	Advance position if nothing has been detected.
			substate.selection.startIndex	=	substate.selection.endIndex
			substate.selection.endIndex		=	substate.selection.startIndex.successor()
			
		case .Incomplete:	fallthrough
		case .Complete:		fallthrough
		default:
			substate.step(subdefinition!, data: data)
		}
	}
}
extension MultiblockDetectionState {
	static func none(#selection:UTF16Range) -> MultiblockDetectionState {
		let	ss	=	BlockDetectionState(mode: BlockDetectionState.Mode.None, selection: selection)
		return	MultiblockDetectionState(substate: ss, subdefinition: nil)
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
		
		var	s	=	MultiblockDetectionState.none(selection: d.utf16.startIndex..<d.utf16.startIndex)
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
		
		var	s	=	MultiblockDetectionState.none(selection: d.utf16.startIndex..<d.utf16.startIndex)
		
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
		
		var	s	=	MultiblockDetectionState.none(selection: d.utf16.startIndex..<d.utf16.startIndex)
		
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
			switch substate.mode {
			case .None:
				return	"None"
			case .Incomplete:
				return	"Incomplete"
			case .Complete:
				return	"Complete"
			}
		}
	}
	func isNone() -> Bool {
		return	substate.mode	==	.None
	}
	func isIncomplete() -> Bool {
		return	substate.mode	==	.Incomplete
	}
	func isComplete() -> Bool {
		return	substate.mode	==	.Complete
	}
	func selectionInDataForTest(data:CodeData) -> String {
		return	substate.selectionInDataForTest(data)
	}
	func restInDataForTest(data:CodeData) -> String {
		return	substate.restInDataForTest(data)
	}
}















