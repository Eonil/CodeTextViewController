NOTE
====








GOAL
----
-	Acceptable syntax highlighting performance files smaller than 500KB.

NON-GOAL
--------
-	Acceptable syntax highlighting performance files larger than 500KB.




ROADMAP
-------

-	[OpenGL rendering to/from another process](http://cocoadhoc.blogspot.kr/2009/09/hidden-gems-of-snow-leopard-iosurface.html)








OPTIMISATION NOTE
-----------------

-	Setting attributes on a `NSTextStorage` is NOT a bottleneck. It is still so fast.
-	Bottleneck is always a `NSLayoutManager/NSTextView` invalidation and redrawing. Minimise it.












Some Details
------------

-	`NSLayoutManager.setTemporaryAttributes(:forCharacterRange:)` is far faster
	than `NSTextStorage.setAttributes(:range:)`. On My iMac, former took about 2
	seconds, and latter took about 17 seconds in optimised build of test suit.

-	Anyway, modifying `NSTextStorage` also took 2 seconds when wrapped by `beginEditing`/`endEditing` pair.
	So this performance drop is mainly due to inefficient layout refresh. You will get same performance
	if you can suppress the layout refreshes.

-	You don't need to subclass `NSTextStorage` just for performance. Just set
	attributes to layout-manager to avoid unnecessary layout cost.

-	Anyway those *temporary* attribution will not be kept when you copy the text.
	If you want colorised text when copying text to pasteboard, I think you can
	combine temporary attributes with source text on-the-fly when you copying the text.

-	You should use UTF16 based counting. Because;
	We're dealing with fully mutable string.
	Any other indexing uses *iterator* semantics, then they will be invalidated after mutating the target string.
	UTF16 based counting is simply an `Int`, and will not be invalidated.


















