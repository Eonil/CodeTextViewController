//
//  BinarySearch.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2014/12/29.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation



///	Look with `15`.
///
///		0  1  2  3
///
///		|10|20|30|
///
///		   ^
///		   Index `1` is the solution.
///
func binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue<C:CollectionType where C.Generator.Element:Comparable, C.Index == Int>(collection:C, value:C.Generator.Element, inRange:Range<Int>) -> Int? {
	let	count	=	inRange.endIndex - inRange.startIndex
	
	switch count {
	case 0:	return	nil
	case 1: return	inRange.startIndex
		
	default:
		let	centerP	=	centerIndexInRange(inRange)
		if collection[inRange.startIndex] >= value {
			return	binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue(collection, value, inRange.startIndex..<centerP)
		} else {
			return	binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue(collection, value, centerP..<inRange.endIndex)
		}
	}
}


func binarySearchForIndexOfLargestValueEqualToOrLessThanValue<C:CollectionType where C.Generator.Element:Comparable, C.Index == Int>(collection:C, value:C.Generator.Element, inRange:Range<Int>) -> Int? {
	let	count	=	inRange.endIndex - inRange.startIndex
	
	switch count {
	case 0:	return	nil
	case 1: return	inRange.startIndex
		
	default:
		let	centerP	=	centerIndexInRange(inRange)
		if collection[centerP] <= value {
			let	r2		=	centerP..<inRange.endIndex
			return	binarySearchForIndexOfLargestValueEqualToOrLessThanValue(collection, value, r2)
		} else {
			let	r1		=	inRange.startIndex..<centerP
			return	binarySearchForIndexOfLargestValueEqualToOrLessThanValue(collection, value, r1)
		}
	}
}

private func centerIndexInRange(range:Range<Int>) -> Int {
	let	idx	=	(range.endIndex - range.startIndex) / 2 + range.startIndex
	assert(range.startIndex < idx)
	assert(range.endIndex > idx)
	return	idx
}















































///	MARK:
///	MARK:	Unit Test

extension UnitTest {
	static func testBinarySearch() {
		func run(b:()->()) {
			b()
		}
		
		run() {
			let	a	=	[] as Array<Int>
			let	idx	=	binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue(a, 15, a.startIndex..<a.endIndex)
			assert(idx == nil)
		}
		
		run() {
			let	a	=	[20]
			let	idx	=	binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue(a, 15, a.startIndex..<a.endIndex)!
			assert(idx == 0)
			assert(a[idx] == 20)
		}
		
		run() {
			let	a	=	[10, 20]
			let	idx	=	binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue(a, 15, a.startIndex..<a.endIndex)!
			assert(idx == 1)
			assert(a[idx] == 20)
		}
		run() {
			let	a	=	[10, 20]
			let	idx	=	binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue(a, 20, a.startIndex..<a.endIndex)!
			assert(idx == 1)
			assert(a[idx] == 20)
		}
		
		run() {
			let	a	=	[10, 20, 30]
			let	idx	=	binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue(a, 20, a.startIndex..<a.endIndex)!
			assert(idx == 1)
			assert(a[idx] == 20)
		}
		
		run() {
			let	a	=	[10, 20, 30]
			let	idx	=	binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue(a, 15, a.startIndex..<a.endIndex)!
			assert(idx == 1)
			assert(a[idx] == 20)
		}
		
		run() {
			let	a	=	[100, 200, 300, 400, 500]
			let	idx	=	binarySearchForIndexOfLargestValueEqualToOrLessThanValue(a, 300, a.startIndex..<a.endIndex)!
			assert(idx == 2)
			assert(a[idx] == 300)
		}
		
		run() {
			let	a	=	[100, 200, 300, 400, 500]
			let	idx	=	binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue(a, 300, a.startIndex..<a.endIndex)!
			assert(idx == 2)
			assert(a[idx] == 300)
		}
		
		run() {
			let	a	=	[100, 200, 300, 400, 500]
			let	idx	=	binarySearchForIndexOfLargestValueEqualToOrLessThanValue(a, 299, a.startIndex..<a.endIndex)!
			assert(idx == 1)
			assert(a[idx] == 200)
		}
		
		run() {
			let	a	=	[100, 200, 300, 400, 500]
			let	idx	=	binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue(a, 299, a.startIndex..<a.endIndex)!
			assert(idx == 2)
			assert(a[idx] == 300)
		}
	}
}











