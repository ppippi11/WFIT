UseSQLiteDatabase() 

; Enable all the decoders than PureBasic actually supports
;
UseJPEGImageDecoder()
UseTGAImageDecoder()
UsePNGImageDecoder()
UseTIFFImageDecoder()

; Enable all the encoders than PureBasic actually supports
;
UseJPEGImageEncoder()
UsePNGImageEncoder()


#LVSICF_NOINVALIDATEALL = 1 
#LVN_ODCACHEHINT = #LVN_FIRST - 13 

#Img1 = 11
#Img2 = 12

Structure ImgSig
   ImgPath.s
   sequence.s
EndStructure

Declare WinCallback(hwnd, msg, wParam, lParam)
Declare.d GetImgDist(*Img1.ImgSig, *Img2.ImgSig)
Declare GetImgSig(*Img.ImgSig); path populated, pt's to be added
Declare.l LoadImages(Path.s, Array Images.ImgSig(1)) ;return count
Declare.l CompareImages(Array Images.ImgSig(1), FileCount.l);return count
Declare DoEvents()
Declare LoadForm()
Declare ProportionalImgResize(ImgID.i, MaxDimension.l)
;... Array to hold data 
Global Dim LvData.s(3,0) ;(4 rows, varible columns)

;Application Entry Point
LoadForm()

;================================================================

Procedure LoadForm()
    Dim Images.ImgSig(0)
    ImgSz.l = 300
    If OpenWindow(0, 0, 0, 1200, 850, "Image Distance", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_ScreenCentered)
        SetWindowCallback(@WinCallback())                         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; left column 
        ImageGadget(#Img1, 295, 505, ImgSz,ImgSz,0,#PB_Image_Border)
        ImageGadget(#Img2, 605, 505, ImgSz,ImgSz,0,#PB_Image_Border)
        If CreateStatusBar(0, WindowID(0))
            AddStatusBarField(1100) ; autosize this field
            AddStatusBarField(#PB_Ignore)
        EndIf
        hWndList.i=ListIconGadget(#PB_Any,2,2,1196,500,"Image 1",400,#LVS_OWNERDATA | #PB_ListIcon_FullRowSelect ) 
        AddGadgetColumn(hWndList,1,"Image 2",400) 
        AddGadgetColumn(hWndList,2,"L-H Avg Distance",195)
        AddGadgetColumn(hWndList,3,"Similarity(%)",195)
        If CreateMenu(0, WindowID(0))
            MenuTitle("File")
                MenuItem(1, "Load From Dir")  
                MenuBar()
                MenuItem(2, "Exit")
        EndIf 
        Repeat
            Event = WaitWindowEvent()
            Select Event
                Case #PB_Event_Gadget
                    Select EventGadget()
                        Case hWndList 
                            hWndImg1.i = LoadImage(#PB_Any, LvData(0,GetGadgetState(hWndList)))
                            hWndImg2.i = LoadImage(#PB_Any, LvData(1,GetGadgetState(hWndList)))
                            ProportionalImgResize(hWndImg1, ImgSz)                     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            ProportionalImgResize(hWndImg2, ImgSz)
                            SetGadgetState(#Img1, ImageID(hWndImg1))
                            SetGadgetState(#Img2, ImageID(hWndImg2))
                            FreeImage(hWndImg1)
                            FreeImage(hWndImg2)
                    EndSelect
                Case #PB_Event_Menu
                    Select EventMenu()
                        Case 1
                            FilePath.s = PathRequester("Select Images Directory", "C:\Users\yunhee\Desktop\꿩\binaries\AC00\")
                            If Len(FilePath) > 0
                                ImgCount.i = LoadImages(FilePath.s, Images())          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                ItemCount.i = CompareImages(Images(),imgcount)         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                SendMessage_(GadgetID(hWndList), #LVM_SETITEMCOUNT, ItemCount, #LVSICF_NOINVALIDATEALL) 
                            EndIf
                        Case 2 
                            Event = #PB_Event_CloseWindow
                    EndSelect
            EndSelect
        Until Event = #PB_Event_CloseWindow 
    EndIf 
EndProcedure

;================================================================

          Procedure WinCallback(hwnd, msg, wParam, lParam) 
              result = #PB_ProcessPureBasicEvents 
              Select msg 
                  Case #WM_NOTIFY 
                      *pnmh.NMHDR = lParam 
                      Select *pnmh\code 
                          Case #LVN_ODCACHEHINT 
                              result = 0  
                          Case #LVN_GETDISPINFO 
                              *pnmlvdi.NMLVDISPINFO = lParam 
                              If *pnmlvdi\item\mask & #LVIF_TEXT 
                                  ;... Item text is being requested 
                                  *pnmlvdi\item\pszText = @LvData(*pnmlvdi\item\iSubItem,*pnmlvdi\item\iItem) 
                              EndIf 
                  
                  EndSelect 
              EndSelect 
              ProcedureReturn result 
          EndProcedure 
          
;================================================================

          Procedure ProportionalImgResize(ImgID.i, MaxDimension.l)
              Protected MinDimension.f
              ImgHeight.l = ImageHeight(ImgID)
              ImgWidth.l = ImageWidth(ImgID)
              If ImgHeight > ImgWidth
                  MinDimension = (MaxDimension/ImgHeight) * ImgWidth
                  ResizeImage(ImgID,MinDimension,MaxDimension)
              Else
                  MinDimension = (MaxDimension/ImgWidth) * ImgHeight
                  ResizeImage(ImgID,MaxDimension,MinDimension)
              EndIf
          EndProcedure
          
;================================================================

          Procedure.l LoadImages(Path.s, Array Images.ImgSig(1))
              FileCount.i = 0
              hDir.i = ExamineDirectory(#PB_Any , Path, "*.png")  
              If hDir
                  While NextDirectoryEntry(hDir)
                      If DirectoryEntryType(hDir) = #PB_DirectoryEntry_File
                          ReDim Images(FileCount)
                          Images(FileCount)\ImgPath = Path + DirectoryEntryName(hDir)                
                          FileCount = FileCount + 1
                      EndIf
                  Wend
                  FinishDirectory(hDir)
              EndIf
              For i = 0 To FileCount -1
                  GetImgSig(@Images(i))          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  StatusBarText(0, 0, "Loading Image: " + Images(i)\ImgPath )
                  StatusBarText(0, 1, Str(i) + " of " + Str(FileCount-1))
                  DoEvents()                     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              Next
              ProcedureReturn FileCount
          EndProcedure
  
;================================================================

                  Procedure GetImgSig(*Img.ImgSig); path populated, pt's to be added
                      Protected ImgWidth.l
                      Protected ImgHeight.l
                     
                      Dim colorsN(501, 501)
                      
                      If FileSize(*Img\ImgPath) < 0
                          ProcedureReturn 0
                      EndIf
                          
                      ImgID.l = LoadImage(#PB_Any, *Img\ImgPath)
                      If ImgID
                          ResizeImage(ImgID, 500, 500)
                          ; Font Sequence ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                          ; colorsN(,)배열에 값 넣어주기 위해 필요
                          StartDrawing(ImageOutput(ImgID)) 
                          For h = 0 To 499
                            For w = 0 To 499
                              colorsN(w,h) = Point(w,h)
                            Next 
                          Next
                          ; 히스토그램
                          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                          *Img\sequence.s=""
                          count=0
                          For h=0 To 49
                            For w=0 To 49
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=0 To 49
                            For w=50 To 99
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=0 To 49
                            For w=100 To 149
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=0 To 49
                            For w=150 To 199
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=0 To 49
                            For w=200 To 249
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=0 To 49
                            For w=250 To 299
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=0 To 49
                            For w=300 To 349
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=0 To 49
                            For w=350 To 399
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=0 To 49
                            For w=400 To 449
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=0 To 49
                            For w=450 To 499
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                          count=0
                          For h=50 To 99
                            For w=0 To 49
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=50 To 99
                            For w=50 To 99
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=50 To 99
                            For w=100 To 149
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=50 To 99
                            For w=150 To 199
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=50 To 99
                            For w=200 To 249
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=50 To 99
                            For w=250 To 299
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=50 To 99
                            For w=300 To 349
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=50 To 99
                            For w=350 To 399
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=50 To 99
                            For w=400 To 449
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=50 To 99
                            For w=450 To 499
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                          
                          count=0
                          For h=100 To 149
                            For w=0 To 49
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=100 To 149
                            For w=50 To 99
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=100 To 149
                            For w=100 To 149
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=100 To 149
                            For w=150 To 199
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=100 To 149
                            For w=200 To 249
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=100 To 149
                            For w=250 To 299
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=100 To 149
                            For w=300 To 349
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=100 To 149
                            For w=350 To 399
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=100 To 149
                            For w=400 To 449
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=100 To 149
                            For w=450 To 499
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                                
                          count=0
                          For h=150 To 199
                            For w=0 To 49
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=150 To 199
                            For w=50 To 99
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=150 To 199
                            For w=100 To 149
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=150 To 199
                            For w=150 To 199
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=150 To 199
                            For w=200 To 249
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=150 To 199
                            For w=250 To 299
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=150 To 199
                            For w=300 To 349
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=150 To 199
                            For w=350 To 399
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=150 To 199
                            For w=400 To 449
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=150 To 199
                            For w=450 To 499
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                             
                          count=0
                          For h=200 To 249
                            For w=0 To 49
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=200 To 249
                            For w=50 To 99
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=200 To 249
                            For w=100 To 149
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=200 To 249
                            For w=150 To 199
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=200 To 249
                            For w=200 To 249
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=200 To 249
                            For w=250 To 299
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=200 To 249
                            For w=300 To 349
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=200 To 249
                            For w=350 To 399
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=200 To 249
                            For w=400 To 449
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=200 To 249
                            For w=450 To 499
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                             
                          count=0
                          For h=250 To 299
                            For w=0 To 49
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=250 To 299
                            For w=50 To 99
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=250 To 299
                            For w=100 To 149
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=250 To 299
                            For w=150 To 199
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=250 To 299
                            For w=200 To 249
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=250 To 299
                            For w=250 To 299
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=250 To 299
                            For w=300 To 349
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=250 To 299
                            For w=350 To 399
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=250 To 299
                            For w=400 To 449
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=250 To 299
                            For w=450 To 499
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                              
                          count=0
                          For h=300 To 349
                            For w=0 To 49
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=300 To 349
                            For w=50 To 99
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=300 To 349
                            For w=100 To 149
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=300 To 349
                            For w=150 To 199
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=300 To 349
                            For w=200 To 249
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=300 To 349
                            For w=250 To 299
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=300 To 349
                            For w=300 To 349
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=300 To 349
                            For w=350 To 399
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=300 To 349
                            For w=400 To 449
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=300 To 349
                            For w=450 To 499
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                             
                          count=0
                          For h=350 To 399
                            For w=0 To 49
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=350 To 399
                            For w=50 To 99
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=350 To 399
                            For w=100 To 149
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=350 To 399
                            For w=150 To 199
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=350 To 399
                            For w=200 To 249
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=350 To 399
                            For w=250 To 299
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=350 To 399
                            For w=300 To 349
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=350 To 399
                            For w=350 To 399
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=350 To 399
                            For w=400 To 449
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=350 To 399
                            For w=450 To 499
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                                                       
                          count=0
                          For h=400 To 449
                            For w=0 To 49
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=400 To 449
                            For w=50 To 99
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=400 To 449
                            For w=100 To 149
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=400 To 449
                            For w=150 To 199
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=400 To 449
                            For w=200 To 249
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=400 To 449
                            For w=250 To 299
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=400 To 449
                            For w=300 To 349
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=400 To 449
                            For w=350 To 399
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=400 To 449
                            For w=400 To 449
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=400 To 449
                            For w=450 To 499
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                             
                          count=0
                          For h=450 To 499
                            For w=0 To 49
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=450 To 499
                            For w=50 To 99
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=450 To 499
                            For w=100 To 149
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=450 To 499
                            For w=150 To 199
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=450 To 499
                            For w=200 To 249
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=450 To 499
                            For w=250 To 299
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=450 To 499
                            For w=300 To 349
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=450 To 499
                            For w=350 To 399
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=450 To 499
                            For w=400 To 449
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          count=0
                          For h=450 To 499
                            For w=450 To 499
                              If colorsN(w,h) = #Black
                                count=count+1
                              EndIf            
                            Next
                          Next
                          *Img\sequence=*Img\sequence+RSet(Str(count), 4, "0")
                          StopDrawing()
                        EndIf   
                  EndProcedure
                  
;================================================================

                  Procedure DoEvents()
                      While WindowEvent() : Wend
                  EndProcedure
                  
;================================================================

          Procedure.l CompareImages(Array Images.ImgSig(1), FileCount.l)
              If OpenDatabase(0, ":memory:", "", "") 
                  DatabaseUpdate(0, "CREATE TABLE ImgDistances (File1 text, File2 text, Distance INT, Similarity INT)") 
                  For i = 0 To 0
                      For j = 0 To FileCount - 1
                          If i = j Or j < i 
                              ;skip self compare or prev compared
                          Else
                            ;Debug GetImgDist(@Images(0),@Images(j))
                              key.d = GetImgDist(@Images(0),@Images(j)) / 25.00
                              key = 100 - key
                              DatabaseUpdate(0, "INSERT INTO ImgDistances (File1,File2,Distance,Similarity) VALUES ('" + Images(0)\ImgPath + "','" + Images(j)\ImgPath + "',"+ StrD(GetImgDist(@Images(0),@Images(j)),2) + ","+ StrD(key,2) +")") 
                          EndIf                   
                      Next
                      DoEvents()                          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  Next
                  sSQL.s = "select * from ImgDistances  order by distance" ;where Distance < 200
                  RetRowCount = 0
                  If DatabaseQuery(0, sSQL) 
                      While NextDatabaseRow(0) 
                          ;PrintN(GetDatabaseString(0, 0) + "," + GetDatabaseString(0, 1) + "," + Str(GetDatabaseLong(0, 2)))
                          ReDim LvData(3,RetRowCount)
                          LvData(0,RetRowCount) = GetDatabaseString(0, 0)
                          LvData(1,RetRowCount) = GetDatabaseString(0, 1)
                          LvData(2,RetRowCount) = StrD(GetDatabaseDouble(0, 2),2)
                          LvData(3,RetRowCount) = StrD(GetDatabaseDouble(0, 3),2)                          
                          RetRowCount = RetRowCount + 1
                      Wend        
                      FinishDatabaseQuery(0) 
                  EndIf 
              EndIf  
              ProcedureReturn RetRowCount
          EndProcedure

;================================================================

                  Procedure.d GetImgDist(*Img1.ImgSig, *Img2.ImgSig)
                      Distance.d = 0
                      For i=1 To 400 Step 4
                        Distance = Distance + Abs(Val(Mid(*Img1\sequence,i,4))-Val(Mid(*Img2\sequence,i,4)))
                      Next
                      Distance = Distance / 100
                      ProcedureReturn Distance
                    EndProcedure
                    
; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 64
; Folding = --
; EnableUnicode
; EnableXP