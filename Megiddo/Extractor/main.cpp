#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/file.h>
#include <fstream>



using namespace std;

struct header
{
   uint32_t magic;//0x43414C
   uint32_t count; // May be entry count
};


struct f_entry
{
   char     name[0x1F];
   uint8_t  unpacked; //0- unpacked
   uint32_t size;
   uint32_t offset;
};

void unNot(uint8_t *buf,uint32_t size)
{
    for (uint32_t i=0;i<size;i++)
       buf[i]=~buf[i];

}

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


            pkd=malloc(hh.count*0x28);

            fread(pkd,hh.count*0x28,1,fil); //reads packed header



            st2=ExtractName(ExtractFileName(argv[i_fil]));

            dir=ExtractPath(argv[0]);

            dir=dir+st2+"/";

            fent=(f_entry *)pkd;

            //
            #ifdef WIN32
            mkdir(dir.c_str());
            #else
            mkdir(dir.c_str(),ALLPERMS);
            #endif

            for (j=0;j<hh.count;j++)
            {
                buff=malloc(fent[j].size);
                fseek(fil,fent[j].offset,SEEK_SET);
                fread(buff,fent[j].size,1,fil);
                unNot((uint8_t *)&(fent[j].name[0]),strlen(fent[j].name));
                st2=dir+fent[j].name;

                if (fent[j].unpacked==0)
                    {
                    fil2=fopen(st2.c_str(),"wb");
                    fwrite(buff,fent[j].size,1,fil2);
                    fclose(fil2);
                    free(buff);
                    }
                else
                    {
                    unpkd=malloc(((uint32_t *)buff)[0]);
                    memset(unpkd,0,((uint32_t *)buff)[0]);

                    unlzw((uint8_t *)unpkd,(uint8_t *)&(((uint32_t *)buff)[1]),fent[j].size-4);

                    fil2=fopen(st2.c_str(),"wb");
                    fwrite(unpkd,((uint32_t *)buff)[0],1,fil2);
                    fclose(fil2);
                    free(buff);
                    free(unpkd);
                    }



            };


            fclose(fil);
        }
    }






    return 0;
}
