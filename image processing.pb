; purebasic 5.00(x86)
UseJPEGImageDecoder()
UsePNGImageDecoder()
UseJPEGImageEncoder()
UsePNGImageEncoder()
UseTGAImageDecoder()
UseTIFFImageDecoder()

#Image1=1

;- Includes
IncludeFile "thinning.pb"

;- Constants

#MaxDistance = $FFFFFFF
#MaxDitherMethods = 128
#MaxDitherMatrixSize = 256

Enumeration
  #RotateImageLeft
  #RotateImageRight
EndEnumeration

Enumeration
  #FlipImageHorizontal
  #FlipImageVertical
EndEnumeration

Enumeration
  #GrayscaleImage_Mean
  #GrayscaleImage_Weighted
  #GrayscaleImage_Weighted2
EndEnumeration

;- Structures

Structure hsl
  h.f
  s.f
  l.f
EndStructure

Structure hsv
  h.f
  s.f
  v.f
EndStructure

;- Macros

Macro NormalizeRGB(r, g, b)
  
  ; ***************************************************************************
  ;
  ; Function: Truncates RGB values to a range of 0 to 255
  ;
  ; ***************************************************************************
  
  If r > 255
    r = 255
  ElseIf r < 0
    r = 0
  EndIf 
  
  If g > 255 
    g = 255
  ElseIf g < 0
    g = 0
  EndIf 
  
  If b > 255 
    b = 255
  ElseIf b < 0
    b = 0
  EndIf 
  
EndMacro

Macro ContrastStretch_CalculateThresholds(Array, min, max)
  
  
  ; ***************************************************************************
  ;
  ; Function: Calculate thresholds for performing contrast stretching
  ;
  ; Notes:    Part of the ContrastStretchImage() procedure
  ;
  ; ***************************************************************************
  
  color = 0
  count = 0
  Repeat
    count + Array(color)
    color + 1
  Until count > lower_target Or color > 255
  min = color - 1
  color = 255
  count = 0
  Repeat
    count + Array(color)
    color - 1
  Until count > upper_target Or color < 0
  max = color + 1
  If max = min
    FreeMemory(*mem)
    ProcedureReturn 0
  EndIf
  
EndMacro

;- Procedures

Procedure CopyImageToMemory(image_no.l, *mem)
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Protected TemporaryDC.l, TemporaryBitmap.BITMAP, TemporaryBitmapInfo.BITMAPINFO 
    TemporaryDC = CreateDC_("DISPLAY", #Null, #Null, #Null) 
    GetObject_(ImageID(image_no), SizeOf(BITMAP), TemporaryBitmap.BITMAP) 
    TemporaryBitmapInfo\bmiHeader\biSize        = SizeOf(BITMAPINFOHEADER) 
    TemporaryBitmapInfo\bmiHeader\biWidth       = TemporaryBitmap\bmWidth 
    TemporaryBitmapInfo\bmiHeader\biHeight      = -TemporaryBitmap\bmHeight 
    TemporaryBitmapInfo\bmiHeader\biPlanes      = 1
    TemporaryBitmapInfo\bmiHeader\biBitCount    = 32 
    TemporaryBitmapInfo\bmiHeader\biCompression = #BI_RGB
    GetDIBits_(TemporaryDC, ImageID(image_no), 0, TemporaryBitmap\bmHeight, *mem, TemporaryBitmapInfo, #DIB_RGB_COLORS)
    DeleteDC_(TemporaryDC)
  CompilerElse
    Protected x.l, y.l, mem_pos.l
    mem_pos = 0
    StartDrawing(ImageOutput(image_no))
    For y = 0 To ImageHeight(image_no) - 1
      For x = 0 To ImageWidth(image_no) - 1
        PokeL(*mem + mem_pos, ReverseRGB(Point(x, y)))
        mem_pos + 4
      Next
    Next
    StopDrawing()
  CompilerEndIf
EndProcedure
Procedure CopyMemoryToImage(*mem, image_no.l)
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Protected TemporaryDC.l, TemporaryBitmap.BITMAP, TemporaryBitmapInfo.BITMAPINFO 
    TemporaryDC = CreateDC_("DISPLAY", #Null, #Null, #Null) 
    GetObject_(ImageID(image_no), SizeOf(BITMAP), TemporaryBitmap.BITMAP) 
    TemporaryBitmapInfo\bmiHeader\biSize        = SizeOf(BITMAPINFOHEADER) 
    TemporaryBitmapInfo\bmiHeader\biWidth       = TemporaryBitmap\bmWidth 
    TemporaryBitmapInfo\bmiHeader\biHeight      = -TemporaryBitmap\bmHeight 
    TemporaryBitmapInfo\bmiHeader\biPlanes      = 1 
    TemporaryBitmapInfo\bmiHeader\biBitCount    = 32 
    TemporaryBitmapInfo\bmiHeader\biCompression = #BI_RGB 
    SetDIBits_(TemporaryDC, ImageID(image_no), 0, TemporaryBitmap\bmHeight, *mem, TemporaryBitmapInfo, #DIB_RGB_COLORS) 
    DeleteDC_(TemporaryDC)
  CompilerElse
    Protected x.l, y.l, mem_pos.l
    mem_pos = 0
    StartDrawing(ImageOutput(image_no))
    For y = 0 To ImageHeight(image_no) - 1
      For x = 0 To ImageWidth(image_no) - 1
        Plot(x, y, ReverseRGB(PeekL(*mem + mem_pos)))
        mem_pos + 4
      Next
    Next    
    StopDrawing()
  CompilerEndIf
EndProcedure
Procedure.l InvertImage(image_no.l)
  
  ; ***************************************************************************
  ;
  ; Function: Inverts the color of an image
  ;
  ; Returns:  '1' if successful, otherwise '0'
  ;
  ; ***************************************************************************
  
  Protected *mem, mem_size, mem_pos
  
  If IsImage(image_no) = 0
    ProcedureReturn 0
  EndIf
  
  mem_size = ImageWidth(image_no) * ImageHeight(image_no) << 2
  *mem = AllocateMemory(mem_size)
  If *mem = 0
    ProcedureReturn 0
  EndIf
  
  CopyImageToMemory(image_no, *mem)
  For mem_pos = 0 To mem_size - 1 Step 4 
    PokeL(*mem + mem_pos, ~PeekL(*mem + mem_pos))
  Next 
  CopyMemoryToImage(*mem, image_no) 
  FreeMemory(*mem) 
  
  ProcedureReturn 1
  
EndProcedure 



;---------------------------

LoadImage(#Image1, "after_bw.png")
width =ImageWidth(#Image1)
height =ImageHeight(#Image1)


;;; 흑백처리된 이미지를 넣어서 바탕이 흰색이면 반전시켜줌
StartDrawing(ImageOutput(#Image1))
If Point(0,0) = #White
  InvertImage(#Image1)
EndIf
StopDrawing()


;;; 반전시킨 이미지를 글자만 잡아서 높이 300으로 맞춰서 리사이즈
StartDrawing(ImageOutput(#Image1))

minX= width-1
maxX=0
minY= height-1
maxY=0

For h=0 To height-1
  For w=0 To width-1
    If Point(w,h) =#White
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

CreateImage(3, width,height)
StartDrawing(ImageOutput(3))
w =maxX-minX+1
h = maxY-minY+1
GrabImage(#Image1, 3, minX, minY, w, h)        
ResizeImage(3,300*w/h,300)
SaveImage(3, "C:\Users\yunhee\Desktop\꿩\after_resize.png", #PB_ImagePlugin_PNG)
StopDrawing()

ExamineDesktops()
OpenCV("C:\Users\yunhee\Desktop\꿩\after_resize.png")




; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 153
; FirstLine = 132
; Folding = v
; EnableXP