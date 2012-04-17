;»нклюд библиотеки FastImage дл€ Ѕлиц3ƒ (верси€ 1.98 - 1.99)
;(c) 2006-2008 либа сделана MixailV aka Monster^Sage [monster-sage@mail.ru]
;ѕри использовании библиотеки в своих работах об€зательно упоминание автора MixailV.
;«апрещено размещать и встраивать FastImage.dll внутри других DLL и им подобных.
;Ќе желательно встраивать FastImage.dll в EXE файлы.



;список доступных функций смотрите в хелпе и декларационном файле FastImage.decls



; подключаем группу функций дл€ определени€ оригинальных размеров картинок
Include "GetImageInfo.bb"



;данные флаги - константы об€зательно пригод€тс€
;подробнее про них читайте в хелпе

;CreateImageEx Flags (при создании картинки)
Const FI_AUTOFLAGS = -1
Const FI_NONE = 0
Const FI_MIDHANDLE = 1
Const FI_FILTEREDIMAGE = 2
Const FI_FILTERED = 2

;SetBlend Flags (при использовании бленда (смешивани€)
Const FI_SOLIDBLEND = 0
Const FI_ALPHABLEND = 1
Const FI_LIGHTBLEND = 2
Const FI_SHADEBLEND = 3
Const FI_MASKBLEND = 4
Const FI_MASKBLEND2 = 5
Const FI_INVALPHABLEND = 6

;ImageFonts Flags
Const FI_SMOOTHFONT=1

;DrawImagePart Wrap Flags
Const FI_NOWRAP = 0
Const FI_WRAPU = 1
Const FI_MIRRORU = 2
Const FI_WRAPV = 4
Const FI_MORRORV = 8
Const FI_WRAPUV = 5
Const FI_MIRRORUV = 10

;DrawPoly consts
Const FI_POINTLIST     = 1
Const FI_LINELIST      = 2
Const FI_LINESTRIP     = 3
Const FI_TRIANGLELIST  = 4
Const FI_TRIANGLESTRIP = 5
Const FI_TRIANGLEFAN   = 6 

;	FI_POINTLIST 
;		Renders the vertices as a collection of isolated points. 
;	FI_LINELIST 
;		Renders the vertices as a list of isolated straight line segments. Calls using this primitive type fail If the count is less than 2 or is odd. 
;	FI_LINESTRIP 
;		Renders the vertices as a single polyline. Calls using this primitive type fail If the count is less than 2. 
;	FI_TRIANGLELIST 
;		Renders the specified vertices as a sequence of isolated triangles. Each group of three vertices defines a separate triangle.
;		Calls using this primitive type fail If the count is less than 3 or not evenly divisible by 3. 
;	FI_TRIANGLESTRIP 
;		Renders the vertices as a triangle strip. Calls using this primitive type fail If the count is less than 3.
;	FI_TRIANGLEFAN 
;		Renders the vertices as a triangle fan. Calls using this primitive type fail If the count is less than 3. 

Const FI_COLOROVERLAY = 1



;набор всех свойств библиотеки
Type FI_PropertyType
	Field Blend%
	Field Alpha#, Red%, Green%, Blue%
	Field ColorVertex0%, ColorVertex1%, ColorVertex2%, ColorVertex3%                                 	
	Field Rotation#, ScaleX#, ScaleY#
	Field MatrixXX#, MatrixXY#, MatrixYX#, MatrixYY#
	Field HandleX%, HandleY%
	Field OriginX%, OriginY%
	Field AutoHandle%, AutoFlags%
	Field LineWidth#
	Field ViewportX%, ViewportY%, ViewportWidth%, ViewportHeight%
	Field MipLevel%
	Field ProjScaleX#, ProjScaleY#, ProjRotation#
	Field ProjOriginX%, ProjOriginY%
	Field ProjHandleX%, ProjHandleY%
	Field Reserved0%
	Field Reserved1%
End Type

;используем глобальную переменную FI_Property дл€ получени€ конкретного свойства из набора
;в программе получать весь набор свойств  нужно так:  GetProperty FI_Property
Global FI_Property.FI_PropertyType = New FI_PropertyType



;набор свойств любой картинки, созданной библиотекой (командой CreateImageEx)
Type FI_ImagePropertyType
	Field HandleX%
	Field HandleY%
	Field Width%
	Field Height%
	Field Frames%
	Field Flags%
	Field Texture%
	Field Reserved0%
	Field Reserved1%
End Type

;используем глобальную переменную FI_ImageProperty дл€ получени€ конкретного свойства
;из набора свойств любой картинки, созданной библиотекой (командой CreateImageEx)
;в программе получать весь набор свойств  нужно так:  GetImageProperty your_image, FI_ImageProperty
Global FI_ImageProperty.FI_ImagePropertyType = New FI_ImagePropertyType



Type FI_FontPropertyType
	Field Width%
	Field Height%
	Field FirstChar%
	Field Kerning%
	Field Image%
	Field FrameWidth%
	Field FrameHeight%
	Field FrameCount%
	Field Chars[256]
End Type
Global FI_FontProperty.FI_FontPropertyType = New FI_FontPropertyType




;тип дл€ получени€ всей информации о положении точки на примитиве (команда TestPoint)
Type FI_TestType
	Field Result%
	Field ProjectedX%, ProjectedY%
	Field RectX%, RectY%
	Field RectU#, RectV#
	Field TextureX%, TextureY%
	Field Texture%
	Field Frame%
	Field Reserved1%
End Type
Global FI_Test.FI_TestType = New FI_TestType




;функци€ универсального "ручного" бленда (смешивани€ цветов)
;создана дл€ начинающих, еще не освоивших DirectX7
;значени€ src и dest должны быть в пределах от 1 до 10
Function SetCustomBlend(src%, dest%)
	SetCustomState 15,0				;DX7  SetRenderState ( D3DRENDERSTATE_AlphaTestEnable, False )
	SetCustomState 27,1				;DX7  SetRenderState ( D3DRENDERSTATE_AlphaBlendEnable, True )
	SetCustomState 19,src			;DX7  SetRenderState ( D3DRENDERSTATE_SrcBlend, src )
	SetCustomState 20,dest			;DX7  SetRenderState ( D3DRENDERSTATE_DestBlend, dest )
End Function







;вспомогательные функции, позвол€ющие не задавать каждый раз параметры с дефолтными значени€ми
Function CreateImageEx% (texure%, width%, height%, imageFlags%=FI_AUTOFLAGS)
	Return CreateImageEx_(texure, width, height, imageFlags)
End Function

Function LoadImageEx% (fileName$, textureFlags%=0, imageFlags%=FI_AUTOFLAGS)
	If ImageInfo_ReadFile (fileName) Then
		Return CreateImageEx_( LoadTexture (fileName, textureFlags), ImageInfo_Width, ImageInfo_Height, imageFlags)
	Else
		Return 0
	EndIf
End Function

Function LoadAnimImageEx% ( fileName$, textureFlags%, frameWidth%, frameHeight%, firstFrame%, frameCount%, imageFlags%=FI_AUTOFLAGS )
	textureFlags = (textureFlags And $3F) Or $9
	Return CreateImageEx_( LoadAnimTexture (fileName, textureFlags, frameWidth, frameHeight, firstFrame, frameCount), frameWidth, frameHeight, imageFlags)
End Function

Function DrawImageEx% (image%, x%, y%, frame%=0)
	Return DrawImageEx_(image, x, y, frame)
End Function

Function DrawImageRectEx% (image%, x%, y%, width%, height%, frame%=0)
	Return DrawImageRectEx_(image, x, y, width, height, frame)
End Function

Function DrawImagePart% (image%, x%, y%, width%, height%, partX%=0, partY%=0, partWidth%=0, partHeight%=0, frame%=0, wrap%=FI_NOWRAP)
	Return DrawImagePart_(image, x, y, width, height, partX, partY, partWidth, partHeight, frame, wrap)
End Function

Function DrawPoly% (x%, y%, bank%, image%=0, frame%=0, color%=FI_NONE)
	Return DrawPoly_(x, y, bank, image, frame, color)
End Function

Function DrawRect% (x%, y%, width%, height%, fill%=1)
	DrawRect_ x, y, width, height, fill
End Function

Function DrawRectSimple% (x%, y%, width%, height%, fill%=1)
	DrawRectSimple_ x, y, width, height, fill
End Function

Function LoadImageFont% (filename$, flags%=FI_SMOOTHFONT)
	Local f, i, l$, r$, AnimTexture$, AnimTextureFlags, Texture

	filename=Replace (filename,"/", "\")
	f = ReadFile(filename)
	If f=0 Then Return 0

	FI_FontProperty\Width=0
	FI_FontProperty\Height=0
	FI_FontProperty\FirstChar=0
	FI_FontProperty\Kerning=0
	FI_FontProperty\Image=0
	FI_FontProperty\FrameWidth=0
	FI_FontProperty\FrameHeight=0
	FI_FontProperty\FrameCount=0
	For i=0 To 255
		FI_FontProperty\Chars[i]=0
	Next
	AnimTextureFlags=4

	While Not Eof(f) 
		l=Trim(ReadLine(f))
		i=Instr(l,"=",1)
		If Len(l)>0 And Left(l,1)<>";" And i>0 Then
			r=Trim(Right(l,Len(l)-i))
			l=Upper(Trim(Left(l,i-1)))
			Select l
				Case "ANIMTEXTURE"
					AnimTexture=r
				Case "ANIMTEXTUREFLAGS"
					AnimTextureFlags=Int(r)
				Case "FRAMEWIDTH"
					FI_FontProperty\FrameWidth=Int(r)
				Case "FRAMEHEIGHT"
					FI_FontProperty\FrameHeight=Int(r)
				Case "FRAMECOUNT"
					FI_FontProperty\FrameCount=Int(r)
				Case "WIDTH"
					FI_FontProperty\Width=Int(r)
				Case "HEIGHT"
					FI_FontProperty\Height=Int(r)
				Case "FIRSTCHAR"
					FI_FontProperty\FirstChar=Int(r)
				Case "KERNING"
					FI_FontProperty\Kerning=Int(r)				
				Default
					If Int(l)>=0 And Int(l)<=255 Then
						FI_FontProperty\Chars[Int(l)]=Int(r)
					EndIf
			End Select
		EndIf
	Wend
	CloseFile f

	If Len(AnimTexture)>0 And FI_FontProperty\FrameWidth>0 And FI_FontProperty\FrameHeight>0 And FI_FontProperty\FrameCount>0 Then
		f=1
		Repeat
			i=Instr(filename,"\",f)
			If i<>0 Then f=i+1
		Until i=0
		If flags=FI_SMOOTHFONT Then   :   flags=FI_FILTEREDIMAGE   :   Else   :   flags=FI_NONE   :   EndIf
		FI_FontProperty\Image = LoadImageEx ( Left(filename,f-1)+AnimTexture, (AnimTextureFlags And $6) Or $39, flags)
		Return CreateImageFont( FI_FontProperty )
	EndIf
	Return 0
End Function

Function StringWidthEx% (txt$, maxWidth%=10000)
	Return StringWidthEx_(txt, maxWidth)
End Function

Function DrawText% (txt$, x%, y%, centerX%=0, centerY%=0, maxWidth%=10000)
	Return DrawText_(txt, x, y, centerX, centerY, maxWidth)
End Function

Function DrawTextRect% (txt$, x%, y%, w%, h%, centerX%=0, centerY%=0, lineSpacing%=0)
	Return DrawTextRect_(txt, x, y, w, h, centerX, centerY, lineSpacing)
End Function



Function InitDraw% (def=0)
	Return InitDraw_ ( SystemProperty("Direct3DDevice7"), SystemProperty("DirectDraw7") )
End Function

Function GetProperty% ()
	Return GetProperty_ (FI_Property)
End Function

Function GetImageProperty% (image%)
	Return GetImageProperty_ (image, FI_ImageProperty)
End Function

Function GetFontProperty% (font%)
	Return GetFontProperty_ (font, FI_FontProperty)
End Function



Function TestRect% (xPoint%, yPoint%, xRect%, yRect%, WidthRect%, HeightRect%, Loc%=0)
	Return TestRect_ (xPoint, yPoint, xRect, yRect, WidthRect, HeightRect, Loc, FI_Test, 1)
End Function

Function TestOval% (xPoint%, yPoint%, xOval%, yOval%, WidthOval%, HeightOval%, Loc%=0)
	Return TestOval_ (xPoint, yPoint, xOval, yOval, WidthOval, HeightOval, Loc, FI_Test, 1)
End Function

Function TestImage% (xPoint%, yPoint%, xImage%, yImage%, Image%, alphaLevel%=0, Frame%=0, Loc%=0)
	If TestImage_ (xPoint, yPoint, xImage, yImage, Image, Loc, FI_Test, 1) And alphaLevel>0 And FI_Test\Texture<>0 Then
		If ( ReadPixel( FI_Test\TextureX, FI_Test\TextureY, TextureBuffer(FI_Test\Texture,Frame) ) Shr 24 ) < alphaLevel Then FI_Test\Result = 0
	EndIf
	Return FI_Test\Result
End Function

Function TestRendered% (xPoint%, yPoint%, alphaLevel%=0, Loc%=0)
	If TestRendered_ (xPoint, yPoint, Loc, FI_Test, 1) And alphaLevel>0 And FI_Test\Texture<>0 Then
		If ( ReadPixel( FI_Test\TextureX, FI_Test\TextureY, TextureBuffer(FI_Test\Texture,FI_Test\Frame) ) Shr 24 ) < alphaLevel Then FI_Test\Result = 0
	EndIf
	Return FI_Test\Result
End Function

Function FreeImageEx% (image%, freeTexture%=0)
	If freeTexture<>0 And GetImageProperty(image)<>0 And FI_ImageProperty\Texture<>0 Then FreeTexture FI_ImageProperty\Texture
	FreeImageEx_ image
End Function

Function FreeImageFont% (font%)
	If GetFontProperty(font)<>0 And FI_FontProperty\Image<>0 Then
		If GetImageProperty(FI_FontProperty\Image)<>0 And FI_ImageProperty\Texture<>0 Then FreeTexture FI_ImageProperty\Texture
	Endif
	FreeImageFont_ font
End Function