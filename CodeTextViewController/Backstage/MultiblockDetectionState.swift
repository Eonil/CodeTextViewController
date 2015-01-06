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
	struct Subdata {
		let	definition:BlockDefinition
		let	state:BlockDetectionState
	}
	
	case None(position:UTF16Range)
	case Incomplete(subdata:Subdata)
	case Complete(subdata:Subdata)
	
	var deinition:BlockDefinition? {
		get {
			switch self {
			case .None(let s):
				return	nil
			case .Incomplete(let s):
				return	s.subdata.definition
			case .Complete(let s):
				return	s.subdata.definition
			}
		}
	}
	var selection:UTF16Range {
		get {
			switch self {
			case .None(let s):
				return	s.position
			case .Incomplete(let s):
				return	s.subdata.state.selection
			case .Complete(let s):
				return	s.subdata.state.selection
			}
		}
	}
	mutating func step(definition:MultiblockDefinition, data:CodeData) {
		assert(selection.endIndex < data.utf16.endIndex)
		
		switch self {
		case .None(let s):
			for b in definition.blocks {
				var	s1	=	BlockDetectionState(mode: BlockDetectionState.Mode.None, selection: s.position)
				s1.step(b, data: data)
				switch s1.mode {
				case .None:
					break
					//	No change on position and retry with another detector.
					
				case .Incomplete:
					let	sd	=	Subdata(definition: b, state: s1)
					self	=	MultiblockDetectionState.Incomplete(subdata: sd)
					return	//	Exit early.
					
				case .Complete:
					let	sd	=	Subdata(definition: b, state: s1)
					self	=	MultiblockDetectionState.Complete(subdata: sd)
					return	//	Exit early.
				}
			}
			var	sp1	=	s.position
			sp1.startIndex++
			sp1.endIndex++
			self	=	MultiblockDetectionState.None(position: sp1)	//	Advance position if nothing has been detected.
			
		case .Incomplete(let s):
			someStep(s, data: data)
			
		case .Complete(let s):
			someStep(s, data: data)
		}
	}
	private mutating func someStep(subdata:Subdata, data:CodeData) {
		var	s1	=	subdata.state
		s1.step(subdata.definition, data: data)
		
		switch s1.mode {
		case .None:
			assert(s1.selection.startIndex == s1.selection.endIndex)
			self	=	MultiblockDetectionState.None(position: s1.selection)
			
		case .Incomplete:
			let	sd	=	Subdata(definition: subdata.definition, state: s1)
			self	=	MultiblockDetectionState.Incomplete(subdata: sd)
			
		case .Complete:
			let	sd	=	Subdata(definition: subdata.definition, state: s1)
			self	=	MultiblockDetectionState.Complete(subdata: sd)
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
		
		var	s	=	MultiblockDetectionState.None(position: d.utf16.startIndex..<d.utf16.startIndex)
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
		
		var	s	=	MultiblockDetectionState.None(position: d.utf16.startIndex..<d.utf16.startIndex)
		
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
		
		var	s	=	MultiblockDetectionState.None(position: d.utf16.startIndex..<d.utf16.startIndex)
		
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
			return	s.subdata.state.selectionInDataForTest(data)
		case .Complete(let s):
			return	s.subdata.state.selectionInDataForTest(data)
		}
	}
	func restInDataForTest(data:CodeData) -> String {
		switch self {
		case .None(let s):
			return	String(data.substringWithUTF16Range(s.position.endIndex..<data.utf16.endIndex))
		case .Incomplete(let s):
			return	s.subdata.state.restInDataForTest(data)
		case .Complete(let s):
			return	s.subdata.state.restInDataForTest(data)
		}
	}
}















