;;;; "osx ffis"
;;; Implements datatypes and procedures for interacting with OS X
;;; APIs.

(c-declare "#import <UIKit/UIKit.h>")

(include "osx#.scm")

;;;; Cocoa

;;;;; NSArray

(define (NSArray->list arr)
  (let ((len (NSArray-length arr)))
    (unfold (lambda (i) (>= i len))
            (lambda (i) (NSArray-ref arr i))
            (lambda (i) (+ i 1))
            0)))

(define NSArray-length
  (c-lambda (NSArray*) int "___result = [___arg1 count];"))

(define NSArray-ref
  (c-lambda (NSArray* int) id #<<end-c-code
   ___result_voidstar = [___arg1 objectAtIndex:___arg2];
end-c-code
))

;;; NSArray-set! is not implemented. Yo.

;;;;; NSSet

(define NSSet->NSArray
 (c-lambda (NSSet*) NSArray* "___result_voidstar = [___arg1 allObjects];"))

(define (NSSet->list set)
  (NSArray->list (NSSet->NSArray set)))

;;;; Quartz

;;;;; CGPoint

(define CGPoint-x
  (c-lambda (CGPoint) CGFloat "___result = ___arg1.x;"))

(define CGPoint-y
  (c-lambda (CGPoint) CGFloat "___result = ___arg1.y;"))

;;;;; CGSize

(define CGSize-width
  (c-lambda (CGSize) CGFloat "___result = ___arg1.width;"))

(define CGSize-height
  (c-lambda (CGSize) CGFloat "___result = ___arg1.height;"))

;;;;; CGRect

;;; WARNING: Do not use this function yet, it crashes for some reason
(define CGRect-origin
  (c-lambda (CGRect) CGPoint #<<end-c-code
   CGPoint *res = malloc(sizeof(CGPoint));
   *res = ___arg1.origin;
   ___result_voidstar = res;
end-c-code
))

;;; WARNING: Do not use this function yet, it crashes for some reason
(define CGRect-size
  (c-lambda (CGRect) CGSize #<<end-c-code
   CGSize *res = malloc(sizeof(CGSize));
   *res = ___arg1.size;
   ___result_voidstar = res;
end-c-code
))
