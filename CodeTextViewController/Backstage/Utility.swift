//
//  Utility.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2014/12/27.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation


func assertMainThread() {
	assert(NSThread.currentThread() == NSThread.mainThread(), "Must be called from the main thread.")
}
func assertNonMainThread() {
	assert(NSThread.currentThread() != NSThread.mainThread(), "Must be called from a non-main thread.")
}




func debugLog<T>(s:@autoclosure()->T) {
	#if DEBUG
		println("\(s())")
	#endif
}






func dispatchMain(f:()->()) {
	dispatch_async(dispatch_get_main_queue()) {
		f()
	}
}






extension NSRange {
	static func fromUTF16Range(range:UTF16Range) -> NSRange {
		assert(range.startIndex <= range.endIndex)
		return	NSRange(location: range.startIndex, length: range.endIndex-range.startIndex)
	}
}


func intersect<T:RandomAccessIndexType>(left:Range<T>, right:Range<T>) -> Range<T>? {
	let	start	=	max(left.startIndex, right.startIndex)
	let	end		=	min(left.endIndex, right.endIndex)
	if start <= end {
		return	start..<end
	}
	return	nil
}













































///	MARK:
///	MARK:	Junkyard



/////	Type-safe wrapper for UTF-16 index.
//struct UTF16Index: BidirectionalIndexType {
//	typealias	Distance	=	Int
//
//	func successor() -> UTF16Index {
//		return	UTF16Index(number.successor())
//	}
//	func predecessor() -> UTF16Index {
//		return	UTF16Index(number.predecessor())
//	}
//
//	private let	number:Int
//	private init(_ value:Int) {
//		self.number	=	value
//	}
//}
//func == (left:UTF16Index, right:UTF16Index) -> Bool {
//	return	left.number == right.number
//}
//func < (left:UTF16Index, right:UTF16Index) -> Bool {
//	return	left.number < right.number
//}
//
//extension String {
//	var	utf16StartIndex:UTF16Index {
//		get {
//			return	UTF16Index(utf16.startIndex)
//		}
//	}
//	var	utf16EndIndex:UTF16Index {
//		get {
//			return	UTF16Index(utf16.endIndex)
//		}
//	}
//}



















//extension String.UnicodeScalarView {
//	func substringFromIndex(index:UIndex) -> String {
//		return	String(self[index..<endIndex])
//	}
//}

//extension String {
//	func convertNSRangeToRange(range:NSRange) -> Range<String.Index> {
//		assert(range.location != NSNotFound)
//
//		let	s	=	self as NSString
//		let	s1	=	s.substringToIndex(range.location)
//		let	s2	=	s.substringToIndex(range.location + range.length)
//		let	b	=	s1.endIndex
//		let	e	=	s2.endIndex
//		return	b..<e
//	}
//	func convertRangeFromNSRange(range:Range<String.Index>) -> NSRange {
//		assert(range.startIndex <= range.endIndex)
//
//		let	s1	=	self[startIndex..<range.startIndex]
//		let	s2	=	self[startIndex..<range.endIndex]
//		return	NSRange(location: s1.utf16Count, length: s2.utf16Count - s1.utf16Count)
//	}
//
//	func convertNSStringLocationToIndex(location:Int) -> String.Index {
//		assert(location != NSNotFound)
//
//		let	s	=	self as NSString
//		let	s1	=	s.substringToIndex(location)
//		let	b	=	s1.endIndex
//		return	b
//	}
//	func convertRangeFromNSStringLocation(index:String.Index) -> Int {
//		let	s1	=	self[startIndex..<index]
//		return	s1.utf16Count
//	}
//}







