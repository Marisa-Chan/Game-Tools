program DatCreater;

{$APPTYPE CONSOLE}


uses
  windows,
  SysUtils,
  Messages,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  strutils;

type
prmbr=^mrbr;
mrbr=record
v1:string;
v2,v3:cardinal;
end;

var
  mal:array [0..$9bF] of byte;  //$9bF
//  mrbr:cardinal=$0EB36A9A;
  mya:cardinal=0;

  glob:cardinal=0;
  files:cardinal=0;

  xrr:Byte;

  i,j:cardinal;

  prs,prs2:Pointer;

  llst:TList;

  tabsmesh:cardinal=0;
  tbsm:cardinal=0;
  glosmesh:cardinal=0;

  partmp1,partmp2:cardinal;


  startdir_ln:cardinal;
   startdir_st:string;


  tmps,tmps2:string;


  fil,fil2:cardinal;
ss:cardinal;
ovr:OVERLAPPED;


ReplaceFlags: TReplaceFlags;






procedure ScanDir(StartDir: string; Mask:string; podp:boolean);
var  SearchRec : TSearchRec;
pz:prmbr;
begin if Mask = '' then Mask := '*.*';
  if StartDir[Length(StartDir)] <>  '\' then StartDir := StartDir + '\';
  if FindFirst(StartDir+Mask, faAnyFile, SearchRec) = 0 then
  begin
    repeat
    Application.ProcessMessages;
    if (SearchRec.Attr and faDirectory) <>  faDirectory then
     begin
     new(pz);
     pz.v1:=AnsiRightStr(StartDir + SearchRec.Name,length(StartDir + SearchRec.Name)-pos('data',StartDir + SearchRec.Name)+1);
     llst.Add(pz);
     glob:=glob + 9+length(pz.v1);
    // writeln(pz.v1);
     files:=files+1;
     end
    else if (SearchRec.Name <>  '..') and (SearchRec.Name <>  '.') then
    begin
   //   List.Add(StartDir + SearchRec.Name + '\');
      if podp then
        ScanDir(StartDir + SearchRec.Name + '\',Mask,podp);
    end;
    until FindNext(SearchRec) <>  0;
      FindClose(SearchRec);
    end;
end;








Procedure UPDTable();
var
i:cardinal;

ttmp,ttmp2,ttmp3,ttmp4,teax,tebx,tecx,tedx:cardinal;
begin
   for I := 0 to $26e do
    begin

    ttmp:=pcardinal(@(mal[(i)*4]))^;
    ttmp2:=pcardinal(@(mal[(i+1)*4]))^;
    ttmp3:=(ttmp and $80000000) or (ttmp2 and $7FFFFFFF);

    ttmp:=i+$18D;
    ttmp2:=$270;
    asm
      pushad
      mov ebx,ttmp2
      mov eax,ttmp
      mov edx,ttmp
      mov ecx,i
      sar edx,$1f
      idiv ebx
      mov eax,ttmp3
      shr eax,1

      mov tedx,edx
      mov teax,eax
      mov tebx,ebx
      mov tecx,ecx
      popad

//      mov edx,dword ptr ttmp5[edx*4]
//      xor edx,eax
//      mov eax,ttmp3
//      and eax,1
//      mov ttmp,eax
//      mov ttmp2,edx

//      popad
    end;

    tedx:=pcardinal(@(mal[tedx*4]))^;
    tedx:=teax xor tedx;
    teax:=ttmp3 and 1;
    ttmp:=teax;
    ttmp2:=tedx;


    if ttmp=0 then
    ttmp:=0
    else
    ttmp:=$9908B0DF;

    ttmp:=ttmp xor ttmp2;

    pcardinal(@(mal[i*4]))^:=ttmp;


    end;


    ttmp:=pcardinal(@(mal[$9BC]))^ and $80000000;
    ttmp2:= pcardinal(@(mal[0]))^ and $7FFFFFFF;
    ttmp3:= ttmp or ttmp2;
    ttmp4:=ttmp3 shr 1;

    ttmp:=pcardinal(@(mal[$630]))^;
    ttmp4:=ttmp4 xor ttmp;

    pcardinal(@(mal[$9BC]))^:=ttmp4;
    ttmp:=ttmp3 and 1;
    if ttmp=1 then
     begin
     pcardinal(@(mal[$9BC]))^:=pcardinal(@(mal[$9BC]))^ xor $9908B0DF;
     end;
    mya:=0;

end;





procedure encry(mem:pointer;size:cardinal);
var
tmps1:ansistring;
tmp1:SHORT;
tmp2,tmp2_2:cardinal;

pppc:file of byte;

ttmp,ttmp2,ttmp3,ttmp4,teax,tebx,tecx,tedx:cardinal;
dtm1,dtm2,dtm3,dtm4:cardinal;
bz,i,j:integer;

ttmp5:Pointer;
begin


dtm3:=0;

dtm1:=$64;
dtm2:=$64;

llst:=TList.Create;

for I := 0 to size - 1 do
  begin
  dtm3:=pbyte(integer(mem)+I)^;
  dtm3:=dtm3 xor dtm1;
  pbyte(integer(mem)+I)^:=dtm3 AND $FF;
  dtm1:=(dtm1+dtm2) and $FF;
  dtm2:=(dtm2+$4D) and $FF;
  end;

end;





procedure inittable(tmp2:cardinal);
var

ttmp,ttmp2,ttmp3,ttmp4,teax,tebx,tecx,tedx:cardinal;
dtm1,dtm2,dtm3,dtm4:cardinal;
bz,i,j:integer;

mem,ttmp5:Pointer;
begin

//GetMem(mem,tmp2);

pcardinal(@(mal[0]))^:=tmp2+6;

  for i := 1 to $26f do
    begin

    ttmp:=pcardinal(@(mal[(i-1)*4]))^;
    ttmp2:=ttmp;
    asm
      pushad
      mov eax,ttmp   //;65832156
      shr eax,$1E    //;3
      xor eax,ttmp   //;65832155
      imul eax,$6C078965  //;FEE5A389
      add eax,i
      mov ttmp,eax
      popad
    end;
    pcardinal(@(mal[i*4]))^:=ttmp;
    end;

    UPDTable();

end;

 begin

 ReplaceFlags:=[rfReplaceAll];

llst:=TList.Create;

files:=0;


tmps2:=ExtractFilePath(ParamStr(0));
if tmps2[Length(tmps2)] <>  '\' then tmps2 := tmps2 + '\';


//////////////////
//tmps2:='H:\Folder-0001\';
///  /////////////

if ParamCount=0 then
startdir_st:=tmps2+'data'
else
startdir_st:=ParamStr(1);

if (startdir_st[length(startdir_st)]='/') or (startdir_st[length(startdir_st)]='\') then
startdir_st:=LeftStr(startdir_st,length(startdir_st)-1);


if RightStr(startdir_st,4)<>'data' then
begin
  writeln('Please drag`n`drop `data` folder to this exe.');
  sleep(5000);
end
else begin


startdir_st:=LeftStr(startdir_st,Length(startdir_st)-4); 

scandir(startdir_st+'data','',true);

glob:=files*$10C;
GetMem(prs,glob);

ZeroMemory(prs,glob);


tmps:=tmps2+'data.dat';

fil:=CreateFile(@tmps[1],GENERIC_ALL,FILE_SHARE_READ or FILE_SHARE_WRITE ,nil,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,ss);

files:=files and $FFFF;



ovr.Internal:=0;
ovr.InternalHigh:=0;
ovr.Offset:=0;
ovr.OffsetHigh:=0;
ovr.hEvent:=0;

WriteFileEx(fil,@files,2,ovr,nil);

//ovr.Offset:=2;
//writefileex(fil,@glob,4,ovr,nil);

ovr.Offset:=2;
writefileex(fil,prs,glob,ovr,nil);

glosmesh:=2+glob;




//for I := llst.Count - 1  downto 0  do
for I := 0 to llst.Count - 1  do
  begin

  tmps:=startdir_st+prmbr(llst.Items[i]).v1;

  Writeln(tmps);

  fil2:=CreateFile(@tmps[1],GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_READONLY,ss);
  partmp1:=GetFileSize(fil2,nil);
  writeln(partmp1);
  getmem(prs2,partmp1);
  ovr.Offset:=0;
  ReadFileex(fil2,prs2,partmp1,@ovr,nil);
  CloseHandle(fil2);


  prmbr(llst.Items[i]).v3:=partmp1;
  prmbr(llst.Items[i]).v2:=glosmesh;

  xrr:=((glosmesh shr 1) or $8) and $FF;

  for j := 0 to partmp1 - 1 do
      pbyte(cardinal(prs2)+j)^:=pbyte(cardinal(prs2)+j)^ xor xrr;

  ovr.Offset:=glosmesh;
  writefileex(fil,prs2,partmp1,ovr,nil);

  glosmesh:=glosmesh+partmp1;

  FreeMem(prs2);


  tbsm:=tabsmesh;

   for j := 1 to length(prmbr(llst.Items[i]).v1) do
    begin
     if prmbr(llst.Items[i]).v1[j]='\' then
      pchar(cardinal(prs)+tabsmesh)^:='/'
     else
      pchar(cardinal(prs)+tabsmesh)^:=prmbr(llst.Items[i]).v1[j];

      tabsmesh:=tabsmesh+1;
    end;

   tabsmesh:=tbsm+$104;

  pcardinal(cardinal(prs)+tabsmesh)^:=prmbr(llst.Items[i]).v3;
  tabsmesh:=tabsmesh+4;
  pcardinal(cardinal(prs)+tabsmesh)^:=prmbr(llst.Items[i]).v2;
  tabsmesh:=tabsmesh+4;

 // StringReplace(prmbr(llst.Items[i]).v1,'\','/',replaceflags);



{ovr.Offset:=6;
writefileex(fil,prs,glob,ovr,nil); }


//  prmbr(llst.Items[i]).v1




  end;

//inittable(glob);
encry(prs,glob);

ovr.Offset:=2;
writefileex(fil,prs,glob,ovr,nil);

//WriteFileEx()




Writeln(glob);
Writeln(files);


closehandle(fil);

sleep(5000);

end;

  { TODO -oUser -cConsole Main : Insert code here }

end.
