program Yami_graph_lzw_extr;

{$APPTYPE CONSOLE}

uses
  windows,
  SysUtils,
  pngimage,
  Strutils,
  Dialogs,
  classes;

type
  phren=^hren;
  hren=record
  pksize:cardinal;
  unpksz:cardinal;
  magic:cardinal;
  magic2:cardinal;
  width:cardinal;
  height:cardinal;
  bit:cardinal;
  unk:cardinal;
  unk2:cardinal;
  unk3:cardinal;
  end;
  
  pbgra=^bgra;
  bgra=record
  b:byte;
  g:byte;
  r:byte;
  a:byte
  end;


var

brr:hren;
fil,s2,fil2,ij,cx,cy:cardinal;
  ss,ovr,ovr2:OVERLAPPED;
  str:string;
  zzzz:TPNGObject;

  bg:pbgra;

  bl:Byte;

  dflt:array[0..255] of bgra;

  i,j,k:cardinal;

  pck,unpck:Pointer;

procedure unlzw(dst,src:pbyte;size:cardinal);
var
lz:array[0..$FFF] of byte;
lz_pos:cardinal;
cur:cardinal;
d_cur:cardinal;
otsk:cardinal;
bl,mk,i,j,lw,hi,loops:byte;
begin

cur:=0;
d_cur:=0;
lz_pos:=$0fee;

ZeroMemory(@lz[0],$1000);

while(cur<size) do
    begin
    bl:=pbyte(cardinal(src)+cur)^;
    mk:=1;

    for i:=0 to 7 do
        begin
        if ((bl and mk)=mk) then
            begin
            cur:=cur+1;
            if (cur >= size) then break;

            lz[lz_pos]:=pbyte(cardinal(src)+cur)^;

            pbyte(cardinal(dst)+d_cur)^:=pbyte(cardinal(src)+cur)^;

            d_cur:=d_cur+1;
            lz_pos:= (lz_pos+1) And $fff;
            end
        else
            begin
            cur:=cur+1;
            if (cur >= size) then break;
            lw:= pbyte(cardinal(src)+cur)^;

            cur:=cur+1;
            if (cur >= size) then break;
            hi:= pbyte(cardinal(src)+cur)^;

            loops:= (hi AND $f)+2;

            otsk:= lw OR ((hi AND $f0) shl 4);

                for j:= 0 to loops do
                    begin
                    lz[lz_pos]:=lz[(otsk+j) and $fff];
                    pbyte(cardinal(dst)+d_cur)^:=lz[(otsk+j) and $fff];
                    lz_pos:=(lz_pos+1) and $fff;
                    d_cur:=d_cur+1;
                    end
            end;

		    mk:=mk shl 1;

        end;

    cur:=cur+1;
    end;

end;




begin


for k := 1 to ParamCount do
begin

ovr.Offset:=0;
ovr.OffsetHigh:=0;
ovr.Internal:=0;
ovr.InternalHigh:=0;

str:=ParamStr(k);

fil:=CreateFile(@str[1],GENERIC_ALL,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,s2);


ZeroMemory(@brr,$28);

ReadFileex(fil,@brr,$28,@ovr,nil);

pck:=GetMemory(brr.pksize);

ovr.Offset:=$28;
ReadFileEx(fil,pck,brr.pksize,@ovr,nil);

unpck:=GetMemory(brr.unpksz);

unlzw(pbyte(unpck),pbyte(pck),brr.pksize);

Closehandle(fil);

str:=str+'.png';
cx:=brr.width;
cy:=brr.height;

if brr.bit=32 then
  begin
  zzzz:=TPNGObject.CreateBlank(COLOR_RGBALPHA,8,cx,cy);
  for j := 0 to cy - 1 do
    for I := 0 to cx - 1 do
    begin
    bg:=pbgra(cardinal(unpck)+i*4+j*cx*4);
    pbyte(cardinal(zzzz.Scanline[j])+i*3)^:=bg.b;
    pbyte(cardinal(zzzz.Scanline[j])+i*3+1)^:=bg.g;
    pbyte(cardinal(zzzz.Scanline[j])+i*3+2)^:=bg.r;
    pbyte(cardinal(zzzz.AlphaScanline[j])+i)^:=bg.a;
    if bg.a=0 then
      if ((bg.r<>0) or (bg.g<>0) or (bg.b<>0)) then
        pbyte(cardinal(zzzz.AlphaScanline[j])+i)^:=255;
      
    

    end;
  zzzz.SaveToFile(str);
  zzzz.Free;
  end
else if brr.bit=8 then
  begin
  zzzz:=TPNGObject.CreateBlank(COLOR_RGBALPHA,8,cx,cy);
  CopyMemory(@dflt[0],unpck,$400);

  for j := 0 to cy - 1 do
    for I := 0 to cx - 1 do
    begin
    bl:=pbyte(cardinal(unpck)+$400+i+j*cx)^;
    pbyte(cardinal(zzzz.Scanline[j])+i*3)^:=dflt[bl].b;
    pbyte(cardinal(zzzz.Scanline[j])+i*3+1)^:=dflt[bl].g;
    pbyte(cardinal(zzzz.Scanline[j])+i*3+2)^:=dflt[bl].r;
    pbyte(cardinal(zzzz.AlphaScanline[j])+i)^:=dflt[bl].a;
    if dflt[bl].a=0 then
      if ((dflt[bl].r<>0) or (dflt[bl].g<>0) or (dflt[bl].b<>0)) then
        pbyte(cardinal(zzzz.AlphaScanline[j])+i)^:=255;
    end;

  zzzz.SaveToFile(str);
  zzzz.Free;


  end
else
  ShowMessage('Unknown BitDepth');


{zzzz:=TPNGObject.CreateBlank();

  for j := 0 to List.Count - 1 do      }
                 {

    ovr2.Offset:=0;
    ovr2.OffsetHigh:=0;
    ovr2.Internal:=0;
    ovr2.InternalHigh:=0;
 str:=str+'out';
fil2:=CreateFile(@Str[1],GENERIC_ALL,FILE_SHARE_READ OR FILE_SHARE_WRITE,nil,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,s2);
    WriteFileEx(fil2,unpck,brr.unpksz,ovr2,nil);
    CloseHandle(fil2);      }

Dispose(unpck);
Dispose(pck);

end;
  { TODO -oUser -cConsole Main : Insert code here }
end.
