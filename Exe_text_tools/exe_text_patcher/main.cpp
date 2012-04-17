#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <string.h>
#include <inttypes.h>

using namespace std;


struct section
{
    char        ObjectName[8];
    uint32_t    VirtualSize;
    uint32_t    SectionRVA;
    uint32_t    PhysicalSize;
    uint32_t    PhysicalOffset;
    uint32_t    res1;
    uint32_t    res2;
    uint32_t    res3;
    uint32_t    ObjectFlags;
};



void        *exebuff;
uint32_t    exesize,sect_num;
section     *exesec;


void * get_buff_offset(uint32_t rva)
{
    uint32_t realrva;

    realrva=rva-0x00400000;
    for (int i=0; i<sect_num;i++)
    {
        if ((exesec[i].SectionRVA<=realrva) && ((exesec[i].SectionRVA+exesec[i].VirtualSize)>=realrva ))
        {
            return (void *) &(((uint8_t *)exebuff)[exesec[i].PhysicalOffset+(realrva-exesec[i].SectionRVA)]);
        }

    }

    return NULL;
}







int main(int argc, char *argv[])
{

    FILE        *exefile, *newexefile, *textfile;
    uint32_t    peoff;
    void        *p_pe;
    uint8_t     *realinbuff;

    char        buff[1024];

    uint32_t    startaddr,inbuffoff,nowpos;



    exefile=fopen("exe.exe","rb");
    textfile=fopen("texts.txt","rb");
    newexefile=fopen("newexe.exe","wb");

    fseek(exefile,0,SEEK_END);
    exesize=ftell(exefile);
    fseek(exefile,0,SEEK_SET);

    exebuff=malloc(exesize);

    fread(exebuff,exesize,1,exefile);
    fclose(exefile);

    peoff=((uint32_t *)exebuff)[0xF];//0x3c - offset to pe header
    p_pe=&((uint8_t *)exebuff)[peoff];
    sect_num=((uint16_t *)p_pe)[3]; //0x06 - sections number
    exesec=(section *)&((uint8_t *)p_pe)[((uint16_t *)p_pe)[0xA] + 0x18]; //from magic + NT Header Size

    memset(buff,0,1024);
    fgets(buff,1024,textfile);
    sscanf(buff,"%08X",&startaddr);

    realinbuff=(uint8_t *)get_buff_offset(startaddr);
    inbuffoff=0;




    while (!feof(textfile))
    {
        memset(buff,0,1024);
        fgets(buff,1024,textfile);


        int z;
        int zz;

        zz=strlen(buff);
        z=zz;



        if (z>8)
        {


            uint32_t    straddr,realstraddr;

            for (int i=z;i>0;i--)
            {
                z=0;
                if (buff[i]=='<')
                {
                    z=i;
                    break;
                };
            }



            if (z>1)
            {
            nowpos=inbuffoff;
                for (int i=0;i<z;i++)
                {
                    if ((buff[i]=='\\') && (buff[i+1]=='n'))
                        {
                            buff[i]=0xA;
                            buff[i+1]=0xD;
                        }
                realinbuff[inbuffoff]=buff[i];
                inbuffoff++;
                }
                realinbuff[inbuffoff]=0x00;
                inbuffoff++;
                realinbuff[inbuffoff]=0x00;
                inbuffoff++;






                for (int i=z;i<zz;i++)
                {

                    if (buff[i]=='o')
                    {
                        sscanf(&buff[i+1],"%08X",&straddr);
                        realstraddr=(uint32_t)get_buff_offset(straddr);
                        *((uint32_t *)realstraddr)=startaddr+nowpos;
                        i+=7;
                    }

                    if (buff[i]=='m')
                    {
                        sscanf(&buff[i+1],"%08X",&straddr);
                        realstraddr=(uint32_t)get_buff_offset(straddr)+1;
                        *((uint32_t *)realstraddr)=startaddr+nowpos;
                        i+=8;
                    }

                    if (buff[i]=='p')
                    {
                        sscanf(&buff[i+1],"%08X",&straddr);
                        realstraddr=(uint32_t)get_buff_offset(straddr)+1;
                        *((uint32_t *)realstraddr)=startaddr+nowpos;
                        i+=8;
                    }

                    if (buff[i]=='r')
                    {
                        sscanf(&buff[i+1],"%08X",&straddr);
                        realstraddr=(uint32_t)get_buff_offset(straddr)+3;
                        *((uint32_t *)realstraddr)=startaddr+nowpos;
                        i+=8;
                    }
                }

            }
        }
    }


    fwrite(exebuff,exesize,1,newexefile);

    fclose(newexefile);
    fclose(textfile);




    return 0;
}
