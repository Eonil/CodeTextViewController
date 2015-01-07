//
//  BinarySearch+Nearest.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2014/12/29.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation











///	`collection`	must be a ascending sorted collection. Otherwise result undefined.
func binarySearchForRangeOfLessValues<C:CollectionType where C:Sliceable, C.Index: RandomAccessIndexType, C.Generator.Element:Comparable>(collection:C, scope:Range<C.Index>, value:C.Generator.Element) -> Range<C.Index> {
	let	dist		=	distance(scope.startIndex, scope.endIndex)
	switch dist {
	case 0:
		return	scope
		
	case 1:
		assert(scope.startIndex.successor() == scope.endIndex)
		let	sample	=	collection[scope.startIndex]
		let	endidx	=	sample < value ? scope.endIndex : scope.startIndex
		return	scope.startIndex..<endidx
	
	default:
		assert(distance(scope.startIndex, scope.endIndex) >= 2)
		let	halfdist	=	dist / 2
		let	midpoint	=	scope.startIndex.advancedBy(halfdist)
		let	midvalue	=	collection[midpoint]
		
		if midvalue < value {
			let	s1	=	midpoint..<scope.endIndex
			let r1	=	binarySearchForRangeOfLessValues(collection, s1, value)
			assert(r1.startIndex == midpoint)
			return	scope.startIndex..<r1.endIndex
		} else {
			let	s1	=	scope.startIndex..<midpoint
			let r1	=	binarySearchForRangeOfLessValues(collection, s1, value)
			return	r1
		}
	}
}


///	`collection`	must be a ascending sorted collection. Otherwise result undefined.
func binarySearchForRangeOfGreaterValues<C:CollectionType where C:Sliceable, C.Index: RandomAccessIndexType, C.Generator.Element:Comparable>(collection:C, scope:Range<C.Index>, value:C.Generator.Element) -> Range<C.Index> {
	let	dist		=	distance(scope.startIndex, scope.endIndex)
	switch dist {
	case 0:
		return	scope
		
	case 1:
		assert(scope.startIndex.successor() == scope.endIndex)
		let	sample		=	collection[scope.startIndex]
		let	startidx	=	sample > value ? scope.startIndex : scope.endIndex
		return	startidx..<scope.endIndex
		
	default:
		assert(distance(scope.startIndex, scope.endIndex) >= 2)
		let	halfdist	=	dist / 2
		let	midpoint	=	scope.startIndex.advancedBy(halfdist)
		let	midvalue	=	collection[midpoint]
		
		if midvalue > value {
			let	s1	=	scope.startIndex..<midpoint
			let r1	=	binarySearchForRangeOfGreaterValues(collection, s1, value)
			println("scope \(scope)")
			println(midpoint)
			println(r1)
			assert(r1.endIndex == midpoint)
			return	r1.startIndex..<scope.endIndex
		} else {
			let	s1	=	midpoint..<scope.endIndex
			let r1	=	binarySearchForRangeOfGreaterValues(collection, s1, value)
			return	r1
		}
	}
}








































///	MARK:
///	MARK:	Unit Test

extension UnitTest {
	static func testNearestBinarySearch() {
		testLessRange()
		testGreaterRange()
	}
	
	
	
	private static func run(b:()->()) {
		b()
	}
	private static func testLessRange() {
		run() {
			let	a	=	[100, 200, 300, 400, 500]
			let	r	=	binarySearchForRangeOfLessValues(a, a.startIndex..<a.endIndex, 0)
			assert(r == 0..<0)
		}
		run() {
			let	a	=	[100, 200, 300, 400, 500]
			let	r	=	binarySearchForRangeOfLessValues(a, a.startIndex..<a.endIndex, 99)
			assert(r == 0..<0)
		}
		run() {
			let	a	=	[100, 200, 300, 400, 500]
			let	r	=	binarySearchForRangeOfLessValues(a, a.startIndex..<a.endIndex, 199)
			assert(r == 0..<1)
		}
		run() {
			let	a	=	[100, 200, 300, 400, 500]
			let	r	=	binarySearchForRangeOfLessValues(a, a.startIndex..<a.endIndex, 299)
			assert(r == 0..<2)
		}
		run() {
			let	a	=	[100, 200, 300, 400, 500]
			let	r	=	binarySearchForRangeOfLessValues(a, a.startIndex..<a.endIndex, 399)
			assert(r == 0..<3)
		}
		run() {
			let	a	=	[100, 200, 300, 400, 500]
			let	r	=	binarySearchForRangeOfLessValues(a, a.startIndex..<a.endIndex, 499)
			assert(r == 0..<4)
		}
		run() {
			let	a	=	[100, 200, 300, 400, 500]
			let	r	=	binarySearchForRangeOfLessValues(a, a.startIndex..<a.endIndex, 599)
			assert(r == 0..<5)
		}
		run() {
			let	a	=	[100, 200, 300, 400, 500]
			let	r	=	binarySearchForRangeOfLessValues(a, a.startIndex..<a.endIndex, 699)
			assert(r == 0..<5)
		}
	}
	
	
	private static func testGreaterRange() {
		run() {
			let	a	=	[100, 200, 300, 400, 500]
			let	r	=	binarySearchForRangeOfGreaterValues(a, a.startIndex..<a.endIndex, 0)
			assert(r == 0..<5)
		}
		run() {
			let	a	=	[100, 200, 300, 400, 500]
			let	r	=	binarySearchForRangeOfGreaterValues(a, a.startIndex..<a.endIndex, 01)
			assert(r == 0..<5)
		}
		run() {
			let	a	=	[100, 200, 300, 400, 500]
			let	r	=	binarySearchForRangeOfGreaterValues(a, a.startIndex..<a.endIndex, 101)
			assert(r == 1..<5)
		}
		run() {
			let	a	=	[100, 200, 300, 400, 500]
			let	r	=	binarySearchForRangeOfGreaterValues(a, a.startIndex..<a.endIndex, 201)
			assert(r == 2..<5)
		}
		run() {
			let	a	=	[100, 200, 300, 400, 500]
			let	r	=	binarySearchForRangeOfGreaterValues(a, a.startIndex..<a.endIndex, 301)
			assert(r == 3..<5)
		}
		run() {
			let	a	=	[100, 200, 300, 400, 500]
			let	r	=	binarySearchForRangeOfGreaterValues(a, a.startIndex..<a.endIndex, 401)
			assert(r == 4..<5)
		}
		run() {
			let	a	=	[100, 200, 300, 400, 500]
			let	r	=	binarySearchForRangeOfGreaterValues(a, a.startIndex..<a.endIndex, 501)
			assert(r == 5..<5)
		}
	}
}











