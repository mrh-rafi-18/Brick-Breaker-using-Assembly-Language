org 100h
.stack 100h
.model small
.data
   start      DB  0AH,0DH,"                                                  "
              DB  0AH,0DH,"                                                  "
              DB  0AH,0DH,"                                                  "
              DB  0AH,0DH,"                                                  "
              DB  0AH,0DH,"                                                  "
              DB  0AH,0DH,"                                                  "
              DB  0AH,0DH,"                                                  "
              DB  0AH,0DH,0AH,0DH,0AH,0DH,"                              Press any key to start$" 
              
              
    over      DB  0AH,0DH,"                                                  "
              DB  0AH,0DH,"                                                  "
              DB  0AH,0DH,"                                                  "
              DB  0AH,0DH,"                                                  "
              DB  0AH,0DH,"                                                  "
              DB  0AH,0DH,"                                                  "
              DB  0AH,0DH,"                                                  "
              DB  0AH,0DH,0AH,0DH,0AH,0DH,"                                  !!Game over!!"
              DB  0AH,0DH,"                              Press space to restart$" 
   
   startx         dw    ?
   starty         dw    ?
   endx           dw    ?
   endy           dw    ?
   
   
   color      db ?
   
   
   b0       dw   150
   b1       dw   222
   b2       dw   294
   b3       dw   366
   b4       dw   438
   brickx   dw   150,220,290,360,430

   
   width    dw   60
  
   by0      dw   132
   by1      dw   156
   bricky   dw   132,156
   iterator1 db   ?
   iterator2 db   ?
   
   
   ballx   dw   317
   bally   dw   372
   vertical   db  1
   horizontal db  0
   
   
   space  db   0x39
   left_key   db   0x4B
   right_key  db   0x4D
   
   
   leftw  dw   146
   rightw dw   488
   upw    dw   100
   downw  dw   364
   
   
   started db 0 
   
   strikerx dw 290
   strikery dw 375
   
   ball_ns dw 317

.code

 
main proc
     
      mov ax,@data 
      mov ds,ax
      
      mov ax, 0003h    
      int 10h
     
     
      mov ah,9
      lea dx,start
      int 21h
      
      mov ah,0
      int 16h
      
      call video_mode
      call start_game
      
end_program:
        mov ah, 4Ch
        int 21h
        ret
      main endp


               
video_mode proc
     mov ah,0h
     mov al,12h
     int 10h
     
     ret
     video_mode endp

start_game proc
      
    call boundary
    call bricks
    call striker
    call ball
   
 shoot: 
    mov ah,0
    int 16h
    
    
    cmp ah,left_key
    je call_ms 
    cmp ah,right_key
    je call_ms 
    cmp ah,space
    je startg
    jne shoot
    
    startg:
        mov started,1
        call game_started
        ret
    
   
   call_ms:
          call move_striker
          jmp shoot  
      
    start_game endp

boundary proc
     mov color,14
    
     ;up
     mov startx,140
     mov starty,109
     mov endx,500
     mov endy,109
     call draw_objects
     ;left
     mov startx,140
     mov starty,109
     mov endx,140
     mov endy,385
     call draw_objects
     ;down
     mov startx,140
     mov starty,385
     mov endx,500
     mov endy,385
     call draw_objects
     ;right
     mov startx,500
     mov starty,109
     mov endx,500
     mov endy,385
     call draw_objects 
     
     
     
     
     ret
     boundary endp

bricks proc
  mov color,40
  mov si,0
  mov iterator1,1
  mov starty,132
  mov endy, 132
     
     row:
        mov si,0
        mov startx,80
         column:
                
                add startx,70
                mov bx,startx
                add bx,width
                mov endx,bx
                call draw_objects
                cmp si,4
                inc si
                jb column
                je updatey
    
    updatey:
            inc iterator1
            add starty,24
            add endy,24
            cmp iterator1,3
            jb row
            ret
    
    bricks endp 

striker proc
    mov color,6
    mov startx,290
    mov endx,350
    mov starty,375
    mov endy,375
    call draw_objects
    
    ret
    striker endp


ball proc
    
    mov color,15
    mov bx,ballx
    mov startx,bx
    add bx,6
    mov endx,bx
    mov bx,bally
    mov starty,bx
    mov endy,bx
    call draw_objects
    
   
    mov bx,ballx
    mov startx,bx
    add bx,6
    mov endx,bx 
    mov bx,bally
    sub bx,1
    mov starty,bx
    mov endy,bx
    call draw_objects
     
    ret 
    ball endp


draw_objects proc
     mov ah,0ch
     mov al,color
     mov cx,startx
     mov dx,starty
     
     
     cmp cx,endx
     jne draw_x
     cmp dx,endy
     jne draw_y
     
     draw_x:
         int 10h
         cmp cx,endx
         inc cx
         jbe draw_x
         ret
     draw_y:
         int 10h
         cmp dx,endy
         inc dx
         jbe draw_y   
         
           
    
          ret
          draw_objects endp 



game_started proc
    
     
     continue:
             
             call ball_position_update
             call wall_hit
             call keyboard_check
             call striker_hit
             
             cmp bally,158
             jb brick_h
             jmp continue
             
            brick_h:
             call brick_hit               
                            
                             
             
             
             
             
             jmp continue
     
    
    game_started endp

ball_position_update proc
    
    mov color,0
    mov bx,ballx
    mov startx,bx
    add bx,6
    mov endx,bx
    mov bx,bally
    mov starty,bx
    mov endy,bx
    call draw_objects
    
    
    mov bx,ballx
    mov startx,bx
    add bx,6
    mov endx,bx 
    mov bx,bally
    sub bx,1
    mov starty,bx
    mov endy,bx
    call draw_objects
    
    
    mov color,15
    cmp started,0
    je  just_x
    jmp all
    
    just_x:
          mov bx,ball_ns
          mov ballx,bx
          mov startx,bx
          add bx,6
          mov endx,bx
          mov bx,bally
          mov starty,bx
          mov endy,bx
          call draw_objects
          
          mov bx,ball_ns
          mov ballx,bx
          mov startx,bx
          add bx,6
          mov endx,bx
          mov bx,bally
          sub bx,1
          mov starty,bx
          mov endy,bx
          call draw_objects
          ret
           
    
    all:
       ;execute below operations
    cmp vertical,1
    je  up
    jne down
    
    
    
    up:
      sub bally,8
      cmp horizontal,0
      je  left
      jne right 
      
    down:
       add bally,8
       cmp horizontal,0
       je  left
       jne right
       
    left:
        sub ballx,9
        mov bx,ballx
        mov startx,bx
        add bx,6
        mov endx,bx
        mov bx,bally
        mov starty,bx
        mov endy,bx
        call draw_objects
        
        
        mov bx,ballx
        mov startx,bx
        add bx,6
        mov endx,bx
        mov bx,bally
        sub bx,1
        mov starty,bx
        mov endy,bx
        call draw_objects
        ret
    right:
        add ballx,9
        mov bx,ballx
        mov startx,bx
        add bx,6
        mov endx,bx
        mov bx,bally
        mov starty,bx
        mov endy,bx
        call draw_objects
        
        
        mov bx,ballx
        mov startx,bx
        add bx,6
        mov endx,bx
        mov bx,bally
        sub bx,1
        mov starty,bx
        mov endy,bx
        call draw_objects
    
    
        ret
        ball_position_update endp

wall_hit proc
    mov bx,ballx
    cmp bx,leftw
    jbe update_l
    
    add bx,6
    cmp bx,rightw
    jge update_r
    
    mov bx,bally
    cmp bx,upw
    jbe update_u
    
    cmp bx,strikery
    jg update_d
    ret
    
    update_l:
             mov horizontal,1
             ret
    update_r:
             mov horizontal,0
             ret
    update_u:
             mov vertical,0
             ret  
    update_d:
            call gameover
    
    
    wall_hit endp


brick_hit proc
    
    
    mov di,0
    
    b_row:
          mov si,0
          b_column:
                  mov bx,brickx[si]
                  cmp ballx,bx
                  jae brick_ex
                  mov cx,ballx
                  add cx,6
                  cmp cx,bx
                  jae brick_ex
                  jmp inc_si
    
                  
    brick_ex:
            add bx,60
            cmp ballx,bx
            jbe check_y
            jmp inc_si
            
 
     
     check_y:
                mov bx,bricky[di]
                cmp bx,bally
                je call_rb
                mov cx,ballY
                dec cx
                cmp bx,cx
                je call_rb
                jmp inc_si
                ret
    
      
      inc_si:
            add si,2
            cmp si,10
            jb  b_column
            jmp inc_di
      
      inc_di:
            add di,2
            cmp di,6
            jb  b_row
            ret
            
      
      call_rb:
             call remove_brick
             ret
    
    brick_hit endp


striker_hit proc
     
     mov bx,372
     cmp bx,bally
     je check_sx
     ret
     check_sx:
           mov bx,strikerx
           cmp bx,ballx
           jae check_ex
           mov cx,ballx
           add cx,6
           cmp bx,cx
           jae check_ex
           ret
     check_ex:
           add bx,60
           cmp bx,ballx
           jbe go_up
           ret
          
     
     go_up:
          mov vertical,1
          ret
     
    striker_hit endp


remove_brick proc
      
     mov color,0
     mov bx,brickx[si]
     mov startx,bx
     add bx,60
     mov endx,bx
     mov bx,bricky[di]
     mov starty,bx
     mov endy,bx
     call draw_objects
     
     mov brickx[si],0
     mov bricky[di],0
     
     
     check_vertical:
                  cmp vertical,1
                  je  checky_down
                  jne checky_up
     
     checky_down:
                mov vertical,0
                ret
    
     checky_up:
                mov vertical,1
                ret
    
    remove_brick endp

move_striker proc
    mov bx,ballx
    mov ball_ns,bx
    cmp started,0
    je  ball_axis
    jmp no_ball_axis
    
    ball_axis:
              cmp ah,left_key
              je  ball_axisl
              jne ball_axisr
    no_ball_axis:
                cmp ah,left_key
                je move_left
                jne move_right
               
    
    
     ball_axisl:
               sub ball_ns,30
               call ball_position_update
               jmp move_left
     
     ball_axisr:
               add ball_ns,30
               call ball_position_update
               jmp move_right
    
    
    move_left:
             mov color,0
             mov bx,strikerx
             mov startx,bx
             add bx,60
             mov endx,bx
             mov starty,375
             mov endy,375
             call draw_objects
             
             mov color,6
             sub strikerx,30
             mov bx,strikerx
             mov startx,bx
             add bx,60
             mov endx,bx
             mov starty,375
             mov endy,375
             call draw_objects
             ret
         
    move_right:
             mov color,0
             mov bx,strikerx
             mov startx,bx
             add bx,60
             mov endx,bx
             mov starty,375
             mov endy,375
             call draw_objects
             
             mov color,6
             add strikerx,30
             mov bx,strikerx
             mov startx,bx
             add bx,60
             mov endx,bx
             mov starty,375
             mov endy,375
             call draw_objects
             ret 
    
   
    move_striker endp


keyboard_check proc
    
    mov ah,1
    int 16h
    
    jz no_key_pressed
    
    mov ah,0
    int 16h
    
    cmp ah,left_key
    je call_
    cmp ah,right_key
    je call_
    cmp ah,space
    je gameover
    cmp ah,01h
    je exit
    ret
    
    
    call_:
          call move_striker
          ret
    no_key_pressed:
                ret
                
   exit: 
        mov ah, 4Ch   
        int 21h
    
    
    keyboard_check endp


gameover proc
    
   mov ax,0003h    
   int 10h
   
    mov ah, 06h       
    mov al, 00h       
    mov bh, 07h       
    mov cx, 0000h     
    mov dx, 184Fh     
    int 10h 
    
   mov ah,9
   lea dx,over
   int 21h
   
   mov ah,1
   int 21h  
   
   call main
   
   ret
    gameover endp


end main