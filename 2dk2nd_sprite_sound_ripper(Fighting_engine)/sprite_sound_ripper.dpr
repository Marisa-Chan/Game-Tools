program sprite_sound_ripper;

{$APPTYPE CONSOLE}

uses
  windows,
  SysUtils,
  pngimage,Strutils,Dialogs,classes;

type
  pmov=^mov;
  mov=array[0..38] of char;

  phren=^hren;
  hren=record
  unk:pointer;
  w:cardinal;
  h:cardinal;
  pal:cardinal;
  size:cardinal;
  ofs:cardinal;
  end;


  snd=record
  name:array[1..$24] of char;
  size:cardinal;
  unk:Word;
  end;


  bgra=record
  b:byte;
  g:byte;
  r:byte;
  a:byte
  end;

  ppals=^pals;
  pals=array[0..255] of bgra;

var
  fil,s2,fil2,ij:cardinal;
  ss,ovr,ovr2:OVERLAPPED;
  str:string;

  fw:WideString;
  pis:array[1..255] of WideChar;

  qqww:snd;
  snd_n:Cardinal;
  snd_m:pointer;

  str2:string[16];

  slst:TList;

  char_name:string[255];

  num_mov:cardinal;
  mov_po:pointer;

  cho_num:cardinal;

  cho_po:pointer;

  pkd,unpkd:pointer;


  nx,ny:cardinal;


  dir:string;


  pi,pj,pk:cardinal;

  pbt:Byte;

  zzzz:TPNGObject;



  tm_num:cardinal;

  zap:hren;
  zps:phren;

  new_size:cardinal;

  filp:Pointer;

  nom:string;

  

  tmppal:ppals;

  pallt:array[0..7] of ppals;
  mempal:pointer;

  est:boolean;

procedure Extract(dst,src:pointer;size:cardinal);
var
i,pos,pos2:cardinal;
tmp,tmp2,tmp3:cardinal;
teax:cardinal;
bt:byte;
begin

pos:=0;
pos2:=0;

while (pos<size) do
begin
tmp:=pbyte(cardinal(src)+pos)^;
tmp2:=tmp shr 6;
tmp:=tmp and $3f;

if tmp=0 then
  begin
    pos:=pos+1;
    tmp:=pbyte(cardinal(src)+pos)^;
    if tmp<>0 then
      tmp:=tmp+$3F
    else
      begin
      //tmp:=pbyte(cardinal(src)+pos+1)^+((pbyte(cardinal(src)+pos+2)^) shl 8);
      tmp:=pword(cardinal(src)+pos+1)^;
      tmp3:=(pbyte(cardinal(src)+pos+3)^) shl $10;
      tmp:=tmp+tmp3+$13F;
      pos:=pos+3;
      end;
  end;

case tmp2 of
0:begin
  teax:=tmp;
  if teax<>0 then
    begin
      tmp3:=tmp;
      for i := 0 to tmp3-1 do
        pbyte(cardinal(dst)+pos2+i)^:=0;
      pos2:=pos2+tmp3;
    end;
  end;
  
1:begin
  tmp3:=tmp;
  if tmp3<>0 then
    while (tmp>0) do
      begin
        bt:=pbyte(cardinal(src)+pos+1)^;
        pos:=pos+1;
        pbyte(cardinal(dst)+pos2)^:=bt;
        pos2:=pos2+1;
        tmp:=tmp-1;
      end;
  end;

2:begin
    bt:=pbyte(cardinal(src)+pos+1)^;
    pos:=pos+1;
    tmp3:=tmp;
    if tmp3<>0 then
      begin
      tmp:=tmp;
      for i := 0 to tmp3-1 do
        pbyte(cardinal(dst)+pos2+i)^:=bt;
      pos2:=pos2+tmp;
      end;
  end;
3:begin
  pos:=pos+1;
  tmp3:=pbyte(cardinal(src)+pos)^;
    if tmp3=0 then
      begin
      pos:=pos+1;
      teax:=pbyte(cardinal(src)+pos)^;
      teax:=(teax+1) shl 8;
      tmp3:=teax;
      pos:=pos+1;
      end;
    teax:=pos2 - tmp3;
    tmp3:=tmp;
    if tmp3<>0 then
      while (tmp>0) do 
        begin
        pbyte(cardinal(dst)+pos2)^:=pbyte(cardinal(dst)+teax)^;
        teax:=teax+1;
        pos2:=pos2+1;
        tmp:=tmp-1;
        end;
  end;
end;

pos:=pos+1;


end;

end;



begin

slst:=TList.Create;


ovr.Offset:=0;
ovr.OffsetHigh:=0;
ovr.Internal:=0;
ovr.InternalHigh:=0;


str:=ParamStr(1);

fil:=CreateFile(@str[1],GENERIC_ALL,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,s2);



ReadFileex(fil,@str2[1],$10,@ovr,nil);
ovr.Offset:=ovr.Offset+$10;

ReadFileex(fil,@char_name[1],$100,@ovr,nil);
ovr.Offset:=ovr.Offset+$100;

setlength(char_name,255);


num_mov:=0;
ReadFileex(fil,@num_mov,4,@ovr,nil);
ovr.Offset:=ovr.Offset+4;

//mov_po:=GetMemory(num_mov*$27);
//ReadFileex(fil,mov_po,num_mov*$27,@ovr,nil);
ovr.Offset:=$114+num_mov*$27;



cho_num:=0;
ReadFileex(fil,@cho_num,4,@ovr,nil);
ovr.Offset:=ovr.Offset+4;


//cho_po:=GetMemory(cho_num shl 4);
//ReadFileEx(fil,cho_po,cardinal(cho_num shl 4),@ovr,nil);
ovr.Offset:=ovr.Offset+(cho_num shl 4);


tm_num:=0;
ReadFileex(fil,@tm_num,4,@ovr,nil);
ovr.Offset:=ovr.Offset+4;



dir:=ExtractFilePath(ParamStr(0))+AnsiLeftStr(ExtractFileName(ParamStr(1)),pos('.',ExtractFileName(paramstr(1)))-1);

CreateDir(dir);

dir:=dir+'/';

CreateDir(dir+'1');
CreateDir(dir+'2');
CreateDir(dir+'3');
CreateDir(dir+'4');
CreateDir(dir+'5');
CreateDir(dir+'6');
CreateDir(dir+'7');

CreateDir(dir+'snd');


for ij := 0 to (tm_num-1)  do       //reading and expanding graph
begin

New(zps);

ZeroMemory(zps,$18);

est:=false;

readfileex(fil,@zps.unk,$14,@ovr,nil);
   {
Writeln(IntToHex(zap.unk,8));
Writeln(IntToHex(ovr.offset,8));
Writeln(IntToHex(ij,8));
writeln;    }

zps.ofs:=ovr.Offset;

ovr.Offset:=ovr.Offset+$14;


  if zps.size<>0 then
    begin

    pkd:=GetMemory(zps.size);


    if zps.pal=1 then
      new_size:=zps.w*zps.h+$400
    else
      new_size:=zps.w*zps.h;

    unpkd:=GetMemory(new_size);
    readfileex(fil,pkd,zps.size,@ovr,nil);
    ovr.Offset:=ovr.Offset+zps.size;
    
    Extract(unpkd,pkd,zps.size);

    Dispose(pkd);
    est:=true;
    end
  else if (zps.w<>0) and (zps.h<>0) then
    begin
    if zps.pal=1 then
      new_size:=zps.w*zps.h+$400
    else
      new_size:=zps.w*zps.h;

    unpkd:=GetMemory(new_size);
    readfileex(fil,unpkd,new_size,@ovr,nil);
    ovr.Offset:=ovr.Offset+new_size;

    est:=true;
    end;




if est then
  begin
  zps.unk:=unpkd;
  zps.size:=new_size;
  slst.Add(zps);
  end
else
  dispose(zps); 



end;

mempal:=GetMemory($2100);     //8 palettes
ReadFileEx(fil,mempal,$2100,@ovr,nil);
ovr.Offset:=ovr.Offset+$2100;



ReadFileEx(fil,@snd_n,4,@ovr,nil);

ovr.Offset:=ovr.Offset+$4;


for ij := 0 to snd_n-1 do     //extracting sounds
  begin
  ZeroMemory(@qqww,$2A);
  ReadFileEx(fil,@qqww,$2A,@ovr,nil);
  ovr.Offset:=ovr.Offset+$2A;

  if qqww.size<>0 then
    begin
    snd_m:=GetMemory(qqww.size);
    ReadFileEx(fil,snd_m,qqww.size,@ovr,nil);
    ovr.Offset:=ovr.Offset+qqww.size;

    ovr2.Offset:=0;
    ovr2.OffsetHigh:=0;
    ovr2.Internal:=0;
    ovr2.InternalHigh:=0;

    str:=dir+'snd/'+inttostr(ij)+'.wav';


    fil2:=CreateFile(@Str[1],GENERIC_ALL,FILE_SHARE_READ OR FILE_SHARE_WRITE,nil,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,s2);
    WriteFileEx(fil2,snd_m,qqww.size,ovr2,nil);
    CloseHandle(fil2);
    Dispose(snd_m); 
    end;

  end;





CloseHandle(fil);


for ij := 0 to 7 do                                //places pointers to global palettes
  pallt[ij]:=pointer(cardinal(mempal)+ij*$420);


for ij := 0 to slst.Count - 1 do                //applicate palette
begin

writeln(ij+1,'/',slst.Count);

zps:=slst.Items[ij];
//zzzz.SetSize(zps.w,zps.h);

nx:=zps.w;
ny:=zps.h;



if zps.pal=1 then
  begin
    zzzz:=TPNGObject.CreateBlank(COLOR_RGBALPHA,8,nx,ny);

    filp:=pointer(cardinal(zps.unk)+$400);
    tmppal:=zps.unk;
    new_size:=zps.size-$400;


    for pj := 0 to zps.h - 1 do
      for pi := 0 to zps.w - 1 do
        begin
        pbt:=pbyte(cardinal(filp)+pi+pj*zps.w)^;
        pbyte(cardinal(zzzz.Scanline[pj])+pi*3)^:=tmppal[pbt].b;
        pbyte(cardinal(zzzz.Scanline[pj])+pi*3+1)^:=tmppal[pbt].g;
        pbyte(cardinal(zzzz.Scanline[pj])+pi*3+2)^:=tmppal[pbt].r;
      //pbyte(cardinal(zzzz.AlphaScanline[pj])+pi)^:=255;
        pbyte(cardinal(zzzz.AlphaScanline[pj])+pi)^:=tmppal[pbt].a*255;
        if (tmppal[pbt].a=0) then
          if (tmppal[pbt].b<>0) or (tmppal[pbt].g<>0) or (tmppal[pbt].r<>0)  then
            pbyte(cardinal(zzzz.AlphaScanline[pj])+pi)^:=255;

        nom:=Format('%.4d',[ij]);

        end;

    zzzz.SaveToFile(dir+nom+'.png');

    zzzz.Free;
  end
else
  begin
    for pk := 0 to 7 do
      begin
      zzzz:=TPNGObject.CreateBlank(COLOR_RGBALPHA,8,nx,ny);

      new_size:=zps.size;
      tmppal:=pallt[pk];
      filp:=zps.unk;


      for pj := 0 to zps.h - 1 do
        for pi := 0 to zps.w - 1 do
          begin
          pbt:=pbyte(cardinal(filp)+pi+pj*zps.w)^;
          pbyte(cardinal(zzzz.Scanline[pj])+pi*3)^:=tmppal[pbt].b;
          pbyte(cardinal(zzzz.Scanline[pj])+pi*3+1)^:=tmppal[pbt].g;
          pbyte(cardinal(zzzz.Scanline[pj])+pi*3+2)^:=tmppal[pbt].r;
          //pbyte(cardinal(zzzz.AlphaScanline[pj])+pi)^:=255;
          pbyte(cardinal(zzzz.AlphaScanline[pj])+pi)^:=tmppal[pbt].a*255;
          if (tmppal[pbt].a=0) then
            if (tmppal[pbt].b<>0) or (tmppal[pbt].g<>0) or (tmppal[pbt].r<>0)  then
              pbyte(cardinal(zzzz.AlphaScanline[pj])+pi)^:=255;


          end;


      nom:=Format('%.4d',[ij]);

      if pk<>0 then
        zzzz.SaveToFile(dir+inttostr(pk)+'/'+nom+'.png')
      else
        zzzz.SaveToFile(dir+nom+'.png');

      zzzz.Free;
      end;
  end;


end;  



  { TODO -oUser -cConsole Main : Insert code here }
end.
