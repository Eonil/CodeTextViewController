//
//  BlockDetectionProcessor.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2014/12/29.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation













protocol BlockDetectionProcessorReaction: class {
	func onBlockNone(range:UTF16Range)
	func onBlockIncomplete(range:UTF16Range)
	func onBlockComplete(range:UTF16Range)
}


class BlockDetectionProcessor<T:BlockDetectionProcessorReaction> {
	let	data:CodeData
	
	init(definition:MultiblockDefinition, state:MultiblockDetectionState, data:CodeData) {
		self.definition		=	definition
		self.state			=	state
		self.data			=	data
		self.checkpoints	=	[]
	}
	
	var available:Bool {
		get {
			return	state.selection.endIndex < data.utf16Count
//			return	state.selection.endIndex < data.utf16.endIndex
		}
	}
	
	func invalidateFromIndex(index:UTF16Index) {
		//
		//	Take care that the String indexes/ranges are all will be invalidated after mutating the string.
		//	For example, an index of 7 captured when the String length is 7 will not advance to next index
		//	even the extra characters are appended to the string becuase the index thinks the length of string
		//	is still 7.
		//
		//	To deal with this, measure the location of the indexes/ranges and re-create them from the
		//	location for the new string.
		//
		if let p = binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue(checkpoints, MultiblockDetectionState.none(selection: index..<index), 0..<checkpoints.count) {
			checkpoints.removeRange(p..<checkpoints.count)
			let	pos	=	p == 0 ? data.utf16.startIndex : checkpoints[p-1].selection.endIndex
			
			state	=	MultiblockDetectionState.none(selection: pos..<pos)
		}
		
//		checkpoints	=	[]
//		state		=	MultiblockDetectionState.none(selection: 0..<0)
	}
	func step(reactions:T) {
		self.stepOpt(Unmanaged<T>.passUnretained(reactions))
	}
	func stepOpt(reactions:Unmanaged<T>) {
		assert(available)
//		if state.selection.startIndex % 1000 == 0 {
//			println(state.selection)
//		}
		
		state.step(definition, data:data)
		
		switch state.mode {
		case .None:
			reactions.takeUnretainedValue().onBlockNone(state.selection)
			
		case .Incomplete:
			reactions.takeUnretainedValue().onBlockIncomplete(state.selection)
			
		case .Complete:
			checkpoints.append(state)
			reactions.takeUnretainedValue().onBlockComplete(state.selection)
		}
	}
	
	////
	
	private let	definition:MultiblockDefinition
	private var	state:MultiblockDetectionState
	
	private var	checkpoints:[MultiblockDetectionState]	//	Sorted in ascending order.
}

























///	Comparison is based on `unicodeScalarValues.startIndex`.
extension MultiblockDetectionState: Comparable {
	var	utf16StartIndex:UTF16Index {
		get {
			return	selection.startIndex
		}
	}
}

///	Comparison is based on `unicodeScalarValues.startIndex`.
extension BlockDetectionState: Comparable {
	var	utf16StartIndex:UTF16Index {
		get {
			return	selection.startIndex
		}
	}
}





func < (left:MultiblockDetectionState, right:MultiblockDetectionState) -> Bool {
	return	left.utf16StartIndex < right.utf16StartIndex
}
func > (left:MultiblockDetectionState, right:MultiblockDetectionState) -> Bool {
	return	left.utf16StartIndex < right.utf16StartIndex
}
func <= (left:MultiblockDetectionState, right:MultiblockDetectionState) -> Bool {
	return	left.utf16StartIndex <= right.utf16StartIndex
}
func >= (left:MultiblockDetectionState, right:MultiblockDetectionState) -> Bool {
	return	left.utf16StartIndex >= right.utf16StartIndex
}
func == (left:MultiblockDetectionState, right:MultiblockDetectionState) -> Bool {
	return	left.utf16StartIndex == right.utf16StartIndex
}



func < (left:BlockDetectionState, right:BlockDetectionState) -> Bool {
	return	left.utf16StartIndex < right.utf16StartIndex
}
func > (left:BlockDetectionState, right:BlockDetectionState) -> Bool {
	return	left.utf16StartIndex < right.utf16StartIndex
}
func <= (left:BlockDetectionState, right:BlockDetectionState) -> Bool {
	return	left.utf16StartIndex <= right.utf16StartIndex
}
func >= (left:BlockDetectionState, right:BlockDetectionState) -> Bool {
	return	left.utf16StartIndex >= right.utf16StartIndex
}
func == (left:BlockDetectionState, right:BlockDetectionState) -> Bool {
	return	left.utf16StartIndex == right.utf16StartIndex
}












































///	MARK:
///	MARK:	Unit Test



extension UnitTest {
	private	class DummyDelegateForUnitTest: BlockDetectionProcessorReaction {
		func onBlockNone(range:UTF16Range) {
		}
		func onBlockIncomplete(range:UTF16Range) {
		}
		func onBlockComplete(range:UTF16Range) {
		}
	}
	
	static func testBlockDetectionController() {
		test1()
	}
	private static func test1() {
		let	del	=	DummyDelegateForUnitTest()
		let	a	=	NSMutableAttributedString(string: "//\n//\n;")
		let	c	=	testSyntax1(a, del) as BlockDetectionProcessor<DummyDelegateForUnitTest>
		
		assert(c.state.isNone())
		assert(c.state.restInDataForTest(c.data) == "//\n//\n;")
		
		c.step(del)
		assert(c.state.isIncomplete())
		c.step(del)
		assert(c.state.isComplete())
		c.step(del)
		assert(c.state.isNone())
		
		c.step(del)
		assert(c.state.isIncomplete())
		c.step(del)
		assert(c.state.isComplete())
		c.step(del)
		assert(c.state.isNone())
		assert(c.state.selectionInDataForTest(c.data) == "")
		assert(c.state.restInDataForTest(c.data) == ";")
		
		c.step(del)
		assert(c.state.isNone())
		assert(c.state.selectionInDataForTest(c.data) == ";")
		assert(c.state.restInDataForTest(c.data) == "")
		assert(c.available == false)
		
		a.insertAttributedString(NSAttributedString(string: "\n"), atIndex: "//\n//\n".utf16Count)
		assert(c.data.utf16Count == 8)
		c.invalidateFromIndex("//\n//\n".utf16Count)
		assert(a.string == "//\n//\n\n;")
		println(a.string)
		assert(c.state.selection.startIndex == "//\n".utf16.endIndex)
		assert(c.state.selection.endIndex == "//\n".utf16.endIndex)
		assert(c.state.restInDataForTest(c.data) == "//\n\n;")
		
		c.step(del)
		assert(c.state.isIncomplete())
		c.step(del)
		assert(c.state.isComplete())
		c.step(del)
		assert(c.state.isNone())
		assert(c.state.restInDataForTest(c.data) == "\n;")
		assert(c.state.selection.startIndex == "//\n//\n".utf16.endIndex)
		assert(c.state.selection.endIndex == "//\n//\n".utf16.endIndex)
		
		c.step(del)
		assert(c.state.isNone())
		assert(c.state.restInDataForTest(c.data) == ";")
		assert(c.state.selection.endIndex < a.length)
		println(c.state.selection.endIndex)
		println(c.data.utf16Count)
		println(c.available)
		assert(c.available == true)
		
		c.step(del)
		
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

private func testSyntax1<T:BlockDetectionProcessorReaction>(text:NSMutableAttributedString, delegate:T) -> BlockDetectionProcessor<T> {
	let	def	=	MultiblockDefinition(blocks: [
		BlockDefinition(startMark: "/*", endMark: "*/"),
		BlockDefinition(startMark: "//", endMark: "\n"),
		])
	let	s	=	MultiblockDetectionState.none(selection: text.string.utf16.startIndex..<text.string.utf16.startIndex)
	let	d	=	CodeData(target: text)
	let	sh	=	BlockDetectionProcessor<T>(definition: def, state: s, data: d)
	return	sh
}









