
user/_init:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   c:	4589                	li	a1,2
   e:	00001517          	auipc	a0,0x1
  12:	90250513          	addi	a0,a0,-1790 # 910 <malloc+0xe8>
  16:	37c000ef          	jal	ra,392 <open>
  1a:	04054563          	bltz	a0,64 <main+0x64>
    mknod("console", CONSOLE, 0);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  1e:	4501                	li	a0,0
  20:	3aa000ef          	jal	ra,3ca <dup>
  dup(0);  // stderr
  24:	4501                	li	a0,0
  26:	3a4000ef          	jal	ra,3ca <dup>

  for(;;){
    printf("init: starting sh\n");
  2a:	00001917          	auipc	s2,0x1
  2e:	8ee90913          	addi	s2,s2,-1810 # 918 <malloc+0xf0>
  32:	854a                	mv	a0,s2
  34:	73a000ef          	jal	ra,76e <printf>
    pid = fork();
  38:	312000ef          	jal	ra,34a <fork>
  3c:	84aa                	mv	s1,a0
    if(pid < 0){
  3e:	04054363          	bltz	a0,84 <main+0x84>
      printf("init: fork failed\n");
      exit(1);
    }
    if(pid == 0){
  42:	c931                	beqz	a0,96 <main+0x96>
    }

    for(;;){
      // this call to wait() returns if the shell exits,
      // or if a parentless process exits.
      wpid = wait((int *) 0);
  44:	4501                	li	a0,0
  46:	314000ef          	jal	ra,35a <wait>
      if(wpid == pid){
  4a:	fea484e3          	beq	s1,a0,32 <main+0x32>
        // the shell exited; restart it.
        break;
      } else if(wpid < 0){
  4e:	fe055be3          	bgez	a0,44 <main+0x44>
        printf("init: wait returned an error\n");
  52:	00001517          	auipc	a0,0x1
  56:	91650513          	addi	a0,a0,-1770 # 968 <malloc+0x140>
  5a:	714000ef          	jal	ra,76e <printf>
        exit(1);
  5e:	4505                	li	a0,1
  60:	2f2000ef          	jal	ra,352 <exit>
    mknod("console", CONSOLE, 0);
  64:	4601                	li	a2,0
  66:	4585                	li	a1,1
  68:	00001517          	auipc	a0,0x1
  6c:	8a850513          	addi	a0,a0,-1880 # 910 <malloc+0xe8>
  70:	32a000ef          	jal	ra,39a <mknod>
    open("console", O_RDWR);
  74:	4589                	li	a1,2
  76:	00001517          	auipc	a0,0x1
  7a:	89a50513          	addi	a0,a0,-1894 # 910 <malloc+0xe8>
  7e:	314000ef          	jal	ra,392 <open>
  82:	bf71                	j	1e <main+0x1e>
      printf("init: fork failed\n");
  84:	00001517          	auipc	a0,0x1
  88:	8ac50513          	addi	a0,a0,-1876 # 930 <malloc+0x108>
  8c:	6e2000ef          	jal	ra,76e <printf>
      exit(1);
  90:	4505                	li	a0,1
  92:	2c0000ef          	jal	ra,352 <exit>
      exec("sh", argv);
  96:	00001597          	auipc	a1,0x1
  9a:	f6a58593          	addi	a1,a1,-150 # 1000 <argv>
  9e:	00001517          	auipc	a0,0x1
  a2:	8aa50513          	addi	a0,a0,-1878 # 948 <malloc+0x120>
  a6:	2e4000ef          	jal	ra,38a <exec>
      printf("init: exec sh failed\n");
  aa:	00001517          	auipc	a0,0x1
  ae:	8a650513          	addi	a0,a0,-1882 # 950 <malloc+0x128>
  b2:	6bc000ef          	jal	ra,76e <printf>
      exit(1);
  b6:	4505                	li	a0,1
  b8:	29a000ef          	jal	ra,352 <exit>

00000000000000bc <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  bc:	1141                	addi	sp,sp,-16
  be:	e406                	sd	ra,8(sp)
  c0:	e022                	sd	s0,0(sp)
  c2:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  c4:	f3dff0ef          	jal	ra,0 <main>
  exit(r);
  c8:	28a000ef          	jal	ra,352 <exit>

00000000000000cc <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  cc:	1141                	addi	sp,sp,-16
  ce:	e422                	sd	s0,8(sp)
  d0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  d2:	87aa                	mv	a5,a0
  d4:	0585                	addi	a1,a1,1
  d6:	0785                	addi	a5,a5,1
  d8:	fff5c703          	lbu	a4,-1(a1)
  dc:	fee78fa3          	sb	a4,-1(a5)
  e0:	fb75                	bnez	a4,d4 <strcpy+0x8>
    ;
  return os;
}
  e2:	6422                	ld	s0,8(sp)
  e4:	0141                	addi	sp,sp,16
  e6:	8082                	ret

00000000000000e8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e8:	1141                	addi	sp,sp,-16
  ea:	e422                	sd	s0,8(sp)
  ec:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ee:	00054783          	lbu	a5,0(a0)
  f2:	cb91                	beqz	a5,106 <strcmp+0x1e>
  f4:	0005c703          	lbu	a4,0(a1)
  f8:	00f71763          	bne	a4,a5,106 <strcmp+0x1e>
    p++, q++;
  fc:	0505                	addi	a0,a0,1
  fe:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 100:	00054783          	lbu	a5,0(a0)
 104:	fbe5                	bnez	a5,f4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 106:	0005c503          	lbu	a0,0(a1)
}
 10a:	40a7853b          	subw	a0,a5,a0
 10e:	6422                	ld	s0,8(sp)
 110:	0141                	addi	sp,sp,16
 112:	8082                	ret

0000000000000114 <strlen>:

uint
strlen(const char *s)
{
 114:	1141                	addi	sp,sp,-16
 116:	e422                	sd	s0,8(sp)
 118:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 11a:	00054783          	lbu	a5,0(a0)
 11e:	cf91                	beqz	a5,13a <strlen+0x26>
 120:	0505                	addi	a0,a0,1
 122:	87aa                	mv	a5,a0
 124:	4685                	li	a3,1
 126:	9e89                	subw	a3,a3,a0
 128:	00f6853b          	addw	a0,a3,a5
 12c:	0785                	addi	a5,a5,1
 12e:	fff7c703          	lbu	a4,-1(a5)
 132:	fb7d                	bnez	a4,128 <strlen+0x14>
    ;
  return n;
}
 134:	6422                	ld	s0,8(sp)
 136:	0141                	addi	sp,sp,16
 138:	8082                	ret
  for(n = 0; s[n]; n++)
 13a:	4501                	li	a0,0
 13c:	bfe5                	j	134 <strlen+0x20>

000000000000013e <memset>:

void*
memset(void *dst, int c, uint n)
{
 13e:	1141                	addi	sp,sp,-16
 140:	e422                	sd	s0,8(sp)
 142:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 144:	ca19                	beqz	a2,15a <memset+0x1c>
 146:	87aa                	mv	a5,a0
 148:	1602                	slli	a2,a2,0x20
 14a:	9201                	srli	a2,a2,0x20
 14c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 150:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 154:	0785                	addi	a5,a5,1
 156:	fee79de3          	bne	a5,a4,150 <memset+0x12>
  }
  return dst;
}
 15a:	6422                	ld	s0,8(sp)
 15c:	0141                	addi	sp,sp,16
 15e:	8082                	ret

0000000000000160 <strchr>:

char*
strchr(const char *s, char c)
{
 160:	1141                	addi	sp,sp,-16
 162:	e422                	sd	s0,8(sp)
 164:	0800                	addi	s0,sp,16
  for(; *s; s++)
 166:	00054783          	lbu	a5,0(a0)
 16a:	cb99                	beqz	a5,180 <strchr+0x20>
    if(*s == c)
 16c:	00f58763          	beq	a1,a5,17a <strchr+0x1a>
  for(; *s; s++)
 170:	0505                	addi	a0,a0,1
 172:	00054783          	lbu	a5,0(a0)
 176:	fbfd                	bnez	a5,16c <strchr+0xc>
      return (char*)s;
  return 0;
 178:	4501                	li	a0,0
}
 17a:	6422                	ld	s0,8(sp)
 17c:	0141                	addi	sp,sp,16
 17e:	8082                	ret
  return 0;
 180:	4501                	li	a0,0
 182:	bfe5                	j	17a <strchr+0x1a>

0000000000000184 <gets>:

char*
gets(char *buf, int max)
{
 184:	711d                	addi	sp,sp,-96
 186:	ec86                	sd	ra,88(sp)
 188:	e8a2                	sd	s0,80(sp)
 18a:	e4a6                	sd	s1,72(sp)
 18c:	e0ca                	sd	s2,64(sp)
 18e:	fc4e                	sd	s3,56(sp)
 190:	f852                	sd	s4,48(sp)
 192:	f456                	sd	s5,40(sp)
 194:	f05a                	sd	s6,32(sp)
 196:	ec5e                	sd	s7,24(sp)
 198:	1080                	addi	s0,sp,96
 19a:	8baa                	mv	s7,a0
 19c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 19e:	892a                	mv	s2,a0
 1a0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1a2:	4aa9                	li	s5,10
 1a4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1a6:	89a6                	mv	s3,s1
 1a8:	2485                	addiw	s1,s1,1
 1aa:	0344d663          	bge	s1,s4,1d6 <gets+0x52>
    cc = read(0, &c, 1);
 1ae:	4605                	li	a2,1
 1b0:	faf40593          	addi	a1,s0,-81
 1b4:	4501                	li	a0,0
 1b6:	1b4000ef          	jal	ra,36a <read>
    if(cc < 1)
 1ba:	00a05e63          	blez	a0,1d6 <gets+0x52>
    buf[i++] = c;
 1be:	faf44783          	lbu	a5,-81(s0)
 1c2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1c6:	01578763          	beq	a5,s5,1d4 <gets+0x50>
 1ca:	0905                	addi	s2,s2,1
 1cc:	fd679de3          	bne	a5,s6,1a6 <gets+0x22>
  for(i=0; i+1 < max; ){
 1d0:	89a6                	mv	s3,s1
 1d2:	a011                	j	1d6 <gets+0x52>
 1d4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1d6:	99de                	add	s3,s3,s7
 1d8:	00098023          	sb	zero,0(s3)
  return buf;
}
 1dc:	855e                	mv	a0,s7
 1de:	60e6                	ld	ra,88(sp)
 1e0:	6446                	ld	s0,80(sp)
 1e2:	64a6                	ld	s1,72(sp)
 1e4:	6906                	ld	s2,64(sp)
 1e6:	79e2                	ld	s3,56(sp)
 1e8:	7a42                	ld	s4,48(sp)
 1ea:	7aa2                	ld	s5,40(sp)
 1ec:	7b02                	ld	s6,32(sp)
 1ee:	6be2                	ld	s7,24(sp)
 1f0:	6125                	addi	sp,sp,96
 1f2:	8082                	ret

00000000000001f4 <stat>:

int
stat(const char *n, struct stat *st)
{
 1f4:	1101                	addi	sp,sp,-32
 1f6:	ec06                	sd	ra,24(sp)
 1f8:	e822                	sd	s0,16(sp)
 1fa:	e426                	sd	s1,8(sp)
 1fc:	e04a                	sd	s2,0(sp)
 1fe:	1000                	addi	s0,sp,32
 200:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 202:	4581                	li	a1,0
 204:	18e000ef          	jal	ra,392 <open>
  if(fd < 0)
 208:	02054163          	bltz	a0,22a <stat+0x36>
 20c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 20e:	85ca                	mv	a1,s2
 210:	19a000ef          	jal	ra,3aa <fstat>
 214:	892a                	mv	s2,a0
  close(fd);
 216:	8526                	mv	a0,s1
 218:	162000ef          	jal	ra,37a <close>
  return r;
}
 21c:	854a                	mv	a0,s2
 21e:	60e2                	ld	ra,24(sp)
 220:	6442                	ld	s0,16(sp)
 222:	64a2                	ld	s1,8(sp)
 224:	6902                	ld	s2,0(sp)
 226:	6105                	addi	sp,sp,32
 228:	8082                	ret
    return -1;
 22a:	597d                	li	s2,-1
 22c:	bfc5                	j	21c <stat+0x28>

000000000000022e <atoi>:

int
atoi(const char *s)
{
 22e:	1141                	addi	sp,sp,-16
 230:	e422                	sd	s0,8(sp)
 232:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 234:	00054603          	lbu	a2,0(a0)
 238:	fd06079b          	addiw	a5,a2,-48
 23c:	0ff7f793          	andi	a5,a5,255
 240:	4725                	li	a4,9
 242:	02f76963          	bltu	a4,a5,274 <atoi+0x46>
 246:	86aa                	mv	a3,a0
  n = 0;
 248:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 24a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 24c:	0685                	addi	a3,a3,1
 24e:	0025179b          	slliw	a5,a0,0x2
 252:	9fa9                	addw	a5,a5,a0
 254:	0017979b          	slliw	a5,a5,0x1
 258:	9fb1                	addw	a5,a5,a2
 25a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 25e:	0006c603          	lbu	a2,0(a3)
 262:	fd06071b          	addiw	a4,a2,-48
 266:	0ff77713          	andi	a4,a4,255
 26a:	fee5f1e3          	bgeu	a1,a4,24c <atoi+0x1e>
  return n;
}
 26e:	6422                	ld	s0,8(sp)
 270:	0141                	addi	sp,sp,16
 272:	8082                	ret
  n = 0;
 274:	4501                	li	a0,0
 276:	bfe5                	j	26e <atoi+0x40>

0000000000000278 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 278:	1141                	addi	sp,sp,-16
 27a:	e422                	sd	s0,8(sp)
 27c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 27e:	02b57463          	bgeu	a0,a1,2a6 <memmove+0x2e>
    while(n-- > 0)
 282:	00c05f63          	blez	a2,2a0 <memmove+0x28>
 286:	1602                	slli	a2,a2,0x20
 288:	9201                	srli	a2,a2,0x20
 28a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 28e:	872a                	mv	a4,a0
      *dst++ = *src++;
 290:	0585                	addi	a1,a1,1
 292:	0705                	addi	a4,a4,1
 294:	fff5c683          	lbu	a3,-1(a1)
 298:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 29c:	fee79ae3          	bne	a5,a4,290 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2a0:	6422                	ld	s0,8(sp)
 2a2:	0141                	addi	sp,sp,16
 2a4:	8082                	ret
    dst += n;
 2a6:	00c50733          	add	a4,a0,a2
    src += n;
 2aa:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2ac:	fec05ae3          	blez	a2,2a0 <memmove+0x28>
 2b0:	fff6079b          	addiw	a5,a2,-1
 2b4:	1782                	slli	a5,a5,0x20
 2b6:	9381                	srli	a5,a5,0x20
 2b8:	fff7c793          	not	a5,a5
 2bc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2be:	15fd                	addi	a1,a1,-1
 2c0:	177d                	addi	a4,a4,-1
 2c2:	0005c683          	lbu	a3,0(a1)
 2c6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2ca:	fee79ae3          	bne	a5,a4,2be <memmove+0x46>
 2ce:	bfc9                	j	2a0 <memmove+0x28>

00000000000002d0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2d0:	1141                	addi	sp,sp,-16
 2d2:	e422                	sd	s0,8(sp)
 2d4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2d6:	ca05                	beqz	a2,306 <memcmp+0x36>
 2d8:	fff6069b          	addiw	a3,a2,-1
 2dc:	1682                	slli	a3,a3,0x20
 2de:	9281                	srli	a3,a3,0x20
 2e0:	0685                	addi	a3,a3,1
 2e2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2e4:	00054783          	lbu	a5,0(a0)
 2e8:	0005c703          	lbu	a4,0(a1)
 2ec:	00e79863          	bne	a5,a4,2fc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2f0:	0505                	addi	a0,a0,1
    p2++;
 2f2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2f4:	fed518e3          	bne	a0,a3,2e4 <memcmp+0x14>
  }
  return 0;
 2f8:	4501                	li	a0,0
 2fa:	a019                	j	300 <memcmp+0x30>
      return *p1 - *p2;
 2fc:	40e7853b          	subw	a0,a5,a4
}
 300:	6422                	ld	s0,8(sp)
 302:	0141                	addi	sp,sp,16
 304:	8082                	ret
  return 0;
 306:	4501                	li	a0,0
 308:	bfe5                	j	300 <memcmp+0x30>

000000000000030a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 30a:	1141                	addi	sp,sp,-16
 30c:	e406                	sd	ra,8(sp)
 30e:	e022                	sd	s0,0(sp)
 310:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 312:	f67ff0ef          	jal	ra,278 <memmove>
}
 316:	60a2                	ld	ra,8(sp)
 318:	6402                	ld	s0,0(sp)
 31a:	0141                	addi	sp,sp,16
 31c:	8082                	ret

000000000000031e <sbrk>:

char *
sbrk(int n) {
 31e:	1141                	addi	sp,sp,-16
 320:	e406                	sd	ra,8(sp)
 322:	e022                	sd	s0,0(sp)
 324:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 326:	4585                	li	a1,1
 328:	0b2000ef          	jal	ra,3da <sys_sbrk>
}
 32c:	60a2                	ld	ra,8(sp)
 32e:	6402                	ld	s0,0(sp)
 330:	0141                	addi	sp,sp,16
 332:	8082                	ret

0000000000000334 <sbrklazy>:

char *
sbrklazy(int n) {
 334:	1141                	addi	sp,sp,-16
 336:	e406                	sd	ra,8(sp)
 338:	e022                	sd	s0,0(sp)
 33a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 33c:	4589                	li	a1,2
 33e:	09c000ef          	jal	ra,3da <sys_sbrk>
}
 342:	60a2                	ld	ra,8(sp)
 344:	6402                	ld	s0,0(sp)
 346:	0141                	addi	sp,sp,16
 348:	8082                	ret

000000000000034a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 34a:	4885                	li	a7,1
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <exit>:
.global exit
exit:
 li a7, SYS_exit
 352:	4889                	li	a7,2
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <wait>:
.global wait
wait:
 li a7, SYS_wait
 35a:	488d                	li	a7,3
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 362:	4891                	li	a7,4
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <read>:
.global read
read:
 li a7, SYS_read
 36a:	4895                	li	a7,5
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <write>:
.global write
write:
 li a7, SYS_write
 372:	48c1                	li	a7,16
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <close>:
.global close
close:
 li a7, SYS_close
 37a:	48d5                	li	a7,21
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <kill>:
.global kill
kill:
 li a7, SYS_kill
 382:	4899                	li	a7,6
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <exec>:
.global exec
exec:
 li a7, SYS_exec
 38a:	489d                	li	a7,7
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <open>:
.global open
open:
 li a7, SYS_open
 392:	48bd                	li	a7,15
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 39a:	48c5                	li	a7,17
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3a2:	48c9                	li	a7,18
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3aa:	48a1                	li	a7,8
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <link>:
.global link
link:
 li a7, SYS_link
 3b2:	48cd                	li	a7,19
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3ba:	48d1                	li	a7,20
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3c2:	48a5                	li	a7,9
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <dup>:
.global dup
dup:
 li a7, SYS_dup
 3ca:	48a9                	li	a7,10
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3d2:	48ad                	li	a7,11
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3da:	48b1                	li	a7,12
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3e2:	48b5                	li	a7,13
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3ea:	48b9                	li	a7,14
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3f2:	1101                	addi	sp,sp,-32
 3f4:	ec06                	sd	ra,24(sp)
 3f6:	e822                	sd	s0,16(sp)
 3f8:	1000                	addi	s0,sp,32
 3fa:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3fe:	4605                	li	a2,1
 400:	fef40593          	addi	a1,s0,-17
 404:	f6fff0ef          	jal	ra,372 <write>
}
 408:	60e2                	ld	ra,24(sp)
 40a:	6442                	ld	s0,16(sp)
 40c:	6105                	addi	sp,sp,32
 40e:	8082                	ret

0000000000000410 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 410:	715d                	addi	sp,sp,-80
 412:	e486                	sd	ra,72(sp)
 414:	e0a2                	sd	s0,64(sp)
 416:	fc26                	sd	s1,56(sp)
 418:	f84a                	sd	s2,48(sp)
 41a:	f44e                	sd	s3,40(sp)
 41c:	0880                	addi	s0,sp,80
 41e:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 420:	c299                	beqz	a3,426 <printint+0x16>
 422:	0805c163          	bltz	a1,4a4 <printint+0x94>
  neg = 0;
 426:	4881                	li	a7,0
 428:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 42c:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 42e:	00000517          	auipc	a0,0x0
 432:	56250513          	addi	a0,a0,1378 # 990 <digits>
 436:	883e                	mv	a6,a5
 438:	2785                	addiw	a5,a5,1
 43a:	02c5f733          	remu	a4,a1,a2
 43e:	972a                	add	a4,a4,a0
 440:	00074703          	lbu	a4,0(a4)
 444:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 448:	872e                	mv	a4,a1
 44a:	02c5d5b3          	divu	a1,a1,a2
 44e:	0685                	addi	a3,a3,1
 450:	fec773e3          	bgeu	a4,a2,436 <printint+0x26>
  if(neg)
 454:	00088b63          	beqz	a7,46a <printint+0x5a>
    buf[i++] = '-';
 458:	fd040713          	addi	a4,s0,-48
 45c:	97ba                	add	a5,a5,a4
 45e:	02d00713          	li	a4,45
 462:	fee78423          	sb	a4,-24(a5)
 466:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 46a:	02f05663          	blez	a5,496 <printint+0x86>
 46e:	fb840713          	addi	a4,s0,-72
 472:	00f704b3          	add	s1,a4,a5
 476:	fff70993          	addi	s3,a4,-1
 47a:	99be                	add	s3,s3,a5
 47c:	37fd                	addiw	a5,a5,-1
 47e:	1782                	slli	a5,a5,0x20
 480:	9381                	srli	a5,a5,0x20
 482:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 486:	fff4c583          	lbu	a1,-1(s1)
 48a:	854a                	mv	a0,s2
 48c:	f67ff0ef          	jal	ra,3f2 <putc>
  while(--i >= 0)
 490:	14fd                	addi	s1,s1,-1
 492:	ff349ae3          	bne	s1,s3,486 <printint+0x76>
}
 496:	60a6                	ld	ra,72(sp)
 498:	6406                	ld	s0,64(sp)
 49a:	74e2                	ld	s1,56(sp)
 49c:	7942                	ld	s2,48(sp)
 49e:	79a2                	ld	s3,40(sp)
 4a0:	6161                	addi	sp,sp,80
 4a2:	8082                	ret
    x = -xx;
 4a4:	40b005b3          	neg	a1,a1
    neg = 1;
 4a8:	4885                	li	a7,1
    x = -xx;
 4aa:	bfbd                	j	428 <printint+0x18>

00000000000004ac <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4ac:	7119                	addi	sp,sp,-128
 4ae:	fc86                	sd	ra,120(sp)
 4b0:	f8a2                	sd	s0,112(sp)
 4b2:	f4a6                	sd	s1,104(sp)
 4b4:	f0ca                	sd	s2,96(sp)
 4b6:	ecce                	sd	s3,88(sp)
 4b8:	e8d2                	sd	s4,80(sp)
 4ba:	e4d6                	sd	s5,72(sp)
 4bc:	e0da                	sd	s6,64(sp)
 4be:	fc5e                	sd	s7,56(sp)
 4c0:	f862                	sd	s8,48(sp)
 4c2:	f466                	sd	s9,40(sp)
 4c4:	f06a                	sd	s10,32(sp)
 4c6:	ec6e                	sd	s11,24(sp)
 4c8:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4ca:	0005c903          	lbu	s2,0(a1)
 4ce:	24090c63          	beqz	s2,726 <vprintf+0x27a>
 4d2:	8b2a                	mv	s6,a0
 4d4:	8a2e                	mv	s4,a1
 4d6:	8bb2                	mv	s7,a2
  state = 0;
 4d8:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4da:	4481                	li	s1,0
 4dc:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4de:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4e2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4e6:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4ea:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4ee:	00000c97          	auipc	s9,0x0
 4f2:	4a2c8c93          	addi	s9,s9,1186 # 990 <digits>
 4f6:	a005                	j	516 <vprintf+0x6a>
        putc(fd, c0);
 4f8:	85ca                	mv	a1,s2
 4fa:	855a                	mv	a0,s6
 4fc:	ef7ff0ef          	jal	ra,3f2 <putc>
 500:	a019                	j	506 <vprintf+0x5a>
    } else if(state == '%'){
 502:	03598263          	beq	s3,s5,526 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 506:	2485                	addiw	s1,s1,1
 508:	8726                	mv	a4,s1
 50a:	009a07b3          	add	a5,s4,s1
 50e:	0007c903          	lbu	s2,0(a5)
 512:	20090a63          	beqz	s2,726 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 516:	0009079b          	sext.w	a5,s2
    if(state == 0){
 51a:	fe0994e3          	bnez	s3,502 <vprintf+0x56>
      if(c0 == '%'){
 51e:	fd579de3          	bne	a5,s5,4f8 <vprintf+0x4c>
        state = '%';
 522:	89be                	mv	s3,a5
 524:	b7cd                	j	506 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 526:	c3c1                	beqz	a5,5a6 <vprintf+0xfa>
 528:	00ea06b3          	add	a3,s4,a4
 52c:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 530:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 532:	c681                	beqz	a3,53a <vprintf+0x8e>
 534:	9752                	add	a4,a4,s4
 536:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 53a:	03878e63          	beq	a5,s8,576 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 53e:	05a78863          	beq	a5,s10,58e <vprintf+0xe2>
      } else if(c0 == 'u'){
 542:	0db78b63          	beq	a5,s11,618 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 546:	07800713          	li	a4,120
 54a:	10e78d63          	beq	a5,a4,664 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 54e:	07000713          	li	a4,112
 552:	14e78263          	beq	a5,a4,696 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 556:	06300713          	li	a4,99
 55a:	16e78f63          	beq	a5,a4,6d8 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 55e:	07300713          	li	a4,115
 562:	18e78563          	beq	a5,a4,6ec <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 566:	05579063          	bne	a5,s5,5a6 <vprintf+0xfa>
        putc(fd, '%');
 56a:	85d6                	mv	a1,s5
 56c:	855a                	mv	a0,s6
 56e:	e85ff0ef          	jal	ra,3f2 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 572:	4981                	li	s3,0
 574:	bf49                	j	506 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 576:	008b8913          	addi	s2,s7,8
 57a:	4685                	li	a3,1
 57c:	4629                	li	a2,10
 57e:	000ba583          	lw	a1,0(s7)
 582:	855a                	mv	a0,s6
 584:	e8dff0ef          	jal	ra,410 <printint>
 588:	8bca                	mv	s7,s2
      state = 0;
 58a:	4981                	li	s3,0
 58c:	bfad                	j	506 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 58e:	03868663          	beq	a3,s8,5ba <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 592:	05a68163          	beq	a3,s10,5d4 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 596:	09b68d63          	beq	a3,s11,630 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 59a:	03a68f63          	beq	a3,s10,5d8 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 59e:	07800793          	li	a5,120
 5a2:	0cf68d63          	beq	a3,a5,67c <vprintf+0x1d0>
        putc(fd, '%');
 5a6:	85d6                	mv	a1,s5
 5a8:	855a                	mv	a0,s6
 5aa:	e49ff0ef          	jal	ra,3f2 <putc>
        putc(fd, c0);
 5ae:	85ca                	mv	a1,s2
 5b0:	855a                	mv	a0,s6
 5b2:	e41ff0ef          	jal	ra,3f2 <putc>
      state = 0;
 5b6:	4981                	li	s3,0
 5b8:	b7b9                	j	506 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ba:	008b8913          	addi	s2,s7,8
 5be:	4685                	li	a3,1
 5c0:	4629                	li	a2,10
 5c2:	000bb583          	ld	a1,0(s7)
 5c6:	855a                	mv	a0,s6
 5c8:	e49ff0ef          	jal	ra,410 <printint>
        i += 1;
 5cc:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ce:	8bca                	mv	s7,s2
      state = 0;
 5d0:	4981                	li	s3,0
        i += 1;
 5d2:	bf15                	j	506 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5d4:	03860563          	beq	a2,s8,5fe <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5d8:	07b60963          	beq	a2,s11,64a <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5dc:	07800793          	li	a5,120
 5e0:	fcf613e3          	bne	a2,a5,5a6 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5e4:	008b8913          	addi	s2,s7,8
 5e8:	4681                	li	a3,0
 5ea:	4641                	li	a2,16
 5ec:	000bb583          	ld	a1,0(s7)
 5f0:	855a                	mv	a0,s6
 5f2:	e1fff0ef          	jal	ra,410 <printint>
        i += 2;
 5f6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5f8:	8bca                	mv	s7,s2
      state = 0;
 5fa:	4981                	li	s3,0
        i += 2;
 5fc:	b729                	j	506 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5fe:	008b8913          	addi	s2,s7,8
 602:	4685                	li	a3,1
 604:	4629                	li	a2,10
 606:	000bb583          	ld	a1,0(s7)
 60a:	855a                	mv	a0,s6
 60c:	e05ff0ef          	jal	ra,410 <printint>
        i += 2;
 610:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 612:	8bca                	mv	s7,s2
      state = 0;
 614:	4981                	li	s3,0
        i += 2;
 616:	bdc5                	j	506 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 618:	008b8913          	addi	s2,s7,8
 61c:	4681                	li	a3,0
 61e:	4629                	li	a2,10
 620:	000be583          	lwu	a1,0(s7)
 624:	855a                	mv	a0,s6
 626:	debff0ef          	jal	ra,410 <printint>
 62a:	8bca                	mv	s7,s2
      state = 0;
 62c:	4981                	li	s3,0
 62e:	bde1                	j	506 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 630:	008b8913          	addi	s2,s7,8
 634:	4681                	li	a3,0
 636:	4629                	li	a2,10
 638:	000bb583          	ld	a1,0(s7)
 63c:	855a                	mv	a0,s6
 63e:	dd3ff0ef          	jal	ra,410 <printint>
        i += 1;
 642:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 644:	8bca                	mv	s7,s2
      state = 0;
 646:	4981                	li	s3,0
        i += 1;
 648:	bd7d                	j	506 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 64a:	008b8913          	addi	s2,s7,8
 64e:	4681                	li	a3,0
 650:	4629                	li	a2,10
 652:	000bb583          	ld	a1,0(s7)
 656:	855a                	mv	a0,s6
 658:	db9ff0ef          	jal	ra,410 <printint>
        i += 2;
 65c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 65e:	8bca                	mv	s7,s2
      state = 0;
 660:	4981                	li	s3,0
        i += 2;
 662:	b555                	j	506 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 664:	008b8913          	addi	s2,s7,8
 668:	4681                	li	a3,0
 66a:	4641                	li	a2,16
 66c:	000be583          	lwu	a1,0(s7)
 670:	855a                	mv	a0,s6
 672:	d9fff0ef          	jal	ra,410 <printint>
 676:	8bca                	mv	s7,s2
      state = 0;
 678:	4981                	li	s3,0
 67a:	b571                	j	506 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 67c:	008b8913          	addi	s2,s7,8
 680:	4681                	li	a3,0
 682:	4641                	li	a2,16
 684:	000bb583          	ld	a1,0(s7)
 688:	855a                	mv	a0,s6
 68a:	d87ff0ef          	jal	ra,410 <printint>
        i += 1;
 68e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 690:	8bca                	mv	s7,s2
      state = 0;
 692:	4981                	li	s3,0
        i += 1;
 694:	bd8d                	j	506 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 696:	008b8793          	addi	a5,s7,8
 69a:	f8f43423          	sd	a5,-120(s0)
 69e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6a2:	03000593          	li	a1,48
 6a6:	855a                	mv	a0,s6
 6a8:	d4bff0ef          	jal	ra,3f2 <putc>
  putc(fd, 'x');
 6ac:	07800593          	li	a1,120
 6b0:	855a                	mv	a0,s6
 6b2:	d41ff0ef          	jal	ra,3f2 <putc>
 6b6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6b8:	03c9d793          	srli	a5,s3,0x3c
 6bc:	97e6                	add	a5,a5,s9
 6be:	0007c583          	lbu	a1,0(a5)
 6c2:	855a                	mv	a0,s6
 6c4:	d2fff0ef          	jal	ra,3f2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6c8:	0992                	slli	s3,s3,0x4
 6ca:	397d                	addiw	s2,s2,-1
 6cc:	fe0916e3          	bnez	s2,6b8 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 6d0:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 6d4:	4981                	li	s3,0
 6d6:	bd05                	j	506 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 6d8:	008b8913          	addi	s2,s7,8
 6dc:	000bc583          	lbu	a1,0(s7)
 6e0:	855a                	mv	a0,s6
 6e2:	d11ff0ef          	jal	ra,3f2 <putc>
 6e6:	8bca                	mv	s7,s2
      state = 0;
 6e8:	4981                	li	s3,0
 6ea:	bd31                	j	506 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 6ec:	008b8993          	addi	s3,s7,8
 6f0:	000bb903          	ld	s2,0(s7)
 6f4:	00090f63          	beqz	s2,712 <vprintf+0x266>
        for(; *s; s++)
 6f8:	00094583          	lbu	a1,0(s2)
 6fc:	c195                	beqz	a1,720 <vprintf+0x274>
          putc(fd, *s);
 6fe:	855a                	mv	a0,s6
 700:	cf3ff0ef          	jal	ra,3f2 <putc>
        for(; *s; s++)
 704:	0905                	addi	s2,s2,1
 706:	00094583          	lbu	a1,0(s2)
 70a:	f9f5                	bnez	a1,6fe <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 70c:	8bce                	mv	s7,s3
      state = 0;
 70e:	4981                	li	s3,0
 710:	bbdd                	j	506 <vprintf+0x5a>
          s = "(null)";
 712:	00000917          	auipc	s2,0x0
 716:	27690913          	addi	s2,s2,630 # 988 <malloc+0x160>
        for(; *s; s++)
 71a:	02800593          	li	a1,40
 71e:	b7c5                	j	6fe <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 720:	8bce                	mv	s7,s3
      state = 0;
 722:	4981                	li	s3,0
 724:	b3cd                	j	506 <vprintf+0x5a>
    }
  }
}
 726:	70e6                	ld	ra,120(sp)
 728:	7446                	ld	s0,112(sp)
 72a:	74a6                	ld	s1,104(sp)
 72c:	7906                	ld	s2,96(sp)
 72e:	69e6                	ld	s3,88(sp)
 730:	6a46                	ld	s4,80(sp)
 732:	6aa6                	ld	s5,72(sp)
 734:	6b06                	ld	s6,64(sp)
 736:	7be2                	ld	s7,56(sp)
 738:	7c42                	ld	s8,48(sp)
 73a:	7ca2                	ld	s9,40(sp)
 73c:	7d02                	ld	s10,32(sp)
 73e:	6de2                	ld	s11,24(sp)
 740:	6109                	addi	sp,sp,128
 742:	8082                	ret

0000000000000744 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 744:	715d                	addi	sp,sp,-80
 746:	ec06                	sd	ra,24(sp)
 748:	e822                	sd	s0,16(sp)
 74a:	1000                	addi	s0,sp,32
 74c:	e010                	sd	a2,0(s0)
 74e:	e414                	sd	a3,8(s0)
 750:	e818                	sd	a4,16(s0)
 752:	ec1c                	sd	a5,24(s0)
 754:	03043023          	sd	a6,32(s0)
 758:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 75c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 760:	8622                	mv	a2,s0
 762:	d4bff0ef          	jal	ra,4ac <vprintf>
}
 766:	60e2                	ld	ra,24(sp)
 768:	6442                	ld	s0,16(sp)
 76a:	6161                	addi	sp,sp,80
 76c:	8082                	ret

000000000000076e <printf>:

void
printf(const char *fmt, ...)
{
 76e:	711d                	addi	sp,sp,-96
 770:	ec06                	sd	ra,24(sp)
 772:	e822                	sd	s0,16(sp)
 774:	1000                	addi	s0,sp,32
 776:	e40c                	sd	a1,8(s0)
 778:	e810                	sd	a2,16(s0)
 77a:	ec14                	sd	a3,24(s0)
 77c:	f018                	sd	a4,32(s0)
 77e:	f41c                	sd	a5,40(s0)
 780:	03043823          	sd	a6,48(s0)
 784:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 788:	00840613          	addi	a2,s0,8
 78c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 790:	85aa                	mv	a1,a0
 792:	4505                	li	a0,1
 794:	d19ff0ef          	jal	ra,4ac <vprintf>
}
 798:	60e2                	ld	ra,24(sp)
 79a:	6442                	ld	s0,16(sp)
 79c:	6125                	addi	sp,sp,96
 79e:	8082                	ret

00000000000007a0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7a0:	1141                	addi	sp,sp,-16
 7a2:	e422                	sd	s0,8(sp)
 7a4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7a6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7aa:	00001797          	auipc	a5,0x1
 7ae:	8667b783          	ld	a5,-1946(a5) # 1010 <freep>
 7b2:	a805                	j	7e2 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7b4:	4618                	lw	a4,8(a2)
 7b6:	9db9                	addw	a1,a1,a4
 7b8:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7bc:	6398                	ld	a4,0(a5)
 7be:	6318                	ld	a4,0(a4)
 7c0:	fee53823          	sd	a4,-16(a0)
 7c4:	a091                	j	808 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7c6:	ff852703          	lw	a4,-8(a0)
 7ca:	9e39                	addw	a2,a2,a4
 7cc:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7ce:	ff053703          	ld	a4,-16(a0)
 7d2:	e398                	sd	a4,0(a5)
 7d4:	a099                	j	81a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d6:	6398                	ld	a4,0(a5)
 7d8:	00e7e463          	bltu	a5,a4,7e0 <free+0x40>
 7dc:	00e6ea63          	bltu	a3,a4,7f0 <free+0x50>
{
 7e0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e2:	fed7fae3          	bgeu	a5,a3,7d6 <free+0x36>
 7e6:	6398                	ld	a4,0(a5)
 7e8:	00e6e463          	bltu	a3,a4,7f0 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ec:	fee7eae3          	bltu	a5,a4,7e0 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7f0:	ff852583          	lw	a1,-8(a0)
 7f4:	6390                	ld	a2,0(a5)
 7f6:	02059713          	slli	a4,a1,0x20
 7fa:	9301                	srli	a4,a4,0x20
 7fc:	0712                	slli	a4,a4,0x4
 7fe:	9736                	add	a4,a4,a3
 800:	fae60ae3          	beq	a2,a4,7b4 <free+0x14>
    bp->s.ptr = p->s.ptr;
 804:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 808:	4790                	lw	a2,8(a5)
 80a:	02061713          	slli	a4,a2,0x20
 80e:	9301                	srli	a4,a4,0x20
 810:	0712                	slli	a4,a4,0x4
 812:	973e                	add	a4,a4,a5
 814:	fae689e3          	beq	a3,a4,7c6 <free+0x26>
  } else
    p->s.ptr = bp;
 818:	e394                	sd	a3,0(a5)
  freep = p;
 81a:	00000717          	auipc	a4,0x0
 81e:	7ef73b23          	sd	a5,2038(a4) # 1010 <freep>
}
 822:	6422                	ld	s0,8(sp)
 824:	0141                	addi	sp,sp,16
 826:	8082                	ret

0000000000000828 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 828:	7139                	addi	sp,sp,-64
 82a:	fc06                	sd	ra,56(sp)
 82c:	f822                	sd	s0,48(sp)
 82e:	f426                	sd	s1,40(sp)
 830:	f04a                	sd	s2,32(sp)
 832:	ec4e                	sd	s3,24(sp)
 834:	e852                	sd	s4,16(sp)
 836:	e456                	sd	s5,8(sp)
 838:	e05a                	sd	s6,0(sp)
 83a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 83c:	02051493          	slli	s1,a0,0x20
 840:	9081                	srli	s1,s1,0x20
 842:	04bd                	addi	s1,s1,15
 844:	8091                	srli	s1,s1,0x4
 846:	0014899b          	addiw	s3,s1,1
 84a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 84c:	00000517          	auipc	a0,0x0
 850:	7c453503          	ld	a0,1988(a0) # 1010 <freep>
 854:	c515                	beqz	a0,880 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 856:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 858:	4798                	lw	a4,8(a5)
 85a:	02977f63          	bgeu	a4,s1,898 <malloc+0x70>
 85e:	8a4e                	mv	s4,s3
 860:	0009871b          	sext.w	a4,s3
 864:	6685                	lui	a3,0x1
 866:	00d77363          	bgeu	a4,a3,86c <malloc+0x44>
 86a:	6a05                	lui	s4,0x1
 86c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 870:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 874:	00000917          	auipc	s2,0x0
 878:	79c90913          	addi	s2,s2,1948 # 1010 <freep>
  if(p == SBRK_ERROR)
 87c:	5afd                	li	s5,-1
 87e:	a0bd                	j	8ec <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 880:	00000797          	auipc	a5,0x0
 884:	7a078793          	addi	a5,a5,1952 # 1020 <base>
 888:	00000717          	auipc	a4,0x0
 88c:	78f73423          	sd	a5,1928(a4) # 1010 <freep>
 890:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 892:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 896:	b7e1                	j	85e <malloc+0x36>
      if(p->s.size == nunits)
 898:	02e48b63          	beq	s1,a4,8ce <malloc+0xa6>
        p->s.size -= nunits;
 89c:	4137073b          	subw	a4,a4,s3
 8a0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8a2:	1702                	slli	a4,a4,0x20
 8a4:	9301                	srli	a4,a4,0x20
 8a6:	0712                	slli	a4,a4,0x4
 8a8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8aa:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ae:	00000717          	auipc	a4,0x0
 8b2:	76a73123          	sd	a0,1890(a4) # 1010 <freep>
      return (void*)(p + 1);
 8b6:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8ba:	70e2                	ld	ra,56(sp)
 8bc:	7442                	ld	s0,48(sp)
 8be:	74a2                	ld	s1,40(sp)
 8c0:	7902                	ld	s2,32(sp)
 8c2:	69e2                	ld	s3,24(sp)
 8c4:	6a42                	ld	s4,16(sp)
 8c6:	6aa2                	ld	s5,8(sp)
 8c8:	6b02                	ld	s6,0(sp)
 8ca:	6121                	addi	sp,sp,64
 8cc:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8ce:	6398                	ld	a4,0(a5)
 8d0:	e118                	sd	a4,0(a0)
 8d2:	bff1                	j	8ae <malloc+0x86>
  hp->s.size = nu;
 8d4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8d8:	0541                	addi	a0,a0,16
 8da:	ec7ff0ef          	jal	ra,7a0 <free>
  return freep;
 8de:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8e2:	dd61                	beqz	a0,8ba <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e6:	4798                	lw	a4,8(a5)
 8e8:	fa9778e3          	bgeu	a4,s1,898 <malloc+0x70>
    if(p == freep)
 8ec:	00093703          	ld	a4,0(s2)
 8f0:	853e                	mv	a0,a5
 8f2:	fef719e3          	bne	a4,a5,8e4 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 8f6:	8552                	mv	a0,s4
 8f8:	a27ff0ef          	jal	ra,31e <sbrk>
  if(p == SBRK_ERROR)
 8fc:	fd551ce3          	bne	a0,s5,8d4 <malloc+0xac>
        return 0;
 900:	4501                	li	a0,0
 902:	bf65                	j	8ba <malloc+0x92>
