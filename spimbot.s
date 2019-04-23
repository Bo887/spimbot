.data
# syscall constants
PRINT_STRING            = 4
PRINT_CHAR              = 11
PRINT_INT               = 1

# memory-mapped I/O
VELOCITY                = 0xffff0010
ANGLE                   = 0xffff0014
ANGLE_CONTROL           = 0xffff0018

BOT_X                   = 0xffff0020
BOT_Y                   = 0xffff0024

TIMER                   = 0xffff001c

SUBMIT_ORDER 		= 0xffff00b0
DROPOFF 		= 0xffff00c0
PICKUP 			= 0xffff00e0
GET_TILE_INFO		= 0xffff0050
SET_TILE		= 0xffff0058

REQUEST_PUZZLE          = 0xffff00d0
SUBMIT_SOLUTION         = 0xffff00d4

BONK_INT_MASK           = 0x1000
BONK_ACK                = 0xffff0060

TIMER_INT_MASK          = 0x8000
TIMER_ACK               = 0xffff006c

REQUEST_PUZZLE_INT_MASK = 0x800
REQUEST_PUZZLE_ACK      = 0xffff00d8

GET_MONEY               = 0xffff00e4
GET_LAYOUT 		= 0xffff00ec
SET_REQUEST 		= 0xffff00f0
GET_REQUEST 	        = 0xffff00f4

GET_INVENTORY 		= 0xffff0040
GET_TURNIN_ORDER 	= 0xffff0044
GET_TURNIN_USERS	= 0xffff0048
GET_SHARED 		= 0xffff004c

GET_BOOST 		= 0xffff0070
GET_INGREDIENT_INSTANT 	= 0xffff0074
FINISH_APPLIANCE_INSTANT= 0xffff0078

puzzle:		    .space 1832

### PRECOMPUTED PUZZLE SOLVING TABLES ###

puzzle_transition:	.byte 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 0 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2 0 0 0 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 3 0 0 0 0 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4 0 0 0 0 1 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 5 4 5 4 1 0 1 0 0 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 6 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 7 0 0 0 0 0 0 0 
puzzle_touch_vert:	.byte 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 0 3 7 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 0 0 7 7 7 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 0 7 7 7 14 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 0 0 0 0 14 14 14 14 14 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 0 3 0 3 14 15 14 15 15 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 0 0 15 15 15 15 15 15 15 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 0 15 15 15 15 15 15 15 

### END PRECOMPUTED TABLES ###
puzzle_queue:	    .space 400
puzzle_contact:	    .space 200
			
d_puzzle_pending:   .word 0

timer_int_active:   .word 0         # global flag that is non-zero when the timer interrupt is active

bot_on_left:        .word 0         # true if the bot is on the left side, false if bot is on the right side
map:                .space 225      # stores the map from GET_LAYOUT
tile_types:         .space 5        # 5 bytes for a 5-element char array representing what is in the 5 item locations.

PI:                 .float 3.14
three:              .float 3.0
five:               .float 5.0
F180:               .float 180.0

.text

# -----------------------------------------------------------------------
# main function - entry point
# -----------------------------------------------------------------------
main:
	# Construct interrupt mask
	li          $t4, 0
	or          $t4, $t4, BONK_INT_MASK # request bonk
	or          $t4, $t4, REQUEST_PUZZLE_INT_MASK	        # puzzle interrupt bit
        or          $t4, $t4, TIMER_INT_MASK        #enable timer interrupts
	or          $t4, $t4, 1 # global enable
	mtc0        $t4, $12

        # determine which side of the map we are on.
        lw          $t0, BOT_X
        slt         $t1, $t0, 150       # $t1 = BOT_X < 150 ? 1 : 0
        sw          $t1, bot_on_left    # save to global variable

        # fill tile_types
        la          $t0, map            # $t0 = &map
        sw          $t0, GET_LAYOUT
        la          $t2, tile_types     # $t2 = &tile_types
        bne         $t1, 0, fill_right_tiles

fill_left_tiles:
        lbu         $t3, 165($t0)
        sb          $t3, 0($t2)
        lbu         $t3, 105($t0)
        sb          $t3, 1($t2)
        lbu         $t3, 45($t0)
        sb          $t3, 2($t2)
        lbu         $t3, 32($t0)
        sb          $t3, 3($t2)
        lbu         $t3, 35($t0)
        sb          $t3, 4($t2)

fill_right_tiles:
        lbu         $t3, 179($t0)
        sb          $t3, 0($t2)
        lbu         $t3, 119($t0)
        sb          $t3, 1($t2)
        lbu         $t3, 59($t0)
        sb          $t3, 2($t2)
        lbu         $t3, 42($t0)
        sb          $t3, 3($t2)
        lbu         $t3, 39($t0)
        sb          $t3, 4($t2)

        lw          $t0, bot_on_left
        beq         $t0, 0, right_main  # jump to the corresponsind "main" depending on which side we are

left_main:
        la          $t0, puzzle
        #sw          $t0, REQUEST_PUZZLE
	
	#Fill in your code here
        li          $a0, 17
        li          $a1, 50
        jal         set_move_point_target
        li          $a0, 70
        li          $a1, 80
        jal         set_move_point_target
        li          $a0, 70
        li          $a1, 270
        jal         set_move_point_target
        li          $a0, 70
        li          $a1, 80
        jal         set_move_point_target
        li          $a0, 17
        li          $a1, 50
        jal         set_move_point_target
        li          $a0, 10
        li          $a1, 10
        jal         set_move_point_target

left_infinite:
	lw	    $t0, d_puzzle_pending	# will be set in kernel mode when puzzle interrupt occurs
	beq	    $t0, $zero, left_no_puzzle
	
	sb	    $zero, d_puzzle_pending
	lw	    $s0, TIMER
	la	    $a0, puzzle
	jal	    puzzle_bolt
	
	la	    $t0, puzzle
	sw	    $t0, SUBMIT_SOLUTION
	
	lw	    $s0, TIMER
	sw	    $t0, REQUEST_PUZZLE	# get another puzzle
	
left_no_puzzle:
	j	    left_infinite

right_main:
        li          $a0, 10
        li          $a1, 10
        jal         set_move_point_target

right_infinite:
        j           right_infinite

nothing:
        j nothing
	
# -----------------------------------------------------------------------
# optimized puzzle solving function
# -----------------------------------------------------------------------

.globl puzzle_bolt
puzzle_bolt:
        sub         $sp, $sp, 44	# free up registers to store:
        sw          $ra, 0($sp)	# &touchVert
        sw          $s0, 4($sp)	# scanStart
        sw          $s1, 8($sp)	# marker
        sw          $s2, 12($sp)	# Puzzle.Bitmap.Length
        sw          $s3, 16($sp)	# base address of the bitmap
	sw          $s4, 20($sp)	# qStart
	sw          $s5, 24($sp)	# qEnd
	sw          $s6, 28($sp)	# Puzzle.BytesWidth
	sw          $s7, 32($sp)	# how many bitmap bytes per row are valid
	sw          $gp, 36($sp)	# &transitions
	sw          $fp, 40($sp)	# &contact
	
	li	    $s0, 0		# scanStart = 0
	li	    $s1, 'A'	# marker
	li	    $s6, 5		# always 5 bytes - documentation is a lie
	la	    $ra, puzzle_touch_vert
	la	    $gp, puzzle_transition
	la	    $fp, puzzle_contact
	
	lw	    $t0, 4($a0)	# width
	and	    $t1, $t0, 7	# width & 0x7
	srl	    $s7, $t0, 3	# floor(width / 8)
	beq	    $t1, $zero, pb_no_ceil_needed
	add	    $s7, $s7, 1	# ceil(width / 8)
pb_no_ceil_needed:
	lw	    $t1, 0($a0)	# height
	mul	    $s2, $s6, $t1	# Puzzle.Bitmap.Length
	mul	    $s3, $t0, $t1	# width * height
	add	    $s3, $a0, $s3	# &puzzle->bitmap - 8
	add	    $s3, $s3, 8	# &puzzle->bitmap
	
pb_outer_loop_top:
	beq	    $s0, $s2, pb_outer_loop_done
	
	add	    $t0, $s3, $s0	# &puzzle->bitmap[scanStart]
	lbu	    $t0, 0($t0)	# chunk = puzzle->bitmap[scanStart]
	bne	    $t0, $zero, pb_start_fill
	add	    $s0, $s0, 1	# scanStart++
	j	    pb_outer_loop_top
	
pb_start_fill:
	la	    $t0, puzzle_contact	# zero out the contact array
	add	    $t1, $t0, 200
pb_clear_contact_top:
	beq	    $t0, $t1, pb_clear_contact_done
	sw	    $zero, 0($t0)
	sw	    $zero, 4($t0)
	sw	    $zero, 8($t0)
	sw	    $zero, 12($t0)
	sw	    $zero, 16($t0)
	add	    $t0, $t0, 20		# zero 5 words (20 bytes) per iteration
	j	    pb_clear_contact_top
	
pb_clear_contact_done:
	la	    $s4, puzzle_queue	# qStart = 0
	add	    $s5, $s4, 1		# qEnd = 1
	sb	    $s0, 0($s4)		# queue[0] = scanStart
	
pb_fill_loop_top:
	beq	    $s4, $s5, pb_fill_loop_done
	lbu	    $t5, 0($s4)	# position = queue[qStart]
	add	    $t4, $s3, $t5	# &puzzle->bitmap[position]
	lbu	    $t6, 0($t4)	# chunk = puzzle->bitmap[position]
	beq	    $t6, $zero, pb_fill_loop_next
	
	add	    $v0, $fp, $t5	# &contact[position]
	lbu	    $t0, 0($v0)	# touching = contact[position]
	sll	    $t1, $t6, 8	# chunk << 8
	or	    $t1, $t1, $t0	# lookupId = chunk << 8 | touching
	add	    $t0, $gp, $t1	# &transitions[lookupId]
	lbu	    $t0, 0($t0)	# transitions[lookupId]
	sb	    $t0, 0($t4)	# puzzle->bitmap[position] = transitions[lookupId]
	nor	    $t0, $t0, $t0	# ~transitions[lookupId]
	and	    $t3, $t0, $t6	# changed = chunk & ~transitions[lookupId]
	beq	    $t3, $zero, pb_fill_loop_next
	and	    $a2, $t3, 0x80	# nonzero if need to use touchLeft
	and	    $a3, $t3, 0x01	# likewise for touchRight
	
	div	    $t5, $s6	# need both quotient and remainder
	mfhi	    $t7		# position % Puzzle.BytesWidth
	bge	    $t7, $s7, pb_fill_loop_next
	mflo	    $t8		# position / Puzzle.BytesWidth
	sll	    $t7, $t7, 3	# (position % Puzzle.BytesWidth) * 8
	lw	    $t0, 4($a0)	# width
	mul	    $t8, $t8, $t0	# (position / Puzzle.BytesWidth) * Puzzle.Width
	add	    $t7, $t7, $t8	# mapPos
	
	add	    $a1, $ra, $t1	# &touchVert[lookupId]
	lbu	    $a1, 0($a1)	# touchVert[lookupId]
	
	add	    $t1, $a0, $t7	# &puzzle->map[mapPos] - 8
pb_write_map_top:
	beq	    $t3, $zero, pb_write_map_done
	and	    $t0, $t3, 0x7f	# see if cutting off the top bit changes the value
	beq	    $t3, $t0, pb_write_map_next
	sb	    $s1, 8($t1)	# puzzle->map[mapPos] = marker
pb_write_map_next:
	sll	    $t3, $t0, 1	# changed <<= 1
	add	    $t1, $t1, 1
	j	    pb_write_map_top
	
pb_write_map_done:
	# up
	sub	    $t1, $t5, $s6	# upPos = position - puzzle.BytesWidth
	blt	    $t1, $zero, pb_no_up
	lbu	    $t0, -5($t4)	# puzzle->bitmap[upPos]
	beq	    $t0, $zero, pb_no_up
	lbu	    $t3, -5($v0)	# contact[upPos]
	or	    $t3, $t3, $a1	# contact[upPos] | touchVert[lookupId]
	sb	    $t3, -5($v0)
	sb	    $t1, 0($s5)	# queue[qEnd] = upPos
	add	    $s5, $s5, 1	# qEnd++
	
pb_no_up:
	# down
	add	    $t8, $t5, $s6	# downPos = position + puzzle.BytesWidth
	bge	    $t8, $s2, pb_no_down
	lbu	    $t0, 5($t4)	# puzzle->bitmap[downPos]
	beq	    $t0, $zero, pb_no_down
	lbu	    $t3, 5($v0)	# contact[downPos]
	or	    $t3, $t3, $a1	# contact[downPos] | touchVert[lookupId]
	sb	    $t3, 5($v0)
	sb	    $t8, 0($s5)	# queue[qEnd] = downPos
	add	    $s5, $s5, 1	# qEnd++

pb_no_down:
	# left
	beq	    $a2, $zero, pb_no_left
	div	    $t5, $s6
	mfhi	    $t0		# position % Puzzle.BytesWidth
	beq	    $t0, $zero, pb_no_left
	lbu	    $t2, -1($t4)	# puzzle->bitmap[position - 1]
	beq	    $t2, $zero, pb_no_direct_left
	lbu	    $t3, -1($v0)	# contact[position - 1]
	or	    $t3, $t3, 1	# contact[position - 1] | touchLeft[lookupId]
	sb	    $t3, -1($v0)
	sub	    $t0, $t5, 1	# position - 1
	sb	    $t0, 0($s5)	# queue[qEnd] = position - 1
	add	    $s5, $s5, 1	# qEnd++
	
pb_no_direct_left:
	# down-left
	bge	    $t8, $s2, pb_no_down_left
	lbu	    $t0, 4($t4)	# puzzle->bitmap[downPos - 1]
	beq	    $t0, $zero, pb_no_down_left
	lbu	    $t3, 4($v0)	# contact[downPos - 1]
	or	    $t3, $t3, 1	# contact[downPos - 1] | touchLeft[lookupId]
	sb	    $t3, 4($v0)
	add	    $t0, $t5, 4	# downPos - 1
	sb	    $t0, 0($s5)	# queue[qEnd] = downPos - 1
	add	    $s5, $s5, 1	# qEnd++
	
pb_no_down_left:
	# up-left
	blt	    $t1, $zero, pb_no_left
	lbu	    $t0, -6($t4)	# puzzle->bitmap[upPos - 1]
	beq	    $t0, $zero, pb_no_left
	lbu	    $t3, -6($v0)	# contact[upPos - 1]
	or	    $t3, $t3, 1	# contact[upPos - 1] | touchLeft[lookupId]
	sb	    $t3, -6($v0)
	add	    $t0, $t5, -6	# upPos - 1
	sb	    $t0, 0($s5)	# queue[qEnd] = upPos - 1
	add	    $s5, $s5, 1	# qEnd++
	
pb_no_left:
	# right
	beq	    $a3, $zero, pb_no_right
	add	    $t6, $t5, 1	# position + 1
	div	    $t6, $s6
	mfhi	    $t0		# (position + 1) % Puzzle.BytesWidth
	beq	    $t0, $zero, pb_no_right
	lbu	    $t2, 1($t4)	# puzzle->bitmap[position + 1]
	beq	    $t2, $zero, pb_no_direct_right
	lbu	    $t3, 1($v0)	# contact[position + 1]
	or	    $t3, $t3, 0x80	# contact[position + 1] | touchRight[lookupId]
	sb	    $t3, 1($v0)
	sb	    $t6, 0($s5)	# queue[qEnd] = position + 1
	add	    $s5, $s5, 1	# qEnd++
	
pb_no_direct_right:
	# down-right
	bge	    $t8, $s2, pb_no_down_right
	lbu	    $t0, 6($t4)	# puzzle->bitmap[downPos + 1]
	beq	    $t0, $zero, pb_no_down_right
	lbu	    $t3, 6($v0)	# contact[downPos + 1]
	or	    $t3, $t3, 0x80	# contact[downPos + 1] | touchRight[lookupId]
	sb	    $t3, 6($v0)
	add	    $t0, $t5, 6	# downPos + 1
	sb	    $t0, 0($s5)	# queue[qEnd] = downPos + 1
	add	    $s5, $s5, 1	# qEnd++
	
pb_no_down_right:
	# up-right
	blt	    $t1, $zero, pb_no_right
	lbu	    $t0, -4($t4)	# puzzle->bitmap[upPos + 1]
	beq	    $t0, $zero, pb_no_right
	lbu	    $t3, -4($v0)	# contact[upPos + 1]
	or	    $t3, $t3, 0x80	# contact[upPos + 1] | touchRight[lookupId]
	sb	    $t3, -4($v0)
	add	    $t0, $t5, -4	# upPos + 1
	sb	    $t0, 0($s5)	# queue[qEnd] = upPos + 1
	add	    $s5, $s5, 1	# qEnd++
	
pb_no_right:
pb_fill_loop_next:
	add	    $s4, $s4, 1	# qStart++
	j	    pb_fill_loop_top
	
pb_fill_loop_done:
	add	    $s1, $s1, 1	# marker++
	j	    pb_outer_loop_top
	
pb_outer_loop_done:
        lw          $ra, 0($sp)
        lw          $s0, 4($sp)
        lw          $s1, 8($sp)
        lw          $s2, 12($sp)
        lw          $s3, 16($sp)
	lw          $s4, 20($sp)
	lw          $s5, 24($sp)
	lw          $s6, 28($sp)
	lw          $s7, 32($sp)
	lw          $gp, 36($sp)
	lw          $fp, 40($sp)
	add         $sp, $sp, 44
	jr	    $ra


# print board ##################################################
#
# argument $a0: board to print
.globl print_board
print_board:
        sub         $sp, $sp, 20
        sw          $ra, 0($sp)     # save $ra and free up 4 $s registers for
        sw          $s0, 4($sp)     # i
        sw          $s1, 8($sp)     # j
        sw          $s2, 12($sp)    # the address
        sw          $s3, 16($sp)    # the line number
        move        $s2, $a0
        li          $s0, 0          # i
pb_loop1:
        li          $s1, 0          # j
pb_loop2:

        lw          $t0, 0($s2)     # NUM_ROWS
        lw          $t1, 4($s2)     # NUM_COLS

        mul         $t2, $s0, $t1   # i * NUM_COLS
        add         $t2, $t2, $s1   # i * NUM_COLS + j
        add         $t2, $t2, 8
        add         $t2, $t2, $s2


        lb          $a0, 0($t2)     # num = &board[i][j]
        li          $v0, 11
        syscall
        j           pb_cont
pb_cont:
        add         $s1, $s1, 1     # j++
        blt         $s1, 8, pb_loop2
        li          $v0, 11         # at the end of a line, print a newline char.
        li          $a0, '\n'
        syscall

        add         $s0, $s0, 1     # i++
        blt         $s0, 8, pb_loop1
        lw          $ra, 0($sp)     # restore registers and return
        lw          $s0, 4($sp)
        lw          $s1, 8($sp)
        lw          $s2, 12($sp)
        lw          $s3, 16($sp)
        add         $sp, $sp, 20
        jr          $ra

# -----------------------------------------------------------------------
# set_move_point_target - sets the target pixel for the SPIMBot to 
# travel to. Uses timer interrupts.
# This function assumes there is a direct path from the current location
# to the target point (no collisions!).
# $a0 - target_x
# $a1 - target_y
# -----------------------------------------------------------------------
set_move_point_target:
        sub         $sp, $sp, 16
        sw          $ra, 0($sp)
        sw          $s0, 4($sp)
        sw          $s1, 8($sp)
        sw          $s2, 12($sp)

        jal         wait_for_timer_int   # wait for timer interrupt handler to become inactive

        lw          $a2, BOT_X
        lw          $a3, BOT_Y

        sub         $s0, $a0, $a2   # $s0 = current_x - target_x
        sub         $s1, $a1, $a3   # $s1 = current_y - target_y

        jal         euc_dist        
        move        $s2, $v0        # s2 = distance

        move        $a0, $s0
        move        $a1, $s1
        jal         sb_arctan       # $v0 = angle to rotate to.
        
        sw          $v0, ANGLE      # set target angle
        li          $t0, 1
        sw          $t0, ANGLE_CONTROL  # and set angle control to absolute

        move        $a0, $s2
        jal         set_move_dist_target # call move_dist

        lw          $ra, 0($sp)     #cleanup
        lw          $s0, 4($sp)
        lw          $s1, 8($sp)
        lw          $s2, 12($sp)
        add         $sp, $sp, 16
        jr          $ra


# -----------------------------------------------------------------------
# set_move_dist_target - sets the target destination for the SPIMBot using
# timer interrupts
# Returns right after the interrupt is set, not after when the bot has
# reached the target distance.
# Make sure to not call this function if a timer interrupt is already
# active. See wait_for_timer_int
# $a0 - dist
# -----------------------------------------------------------------------
set_move_dist_target:
        sub         $sp, $sp, 4
        sw          $ra, 0($sp)

        jal         wait_for_timer_int   # wait for timer interrupt handler to become inactive

        lw          $t1, TIMER      # $t0 = current time (cycles)
        mul         $a0, $a0, 1000  # $a0 = # of cycles needed to travel "dist" (assumes bot is moving at max speed (10 mips))
        add         $a0, $a0, $t1   # $a0 = cycle to stop moving
        sw          $a0, TIMER      # request TIMER interrupt
        li          $t1, 10
        sw          $t1, VELOCITY   # set bot to max speed
        sw          $t1, 0($v0)     # update the timer_int_active flag

        lw          $ra, 0($sp)
        add         $sp, $sp, 4
        jr          $ra

# -----------------------------------------------------------------------
# wait_for_timer_int - waits for timer interrupts to finish
# It really just checks the state of timer_int_active.
# Returns the address of timer_int_active in $v0
# Returns the value of timer_int_active in $v1
# -----------------------------------------------------------------------
wait_for_timer_int:
        la          $v0, timer_int_active
        lw          $v1, 0($v0)
        bne         $v1, 0, wait_for_timer_int
        jr          $ra

# -----------------------------------------------------------------------
# move_dist_poll - moves the SPIMBot a given distance by constantly
# polling the current position
# It (currently) only returns after the bot has reached the given position
# $a0 - dist
# -----------------------------------------------------------------------
move_dist_poll:
        sub         $sp, $sp, 16
        sw          $ra, 0($sp)
        sw          $s0, 4($sp)
        sw          $s1, 8($sp)
        sw          $s2, 12($sp)

        lw          $s0, BOT_X      # $s0 = start_x
        lw          $s1, BOT_Y      # $s1 = start_y

        move        $s2, $a0        # $s2 = dist

        li          $t0, 10
        sw          $t0, VELOCITY

_move_dist_loop:
        lw          $a2, BOT_X      # $a2 = curr_x
        lw          $a3, BOT_Y      # $a2 = curr_y
        move        $a0, $s0
        move        $a1, $s1
        jal         euc_dist        # $v0 = dist
        bge         $v0, $s2, _move_dist_ret        # did we hit the distance?
        j _move_dist_loop

_move_dist_ret:
        sw          $0, VELOCITY
        lw          $ra, 0($sp)
        lw          $s0, 4($sp)
        lw          $s1, 8($sp)
        lw          $s2, 12($sp)
        add         $sp, $sp, 16


# -----------------------------------------------------------------------
# euc_dist - computes the euclidean distance between (x1, y1) and (x2, y2)
# $a0 - x1
# $a1 - y1
# $a2 - x2
# $a3 - y2
# returns the (integer casted) euclidean distance in $v0
# -----------------------------------------------------------------------
euc_dist:
        sub         $a0, $a2, $a0   # $a0 = (x2 - x1)
        mul         $a0, $a0, $a0   # $a0 = (x2 - x1)^2
        sub         $a1, $a3, $a1   # $a1 = (y2 - y1)
        mul         $a1, $a1, $a1   # $a1 = (y2 - y1)^2

        add         $v0, $a0, $a1   # $v0 = (x2 - x1)^2 + (y2 - y1)^2

        mtc1        $v0, $f12       # $f12 = $v0
        cvt.s.w     $f12, $f12      # cast $f12 to a float
        sqrt.s      $f12, $f12      # $f12 = sqrt($f12)
        cvt.w.s     $f12, $f12      # cast $f12 to an int
        mfc1        $v0, $f12       # $v0 = $f12
        jr          $ra

# -----------------------------------------------------------------------
# sb_arctan - computes the arctangent of y / x
# $a0 - x
# $a1 - y
# returns the arctangent in $v0
# -----------------------------------------------------------------------
sb_arctan:
        li          $v0, 0           # angle = 0;

        abs         $t0, $a0         # get absolute values
        abs         $t1, $a1
        ble         $t1, $t0, no_TURN_90

        ## if (abs(y) > abs(x)) { rotate 90 degrees }
        move        $t0, $a1         # int temp = y;
        neg         $a1, $a0         # y = -x;
        move        $a0, $t0         # x = temp;
        li          $v0, 90          # angle = 90;

no_TURN_90:
        bgez        $a0, pos_x       # skip if (x >= 0)

        ## if (x < 0)
        add         $v0, $v0, 180    # angle += 180;

pos_x:
        mtc1        $a0, $f0
        mtc1        $a1, $f1
        cvt.s.w     $f0, $f0         # convert from ints to floats
        cvt.s.w     $f1, $f1

        div.s       $f0, $f1, $f0    # float v = (float) y / (float) x;
    
        mul.s       $f1, $f0, $f0    # v^^2
        mul.s       $f2, $f1, $f0    # v^^3
        l.s         $f3, three       # load 3.0
        div.s       $f3, $f2, $f3    # v^^3/3
        sub.s       $f6, $f0, $f3    # v - v^^3/3

        mul.s       $f4, $f1, $f2    # v^^5
        l.s         $f5, five        # load 5.0
        div.s       $f5, $f4, $f5    # v^^5/5
        add.s       $f6, $f6, $f5    # value = v - v^^3/3 + v^^5/5

        l.s         $f8, PI          # load PI
        div.s       $f6, $f6, $f8    # value / PI
        l.s         $f7, F180        # load 180.0
        mul.s       $f6, $f6, $f7    # 180.0 * value / PI

        cvt.w.s     $f6, $f6         # convert "delta" back to integer
        mfc1        $t0, $f6
        add         $v0, $v0, $t0    # angle += delta

        bge         $v0, 0, sb_arc_tan_end
        # negative value received.
        li          $t0, 360
        add         $v0, $t0, $v0

sb_arc_tan_end:
        jr          $ra

.kdata
chunkIH:            .space 32
non_intrpt_str:     .asciiz "Non-interrupt exception\n"
unhandled_str:      .asciiz "Unhandled interrupt type\n"
.ktext 0x80000180
interrupt_handler:
.set noat
        move        $k1, $at        # Save $at
.set at
        la          $k0, chunkIH
        sw          $a0, 0($k0)        # Get some free registers
        sw          $v0, 4($k0)        # by storing them to a global variable
        sw          $t0, 8($k0)
        sw          $t1, 12($k0)
        sw          $t2, 16($k0)
        sw          $t3, 20($k0)
	sw          $t4, 24($k0)
	sw          $t5, 28($k0)

        mfc0        $k0, $13             # Get Cause register
        srl         $a0, $k0, 2
        and         $a0, $a0, 0xf        # ExcCode field
        bne         $a0, 0, non_intrpt



interrupt_dispatch:            # Interrupt:
        mfc0        $k0, $13        # Get Cause register, again
        beq         $k0, 0, done        # handled all outstanding interrupts

        and         $a0, $k0, BONK_INT_MASK    # is there a bonk interrupt?
        bne         $a0, 0, bonk_interrupt

        and         $a0, $k0, TIMER_INT_MASK    # is there a timer interrupt?
        bne         $a0, 0, timer_interrupt

        and 	    $a0, $k0, REQUEST_PUZZLE_INT_MASK
        bne 	    $a0, 0, request_puzzle_interrupt

        li          $v0, PRINT_STRING    # Unhandled interrupt types
        la          $a0, unhandled_str
        syscall
        j           done

bonk_interrupt:
	sw 	    $0, BONK_ACK
        #Fill in your code here
        j           interrupt_dispatch    # see if other interrupts are waiting

request_puzzle_interrupt:
	sw	$0, REQUEST_PUZZLE_ACK
	li	$t0, 1
	sb	$t0, d_puzzle_pending
	j	interrupt_dispatch

timer_interrupt:
	sw 	    $0, TIMER_ACK
        sw          $0, VELOCITY        # stop moving
        la          $t4, timer_int_active   
        sw          $0, 0($t4)      # set timer_int_active to false
        j           interrupt_dispatch    # see if other interrupts are waiting

non_intrpt:                # was some non-interrupt
        li          $v0, PRINT_STRING
        la          $a0, non_intrpt_str
        syscall                # print out an error message
        # fall through to done

done:
        la          $k0, chunkIH
        lw          $a0, 0($k0)        # Restore saved registers
        lw          $v0, 4($k0)
        lw          $t0, 8($k0)
        lw          $t1, 12($k0)
        lw          $t2, 16($k0)
        lw          $t3, 20($k0)
        lw          $t4, 24($k0)
        lw          $t5, 28($k0)
.set noat
        move        $at, $k1        # Restore $at
.set at
        eret
