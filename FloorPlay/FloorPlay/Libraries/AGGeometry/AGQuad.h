//
// Author: Håvard Fossli <hfossli@agens.no>
// Author: https://github.com/kennytm
//
// Copyright (c) 2013 Agens AS (http://agens.no/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "AGPoint.h"

/*
 tl = top left
 tr = top right
 br = bottom right
 bl = bottom left
 */

typedef union AGQuad {
    struct { AGPoint tl, tr, br, bl; };
    AGPoint v[4];
} AGQuad;

extern const AGQuad AGQuadZero;
inline BOOL AGQuadEqual(AGQuad q1, AGQuad q2);
inline BOOL AGQuadIsConvex(AGQuad q);
inline BOOL AGQuadIsValid(AGQuad q);
inline AGQuad AGQuadMove(AGQuad q, double x, double y);
inline AGQuad AGQuadInsetLeft(AGQuad q, double inset);
inline AGQuad AGQuadInsetRight(AGQuad q, double inset);
inline AGQuad AGQuadInsetTop(AGQuad q, double inset);
inline AGQuad AGQuadInsetBottom(AGQuad q, double inset);
inline AGQuad AGQuadMirror(AGQuad q, BOOL x, BOOL y);
inline AGQuad AGQuadMake(AGPoint tl, AGPoint tr, AGPoint br, AGPoint bl);
inline AGQuad AGQuadMakeWithCGPoints(CGPoint tl, CGPoint tr, CGPoint br, CGPoint bl);
inline AGQuad AGQuadMakeWithCGRect(CGRect rect);
inline AGQuad AGQuadMakeWithCGSize(CGSize size);
inline double AGQuadGetSmallestX(AGQuad q);
inline double AGQuadGetBiggestX(AGQuad q);
inline double AGQuadGetSmallestY(AGQuad q);
inline double AGQuadGetBiggestY(AGQuad q);
inline CGRect AGQuadGetBoundingRect(AGQuad q);
inline AGPoint AGQuadGetCenter(AGQuad q);
inline CGSize AGQuadGetSize(AGQuad q);
void AGQuadGetXValues(AGQuad q, double *out_values);
void AGQuadGetYValues(AGQuad q, double *out_values);
inline AGQuad AGQuadInterpolation(AGQuad q1, AGQuad q2, double progress);
inline AGQuad AGQuadApplyCGAffineTransform(AGQuad q, CGAffineTransform t);
inline AGQuad AGQuadApplyCATransform3D(AGQuad q, CATransform3D t);
inline NSString * NSStringFromAGQuad(AGQuad q);

/**
 * @discussion
 *   It is only possible to make 'convex quadrilateral' with transforms.
 *   So make sure your quadrilateral is convex.
 *   http://upload.wikimedia.org/wikipedia/commons/f/f1/Quadrilateral_hierarchy.png
 */
CATransform3D CATransform3DWithQuadFromBounds(AGQuad q, CGRect rect);
CATransform3D CATransform3DWithQuadFromRect(AGQuad q, CGRect rect);

