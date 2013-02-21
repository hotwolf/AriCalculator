*
*       S12X test case
*

	CPU	S12X
	
char    equ     65
immed   equ     $72
dir     equ     $55
ext     equ     $1234
ind     equ     $37
small   equ     $e
mask    equ     %11001100
ROTATE000 EQU	$0188
ROTATE001 EQU	$8944
ROTATE002 EQU	$3333
ROTATE003 EQU	$4444
INDEX	EQU	3
*
*
*
	ORG		$1000

TEST1	EQU	1
TEST2	EQU	2
TEST3	EQU	3
TEST4	EQU	4
TEST5	EQU	5
TEST6	EQU	6
TEST7	EQU	7
TEST8	EQU	8
				
#ifdef	TEST1
	ldaa	#TEST1
#ifdef	TEST2
	ldaa	#TEST2
#ifndef	TEST3
	ldab	#TEST3
#ifdef	TEST4
	ldab	#TEST4
#endif
#ifdef	TEST5
	ldaa	#TEST5
*#ifdef	TEST6
*	ldaa	#TEST6
*#ifdef TEST7
*	ldaa	#TEST7
*#ifdef	TEST8
*	ldaa	#TEST8
*#endif
*#endif
*#endif
#else
	ldd	#3333
#ifdef	TEST7
	ldd	#7777
#else
	ldaa	#'N'
#endif				
#endif
#else
	ldd	#3333
#ifdef	TEST17
	ldd	#7777
#else
	ldaa	#'N'
#endif				
#endif
#endif
#endif	
*#endif		

	ORG		$4000
				

	movb	5,-y,-16,sp

#ifdef a4fn
	movb	5,-y,-16,x
#endif

#ifdef b32ff	
	movb	5,-y,-16,y
#endif

; funny ` test
; stinky `` test
;
	movb	5,-y -small,pc
	movb	5,-y,-small,pc
happy`

	movb	5,-y -small,sp
	movb	5,-y,-small,sp
	movb	5,y- -small,sp
	movb	5,y-,-small,sp
	

	dw	2
	db	2
	dc.w	2
	dc.b	2
	fcb	2
	fdb	2222
	ds	34
	ds.b	34
	ds.w	34
	rmb	34
	rmw	34

bb equ 1

#ifdef aa
	movb	5,-y -small,x
	movb	5,-y,-small,x
#endif

	movb	5,-y -small,y
	movb	5,-y,-small,y

#ifdef aa
	movb	5,-y 0,pc
	movb	5,-y,0,pc
#endif
	
	movb	5,-y 0,sp 
	movb	5,-y,0,sp
	trap	$49

#ifdef aa
	bclr	1,+sp $55
	bclr	1,+sp #$55
	bclr	1,+sp,#$55
	bclr	1,sp-,#$55
	bclr	1,sp- #$55
#endif

#ifdef bb
	bclr	1,+x $55
	bclr	1,+x #$55
	bclr	1,+x,$55
	bclr	1,+x,#$55
#endif

	bclr	dir $55
	bclr	dir #$55
	bclr	dir,$55
	bclr	dir,#$55
	
	bclr	ext $55
	bclr	ext #$55
	bclr	ext,$55
	bclr	ext,#$55
	
	brclr	1,+sp $55 *
	brclr	1,+sp #$55 *
	brclr	1,+sp,$55 *
	brclr	1,+sp,#$55 *
	
	brclr	dir $55 *
	brclr	dir #$55 *
	brclr	dir,$55 *
	brclr	dir,#$55 *
	
	brclr	ext $55 *
	brclr	ext #$55 *
	brclr	ext,$55,*
	brclr	ext,#$55,*
	
	brset	1,+sp $55 *
	brset	1,+sp #$55 *
	brset	1,+sp,$55,*
	brset	1,+sp,#$55,*
	
	brset	dir $55 *
	brset	dir #$55 *
	brset	dir,$55,*
	brset	dir,#$55,*
	
	brset	ext $55 *
	brset	ext #$55 *
	brset	ext,$55,*
	brset	ext,#$55,*
	
	bset	1,+sp $55
	bset	1,+sp #$55
	bset	1,+sp,$55
	bset	1,+sp,#$55

	btas	1,+sp $55	;s12x dark blue
	btas	1,+sp #$55	;s12x dark blue
	btas	1,+sp,$55	;s12x dark blue
	btas	1,+sp,#$55	;s12x dark blue

	bset	dir $55
	bset	dir #$55
	bset	dir,$55
	bset	dir,#$55

	btas	dir $55		;s12x dark blue
	btas	dir #$55	;s12x dark blue
	btas	dir,$55		;s12x dark blue
	btas	dir,#$55	;s12x dark blue

	bset	dir $55
	bset	dir #$55
	bset	dir,$55
	bset	dir,#$55

	btas	dir $55		;s12x dark blue
	btas	dir #$55	;s12x dark blue
	btas	dir,$55		;s12x dark blue
	btas	dir,#$55	;s12x dark blue

	bset	ext $55
	bset	ext #$55
	bset	ext,$55
	bset	ext,#$55

	btas	ext $55		;s12x dark blue
	btas	ext #$55	;s12x dark blue
	btas	ext,$55		;s12x dark blue
	btas	ext,#$55	;s12x dark blue

 	movw	ext  2,x 
 	movw	2,x  0,x

	movb	1,sp ext
	movb	1,sp 12,x
	movw	2,sp ext
	movw	2,sp 12,x

	movb  	#immed 1,-sp
	movw	ext 2,-sp
	movb	ext 1,-sp
	movw	#immed 2,-sp
	movw	#immed 2,-sp
	aba
	abx
	aby
	ALIGN   0
	adca	#immed
	adca	#immed
	adca	#immed
	adca	#immed
	adca	#immed
#ifndef dense
	adca	1,+sp
#else
	adca	1,+x
#endif
	adca	1,+y
	LOC 
	adca	8,+sp		; a comma is in , order in the comment
	adca	8,+y
	adca	,pc
	adca	,sp
	adca	,x

	adca	,y
	adca	1,-sp
reset
	adca	1,-x
	adca	1,-y
	adca	8,-sp
reset`
	adca	8,-x
	adca	8,-y
	adca	-1,sp
	adca	-1,x
*
* helwo warry bud
* hewe is you comment
*
	adca	-1,y
	adca	-16,sp
	jsr	reset-*,pc
	jsr	*,pc
	jsr	*
	adca	-16,x
	adca	-16,y
	adca	-17,sp
	ALIGN	1
	adca	-17,x
	adca	-17,y
	ALIGN	3
	adca	-small,pc
	adca	-small,sp
	adca	-small,x
	ALIGN	7
	adca	-small,y
	adca	0,pc
	adca	0,sp
	adca	0,x
	adca	0,y
	adca	1,sp+
	adca	1,x+
	adca	ext,x
	adca	ext,x
	adca	ext,x
	adca	ext,x
	adca	ext,x
	adca	1,y+
	adca	1,sp
	adca	1,x
	adca	1,y
	adca	1,sp-
	adca	1,x-
	adca	1,y-
	adca	125,pc
	adca	125,sp
	adca	125,x
	adca	125,y
	adca	15,sp
	adca	15,x
	adca	15,y
	adca	16,sp
	adca	16,x
	adca	16,y
	adca	8,sp+
	adca	8,x+
	adca	8,y+
	adca	8,sp-
	adca	8,x-
	adca	8,y-
	adca	a,sp
	adca	a,x
	adca	a,y
	adca	b,sp
	adca	b,x
	adca	b,y
	adca	d,sp
	adca	d,x
	adca	d,y
	adca	dir
	adca	dir
	adca	ext
	adca	ext
	adca	ext,sp
	adca	ext,x
	adca	ext,y
	adca	ind,pc
	adca	ind,sp
	adca	ind,x
	adca	ind,y
	adca	small,pc
	adca	small,sp
	adca	small,x
	adca	small,y

	adex	#immed	;s12x yellow
	adex	1,+sp	;s12x yellow
	adex	-small,pc	;s12x yellow
	adex	125,pc	;s12x yellow
	adex	dir	;s12x yellow
	adex	ext	;s12x yellow
	adex	ext,sp	;s12x yellow

	adcb	#immed
	adcb	1,+sp
	adcb	-small,pc
	adcb	125,pc
	adcb	dir
	adcb	ext
	adcb	ext,sp

	adey	#immed	;s12x yellow
	adey	1,+sp	;s12x yellow
	adey	-small,pc	;s12x yellow
	adey	125,pc	;s12x yellow
	adey	dir	;s12x yellow
	adey	ext	;s12x yellow
	adey	ext,sp	;s12x yellow

	adda	#immed
	adda	1,+sp
	adda	dir
	adda	ext
	adda	ext

	addx	#immed	;s12x yellow
	addx	1,+sp	;s12x yellow
	addx	dir	;s12x yellow
	addx	ext	;s12x yellow
	addx	ext	;s12x yellow

	addb	#immed
	addb	1,+sp
	addb	dir
	addb	ext

	addy	#immed	;s12x yellow
	addy	1,+sp	;s12x yellow
	addy	dir	;s12x yellow
	addy	ext	;s12x yellow

	addd	#immed
	addd	1,+sp
	addd	dir
	addd	ext

	aded	#immed	;s12x red
	aded	1,+sp	;s12x red
	aded	dir	;s12x red
	aded	ext	;s12x red

	anda	#immed
	anda	1,+sp
	anda	dir
	anda	ext

	andx	#immed	;s12x yellow
	andx	1,+sp	;s12x yellow
	andx	dir	;s12x yellow
	andx	ext	;s12x yellow

	andb	#immed
	andb	1,+sp
	andb	dir
	andb	ext

	andy	#immed	;s12x yellow
	andy	1,+sp	;s12x yellow
	andy	dir	;s12x yellow
	andy	ext	;s12x yellow

	andcc	#immed
	asl	1,+sp
	asl	dir
	asl	ext

	aslw	1,+sp	;s12x green
	aslw	dir	;s12x green
	aslw	ext	;s12x green

	asla
	aslb
	asld

	aslx		;s12x yellow
	asly		;s12x yellow

	asr	1,+sp
	asr	dir
	asr	ext

	asrw	1,+sp	;s12x green
	asrw	dir	;s12x green
	asrw	ext	;s12x green

	asra
	asrb

	asrx		;s12x yellow
	asry		;s12x yellow

	bcc	*
	bcs	*
	beq	*
	bge	*
	bgt	*
	bhi	*
	bita	#immed
	bita	1,+sp
	bita	dir
	bita	ext

	bitx	#immed	;s12x yellow
	bitx	1,+sp	;s12x yellow
	bitx	dir	;s12x yellow
	bitx	ext	;s12x yellow

	bitb	#immed
	bitb	1,+sp
	bitb	dir
	bitb	ext

	bity	#immed	;s12x yellow
	bity	1,+sp	;s12x yellow
	bity	dir	;s12x yellow
	bity	ext	;s12x yellow

	ble	*
	bls	*
	blt	*
	bmi	*
	bne	*
	bpl	*
	bra	*
	brn	*
	bsr	*
	bvc	*
	bvs	*
	cba
	clc
	cli
	clr	1,+sp
	clr	dir
	clr	ext

	clrw	1,+sp	;s12x green
	clrw	dir	;s12x green
	clrw	ext	;s12x green

	clra
	clrb

	clrx		;s12 yellow
	clry		;s12 yellow

	clv
	cmpa	#immed
	cmpa	1,+sp
	cmpa	dir
	cmpa	ext

	cmpb	#immed
	cmpb	#immed
	cmpb	1,+sp
	cmpb	1,+x
	cmpb	1,+y
	cmpb	8,+sp
	cmpb	8,+x
	cmpb	8,+y
	cmpb	,pc
	cmpb	,sp
	cmpb	,x
	cmpb	,y
	cmpb	1,-sp
	cmpb	1,-x
	cmpb	1,-y
	cmpb	8,-sp
	cmpb	8,-x
	cmpb	8,-y
	cmpb	-1,sp
	cmpb	-1,x
	cmpb	-1,y
	cmpb	-16,sp
	cmpb	-16,x
	cmpb	-16,y
	cmpb	-17,sp
	cmpb	-17,x
	cmpb	-17,y
	cmpb	-small,pc
	cmpb	-small,sp
	cmpb	-small,x
	cmpb	-small,y
	cmpb	0,pc
	cmpb	0,sp
	cmpb	0,x
	cmpb	0,y
	cmpb	1,sp+
	cmpb	1,x+
	cmpb	1,y+
	cmpb	1,sp
	cmpb	1,x
	cmpb	1,y
	cmpb	1,sp-
	cmpb	1,x-
	cmpb	1,y-
	cmpb	125,pc
	cmpb	125,sp
	cmpb	125,x
	cmpb	125,y
	cmpb	15,sp
	cmpb	15,x
	cmpb	15,y
	cmpb	16,sp
	cmpb	16,x
	cmpb	16,y
	cmpb	8,sp+
	cmpb	8,x+
	cmpb	8,y+
	cmpb	8,sp-
	cmpb	8,x-
	cmpb	8,y-
	cmpb	a,sp
	cmpb	a,x
	cmpb	a,y
	cmpb	b,sp
	cmpb	b,x
	cmpb	b,y
	cmpb	d,sp
	cmpb	d,x
	cmpb	d,y
	cmpb	dir
	cmpb	dir
	cmpb	ext
	cmpb	ext
	cmpb	ext,sp
	cmpb	ext,x
	cmpb	ext,y
	cmpb	ind,pc
	cmpb	ind,sp
	cmpb	ind,x
	cmpb	ind,y
	cmpb	small,pc
	cmpb	small,sp
	cmpb	small,x
	cmpb	small,y
	com	1,+sp
	com	1,+x
	com	1,+y
	com	8,+sp
	com	8,+x
	com	8,+y
	com	,pc
	com	,sp
	com	,x
	com	,y
	com	1,-sp
	com	1,-x
	com	1,-y
	com	8,-sp
	com	8,-x
	com	8,-y
	com	-1,sp
	com	-1,x
	com	-1,y
	com	-16,sp
	com	-16,x
	com	-16,y
	com	-17,sp
	com	-17,x
	com	-17,y
	com	-small,pc
	com	-small,sp
	com	-small,x
	com	-small,y
	com	0,pc
	com	0,sp
	com	0,x
	com	0,y
	com	1,sp+
	com	1,x+
	com	1,y+
	com	1,sp
	com	1,x
	com	1,y
	com	1,sp-
	com	1,x-
	com	1,y-
	com	125,pc
	com	125,sp
	com	125,x
	com	125,y
	com	15,sp
	com	15,x
	com	15,y
	com	16,sp
	com	16,x
	com	16,y
	com	8,sp+
	com	8,x+
	com	8,y+
	com	8,sp-
	com	8,x-
	com	8,y-
	com	a,sp
	com	a,x
	com	a,y
	com	b,sp
	com	b,x
	com	b,y
	com	d,sp
	com	d,x
	com	d,y
	com	dir
	com	ext
	com	ext
	com	ext,sp
	com	ext,x
	com	ext,y
	com	ind,pc
	com	ind,sp
	com	ind,x
	com	ind,y
	com	small,pc
	com	small,sp
	com	small,x
	com	small,y

	comw	1,+sp	;s12x green
	comw	1,+x	;s12x green
	comw	1,+y	;s12x green
	comw	8,+sp	;s12x green
	comw	8,+x	;s12x green
	comw	8,+y	;s12x green
	comw	,pc	;s12x green
	comw	,sp	;s12x green
	comw	,x	;s12x green
	comw	,y	;s12x green
	comw	1,-sp	;s12x green
	comw	1,-x	;s12x green
	comw	1,-y	;s12x green
	comw	8,-sp	;s12x green
	comw	8,-x	;s12x green
	comw	8,-y	;s12x green
	comw	-1,sp	;s12x green
	comw	-1,x	;s12x green
	comw	-1,y	;s12x green
	comw	-16,sp	;s12x green
	comw	-16,x	;s12x green
	comw	-16,y	;s12x green
	comw	-17,sp	;s12x green
	comw	-17,x	;s12x green
	comw	-17,y	;s12x green
	comw	-small,pc	;s12x green
	comw	-small,sp	;s12x green
	comw	-small,x	;s12x green
	comw	-small,y	;s12x green
	comw	0,pc	;s12x green
	comw	0,sp	;s12x green
	comw	0,x	;s12x green
	comw	0,y	;s12x green
	comw	1,sp+	;s12x green
	comw	1,x+	;s12x green
	comw	1,y+	;s12x green
	comw	1,sp	;s12x green
	comw	1,x	;s12x green
	comw	1,y	;s12x green
	comw	1,sp-	;s12x green
	comw	1,x-	;s12x green
	comw	1,y-	;s12x green
	comw	125,pc	;s12x green
	comw	125,sp	;s12x green
	comw	125,x	;s12x green
	comw	125,y	;s12x green
	comw	15,sp	;s12x green
	comw	15,x	;s12x green
	comw	15,y	;s12x green
	comw	16,sp	;s12x green
	comw	16,x	;s12x green
	comw	16,y	;s12x green
	comw	8,sp+	;s12x green
	comw	8,x+	;s12x green
	comw	8,y+	;s12x green
	comw	8,sp-	;s12x green
	comw	8,x-	;s12x green
	comw	8,y-	;s12x green
	comw	a,sp	;s12x green
	comw	a,x	;s12x green
	comw	a,y	;s12x green
	comw	b,sp	;s12x green
	comw	b,x	;s12x green
	comw	b,y	;s12x green
	comw	d,sp	;s12x green
	comw	d,x	;s12x green
	comw	d,y	;s12x green
	comw	dir	;s12x green
	comw	ext	;s12x green
	comw	ext	;s12x green
	comw	ext,sp	;s12x green
	comw	ext,x	;s12x green
	comw	ext,y	;s12x green
	comw	ind,pc	;s12x green
	comw	ind,sp	;s12x green
	comw	ind,x	;s12x green
	comw	ind,y	;s12x green
	comw	small,pc	;s12x green
	comw	small,sp	;s12x green
	comw	small,x	;s12x green
	comw	small,y	;s12x green

	coma
	comb

	comx	;s12x yellow
	comy	;s12x yellow

	cpd	#immed
	cpd	1,+sp
	cpd	1,+x
	cpd	1,+y
	cpd	8,+sp
	cpd	8,+x
	cpd	8,+y
	cpd	,pc
	cpd	,sp
	cpd	,x
	cpd	,y
	cpd	1,-sp
	cpd	1,-x
	cpd	1,-y
	cpd	8,-sp
	cpd	8,-x
	cpd	8,-y
	cpd	-1,sp
	cpd	-1,x
	cpd	-1,y
	cpd	-16,sp
	cpd	-16,x
	cpd	-16,y
	cpd	-17,sp
	cpd	-17,x
	cpd	-17,y
	cpd	-small,pc
	cpd	-small,sp
	cpd	-small,x
	cpd	-small,y
	cpd	0,pc
	cpd	0,sp
	cpd	0,x
	cpd	0,y
	cpd	1,sp+
	cpd	1,x+
	cpd	1,y+
	cpd	1,sp
	cpd	1,x
	cpd	1,y
	cpd	1,sp-
	cpd	1,x-
	cpd	1,y-
	cpd	125,pc
	cpd	125,sp
	cpd	125,x
	cpd	125,y
	cpd	15,sp
	cpd	15,x
	cpd	15,y
	cpd	16,sp
	cpd	16,x
	cpd	16,y
	cpd	8,sp+
	cpd	8,x+
	cpd	8,y+
	cpd	8,sp-
	cpd	8,x-
	cpd	8,y-
	cpd	a,sp
	cpd	a,x
	cpd	a,y
	cpd	b,sp
	cpd	b,x
	cpd	b,y
	cpd	d,sp
	cpd	d,x
	cpd	d,y
	cpd	dir
	cpd	dir
	cpd	ext
	cpd	ext
	cpd	ext,sp
	cpd	ext,x
	cpd	ext,y
	cpd	ind,pc
	cpd	ind,sp
	cpd	ind,x
	cpd	ind,y
	cpd	small,pc
	cpd	small,sp
	cpd	small,x
	cpd	small,y
	cps	#immed
	cps	1,+sp
	cps	1,+x
	cps	1,+y
	cps	8,+sp
	cps	8,+x
	cps	8,+y
	cps	,pc
	cps	,sp
	cps	,x
	cps	,y
	cps	1,-sp
	cps	1,-x
	cps	1,-y
	cps	8,-sp
	cps	8,-x
	cps	8,-y
	cps	-1,sp
	cps	-1,x
	cps	-1,y
	cps	-16,sp
	cps	-16,x
	cps	-16,y
	cps	-17,sp
	cps	-17,x
	cps	-17,y
	cps	-small,pc
	cps	-small,sp
	cps	-small,x
	cps	-small,y
	cps	0,pc
	cps	0,sp
	cps	0,x
	cps	0,y
	cps	1,sp+
	cps	1,x+
	cps	1,y+
	cps	1,sp
	cps	1,x
	cps	1,y
	cps	1,sp-
	cps	1,x-
	cps	1,y-
	cps	125,pc
	cps	125,sp
	cps	125,x
	cps	125,y
	cps	15,sp
	cps	15,x
	cps	15,y
	cps	16,sp
	cps	16,x
	cps	16,y
	cps	8,sp+
	cps	8,x+
	cps	8,y+
	cps	8,sp-
	cps	8,x-
	cps	8,y-
	cps	a,sp
	cps	a,x
	cps	a,y
	cps	b,sp
	cps	b,x
	cps	b,y
	cps	d,sp
	cps	d,x
	cps	d,y
	cps	dir
	cps	dir
	cps	ext
	cps	ext
	cps	ext,sp
	cps	ext,x
	cps	ext,y
	cps	ind,pc
	cps	ind,sp
	cps	ind,x
	cps	ind,y
	cps	small,pc
	cps	small,sp
	cps	small,x
	cps	small,y
	cpx	#immed
	cpx	#immed
	cpx	1,+sp
	cpx	1,+x
	cpx	1,+y
	cpx	8,+sp
	cpx	8,+x
	cpx	8,+y
	cpx	,pc
	cpx	,sp
	cpx	,x
	cpx	,y
	cpx	1,-sp
	cpx	1,-x
	cpx	1,-y
	cpx	8,-sp
	cpx	8,-x
	cpx	8,-y
	cpx	-1,sp
	cpx	-1,x
	cpx	-1,y
	cpx	-16,sp
	cpx	-16,x
	cpx	-16,y
	cpx	-17,sp
	cpx	-17,x
	cpx	-17,y
	cpx	-small,pc
	cpx	-small,sp
	cpx	-small,x
	cpx	-small,y
	cpx	0,pc
	cpx	0,sp
	cpx	0,x
	cpx	0,y
	cpx	1,sp+
	cpx	1,x+
	cpx	1,y+
	cpx	1,sp
	cpx	1,x
	cpx	1,y
	cpx	1,sp-
	cpx	1,x-
	cpx	1,y-
	cpx	125,pc
	cpx	125,sp
	cpx	125,x
	cpx	125,y
	cpx	15,sp
	cpx	15,x
	cpx	15,y
	cpx	16,sp
	cpx	16,x
	cpx	16,y
	cpx	8,sp+
	cpx	8,x+
	cpx	8,y+
	cpx	8,sp-
	cpx	8,x-
	cpx	8,y-
	cpx	a,sp
	cpx	a,x
	cpx	a,y
	cpx	b,sp
	cpx	b,x
	cpx	b,y
	cpx	d,sp
	cpx	d,x
	cpx	d,y
	cpx	dir
	cpx	dir
	cpx	ext
	cpx	ext
	cpx	ext,sp
	cpx	ext,x
	cpx	ext,y
	cpx	ind,pc
	cpx	ind,sp
	cpx	ind,x
	cpx	ind,y
	cpx	small,pc
	cpx	small,sp
	cpx	small,x
	cpx	small,y
	cpy	#immed
	cpy	#immed
	cpy	1,+sp
	cpy	1,+x
	cpy	1,+y
	cpy	8,+sp
	cpy	8,+x
	cpy	8,+y
	cpy	,pc
	cpy	,sp
	cpy	,x
	cpy	,y
	cpy	1,-sp
	cpy	1,-x
	cpy	1,-y
	cpy	8,-sp
	cpy	8,-x
	cpy	8,-y
	cpy	-1,sp
	cpy	-1,x
	cpy	-1,y
	cpy	-16,sp
	cpy	-16,x
	cpy	-16,y
	cpy	-17,sp
	cpy	-17,x
	cpy	-17,y
	cpy	-small,pc
	cpy	-small,sp
	cpy	-small,x
	cpy	-small,y
	cpy	0,pc
	cpy	0,sp
	cpy	0,x
	cpy	0,y
	cpy	1,sp+
	cpy	1,x+
	cpy	1,y+
	cpy	1,sp
	cpy	1,x
	cpy	1,y
	cpy	1,sp-
	cpy	1,x-
	cpy	1,y-
	cpy	125,pc
	cpy	125,sp
	cpy	125,x
	cpy	125,y
	cpy	15,sp
	cpy	15,x
	cpy	15,y
	cpy	16,sp
	cpy	16,x
	cpy	16,y
	cpy	8,sp+
	cpy	8,x+
	cpy	8,y+
	cpy	8,sp-
	cpy	8,x-
	cpy	8,y-
	cpy	a,sp
	cpy	a,x
	cpy	a,y
	cpy	b,sp
	cpy	b,x
	cpy	b,y
	cpy	d,sp
	cpy	d,x
	cpy	d,y
	cpy	dir
	cpy	dir
	cpy	ext
	cpy	ext
	cpy	ext,sp
	cpy	ext,x
	cpy	ext,y
	cpy	ind,pc
	cpy	ind,sp
	cpy	ind,x
	cpy	ind,y
	cpy	small,pc
	cpy	small,sp
	cpy	small,x
	cpy	small,y

	cped	#immed	;s12x magenta
	cped	1,+sp	;s12x magenta
	cped	1,+x	;s12x magenta
	cped	1,+y	;s12x magenta
	cped	8,+sp	;s12x magenta
	cped	8,+x	;s12x magenta
	cped	8,+y	;s12x magenta
	cped	,pc	;s12x magenta
	cped	,sp	;s12x magenta
	cped	,x	;s12x magenta
	cped	,y	;s12x magenta
	cped	1,-sp	;s12x magenta
	cped	1,-x	;s12x magenta
	cped	1,-y	;s12x magenta
	cped	8,-sp	;s12x magenta
	cped	8,-x	;s12x magenta
	cped	8,-y	;s12x magenta
	cped	-1,sp	;s12x magenta
	cped	-1,x	;s12x magenta
	cped	-1,y	;s12x magenta
	cped	-16,sp	;s12x magenta
	cped	-16,x	;s12x magenta
	cped	-16,y	;s12x magenta
	cped	-17,sp	;s12x magenta
	cped	-17,x	;s12x magenta
	cped	-17,y	;s12x magenta
	cped	-small,pc	;s12x magenta
	cped	-small,sp	;s12x magenta
	cped	-small,x	;s12x magenta
	cped	-small,y	;s12x magenta
	cped	0,pc	;s12x magenta
	cped	0,sp	;s12x magenta
	cped	0,x	;s12x magenta
	cped	0,y	;s12x magenta
	cped	1,sp+	;s12x magenta
	cped	1,x+	;s12x magenta
	cped	1,y+	;s12x magenta
	cped	1,sp	;s12x magenta
	cped	1,x	;s12x magenta
	cped	1,y	;s12x magenta
	cped	1,sp-	;s12x magenta
	cped	1,x-	;s12x magenta
	cped	1,y-	;s12x magenta
	cped	125,pc	;s12x magenta
	cped	125,sp	;s12x magenta
	cped	125,x	;s12x magenta
	cped	125,y	;s12x magenta
	cped	15,sp	;s12x magenta
	cped	15,x	;s12x magenta
	cped	15,y	;s12x magenta
	cped	16,sp	;s12x magenta
	cped	16,x	;s12x magenta
	cped	16,y	;s12x magenta
	cped	8,sp+	;s12x magenta
	cped	8,x+	;s12x magenta
	cped	8,y+	;s12x magenta
	cped	8,sp-	;s12x magenta
	cped	8,x-	;s12x magenta
	cped	8,y-	;s12x magenta
	cped	a,sp	;s12x magenta
	cped	a,x	;s12x magenta
	cped	a,y	;s12x magenta
	cped	b,sp	;s12x magenta
	cped	b,x	;s12x magenta
	cped	b,y	;s12x magenta
	cped	d,sp	;s12x magenta
	cped	d,x	;s12x magenta
	cped	d,y	;s12x magenta
	cped	dir	;s12x magenta
	cped	dir	;s12x magenta
	cped	ext	;s12x magenta
	cped	ext	;s12x magenta
	cped	ext,sp	;s12x magenta
	cped	ext,x	;s12x magenta
	cped	ext,y	;s12x magenta
	cped	ind,pc	;s12x magenta
	cped	ind,sp	;s12x magenta
	cped	ind,x	;s12x magenta
	cped	ind,y	;s12x magenta
	cped	small,pc	;s12x magenta
	cped	small,sp	;s12x magenta
	cped	small,x	;s12x magenta
	cped	small,y	;s12x magenta
	cpes	#immed	;s12x magenta
	cpes	1,+sp	;s12x magenta
	cpes	1,+x	;s12x magenta
	cpes	1,+y	;s12x magenta
	cpes	8,+sp	;s12x magenta
	cpes	8,+x	;s12x magenta
	cpes	8,+y	;s12x magenta
	cpes	,pc	;s12x magenta
	cpes	,sp	;s12x magenta
	cpes	,x	;s12x magenta
	cpes	,y	;s12x magenta
	cpes	1,-sp	;s12x magenta
	cpes	1,-x	;s12x magenta
	cpes	1,-y	;s12x magenta
	cpes	8,-sp	;s12x magenta
	cpes	8,-x	;s12x magenta
	cpes	8,-y	;s12x magenta
	cpes	-1,sp	;s12x magenta
	cpes	-1,x	;s12x magenta
	cpes	-1,y	;s12x magenta
	cpes	-16,sp	;s12x magenta
	cpes	-16,x	;s12x magenta
	cpes	-16,y	;s12x magenta
	cpes	-17,sp	;s12x magenta
	cpes	-17,x	;s12x magenta
	cpes	-17,y	;s12x magenta
	cpes	-small,pc	;s12x magenta
	cpes	-small,sp	;s12x magenta
	cpes	-small,x	;s12x magenta
	cpes	-small,y	;s12x magenta
	cpes	0,pc	;s12x magenta
	cpes	0,sp	;s12x magenta
	cpes	0,x	;s12x magenta
	cpes	0,y	;s12x magenta
	cpes	1,sp+	;s12x magenta
	cpes	1,x+	;s12x magenta
	cpes	1,y+	;s12x magenta
	cpes	1,sp	;s12x magenta
	cpes	1,x	;s12x magenta
	cpes	1,y	;s12x magenta
	cpes	1,sp-	;s12x magenta
	cpes	1,x-	;s12x magenta
	cpes	1,y-	;s12x magenta
	cpes	125,pc	;s12x magenta
	cpes	125,sp	;s12x magenta
	cpes	125,x	;s12x magenta
	cpes	125,y	;s12x magenta
	cpes	15,sp	;s12x magenta
	cpes	15,x	;s12x magenta
	cpes	15,y	;s12x magenta
	cpes	16,sp	;s12x magenta
	cpes	16,x	;s12x magenta
	cpes	16,y	;s12x magenta
	cpes	8,sp+	;s12x magenta
	cpes	8,x+	;s12x magenta
	cpes	8,y+	;s12x magenta
	cpes	8,sp-	;s12x magenta
	cpes	8,x-	;s12x magenta
	cpes	8,y-	;s12x magenta
	cpes	a,sp	;s12x magenta
	cpes	a,x	;s12x magenta
	cpes	a,y	;s12x magenta
	cpes	b,sp	;s12x magenta
	cpes	b,x	;s12x magenta
	cpes	b,y	;s12x magenta
	cpes	d,sp	;s12x magenta
	cpes	d,x	;s12x magenta
	cpes	d,y	;s12x magenta
	cpes	dir	;s12x magenta
	cpes	dir	;s12x magenta
	cpes	ext	;s12x magenta
	cpes	ext	;s12x magenta
	cpes	ext,sp	;s12x magenta
	cpes	ext,x	;s12x magenta
	cpes	ext,y	;s12x magenta
	cpes	ind,pc	;s12x magenta
	cpes	ind,sp	;s12x magenta
	cpes	ind,x	;s12x magenta
	cpes	ind,y	;s12x magenta
	cpes	small,pc	;s12x magenta
	cpes	small,sp	;s12x magenta
	cpes	small,x	;s12x magenta
	cpes	small,y	;s12x magenta
	cpex	#immed	;s12x magenta
	cpex	#immed	;s12x magenta
	cpex	1,+sp	;s12x magenta
	cpex	1,+x	;s12x magenta
	cpex	1,+y	;s12x magenta
	cpex	8,+sp	;s12x magenta
	cpex	8,+x	;s12x magenta
	cpex	8,+y	;s12x magenta
	cpex	,pc	;s12x magenta
	cpex	,sp	;s12x magenta
	cpex	,x	;s12x magenta
	cpex	,y	;s12x magenta
	cpex	1,-sp	;s12x magenta
	cpex	1,-x	;s12x magenta
	cpex	1,-y	;s12x magenta
	cpex	8,-sp	;s12x magenta
	cpex	8,-x	;s12x magenta
	cpex	8,-y	;s12x magenta
	cpex	-1,sp	;s12x magenta
	cpex	-1,x	;s12x magenta
	cpex	-1,y	;s12x magenta
	cpex	-16,sp	;s12x magenta
	cpex	-16,x	;s12x magenta
	cpex	-16,y	;s12x magenta
	cpex	-17,sp	;s12x magenta
	cpex	-17,x	;s12x magenta
	cpex	-17,y	;s12x magenta
	cpex	-small,pc	;s12x magenta
	cpex	-small,sp	;s12x magenta
	cpex	-small,x	;s12x magenta
	cpex	-small,y	;s12x magenta
	cpex	0,pc	;s12x magenta
	cpex	0,sp	;s12x magenta
	cpex	0,x	;s12x magenta
	cpex	0,y	;s12x magenta
	cpex	1,sp+	;s12x magenta
	cpex	1,x+	;s12x magenta
	cpex	1,y+	;s12x magenta
	cpex	1,sp	;s12x magenta
	cpex	1,x	;s12x magenta
	cpex	1,y	;s12x magenta
	cpex	1,sp-	;s12x magenta
	cpex	1,x-	;s12x magenta
	cpex	1,y-	;s12x magenta
	cpex	125,pc	;s12x magenta
	cpex	125,sp	;s12x magenta
	cpex	125,x	;s12x magenta
	cpex	125,y	;s12x magenta
	cpex	15,sp	;s12x magenta
	cpex	15,x	;s12x magenta
	cpex	15,y	;s12x magenta
	cpex	16,sp	;s12x magenta
	cpex	16,x	;s12x magenta
	cpex	16,y	;s12x magenta
	cpex	8,sp+	;s12x magenta
	cpex	8,x+	;s12x magenta
	cpex	8,y+	;s12x magenta
	cpex	8,sp-	;s12x magenta
	cpex	8,x-	;s12x magenta
	cpex	8,y-	;s12x magenta
	cpex	a,sp	;s12x magenta
	cpex	a,x	;s12x magenta
	cpex	a,y	;s12x magenta
	cpex	b,sp	;s12x magenta
	cpex	b,x	;s12x magenta
	cpex	b,y	;s12x magenta
	cpex	d,sp	;s12x magenta
	cpex	d,x	;s12x magenta
	cpex	d,y	;s12x magenta
	cpex	dir	;s12x magenta
	cpex	dir	;s12x magenta
	cpex	ext	;s12x magenta
	cpex	ext	;s12x magenta
	cpex	ext,sp	;s12x magenta
	cpex	ext,x	;s12x magenta
	cpex	ext,y	;s12x magenta
	cpex	ind,pc	;s12x magenta
	cpex	ind,sp	;s12x magenta
	cpex	ind,x	;s12x magenta
	cpex	ind,y	;s12x magenta
	cpex	small,pc	;s12x magenta
	cpex	small,sp	;s12x magenta
	cpex	small,x	;s12x magenta
	cpex	small,y	;s12x magenta
	cpey	#immed	;s12x magenta
	cpey	#immed	;s12x magenta
	cpey	1,+sp	;s12x magenta
	cpey	1,+x	;s12x magenta
	cpey	1,+y	;s12x magenta
	cpey	8,+sp	;s12x magenta
	cpey	8,+x	;s12x magenta
	cpey	8,+y	;s12x magenta
	cpey	,pc	;s12x magenta
	cpey	,sp	;s12x magenta
	cpey	,x	;s12x magenta
	cpey	,y	;s12x magenta
	cpey	1,-sp	;s12x magenta
	cpey	1,-x	;s12x magenta
	cpey	1,-y	;s12x magenta
	cpey	8,-sp	;s12x magenta
	cpey	8,-x	;s12x magenta
	cpey	8,-y	;s12x magenta
	cpey	-1,sp	;s12x magenta
	cpey	-1,x	;s12x magenta
	cpey	-1,y	;s12x magenta
	cpey	-16,sp	;s12x magenta
	cpey	-16,x	;s12x magenta
	cpey	-16,y	;s12x magenta
	cpey	-17,sp	;s12x magenta
	cpey	-17,x	;s12x magenta
	cpey	-17,y	;s12x magenta
	cpey	-small,pc	;s12x magenta
	cpey	-small,sp	;s12x magenta
	cpey	-small,x	;s12x magenta
	cpey	-small,y	;s12x magenta
	cpey	0,pc	;s12x magenta
	cpey	0,sp	;s12x magenta
	cpey	0,x	;s12x magenta
	cpey	0,y	;s12x magenta
	cpey	1,sp+	;s12x magenta
	cpey	1,x+	;s12x magenta
	cpey	1,y+	;s12x magenta
	cpey	1,sp	;s12x magenta
	cpey	1,x	;s12x magenta
	cpey	1,y	;s12x magenta
	cpey	1,sp-	;s12x magenta
	cpey	1,x-	;s12x magenta
	cpey	1,y-	;s12x magenta
	cpey	125,pc	;s12x magenta
	cpey	125,sp	;s12x magenta
	cpey	125,x	;s12x magenta
	cpey	125,y	;s12x magenta
	cpey	15,sp	;s12x magenta
	cpey	15,x	;s12x magenta
	cpey	15,y	;s12x magenta
	cpey	16,sp	;s12x magenta
	cpey	16,x	;s12x magenta
	cpey	16,y	;s12x magenta
	cpey	8,sp+	;s12x magenta
	cpey	8,x+	;s12x magenta
	cpey	8,y+	;s12x magenta
	cpey	8,sp-	;s12x magenta
	cpey	8,x-	;s12x magenta
	cpey	8,y-	;s12x magenta
	cpey	a,sp	;s12x magenta
	cpey	a,x	;s12x magenta
	cpey	a,y	;s12x magenta
	cpey	b,sp	;s12x magenta
	cpey	b,x	;s12x magenta
	cpey	b,y	;s12x magenta
	cpey	d,sp	;s12x magenta
	cpey	d,x	;s12x magenta
	cpey	d,y	;s12x magenta
	cpey	dir	;s12x magenta
	cpey	dir	;s12x magenta
	cpey	ext	;s12x magenta
	cpey	ext	;s12x magenta
	cpey	ext,sp	;s12x magenta
	cpey	ext,x	;s12x magenta
	cpey	ext,y	;s12x magenta
	cpey	ind,pc	;s12x magenta
	cpey	ind,sp	;s12x magenta
	cpey	ind,x	;s12x magenta
	cpey	ind,y	;s12x magenta
	cpey	small,pc	;s12x magenta
	cpey	small,sp	;s12x magenta
	cpey	small,x	;s12x magenta
	cpey	small,y	;s12x magenta

	daa
	dbne	a *
	dbne	b *
	dbne	x *
	dbne	y *

	decw	1,+sp	;s12x green
	decw	1,+x	;s12x green
	decw	1,+y	;s12x green
	decw	8,+sp	;s12x green
	decw	8,+x	;s12x green
	decw	8,+y	;s12x green
	decw	,pc	;s12x green
	decw	,sp	;s12x green
	decw	,x	;s12x green
	decw	,y	;s12x green
	decw	1,-sp	;s12x green
	decw	1,-x	;s12x green
	decw	1,-y	;s12x green
	decw	8,-sp	;s12x green
	decw	8,-x	;s12x green
	decw	8,-y	;s12x green
	decw	-1,sp	;s12x green
	decw	-1,x	;s12x green
	decw	-1,y	;s12x green
	decw	-16,sp	;s12x green
	decw	-16,x	;s12x green
	decw	-16,y	;s12x green
	decw	-17,sp	;s12x green
	decw	-17,x	;s12x green
	decw	-17,y	;s12x green
	decw	-small,pc	;s12x green
	decw	-small,sp	;s12x green
	decw	-small,x	;s12x green
	decw	-small,y	;s12x green
	decw	0,pc	;s12x green
	decw	0,sp	;s12x green
	decw	0,x	;s12x green
	decw	0,y	;s12x green
	decw	1,sp+	;s12x green
	decw	1,x+	;s12x green
	decw	1,y+	;s12x green
	decw	1,sp	;s12x green
	decw	1,x	;s12x green
	decw	1,y	;s12x green
	decw	1,sp-	;s12x green
	decw	1,x-	;s12x green
	decw	1,y-	;s12x green
	decw	125,pc	;s12x green
	decw	125,sp	;s12x green
	decw	125,x	;s12x green
	decw	125,y	;s12x green
	decw	15,sp	;s12x green
	decw	15,x	;s12x green
	decw	15,y	;s12x green
	decw	16,sp	;s12x green
	decw	16,x	;s12x green
	decw	16,y	;s12x green
	decw	8,sp+	;s12x green
	decw	8,x+	;s12x green
	decw	8,y+	;s12x green
	decw	8,sp-	;s12x green
	decw	8,x-	;s12x green
	decw	8,y-	;s12x green
	decw	a,sp	;s12x green
	decw	a,x	;s12x green
	decw	a,y	;s12x green
	decw	b,sp	;s12x green
	decw	b,x	;s12x green
	decw	b,y	;s12x green
	decw	d,sp	;s12x green
	decw	d,x	;s12x green
	decw	d,y	;s12x green
	decw	dir	;s12x green
	decw	ext	;s12x green
	decw	ext	;s12x green
	decw	ext,sp	;s12x green
	decw	ext,x	;s12x green
	decw	ext,y	;s12x green
	decw	ind,pc	;s12x green
	decw	ind,sp	;s12x green
	decw	ind,x	;s12x green
	decw	ind,y	;s12x green
	decw	small,pc	;s12x green
	decw	small,sp	;s12x green
	decw	small,x	;s12x green
	decw	small,y	;s12x green

	deca
	decb

	decx	;s12x yellow
	decy	;s12x yellow

	des
	dex
	dey
	ediv
	edivs
	emacs	dir
	emacs	ext
	emacs	small
	emaxd	1,+sp
	emaxd	1,+x
	emaxd	1,+y
	emaxd	8,+sp
	emaxd	8,+x
	emaxd	8,+y
	emaxd	,pc
	emaxd	,sp
	emaxd	,x
	emaxd	,y
	emaxd	1,-sp
	emaxd	1,-x
	emaxd	1,-y
	emaxd	8,-sp
	emaxd	8,-x
	emaxd	8,-y
	emaxd	-1,sp
	emaxd	-1,x
	emaxd	-1,y
	emaxd	-16,sp
	emaxd	-16,x
	emaxd	-16,y
	emaxd	-17,sp
	emaxd	-17,x
	emaxd	-17,y
	emaxd	-small,pc
	emaxd	-small,sp
	emaxd	-small,x
	emaxd	-small,y
	emaxd	0,pc
	emaxd	0,sp
	emaxd	0,x
	emaxd	0,y
	emaxd	1,sp+
	emaxd	1,x+
	emaxd	1,y+
	emaxd	1,sp
	emaxd	1,x
	emaxd	1,y
	emaxd	1,sp-
	emaxd	1,x-
	emaxd	1,y-
	emaxd	125,pc
	emaxd	125,sp
	emaxd	125,x
	emaxd	125,y
	emaxd	15,sp
	emaxd	15,x
	emaxd	15,y
	emaxd	16,sp
	emaxd	16,x
	emaxd	16,y
	emaxd	8,sp+
	emaxd	8,x+
	emaxd	8,y+
	emaxd	8,sp-
	emaxd	8,x-
	emaxd	8,y-
	emaxd	a,sp
	emaxd	a,x
	emaxd	a,y
	emaxd	b,sp
	emaxd	b,x
	emaxd	b,y
	emaxd	d,sp
	emaxd	d,x
	emaxd	d,y
	emaxd	ext,sp
	emaxd	ext,x
	emaxd	ext,y
	emaxd	ind,pc
	emaxd	ind,sp
	emaxd	ind,x
	emaxd	ind,y
	emaxd	small,pc
	emaxd	small,sp
	emaxd	small,x
	emaxd	small,y
	emaxm	1,+sp
	emaxm	1,+x
	emaxm	1,+y
	emaxm	8,+sp
	emaxm	8,+x
	emaxm	8,+y
	emaxm	,pc
	emaxm	,sp
	emaxm	,x
	emaxm	,y
	emaxm	1,-sp
	emaxm	1,-x
	emaxm	1,-y
	emaxm	8,-sp
	emaxm	8,-x
	emaxm	8,-y
	emaxm	-1,sp
	emaxm	-1,x
	emaxm	-1,y
	emaxm	-16,sp
	emaxm	-16,x
	emaxm	-16,y
	emaxm	-17,sp
	emaxm	-17,x
	emaxm	-17,y
	emaxm	-small,pc
	emaxm	-small,sp
	emaxm	-small,x
	emaxm	-small,y
	emaxm	0,pc
	emaxm	0,sp
	emaxm	0,x
	emaxm	0,y
	emaxm	1,sp+
	emaxm	1,x+
	emaxm	1,y+
	emaxm	1,sp
	emaxm	1,x
	emaxm	1,y
	emaxm	1,sp-
	emaxm	1,x-
	emaxm	1,y-
	emaxm	125,pc
	emaxm	125,sp
	emaxm	125,x
	emaxm	125,y
	emaxm	15,sp
	emaxm	15,x
	emaxm	15,y
	emaxm	16,sp
	emaxm	16,x
	emaxm	16,y
	emaxm	8,sp+
	emaxm	8,x+
	emaxm	8,y+
	emaxm	8,sp-
	emaxm	8,x-
	emaxm	8,y-
	emaxm	a,sp
	emaxm	a,x
	emaxm	a,y
	emaxm	b,sp
	emaxm	b,x
	emaxm	b,y
	emaxm	d,sp
	emaxm	d,x
	emaxm	d,y
	emaxm	ext,sp
	emaxm	ext,x
	emaxm	ext,y
	emaxm	ind,pc
	emaxm	ind,sp
	emaxm	ind,x
	emaxm	ind,y
	emaxm	small,pc
	emaxm	small,sp
	emaxm	small,x
	emaxm	small,y
	emind	1,+sp
	emind	1,+x
	emind	1,+y
	emind	8,+sp
	emind	8,+x
	emind	8,+y
	emind	,pc
	emind	,sp
	emind	,x
	emind	,y
	emind	1,-sp
	emind	1,-x
	emind	1,-y
	emind	8,-sp
	emind	8,-x
	emind	8,-y
	emind	-1,sp
	emind	-1,x
	emind	-1,y
	emind	-16,sp
	emind	-16,x
	emind	-16,y
	emind	-17,sp
	emind	-17,x
	emind	-17,y
	emind	-small,pc
	emind	-small,sp
	emind	-small,x
	emind	-small,y
	emind	0,pc
	emind	0,sp
	emind	0,x
	emind	0,y
	emind	1,sp+
	emind	1,x+
	emind	1,y+
	emind	1,sp
	emind	1,x
	emind	1,y
	emind	1,sp-
	emind	1,x-
	emind	1,y-
	emind	125,pc
	emind	125,sp
	emind	125,x
	emind	125,y
	emind	15,sp
	emind	15,x
	emind	15,y
	emind	16,sp
	emind	16,x
	emind	16,y
	emind	8,sp+
	emind	8,x+
	emind	8,y+
	emind	8,sp-
	emind	8,x-
	emind	8,y-
	emind	a,sp
	emind	a,x
	emind	a,y
	emind	b,sp
	emind	b,x
	emind	b,y
	emind	d,sp
	emind	d,x
	emind	d,y
	emind	ext,sp
	emind	ext,x
	emind	ext,y
	emind	ind,pc
	emind	ind,sp
	emind	ind,x
	emind	ind,y
	emind	small,pc
	emind	small,sp
	emind	small,x
	emind	small,y
	eminm	1,+sp
	eminm	1,+x
	eminm	1,+y
	eminm	8,+sp
	eminm	8,+x
	eminm	8,+y
	eminm	,pc
	eminm	,sp
	eminm	,x
	eminm	,y
	eminm	1,-sp
	eminm	1,-x
	eminm	1,-y
	eminm	8,-sp
	eminm	8,-x
	eminm	8,-y
	eminm	-1,sp
	eminm	-1,x
	eminm	-1,y
	eminm	-16,sp
	eminm	-16,x
	eminm	-16,y
	eminm	-17,sp
	eminm	-17,x
	eminm	-17,y
	eminm	-small,pc
	eminm	-small,sp
	eminm	-small,x
	eminm	-small,y
	eminm	0,pc
	eminm	0,sp
	eminm	0,x
	eminm	0,y
	eminm	1,sp+
	eminm	1,x+
	eminm	1,y+
	eminm	1,sp
	eminm	1,x
	eminm	1,y
	eminm	1,sp-
	eminm	1,x-
	eminm	1,y-
	eminm	125,pc
	eminm	125,sp
	eminm	125,x
	eminm	125,y
	eminm	15,sp
	eminm	15,x
	eminm	15,y
	eminm	16,sp
	eminm	16,x
	eminm	16,y
	eminm	8,sp+
	eminm	8,x+
	eminm	8,y+
	eminm	8,sp-
	eminm	8,x-
	eminm	8,y-
	eminm	a,sp
	eminm	a,x
	eminm	a,y
	eminm	b,sp
	eminm	b,x
	eminm	b,y
	eminm	d,sp
	eminm	d,x
	eminm	d,y
	eminm	ext,sp
	eminm	ext,x
	eminm	ext,y
	eminm	ind,pc
	eminm	ind,sp
	eminm	ind,x
	eminm	ind,y
	eminm	small,pc
	eminm	small,sp
	eminm	small,x
	eminm	small,y
	eora	#immed
	eora	#immed
	eora	1,+sp
	eora	1,+x
	eora	1,+y
	eora	8,+sp
	eora	8,+x
	eora	8,+y
	eora	,pc
	eora	,sp
	eora	,x
	eora	,y
	eora	1,-sp
	eora	1,-x
	eora	1,-y
	eora	8,-sp
	eora	8,-x
	eora	8,-y
	eora	-1,sp
	eora	-1,x
	eora	-1,y
	eora	-16,sp
	eora	-16,x
	eora	-16,y
	eora	-17,sp
	eora	-17,x
	eora	-17,y
	eora	-small,pc
	eora	-small,sp
	eora	-small,x
	eora	-small,y
	eora	0,pc
	eora	0,sp
	eora	0,x
	eora	0,y
	eora	1,sp+
	eora	1,x+
	eora	1,y+
	eora	1,sp
	eora	1,x
	eora	1,y
	eora	1,sp-
	eora	1,x-
	eora	1,y-
	eora	125,pc
	eora	125,sp
	eora	125,x
	eora	125,y
	eora	15,sp
	eora	15,x
	eora	15,y
	eora	16,sp
	eora	16,x
	eora	16,y
	eora	8,sp+
	eora	8,x+
	eora	8,y+
	eora	8,sp-
	eora	8,x-
	eora	8,y-
	eora	a,sp
	eora	a,x
	eora	a,y
	eora	b,sp
	eora	b,x
	eora	b,y
	eora	d,sp
	eora	d,x
	eora	d,y
	eora	dir
	eora	dir
	eora	ext
	eora	ext
	eora	ext,sp
	eora	ext,x
	eora	ext,y
	eora	ind,pc
	eora	ind,sp
	eora	ind,x
	eora	ind,y
	eora	small,pc
	eora	small,sp
	eora	small,x
	eora	small,y

	eorx	#immed	;s12 yellow
	eorx	#immed	;s12 yellow
	eorx	1,+sp	;s12 yellow
	eorx	1,+x	;s12 yellow
	eorx	1,+y	;s12 yellow
	eorx	8,+sp	;s12 yellow
	eorx	8,+x	;s12 yellow
	eorx	8,+y	;s12 yellow
	eorx	,pc	;s12 yellow
	eorx	,sp	;s12 yellow
	eorx	,x	;s12 yellow
	eorx	,y	;s12 yellow
	eorx	1,-sp	;s12 yellow
	eorx	1,-x	;s12 yellow
	eorx	1,-y	;s12 yellow
	eorx	8,-sp	;s12 yellow
	eorx	8,-x	;s12 yellow
	eorx	8,-y	;s12 yellow
	eorx	-1,sp	;s12 yellow
	eorx	-1,x	;s12 yellow
	eorx	-1,y	;s12 yellow
	eorx	-16,sp	;s12 yellow
	eorx	-16,x	;s12 yellow
	eorx	-16,y	;s12 yellow
	eorx	-17,sp	;s12 yellow
	eorx	-17,x	;s12 yellow
	eorx	-17,y	;s12 yellow
	eorx	-small,pc	;s12 yellow
	eorx	-small,sp	;s12 yellow
	eorx	-small,x	;s12 yellow
	eorx	-small,y	;s12 yellow
	eorx	0,pc	;s12 yellow
	eorx	0,sp	;s12 yellow
	eorx	0,x	;s12 yellow
	eorx	0,y	;s12 yellow
	eorx	1,sp+	;s12 yellow
	eorx	1,x+	;s12 yellow
	eorx	1,y+	;s12 yellow
	eorx	1,sp	;s12 yellow
	eorx	1,x	;s12 yellow
	eorx	1,y	;s12 yellow
	eorx	1,sp-	;s12 yellow
	eorx	1,x-	;s12 yellow
	eorx	1,y-	;s12 yellow
	eorx	125,pc	;s12 yellow
	eorx	125,sp	;s12 yellow
	eorx	125,x	;s12 yellow
	eorx	125,y	;s12 yellow
	eorx	15,sp	;s12 yellow
	eorx	15,x	;s12 yellow
	eorx	15,y	;s12 yellow
	eorx	16,sp	;s12 yellow
	eorx	16,x	;s12 yellow
	eorx	16,y	;s12 yellow
	eorx	8,sp+	;s12 yellow
	eorx	8,x+	;s12 yellow
	eorx	8,y+	;s12 yellow
	eorx	8,sp-	;s12 yellow
	eorx	8,x-	;s12 yellow
	eorx	8,y-	;s12 yellow
	eorx	a,sp	;s12 yellow
	eorx	a,x	;s12 yellow
	eorx	a,y	;s12 yellow
	eorx	b,sp	;s12 yellow
	eorx	b,x	;s12 yellow
	eorx	b,y	;s12 yellow
	eorx	d,sp	;s12 yellow
	eorx	d,x	;s12 yellow
	eorx	d,y	;s12 yellow
	eorx	dir	;s12 yellow
	eorx	dir	;s12 yellow
	eorx	ext	;s12 yellow
	eorx	ext	;s12 yellow
	eorx	ext,sp	;s12 yellow
	eorx	ext,x	;s12 yellow
	eorx	ext,y	;s12 yellow
	eorx	ind,pc	;s12 yellow
	eorx	ind,sp	;s12 yellow
	eorx	ind,x	;s12 yellow
	eorx	ind,y	;s12 yellow
	eorx	small,pc	;s12 yellow
	eorx	small,sp	;s12 yellow
	eorx	small,x	;s12 yellow
	eorx	small,y	;s12 yellow

	eorb	#immed
	eorb	1,+sp
	eorb	1,+x
	eorb	1,+y
	eorb	8,+sp
	eorb	8,+x
	eorb	8,+y
	eorb	,pc
	eorb	,sp
	eorb	,x
	eorb	,y
	eorb	1,-sp
	eorb	1,-x
	eorb	1,-y
	eorb	8,-sp
	eorb	8,-x
	eorb	8,-y
	eorb	-1,sp
	eorb	-1,x
	eorb	-1,y
	eorb	-16,sp
	eorb	-16,x
	eorb	-16,y
	eorb	-17,sp
	eorb	-17,x
	eorb	-17,y
	eorb	-small,pc
	eorb	-small,sp
	eorb	-small,x
	eorb	-small,y
	eorb	0,pc
	eorb	0,sp
	eorb	0,x
	eorb	0,y
	eorb	1,sp+
	eorb	1,x+
	eorb	1,y+
	eorb	1,sp
	eorb	1,x
	eorb	1,y
	eorb	1,sp-
	eorb	1,x-
	eorb	1,y-
	eorb	125,pc
	eorb	125,sp
	eorb	125,x
	eorb	125,y
	eorb	15,sp
	eorb	15,x
	eorb	15,y
	eorb	16,sp
	eorb	16,x
	eorb	16,y
	eorb	8,sp+
	eorb	8,x+
	eorb	8,y+
	eorb	8,sp-
	eorb	8,x-
	eorb	8,y-
	eorb	a,sp
	eorb	a,x
	eorb	a,y
	eorb	b,sp
	eorb	b,x
	eorb	b,y
	eorb	d,sp
	eorb	d,x
	eorb	d,y
	eorb	dir
	eorb	dir
	eorb	ext
	eorb	ext
	eorb	ext,sp
	eorb	ext,x
	eorb	ext,y
	eorb	ind,pc
	eorb	ind,sp
	eorb	ind,x
	eorb	ind,y
	eorb	small,pc
	eorb	small,sp
	eorb	small,x
	eorb	small,y

	eory	#immed	;s12x yellow
	eory	1,+sp	;s12x yellow
	eory	1,+x	;s12x yellow
	eory	1,+y	;s12x yellow
	eory	8,+sp	;s12x yellow
	eory	8,+x	;s12x yellow
	eory	8,+y	;s12x yellow
	eory	,pc	;s12x yellow
	eory	,sp	;s12x yellow
	eory	,x	;s12x yellow
	eory	,y	;s12x yellow
	eory	1,-sp	;s12x yellow
	eory	1,-x	;s12x yellow
	eory	1,-y	;s12x yellow
	eory	8,-sp	;s12x yellow
	eory	8,-x	;s12x yellow
	eory	8,-y	;s12x yellow
	eory	-1,sp	;s12x yellow
	eory	-1,x	;s12x yellow
	eory	-1,y	;s12x yellow
	eory	-16,sp	;s12x yellow
	eory	-16,x	;s12x yellow
	eory	-16,y	;s12x yellow
	eory	-17,sp	;s12x yellow
	eory	-17,x	;s12x yellow
	eory	-17,y	;s12x yellow
	eory	-small,pc	;s12x yellow
	eory	-small,sp	;s12x yellow
	eory	-small,x	;s12x yellow
	eory	-small,y	;s12x yellow
	eory	0,pc	;s12x yellow
	eory	0,sp	;s12x yellow
	eory	0,x	;s12x yellow
	eory	0,y	;s12x yellow
	eory	1,sp+	;s12x yellow
	eory	1,x+	;s12x yellow
	eory	1,y+	;s12x yellow
	eory	1,sp	;s12x yellow
	eory	1,x	;s12x yellow
	eory	1,y	;s12x yellow
	eory	1,sp-	;s12x yellow
	eory	1,x-	;s12x yellow
	eory	1,y-	;s12x yellow
	eory	125,pc	;s12x yellow
	eory	125,sp	;s12x yellow
	eory	125,x	;s12x yellow
	eory	125,y	;s12x yellow
	eory	15,sp	;s12x yellow
	eory	15,x	;s12x yellow
	eory	15,y	;s12x yellow
	eory	16,sp	;s12x yellow
	eory	16,x	;s12x yellow
	eory	16,y	;s12x yellow
	eory	8,sp+	;s12x yellow
	eory	8,x+	;s12x yellow
	eory	8,y+	;s12x yellow
	eory	8,sp-	;s12x yellow
	eory	8,x-	;s12x yellow
	eory	8,y-	;s12x yellow
	eory	a,sp	;s12x yellow
	eory	a,x	;s12x yellow
	eory	a,y	;s12x yellow
	eory	b,sp	;s12x yellow
	eory	b,x	;s12x yellow
	eory	b,y	;s12x yellow
	eory	d,sp	;s12x yellow
	eory	d,x	;s12x yellow
	eory	d,y	;s12x yellow
	eory	dir	;s12x yellow
	eory	dir	;s12x yellow
	eory	ext	;s12x yellow
	eory	ext	;s12x yellow
	eory	ext,sp	;s12x yellow
	eory	ext,x	;s12x yellow
	eory	ext,y	;s12x yellow
	eory	ind,pc	;s12x yellow
	eory	ind,sp	;s12x yellow
	eory	ind,x	;s12x yellow
	eory	ind,y	;s12x yellow
	eory	small,pc	;s12x yellow
	eory	small,sp	;s12x yellow
	eory	small,x	;s12x yellow
	eory	small,y	;s12x yellow

	etbl    5,x
	exg	a a
	exg	a b
	exg	a,b
	exg	a ccr
	exg	a ccrl	;s12x exg alternative
	exg	a ccrh	;s12x exg new
	exg	a d
	exg	a sp
	exg	a x
	exg	a,x
	exg	a y
	exg	a,x
	exg	b a
	exg	b b
	exg	b ccr
	exg	b ccrl	;s12x exg alternative
	;exg	b ccrh	;s12x exg new
	exg	b d
	exg	b sp
	exg	b x
	exg	b y
	exg	ccr a
	exg	ccrl a	;s12x exg alternative
	exg	ccrh a	;s12x exg new
	exg	ccr b
	exg	ccrl b	;s12x exg alternative
	;exg	ccrh b	;s12x exg new
	exg	ccr ccr
	exg	ccrw ccrw	;s12x exg new
	exg	ccr d	;??????
	exg	ccrl d	;s12x exg alternative
	exg	ccrw d	;s12x exg new
	exg	ccr sp
	exg	ccrl sp	;s12x exg alternative
	exg	ccrw sp	;s12x exg new
	exg	ccr x
	exg	ccrl x	;s12x exg alternative
	exg	ccrw x	;s12x exg new
	exg	ccr y
	exg	ccrl y	;s12x exg alternative
	exg	ccrw y	;s12x exg new
	exg	d a
	exg	d b
	exg	d ccr
	exg	d ccrl	;??????
	exg	d ccrw	;s12x exg new
	exg	d d
	exg	d sp
	exg	d x
	exg	d y
	exg	sp a
	exg	sp b
	exg	sp ccr
	exg	sp ccrl	;s12x exg alternative
	exg	sp ccrw	;s12x exg new
	exg	sp d
	exg	sp sp
	exg	sp x
	exg	sp y
	exg	x a
	exg	x b
	exg	x ccr
	exg	x ccrl	;s12x exg alternative
	exg	x ccrw	;s12x exg new
	exg	x d
	exg	x sp
	exg	x x
	exg	x y
	exg	x,y
	exg	y a
	exg	y b
	exg	y ccr
	exg	y ccrl	;s12x exg alternative
	exg	y ccrw	;s12x exg new
	exg	y d
	exg	y sp
	exg	y x
	exg	y y
	fdiv
	idiv
	inc	1,+sp
	inc	1,+x
	inc	1,+y
	inc	8,+sp
	inc	8,+x
	inc	8,+y
	inc	,pc
	inc	,sp
	inc	,x
	inc	,y
	inc	1,-sp
	inc	1,-x
	inc	1,-y
	inc	8,-sp
	inc	8,-x
	inc	8,-y
	inc	-1,sp
	inc	-1,x
	inc	-1,y
	inc	-16,sp
	inc	-16,x
	inc	-16,y
	inc	-17,sp
	inc	-17,x
	inc	-17,y
	inc	-small,pc
	inc	-small,sp
	inc	-small,x
	inc	-small,y
	inc	0,pc
	inc	0,sp
	inc	0,x
	inc	0,y
	inc	1,sp+
	inc	1,x+
	inc	1,y+
	inc	1,sp
	inc	1,x
	inc	1,y
	inc	1,sp-
	inc	1,x-
	inc	1,y-
	inc	125,pc
	inc	125,sp
	inc	125,x
	inc	125,y
	inc	15,sp
	inc	15,x
	inc	15,y
	inc	16,sp
	inc	16,x
	inc	16,y
	inc	8,sp+
	inc	8,x+
	inc	8,y+
	inc	8,sp-
	inc	8,x-
	inc	8,y-
	inc	a,sp
	inc	a,x
	inc	a,y
	inc	b,sp
	inc	b,x
	inc	b,y
	inc	d,sp
	inc	d,x
	inc	d,y
	inc	dir
	inc	ext
	inc	ext
	inc	ext,sp
	inc	ext,x
	inc	ext,y
	inc	ind,pc
	inc	ind,sp
	inc	ind,x
	inc	ind,y
	inc	small,pc
	inc	small,sp
	inc	small,x
	inc	small,y

	incw	1,+sp	;s12x green
	incw	1,+x	;s12x green
	incw	1,+y	;s12x green
	incw	8,+sp	;s12x green
	incw	8,+x	;s12x green
	incw	8,+y	;s12x green
	incw	,pc	;s12x green
	incw	,sp	;s12x green
	incw	,x	;s12x green
	incw	,y	;s12x green
	incw	1,-sp	;s12x green
	incw	1,-x	;s12x green
	incw	1,-y	;s12x green
	incw	8,-sp	;s12x green
	incw	8,-x	;s12x green
	incw	8,-y	;s12x green
	incw	-1,sp	;s12x green
	incw	-1,x	;s12x green
	incw	-1,y	;s12x green
	incw	-16,sp	;s12x green
	incw	-16,x	;s12x green
	incw	-16,y	;s12x green
	incw	-17,sp	;s12x green
	incw	-17,x	;s12x green
	incw	-17,y	;s12x green
	incw	-small,pc	;s12x green
	incw	-small,sp	;s12x green
	incw	-small,x	;s12x green
	incw	-small,y	;s12x green
	incw	0,pc	;s12x green
	incw	0,sp	;s12x green
	incw	0,x	;s12x green
	incw	0,y	;s12x green
	incw	1,sp+	;s12x green
	incw	1,x+	;s12x green
	incw	1,y+	;s12x green
	incw	1,sp	;s12x green
	incw	1,x	;s12x green
	incw	1,y	;s12x green
	incw	1,sp-	;s12x green
	incw	1,x-	;s12x green
	incw	1,y-	;s12x green
	incw	125,pc	;s12x green
	incw	125,sp	;s12x green
	incw	125,x	;s12x green
	incw	125,y	;s12x green
	incw	15,sp	;s12x green
	incw	15,x	;s12x green
	incw	15,y	;s12x green
	incw	16,sp	;s12x green
	incw	16,x	;s12x green
	incw	16,y	;s12x green
	incw	8,sp+	;s12x green
	incw	8,x+	;s12x green
	incw	8,y+	;s12x green
	incw	8,sp-	;s12x green
	incw	8,x-	;s12x green
	incw	8,y-	;s12x green
	incw	a,sp	;s12x green
	incw	a,x	;s12x green
	incw	a,y	;s12x green
	incw	b,sp	;s12x green
	incw	b,x	;s12x green
	incw	b,y	;s12x green
	incw	d,sp	;s12x green
	incw	d,x	;s12x green
	incw	d,y	;s12x green
	incw	dir	;s12x green
	incw	ext	;s12x green
	incw	ext	;s12x green
	incw	ext,sp	;s12x green
	incw	ext,x	;s12x green
	incw	ext,y	;s12x green
	incw	ind,pc	;s12x green
	incw	ind,sp	;s12x green
	incw	ind,x	;s12x green
	incw	ind,y	;s12x green
	incw	small,pc	;s12x green
	incw	small,sp	;s12x green
	incw	small,x	;s12x green
	incw	small,y	;s12x green

	inca
	incb

	incx	;s12x yellow
	incy	;s12x yellow
	
	ins
	inx
	iny
	jmp	1,+sp
	jmp	1,+x
	jmp	1,+y
	jmp	8,+sp
	jmp	8,+x
	jmp	8,+y
	jmp	,pc
	jmp	,sp
	jmp	,x
	jmp	,y
	jmp	1,-sp
	jmp	1,-x
	jmp	1,-y
	jmp	8,-sp
	jmp	8,-x
	jmp	8,-y
	jmp	-1,sp
	jmp	-1,x
	jmp	-1,y
	jmp	-16,sp
	jmp	-16,x
	jmp	-16,y
	jmp	-17,sp
	jmp	-17,x
	jmp	-17,y
	jmp	-small,pc
	jmp	-small,sp
	jmp	-small,x
	jmp	-small,y
	jmp	0,pc
	jmp	0,sp
	jmp	0,x
	jmp	0,y
	jmp	1,sp+
	jmp	1,x+
	jmp	1,y+
	jmp	1,sp
	jmp	1,x
	jmp	1,y
	jmp	1,sp-
	jmp	1,x-
	jmp	1,y-
	jmp	125,pc
	jmp	125,sp
	jmp	125,x
	jmp	125,y
	jmp	15,sp
	jmp	15,x
	jmp	15,y
	jmp	16,sp
	jmp	16,x
	jmp	16,y
	jmp	8,sp+
	jmp	8,x+
	jmp	8,y+
	jmp	8,sp-
	jmp	8,x-
	jmp	8,y-
	jmp	a,sp
	jmp	a,x
	jmp	a,y
	jmp	b,sp
	jmp	b,x
	jmp	b,y
	jmp	d,sp
	jmp	d,x
	jmp	d,y
	jmp	dir
	jmp	ext
	jmp	ext
	jmp	ext,sp
	jmp	ext,x
	jmp	ext,y
	jmp	ind,pc
	jmp	ind,sp
	jmp	ind,x
	jmp	ind,y
	jmp	small,pc
	jmp	small,sp
	jmp	small,x
	jmp	small,y
	jsr	1,+sp
	jsr	1,+x
	jsr	1,+y
	jsr	8,+sp
	jsr	8,+x
	jsr	8,+y
	jsr	,pc
	jsr	,sp
	jsr	,x
	jsr	,y
	jsr	1,-sp
	jsr	1,-x
	jsr	1,-y
	jsr	8,-sp
	jsr	8,-x
	jsr	8,-y
	jsr	-1,sp
	jsr	-1,x
	jsr	-1,y
	jsr	-16,sp
	jsr	-16,x
	jsr	-16,y
	jsr	-17,sp
	jsr	-17,x
	jsr	-17,y
	jsr	-small,pc
	jsr	-small,sp
	jsr	-small,x
	jsr	-small,y
	jsr	0,pc
	jsr	0,sp
	jsr	0,x
	jsr	0,y
	jsr	1,sp+
	jsr	1,x+
	jsr	1,y+
	jsr	1,sp
	jsr	1,x
	jsr	1,y
	jsr	1,sp-
	jsr	1,x-
	jsr	1,y-
	jsr	125,pc
	jsr	125,sp
	jsr	125,x
	jsr	125,y
	jsr	15,sp
	jsr	15,x
	jsr	15,y
	jsr	16,sp
	jsr	16,x
	jsr	16,y
	jsr	8,sp+
	jsr	8,x+
	jsr	8,y+
	jsr	8,sp-
	jsr	8,x-
	jsr	8,y-
	jsr	a,sp
	jsr	a,x
	jsr	a,y
	jsr	b,sp
	jsr	b,x
	jsr	b,y
	jsr	d,sp
	jsr	d,x
	jsr	d,y
	jsr	dir
	jsr	dir
	jsr	ext
	jsr	ext
	jsr	ext
	jsr	ext,sp
	jsr	ext,x
	jsr	ext,y
	jsr	ind,pc
	jsr	ind,sp
	jsr	ind,x
	jsr	ind,y
	jsr	small,pc
	jsr	small,sp
	jsr	small,x
	jsr	small,y
	lbcc	*
	lbcc	*
	lbcs	*
	lbeq	*
	lbge	*
	lbgt	*
	lbhi	*
	lble	*
	lbls	*
	lblt	*
	lbmi	*
	lbne	*
	lbpl	*
	lbra	*
	lbrn	*
	lbvc	*
	lbvs	*

	ldaa	#immed
	ldaa	1,+sp
	ldaa	1,+x
	ldaa	1,+y
	ldaa	8,+sp
	ldaa	8,+x
	ldaa	8,+y
	ldaa	,pc
	ldaa	,sp
	ldaa	,x
	ldaa	,y
	ldaa	1,-sp
	ldaa	1,-x
	ldaa	1,-y
	ldaa	8,-sp
	ldaa	8,-x
	ldaa	8,-y
	ldaa	-1,sp
	ldaa	-1,x
	ldaa	-1,y
	ldaa	-16,sp
	ldaa	-16,x
	ldaa	-16,y
	ldaa	-17,sp
	ldaa	-17,x
	ldaa	-17,y
	ldaa	-small,pc
	ldaa	-small,sp
	ldaa	-small,x
	ldaa	-small,y
	ldaa	0,pc
	ldaa	0,sp
	ldaa	0,x
	ldaa	0,y
	ldaa	1,sp+
	ldaa	1,x+
	ldaa	1,y+
	ldaa	1,sp
	ldaa	1,x
	ldaa	1,y
	ldaa	1,sp-
	ldaa	1,x-
	ldaa	1,y-
	ldaa	125,pc
	ldaa	125,sp
	ldaa	125,x
	ldaa	125,y
	ldaa	15,sp
	ldaa	15,x
	ldaa	15,y
	ldaa	16,sp
	ldaa	16,x
	ldaa	16,y
	ldaa	8,sp+
	ldaa	8,x+
	ldaa	8,y+
	ldaa	8,sp-
	ldaa	8,x-
	ldaa	8,y-
	ldaa	a,sp
	ldaa	a,x
	ldaa	a,y
	ldaa	b,sp
	ldaa	b,x
	ldaa	b,y
	ldaa	d,sp
	ldaa	d,x
	ldaa	d,y
	ldaa	dir
	ldaa	dir
	ldaa	ext
	ldaa	ext
	ldaa	ext,sp
	ldaa	ext,x
	ldaa	ext,y
	ldaa	ind,pc
	ldaa	ind,sp
	ldaa	ind,x
	ldaa	ind,y
	ldaa	small,pc
	ldaa	small,sp
	ldaa	small,x
	ldaa	small,y
	ldab	#immed
	ldab	#immed
	ldab	1,+sp
	ldab	1,+x
	ldab	1,+y
	ldab	8,+sp
	ldab	8,+x
	ldab	8,+y
	ldab	,pc
	ldab	,sp
	ldab	,x
	ldab	,y
	ldab	1,-sp
	ldab	1,-x
	ldab	1,-y
	ldab	8,-sp
	ldab	8,-x
	ldab	8,-y
	ldab	-1,sp
	ldab	-1,x
	ldab	-1,y
	ldab	-16,sp
	ldab	-16,x
	ldab	-16,y
	ldab	-17,sp
	ldab	-17,x
	ldab	-17,y
	ldab	-small,pc
	ldab	-small,sp
	ldab	-small,x
	ldab	-small,y
	ldab	0,pc
	ldab	0,sp
	ldab	0,x
	ldab	0,y
	ldab	1,sp+
	ldab	1,x+
	ldab	1,y+
	ldab	1,sp
	ldab	1,x
	ldab	1,y
	ldab	1,sp-
	ldab	1,x-
	ldab	1,y-
	ldab	125,pc
	ldab	125,sp
	ldab	125,x
	ldab	125,y
	ldab	15,sp
	ldab	15,x
	ldab	15,y
	ldab	16,sp
	ldab	16,x
	ldab	16,y
	ldab	8,sp+
	ldab	8,x+
	ldab	8,y+
	ldab	8,sp-
	ldab	8,x-
	ldab	8,y-
	ldab	a,sp
	ldab	a,x
	ldab	a,y
	ldab	b,sp
	ldab	b,x
	ldab	b,y
	ldab	d,sp
	ldab	d,x
	ldab	d,y
	ldab	dir
	ldab	dir
	ldab	ext
	ldab	ext
	ldab	ext,sp
	ldab	ext,x
	ldab	ext,y
	ldab	ind,pc
	ldab	ind,sp
	ldab	ind,x
	ldab	ind,y
	ldab	small,pc
	ldab	small,sp
	ldab	small,x
	ldab	small,y
	ldd	#immed
	ldd	#immed
	ldd	1,+sp
	ldd	1,+x
	ldd	1,+y
	ldd	8,+sp
	ldd	8,+x
	ldd	8,+y
	ldd	,pc
	ldd	,sp
	ldd	,x
	ldd	,y
	ldd	1,-sp
	ldd	1,-x
	ldd	1,-y
	ldd	8,-sp
	ldd	8,-x
	ldd	8,-y
	ldd	-1,sp
	ldd	-1,x
	ldd	-1,y
	ldd	-16,sp
	ldd	-16,x
	ldd	-16,y
	ldd	-17,sp
	ldd	-17,x
	ldd	-17,y
	ldd	-small,pc
	ldd	-small,sp
	ldd	-small,x
	ldd	-small,y
	ldd	0,pc
	ldd	0,sp
	ldd	0,x
	ldd	0,y
	ldd	1,sp+
	ldd	1,x+
	ldd	1,y+
	ldd	1,sp
	ldd	1,x
	ldd	1,y
	ldd	1,sp-
	ldd	1,x-
	ldd	1,y-
	ldd	125,pc
	ldd	125,sp
	ldd	125,x
	ldd	125,y
	ldd	15,sp
	ldd	15,x
	ldd	15,y
	ldd	16,sp
	ldd	16,x
	ldd	16,y
	ldd	8,sp+
	ldd	8,x+
	ldd	8,y+
	ldd	8,sp-
	ldd	8,x-
	ldd	8,y-
	ldd	a,sp
	ldd	a,x
	ldd	a,y
	ldd	b,sp
	ldd	b,x
	ldd	b,y
	ldd	d,sp
	ldd	d,x
	ldd	d,y
	ldd	dir
	ldd	dir
	ldd	ext
	ldd	ext
	ldd	ext,sp
	ldd	ext,x
	ldd	ext,y
	ldd	ind,pc
	ldd	ind,sp
	ldd	ind,x
	ldd	ind,y
	ldd	small,pc
	ldd	small,sp
	ldd	small,x
	ldd	small,y
	lds	#immed
	lds	#immed
	lds	1,+sp
	lds	1,+x
	lds	1,+y
	lds	8,+sp
	lds	8,+x
	lds	8,+y
	lds	,pc
	lds	,sp
	lds	,x
	lds	,y
	lds	1,-sp
	lds	1,-x
	lds	1,-y
	lds	8,-sp
	lds	8,-x
	lds	8,-y
	lds	-1,sp
	lds	-1,x
	lds	-1,y
	lds	-16,sp
	lds	-16,x
	lds	-16,y
	lds	-17,sp
	lds	-17,x
	lds	-17,y
	lds	-small,pc
	lds	-small,sp
	lds	-small,x
	lds	-small,y
	lds	0,pc
	lds	0,sp
	lds	0,x
	lds	0,y
	lds	1,sp+
	lds	1,x+
	lds	1,y+
	lds	1,sp
	lds	1,x
	lds	1,y
	lds	1,sp-
	lds	1,x-
	lds	1,y-
	lds	125,pc
	lds	125,sp
	lds	125,x
	lds	125,y
	lds	15,sp
	lds	15,x
	lds	15,y
	lds	16,sp
	lds	16,x
	lds	16,y
	lds	8,sp+
	lds	8,x+
	lds	8,y+
	lds	8,sp-
	lds	8,x-
	lds	8,y-
	lds	a,sp
	lds	a,x
	lds	a,y
	lds	b,sp
	lds	b,x
	lds	b,y
	lds	d,sp
	lds	d,x
	lds	d,y
	lds	dir
	lds	ext
	lds	ext,sp
	lds	ext,x
	lds	ext,y
	lds	ind,pc
	lds	ind,sp
	lds	ind,x
	lds	ind,y
	lds	small,pc
	lds	small,sp
	lds	small,x
	lds	small,y
	ldx	#immed
	ldx	#immed
	ldx	1,+sp
	ldx	1,+x
	ldx	1,+y
	ldx	8,+sp
	ldx	8,+x
	ldx	8,+y
	ldx	,pc
	ldx	,sp
	ldx	,x
	ldx	,y
	ldx	1,-sp
	ldx	1,-x
	ldx	1,-y
	ldx	8,-sp
	ldx	8,-x
	ldx	8,-y
	ldx	-1,sp
	ldx	-1,x
	ldx	-1,y
	ldx	-16,sp
	ldx	-16,x
	ldx	-16,y
	ldx	-17,sp
	ldx	-17,x
	ldx	-17,y
	ldx	-small,pc
	ldx	-small,sp
	ldx	-small,x
	ldx	-small,y
	ldx	0,pc
	ldx	0,sp
	ldx	0,x
	ldx	0,y
	ldx	1,sp+
	ldx	1,x+
	ldx	1,y+
	ldx	1,sp
	ldx	1,x
	ldx	1,y
	ldx	1,sp-
	ldx	1,x-
	ldx	1,y-
	ldx	125,pc
	ldx	125,sp
	ldx	125,x
	ldx	125,y
	ldx	15,sp
	ldx	15,x
	ldx	15,y
	ldx	16,sp
	ldx	16,x
	ldx	16,y
	ldx	8,sp+
	ldx	8,x+
	ldx	8,y+
	ldx	8,sp-
	ldx	8,x-
	ldx	8,y-
	ldx	a,sp
	ldx	a,x
	ldx	a,y
	ldx	b,sp
	ldx	b,x
	ldx	b,y
	ldx	d,sp
	ldx	d,x
	ldx	d,y
	ldx	dir
	ldx	dir
	ldx	ext
	ldx	ext
	ldx	ext,sp
	ldx	ext,x
	ldx	ext,y
	ldx	ind,pc
	ldx	ind,sp
	ldx	ind,x
	ldx	ind,y
	ldx	small,pc
	ldx	small,sp
	ldx	small,x
	ldx	small,y
	ldy	#immed
	ldy	#immed
	ldy	1,+sp
	ldy	1,+x
	ldy	1,+y
	ldy	8,+sp
	ldy	8,+x
	ldy	8,+y
	ldy	,pc
	ldy	,sp
	ldy	,x
	ldy	,y
	ldy	1,-sp
	ldy	1,-x
	ldy	1,-y
	ldy	8,-sp
	ldy	8,-x
	ldy	8,-y
	ldy	-1,sp
	ldy	-1,x
	ldy	-1,y
	ldy	-16,sp
	ldy	-16,x
	ldy	-16,y
	ldy	-17,sp
	ldy	-17,x
	ldy	-17,y
	ldy	-small,pc
	ldy	-small,sp
	ldy	-small,x
	ldy	-small,y
	ldy	0,pc
	ldy	0,sp
	ldy	0,x
	ldy	0,y
	ldy	1,sp+
	ldy	1,x+
	ldy	1,y+
	ldy	1,sp
	ldy	1,x
	ldy	1,y
	ldy	1,sp-
	ldy	1,x-
	ldy	1,y-
	ldy	125,pc
	ldy	125,sp
	ldy	125,x
	ldy	125,y
	ldy	15,sp
	ldy	15,x
	ldy	15,y
	ldy	16,sp
	ldy	16,x
	ldy	16,y
	ldy	8,sp+
	ldy	8,x+
	ldy	8,y+
	ldy	8,sp-
	ldy	8,x-
	ldy	8,y-
	ldy	a,sp
	ldy	a,x
	ldy	a,y
	ldy	b,sp
	ldy	b,x
	ldy	b,y
	ldy	d,sp
	ldy	d,x
	ldy	d,y
	ldy	dir
	ldy	dir
	ldy	ext
	ldy	ext
	ldy	ext,sp
	ldy	ext,x
	ldy	ext,y
	ldy	ind,pc
	ldy	ind,sp
	ldy	ind,x
	ldy	ind,y
	ldy	small,pc
	ldy	small,sp
	ldy	small,x
	ldy	small,y

	gldaa	1,+sp	;s12x cyan
	gldaa	1,+x	;s12x cyan
	gldaa	1,+y	;s12x cyan
	gldaa	8,+sp	;s12x cyan
	gldaa	8,+x	;s12x cyan
	gldaa	8,+y	;s12x cyan
	gldaa	,pc	;s12x cyan
	gldaa	,sp	;s12x cyan
	gldaa	,x	;s12x cyan
	gldaa	,y	;s12x cyan
	gldaa	1,-sp	;s12x cyan
	gldaa	1,-x	;s12x cyan
	gldaa	1,-y	;s12x cyan
	gldaa	8,-sp	;s12x cyan
	gldaa	8,-x	;s12x cyan
	gldaa	8,-y	;s12x cyan
	gldaa	-1,sp	;s12x cyan
	gldaa	-1,x	;s12x cyan
	gldaa	-1,y	;s12x cyan
	gldaa	-16,sp	;s12x cyan
	gldaa	-16,x	;s12x cyan
	gldaa	-16,y	;s12x cyan
	gldaa	-17,sp	;s12x cyan
	gldaa	-17,x	;s12x cyan
	gldaa	-17,y	;s12x cyan
	gldaa	-small,pc	;s12x cyan
	gldaa	-small,sp	;s12x cyan
	gldaa	-small,x	;s12x cyan
	gldaa	-small,y	;s12x cyan
	gldaa	0,pc	;s12x cyan
	gldaa	0,sp	;s12x cyan
	gldaa	0,x	;s12x cyan
	gldaa	0,y	;s12x cyan
	gldaa	1,sp+	;s12x cyan
	gldaa	1,x+	;s12x cyan
	gldaa	1,y+	;s12x cyan
	gldaa	1,sp	;s12x cyan
	gldaa	1,x	;s12x cyan
	gldaa	1,y	;s12x cyan
	gldaa	1,sp-	;s12x cyan
	gldaa	1,x-	;s12x cyan
	gldaa	1,y-	;s12x cyan
	gldaa	125,pc	;s12x cyan
	gldaa	125,sp	;s12x cyan
	gldaa	125,x	;s12x cyan
	gldaa	125,y	;s12x cyan
	gldaa	15,sp	;s12x cyan
	gldaa	15,x	;s12x cyan
	gldaa	15,y	;s12x cyan
	gldaa	16,sp	;s12x cyan
	gldaa	16,x	;s12x cyan
	gldaa	16,y	;s12x cyan
	gldaa	8,sp+	;s12x cyan
	gldaa	8,x+	;s12x cyan
	gldaa	8,y+	;s12x cyan
	gldaa	8,sp-	;s12x cyan
	gldaa	8,x-	;s12x cyan
	gldaa	8,y-	;s12x cyan
	gldaa	a,sp	;s12x cyan
	gldaa	a,x	;s12x cyan
	gldaa	a,y	;s12x cyan
	gldaa	b,sp	;s12x cyan
	gldaa	b,x	;s12x cyan
	gldaa	b,y	;s12x cyan
	gldaa	d,sp	;s12x cyan
	gldaa	d,x	;s12x cyan
	gldaa	d,y	;s12x cyan
	gldaa	dir	;s12x cyan
	gldaa	dir	;s12x cyan
	gldaa	ext	;s12x cyan
	gldaa	ext	;s12x cyan
	gldaa	ext,sp	;s12x cyan
	gldaa	ext,x	;s12x cyan
	gldaa	ext,y	;s12x cyan
	gldaa	ind,pc	;s12x cyan
	gldaa	ind,sp	;s12x cyan
	gldaa	ind,x	;s12x cyan
	gldaa	ind,y	;s12x cyan
	gldaa	small,pc	;s12x cyan
	gldaa	small,sp	;s12x cyan
	gldaa	small,x	;s12x cyan
	gldaa	small,y	;s12x cyan
	gldab	1,+sp	;s12x cyan
	gldab	1,+x	;s12x cyan
	gldab	1,+y	;s12x cyan
	gldab	8,+sp	;s12x cyan
	gldab	8,+x	;s12x cyan
	gldab	8,+y	;s12x cyan
	gldab	,pc	;s12x cyan
	gldab	,sp	;s12x cyan
	gldab	,x	;s12x cyan
	gldab	,y	;s12x cyan
	gldab	1,-sp	;s12x cyan
	gldab	1,-x	;s12x cyan
	gldab	1,-y	;s12x cyan
	gldab	8,-sp	;s12x cyan
	gldab	8,-x	;s12x cyan
	gldab	8,-y	;s12x cyan
	gldab	-1,sp	;s12x cyan
	gldab	-1,x	;s12x cyan
	gldab	-1,y	;s12x cyan
	gldab	-16,sp	;s12x cyan
	gldab	-16,x	;s12x cyan
	gldab	-16,y	;s12x cyan
	gldab	-17,sp	;s12x cyan
	gldab	-17,x	;s12x cyan
	gldab	-17,y	;s12x cyan
	gldab	-small,pc	;s12x cyan
	gldab	-small,sp	;s12x cyan
	gldab	-small,x	;s12x cyan
	gldab	-small,y	;s12x cyan
	gldab	0,pc	;s12x cyan
	gldab	0,sp	;s12x cyan
	gldab	0,x	;s12x cyan
	gldab	0,y	;s12x cyan
	gldab	1,sp+	;s12x cyan
	gldab	1,x+	;s12x cyan
	gldab	1,y+	;s12x cyan
	gldab	1,sp	;s12x cyan
	gldab	1,x	;s12x cyan
	gldab	1,y	;s12x cyan
	gldab	1,sp-	;s12x cyan
	gldab	1,x-	;s12x cyan
	gldab	1,y-	;s12x cyan
	gldab	125,pc	;s12x cyan
	gldab	125,sp	;s12x cyan
	gldab	125,x	;s12x cyan
	gldab	125,y	;s12x cyan
	gldab	15,sp	;s12x cyan
	gldab	15,x	;s12x cyan
	gldab	15,y	;s12x cyan
	gldab	16,sp	;s12x cyan
	gldab	16,x	;s12x cyan
	gldab	16,y	;s12x cyan
	gldab	8,sp+	;s12x cyan
	gldab	8,x+	;s12x cyan
	gldab	8,y+	;s12x cyan
	gldab	8,sp-	;s12x cyan
	gldab	8,x-	;s12x cyan
	gldab	8,y-	;s12x cyan
	gldab	a,sp	;s12x cyan
	gldab	a,x	;s12x cyan
	gldab	a,y	;s12x cyan
	gldab	b,sp	;s12x cyan
	gldab	b,x	;s12x cyan
	gldab	b,y	;s12x cyan
	gldab	d,sp	;s12x cyan
	gldab	d,x	;s12x cyan
	gldab	d,y	;s12x cyan
	gldab	dir	;s12x cyan
	gldab	dir	;s12x cyan
	gldab	ext	;s12x cyan
	gldab	ext	;s12x cyan
	gldab	ext,sp	;s12x cyan
	gldab	ext,x	;s12x cyan
	gldab	ext,y	;s12x cyan
	gldab	ind,pc	;s12x cyan
	gldab	ind,sp	;s12x cyan
	gldab	ind,x	;s12x cyan
	gldab	ind,y	;s12x cyan
	gldab	small,pc	;s12x cyan
	gldab	small,sp	;s12x cyan
	gldab	small,x	;s12x cyan
	gldab	small,y	;s12x cyan
	gldd	1,+sp	;s12x cyan
	gldd	1,+x	;s12x cyan
	gldd	1,+y	;s12x cyan
	gldd	8,+sp	;s12x cyan
	gldd	8,+x	;s12x cyan
	gldd	8,+y	;s12x cyan
	gldd	,pc	;s12x cyan
	gldd	,sp	;s12x cyan
	gldd	,x	;s12x cyan
	gldd	,y	;s12x cyan
	gldd	1,-sp	;s12x cyan
	gldd	1,-x	;s12x cyan
	gldd	1,-y	;s12x cyan
	gldd	8,-sp	;s12x cyan
	gldd	8,-x	;s12x cyan
	gldd	8,-y	;s12x cyan
	gldd	-1,sp	;s12x cyan
	gldd	-1,x	;s12x cyan
	gldd	-1,y	;s12x cyan
	gldd	-16,sp	;s12x cyan
	gldd	-16,x	;s12x cyan
	gldd	-16,y	;s12x cyan
	gldd	-17,sp	;s12x cyan
	gldd	-17,x	;s12x cyan
	gldd	-17,y	;s12x cyan
	gldd	-small,pc	;s12x cyan
	gldd	-small,sp	;s12x cyan
	gldd	-small,x	;s12x cyan
	gldd	-small,y	;s12x cyan
	gldd	0,pc	;s12x cyan
	gldd	0,sp	;s12x cyan
	gldd	0,x	;s12x cyan
	gldd	0,y	;s12x cyan
	gldd	1,sp+	;s12x cyan
	gldd	1,x+	;s12x cyan
	gldd	1,y+	;s12x cyan
	gldd	1,sp	;s12x cyan
	gldd	1,x	;s12x cyan
	gldd	1,y	;s12x cyan
	gldd	1,sp-	;s12x cyan
	gldd	1,x-	;s12x cyan
	gldd	1,y-	;s12x cyan
	gldd	125,pc	;s12x cyan
	gldd	125,sp	;s12x cyan
	gldd	125,x	;s12x cyan
	gldd	125,y	;s12x cyan
	gldd	15,sp	;s12x cyan
	gldd	15,x	;s12x cyan
	gldd	15,y	;s12x cyan
	gldd	16,sp	;s12x cyan
	gldd	16,x	;s12x cyan
	gldd	16,y	;s12x cyan
	gldd	8,sp+	;s12x cyan
	gldd	8,x+	;s12x cyan
	gldd	8,y+	;s12x cyan
	gldd	8,sp-	;s12x cyan
	gldd	8,x-	;s12x cyan
	gldd	8,y-	;s12x cyan
	gldd	a,sp	;s12x cyan
	gldd	a,x	;s12x cyan
	gldd	a,y	;s12x cyan
	gldd	b,sp	;s12x cyan
	gldd	b,x	;s12x cyan
	gldd	b,y	;s12x cyan
	gldd	d,sp	;s12x cyan
	gldd	d,x	;s12x cyan
	gldd	d,y	;s12x cyan
	gldd	dir	;s12x cyan
	gldd	dir	;s12x cyan
	gldd	ext	;s12x cyan
	gldd	ext	;s12x cyan
	gldd	ext,sp	;s12x cyan
	gldd	ext,x	;s12x cyan
	gldd	ext,y	;s12x cyan
	gldd	ind,pc	;s12x cyan
	gldd	ind,sp	;s12x cyan
	gldd	ind,x	;s12x cyan
	gldd	ind,y	;s12x cyan
	gldd	small,pc	;s12x cyan
	gldd	small,sp	;s12x cyan
	gldd	small,x	;s12x cyan
	gldd	small,y	;s12x cyan
	glds	1,+sp	;s12x cyan
	glds	1,+x	;s12x cyan
	glds	1,+y	;s12x cyan
	glds	8,+sp	;s12x cyan
	glds	8,+x	;s12x cyan
	glds	8,+y	;s12x cyan
	glds	,pc	;s12x cyan
	glds	,sp	;s12x cyan
	glds	,x	;s12x cyan
	glds	,y	;s12x cyan
	glds	1,-sp	;s12x cyan
	glds	1,-x	;s12x cyan
	glds	1,-y	;s12x cyan
	glds	8,-sp	;s12x cyan
	glds	8,-x	;s12x cyan
	glds	8,-y	;s12x cyan
	glds	-1,sp	;s12x cyan
	glds	-1,x	;s12x cyan
	glds	-1,y	;s12x cyan
	glds	-16,sp	;s12x cyan
	glds	-16,x	;s12x cyan
	glds	-16,y	;s12x cyan
	glds	-17,sp	;s12x cyan
	glds	-17,x	;s12x cyan
	glds	-17,y	;s12x cyan
	glds	-small,pc	;s12x cyan
	glds	-small,sp	;s12x cyan
	glds	-small,x	;s12x cyan
	glds	-small,y	;s12x cyan
	glds	0,pc	;s12x cyan
	glds	0,sp	;s12x cyan
	glds	0,x	;s12x cyan
	glds	0,y	;s12x cyan
	glds	1,sp+	;s12x cyan
	glds	1,x+	;s12x cyan
	glds	1,y+	;s12x cyan
	glds	1,sp	;s12x cyan
	glds	1,x	;s12x cyan
	glds	1,y	;s12x cyan
	glds	1,sp-	;s12x cyan
	glds	1,x-	;s12x cyan
	glds	1,y-	;s12x cyan
	glds	125,pc	;s12x cyan
	glds	125,sp	;s12x cyan
	glds	125,x	;s12x cyan
	glds	125,y	;s12x cyan
	glds	15,sp	;s12x cyan
	glds	15,x	;s12x cyan
	glds	15,y	;s12x cyan
	glds	16,sp	;s12x cyan
	glds	16,x	;s12x cyan
	glds	16,y	;s12x cyan
	glds	8,sp+	;s12x cyan
	glds	8,x+	;s12x cyan
	glds	8,y+	;s12x cyan
	glds	8,sp-	;s12x cyan
	glds	8,x-	;s12x cyan
	glds	8,y-	;s12x cyan
	glds	a,sp	;s12x cyan
	glds	a,x	;s12x cyan
	glds	a,y	;s12x cyan
	glds	b,sp	;s12x cyan
	glds	b,x	;s12x cyan
	glds	b,y	;s12x cyan
	glds	d,sp	;s12x cyan
	glds	d,x	;s12x cyan
	glds	d,y	;s12x cyan
	glds	dir	;s12x cyan
	glds	ext	;s12x cyan
	glds	ext,sp	;s12x cyan
	glds	ext,x	;s12x cyan
	glds	ext,y	;s12x cyan
	glds	ind,pc	;s12x cyan
	glds	ind,sp	;s12x cyan
	glds	ind,x	;s12x cyan
	glds	ind,y	;s12x cyan
	glds	small,pc	;s12x cyan
	glds	small,sp	;s12x cyan
	glds	small,x	;s12x cyan
	glds	small,y	;s12x cyan
	gldx	1,+sp	;s12x cyan
	gldx	1,+x	;s12x cyan
	gldx	1,+y	;s12x cyan
	gldx	8,+sp	;s12x cyan
	gldx	8,+x	;s12x cyan
	gldx	8,+y	;s12x cyan
	gldx	,pc	;s12x cyan
	gldx	,sp	;s12x cyan
	gldx	,x	;s12x cyan
	gldx	,y	;s12x cyan
	gldx	1,-sp	;s12x cyan
	gldx	1,-x	;s12x cyan
	gldx	1,-y	;s12x cyan
	gldx	8,-sp	;s12x cyan
	gldx	8,-x	;s12x cyan
	gldx	8,-y	;s12x cyan
	gldx	-1,sp	;s12x cyan
	gldx	-1,x	;s12x cyan
	gldx	-1,y	;s12x cyan
	gldx	-16,sp	;s12x cyan
	gldx	-16,x	;s12x cyan
	gldx	-16,y	;s12x cyan
	gldx	-17,sp	;s12x cyan
	gldx	-17,x	;s12x cyan
	gldx	-17,y	;s12x cyan
	gldx	-small,pc	;s12x cyan
	gldx	-small,sp	;s12x cyan
	gldx	-small,x	;s12x cyan
	gldx	-small,y	;s12x cyan
	gldx	0,pc	;s12x cyan
	gldx	0,sp	;s12x cyan
	gldx	0,x	;s12x cyan
	gldx	0,y	;s12x cyan
	gldx	1,sp+	;s12x cyan
	gldx	1,x+	;s12x cyan
	gldx	1,y+	;s12x cyan
	gldx	1,sp	;s12x cyan
	gldx	1,x	;s12x cyan
	gldx	1,y	;s12x cyan
	gldx	1,sp-	;s12x cyan
	gldx	1,x-	;s12x cyan
	gldx	1,y-	;s12x cyan
	gldx	125,pc	;s12x cyan
	gldx	125,sp	;s12x cyan
	gldx	125,x	;s12x cyan
	gldx	125,y	;s12x cyan
	gldx	15,sp	;s12x cyan
	gldx	15,x	;s12x cyan
	gldx	15,y	;s12x cyan
	gldx	16,sp	;s12x cyan
	gldx	16,x	;s12x cyan
	gldx	16,y	;s12x cyan
	gldx	8,sp+	;s12x cyan
	gldx	8,x+	;s12x cyan
	gldx	8,y+	;s12x cyan
	gldx	8,sp-	;s12x cyan
	gldx	8,x-	;s12x cyan
	gldx	8,y-	;s12x cyan
	gldx	a,sp	;s12x cyan
	gldx	a,x	;s12x cyan
	gldx	a,y	;s12x cyan
	gldx	b,sp	;s12x cyan
	gldx	b,x	;s12x cyan
	gldx	b,y	;s12x cyan
	gldx	d,sp	;s12x cyan
	gldx	d,x	;s12x cyan
	gldx	d,y	;s12x cyan
	gldx	dir	;s12x cyan
	gldx	dir	;s12x cyan
	gldx	ext	;s12x cyan
	gldx	ext	;s12x cyan
	gldx	ext,sp	;s12x cyan
	gldx	ext,x	;s12x cyan
	gldx	ext,y	;s12x cyan
	gldx	ind,pc	;s12x cyan
	gldx	ind,sp	;s12x cyan
	gldx	ind,x	;s12x cyan
	gldx	ind,y	;s12x cyan
	gldx	small,pc	;s12x cyan
	gldx	small,sp	;s12x cyan
	gldx	small,x	;s12x cyan
	gldx	small,y	;s12x cyan
	gldy	1,+sp	;s12x cyan
	gldy	1,+x	;s12x cyan
	gldy	1,+y	;s12x cyan
	gldy	8,+sp	;s12x cyan
	gldy	8,+x	;s12x cyan
	gldy	8,+y	;s12x cyan
	gldy	,pc	;s12x cyan
	gldy	,sp	;s12x cyan
	gldy	,x	;s12x cyan
	gldy	,y	;s12x cyan
	gldy	1,-sp	;s12x cyan
	gldy	1,-x	;s12x cyan
	gldy	1,-y	;s12x cyan
	gldy	8,-sp	;s12x cyan
	gldy	8,-x	;s12x cyan
	gldy	8,-y	;s12x cyan
	gldy	-1,sp	;s12x cyan
	gldy	-1,x	;s12x cyan
	gldy	-1,y	;s12x cyan
	gldy	-16,sp	;s12x cyan
	gldy	-16,x	;s12x cyan
	gldy	-16,y	;s12x cyan
	gldy	-17,sp	;s12x cyan
	gldy	-17,x	;s12x cyan
	gldy	-17,y	;s12x cyan
	gldy	-small,pc	;s12x cyan
	gldy	-small,sp	;s12x cyan
	gldy	-small,x	;s12x cyan
	gldy	-small,y	;s12x cyan
	gldy	0,pc	;s12x cyan
	gldy	0,sp	;s12x cyan
	gldy	0,x	;s12x cyan
	gldy	0,y	;s12x cyan
	gldy	1,sp+	;s12x cyan
	gldy	1,x+	;s12x cyan
	gldy	1,y+	;s12x cyan
	gldy	1,sp	;s12x cyan
	gldy	1,x	;s12x cyan
	gldy	1,y	;s12x cyan
	gldy	1,sp-	;s12x cyan
	gldy	1,x-	;s12x cyan
	gldy	1,y-	;s12x cyan
	gldy	125,pc	;s12x cyan
	gldy	125,sp	;s12x cyan
	gldy	125,x	;s12x cyan
	gldy	125,y	;s12x cyan
	gldy	15,sp	;s12x cyan
	gldy	15,x	;s12x cyan
	gldy	15,y	;s12x cyan
	gldy	16,sp	;s12x cyan
	gldy	16,x	;s12x cyan
	gldy	16,y	;s12x cyan
	gldy	8,sp+	;s12x cyan
	gldy	8,x+	;s12x cyan
	gldy	8,y+	;s12x cyan
	gldy	8,sp-	;s12x cyan
	gldy	8,x-	;s12x cyan
	gldy	8,y-	;s12x cyan
	gldy	a,sp	;s12x cyan
	gldy	a,x	;s12x cyan
	gldy	a,y	;s12x cyan
	gldy	b,sp	;s12x cyan
	gldy	b,x	;s12x cyan
	gldy	b,y	;s12x cyan
	gldy	d,sp	;s12x cyan
	gldy	d,x	;s12x cyan
	gldy	d,y	;s12x cyan
	gldy	dir	;s12x cyan
	gldy	dir	;s12x cyan
	gldy	ext	;s12x cyan
	gldy	ext	;s12x cyan
	gldy	ext,sp	;s12x cyan
	gldy	ext,x	;s12x cyan
	gldy	ext,y	;s12x cyan
	gldy	ind,pc	;s12x cyan
	gldy	ind,sp	;s12x cyan
	gldy	ind,x	;s12x cyan
	gldy	ind,y	;s12x cyan
	gldy	small,pc	;s12x cyan
	gldy	small,sp	;s12x cyan
	gldy	small,x	;s12x cyan
	gldy	small,y	;s12x cyan

	leas	1,+sp
	leas	1,+x
	leas	1,+y
	leas	8,+sp
	leas	8,+x
	leas	8,+y
	leas	,pc
	leas	,sp
	leas	,x
	leas	,y
	leas	1,-sp
	leas	1,-x
	leas	1,-y
	leas	8,-sp
	leas	8,-x
	leas	8,-y
	leas	-1,sp
	leas	-1,x
	leas	-1,y
	leas	-16,sp
	leas	-16,x
	leas	-16,y
	leas	-17,sp
	leas	-17,x
	leas	-17,y
	leas	-small,pc
	leas	-small,sp
	leas	-small,x
	leas	-small,y
	leas	0,pc
	leas	0,sp
	leas	0,x
	leas	0,y
	leas	1,sp+
	leas	1,x+
	leas	1,y+
	leas	1,sp
	leas	1,x
	leas	1,y
	leas	1,sp-
	leas	1,x-
	leas	1,y-
	leas	125,pc
	leas	125,sp
	leas	125,x
	leas	125,y
	leas	15,sp
	leas	15,x
	leas	15,y
	leas	16,sp
	leas	16,x
	leas	16,y
	leas	8,sp+
	leas	8,x+
	leas	8,y+
	leas	8,sp-
	leas	8,x-
	leas	8,y-
	leas	a,sp
	leas	a,x
	leas	a,y
	leas	b,sp
	leas	b,x
	leas	b,y
	leas	d,sp
	leas	d,x
	leas	d,y
	leas	ext,sp
	leas	ext,x
	leas	ext,y
	leas	ind,pc
	leas	ind,sp
	leas	ind,x
	leas	ind,y
	leas	small,pc
	leas	small,sp
	leas	small,x
	leas	small,y
	leax	1,+sp
	leax	1,+x
	leax	1,+y
	leax	8,+sp
	leax	8,+x
	leax	8,+y
	leax	,pc
	leax	,sp
	leax	,x
	leax	,y
	leax	1,-sp
	leax	1,-x
	leax	1,-y
	leax	8,-sp
	leax	8,-x
	leax	8,-y
	leax	-1,sp
	leax	-1,x
	leax	-1,y
	leax	-16,sp
	leax	-16,x
	leax	-16,y
	leax	-17,sp
	leax	-17,x
	leax	-17,y
	leax	-small,pc
	leax	-small,sp
	leax	-small,x
	leax	-small,y
	leax	0,pc
	leax	0,sp
	leax	0,x
	leax	0,y
	leax	1,sp+
	leax	1,x+
	leax	1,y+
	leax	1,sp
	leax	1,x
	leax	1,y
	leax	1,sp-
	leax	1,x-
	leax	1,y-
	leax	125,pc
	leax	125,sp
	leax	125,x
	leax	125,y
	leax	15,sp
	leax	15,x
	leax	15,y
	leax	16,sp
	leax	16,x
	leax	16,y
	leax	8,sp+
	leax	8,x+
	leax	8,y+
	leax	8,sp-
	leax	8,x-
	leax	8,y-
	leax	a,sp
	leax	a,x
	leax	a,y
	leax	b,sp
	leax	b,x
	leax	b,y
	leax	d,sp
	leax	d,x
	leax	d,y
	leax	ext,sp
	leax	ext,x
	leax	ext,y
	leax	ind,pc
	leax	ind,sp
	leax	ind,x
	leax	ind,y
	leax	small,pc
	leax	small,sp
	leax	small,x
	leax	small,y
	leay	1,+sp
	leay	1,+x
	leay	1,+y
	leay	8,+sp
	leay	8,+x
	leay	8,+y
	leay	,pc
	leay	,sp
	leay	,x
	leay	,y
	leay	1,-sp
	leay	1,-x
	leay	1,-y
	leay	8,-sp
	leay	8,-x
	leay	8,-y
	leay	-1,sp
	leay	-1,x
	leay	-1,y
	leay	-16,sp
	leay	-16,x
	leay	-16,y
	leay	-17,sp
	leay	-17,x
	leay	-17,y
	leay	-small,pc
	leay	-small,sp
	leay	-small,x
	leay	-small,y
	leay	0,pc
	leay	0,sp
	leay	0,x
	leay	0,y
	leay	1,sp+
	leay	1,x+
	leay	1,y+
	leay	1,sp
	leay	1,x
	leay	1,y
	leay	1,sp-
	leay	1,x-
	leay	1,y-
	leay	125,pc
	leay	125,sp
	leay	125,x
	leay	125,y
	leay	15,sp
	leay	15,x
	leay	15,y
	leay	16,sp
	leay	16,x
	leay	16,y
	leay	8,sp+
	leay	8,x+
	leay	8,y+
	leay	8,sp-
	leay	8,x-
	leay	8,y-
	leay	a,sp
	leay	a,x
	leay	a,y
	leay	b,sp
	leay	b,x
	leay	b,y
	leay	d,sp
	leay	d,x
	leay	d,y
	leay	ext,sp
	leay	ext,x
	leay	ext,y
	leay	ind,pc
	leay	ind,sp
	leay	ind,x
	leay	ind,y
	leay	small,pc
	leay	small,sp
	leay	small,x
	leay	small,y
	lsl	1,+sp
	lsl	1,+x
	lsl	1,+y
	lsl	8,+sp
	lsl	8,+x
	lsl	8,+y
	lsl	,pc
	lsl	,sp
	lsl	,x
	lsl	,y
	lsl	1,-sp
	lsl	1,-x
	lsl	1,-y
	lsl	8,-sp
	lsl	8,-x
	lsl	8,-y
	lsl	-1,sp
	lsl	-1,x
	lsl	-1,y
	lsl	-16,sp
	lsl	-16,x
	lsl	-16,y
	lsl	-17,sp
	lsl	-17,x
	lsl	-17,y
	lsl	-small,pc
	lsl	-small,sp
	lsl	-small,x
	lsl	-small,y
	lsl	0,pc
	lsl	0,sp
	lsl	0,x
	lsl	0,y
	lsl	1,sp+
	lsl	1,x+
	lsl	1,y+
	lsl	1,sp
	lsl	1,x
	lsl	1,y
	lsl	1,sp-
	lsl	1,x-
	lsl	1,y-
	lsl	125,pc
	lsl	125,sp
	lsl	125,x
	lsl	125,y
	lsl	15,sp
	lsl	15,x
	lsl	15,y
	lsl	16,sp
	lsl	16,x
	lsl	16,y
	lsl	8,sp+
	lsl	8,x+
	lsl	8,y+
	lsl	8,sp-
	lsl	8,x-
	lsl	8,y-
	lsl	a,sp
	lsl	a,x
	lsl	a,y
	lsl	b,sp
	lsl	b,x
	lsl	b,y
	lsl	d,sp
	lsl	d,x
	lsl	d,y
	lsl	dir
	lsl	ext
	lsl	ext
	lsl	ext,sp
	lsl	ext,x
	lsl	ext,y
	lsl	ind,pc
	lsl	ind,sp
	lsl	ind,x
	lsl	ind,y
	lsl	small,pc
	lsl	small,sp
	lsl	small,x
	lsl	small,y
	lsla
	lslb
	lsld
	lsr	1,+sp
	lsr	1,+x
	lsr	1,+y
	lsr	8,+sp
	lsr	8,+x
	lsr	8,+y
	lsr	,pc
	lsr	,sp
	lsr	,x
	lsr	,y
	lsr	1,-sp
	lsr	1,-x
	lsr	1,-y
	lsr	8,-sp
	lsr	8,-x
	lsr	8,-y
	lsr	-1,sp
	lsr	-1,x
	lsr	-1,y
	lsr	-16,sp
	lsr	-16,x
	lsr	-16,y
	lsr	-17,sp
	lsr	-17,x
	lsr	-17,y
	lsr	-small,pc
	lsr	-small,sp
	lsr	-small,x
	lsr	-small,y
	lsr	0,pc
	lsr	0,sp
	lsr	0,x
	lsr	0,y
	lsr	1,sp+
	lsr	1,x+
	lsr	1,y+
	lsr	1,sp
	lsr	1,x
	lsr	1,y
	lsr	1,sp-
	lsr	1,x-
	lsr	1,y-
	lsr	125,pc
	lsr	125,sp
	lsr	125,x
	lsr	125,y
	lsr	15,sp
	lsr	15,x
	lsr	15,y
	lsr	16,sp
	lsr	16,x
	lsr	16,y
	lsr	8,sp+
	lsr	8,x+
	lsr	8,y+
	lsr	8,sp-
	lsr	8,x-
	lsr	8,y-
	lsr	a,sp
	lsr	a,x
	lsr	a,y
	lsr	b,sp
	lsr	b,x
	lsr	b,y
	lsr	d,sp
	lsr	d,x
	lsr	d,y
	lsr	dir
	lsr	ext
	lsr	ext
	lsr	ext,sp
	lsr	ext,x
	lsr	ext,y
	lsr	ind,pc
	lsr	ind,sp
	lsr	ind,x
	lsr	ind,y
	lsr	small,pc
	lsr	small,sp
	lsr	small,x
	lsr	small,y

	lsrw	1,+sp	;s12x green
	lsrw	1,+x	;s12x green
	lsrw	1,+y	;s12x green
	lsrw	8,+sp	;s12x green
	lsrw	8,+x	;s12x green
	lsrw	8,+y	;s12x green
	lsrw	,pc	;s12x green
	lsrw	,sp	;s12x green
	lsrw	,x	;s12x green
	lsrw	,y	;s12x green
	lsrw	1,-sp	;s12x green
	lsrw	1,-x	;s12x green
	lsrw	1,-y	;s12x green
	lsrw	8,-sp	;s12x green
	lsrw	8,-x	;s12x green
	lsrw	8,-y	;s12x green
	lsrw	-1,sp	;s12x green
	lsrw	-1,x	;s12x green
	lsrw	-1,y	;s12x green
	lsrw	-16,sp	;s12x green
	lsrw	-16,x	;s12x green
	lsrw	-16,y	;s12x green
	lsrw	-17,sp	;s12x green
	lsrw	-17,x	;s12x green
	lsrw	-17,y	;s12x green
	lsrw	-small,pc	;s12x green
	lsrw	-small,sp	;s12x green
	lsrw	-small,x	;s12x green
	lsrw	-small,y	;s12x green
	lsrw	0,pc	;s12x green
	lsrw	0,sp	;s12x green
	lsrw	0,x	;s12x green
	lsrw	0,y	;s12x green
	lsrw	1,sp+	;s12x green
	lsrw	1,x+	;s12x green
	lsrw	1,y+	;s12x green
	lsrw	1,sp	;s12x green
	lsrw	1,x	;s12x green
	lsrw	1,y	;s12x green
	lsrw	1,sp-	;s12x green
	lsrw	1,x-	;s12x green
	lsrw	1,y-	;s12x green
	lsrw	125,pc	;s12x green
	lsrw	125,sp	;s12x green
	lsrw	125,x	;s12x green
	lsrw	125,y	;s12x green
	lsrw	15,sp	;s12x green
	lsrw	15,x	;s12x green
	lsrw	15,y	;s12x green
	lsrw	16,sp	;s12x green
	lsrw	16,x	;s12x green
	lsrw	16,y	;s12x green
	lsrw	8,sp+	;s12x green
	lsrw	8,x+	;s12x green
	lsrw	8,y+	;s12x green
	lsrw	8,sp-	;s12x green
	lsrw	8,x-	;s12x green
	lsrw	8,y-	;s12x green
	lsrw	a,sp	;s12x green
	lsrw	a,x	;s12x green
	lsrw	a,y	;s12x green
	lsrw	b,sp	;s12x green
	lsrw	b,x	;s12x green
	lsrw	b,y	;s12x green
	lsrw	d,sp	;s12x green
	lsrw	d,x	;s12x green
	lsrw	d,y	;s12x green
	lsrw	dir	;s12x green
	lsrw	ext	;s12x green
	lsrw	ext	;s12x green
	lsrw	ext,sp	;s12x green
	lsrw	ext,x	;s12x green
	lsrw	ext,y	;s12x green
	lsrw	ind,pc	;s12x green
	lsrw	ind,sp	;s12x green
	lsrw	ind,x	;s12x green
	lsrw	ind,y	;s12x green
	lsrw	small,pc	;s12x green
	lsrw	small,sp	;s12x green
	lsrw	small,x	;s12x green
	lsrw	small,y	;s12x green

	lsra
	lsrb

	lsrx		;s12x yellow
	lsry		;s12x yellow
	
	lsrd
	lsrd
	maxa	1,+sp
	maxa	1,+x
	maxa	1,+y
	maxa	8,+sp
	maxa	8,+x
	maxa	8,+y
	maxa	,pc
	maxa	,sp
	maxa	,x
	maxa	,y
	maxa	1,-sp
	maxa	1,-x
	maxa	1,-y
	maxa	8,-sp
	maxa	8,-x
	maxa	8,-y
	maxa	-1,sp
	maxa	-1,x
	maxa	-1,y
	maxa	-16,sp
	maxa	-16,x
	maxa	-16,y
	maxa	-17,sp
	maxa	-17,x
	maxa	-17,y
	maxa	-small,pc
	maxa	-small,sp
	maxa	-small,x
	maxa	-small,y
	maxa	0,pc
	maxa	0,sp
	maxa	0,x
	maxa	0,y
	maxa	1,sp+
	maxa	1,x+
	maxa	1,y+
	maxa	1,sp
	maxa	1,x
	maxa	1,y
	maxa	1,sp-
	maxa	1,x-
	maxa	1,y-
	maxa	125,pc
	maxa	125,sp
	maxa	125,x
	maxa	125,y
	maxa	15,sp
	maxa	15,x
	maxa	15,y
	maxa	16,sp
	maxa	16,x
	maxa	16,y
	maxa	8,sp+
	maxa	8,x+
	maxa	8,y+
	maxa	8,sp-
	maxa	8,x-
	maxa	8,y-
	maxa	a,sp
	maxa	a,x
	maxa	a,y
	maxa	b,sp
	maxa	b,x
	maxa	b,y
	maxa	d,sp
	maxa	d,x
	maxa	d,y
	maxa	ext,sp
	maxa	ext,x
	maxa	ext,y
	maxa	ind,pc
	maxa	ind,sp
	maxa	ind,x
	maxa	ind,y
	maxa	small,pc
	maxa	small,sp
	maxa	small,x
	maxa	small,y
	maxm	1,+sp
	maxm	1,+x
	maxm	1,+y
	maxm	8,+sp
	maxm	8,+x
	maxm	8,+y
	maxm	,pc
	maxm	,sp
	maxm	,x
	maxm	,y
	maxm	1,-sp
	maxm	1,-x
	maxm	1,-y
	maxm	8,-sp
	maxm	8,-x
	maxm	8,-y
	maxm	-1,sp
	maxm	-1,x
	maxm	-1,y
	maxm	-16,sp
	maxm	-16,x
	maxm	-16,y
	maxm	-17,sp
	maxm	-17,x
	maxm	-17,y
	maxm	-small,pc
	maxm	-small,sp
	maxm	-small,x
	maxm	-small,y
	maxm	0,pc
	maxm	0,sp
	maxm	0,x
	maxm	0,y
	maxm	1,sp+
	maxm	1,x+
	maxm	1,y+
	maxm	1,sp
	maxm	1,x
	maxm	1,y
	maxm	1,sp-
	maxm	1,x-
	maxm	1,y-
	maxm	125,pc
	maxm	125,sp
	maxm	125,x
	maxm	125,y
	maxm	15,sp
	maxm	15,x
	maxm	15,y
	maxm	16,sp
	maxm	16,x
	maxm	16,y
	maxm	8,sp+
	maxm	8,x+
	maxm	8,y+
	maxm	8,sp-
	maxm	8,x-
	maxm	8,y-
	maxm	a,sp
	maxm	a,x
	maxm	a,y
	maxm	b,sp
	maxm	b,x
	maxm	b,y
	maxm	d,sp
	maxm	d,x
	maxm	d,y
	maxm	ext,sp
	maxm	ext,x
	maxm	ext,y
	maxm	ind,pc
	maxm	ind,sp
	maxm	ind,x
	maxm	ind,y
	maxm	small,pc
	maxm	small,sp
	maxm	small,x
	maxm	small,y
	mem
	mina	1,+sp
	mina	1,+x
	mina	1,+y
	mina	8,+sp
	mina	8,+x
	mina	8,+y
	mina	,pc
	mina	,sp
	mina	,x
	mina	,y
	mina	1,-sp
	mina	1,-x
	mina	1,-y
	mina	8,-sp
	mina	8,-x
	mina	8,-y
	mina	-1,sp
	mina	-1,x
	mina	-1,y
	mina	-16,sp
	mina	-16,x
	mina	-16,y
	mina	-17,sp
	mina	-17,x
	mina	-17,y
	mina	-small,pc
	mina	-small,sp
	mina	-small,x
	mina	-small,y
	mina	0,pc
	mina	0,sp
	mina	0,x
	mina	0,y
	mina	1,sp+
	mina	1,x+
	mina	1,y+
	mina	1,sp
	mina	1,x
	mina	1,y
	mina	1,sp-
	mina	1,x-
	mina	1,y-
	mina	125,pc
	mina	125,sp
	mina	125,x
	mina	125,y
	mina	15,sp
	mina	15,x
	mina	15,y
	mina	16,sp
	mina	16,x
	mina	16,y
	mina	8,sp+
	mina	8,x+
	mina	8,y+
	mina	8,sp-
	mina	8,x-
	mina	8,y-
	mina	a,sp
	mina	a,x
	mina	a,y
	mina	b,sp
	mina	b,x
	mina	b,y
	mina	d,sp
	mina	d,x
	mina	d,y
	mina	ext,sp
	mina	ext,x
	mina	ext,y
	mina	ind,pc
	mina	ind,sp
	mina	ind,x
	mina	ind,y
	mina	small,pc
	mina	small,sp
	mina	small,x
	mina	small,y
	minm	1,+sp
	minm	1,+x
	minm	1,+y
	minm	8,+sp
	minm	8,+x
	minm	8,+y
	minm	,pc
	minm	,sp
	minm	,x
	minm	,y
	minm	1,-sp
	minm	1,-x
	minm	1,-y
	minm	8,-sp
	minm	8,-x
	minm	8,-y
	minm	-1,sp
	minm	-1,x
	minm	-1,y
	minm	-16,sp
	minm	-16,x
	minm	-16,y
	minm	-17,sp
	minm	-17,x
	minm	-17,y
	minm	-small,pc
	minm	-small,sp
	minm	-small,x
	minm	-small,y
	minm	0,pc
	minm	0,sp
	minm	0,x
	minm	0,y
	minm	1,sp+
	minm	1,x+
	minm	1,y+
	minm	1,sp
	minm	1,x
	minm	1,y
	minm	1,sp-
	minm	1,x-
	minm	1,y-
	minm	125,pc
	minm	125,sp
	minm	125,x
	minm	125,y
	minm	15,sp
	minm	15,x
	minm	15,y
	minm	16,sp
	minm	16,x
	minm	16,y
	minm	8,sp+
	minm	8,x+
	minm	8,y+
	minm	8,sp-
	minm	8,x-
	minm	8,y-
	minm	a,sp
	minm	a,x
	minm	a,y
	minm	b,sp
	minm	b,x
	minm	b,y
	minm	d,sp
	minm	d,x
	minm	d,y
	minm	ext,sp
	minm	ext,x
	minm	ext,y
	minm	ind,pc
	minm	ind,sp
	minm	ind,x
	minm	ind,y
	minm	small,pc
	minm	small,sp
	minm	small,x
	minm	small,y
	mul
	neg	1,+sp
	neg	1,+x
	neg	1,+y
	neg	8,+sp
	neg	8,+x
	neg	8,+y
	neg	,pc
	neg	,sp
	neg	,x
	neg	,y
	neg	1,-sp
	neg	1,-x
	neg	1,-y
	neg	8,-sp
	neg	8,-x
	neg	8,-y
	neg	-1,sp
	neg	-1,x
	neg	-1,y
	neg	-16,sp
	neg	-16,x
	neg	-16,y
	neg	-17,sp
	neg	-17,x
	neg	-17,y
	neg	-small,pc
	neg	-small,sp
	neg	-small,x
	neg	-small,y
	neg	0,pc
	neg	0,sp
	neg	0,x
	neg	0,y
	neg	1,sp+
	neg	1,x+
	neg	1,y+
	neg	1,sp
	neg	1,x
	neg	1,y
	neg	1,sp-
	neg	1,x-
	neg	1,y-
	neg	125,pc
	neg	125,sp
	neg	125,x
	neg	125,y
	neg	15,sp
	neg	15,x
	neg	15,y
	neg	16,sp
	neg	16,x
	neg	16,y
	neg	8,sp+
	neg	8,x+
	neg	8,y+
	neg	8,sp-
	neg	8,x-
	neg	8,y-
	neg	a,sp
	neg	a,x
	neg	a,y
	neg	b,sp
	neg	b,x
	neg	b,y
	neg	d,sp
	neg	d,x
	neg	d,y
	neg	dir
	neg	ext
	neg	ext
	neg	ext,sp
	neg	ext,x
	neg	ext,y
	neg	ind,pc
	neg	ind,sp
	neg	ind,x
	neg	ind,y
	neg	small,pc
	neg	small,sp
	neg	small,x
	neg	small,y

	negw	1,+sp	;s12x green
	negw	1,+x	;s12x green
	negw	1,+y	;s12x green
	negw	8,+sp	;s12x green
	negw	8,+x	;s12x green
	negw	8,+y	;s12x green
	negw	,pc	;s12x green
	negw	,sp	;s12x green
	negw	,x	;s12x green
	negw	,y	;s12x green
	negw	1,-sp	;s12x green
	negw	1,-x	;s12x green
	negw	1,-y	;s12x green
	negw	8,-sp	;s12x green
	negw	8,-x	;s12x green
	negw	8,-y	;s12x green
	negw	-1,sp	;s12x green
	negw	-1,x	;s12x green
	negw	-1,y	;s12x green
	negw	-16,sp	;s12x green
	negw	-16,x	;s12x green
	negw	-16,y	;s12x green
	negw	-17,sp	;s12x green
	negw	-17,x	;s12x green
	negw	-17,y	;s12x green
	negw	-small,pc	;s12x green
	negw	-small,sp	;s12x green
	negw	-small,x	;s12x green
	negw	-small,y	;s12x green
	negw	0,pc	;s12x green
	negw	0,sp	;s12x green
	negw	0,x	;s12x green
	negw	0,y	;s12x green
	negw	1,sp+	;s12x green
	negw	1,x+	;s12x green
	negw	1,y+	;s12x green
	negw	1,sp	;s12x green
	negw	1,x	;s12x green
	negw	1,y	;s12x green
	negw	1,sp-	;s12x green
	negw	1,x-	;s12x green
	negw	1,y-	;s12x green
	negw	125,pc	;s12x green
	negw	125,sp	;s12x green
	negw	125,x	;s12x green
	negw	125,y	;s12x green
	negw	15,sp	;s12x green
	negw	15,x	;s12x green
	negw	15,y	;s12x green
	negw	16,sp	;s12x green
	negw	16,x	;s12x green
	negw	16,y	;s12x green
	negw	8,sp+	;s12x green
	negw	8,x+	;s12x green
	negw	8,y+	;s12x green
	negw	8,sp-	;s12x green
	negw	8,x-	;s12x green
	negw	8,y-	;s12x green
	negw	a,sp	;s12x green
	negw	a,x	;s12x green
	negw	a,y	;s12x green
	negw	b,sp	;s12x green
	negw	b,x	;s12x green
	negw	b,y	;s12x green
	negw	d,sp	;s12x green
	negw	d,x	;s12x green
	negw	d,y	;s12x green
	negw	dir	;s12x green
	negw	ext	;s12x green
	negw	ext	;s12x green
	negw	ext,sp	;s12x green
	negw	ext,x	;s12x green
	negw	ext,y	;s12x green
	negw	ind,pc	;s12x green
	negw	ind,sp	;s12x green
	negw	ind,x	;s12x green
	negw	ind,y	;s12x green
	negw	small,pc	;s12x green
	negw	small,sp	;s12x green
	negw	small,x	;s12x green
	negw	small,y	;s12x green

	nega
	negb

	negx		;s12x yellow
	negy		;s12x yellow

	nop
	oraa	#immed
	oraa	1,+sp
	oraa	1,+x
	oraa	1,+y
	oraa	8,+sp
	oraa	8,+x
	oraa	8,+y
	oraa	,pc
	oraa	,sp
	oraa	,x
	oraa	,y
	oraa	1,-sp
	oraa	1,-x
	oraa	1,-y
	oraa	8,-sp
	oraa	8,-x
	oraa	8,-y
	oraa	-1,sp
	oraa	-1,x
	oraa	-1,y
	oraa	-16,sp
	oraa	-16,x
	oraa	-16,y
	oraa	-17,sp
	oraa	-17,x
	oraa	-17,y
	oraa	-small,pc
	oraa	-small,sp
	oraa	-small,x
	oraa	-small,y
	oraa	0,pc
	oraa	0,sp
	oraa	0,x
	oraa	0,y
	oraa	1,sp+
	oraa	1,x+
	oraa	1,y+
	oraa	1,sp
	oraa	1,x
	oraa	1,y
	oraa	1,sp-
	oraa	1,x-
	oraa	1,y-
	oraa	125,pc
	oraa	125,sp
	oraa	125,x
	oraa	125,y
	oraa	15,sp
	oraa	15,x
	oraa	15,y
	oraa	16,sp
	oraa	16,x
	oraa	16,y
	oraa	8,sp+
	oraa	8,x+
	oraa	8,y+
	oraa	8,sp-
	oraa	8,x-
	oraa	8,y-
	oraa	a,sp
	oraa	a,x
	oraa	a,y
	oraa	b,sp
	oraa	b,x
	oraa	b,y
	oraa	d,sp
	oraa	d,x
	oraa	d,y
	oraa	dir
	oraa	dir
	oraa	ext
	oraa	ext
	oraa	ext,sp
	oraa	ext,x
	oraa	ext,y
	oraa	ind,pc
	oraa	ind,sp
	oraa	ind,x
	oraa	ind,y
	oraa	small,pc
	oraa	small,sp
	oraa	small,x
	oraa	small,y

	orx	#immed	;s12x yellow
	orx	1,+sp	;s12x yellow
	orx	1,+x	;s12x yellow
	orx	1,+y	;s12x yellow
	orx	8,+sp	;s12x yellow
	orx	8,+x	;s12x yellow
	orx	8,+y	;s12x yellow
	orx	,pc	;s12x yellow
	orx	,sp	;s12x yellow
	orx	,x	;s12x yellow
	orx	,y	;s12x yellow
	orx	1,-sp	;s12x yellow
	orx	1,-x	;s12x yellow
	orx	1,-y	;s12x yellow
	orx	8,-sp	;s12x yellow
	orx	8,-x	;s12x yellow
	orx	8,-y	;s12x yellow
	orx	-1,sp	;s12x yellow
	orx	-1,x	;s12x yellow
	orx	-1,y	;s12x yellow
	orx	-16,sp	;s12x yellow
	orx	-16,x	;s12x yellow
	orx	-16,y	;s12x yellow
	orx	-17,sp	;s12x yellow
	orx	-17,x	;s12x yellow
	orx	-17,y	;s12x yellow
	orx	-small,pc	;s12x yellow
	orx	-small,sp	;s12x yellow
	orx	-small,x	;s12x yellow
	orx	-small,y	;s12x yellow
	orx	0,pc	;s12x yellow
	orx	0,sp	;s12x yellow
	orx	0,x	;s12x yellow
	orx	0,y	;s12x yellow
	orx	1,sp+	;s12x yellow
	orx	1,x+	;s12x yellow
	orx	1,y+	;s12x yellow
	orx	1,sp	;s12x yellow
	orx	1,x	;s12x yellow
	orx	1,y	;s12x yellow
	orx	1,sp-	;s12x yellow
	orx	1,x-	;s12x yellow
	orx	1,y-	;s12x yellow
	orx	125,pc	;s12x yellow
	orx	125,sp	;s12x yellow
	orx	125,x	;s12x yellow
	orx	125,y	;s12x yellow
	orx	15,sp	;s12x yellow
	orx	15,x	;s12x yellow
	orx	15,y	;s12x yellow
	orx	16,sp	;s12x yellow
	orx	16,x	;s12x yellow
	orx	16,y	;s12x yellow
	orx	8,sp+	;s12x yellow
	orx	8,x+	;s12x yellow
	orx	8,y+	;s12x yellow
	orx	8,sp-	;s12x yellow
	orx	8,x-	;s12x yellow
	orx	8,y-	;s12x yellow
	orx	a,sp	;s12x yellow
	orx	a,x	;s12x yellow
	orx	a,y	;s12x yellow
	orx	b,sp	;s12x yellow
	orx	b,x	;s12x yellow
	orx	b,y	;s12x yellow
	orx	d,sp	;s12x yellow
	orx	d,x	;s12x yellow
	orx	d,y	;s12x yellow
	orx	dir	;s12x yellow
	orx	dir	;s12x yellow
	orx	ext	;s12x yellow
	orx	ext	;s12x yellow
	orx	ext,sp	;s12x yellow
	orx	ext,x	;s12x yellow
	orx	ext,y	;s12x yellow
	orx	ind,pc	;s12x yellow
	orx	ind,sp	;s12x yellow
	orx	ind,x	;s12x yellow
	orx	ind,y	;s12x yellow
	orx	small,pc	;s12x yellow
	orx	small,sp	;s12x yellow
	orx	small,x	;s12x yellow
	orx	small,y	;s12x yellow

	ory	#immed	;s12x yellow
	ory	1,+sp	;s12x yellow
	ory	1,+x	;s12x yellow
	ory	1,+y	;s12x yellow
	ory	8,+sp	;s12x yellow
	ory	8,+x	;s12x yellow
	ory	8,+y	;s12x yellow
	ory	,pc	;s12x yellow
	ory	,sp	;s12x yellow
	ory	,x	;s12x yellow
	ory	,y	;s12x yellow
	ory	1,-sp	;s12x yellow
	ory	1,-x	;s12x yellow
	ory	1,-y	;s12x yellow
	ory	8,-sp	;s12x yellow
	ory	8,-x	;s12x yellow
	ory	8,-y	;s12x yellow
	ory	-1,sp	;s12x yellow
	ory	-1,x	;s12x yellow
	ory	-1,y	;s12x yellow
	ory	-16,sp	;s12x yellow
	ory	-16,x	;s12x yellow
	ory	-16,y	;s12x yellow
	ory	-17,sp	;s12x yellow
	ory	-17,x	;s12x yellow
	ory	-17,y	;s12x yellow
	ory	-small,pc	;s12x yellow
	ory	-small,sp	;s12x yellow
	ory	-small,x	;s12x yellow
	ory	-small,y	;s12x yellow
	ory	0,pc	;s12x yellow
	ory	0,sp	;s12x yellow
	ory	0,x	;s12x yellow
	ory	0,y	;s12x yellow
	ory	1,sp+	;s12x yellow
	ory	1,x+	;s12x yellow
	ory	1,y+	;s12x yellow
	ory	1,sp	;s12x yellow
	ory	1,x	;s12x yellow
	ory	1,y	;s12x yellow
	ory	1,sp-	;s12x yellow
	ory	1,x-	;s12x yellow
	ory	1,y-	;s12x yellow
	ory	125,pc	;s12x yellow
	ory	125,sp	;s12x yellow
	ory	125,x	;s12x yellow
	ory	125,y	;s12x yellow
	ory	15,sp	;s12x yellow
	ory	15,x	;s12x yellow
	ory	15,y	;s12x yellow
	ory	16,sp	;s12x yellow
	ory	16,x	;s12x yellow
	ory	16,y	;s12x yellow
	ory	8,sp+	;s12x yellow
	ory	8,x+	;s12x yellow
	ory	8,y+	;s12x yellow
	ory	8,sp-	;s12x yellow
	ory	8,x-	;s12x yellow
	ory	8,y-	;s12x yellow
	ory	a,sp	;s12x yellow
	ory	a,x	;s12x yellow
	ory	a,y	;s12x yellow
	ory	b,sp	;s12x yellow
	ory	b,x	;s12x yellow
	ory	b,y	;s12x yellow
	ory	d,sp	;s12x yellow
	ory	d,x	;s12x yellow
	ory	d,y	;s12x yellow
	ory	dir	;s12x yellow
	ory	dir	;s12x yellow
	ory	ext	;s12x yellow
	ory	ext	;s12x yellow
	ory	ext,sp	;s12x yellow
	ory	ext,x	;s12x yellow
	ory	ext,y	;s12x yellow
	ory	ind,pc	;s12x yellow
	ory	ind,sp	;s12x yellow
	ory	ind,x	;s12x yellow
	ory	ind,y	;s12x yellow
	ory	small,pc	;s12x yellow
	ory	small,sp	;s12x yellow
	ory	small,x	;s12x yellow
	ory	small,y	;s12x yellow

	orcc	#immed
	psha
	pshb
	pshd
	pshx
	pshy
	pula
	pulb
	pulc

	pulcw		;s12x dark blue

	puld
	pulx
	puly
	rev
	rol	1,+sp
	rol	1,+x
	rol	1,+y
	rol	8,+sp
	rol	8,+x
	rol	8,+y
	rol	,pc
	rol	,sp
	rol	,x
	rol	,y
	rol	1,-sp
	rol	1,-x
	rol	1,-y
	rol	8,-sp
	rol	8,-x
	rol	8,-y
	rol	-1,sp
	rol	-1,x
	rol	-1,y
	rol	-16,sp
	rol	-16,x
	rol	-16,y
	rol	-17,sp
	rol	-17,x
	rol	-17,y
	rol	-small,pc
	rol	-small,sp
	rol	-small,x
	rol	-small,y
	rol	0,pc
	rol	0,sp
	rol	0,x
	rol	0,y
	rol	1,sp+
	rol	1,x+
	rol	1,y+
	rol	1,sp
	rol	1,x
	rol	1,y
	rol	1,sp-
	rol	1,x-
	rol	1,y-
	rol	125,pc
	rol	125,sp
	rol	125,x
	rol	125,y
	rol	15,sp
	rol	15,x
	rol	15,y
	rol	16,sp
	rol	16,x
	rol	16,y
	rol	8,sp+
	rol	8,x+
	rol	8,y+
	rol	8,sp-
	rol	8,x-
	rol	8,y-
	rol	a,sp
	rol	a,x
	rol	a,y
	rol	b,sp
	rol	b,x
	rol	b,y
	rol	d,sp
	rol	d,x
	rol	d,y
	rol	dir
	rol	ext
	rol	ext
	rol	ext,sp
	rol	ext,x
	rol	ext,y
	rol	ind,pc
	rol	ind,sp
	rol	ind,x
	rol	ind,y
	rol	small,pc
	rol	small,sp
	rol	small,x
	rol	small,y

	rolw	1,+sp	;s12x green
	rolw	1,+x	;s12x green
	rolw	1,+y	;s12x green
	rolw	8,+sp	;s12x green
	rolw	8,+x	;s12x green
	rolw	8,+y	;s12x green
	rolw	,pc	;s12x green
	rolw	,sp	;s12x green
	rolw	,x	;s12x green
	rolw	,y	;s12x green
	rolw	1,-sp	;s12x green
	rolw	1,-x	;s12x green
	rolw	1,-y	;s12x green
	rolw	8,-sp	;s12x green
	rolw	8,-x	;s12x green
	rolw	8,-y	;s12x green
	rolw	-1,sp	;s12x green
	rolw	-1,x	;s12x green
	rolw	-1,y	;s12x green
	rolw	-16,sp	;s12x green
	rolw	-16,x	;s12x green
	rolw	-16,y	;s12x green
	rolw	-17,sp	;s12x green
	rolw	-17,x	;s12x green
	rolw	-17,y	;s12x green
	rolw	-small,pc	;s12x green
	rolw	-small,sp	;s12x green
	rolw	-small,x	;s12x green
	rolw	-small,y	;s12x green
	rolw	0,pc	;s12x green
	rolw	0,sp	;s12x green
	rolw	0,x	;s12x green
	rolw	0,y	;s12x green
	rolw	1,sp+	;s12x green
	rolw	1,x+	;s12x green
	rolw	1,y+	;s12x green
	rolw	1,sp	;s12x green
	rolw	1,x	;s12x green
	rolw	1,y	;s12x green
	rolw	1,sp-	;s12x green
	rolw	1,x-	;s12x green
	rolw	1,y-	;s12x green
	rolw	125,pc	;s12x green
	rolw	125,sp	;s12x green
	rolw	125,x	;s12x green
	rolw	125,y	;s12x green
	rolw	15,sp	;s12x green
	rolw	15,x	;s12x green
	rolw	15,y	;s12x green
	rolw	16,sp	;s12x green
	rolw	16,x	;s12x green
	rolw	16,y	;s12x green
	rolw	8,sp+	;s12x green
	rolw	8,x+	;s12x green
	rolw	8,y+	;s12x green
	rolw	8,sp-	;s12x green
	rolw	8,x-	;s12x green
	rolw	8,y-	;s12x green
	rolw	a,sp	;s12x green
	rolw	a,x	;s12x green
	rolw	a,y	;s12x green
	rolw	b,sp	;s12x green
	rolw	b,x	;s12x green
	rolw	b,y	;s12x green
	rolw	d,sp	;s12x green
	rolw	d,x	;s12x green
	rolw	d,y	;s12x green
	rolw	dir	;s12x green
	rolw	ext	;s12x green
	rolw	ext	;s12x green
	rolw	ext,sp	;s12x green
	rolw	ext,x	;s12x green
	rolw	ext,y	;s12x green
	rolw	ind,pc	;s12x green
	rolw	ind,sp	;s12x green
	rolw	ind,x	;s12x green
	rolw	ind,y	;s12x green
	rolw	small,pc	;s12x green
	rolw	small,sp	;s12x green
	rolw	small,x	;s12x green
	rolw	small,y	;s12x green

	rola
	rolb

	rolx		;s12x yellow
	roly		;s12x yellow

	ror	1,+sp
	ror	1,+x
	ror	1,+y
	ror	8,+sp
	ror	8,+x
	ror	8,+y
	ror	,pc
	ror	,sp
	ror	,x
	ror	,y
	ror	1,-sp
	ror	1,-x
	ror	1,-y
	ror	8,-sp
	ror	8,-x
	ror	8,-y
	ror	-1,sp
	ror	-1,x
	ror	-1,y
	ror	-16,sp
	ror	-16,x
	ror	-16,y
	ror	-17,sp
	ror	-17,x
	ror	-17,y
	ror	-small,pc
	ror	-small,sp
	ror	-small,x
	ror	-small,y
	ror	0,pc
	ror	0,sp
	ror	0,x
	ror	0,y
	ror	1,sp+
	ror	1,x+
	ror	1,y+
	ror	1,sp
	ror	1,x
	ror	1,y
	ror	1,sp-
	ror	1,x-
	ror	1,y-
	ror	125,pc
	ror	125,sp
	ror	125,x
	ror	125,y
	ror	15,sp
	ror	15,x
	ror	15,y
	ror	16,sp
	ror	16,x
	ror	16,y
	ror	8,sp+
	ror	8,x+
	ror	8,y+
	ror	8,sp-
	ror	8,x-
	ror	8,y-
	ror	a,sp
	ror	a,x
	ror	a,y
	ror	b,sp
	ror	b,x
	ror	b,y
	ror	d,sp
	ror	d,x
	ror	d,y
	ror	dir
	ror	ext
	ror	ext
	ror	ext,sp
	ror	ext,x
	ror	ext,y
	ror	ind,pc
	ror	ind,sp
	ror	ind,x
	ror	ind,y
	ror	small,pc
	ror	small,sp
	ror	small,x
	ror	small,y

	rorw	1,+sp	;s12x green
	rorw	1,+x	;s12x green
	rorw	1,+y	;s12x green
	rorw	8,+sp	;s12x green
	rorw	8,+x	;s12x green
	rorw	8,+y	;s12x green
	rorw	,pc	;s12x green
	rorw	,sp	;s12x green
	rorw	,x	;s12x green
	rorw	,y	;s12x green
	rorw	1,-sp	;s12x green
	rorw	1,-x	;s12x green
	rorw	1,-y	;s12x green
	rorw	8,-sp	;s12x green
	rorw	8,-x	;s12x green
	rorw	8,-y	;s12x green
	rorw	-1,sp	;s12x green
	rorw	-1,x	;s12x green
	rorw	-1,y	;s12x green
	rorw	-16,sp	;s12x green
	rorw	-16,x	;s12x green
	rorw	-16,y	;s12x green
	rorw	-17,sp	;s12x green
	rorw	-17,x	;s12x green
	rorw	-17,y	;s12x green
	rorw	-small,pc	;s12x green
	rorw	-small,sp	;s12x green
	rorw	-small,x	;s12x green
	rorw	-small,y	;s12x green
	rorw	0,pc	;s12x green
	rorw	0,sp	;s12x green
	rorw	0,x	;s12x green
	rorw	0,y	;s12x green
	rorw	1,sp+	;s12x green
	rorw	1,x+	;s12x green
	rorw	1,y+	;s12x green
	rorw	1,sp	;s12x green
	rorw	1,x	;s12x green
	rorw	1,y	;s12x green
	rorw	1,sp-	;s12x green
	rorw	1,x-	;s12x green
	rorw	1,y-	;s12x green
	rorw	125,pc	;s12x green
	rorw	125,sp	;s12x green
	rorw	125,x	;s12x green
	rorw	125,y	;s12x green
	rorw	15,sp	;s12x green
	rorw	15,x	;s12x green
	rorw	15,y	;s12x green
	rorw	16,sp	;s12x green
	rorw	16,x	;s12x green
	rorw	16,y	;s12x green
	rorw	8,sp+	;s12x green
	rorw	8,x+	;s12x green
	rorw	8,y+	;s12x green
	rorw	8,sp-	;s12x green
	rorw	8,x-	;s12x green
	rorw	8,y-	;s12x green
	rorw	a,sp	;s12x green
	rorw	a,x	;s12x green
	rorw	a,y	;s12x green
	rorw	b,sp	;s12x green
	rorw	b,x	;s12x green
	rorw	b,y	;s12x green
	rorw	d,sp	;s12x green
	rorw	d,x	;s12x green
	rorw	d,y	;s12x green
	rorw	dir	;s12x green
	rorw	ext	;s12x green
	rorw	ext	;s12x green
	rorw	ext,sp	;s12x green
	rorw	ext,x	;s12x green
	rorw	ext,y	;s12x green
	rorw	ind,pc	;s12x green
	rorw	ind,sp	;s12x green
	rorw	ind,x	;s12x green
	rorw	ind,y	;s12x green
	rorw	small,pc	;s12x green
	rorw	small,sp	;s12x green
	rorw	small,x	;s12x green
	rorw	small,y	;s12x green

	rora
	rorb

	rorx		;s12x yellow
	rory		;s12x yellow

	rti
	rts
	sba
	sbca	#immed
	sbca	1,+sp
	sbca	1,+x
	sbca	1,+y
	sbca	8,+sp
	sbca	8,+x
	sbca	8,+y
	sbca	,pc
	sbca	,sp
	sbca	,x
	sbca	,y
	sbca	1,-sp
	sbca	1,-x
	sbca	1,-y
	sbca	8,-sp
	sbca	8,-x
	sbca	8,-y
	sbca	-1,sp
	sbca	-1,x
	sbca	-1,y
	sbca	-16,sp
	sbca	-16,x
	sbca	-16,y
	sbca	-17,sp
	sbca	-17,x
	sbca	-17,y
	sbca	-small,pc
	sbca	-small,sp
	sbca	-small,x
	sbca	-small,y
	sbca	0,pc
	sbca	0,sp
	sbca	0,x
	sbca	0,y
	sbca	1,sp+
	sbca	1,x+
	sbca	1,y+
	sbca	1,sp
	sbca	1,x
	sbca	1,y
	sbca	1,sp-
	sbca	1,x-
	sbca	1,y-
	sbca	125,pc
	sbca	125,sp
	sbca	125,x
	sbca	125,y
	sbca	15,sp
	sbca	15,x
	sbca	15,y
	sbca	16,sp
	sbca	16,x
	sbca	16,y
	sbca	8,sp+
	sbca	8,x+
	sbca	8,y+
	sbca	8,sp-
	sbca	8,x-
	sbca	8,y-
	sbca	a,sp
	sbca	a,x
	sbca	a,y
	sbca	b,sp
	sbca	b,x
	sbca	b,y
	sbca	d,sp
	sbca	d,x
	sbca	d,y
	sbca	dir
	sbca	dir
	sbca	ext
	sbca	ext
	sbca	ext,sp
	sbca	ext,x
	sbca	ext,y
	sbca	ind,pc
	sbca	ind,sp
	sbca	ind,x
	sbca	ind,y
	sbca	small,pc
	sbca	small,sp
	sbca	small,x
	sbca	small,y
	
	sbex	#immed	;s12x yellow
	sbex	1,+sp	;s12x yellow
	sbex	1,+x	;s12x yellow
	sbex	1,+y	;s12x yellow
	sbex	8,+sp	;s12x yellow
	sbex	8,+x	;s12x yellow
	sbex	8,+y	;s12x yellow
	sbex	,pc	;s12x yellow
	sbex	,sp	;s12x yellow
	sbex	,x	;s12x yellow
	sbex	,y	;s12x yellow
	sbex	1,-sp	;s12x yellow
	sbex	1,-x	;s12x yellow
	sbex	1,-y	;s12x yellow
	sbex	8,-sp	;s12x yellow
	sbex	8,-x	;s12x yellow
	sbex	8,-y	;s12x yellow
	sbex	-1,sp	;s12x yellow
	sbex	-1,x	;s12x yellow
	sbex	-1,y	;s12x yellow
	sbex	-16,sp	;s12x yellow
	sbex	-16,x	;s12x yellow
	sbex	-16,y	;s12x yellow
	sbex	-17,sp	;s12x yellow
	sbex	-17,x	;s12x yellow
	sbex	-17,y	;s12x yellow
	sbex	-small,pc	;s12x yellow
	sbex	-small,sp	;s12x yellow
	sbex	-small,x	;s12x yellow
	sbex	-small,y	;s12x yellow
	sbex	0,pc	;s12x yellow
	sbex	0,sp	;s12x yellow
	sbex	0,x	;s12x yellow
	sbex	0,y	;s12x yellow
	sbex	1,sp+	;s12x yellow
	sbex	1,x+	;s12x yellow
	sbex	1,y+	;s12x yellow
	sbex	1,sp	;s12x yellow
	sbex	1,x	;s12x yellow
	sbex	1,y	;s12x yellow
	sbex	1,sp-	;s12x yellow
	sbex	1,x-	;s12x yellow
	sbex	1,y-	;s12x yellow
	sbex	125,pc	;s12x yellow
	sbex	125,sp	;s12x yellow
	sbex	125,x	;s12x yellow
	sbex	125,y	;s12x yellow
	sbex	15,sp	;s12x yellow
	sbex	15,x	;s12x yellow
	sbex	15,y	;s12x yellow
	sbex	16,sp	;s12x yellow
	sbex	16,x	;s12x yellow
	sbex	16,y	;s12x yellow
	sbex	8,sp+	;s12x yellow
	sbex	8,x+	;s12x yellow
	sbex	8,y+	;s12x yellow
	sbex	8,sp-	;s12x yellow
	sbex	8,x-	;s12x yellow
	sbex	8,y-	;s12x yellow
	sbex	a,sp	;s12x yellow
	sbex	a,x	;s12x yellow
	sbex	a,y	;s12x yellow
	sbex	b,sp	;s12x yellow
	sbex	b,x	;s12x yellow
	sbex	b,y	;s12x yellow
	sbex	d,sp	;s12x yellow
	sbex	d,x	;s12x yellow
	sbex	d,y	;s12x yellow
	sbex	dir	;s12x yellow
	sbex	dir	;s12x yellow
	sbex	ext	;s12x yellow
	sbex	ext	;s12x yellow
	sbex	ext,sp	;s12x yellow
	sbex	ext,x	;s12x yellow
	sbex	ext,y	;s12x yellow
	sbex	ind,pc	;s12x yellow
	sbex	ind,sp	;s12x yellow
	sbex	ind,x	;s12x yellow
	sbex	ind,y	;s12x yellow
	sbex	small,pc	;s12x yellow
	sbex	small,sp	;s12x yellow
	sbex	small,x	;s12x yellow
	sbex	small,y	;s12x yellow
	
	sbcb	#immed
	sbcb	1,+sp
	sbcb	1,+x
	sbcb	1,+y
	sbcb	8,+sp
	sbcb	8,+x
	sbcb	8,+y
	sbcb	,pc
	sbcb	,sp
	sbcb	,x
	sbcb	,y
	sbcb	1,-sp
	sbcb	1,-x
	sbcb	1,-y
	sbcb	8,-sp
	sbcb	8,-x
	sbcb	8,-y
	sbcb	-1,sp
	sbcb	-1,x
	sbcb	-1,y
	sbcb	-16,sp
	sbcb	-16,x
	sbcb	-16,y
	sbcb	-17,sp
	sbcb	-17,x
	sbcb	-17,y
	sbcb	-small,pc
	sbcb	-small,sp
	sbcb	-small,x
	sbcb	-small,y
	sbcb	0,pc
	sbcb	0,sp
	sbcb	0,x
	sbcb	0,y
	sbcb	1,sp+
	sbcb	1,x+
	sbcb	1,y+
	sbcb	1,sp
	sbcb	1,x
	sbcb	1,y
	sbcb	1,sp-
	sbcb	1,x-
	sbcb	1,y-
	sbcb	125,pc
	sbcb	125,sp
	sbcb	125,x
	sbcb	125,y
	sbcb	15,sp
	sbcb	15,x
	sbcb	15,y
	sbcb	16,sp
	sbcb	16,x
	sbcb	16,y
	sbcb	8,sp+
	sbcb	8,x+
	sbcb	8,y+
	sbcb	8,sp-
	sbcb	8,x-
	sbcb	8,y-
	sbcb	a,sp
	sbcb	a,x
	sbcb	a,y
	sbcb	b,sp
	sbcb	b,x
	sbcb	b,y
	sbcb	d,sp
	sbcb	d,x
	sbcb	d,y
	sbcb	dir
	sbcb	dir
	sbcb	ext
	sbcb	ext
	sbcb	ext,sp
	sbcb	ext,x
	sbcb	ext,y
	sbcb	ind,pc
	sbcb	ind,sp
	sbcb	ind,x
	sbcb	ind,y
	sbcb	small,pc
	sbcb	small,sp
	sbcb	small,x
	sbcb	small,y

	sbey	#immed	;s12x yellow
	sbey	1,+sp	;s12x yellow
	sbey	1,+x	;s12x yellow
	sbey	1,+y	;s12x yellow
	sbey	8,+sp	;s12x yellow
	sbey	8,+x	;s12x yellow
	sbey	8,+y	;s12x yellow
	sbey	,pc	;s12x yellow
	sbey	,sp	;s12x yellow
	sbey	,x	;s12x yellow
	sbey	,y	;s12x yellow
	sbey	1,-sp	;s12x yellow
	sbey	1,-x	;s12x yellow
	sbey	1,-y	;s12x yellow
	sbey	8,-sp	;s12x yellow
	sbey	8,-x	;s12x yellow
	sbey	8,-y	;s12x yellow
	sbey	-1,sp	;s12x yellow
	sbey	-1,x	;s12x yellow
	sbey	-1,y	;s12x yellow
	sbey	-16,sp	;s12x yellow
	sbey	-16,x	;s12x yellow
	sbey	-16,y	;s12x yellow
	sbey	-17,sp	;s12x yellow
	sbey	-17,x	;s12x yellow
	sbey	-17,y	;s12x yellow
	sbey	-small,pc	;s12x yellow
	sbey	-small,sp	;s12x yellow
	sbey	-small,x	;s12x yellow
	sbey	-small,y	;s12x yellow
	sbey	0,pc	;s12x yellow
	sbey	0,sp	;s12x yellow
	sbey	0,x	;s12x yellow
	sbey	0,y	;s12x yellow
	sbey	1,sp+	;s12x yellow
	sbey	1,x+	;s12x yellow
	sbey	1,y+	;s12x yellow
	sbey	1,sp	;s12x yellow
	sbey	1,x	;s12x yellow
	sbey	1,y	;s12x yellow
	sbey	1,sp-	;s12x yellow
	sbey	1,x-	;s12x yellow
	sbey	1,y-	;s12x yellow
	sbey	125,pc	;s12x yellow
	sbey	125,sp	;s12x yellow
	sbey	125,x	;s12x yellow
	sbey	125,y	;s12x yellow
	sbey	15,sp	;s12x yellow
	sbey	15,x	;s12x yellow
	sbey	15,y	;s12x yellow
	sbey	16,sp	;s12x yellow
	sbey	16,x	;s12x yellow
	sbey	16,y	;s12x yellow
	sbey	8,sp+	;s12x yellow
	sbey	8,x+	;s12x yellow
	sbey	8,y+	;s12x yellow
	sbey	8,sp-	;s12x yellow
	sbey	8,x-	;s12x yellow
	sbey	8,y-	;s12x yellow
	sbey	a,sp	;s12x yellow
	sbey	a,x	;s12x yellow
	sbey	a,y	;s12x yellow
	sbey	b,sp	;s12x yellow
	sbey	b,x	;s12x yellow
	sbey	b,y	;s12x yellow
	sbey	d,sp	;s12x yellow
	sbey	d,x	;s12x yellow
	sbey	d,y	;s12x yellow
	sbey	dir	;s12x yellow
	sbey	dir	;s12x yellow
	sbey	ext	;s12x yellow
	sbey	ext	;s12x yellow
	sbey	ext,sp	;s12x yellow
	sbey	ext,x	;s12x yellow
	sbey	ext,y	;s12x yellow
	sbey	ind,pc	;s12x yellow
	sbey	ind,sp	;s12x yellow
	sbey	ind,x	;s12x yellow
	sbey	ind,y	;s12x yellow
	sbey	small,pc	;s12x yellow
	sbey	small,sp	;s12x yellow
	sbey	small,x	;s12x yellow
	sbey	small,y	;s12x yellow

	sec
	sei
	sev
	sex	a d
	sex	a sp
	sex	a,sp
	sex	a x
	sex	a,x
	sex	a y
	sex	a,y
	sex	b d
	sex	b sp
	sex	b,sp
	sex	b x
	sex	b,x
	sex	b y
	sex	b,y
	sex	ccr d
	sex	ccr sp
	sex	ccr x
	sex	ccr y
	staa	1,+sp
	staa	1,+x
	staa	1,+y
	staa	8,+sp
	staa	8,+x
	staa	8,+y
	staa	,pc
	staa	,sp
	staa	,x
	staa	,y
	staa	1,-sp
	staa	1,-x
	staa	1,-y
	staa	8,-sp
	staa	8,-x
	staa	8,-y
	staa	-1,sp
	staa	-1,x
	staa	-1,y
	staa	-16,sp
	staa	-16,x
	staa	-16,y
	staa	-17,sp
	staa	-17,x
	staa	-17,y
	staa	-small,pc
	staa	-small,sp
	staa	-small,x
	staa	-small,y
	staa	0,pc
	staa	0,sp
	staa	0,x
	staa	0,y
	staa	1,sp+
	staa	1,x+
	staa	1,y+
	staa	1,sp
	staa	1,x
	staa	1,y
	staa	1,sp-
	staa	1,x-
	staa	1,y-
	staa	125,pc
	staa	125,sp
	staa	125,x
	staa	125,y
	staa	15,sp
	staa	15,x
	staa	15,y
	staa	16,sp
	staa	16,x
	staa	16,y
	staa	8,sp+
	staa	8,x+
	staa	8,y+
	staa	8,sp-
	staa	8,x-
	staa	8,y-
	staa	a,sp
	staa	a,x
	staa	a,y
	staa	b,sp
	staa	b,x
	staa	b,y
	staa	d,sp
	staa	d,x
	staa	d,y
	staa	dir
	staa	dir
	staa	ext
	staa	ext
	staa	ext,sp
	staa	ext,x
	staa	ext,y
	staa	ind,pc
	staa	ind,sp
	staa	ind,x
	staa	ind,y
	staa	small,pc
	staa	small,sp
	staa	small,x
	staa	small,y
	stab	1,+sp
	stab	1,+x
	stab	1,+y
	stab	8,+sp
	stab	8,+x
	stab	8,+y
	stab	,pc
	stab	,sp
	stab	,x
	stab	,y
	stab	1,-sp
	stab	1,-x
	stab	1,-y
	stab	8,-sp
	stab	8,-x
	stab	8,-y
	stab	-1,sp
	stab	-1,x
	stab	-1,y
	stab	-16,sp
	stab	-16,x
	stab	-16,y
	stab	-17,sp
	stab	-17,x
	stab	-17,y
	stab	-small,pc
	stab	-small,sp
	stab	-small,x
	stab	-small,y
	stab	0,pc
	stab	0,sp
	stab	0,x
	stab	0,y
	stab	1,sp+
	stab	1,x+
	stab	1,y+
	stab	1,sp
	stab	1,x
	stab	1,y
	stab	1,sp-
	stab	1,x-
	stab	1,y-
	stab	125,pc
	stab	125,sp
	stab	125,x
	stab	125,y
	stab	15,sp
	stab	15,x
	stab	15,y
	stab	16,sp
	stab	16,x
	stab	16,y
	stab	8,sp+
	stab	8,x+
	stab	8,y+
	stab	8,sp-
	stab	8,x-
	stab	8,y-
	stab	a,sp
	stab	a,x
	stab	a,y
	stab	b,sp
	stab	b,x
	stab	b,y
	stab	d,sp
	stab	d,x
	stab	d,y
	stab	dir
	stab	dir
	stab	ext
	stab	ext
	stab	ext,sp
	stab	ext,x
	stab	ext,y
	stab	ind,pc
	stab	ind,sp
	stab	ind,x
	stab	ind,y
	stab	small,pc
	stab	small,sp
	stab	small,x
	stab	small,y
	std	1,+sp
	std	1,+x
	std	1,+y
	std	8,+sp
	std	8,+x
	std	8,+y
	std	,pc
	std	,sp
	std	,x
	std	,y
	std	1,-sp
	std	1,-x
	std	1,-y
	std	8,-sp
	std	8,-x
	std	8,-y
	std	-1,sp
	std	-1,x
	std	-1,y
	std	-16,sp
	std	-16,x
	std	-16,y
	std	-17,sp
	std	-17,x
	std	-17,y
	std	-small,pc
	std	-small,sp
	std	-small,x
	std	-small,y
	std	0,pc
	std	0,sp
	std	0,x
	std	0,y
	std	1,sp+
	std	1,x+
	std	1,y+
	std	1,sp
	std	1,x
	std	1,y
	std	1,sp-
	std	1,x-
	std	1,y-
	std	125,pc
	std	125,sp
	std	125,x
	std	125,y
	std	15,sp
	std	15,x
	std	15,y
	std	16,sp
	std	16,x
	std	16,y
	std	8,sp+
	std	8,x+
	std	8,y+
	std	8,sp-
	std	8,x-
	std	8,y-
	std	a,sp
	std	a,x
	std	a,y
	std	b,sp
	std	b,x
	std	b,y
	std	d,sp
	std	d,x
	std	d,y
	std	dir
	std	dir
	std	ext
	std	ext
	std	ext,sp
	std	ext,x
	std	ext,y
	std	ind,pc
	std	ind,sp
	std	ind,x
	std	ind,y
	std	small,pc
	std	small,sp
	std	small,x
	std	small,y
	stop
	sts	1,+sp
	sts	1,+x
	sts	1,+y
	sts	8,+sp
	sts	8,+x
	sts	8,+y
	sts	,pc
	sts	,sp
	sts	,x
	sts	,y
	sts	1,-sp
	sts	1,-x
	sts	1,-y
	sts	8,-sp
	sts	8,-x
	sts	8,-y
	sts	-1,sp
	sts	-1,x
	sts	-1,y
	sts	-16,sp
	sts	-16,x
	sts	-16,y
	sts	-17,sp
	sts	-17,x
	sts	-17,y
	sts	-small,pc
	sts	-small,sp
	sts	-small,x
	sts	-small,y
	sts	0,pc
	sts	0,sp
	sts	0,x
	sts	0,y
	sts	1,sp+
	sts	1,x+
	sts	1,y+
	sts	1,sp
	sts	1,x
	sts	1,y
	sts	1,sp-
	sts	1,x-
	sts	1,y-
	sts	125,pc
	sts	125,sp
	sts	125,x
	sts	125,y
	sts	15,sp
	sts	15,x
	sts	15,y
	sts	16,sp
	sts	16,x
	sts	16,y
	sts	8,sp+
	sts	8,x+
	sts	8,y+
	sts	8,sp-
	sts	8,x-
	sts	8,y-
	sts	a,sp
	sts	a,x
	sts	a,y
	sts	b,sp
	sts	b,x
	sts	b,y
	sts	d,sp
	sts	d,x
	sts	d,y
	sts	dir
	sts	ext
	sts	ext,sp
	sts	ext,x
	sts	ext,y
	sts	ind,pc
	sts	ind,sp
	sts	ind,x
	sts	ind,y
	sts	small,pc
	sts	small,sp
	sts	small,x
	sts	small,y
	stx	1,+sp
	stx	1,+x
	stx	1,+y
	stx	8,+sp
	stx	8,+x
	stx	8,+y
	stx	,pc
	stx	,sp
	stx	,x
	stx	,y
	stx	1,-sp
	stx	1,-x
	stx	1,-y
	stx	8,-sp
	stx	8,-x
	stx	8,-y
	stx	-1,sp
	stx	-1,x
	stx	-1,y
	stx	-16,sp
	stx	-16,x
	stx	-16,y
	stx	-17,sp
	stx	-17,x
	stx	-17,y
	stx	-small,pc
	stx	-small,sp
	stx	-small,x
	stx	-small,y
	stx	0,pc
	stx	0,sp
	stx	0,x
	stx	0,y
	stx	1,sp+
	stx	1,x+
	stx	1,y+
	stx	1,sp
	stx	1,x
	stx	1,y
	stx	1,sp-
	stx	1,x-
	stx	1,y-
	stx	125,pc
	stx	125,sp
	stx	125,x
	stx	125,y
	stx	15,sp
	stx	15,x
	stx	15,y
	stx	16,sp
	stx	16,x
	stx	16,y
	stx	8,sp+
	stx	8,x+
	stx	8,y+
	stx	8,sp-
	stx	8,x-
	stx	8,y-
	stx	a,sp
	stx	a,x
	stx	a,y
	stx	b,sp
	stx	b,x
	stx	b,y
	stx	d,sp
	stx	d,x
	stx	d,y
	stx	dir
	stx	dir
	stx	ext
	stx	ext
	stx	ext,sp
	stx	ext,x
	stx	ext,y
	stx	ind,pc
	stx	ind,sp
	stx	ind,x
	stx	ind,y
	stx	small,pc
	stx	small,sp
	stx	small,x
	stx	small,y
	sty	1,+sp
	sty	1,+x
	sty	1,+y
	sty	8,+sp
	sty	8,+x
	sty	8,+y
	sty	,pc
	sty	,sp
	sty	,x
	sty	,y
	sty	1,-sp
	sty	1,-x
	sty	1,-y
	sty	8,-sp
	sty	8,-x
	sty	8,-y
	sty	-1,sp
	sty	-1,x
	sty	-1,y
	sty	-16,sp
	sty	-16,x
	sty	-16,y
	sty	-17,sp
	sty	-17,x
	sty	-17,y
	sty	-small,pc
	sty	-small,sp
	sty	-small,x
	sty	-small,y
	sty	0,pc
	sty	0,sp
	sty	0,x
	sty	0,y
	sty	1,sp+
	sty	1,x+
	sty	1,y+
	sty	1,sp
	sty	1,x
	sty	1,y
	sty	1,sp-
	sty	1,x-
	sty	1,y-
	sty	125,pc
	sty	125,sp
	sty	125,x
	sty	125,y
	sty	15,sp
	sty	15,x
	sty	15,y
	sty	16,sp
	sty	16,x
	sty	16,y
	sty	8,sp+
	sty	8,x+
	sty	8,y+
	sty	8,sp-
	sty	8,x-
	sty	8,y-
	sty	a,sp
	sty	a,x
	sty	a,y
	sty	b,sp
	sty	b,x
	sty	b,y
	sty	d,sp
	sty	d,x
	sty	d,y
	sty	dir
	sty	dir
	sty	ext
	sty	ext
	sty	ext,sp
	sty	ext,x
	sty	ext,y
	sty	ind,pc
	sty	ind,sp
	sty	ind,x
	sty	ind,y
	sty	small,pc
	sty	small,sp
	sty	small,x
	sty	small,y

		ORG	$8000
	gstaa	1,+sp	;s12x cyan
	gstaa	1,+x	;s12x cyan
	gstaa	1,+y	;s12x cyan
	gstaa	8,+sp	;s12x cyan
	gstaa	8,+x	;s12x cyan
	gstaa	8,+y	;s12x cyan
	gstaa	,pc	;s12x cyan
	gstaa	,sp	;s12x cyan
	gstaa	,x	;s12x cyan
	gstaa	,y	;s12x cyan
	gstaa	1,-sp	;s12x cyan
	gstaa	1,-x	;s12x cyan
	gstaa	1,-y	;s12x cyan
	gstaa	8,-sp	;s12x cyan
	gstaa	8,-x	;s12x cyan
	gstaa	8,-y	;s12x cyan
	gstaa	-1,sp	;s12x cyan
	gstaa	-1,x	;s12x cyan
	gstaa	-1,y	;s12x cyan
	gstaa	-16,sp	;s12x cyan
	gstaa	-16,x	;s12x cyan
	gstaa	-16,y	;s12x cyan
	gstaa	-17,sp	;s12x cyan
	gstaa	-17,x	;s12x cyan
	gstaa	-17,y	;s12x cyan
	gstaa	-small,pc	;s12x cyan
	gstaa	-small,sp	;s12x cyan
	gstaa	-small,x	;s12x cyan
	gstaa	-small,y	;s12x cyan
	gstaa	0,pc	;s12x cyan
	gstaa	0,sp	;s12x cyan
	gstaa	0,x	;s12x cyan
	gstaa	0,y	;s12x cyan
	gstaa	1,sp+	;s12x cyan
	gstaa	1,x+	;s12x cyan
	gstaa	1,y+	;s12x cyan
	gstaa	1,sp	;s12x cyan
	gstaa	1,x	;s12x cyan
	gstaa	1,y	;s12x cyan
	gstaa	1,sp-	;s12x cyan
	gstaa	1,x-	;s12x cyan
	gstaa	1,y-	;s12x cyan
	gstaa	125,pc	;s12x cyan
	gstaa	125,sp	;s12x cyan
	gstaa	125,x	;s12x cyan
	gstaa	125,y	;s12x cyan
	gstaa	15,sp	;s12x cyan
	gstaa	15,x	;s12x cyan
	gstaa	15,y	;s12x cyan
	gstaa	16,sp	;s12x cyan
	gstaa	16,x	;s12x cyan
	gstaa	16,y	;s12x cyan
	gstaa	8,sp+	;s12x cyan
	gstaa	8,x+	;s12x cyan
	gstaa	8,y+	;s12x cyan
	gstaa	8,sp-	;s12x cyan
	gstaa	8,x-	;s12x cyan
	gstaa	8,y-	;s12x cyan
	gstaa	a,sp	;s12x cyan
	gstaa	a,x	;s12x cyan
	gstaa	a,y	;s12x cyan
	gstaa	b,sp	;s12x cyan
	gstaa	b,x	;s12x cyan
	gstaa	b,y	;s12x cyan
	gstaa	d,sp	;s12x cyan
	gstaa	d,x	;s12x cyan
	gstaa	d,y	;s12x cyan
	gstaa	dir	;s12x cyan
	gstaa	dir	;s12x cyan
	gstaa	ext	;s12x cyan
	gstaa	ext	;s12x cyan
	gstaa	ext,sp	;s12x cyan
	gstaa	ext,x	;s12x cyan
	gstaa	ext,y	;s12x cyan
	gstaa	ind,pc	;s12x cyan
	gstaa	ind,sp	;s12x cyan
	gstaa	ind,x	;s12x cyan
	gstaa	ind,y	;s12x cyan
	gstaa	small,pc	;s12x cyan
	gstaa	small,sp	;s12x cyan
	gstaa	small,x	;s12x cyan
	gstaa	small,y	;s12x cyan
	gstab	1,+sp	;s12x cyan
	gstab	1,+x	;s12x cyan
	gstab	1,+y	;s12x cyan
	gstab	8,+sp	;s12x cyan
	gstab	8,+x	;s12x cyan
	gstab	8,+y	;s12x cyan
	gstab	,pc	;s12x cyan
	gstab	,sp	;s12x cyan
	gstab	,x	;s12x cyan
	gstab	,y	;s12x cyan
	gstab	1,-sp	;s12x cyan
	gstab	1,-x	;s12x cyan
	gstab	1,-y	;s12x cyan
	gstab	8,-sp	;s12x cyan
	gstab	8,-x	;s12x cyan
	gstab	8,-y	;s12x cyan
	gstab	-1,sp	;s12x cyan
	gstab	-1,x	;s12x cyan
	gstab	-1,y	;s12x cyan
	gstab	-16,sp	;s12x cyan
	gstab	-16,x	;s12x cyan
	gstab	-16,y	;s12x cyan
	gstab	-17,sp	;s12x cyan
	gstab	-17,x	;s12x cyan
	gstab	-17,y	;s12x cyan
	gstab	-small,pc	;s12x cyan
	gstab	-small,sp	;s12x cyan
	gstab	-small,x	;s12x cyan
	gstab	-small,y	;s12x cyan
	gstab	0,pc	;s12x cyan
	gstab	0,sp	;s12x cyan
	gstab	0,x	;s12x cyan
	gstab	0,y	;s12x cyan
	gstab	1,sp+	;s12x cyan
	gstab	1,x+	;s12x cyan
	gstab	1,y+	;s12x cyan
	gstab	1,sp	;s12x cyan
	gstab	1,x	;s12x cyan
	gstab	1,y	;s12x cyan
	gstab	1,sp-	;s12x cyan
	gstab	1,x-	;s12x cyan
	gstab	1,y-	;s12x cyan
	gstab	125,pc	;s12x cyan
	gstab	125,sp	;s12x cyan
	gstab	125,x	;s12x cyan
	gstab	125,y	;s12x cyan
	gstab	15,sp	;s12x cyan
	gstab	15,x	;s12x cyan
	gstab	15,y	;s12x cyan
	gstab	16,sp	;s12x cyan
	gstab	16,x	;s12x cyan
	gstab	16,y	;s12x cyan
	gstab	8,sp+	;s12x cyan
	gstab	8,x+	;s12x cyan
	gstab	8,y+	;s12x cyan
	gstab	8,sp-	;s12x cyan
	gstab	8,x-	;s12x cyan
	gstab	8,y-	;s12x cyan
	gstab	a,sp	;s12x cyan
	gstab	a,x	;s12x cyan
	gstab	a,y	;s12x cyan
	gstab	b,sp	;s12x cyan
	gstab	b,x	;s12x cyan
	gstab	b,y	;s12x cyan
	gstab	d,sp	;s12x cyan
	gstab	d,x	;s12x cyan
	gstab	d,y	;s12x cyan
	gstab	dir	;s12x cyan
	gstab	dir	;s12x cyan
	gstab	ext	;s12x cyan
	gstab	ext	;s12x cyan
	gstab	ext,sp	;s12x cyan
	gstab	ext,x	;s12x cyan
	gstab	ext,y	;s12x cyan
	gstab	ind,pc	;s12x cyan
	gstab	ind,sp	;s12x cyan
	gstab	ind,x	;s12x cyan
	gstab	ind,y	;s12x cyan
	gstab	small,pc	;s12x cyan
	gstab	small,sp	;s12x cyan
	gstab	small,x	;s12x cyan
	gstab	small,y	;s12x cyan
	gstd	1,+sp	;s12x cyan
	gstd	1,+x	;s12x cyan
	gstd	1,+y	;s12x cyan
	gstd	8,+sp	;s12x cyan
	gstd	8,+x	;s12x cyan
	gstd	8,+y	;s12x cyan
	gstd	,pc	;s12x cyan
	gstd	,sp	;s12x cyan
	gstd	,x	;s12x cyan
	gstd	,y	;s12x cyan
	gstd	1,-sp	;s12x cyan
	gstd	1,-x	;s12x cyan
	gstd	1,-y	;s12x cyan
	gstd	8,-sp	;s12x cyan
	gstd	8,-x	;s12x cyan
	gstd	8,-y	;s12x cyan
	gstd	-1,sp	;s12x cyan
	gstd	-1,x	;s12x cyan
	gstd	-1,y	;s12x cyan
	gstd	-16,sp	;s12x cyan
	gstd	-16,x	;s12x cyan
	gstd	-16,y	;s12x cyan
	gstd	-17,sp	;s12x cyan
	gstd	-17,x	;s12x cyan
	gstd	-17,y	;s12x cyan
	gstd	-small,pc	;s12x cyan
	gstd	-small,sp	;s12x cyan
	gstd	-small,x	;s12x cyan
	gstd	-small,y	;s12x cyan
	gstd	0,pc	;s12x cyan
	gstd	0,sp	;s12x cyan
	gstd	0,x	;s12x cyan
	gstd	0,y	;s12x cyan
	gstd	1,sp+	;s12x cyan
	gstd	1,x+	;s12x cyan
	gstd	1,y+	;s12x cyan
	gstd	1,sp	;s12x cyan
	gstd	1,x	;s12x cyan
	gstd	1,y	;s12x cyan
	gstd	1,sp-	;s12x cyan
	gstd	1,x-	;s12x cyan
	gstd	1,y-	;s12x cyan
	gstd	125,pc	;s12x cyan
	gstd	125,sp	;s12x cyan
	gstd	125,x	;s12x cyan
	gstd	125,y	;s12x cyan
	gstd	15,sp	;s12x cyan
	gstd	15,x	;s12x cyan
	gstd	15,y	;s12x cyan
	gstd	16,sp	;s12x cyan
	gstd	16,x	;s12x cyan
	gstd	16,y	;s12x cyan
	gstd	8,sp+	;s12x cyan
	gstd	8,x+	;s12x cyan
	gstd	8,y+	;s12x cyan
	gstd	8,sp-	;s12x cyan
	gstd	8,x-	;s12x cyan
	gstd	8,y-	;s12x cyan
	gstd	a,sp	;s12x cyan
	gstd	a,x	;s12x cyan
	gstd	a,y	;s12x cyan
	gstd	b,sp	;s12x cyan
	gstd	b,x	;s12x cyan
	gstd	b,y	;s12x cyan
	gstd	d,sp	;s12x cyan
	gstd	d,x	;s12x cyan
	gstd	d,y	;s12x cyan
	gstd	dir	;s12x cyan
	gstd	dir	;s12x cyan
	gstd	ext	;s12x cyan
	gstd	ext	;s12x cyan
	gstd	ext,sp	;s12x cyan
	gstd	ext,x	;s12x cyan
	gstd	ext,y	;s12x cyan
	gstd	ind,pc	;s12x cyan
	gstd	ind,sp	;s12x cyan
	gstd	ind,x	;s12x cyan
	gstd	ind,y	;s12x cyan
	gstd	small,pc	;s12x cyan
	gstd	small,sp	;s12x cyan
	gstd	small,x	;s12x cyan
	gstd	small,y	;s12x cyan
	gsts	1,+sp	;s12x cyan
	gsts	1,+x	;s12x cyan
	gsts	1,+y	;s12x cyan
	gsts	8,+sp	;s12x cyan
	gsts	8,+x	;s12x cyan
	gsts	8,+y	;s12x cyan
	gsts	,pc	;s12x cyan
	gsts	,sp	;s12x cyan
	gsts	,x	;s12x cyan
	gsts	,y	;s12x cyan
	gsts	1,-sp	;s12x cyan
	gsts	1,-x	;s12x cyan
	gsts	1,-y	;s12x cyan
	gsts	8,-sp	;s12x cyan
	gsts	8,-x	;s12x cyan
	gsts	8,-y	;s12x cyan
	gsts	-1,sp	;s12x cyan
	gsts	-1,x	;s12x cyan
	gsts	-1,y	;s12x cyan
	gsts	-16,sp	;s12x cyan
	gsts	-16,x	;s12x cyan
	gsts	-16,y	;s12x cyan
	gsts	-17,sp	;s12x cyan
	gsts	-17,x	;s12x cyan
	gsts	-17,y	;s12x cyan
	gsts	-small,pc	;s12x cyan
	gsts	-small,sp	;s12x cyan
	gsts	-small,x	;s12x cyan
	gsts	-small,y	;s12x cyan
	gsts	0,pc	;s12x cyan
	gsts	0,sp	;s12x cyan
	gsts	0,x	;s12x cyan
	gsts	0,y	;s12x cyan
	gsts	1,sp+	;s12x cyan
	gsts	1,x+	;s12x cyan
	gsts	1,y+	;s12x cyan
	gsts	1,sp	;s12x cyan
	gsts	1,x	;s12x cyan
	gsts	1,y	;s12x cyan
	gsts	1,sp-	;s12x cyan
	gsts	1,x-	;s12x cyan
	gsts	1,y-	;s12x cyan
	gsts	125,pc	;s12x cyan
	gsts	125,sp	;s12x cyan
	gsts	125,x	;s12x cyan
	gsts	125,y	;s12x cyan
	gsts	15,sp	;s12x cyan
	gsts	15,x	;s12x cyan
	gsts	15,y	;s12x cyan
	gsts	16,sp	;s12x cyan
	gsts	16,x	;s12x cyan
	gsts	16,y	;s12x cyan
	gsts	8,sp+	;s12x cyan
	gsts	8,x+	;s12x cyan
	gsts	8,y+	;s12x cyan
	gsts	8,sp-	;s12x cyan
	gsts	8,x-	;s12x cyan
	gsts	8,y-	;s12x cyan
	gsts	a,sp	;s12x cyan
	gsts	a,x	;s12x cyan
	gsts	a,y	;s12x cyan
	gsts	b,sp	;s12x cyan
	gsts	b,x	;s12x cyan
	gsts	b,y	;s12x cyan
	gsts	d,sp	;s12x cyan
	gsts	d,x	;s12x cyan
	gsts	d,y	;s12x cyan
	gsts	dir	;s12x cyan
	gsts	ext	;s12x cyan
	gsts	ext,sp	;s12x cyan
	gsts	ext,x	;s12x cyan
	gsts	ext,y	;s12x cyan
	gsts	ind,pc	;s12x cyan
	gsts	ind,sp	;s12x cyan
	gsts	ind,x	;s12x cyan
	gsts	ind,y	;s12x cyan
	gsts	small,pc	;s12x cyan
	gsts	small,sp	;s12x cyan
	gsts	small,x	;s12x cyan
	gsts	small,y	;s12x cyan
	gstx	1,+sp	;s12x cyan
	gstx	1,+x	;s12x cyan
	gstx	1,+y	;s12x cyan
	gstx	8,+sp	;s12x cyan
	gstx	8,+x	;s12x cyan
	gstx	8,+y	;s12x cyan
	gstx	,pc	;s12x cyan
	gstx	,sp	;s12x cyan
	gstx	,x	;s12x cyan
	gstx	,y	;s12x cyan
	gstx	1,-sp	;s12x cyan
	gstx	1,-x	;s12x cyan
	gstx	1,-y	;s12x cyan
	gstx	8,-sp	;s12x cyan
	gstx	8,-x	;s12x cyan
	gstx	8,-y	;s12x cyan
	gstx	-1,sp	;s12x cyan
	gstx	-1,x	;s12x cyan
	gstx	-1,y	;s12x cyan
	gstx	-16,sp	;s12x cyan
	gstx	-16,x	;s12x cyan
	gstx	-16,y	;s12x cyan
	gstx	-17,sp	;s12x cyan
	gstx	-17,x	;s12x cyan
	gstx	-17,y	;s12x cyan
	gstx	-small,pc	;s12x cyan
	gstx	-small,sp	;s12x cyan
	gstx	-small,x	;s12x cyan
	gstx	-small,y	;s12x cyan
	gstx	0,pc	;s12x cyan
	gstx	0,sp	;s12x cyan
	gstx	0,x	;s12x cyan
	gstx	0,y	;s12x cyan
	gstx	1,sp+	;s12x cyan
	gstx	1,x+	;s12x cyan
	gstx	1,y+	;s12x cyan
	gstx	1,sp	;s12x cyan
	gstx	1,x	;s12x cyan
	gstx	1,y	;s12x cyan
	gstx	1,sp-	;s12x cyan
	gstx	1,x-	;s12x cyan
	gstx	1,y-	;s12x cyan
	gstx	125,pc	;s12x cyan
	gstx	125,sp	;s12x cyan
	gstx	125,x	;s12x cyan
	gstx	125,y	;s12x cyan
	gstx	15,sp	;s12x cyan
	gstx	15,x	;s12x cyan
	gstx	15,y	;s12x cyan
	gstx	16,sp	;s12x cyan
	gstx	16,x	;s12x cyan
	gstx	16,y	;s12x cyan
	gstx	8,sp+	;s12x cyan
	gstx	8,x+	;s12x cyan
	gstx	8,y+	;s12x cyan
	gstx	8,sp-	;s12x cyan
	gstx	8,x-	;s12x cyan
	gstx	8,y-	;s12x cyan
	gstx	a,sp	;s12x cyan
	gstx	a,x	;s12x cyan
	gstx	a,y	;s12x cyan
	gstx	b,sp	;s12x cyan
	gstx	b,x	;s12x cyan
	gstx	b,y	;s12x cyan
	gstx	d,sp	;s12x cyan
	gstx	d,x	;s12x cyan
	gstx	d,y	;s12x cyan
	gstx	dir	;s12x cyan
	gstx	dir	;s12x cyan
	gstx	ext	;s12x cyan
	gstx	ext	;s12x cyan
	gstx	ext,sp	;s12x cyan
	gstx	ext,x	;s12x cyan
	gstx	ext,y	;s12x cyan
	gstx	ind,pc	;s12x cyan
	gstx	ind,sp	;s12x cyan
	gstx	ind,x	;s12x cyan
	gstx	ind,y	;s12x cyan
	gstx	small,pc	;s12x cyan
	gstx	small,sp	;s12x cyan
	gstx	small,x	;s12x cyan
	gstx	small,y	;s12x cyan
	gsty	1,+sp	;s12x cyan
	gsty	1,+x	;s12x cyan
	gsty	1,+y	;s12x cyan
	gsty	8,+sp	;s12x cyan
	gsty	8,+x	;s12x cyan
	gsty	8,+y	;s12x cyan
	gsty	,pc	;s12x cyan
	gsty	,sp	;s12x cyan
	gsty	,x	;s12x cyan
	gsty	,y	;s12x cyan
	gsty	1,-sp	;s12x cyan
	gsty	1,-x	;s12x cyan
	gsty	1,-y	;s12x cyan
	gsty	8,-sp	;s12x cyan
	gsty	8,-x	;s12x cyan
	gsty	8,-y	;s12x cyan
	gsty	-1,sp	;s12x cyan
	gsty	-1,x	;s12x cyan
	gsty	-1,y	;s12x cyan
	gsty	-16,sp	;s12x cyan
	gsty	-16,x	;s12x cyan
	gsty	-16,y	;s12x cyan
	gsty	-17,sp	;s12x cyan
	gsty	-17,x	;s12x cyan
	gsty	-17,y	;s12x cyan
	gsty	-small,pc	;s12x cyan
	gsty	-small,sp	;s12x cyan
	gsty	-small,x	;s12x cyan
	gsty	-small,y	;s12x cyan
	gsty	0,pc	;s12x cyan
	gsty	0,sp	;s12x cyan
	gsty	0,x	;s12x cyan
	gsty	0,y	;s12x cyan
	gsty	1,sp+	;s12x cyan
	gsty	1,x+	;s12x cyan
	gsty	1,y+	;s12x cyan
	gsty	1,sp	;s12x cyan
	gsty	1,x	;s12x cyan
	gsty	1,y	;s12x cyan
	gsty	1,sp-	;s12x cyan
	gsty	1,x-	;s12x cyan
	gsty	1,y-	;s12x cyan
	gsty	125,pc	;s12x cyan
	gsty	125,sp	;s12x cyan
	gsty	125,x	;s12x cyan
	gsty	125,y	;s12x cyan
	gsty	15,sp	;s12x cyan
	gsty	15,x	;s12x cyan
	gsty	15,y	;s12x cyan
	gsty	16,sp	;s12x cyan
	gsty	16,x	;s12x cyan
	gsty	16,y	;s12x cyan
	gsty	8,sp+	;s12x cyan
	gsty	8,x+	;s12x cyan
	gsty	8,y+	;s12x cyan
	gsty	8,sp-	;s12x cyan
	gsty	8,x-	;s12x cyan
	gsty	8,y-	;s12x cyan
	gsty	a,sp	;s12x cyan
	gsty	a,x	;s12x cyan
	gsty	a,y	;s12x cyan
	gsty	b,sp	;s12x cyan
	gsty	b,x	;s12x cyan
	gsty	b,y	;s12x cyan
	gsty	d,sp	;s12x cyan
	gsty	d,x	;s12x cyan
	gsty	d,y	;s12x cyan
	gsty	dir	;s12x cyan
	gsty	dir	;s12x cyan
	gsty	ext	;s12x cyan
	gsty	ext	;s12x cyan
	gsty	ext,sp	;s12x cyan
	gsty	ext,x	;s12x cyan
	gsty	ext,y	;s12x cyan
	gsty	ind,pc	;s12x cyan
	gsty	ind,sp	;s12x cyan
	gsty	ind,x	;s12x cyan
	gsty	ind,y	;s12x cyan
	gsty	small,pc	;s12x cyan
	gsty	small,sp	;s12x cyan
	gsty	small,x	;s12x cyan
	gsty	small,y	;s12x cyan
	
	suba	#immed
	suba	1,+sp
	suba	1,+x
	suba	1,+y
	suba	8,+sp
	suba	8,+x
	suba	8,+y
	suba	,pc
	suba	,sp
	suba	,x
	suba	,y
	suba	1,-sp
	suba	1,-x
	suba	1,-y
	suba	8,-sp
	suba	8,-x
	suba	8,-y
	suba	-1,sp
	suba	-1,x
	suba	-1,y
	suba	-16,sp
	suba	-16,x
	suba	-16,y
	suba	-17,sp
	suba	-17,x
	suba	-17,y
	suba	-small,pc
	suba	-small,sp
	suba	-small,x
	suba	-small,y
	suba	0,pc
	suba	0,sp
	suba	0,x
	suba	0,y
	suba	1,sp+
	suba	1,x+
	suba	1,y+
	suba	1,sp
	suba	1,x
	suba	1,y
	suba	1,sp-
	suba	1,x-
	suba	1,y-
	suba	125,pc
	suba	125,sp
	suba	125,x
	suba	125,y
	suba	15,sp
	suba	15,x
	suba	15,y
	suba	16,sp
	suba	16,x
	suba	16,y
	suba	8,sp+
	suba	8,x+
	suba	8,y+
	suba	8,sp-
	suba	8,x-
	suba	8,y-
	suba	a,sp
	suba	a,x
	suba	a,y
	suba	b,sp
	suba	b,x
	suba	b,y
	suba	d,sp
	suba	d,x
	suba	d,y
	suba	dir
	suba	ext
	suba	ext,sp
	suba	ext,x
	suba	ext,y
	suba	ind,pc
	suba	ind,sp
	suba	ind,x
	suba	ind,y
	suba	small,pc
	suba	small,sp
	suba	small,x
	suba	small,y

	subx	#immed	;s12x yellow
	subx	1,+sp	;s12x yellow
	subx	1,+x	;s12x yellow
	subx	1,+y	;s12x yellow
	subx	8,+sp	;s12x yellow
	subx	8,+x	;s12x yellow
	subx	8,+y	;s12x yellow
	subx	,pc	;s12x yellow
	subx	,sp	;s12x yellow
	subx	,x	;s12x yellow
	subx	,y	;s12x yellow
	subx	1,-sp	;s12x yellow
	subx	1,-x	;s12x yellow
	subx	1,-y	;s12x yellow
	subx	8,-sp	;s12x yellow
	subx	8,-x	;s12x yellow
	subx	8,-y	;s12x yellow
	subx	-1,sp	;s12x yellow
	subx	-1,x	;s12x yellow
	subx	-1,y	;s12x yellow
	subx	-16,sp	;s12x yellow
	subx	-16,x	;s12x yellow
	subx	-16,y	;s12x yellow
	subx	-17,sp	;s12x yellow
	subx	-17,x	;s12x yellow
	subx	-17,y	;s12x yellow
	subx	-small,pc	;s12x yellow
	subx	-small,sp	;s12x yellow
	subx	-small,x	;s12x yellow
	subx	-small,y	;s12x yellow
	subx	0,pc	;s12x yellow
	subx	0,sp	;s12x yellow
	subx	0,x	;s12x yellow
	subx	0,y	;s12x yellow
	subx	1,sp+	;s12x yellow
	subx	1,x+	;s12x yellow
	subx	1,y+	;s12x yellow
	subx	1,sp	;s12x yellow
	subx	1,x	;s12x yellow
	subx	1,y	;s12x yellow
	subx	1,sp-	;s12x yellow
	subx	1,x-	;s12x yellow
	subx	1,y-	;s12x yellow
	subx	125,pc	;s12x yellow
	subx	125,sp	;s12x yellow
	subx	125,x	;s12x yellow
	subx	125,y	;s12x yellow
	subx	15,sp	;s12x yellow
	subx	15,x	;s12x yellow
	subx	15,y	;s12x yellow
	subx	16,sp	;s12x yellow
	subx	16,x	;s12x yellow
	subx	16,y	;s12x yellow
	subx	8,sp+	;s12x yellow
	subx	8,x+	;s12x yellow
	subx	8,y+	;s12x yellow
	subx	8,sp-	;s12x yellow
	subx	8,x-	;s12x yellow
	subx	8,y-	;s12x yellow
	subx	a,sp	;s12x yellow
	subx	a,x	;s12x yellow
	subx	a,y	;s12x yellow
	subx	b,sp	;s12x yellow
	subx	b,x	;s12x yellow
	subx	b,y	;s12x yellow
	subx	d,sp	;s12x yellow
	subx	d,x	;s12x yellow
	subx	d,y	;s12x yellow
	subx	dir	;s12x yellow
	subx	ext	;s12x yellow
	subx	ext,sp	;s12x yellow
	subx	ext,x	;s12x yellow
	subx	ext,y	;s12x yellow
	subx	ind,pc	;s12x yellow
	subx	ind,sp	;s12x yellow
	subx	ind,x	;s12x yellow
	subx	ind,y	;s12x yellow
	subx	small,pc	;s12x yellow
	subx	small,sp	;s12x yellow
	subx	small,x	;s12x yellow
	subx	small,y	;s12x yellow

	subb	#immed
	subb	1,+sp
	subb	1,+x
	subb	1,+y
	subb	8,+sp
	subb	8,+x
	subb	8,+y
	subb	,pc
	subb	,sp
	subb	,x
	subb	,y
	subb	1,-sp
	subb	1,-x
	subb	1,-y
	subb	8,-sp
	subb	8,-x
	subb	8,-y
	subb	-1,sp
	subb	-1,x
	subb	-1,y
	subb	-16,sp
	subb	-16,x
	subb	-16,y
	subb	-17,sp
	subb	-17,x
	subb	-17,y
	subb	-small,pc
	subb	-small,sp
	subb	-small,x
	subb	-small,y
	subb	0,pc
	subb	0,sp
	subb	0,x
	subb	0,y
	subb	1,sp+
	subb	1,x+
	subb	1,y+
	subb	1,sp
	subb	1,x
	subb	1,y
	subb	1,sp-
	subb	1,x-
	subb	1,y-
	subb	125,pc
	subb	125,sp
	subb	125,x
	subb	125,y
	subb	15,sp
	subb	15,x
	subb	15,y
	subb	16,sp
	subb	16,x
	subb	16,y
	subb	8,sp+
	subb	8,x+
	subb	8,y+
	subb	8,sp-
	subb	8,x-
	subb	8,y-
	subb	a,sp
	subb	a,x
	subb	a,y
	subb	b,sp
	subb	b,x
	subb	b,y
	subb	d,sp
	subb	d,x
	subb	d,y
	subb	dir
	subb	dir
	subb	ext
	subb	ext
	subb	ext,sp
	subb	ext,x
	subb	ext,y
	subb	ind,pc
	subb	ind,sp
	subb	ind,x
	subb	ind,y
	subb	small,pc
	subb	small,sp
	subb	small,x
	subb	small,y

	suby	#immed	;s12x yellow
	suby	1,+sp	;s12x yellow
	suby	1,+x	;s12x yellow
	suby	1,+y	;s12x yellow
	suby	8,+sp	;s12x yellow
	suby	8,+x	;s12x yellow
	suby	8,+y	;s12x yellow
	suby	,pc	;s12x yellow
	suby	,sp	;s12x yellow
	suby	,x	;s12x yellow
	suby	,y	;s12x yellow
	suby	1,-sp	;s12x yellow
	suby	1,-x	;s12x yellow
	suby	1,-y	;s12x yellow
	suby	8,-sp	;s12x yellow
	suby	8,-x	;s12x yellow
	suby	8,-y	;s12x yellow
	suby	-1,sp	;s12x yellow
	suby	-1,x	;s12x yellow
	suby	-1,y	;s12x yellow
	suby	-16,sp	;s12x yellow
	suby	-16,x	;s12x yellow
	suby	-16,y	;s12x yellow
	suby	-17,sp	;s12x yellow
	suby	-17,x	;s12x yellow
	suby	-17,y	;s12x yellow
	suby	-small,pc	;s12x yellow
	suby	-small,sp	;s12x yellow
	suby	-small,x	;s12x yellow
	suby	-small,y	;s12x yellow
	suby	0,pc	;s12x yellow
	suby	0,sp	;s12x yellow
	suby	0,x	;s12x yellow
	suby	0,y	;s12x yellow
	suby	1,sp+	;s12x yellow
	suby	1,x+	;s12x yellow
	suby	1,y+	;s12x yellow
	suby	1,sp	;s12x yellow
	suby	1,x	;s12x yellow
	suby	1,y	;s12x yellow
	suby	1,sp-	;s12x yellow
	suby	1,x-	;s12x yellow
	suby	1,y-	;s12x yellow
	suby	125,pc	;s12x yellow
	suby	125,sp	;s12x yellow
	suby	125,x	;s12x yellow
	suby	125,y	;s12x yellow
	suby	15,sp	;s12x yellow
	suby	15,x	;s12x yellow
	suby	15,y	;s12x yellow
	suby	16,sp	;s12x yellow
	suby	16,x	;s12x yellow
	suby	16,y	;s12x yellow
	suby	8,sp+	;s12x yellow
	suby	8,x+	;s12x yellow
	suby	8,y+	;s12x yellow
	suby	8,sp-	;s12x yellow
	suby	8,x-	;s12x yellow
	suby	8,y-	;s12x yellow
	suby	a,sp	;s12x yellow
	suby	a,x	;s12x yellow
	suby	a,y	;s12x yellow
	suby	b,sp	;s12x yellow
	suby	b,x	;s12x yellow
	suby	b,y	;s12x yellow
	suby	d,sp	;s12x yellow
	suby	d,x	;s12x yellow
	suby	d,y	;s12x yellow
	suby	dir	;s12x yellow
	suby	dir	;s12x yellow
	suby	ext	;s12x yellow
	suby	ext	;s12x yellow
	suby	ext,sp	;s12x yellow
	suby	ext,x	;s12x yellow
	suby	ext,y	;s12x yellow
	suby	ind,pc	;s12x yellow
	suby	ind,sp	;s12x yellow
	suby	ind,x	;s12x yellow
	suby	ind,y	;s12x yellow
	suby	small,pc	;s12x yellow
	suby	small,sp	;s12x yellow
	suby	small,x	;s12x yellow
	suby	small,y	;s12x yellow

	subd	#immed
	subd	1,+sp
	subd	1,+x
	subd	1,+y
	subd	8,+sp
	subd	8,+x
	subd	8,+y
	subd	,pc
	subd	,sp
	subd	,x
	subd	,y
	subd	1,-sp
	subd	1,-x
	subd	1,-y
	subd	8,-sp
	subd	8,-x
	subd	8,-y
	subd	-1,sp
	subd	-1,x
	subd	-1,y
	subd	-16,sp
	subd	-16,x
	subd	-16,y
	subd	-17,sp
	subd	-17,x
	subd	-17,y
	subd	-small,pc
	subd	-small,sp
	subd	-small,x
	subd	-small,y
	subd	0,pc
	subd	0,sp
	subd	0,x
	subd	0,y
	subd	1,sp+
	subd	1,x+
	subd	1,y+
	subd	1,sp
	subd	1,x
	subd	1,y
	subd	1,sp-
	subd	1,x-
	subd	1,y-
	subd	125,pc
	subd	125,sp
	subd	125,x
	subd	125,y
	subd	15,sp
	subd	15,x
	subd	15,y
	subd	16,sp
	subd	16,x
	subd	16,y
	subd	8,sp+
	subd	8,x+
	subd	8,y+
	subd	8,sp-
	subd	8,x-
	subd	8,y-
	subd	a,sp
	subd	a,x
	subd	a,y
	subd	b,sp
	subd	b,x
	subd	b,y
	subd	d,sp
	subd	d,x
	subd	d,y
	subd	dir
	subd	dir
	subd	ext
	subd	ext
	subd	ext,sp
	subd	ext,x
	subd	ext,y
	subd	ind,pc
	subd	ind,sp
	subd	ind,x
	subd	ind,y
	subd	small,pc
	subd	small,sp
	subd	small,x
	subd	small,y

	sbed	#immed	;s12x red
	sbed	#immed	;s12x red
	sbed	1,+sp	;s12x red
	sbed	1,+x	;s12x red
	sbed	1,+y	;s12x red
	sbed	8,+sp	;s12x red
	sbed	8,+x	;s12x red
	sbed	8,+y	;s12x red
	sbed	,pc	;s12x red
	sbed	,sp	;s12x red
	sbed	,x	;s12x red
	sbed	,y	;s12x red
	sbed	1,-sp	;s12x red
	sbed	1,-x	;s12x red
	sbed	1,-y	;s12x red
	sbed	8,-sp	;s12x red
	sbed	8,-x	;s12x red
	sbed	8,-y	;s12x red
	sbed	-1,sp	;s12x red
	sbed	-1,x	;s12x red
	sbed	-1,y	;s12x red
	sbed	-16,sp	;s12x red
	sbed	-16,x	;s12x red
	sbed	-16,y	;s12x red
	sbed	-17,sp	;s12x red
	sbed	-17,x	;s12x red
	sbed	-17,y	;s12x red
	sbed	-small,pc	;s12x red
	sbed	-small,sp	;s12x red
	sbed	-small,x	;s12x red
	sbed	-small,y	;s12x red
	sbed	0,pc	;s12x red
	sbed	0,sp	;s12x red
	sbed	0,x	;s12x red
	sbed	0,y	;s12x red
	sbed	1,sp+	;s12x red
	sbed	1,x+	;s12x red
	sbed	1,y+	;s12x red
	sbed	1,sp	;s12x red
	sbed	1,x	;s12x red
	sbed	1,y	;s12x red
	sbed	1,sp-	;s12x red
	sbed	1,x-	;s12x red
	sbed	1,y-	;s12x red
	sbed	125,pc	;s12x red
	sbed	125,sp	;s12x red
	sbed	125,x	;s12x red
	sbed	125,y	;s12x red
	sbed	15,sp	;s12x red
	sbed	15,x	;s12x red
	sbed	15,y	;s12x red
	sbed	16,sp	;s12x red
	sbed	16,x	;s12x red
	sbed	16,y	;s12x red
	sbed	8,sp+	;s12x red
	sbed	8,x+	;s12x red
	sbed	8,y+	;s12x red
	sbed	8,sp-	;s12x red
	sbed	8,x-	;s12x red
	sbed	8,y-	;s12x red
	sbed	a,sp	;s12x red
	sbed	a,x	;s12x red
	sbed	a,y	;s12x red
	sbed	b,sp	;s12x red
	sbed	b,x	;s12x red
	sbed	b,y	;s12x red
	sbed	d,sp	;s12x red
	sbed	d,x	;s12x red
	sbed	d,y	;s12x red
	sbed	dir	;s12x red
	sbed	dir	;s12x red
	sbed	ext	;s12x red
	sbed	ext	;s12x red
	sbed	ext,sp	;s12x red
	sbed	ext,x	;s12x red
	sbed	ext,y	;s12x red
	sbed	ind,pc	;s12x red
	sbed	ind,sp	;s12x red
	sbed	ind,x	;s12x red
	sbed	ind,y	;s12x red
	sbed	small,pc	;s12x red
	sbed	small,sp	;s12x red
	sbed	small,x	;s12x red
	sbed	small,y	;s12x red

	swi

	tab
	tap
	tba
	tbl     b,x
	tfr	a a
	tfr	a,a
	tfr	a b
	tfr	a,b
	tfr	a ccr
	tfr     a ccrl	;s12x tfr alternative
	tfr	a ccrh	;s12x tfr new
	tfr	a d
	tfr	a sp
	tfr	a x
	tfr	a,x
	tfr	a y
	tfr	a,y
	tfr	b a
	tfr	b b
	tfr	b ccr
	tfr     b ccrl	;s12x tfr alternative
	;tfr	b ccrh	;s12x tfr new
	tfr	b d
	tfr	b sp
	tfr	b x
	tfr	b y
	tfr	ccr a
	tfr	ccrl a	;s12x tfr alternative
	tfr	ccrh a	;s12x tfr new
	tfr	ccr b
	tfr	ccrl b  ;s12x alternative
	;tfr	ccrh b	;s12x new
	tfr	ccr ccr
	tfr	ccrl ccrl ;s12x tfr alternative
	tfr	ccrw ccrw ;s12x tfr new
	tfr	ccr d
	tfr	ccrl d	;s12x tfr alternative
	tfr	ccrw d	;s12x tfr new
	tfr	ccr sp
	tfr	ccrl sp	;s12x tfr alternative
	tfr	ccrw sp	;s12x tfr new
	tfr	ccr x
	tfr	ccrl x	;s12x tfr alternative
	tfr	ccrw x	;s12x tfr new
	tfr	ccr y
	tfr	ccrl y	;s12x tfr alternative
	tfr	ccrw y	;s12x tfr new
	tfr	d a
	tfr	d b
	;tfr	d ccr	;?????? ?JW?
	;tfr     d ccrw  ;s12x tfr new ?JW?
	tfr	d d
	tfr	d sp
	tfr	d x
	tfr	d y
	tfr	sp a
	tfr	sp b
	tfr	sp ccr
	tfr     sp ccrl ;s12x tfr alternative
	tfr     sp ccrw ;s12x tfr new
	tfr	sp d
	tfr	sp sp
	tfr	sp x
	tfr	sp y
	tfr	x a
	tfr	x b
	tfr	x ccr
	tfr     x ccrl  ;s12x tfr alternative
	tfr     x ccrw  ;s12x tfr new
	tfr	x d
	tfr	x sp
	tfr	x x
	tfr	x y
	tfr	y a
	tfr	y b
	tfr	y ccr
	tfr     y ccrl  ;s12x tfr alternative
	tfr     y ccrw  ;s12x tfr new
	tfr	y d
	tfr	y sp
	tfr	y x
	tfr	y y
	tpa
	tst	1,+sp
	tst	1,+x
	tst	1,+y
	tst	8,+sp
	tst	8,+x
	tst	8,+y
	tst	,pc
	tst	,sp
	tst	,x
	tst	,y
	tst	1,-sp
	tst	1,-x
	tst	1,-y
	tst	8,-sp
	tst	8,-x
	tst	8,-y
	tst	-1,sp
	tst	-1,x
	tst	-1,y
	tst	-16,sp
	tst	-16,x
	tst	-16,y
	tst	-17,sp
	tst	-17,x
	tst	-17,y
	tst	-small,pc
	tst	-small,sp
	tst	-small,x
	tst	-small,y
	tst	0,pc
	tst	0,sp
	tst	0,x
	tst	0,y
	tst	1,sp+
	tst	1,x+
	tst	1,y+
	tst	1,sp
	tst	1,x
	tst	1,y
	tst	1,sp-
	tst	1,x-
	tst	1,y-
	tst	125,pc
	tst	125,sp
	tst	125,x
	tst	125,y
	tst	15,sp
	tst	15,x
	tst	15,y
	tst	16,sp
	tst	16,x
	tst	16,y
	tst	8,sp+
	tst	8,x+
	tst	8,y+
	tst	8,sp-
	tst	8,x-
	tst	8,y-
	tst	a,sp
	tst	a,x
	tst	a,y
	tst	b,sp
	tst	b,x
	tst	b,y
	tst	d,sp
	tst	d,x
	tst	d,y
	tst	dir
	tst	ext
	tst	ext
	tst	ext,sp
	tst	ext,x
	tst	ext,y
	tst	ind,pc
	tst	ind,sp
	tst	ind,x
	tst	ind,y
	tst	small,pc
	tst	small,sp
	tst	small,x
	tst	small,y

	tstw	1,+sp	;s12x green
	tstw	1,+x	;s12x green
	tstw	1,+y	;s12x green
	tstw	8,+sp	;s12x green
	tstw	8,+x	;s12x green
	tstw	8,+y	;s12x green
	tstw	,pc	;s12x green
	tstw	,sp	;s12x green
	tstw	,x	;s12x green
	tstw	,y	;s12x green
	tstw	1,-sp	;s12x green
	tstw	1,-x	;s12x green
	tstw	1,-y	;s12x green
	tstw	8,-sp	;s12x green
	tstw	8,-x	;s12x green
	tstw	8,-y	;s12x green
	tstw	-1,sp	;s12x green
	tstw	-1,x	;s12x green
	tstw	-1,y	;s12x green
	tstw	-16,sp	;s12x green
	tstw	-16,x	;s12x green
	tstw	-16,y	;s12x green
	tstw	-17,sp	;s12x green
	tstw	-17,x	;s12x green
	tstw	-17,y	;s12x green
	tstw	-small,pc	;s12x green
	tstw	-small,sp	;s12x green
	tstw	-small,x	;s12x green
	tstw	-small,y	;s12x green
	tstw	0,pc	;s12x green
	tstw	0,sp	;s12x green
	tstw	0,x	;s12x green
	tstw	0,y	;s12x green
	tstw	1,sp+	;s12x green
	tstw	1,x+	;s12x green
	tstw	1,y+	;s12x green
	tstw	1,sp	;s12x green
	tstw	1,x	;s12x green
	tstw	1,y	;s12x green
	tstw	1,sp-	;s12x green
	tstw	1,x-	;s12x green
	tstw	1,y-	;s12x green
	tstw	125,pc	;s12x green
	tstw	125,sp	;s12x green
	tstw	125,x	;s12x green
	tstw	125,y	;s12x green
	tstw	15,sp	;s12x green
	tstw	15,x	;s12x green
	tstw	15,y	;s12x green
	tstw	16,sp	;s12x green
	tstw	16,x	;s12x green
	tstw	16,y	;s12x green
	tstw	8,sp+	;s12x green
	tstw	8,x+	;s12x green
	tstw	8,y+	;s12x green
	tstw	8,sp-	;s12x green
	tstw	8,x-	;s12x green
	tstw	8,y-	;s12x green
	tstw	a,sp	;s12x green
	tstw	a,x	;s12x green
	tstw	a,y	;s12x green
	tstw	b,sp	;s12x green
	tstw	b,x	;s12x green
	tstw	b,y	;s12x green
	tstw	d,sp	;s12x green
	tstw	d,x	;s12x green
	tstw	d,y	;s12x green
	tstw	dir	;s12x green
	tstw	ext	;s12x green
	tstw	ext	;s12x green
	tstw	ext,sp	;s12x green
	tstw	ext,x	;s12x green
	tstw	ext,y	;s12x green
	tstw	ind,pc	;s12x green
	tstw	ind,sp	;s12x green
	tstw	ind,x	;s12x green
	tstw	ind,y	;s12x green
	tstw	small,pc	;s12x green
	tstw	small,sp	;s12x green
	tstw	small,x	;s12x green
	tstw	small,y	;s12x green

	tsta
	tstb
	tstx	;s12x yellow
	tsty	;s12x yellow
	tsx
	tsy
	txs
	tys
	wai
	wav
	xgdx
	xgdy
	call	1,+sp $55 
	call	1,+x $55
	call	1,+y $55
	call	8,+sp $55
	call	8,+x $55
	call	8,+y $55
	call	,pc $55
	call	,sp $55
	call	,x $55
	call	,y $55
	call	1,-sp $55
	call	1,-x $55
	call	1,-y $55
	call	8,-sp $55
	call	8,-x $55
	call	8,-y $55
	call	-1,sp $55
	call	-1,x $55
	call	-1,y $55
	call	-16,sp $55
	call	-16,x $55
	call	-16,y $55
	call	-17,sp $55
	call	-17,x $55
	call	-17,y $55
	call	-small,pc $55
	call	-small,sp $55
	call	-small,x $55
	call	-small,y $55
	call	0,pc $55
	call	0,sp $55
	call	0,x $55
	call	0,y $55
	call	1,sp+ $55
	call	1,x+ $55
	call	1,y+ $55
	call	1,sp $55
	call	1,x $55
	call	1,y $55
	call	1,sp- $55
	call	1,x- $55
	call	1,y- $55
	call	125,pc $55
	call	125,sp $55
	call	125,x $55
	call	125,y $55
	call	15,sp $55
	call	15,x $55
	call	15,y $55
	call	16,sp $55
	call	16,x $55
	call	16,y $55
	call	8,sp+ $55
	call	8,x+ $55
	call	8,y+ $55
	call	8,sp- $55
	call	8,x- $55
	call	8,y- $55
	call	a,sp $55
	call	a,x $55
	call	a,y $55
	call	b,sp $55
	call	b,x $55
	call	b,y $55
	call	d,sp $55
	call	d,x $55
	call	d,y $55
	call	dir $55
	call	ext $55
	call	ext,sp $55
	call	ext,x $55
	call	ext,y $55
	call	ind,pc $55
	call	ind,sp $55
	call	ind,x $55
	call	ind,y $55
	call	small,pc $55
	call	small,sp $55
	call	small,x $55
	call	small,y $55
	pshc

	pshcw		;s12x dark blue

	rtc
	movb	#immed 3,+x
	movb	#immed 5,-y
	movb	#immed 5,sp
	movb	#immed ext
	movb	1,+sp 3,+x
	movb	1,+sp 5,-y
	movb	1,+sp 5,sp
	movb	1,+sp ext
	movb	1,+x 3,+x 
	movb	1,+x 5,-y
	movb	1,+x 5,sp
	movb	1,+x ext 
	movb	1,+y 3,+x
	movb	1,+y 5,-y
	movb	1,+y 5,sp
	movb	1,+y ext
	movb	3,+x 1,+sp 
	movb	3,+x 1,+x 
	movb	3,+x 1,+y 
	movb	3,+x 8,+sp 
	movb	3,+x 8,+x 
	movb	3,+x 8,+y 
	movb	3,+x ,pc 
	movb	3,+x ,sp 
	movb	3,+x ,x 
	movb	3,+x ,y 
	movb	3,+x 1,-sp 
	movb	3,+x 1,-x 
	movb	3,+x 1,-y 
	movb	3,+x 8,-sp 
	movb	3,+x 8,-x 
	movb	3,+x 8,-y 
	movb	3,+x -1,sp 
	movb	3,+x -1,x 
	movb	3,+x -1,y 
	movb	3,+x -16,sp 
	movb	3,+x -16,x 
	movb	3,+x -16,y 
	movb	3,+x -small,pc 
	movb	3,+x -small,sp 
	movb	3,+x -small,x 
	movb	3,+x -small,y 
	movb	3,+x 0,pc 
	movb	3,+x 0,sp 
	movb	3,+x 0,x 
	movb	3,+x 0,y 
	movb	3,+x 1,sp+ 
	movb	3,+x 1,x+ 
	movb	3,+x 1,y+ 
	movb	3,+x 1,sp 
	movb	3,+x 1,x 
	movb	3,+x 1,y 
	movb	3,+x 1,sp- 
	movb	3,+x 1,x- 
	movb	3,+x 1,y- 
	movb	3,+x 15,sp 
	movb	3,+x 15,x 
	movb	3,+x 15,y 
	movb	3,+x 8,sp+ 
	movb	3,+x 8,x+ 
	movb	3,+x 8,y+ 
	movb	3,+x 8,sp- 
	movb	3,+x 8,x- 
	movb	3,+x 8,y- 
	movb	3,+x a,sp 
	movb	3,+x a,x 
	movb	3,+x a,y 
	movb	3,+x b,sp 
	movb	3,+x b,x 
	movb	3,+x b,y 
	movb	3,+x d,sp 
	movb	3,+x d,x 
	movb	3,+x d,y 
	movb	3,+x ext 
	movb	3,+x small,pc 
	movb	3,+x small,sp 
	movb	3,+x small,x 
	movb	3,+x small,y 
	movb	8,+sp 3,+x
	movb	8,+sp 5,-y
	movb	8,+sp 5,sp
	movb	8,+sp ext
	movb	8,+x 3,+x
	movb	8,+x 5,-y
	movb	8,+x 5,sp
	movb	8,+x ext
	movb	8,+y 3,+x
	movb	8,+y 5,-y
	movb	8,+y 5,sp
	movb	8,+y ext
	movb	,pc 3,+x
	movb	,pc 5,-y
	movb	,pc 5,sp
	movb	,pc ext
	movb	,sp 3,+x
	movb	,sp 5,-y
	movb	,sp 5,sp
	movb	,sp ext
	movb	,x 3,+x
	movb	,x 5,-y
	movb	,x 5,sp
	movb	,x ext
	movb	,y 3,+x
	movb	,y 5,-y
	movb	,y 5,sp
	movb	,y ext
	movb	1,-sp 3,+x
	movb	1,-sp 5,-y
	movb	1,-sp 5,sp
	movb	1,-sp ext
	movb	1,-x 3,+x
	movb	1,-x 5,-y
	movb	1,-x 5,sp
	movb	1,-x ext
	movb	1,-y 3,+x
	movb	1,-y 5,-y
	movb	1,-y 5,sp
	movb	1,-y ext
	movb	8,-sp 3,+x
	movb	8,-sp 5,-y
	movb	8,-sp 5,sp
	movb	8,-sp ext
	movb	8,-x 3,+x
	movb	8,-x 5,-y
	movb	8,-x 5,sp
	movb	8,-x ext
	movb	8,-y 3,+x
	movb	8,-y 5,-y
	movb	8,-y 5,sp
	movb	8,-y ext
	movb	-1,sp 3,+x
	movb	-1,sp 5,-y
	movb	-1,sp 5,sp
	movb	-1,sp ext
	movb	-1,x 3,+x
	movb	-1,x 5,-y
	movb	-1,x 5,sp
	movb	-1,x ext
	movb	-1,y 3,+x
	movb	-1,y 5,-y
	movb	-1,y 5,sp
	movb	-1,y ext
	movb	-16,sp 3,+x
	movb	-16,sp 5,-y
	movb	-16,sp 5,sp
	movb	-16,sp ext
	movb	-16,x 3,+x
	movb	-16,x 5,-y
	movb	-16,x 5,sp
	movb	-16,x ext
	movb	-16,y 3,+x
	movb	-16,y 5,-y
	movb	-16,y 5,sp
	movb	-16,y ext
	movb	-small,pc 3,+x
	movb	-small,pc 5,-y
	movb	-small,pc 5,sp
	movb	-small,pc ext
	movb	-small,sp 3,+x
	movb	-small,sp 5,-y
	movb	-small,sp 5,sp
	movb	-small,sp ext
	movb	-small,x 3,+x
	movb	-small,x 5,-y
	movb	-small,x 5,sp
	movb	-small,x ext
	movb	-small,y 3,+x
	movb	-small,y 5,-y
	movb	-small,y 5,sp
	movb	-small,y ext
	movb	0,pc 3,+x
	movb	0,pc 5,-y
	movb	0,pc 5,sp
	movb	0,pc ext
	movb	0,sp 3,+x
	movb	0,sp 5,-y
	movb	0,sp 5,sp
	movb	0,sp ext
	movb	0,x 3,+x
	movb	0,x 5,-y
	movb	0,x 5,sp
	movb	0,x ext
	movb	0,y 3,+x
	movb	0,y 5,-y
	movb	0,y 5,sp
	movb	0,y ext
	movb	1,sp+ 3,+x
	movb	1,sp+ 5,-y
	movb	1,sp+ 5,sp
	movb	1,sp+ ext
	movb	1,x+ 3,+x
	movb	1,x+ 5,-y
	movb	1,x+ 5,sp
	movb	1,x+ ext
	movb	1,y+ 3,+x
	movb	1,y+ 5,-y
	movb	1,y+ 5,sp
	movb	1,y+ ext
	movb	1,sp 3,+x
	movb	1,sp 5,-y
	movb	1,sp 5,sp
	movb	1,sp ext
	movb	1,x 3,+x
	movb	1,x 5,-y
	movb	1,x 5,sp
	movb	1,x ext
	movb	1,y 3,+x
	movb	1,y 5,-y
	movb	1,y 5,sp
	movb	1,y ext
	movb	1,sp- 3,+x
	movb	1,sp- 5,-y
	movb	1,sp- 5,sp
	movb	1,sp- ext
	movb	1,x- 3,+x
	movb	1,x- 5,-y
	movb	1,x- 5,sp
	movb	1,x- ext
	movb	1,y- 3,+x
	movb	1,y- 5,-y
	movb	1,y- 5,sp
	movb	1,y- ext
	movb	5,-y 1,+sp 
	movb	5,-y 1,+x 
	movb	5,-y 1,+y 
	movb	5,-y 8,+sp 
	movb	5,-y 8,+x 
	movb	5,-y 8,+y 
	movb	5,-y ,pc 
	movb	5,-y ,sp 
	movb	5,-y ,x 
	movb	5,-y ,y 
	movb	5,-y 1,-sp 
	movb	5,-y 1,-x 
	movb	5,-y 1,-y 
	movb	5,-y 8,-sp 
	movb	5,-y 8,-x 
	movb	5,-y 8,-y 
	movb	5,-y -1,sp 
	movb	5,-y -1,x 
	movb	5,-y -1,y 
	movb	5,-y -16,sp 
	movb	5,-y -16,x 
	movb	5,-y -16,y 
	movb	5,-y -small,pc 
	movb	5,-y -small,sp 
	movb	5,-y -small,x 
	movb	5,-y -small,y 
	movb	5,-y 0,pc 
	movb	5,-y 0,sp 
	movb	5,-y 0,x 
	movb	5,-y 0,y 
	movb	5,-y 1,sp+ 
	movb	5,-y 1,x+ 
	movb	5,-y 1,y+ 
	movb	5,-y 1,sp 
	movb	5,-y 1,x 
	movb	5,-y 1,y 
	movb	5,-y 1,sp- 
	movb	5,-y 1,x- 
	movb	5,-y 1,y- 
	movb	5,-y 15,sp 
	movb	5,-y 15,x 
	movb	5,-y 15,y 
	movb	5,-y 8,sp+ 
	movb	5,-y 8,x+ 
	movb	5,-y 8,y+ 
	movb	5,-y 8,sp- 
	movb	5,-y 8,x- 
	movb	5,-y 8,y- 
	movb	5,-y a,sp 
	movb	5,-y a,x 
	movb	5,-y a,y 
	movb	5,-y b,sp 
	movb	5,-y b,x 
	movb	5,-y b,y 
	movb	5,-y d,sp 
	movb	5,-y d,x 
	movb	5,-y d,y 
	movb	5,-y ext 
	movb	5,-y small,pc 
	movb	5,-y small,sp 
	movb	5,-y small,x 
	movb	5,-y small,y 
	movb	15,sp 3,+x
	movb	15,sp 5,-y
	movb	15,sp 5,sp
	movb	15,sp ext
	movb	15,x 3,+x
	movb	15,x 5,-y
	movb	15,x 5,sp
	movb	15,x ext
	movb	15,y 3,+x
	movb	15,y 5,-y
	movb	15,y 5,sp
	movb	15,y ext
	movb	5,sp 1,+sp 
	movb	5,sp 1,+x 
	movb	5,sp 1,+y 
	movb	5,sp 8,+sp 
	movb	5,sp 8,+x 
	movb	5,sp 8,+y 
	movb	5,sp ,pc 
	movb	5,sp ,sp 
	movb	5,sp ,x 
	movb	5,sp ,y 
	movb	5,sp 1,-sp 
	movb	5,sp 1,-x 
	movb	5,sp 1,-y 
	movb	5,sp 8,-sp 
	movb	5,sp 8,-x 
	movb	5,sp 8,-y 
	movb	5,sp -1,sp 
	movb	5,sp -1,x 
	movb	5,sp -1,y 
	movb	5,sp -16,sp 
	movb	5,sp -16,x 
	movb	5,sp -16,y 
	movb	5,sp -small,pc 
	movb	5,sp -small,sp 
	movb	5,sp -small,x 
	movb	5,sp -small,y 
	movb	5,sp 0,pc 
	movb	5,sp 0,sp 
	movb	5,sp 0,x 
	movb	5,sp 0,y 
	movb	5,sp 1,sp+ 
	movb	5,sp 1,x+ 
	movb	5,sp 1,y+ 
	movb	5,sp 1,sp 
	movb	5,sp 1,x 
	movb	5,sp 1,y 
	movb	5,sp 1,sp- 
	movb	5,sp 1,x- 
	movb	5,sp 1,y- 
	movb	5,sp 8,sp+ 
	movb	5,sp 8,x+ 
	movb	5,sp 8,y+ 
	movb	5,sp 8,sp- 
	movb	5,sp 8,x- 
	movb	5,sp 8,y- 
	movb	5,sp a,sp 
	movb	5,sp a,x 
	movb	5,sp a,y 
	movb	5,sp b,sp 
	movb	5,sp b,x 
	movb	5,sp b,y 
	movb	5,sp d,sp 
	movb	5,sp d,x 
	movb	5,sp d,y 
	movb	5,sp ext 
	movb	5,sp small,pc 
	movb	5,sp small,sp 
	movb	5,sp small,x 
	movb	5,sp small,y 
	movb	8,sp+ 3,+x
	movb	8,sp+ 5,-y
	movb	8,sp+ 5,sp
	movb	8,sp+ ext
	movb	8,x+ 3,+x
	movb	8,x+ 5,-y
	movb	8,x+ 5,sp
	movb	8,x+ ext
	movb	8,y+ 3,+x
	movb	8,y+ 5,-y
	movb	8,y+ 5,sp
	movb	8,y+ ext
	movb	8,sp- 3,+x
	movb	8,sp- 5,-y
	movb	8,sp- 5,sp
	movb	8,sp- ext
	movb	8,x- 3,+x
	movb	8,x- 5,-y
	movb	8,x- 5,sp
	movb	8,x- ext
	movb	8,y- 3,+x
	movb	8,y- 5,-y
	movb	8,y- 5,sp
	movb	8,y- ext
	movb	a,sp 3,+x
	movb	a,sp 5,-y
	movb	a,sp 5,sp
	movb	a,sp ext
	movb	a,x 3,+x
	movb	a,x 5,-y
	movb	a,x 5,sp
	movb	a,x ext
	movb	a,y 3,+x
	movb	a,y 5,-y
	movb	a,y 5,sp
	movb	a,y ext
	movb	b,sp 3,+x
	movb	b,sp 5,-y
	movb	b,sp 5,sp
	movb	b,sp ext
	movb	b,x 3,+x
	movb	b,x 5,-y
	movb	b,x 5,sp
	movb	b,x ext
	movb	b,y 3,+x
	movb	b,y 5,-y
	movb	b,y 5,sp
	movb	b,y ext 
	movb	d,sp 3,+x
	movb	d,sp 5,-y
	movb	d,sp 5,sp
	movb	d,sp ext
	movb	d,x 3,+x
	movb	d,x 5,-y
	movb	d,x 5,sp
	movb	d,x ext
	movb	d,y 3,+x
	movb	d,y 5,-y
	movb	d,y 5,sp
	movb	d,y ext
	movb	ext 1,+sp 
	movb	ext 1,+x 
	movb	ext 1,+y 
	movb	ext 8,+sp 
	movb	ext 8,+x 
	movb	ext 8,+y 
	movb	ext ,pc 
	movb	ext ,sp 
	movb	ext ,x   
	movb	ext ,y 
	movb	ext 1,-sp
	movb	ext 1,-x
	movb	ext 1,-y 
	movb	ext 8,-sp 
	movb	ext 8,-x 
	movb	ext 8,-y  
	movb	ext -1,sp 
	movb	ext -1,x 
	movb	ext -1,y 
	movb	ext -16,sp 
	movb	ext -16,x 
	movb	ext -16,y 
	movb	ext -small,pc 
	movb	ext -small,sp 
	movb	ext -small,x 
	movb	ext -small,y 
	movb	ext 0,pc 
	movb	ext 0,sp 
	movb	ext 0,x 
	movb	ext 0,y 
	movb	ext 1,sp+ 
	movb	ext 1,x+ 
	movb	ext 1,y+ 
	movb	ext 1,sp 
	movb	ext 1,x 
	movb	ext 1,y 
	movb	ext 1,sp- 
	movb	ext 1,x- 
	movb	ext 1,y- 
	movb	ext 8,sp+ 
	movb	ext 8,x+ 
	movb	ext 8,y+ 
	movb	ext 8,sp- 
	movb	ext 8,x- 
	movb	ext 8,y- 
	movb	ext a,sp 
	movb	ext a,x 
	movb	ext a,y
	movb	ext b,sp 
	movb	ext b,x 
	movb	ext b,y 
	movb	ext d,sp 
	movb	ext d,x 
	movb	ext d,y 
	movb	ext ext 
	movb	ext small,pc
	movb	ext small,sp 
	movb	ext small,x 
	movb	ext small,y 
	movb	small,pc 3,+x
	movb	small,pc 5,-y
	movb	small,pc 5,sp
	movb	small,pc ext
	movb	small,sp 3,+x
	movb	small,sp 5,-y
	movb	small,sp 5,sp
	movb	small,sp ext
	movb	small,x 3,+x
	movb	small,x 5,-y
	movb	small,x 5,sp
	movb	small,x ext
	movb	small,y 3,+x
	movb	small,y 5,-y
	movb	small,y 5,sp
	movb	small,y ext
	movw	#immed 3,+x
	movw	#immed 5,-y
	movw	#immed 5,sp
	movw	#immed ext
	movw	1,+sp 3,+x
	movw	1,+sp 5,-y
	movw	1,+sp 5,sp
	movw	1,+sp ext
	movw	1,+x 3,+x
	movw	1,+x 5,-y
	movw	1,+x 5,sp
	movw	1,+x ext
	movw	1,+y 3,+x
	movw	1,+y 5,-y
	movw	1,+y 5,sp
	movw	1,+y ext
	movw	3,+x 1,+sp 
	movw	3,+x 1,+x 
	movw	3,+x 1,+y 
	movw	3,+x 8,+sp 
	movw	3,+x 8,+x 
	movw	3,+x 8,+y 
	movw	3,+x ,pc 
	movw	3,+x ,sp 
	movw	3,+x ,x 
	movw	3,+x ,y 
	movw	3,+x 1,-sp 
	movw	3,+x 1,-x 
	movw	3,+x 1,-y 
	movw	3,+x 8,-sp 
	movw	3,+x 8,-x 
	movw	3,+x 8,-y 
	movw	3,+x -1,sp 
	movw	3,+x -1,x 
	movw	3,+x -1,y 
	movw	3,+x -16,sp 
	movw	3,+x -16,x 
	movw	3,+x -16,y 
	movw	3,+x -small,pc 
	movw	3,+x -small,sp 
	movw	3,+x -small,x 
	movw	3,+x -small,y 
	movw	3,+x 0,pc 
	movw	3,+x 0,sp 
	movw	3,+x 0,x 
	movw	3,+x 0,y 
	movw	3,+x 1,sp+ 
	movw	3,+x 1,x+ 
	movw	3,+x 1,y+ 
	movw	3,+x 1,sp 
	movw	3,+x 1,x 
	movw	3,+x 1,y 
	movw	3,+x 1,sp- 
	movw	3,+x 1,x- 
	movw	3,+x 1,y- 
	movw	3,+x 8,sp+ 
	movw	3,+x 8,x+ 
	movw	3,+x 8,y+ 
	movw	3,+x 8,sp- 
	movw	3,+x 8,x- 
	movw	3,+x 8,y- 
	movw	3,+x a,sp 
	movw	3,+x a,x 
	movw	3,+x a,y 
	movw	3,+x b,sp 
	movw	3,+x b,x 
	movw	3,+x b,y 
	movw	3,+x d,sp 
	movw	3,+x d,x 
	movw	3,+x d,y 
	movw	3,+x ext 
	movw	3,+x small,pc 
	movw	3,+x small,sp 
	movw	3,+x small,x 
	movw	3,+x small,y 
	movw	8,+sp 3,+x
	movw	8,+sp 5,-y
	movw	8,+sp 5,sp
	movw	8,+sp ext
	movw	8,+x 3,+x
	movw	8,+x 5,-y
	movw	8,+x 5,sp
	movw	8,+x ext
	movw	8,+y 3,+x
	movw	8,+y 5,-y
	movw	8,+y 5,sp
	movw	8,+y ext
	movw	,pc 3,+x
	movw	,pc 5,-y
	movw	,pc 5,sp
	movw	,pc ext
	movw	,sp 3,+x
	movw	,sp 5,-y
	movw	,sp 5,sp
	movw	,sp ext
	movw	,x 3,+x
	movw	,x 5,-y
	movw	,x 5,sp
	movw	,x ext
	movw	,y 3,+x
	movw	,y 5,-y
	movw	,y 5,sp
	movw	,y ext
	movw	1,-sp 3,+x
	movw	1,-sp 5,-y
	movw	1,-sp 5,sp
	movw	1,-sp ext
	movw	1,-x 3,+x
	movw	1,-x 5,-y
	movw	1,-x 5,sp
	movw	1,-x ext
	movw	1,-y 3,+x
	movw	1,-y 5,-y
	movw	1,-y 5,sp
	movw	1,-y ext
	movw	8,-sp 3,+x
	movw	8,-sp 5,-y
	movw	8,-sp 5,sp
	movw	8,-sp ext
	movw	8,-x 3,+x
	movw	8,-x 5,-y
	movw	8,-x 5,sp
	movw	8,-x ext
	movw	8,-y 3,+x
	movw	8,-y 5,-y
	movw	8,-y 5,sp
	movw	8,-y ext
	movw	-1,sp 3,+x
	movw	-1,sp 5,-y
	movw	-1,sp 5,sp
	movw	-1,sp ext
	movw	-1,x 3,+x
	movw	-1,x 5,-y
	movw	-1,x 5,sp
	movw	-1,x ext
	movw	-1,y 3,+x
	movw	-1,y 5,-y
	movw	-1,y 5,sp
	movw	-1,y ext
	movw	-16,sp 3,+x
	movw	-16,sp 5,-y
	movw	-16,sp 5,sp
	movw	-16,sp ext
	movw	-16,x 3,+x
	movw	-16,x 5,-y
	movw	-16,x 5,sp
	movw	-16,x ext
	movw	-16,y 3,+x
	movw	-16,y 5,-y
	movw	-16,y 5,sp
	movw	-16,y ext
	movw	-small,pc 3,+x
	movw	-small,pc 5,-y
	movw	-small,pc 5,sp
	movw	-small,pc ext
	movw	-small,sp 3,+x
	movw	-small,sp 5,-y
	movw	-small,sp 5,sp
	movw	-small,sp ext
	movw	-small,x 3,+x
	movw	-small,x 5,-y
	movw	-small,x 5,sp
	movw	-small,x ext
	movw	-small,y 3,+x
	movw	-small,y 5,-y
	movw	-small,y 5,sp
	movw	-small,y ext
	movw	0,pc 3,+x
	movw	0,pc 5,-y
	movw	0,pc 5,sp
	movw	0,pc ext
	movw	0,sp 3,+x
	movw	0,sp 5,-y
	movw	0,sp 5,sp
	movw	0,sp ext
	movw	0,x 3,+x
	movw	0,x 5,-y
	movw	0,x 5,sp
	movw	0,x ext
	movw	0,y 3,+x
	movw	0,y 5,-y
	movw	0,y 5,sp
	movw	0,y ext
	movw	1,sp+ 3,+x
	movw	1,sp+ 5,-y
	movw	1,sp+ 5,sp
	movw	1,sp+ ext
	movw	1,x+ 3,+x
	movw	1,x+ 5,-y
	movw	1,x+ 5,sp
	movw	1,x+ ext
	movw	1,y+ 3,+x
	movw	1,y+ 5,-y
	movw	1,y+ 5,sp
	movw	1,y+ ext
	movw	1,sp 3,+x
	movw	1,sp 5,-y
	movw	1,sp 5,sp
	movw	1,sp ext
	movw	1,x 3,+x
	movw	1,x 5,-y
	movw	1,x 5,sp
	movw	1,x ext
	movw	1,y 3,+x
	movw	1,y 5,-y 
	movw	1,y 5,sp
	movw	1,y ext
	movw	1,sp- 3,+x
	movw	1,sp- 5,-y
	movw	1,sp- 5,sp
	movw	1,sp- ext
	movw	1,x- 3,+x
	movw	1,x- 5,-y
	movw	1,x- 5,sp
	movw	1,x- ext
	movw	1,y- 3,+x
	movw	1,y- 5,-y
	movw	1,y- 5,sp
	movw	1,y- ext
	movw	5,-y 1,+sp 
	movw	5,-y 1,+x 
	movw	5,-y 1,+y 
	movw	5,-y 8,+sp 
	movw	5,-y 8,+x 
	movw	5,-y 8,+y 
	movw	5,-y ,pc 
	movw	5,-y ,sp 
	movw	5,-y ,x 
	movw	5,-y ,y 
	movw	5,-y 1,-sp 
	movw	5,-y 1,-x 
	movw	5,-y 1,-y 
	movw	5,-y 8,-sp 
	movw	5,-y 8,-x 
	movw	5,-y 8,-y 
	movw	5,-y -1,sp 
	movw	5,-y -1,x 
	movw	5,-y -1,y 
	movw	5,-y -16,sp 
	movw	5,-y -16,x 
	movw	5,-y -16,y 
	movw	5,-y -small,pc 
	movw	5,-y -small,sp 
	movw	5,-y -small,x 
	movw	5,-y -small,y 
	movw	5,-y 0,pc 
	movw	5,-y 0,sp 
	movw	5,-y 0,x 
	movw	5,-y 0,y 
	movw	5,-y 1,sp+ 
	movw	5,-y 1,x+ 
	movw	5,-y 1,y+ 
	movw	5,-y 1,sp 
	movw	5,-y 1,x 
	movw	5,-y 1,y 
	movw	5,-y 1,sp- 
	movw	5,-y 1,x- 
	movw	5,-y 1,y- 
	movw	5,-y 15,sp 
	movw	5,-y 15,x 
	movw	5,-y 15,y 
	movw	5,-y 8,sp+ 
	movw	5,-y 8,x+ 
	movw	5,-y 8,y+ 
	movw	5,-y 8,sp- 
	movw	5,-y 8,x- 
	movw	5,-y 8,y- 
	movw	5,-y a,sp 
	movw	5,-y a,x 
	movw	5,-y a,y 
	movw	5,-y b,sp 
	movw	5,-y b,x 
	movw	5,-y b,y 
	movw	5,-y d,sp 
	movw	5,-y d,x 
	movw	5,-y d,y 
	movw	5,-y ext 
	movw	5,-y small,pc 
	movw	5,-y small,sp 
	movw	5,-y small,x 
	movw	5,-y small,y 
	movw	15,sp 3,+x
	movw	15,sp 5,-y
	movw	15,sp 5,sp
	movw	15,sp ext
	movw	15,x 3,+x
	movw	15,x 5,-y
	movw	15,x 5,sp
	movw	15,x ext
	movw	15,y 3,+x
	movw	15,y 5,-y
	movw	15,y 5,sp
	movw	15,y ext
	movw	5,sp 1,+sp 
	movw	5,sp 1,+x 
	movw	5,sp 1,+y 
	movw	5,sp 8,+sp 
	movw	5,sp 8,+x 
	movw	5,sp 8,+y 
	movw	5,sp ,pc 
	movw	5,sp ,sp 
	movw	5,sp ,x 
	movw	5,sp ,y 
	movw	5,sp 1,-sp 
	movw	5,sp 1,-x 
	movw	5,sp 1,-y 
	movw	5,sp 8,-sp 
	movw	5,sp 8,-x 
	movw	5,sp 8,-y 
	movw	5,sp -1,sp 
	movw	5,sp -1,x 
	movw	5,sp -1,y 
	movw	5,sp -16,sp 
	movw	5,sp -16,x 
	movw	5,sp -16,y 
	movw	5,sp -small,pc 
	movw	5,sp -small,sp 
	movw	5,sp -small,x 
	movw	5,sp -small,y 
	movw	5,sp 0,pc 
	movw	5,sp 0,sp 
	movw	5,sp 0,x 
	movw	5,sp 0,y 
	movw	5,sp 1,sp+ 
	movw	5,sp 1,x+ 
	movw	5,sp 1,y+ 
	movw	5,sp 1,sp 
	movw	5,sp 1,x 
	movw	5,sp 1,y 
	movw	5,sp 1,sp- 
	movw	5,sp 1,x- 
	movw	5,sp 1,y- 
	movw	5,sp 8,sp+ 
	movw	5,sp 8,x+ 
	movw	5,sp 8,y+ 
	movw	5,sp 8,sp- 
	movw	5,sp 8,x- 
	movw	5,sp 8,y- 
	movw	5,sp a,sp 
	movw	5,sp a,x 
	movw	5,sp a,y 
	movw	5,sp b,sp 
	movw	5,sp b,x 
	movw	5,sp b,y 
	movw	5,sp d,sp 
	movw	5,sp d,x 
	movw	5,sp d,y 
	movw	5,sp ext 
	movw	5,sp small,pc 
	movw	5,sp small,sp 
	movw	5,sp small,x 
	movw	5,sp small,y 
	movw	8,sp+ 3,+x
	movw	8,sp+ 5,-y
	movw	8,sp+ 5,sp
	movw	8,sp+ ext
	movw	8,x+ 3,+x
	movw	8,x+ 5,-y
	movw	8,x+ 5,sp
	movw	8,x+ ext
	movw	8,y+ 3,+x
	movw	8,y+ 5,-y
	movw	8,y+ 5,sp
	movw	8,y+ ext
	movw	8,sp- 3,+x
	movw	8,sp- 5,-y
	movw	8,sp- 5,sp
	movw	8,sp- ext
	movw	8,x- 3,+x
	movw	8,x- 5,-y
	movw	8,x- 5,sp
	movw	8,x- ext
	movw	8,y- 3,+x
	movw	8,y- 5,-y
	movw	8,y- 5,sp
	movw	8,y- ext
	movw	a,sp 3,+x
	movw	a,sp 5,-y
	movw	a,sp 5,sp
	movw	a,sp ext
	movw	a,x 3,+x
	movw	a,x 5,-y
	movw	a,x 5,sp
	movw	a,x ext
	movw	a,y 3,+x
	movw	a,y 5,-y
	movw	a,y 5,sp
	movw	a,y ext
	movw	b,sp 3,+x
	movw	b,sp 5,-y
	movw	b,sp 5,sp
	movw	b,sp ext
	movw	b,x 3,+x
	movw	b,x 5,-y
	movw	b,x 5,sp
	movw	b,x ext
	movw	b,y 3,+x
	movw	b,y 5,-y
	movw	b,y 5,sp
	movw	b,y ext
	movw	d,sp 3,+x
	movw	d,sp 5,-y
	movw	d,sp 5,sp
	movw	d,sp ext
	movw	d,x 3,+x
	movw	d,x 5,-y
	movw	d,x 5,sp
	movw	d,x ext
	movw	d,y 3,+x
	movw	d,y 5,-y
	movw	d,y 5,sp
	movw	d,y ext 
	movw	ext 1,+sp 
	movw	ext 1,+x 
	movw	ext 1,+y 
	movw	ext 8,+sp 
	movw	ext 8,+x 
	movw	ext 8,+y 
	movw	ext ,pc 
	movw	ext ,sp 
	movw	ext ,x 
	movw	ext ,y 
	movw	ext 1,-sp 
	movw	ext 1,-x 
	movw	ext 1,-y 
	movw	ext 8,-sp 
	movw	ext 8,-x 
	movw	ext 8,-y 
	movw	ext -1,sp 
	movw	ext -1,x 
	movw	ext -1,y 
	movw	ext -16,sp 
	movw	ext -16,x 
	movw	ext -16,y 
	movw	ext -small,pc 
	movw	ext -small,sp 
	movw	ext -small,x 
	movw	ext -small,y 
	movw	ext 0,pc 
	movw	ext 0,sp 
	movw	ext 0,x 
	movw	ext 0,y 
	movw	ext 1,sp+ 
	movw	ext 1,x+ 
	movw	ext 1,y+ 
	movw	ext 1,sp 
	movw	ext 1,x 
	movw	ext 1,y 
	movw	ext 1,sp- 
	movw	ext 1,x- 
	movw	ext 1,y- 
	movw	ext 8,sp+ 
	movw	ext 8,x+ 
	movw	ext 8,y+ 
	movw	ext 8,sp- 
	movw	ext 8,x- 
	movw	ext 8,y- 
	movw	ext a,sp 
	movw	ext a,x 
	movw	ext a,y 
	movw	ext b,sp 
	movw	ext b,x 
	movw	ext b,y 
	movw	ext d,sp 
	movw	ext d,x 
	movw	ext d,y 
	movw	ext ext
	movw	ext small,pc 
	movw	ext small,sp 
	movw	ext small,x 
	movw	ext small,y 
	movw	small,pc 3,+x
	movw	small,pc 5,-y
	movw	small,pc 5,sp
	movw	small,pc ext
	movw	small,sp 3,+x
	movw	small,sp 5,-y
	movw	small,sp 5,sp
	movw	small,sp ext
	movw	small,x 3,+x
	movw	small,x 5,-y
	movw	small,x 5,sp
	movw	small,x ext
	movw	small,y 3,+x
	movw	small,y 5,-y
	movw	small,y 5,sp
	movw	small,y ext
	movb	1,x+ 1,y- 
	movb	0,x  0,x 
