Graphics3D 800,600,0,2
SetBuffer BackBuffer()

Global buf

If FileType("screen.bmp")=0 Then

buf=CreateTexture(4096,512,512)

mapres=ReadFile("res(1_24).wmr") ;big file ~1MB from '1' dir
LockBuffer TextureBuffer(buf)

ReadByte(mapres)

db=ReadByte(mapres)
ReadShort(mapres)


For i= 1 To db
	gdds%=FilePos(mapres)
	tmpp=ReadInt(mapres)
	If ((tmpp Shr 24) And $FF)=$00 Then
		param=(tmpp And $FFFFFF)+gdds
		Exit
	EndIf
Next

SeekFile mapres,param
ReadByte mapres
db=ReadByte(mapres)
ReadShort mapres
pdb=db
If (db And 1)= 1 Then pdb=db+1
For i=1 To pdb
	ReadShort mapres
Next

For i=1 To db
	gdds=FilePos(mapres)
	pnt=ReadInt(mapres)
	SeekFile mapres,(gdds+pnt)
	gdds2=FilePos(mapres)
	k=ReadInt(mapres)
		For j=1 To k
		pnt2=ReadInt(mapres)
		;debuglog  pnt2
		gdds3=FilePos(mapres)
		;debuglog  j+" "+k
		SeekFile mapres,(gdds2+pnt2)
		LoadTim(mapres)
		SeekFile mapres,gdds3
		Next
	;///////////////
	SeekFile mapres,(gdds+4)
Next

CloseFile mapres
UnlockBuffer TextureBuffer(buf)

SaveBuffer(TextureBuffer(buf),"screen.bmp")

Else

buf=LoadTexture("screen.bmp",512)
LockBuffer TextureBuffer(buf)
	UnlockBuffer TextureBuffer(buf)
EndIf




AmbientLight 255,255,255

Global txs=0

Global texs%[256]
Global texes%=0

Type vbuf
	Field x%
	Field tx%
End Type

Dialog(True,"","")

fil=ReadFile(GetPathName()) ; Files from 12 dir

Global version%=1

sss$=Input("What version of map do you want to load(1/2)?:")
If sss=2 Then version=2

orient=1
orienta$=Input("Orientationt (1/2)?  (1 for 0 file, 2 for 1 file):")
If orienta=2 Then orient=2

;Const vram%=1024*512*2

;Global GpuBuffer%=CreateBank(vram)

Global WorldGridW%,WorldGridH%

;Global GlobTim%

WorldGridW=ReadShort(fil)
WorldGridH=ReadShort(fil)

Global attr2
Global Gdh%=4

dbs=FilePos(fil)

For j=1 To WorldGridH
	For i=1 To WorldGridW
		V1=ReadShort(fil)
		attr1=ReadByte(fil)
		attr2%=ReadByte(fil)
	Gdh=Gdh+4
	SeekFile(fil,V1*$800)
	If attr2<>0 Then loadSetka2(fil,i,j,attr2) ;: ;debuglog Hex(V1*$800)
	SeekFile(fil,Gdh)
		V1=ReadShort(fil)
		attr1=ReadByte(fil)
		attr2%=ReadByte(fil)
	Gdh=Gdh+4
	SeekFile(fil,V1*$800)
	If attr2<>0 Then loadSetka2(fil,i,j,attr2) ;: ;debuglog Hex(V1*$800)
	SeekFile(fil,Gdh)
;	txs=txs+1
	Next
Next

SeekFile fil,dbs


Gdh=4
If orient=1 Then;//////////////////////
For j=1 To WorldGridH
	For i=1 To WorldGridW
		V1=ReadShort(fil)
		attr1=ReadByte(fil)
		attr2%=ReadByte(fil)
	Gdh=Gdh+4
	If version=1 Then
		SeekFile(fil,V1*$800)
		If attr1<>0 Then loadSetka(fil,i,j)
		SeekFile(fil,Gdh)
	EndIf
		V1=ReadShort(fil)
		attr1=ReadByte(fil)
		attr2%=ReadByte(fil)
	Gdh=Gdh+4
	If version=2 Then
		SeekFile(fil,V1*$800)
		If attr1<>0 Then loadSetka(fil,i,j)
		SeekFile(fil,Gdh)
	EndIf

	txs=txs+1
	Next
Next
Else;/////////////////////////////////////////
For i=1 To WorldGridW
	For j=1 To WorldGridH
		V1=ReadShort(fil)
		attr1=ReadByte(fil)
		attr2%=ReadByte(fil)
	Gdh=Gdh+4
	If version=1 Then
		SeekFile(fil,V1*$800)
		If attr1<>0 Then loadSetka(fil,i,j)
		SeekFile(fil,Gdh)
	EndIf
		V1=ReadShort(fil)
		attr1=ReadByte(fil)
		attr2%=ReadByte(fil)
	Gdh=Gdh+4
	If version=2 Then
		SeekFile(fil,V1*$800)
		If attr1<>0 Then loadSetka(fil,i,j)
		SeekFile(fil,Gdh)
	EndIf

	txs=txs+1
	Next
Next
EndIf;/////////////////////////////////////////


cam=CreateCamera()
CameraClsColor cam,0,100,100

MoveMouse GraphicsWidth()/2,GraphicsHeight()/2	
While Not KeyDown(1)
	
	;TurnEntity c,MouseYSpeed(),-MouseXSpeed(),0
	mouselook(cam)
	If KeyDown(200) Then MoveEntity cam,0,0,1
	If KeyDown(208) Then MoveEntity cam,0,0,-1

	RenderWorld()
	
;	CameraPick cam,MouseX(),MouseY()
	
	If PickedEntity() Text 10,10,	EntityName(PickedEntity()) + "   " + PickedTriangle()
	
	
	
;If KeyHit(28) Stop

;	Text 10,10,maxx
;	Text 10,20,sssr
	If KeyHit(57) ggg=Not ggg:WireFrame ggg 
		
;	If KeyHit(28) ClearWorld(1,1,1) : Goto nach	
	
	Flip
Wend
End


Function mouselook(ent)

	mxspd#=MouseXSpeed()*0.25
	myspd#=MouseYSpeed()*0.25

	MoveMouse GraphicsWidth()/2,GraphicsHeight()/2	
	
	campitch#=EntityPitch(ent)+myspd#
	
	If campitch#<-85 Then campitch#=-85
	If campitch#>85 Then campitch#=85

	RotateEntity ent,campitch#,EntityYaw(ent)-mxspd#,0
End Function

Function ReadSShort%(fl%)
	Local qq%
	qq=ReadShort(fl)
	If qq>32767 Then qq=qq-65536
	Return qq
End Function


Function loadSetka(fl%,x%,y%)

Local mesh%[4]

Local c.vbuf

Local VertX#[1024]
Local VertY#[1024]
Local VertZ#[1024]


tmp1=FilePos(fl)
ffs%=ReadInt(fl)
point%=ReadInt(fl)

dffs%=ffs Shr 16


mesh[0]=ReadInt(fl)
mesh[1]=ReadInt(fl)
mesh[2]=ReadInt(fl)
mesh[3]=ReadInt(fl)

For i=0 To 3
	SeekFile fl,tmp1+mesh[i]
	numvert=ReadByte(fl)
	ReadByte(fl)
	numtri=ReadShort(fl)
	VertPointer=ReadInt(fl)
	TriPointer=ReadInt(fl)
	SeekFile(fl,tmp1+vertpointer)
	
	For j=0 To (numvert-1)
	VertX[j]=ReadSShort(fl)/1024.0
	VertY[j]=-ReadSShort(fl)/1024.0
	VertZ[j]=ReadSShort(fl)/1024.0
	ReadShort(fl)
	Next
	
	
	
	sbsub=CreateMesh()
	
	NameEntity sbsub,txs+" "+x+" "+y+" "+i+" "+(texes-1)
	EntityPickMode sbsub,2
	
	EntityTexture sbsub,buf
	PositionEntity sbsub,x*16+(i Mod 2)*8 ,0,-y*16-(i/2)*8
	SeekFile(fl,tmp1+tripointer)
	
	spsub=CreateSurface(sbsub)
	ppc=-1
	norm=True
	For j=0 To (numtri-1)
	
	
	
	
	
	tmp2=ReadByte(fl)
	tmp3=ReadByte(fl)
	tmp4=ReadByte(fl)
	ReadByte(fl)

	
	u1#=ReadByte(fl)
	v1#=ReadByte(fl)
	nx1=ReadShort(fl)
	
	u2#=ReadByte(fl)
	v2#=ReadByte(fl)
	tpage%=ReadShort(fl)
	
	u3#=ReadByte(fl)
	v3#=ReadByte(fl)
	nx3=ReadShort(fl)
	
	tx=tpage And 15
ty=(tpage Shr 4) And 1

If tx=0 And ty=0 Then
If norm=True
sbsub=CreateMesh()
	NameEntity sbsub,txs+" "+x+" "+y+" "+i+" "+(texes-1)
	EntityPickMode sbsub,2
PositionEntity sbsub,x*16+(i Mod 2)*8 ,0,-y*16-(i/2)*8
	norm=False
spsub=CreateSurface(sbsub)
ppc=-1
EndIf

v1=Float(v1)/255.0
v2=Float(v2)/255.0
v3=Float(v3)/255.0
u1=u1/255.0
u2=u2/255.0
u3=u3/255.0

	AddVertex(spsub,VertX[tmp2],VertY[tmp2],VertZ[tmp2],u1,v1)
	AddVertex(spsub,VertX[tmp3],VertY[tmp3],VertZ[tmp3],u2,v2)
	AddVertex(spsub,VertX[tmp4],VertY[tmp4],VertZ[tmp4],u3,v3)
	ppc=ppc+3
	
	AddTriangle(spsub,ppc-2,ppc-1,ppc)
For c=Each vbuf
If c\x=dffs Then 
EntityTexture sbsub,c\tx
Exit
EndIf
Next

Else
If norm=False Then
sbsub=CreateMesh()
	NameEntity sbsub,txs+" "+x+" "+y+" "+i+" "+(texes-1)
	EntityPickMode sbsub,2
PositionEntity sbsub,x*16+(i Mod 2)*8 ,0,-y*16-(i/2)*8
spsub=CreateSurface(sbsub)
	ppc=-1
norm=True
EntityTexture sbsub,buf
EndIf

v1=0.5*Float(ty) +Float(v1)/512.0
v2=0.5*Float(ty) +Float(v2)/512.0
v3=0.5*Float(ty) +Float(v3)/512.0
u1=Float(tx)*0.0625+u1/2048.0
u2=Float(tx)*0.0625+u2/2048.0
u3=Float(tx)*0.0625+u3/2048.0


	AddVertex(spsub,VertX[tmp2],VertY[tmp2],VertZ[tmp2],u1,v1)
	AddVertex(spsub,VertX[tmp3],VertY[tmp3],VertZ[tmp3],u2,v2)
	AddVertex(spsub,VertX[tmp4],VertY[tmp4],VertZ[tmp4],u3,v3)
	ppc=ppc+3
	
	AddTriangle(spsub,ppc-2,ppc-1,ppc)
EndIf




	Next
	



EntityFX sbsub,1
	
Next


	
	
End Function

Function loadSetka2(fl%,x%,y%,att2%)

Local mesh%[4]

Local VertX#[1024]
Local VertY#[1024]
Local VertZ#[1024]


tmp1=FilePos(fl)
ffs%=ReadInt(fl)
point%=ReadInt(fl)


ffs=ffs Shr 16

If attr2<>0 Then

	psd=FilePos(fl)
	SeekFile(fl,tmp1+point)
	LoadSpecialTim(fl,ffs)
	DebugLog x+" "+y+" " + Right(Bin (att2),5) + " " + att2
	SeekFile fl,psd
EndIf
End Function

Function LoadSpecialTim(fl%,attr%)
Local msk%[256]
Local ppc#=8.22580;
tmp1=FilePos(fl)
nums%=ReadInt(fl)

tmpLS%=CreateTexture(256,256,1+512)

fss=4

LockBuffer TextureBuffer(tmpLS)

For k=1 To (nums)
	SeekFile fl,tmp1+fss
	tmp2=ReadInt(fl)
	fss=fss+4
	SeekFile fl,tmp1+tmp2
	ReadInt(fl)
	flag=ReadInt(fl)
	clut=0
	If flag And 8 = 8 Then clut=1
	
	If (flag And 7) = 1 Then cbytes=2
	If (flag And 7) = 2 Then cbytes=2
	If (flag And 7) = 3 Then cbytes=3
	
	If clut Then
		ReadInt(fl)
		ReadShort(fl)
		ReadShort(fl)
		ReadShort(fl)
		ReadShort(fl)
		For i=0 To 255
		ktmp%=ReadShort(fl)
		;;debuglog ktmp
		
		pipka=ktmp Shr 15
		If pipka Then
		msk[i]=($FF Shl 24) Or (((((ktmp) And $1f)*ppc) And $FF) Shl 16) Or ((((((ktmp) Shr 5) And $1f)*ppc) And $FF) Shl 8) Or ((((((ktmp) Shr 10 ) And $1f )*ppc) And $FF))
		Else
		msk[i]=($00 Shl 24) Or (((((ktmp) And $1f)*ppc) And $FF) Shl 16)  Or  ((((((ktmp) Shr 5) And $1f) *ppc) And $FF) Shl 8) Or ((((((ktmp) Shr 10 ) And $1f )*ppc) And $FF))
		EndIf
		
		Next
	EndIf
	ReadInt(fl)
	dX=ReadShort(fl)
	dy=ReadShort(fl)
	dw=ReadShort(fl)
	dh=ReadShort(fl)
	If dw>255 Then RuntimeError(Hex(FilePos(fl)))
	For j=0 To (dh-1)
		For i=0 To (dw*cbytes-1)
			bttt%=ReadByte(fl)
			
			If (dx+i)>255 Then RuntimeError(Hex(FilePos(fl)))
			If (dy+j)>255 Then RuntimeError(Hex(FilePos(fl)))
			
			WritePixelFast(dx*2+i,dy+j,msk[bttt],TextureBuffer(tmpls))
		Next
	Next
Next

UnlockBuffer TextureBuffer(tmpLS)


texs[texes]=tmpls
texes=texes+1
GlobTim=tmpls

Local c.vbuf
c = New vbuf
c\tx = tmpls
c\x =attr



End Function


Function LoadTim(fl%)
Local hasClut%=0
Local tmmp%,sizeof%
Local ppc#=8.22580;

Local poloj%

Local clut%[256]

;;	c.tims=New TimS 
;debuglog  Hex(FilePos(fl))
	If ReadInt(fl)<>$10 Then Return
	tmmp=ReadInt(fl)
	If (tmmp And 8) = 8 Then hasClut=1
	If (tmmp And 7) = 0 Then cbytes=2
	If (tmmp And 7) = 1 Then cbytes=1

	If hasClut Then
		ReadInt(fl)
		ReadShort(fl)
		ReadShort(fl)
		ReadShort(fl)
		ReadShort(fl)
		If cbytes=1
		For i=0 To 255
		ktmp%=ReadShort(fl)
		;;debuglog ktmp
		
		pipka=ktmp Shr 15
		If pipka Then
		clut[i]=($FF Shl 24) Or (((((ktmp) And $1f)*ppc) And $FF) Shl 16) Or ((((((ktmp) Shr 5) And $1f)*ppc) And $FF) Shl 8) Or ((((((ktmp) Shr 10 ) And $1f )*ppc) And $FF))
		Else
		clut[i]=($00 Shl 24) Or (((((ktmp) And $1f)*ppc) And $FF) Shl 16)  Or  ((((((ktmp) Shr 5) And $1f) *ppc) And $FF) Shl 8) Or ((((((ktmp) Shr 10 ) And $1f )*ppc) And $FF))
		EndIf
		
		Next
		Else
		For i=0 To 15
		ktmp%=ReadShort(fl)
		;;debuglog ktmp
		
		pipka=ktmp Shr 15
		If pipka Then
		clut[i]=($FF Shl 24) Or (((((ktmp) And $1f)*ppc) And $FF) Shl 16) Or ((((((ktmp) Shr 5) And $1f)*ppc) And $FF) Shl 8) Or ((((((ktmp) Shr 10 ) And $1f )*ppc) And $FF))
		Else
		clut[i]=($00 Shl 24) Or (((((ktmp) And $1f)*ppc) And $FF) Shl 16)  Or  ((((((ktmp) Shr 5) And $1f) *ppc) And $FF) Shl 8) Or ((((((ktmp) Shr 10 ) And $1f )*ppc) And $FF))
		EndIf
		
		Next
		EndIf
	EndIf
	
	sizeof=(ReadInt(fl)-12)
	cx=ReadShort(fl)
	cy=ReadShort(fl)
	cwi=ReadShort(fl)
	chi=ReadShort(fl)
	
;	poloj=cx*2 + cy*1024*2
	If (cwi > 256) Or (chi>256) Then Return
	For j=0 To (chi-1)
	For i=0 To ((cwi*2)-1)
	bttt%=ReadByte(fl)
	If cbytes=2 Then
		WritePixelFast(cx*4+i*2,cy+j,clut[(bttt And $f)],TextureBuffer(buf))
		WritePixelFast(cx*4+i*2+1,cy+j,clut[((bttt Shr 4) And $f)],TextureBuffer(buf))
	Else
		WritePixelFast(cx*4+i*2,cy+j,clut[bttt],TextureBuffer(buf))
		WritePixelFast(cx*4+i*2+1,cy+j,clut[bttt],TextureBuffer(buf))
	EndIf
;	PokeByte(GpuBuffer,poloj+i,ReadByte(fl))	
	Next
	Next
	
;	For i=0 To (sizeof-1)
;		PokeByte(c\bitmap,i,ReadByte(fl))
;	Next
;;;	c\pagex=Floor(c\x/64)
;;	;c\pagey=Floor(c\y/256)
;;;	;	c\x=c\x-c\pagex*64
;;;	c\y=c\y-c\pagey*256
End Function
