Include "FastImage.bb"

Graphics3D 800,600,0,2


SetBuffer BackBuffer()
InitDraw

.Nach

Const vram%=1024*512*2

Global GpuBuffer%=CreateBank(vram)
For i=0 To (vram-1)
	PokeByte(GpuBuffer,i,0)
Next

Global pal%[256]

Global fil%

Dialog(False,"","")

Global MYA$=GetPathName()
Global filname=GetFileName()

fil=ReadFile(MYA) ; File from 4 Dir

AppTitle GetPathName()

If ReadByte(fil)<>$db Then 
	RuntimeError ("Not DB")
EndIf

Global aaaaaadr%

ReadDB(fil)



;LoadTim("1.tim")
;LoadTim("2.tim")
;LoadTim("3.tim")
;LoadTim("4.tim")
;LoadTim("5.tim")
;LoadTim("6.tim")
;







;psik = CreateImage(1024,512)
;
;;LockBuffer(ImageBuffer(psik))
;;
;;For j= 0 To 511
;;For i=0 To 1023
;;zzzz=PeekShort(GpuBuffer,((i+j*1024)*2))
;;WritePixelFast i,j,(((zzzz And $1f)*5) Shl 16) Or ((((zzzz Shr 5) And $1f) *5) Shl 8) Or (((zzzz Shr 10 ) And $1f )*5), ImageBuffer(psik)
;;Next
;;Next
;;
;;UnlockBuffer(ImageBuffer(psik))
;
;SaveImage(psik,"gpu.bmp")


Global tmp1%,tmp2%,tmp3%,tmp4%,tmp5%,tmp6%,tmp7%,tmp8%,u%,v%
Global tp1%,tp2%,tp3%,tp4%



Type tiles
	Field img%
	Field xx%
	Field y%
	Field order%
	Field abr%
	Field anim%
	Field block%
	Field set%
	Field br#
End Type

Type seq
	Field strt%
	Field num%
	Field cur%
	Field bank%
	
	Field napr%
	Field msec%
End Type


;fil=ReadFile("1.tileinfo")
SeekFile fil,aaaaaadr
ReadInt(fil)
Global Num1%=ReadShort(fil)
Global Num2%=ReadShort(fil)
ReadShort(fil)
Global skolkosetov%=ReadShort(fil)
Global ofs1%=ReadInt(fil)
Global ofs2%=ReadInt(fil)
SeekFile (fil,aaaaaadr+$30)

ska1=ReadShort(fil)
ska2=ReadShort(fil)





For i=0 To  (num1-1)
SeekFile fil,aaaaaadr+ofs1
zxc.seq=New seq
zxc\cur=0
zxc\napr=0
	ReadByte(fil)
	zxc\num=ReadByte(fil)
	ReadShort(fil)
	ReadInt(fil)
	ReadInt(fil)
SeekFile fil,aaaaaadr+ReadInt(fil)
	zxc\bank=CreateBank(2*zxc\num)
	For j=0 To zxc\num-1
	PokeShort(zxc\bank,j*2,ReadShort(fil))
	Next
	ofs1=ofs1+$10
Next


SeekFile fil,aaaaaadr+ofs2

iii=0

For i=0 To   (num2-1)
	tmppos=FilePos(fil)
	
bbbbb=ReadInt(fil);	If (ReadInt(fil) And $ff) = $12 Then ;0 -4

	
	ReadInt(fil); 4 -8
	ReadInt(fil); 8 - c
	tmp6=ReadShort(fil) ;c-d
	tmp5=ReadShort(fil) ; e-f
	
	;ReadInt(fil) ;c - 10
	ReadInt(fil) ;10 - 14
	ReadInt(fil) ;14 - 18
	btmp4=ReadShort(fil) ;18 - 1a
	btmp5=ReadShort(fil) ;1a - 1c
	ReadInt(fil) ;1c - 20
	ReadInt(fil) ;20 - 24
	tmpset=ReadShort(fil) ;24 - 26
	tmp3=ReadShort(fil) ;26 - 28
	tmp1=ReadInt(fil) ;28 - 2c
	tmp2=ReadInt(fil) ;2c - 30
	ReadInt(fil) ;30 - 34
	ReadInt(fil);34 - 38		
	
;	tmp6=tmp6+i*100
	
	
	For j=0 To (tmp3-1)
	SeekFile(fil,aaaaaadr+tmp1)	
	tmp4=ReadInt(fil)
	pnc.tiles=New tiles
	
	pnc\xx= sshort(tmp6+ska1)+(tmp4 Shr 22)                  ;(tmp4 Shr 22)
;	DebugLog  pnc\xx
	pnc\y=sshort(tmp5+ska2)+((tmp4 Shr 12) And $3ff)    ;((tmp4 Shr 12) And $3ff)
	
	pnc\order=bbbbb Shr 8
	
	pnc\block=i
	pnc\set=tmpset
	pnc\anim=bbbbb And $10

;	DebugLog  pnc\y 

iii=iii+1
	
;	DebugLog tmp5+ska2
;	DebugLog btmp5
;	DebugLog tmp6+ska1
;	DebugLog btmp4
;	DebugLog "aaaaa"
;	
	
	
	SeekFile(fil,aaaaaadr+tmp2)
	tmp7=ReadInt(fil)
	u=ReadByte(fil)
	v=ReadByte(fil)
	br=ReadShort(fil)	
	
	v=tmp7 Shr 24
	
	tp5=(tmp7 Shr 9) And $3f  ;  CLUT ID    X
	tp4=tmp7 And $1ff              ;  CLUT ID    Y
	
	ntp=(tp4 Shl 6) Or tp5
	
	tp3=(tp1 Or tp2) And $FFFF

	tp1=(tmp7 Shr 16) And $f
	tp2=(tmp7 Shr 15) And 1
	
	
	If ((tmp7 Shr 20)And 3)<>0 Then  ; TP
	TP=1
	Else
	TP=0
	EndIf
	
	
	br=(br Shr (8+4)) And 1
	
	; 8 bytes
	;
	;>>> 1st 4 bytes
	; 9 bits   -  CLUT ID   Y         0-8
	; 6 bits   -  CLUT ID   X         9-E
	; 1 bit     -  PageY                     F
	; 4 bit     -  PageX                10-13
	; 2 bits   -   TP                     14-15
	; 2 bits   -   ABR                  16-17
	; 8 bits   -      V                    18-1F
	;>>>>2nd 4 bytes
	; 8 bits   -      U                   20-27
	; 8  ------unk or not use
	; 8 -------unk or not use
	; 4 --------unk or not use
	; 1 -------- Packet type, if 1 then packet 7E,         if 0  -   7C 
	; 3 -------- unk or not use
	
		
;	v0=(tmp7 Shr 20) And 3
;	
;	a0=1
;	If v0= 0 Then a0=0	
;	
;	a1= (tmp7 Shr 22) And 3
;	a2= (tmp7 Shr 10) And $3c0
;	a3=(tmp7 Shr 7) And  $100
;
;	v0=GetTPage(a0,a1,a2,a3)
;	tp1= v0 And $f
;	tp2 = (v0 Shr 4) And 1




abr=(tmp7 Shr 22) And 3
	
pnc\br=1.0
	
	
	If br=1 Then
abr=1
pnc\br=.5
Else
abr=0
pnc\br=1.0
EndIf



pnc\abr=abr
	
If tp=1
	For z=0 To 255
	ktmp=GetTim(0,0,tp5*16*2+z*2,tp4)
	ktmp=ktmp Or (GetTim(0,0,tp5*16*2+z*2+1,tp4) Shl 8)
	
	ppc#=8.22580;
	
	pipka=ktmp Shr 15
		If pipka Then
				pal[z]=($FF Shl 24) Or (((((ktmp) And $1f)*ppc) And $FF) Shl 16) Or ((((((ktmp) Shr 5) And $1f)*ppc) And $FF) Shl 8) Or ((((((ktmp) Shr 10 ) And $1f )*ppc) And $FF))
		Else
		pal[z]=0
		EndIf
	Next
	
	pnc\img=CreateTexture(16,16,1+2+256)
;	MaskImage pnc\img,0,0,0

	
	LockBuffer TextureBuffer(pnc\img)
	
	For z=0 To 15
		For z2=0 To 15
			WritePixelFast(z2,z,pal[GetTim(tp1,tp2,z2+u,z+v)],TextureBuffer(pnc\img))
		Next
	Next
	
	
	UnlockBuffer TextureBuffer(pnc\img)
	
Else

	For z=0 To 15
	ktmp=GetTim(0,0,tp5*16*2+z*2,tp4)
	ktmp=ktmp Or (GetTim(0,0,tp5*16*2+z*2+1,tp4) Shl 8)

	ppc#=8.22580;
	
	pipka=ktmp Shr 15
		If pipka Then
				pal[z]=($FF Shl 24) Or (((((ktmp) And $1f)*ppc) And $FF) Shl 16) Or ((((((ktmp) Shr 5) And $1f)*ppc) And $FF) Shl 8) Or ((((((ktmp) Shr 10 ) And $1f )*ppc) And $FF))
		Else
		pal[z]=0
		EndIf
	Next
	
	pnc\img=CreateTexture(16,16,1+2+256)

	LockBuffer TextureBuffer(pnc\img)
	
	For z=0 To 15
		For z2=0 To 7
		If (u And 1) = 0 Then
		nbp=GetTim(tp1,tp2,z2+(u)/2,z+v)
		nb1=nbp And $F
		nb2=(nbp Shr 4) And $F
		Else
		nbp=GetTim(tp1,tp2,z2+(u / 2),z+v)
		nb1=(nbp Shr 4) And $F
		nbp=GetTim(tp1,tp2,z2+1+(u / 2),z+v)
		nb2=nbp And $F
		EndIf
			WritePixelFast(z2*2,z,pal[nb1],TextureBuffer(pnc\img))
			
			WritePixelFast(z2*2+1,z,pal[nb2],TextureBuffer(pnc\img))
		Next
	Next
	
	
	UnlockBuffer TextureBuffer(pnc\img)	
EndIf
	
;	SetBuffer TextureBuffer(pnc\img)
;	
;	Color 255,1,1
;	Text 0,0,i
;
;	
;	SetBuffer BackBuffer()
	
	
	pnc\img=CreateImageEx(pnc\img,16,16,FI_FILTERED)
	
	
	
	tmp1=tmp1+4
	tmp2=tmp2+8
	Next
;EndIf
	SeekFile(fil,tmppos+$38)
Next





ClsColor 20,50,128

Global bb%,zz%

Local aa.tiles,dd.tiles

For j=0 To iii-1
	For aa=Each tiles
	If aa <> (Last tiles)
		dd=After aa
		If dd\order> aa\order Then Insert dd Before aa
	EndIf
	
	Next
Next

;SetBlend FI_ALPHABLEND

Global set=0


Local x1,y1
aa=First tiles
x1=aa\xx
y1=aa\y
For aa=Each tiles
If aa\set=set Then
If aa\xx<x1 Then x1=aa\xx
If aa\y<y1 Then y1=aa\y
EndIf
Next

bb=-x1
zz=-y1

CloseFile fil

While Not KeyDown(1)
SetOrigin bb,zz
Cls
StartDraw
For pnc.tiles=Each tiles
	If pnc\set=set Then
		

Select pnc\abr
	Case 0
	SetBlend  FI_ALPHABLEND
	SetAlpha pnc\br
	Case 1
	SetBlend FI_LIGHTBLEND
	SetAlpha pnc\br
	Case 2
	SetBlend FI_SHADEBLEND
	SetAlpha 0.9
	Case 3
	SetBlend FI_LIGHTBLEND
	SetAlpha 0.5
End Select

If pnc\anim=$10 Then
	DrawImageEx pnc\img,pnc\xx,pnc\y
Else

	For gg.seq=Each seq
	block=PeekByte(gg\bank,(gg\cur*2))
	If pnc\block=block Then 
	DrawImageEx pnc\img,pnc\xx,pnc\y
	Exit
	EndIf
	Next
	
EndIf
;	Color 255,0,0
;	Plot pnc\xx,pnc\y

	EndIf
Next

EndDraw


If KeyDown(200) zz=zz-10
If KeyDown(208) zz=zz+10
If KeyDown(203) bb=bb-10
If KeyDown(205) bb=bb+10
	
	For i=2 To 11
		If KeyHit(i)=True Then
		 set=i-2
		 
		aa=First tiles
x1=aa\xx
y1=aa\y
For aa=Each tiles
If aa\set=set Then
If aa\xx<x1 Then x1=aa\xx
If aa\y<y1 Then y1=aa\y
EndIf
Next

bb=-x1
zz=-y1

EndIf
	Next
	
	
If KeyHit(28) Then

For pnc.tiles=Each tiles
	FreeImageEx_(pnc\img)
	Delete pnc
Next

For gg.seq=Each seq
	Delete gg
Next

	ClearWorld(1,1,1) 
	
	Goto nach	
EndIf
	

For gg.seq=Each seq
Select gg\napr
Case 0
If MilliSecs()>gg\msec
	gg\cur=gg\cur+1
	If gg\cur>= gg\num Then 
	gg\cur=0
	gg\napr=0
;	gg\cur=gg\num-1
;	gg\napr=1
	EndIf
	gg\msec=MilliSecs()+150
	
EndIf
Case 1
gg\cur=gg\cur-1
If gg\cur=0 Then
	gg\napr=0
	gg\msec=MilliSecs()+40
EndIf

End Select
	
Next



If KeyHit(57) 
;	brrrr=CreateImage(400,240)
	
;	CopyRect(0,0,400,240,0,0,BackBuffer(),ImageBuffer(brrrr))

Local x2,y2
pnc=First tiles
x1=pnc\xx
x2=pnc\xx
y1=pnc\y
y2=pnc\y
For pnc.tiles=Each tiles
If pnc\set=cur Then
If pnc\xx<x1 Then x1=pnc\xx
If pnc\y<y1 Then y1=pnc\y
If pnc\xx>x2 Then x2=pnc\xx
If pnc\y>y2 Then y2=pnc\y
EndIf
Next

x1=x1+bb
x2=x2+bb+16
y1=y1+zz
y2=y2+zz+16

If x1<0 Then x1=0
If y1<0 Then y1=0

iiiimg=CreateImage(x2-x1+1,y2-y1+1)

CopyRect x1,y1,x2-x1+1,y2-y1+1,0,0,BackBuffer(),ImageBuffer(iiiimg)

	SaveImage(iiiimg,filname+"_"+Str(set)+".bmp")
	
	FreeImage iiiimg
;	FreeImage brrrr
EndIf
Color 255,255,255


Text 10,10,"Tile-Sets count: "+skolkosetov
Text 10,20,"current: "+set

	Flip
Wend
End



;#Region OldStyle LoadTim(fl%)
;Function LoadTim(fl%)
;Local hasClut%=0
;Local tmmp%,sizeof%
;
;Local poloj%
;
;;;	c.tims=New TimS 
;	ReadInt(fl)
;	tmmp=ReadInt(fl)
;	If (tmmp And 8) = 8 Then hasClut=1
;	If (tmmp And 7) = 1 Then cbytes=1
;	If (tmmp And 7) = 2 Then cbytes=2
;	If (tmmp And 7) = 3 Then cbytes=3
;	tmmp=FilePos(fl)
;	If hasClut=1 Then
;		SeekFile(fl,tmmp+ReadInt(fl))
;		tmmp=FilePos(fl)
;	EndIf
;	sizeof=(ReadInt(fl)-12)
;;;	c\BitmAp=CreateBank(sizeof)
;	cx=ReadShort(fl)
;	cy=ReadShort(fl)
;	cwi=ReadShort(fl)
;	chi=ReadShort(fl)
;	
;	poloj=cx*2 + cy*1024*2
;	
;	For j=0 To (chi-1)
;	For i=0 To ((cwi*cbytes)-1)
;	PokeByte(GpuBuffer,poloj+i,ReadByte(fl))	
;	Next
;	poloj=poloj+1024*2
;	Next
;	
;;	For i=0 To (sizeof-1)
;;		PokeByte(c\bitmap,i,ReadByte(fl))
;;	Next
;;;;	c\pagex=Floor(c\x/64)
;;;	;c\pagey=Floor(c\y/256)
;;;;	;	c\x=c\x-c\pagex*64
;;;;	c\y=c\y-c\pagey*256
;End Function
;#End Region

Function LoadTim(fll$)
Local hasClut%=0
Local tmmp%,sizeof%

Local poloj%

Local fl=ReadFile(fll)
;;	c.tims=New TimS 
	ReadInt(fl)
	tmmp=ReadInt(fl)
	If (tmmp And 8) = 8 Then hasClut=1
	If (tmmp And 7) = 1 Then cbytes=1
	If (tmmp And 7) = 2 Then cbytes=2
	If (tmmp And 7) = 3 Then cbytes=3
	tmmp=FilePos(fl)
	If hasClut=1 Then
		SeekFile(fl,tmmp+ReadInt(fl))
		tmmp=FilePos(fl)
	EndIf
	sizeof=(ReadInt(fl)-12)
;;	c\BitmAp=CreateBank(sizeof)
	cx=ReadShort(fl)
	cy=ReadShort(fl)
	cwi=ReadShort(fl)
	chi=ReadShort(fl)
	
	poloj=cx*2 + cy*1024*2
	
	For j=0 To (chi-1)
	For i=0 To ((cwi*cbytes)-1)
	PokeByte(GpuBuffer,poloj+i,ReadByte(fl))	
	Next
	poloj=poloj+1024*2
	Next
	
	CloseFile fl
;	For i=0 To (sizeof-1)
;		PokeByte(c\bitmap,i,ReadByte(fl))
;	Next
;;;	c\pagex=Floor(c\x/64)
;;	;c\pagey=Floor(c\y/256)
;;;	;	c\x=c\x-c\pagex*64
;;;	c\y=c\y-c\pagey*256
End Function


Function LoadTimFromMem(fll$)
Local hasClut%=0
Local tmmp%,sizeof%

Local poloj%

Local fl=fll
;;	c.tims=New TimS 
	ReadInt(fl)
	tmmp=ReadInt(fl)
	If (tmmp And 8) = 8 Then hasClut=1
	If (tmmp And 7) = 1 Then cbytes=1
	If (tmmp And 7) = 2 Then cbytes=2
	If (tmmp And 7) = 3 Then cbytes=3
	tmmp=FilePos(fl)
	If hasClut=1 Then
		SeekFile(fl,tmmp+ReadInt(fl))
		tmmp=FilePos(fl)
	EndIf
	sizeof=(ReadInt(fl)-12)
;;	c\BitmAp=CreateBank(sizeof)
	cx=ReadShort(fl)
	cy=ReadShort(fl)
	cwi=ReadShort(fl)
	chi=ReadShort(fl)
	
	poloj=cx*2 + cy*1024*2
	
	For j=0 To (chi-1)
	For i=0 To ((cwi*cbytes)-1)
	PokeByte(GpuBuffer,poloj+i,ReadByte(fl))	
	Next
	poloj=poloj+1024*2
	Next
	
;	For i=0 To (sizeof-1)
;		PokeByte(c\bitmap,i,ReadByte(fl))
;	Next
;;;	c\pagex=Floor(c\x/64)
;;	;c\pagey=Floor(c\y/256)
;;;	;	c\x=c\x-c\pagex*64
;;;	c\y=c\y-c\pagey*256
End Function


Function GetTim%(Px%,py%,X%,Y%)
Local offx%,offy%
	Return PeekByte( gpubuffer, px*128 + py*256*1024*2+x+y*1024*2)
;	For c.tims=Each tims
;		If Px>=c\pagex And py>=c\pagey And X<=(c\x+c\wi*c\bytes) And Y<=(c\y+c\hi*c\bytes) And X>= c\x And Y>=c\y Then
;			offx=x-c\x
;			offy=y-c\y
;			Return PeekByte(c\bitmap,offy*c\bytes*c\wi+((px-c\pagex)*64*c\bytes)+offx)
;			Exit
;		EndIf
;	Next
End Function


Function GetTPage(mode,abr,x,y)
v0=mode And 3
v0=v0 Shl 7
a1=abr And 3
a1=a1 Shl 5
v0=v0 Or a1
v1 = y And $100
v1= v1 Sar 4
v0=v1 Or v0
a2=x And $3ff
a2=a2 Sar  6
v0 = v0 Or a2
a3= a3 And $200
a3=a3 Shl 2
v0= a3 Or v0

Return v0	
End Function


Function ReadSShort%(fl%)
	Local qq%
	qq=ReadShort(fl)
	If qq>32767 Then qq=qq-65536
	Return qq
End Function

Function sshort%(fl%)
qq=fl
If qq>32767 Then qq=qq-65536
	Return qq
End Function





Function ReadDB(fil%)
Local scol%
Local tmp1%,tmp2%,tmp3%,param%


scol=ReadByte(fil)
ReadShort(fil)

For i=1 To scol
	tmp1=FilePos(fil)
	tmp2=ReadInt(fil)
	param=(tmp2 Shr 24)
	tmp2=tmp2 And $FFFFFF
	If param = $1B Then
		SeekFile (fil,tmp1+tmp2)
		read1b(fil)
	EndIf
	If param = 4 Then
		LoadTims(fil,tmp1+tmp2)
	EndIf
	If param= $A Then
		aaaaaadr=tmp1+tmp2+$10
	EndIf
	SeekFile fil,(tmp1+4)
Next


End Function


Function read1b(fil%)
Local tmp1%,tmp2%,tmp3%

ReadByte(fil)
tmp1=ReadByte(fil)
ReadShort(fil)

tmp2=tmp1
If (tmp2 And 1) = 1 Then tmp2=tmp2+1

SeekFile(fil, FilePos(fil)+tmp2*2)

For i=1 To tmp1
tmp2=FilePos(fil)
tmp3=ReadInt(fil)
SeekFile(fil,tmp2+tmp3)
If ReadByte(fil)=$db Then ReadDB(fil)
SeekFile(fil,tmp2+4)
Next


End Function

Function LoadTims(fl%,addr%)
Local endg%=FilePos(fl)
Local hows%,fif%,fuf%,tmmp%
SeekFile(fl,addr)
If ReadByte(fl)<>4 Then RuntimeError("FUCKED TIMS") : End

hows=ReadByte(fl)
ReadShort(fl)
 
For i=1 To hows
	ReadShort(fl)
Next
If (hows And 1) = 1 Then ReadShort(fl)

For i=1 To hows
	fif=FilePos(fl)
	tmmp=ReadInt(fl)
	fuf=FilePos(fl)
	SeekFile(fl,tmmp+fif)
	LoadTimFromMem(fl)
	SeekFile(fl,fuf)
Next

SeekFile(fl,endg)
End Function


