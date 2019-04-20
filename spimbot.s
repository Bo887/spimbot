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

timer_int_active:   .word 0     # global flag that is non-zero when the timer interrupt is being used for move_dist_time, otherwise false
puzzle:             .word 0:452

PI:                 .float 3.14
three:              .float 3.0
five:               .float 5.0
F180:               .float 180.0

.text
main:
	# Construct interrupt mask
	li          $t4, 0
	or          $t4, $t4, BONK_INT_MASK # request bonk
	or          $t4, $t4, REQUEST_PUZZLE_INT_MASK	        # puzzle interrupt bit
        or          $t4, $t4, TIMER_INT_MASK        #enable timer interrupts
	or          $t4, $t4, 1 # global enable
	mtc0        $t4, $12
	
	#Fill in your code here
        li          $a0, 20
        jal move_dist_time
        li          $a0, 20
        jal move_dist_time
        
infinite:
	j           infinite

# -----------------------------------------------------------------------
# move_dist_time - moves the SPIMBot a given distance by setting a 
# timer interrupt
# $a0 - dist
# -----------------------------------------------------------------------
move_dist_time:

_move_dist_wait:
        la          $t0, timer_int_active
        lw          $t1, 0($t0)
        beq         $t1, 0, _move_dist_go   # check if the timer_int_active is true
        j           _move_dist_wait # wait for the timer interrupt to finish before setting a new one

_move_dist_go:
        lw          $t1, TIMER      # $t0 = current time (cycles)
        mul         $a0, $a0, 1000  # $a0 = # of cycles needed to travel "dist" (assumes bot is moving at max speed (10 mips))
        add         $a0, $a0, $t1   # $a0 = cycle to stop moving
        sw          $a0, TIMER      # request TIMER interrupt
        li          $t1, 10
        sw          $t1, VELOCITY   # set bot to max speed
        sw          $t1, 0($t0)     # update the timer_int_active flag
        jr          $ra


# -----------------------------------------------------------------------
# move_dist_poll - moves the SPIMBot a given distance by constantly
# polling the current position
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
        bge         $v0, $s2, _move_dist_ret
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
	sw 	    $0, REQUEST_PUZZLE_ACK
	#Fill in your code here
	j	    interrupt_dispatch

timer_interrupt:
	sw 	    $0, TIMER_ACK
        sw          $0, VELOCITY        # stop moving
        la          $t0, timer_int_active   
        sw          $0, 0($t0)      # set timer_int_active to false
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
