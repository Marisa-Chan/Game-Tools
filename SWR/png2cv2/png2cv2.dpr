program png2cv2;

{$APPTYPE CONSOLE}

uses
  windows,
  SysUtils,
  pngimage,Strutils;

var
  img:TPNGObject;
  bpp,width,height,i,j,k:Integer;
  fil,ss,tmp:Cardinal;
  ovr:OVERLAPPED;
  st1,st2,st3:string;

begin

if ParamCount <1 then
writeln('Usage:  png2cv2.exe src.png');
if ParamCount < 1 then Halt;

for k := 1 to ParamCount do
begin


st3:=ExtractFilePath(ParamStr(0));
if st3[length(st3)]<>'\' then st3:=st3+'\';


st1:=ParamStr(k);

if not(FileExists(st1)) then
  st1:=st3+st1;


  st2:=ExtractFilePath(st1);
  if st2[length(st2)]<>'\' then st2:=st2+'\';
  st2:=st2 + AnsiLeftStr(ExtractFileName(st1),pos('.',ExtractFileName(st1)))+'cv2';


//if not(FileExists(st2)) then
 // st2:=st3+st2;

img:=TPNGObject.Create;
img.LoadFromFile(st1);

bpp:=24;

if img.Header.ColorType=COLOR_RGBALPHA then
for j := 0 to img.Height - 1 do
  for i := 0 to img.Width - 1 do
      if pbyte(cardinal(img.AlphaScanline[j])+i)^<>255 then
          begin
            bpp:=32;
            break;
          end;

width:=img.Width;
height:=img.Height;

ZeroMemory(@ovr,sizeof(ovr));

ovr.Offset:=0;
ovr.Internal:=0;
ovr.InternalHigh:=0;
ovr.OffsetHigh:=0;
ovr.hEvent:=0;

fil:=createfile(@st2[1],GENERIC_ALL,FILE_SHARE_READ or FILE_SHARE_WRITE ,nil,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,ss);



WriteFileEx(fil,@bpp,1,ovr,nil);

ovr.Offset:=1;
WriteFileEx(fil,@width,4,ovr,nil);
ovr.Offset:=5;
WriteFileEx(fil,@height,4,ovr,nil);
ovr.Offset:=9;
WriteFileEx(fil,@width,4,ovr,nil);

bpp:=0;
ovr.Offset:=13;
WriteFileEx(fil,@bpp,4,ovr,nil);

for j := 0 to img.Height - 1 do
  for i := 0 to img.Width - 1 do
     begin
     tmp:=pbyte(cardinal(img.Scanline[j])+i*3)^;
     tmp:=tmp or (pbyte(cardinal(img.Scanline[j])+i*3+1)^ shl 8);
     tmp:=tmp or (pbyte(cardinal(img.Scanline[j])+i*3+2)^ shl 16);
     if img.Header.ColorType=COLOR_RGBALPHA then     
       tmp:=tmp or (pbyte(cardinal(img.alphascanline[j])+i)^ shl 24)
     else
       tmp:=tmp or $FF000000;
       ovr.Offset:=ovr.Offset+4;
       WriteFileex(fil,@tmp,4,ovr,nil);
     end;






//WriteFileex(fil,)

closehandle(fil);


img.Free;

end;




  { TODO -oUser -cConsole Main : Insert code here }
end.
