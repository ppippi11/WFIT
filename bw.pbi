UseJPEGImageDecoder()
UsePNGImageDecoder()
UseTGAImageDecoder()
UseTIFFImageDecoder()
UseJPEGImageEncoder()
UsePNGImageEncoder()

#True = 1
#False = 0

Procedure greyscale(img, Array srcData(1))
  Protected width, height, x, y, gray, pixel
  If Not IsImage(img) : ProcedureReturn #False : EndIf
  
  StartDrawing(ImageOutput(img))
    width = ImageWidth(img) - 1
    height = ImageHeight(img) - 1
    For y = 0 To height
      For x = 0 To width
        pixel = Point(x, y)
        grey = Red(pixel) * 77    ; 0.2989 * 256 = 76.5184
        grey + Green(pixel) * 150 ; 0.5870 * 256 = 150.2720
        grey + Blue(pixel) * 29   ; 0.1140 * 256 = 29.1840
        grey = grey >> 8          ; / 256
        Plot(x, y, RGB(grey, grey, grey))
        srcData(y * (width + 1) + x) = grey
      Next
    Next
  StopDrawing()
  
  ProcedureReturn #True
EndProcedure

Procedure createImageWithThreshold(img, Array srcData(1), threshold)
  Protected width, height, x, y, gray, pixel
  If Not IsImage(img) : ProcedureReturn #False : EndIf
  
  StartDrawing(ImageOutput(img))
    width = ImageWidth(img) - 1
    height = ImageHeight(img) - 1
    For y = 0 To height
      For x = 0 To width
        pixel = srcData(y * (width + 1) + x)
        If pixel >= threshold
          pixel = RGB(255, 255, 255)
        Else 
          pixel = RGB(0, 0, 0)
        EndIf 
        
        Plot(x, y, pixel)
      Next
    Next
  StopDrawing()
  
  ProcedureReturn #True
EndProcedure

Procedure otsu_threashold(Array srcData(1))
  ;The input is an array of bytes, srcData that stores the greyscale image
  
  ;Calculate histogram
  Protected srcDataLength = ArraySize(srcData()), ptr, h
  Protected Dim histData($FF)
  
  While ptr < srcDataLength
    h = $FF & srcData(ptr)
    histData(h) + 1
    ptr + 1
  Wend
  
  Protected.f sum, sumB, varMax, varBetween, mB, mF
  Protected wB, wF, threshold
  
  For t = 0 To $FF
    sum + t * histData(t)
  Next
  
  For t = 0 To $FF
    wB + histData(t)         ;Weight Background
    If wB = 0: Continue: EndIf
    
    wF = srcDataLength - wB  ;Weight Foreground
    If wF = 0: Break: EndIf
    
    sumB + t * histData(t)
    mB = sumB / wB           ;Mean Background
    mF = (sum - sumB) / wF   ;Mean Foreground
    
    ;Calculate Between Class Variance
    varBetween = (mB - mF) * (mB - mF) * wB * wF

    ;Check If new maximum Found
    If varBetween > varMax
      varMax = varBetween
      threshold = t
    EndIf 
  Next
  ProcedureReturn threshold
EndProcedure

Enumeration
  ;windows
  #main_win = 0
  ;gadgets
  #load_btn = 0
  #sourceImage_img
  #resultImage_img
  #threshold_trk
  #threshold_txt
  ;images
  #originalImage = 0
  #thresholdImage
EndEnumeration

OpenWindow(#main_win, 0, 0, 530, 350, " Black & White", #PB_Window_SystemMenu)
ButtonGadget(#load_btn, 0, 0, 100, 20, "Load Picture")
Define Event, EventGadget, FileName.s, threshold

Repeat
  Event = WaitWindowEvent(10)
  Select Event
    Case #PB_Event_Gadget
      EventGadget = EventGadget()
      Select EventGadget
        Case #load_btn
          
          FileName = OpenFileRequester("Select source image:", "C:\*.*", "Image|*.png;*.jpg;*.bmp|All Files (*.*)|*.*", 0)
          If FileName
            LoadImage(#originalImage, FileName)
            Dim srcData(ImageWidth(#originalImage) * ImageHeight(#originalImage) - 1)
              greyscale(#originalImage, srcData())
               
              threshold = otsu_threashold(srcData())
              CopyImage(#originalImage, #thresholdImage)
              
              createImageWithThreshold(#thresholdImage, srcData(), threshold)
           SaveImage(#thresholdImage, "C:\Users\yunhee\Desktop\꿩\after_BW.png" ,#PB_ImagePlugin_PNG)
              
            EndIf
        Case #threshold_trk
          If GetGadgetState(#threshold_trk) <> threshold
            threshold = GetGadgetState(#threshold_trk)
            CopyImage(#originalImage, #thresholdImage)
            
           createImageWithThreshold(#thresholdImage, srcData(), threshold)
           SetGadgetState(#resultImage_img, ImageID(#thresholdImage))
            
          EndIf 
            
      EndSelect
  EndSelect

Until Event = #PB_Event_CloseWindow
; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 38
; FirstLine = 18
; Folding = -
; EnableUnicode
; EnableXP