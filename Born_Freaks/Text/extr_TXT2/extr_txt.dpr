program extr_txt;

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
  pdat=^dat;
  dat=array [0..6] of char;

  pmelopan=^melopan;
  melopan=record
  txt:string;
  id:cardinal;
  offset:cardinal;
  size:cardinal;
  end;

var

pck:string;

br:cardinal;
ss:Cardinal;
ovr:OVERLAPPED;

offset,offset2:cardinal;

col:cardinal;

jj:cardinal;


list:TList;

i,j,k,size:Cardinal;

buff:pointer;


dir,srcdir,dstdir:string;
fil:TextFile;

bf:pdat;


entrs,entrs2:cardinal;
tmp:pmelopan;
ptmpst:Pchar;


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

     pck:=StartDir+searchrec.name;



     br:=CreateFile(@pck[1],GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,ss);

     size:=GetFileSize(br,@ss);
     buff:=GetMemory(size);

     ovr.OffsetHigh:=0;
     ovr.Offset:=0;
     ReadFileEx(br,buff,size,@ovr,nil);
     closehandle(br);

     entrs:=0;
     entrs2:=0;
 //    tmpst:='';
 list:=TList.Create;

 offset:=pcardinal(cardinal(buff)+8)^+$28;
 col:=(pcardinal(cardinal(buff)+$C)^-4) div 4;



 jj:=0;

 while True do
 begin

 if pcardinal(cardinal(buff)+offset+jj)^=0 then break;

 if (pbyte(cardinal(buff)+offset+jj+3)^<>0) and (pbyte(cardinal(buff)+offset+jj)^=0) then break;
 jj:=jj+4;
 entrs:=entrs+1;
 end;
 offset2:=offset+jj;

 
 


 if entrs>0 then 
 for i := 0 to entrs-1 do
  begin
  jj:=pcardinal(cardinal(buff)+offset+i*4)^+offset2;
    for j := jj to size - 1 do
              if (pbyte(j+cardinal(buff)))^=0 then break;

   ptmpst:=GetMemory(j-jj+1);
          ZeroMemory(ptmpst,j-jj+1);
          CopyMemory(ptmpst,pointer(jj+cardinal(buff)),j-jj);

   if AnsiLeftStr(ptmpst,4)<>'grpo' then
   begin
   new(tmp);
          tmp.txt:=ptmpst;
          tmp.offset:=jj;
          tmp.size:=j-jj+1;
          tmp.id:=i;
          list.Add(tmp);
          entrs2:=entrs2+1;
    end;
          freemem(ptmpst);
  end;
   




    freemem(buff);

     if entrs2>0 then
      begin
        Writeln(fil,'{');
        writeln(fil,searchrec.name);
        writeln(fil,inttostr(entrs2));
        writeln(fil,inttostr(offset));
        writeln(fil,inttostr(offset2));
        for k := 0 to List.Count - 1 do
           begin
           writeln(fil,pmelopan(list.Items[k]).txt);
           writeln(fil,inttostr(pmelopan(list.Items[k]).offset));
           writeln(fil,inttostr(pmelopan(list.Items[k]).size));
           writeln(fil,inttostr(pmelopan(list.Items[k]).id));
           end;
        writeln(fil,'}');
        writeln(fil,' ');
        writeln(fil,' ');



      for k := List.Count - 1 downto 0 do
        begin
        Dispose(pmelopan(list.Items[k]));
        end;

      end;

 list.Destroy;

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

dir:=ExtractFilePath(ParamStr(0));

if not(DirectoryExists(dir+'src')) then exit;

if not(DirectoryExists(dir+'dst')) then CreateDir(dir+'dst');

srcdir:=dir+'src\';
dstdir:=dir+'dst\';

AssignFile(fil,dir+'strings.txt');




Rewrite(fil);

ScanDir(dir+'src\','',false);

CloseFile(fil);



  { TODO -oUser -cConsole Main : Insert code here }
end.
