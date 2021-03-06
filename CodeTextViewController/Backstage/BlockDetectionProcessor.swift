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
	var selection:UTF16Range {
		get {
			return	state.selection
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
		let	r	=	binarySearchForRangeOfGreaterValues(checkpoints, 0..<checkpoints.count, sample)
		checkpoints.removeRange(r)
		if checkpoints.count == 0 {
			state		=	MultiblockDetectionState.none(selection: 0..<0)
			debugLog("block detection cache reset to 0.")
		} else {
			let	cp1	=	checkpoints.last!
			let	pos	=	cp1.selection.endIndex > index ? cp1.selection.startIndex : cp1.selection.endIndex
			state	=	MultiblockDetectionState.none(selection: pos..<pos)
			debugLog("block detection cache reset to \(pos).")
		}
	}
	func step(reactions:T) {
		self.stepOpt(Unmanaged<T>.passUnretained(reactions))
	}
	func stepOpt(reactions:Unmanaged<T>) {
		assert(available)
		
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





/////	Comparison is based on `unicodeScalarValues.startIndex`.
//extension BlockDetectionState: Comparable {
//	var	utf16StartIndex:UTF16Index {
//		get {
//			return	selection.startIndex
//		}
//	}
//}
//func < (left:BlockDetectionState, right:BlockDetectionState) -> Bool {
//	return	left.utf16StartIndex < right.utf16StartIndex
//}
//func > (left:BlockDetectionState, right:BlockDetectionState) -> Bool {
//	return	left.utf16StartIndex > right.utf16StartIndex
//}
//func <= (left:BlockDetectionState, right:BlockDetectionState) -> Bool {
//	return	left.utf16StartIndex <= right.utf16StartIndex
//}
//func >= (left:BlockDetectionState, right:BlockDetectionState) -> Bool {
//	return	left.utf16StartIndex >= right.utf16StartIndex
//}
//func == (left:BlockDetectionState, right:BlockDetectionState) -> Bool {
//	return	left.utf16StartIndex == right.utf16StartIndex
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









