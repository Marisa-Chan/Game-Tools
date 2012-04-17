#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/file.h>
#include <fstream>
////#include <iconv.h>
//#include <algorithm>



std::wstring StringToWString(const std::string& s);
std::string WStringToString(const std::wstring& s);

std::wstring StringToWString(const std::string& s)
{
std::wstring temp(s.length(),L' ');
std::copy(s.begin(), s.end(), temp.begin());
return temp;
}


std::string WStringToString(const std::wstring& s)
{
std::string temp(s.length(), ' ');
std::copy(s.begin(), s.end(), temp.begin());
return temp;
}




using namespace std;

struct header
{
   uint32_t magic;  //0x43415049 ()
   uint16_t count;
   uint16_t unk; // May be entry count
};


struct f_entry
{
   char     name[0x24];
   uint32_t offset;
   uint32_t size;
};




void unlzw(uint8_t *dst,uint8_t *src,uint32_t size)
{
uint8_t     lz[0x1000];
uint32_t    lz_pos=0x0fee;
uint32_t    cur=0, d_cur=0, otsk;
uint8_t     bl,mk,i,j,lw,hi,loops;

memset(&lz[0],0x20,0x1000);

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

var=st.substr(0,i);

return var;
}


int main(int argc, char *argv[])
{
FILE * fil, *fil2;
string st;
void *pkd,*unpkd;
header hh;

uint32_t j;

f_entry *fent;

string path;
wstring ou;

char    buficv[256];
string  st2,dir;


char *mu1,*mu2;

// iconv_t d;
 size_t fl, tl;

void * buff;


if (argc>1)
    {
    for (int i_fil=1;i_fil<argc;i_fil++)
        {

            fil=fopen(argv[i_fil],"rb");

            fread(&hh,sizeof(hh),1,fil);


            unpkd=malloc(hh.count*0x2C);

            memset(unpkd,0,hh.count*0x2C);

            fread(unpkd,hh.count*0x2C,1,fil); //reads packed header


            dir=ExtractPath(argv[0]);
            st2=ExtractName(ExtractFileName(argv[i_fil]));

            dir=dir+st2+"/";



            fent=(f_entry *)unpkd;

            // UNIX
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



        #ifndef WIN32
            memset(buficv,0,256);
            fl=strlen(fent[j].name);
            tl=256;
     //       d=iconv_open("UTF-8","SHIFT_JIS");
            mu1=&fent[j].name[0];
            mu2=&buficv[0];
         //   iconv(d,(const char **)&mu1,&fl,&mu2,&tl);
        //    iconv_close(d);

            st2=dir+buficv;
        #else
            st2=dir+fent[j].name;
        #endif



            fil2=fopen(st2.c_str(),"wb");


                if (((uint32_t *)buff)[0]==0x314C4549)
                {
                    pkd=malloc(((uint32_t *)buff)[1]);
                    unlzw((uint8_t *)pkd,(uint8_t *)&((uint32_t *)buff)[2],fent[j].size-8);
                    fwrite(pkd,((uint32_t *)buff)[1],1,fil2);
                    free(pkd);
                }
                else
                {
                    fwrite(buff,fent[j].size,1,fil2);
                    cout<<"Wuu"<<endl;
                }
                fclose(fil2);
                free(buff);
            };

            free(unpkd);
            fclose(fil);
        }
    }






    return 0;
}
