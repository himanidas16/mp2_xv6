
user/_stressfs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"

int
main(int argc, char *argv[])
{
   0:	dd010113          	addi	sp,sp,-560
   4:	22113423          	sd	ra,552(sp)
   8:	22813023          	sd	s0,544(sp)
   c:	20913c23          	sd	s1,536(sp)
  10:	21213823          	sd	s2,528(sp)
  14:	1c00                	addi	s0,sp,560
  int fd, i;
  char path[] = "stressfs0";
  16:	00001797          	auipc	a5,0x1
  1a:	93a78793          	addi	a5,a5,-1734 # 950 <malloc+0x10c>
  1e:	6398                	ld	a4,0(a5)
  20:	fce43823          	sd	a4,-48(s0)
  24:	0087d783          	lhu	a5,8(a5)
  28:	fcf41c23          	sh	a5,-40(s0)
  char data[512];

  printf("stressfs starting\n");
  2c:	00001517          	auipc	a0,0x1
  30:	8f450513          	addi	a0,a0,-1804 # 920 <malloc+0xdc>
  34:	756000ef          	jal	ra,78a <printf>
  memset(data, 'a', sizeof(data));
  38:	20000613          	li	a2,512
  3c:	06100593          	li	a1,97
  40:	dd040513          	addi	a0,s0,-560
  44:	116000ef          	jal	ra,15a <memset>

  for(i = 0; i < 4; i++)
  48:	4481                	li	s1,0
  4a:	4911                	li	s2,4
    if(fork() > 0)
  4c:	31a000ef          	jal	ra,366 <fork>
  50:	00a04563          	bgtz	a0,5a <main+0x5a>
  for(i = 0; i < 4; i++)
  54:	2485                	addiw	s1,s1,1
  56:	ff249be3          	bne	s1,s2,4c <main+0x4c>
      break;

  printf("write %d\n", i);
  5a:	85a6                	mv	a1,s1
  5c:	00001517          	auipc	a0,0x1
  60:	8dc50513          	addi	a0,a0,-1828 # 938 <malloc+0xf4>
  64:	726000ef          	jal	ra,78a <printf>

  path[8] += i;
  68:	fd844783          	lbu	a5,-40(s0)
  6c:	9cbd                	addw	s1,s1,a5
  6e:	fc940c23          	sb	s1,-40(s0)
  fd = open(path, O_CREATE | O_RDWR);
  72:	20200593          	li	a1,514
  76:	fd040513          	addi	a0,s0,-48
  7a:	334000ef          	jal	ra,3ae <open>
  7e:	892a                	mv	s2,a0
  80:	44d1                	li	s1,20
  for(i = 0; i < 20; i++)
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  82:	20000613          	li	a2,512
  86:	dd040593          	addi	a1,s0,-560
  8a:	854a                	mv	a0,s2
  8c:	302000ef          	jal	ra,38e <write>
  for(i = 0; i < 20; i++)
  90:	34fd                	addiw	s1,s1,-1
  92:	f8e5                	bnez	s1,82 <main+0x82>
  close(fd);
  94:	854a                	mv	a0,s2
  96:	300000ef          	jal	ra,396 <close>

  printf("read\n");
  9a:	00001517          	auipc	a0,0x1
  9e:	8ae50513          	addi	a0,a0,-1874 # 948 <malloc+0x104>
  a2:	6e8000ef          	jal	ra,78a <printf>

  fd = open(path, O_RDONLY);
  a6:	4581                	li	a1,0
  a8:	fd040513          	addi	a0,s0,-48
  ac:	302000ef          	jal	ra,3ae <open>
  b0:	892a                	mv	s2,a0
  b2:	44d1                	li	s1,20
  for (i = 0; i < 20; i++)
    read(fd, data, sizeof(data));
  b4:	20000613          	li	a2,512
  b8:	dd040593          	addi	a1,s0,-560
  bc:	854a                	mv	a0,s2
  be:	2c8000ef          	jal	ra,386 <read>
  for (i = 0; i < 20; i++)
  c2:	34fd                	addiw	s1,s1,-1
  c4:	f8e5                	bnez	s1,b4 <main+0xb4>
  close(fd);
  c6:	854a                	mv	a0,s2
  c8:	2ce000ef          	jal	ra,396 <close>

  wait(0);
  cc:	4501                	li	a0,0
  ce:	2a8000ef          	jal	ra,376 <wait>

  exit(0);
  d2:	4501                	li	a0,0
  d4:	29a000ef          	jal	ra,36e <exit>

00000000000000d8 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  d8:	1141                	addi	sp,sp,-16
  da:	e406                	sd	ra,8(sp)
  dc:	e022                	sd	s0,0(sp)
  de:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  e0:	f21ff0ef          	jal	ra,0 <main>
  exit(r);
  e4:	28a000ef          	jal	ra,36e <exit>

00000000000000e8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  e8:	1141                	addi	sp,sp,-16
  ea:	e422                	sd	s0,8(sp)
  ec:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ee:	87aa                	mv	a5,a0
  f0:	0585                	addi	a1,a1,1
  f2:	0785                	addi	a5,a5,1
  f4:	fff5c703          	lbu	a4,-1(a1)
  f8:	fee78fa3          	sb	a4,-1(a5)
  fc:	fb75                	bnez	a4,f0 <strcpy+0x8>
    ;
  return os;
}
  fe:	6422                	ld	s0,8(sp)
 100:	0141                	addi	sp,sp,16
 102:	8082                	ret

0000000000000104 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 104:	1141                	addi	sp,sp,-16
 106:	e422                	sd	s0,8(sp)
 108:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 10a:	00054783          	lbu	a5,0(a0)
 10e:	cb91                	beqz	a5,122 <strcmp+0x1e>
 110:	0005c703          	lbu	a4,0(a1)
 114:	00f71763          	bne	a4,a5,122 <strcmp+0x1e>
    p++, q++;
 118:	0505                	addi	a0,a0,1
 11a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 11c:	00054783          	lbu	a5,0(a0)
 120:	fbe5                	bnez	a5,110 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 122:	0005c503          	lbu	a0,0(a1)
}
 126:	40a7853b          	subw	a0,a5,a0
 12a:	6422                	ld	s0,8(sp)
 12c:	0141                	addi	sp,sp,16
 12e:	8082                	ret

0000000000000130 <strlen>:

uint
strlen(const char *s)
{
 130:	1141                	addi	sp,sp,-16
 132:	e422                	sd	s0,8(sp)
 134:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 136:	00054783          	lbu	a5,0(a0)
 13a:	cf91                	beqz	a5,156 <strlen+0x26>
 13c:	0505                	addi	a0,a0,1
 13e:	87aa                	mv	a5,a0
 140:	4685                	li	a3,1
 142:	9e89                	subw	a3,a3,a0
 144:	00f6853b          	addw	a0,a3,a5
 148:	0785                	addi	a5,a5,1
 14a:	fff7c703          	lbu	a4,-1(a5)
 14e:	fb7d                	bnez	a4,144 <strlen+0x14>
    ;
  return n;
}
 150:	6422                	ld	s0,8(sp)
 152:	0141                	addi	sp,sp,16
 154:	8082                	ret
  for(n = 0; s[n]; n++)
 156:	4501                	li	a0,0
 158:	bfe5                	j	150 <strlen+0x20>

000000000000015a <memset>:

void*
memset(void *dst, int c, uint n)
{
 15a:	1141                	addi	sp,sp,-16
 15c:	e422                	sd	s0,8(sp)
 15e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 160:	ca19                	beqz	a2,176 <memset+0x1c>
 162:	87aa                	mv	a5,a0
 164:	1602                	slli	a2,a2,0x20
 166:	9201                	srli	a2,a2,0x20
 168:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 16c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 170:	0785                	addi	a5,a5,1
 172:	fee79de3          	bne	a5,a4,16c <memset+0x12>
  }
  return dst;
}
 176:	6422                	ld	s0,8(sp)
 178:	0141                	addi	sp,sp,16
 17a:	8082                	ret

000000000000017c <strchr>:

char*
strchr(const char *s, char c)
{
 17c:	1141                	addi	sp,sp,-16
 17e:	e422                	sd	s0,8(sp)
 180:	0800                	addi	s0,sp,16
  for(; *s; s++)
 182:	00054783          	lbu	a5,0(a0)
 186:	cb99                	beqz	a5,19c <strchr+0x20>
    if(*s == c)
 188:	00f58763          	beq	a1,a5,196 <strchr+0x1a>
  for(; *s; s++)
 18c:	0505                	addi	a0,a0,1
 18e:	00054783          	lbu	a5,0(a0)
 192:	fbfd                	bnez	a5,188 <strchr+0xc>
      return (char*)s;
  return 0;
 194:	4501                	li	a0,0
}
 196:	6422                	ld	s0,8(sp)
 198:	0141                	addi	sp,sp,16
 19a:	8082                	ret
  return 0;
 19c:	4501                	li	a0,0
 19e:	bfe5                	j	196 <strchr+0x1a>

00000000000001a0 <gets>:

char*
gets(char *buf, int max)
{
 1a0:	711d                	addi	sp,sp,-96
 1a2:	ec86                	sd	ra,88(sp)
 1a4:	e8a2                	sd	s0,80(sp)
 1a6:	e4a6                	sd	s1,72(sp)
 1a8:	e0ca                	sd	s2,64(sp)
 1aa:	fc4e                	sd	s3,56(sp)
 1ac:	f852                	sd	s4,48(sp)
 1ae:	f456                	sd	s5,40(sp)
 1b0:	f05a                	sd	s6,32(sp)
 1b2:	ec5e                	sd	s7,24(sp)
 1b4:	1080                	addi	s0,sp,96
 1b6:	8baa                	mv	s7,a0
 1b8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ba:	892a                	mv	s2,a0
 1bc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1be:	4aa9                	li	s5,10
 1c0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1c2:	89a6                	mv	s3,s1
 1c4:	2485                	addiw	s1,s1,1
 1c6:	0344d663          	bge	s1,s4,1f2 <gets+0x52>
    cc = read(0, &c, 1);
 1ca:	4605                	li	a2,1
 1cc:	faf40593          	addi	a1,s0,-81
 1d0:	4501                	li	a0,0
 1d2:	1b4000ef          	jal	ra,386 <read>
    if(cc < 1)
 1d6:	00a05e63          	blez	a0,1f2 <gets+0x52>
    buf[i++] = c;
 1da:	faf44783          	lbu	a5,-81(s0)
 1de:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1e2:	01578763          	beq	a5,s5,1f0 <gets+0x50>
 1e6:	0905                	addi	s2,s2,1
 1e8:	fd679de3          	bne	a5,s6,1c2 <gets+0x22>
  for(i=0; i+1 < max; ){
 1ec:	89a6                	mv	s3,s1
 1ee:	a011                	j	1f2 <gets+0x52>
 1f0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1f2:	99de                	add	s3,s3,s7
 1f4:	00098023          	sb	zero,0(s3)
  return buf;
}
 1f8:	855e                	mv	a0,s7
 1fa:	60e6                	ld	ra,88(sp)
 1fc:	6446                	ld	s0,80(sp)
 1fe:	64a6                	ld	s1,72(sp)
 200:	6906                	ld	s2,64(sp)
 202:	79e2                	ld	s3,56(sp)
 204:	7a42                	ld	s4,48(sp)
 206:	7aa2                	ld	s5,40(sp)
 208:	7b02                	ld	s6,32(sp)
 20a:	6be2                	ld	s7,24(sp)
 20c:	6125                	addi	sp,sp,96
 20e:	8082                	ret

0000000000000210 <stat>:

int
stat(const char *n, struct stat *st)
{
 210:	1101                	addi	sp,sp,-32
 212:	ec06                	sd	ra,24(sp)
 214:	e822                	sd	s0,16(sp)
 216:	e426                	sd	s1,8(sp)
 218:	e04a                	sd	s2,0(sp)
 21a:	1000                	addi	s0,sp,32
 21c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 21e:	4581                	li	a1,0
 220:	18e000ef          	jal	ra,3ae <open>
  if(fd < 0)
 224:	02054163          	bltz	a0,246 <stat+0x36>
 228:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 22a:	85ca                	mv	a1,s2
 22c:	19a000ef          	jal	ra,3c6 <fstat>
 230:	892a                	mv	s2,a0
  close(fd);
 232:	8526                	mv	a0,s1
 234:	162000ef          	jal	ra,396 <close>
  return r;
}
 238:	854a                	mv	a0,s2
 23a:	60e2                	ld	ra,24(sp)
 23c:	6442                	ld	s0,16(sp)
 23e:	64a2                	ld	s1,8(sp)
 240:	6902                	ld	s2,0(sp)
 242:	6105                	addi	sp,sp,32
 244:	8082                	ret
    return -1;
 246:	597d                	li	s2,-1
 248:	bfc5                	j	238 <stat+0x28>

000000000000024a <atoi>:

int
atoi(const char *s)
{
 24a:	1141                	addi	sp,sp,-16
 24c:	e422                	sd	s0,8(sp)
 24e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 250:	00054603          	lbu	a2,0(a0)
 254:	fd06079b          	addiw	a5,a2,-48
 258:	0ff7f793          	andi	a5,a5,255
 25c:	4725                	li	a4,9
 25e:	02f76963          	bltu	a4,a5,290 <atoi+0x46>
 262:	86aa                	mv	a3,a0
  n = 0;
 264:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 266:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 268:	0685                	addi	a3,a3,1
 26a:	0025179b          	slliw	a5,a0,0x2
 26e:	9fa9                	addw	a5,a5,a0
 270:	0017979b          	slliw	a5,a5,0x1
 274:	9fb1                	addw	a5,a5,a2
 276:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 27a:	0006c603          	lbu	a2,0(a3)
 27e:	fd06071b          	addiw	a4,a2,-48
 282:	0ff77713          	andi	a4,a4,255
 286:	fee5f1e3          	bgeu	a1,a4,268 <atoi+0x1e>
  return n;
}
 28a:	6422                	ld	s0,8(sp)
 28c:	0141                	addi	sp,sp,16
 28e:	8082                	ret
  n = 0;
 290:	4501                	li	a0,0
 292:	bfe5                	j	28a <atoi+0x40>

0000000000000294 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 294:	1141                	addi	sp,sp,-16
 296:	e422                	sd	s0,8(sp)
 298:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 29a:	02b57463          	bgeu	a0,a1,2c2 <memmove+0x2e>
    while(n-- > 0)
 29e:	00c05f63          	blez	a2,2bc <memmove+0x28>
 2a2:	1602                	slli	a2,a2,0x20
 2a4:	9201                	srli	a2,a2,0x20
 2a6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2aa:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ac:	0585                	addi	a1,a1,1
 2ae:	0705                	addi	a4,a4,1
 2b0:	fff5c683          	lbu	a3,-1(a1)
 2b4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2b8:	fee79ae3          	bne	a5,a4,2ac <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2bc:	6422                	ld	s0,8(sp)
 2be:	0141                	addi	sp,sp,16
 2c0:	8082                	ret
    dst += n;
 2c2:	00c50733          	add	a4,a0,a2
    src += n;
 2c6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2c8:	fec05ae3          	blez	a2,2bc <memmove+0x28>
 2cc:	fff6079b          	addiw	a5,a2,-1
 2d0:	1782                	slli	a5,a5,0x20
 2d2:	9381                	srli	a5,a5,0x20
 2d4:	fff7c793          	not	a5,a5
 2d8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2da:	15fd                	addi	a1,a1,-1
 2dc:	177d                	addi	a4,a4,-1
 2de:	0005c683          	lbu	a3,0(a1)
 2e2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2e6:	fee79ae3          	bne	a5,a4,2da <memmove+0x46>
 2ea:	bfc9                	j	2bc <memmove+0x28>

00000000000002ec <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2ec:	1141                	addi	sp,sp,-16
 2ee:	e422                	sd	s0,8(sp)
 2f0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2f2:	ca05                	beqz	a2,322 <memcmp+0x36>
 2f4:	fff6069b          	addiw	a3,a2,-1
 2f8:	1682                	slli	a3,a3,0x20
 2fa:	9281                	srli	a3,a3,0x20
 2fc:	0685                	addi	a3,a3,1
 2fe:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 300:	00054783          	lbu	a5,0(a0)
 304:	0005c703          	lbu	a4,0(a1)
 308:	00e79863          	bne	a5,a4,318 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 30c:	0505                	addi	a0,a0,1
    p2++;
 30e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 310:	fed518e3          	bne	a0,a3,300 <memcmp+0x14>
  }
  return 0;
 314:	4501                	li	a0,0
 316:	a019                	j	31c <memcmp+0x30>
      return *p1 - *p2;
 318:	40e7853b          	subw	a0,a5,a4
}
 31c:	6422                	ld	s0,8(sp)
 31e:	0141                	addi	sp,sp,16
 320:	8082                	ret
  return 0;
 322:	4501                	li	a0,0
 324:	bfe5                	j	31c <memcmp+0x30>

0000000000000326 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 326:	1141                	addi	sp,sp,-16
 328:	e406                	sd	ra,8(sp)
 32a:	e022                	sd	s0,0(sp)
 32c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 32e:	f67ff0ef          	jal	ra,294 <memmove>
}
 332:	60a2                	ld	ra,8(sp)
 334:	6402                	ld	s0,0(sp)
 336:	0141                	addi	sp,sp,16
 338:	8082                	ret

000000000000033a <sbrk>:

char *
sbrk(int n) {
 33a:	1141                	addi	sp,sp,-16
 33c:	e406                	sd	ra,8(sp)
 33e:	e022                	sd	s0,0(sp)
 340:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 342:	4585                	li	a1,1
 344:	0b2000ef          	jal	ra,3f6 <sys_sbrk>
}
 348:	60a2                	ld	ra,8(sp)
 34a:	6402                	ld	s0,0(sp)
 34c:	0141                	addi	sp,sp,16
 34e:	8082                	ret

0000000000000350 <sbrklazy>:

char *
sbrklazy(int n) {
 350:	1141                	addi	sp,sp,-16
 352:	e406                	sd	ra,8(sp)
 354:	e022                	sd	s0,0(sp)
 356:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 358:	4589                	li	a1,2
 35a:	09c000ef          	jal	ra,3f6 <sys_sbrk>
}
 35e:	60a2                	ld	ra,8(sp)
 360:	6402                	ld	s0,0(sp)
 362:	0141                	addi	sp,sp,16
 364:	8082                	ret

0000000000000366 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 366:	4885                	li	a7,1
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <exit>:
.global exit
exit:
 li a7, SYS_exit
 36e:	4889                	li	a7,2
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <wait>:
.global wait
wait:
 li a7, SYS_wait
 376:	488d                	li	a7,3
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 37e:	4891                	li	a7,4
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <read>:
.global read
read:
 li a7, SYS_read
 386:	4895                	li	a7,5
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <write>:
.global write
write:
 li a7, SYS_write
 38e:	48c1                	li	a7,16
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <close>:
.global close
close:
 li a7, SYS_close
 396:	48d5                	li	a7,21
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <kill>:
.global kill
kill:
 li a7, SYS_kill
 39e:	4899                	li	a7,6
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3a6:	489d                	li	a7,7
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <open>:
.global open
open:
 li a7, SYS_open
 3ae:	48bd                	li	a7,15
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3b6:	48c5                	li	a7,17
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3be:	48c9                	li	a7,18
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3c6:	48a1                	li	a7,8
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <link>:
.global link
link:
 li a7, SYS_link
 3ce:	48cd                	li	a7,19
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3d6:	48d1                	li	a7,20
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3de:	48a5                	li	a7,9
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3e6:	48a9                	li	a7,10
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3ee:	48ad                	li	a7,11
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3f6:	48b1                	li	a7,12
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <pause>:
.global pause
pause:
 li a7, SYS_pause
 3fe:	48b5                	li	a7,13
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 406:	48b9                	li	a7,14
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 40e:	1101                	addi	sp,sp,-32
 410:	ec06                	sd	ra,24(sp)
 412:	e822                	sd	s0,16(sp)
 414:	1000                	addi	s0,sp,32
 416:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 41a:	4605                	li	a2,1
 41c:	fef40593          	addi	a1,s0,-17
 420:	f6fff0ef          	jal	ra,38e <write>
}
 424:	60e2                	ld	ra,24(sp)
 426:	6442                	ld	s0,16(sp)
 428:	6105                	addi	sp,sp,32
 42a:	8082                	ret

000000000000042c <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 42c:	715d                	addi	sp,sp,-80
 42e:	e486                	sd	ra,72(sp)
 430:	e0a2                	sd	s0,64(sp)
 432:	fc26                	sd	s1,56(sp)
 434:	f84a                	sd	s2,48(sp)
 436:	f44e                	sd	s3,40(sp)
 438:	0880                	addi	s0,sp,80
 43a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 43c:	c299                	beqz	a3,442 <printint+0x16>
 43e:	0805c163          	bltz	a1,4c0 <printint+0x94>
  neg = 0;
 442:	4881                	li	a7,0
 444:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 448:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 44a:	00000517          	auipc	a0,0x0
 44e:	51e50513          	addi	a0,a0,1310 # 968 <digits>
 452:	883e                	mv	a6,a5
 454:	2785                	addiw	a5,a5,1
 456:	02c5f733          	remu	a4,a1,a2
 45a:	972a                	add	a4,a4,a0
 45c:	00074703          	lbu	a4,0(a4)
 460:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 464:	872e                	mv	a4,a1
 466:	02c5d5b3          	divu	a1,a1,a2
 46a:	0685                	addi	a3,a3,1
 46c:	fec773e3          	bgeu	a4,a2,452 <printint+0x26>
  if(neg)
 470:	00088b63          	beqz	a7,486 <printint+0x5a>
    buf[i++] = '-';
 474:	fd040713          	addi	a4,s0,-48
 478:	97ba                	add	a5,a5,a4
 47a:	02d00713          	li	a4,45
 47e:	fee78423          	sb	a4,-24(a5)
 482:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 486:	02f05663          	blez	a5,4b2 <printint+0x86>
 48a:	fb840713          	addi	a4,s0,-72
 48e:	00f704b3          	add	s1,a4,a5
 492:	fff70993          	addi	s3,a4,-1
 496:	99be                	add	s3,s3,a5
 498:	37fd                	addiw	a5,a5,-1
 49a:	1782                	slli	a5,a5,0x20
 49c:	9381                	srli	a5,a5,0x20
 49e:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4a2:	fff4c583          	lbu	a1,-1(s1)
 4a6:	854a                	mv	a0,s2
 4a8:	f67ff0ef          	jal	ra,40e <putc>
  while(--i >= 0)
 4ac:	14fd                	addi	s1,s1,-1
 4ae:	ff349ae3          	bne	s1,s3,4a2 <printint+0x76>
}
 4b2:	60a6                	ld	ra,72(sp)
 4b4:	6406                	ld	s0,64(sp)
 4b6:	74e2                	ld	s1,56(sp)
 4b8:	7942                	ld	s2,48(sp)
 4ba:	79a2                	ld	s3,40(sp)
 4bc:	6161                	addi	sp,sp,80
 4be:	8082                	ret
    x = -xx;
 4c0:	40b005b3          	neg	a1,a1
    neg = 1;
 4c4:	4885                	li	a7,1
    x = -xx;
 4c6:	bfbd                	j	444 <printint+0x18>

00000000000004c8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4c8:	7119                	addi	sp,sp,-128
 4ca:	fc86                	sd	ra,120(sp)
 4cc:	f8a2                	sd	s0,112(sp)
 4ce:	f4a6                	sd	s1,104(sp)
 4d0:	f0ca                	sd	s2,96(sp)
 4d2:	ecce                	sd	s3,88(sp)
 4d4:	e8d2                	sd	s4,80(sp)
 4d6:	e4d6                	sd	s5,72(sp)
 4d8:	e0da                	sd	s6,64(sp)
 4da:	fc5e                	sd	s7,56(sp)
 4dc:	f862                	sd	s8,48(sp)
 4de:	f466                	sd	s9,40(sp)
 4e0:	f06a                	sd	s10,32(sp)
 4e2:	ec6e                	sd	s11,24(sp)
 4e4:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4e6:	0005c903          	lbu	s2,0(a1)
 4ea:	24090c63          	beqz	s2,742 <vprintf+0x27a>
 4ee:	8b2a                	mv	s6,a0
 4f0:	8a2e                	mv	s4,a1
 4f2:	8bb2                	mv	s7,a2
  state = 0;
 4f4:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4f6:	4481                	li	s1,0
 4f8:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4fa:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4fe:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 502:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 506:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 50a:	00000c97          	auipc	s9,0x0
 50e:	45ec8c93          	addi	s9,s9,1118 # 968 <digits>
 512:	a005                	j	532 <vprintf+0x6a>
        putc(fd, c0);
 514:	85ca                	mv	a1,s2
 516:	855a                	mv	a0,s6
 518:	ef7ff0ef          	jal	ra,40e <putc>
 51c:	a019                	j	522 <vprintf+0x5a>
    } else if(state == '%'){
 51e:	03598263          	beq	s3,s5,542 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 522:	2485                	addiw	s1,s1,1
 524:	8726                	mv	a4,s1
 526:	009a07b3          	add	a5,s4,s1
 52a:	0007c903          	lbu	s2,0(a5)
 52e:	20090a63          	beqz	s2,742 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 532:	0009079b          	sext.w	a5,s2
    if(state == 0){
 536:	fe0994e3          	bnez	s3,51e <vprintf+0x56>
      if(c0 == '%'){
 53a:	fd579de3          	bne	a5,s5,514 <vprintf+0x4c>
        state = '%';
 53e:	89be                	mv	s3,a5
 540:	b7cd                	j	522 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 542:	c3c1                	beqz	a5,5c2 <vprintf+0xfa>
 544:	00ea06b3          	add	a3,s4,a4
 548:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 54c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 54e:	c681                	beqz	a3,556 <vprintf+0x8e>
 550:	9752                	add	a4,a4,s4
 552:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 556:	03878e63          	beq	a5,s8,592 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 55a:	05a78863          	beq	a5,s10,5aa <vprintf+0xe2>
      } else if(c0 == 'u'){
 55e:	0db78b63          	beq	a5,s11,634 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 562:	07800713          	li	a4,120
 566:	10e78d63          	beq	a5,a4,680 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 56a:	07000713          	li	a4,112
 56e:	14e78263          	beq	a5,a4,6b2 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 572:	06300713          	li	a4,99
 576:	16e78f63          	beq	a5,a4,6f4 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 57a:	07300713          	li	a4,115
 57e:	18e78563          	beq	a5,a4,708 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 582:	05579063          	bne	a5,s5,5c2 <vprintf+0xfa>
        putc(fd, '%');
 586:	85d6                	mv	a1,s5
 588:	855a                	mv	a0,s6
 58a:	e85ff0ef          	jal	ra,40e <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 58e:	4981                	li	s3,0
 590:	bf49                	j	522 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 592:	008b8913          	addi	s2,s7,8
 596:	4685                	li	a3,1
 598:	4629                	li	a2,10
 59a:	000ba583          	lw	a1,0(s7)
 59e:	855a                	mv	a0,s6
 5a0:	e8dff0ef          	jal	ra,42c <printint>
 5a4:	8bca                	mv	s7,s2
      state = 0;
 5a6:	4981                	li	s3,0
 5a8:	bfad                	j	522 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5aa:	03868663          	beq	a3,s8,5d6 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5ae:	05a68163          	beq	a3,s10,5f0 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 5b2:	09b68d63          	beq	a3,s11,64c <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5b6:	03a68f63          	beq	a3,s10,5f4 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 5ba:	07800793          	li	a5,120
 5be:	0cf68d63          	beq	a3,a5,698 <vprintf+0x1d0>
        putc(fd, '%');
 5c2:	85d6                	mv	a1,s5
 5c4:	855a                	mv	a0,s6
 5c6:	e49ff0ef          	jal	ra,40e <putc>
        putc(fd, c0);
 5ca:	85ca                	mv	a1,s2
 5cc:	855a                	mv	a0,s6
 5ce:	e41ff0ef          	jal	ra,40e <putc>
      state = 0;
 5d2:	4981                	li	s3,0
 5d4:	b7b9                	j	522 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5d6:	008b8913          	addi	s2,s7,8
 5da:	4685                	li	a3,1
 5dc:	4629                	li	a2,10
 5de:	000bb583          	ld	a1,0(s7)
 5e2:	855a                	mv	a0,s6
 5e4:	e49ff0ef          	jal	ra,42c <printint>
        i += 1;
 5e8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ea:	8bca                	mv	s7,s2
      state = 0;
 5ec:	4981                	li	s3,0
        i += 1;
 5ee:	bf15                	j	522 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5f0:	03860563          	beq	a2,s8,61a <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5f4:	07b60963          	beq	a2,s11,666 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5f8:	07800793          	li	a5,120
 5fc:	fcf613e3          	bne	a2,a5,5c2 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 600:	008b8913          	addi	s2,s7,8
 604:	4681                	li	a3,0
 606:	4641                	li	a2,16
 608:	000bb583          	ld	a1,0(s7)
 60c:	855a                	mv	a0,s6
 60e:	e1fff0ef          	jal	ra,42c <printint>
        i += 2;
 612:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 614:	8bca                	mv	s7,s2
      state = 0;
 616:	4981                	li	s3,0
        i += 2;
 618:	b729                	j	522 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 61a:	008b8913          	addi	s2,s7,8
 61e:	4685                	li	a3,1
 620:	4629                	li	a2,10
 622:	000bb583          	ld	a1,0(s7)
 626:	855a                	mv	a0,s6
 628:	e05ff0ef          	jal	ra,42c <printint>
        i += 2;
 62c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 62e:	8bca                	mv	s7,s2
      state = 0;
 630:	4981                	li	s3,0
        i += 2;
 632:	bdc5                	j	522 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 634:	008b8913          	addi	s2,s7,8
 638:	4681                	li	a3,0
 63a:	4629                	li	a2,10
 63c:	000be583          	lwu	a1,0(s7)
 640:	855a                	mv	a0,s6
 642:	debff0ef          	jal	ra,42c <printint>
 646:	8bca                	mv	s7,s2
      state = 0;
 648:	4981                	li	s3,0
 64a:	bde1                	j	522 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 64c:	008b8913          	addi	s2,s7,8
 650:	4681                	li	a3,0
 652:	4629                	li	a2,10
 654:	000bb583          	ld	a1,0(s7)
 658:	855a                	mv	a0,s6
 65a:	dd3ff0ef          	jal	ra,42c <printint>
        i += 1;
 65e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 660:	8bca                	mv	s7,s2
      state = 0;
 662:	4981                	li	s3,0
        i += 1;
 664:	bd7d                	j	522 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 666:	008b8913          	addi	s2,s7,8
 66a:	4681                	li	a3,0
 66c:	4629                	li	a2,10
 66e:	000bb583          	ld	a1,0(s7)
 672:	855a                	mv	a0,s6
 674:	db9ff0ef          	jal	ra,42c <printint>
        i += 2;
 678:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 67a:	8bca                	mv	s7,s2
      state = 0;
 67c:	4981                	li	s3,0
        i += 2;
 67e:	b555                	j	522 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 680:	008b8913          	addi	s2,s7,8
 684:	4681                	li	a3,0
 686:	4641                	li	a2,16
 688:	000be583          	lwu	a1,0(s7)
 68c:	855a                	mv	a0,s6
 68e:	d9fff0ef          	jal	ra,42c <printint>
 692:	8bca                	mv	s7,s2
      state = 0;
 694:	4981                	li	s3,0
 696:	b571                	j	522 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 698:	008b8913          	addi	s2,s7,8
 69c:	4681                	li	a3,0
 69e:	4641                	li	a2,16
 6a0:	000bb583          	ld	a1,0(s7)
 6a4:	855a                	mv	a0,s6
 6a6:	d87ff0ef          	jal	ra,42c <printint>
        i += 1;
 6aa:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ac:	8bca                	mv	s7,s2
      state = 0;
 6ae:	4981                	li	s3,0
        i += 1;
 6b0:	bd8d                	j	522 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6b2:	008b8793          	addi	a5,s7,8
 6b6:	f8f43423          	sd	a5,-120(s0)
 6ba:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6be:	03000593          	li	a1,48
 6c2:	855a                	mv	a0,s6
 6c4:	d4bff0ef          	jal	ra,40e <putc>
  putc(fd, 'x');
 6c8:	07800593          	li	a1,120
 6cc:	855a                	mv	a0,s6
 6ce:	d41ff0ef          	jal	ra,40e <putc>
 6d2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6d4:	03c9d793          	srli	a5,s3,0x3c
 6d8:	97e6                	add	a5,a5,s9
 6da:	0007c583          	lbu	a1,0(a5)
 6de:	855a                	mv	a0,s6
 6e0:	d2fff0ef          	jal	ra,40e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6e4:	0992                	slli	s3,s3,0x4
 6e6:	397d                	addiw	s2,s2,-1
 6e8:	fe0916e3          	bnez	s2,6d4 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 6ec:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 6f0:	4981                	li	s3,0
 6f2:	bd05                	j	522 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 6f4:	008b8913          	addi	s2,s7,8
 6f8:	000bc583          	lbu	a1,0(s7)
 6fc:	855a                	mv	a0,s6
 6fe:	d11ff0ef          	jal	ra,40e <putc>
 702:	8bca                	mv	s7,s2
      state = 0;
 704:	4981                	li	s3,0
 706:	bd31                	j	522 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 708:	008b8993          	addi	s3,s7,8
 70c:	000bb903          	ld	s2,0(s7)
 710:	00090f63          	beqz	s2,72e <vprintf+0x266>
        for(; *s; s++)
 714:	00094583          	lbu	a1,0(s2)
 718:	c195                	beqz	a1,73c <vprintf+0x274>
          putc(fd, *s);
 71a:	855a                	mv	a0,s6
 71c:	cf3ff0ef          	jal	ra,40e <putc>
        for(; *s; s++)
 720:	0905                	addi	s2,s2,1
 722:	00094583          	lbu	a1,0(s2)
 726:	f9f5                	bnez	a1,71a <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 728:	8bce                	mv	s7,s3
      state = 0;
 72a:	4981                	li	s3,0
 72c:	bbdd                	j	522 <vprintf+0x5a>
          s = "(null)";
 72e:	00000917          	auipc	s2,0x0
 732:	23290913          	addi	s2,s2,562 # 960 <malloc+0x11c>
        for(; *s; s++)
 736:	02800593          	li	a1,40
 73a:	b7c5                	j	71a <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 73c:	8bce                	mv	s7,s3
      state = 0;
 73e:	4981                	li	s3,0
 740:	b3cd                	j	522 <vprintf+0x5a>
    }
  }
}
 742:	70e6                	ld	ra,120(sp)
 744:	7446                	ld	s0,112(sp)
 746:	74a6                	ld	s1,104(sp)
 748:	7906                	ld	s2,96(sp)
 74a:	69e6                	ld	s3,88(sp)
 74c:	6a46                	ld	s4,80(sp)
 74e:	6aa6                	ld	s5,72(sp)
 750:	6b06                	ld	s6,64(sp)
 752:	7be2                	ld	s7,56(sp)
 754:	7c42                	ld	s8,48(sp)
 756:	7ca2                	ld	s9,40(sp)
 758:	7d02                	ld	s10,32(sp)
 75a:	6de2                	ld	s11,24(sp)
 75c:	6109                	addi	sp,sp,128
 75e:	8082                	ret

0000000000000760 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 760:	715d                	addi	sp,sp,-80
 762:	ec06                	sd	ra,24(sp)
 764:	e822                	sd	s0,16(sp)
 766:	1000                	addi	s0,sp,32
 768:	e010                	sd	a2,0(s0)
 76a:	e414                	sd	a3,8(s0)
 76c:	e818                	sd	a4,16(s0)
 76e:	ec1c                	sd	a5,24(s0)
 770:	03043023          	sd	a6,32(s0)
 774:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 778:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 77c:	8622                	mv	a2,s0
 77e:	d4bff0ef          	jal	ra,4c8 <vprintf>
}
 782:	60e2                	ld	ra,24(sp)
 784:	6442                	ld	s0,16(sp)
 786:	6161                	addi	sp,sp,80
 788:	8082                	ret

000000000000078a <printf>:

void
printf(const char *fmt, ...)
{
 78a:	711d                	addi	sp,sp,-96
 78c:	ec06                	sd	ra,24(sp)
 78e:	e822                	sd	s0,16(sp)
 790:	1000                	addi	s0,sp,32
 792:	e40c                	sd	a1,8(s0)
 794:	e810                	sd	a2,16(s0)
 796:	ec14                	sd	a3,24(s0)
 798:	f018                	sd	a4,32(s0)
 79a:	f41c                	sd	a5,40(s0)
 79c:	03043823          	sd	a6,48(s0)
 7a0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7a4:	00840613          	addi	a2,s0,8
 7a8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7ac:	85aa                	mv	a1,a0
 7ae:	4505                	li	a0,1
 7b0:	d19ff0ef          	jal	ra,4c8 <vprintf>
}
 7b4:	60e2                	ld	ra,24(sp)
 7b6:	6442                	ld	s0,16(sp)
 7b8:	6125                	addi	sp,sp,96
 7ba:	8082                	ret

00000000000007bc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7bc:	1141                	addi	sp,sp,-16
 7be:	e422                	sd	s0,8(sp)
 7c0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7c2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c6:	00001797          	auipc	a5,0x1
 7ca:	83a7b783          	ld	a5,-1990(a5) # 1000 <freep>
 7ce:	a805                	j	7fe <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7d0:	4618                	lw	a4,8(a2)
 7d2:	9db9                	addw	a1,a1,a4
 7d4:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7d8:	6398                	ld	a4,0(a5)
 7da:	6318                	ld	a4,0(a4)
 7dc:	fee53823          	sd	a4,-16(a0)
 7e0:	a091                	j	824 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7e2:	ff852703          	lw	a4,-8(a0)
 7e6:	9e39                	addw	a2,a2,a4
 7e8:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7ea:	ff053703          	ld	a4,-16(a0)
 7ee:	e398                	sd	a4,0(a5)
 7f0:	a099                	j	836 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f2:	6398                	ld	a4,0(a5)
 7f4:	00e7e463          	bltu	a5,a4,7fc <free+0x40>
 7f8:	00e6ea63          	bltu	a3,a4,80c <free+0x50>
{
 7fc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7fe:	fed7fae3          	bgeu	a5,a3,7f2 <free+0x36>
 802:	6398                	ld	a4,0(a5)
 804:	00e6e463          	bltu	a3,a4,80c <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 808:	fee7eae3          	bltu	a5,a4,7fc <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 80c:	ff852583          	lw	a1,-8(a0)
 810:	6390                	ld	a2,0(a5)
 812:	02059713          	slli	a4,a1,0x20
 816:	9301                	srli	a4,a4,0x20
 818:	0712                	slli	a4,a4,0x4
 81a:	9736                	add	a4,a4,a3
 81c:	fae60ae3          	beq	a2,a4,7d0 <free+0x14>
    bp->s.ptr = p->s.ptr;
 820:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 824:	4790                	lw	a2,8(a5)
 826:	02061713          	slli	a4,a2,0x20
 82a:	9301                	srli	a4,a4,0x20
 82c:	0712                	slli	a4,a4,0x4
 82e:	973e                	add	a4,a4,a5
 830:	fae689e3          	beq	a3,a4,7e2 <free+0x26>
  } else
    p->s.ptr = bp;
 834:	e394                	sd	a3,0(a5)
  freep = p;
 836:	00000717          	auipc	a4,0x0
 83a:	7cf73523          	sd	a5,1994(a4) # 1000 <freep>
}
 83e:	6422                	ld	s0,8(sp)
 840:	0141                	addi	sp,sp,16
 842:	8082                	ret

0000000000000844 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 844:	7139                	addi	sp,sp,-64
 846:	fc06                	sd	ra,56(sp)
 848:	f822                	sd	s0,48(sp)
 84a:	f426                	sd	s1,40(sp)
 84c:	f04a                	sd	s2,32(sp)
 84e:	ec4e                	sd	s3,24(sp)
 850:	e852                	sd	s4,16(sp)
 852:	e456                	sd	s5,8(sp)
 854:	e05a                	sd	s6,0(sp)
 856:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 858:	02051493          	slli	s1,a0,0x20
 85c:	9081                	srli	s1,s1,0x20
 85e:	04bd                	addi	s1,s1,15
 860:	8091                	srli	s1,s1,0x4
 862:	0014899b          	addiw	s3,s1,1
 866:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 868:	00000517          	auipc	a0,0x0
 86c:	79853503          	ld	a0,1944(a0) # 1000 <freep>
 870:	c515                	beqz	a0,89c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 872:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 874:	4798                	lw	a4,8(a5)
 876:	02977f63          	bgeu	a4,s1,8b4 <malloc+0x70>
 87a:	8a4e                	mv	s4,s3
 87c:	0009871b          	sext.w	a4,s3
 880:	6685                	lui	a3,0x1
 882:	00d77363          	bgeu	a4,a3,888 <malloc+0x44>
 886:	6a05                	lui	s4,0x1
 888:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 88c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 890:	00000917          	auipc	s2,0x0
 894:	77090913          	addi	s2,s2,1904 # 1000 <freep>
  if(p == SBRK_ERROR)
 898:	5afd                	li	s5,-1
 89a:	a0bd                	j	908 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 89c:	00000797          	auipc	a5,0x0
 8a0:	77478793          	addi	a5,a5,1908 # 1010 <base>
 8a4:	00000717          	auipc	a4,0x0
 8a8:	74f73e23          	sd	a5,1884(a4) # 1000 <freep>
 8ac:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ae:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8b2:	b7e1                	j	87a <malloc+0x36>
      if(p->s.size == nunits)
 8b4:	02e48b63          	beq	s1,a4,8ea <malloc+0xa6>
        p->s.size -= nunits;
 8b8:	4137073b          	subw	a4,a4,s3
 8bc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8be:	1702                	slli	a4,a4,0x20
 8c0:	9301                	srli	a4,a4,0x20
 8c2:	0712                	slli	a4,a4,0x4
 8c4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8c6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ca:	00000717          	auipc	a4,0x0
 8ce:	72a73b23          	sd	a0,1846(a4) # 1000 <freep>
      return (void*)(p + 1);
 8d2:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8d6:	70e2                	ld	ra,56(sp)
 8d8:	7442                	ld	s0,48(sp)
 8da:	74a2                	ld	s1,40(sp)
 8dc:	7902                	ld	s2,32(sp)
 8de:	69e2                	ld	s3,24(sp)
 8e0:	6a42                	ld	s4,16(sp)
 8e2:	6aa2                	ld	s5,8(sp)
 8e4:	6b02                	ld	s6,0(sp)
 8e6:	6121                	addi	sp,sp,64
 8e8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8ea:	6398                	ld	a4,0(a5)
 8ec:	e118                	sd	a4,0(a0)
 8ee:	bff1                	j	8ca <malloc+0x86>
  hp->s.size = nu;
 8f0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8f4:	0541                	addi	a0,a0,16
 8f6:	ec7ff0ef          	jal	ra,7bc <free>
  return freep;
 8fa:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8fe:	dd61                	beqz	a0,8d6 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 900:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 902:	4798                	lw	a4,8(a5)
 904:	fa9778e3          	bgeu	a4,s1,8b4 <malloc+0x70>
    if(p == freep)
 908:	00093703          	ld	a4,0(s2)
 90c:	853e                	mv	a0,a5
 90e:	fef719e3          	bne	a4,a5,900 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 912:	8552                	mv	a0,s4
 914:	a27ff0ef          	jal	ra,33a <sbrk>
  if(p == SBRK_ERROR)
 918:	fd551ce3          	bne	a0,s5,8f0 <malloc+0xac>
        return 0;
 91c:	4501                	li	a0,0
 91e:	bf65                	j	8d6 <malloc+0x92>
