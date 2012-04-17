#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/file.h>
#include <fstream>



using namespace std;

struct header
{
   char     magic[16];
   uint32_t size;
   uint32_t count; // May be entry count
   uint32_t start;
};


struct f_entry
{
   char     name[0x20];
   uint32_t offset;
   uint32_t size;
};




void unlzw(uint8_t *dst,uint8_t *src,uint32_t size)
{
uint8_t     lz[0x1000];
uint32_t    lz_pos=0x0fee;
uint32_t    cur=0, d_cur=0, otsk;
uint8_t     bl,mk,i,j,lw,hi,loops;

memset(&lz[0],0,0x1000);

while(cur<size)
    {
    bl=src[cur];
    mk=1;

    for (i=0;i<=7;i++)
        {
        if ((bl & mk)==mk)
            {
            cur++;
            if (cur >= size) break;

            lz[lz_pos]=src[cur];

            dst[d_cur]=src[cur];

            d_cur++;
            lz_pos = (lz_pos+1) & 0xfff;
            }
        else
            {
            cur++;
            if (cur >= size) break;
            lw = src[cur];

            cur++;
            if (cur >= size) break;
            hi = src[cur];

            loops = (hi & 0xf)+2;

            otsk = lw | ((hi & 0xf0)<<4);

                for(j = 0; j <= loops;j++)
                    {
                    lz[lz_pos]=lz[(otsk+j) & 0xfff];
                    dst[d_cur]=lz[(otsk+j) & 0xfff];
                    lz_pos=(lz_pos+1) & 0xfff;
                    d_cur++;
                    }
            };

		mk=mk << 1;

        }

    cur++;
    };

}

void unXor(uint8_t *buf,uint32_t size)
{
    for (uint32_t i=0;i<size;i++)
       buf[i]=(i & 0xFF) ^ buf[i];

}


string ExtractFileName(string st)
{
string      var;
uint32_t    i;


for (i=st.length();i>=1;i--)
    if ((st[i]=='/') || (st[i]=='\\')) break;


var=st.substr(i,st.length()-i);

return var;

}

string ExtractName(string st)
{
string      var;
uint32_t    i;

i=st.find('.');
if (i!=0)
    var=st.substr(0,i);
else
    var=st;

return var;
}

string ExtractPath(string st)
{
string      var;
uint32_t    i;

for (i=st.length();i>=1;i--)
    if ((st[i]=='/') || (st[i]=='\\')) break;

var=st.substr(0,i+1);

return var;
}



int main(int argc, char *argv[])
{
FILE * fil, *fil2;
string st,st2;
void *pkd,*unpkd;
header hh;

uint32_t j;

f_entry *fent;

string dir,path;

void * buff;


if (argc>1)
    {
    for (int i_fil=1;i_fil<argc;i_fil++)
        {

            fil=fopen(argv[i_fil],"rb");

            fread(&hh,sizeof(hh),1,fil);


            pkd=malloc(hh.size);

            unpkd=malloc(hh.count*0x28);

            memset(unpkd,0,hh.count*0x28);

            fread(pkd,hh.size,1,fil); //reads packed header


            unXor((uint8_t *)pkd,hh.size);

            unlzw((uint8_t *)unpkd,(uint8_t *)pkd,hh.size);


            st2=ExtractName(ExtractFileName(argv[i_fil]));

            dir=ExtractPath(argv[0]);

            dir=dir+st2+"/";

            fent=(f_entry *)unpkd;

            //mkdir(dir.c_str(),ALLPERMS); UNIX
            mkdir(dir.c_str());

            for (j=0;j<hh.count;j++)
            {
                buff=malloc(fent[j].size);
                fseek(fil,hh.start+fent[j].offset,SEEK_SET);
                fread(buff,fent[j].size,1,fil);
                st2=dir+fent[j].name;
                fil2=fopen(st2.c_str(),"wb");
                fwrite(buff,fent[j].size,1,fil2);
                fclose(fil2);
                free(buff);
            };


            fclose(fil);
        }
    }






    return 0;
}
