#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include <string.h>

unsigned char vram[1024*512*2];

uint8_t color[32] = {  0,  8, 16, 24,
                      32, 40, 48, 56,
                      65, 73, 81, 89,
                     100,108,118,125,
                     135,143,152,162,
                     170,178,186,194,
                     202,210,217,225,
                     232,240,246,255};


void LoadTim(void *addr)
{

    struct localtim
    {
        int32_t size;
        int16_t x;
        int16_t y;
        int16_t w;
        int16_t h;
    } __attribute__((__packed__));

    int32_t startpos=8;

    int8_t *data = (int8_t *)addr;

    int8_t cbytes = data[4] & 0x3;

    if ((data[4] & 0x8) == 0x8)
    {
        int32_t *data2 = (int32_t *)addr;
        startpos = 8+data2[2];
    }

    localtim *head = (localtim *)(data + startpos);
    startpos += 12; //sizeof(localtim)

    int32_t posit=head->x*2 + head->y * 2048;

    int32_t readpos = startpos;

    for (int32_t j=0; j < head->h; j++)
    {
        for (int32_t i=0; i < (head->w*cbytes); i++)
        {
            vram[i+posit] = data[readpos];
            readpos++;
        }
        posit += 2048;
    }
}

uint8_t GetTim(int32_t px, int32_t py, int32_t x, int32_t y)
{
    int32_t index = px*128+py*256*1024*2+x+y*1024*2;
    if ((index >= 0) && (index < 1024*512*2))
        return vram[index];
    return 0;
}

void ToImages(void *addr,int32_t cnt, const char *filemask)
{
    int32_t ktmp;
    uint32_t pal[256];

    int32_t *dat = (int32_t *) addr;

    for (int32_t i=0; i<cnt; i++)
    {
        uint32_t packet = dat[i];

        int32_t palxx = ((packet >> 0x10) & 0x3F) * 16 * 2;
        int32_t palyy = packet >> (16+6);

        int32_t texX = packet & 0xF;
        int32_t texY = (packet & 0x10) >> 4;

        for (int32_t j=0; j<256; j++)
        {
            pal[j]=0;
            ktmp = GetTim(0,0,palxx+j*2,palyy);
            ktmp |= GetTim(0,0,palxx+j*2+1,palyy) << 8;

            int32_t r = color[ktmp & 0x1f] & 0xFF;
            int32_t g = color[(ktmp >> 5) & 0x1f] & 0xFF;
            int32_t b = color[(ktmp >> 10) & 0x1f] & 0xFF;

            pal[j] = (r << 16) | (g << 8) | (b << 0);

            if ((ktmp & 0x8000) == 0x8000)
                pal[j] |= 0xFF000000;

        }

        int32_t *texdata = (int32_t *)malloc(256*256*4);

        for (int32_t ty=0; ty< 256; ty++)
            for (int32_t tx=0; tx< 256; tx++)
                texdata[tx+ty*256] = pal[GetTim(texX,texY,tx,ty) & 0xFF];


        char buf[1024];

        sprintf(buf,filemask,i);

        FILE *f = fopen(buf,"wb");

        uint32_t tmp = 0x20000;
        fwrite(&tmp,4,1,f);
        tmp = 0;
        fwrite(&tmp,4,1,f);
        fwrite(&tmp,4,1,f);
        tmp = 0x01000100;
        fwrite(&tmp,4,1,f);

        tmp = 0x2020;

        fwrite(&tmp,2,1,f);
        fwrite(texdata,256*4,256,f);

        fclose(f);

        free(texdata);

    }

}

void LoadTims(FILE *f)
{

    int8_t bt;

    fread(&bt,1,1,f);
    if (bt != 4)
        exit(100);

    int8_t num,pad;

    fread(&num,1,1,f);

    int16_t na;
    fread(&na,2,1,f);

    pad = num+1;
    pad&=0xfE;

    fseek(f,ftell(f) + pad*2,SEEK_SET);

    for (int32_t i=0; i<num; i++)
    {
        int32_t fif = ftell(f);
        int32_t tim_off;
        fread(&tim_off,4,1,f);
        int32_t fif2 = ftell(f);
        int32_t tim_next;
        fread(&tim_next,4,1,f);
        tim_next+=4;
        fseek(f,fif + tim_off,SEEK_SET);

        void *tim = malloc(tim_next - tim_off);
        fread(tim,tim_next - tim_off,1,f);

        LoadTim(tim);

        free(tim);

        fseek(f,fif2,SEEK_SET);
    }


}


int main(int argc, char **argv)
{
    memset(vram,0x0,1024*2*512);

    int32_t param=0;

    char *filename;

    filename = argv[1];

    for (int32_t jj=strlen(filename)-1;jj>0;jj--)
        if (filename[jj] == '/' || filename[jj]=='\\')
        {
            filename = filename +jj+1;
            break;
        }

    char fname[256];

    sprintf(fname,"%s.obj",filename);

    FILE *f=fopen(argv[1],"rb");
    FILE *fobj=fopen(fname,"wb");

    fseek(f,1, SEEK_SET);

    int8_t db;

    fread(&db,1,1,f);

    fseek(f,4,SEEK_SET);

    for (int8_t i= 0; i<db; i++)
    {
        int32_t flpos = ftell(f);
        int32_t pos = 0;
        int8_t type = 0;
        fread(&pos,3,1,f);
        fread(&type,1,1,f);

        if (type == 0xC)
            param = 0x10 + flpos + pos;

        if (type == 0x4)
        {
            fseek(f, flpos + pos, SEEK_SET);
            LoadTims(f);
            fseek(f, flpos + 4, SEEK_SET);
        }

    }

    fseek(f,param+4,SEEK_SET);

    int16_t objs;
    fread(&objs,2,1,f);

    int16_t unk1;
    fread(&unk1,2,1,f);

    int16_t imgs;
    fread(&imgs,2,1,f);

    int16_t imgs_off;
    fread(&imgs_off,2,1,f);

    int16_t unk2;
    fread(&unk2,2,1,f);

    int16_t vertOff;
    fread(&vertOff,2,1,f);



    int32_t allverts=0;


    fseek(f,param + imgs_off,SEEK_SET);
    void *mem = malloc(imgs*4);
    fread(mem,imgs,4,f);

    sprintf(fname,"%s_tex%%d.tga",filename);

    ToImages(mem,imgs,fname);
    free(mem);

    sprintf(fname,"%s_mtl.lib",filename);
    FILE *mtl = fopen(fname,"wb");
    for (int32_t i=0; i<imgs; i++)
    {
        fprintf(mtl,"newmtl tex%d\n",i);
        fprintf(mtl,"Ka 1.000 1.000 1.000\nKd 1.000 1.000 1.000\nKs 0.000 0.000 0.000\nd 1.0\nillum 0\n");
        sprintf(fname,"%s_tex%%d.tga",filename);
        fprintf(mtl,"map_Kd %s_tex%d.tga\n",filename,i);
    }
    fclose(mtl);

    int32_t vertpos=vertOff+param;

    int32_t tmptmp = 0x18+param;

    int32_t objvert=0;
    int32_t objcord=0;
    int32_t allcord=0;

    sprintf(fname,"%s_mtl.lib",filename);
    fprintf(fobj,"mtllib %s\n",fname);

    for(int i=0; i<objs; i++)
    {
        fseek(f,tmptmp,SEEK_SET);

        //printf("o obj%d\n",i);

        objvert = allverts;
        objcord = allcord;

        int16_t timp;
        fread(&timp,2,1,f);

        int16_t verts;
        fread(&verts,2,1,f);

        int16_t unk3;
        fread(&unk3,2,1,f);

        int16_t cpl,tmppl,cord;
        fread(&cpl,2,1,f);
        fread(&tmppl,2,1,f);
        fread(&cord,2,1,f);

        int16_t pols,tris;
        fread(&pols,2,1,f);
        fread(&tris,2,1,f);

        tmptmp = ftell(f);

        fseek(f,vertpos,SEEK_SET);
        for (int j=0; j<verts; j++)
        {
            int16_t x,y,z;
            fread(&x,2,1,f);
            fread(&y,2,1,f);
            fread(&z,2,1,f);

            double xx = x/100.0;
            double yy = y/100.0;
            double zz = z/100.0;

            allverts++;

            fprintf(fobj,"v %f %f %f\n",xx,-yy,zz);

        }
        vertpos = ftell(f);


        fseek(f,cpl+0x18+i*16+param,SEEK_SET);

        uint32_t *ccols = (uint32_t *)malloc((pols+tris)*4);
        uint32_t *scols = (uint32_t *)malloc((pols+tris)*4);

        for (int32_t ii=0;ii<pols+tris;ii++)
        {
            uint32_t utmp;
            fread(&utmp,4,1,f);
            ccols[ii] = ((utmp >> 22) & 0x7C ) / 4;
            scols[ii] = utmp >> 29;
        }

        fseek(f,cord+0x18+i*16+param,SEEK_SET);

        for (int32_t jj=0; jj<pols; jj++)
        {
            uint8_t tx,ty;
            fread(&tx,1,1,f);
            fread(&ty,1,1,f);
            fprintf(fobj,"vt %f %f\n",tx/255.0,1.0-ty/255.0);
            allcord++;
            fread(&tx,1,1,f);
            fread(&ty,1,1,f);
            fprintf(fobj,"vt %f %f\n",tx/255.0,1.0-ty/255.0);
            allcord++;
            fread(&tx,1,1,f);
            fread(&ty,1,1,f);
            fprintf(fobj,"vt %f %f\n",tx/255.0,1.0-ty/255.0);
            allcord++;
            fread(&tx,1,1,f);
            fread(&ty,1,1,f);
            fprintf(fobj,"vt %f %f\n",tx/255.0,1.0-ty/255.0);
            allcord++;
        }
        for (int32_t jj=0; jj<tris; jj++)
        {
            uint8_t tx,ty;
            fread(&tx,1,1,f);
            fread(&ty,1,1,f);
            fprintf(fobj,"vt %f %f\n",tx/255.0,1.0-ty/255.0);
            allcord++;
            fread(&tx,1,1,f);
            fread(&ty,1,1,f);
            fprintf(fobj,"vt %f %f\n",tx/255.0,1.0-ty/255.0);
            allcord++;
            fread(&tx,1,1,f);
            fread(&ty,1,1,f);
            fprintf(fobj,"vt %f %f\n",tx/255.0,1.0-ty/255.0);
            allcord++;
        }


        fseek(f,tmppl+0x18+i*16+param,SEEK_SET);

        int32_t cdSee=0;
        uint32_t prevtex=-1;

        for(int j=0; j<pols; j++)
        {
            int16_t t1,t2,t3,t4;
            fread(&t1,2,1,f);
            fread(&t2,2,1,f);
            fread(&t3,2,1,f);
            fread(&t4,2,1,f);

            t1/=4;
            t2/=4;
            t3/=4;
            t4/=4;

            if (prevtex != ccols[cdSee])
            {
                prevtex = ccols[cdSee];
                fprintf(fobj,"usemtl tex%d\n",prevtex);
            }

            /*printf("f %d/%d %d/%d %d/%d %d/%d\n",objvert+t1+1,objcord+1+j*4
                                                ,objvert+t2+1,objcord+2+j*4
                                                ,objvert+t4+1,objcord+4+j*4
                                                ,objvert+t3+1,objcord+3+j*4);*/
            fprintf(fobj,"f %d/%d %d/%d %d/%d\n",objvert+t1+1,objcord+1+j*4
                                          ,objvert+t2+1,objcord+2+j*4
                                          ,objvert+t3+1,objcord+3+j*4);

            fprintf(fobj,"f %d/%d %d/%d %d/%d\n",objvert+t4+1,objcord+4+j*4
                                          ,objvert+t3+1,objcord+3+j*4
                                          ,objvert+t2+1,objcord+2+j*4);

            cdSee++;
        }

        for(int j=0; j<tris; j++)
        {
            int16_t t1,t2,t3;
            fread(&t1,2,1,f);
            fread(&t2,2,1,f);
            fread(&t3,2,1,f);

            if (prevtex != ccols[cdSee])
            {
                prevtex = ccols[cdSee];
                fprintf(fobj,"usemtl tex%d\n",prevtex);
            }

            t1/=4;
            t2/=4;
            t3/=4;
            fprintf(fobj,"f %d/%d %d/%d %d/%d\n",objvert+t1+1,objcord+pols*4+j*3+1
                                          ,objvert+t2+1,objcord+pols*4+j*3+2
                                          ,objvert+t3+1,objcord+pols*4+j*3+3);

            /*printf("f %d/%d %d/%d %d/%d\n",objvert+t1+1,objcord+pols*4+j*3+1
                                          ,objvert+t2+1,objcord+pols*4+j*3+2
                                          ,objvert+t3+1,objcord+pols*4+j*3+3);*/
            cdSee++;
        }

        free(ccols);
        free(scols);

    }


    //  for(int i=0; i<allverts;i++)
    //    printf("f %d %d %d\n",i+1,i+1,i+1);


    fclose(f);
    fclose(fobj);
    return 0;
}
