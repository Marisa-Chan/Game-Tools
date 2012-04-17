program Project1;

{$APPTYPE CONSOLE}

uses
  windows,
  SysUtils,
  Strutils,
  Dialogs,
  classes;

type
  pheader=^header;
  header=record
  magic:cardinal; //0x584D5044
  offset:cardinal;
  count:cardinal;
  dummy:cardinal;
  end;
  
  pevnt=^evnt;
  evnt=record
  name:array[1..$10] of char;
  pointer:Cardinal;
  params:array[0..3] of byte;
  offset:cardinal;
  size:cardinal;
  end;


  pobjheader=^objheader;
  objheader=record
  o_name:array[1..8] of char;
  o_vsize:cardinal;
  o_vaddr:cardinal;
  o_psize:cardinal;
  o_poff:cardinal;
  o_reserved:array[1..12] of byte;
  o_flags:cardinal;
  end;


var
  brr:header;

  dem_ofs:cardinal=$25000;           //////////////////////////////////////
  unk_num:cardinal=$651CDF43;        ////////////////////////////////////////


fil,s2,fil2,ij,cx,cy:cardinal;
  ovr,ovr2:OVERLAPPED;
  str,str2:string;

  bg:pevnt;

  bl,tb:Byte;

  i,j,k:cardinal;

  dir:string;

  p1,p2:Pointer;


  var1,var2,var3,var4,ss:cardinal;

  size:cardinal;



  peheader_ofs:cardinal;
  pe_obj_count:Word;
  pe_obj:pobjheader;
  pe_buff:pointer;
  pe_max:cardinal;

  exe_buff:pointer;
  var_addr:cardinal;


begin


dir:=ExtractFilePath(ParamStr(0))+'d_phob\';

if not(DirectoryExists(dir)) then

MkDir(dir);

for k := 1 to ParamCount do
begin

ovr.Offset:=0;
ovr.OffsetHigh:=0;
ovr.Internal:=0;
ovr.InternalHigh:=0;

str:=ParamStr(k);



fil:=CreateFile(@str[1],GENERIC_ALL,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,s2);


ovr.Offset:=$3C; //PE Header offset
ReadFileex(fil,@peheader_ofs,4,@ovr,nil);

ovr.Offset:=peheader_ofs+6;   //Num of Objects
ReadFileex(fil,@pe_obj_count,2,@ovr,nil);

pe_buff:=GetMemory(pe_obj_count*sizeof(objheader));

ovr.Offset:=peheader_ofs+$F8;
ReadFileex(fil,pe_buff,pe_obj_count*sizeof(objheader),@ovr,nil);

pe_max:=0;
for I := 0 to pe_obj_count - 1 do                          ///Real Exe Size
  begin
  pe_obj:=pointer(cardinal(pe_buff)+i*sizeof(objheader));
  if (pe_obj.o_psize+pe_obj.o_poff)> pe_max then
      pe_max:=pe_obj.o_psize+pe_obj.o_poff;
  end;

dem_ofs:=pe_max;

exe_buff:=GetMemory(pe_max);
ovr.Offset:=$0;

ReadFileex(fil,exe_buff,pe_max,@ovr,nil);

j:=0;
for I := 0 to pe_max - 1-$2C do                               //finding code
    if (pword(cardinal(exe_buff)+i)^   =$BF0F) and
       (pword(cardinal(exe_buff)+i+7)^ =$BF0F) and
       (pword(cardinal(exe_buff)+i+14)^=$BF0F) and
       (pbyte(cardinal(exe_buff)+i+21)^=$89)   and
       (pword(cardinal(exe_buff)+i+27)^=$B70F) and
       (pbyte(cardinal(exe_buff)+i+34)^=$A3)   and
       (pbyte(cardinal(exe_buff)+i+39)^=$A1)   then
        begin
        j:=1;
        break;
        end;

if j=0 then
  begin
    writeln('Please Find Secret Code Manual and modify source;');
    exit;
  end;

var_addr:=(pcardinal(cardinal(exe_buff)+i+40)^ AND $FFFFFFFF) - $400000;



unk_num:=$FFFFFFFF;

for I := 0 to pe_obj_count - 1 do                          ///Real Exe Size
  begin
  pe_obj:=pointer(cardinal(pe_buff)+i*sizeof(objheader));
  if (pe_obj.o_vaddr<var_addr) and ((pe_obj.o_vaddr+pe_obj.o_vsize)>var_addr) then
    begin
      unk_num:=pcardinal(cardinal(exe_buff)+pe_obj.o_poff+(var_addr-pe_obj.o_vaddr))^;
      break;
    end;
  end;

if unk_num=$FFFFFFFF then
  begin
    writeln('Please Find Secret Code Manual and modify source;');
    exit;
  end;


writeln('Real exe size=0x'+IntToHex(dem_ofs,8));
writeln('Magic number=0x'+IntToHex(unk_num,8));

//  dem_ofs:=$25000;           //////////////////////////////////////  real exe size
//  unk_num:=$651CDF43;        //////////////////////////////////////// Magic number

FreeMem(exe_buff);
FreeMem(pe_buff);


ovr.Offset:=dem_ofs;

ReadFileex(fil,@brr,SizeOf(brr),@ovr,nil);


size:=GetFileSize(fil,@j) - dem_ofs-brr.offset;

p1:=GetMemory(brr.count*$20);
ovr.Offset:=dem_ofs+$10;

ReadFileex(fil,p1,brr.count*$20,@ovr,nil);

var1:=(unk_num shr 16) and $FF;
var2:=(unk_num shr 24) and $FF;

asm
pusha
mov ebx,unk_num;
xor edx,edx
mov edx,var1

movzx ecx, bl;

imul    ecx, edx
mov     eax, 55555556h
imul    ecx
mov     eax, edx
shr     eax, 1Fh
add     eax, edx

xor edx,edx
mov   edx, var2
xor     eax, size
movzx   ecx, bh
and     eax, 0FFh
imul    ecx, edx
mov     var1, eax
mov     eax, 66666667h
imul    ecx
sar     edx, 1
mov     eax, edx
shr     eax, 1Fh
add     eax, edx
xor     eax, size
xor     eax, 0FFFFFFAAh
and     eax, 0FFh
mov     var2, eax

popa
end;




for I := 0 to brr.count-1 do
  begin

  bg:=pointer(cardinal(p1)+i*$20);

  if bg.offset=$AC98DF9 then
    Writeln('aaa');
  

  var3:=(((bg.params[0]+$55) xor bg.params[2]) + var1) and $FF;
  var4:=(((bg.params[1]+$AA) xor bg.params[3]) + var2) and $FF;


  bl:=0;

  ovr.Offset:=dem_ofs+brr.offset+bg.offset;
  p2:=GetMemory(bg.size);

  ReadFileEx(fil,p2,bg.size,@ovr,nil);

  for j := 0 to bg.size - 1 do
    begin
      tb:=pbyte(cardinal(p2)+j)^;
      tb:=tb-var4;
      tb:=tb xor var3;
      bl:=bl+tb;
      pbyte(cardinal(p2)+j)^:=bl;

    end;


  str2:=dir+bg.name;
  fil2:=CreateFile(@str2[1],GENERIC_WRITE,FILE_SHARE_WRITE,nil,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,ss);

  ovr.Offset:=0;

  WriteFileex(fil2,p2,bg.size,ovr,nil);

  freemem(p2);
  closehandle(fil2);


  end;
  





Closehandle(fil);


end;

  { TODO -oUser -cConsole Main : Insert code here }
end.
