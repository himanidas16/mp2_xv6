
user/_logstress:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
main(int argc, char **argv)
{
  int fd, n;
  enum { N = 250, SZ=2000 };
  
  for (int i = 1; i < argc; i++){
   0:	4785                	li	a5,1
   2:	0ea7de63          	bge	a5,a0,fe <main+0xfe>
{
   6:	7139                	addi	sp,sp,-64
   8:	fc06                	sd	ra,56(sp)
   a:	f822                	sd	s0,48(sp)
   c:	f426                	sd	s1,40(sp)
   e:	f04a                	sd	s2,32(sp)
  10:	ec4e                	sd	s3,24(sp)
  12:	e852                	sd	s4,16(sp)
  14:	0080                	addi	s0,sp,64
  16:	892a                	mv	s2,a0
  18:	89ae                	mv	s3,a1
  for (int i = 1; i < argc; i++){
  1a:	4485                	li	s1,1
  1c:	a011                	j	20 <main+0x20>
  1e:	84be                	mv	s1,a5
    int pid1 = fork();
  20:	370000ef          	jal	ra,390 <fork>
    if(pid1 < 0){
  24:	00054963          	bltz	a0,36 <main+0x36>
      printf("%s: fork failed\n", argv[0]);
      exit(1);
    }
    if(pid1 == 0) {
  28:	c115                	beqz	a0,4c <main+0x4c>
  for (int i = 1; i < argc; i++){
  2a:	0014879b          	addiw	a5,s1,1
  2e:	fef918e3          	bne	s2,a5,1e <main+0x1e>
  32:	4905                	li	s2,1
  34:	a879                	j	d2 <main+0xd2>
      printf("%s: fork failed\n", argv[0]);
  36:	0009b583          	ld	a1,0(s3)
  3a:	00001517          	auipc	a0,0x1
  3e:	92650513          	addi	a0,a0,-1754 # 960 <malloc+0xea>
  42:	77a000ef          	jal	ra,7bc <printf>
      exit(1);
  46:	4505                	li	a0,1
  48:	350000ef          	jal	ra,398 <exit>
      fd = open(argv[i], O_CREATE | O_RDWR);
  4c:	00349a13          	slli	s4,s1,0x3
  50:	9a4e                	add	s4,s4,s3
  52:	20200593          	li	a1,514
  56:	000a3503          	ld	a0,0(s4)
  5a:	37e000ef          	jal	ra,3d8 <open>
  5e:	892a                	mv	s2,a0
      if(fd < 0){
  60:	04054163          	bltz	a0,a2 <main+0xa2>
        printf("%s: create %s failed\n", argv[0], argv[i]);
        exit(1);
      }
      memset(buf, '0'+i, SZ);
  64:	7d000613          	li	a2,2000
  68:	0304859b          	addiw	a1,s1,48
  6c:	00001517          	auipc	a0,0x1
  70:	fa450513          	addi	a0,a0,-92 # 1010 <buf>
  74:	110000ef          	jal	ra,184 <memset>
  78:	0fa00493          	li	s1,250
      for(i = 0; i < N; i++){
        if((n = write(fd, buf, SZ)) != SZ){
  7c:	00001997          	auipc	s3,0x1
  80:	f9498993          	addi	s3,s3,-108 # 1010 <buf>
  84:	7d000613          	li	a2,2000
  88:	85ce                	mv	a1,s3
  8a:	854a                	mv	a0,s2
  8c:	32c000ef          	jal	ra,3b8 <write>
  90:	7d000793          	li	a5,2000
  94:	02f51463          	bne	a0,a5,bc <main+0xbc>
      for(i = 0; i < N; i++){
  98:	34fd                	addiw	s1,s1,-1
  9a:	f4ed                	bnez	s1,84 <main+0x84>
          printf("write failed %d\n", n);
          exit(1);
        }
      }
      exit(0);
  9c:	4501                	li	a0,0
  9e:	2fa000ef          	jal	ra,398 <exit>
        printf("%s: create %s failed\n", argv[0], argv[i]);
  a2:	000a3603          	ld	a2,0(s4)
  a6:	0009b583          	ld	a1,0(s3)
  aa:	00001517          	auipc	a0,0x1
  ae:	8ce50513          	addi	a0,a0,-1842 # 978 <malloc+0x102>
  b2:	70a000ef          	jal	ra,7bc <printf>
        exit(1);
  b6:	4505                	li	a0,1
  b8:	2e0000ef          	jal	ra,398 <exit>
          printf("write failed %d\n", n);
  bc:	85aa                	mv	a1,a0
  be:	00001517          	auipc	a0,0x1
  c2:	8d250513          	addi	a0,a0,-1838 # 990 <malloc+0x11a>
  c6:	6f6000ef          	jal	ra,7bc <printf>
          exit(1);
  ca:	4505                	li	a0,1
  cc:	2cc000ef          	jal	ra,398 <exit>
    }
  }
  int xstatus;
  for(int i = 1; i < argc; i++){
  d0:	893e                	mv	s2,a5
    wait(&xstatus);
  d2:	fcc40513          	addi	a0,s0,-52
  d6:	2ca000ef          	jal	ra,3a0 <wait>
    if(xstatus != 0)
  da:	fcc42503          	lw	a0,-52(s0)
  de:	ed11                	bnez	a0,fa <main+0xfa>
  for(int i = 1; i < argc; i++){
  e0:	0019079b          	addiw	a5,s2,1
  e4:	ff2496e3          	bne	s1,s2,d0 <main+0xd0>
      exit(xstatus);
  }
  return 0;
}
  e8:	4501                	li	a0,0
  ea:	70e2                	ld	ra,56(sp)
  ec:	7442                	ld	s0,48(sp)
  ee:	74a2                	ld	s1,40(sp)
  f0:	7902                	ld	s2,32(sp)
  f2:	69e2                	ld	s3,24(sp)
  f4:	6a42                	ld	s4,16(sp)
  f6:	6121                	addi	sp,sp,64
  f8:	8082                	ret
      exit(xstatus);
  fa:	29e000ef          	jal	ra,398 <exit>
}
  fe:	4501                	li	a0,0
 100:	8082                	ret

0000000000000102 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 102:	1141                	addi	sp,sp,-16
 104:	e406                	sd	ra,8(sp)
 106:	e022                	sd	s0,0(sp)
 108:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 10a:	ef7ff0ef          	jal	ra,0 <main>
  exit(r);
 10e:	28a000ef          	jal	ra,398 <exit>

0000000000000112 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 112:	1141                	addi	sp,sp,-16
 114:	e422                	sd	s0,8(sp)
 116:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 118:	87aa                	mv	a5,a0
 11a:	0585                	addi	a1,a1,1
 11c:	0785                	addi	a5,a5,1
 11e:	fff5c703          	lbu	a4,-1(a1)
 122:	fee78fa3          	sb	a4,-1(a5)
 126:	fb75                	bnez	a4,11a <strcpy+0x8>
    ;
  return os;
}
 128:	6422                	ld	s0,8(sp)
 12a:	0141                	addi	sp,sp,16
 12c:	8082                	ret

000000000000012e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 12e:	1141                	addi	sp,sp,-16
 130:	e422                	sd	s0,8(sp)
 132:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 134:	00054783          	lbu	a5,0(a0)
 138:	cb91                	beqz	a5,14c <strcmp+0x1e>
 13a:	0005c703          	lbu	a4,0(a1)
 13e:	00f71763          	bne	a4,a5,14c <strcmp+0x1e>
    p++, q++;
 142:	0505                	addi	a0,a0,1
 144:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 146:	00054783          	lbu	a5,0(a0)
 14a:	fbe5                	bnez	a5,13a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 14c:	0005c503          	lbu	a0,0(a1)
}
 150:	40a7853b          	subw	a0,a5,a0
 154:	6422                	ld	s0,8(sp)
 156:	0141                	addi	sp,sp,16
 158:	8082                	ret

000000000000015a <strlen>:

uint
strlen(const char *s)
{
 15a:	1141                	addi	sp,sp,-16
 15c:	e422                	sd	s0,8(sp)
 15e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 160:	00054783          	lbu	a5,0(a0)
 164:	cf91                	beqz	a5,180 <strlen+0x26>
 166:	0505                	addi	a0,a0,1
 168:	87aa                	mv	a5,a0
 16a:	4685                	li	a3,1
 16c:	9e89                	subw	a3,a3,a0
 16e:	00f6853b          	addw	a0,a3,a5
 172:	0785                	addi	a5,a5,1
 174:	fff7c703          	lbu	a4,-1(a5)
 178:	fb7d                	bnez	a4,16e <strlen+0x14>
    ;
  return n;
}
 17a:	6422                	ld	s0,8(sp)
 17c:	0141                	addi	sp,sp,16
 17e:	8082                	ret
  for(n = 0; s[n]; n++)
 180:	4501                	li	a0,0
 182:	bfe5                	j	17a <strlen+0x20>

0000000000000184 <memset>:

void*
memset(void *dst, int c, uint n)
{
 184:	1141                	addi	sp,sp,-16
 186:	e422                	sd	s0,8(sp)
 188:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 18a:	ca19                	beqz	a2,1a0 <memset+0x1c>
 18c:	87aa                	mv	a5,a0
 18e:	1602                	slli	a2,a2,0x20
 190:	9201                	srli	a2,a2,0x20
 192:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 196:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 19a:	0785                	addi	a5,a5,1
 19c:	fee79de3          	bne	a5,a4,196 <memset+0x12>
  }
  return dst;
}
 1a0:	6422                	ld	s0,8(sp)
 1a2:	0141                	addi	sp,sp,16
 1a4:	8082                	ret

00000000000001a6 <strchr>:

char*
strchr(const char *s, char c)
{
 1a6:	1141                	addi	sp,sp,-16
 1a8:	e422                	sd	s0,8(sp)
 1aa:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1ac:	00054783          	lbu	a5,0(a0)
 1b0:	cb99                	beqz	a5,1c6 <strchr+0x20>
    if(*s == c)
 1b2:	00f58763          	beq	a1,a5,1c0 <strchr+0x1a>
  for(; *s; s++)
 1b6:	0505                	addi	a0,a0,1
 1b8:	00054783          	lbu	a5,0(a0)
 1bc:	fbfd                	bnez	a5,1b2 <strchr+0xc>
      return (char*)s;
  return 0;
 1be:	4501                	li	a0,0
}
 1c0:	6422                	ld	s0,8(sp)
 1c2:	0141                	addi	sp,sp,16
 1c4:	8082                	ret
  return 0;
 1c6:	4501                	li	a0,0
 1c8:	bfe5                	j	1c0 <strchr+0x1a>

00000000000001ca <gets>:

char*
gets(char *buf, int max)
{
 1ca:	711d                	addi	sp,sp,-96
 1cc:	ec86                	sd	ra,88(sp)
 1ce:	e8a2                	sd	s0,80(sp)
 1d0:	e4a6                	sd	s1,72(sp)
 1d2:	e0ca                	sd	s2,64(sp)
 1d4:	fc4e                	sd	s3,56(sp)
 1d6:	f852                	sd	s4,48(sp)
 1d8:	f456                	sd	s5,40(sp)
 1da:	f05a                	sd	s6,32(sp)
 1dc:	ec5e                	sd	s7,24(sp)
 1de:	1080                	addi	s0,sp,96
 1e0:	8baa                	mv	s7,a0
 1e2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e4:	892a                	mv	s2,a0
 1e6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1e8:	4aa9                	li	s5,10
 1ea:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ec:	89a6                	mv	s3,s1
 1ee:	2485                	addiw	s1,s1,1
 1f0:	0344d663          	bge	s1,s4,21c <gets+0x52>
    cc = read(0, &c, 1);
 1f4:	4605                	li	a2,1
 1f6:	faf40593          	addi	a1,s0,-81
 1fa:	4501                	li	a0,0
 1fc:	1b4000ef          	jal	ra,3b0 <read>
    if(cc < 1)
 200:	00a05e63          	blez	a0,21c <gets+0x52>
    buf[i++] = c;
 204:	faf44783          	lbu	a5,-81(s0)
 208:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 20c:	01578763          	beq	a5,s5,21a <gets+0x50>
 210:	0905                	addi	s2,s2,1
 212:	fd679de3          	bne	a5,s6,1ec <gets+0x22>
  for(i=0; i+1 < max; ){
 216:	89a6                	mv	s3,s1
 218:	a011                	j	21c <gets+0x52>
 21a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 21c:	99de                	add	s3,s3,s7
 21e:	00098023          	sb	zero,0(s3)
  return buf;
}
 222:	855e                	mv	a0,s7
 224:	60e6                	ld	ra,88(sp)
 226:	6446                	ld	s0,80(sp)
 228:	64a6                	ld	s1,72(sp)
 22a:	6906                	ld	s2,64(sp)
 22c:	79e2                	ld	s3,56(sp)
 22e:	7a42                	ld	s4,48(sp)
 230:	7aa2                	ld	s5,40(sp)
 232:	7b02                	ld	s6,32(sp)
 234:	6be2                	ld	s7,24(sp)
 236:	6125                	addi	sp,sp,96
 238:	8082                	ret

000000000000023a <stat>:

int
stat(const char *n, struct stat *st)
{
 23a:	1101                	addi	sp,sp,-32
 23c:	ec06                	sd	ra,24(sp)
 23e:	e822                	sd	s0,16(sp)
 240:	e426                	sd	s1,8(sp)
 242:	e04a                	sd	s2,0(sp)
 244:	1000                	addi	s0,sp,32
 246:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 248:	4581                	li	a1,0
 24a:	18e000ef          	jal	ra,3d8 <open>
  if(fd < 0)
 24e:	02054163          	bltz	a0,270 <stat+0x36>
 252:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 254:	85ca                	mv	a1,s2
 256:	19a000ef          	jal	ra,3f0 <fstat>
 25a:	892a                	mv	s2,a0
  close(fd);
 25c:	8526                	mv	a0,s1
 25e:	162000ef          	jal	ra,3c0 <close>
  return r;
}
 262:	854a                	mv	a0,s2
 264:	60e2                	ld	ra,24(sp)
 266:	6442                	ld	s0,16(sp)
 268:	64a2                	ld	s1,8(sp)
 26a:	6902                	ld	s2,0(sp)
 26c:	6105                	addi	sp,sp,32
 26e:	8082                	ret
    return -1;
 270:	597d                	li	s2,-1
 272:	bfc5                	j	262 <stat+0x28>

0000000000000274 <atoi>:

int
atoi(const char *s)
{
 274:	1141                	addi	sp,sp,-16
 276:	e422                	sd	s0,8(sp)
 278:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 27a:	00054603          	lbu	a2,0(a0)
 27e:	fd06079b          	addiw	a5,a2,-48
 282:	0ff7f793          	andi	a5,a5,255
 286:	4725                	li	a4,9
 288:	02f76963          	bltu	a4,a5,2ba <atoi+0x46>
 28c:	86aa                	mv	a3,a0
  n = 0;
 28e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 290:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 292:	0685                	addi	a3,a3,1
 294:	0025179b          	slliw	a5,a0,0x2
 298:	9fa9                	addw	a5,a5,a0
 29a:	0017979b          	slliw	a5,a5,0x1
 29e:	9fb1                	addw	a5,a5,a2
 2a0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2a4:	0006c603          	lbu	a2,0(a3)
 2a8:	fd06071b          	addiw	a4,a2,-48
 2ac:	0ff77713          	andi	a4,a4,255
 2b0:	fee5f1e3          	bgeu	a1,a4,292 <atoi+0x1e>
  return n;
}
 2b4:	6422                	ld	s0,8(sp)
 2b6:	0141                	addi	sp,sp,16
 2b8:	8082                	ret
  n = 0;
 2ba:	4501                	li	a0,0
 2bc:	bfe5                	j	2b4 <atoi+0x40>

00000000000002be <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2be:	1141                	addi	sp,sp,-16
 2c0:	e422                	sd	s0,8(sp)
 2c2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2c4:	02b57463          	bgeu	a0,a1,2ec <memmove+0x2e>
    while(n-- > 0)
 2c8:	00c05f63          	blez	a2,2e6 <memmove+0x28>
 2cc:	1602                	slli	a2,a2,0x20
 2ce:	9201                	srli	a2,a2,0x20
 2d0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2d4:	872a                	mv	a4,a0
      *dst++ = *src++;
 2d6:	0585                	addi	a1,a1,1
 2d8:	0705                	addi	a4,a4,1
 2da:	fff5c683          	lbu	a3,-1(a1)
 2de:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2e2:	fee79ae3          	bne	a5,a4,2d6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2e6:	6422                	ld	s0,8(sp)
 2e8:	0141                	addi	sp,sp,16
 2ea:	8082                	ret
    dst += n;
 2ec:	00c50733          	add	a4,a0,a2
    src += n;
 2f0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2f2:	fec05ae3          	blez	a2,2e6 <memmove+0x28>
 2f6:	fff6079b          	addiw	a5,a2,-1
 2fa:	1782                	slli	a5,a5,0x20
 2fc:	9381                	srli	a5,a5,0x20
 2fe:	fff7c793          	not	a5,a5
 302:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 304:	15fd                	addi	a1,a1,-1
 306:	177d                	addi	a4,a4,-1
 308:	0005c683          	lbu	a3,0(a1)
 30c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 310:	fee79ae3          	bne	a5,a4,304 <memmove+0x46>
 314:	bfc9                	j	2e6 <memmove+0x28>

0000000000000316 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 316:	1141                	addi	sp,sp,-16
 318:	e422                	sd	s0,8(sp)
 31a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 31c:	ca05                	beqz	a2,34c <memcmp+0x36>
 31e:	fff6069b          	addiw	a3,a2,-1
 322:	1682                	slli	a3,a3,0x20
 324:	9281                	srli	a3,a3,0x20
 326:	0685                	addi	a3,a3,1
 328:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 32a:	00054783          	lbu	a5,0(a0)
 32e:	0005c703          	lbu	a4,0(a1)
 332:	00e79863          	bne	a5,a4,342 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 336:	0505                	addi	a0,a0,1
    p2++;
 338:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 33a:	fed518e3          	bne	a0,a3,32a <memcmp+0x14>
  }
  return 0;
 33e:	4501                	li	a0,0
 340:	a019                	j	346 <memcmp+0x30>
      return *p1 - *p2;
 342:	40e7853b          	subw	a0,a5,a4
}
 346:	6422                	ld	s0,8(sp)
 348:	0141                	addi	sp,sp,16
 34a:	8082                	ret
  return 0;
 34c:	4501                	li	a0,0
 34e:	bfe5                	j	346 <memcmp+0x30>

0000000000000350 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 350:	1141                	addi	sp,sp,-16
 352:	e406                	sd	ra,8(sp)
 354:	e022                	sd	s0,0(sp)
 356:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 358:	f67ff0ef          	jal	ra,2be <memmove>
}
 35c:	60a2                	ld	ra,8(sp)
 35e:	6402                	ld	s0,0(sp)
 360:	0141                	addi	sp,sp,16
 362:	8082                	ret

0000000000000364 <sbrk>:

char *
sbrk(int n) {
 364:	1141                	addi	sp,sp,-16
 366:	e406                	sd	ra,8(sp)
 368:	e022                	sd	s0,0(sp)
 36a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 36c:	4585                	li	a1,1
 36e:	0b2000ef          	jal	ra,420 <sys_sbrk>
}
 372:	60a2                	ld	ra,8(sp)
 374:	6402                	ld	s0,0(sp)
 376:	0141                	addi	sp,sp,16
 378:	8082                	ret

000000000000037a <sbrklazy>:

char *
sbrklazy(int n) {
 37a:	1141                	addi	sp,sp,-16
 37c:	e406                	sd	ra,8(sp)
 37e:	e022                	sd	s0,0(sp)
 380:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 382:	4589                	li	a1,2
 384:	09c000ef          	jal	ra,420 <sys_sbrk>
}
 388:	60a2                	ld	ra,8(sp)
 38a:	6402                	ld	s0,0(sp)
 38c:	0141                	addi	sp,sp,16
 38e:	8082                	ret

0000000000000390 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 390:	4885                	li	a7,1
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <exit>:
.global exit
exit:
 li a7, SYS_exit
 398:	4889                	li	a7,2
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3a0:	488d                	li	a7,3
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3a8:	4891                	li	a7,4
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <read>:
.global read
read:
 li a7, SYS_read
 3b0:	4895                	li	a7,5
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <write>:
.global write
write:
 li a7, SYS_write
 3b8:	48c1                	li	a7,16
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <close>:
.global close
close:
 li a7, SYS_close
 3c0:	48d5                	li	a7,21
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3c8:	4899                	li	a7,6
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3d0:	489d                	li	a7,7
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <open>:
.global open
open:
 li a7, SYS_open
 3d8:	48bd                	li	a7,15
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3e0:	48c5                	li	a7,17
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3e8:	48c9                	li	a7,18
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3f0:	48a1                	li	a7,8
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <link>:
.global link
link:
 li a7, SYS_link
 3f8:	48cd                	li	a7,19
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 400:	48d1                	li	a7,20
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 408:	48a5                	li	a7,9
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <dup>:
.global dup
dup:
 li a7, SYS_dup
 410:	48a9                	li	a7,10
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 418:	48ad                	li	a7,11
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 420:	48b1                	li	a7,12
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <pause>:
.global pause
pause:
 li a7, SYS_pause
 428:	48b5                	li	a7,13
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 430:	48b9                	li	a7,14
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <memstat>:
.global memstat
memstat:
 li a7, SYS_memstat
 438:	48d9                	li	a7,22
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 440:	1101                	addi	sp,sp,-32
 442:	ec06                	sd	ra,24(sp)
 444:	e822                	sd	s0,16(sp)
 446:	1000                	addi	s0,sp,32
 448:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 44c:	4605                	li	a2,1
 44e:	fef40593          	addi	a1,s0,-17
 452:	f67ff0ef          	jal	ra,3b8 <write>
}
 456:	60e2                	ld	ra,24(sp)
 458:	6442                	ld	s0,16(sp)
 45a:	6105                	addi	sp,sp,32
 45c:	8082                	ret

000000000000045e <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 45e:	715d                	addi	sp,sp,-80
 460:	e486                	sd	ra,72(sp)
 462:	e0a2                	sd	s0,64(sp)
 464:	fc26                	sd	s1,56(sp)
 466:	f84a                	sd	s2,48(sp)
 468:	f44e                	sd	s3,40(sp)
 46a:	0880                	addi	s0,sp,80
 46c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 46e:	c299                	beqz	a3,474 <printint+0x16>
 470:	0805c163          	bltz	a1,4f2 <printint+0x94>
  neg = 0;
 474:	4881                	li	a7,0
 476:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 47a:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 47c:	00000517          	auipc	a0,0x0
 480:	53450513          	addi	a0,a0,1332 # 9b0 <digits>
 484:	883e                	mv	a6,a5
 486:	2785                	addiw	a5,a5,1
 488:	02c5f733          	remu	a4,a1,a2
 48c:	972a                	add	a4,a4,a0
 48e:	00074703          	lbu	a4,0(a4)
 492:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 496:	872e                	mv	a4,a1
 498:	02c5d5b3          	divu	a1,a1,a2
 49c:	0685                	addi	a3,a3,1
 49e:	fec773e3          	bgeu	a4,a2,484 <printint+0x26>
  if(neg)
 4a2:	00088b63          	beqz	a7,4b8 <printint+0x5a>
    buf[i++] = '-';
 4a6:	fd040713          	addi	a4,s0,-48
 4aa:	97ba                	add	a5,a5,a4
 4ac:	02d00713          	li	a4,45
 4b0:	fee78423          	sb	a4,-24(a5)
 4b4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4b8:	02f05663          	blez	a5,4e4 <printint+0x86>
 4bc:	fb840713          	addi	a4,s0,-72
 4c0:	00f704b3          	add	s1,a4,a5
 4c4:	fff70993          	addi	s3,a4,-1
 4c8:	99be                	add	s3,s3,a5
 4ca:	37fd                	addiw	a5,a5,-1
 4cc:	1782                	slli	a5,a5,0x20
 4ce:	9381                	srli	a5,a5,0x20
 4d0:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4d4:	fff4c583          	lbu	a1,-1(s1)
 4d8:	854a                	mv	a0,s2
 4da:	f67ff0ef          	jal	ra,440 <putc>
  while(--i >= 0)
 4de:	14fd                	addi	s1,s1,-1
 4e0:	ff349ae3          	bne	s1,s3,4d4 <printint+0x76>
}
 4e4:	60a6                	ld	ra,72(sp)
 4e6:	6406                	ld	s0,64(sp)
 4e8:	74e2                	ld	s1,56(sp)
 4ea:	7942                	ld	s2,48(sp)
 4ec:	79a2                	ld	s3,40(sp)
 4ee:	6161                	addi	sp,sp,80
 4f0:	8082                	ret
    x = -xx;
 4f2:	40b005b3          	neg	a1,a1
    neg = 1;
 4f6:	4885                	li	a7,1
    x = -xx;
 4f8:	bfbd                	j	476 <printint+0x18>

00000000000004fa <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4fa:	7119                	addi	sp,sp,-128
 4fc:	fc86                	sd	ra,120(sp)
 4fe:	f8a2                	sd	s0,112(sp)
 500:	f4a6                	sd	s1,104(sp)
 502:	f0ca                	sd	s2,96(sp)
 504:	ecce                	sd	s3,88(sp)
 506:	e8d2                	sd	s4,80(sp)
 508:	e4d6                	sd	s5,72(sp)
 50a:	e0da                	sd	s6,64(sp)
 50c:	fc5e                	sd	s7,56(sp)
 50e:	f862                	sd	s8,48(sp)
 510:	f466                	sd	s9,40(sp)
 512:	f06a                	sd	s10,32(sp)
 514:	ec6e                	sd	s11,24(sp)
 516:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 518:	0005c903          	lbu	s2,0(a1)
 51c:	24090c63          	beqz	s2,774 <vprintf+0x27a>
 520:	8b2a                	mv	s6,a0
 522:	8a2e                	mv	s4,a1
 524:	8bb2                	mv	s7,a2
  state = 0;
 526:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 528:	4481                	li	s1,0
 52a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 52c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 530:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 534:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 538:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 53c:	00000c97          	auipc	s9,0x0
 540:	474c8c93          	addi	s9,s9,1140 # 9b0 <digits>
 544:	a005                	j	564 <vprintf+0x6a>
        putc(fd, c0);
 546:	85ca                	mv	a1,s2
 548:	855a                	mv	a0,s6
 54a:	ef7ff0ef          	jal	ra,440 <putc>
 54e:	a019                	j	554 <vprintf+0x5a>
    } else if(state == '%'){
 550:	03598263          	beq	s3,s5,574 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 554:	2485                	addiw	s1,s1,1
 556:	8726                	mv	a4,s1
 558:	009a07b3          	add	a5,s4,s1
 55c:	0007c903          	lbu	s2,0(a5)
 560:	20090a63          	beqz	s2,774 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 564:	0009079b          	sext.w	a5,s2
    if(state == 0){
 568:	fe0994e3          	bnez	s3,550 <vprintf+0x56>
      if(c0 == '%'){
 56c:	fd579de3          	bne	a5,s5,546 <vprintf+0x4c>
        state = '%';
 570:	89be                	mv	s3,a5
 572:	b7cd                	j	554 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 574:	c3c1                	beqz	a5,5f4 <vprintf+0xfa>
 576:	00ea06b3          	add	a3,s4,a4
 57a:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 57e:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 580:	c681                	beqz	a3,588 <vprintf+0x8e>
 582:	9752                	add	a4,a4,s4
 584:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 588:	03878e63          	beq	a5,s8,5c4 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 58c:	05a78863          	beq	a5,s10,5dc <vprintf+0xe2>
      } else if(c0 == 'u'){
 590:	0db78b63          	beq	a5,s11,666 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 594:	07800713          	li	a4,120
 598:	10e78d63          	beq	a5,a4,6b2 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 59c:	07000713          	li	a4,112
 5a0:	14e78263          	beq	a5,a4,6e4 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5a4:	06300713          	li	a4,99
 5a8:	16e78f63          	beq	a5,a4,726 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5ac:	07300713          	li	a4,115
 5b0:	18e78563          	beq	a5,a4,73a <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5b4:	05579063          	bne	a5,s5,5f4 <vprintf+0xfa>
        putc(fd, '%');
 5b8:	85d6                	mv	a1,s5
 5ba:	855a                	mv	a0,s6
 5bc:	e85ff0ef          	jal	ra,440 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5c0:	4981                	li	s3,0
 5c2:	bf49                	j	554 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 5c4:	008b8913          	addi	s2,s7,8
 5c8:	4685                	li	a3,1
 5ca:	4629                	li	a2,10
 5cc:	000ba583          	lw	a1,0(s7)
 5d0:	855a                	mv	a0,s6
 5d2:	e8dff0ef          	jal	ra,45e <printint>
 5d6:	8bca                	mv	s7,s2
      state = 0;
 5d8:	4981                	li	s3,0
 5da:	bfad                	j	554 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5dc:	03868663          	beq	a3,s8,608 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5e0:	05a68163          	beq	a3,s10,622 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 5e4:	09b68d63          	beq	a3,s11,67e <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5e8:	03a68f63          	beq	a3,s10,626 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 5ec:	07800793          	li	a5,120
 5f0:	0cf68d63          	beq	a3,a5,6ca <vprintf+0x1d0>
        putc(fd, '%');
 5f4:	85d6                	mv	a1,s5
 5f6:	855a                	mv	a0,s6
 5f8:	e49ff0ef          	jal	ra,440 <putc>
        putc(fd, c0);
 5fc:	85ca                	mv	a1,s2
 5fe:	855a                	mv	a0,s6
 600:	e41ff0ef          	jal	ra,440 <putc>
      state = 0;
 604:	4981                	li	s3,0
 606:	b7b9                	j	554 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 608:	008b8913          	addi	s2,s7,8
 60c:	4685                	li	a3,1
 60e:	4629                	li	a2,10
 610:	000bb583          	ld	a1,0(s7)
 614:	855a                	mv	a0,s6
 616:	e49ff0ef          	jal	ra,45e <printint>
        i += 1;
 61a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 61c:	8bca                	mv	s7,s2
      state = 0;
 61e:	4981                	li	s3,0
        i += 1;
 620:	bf15                	j	554 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 622:	03860563          	beq	a2,s8,64c <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 626:	07b60963          	beq	a2,s11,698 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 62a:	07800793          	li	a5,120
 62e:	fcf613e3          	bne	a2,a5,5f4 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 632:	008b8913          	addi	s2,s7,8
 636:	4681                	li	a3,0
 638:	4641                	li	a2,16
 63a:	000bb583          	ld	a1,0(s7)
 63e:	855a                	mv	a0,s6
 640:	e1fff0ef          	jal	ra,45e <printint>
        i += 2;
 644:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 646:	8bca                	mv	s7,s2
      state = 0;
 648:	4981                	li	s3,0
        i += 2;
 64a:	b729                	j	554 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 64c:	008b8913          	addi	s2,s7,8
 650:	4685                	li	a3,1
 652:	4629                	li	a2,10
 654:	000bb583          	ld	a1,0(s7)
 658:	855a                	mv	a0,s6
 65a:	e05ff0ef          	jal	ra,45e <printint>
        i += 2;
 65e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 660:	8bca                	mv	s7,s2
      state = 0;
 662:	4981                	li	s3,0
        i += 2;
 664:	bdc5                	j	554 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 666:	008b8913          	addi	s2,s7,8
 66a:	4681                	li	a3,0
 66c:	4629                	li	a2,10
 66e:	000be583          	lwu	a1,0(s7)
 672:	855a                	mv	a0,s6
 674:	debff0ef          	jal	ra,45e <printint>
 678:	8bca                	mv	s7,s2
      state = 0;
 67a:	4981                	li	s3,0
 67c:	bde1                	j	554 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 67e:	008b8913          	addi	s2,s7,8
 682:	4681                	li	a3,0
 684:	4629                	li	a2,10
 686:	000bb583          	ld	a1,0(s7)
 68a:	855a                	mv	a0,s6
 68c:	dd3ff0ef          	jal	ra,45e <printint>
        i += 1;
 690:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 692:	8bca                	mv	s7,s2
      state = 0;
 694:	4981                	li	s3,0
        i += 1;
 696:	bd7d                	j	554 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 698:	008b8913          	addi	s2,s7,8
 69c:	4681                	li	a3,0
 69e:	4629                	li	a2,10
 6a0:	000bb583          	ld	a1,0(s7)
 6a4:	855a                	mv	a0,s6
 6a6:	db9ff0ef          	jal	ra,45e <printint>
        i += 2;
 6aa:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ac:	8bca                	mv	s7,s2
      state = 0;
 6ae:	4981                	li	s3,0
        i += 2;
 6b0:	b555                	j	554 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6b2:	008b8913          	addi	s2,s7,8
 6b6:	4681                	li	a3,0
 6b8:	4641                	li	a2,16
 6ba:	000be583          	lwu	a1,0(s7)
 6be:	855a                	mv	a0,s6
 6c0:	d9fff0ef          	jal	ra,45e <printint>
 6c4:	8bca                	mv	s7,s2
      state = 0;
 6c6:	4981                	li	s3,0
 6c8:	b571                	j	554 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ca:	008b8913          	addi	s2,s7,8
 6ce:	4681                	li	a3,0
 6d0:	4641                	li	a2,16
 6d2:	000bb583          	ld	a1,0(s7)
 6d6:	855a                	mv	a0,s6
 6d8:	d87ff0ef          	jal	ra,45e <printint>
        i += 1;
 6dc:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6de:	8bca                	mv	s7,s2
      state = 0;
 6e0:	4981                	li	s3,0
        i += 1;
 6e2:	bd8d                	j	554 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6e4:	008b8793          	addi	a5,s7,8
 6e8:	f8f43423          	sd	a5,-120(s0)
 6ec:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6f0:	03000593          	li	a1,48
 6f4:	855a                	mv	a0,s6
 6f6:	d4bff0ef          	jal	ra,440 <putc>
  putc(fd, 'x');
 6fa:	07800593          	li	a1,120
 6fe:	855a                	mv	a0,s6
 700:	d41ff0ef          	jal	ra,440 <putc>
 704:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 706:	03c9d793          	srli	a5,s3,0x3c
 70a:	97e6                	add	a5,a5,s9
 70c:	0007c583          	lbu	a1,0(a5)
 710:	855a                	mv	a0,s6
 712:	d2fff0ef          	jal	ra,440 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 716:	0992                	slli	s3,s3,0x4
 718:	397d                	addiw	s2,s2,-1
 71a:	fe0916e3          	bnez	s2,706 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 71e:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 722:	4981                	li	s3,0
 724:	bd05                	j	554 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 726:	008b8913          	addi	s2,s7,8
 72a:	000bc583          	lbu	a1,0(s7)
 72e:	855a                	mv	a0,s6
 730:	d11ff0ef          	jal	ra,440 <putc>
 734:	8bca                	mv	s7,s2
      state = 0;
 736:	4981                	li	s3,0
 738:	bd31                	j	554 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 73a:	008b8993          	addi	s3,s7,8
 73e:	000bb903          	ld	s2,0(s7)
 742:	00090f63          	beqz	s2,760 <vprintf+0x266>
        for(; *s; s++)
 746:	00094583          	lbu	a1,0(s2)
 74a:	c195                	beqz	a1,76e <vprintf+0x274>
          putc(fd, *s);
 74c:	855a                	mv	a0,s6
 74e:	cf3ff0ef          	jal	ra,440 <putc>
        for(; *s; s++)
 752:	0905                	addi	s2,s2,1
 754:	00094583          	lbu	a1,0(s2)
 758:	f9f5                	bnez	a1,74c <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 75a:	8bce                	mv	s7,s3
      state = 0;
 75c:	4981                	li	s3,0
 75e:	bbdd                	j	554 <vprintf+0x5a>
          s = "(null)";
 760:	00000917          	auipc	s2,0x0
 764:	24890913          	addi	s2,s2,584 # 9a8 <malloc+0x132>
        for(; *s; s++)
 768:	02800593          	li	a1,40
 76c:	b7c5                	j	74c <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 76e:	8bce                	mv	s7,s3
      state = 0;
 770:	4981                	li	s3,0
 772:	b3cd                	j	554 <vprintf+0x5a>
    }
  }
}
 774:	70e6                	ld	ra,120(sp)
 776:	7446                	ld	s0,112(sp)
 778:	74a6                	ld	s1,104(sp)
 77a:	7906                	ld	s2,96(sp)
 77c:	69e6                	ld	s3,88(sp)
 77e:	6a46                	ld	s4,80(sp)
 780:	6aa6                	ld	s5,72(sp)
 782:	6b06                	ld	s6,64(sp)
 784:	7be2                	ld	s7,56(sp)
 786:	7c42                	ld	s8,48(sp)
 788:	7ca2                	ld	s9,40(sp)
 78a:	7d02                	ld	s10,32(sp)
 78c:	6de2                	ld	s11,24(sp)
 78e:	6109                	addi	sp,sp,128
 790:	8082                	ret

0000000000000792 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 792:	715d                	addi	sp,sp,-80
 794:	ec06                	sd	ra,24(sp)
 796:	e822                	sd	s0,16(sp)
 798:	1000                	addi	s0,sp,32
 79a:	e010                	sd	a2,0(s0)
 79c:	e414                	sd	a3,8(s0)
 79e:	e818                	sd	a4,16(s0)
 7a0:	ec1c                	sd	a5,24(s0)
 7a2:	03043023          	sd	a6,32(s0)
 7a6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7aa:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7ae:	8622                	mv	a2,s0
 7b0:	d4bff0ef          	jal	ra,4fa <vprintf>
}
 7b4:	60e2                	ld	ra,24(sp)
 7b6:	6442                	ld	s0,16(sp)
 7b8:	6161                	addi	sp,sp,80
 7ba:	8082                	ret

00000000000007bc <printf>:

void
printf(const char *fmt, ...)
{
 7bc:	711d                	addi	sp,sp,-96
 7be:	ec06                	sd	ra,24(sp)
 7c0:	e822                	sd	s0,16(sp)
 7c2:	1000                	addi	s0,sp,32
 7c4:	e40c                	sd	a1,8(s0)
 7c6:	e810                	sd	a2,16(s0)
 7c8:	ec14                	sd	a3,24(s0)
 7ca:	f018                	sd	a4,32(s0)
 7cc:	f41c                	sd	a5,40(s0)
 7ce:	03043823          	sd	a6,48(s0)
 7d2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7d6:	00840613          	addi	a2,s0,8
 7da:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7de:	85aa                	mv	a1,a0
 7e0:	4505                	li	a0,1
 7e2:	d19ff0ef          	jal	ra,4fa <vprintf>
}
 7e6:	60e2                	ld	ra,24(sp)
 7e8:	6442                	ld	s0,16(sp)
 7ea:	6125                	addi	sp,sp,96
 7ec:	8082                	ret

00000000000007ee <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ee:	1141                	addi	sp,sp,-16
 7f0:	e422                	sd	s0,8(sp)
 7f2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7f4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f8:	00001797          	auipc	a5,0x1
 7fc:	8087b783          	ld	a5,-2040(a5) # 1000 <freep>
 800:	a805                	j	830 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 802:	4618                	lw	a4,8(a2)
 804:	9db9                	addw	a1,a1,a4
 806:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 80a:	6398                	ld	a4,0(a5)
 80c:	6318                	ld	a4,0(a4)
 80e:	fee53823          	sd	a4,-16(a0)
 812:	a091                	j	856 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 814:	ff852703          	lw	a4,-8(a0)
 818:	9e39                	addw	a2,a2,a4
 81a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 81c:	ff053703          	ld	a4,-16(a0)
 820:	e398                	sd	a4,0(a5)
 822:	a099                	j	868 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 824:	6398                	ld	a4,0(a5)
 826:	00e7e463          	bltu	a5,a4,82e <free+0x40>
 82a:	00e6ea63          	bltu	a3,a4,83e <free+0x50>
{
 82e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 830:	fed7fae3          	bgeu	a5,a3,824 <free+0x36>
 834:	6398                	ld	a4,0(a5)
 836:	00e6e463          	bltu	a3,a4,83e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 83a:	fee7eae3          	bltu	a5,a4,82e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 83e:	ff852583          	lw	a1,-8(a0)
 842:	6390                	ld	a2,0(a5)
 844:	02059713          	slli	a4,a1,0x20
 848:	9301                	srli	a4,a4,0x20
 84a:	0712                	slli	a4,a4,0x4
 84c:	9736                	add	a4,a4,a3
 84e:	fae60ae3          	beq	a2,a4,802 <free+0x14>
    bp->s.ptr = p->s.ptr;
 852:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 856:	4790                	lw	a2,8(a5)
 858:	02061713          	slli	a4,a2,0x20
 85c:	9301                	srli	a4,a4,0x20
 85e:	0712                	slli	a4,a4,0x4
 860:	973e                	add	a4,a4,a5
 862:	fae689e3          	beq	a3,a4,814 <free+0x26>
  } else
    p->s.ptr = bp;
 866:	e394                	sd	a3,0(a5)
  freep = p;
 868:	00000717          	auipc	a4,0x0
 86c:	78f73c23          	sd	a5,1944(a4) # 1000 <freep>
}
 870:	6422                	ld	s0,8(sp)
 872:	0141                	addi	sp,sp,16
 874:	8082                	ret

0000000000000876 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 876:	7139                	addi	sp,sp,-64
 878:	fc06                	sd	ra,56(sp)
 87a:	f822                	sd	s0,48(sp)
 87c:	f426                	sd	s1,40(sp)
 87e:	f04a                	sd	s2,32(sp)
 880:	ec4e                	sd	s3,24(sp)
 882:	e852                	sd	s4,16(sp)
 884:	e456                	sd	s5,8(sp)
 886:	e05a                	sd	s6,0(sp)
 888:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 88a:	02051493          	slli	s1,a0,0x20
 88e:	9081                	srli	s1,s1,0x20
 890:	04bd                	addi	s1,s1,15
 892:	8091                	srli	s1,s1,0x4
 894:	0014899b          	addiw	s3,s1,1
 898:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 89a:	00000517          	auipc	a0,0x0
 89e:	76653503          	ld	a0,1894(a0) # 1000 <freep>
 8a2:	c515                	beqz	a0,8ce <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8a6:	4798                	lw	a4,8(a5)
 8a8:	02977f63          	bgeu	a4,s1,8e6 <malloc+0x70>
 8ac:	8a4e                	mv	s4,s3
 8ae:	0009871b          	sext.w	a4,s3
 8b2:	6685                	lui	a3,0x1
 8b4:	00d77363          	bgeu	a4,a3,8ba <malloc+0x44>
 8b8:	6a05                	lui	s4,0x1
 8ba:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8be:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8c2:	00000917          	auipc	s2,0x0
 8c6:	73e90913          	addi	s2,s2,1854 # 1000 <freep>
  if(p == SBRK_ERROR)
 8ca:	5afd                	li	s5,-1
 8cc:	a0bd                	j	93a <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 8ce:	00001797          	auipc	a5,0x1
 8d2:	93a78793          	addi	a5,a5,-1734 # 1208 <base>
 8d6:	00000717          	auipc	a4,0x0
 8da:	72f73523          	sd	a5,1834(a4) # 1000 <freep>
 8de:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8e0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8e4:	b7e1                	j	8ac <malloc+0x36>
      if(p->s.size == nunits)
 8e6:	02e48b63          	beq	s1,a4,91c <malloc+0xa6>
        p->s.size -= nunits;
 8ea:	4137073b          	subw	a4,a4,s3
 8ee:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8f0:	1702                	slli	a4,a4,0x20
 8f2:	9301                	srli	a4,a4,0x20
 8f4:	0712                	slli	a4,a4,0x4
 8f6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8f8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8fc:	00000717          	auipc	a4,0x0
 900:	70a73223          	sd	a0,1796(a4) # 1000 <freep>
      return (void*)(p + 1);
 904:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 908:	70e2                	ld	ra,56(sp)
 90a:	7442                	ld	s0,48(sp)
 90c:	74a2                	ld	s1,40(sp)
 90e:	7902                	ld	s2,32(sp)
 910:	69e2                	ld	s3,24(sp)
 912:	6a42                	ld	s4,16(sp)
 914:	6aa2                	ld	s5,8(sp)
 916:	6b02                	ld	s6,0(sp)
 918:	6121                	addi	sp,sp,64
 91a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 91c:	6398                	ld	a4,0(a5)
 91e:	e118                	sd	a4,0(a0)
 920:	bff1                	j	8fc <malloc+0x86>
  hp->s.size = nu;
 922:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 926:	0541                	addi	a0,a0,16
 928:	ec7ff0ef          	jal	ra,7ee <free>
  return freep;
 92c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 930:	dd61                	beqz	a0,908 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 932:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 934:	4798                	lw	a4,8(a5)
 936:	fa9778e3          	bgeu	a4,s1,8e6 <malloc+0x70>
    if(p == freep)
 93a:	00093703          	ld	a4,0(s2)
 93e:	853e                	mv	a0,a5
 940:	fef719e3          	bne	a4,a5,932 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 944:	8552                	mv	a0,s4
 946:	a1fff0ef          	jal	ra,364 <sbrk>
  if(p == SBRK_ERROR)
 94a:	fd551ce3          	bne	a0,s5,922 <malloc+0xac>
        return 0;
 94e:	4501                	li	a0,0
 950:	bf65                	j	908 <malloc+0x92>
