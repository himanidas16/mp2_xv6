
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	711d                	addi	sp,sp,-96
       2:	ec86                	sd	ra,88(sp)
       4:	e8a2                	sd	s0,80(sp)
       6:	e4a6                	sd	s1,72(sp)
       8:	e0ca                	sd	s2,64(sp)
       a:	fc4e                	sd	s3,56(sp)
       c:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0x3fffffe000, 0x3ffffff000, 0x4000000000,
       e:	00007797          	auipc	a5,0x7
      12:	67278793          	addi	a5,a5,1650 # 7680 <malloc+0x2562>
      16:	638c                	ld	a1,0(a5)
      18:	6790                	ld	a2,8(a5)
      1a:	6b94                	ld	a3,16(a5)
      1c:	6f98                	ld	a4,24(a5)
      1e:	739c                	ld	a5,32(a5)
      20:	fab43423          	sd	a1,-88(s0)
      24:	fac43823          	sd	a2,-80(s0)
      28:	fad43c23          	sd	a3,-72(s0)
      2c:	fce43023          	sd	a4,-64(s0)
      30:	fcf43423          	sd	a5,-56(s0)
                     0xffffffffffffffff };

  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
      34:	fa840493          	addi	s1,s0,-88
      38:	fd040993          	addi	s3,s0,-48
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      3c:	0004b903          	ld	s2,0(s1)
      40:	20100593          	li	a1,513
      44:	854a                	mv	a0,s2
      46:	43b040ef          	jal	ra,4c80 <open>
    if(fd >= 0){
      4a:	00055c63          	bgez	a0,62 <copyinstr1+0x62>
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
      4e:	04a1                	addi	s1,s1,8
      50:	ff3496e3          	bne	s1,s3,3c <copyinstr1+0x3c>
      printf("open(%p) returned %d, not -1\n", (void*)addr, fd);
      exit(1);
    }
  }
}
      54:	60e6                	ld	ra,88(sp)
      56:	6446                	ld	s0,80(sp)
      58:	64a6                	ld	s1,72(sp)
      5a:	6906                	ld	s2,64(sp)
      5c:	79e2                	ld	s3,56(sp)
      5e:	6125                	addi	sp,sp,96
      60:	8082                	ret
      printf("open(%p) returned %d, not -1\n", (void*)addr, fd);
      62:	862a                	mv	a2,a0
      64:	85ca                	mv	a1,s2
      66:	00005517          	auipc	a0,0x5
      6a:	1ba50513          	addi	a0,a0,442 # 5220 <malloc+0x102>
      6e:	7f7040ef          	jal	ra,5064 <printf>
      exit(1);
      72:	4505                	li	a0,1
      74:	3cd040ef          	jal	ra,4c40 <exit>

0000000000000078 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      78:	00009797          	auipc	a5,0x9
      7c:	52078793          	addi	a5,a5,1312 # 9598 <uninit>
      80:	0000c697          	auipc	a3,0xc
      84:	c2868693          	addi	a3,a3,-984 # bca8 <buf>
    if(uninit[i] != '\0'){
      88:	0007c703          	lbu	a4,0(a5)
      8c:	e709                	bnez	a4,96 <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      8e:	0785                	addi	a5,a5,1
      90:	fed79ce3          	bne	a5,a3,88 <bsstest+0x10>
      94:	8082                	ret
{
      96:	1141                	addi	sp,sp,-16
      98:	e406                	sd	ra,8(sp)
      9a:	e022                	sd	s0,0(sp)
      9c:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      9e:	85aa                	mv	a1,a0
      a0:	00005517          	auipc	a0,0x5
      a4:	1a050513          	addi	a0,a0,416 # 5240 <malloc+0x122>
      a8:	7bd040ef          	jal	ra,5064 <printf>
      exit(1);
      ac:	4505                	li	a0,1
      ae:	393040ef          	jal	ra,4c40 <exit>

00000000000000b2 <opentest>:
{
      b2:	1101                	addi	sp,sp,-32
      b4:	ec06                	sd	ra,24(sp)
      b6:	e822                	sd	s0,16(sp)
      b8:	e426                	sd	s1,8(sp)
      ba:	1000                	addi	s0,sp,32
      bc:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      be:	4581                	li	a1,0
      c0:	00005517          	auipc	a0,0x5
      c4:	19850513          	addi	a0,a0,408 # 5258 <malloc+0x13a>
      c8:	3b9040ef          	jal	ra,4c80 <open>
  if(fd < 0){
      cc:	02054263          	bltz	a0,f0 <opentest+0x3e>
  close(fd);
      d0:	399040ef          	jal	ra,4c68 <close>
  fd = open("doesnotexist", 0);
      d4:	4581                	li	a1,0
      d6:	00005517          	auipc	a0,0x5
      da:	1a250513          	addi	a0,a0,418 # 5278 <malloc+0x15a>
      de:	3a3040ef          	jal	ra,4c80 <open>
  if(fd >= 0){
      e2:	02055163          	bgez	a0,104 <opentest+0x52>
}
      e6:	60e2                	ld	ra,24(sp)
      e8:	6442                	ld	s0,16(sp)
      ea:	64a2                	ld	s1,8(sp)
      ec:	6105                	addi	sp,sp,32
      ee:	8082                	ret
    printf("%s: open echo failed!\n", s);
      f0:	85a6                	mv	a1,s1
      f2:	00005517          	auipc	a0,0x5
      f6:	16e50513          	addi	a0,a0,366 # 5260 <malloc+0x142>
      fa:	76b040ef          	jal	ra,5064 <printf>
    exit(1);
      fe:	4505                	li	a0,1
     100:	341040ef          	jal	ra,4c40 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     104:	85a6                	mv	a1,s1
     106:	00005517          	auipc	a0,0x5
     10a:	18250513          	addi	a0,a0,386 # 5288 <malloc+0x16a>
     10e:	757040ef          	jal	ra,5064 <printf>
    exit(1);
     112:	4505                	li	a0,1
     114:	32d040ef          	jal	ra,4c40 <exit>

0000000000000118 <truncate2>:
{
     118:	7179                	addi	sp,sp,-48
     11a:	f406                	sd	ra,40(sp)
     11c:	f022                	sd	s0,32(sp)
     11e:	ec26                	sd	s1,24(sp)
     120:	e84a                	sd	s2,16(sp)
     122:	e44e                	sd	s3,8(sp)
     124:	1800                	addi	s0,sp,48
     126:	89aa                	mv	s3,a0
  unlink("truncfile");
     128:	00005517          	auipc	a0,0x5
     12c:	18850513          	addi	a0,a0,392 # 52b0 <malloc+0x192>
     130:	361040ef          	jal	ra,4c90 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     134:	60100593          	li	a1,1537
     138:	00005517          	auipc	a0,0x5
     13c:	17850513          	addi	a0,a0,376 # 52b0 <malloc+0x192>
     140:	341040ef          	jal	ra,4c80 <open>
     144:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     146:	4611                	li	a2,4
     148:	00005597          	auipc	a1,0x5
     14c:	17858593          	addi	a1,a1,376 # 52c0 <malloc+0x1a2>
     150:	311040ef          	jal	ra,4c60 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     154:	40100593          	li	a1,1025
     158:	00005517          	auipc	a0,0x5
     15c:	15850513          	addi	a0,a0,344 # 52b0 <malloc+0x192>
     160:	321040ef          	jal	ra,4c80 <open>
     164:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     166:	4605                	li	a2,1
     168:	00005597          	auipc	a1,0x5
     16c:	16058593          	addi	a1,a1,352 # 52c8 <malloc+0x1aa>
     170:	8526                	mv	a0,s1
     172:	2ef040ef          	jal	ra,4c60 <write>
  if(n != -1){
     176:	57fd                	li	a5,-1
     178:	02f51563          	bne	a0,a5,1a2 <truncate2+0x8a>
  unlink("truncfile");
     17c:	00005517          	auipc	a0,0x5
     180:	13450513          	addi	a0,a0,308 # 52b0 <malloc+0x192>
     184:	30d040ef          	jal	ra,4c90 <unlink>
  close(fd1);
     188:	8526                	mv	a0,s1
     18a:	2df040ef          	jal	ra,4c68 <close>
  close(fd2);
     18e:	854a                	mv	a0,s2
     190:	2d9040ef          	jal	ra,4c68 <close>
}
     194:	70a2                	ld	ra,40(sp)
     196:	7402                	ld	s0,32(sp)
     198:	64e2                	ld	s1,24(sp)
     19a:	6942                	ld	s2,16(sp)
     19c:	69a2                	ld	s3,8(sp)
     19e:	6145                	addi	sp,sp,48
     1a0:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1a2:	862a                	mv	a2,a0
     1a4:	85ce                	mv	a1,s3
     1a6:	00005517          	auipc	a0,0x5
     1aa:	12a50513          	addi	a0,a0,298 # 52d0 <malloc+0x1b2>
     1ae:	6b7040ef          	jal	ra,5064 <printf>
    exit(1);
     1b2:	4505                	li	a0,1
     1b4:	28d040ef          	jal	ra,4c40 <exit>

00000000000001b8 <createtest>:
{
     1b8:	7179                	addi	sp,sp,-48
     1ba:	f406                	sd	ra,40(sp)
     1bc:	f022                	sd	s0,32(sp)
     1be:	ec26                	sd	s1,24(sp)
     1c0:	e84a                	sd	s2,16(sp)
     1c2:	1800                	addi	s0,sp,48
  name[0] = 'a';
     1c4:	06100793          	li	a5,97
     1c8:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     1cc:	fc040d23          	sb	zero,-38(s0)
     1d0:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     1d4:	06400913          	li	s2,100
    name[1] = '0' + i;
     1d8:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE|O_RDWR);
     1dc:	20200593          	li	a1,514
     1e0:	fd840513          	addi	a0,s0,-40
     1e4:	29d040ef          	jal	ra,4c80 <open>
    close(fd);
     1e8:	281040ef          	jal	ra,4c68 <close>
  for(i = 0; i < N; i++){
     1ec:	2485                	addiw	s1,s1,1
     1ee:	0ff4f493          	andi	s1,s1,255
     1f2:	ff2493e3          	bne	s1,s2,1d8 <createtest+0x20>
  name[0] = 'a';
     1f6:	06100793          	li	a5,97
     1fa:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     1fe:	fc040d23          	sb	zero,-38(s0)
     202:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     206:	06400913          	li	s2,100
    name[1] = '0' + i;
     20a:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
     20e:	fd840513          	addi	a0,s0,-40
     212:	27f040ef          	jal	ra,4c90 <unlink>
  for(i = 0; i < N; i++){
     216:	2485                	addiw	s1,s1,1
     218:	0ff4f493          	andi	s1,s1,255
     21c:	ff2497e3          	bne	s1,s2,20a <createtest+0x52>
}
     220:	70a2                	ld	ra,40(sp)
     222:	7402                	ld	s0,32(sp)
     224:	64e2                	ld	s1,24(sp)
     226:	6942                	ld	s2,16(sp)
     228:	6145                	addi	sp,sp,48
     22a:	8082                	ret

000000000000022c <bigwrite>:
{
     22c:	715d                	addi	sp,sp,-80
     22e:	e486                	sd	ra,72(sp)
     230:	e0a2                	sd	s0,64(sp)
     232:	fc26                	sd	s1,56(sp)
     234:	f84a                	sd	s2,48(sp)
     236:	f44e                	sd	s3,40(sp)
     238:	f052                	sd	s4,32(sp)
     23a:	ec56                	sd	s5,24(sp)
     23c:	e85a                	sd	s6,16(sp)
     23e:	e45e                	sd	s7,8(sp)
     240:	0880                	addi	s0,sp,80
     242:	8baa                	mv	s7,a0
  unlink("bigwrite");
     244:	00005517          	auipc	a0,0x5
     248:	0b450513          	addi	a0,a0,180 # 52f8 <malloc+0x1da>
     24c:	245040ef          	jal	ra,4c90 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     250:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     254:	00005a97          	auipc	s5,0x5
     258:	0a4a8a93          	addi	s5,s5,164 # 52f8 <malloc+0x1da>
      int cc = write(fd, buf, sz);
     25c:	0000ca17          	auipc	s4,0xc
     260:	a4ca0a13          	addi	s4,s4,-1460 # bca8 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     264:	6b0d                	lui	s6,0x3
     266:	1c9b0b13          	addi	s6,s6,457 # 31c9 <rmdot+0x69>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     26a:	20200593          	li	a1,514
     26e:	8556                	mv	a0,s5
     270:	211040ef          	jal	ra,4c80 <open>
     274:	892a                	mv	s2,a0
    if(fd < 0){
     276:	04054563          	bltz	a0,2c0 <bigwrite+0x94>
      int cc = write(fd, buf, sz);
     27a:	8626                	mv	a2,s1
     27c:	85d2                	mv	a1,s4
     27e:	1e3040ef          	jal	ra,4c60 <write>
     282:	89aa                	mv	s3,a0
      if(cc != sz){
     284:	04a49a63          	bne	s1,a0,2d8 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     288:	8626                	mv	a2,s1
     28a:	85d2                	mv	a1,s4
     28c:	854a                	mv	a0,s2
     28e:	1d3040ef          	jal	ra,4c60 <write>
      if(cc != sz){
     292:	04951163          	bne	a0,s1,2d4 <bigwrite+0xa8>
    close(fd);
     296:	854a                	mv	a0,s2
     298:	1d1040ef          	jal	ra,4c68 <close>
    unlink("bigwrite");
     29c:	8556                	mv	a0,s5
     29e:	1f3040ef          	jal	ra,4c90 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2a2:	1d74849b          	addiw	s1,s1,471
     2a6:	fd6492e3          	bne	s1,s6,26a <bigwrite+0x3e>
}
     2aa:	60a6                	ld	ra,72(sp)
     2ac:	6406                	ld	s0,64(sp)
     2ae:	74e2                	ld	s1,56(sp)
     2b0:	7942                	ld	s2,48(sp)
     2b2:	79a2                	ld	s3,40(sp)
     2b4:	7a02                	ld	s4,32(sp)
     2b6:	6ae2                	ld	s5,24(sp)
     2b8:	6b42                	ld	s6,16(sp)
     2ba:	6ba2                	ld	s7,8(sp)
     2bc:	6161                	addi	sp,sp,80
     2be:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     2c0:	85de                	mv	a1,s7
     2c2:	00005517          	auipc	a0,0x5
     2c6:	04650513          	addi	a0,a0,70 # 5308 <malloc+0x1ea>
     2ca:	59b040ef          	jal	ra,5064 <printf>
      exit(1);
     2ce:	4505                	li	a0,1
     2d0:	171040ef          	jal	ra,4c40 <exit>
     2d4:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     2d6:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     2d8:	86ce                	mv	a3,s3
     2da:	8626                	mv	a2,s1
     2dc:	85de                	mv	a1,s7
     2de:	00005517          	auipc	a0,0x5
     2e2:	04a50513          	addi	a0,a0,74 # 5328 <malloc+0x20a>
     2e6:	57f040ef          	jal	ra,5064 <printf>
        exit(1);
     2ea:	4505                	li	a0,1
     2ec:	155040ef          	jal	ra,4c40 <exit>

00000000000002f0 <badwrite>:
// file is deleted? if the kernel has this bug, it will panic: balloc:
// out of blocks. assumed_free may need to be raised to be more than
// the number of free blocks. this test takes a long time.
void
badwrite(char *s)
{
     2f0:	7179                	addi	sp,sp,-48
     2f2:	f406                	sd	ra,40(sp)
     2f4:	f022                	sd	s0,32(sp)
     2f6:	ec26                	sd	s1,24(sp)
     2f8:	e84a                	sd	s2,16(sp)
     2fa:	e44e                	sd	s3,8(sp)
     2fc:	e052                	sd	s4,0(sp)
     2fe:	1800                	addi	s0,sp,48
  int assumed_free = 600;
  
  unlink("junk");
     300:	00005517          	auipc	a0,0x5
     304:	04050513          	addi	a0,a0,64 # 5340 <malloc+0x222>
     308:	189040ef          	jal	ra,4c90 <unlink>
     30c:	25800913          	li	s2,600
  for(int i = 0; i < assumed_free; i++){
    int fd = open("junk", O_CREATE|O_WRONLY);
     310:	00005997          	auipc	s3,0x5
     314:	03098993          	addi	s3,s3,48 # 5340 <malloc+0x222>
    if(fd < 0){
      printf("open junk failed\n");
      exit(1);
    }
    write(fd, (char*)0xffffffffffL, 1);
     318:	5a7d                	li	s4,-1
     31a:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
     31e:	20100593          	li	a1,513
     322:	854e                	mv	a0,s3
     324:	15d040ef          	jal	ra,4c80 <open>
     328:	84aa                	mv	s1,a0
    if(fd < 0){
     32a:	04054d63          	bltz	a0,384 <badwrite+0x94>
    write(fd, (char*)0xffffffffffL, 1);
     32e:	4605                	li	a2,1
     330:	85d2                	mv	a1,s4
     332:	12f040ef          	jal	ra,4c60 <write>
    close(fd);
     336:	8526                	mv	a0,s1
     338:	131040ef          	jal	ra,4c68 <close>
    unlink("junk");
     33c:	854e                	mv	a0,s3
     33e:	153040ef          	jal	ra,4c90 <unlink>
  for(int i = 0; i < assumed_free; i++){
     342:	397d                	addiw	s2,s2,-1
     344:	fc091de3          	bnez	s2,31e <badwrite+0x2e>
  }

  int fd = open("junk", O_CREATE|O_WRONLY);
     348:	20100593          	li	a1,513
     34c:	00005517          	auipc	a0,0x5
     350:	ff450513          	addi	a0,a0,-12 # 5340 <malloc+0x222>
     354:	12d040ef          	jal	ra,4c80 <open>
     358:	84aa                	mv	s1,a0
  if(fd < 0){
     35a:	02054e63          	bltz	a0,396 <badwrite+0xa6>
    printf("open junk failed\n");
    exit(1);
  }
  if(write(fd, "x", 1) != 1){
     35e:	4605                	li	a2,1
     360:	00005597          	auipc	a1,0x5
     364:	f6858593          	addi	a1,a1,-152 # 52c8 <malloc+0x1aa>
     368:	0f9040ef          	jal	ra,4c60 <write>
     36c:	4785                	li	a5,1
     36e:	02f50d63          	beq	a0,a5,3a8 <badwrite+0xb8>
    printf("write failed\n");
     372:	00005517          	auipc	a0,0x5
     376:	fee50513          	addi	a0,a0,-18 # 5360 <malloc+0x242>
     37a:	4eb040ef          	jal	ra,5064 <printf>
    exit(1);
     37e:	4505                	li	a0,1
     380:	0c1040ef          	jal	ra,4c40 <exit>
      printf("open junk failed\n");
     384:	00005517          	auipc	a0,0x5
     388:	fc450513          	addi	a0,a0,-60 # 5348 <malloc+0x22a>
     38c:	4d9040ef          	jal	ra,5064 <printf>
      exit(1);
     390:	4505                	li	a0,1
     392:	0af040ef          	jal	ra,4c40 <exit>
    printf("open junk failed\n");
     396:	00005517          	auipc	a0,0x5
     39a:	fb250513          	addi	a0,a0,-78 # 5348 <malloc+0x22a>
     39e:	4c7040ef          	jal	ra,5064 <printf>
    exit(1);
     3a2:	4505                	li	a0,1
     3a4:	09d040ef          	jal	ra,4c40 <exit>
  }
  close(fd);
     3a8:	8526                	mv	a0,s1
     3aa:	0bf040ef          	jal	ra,4c68 <close>
  unlink("junk");
     3ae:	00005517          	auipc	a0,0x5
     3b2:	f9250513          	addi	a0,a0,-110 # 5340 <malloc+0x222>
     3b6:	0db040ef          	jal	ra,4c90 <unlink>

  exit(0);
     3ba:	4501                	li	a0,0
     3bc:	085040ef          	jal	ra,4c40 <exit>

00000000000003c0 <outofinodes>:
  }
}

void
outofinodes(char *s)
{
     3c0:	715d                	addi	sp,sp,-80
     3c2:	e486                	sd	ra,72(sp)
     3c4:	e0a2                	sd	s0,64(sp)
     3c6:	fc26                	sd	s1,56(sp)
     3c8:	f84a                	sd	s2,48(sp)
     3ca:	f44e                	sd	s3,40(sp)
     3cc:	0880                	addi	s0,sp,80
  int nzz = 32*32;
  for(int i = 0; i < nzz; i++){
     3ce:	4481                	li	s1,0
    char name[32];
    name[0] = 'z';
     3d0:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
     3d4:	40000993          	li	s3,1024
    name[0] = 'z';
     3d8:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     3dc:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     3e0:	41f4d79b          	sraiw	a5,s1,0x1f
     3e4:	01b7d71b          	srliw	a4,a5,0x1b
     3e8:	009707bb          	addw	a5,a4,s1
     3ec:	4057d69b          	sraiw	a3,a5,0x5
     3f0:	0306869b          	addiw	a3,a3,48
     3f4:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     3f8:	8bfd                	andi	a5,a5,31
     3fa:	9f99                	subw	a5,a5,a4
     3fc:	0307879b          	addiw	a5,a5,48
     400:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     404:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     408:	fb040513          	addi	a0,s0,-80
     40c:	085040ef          	jal	ra,4c90 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
     410:	60200593          	li	a1,1538
     414:	fb040513          	addi	a0,s0,-80
     418:	069040ef          	jal	ra,4c80 <open>
    if(fd < 0){
     41c:	00054763          	bltz	a0,42a <outofinodes+0x6a>
      // failure is eventually expected.
      break;
    }
    close(fd);
     420:	049040ef          	jal	ra,4c68 <close>
  for(int i = 0; i < nzz; i++){
     424:	2485                	addiw	s1,s1,1
     426:	fb3499e3          	bne	s1,s3,3d8 <outofinodes+0x18>
     42a:	4481                	li	s1,0
  }

  for(int i = 0; i < nzz; i++){
    char name[32];
    name[0] = 'z';
     42c:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
     430:	40000993          	li	s3,1024
    name[0] = 'z';
     434:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     438:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     43c:	41f4d79b          	sraiw	a5,s1,0x1f
     440:	01b7d71b          	srliw	a4,a5,0x1b
     444:	009707bb          	addw	a5,a4,s1
     448:	4057d69b          	sraiw	a3,a5,0x5
     44c:	0306869b          	addiw	a3,a3,48
     450:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     454:	8bfd                	andi	a5,a5,31
     456:	9f99                	subw	a5,a5,a4
     458:	0307879b          	addiw	a5,a5,48
     45c:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     460:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     464:	fb040513          	addi	a0,s0,-80
     468:	029040ef          	jal	ra,4c90 <unlink>
  for(int i = 0; i < nzz; i++){
     46c:	2485                	addiw	s1,s1,1
     46e:	fd3493e3          	bne	s1,s3,434 <outofinodes+0x74>
  }
}
     472:	60a6                	ld	ra,72(sp)
     474:	6406                	ld	s0,64(sp)
     476:	74e2                	ld	s1,56(sp)
     478:	7942                	ld	s2,48(sp)
     47a:	79a2                	ld	s3,40(sp)
     47c:	6161                	addi	sp,sp,80
     47e:	8082                	ret

0000000000000480 <copyin>:
{
     480:	7159                	addi	sp,sp,-112
     482:	f486                	sd	ra,104(sp)
     484:	f0a2                	sd	s0,96(sp)
     486:	eca6                	sd	s1,88(sp)
     488:	e8ca                	sd	s2,80(sp)
     48a:	e4ce                	sd	s3,72(sp)
     48c:	e0d2                	sd	s4,64(sp)
     48e:	fc56                	sd	s5,56(sp)
     490:	1880                	addi	s0,sp,112
  uint64 addrs[] = { 0x80000000LL, 0x3fffffe000, 0x3ffffff000, 0x4000000000,
     492:	00007797          	auipc	a5,0x7
     496:	1ee78793          	addi	a5,a5,494 # 7680 <malloc+0x2562>
     49a:	638c                	ld	a1,0(a5)
     49c:	6790                	ld	a2,8(a5)
     49e:	6b94                	ld	a3,16(a5)
     4a0:	6f98                	ld	a4,24(a5)
     4a2:	739c                	ld	a5,32(a5)
     4a4:	f8b43c23          	sd	a1,-104(s0)
     4a8:	fac43023          	sd	a2,-96(s0)
     4ac:	fad43423          	sd	a3,-88(s0)
     4b0:	fae43823          	sd	a4,-80(s0)
     4b4:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
     4b8:	f9840913          	addi	s2,s0,-104
     4bc:	fc040a93          	addi	s5,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     4c0:	00005a17          	auipc	s4,0x5
     4c4:	eb0a0a13          	addi	s4,s4,-336 # 5370 <malloc+0x252>
    uint64 addr = addrs[ai];
     4c8:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     4cc:	20100593          	li	a1,513
     4d0:	8552                	mv	a0,s4
     4d2:	7ae040ef          	jal	ra,4c80 <open>
     4d6:	84aa                	mv	s1,a0
    if(fd < 0){
     4d8:	06054763          	bltz	a0,546 <copyin+0xc6>
    int n = write(fd, (void*)addr, 8192);
     4dc:	6609                	lui	a2,0x2
     4de:	85ce                	mv	a1,s3
     4e0:	780040ef          	jal	ra,4c60 <write>
    if(n >= 0){
     4e4:	06055a63          	bgez	a0,558 <copyin+0xd8>
    close(fd);
     4e8:	8526                	mv	a0,s1
     4ea:	77e040ef          	jal	ra,4c68 <close>
    unlink("copyin1");
     4ee:	8552                	mv	a0,s4
     4f0:	7a0040ef          	jal	ra,4c90 <unlink>
    n = write(1, (char*)addr, 8192);
     4f4:	6609                	lui	a2,0x2
     4f6:	85ce                	mv	a1,s3
     4f8:	4505                	li	a0,1
     4fa:	766040ef          	jal	ra,4c60 <write>
    if(n > 0){
     4fe:	06a04863          	bgtz	a0,56e <copyin+0xee>
    if(pipe(fds) < 0){
     502:	f9040513          	addi	a0,s0,-112
     506:	74a040ef          	jal	ra,4c50 <pipe>
     50a:	06054d63          	bltz	a0,584 <copyin+0x104>
    n = write(fds[1], (char*)addr, 8192);
     50e:	6609                	lui	a2,0x2
     510:	85ce                	mv	a1,s3
     512:	f9442503          	lw	a0,-108(s0)
     516:	74a040ef          	jal	ra,4c60 <write>
    if(n > 0){
     51a:	06a04e63          	bgtz	a0,596 <copyin+0x116>
    close(fds[0]);
     51e:	f9042503          	lw	a0,-112(s0)
     522:	746040ef          	jal	ra,4c68 <close>
    close(fds[1]);
     526:	f9442503          	lw	a0,-108(s0)
     52a:	73e040ef          	jal	ra,4c68 <close>
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
     52e:	0921                	addi	s2,s2,8
     530:	f9591ce3          	bne	s2,s5,4c8 <copyin+0x48>
}
     534:	70a6                	ld	ra,104(sp)
     536:	7406                	ld	s0,96(sp)
     538:	64e6                	ld	s1,88(sp)
     53a:	6946                	ld	s2,80(sp)
     53c:	69a6                	ld	s3,72(sp)
     53e:	6a06                	ld	s4,64(sp)
     540:	7ae2                	ld	s5,56(sp)
     542:	6165                	addi	sp,sp,112
     544:	8082                	ret
      printf("open(copyin1) failed\n");
     546:	00005517          	auipc	a0,0x5
     54a:	e3250513          	addi	a0,a0,-462 # 5378 <malloc+0x25a>
     54e:	317040ef          	jal	ra,5064 <printf>
      exit(1);
     552:	4505                	li	a0,1
     554:	6ec040ef          	jal	ra,4c40 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", (void*)addr, n);
     558:	862a                	mv	a2,a0
     55a:	85ce                	mv	a1,s3
     55c:	00005517          	auipc	a0,0x5
     560:	e3450513          	addi	a0,a0,-460 # 5390 <malloc+0x272>
     564:	301040ef          	jal	ra,5064 <printf>
      exit(1);
     568:	4505                	li	a0,1
     56a:	6d6040ef          	jal	ra,4c40 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", (void*)addr, n);
     56e:	862a                	mv	a2,a0
     570:	85ce                	mv	a1,s3
     572:	00005517          	auipc	a0,0x5
     576:	e4e50513          	addi	a0,a0,-434 # 53c0 <malloc+0x2a2>
     57a:	2eb040ef          	jal	ra,5064 <printf>
      exit(1);
     57e:	4505                	li	a0,1
     580:	6c0040ef          	jal	ra,4c40 <exit>
      printf("pipe() failed\n");
     584:	00005517          	auipc	a0,0x5
     588:	e6c50513          	addi	a0,a0,-404 # 53f0 <malloc+0x2d2>
     58c:	2d9040ef          	jal	ra,5064 <printf>
      exit(1);
     590:	4505                	li	a0,1
     592:	6ae040ef          	jal	ra,4c40 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", (void*)addr, n);
     596:	862a                	mv	a2,a0
     598:	85ce                	mv	a1,s3
     59a:	00005517          	auipc	a0,0x5
     59e:	e6650513          	addi	a0,a0,-410 # 5400 <malloc+0x2e2>
     5a2:	2c3040ef          	jal	ra,5064 <printf>
      exit(1);
     5a6:	4505                	li	a0,1
     5a8:	698040ef          	jal	ra,4c40 <exit>

00000000000005ac <copyout>:
{
     5ac:	7119                	addi	sp,sp,-128
     5ae:	fc86                	sd	ra,120(sp)
     5b0:	f8a2                	sd	s0,112(sp)
     5b2:	f4a6                	sd	s1,104(sp)
     5b4:	f0ca                	sd	s2,96(sp)
     5b6:	ecce                	sd	s3,88(sp)
     5b8:	e8d2                	sd	s4,80(sp)
     5ba:	e4d6                	sd	s5,72(sp)
     5bc:	e0da                	sd	s6,64(sp)
     5be:	0100                	addi	s0,sp,128
  uint64 addrs[] = { 0LL, 0x80000000LL, 0x3fffffe000, 0x3ffffff000, 0x4000000000,
     5c0:	00007797          	auipc	a5,0x7
     5c4:	0c078793          	addi	a5,a5,192 # 7680 <malloc+0x2562>
     5c8:	7788                	ld	a0,40(a5)
     5ca:	7b8c                	ld	a1,48(a5)
     5cc:	7f90                	ld	a2,56(a5)
     5ce:	63b4                	ld	a3,64(a5)
     5d0:	67b8                	ld	a4,72(a5)
     5d2:	6bbc                	ld	a5,80(a5)
     5d4:	f8a43823          	sd	a0,-112(s0)
     5d8:	f8b43c23          	sd	a1,-104(s0)
     5dc:	fac43023          	sd	a2,-96(s0)
     5e0:	fad43423          	sd	a3,-88(s0)
     5e4:	fae43823          	sd	a4,-80(s0)
     5e8:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
     5ec:	f9040913          	addi	s2,s0,-112
     5f0:	fc040b13          	addi	s6,s0,-64
    int fd = open("README", 0);
     5f4:	00005a17          	auipc	s4,0x5
     5f8:	e3ca0a13          	addi	s4,s4,-452 # 5430 <malloc+0x312>
    n = write(fds[1], "x", 1);
     5fc:	00005a97          	auipc	s5,0x5
     600:	ccca8a93          	addi	s5,s5,-820 # 52c8 <malloc+0x1aa>
    uint64 addr = addrs[ai];
     604:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     608:	4581                	li	a1,0
     60a:	8552                	mv	a0,s4
     60c:	674040ef          	jal	ra,4c80 <open>
     610:	84aa                	mv	s1,a0
    if(fd < 0){
     612:	06054763          	bltz	a0,680 <copyout+0xd4>
    int n = read(fd, (void*)addr, 8192);
     616:	6609                	lui	a2,0x2
     618:	85ce                	mv	a1,s3
     61a:	63e040ef          	jal	ra,4c58 <read>
    if(n > 0){
     61e:	06a04a63          	bgtz	a0,692 <copyout+0xe6>
    close(fd);
     622:	8526                	mv	a0,s1
     624:	644040ef          	jal	ra,4c68 <close>
    if(pipe(fds) < 0){
     628:	f8840513          	addi	a0,s0,-120
     62c:	624040ef          	jal	ra,4c50 <pipe>
     630:	06054c63          	bltz	a0,6a8 <copyout+0xfc>
    n = write(fds[1], "x", 1);
     634:	4605                	li	a2,1
     636:	85d6                	mv	a1,s5
     638:	f8c42503          	lw	a0,-116(s0)
     63c:	624040ef          	jal	ra,4c60 <write>
    if(n != 1){
     640:	4785                	li	a5,1
     642:	06f51c63          	bne	a0,a5,6ba <copyout+0x10e>
    n = read(fds[0], (void*)addr, 8192);
     646:	6609                	lui	a2,0x2
     648:	85ce                	mv	a1,s3
     64a:	f8842503          	lw	a0,-120(s0)
     64e:	60a040ef          	jal	ra,4c58 <read>
    if(n > 0){
     652:	06a04d63          	bgtz	a0,6cc <copyout+0x120>
    close(fds[0]);
     656:	f8842503          	lw	a0,-120(s0)
     65a:	60e040ef          	jal	ra,4c68 <close>
    close(fds[1]);
     65e:	f8c42503          	lw	a0,-116(s0)
     662:	606040ef          	jal	ra,4c68 <close>
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
     666:	0921                	addi	s2,s2,8
     668:	f9691ee3          	bne	s2,s6,604 <copyout+0x58>
}
     66c:	70e6                	ld	ra,120(sp)
     66e:	7446                	ld	s0,112(sp)
     670:	74a6                	ld	s1,104(sp)
     672:	7906                	ld	s2,96(sp)
     674:	69e6                	ld	s3,88(sp)
     676:	6a46                	ld	s4,80(sp)
     678:	6aa6                	ld	s5,72(sp)
     67a:	6b06                	ld	s6,64(sp)
     67c:	6109                	addi	sp,sp,128
     67e:	8082                	ret
      printf("open(README) failed\n");
     680:	00005517          	auipc	a0,0x5
     684:	db850513          	addi	a0,a0,-584 # 5438 <malloc+0x31a>
     688:	1dd040ef          	jal	ra,5064 <printf>
      exit(1);
     68c:	4505                	li	a0,1
     68e:	5b2040ef          	jal	ra,4c40 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", (void*)addr, n);
     692:	862a                	mv	a2,a0
     694:	85ce                	mv	a1,s3
     696:	00005517          	auipc	a0,0x5
     69a:	dba50513          	addi	a0,a0,-582 # 5450 <malloc+0x332>
     69e:	1c7040ef          	jal	ra,5064 <printf>
      exit(1);
     6a2:	4505                	li	a0,1
     6a4:	59c040ef          	jal	ra,4c40 <exit>
      printf("pipe() failed\n");
     6a8:	00005517          	auipc	a0,0x5
     6ac:	d4850513          	addi	a0,a0,-696 # 53f0 <malloc+0x2d2>
     6b0:	1b5040ef          	jal	ra,5064 <printf>
      exit(1);
     6b4:	4505                	li	a0,1
     6b6:	58a040ef          	jal	ra,4c40 <exit>
      printf("pipe write failed\n");
     6ba:	00005517          	auipc	a0,0x5
     6be:	dc650513          	addi	a0,a0,-570 # 5480 <malloc+0x362>
     6c2:	1a3040ef          	jal	ra,5064 <printf>
      exit(1);
     6c6:	4505                	li	a0,1
     6c8:	578040ef          	jal	ra,4c40 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", (void*)addr, n);
     6cc:	862a                	mv	a2,a0
     6ce:	85ce                	mv	a1,s3
     6d0:	00005517          	auipc	a0,0x5
     6d4:	dc850513          	addi	a0,a0,-568 # 5498 <malloc+0x37a>
     6d8:	18d040ef          	jal	ra,5064 <printf>
      exit(1);
     6dc:	4505                	li	a0,1
     6de:	562040ef          	jal	ra,4c40 <exit>

00000000000006e2 <truncate1>:
{
     6e2:	711d                	addi	sp,sp,-96
     6e4:	ec86                	sd	ra,88(sp)
     6e6:	e8a2                	sd	s0,80(sp)
     6e8:	e4a6                	sd	s1,72(sp)
     6ea:	e0ca                	sd	s2,64(sp)
     6ec:	fc4e                	sd	s3,56(sp)
     6ee:	f852                	sd	s4,48(sp)
     6f0:	f456                	sd	s5,40(sp)
     6f2:	1080                	addi	s0,sp,96
     6f4:	8aaa                	mv	s5,a0
  unlink("truncfile");
     6f6:	00005517          	auipc	a0,0x5
     6fa:	bba50513          	addi	a0,a0,-1094 # 52b0 <malloc+0x192>
     6fe:	592040ef          	jal	ra,4c90 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     702:	60100593          	li	a1,1537
     706:	00005517          	auipc	a0,0x5
     70a:	baa50513          	addi	a0,a0,-1110 # 52b0 <malloc+0x192>
     70e:	572040ef          	jal	ra,4c80 <open>
     712:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     714:	4611                	li	a2,4
     716:	00005597          	auipc	a1,0x5
     71a:	baa58593          	addi	a1,a1,-1110 # 52c0 <malloc+0x1a2>
     71e:	542040ef          	jal	ra,4c60 <write>
  close(fd1);
     722:	8526                	mv	a0,s1
     724:	544040ef          	jal	ra,4c68 <close>
  int fd2 = open("truncfile", O_RDONLY);
     728:	4581                	li	a1,0
     72a:	00005517          	auipc	a0,0x5
     72e:	b8650513          	addi	a0,a0,-1146 # 52b0 <malloc+0x192>
     732:	54e040ef          	jal	ra,4c80 <open>
     736:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     738:	02000613          	li	a2,32
     73c:	fa040593          	addi	a1,s0,-96
     740:	518040ef          	jal	ra,4c58 <read>
  if(n != 4){
     744:	4791                	li	a5,4
     746:	0af51863          	bne	a0,a5,7f6 <truncate1+0x114>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     74a:	40100593          	li	a1,1025
     74e:	00005517          	auipc	a0,0x5
     752:	b6250513          	addi	a0,a0,-1182 # 52b0 <malloc+0x192>
     756:	52a040ef          	jal	ra,4c80 <open>
     75a:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     75c:	4581                	li	a1,0
     75e:	00005517          	auipc	a0,0x5
     762:	b5250513          	addi	a0,a0,-1198 # 52b0 <malloc+0x192>
     766:	51a040ef          	jal	ra,4c80 <open>
     76a:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     76c:	02000613          	li	a2,32
     770:	fa040593          	addi	a1,s0,-96
     774:	4e4040ef          	jal	ra,4c58 <read>
     778:	8a2a                	mv	s4,a0
  if(n != 0){
     77a:	e949                	bnez	a0,80c <truncate1+0x12a>
  n = read(fd2, buf, sizeof(buf));
     77c:	02000613          	li	a2,32
     780:	fa040593          	addi	a1,s0,-96
     784:	8526                	mv	a0,s1
     786:	4d2040ef          	jal	ra,4c58 <read>
     78a:	8a2a                	mv	s4,a0
  if(n != 0){
     78c:	e155                	bnez	a0,830 <truncate1+0x14e>
  write(fd1, "abcdef", 6);
     78e:	4619                	li	a2,6
     790:	00005597          	auipc	a1,0x5
     794:	d9858593          	addi	a1,a1,-616 # 5528 <malloc+0x40a>
     798:	854e                	mv	a0,s3
     79a:	4c6040ef          	jal	ra,4c60 <write>
  n = read(fd3, buf, sizeof(buf));
     79e:	02000613          	li	a2,32
     7a2:	fa040593          	addi	a1,s0,-96
     7a6:	854a                	mv	a0,s2
     7a8:	4b0040ef          	jal	ra,4c58 <read>
  if(n != 6){
     7ac:	4799                	li	a5,6
     7ae:	0af51363          	bne	a0,a5,854 <truncate1+0x172>
  n = read(fd2, buf, sizeof(buf));
     7b2:	02000613          	li	a2,32
     7b6:	fa040593          	addi	a1,s0,-96
     7ba:	8526                	mv	a0,s1
     7bc:	49c040ef          	jal	ra,4c58 <read>
  if(n != 2){
     7c0:	4789                	li	a5,2
     7c2:	0af51463          	bne	a0,a5,86a <truncate1+0x188>
  unlink("truncfile");
     7c6:	00005517          	auipc	a0,0x5
     7ca:	aea50513          	addi	a0,a0,-1302 # 52b0 <malloc+0x192>
     7ce:	4c2040ef          	jal	ra,4c90 <unlink>
  close(fd1);
     7d2:	854e                	mv	a0,s3
     7d4:	494040ef          	jal	ra,4c68 <close>
  close(fd2);
     7d8:	8526                	mv	a0,s1
     7da:	48e040ef          	jal	ra,4c68 <close>
  close(fd3);
     7de:	854a                	mv	a0,s2
     7e0:	488040ef          	jal	ra,4c68 <close>
}
     7e4:	60e6                	ld	ra,88(sp)
     7e6:	6446                	ld	s0,80(sp)
     7e8:	64a6                	ld	s1,72(sp)
     7ea:	6906                	ld	s2,64(sp)
     7ec:	79e2                	ld	s3,56(sp)
     7ee:	7a42                	ld	s4,48(sp)
     7f0:	7aa2                	ld	s5,40(sp)
     7f2:	6125                	addi	sp,sp,96
     7f4:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     7f6:	862a                	mv	a2,a0
     7f8:	85d6                	mv	a1,s5
     7fa:	00005517          	auipc	a0,0x5
     7fe:	cce50513          	addi	a0,a0,-818 # 54c8 <malloc+0x3aa>
     802:	063040ef          	jal	ra,5064 <printf>
    exit(1);
     806:	4505                	li	a0,1
     808:	438040ef          	jal	ra,4c40 <exit>
    printf("aaa fd3=%d\n", fd3);
     80c:	85ca                	mv	a1,s2
     80e:	00005517          	auipc	a0,0x5
     812:	cda50513          	addi	a0,a0,-806 # 54e8 <malloc+0x3ca>
     816:	04f040ef          	jal	ra,5064 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     81a:	8652                	mv	a2,s4
     81c:	85d6                	mv	a1,s5
     81e:	00005517          	auipc	a0,0x5
     822:	cda50513          	addi	a0,a0,-806 # 54f8 <malloc+0x3da>
     826:	03f040ef          	jal	ra,5064 <printf>
    exit(1);
     82a:	4505                	li	a0,1
     82c:	414040ef          	jal	ra,4c40 <exit>
    printf("bbb fd2=%d\n", fd2);
     830:	85a6                	mv	a1,s1
     832:	00005517          	auipc	a0,0x5
     836:	ce650513          	addi	a0,a0,-794 # 5518 <malloc+0x3fa>
     83a:	02b040ef          	jal	ra,5064 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     83e:	8652                	mv	a2,s4
     840:	85d6                	mv	a1,s5
     842:	00005517          	auipc	a0,0x5
     846:	cb650513          	addi	a0,a0,-842 # 54f8 <malloc+0x3da>
     84a:	01b040ef          	jal	ra,5064 <printf>
    exit(1);
     84e:	4505                	li	a0,1
     850:	3f0040ef          	jal	ra,4c40 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     854:	862a                	mv	a2,a0
     856:	85d6                	mv	a1,s5
     858:	00005517          	auipc	a0,0x5
     85c:	cd850513          	addi	a0,a0,-808 # 5530 <malloc+0x412>
     860:	005040ef          	jal	ra,5064 <printf>
    exit(1);
     864:	4505                	li	a0,1
     866:	3da040ef          	jal	ra,4c40 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     86a:	862a                	mv	a2,a0
     86c:	85d6                	mv	a1,s5
     86e:	00005517          	auipc	a0,0x5
     872:	ce250513          	addi	a0,a0,-798 # 5550 <malloc+0x432>
     876:	7ee040ef          	jal	ra,5064 <printf>
    exit(1);
     87a:	4505                	li	a0,1
     87c:	3c4040ef          	jal	ra,4c40 <exit>

0000000000000880 <writetest>:
{
     880:	7139                	addi	sp,sp,-64
     882:	fc06                	sd	ra,56(sp)
     884:	f822                	sd	s0,48(sp)
     886:	f426                	sd	s1,40(sp)
     888:	f04a                	sd	s2,32(sp)
     88a:	ec4e                	sd	s3,24(sp)
     88c:	e852                	sd	s4,16(sp)
     88e:	e456                	sd	s5,8(sp)
     890:	e05a                	sd	s6,0(sp)
     892:	0080                	addi	s0,sp,64
     894:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     896:	20200593          	li	a1,514
     89a:	00005517          	auipc	a0,0x5
     89e:	cd650513          	addi	a0,a0,-810 # 5570 <malloc+0x452>
     8a2:	3de040ef          	jal	ra,4c80 <open>
  if(fd < 0){
     8a6:	08054f63          	bltz	a0,944 <writetest+0xc4>
     8aa:	892a                	mv	s2,a0
     8ac:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     8ae:	00005997          	auipc	s3,0x5
     8b2:	cea98993          	addi	s3,s3,-790 # 5598 <malloc+0x47a>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     8b6:	00005a97          	auipc	s5,0x5
     8ba:	d1aa8a93          	addi	s5,s5,-742 # 55d0 <malloc+0x4b2>
  for(i = 0; i < N; i++){
     8be:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     8c2:	4629                	li	a2,10
     8c4:	85ce                	mv	a1,s3
     8c6:	854a                	mv	a0,s2
     8c8:	398040ef          	jal	ra,4c60 <write>
     8cc:	47a9                	li	a5,10
     8ce:	08f51563          	bne	a0,a5,958 <writetest+0xd8>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     8d2:	4629                	li	a2,10
     8d4:	85d6                	mv	a1,s5
     8d6:	854a                	mv	a0,s2
     8d8:	388040ef          	jal	ra,4c60 <write>
     8dc:	47a9                	li	a5,10
     8de:	08f51863          	bne	a0,a5,96e <writetest+0xee>
  for(i = 0; i < N; i++){
     8e2:	2485                	addiw	s1,s1,1
     8e4:	fd449fe3          	bne	s1,s4,8c2 <writetest+0x42>
  close(fd);
     8e8:	854a                	mv	a0,s2
     8ea:	37e040ef          	jal	ra,4c68 <close>
  fd = open("small", O_RDONLY);
     8ee:	4581                	li	a1,0
     8f0:	00005517          	auipc	a0,0x5
     8f4:	c8050513          	addi	a0,a0,-896 # 5570 <malloc+0x452>
     8f8:	388040ef          	jal	ra,4c80 <open>
     8fc:	84aa                	mv	s1,a0
  if(fd < 0){
     8fe:	08054363          	bltz	a0,984 <writetest+0x104>
  i = read(fd, buf, N*SZ*2);
     902:	7d000613          	li	a2,2000
     906:	0000b597          	auipc	a1,0xb
     90a:	3a258593          	addi	a1,a1,930 # bca8 <buf>
     90e:	34a040ef          	jal	ra,4c58 <read>
  if(i != N*SZ*2){
     912:	7d000793          	li	a5,2000
     916:	08f51163          	bne	a0,a5,998 <writetest+0x118>
  close(fd);
     91a:	8526                	mv	a0,s1
     91c:	34c040ef          	jal	ra,4c68 <close>
  if(unlink("small") < 0){
     920:	00005517          	auipc	a0,0x5
     924:	c5050513          	addi	a0,a0,-944 # 5570 <malloc+0x452>
     928:	368040ef          	jal	ra,4c90 <unlink>
     92c:	08054063          	bltz	a0,9ac <writetest+0x12c>
}
     930:	70e2                	ld	ra,56(sp)
     932:	7442                	ld	s0,48(sp)
     934:	74a2                	ld	s1,40(sp)
     936:	7902                	ld	s2,32(sp)
     938:	69e2                	ld	s3,24(sp)
     93a:	6a42                	ld	s4,16(sp)
     93c:	6aa2                	ld	s5,8(sp)
     93e:	6b02                	ld	s6,0(sp)
     940:	6121                	addi	sp,sp,64
     942:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     944:	85da                	mv	a1,s6
     946:	00005517          	auipc	a0,0x5
     94a:	c3250513          	addi	a0,a0,-974 # 5578 <malloc+0x45a>
     94e:	716040ef          	jal	ra,5064 <printf>
    exit(1);
     952:	4505                	li	a0,1
     954:	2ec040ef          	jal	ra,4c40 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     958:	8626                	mv	a2,s1
     95a:	85da                	mv	a1,s6
     95c:	00005517          	auipc	a0,0x5
     960:	c4c50513          	addi	a0,a0,-948 # 55a8 <malloc+0x48a>
     964:	700040ef          	jal	ra,5064 <printf>
      exit(1);
     968:	4505                	li	a0,1
     96a:	2d6040ef          	jal	ra,4c40 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     96e:	8626                	mv	a2,s1
     970:	85da                	mv	a1,s6
     972:	00005517          	auipc	a0,0x5
     976:	c6e50513          	addi	a0,a0,-914 # 55e0 <malloc+0x4c2>
     97a:	6ea040ef          	jal	ra,5064 <printf>
      exit(1);
     97e:	4505                	li	a0,1
     980:	2c0040ef          	jal	ra,4c40 <exit>
    printf("%s: error: open small failed!\n", s);
     984:	85da                	mv	a1,s6
     986:	00005517          	auipc	a0,0x5
     98a:	c8250513          	addi	a0,a0,-894 # 5608 <malloc+0x4ea>
     98e:	6d6040ef          	jal	ra,5064 <printf>
    exit(1);
     992:	4505                	li	a0,1
     994:	2ac040ef          	jal	ra,4c40 <exit>
    printf("%s: read failed\n", s);
     998:	85da                	mv	a1,s6
     99a:	00005517          	auipc	a0,0x5
     99e:	c8e50513          	addi	a0,a0,-882 # 5628 <malloc+0x50a>
     9a2:	6c2040ef          	jal	ra,5064 <printf>
    exit(1);
     9a6:	4505                	li	a0,1
     9a8:	298040ef          	jal	ra,4c40 <exit>
    printf("%s: unlink small failed\n", s);
     9ac:	85da                	mv	a1,s6
     9ae:	00005517          	auipc	a0,0x5
     9b2:	c9250513          	addi	a0,a0,-878 # 5640 <malloc+0x522>
     9b6:	6ae040ef          	jal	ra,5064 <printf>
    exit(1);
     9ba:	4505                	li	a0,1
     9bc:	284040ef          	jal	ra,4c40 <exit>

00000000000009c0 <writebig>:
{
     9c0:	7139                	addi	sp,sp,-64
     9c2:	fc06                	sd	ra,56(sp)
     9c4:	f822                	sd	s0,48(sp)
     9c6:	f426                	sd	s1,40(sp)
     9c8:	f04a                	sd	s2,32(sp)
     9ca:	ec4e                	sd	s3,24(sp)
     9cc:	e852                	sd	s4,16(sp)
     9ce:	e456                	sd	s5,8(sp)
     9d0:	0080                	addi	s0,sp,64
     9d2:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     9d4:	20200593          	li	a1,514
     9d8:	00005517          	auipc	a0,0x5
     9dc:	c8850513          	addi	a0,a0,-888 # 5660 <malloc+0x542>
     9e0:	2a0040ef          	jal	ra,4c80 <open>
     9e4:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     9e6:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     9e8:	0000b917          	auipc	s2,0xb
     9ec:	2c090913          	addi	s2,s2,704 # bca8 <buf>
  for(i = 0; i < MAXFILE; i++){
     9f0:	10c00a13          	li	s4,268
  if(fd < 0){
     9f4:	06054463          	bltz	a0,a5c <writebig+0x9c>
    ((int*)buf)[0] = i;
     9f8:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     9fc:	40000613          	li	a2,1024
     a00:	85ca                	mv	a1,s2
     a02:	854e                	mv	a0,s3
     a04:	25c040ef          	jal	ra,4c60 <write>
     a08:	40000793          	li	a5,1024
     a0c:	06f51263          	bne	a0,a5,a70 <writebig+0xb0>
  for(i = 0; i < MAXFILE; i++){
     a10:	2485                	addiw	s1,s1,1
     a12:	ff4493e3          	bne	s1,s4,9f8 <writebig+0x38>
  close(fd);
     a16:	854e                	mv	a0,s3
     a18:	250040ef          	jal	ra,4c68 <close>
  fd = open("big", O_RDONLY);
     a1c:	4581                	li	a1,0
     a1e:	00005517          	auipc	a0,0x5
     a22:	c4250513          	addi	a0,a0,-958 # 5660 <malloc+0x542>
     a26:	25a040ef          	jal	ra,4c80 <open>
     a2a:	89aa                	mv	s3,a0
  n = 0;
     a2c:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     a2e:	0000b917          	auipc	s2,0xb
     a32:	27a90913          	addi	s2,s2,634 # bca8 <buf>
  if(fd < 0){
     a36:	04054863          	bltz	a0,a86 <writebig+0xc6>
    i = read(fd, buf, BSIZE);
     a3a:	40000613          	li	a2,1024
     a3e:	85ca                	mv	a1,s2
     a40:	854e                	mv	a0,s3
     a42:	216040ef          	jal	ra,4c58 <read>
    if(i == 0){
     a46:	c931                	beqz	a0,a9a <writebig+0xda>
    } else if(i != BSIZE){
     a48:	40000793          	li	a5,1024
     a4c:	08f51a63          	bne	a0,a5,ae0 <writebig+0x120>
    if(((int*)buf)[0] != n){
     a50:	00092683          	lw	a3,0(s2)
     a54:	0a969163          	bne	a3,s1,af6 <writebig+0x136>
    n++;
     a58:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     a5a:	b7c5                	j	a3a <writebig+0x7a>
    printf("%s: error: creat big failed!\n", s);
     a5c:	85d6                	mv	a1,s5
     a5e:	00005517          	auipc	a0,0x5
     a62:	c0a50513          	addi	a0,a0,-1014 # 5668 <malloc+0x54a>
     a66:	5fe040ef          	jal	ra,5064 <printf>
    exit(1);
     a6a:	4505                	li	a0,1
     a6c:	1d4040ef          	jal	ra,4c40 <exit>
      printf("%s: error: write big file failed i=%d\n", s, i);
     a70:	8626                	mv	a2,s1
     a72:	85d6                	mv	a1,s5
     a74:	00005517          	auipc	a0,0x5
     a78:	c1450513          	addi	a0,a0,-1004 # 5688 <malloc+0x56a>
     a7c:	5e8040ef          	jal	ra,5064 <printf>
      exit(1);
     a80:	4505                	li	a0,1
     a82:	1be040ef          	jal	ra,4c40 <exit>
    printf("%s: error: open big failed!\n", s);
     a86:	85d6                	mv	a1,s5
     a88:	00005517          	auipc	a0,0x5
     a8c:	c2850513          	addi	a0,a0,-984 # 56b0 <malloc+0x592>
     a90:	5d4040ef          	jal	ra,5064 <printf>
    exit(1);
     a94:	4505                	li	a0,1
     a96:	1aa040ef          	jal	ra,4c40 <exit>
      if(n != MAXFILE){
     a9a:	10c00793          	li	a5,268
     a9e:	02f49663          	bne	s1,a5,aca <writebig+0x10a>
  close(fd);
     aa2:	854e                	mv	a0,s3
     aa4:	1c4040ef          	jal	ra,4c68 <close>
  if(unlink("big") < 0){
     aa8:	00005517          	auipc	a0,0x5
     aac:	bb850513          	addi	a0,a0,-1096 # 5660 <malloc+0x542>
     ab0:	1e0040ef          	jal	ra,4c90 <unlink>
     ab4:	04054c63          	bltz	a0,b0c <writebig+0x14c>
}
     ab8:	70e2                	ld	ra,56(sp)
     aba:	7442                	ld	s0,48(sp)
     abc:	74a2                	ld	s1,40(sp)
     abe:	7902                	ld	s2,32(sp)
     ac0:	69e2                	ld	s3,24(sp)
     ac2:	6a42                	ld	s4,16(sp)
     ac4:	6aa2                	ld	s5,8(sp)
     ac6:	6121                	addi	sp,sp,64
     ac8:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     aca:	8626                	mv	a2,s1
     acc:	85d6                	mv	a1,s5
     ace:	00005517          	auipc	a0,0x5
     ad2:	c0250513          	addi	a0,a0,-1022 # 56d0 <malloc+0x5b2>
     ad6:	58e040ef          	jal	ra,5064 <printf>
        exit(1);
     ada:	4505                	li	a0,1
     adc:	164040ef          	jal	ra,4c40 <exit>
      printf("%s: read failed %d\n", s, i);
     ae0:	862a                	mv	a2,a0
     ae2:	85d6                	mv	a1,s5
     ae4:	00005517          	auipc	a0,0x5
     ae8:	c1450513          	addi	a0,a0,-1004 # 56f8 <malloc+0x5da>
     aec:	578040ef          	jal	ra,5064 <printf>
      exit(1);
     af0:	4505                	li	a0,1
     af2:	14e040ef          	jal	ra,4c40 <exit>
      printf("%s: read content of block %d is %d\n", s,
     af6:	8626                	mv	a2,s1
     af8:	85d6                	mv	a1,s5
     afa:	00005517          	auipc	a0,0x5
     afe:	c1650513          	addi	a0,a0,-1002 # 5710 <malloc+0x5f2>
     b02:	562040ef          	jal	ra,5064 <printf>
      exit(1);
     b06:	4505                	li	a0,1
     b08:	138040ef          	jal	ra,4c40 <exit>
    printf("%s: unlink big failed\n", s);
     b0c:	85d6                	mv	a1,s5
     b0e:	00005517          	auipc	a0,0x5
     b12:	c2a50513          	addi	a0,a0,-982 # 5738 <malloc+0x61a>
     b16:	54e040ef          	jal	ra,5064 <printf>
    exit(1);
     b1a:	4505                	li	a0,1
     b1c:	124040ef          	jal	ra,4c40 <exit>

0000000000000b20 <unlinkread>:
{
     b20:	7179                	addi	sp,sp,-48
     b22:	f406                	sd	ra,40(sp)
     b24:	f022                	sd	s0,32(sp)
     b26:	ec26                	sd	s1,24(sp)
     b28:	e84a                	sd	s2,16(sp)
     b2a:	e44e                	sd	s3,8(sp)
     b2c:	1800                	addi	s0,sp,48
     b2e:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     b30:	20200593          	li	a1,514
     b34:	00005517          	auipc	a0,0x5
     b38:	c1c50513          	addi	a0,a0,-996 # 5750 <malloc+0x632>
     b3c:	144040ef          	jal	ra,4c80 <open>
  if(fd < 0){
     b40:	0a054f63          	bltz	a0,bfe <unlinkread+0xde>
     b44:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     b46:	4615                	li	a2,5
     b48:	00005597          	auipc	a1,0x5
     b4c:	c3858593          	addi	a1,a1,-968 # 5780 <malloc+0x662>
     b50:	110040ef          	jal	ra,4c60 <write>
  close(fd);
     b54:	8526                	mv	a0,s1
     b56:	112040ef          	jal	ra,4c68 <close>
  fd = open("unlinkread", O_RDWR);
     b5a:	4589                	li	a1,2
     b5c:	00005517          	auipc	a0,0x5
     b60:	bf450513          	addi	a0,a0,-1036 # 5750 <malloc+0x632>
     b64:	11c040ef          	jal	ra,4c80 <open>
     b68:	84aa                	mv	s1,a0
  if(fd < 0){
     b6a:	0a054463          	bltz	a0,c12 <unlinkread+0xf2>
  if(unlink("unlinkread") != 0){
     b6e:	00005517          	auipc	a0,0x5
     b72:	be250513          	addi	a0,a0,-1054 # 5750 <malloc+0x632>
     b76:	11a040ef          	jal	ra,4c90 <unlink>
     b7a:	e555                	bnez	a0,c26 <unlinkread+0x106>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     b7c:	20200593          	li	a1,514
     b80:	00005517          	auipc	a0,0x5
     b84:	bd050513          	addi	a0,a0,-1072 # 5750 <malloc+0x632>
     b88:	0f8040ef          	jal	ra,4c80 <open>
     b8c:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     b8e:	460d                	li	a2,3
     b90:	00005597          	auipc	a1,0x5
     b94:	c3858593          	addi	a1,a1,-968 # 57c8 <malloc+0x6aa>
     b98:	0c8040ef          	jal	ra,4c60 <write>
  close(fd1);
     b9c:	854a                	mv	a0,s2
     b9e:	0ca040ef          	jal	ra,4c68 <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     ba2:	660d                	lui	a2,0x3
     ba4:	0000b597          	auipc	a1,0xb
     ba8:	10458593          	addi	a1,a1,260 # bca8 <buf>
     bac:	8526                	mv	a0,s1
     bae:	0aa040ef          	jal	ra,4c58 <read>
     bb2:	4795                	li	a5,5
     bb4:	08f51363          	bne	a0,a5,c3a <unlinkread+0x11a>
  if(buf[0] != 'h'){
     bb8:	0000b717          	auipc	a4,0xb
     bbc:	0f074703          	lbu	a4,240(a4) # bca8 <buf>
     bc0:	06800793          	li	a5,104
     bc4:	08f71563          	bne	a4,a5,c4e <unlinkread+0x12e>
  if(write(fd, buf, 10) != 10){
     bc8:	4629                	li	a2,10
     bca:	0000b597          	auipc	a1,0xb
     bce:	0de58593          	addi	a1,a1,222 # bca8 <buf>
     bd2:	8526                	mv	a0,s1
     bd4:	08c040ef          	jal	ra,4c60 <write>
     bd8:	47a9                	li	a5,10
     bda:	08f51463          	bne	a0,a5,c62 <unlinkread+0x142>
  close(fd);
     bde:	8526                	mv	a0,s1
     be0:	088040ef          	jal	ra,4c68 <close>
  unlink("unlinkread");
     be4:	00005517          	auipc	a0,0x5
     be8:	b6c50513          	addi	a0,a0,-1172 # 5750 <malloc+0x632>
     bec:	0a4040ef          	jal	ra,4c90 <unlink>
}
     bf0:	70a2                	ld	ra,40(sp)
     bf2:	7402                	ld	s0,32(sp)
     bf4:	64e2                	ld	s1,24(sp)
     bf6:	6942                	ld	s2,16(sp)
     bf8:	69a2                	ld	s3,8(sp)
     bfa:	6145                	addi	sp,sp,48
     bfc:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     bfe:	85ce                	mv	a1,s3
     c00:	00005517          	auipc	a0,0x5
     c04:	b6050513          	addi	a0,a0,-1184 # 5760 <malloc+0x642>
     c08:	45c040ef          	jal	ra,5064 <printf>
    exit(1);
     c0c:	4505                	li	a0,1
     c0e:	032040ef          	jal	ra,4c40 <exit>
    printf("%s: open unlinkread failed\n", s);
     c12:	85ce                	mv	a1,s3
     c14:	00005517          	auipc	a0,0x5
     c18:	b7450513          	addi	a0,a0,-1164 # 5788 <malloc+0x66a>
     c1c:	448040ef          	jal	ra,5064 <printf>
    exit(1);
     c20:	4505                	li	a0,1
     c22:	01e040ef          	jal	ra,4c40 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     c26:	85ce                	mv	a1,s3
     c28:	00005517          	auipc	a0,0x5
     c2c:	b8050513          	addi	a0,a0,-1152 # 57a8 <malloc+0x68a>
     c30:	434040ef          	jal	ra,5064 <printf>
    exit(1);
     c34:	4505                	li	a0,1
     c36:	00a040ef          	jal	ra,4c40 <exit>
    printf("%s: unlinkread read failed", s);
     c3a:	85ce                	mv	a1,s3
     c3c:	00005517          	auipc	a0,0x5
     c40:	b9450513          	addi	a0,a0,-1132 # 57d0 <malloc+0x6b2>
     c44:	420040ef          	jal	ra,5064 <printf>
    exit(1);
     c48:	4505                	li	a0,1
     c4a:	7f7030ef          	jal	ra,4c40 <exit>
    printf("%s: unlinkread wrong data\n", s);
     c4e:	85ce                	mv	a1,s3
     c50:	00005517          	auipc	a0,0x5
     c54:	ba050513          	addi	a0,a0,-1120 # 57f0 <malloc+0x6d2>
     c58:	40c040ef          	jal	ra,5064 <printf>
    exit(1);
     c5c:	4505                	li	a0,1
     c5e:	7e3030ef          	jal	ra,4c40 <exit>
    printf("%s: unlinkread write failed\n", s);
     c62:	85ce                	mv	a1,s3
     c64:	00005517          	auipc	a0,0x5
     c68:	bac50513          	addi	a0,a0,-1108 # 5810 <malloc+0x6f2>
     c6c:	3f8040ef          	jal	ra,5064 <printf>
    exit(1);
     c70:	4505                	li	a0,1
     c72:	7cf030ef          	jal	ra,4c40 <exit>

0000000000000c76 <linktest>:
{
     c76:	1101                	addi	sp,sp,-32
     c78:	ec06                	sd	ra,24(sp)
     c7a:	e822                	sd	s0,16(sp)
     c7c:	e426                	sd	s1,8(sp)
     c7e:	e04a                	sd	s2,0(sp)
     c80:	1000                	addi	s0,sp,32
     c82:	892a                	mv	s2,a0
  unlink("lf1");
     c84:	00005517          	auipc	a0,0x5
     c88:	bac50513          	addi	a0,a0,-1108 # 5830 <malloc+0x712>
     c8c:	004040ef          	jal	ra,4c90 <unlink>
  unlink("lf2");
     c90:	00005517          	auipc	a0,0x5
     c94:	ba850513          	addi	a0,a0,-1112 # 5838 <malloc+0x71a>
     c98:	7f9030ef          	jal	ra,4c90 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     c9c:	20200593          	li	a1,514
     ca0:	00005517          	auipc	a0,0x5
     ca4:	b9050513          	addi	a0,a0,-1136 # 5830 <malloc+0x712>
     ca8:	7d9030ef          	jal	ra,4c80 <open>
  if(fd < 0){
     cac:	0c054f63          	bltz	a0,d8a <linktest+0x114>
     cb0:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     cb2:	4615                	li	a2,5
     cb4:	00005597          	auipc	a1,0x5
     cb8:	acc58593          	addi	a1,a1,-1332 # 5780 <malloc+0x662>
     cbc:	7a5030ef          	jal	ra,4c60 <write>
     cc0:	4795                	li	a5,5
     cc2:	0cf51e63          	bne	a0,a5,d9e <linktest+0x128>
  close(fd);
     cc6:	8526                	mv	a0,s1
     cc8:	7a1030ef          	jal	ra,4c68 <close>
  if(link("lf1", "lf2") < 0){
     ccc:	00005597          	auipc	a1,0x5
     cd0:	b6c58593          	addi	a1,a1,-1172 # 5838 <malloc+0x71a>
     cd4:	00005517          	auipc	a0,0x5
     cd8:	b5c50513          	addi	a0,a0,-1188 # 5830 <malloc+0x712>
     cdc:	7c5030ef          	jal	ra,4ca0 <link>
     ce0:	0c054963          	bltz	a0,db2 <linktest+0x13c>
  unlink("lf1");
     ce4:	00005517          	auipc	a0,0x5
     ce8:	b4c50513          	addi	a0,a0,-1204 # 5830 <malloc+0x712>
     cec:	7a5030ef          	jal	ra,4c90 <unlink>
  if(open("lf1", 0) >= 0){
     cf0:	4581                	li	a1,0
     cf2:	00005517          	auipc	a0,0x5
     cf6:	b3e50513          	addi	a0,a0,-1218 # 5830 <malloc+0x712>
     cfa:	787030ef          	jal	ra,4c80 <open>
     cfe:	0c055463          	bgez	a0,dc6 <linktest+0x150>
  fd = open("lf2", 0);
     d02:	4581                	li	a1,0
     d04:	00005517          	auipc	a0,0x5
     d08:	b3450513          	addi	a0,a0,-1228 # 5838 <malloc+0x71a>
     d0c:	775030ef          	jal	ra,4c80 <open>
     d10:	84aa                	mv	s1,a0
  if(fd < 0){
     d12:	0c054463          	bltz	a0,dda <linktest+0x164>
  if(read(fd, buf, sizeof(buf)) != SZ){
     d16:	660d                	lui	a2,0x3
     d18:	0000b597          	auipc	a1,0xb
     d1c:	f9058593          	addi	a1,a1,-112 # bca8 <buf>
     d20:	739030ef          	jal	ra,4c58 <read>
     d24:	4795                	li	a5,5
     d26:	0cf51463          	bne	a0,a5,dee <linktest+0x178>
  close(fd);
     d2a:	8526                	mv	a0,s1
     d2c:	73d030ef          	jal	ra,4c68 <close>
  if(link("lf2", "lf2") >= 0){
     d30:	00005597          	auipc	a1,0x5
     d34:	b0858593          	addi	a1,a1,-1272 # 5838 <malloc+0x71a>
     d38:	852e                	mv	a0,a1
     d3a:	767030ef          	jal	ra,4ca0 <link>
     d3e:	0c055263          	bgez	a0,e02 <linktest+0x18c>
  unlink("lf2");
     d42:	00005517          	auipc	a0,0x5
     d46:	af650513          	addi	a0,a0,-1290 # 5838 <malloc+0x71a>
     d4a:	747030ef          	jal	ra,4c90 <unlink>
  if(link("lf2", "lf1") >= 0){
     d4e:	00005597          	auipc	a1,0x5
     d52:	ae258593          	addi	a1,a1,-1310 # 5830 <malloc+0x712>
     d56:	00005517          	auipc	a0,0x5
     d5a:	ae250513          	addi	a0,a0,-1310 # 5838 <malloc+0x71a>
     d5e:	743030ef          	jal	ra,4ca0 <link>
     d62:	0a055a63          	bgez	a0,e16 <linktest+0x1a0>
  if(link(".", "lf1") >= 0){
     d66:	00005597          	auipc	a1,0x5
     d6a:	aca58593          	addi	a1,a1,-1334 # 5830 <malloc+0x712>
     d6e:	00005517          	auipc	a0,0x5
     d72:	bd250513          	addi	a0,a0,-1070 # 5940 <malloc+0x822>
     d76:	72b030ef          	jal	ra,4ca0 <link>
     d7a:	0a055863          	bgez	a0,e2a <linktest+0x1b4>
}
     d7e:	60e2                	ld	ra,24(sp)
     d80:	6442                	ld	s0,16(sp)
     d82:	64a2                	ld	s1,8(sp)
     d84:	6902                	ld	s2,0(sp)
     d86:	6105                	addi	sp,sp,32
     d88:	8082                	ret
    printf("%s: create lf1 failed\n", s);
     d8a:	85ca                	mv	a1,s2
     d8c:	00005517          	auipc	a0,0x5
     d90:	ab450513          	addi	a0,a0,-1356 # 5840 <malloc+0x722>
     d94:	2d0040ef          	jal	ra,5064 <printf>
    exit(1);
     d98:	4505                	li	a0,1
     d9a:	6a7030ef          	jal	ra,4c40 <exit>
    printf("%s: write lf1 failed\n", s);
     d9e:	85ca                	mv	a1,s2
     da0:	00005517          	auipc	a0,0x5
     da4:	ab850513          	addi	a0,a0,-1352 # 5858 <malloc+0x73a>
     da8:	2bc040ef          	jal	ra,5064 <printf>
    exit(1);
     dac:	4505                	li	a0,1
     dae:	693030ef          	jal	ra,4c40 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
     db2:	85ca                	mv	a1,s2
     db4:	00005517          	auipc	a0,0x5
     db8:	abc50513          	addi	a0,a0,-1348 # 5870 <malloc+0x752>
     dbc:	2a8040ef          	jal	ra,5064 <printf>
    exit(1);
     dc0:	4505                	li	a0,1
     dc2:	67f030ef          	jal	ra,4c40 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
     dc6:	85ca                	mv	a1,s2
     dc8:	00005517          	auipc	a0,0x5
     dcc:	ac850513          	addi	a0,a0,-1336 # 5890 <malloc+0x772>
     dd0:	294040ef          	jal	ra,5064 <printf>
    exit(1);
     dd4:	4505                	li	a0,1
     dd6:	66b030ef          	jal	ra,4c40 <exit>
    printf("%s: open lf2 failed\n", s);
     dda:	85ca                	mv	a1,s2
     ddc:	00005517          	auipc	a0,0x5
     de0:	ae450513          	addi	a0,a0,-1308 # 58c0 <malloc+0x7a2>
     de4:	280040ef          	jal	ra,5064 <printf>
    exit(1);
     de8:	4505                	li	a0,1
     dea:	657030ef          	jal	ra,4c40 <exit>
    printf("%s: read lf2 failed\n", s);
     dee:	85ca                	mv	a1,s2
     df0:	00005517          	auipc	a0,0x5
     df4:	ae850513          	addi	a0,a0,-1304 # 58d8 <malloc+0x7ba>
     df8:	26c040ef          	jal	ra,5064 <printf>
    exit(1);
     dfc:	4505                	li	a0,1
     dfe:	643030ef          	jal	ra,4c40 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
     e02:	85ca                	mv	a1,s2
     e04:	00005517          	auipc	a0,0x5
     e08:	aec50513          	addi	a0,a0,-1300 # 58f0 <malloc+0x7d2>
     e0c:	258040ef          	jal	ra,5064 <printf>
    exit(1);
     e10:	4505                	li	a0,1
     e12:	62f030ef          	jal	ra,4c40 <exit>
    printf("%s: link non-existent succeeded! oops\n", s);
     e16:	85ca                	mv	a1,s2
     e18:	00005517          	auipc	a0,0x5
     e1c:	b0050513          	addi	a0,a0,-1280 # 5918 <malloc+0x7fa>
     e20:	244040ef          	jal	ra,5064 <printf>
    exit(1);
     e24:	4505                	li	a0,1
     e26:	61b030ef          	jal	ra,4c40 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
     e2a:	85ca                	mv	a1,s2
     e2c:	00005517          	auipc	a0,0x5
     e30:	b1c50513          	addi	a0,a0,-1252 # 5948 <malloc+0x82a>
     e34:	230040ef          	jal	ra,5064 <printf>
    exit(1);
     e38:	4505                	li	a0,1
     e3a:	607030ef          	jal	ra,4c40 <exit>

0000000000000e3e <validatetest>:
{
     e3e:	7139                	addi	sp,sp,-64
     e40:	fc06                	sd	ra,56(sp)
     e42:	f822                	sd	s0,48(sp)
     e44:	f426                	sd	s1,40(sp)
     e46:	f04a                	sd	s2,32(sp)
     e48:	ec4e                	sd	s3,24(sp)
     e4a:	e852                	sd	s4,16(sp)
     e4c:	e456                	sd	s5,8(sp)
     e4e:	e05a                	sd	s6,0(sp)
     e50:	0080                	addi	s0,sp,64
     e52:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
     e54:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
     e56:	00005997          	auipc	s3,0x5
     e5a:	b1298993          	addi	s3,s3,-1262 # 5968 <malloc+0x84a>
     e5e:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
     e60:	6a85                	lui	s5,0x1
     e62:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
     e66:	85a6                	mv	a1,s1
     e68:	854e                	mv	a0,s3
     e6a:	637030ef          	jal	ra,4ca0 <link>
     e6e:	01251f63          	bne	a0,s2,e8c <validatetest+0x4e>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
     e72:	94d6                	add	s1,s1,s5
     e74:	ff4499e3          	bne	s1,s4,e66 <validatetest+0x28>
}
     e78:	70e2                	ld	ra,56(sp)
     e7a:	7442                	ld	s0,48(sp)
     e7c:	74a2                	ld	s1,40(sp)
     e7e:	7902                	ld	s2,32(sp)
     e80:	69e2                	ld	s3,24(sp)
     e82:	6a42                	ld	s4,16(sp)
     e84:	6aa2                	ld	s5,8(sp)
     e86:	6b02                	ld	s6,0(sp)
     e88:	6121                	addi	sp,sp,64
     e8a:	8082                	ret
      printf("%s: link should not succeed\n", s);
     e8c:	85da                	mv	a1,s6
     e8e:	00005517          	auipc	a0,0x5
     e92:	aea50513          	addi	a0,a0,-1302 # 5978 <malloc+0x85a>
     e96:	1ce040ef          	jal	ra,5064 <printf>
      exit(1);
     e9a:	4505                	li	a0,1
     e9c:	5a5030ef          	jal	ra,4c40 <exit>

0000000000000ea0 <bigdir>:
{
     ea0:	715d                	addi	sp,sp,-80
     ea2:	e486                	sd	ra,72(sp)
     ea4:	e0a2                	sd	s0,64(sp)
     ea6:	fc26                	sd	s1,56(sp)
     ea8:	f84a                	sd	s2,48(sp)
     eaa:	f44e                	sd	s3,40(sp)
     eac:	f052                	sd	s4,32(sp)
     eae:	ec56                	sd	s5,24(sp)
     eb0:	e85a                	sd	s6,16(sp)
     eb2:	0880                	addi	s0,sp,80
     eb4:	89aa                	mv	s3,a0
  unlink("bd");
     eb6:	00005517          	auipc	a0,0x5
     eba:	ae250513          	addi	a0,a0,-1310 # 5998 <malloc+0x87a>
     ebe:	5d3030ef          	jal	ra,4c90 <unlink>
  fd = open("bd", O_CREATE);
     ec2:	20000593          	li	a1,512
     ec6:	00005517          	auipc	a0,0x5
     eca:	ad250513          	addi	a0,a0,-1326 # 5998 <malloc+0x87a>
     ece:	5b3030ef          	jal	ra,4c80 <open>
  if(fd < 0){
     ed2:	0c054163          	bltz	a0,f94 <bigdir+0xf4>
  close(fd);
     ed6:	593030ef          	jal	ra,4c68 <close>
  for(i = 0; i < N; i++){
     eda:	4901                	li	s2,0
    name[0] = 'x';
     edc:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
     ee0:	00005a17          	auipc	s4,0x5
     ee4:	ab8a0a13          	addi	s4,s4,-1352 # 5998 <malloc+0x87a>
  for(i = 0; i < N; i++){
     ee8:	1f400b13          	li	s6,500
    name[0] = 'x';
     eec:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
     ef0:	41f9579b          	sraiw	a5,s2,0x1f
     ef4:	01a7d71b          	srliw	a4,a5,0x1a
     ef8:	012707bb          	addw	a5,a4,s2
     efc:	4067d69b          	sraiw	a3,a5,0x6
     f00:	0306869b          	addiw	a3,a3,48
     f04:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     f08:	03f7f793          	andi	a5,a5,63
     f0c:	9f99                	subw	a5,a5,a4
     f0e:	0307879b          	addiw	a5,a5,48
     f12:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     f16:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
     f1a:	fb040593          	addi	a1,s0,-80
     f1e:	8552                	mv	a0,s4
     f20:	581030ef          	jal	ra,4ca0 <link>
     f24:	84aa                	mv	s1,a0
     f26:	e149                	bnez	a0,fa8 <bigdir+0x108>
  for(i = 0; i < N; i++){
     f28:	2905                	addiw	s2,s2,1
     f2a:	fd6911e3          	bne	s2,s6,eec <bigdir+0x4c>
  unlink("bd");
     f2e:	00005517          	auipc	a0,0x5
     f32:	a6a50513          	addi	a0,a0,-1430 # 5998 <malloc+0x87a>
     f36:	55b030ef          	jal	ra,4c90 <unlink>
    name[0] = 'x';
     f3a:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
     f3e:	1f400a13          	li	s4,500
    name[0] = 'x';
     f42:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
     f46:	41f4d79b          	sraiw	a5,s1,0x1f
     f4a:	01a7d71b          	srliw	a4,a5,0x1a
     f4e:	009707bb          	addw	a5,a4,s1
     f52:	4067d69b          	sraiw	a3,a5,0x6
     f56:	0306869b          	addiw	a3,a3,48
     f5a:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     f5e:	03f7f793          	andi	a5,a5,63
     f62:	9f99                	subw	a5,a5,a4
     f64:	0307879b          	addiw	a5,a5,48
     f68:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     f6c:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
     f70:	fb040513          	addi	a0,s0,-80
     f74:	51d030ef          	jal	ra,4c90 <unlink>
     f78:	e529                	bnez	a0,fc2 <bigdir+0x122>
  for(i = 0; i < N; i++){
     f7a:	2485                	addiw	s1,s1,1
     f7c:	fd4493e3          	bne	s1,s4,f42 <bigdir+0xa2>
}
     f80:	60a6                	ld	ra,72(sp)
     f82:	6406                	ld	s0,64(sp)
     f84:	74e2                	ld	s1,56(sp)
     f86:	7942                	ld	s2,48(sp)
     f88:	79a2                	ld	s3,40(sp)
     f8a:	7a02                	ld	s4,32(sp)
     f8c:	6ae2                	ld	s5,24(sp)
     f8e:	6b42                	ld	s6,16(sp)
     f90:	6161                	addi	sp,sp,80
     f92:	8082                	ret
    printf("%s: bigdir create failed\n", s);
     f94:	85ce                	mv	a1,s3
     f96:	00005517          	auipc	a0,0x5
     f9a:	a0a50513          	addi	a0,a0,-1526 # 59a0 <malloc+0x882>
     f9e:	0c6040ef          	jal	ra,5064 <printf>
    exit(1);
     fa2:	4505                	li	a0,1
     fa4:	49d030ef          	jal	ra,4c40 <exit>
      printf("%s: bigdir i=%d link(bd, %s) failed\n", s, i, name);
     fa8:	fb040693          	addi	a3,s0,-80
     fac:	864a                	mv	a2,s2
     fae:	85ce                	mv	a1,s3
     fb0:	00005517          	auipc	a0,0x5
     fb4:	a1050513          	addi	a0,a0,-1520 # 59c0 <malloc+0x8a2>
     fb8:	0ac040ef          	jal	ra,5064 <printf>
      exit(1);
     fbc:	4505                	li	a0,1
     fbe:	483030ef          	jal	ra,4c40 <exit>
      printf("%s: bigdir unlink failed", s);
     fc2:	85ce                	mv	a1,s3
     fc4:	00005517          	auipc	a0,0x5
     fc8:	a2450513          	addi	a0,a0,-1500 # 59e8 <malloc+0x8ca>
     fcc:	098040ef          	jal	ra,5064 <printf>
      exit(1);
     fd0:	4505                	li	a0,1
     fd2:	46f030ef          	jal	ra,4c40 <exit>

0000000000000fd6 <pgbug>:
{
     fd6:	7179                	addi	sp,sp,-48
     fd8:	f406                	sd	ra,40(sp)
     fda:	f022                	sd	s0,32(sp)
     fdc:	ec26                	sd	s1,24(sp)
     fde:	1800                	addi	s0,sp,48
  argv[0] = 0;
     fe0:	fc043c23          	sd	zero,-40(s0)
  exec(big, argv);
     fe4:	00007497          	auipc	s1,0x7
     fe8:	01c48493          	addi	s1,s1,28 # 8000 <big>
     fec:	fd840593          	addi	a1,s0,-40
     ff0:	6088                	ld	a0,0(s1)
     ff2:	487030ef          	jal	ra,4c78 <exec>
  pipe(big);
     ff6:	6088                	ld	a0,0(s1)
     ff8:	459030ef          	jal	ra,4c50 <pipe>
  exit(0);
     ffc:	4501                	li	a0,0
     ffe:	443030ef          	jal	ra,4c40 <exit>

0000000000001002 <badarg>:
{
    1002:	7139                	addi	sp,sp,-64
    1004:	fc06                	sd	ra,56(sp)
    1006:	f822                	sd	s0,48(sp)
    1008:	f426                	sd	s1,40(sp)
    100a:	f04a                	sd	s2,32(sp)
    100c:	ec4e                	sd	s3,24(sp)
    100e:	0080                	addi	s0,sp,64
    1010:	64b1                	lui	s1,0xc
    1012:	35048493          	addi	s1,s1,848 # c350 <buf+0x6a8>
    argv[0] = (char*)0xffffffff;
    1016:	597d                	li	s2,-1
    1018:	02095913          	srli	s2,s2,0x20
    exec("echo", argv);
    101c:	00004997          	auipc	s3,0x4
    1020:	23c98993          	addi	s3,s3,572 # 5258 <malloc+0x13a>
    argv[0] = (char*)0xffffffff;
    1024:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    1028:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    102c:	fc040593          	addi	a1,s0,-64
    1030:	854e                	mv	a0,s3
    1032:	447030ef          	jal	ra,4c78 <exec>
  for(int i = 0; i < 50000; i++){
    1036:	34fd                	addiw	s1,s1,-1
    1038:	f4f5                	bnez	s1,1024 <badarg+0x22>
  exit(0);
    103a:	4501                	li	a0,0
    103c:	405030ef          	jal	ra,4c40 <exit>

0000000000001040 <copyinstr2>:
{
    1040:	7155                	addi	sp,sp,-208
    1042:	e586                	sd	ra,200(sp)
    1044:	e1a2                	sd	s0,192(sp)
    1046:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    1048:	f6840793          	addi	a5,s0,-152
    104c:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    1050:	07800713          	li	a4,120
    1054:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    1058:	0785                	addi	a5,a5,1
    105a:	fed79de3          	bne	a5,a3,1054 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    105e:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    1062:	f6840513          	addi	a0,s0,-152
    1066:	42b030ef          	jal	ra,4c90 <unlink>
  if(ret != -1){
    106a:	57fd                	li	a5,-1
    106c:	0cf51263          	bne	a0,a5,1130 <copyinstr2+0xf0>
  int fd = open(b, O_CREATE | O_WRONLY);
    1070:	20100593          	li	a1,513
    1074:	f6840513          	addi	a0,s0,-152
    1078:	409030ef          	jal	ra,4c80 <open>
  if(fd != -1){
    107c:	57fd                	li	a5,-1
    107e:	0cf51563          	bne	a0,a5,1148 <copyinstr2+0x108>
  ret = link(b, b);
    1082:	f6840593          	addi	a1,s0,-152
    1086:	852e                	mv	a0,a1
    1088:	419030ef          	jal	ra,4ca0 <link>
  if(ret != -1){
    108c:	57fd                	li	a5,-1
    108e:	0cf51963          	bne	a0,a5,1160 <copyinstr2+0x120>
  char *args[] = { "xx", 0 };
    1092:	00006797          	auipc	a5,0x6
    1096:	aa678793          	addi	a5,a5,-1370 # 6b38 <malloc+0x1a1a>
    109a:	f4f43c23          	sd	a5,-168(s0)
    109e:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    10a2:	f5840593          	addi	a1,s0,-168
    10a6:	f6840513          	addi	a0,s0,-152
    10aa:	3cf030ef          	jal	ra,4c78 <exec>
  if(ret != -1){
    10ae:	57fd                	li	a5,-1
    10b0:	0cf51563          	bne	a0,a5,117a <copyinstr2+0x13a>
  int pid = fork();
    10b4:	385030ef          	jal	ra,4c38 <fork>
  if(pid < 0){
    10b8:	0c054d63          	bltz	a0,1192 <copyinstr2+0x152>
  if(pid == 0){
    10bc:	0e051863          	bnez	a0,11ac <copyinstr2+0x16c>
    10c0:	00007797          	auipc	a5,0x7
    10c4:	4d078793          	addi	a5,a5,1232 # 8590 <big.0>
    10c8:	00008697          	auipc	a3,0x8
    10cc:	4c868693          	addi	a3,a3,1224 # 9590 <big.0+0x1000>
      big[i] = 'x';
    10d0:	07800713          	li	a4,120
    10d4:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    10d8:	0785                	addi	a5,a5,1
    10da:	fed79de3          	bne	a5,a3,10d4 <copyinstr2+0x94>
    big[PGSIZE] = '\0';
    10de:	00008797          	auipc	a5,0x8
    10e2:	4a078923          	sb	zero,1202(a5) # 9590 <big.0+0x1000>
    char *args2[] = { big, big, big, 0 };
    10e6:	00006797          	auipc	a5,0x6
    10ea:	59a78793          	addi	a5,a5,1434 # 7680 <malloc+0x2562>
    10ee:	6fb0                	ld	a2,88(a5)
    10f0:	73b4                	ld	a3,96(a5)
    10f2:	77b8                	ld	a4,104(a5)
    10f4:	7bbc                	ld	a5,112(a5)
    10f6:	f2c43823          	sd	a2,-208(s0)
    10fa:	f2d43c23          	sd	a3,-200(s0)
    10fe:	f4e43023          	sd	a4,-192(s0)
    1102:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    1106:	f3040593          	addi	a1,s0,-208
    110a:	00004517          	auipc	a0,0x4
    110e:	14e50513          	addi	a0,a0,334 # 5258 <malloc+0x13a>
    1112:	367030ef          	jal	ra,4c78 <exec>
    if(ret != -1){
    1116:	57fd                	li	a5,-1
    1118:	08f50663          	beq	a0,a5,11a4 <copyinstr2+0x164>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    111c:	55fd                	li	a1,-1
    111e:	00005517          	auipc	a0,0x5
    1122:	97250513          	addi	a0,a0,-1678 # 5a90 <malloc+0x972>
    1126:	73f030ef          	jal	ra,5064 <printf>
      exit(1);
    112a:	4505                	li	a0,1
    112c:	315030ef          	jal	ra,4c40 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    1130:	862a                	mv	a2,a0
    1132:	f6840593          	addi	a1,s0,-152
    1136:	00005517          	auipc	a0,0x5
    113a:	8d250513          	addi	a0,a0,-1838 # 5a08 <malloc+0x8ea>
    113e:	727030ef          	jal	ra,5064 <printf>
    exit(1);
    1142:	4505                	li	a0,1
    1144:	2fd030ef          	jal	ra,4c40 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    1148:	862a                	mv	a2,a0
    114a:	f6840593          	addi	a1,s0,-152
    114e:	00005517          	auipc	a0,0x5
    1152:	8da50513          	addi	a0,a0,-1830 # 5a28 <malloc+0x90a>
    1156:	70f030ef          	jal	ra,5064 <printf>
    exit(1);
    115a:	4505                	li	a0,1
    115c:	2e5030ef          	jal	ra,4c40 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1160:	86aa                	mv	a3,a0
    1162:	f6840613          	addi	a2,s0,-152
    1166:	85b2                	mv	a1,a2
    1168:	00005517          	auipc	a0,0x5
    116c:	8e050513          	addi	a0,a0,-1824 # 5a48 <malloc+0x92a>
    1170:	6f5030ef          	jal	ra,5064 <printf>
    exit(1);
    1174:	4505                	li	a0,1
    1176:	2cb030ef          	jal	ra,4c40 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    117a:	567d                	li	a2,-1
    117c:	f6840593          	addi	a1,s0,-152
    1180:	00005517          	auipc	a0,0x5
    1184:	8f050513          	addi	a0,a0,-1808 # 5a70 <malloc+0x952>
    1188:	6dd030ef          	jal	ra,5064 <printf>
    exit(1);
    118c:	4505                	li	a0,1
    118e:	2b3030ef          	jal	ra,4c40 <exit>
    printf("fork failed\n");
    1192:	00006517          	auipc	a0,0x6
    1196:	ede50513          	addi	a0,a0,-290 # 7070 <malloc+0x1f52>
    119a:	6cb030ef          	jal	ra,5064 <printf>
    exit(1);
    119e:	4505                	li	a0,1
    11a0:	2a1030ef          	jal	ra,4c40 <exit>
    exit(747); // OK
    11a4:	2eb00513          	li	a0,747
    11a8:	299030ef          	jal	ra,4c40 <exit>
  int st = 0;
    11ac:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    11b0:	f5440513          	addi	a0,s0,-172
    11b4:	295030ef          	jal	ra,4c48 <wait>
  if(st != 747){
    11b8:	f5442703          	lw	a4,-172(s0)
    11bc:	2eb00793          	li	a5,747
    11c0:	00f71663          	bne	a4,a5,11cc <copyinstr2+0x18c>
}
    11c4:	60ae                	ld	ra,200(sp)
    11c6:	640e                	ld	s0,192(sp)
    11c8:	6169                	addi	sp,sp,208
    11ca:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    11cc:	00005517          	auipc	a0,0x5
    11d0:	8ec50513          	addi	a0,a0,-1812 # 5ab8 <malloc+0x99a>
    11d4:	691030ef          	jal	ra,5064 <printf>
    exit(1);
    11d8:	4505                	li	a0,1
    11da:	267030ef          	jal	ra,4c40 <exit>

00000000000011de <truncate3>:
{
    11de:	7159                	addi	sp,sp,-112
    11e0:	f486                	sd	ra,104(sp)
    11e2:	f0a2                	sd	s0,96(sp)
    11e4:	eca6                	sd	s1,88(sp)
    11e6:	e8ca                	sd	s2,80(sp)
    11e8:	e4ce                	sd	s3,72(sp)
    11ea:	e0d2                	sd	s4,64(sp)
    11ec:	fc56                	sd	s5,56(sp)
    11ee:	1880                	addi	s0,sp,112
    11f0:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    11f2:	60100593          	li	a1,1537
    11f6:	00004517          	auipc	a0,0x4
    11fa:	0ba50513          	addi	a0,a0,186 # 52b0 <malloc+0x192>
    11fe:	283030ef          	jal	ra,4c80 <open>
    1202:	267030ef          	jal	ra,4c68 <close>
  pid = fork();
    1206:	233030ef          	jal	ra,4c38 <fork>
  if(pid < 0){
    120a:	06054263          	bltz	a0,126e <truncate3+0x90>
  if(pid == 0){
    120e:	ed59                	bnez	a0,12ac <truncate3+0xce>
    1210:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    1214:	00004a17          	auipc	s4,0x4
    1218:	09ca0a13          	addi	s4,s4,156 # 52b0 <malloc+0x192>
      int n = write(fd, "1234567890", 10);
    121c:	00005a97          	auipc	s5,0x5
    1220:	8fca8a93          	addi	s5,s5,-1796 # 5b18 <malloc+0x9fa>
      int fd = open("truncfile", O_WRONLY);
    1224:	4585                	li	a1,1
    1226:	8552                	mv	a0,s4
    1228:	259030ef          	jal	ra,4c80 <open>
    122c:	84aa                	mv	s1,a0
      if(fd < 0){
    122e:	04054a63          	bltz	a0,1282 <truncate3+0xa4>
      int n = write(fd, "1234567890", 10);
    1232:	4629                	li	a2,10
    1234:	85d6                	mv	a1,s5
    1236:	22b030ef          	jal	ra,4c60 <write>
      if(n != 10){
    123a:	47a9                	li	a5,10
    123c:	04f51d63          	bne	a0,a5,1296 <truncate3+0xb8>
      close(fd);
    1240:	8526                	mv	a0,s1
    1242:	227030ef          	jal	ra,4c68 <close>
      fd = open("truncfile", O_RDONLY);
    1246:	4581                	li	a1,0
    1248:	8552                	mv	a0,s4
    124a:	237030ef          	jal	ra,4c80 <open>
    124e:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    1250:	02000613          	li	a2,32
    1254:	f9840593          	addi	a1,s0,-104
    1258:	201030ef          	jal	ra,4c58 <read>
      close(fd);
    125c:	8526                	mv	a0,s1
    125e:	20b030ef          	jal	ra,4c68 <close>
    for(int i = 0; i < 100; i++){
    1262:	39fd                	addiw	s3,s3,-1
    1264:	fc0990e3          	bnez	s3,1224 <truncate3+0x46>
    exit(0);
    1268:	4501                	li	a0,0
    126a:	1d7030ef          	jal	ra,4c40 <exit>
    printf("%s: fork failed\n", s);
    126e:	85ca                	mv	a1,s2
    1270:	00005517          	auipc	a0,0x5
    1274:	87850513          	addi	a0,a0,-1928 # 5ae8 <malloc+0x9ca>
    1278:	5ed030ef          	jal	ra,5064 <printf>
    exit(1);
    127c:	4505                	li	a0,1
    127e:	1c3030ef          	jal	ra,4c40 <exit>
        printf("%s: open failed\n", s);
    1282:	85ca                	mv	a1,s2
    1284:	00005517          	auipc	a0,0x5
    1288:	87c50513          	addi	a0,a0,-1924 # 5b00 <malloc+0x9e2>
    128c:	5d9030ef          	jal	ra,5064 <printf>
        exit(1);
    1290:	4505                	li	a0,1
    1292:	1af030ef          	jal	ra,4c40 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    1296:	862a                	mv	a2,a0
    1298:	85ca                	mv	a1,s2
    129a:	00005517          	auipc	a0,0x5
    129e:	88e50513          	addi	a0,a0,-1906 # 5b28 <malloc+0xa0a>
    12a2:	5c3030ef          	jal	ra,5064 <printf>
        exit(1);
    12a6:	4505                	li	a0,1
    12a8:	199030ef          	jal	ra,4c40 <exit>
    12ac:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    12b0:	00004a17          	auipc	s4,0x4
    12b4:	000a0a13          	mv	s4,s4
    int n = write(fd, "xxx", 3);
    12b8:	00005a97          	auipc	s5,0x5
    12bc:	890a8a93          	addi	s5,s5,-1904 # 5b48 <malloc+0xa2a>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    12c0:	60100593          	li	a1,1537
    12c4:	8552                	mv	a0,s4
    12c6:	1bb030ef          	jal	ra,4c80 <open>
    12ca:	84aa                	mv	s1,a0
    if(fd < 0){
    12cc:	02054d63          	bltz	a0,1306 <truncate3+0x128>
    int n = write(fd, "xxx", 3);
    12d0:	460d                	li	a2,3
    12d2:	85d6                	mv	a1,s5
    12d4:	18d030ef          	jal	ra,4c60 <write>
    if(n != 3){
    12d8:	478d                	li	a5,3
    12da:	04f51063          	bne	a0,a5,131a <truncate3+0x13c>
    close(fd);
    12de:	8526                	mv	a0,s1
    12e0:	189030ef          	jal	ra,4c68 <close>
  for(int i = 0; i < 150; i++){
    12e4:	39fd                	addiw	s3,s3,-1
    12e6:	fc099de3          	bnez	s3,12c0 <truncate3+0xe2>
  wait(&xstatus);
    12ea:	fbc40513          	addi	a0,s0,-68
    12ee:	15b030ef          	jal	ra,4c48 <wait>
  unlink("truncfile");
    12f2:	00004517          	auipc	a0,0x4
    12f6:	fbe50513          	addi	a0,a0,-66 # 52b0 <malloc+0x192>
    12fa:	197030ef          	jal	ra,4c90 <unlink>
  exit(xstatus);
    12fe:	fbc42503          	lw	a0,-68(s0)
    1302:	13f030ef          	jal	ra,4c40 <exit>
      printf("%s: open failed\n", s);
    1306:	85ca                	mv	a1,s2
    1308:	00004517          	auipc	a0,0x4
    130c:	7f850513          	addi	a0,a0,2040 # 5b00 <malloc+0x9e2>
    1310:	555030ef          	jal	ra,5064 <printf>
      exit(1);
    1314:	4505                	li	a0,1
    1316:	12b030ef          	jal	ra,4c40 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    131a:	862a                	mv	a2,a0
    131c:	85ca                	mv	a1,s2
    131e:	00005517          	auipc	a0,0x5
    1322:	83250513          	addi	a0,a0,-1998 # 5b50 <malloc+0xa32>
    1326:	53f030ef          	jal	ra,5064 <printf>
      exit(1);
    132a:	4505                	li	a0,1
    132c:	115030ef          	jal	ra,4c40 <exit>

0000000000001330 <exectest>:
{
    1330:	715d                	addi	sp,sp,-80
    1332:	e486                	sd	ra,72(sp)
    1334:	e0a2                	sd	s0,64(sp)
    1336:	fc26                	sd	s1,56(sp)
    1338:	f84a                	sd	s2,48(sp)
    133a:	0880                	addi	s0,sp,80
    133c:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    133e:	00004797          	auipc	a5,0x4
    1342:	f1a78793          	addi	a5,a5,-230 # 5258 <malloc+0x13a>
    1346:	fcf43023          	sd	a5,-64(s0)
    134a:	00005797          	auipc	a5,0x5
    134e:	82678793          	addi	a5,a5,-2010 # 5b70 <malloc+0xa52>
    1352:	fcf43423          	sd	a5,-56(s0)
    1356:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    135a:	00005517          	auipc	a0,0x5
    135e:	81e50513          	addi	a0,a0,-2018 # 5b78 <malloc+0xa5a>
    1362:	12f030ef          	jal	ra,4c90 <unlink>
  pid = fork();
    1366:	0d3030ef          	jal	ra,4c38 <fork>
  if(pid < 0) {
    136a:	02054e63          	bltz	a0,13a6 <exectest+0x76>
    136e:	84aa                	mv	s1,a0
  if(pid == 0) {
    1370:	e92d                	bnez	a0,13e2 <exectest+0xb2>
    close(1);
    1372:	4505                	li	a0,1
    1374:	0f5030ef          	jal	ra,4c68 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    1378:	20100593          	li	a1,513
    137c:	00004517          	auipc	a0,0x4
    1380:	7fc50513          	addi	a0,a0,2044 # 5b78 <malloc+0xa5a>
    1384:	0fd030ef          	jal	ra,4c80 <open>
    if(fd < 0) {
    1388:	02054963          	bltz	a0,13ba <exectest+0x8a>
    if(fd != 1) {
    138c:	4785                	li	a5,1
    138e:	04f50063          	beq	a0,a5,13ce <exectest+0x9e>
      printf("%s: wrong fd\n", s);
    1392:	85ca                	mv	a1,s2
    1394:	00005517          	auipc	a0,0x5
    1398:	80450513          	addi	a0,a0,-2044 # 5b98 <malloc+0xa7a>
    139c:	4c9030ef          	jal	ra,5064 <printf>
      exit(1);
    13a0:	4505                	li	a0,1
    13a2:	09f030ef          	jal	ra,4c40 <exit>
     printf("%s: fork failed\n", s);
    13a6:	85ca                	mv	a1,s2
    13a8:	00004517          	auipc	a0,0x4
    13ac:	74050513          	addi	a0,a0,1856 # 5ae8 <malloc+0x9ca>
    13b0:	4b5030ef          	jal	ra,5064 <printf>
     exit(1);
    13b4:	4505                	li	a0,1
    13b6:	08b030ef          	jal	ra,4c40 <exit>
      printf("%s: create failed\n", s);
    13ba:	85ca                	mv	a1,s2
    13bc:	00004517          	auipc	a0,0x4
    13c0:	7c450513          	addi	a0,a0,1988 # 5b80 <malloc+0xa62>
    13c4:	4a1030ef          	jal	ra,5064 <printf>
      exit(1);
    13c8:	4505                	li	a0,1
    13ca:	077030ef          	jal	ra,4c40 <exit>
    if(exec("echo", echoargv) < 0){
    13ce:	fc040593          	addi	a1,s0,-64
    13d2:	00004517          	auipc	a0,0x4
    13d6:	e8650513          	addi	a0,a0,-378 # 5258 <malloc+0x13a>
    13da:	09f030ef          	jal	ra,4c78 <exec>
    13de:	00054d63          	bltz	a0,13f8 <exectest+0xc8>
  if (wait(&xstatus) != pid) {
    13e2:	fdc40513          	addi	a0,s0,-36
    13e6:	063030ef          	jal	ra,4c48 <wait>
    13ea:	02951163          	bne	a0,s1,140c <exectest+0xdc>
  if(xstatus != 0)
    13ee:	fdc42503          	lw	a0,-36(s0)
    13f2:	c50d                	beqz	a0,141c <exectest+0xec>
    exit(xstatus);
    13f4:	04d030ef          	jal	ra,4c40 <exit>
      printf("%s: exec echo failed\n", s);
    13f8:	85ca                	mv	a1,s2
    13fa:	00004517          	auipc	a0,0x4
    13fe:	7ae50513          	addi	a0,a0,1966 # 5ba8 <malloc+0xa8a>
    1402:	463030ef          	jal	ra,5064 <printf>
      exit(1);
    1406:	4505                	li	a0,1
    1408:	039030ef          	jal	ra,4c40 <exit>
    printf("%s: wait failed!\n", s);
    140c:	85ca                	mv	a1,s2
    140e:	00004517          	auipc	a0,0x4
    1412:	7b250513          	addi	a0,a0,1970 # 5bc0 <malloc+0xaa2>
    1416:	44f030ef          	jal	ra,5064 <printf>
    141a:	bfd1                	j	13ee <exectest+0xbe>
  fd = open("echo-ok", O_RDONLY);
    141c:	4581                	li	a1,0
    141e:	00004517          	auipc	a0,0x4
    1422:	75a50513          	addi	a0,a0,1882 # 5b78 <malloc+0xa5a>
    1426:	05b030ef          	jal	ra,4c80 <open>
  if(fd < 0) {
    142a:	02054463          	bltz	a0,1452 <exectest+0x122>
  if (read(fd, buf, 2) != 2) {
    142e:	4609                	li	a2,2
    1430:	fb840593          	addi	a1,s0,-72
    1434:	025030ef          	jal	ra,4c58 <read>
    1438:	4789                	li	a5,2
    143a:	02f50663          	beq	a0,a5,1466 <exectest+0x136>
    printf("%s: read failed\n", s);
    143e:	85ca                	mv	a1,s2
    1440:	00004517          	auipc	a0,0x4
    1444:	1e850513          	addi	a0,a0,488 # 5628 <malloc+0x50a>
    1448:	41d030ef          	jal	ra,5064 <printf>
    exit(1);
    144c:	4505                	li	a0,1
    144e:	7f2030ef          	jal	ra,4c40 <exit>
    printf("%s: open failed\n", s);
    1452:	85ca                	mv	a1,s2
    1454:	00004517          	auipc	a0,0x4
    1458:	6ac50513          	addi	a0,a0,1708 # 5b00 <malloc+0x9e2>
    145c:	409030ef          	jal	ra,5064 <printf>
    exit(1);
    1460:	4505                	li	a0,1
    1462:	7de030ef          	jal	ra,4c40 <exit>
  unlink("echo-ok");
    1466:	00004517          	auipc	a0,0x4
    146a:	71250513          	addi	a0,a0,1810 # 5b78 <malloc+0xa5a>
    146e:	023030ef          	jal	ra,4c90 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1472:	fb844703          	lbu	a4,-72(s0)
    1476:	04f00793          	li	a5,79
    147a:	00f71863          	bne	a4,a5,148a <exectest+0x15a>
    147e:	fb944703          	lbu	a4,-71(s0)
    1482:	04b00793          	li	a5,75
    1486:	00f70c63          	beq	a4,a5,149e <exectest+0x16e>
    printf("%s: wrong output\n", s);
    148a:	85ca                	mv	a1,s2
    148c:	00004517          	auipc	a0,0x4
    1490:	74c50513          	addi	a0,a0,1868 # 5bd8 <malloc+0xaba>
    1494:	3d1030ef          	jal	ra,5064 <printf>
    exit(1);
    1498:	4505                	li	a0,1
    149a:	7a6030ef          	jal	ra,4c40 <exit>
    exit(0);
    149e:	4501                	li	a0,0
    14a0:	7a0030ef          	jal	ra,4c40 <exit>

00000000000014a4 <pipe1>:
{
    14a4:	711d                	addi	sp,sp,-96
    14a6:	ec86                	sd	ra,88(sp)
    14a8:	e8a2                	sd	s0,80(sp)
    14aa:	e4a6                	sd	s1,72(sp)
    14ac:	e0ca                	sd	s2,64(sp)
    14ae:	fc4e                	sd	s3,56(sp)
    14b0:	f852                	sd	s4,48(sp)
    14b2:	f456                	sd	s5,40(sp)
    14b4:	f05a                	sd	s6,32(sp)
    14b6:	ec5e                	sd	s7,24(sp)
    14b8:	1080                	addi	s0,sp,96
    14ba:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    14bc:	fa840513          	addi	a0,s0,-88
    14c0:	790030ef          	jal	ra,4c50 <pipe>
    14c4:	e535                	bnez	a0,1530 <pipe1+0x8c>
    14c6:	84aa                	mv	s1,a0
  pid = fork();
    14c8:	770030ef          	jal	ra,4c38 <fork>
    14cc:	8a2a                	mv	s4,a0
  if(pid == 0){
    14ce:	c93d                	beqz	a0,1544 <pipe1+0xa0>
  } else if(pid > 0){
    14d0:	14a05163          	blez	a0,1612 <pipe1+0x16e>
    close(fds[1]);
    14d4:	fac42503          	lw	a0,-84(s0)
    14d8:	790030ef          	jal	ra,4c68 <close>
    total = 0;
    14dc:	8a26                	mv	s4,s1
    cc = 1;
    14de:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    14e0:	0000aa97          	auipc	s5,0xa
    14e4:	7c8a8a93          	addi	s5,s5,1992 # bca8 <buf>
      if(cc > sizeof(buf))
    14e8:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    14ea:	864e                	mv	a2,s3
    14ec:	85d6                	mv	a1,s5
    14ee:	fa842503          	lw	a0,-88(s0)
    14f2:	766030ef          	jal	ra,4c58 <read>
    14f6:	0ea05263          	blez	a0,15da <pipe1+0x136>
      for(i = 0; i < n; i++){
    14fa:	0000a717          	auipc	a4,0xa
    14fe:	7ae70713          	addi	a4,a4,1966 # bca8 <buf>
    1502:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    1506:	00074683          	lbu	a3,0(a4)
    150a:	0ff4f793          	andi	a5,s1,255
    150e:	2485                	addiw	s1,s1,1
    1510:	0af69363          	bne	a3,a5,15b6 <pipe1+0x112>
      for(i = 0; i < n; i++){
    1514:	0705                	addi	a4,a4,1
    1516:	fec498e3          	bne	s1,a2,1506 <pipe1+0x62>
      total += n;
    151a:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    151e:	0019979b          	slliw	a5,s3,0x1
    1522:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    1526:	013b7363          	bgeu	s6,s3,152c <pipe1+0x88>
        cc = sizeof(buf);
    152a:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    152c:	84b2                	mv	s1,a2
    152e:	bf75                	j	14ea <pipe1+0x46>
    printf("%s: pipe() failed\n", s);
    1530:	85ca                	mv	a1,s2
    1532:	00004517          	auipc	a0,0x4
    1536:	6be50513          	addi	a0,a0,1726 # 5bf0 <malloc+0xad2>
    153a:	32b030ef          	jal	ra,5064 <printf>
    exit(1);
    153e:	4505                	li	a0,1
    1540:	700030ef          	jal	ra,4c40 <exit>
    close(fds[0]);
    1544:	fa842503          	lw	a0,-88(s0)
    1548:	720030ef          	jal	ra,4c68 <close>
    for(n = 0; n < N; n++){
    154c:	0000ab17          	auipc	s6,0xa
    1550:	75cb0b13          	addi	s6,s6,1884 # bca8 <buf>
    1554:	416004bb          	negw	s1,s6
    1558:	0ff4f493          	andi	s1,s1,255
    155c:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    1560:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    1562:	6a85                	lui	s5,0x1
    1564:	42da8a93          	addi	s5,s5,1069 # 142d <exectest+0xfd>
{
    1568:	87da                	mv	a5,s6
        buf[i] = seq++;
    156a:	0097873b          	addw	a4,a5,s1
    156e:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1572:	0785                	addi	a5,a5,1
    1574:	fef99be3          	bne	s3,a5,156a <pipe1+0xc6>
        buf[i] = seq++;
    1578:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    157c:	40900613          	li	a2,1033
    1580:	85de                	mv	a1,s7
    1582:	fac42503          	lw	a0,-84(s0)
    1586:	6da030ef          	jal	ra,4c60 <write>
    158a:	40900793          	li	a5,1033
    158e:	00f51a63          	bne	a0,a5,15a2 <pipe1+0xfe>
    for(n = 0; n < N; n++){
    1592:	24a5                	addiw	s1,s1,9
    1594:	0ff4f493          	andi	s1,s1,255
    1598:	fd5a18e3          	bne	s4,s5,1568 <pipe1+0xc4>
    exit(0);
    159c:	4501                	li	a0,0
    159e:	6a2030ef          	jal	ra,4c40 <exit>
        printf("%s: pipe1 oops 1\n", s);
    15a2:	85ca                	mv	a1,s2
    15a4:	00004517          	auipc	a0,0x4
    15a8:	66450513          	addi	a0,a0,1636 # 5c08 <malloc+0xaea>
    15ac:	2b9030ef          	jal	ra,5064 <printf>
        exit(1);
    15b0:	4505                	li	a0,1
    15b2:	68e030ef          	jal	ra,4c40 <exit>
          printf("%s: pipe1 oops 2\n", s);
    15b6:	85ca                	mv	a1,s2
    15b8:	00004517          	auipc	a0,0x4
    15bc:	66850513          	addi	a0,a0,1640 # 5c20 <malloc+0xb02>
    15c0:	2a5030ef          	jal	ra,5064 <printf>
}
    15c4:	60e6                	ld	ra,88(sp)
    15c6:	6446                	ld	s0,80(sp)
    15c8:	64a6                	ld	s1,72(sp)
    15ca:	6906                	ld	s2,64(sp)
    15cc:	79e2                	ld	s3,56(sp)
    15ce:	7a42                	ld	s4,48(sp)
    15d0:	7aa2                	ld	s5,40(sp)
    15d2:	7b02                	ld	s6,32(sp)
    15d4:	6be2                	ld	s7,24(sp)
    15d6:	6125                	addi	sp,sp,96
    15d8:	8082                	ret
    if(total != N * SZ){
    15da:	6785                	lui	a5,0x1
    15dc:	42d78793          	addi	a5,a5,1069 # 142d <exectest+0xfd>
    15e0:	00fa0d63          	beq	s4,a5,15fa <pipe1+0x156>
      printf("%s: pipe1 oops 3 total %d\n", s, total);
    15e4:	8652                	mv	a2,s4
    15e6:	85ca                	mv	a1,s2
    15e8:	00004517          	auipc	a0,0x4
    15ec:	65050513          	addi	a0,a0,1616 # 5c38 <malloc+0xb1a>
    15f0:	275030ef          	jal	ra,5064 <printf>
      exit(1);
    15f4:	4505                	li	a0,1
    15f6:	64a030ef          	jal	ra,4c40 <exit>
    close(fds[0]);
    15fa:	fa842503          	lw	a0,-88(s0)
    15fe:	66a030ef          	jal	ra,4c68 <close>
    wait(&xstatus);
    1602:	fa440513          	addi	a0,s0,-92
    1606:	642030ef          	jal	ra,4c48 <wait>
    exit(xstatus);
    160a:	fa442503          	lw	a0,-92(s0)
    160e:	632030ef          	jal	ra,4c40 <exit>
    printf("%s: fork() failed\n", s);
    1612:	85ca                	mv	a1,s2
    1614:	00004517          	auipc	a0,0x4
    1618:	64450513          	addi	a0,a0,1604 # 5c58 <malloc+0xb3a>
    161c:	249030ef          	jal	ra,5064 <printf>
    exit(1);
    1620:	4505                	li	a0,1
    1622:	61e030ef          	jal	ra,4c40 <exit>

0000000000001626 <exitwait>:
{
    1626:	7139                	addi	sp,sp,-64
    1628:	fc06                	sd	ra,56(sp)
    162a:	f822                	sd	s0,48(sp)
    162c:	f426                	sd	s1,40(sp)
    162e:	f04a                	sd	s2,32(sp)
    1630:	ec4e                	sd	s3,24(sp)
    1632:	e852                	sd	s4,16(sp)
    1634:	0080                	addi	s0,sp,64
    1636:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    1638:	4901                	li	s2,0
    163a:	06400993          	li	s3,100
    pid = fork();
    163e:	5fa030ef          	jal	ra,4c38 <fork>
    1642:	84aa                	mv	s1,a0
    if(pid < 0){
    1644:	02054863          	bltz	a0,1674 <exitwait+0x4e>
    if(pid){
    1648:	c525                	beqz	a0,16b0 <exitwait+0x8a>
      if(wait(&xstate) != pid){
    164a:	fcc40513          	addi	a0,s0,-52
    164e:	5fa030ef          	jal	ra,4c48 <wait>
    1652:	02951b63          	bne	a0,s1,1688 <exitwait+0x62>
      if(i != xstate) {
    1656:	fcc42783          	lw	a5,-52(s0)
    165a:	05279163          	bne	a5,s2,169c <exitwait+0x76>
  for(i = 0; i < 100; i++){
    165e:	2905                	addiw	s2,s2,1
    1660:	fd391fe3          	bne	s2,s3,163e <exitwait+0x18>
}
    1664:	70e2                	ld	ra,56(sp)
    1666:	7442                	ld	s0,48(sp)
    1668:	74a2                	ld	s1,40(sp)
    166a:	7902                	ld	s2,32(sp)
    166c:	69e2                	ld	s3,24(sp)
    166e:	6a42                	ld	s4,16(sp)
    1670:	6121                	addi	sp,sp,64
    1672:	8082                	ret
      printf("%s: fork failed\n", s);
    1674:	85d2                	mv	a1,s4
    1676:	00004517          	auipc	a0,0x4
    167a:	47250513          	addi	a0,a0,1138 # 5ae8 <malloc+0x9ca>
    167e:	1e7030ef          	jal	ra,5064 <printf>
      exit(1);
    1682:	4505                	li	a0,1
    1684:	5bc030ef          	jal	ra,4c40 <exit>
        printf("%s: wait wrong pid\n", s);
    1688:	85d2                	mv	a1,s4
    168a:	00004517          	auipc	a0,0x4
    168e:	5e650513          	addi	a0,a0,1510 # 5c70 <malloc+0xb52>
    1692:	1d3030ef          	jal	ra,5064 <printf>
        exit(1);
    1696:	4505                	li	a0,1
    1698:	5a8030ef          	jal	ra,4c40 <exit>
        printf("%s: wait wrong exit status\n", s);
    169c:	85d2                	mv	a1,s4
    169e:	00004517          	auipc	a0,0x4
    16a2:	5ea50513          	addi	a0,a0,1514 # 5c88 <malloc+0xb6a>
    16a6:	1bf030ef          	jal	ra,5064 <printf>
        exit(1);
    16aa:	4505                	li	a0,1
    16ac:	594030ef          	jal	ra,4c40 <exit>
      exit(i);
    16b0:	854a                	mv	a0,s2
    16b2:	58e030ef          	jal	ra,4c40 <exit>

00000000000016b6 <twochildren>:
{
    16b6:	1101                	addi	sp,sp,-32
    16b8:	ec06                	sd	ra,24(sp)
    16ba:	e822                	sd	s0,16(sp)
    16bc:	e426                	sd	s1,8(sp)
    16be:	e04a                	sd	s2,0(sp)
    16c0:	1000                	addi	s0,sp,32
    16c2:	892a                	mv	s2,a0
    16c4:	3e800493          	li	s1,1000
    int pid1 = fork();
    16c8:	570030ef          	jal	ra,4c38 <fork>
    if(pid1 < 0){
    16cc:	02054663          	bltz	a0,16f8 <twochildren+0x42>
    if(pid1 == 0){
    16d0:	cd15                	beqz	a0,170c <twochildren+0x56>
      int pid2 = fork();
    16d2:	566030ef          	jal	ra,4c38 <fork>
      if(pid2 < 0){
    16d6:	02054d63          	bltz	a0,1710 <twochildren+0x5a>
      if(pid2 == 0){
    16da:	c529                	beqz	a0,1724 <twochildren+0x6e>
        wait(0);
    16dc:	4501                	li	a0,0
    16de:	56a030ef          	jal	ra,4c48 <wait>
        wait(0);
    16e2:	4501                	li	a0,0
    16e4:	564030ef          	jal	ra,4c48 <wait>
  for(int i = 0; i < 1000; i++){
    16e8:	34fd                	addiw	s1,s1,-1
    16ea:	fcf9                	bnez	s1,16c8 <twochildren+0x12>
}
    16ec:	60e2                	ld	ra,24(sp)
    16ee:	6442                	ld	s0,16(sp)
    16f0:	64a2                	ld	s1,8(sp)
    16f2:	6902                	ld	s2,0(sp)
    16f4:	6105                	addi	sp,sp,32
    16f6:	8082                	ret
      printf("%s: fork failed\n", s);
    16f8:	85ca                	mv	a1,s2
    16fa:	00004517          	auipc	a0,0x4
    16fe:	3ee50513          	addi	a0,a0,1006 # 5ae8 <malloc+0x9ca>
    1702:	163030ef          	jal	ra,5064 <printf>
      exit(1);
    1706:	4505                	li	a0,1
    1708:	538030ef          	jal	ra,4c40 <exit>
      exit(0);
    170c:	534030ef          	jal	ra,4c40 <exit>
        printf("%s: fork failed\n", s);
    1710:	85ca                	mv	a1,s2
    1712:	00004517          	auipc	a0,0x4
    1716:	3d650513          	addi	a0,a0,982 # 5ae8 <malloc+0x9ca>
    171a:	14b030ef          	jal	ra,5064 <printf>
        exit(1);
    171e:	4505                	li	a0,1
    1720:	520030ef          	jal	ra,4c40 <exit>
        exit(0);
    1724:	51c030ef          	jal	ra,4c40 <exit>

0000000000001728 <forkfork>:
{
    1728:	7179                	addi	sp,sp,-48
    172a:	f406                	sd	ra,40(sp)
    172c:	f022                	sd	s0,32(sp)
    172e:	ec26                	sd	s1,24(sp)
    1730:	1800                	addi	s0,sp,48
    1732:	84aa                	mv	s1,a0
    int pid = fork();
    1734:	504030ef          	jal	ra,4c38 <fork>
    if(pid < 0){
    1738:	02054b63          	bltz	a0,176e <forkfork+0x46>
    if(pid == 0){
    173c:	c139                	beqz	a0,1782 <forkfork+0x5a>
    int pid = fork();
    173e:	4fa030ef          	jal	ra,4c38 <fork>
    if(pid < 0){
    1742:	02054663          	bltz	a0,176e <forkfork+0x46>
    if(pid == 0){
    1746:	cd15                	beqz	a0,1782 <forkfork+0x5a>
    wait(&xstatus);
    1748:	fdc40513          	addi	a0,s0,-36
    174c:	4fc030ef          	jal	ra,4c48 <wait>
    if(xstatus != 0) {
    1750:	fdc42783          	lw	a5,-36(s0)
    1754:	ebb9                	bnez	a5,17aa <forkfork+0x82>
    wait(&xstatus);
    1756:	fdc40513          	addi	a0,s0,-36
    175a:	4ee030ef          	jal	ra,4c48 <wait>
    if(xstatus != 0) {
    175e:	fdc42783          	lw	a5,-36(s0)
    1762:	e7a1                	bnez	a5,17aa <forkfork+0x82>
}
    1764:	70a2                	ld	ra,40(sp)
    1766:	7402                	ld	s0,32(sp)
    1768:	64e2                	ld	s1,24(sp)
    176a:	6145                	addi	sp,sp,48
    176c:	8082                	ret
      printf("%s: fork failed", s);
    176e:	85a6                	mv	a1,s1
    1770:	00004517          	auipc	a0,0x4
    1774:	53850513          	addi	a0,a0,1336 # 5ca8 <malloc+0xb8a>
    1778:	0ed030ef          	jal	ra,5064 <printf>
      exit(1);
    177c:	4505                	li	a0,1
    177e:	4c2030ef          	jal	ra,4c40 <exit>
{
    1782:	0c800493          	li	s1,200
        int pid1 = fork();
    1786:	4b2030ef          	jal	ra,4c38 <fork>
        if(pid1 < 0){
    178a:	00054b63          	bltz	a0,17a0 <forkfork+0x78>
        if(pid1 == 0){
    178e:	cd01                	beqz	a0,17a6 <forkfork+0x7e>
        wait(0);
    1790:	4501                	li	a0,0
    1792:	4b6030ef          	jal	ra,4c48 <wait>
      for(int j = 0; j < 200; j++){
    1796:	34fd                	addiw	s1,s1,-1
    1798:	f4fd                	bnez	s1,1786 <forkfork+0x5e>
      exit(0);
    179a:	4501                	li	a0,0
    179c:	4a4030ef          	jal	ra,4c40 <exit>
          exit(1);
    17a0:	4505                	li	a0,1
    17a2:	49e030ef          	jal	ra,4c40 <exit>
          exit(0);
    17a6:	49a030ef          	jal	ra,4c40 <exit>
      printf("%s: fork in child failed", s);
    17aa:	85a6                	mv	a1,s1
    17ac:	00004517          	auipc	a0,0x4
    17b0:	50c50513          	addi	a0,a0,1292 # 5cb8 <malloc+0xb9a>
    17b4:	0b1030ef          	jal	ra,5064 <printf>
      exit(1);
    17b8:	4505                	li	a0,1
    17ba:	486030ef          	jal	ra,4c40 <exit>

00000000000017be <reparent2>:
{
    17be:	1101                	addi	sp,sp,-32
    17c0:	ec06                	sd	ra,24(sp)
    17c2:	e822                	sd	s0,16(sp)
    17c4:	e426                	sd	s1,8(sp)
    17c6:	1000                	addi	s0,sp,32
    17c8:	32000493          	li	s1,800
    int pid1 = fork();
    17cc:	46c030ef          	jal	ra,4c38 <fork>
    if(pid1 < 0){
    17d0:	00054b63          	bltz	a0,17e6 <reparent2+0x28>
    if(pid1 == 0){
    17d4:	c115                	beqz	a0,17f8 <reparent2+0x3a>
    wait(0);
    17d6:	4501                	li	a0,0
    17d8:	470030ef          	jal	ra,4c48 <wait>
  for(int i = 0; i < 800; i++){
    17dc:	34fd                	addiw	s1,s1,-1
    17de:	f4fd                	bnez	s1,17cc <reparent2+0xe>
  exit(0);
    17e0:	4501                	li	a0,0
    17e2:	45e030ef          	jal	ra,4c40 <exit>
      printf("fork failed\n");
    17e6:	00006517          	auipc	a0,0x6
    17ea:	88a50513          	addi	a0,a0,-1910 # 7070 <malloc+0x1f52>
    17ee:	077030ef          	jal	ra,5064 <printf>
      exit(1);
    17f2:	4505                	li	a0,1
    17f4:	44c030ef          	jal	ra,4c40 <exit>
      fork();
    17f8:	440030ef          	jal	ra,4c38 <fork>
      fork();
    17fc:	43c030ef          	jal	ra,4c38 <fork>
      exit(0);
    1800:	4501                	li	a0,0
    1802:	43e030ef          	jal	ra,4c40 <exit>

0000000000001806 <createdelete>:
{
    1806:	7175                	addi	sp,sp,-144
    1808:	e506                	sd	ra,136(sp)
    180a:	e122                	sd	s0,128(sp)
    180c:	fca6                	sd	s1,120(sp)
    180e:	f8ca                	sd	s2,112(sp)
    1810:	f4ce                	sd	s3,104(sp)
    1812:	f0d2                	sd	s4,96(sp)
    1814:	ecd6                	sd	s5,88(sp)
    1816:	e8da                	sd	s6,80(sp)
    1818:	e4de                	sd	s7,72(sp)
    181a:	e0e2                	sd	s8,64(sp)
    181c:	fc66                	sd	s9,56(sp)
    181e:	0900                	addi	s0,sp,144
    1820:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    1822:	4901                	li	s2,0
    1824:	4991                	li	s3,4
    pid = fork();
    1826:	412030ef          	jal	ra,4c38 <fork>
    182a:	84aa                	mv	s1,a0
    if(pid < 0){
    182c:	02054d63          	bltz	a0,1866 <createdelete+0x60>
    if(pid == 0){
    1830:	c529                	beqz	a0,187a <createdelete+0x74>
  for(pi = 0; pi < NCHILD; pi++){
    1832:	2905                	addiw	s2,s2,1
    1834:	ff3919e3          	bne	s2,s3,1826 <createdelete+0x20>
    1838:	4491                	li	s1,4
    wait(&xstatus);
    183a:	f7c40513          	addi	a0,s0,-132
    183e:	40a030ef          	jal	ra,4c48 <wait>
    if(xstatus != 0)
    1842:	f7c42903          	lw	s2,-132(s0)
    1846:	0a091e63          	bnez	s2,1902 <createdelete+0xfc>
  for(pi = 0; pi < NCHILD; pi++){
    184a:	34fd                	addiw	s1,s1,-1
    184c:	f4fd                	bnez	s1,183a <createdelete+0x34>
  name[0] = name[1] = name[2] = 0;
    184e:	f8040123          	sb	zero,-126(s0)
    1852:	03000993          	li	s3,48
    1856:	5a7d                	li	s4,-1
    1858:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    185c:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    185e:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    1860:	07400a93          	li	s5,116
    1864:	a20d                	j	1986 <createdelete+0x180>
      printf("%s: fork failed\n", s);
    1866:	85e6                	mv	a1,s9
    1868:	00004517          	auipc	a0,0x4
    186c:	28050513          	addi	a0,a0,640 # 5ae8 <malloc+0x9ca>
    1870:	7f4030ef          	jal	ra,5064 <printf>
      exit(1);
    1874:	4505                	li	a0,1
    1876:	3ca030ef          	jal	ra,4c40 <exit>
      name[0] = 'p' + pi;
    187a:	0709091b          	addiw	s2,s2,112
    187e:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1882:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    1886:	4951                	li	s2,20
    1888:	a831                	j	18a4 <createdelete+0x9e>
          printf("%s: create failed\n", s);
    188a:	85e6                	mv	a1,s9
    188c:	00004517          	auipc	a0,0x4
    1890:	2f450513          	addi	a0,a0,756 # 5b80 <malloc+0xa62>
    1894:	7d0030ef          	jal	ra,5064 <printf>
          exit(1);
    1898:	4505                	li	a0,1
    189a:	3a6030ef          	jal	ra,4c40 <exit>
      for(i = 0; i < N; i++){
    189e:	2485                	addiw	s1,s1,1
    18a0:	05248e63          	beq	s1,s2,18fc <createdelete+0xf6>
        name[1] = '0' + i;
    18a4:	0304879b          	addiw	a5,s1,48
    18a8:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    18ac:	20200593          	li	a1,514
    18b0:	f8040513          	addi	a0,s0,-128
    18b4:	3cc030ef          	jal	ra,4c80 <open>
        if(fd < 0){
    18b8:	fc0549e3          	bltz	a0,188a <createdelete+0x84>
        close(fd);
    18bc:	3ac030ef          	jal	ra,4c68 <close>
        if(i > 0 && (i % 2 ) == 0){
    18c0:	fc905fe3          	blez	s1,189e <createdelete+0x98>
    18c4:	0014f793          	andi	a5,s1,1
    18c8:	fbf9                	bnez	a5,189e <createdelete+0x98>
          name[1] = '0' + (i / 2);
    18ca:	01f4d79b          	srliw	a5,s1,0x1f
    18ce:	9fa5                	addw	a5,a5,s1
    18d0:	4017d79b          	sraiw	a5,a5,0x1
    18d4:	0307879b          	addiw	a5,a5,48
    18d8:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    18dc:	f8040513          	addi	a0,s0,-128
    18e0:	3b0030ef          	jal	ra,4c90 <unlink>
    18e4:	fa055de3          	bgez	a0,189e <createdelete+0x98>
            printf("%s: unlink failed\n", s);
    18e8:	85e6                	mv	a1,s9
    18ea:	00004517          	auipc	a0,0x4
    18ee:	3ee50513          	addi	a0,a0,1006 # 5cd8 <malloc+0xbba>
    18f2:	772030ef          	jal	ra,5064 <printf>
            exit(1);
    18f6:	4505                	li	a0,1
    18f8:	348030ef          	jal	ra,4c40 <exit>
      exit(0);
    18fc:	4501                	li	a0,0
    18fe:	342030ef          	jal	ra,4c40 <exit>
      exit(1);
    1902:	4505                	li	a0,1
    1904:	33c030ef          	jal	ra,4c40 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1908:	f8040613          	addi	a2,s0,-128
    190c:	85e6                	mv	a1,s9
    190e:	00004517          	auipc	a0,0x4
    1912:	3e250513          	addi	a0,a0,994 # 5cf0 <malloc+0xbd2>
    1916:	74e030ef          	jal	ra,5064 <printf>
        exit(1);
    191a:	4505                	li	a0,1
    191c:	324030ef          	jal	ra,4c40 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1920:	034b7d63          	bgeu	s6,s4,195a <createdelete+0x154>
      if(fd >= 0)
    1924:	02055863          	bgez	a0,1954 <createdelete+0x14e>
    for(pi = 0; pi < NCHILD; pi++){
    1928:	2485                	addiw	s1,s1,1
    192a:	0ff4f493          	andi	s1,s1,255
    192e:	05548463          	beq	s1,s5,1976 <createdelete+0x170>
      name[0] = 'p' + pi;
    1932:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1936:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    193a:	4581                	li	a1,0
    193c:	f8040513          	addi	a0,s0,-128
    1940:	340030ef          	jal	ra,4c80 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1944:	00090463          	beqz	s2,194c <createdelete+0x146>
    1948:	fd2bdce3          	bge	s7,s2,1920 <createdelete+0x11a>
    194c:	fa054ee3          	bltz	a0,1908 <createdelete+0x102>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1950:	014b7763          	bgeu	s6,s4,195e <createdelete+0x158>
        close(fd);
    1954:	314030ef          	jal	ra,4c68 <close>
    1958:	bfc1                	j	1928 <createdelete+0x122>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    195a:	fc0547e3          	bltz	a0,1928 <createdelete+0x122>
        printf("%s: oops createdelete %s did exist\n", s, name);
    195e:	f8040613          	addi	a2,s0,-128
    1962:	85e6                	mv	a1,s9
    1964:	00004517          	auipc	a0,0x4
    1968:	3b450513          	addi	a0,a0,948 # 5d18 <malloc+0xbfa>
    196c:	6f8030ef          	jal	ra,5064 <printf>
        exit(1);
    1970:	4505                	li	a0,1
    1972:	2ce030ef          	jal	ra,4c40 <exit>
  for(i = 0; i < N; i++){
    1976:	2905                	addiw	s2,s2,1
    1978:	2a05                	addiw	s4,s4,1
    197a:	2985                	addiw	s3,s3,1
    197c:	0ff9f993          	andi	s3,s3,255
    1980:	47d1                	li	a5,20
    1982:	02f90863          	beq	s2,a5,19b2 <createdelete+0x1ac>
    for(pi = 0; pi < NCHILD; pi++){
    1986:	84e2                	mv	s1,s8
    1988:	b76d                	j	1932 <createdelete+0x12c>
  for(i = 0; i < N; i++){
    198a:	2905                	addiw	s2,s2,1
    198c:	0ff97913          	andi	s2,s2,255
    1990:	03490a63          	beq	s2,s4,19c4 <createdelete+0x1be>
  name[0] = name[1] = name[2] = 0;
    1994:	84d6                	mv	s1,s5
      name[0] = 'p' + pi;
    1996:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    199a:	f92400a3          	sb	s2,-127(s0)
      unlink(name);
    199e:	f8040513          	addi	a0,s0,-128
    19a2:	2ee030ef          	jal	ra,4c90 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    19a6:	2485                	addiw	s1,s1,1
    19a8:	0ff4f493          	andi	s1,s1,255
    19ac:	ff3495e3          	bne	s1,s3,1996 <createdelete+0x190>
    19b0:	bfe9                	j	198a <createdelete+0x184>
    19b2:	03000913          	li	s2,48
  name[0] = name[1] = name[2] = 0;
    19b6:	07000a93          	li	s5,112
    for(pi = 0; pi < NCHILD; pi++){
    19ba:	07400993          	li	s3,116
  for(i = 0; i < N; i++){
    19be:	04400a13          	li	s4,68
    19c2:	bfc9                	j	1994 <createdelete+0x18e>
}
    19c4:	60aa                	ld	ra,136(sp)
    19c6:	640a                	ld	s0,128(sp)
    19c8:	74e6                	ld	s1,120(sp)
    19ca:	7946                	ld	s2,112(sp)
    19cc:	79a6                	ld	s3,104(sp)
    19ce:	7a06                	ld	s4,96(sp)
    19d0:	6ae6                	ld	s5,88(sp)
    19d2:	6b46                	ld	s6,80(sp)
    19d4:	6ba6                	ld	s7,72(sp)
    19d6:	6c06                	ld	s8,64(sp)
    19d8:	7ce2                	ld	s9,56(sp)
    19da:	6149                	addi	sp,sp,144
    19dc:	8082                	ret

00000000000019de <linkunlink>:
{
    19de:	711d                	addi	sp,sp,-96
    19e0:	ec86                	sd	ra,88(sp)
    19e2:	e8a2                	sd	s0,80(sp)
    19e4:	e4a6                	sd	s1,72(sp)
    19e6:	e0ca                	sd	s2,64(sp)
    19e8:	fc4e                	sd	s3,56(sp)
    19ea:	f852                	sd	s4,48(sp)
    19ec:	f456                	sd	s5,40(sp)
    19ee:	f05a                	sd	s6,32(sp)
    19f0:	ec5e                	sd	s7,24(sp)
    19f2:	e862                	sd	s8,16(sp)
    19f4:	e466                	sd	s9,8(sp)
    19f6:	1080                	addi	s0,sp,96
    19f8:	84aa                	mv	s1,a0
  unlink("x");
    19fa:	00004517          	auipc	a0,0x4
    19fe:	8ce50513          	addi	a0,a0,-1842 # 52c8 <malloc+0x1aa>
    1a02:	28e030ef          	jal	ra,4c90 <unlink>
  pid = fork();
    1a06:	232030ef          	jal	ra,4c38 <fork>
  if(pid < 0){
    1a0a:	02054b63          	bltz	a0,1a40 <linkunlink+0x62>
    1a0e:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1a10:	4c85                	li	s9,1
    1a12:	e119                	bnez	a0,1a18 <linkunlink+0x3a>
    1a14:	06100c93          	li	s9,97
    1a18:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1a1c:	41c659b7          	lui	s3,0x41c65
    1a20:	e6d9899b          	addiw	s3,s3,-403
    1a24:	690d                	lui	s2,0x3
    1a26:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    1a2a:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    1a2c:	4b05                	li	s6,1
      unlink("x");
    1a2e:	00004a97          	auipc	s5,0x4
    1a32:	89aa8a93          	addi	s5,s5,-1894 # 52c8 <malloc+0x1aa>
      link("cat", "x");
    1a36:	00004b97          	auipc	s7,0x4
    1a3a:	30ab8b93          	addi	s7,s7,778 # 5d40 <malloc+0xc22>
    1a3e:	a025                	j	1a66 <linkunlink+0x88>
    printf("%s: fork failed\n", s);
    1a40:	85a6                	mv	a1,s1
    1a42:	00004517          	auipc	a0,0x4
    1a46:	0a650513          	addi	a0,a0,166 # 5ae8 <malloc+0x9ca>
    1a4a:	61a030ef          	jal	ra,5064 <printf>
    exit(1);
    1a4e:	4505                	li	a0,1
    1a50:	1f0030ef          	jal	ra,4c40 <exit>
      close(open("x", O_RDWR | O_CREATE));
    1a54:	20200593          	li	a1,514
    1a58:	8556                	mv	a0,s5
    1a5a:	226030ef          	jal	ra,4c80 <open>
    1a5e:	20a030ef          	jal	ra,4c68 <close>
  for(i = 0; i < 100; i++){
    1a62:	34fd                	addiw	s1,s1,-1
    1a64:	c48d                	beqz	s1,1a8e <linkunlink+0xb0>
    x = x * 1103515245 + 12345;
    1a66:	033c87bb          	mulw	a5,s9,s3
    1a6a:	012787bb          	addw	a5,a5,s2
    1a6e:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    1a72:	0347f7bb          	remuw	a5,a5,s4
    1a76:	dff9                	beqz	a5,1a54 <linkunlink+0x76>
    } else if((x % 3) == 1){
    1a78:	01678663          	beq	a5,s6,1a84 <linkunlink+0xa6>
      unlink("x");
    1a7c:	8556                	mv	a0,s5
    1a7e:	212030ef          	jal	ra,4c90 <unlink>
    1a82:	b7c5                	j	1a62 <linkunlink+0x84>
      link("cat", "x");
    1a84:	85d6                	mv	a1,s5
    1a86:	855e                	mv	a0,s7
    1a88:	218030ef          	jal	ra,4ca0 <link>
    1a8c:	bfd9                	j	1a62 <linkunlink+0x84>
  if(pid)
    1a8e:	020c0263          	beqz	s8,1ab2 <linkunlink+0xd4>
    wait(0);
    1a92:	4501                	li	a0,0
    1a94:	1b4030ef          	jal	ra,4c48 <wait>
}
    1a98:	60e6                	ld	ra,88(sp)
    1a9a:	6446                	ld	s0,80(sp)
    1a9c:	64a6                	ld	s1,72(sp)
    1a9e:	6906                	ld	s2,64(sp)
    1aa0:	79e2                	ld	s3,56(sp)
    1aa2:	7a42                	ld	s4,48(sp)
    1aa4:	7aa2                	ld	s5,40(sp)
    1aa6:	7b02                	ld	s6,32(sp)
    1aa8:	6be2                	ld	s7,24(sp)
    1aaa:	6c42                	ld	s8,16(sp)
    1aac:	6ca2                	ld	s9,8(sp)
    1aae:	6125                	addi	sp,sp,96
    1ab0:	8082                	ret
    exit(0);
    1ab2:	4501                	li	a0,0
    1ab4:	18c030ef          	jal	ra,4c40 <exit>

0000000000001ab8 <forktest>:
{
    1ab8:	7179                	addi	sp,sp,-48
    1aba:	f406                	sd	ra,40(sp)
    1abc:	f022                	sd	s0,32(sp)
    1abe:	ec26                	sd	s1,24(sp)
    1ac0:	e84a                	sd	s2,16(sp)
    1ac2:	e44e                	sd	s3,8(sp)
    1ac4:	1800                	addi	s0,sp,48
    1ac6:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    1ac8:	4481                	li	s1,0
    1aca:	3e800913          	li	s2,1000
    pid = fork();
    1ace:	16a030ef          	jal	ra,4c38 <fork>
    if(pid < 0)
    1ad2:	02054263          	bltz	a0,1af6 <forktest+0x3e>
    if(pid == 0)
    1ad6:	cd11                	beqz	a0,1af2 <forktest+0x3a>
  for(n=0; n<N; n++){
    1ad8:	2485                	addiw	s1,s1,1
    1ada:	ff249ae3          	bne	s1,s2,1ace <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    1ade:	85ce                	mv	a1,s3
    1ae0:	00004517          	auipc	a0,0x4
    1ae4:	28050513          	addi	a0,a0,640 # 5d60 <malloc+0xc42>
    1ae8:	57c030ef          	jal	ra,5064 <printf>
    exit(1);
    1aec:	4505                	li	a0,1
    1aee:	152030ef          	jal	ra,4c40 <exit>
      exit(0);
    1af2:	14e030ef          	jal	ra,4c40 <exit>
  if (n == 0) {
    1af6:	c89d                	beqz	s1,1b2c <forktest+0x74>
  if(n == N){
    1af8:	3e800793          	li	a5,1000
    1afc:	fef481e3          	beq	s1,a5,1ade <forktest+0x26>
  for(; n > 0; n--){
    1b00:	00905963          	blez	s1,1b12 <forktest+0x5a>
    if(wait(0) < 0){
    1b04:	4501                	li	a0,0
    1b06:	142030ef          	jal	ra,4c48 <wait>
    1b0a:	02054b63          	bltz	a0,1b40 <forktest+0x88>
  for(; n > 0; n--){
    1b0e:	34fd                	addiw	s1,s1,-1
    1b10:	f8f5                	bnez	s1,1b04 <forktest+0x4c>
  if(wait(0) != -1){
    1b12:	4501                	li	a0,0
    1b14:	134030ef          	jal	ra,4c48 <wait>
    1b18:	57fd                	li	a5,-1
    1b1a:	02f51d63          	bne	a0,a5,1b54 <forktest+0x9c>
}
    1b1e:	70a2                	ld	ra,40(sp)
    1b20:	7402                	ld	s0,32(sp)
    1b22:	64e2                	ld	s1,24(sp)
    1b24:	6942                	ld	s2,16(sp)
    1b26:	69a2                	ld	s3,8(sp)
    1b28:	6145                	addi	sp,sp,48
    1b2a:	8082                	ret
    printf("%s: no fork at all!\n", s);
    1b2c:	85ce                	mv	a1,s3
    1b2e:	00004517          	auipc	a0,0x4
    1b32:	21a50513          	addi	a0,a0,538 # 5d48 <malloc+0xc2a>
    1b36:	52e030ef          	jal	ra,5064 <printf>
    exit(1);
    1b3a:	4505                	li	a0,1
    1b3c:	104030ef          	jal	ra,4c40 <exit>
      printf("%s: wait stopped early\n", s);
    1b40:	85ce                	mv	a1,s3
    1b42:	00004517          	auipc	a0,0x4
    1b46:	24650513          	addi	a0,a0,582 # 5d88 <malloc+0xc6a>
    1b4a:	51a030ef          	jal	ra,5064 <printf>
      exit(1);
    1b4e:	4505                	li	a0,1
    1b50:	0f0030ef          	jal	ra,4c40 <exit>
    printf("%s: wait got too many\n", s);
    1b54:	85ce                	mv	a1,s3
    1b56:	00004517          	auipc	a0,0x4
    1b5a:	24a50513          	addi	a0,a0,586 # 5da0 <malloc+0xc82>
    1b5e:	506030ef          	jal	ra,5064 <printf>
    exit(1);
    1b62:	4505                	li	a0,1
    1b64:	0dc030ef          	jal	ra,4c40 <exit>

0000000000001b68 <kernmem>:
{
    1b68:	715d                	addi	sp,sp,-80
    1b6a:	e486                	sd	ra,72(sp)
    1b6c:	e0a2                	sd	s0,64(sp)
    1b6e:	fc26                	sd	s1,56(sp)
    1b70:	f84a                	sd	s2,48(sp)
    1b72:	f44e                	sd	s3,40(sp)
    1b74:	f052                	sd	s4,32(sp)
    1b76:	ec56                	sd	s5,24(sp)
    1b78:	0880                	addi	s0,sp,80
    1b7a:	8a2a                	mv	s4,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1b7c:	4485                	li	s1,1
    1b7e:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    1b80:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1b82:	69b1                	lui	s3,0xc
    1b84:	35098993          	addi	s3,s3,848 # c350 <buf+0x6a8>
    1b88:	1003d937          	lui	s2,0x1003d
    1b8c:	090e                	slli	s2,s2,0x3
    1b8e:	48090913          	addi	s2,s2,1152 # 1003d480 <base+0x1002e7d8>
    pid = fork();
    1b92:	0a6030ef          	jal	ra,4c38 <fork>
    if(pid < 0){
    1b96:	02054763          	bltz	a0,1bc4 <kernmem+0x5c>
    if(pid == 0){
    1b9a:	cd1d                	beqz	a0,1bd8 <kernmem+0x70>
    wait(&xstatus);
    1b9c:	fbc40513          	addi	a0,s0,-68
    1ba0:	0a8030ef          	jal	ra,4c48 <wait>
    if(xstatus != -1)  // did kernel kill child?
    1ba4:	fbc42783          	lw	a5,-68(s0)
    1ba8:	05579563          	bne	a5,s5,1bf2 <kernmem+0x8a>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1bac:	94ce                	add	s1,s1,s3
    1bae:	ff2492e3          	bne	s1,s2,1b92 <kernmem+0x2a>
}
    1bb2:	60a6                	ld	ra,72(sp)
    1bb4:	6406                	ld	s0,64(sp)
    1bb6:	74e2                	ld	s1,56(sp)
    1bb8:	7942                	ld	s2,48(sp)
    1bba:	79a2                	ld	s3,40(sp)
    1bbc:	7a02                	ld	s4,32(sp)
    1bbe:	6ae2                	ld	s5,24(sp)
    1bc0:	6161                	addi	sp,sp,80
    1bc2:	8082                	ret
      printf("%s: fork failed\n", s);
    1bc4:	85d2                	mv	a1,s4
    1bc6:	00004517          	auipc	a0,0x4
    1bca:	f2250513          	addi	a0,a0,-222 # 5ae8 <malloc+0x9ca>
    1bce:	496030ef          	jal	ra,5064 <printf>
      exit(1);
    1bd2:	4505                	li	a0,1
    1bd4:	06c030ef          	jal	ra,4c40 <exit>
      printf("%s: oops could read %p = %x\n", s, a, *a);
    1bd8:	0004c683          	lbu	a3,0(s1)
    1bdc:	8626                	mv	a2,s1
    1bde:	85d2                	mv	a1,s4
    1be0:	00004517          	auipc	a0,0x4
    1be4:	1d850513          	addi	a0,a0,472 # 5db8 <malloc+0xc9a>
    1be8:	47c030ef          	jal	ra,5064 <printf>
      exit(1);
    1bec:	4505                	li	a0,1
    1bee:	052030ef          	jal	ra,4c40 <exit>
      exit(1);
    1bf2:	4505                	li	a0,1
    1bf4:	04c030ef          	jal	ra,4c40 <exit>

0000000000001bf8 <MAXVAplus>:
{
    1bf8:	7179                	addi	sp,sp,-48
    1bfa:	f406                	sd	ra,40(sp)
    1bfc:	f022                	sd	s0,32(sp)
    1bfe:	ec26                	sd	s1,24(sp)
    1c00:	e84a                	sd	s2,16(sp)
    1c02:	1800                	addi	s0,sp,48
  volatile uint64 a = MAXVA;
    1c04:	4785                	li	a5,1
    1c06:	179a                	slli	a5,a5,0x26
    1c08:	fcf43c23          	sd	a5,-40(s0)
  for( ; a != 0; a <<= 1){
    1c0c:	fd843783          	ld	a5,-40(s0)
    1c10:	cb85                	beqz	a5,1c40 <MAXVAplus+0x48>
    1c12:	892a                	mv	s2,a0
    if(xstatus != -1)  // did kernel kill child?
    1c14:	54fd                	li	s1,-1
    pid = fork();
    1c16:	022030ef          	jal	ra,4c38 <fork>
    if(pid < 0){
    1c1a:	02054963          	bltz	a0,1c4c <MAXVAplus+0x54>
    if(pid == 0){
    1c1e:	c129                	beqz	a0,1c60 <MAXVAplus+0x68>
    wait(&xstatus);
    1c20:	fd440513          	addi	a0,s0,-44
    1c24:	024030ef          	jal	ra,4c48 <wait>
    if(xstatus != -1)  // did kernel kill child?
    1c28:	fd442783          	lw	a5,-44(s0)
    1c2c:	04979c63          	bne	a5,s1,1c84 <MAXVAplus+0x8c>
  for( ; a != 0; a <<= 1){
    1c30:	fd843783          	ld	a5,-40(s0)
    1c34:	0786                	slli	a5,a5,0x1
    1c36:	fcf43c23          	sd	a5,-40(s0)
    1c3a:	fd843783          	ld	a5,-40(s0)
    1c3e:	ffe1                	bnez	a5,1c16 <MAXVAplus+0x1e>
}
    1c40:	70a2                	ld	ra,40(sp)
    1c42:	7402                	ld	s0,32(sp)
    1c44:	64e2                	ld	s1,24(sp)
    1c46:	6942                	ld	s2,16(sp)
    1c48:	6145                	addi	sp,sp,48
    1c4a:	8082                	ret
      printf("%s: fork failed\n", s);
    1c4c:	85ca                	mv	a1,s2
    1c4e:	00004517          	auipc	a0,0x4
    1c52:	e9a50513          	addi	a0,a0,-358 # 5ae8 <malloc+0x9ca>
    1c56:	40e030ef          	jal	ra,5064 <printf>
      exit(1);
    1c5a:	4505                	li	a0,1
    1c5c:	7e5020ef          	jal	ra,4c40 <exit>
      *(char*)a = 99;
    1c60:	fd843783          	ld	a5,-40(s0)
    1c64:	06300713          	li	a4,99
    1c68:	00e78023          	sb	a4,0(a5)
      printf("%s: oops wrote %p\n", s, (void*)a);
    1c6c:	fd843603          	ld	a2,-40(s0)
    1c70:	85ca                	mv	a1,s2
    1c72:	00004517          	auipc	a0,0x4
    1c76:	16650513          	addi	a0,a0,358 # 5dd8 <malloc+0xcba>
    1c7a:	3ea030ef          	jal	ra,5064 <printf>
      exit(1);
    1c7e:	4505                	li	a0,1
    1c80:	7c1020ef          	jal	ra,4c40 <exit>
      exit(1);
    1c84:	4505                	li	a0,1
    1c86:	7bb020ef          	jal	ra,4c40 <exit>

0000000000001c8a <stacktest>:
{
    1c8a:	7179                	addi	sp,sp,-48
    1c8c:	f406                	sd	ra,40(sp)
    1c8e:	f022                	sd	s0,32(sp)
    1c90:	ec26                	sd	s1,24(sp)
    1c92:	1800                	addi	s0,sp,48
    1c94:	84aa                	mv	s1,a0
  pid = fork();
    1c96:	7a3020ef          	jal	ra,4c38 <fork>
  if(pid == 0) {
    1c9a:	cd11                	beqz	a0,1cb6 <stacktest+0x2c>
  } else if(pid < 0){
    1c9c:	02054c63          	bltz	a0,1cd4 <stacktest+0x4a>
  wait(&xstatus);
    1ca0:	fdc40513          	addi	a0,s0,-36
    1ca4:	7a5020ef          	jal	ra,4c48 <wait>
  if(xstatus == -1)  // kernel killed child?
    1ca8:	fdc42503          	lw	a0,-36(s0)
    1cac:	57fd                	li	a5,-1
    1cae:	02f50d63          	beq	a0,a5,1ce8 <stacktest+0x5e>
    exit(xstatus);
    1cb2:	78f020ef          	jal	ra,4c40 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    1cb6:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %d\n", s, *sp);
    1cb8:	77fd                	lui	a5,0xfffff
    1cba:	97ba                	add	a5,a5,a4
    1cbc:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <base+0xffffffffffff0358>
    1cc0:	85a6                	mv	a1,s1
    1cc2:	00004517          	auipc	a0,0x4
    1cc6:	12e50513          	addi	a0,a0,302 # 5df0 <malloc+0xcd2>
    1cca:	39a030ef          	jal	ra,5064 <printf>
    exit(1);
    1cce:	4505                	li	a0,1
    1cd0:	771020ef          	jal	ra,4c40 <exit>
    printf("%s: fork failed\n", s);
    1cd4:	85a6                	mv	a1,s1
    1cd6:	00004517          	auipc	a0,0x4
    1cda:	e1250513          	addi	a0,a0,-494 # 5ae8 <malloc+0x9ca>
    1cde:	386030ef          	jal	ra,5064 <printf>
    exit(1);
    1ce2:	4505                	li	a0,1
    1ce4:	75d020ef          	jal	ra,4c40 <exit>
    exit(0);
    1ce8:	4501                	li	a0,0
    1cea:	757020ef          	jal	ra,4c40 <exit>

0000000000001cee <nowrite>:
{
    1cee:	7159                	addi	sp,sp,-112
    1cf0:	f486                	sd	ra,104(sp)
    1cf2:	f0a2                	sd	s0,96(sp)
    1cf4:	eca6                	sd	s1,88(sp)
    1cf6:	e8ca                	sd	s2,80(sp)
    1cf8:	e4ce                	sd	s3,72(sp)
    1cfa:	1880                	addi	s0,sp,112
    1cfc:	89aa                	mv	s3,a0
  uint64 addrs[] = { 0, 0x80000000LL, 0x3fffffe000, 0x3ffffff000, 0x4000000000,
    1cfe:	00006797          	auipc	a5,0x6
    1d02:	98278793          	addi	a5,a5,-1662 # 7680 <malloc+0x2562>
    1d06:	7788                	ld	a0,40(a5)
    1d08:	7b8c                	ld	a1,48(a5)
    1d0a:	7f90                	ld	a2,56(a5)
    1d0c:	63b4                	ld	a3,64(a5)
    1d0e:	67b8                	ld	a4,72(a5)
    1d10:	6bbc                	ld	a5,80(a5)
    1d12:	f8a43c23          	sd	a0,-104(s0)
    1d16:	fab43023          	sd	a1,-96(s0)
    1d1a:	fac43423          	sd	a2,-88(s0)
    1d1e:	fad43823          	sd	a3,-80(s0)
    1d22:	fae43c23          	sd	a4,-72(s0)
    1d26:	fcf43023          	sd	a5,-64(s0)
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
    1d2a:	4481                	li	s1,0
    1d2c:	4919                	li	s2,6
    pid = fork();
    1d2e:	70b020ef          	jal	ra,4c38 <fork>
    if(pid == 0) {
    1d32:	c105                	beqz	a0,1d52 <nowrite+0x64>
    } else if(pid < 0){
    1d34:	04054163          	bltz	a0,1d76 <nowrite+0x88>
    wait(&xstatus);
    1d38:	fcc40513          	addi	a0,s0,-52
    1d3c:	70d020ef          	jal	ra,4c48 <wait>
    if(xstatus == 0){
    1d40:	fcc42783          	lw	a5,-52(s0)
    1d44:	c3b9                	beqz	a5,1d8a <nowrite+0x9c>
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
    1d46:	2485                	addiw	s1,s1,1
    1d48:	ff2493e3          	bne	s1,s2,1d2e <nowrite+0x40>
  exit(0);
    1d4c:	4501                	li	a0,0
    1d4e:	6f3020ef          	jal	ra,4c40 <exit>
      volatile int *addr = (int *) addrs[ai];
    1d52:	048e                	slli	s1,s1,0x3
    1d54:	fd040793          	addi	a5,s0,-48
    1d58:	94be                	add	s1,s1,a5
    1d5a:	fc84b603          	ld	a2,-56(s1)
      *addr = 10;
    1d5e:	47a9                	li	a5,10
    1d60:	c21c                	sw	a5,0(a2)
      printf("%s: write to %p did not fail!\n", s, addr);
    1d62:	85ce                	mv	a1,s3
    1d64:	00004517          	auipc	a0,0x4
    1d68:	0b450513          	addi	a0,a0,180 # 5e18 <malloc+0xcfa>
    1d6c:	2f8030ef          	jal	ra,5064 <printf>
      exit(0);
    1d70:	4501                	li	a0,0
    1d72:	6cf020ef          	jal	ra,4c40 <exit>
      printf("%s: fork failed\n", s);
    1d76:	85ce                	mv	a1,s3
    1d78:	00004517          	auipc	a0,0x4
    1d7c:	d7050513          	addi	a0,a0,-656 # 5ae8 <malloc+0x9ca>
    1d80:	2e4030ef          	jal	ra,5064 <printf>
      exit(1);
    1d84:	4505                	li	a0,1
    1d86:	6bb020ef          	jal	ra,4c40 <exit>
      exit(1);
    1d8a:	4505                	li	a0,1
    1d8c:	6b5020ef          	jal	ra,4c40 <exit>

0000000000001d90 <manywrites>:
{
    1d90:	711d                	addi	sp,sp,-96
    1d92:	ec86                	sd	ra,88(sp)
    1d94:	e8a2                	sd	s0,80(sp)
    1d96:	e4a6                	sd	s1,72(sp)
    1d98:	e0ca                	sd	s2,64(sp)
    1d9a:	fc4e                	sd	s3,56(sp)
    1d9c:	f852                	sd	s4,48(sp)
    1d9e:	f456                	sd	s5,40(sp)
    1da0:	f05a                	sd	s6,32(sp)
    1da2:	ec5e                	sd	s7,24(sp)
    1da4:	1080                	addi	s0,sp,96
    1da6:	8aaa                	mv	s5,a0
  for(int ci = 0; ci < nchildren; ci++){
    1da8:	4981                	li	s3,0
    1daa:	4911                	li	s2,4
    int pid = fork();
    1dac:	68d020ef          	jal	ra,4c38 <fork>
    1db0:	84aa                	mv	s1,a0
    if(pid < 0){
    1db2:	02054563          	bltz	a0,1ddc <manywrites+0x4c>
    if(pid == 0){
    1db6:	cd05                	beqz	a0,1dee <manywrites+0x5e>
  for(int ci = 0; ci < nchildren; ci++){
    1db8:	2985                	addiw	s3,s3,1
    1dba:	ff2999e3          	bne	s3,s2,1dac <manywrites+0x1c>
    1dbe:	4491                	li	s1,4
    int st = 0;
    1dc0:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    1dc4:	fa840513          	addi	a0,s0,-88
    1dc8:	681020ef          	jal	ra,4c48 <wait>
    if(st != 0)
    1dcc:	fa842503          	lw	a0,-88(s0)
    1dd0:	e169                	bnez	a0,1e92 <manywrites+0x102>
  for(int ci = 0; ci < nchildren; ci++){
    1dd2:	34fd                	addiw	s1,s1,-1
    1dd4:	f4f5                	bnez	s1,1dc0 <manywrites+0x30>
  exit(0);
    1dd6:	4501                	li	a0,0
    1dd8:	669020ef          	jal	ra,4c40 <exit>
      printf("fork failed\n");
    1ddc:	00005517          	auipc	a0,0x5
    1de0:	29450513          	addi	a0,a0,660 # 7070 <malloc+0x1f52>
    1de4:	280030ef          	jal	ra,5064 <printf>
      exit(1);
    1de8:	4505                	li	a0,1
    1dea:	657020ef          	jal	ra,4c40 <exit>
      name[0] = 'b';
    1dee:	06200793          	li	a5,98
    1df2:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    1df6:	0619879b          	addiw	a5,s3,97
    1dfa:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    1dfe:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    1e02:	fa840513          	addi	a0,s0,-88
    1e06:	68b020ef          	jal	ra,4c90 <unlink>
    1e0a:	4bf9                	li	s7,30
          int cc = write(fd, buf, sz);
    1e0c:	0000ab17          	auipc	s6,0xa
    1e10:	e9cb0b13          	addi	s6,s6,-356 # bca8 <buf>
        for(int i = 0; i < ci+1; i++){
    1e14:	8a26                	mv	s4,s1
    1e16:	0209c863          	bltz	s3,1e46 <manywrites+0xb6>
          int fd = open(name, O_CREATE | O_RDWR);
    1e1a:	20200593          	li	a1,514
    1e1e:	fa840513          	addi	a0,s0,-88
    1e22:	65f020ef          	jal	ra,4c80 <open>
    1e26:	892a                	mv	s2,a0
          if(fd < 0){
    1e28:	02054d63          	bltz	a0,1e62 <manywrites+0xd2>
          int cc = write(fd, buf, sz);
    1e2c:	660d                	lui	a2,0x3
    1e2e:	85da                	mv	a1,s6
    1e30:	631020ef          	jal	ra,4c60 <write>
          if(cc != sz){
    1e34:	678d                	lui	a5,0x3
    1e36:	04f51263          	bne	a0,a5,1e7a <manywrites+0xea>
          close(fd);
    1e3a:	854a                	mv	a0,s2
    1e3c:	62d020ef          	jal	ra,4c68 <close>
        for(int i = 0; i < ci+1; i++){
    1e40:	2a05                	addiw	s4,s4,1
    1e42:	fd49dce3          	bge	s3,s4,1e1a <manywrites+0x8a>
        unlink(name);
    1e46:	fa840513          	addi	a0,s0,-88
    1e4a:	647020ef          	jal	ra,4c90 <unlink>
      for(int iters = 0; iters < howmany; iters++){
    1e4e:	3bfd                	addiw	s7,s7,-1
    1e50:	fc0b92e3          	bnez	s7,1e14 <manywrites+0x84>
      unlink(name);
    1e54:	fa840513          	addi	a0,s0,-88
    1e58:	639020ef          	jal	ra,4c90 <unlink>
      exit(0);
    1e5c:	4501                	li	a0,0
    1e5e:	5e3020ef          	jal	ra,4c40 <exit>
            printf("%s: cannot create %s\n", s, name);
    1e62:	fa840613          	addi	a2,s0,-88
    1e66:	85d6                	mv	a1,s5
    1e68:	00004517          	auipc	a0,0x4
    1e6c:	fd050513          	addi	a0,a0,-48 # 5e38 <malloc+0xd1a>
    1e70:	1f4030ef          	jal	ra,5064 <printf>
            exit(1);
    1e74:	4505                	li	a0,1
    1e76:	5cb020ef          	jal	ra,4c40 <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    1e7a:	86aa                	mv	a3,a0
    1e7c:	660d                	lui	a2,0x3
    1e7e:	85d6                	mv	a1,s5
    1e80:	00003517          	auipc	a0,0x3
    1e84:	4a850513          	addi	a0,a0,1192 # 5328 <malloc+0x20a>
    1e88:	1dc030ef          	jal	ra,5064 <printf>
            exit(1);
    1e8c:	4505                	li	a0,1
    1e8e:	5b3020ef          	jal	ra,4c40 <exit>
      exit(st);
    1e92:	5af020ef          	jal	ra,4c40 <exit>

0000000000001e96 <copyinstr3>:
{
    1e96:	7179                	addi	sp,sp,-48
    1e98:	f406                	sd	ra,40(sp)
    1e9a:	f022                	sd	s0,32(sp)
    1e9c:	ec26                	sd	s1,24(sp)
    1e9e:	1800                	addi	s0,sp,48
  sbrk(8192);
    1ea0:	6509                	lui	a0,0x2
    1ea2:	56b020ef          	jal	ra,4c0c <sbrk>
  uint64 top = (uint64) sbrk(0);
    1ea6:	4501                	li	a0,0
    1ea8:	565020ef          	jal	ra,4c0c <sbrk>
  if((top % PGSIZE) != 0){
    1eac:	03451793          	slli	a5,a0,0x34
    1eb0:	e7bd                	bnez	a5,1f1e <copyinstr3+0x88>
  top = (uint64) sbrk(0);
    1eb2:	4501                	li	a0,0
    1eb4:	559020ef          	jal	ra,4c0c <sbrk>
  if(top % PGSIZE){
    1eb8:	03451793          	slli	a5,a0,0x34
    1ebc:	ebad                	bnez	a5,1f2e <copyinstr3+0x98>
  char *b = (char *) (top - 1);
    1ebe:	fff50493          	addi	s1,a0,-1 # 1fff <rwsbrk+0x65>
  *b = 'x';
    1ec2:	07800793          	li	a5,120
    1ec6:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    1eca:	8526                	mv	a0,s1
    1ecc:	5c5020ef          	jal	ra,4c90 <unlink>
  if(ret != -1){
    1ed0:	57fd                	li	a5,-1
    1ed2:	06f51763          	bne	a0,a5,1f40 <copyinstr3+0xaa>
  int fd = open(b, O_CREATE | O_WRONLY);
    1ed6:	20100593          	li	a1,513
    1eda:	8526                	mv	a0,s1
    1edc:	5a5020ef          	jal	ra,4c80 <open>
  if(fd != -1){
    1ee0:	57fd                	li	a5,-1
    1ee2:	06f51a63          	bne	a0,a5,1f56 <copyinstr3+0xc0>
  ret = link(b, b);
    1ee6:	85a6                	mv	a1,s1
    1ee8:	8526                	mv	a0,s1
    1eea:	5b7020ef          	jal	ra,4ca0 <link>
  if(ret != -1){
    1eee:	57fd                	li	a5,-1
    1ef0:	06f51e63          	bne	a0,a5,1f6c <copyinstr3+0xd6>
  char *args[] = { "xx", 0 };
    1ef4:	00005797          	auipc	a5,0x5
    1ef8:	c4478793          	addi	a5,a5,-956 # 6b38 <malloc+0x1a1a>
    1efc:	fcf43823          	sd	a5,-48(s0)
    1f00:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    1f04:	fd040593          	addi	a1,s0,-48
    1f08:	8526                	mv	a0,s1
    1f0a:	56f020ef          	jal	ra,4c78 <exec>
  if(ret != -1){
    1f0e:	57fd                	li	a5,-1
    1f10:	06f51a63          	bne	a0,a5,1f84 <copyinstr3+0xee>
}
    1f14:	70a2                	ld	ra,40(sp)
    1f16:	7402                	ld	s0,32(sp)
    1f18:	64e2                	ld	s1,24(sp)
    1f1a:	6145                	addi	sp,sp,48
    1f1c:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    1f1e:	0347d513          	srli	a0,a5,0x34
    1f22:	6785                	lui	a5,0x1
    1f24:	40a7853b          	subw	a0,a5,a0
    1f28:	4e5020ef          	jal	ra,4c0c <sbrk>
    1f2c:	b759                	j	1eb2 <copyinstr3+0x1c>
    printf("oops\n");
    1f2e:	00004517          	auipc	a0,0x4
    1f32:	f2250513          	addi	a0,a0,-222 # 5e50 <malloc+0xd32>
    1f36:	12e030ef          	jal	ra,5064 <printf>
    exit(1);
    1f3a:	4505                	li	a0,1
    1f3c:	505020ef          	jal	ra,4c40 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    1f40:	862a                	mv	a2,a0
    1f42:	85a6                	mv	a1,s1
    1f44:	00004517          	auipc	a0,0x4
    1f48:	ac450513          	addi	a0,a0,-1340 # 5a08 <malloc+0x8ea>
    1f4c:	118030ef          	jal	ra,5064 <printf>
    exit(1);
    1f50:	4505                	li	a0,1
    1f52:	4ef020ef          	jal	ra,4c40 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    1f56:	862a                	mv	a2,a0
    1f58:	85a6                	mv	a1,s1
    1f5a:	00004517          	auipc	a0,0x4
    1f5e:	ace50513          	addi	a0,a0,-1330 # 5a28 <malloc+0x90a>
    1f62:	102030ef          	jal	ra,5064 <printf>
    exit(1);
    1f66:	4505                	li	a0,1
    1f68:	4d9020ef          	jal	ra,4c40 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1f6c:	86aa                	mv	a3,a0
    1f6e:	8626                	mv	a2,s1
    1f70:	85a6                	mv	a1,s1
    1f72:	00004517          	auipc	a0,0x4
    1f76:	ad650513          	addi	a0,a0,-1322 # 5a48 <malloc+0x92a>
    1f7a:	0ea030ef          	jal	ra,5064 <printf>
    exit(1);
    1f7e:	4505                	li	a0,1
    1f80:	4c1020ef          	jal	ra,4c40 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1f84:	567d                	li	a2,-1
    1f86:	85a6                	mv	a1,s1
    1f88:	00004517          	auipc	a0,0x4
    1f8c:	ae850513          	addi	a0,a0,-1304 # 5a70 <malloc+0x952>
    1f90:	0d4030ef          	jal	ra,5064 <printf>
    exit(1);
    1f94:	4505                	li	a0,1
    1f96:	4ab020ef          	jal	ra,4c40 <exit>

0000000000001f9a <rwsbrk>:
{
    1f9a:	1101                	addi	sp,sp,-32
    1f9c:	ec06                	sd	ra,24(sp)
    1f9e:	e822                	sd	s0,16(sp)
    1fa0:	e426                	sd	s1,8(sp)
    1fa2:	e04a                	sd	s2,0(sp)
    1fa4:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    1fa6:	6509                	lui	a0,0x2
    1fa8:	465020ef          	jal	ra,4c0c <sbrk>
  if(a == (uint64) SBRK_ERROR) {
    1fac:	57fd                	li	a5,-1
    1fae:	04f50963          	beq	a0,a5,2000 <rwsbrk+0x66>
    1fb2:	84aa                	mv	s1,a0
  if (sbrk(-8192) == SBRK_ERROR) {
    1fb4:	7579                	lui	a0,0xffffe
    1fb6:	457020ef          	jal	ra,4c0c <sbrk>
    1fba:	57fd                	li	a5,-1
    1fbc:	04f50b63          	beq	a0,a5,2012 <rwsbrk+0x78>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    1fc0:	20100593          	li	a1,513
    1fc4:	00004517          	auipc	a0,0x4
    1fc8:	ecc50513          	addi	a0,a0,-308 # 5e90 <malloc+0xd72>
    1fcc:	4b5020ef          	jal	ra,4c80 <open>
    1fd0:	892a                	mv	s2,a0
  if(fd < 0){
    1fd2:	04054963          	bltz	a0,2024 <rwsbrk+0x8a>
  n = write(fd, (void*)(a+PGSIZE), 1024);
    1fd6:	6505                	lui	a0,0x1
    1fd8:	94aa                	add	s1,s1,a0
    1fda:	40000613          	li	a2,1024
    1fde:	85a6                	mv	a1,s1
    1fe0:	854a                	mv	a0,s2
    1fe2:	47f020ef          	jal	ra,4c60 <write>
    1fe6:	862a                	mv	a2,a0
  if(n >= 0){
    1fe8:	04054763          	bltz	a0,2036 <rwsbrk+0x9c>
    printf("write(fd, %p, 1024) returned %d, not -1\n", (void*)a+PGSIZE, n);
    1fec:	85a6                	mv	a1,s1
    1fee:	00004517          	auipc	a0,0x4
    1ff2:	ec250513          	addi	a0,a0,-318 # 5eb0 <malloc+0xd92>
    1ff6:	06e030ef          	jal	ra,5064 <printf>
    exit(1);
    1ffa:	4505                	li	a0,1
    1ffc:	445020ef          	jal	ra,4c40 <exit>
    printf("sbrk(rwsbrk) failed\n");
    2000:	00004517          	auipc	a0,0x4
    2004:	e5850513          	addi	a0,a0,-424 # 5e58 <malloc+0xd3a>
    2008:	05c030ef          	jal	ra,5064 <printf>
    exit(1);
    200c:	4505                	li	a0,1
    200e:	433020ef          	jal	ra,4c40 <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    2012:	00004517          	auipc	a0,0x4
    2016:	e5e50513          	addi	a0,a0,-418 # 5e70 <malloc+0xd52>
    201a:	04a030ef          	jal	ra,5064 <printf>
    exit(1);
    201e:	4505                	li	a0,1
    2020:	421020ef          	jal	ra,4c40 <exit>
    printf("open(rwsbrk) failed\n");
    2024:	00004517          	auipc	a0,0x4
    2028:	e7450513          	addi	a0,a0,-396 # 5e98 <malloc+0xd7a>
    202c:	038030ef          	jal	ra,5064 <printf>
    exit(1);
    2030:	4505                	li	a0,1
    2032:	40f020ef          	jal	ra,4c40 <exit>
  close(fd);
    2036:	854a                	mv	a0,s2
    2038:	431020ef          	jal	ra,4c68 <close>
  unlink("rwsbrk");
    203c:	00004517          	auipc	a0,0x4
    2040:	e5450513          	addi	a0,a0,-428 # 5e90 <malloc+0xd72>
    2044:	44d020ef          	jal	ra,4c90 <unlink>
  fd = open("README", O_RDONLY);
    2048:	4581                	li	a1,0
    204a:	00003517          	auipc	a0,0x3
    204e:	3e650513          	addi	a0,a0,998 # 5430 <malloc+0x312>
    2052:	42f020ef          	jal	ra,4c80 <open>
    2056:	892a                	mv	s2,a0
  if(fd < 0){
    2058:	02054363          	bltz	a0,207e <rwsbrk+0xe4>
  n = read(fd, (void*)(a+PGSIZE), 10);
    205c:	4629                	li	a2,10
    205e:	85a6                	mv	a1,s1
    2060:	3f9020ef          	jal	ra,4c58 <read>
    2064:	862a                	mv	a2,a0
  if(n >= 0){
    2066:	02054563          	bltz	a0,2090 <rwsbrk+0xf6>
    printf("read(fd, %p, 10) returned %d, not -1\n", (void*)a+PGSIZE, n);
    206a:	85a6                	mv	a1,s1
    206c:	00004517          	auipc	a0,0x4
    2070:	e7450513          	addi	a0,a0,-396 # 5ee0 <malloc+0xdc2>
    2074:	7f1020ef          	jal	ra,5064 <printf>
    exit(1);
    2078:	4505                	li	a0,1
    207a:	3c7020ef          	jal	ra,4c40 <exit>
    printf("open(README) failed\n");
    207e:	00003517          	auipc	a0,0x3
    2082:	3ba50513          	addi	a0,a0,954 # 5438 <malloc+0x31a>
    2086:	7df020ef          	jal	ra,5064 <printf>
    exit(1);
    208a:	4505                	li	a0,1
    208c:	3b5020ef          	jal	ra,4c40 <exit>
  close(fd);
    2090:	854a                	mv	a0,s2
    2092:	3d7020ef          	jal	ra,4c68 <close>
  exit(0);
    2096:	4501                	li	a0,0
    2098:	3a9020ef          	jal	ra,4c40 <exit>

000000000000209c <sbrkbasic>:
{
    209c:	7139                	addi	sp,sp,-64
    209e:	fc06                	sd	ra,56(sp)
    20a0:	f822                	sd	s0,48(sp)
    20a2:	f426                	sd	s1,40(sp)
    20a4:	f04a                	sd	s2,32(sp)
    20a6:	ec4e                	sd	s3,24(sp)
    20a8:	e852                	sd	s4,16(sp)
    20aa:	0080                	addi	s0,sp,64
    20ac:	8a2a                	mv	s4,a0
  pid = fork();
    20ae:	38b020ef          	jal	ra,4c38 <fork>
  if(pid < 0){
    20b2:	02054863          	bltz	a0,20e2 <sbrkbasic+0x46>
  if(pid == 0){
    20b6:	e131                	bnez	a0,20fa <sbrkbasic+0x5e>
    a = sbrk(TOOMUCH);
    20b8:	40000537          	lui	a0,0x40000
    20bc:	351020ef          	jal	ra,4c0c <sbrk>
    if(a == (char*)SBRK_ERROR){
    20c0:	57fd                	li	a5,-1
    20c2:	02f50963          	beq	a0,a5,20f4 <sbrkbasic+0x58>
    for(b = a; b < a+TOOMUCH; b += PGSIZE){
    20c6:	400007b7          	lui	a5,0x40000
    20ca:	97aa                	add	a5,a5,a0
      *b = 99;
    20cc:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += PGSIZE){
    20d0:	6705                	lui	a4,0x1
      *b = 99;
    20d2:	00d50023          	sb	a3,0(a0) # 40000000 <base+0x3fff1358>
    for(b = a; b < a+TOOMUCH; b += PGSIZE){
    20d6:	953a                	add	a0,a0,a4
    20d8:	fef51de3          	bne	a0,a5,20d2 <sbrkbasic+0x36>
    exit(1);
    20dc:	4505                	li	a0,1
    20de:	363020ef          	jal	ra,4c40 <exit>
    printf("fork failed in sbrkbasic\n");
    20e2:	00004517          	auipc	a0,0x4
    20e6:	e2650513          	addi	a0,a0,-474 # 5f08 <malloc+0xdea>
    20ea:	77b020ef          	jal	ra,5064 <printf>
    exit(1);
    20ee:	4505                	li	a0,1
    20f0:	351020ef          	jal	ra,4c40 <exit>
      exit(0);
    20f4:	4501                	li	a0,0
    20f6:	34b020ef          	jal	ra,4c40 <exit>
  wait(&xstatus);
    20fa:	fcc40513          	addi	a0,s0,-52
    20fe:	34b020ef          	jal	ra,4c48 <wait>
  if(xstatus == 1){
    2102:	fcc42703          	lw	a4,-52(s0)
    2106:	4785                	li	a5,1
    2108:	00f70b63          	beq	a4,a5,211e <sbrkbasic+0x82>
  a = sbrk(0);
    210c:	4501                	li	a0,0
    210e:	2ff020ef          	jal	ra,4c0c <sbrk>
    2112:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    2114:	4901                	li	s2,0
    2116:	6985                	lui	s3,0x1
    2118:	38898993          	addi	s3,s3,904 # 1388 <exectest+0x58>
    211c:	a821                	j	2134 <sbrkbasic+0x98>
    printf("%s: too much memory allocated!\n", s);
    211e:	85d2                	mv	a1,s4
    2120:	00004517          	auipc	a0,0x4
    2124:	e0850513          	addi	a0,a0,-504 # 5f28 <malloc+0xe0a>
    2128:	73d020ef          	jal	ra,5064 <printf>
    exit(1);
    212c:	4505                	li	a0,1
    212e:	313020ef          	jal	ra,4c40 <exit>
    a = b + 1;
    2132:	84be                	mv	s1,a5
    b = sbrk(1);
    2134:	4505                	li	a0,1
    2136:	2d7020ef          	jal	ra,4c0c <sbrk>
    if(b != a){
    213a:	04951263          	bne	a0,s1,217e <sbrkbasic+0xe2>
    *b = 1;
    213e:	4785                	li	a5,1
    2140:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    2144:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    2148:	2905                	addiw	s2,s2,1
    214a:	ff3914e3          	bne	s2,s3,2132 <sbrkbasic+0x96>
  pid = fork();
    214e:	2eb020ef          	jal	ra,4c38 <fork>
    2152:	892a                	mv	s2,a0
  if(pid < 0){
    2154:	04054263          	bltz	a0,2198 <sbrkbasic+0xfc>
  c = sbrk(1);
    2158:	4505                	li	a0,1
    215a:	2b3020ef          	jal	ra,4c0c <sbrk>
  c = sbrk(1);
    215e:	4505                	li	a0,1
    2160:	2ad020ef          	jal	ra,4c0c <sbrk>
  if(c != a + 1){
    2164:	0489                	addi	s1,s1,2
    2166:	04a48363          	beq	s1,a0,21ac <sbrkbasic+0x110>
    printf("%s: sbrk test failed post-fork\n", s);
    216a:	85d2                	mv	a1,s4
    216c:	00004517          	auipc	a0,0x4
    2170:	e1c50513          	addi	a0,a0,-484 # 5f88 <malloc+0xe6a>
    2174:	6f1020ef          	jal	ra,5064 <printf>
    exit(1);
    2178:	4505                	li	a0,1
    217a:	2c7020ef          	jal	ra,4c40 <exit>
      printf("%s: sbrk test failed %d %p %p\n", s, i, a, b);
    217e:	872a                	mv	a4,a0
    2180:	86a6                	mv	a3,s1
    2182:	864a                	mv	a2,s2
    2184:	85d2                	mv	a1,s4
    2186:	00004517          	auipc	a0,0x4
    218a:	dc250513          	addi	a0,a0,-574 # 5f48 <malloc+0xe2a>
    218e:	6d7020ef          	jal	ra,5064 <printf>
      exit(1);
    2192:	4505                	li	a0,1
    2194:	2ad020ef          	jal	ra,4c40 <exit>
    printf("%s: sbrk test fork failed\n", s);
    2198:	85d2                	mv	a1,s4
    219a:	00004517          	auipc	a0,0x4
    219e:	dce50513          	addi	a0,a0,-562 # 5f68 <malloc+0xe4a>
    21a2:	6c3020ef          	jal	ra,5064 <printf>
    exit(1);
    21a6:	4505                	li	a0,1
    21a8:	299020ef          	jal	ra,4c40 <exit>
  if(pid == 0)
    21ac:	00091563          	bnez	s2,21b6 <sbrkbasic+0x11a>
    exit(0);
    21b0:	4501                	li	a0,0
    21b2:	28f020ef          	jal	ra,4c40 <exit>
  wait(&xstatus);
    21b6:	fcc40513          	addi	a0,s0,-52
    21ba:	28f020ef          	jal	ra,4c48 <wait>
  exit(xstatus);
    21be:	fcc42503          	lw	a0,-52(s0)
    21c2:	27f020ef          	jal	ra,4c40 <exit>

00000000000021c6 <sbrkmuch>:
{
    21c6:	7179                	addi	sp,sp,-48
    21c8:	f406                	sd	ra,40(sp)
    21ca:	f022                	sd	s0,32(sp)
    21cc:	ec26                	sd	s1,24(sp)
    21ce:	e84a                	sd	s2,16(sp)
    21d0:	e44e                	sd	s3,8(sp)
    21d2:	e052                	sd	s4,0(sp)
    21d4:	1800                	addi	s0,sp,48
    21d6:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    21d8:	4501                	li	a0,0
    21da:	233020ef          	jal	ra,4c0c <sbrk>
    21de:	892a                	mv	s2,a0
  a = sbrk(0);
    21e0:	4501                	li	a0,0
    21e2:	22b020ef          	jal	ra,4c0c <sbrk>
    21e6:	84aa                	mv	s1,a0
  p = sbrk(amt);
    21e8:	06400537          	lui	a0,0x6400
    21ec:	9d05                	subw	a0,a0,s1
    21ee:	21f020ef          	jal	ra,4c0c <sbrk>
  if (p != a) {
    21f2:	08a49763          	bne	s1,a0,2280 <sbrkmuch+0xba>
  *lastaddr = 99;
    21f6:	064007b7          	lui	a5,0x6400
    21fa:	06300713          	li	a4,99
    21fe:	fee78fa3          	sb	a4,-1(a5) # 63fffff <base+0x63f1357>
  a = sbrk(0);
    2202:	4501                	li	a0,0
    2204:	209020ef          	jal	ra,4c0c <sbrk>
    2208:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    220a:	757d                	lui	a0,0xfffff
    220c:	201020ef          	jal	ra,4c0c <sbrk>
  if(c == (char*)SBRK_ERROR){
    2210:	57fd                	li	a5,-1
    2212:	08f50163          	beq	a0,a5,2294 <sbrkmuch+0xce>
  c = sbrk(0);
    2216:	4501                	li	a0,0
    2218:	1f5020ef          	jal	ra,4c0c <sbrk>
  if(c != a - PGSIZE){
    221c:	77fd                	lui	a5,0xfffff
    221e:	97a6                	add	a5,a5,s1
    2220:	08f51463          	bne	a0,a5,22a8 <sbrkmuch+0xe2>
  a = sbrk(0);
    2224:	4501                	li	a0,0
    2226:	1e7020ef          	jal	ra,4c0c <sbrk>
    222a:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    222c:	6505                	lui	a0,0x1
    222e:	1df020ef          	jal	ra,4c0c <sbrk>
    2232:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    2234:	08a49663          	bne	s1,a0,22c0 <sbrkmuch+0xfa>
    2238:	4501                	li	a0,0
    223a:	1d3020ef          	jal	ra,4c0c <sbrk>
    223e:	6785                	lui	a5,0x1
    2240:	97a6                	add	a5,a5,s1
    2242:	06f51f63          	bne	a0,a5,22c0 <sbrkmuch+0xfa>
  if(*lastaddr == 99){
    2246:	064007b7          	lui	a5,0x6400
    224a:	fff7c703          	lbu	a4,-1(a5) # 63fffff <base+0x63f1357>
    224e:	06300793          	li	a5,99
    2252:	08f70363          	beq	a4,a5,22d8 <sbrkmuch+0x112>
  a = sbrk(0);
    2256:	4501                	li	a0,0
    2258:	1b5020ef          	jal	ra,4c0c <sbrk>
    225c:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    225e:	4501                	li	a0,0
    2260:	1ad020ef          	jal	ra,4c0c <sbrk>
    2264:	40a9053b          	subw	a0,s2,a0
    2268:	1a5020ef          	jal	ra,4c0c <sbrk>
  if(c != a){
    226c:	08a49063          	bne	s1,a0,22ec <sbrkmuch+0x126>
}
    2270:	70a2                	ld	ra,40(sp)
    2272:	7402                	ld	s0,32(sp)
    2274:	64e2                	ld	s1,24(sp)
    2276:	6942                	ld	s2,16(sp)
    2278:	69a2                	ld	s3,8(sp)
    227a:	6a02                	ld	s4,0(sp)
    227c:	6145                	addi	sp,sp,48
    227e:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    2280:	85ce                	mv	a1,s3
    2282:	00004517          	auipc	a0,0x4
    2286:	d2650513          	addi	a0,a0,-730 # 5fa8 <malloc+0xe8a>
    228a:	5db020ef          	jal	ra,5064 <printf>
    exit(1);
    228e:	4505                	li	a0,1
    2290:	1b1020ef          	jal	ra,4c40 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    2294:	85ce                	mv	a1,s3
    2296:	00004517          	auipc	a0,0x4
    229a:	d5a50513          	addi	a0,a0,-678 # 5ff0 <malloc+0xed2>
    229e:	5c7020ef          	jal	ra,5064 <printf>
    exit(1);
    22a2:	4505                	li	a0,1
    22a4:	19d020ef          	jal	ra,4c40 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %p c %p\n", s, a, c);
    22a8:	86aa                	mv	a3,a0
    22aa:	8626                	mv	a2,s1
    22ac:	85ce                	mv	a1,s3
    22ae:	00004517          	auipc	a0,0x4
    22b2:	d6250513          	addi	a0,a0,-670 # 6010 <malloc+0xef2>
    22b6:	5af020ef          	jal	ra,5064 <printf>
    exit(1);
    22ba:	4505                	li	a0,1
    22bc:	185020ef          	jal	ra,4c40 <exit>
    printf("%s: sbrk re-allocation failed, a %p c %p\n", s, a, c);
    22c0:	86d2                	mv	a3,s4
    22c2:	8626                	mv	a2,s1
    22c4:	85ce                	mv	a1,s3
    22c6:	00004517          	auipc	a0,0x4
    22ca:	d8a50513          	addi	a0,a0,-630 # 6050 <malloc+0xf32>
    22ce:	597020ef          	jal	ra,5064 <printf>
    exit(1);
    22d2:	4505                	li	a0,1
    22d4:	16d020ef          	jal	ra,4c40 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    22d8:	85ce                	mv	a1,s3
    22da:	00004517          	auipc	a0,0x4
    22de:	da650513          	addi	a0,a0,-602 # 6080 <malloc+0xf62>
    22e2:	583020ef          	jal	ra,5064 <printf>
    exit(1);
    22e6:	4505                	li	a0,1
    22e8:	159020ef          	jal	ra,4c40 <exit>
    printf("%s: sbrk downsize failed, a %p c %p\n", s, a, c);
    22ec:	86aa                	mv	a3,a0
    22ee:	8626                	mv	a2,s1
    22f0:	85ce                	mv	a1,s3
    22f2:	00004517          	auipc	a0,0x4
    22f6:	dc650513          	addi	a0,a0,-570 # 60b8 <malloc+0xf9a>
    22fa:	56b020ef          	jal	ra,5064 <printf>
    exit(1);
    22fe:	4505                	li	a0,1
    2300:	141020ef          	jal	ra,4c40 <exit>

0000000000002304 <sbrkarg>:
{
    2304:	7179                	addi	sp,sp,-48
    2306:	f406                	sd	ra,40(sp)
    2308:	f022                	sd	s0,32(sp)
    230a:	ec26                	sd	s1,24(sp)
    230c:	e84a                	sd	s2,16(sp)
    230e:	e44e                	sd	s3,8(sp)
    2310:	1800                	addi	s0,sp,48
    2312:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    2314:	6505                	lui	a0,0x1
    2316:	0f7020ef          	jal	ra,4c0c <sbrk>
    231a:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    231c:	20100593          	li	a1,513
    2320:	00004517          	auipc	a0,0x4
    2324:	dc050513          	addi	a0,a0,-576 # 60e0 <malloc+0xfc2>
    2328:	159020ef          	jal	ra,4c80 <open>
    232c:	84aa                	mv	s1,a0
  unlink("sbrk");
    232e:	00004517          	auipc	a0,0x4
    2332:	db250513          	addi	a0,a0,-590 # 60e0 <malloc+0xfc2>
    2336:	15b020ef          	jal	ra,4c90 <unlink>
  if(fd < 0)  {
    233a:	0204c963          	bltz	s1,236c <sbrkarg+0x68>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    233e:	6605                	lui	a2,0x1
    2340:	85ca                	mv	a1,s2
    2342:	8526                	mv	a0,s1
    2344:	11d020ef          	jal	ra,4c60 <write>
    2348:	02054c63          	bltz	a0,2380 <sbrkarg+0x7c>
  close(fd);
    234c:	8526                	mv	a0,s1
    234e:	11b020ef          	jal	ra,4c68 <close>
  a = sbrk(PGSIZE);
    2352:	6505                	lui	a0,0x1
    2354:	0b9020ef          	jal	ra,4c0c <sbrk>
  if(pipe((int *) a) != 0){
    2358:	0f9020ef          	jal	ra,4c50 <pipe>
    235c:	ed05                	bnez	a0,2394 <sbrkarg+0x90>
}
    235e:	70a2                	ld	ra,40(sp)
    2360:	7402                	ld	s0,32(sp)
    2362:	64e2                	ld	s1,24(sp)
    2364:	6942                	ld	s2,16(sp)
    2366:	69a2                	ld	s3,8(sp)
    2368:	6145                	addi	sp,sp,48
    236a:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    236c:	85ce                	mv	a1,s3
    236e:	00004517          	auipc	a0,0x4
    2372:	d7a50513          	addi	a0,a0,-646 # 60e8 <malloc+0xfca>
    2376:	4ef020ef          	jal	ra,5064 <printf>
    exit(1);
    237a:	4505                	li	a0,1
    237c:	0c5020ef          	jal	ra,4c40 <exit>
    printf("%s: write sbrk failed\n", s);
    2380:	85ce                	mv	a1,s3
    2382:	00004517          	auipc	a0,0x4
    2386:	d7e50513          	addi	a0,a0,-642 # 6100 <malloc+0xfe2>
    238a:	4db020ef          	jal	ra,5064 <printf>
    exit(1);
    238e:	4505                	li	a0,1
    2390:	0b1020ef          	jal	ra,4c40 <exit>
    printf("%s: pipe() failed\n", s);
    2394:	85ce                	mv	a1,s3
    2396:	00004517          	auipc	a0,0x4
    239a:	85a50513          	addi	a0,a0,-1958 # 5bf0 <malloc+0xad2>
    239e:	4c7020ef          	jal	ra,5064 <printf>
    exit(1);
    23a2:	4505                	li	a0,1
    23a4:	09d020ef          	jal	ra,4c40 <exit>

00000000000023a8 <argptest>:
{
    23a8:	1101                	addi	sp,sp,-32
    23aa:	ec06                	sd	ra,24(sp)
    23ac:	e822                	sd	s0,16(sp)
    23ae:	e426                	sd	s1,8(sp)
    23b0:	e04a                	sd	s2,0(sp)
    23b2:	1000                	addi	s0,sp,32
    23b4:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    23b6:	4581                	li	a1,0
    23b8:	00004517          	auipc	a0,0x4
    23bc:	d6050513          	addi	a0,a0,-672 # 6118 <malloc+0xffa>
    23c0:	0c1020ef          	jal	ra,4c80 <open>
  if (fd < 0) {
    23c4:	02054563          	bltz	a0,23ee <argptest+0x46>
    23c8:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    23ca:	4501                	li	a0,0
    23cc:	041020ef          	jal	ra,4c0c <sbrk>
    23d0:	567d                	li	a2,-1
    23d2:	fff50593          	addi	a1,a0,-1
    23d6:	8526                	mv	a0,s1
    23d8:	081020ef          	jal	ra,4c58 <read>
  close(fd);
    23dc:	8526                	mv	a0,s1
    23de:	08b020ef          	jal	ra,4c68 <close>
}
    23e2:	60e2                	ld	ra,24(sp)
    23e4:	6442                	ld	s0,16(sp)
    23e6:	64a2                	ld	s1,8(sp)
    23e8:	6902                	ld	s2,0(sp)
    23ea:	6105                	addi	sp,sp,32
    23ec:	8082                	ret
    printf("%s: open failed\n", s);
    23ee:	85ca                	mv	a1,s2
    23f0:	00003517          	auipc	a0,0x3
    23f4:	71050513          	addi	a0,a0,1808 # 5b00 <malloc+0x9e2>
    23f8:	46d020ef          	jal	ra,5064 <printf>
    exit(1);
    23fc:	4505                	li	a0,1
    23fe:	043020ef          	jal	ra,4c40 <exit>

0000000000002402 <sbrkbugs>:
{
    2402:	1141                	addi	sp,sp,-16
    2404:	e406                	sd	ra,8(sp)
    2406:	e022                	sd	s0,0(sp)
    2408:	0800                	addi	s0,sp,16
  int pid = fork();
    240a:	02f020ef          	jal	ra,4c38 <fork>
  if(pid < 0){
    240e:	00054c63          	bltz	a0,2426 <sbrkbugs+0x24>
  if(pid == 0){
    2412:	e11d                	bnez	a0,2438 <sbrkbugs+0x36>
    int sz = (uint64) sbrk(0);
    2414:	7f8020ef          	jal	ra,4c0c <sbrk>
    sbrk(-sz);
    2418:	40a0053b          	negw	a0,a0
    241c:	7f0020ef          	jal	ra,4c0c <sbrk>
    exit(0);
    2420:	4501                	li	a0,0
    2422:	01f020ef          	jal	ra,4c40 <exit>
    printf("fork failed\n");
    2426:	00005517          	auipc	a0,0x5
    242a:	c4a50513          	addi	a0,a0,-950 # 7070 <malloc+0x1f52>
    242e:	437020ef          	jal	ra,5064 <printf>
    exit(1);
    2432:	4505                	li	a0,1
    2434:	00d020ef          	jal	ra,4c40 <exit>
  wait(0);
    2438:	4501                	li	a0,0
    243a:	00f020ef          	jal	ra,4c48 <wait>
  pid = fork();
    243e:	7fa020ef          	jal	ra,4c38 <fork>
  if(pid < 0){
    2442:	00054f63          	bltz	a0,2460 <sbrkbugs+0x5e>
  if(pid == 0){
    2446:	e515                	bnez	a0,2472 <sbrkbugs+0x70>
    int sz = (uint64) sbrk(0);
    2448:	7c4020ef          	jal	ra,4c0c <sbrk>
    sbrk(-(sz - 3500));
    244c:	6785                	lui	a5,0x1
    244e:	dac7879b          	addiw	a5,a5,-596
    2452:	40a7853b          	subw	a0,a5,a0
    2456:	7b6020ef          	jal	ra,4c0c <sbrk>
    exit(0);
    245a:	4501                	li	a0,0
    245c:	7e4020ef          	jal	ra,4c40 <exit>
    printf("fork failed\n");
    2460:	00005517          	auipc	a0,0x5
    2464:	c1050513          	addi	a0,a0,-1008 # 7070 <malloc+0x1f52>
    2468:	3fd020ef          	jal	ra,5064 <printf>
    exit(1);
    246c:	4505                	li	a0,1
    246e:	7d2020ef          	jal	ra,4c40 <exit>
  wait(0);
    2472:	4501                	li	a0,0
    2474:	7d4020ef          	jal	ra,4c48 <wait>
  pid = fork();
    2478:	7c0020ef          	jal	ra,4c38 <fork>
  if(pid < 0){
    247c:	02054263          	bltz	a0,24a0 <sbrkbugs+0x9e>
  if(pid == 0){
    2480:	e90d                	bnez	a0,24b2 <sbrkbugs+0xb0>
    sbrk((10*PGSIZE + 2048) - (uint64)sbrk(0));
    2482:	78a020ef          	jal	ra,4c0c <sbrk>
    2486:	67ad                	lui	a5,0xb
    2488:	8007879b          	addiw	a5,a5,-2048
    248c:	40a7853b          	subw	a0,a5,a0
    2490:	77c020ef          	jal	ra,4c0c <sbrk>
    sbrk(-10);
    2494:	5559                	li	a0,-10
    2496:	776020ef          	jal	ra,4c0c <sbrk>
    exit(0);
    249a:	4501                	li	a0,0
    249c:	7a4020ef          	jal	ra,4c40 <exit>
    printf("fork failed\n");
    24a0:	00005517          	auipc	a0,0x5
    24a4:	bd050513          	addi	a0,a0,-1072 # 7070 <malloc+0x1f52>
    24a8:	3bd020ef          	jal	ra,5064 <printf>
    exit(1);
    24ac:	4505                	li	a0,1
    24ae:	792020ef          	jal	ra,4c40 <exit>
  wait(0);
    24b2:	4501                	li	a0,0
    24b4:	794020ef          	jal	ra,4c48 <wait>
  exit(0);
    24b8:	4501                	li	a0,0
    24ba:	786020ef          	jal	ra,4c40 <exit>

00000000000024be <sbrklast>:
{
    24be:	7179                	addi	sp,sp,-48
    24c0:	f406                	sd	ra,40(sp)
    24c2:	f022                	sd	s0,32(sp)
    24c4:	ec26                	sd	s1,24(sp)
    24c6:	e84a                	sd	s2,16(sp)
    24c8:	e44e                	sd	s3,8(sp)
    24ca:	e052                	sd	s4,0(sp)
    24cc:	1800                	addi	s0,sp,48
  uint64 top = (uint64) sbrk(0);
    24ce:	4501                	li	a0,0
    24d0:	73c020ef          	jal	ra,4c0c <sbrk>
  if((top % PGSIZE) != 0)
    24d4:	03451793          	slli	a5,a0,0x34
    24d8:	ebad                	bnez	a5,254a <sbrklast+0x8c>
  sbrk(PGSIZE);
    24da:	6505                	lui	a0,0x1
    24dc:	730020ef          	jal	ra,4c0c <sbrk>
  sbrk(10);
    24e0:	4529                	li	a0,10
    24e2:	72a020ef          	jal	ra,4c0c <sbrk>
  sbrk(-20);
    24e6:	5531                	li	a0,-20
    24e8:	724020ef          	jal	ra,4c0c <sbrk>
  top = (uint64) sbrk(0);
    24ec:	4501                	li	a0,0
    24ee:	71e020ef          	jal	ra,4c0c <sbrk>
    24f2:	84aa                	mv	s1,a0
  char *p = (char *) (top - 64);
    24f4:	fc050913          	addi	s2,a0,-64 # fc0 <bigdir+0x120>
  p[0] = 'x';
    24f8:	07800a13          	li	s4,120
    24fc:	fd450023          	sb	s4,-64(a0)
  p[1] = '\0';
    2500:	fc0500a3          	sb	zero,-63(a0)
  int fd = open(p, O_RDWR|O_CREATE);
    2504:	20200593          	li	a1,514
    2508:	854a                	mv	a0,s2
    250a:	776020ef          	jal	ra,4c80 <open>
    250e:	89aa                	mv	s3,a0
  write(fd, p, 1);
    2510:	4605                	li	a2,1
    2512:	85ca                	mv	a1,s2
    2514:	74c020ef          	jal	ra,4c60 <write>
  close(fd);
    2518:	854e                	mv	a0,s3
    251a:	74e020ef          	jal	ra,4c68 <close>
  fd = open(p, O_RDWR);
    251e:	4589                	li	a1,2
    2520:	854a                	mv	a0,s2
    2522:	75e020ef          	jal	ra,4c80 <open>
  p[0] = '\0';
    2526:	fc048023          	sb	zero,-64(s1)
  read(fd, p, 1);
    252a:	4605                	li	a2,1
    252c:	85ca                	mv	a1,s2
    252e:	72a020ef          	jal	ra,4c58 <read>
  if(p[0] != 'x')
    2532:	fc04c783          	lbu	a5,-64(s1)
    2536:	03479263          	bne	a5,s4,255a <sbrklast+0x9c>
}
    253a:	70a2                	ld	ra,40(sp)
    253c:	7402                	ld	s0,32(sp)
    253e:	64e2                	ld	s1,24(sp)
    2540:	6942                	ld	s2,16(sp)
    2542:	69a2                	ld	s3,8(sp)
    2544:	6a02                	ld	s4,0(sp)
    2546:	6145                	addi	sp,sp,48
    2548:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    254a:	0347d513          	srli	a0,a5,0x34
    254e:	6785                	lui	a5,0x1
    2550:	40a7853b          	subw	a0,a5,a0
    2554:	6b8020ef          	jal	ra,4c0c <sbrk>
    2558:	b749                	j	24da <sbrklast+0x1c>
    exit(1);
    255a:	4505                	li	a0,1
    255c:	6e4020ef          	jal	ra,4c40 <exit>

0000000000002560 <sbrk8000>:
{
    2560:	1141                	addi	sp,sp,-16
    2562:	e406                	sd	ra,8(sp)
    2564:	e022                	sd	s0,0(sp)
    2566:	0800                	addi	s0,sp,16
  sbrk(0x80000004);
    2568:	80000537          	lui	a0,0x80000
    256c:	0511                	addi	a0,a0,4
    256e:	69e020ef          	jal	ra,4c0c <sbrk>
  volatile char *top = sbrk(0);
    2572:	4501                	li	a0,0
    2574:	698020ef          	jal	ra,4c0c <sbrk>
  *(top-1) = *(top-1) + 1;
    2578:	fff54783          	lbu	a5,-1(a0) # ffffffff7fffffff <base+0xffffffff7fff1357>
    257c:	0785                	addi	a5,a5,1
    257e:	0ff7f793          	andi	a5,a5,255
    2582:	fef50fa3          	sb	a5,-1(a0)
}
    2586:	60a2                	ld	ra,8(sp)
    2588:	6402                	ld	s0,0(sp)
    258a:	0141                	addi	sp,sp,16
    258c:	8082                	ret

000000000000258e <execout>:
{
    258e:	715d                	addi	sp,sp,-80
    2590:	e486                	sd	ra,72(sp)
    2592:	e0a2                	sd	s0,64(sp)
    2594:	fc26                	sd	s1,56(sp)
    2596:	f84a                	sd	s2,48(sp)
    2598:	f44e                	sd	s3,40(sp)
    259a:	f052                	sd	s4,32(sp)
    259c:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    259e:	4901                	li	s2,0
    25a0:	49bd                	li	s3,15
    int pid = fork();
    25a2:	696020ef          	jal	ra,4c38 <fork>
    25a6:	84aa                	mv	s1,a0
    if(pid < 0){
    25a8:	00054c63          	bltz	a0,25c0 <execout+0x32>
    } else if(pid == 0){
    25ac:	c11d                	beqz	a0,25d2 <execout+0x44>
      wait((int*)0);
    25ae:	4501                	li	a0,0
    25b0:	698020ef          	jal	ra,4c48 <wait>
  for(int avail = 0; avail < 15; avail++){
    25b4:	2905                	addiw	s2,s2,1
    25b6:	ff3916e3          	bne	s2,s3,25a2 <execout+0x14>
  exit(0);
    25ba:	4501                	li	a0,0
    25bc:	684020ef          	jal	ra,4c40 <exit>
      printf("fork failed\n");
    25c0:	00005517          	auipc	a0,0x5
    25c4:	ab050513          	addi	a0,a0,-1360 # 7070 <malloc+0x1f52>
    25c8:	29d020ef          	jal	ra,5064 <printf>
      exit(1);
    25cc:	4505                	li	a0,1
    25ce:	672020ef          	jal	ra,4c40 <exit>
        if(a == SBRK_ERROR)
    25d2:	59fd                	li	s3,-1
        *(a + PGSIZE - 1) = 1;
    25d4:	4a05                	li	s4,1
        char *a = sbrk(PGSIZE);
    25d6:	6505                	lui	a0,0x1
    25d8:	634020ef          	jal	ra,4c0c <sbrk>
        if(a == SBRK_ERROR)
    25dc:	01350763          	beq	a0,s3,25ea <execout+0x5c>
        *(a + PGSIZE - 1) = 1;
    25e0:	6785                	lui	a5,0x1
    25e2:	953e                	add	a0,a0,a5
    25e4:	ff450fa3          	sb	s4,-1(a0) # fff <pgbug+0x29>
      while(1){
    25e8:	b7fd                	j	25d6 <execout+0x48>
      for(int i = 0; i < avail; i++)
    25ea:	01205863          	blez	s2,25fa <execout+0x6c>
        sbrk(-PGSIZE);
    25ee:	757d                	lui	a0,0xfffff
    25f0:	61c020ef          	jal	ra,4c0c <sbrk>
      for(int i = 0; i < avail; i++)
    25f4:	2485                	addiw	s1,s1,1
    25f6:	ff249ce3          	bne	s1,s2,25ee <execout+0x60>
      close(1);
    25fa:	4505                	li	a0,1
    25fc:	66c020ef          	jal	ra,4c68 <close>
      char *args[] = { "echo", "x", 0 };
    2600:	00003517          	auipc	a0,0x3
    2604:	c5850513          	addi	a0,a0,-936 # 5258 <malloc+0x13a>
    2608:	faa43c23          	sd	a0,-72(s0)
    260c:	00003797          	auipc	a5,0x3
    2610:	cbc78793          	addi	a5,a5,-836 # 52c8 <malloc+0x1aa>
    2614:	fcf43023          	sd	a5,-64(s0)
    2618:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    261c:	fb840593          	addi	a1,s0,-72
    2620:	658020ef          	jal	ra,4c78 <exec>
      exit(0);
    2624:	4501                	li	a0,0
    2626:	61a020ef          	jal	ra,4c40 <exit>

000000000000262a <fourteen>:
{
    262a:	1101                	addi	sp,sp,-32
    262c:	ec06                	sd	ra,24(sp)
    262e:	e822                	sd	s0,16(sp)
    2630:	e426                	sd	s1,8(sp)
    2632:	1000                	addi	s0,sp,32
    2634:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    2636:	00004517          	auipc	a0,0x4
    263a:	cba50513          	addi	a0,a0,-838 # 62f0 <malloc+0x11d2>
    263e:	66a020ef          	jal	ra,4ca8 <mkdir>
    2642:	e555                	bnez	a0,26ee <fourteen+0xc4>
  if(mkdir("12345678901234/123456789012345") != 0){
    2644:	00004517          	auipc	a0,0x4
    2648:	b0450513          	addi	a0,a0,-1276 # 6148 <malloc+0x102a>
    264c:	65c020ef          	jal	ra,4ca8 <mkdir>
    2650:	e94d                	bnez	a0,2702 <fourteen+0xd8>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    2652:	20000593          	li	a1,512
    2656:	00004517          	auipc	a0,0x4
    265a:	b4a50513          	addi	a0,a0,-1206 # 61a0 <malloc+0x1082>
    265e:	622020ef          	jal	ra,4c80 <open>
  if(fd < 0){
    2662:	0a054a63          	bltz	a0,2716 <fourteen+0xec>
  close(fd);
    2666:	602020ef          	jal	ra,4c68 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    266a:	4581                	li	a1,0
    266c:	00004517          	auipc	a0,0x4
    2670:	bac50513          	addi	a0,a0,-1108 # 6218 <malloc+0x10fa>
    2674:	60c020ef          	jal	ra,4c80 <open>
  if(fd < 0){
    2678:	0a054963          	bltz	a0,272a <fourteen+0x100>
  close(fd);
    267c:	5ec020ef          	jal	ra,4c68 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    2680:	00004517          	auipc	a0,0x4
    2684:	c0850513          	addi	a0,a0,-1016 # 6288 <malloc+0x116a>
    2688:	620020ef          	jal	ra,4ca8 <mkdir>
    268c:	c94d                	beqz	a0,273e <fourteen+0x114>
  if(mkdir("123456789012345/12345678901234") == 0){
    268e:	00004517          	auipc	a0,0x4
    2692:	c5250513          	addi	a0,a0,-942 # 62e0 <malloc+0x11c2>
    2696:	612020ef          	jal	ra,4ca8 <mkdir>
    269a:	cd45                	beqz	a0,2752 <fourteen+0x128>
  unlink("123456789012345/12345678901234");
    269c:	00004517          	auipc	a0,0x4
    26a0:	c4450513          	addi	a0,a0,-956 # 62e0 <malloc+0x11c2>
    26a4:	5ec020ef          	jal	ra,4c90 <unlink>
  unlink("12345678901234/12345678901234");
    26a8:	00004517          	auipc	a0,0x4
    26ac:	be050513          	addi	a0,a0,-1056 # 6288 <malloc+0x116a>
    26b0:	5e0020ef          	jal	ra,4c90 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    26b4:	00004517          	auipc	a0,0x4
    26b8:	b6450513          	addi	a0,a0,-1180 # 6218 <malloc+0x10fa>
    26bc:	5d4020ef          	jal	ra,4c90 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    26c0:	00004517          	auipc	a0,0x4
    26c4:	ae050513          	addi	a0,a0,-1312 # 61a0 <malloc+0x1082>
    26c8:	5c8020ef          	jal	ra,4c90 <unlink>
  unlink("12345678901234/123456789012345");
    26cc:	00004517          	auipc	a0,0x4
    26d0:	a7c50513          	addi	a0,a0,-1412 # 6148 <malloc+0x102a>
    26d4:	5bc020ef          	jal	ra,4c90 <unlink>
  unlink("12345678901234");
    26d8:	00004517          	auipc	a0,0x4
    26dc:	c1850513          	addi	a0,a0,-1000 # 62f0 <malloc+0x11d2>
    26e0:	5b0020ef          	jal	ra,4c90 <unlink>
}
    26e4:	60e2                	ld	ra,24(sp)
    26e6:	6442                	ld	s0,16(sp)
    26e8:	64a2                	ld	s1,8(sp)
    26ea:	6105                	addi	sp,sp,32
    26ec:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    26ee:	85a6                	mv	a1,s1
    26f0:	00004517          	auipc	a0,0x4
    26f4:	a3050513          	addi	a0,a0,-1488 # 6120 <malloc+0x1002>
    26f8:	16d020ef          	jal	ra,5064 <printf>
    exit(1);
    26fc:	4505                	li	a0,1
    26fe:	542020ef          	jal	ra,4c40 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    2702:	85a6                	mv	a1,s1
    2704:	00004517          	auipc	a0,0x4
    2708:	a6450513          	addi	a0,a0,-1436 # 6168 <malloc+0x104a>
    270c:	159020ef          	jal	ra,5064 <printf>
    exit(1);
    2710:	4505                	li	a0,1
    2712:	52e020ef          	jal	ra,4c40 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    2716:	85a6                	mv	a1,s1
    2718:	00004517          	auipc	a0,0x4
    271c:	ab850513          	addi	a0,a0,-1352 # 61d0 <malloc+0x10b2>
    2720:	145020ef          	jal	ra,5064 <printf>
    exit(1);
    2724:	4505                	li	a0,1
    2726:	51a020ef          	jal	ra,4c40 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    272a:	85a6                	mv	a1,s1
    272c:	00004517          	auipc	a0,0x4
    2730:	b1c50513          	addi	a0,a0,-1252 # 6248 <malloc+0x112a>
    2734:	131020ef          	jal	ra,5064 <printf>
    exit(1);
    2738:	4505                	li	a0,1
    273a:	506020ef          	jal	ra,4c40 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    273e:	85a6                	mv	a1,s1
    2740:	00004517          	auipc	a0,0x4
    2744:	b6850513          	addi	a0,a0,-1176 # 62a8 <malloc+0x118a>
    2748:	11d020ef          	jal	ra,5064 <printf>
    exit(1);
    274c:	4505                	li	a0,1
    274e:	4f2020ef          	jal	ra,4c40 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    2752:	85a6                	mv	a1,s1
    2754:	00004517          	auipc	a0,0x4
    2758:	bac50513          	addi	a0,a0,-1108 # 6300 <malloc+0x11e2>
    275c:	109020ef          	jal	ra,5064 <printf>
    exit(1);
    2760:	4505                	li	a0,1
    2762:	4de020ef          	jal	ra,4c40 <exit>

0000000000002766 <diskfull>:
{
    2766:	b8010113          	addi	sp,sp,-1152
    276a:	46113c23          	sd	ra,1144(sp)
    276e:	46813823          	sd	s0,1136(sp)
    2772:	46913423          	sd	s1,1128(sp)
    2776:	47213023          	sd	s2,1120(sp)
    277a:	45313c23          	sd	s3,1112(sp)
    277e:	45413823          	sd	s4,1104(sp)
    2782:	45513423          	sd	s5,1096(sp)
    2786:	45613023          	sd	s6,1088(sp)
    278a:	43713c23          	sd	s7,1080(sp)
    278e:	43813823          	sd	s8,1072(sp)
    2792:	43913423          	sd	s9,1064(sp)
    2796:	48010413          	addi	s0,sp,1152
    279a:	8caa                	mv	s9,a0
  unlink("diskfulldir");
    279c:	00004517          	auipc	a0,0x4
    27a0:	b9c50513          	addi	a0,a0,-1124 # 6338 <malloc+0x121a>
    27a4:	4ec020ef          	jal	ra,4c90 <unlink>
    27a8:	03000993          	li	s3,48
    name[0] = 'b';
    27ac:	06200b13          	li	s6,98
    name[1] = 'i';
    27b0:	06900a93          	li	s5,105
    name[2] = 'g';
    27b4:	06700a13          	li	s4,103
    27b8:	10c00b93          	li	s7,268
  for(fi = 0; done == 0 && '0' + fi < 0177; fi++){
    27bc:	07f00c13          	li	s8,127
    27c0:	aab9                	j	291e <diskfull+0x1b8>
      printf("%s: could not create file %s\n", s, name);
    27c2:	b8040613          	addi	a2,s0,-1152
    27c6:	85e6                	mv	a1,s9
    27c8:	00004517          	auipc	a0,0x4
    27cc:	b8050513          	addi	a0,a0,-1152 # 6348 <malloc+0x122a>
    27d0:	095020ef          	jal	ra,5064 <printf>
      break;
    27d4:	a039                	j	27e2 <diskfull+0x7c>
        close(fd);
    27d6:	854a                	mv	a0,s2
    27d8:	490020ef          	jal	ra,4c68 <close>
    close(fd);
    27dc:	854a                	mv	a0,s2
    27de:	48a020ef          	jal	ra,4c68 <close>
  for(int i = 0; i < nzz; i++){
    27e2:	4481                	li	s1,0
    name[0] = 'z';
    27e4:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
    27e8:	08000993          	li	s3,128
    name[0] = 'z';
    27ec:	bb240023          	sb	s2,-1120(s0)
    name[1] = 'z';
    27f0:	bb2400a3          	sb	s2,-1119(s0)
    name[2] = '0' + (i / 32);
    27f4:	41f4d79b          	sraiw	a5,s1,0x1f
    27f8:	01b7d71b          	srliw	a4,a5,0x1b
    27fc:	009707bb          	addw	a5,a4,s1
    2800:	4057d69b          	sraiw	a3,a5,0x5
    2804:	0306869b          	addiw	a3,a3,48
    2808:	bad40123          	sb	a3,-1118(s0)
    name[3] = '0' + (i % 32);
    280c:	8bfd                	andi	a5,a5,31
    280e:	9f99                	subw	a5,a5,a4
    2810:	0307879b          	addiw	a5,a5,48
    2814:	baf401a3          	sb	a5,-1117(s0)
    name[4] = '\0';
    2818:	ba040223          	sb	zero,-1116(s0)
    unlink(name);
    281c:	ba040513          	addi	a0,s0,-1120
    2820:	470020ef          	jal	ra,4c90 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    2824:	60200593          	li	a1,1538
    2828:	ba040513          	addi	a0,s0,-1120
    282c:	454020ef          	jal	ra,4c80 <open>
    if(fd < 0)
    2830:	00054763          	bltz	a0,283e <diskfull+0xd8>
    close(fd);
    2834:	434020ef          	jal	ra,4c68 <close>
  for(int i = 0; i < nzz; i++){
    2838:	2485                	addiw	s1,s1,1
    283a:	fb3499e3          	bne	s1,s3,27ec <diskfull+0x86>
  if(mkdir("diskfulldir") == 0)
    283e:	00004517          	auipc	a0,0x4
    2842:	afa50513          	addi	a0,a0,-1286 # 6338 <malloc+0x121a>
    2846:	462020ef          	jal	ra,4ca8 <mkdir>
    284a:	12050063          	beqz	a0,296a <diskfull+0x204>
  unlink("diskfulldir");
    284e:	00004517          	auipc	a0,0x4
    2852:	aea50513          	addi	a0,a0,-1302 # 6338 <malloc+0x121a>
    2856:	43a020ef          	jal	ra,4c90 <unlink>
  for(int i = 0; i < nzz; i++){
    285a:	4481                	li	s1,0
    name[0] = 'z';
    285c:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
    2860:	08000993          	li	s3,128
    name[0] = 'z';
    2864:	bb240023          	sb	s2,-1120(s0)
    name[1] = 'z';
    2868:	bb2400a3          	sb	s2,-1119(s0)
    name[2] = '0' + (i / 32);
    286c:	41f4d79b          	sraiw	a5,s1,0x1f
    2870:	01b7d71b          	srliw	a4,a5,0x1b
    2874:	009707bb          	addw	a5,a4,s1
    2878:	4057d69b          	sraiw	a3,a5,0x5
    287c:	0306869b          	addiw	a3,a3,48
    2880:	bad40123          	sb	a3,-1118(s0)
    name[3] = '0' + (i % 32);
    2884:	8bfd                	andi	a5,a5,31
    2886:	9f99                	subw	a5,a5,a4
    2888:	0307879b          	addiw	a5,a5,48
    288c:	baf401a3          	sb	a5,-1117(s0)
    name[4] = '\0';
    2890:	ba040223          	sb	zero,-1116(s0)
    unlink(name);
    2894:	ba040513          	addi	a0,s0,-1120
    2898:	3f8020ef          	jal	ra,4c90 <unlink>
  for(int i = 0; i < nzz; i++){
    289c:	2485                	addiw	s1,s1,1
    289e:	fd3493e3          	bne	s1,s3,2864 <diskfull+0xfe>
    28a2:	03000493          	li	s1,48
    name[0] = 'b';
    28a6:	06200a93          	li	s5,98
    name[1] = 'i';
    28aa:	06900a13          	li	s4,105
    name[2] = 'g';
    28ae:	06700993          	li	s3,103
  for(int i = 0; '0' + i < 0177; i++){
    28b2:	07f00913          	li	s2,127
    name[0] = 'b';
    28b6:	bb540023          	sb	s5,-1120(s0)
    name[1] = 'i';
    28ba:	bb4400a3          	sb	s4,-1119(s0)
    name[2] = 'g';
    28be:	bb340123          	sb	s3,-1118(s0)
    name[3] = '0' + i;
    28c2:	ba9401a3          	sb	s1,-1117(s0)
    name[4] = '\0';
    28c6:	ba040223          	sb	zero,-1116(s0)
    unlink(name);
    28ca:	ba040513          	addi	a0,s0,-1120
    28ce:	3c2020ef          	jal	ra,4c90 <unlink>
  for(int i = 0; '0' + i < 0177; i++){
    28d2:	2485                	addiw	s1,s1,1
    28d4:	0ff4f493          	andi	s1,s1,255
    28d8:	fd249fe3          	bne	s1,s2,28b6 <diskfull+0x150>
}
    28dc:	47813083          	ld	ra,1144(sp)
    28e0:	47013403          	ld	s0,1136(sp)
    28e4:	46813483          	ld	s1,1128(sp)
    28e8:	46013903          	ld	s2,1120(sp)
    28ec:	45813983          	ld	s3,1112(sp)
    28f0:	45013a03          	ld	s4,1104(sp)
    28f4:	44813a83          	ld	s5,1096(sp)
    28f8:	44013b03          	ld	s6,1088(sp)
    28fc:	43813b83          	ld	s7,1080(sp)
    2900:	43013c03          	ld	s8,1072(sp)
    2904:	42813c83          	ld	s9,1064(sp)
    2908:	48010113          	addi	sp,sp,1152
    290c:	8082                	ret
    close(fd);
    290e:	854a                	mv	a0,s2
    2910:	358020ef          	jal	ra,4c68 <close>
  for(fi = 0; done == 0 && '0' + fi < 0177; fi++){
    2914:	2985                	addiw	s3,s3,1
    2916:	0ff9f993          	andi	s3,s3,255
    291a:	ed8984e3          	beq	s3,s8,27e2 <diskfull+0x7c>
    name[0] = 'b';
    291e:	b9640023          	sb	s6,-1152(s0)
    name[1] = 'i';
    2922:	b95400a3          	sb	s5,-1151(s0)
    name[2] = 'g';
    2926:	b9440123          	sb	s4,-1150(s0)
    name[3] = '0' + fi;
    292a:	b93401a3          	sb	s3,-1149(s0)
    name[4] = '\0';
    292e:	b8040223          	sb	zero,-1148(s0)
    unlink(name);
    2932:	b8040513          	addi	a0,s0,-1152
    2936:	35a020ef          	jal	ra,4c90 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    293a:	60200593          	li	a1,1538
    293e:	b8040513          	addi	a0,s0,-1152
    2942:	33e020ef          	jal	ra,4c80 <open>
    2946:	892a                	mv	s2,a0
    if(fd < 0){
    2948:	e6054de3          	bltz	a0,27c2 <diskfull+0x5c>
    294c:	84de                	mv	s1,s7
      if(write(fd, buf, BSIZE) != BSIZE){
    294e:	40000613          	li	a2,1024
    2952:	ba040593          	addi	a1,s0,-1120
    2956:	854a                	mv	a0,s2
    2958:	308020ef          	jal	ra,4c60 <write>
    295c:	40000793          	li	a5,1024
    2960:	e6f51be3          	bne	a0,a5,27d6 <diskfull+0x70>
    for(int i = 0; i < MAXFILE; i++){
    2964:	34fd                	addiw	s1,s1,-1
    2966:	f4e5                	bnez	s1,294e <diskfull+0x1e8>
    2968:	b75d                	j	290e <diskfull+0x1a8>
    printf("%s: mkdir(diskfulldir) unexpectedly succeeded!\n", s);
    296a:	85e6                	mv	a1,s9
    296c:	00004517          	auipc	a0,0x4
    2970:	9fc50513          	addi	a0,a0,-1540 # 6368 <malloc+0x124a>
    2974:	6f0020ef          	jal	ra,5064 <printf>
    2978:	bdd9                	j	284e <diskfull+0xe8>

000000000000297a <iputtest>:
{
    297a:	1101                	addi	sp,sp,-32
    297c:	ec06                	sd	ra,24(sp)
    297e:	e822                	sd	s0,16(sp)
    2980:	e426                	sd	s1,8(sp)
    2982:	1000                	addi	s0,sp,32
    2984:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    2986:	00004517          	auipc	a0,0x4
    298a:	a1250513          	addi	a0,a0,-1518 # 6398 <malloc+0x127a>
    298e:	31a020ef          	jal	ra,4ca8 <mkdir>
    2992:	02054f63          	bltz	a0,29d0 <iputtest+0x56>
  if(chdir("iputdir") < 0){
    2996:	00004517          	auipc	a0,0x4
    299a:	a0250513          	addi	a0,a0,-1534 # 6398 <malloc+0x127a>
    299e:	312020ef          	jal	ra,4cb0 <chdir>
    29a2:	04054163          	bltz	a0,29e4 <iputtest+0x6a>
  if(unlink("../iputdir") < 0){
    29a6:	00004517          	auipc	a0,0x4
    29aa:	a3250513          	addi	a0,a0,-1486 # 63d8 <malloc+0x12ba>
    29ae:	2e2020ef          	jal	ra,4c90 <unlink>
    29b2:	04054363          	bltz	a0,29f8 <iputtest+0x7e>
  if(chdir("/") < 0){
    29b6:	00004517          	auipc	a0,0x4
    29ba:	a5250513          	addi	a0,a0,-1454 # 6408 <malloc+0x12ea>
    29be:	2f2020ef          	jal	ra,4cb0 <chdir>
    29c2:	04054563          	bltz	a0,2a0c <iputtest+0x92>
}
    29c6:	60e2                	ld	ra,24(sp)
    29c8:	6442                	ld	s0,16(sp)
    29ca:	64a2                	ld	s1,8(sp)
    29cc:	6105                	addi	sp,sp,32
    29ce:	8082                	ret
    printf("%s: mkdir failed\n", s);
    29d0:	85a6                	mv	a1,s1
    29d2:	00004517          	auipc	a0,0x4
    29d6:	9ce50513          	addi	a0,a0,-1586 # 63a0 <malloc+0x1282>
    29da:	68a020ef          	jal	ra,5064 <printf>
    exit(1);
    29de:	4505                	li	a0,1
    29e0:	260020ef          	jal	ra,4c40 <exit>
    printf("%s: chdir iputdir failed\n", s);
    29e4:	85a6                	mv	a1,s1
    29e6:	00004517          	auipc	a0,0x4
    29ea:	9d250513          	addi	a0,a0,-1582 # 63b8 <malloc+0x129a>
    29ee:	676020ef          	jal	ra,5064 <printf>
    exit(1);
    29f2:	4505                	li	a0,1
    29f4:	24c020ef          	jal	ra,4c40 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    29f8:	85a6                	mv	a1,s1
    29fa:	00004517          	auipc	a0,0x4
    29fe:	9ee50513          	addi	a0,a0,-1554 # 63e8 <malloc+0x12ca>
    2a02:	662020ef          	jal	ra,5064 <printf>
    exit(1);
    2a06:	4505                	li	a0,1
    2a08:	238020ef          	jal	ra,4c40 <exit>
    printf("%s: chdir / failed\n", s);
    2a0c:	85a6                	mv	a1,s1
    2a0e:	00004517          	auipc	a0,0x4
    2a12:	a0250513          	addi	a0,a0,-1534 # 6410 <malloc+0x12f2>
    2a16:	64e020ef          	jal	ra,5064 <printf>
    exit(1);
    2a1a:	4505                	li	a0,1
    2a1c:	224020ef          	jal	ra,4c40 <exit>

0000000000002a20 <exitiputtest>:
{
    2a20:	7179                	addi	sp,sp,-48
    2a22:	f406                	sd	ra,40(sp)
    2a24:	f022                	sd	s0,32(sp)
    2a26:	ec26                	sd	s1,24(sp)
    2a28:	1800                	addi	s0,sp,48
    2a2a:	84aa                	mv	s1,a0
  pid = fork();
    2a2c:	20c020ef          	jal	ra,4c38 <fork>
  if(pid < 0){
    2a30:	02054e63          	bltz	a0,2a6c <exitiputtest+0x4c>
  if(pid == 0){
    2a34:	e541                	bnez	a0,2abc <exitiputtest+0x9c>
    if(mkdir("iputdir") < 0){
    2a36:	00004517          	auipc	a0,0x4
    2a3a:	96250513          	addi	a0,a0,-1694 # 6398 <malloc+0x127a>
    2a3e:	26a020ef          	jal	ra,4ca8 <mkdir>
    2a42:	02054f63          	bltz	a0,2a80 <exitiputtest+0x60>
    if(chdir("iputdir") < 0){
    2a46:	00004517          	auipc	a0,0x4
    2a4a:	95250513          	addi	a0,a0,-1710 # 6398 <malloc+0x127a>
    2a4e:	262020ef          	jal	ra,4cb0 <chdir>
    2a52:	04054163          	bltz	a0,2a94 <exitiputtest+0x74>
    if(unlink("../iputdir") < 0){
    2a56:	00004517          	auipc	a0,0x4
    2a5a:	98250513          	addi	a0,a0,-1662 # 63d8 <malloc+0x12ba>
    2a5e:	232020ef          	jal	ra,4c90 <unlink>
    2a62:	04054363          	bltz	a0,2aa8 <exitiputtest+0x88>
    exit(0);
    2a66:	4501                	li	a0,0
    2a68:	1d8020ef          	jal	ra,4c40 <exit>
    printf("%s: fork failed\n", s);
    2a6c:	85a6                	mv	a1,s1
    2a6e:	00003517          	auipc	a0,0x3
    2a72:	07a50513          	addi	a0,a0,122 # 5ae8 <malloc+0x9ca>
    2a76:	5ee020ef          	jal	ra,5064 <printf>
    exit(1);
    2a7a:	4505                	li	a0,1
    2a7c:	1c4020ef          	jal	ra,4c40 <exit>
      printf("%s: mkdir failed\n", s);
    2a80:	85a6                	mv	a1,s1
    2a82:	00004517          	auipc	a0,0x4
    2a86:	91e50513          	addi	a0,a0,-1762 # 63a0 <malloc+0x1282>
    2a8a:	5da020ef          	jal	ra,5064 <printf>
      exit(1);
    2a8e:	4505                	li	a0,1
    2a90:	1b0020ef          	jal	ra,4c40 <exit>
      printf("%s: child chdir failed\n", s);
    2a94:	85a6                	mv	a1,s1
    2a96:	00004517          	auipc	a0,0x4
    2a9a:	99250513          	addi	a0,a0,-1646 # 6428 <malloc+0x130a>
    2a9e:	5c6020ef          	jal	ra,5064 <printf>
      exit(1);
    2aa2:	4505                	li	a0,1
    2aa4:	19c020ef          	jal	ra,4c40 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    2aa8:	85a6                	mv	a1,s1
    2aaa:	00004517          	auipc	a0,0x4
    2aae:	93e50513          	addi	a0,a0,-1730 # 63e8 <malloc+0x12ca>
    2ab2:	5b2020ef          	jal	ra,5064 <printf>
      exit(1);
    2ab6:	4505                	li	a0,1
    2ab8:	188020ef          	jal	ra,4c40 <exit>
  wait(&xstatus);
    2abc:	fdc40513          	addi	a0,s0,-36
    2ac0:	188020ef          	jal	ra,4c48 <wait>
  exit(xstatus);
    2ac4:	fdc42503          	lw	a0,-36(s0)
    2ac8:	178020ef          	jal	ra,4c40 <exit>

0000000000002acc <dirtest>:
{
    2acc:	1101                	addi	sp,sp,-32
    2ace:	ec06                	sd	ra,24(sp)
    2ad0:	e822                	sd	s0,16(sp)
    2ad2:	e426                	sd	s1,8(sp)
    2ad4:	1000                	addi	s0,sp,32
    2ad6:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    2ad8:	00004517          	auipc	a0,0x4
    2adc:	96850513          	addi	a0,a0,-1688 # 6440 <malloc+0x1322>
    2ae0:	1c8020ef          	jal	ra,4ca8 <mkdir>
    2ae4:	02054f63          	bltz	a0,2b22 <dirtest+0x56>
  if(chdir("dir0") < 0){
    2ae8:	00004517          	auipc	a0,0x4
    2aec:	95850513          	addi	a0,a0,-1704 # 6440 <malloc+0x1322>
    2af0:	1c0020ef          	jal	ra,4cb0 <chdir>
    2af4:	04054163          	bltz	a0,2b36 <dirtest+0x6a>
  if(chdir("..") < 0){
    2af8:	00004517          	auipc	a0,0x4
    2afc:	96850513          	addi	a0,a0,-1688 # 6460 <malloc+0x1342>
    2b00:	1b0020ef          	jal	ra,4cb0 <chdir>
    2b04:	04054363          	bltz	a0,2b4a <dirtest+0x7e>
  if(unlink("dir0") < 0){
    2b08:	00004517          	auipc	a0,0x4
    2b0c:	93850513          	addi	a0,a0,-1736 # 6440 <malloc+0x1322>
    2b10:	180020ef          	jal	ra,4c90 <unlink>
    2b14:	04054563          	bltz	a0,2b5e <dirtest+0x92>
}
    2b18:	60e2                	ld	ra,24(sp)
    2b1a:	6442                	ld	s0,16(sp)
    2b1c:	64a2                	ld	s1,8(sp)
    2b1e:	6105                	addi	sp,sp,32
    2b20:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2b22:	85a6                	mv	a1,s1
    2b24:	00004517          	auipc	a0,0x4
    2b28:	87c50513          	addi	a0,a0,-1924 # 63a0 <malloc+0x1282>
    2b2c:	538020ef          	jal	ra,5064 <printf>
    exit(1);
    2b30:	4505                	li	a0,1
    2b32:	10e020ef          	jal	ra,4c40 <exit>
    printf("%s: chdir dir0 failed\n", s);
    2b36:	85a6                	mv	a1,s1
    2b38:	00004517          	auipc	a0,0x4
    2b3c:	91050513          	addi	a0,a0,-1776 # 6448 <malloc+0x132a>
    2b40:	524020ef          	jal	ra,5064 <printf>
    exit(1);
    2b44:	4505                	li	a0,1
    2b46:	0fa020ef          	jal	ra,4c40 <exit>
    printf("%s: chdir .. failed\n", s);
    2b4a:	85a6                	mv	a1,s1
    2b4c:	00004517          	auipc	a0,0x4
    2b50:	91c50513          	addi	a0,a0,-1764 # 6468 <malloc+0x134a>
    2b54:	510020ef          	jal	ra,5064 <printf>
    exit(1);
    2b58:	4505                	li	a0,1
    2b5a:	0e6020ef          	jal	ra,4c40 <exit>
    printf("%s: unlink dir0 failed\n", s);
    2b5e:	85a6                	mv	a1,s1
    2b60:	00004517          	auipc	a0,0x4
    2b64:	92050513          	addi	a0,a0,-1760 # 6480 <malloc+0x1362>
    2b68:	4fc020ef          	jal	ra,5064 <printf>
    exit(1);
    2b6c:	4505                	li	a0,1
    2b6e:	0d2020ef          	jal	ra,4c40 <exit>

0000000000002b72 <subdir>:
{
    2b72:	1101                	addi	sp,sp,-32
    2b74:	ec06                	sd	ra,24(sp)
    2b76:	e822                	sd	s0,16(sp)
    2b78:	e426                	sd	s1,8(sp)
    2b7a:	e04a                	sd	s2,0(sp)
    2b7c:	1000                	addi	s0,sp,32
    2b7e:	892a                	mv	s2,a0
  unlink("ff");
    2b80:	00004517          	auipc	a0,0x4
    2b84:	a4850513          	addi	a0,a0,-1464 # 65c8 <malloc+0x14aa>
    2b88:	108020ef          	jal	ra,4c90 <unlink>
  if(mkdir("dd") != 0){
    2b8c:	00004517          	auipc	a0,0x4
    2b90:	90c50513          	addi	a0,a0,-1780 # 6498 <malloc+0x137a>
    2b94:	114020ef          	jal	ra,4ca8 <mkdir>
    2b98:	2e051263          	bnez	a0,2e7c <subdir+0x30a>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    2b9c:	20200593          	li	a1,514
    2ba0:	00004517          	auipc	a0,0x4
    2ba4:	91850513          	addi	a0,a0,-1768 # 64b8 <malloc+0x139a>
    2ba8:	0d8020ef          	jal	ra,4c80 <open>
    2bac:	84aa                	mv	s1,a0
  if(fd < 0){
    2bae:	2e054163          	bltz	a0,2e90 <subdir+0x31e>
  write(fd, "ff", 2);
    2bb2:	4609                	li	a2,2
    2bb4:	00004597          	auipc	a1,0x4
    2bb8:	a1458593          	addi	a1,a1,-1516 # 65c8 <malloc+0x14aa>
    2bbc:	0a4020ef          	jal	ra,4c60 <write>
  close(fd);
    2bc0:	8526                	mv	a0,s1
    2bc2:	0a6020ef          	jal	ra,4c68 <close>
  if(unlink("dd") >= 0){
    2bc6:	00004517          	auipc	a0,0x4
    2bca:	8d250513          	addi	a0,a0,-1838 # 6498 <malloc+0x137a>
    2bce:	0c2020ef          	jal	ra,4c90 <unlink>
    2bd2:	2c055963          	bgez	a0,2ea4 <subdir+0x332>
  if(mkdir("/dd/dd") != 0){
    2bd6:	00004517          	auipc	a0,0x4
    2bda:	93a50513          	addi	a0,a0,-1734 # 6510 <malloc+0x13f2>
    2bde:	0ca020ef          	jal	ra,4ca8 <mkdir>
    2be2:	2c051b63          	bnez	a0,2eb8 <subdir+0x346>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    2be6:	20200593          	li	a1,514
    2bea:	00004517          	auipc	a0,0x4
    2bee:	94e50513          	addi	a0,a0,-1714 # 6538 <malloc+0x141a>
    2bf2:	08e020ef          	jal	ra,4c80 <open>
    2bf6:	84aa                	mv	s1,a0
  if(fd < 0){
    2bf8:	2c054a63          	bltz	a0,2ecc <subdir+0x35a>
  write(fd, "FF", 2);
    2bfc:	4609                	li	a2,2
    2bfe:	00004597          	auipc	a1,0x4
    2c02:	96a58593          	addi	a1,a1,-1686 # 6568 <malloc+0x144a>
    2c06:	05a020ef          	jal	ra,4c60 <write>
  close(fd);
    2c0a:	8526                	mv	a0,s1
    2c0c:	05c020ef          	jal	ra,4c68 <close>
  fd = open("dd/dd/../ff", 0);
    2c10:	4581                	li	a1,0
    2c12:	00004517          	auipc	a0,0x4
    2c16:	95e50513          	addi	a0,a0,-1698 # 6570 <malloc+0x1452>
    2c1a:	066020ef          	jal	ra,4c80 <open>
    2c1e:	84aa                	mv	s1,a0
  if(fd < 0){
    2c20:	2c054063          	bltz	a0,2ee0 <subdir+0x36e>
  cc = read(fd, buf, sizeof(buf));
    2c24:	660d                	lui	a2,0x3
    2c26:	00009597          	auipc	a1,0x9
    2c2a:	08258593          	addi	a1,a1,130 # bca8 <buf>
    2c2e:	02a020ef          	jal	ra,4c58 <read>
  if(cc != 2 || buf[0] != 'f'){
    2c32:	4789                	li	a5,2
    2c34:	2cf51063          	bne	a0,a5,2ef4 <subdir+0x382>
    2c38:	00009717          	auipc	a4,0x9
    2c3c:	07074703          	lbu	a4,112(a4) # bca8 <buf>
    2c40:	06600793          	li	a5,102
    2c44:	2af71863          	bne	a4,a5,2ef4 <subdir+0x382>
  close(fd);
    2c48:	8526                	mv	a0,s1
    2c4a:	01e020ef          	jal	ra,4c68 <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    2c4e:	00004597          	auipc	a1,0x4
    2c52:	97258593          	addi	a1,a1,-1678 # 65c0 <malloc+0x14a2>
    2c56:	00004517          	auipc	a0,0x4
    2c5a:	8e250513          	addi	a0,a0,-1822 # 6538 <malloc+0x141a>
    2c5e:	042020ef          	jal	ra,4ca0 <link>
    2c62:	2a051363          	bnez	a0,2f08 <subdir+0x396>
  if(unlink("dd/dd/ff") != 0){
    2c66:	00004517          	auipc	a0,0x4
    2c6a:	8d250513          	addi	a0,a0,-1838 # 6538 <malloc+0x141a>
    2c6e:	022020ef          	jal	ra,4c90 <unlink>
    2c72:	2a051563          	bnez	a0,2f1c <subdir+0x3aa>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2c76:	4581                	li	a1,0
    2c78:	00004517          	auipc	a0,0x4
    2c7c:	8c050513          	addi	a0,a0,-1856 # 6538 <malloc+0x141a>
    2c80:	000020ef          	jal	ra,4c80 <open>
    2c84:	2a055663          	bgez	a0,2f30 <subdir+0x3be>
  if(chdir("dd") != 0){
    2c88:	00004517          	auipc	a0,0x4
    2c8c:	81050513          	addi	a0,a0,-2032 # 6498 <malloc+0x137a>
    2c90:	020020ef          	jal	ra,4cb0 <chdir>
    2c94:	2a051863          	bnez	a0,2f44 <subdir+0x3d2>
  if(chdir("dd/../../dd") != 0){
    2c98:	00004517          	auipc	a0,0x4
    2c9c:	9c050513          	addi	a0,a0,-1600 # 6658 <malloc+0x153a>
    2ca0:	010020ef          	jal	ra,4cb0 <chdir>
    2ca4:	2a051a63          	bnez	a0,2f58 <subdir+0x3e6>
  if(chdir("dd/../../../dd") != 0){
    2ca8:	00004517          	auipc	a0,0x4
    2cac:	9e050513          	addi	a0,a0,-1568 # 6688 <malloc+0x156a>
    2cb0:	000020ef          	jal	ra,4cb0 <chdir>
    2cb4:	2a051c63          	bnez	a0,2f6c <subdir+0x3fa>
  if(chdir("./..") != 0){
    2cb8:	00004517          	auipc	a0,0x4
    2cbc:	a0850513          	addi	a0,a0,-1528 # 66c0 <malloc+0x15a2>
    2cc0:	7f1010ef          	jal	ra,4cb0 <chdir>
    2cc4:	2a051e63          	bnez	a0,2f80 <subdir+0x40e>
  fd = open("dd/dd/ffff", 0);
    2cc8:	4581                	li	a1,0
    2cca:	00004517          	auipc	a0,0x4
    2cce:	8f650513          	addi	a0,a0,-1802 # 65c0 <malloc+0x14a2>
    2cd2:	7af010ef          	jal	ra,4c80 <open>
    2cd6:	84aa                	mv	s1,a0
  if(fd < 0){
    2cd8:	2a054e63          	bltz	a0,2f94 <subdir+0x422>
  if(read(fd, buf, sizeof(buf)) != 2){
    2cdc:	660d                	lui	a2,0x3
    2cde:	00009597          	auipc	a1,0x9
    2ce2:	fca58593          	addi	a1,a1,-54 # bca8 <buf>
    2ce6:	773010ef          	jal	ra,4c58 <read>
    2cea:	4789                	li	a5,2
    2cec:	2af51e63          	bne	a0,a5,2fa8 <subdir+0x436>
  close(fd);
    2cf0:	8526                	mv	a0,s1
    2cf2:	777010ef          	jal	ra,4c68 <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2cf6:	4581                	li	a1,0
    2cf8:	00004517          	auipc	a0,0x4
    2cfc:	84050513          	addi	a0,a0,-1984 # 6538 <malloc+0x141a>
    2d00:	781010ef          	jal	ra,4c80 <open>
    2d04:	2a055c63          	bgez	a0,2fbc <subdir+0x44a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    2d08:	20200593          	li	a1,514
    2d0c:	00004517          	auipc	a0,0x4
    2d10:	a4450513          	addi	a0,a0,-1468 # 6750 <malloc+0x1632>
    2d14:	76d010ef          	jal	ra,4c80 <open>
    2d18:	2a055c63          	bgez	a0,2fd0 <subdir+0x45e>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    2d1c:	20200593          	li	a1,514
    2d20:	00004517          	auipc	a0,0x4
    2d24:	a6050513          	addi	a0,a0,-1440 # 6780 <malloc+0x1662>
    2d28:	759010ef          	jal	ra,4c80 <open>
    2d2c:	2a055c63          	bgez	a0,2fe4 <subdir+0x472>
  if(open("dd", O_CREATE) >= 0){
    2d30:	20000593          	li	a1,512
    2d34:	00003517          	auipc	a0,0x3
    2d38:	76450513          	addi	a0,a0,1892 # 6498 <malloc+0x137a>
    2d3c:	745010ef          	jal	ra,4c80 <open>
    2d40:	2a055c63          	bgez	a0,2ff8 <subdir+0x486>
  if(open("dd", O_RDWR) >= 0){
    2d44:	4589                	li	a1,2
    2d46:	00003517          	auipc	a0,0x3
    2d4a:	75250513          	addi	a0,a0,1874 # 6498 <malloc+0x137a>
    2d4e:	733010ef          	jal	ra,4c80 <open>
    2d52:	2a055d63          	bgez	a0,300c <subdir+0x49a>
  if(open("dd", O_WRONLY) >= 0){
    2d56:	4585                	li	a1,1
    2d58:	00003517          	auipc	a0,0x3
    2d5c:	74050513          	addi	a0,a0,1856 # 6498 <malloc+0x137a>
    2d60:	721010ef          	jal	ra,4c80 <open>
    2d64:	2a055e63          	bgez	a0,3020 <subdir+0x4ae>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    2d68:	00004597          	auipc	a1,0x4
    2d6c:	aa858593          	addi	a1,a1,-1368 # 6810 <malloc+0x16f2>
    2d70:	00004517          	auipc	a0,0x4
    2d74:	9e050513          	addi	a0,a0,-1568 # 6750 <malloc+0x1632>
    2d78:	729010ef          	jal	ra,4ca0 <link>
    2d7c:	2a050c63          	beqz	a0,3034 <subdir+0x4c2>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    2d80:	00004597          	auipc	a1,0x4
    2d84:	a9058593          	addi	a1,a1,-1392 # 6810 <malloc+0x16f2>
    2d88:	00004517          	auipc	a0,0x4
    2d8c:	9f850513          	addi	a0,a0,-1544 # 6780 <malloc+0x1662>
    2d90:	711010ef          	jal	ra,4ca0 <link>
    2d94:	2a050a63          	beqz	a0,3048 <subdir+0x4d6>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    2d98:	00004597          	auipc	a1,0x4
    2d9c:	82858593          	addi	a1,a1,-2008 # 65c0 <malloc+0x14a2>
    2da0:	00003517          	auipc	a0,0x3
    2da4:	71850513          	addi	a0,a0,1816 # 64b8 <malloc+0x139a>
    2da8:	6f9010ef          	jal	ra,4ca0 <link>
    2dac:	2a050863          	beqz	a0,305c <subdir+0x4ea>
  if(mkdir("dd/ff/ff") == 0){
    2db0:	00004517          	auipc	a0,0x4
    2db4:	9a050513          	addi	a0,a0,-1632 # 6750 <malloc+0x1632>
    2db8:	6f1010ef          	jal	ra,4ca8 <mkdir>
    2dbc:	2a050a63          	beqz	a0,3070 <subdir+0x4fe>
  if(mkdir("dd/xx/ff") == 0){
    2dc0:	00004517          	auipc	a0,0x4
    2dc4:	9c050513          	addi	a0,a0,-1600 # 6780 <malloc+0x1662>
    2dc8:	6e1010ef          	jal	ra,4ca8 <mkdir>
    2dcc:	2a050c63          	beqz	a0,3084 <subdir+0x512>
  if(mkdir("dd/dd/ffff") == 0){
    2dd0:	00003517          	auipc	a0,0x3
    2dd4:	7f050513          	addi	a0,a0,2032 # 65c0 <malloc+0x14a2>
    2dd8:	6d1010ef          	jal	ra,4ca8 <mkdir>
    2ddc:	2a050e63          	beqz	a0,3098 <subdir+0x526>
  if(unlink("dd/xx/ff") == 0){
    2de0:	00004517          	auipc	a0,0x4
    2de4:	9a050513          	addi	a0,a0,-1632 # 6780 <malloc+0x1662>
    2de8:	6a9010ef          	jal	ra,4c90 <unlink>
    2dec:	2c050063          	beqz	a0,30ac <subdir+0x53a>
  if(unlink("dd/ff/ff") == 0){
    2df0:	00004517          	auipc	a0,0x4
    2df4:	96050513          	addi	a0,a0,-1696 # 6750 <malloc+0x1632>
    2df8:	699010ef          	jal	ra,4c90 <unlink>
    2dfc:	2c050263          	beqz	a0,30c0 <subdir+0x54e>
  if(chdir("dd/ff") == 0){
    2e00:	00003517          	auipc	a0,0x3
    2e04:	6b850513          	addi	a0,a0,1720 # 64b8 <malloc+0x139a>
    2e08:	6a9010ef          	jal	ra,4cb0 <chdir>
    2e0c:	2c050463          	beqz	a0,30d4 <subdir+0x562>
  if(chdir("dd/xx") == 0){
    2e10:	00004517          	auipc	a0,0x4
    2e14:	b5050513          	addi	a0,a0,-1200 # 6960 <malloc+0x1842>
    2e18:	699010ef          	jal	ra,4cb0 <chdir>
    2e1c:	2c050663          	beqz	a0,30e8 <subdir+0x576>
  if(unlink("dd/dd/ffff") != 0){
    2e20:	00003517          	auipc	a0,0x3
    2e24:	7a050513          	addi	a0,a0,1952 # 65c0 <malloc+0x14a2>
    2e28:	669010ef          	jal	ra,4c90 <unlink>
    2e2c:	2c051863          	bnez	a0,30fc <subdir+0x58a>
  if(unlink("dd/ff") != 0){
    2e30:	00003517          	auipc	a0,0x3
    2e34:	68850513          	addi	a0,a0,1672 # 64b8 <malloc+0x139a>
    2e38:	659010ef          	jal	ra,4c90 <unlink>
    2e3c:	2c051a63          	bnez	a0,3110 <subdir+0x59e>
  if(unlink("dd") == 0){
    2e40:	00003517          	auipc	a0,0x3
    2e44:	65850513          	addi	a0,a0,1624 # 6498 <malloc+0x137a>
    2e48:	649010ef          	jal	ra,4c90 <unlink>
    2e4c:	2c050c63          	beqz	a0,3124 <subdir+0x5b2>
  if(unlink("dd/dd") < 0){
    2e50:	00004517          	auipc	a0,0x4
    2e54:	b8050513          	addi	a0,a0,-1152 # 69d0 <malloc+0x18b2>
    2e58:	639010ef          	jal	ra,4c90 <unlink>
    2e5c:	2c054e63          	bltz	a0,3138 <subdir+0x5c6>
  if(unlink("dd") < 0){
    2e60:	00003517          	auipc	a0,0x3
    2e64:	63850513          	addi	a0,a0,1592 # 6498 <malloc+0x137a>
    2e68:	629010ef          	jal	ra,4c90 <unlink>
    2e6c:	2e054063          	bltz	a0,314c <subdir+0x5da>
}
    2e70:	60e2                	ld	ra,24(sp)
    2e72:	6442                	ld	s0,16(sp)
    2e74:	64a2                	ld	s1,8(sp)
    2e76:	6902                	ld	s2,0(sp)
    2e78:	6105                	addi	sp,sp,32
    2e7a:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    2e7c:	85ca                	mv	a1,s2
    2e7e:	00003517          	auipc	a0,0x3
    2e82:	62250513          	addi	a0,a0,1570 # 64a0 <malloc+0x1382>
    2e86:	1de020ef          	jal	ra,5064 <printf>
    exit(1);
    2e8a:	4505                	li	a0,1
    2e8c:	5b5010ef          	jal	ra,4c40 <exit>
    printf("%s: create dd/ff failed\n", s);
    2e90:	85ca                	mv	a1,s2
    2e92:	00003517          	auipc	a0,0x3
    2e96:	62e50513          	addi	a0,a0,1582 # 64c0 <malloc+0x13a2>
    2e9a:	1ca020ef          	jal	ra,5064 <printf>
    exit(1);
    2e9e:	4505                	li	a0,1
    2ea0:	5a1010ef          	jal	ra,4c40 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    2ea4:	85ca                	mv	a1,s2
    2ea6:	00003517          	auipc	a0,0x3
    2eaa:	63a50513          	addi	a0,a0,1594 # 64e0 <malloc+0x13c2>
    2eae:	1b6020ef          	jal	ra,5064 <printf>
    exit(1);
    2eb2:	4505                	li	a0,1
    2eb4:	58d010ef          	jal	ra,4c40 <exit>
    printf("%s: subdir mkdir dd/dd failed\n", s);
    2eb8:	85ca                	mv	a1,s2
    2eba:	00003517          	auipc	a0,0x3
    2ebe:	65e50513          	addi	a0,a0,1630 # 6518 <malloc+0x13fa>
    2ec2:	1a2020ef          	jal	ra,5064 <printf>
    exit(1);
    2ec6:	4505                	li	a0,1
    2ec8:	579010ef          	jal	ra,4c40 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    2ecc:	85ca                	mv	a1,s2
    2ece:	00003517          	auipc	a0,0x3
    2ed2:	67a50513          	addi	a0,a0,1658 # 6548 <malloc+0x142a>
    2ed6:	18e020ef          	jal	ra,5064 <printf>
    exit(1);
    2eda:	4505                	li	a0,1
    2edc:	565010ef          	jal	ra,4c40 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    2ee0:	85ca                	mv	a1,s2
    2ee2:	00003517          	auipc	a0,0x3
    2ee6:	69e50513          	addi	a0,a0,1694 # 6580 <malloc+0x1462>
    2eea:	17a020ef          	jal	ra,5064 <printf>
    exit(1);
    2eee:	4505                	li	a0,1
    2ef0:	551010ef          	jal	ra,4c40 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    2ef4:	85ca                	mv	a1,s2
    2ef6:	00003517          	auipc	a0,0x3
    2efa:	6aa50513          	addi	a0,a0,1706 # 65a0 <malloc+0x1482>
    2efe:	166020ef          	jal	ra,5064 <printf>
    exit(1);
    2f02:	4505                	li	a0,1
    2f04:	53d010ef          	jal	ra,4c40 <exit>
    printf("%s: link dd/dd/ff dd/dd/ffff failed\n", s);
    2f08:	85ca                	mv	a1,s2
    2f0a:	00003517          	auipc	a0,0x3
    2f0e:	6c650513          	addi	a0,a0,1734 # 65d0 <malloc+0x14b2>
    2f12:	152020ef          	jal	ra,5064 <printf>
    exit(1);
    2f16:	4505                	li	a0,1
    2f18:	529010ef          	jal	ra,4c40 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    2f1c:	85ca                	mv	a1,s2
    2f1e:	00003517          	auipc	a0,0x3
    2f22:	6da50513          	addi	a0,a0,1754 # 65f8 <malloc+0x14da>
    2f26:	13e020ef          	jal	ra,5064 <printf>
    exit(1);
    2f2a:	4505                	li	a0,1
    2f2c:	515010ef          	jal	ra,4c40 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    2f30:	85ca                	mv	a1,s2
    2f32:	00003517          	auipc	a0,0x3
    2f36:	6e650513          	addi	a0,a0,1766 # 6618 <malloc+0x14fa>
    2f3a:	12a020ef          	jal	ra,5064 <printf>
    exit(1);
    2f3e:	4505                	li	a0,1
    2f40:	501010ef          	jal	ra,4c40 <exit>
    printf("%s: chdir dd failed\n", s);
    2f44:	85ca                	mv	a1,s2
    2f46:	00003517          	auipc	a0,0x3
    2f4a:	6fa50513          	addi	a0,a0,1786 # 6640 <malloc+0x1522>
    2f4e:	116020ef          	jal	ra,5064 <printf>
    exit(1);
    2f52:	4505                	li	a0,1
    2f54:	4ed010ef          	jal	ra,4c40 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    2f58:	85ca                	mv	a1,s2
    2f5a:	00003517          	auipc	a0,0x3
    2f5e:	70e50513          	addi	a0,a0,1806 # 6668 <malloc+0x154a>
    2f62:	102020ef          	jal	ra,5064 <printf>
    exit(1);
    2f66:	4505                	li	a0,1
    2f68:	4d9010ef          	jal	ra,4c40 <exit>
    printf("%s: chdir dd/../../../dd failed\n", s);
    2f6c:	85ca                	mv	a1,s2
    2f6e:	00003517          	auipc	a0,0x3
    2f72:	72a50513          	addi	a0,a0,1834 # 6698 <malloc+0x157a>
    2f76:	0ee020ef          	jal	ra,5064 <printf>
    exit(1);
    2f7a:	4505                	li	a0,1
    2f7c:	4c5010ef          	jal	ra,4c40 <exit>
    printf("%s: chdir ./.. failed\n", s);
    2f80:	85ca                	mv	a1,s2
    2f82:	00003517          	auipc	a0,0x3
    2f86:	74650513          	addi	a0,a0,1862 # 66c8 <malloc+0x15aa>
    2f8a:	0da020ef          	jal	ra,5064 <printf>
    exit(1);
    2f8e:	4505                	li	a0,1
    2f90:	4b1010ef          	jal	ra,4c40 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    2f94:	85ca                	mv	a1,s2
    2f96:	00003517          	auipc	a0,0x3
    2f9a:	74a50513          	addi	a0,a0,1866 # 66e0 <malloc+0x15c2>
    2f9e:	0c6020ef          	jal	ra,5064 <printf>
    exit(1);
    2fa2:	4505                	li	a0,1
    2fa4:	49d010ef          	jal	ra,4c40 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    2fa8:	85ca                	mv	a1,s2
    2faa:	00003517          	auipc	a0,0x3
    2fae:	75650513          	addi	a0,a0,1878 # 6700 <malloc+0x15e2>
    2fb2:	0b2020ef          	jal	ra,5064 <printf>
    exit(1);
    2fb6:	4505                	li	a0,1
    2fb8:	489010ef          	jal	ra,4c40 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    2fbc:	85ca                	mv	a1,s2
    2fbe:	00003517          	auipc	a0,0x3
    2fc2:	76250513          	addi	a0,a0,1890 # 6720 <malloc+0x1602>
    2fc6:	09e020ef          	jal	ra,5064 <printf>
    exit(1);
    2fca:	4505                	li	a0,1
    2fcc:	475010ef          	jal	ra,4c40 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    2fd0:	85ca                	mv	a1,s2
    2fd2:	00003517          	auipc	a0,0x3
    2fd6:	78e50513          	addi	a0,a0,1934 # 6760 <malloc+0x1642>
    2fda:	08a020ef          	jal	ra,5064 <printf>
    exit(1);
    2fde:	4505                	li	a0,1
    2fe0:	461010ef          	jal	ra,4c40 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    2fe4:	85ca                	mv	a1,s2
    2fe6:	00003517          	auipc	a0,0x3
    2fea:	7aa50513          	addi	a0,a0,1962 # 6790 <malloc+0x1672>
    2fee:	076020ef          	jal	ra,5064 <printf>
    exit(1);
    2ff2:	4505                	li	a0,1
    2ff4:	44d010ef          	jal	ra,4c40 <exit>
    printf("%s: create dd succeeded!\n", s);
    2ff8:	85ca                	mv	a1,s2
    2ffa:	00003517          	auipc	a0,0x3
    2ffe:	7b650513          	addi	a0,a0,1974 # 67b0 <malloc+0x1692>
    3002:	062020ef          	jal	ra,5064 <printf>
    exit(1);
    3006:	4505                	li	a0,1
    3008:	439010ef          	jal	ra,4c40 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    300c:	85ca                	mv	a1,s2
    300e:	00003517          	auipc	a0,0x3
    3012:	7c250513          	addi	a0,a0,1986 # 67d0 <malloc+0x16b2>
    3016:	04e020ef          	jal	ra,5064 <printf>
    exit(1);
    301a:	4505                	li	a0,1
    301c:	425010ef          	jal	ra,4c40 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    3020:	85ca                	mv	a1,s2
    3022:	00003517          	auipc	a0,0x3
    3026:	7ce50513          	addi	a0,a0,1998 # 67f0 <malloc+0x16d2>
    302a:	03a020ef          	jal	ra,5064 <printf>
    exit(1);
    302e:	4505                	li	a0,1
    3030:	411010ef          	jal	ra,4c40 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3034:	85ca                	mv	a1,s2
    3036:	00003517          	auipc	a0,0x3
    303a:	7ea50513          	addi	a0,a0,2026 # 6820 <malloc+0x1702>
    303e:	026020ef          	jal	ra,5064 <printf>
    exit(1);
    3042:	4505                	li	a0,1
    3044:	3fd010ef          	jal	ra,4c40 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3048:	85ca                	mv	a1,s2
    304a:	00003517          	auipc	a0,0x3
    304e:	7fe50513          	addi	a0,a0,2046 # 6848 <malloc+0x172a>
    3052:	012020ef          	jal	ra,5064 <printf>
    exit(1);
    3056:	4505                	li	a0,1
    3058:	3e9010ef          	jal	ra,4c40 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    305c:	85ca                	mv	a1,s2
    305e:	00004517          	auipc	a0,0x4
    3062:	81250513          	addi	a0,a0,-2030 # 6870 <malloc+0x1752>
    3066:	7ff010ef          	jal	ra,5064 <printf>
    exit(1);
    306a:	4505                	li	a0,1
    306c:	3d5010ef          	jal	ra,4c40 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    3070:	85ca                	mv	a1,s2
    3072:	00004517          	auipc	a0,0x4
    3076:	82650513          	addi	a0,a0,-2010 # 6898 <malloc+0x177a>
    307a:	7eb010ef          	jal	ra,5064 <printf>
    exit(1);
    307e:	4505                	li	a0,1
    3080:	3c1010ef          	jal	ra,4c40 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    3084:	85ca                	mv	a1,s2
    3086:	00004517          	auipc	a0,0x4
    308a:	83250513          	addi	a0,a0,-1998 # 68b8 <malloc+0x179a>
    308e:	7d7010ef          	jal	ra,5064 <printf>
    exit(1);
    3092:	4505                	li	a0,1
    3094:	3ad010ef          	jal	ra,4c40 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    3098:	85ca                	mv	a1,s2
    309a:	00004517          	auipc	a0,0x4
    309e:	83e50513          	addi	a0,a0,-1986 # 68d8 <malloc+0x17ba>
    30a2:	7c3010ef          	jal	ra,5064 <printf>
    exit(1);
    30a6:	4505                	li	a0,1
    30a8:	399010ef          	jal	ra,4c40 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    30ac:	85ca                	mv	a1,s2
    30ae:	00004517          	auipc	a0,0x4
    30b2:	85250513          	addi	a0,a0,-1966 # 6900 <malloc+0x17e2>
    30b6:	7af010ef          	jal	ra,5064 <printf>
    exit(1);
    30ba:	4505                	li	a0,1
    30bc:	385010ef          	jal	ra,4c40 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    30c0:	85ca                	mv	a1,s2
    30c2:	00004517          	auipc	a0,0x4
    30c6:	85e50513          	addi	a0,a0,-1954 # 6920 <malloc+0x1802>
    30ca:	79b010ef          	jal	ra,5064 <printf>
    exit(1);
    30ce:	4505                	li	a0,1
    30d0:	371010ef          	jal	ra,4c40 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    30d4:	85ca                	mv	a1,s2
    30d6:	00004517          	auipc	a0,0x4
    30da:	86a50513          	addi	a0,a0,-1942 # 6940 <malloc+0x1822>
    30de:	787010ef          	jal	ra,5064 <printf>
    exit(1);
    30e2:	4505                	li	a0,1
    30e4:	35d010ef          	jal	ra,4c40 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    30e8:	85ca                	mv	a1,s2
    30ea:	00004517          	auipc	a0,0x4
    30ee:	87e50513          	addi	a0,a0,-1922 # 6968 <malloc+0x184a>
    30f2:	773010ef          	jal	ra,5064 <printf>
    exit(1);
    30f6:	4505                	li	a0,1
    30f8:	349010ef          	jal	ra,4c40 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    30fc:	85ca                	mv	a1,s2
    30fe:	00003517          	auipc	a0,0x3
    3102:	4fa50513          	addi	a0,a0,1274 # 65f8 <malloc+0x14da>
    3106:	75f010ef          	jal	ra,5064 <printf>
    exit(1);
    310a:	4505                	li	a0,1
    310c:	335010ef          	jal	ra,4c40 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    3110:	85ca                	mv	a1,s2
    3112:	00004517          	auipc	a0,0x4
    3116:	87650513          	addi	a0,a0,-1930 # 6988 <malloc+0x186a>
    311a:	74b010ef          	jal	ra,5064 <printf>
    exit(1);
    311e:	4505                	li	a0,1
    3120:	321010ef          	jal	ra,4c40 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    3124:	85ca                	mv	a1,s2
    3126:	00004517          	auipc	a0,0x4
    312a:	88250513          	addi	a0,a0,-1918 # 69a8 <malloc+0x188a>
    312e:	737010ef          	jal	ra,5064 <printf>
    exit(1);
    3132:	4505                	li	a0,1
    3134:	30d010ef          	jal	ra,4c40 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    3138:	85ca                	mv	a1,s2
    313a:	00004517          	auipc	a0,0x4
    313e:	89e50513          	addi	a0,a0,-1890 # 69d8 <malloc+0x18ba>
    3142:	723010ef          	jal	ra,5064 <printf>
    exit(1);
    3146:	4505                	li	a0,1
    3148:	2f9010ef          	jal	ra,4c40 <exit>
    printf("%s: unlink dd failed\n", s);
    314c:	85ca                	mv	a1,s2
    314e:	00004517          	auipc	a0,0x4
    3152:	8aa50513          	addi	a0,a0,-1878 # 69f8 <malloc+0x18da>
    3156:	70f010ef          	jal	ra,5064 <printf>
    exit(1);
    315a:	4505                	li	a0,1
    315c:	2e5010ef          	jal	ra,4c40 <exit>

0000000000003160 <rmdot>:
{
    3160:	1101                	addi	sp,sp,-32
    3162:	ec06                	sd	ra,24(sp)
    3164:	e822                	sd	s0,16(sp)
    3166:	e426                	sd	s1,8(sp)
    3168:	1000                	addi	s0,sp,32
    316a:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    316c:	00004517          	auipc	a0,0x4
    3170:	8a450513          	addi	a0,a0,-1884 # 6a10 <malloc+0x18f2>
    3174:	335010ef          	jal	ra,4ca8 <mkdir>
    3178:	e53d                	bnez	a0,31e6 <rmdot+0x86>
  if(chdir("dots") != 0){
    317a:	00004517          	auipc	a0,0x4
    317e:	89650513          	addi	a0,a0,-1898 # 6a10 <malloc+0x18f2>
    3182:	32f010ef          	jal	ra,4cb0 <chdir>
    3186:	e935                	bnez	a0,31fa <rmdot+0x9a>
  if(unlink(".") == 0){
    3188:	00002517          	auipc	a0,0x2
    318c:	7b850513          	addi	a0,a0,1976 # 5940 <malloc+0x822>
    3190:	301010ef          	jal	ra,4c90 <unlink>
    3194:	cd2d                	beqz	a0,320e <rmdot+0xae>
  if(unlink("..") == 0){
    3196:	00003517          	auipc	a0,0x3
    319a:	2ca50513          	addi	a0,a0,714 # 6460 <malloc+0x1342>
    319e:	2f3010ef          	jal	ra,4c90 <unlink>
    31a2:	c141                	beqz	a0,3222 <rmdot+0xc2>
  if(chdir("/") != 0){
    31a4:	00003517          	auipc	a0,0x3
    31a8:	26450513          	addi	a0,a0,612 # 6408 <malloc+0x12ea>
    31ac:	305010ef          	jal	ra,4cb0 <chdir>
    31b0:	e159                	bnez	a0,3236 <rmdot+0xd6>
  if(unlink("dots/.") == 0){
    31b2:	00004517          	auipc	a0,0x4
    31b6:	8c650513          	addi	a0,a0,-1850 # 6a78 <malloc+0x195a>
    31ba:	2d7010ef          	jal	ra,4c90 <unlink>
    31be:	c551                	beqz	a0,324a <rmdot+0xea>
  if(unlink("dots/..") == 0){
    31c0:	00004517          	auipc	a0,0x4
    31c4:	8e050513          	addi	a0,a0,-1824 # 6aa0 <malloc+0x1982>
    31c8:	2c9010ef          	jal	ra,4c90 <unlink>
    31cc:	c949                	beqz	a0,325e <rmdot+0xfe>
  if(unlink("dots") != 0){
    31ce:	00004517          	auipc	a0,0x4
    31d2:	84250513          	addi	a0,a0,-1982 # 6a10 <malloc+0x18f2>
    31d6:	2bb010ef          	jal	ra,4c90 <unlink>
    31da:	ed41                	bnez	a0,3272 <rmdot+0x112>
}
    31dc:	60e2                	ld	ra,24(sp)
    31de:	6442                	ld	s0,16(sp)
    31e0:	64a2                	ld	s1,8(sp)
    31e2:	6105                	addi	sp,sp,32
    31e4:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    31e6:	85a6                	mv	a1,s1
    31e8:	00004517          	auipc	a0,0x4
    31ec:	83050513          	addi	a0,a0,-2000 # 6a18 <malloc+0x18fa>
    31f0:	675010ef          	jal	ra,5064 <printf>
    exit(1);
    31f4:	4505                	li	a0,1
    31f6:	24b010ef          	jal	ra,4c40 <exit>
    printf("%s: chdir dots failed\n", s);
    31fa:	85a6                	mv	a1,s1
    31fc:	00004517          	auipc	a0,0x4
    3200:	83450513          	addi	a0,a0,-1996 # 6a30 <malloc+0x1912>
    3204:	661010ef          	jal	ra,5064 <printf>
    exit(1);
    3208:	4505                	li	a0,1
    320a:	237010ef          	jal	ra,4c40 <exit>
    printf("%s: rm . worked!\n", s);
    320e:	85a6                	mv	a1,s1
    3210:	00004517          	auipc	a0,0x4
    3214:	83850513          	addi	a0,a0,-1992 # 6a48 <malloc+0x192a>
    3218:	64d010ef          	jal	ra,5064 <printf>
    exit(1);
    321c:	4505                	li	a0,1
    321e:	223010ef          	jal	ra,4c40 <exit>
    printf("%s: rm .. worked!\n", s);
    3222:	85a6                	mv	a1,s1
    3224:	00004517          	auipc	a0,0x4
    3228:	83c50513          	addi	a0,a0,-1988 # 6a60 <malloc+0x1942>
    322c:	639010ef          	jal	ra,5064 <printf>
    exit(1);
    3230:	4505                	li	a0,1
    3232:	20f010ef          	jal	ra,4c40 <exit>
    printf("%s: chdir / failed\n", s);
    3236:	85a6                	mv	a1,s1
    3238:	00003517          	auipc	a0,0x3
    323c:	1d850513          	addi	a0,a0,472 # 6410 <malloc+0x12f2>
    3240:	625010ef          	jal	ra,5064 <printf>
    exit(1);
    3244:	4505                	li	a0,1
    3246:	1fb010ef          	jal	ra,4c40 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    324a:	85a6                	mv	a1,s1
    324c:	00004517          	auipc	a0,0x4
    3250:	83450513          	addi	a0,a0,-1996 # 6a80 <malloc+0x1962>
    3254:	611010ef          	jal	ra,5064 <printf>
    exit(1);
    3258:	4505                	li	a0,1
    325a:	1e7010ef          	jal	ra,4c40 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    325e:	85a6                	mv	a1,s1
    3260:	00004517          	auipc	a0,0x4
    3264:	84850513          	addi	a0,a0,-1976 # 6aa8 <malloc+0x198a>
    3268:	5fd010ef          	jal	ra,5064 <printf>
    exit(1);
    326c:	4505                	li	a0,1
    326e:	1d3010ef          	jal	ra,4c40 <exit>
    printf("%s: unlink dots failed!\n", s);
    3272:	85a6                	mv	a1,s1
    3274:	00004517          	auipc	a0,0x4
    3278:	85450513          	addi	a0,a0,-1964 # 6ac8 <malloc+0x19aa>
    327c:	5e9010ef          	jal	ra,5064 <printf>
    exit(1);
    3280:	4505                	li	a0,1
    3282:	1bf010ef          	jal	ra,4c40 <exit>

0000000000003286 <dirfile>:
{
    3286:	1101                	addi	sp,sp,-32
    3288:	ec06                	sd	ra,24(sp)
    328a:	e822                	sd	s0,16(sp)
    328c:	e426                	sd	s1,8(sp)
    328e:	e04a                	sd	s2,0(sp)
    3290:	1000                	addi	s0,sp,32
    3292:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    3294:	20000593          	li	a1,512
    3298:	00004517          	auipc	a0,0x4
    329c:	85050513          	addi	a0,a0,-1968 # 6ae8 <malloc+0x19ca>
    32a0:	1e1010ef          	jal	ra,4c80 <open>
  if(fd < 0){
    32a4:	0c054563          	bltz	a0,336e <dirfile+0xe8>
  close(fd);
    32a8:	1c1010ef          	jal	ra,4c68 <close>
  if(chdir("dirfile") == 0){
    32ac:	00004517          	auipc	a0,0x4
    32b0:	83c50513          	addi	a0,a0,-1988 # 6ae8 <malloc+0x19ca>
    32b4:	1fd010ef          	jal	ra,4cb0 <chdir>
    32b8:	c569                	beqz	a0,3382 <dirfile+0xfc>
  fd = open("dirfile/xx", 0);
    32ba:	4581                	li	a1,0
    32bc:	00004517          	auipc	a0,0x4
    32c0:	87450513          	addi	a0,a0,-1932 # 6b30 <malloc+0x1a12>
    32c4:	1bd010ef          	jal	ra,4c80 <open>
  if(fd >= 0){
    32c8:	0c055763          	bgez	a0,3396 <dirfile+0x110>
  fd = open("dirfile/xx", O_CREATE);
    32cc:	20000593          	li	a1,512
    32d0:	00004517          	auipc	a0,0x4
    32d4:	86050513          	addi	a0,a0,-1952 # 6b30 <malloc+0x1a12>
    32d8:	1a9010ef          	jal	ra,4c80 <open>
  if(fd >= 0){
    32dc:	0c055763          	bgez	a0,33aa <dirfile+0x124>
  if(mkdir("dirfile/xx") == 0){
    32e0:	00004517          	auipc	a0,0x4
    32e4:	85050513          	addi	a0,a0,-1968 # 6b30 <malloc+0x1a12>
    32e8:	1c1010ef          	jal	ra,4ca8 <mkdir>
    32ec:	0c050963          	beqz	a0,33be <dirfile+0x138>
  if(unlink("dirfile/xx") == 0){
    32f0:	00004517          	auipc	a0,0x4
    32f4:	84050513          	addi	a0,a0,-1984 # 6b30 <malloc+0x1a12>
    32f8:	199010ef          	jal	ra,4c90 <unlink>
    32fc:	0c050b63          	beqz	a0,33d2 <dirfile+0x14c>
  if(link("README", "dirfile/xx") == 0){
    3300:	00004597          	auipc	a1,0x4
    3304:	83058593          	addi	a1,a1,-2000 # 6b30 <malloc+0x1a12>
    3308:	00002517          	auipc	a0,0x2
    330c:	12850513          	addi	a0,a0,296 # 5430 <malloc+0x312>
    3310:	191010ef          	jal	ra,4ca0 <link>
    3314:	0c050963          	beqz	a0,33e6 <dirfile+0x160>
  if(unlink("dirfile") != 0){
    3318:	00003517          	auipc	a0,0x3
    331c:	7d050513          	addi	a0,a0,2000 # 6ae8 <malloc+0x19ca>
    3320:	171010ef          	jal	ra,4c90 <unlink>
    3324:	0c051b63          	bnez	a0,33fa <dirfile+0x174>
  fd = open(".", O_RDWR);
    3328:	4589                	li	a1,2
    332a:	00002517          	auipc	a0,0x2
    332e:	61650513          	addi	a0,a0,1558 # 5940 <malloc+0x822>
    3332:	14f010ef          	jal	ra,4c80 <open>
  if(fd >= 0){
    3336:	0c055c63          	bgez	a0,340e <dirfile+0x188>
  fd = open(".", 0);
    333a:	4581                	li	a1,0
    333c:	00002517          	auipc	a0,0x2
    3340:	60450513          	addi	a0,a0,1540 # 5940 <malloc+0x822>
    3344:	13d010ef          	jal	ra,4c80 <open>
    3348:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    334a:	4605                	li	a2,1
    334c:	00002597          	auipc	a1,0x2
    3350:	f7c58593          	addi	a1,a1,-132 # 52c8 <malloc+0x1aa>
    3354:	10d010ef          	jal	ra,4c60 <write>
    3358:	0ca04563          	bgtz	a0,3422 <dirfile+0x19c>
  close(fd);
    335c:	8526                	mv	a0,s1
    335e:	10b010ef          	jal	ra,4c68 <close>
}
    3362:	60e2                	ld	ra,24(sp)
    3364:	6442                	ld	s0,16(sp)
    3366:	64a2                	ld	s1,8(sp)
    3368:	6902                	ld	s2,0(sp)
    336a:	6105                	addi	sp,sp,32
    336c:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    336e:	85ca                	mv	a1,s2
    3370:	00003517          	auipc	a0,0x3
    3374:	78050513          	addi	a0,a0,1920 # 6af0 <malloc+0x19d2>
    3378:	4ed010ef          	jal	ra,5064 <printf>
    exit(1);
    337c:	4505                	li	a0,1
    337e:	0c3010ef          	jal	ra,4c40 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    3382:	85ca                	mv	a1,s2
    3384:	00003517          	auipc	a0,0x3
    3388:	78c50513          	addi	a0,a0,1932 # 6b10 <malloc+0x19f2>
    338c:	4d9010ef          	jal	ra,5064 <printf>
    exit(1);
    3390:	4505                	li	a0,1
    3392:	0af010ef          	jal	ra,4c40 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3396:	85ca                	mv	a1,s2
    3398:	00003517          	auipc	a0,0x3
    339c:	7a850513          	addi	a0,a0,1960 # 6b40 <malloc+0x1a22>
    33a0:	4c5010ef          	jal	ra,5064 <printf>
    exit(1);
    33a4:	4505                	li	a0,1
    33a6:	09b010ef          	jal	ra,4c40 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    33aa:	85ca                	mv	a1,s2
    33ac:	00003517          	auipc	a0,0x3
    33b0:	79450513          	addi	a0,a0,1940 # 6b40 <malloc+0x1a22>
    33b4:	4b1010ef          	jal	ra,5064 <printf>
    exit(1);
    33b8:	4505                	li	a0,1
    33ba:	087010ef          	jal	ra,4c40 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    33be:	85ca                	mv	a1,s2
    33c0:	00003517          	auipc	a0,0x3
    33c4:	7a850513          	addi	a0,a0,1960 # 6b68 <malloc+0x1a4a>
    33c8:	49d010ef          	jal	ra,5064 <printf>
    exit(1);
    33cc:	4505                	li	a0,1
    33ce:	073010ef          	jal	ra,4c40 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    33d2:	85ca                	mv	a1,s2
    33d4:	00003517          	auipc	a0,0x3
    33d8:	7bc50513          	addi	a0,a0,1980 # 6b90 <malloc+0x1a72>
    33dc:	489010ef          	jal	ra,5064 <printf>
    exit(1);
    33e0:	4505                	li	a0,1
    33e2:	05f010ef          	jal	ra,4c40 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    33e6:	85ca                	mv	a1,s2
    33e8:	00003517          	auipc	a0,0x3
    33ec:	7d050513          	addi	a0,a0,2000 # 6bb8 <malloc+0x1a9a>
    33f0:	475010ef          	jal	ra,5064 <printf>
    exit(1);
    33f4:	4505                	li	a0,1
    33f6:	04b010ef          	jal	ra,4c40 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    33fa:	85ca                	mv	a1,s2
    33fc:	00003517          	auipc	a0,0x3
    3400:	7e450513          	addi	a0,a0,2020 # 6be0 <malloc+0x1ac2>
    3404:	461010ef          	jal	ra,5064 <printf>
    exit(1);
    3408:	4505                	li	a0,1
    340a:	037010ef          	jal	ra,4c40 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    340e:	85ca                	mv	a1,s2
    3410:	00003517          	auipc	a0,0x3
    3414:	7f050513          	addi	a0,a0,2032 # 6c00 <malloc+0x1ae2>
    3418:	44d010ef          	jal	ra,5064 <printf>
    exit(1);
    341c:	4505                	li	a0,1
    341e:	023010ef          	jal	ra,4c40 <exit>
    printf("%s: write . succeeded!\n", s);
    3422:	85ca                	mv	a1,s2
    3424:	00004517          	auipc	a0,0x4
    3428:	80450513          	addi	a0,a0,-2044 # 6c28 <malloc+0x1b0a>
    342c:	439010ef          	jal	ra,5064 <printf>
    exit(1);
    3430:	4505                	li	a0,1
    3432:	00f010ef          	jal	ra,4c40 <exit>

0000000000003436 <iref>:
{
    3436:	7139                	addi	sp,sp,-64
    3438:	fc06                	sd	ra,56(sp)
    343a:	f822                	sd	s0,48(sp)
    343c:	f426                	sd	s1,40(sp)
    343e:	f04a                	sd	s2,32(sp)
    3440:	ec4e                	sd	s3,24(sp)
    3442:	e852                	sd	s4,16(sp)
    3444:	e456                	sd	s5,8(sp)
    3446:	e05a                	sd	s6,0(sp)
    3448:	0080                	addi	s0,sp,64
    344a:	8b2a                	mv	s6,a0
    344c:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    3450:	00003a17          	auipc	s4,0x3
    3454:	7f0a0a13          	addi	s4,s4,2032 # 6c40 <malloc+0x1b22>
    mkdir("");
    3458:	00003497          	auipc	s1,0x3
    345c:	2f048493          	addi	s1,s1,752 # 6748 <malloc+0x162a>
    link("README", "");
    3460:	00002a97          	auipc	s5,0x2
    3464:	fd0a8a93          	addi	s5,s5,-48 # 5430 <malloc+0x312>
    fd = open("xx", O_CREATE);
    3468:	00003997          	auipc	s3,0x3
    346c:	6d098993          	addi	s3,s3,1744 # 6b38 <malloc+0x1a1a>
    3470:	a835                	j	34ac <iref+0x76>
      printf("%s: mkdir irefd failed\n", s);
    3472:	85da                	mv	a1,s6
    3474:	00003517          	auipc	a0,0x3
    3478:	7d450513          	addi	a0,a0,2004 # 6c48 <malloc+0x1b2a>
    347c:	3e9010ef          	jal	ra,5064 <printf>
      exit(1);
    3480:	4505                	li	a0,1
    3482:	7be010ef          	jal	ra,4c40 <exit>
      printf("%s: chdir irefd failed\n", s);
    3486:	85da                	mv	a1,s6
    3488:	00003517          	auipc	a0,0x3
    348c:	7d850513          	addi	a0,a0,2008 # 6c60 <malloc+0x1b42>
    3490:	3d5010ef          	jal	ra,5064 <printf>
      exit(1);
    3494:	4505                	li	a0,1
    3496:	7aa010ef          	jal	ra,4c40 <exit>
      close(fd);
    349a:	7ce010ef          	jal	ra,4c68 <close>
    349e:	a82d                	j	34d8 <iref+0xa2>
    unlink("xx");
    34a0:	854e                	mv	a0,s3
    34a2:	7ee010ef          	jal	ra,4c90 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    34a6:	397d                	addiw	s2,s2,-1
    34a8:	04090263          	beqz	s2,34ec <iref+0xb6>
    if(mkdir("irefd") != 0){
    34ac:	8552                	mv	a0,s4
    34ae:	7fa010ef          	jal	ra,4ca8 <mkdir>
    34b2:	f161                	bnez	a0,3472 <iref+0x3c>
    if(chdir("irefd") != 0){
    34b4:	8552                	mv	a0,s4
    34b6:	7fa010ef          	jal	ra,4cb0 <chdir>
    34ba:	f571                	bnez	a0,3486 <iref+0x50>
    mkdir("");
    34bc:	8526                	mv	a0,s1
    34be:	7ea010ef          	jal	ra,4ca8 <mkdir>
    link("README", "");
    34c2:	85a6                	mv	a1,s1
    34c4:	8556                	mv	a0,s5
    34c6:	7da010ef          	jal	ra,4ca0 <link>
    fd = open("", O_CREATE);
    34ca:	20000593          	li	a1,512
    34ce:	8526                	mv	a0,s1
    34d0:	7b0010ef          	jal	ra,4c80 <open>
    if(fd >= 0)
    34d4:	fc0553e3          	bgez	a0,349a <iref+0x64>
    fd = open("xx", O_CREATE);
    34d8:	20000593          	li	a1,512
    34dc:	854e                	mv	a0,s3
    34de:	7a2010ef          	jal	ra,4c80 <open>
    if(fd >= 0)
    34e2:	fa054fe3          	bltz	a0,34a0 <iref+0x6a>
      close(fd);
    34e6:	782010ef          	jal	ra,4c68 <close>
    34ea:	bf5d                	j	34a0 <iref+0x6a>
    34ec:	03300493          	li	s1,51
    chdir("..");
    34f0:	00003997          	auipc	s3,0x3
    34f4:	f7098993          	addi	s3,s3,-144 # 6460 <malloc+0x1342>
    unlink("irefd");
    34f8:	00003917          	auipc	s2,0x3
    34fc:	74890913          	addi	s2,s2,1864 # 6c40 <malloc+0x1b22>
    chdir("..");
    3500:	854e                	mv	a0,s3
    3502:	7ae010ef          	jal	ra,4cb0 <chdir>
    unlink("irefd");
    3506:	854a                	mv	a0,s2
    3508:	788010ef          	jal	ra,4c90 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    350c:	34fd                	addiw	s1,s1,-1
    350e:	f8ed                	bnez	s1,3500 <iref+0xca>
  chdir("/");
    3510:	00003517          	auipc	a0,0x3
    3514:	ef850513          	addi	a0,a0,-264 # 6408 <malloc+0x12ea>
    3518:	798010ef          	jal	ra,4cb0 <chdir>
}
    351c:	70e2                	ld	ra,56(sp)
    351e:	7442                	ld	s0,48(sp)
    3520:	74a2                	ld	s1,40(sp)
    3522:	7902                	ld	s2,32(sp)
    3524:	69e2                	ld	s3,24(sp)
    3526:	6a42                	ld	s4,16(sp)
    3528:	6aa2                	ld	s5,8(sp)
    352a:	6b02                	ld	s6,0(sp)
    352c:	6121                	addi	sp,sp,64
    352e:	8082                	ret

0000000000003530 <openiputtest>:
{
    3530:	7179                	addi	sp,sp,-48
    3532:	f406                	sd	ra,40(sp)
    3534:	f022                	sd	s0,32(sp)
    3536:	ec26                	sd	s1,24(sp)
    3538:	1800                	addi	s0,sp,48
    353a:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    353c:	00003517          	auipc	a0,0x3
    3540:	73c50513          	addi	a0,a0,1852 # 6c78 <malloc+0x1b5a>
    3544:	764010ef          	jal	ra,4ca8 <mkdir>
    3548:	02054a63          	bltz	a0,357c <openiputtest+0x4c>
  pid = fork();
    354c:	6ec010ef          	jal	ra,4c38 <fork>
  if(pid < 0){
    3550:	04054063          	bltz	a0,3590 <openiputtest+0x60>
  if(pid == 0){
    3554:	e939                	bnez	a0,35aa <openiputtest+0x7a>
    int fd = open("oidir", O_RDWR);
    3556:	4589                	li	a1,2
    3558:	00003517          	auipc	a0,0x3
    355c:	72050513          	addi	a0,a0,1824 # 6c78 <malloc+0x1b5a>
    3560:	720010ef          	jal	ra,4c80 <open>
    if(fd >= 0){
    3564:	04054063          	bltz	a0,35a4 <openiputtest+0x74>
      printf("%s: open directory for write succeeded\n", s);
    3568:	85a6                	mv	a1,s1
    356a:	00003517          	auipc	a0,0x3
    356e:	72e50513          	addi	a0,a0,1838 # 6c98 <malloc+0x1b7a>
    3572:	2f3010ef          	jal	ra,5064 <printf>
      exit(1);
    3576:	4505                	li	a0,1
    3578:	6c8010ef          	jal	ra,4c40 <exit>
    printf("%s: mkdir oidir failed\n", s);
    357c:	85a6                	mv	a1,s1
    357e:	00003517          	auipc	a0,0x3
    3582:	70250513          	addi	a0,a0,1794 # 6c80 <malloc+0x1b62>
    3586:	2df010ef          	jal	ra,5064 <printf>
    exit(1);
    358a:	4505                	li	a0,1
    358c:	6b4010ef          	jal	ra,4c40 <exit>
    printf("%s: fork failed\n", s);
    3590:	85a6                	mv	a1,s1
    3592:	00002517          	auipc	a0,0x2
    3596:	55650513          	addi	a0,a0,1366 # 5ae8 <malloc+0x9ca>
    359a:	2cb010ef          	jal	ra,5064 <printf>
    exit(1);
    359e:	4505                	li	a0,1
    35a0:	6a0010ef          	jal	ra,4c40 <exit>
    exit(0);
    35a4:	4501                	li	a0,0
    35a6:	69a010ef          	jal	ra,4c40 <exit>
  pause(1);
    35aa:	4505                	li	a0,1
    35ac:	724010ef          	jal	ra,4cd0 <pause>
  if(unlink("oidir") != 0){
    35b0:	00003517          	auipc	a0,0x3
    35b4:	6c850513          	addi	a0,a0,1736 # 6c78 <malloc+0x1b5a>
    35b8:	6d8010ef          	jal	ra,4c90 <unlink>
    35bc:	c919                	beqz	a0,35d2 <openiputtest+0xa2>
    printf("%s: unlink failed\n", s);
    35be:	85a6                	mv	a1,s1
    35c0:	00002517          	auipc	a0,0x2
    35c4:	71850513          	addi	a0,a0,1816 # 5cd8 <malloc+0xbba>
    35c8:	29d010ef          	jal	ra,5064 <printf>
    exit(1);
    35cc:	4505                	li	a0,1
    35ce:	672010ef          	jal	ra,4c40 <exit>
  wait(&xstatus);
    35d2:	fdc40513          	addi	a0,s0,-36
    35d6:	672010ef          	jal	ra,4c48 <wait>
  exit(xstatus);
    35da:	fdc42503          	lw	a0,-36(s0)
    35de:	662010ef          	jal	ra,4c40 <exit>

00000000000035e2 <forkforkfork>:
{
    35e2:	1101                	addi	sp,sp,-32
    35e4:	ec06                	sd	ra,24(sp)
    35e6:	e822                	sd	s0,16(sp)
    35e8:	e426                	sd	s1,8(sp)
    35ea:	1000                	addi	s0,sp,32
    35ec:	84aa                	mv	s1,a0
  unlink("stopforking");
    35ee:	00003517          	auipc	a0,0x3
    35f2:	6d250513          	addi	a0,a0,1746 # 6cc0 <malloc+0x1ba2>
    35f6:	69a010ef          	jal	ra,4c90 <unlink>
  int pid = fork();
    35fa:	63e010ef          	jal	ra,4c38 <fork>
  if(pid < 0){
    35fe:	02054b63          	bltz	a0,3634 <forkforkfork+0x52>
  if(pid == 0){
    3602:	c139                	beqz	a0,3648 <forkforkfork+0x66>
  pause(20); // two seconds
    3604:	4551                	li	a0,20
    3606:	6ca010ef          	jal	ra,4cd0 <pause>
  close(open("stopforking", O_CREATE|O_RDWR));
    360a:	20200593          	li	a1,514
    360e:	00003517          	auipc	a0,0x3
    3612:	6b250513          	addi	a0,a0,1714 # 6cc0 <malloc+0x1ba2>
    3616:	66a010ef          	jal	ra,4c80 <open>
    361a:	64e010ef          	jal	ra,4c68 <close>
  wait(0);
    361e:	4501                	li	a0,0
    3620:	628010ef          	jal	ra,4c48 <wait>
  pause(10); // one second
    3624:	4529                	li	a0,10
    3626:	6aa010ef          	jal	ra,4cd0 <pause>
}
    362a:	60e2                	ld	ra,24(sp)
    362c:	6442                	ld	s0,16(sp)
    362e:	64a2                	ld	s1,8(sp)
    3630:	6105                	addi	sp,sp,32
    3632:	8082                	ret
    printf("%s: fork failed", s);
    3634:	85a6                	mv	a1,s1
    3636:	00002517          	auipc	a0,0x2
    363a:	67250513          	addi	a0,a0,1650 # 5ca8 <malloc+0xb8a>
    363e:	227010ef          	jal	ra,5064 <printf>
    exit(1);
    3642:	4505                	li	a0,1
    3644:	5fc010ef          	jal	ra,4c40 <exit>
      int fd = open("stopforking", 0);
    3648:	00003497          	auipc	s1,0x3
    364c:	67848493          	addi	s1,s1,1656 # 6cc0 <malloc+0x1ba2>
    3650:	4581                	li	a1,0
    3652:	8526                	mv	a0,s1
    3654:	62c010ef          	jal	ra,4c80 <open>
      if(fd >= 0){
    3658:	00055e63          	bgez	a0,3674 <forkforkfork+0x92>
      if(fork() < 0){
    365c:	5dc010ef          	jal	ra,4c38 <fork>
    3660:	fe0558e3          	bgez	a0,3650 <forkforkfork+0x6e>
        close(open("stopforking", O_CREATE|O_RDWR));
    3664:	20200593          	li	a1,514
    3668:	8526                	mv	a0,s1
    366a:	616010ef          	jal	ra,4c80 <open>
    366e:	5fa010ef          	jal	ra,4c68 <close>
    3672:	bff9                	j	3650 <forkforkfork+0x6e>
        exit(0);
    3674:	4501                	li	a0,0
    3676:	5ca010ef          	jal	ra,4c40 <exit>

000000000000367a <killstatus>:
{
    367a:	7139                	addi	sp,sp,-64
    367c:	fc06                	sd	ra,56(sp)
    367e:	f822                	sd	s0,48(sp)
    3680:	f426                	sd	s1,40(sp)
    3682:	f04a                	sd	s2,32(sp)
    3684:	ec4e                	sd	s3,24(sp)
    3686:	e852                	sd	s4,16(sp)
    3688:	0080                	addi	s0,sp,64
    368a:	8a2a                	mv	s4,a0
    368c:	06400913          	li	s2,100
    if(xst != -1) {
    3690:	59fd                	li	s3,-1
    int pid1 = fork();
    3692:	5a6010ef          	jal	ra,4c38 <fork>
    3696:	84aa                	mv	s1,a0
    if(pid1 < 0){
    3698:	02054763          	bltz	a0,36c6 <killstatus+0x4c>
    if(pid1 == 0){
    369c:	cd1d                	beqz	a0,36da <killstatus+0x60>
    pause(1);
    369e:	4505                	li	a0,1
    36a0:	630010ef          	jal	ra,4cd0 <pause>
    kill(pid1);
    36a4:	8526                	mv	a0,s1
    36a6:	5ca010ef          	jal	ra,4c70 <kill>
    wait(&xst);
    36aa:	fcc40513          	addi	a0,s0,-52
    36ae:	59a010ef          	jal	ra,4c48 <wait>
    if(xst != -1) {
    36b2:	fcc42783          	lw	a5,-52(s0)
    36b6:	03379563          	bne	a5,s3,36e0 <killstatus+0x66>
  for(int i = 0; i < 100; i++){
    36ba:	397d                	addiw	s2,s2,-1
    36bc:	fc091be3          	bnez	s2,3692 <killstatus+0x18>
  exit(0);
    36c0:	4501                	li	a0,0
    36c2:	57e010ef          	jal	ra,4c40 <exit>
      printf("%s: fork failed\n", s);
    36c6:	85d2                	mv	a1,s4
    36c8:	00002517          	auipc	a0,0x2
    36cc:	42050513          	addi	a0,a0,1056 # 5ae8 <malloc+0x9ca>
    36d0:	195010ef          	jal	ra,5064 <printf>
      exit(1);
    36d4:	4505                	li	a0,1
    36d6:	56a010ef          	jal	ra,4c40 <exit>
        getpid();
    36da:	5e6010ef          	jal	ra,4cc0 <getpid>
      while(1) {
    36de:	bff5                	j	36da <killstatus+0x60>
       printf("%s: status should be -1\n", s);
    36e0:	85d2                	mv	a1,s4
    36e2:	00003517          	auipc	a0,0x3
    36e6:	5ee50513          	addi	a0,a0,1518 # 6cd0 <malloc+0x1bb2>
    36ea:	17b010ef          	jal	ra,5064 <printf>
       exit(1);
    36ee:	4505                	li	a0,1
    36f0:	550010ef          	jal	ra,4c40 <exit>

00000000000036f4 <preempt>:
{
    36f4:	7139                	addi	sp,sp,-64
    36f6:	fc06                	sd	ra,56(sp)
    36f8:	f822                	sd	s0,48(sp)
    36fa:	f426                	sd	s1,40(sp)
    36fc:	f04a                	sd	s2,32(sp)
    36fe:	ec4e                	sd	s3,24(sp)
    3700:	e852                	sd	s4,16(sp)
    3702:	0080                	addi	s0,sp,64
    3704:	892a                	mv	s2,a0
  pid1 = fork();
    3706:	532010ef          	jal	ra,4c38 <fork>
  if(pid1 < 0) {
    370a:	00054563          	bltz	a0,3714 <preempt+0x20>
    370e:	84aa                	mv	s1,a0
  if(pid1 == 0)
    3710:	ed01                	bnez	a0,3728 <preempt+0x34>
    for(;;)
    3712:	a001                	j	3712 <preempt+0x1e>
    printf("%s: fork failed", s);
    3714:	85ca                	mv	a1,s2
    3716:	00002517          	auipc	a0,0x2
    371a:	59250513          	addi	a0,a0,1426 # 5ca8 <malloc+0xb8a>
    371e:	147010ef          	jal	ra,5064 <printf>
    exit(1);
    3722:	4505                	li	a0,1
    3724:	51c010ef          	jal	ra,4c40 <exit>
  pid2 = fork();
    3728:	510010ef          	jal	ra,4c38 <fork>
    372c:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    372e:	00054463          	bltz	a0,3736 <preempt+0x42>
  if(pid2 == 0)
    3732:	ed01                	bnez	a0,374a <preempt+0x56>
    for(;;)
    3734:	a001                	j	3734 <preempt+0x40>
    printf("%s: fork failed\n", s);
    3736:	85ca                	mv	a1,s2
    3738:	00002517          	auipc	a0,0x2
    373c:	3b050513          	addi	a0,a0,944 # 5ae8 <malloc+0x9ca>
    3740:	125010ef          	jal	ra,5064 <printf>
    exit(1);
    3744:	4505                	li	a0,1
    3746:	4fa010ef          	jal	ra,4c40 <exit>
  pipe(pfds);
    374a:	fc840513          	addi	a0,s0,-56
    374e:	502010ef          	jal	ra,4c50 <pipe>
  pid3 = fork();
    3752:	4e6010ef          	jal	ra,4c38 <fork>
    3756:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
    3758:	02054863          	bltz	a0,3788 <preempt+0x94>
  if(pid3 == 0){
    375c:	e921                	bnez	a0,37ac <preempt+0xb8>
    close(pfds[0]);
    375e:	fc842503          	lw	a0,-56(s0)
    3762:	506010ef          	jal	ra,4c68 <close>
    if(write(pfds[1], "x", 1) != 1)
    3766:	4605                	li	a2,1
    3768:	00002597          	auipc	a1,0x2
    376c:	b6058593          	addi	a1,a1,-1184 # 52c8 <malloc+0x1aa>
    3770:	fcc42503          	lw	a0,-52(s0)
    3774:	4ec010ef          	jal	ra,4c60 <write>
    3778:	4785                	li	a5,1
    377a:	02f51163          	bne	a0,a5,379c <preempt+0xa8>
    close(pfds[1]);
    377e:	fcc42503          	lw	a0,-52(s0)
    3782:	4e6010ef          	jal	ra,4c68 <close>
    for(;;)
    3786:	a001                	j	3786 <preempt+0x92>
     printf("%s: fork failed\n", s);
    3788:	85ca                	mv	a1,s2
    378a:	00002517          	auipc	a0,0x2
    378e:	35e50513          	addi	a0,a0,862 # 5ae8 <malloc+0x9ca>
    3792:	0d3010ef          	jal	ra,5064 <printf>
     exit(1);
    3796:	4505                	li	a0,1
    3798:	4a8010ef          	jal	ra,4c40 <exit>
      printf("%s: preempt write error", s);
    379c:	85ca                	mv	a1,s2
    379e:	00003517          	auipc	a0,0x3
    37a2:	55250513          	addi	a0,a0,1362 # 6cf0 <malloc+0x1bd2>
    37a6:	0bf010ef          	jal	ra,5064 <printf>
    37aa:	bfd1                	j	377e <preempt+0x8a>
  close(pfds[1]);
    37ac:	fcc42503          	lw	a0,-52(s0)
    37b0:	4b8010ef          	jal	ra,4c68 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    37b4:	660d                	lui	a2,0x3
    37b6:	00008597          	auipc	a1,0x8
    37ba:	4f258593          	addi	a1,a1,1266 # bca8 <buf>
    37be:	fc842503          	lw	a0,-56(s0)
    37c2:	496010ef          	jal	ra,4c58 <read>
    37c6:	4785                	li	a5,1
    37c8:	02f50163          	beq	a0,a5,37ea <preempt+0xf6>
    printf("%s: preempt read error", s);
    37cc:	85ca                	mv	a1,s2
    37ce:	00003517          	auipc	a0,0x3
    37d2:	53a50513          	addi	a0,a0,1338 # 6d08 <malloc+0x1bea>
    37d6:	08f010ef          	jal	ra,5064 <printf>
}
    37da:	70e2                	ld	ra,56(sp)
    37dc:	7442                	ld	s0,48(sp)
    37de:	74a2                	ld	s1,40(sp)
    37e0:	7902                	ld	s2,32(sp)
    37e2:	69e2                	ld	s3,24(sp)
    37e4:	6a42                	ld	s4,16(sp)
    37e6:	6121                	addi	sp,sp,64
    37e8:	8082                	ret
  close(pfds[0]);
    37ea:	fc842503          	lw	a0,-56(s0)
    37ee:	47a010ef          	jal	ra,4c68 <close>
  printf("kill... ");
    37f2:	00003517          	auipc	a0,0x3
    37f6:	52e50513          	addi	a0,a0,1326 # 6d20 <malloc+0x1c02>
    37fa:	06b010ef          	jal	ra,5064 <printf>
  kill(pid1);
    37fe:	8526                	mv	a0,s1
    3800:	470010ef          	jal	ra,4c70 <kill>
  kill(pid2);
    3804:	854e                	mv	a0,s3
    3806:	46a010ef          	jal	ra,4c70 <kill>
  kill(pid3);
    380a:	8552                	mv	a0,s4
    380c:	464010ef          	jal	ra,4c70 <kill>
  printf("wait... ");
    3810:	00003517          	auipc	a0,0x3
    3814:	52050513          	addi	a0,a0,1312 # 6d30 <malloc+0x1c12>
    3818:	04d010ef          	jal	ra,5064 <printf>
  wait(0);
    381c:	4501                	li	a0,0
    381e:	42a010ef          	jal	ra,4c48 <wait>
  wait(0);
    3822:	4501                	li	a0,0
    3824:	424010ef          	jal	ra,4c48 <wait>
  wait(0);
    3828:	4501                	li	a0,0
    382a:	41e010ef          	jal	ra,4c48 <wait>
    382e:	b775                	j	37da <preempt+0xe6>

0000000000003830 <reparent>:
{
    3830:	7179                	addi	sp,sp,-48
    3832:	f406                	sd	ra,40(sp)
    3834:	f022                	sd	s0,32(sp)
    3836:	ec26                	sd	s1,24(sp)
    3838:	e84a                	sd	s2,16(sp)
    383a:	e44e                	sd	s3,8(sp)
    383c:	e052                	sd	s4,0(sp)
    383e:	1800                	addi	s0,sp,48
    3840:	89aa                	mv	s3,a0
  int master_pid = getpid();
    3842:	47e010ef          	jal	ra,4cc0 <getpid>
    3846:	8a2a                	mv	s4,a0
    3848:	0c800913          	li	s2,200
    int pid = fork();
    384c:	3ec010ef          	jal	ra,4c38 <fork>
    3850:	84aa                	mv	s1,a0
    if(pid < 0){
    3852:	00054e63          	bltz	a0,386e <reparent+0x3e>
    if(pid){
    3856:	c121                	beqz	a0,3896 <reparent+0x66>
      if(wait(0) != pid){
    3858:	4501                	li	a0,0
    385a:	3ee010ef          	jal	ra,4c48 <wait>
    385e:	02951263          	bne	a0,s1,3882 <reparent+0x52>
  for(int i = 0; i < 200; i++){
    3862:	397d                	addiw	s2,s2,-1
    3864:	fe0914e3          	bnez	s2,384c <reparent+0x1c>
  exit(0);
    3868:	4501                	li	a0,0
    386a:	3d6010ef          	jal	ra,4c40 <exit>
      printf("%s: fork failed\n", s);
    386e:	85ce                	mv	a1,s3
    3870:	00002517          	auipc	a0,0x2
    3874:	27850513          	addi	a0,a0,632 # 5ae8 <malloc+0x9ca>
    3878:	7ec010ef          	jal	ra,5064 <printf>
      exit(1);
    387c:	4505                	li	a0,1
    387e:	3c2010ef          	jal	ra,4c40 <exit>
        printf("%s: wait wrong pid\n", s);
    3882:	85ce                	mv	a1,s3
    3884:	00002517          	auipc	a0,0x2
    3888:	3ec50513          	addi	a0,a0,1004 # 5c70 <malloc+0xb52>
    388c:	7d8010ef          	jal	ra,5064 <printf>
        exit(1);
    3890:	4505                	li	a0,1
    3892:	3ae010ef          	jal	ra,4c40 <exit>
      int pid2 = fork();
    3896:	3a2010ef          	jal	ra,4c38 <fork>
      if(pid2 < 0){
    389a:	00054563          	bltz	a0,38a4 <reparent+0x74>
      exit(0);
    389e:	4501                	li	a0,0
    38a0:	3a0010ef          	jal	ra,4c40 <exit>
        kill(master_pid);
    38a4:	8552                	mv	a0,s4
    38a6:	3ca010ef          	jal	ra,4c70 <kill>
        exit(1);
    38aa:	4505                	li	a0,1
    38ac:	394010ef          	jal	ra,4c40 <exit>

00000000000038b0 <sbrkfail>:
{
    38b0:	7175                	addi	sp,sp,-144
    38b2:	e506                	sd	ra,136(sp)
    38b4:	e122                	sd	s0,128(sp)
    38b6:	fca6                	sd	s1,120(sp)
    38b8:	f8ca                	sd	s2,112(sp)
    38ba:	f4ce                	sd	s3,104(sp)
    38bc:	f0d2                	sd	s4,96(sp)
    38be:	ecd6                	sd	s5,88(sp)
    38c0:	e8da                	sd	s6,80(sp)
    38c2:	e4de                	sd	s7,72(sp)
    38c4:	0900                	addi	s0,sp,144
    38c6:	8b2a                	mv	s6,a0
  if(pipe(fds) != 0){
    38c8:	fa040513          	addi	a0,s0,-96
    38cc:	384010ef          	jal	ra,4c50 <pipe>
    38d0:	e919                	bnez	a0,38e6 <sbrkfail+0x36>
    38d2:	8aaa                	mv	s5,a0
    38d4:	f7040493          	addi	s1,s0,-144
    38d8:	f9840993          	addi	s3,s0,-104
    38dc:	8926                	mv	s2,s1
    if(pids[i] != -1) {
    38de:	5a7d                	li	s4,-1
      if(scratch == '0')
    38e0:	03000b93          	li	s7,48
    38e4:	a08d                	j	3946 <sbrkfail+0x96>
    printf("%s: pipe() failed\n", s);
    38e6:	85da                	mv	a1,s6
    38e8:	00002517          	auipc	a0,0x2
    38ec:	30850513          	addi	a0,a0,776 # 5bf0 <malloc+0xad2>
    38f0:	774010ef          	jal	ra,5064 <printf>
    exit(1);
    38f4:	4505                	li	a0,1
    38f6:	34a010ef          	jal	ra,4c40 <exit>
      if (sbrk(BIG - (uint64)sbrk(0)) ==  (char*)SBRK_ERROR)
    38fa:	312010ef          	jal	ra,4c0c <sbrk>
    38fe:	064007b7          	lui	a5,0x6400
    3902:	40a7853b          	subw	a0,a5,a0
    3906:	306010ef          	jal	ra,4c0c <sbrk>
    390a:	57fd                	li	a5,-1
    390c:	02f50063          	beq	a0,a5,392c <sbrkfail+0x7c>
        write(fds[1], "1", 1);
    3910:	4605                	li	a2,1
    3912:	00004597          	auipc	a1,0x4
    3916:	a9e58593          	addi	a1,a1,-1378 # 73b0 <malloc+0x2292>
    391a:	fa442503          	lw	a0,-92(s0)
    391e:	342010ef          	jal	ra,4c60 <write>
      for(;;) pause(1000);
    3922:	3e800513          	li	a0,1000
    3926:	3aa010ef          	jal	ra,4cd0 <pause>
    392a:	bfe5                	j	3922 <sbrkfail+0x72>
        write(fds[1], "0", 1);
    392c:	4605                	li	a2,1
    392e:	00003597          	auipc	a1,0x3
    3932:	41258593          	addi	a1,a1,1042 # 6d40 <malloc+0x1c22>
    3936:	fa442503          	lw	a0,-92(s0)
    393a:	326010ef          	jal	ra,4c60 <write>
    393e:	b7d5                	j	3922 <sbrkfail+0x72>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3940:	0911                	addi	s2,s2,4
    3942:	03390663          	beq	s2,s3,396e <sbrkfail+0xbe>
    if((pids[i] = fork()) == 0){
    3946:	2f2010ef          	jal	ra,4c38 <fork>
    394a:	00a92023          	sw	a0,0(s2)
    394e:	d555                	beqz	a0,38fa <sbrkfail+0x4a>
    if(pids[i] != -1) {
    3950:	ff4508e3          	beq	a0,s4,3940 <sbrkfail+0x90>
      read(fds[0], &scratch, 1);
    3954:	4605                	li	a2,1
    3956:	f9f40593          	addi	a1,s0,-97
    395a:	fa042503          	lw	a0,-96(s0)
    395e:	2fa010ef          	jal	ra,4c58 <read>
      if(scratch == '0')
    3962:	f9f44783          	lbu	a5,-97(s0)
    3966:	fd779de3          	bne	a5,s7,3940 <sbrkfail+0x90>
        failed = 1;
    396a:	4a85                	li	s5,1
    396c:	bfd1                	j	3940 <sbrkfail+0x90>
  if(!failed) {
    396e:	000a8863          	beqz	s5,397e <sbrkfail+0xce>
  c = sbrk(PGSIZE);
    3972:	6505                	lui	a0,0x1
    3974:	298010ef          	jal	ra,4c0c <sbrk>
    3978:	8a2a                	mv	s4,a0
    if(pids[i] == -1)
    397a:	597d                	li	s2,-1
    397c:	a821                	j	3994 <sbrkfail+0xe4>
    printf("%s: no allocation failed; allocate more?\n", s);
    397e:	85da                	mv	a1,s6
    3980:	00003517          	auipc	a0,0x3
    3984:	3c850513          	addi	a0,a0,968 # 6d48 <malloc+0x1c2a>
    3988:	6dc010ef          	jal	ra,5064 <printf>
    398c:	b7dd                	j	3972 <sbrkfail+0xc2>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    398e:	0491                	addi	s1,s1,4
    3990:	01348b63          	beq	s1,s3,39a6 <sbrkfail+0xf6>
    if(pids[i] == -1)
    3994:	4088                	lw	a0,0(s1)
    3996:	ff250ce3          	beq	a0,s2,398e <sbrkfail+0xde>
    kill(pids[i]);
    399a:	2d6010ef          	jal	ra,4c70 <kill>
    wait(0);
    399e:	4501                	li	a0,0
    39a0:	2a8010ef          	jal	ra,4c48 <wait>
    39a4:	b7ed                	j	398e <sbrkfail+0xde>
  if(c == (char*)SBRK_ERROR){
    39a6:	57fd                	li	a5,-1
    39a8:	02fa0a63          	beq	s4,a5,39dc <sbrkfail+0x12c>
  pid = fork();
    39ac:	28c010ef          	jal	ra,4c38 <fork>
  if(pid < 0){
    39b0:	04054063          	bltz	a0,39f0 <sbrkfail+0x140>
  if(pid == 0){
    39b4:	e939                	bnez	a0,3a0a <sbrkfail+0x15a>
    a = sbrk(10*BIG);
    39b6:	3e800537          	lui	a0,0x3e800
    39ba:	252010ef          	jal	ra,4c0c <sbrk>
    if(a == (char*)SBRK_ERROR){
    39be:	57fd                	li	a5,-1
    39c0:	04f50263          	beq	a0,a5,3a04 <sbrkfail+0x154>
    printf("%s: allocate a lot of memory succeeded %d\n", s, 10*BIG);
    39c4:	3e800637          	lui	a2,0x3e800
    39c8:	85da                	mv	a1,s6
    39ca:	00003517          	auipc	a0,0x3
    39ce:	3ce50513          	addi	a0,a0,974 # 6d98 <malloc+0x1c7a>
    39d2:	692010ef          	jal	ra,5064 <printf>
    exit(1);
    39d6:	4505                	li	a0,1
    39d8:	268010ef          	jal	ra,4c40 <exit>
    printf("%s: failed sbrk leaked memory\n", s);
    39dc:	85da                	mv	a1,s6
    39de:	00003517          	auipc	a0,0x3
    39e2:	39a50513          	addi	a0,a0,922 # 6d78 <malloc+0x1c5a>
    39e6:	67e010ef          	jal	ra,5064 <printf>
    exit(1);
    39ea:	4505                	li	a0,1
    39ec:	254010ef          	jal	ra,4c40 <exit>
    printf("%s: fork failed\n", s);
    39f0:	85da                	mv	a1,s6
    39f2:	00002517          	auipc	a0,0x2
    39f6:	0f650513          	addi	a0,a0,246 # 5ae8 <malloc+0x9ca>
    39fa:	66a010ef          	jal	ra,5064 <printf>
    exit(1);
    39fe:	4505                	li	a0,1
    3a00:	240010ef          	jal	ra,4c40 <exit>
      exit(0);
    3a04:	4501                	li	a0,0
    3a06:	23a010ef          	jal	ra,4c40 <exit>
  wait(&xstatus);
    3a0a:	fac40513          	addi	a0,s0,-84
    3a0e:	23a010ef          	jal	ra,4c48 <wait>
  if(xstatus != 0)
    3a12:	fac42783          	lw	a5,-84(s0)
    3a16:	ef81                	bnez	a5,3a2e <sbrkfail+0x17e>
}
    3a18:	60aa                	ld	ra,136(sp)
    3a1a:	640a                	ld	s0,128(sp)
    3a1c:	74e6                	ld	s1,120(sp)
    3a1e:	7946                	ld	s2,112(sp)
    3a20:	79a6                	ld	s3,104(sp)
    3a22:	7a06                	ld	s4,96(sp)
    3a24:	6ae6                	ld	s5,88(sp)
    3a26:	6b46                	ld	s6,80(sp)
    3a28:	6ba6                	ld	s7,72(sp)
    3a2a:	6149                	addi	sp,sp,144
    3a2c:	8082                	ret
    exit(1);
    3a2e:	4505                	li	a0,1
    3a30:	210010ef          	jal	ra,4c40 <exit>

0000000000003a34 <mem>:
{
    3a34:	7139                	addi	sp,sp,-64
    3a36:	fc06                	sd	ra,56(sp)
    3a38:	f822                	sd	s0,48(sp)
    3a3a:	f426                	sd	s1,40(sp)
    3a3c:	f04a                	sd	s2,32(sp)
    3a3e:	ec4e                	sd	s3,24(sp)
    3a40:	0080                	addi	s0,sp,64
    3a42:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    3a44:	1f4010ef          	jal	ra,4c38 <fork>
    m1 = 0;
    3a48:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    3a4a:	6909                	lui	s2,0x2
    3a4c:	71190913          	addi	s2,s2,1809 # 2711 <fourteen+0xe7>
  if((pid = fork()) == 0){
    3a50:	cd11                	beqz	a0,3a6c <mem+0x38>
    wait(&xstatus);
    3a52:	fcc40513          	addi	a0,s0,-52
    3a56:	1f2010ef          	jal	ra,4c48 <wait>
    if(xstatus == -1){
    3a5a:	fcc42503          	lw	a0,-52(s0)
    3a5e:	57fd                	li	a5,-1
    3a60:	04f50363          	beq	a0,a5,3aa6 <mem+0x72>
    exit(xstatus);
    3a64:	1dc010ef          	jal	ra,4c40 <exit>
      *(char**)m2 = m1;
    3a68:	e104                	sd	s1,0(a0)
      m1 = m2;
    3a6a:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    3a6c:	854a                	mv	a0,s2
    3a6e:	6b0010ef          	jal	ra,511e <malloc>
    3a72:	f97d                	bnez	a0,3a68 <mem+0x34>
    while(m1){
    3a74:	c491                	beqz	s1,3a80 <mem+0x4c>
      m2 = *(char**)m1;
    3a76:	8526                	mv	a0,s1
    3a78:	6084                	ld	s1,0(s1)
      free(m1);
    3a7a:	61c010ef          	jal	ra,5096 <free>
    while(m1){
    3a7e:	fce5                	bnez	s1,3a76 <mem+0x42>
    m1 = malloc(1024*20);
    3a80:	6515                	lui	a0,0x5
    3a82:	69c010ef          	jal	ra,511e <malloc>
    if(m1 == 0){
    3a86:	c511                	beqz	a0,3a92 <mem+0x5e>
    free(m1);
    3a88:	60e010ef          	jal	ra,5096 <free>
    exit(0);
    3a8c:	4501                	li	a0,0
    3a8e:	1b2010ef          	jal	ra,4c40 <exit>
      printf("%s: couldn't allocate mem?!!\n", s);
    3a92:	85ce                	mv	a1,s3
    3a94:	00003517          	auipc	a0,0x3
    3a98:	33450513          	addi	a0,a0,820 # 6dc8 <malloc+0x1caa>
    3a9c:	5c8010ef          	jal	ra,5064 <printf>
      exit(1);
    3aa0:	4505                	li	a0,1
    3aa2:	19e010ef          	jal	ra,4c40 <exit>
      exit(0);
    3aa6:	4501                	li	a0,0
    3aa8:	198010ef          	jal	ra,4c40 <exit>

0000000000003aac <sharedfd>:
{
    3aac:	7159                	addi	sp,sp,-112
    3aae:	f486                	sd	ra,104(sp)
    3ab0:	f0a2                	sd	s0,96(sp)
    3ab2:	eca6                	sd	s1,88(sp)
    3ab4:	e8ca                	sd	s2,80(sp)
    3ab6:	e4ce                	sd	s3,72(sp)
    3ab8:	e0d2                	sd	s4,64(sp)
    3aba:	fc56                	sd	s5,56(sp)
    3abc:	f85a                	sd	s6,48(sp)
    3abe:	f45e                	sd	s7,40(sp)
    3ac0:	1880                	addi	s0,sp,112
    3ac2:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    3ac4:	00003517          	auipc	a0,0x3
    3ac8:	32450513          	addi	a0,a0,804 # 6de8 <malloc+0x1cca>
    3acc:	1c4010ef          	jal	ra,4c90 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    3ad0:	20200593          	li	a1,514
    3ad4:	00003517          	auipc	a0,0x3
    3ad8:	31450513          	addi	a0,a0,788 # 6de8 <malloc+0x1cca>
    3adc:	1a4010ef          	jal	ra,4c80 <open>
  if(fd < 0){
    3ae0:	04054263          	bltz	a0,3b24 <sharedfd+0x78>
    3ae4:	892a                	mv	s2,a0
  pid = fork();
    3ae6:	152010ef          	jal	ra,4c38 <fork>
    3aea:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    3aec:	06300593          	li	a1,99
    3af0:	c119                	beqz	a0,3af6 <sharedfd+0x4a>
    3af2:	07000593          	li	a1,112
    3af6:	4629                	li	a2,10
    3af8:	fa040513          	addi	a0,s0,-96
    3afc:	731000ef          	jal	ra,4a2c <memset>
    3b00:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    3b04:	4629                	li	a2,10
    3b06:	fa040593          	addi	a1,s0,-96
    3b0a:	854a                	mv	a0,s2
    3b0c:	154010ef          	jal	ra,4c60 <write>
    3b10:	47a9                	li	a5,10
    3b12:	02f51363          	bne	a0,a5,3b38 <sharedfd+0x8c>
  for(i = 0; i < N; i++){
    3b16:	34fd                	addiw	s1,s1,-1
    3b18:	f4f5                	bnez	s1,3b04 <sharedfd+0x58>
  if(pid == 0) {
    3b1a:	02099963          	bnez	s3,3b4c <sharedfd+0xa0>
    exit(0);
    3b1e:	4501                	li	a0,0
    3b20:	120010ef          	jal	ra,4c40 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    3b24:	85d2                	mv	a1,s4
    3b26:	00003517          	auipc	a0,0x3
    3b2a:	2d250513          	addi	a0,a0,722 # 6df8 <malloc+0x1cda>
    3b2e:	536010ef          	jal	ra,5064 <printf>
    exit(1);
    3b32:	4505                	li	a0,1
    3b34:	10c010ef          	jal	ra,4c40 <exit>
      printf("%s: write sharedfd failed\n", s);
    3b38:	85d2                	mv	a1,s4
    3b3a:	00003517          	auipc	a0,0x3
    3b3e:	2e650513          	addi	a0,a0,742 # 6e20 <malloc+0x1d02>
    3b42:	522010ef          	jal	ra,5064 <printf>
      exit(1);
    3b46:	4505                	li	a0,1
    3b48:	0f8010ef          	jal	ra,4c40 <exit>
    wait(&xstatus);
    3b4c:	f9c40513          	addi	a0,s0,-100
    3b50:	0f8010ef          	jal	ra,4c48 <wait>
    if(xstatus != 0)
    3b54:	f9c42983          	lw	s3,-100(s0)
    3b58:	00098563          	beqz	s3,3b62 <sharedfd+0xb6>
      exit(xstatus);
    3b5c:	854e                	mv	a0,s3
    3b5e:	0e2010ef          	jal	ra,4c40 <exit>
  close(fd);
    3b62:	854a                	mv	a0,s2
    3b64:	104010ef          	jal	ra,4c68 <close>
  fd = open("sharedfd", 0);
    3b68:	4581                	li	a1,0
    3b6a:	00003517          	auipc	a0,0x3
    3b6e:	27e50513          	addi	a0,a0,638 # 6de8 <malloc+0x1cca>
    3b72:	10e010ef          	jal	ra,4c80 <open>
    3b76:	8baa                	mv	s7,a0
  nc = np = 0;
    3b78:	8ace                	mv	s5,s3
  if(fd < 0){
    3b7a:	02054363          	bltz	a0,3ba0 <sharedfd+0xf4>
    3b7e:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    3b82:	06300493          	li	s1,99
      if(buf[i] == 'p')
    3b86:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    3b8a:	4629                	li	a2,10
    3b8c:	fa040593          	addi	a1,s0,-96
    3b90:	855e                	mv	a0,s7
    3b92:	0c6010ef          	jal	ra,4c58 <read>
    3b96:	02a05b63          	blez	a0,3bcc <sharedfd+0x120>
    3b9a:	fa040793          	addi	a5,s0,-96
    3b9e:	a839                	j	3bbc <sharedfd+0x110>
    printf("%s: cannot open sharedfd for reading\n", s);
    3ba0:	85d2                	mv	a1,s4
    3ba2:	00003517          	auipc	a0,0x3
    3ba6:	29e50513          	addi	a0,a0,670 # 6e40 <malloc+0x1d22>
    3baa:	4ba010ef          	jal	ra,5064 <printf>
    exit(1);
    3bae:	4505                	li	a0,1
    3bb0:	090010ef          	jal	ra,4c40 <exit>
        nc++;
    3bb4:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    3bb6:	0785                	addi	a5,a5,1
    3bb8:	fd2789e3          	beq	a5,s2,3b8a <sharedfd+0xde>
      if(buf[i] == 'c')
    3bbc:	0007c703          	lbu	a4,0(a5) # 6400000 <base+0x63f1358>
    3bc0:	fe970ae3          	beq	a4,s1,3bb4 <sharedfd+0x108>
      if(buf[i] == 'p')
    3bc4:	ff6719e3          	bne	a4,s6,3bb6 <sharedfd+0x10a>
        np++;
    3bc8:	2a85                	addiw	s5,s5,1
    3bca:	b7f5                	j	3bb6 <sharedfd+0x10a>
  close(fd);
    3bcc:	855e                	mv	a0,s7
    3bce:	09a010ef          	jal	ra,4c68 <close>
  unlink("sharedfd");
    3bd2:	00003517          	auipc	a0,0x3
    3bd6:	21650513          	addi	a0,a0,534 # 6de8 <malloc+0x1cca>
    3bda:	0b6010ef          	jal	ra,4c90 <unlink>
  if(nc == N*SZ && np == N*SZ){
    3bde:	6789                	lui	a5,0x2
    3be0:	71078793          	addi	a5,a5,1808 # 2710 <fourteen+0xe6>
    3be4:	00f99763          	bne	s3,a5,3bf2 <sharedfd+0x146>
    3be8:	6789                	lui	a5,0x2
    3bea:	71078793          	addi	a5,a5,1808 # 2710 <fourteen+0xe6>
    3bee:	00fa8c63          	beq	s5,a5,3c06 <sharedfd+0x15a>
    printf("%s: nc/np test fails\n", s);
    3bf2:	85d2                	mv	a1,s4
    3bf4:	00003517          	auipc	a0,0x3
    3bf8:	27450513          	addi	a0,a0,628 # 6e68 <malloc+0x1d4a>
    3bfc:	468010ef          	jal	ra,5064 <printf>
    exit(1);
    3c00:	4505                	li	a0,1
    3c02:	03e010ef          	jal	ra,4c40 <exit>
    exit(0);
    3c06:	4501                	li	a0,0
    3c08:	038010ef          	jal	ra,4c40 <exit>

0000000000003c0c <fourfiles>:
{
    3c0c:	7171                	addi	sp,sp,-176
    3c0e:	f506                	sd	ra,168(sp)
    3c10:	f122                	sd	s0,160(sp)
    3c12:	ed26                	sd	s1,152(sp)
    3c14:	e94a                	sd	s2,144(sp)
    3c16:	e54e                	sd	s3,136(sp)
    3c18:	e152                	sd	s4,128(sp)
    3c1a:	fcd6                	sd	s5,120(sp)
    3c1c:	f8da                	sd	s6,112(sp)
    3c1e:	f4de                	sd	s7,104(sp)
    3c20:	f0e2                	sd	s8,96(sp)
    3c22:	ece6                	sd	s9,88(sp)
    3c24:	e8ea                	sd	s10,80(sp)
    3c26:	e4ee                	sd	s11,72(sp)
    3c28:	1900                	addi	s0,sp,176
    3c2a:	f4a43c23          	sd	a0,-168(s0)
  char *names[] = { "f0", "f1", "f2", "f3" };
    3c2e:	00001797          	auipc	a5,0x1
    3c32:	5d278793          	addi	a5,a5,1490 # 5200 <malloc+0xe2>
    3c36:	f6f43823          	sd	a5,-144(s0)
    3c3a:	00001797          	auipc	a5,0x1
    3c3e:	5ce78793          	addi	a5,a5,1486 # 5208 <malloc+0xea>
    3c42:	f6f43c23          	sd	a5,-136(s0)
    3c46:	00001797          	auipc	a5,0x1
    3c4a:	5ca78793          	addi	a5,a5,1482 # 5210 <malloc+0xf2>
    3c4e:	f8f43023          	sd	a5,-128(s0)
    3c52:	00001797          	auipc	a5,0x1
    3c56:	5c678793          	addi	a5,a5,1478 # 5218 <malloc+0xfa>
    3c5a:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    3c5e:	f7040c13          	addi	s8,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    3c62:	8962                	mv	s2,s8
  for(pi = 0; pi < NCHILD; pi++){
    3c64:	4481                	li	s1,0
    3c66:	4a11                	li	s4,4
    fname = names[pi];
    3c68:	00093983          	ld	s3,0(s2)
    unlink(fname);
    3c6c:	854e                	mv	a0,s3
    3c6e:	022010ef          	jal	ra,4c90 <unlink>
    pid = fork();
    3c72:	7c7000ef          	jal	ra,4c38 <fork>
    if(pid < 0){
    3c76:	04054263          	bltz	a0,3cba <fourfiles+0xae>
    if(pid == 0){
    3c7a:	c939                	beqz	a0,3cd0 <fourfiles+0xc4>
  for(pi = 0; pi < NCHILD; pi++){
    3c7c:	2485                	addiw	s1,s1,1
    3c7e:	0921                	addi	s2,s2,8
    3c80:	ff4494e3          	bne	s1,s4,3c68 <fourfiles+0x5c>
    3c84:	4491                	li	s1,4
    wait(&xstatus);
    3c86:	f6c40513          	addi	a0,s0,-148
    3c8a:	7bf000ef          	jal	ra,4c48 <wait>
    if(xstatus != 0)
    3c8e:	f6c42b03          	lw	s6,-148(s0)
    3c92:	0a0b1a63          	bnez	s6,3d46 <fourfiles+0x13a>
  for(pi = 0; pi < NCHILD; pi++){
    3c96:	34fd                	addiw	s1,s1,-1
    3c98:	f4fd                	bnez	s1,3c86 <fourfiles+0x7a>
    3c9a:	03000b93          	li	s7,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    3c9e:	00008a17          	auipc	s4,0x8
    3ca2:	00aa0a13          	addi	s4,s4,10 # bca8 <buf>
    3ca6:	00008a97          	auipc	s5,0x8
    3caa:	003a8a93          	addi	s5,s5,3 # bca9 <buf+0x1>
    if(total != N*SZ){
    3cae:	6d85                	lui	s11,0x1
    3cb0:	770d8d93          	addi	s11,s11,1904 # 1770 <forkfork+0x48>
  for(i = 0; i < NCHILD; i++){
    3cb4:	03400d13          	li	s10,52
    3cb8:	a8dd                	j	3dae <fourfiles+0x1a2>
      printf("%s: fork failed\n", s);
    3cba:	f5843583          	ld	a1,-168(s0)
    3cbe:	00002517          	auipc	a0,0x2
    3cc2:	e2a50513          	addi	a0,a0,-470 # 5ae8 <malloc+0x9ca>
    3cc6:	39e010ef          	jal	ra,5064 <printf>
      exit(1);
    3cca:	4505                	li	a0,1
    3ccc:	775000ef          	jal	ra,4c40 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    3cd0:	20200593          	li	a1,514
    3cd4:	854e                	mv	a0,s3
    3cd6:	7ab000ef          	jal	ra,4c80 <open>
    3cda:	892a                	mv	s2,a0
      if(fd < 0){
    3cdc:	04054163          	bltz	a0,3d1e <fourfiles+0x112>
      memset(buf, '0'+pi, SZ);
    3ce0:	1f400613          	li	a2,500
    3ce4:	0304859b          	addiw	a1,s1,48
    3ce8:	00008517          	auipc	a0,0x8
    3cec:	fc050513          	addi	a0,a0,-64 # bca8 <buf>
    3cf0:	53d000ef          	jal	ra,4a2c <memset>
    3cf4:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    3cf6:	00008997          	auipc	s3,0x8
    3cfa:	fb298993          	addi	s3,s3,-78 # bca8 <buf>
    3cfe:	1f400613          	li	a2,500
    3d02:	85ce                	mv	a1,s3
    3d04:	854a                	mv	a0,s2
    3d06:	75b000ef          	jal	ra,4c60 <write>
    3d0a:	85aa                	mv	a1,a0
    3d0c:	1f400793          	li	a5,500
    3d10:	02f51263          	bne	a0,a5,3d34 <fourfiles+0x128>
      for(i = 0; i < N; i++){
    3d14:	34fd                	addiw	s1,s1,-1
    3d16:	f4e5                	bnez	s1,3cfe <fourfiles+0xf2>
      exit(0);
    3d18:	4501                	li	a0,0
    3d1a:	727000ef          	jal	ra,4c40 <exit>
        printf("%s: create failed\n", s);
    3d1e:	f5843583          	ld	a1,-168(s0)
    3d22:	00002517          	auipc	a0,0x2
    3d26:	e5e50513          	addi	a0,a0,-418 # 5b80 <malloc+0xa62>
    3d2a:	33a010ef          	jal	ra,5064 <printf>
        exit(1);
    3d2e:	4505                	li	a0,1
    3d30:	711000ef          	jal	ra,4c40 <exit>
          printf("write failed %d\n", n);
    3d34:	00003517          	auipc	a0,0x3
    3d38:	14c50513          	addi	a0,a0,332 # 6e80 <malloc+0x1d62>
    3d3c:	328010ef          	jal	ra,5064 <printf>
          exit(1);
    3d40:	4505                	li	a0,1
    3d42:	6ff000ef          	jal	ra,4c40 <exit>
      exit(xstatus);
    3d46:	855a                	mv	a0,s6
    3d48:	6f9000ef          	jal	ra,4c40 <exit>
          printf("%s: wrong char\n", s);
    3d4c:	f5843583          	ld	a1,-168(s0)
    3d50:	00003517          	auipc	a0,0x3
    3d54:	14850513          	addi	a0,a0,328 # 6e98 <malloc+0x1d7a>
    3d58:	30c010ef          	jal	ra,5064 <printf>
          exit(1);
    3d5c:	4505                	li	a0,1
    3d5e:	6e3000ef          	jal	ra,4c40 <exit>
      total += n;
    3d62:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    3d66:	660d                	lui	a2,0x3
    3d68:	85d2                	mv	a1,s4
    3d6a:	854e                	mv	a0,s3
    3d6c:	6ed000ef          	jal	ra,4c58 <read>
    3d70:	02a05363          	blez	a0,3d96 <fourfiles+0x18a>
    3d74:	00008797          	auipc	a5,0x8
    3d78:	f3478793          	addi	a5,a5,-204 # bca8 <buf>
    3d7c:	fff5069b          	addiw	a3,a0,-1
    3d80:	1682                	slli	a3,a3,0x20
    3d82:	9281                	srli	a3,a3,0x20
    3d84:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    3d86:	0007c703          	lbu	a4,0(a5)
    3d8a:	fc9711e3          	bne	a4,s1,3d4c <fourfiles+0x140>
      for(j = 0; j < n; j++){
    3d8e:	0785                	addi	a5,a5,1
    3d90:	fed79be3          	bne	a5,a3,3d86 <fourfiles+0x17a>
    3d94:	b7f9                	j	3d62 <fourfiles+0x156>
    close(fd);
    3d96:	854e                	mv	a0,s3
    3d98:	6d1000ef          	jal	ra,4c68 <close>
    if(total != N*SZ){
    3d9c:	03b91463          	bne	s2,s11,3dc4 <fourfiles+0x1b8>
    unlink(fname);
    3da0:	8566                	mv	a0,s9
    3da2:	6ef000ef          	jal	ra,4c90 <unlink>
  for(i = 0; i < NCHILD; i++){
    3da6:	0c21                	addi	s8,s8,8
    3da8:	2b85                	addiw	s7,s7,1
    3daa:	03ab8763          	beq	s7,s10,3dd8 <fourfiles+0x1cc>
    fname = names[i];
    3dae:	000c3c83          	ld	s9,0(s8)
    fd = open(fname, 0);
    3db2:	4581                	li	a1,0
    3db4:	8566                	mv	a0,s9
    3db6:	6cb000ef          	jal	ra,4c80 <open>
    3dba:	89aa                	mv	s3,a0
    total = 0;
    3dbc:	895a                	mv	s2,s6
        if(buf[j] != '0'+i){
    3dbe:	000b849b          	sext.w	s1,s7
    while((n = read(fd, buf, sizeof(buf))) > 0){
    3dc2:	b755                	j	3d66 <fourfiles+0x15a>
      printf("wrong length %d\n", total);
    3dc4:	85ca                	mv	a1,s2
    3dc6:	00003517          	auipc	a0,0x3
    3dca:	0e250513          	addi	a0,a0,226 # 6ea8 <malloc+0x1d8a>
    3dce:	296010ef          	jal	ra,5064 <printf>
      exit(1);
    3dd2:	4505                	li	a0,1
    3dd4:	66d000ef          	jal	ra,4c40 <exit>
}
    3dd8:	70aa                	ld	ra,168(sp)
    3dda:	740a                	ld	s0,160(sp)
    3ddc:	64ea                	ld	s1,152(sp)
    3dde:	694a                	ld	s2,144(sp)
    3de0:	69aa                	ld	s3,136(sp)
    3de2:	6a0a                	ld	s4,128(sp)
    3de4:	7ae6                	ld	s5,120(sp)
    3de6:	7b46                	ld	s6,112(sp)
    3de8:	7ba6                	ld	s7,104(sp)
    3dea:	7c06                	ld	s8,96(sp)
    3dec:	6ce6                	ld	s9,88(sp)
    3dee:	6d46                	ld	s10,80(sp)
    3df0:	6da6                	ld	s11,72(sp)
    3df2:	614d                	addi	sp,sp,176
    3df4:	8082                	ret

0000000000003df6 <concreate>:
{
    3df6:	7135                	addi	sp,sp,-160
    3df8:	ed06                	sd	ra,152(sp)
    3dfa:	e922                	sd	s0,144(sp)
    3dfc:	e526                	sd	s1,136(sp)
    3dfe:	e14a                	sd	s2,128(sp)
    3e00:	fcce                	sd	s3,120(sp)
    3e02:	f8d2                	sd	s4,112(sp)
    3e04:	f4d6                	sd	s5,104(sp)
    3e06:	f0da                	sd	s6,96(sp)
    3e08:	ecde                	sd	s7,88(sp)
    3e0a:	1100                	addi	s0,sp,160
    3e0c:	89aa                	mv	s3,a0
  file[0] = 'C';
    3e0e:	04300793          	li	a5,67
    3e12:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    3e16:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    3e1a:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    3e1c:	4b0d                	li	s6,3
    3e1e:	4a85                	li	s5,1
      link("C0", file);
    3e20:	00003b97          	auipc	s7,0x3
    3e24:	0a0b8b93          	addi	s7,s7,160 # 6ec0 <malloc+0x1da2>
  for(i = 0; i < N; i++){
    3e28:	02800a13          	li	s4,40
    3e2c:	a415                	j	4050 <concreate+0x25a>
      link("C0", file);
    3e2e:	fa840593          	addi	a1,s0,-88
    3e32:	855e                	mv	a0,s7
    3e34:	66d000ef          	jal	ra,4ca0 <link>
    if(pid == 0) {
    3e38:	a409                	j	403a <concreate+0x244>
    } else if(pid == 0 && (i % 5) == 1){
    3e3a:	4795                	li	a5,5
    3e3c:	02f9693b          	remw	s2,s2,a5
    3e40:	4785                	li	a5,1
    3e42:	02f90563          	beq	s2,a5,3e6c <concreate+0x76>
      fd = open(file, O_CREATE | O_RDWR);
    3e46:	20200593          	li	a1,514
    3e4a:	fa840513          	addi	a0,s0,-88
    3e4e:	633000ef          	jal	ra,4c80 <open>
      if(fd < 0){
    3e52:	1c055f63          	bgez	a0,4030 <concreate+0x23a>
        printf("concreate create %s failed\n", file);
    3e56:	fa840593          	addi	a1,s0,-88
    3e5a:	00003517          	auipc	a0,0x3
    3e5e:	06e50513          	addi	a0,a0,110 # 6ec8 <malloc+0x1daa>
    3e62:	202010ef          	jal	ra,5064 <printf>
        exit(1);
    3e66:	4505                	li	a0,1
    3e68:	5d9000ef          	jal	ra,4c40 <exit>
      link("C0", file);
    3e6c:	fa840593          	addi	a1,s0,-88
    3e70:	00003517          	auipc	a0,0x3
    3e74:	05050513          	addi	a0,a0,80 # 6ec0 <malloc+0x1da2>
    3e78:	629000ef          	jal	ra,4ca0 <link>
      exit(0);
    3e7c:	4501                	li	a0,0
    3e7e:	5c3000ef          	jal	ra,4c40 <exit>
        exit(1);
    3e82:	4505                	li	a0,1
    3e84:	5bd000ef          	jal	ra,4c40 <exit>
  memset(fa, 0, sizeof(fa));
    3e88:	02800613          	li	a2,40
    3e8c:	4581                	li	a1,0
    3e8e:	f8040513          	addi	a0,s0,-128
    3e92:	39b000ef          	jal	ra,4a2c <memset>
  fd = open(".", 0);
    3e96:	4581                	li	a1,0
    3e98:	00002517          	auipc	a0,0x2
    3e9c:	aa850513          	addi	a0,a0,-1368 # 5940 <malloc+0x822>
    3ea0:	5e1000ef          	jal	ra,4c80 <open>
    3ea4:	892a                	mv	s2,a0
  n = 0;
    3ea6:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    3ea8:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    3eac:	02700b13          	li	s6,39
      fa[i] = 1;
    3eb0:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    3eb2:	4641                	li	a2,16
    3eb4:	f7040593          	addi	a1,s0,-144
    3eb8:	854a                	mv	a0,s2
    3eba:	59f000ef          	jal	ra,4c58 <read>
    3ebe:	06a05963          	blez	a0,3f30 <concreate+0x13a>
    if(de.inum == 0)
    3ec2:	f7045783          	lhu	a5,-144(s0)
    3ec6:	d7f5                	beqz	a5,3eb2 <concreate+0xbc>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    3ec8:	f7244783          	lbu	a5,-142(s0)
    3ecc:	ff4793e3          	bne	a5,s4,3eb2 <concreate+0xbc>
    3ed0:	f7444783          	lbu	a5,-140(s0)
    3ed4:	fff9                	bnez	a5,3eb2 <concreate+0xbc>
      i = de.name[1] - '0';
    3ed6:	f7344783          	lbu	a5,-141(s0)
    3eda:	fd07879b          	addiw	a5,a5,-48
    3ede:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    3ee2:	00eb6f63          	bltu	s6,a4,3f00 <concreate+0x10a>
      if(fa[i]){
    3ee6:	fb040793          	addi	a5,s0,-80
    3eea:	97ba                	add	a5,a5,a4
    3eec:	fd07c783          	lbu	a5,-48(a5)
    3ef0:	e785                	bnez	a5,3f18 <concreate+0x122>
      fa[i] = 1;
    3ef2:	fb040793          	addi	a5,s0,-80
    3ef6:	973e                	add	a4,a4,a5
    3ef8:	fd770823          	sb	s7,-48(a4)
      n++;
    3efc:	2a85                	addiw	s5,s5,1
    3efe:	bf55                	j	3eb2 <concreate+0xbc>
        printf("%s: concreate weird file %s\n", s, de.name);
    3f00:	f7240613          	addi	a2,s0,-142
    3f04:	85ce                	mv	a1,s3
    3f06:	00003517          	auipc	a0,0x3
    3f0a:	fe250513          	addi	a0,a0,-30 # 6ee8 <malloc+0x1dca>
    3f0e:	156010ef          	jal	ra,5064 <printf>
        exit(1);
    3f12:	4505                	li	a0,1
    3f14:	52d000ef          	jal	ra,4c40 <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    3f18:	f7240613          	addi	a2,s0,-142
    3f1c:	85ce                	mv	a1,s3
    3f1e:	00003517          	auipc	a0,0x3
    3f22:	fea50513          	addi	a0,a0,-22 # 6f08 <malloc+0x1dea>
    3f26:	13e010ef          	jal	ra,5064 <printf>
        exit(1);
    3f2a:	4505                	li	a0,1
    3f2c:	515000ef          	jal	ra,4c40 <exit>
  close(fd);
    3f30:	854a                	mv	a0,s2
    3f32:	537000ef          	jal	ra,4c68 <close>
  if(n != N){
    3f36:	02800793          	li	a5,40
    3f3a:	00fa9763          	bne	s5,a5,3f48 <concreate+0x152>
    if(((i % 3) == 0 && pid == 0) ||
    3f3e:	4a8d                	li	s5,3
    3f40:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    3f42:	02800a13          	li	s4,40
    3f46:	a079                	j	3fd4 <concreate+0x1de>
    printf("%s: concreate not enough files in directory listing\n", s);
    3f48:	85ce                	mv	a1,s3
    3f4a:	00003517          	auipc	a0,0x3
    3f4e:	fe650513          	addi	a0,a0,-26 # 6f30 <malloc+0x1e12>
    3f52:	112010ef          	jal	ra,5064 <printf>
    exit(1);
    3f56:	4505                	li	a0,1
    3f58:	4e9000ef          	jal	ra,4c40 <exit>
      printf("%s: fork failed\n", s);
    3f5c:	85ce                	mv	a1,s3
    3f5e:	00002517          	auipc	a0,0x2
    3f62:	b8a50513          	addi	a0,a0,-1142 # 5ae8 <malloc+0x9ca>
    3f66:	0fe010ef          	jal	ra,5064 <printf>
      exit(1);
    3f6a:	4505                	li	a0,1
    3f6c:	4d5000ef          	jal	ra,4c40 <exit>
      close(open(file, 0));
    3f70:	4581                	li	a1,0
    3f72:	fa840513          	addi	a0,s0,-88
    3f76:	50b000ef          	jal	ra,4c80 <open>
    3f7a:	4ef000ef          	jal	ra,4c68 <close>
      close(open(file, 0));
    3f7e:	4581                	li	a1,0
    3f80:	fa840513          	addi	a0,s0,-88
    3f84:	4fd000ef          	jal	ra,4c80 <open>
    3f88:	4e1000ef          	jal	ra,4c68 <close>
      close(open(file, 0));
    3f8c:	4581                	li	a1,0
    3f8e:	fa840513          	addi	a0,s0,-88
    3f92:	4ef000ef          	jal	ra,4c80 <open>
    3f96:	4d3000ef          	jal	ra,4c68 <close>
      close(open(file, 0));
    3f9a:	4581                	li	a1,0
    3f9c:	fa840513          	addi	a0,s0,-88
    3fa0:	4e1000ef          	jal	ra,4c80 <open>
    3fa4:	4c5000ef          	jal	ra,4c68 <close>
      close(open(file, 0));
    3fa8:	4581                	li	a1,0
    3faa:	fa840513          	addi	a0,s0,-88
    3fae:	4d3000ef          	jal	ra,4c80 <open>
    3fb2:	4b7000ef          	jal	ra,4c68 <close>
      close(open(file, 0));
    3fb6:	4581                	li	a1,0
    3fb8:	fa840513          	addi	a0,s0,-88
    3fbc:	4c5000ef          	jal	ra,4c80 <open>
    3fc0:	4a9000ef          	jal	ra,4c68 <close>
    if(pid == 0)
    3fc4:	06090363          	beqz	s2,402a <concreate+0x234>
      wait(0);
    3fc8:	4501                	li	a0,0
    3fca:	47f000ef          	jal	ra,4c48 <wait>
  for(i = 0; i < N; i++){
    3fce:	2485                	addiw	s1,s1,1
    3fd0:	0b448963          	beq	s1,s4,4082 <concreate+0x28c>
    file[1] = '0' + i;
    3fd4:	0304879b          	addiw	a5,s1,48
    3fd8:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    3fdc:	45d000ef          	jal	ra,4c38 <fork>
    3fe0:	892a                	mv	s2,a0
    if(pid < 0){
    3fe2:	f6054de3          	bltz	a0,3f5c <concreate+0x166>
    if(((i % 3) == 0 && pid == 0) ||
    3fe6:	0354e73b          	remw	a4,s1,s5
    3fea:	00a767b3          	or	a5,a4,a0
    3fee:	2781                	sext.w	a5,a5
    3ff0:	d3c1                	beqz	a5,3f70 <concreate+0x17a>
    3ff2:	01671363          	bne	a4,s6,3ff8 <concreate+0x202>
       ((i % 3) == 1 && pid != 0)){
    3ff6:	fd2d                	bnez	a0,3f70 <concreate+0x17a>
      unlink(file);
    3ff8:	fa840513          	addi	a0,s0,-88
    3ffc:	495000ef          	jal	ra,4c90 <unlink>
      unlink(file);
    4000:	fa840513          	addi	a0,s0,-88
    4004:	48d000ef          	jal	ra,4c90 <unlink>
      unlink(file);
    4008:	fa840513          	addi	a0,s0,-88
    400c:	485000ef          	jal	ra,4c90 <unlink>
      unlink(file);
    4010:	fa840513          	addi	a0,s0,-88
    4014:	47d000ef          	jal	ra,4c90 <unlink>
      unlink(file);
    4018:	fa840513          	addi	a0,s0,-88
    401c:	475000ef          	jal	ra,4c90 <unlink>
      unlink(file);
    4020:	fa840513          	addi	a0,s0,-88
    4024:	46d000ef          	jal	ra,4c90 <unlink>
    4028:	bf71                	j	3fc4 <concreate+0x1ce>
      exit(0);
    402a:	4501                	li	a0,0
    402c:	415000ef          	jal	ra,4c40 <exit>
      close(fd);
    4030:	439000ef          	jal	ra,4c68 <close>
    if(pid == 0) {
    4034:	b5a1                	j	3e7c <concreate+0x86>
      close(fd);
    4036:	433000ef          	jal	ra,4c68 <close>
      wait(&xstatus);
    403a:	f6c40513          	addi	a0,s0,-148
    403e:	40b000ef          	jal	ra,4c48 <wait>
      if(xstatus != 0)
    4042:	f6c42483          	lw	s1,-148(s0)
    4046:	e2049ee3          	bnez	s1,3e82 <concreate+0x8c>
  for(i = 0; i < N; i++){
    404a:	2905                	addiw	s2,s2,1
    404c:	e3490ee3          	beq	s2,s4,3e88 <concreate+0x92>
    file[1] = '0' + i;
    4050:	0309079b          	addiw	a5,s2,48
    4054:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    4058:	fa840513          	addi	a0,s0,-88
    405c:	435000ef          	jal	ra,4c90 <unlink>
    pid = fork();
    4060:	3d9000ef          	jal	ra,4c38 <fork>
    if(pid && (i % 3) == 1){
    4064:	dc050be3          	beqz	a0,3e3a <concreate+0x44>
    4068:	036967bb          	remw	a5,s2,s6
    406c:	dd5781e3          	beq	a5,s5,3e2e <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    4070:	20200593          	li	a1,514
    4074:	fa840513          	addi	a0,s0,-88
    4078:	409000ef          	jal	ra,4c80 <open>
      if(fd < 0){
    407c:	fa055de3          	bgez	a0,4036 <concreate+0x240>
    4080:	bbd9                	j	3e56 <concreate+0x60>
}
    4082:	60ea                	ld	ra,152(sp)
    4084:	644a                	ld	s0,144(sp)
    4086:	64aa                	ld	s1,136(sp)
    4088:	690a                	ld	s2,128(sp)
    408a:	79e6                	ld	s3,120(sp)
    408c:	7a46                	ld	s4,112(sp)
    408e:	7aa6                	ld	s5,104(sp)
    4090:	7b06                	ld	s6,96(sp)
    4092:	6be6                	ld	s7,88(sp)
    4094:	610d                	addi	sp,sp,160
    4096:	8082                	ret

0000000000004098 <bigfile>:
{
    4098:	7139                	addi	sp,sp,-64
    409a:	fc06                	sd	ra,56(sp)
    409c:	f822                	sd	s0,48(sp)
    409e:	f426                	sd	s1,40(sp)
    40a0:	f04a                	sd	s2,32(sp)
    40a2:	ec4e                	sd	s3,24(sp)
    40a4:	e852                	sd	s4,16(sp)
    40a6:	e456                	sd	s5,8(sp)
    40a8:	0080                	addi	s0,sp,64
    40aa:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    40ac:	00003517          	auipc	a0,0x3
    40b0:	ebc50513          	addi	a0,a0,-324 # 6f68 <malloc+0x1e4a>
    40b4:	3dd000ef          	jal	ra,4c90 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    40b8:	20200593          	li	a1,514
    40bc:	00003517          	auipc	a0,0x3
    40c0:	eac50513          	addi	a0,a0,-340 # 6f68 <malloc+0x1e4a>
    40c4:	3bd000ef          	jal	ra,4c80 <open>
    40c8:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    40ca:	4481                	li	s1,0
    memset(buf, i, SZ);
    40cc:	00008917          	auipc	s2,0x8
    40d0:	bdc90913          	addi	s2,s2,-1060 # bca8 <buf>
  for(i = 0; i < N; i++){
    40d4:	4a51                	li	s4,20
  if(fd < 0){
    40d6:	08054663          	bltz	a0,4162 <bigfile+0xca>
    memset(buf, i, SZ);
    40da:	25800613          	li	a2,600
    40de:	85a6                	mv	a1,s1
    40e0:	854a                	mv	a0,s2
    40e2:	14b000ef          	jal	ra,4a2c <memset>
    if(write(fd, buf, SZ) != SZ){
    40e6:	25800613          	li	a2,600
    40ea:	85ca                	mv	a1,s2
    40ec:	854e                	mv	a0,s3
    40ee:	373000ef          	jal	ra,4c60 <write>
    40f2:	25800793          	li	a5,600
    40f6:	08f51063          	bne	a0,a5,4176 <bigfile+0xde>
  for(i = 0; i < N; i++){
    40fa:	2485                	addiw	s1,s1,1
    40fc:	fd449fe3          	bne	s1,s4,40da <bigfile+0x42>
  close(fd);
    4100:	854e                	mv	a0,s3
    4102:	367000ef          	jal	ra,4c68 <close>
  fd = open("bigfile.dat", 0);
    4106:	4581                	li	a1,0
    4108:	00003517          	auipc	a0,0x3
    410c:	e6050513          	addi	a0,a0,-416 # 6f68 <malloc+0x1e4a>
    4110:	371000ef          	jal	ra,4c80 <open>
    4114:	8a2a                	mv	s4,a0
  total = 0;
    4116:	4981                	li	s3,0
  for(i = 0; ; i++){
    4118:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    411a:	00008917          	auipc	s2,0x8
    411e:	b8e90913          	addi	s2,s2,-1138 # bca8 <buf>
  if(fd < 0){
    4122:	06054463          	bltz	a0,418a <bigfile+0xf2>
    cc = read(fd, buf, SZ/2);
    4126:	12c00613          	li	a2,300
    412a:	85ca                	mv	a1,s2
    412c:	8552                	mv	a0,s4
    412e:	32b000ef          	jal	ra,4c58 <read>
    if(cc < 0){
    4132:	06054663          	bltz	a0,419e <bigfile+0x106>
    if(cc == 0)
    4136:	c155                	beqz	a0,41da <bigfile+0x142>
    if(cc != SZ/2){
    4138:	12c00793          	li	a5,300
    413c:	06f51b63          	bne	a0,a5,41b2 <bigfile+0x11a>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    4140:	01f4d79b          	srliw	a5,s1,0x1f
    4144:	9fa5                	addw	a5,a5,s1
    4146:	4017d79b          	sraiw	a5,a5,0x1
    414a:	00094703          	lbu	a4,0(s2)
    414e:	06f71c63          	bne	a4,a5,41c6 <bigfile+0x12e>
    4152:	12b94703          	lbu	a4,299(s2)
    4156:	06f71863          	bne	a4,a5,41c6 <bigfile+0x12e>
    total += cc;
    415a:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    415e:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    4160:	b7d9                	j	4126 <bigfile+0x8e>
    printf("%s: cannot create bigfile", s);
    4162:	85d6                	mv	a1,s5
    4164:	00003517          	auipc	a0,0x3
    4168:	e1450513          	addi	a0,a0,-492 # 6f78 <malloc+0x1e5a>
    416c:	6f9000ef          	jal	ra,5064 <printf>
    exit(1);
    4170:	4505                	li	a0,1
    4172:	2cf000ef          	jal	ra,4c40 <exit>
      printf("%s: write bigfile failed\n", s);
    4176:	85d6                	mv	a1,s5
    4178:	00003517          	auipc	a0,0x3
    417c:	e2050513          	addi	a0,a0,-480 # 6f98 <malloc+0x1e7a>
    4180:	6e5000ef          	jal	ra,5064 <printf>
      exit(1);
    4184:	4505                	li	a0,1
    4186:	2bb000ef          	jal	ra,4c40 <exit>
    printf("%s: cannot open bigfile\n", s);
    418a:	85d6                	mv	a1,s5
    418c:	00003517          	auipc	a0,0x3
    4190:	e2c50513          	addi	a0,a0,-468 # 6fb8 <malloc+0x1e9a>
    4194:	6d1000ef          	jal	ra,5064 <printf>
    exit(1);
    4198:	4505                	li	a0,1
    419a:	2a7000ef          	jal	ra,4c40 <exit>
      printf("%s: read bigfile failed\n", s);
    419e:	85d6                	mv	a1,s5
    41a0:	00003517          	auipc	a0,0x3
    41a4:	e3850513          	addi	a0,a0,-456 # 6fd8 <malloc+0x1eba>
    41a8:	6bd000ef          	jal	ra,5064 <printf>
      exit(1);
    41ac:	4505                	li	a0,1
    41ae:	293000ef          	jal	ra,4c40 <exit>
      printf("%s: short read bigfile\n", s);
    41b2:	85d6                	mv	a1,s5
    41b4:	00003517          	auipc	a0,0x3
    41b8:	e4450513          	addi	a0,a0,-444 # 6ff8 <malloc+0x1eda>
    41bc:	6a9000ef          	jal	ra,5064 <printf>
      exit(1);
    41c0:	4505                	li	a0,1
    41c2:	27f000ef          	jal	ra,4c40 <exit>
      printf("%s: read bigfile wrong data\n", s);
    41c6:	85d6                	mv	a1,s5
    41c8:	00003517          	auipc	a0,0x3
    41cc:	e4850513          	addi	a0,a0,-440 # 7010 <malloc+0x1ef2>
    41d0:	695000ef          	jal	ra,5064 <printf>
      exit(1);
    41d4:	4505                	li	a0,1
    41d6:	26b000ef          	jal	ra,4c40 <exit>
  close(fd);
    41da:	8552                	mv	a0,s4
    41dc:	28d000ef          	jal	ra,4c68 <close>
  if(total != N*SZ){
    41e0:	678d                	lui	a5,0x3
    41e2:	ee078793          	addi	a5,a5,-288 # 2ee0 <subdir+0x36e>
    41e6:	02f99163          	bne	s3,a5,4208 <bigfile+0x170>
  unlink("bigfile.dat");
    41ea:	00003517          	auipc	a0,0x3
    41ee:	d7e50513          	addi	a0,a0,-642 # 6f68 <malloc+0x1e4a>
    41f2:	29f000ef          	jal	ra,4c90 <unlink>
}
    41f6:	70e2                	ld	ra,56(sp)
    41f8:	7442                	ld	s0,48(sp)
    41fa:	74a2                	ld	s1,40(sp)
    41fc:	7902                	ld	s2,32(sp)
    41fe:	69e2                	ld	s3,24(sp)
    4200:	6a42                	ld	s4,16(sp)
    4202:	6aa2                	ld	s5,8(sp)
    4204:	6121                	addi	sp,sp,64
    4206:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    4208:	85d6                	mv	a1,s5
    420a:	00003517          	auipc	a0,0x3
    420e:	e2650513          	addi	a0,a0,-474 # 7030 <malloc+0x1f12>
    4212:	653000ef          	jal	ra,5064 <printf>
    exit(1);
    4216:	4505                	li	a0,1
    4218:	229000ef          	jal	ra,4c40 <exit>

000000000000421c <bigargtest>:
{
    421c:	7121                	addi	sp,sp,-448
    421e:	ff06                	sd	ra,440(sp)
    4220:	fb22                	sd	s0,432(sp)
    4222:	f726                	sd	s1,424(sp)
    4224:	0380                	addi	s0,sp,448
    4226:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    4228:	00003517          	auipc	a0,0x3
    422c:	e2850513          	addi	a0,a0,-472 # 7050 <malloc+0x1f32>
    4230:	261000ef          	jal	ra,4c90 <unlink>
  pid = fork();
    4234:	205000ef          	jal	ra,4c38 <fork>
  if(pid == 0){
    4238:	c915                	beqz	a0,426c <bigargtest+0x50>
  } else if(pid < 0){
    423a:	08054a63          	bltz	a0,42ce <bigargtest+0xb2>
  wait(&xstatus);
    423e:	fdc40513          	addi	a0,s0,-36
    4242:	207000ef          	jal	ra,4c48 <wait>
  if(xstatus != 0)
    4246:	fdc42503          	lw	a0,-36(s0)
    424a:	ed41                	bnez	a0,42e2 <bigargtest+0xc6>
  fd = open("bigarg-ok", 0);
    424c:	4581                	li	a1,0
    424e:	00003517          	auipc	a0,0x3
    4252:	e0250513          	addi	a0,a0,-510 # 7050 <malloc+0x1f32>
    4256:	22b000ef          	jal	ra,4c80 <open>
  if(fd < 0){
    425a:	08054663          	bltz	a0,42e6 <bigargtest+0xca>
  close(fd);
    425e:	20b000ef          	jal	ra,4c68 <close>
}
    4262:	70fa                	ld	ra,440(sp)
    4264:	745a                	ld	s0,432(sp)
    4266:	74ba                	ld	s1,424(sp)
    4268:	6139                	addi	sp,sp,448
    426a:	8082                	ret
    memset(big, ' ', sizeof(big));
    426c:	19000613          	li	a2,400
    4270:	02000593          	li	a1,32
    4274:	e4840513          	addi	a0,s0,-440
    4278:	7b4000ef          	jal	ra,4a2c <memset>
    big[sizeof(big)-1] = '\0';
    427c:	fc040ba3          	sb	zero,-41(s0)
    for(i = 0; i < MAXARG-1; i++)
    4280:	00004797          	auipc	a5,0x4
    4284:	21078793          	addi	a5,a5,528 # 8490 <args.1>
    4288:	00004697          	auipc	a3,0x4
    428c:	30068693          	addi	a3,a3,768 # 8588 <args.1+0xf8>
      args[i] = big;
    4290:	e4840713          	addi	a4,s0,-440
    4294:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    4296:	07a1                	addi	a5,a5,8
    4298:	fed79ee3          	bne	a5,a3,4294 <bigargtest+0x78>
    args[MAXARG-1] = 0;
    429c:	00004597          	auipc	a1,0x4
    42a0:	1f458593          	addi	a1,a1,500 # 8490 <args.1>
    42a4:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    42a8:	00001517          	auipc	a0,0x1
    42ac:	fb050513          	addi	a0,a0,-80 # 5258 <malloc+0x13a>
    42b0:	1c9000ef          	jal	ra,4c78 <exec>
    fd = open("bigarg-ok", O_CREATE);
    42b4:	20000593          	li	a1,512
    42b8:	00003517          	auipc	a0,0x3
    42bc:	d9850513          	addi	a0,a0,-616 # 7050 <malloc+0x1f32>
    42c0:	1c1000ef          	jal	ra,4c80 <open>
    close(fd);
    42c4:	1a5000ef          	jal	ra,4c68 <close>
    exit(0);
    42c8:	4501                	li	a0,0
    42ca:	177000ef          	jal	ra,4c40 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    42ce:	85a6                	mv	a1,s1
    42d0:	00003517          	auipc	a0,0x3
    42d4:	d9050513          	addi	a0,a0,-624 # 7060 <malloc+0x1f42>
    42d8:	58d000ef          	jal	ra,5064 <printf>
    exit(1);
    42dc:	4505                	li	a0,1
    42de:	163000ef          	jal	ra,4c40 <exit>
    exit(xstatus);
    42e2:	15f000ef          	jal	ra,4c40 <exit>
    printf("%s: bigarg test failed!\n", s);
    42e6:	85a6                	mv	a1,s1
    42e8:	00003517          	auipc	a0,0x3
    42ec:	d9850513          	addi	a0,a0,-616 # 7080 <malloc+0x1f62>
    42f0:	575000ef          	jal	ra,5064 <printf>
    exit(1);
    42f4:	4505                	li	a0,1
    42f6:	14b000ef          	jal	ra,4c40 <exit>

00000000000042fa <lazy_alloc>:
{
    42fa:	1141                	addi	sp,sp,-16
    42fc:	e406                	sd	ra,8(sp)
    42fe:	e022                	sd	s0,0(sp)
    4300:	0800                	addi	s0,sp,16
  prev_end = sbrklazy(REGION_SZ);
    4302:	40000537          	lui	a0,0x40000
    4306:	11d000ef          	jal	ra,4c22 <sbrklazy>
  if (prev_end == (char *) SBRK_ERROR) {
    430a:	57fd                	li	a5,-1
    430c:	02f50963          	beq	a0,a5,433e <lazy_alloc+0x44>
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE)
    4310:	6605                	lui	a2,0x1
    4312:	962a                	add	a2,a2,a0
    4314:	40001737          	lui	a4,0x40001
    4318:	972a                	add	a4,a4,a0
    431a:	87b2                	mv	a5,a2
    431c:	000406b7          	lui	a3,0x40
    *(char **)i = i;
    4320:	e39c                	sd	a5,0(a5)
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE)
    4322:	97b6                	add	a5,a5,a3
    4324:	fee79ee3          	bne	a5,a4,4320 <lazy_alloc+0x26>
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE) {
    4328:	000406b7          	lui	a3,0x40
    if (*(char **)i != i) {
    432c:	621c                	ld	a5,0(a2)
    432e:	02c79163          	bne	a5,a2,4350 <lazy_alloc+0x56>
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE) {
    4332:	9636                	add	a2,a2,a3
    4334:	fee61ce3          	bne	a2,a4,432c <lazy_alloc+0x32>
  exit(0);
    4338:	4501                	li	a0,0
    433a:	107000ef          	jal	ra,4c40 <exit>
    printf("sbrklazy() failed\n");
    433e:	00003517          	auipc	a0,0x3
    4342:	d6250513          	addi	a0,a0,-670 # 70a0 <malloc+0x1f82>
    4346:	51f000ef          	jal	ra,5064 <printf>
    exit(1);
    434a:	4505                	li	a0,1
    434c:	0f5000ef          	jal	ra,4c40 <exit>
      printf("failed to read value from memory\n");
    4350:	00003517          	auipc	a0,0x3
    4354:	d6850513          	addi	a0,a0,-664 # 70b8 <malloc+0x1f9a>
    4358:	50d000ef          	jal	ra,5064 <printf>
      exit(1);
    435c:	4505                	li	a0,1
    435e:	0e3000ef          	jal	ra,4c40 <exit>

0000000000004362 <lazy_unmap>:
{
    4362:	7139                	addi	sp,sp,-64
    4364:	fc06                	sd	ra,56(sp)
    4366:	f822                	sd	s0,48(sp)
    4368:	f426                	sd	s1,40(sp)
    436a:	f04a                	sd	s2,32(sp)
    436c:	ec4e                	sd	s3,24(sp)
    436e:	0080                	addi	s0,sp,64
  prev_end = sbrklazy(REGION_SZ);
    4370:	40000537          	lui	a0,0x40000
    4374:	0af000ef          	jal	ra,4c22 <sbrklazy>
  if (prev_end == (char*)SBRK_ERROR) {
    4378:	57fd                	li	a5,-1
    437a:	04f50263          	beq	a0,a5,43be <lazy_unmap+0x5c>
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE)
    437e:	6905                	lui	s2,0x1
    4380:	992a                	add	s2,s2,a0
    4382:	400014b7          	lui	s1,0x40001
    4386:	94aa                	add	s1,s1,a0
    4388:	87ca                	mv	a5,s2
    438a:	01000737          	lui	a4,0x1000
    *(char **)i = i;
    438e:	e39c                	sd	a5,0(a5)
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE)
    4390:	97ba                	add	a5,a5,a4
    4392:	fef49ee3          	bne	s1,a5,438e <lazy_unmap+0x2c>
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE) {
    4396:	010009b7          	lui	s3,0x1000
    pid = fork();
    439a:	09f000ef          	jal	ra,4c38 <fork>
    if (pid < 0) {
    439e:	02054963          	bltz	a0,43d0 <lazy_unmap+0x6e>
    } else if (pid == 0) {
    43a2:	c121                	beqz	a0,43e2 <lazy_unmap+0x80>
      wait(&status);
    43a4:	fcc40513          	addi	a0,s0,-52
    43a8:	0a1000ef          	jal	ra,4c48 <wait>
      if (status == 0) {
    43ac:	fcc42783          	lw	a5,-52(s0)
    43b0:	c3b1                	beqz	a5,43f4 <lazy_unmap+0x92>
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE) {
    43b2:	994e                	add	s2,s2,s3
    43b4:	ff2493e3          	bne	s1,s2,439a <lazy_unmap+0x38>
  exit(0);
    43b8:	4501                	li	a0,0
    43ba:	087000ef          	jal	ra,4c40 <exit>
    printf("sbrklazy() failed\n");
    43be:	00003517          	auipc	a0,0x3
    43c2:	ce250513          	addi	a0,a0,-798 # 70a0 <malloc+0x1f82>
    43c6:	49f000ef          	jal	ra,5064 <printf>
    exit(1);
    43ca:	4505                	li	a0,1
    43cc:	075000ef          	jal	ra,4c40 <exit>
      printf("error forking\n");
    43d0:	00003517          	auipc	a0,0x3
    43d4:	d1050513          	addi	a0,a0,-752 # 70e0 <malloc+0x1fc2>
    43d8:	48d000ef          	jal	ra,5064 <printf>
      exit(1);
    43dc:	4505                	li	a0,1
    43de:	063000ef          	jal	ra,4c40 <exit>
      sbrklazy(-1L * REGION_SZ);
    43e2:	c0000537          	lui	a0,0xc0000
    43e6:	03d000ef          	jal	ra,4c22 <sbrklazy>
      *(char **)i = i;
    43ea:	01293023          	sd	s2,0(s2) # 1000 <pgbug+0x2a>
      exit(0);
    43ee:	4501                	li	a0,0
    43f0:	051000ef          	jal	ra,4c40 <exit>
        printf("memory not unmapped\n");
    43f4:	00003517          	auipc	a0,0x3
    43f8:	cfc50513          	addi	a0,a0,-772 # 70f0 <malloc+0x1fd2>
    43fc:	469000ef          	jal	ra,5064 <printf>
        exit(1);
    4400:	4505                	li	a0,1
    4402:	03f000ef          	jal	ra,4c40 <exit>

0000000000004406 <lazy_copy>:
{
    4406:	7159                	addi	sp,sp,-112
    4408:	f486                	sd	ra,104(sp)
    440a:	f0a2                	sd	s0,96(sp)
    440c:	eca6                	sd	s1,88(sp)
    440e:	e8ca                	sd	s2,80(sp)
    4410:	e4ce                	sd	s3,72(sp)
    4412:	e0d2                	sd	s4,64(sp)
    4414:	fc56                	sd	s5,56(sp)
    4416:	f85a                	sd	s6,48(sp)
    4418:	1880                	addi	s0,sp,112
    char *p = sbrk(0);
    441a:	4501                	li	a0,0
    441c:	7f0000ef          	jal	ra,4c0c <sbrk>
    4420:	84aa                	mv	s1,a0
    sbrklazy(4*PGSIZE);
    4422:	6511                	lui	a0,0x4
    4424:	7fe000ef          	jal	ra,4c22 <sbrklazy>
    open(p + 8192, 0);
    4428:	4581                	li	a1,0
    442a:	6509                	lui	a0,0x2
    442c:	9526                	add	a0,a0,s1
    442e:	053000ef          	jal	ra,4c80 <open>
    void *xx = sbrk(0);
    4432:	4501                	li	a0,0
    4434:	7d8000ef          	jal	ra,4c0c <sbrk>
    4438:	84aa                	mv	s1,a0
    void *ret = sbrk(-(((uint64) xx)+1));
    443a:	fff54513          	not	a0,a0
    443e:	2501                	sext.w	a0,a0
    4440:	7cc000ef          	jal	ra,4c0c <sbrk>
    if(ret != xx){
    4444:	00a48c63          	beq	s1,a0,445c <lazy_copy+0x56>
    4448:	85aa                	mv	a1,a0
      printf("sbrk(sbrk(0)+1) returned %p, not old sz\n", ret);
    444a:	00003517          	auipc	a0,0x3
    444e:	cbe50513          	addi	a0,a0,-834 # 7108 <malloc+0x1fea>
    4452:	413000ef          	jal	ra,5064 <printf>
      exit(1);
    4456:	4505                	li	a0,1
    4458:	7e8000ef          	jal	ra,4c40 <exit>
  unsigned long bad[] = {
    445c:	00003797          	auipc	a5,0x3
    4460:	22478793          	addi	a5,a5,548 # 7680 <malloc+0x2562>
    4464:	7fa8                	ld	a0,120(a5)
    4466:	63cc                	ld	a1,128(a5)
    4468:	67d0                	ld	a2,136(a5)
    446a:	6bd4                	ld	a3,144(a5)
    446c:	6fd8                	ld	a4,152(a5)
    446e:	73dc                	ld	a5,160(a5)
    4470:	f8a43823          	sd	a0,-112(s0)
    4474:	f8b43c23          	sd	a1,-104(s0)
    4478:	fac43023          	sd	a2,-96(s0)
    447c:	fad43423          	sd	a3,-88(s0)
    4480:	fae43823          	sd	a4,-80(s0)
    4484:	faf43c23          	sd	a5,-72(s0)
  for(int i = 0; i < sizeof(bad)/sizeof(bad[0]); i++){
    4488:	f9040913          	addi	s2,s0,-112
    448c:	fc040b13          	addi	s6,s0,-64
    int fd = open("README", 0);
    4490:	00001a17          	auipc	s4,0x1
    4494:	fa0a0a13          	addi	s4,s4,-96 # 5430 <malloc+0x312>
    fd = open("junk", O_CREATE|O_RDWR|O_TRUNC);
    4498:	00001a97          	auipc	s5,0x1
    449c:	ea8a8a93          	addi	s5,s5,-344 # 5340 <malloc+0x222>
    int fd = open("README", 0);
    44a0:	4581                	li	a1,0
    44a2:	8552                	mv	a0,s4
    44a4:	7dc000ef          	jal	ra,4c80 <open>
    44a8:	84aa                	mv	s1,a0
    if(fd < 0) { printf("cannot open README\n"); exit(1); }
    44aa:	04054663          	bltz	a0,44f6 <lazy_copy+0xf0>
    if(read(fd, (char*)bad[i], 512) >= 0) { printf("read succeeded\n");  exit(1); }
    44ae:	00093983          	ld	s3,0(s2)
    44b2:	20000613          	li	a2,512
    44b6:	85ce                	mv	a1,s3
    44b8:	7a0000ef          	jal	ra,4c58 <read>
    44bc:	04055663          	bgez	a0,4508 <lazy_copy+0x102>
    close(fd);
    44c0:	8526                	mv	a0,s1
    44c2:	7a6000ef          	jal	ra,4c68 <close>
    fd = open("junk", O_CREATE|O_RDWR|O_TRUNC);
    44c6:	60200593          	li	a1,1538
    44ca:	8556                	mv	a0,s5
    44cc:	7b4000ef          	jal	ra,4c80 <open>
    44d0:	84aa                	mv	s1,a0
    if(fd < 0) { printf("cannot open junk\n"); exit(1); }
    44d2:	04054463          	bltz	a0,451a <lazy_copy+0x114>
    if(write(fd, (char*)bad[i], 512) >= 0) { printf("write succeeded\n"); exit(1); }
    44d6:	20000613          	li	a2,512
    44da:	85ce                	mv	a1,s3
    44dc:	784000ef          	jal	ra,4c60 <write>
    44e0:	04055663          	bgez	a0,452c <lazy_copy+0x126>
    close(fd);
    44e4:	8526                	mv	a0,s1
    44e6:	782000ef          	jal	ra,4c68 <close>
  for(int i = 0; i < sizeof(bad)/sizeof(bad[0]); i++){
    44ea:	0921                	addi	s2,s2,8
    44ec:	fb691ae3          	bne	s2,s6,44a0 <lazy_copy+0x9a>
  exit(0);
    44f0:	4501                	li	a0,0
    44f2:	74e000ef          	jal	ra,4c40 <exit>
    if(fd < 0) { printf("cannot open README\n"); exit(1); }
    44f6:	00003517          	auipc	a0,0x3
    44fa:	c4250513          	addi	a0,a0,-958 # 7138 <malloc+0x201a>
    44fe:	367000ef          	jal	ra,5064 <printf>
    4502:	4505                	li	a0,1
    4504:	73c000ef          	jal	ra,4c40 <exit>
    if(read(fd, (char*)bad[i], 512) >= 0) { printf("read succeeded\n");  exit(1); }
    4508:	00003517          	auipc	a0,0x3
    450c:	c4850513          	addi	a0,a0,-952 # 7150 <malloc+0x2032>
    4510:	355000ef          	jal	ra,5064 <printf>
    4514:	4505                	li	a0,1
    4516:	72a000ef          	jal	ra,4c40 <exit>
    if(fd < 0) { printf("cannot open junk\n"); exit(1); }
    451a:	00003517          	auipc	a0,0x3
    451e:	c4650513          	addi	a0,a0,-954 # 7160 <malloc+0x2042>
    4522:	343000ef          	jal	ra,5064 <printf>
    4526:	4505                	li	a0,1
    4528:	718000ef          	jal	ra,4c40 <exit>
    if(write(fd, (char*)bad[i], 512) >= 0) { printf("write succeeded\n"); exit(1); }
    452c:	00003517          	auipc	a0,0x3
    4530:	c4c50513          	addi	a0,a0,-948 # 7178 <malloc+0x205a>
    4534:	331000ef          	jal	ra,5064 <printf>
    4538:	4505                	li	a0,1
    453a:	706000ef          	jal	ra,4c40 <exit>

000000000000453e <fsfull>:
{
    453e:	7171                	addi	sp,sp,-176
    4540:	f506                	sd	ra,168(sp)
    4542:	f122                	sd	s0,160(sp)
    4544:	ed26                	sd	s1,152(sp)
    4546:	e94a                	sd	s2,144(sp)
    4548:	e54e                	sd	s3,136(sp)
    454a:	e152                	sd	s4,128(sp)
    454c:	fcd6                	sd	s5,120(sp)
    454e:	f8da                	sd	s6,112(sp)
    4550:	f4de                	sd	s7,104(sp)
    4552:	f0e2                	sd	s8,96(sp)
    4554:	ece6                	sd	s9,88(sp)
    4556:	e8ea                	sd	s10,80(sp)
    4558:	e4ee                	sd	s11,72(sp)
    455a:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    455c:	00003517          	auipc	a0,0x3
    4560:	c3450513          	addi	a0,a0,-972 # 7190 <malloc+0x2072>
    4564:	301000ef          	jal	ra,5064 <printf>
  for(nfiles = 0; ; nfiles++){
    4568:	4481                	li	s1,0
    name[0] = 'f';
    456a:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    456e:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4572:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    4576:	4b29                	li	s6,10
    printf("writing %s\n", name);
    4578:	00003c97          	auipc	s9,0x3
    457c:	c28c8c93          	addi	s9,s9,-984 # 71a0 <malloc+0x2082>
    int total = 0;
    4580:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    4582:	00007a17          	auipc	s4,0x7
    4586:	726a0a13          	addi	s4,s4,1830 # bca8 <buf>
    name[0] = 'f';
    458a:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    458e:	0384c7bb          	divw	a5,s1,s8
    4592:	0307879b          	addiw	a5,a5,48
    4596:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    459a:	0384e7bb          	remw	a5,s1,s8
    459e:	0377c7bb          	divw	a5,a5,s7
    45a2:	0307879b          	addiw	a5,a5,48
    45a6:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    45aa:	0374e7bb          	remw	a5,s1,s7
    45ae:	0367c7bb          	divw	a5,a5,s6
    45b2:	0307879b          	addiw	a5,a5,48
    45b6:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    45ba:	0364e7bb          	remw	a5,s1,s6
    45be:	0307879b          	addiw	a5,a5,48
    45c2:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    45c6:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    45ca:	f5040593          	addi	a1,s0,-176
    45ce:	8566                	mv	a0,s9
    45d0:	295000ef          	jal	ra,5064 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    45d4:	20200593          	li	a1,514
    45d8:	f5040513          	addi	a0,s0,-176
    45dc:	6a4000ef          	jal	ra,4c80 <open>
    45e0:	892a                	mv	s2,a0
    if(fd < 0){
    45e2:	0a055063          	bgez	a0,4682 <fsfull+0x144>
      printf("open %s failed\n", name);
    45e6:	f5040593          	addi	a1,s0,-176
    45ea:	00003517          	auipc	a0,0x3
    45ee:	bc650513          	addi	a0,a0,-1082 # 71b0 <malloc+0x2092>
    45f2:	273000ef          	jal	ra,5064 <printf>
  while(nfiles >= 0){
    45f6:	0604c163          	bltz	s1,4658 <fsfull+0x11a>
    name[0] = 'f';
    45fa:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    45fe:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4602:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    4606:	4929                	li	s2,10
  while(nfiles >= 0){
    4608:	5afd                	li	s5,-1
    name[0] = 'f';
    460a:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    460e:	0344c7bb          	divw	a5,s1,s4
    4612:	0307879b          	addiw	a5,a5,48
    4616:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    461a:	0344e7bb          	remw	a5,s1,s4
    461e:	0337c7bb          	divw	a5,a5,s3
    4622:	0307879b          	addiw	a5,a5,48
    4626:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    462a:	0334e7bb          	remw	a5,s1,s3
    462e:	0327c7bb          	divw	a5,a5,s2
    4632:	0307879b          	addiw	a5,a5,48
    4636:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    463a:	0324e7bb          	remw	a5,s1,s2
    463e:	0307879b          	addiw	a5,a5,48
    4642:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4646:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    464a:	f5040513          	addi	a0,s0,-176
    464e:	642000ef          	jal	ra,4c90 <unlink>
    nfiles--;
    4652:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    4654:	fb549be3          	bne	s1,s5,460a <fsfull+0xcc>
  printf("fsfull test finished\n");
    4658:	00003517          	auipc	a0,0x3
    465c:	b7850513          	addi	a0,a0,-1160 # 71d0 <malloc+0x20b2>
    4660:	205000ef          	jal	ra,5064 <printf>
}
    4664:	70aa                	ld	ra,168(sp)
    4666:	740a                	ld	s0,160(sp)
    4668:	64ea                	ld	s1,152(sp)
    466a:	694a                	ld	s2,144(sp)
    466c:	69aa                	ld	s3,136(sp)
    466e:	6a0a                	ld	s4,128(sp)
    4670:	7ae6                	ld	s5,120(sp)
    4672:	7b46                	ld	s6,112(sp)
    4674:	7ba6                	ld	s7,104(sp)
    4676:	7c06                	ld	s8,96(sp)
    4678:	6ce6                	ld	s9,88(sp)
    467a:	6d46                	ld	s10,80(sp)
    467c:	6da6                	ld	s11,72(sp)
    467e:	614d                	addi	sp,sp,176
    4680:	8082                	ret
    int total = 0;
    4682:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    4684:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    4688:	40000613          	li	a2,1024
    468c:	85d2                	mv	a1,s4
    468e:	854a                	mv	a0,s2
    4690:	5d0000ef          	jal	ra,4c60 <write>
      if(cc < BSIZE)
    4694:	00aad563          	bge	s5,a0,469e <fsfull+0x160>
      total += cc;
    4698:	00a989bb          	addw	s3,s3,a0
    while(1){
    469c:	b7f5                	j	4688 <fsfull+0x14a>
    printf("wrote %d bytes\n", total);
    469e:	85ce                	mv	a1,s3
    46a0:	00003517          	auipc	a0,0x3
    46a4:	b2050513          	addi	a0,a0,-1248 # 71c0 <malloc+0x20a2>
    46a8:	1bd000ef          	jal	ra,5064 <printf>
    close(fd);
    46ac:	854a                	mv	a0,s2
    46ae:	5ba000ef          	jal	ra,4c68 <close>
    if(total == 0)
    46b2:	f40982e3          	beqz	s3,45f6 <fsfull+0xb8>
  for(nfiles = 0; ; nfiles++){
    46b6:	2485                	addiw	s1,s1,1
    46b8:	bdc9                	j	458a <fsfull+0x4c>

00000000000046ba <run>:
//

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    46ba:	7179                	addi	sp,sp,-48
    46bc:	f406                	sd	ra,40(sp)
    46be:	f022                	sd	s0,32(sp)
    46c0:	ec26                	sd	s1,24(sp)
    46c2:	e84a                	sd	s2,16(sp)
    46c4:	1800                	addi	s0,sp,48
    46c6:	84aa                	mv	s1,a0
    46c8:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    46ca:	00003517          	auipc	a0,0x3
    46ce:	b1e50513          	addi	a0,a0,-1250 # 71e8 <malloc+0x20ca>
    46d2:	193000ef          	jal	ra,5064 <printf>
  if((pid = fork()) < 0) {
    46d6:	562000ef          	jal	ra,4c38 <fork>
    46da:	02054a63          	bltz	a0,470e <run+0x54>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    46de:	c129                	beqz	a0,4720 <run+0x66>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    46e0:	fdc40513          	addi	a0,s0,-36
    46e4:	564000ef          	jal	ra,4c48 <wait>
    if(xstatus != 0) 
    46e8:	fdc42783          	lw	a5,-36(s0)
    46ec:	cf9d                	beqz	a5,472a <run+0x70>
      printf("FAILED\n");
    46ee:	00003517          	auipc	a0,0x3
    46f2:	b2250513          	addi	a0,a0,-1246 # 7210 <malloc+0x20f2>
    46f6:	16f000ef          	jal	ra,5064 <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    46fa:	fdc42503          	lw	a0,-36(s0)
  }
}
    46fe:	00153513          	seqz	a0,a0
    4702:	70a2                	ld	ra,40(sp)
    4704:	7402                	ld	s0,32(sp)
    4706:	64e2                	ld	s1,24(sp)
    4708:	6942                	ld	s2,16(sp)
    470a:	6145                	addi	sp,sp,48
    470c:	8082                	ret
    printf("runtest: fork error\n");
    470e:	00003517          	auipc	a0,0x3
    4712:	aea50513          	addi	a0,a0,-1302 # 71f8 <malloc+0x20da>
    4716:	14f000ef          	jal	ra,5064 <printf>
    exit(1);
    471a:	4505                	li	a0,1
    471c:	524000ef          	jal	ra,4c40 <exit>
    f(s);
    4720:	854a                	mv	a0,s2
    4722:	9482                	jalr	s1
    exit(0);
    4724:	4501                	li	a0,0
    4726:	51a000ef          	jal	ra,4c40 <exit>
      printf("OK\n");
    472a:	00003517          	auipc	a0,0x3
    472e:	aee50513          	addi	a0,a0,-1298 # 7218 <malloc+0x20fa>
    4732:	133000ef          	jal	ra,5064 <printf>
    4736:	b7d1                	j	46fa <run+0x40>

0000000000004738 <runtests>:

int
runtests(struct test *tests, char *justone, int continuous) {
    4738:	7139                	addi	sp,sp,-64
    473a:	fc06                	sd	ra,56(sp)
    473c:	f822                	sd	s0,48(sp)
    473e:	f426                	sd	s1,40(sp)
    4740:	f04a                	sd	s2,32(sp)
    4742:	ec4e                	sd	s3,24(sp)
    4744:	e852                	sd	s4,16(sp)
    4746:	e456                	sd	s5,8(sp)
    4748:	0080                	addi	s0,sp,64
    474a:	84aa                	mv	s1,a0
  int ntests = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    474c:	6508                	ld	a0,8(a0)
    474e:	c921                	beqz	a0,479e <runtests+0x66>
    4750:	892e                	mv	s2,a1
    4752:	8a32                	mv	s4,a2
  int ntests = 0;
    4754:	4981                	li	s3,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      ntests++;
      if(!run(t->f, t->s)){
        if(continuous != 2){
    4756:	4a89                	li	s5,2
    4758:	a021                	j	4760 <runtests+0x28>
  for (struct test *t = tests; t->s != 0; t++) {
    475a:	04c1                	addi	s1,s1,16
    475c:	6488                	ld	a0,8(s1)
    475e:	c515                	beqz	a0,478a <runtests+0x52>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    4760:	00090663          	beqz	s2,476c <runtests+0x34>
    4764:	85ca                	mv	a1,s2
    4766:	270000ef          	jal	ra,49d6 <strcmp>
    476a:	f965                	bnez	a0,475a <runtests+0x22>
      ntests++;
    476c:	2985                	addiw	s3,s3,1
      if(!run(t->f, t->s)){
    476e:	648c                	ld	a1,8(s1)
    4770:	6088                	ld	a0,0(s1)
    4772:	f49ff0ef          	jal	ra,46ba <run>
    4776:	f175                	bnez	a0,475a <runtests+0x22>
        if(continuous != 2){
    4778:	ff5a01e3          	beq	s4,s5,475a <runtests+0x22>
          printf("SOME TESTS FAILED\n");
    477c:	00003517          	auipc	a0,0x3
    4780:	aa450513          	addi	a0,a0,-1372 # 7220 <malloc+0x2102>
    4784:	0e1000ef          	jal	ra,5064 <printf>
          return -1;
    4788:	59fd                	li	s3,-1
        }
      }
    }
  }
  return ntests;
}
    478a:	854e                	mv	a0,s3
    478c:	70e2                	ld	ra,56(sp)
    478e:	7442                	ld	s0,48(sp)
    4790:	74a2                	ld	s1,40(sp)
    4792:	7902                	ld	s2,32(sp)
    4794:	69e2                	ld	s3,24(sp)
    4796:	6a42                	ld	s4,16(sp)
    4798:	6aa2                	ld	s5,8(sp)
    479a:	6121                	addi	sp,sp,64
    479c:	8082                	ret
  int ntests = 0;
    479e:	4981                	li	s3,0
    47a0:	b7ed                	j	478a <runtests+0x52>

00000000000047a2 <countfree>:


// use sbrk() to count how many free physical memory pages there are.
int
countfree()
{
    47a2:	7179                	addi	sp,sp,-48
    47a4:	f406                	sd	ra,40(sp)
    47a6:	f022                	sd	s0,32(sp)
    47a8:	ec26                	sd	s1,24(sp)
    47aa:	e84a                	sd	s2,16(sp)
    47ac:	e44e                	sd	s3,8(sp)
    47ae:	1800                	addi	s0,sp,48
  int n = 0;
  uint64 sz0 = (uint64)sbrk(0);
    47b0:	4501                	li	a0,0
    47b2:	45a000ef          	jal	ra,4c0c <sbrk>
    47b6:	89aa                	mv	s3,a0
  int n = 0;
    47b8:	4481                	li	s1,0
  while(1){
    char *a = sbrk(PGSIZE);
    if(a == SBRK_ERROR){
    47ba:	597d                	li	s2,-1
    47bc:	a011                	j	47c0 <countfree+0x1e>
      break;
    }
    n += 1;
    47be:	2485                	addiw	s1,s1,1
    char *a = sbrk(PGSIZE);
    47c0:	6505                	lui	a0,0x1
    47c2:	44a000ef          	jal	ra,4c0c <sbrk>
    if(a == SBRK_ERROR){
    47c6:	ff251ce3          	bne	a0,s2,47be <countfree+0x1c>
  }
  sbrk(-((uint64)sbrk(0) - sz0));  
    47ca:	4501                	li	a0,0
    47cc:	440000ef          	jal	ra,4c0c <sbrk>
    47d0:	40a9853b          	subw	a0,s3,a0
    47d4:	438000ef          	jal	ra,4c0c <sbrk>
  return n;
}
    47d8:	8526                	mv	a0,s1
    47da:	70a2                	ld	ra,40(sp)
    47dc:	7402                	ld	s0,32(sp)
    47de:	64e2                	ld	s1,24(sp)
    47e0:	6942                	ld	s2,16(sp)
    47e2:	69a2                	ld	s3,8(sp)
    47e4:	6145                	addi	sp,sp,48
    47e6:	8082                	ret

00000000000047e8 <drivetests>:

int
drivetests(int quick, int continuous, char *justone) {
    47e8:	7159                	addi	sp,sp,-112
    47ea:	f486                	sd	ra,104(sp)
    47ec:	f0a2                	sd	s0,96(sp)
    47ee:	eca6                	sd	s1,88(sp)
    47f0:	e8ca                	sd	s2,80(sp)
    47f2:	e4ce                	sd	s3,72(sp)
    47f4:	e0d2                	sd	s4,64(sp)
    47f6:	fc56                	sd	s5,56(sp)
    47f8:	f85a                	sd	s6,48(sp)
    47fa:	f45e                	sd	s7,40(sp)
    47fc:	f062                	sd	s8,32(sp)
    47fe:	ec66                	sd	s9,24(sp)
    4800:	e86a                	sd	s10,16(sp)
    4802:	e46e                	sd	s11,8(sp)
    4804:	1880                	addi	s0,sp,112
    4806:	8aaa                	mv	s5,a0
    4808:	89ae                	mv	s3,a1
    480a:	8a32                	mv	s4,a2
  do {
    printf("usertests starting\n");
    480c:	00003b97          	auipc	s7,0x3
    4810:	a2cb8b93          	addi	s7,s7,-1492 # 7238 <malloc+0x211a>
    int free0 = countfree();
    int free1 = 0;
    int ntests = 0;
    int n;
    n = runtests(quicktests, justone, continuous);
    4814:	00003b17          	auipc	s6,0x3
    4818:	7fcb0b13          	addi	s6,s6,2044 # 8010 <quicktests>
    if (n < 0) {
      if(continuous != 2) {
    481c:	4c09                	li	s8,2
      } else {
        ntests += n;
      }
    }
    if((free1 = countfree()) < free0) {
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    481e:	00003d17          	auipc	s10,0x3
    4822:	a52d0d13          	addi	s10,s10,-1454 # 7270 <malloc+0x2152>
      n = runtests(slowtests, justone, continuous);
    4826:	00004c97          	auipc	s9,0x4
    482a:	beac8c93          	addi	s9,s9,-1046 # 8410 <slowtests>
        printf("usertests slow tests starting\n");
    482e:	00003d97          	auipc	s11,0x3
    4832:	a22d8d93          	addi	s11,s11,-1502 # 7250 <malloc+0x2132>
    4836:	a835                	j	4872 <drivetests+0x8a>
      if(continuous != 2) {
    4838:	09899a63          	bne	s3,s8,48cc <drivetests+0xe4>
    int ntests = 0;
    483c:	4481                	li	s1,0
    483e:	a881                	j	488e <drivetests+0xa6>
        printf("usertests slow tests starting\n");
    4840:	856e                	mv	a0,s11
    4842:	023000ef          	jal	ra,5064 <printf>
    4846:	a881                	j	4896 <drivetests+0xae>
        if(continuous != 2) {
    4848:	09899463          	bne	s3,s8,48d0 <drivetests+0xe8>
    if((free1 = countfree()) < free0) {
    484c:	f57ff0ef          	jal	ra,47a2 <countfree>
    4850:	01255c63          	bge	a0,s2,4868 <drivetests+0x80>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    4854:	864a                	mv	a2,s2
    4856:	85aa                	mv	a1,a0
    4858:	856a                	mv	a0,s10
    485a:	00b000ef          	jal	ra,5064 <printf>
      if(continuous != 2) {
    485e:	a8a1                	j	48b6 <drivetests+0xce>
    if((free1 = countfree()) < free0) {
    4860:	f43ff0ef          	jal	ra,47a2 <countfree>
    4864:	05254263          	blt	a0,s2,48a8 <drivetests+0xc0>
        return 1;
      }
    }
    if (justone != 0 && ntests == 0) {
    4868:	000a0363          	beqz	s4,486e <drivetests+0x86>
    486c:	c8a1                	beqz	s1,48bc <drivetests+0xd4>
      printf("NO TESTS EXECUTED\n");
      return 1;
    }
  } while(continuous);
    486e:	06098563          	beqz	s3,48d8 <drivetests+0xf0>
    printf("usertests starting\n");
    4872:	855e                	mv	a0,s7
    4874:	7f0000ef          	jal	ra,5064 <printf>
    int free0 = countfree();
    4878:	f2bff0ef          	jal	ra,47a2 <countfree>
    487c:	892a                	mv	s2,a0
    n = runtests(quicktests, justone, continuous);
    487e:	864e                	mv	a2,s3
    4880:	85d2                	mv	a1,s4
    4882:	855a                	mv	a0,s6
    4884:	eb5ff0ef          	jal	ra,4738 <runtests>
    4888:	84aa                	mv	s1,a0
    if (n < 0) {
    488a:	fa0547e3          	bltz	a0,4838 <drivetests+0x50>
    if(!quick) {
    488e:	fc0a99e3          	bnez	s5,4860 <drivetests+0x78>
      if (justone == 0)
    4892:	fa0a07e3          	beqz	s4,4840 <drivetests+0x58>
      n = runtests(slowtests, justone, continuous);
    4896:	864e                	mv	a2,s3
    4898:	85d2                	mv	a1,s4
    489a:	8566                	mv	a0,s9
    489c:	e9dff0ef          	jal	ra,4738 <runtests>
      if (n < 0) {
    48a0:	fa0544e3          	bltz	a0,4848 <drivetests+0x60>
        ntests += n;
    48a4:	9ca9                	addw	s1,s1,a0
    48a6:	bf6d                	j	4860 <drivetests+0x78>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    48a8:	864a                	mv	a2,s2
    48aa:	85aa                	mv	a1,a0
    48ac:	856a                	mv	a0,s10
    48ae:	7b6000ef          	jal	ra,5064 <printf>
      if(continuous != 2) {
    48b2:	03899163          	bne	s3,s8,48d4 <drivetests+0xec>
    if (justone != 0 && ntests == 0) {
    48b6:	fa0a0ee3          	beqz	s4,4872 <drivetests+0x8a>
    48ba:	fcc5                	bnez	s1,4872 <drivetests+0x8a>
      printf("NO TESTS EXECUTED\n");
    48bc:	00003517          	auipc	a0,0x3
    48c0:	9e450513          	addi	a0,a0,-1564 # 72a0 <malloc+0x2182>
    48c4:	7a0000ef          	jal	ra,5064 <printf>
      return 1;
    48c8:	4505                	li	a0,1
    48ca:	a801                	j	48da <drivetests+0xf2>
        return 1;
    48cc:	4505                	li	a0,1
    48ce:	a031                	j	48da <drivetests+0xf2>
          return 1;
    48d0:	4505                	li	a0,1
    48d2:	a021                	j	48da <drivetests+0xf2>
        return 1;
    48d4:	4505                	li	a0,1
    48d6:	a011                	j	48da <drivetests+0xf2>
  return 0;
    48d8:	854e                	mv	a0,s3
}
    48da:	70a6                	ld	ra,104(sp)
    48dc:	7406                	ld	s0,96(sp)
    48de:	64e6                	ld	s1,88(sp)
    48e0:	6946                	ld	s2,80(sp)
    48e2:	69a6                	ld	s3,72(sp)
    48e4:	6a06                	ld	s4,64(sp)
    48e6:	7ae2                	ld	s5,56(sp)
    48e8:	7b42                	ld	s6,48(sp)
    48ea:	7ba2                	ld	s7,40(sp)
    48ec:	7c02                	ld	s8,32(sp)
    48ee:	6ce2                	ld	s9,24(sp)
    48f0:	6d42                	ld	s10,16(sp)
    48f2:	6da2                	ld	s11,8(sp)
    48f4:	6165                	addi	sp,sp,112
    48f6:	8082                	ret

00000000000048f8 <main>:

int
main(int argc, char *argv[])
{
    48f8:	1101                	addi	sp,sp,-32
    48fa:	ec06                	sd	ra,24(sp)
    48fc:	e822                	sd	s0,16(sp)
    48fe:	e426                	sd	s1,8(sp)
    4900:	e04a                	sd	s2,0(sp)
    4902:	1000                	addi	s0,sp,32
    4904:	84aa                	mv	s1,a0
  int continuous = 0;
  int quick = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    4906:	4789                	li	a5,2
    4908:	00f50f63          	beq	a0,a5,4926 <main+0x2e>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    490c:	4785                	li	a5,1
    490e:	06a7c363          	blt	a5,a0,4974 <main+0x7c>
  char *justone = 0;
    4912:	4601                	li	a2,0
  int quick = 0;
    4914:	4501                	li	a0,0
  int continuous = 0;
    4916:	4481                	li	s1,0
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    exit(1);
  }
  if (drivetests(quick, continuous, justone)) {
    4918:	85a6                	mv	a1,s1
    491a:	ecfff0ef          	jal	ra,47e8 <drivetests>
    491e:	cd2d                	beqz	a0,4998 <main+0xa0>
    exit(1);
    4920:	4505                	li	a0,1
    4922:	31e000ef          	jal	ra,4c40 <exit>
    4926:	892e                	mv	s2,a1
  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    4928:	00003597          	auipc	a1,0x3
    492c:	99058593          	addi	a1,a1,-1648 # 72b8 <malloc+0x219a>
    4930:	00893503          	ld	a0,8(s2)
    4934:	0a2000ef          	jal	ra,49d6 <strcmp>
    4938:	c539                	beqz	a0,4986 <main+0x8e>
  } else if(argc == 2 && strcmp(argv[1], "-c") == 0){
    493a:	00003597          	auipc	a1,0x3
    493e:	9d658593          	addi	a1,a1,-1578 # 7310 <malloc+0x21f2>
    4942:	00893503          	ld	a0,8(s2)
    4946:	090000ef          	jal	ra,49d6 <strcmp>
    494a:	c521                	beqz	a0,4992 <main+0x9a>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    494c:	00003597          	auipc	a1,0x3
    4950:	9bc58593          	addi	a1,a1,-1604 # 7308 <malloc+0x21ea>
    4954:	00893503          	ld	a0,8(s2)
    4958:	07e000ef          	jal	ra,49d6 <strcmp>
    495c:	c90d                	beqz	a0,498e <main+0x96>
  } else if(argc == 2 && argv[1][0] != '-'){
    495e:	00893603          	ld	a2,8(s2)
    4962:	00064703          	lbu	a4,0(a2) # 1000 <pgbug+0x2a>
    4966:	02d00793          	li	a5,45
    496a:	00f70563          	beq	a4,a5,4974 <main+0x7c>
  int quick = 0;
    496e:	4501                	li	a0,0
  int continuous = 0;
    4970:	4481                	li	s1,0
    4972:	b75d                	j	4918 <main+0x20>
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    4974:	00003517          	auipc	a0,0x3
    4978:	94c50513          	addi	a0,a0,-1716 # 72c0 <malloc+0x21a2>
    497c:	6e8000ef          	jal	ra,5064 <printf>
    exit(1);
    4980:	4505                	li	a0,1
    4982:	2be000ef          	jal	ra,4c40 <exit>
  int continuous = 0;
    4986:	84aa                	mv	s1,a0
  char *justone = 0;
    4988:	4601                	li	a2,0
    quick = 1;
    498a:	4505                	li	a0,1
    498c:	b771                	j	4918 <main+0x20>
  char *justone = 0;
    498e:	4601                	li	a2,0
    4990:	b761                	j	4918 <main+0x20>
    4992:	4601                	li	a2,0
    continuous = 1;
    4994:	4485                	li	s1,1
    4996:	b749                	j	4918 <main+0x20>
  }
  printf("ALL TESTS PASSED\n");
    4998:	00003517          	auipc	a0,0x3
    499c:	95850513          	addi	a0,a0,-1704 # 72f0 <malloc+0x21d2>
    49a0:	6c4000ef          	jal	ra,5064 <printf>
  exit(0);
    49a4:	4501                	li	a0,0
    49a6:	29a000ef          	jal	ra,4c40 <exit>

00000000000049aa <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
    49aa:	1141                	addi	sp,sp,-16
    49ac:	e406                	sd	ra,8(sp)
    49ae:	e022                	sd	s0,0(sp)
    49b0:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
    49b2:	f47ff0ef          	jal	ra,48f8 <main>
  exit(r);
    49b6:	28a000ef          	jal	ra,4c40 <exit>

00000000000049ba <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
    49ba:	1141                	addi	sp,sp,-16
    49bc:	e422                	sd	s0,8(sp)
    49be:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    49c0:	87aa                	mv	a5,a0
    49c2:	0585                	addi	a1,a1,1
    49c4:	0785                	addi	a5,a5,1
    49c6:	fff5c703          	lbu	a4,-1(a1)
    49ca:	fee78fa3          	sb	a4,-1(a5)
    49ce:	fb75                	bnez	a4,49c2 <strcpy+0x8>
    ;
  return os;
}
    49d0:	6422                	ld	s0,8(sp)
    49d2:	0141                	addi	sp,sp,16
    49d4:	8082                	ret

00000000000049d6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    49d6:	1141                	addi	sp,sp,-16
    49d8:	e422                	sd	s0,8(sp)
    49da:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    49dc:	00054783          	lbu	a5,0(a0)
    49e0:	cb91                	beqz	a5,49f4 <strcmp+0x1e>
    49e2:	0005c703          	lbu	a4,0(a1)
    49e6:	00f71763          	bne	a4,a5,49f4 <strcmp+0x1e>
    p++, q++;
    49ea:	0505                	addi	a0,a0,1
    49ec:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    49ee:	00054783          	lbu	a5,0(a0)
    49f2:	fbe5                	bnez	a5,49e2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    49f4:	0005c503          	lbu	a0,0(a1)
}
    49f8:	40a7853b          	subw	a0,a5,a0
    49fc:	6422                	ld	s0,8(sp)
    49fe:	0141                	addi	sp,sp,16
    4a00:	8082                	ret

0000000000004a02 <strlen>:

uint
strlen(const char *s)
{
    4a02:	1141                	addi	sp,sp,-16
    4a04:	e422                	sd	s0,8(sp)
    4a06:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    4a08:	00054783          	lbu	a5,0(a0)
    4a0c:	cf91                	beqz	a5,4a28 <strlen+0x26>
    4a0e:	0505                	addi	a0,a0,1
    4a10:	87aa                	mv	a5,a0
    4a12:	4685                	li	a3,1
    4a14:	9e89                	subw	a3,a3,a0
    4a16:	00f6853b          	addw	a0,a3,a5
    4a1a:	0785                	addi	a5,a5,1
    4a1c:	fff7c703          	lbu	a4,-1(a5)
    4a20:	fb7d                	bnez	a4,4a16 <strlen+0x14>
    ;
  return n;
}
    4a22:	6422                	ld	s0,8(sp)
    4a24:	0141                	addi	sp,sp,16
    4a26:	8082                	ret
  for(n = 0; s[n]; n++)
    4a28:	4501                	li	a0,0
    4a2a:	bfe5                	j	4a22 <strlen+0x20>

0000000000004a2c <memset>:

void*
memset(void *dst, int c, uint n)
{
    4a2c:	1141                	addi	sp,sp,-16
    4a2e:	e422                	sd	s0,8(sp)
    4a30:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    4a32:	ca19                	beqz	a2,4a48 <memset+0x1c>
    4a34:	87aa                	mv	a5,a0
    4a36:	1602                	slli	a2,a2,0x20
    4a38:	9201                	srli	a2,a2,0x20
    4a3a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    4a3e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    4a42:	0785                	addi	a5,a5,1
    4a44:	fee79de3          	bne	a5,a4,4a3e <memset+0x12>
  }
  return dst;
}
    4a48:	6422                	ld	s0,8(sp)
    4a4a:	0141                	addi	sp,sp,16
    4a4c:	8082                	ret

0000000000004a4e <strchr>:

char*
strchr(const char *s, char c)
{
    4a4e:	1141                	addi	sp,sp,-16
    4a50:	e422                	sd	s0,8(sp)
    4a52:	0800                	addi	s0,sp,16
  for(; *s; s++)
    4a54:	00054783          	lbu	a5,0(a0)
    4a58:	cb99                	beqz	a5,4a6e <strchr+0x20>
    if(*s == c)
    4a5a:	00f58763          	beq	a1,a5,4a68 <strchr+0x1a>
  for(; *s; s++)
    4a5e:	0505                	addi	a0,a0,1
    4a60:	00054783          	lbu	a5,0(a0)
    4a64:	fbfd                	bnez	a5,4a5a <strchr+0xc>
      return (char*)s;
  return 0;
    4a66:	4501                	li	a0,0
}
    4a68:	6422                	ld	s0,8(sp)
    4a6a:	0141                	addi	sp,sp,16
    4a6c:	8082                	ret
  return 0;
    4a6e:	4501                	li	a0,0
    4a70:	bfe5                	j	4a68 <strchr+0x1a>

0000000000004a72 <gets>:

char*
gets(char *buf, int max)
{
    4a72:	711d                	addi	sp,sp,-96
    4a74:	ec86                	sd	ra,88(sp)
    4a76:	e8a2                	sd	s0,80(sp)
    4a78:	e4a6                	sd	s1,72(sp)
    4a7a:	e0ca                	sd	s2,64(sp)
    4a7c:	fc4e                	sd	s3,56(sp)
    4a7e:	f852                	sd	s4,48(sp)
    4a80:	f456                	sd	s5,40(sp)
    4a82:	f05a                	sd	s6,32(sp)
    4a84:	ec5e                	sd	s7,24(sp)
    4a86:	1080                	addi	s0,sp,96
    4a88:	8baa                	mv	s7,a0
    4a8a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    4a8c:	892a                	mv	s2,a0
    4a8e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    4a90:	4aa9                	li	s5,10
    4a92:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    4a94:	89a6                	mv	s3,s1
    4a96:	2485                	addiw	s1,s1,1
    4a98:	0344d663          	bge	s1,s4,4ac4 <gets+0x52>
    cc = read(0, &c, 1);
    4a9c:	4605                	li	a2,1
    4a9e:	faf40593          	addi	a1,s0,-81
    4aa2:	4501                	li	a0,0
    4aa4:	1b4000ef          	jal	ra,4c58 <read>
    if(cc < 1)
    4aa8:	00a05e63          	blez	a0,4ac4 <gets+0x52>
    buf[i++] = c;
    4aac:	faf44783          	lbu	a5,-81(s0)
    4ab0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    4ab4:	01578763          	beq	a5,s5,4ac2 <gets+0x50>
    4ab8:	0905                	addi	s2,s2,1
    4aba:	fd679de3          	bne	a5,s6,4a94 <gets+0x22>
  for(i=0; i+1 < max; ){
    4abe:	89a6                	mv	s3,s1
    4ac0:	a011                	j	4ac4 <gets+0x52>
    4ac2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    4ac4:	99de                	add	s3,s3,s7
    4ac6:	00098023          	sb	zero,0(s3) # 1000000 <base+0xff1358>
  return buf;
}
    4aca:	855e                	mv	a0,s7
    4acc:	60e6                	ld	ra,88(sp)
    4ace:	6446                	ld	s0,80(sp)
    4ad0:	64a6                	ld	s1,72(sp)
    4ad2:	6906                	ld	s2,64(sp)
    4ad4:	79e2                	ld	s3,56(sp)
    4ad6:	7a42                	ld	s4,48(sp)
    4ad8:	7aa2                	ld	s5,40(sp)
    4ada:	7b02                	ld	s6,32(sp)
    4adc:	6be2                	ld	s7,24(sp)
    4ade:	6125                	addi	sp,sp,96
    4ae0:	8082                	ret

0000000000004ae2 <stat>:

int
stat(const char *n, struct stat *st)
{
    4ae2:	1101                	addi	sp,sp,-32
    4ae4:	ec06                	sd	ra,24(sp)
    4ae6:	e822                	sd	s0,16(sp)
    4ae8:	e426                	sd	s1,8(sp)
    4aea:	e04a                	sd	s2,0(sp)
    4aec:	1000                	addi	s0,sp,32
    4aee:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    4af0:	4581                	li	a1,0
    4af2:	18e000ef          	jal	ra,4c80 <open>
  if(fd < 0)
    4af6:	02054163          	bltz	a0,4b18 <stat+0x36>
    4afa:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    4afc:	85ca                	mv	a1,s2
    4afe:	19a000ef          	jal	ra,4c98 <fstat>
    4b02:	892a                	mv	s2,a0
  close(fd);
    4b04:	8526                	mv	a0,s1
    4b06:	162000ef          	jal	ra,4c68 <close>
  return r;
}
    4b0a:	854a                	mv	a0,s2
    4b0c:	60e2                	ld	ra,24(sp)
    4b0e:	6442                	ld	s0,16(sp)
    4b10:	64a2                	ld	s1,8(sp)
    4b12:	6902                	ld	s2,0(sp)
    4b14:	6105                	addi	sp,sp,32
    4b16:	8082                	ret
    return -1;
    4b18:	597d                	li	s2,-1
    4b1a:	bfc5                	j	4b0a <stat+0x28>

0000000000004b1c <atoi>:

int
atoi(const char *s)
{
    4b1c:	1141                	addi	sp,sp,-16
    4b1e:	e422                	sd	s0,8(sp)
    4b20:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    4b22:	00054603          	lbu	a2,0(a0)
    4b26:	fd06079b          	addiw	a5,a2,-48
    4b2a:	0ff7f793          	andi	a5,a5,255
    4b2e:	4725                	li	a4,9
    4b30:	02f76963          	bltu	a4,a5,4b62 <atoi+0x46>
    4b34:	86aa                	mv	a3,a0
  n = 0;
    4b36:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    4b38:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    4b3a:	0685                	addi	a3,a3,1
    4b3c:	0025179b          	slliw	a5,a0,0x2
    4b40:	9fa9                	addw	a5,a5,a0
    4b42:	0017979b          	slliw	a5,a5,0x1
    4b46:	9fb1                	addw	a5,a5,a2
    4b48:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    4b4c:	0006c603          	lbu	a2,0(a3) # 40000 <base+0x31358>
    4b50:	fd06071b          	addiw	a4,a2,-48
    4b54:	0ff77713          	andi	a4,a4,255
    4b58:	fee5f1e3          	bgeu	a1,a4,4b3a <atoi+0x1e>
  return n;
}
    4b5c:	6422                	ld	s0,8(sp)
    4b5e:	0141                	addi	sp,sp,16
    4b60:	8082                	ret
  n = 0;
    4b62:	4501                	li	a0,0
    4b64:	bfe5                	j	4b5c <atoi+0x40>

0000000000004b66 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    4b66:	1141                	addi	sp,sp,-16
    4b68:	e422                	sd	s0,8(sp)
    4b6a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    4b6c:	02b57463          	bgeu	a0,a1,4b94 <memmove+0x2e>
    while(n-- > 0)
    4b70:	00c05f63          	blez	a2,4b8e <memmove+0x28>
    4b74:	1602                	slli	a2,a2,0x20
    4b76:	9201                	srli	a2,a2,0x20
    4b78:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    4b7c:	872a                	mv	a4,a0
      *dst++ = *src++;
    4b7e:	0585                	addi	a1,a1,1
    4b80:	0705                	addi	a4,a4,1
    4b82:	fff5c683          	lbu	a3,-1(a1)
    4b86:	fed70fa3          	sb	a3,-1(a4) # ffffff <base+0xff1357>
    while(n-- > 0)
    4b8a:	fee79ae3          	bne	a5,a4,4b7e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    4b8e:	6422                	ld	s0,8(sp)
    4b90:	0141                	addi	sp,sp,16
    4b92:	8082                	ret
    dst += n;
    4b94:	00c50733          	add	a4,a0,a2
    src += n;
    4b98:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    4b9a:	fec05ae3          	blez	a2,4b8e <memmove+0x28>
    4b9e:	fff6079b          	addiw	a5,a2,-1
    4ba2:	1782                	slli	a5,a5,0x20
    4ba4:	9381                	srli	a5,a5,0x20
    4ba6:	fff7c793          	not	a5,a5
    4baa:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    4bac:	15fd                	addi	a1,a1,-1
    4bae:	177d                	addi	a4,a4,-1
    4bb0:	0005c683          	lbu	a3,0(a1)
    4bb4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    4bb8:	fee79ae3          	bne	a5,a4,4bac <memmove+0x46>
    4bbc:	bfc9                	j	4b8e <memmove+0x28>

0000000000004bbe <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    4bbe:	1141                	addi	sp,sp,-16
    4bc0:	e422                	sd	s0,8(sp)
    4bc2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    4bc4:	ca05                	beqz	a2,4bf4 <memcmp+0x36>
    4bc6:	fff6069b          	addiw	a3,a2,-1
    4bca:	1682                	slli	a3,a3,0x20
    4bcc:	9281                	srli	a3,a3,0x20
    4bce:	0685                	addi	a3,a3,1
    4bd0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    4bd2:	00054783          	lbu	a5,0(a0)
    4bd6:	0005c703          	lbu	a4,0(a1)
    4bda:	00e79863          	bne	a5,a4,4bea <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    4bde:	0505                	addi	a0,a0,1
    p2++;
    4be0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    4be2:	fed518e3          	bne	a0,a3,4bd2 <memcmp+0x14>
  }
  return 0;
    4be6:	4501                	li	a0,0
    4be8:	a019                	j	4bee <memcmp+0x30>
      return *p1 - *p2;
    4bea:	40e7853b          	subw	a0,a5,a4
}
    4bee:	6422                	ld	s0,8(sp)
    4bf0:	0141                	addi	sp,sp,16
    4bf2:	8082                	ret
  return 0;
    4bf4:	4501                	li	a0,0
    4bf6:	bfe5                	j	4bee <memcmp+0x30>

0000000000004bf8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    4bf8:	1141                	addi	sp,sp,-16
    4bfa:	e406                	sd	ra,8(sp)
    4bfc:	e022                	sd	s0,0(sp)
    4bfe:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    4c00:	f67ff0ef          	jal	ra,4b66 <memmove>
}
    4c04:	60a2                	ld	ra,8(sp)
    4c06:	6402                	ld	s0,0(sp)
    4c08:	0141                	addi	sp,sp,16
    4c0a:	8082                	ret

0000000000004c0c <sbrk>:

char *
sbrk(int n) {
    4c0c:	1141                	addi	sp,sp,-16
    4c0e:	e406                	sd	ra,8(sp)
    4c10:	e022                	sd	s0,0(sp)
    4c12:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
    4c14:	4585                	li	a1,1
    4c16:	0b2000ef          	jal	ra,4cc8 <sys_sbrk>
}
    4c1a:	60a2                	ld	ra,8(sp)
    4c1c:	6402                	ld	s0,0(sp)
    4c1e:	0141                	addi	sp,sp,16
    4c20:	8082                	ret

0000000000004c22 <sbrklazy>:

char *
sbrklazy(int n) {
    4c22:	1141                	addi	sp,sp,-16
    4c24:	e406                	sd	ra,8(sp)
    4c26:	e022                	sd	s0,0(sp)
    4c28:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
    4c2a:	4589                	li	a1,2
    4c2c:	09c000ef          	jal	ra,4cc8 <sys_sbrk>
}
    4c30:	60a2                	ld	ra,8(sp)
    4c32:	6402                	ld	s0,0(sp)
    4c34:	0141                	addi	sp,sp,16
    4c36:	8082                	ret

0000000000004c38 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    4c38:	4885                	li	a7,1
 ecall
    4c3a:	00000073          	ecall
 ret
    4c3e:	8082                	ret

0000000000004c40 <exit>:
.global exit
exit:
 li a7, SYS_exit
    4c40:	4889                	li	a7,2
 ecall
    4c42:	00000073          	ecall
 ret
    4c46:	8082                	ret

0000000000004c48 <wait>:
.global wait
wait:
 li a7, SYS_wait
    4c48:	488d                	li	a7,3
 ecall
    4c4a:	00000073          	ecall
 ret
    4c4e:	8082                	ret

0000000000004c50 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    4c50:	4891                	li	a7,4
 ecall
    4c52:	00000073          	ecall
 ret
    4c56:	8082                	ret

0000000000004c58 <read>:
.global read
read:
 li a7, SYS_read
    4c58:	4895                	li	a7,5
 ecall
    4c5a:	00000073          	ecall
 ret
    4c5e:	8082                	ret

0000000000004c60 <write>:
.global write
write:
 li a7, SYS_write
    4c60:	48c1                	li	a7,16
 ecall
    4c62:	00000073          	ecall
 ret
    4c66:	8082                	ret

0000000000004c68 <close>:
.global close
close:
 li a7, SYS_close
    4c68:	48d5                	li	a7,21
 ecall
    4c6a:	00000073          	ecall
 ret
    4c6e:	8082                	ret

0000000000004c70 <kill>:
.global kill
kill:
 li a7, SYS_kill
    4c70:	4899                	li	a7,6
 ecall
    4c72:	00000073          	ecall
 ret
    4c76:	8082                	ret

0000000000004c78 <exec>:
.global exec
exec:
 li a7, SYS_exec
    4c78:	489d                	li	a7,7
 ecall
    4c7a:	00000073          	ecall
 ret
    4c7e:	8082                	ret

0000000000004c80 <open>:
.global open
open:
 li a7, SYS_open
    4c80:	48bd                	li	a7,15
 ecall
    4c82:	00000073          	ecall
 ret
    4c86:	8082                	ret

0000000000004c88 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    4c88:	48c5                	li	a7,17
 ecall
    4c8a:	00000073          	ecall
 ret
    4c8e:	8082                	ret

0000000000004c90 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    4c90:	48c9                	li	a7,18
 ecall
    4c92:	00000073          	ecall
 ret
    4c96:	8082                	ret

0000000000004c98 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    4c98:	48a1                	li	a7,8
 ecall
    4c9a:	00000073          	ecall
 ret
    4c9e:	8082                	ret

0000000000004ca0 <link>:
.global link
link:
 li a7, SYS_link
    4ca0:	48cd                	li	a7,19
 ecall
    4ca2:	00000073          	ecall
 ret
    4ca6:	8082                	ret

0000000000004ca8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    4ca8:	48d1                	li	a7,20
 ecall
    4caa:	00000073          	ecall
 ret
    4cae:	8082                	ret

0000000000004cb0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    4cb0:	48a5                	li	a7,9
 ecall
    4cb2:	00000073          	ecall
 ret
    4cb6:	8082                	ret

0000000000004cb8 <dup>:
.global dup
dup:
 li a7, SYS_dup
    4cb8:	48a9                	li	a7,10
 ecall
    4cba:	00000073          	ecall
 ret
    4cbe:	8082                	ret

0000000000004cc0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    4cc0:	48ad                	li	a7,11
 ecall
    4cc2:	00000073          	ecall
 ret
    4cc6:	8082                	ret

0000000000004cc8 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
    4cc8:	48b1                	li	a7,12
 ecall
    4cca:	00000073          	ecall
 ret
    4cce:	8082                	ret

0000000000004cd0 <pause>:
.global pause
pause:
 li a7, SYS_pause
    4cd0:	48b5                	li	a7,13
 ecall
    4cd2:	00000073          	ecall
 ret
    4cd6:	8082                	ret

0000000000004cd8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    4cd8:	48b9                	li	a7,14
 ecall
    4cda:	00000073          	ecall
 ret
    4cde:	8082                	ret

0000000000004ce0 <memstat>:
.global memstat
memstat:
 li a7, SYS_memstat
    4ce0:	48d9                	li	a7,22
 ecall
    4ce2:	00000073          	ecall
 ret
    4ce6:	8082                	ret

0000000000004ce8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    4ce8:	1101                	addi	sp,sp,-32
    4cea:	ec06                	sd	ra,24(sp)
    4cec:	e822                	sd	s0,16(sp)
    4cee:	1000                	addi	s0,sp,32
    4cf0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    4cf4:	4605                	li	a2,1
    4cf6:	fef40593          	addi	a1,s0,-17
    4cfa:	f67ff0ef          	jal	ra,4c60 <write>
}
    4cfe:	60e2                	ld	ra,24(sp)
    4d00:	6442                	ld	s0,16(sp)
    4d02:	6105                	addi	sp,sp,32
    4d04:	8082                	ret

0000000000004d06 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
    4d06:	715d                	addi	sp,sp,-80
    4d08:	e486                	sd	ra,72(sp)
    4d0a:	e0a2                	sd	s0,64(sp)
    4d0c:	fc26                	sd	s1,56(sp)
    4d0e:	f84a                	sd	s2,48(sp)
    4d10:	f44e                	sd	s3,40(sp)
    4d12:	0880                	addi	s0,sp,80
    4d14:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
    4d16:	c299                	beqz	a3,4d1c <printint+0x16>
    4d18:	0805c163          	bltz	a1,4d9a <printint+0x94>
  neg = 0;
    4d1c:	4881                	li	a7,0
    4d1e:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
    4d22:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
    4d24:	00003517          	auipc	a0,0x3
    4d28:	a0c50513          	addi	a0,a0,-1524 # 7730 <digits>
    4d2c:	883e                	mv	a6,a5
    4d2e:	2785                	addiw	a5,a5,1
    4d30:	02c5f733          	remu	a4,a1,a2
    4d34:	972a                	add	a4,a4,a0
    4d36:	00074703          	lbu	a4,0(a4)
    4d3a:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
    4d3e:	872e                	mv	a4,a1
    4d40:	02c5d5b3          	divu	a1,a1,a2
    4d44:	0685                	addi	a3,a3,1
    4d46:	fec773e3          	bgeu	a4,a2,4d2c <printint+0x26>
  if(neg)
    4d4a:	00088b63          	beqz	a7,4d60 <printint+0x5a>
    buf[i++] = '-';
    4d4e:	fd040713          	addi	a4,s0,-48
    4d52:	97ba                	add	a5,a5,a4
    4d54:	02d00713          	li	a4,45
    4d58:	fee78423          	sb	a4,-24(a5)
    4d5c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    4d60:	02f05663          	blez	a5,4d8c <printint+0x86>
    4d64:	fb840713          	addi	a4,s0,-72
    4d68:	00f704b3          	add	s1,a4,a5
    4d6c:	fff70993          	addi	s3,a4,-1
    4d70:	99be                	add	s3,s3,a5
    4d72:	37fd                	addiw	a5,a5,-1
    4d74:	1782                	slli	a5,a5,0x20
    4d76:	9381                	srli	a5,a5,0x20
    4d78:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
    4d7c:	fff4c583          	lbu	a1,-1(s1) # 40000fff <base+0x3fff2357>
    4d80:	854a                	mv	a0,s2
    4d82:	f67ff0ef          	jal	ra,4ce8 <putc>
  while(--i >= 0)
    4d86:	14fd                	addi	s1,s1,-1
    4d88:	ff349ae3          	bne	s1,s3,4d7c <printint+0x76>
}
    4d8c:	60a6                	ld	ra,72(sp)
    4d8e:	6406                	ld	s0,64(sp)
    4d90:	74e2                	ld	s1,56(sp)
    4d92:	7942                	ld	s2,48(sp)
    4d94:	79a2                	ld	s3,40(sp)
    4d96:	6161                	addi	sp,sp,80
    4d98:	8082                	ret
    x = -xx;
    4d9a:	40b005b3          	neg	a1,a1
    neg = 1;
    4d9e:	4885                	li	a7,1
    x = -xx;
    4da0:	bfbd                	j	4d1e <printint+0x18>

0000000000004da2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    4da2:	7119                	addi	sp,sp,-128
    4da4:	fc86                	sd	ra,120(sp)
    4da6:	f8a2                	sd	s0,112(sp)
    4da8:	f4a6                	sd	s1,104(sp)
    4daa:	f0ca                	sd	s2,96(sp)
    4dac:	ecce                	sd	s3,88(sp)
    4dae:	e8d2                	sd	s4,80(sp)
    4db0:	e4d6                	sd	s5,72(sp)
    4db2:	e0da                	sd	s6,64(sp)
    4db4:	fc5e                	sd	s7,56(sp)
    4db6:	f862                	sd	s8,48(sp)
    4db8:	f466                	sd	s9,40(sp)
    4dba:	f06a                	sd	s10,32(sp)
    4dbc:	ec6e                	sd	s11,24(sp)
    4dbe:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    4dc0:	0005c903          	lbu	s2,0(a1)
    4dc4:	24090c63          	beqz	s2,501c <vprintf+0x27a>
    4dc8:	8b2a                	mv	s6,a0
    4dca:	8a2e                	mv	s4,a1
    4dcc:	8bb2                	mv	s7,a2
  state = 0;
    4dce:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
    4dd0:	4481                	li	s1,0
    4dd2:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
    4dd4:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
    4dd8:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
    4ddc:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
    4de0:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    4de4:	00003c97          	auipc	s9,0x3
    4de8:	94cc8c93          	addi	s9,s9,-1716 # 7730 <digits>
    4dec:	a005                	j	4e0c <vprintf+0x6a>
        putc(fd, c0);
    4dee:	85ca                	mv	a1,s2
    4df0:	855a                	mv	a0,s6
    4df2:	ef7ff0ef          	jal	ra,4ce8 <putc>
    4df6:	a019                	j	4dfc <vprintf+0x5a>
    } else if(state == '%'){
    4df8:	03598263          	beq	s3,s5,4e1c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    4dfc:	2485                	addiw	s1,s1,1
    4dfe:	8726                	mv	a4,s1
    4e00:	009a07b3          	add	a5,s4,s1
    4e04:	0007c903          	lbu	s2,0(a5)
    4e08:	20090a63          	beqz	s2,501c <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
    4e0c:	0009079b          	sext.w	a5,s2
    if(state == 0){
    4e10:	fe0994e3          	bnez	s3,4df8 <vprintf+0x56>
      if(c0 == '%'){
    4e14:	fd579de3          	bne	a5,s5,4dee <vprintf+0x4c>
        state = '%';
    4e18:	89be                	mv	s3,a5
    4e1a:	b7cd                	j	4dfc <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
    4e1c:	c3c1                	beqz	a5,4e9c <vprintf+0xfa>
    4e1e:	00ea06b3          	add	a3,s4,a4
    4e22:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
    4e26:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
    4e28:	c681                	beqz	a3,4e30 <vprintf+0x8e>
    4e2a:	9752                	add	a4,a4,s4
    4e2c:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
    4e30:	03878e63          	beq	a5,s8,4e6c <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
    4e34:	05a78863          	beq	a5,s10,4e84 <vprintf+0xe2>
      } else if(c0 == 'u'){
    4e38:	0db78b63          	beq	a5,s11,4f0e <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
    4e3c:	07800713          	li	a4,120
    4e40:	10e78d63          	beq	a5,a4,4f5a <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
    4e44:	07000713          	li	a4,112
    4e48:	14e78263          	beq	a5,a4,4f8c <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
    4e4c:	06300713          	li	a4,99
    4e50:	16e78f63          	beq	a5,a4,4fce <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
    4e54:	07300713          	li	a4,115
    4e58:	18e78563          	beq	a5,a4,4fe2 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
    4e5c:	05579063          	bne	a5,s5,4e9c <vprintf+0xfa>
        putc(fd, '%');
    4e60:	85d6                	mv	a1,s5
    4e62:	855a                	mv	a0,s6
    4e64:	e85ff0ef          	jal	ra,4ce8 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
    4e68:	4981                	li	s3,0
    4e6a:	bf49                	j	4dfc <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
    4e6c:	008b8913          	addi	s2,s7,8
    4e70:	4685                	li	a3,1
    4e72:	4629                	li	a2,10
    4e74:	000ba583          	lw	a1,0(s7)
    4e78:	855a                	mv	a0,s6
    4e7a:	e8dff0ef          	jal	ra,4d06 <printint>
    4e7e:	8bca                	mv	s7,s2
      state = 0;
    4e80:	4981                	li	s3,0
    4e82:	bfad                	j	4dfc <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
    4e84:	03868663          	beq	a3,s8,4eb0 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    4e88:	05a68163          	beq	a3,s10,4eca <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
    4e8c:	09b68d63          	beq	a3,s11,4f26 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    4e90:	03a68f63          	beq	a3,s10,4ece <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
    4e94:	07800793          	li	a5,120
    4e98:	0cf68d63          	beq	a3,a5,4f72 <vprintf+0x1d0>
        putc(fd, '%');
    4e9c:	85d6                	mv	a1,s5
    4e9e:	855a                	mv	a0,s6
    4ea0:	e49ff0ef          	jal	ra,4ce8 <putc>
        putc(fd, c0);
    4ea4:	85ca                	mv	a1,s2
    4ea6:	855a                	mv	a0,s6
    4ea8:	e41ff0ef          	jal	ra,4ce8 <putc>
      state = 0;
    4eac:	4981                	li	s3,0
    4eae:	b7b9                	j	4dfc <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    4eb0:	008b8913          	addi	s2,s7,8
    4eb4:	4685                	li	a3,1
    4eb6:	4629                	li	a2,10
    4eb8:	000bb583          	ld	a1,0(s7)
    4ebc:	855a                	mv	a0,s6
    4ebe:	e49ff0ef          	jal	ra,4d06 <printint>
        i += 1;
    4ec2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
    4ec4:	8bca                	mv	s7,s2
      state = 0;
    4ec6:	4981                	li	s3,0
        i += 1;
    4ec8:	bf15                	j	4dfc <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    4eca:	03860563          	beq	a2,s8,4ef4 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    4ece:	07b60963          	beq	a2,s11,4f40 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    4ed2:	07800793          	li	a5,120
    4ed6:	fcf613e3          	bne	a2,a5,4e9c <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
    4eda:	008b8913          	addi	s2,s7,8
    4ede:	4681                	li	a3,0
    4ee0:	4641                	li	a2,16
    4ee2:	000bb583          	ld	a1,0(s7)
    4ee6:	855a                	mv	a0,s6
    4ee8:	e1fff0ef          	jal	ra,4d06 <printint>
        i += 2;
    4eec:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
    4eee:	8bca                	mv	s7,s2
      state = 0;
    4ef0:	4981                	li	s3,0
        i += 2;
    4ef2:	b729                	j	4dfc <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    4ef4:	008b8913          	addi	s2,s7,8
    4ef8:	4685                	li	a3,1
    4efa:	4629                	li	a2,10
    4efc:	000bb583          	ld	a1,0(s7)
    4f00:	855a                	mv	a0,s6
    4f02:	e05ff0ef          	jal	ra,4d06 <printint>
        i += 2;
    4f06:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
    4f08:	8bca                	mv	s7,s2
      state = 0;
    4f0a:	4981                	li	s3,0
        i += 2;
    4f0c:	bdc5                	j	4dfc <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
    4f0e:	008b8913          	addi	s2,s7,8
    4f12:	4681                	li	a3,0
    4f14:	4629                	li	a2,10
    4f16:	000be583          	lwu	a1,0(s7)
    4f1a:	855a                	mv	a0,s6
    4f1c:	debff0ef          	jal	ra,4d06 <printint>
    4f20:	8bca                	mv	s7,s2
      state = 0;
    4f22:	4981                	li	s3,0
    4f24:	bde1                	j	4dfc <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    4f26:	008b8913          	addi	s2,s7,8
    4f2a:	4681                	li	a3,0
    4f2c:	4629                	li	a2,10
    4f2e:	000bb583          	ld	a1,0(s7)
    4f32:	855a                	mv	a0,s6
    4f34:	dd3ff0ef          	jal	ra,4d06 <printint>
        i += 1;
    4f38:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
    4f3a:	8bca                	mv	s7,s2
      state = 0;
    4f3c:	4981                	li	s3,0
        i += 1;
    4f3e:	bd7d                	j	4dfc <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    4f40:	008b8913          	addi	s2,s7,8
    4f44:	4681                	li	a3,0
    4f46:	4629                	li	a2,10
    4f48:	000bb583          	ld	a1,0(s7)
    4f4c:	855a                	mv	a0,s6
    4f4e:	db9ff0ef          	jal	ra,4d06 <printint>
        i += 2;
    4f52:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
    4f54:	8bca                	mv	s7,s2
      state = 0;
    4f56:	4981                	li	s3,0
        i += 2;
    4f58:	b555                	j	4dfc <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
    4f5a:	008b8913          	addi	s2,s7,8
    4f5e:	4681                	li	a3,0
    4f60:	4641                	li	a2,16
    4f62:	000be583          	lwu	a1,0(s7)
    4f66:	855a                	mv	a0,s6
    4f68:	d9fff0ef          	jal	ra,4d06 <printint>
    4f6c:	8bca                	mv	s7,s2
      state = 0;
    4f6e:	4981                	li	s3,0
    4f70:	b571                	j	4dfc <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
    4f72:	008b8913          	addi	s2,s7,8
    4f76:	4681                	li	a3,0
    4f78:	4641                	li	a2,16
    4f7a:	000bb583          	ld	a1,0(s7)
    4f7e:	855a                	mv	a0,s6
    4f80:	d87ff0ef          	jal	ra,4d06 <printint>
        i += 1;
    4f84:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
    4f86:	8bca                	mv	s7,s2
      state = 0;
    4f88:	4981                	li	s3,0
        i += 1;
    4f8a:	bd8d                	j	4dfc <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
    4f8c:	008b8793          	addi	a5,s7,8
    4f90:	f8f43423          	sd	a5,-120(s0)
    4f94:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    4f98:	03000593          	li	a1,48
    4f9c:	855a                	mv	a0,s6
    4f9e:	d4bff0ef          	jal	ra,4ce8 <putc>
  putc(fd, 'x');
    4fa2:	07800593          	li	a1,120
    4fa6:	855a                	mv	a0,s6
    4fa8:	d41ff0ef          	jal	ra,4ce8 <putc>
    4fac:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    4fae:	03c9d793          	srli	a5,s3,0x3c
    4fb2:	97e6                	add	a5,a5,s9
    4fb4:	0007c583          	lbu	a1,0(a5)
    4fb8:	855a                	mv	a0,s6
    4fba:	d2fff0ef          	jal	ra,4ce8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    4fbe:	0992                	slli	s3,s3,0x4
    4fc0:	397d                	addiw	s2,s2,-1
    4fc2:	fe0916e3          	bnez	s2,4fae <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
    4fc6:	f8843b83          	ld	s7,-120(s0)
      state = 0;
    4fca:	4981                	li	s3,0
    4fcc:	bd05                	j	4dfc <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
    4fce:	008b8913          	addi	s2,s7,8
    4fd2:	000bc583          	lbu	a1,0(s7)
    4fd6:	855a                	mv	a0,s6
    4fd8:	d11ff0ef          	jal	ra,4ce8 <putc>
    4fdc:	8bca                	mv	s7,s2
      state = 0;
    4fde:	4981                	li	s3,0
    4fe0:	bd31                	j	4dfc <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
    4fe2:	008b8993          	addi	s3,s7,8
    4fe6:	000bb903          	ld	s2,0(s7)
    4fea:	00090f63          	beqz	s2,5008 <vprintf+0x266>
        for(; *s; s++)
    4fee:	00094583          	lbu	a1,0(s2)
    4ff2:	c195                	beqz	a1,5016 <vprintf+0x274>
          putc(fd, *s);
    4ff4:	855a                	mv	a0,s6
    4ff6:	cf3ff0ef          	jal	ra,4ce8 <putc>
        for(; *s; s++)
    4ffa:	0905                	addi	s2,s2,1
    4ffc:	00094583          	lbu	a1,0(s2)
    5000:	f9f5                	bnez	a1,4ff4 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
    5002:	8bce                	mv	s7,s3
      state = 0;
    5004:	4981                	li	s3,0
    5006:	bbdd                	j	4dfc <vprintf+0x5a>
          s = "(null)";
    5008:	00002917          	auipc	s2,0x2
    500c:	72090913          	addi	s2,s2,1824 # 7728 <malloc+0x260a>
        for(; *s; s++)
    5010:	02800593          	li	a1,40
    5014:	b7c5                	j	4ff4 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
    5016:	8bce                	mv	s7,s3
      state = 0;
    5018:	4981                	li	s3,0
    501a:	b3cd                	j	4dfc <vprintf+0x5a>
    }
  }
}
    501c:	70e6                	ld	ra,120(sp)
    501e:	7446                	ld	s0,112(sp)
    5020:	74a6                	ld	s1,104(sp)
    5022:	7906                	ld	s2,96(sp)
    5024:	69e6                	ld	s3,88(sp)
    5026:	6a46                	ld	s4,80(sp)
    5028:	6aa6                	ld	s5,72(sp)
    502a:	6b06                	ld	s6,64(sp)
    502c:	7be2                	ld	s7,56(sp)
    502e:	7c42                	ld	s8,48(sp)
    5030:	7ca2                	ld	s9,40(sp)
    5032:	7d02                	ld	s10,32(sp)
    5034:	6de2                	ld	s11,24(sp)
    5036:	6109                	addi	sp,sp,128
    5038:	8082                	ret

000000000000503a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    503a:	715d                	addi	sp,sp,-80
    503c:	ec06                	sd	ra,24(sp)
    503e:	e822                	sd	s0,16(sp)
    5040:	1000                	addi	s0,sp,32
    5042:	e010                	sd	a2,0(s0)
    5044:	e414                	sd	a3,8(s0)
    5046:	e818                	sd	a4,16(s0)
    5048:	ec1c                	sd	a5,24(s0)
    504a:	03043023          	sd	a6,32(s0)
    504e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5052:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5056:	8622                	mv	a2,s0
    5058:	d4bff0ef          	jal	ra,4da2 <vprintf>
}
    505c:	60e2                	ld	ra,24(sp)
    505e:	6442                	ld	s0,16(sp)
    5060:	6161                	addi	sp,sp,80
    5062:	8082                	ret

0000000000005064 <printf>:

void
printf(const char *fmt, ...)
{
    5064:	711d                	addi	sp,sp,-96
    5066:	ec06                	sd	ra,24(sp)
    5068:	e822                	sd	s0,16(sp)
    506a:	1000                	addi	s0,sp,32
    506c:	e40c                	sd	a1,8(s0)
    506e:	e810                	sd	a2,16(s0)
    5070:	ec14                	sd	a3,24(s0)
    5072:	f018                	sd	a4,32(s0)
    5074:	f41c                	sd	a5,40(s0)
    5076:	03043823          	sd	a6,48(s0)
    507a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    507e:	00840613          	addi	a2,s0,8
    5082:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    5086:	85aa                	mv	a1,a0
    5088:	4505                	li	a0,1
    508a:	d19ff0ef          	jal	ra,4da2 <vprintf>
}
    508e:	60e2                	ld	ra,24(sp)
    5090:	6442                	ld	s0,16(sp)
    5092:	6125                	addi	sp,sp,96
    5094:	8082                	ret

0000000000005096 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    5096:	1141                	addi	sp,sp,-16
    5098:	e422                	sd	s0,8(sp)
    509a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    509c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    50a0:	00003797          	auipc	a5,0x3
    50a4:	3e07b783          	ld	a5,992(a5) # 8480 <freep>
    50a8:	a805                	j	50d8 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    50aa:	4618                	lw	a4,8(a2)
    50ac:	9db9                	addw	a1,a1,a4
    50ae:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    50b2:	6398                	ld	a4,0(a5)
    50b4:	6318                	ld	a4,0(a4)
    50b6:	fee53823          	sd	a4,-16(a0)
    50ba:	a091                	j	50fe <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    50bc:	ff852703          	lw	a4,-8(a0)
    50c0:	9e39                	addw	a2,a2,a4
    50c2:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    50c4:	ff053703          	ld	a4,-16(a0)
    50c8:	e398                	sd	a4,0(a5)
    50ca:	a099                	j	5110 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    50cc:	6398                	ld	a4,0(a5)
    50ce:	00e7e463          	bltu	a5,a4,50d6 <free+0x40>
    50d2:	00e6ea63          	bltu	a3,a4,50e6 <free+0x50>
{
    50d6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    50d8:	fed7fae3          	bgeu	a5,a3,50cc <free+0x36>
    50dc:	6398                	ld	a4,0(a5)
    50de:	00e6e463          	bltu	a3,a4,50e6 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    50e2:	fee7eae3          	bltu	a5,a4,50d6 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    50e6:	ff852583          	lw	a1,-8(a0)
    50ea:	6390                	ld	a2,0(a5)
    50ec:	02059713          	slli	a4,a1,0x20
    50f0:	9301                	srli	a4,a4,0x20
    50f2:	0712                	slli	a4,a4,0x4
    50f4:	9736                	add	a4,a4,a3
    50f6:	fae60ae3          	beq	a2,a4,50aa <free+0x14>
    bp->s.ptr = p->s.ptr;
    50fa:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    50fe:	4790                	lw	a2,8(a5)
    5100:	02061713          	slli	a4,a2,0x20
    5104:	9301                	srli	a4,a4,0x20
    5106:	0712                	slli	a4,a4,0x4
    5108:	973e                	add	a4,a4,a5
    510a:	fae689e3          	beq	a3,a4,50bc <free+0x26>
  } else
    p->s.ptr = bp;
    510e:	e394                	sd	a3,0(a5)
  freep = p;
    5110:	00003717          	auipc	a4,0x3
    5114:	36f73823          	sd	a5,880(a4) # 8480 <freep>
}
    5118:	6422                	ld	s0,8(sp)
    511a:	0141                	addi	sp,sp,16
    511c:	8082                	ret

000000000000511e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    511e:	7139                	addi	sp,sp,-64
    5120:	fc06                	sd	ra,56(sp)
    5122:	f822                	sd	s0,48(sp)
    5124:	f426                	sd	s1,40(sp)
    5126:	f04a                	sd	s2,32(sp)
    5128:	ec4e                	sd	s3,24(sp)
    512a:	e852                	sd	s4,16(sp)
    512c:	e456                	sd	s5,8(sp)
    512e:	e05a                	sd	s6,0(sp)
    5130:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    5132:	02051493          	slli	s1,a0,0x20
    5136:	9081                	srli	s1,s1,0x20
    5138:	04bd                	addi	s1,s1,15
    513a:	8091                	srli	s1,s1,0x4
    513c:	0014899b          	addiw	s3,s1,1
    5140:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    5142:	00003517          	auipc	a0,0x3
    5146:	33e53503          	ld	a0,830(a0) # 8480 <freep>
    514a:	c515                	beqz	a0,5176 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    514c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    514e:	4798                	lw	a4,8(a5)
    5150:	02977f63          	bgeu	a4,s1,518e <malloc+0x70>
    5154:	8a4e                	mv	s4,s3
    5156:	0009871b          	sext.w	a4,s3
    515a:	6685                	lui	a3,0x1
    515c:	00d77363          	bgeu	a4,a3,5162 <malloc+0x44>
    5160:	6a05                	lui	s4,0x1
    5162:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    5166:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    516a:	00003917          	auipc	s2,0x3
    516e:	31690913          	addi	s2,s2,790 # 8480 <freep>
  if(p == SBRK_ERROR)
    5172:	5afd                	li	s5,-1
    5174:	a0bd                	j	51e2 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
    5176:	0000a797          	auipc	a5,0xa
    517a:	b3278793          	addi	a5,a5,-1230 # eca8 <base>
    517e:	00003717          	auipc	a4,0x3
    5182:	30f73123          	sd	a5,770(a4) # 8480 <freep>
    5186:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5188:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    518c:	b7e1                	j	5154 <malloc+0x36>
      if(p->s.size == nunits)
    518e:	02e48b63          	beq	s1,a4,51c4 <malloc+0xa6>
        p->s.size -= nunits;
    5192:	4137073b          	subw	a4,a4,s3
    5196:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5198:	1702                	slli	a4,a4,0x20
    519a:	9301                	srli	a4,a4,0x20
    519c:	0712                	slli	a4,a4,0x4
    519e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    51a0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    51a4:	00003717          	auipc	a4,0x3
    51a8:	2ca73e23          	sd	a0,732(a4) # 8480 <freep>
      return (void*)(p + 1);
    51ac:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    51b0:	70e2                	ld	ra,56(sp)
    51b2:	7442                	ld	s0,48(sp)
    51b4:	74a2                	ld	s1,40(sp)
    51b6:	7902                	ld	s2,32(sp)
    51b8:	69e2                	ld	s3,24(sp)
    51ba:	6a42                	ld	s4,16(sp)
    51bc:	6aa2                	ld	s5,8(sp)
    51be:	6b02                	ld	s6,0(sp)
    51c0:	6121                	addi	sp,sp,64
    51c2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    51c4:	6398                	ld	a4,0(a5)
    51c6:	e118                	sd	a4,0(a0)
    51c8:	bff1                	j	51a4 <malloc+0x86>
  hp->s.size = nu;
    51ca:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    51ce:	0541                	addi	a0,a0,16
    51d0:	ec7ff0ef          	jal	ra,5096 <free>
  return freep;
    51d4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    51d8:	dd61                	beqz	a0,51b0 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    51da:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    51dc:	4798                	lw	a4,8(a5)
    51de:	fa9778e3          	bgeu	a4,s1,518e <malloc+0x70>
    if(p == freep)
    51e2:	00093703          	ld	a4,0(s2)
    51e6:	853e                	mv	a0,a5
    51e8:	fef719e3          	bne	a4,a5,51da <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
    51ec:	8552                	mv	a0,s4
    51ee:	a1fff0ef          	jal	ra,4c0c <sbrk>
  if(p == SBRK_ERROR)
    51f2:	fd551ce3          	bne	a0,s5,51ca <malloc+0xac>
        return 0;
    51f6:	4501                	li	a0,0
    51f8:	bf65                	j	51b0 <malloc+0x92>
