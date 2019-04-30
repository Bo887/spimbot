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

puzzle:			.space 1832     # space allocated for the puzzle
map:			.space 225      # stores the map from GET_LAYOUT
test_a: .word 0xdeadbeef
tile_types:		.space 5        # 5 bytes for a 5-element char array representing what is in the 5 item locations.
test_b: .word 0xdeadbeef

			.align 2	# force the following to be word-aligned

encoded_request:	.space 24	# 3 orders, 2 words per packed request
decoded_request:	.space 144	# 3 orders, 12 words per unpacked request (ingredients array)
inventory:              .space 16       # 4 elements (each an integer) in the inventory -> 16 bytes total

encoded_shared_counter: .space 8
decoded_shared_counter: .space 48
has_oven:               .word 0
has_sink:               .word 0
has_chop:               .word 0
done_processing:        .word 0

encoded_order:          .space 24       # same as encoded_request
decoded_order:          .space 144      # same as decoded_request

first_order_magnitude:  .word 0
second_order_magnitude: .word 0
third_order_magnitude:  .word 0

food_groups_idx_to_id:  .word 0x50002 0x50001 0x50000 0x40001 0x4000 0x30001 0x30000 0x20002 0x20001 0x20000 0x10000 0

.align 2
first_order_components: .space 36
second_order_components:.space 36
third_order_components: .space 36

### PRECOMPUTED PUZZLE SOLVING TABLES ###

puzzle_transition:	.space 65536
puzzle_touch_vert:	.space 65536

### END PRECOMPUTED TABLES ###
puzzle_queue:	    .space 400
puzzle_contact:	    .space 200
			
d_puzzle_pending:   .word 0

timer_int_active:   .word 0         # global flag that is non-zero when the timer interrupt is active

bot_on_left:        .word 0         # true if the bot is on the left side, false if bot is on the right side
PI:                 .float 3.14
three:              .float 3.0
five:               .float 5.0
F180:               .float 180.0

shared_counter_x:   .word 170 130   # 2-element array, shared_counter_x[bot_on_left] will give the corresponding one to use

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

infinite:
        j           infinite

# -----------------------------------------------------------------------
# update_flags - function that updates the utility flags
# has_oven, has_sink, has_chop
# $a0 - value of the utility
# $a1 - index of the utility in tile_types
# -----------------------------------------------------------------------
update_flags:
        beq         $a0, 4, _update_flags_oven
        beq         $a0, 5, _update_flags_sink
        beq         $a0, 6, _update_flags_chop
        j           _update_flags_ret
_update_flags_oven:
        la          $t0, has_oven
        sw          $a1, 0($t0)
        j           _update_flags_ret
_update_flags_sink:
        la          $t0, has_sink
        sw          $a1, 0($t0)
        j           _update_flags_ret
_update_flags_chop:
        la          $t0, has_chop
        sw          $a1, 0($t0)

        # fall thru

_update_flags_ret:
        jr          $ra

# -----------------------------------------------------------------------
# update_order_mem - function that updates the information about the order
# in memory
# $a0 - base address of order struct
# $a1 - base address to save the number of components
# $a2 - base address to save the components
# -----------------------------------------------------------------------
update_order_mem:
        li          $v0, 0      # $v0 = 0

        li          $t0, 0      # $t0 = 0 (i)
        li          $t2, 0      # $t2 = 0 (j)
_update_order_mem_for_begin:
        bge         $t0, 12, _update_order_mem_ret
        mul         $t1, $t0, 4     # $t1 = i*sizeof(int)
        add         $t3, $t1, $a0   # $t3 = food_groups + i * sizeof(int)
        lw          $t3, 0($t3)     # $t3 = food_groups[i]
        add         $v0, $v0, $t3

        beq         $t3, $zero, _update_order_mem_for_inc   # if there are no items (i.e. food_groups[i] == 0), go to next iteration

_update_order_inner_for_begin:          # handle the case where there are multiple of the same element
        beq         $t3, $zero, _update_order_mem_for_inc
        mul         $t5, $t2, 4     # $t5 = j*sizeof(int)
        la          $t4, food_groups_idx_to_id
        add         $t4, $t4, $t1   # $t4 = food_groups_idx_to_id + i * sizeof(int)
        lw          $t4, 0($t4)     # $t4 = food_groups_idx_to_id[i]
        add         $t5, $a2, $t5   # $t5 = base_addr_components + j * sizeof(int)

        sw          $t4, 0($t5)
        add         $t2, $t2, 1     # j++
        sub         $t3, $t3, 1     # $t3--
        j           _update_order_inner_for_begin
        
_update_order_mem_for_inc:
        add         $t0, $t0, 1
        j           _update_order_mem_for_begin

_update_order_mem_ret:
        sw          $v0, 0($a1)
        jr          $ra

# -----------------------------------------------------------------------
# update_orders - function that updates the orders requested 
# (the decoded_orders struct in .data)
# -----------------------------------------------------------------------
update_orders:
        sub         $sp, $sp, 12
        sw          $ra, 0($sp)
        sw          $s0, 4($sp)
        sw          $s1, 8($sp)

        la          $s0, encoded_order
        sw          $s0, GET_TURNIN_ORDER
        la          $s1, decoded_order
        
        add         $a0, $s0, 0
        add         $a1, $s1, 0
        jal         decode_request_in_mem
        add         $a0, $s1, 0
        la          $a1, first_order_magnitude
        la          $a2, first_order_components
        jal         update_order_mem
    
        add         $a0, $s0, 8
        add         $a1, $s1, 48
        jal         decode_request_in_mem
        add         $a0, $s1, 48
        la          $a1, second_order_magnitude
        la          $a2, second_order_components
        jal         update_order_mem
    
        add         $a0, $s0, 16
        add         $a1, $s1, 96
        jal         decode_request_in_mem
        add         $a0, $s1, 96
        la          $a1, third_order_magnitude
        la          $a2, third_order_components
        jal         update_order_mem

        lw          $ra, 0($sp)
        lw          $s0, 4($sp)
        lw          $s1, 8($sp)
        add         $sp, $sp, 12
        jr          $ra

# -----------------------------------------------------------------------
# update_shared_counter - function that updates the contents of the shared counter
# (the decoded_shared_counter struct in .data)
# -----------------------------------------------------------------------
update_shared_counter:
        sub         $sp, $sp, 4
        sw          $ra, 0($sp)

        la          $a0, encoded_shared_counter
        sw          $a0, GET_SHARED
        la          $a1, decoded_shared_counter
        jal         decode_request_in_mem

        lw          $ra, 0($sp)
        add         $sp, $sp, 4
        jr          $ra

# -----------------------------------------------------------------------
# process_single_item - function that makes the bot go process a single item
# $a0 - location (index of tile_types) of the item
# $a1 - type of item to process
# -----------------------------------------------------------------------
process_single_item:
        sub         $sp, $sp, 8
        sw          $ra, 0($sp)
        sw          $s0, 4($sp)

        move        $s0, $a1
        li          $a1, 62         # height, all utilities are at height 60, so go a bit lower

        bne         $a0, 3, _process_item_idx_4
        li          $a0, 50
        j           _process_item_go
_process_item_idx_4:
        li          $a0, 110

_process_item_go:
        jal         move_point_while_solving_generic
        jal         rotate_face_up

        beq         $s0, 0x20000, _process_item_oven    # uncooked meat
        beq         $s0, 0x30000, _process_item_sink    # unwashed tomato
        beq         $s0, 0x40000, _process_item_chop_onion    # unchopped onion
        beq         $s0, 0x50000, _process_item_sink    # unwashed unchopped lettuce
        beq         $s0, 0x50001, _process_item_chop_lettuce    # unchopped lettuce
        j           _process_item_return

_process_item_oven:
        jal         wait_for_timer_int
        sw          $zero, DROPOFF
        li          $a0, 100000
        jal         set_wait_cycles
        jal         wait_for_timer_int
        sw          $0, PICKUP
        j           _process_item_return

_process_item_sink:
        jal         wait_for_timer_int
        sw          $zero, DROPOFF
        li          $a0, 20000
        jal         set_wait_cycles
        jal         wait_for_timer_int
        sw          $0, PICKUP
        j           _process_item_return

_process_item_chop_onion:
        jal         wait_for_timer_int
        sw          $zero, DROPOFF
        li          $a0, 20000
        jal         set_wait_cycles
        jal         wait_for_timer_int
        sw          $0, PICKUP
        j           _process_item_return

_process_item_chop_lettuce:
        jal         wait_for_timer_int
        sw          $zero, DROPOFF
        li          $a0, 40000
        jal         set_wait_cycles
        jal         wait_for_timer_int
        sw          $0, PICKUP
        # fall thru

_process_item_return:
        lw          $ra, 0($sp)
        lw          $s0, 4($sp)
        add         $sp, $sp, 8
        jr          $ra

# -----------------------------------------------------------------------
# can_cook_inventory_items - returns 1 if we can process the inventory items,
# otherwise returns 0
# Assumes the inventory contains the exact same elements!! (i.e. only checks
# the first inventory item to decide on the item type)
# returns if the bot can process the inventory items in $v0
# returns the index of tile_types that contains the processing item in $v1
# -----------------------------------------------------------------------
can_cook_inventory_items:
        lw          $t0, inventory      # $t0 = ID of the items in the inventory
        li          $v0, 0              # default $v0 = 0 (false)

        beq         $t0, 0, _can_cook_return
        beq         $t0, 0x10000, _can_cook_return

        li          $t1, 0              # $t1 = i
        la          $t2, tile_types     # $t2 = tile_types (tile_types = char[5])
_can_cook_search_tiles_for_begin:
        bge         $t1, 3, _can_cook_return         # we only need to search indices 0-2
        add         $t3, $t1, $t2       # $t3 = tile_types+i
        lb          $t3, 0($t3)         # $t3 = *(tile_types+i) = tile_types[i]
        beq         $t3, 8, _can_cook_handle_meat
        beq         $t3, 9, _can_cook_handle_lettuce
        beq         $t3, 12 _can_cook_handle_onion
        beq         $t3, 10 _can_cook_handle_tomato
        j           _can_cook_loop_inc

_can_cook_handle_tomato:
        lb          $t4, 3($t2)
        li          $t5, 3
        beq         $t4, 5, _can_cook_handle_tomato_go
        lb          $t4, 4($t2)
        li          $t5, 4
        beq         $t4, 5, _can_cook_handle_tomato_go
        j _can_cook_loop_inc
_can_cook_handle_tomato_go:
        beq         $t0, 0x30000, _can_cook_found       # tomato that is not cooked, return true
        beq         $t0, 0x30001, _can_cook_return      # tomato that is already cooked, return false
        j _can_cook_loop_inc
_can_cook_handle_onion:
        lb          $t4, 3($t2)
        li          $t5, 3
        beq         $t4, 6, _can_cook_handle_onion_go
        lb          $t4, 4($t2)
        li          $t5, 4
        beq         $t4, 6, _can_cook_handle_onion_go
        j _can_cook_loop_inc
_can_cook_handle_onion_go:
        beq         $t0, 0x40000, _can_cook_found
        beq         $t0, 0x40001, _can_cook_return
        j _can_cook_loop_inc
_can_cook_handle_meat:
        lb          $t4, 3($t2)
        li          $t5, 3
        beq         $t4, 4, _can_cook_handle_meat_go
        lb          $t4, 4($t2)
        li          $t5, 4
        beq         $t4, 4, _can_cook_handle_meat_go
        j _can_cook_loop_inc
_can_cook_handle_meat_go:
        beq         $t0, 0x20000, _can_cook_found
        beq         $t0, 0x20001, _can_cook_return
        j _can_cook_loop_inc
_can_cook_handle_lettuce:
        # TODO: lettuce logic is a bit complicated, since we have to wash and chop it.
        # if the lettuce is unwashed and unchopped (level 0), return true if there is a sink
        # if the lettuce is unchopped (level 1), return true if there is a chopping board
        # else, the lettuce is processed (level 2), return false since we don't need to do any processing
        #j _can_cook_loop_inc
_can_cook_handle_lettuce_go:
        beq         $t0, 0x50000, _can_cook_found
        beq         $t0, 0x50001, _can_cook_found
        beq         $t0, 0x50002, _can_cook_return

_can_cook_loop_inc:
        add         $t1, $t1, 1
        j _can_cook_search_tiles_for_begin

_can_cook_found:
        li          $v0, 1              # $v0 = 1 (true)
        move        $v1, $t5            # $v1 = $t5 (index of processing item)
        # fall through

_can_cook_return:
        jr          $ra

# ----------------------------------------------------------------------
# rotate_face_up - makes the SPIMBot face upwards (towards the utilities)
# ----------------------------------------------------------------------
rotate_face_up:
        li          $t0, 270
        sw          $t0, ANGLE
        li          $t1, 1
        sw          $t1, ANGLE_CONTROL
        jr          $ra

# ----------------------------------------------------------------------
# rotate_face_outside - makes the SPIMBot face towards the outside wall
# If the bot is on the left, turns towards angle 180.
# If the bot is on the right, turns towards angle 0.
# ----------------------------------------------------------------------
rotate_face_outside:
        lw          $t0, bot_on_left        # load bot_on_left
        beq         $t0, 0, _rotate_face_outside_right
        li          $t1, 180
        sw          $t1, ANGLE
        j           _rotate_face_outside_go

_rotate_face_outside_right:
        li          $t1, 0
        sw          $t1, ANGLE

_rotate_face_outside_go:
        li          $t1, 1
        sw          $t1, ANGLE_CONTROL
        jr          $ra

# -----------------------------------------------------------------------
# move_point_while_solving_generic - same as move_point_while_solving,
# but this is now generic.
# This function only takes in coordinates from the left side, and automatically
# converts them to the POV of the right side when needed (based on bot_on_left)
# $a0 - target_x
# $a1 - target_y
# -----------------------------------------------------------------------
move_point_while_solving_generic:
        sub         $sp, $sp, 4
        sw          $ra, 0($sp)

        lw          $t0, bot_on_left        # load bot_on_left
        bne         $t0, 0, _move_point_generic_move
        li          $t1, 300
        sub         $a0, $t1, $a0           # bot is on the right side - mirror the x value

_move_point_generic_move:
        jal         move_point_while_solving

        lw          $ra, 0($sp)
        add         $sp, $sp, 4
        jr          $ra

# -----------------------------------------------------------------------
# pickup_all_unprocessed - pickups 4 (inventory max) unprocessed ingredients
# -----------------------------------------------------------------------
pickup_all_unprocessed:
        sub         $sp, $sp, 4
        sw          $ra, 0($sp)

        sw          $0, PICKUP
        sw          $0, PICKUP
        sw          $0, PICKUP
        sw          $0, PICKUP
        jal         update_inventory

        lw          $ra, 0($sp)
        add         $sp, $sp, 4
        jr          $ra

# -----------------------------------------------------------------------
# dropoff_all - drops off all (4) ingredients
# -----------------------------------------------------------------------
dropoff_all:
        sub         $sp, $sp, 4
        sw          $ra, 0($sp)

        add         $t0, $zero, $zero
        sw          $t0, DROPOFF
        add         $t0, $t0, 1
        sw          $t0, DROPOFF
        add         $t0, $t0, 1
        sw          $t0, DROPOFF
        add         $t0, $t0, 1
        sw          $t0, DROPOFF
        jal         update_inventory

        lw          $ra, 0($sp)
        add         $sp, $sp, 4
        jr          $ra

# -----------------------------------------------------------------------
# set_wait_cycles - sets the timer to wait for a number of cycles.
# Note: does not actually do the waiting!
# $a0 - number of cycles to wait
# -----------------------------------------------------------------------
set_wait_cycles:
        lw          $t1, TIMER          # load current cycle
        add         $t1, $t1, $a0       # and calculate target cycle to stop
        sw          $t1, TIMER          # set timer interrupt
        la          $t0, timer_int_active
        sw          $t1, 0($t0)         # update the timer_int_active flag
        jr          $ra

# -----------------------------------------------------------------------
# wait_cycles - waits for a number of cycles
# $a0 - number of cycles to wait
# -----------------------------------------------------------------------
wait_cycles:
        sub         $sp, $sp, 4
        sw          $ra, 0($sp)

        jal         wait_for_timer_int  # wait for ongoing timer interrupts, don't want to accidentally screw up something else
        lw          $t1, TIMER          # load current cycle
        add         $t1, $t1, $a0       # and calculate target cycle to stop
        sw          $t1, TIMER          # set timer interrupt
        la          $t0, timer_int_active
        sw          $t1, 0($t0)         # update the timer_int_active flag
        jal         wait_for_timer_int  # and just wait............

        lw          $ra, 0($sp)
        add         $sp, $sp, 4
        jr          $ra

# -----------------------------------------------------------------------
# drive_to_shared_counter - drives the most optimal path to the
# corresponding side of the shared counter (depending on bot_on_left)
# Assumes there is a direct path!
# This function only returns once the bot reaches the counter.
# -----------------------------------------------------------------------
drive_to_shared_counter:
        sub         $sp, $sp, 4
        sw          $ra, 0($sp)

        lw          $t1, bot_on_left        # load bot_on_left
        mul         $t1, $t1, 4
        la          $t2, shared_counter_x
        add         $t2, $t2, $t1
        lw          $a0, 0($t2)             # and get shared_counter_x[bot_on_left]

        lw          $a1, BOT_Y      # the y-target will be the bot's current y location (shortest distance is direct)
        bge         $a1, 65, _drive_to_shared_counter_drive
        li          $a1, 65         # unless the bot's height is < 65, then load 65 (we want to stay in the center "rectangle", 65 is an approximate cutoff)

_drive_to_shared_counter_drive:
        jal         move_point_while_solving

        lw          $ra, 0($sp)
        add         $sp, $sp, 4
        jr          $ra

# -----------------------------------------------------------------------
# move_point_while_solving - wrapper around set_move_point_target
# that tries to solve puzzles in the meantime
# This function only returns once the target is reached.
# $a0 - target_x
# $a1 - target_y
# -----------------------------------------------------------------------
move_point_while_solving:
        sub         $sp, $sp, 4
        sw          $ra, 0($sp)

        jal         set_move_point_target       # set the target

_move_point_solve_request_puzzle:
        lw          $t0, timer_int_active
        beq         $t0, $zero, _move_point_solve_return    # loop until the timer interrupt is no longer active (which means we have reached our destination)
        la          $t0, puzzle                             # request a puzzle
        sw          $t0, REQUEST_PUZZLE

_move_point_solve_wait:
	lw	    $t0, d_puzzle_pending                   # wait for the puzzle to be ready
	beq         $t0, $zero, _move_point_solve_wait

_move_point_solve_solve:                                    # update the d_puzzle_pending flag
        sb	    $zero, d_puzzle_pending
	la	    $a0, puzzle                             # solve puzzle
	jal	    puzzle_bolt
	
	la	    $t0, puzzle                             # submit the solution
	sw	    $t0, SUBMIT_SOLUTION
        j           _move_point_solve_request_puzzle        # and loop again

_move_point_solve_return: 
        lw          $ra, 0($sp)
        add         $sp, $sp, 4
        jr          $ra

# -----------------------------------------------------------------------
# update_inventory - updates the "inventory" block in the .data segment
# -----------------------------------------------------------------------
update_inventory:
        la          $t0, inventory
        sw          $t0, GET_INVENTORY
        jr          $ra
	
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
	beq	$s4, $s5, pb_fill_loop_done
	lbu	$t5, 0($s4)	# position = queue[qStart]
	add	$t4, $s3, $t5	# &puzzle->bitmap[position]
	lbu	$t6, 0($t4)	# chunk = puzzle->bitmap[position]
	beq	$t6, $zero, pb_fill_loop_next
	
	add	$v0, $fp, $t5	# &contact[position]
	lbu	$t0, 0($v0)	# touching = contact[position]
	sll	$t1, $t6, 8	# chunk << 8
	or	$t1, $t1, $t0	# lookupId = chunk << 8 | touching
	add	$t0, $gp, $t1	# &transitions[lookupId]
	lbu	$t9, 0($t0)	# transitions[lookupId]
	beq	$t9, $t6, pb_fill_loop_next
	sb	$t9, 0($t4)	# puzzle->bitmap[position] = transitions[lookupId]
	
	div	$t5, $s6	# need both quotient and remainder
	mfhi	$t7		# position % Puzzle.BytesWidth
	beq	$t7, $s7, pb_fill_loop_next
	mflo	$t8		# position / Puzzle.BytesWidth
	sll	$t7, $t7, 3	# (position % Puzzle.BytesWidth) * 8
	lw	$t0, 4($a0)	# width
	mul	$t8, $t8, $t0	# (position / Puzzle.BytesWidth) * Puzzle.Width
	add	$t7, $t7, $t8	# mapPos
	
	nor	$t9, $t9, $t9	# ~transitions[lookupId]
	and	$t3, $t9, $t6	# changed = chunk & ~transitions[lookupId]
	and	$a2, $t3, 0x80	# nonzero if need to use touchLeft
	and	$a3, $t3, 0x01	# likewise for touchRight
	
	add	$a1, $ra, $t1	# &touchVert[lookupId]
	lbu	$a1, 0($a1)	# touchVert[lookupId]
	
	add	$t1, $a0, $t7	# &puzzle->map[mapPos] - 8
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

# -----------------------------------------------------------------------
# request/order/counter encoding and decoding functions
# -----------------------------------------------------------------------

# decode_request turns two ints (packed request) into a 12-long int array
# $a0: request low word
# $a1: request high word
# $a2: result array base address

.globl decode_request
decode_request:
	li	$t0, 0
	
dr_first_loop:
	bge	$t0, 6, dr_intermediate_bits
	and	$t1, $a0, 0x1f		# array[i] = lo & 0x0000001f;
	mul	$t2, $t0, 4		# Calculate array[i]
	add	$t3, $a2, $t2
	sw	$t1, 0($t3)		# Save array[i]
	srl	$a0, $a0, 5		# lo = lo >> 5;
	add	$t0, $t0, 1
	j	dr_first_loop
	
dr_intermediate_bits:
	sll	$t0, $a1, 2		# unsigned upper_three_bits = (hi << 2) & 0x0000001f;
	and	$t0, $t0, 0x1f
	or	$t0, $t0, $a0		# array[6] = upper_three_bits | lo;
	sw	$t0, 24($a2)
	srl	$a1, $a1, 3		# hi = hi >> 3;
	
	li	$t0, 7
	
dr_second_loop:
	bge 	$t0, 12, dr_end		# for (int i = 7; i < 12; ++i)
	and	$t1, $a1, 0x1f		# array[i] = hi & 0x0000001f;
	mul	$t2, $t0, 4		# Calculate array[i]
	add	$t3, $a2, $t2
	sw	$t1, 0($t3)		# Save array[i]
	srl	$a1, $a1, 5		# hi = hi >> 5;
	add	$t0, $t0, 1
	j	dr_second_loop
	
dr_end:
	jr	$ra
	
# decode_request_in_mem unpacks a request from memory into an ingredient array in memory
# $a0: base address of request structure
# $a1: result array base address

.globl decode_request_in_mem
decode_request_in_mem:
	move	$a2, $a1	# result address
	lw	$a1, 4($a0)	# high - documentation is a lie
	lw	$a0, 0($a0)	# low
	j	decode_request	# will use current $ra
	
# create_request turns an array of 12 ingredient counts (words) into a two-word (packed) request
# $a0: array base address
# $v0: low word of result
# $v1: high word of result
	
.globl create_request
create_request:
	lw	$v0, 24($a0)	# unsigned lo = ((array[6] << 30) >> 30);
	sll	$v0, $v0, 30
	srl	$v0, $v0, 30
	
	li	$t0, 5
cr_first_loop:
	blt 	$t0, 0, cr_second_loop_start	# for (int i = 5; i >= 0; --i) {
	sll	$v0, $v0, 5	# lo = lo << 5;
	mul	$t1, $t0, 4	# Calculate array[i]
	add	$t2, $a0, $t1	
	lw	$t1, 0($t2)	# Load array[i]
	or	$v0, $v0, $t1	# lo |= array[i];
	sub	$t0, $t0, 1
	j	cr_first_loop
	
cr_second_loop_start:
	li	$t0, 12
	li	$v1, 0
	
cr_second_loop:
	ble 	$t0, 7, cr_intermediate_bits	# for (int i = 12; i > 7; --i) {
	mul	$t1, $t0, 4	# Calculate array[i]
	add	$t2, $a0, $t1	
	lw	$t1, 0($t2)	# Load array[i]
	or	$v1, $v1, $t1	# hi |= array[i];
	sll	$v1, $v1, 5	# hi = hi << 5;
	
	sub	$t0, $t0, 1
	j	cr_second_loop
	
cr_intermediate_bits:	
	lw	$t1, 28($a0)	# Load array[7]
	or	$v1, $v1, $t1	# hi |= array[i];
	sll	$v1, $v1, 3	# hi = hi << 3;
	lw	$t1, 24($a0)	# Load array[6]
	srl	$t1, $t1, 2	# (array[6] >> 2)
	or	$v1, $v1, $t1	# hi |= (array[6] >> 2);
	
cr_end:
	jr	$ra
	
# create_request_in_mem packs an ingredients list into a request structure in memory
# $a0: base address of (output) request structure
# $a1: input (unpacked) array base address

.globl create_request_in_mem
create_request_in_mem:
	sub	$sp, $sp, 8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)	# saves $a0
	
	move	$s0, $a0
	move	$a0, $a1
	jal	create_request
	sw	$v0, 0($s0)	# low
	sw	$v1, 4($s0)	# high
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	add	$sp, $sp, 8
	jr	$ra

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
# returns the number of cycles needed to move in $v0
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
        jal         set_move_dist_target # call move_dist, $v0 is set here also

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
# returns the number of cycles needed in $v0
# -----------------------------------------------------------------------
set_move_dist_target:
        sub         $sp, $sp, 4
        sw          $ra, 0($sp)

        jal         wait_for_timer_int   # wait for timer interrupt handler to become inactive

        lw          $t1, TIMER      # $t0 = current time (cycles)
        mul         $a0, $a0, 1000  # $a0 = # of cycles needed to travel "dist" (assumes bot is moving at max speed (10 mips))
        add         $t2, $a0, $t1   # $a0 = cycle to stop moving
        sw          $t2, TIMER      # request TIMER interrupt
        li          $t1, 10
        sw          $t1, VELOCITY   # set bot to max speed
        sw          $t1, 0($v0)     # update the timer_int_active flag

        move        $v0, $a0        # store the return value (# of cycles needed)

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
