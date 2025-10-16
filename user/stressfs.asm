
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
  1a:	94a78793          	addi	a5,a5,-1718 # 960 <malloc+0x114>
  1e:	6398                	ld	a4,0(a5)
  20:	fce43823          	sd	a4,-48(s0)
  24:	0087d783          	lhu	a5,8(a5)
  28:	fcf41c23          	sh	a5,-40(s0)
  char data[512];

  printf("stressfs starting\n");
  2c:	00001517          	auipc	a0,0x1
  30:	90450513          	addi	a0,a0,-1788 # 930 <malloc+0xe4>
  34:	75e000ef          	jal	ra,792 <printf>
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
  60:	8ec50513          	addi	a0,a0,-1812 # 948 <malloc+0xfc>
  64:	72e000ef          	jal	ra,792 <printf>

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
  9e:	8be50513          	addi	a0,a0,-1858 # 958 <malloc+0x10c>
  a2:	6f0000ef          	jal	ra,792 <printf>

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

000000000000040e <memstat>:
.global memstat
memstat:
 li a7, SYS_memstat
 40e:	48d9                	li	a7,22
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 416:	1101                	addi	sp,sp,-32
 418:	ec06                	sd	ra,24(sp)
 41a:	e822                	sd	s0,16(sp)
 41c:	1000                	addi	s0,sp,32
 41e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 422:	4605                	li	a2,1
 424:	fef40593          	addi	a1,s0,-17
 428:	f67ff0ef          	jal	ra,38e <write>
}
 42c:	60e2                	ld	ra,24(sp)
 42e:	6442                	ld	s0,16(sp)
 430:	6105                	addi	sp,sp,32
 432:	8082                	ret

0000000000000434 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 434:	715d                	addi	sp,sp,-80
 436:	e486                	sd	ra,72(sp)
 438:	e0a2                	sd	s0,64(sp)
 43a:	fc26                	sd	s1,56(sp)
 43c:	f84a                	sd	s2,48(sp)
 43e:	f44e                	sd	s3,40(sp)
 440:	0880                	addi	s0,sp,80
 442:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 444:	c299                	beqz	a3,44a <printint+0x16>
 446:	0805c163          	bltz	a1,4c8 <printint+0x94>
  neg = 0;
 44a:	4881                	li	a7,0
 44c:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 450:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 452:	00000517          	auipc	a0,0x0
 456:	52650513          	addi	a0,a0,1318 # 978 <digits>
 45a:	883e                	mv	a6,a5
 45c:	2785                	addiw	a5,a5,1
 45e:	02c5f733          	remu	a4,a1,a2
 462:	972a                	add	a4,a4,a0
 464:	00074703          	lbu	a4,0(a4)
 468:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 46c:	872e                	mv	a4,a1
 46e:	02c5d5b3          	divu	a1,a1,a2
 472:	0685                	addi	a3,a3,1
 474:	fec773e3          	bgeu	a4,a2,45a <printint+0x26>
  if(neg)
 478:	00088b63          	beqz	a7,48e <printint+0x5a>
    buf[i++] = '-';
 47c:	fd040713          	addi	a4,s0,-48
 480:	97ba                	add	a5,a5,a4
 482:	02d00713          	li	a4,45
 486:	fee78423          	sb	a4,-24(a5)
 48a:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 48e:	02f05663          	blez	a5,4ba <printint+0x86>
 492:	fb840713          	addi	a4,s0,-72
 496:	00f704b3          	add	s1,a4,a5
 49a:	fff70993          	addi	s3,a4,-1
 49e:	99be                	add	s3,s3,a5
 4a0:	37fd                	addiw	a5,a5,-1
 4a2:	1782                	slli	a5,a5,0x20
 4a4:	9381                	srli	a5,a5,0x20
 4a6:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4aa:	fff4c583          	lbu	a1,-1(s1)
 4ae:	854a                	mv	a0,s2
 4b0:	f67ff0ef          	jal	ra,416 <putc>
  while(--i >= 0)
 4b4:	14fd                	addi	s1,s1,-1
 4b6:	ff349ae3          	bne	s1,s3,4aa <printint+0x76>
}
 4ba:	60a6                	ld	ra,72(sp)
 4bc:	6406                	ld	s0,64(sp)
 4be:	74e2                	ld	s1,56(sp)
 4c0:	7942                	ld	s2,48(sp)
 4c2:	79a2                	ld	s3,40(sp)
 4c4:	6161                	addi	sp,sp,80
 4c6:	8082                	ret
    x = -xx;
 4c8:	40b005b3          	neg	a1,a1
    neg = 1;
 4cc:	4885                	li	a7,1
    x = -xx;
 4ce:	bfbd                	j	44c <printint+0x18>

00000000000004d0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4d0:	7119                	addi	sp,sp,-128
 4d2:	fc86                	sd	ra,120(sp)
 4d4:	f8a2                	sd	s0,112(sp)
 4d6:	f4a6                	sd	s1,104(sp)
 4d8:	f0ca                	sd	s2,96(sp)
 4da:	ecce                	sd	s3,88(sp)
 4dc:	e8d2                	sd	s4,80(sp)
 4de:	e4d6                	sd	s5,72(sp)
 4e0:	e0da                	sd	s6,64(sp)
 4e2:	fc5e                	sd	s7,56(sp)
 4e4:	f862                	sd	s8,48(sp)
 4e6:	f466                	sd	s9,40(sp)
 4e8:	f06a                	sd	s10,32(sp)
 4ea:	ec6e                	sd	s11,24(sp)
 4ec:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4ee:	0005c903          	lbu	s2,0(a1)
 4f2:	24090c63          	beqz	s2,74a <vprintf+0x27a>
 4f6:	8b2a                	mv	s6,a0
 4f8:	8a2e                	mv	s4,a1
 4fa:	8bb2                	mv	s7,a2
  state = 0;
 4fc:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4fe:	4481                	li	s1,0
 500:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 502:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 506:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 50a:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 50e:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 512:	00000c97          	auipc	s9,0x0
 516:	466c8c93          	addi	s9,s9,1126 # 978 <digits>
 51a:	a005                	j	53a <vprintf+0x6a>
        putc(fd, c0);
 51c:	85ca                	mv	a1,s2
 51e:	855a                	mv	a0,s6
 520:	ef7ff0ef          	jal	ra,416 <putc>
 524:	a019                	j	52a <vprintf+0x5a>
    } else if(state == '%'){
 526:	03598263          	beq	s3,s5,54a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 52a:	2485                	addiw	s1,s1,1
 52c:	8726                	mv	a4,s1
 52e:	009a07b3          	add	a5,s4,s1
 532:	0007c903          	lbu	s2,0(a5)
 536:	20090a63          	beqz	s2,74a <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 53a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 53e:	fe0994e3          	bnez	s3,526 <vprintf+0x56>
      if(c0 == '%'){
 542:	fd579de3          	bne	a5,s5,51c <vprintf+0x4c>
        state = '%';
 546:	89be                	mv	s3,a5
 548:	b7cd                	j	52a <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 54a:	c3c1                	beqz	a5,5ca <vprintf+0xfa>
 54c:	00ea06b3          	add	a3,s4,a4
 550:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 554:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 556:	c681                	beqz	a3,55e <vprintf+0x8e>
 558:	9752                	add	a4,a4,s4
 55a:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 55e:	03878e63          	beq	a5,s8,59a <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 562:	05a78863          	beq	a5,s10,5b2 <vprintf+0xe2>
      } else if(c0 == 'u'){
 566:	0db78b63          	beq	a5,s11,63c <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 56a:	07800713          	li	a4,120
 56e:	10e78d63          	beq	a5,a4,688 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 572:	07000713          	li	a4,112
 576:	14e78263          	beq	a5,a4,6ba <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 57a:	06300713          	li	a4,99
 57e:	16e78f63          	beq	a5,a4,6fc <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 582:	07300713          	li	a4,115
 586:	18e78563          	beq	a5,a4,710 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 58a:	05579063          	bne	a5,s5,5ca <vprintf+0xfa>
        putc(fd, '%');
 58e:	85d6                	mv	a1,s5
 590:	855a                	mv	a0,s6
 592:	e85ff0ef          	jal	ra,416 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 596:	4981                	li	s3,0
 598:	bf49                	j	52a <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 59a:	008b8913          	addi	s2,s7,8
 59e:	4685                	li	a3,1
 5a0:	4629                	li	a2,10
 5a2:	000ba583          	lw	a1,0(s7)
 5a6:	855a                	mv	a0,s6
 5a8:	e8dff0ef          	jal	ra,434 <printint>
 5ac:	8bca                	mv	s7,s2
      state = 0;
 5ae:	4981                	li	s3,0
 5b0:	bfad                	j	52a <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5b2:	03868663          	beq	a3,s8,5de <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5b6:	05a68163          	beq	a3,s10,5f8 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 5ba:	09b68d63          	beq	a3,s11,654 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5be:	03a68f63          	beq	a3,s10,5fc <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 5c2:	07800793          	li	a5,120
 5c6:	0cf68d63          	beq	a3,a5,6a0 <vprintf+0x1d0>
        putc(fd, '%');
 5ca:	85d6                	mv	a1,s5
 5cc:	855a                	mv	a0,s6
 5ce:	e49ff0ef          	jal	ra,416 <putc>
        putc(fd, c0);
 5d2:	85ca                	mv	a1,s2
 5d4:	855a                	mv	a0,s6
 5d6:	e41ff0ef          	jal	ra,416 <putc>
      state = 0;
 5da:	4981                	li	s3,0
 5dc:	b7b9                	j	52a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5de:	008b8913          	addi	s2,s7,8
 5e2:	4685                	li	a3,1
 5e4:	4629                	li	a2,10
 5e6:	000bb583          	ld	a1,0(s7)
 5ea:	855a                	mv	a0,s6
 5ec:	e49ff0ef          	jal	ra,434 <printint>
        i += 1;
 5f0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5f2:	8bca                	mv	s7,s2
      state = 0;
 5f4:	4981                	li	s3,0
        i += 1;
 5f6:	bf15                	j	52a <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5f8:	03860563          	beq	a2,s8,622 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5fc:	07b60963          	beq	a2,s11,66e <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 600:	07800793          	li	a5,120
 604:	fcf613e3          	bne	a2,a5,5ca <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 608:	008b8913          	addi	s2,s7,8
 60c:	4681                	li	a3,0
 60e:	4641                	li	a2,16
 610:	000bb583          	ld	a1,0(s7)
 614:	855a                	mv	a0,s6
 616:	e1fff0ef          	jal	ra,434 <printint>
        i += 2;
 61a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 61c:	8bca                	mv	s7,s2
      state = 0;
 61e:	4981                	li	s3,0
        i += 2;
 620:	b729                	j	52a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 622:	008b8913          	addi	s2,s7,8
 626:	4685                	li	a3,1
 628:	4629                	li	a2,10
 62a:	000bb583          	ld	a1,0(s7)
 62e:	855a                	mv	a0,s6
 630:	e05ff0ef          	jal	ra,434 <printint>
        i += 2;
 634:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 636:	8bca                	mv	s7,s2
      state = 0;
 638:	4981                	li	s3,0
        i += 2;
 63a:	bdc5                	j	52a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 63c:	008b8913          	addi	s2,s7,8
 640:	4681                	li	a3,0
 642:	4629                	li	a2,10
 644:	000be583          	lwu	a1,0(s7)
 648:	855a                	mv	a0,s6
 64a:	debff0ef          	jal	ra,434 <printint>
 64e:	8bca                	mv	s7,s2
      state = 0;
 650:	4981                	li	s3,0
 652:	bde1                	j	52a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 654:	008b8913          	addi	s2,s7,8
 658:	4681                	li	a3,0
 65a:	4629                	li	a2,10
 65c:	000bb583          	ld	a1,0(s7)
 660:	855a                	mv	a0,s6
 662:	dd3ff0ef          	jal	ra,434 <printint>
        i += 1;
 666:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 668:	8bca                	mv	s7,s2
      state = 0;
 66a:	4981                	li	s3,0
        i += 1;
 66c:	bd7d                	j	52a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 66e:	008b8913          	addi	s2,s7,8
 672:	4681                	li	a3,0
 674:	4629                	li	a2,10
 676:	000bb583          	ld	a1,0(s7)
 67a:	855a                	mv	a0,s6
 67c:	db9ff0ef          	jal	ra,434 <printint>
        i += 2;
 680:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 682:	8bca                	mv	s7,s2
      state = 0;
 684:	4981                	li	s3,0
        i += 2;
 686:	b555                	j	52a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 688:	008b8913          	addi	s2,s7,8
 68c:	4681                	li	a3,0
 68e:	4641                	li	a2,16
 690:	000be583          	lwu	a1,0(s7)
 694:	855a                	mv	a0,s6
 696:	d9fff0ef          	jal	ra,434 <printint>
 69a:	8bca                	mv	s7,s2
      state = 0;
 69c:	4981                	li	s3,0
 69e:	b571                	j	52a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a0:	008b8913          	addi	s2,s7,8
 6a4:	4681                	li	a3,0
 6a6:	4641                	li	a2,16
 6a8:	000bb583          	ld	a1,0(s7)
 6ac:	855a                	mv	a0,s6
 6ae:	d87ff0ef          	jal	ra,434 <printint>
        i += 1;
 6b2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6b4:	8bca                	mv	s7,s2
      state = 0;
 6b6:	4981                	li	s3,0
        i += 1;
 6b8:	bd8d                	j	52a <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6ba:	008b8793          	addi	a5,s7,8
 6be:	f8f43423          	sd	a5,-120(s0)
 6c2:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6c6:	03000593          	li	a1,48
 6ca:	855a                	mv	a0,s6
 6cc:	d4bff0ef          	jal	ra,416 <putc>
  putc(fd, 'x');
 6d0:	07800593          	li	a1,120
 6d4:	855a                	mv	a0,s6
 6d6:	d41ff0ef          	jal	ra,416 <putc>
 6da:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6dc:	03c9d793          	srli	a5,s3,0x3c
 6e0:	97e6                	add	a5,a5,s9
 6e2:	0007c583          	lbu	a1,0(a5)
 6e6:	855a                	mv	a0,s6
 6e8:	d2fff0ef          	jal	ra,416 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6ec:	0992                	slli	s3,s3,0x4
 6ee:	397d                	addiw	s2,s2,-1
 6f0:	fe0916e3          	bnez	s2,6dc <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 6f4:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	bd05                	j	52a <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 6fc:	008b8913          	addi	s2,s7,8
 700:	000bc583          	lbu	a1,0(s7)
 704:	855a                	mv	a0,s6
 706:	d11ff0ef          	jal	ra,416 <putc>
 70a:	8bca                	mv	s7,s2
      state = 0;
 70c:	4981                	li	s3,0
 70e:	bd31                	j	52a <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 710:	008b8993          	addi	s3,s7,8
 714:	000bb903          	ld	s2,0(s7)
 718:	00090f63          	beqz	s2,736 <vprintf+0x266>
        for(; *s; s++)
 71c:	00094583          	lbu	a1,0(s2)
 720:	c195                	beqz	a1,744 <vprintf+0x274>
          putc(fd, *s);
 722:	855a                	mv	a0,s6
 724:	cf3ff0ef          	jal	ra,416 <putc>
        for(; *s; s++)
 728:	0905                	addi	s2,s2,1
 72a:	00094583          	lbu	a1,0(s2)
 72e:	f9f5                	bnez	a1,722 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 730:	8bce                	mv	s7,s3
      state = 0;
 732:	4981                	li	s3,0
 734:	bbdd                	j	52a <vprintf+0x5a>
          s = "(null)";
 736:	00000917          	auipc	s2,0x0
 73a:	23a90913          	addi	s2,s2,570 # 970 <malloc+0x124>
        for(; *s; s++)
 73e:	02800593          	li	a1,40
 742:	b7c5                	j	722 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 744:	8bce                	mv	s7,s3
      state = 0;
 746:	4981                	li	s3,0
 748:	b3cd                	j	52a <vprintf+0x5a>
    }
  }
}
 74a:	70e6                	ld	ra,120(sp)
 74c:	7446                	ld	s0,112(sp)
 74e:	74a6                	ld	s1,104(sp)
 750:	7906                	ld	s2,96(sp)
 752:	69e6                	ld	s3,88(sp)
 754:	6a46                	ld	s4,80(sp)
 756:	6aa6                	ld	s5,72(sp)
 758:	6b06                	ld	s6,64(sp)
 75a:	7be2                	ld	s7,56(sp)
 75c:	7c42                	ld	s8,48(sp)
 75e:	7ca2                	ld	s9,40(sp)
 760:	7d02                	ld	s10,32(sp)
 762:	6de2                	ld	s11,24(sp)
 764:	6109                	addi	sp,sp,128
 766:	8082                	ret

0000000000000768 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 768:	715d                	addi	sp,sp,-80
 76a:	ec06                	sd	ra,24(sp)
 76c:	e822                	sd	s0,16(sp)
 76e:	1000                	addi	s0,sp,32
 770:	e010                	sd	a2,0(s0)
 772:	e414                	sd	a3,8(s0)
 774:	e818                	sd	a4,16(s0)
 776:	ec1c                	sd	a5,24(s0)
 778:	03043023          	sd	a6,32(s0)
 77c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 780:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 784:	8622                	mv	a2,s0
 786:	d4bff0ef          	jal	ra,4d0 <vprintf>
}
 78a:	60e2                	ld	ra,24(sp)
 78c:	6442                	ld	s0,16(sp)
 78e:	6161                	addi	sp,sp,80
 790:	8082                	ret

0000000000000792 <printf>:

void
printf(const char *fmt, ...)
{
 792:	711d                	addi	sp,sp,-96
 794:	ec06                	sd	ra,24(sp)
 796:	e822                	sd	s0,16(sp)
 798:	1000                	addi	s0,sp,32
 79a:	e40c                	sd	a1,8(s0)
 79c:	e810                	sd	a2,16(s0)
 79e:	ec14                	sd	a3,24(s0)
 7a0:	f018                	sd	a4,32(s0)
 7a2:	f41c                	sd	a5,40(s0)
 7a4:	03043823          	sd	a6,48(s0)
 7a8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ac:	00840613          	addi	a2,s0,8
 7b0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7b4:	85aa                	mv	a1,a0
 7b6:	4505                	li	a0,1
 7b8:	d19ff0ef          	jal	ra,4d0 <vprintf>
}
 7bc:	60e2                	ld	ra,24(sp)
 7be:	6442                	ld	s0,16(sp)
 7c0:	6125                	addi	sp,sp,96
 7c2:	8082                	ret

00000000000007c4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7c4:	1141                	addi	sp,sp,-16
 7c6:	e422                	sd	s0,8(sp)
 7c8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7ca:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ce:	00001797          	auipc	a5,0x1
 7d2:	8327b783          	ld	a5,-1998(a5) # 1000 <freep>
 7d6:	a805                	j	806 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7d8:	4618                	lw	a4,8(a2)
 7da:	9db9                	addw	a1,a1,a4
 7dc:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7e0:	6398                	ld	a4,0(a5)
 7e2:	6318                	ld	a4,0(a4)
 7e4:	fee53823          	sd	a4,-16(a0)
 7e8:	a091                	j	82c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7ea:	ff852703          	lw	a4,-8(a0)
 7ee:	9e39                	addw	a2,a2,a4
 7f0:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7f2:	ff053703          	ld	a4,-16(a0)
 7f6:	e398                	sd	a4,0(a5)
 7f8:	a099                	j	83e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7fa:	6398                	ld	a4,0(a5)
 7fc:	00e7e463          	bltu	a5,a4,804 <free+0x40>
 800:	00e6ea63          	bltu	a3,a4,814 <free+0x50>
{
 804:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 806:	fed7fae3          	bgeu	a5,a3,7fa <free+0x36>
 80a:	6398                	ld	a4,0(a5)
 80c:	00e6e463          	bltu	a3,a4,814 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 810:	fee7eae3          	bltu	a5,a4,804 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 814:	ff852583          	lw	a1,-8(a0)
 818:	6390                	ld	a2,0(a5)
 81a:	02059713          	slli	a4,a1,0x20
 81e:	9301                	srli	a4,a4,0x20
 820:	0712                	slli	a4,a4,0x4
 822:	9736                	add	a4,a4,a3
 824:	fae60ae3          	beq	a2,a4,7d8 <free+0x14>
    bp->s.ptr = p->s.ptr;
 828:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 82c:	4790                	lw	a2,8(a5)
 82e:	02061713          	slli	a4,a2,0x20
 832:	9301                	srli	a4,a4,0x20
 834:	0712                	slli	a4,a4,0x4
 836:	973e                	add	a4,a4,a5
 838:	fae689e3          	beq	a3,a4,7ea <free+0x26>
  } else
    p->s.ptr = bp;
 83c:	e394                	sd	a3,0(a5)
  freep = p;
 83e:	00000717          	auipc	a4,0x0
 842:	7cf73123          	sd	a5,1986(a4) # 1000 <freep>
}
 846:	6422                	ld	s0,8(sp)
 848:	0141                	addi	sp,sp,16
 84a:	8082                	ret

000000000000084c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 84c:	7139                	addi	sp,sp,-64
 84e:	fc06                	sd	ra,56(sp)
 850:	f822                	sd	s0,48(sp)
 852:	f426                	sd	s1,40(sp)
 854:	f04a                	sd	s2,32(sp)
 856:	ec4e                	sd	s3,24(sp)
 858:	e852                	sd	s4,16(sp)
 85a:	e456                	sd	s5,8(sp)
 85c:	e05a                	sd	s6,0(sp)
 85e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 860:	02051493          	slli	s1,a0,0x20
 864:	9081                	srli	s1,s1,0x20
 866:	04bd                	addi	s1,s1,15
 868:	8091                	srli	s1,s1,0x4
 86a:	0014899b          	addiw	s3,s1,1
 86e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 870:	00000517          	auipc	a0,0x0
 874:	79053503          	ld	a0,1936(a0) # 1000 <freep>
 878:	c515                	beqz	a0,8a4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 87a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 87c:	4798                	lw	a4,8(a5)
 87e:	02977f63          	bgeu	a4,s1,8bc <malloc+0x70>
 882:	8a4e                	mv	s4,s3
 884:	0009871b          	sext.w	a4,s3
 888:	6685                	lui	a3,0x1
 88a:	00d77363          	bgeu	a4,a3,890 <malloc+0x44>
 88e:	6a05                	lui	s4,0x1
 890:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 894:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 898:	00000917          	auipc	s2,0x0
 89c:	76890913          	addi	s2,s2,1896 # 1000 <freep>
  if(p == SBRK_ERROR)
 8a0:	5afd                	li	s5,-1
 8a2:	a0bd                	j	910 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 8a4:	00000797          	auipc	a5,0x0
 8a8:	76c78793          	addi	a5,a5,1900 # 1010 <base>
 8ac:	00000717          	auipc	a4,0x0
 8b0:	74f73a23          	sd	a5,1876(a4) # 1000 <freep>
 8b4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8b6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8ba:	b7e1                	j	882 <malloc+0x36>
      if(p->s.size == nunits)
 8bc:	02e48b63          	beq	s1,a4,8f2 <malloc+0xa6>
        p->s.size -= nunits;
 8c0:	4137073b          	subw	a4,a4,s3
 8c4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8c6:	1702                	slli	a4,a4,0x20
 8c8:	9301                	srli	a4,a4,0x20
 8ca:	0712                	slli	a4,a4,0x4
 8cc:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8ce:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8d2:	00000717          	auipc	a4,0x0
 8d6:	72a73723          	sd	a0,1838(a4) # 1000 <freep>
      return (void*)(p + 1);
 8da:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8de:	70e2                	ld	ra,56(sp)
 8e0:	7442                	ld	s0,48(sp)
 8e2:	74a2                	ld	s1,40(sp)
 8e4:	7902                	ld	s2,32(sp)
 8e6:	69e2                	ld	s3,24(sp)
 8e8:	6a42                	ld	s4,16(sp)
 8ea:	6aa2                	ld	s5,8(sp)
 8ec:	6b02                	ld	s6,0(sp)
 8ee:	6121                	addi	sp,sp,64
 8f0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8f2:	6398                	ld	a4,0(a5)
 8f4:	e118                	sd	a4,0(a0)
 8f6:	bff1                	j	8d2 <malloc+0x86>
  hp->s.size = nu;
 8f8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8fc:	0541                	addi	a0,a0,16
 8fe:	ec7ff0ef          	jal	ra,7c4 <free>
  return freep;
 902:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 906:	dd61                	beqz	a0,8de <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 908:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 90a:	4798                	lw	a4,8(a5)
 90c:	fa9778e3          	bgeu	a4,s1,8bc <malloc+0x70>
    if(p == freep)
 910:	00093703          	ld	a4,0(s2)
 914:	853e                	mv	a0,a5
 916:	fef719e3          	bne	a4,a5,908 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 91a:	8552                	mv	a0,s4
 91c:	a1fff0ef          	jal	ra,33a <sbrk>
  if(p == SBRK_ERROR)
 920:	fd551ce3          	bne	a0,s5,8f8 <malloc+0xac>
        return 0;
 924:	4501                	li	a0,0
 926:	bf65                	j	8de <malloc+0x92>
