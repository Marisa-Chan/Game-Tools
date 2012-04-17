program CFF_DDS_INS;

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
  txt:pointer;
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

i,j,k,kk,size:Cardinal;

buff,orig:pointer;


dir,srcdir,dstdir:string;
fil:TextFile;

bf:pdat;


entrs:cardinal;
tmp:pmelopan;
ptmpst:Pchar;

leni:integer;

conc:cardinal;


begin

dir:=ParamStr(1);

if (dir[length(dir)]<>'\') or (dir[length(dir)]<>'/') then
  dir:=dir+'\';


dstdir:=leftstr(dir,length(dir)-1)+'.lmd';




AssignFile(fil,dir+'files.txt');


Reset(fil);

//ScanDir(dir+'src\','',false);

pck2:=dir+'dat.tmp';
br:=CreateFile(@pck2[1],GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,ss);

 size:=GetFileSize(br,@ss);
orig:=GetMemory(size);
    ovr.OffsetHigh:=0;
    ovr.Offset:=0;
    readfileex(br,orig,size,@ovr,nil);
    closehandle(br);


//if Eof(fil) then break;


readln(fil,pck);

k:=strtoint(pck);

    list:=TList.Create;

for kk:=0 to k-1 do
  begin
    new(tmp);
    list.Add(tmp);
    readln(fil,pck3);
    readln(fil,pck4);
    readln(fil,pck5);


    pck2:=dir+pck3;

    br:=CreateFile(@pck2[1],GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,ss);

tmp.size:=GetFileSize(br,@ss);
tmp.txt:=GetMemory(tmp.size);
    ovr.OffsetHigh:=0;
    ovr.Offset:=0;
    readfileex(br,tmp.txt,tmp.size,@ovr,nil);
    closehandle(br);

tmp.offset:=strtoint(pck4);
tmp.offset2:=strtoint(pck5);



    end;

    bzz:=0;
    bzz2:=0;

    pck2:=dstdir;
    br:=CreateFile(@pck2[1],GENERIC_WRITE,FILE_SHARE_WRITE,nil,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,ss);

    for I := 0 to List.Count - 1 do
      begin
      if bzz<(pmelopan(list.items[i]).offset) then
        begin
          ovr.Offset:=bzz2;
          WriteFileEx(br,pointer(cardinal(orig)+bzz),pmelopan(list.items[i]).offset-bzz,ovr,nil);
          bzz2:=bzz2+pmelopan(list.items[i]).offset-bzz;
          bzz:=pmelopan(list.items[i]).offset;
        end;

        ovr.Offset:=bzz2-4;
        writefileex(br,@pmelopan(list.items[i]).size,4,ovr,nil);

       // pck2:=pmelopan(list.items[i]).txt;
        leni:=pmelopan(list.items[i]).size;
        //pck2:=pck2+#0;
        ovr.Offset:=bzz2;
        //pmelopan(list.items[i]).offset2:=bzz2;
        writefileex(br,pmelopan(list.items[i]).txt,leni,ovr,nil);

        Dispose(pmelopan(list.items[i]).txt);
        bzz:=bzz+pmelopan(list.items[i]).offset2;
        bzz2:=bzz2+leni;

        if i=(list.count-1) then
          begin
          ovr.Offset:=bzz2;
          WriteFileEx(br,pointer(cardinal(orig)+bzz),size-bzz,ovr,nil);
         // bzz2:=bzz2+pmelopan(list.items[i]).offset-bzz;
          //bzz:=pmelopan(list.items[i]).offset;
          end;


      end;



      list.Destroy;





    closehandle(br);

    FreeMem(orig);


CloseFile(fil);



  { TODO -oUser -cConsole Main : Insert code here }
end.
