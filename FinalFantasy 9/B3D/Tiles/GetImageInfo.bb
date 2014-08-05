; ImageInfo v1.3



; v1.3  ( доработано: MixailV aka Monster^Sage [monster-sage@mail.ru] )
; - устранен баг, который проявлялся при загрузке JPEG картинок, содержащих
;   в себе метаданные (некорректно определялись размеры таких картинок).

; v1.2  ( доработано: MixailV aka Monster^Sage [monster-sage@mail.ru] )
; - добавлена поддержка DDS файлов



;This unit is the down-striped (supports only BMP, PNG,TGA, JPG files) and modified BlitzBasic 
;version of the original file 'DCImageInfo.pas' of David Crowell

;-copyrights v1.1 ---------------------------------------------------------------------
; TDCImageInfo, © 2001 David Crowell, www.davidcrowell.com
; Description:
; TDCImageInfo returns image Type, dimensions, And Color depth from GIF, JPEG, PNG, BMP, PCX, And TIFF files.
; This is a port of my CImageInfo class which was created with Visual Basic.
;--------------------------------------------------------------------------------------------



;Image type constants
Const imgtype_Unknown = 0
Const imgtype_BMP = 1
Const imgtype_PNG = 2
Const imgtype_JPEG = 3
Const imgtype_TGA = 4
Const imgtype_DDS = 5

;Globals

Global ImageInfo_Type = imgtype_Unknown
Global ImageInfo_Width
Global ImageInfo_Height
Global ImageInfo_Depth

;User functions

Function ImageInfo_ReadFile(FileName$)  
	If FileType(FileName)<>1 Return	
	
	;Init  
	ImageInfo_Type = imgtype_Unknown
	ImageInfo_Width = 0
	ImageInfo_Height = 0
	ImageInfo_Depth = 0
  
	Buffer = CreateBank(4)  
	ImageFileSize = FileSize(FileName)
	
	If ImageFileSize<3 Then 
		FreeBank(Buffer)
		Return
	EndIf
	
	ImageFile = OpenFile(FileName)  
  
	;Start comparsion
	ReadBytes(Buffer, ImageFile, 0, 4)
  
	;Check PNG
	If (PeekByte(Buffer,0) = 137) And (PeekByte(Buffer,1) = 80) And (PeekByte(Buffer,2) = 78) Then 
		ImageOk = ImageInfo_ReadPNG(ImageFile, ImageFileSize)		
	EndIf
  
	;Check BMP
	If (ImageOk = False) And (PeekByte(Buffer,0) = 66) And (PeekByte(Buffer,1) = 77) Then
		ImageOk = ImageInfo_ReadBMP(ImageFile, ImageFileSize)				
	EndIf

	;Check DDS
	If (ImageOk = False) And (PeekByte(Buffer,0) = 68) And (PeekByte(Buffer,1) = 68) And (PeekByte(Buffer,2) = 83)  And (PeekByte(Buffer,3) = 32) Then
		ImageOk = ImageInfo_ReadDDS(ImageFile, ImageFileSize)				
	EndIf
	
	;Check TGA
	If ImageOk = False Then ImageOk = ImageInfo_ReadTGA(ImageFile, ImageFileSize)
           
	;Check JPEG
	If ImageOk = False Then ImageOk = ImageInfo_ReadJPG(Buffer, ImageFile, ImageFileSize)
		

	CloseFile(ImageFile)
	FreeBank(Buffer)
	
	Return ImageOk
End Function 

;Internal functions

Function ImageInfo_ReadBMP(ImageFile, ImageFileSize)
	If ImageFileSize<29 Return 
	
	ImageInfo_Type = imgtype_BMP
	
	SeekFile(ImageFile, 18)
	ImageInfo_Width = ReadShort(ImageFile)
	
	SeekFile(ImageFile, 22)
	ImageInfo_Height = ReadShort(ImageFile)

	SeekFile(ImageFile, 28)
	ImageInfo_Depth = ReadByte(ImageFile)
	
	Return True
End Function

Function ImageInfo_ReadDDS(ImageFile, ImageFileSize)
	If ImageFileSize<129 Return 
	
	ImageInfo_Type = imgtype_DDS
	
	SeekFile(ImageFile, 12)
	ImageInfo_Height = ReadInt(ImageFile)

	;SeekFile(ImageFile, 16)
	ImageInfo_Width = ReadInt(ImageFile)

	ReadInt(ImageFile)	;20 Pitch

	;SeekFile(ImageFile, 24)
	ImageInfo_Depth = ReadInt(ImageFile)
	
	Return True
End Function 

Function ImageInfo_ReadPNG(ImageFile, ImageFileSize)
	If ImageFileSize<25 Return
	
	Local b
	Local c	
	
	ImageInfo_Type = imgtype_PNG
	SeekFile(ImageFile, 24)  

	b = ReadByte(ImageFile)
	c = ReadByte(ImageFile)

	;Color depth
	Select c 
		Case 0 
			ImageInfo_Depth = b; greyscale
		Case 2 
			ImageInfo_Depth = b * 3; RGB
		Case 3 
			ImageInfo_Depth = 8; Palette based
		Case 4 
			ImageInfo_Depth = b * 2; greyscale with alpha
		Case 6 
			ImageInfo_Depth = b * 4; RGB with alpha
		Default
			ImageInfo_Type = imgtype_Unknown
	End Select 
    
	If ImageInfo_Type = imgtype_PNG Then 
		seeked = SeekFile(ImageFile, 16)		
		ImageInfo_Width = Swap32(ReadInt(ImageFile))
		ImageInfo_Height = Swap32(ReadInt(ImageFile))				
		Return True
	EndIf	
End Function

Function ImageInfo_ReadJPG(Buffer, ImageFile, ImageFileSize)
	Local i
	Local Pos = 0
	Local BType
	
	;find beginning of JPEG stream
	IsError = True
	While Pos<=ImageFileSize-4
		SeekFile(ImageFile, Pos)
		For i=0 To 3: PokeByte Buffer, i, ReadByte(ImageFile): Next
		If (PeekByte(Buffer,0) = $FF) And (PeekByte(Buffer,1) = $D8) And (PeekByte(Buffer,2) = $FF) And (PeekByte(Buffer,3) = $E0) Then
			IsError = False
			Exit
		EndIf	
		Pos = Pos + 1
	Wend
	If IsError Return
	Pos = FilePos(ImageFile) + Swap16(ReadShort(ImageFile))

	;loop through Each marker Until we find the C0 marker (Or C1 Or C2) which
	;has the image information
	IsError = True
	SeekFile(ImageFile, Pos)
	While Not Eof(ImageFile)
		If ReadByte(ImageFile) = $FF
			BType = ReadByte(ImageFile)
			Pos = FilePos(ImageFile) + Swap16(ReadShort(ImageFile))

			; if the type is from SOF0 to SOF3
			If (BType >= $C0) And (BType <= $C3)
				i = ReadByte(ImageFile)
				ImageInfo_Height = Swap16(ReadShort(ImageFile))
				ImageInfo_Width = Swap16(ReadShort(ImageFile))
				ImageInfo_Depth = ReadByte(ImageFile) * 8
				ImageInfo_Type = imgtype_JPEG
				 IsError = False
				Exit
			EndIf
			
			; Goto next marker
			SeekFile(ImageFile, Pos)
		EndIf		
	Wend
		
	Return 1-IsError
End Function 

Function ImageInfo_ReadTGA(ImageFile, ImageFileSize)
	If ImageFileSize<24+12 Return 

	SeekFile(ImageFile, 0)
	If ReadByte(ImageFile)=0 And ReadByte(ImageFile)=0 And ReadByte(ImageFile)=2
		ImageInfo_Type = imgtype_TGA
	Else
		Return
	EndIf
	
	SeekFile(ImageFile, 12)
	ImageInfo_Width = ReadShort(ImageFile)
	ImageInfo_Height = ReadShort(ImageFile)
	ImageInfo_Depth = ReadShort(ImageFile)
	
	Return True	
End Function

Function Swap16%(Value%)
	Local b1 = Value And 255
	Local b2 = (Value Shr 8) And 255
	Return b1 Shl 8 Or b2
End Function 

Function Swap32%(Value%)  
	Local b1 = Value And 255;
	Local b2 = (Value Shr 8) And 255;
	Local b3 = (Value Shr 16) And 255;
	Local b4 = (Value Shr 24) And 255;

	b1 = b1 Shl 24
	b2 = b2 Shl 16
	b3 = b3 Shl 8

	Return b1 Or b2 Or b3 Or b4
End Function 