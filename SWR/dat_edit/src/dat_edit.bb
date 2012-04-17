Include "FastImage.bb"

Graphics3D 640,480,32,2
;SetBuffer BackBuffer()

InitDraw

Dialog(True,"dat","*.dat|*.dat")

Global fil$=GetFileName()

Global drr=OpenFile (fil)


ReadInt(drr)

Global num%=ReadInt(drr)




Type cart
	Field id%
	Field img%
	Field name$
	Field ofs%
	Field L%,T%,R%,B%
End Type

For i=1 To num
mya$=readtrustring(drr)
ofs%= FilePos(drr)
tmp11%=ReadInt(drr)
tmp12%=ReadInt(drr)
tmp13%=ReadInt(drr)
tmp14%=ReadInt(drr)
mya=Left(mya,Instr(mya,".",1)-1)

	bc.cart=New cart
	bc\img=0
	bc\ofs=ofs
	If FileType(mya+".png")=1
	bc\img=LoadImageEx(mya+".png",2,2)
	EndIf
	bc\name=mya+".png"
	bc\id=i-1
	bc\L=tmp11
	bc\T=tmp12
	bc\R=tmp13
	bc\B=tmp14


	
Next


Type scr
	Field x%,y%,id%,iid%,iiiid%
	Field ofs%,unk1%,unk2%
	
End Type

num=ReadInt(drr)

For i=1 To num
	br.scr=New scr
	br\ofs=FilePos(drr)
	br\iid=ReadInt(drr)
	br\unk1=ReadByte(drr)
	
If  br\unk1=0 Then
	br\id=ReadInt(drr)
	br\x=ReadInt(drr)
	br\y=ReadInt(drr)
	br\unk2=ReadInt(drr)
	br\iiiid=i
Else If br\unk1=1 Then
	br\id=-1
	br\x=ReadInt(drr)
	br\y=ReadInt(drr)
	br\unk2=0
	br\iiiid=i
Else If (br\unk1>=2) And (br\unk1<=5) Then
;RuntimeError (br\unk1 + "  "+Hex(br\ofs))
	br\id=ReadInt(drr)
	br\unk2=ReadInt(drr)
	br\x=ReadInt(drr)
	br\y=ReadInt(drr)
	br\iiiid=i
Else If br\unk1=6 Then
;RuntimeError (br\unk1 + "  "+Hex(br\ofs))
	ReadInt(drr)
	ReadInt(drr)
	ReadInt(drr)
	ReadInt(drr)
	ReadInt(drr)
	ReadInt(drr)
	ReadInt(drr)
	ReadInt(drr)
	ReadInt(drr)
	br\iiiid=i
EndIf

Next


vibr=1

lxx=-1
lyy=-1

While Not KeyDown(1)
	Cls
	
	If Not(KeyDown(42)) Then
		If KeyHit(15) Then vibr=vibr+1
		If vibr>num Then vibr=1
	Else
		If KeyHit(15) Then vibr=vibr-1
		If vibr<1 Then vibr=num
	EndIf		

	
	StartDraw

	
	For br.scr=Each scr

		If br\unk1=0 Then
		For bc.cart=Each cart
		
		If bc\id=br\id Then
		SetBlend  FI_ALPHABLEND
		SetAlpha 0.5

		If bc\img<>0 Then DrawImageEx bc\img,br\x,br\y

		
		If vibr=br\iiiid Then
        SetAlpha 1.0		

		If bc\img<>0 Then DrawImageEx bc\img,br\x,br\y
		
		If KeyHit(200) Then br\y=br\y-1
		If KeyHit(208) Then br\y=br\y+1
		If KeyHit(203) Then br\x=br\x-1
		If KeyHit(205) Then br\x=br\x+1
		
		If KeyHit(72) Then bc\b=bc\b-1
		If KeyHit(76) Then bc\b=bc\b+1
		If KeyHit(75) Then bc\r=bc\r-1
		If KeyHit(77) Then bc\r=bc\r+1
		
		If KeyHit(199) Then bc\t=bc\t-1
		If KeyHit(207) Then bc\t=bc\t+1
		If KeyHit(211) Then bc\l=bc\l-1
		If KeyHit(209) Then bc\l=bc\l+1
		
		;GetImageProperty bc\img
		;SetAlpha 1.0
		;SetColor 255,0,0
		;SetLineWidth(4)
		;DrawRectSimple br\x,br\y,FI_ImageProperty\width,FI_ImageProperty\height,0
		Color 255,0,0
		Rect br\x+bc\L,br\y+bc\T,bc\R,bc\B,0
		DrawText bc\name,10,10
		Text br\x+bc\L,br\y+bc\T,bc\name
		Color 255,255,255
		SetColor 255,255,255
		EndIf
		
			Exit
		EndIf
		
		Next
		EndIf
		
		
		If br\unk1=1 Then
		
		

		
		SetAlpha 1.0
		SetColor 255,0,255
				DrawLine br\x-5,br\y,br\x+5,br\y
				DrawLine br\x,br\y-5,br\x,br\y+5
		SetColor 255,255,255
			If vibr=br\iiiid Then
					If KeyHit(200) Then br\y=br\y-1
					If KeyHit(208) Then br\y=br\y+1
					If KeyHit(203) Then br\x=br\x-1
					If KeyHit(205) Then br\x=br\x+1
				Color 0,0,255
				Line br\x-5,br\y,br\x+5,br\y
				Line br\x,br\y-5,br\x,br\y+5
				Color 255,255,255				
			EndIf
		EndIf
	
		;Color 0,0,255
		;Rect br\x,br\y,2,2
		
	Next
	

	
	EndDraw 
	
	Color 0,127,127
	Line lxx,0,lxx,480
	Line 0,lyy,640,lyy
	
	If Not(KeyDown(42)) Then 
		If KeyHit(17) Then lyy=lyy-1
		If KeyHit(31) Then lyy=lyy+1
		If KeyHit(30) Then lxx=lxx-1
		If KeyHit(32) Then lxx=lxx+1
	Else
		If KeyDown(17) Then lyy=lyy-1
		If KeyDown(31) Then lyy=lyy+1
		If KeyDown(30) Then lxx=lxx-1
		If KeyDown(32) Then lxx=lxx+1
	EndIf
	
	
	
	If KeyHit(88) Then writeizm()
	
	Flip
Wend

CloseFile drr
End



Function writeizm()
	For brc.scr=Each scr
		SeekFile drr,brc\ofs
		WriteInt(drr,brc\iid)
		WriteByte(drr,brc\unk1)
		
		If brc\unk1=0 Then
		
			WriteInt(drr,brc\id)
			WriteInt(drr,brc\x)
			WriteInt(drr,brc\y)
			WriteInt(drr,brc\unk2)
		
		Else If brc\unk1=1 Then
		
			WriteInt(drr,brc\x)
			WriteInt(drr,brc\y)		
		
		EndIf
	Next
	For bc.cart=Each cart
		SeekFile drr,bc\ofs
		WriteInt(drr,bc\L)
		WriteInt(drr,bc\T)
		WriteInt(drr,bc\R)
		WriteInt(drr,bc\B)
	Next
End Function




Function readtrustring$(fil%)
	nm=ReadInt(fil)
	bred$=""
	For i=1 To nm
		bred=bred+Chr(ReadByte(fil))
	Next
	Return bred
End Function