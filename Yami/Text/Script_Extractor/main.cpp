#include <stdio.h>
#include <iostream>
#include <stdlib.h>
#include <string.h>
#include <sys/file.h>
#include <sys/types.h>
#include <dirent.h>
#include <libgen.h>


using namespace std;

struct scw_header
{
    char        ident[0x10]; //SCW for GswSys
    uint32_t    magic1; //0x03000003
    uint32_t    magic2; //0xFFFFFFFF
    uint32_t    pkd_size;
    uint32_t    unpkd_size;
    uint32_t    unk1;
    uint32_t    unk2;
    uint32_t    cnt1;
    uint32_t    cnt2;//text count
    uint32_t    cnt3;
    uint32_t    scriptsize;//think it`s real script
    uint32_t    txt1_size;
    uint32_t    txt2_size;
    char        unk[0x48];
    char        descr[0x40];
};



DIR *dirr;
struct dirent *dp;




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

if (i!=-1)
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
FILE *fil;
FILE *fil2;
string st,st2;
void *pkd,*unpkd;
scw_header hh;

uint32_t ii;
uint32_t gg;
char * nuaf;

uint32_t j;

char *stroka;

string dir,path;

void * buff;
dir=ExtractPath(argv[0])+"src/";
path=ExtractPath(argv[0])+"txt/";

mkdir(path.c_str());

dirr = opendir (dir.c_str());
dp = readdir(dirr);
    while(dp != NULL)
        {
            if ((strcmp(dp->d_name,".")!=0) && (strcmp(dp->d_name,"..")!=0))
            {

            st2=dir+dp->d_name;

            fil=fopen(st2.c_str(),"rb");

            memset(&hh,0,sizeof(hh));


            fread(&hh,sizeof(hh),1,fil);


            cout<<hh.ident;

            pkd=malloc(hh.pkd_size);

            unpkd=malloc(hh.unpkd_size);

            memset(unpkd,0,hh.unpkd_size);

            fread(pkd,hh.pkd_size,1,fil); //reads packed script


            unXor((uint8_t *)pkd,hh.pkd_size);

            unlzw((uint8_t *)unpkd,(uint8_t *)pkd,hh.pkd_size);


            st2=ExtractName(ExtractFileName(st2));



            /*st=dir+st2+".swc";


                fil2=fopen(st.c_str(),"wb");
                fwrite(unpkd,hh.unpkd_size,1,fil2);
                fclose(fil2);*/

            st=path+st2+".txt";
                fil2=fopen(st.c_str(),"wb");

            for (ii=0; ii<hh.cnt2;ii++)
                {
                    nuaf=&((char *)unpkd)[((hh.cnt1 +hh.cnt2+hh.cnt3)<< 4)+hh.scriptsize+((uint32_t *)unpkd)[(hh.cnt1+ii) << 2]];
                    stroka=(char *)malloc(strlen(nuaf)*2);
                    memset(stroka,0,strlen(nuaf)*2);
                    j=0;
                    for (int jj=0;jj<strlen(nuaf);jj++)
                        {
                            if (nuaf[jj]!=0x0A)
                                stroka[j]=nuaf[jj];
                            else
                                {
                                    stroka[j]='\\';
                                    j++;
                                    stroka[j]='n';
                                }
                            j++;

                        }

                    fprintf(fil2,"%s\n",stroka);
                    free(stroka);
                };
                fclose(fil2);






            fclose(fil);

            free(unpkd);
            free(pkd);


            }

            dp = readdir(dirr);

    }

closedir(dirr);



    return 0;
}
