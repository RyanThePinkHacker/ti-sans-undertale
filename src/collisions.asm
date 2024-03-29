check_hard_collision_inner_box:
; Arguments:
    .box_x      := 03 ; u24
    .box_y      := 06 ; u8
    .box_size_x := 09 ; u24
    .box_size_y := 12 ; u8
; Return:
;   Sets hard collision flags; never resets.
    ld iy, 0
    add iy, sp

    .up:
        ld a, (iy + .box_y)
        ld b, (ix + flags.player_soul_y.offset)

        ; box_y < player.y
        cp a, b
        jq c, .up_end

        ; Collision
        set flags.collision.hard_up_bit, (ix + flags.collision.offset)
    .up_end:

    .down:
        add a, (iy + .box_size_y)
        ld c, a

        ld a, b ; player.y
        add a, sprites.heart_red.height

        ; player.y + player_size < box_y + box_size.y
        cp a, c
        jq c, .down_end

        ; Collision
        set flags.collision.hard_down_bit, (ix + flags.collision.offset)
    .down_end:

    .left:
        ld de, (ix + flags.player_soul_x.offset)
        ld hl, (iy + .box_x)

        ; box_x < player.x
        ; Carry is unknown
        or a, a ; Resets carry
        sbc hl, de
        jq c, .left_end

        ; Collision
        set flags.collision.hard_left_bit, (ix + flags.collision.offset)
    .left_end:
    
    .right:
        ld hl, (iy + .box_size_x)
        ld bc, (iy + .box_x)
        add hl, bc ; box_size.x + box_x
        ex de, hl ; de = box_size.x + box_x

        ld hl, (ix + flags.player_soul_x.offset)
        ld bc, sprites.heart_red.width
        add hl, bc ; player.x + player_size
                   ; Resets carry
                   ; unless the player's x is greater than 16_777_208.
                   ; Hopefully this isn't the case.

        ; player.x + player_size < box_x + box_size.x
        sbc hl, de
        ret c

        set flags.collision.hard_right_bit, (ix + flags.collision.offset)
    .right_end:

    ret

check_soft_collision_box:
; Arguments:
    .box_x      := 03 ; u24
    .box_y      := 06 ; u8
    .box_size_x := 09 ; u24
    .box_size_y := 12 ; u8
; Return:
;   Sets soft collision flags; never resets.
    ld iy, 0
    add iy, sp

    .up:
        ld a, (ix + flags.player_soul_y.offset)
        add a, sprites.heart_red.height ; player.y + player_height

        ; player.y + player_height < box_y
        cp a, (iy + .box_y)
        ret c

    .down:
        ld a, (iy + .box_y) ; box_y
        add a, (iy + .box_size_y) ; box_y + box_size_y

        ; box_y + box_size_y < player.y
        cp a, (ix + flags.player_soul_y.offset)
        ret c

    .left:
        ld hl, (ix + flags.player_soul_x.offset)
        ld bc, sprites.heart_red.width
        add hl, bc ; player.x + player_width
                   ; Resets carry.

        ; player.x + player_width < box_x
        ld de, (iy + .box_x)
        sbc hl, de
        ret c

    .right:
        ex de, hl ; de = player.x + player_width
                  ; hl = box_x
        ld bc, (iy + .box_size_x)
        add hl, bc ; box_x + box_size
                                 ; Resets carry

        ; box_x + box_size_x < player.x
        ld de, (ix + flags.player_soul_x.offset)
        sbc hl, de
        ret c

        set flags.collision.soft_bit, (ix + flags.collision.offset)
        ret
