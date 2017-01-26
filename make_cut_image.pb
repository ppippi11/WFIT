
IncludeFile "cv_thinning_1.pbi"

ExamineDesktops()

Global getCV.b, *save.IplImage, exitCV.b, lpPrevWndFunc, nThin

; Enable all the decoders than PureBasic actually supports
UseJPEGImageDecoder()
UseTGAImageDecoder()
UsePNGImageDecoder()
UseTIFFImageDecoder()

; Enable all the encoders than PureBasic actually supports
UseJPEGImageEncoder()
UsePNGImageEncoder()

Dim colors(500,500)
Dim colorsN(500,500)

LoadFont (0, "HY크리스탈M", 250) ;저장시킬 폰트명과 크기를 Load한다.

If OpenWindow(0, 0, 0, 500, 500, "create JPEG file", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  
  If ReadFile(0, "2350.txt") ; if the file could be read, we continue...
    While Eof(0) = 0 ; loop as long the 'end of file' isn't reached
      kk$ = ReadString(0)
      k$ = "$"+ kk$ ; display line by line in the debug window
      k = Val(k$)
      ;글자를 출력하기 위해 유니코드를 사용하였다.
      ;한글 유니코드의 범위는 AC00(가)~D7A3(힣)이다.
      
      If CreateImage(0, 500, 500)
        
        If StartDrawing(ImageOutput(0))     ;그림을 그리기 시작한다.       
          
          Box(0, 0, 500, 500, RGB(0, 0, 0))  
          DrawingMode(1)                    ;배경색을 검정색으으로 한다.
          FrontColor(RGB(255, 255, 255))           ;폰트의 색을 흰색으로 한다.
          DrawingFont(FontID(0))                 
          DrawText(0,0,Chr(k)) ;For loop가 돌면서 한글 글자를 창에 나타낸다.
          ;배열에 (x,y) 색 값 저장
          For h = 0 To 499 
            For w = 0 To 499 
              colors(w,h) = Point(w,h) 
            Next          
          Next              
          minX=499
          maxX=0
          minY=499
          maxY=0
          For h=0 To 499
            For w=0 To 499
              If colors(w,h) =#White
                If minX>w
                  minX=w
                EndIf
                If minY>h
                  minY=h  
                EndIf
                If maxX<w
                  maxX = w
                EndIf
                If maxY<h
                  maxY = h
                EndIf
              EndIf
            Next
          Next  
          StopDrawing()
          
        EndIf                                     
      EndIf
      
      If CreateImage(1, 500,500)
        
        If StartDrawing(ImageOutput(1))     ;그림을 그리기 시작한다.       
        
          w =maxX-minX+1
          h = maxY-minY+1
          GrabImage(0, 1, minX, minY, w, h)
          ResizeImage(1,300*w/h,300)
          StopDrawing()      
          folder$ = Hex(k)
          
          SaveImage(1, "C:\Users\yunhee\Desktop\꿩\binaries\"+folder$+"\crystal.png", #PB_ImagePlugin_PNG)        
          
          OpenCV("C:\Users\yunhee\Desktop\꿩\binaries\"+folder$+"\crystal.png",folder$)
          ;SaveImage(1, "C:\Users\yunhee\Desktop\꿩\"+folder$+"\test.png", #PB_ImagePlugin_PNG)
          
        EndIf
      EndIf
      ;ImageGadget(0, 0, 0, 500, 500, ImageID(1), #PB_Image_Border)
      ;OpenCV("C:\Users\yunhee\Desktop\꿩\"+folder$+"\test.png")
    Wend
    CloseFile(0) ; close the previously opened file
  Else
    MessageRequester("Information","Couldn't open the file!")
  EndIf
  
EndIf
End
; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; CursorPosition = 80
; FirstLine = 42
; EnableUnicode
; EnableXP
; CurrentDirectory = binaries\