#tag Class
Protected Class bevelButtonReplacement
Inherits Canvas
	#tag Event
		Sub Activate()
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub Deactivate()
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub DoubleClick(X As Integer, Y As Integer)
		  #pragma unused X
		  #pragma unused Y
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub EnableMenuItems()
		  
		End Sub
	#tag EndEvent

	#tag Event
		Function KeyDown(Key As String) As Boolean
		  If RaiseEvent KeyDown(key) Then // the USER handled the key
		    Return True // so cause the Keyup to NOT fire 
		  End If
		  
		  If key = &u20 Then
		    DoAction
		    Return True
		  End If
		  
		  Return True
		End Function
	#tag EndEvent

	#tag Event
		Function MouseDown(X As Integer, Y As Integer) As Boolean
		  mMouseIsDown = True
		  
		  Me.Invalidate
		  
		  mRaiseActionEvent = True
		  
		  Dim retValue As Boolean = RaiseEvent MouseDown(x,y)
		  
		  If retValue = True Then
		    mRaiseActionEvent = False
		  End If
		  
		  If mHasMenu = 1 Or mHasMenu = 2 Then
		    
		    If retValue = False Then
		      DoAction()
		    End If
		    
		  End If
		  
		  Return True
		  
		End Function
	#tag EndEvent

	#tag Event
		Sub MouseDrag(X As Integer, Y As Integer)
		  #pragma unused X
		  #pragma unused Y
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseEnter()
		  mMouseInside = True
		  
		  Me.Invalidate
		  
		  RaiseEvent MouseEnter
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseExit()
		  mMouseInside = False
		  
		  Me.Invalidate
		  
		  RaiseEvent MouseExit
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseUp(X As Integer, Y As Integer)
		  #Pragma unused X
		  #pragma unused Y
		  
		  If mRaiseActionEvent Then
		    
		    If (x >= 0) And (x <= Me.width) And (y >= 0) And (y <= Me.height) Then
		      
		      // ok here's a screwy set up 
		      // a toggle or sticky button with a menu
		      // we ignore the toggle and stickness
		      If (ButtonType = 1) And (HasMenu = 0) Then
		        // toggle the toggle button
		        value = Not value
		      Elseif (ButtonType = 2) And (HasMenu = 0) Then
		        // sticky buttons just get set to true
		        value = True
		      Else
		        DoAction
		      End If
		      
		    End If
		  End If
		  
		  System.debuglog CurrentMethodName
		  
		  mMouseIsDown = False
		  Me.Invalidate
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub Open()
		  If Self.AcceptFocus Then
		    Self.UseFocusRing = True
		  Else
		    Self.UseFocusRing = False
		  End If
		  
		  RaiseEvent Open
		End Sub
	#tag EndEvent

	#tag Event
		Sub Paint(g As Graphics, areas() As REALbasic.Rect)
		  #Pragma unused areas
		  
		  DrawBackAndBevel(g)
		  
		  DrawIcon(g)
		  
		  DrawMenuIndicator(g)
		  
		  DrawCaption(g)
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub ScaleFactorChanged()
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub AddRow(rowText as string)
		  If mMenu IsA Object Then
		    RaiseMenuError
		  End If
		  
		  mMenuTextRows.Append rowtext
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AddSeparator()
		  If mMenu IsA Object Then
		    RaiseMenuError
		  End If
		  
		  mMenuTextRows.Append "-"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ClearIsMenuShowing()
		  mIsMenuShowing = False
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function CloneMenuItem(orig As MenuItem) As MenuItem
		  If orig Is Nil Then
		    Return Nil
		  End If
		  
		  Dim clone As New MenuItem(orig)
		  
		  For row As Integer = clone.Count - 1 DownTo 0
		    clone.Remove(row)
		  Next
		  
		  For i As Integer = 0 To orig.Count - 1
		    Dim subMenu As MenuItem = orig.Item(i)
		    
		    If subMenu.Count = 0 Then
		      clone.Append New MenuItem(subMenu)
		    Else
		      clone.Append CloneMenuItem(subMenu)
		    End If
		  Next
		  
		  Return clone
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function darken(c as color) As color
		  
		  Dim darkerColor As Color = HSV(c.hue, c.Saturation, max(0,c.Value-0.2), c.Alpha)
		  
		  Return darkerColor
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DeleteAllRows()
		  Redim mMenuTextRows(-1)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DoAction()
		  If mHasMenu = 1 Or mHasMenu = 2 Then
		    If mIsMenuShowing Then
		      Return
		    End If
		    
		    Dim base As MenuItem = mMenu
		    
		    If base Is Nil And mMenuTextRows.Ubound <> -1 Then
		      base = New MenuItem
		      
		      For i As Integer = 0 To mMenuTextRows.Ubound
		        Dim item As New MenuItem(mMenuTextRows(i))
		        
		        If MenuValue >= 0 And i = MenuValue Then
		          item.Checked = True
		        End If
		        
		        base.Append item
		        
		      Next
		    End If
		    
		    Dim menuLeft As Integer
		    Dim menuTop As Integer
		    
		    FigureMenuPopupLocation(menuLeft, menuTop)
		    
		    If base <> Nil Then
		      mIsMenuShowing = True
		      Dim result As MenuItem = base.PopUp(menuLeft, menuTop)
		      
		      //
		      // Prevent a second click from showing the menu again on Windows
		      //
		      Xojo.Core.Timer.CallLater 250, WeakAddressOf ClearIsMenuShowing
		      
		      If result <> Nil Then
		        RaiseEvent MenuAction(result)
		      End If
		      
		    End If
		    
		  Else
		    RaiseEvent Action
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub DrawBackAndBevel(g as graphics)
		  Dim tmp As Boolean = g.AntiAlias
		  g.AntiAlias = True
		  
		  Dim midX As Integer
		  Dim midY As Integer
		  Dim ovalSize As Integer = 19
		  Dim topX As Integer
		  Dim topY As Integer
		  
		  // darn thing in this style is fixed size no matter what
		  Const kDisclosureBevelWidth = 20
		  Const kDisclosureBevelHeight = 20
		  
		  g.ClearRect 0, 0, g.width, g.height
		  g.ForeColor = BackColor
		  g.FillRect 0, 0, g.width, g.height
		  
		  // what colors to use ????
		  // ButtonType
		  // 0 - Button
		  // 1 - Toggle
		  // 2 - Sticky
		  If buttontype = kNormalBevel  Then
		    
		    If value Then
		      If IsDarkMode Then
		        g.ForeColor = lighten(backcolor) // lighten slightly
		      Else
		        g.forecolor = darken(backcolor) // darken slightly
		      End If
		    Else
		      // back color 
		      g.ForeColor = BackColor
		    End If
		    
		  Elseif buttontype = kLargeBevel Then
		    
		    If value Then
		      If IsDarkMode Then
		        g.ForeColor = lighten(backcolor) // lighten slightly
		      Else
		        g.forecolor = darken(backcolor) // darken slightly
		      End If
		    End If
		    
		  Elseif (HasBackColor And mMouseIsDown And Self.HasMenu = 0) Then
		    // if its dark mode do we light this ?
		    // and in light mode darken it ?
		    If IsDarkMode Then
		      g.ForeColor = lighten(backcolor) // lighten slightly
		    Else
		      g.forecolor = darken(backcolor) // darken slightly
		    End If
		    
		  Elseif mMouseIsDown And Self.HasMenu = 0 Then
		    // mouse down no back color
		    #Pragma BreakOnExceptions False
		    Try
		      g.ForeColor = SemanticColors.unemphasizedSelectedContentBackgroundColor
		    Catch
		      g.forecolor = SemanticColors.gridColor // which semantic color here !
		    End Try
		    #Pragma BreakOnExceptions default
		    
		  Elseif HasBackColor Then
		    // back color no mouse down
		    g.ForeColor = BackColor
		    
		  Else
		    // no back no mouse down
		    If Self.Value Then
		      #If TargetMacOS
		        g.ForeColor = SemanticColors.controlAccentColor
		      #Else
		        g.ForeColor = &c8CBAFF00
		      #EndIf
		    Else
		      #If TargetMacOS
		        g.ForeColor = SemanticColors.controlBackgroundColor
		      #Else
		        g.ForeColor = &cFFFEFE00
		      #EndIf
		    End If
		  End If
		  
		  #If TargetWindows
		    If mMouseInside Then
		      g.ForeColor = &cB2E0F9
		    End If
		  #EndIf
		  
		  // fill the background 
		  If bevel = kRoundedBevel Then // round rect style
		    g.FillRoundRect 0, 0, g.width, g.height, arcWidth, arcHeight
		    
		  Elseif bevel = kDisclosureBevel Then // disclosure style
		    g.FillRoundRect 0, (g.height/2) - (kDisclosureBevelHeight/2) , kDisclosureBevelWidth, kDisclosureBevelHeight, arcWidth, arcHeight
		    
		  Elseif bevel = kRoundBevel Or bevel = kLargeRoundBevel Then // round and large round (which appear to be the same)
		    midX = g.width / 2
		    midY = g.height / 2
		    //ovalSize = Min(g.height, g.width)
		    topX = midX - (ovalsize / 2)
		    topY = midY - (ovalSize / 2)
		    g.FillOval topX, topY, ovalSize, ovalSize
		  Elseif bevel = kNoBevel Then
		    // no bevel !!!!!!
		    
		  Elseif mMouseIsDown Then
		    System.debuglog "mouse is down"
		    If IsDarkMode Then
		      g.ForeColor = lighten(g.ForeColor) // lighten slightly
		    Else
		      g.forecolor = darken(g.ForeColor) // darken slightly
		    End If
		    g.FillRect 0, 0, g.width, g.height
		    
		  Elseif IsDarkMode Or Self.Value Then
		    System.debuglog "IsDarkMode Or Self.Value"
		    g.FillRect 0, 0, g.width, g.height
		  Else
		    System.debuglog "else"
		    //g.FillRect 0, 0, g.width, g.height
		    Dim sAmt, eAmt As Double
		    Dim startColor As Color
		    Dim endColor As Color
		    #If TargetWindows
		      If mMouseInside Then
		        startColor = &cE1F3FC
		        endColor = &cB2E0F9
		      Else
		        startColor = &cE9E9E9
		        endColor = &cF7F7F7
		      End If
		    #Else
		      startColor = &cE9E9E9
		      endColor = &cF7F7F7
		    #EndIf
		    
		    For i As Integer = 0 To height
		      sAmt = 1 - (i / g.height)
		      eAmt = i / g.height
		      g.ForeColor = RGB((startColor.Red * sAmt) + (endColor.Red * eAmt), _
		      (startColor.Green *sAmt) + (endColor.Green * eAmt), _
		      (startColor.Blue * sAmt) + (endColor.Blue * eAmt))
		      g.DrawLine(-1, i, g.width+1, i)
		    Next
		  End If
		  
		  
		  
		  // now draw the frame around it
		  // first figure out what color to use
		  #If TargetMacOS
		    #Pragma BreakOnExceptions False
		    Try
		      g.forecolor = SemanticColors.controlShadowColor
		    Catch
		      g.forecolor = SemanticColors.gridColor
		    End Try
		    #Pragma BreakOnExceptions default
		  #Else
		    g.ForeColor = DarkBevelColor
		  #EndIf
		  
		  Select Case bevel
		  Case kSmallBevel // 0 // - Small Bevel
		    g.DrawRect 0,0,g.width,g.height
		    
		  Case kNormalBevel // 1 // - Normal Bevel
		    g.DrawRect 0,0,g.width,g.height
		    
		  Case kLargeBevel // 2 // - Large Bevel
		    g.DrawRect 0,0,g.width,g.height
		    
		  Case kRoundedBevel // 3 // - Rounded Bevel
		    // oddly enough this one LOOKS like it fills the thing with white !?!?!?!?!?
		    g.DrawRoundRect 0,0,g.width,g.height, arcWidth, archeight
		    
		  Case kNoBevel // 4 // - No Bevel
		    // my favourite ... NOTHING TO DO !!!!!
		    // except the bevel button draws one :(
		    #If TargetMacOS Then
		      g.DrawRect 0,0,g.width,g.height
		    #EndIf
		    
		  Case kRoundBevel // 5 // - Round
		    g.DrawOval topX, topY, ovalSize, ovalSize
		    
		  Case kLargeRoundBevel // 6 // - Large Round
		    g.DrawOval topX, topY, ovalSize, ovalSize
		    
		  Case kDisclosureBevel // 7 // - Disclosure
		    g.DrawRoundRect 0, (g.height/2) - (kDisclosureBevelHeight/2) , kDisclosureBevelWidth, kDisclosureBevelHeight, arcWidth, arcHeight
		    
		  End Select
		  
		  
		  g.AntiAlias = tmp
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub DrawCaption(g as graphics)
		  Dim tmp As Boolean = g.AntiAlias
		  g.AntiAlias = True
		  
		  If bevel = kDisclosureBevel Then // disclosure style
		    
		    If mUseBevelButtonTextColor Then
		      g.forecolor = mTextColor
		    Elseif Self.Value Then
		      g.ForeColor = SemanticColors.selectedMenuItemTextColor
		    Else
		      g.ForeColor = SemanticColors.TextColor
		    End If
		    
		    #If TargetWindows
		      
		    #Else
		      g.DrawLine  6.5, 8.5, 10, 12.5
		      g.DrawLine 13.5, 8.5, 10, 12.5
		    #EndIf
		    
		  Else
		    
		    Const kGapToEdge = 2
		    
		    g.TextFont = TextFont
		    g.TextSize = TextSize
		    g.TextUnit = TextUnit
		    g.Bold = Bold
		    g.Italic = Italic
		    g.Underline = Underline
		    
		    Dim titleX As Integer 
		    Dim titleY As Integer
		    
		    // if caption is wider than g.width we remove in the middle until it fits
		    // and replace with ellipsis (singlechar not three dots)
		    // &u2026
		    Dim leftPos As Integer = Len(caption)/2
		    Dim leftChunk As String = Left(caption, leftPos)
		    Dim rightchunk As String = Mid(caption, leftPos+1)
		    Dim middleEllipsis As String
		    
		    While kGapToEdge + g.StringWidth(leftChunk+middleEllipsis+rightChunk) + kGapToEdge > g.width
		      leftChunk = Left(leftChunk , Len(leftChunk)-1)
		      rightChunk = Mid(rightchunk, 2)
		      If leftChunk.Len = 0 Or rightchunk.Len = 0 then
		        Exit While
		      End If
		      If middleEllipsis = "" Then
		        middleEllipsis = &u2026
		      End If
		    Wend
		    caption = leftChunk+middleEllipsis+rightChunk
		    
		    Dim captionWidth As Double = g.StringWidth(caption)
		    Dim captionHeight As Integer = g.StringHeight(caption, Me.width + 10)
		    titleY = (g.height - captionHeight)/2 + g.TextAscent
		    
		    Select Case CaptionAlign
		      
		    Case kCaptionAlignFlushLeft // 0 // - Flush left"
		      titleX = kGapToEdge
		      
		    Case kCaptionAlignFlushRight // 1 // - Flush right"
		      titleX = (g.width - kGapToEdge) - captionWidth
		      
		    Case kCaptionAlignSysDirection // 2 // - Sys direction"
		      // not exactly sure about this one
		      // so for now it matches Left
		      
		      titleX = kGapToEdge
		      
		    Else // includes Case 3 // - Center
		      // default to center
		      titleX = g.width/2 - captionWidth / 2
		      
		    End Select
		    
		    Select Case CaptionPlacement
		    Case 0 // - Sys Direction
		    Case 1 // - Normally
		      
		    Case 2 // - Right of graphic - this overrides whatever alignment is set above
		      titleX = mIconLeft + Icon.Width + kDefaultIconInset
		      titleY = mIconTop + (Icon.Height/2)
		      
		    Case 3 // - Left of graphic - this overrides whatever alignment is set above
		      titleX = mIconLeft - kDefaultIconInset - captionWidth
		      titleY = mIconTop + (Icon.Height/2)
		      
		    Case 4 // - Below graphic
		      titleY = mIconTop + Icon.Height + kDefaultIconInset + g.TextAscent
		      
		    Case 5 // - Above graphic
		      titleY = mIconTop - kDefaultIconInset - (captionHeight - g.TextAscent)
		      
		    End Select
		    
		    If mUseBevelButtonTextColor Then
		      g.forecolor = mTextColor
		    Elseif Self.Value Then
		      g.ForeColor = SemanticColors.selectedMenuItemTextColor
		    Else
		      g.ForeColor = SemanticColors.TextColor
		    End If
		    
		    g.DrawString caption, titleX + CaptionDelta, titleY
		    
		  End If
		  
		  g.AntiAlias = Tmp
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub DrawIcon(g as graphics)
		  Dim tmp As Boolean = g.AntiAlias
		  g.AntiAlias = True
		  
		  If Self.Icon <> Nil Then
		    
		    
		    Select Case IconAlignments(Self.IconAlign)
		      
		    Case IconAlignments.SysDirection
		      mIconLeft = kDefaultIconInset
		      mIconTop = (Self.Height / 2) - (icon.Height / 2)
		      
		    Case IconAlignments.Bottom
		      mIconLeft = (Me.width / 2) - (icon.width / 2)
		      mIconTop = Self.Height - icon.Height - kDefaultIconInset
		      
		    Case IconAlignments.BottomLeft
		      mIconLeft = kDefaultIconInset
		      mIconTop = Self.Height - icon.Height - kDefaultIconInset
		      
		    Case IconAlignments.BottomRight
		      mIconLeft = Me.width - kDefaultIconInset - icon.width
		      mIconTop = Self.Height - icon.Height - kDefaultIconInset
		      
		    Case IconAlignments.Center
		      mIconLeft = (Me.width / 2) - (icon.width / 2)
		      mIconTop = (Self.Height / 2) - (icon.Height / 2)
		      
		    Case IconAlignments.Left
		      mIconLeft = kDefaultIconInset
		      mIconTop = (Self.Height / 2) - (icon.Height / 2)
		      
		    Case IconAlignments.Right
		      mIconLeft = Me.width - kDefaultIconInset - icon.width
		      mIconTop = (Self.Height / 2) - (icon.Height / 2)
		      
		    Case IconAlignments.Top
		      mIconLeft = (Me.width / 2) - (icon.width / 2)
		      mIconTop = kDefaultIconInset
		      
		    Case IconAlignments.TopLeft
		      mIconLeft = kDefaultIconInset
		      mIconTop = kDefaultIconInset
		      
		    Case IconAlignments.TopRight
		      mIconLeft = Me.width - kDefaultIconInset - icon.width
		      mIconTop = kDefaultIconInset
		      
		    End Select
		    
		    g.DrawPicture Self.icon, mIconLeft, mIconTop
		    
		  End If
		  
		  g.AntiAlias = tmp
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub DrawMenuIndicator(g as graphics)
		  #If TargetWindows
		  #Else
		    If bevel = kDisclosureBevel Then // disclosure style
		      Return
		    End If
		  #EndIf
		  
		  Dim tmp As Boolean = g.AntiAlias
		  g.AntiAlias = True
		  
		  Select Case hasMenu
		    
		  Case kMenuNone
		    // simple since this is "no menu"
		    
		  Case kMenuNormal
		    // normal menu
		    
		    // drawn relative to the •                    
		    //   menu arrow left  |    menu arrow right
		    //                 \--•---/    << menu arrow top
		    //                  \       /
		    //                   \    /
		    //                    \  /
		    //     the "tip" is at menuArrowPointleft, menuArrowPointTop
		    //
		    
		    
		    Dim menuArrowTopOffset As Integer = 0 // offset from the top
		    Dim menuArrowLeftOffset As Integer = -3 // offset from the mid point to the left
		    Dim menuArrowRightOffset As Integer = 3 // offset from the mid pont to the right
		    Dim menuArrowPointTopOffset As Integer = 3 // offset DOWN from the top 
		    
		    Dim fs As New FigureShape
		    fs.Border = 100
		    fs.BorderWidth = 1
		    If mUseBevelButtonTextColor Then
		      fs.BorderColor = TextColor
		    Else
		      fs.BorderColor = SemanticColors.TextColor
		    End If
		    
		    fs.AddLine menuArrowLeftOffset, menuArrowTopOffset, 0, menuArrowPointTopOffset // the left side of the arrow
		    fs.AddLine 0, menuArrowPointTopOffset, menuArrowRightOffset, 0
		    fs.addline menuArrowRightOffset, 0, menuArrowLeftOffset, menuArrowTopOffset
		    
		    If mUseBevelButtonTextColor Then
		      fs.FillColor = TextColor
		    Else
		      fs.FillColor = SemanticColors.TextColor
		    End If
		    
		    // note this draws using the midpoint (g.width-10, g.height-8) and) as X Y and draws
		    // the arrow facing down
		    #If TargetWindows
		      g.DrawObject fs, g.width-10, g.height/2
		    #Else
		      g.DrawObject fs, g.width-10, g.height-8
		    #EndIf
		    
		  Case kMenuOnRight
		    // menu on right
		    // 
		    // drawn relative to the •                    
		    //    menuArrowLeftOffset   
		    //        |
		    //        |
		    //        |\-------------- menuArrowTopOffset
		    //        | \
		    //        |  \
		    //        •   +-------------- menuArrowPointTopOffset
		    //        |  /|
		    //        | / +- menuArrowPointleftOffset
		    //        |/
		    //         -------------- -menuArrowTopOffset
		    
		    Dim menuArrowTopOffset As Integer = -3 // offset from the top
		    Dim menuArrowLeftOffset As Integer = 0 // offset from the mid point to the left
		    Dim menuArrowPointTopOffset As Integer = 0 // offset DOWN from the top 
		    Dim menuArrowPointleftOffset As Integer = 3 // offset from the midpoint
		    
		    Dim fs As New FigureShape
		    fs.Border = 100
		    fs.BorderWidth = 1
		    If mUseBevelButtonTextColor Then
		      fs.BorderColor = TextColor
		    Else
		      fs.BorderColor = SemanticColors.TextColor
		      
		    End If
		    
		    fs.AddLine menuArrowLeftOffset, menuArrowTopOffset, menuArrowLeftOffset, -menuArrowTopOffset
		    fs.AddLine menuArrowLeftOffset, -menuArrowTopOffset, menuArrowPointleftOffset, menuArrowPointTopOffset
		    fs.AddLine menuArrowPointleftOffset, menuArrowPointTopOffset , menuArrowLeftOffset, menuArrowTopOffset
		    
		    If mUseBevelButtonTextColor Then
		      fs.FillColor = TextColor
		    Else
		      fs.FillColor = SemanticColors.TextColor
		    End If
		    
		    fs.fill = 100
		    
		    // note this draws using the midpoint (g.width-10, g.height-8) and) as X Y and draws
		    // the arrow facing eight
		    #If TargetWindows
		      g.DrawObject fs, g.width-10, g.height/2
		    #Else
		      g.DrawObject fs, g.width-10, g.height-8
		    #EndIf
		    
		  End Select
		  
		  g.AntiAlias = tmp
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub FigureMenuPopupLocation(byref menuLeft as Integer, byref menuTop as Integer)
		  If mHasMenu = 1 Then
		    menuLeft = Me.Left
		    menuTop = Me.top + Me.height
		  Else
		    menuLeft = Me.Left + Me.width
		    menuTop = Me.top
		  End If
		  
		  menuLeft = menuLeft + Self.TrueWindow.Left
		  menuTop = menuTop + Self.TrueWindow.Top
		  
		  // and now to walk up the containment hierarchy and get my global left and global top
		  Dim p As Control = self.Parent
		  While p <> Nil 
		    
		    If p IsA RectControl Then
		      menuLeft = menuLeft + RectControl(p).Left
		      menuTop = menuTop + RectControl(p).Top
		      
		      p = RectControl(p).Parent
		      
		    Else
		      p = Nil
		    End If
		    
		  Wend
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function lighten(c as color) As color
		  
		  Dim lighterColor As Color = HSV(c.hue, c.Saturation, min(1,c.Value+0.2), c.Alpha)
		  
		  Return lighterColor
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function List(row as integer) As string
		  If row < 0 Or row > mMenuTextRows.Ubound Then
		    Raise New OutOfBoundsException
		  End If
		  
		  
		  Return mMenuTextRows(row)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RaiseMenuError()
		  Dim err As New UnsupportedOperationException
		  err.Message = kMenuError
		  Raise err
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RemoveRow(row as integer)
		  If mMenu IsA Object Then
		    RaiseMenuError
		  End If
		  
		  If row < 0 Or row > mMenuTextRows.Ubound Then
		    Raise New OutOfBoundsException
		  End If
		  
		  mMenuTextRows.remove row
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetMenu(m As MenuItem)
		  If mMenuTextRows.Ubound <> -1 Then
		    RaiseMenuError
		  End If
		  
		  mMenu = m
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Action()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event KeyDown(Key As String) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event MenuAction(item as MenuItem)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event MouseDown(X As Integer, Y As Integer) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event MouseEnter()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event MouseExit()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event MouseUp(x as integer, y as integer) As boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Open()
	#tag EndHook


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mBackColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mBackColor = value
			  
			  me.invalidate
			End Set
		#tag EndSetter
		BackColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mBevel
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mBevel = value
			  
			  Me.invalidate
			End Set
		#tag EndSetter
		Bevel As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mBold
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mBold = value
			  
			  Me.invalidate
			End Set
		#tag EndSetter
		Bold As boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mButtonType
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mButtonType = value
			  
			  Me.invalidate
			End Set
		#tag EndSetter
		ButtonType As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mCaption
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mCaption = value
			  
			  Me.invalidate
			End Set
		#tag EndSetter
		Caption As string
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mCaptionAlign
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mCaptionAlign = value
			  
			  Me.invalidate
			End Set
		#tag EndSetter
		CaptionAlign As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mCaptionDelta
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mCaptionDelta = value
			  
			  Me.invalidate
			End Set
		#tag EndSetter
		CaptionDelta As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mCaptionPlacement
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mCaptionPlacement = value
			  
			  Me.invalidate
			End Set
		#tag EndSetter
		CaptionPlacement As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mHasBackColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mHasBackColor = value
			  
			  Me.invalidate
			End Set
		#tag EndSetter
		HasBackColor As boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mHasMenu
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mHasMenu = value
			  
			  Me.invalidate
			End Set
		#tag EndSetter
		HasMenu As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mIcon
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mIcon = value
			  
			  Me.invalidate
			End Set
		#tag EndSetter
		Icon As Picture
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mIconAlign
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mIconAlign = value
			  
			  Me.invalidate
			End Set
		#tag EndSetter
		IconAlign As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mIconDX
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mIconDX = value
			  
			  Me.invalidate
			End Set
		#tag EndSetter
		IconDX As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mIconDY
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mIconDY = value
			  
			  Me.invalidate
			End Set
		#tag EndSetter
		IconDY As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mItalic
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mItalic = value
			  
			  Me.invalidate
			End Set
		#tag EndSetter
		Italic As boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mBackColor As Color
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBevel As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBold As boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mButtonType As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCaption As string
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCaptionAlign As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCaptionDelta As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCaptionPlacement As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mMenuValue
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mMenuValue = value
			  
			  Me.invalidate
			End Set
		#tag EndSetter
		MenuValue As integer
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mHasBackColor As boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHasMenu As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIcon As Picture
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIconAlign As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIconDX As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIconDY As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIconLeft As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIconTop As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIsMenuShowing As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mItalic As boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMenu As MenuItem
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMenuTextRows() As string
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMenuValue As integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mMouseInside As boolean = false
	#tag EndProperty

	#tag Property, Flags = &h0
		mMouseIsDown As boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRaiseActionEvent As boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTextColor As Color
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTextFont As string
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTextSize As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTextUnit As FontUnits
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mUnderline As boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mUseBevelButtonTextColor As boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mValue As boolean
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mTextColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mTextColor = value
			  
			  Me.invalidate
			End Set
		#tag EndSetter
		TextColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mTextFont
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mTextFont = value
			  
			  Me.invalidate
			End Set
		#tag EndSetter
		TextFont As string
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mTextSize
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mTextSize = value
			  
			  Me.invalidate
			End Set
		#tag EndSetter
		TextSize As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mTextUnit
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mTextUnit = value
			  
			  Me.invalidate
			End Set
		#tag EndSetter
		TextUnit As FontUnits
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mUnderline
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mUnderline = value
			  
			  Me.invalidate
			End Set
		#tag EndSetter
		Underline As boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mUseBevelButtonTextColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mUseBevelButtonTextColor = value
			  
			End Set
		#tag EndSetter
		UseBevelButtonTextColor As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mValue
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mValue = value
			  
			  Me.invalidate
			End Set
		#tag EndSetter
		Value As boolean
	#tag EndComputedProperty


	#tag Constant, Name = archeight, Type = Double, Dynamic = False, Default = \"9", Scope = Private
	#tag EndConstant

	#tag Constant, Name = arcWidth, Type = Double, Dynamic = False, Default = \"9", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kButtonTypeButton, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kButtonTypeSticky, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kButtonTypeToggle, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kCaptionAlignCenter, Type = Double, Dynamic = False, Default = \"3", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kCaptionAlignFlushLeft, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kCaptionAlignFlushRight, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kCaptionAlignSysDirection, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kCaptionPlacementAboveGraphic, Type = Double, Dynamic = False, Default = \"5", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kCaptionPlacementBelowGraphic, Type = Double, Dynamic = False, Default = \"4", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kCaptionPlacementLeftOfGraphic, Type = Double, Dynamic = False, Default = \"3", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kCaptionPlacementNormally, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kCaptionPlacementRightOfGraphic, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kCaptionPlacementSysDirection, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kDefaultIconInset, Type = Double, Dynamic = False, Default = \"2", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDisclosureBevel, Type = Double, Dynamic = False, Default = \"7", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kLargeBevel, Type = Double, Dynamic = False, Default = \"2\n", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kLargeRoundBevel, Type = Double, Dynamic = False, Default = \"6", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kMenuError, Type = String, Dynamic = False, Default = \"You may use SetMenu or the menu functions\x2C but not both", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMenuNone, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kMenuNormal, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kMenuOnRight, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kNoBevel, Type = Double, Dynamic = False, Default = \"4\n", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kNormalBevel, Type = Double, Dynamic = False, Default = \"1\n", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kRoundBevel, Type = Double, Dynamic = False, Default = \"5\n", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kRoundedBevel, Type = Double, Dynamic = False, Default = \"3\n", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSmallBevel, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant


	#tag Enum, Name = IconAlignments, Flags = &h0
		SysDirection
		  Center
		  Left
		  Right
		  Top
		  Bottom
		  TopLeft
		  BottomLeft
		  TopRight
		BottomRight
	#tag EndEnum


	#tag ViewBehavior
		#tag ViewProperty
			Name="AutoDeactivate"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HelpTag"
			Visible=true
			Group="Appearance"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="UseFocusRing"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AcceptFocus"
			Visible=true
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AcceptTabs"
			Visible=true
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="EraseBackground"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
			EditorType="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			Type="Integer"
			EditorType="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
			EditorType="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Visible=true
			Group="Position"
			InitialValue="60"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Height"
			Visible=true
			Group="Position"
			InitialValue="22"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockLeft"
			Visible=true
			Group="Position"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockTop"
			Visible=true
			Group="Position"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockRight"
			Visible=true
			Group="Position"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockBottom"
			Visible=true
			Group="Position"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabIndex"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabStop"
			Visible=true
			Group="Position"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Transparent"
			Visible=true
			Group="Appearance"
			InitialValue="False"
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Enabled"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Bold"
			Visible=true
			Group="Font"
			Type="boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Italic"
			Visible=true
			Group="Font"
			Type="boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TextFont"
			Visible=true
			Group="Font"
			InitialValue="System"
			Type="string"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TextSize"
			Visible=true
			Group="Font"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TextUnit"
			Visible=true
			Group="Font"
			InitialValue="2"
			Type="FontUnits"
			EditorType="Enum"
			#tag EnumValues
				"0 - Default"
				"1 - Pixel"
				"2 - Point"
				"3 - Inches"
				"4 - Millimeter"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="Underline"
			Visible=true
			Group="Font"
			Type="boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Caption"
			Visible=true
			Group="Behavior"
			InitialValue="Untitled"
			Type="string"
			EditorType="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="CaptionAlign"
			Visible=true
			Group="Behavior"
			InitialValue="3"
			Type="Integer"
			EditorType="Enum"
			#tag EnumValues
				"0 - Flush left"
				"1 - Flush right"
				"2 - Sys direction"
				"3 - Center"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="CaptionPlacement"
			Visible=true
			Group="Behavior"
			InitialValue="1"
			Type="Integer"
			EditorType="Enum"
			#tag EnumValues
				"0 - Sys Direction"
				"1 - Normally"
				"2 - Right of graphic"
				"3 - Left of graphic"
				"4 - Below graphic"
				"5 - Above graphic"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="CaptionDelta"
			Visible=true
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Icon"
			Visible=true
			Group="Behavior"
			Type="Picture"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IconAlign"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType="Enum"
			#tag EnumValues
				"0 - Sys Direction"
				"1 - Center"
				"2 - Left"
				"3 - Right"
				"4 - Top"
				"5 - Bottom"
				"6 - Top left"
				"7 - Bottom left"
				"8 - Top right"
				"9 - Bottom right"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="IconDX"
			Visible=true
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IconDY"
			Visible=true
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Bevel"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType="Enum"
			#tag EnumValues
				"0 - Small Bevel"
				"1 - Normal Bevel"
				"2 - Large Bevel"
				"3 - Rounded Bevel"
				"4 - No Bevel"
				"5 - Round"
				"6 - Large Round"
				"7 - Disclosure"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="HasMenu"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType="Enum"
			#tag EnumValues
				"0 - No menu"
				"1 - Normal menu"
				"2 - Menu on right"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="HasBackColor"
			Visible=true
			Group="Behavior"
			Type="boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="BackColor"
			Visible=true
			Group="Behavior"
			InitialValue="&c000000"
			Type="Color"
		#tag EndViewProperty
		#tag ViewProperty
			Name="UseBevelButtonTextColor"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TextColor"
			Visible=true
			Group="Behavior"
			InitialValue="&c000000"
			Type="Color"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ButtonType"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType="Enum"
			#tag EnumValues
				"0 - Button"
				"1 - Toggle"
				"2 - Sticky"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="Value"
			Visible=true
			Group="Behavior"
			Type="boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MenuValue"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="mMouseIsDown"
			Group="Behavior"
			Type="boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabPanelIndex"
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Backdrop"
			Group="Appearance"
			Type="Picture"
			EditorType="Picture"
		#tag EndViewProperty
		#tag ViewProperty
			Name="DoubleBuffer"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="InitialParent"
			Type="String"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
