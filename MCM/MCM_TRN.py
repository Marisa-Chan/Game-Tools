import sys
import os
import io
import struct
from PIL import Image as pimg


class Color:
	r = 0
	g = 0
	b = 0
	a = 0
	
class TexFmt:
	ID = 0
	fmt = 0
	bpp = 0 #bytes per pixel
	Compressed = False #compressed
	
	def __init__(self, i, f, b, c):
		self.ID = i
		self.fmt = f
		self.bpp = b
		self.Compressed = c


TexTypes = (TexFmt(0, 0, 0, 0),
			TexFmt(1, 888, 3, 0),
			TexFmt(2, 555, 2, 0),
			TexFmt(3, 565, 2, 0),
			TexFmt(4, 8, 1, 0),
			TexFmt(5, 3, 3, 1),
			TexFmt(6, 8, 1, 1),
			TexFmt(7, 555, 2, 1),
			TexFmt(8, 565, 2, 1),
			TexFmt(9, 888, 3, 1),
			TexFmt(10, 1555, 2, 1),
			TexFmt(11, 4444, 2, 1),
			TexFmt(12, 8888, 4, 1),
			TexFmt(13, 1555, 2, 0),
			TexFmt(14, 4444, 2, 0),
			TexFmt(15, 8888, 4, 0) )	

def i4(f): #read 4 bytes integer
	return int.from_bytes(f.read(4), byteorder="little")
	
def i2(f): #read 2 bytes integer
	return int.from_bytes(f.read(2), byteorder="little")

def i1(f): #read 1 byte integer
	return f.read(1)[0]

def f4(f): #read float
	return struct.unpack('f', f.read(4))[0]


def MakeImage(data, w, h, fmt, pal):
	img = pimg.new('RGBA', (w,h))
	pix = img.load()

	off = 0
	if (fmt.fmt != 8):
		print("Make color parser for {:d}!".format(fmt.fmt))
	for y in range(h):
		for x in range(w):
			if (fmt.fmt == 8):
				cl = pal[ data[off] ]
				
				pix[x, y] = (cl.r, cl.g, cl.b, cl.a)
				
				off += 1
			else:
				pass
	return img
		
	

	
class BitString:
	buf = None
	pos = 0
	rd = 0
	uint = 0
	rmask = (0,1,      3,        7,         0xf,  
	         0x1f,     0x3f,     0x7f,      0xff,
			 0x1ff,    0x3ff,    0x7ff,     0xfff,
			 0x1fff,   0x3fff,   0x7fff,    0xffff,
			 0x1ffff,  0x3ffff,  0x7ffff,   0xfffff,
			 0x1fffff, 0x3fffff, 0x7fffff,  0xffffff,
			 0x1ffffff,0x3ffffff,0x7ffffff, 0xfffffff,
			 0x1fffffff,0x3fffffff,0x7fffffff, 0xffffffff)
	
	def init(self, buf):
		self.rd = 0
		self.pos = 0
		self.uint = 0
		self.buf = bytearray(buf)
		pad = len(self.buf) & 3
		if pad:
			self.buf += bytearray(pad)
		self.prepNext()
	
	def prepNext(self):
		self.uint = int.from_bytes(self.buf[ self.pos : self.pos + 4 ], byteorder="big")
		self.pos += 4
	
	def read(self, num):
		self.rd += num
		if (self.rd < 0x20):
			return self.rmask[num] & (self.uint >> (0x20 - (self.rd & 0x1f)))
		else:
			self.rd += -0x20
			t = self.rmask[num] & (self.uint << (self.rd & 0x1f))
			self.prepNext()
			if self.rd:
				return  t | (self.uint >> (0x20 - (self.rd & 0x1f)))
			else:
				return t

def Decompress(buf, num):
	out = bytearray()
	bs = BitString()
	bs.init(buf)
	bs.read(32)
	
	f18 = list()
	for i in range(256):
		f18.append( [0] * 0x200)
	
	f40 = bytearray(4096)
		
	while True:
		f14 = 9
		f38 = 0x103
		f10 = 0x1ff
		
		t = bs.read(f14)
		uvar4 = t
		if (t == 0x100):
			break
		out.append( t & 0xFF )
		while True:
			t2 = bs.read(f14)
			if t2 == 0x100:
				return out
			if t2 == 0x102:
				break
			if t2 == 0x101:
				f14 += 1
			else:
				i = 0
				if t2 < f38:
					i = 0
					uvar4 = t2
					while (uvar4 > 0xFF):
						f40[i] = f18[ (uvar4 & 0xffffff3f) >> 6 ][ (uvar4 & 0xff) * 2 + 1 ] & 0xFF
						uvar4 = f18[ (uvar4 & 0xffffff3f) >> 6 ][ (uvar4 & 0xff) * 2 ]
						i += 1						
				else:
					f40[0] = uvar4 & 0xFF
					i = 1
					uvar4 = t
					while (uvar4 > 0xFF):
						f40[i] = f18[ (uvar4 & 0xffffff3f) >> 6 ][ (uvar4 & 0xff) * 2 + 1 ] & 0xFF
						uvar4 = f18[ (uvar4 & 0xffffff3f) >> 6 ][ (uvar4 & 0xff) * 2 ]
						i += 1
				
				uvar4 &= 0xFF
				f40[i] = uvar4
				
				while i >= 0:
					out.append(f40[i])
					i -= 1
				f18[ (f38 & 0xffffff3f) >> 6 ][ (f38 & 0xff) * 2 ] = t
				f18[ (f38 & 0xffffff3f) >> 6 ][ (f38 & 0xff) * 2 + 1] = uvar4
				f38 += 1
				t = t2
		
	return out

class Chunk1:
	hmap = None
	f2 = None #unknown
	f3 = None #unknown

class HVtx:
	unk = 0
	h = 0
	nx = 0.0
	ny = 0.0
	nz = 0.0

def ReadChunk1(f, version):
	t = Chunk1()
	
	c = i4(f)
	d = i4(f)
	if c < d:
		t.f2 = Decompress(f.read( c ), 0x200)
	else:
		t.f2 = f.read( d )
	
	c = i4(f)
	d = i4(f)
	if c < d:
		t.f3 = Decompress(f.read( c ), 0x244)
	else:
		t.f3 = f.read( d )
	
	c = i4(f)
	d = i4(f)
	
	thmap = None
	if c < d:
		thmap = Decompress(f.read( c ), 0x1210)
	else:
		thmap = f.read( d )
	
	hm = io.BytesIO(thmap) #buffer as stream to use stream read funcs
	
	t.hmap = [None] * (17 * 17)
	
	for i in range(17 * 17):
		h = HVtx()
		h.unk = i2(hm)
		h.h = i2(hm)
		if version == 3:
			if h.h > 0x7FFF:
				h.h = ((h.h - i) + 0x8000) & 0xFFFF
		h.nx = f4(hm)
		h.ny = f4(hm)
		h.nz = f4(hm)
		t.hmap[i] = h		
	return t


		
class ColorMapper:
	firstColor = None
	colorCount = None
	lastColor = 0
	lastColor2 = 0
	f_714 = None #Unknown
	f_8714 = None #Unknown
	colors = None
	tp = None
	
	
def ReadColorMapper(f):
	c = ColorMapper()
	c.lastColor = 0
	c.lastColor2 = 0
	c.firstColor = i4(f)
	c.colorCount = i4(f)
	c.tp = i4(f)
	
	if (c.tp == 0):
		c.colors = f.read(0x300)
		c.f_714 = f.read(0x8000)
		c.f_8714 = f.read(0x10000)
	else:
		t = i4(f)
		if t == 0x300:
			c.colors = f.read(0x300)
		else:
			c.colors = Decompress(f.read(t), 0x300)
		
		t = i4(f)
		if t == 0x8000:
			c.f_714 = f.read(0x8000)
		else:
			c.f_714 = Decompress(f.read( t ), 0x8000)
			
		t = i4(f)
		if t == 0x10000:
			c.f_8714 = f.read(0x10000)
		else:
			c.f_8714 = Decompress(f.read( t ), 0x10000)
	
	if c.colorCount != 0x100:
		c.lastColor = c.firstColor + c.colorCount
		c.colors[ c.lastColor * 3 ] = 0xFF
		c.colors[ c.lastColor * 3 + 1 ] = 0
		c.colors[ c.lastColor * 3 + 2 ] = 0xFF
		c.lastColor2 = c.lastColor
		c.colorCount += 1
		
	return c


class Grid:
	H1 = 0.0
	H2 = 0.0
	f_14 = 0
	f_18 = 0
	f_1c = 0
	f_20 = 0
	shift = 0
	x = 0
	z = 0
	seqID = 0
	offset = 0
	chunkID = 0
	textureId = 0
	texmapping = 0
	f_4c = 0
	nodes = None

level = 0
def ReadGrid(f, version):
	global level 
	g = Grid()
	g.H1 = f4(f)
	g.H2 = f4(f)
	if version == 3:
		g.H2 *= 0.001
	g.f_14 = i4(f)
	g.f_18 = i4(f)
	g.f_1c = i4(f)
	g.f_20 = i4(f)
	g.shift = i4(f) 
	g.x = i4(f)
	g.z = i4(f)
	g.seqID = i4(f)
	g.chunkID = i4(f)
	g.textureId = i4(f)
	g.texmapping = i4(f)
	g.f_4c = i4(f)
	g.offset = i4(f)
	g.nodes = None
	
	
	if g.offset:
		level += 1
		g.nodes = [ None ] * 256 # 256
		
		f.seek(g.offset, 0)
		
		offsets = [0] * 256
		for i in range(256): #Read offsets to nodes
			offsets[i] = i4(f)
		
		#Read nodes
		for i in range(256):
			if offsets[i] == 0:
				g.nodes[i] = None
			else:
				f.seek(offsets[i], 0)
				g.nodes[i] = ReadGrid(f, version)
		
		level -= 1
	
	#if level == 2:
		#print(g.f_c, g.f_10, g.chunkID)
	
	
	return g		
		
		
class TRN:
	Palette = None
	version = 0
	datType = 0
	gridType = 0
	cmap = None
	scale = 0.0
	chunks = None
	mainTex = None
	textures = None
	grid = None


def ReadTRN(fname):
	f = open(fname, "rb")

	magic = f.read(4)
	if (magic != b'TRN\x00'):
		print("Invalid magic")
		exit(-1)
		
	T = TRN()
	
	T.version = i4(f) # 2 game, 3 demo
	T.Palette = list()
	
	T.datType = i4(f)
	
	if T.datType != 0:
		T.cmap = ReadColorMapper(f)
		for i in range(256):
			c = Color()
			c.r = T.cmap.colors[i * 3]
			c.g = T.cmap.colors[i * 3 + 1]
			c.b = T.cmap.colors[i * 3 + 2]
			c.a = 255
			T.Palette.append( c )
	
	T.gridType = i4(f)
	
	T.scale = f4(f)
	
	chunkCnt = i4(f)
	
	f.seek( chunkCnt << 2, 1 )
	
	T.chunks = list()
	
	for i in range(chunkCnt):
		T.chunks.append( ReadChunk1( f, T.version ) )
	
	texCount = i4(f)
	mainTex = i4(f)
	if mainTex:
		w = i4(f)
		h = i4(f)
		fmt = i4(f)
		tmp = f.read( w * h * TexTypes[fmt].bpp )
		
		if (TexTypes[fmt].Compressed):
			if (fmt != 5):
				tmp = Decompress(tmp, 0)
		
		T.mainTex = MakeImage(tmp, w, h, TexTypes[fmt], T.Palette)
		#img.save("mainTex.png")
		
		# skip half size tex
		f.seek( (w // 2) * (h // 2) * TexTypes[fmt].bpp, 1 )
		
	T.textures = list()
	
	if texCount:
		w = i4(f)
		h = i4(f)
		fmt = i4(f)
		
		for i in range(texCount):
			tmp = f.read( w * h * TexTypes[fmt].bpp )
			if (TexTypes[fmt].Compressed):
				if (fmt != 5):
					tmp = Decompress(tmp, 0)
		
			T.textures.append( MakeImage(tmp, w, h, TexTypes[fmt], T.Palette) )
			#img.save("tex_{:d}.png".format(i))
		
		# skip half size tex
		f.seek( (w // 2) * (h // 2) * TexTypes[fmt].bpp * texCount, 1 )
	
	T.grid = ReadGrid(f, T.version)
	
	f.close()
	
	return T

class OBJ:
	fh = None
	v = 0
	n = 0
	uv = 0
	tr = 0
	

def ProcessGrid(grid, T, out, matNames, scale, level):
	if level == 2:
		hmap = T.chunks[ grid.chunkID ].hmap
		out.fh.write("usemtl {}\n".format( matNames[grid.textureId] ))
		
		su = 0.0
		sv = 0.0
		stp = 1.0 / 16.0
		
		if grid.textureId != 0xFFFFFFFF:
			(w, h) = T.textures[grid.textureId].size
			if T.gridType == 1:
				su = 1.0 / w
				sv = 1.0 / h
				stp = ((w - 2) / w) / 16.0
			else:
				t = (w - 2) * 0.25
				su = (( grid.seqID & 3) * t  + 1.0) / w
				sv = ((( grid.seqID >> 4 ) & 3) * t + 1.0) / h
				stp = ((w - 2) / w) / 64.0
		
		for i in range(17 * 17):
			dx = i % 17
			dz = i // 17
			out.fh.write("v {:f} {:f} {:f}\n".format( scale * ((grid.x + dx) << grid.shift),
		                                              scale * ((hmap[i].h - grid.H1) * grid.H2 + grid.H1),
			                                          scale * ((grid.z + dz) << grid.shift )) )
			u = su + dx * stp
			v = 1.0 - (sv + dz * stp)
				
			if grid.texmapping == 1:
				v = 1.0 - v
			elif grid.texmapping == 2:
				u = 1.0 - u
			elif grid.texmapping == 3:
				u = 1.0 - u
				v = 1.0 - v
			elif grid.texmapping == 4:
				t = 1.0 - u
				u = v
				v = t
			elif grid.texmapping == 5:
				t = u
				u = v
				v = t
			elif grid.texmapping == 6:
				t = u
				u = 1.0 - v
				v = 1.0 - t
			elif grid.texmapping == 7:
				t = 1.0 - v
				v = u
				u = t
			out.fh.write("vt {:f} {:f}\n".format( u, v ) )
		for j in range(16):
			for i in range(16):
				idx = 1 + out.v + i + j * 17
				out.fh.write("f {0:d}/{0:d} {1:d}/{1:d} {2:d}/{2:d}\n".format(idx, idx + 17, idx + 18 ) )
				out.fh.write("f {0:d}/{0:d} {1:d}/{1:d} {2:d}/{2:d}\n".format(idx, idx + 18, idx + 1 ) )
		out.v += 17 * 17

	if grid.nodes:
		for g in grid.nodes:
			if g != None:
				ProcessGrid(g, T, out, matNames, scale, level + 1)
	

def SaveObj(T, name, scale):
	print("Writing {}".format(name + ".mtl"))
	oobj = open(name + ".mtl", "w") 
	matName = dict()
	if T.mainTex:
		T.mainTex.save("mainTex.png")
		oobj.write("newmtl mainTex\n\
		Kd 1.000000 1.000000 1.000000\n\
		Ka 1.000000 1.000000 1.000000\n\
		Ks 0.000000 0.000000 0.000000\n\
		Ke 0.000000 0.000000 0.000000\n\
		Ni 1.450000\n\
		d 1.000000\n\
		illum 2\n\
		map_Kd mainTex.png\n\n")
		print("Saved mainTex.png")
		
		matName[0xFFFFFFFF] = "mainTex"
	
	i = 0
	for img in T.textures:
		img.save("Tex{:d}.png".format(i))
		oobj.write("newmtl Tex{0:d}\n\
		Kd 1.000000 1.000000 1.000000\n\
		Ka 1.000000 1.000000 1.000000\n\
		Ks 0.000000 0.000000 0.000000\n\
		Ke 0.000000 0.000000 0.000000\n\
		Ni 1.450000\n\
		d 1.000000\n\
		illum 2\n\
		map_Kd Tex{0:d}.png\n\n".format(i))
		matName[i] = "Tex{:d}".format(i)
		
		print("Saved Tex{:d}.png".format(i))
		i += 1
		
	oobj.close()
	
	print("Writing {}".format(name + ".obj"))
	
	oobj = open(name + ".obj", "w")
	oobj.write("mtllib {}.mtl\n\n".format(name))
	o = OBJ()
	o.fh = oobj
	ProcessGrid(T.grid, T, o, matName, scale, 0)
	
	oobj.close()


#### MAIN

if len(sys.argv) != 2:
	print("Use python3 {} file.trn".format(sys.argv[0]))
	exit(0)

print("Reading file {}".format(sys.argv[1]))
T = ReadTRN( sys.argv[1] )

#fname = os.path.basename(sys.argv[1])
fname = sys.argv[1]
dotp = fname.rfind(".")
if dotp > 0:
	fname = fname[:dotp]

SaveObj(T, fname, 0.001)

