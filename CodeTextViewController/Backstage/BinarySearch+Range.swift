////
////  BinarySearch+Range.swift
////  CodeTextViewController
////
////  Created by Hoon H. on 2015/01/08.
////  Copyright (c) 2015 Eonil. All rights reserved.
////
//
//import Swift
//
//func binarySearch<T:CollectionType where T.Index: RandomAccessIndexType, T.Generator.Element:Comparable>(collection:T, value:T.Generator.Element) -> T.Index? {
//	let	r	=	collection.startIndex..<collection.endIndex
//	return	binarySearch(collection, r, value)
//}
//
//func binarySearch<T:CollectionType where T.Index: RandomAccessIndexType, T.Generator.Element:Comparable>(collection:T, scope:Range<T.Index>, value:T.Generator.Element) -> T.Index? {
//	return	RandomAccessibleSubcollection(collection: collection, selection: scope).binarySearch(value)
//}
//
//
//private struct RandomAccessibleSubcollection<T:CollectionType where T.Index: RandomAccessIndexType, T.Generator.Element:Comparable> {
//	let	collection:T
//	let	selection:Range<T.Index>
//	
//	///	`collection`:	must be sorted in ascending order.
//	init(collection:T, selection:Range<T.Index>) {
//		self.collection	=	collection
//		self.selection	=	selection
//	}
//	
//	func binarySearch(value:T.Generator.Element) -> T.Index? {
//		let	dist	=	distance(selection.startIndex, selection.endIndex)
//		switch dist {
//		case 0:
//			return	nil
//			
//		case 1:
//			assert(selection.startIndex == selection.endIndex)
//			return	collection[selection.startIndex] == value ? selection.startIndex : nil
//			
//		default:
//			assert(dist >= 2)
//			assert(selection.startIndex < selection.endIndex)
//			let	halfdist	=	dist / 2
//			let	midpoint	=	selection.startIndex.advancedBy(halfdist)
//			assert(midpoint != selection.startIndex)
//			assert(midpoint != selection.endIndex)
//			let	midvalue	=	collection[midpoint]
//			let	sidedet		=	midvalue < value	//	midvalue is less than (and not equal to) the target.
//			
//			let	subscope	=	sidedet ? midpoint..<selection.endIndex : selection.startIndex..<midpoint
//			let	solution	=	RandomAccessibleSubcollection(collection: collection, selection: subscope).binarySearch(value)
//			
//			return	solution
//		}
//	}
//}
//
//
//
//
//
//
//
//
//
//////protocol ComparisonWrapper: Comparable {
//////	typealias	Element
//////	
//////	init(_ value:Element)
//////}
////func binarySearchWithWrapper<T:CollectionType, W:Comparable where T.Index: RandomAccessIndexType>(collection:T, scope:Range<T.Index>, value:T.Generator.Element, wrap:T.Generator.Element->W) -> T.Index? {
////	return	RandomAccessibleSubcollection(collection: collection, selection: scope).binarySearchWithWrapper(value, wrap)
////}
////
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//extension UnitTest {
//	static func testBinarySearch() {
//		test1()
//	}
//	private static func test1() {
//		func run(f:()->()) {
//			f()
//		}
//	
//		run {
//			let	col	=	[100,200,300]
//			let	idx	=	binarySearch(col, 200)!
//			let	val	=	col[idx]
//			assert(idx == 1)
//			assert(val == 200)
//		}
//	
//		run {
//			let	col	=	[100,200,300]
//			let	idx	=	binarySearch(col, 100)!
//			let	val	=	col[idx]
//			assert(idx == 0)
//			assert(val == 100)
//		}
//		
//		run {
//			let	col	=	[100,200,300]
//			let	idx	=	binarySearch(col, 300)!
//			let	val	=	col[idx]
//			assert(idx == 2)
//			assert(val == 300)
//		}
//		
//		run {
//			let	col	=	[100,200,300]
//			let	idx	=	binarySearch(col, 220)
//			assert(idx == nil)
//		}
//		
//		run {
//			let	col	=	[100,200,300]
//			let	idx	=	binarySearch(col, 400)
//			assert(idx == nil)
//		}
//		
//		run {
//			let	col	=	[100,200,300]
//			let	idx	=	binarySearch(col, 10)
//			assert(idx == nil)
//		}
//	}
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
