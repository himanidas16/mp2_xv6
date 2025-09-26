
user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"

char*
fmtname(char *path)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	84aa                	mv	s1,a0
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
  10:	2b0000ef          	jal	ra,2c0 <strlen>
  14:	02051793          	slli	a5,a0,0x20
  18:	9381                	srli	a5,a5,0x20
  1a:	97a6                	add	a5,a5,s1
  1c:	02f00693          	li	a3,47
  20:	0097e963          	bltu	a5,s1,32 <fmtname+0x32>
  24:	0007c703          	lbu	a4,0(a5)
  28:	00d70563          	beq	a4,a3,32 <fmtname+0x32>
  2c:	17fd                	addi	a5,a5,-1
  2e:	fe97fbe3          	bgeu	a5,s1,24 <fmtname+0x24>
    ;
  p++;
  32:	00178493          	addi	s1,a5,1

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  36:	8526                	mv	a0,s1
  38:	288000ef          	jal	ra,2c0 <strlen>
  3c:	2501                	sext.w	a0,a0
  3e:	47b5                	li	a5,13
  40:	00a7fa63          	bgeu	a5,a0,54 <fmtname+0x54>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  buf[sizeof(buf)-1] = '\0';
  return buf;
}
  44:	8526                	mv	a0,s1
  46:	70a2                	ld	ra,40(sp)
  48:	7402                	ld	s0,32(sp)
  4a:	64e2                	ld	s1,24(sp)
  4c:	6942                	ld	s2,16(sp)
  4e:	69a2                	ld	s3,8(sp)
  50:	6145                	addi	sp,sp,48
  52:	8082                	ret
  memmove(buf, p, strlen(p));
  54:	8526                	mv	a0,s1
  56:	26a000ef          	jal	ra,2c0 <strlen>
  5a:	00001997          	auipc	s3,0x1
  5e:	fb698993          	addi	s3,s3,-74 # 1010 <buf.0>
  62:	0005061b          	sext.w	a2,a0
  66:	85a6                	mv	a1,s1
  68:	854e                	mv	a0,s3
  6a:	3ba000ef          	jal	ra,424 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  6e:	8526                	mv	a0,s1
  70:	250000ef          	jal	ra,2c0 <strlen>
  74:	0005091b          	sext.w	s2,a0
  78:	8526                	mv	a0,s1
  7a:	246000ef          	jal	ra,2c0 <strlen>
  7e:	1902                	slli	s2,s2,0x20
  80:	02095913          	srli	s2,s2,0x20
  84:	4639                	li	a2,14
  86:	9e09                	subw	a2,a2,a0
  88:	02000593          	li	a1,32
  8c:	01298533          	add	a0,s3,s2
  90:	25a000ef          	jal	ra,2ea <memset>
  buf[sizeof(buf)-1] = '\0';
  94:	00098723          	sb	zero,14(s3)
  return buf;
  98:	84ce                	mv	s1,s3
  9a:	b76d                	j	44 <fmtname+0x44>

000000000000009c <ls>:

void
ls(char *path)
{
  9c:	d9010113          	addi	sp,sp,-624
  a0:	26113423          	sd	ra,616(sp)
  a4:	26813023          	sd	s0,608(sp)
  a8:	24913c23          	sd	s1,600(sp)
  ac:	25213823          	sd	s2,592(sp)
  b0:	25313423          	sd	s3,584(sp)
  b4:	25413023          	sd	s4,576(sp)
  b8:	23513c23          	sd	s5,568(sp)
  bc:	1c80                	addi	s0,sp,624
  be:	892a                	mv	s2,a0
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, O_RDONLY)) < 0){
  c0:	4581                	li	a1,0
  c2:	47c000ef          	jal	ra,53e <open>
  c6:	06054963          	bltz	a0,138 <ls+0x9c>
  ca:	84aa                	mv	s1,a0
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  cc:	d9840593          	addi	a1,s0,-616
  d0:	486000ef          	jal	ra,556 <fstat>
  d4:	06054b63          	bltz	a0,14a <ls+0xae>
    fprintf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
  d8:	da041783          	lh	a5,-608(s0)
  dc:	0007869b          	sext.w	a3,a5
  e0:	4705                	li	a4,1
  e2:	08e68063          	beq	a3,a4,162 <ls+0xc6>
  e6:	37f9                	addiw	a5,a5,-2
  e8:	17c2                	slli	a5,a5,0x30
  ea:	93c1                	srli	a5,a5,0x30
  ec:	02f76263          	bltu	a4,a5,110 <ls+0x74>
  case T_DEVICE:
  case T_FILE:
    printf("%s %d %d %d\n", fmtname(path), st.type, st.ino, (int) st.size);
  f0:	854a                	mv	a0,s2
  f2:	f0fff0ef          	jal	ra,0 <fmtname>
  f6:	85aa                	mv	a1,a0
  f8:	da842703          	lw	a4,-600(s0)
  fc:	d9c42683          	lw	a3,-612(s0)
 100:	da041603          	lh	a2,-608(s0)
 104:	00001517          	auipc	a0,0x1
 108:	9dc50513          	addi	a0,a0,-1572 # ae0 <malloc+0x10c>
 10c:	00f000ef          	jal	ra,91a <printf>
      }
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
    }
    break;
  }
  close(fd);
 110:	8526                	mv	a0,s1
 112:	414000ef          	jal	ra,526 <close>
}
 116:	26813083          	ld	ra,616(sp)
 11a:	26013403          	ld	s0,608(sp)
 11e:	25813483          	ld	s1,600(sp)
 122:	25013903          	ld	s2,592(sp)
 126:	24813983          	ld	s3,584(sp)
 12a:	24013a03          	ld	s4,576(sp)
 12e:	23813a83          	ld	s5,568(sp)
 132:	27010113          	addi	sp,sp,624
 136:	8082                	ret
    fprintf(2, "ls: cannot open %s\n", path);
 138:	864a                	mv	a2,s2
 13a:	00001597          	auipc	a1,0x1
 13e:	97658593          	addi	a1,a1,-1674 # ab0 <malloc+0xdc>
 142:	4509                	li	a0,2
 144:	7ac000ef          	jal	ra,8f0 <fprintf>
    return;
 148:	b7f9                	j	116 <ls+0x7a>
    fprintf(2, "ls: cannot stat %s\n", path);
 14a:	864a                	mv	a2,s2
 14c:	00001597          	auipc	a1,0x1
 150:	97c58593          	addi	a1,a1,-1668 # ac8 <malloc+0xf4>
 154:	4509                	li	a0,2
 156:	79a000ef          	jal	ra,8f0 <fprintf>
    close(fd);
 15a:	8526                	mv	a0,s1
 15c:	3ca000ef          	jal	ra,526 <close>
    return;
 160:	bf5d                	j	116 <ls+0x7a>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 162:	854a                	mv	a0,s2
 164:	15c000ef          	jal	ra,2c0 <strlen>
 168:	2541                	addiw	a0,a0,16
 16a:	20000793          	li	a5,512
 16e:	00a7f963          	bgeu	a5,a0,180 <ls+0xe4>
      printf("ls: path too long\n");
 172:	00001517          	auipc	a0,0x1
 176:	97e50513          	addi	a0,a0,-1666 # af0 <malloc+0x11c>
 17a:	7a0000ef          	jal	ra,91a <printf>
      break;
 17e:	bf49                	j	110 <ls+0x74>
    strcpy(buf, path);
 180:	85ca                	mv	a1,s2
 182:	dc040513          	addi	a0,s0,-576
 186:	0f2000ef          	jal	ra,278 <strcpy>
    p = buf+strlen(buf);
 18a:	dc040513          	addi	a0,s0,-576
 18e:	132000ef          	jal	ra,2c0 <strlen>
 192:	02051913          	slli	s2,a0,0x20
 196:	02095913          	srli	s2,s2,0x20
 19a:	dc040793          	addi	a5,s0,-576
 19e:	993e                	add	s2,s2,a5
    *p++ = '/';
 1a0:	00190993          	addi	s3,s2,1
 1a4:	02f00793          	li	a5,47
 1a8:	00f90023          	sb	a5,0(s2)
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
 1ac:	00001a17          	auipc	s4,0x1
 1b0:	934a0a13          	addi	s4,s4,-1740 # ae0 <malloc+0x10c>
        printf("ls: cannot stat %s\n", buf);
 1b4:	00001a97          	auipc	s5,0x1
 1b8:	914a8a93          	addi	s5,s5,-1772 # ac8 <malloc+0xf4>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1bc:	a031                	j	1c8 <ls+0x12c>
        printf("ls: cannot stat %s\n", buf);
 1be:	dc040593          	addi	a1,s0,-576
 1c2:	8556                	mv	a0,s5
 1c4:	756000ef          	jal	ra,91a <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1c8:	4641                	li	a2,16
 1ca:	db040593          	addi	a1,s0,-592
 1ce:	8526                	mv	a0,s1
 1d0:	346000ef          	jal	ra,516 <read>
 1d4:	47c1                	li	a5,16
 1d6:	f2f51de3          	bne	a0,a5,110 <ls+0x74>
      if(de.inum == 0)
 1da:	db045783          	lhu	a5,-592(s0)
 1de:	d7ed                	beqz	a5,1c8 <ls+0x12c>
      memmove(p, de.name, DIRSIZ);
 1e0:	4639                	li	a2,14
 1e2:	db240593          	addi	a1,s0,-590
 1e6:	854e                	mv	a0,s3
 1e8:	23c000ef          	jal	ra,424 <memmove>
      p[DIRSIZ] = 0;
 1ec:	000907a3          	sb	zero,15(s2)
      if(stat(buf, &st) < 0){
 1f0:	d9840593          	addi	a1,s0,-616
 1f4:	dc040513          	addi	a0,s0,-576
 1f8:	1a8000ef          	jal	ra,3a0 <stat>
 1fc:	fc0541e3          	bltz	a0,1be <ls+0x122>
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
 200:	dc040513          	addi	a0,s0,-576
 204:	dfdff0ef          	jal	ra,0 <fmtname>
 208:	85aa                	mv	a1,a0
 20a:	da842703          	lw	a4,-600(s0)
 20e:	d9c42683          	lw	a3,-612(s0)
 212:	da041603          	lh	a2,-608(s0)
 216:	8552                	mv	a0,s4
 218:	702000ef          	jal	ra,91a <printf>
 21c:	b775                	j	1c8 <ls+0x12c>

000000000000021e <main>:

int
main(int argc, char *argv[])
{
 21e:	1101                	addi	sp,sp,-32
 220:	ec06                	sd	ra,24(sp)
 222:	e822                	sd	s0,16(sp)
 224:	e426                	sd	s1,8(sp)
 226:	e04a                	sd	s2,0(sp)
 228:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
 22a:	4785                	li	a5,1
 22c:	02a7d563          	bge	a5,a0,256 <main+0x38>
 230:	00858493          	addi	s1,a1,8
 234:	ffe5091b          	addiw	s2,a0,-2
 238:	1902                	slli	s2,s2,0x20
 23a:	02095913          	srli	s2,s2,0x20
 23e:	090e                	slli	s2,s2,0x3
 240:	05c1                	addi	a1,a1,16
 242:	992e                	add	s2,s2,a1
    ls(".");
    exit(0);
  }
  for(i=1; i<argc; i++)
    ls(argv[i]);
 244:	6088                	ld	a0,0(s1)
 246:	e57ff0ef          	jal	ra,9c <ls>
  for(i=1; i<argc; i++)
 24a:	04a1                	addi	s1,s1,8
 24c:	ff249ce3          	bne	s1,s2,244 <main+0x26>
  exit(0);
 250:	4501                	li	a0,0
 252:	2ac000ef          	jal	ra,4fe <exit>
    ls(".");
 256:	00001517          	auipc	a0,0x1
 25a:	8b250513          	addi	a0,a0,-1870 # b08 <malloc+0x134>
 25e:	e3fff0ef          	jal	ra,9c <ls>
    exit(0);
 262:	4501                	li	a0,0
 264:	29a000ef          	jal	ra,4fe <exit>

0000000000000268 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 268:	1141                	addi	sp,sp,-16
 26a:	e406                	sd	ra,8(sp)
 26c:	e022                	sd	s0,0(sp)
 26e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 270:	fafff0ef          	jal	ra,21e <main>
  exit(r);
 274:	28a000ef          	jal	ra,4fe <exit>

0000000000000278 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 278:	1141                	addi	sp,sp,-16
 27a:	e422                	sd	s0,8(sp)
 27c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 27e:	87aa                	mv	a5,a0
 280:	0585                	addi	a1,a1,1
 282:	0785                	addi	a5,a5,1
 284:	fff5c703          	lbu	a4,-1(a1)
 288:	fee78fa3          	sb	a4,-1(a5)
 28c:	fb75                	bnez	a4,280 <strcpy+0x8>
    ;
  return os;
}
 28e:	6422                	ld	s0,8(sp)
 290:	0141                	addi	sp,sp,16
 292:	8082                	ret

0000000000000294 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 294:	1141                	addi	sp,sp,-16
 296:	e422                	sd	s0,8(sp)
 298:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 29a:	00054783          	lbu	a5,0(a0)
 29e:	cb91                	beqz	a5,2b2 <strcmp+0x1e>
 2a0:	0005c703          	lbu	a4,0(a1)
 2a4:	00f71763          	bne	a4,a5,2b2 <strcmp+0x1e>
    p++, q++;
 2a8:	0505                	addi	a0,a0,1
 2aa:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2ac:	00054783          	lbu	a5,0(a0)
 2b0:	fbe5                	bnez	a5,2a0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2b2:	0005c503          	lbu	a0,0(a1)
}
 2b6:	40a7853b          	subw	a0,a5,a0
 2ba:	6422                	ld	s0,8(sp)
 2bc:	0141                	addi	sp,sp,16
 2be:	8082                	ret

00000000000002c0 <strlen>:

uint
strlen(const char *s)
{
 2c0:	1141                	addi	sp,sp,-16
 2c2:	e422                	sd	s0,8(sp)
 2c4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2c6:	00054783          	lbu	a5,0(a0)
 2ca:	cf91                	beqz	a5,2e6 <strlen+0x26>
 2cc:	0505                	addi	a0,a0,1
 2ce:	87aa                	mv	a5,a0
 2d0:	4685                	li	a3,1
 2d2:	9e89                	subw	a3,a3,a0
 2d4:	00f6853b          	addw	a0,a3,a5
 2d8:	0785                	addi	a5,a5,1
 2da:	fff7c703          	lbu	a4,-1(a5)
 2de:	fb7d                	bnez	a4,2d4 <strlen+0x14>
    ;
  return n;
}
 2e0:	6422                	ld	s0,8(sp)
 2e2:	0141                	addi	sp,sp,16
 2e4:	8082                	ret
  for(n = 0; s[n]; n++)
 2e6:	4501                	li	a0,0
 2e8:	bfe5                	j	2e0 <strlen+0x20>

00000000000002ea <memset>:

void*
memset(void *dst, int c, uint n)
{
 2ea:	1141                	addi	sp,sp,-16
 2ec:	e422                	sd	s0,8(sp)
 2ee:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2f0:	ca19                	beqz	a2,306 <memset+0x1c>
 2f2:	87aa                	mv	a5,a0
 2f4:	1602                	slli	a2,a2,0x20
 2f6:	9201                	srli	a2,a2,0x20
 2f8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2fc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 300:	0785                	addi	a5,a5,1
 302:	fee79de3          	bne	a5,a4,2fc <memset+0x12>
  }
  return dst;
}
 306:	6422                	ld	s0,8(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret

000000000000030c <strchr>:

char*
strchr(const char *s, char c)
{
 30c:	1141                	addi	sp,sp,-16
 30e:	e422                	sd	s0,8(sp)
 310:	0800                	addi	s0,sp,16
  for(; *s; s++)
 312:	00054783          	lbu	a5,0(a0)
 316:	cb99                	beqz	a5,32c <strchr+0x20>
    if(*s == c)
 318:	00f58763          	beq	a1,a5,326 <strchr+0x1a>
  for(; *s; s++)
 31c:	0505                	addi	a0,a0,1
 31e:	00054783          	lbu	a5,0(a0)
 322:	fbfd                	bnez	a5,318 <strchr+0xc>
      return (char*)s;
  return 0;
 324:	4501                	li	a0,0
}
 326:	6422                	ld	s0,8(sp)
 328:	0141                	addi	sp,sp,16
 32a:	8082                	ret
  return 0;
 32c:	4501                	li	a0,0
 32e:	bfe5                	j	326 <strchr+0x1a>

0000000000000330 <gets>:

char*
gets(char *buf, int max)
{
 330:	711d                	addi	sp,sp,-96
 332:	ec86                	sd	ra,88(sp)
 334:	e8a2                	sd	s0,80(sp)
 336:	e4a6                	sd	s1,72(sp)
 338:	e0ca                	sd	s2,64(sp)
 33a:	fc4e                	sd	s3,56(sp)
 33c:	f852                	sd	s4,48(sp)
 33e:	f456                	sd	s5,40(sp)
 340:	f05a                	sd	s6,32(sp)
 342:	ec5e                	sd	s7,24(sp)
 344:	1080                	addi	s0,sp,96
 346:	8baa                	mv	s7,a0
 348:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 34a:	892a                	mv	s2,a0
 34c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 34e:	4aa9                	li	s5,10
 350:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 352:	89a6                	mv	s3,s1
 354:	2485                	addiw	s1,s1,1
 356:	0344d663          	bge	s1,s4,382 <gets+0x52>
    cc = read(0, &c, 1);
 35a:	4605                	li	a2,1
 35c:	faf40593          	addi	a1,s0,-81
 360:	4501                	li	a0,0
 362:	1b4000ef          	jal	ra,516 <read>
    if(cc < 1)
 366:	00a05e63          	blez	a0,382 <gets+0x52>
    buf[i++] = c;
 36a:	faf44783          	lbu	a5,-81(s0)
 36e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 372:	01578763          	beq	a5,s5,380 <gets+0x50>
 376:	0905                	addi	s2,s2,1
 378:	fd679de3          	bne	a5,s6,352 <gets+0x22>
  for(i=0; i+1 < max; ){
 37c:	89a6                	mv	s3,s1
 37e:	a011                	j	382 <gets+0x52>
 380:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 382:	99de                	add	s3,s3,s7
 384:	00098023          	sb	zero,0(s3)
  return buf;
}
 388:	855e                	mv	a0,s7
 38a:	60e6                	ld	ra,88(sp)
 38c:	6446                	ld	s0,80(sp)
 38e:	64a6                	ld	s1,72(sp)
 390:	6906                	ld	s2,64(sp)
 392:	79e2                	ld	s3,56(sp)
 394:	7a42                	ld	s4,48(sp)
 396:	7aa2                	ld	s5,40(sp)
 398:	7b02                	ld	s6,32(sp)
 39a:	6be2                	ld	s7,24(sp)
 39c:	6125                	addi	sp,sp,96
 39e:	8082                	ret

00000000000003a0 <stat>:

int
stat(const char *n, struct stat *st)
{
 3a0:	1101                	addi	sp,sp,-32
 3a2:	ec06                	sd	ra,24(sp)
 3a4:	e822                	sd	s0,16(sp)
 3a6:	e426                	sd	s1,8(sp)
 3a8:	e04a                	sd	s2,0(sp)
 3aa:	1000                	addi	s0,sp,32
 3ac:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3ae:	4581                	li	a1,0
 3b0:	18e000ef          	jal	ra,53e <open>
  if(fd < 0)
 3b4:	02054163          	bltz	a0,3d6 <stat+0x36>
 3b8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3ba:	85ca                	mv	a1,s2
 3bc:	19a000ef          	jal	ra,556 <fstat>
 3c0:	892a                	mv	s2,a0
  close(fd);
 3c2:	8526                	mv	a0,s1
 3c4:	162000ef          	jal	ra,526 <close>
  return r;
}
 3c8:	854a                	mv	a0,s2
 3ca:	60e2                	ld	ra,24(sp)
 3cc:	6442                	ld	s0,16(sp)
 3ce:	64a2                	ld	s1,8(sp)
 3d0:	6902                	ld	s2,0(sp)
 3d2:	6105                	addi	sp,sp,32
 3d4:	8082                	ret
    return -1;
 3d6:	597d                	li	s2,-1
 3d8:	bfc5                	j	3c8 <stat+0x28>

00000000000003da <atoi>:

int
atoi(const char *s)
{
 3da:	1141                	addi	sp,sp,-16
 3dc:	e422                	sd	s0,8(sp)
 3de:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3e0:	00054603          	lbu	a2,0(a0)
 3e4:	fd06079b          	addiw	a5,a2,-48
 3e8:	0ff7f793          	andi	a5,a5,255
 3ec:	4725                	li	a4,9
 3ee:	02f76963          	bltu	a4,a5,420 <atoi+0x46>
 3f2:	86aa                	mv	a3,a0
  n = 0;
 3f4:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 3f6:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 3f8:	0685                	addi	a3,a3,1
 3fa:	0025179b          	slliw	a5,a0,0x2
 3fe:	9fa9                	addw	a5,a5,a0
 400:	0017979b          	slliw	a5,a5,0x1
 404:	9fb1                	addw	a5,a5,a2
 406:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 40a:	0006c603          	lbu	a2,0(a3)
 40e:	fd06071b          	addiw	a4,a2,-48
 412:	0ff77713          	andi	a4,a4,255
 416:	fee5f1e3          	bgeu	a1,a4,3f8 <atoi+0x1e>
  return n;
}
 41a:	6422                	ld	s0,8(sp)
 41c:	0141                	addi	sp,sp,16
 41e:	8082                	ret
  n = 0;
 420:	4501                	li	a0,0
 422:	bfe5                	j	41a <atoi+0x40>

0000000000000424 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 424:	1141                	addi	sp,sp,-16
 426:	e422                	sd	s0,8(sp)
 428:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 42a:	02b57463          	bgeu	a0,a1,452 <memmove+0x2e>
    while(n-- > 0)
 42e:	00c05f63          	blez	a2,44c <memmove+0x28>
 432:	1602                	slli	a2,a2,0x20
 434:	9201                	srli	a2,a2,0x20
 436:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 43a:	872a                	mv	a4,a0
      *dst++ = *src++;
 43c:	0585                	addi	a1,a1,1
 43e:	0705                	addi	a4,a4,1
 440:	fff5c683          	lbu	a3,-1(a1)
 444:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 448:	fee79ae3          	bne	a5,a4,43c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 44c:	6422                	ld	s0,8(sp)
 44e:	0141                	addi	sp,sp,16
 450:	8082                	ret
    dst += n;
 452:	00c50733          	add	a4,a0,a2
    src += n;
 456:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 458:	fec05ae3          	blez	a2,44c <memmove+0x28>
 45c:	fff6079b          	addiw	a5,a2,-1
 460:	1782                	slli	a5,a5,0x20
 462:	9381                	srli	a5,a5,0x20
 464:	fff7c793          	not	a5,a5
 468:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 46a:	15fd                	addi	a1,a1,-1
 46c:	177d                	addi	a4,a4,-1
 46e:	0005c683          	lbu	a3,0(a1)
 472:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 476:	fee79ae3          	bne	a5,a4,46a <memmove+0x46>
 47a:	bfc9                	j	44c <memmove+0x28>

000000000000047c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 47c:	1141                	addi	sp,sp,-16
 47e:	e422                	sd	s0,8(sp)
 480:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 482:	ca05                	beqz	a2,4b2 <memcmp+0x36>
 484:	fff6069b          	addiw	a3,a2,-1
 488:	1682                	slli	a3,a3,0x20
 48a:	9281                	srli	a3,a3,0x20
 48c:	0685                	addi	a3,a3,1
 48e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 490:	00054783          	lbu	a5,0(a0)
 494:	0005c703          	lbu	a4,0(a1)
 498:	00e79863          	bne	a5,a4,4a8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 49c:	0505                	addi	a0,a0,1
    p2++;
 49e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4a0:	fed518e3          	bne	a0,a3,490 <memcmp+0x14>
  }
  return 0;
 4a4:	4501                	li	a0,0
 4a6:	a019                	j	4ac <memcmp+0x30>
      return *p1 - *p2;
 4a8:	40e7853b          	subw	a0,a5,a4
}
 4ac:	6422                	ld	s0,8(sp)
 4ae:	0141                	addi	sp,sp,16
 4b0:	8082                	ret
  return 0;
 4b2:	4501                	li	a0,0
 4b4:	bfe5                	j	4ac <memcmp+0x30>

00000000000004b6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4b6:	1141                	addi	sp,sp,-16
 4b8:	e406                	sd	ra,8(sp)
 4ba:	e022                	sd	s0,0(sp)
 4bc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4be:	f67ff0ef          	jal	ra,424 <memmove>
}
 4c2:	60a2                	ld	ra,8(sp)
 4c4:	6402                	ld	s0,0(sp)
 4c6:	0141                	addi	sp,sp,16
 4c8:	8082                	ret

00000000000004ca <sbrk>:

char *
sbrk(int n) {
 4ca:	1141                	addi	sp,sp,-16
 4cc:	e406                	sd	ra,8(sp)
 4ce:	e022                	sd	s0,0(sp)
 4d0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4d2:	4585                	li	a1,1
 4d4:	0b2000ef          	jal	ra,586 <sys_sbrk>
}
 4d8:	60a2                	ld	ra,8(sp)
 4da:	6402                	ld	s0,0(sp)
 4dc:	0141                	addi	sp,sp,16
 4de:	8082                	ret

00000000000004e0 <sbrklazy>:

char *
sbrklazy(int n) {
 4e0:	1141                	addi	sp,sp,-16
 4e2:	e406                	sd	ra,8(sp)
 4e4:	e022                	sd	s0,0(sp)
 4e6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4e8:	4589                	li	a1,2
 4ea:	09c000ef          	jal	ra,586 <sys_sbrk>
}
 4ee:	60a2                	ld	ra,8(sp)
 4f0:	6402                	ld	s0,0(sp)
 4f2:	0141                	addi	sp,sp,16
 4f4:	8082                	ret

00000000000004f6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4f6:	4885                	li	a7,1
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <exit>:
.global exit
exit:
 li a7, SYS_exit
 4fe:	4889                	li	a7,2
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <wait>:
.global wait
wait:
 li a7, SYS_wait
 506:	488d                	li	a7,3
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 50e:	4891                	li	a7,4
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <read>:
.global read
read:
 li a7, SYS_read
 516:	4895                	li	a7,5
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <write>:
.global write
write:
 li a7, SYS_write
 51e:	48c1                	li	a7,16
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <close>:
.global close
close:
 li a7, SYS_close
 526:	48d5                	li	a7,21
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <kill>:
.global kill
kill:
 li a7, SYS_kill
 52e:	4899                	li	a7,6
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <exec>:
.global exec
exec:
 li a7, SYS_exec
 536:	489d                	li	a7,7
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <open>:
.global open
open:
 li a7, SYS_open
 53e:	48bd                	li	a7,15
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 546:	48c5                	li	a7,17
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 54e:	48c9                	li	a7,18
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 556:	48a1                	li	a7,8
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <link>:
.global link
link:
 li a7, SYS_link
 55e:	48cd                	li	a7,19
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 566:	48d1                	li	a7,20
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 56e:	48a5                	li	a7,9
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <dup>:
.global dup
dup:
 li a7, SYS_dup
 576:	48a9                	li	a7,10
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 57e:	48ad                	li	a7,11
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 586:	48b1                	li	a7,12
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <pause>:
.global pause
pause:
 li a7, SYS_pause
 58e:	48b5                	li	a7,13
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 596:	48b9                	li	a7,14
 ecall
 598:	00000073          	ecall
 ret
 59c:	8082                	ret

000000000000059e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 59e:	1101                	addi	sp,sp,-32
 5a0:	ec06                	sd	ra,24(sp)
 5a2:	e822                	sd	s0,16(sp)
 5a4:	1000                	addi	s0,sp,32
 5a6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5aa:	4605                	li	a2,1
 5ac:	fef40593          	addi	a1,s0,-17
 5b0:	f6fff0ef          	jal	ra,51e <write>
}
 5b4:	60e2                	ld	ra,24(sp)
 5b6:	6442                	ld	s0,16(sp)
 5b8:	6105                	addi	sp,sp,32
 5ba:	8082                	ret

00000000000005bc <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 5bc:	715d                	addi	sp,sp,-80
 5be:	e486                	sd	ra,72(sp)
 5c0:	e0a2                	sd	s0,64(sp)
 5c2:	fc26                	sd	s1,56(sp)
 5c4:	f84a                	sd	s2,48(sp)
 5c6:	f44e                	sd	s3,40(sp)
 5c8:	0880                	addi	s0,sp,80
 5ca:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 5cc:	c299                	beqz	a3,5d2 <printint+0x16>
 5ce:	0805c163          	bltz	a1,650 <printint+0x94>
  neg = 0;
 5d2:	4881                	li	a7,0
 5d4:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 5d8:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 5da:	00000517          	auipc	a0,0x0
 5de:	53e50513          	addi	a0,a0,1342 # b18 <digits>
 5e2:	883e                	mv	a6,a5
 5e4:	2785                	addiw	a5,a5,1
 5e6:	02c5f733          	remu	a4,a1,a2
 5ea:	972a                	add	a4,a4,a0
 5ec:	00074703          	lbu	a4,0(a4)
 5f0:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 5f4:	872e                	mv	a4,a1
 5f6:	02c5d5b3          	divu	a1,a1,a2
 5fa:	0685                	addi	a3,a3,1
 5fc:	fec773e3          	bgeu	a4,a2,5e2 <printint+0x26>
  if(neg)
 600:	00088b63          	beqz	a7,616 <printint+0x5a>
    buf[i++] = '-';
 604:	fd040713          	addi	a4,s0,-48
 608:	97ba                	add	a5,a5,a4
 60a:	02d00713          	li	a4,45
 60e:	fee78423          	sb	a4,-24(a5)
 612:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 616:	02f05663          	blez	a5,642 <printint+0x86>
 61a:	fb840713          	addi	a4,s0,-72
 61e:	00f704b3          	add	s1,a4,a5
 622:	fff70993          	addi	s3,a4,-1
 626:	99be                	add	s3,s3,a5
 628:	37fd                	addiw	a5,a5,-1
 62a:	1782                	slli	a5,a5,0x20
 62c:	9381                	srli	a5,a5,0x20
 62e:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 632:	fff4c583          	lbu	a1,-1(s1)
 636:	854a                	mv	a0,s2
 638:	f67ff0ef          	jal	ra,59e <putc>
  while(--i >= 0)
 63c:	14fd                	addi	s1,s1,-1
 63e:	ff349ae3          	bne	s1,s3,632 <printint+0x76>
}
 642:	60a6                	ld	ra,72(sp)
 644:	6406                	ld	s0,64(sp)
 646:	74e2                	ld	s1,56(sp)
 648:	7942                	ld	s2,48(sp)
 64a:	79a2                	ld	s3,40(sp)
 64c:	6161                	addi	sp,sp,80
 64e:	8082                	ret
    x = -xx;
 650:	40b005b3          	neg	a1,a1
    neg = 1;
 654:	4885                	li	a7,1
    x = -xx;
 656:	bfbd                	j	5d4 <printint+0x18>

0000000000000658 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 658:	7119                	addi	sp,sp,-128
 65a:	fc86                	sd	ra,120(sp)
 65c:	f8a2                	sd	s0,112(sp)
 65e:	f4a6                	sd	s1,104(sp)
 660:	f0ca                	sd	s2,96(sp)
 662:	ecce                	sd	s3,88(sp)
 664:	e8d2                	sd	s4,80(sp)
 666:	e4d6                	sd	s5,72(sp)
 668:	e0da                	sd	s6,64(sp)
 66a:	fc5e                	sd	s7,56(sp)
 66c:	f862                	sd	s8,48(sp)
 66e:	f466                	sd	s9,40(sp)
 670:	f06a                	sd	s10,32(sp)
 672:	ec6e                	sd	s11,24(sp)
 674:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 676:	0005c903          	lbu	s2,0(a1)
 67a:	24090c63          	beqz	s2,8d2 <vprintf+0x27a>
 67e:	8b2a                	mv	s6,a0
 680:	8a2e                	mv	s4,a1
 682:	8bb2                	mv	s7,a2
  state = 0;
 684:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 686:	4481                	li	s1,0
 688:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 68a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 68e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 692:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 696:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 69a:	00000c97          	auipc	s9,0x0
 69e:	47ec8c93          	addi	s9,s9,1150 # b18 <digits>
 6a2:	a005                	j	6c2 <vprintf+0x6a>
        putc(fd, c0);
 6a4:	85ca                	mv	a1,s2
 6a6:	855a                	mv	a0,s6
 6a8:	ef7ff0ef          	jal	ra,59e <putc>
 6ac:	a019                	j	6b2 <vprintf+0x5a>
    } else if(state == '%'){
 6ae:	03598263          	beq	s3,s5,6d2 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 6b2:	2485                	addiw	s1,s1,1
 6b4:	8726                	mv	a4,s1
 6b6:	009a07b3          	add	a5,s4,s1
 6ba:	0007c903          	lbu	s2,0(a5)
 6be:	20090a63          	beqz	s2,8d2 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 6c2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6c6:	fe0994e3          	bnez	s3,6ae <vprintf+0x56>
      if(c0 == '%'){
 6ca:	fd579de3          	bne	a5,s5,6a4 <vprintf+0x4c>
        state = '%';
 6ce:	89be                	mv	s3,a5
 6d0:	b7cd                	j	6b2 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 6d2:	c3c1                	beqz	a5,752 <vprintf+0xfa>
 6d4:	00ea06b3          	add	a3,s4,a4
 6d8:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 6dc:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 6de:	c681                	beqz	a3,6e6 <vprintf+0x8e>
 6e0:	9752                	add	a4,a4,s4
 6e2:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 6e6:	03878e63          	beq	a5,s8,722 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 6ea:	05a78863          	beq	a5,s10,73a <vprintf+0xe2>
      } else if(c0 == 'u'){
 6ee:	0db78b63          	beq	a5,s11,7c4 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 6f2:	07800713          	li	a4,120
 6f6:	10e78d63          	beq	a5,a4,810 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 6fa:	07000713          	li	a4,112
 6fe:	14e78263          	beq	a5,a4,842 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 702:	06300713          	li	a4,99
 706:	16e78f63          	beq	a5,a4,884 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 70a:	07300713          	li	a4,115
 70e:	18e78563          	beq	a5,a4,898 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 712:	05579063          	bne	a5,s5,752 <vprintf+0xfa>
        putc(fd, '%');
 716:	85d6                	mv	a1,s5
 718:	855a                	mv	a0,s6
 71a:	e85ff0ef          	jal	ra,59e <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 71e:	4981                	li	s3,0
 720:	bf49                	j	6b2 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 722:	008b8913          	addi	s2,s7,8
 726:	4685                	li	a3,1
 728:	4629                	li	a2,10
 72a:	000ba583          	lw	a1,0(s7)
 72e:	855a                	mv	a0,s6
 730:	e8dff0ef          	jal	ra,5bc <printint>
 734:	8bca                	mv	s7,s2
      state = 0;
 736:	4981                	li	s3,0
 738:	bfad                	j	6b2 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 73a:	03868663          	beq	a3,s8,766 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 73e:	05a68163          	beq	a3,s10,780 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 742:	09b68d63          	beq	a3,s11,7dc <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 746:	03a68f63          	beq	a3,s10,784 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 74a:	07800793          	li	a5,120
 74e:	0cf68d63          	beq	a3,a5,828 <vprintf+0x1d0>
        putc(fd, '%');
 752:	85d6                	mv	a1,s5
 754:	855a                	mv	a0,s6
 756:	e49ff0ef          	jal	ra,59e <putc>
        putc(fd, c0);
 75a:	85ca                	mv	a1,s2
 75c:	855a                	mv	a0,s6
 75e:	e41ff0ef          	jal	ra,59e <putc>
      state = 0;
 762:	4981                	li	s3,0
 764:	b7b9                	j	6b2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 766:	008b8913          	addi	s2,s7,8
 76a:	4685                	li	a3,1
 76c:	4629                	li	a2,10
 76e:	000bb583          	ld	a1,0(s7)
 772:	855a                	mv	a0,s6
 774:	e49ff0ef          	jal	ra,5bc <printint>
        i += 1;
 778:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 77a:	8bca                	mv	s7,s2
      state = 0;
 77c:	4981                	li	s3,0
        i += 1;
 77e:	bf15                	j	6b2 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 780:	03860563          	beq	a2,s8,7aa <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 784:	07b60963          	beq	a2,s11,7f6 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 788:	07800793          	li	a5,120
 78c:	fcf613e3          	bne	a2,a5,752 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 790:	008b8913          	addi	s2,s7,8
 794:	4681                	li	a3,0
 796:	4641                	li	a2,16
 798:	000bb583          	ld	a1,0(s7)
 79c:	855a                	mv	a0,s6
 79e:	e1fff0ef          	jal	ra,5bc <printint>
        i += 2;
 7a2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 7a4:	8bca                	mv	s7,s2
      state = 0;
 7a6:	4981                	li	s3,0
        i += 2;
 7a8:	b729                	j	6b2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7aa:	008b8913          	addi	s2,s7,8
 7ae:	4685                	li	a3,1
 7b0:	4629                	li	a2,10
 7b2:	000bb583          	ld	a1,0(s7)
 7b6:	855a                	mv	a0,s6
 7b8:	e05ff0ef          	jal	ra,5bc <printint>
        i += 2;
 7bc:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 7be:	8bca                	mv	s7,s2
      state = 0;
 7c0:	4981                	li	s3,0
        i += 2;
 7c2:	bdc5                	j	6b2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 7c4:	008b8913          	addi	s2,s7,8
 7c8:	4681                	li	a3,0
 7ca:	4629                	li	a2,10
 7cc:	000be583          	lwu	a1,0(s7)
 7d0:	855a                	mv	a0,s6
 7d2:	debff0ef          	jal	ra,5bc <printint>
 7d6:	8bca                	mv	s7,s2
      state = 0;
 7d8:	4981                	li	s3,0
 7da:	bde1                	j	6b2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7dc:	008b8913          	addi	s2,s7,8
 7e0:	4681                	li	a3,0
 7e2:	4629                	li	a2,10
 7e4:	000bb583          	ld	a1,0(s7)
 7e8:	855a                	mv	a0,s6
 7ea:	dd3ff0ef          	jal	ra,5bc <printint>
        i += 1;
 7ee:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 7f0:	8bca                	mv	s7,s2
      state = 0;
 7f2:	4981                	li	s3,0
        i += 1;
 7f4:	bd7d                	j	6b2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7f6:	008b8913          	addi	s2,s7,8
 7fa:	4681                	li	a3,0
 7fc:	4629                	li	a2,10
 7fe:	000bb583          	ld	a1,0(s7)
 802:	855a                	mv	a0,s6
 804:	db9ff0ef          	jal	ra,5bc <printint>
        i += 2;
 808:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 80a:	8bca                	mv	s7,s2
      state = 0;
 80c:	4981                	li	s3,0
        i += 2;
 80e:	b555                	j	6b2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 810:	008b8913          	addi	s2,s7,8
 814:	4681                	li	a3,0
 816:	4641                	li	a2,16
 818:	000be583          	lwu	a1,0(s7)
 81c:	855a                	mv	a0,s6
 81e:	d9fff0ef          	jal	ra,5bc <printint>
 822:	8bca                	mv	s7,s2
      state = 0;
 824:	4981                	li	s3,0
 826:	b571                	j	6b2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 828:	008b8913          	addi	s2,s7,8
 82c:	4681                	li	a3,0
 82e:	4641                	li	a2,16
 830:	000bb583          	ld	a1,0(s7)
 834:	855a                	mv	a0,s6
 836:	d87ff0ef          	jal	ra,5bc <printint>
        i += 1;
 83a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 83c:	8bca                	mv	s7,s2
      state = 0;
 83e:	4981                	li	s3,0
        i += 1;
 840:	bd8d                	j	6b2 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 842:	008b8793          	addi	a5,s7,8
 846:	f8f43423          	sd	a5,-120(s0)
 84a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 84e:	03000593          	li	a1,48
 852:	855a                	mv	a0,s6
 854:	d4bff0ef          	jal	ra,59e <putc>
  putc(fd, 'x');
 858:	07800593          	li	a1,120
 85c:	855a                	mv	a0,s6
 85e:	d41ff0ef          	jal	ra,59e <putc>
 862:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 864:	03c9d793          	srli	a5,s3,0x3c
 868:	97e6                	add	a5,a5,s9
 86a:	0007c583          	lbu	a1,0(a5)
 86e:	855a                	mv	a0,s6
 870:	d2fff0ef          	jal	ra,59e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 874:	0992                	slli	s3,s3,0x4
 876:	397d                	addiw	s2,s2,-1
 878:	fe0916e3          	bnez	s2,864 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 87c:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 880:	4981                	li	s3,0
 882:	bd05                	j	6b2 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 884:	008b8913          	addi	s2,s7,8
 888:	000bc583          	lbu	a1,0(s7)
 88c:	855a                	mv	a0,s6
 88e:	d11ff0ef          	jal	ra,59e <putc>
 892:	8bca                	mv	s7,s2
      state = 0;
 894:	4981                	li	s3,0
 896:	bd31                	j	6b2 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 898:	008b8993          	addi	s3,s7,8
 89c:	000bb903          	ld	s2,0(s7)
 8a0:	00090f63          	beqz	s2,8be <vprintf+0x266>
        for(; *s; s++)
 8a4:	00094583          	lbu	a1,0(s2)
 8a8:	c195                	beqz	a1,8cc <vprintf+0x274>
          putc(fd, *s);
 8aa:	855a                	mv	a0,s6
 8ac:	cf3ff0ef          	jal	ra,59e <putc>
        for(; *s; s++)
 8b0:	0905                	addi	s2,s2,1
 8b2:	00094583          	lbu	a1,0(s2)
 8b6:	f9f5                	bnez	a1,8aa <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 8b8:	8bce                	mv	s7,s3
      state = 0;
 8ba:	4981                	li	s3,0
 8bc:	bbdd                	j	6b2 <vprintf+0x5a>
          s = "(null)";
 8be:	00000917          	auipc	s2,0x0
 8c2:	25290913          	addi	s2,s2,594 # b10 <malloc+0x13c>
        for(; *s; s++)
 8c6:	02800593          	li	a1,40
 8ca:	b7c5                	j	8aa <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 8cc:	8bce                	mv	s7,s3
      state = 0;
 8ce:	4981                	li	s3,0
 8d0:	b3cd                	j	6b2 <vprintf+0x5a>
    }
  }
}
 8d2:	70e6                	ld	ra,120(sp)
 8d4:	7446                	ld	s0,112(sp)
 8d6:	74a6                	ld	s1,104(sp)
 8d8:	7906                	ld	s2,96(sp)
 8da:	69e6                	ld	s3,88(sp)
 8dc:	6a46                	ld	s4,80(sp)
 8de:	6aa6                	ld	s5,72(sp)
 8e0:	6b06                	ld	s6,64(sp)
 8e2:	7be2                	ld	s7,56(sp)
 8e4:	7c42                	ld	s8,48(sp)
 8e6:	7ca2                	ld	s9,40(sp)
 8e8:	7d02                	ld	s10,32(sp)
 8ea:	6de2                	ld	s11,24(sp)
 8ec:	6109                	addi	sp,sp,128
 8ee:	8082                	ret

00000000000008f0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8f0:	715d                	addi	sp,sp,-80
 8f2:	ec06                	sd	ra,24(sp)
 8f4:	e822                	sd	s0,16(sp)
 8f6:	1000                	addi	s0,sp,32
 8f8:	e010                	sd	a2,0(s0)
 8fa:	e414                	sd	a3,8(s0)
 8fc:	e818                	sd	a4,16(s0)
 8fe:	ec1c                	sd	a5,24(s0)
 900:	03043023          	sd	a6,32(s0)
 904:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 908:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 90c:	8622                	mv	a2,s0
 90e:	d4bff0ef          	jal	ra,658 <vprintf>
}
 912:	60e2                	ld	ra,24(sp)
 914:	6442                	ld	s0,16(sp)
 916:	6161                	addi	sp,sp,80
 918:	8082                	ret

000000000000091a <printf>:

void
printf(const char *fmt, ...)
{
 91a:	711d                	addi	sp,sp,-96
 91c:	ec06                	sd	ra,24(sp)
 91e:	e822                	sd	s0,16(sp)
 920:	1000                	addi	s0,sp,32
 922:	e40c                	sd	a1,8(s0)
 924:	e810                	sd	a2,16(s0)
 926:	ec14                	sd	a3,24(s0)
 928:	f018                	sd	a4,32(s0)
 92a:	f41c                	sd	a5,40(s0)
 92c:	03043823          	sd	a6,48(s0)
 930:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 934:	00840613          	addi	a2,s0,8
 938:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 93c:	85aa                	mv	a1,a0
 93e:	4505                	li	a0,1
 940:	d19ff0ef          	jal	ra,658 <vprintf>
}
 944:	60e2                	ld	ra,24(sp)
 946:	6442                	ld	s0,16(sp)
 948:	6125                	addi	sp,sp,96
 94a:	8082                	ret

000000000000094c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 94c:	1141                	addi	sp,sp,-16
 94e:	e422                	sd	s0,8(sp)
 950:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 952:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 956:	00000797          	auipc	a5,0x0
 95a:	6aa7b783          	ld	a5,1706(a5) # 1000 <freep>
 95e:	a805                	j	98e <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 960:	4618                	lw	a4,8(a2)
 962:	9db9                	addw	a1,a1,a4
 964:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 968:	6398                	ld	a4,0(a5)
 96a:	6318                	ld	a4,0(a4)
 96c:	fee53823          	sd	a4,-16(a0)
 970:	a091                	j	9b4 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 972:	ff852703          	lw	a4,-8(a0)
 976:	9e39                	addw	a2,a2,a4
 978:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 97a:	ff053703          	ld	a4,-16(a0)
 97e:	e398                	sd	a4,0(a5)
 980:	a099                	j	9c6 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 982:	6398                	ld	a4,0(a5)
 984:	00e7e463          	bltu	a5,a4,98c <free+0x40>
 988:	00e6ea63          	bltu	a3,a4,99c <free+0x50>
{
 98c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 98e:	fed7fae3          	bgeu	a5,a3,982 <free+0x36>
 992:	6398                	ld	a4,0(a5)
 994:	00e6e463          	bltu	a3,a4,99c <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 998:	fee7eae3          	bltu	a5,a4,98c <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 99c:	ff852583          	lw	a1,-8(a0)
 9a0:	6390                	ld	a2,0(a5)
 9a2:	02059713          	slli	a4,a1,0x20
 9a6:	9301                	srli	a4,a4,0x20
 9a8:	0712                	slli	a4,a4,0x4
 9aa:	9736                	add	a4,a4,a3
 9ac:	fae60ae3          	beq	a2,a4,960 <free+0x14>
    bp->s.ptr = p->s.ptr;
 9b0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9b4:	4790                	lw	a2,8(a5)
 9b6:	02061713          	slli	a4,a2,0x20
 9ba:	9301                	srli	a4,a4,0x20
 9bc:	0712                	slli	a4,a4,0x4
 9be:	973e                	add	a4,a4,a5
 9c0:	fae689e3          	beq	a3,a4,972 <free+0x26>
  } else
    p->s.ptr = bp;
 9c4:	e394                	sd	a3,0(a5)
  freep = p;
 9c6:	00000717          	auipc	a4,0x0
 9ca:	62f73d23          	sd	a5,1594(a4) # 1000 <freep>
}
 9ce:	6422                	ld	s0,8(sp)
 9d0:	0141                	addi	sp,sp,16
 9d2:	8082                	ret

00000000000009d4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9d4:	7139                	addi	sp,sp,-64
 9d6:	fc06                	sd	ra,56(sp)
 9d8:	f822                	sd	s0,48(sp)
 9da:	f426                	sd	s1,40(sp)
 9dc:	f04a                	sd	s2,32(sp)
 9de:	ec4e                	sd	s3,24(sp)
 9e0:	e852                	sd	s4,16(sp)
 9e2:	e456                	sd	s5,8(sp)
 9e4:	e05a                	sd	s6,0(sp)
 9e6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9e8:	02051493          	slli	s1,a0,0x20
 9ec:	9081                	srli	s1,s1,0x20
 9ee:	04bd                	addi	s1,s1,15
 9f0:	8091                	srli	s1,s1,0x4
 9f2:	0014899b          	addiw	s3,s1,1
 9f6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9f8:	00000517          	auipc	a0,0x0
 9fc:	60853503          	ld	a0,1544(a0) # 1000 <freep>
 a00:	c515                	beqz	a0,a2c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a02:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a04:	4798                	lw	a4,8(a5)
 a06:	02977f63          	bgeu	a4,s1,a44 <malloc+0x70>
 a0a:	8a4e                	mv	s4,s3
 a0c:	0009871b          	sext.w	a4,s3
 a10:	6685                	lui	a3,0x1
 a12:	00d77363          	bgeu	a4,a3,a18 <malloc+0x44>
 a16:	6a05                	lui	s4,0x1
 a18:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a1c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a20:	00000917          	auipc	s2,0x0
 a24:	5e090913          	addi	s2,s2,1504 # 1000 <freep>
  if(p == SBRK_ERROR)
 a28:	5afd                	li	s5,-1
 a2a:	a0bd                	j	a98 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 a2c:	00000797          	auipc	a5,0x0
 a30:	5f478793          	addi	a5,a5,1524 # 1020 <base>
 a34:	00000717          	auipc	a4,0x0
 a38:	5cf73623          	sd	a5,1484(a4) # 1000 <freep>
 a3c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a3e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a42:	b7e1                	j	a0a <malloc+0x36>
      if(p->s.size == nunits)
 a44:	02e48b63          	beq	s1,a4,a7a <malloc+0xa6>
        p->s.size -= nunits;
 a48:	4137073b          	subw	a4,a4,s3
 a4c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a4e:	1702                	slli	a4,a4,0x20
 a50:	9301                	srli	a4,a4,0x20
 a52:	0712                	slli	a4,a4,0x4
 a54:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a56:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a5a:	00000717          	auipc	a4,0x0
 a5e:	5aa73323          	sd	a0,1446(a4) # 1000 <freep>
      return (void*)(p + 1);
 a62:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a66:	70e2                	ld	ra,56(sp)
 a68:	7442                	ld	s0,48(sp)
 a6a:	74a2                	ld	s1,40(sp)
 a6c:	7902                	ld	s2,32(sp)
 a6e:	69e2                	ld	s3,24(sp)
 a70:	6a42                	ld	s4,16(sp)
 a72:	6aa2                	ld	s5,8(sp)
 a74:	6b02                	ld	s6,0(sp)
 a76:	6121                	addi	sp,sp,64
 a78:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a7a:	6398                	ld	a4,0(a5)
 a7c:	e118                	sd	a4,0(a0)
 a7e:	bff1                	j	a5a <malloc+0x86>
  hp->s.size = nu;
 a80:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a84:	0541                	addi	a0,a0,16
 a86:	ec7ff0ef          	jal	ra,94c <free>
  return freep;
 a8a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a8e:	dd61                	beqz	a0,a66 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a90:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a92:	4798                	lw	a4,8(a5)
 a94:	fa9778e3          	bgeu	a4,s1,a44 <malloc+0x70>
    if(p == freep)
 a98:	00093703          	ld	a4,0(s2)
 a9c:	853e                	mv	a0,a5
 a9e:	fef719e3          	bne	a4,a5,a90 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 aa2:	8552                	mv	a0,s4
 aa4:	a27ff0ef          	jal	ra,4ca <sbrk>
  if(p == SBRK_ERROR)
 aa8:	fd551ce3          	bne	a0,s5,a80 <malloc+0xac>
        return 0;
 aac:	4501                	li	a0,0
 aae:	bf65                	j	a66 <malloc+0x92>
