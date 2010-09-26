#ifndef TYPES_H
#define	TYPES_H

#ifndef NULL
#define NULL (void *) 0
#endif

#define SUCCESS  1
#define FAILURE  0

/* Define standard character constants. */
#define EOL             '\n'            /* End of line character        */
#define EOS             '\0'            /* End of string character      */
#define CACHE_LINE_SIZE 32

/* Define standard macros. */
#define DIM(x)    (sizeof(x)/sizeof(*(x))) /* Dimension of an array     */
#define HIBYTE(x) (((x) >> 8) & 0xff)      /* High byte of 16-bit word  */
#define LOBYTE(x) ((x) & 0xff)             /* Low byte of 16-bit word   */
#define HIWORD(x) (((x) >> 16) & 0xffffL)  /* Upper half of 32-bit word */
#define LOWORD(x) ((x) & 0xffffL)          /* Lower half of 32-bit word */

/* Define Fundamental Data Types. */
    typedef unsigned char  bool;        /* Unsigned  1-bit quantity     */
    typedef unsigned char  uint8;       /* Unsigned  8-bit quantity     */
    typedef unsigned short uint16;      /* Unsigned 16-bit quantity     */
    typedef unsigned long  uint32;      /* Unsigned 32-bit quantity     */
    typedef signed char    sint8;       /* Signed    8-bit quantity     */
    typedef short          sint16;      /* Signed   16-bit quantity     */
    typedef long           sint32;      /* Signed   32-bit quantity     */

/* Data types for function pointers     */
typedef uint32   (*UFUNCPTR) ();     
typedef sint32   (*SFUNCPTR) ();     
typedef void     (*VOIDFUNCPTR) ();
typedef	void (interrupt_handler_t)(void *);

#define fncdef(a,b,c,d) c a d;          /* External function prototyping*/
#define FNC_PTR(a,b,c)  b (*a) c        /* Function pointer declaration */

typedef enum vector_type
{
    VT_DIRECT   = 0,
    VT_INTR     = 1
} VECTOR_TYPE;

/*-----------------------------------------------------------------------
    Define macros to orient multi-byte quantities into Internet or Ethernet
    network order.  For those platforms which must do byte swapping
    (little-endian architectures), considerable code savings, and possibly
    execution time savings, may be possible by implementing the "swap"
    operations with assembly language or other optimized facilities.  If
    your platform must swap, but you don't have functions available, you
    can use the generic C language versions which are in comments below.
 -----------------------------------------------------------------------*/
#if LITTLE_ENDIAN

#define swap16(x)       ((uint16) (((x) << 8) | (((x) >> 8) & 0xff)))
#define swap32(x)       ((uint32) (((x) << 24) | (((x) << 8) & 0xff0000L) | \
                         (((x) >> 8) & 0xff00L) | (((x) >> 24) & 0xffL)))

#else /* Big Endian */

#define swap16(x)       (x)
#define swap32(x)       (x)

#endif /* LITTLE_ENDIAN */

#define PRINTF s1printf

#endif  /* TYPES_H */
