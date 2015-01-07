//
//  BinarySearch+Nearest.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2014/12/29.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation



/////	Look with `25`.
/////
/////		0  1  2  3  4
/////
/////		|10|20|30|40|
/////
/////		      ^
/////		      Index `2` is the solution.
/////
//func binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue<C:CollectionType where C.Generator.Element:Comparable, C.Index:RandomAccessIndexType>(collection:C, value:C.Generator.Element, inRange:Range<C.Index>) -> C.Index? {
//	let	count	=	inRange.endIndex - inRange.startIndex
//	
//	switch count {
//	case 0:	return	nil
//	case 1: return	inRange.startIndex
//		
//	default:
//		let	midpoint	=	centerIndexInRange(inRange)
//		let	midvalue	=	collection[midpoint]
//		if midvalue < value {
//			return	binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue(collection, value, inRange.startIndex..<midpoint)
//		} else {
//			return	binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue(collection, value, midpoint..<inRange.endIndex)
//		}
//	}
//}


///	Look with `25`.
///
///		0  1  2  3  4
///
///		|10|20|30|40|
///
///		   ^
///		   Index `1` is the solution.
///
func binarySearchForIndexOfLargestValueEqualToOrLessThanValue<C:CollectionType where C.Generator.Element:Comparable, C.Index:RandomAccessIndexType>(collection:C, value:C.Generator.Element, inRange:Range<C.Index>) -> C.Index? {
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

private func centerIndexInRange<T:RandomAccessIndexType>(range:Range<T>) -> T {
	let	dist		=	distance(range.startIndex, range.endIndex)
	let	halfdist	=	dist / 2
	let	idx			=	range.startIndex.advancedBy(halfdist)
	assert(range.startIndex < idx)
	assert(range.endIndex > idx)
	return	idx
}











/////	`collection`	must be a ascending sorted collection. Otherwise result undefined.
//func binarySearchIndexOfLargestValuesThatLessThanValue<C:CollectionType where C.Index: RandomAccessIndexType, C.Generator.Element:Comparable>(collection:C, value:C.Generator.Element) -> Range<Int> {
//	let	dist		=	distance(collection.startIndex, collection.endIndex)
//	let	halfdist	=	dist / 2
//	let	midpoint	=	collection.startIndex.advancedBy(halfdist)
//	let	midvalue	=
//}










































///	MARK:
///	MARK:	Unit Test

extension UnitTest {
	static func testNearestBinarySearch() {
		func run(b:()->()) {
			b()
		}
		
//		run() {
//			let	a	=	[] as Array<Int>
//			let	idx	=	binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue(a, 15, a.startIndex..<a.endIndex)
//			assert(idx == nil)
//		}
//		
//		run() {
//			let	a	=	[20]
//			let	idx	=	binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue(a, 15, a.startIndex..<a.endIndex)!
//			assert(idx == 0)
//			assert(a[idx] == 20)
//		}
//		
//		run() {
//			let	a	=	[10, 20]
//			let	idx	=	binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue(a, 15, a.startIndex..<a.endIndex)!
//			assert(idx == 1)
//			assert(a[idx] == 20)
//		}
//		run() {
//			let	a	=	[10, 20]
//			let	idx	=	binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue(a, 20, a.startIndex..<a.endIndex)!
//			assert(idx == 1)
//			assert(a[idx] == 20)
//		}
//		
//		run() {
//			let	a	=	[10, 20, 30]
//			let	idx	=	binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue(a, 20, a.startIndex..<a.endIndex)!
//			assert(idx == 1)
//			assert(a[idx] == 20)
//		}
//		
//		run() {
//			let	a	=	[10, 20, 30]
//			let	idx	=	binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue(a, 15, a.startIndex..<a.endIndex)!
//			assert(idx == 1)
//			assert(a[idx] == 20)
//		}
		
		
//		run() {
//			let	a	=	[100, 200, 300, 400, 500]
//			let	idx	=	binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue(a, 300, a.startIndex..<a.endIndex)!
//			assert(idx == 2)
//			assert(a[idx] == 300)
//		}
		
		
//		run() {
//			let	a	=	[100, 200, 300, 400, 500]
//			let	idx	=	binarySearchForIndexOfSmallestValueEqualToOrGreaterThanValue(a, 299, a.startIndex..<a.endIndex)!
//			assert(idx == 2)
//			assert(a[idx] == 300)
//		}
		
		run() {
			let	a	=	[100, 200, 300, 400, 500]
			let	idx	=	binarySearchForIndexOfLargestValueEqualToOrLessThanValue(a, 300, a.startIndex..<a.endIndex)!
			assert(idx == 2)
			assert(a[idx] == 300)
		}
		
		run() {
			let	a	=	[100, 200, 300, 400, 500]
			let	idx	=	binarySearchForIndexOfLargestValueEqualToOrLessThanValue(a, 199, a.startIndex..<a.endIndex)!
			assert(idx == 0)
			assert(a[idx] == 100)
		}
		run() {
			let	a	=	[100, 200, 300, 400, 500]
			let	idx	=	binarySearchForIndexOfLargestValueEqualToOrLessThanValue(a, 299, a.startIndex..<a.endIndex)!
			assert(idx == 1)
			assert(a[idx] == 200)
		}
		run() {
			let	a	=	[100, 200, 300, 400, 500]
			let	idx	=	binarySearchForIndexOfLargestValueEqualToOrLessThanValue(a, 399, a.startIndex..<a.endIndex)!
			assert(idx == 2)
			assert(a[idx] == 300)
		}
		run() {
			let	a	=	[100, 200, 300, 400, 500]
			let	idx	=	binarySearchForIndexOfLargestValueEqualToOrLessThanValue(a, 499, a.startIndex..<a.endIndex)!
			assert(idx == 3)
			assert(a[idx] == 400)
		}
		run() {
			let	a	=	[100, 200, 300, 400, 500]
			let	idx	=	binarySearchForIndexOfLargestValueEqualToOrLessThanValue(a, 599, a.startIndex..<a.endIndex)!
			assert(idx == 4)
			assert(a[idx] == 500)
		}
	}
}











