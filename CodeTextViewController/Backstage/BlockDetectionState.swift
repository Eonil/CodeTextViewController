//
//  BlockDetectionState.swift
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
///		1	---		First `None`, second `Incomplete` with selection of length 2.
///			'/'
///		2	---		No state. Detector skips start mark at once.
///			'*'
///		3	---		`Incomplete` with `1..<3` range.
///			A
///		4	---		`Incomplete` with `1..<4` range.
///			'*'
///		5	---		No state. Detector skips end mark at once.
///			'/'
///		6	---		First `Complete` with `1..<6` range, second `None`. Second phase will not happend at the end of data.
///
///		7	---		`None` continues.
///
///
struct BlockDetectionState {
	var	mode:Mode
	var	selection:UTF16Range
	
	enum Mode {
		case None
		case Incomplete
		case Complete
	}
	mutating func step(definition:BlockDefinition, data:CodeData) {
		assert(selection.endIndex < data.utf16.endIndex)
		
		switch mode {
		case .None:
			assert(selection.startIndex == selection.endIndex)
			let	p	=	selection.startIndex
			let	ok	=	data.hasPrefixAtUTF16Index(definition.startMark, index: p)
			if ok {
				let	p1		=	advance(p, definition.startMark.utf16.endIndex)
				mode		=	Mode.Incomplete
				selection	=	UTF16Range(start: p, end: p1)
				
			} else {
				let	p1	=	p.successor()
				mode		=	Mode.None
				selection	=	p1..<p1
			}
			
		case .Incomplete:
			let	p	=	selection.endIndex
			let	ok	=	data.hasPrefixAtUTF16Index(definition.endMark, index: p)
			if ok {
				let	p2		=	advance(p, definition.endMark.utf16.endIndex)
				mode		=	Mode.Complete
				selection	=	UTF16Range(start: selection.startIndex, end: p2)
			} else {
				let	p2	=	p.successor()
				mode		=	Mode.Incomplete
				selection	=	UTF16Range(start: selection.startIndex, end: p2)
			}
			
		case .Complete:
			mode		=	Mode.None
			selection	=	selection.endIndex..<selection.endIndex
		}
	}
	mutating func stepOpt1(definition:Unmanaged<BlockDefinition>, data:Unmanaged<CodeData>) {
		assert(selection.endIndex < data.takeUnretainedValue().utf16.endIndex)
		
		switch mode {
		case .None:
			assert(selection.startIndex == selection.endIndex)
			let	p	=	selection.startIndex
			let	ok	=	data.takeUnretainedValue().hasPrefixAtUTF16Index(definition.takeUnretainedValue().startMark, index: p)
			if ok {
				let	p1		=	advance(p, definition.takeUnretainedValue().startMark.utf16.endIndex)
				mode		=	Mode.Incomplete
				selection	=	UTF16Range(start: p, end: p1)
				
			} else {
				let	p1	=	p.successor()
				mode		=	Mode.None
				selection	=	p1..<p1
			}
			
		case .Incomplete:
			let	p	=	selection.endIndex
			let	ok	=	data.takeUnretainedValue().hasPrefixAtUTF16Index(definition.takeUnretainedValue().endMark, index: p)
			if ok {
				let	p2		=	advance(p, definition.takeUnretainedValue().endMark.utf16.endIndex)
				mode		=	Mode.Complete
				selection	=	UTF16Range(start: selection.startIndex, end: p2)
			} else {
				let	p2	=	p.successor()
				mode		=	Mode.Incomplete
				selection	=	UTF16Range(start: selection.startIndex, end: p2)
			}
			
		case .Complete:
			mode		=	Mode.None
			selection	=	selection.endIndex..<selection.endIndex
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
		var	d	=	CodeData(target: NSMutableAttributedString(string: "ABCD"))
		let	p	=	d.utf16.startIndex
		
		let	def	=	BlockDefinition(startMark: "A", endMark: "C")
		var	s	=	BlockDetectionState(mode: BlockDetectionState.Mode.None, selection: d.utf16.startIndex..<d.utf16.startIndex)
		
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
		var	d	=	CodeData(target: NSMutableAttributedString(string: "abc/*def*/ghi"))
		let	p	=	d.unicodeScalars.startIndex
		
		let	def	=	BlockDefinition(startMark: "/*", endMark: "*/")
		var	s	=	BlockDetectionState(mode: BlockDetectionState.Mode.None, selection: d.utf16.startIndex..<d.utf16.startIndex)
		
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
		var	d	=	CodeData(target: NSMutableAttributedString(string: "abc/*def"))
		let	p	=	d.unicodeScalars.startIndex
		
		let	def	=	BlockDefinition(startMark: "/*", endMark: "*/")
		var	s	=	BlockDetectionState(mode: BlockDetectionState.Mode.None, selection: d.utf16.startIndex..<d.utf16.startIndex)
		
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
		assert(s.selection.endIndex < d.utf16.endIndex)
		
		s.step(def, data: d)
		assert(s.isIncomplete())
		assert(s.selectionInDataForTest(d) == "/*def")
		
		//	Further stepping undefined.
		//	User must stop stepping by investigating selection.
		//	Stepping at last is not allowed, but if the state is `Complete` 
		//	it will be changed into `None` once.
		assert(s.selection.endIndex == d.utf16.endIndex)
	}
}

extension BlockDetectionState {
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
		return	String(data.substringWithUTF16Range(selection))
	}
	func restInDataForTest(data:CodeData) -> String {
		return	String(data.substringWithUTF16Range(selection.endIndex..<data.utf16.endIndex))
	}
}

















































