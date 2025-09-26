
user/_cat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	89aa                	mv	s3,a0
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
  10:	00001917          	auipc	s2,0x1
  14:	00090913          	mv	s2,s2
  18:	20000613          	li	a2,512
  1c:	85ca                	mv	a1,s2
  1e:	854e                	mv	a0,s3
  20:	374000ef          	jal	ra,394 <read>
  24:	84aa                	mv	s1,a0
  26:	02a05363          	blez	a0,4c <cat+0x4c>
    if (write(1, buf, n) != n) {
  2a:	8626                	mv	a2,s1
  2c:	85ca                	mv	a1,s2
  2e:	4505                	li	a0,1
  30:	36c000ef          	jal	ra,39c <write>
  34:	fe9502e3          	beq	a0,s1,18 <cat+0x18>
      fprintf(2, "cat: write error\n");
  38:	00001597          	auipc	a1,0x1
  3c:	8f858593          	addi	a1,a1,-1800 # 930 <malloc+0xde>
  40:	4509                	li	a0,2
  42:	72c000ef          	jal	ra,76e <fprintf>
      exit(1);
  46:	4505                	li	a0,1
  48:	334000ef          	jal	ra,37c <exit>
    }
  }
  if(n < 0){
  4c:	00054963          	bltz	a0,5e <cat+0x5e>
    fprintf(2, "cat: read error\n");
    exit(1);
  }
}
  50:	70a2                	ld	ra,40(sp)
  52:	7402                	ld	s0,32(sp)
  54:	64e2                	ld	s1,24(sp)
  56:	6942                	ld	s2,16(sp)
  58:	69a2                	ld	s3,8(sp)
  5a:	6145                	addi	sp,sp,48
  5c:	8082                	ret
    fprintf(2, "cat: read error\n");
  5e:	00001597          	auipc	a1,0x1
  62:	8ea58593          	addi	a1,a1,-1814 # 948 <malloc+0xf6>
  66:	4509                	li	a0,2
  68:	706000ef          	jal	ra,76e <fprintf>
    exit(1);
  6c:	4505                	li	a0,1
  6e:	30e000ef          	jal	ra,37c <exit>

0000000000000072 <main>:

int
main(int argc, char *argv[])
{
  72:	7179                	addi	sp,sp,-48
  74:	f406                	sd	ra,40(sp)
  76:	f022                	sd	s0,32(sp)
  78:	ec26                	sd	s1,24(sp)
  7a:	e84a                	sd	s2,16(sp)
  7c:	e44e                	sd	s3,8(sp)
  7e:	e052                	sd	s4,0(sp)
  80:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  82:	4785                	li	a5,1
  84:	02a7df63          	bge	a5,a0,c2 <main+0x50>
  88:	00858913          	addi	s2,a1,8
  8c:	ffe5099b          	addiw	s3,a0,-2
  90:	1982                	slli	s3,s3,0x20
  92:	0209d993          	srli	s3,s3,0x20
  96:	098e                	slli	s3,s3,0x3
  98:	05c1                	addi	a1,a1,16
  9a:	99ae                	add	s3,s3,a1
    cat(0);
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], O_RDONLY)) < 0){
  9c:	4581                	li	a1,0
  9e:	00093503          	ld	a0,0(s2) # 1010 <buf>
  a2:	31a000ef          	jal	ra,3bc <open>
  a6:	84aa                	mv	s1,a0
  a8:	02054363          	bltz	a0,ce <main+0x5c>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
      exit(1);
    }
    cat(fd);
  ac:	f55ff0ef          	jal	ra,0 <cat>
    close(fd);
  b0:	8526                	mv	a0,s1
  b2:	2f2000ef          	jal	ra,3a4 <close>
  for(i = 1; i < argc; i++){
  b6:	0921                	addi	s2,s2,8
  b8:	ff3912e3          	bne	s2,s3,9c <main+0x2a>
  }
  exit(0);
  bc:	4501                	li	a0,0
  be:	2be000ef          	jal	ra,37c <exit>
    cat(0);
  c2:	4501                	li	a0,0
  c4:	f3dff0ef          	jal	ra,0 <cat>
    exit(0);
  c8:	4501                	li	a0,0
  ca:	2b2000ef          	jal	ra,37c <exit>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
  ce:	00093603          	ld	a2,0(s2)
  d2:	00001597          	auipc	a1,0x1
  d6:	88e58593          	addi	a1,a1,-1906 # 960 <malloc+0x10e>
  da:	4509                	li	a0,2
  dc:	692000ef          	jal	ra,76e <fprintf>
      exit(1);
  e0:	4505                	li	a0,1
  e2:	29a000ef          	jal	ra,37c <exit>

00000000000000e6 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  e6:	1141                	addi	sp,sp,-16
  e8:	e406                	sd	ra,8(sp)
  ea:	e022                	sd	s0,0(sp)
  ec:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  ee:	f85ff0ef          	jal	ra,72 <main>
  exit(r);
  f2:	28a000ef          	jal	ra,37c <exit>

00000000000000f6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  f6:	1141                	addi	sp,sp,-16
  f8:	e422                	sd	s0,8(sp)
  fa:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  fc:	87aa                	mv	a5,a0
  fe:	0585                	addi	a1,a1,1
 100:	0785                	addi	a5,a5,1
 102:	fff5c703          	lbu	a4,-1(a1)
 106:	fee78fa3          	sb	a4,-1(a5)
 10a:	fb75                	bnez	a4,fe <strcpy+0x8>
    ;
  return os;
}
 10c:	6422                	ld	s0,8(sp)
 10e:	0141                	addi	sp,sp,16
 110:	8082                	ret

0000000000000112 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 112:	1141                	addi	sp,sp,-16
 114:	e422                	sd	s0,8(sp)
 116:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 118:	00054783          	lbu	a5,0(a0)
 11c:	cb91                	beqz	a5,130 <strcmp+0x1e>
 11e:	0005c703          	lbu	a4,0(a1)
 122:	00f71763          	bne	a4,a5,130 <strcmp+0x1e>
    p++, q++;
 126:	0505                	addi	a0,a0,1
 128:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 12a:	00054783          	lbu	a5,0(a0)
 12e:	fbe5                	bnez	a5,11e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 130:	0005c503          	lbu	a0,0(a1)
}
 134:	40a7853b          	subw	a0,a5,a0
 138:	6422                	ld	s0,8(sp)
 13a:	0141                	addi	sp,sp,16
 13c:	8082                	ret

000000000000013e <strlen>:

uint
strlen(const char *s)
{
 13e:	1141                	addi	sp,sp,-16
 140:	e422                	sd	s0,8(sp)
 142:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 144:	00054783          	lbu	a5,0(a0)
 148:	cf91                	beqz	a5,164 <strlen+0x26>
 14a:	0505                	addi	a0,a0,1
 14c:	87aa                	mv	a5,a0
 14e:	4685                	li	a3,1
 150:	9e89                	subw	a3,a3,a0
 152:	00f6853b          	addw	a0,a3,a5
 156:	0785                	addi	a5,a5,1
 158:	fff7c703          	lbu	a4,-1(a5)
 15c:	fb7d                	bnez	a4,152 <strlen+0x14>
    ;
  return n;
}
 15e:	6422                	ld	s0,8(sp)
 160:	0141                	addi	sp,sp,16
 162:	8082                	ret
  for(n = 0; s[n]; n++)
 164:	4501                	li	a0,0
 166:	bfe5                	j	15e <strlen+0x20>

0000000000000168 <memset>:

void*
memset(void *dst, int c, uint n)
{
 168:	1141                	addi	sp,sp,-16
 16a:	e422                	sd	s0,8(sp)
 16c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 16e:	ca19                	beqz	a2,184 <memset+0x1c>
 170:	87aa                	mv	a5,a0
 172:	1602                	slli	a2,a2,0x20
 174:	9201                	srli	a2,a2,0x20
 176:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 17a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 17e:	0785                	addi	a5,a5,1
 180:	fee79de3          	bne	a5,a4,17a <memset+0x12>
  }
  return dst;
}
 184:	6422                	ld	s0,8(sp)
 186:	0141                	addi	sp,sp,16
 188:	8082                	ret

000000000000018a <strchr>:

char*
strchr(const char *s, char c)
{
 18a:	1141                	addi	sp,sp,-16
 18c:	e422                	sd	s0,8(sp)
 18e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 190:	00054783          	lbu	a5,0(a0)
 194:	cb99                	beqz	a5,1aa <strchr+0x20>
    if(*s == c)
 196:	00f58763          	beq	a1,a5,1a4 <strchr+0x1a>
  for(; *s; s++)
 19a:	0505                	addi	a0,a0,1
 19c:	00054783          	lbu	a5,0(a0)
 1a0:	fbfd                	bnez	a5,196 <strchr+0xc>
      return (char*)s;
  return 0;
 1a2:	4501                	li	a0,0
}
 1a4:	6422                	ld	s0,8(sp)
 1a6:	0141                	addi	sp,sp,16
 1a8:	8082                	ret
  return 0;
 1aa:	4501                	li	a0,0
 1ac:	bfe5                	j	1a4 <strchr+0x1a>

00000000000001ae <gets>:

char*
gets(char *buf, int max)
{
 1ae:	711d                	addi	sp,sp,-96
 1b0:	ec86                	sd	ra,88(sp)
 1b2:	e8a2                	sd	s0,80(sp)
 1b4:	e4a6                	sd	s1,72(sp)
 1b6:	e0ca                	sd	s2,64(sp)
 1b8:	fc4e                	sd	s3,56(sp)
 1ba:	f852                	sd	s4,48(sp)
 1bc:	f456                	sd	s5,40(sp)
 1be:	f05a                	sd	s6,32(sp)
 1c0:	ec5e                	sd	s7,24(sp)
 1c2:	1080                	addi	s0,sp,96
 1c4:	8baa                	mv	s7,a0
 1c6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1c8:	892a                	mv	s2,a0
 1ca:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1cc:	4aa9                	li	s5,10
 1ce:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1d0:	89a6                	mv	s3,s1
 1d2:	2485                	addiw	s1,s1,1
 1d4:	0344d663          	bge	s1,s4,200 <gets+0x52>
    cc = read(0, &c, 1);
 1d8:	4605                	li	a2,1
 1da:	faf40593          	addi	a1,s0,-81
 1de:	4501                	li	a0,0
 1e0:	1b4000ef          	jal	ra,394 <read>
    if(cc < 1)
 1e4:	00a05e63          	blez	a0,200 <gets+0x52>
    buf[i++] = c;
 1e8:	faf44783          	lbu	a5,-81(s0)
 1ec:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1f0:	01578763          	beq	a5,s5,1fe <gets+0x50>
 1f4:	0905                	addi	s2,s2,1
 1f6:	fd679de3          	bne	a5,s6,1d0 <gets+0x22>
  for(i=0; i+1 < max; ){
 1fa:	89a6                	mv	s3,s1
 1fc:	a011                	j	200 <gets+0x52>
 1fe:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 200:	99de                	add	s3,s3,s7
 202:	00098023          	sb	zero,0(s3)
  return buf;
}
 206:	855e                	mv	a0,s7
 208:	60e6                	ld	ra,88(sp)
 20a:	6446                	ld	s0,80(sp)
 20c:	64a6                	ld	s1,72(sp)
 20e:	6906                	ld	s2,64(sp)
 210:	79e2                	ld	s3,56(sp)
 212:	7a42                	ld	s4,48(sp)
 214:	7aa2                	ld	s5,40(sp)
 216:	7b02                	ld	s6,32(sp)
 218:	6be2                	ld	s7,24(sp)
 21a:	6125                	addi	sp,sp,96
 21c:	8082                	ret

000000000000021e <stat>:

int
stat(const char *n, struct stat *st)
{
 21e:	1101                	addi	sp,sp,-32
 220:	ec06                	sd	ra,24(sp)
 222:	e822                	sd	s0,16(sp)
 224:	e426                	sd	s1,8(sp)
 226:	e04a                	sd	s2,0(sp)
 228:	1000                	addi	s0,sp,32
 22a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 22c:	4581                	li	a1,0
 22e:	18e000ef          	jal	ra,3bc <open>
  if(fd < 0)
 232:	02054163          	bltz	a0,254 <stat+0x36>
 236:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 238:	85ca                	mv	a1,s2
 23a:	19a000ef          	jal	ra,3d4 <fstat>
 23e:	892a                	mv	s2,a0
  close(fd);
 240:	8526                	mv	a0,s1
 242:	162000ef          	jal	ra,3a4 <close>
  return r;
}
 246:	854a                	mv	a0,s2
 248:	60e2                	ld	ra,24(sp)
 24a:	6442                	ld	s0,16(sp)
 24c:	64a2                	ld	s1,8(sp)
 24e:	6902                	ld	s2,0(sp)
 250:	6105                	addi	sp,sp,32
 252:	8082                	ret
    return -1;
 254:	597d                	li	s2,-1
 256:	bfc5                	j	246 <stat+0x28>

0000000000000258 <atoi>:

int
atoi(const char *s)
{
 258:	1141                	addi	sp,sp,-16
 25a:	e422                	sd	s0,8(sp)
 25c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 25e:	00054603          	lbu	a2,0(a0)
 262:	fd06079b          	addiw	a5,a2,-48
 266:	0ff7f793          	andi	a5,a5,255
 26a:	4725                	li	a4,9
 26c:	02f76963          	bltu	a4,a5,29e <atoi+0x46>
 270:	86aa                	mv	a3,a0
  n = 0;
 272:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 274:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 276:	0685                	addi	a3,a3,1
 278:	0025179b          	slliw	a5,a0,0x2
 27c:	9fa9                	addw	a5,a5,a0
 27e:	0017979b          	slliw	a5,a5,0x1
 282:	9fb1                	addw	a5,a5,a2
 284:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 288:	0006c603          	lbu	a2,0(a3)
 28c:	fd06071b          	addiw	a4,a2,-48
 290:	0ff77713          	andi	a4,a4,255
 294:	fee5f1e3          	bgeu	a1,a4,276 <atoi+0x1e>
  return n;
}
 298:	6422                	ld	s0,8(sp)
 29a:	0141                	addi	sp,sp,16
 29c:	8082                	ret
  n = 0;
 29e:	4501                	li	a0,0
 2a0:	bfe5                	j	298 <atoi+0x40>

00000000000002a2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2a2:	1141                	addi	sp,sp,-16
 2a4:	e422                	sd	s0,8(sp)
 2a6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2a8:	02b57463          	bgeu	a0,a1,2d0 <memmove+0x2e>
    while(n-- > 0)
 2ac:	00c05f63          	blez	a2,2ca <memmove+0x28>
 2b0:	1602                	slli	a2,a2,0x20
 2b2:	9201                	srli	a2,a2,0x20
 2b4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2b8:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ba:	0585                	addi	a1,a1,1
 2bc:	0705                	addi	a4,a4,1
 2be:	fff5c683          	lbu	a3,-1(a1)
 2c2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2c6:	fee79ae3          	bne	a5,a4,2ba <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2ca:	6422                	ld	s0,8(sp)
 2cc:	0141                	addi	sp,sp,16
 2ce:	8082                	ret
    dst += n;
 2d0:	00c50733          	add	a4,a0,a2
    src += n;
 2d4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2d6:	fec05ae3          	blez	a2,2ca <memmove+0x28>
 2da:	fff6079b          	addiw	a5,a2,-1
 2de:	1782                	slli	a5,a5,0x20
 2e0:	9381                	srli	a5,a5,0x20
 2e2:	fff7c793          	not	a5,a5
 2e6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2e8:	15fd                	addi	a1,a1,-1
 2ea:	177d                	addi	a4,a4,-1
 2ec:	0005c683          	lbu	a3,0(a1)
 2f0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2f4:	fee79ae3          	bne	a5,a4,2e8 <memmove+0x46>
 2f8:	bfc9                	j	2ca <memmove+0x28>

00000000000002fa <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2fa:	1141                	addi	sp,sp,-16
 2fc:	e422                	sd	s0,8(sp)
 2fe:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 300:	ca05                	beqz	a2,330 <memcmp+0x36>
 302:	fff6069b          	addiw	a3,a2,-1
 306:	1682                	slli	a3,a3,0x20
 308:	9281                	srli	a3,a3,0x20
 30a:	0685                	addi	a3,a3,1
 30c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 30e:	00054783          	lbu	a5,0(a0)
 312:	0005c703          	lbu	a4,0(a1)
 316:	00e79863          	bne	a5,a4,326 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 31a:	0505                	addi	a0,a0,1
    p2++;
 31c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 31e:	fed518e3          	bne	a0,a3,30e <memcmp+0x14>
  }
  return 0;
 322:	4501                	li	a0,0
 324:	a019                	j	32a <memcmp+0x30>
      return *p1 - *p2;
 326:	40e7853b          	subw	a0,a5,a4
}
 32a:	6422                	ld	s0,8(sp)
 32c:	0141                	addi	sp,sp,16
 32e:	8082                	ret
  return 0;
 330:	4501                	li	a0,0
 332:	bfe5                	j	32a <memcmp+0x30>

0000000000000334 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 334:	1141                	addi	sp,sp,-16
 336:	e406                	sd	ra,8(sp)
 338:	e022                	sd	s0,0(sp)
 33a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 33c:	f67ff0ef          	jal	ra,2a2 <memmove>
}
 340:	60a2                	ld	ra,8(sp)
 342:	6402                	ld	s0,0(sp)
 344:	0141                	addi	sp,sp,16
 346:	8082                	ret

0000000000000348 <sbrk>:

char *
sbrk(int n) {
 348:	1141                	addi	sp,sp,-16
 34a:	e406                	sd	ra,8(sp)
 34c:	e022                	sd	s0,0(sp)
 34e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 350:	4585                	li	a1,1
 352:	0b2000ef          	jal	ra,404 <sys_sbrk>
}
 356:	60a2                	ld	ra,8(sp)
 358:	6402                	ld	s0,0(sp)
 35a:	0141                	addi	sp,sp,16
 35c:	8082                	ret

000000000000035e <sbrklazy>:

char *
sbrklazy(int n) {
 35e:	1141                	addi	sp,sp,-16
 360:	e406                	sd	ra,8(sp)
 362:	e022                	sd	s0,0(sp)
 364:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 366:	4589                	li	a1,2
 368:	09c000ef          	jal	ra,404 <sys_sbrk>
}
 36c:	60a2                	ld	ra,8(sp)
 36e:	6402                	ld	s0,0(sp)
 370:	0141                	addi	sp,sp,16
 372:	8082                	ret

0000000000000374 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 374:	4885                	li	a7,1
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <exit>:
.global exit
exit:
 li a7, SYS_exit
 37c:	4889                	li	a7,2
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <wait>:
.global wait
wait:
 li a7, SYS_wait
 384:	488d                	li	a7,3
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 38c:	4891                	li	a7,4
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <read>:
.global read
read:
 li a7, SYS_read
 394:	4895                	li	a7,5
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <write>:
.global write
write:
 li a7, SYS_write
 39c:	48c1                	li	a7,16
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <close>:
.global close
close:
 li a7, SYS_close
 3a4:	48d5                	li	a7,21
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <kill>:
.global kill
kill:
 li a7, SYS_kill
 3ac:	4899                	li	a7,6
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3b4:	489d                	li	a7,7
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <open>:
.global open
open:
 li a7, SYS_open
 3bc:	48bd                	li	a7,15
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3c4:	48c5                	li	a7,17
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3cc:	48c9                	li	a7,18
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3d4:	48a1                	li	a7,8
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <link>:
.global link
link:
 li a7, SYS_link
 3dc:	48cd                	li	a7,19
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3e4:	48d1                	li	a7,20
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3ec:	48a5                	li	a7,9
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3f4:	48a9                	li	a7,10
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3fc:	48ad                	li	a7,11
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 404:	48b1                	li	a7,12
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <pause>:
.global pause
pause:
 li a7, SYS_pause
 40c:	48b5                	li	a7,13
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 414:	48b9                	li	a7,14
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 41c:	1101                	addi	sp,sp,-32
 41e:	ec06                	sd	ra,24(sp)
 420:	e822                	sd	s0,16(sp)
 422:	1000                	addi	s0,sp,32
 424:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 428:	4605                	li	a2,1
 42a:	fef40593          	addi	a1,s0,-17
 42e:	f6fff0ef          	jal	ra,39c <write>
}
 432:	60e2                	ld	ra,24(sp)
 434:	6442                	ld	s0,16(sp)
 436:	6105                	addi	sp,sp,32
 438:	8082                	ret

000000000000043a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 43a:	715d                	addi	sp,sp,-80
 43c:	e486                	sd	ra,72(sp)
 43e:	e0a2                	sd	s0,64(sp)
 440:	fc26                	sd	s1,56(sp)
 442:	f84a                	sd	s2,48(sp)
 444:	f44e                	sd	s3,40(sp)
 446:	0880                	addi	s0,sp,80
 448:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 44a:	c299                	beqz	a3,450 <printint+0x16>
 44c:	0805c163          	bltz	a1,4ce <printint+0x94>
  neg = 0;
 450:	4881                	li	a7,0
 452:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 456:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 458:	00000517          	auipc	a0,0x0
 45c:	52850513          	addi	a0,a0,1320 # 980 <digits>
 460:	883e                	mv	a6,a5
 462:	2785                	addiw	a5,a5,1
 464:	02c5f733          	remu	a4,a1,a2
 468:	972a                	add	a4,a4,a0
 46a:	00074703          	lbu	a4,0(a4)
 46e:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 472:	872e                	mv	a4,a1
 474:	02c5d5b3          	divu	a1,a1,a2
 478:	0685                	addi	a3,a3,1
 47a:	fec773e3          	bgeu	a4,a2,460 <printint+0x26>
  if(neg)
 47e:	00088b63          	beqz	a7,494 <printint+0x5a>
    buf[i++] = '-';
 482:	fd040713          	addi	a4,s0,-48
 486:	97ba                	add	a5,a5,a4
 488:	02d00713          	li	a4,45
 48c:	fee78423          	sb	a4,-24(a5)
 490:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 494:	02f05663          	blez	a5,4c0 <printint+0x86>
 498:	fb840713          	addi	a4,s0,-72
 49c:	00f704b3          	add	s1,a4,a5
 4a0:	fff70993          	addi	s3,a4,-1
 4a4:	99be                	add	s3,s3,a5
 4a6:	37fd                	addiw	a5,a5,-1
 4a8:	1782                	slli	a5,a5,0x20
 4aa:	9381                	srli	a5,a5,0x20
 4ac:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4b0:	fff4c583          	lbu	a1,-1(s1)
 4b4:	854a                	mv	a0,s2
 4b6:	f67ff0ef          	jal	ra,41c <putc>
  while(--i >= 0)
 4ba:	14fd                	addi	s1,s1,-1
 4bc:	ff349ae3          	bne	s1,s3,4b0 <printint+0x76>
}
 4c0:	60a6                	ld	ra,72(sp)
 4c2:	6406                	ld	s0,64(sp)
 4c4:	74e2                	ld	s1,56(sp)
 4c6:	7942                	ld	s2,48(sp)
 4c8:	79a2                	ld	s3,40(sp)
 4ca:	6161                	addi	sp,sp,80
 4cc:	8082                	ret
    x = -xx;
 4ce:	40b005b3          	neg	a1,a1
    neg = 1;
 4d2:	4885                	li	a7,1
    x = -xx;
 4d4:	bfbd                	j	452 <printint+0x18>

00000000000004d6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4d6:	7119                	addi	sp,sp,-128
 4d8:	fc86                	sd	ra,120(sp)
 4da:	f8a2                	sd	s0,112(sp)
 4dc:	f4a6                	sd	s1,104(sp)
 4de:	f0ca                	sd	s2,96(sp)
 4e0:	ecce                	sd	s3,88(sp)
 4e2:	e8d2                	sd	s4,80(sp)
 4e4:	e4d6                	sd	s5,72(sp)
 4e6:	e0da                	sd	s6,64(sp)
 4e8:	fc5e                	sd	s7,56(sp)
 4ea:	f862                	sd	s8,48(sp)
 4ec:	f466                	sd	s9,40(sp)
 4ee:	f06a                	sd	s10,32(sp)
 4f0:	ec6e                	sd	s11,24(sp)
 4f2:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4f4:	0005c903          	lbu	s2,0(a1)
 4f8:	24090c63          	beqz	s2,750 <vprintf+0x27a>
 4fc:	8b2a                	mv	s6,a0
 4fe:	8a2e                	mv	s4,a1
 500:	8bb2                	mv	s7,a2
  state = 0;
 502:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 504:	4481                	li	s1,0
 506:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 508:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 50c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 510:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 514:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 518:	00000c97          	auipc	s9,0x0
 51c:	468c8c93          	addi	s9,s9,1128 # 980 <digits>
 520:	a005                	j	540 <vprintf+0x6a>
        putc(fd, c0);
 522:	85ca                	mv	a1,s2
 524:	855a                	mv	a0,s6
 526:	ef7ff0ef          	jal	ra,41c <putc>
 52a:	a019                	j	530 <vprintf+0x5a>
    } else if(state == '%'){
 52c:	03598263          	beq	s3,s5,550 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 530:	2485                	addiw	s1,s1,1
 532:	8726                	mv	a4,s1
 534:	009a07b3          	add	a5,s4,s1
 538:	0007c903          	lbu	s2,0(a5)
 53c:	20090a63          	beqz	s2,750 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 540:	0009079b          	sext.w	a5,s2
    if(state == 0){
 544:	fe0994e3          	bnez	s3,52c <vprintf+0x56>
      if(c0 == '%'){
 548:	fd579de3          	bne	a5,s5,522 <vprintf+0x4c>
        state = '%';
 54c:	89be                	mv	s3,a5
 54e:	b7cd                	j	530 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 550:	c3c1                	beqz	a5,5d0 <vprintf+0xfa>
 552:	00ea06b3          	add	a3,s4,a4
 556:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 55a:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 55c:	c681                	beqz	a3,564 <vprintf+0x8e>
 55e:	9752                	add	a4,a4,s4
 560:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 564:	03878e63          	beq	a5,s8,5a0 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 568:	05a78863          	beq	a5,s10,5b8 <vprintf+0xe2>
      } else if(c0 == 'u'){
 56c:	0db78b63          	beq	a5,s11,642 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 570:	07800713          	li	a4,120
 574:	10e78d63          	beq	a5,a4,68e <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 578:	07000713          	li	a4,112
 57c:	14e78263          	beq	a5,a4,6c0 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 580:	06300713          	li	a4,99
 584:	16e78f63          	beq	a5,a4,702 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 588:	07300713          	li	a4,115
 58c:	18e78563          	beq	a5,a4,716 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 590:	05579063          	bne	a5,s5,5d0 <vprintf+0xfa>
        putc(fd, '%');
 594:	85d6                	mv	a1,s5
 596:	855a                	mv	a0,s6
 598:	e85ff0ef          	jal	ra,41c <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 59c:	4981                	li	s3,0
 59e:	bf49                	j	530 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 5a0:	008b8913          	addi	s2,s7,8
 5a4:	4685                	li	a3,1
 5a6:	4629                	li	a2,10
 5a8:	000ba583          	lw	a1,0(s7)
 5ac:	855a                	mv	a0,s6
 5ae:	e8dff0ef          	jal	ra,43a <printint>
 5b2:	8bca                	mv	s7,s2
      state = 0;
 5b4:	4981                	li	s3,0
 5b6:	bfad                	j	530 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5b8:	03868663          	beq	a3,s8,5e4 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5bc:	05a68163          	beq	a3,s10,5fe <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 5c0:	09b68d63          	beq	a3,s11,65a <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5c4:	03a68f63          	beq	a3,s10,602 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 5c8:	07800793          	li	a5,120
 5cc:	0cf68d63          	beq	a3,a5,6a6 <vprintf+0x1d0>
        putc(fd, '%');
 5d0:	85d6                	mv	a1,s5
 5d2:	855a                	mv	a0,s6
 5d4:	e49ff0ef          	jal	ra,41c <putc>
        putc(fd, c0);
 5d8:	85ca                	mv	a1,s2
 5da:	855a                	mv	a0,s6
 5dc:	e41ff0ef          	jal	ra,41c <putc>
      state = 0;
 5e0:	4981                	li	s3,0
 5e2:	b7b9                	j	530 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5e4:	008b8913          	addi	s2,s7,8
 5e8:	4685                	li	a3,1
 5ea:	4629                	li	a2,10
 5ec:	000bb583          	ld	a1,0(s7)
 5f0:	855a                	mv	a0,s6
 5f2:	e49ff0ef          	jal	ra,43a <printint>
        i += 1;
 5f6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5f8:	8bca                	mv	s7,s2
      state = 0;
 5fa:	4981                	li	s3,0
        i += 1;
 5fc:	bf15                	j	530 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5fe:	03860563          	beq	a2,s8,628 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 602:	07b60963          	beq	a2,s11,674 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 606:	07800793          	li	a5,120
 60a:	fcf613e3          	bne	a2,a5,5d0 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 60e:	008b8913          	addi	s2,s7,8
 612:	4681                	li	a3,0
 614:	4641                	li	a2,16
 616:	000bb583          	ld	a1,0(s7)
 61a:	855a                	mv	a0,s6
 61c:	e1fff0ef          	jal	ra,43a <printint>
        i += 2;
 620:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 622:	8bca                	mv	s7,s2
      state = 0;
 624:	4981                	li	s3,0
        i += 2;
 626:	b729                	j	530 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 628:	008b8913          	addi	s2,s7,8
 62c:	4685                	li	a3,1
 62e:	4629                	li	a2,10
 630:	000bb583          	ld	a1,0(s7)
 634:	855a                	mv	a0,s6
 636:	e05ff0ef          	jal	ra,43a <printint>
        i += 2;
 63a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 63c:	8bca                	mv	s7,s2
      state = 0;
 63e:	4981                	li	s3,0
        i += 2;
 640:	bdc5                	j	530 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 642:	008b8913          	addi	s2,s7,8
 646:	4681                	li	a3,0
 648:	4629                	li	a2,10
 64a:	000be583          	lwu	a1,0(s7)
 64e:	855a                	mv	a0,s6
 650:	debff0ef          	jal	ra,43a <printint>
 654:	8bca                	mv	s7,s2
      state = 0;
 656:	4981                	li	s3,0
 658:	bde1                	j	530 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 65a:	008b8913          	addi	s2,s7,8
 65e:	4681                	li	a3,0
 660:	4629                	li	a2,10
 662:	000bb583          	ld	a1,0(s7)
 666:	855a                	mv	a0,s6
 668:	dd3ff0ef          	jal	ra,43a <printint>
        i += 1;
 66c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 66e:	8bca                	mv	s7,s2
      state = 0;
 670:	4981                	li	s3,0
        i += 1;
 672:	bd7d                	j	530 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 674:	008b8913          	addi	s2,s7,8
 678:	4681                	li	a3,0
 67a:	4629                	li	a2,10
 67c:	000bb583          	ld	a1,0(s7)
 680:	855a                	mv	a0,s6
 682:	db9ff0ef          	jal	ra,43a <printint>
        i += 2;
 686:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 688:	8bca                	mv	s7,s2
      state = 0;
 68a:	4981                	li	s3,0
        i += 2;
 68c:	b555                	j	530 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 68e:	008b8913          	addi	s2,s7,8
 692:	4681                	li	a3,0
 694:	4641                	li	a2,16
 696:	000be583          	lwu	a1,0(s7)
 69a:	855a                	mv	a0,s6
 69c:	d9fff0ef          	jal	ra,43a <printint>
 6a0:	8bca                	mv	s7,s2
      state = 0;
 6a2:	4981                	li	s3,0
 6a4:	b571                	j	530 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a6:	008b8913          	addi	s2,s7,8
 6aa:	4681                	li	a3,0
 6ac:	4641                	li	a2,16
 6ae:	000bb583          	ld	a1,0(s7)
 6b2:	855a                	mv	a0,s6
 6b4:	d87ff0ef          	jal	ra,43a <printint>
        i += 1;
 6b8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ba:	8bca                	mv	s7,s2
      state = 0;
 6bc:	4981                	li	s3,0
        i += 1;
 6be:	bd8d                	j	530 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6c0:	008b8793          	addi	a5,s7,8
 6c4:	f8f43423          	sd	a5,-120(s0)
 6c8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6cc:	03000593          	li	a1,48
 6d0:	855a                	mv	a0,s6
 6d2:	d4bff0ef          	jal	ra,41c <putc>
  putc(fd, 'x');
 6d6:	07800593          	li	a1,120
 6da:	855a                	mv	a0,s6
 6dc:	d41ff0ef          	jal	ra,41c <putc>
 6e0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6e2:	03c9d793          	srli	a5,s3,0x3c
 6e6:	97e6                	add	a5,a5,s9
 6e8:	0007c583          	lbu	a1,0(a5)
 6ec:	855a                	mv	a0,s6
 6ee:	d2fff0ef          	jal	ra,41c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6f2:	0992                	slli	s3,s3,0x4
 6f4:	397d                	addiw	s2,s2,-1
 6f6:	fe0916e3          	bnez	s2,6e2 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 6fa:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 6fe:	4981                	li	s3,0
 700:	bd05                	j	530 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 702:	008b8913          	addi	s2,s7,8
 706:	000bc583          	lbu	a1,0(s7)
 70a:	855a                	mv	a0,s6
 70c:	d11ff0ef          	jal	ra,41c <putc>
 710:	8bca                	mv	s7,s2
      state = 0;
 712:	4981                	li	s3,0
 714:	bd31                	j	530 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 716:	008b8993          	addi	s3,s7,8
 71a:	000bb903          	ld	s2,0(s7)
 71e:	00090f63          	beqz	s2,73c <vprintf+0x266>
        for(; *s; s++)
 722:	00094583          	lbu	a1,0(s2)
 726:	c195                	beqz	a1,74a <vprintf+0x274>
          putc(fd, *s);
 728:	855a                	mv	a0,s6
 72a:	cf3ff0ef          	jal	ra,41c <putc>
        for(; *s; s++)
 72e:	0905                	addi	s2,s2,1
 730:	00094583          	lbu	a1,0(s2)
 734:	f9f5                	bnez	a1,728 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 736:	8bce                	mv	s7,s3
      state = 0;
 738:	4981                	li	s3,0
 73a:	bbdd                	j	530 <vprintf+0x5a>
          s = "(null)";
 73c:	00000917          	auipc	s2,0x0
 740:	23c90913          	addi	s2,s2,572 # 978 <malloc+0x126>
        for(; *s; s++)
 744:	02800593          	li	a1,40
 748:	b7c5                	j	728 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 74a:	8bce                	mv	s7,s3
      state = 0;
 74c:	4981                	li	s3,0
 74e:	b3cd                	j	530 <vprintf+0x5a>
    }
  }
}
 750:	70e6                	ld	ra,120(sp)
 752:	7446                	ld	s0,112(sp)
 754:	74a6                	ld	s1,104(sp)
 756:	7906                	ld	s2,96(sp)
 758:	69e6                	ld	s3,88(sp)
 75a:	6a46                	ld	s4,80(sp)
 75c:	6aa6                	ld	s5,72(sp)
 75e:	6b06                	ld	s6,64(sp)
 760:	7be2                	ld	s7,56(sp)
 762:	7c42                	ld	s8,48(sp)
 764:	7ca2                	ld	s9,40(sp)
 766:	7d02                	ld	s10,32(sp)
 768:	6de2                	ld	s11,24(sp)
 76a:	6109                	addi	sp,sp,128
 76c:	8082                	ret

000000000000076e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 76e:	715d                	addi	sp,sp,-80
 770:	ec06                	sd	ra,24(sp)
 772:	e822                	sd	s0,16(sp)
 774:	1000                	addi	s0,sp,32
 776:	e010                	sd	a2,0(s0)
 778:	e414                	sd	a3,8(s0)
 77a:	e818                	sd	a4,16(s0)
 77c:	ec1c                	sd	a5,24(s0)
 77e:	03043023          	sd	a6,32(s0)
 782:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 786:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 78a:	8622                	mv	a2,s0
 78c:	d4bff0ef          	jal	ra,4d6 <vprintf>
}
 790:	60e2                	ld	ra,24(sp)
 792:	6442                	ld	s0,16(sp)
 794:	6161                	addi	sp,sp,80
 796:	8082                	ret

0000000000000798 <printf>:

void
printf(const char *fmt, ...)
{
 798:	711d                	addi	sp,sp,-96
 79a:	ec06                	sd	ra,24(sp)
 79c:	e822                	sd	s0,16(sp)
 79e:	1000                	addi	s0,sp,32
 7a0:	e40c                	sd	a1,8(s0)
 7a2:	e810                	sd	a2,16(s0)
 7a4:	ec14                	sd	a3,24(s0)
 7a6:	f018                	sd	a4,32(s0)
 7a8:	f41c                	sd	a5,40(s0)
 7aa:	03043823          	sd	a6,48(s0)
 7ae:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7b2:	00840613          	addi	a2,s0,8
 7b6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7ba:	85aa                	mv	a1,a0
 7bc:	4505                	li	a0,1
 7be:	d19ff0ef          	jal	ra,4d6 <vprintf>
}
 7c2:	60e2                	ld	ra,24(sp)
 7c4:	6442                	ld	s0,16(sp)
 7c6:	6125                	addi	sp,sp,96
 7c8:	8082                	ret

00000000000007ca <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ca:	1141                	addi	sp,sp,-16
 7cc:	e422                	sd	s0,8(sp)
 7ce:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7d0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d4:	00001797          	auipc	a5,0x1
 7d8:	82c7b783          	ld	a5,-2004(a5) # 1000 <freep>
 7dc:	a805                	j	80c <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7de:	4618                	lw	a4,8(a2)
 7e0:	9db9                	addw	a1,a1,a4
 7e2:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7e6:	6398                	ld	a4,0(a5)
 7e8:	6318                	ld	a4,0(a4)
 7ea:	fee53823          	sd	a4,-16(a0)
 7ee:	a091                	j	832 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7f0:	ff852703          	lw	a4,-8(a0)
 7f4:	9e39                	addw	a2,a2,a4
 7f6:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7f8:	ff053703          	ld	a4,-16(a0)
 7fc:	e398                	sd	a4,0(a5)
 7fe:	a099                	j	844 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 800:	6398                	ld	a4,0(a5)
 802:	00e7e463          	bltu	a5,a4,80a <free+0x40>
 806:	00e6ea63          	bltu	a3,a4,81a <free+0x50>
{
 80a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 80c:	fed7fae3          	bgeu	a5,a3,800 <free+0x36>
 810:	6398                	ld	a4,0(a5)
 812:	00e6e463          	bltu	a3,a4,81a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 816:	fee7eae3          	bltu	a5,a4,80a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 81a:	ff852583          	lw	a1,-8(a0)
 81e:	6390                	ld	a2,0(a5)
 820:	02059713          	slli	a4,a1,0x20
 824:	9301                	srli	a4,a4,0x20
 826:	0712                	slli	a4,a4,0x4
 828:	9736                	add	a4,a4,a3
 82a:	fae60ae3          	beq	a2,a4,7de <free+0x14>
    bp->s.ptr = p->s.ptr;
 82e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 832:	4790                	lw	a2,8(a5)
 834:	02061713          	slli	a4,a2,0x20
 838:	9301                	srli	a4,a4,0x20
 83a:	0712                	slli	a4,a4,0x4
 83c:	973e                	add	a4,a4,a5
 83e:	fae689e3          	beq	a3,a4,7f0 <free+0x26>
  } else
    p->s.ptr = bp;
 842:	e394                	sd	a3,0(a5)
  freep = p;
 844:	00000717          	auipc	a4,0x0
 848:	7af73e23          	sd	a5,1980(a4) # 1000 <freep>
}
 84c:	6422                	ld	s0,8(sp)
 84e:	0141                	addi	sp,sp,16
 850:	8082                	ret

0000000000000852 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 852:	7139                	addi	sp,sp,-64
 854:	fc06                	sd	ra,56(sp)
 856:	f822                	sd	s0,48(sp)
 858:	f426                	sd	s1,40(sp)
 85a:	f04a                	sd	s2,32(sp)
 85c:	ec4e                	sd	s3,24(sp)
 85e:	e852                	sd	s4,16(sp)
 860:	e456                	sd	s5,8(sp)
 862:	e05a                	sd	s6,0(sp)
 864:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 866:	02051493          	slli	s1,a0,0x20
 86a:	9081                	srli	s1,s1,0x20
 86c:	04bd                	addi	s1,s1,15
 86e:	8091                	srli	s1,s1,0x4
 870:	0014899b          	addiw	s3,s1,1
 874:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 876:	00000517          	auipc	a0,0x0
 87a:	78a53503          	ld	a0,1930(a0) # 1000 <freep>
 87e:	c515                	beqz	a0,8aa <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 880:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 882:	4798                	lw	a4,8(a5)
 884:	02977f63          	bgeu	a4,s1,8c2 <malloc+0x70>
 888:	8a4e                	mv	s4,s3
 88a:	0009871b          	sext.w	a4,s3
 88e:	6685                	lui	a3,0x1
 890:	00d77363          	bgeu	a4,a3,896 <malloc+0x44>
 894:	6a05                	lui	s4,0x1
 896:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 89a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 89e:	00000917          	auipc	s2,0x0
 8a2:	76290913          	addi	s2,s2,1890 # 1000 <freep>
  if(p == SBRK_ERROR)
 8a6:	5afd                	li	s5,-1
 8a8:	a0bd                	j	916 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 8aa:	00001797          	auipc	a5,0x1
 8ae:	96678793          	addi	a5,a5,-1690 # 1210 <base>
 8b2:	00000717          	auipc	a4,0x0
 8b6:	74f73723          	sd	a5,1870(a4) # 1000 <freep>
 8ba:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8bc:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8c0:	b7e1                	j	888 <malloc+0x36>
      if(p->s.size == nunits)
 8c2:	02e48b63          	beq	s1,a4,8f8 <malloc+0xa6>
        p->s.size -= nunits;
 8c6:	4137073b          	subw	a4,a4,s3
 8ca:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8cc:	1702                	slli	a4,a4,0x20
 8ce:	9301                	srli	a4,a4,0x20
 8d0:	0712                	slli	a4,a4,0x4
 8d2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8d4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8d8:	00000717          	auipc	a4,0x0
 8dc:	72a73423          	sd	a0,1832(a4) # 1000 <freep>
      return (void*)(p + 1);
 8e0:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8e4:	70e2                	ld	ra,56(sp)
 8e6:	7442                	ld	s0,48(sp)
 8e8:	74a2                	ld	s1,40(sp)
 8ea:	7902                	ld	s2,32(sp)
 8ec:	69e2                	ld	s3,24(sp)
 8ee:	6a42                	ld	s4,16(sp)
 8f0:	6aa2                	ld	s5,8(sp)
 8f2:	6b02                	ld	s6,0(sp)
 8f4:	6121                	addi	sp,sp,64
 8f6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8f8:	6398                	ld	a4,0(a5)
 8fa:	e118                	sd	a4,0(a0)
 8fc:	bff1                	j	8d8 <malloc+0x86>
  hp->s.size = nu;
 8fe:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 902:	0541                	addi	a0,a0,16
 904:	ec7ff0ef          	jal	ra,7ca <free>
  return freep;
 908:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 90c:	dd61                	beqz	a0,8e4 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 90e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 910:	4798                	lw	a4,8(a5)
 912:	fa9778e3          	bgeu	a4,s1,8c2 <malloc+0x70>
    if(p == freep)
 916:	00093703          	ld	a4,0(s2)
 91a:	853e                	mv	a0,a5
 91c:	fef719e3          	bne	a4,a5,90e <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 920:	8552                	mv	a0,s4
 922:	a27ff0ef          	jal	ra,348 <sbrk>
  if(p == SBRK_ERROR)
 926:	fd551ce3          	bne	a0,s5,8fe <malloc+0xac>
        return 0;
 92a:	4501                	li	a0,0
 92c:	bf65                	j	8e4 <malloc+0x92>
