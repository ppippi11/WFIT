IncludeFile "includes/cv_functions.pbi"
ExamineDesktops()
Global getCV.b, *save.IplImage, exitCV.b, lpPrevWndFunc, nThin
#CV_WINDOW_NAME = "PureBasic Interface to OpenCV"
ProcedureC WindowCallback(hWnd, Msg, wParam, lParam)
  Select Msg
    Case #WM_COMMAND
      Select wParam
        Case 1
          getCV = #True
          keybd_event_(#VK_ESCAPE, 0, 0, 0)
        Case 2
          FileName.s = SaveFile()
          If FileName
            params.SAVE_INFO
            Select LCase(GetExtensionPart(FileName))
              Case "jpeg", "jpg", "jpe"
                params\paramId = #CV_IMWRITE_JPEG_QUALITY
                params\paramValue = 95

              Case "png"

                params\paramId = #CV_IMWRITE_PNG_COMPRESSION

                params\paramValue = 3

              Case "ppm", "pgm", "pbm"

                params\paramId = #CV_IMWRITE_PXM_BINARY

                params\paramValue = 1

              Default

                Select SelectedFilePattern()

                  Case 0

                    FileName + ".jpg"

                    params\paramId = #CV_IMWRITE_JPEG_QUALITY

                    params\paramValue = 95

                  Case 1

                    FileName + ".png"

                    params\paramId = #CV_IMWRITE_PNG_COMPRESSION

                    params\paramValue = 3

                  Case 2

                    FileName + ".ppm"

                    params\paramId = #CV_IMWRITE_PXM_BINARY

                    params\paramValue = 1

                EndSelect

            EndSelect

            cvSaveImage(FileName, *save, @params)

          EndIf

        Case 10

          keybd_event_(#VK_ESCAPE, 0, 0, 0)

      EndSelect

    Case #WM_DESTROY

      exitCV = #False

  EndSelect

  ProcedureReturn CallWindowProc_(lpPrevWndFunc, hWnd, Msg, wParam, lParam)

EndProcedure



ProcedureC CvMouseCallback(event, x.l, y.l, flags, *param.USER_INFO)

  Select event

    Case #CV_EVENT_RBUTTONDOWN

      *save = *param\uPointer1

      DisplayPopupMenu(0, *param\uValue)

  EndSelect

EndProcedure



ProcedureC InitThinning(Array *kpw.CvMat(1), Array *kpb.CvMat(1))

  For rtnCount = 0 To 8 - 1

    *kpw(rtnCount) = cvCreateMat(3, 3, CV_MAKETYPE(#CV_8U, 1))

    *kpb(rtnCount) = cvCreateMat(3, 3, CV_MAKETYPE(#CV_8U, 1))

    cvSet(*kpw(rtnCount), 0, 0, 0, 0, #Null)

    cvSet(*kpb(rtnCount), 0, 0, 0, 0, #Null)

  Next

  cvSet2D(*kpb(0), 0, 0, 1, 0, 0, 0)

  cvSet2D(*kpb(0), 0, 1, 1, 0, 0, 0)

  cvSet2D(*kpb(0), 1, 0, 1, 0, 0, 0)

  cvSet2D(*kpw(0), 1, 1, 1, 0, 0, 0)

  cvSet2D(*kpw(0), 1, 2, 1, 0, 0, 0)

  cvSet2D(*kpw(0), 2, 1, 1, 0, 0, 0)

  cvSet2D(*kpb(1), 0, 0, 1, 0, 0, 0)

  cvSet2D(*kpb(1), 0, 1, 1, 0, 0, 0)

  cvSet2D(*kpb(1), 0, 2, 1, 0, 0, 0)

  cvSet2D(*kpw(1), 1, 1, 1, 0, 0, 0)

  cvSet2D(*kpw(1), 2, 0, 1, 0, 0, 0)

  cvSet2D(*kpw(1), 2, 1, 1, 0, 0, 0)

  cvSet2D(*kpb(2), 0, 1, 1, 0, 0, 0)

  cvSet2D(*kpb(2), 0, 2, 1, 0, 0, 0)

  cvSet2D(*kpb(2), 1, 2, 1, 0, 0, 0)

  cvSet2D(*kpw(2), 1, 0, 1, 0, 0, 0)

  cvSet2D(*kpw(2), 1, 1, 1, 0, 0, 0)

  cvSet2D(*kpw(2), 2, 1, 1, 0, 0, 0)

  cvSet2D(*kpb(3), 0, 2, 1, 0, 0, 0)

  cvSet2D(*kpb(3), 1, 2, 1, 0, 0, 0)

  cvSet2D(*kpb(3), 2, 2, 1, 0, 0, 0)

  cvSet2D(*kpw(3), 0, 0, 1, 0, 0, 0)

  cvSet2D(*kpw(3), 1, 0, 1, 0, 0, 0)

  cvSet2D(*kpw(3), 1, 1, 1, 0, 0, 0)

  cvSet2D(*kpb(4), 1, 2, 1, 0, 0, 0)

  cvSet2D(*kpb(4), 2, 2, 1, 0, 0, 0)

  cvSet2D(*kpb(4), 2, 1, 1, 0, 0, 0)

  cvSet2D(*kpw(4), 0, 1, 1, 0, 0, 0)

  cvSet2D(*kpw(4), 1, 1, 1, 0, 0, 0)

  cvSet2D(*kpw(4), 1, 0, 1, 0, 0, 0)

  cvSet2D(*kpb(5), 2, 0, 1, 0, 0, 0)

  cvSet2D(*kpb(5), 2, 1, 1, 0, 0, 0)

  cvSet2D(*kpb(5), 2, 2, 1, 0, 0, 0)

  cvSet2D(*kpw(5), 0, 2, 1, 0, 0, 0)

  cvSet2D(*kpw(5), 0, 1, 1, 0, 0, 0)

  cvSet2D(*kpw(5), 1, 1, 1, 0, 0, 0)

  cvSet2D(*kpb(6), 1, 0, 1, 0, 0, 0)

  cvSet2D(*kpb(6), 2, 0, 1, 0, 0, 0)

  cvSet2D(*kpb(6), 2, 1, 1, 0, 0, 0)

  cvSet2D(*kpw(6), 0, 1, 1, 0, 0, 0)

  cvSet2D(*kpw(6), 1, 1, 1, 0, 0, 0)

  cvSet2D(*kpw(6), 1, 2, 1, 0, 0, 0)

  cvSet2D(*kpb(7), 0, 0, 1, 0, 0, 0)

  cvSet2D(*kpb(7), 1, 0, 1, 0, 0, 0)

  cvSet2D(*kpb(7), 2, 0, 1, 0, 0, 0)

  cvSet2D(*kpw(7), 1, 1, 1, 0, 0, 0)

  cvSet2D(*kpw(7), 1, 2, 1, 0, 0, 0)

  cvSet2D(*kpw(7), 2, 2, 1, 0, 0, 0)
EndProcedure
ProcedureC OpenCV(ImageFile.s)

  If FileSize(ImageFile) > 0

    cvNamedWindow(#CV_WINDOW_NAME, #CV_WINDOW_AUTOSIZE)

    window_handle = cvGetWindowHandle(#CV_WINDOW_NAME)

    *window_name = cvGetWindowName(window_handle)

    lpPrevWndFunc = SetWindowLongPtr_(window_handle, #GWL_WNDPROC, @WindowCallback())

    hWnd = GetParent_(window_handle)

    opencv = LoadImage_(GetModuleHandle_(0), @"icons/opencv.ico", #IMAGE_ICON, 35, 32, #LR_LOADFROMFILE)

    SendMessage_(hWnd, #WM_SETICON, 0, opencv)

    wStyle = GetWindowLongPtr_(hWnd, #GWL_STYLE)

    SetWindowLongPtr_(hWnd, #GWL_STYLE, wStyle & ~(#WS_MAXIMIZEBOX | #WS_MINIMIZEBOX | #WS_SIZEBOX))

    *image.IplImage = cvLoadImage(ImageFile, #CV_LOAD_IMAGE_GRAYSCALE)

    dtWidth = DesktopWidth(0)

    dtHeight = DesktopHeight(0)



    If *image\width >= dtWidth - 100 Or *image\height >= dtHeight - 100

      iWidth = dtWidth - 100

      iRatio1.d = iWidth / *image\width

      iHeight = dtHeight - 100

      iRatio2.d = iHeight / *image\height



      If iRatio1 < iRatio2

        iWidth = *image\width * iRatio1

        iHeight = *image\height * iRatio1

      Else

        iWidth = *image\width * iRatio2

        iHeight = *image\height * iRatio2

      EndIf

      cvResizeWindow(#CV_WINDOW_NAME, iWidth, iHeight)

      *resize.IplImage = cvCreateImage(iWidth, iHeight, #IPL_DEPTH_8U, *image\nChannels)

      cvResize(*image, *resize, #CV_INTER_AREA)

    Else

      cvResizeWindow(#CV_WINDOW_NAME, *image\width, *image\height)

      *resize.IplImage = cvCloneImage(*image)

    EndIf

    cvMoveWindow(#CV_WINDOW_NAME, 20, 20)



    If *resize\width > 200 And *resize\height > 200

      BringToTop(hWnd)

      *param.USER_INFO = AllocateMemory(SizeOf(USER_INFO))

      *param\uPointer1 = *resize

      *param\uValue = window_handle

      cvSetMouseCallback(*window_name, @CvMouseCallback(), *param)

        Dim *kpb.CvMat(8)

        Dim *kpw.CvMat(8)

        InitThinning(*kpw(), *kpb())

        *thin.IplImage = cvCloneImage(*resize)

        *resize_f.IplImage = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_32F, 1)

        *resize_w.IplImage = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_32F, 1)

        *resize_b.IplImage = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_32F, 1)

        cvConvertScale(*resize, *resize_f, 1 / 255, 0)    

        cvThreshold(*resize_f, *resize_f, 0.5, 1, #CV_THRESH_BINARY)

        cvThreshold(*resize_f, *resize_w, 0.5, 1, #CV_THRESH_BINARY)

        cvThreshold(*resize_f, *resize_b, 0.5, 1, #CV_THRESH_BINARY_INV)

        scalar.CvScalar

        BringToTop(hWnd)



        Repeat

          sum.d = 0



          For rtnCount = 0 To 8 - 1

            cvFilter2D(*resize_w, *resize_w, *kpw(rtnCount), -1, -1)

            cvFilter2D(*resize_b, *resize_b, *kpb(rtnCount), -1, -1)

            cvThreshold(*resize_w, *resize_w, 2.99, 1, #CV_THRESH_BINARY)

            cvThreshold(*resize_b, *resize_b, 2.99, 1, #CV_THRESH_BINARY)

            cvAnd(*resize_w, *resize_b, *resize_w, #Null)

            cvSum(@scalar, *resize_w)

            sum + scalar\val[0]

            cvXor(*resize_f, *resize_w, *resize_f, #Null)

            cvCopy(*resize_f, *resize_w, #Null)

            cvThreshold(*resize_f, *resize_b, 0.5, 1, #CV_THRESH_BINARY_INV)

          Next


        Until keyPressed = 13 Or keyPressed = 27 Or exitCV Or sum = 0



        If sum = 0

          cvConvertScaleAbs(*resize_f, *thin, 255, 0)

          *color.IplImage = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_8U, 3)

          cvCvtColor(*thin, *color, #CV_GRAY2BGR, 1)

          *reset.IplImage = cvCloneImage(*color)

          iRatio.d = 150 / *resize\width

          iWidth = *resize\width * iRatio

          iHeight = *resize\height * iRatio

          *PIP.IplImage = cvCreateImage(iWidth, iHeight, #IPL_DEPTH_8U, 3)

          *temp.IplImage = cvCreateImage(*resize\width, *resize\height, #IPL_DEPTH_8U, 3)

          cvCvtColor(*resize, *temp, #CV_GRAY2BGR, 1)

          cvResize(*temp, *PIP, #CV_INTER_AREA)

          BringToTop(hWnd)

          *param\uPointer1 = *color


            If *color

cvSaveImage("after_thinning.png", *color, #Null)
            EndIf

          

          FreeMemory(*param)

          cvReleaseImage(@*temp)

          cvReleaseImage(@*PIP)

          cvReleaseImage(@*reset)

          cvReleaseImage(@*color)

        EndIf

        cvReleaseImage(@*resize_b)

        cvReleaseImage(@*resize_w)

        cvReleaseImage(@*resize_f)

        cvReleaseImage(@*thin)

        cvReleaseMat(@*kpw)

        cvReleaseMat(@*kpb)

      EndIf

      cvReleaseImage(@*resize)
      cvReleaseImage(@*image)
      cvDestroyAllWindows()
      
      EndIf
      
EndProcedure

; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; CursorPosition = 29
; FirstLine = 237
; Folding = -
; EnableUnicode
; EnableXP