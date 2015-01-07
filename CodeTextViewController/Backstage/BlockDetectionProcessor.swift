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
	
	///	Removed internal cache for the editing location.
	///
	///	Internal cache stored as `UTF16Range` form. Once user edited the string
	///	those indexes that later the editing point becomes invalid.
	///	This method clears any invalid indexes and reset the cache constuction point
	///	to a proper position.
	func invalidateFromIndex(index:UTF16Index) {
		let	sample	=	MultiblockDetectionState.none(selection: index..<index)
		//
		//	`MultiblockDetectionState` will be compared by its start index.
		//
		if let p = binarySearchForIndexOfLargestValueEqualToOrLessThanValue(checkpoints, sample, 0..<checkpoints.count) {
			//	If last checkpoint block is including the editing point, it also need to be removed.
			let	p1	=	checkpoints[p].selection.endIndex > index ? p : p+1
			checkpoints.removeRange((p1)..<checkpoints.count)
			
			let	pos	=	p1 == 0 ? 0 : checkpoints[p1-1].selection.endIndex
//			println("requested to invalidate at \(index), and invalidated at \(pos) \(data.substringWithUTF16Range(UTF16Range(start: pos, end: pos+4)))")
			state	=	MultiblockDetectionState.none(selection: pos..<pos)
		} else {
			println("requested invalidation at non-token position. no need to invalidate.")
			checkpoints	=	[]
			state		=	MultiblockDetectionState.none(selection: 0..<0)
		}
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
	
	private var	checkpoints:[MultiblockDetectionState]		//	Sorted in ascending order.
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
	return	left.utf16StartIndex > right.utf16StartIndex
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
	return	left.utf16StartIndex > right.utf16StartIndex
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





























//class CheckpointDatabase {
//	var	pages	=	[] as [[Checkpoint]]
//}
//
//class Page {
//	
//}







































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
		test2()
	}
	
	private static func test1() {
		let	del	=	DummyDelegateForUnitTest()
		let	a	=	NSMutableAttributedString(string: "<A><B><C>")
		let	c	=	testSyntax1(a, del) as BlockDetectionProcessor<DummyDelegateForUnitTest>
		
		assert(c.state.isNone())
		assert(c.state.restInDataForTest(c.data) == "<A><B><C>")
		
		c.step(del)
		assert(c.state.isIncomplete())
		c.step(del)
		assert(c.state.isIncomplete())
		c.step(del)
		assert(c.state.isComplete())
		assert(c.state.selectionInDataForTest(c.data) == "<A>")
		c.step(del)
		assert(c.state.isNone())
		assert(c.state.selectionInDataForTest(c.data) == "")
		assert(c.state.restInDataForTest(c.data) == "<B><C>")
		
		c.step(del)
		assert(c.state.isIncomplete())
		c.step(del)
		assert(c.state.isIncomplete())
		assert(c.state.restInDataForTest(c.data) == "><C>")
		
		a.insertAttributedString(NSAttributedString(string: "<X>"), atIndex: "<A><B>".utf16Count)
		assert(c.data.utf16Count == 12)
		c.invalidateFromIndex(c.state.selection.endIndex)
		assert(c.state.selection.startIndex == "<A>".utf16.endIndex)
		assert(c.state.selection.endIndex == "<A>".utf16.endIndex)
		assert(c.state.restInDataForTest(c.data) == "<B><X><C>")
	}

	private static func test2() {
		let	del	=	DummyDelegateForUnitTest()
		let	a	=	NSMutableAttributedString(string: "//\n//\n;")
		let	c	=	testSyntax2(a, del) as BlockDetectionProcessor<DummyDelegateForUnitTest>
		
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
		assert(c.state.selection.startIndex == "//\n//\n".utf16.endIndex)
		assert(c.state.selection.endIndex == "//\n//\n".utf16.endIndex)
		assert(c.state.restInDataForTest(c.data) == "\n;")
		
		c.step(del)
		assert(c.state.isNone())
		assert(c.state.restInDataForTest(c.data) == ";")
		assert(c.state.selection.startIndex == "//\n//\n".utf16.endIndex)
		assert(c.state.selection.endIndex == "//\n//\n\n".utf16.endIndex)
		assert(c.available == true)
		
		c.step(del)
		assert(c.state.isNone())
		assert(c.state.restInDataForTest(c.data) == "")
		assert(c.state.selection.startIndex == "//\n//\n\n".utf16.endIndex)
		assert(c.state.selection.endIndex == "//\n//\n\n;".utf16.endIndex)
		assert(c.available == false)
		
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
		BlockDefinition(startMark: "<", endMark: ">"),
		])
	let	s	=	MultiblockDetectionState.none(selection: text.string.utf16.startIndex..<text.string.utf16.startIndex)
	let	d	=	CodeData(target: text)
	let	sh	=	BlockDetectionProcessor<T>(definition: def, state: s, data: d)
	return	sh
}
private func testSyntax2<T:BlockDetectionProcessorReaction>(text:NSMutableAttributedString, delegate:T) -> BlockDetectionProcessor<T> {
	let	def	=	MultiblockDefinition(blocks: [
		BlockDefinition(startMark: "/*", endMark: "*/"),
		BlockDefinition(startMark: "//", endMark: "\n"),
		])
	let	s	=	MultiblockDetectionState.none(selection: text.string.utf16.startIndex..<text.string.utf16.startIndex)
	let	d	=	CodeData(target: text)
	let	sh	=	BlockDetectionProcessor<T>(definition: def, state: s, data: d)
	return	sh
}









