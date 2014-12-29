//
//  SyntaxHighlighter.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2014/12/29.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation













protocol BlockDetectionControllerDelegate: class {
	func onBlockComplete(range:URange)
}


class BlockDetectionController {
	weak var delegate:BlockDetectionControllerDelegate?
	
	let	data:CodeData
	
	init(definition:MultiblockDetection.Definition, state:MultiblockDetection.State, data:CodeData) {
		self.definition		=	definition
		self.state			=	state
		self.data			=	data
		self.checkpoints	=	[]
	}
	
	var available:Bool {
		get {
			return	state.selection.endIndex < data.unicodeScalars.endIndex
		}
	}
	func invalidateFromIndex(index:UIndex) {
		//
		//	Take care that the String indexes/ranges are all will be invalidated after mutating the string.
		//	For example, an index of 7 captured when the String length is 7 will not advance to next index
		//	even the extra characters are appended to the string becuase the index thinks the length of string
		//	is still 7.
		//
		//	To deal with this, measure the location of the indexes/ranges and re-create them from the
		//	location for the new string.
		//
		if let p = binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue(checkpoints, MultiblockDetection.State.None(position: index), 0..<checkpoints.count) {
			checkpoints.removeRange(p..<checkpoints.count)
			let	pos	=	p == 0 ? data.unicodeScalars.startIndex : checkpoints[p-1].unicodeScalarStartIndex
			
			state	=	MultiblockDetection.State.None(position: pos)
		}
	}
	func step() {
		assert(available)
//		if state.restInDataForTest(data).utf16Count == 1 {
//			println(state)
//			println(state.restInDataForTest(data))
//			println("\(available)")
//		}
		
		state.step(definition, data: data)
		
//		if state.restInDataForTest(data).utf16Count == 0 {
//			println(state)
//			println(state.restInDataForTest(data))
//			println("\(available)")
//		}
		
		switch state {
		case .Complete(let s):
			checkpoints.append(state)
			if s.substate.mode == .Complete {
				delegate?.onBlockComplete(s.substate.selection)
			}
			
		default:
			break
		}
	}
	
	////
	
	private let	definition:MultiblockDetection.Definition
	private var	state:MultiblockDetection.State
	
	private var	checkpoints:[MultiblockDetection.State]
	
}

























///	Comparison is based on `unicodeScalarValues.startIndex`.
extension MultiblockDetection.State: Comparable {
	var	unicodeScalarStartIndex:UIndex {
		get {
			switch self {
			case .None(let s):
				return	s.position
			case .Incomplete(let s):
				return	s.substate.unicodeScalarStartIndex
			case .Complete(let s):
				return	s.substate.unicodeScalarStartIndex
			}
		}
	}
}

///	Comparison is based on `unicodeScalarValues.startIndex`.
extension BlockDetection.State: Comparable {
	var	unicodeScalarStartIndex:UIndex {
		get {
			return	self.selection.endIndex
		}
	}
}





func < (left:MultiblockDetection.State, right:MultiblockDetection.State) -> Bool {
	return	left.unicodeScalarStartIndex < right.unicodeScalarStartIndex
}
func > (left:MultiblockDetection.State, right:MultiblockDetection.State) -> Bool {
	return	left.unicodeScalarStartIndex < right.unicodeScalarStartIndex
}
func <= (left:MultiblockDetection.State, right:MultiblockDetection.State) -> Bool {
	return	left.unicodeScalarStartIndex <= right.unicodeScalarStartIndex
}
func >= (left:MultiblockDetection.State, right:MultiblockDetection.State) -> Bool {
	return	left.unicodeScalarStartIndex >= right.unicodeScalarStartIndex
}
func == (left:MultiblockDetection.State, right:MultiblockDetection.State) -> Bool {
	return	left.unicodeScalarStartIndex == right.unicodeScalarStartIndex
}



func < (left:BlockDetection.State, right:BlockDetection.State) -> Bool {
	return	left.unicodeScalarStartIndex < right.unicodeScalarStartIndex
}
func > (left:BlockDetection.State, right:BlockDetection.State) -> Bool {
	return	left.unicodeScalarStartIndex < right.unicodeScalarStartIndex
}
func <= (left:BlockDetection.State, right:BlockDetection.State) -> Bool {
	return	left.unicodeScalarStartIndex <= right.unicodeScalarStartIndex
}
func >= (left:BlockDetection.State, right:BlockDetection.State) -> Bool {
	return	left.unicodeScalarStartIndex >= right.unicodeScalarStartIndex
}
func == (left:BlockDetection.State, right:BlockDetection.State) -> Bool {
	return	left.unicodeScalarStartIndex == right.unicodeScalarStartIndex
}












































///	MARK:
///	MARK:	Unit Test

extension UnitTest {
	static func testBlockDetectionController() {
		test1()
	}
	private static func test1() {
		let	a	=	NSMutableAttributedString(string: "//\n//\n;")
		let	c	=	testSyntax1(a)
		
		assert(c.state.isNone())
		assert(c.state.restInDataForTest(c.data) == "//\n//\n;")
		
		c.step()
		assert(c.state.isIncomplete())
		c.step()
		assert(c.state.isComplete())
		c.step()
		assert(c.state.isNone())
		
		c.step()
		assert(c.state.isIncomplete())
		c.step()
		assert(c.state.isComplete())
		c.step()
		assert(c.state.isNone())
		assert(c.state.restInDataForTest(c.data) == ";")
		
		c.step()
		assert(c.state.isNone())
		assert(c.state.restInDataForTest(c.data) == "")
		assert(c.available == false)
		
		a.insertAttributedString(NSAttributedString(string: "\n"), atIndex: "//\n//\n".utf16Count)
		c.invalidateFromIndex("//\n//\n".unicodeScalars.endIndex)
		assert(a.string == "//\n//\n\n;")
		println(a.string)
		assert(c.state.restInDataForTest(c.data) == "//\n\n;")
		
		c.step()
		assert(c.state.isIncomplete())
		c.step()
		assert(c.state.isComplete())
		c.step()
		assert(c.state.isNone())
		assert(c.state.restInDataForTest(c.data) == "\n;")
		
		c.step()
		assert(c.state.isNone())
		assert(c.state.restInDataForTest(c.data) == ";")
		assert(c.available == true)
		
		c.step()
		
		println(String(c.data.unicodeScalars))
		let	v1	=	c.state.selection.endIndex
		let	v	=	c.state.selection.endIndex.successor()
		let	v2	=	c.state.selection.endIndex.successor().successor()
		assert(c.state.isNone())
		println(c.state.restInDataForTest(c.data))
		assert(c.state.restInDataForTest(c.data) == "")
		assert(c.available == false)
	}
}

private func testSyntax1(text:NSMutableAttributedString) -> BlockDetectionController {
	let	def	=	MultiblockDetection.Definition(blocks: [
		BlockDetection.Definition(startMark: "/*", endMark: "*/"),
		BlockDetection.Definition(startMark: "//", endMark: "\n"),
		])
	let	s	=	MultiblockDetection.State.None(position: text.string.unicodeScalars.startIndex)
	let	d	=	CodeData(target: text)
	let	sh	=	BlockDetectionController(definition: def, state: s, data: d)
	return	sh
}









