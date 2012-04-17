program Project1;

{$APPTYPE CONSOLE}

uses
windows,
  SysUtils,
  Messages,
  Variants,
  Classes,
  Dialogs,
  StdCtrls,
  strutils;


type
  ptp=^tp;
  tp=record
  filename:array [1..$20] of char;
  offset:cardinal;
  size:cardinal;
  end;

var
pck:string;
fil:cardinal;
ss:cardinal;
ovr:OVERLAPPED;

pck2:string;
fil2:cardinal;
ss2:cardinal;
ovr2:OVERLAPPED;


dir_to:string;
dir:string;

list:TList;

offset:cardinal;
files:cardinal;
i:integer;

gs:ptp;

pck3:string;
pck4:string;
pck5:string;

pck6:string;
pck7:string;

zzz:cardinal;

bzz,bzz2:cardinal;

buff:Pointer;

procedure ScanDir(StartDir: string; Mask:string; podp:boolean);
var  SearchRec : TSearchRec;
begin if Mask = '' then Mask := '*.*';
  if StartDir[Length(StartDir)] <>  '\' then StartDir := StartDir + '\';
  if FindFirst(StartDir+Mask, faAnyFile, SearchRec) = 0 then
  begin
    repeat
 //   Application.ProcessMessages;
    if (SearchRec.Attr and faDirectory) <>  faDirectory then
     begin
     new(gs);
     ZeroMemory(gs,$28);
     CopyMemory(@gs.filename[1],@searchrec.name[1],Length(searchrec.name));
//     gs.filename:=searchrec.name;

     list.Add(gs);
     end
    else if (SearchRec.Name <>  '..') and (SearchRec.Name <>  '.') then
    begin
   //   List.Add(StartDir + SearchRec.Name + '\');
      if podp then
        ScanDir(StartDir + SearchRec.Name + '\',Mask,podp);
    end;
    until FindNext(SearchRec) <>  0;
      findClose(SearchRec);
    end;
end;



begin


pck:=ParamStr(1);
dir:=ExtractFilePath(ParamStr(0));
if pck='' then exit;

if (pck[Length(pck)]='\') or (pck[Length(pck)]='/') then pck:=leftstr(pck,length(pck)-1);

for I := length(pck) downto 1 do
 begin
   if (pck[i]='\') or (pck[i]='/') then
    begin
      pck3:=midstr(pck,i+1,length(pck)-i);
      pck4:=leftstr(pck,i);
      break;
    end;
 end;

pck5:=pck+'.xfl';

fil:=CreateFile(@pck5[1],GENERIC_WRITE,FILE_SHARE_WRITE,nil,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,ss);

//IF  GetLastError<>0 then begin showmessage('Error creating file'); exit; end;



//dir_to:=ExtractFileName(pck);
//dir_to:=LeftStr(dir_to,pos(ExtractFileExt(pck),dir_to)-1);
//CreateDir (dir+dir_to);

zzz:=$0001424C;

WriteFile(fil,zzz,4,ss,nil);

zzz:=0;

WriteFile(fil,zzz,4,ss,nil);
WriteFile(fil,zzz,4,ss,nil);

list:=TList.Create;

ScanDir(pck,'',false);

for I := 0 to List.Count - 1 do
begin
  WriteFile(fil,(pinteger(list.items[i]))^,sizeof(tp),ss,nil);
end;


zzz:=list.Count*$28;
ovr.Offset:=4;
ovr.OffsetHigh:=0;
writeFileEx(fil,@zzz,4,ovr,nil);

zzz:=list.Count;
ovr.Offset:=8;
writeFileEx(fil,@zzz,4,ovr,nil);


bzz:=$C+list.Count*$28;
bzz2:=0;

for I := 0 to List.Count - 1 do
begin
  ptp(list.items[i]).offset:=bzz2;
  pck6:=ptp(list.Items[i]).filename;

  pck6:=pck+'\'+pck6;
  fil2:=CreateFile(@pck6[1],GENERIC_READ,FILE_SHARE_READ ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,ss);

    ptp(list.Items[i]).size:=getFileSize(fil2,@ss);

  buff:=GetMemory(ptp(list.Items[i]).size);
  ovr.Offset:=0;
  ReadFileex(fil2,buff,ptp(list.Items[i]).size,@ovr,nil);
  ovr.Offset:=bzz;
  writefileex(fil,buff,ptp(list.Items[i]).size,ovr,nil);
  FreeMem(buff);
  closehandle(fil2);

  bzz:=bzz+ptp(list.Items[i]).size;
  bzz2:=bzz2+ptp(list.Items[i]).size;
  ovr.Offset:=$C+i*$28;
  writefileex(fil,ptp(list.Items[i]),sizeof(tp),ovr,nil);
end;


 {


ovr.Offset:=4;
ovr.OffsetHigh:=0;

ReadFileEx(fil,@offset,4,@ovr,nil);

ovr.Offset:=8;
ReadFileEx(fil,@files,4,@ovr,nil);




ovr.Offset:=$C;
for I := 1 to files do
  begin
  new(gs);
  ReadFileEx(fil,@gs,sizeof(tp),@ovr,nil);
  ovr.Offset:=ovr.Offset+sizeof(tp);
  list.Add(gs);
  end;


                    }



  { TODO -oUser -cConsole Main : Insert code here }
end.
