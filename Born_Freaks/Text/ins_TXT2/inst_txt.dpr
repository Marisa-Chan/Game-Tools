program inst_txt;

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
  offset2:cardinal;
  size:cardinal;
  end;

var

pck:string;
pck2:string;
pck3:string;
pck4:string;
pck5:string;

br:cardinal;
ss:Cardinal;
ovr:OVERLAPPED;

offset,offset2:cardinal;

jj:cardinal;

bzz,bzz2:cardinal;

list:TList;

i,j,k,size:Cardinal;

buff:pointer;


dir,srcdir,dstdir:string;
fil:TextFile;

bf:pdat;


entrs:cardinal;
tmp:pmelopan;
ptmpst:Pchar;

leni:integer;

conc:cardinal;


begin

dir:=ExtractFilePath(ParamStr(0));

if not(DirectoryExists(dir+'src')) then exit;

if not(DirectoryExists(dir+'dst')) then CreateDir(dir+'dst');

srcdir:=dir+'src\';
dstdir:=dir+'dst\';

AssignFile(fil,dir+'strings.txt');




Reset(fil);

//ScanDir(dir+'src\','',false);


while True do

begin

if Eof(fil) then break;


readln(fil,pck);



if trim(pck)='{' then
  begin
    readln(fil,pck5);
    pck2:=srcdir+pck5;
    br:=CreateFile(@pck2[1],GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,ss);

    size:=GetFileSize(br,@ss);
    buff:=GetMemory(size);
    ovr.OffsetHigh:=0;
    ovr.Offset:=0;
    readfileex(br,buff,size,@ovr,nil);
    closehandle(br);

    readln(fil,pck3);
    entrs:=StrToInt(pck3);
    readln(fil,pck3);
    offset:=StrToInt(pck3);
    readln(fil,pck3);
    offset2:=StrToInt(pck3);

    list:=TList.Create;

    for I := 1 to entrs do
    begin
    new(tmp);
    list.Add(tmp);
    readln(fil,pck3);
    tmp.txt:=pck3;
    readln(fil,pck3);
    tmp.offset:=strtoint(pck3);
    readln(fil,pck3);
    tmp.size:=strtoint(pck3);
    readln(fil,pck3);
    tmp.id:=strtoint(pck3);
    end;
    readln(fil,pck3);

    bzz:=0;
    bzz2:=0;

    pck2:=dstdir+pck5;
    br:=CreateFile(@pck2[1],GENERIC_WRITE,FILE_SHARE_WRITE,nil,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,ss);

    for I := 0 to List.Count - 1 do
      begin
      if bzz<(pmelopan(list.items[i]).offset) then
        begin
          ovr.Offset:=bzz2;
          WriteFileEx(br,pointer(cardinal(buff)+bzz),pmelopan(list.items[i]).offset-bzz,ovr,nil);
          bzz2:=bzz2+pmelopan(list.items[i]).offset-bzz;
          bzz:=pmelopan(list.items[i]).offset;
        end;

        pck2:=pmelopan(list.items[i]).txt;
        leni:=length(pck2);
        pck2:=pck2+#0;
        ovr.Offset:=bzz2;
        pmelopan(list.items[i]).offset2:=bzz2;
        writefileex(br,@pck2[1],leni+1,ovr,nil);
        bzz:=bzz+pmelopan(list.items[i]).size;
        bzz2:=bzz2+leni+1;

        if i=(list.count-1) then
          begin
          ovr.Offset:=bzz2;
          WriteFileEx(br,pointer(cardinal(buff)+bzz),size-bzz,ovr,nil);
         // bzz2:=bzz2+pmelopan(list.items[i]).offset-bzz;
          //bzz:=pmelopan(list.items[i]).offset;
          end;


      end;


      /////////PATCH


      for I := 0 to List.Count - 1 do
      begin
      ovr.Offset:=offset+pmelopan(list.items[i]).id*4;
      jj:=pmelopan(list.items[i]).offset2-offset2;
      WriteFileEx(br,@jj,4,ovr,nil);

      end;

      bzz2:=bzz2-offset2;
      ovr.Offset:=$10;
      WriteFileEx(br,@bzz2,4,ovr,nil);

      ///////////PATCH


      list.Destroy;





    closehandle(br);

    FreeMem(buff); 

  end;


end;





CloseFile(fil);



  { TODO -oUser -cConsole Main : Insert code here }
end.
