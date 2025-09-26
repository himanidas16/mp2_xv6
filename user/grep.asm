
user/_grep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <matchstar>:
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	892a                	mv	s2,a0
  12:	89ae                	mv	s3,a1
  14:	84b2                	mv	s1,a2
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  16:	02e00a13          	li	s4,46
    if(matchhere(re, text))
  1a:	85a6                	mv	a1,s1
  1c:	854e                	mv	a0,s3
  1e:	02c000ef          	jal	ra,4a <matchhere>
  22:	e919                	bnez	a0,38 <matchstar+0x38>
  }while(*text!='\0' && (*text++==c || c=='.'));
  24:	0004c783          	lbu	a5,0(s1)
  28:	cb89                	beqz	a5,3a <matchstar+0x3a>
  2a:	0485                	addi	s1,s1,1
  2c:	2781                	sext.w	a5,a5
  2e:	ff2786e3          	beq	a5,s2,1a <matchstar+0x1a>
  32:	ff4904e3          	beq	s2,s4,1a <matchstar+0x1a>
  36:	a011                	j	3a <matchstar+0x3a>
      return 1;
  38:	4505                	li	a0,1
  return 0;
}
  3a:	70a2                	ld	ra,40(sp)
  3c:	7402                	ld	s0,32(sp)
  3e:	64e2                	ld	s1,24(sp)
  40:	6942                	ld	s2,16(sp)
  42:	69a2                	ld	s3,8(sp)
  44:	6a02                	ld	s4,0(sp)
  46:	6145                	addi	sp,sp,48
  48:	8082                	ret

000000000000004a <matchhere>:
  if(re[0] == '\0')
  4a:	00054703          	lbu	a4,0(a0)
  4e:	c73d                	beqz	a4,bc <matchhere+0x72>
{
  50:	1141                	addi	sp,sp,-16
  52:	e406                	sd	ra,8(sp)
  54:	e022                	sd	s0,0(sp)
  56:	0800                	addi	s0,sp,16
  58:	87aa                	mv	a5,a0
  if(re[1] == '*')
  5a:	00154683          	lbu	a3,1(a0)
  5e:	02a00613          	li	a2,42
  62:	02c68563          	beq	a3,a2,8c <matchhere+0x42>
  if(re[0] == '$' && re[1] == '\0')
  66:	02400613          	li	a2,36
  6a:	02c70863          	beq	a4,a2,9a <matchhere+0x50>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  6e:	0005c683          	lbu	a3,0(a1)
  return 0;
  72:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  74:	ca81                	beqz	a3,84 <matchhere+0x3a>
  76:	02e00613          	li	a2,46
  7a:	02c70b63          	beq	a4,a2,b0 <matchhere+0x66>
  return 0;
  7e:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  80:	02d70863          	beq	a4,a3,b0 <matchhere+0x66>
}
  84:	60a2                	ld	ra,8(sp)
  86:	6402                	ld	s0,0(sp)
  88:	0141                	addi	sp,sp,16
  8a:	8082                	ret
    return matchstar(re[0], re+2, text);
  8c:	862e                	mv	a2,a1
  8e:	00250593          	addi	a1,a0,2
  92:	853a                	mv	a0,a4
  94:	f6dff0ef          	jal	ra,0 <matchstar>
  98:	b7f5                	j	84 <matchhere+0x3a>
  if(re[0] == '$' && re[1] == '\0')
  9a:	c691                	beqz	a3,a6 <matchhere+0x5c>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  9c:	0005c683          	lbu	a3,0(a1)
  a0:	fef9                	bnez	a3,7e <matchhere+0x34>
  return 0;
  a2:	4501                	li	a0,0
  a4:	b7c5                	j	84 <matchhere+0x3a>
    return *text == '\0';
  a6:	0005c503          	lbu	a0,0(a1)
  aa:	00153513          	seqz	a0,a0
  ae:	bfd9                	j	84 <matchhere+0x3a>
    return matchhere(re+1, text+1);
  b0:	0585                	addi	a1,a1,1
  b2:	00178513          	addi	a0,a5,1
  b6:	f95ff0ef          	jal	ra,4a <matchhere>
  ba:	b7e9                	j	84 <matchhere+0x3a>
    return 1;
  bc:	4505                	li	a0,1
}
  be:	8082                	ret

00000000000000c0 <match>:
{
  c0:	1101                	addi	sp,sp,-32
  c2:	ec06                	sd	ra,24(sp)
  c4:	e822                	sd	s0,16(sp)
  c6:	e426                	sd	s1,8(sp)
  c8:	e04a                	sd	s2,0(sp)
  ca:	1000                	addi	s0,sp,32
  cc:	892a                	mv	s2,a0
  ce:	84ae                	mv	s1,a1
  if(re[0] == '^')
  d0:	00054703          	lbu	a4,0(a0)
  d4:	05e00793          	li	a5,94
  d8:	00f70c63          	beq	a4,a5,f0 <match+0x30>
    if(matchhere(re, text))
  dc:	85a6                	mv	a1,s1
  de:	854a                	mv	a0,s2
  e0:	f6bff0ef          	jal	ra,4a <matchhere>
  e4:	e911                	bnez	a0,f8 <match+0x38>
  }while(*text++ != '\0');
  e6:	0485                	addi	s1,s1,1
  e8:	fff4c783          	lbu	a5,-1(s1)
  ec:	fbe5                	bnez	a5,dc <match+0x1c>
  ee:	a031                	j	fa <match+0x3a>
    return matchhere(re+1, text);
  f0:	0505                	addi	a0,a0,1
  f2:	f59ff0ef          	jal	ra,4a <matchhere>
  f6:	a011                	j	fa <match+0x3a>
      return 1;
  f8:	4505                	li	a0,1
}
  fa:	60e2                	ld	ra,24(sp)
  fc:	6442                	ld	s0,16(sp)
  fe:	64a2                	ld	s1,8(sp)
 100:	6902                	ld	s2,0(sp)
 102:	6105                	addi	sp,sp,32
 104:	8082                	ret

0000000000000106 <grep>:
{
 106:	715d                	addi	sp,sp,-80
 108:	e486                	sd	ra,72(sp)
 10a:	e0a2                	sd	s0,64(sp)
 10c:	fc26                	sd	s1,56(sp)
 10e:	f84a                	sd	s2,48(sp)
 110:	f44e                	sd	s3,40(sp)
 112:	f052                	sd	s4,32(sp)
 114:	ec56                	sd	s5,24(sp)
 116:	e85a                	sd	s6,16(sp)
 118:	e45e                	sd	s7,8(sp)
 11a:	0880                	addi	s0,sp,80
 11c:	89aa                	mv	s3,a0
 11e:	8b2e                	mv	s6,a1
  m = 0;
 120:	4a01                	li	s4,0
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 122:	3ff00b93          	li	s7,1023
 126:	00001a97          	auipc	s5,0x1
 12a:	eeaa8a93          	addi	s5,s5,-278 # 1010 <buf>
 12e:	a835                	j	16a <grep+0x64>
      p = q+1;
 130:	00148913          	addi	s2,s1,1
    while((q = strchr(p, '\n')) != 0){
 134:	45a9                	li	a1,10
 136:	854a                	mv	a0,s2
 138:	1ba000ef          	jal	ra,2f2 <strchr>
 13c:	84aa                	mv	s1,a0
 13e:	c505                	beqz	a0,166 <grep+0x60>
      *q = 0;
 140:	00048023          	sb	zero,0(s1)
      if(match(pattern, p)){
 144:	85ca                	mv	a1,s2
 146:	854e                	mv	a0,s3
 148:	f79ff0ef          	jal	ra,c0 <match>
 14c:	d175                	beqz	a0,130 <grep+0x2a>
        *q = '\n';
 14e:	47a9                	li	a5,10
 150:	00f48023          	sb	a5,0(s1)
        write(1, p, q+1 - p);
 154:	00148613          	addi	a2,s1,1
 158:	4126063b          	subw	a2,a2,s2
 15c:	85ca                	mv	a1,s2
 15e:	4505                	li	a0,1
 160:	3a4000ef          	jal	ra,504 <write>
 164:	b7f1                	j	130 <grep+0x2a>
    if(m > 0){
 166:	03404363          	bgtz	s4,18c <grep+0x86>
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 16a:	414b863b          	subw	a2,s7,s4
 16e:	014a85b3          	add	a1,s5,s4
 172:	855a                	mv	a0,s6
 174:	388000ef          	jal	ra,4fc <read>
 178:	02a05463          	blez	a0,1a0 <grep+0x9a>
    m += n;
 17c:	00aa0a3b          	addw	s4,s4,a0
    buf[m] = '\0';
 180:	014a87b3          	add	a5,s5,s4
 184:	00078023          	sb	zero,0(a5)
    p = buf;
 188:	8956                	mv	s2,s5
    while((q = strchr(p, '\n')) != 0){
 18a:	b76d                	j	134 <grep+0x2e>
      m -= p - buf;
 18c:	415907b3          	sub	a5,s2,s5
 190:	40fa0a3b          	subw	s4,s4,a5
      memmove(buf, p, m);
 194:	8652                	mv	a2,s4
 196:	85ca                	mv	a1,s2
 198:	8556                	mv	a0,s5
 19a:	270000ef          	jal	ra,40a <memmove>
 19e:	b7f1                	j	16a <grep+0x64>
}
 1a0:	60a6                	ld	ra,72(sp)
 1a2:	6406                	ld	s0,64(sp)
 1a4:	74e2                	ld	s1,56(sp)
 1a6:	7942                	ld	s2,48(sp)
 1a8:	79a2                	ld	s3,40(sp)
 1aa:	7a02                	ld	s4,32(sp)
 1ac:	6ae2                	ld	s5,24(sp)
 1ae:	6b42                	ld	s6,16(sp)
 1b0:	6ba2                	ld	s7,8(sp)
 1b2:	6161                	addi	sp,sp,80
 1b4:	8082                	ret

00000000000001b6 <main>:
{
 1b6:	7139                	addi	sp,sp,-64
 1b8:	fc06                	sd	ra,56(sp)
 1ba:	f822                	sd	s0,48(sp)
 1bc:	f426                	sd	s1,40(sp)
 1be:	f04a                	sd	s2,32(sp)
 1c0:	ec4e                	sd	s3,24(sp)
 1c2:	e852                	sd	s4,16(sp)
 1c4:	e456                	sd	s5,8(sp)
 1c6:	0080                	addi	s0,sp,64
  if(argc <= 1){
 1c8:	4785                	li	a5,1
 1ca:	04a7d663          	bge	a5,a0,216 <main+0x60>
  pattern = argv[1];
 1ce:	0085ba03          	ld	s4,8(a1)
  if(argc <= 2){
 1d2:	4789                	li	a5,2
 1d4:	04a7db63          	bge	a5,a0,22a <main+0x74>
 1d8:	01058913          	addi	s2,a1,16
 1dc:	ffd5099b          	addiw	s3,a0,-3
 1e0:	1982                	slli	s3,s3,0x20
 1e2:	0209d993          	srli	s3,s3,0x20
 1e6:	098e                	slli	s3,s3,0x3
 1e8:	05e1                	addi	a1,a1,24
 1ea:	99ae                	add	s3,s3,a1
    if((fd = open(argv[i], O_RDONLY)) < 0){
 1ec:	4581                	li	a1,0
 1ee:	00093503          	ld	a0,0(s2)
 1f2:	332000ef          	jal	ra,524 <open>
 1f6:	84aa                	mv	s1,a0
 1f8:	04054063          	bltz	a0,238 <main+0x82>
    grep(pattern, fd);
 1fc:	85aa                	mv	a1,a0
 1fe:	8552                	mv	a0,s4
 200:	f07ff0ef          	jal	ra,106 <grep>
    close(fd);
 204:	8526                	mv	a0,s1
 206:	306000ef          	jal	ra,50c <close>
  for(i = 2; i < argc; i++){
 20a:	0921                	addi	s2,s2,8
 20c:	ff3910e3          	bne	s2,s3,1ec <main+0x36>
  exit(0);
 210:	4501                	li	a0,0
 212:	2d2000ef          	jal	ra,4e4 <exit>
    fprintf(2, "usage: grep pattern [file ...]\n");
 216:	00001597          	auipc	a1,0x1
 21a:	88a58593          	addi	a1,a1,-1910 # aa0 <malloc+0xe6>
 21e:	4509                	li	a0,2
 220:	6b6000ef          	jal	ra,8d6 <fprintf>
    exit(1);
 224:	4505                	li	a0,1
 226:	2be000ef          	jal	ra,4e4 <exit>
    grep(pattern, 0);
 22a:	4581                	li	a1,0
 22c:	8552                	mv	a0,s4
 22e:	ed9ff0ef          	jal	ra,106 <grep>
    exit(0);
 232:	4501                	li	a0,0
 234:	2b0000ef          	jal	ra,4e4 <exit>
      printf("grep: cannot open %s\n", argv[i]);
 238:	00093583          	ld	a1,0(s2)
 23c:	00001517          	auipc	a0,0x1
 240:	88450513          	addi	a0,a0,-1916 # ac0 <malloc+0x106>
 244:	6bc000ef          	jal	ra,900 <printf>
      exit(1);
 248:	4505                	li	a0,1
 24a:	29a000ef          	jal	ra,4e4 <exit>

000000000000024e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 24e:	1141                	addi	sp,sp,-16
 250:	e406                	sd	ra,8(sp)
 252:	e022                	sd	s0,0(sp)
 254:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 256:	f61ff0ef          	jal	ra,1b6 <main>
  exit(r);
 25a:	28a000ef          	jal	ra,4e4 <exit>

000000000000025e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 25e:	1141                	addi	sp,sp,-16
 260:	e422                	sd	s0,8(sp)
 262:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 264:	87aa                	mv	a5,a0
 266:	0585                	addi	a1,a1,1
 268:	0785                	addi	a5,a5,1
 26a:	fff5c703          	lbu	a4,-1(a1)
 26e:	fee78fa3          	sb	a4,-1(a5)
 272:	fb75                	bnez	a4,266 <strcpy+0x8>
    ;
  return os;
}
 274:	6422                	ld	s0,8(sp)
 276:	0141                	addi	sp,sp,16
 278:	8082                	ret

000000000000027a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 27a:	1141                	addi	sp,sp,-16
 27c:	e422                	sd	s0,8(sp)
 27e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 280:	00054783          	lbu	a5,0(a0)
 284:	cb91                	beqz	a5,298 <strcmp+0x1e>
 286:	0005c703          	lbu	a4,0(a1)
 28a:	00f71763          	bne	a4,a5,298 <strcmp+0x1e>
    p++, q++;
 28e:	0505                	addi	a0,a0,1
 290:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 292:	00054783          	lbu	a5,0(a0)
 296:	fbe5                	bnez	a5,286 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 298:	0005c503          	lbu	a0,0(a1)
}
 29c:	40a7853b          	subw	a0,a5,a0
 2a0:	6422                	ld	s0,8(sp)
 2a2:	0141                	addi	sp,sp,16
 2a4:	8082                	ret

00000000000002a6 <strlen>:

uint
strlen(const char *s)
{
 2a6:	1141                	addi	sp,sp,-16
 2a8:	e422                	sd	s0,8(sp)
 2aa:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2ac:	00054783          	lbu	a5,0(a0)
 2b0:	cf91                	beqz	a5,2cc <strlen+0x26>
 2b2:	0505                	addi	a0,a0,1
 2b4:	87aa                	mv	a5,a0
 2b6:	4685                	li	a3,1
 2b8:	9e89                	subw	a3,a3,a0
 2ba:	00f6853b          	addw	a0,a3,a5
 2be:	0785                	addi	a5,a5,1
 2c0:	fff7c703          	lbu	a4,-1(a5)
 2c4:	fb7d                	bnez	a4,2ba <strlen+0x14>
    ;
  return n;
}
 2c6:	6422                	ld	s0,8(sp)
 2c8:	0141                	addi	sp,sp,16
 2ca:	8082                	ret
  for(n = 0; s[n]; n++)
 2cc:	4501                	li	a0,0
 2ce:	bfe5                	j	2c6 <strlen+0x20>

00000000000002d0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2d0:	1141                	addi	sp,sp,-16
 2d2:	e422                	sd	s0,8(sp)
 2d4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2d6:	ca19                	beqz	a2,2ec <memset+0x1c>
 2d8:	87aa                	mv	a5,a0
 2da:	1602                	slli	a2,a2,0x20
 2dc:	9201                	srli	a2,a2,0x20
 2de:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2e2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2e6:	0785                	addi	a5,a5,1
 2e8:	fee79de3          	bne	a5,a4,2e2 <memset+0x12>
  }
  return dst;
}
 2ec:	6422                	ld	s0,8(sp)
 2ee:	0141                	addi	sp,sp,16
 2f0:	8082                	ret

00000000000002f2 <strchr>:

char*
strchr(const char *s, char c)
{
 2f2:	1141                	addi	sp,sp,-16
 2f4:	e422                	sd	s0,8(sp)
 2f6:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2f8:	00054783          	lbu	a5,0(a0)
 2fc:	cb99                	beqz	a5,312 <strchr+0x20>
    if(*s == c)
 2fe:	00f58763          	beq	a1,a5,30c <strchr+0x1a>
  for(; *s; s++)
 302:	0505                	addi	a0,a0,1
 304:	00054783          	lbu	a5,0(a0)
 308:	fbfd                	bnez	a5,2fe <strchr+0xc>
      return (char*)s;
  return 0;
 30a:	4501                	li	a0,0
}
 30c:	6422                	ld	s0,8(sp)
 30e:	0141                	addi	sp,sp,16
 310:	8082                	ret
  return 0;
 312:	4501                	li	a0,0
 314:	bfe5                	j	30c <strchr+0x1a>

0000000000000316 <gets>:

char*
gets(char *buf, int max)
{
 316:	711d                	addi	sp,sp,-96
 318:	ec86                	sd	ra,88(sp)
 31a:	e8a2                	sd	s0,80(sp)
 31c:	e4a6                	sd	s1,72(sp)
 31e:	e0ca                	sd	s2,64(sp)
 320:	fc4e                	sd	s3,56(sp)
 322:	f852                	sd	s4,48(sp)
 324:	f456                	sd	s5,40(sp)
 326:	f05a                	sd	s6,32(sp)
 328:	ec5e                	sd	s7,24(sp)
 32a:	1080                	addi	s0,sp,96
 32c:	8baa                	mv	s7,a0
 32e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 330:	892a                	mv	s2,a0
 332:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 334:	4aa9                	li	s5,10
 336:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 338:	89a6                	mv	s3,s1
 33a:	2485                	addiw	s1,s1,1
 33c:	0344d663          	bge	s1,s4,368 <gets+0x52>
    cc = read(0, &c, 1);
 340:	4605                	li	a2,1
 342:	faf40593          	addi	a1,s0,-81
 346:	4501                	li	a0,0
 348:	1b4000ef          	jal	ra,4fc <read>
    if(cc < 1)
 34c:	00a05e63          	blez	a0,368 <gets+0x52>
    buf[i++] = c;
 350:	faf44783          	lbu	a5,-81(s0)
 354:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 358:	01578763          	beq	a5,s5,366 <gets+0x50>
 35c:	0905                	addi	s2,s2,1
 35e:	fd679de3          	bne	a5,s6,338 <gets+0x22>
  for(i=0; i+1 < max; ){
 362:	89a6                	mv	s3,s1
 364:	a011                	j	368 <gets+0x52>
 366:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 368:	99de                	add	s3,s3,s7
 36a:	00098023          	sb	zero,0(s3)
  return buf;
}
 36e:	855e                	mv	a0,s7
 370:	60e6                	ld	ra,88(sp)
 372:	6446                	ld	s0,80(sp)
 374:	64a6                	ld	s1,72(sp)
 376:	6906                	ld	s2,64(sp)
 378:	79e2                	ld	s3,56(sp)
 37a:	7a42                	ld	s4,48(sp)
 37c:	7aa2                	ld	s5,40(sp)
 37e:	7b02                	ld	s6,32(sp)
 380:	6be2                	ld	s7,24(sp)
 382:	6125                	addi	sp,sp,96
 384:	8082                	ret

0000000000000386 <stat>:

int
stat(const char *n, struct stat *st)
{
 386:	1101                	addi	sp,sp,-32
 388:	ec06                	sd	ra,24(sp)
 38a:	e822                	sd	s0,16(sp)
 38c:	e426                	sd	s1,8(sp)
 38e:	e04a                	sd	s2,0(sp)
 390:	1000                	addi	s0,sp,32
 392:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 394:	4581                	li	a1,0
 396:	18e000ef          	jal	ra,524 <open>
  if(fd < 0)
 39a:	02054163          	bltz	a0,3bc <stat+0x36>
 39e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3a0:	85ca                	mv	a1,s2
 3a2:	19a000ef          	jal	ra,53c <fstat>
 3a6:	892a                	mv	s2,a0
  close(fd);
 3a8:	8526                	mv	a0,s1
 3aa:	162000ef          	jal	ra,50c <close>
  return r;
}
 3ae:	854a                	mv	a0,s2
 3b0:	60e2                	ld	ra,24(sp)
 3b2:	6442                	ld	s0,16(sp)
 3b4:	64a2                	ld	s1,8(sp)
 3b6:	6902                	ld	s2,0(sp)
 3b8:	6105                	addi	sp,sp,32
 3ba:	8082                	ret
    return -1;
 3bc:	597d                	li	s2,-1
 3be:	bfc5                	j	3ae <stat+0x28>

00000000000003c0 <atoi>:

int
atoi(const char *s)
{
 3c0:	1141                	addi	sp,sp,-16
 3c2:	e422                	sd	s0,8(sp)
 3c4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3c6:	00054603          	lbu	a2,0(a0)
 3ca:	fd06079b          	addiw	a5,a2,-48
 3ce:	0ff7f793          	andi	a5,a5,255
 3d2:	4725                	li	a4,9
 3d4:	02f76963          	bltu	a4,a5,406 <atoi+0x46>
 3d8:	86aa                	mv	a3,a0
  n = 0;
 3da:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 3dc:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 3de:	0685                	addi	a3,a3,1
 3e0:	0025179b          	slliw	a5,a0,0x2
 3e4:	9fa9                	addw	a5,a5,a0
 3e6:	0017979b          	slliw	a5,a5,0x1
 3ea:	9fb1                	addw	a5,a5,a2
 3ec:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3f0:	0006c603          	lbu	a2,0(a3)
 3f4:	fd06071b          	addiw	a4,a2,-48
 3f8:	0ff77713          	andi	a4,a4,255
 3fc:	fee5f1e3          	bgeu	a1,a4,3de <atoi+0x1e>
  return n;
}
 400:	6422                	ld	s0,8(sp)
 402:	0141                	addi	sp,sp,16
 404:	8082                	ret
  n = 0;
 406:	4501                	li	a0,0
 408:	bfe5                	j	400 <atoi+0x40>

000000000000040a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 40a:	1141                	addi	sp,sp,-16
 40c:	e422                	sd	s0,8(sp)
 40e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 410:	02b57463          	bgeu	a0,a1,438 <memmove+0x2e>
    while(n-- > 0)
 414:	00c05f63          	blez	a2,432 <memmove+0x28>
 418:	1602                	slli	a2,a2,0x20
 41a:	9201                	srli	a2,a2,0x20
 41c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 420:	872a                	mv	a4,a0
      *dst++ = *src++;
 422:	0585                	addi	a1,a1,1
 424:	0705                	addi	a4,a4,1
 426:	fff5c683          	lbu	a3,-1(a1)
 42a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 42e:	fee79ae3          	bne	a5,a4,422 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 432:	6422                	ld	s0,8(sp)
 434:	0141                	addi	sp,sp,16
 436:	8082                	ret
    dst += n;
 438:	00c50733          	add	a4,a0,a2
    src += n;
 43c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 43e:	fec05ae3          	blez	a2,432 <memmove+0x28>
 442:	fff6079b          	addiw	a5,a2,-1
 446:	1782                	slli	a5,a5,0x20
 448:	9381                	srli	a5,a5,0x20
 44a:	fff7c793          	not	a5,a5
 44e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 450:	15fd                	addi	a1,a1,-1
 452:	177d                	addi	a4,a4,-1
 454:	0005c683          	lbu	a3,0(a1)
 458:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 45c:	fee79ae3          	bne	a5,a4,450 <memmove+0x46>
 460:	bfc9                	j	432 <memmove+0x28>

0000000000000462 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 462:	1141                	addi	sp,sp,-16
 464:	e422                	sd	s0,8(sp)
 466:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 468:	ca05                	beqz	a2,498 <memcmp+0x36>
 46a:	fff6069b          	addiw	a3,a2,-1
 46e:	1682                	slli	a3,a3,0x20
 470:	9281                	srli	a3,a3,0x20
 472:	0685                	addi	a3,a3,1
 474:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 476:	00054783          	lbu	a5,0(a0)
 47a:	0005c703          	lbu	a4,0(a1)
 47e:	00e79863          	bne	a5,a4,48e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 482:	0505                	addi	a0,a0,1
    p2++;
 484:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 486:	fed518e3          	bne	a0,a3,476 <memcmp+0x14>
  }
  return 0;
 48a:	4501                	li	a0,0
 48c:	a019                	j	492 <memcmp+0x30>
      return *p1 - *p2;
 48e:	40e7853b          	subw	a0,a5,a4
}
 492:	6422                	ld	s0,8(sp)
 494:	0141                	addi	sp,sp,16
 496:	8082                	ret
  return 0;
 498:	4501                	li	a0,0
 49a:	bfe5                	j	492 <memcmp+0x30>

000000000000049c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 49c:	1141                	addi	sp,sp,-16
 49e:	e406                	sd	ra,8(sp)
 4a0:	e022                	sd	s0,0(sp)
 4a2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4a4:	f67ff0ef          	jal	ra,40a <memmove>
}
 4a8:	60a2                	ld	ra,8(sp)
 4aa:	6402                	ld	s0,0(sp)
 4ac:	0141                	addi	sp,sp,16
 4ae:	8082                	ret

00000000000004b0 <sbrk>:

char *
sbrk(int n) {
 4b0:	1141                	addi	sp,sp,-16
 4b2:	e406                	sd	ra,8(sp)
 4b4:	e022                	sd	s0,0(sp)
 4b6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4b8:	4585                	li	a1,1
 4ba:	0b2000ef          	jal	ra,56c <sys_sbrk>
}
 4be:	60a2                	ld	ra,8(sp)
 4c0:	6402                	ld	s0,0(sp)
 4c2:	0141                	addi	sp,sp,16
 4c4:	8082                	ret

00000000000004c6 <sbrklazy>:

char *
sbrklazy(int n) {
 4c6:	1141                	addi	sp,sp,-16
 4c8:	e406                	sd	ra,8(sp)
 4ca:	e022                	sd	s0,0(sp)
 4cc:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4ce:	4589                	li	a1,2
 4d0:	09c000ef          	jal	ra,56c <sys_sbrk>
}
 4d4:	60a2                	ld	ra,8(sp)
 4d6:	6402                	ld	s0,0(sp)
 4d8:	0141                	addi	sp,sp,16
 4da:	8082                	ret

00000000000004dc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4dc:	4885                	li	a7,1
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4e4:	4889                	li	a7,2
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <wait>:
.global wait
wait:
 li a7, SYS_wait
 4ec:	488d                	li	a7,3
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4f4:	4891                	li	a7,4
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <read>:
.global read
read:
 li a7, SYS_read
 4fc:	4895                	li	a7,5
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <write>:
.global write
write:
 li a7, SYS_write
 504:	48c1                	li	a7,16
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <close>:
.global close
close:
 li a7, SYS_close
 50c:	48d5                	li	a7,21
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <kill>:
.global kill
kill:
 li a7, SYS_kill
 514:	4899                	li	a7,6
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <exec>:
.global exec
exec:
 li a7, SYS_exec
 51c:	489d                	li	a7,7
 ecall
 51e:	00000073          	ecall
 ret
 522:	8082                	ret

0000000000000524 <open>:
.global open
open:
 li a7, SYS_open
 524:	48bd                	li	a7,15
 ecall
 526:	00000073          	ecall
 ret
 52a:	8082                	ret

000000000000052c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 52c:	48c5                	li	a7,17
 ecall
 52e:	00000073          	ecall
 ret
 532:	8082                	ret

0000000000000534 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 534:	48c9                	li	a7,18
 ecall
 536:	00000073          	ecall
 ret
 53a:	8082                	ret

000000000000053c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 53c:	48a1                	li	a7,8
 ecall
 53e:	00000073          	ecall
 ret
 542:	8082                	ret

0000000000000544 <link>:
.global link
link:
 li a7, SYS_link
 544:	48cd                	li	a7,19
 ecall
 546:	00000073          	ecall
 ret
 54a:	8082                	ret

000000000000054c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 54c:	48d1                	li	a7,20
 ecall
 54e:	00000073          	ecall
 ret
 552:	8082                	ret

0000000000000554 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 554:	48a5                	li	a7,9
 ecall
 556:	00000073          	ecall
 ret
 55a:	8082                	ret

000000000000055c <dup>:
.global dup
dup:
 li a7, SYS_dup
 55c:	48a9                	li	a7,10
 ecall
 55e:	00000073          	ecall
 ret
 562:	8082                	ret

0000000000000564 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 564:	48ad                	li	a7,11
 ecall
 566:	00000073          	ecall
 ret
 56a:	8082                	ret

000000000000056c <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 56c:	48b1                	li	a7,12
 ecall
 56e:	00000073          	ecall
 ret
 572:	8082                	ret

0000000000000574 <pause>:
.global pause
pause:
 li a7, SYS_pause
 574:	48b5                	li	a7,13
 ecall
 576:	00000073          	ecall
 ret
 57a:	8082                	ret

000000000000057c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 57c:	48b9                	li	a7,14
 ecall
 57e:	00000073          	ecall
 ret
 582:	8082                	ret

0000000000000584 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 584:	1101                	addi	sp,sp,-32
 586:	ec06                	sd	ra,24(sp)
 588:	e822                	sd	s0,16(sp)
 58a:	1000                	addi	s0,sp,32
 58c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 590:	4605                	li	a2,1
 592:	fef40593          	addi	a1,s0,-17
 596:	f6fff0ef          	jal	ra,504 <write>
}
 59a:	60e2                	ld	ra,24(sp)
 59c:	6442                	ld	s0,16(sp)
 59e:	6105                	addi	sp,sp,32
 5a0:	8082                	ret

00000000000005a2 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 5a2:	715d                	addi	sp,sp,-80
 5a4:	e486                	sd	ra,72(sp)
 5a6:	e0a2                	sd	s0,64(sp)
 5a8:	fc26                	sd	s1,56(sp)
 5aa:	f84a                	sd	s2,48(sp)
 5ac:	f44e                	sd	s3,40(sp)
 5ae:	0880                	addi	s0,sp,80
 5b0:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 5b2:	c299                	beqz	a3,5b8 <printint+0x16>
 5b4:	0805c163          	bltz	a1,636 <printint+0x94>
  neg = 0;
 5b8:	4881                	li	a7,0
 5ba:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 5be:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 5c0:	00000517          	auipc	a0,0x0
 5c4:	52050513          	addi	a0,a0,1312 # ae0 <digits>
 5c8:	883e                	mv	a6,a5
 5ca:	2785                	addiw	a5,a5,1
 5cc:	02c5f733          	remu	a4,a1,a2
 5d0:	972a                	add	a4,a4,a0
 5d2:	00074703          	lbu	a4,0(a4)
 5d6:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 5da:	872e                	mv	a4,a1
 5dc:	02c5d5b3          	divu	a1,a1,a2
 5e0:	0685                	addi	a3,a3,1
 5e2:	fec773e3          	bgeu	a4,a2,5c8 <printint+0x26>
  if(neg)
 5e6:	00088b63          	beqz	a7,5fc <printint+0x5a>
    buf[i++] = '-';
 5ea:	fd040713          	addi	a4,s0,-48
 5ee:	97ba                	add	a5,a5,a4
 5f0:	02d00713          	li	a4,45
 5f4:	fee78423          	sb	a4,-24(a5)
 5f8:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 5fc:	02f05663          	blez	a5,628 <printint+0x86>
 600:	fb840713          	addi	a4,s0,-72
 604:	00f704b3          	add	s1,a4,a5
 608:	fff70993          	addi	s3,a4,-1
 60c:	99be                	add	s3,s3,a5
 60e:	37fd                	addiw	a5,a5,-1
 610:	1782                	slli	a5,a5,0x20
 612:	9381                	srli	a5,a5,0x20
 614:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 618:	fff4c583          	lbu	a1,-1(s1)
 61c:	854a                	mv	a0,s2
 61e:	f67ff0ef          	jal	ra,584 <putc>
  while(--i >= 0)
 622:	14fd                	addi	s1,s1,-1
 624:	ff349ae3          	bne	s1,s3,618 <printint+0x76>
}
 628:	60a6                	ld	ra,72(sp)
 62a:	6406                	ld	s0,64(sp)
 62c:	74e2                	ld	s1,56(sp)
 62e:	7942                	ld	s2,48(sp)
 630:	79a2                	ld	s3,40(sp)
 632:	6161                	addi	sp,sp,80
 634:	8082                	ret
    x = -xx;
 636:	40b005b3          	neg	a1,a1
    neg = 1;
 63a:	4885                	li	a7,1
    x = -xx;
 63c:	bfbd                	j	5ba <printint+0x18>

000000000000063e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 63e:	7119                	addi	sp,sp,-128
 640:	fc86                	sd	ra,120(sp)
 642:	f8a2                	sd	s0,112(sp)
 644:	f4a6                	sd	s1,104(sp)
 646:	f0ca                	sd	s2,96(sp)
 648:	ecce                	sd	s3,88(sp)
 64a:	e8d2                	sd	s4,80(sp)
 64c:	e4d6                	sd	s5,72(sp)
 64e:	e0da                	sd	s6,64(sp)
 650:	fc5e                	sd	s7,56(sp)
 652:	f862                	sd	s8,48(sp)
 654:	f466                	sd	s9,40(sp)
 656:	f06a                	sd	s10,32(sp)
 658:	ec6e                	sd	s11,24(sp)
 65a:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 65c:	0005c903          	lbu	s2,0(a1)
 660:	24090c63          	beqz	s2,8b8 <vprintf+0x27a>
 664:	8b2a                	mv	s6,a0
 666:	8a2e                	mv	s4,a1
 668:	8bb2                	mv	s7,a2
  state = 0;
 66a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 66c:	4481                	li	s1,0
 66e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 670:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 674:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 678:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 67c:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 680:	00000c97          	auipc	s9,0x0
 684:	460c8c93          	addi	s9,s9,1120 # ae0 <digits>
 688:	a005                	j	6a8 <vprintf+0x6a>
        putc(fd, c0);
 68a:	85ca                	mv	a1,s2
 68c:	855a                	mv	a0,s6
 68e:	ef7ff0ef          	jal	ra,584 <putc>
 692:	a019                	j	698 <vprintf+0x5a>
    } else if(state == '%'){
 694:	03598263          	beq	s3,s5,6b8 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 698:	2485                	addiw	s1,s1,1
 69a:	8726                	mv	a4,s1
 69c:	009a07b3          	add	a5,s4,s1
 6a0:	0007c903          	lbu	s2,0(a5)
 6a4:	20090a63          	beqz	s2,8b8 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 6a8:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6ac:	fe0994e3          	bnez	s3,694 <vprintf+0x56>
      if(c0 == '%'){
 6b0:	fd579de3          	bne	a5,s5,68a <vprintf+0x4c>
        state = '%';
 6b4:	89be                	mv	s3,a5
 6b6:	b7cd                	j	698 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 6b8:	c3c1                	beqz	a5,738 <vprintf+0xfa>
 6ba:	00ea06b3          	add	a3,s4,a4
 6be:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 6c2:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 6c4:	c681                	beqz	a3,6cc <vprintf+0x8e>
 6c6:	9752                	add	a4,a4,s4
 6c8:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 6cc:	03878e63          	beq	a5,s8,708 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 6d0:	05a78863          	beq	a5,s10,720 <vprintf+0xe2>
      } else if(c0 == 'u'){
 6d4:	0db78b63          	beq	a5,s11,7aa <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 6d8:	07800713          	li	a4,120
 6dc:	10e78d63          	beq	a5,a4,7f6 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 6e0:	07000713          	li	a4,112
 6e4:	14e78263          	beq	a5,a4,828 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 6e8:	06300713          	li	a4,99
 6ec:	16e78f63          	beq	a5,a4,86a <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 6f0:	07300713          	li	a4,115
 6f4:	18e78563          	beq	a5,a4,87e <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 6f8:	05579063          	bne	a5,s5,738 <vprintf+0xfa>
        putc(fd, '%');
 6fc:	85d6                	mv	a1,s5
 6fe:	855a                	mv	a0,s6
 700:	e85ff0ef          	jal	ra,584 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 704:	4981                	li	s3,0
 706:	bf49                	j	698 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 708:	008b8913          	addi	s2,s7,8
 70c:	4685                	li	a3,1
 70e:	4629                	li	a2,10
 710:	000ba583          	lw	a1,0(s7)
 714:	855a                	mv	a0,s6
 716:	e8dff0ef          	jal	ra,5a2 <printint>
 71a:	8bca                	mv	s7,s2
      state = 0;
 71c:	4981                	li	s3,0
 71e:	bfad                	j	698 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 720:	03868663          	beq	a3,s8,74c <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 724:	05a68163          	beq	a3,s10,766 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 728:	09b68d63          	beq	a3,s11,7c2 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 72c:	03a68f63          	beq	a3,s10,76a <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 730:	07800793          	li	a5,120
 734:	0cf68d63          	beq	a3,a5,80e <vprintf+0x1d0>
        putc(fd, '%');
 738:	85d6                	mv	a1,s5
 73a:	855a                	mv	a0,s6
 73c:	e49ff0ef          	jal	ra,584 <putc>
        putc(fd, c0);
 740:	85ca                	mv	a1,s2
 742:	855a                	mv	a0,s6
 744:	e41ff0ef          	jal	ra,584 <putc>
      state = 0;
 748:	4981                	li	s3,0
 74a:	b7b9                	j	698 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 74c:	008b8913          	addi	s2,s7,8
 750:	4685                	li	a3,1
 752:	4629                	li	a2,10
 754:	000bb583          	ld	a1,0(s7)
 758:	855a                	mv	a0,s6
 75a:	e49ff0ef          	jal	ra,5a2 <printint>
        i += 1;
 75e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 760:	8bca                	mv	s7,s2
      state = 0;
 762:	4981                	li	s3,0
        i += 1;
 764:	bf15                	j	698 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 766:	03860563          	beq	a2,s8,790 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 76a:	07b60963          	beq	a2,s11,7dc <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 76e:	07800793          	li	a5,120
 772:	fcf613e3          	bne	a2,a5,738 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 776:	008b8913          	addi	s2,s7,8
 77a:	4681                	li	a3,0
 77c:	4641                	li	a2,16
 77e:	000bb583          	ld	a1,0(s7)
 782:	855a                	mv	a0,s6
 784:	e1fff0ef          	jal	ra,5a2 <printint>
        i += 2;
 788:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 78a:	8bca                	mv	s7,s2
      state = 0;
 78c:	4981                	li	s3,0
        i += 2;
 78e:	b729                	j	698 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 790:	008b8913          	addi	s2,s7,8
 794:	4685                	li	a3,1
 796:	4629                	li	a2,10
 798:	000bb583          	ld	a1,0(s7)
 79c:	855a                	mv	a0,s6
 79e:	e05ff0ef          	jal	ra,5a2 <printint>
        i += 2;
 7a2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 7a4:	8bca                	mv	s7,s2
      state = 0;
 7a6:	4981                	li	s3,0
        i += 2;
 7a8:	bdc5                	j	698 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 7aa:	008b8913          	addi	s2,s7,8
 7ae:	4681                	li	a3,0
 7b0:	4629                	li	a2,10
 7b2:	000be583          	lwu	a1,0(s7)
 7b6:	855a                	mv	a0,s6
 7b8:	debff0ef          	jal	ra,5a2 <printint>
 7bc:	8bca                	mv	s7,s2
      state = 0;
 7be:	4981                	li	s3,0
 7c0:	bde1                	j	698 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7c2:	008b8913          	addi	s2,s7,8
 7c6:	4681                	li	a3,0
 7c8:	4629                	li	a2,10
 7ca:	000bb583          	ld	a1,0(s7)
 7ce:	855a                	mv	a0,s6
 7d0:	dd3ff0ef          	jal	ra,5a2 <printint>
        i += 1;
 7d4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 7d6:	8bca                	mv	s7,s2
      state = 0;
 7d8:	4981                	li	s3,0
        i += 1;
 7da:	bd7d                	j	698 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7dc:	008b8913          	addi	s2,s7,8
 7e0:	4681                	li	a3,0
 7e2:	4629                	li	a2,10
 7e4:	000bb583          	ld	a1,0(s7)
 7e8:	855a                	mv	a0,s6
 7ea:	db9ff0ef          	jal	ra,5a2 <printint>
        i += 2;
 7ee:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 7f0:	8bca                	mv	s7,s2
      state = 0;
 7f2:	4981                	li	s3,0
        i += 2;
 7f4:	b555                	j	698 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 7f6:	008b8913          	addi	s2,s7,8
 7fa:	4681                	li	a3,0
 7fc:	4641                	li	a2,16
 7fe:	000be583          	lwu	a1,0(s7)
 802:	855a                	mv	a0,s6
 804:	d9fff0ef          	jal	ra,5a2 <printint>
 808:	8bca                	mv	s7,s2
      state = 0;
 80a:	4981                	li	s3,0
 80c:	b571                	j	698 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 80e:	008b8913          	addi	s2,s7,8
 812:	4681                	li	a3,0
 814:	4641                	li	a2,16
 816:	000bb583          	ld	a1,0(s7)
 81a:	855a                	mv	a0,s6
 81c:	d87ff0ef          	jal	ra,5a2 <printint>
        i += 1;
 820:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 822:	8bca                	mv	s7,s2
      state = 0;
 824:	4981                	li	s3,0
        i += 1;
 826:	bd8d                	j	698 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 828:	008b8793          	addi	a5,s7,8
 82c:	f8f43423          	sd	a5,-120(s0)
 830:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 834:	03000593          	li	a1,48
 838:	855a                	mv	a0,s6
 83a:	d4bff0ef          	jal	ra,584 <putc>
  putc(fd, 'x');
 83e:	07800593          	li	a1,120
 842:	855a                	mv	a0,s6
 844:	d41ff0ef          	jal	ra,584 <putc>
 848:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 84a:	03c9d793          	srli	a5,s3,0x3c
 84e:	97e6                	add	a5,a5,s9
 850:	0007c583          	lbu	a1,0(a5)
 854:	855a                	mv	a0,s6
 856:	d2fff0ef          	jal	ra,584 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 85a:	0992                	slli	s3,s3,0x4
 85c:	397d                	addiw	s2,s2,-1
 85e:	fe0916e3          	bnez	s2,84a <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 862:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 866:	4981                	li	s3,0
 868:	bd05                	j	698 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 86a:	008b8913          	addi	s2,s7,8
 86e:	000bc583          	lbu	a1,0(s7)
 872:	855a                	mv	a0,s6
 874:	d11ff0ef          	jal	ra,584 <putc>
 878:	8bca                	mv	s7,s2
      state = 0;
 87a:	4981                	li	s3,0
 87c:	bd31                	j	698 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 87e:	008b8993          	addi	s3,s7,8
 882:	000bb903          	ld	s2,0(s7)
 886:	00090f63          	beqz	s2,8a4 <vprintf+0x266>
        for(; *s; s++)
 88a:	00094583          	lbu	a1,0(s2)
 88e:	c195                	beqz	a1,8b2 <vprintf+0x274>
          putc(fd, *s);
 890:	855a                	mv	a0,s6
 892:	cf3ff0ef          	jal	ra,584 <putc>
        for(; *s; s++)
 896:	0905                	addi	s2,s2,1
 898:	00094583          	lbu	a1,0(s2)
 89c:	f9f5                	bnez	a1,890 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 89e:	8bce                	mv	s7,s3
      state = 0;
 8a0:	4981                	li	s3,0
 8a2:	bbdd                	j	698 <vprintf+0x5a>
          s = "(null)";
 8a4:	00000917          	auipc	s2,0x0
 8a8:	23490913          	addi	s2,s2,564 # ad8 <malloc+0x11e>
        for(; *s; s++)
 8ac:	02800593          	li	a1,40
 8b0:	b7c5                	j	890 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 8b2:	8bce                	mv	s7,s3
      state = 0;
 8b4:	4981                	li	s3,0
 8b6:	b3cd                	j	698 <vprintf+0x5a>
    }
  }
}
 8b8:	70e6                	ld	ra,120(sp)
 8ba:	7446                	ld	s0,112(sp)
 8bc:	74a6                	ld	s1,104(sp)
 8be:	7906                	ld	s2,96(sp)
 8c0:	69e6                	ld	s3,88(sp)
 8c2:	6a46                	ld	s4,80(sp)
 8c4:	6aa6                	ld	s5,72(sp)
 8c6:	6b06                	ld	s6,64(sp)
 8c8:	7be2                	ld	s7,56(sp)
 8ca:	7c42                	ld	s8,48(sp)
 8cc:	7ca2                	ld	s9,40(sp)
 8ce:	7d02                	ld	s10,32(sp)
 8d0:	6de2                	ld	s11,24(sp)
 8d2:	6109                	addi	sp,sp,128
 8d4:	8082                	ret

00000000000008d6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8d6:	715d                	addi	sp,sp,-80
 8d8:	ec06                	sd	ra,24(sp)
 8da:	e822                	sd	s0,16(sp)
 8dc:	1000                	addi	s0,sp,32
 8de:	e010                	sd	a2,0(s0)
 8e0:	e414                	sd	a3,8(s0)
 8e2:	e818                	sd	a4,16(s0)
 8e4:	ec1c                	sd	a5,24(s0)
 8e6:	03043023          	sd	a6,32(s0)
 8ea:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8ee:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8f2:	8622                	mv	a2,s0
 8f4:	d4bff0ef          	jal	ra,63e <vprintf>
}
 8f8:	60e2                	ld	ra,24(sp)
 8fa:	6442                	ld	s0,16(sp)
 8fc:	6161                	addi	sp,sp,80
 8fe:	8082                	ret

0000000000000900 <printf>:

void
printf(const char *fmt, ...)
{
 900:	711d                	addi	sp,sp,-96
 902:	ec06                	sd	ra,24(sp)
 904:	e822                	sd	s0,16(sp)
 906:	1000                	addi	s0,sp,32
 908:	e40c                	sd	a1,8(s0)
 90a:	e810                	sd	a2,16(s0)
 90c:	ec14                	sd	a3,24(s0)
 90e:	f018                	sd	a4,32(s0)
 910:	f41c                	sd	a5,40(s0)
 912:	03043823          	sd	a6,48(s0)
 916:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 91a:	00840613          	addi	a2,s0,8
 91e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 922:	85aa                	mv	a1,a0
 924:	4505                	li	a0,1
 926:	d19ff0ef          	jal	ra,63e <vprintf>
}
 92a:	60e2                	ld	ra,24(sp)
 92c:	6442                	ld	s0,16(sp)
 92e:	6125                	addi	sp,sp,96
 930:	8082                	ret

0000000000000932 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 932:	1141                	addi	sp,sp,-16
 934:	e422                	sd	s0,8(sp)
 936:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 938:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 93c:	00000797          	auipc	a5,0x0
 940:	6c47b783          	ld	a5,1732(a5) # 1000 <freep>
 944:	a805                	j	974 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 946:	4618                	lw	a4,8(a2)
 948:	9db9                	addw	a1,a1,a4
 94a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 94e:	6398                	ld	a4,0(a5)
 950:	6318                	ld	a4,0(a4)
 952:	fee53823          	sd	a4,-16(a0)
 956:	a091                	j	99a <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 958:	ff852703          	lw	a4,-8(a0)
 95c:	9e39                	addw	a2,a2,a4
 95e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 960:	ff053703          	ld	a4,-16(a0)
 964:	e398                	sd	a4,0(a5)
 966:	a099                	j	9ac <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 968:	6398                	ld	a4,0(a5)
 96a:	00e7e463          	bltu	a5,a4,972 <free+0x40>
 96e:	00e6ea63          	bltu	a3,a4,982 <free+0x50>
{
 972:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 974:	fed7fae3          	bgeu	a5,a3,968 <free+0x36>
 978:	6398                	ld	a4,0(a5)
 97a:	00e6e463          	bltu	a3,a4,982 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 97e:	fee7eae3          	bltu	a5,a4,972 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 982:	ff852583          	lw	a1,-8(a0)
 986:	6390                	ld	a2,0(a5)
 988:	02059713          	slli	a4,a1,0x20
 98c:	9301                	srli	a4,a4,0x20
 98e:	0712                	slli	a4,a4,0x4
 990:	9736                	add	a4,a4,a3
 992:	fae60ae3          	beq	a2,a4,946 <free+0x14>
    bp->s.ptr = p->s.ptr;
 996:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 99a:	4790                	lw	a2,8(a5)
 99c:	02061713          	slli	a4,a2,0x20
 9a0:	9301                	srli	a4,a4,0x20
 9a2:	0712                	slli	a4,a4,0x4
 9a4:	973e                	add	a4,a4,a5
 9a6:	fae689e3          	beq	a3,a4,958 <free+0x26>
  } else
    p->s.ptr = bp;
 9aa:	e394                	sd	a3,0(a5)
  freep = p;
 9ac:	00000717          	auipc	a4,0x0
 9b0:	64f73a23          	sd	a5,1620(a4) # 1000 <freep>
}
 9b4:	6422                	ld	s0,8(sp)
 9b6:	0141                	addi	sp,sp,16
 9b8:	8082                	ret

00000000000009ba <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9ba:	7139                	addi	sp,sp,-64
 9bc:	fc06                	sd	ra,56(sp)
 9be:	f822                	sd	s0,48(sp)
 9c0:	f426                	sd	s1,40(sp)
 9c2:	f04a                	sd	s2,32(sp)
 9c4:	ec4e                	sd	s3,24(sp)
 9c6:	e852                	sd	s4,16(sp)
 9c8:	e456                	sd	s5,8(sp)
 9ca:	e05a                	sd	s6,0(sp)
 9cc:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9ce:	02051493          	slli	s1,a0,0x20
 9d2:	9081                	srli	s1,s1,0x20
 9d4:	04bd                	addi	s1,s1,15
 9d6:	8091                	srli	s1,s1,0x4
 9d8:	0014899b          	addiw	s3,s1,1
 9dc:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9de:	00000517          	auipc	a0,0x0
 9e2:	62253503          	ld	a0,1570(a0) # 1000 <freep>
 9e6:	c515                	beqz	a0,a12 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9e8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9ea:	4798                	lw	a4,8(a5)
 9ec:	02977f63          	bgeu	a4,s1,a2a <malloc+0x70>
 9f0:	8a4e                	mv	s4,s3
 9f2:	0009871b          	sext.w	a4,s3
 9f6:	6685                	lui	a3,0x1
 9f8:	00d77363          	bgeu	a4,a3,9fe <malloc+0x44>
 9fc:	6a05                	lui	s4,0x1
 9fe:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a02:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a06:	00000917          	auipc	s2,0x0
 a0a:	5fa90913          	addi	s2,s2,1530 # 1000 <freep>
  if(p == SBRK_ERROR)
 a0e:	5afd                	li	s5,-1
 a10:	a0bd                	j	a7e <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 a12:	00001797          	auipc	a5,0x1
 a16:	9fe78793          	addi	a5,a5,-1538 # 1410 <base>
 a1a:	00000717          	auipc	a4,0x0
 a1e:	5ef73323          	sd	a5,1510(a4) # 1000 <freep>
 a22:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a24:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a28:	b7e1                	j	9f0 <malloc+0x36>
      if(p->s.size == nunits)
 a2a:	02e48b63          	beq	s1,a4,a60 <malloc+0xa6>
        p->s.size -= nunits;
 a2e:	4137073b          	subw	a4,a4,s3
 a32:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a34:	1702                	slli	a4,a4,0x20
 a36:	9301                	srli	a4,a4,0x20
 a38:	0712                	slli	a4,a4,0x4
 a3a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a3c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a40:	00000717          	auipc	a4,0x0
 a44:	5ca73023          	sd	a0,1472(a4) # 1000 <freep>
      return (void*)(p + 1);
 a48:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a4c:	70e2                	ld	ra,56(sp)
 a4e:	7442                	ld	s0,48(sp)
 a50:	74a2                	ld	s1,40(sp)
 a52:	7902                	ld	s2,32(sp)
 a54:	69e2                	ld	s3,24(sp)
 a56:	6a42                	ld	s4,16(sp)
 a58:	6aa2                	ld	s5,8(sp)
 a5a:	6b02                	ld	s6,0(sp)
 a5c:	6121                	addi	sp,sp,64
 a5e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a60:	6398                	ld	a4,0(a5)
 a62:	e118                	sd	a4,0(a0)
 a64:	bff1                	j	a40 <malloc+0x86>
  hp->s.size = nu;
 a66:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a6a:	0541                	addi	a0,a0,16
 a6c:	ec7ff0ef          	jal	ra,932 <free>
  return freep;
 a70:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a74:	dd61                	beqz	a0,a4c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a76:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a78:	4798                	lw	a4,8(a5)
 a7a:	fa9778e3          	bgeu	a4,s1,a2a <malloc+0x70>
    if(p == freep)
 a7e:	00093703          	ld	a4,0(s2)
 a82:	853e                	mv	a0,a5
 a84:	fef719e3          	bne	a4,a5,a76 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 a88:	8552                	mv	a0,s4
 a8a:	a27ff0ef          	jal	ra,4b0 <sbrk>
  if(p == SBRK_ERROR)
 a8e:	fd551ce3          	bne	a0,s5,a66 <malloc+0xac>
        return 0;
 a92:	4501                	li	a0,0
 a94:	bf65                	j	a4c <malloc+0x92>
