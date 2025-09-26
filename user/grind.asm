
user/_grind:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_rand>:
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
       6:	611c                	ld	a5,0(a0)
       8:	80000737          	lui	a4,0x80000
       c:	ffe74713          	xori	a4,a4,-2
      10:	02e7f7b3          	remu	a5,a5,a4
      14:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
      16:	66fd                	lui	a3,0x1f
      18:	31d68693          	addi	a3,a3,797 # 1f31d <base+0x1cf15>
      1c:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
      20:	6611                	lui	a2,0x4
      22:	1a760613          	addi	a2,a2,423 # 41a7 <base+0x1d9f>
      26:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
      2a:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
      2e:	76fd                	lui	a3,0xfffff
      30:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <base+0xffffffffffffd0e4>
      34:	02d787b3          	mul	a5,a5,a3
      38:	97ba                	add	a5,a5,a4
    if (x < 0)
      3a:	0007c963          	bltz	a5,4c <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
      3e:	17fd                	addi	a5,a5,-1
    *ctx = x;
      40:	e11c                	sd	a5,0(a0)
    return (x);
}
      42:	0007851b          	sext.w	a0,a5
      46:	6422                	ld	s0,8(sp)
      48:	0141                	addi	sp,sp,16
      4a:	8082                	ret
        x += 0x7fffffff;
      4c:	80000737          	lui	a4,0x80000
      50:	fff74713          	not	a4,a4
      54:	97ba                	add	a5,a5,a4
      56:	b7e5                	j	3e <do_rand+0x3e>

0000000000000058 <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
      58:	1141                	addi	sp,sp,-16
      5a:	e406                	sd	ra,8(sp)
      5c:	e022                	sd	s0,0(sp)
      5e:	0800                	addi	s0,sp,16
    return (do_rand(&rand_next));
      60:	00002517          	auipc	a0,0x2
      64:	fa050513          	addi	a0,a0,-96 # 2000 <rand_next>
      68:	f99ff0ef          	jal	ra,0 <do_rand>
}
      6c:	60a2                	ld	ra,8(sp)
      6e:	6402                	ld	s0,0(sp)
      70:	0141                	addi	sp,sp,16
      72:	8082                	ret

0000000000000074 <go>:

void
go(int which_child)
{
      74:	7159                	addi	sp,sp,-112
      76:	f486                	sd	ra,104(sp)
      78:	f0a2                	sd	s0,96(sp)
      7a:	eca6                	sd	s1,88(sp)
      7c:	e8ca                	sd	s2,80(sp)
      7e:	e4ce                	sd	s3,72(sp)
      80:	e0d2                	sd	s4,64(sp)
      82:	fc56                	sd	s5,56(sp)
      84:	f85a                	sd	s6,48(sp)
      86:	1880                	addi	s0,sp,112
      88:	84aa                	mv	s1,a0
  int fd = -1;
  static char buf[999];
  char *break0 = sbrk(0);
      8a:	4501                	li	a0,0
      8c:	307000ef          	jal	ra,b92 <sbrk>
      90:	8aaa                	mv	s5,a0
  uint64 iters = 0;

  mkdir("grindir");
      92:	00001517          	auipc	a0,0x1
      96:	0ee50513          	addi	a0,a0,238 # 1180 <malloc+0xe4>
      9a:	395000ef          	jal	ra,c2e <mkdir>
  if(chdir("grindir") != 0){
      9e:	00001517          	auipc	a0,0x1
      a2:	0e250513          	addi	a0,a0,226 # 1180 <malloc+0xe4>
      a6:	391000ef          	jal	ra,c36 <chdir>
      aa:	c911                	beqz	a0,be <go+0x4a>
    printf("grind: chdir grindir failed\n");
      ac:	00001517          	auipc	a0,0x1
      b0:	0dc50513          	addi	a0,a0,220 # 1188 <malloc+0xec>
      b4:	72f000ef          	jal	ra,fe2 <printf>
    exit(1);
      b8:	4505                	li	a0,1
      ba:	30d000ef          	jal	ra,bc6 <exit>
  }
  chdir("/");
      be:	00001517          	auipc	a0,0x1
      c2:	0ea50513          	addi	a0,a0,234 # 11a8 <malloc+0x10c>
      c6:	371000ef          	jal	ra,c36 <chdir>
  
  while(1){
    iters++;
    if((iters % 500) == 0)
      ca:	00001997          	auipc	s3,0x1
      ce:	0ee98993          	addi	s3,s3,238 # 11b8 <malloc+0x11c>
      d2:	c489                	beqz	s1,dc <go+0x68>
      d4:	00001997          	auipc	s3,0x1
      d8:	0dc98993          	addi	s3,s3,220 # 11b0 <malloc+0x114>
    iters++;
      dc:	4485                	li	s1,1
  int fd = -1;
      de:	597d                	li	s2,-1
      close(fd);
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
    } else if(what == 7){
      write(fd, buf, sizeof(buf));
    } else if(what == 8){
      read(fd, buf, sizeof(buf));
      e0:	00002a17          	auipc	s4,0x2
      e4:	f40a0a13          	addi	s4,s4,-192 # 2020 <buf.0>
      e8:	a035                	j	114 <go+0xa0>
      close(open("grindir/../a", O_CREATE|O_RDWR));
      ea:	20200593          	li	a1,514
      ee:	00001517          	auipc	a0,0x1
      f2:	0d250513          	addi	a0,a0,210 # 11c0 <malloc+0x124>
      f6:	311000ef          	jal	ra,c06 <open>
      fa:	2f5000ef          	jal	ra,bee <close>
    iters++;
      fe:	0485                	addi	s1,s1,1
    if((iters % 500) == 0)
     100:	1f400793          	li	a5,500
     104:	02f4f7b3          	remu	a5,s1,a5
     108:	e791                	bnez	a5,114 <go+0xa0>
      write(1, which_child?"B":"A", 1);
     10a:	4605                	li	a2,1
     10c:	85ce                	mv	a1,s3
     10e:	4505                	li	a0,1
     110:	2d7000ef          	jal	ra,be6 <write>
    int what = rand() % 23;
     114:	f45ff0ef          	jal	ra,58 <rand>
     118:	47dd                	li	a5,23
     11a:	02f5653b          	remw	a0,a0,a5
    if(what == 1){
     11e:	4785                	li	a5,1
     120:	fcf505e3          	beq	a0,a5,ea <go+0x76>
    } else if(what == 2){
     124:	4789                	li	a5,2
     126:	14f50563          	beq	a0,a5,270 <go+0x1fc>
    } else if(what == 3){
     12a:	478d                	li	a5,3
     12c:	14f50d63          	beq	a0,a5,286 <go+0x212>
    } else if(what == 4){
     130:	4791                	li	a5,4
     132:	16f50163          	beq	a0,a5,294 <go+0x220>
    } else if(what == 5){
     136:	4795                	li	a5,5
     138:	18f50b63          	beq	a0,a5,2ce <go+0x25a>
    } else if(what == 6){
     13c:	4799                	li	a5,6
     13e:	1af50563          	beq	a0,a5,2e8 <go+0x274>
    } else if(what == 7){
     142:	479d                	li	a5,7
     144:	1af50f63          	beq	a0,a5,302 <go+0x28e>
    } else if(what == 8){
     148:	47a1                	li	a5,8
     14a:	1cf50363          	beq	a0,a5,310 <go+0x29c>
    } else if(what == 9){
     14e:	47a5                	li	a5,9
     150:	1cf50763          	beq	a0,a5,31e <go+0x2aa>
      mkdir("grindir/../a");
      close(open("a/../a/./a", O_CREATE|O_RDWR));
      unlink("a/a");
    } else if(what == 10){
     154:	47a9                	li	a5,10
     156:	1ef50b63          	beq	a0,a5,34c <go+0x2d8>
      mkdir("/../b");
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
      unlink("b/b");
    } else if(what == 11){
     15a:	47ad                	li	a5,11
     15c:	20f50f63          	beq	a0,a5,37a <go+0x306>
      unlink("b");
      link("../grindir/./../a", "../b");
    } else if(what == 12){
     160:	47b1                	li	a5,12
     162:	22f50d63          	beq	a0,a5,39c <go+0x328>
      unlink("../grindir/../a");
      link(".././b", "/grindir/../a");
    } else if(what == 13){
     166:	47b5                	li	a5,13
     168:	24f50b63          	beq	a0,a5,3be <go+0x34a>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 14){
     16c:	47b9                	li	a5,14
     16e:	26f50c63          	beq	a0,a5,3e6 <go+0x372>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 15){
     172:	47bd                	li	a5,15
     174:	2af50263          	beq	a0,a5,418 <go+0x3a4>
      sbrk(6011);
    } else if(what == 16){
     178:	47c1                	li	a5,16
     17a:	2af50563          	beq	a0,a5,424 <go+0x3b0>
      if(sbrk(0) > break0)
        sbrk(-(sbrk(0) - break0));
    } else if(what == 17){
     17e:	47c5                	li	a5,17
     180:	2af50f63          	beq	a0,a5,43e <go+0x3ca>
        printf("grind: chdir failed\n");
        exit(1);
      }
      kill(pid);
      wait(0);
    } else if(what == 18){
     184:	47c9                	li	a5,18
     186:	30f50f63          	beq	a0,a5,4a4 <go+0x430>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 19){
     18a:	47cd                	li	a5,19
     18c:	34f50563          	beq	a0,a5,4d6 <go+0x462>
        exit(1);
      }
      close(fds[0]);
      close(fds[1]);
      wait(0);
    } else if(what == 20){
     190:	47d1                	li	a5,20
     192:	3ef50663          	beq	a0,a5,57e <go+0x50a>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 21){
     196:	47d5                	li	a5,21
     198:	44f50e63          	beq	a0,a5,5f4 <go+0x580>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
        exit(1);
      }
      close(fd1);
      unlink("c");
    } else if(what == 22){
     19c:	47d9                	li	a5,22
     19e:	f6f510e3          	bne	a0,a5,fe <go+0x8a>
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     1a2:	f9840513          	addi	a0,s0,-104
     1a6:	231000ef          	jal	ra,bd6 <pipe>
     1aa:	50054963          	bltz	a0,6bc <go+0x648>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      if(pipe(bb) < 0){
     1ae:	fa040513          	addi	a0,s0,-96
     1b2:	225000ef          	jal	ra,bd6 <pipe>
     1b6:	50054d63          	bltz	a0,6d0 <go+0x65c>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      int pid1 = fork();
     1ba:	205000ef          	jal	ra,bbe <fork>
      if(pid1 == 0){
     1be:	52050363          	beqz	a0,6e4 <go+0x670>
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "grind: echo: not found\n");
        exit(2);
      } else if(pid1 < 0){
     1c2:	5a054563          	bltz	a0,76c <go+0x6f8>
        fprintf(2, "grind: fork failed\n");
        exit(3);
      }
      int pid2 = fork();
     1c6:	1f9000ef          	jal	ra,bbe <fork>
      if(pid2 == 0){
     1ca:	5a050b63          	beqz	a0,780 <go+0x70c>
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "grind: cat: not found\n");
        exit(6);
      } else if(pid2 < 0){
     1ce:	64054963          	bltz	a0,820 <go+0x7ac>
        fprintf(2, "grind: fork failed\n");
        exit(7);
      }
      close(aa[0]);
     1d2:	f9842503          	lw	a0,-104(s0)
     1d6:	219000ef          	jal	ra,bee <close>
      close(aa[1]);
     1da:	f9c42503          	lw	a0,-100(s0)
     1de:	211000ef          	jal	ra,bee <close>
      close(bb[1]);
     1e2:	fa442503          	lw	a0,-92(s0)
     1e6:	209000ef          	jal	ra,bee <close>
      char buf[4] = { 0, 0, 0, 0 };
     1ea:	f8042823          	sw	zero,-112(s0)
      read(bb[0], buf+0, 1);
     1ee:	4605                	li	a2,1
     1f0:	f9040593          	addi	a1,s0,-112
     1f4:	fa042503          	lw	a0,-96(s0)
     1f8:	1e7000ef          	jal	ra,bde <read>
      read(bb[0], buf+1, 1);
     1fc:	4605                	li	a2,1
     1fe:	f9140593          	addi	a1,s0,-111
     202:	fa042503          	lw	a0,-96(s0)
     206:	1d9000ef          	jal	ra,bde <read>
      read(bb[0], buf+2, 1);
     20a:	4605                	li	a2,1
     20c:	f9240593          	addi	a1,s0,-110
     210:	fa042503          	lw	a0,-96(s0)
     214:	1cb000ef          	jal	ra,bde <read>
      close(bb[0]);
     218:	fa042503          	lw	a0,-96(s0)
     21c:	1d3000ef          	jal	ra,bee <close>
      int st1, st2;
      wait(&st1);
     220:	f9440513          	addi	a0,s0,-108
     224:	1ab000ef          	jal	ra,bce <wait>
      wait(&st2);
     228:	fa840513          	addi	a0,s0,-88
     22c:	1a3000ef          	jal	ra,bce <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi\n") != 0){
     230:	f9442783          	lw	a5,-108(s0)
     234:	fa842703          	lw	a4,-88(s0)
     238:	8fd9                	or	a5,a5,a4
     23a:	2781                	sext.w	a5,a5
     23c:	eb99                	bnez	a5,252 <go+0x1de>
     23e:	00001597          	auipc	a1,0x1
     242:	1fa58593          	addi	a1,a1,506 # 1438 <malloc+0x39c>
     246:	f9040513          	addi	a0,s0,-112
     24a:	712000ef          	jal	ra,95c <strcmp>
     24e:	ea0508e3          	beqz	a0,fe <go+0x8a>
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     252:	f9040693          	addi	a3,s0,-112
     256:	fa842603          	lw	a2,-88(s0)
     25a:	f9442583          	lw	a1,-108(s0)
     25e:	00001517          	auipc	a0,0x1
     262:	1e250513          	addi	a0,a0,482 # 1440 <malloc+0x3a4>
     266:	57d000ef          	jal	ra,fe2 <printf>
        exit(1);
     26a:	4505                	li	a0,1
     26c:	15b000ef          	jal	ra,bc6 <exit>
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     270:	20200593          	li	a1,514
     274:	00001517          	auipc	a0,0x1
     278:	f5c50513          	addi	a0,a0,-164 # 11d0 <malloc+0x134>
     27c:	18b000ef          	jal	ra,c06 <open>
     280:	16f000ef          	jal	ra,bee <close>
     284:	bdad                	j	fe <go+0x8a>
      unlink("grindir/../a");
     286:	00001517          	auipc	a0,0x1
     28a:	f3a50513          	addi	a0,a0,-198 # 11c0 <malloc+0x124>
     28e:	189000ef          	jal	ra,c16 <unlink>
     292:	b5b5                	j	fe <go+0x8a>
      if(chdir("grindir") != 0){
     294:	00001517          	auipc	a0,0x1
     298:	eec50513          	addi	a0,a0,-276 # 1180 <malloc+0xe4>
     29c:	19b000ef          	jal	ra,c36 <chdir>
     2a0:	ed11                	bnez	a0,2bc <go+0x248>
      unlink("../b");
     2a2:	00001517          	auipc	a0,0x1
     2a6:	f4650513          	addi	a0,a0,-186 # 11e8 <malloc+0x14c>
     2aa:	16d000ef          	jal	ra,c16 <unlink>
      chdir("/");
     2ae:	00001517          	auipc	a0,0x1
     2b2:	efa50513          	addi	a0,a0,-262 # 11a8 <malloc+0x10c>
     2b6:	181000ef          	jal	ra,c36 <chdir>
     2ba:	b591                	j	fe <go+0x8a>
        printf("grind: chdir grindir failed\n");
     2bc:	00001517          	auipc	a0,0x1
     2c0:	ecc50513          	addi	a0,a0,-308 # 1188 <malloc+0xec>
     2c4:	51f000ef          	jal	ra,fe2 <printf>
        exit(1);
     2c8:	4505                	li	a0,1
     2ca:	0fd000ef          	jal	ra,bc6 <exit>
      close(fd);
     2ce:	854a                	mv	a0,s2
     2d0:	11f000ef          	jal	ra,bee <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     2d4:	20200593          	li	a1,514
     2d8:	00001517          	auipc	a0,0x1
     2dc:	f1850513          	addi	a0,a0,-232 # 11f0 <malloc+0x154>
     2e0:	127000ef          	jal	ra,c06 <open>
     2e4:	892a                	mv	s2,a0
     2e6:	bd21                	j	fe <go+0x8a>
      close(fd);
     2e8:	854a                	mv	a0,s2
     2ea:	105000ef          	jal	ra,bee <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     2ee:	20200593          	li	a1,514
     2f2:	00001517          	auipc	a0,0x1
     2f6:	f0e50513          	addi	a0,a0,-242 # 1200 <malloc+0x164>
     2fa:	10d000ef          	jal	ra,c06 <open>
     2fe:	892a                	mv	s2,a0
     300:	bbfd                	j	fe <go+0x8a>
      write(fd, buf, sizeof(buf));
     302:	3e700613          	li	a2,999
     306:	85d2                	mv	a1,s4
     308:	854a                	mv	a0,s2
     30a:	0dd000ef          	jal	ra,be6 <write>
     30e:	bbc5                	j	fe <go+0x8a>
      read(fd, buf, sizeof(buf));
     310:	3e700613          	li	a2,999
     314:	85d2                	mv	a1,s4
     316:	854a                	mv	a0,s2
     318:	0c7000ef          	jal	ra,bde <read>
     31c:	b3cd                	j	fe <go+0x8a>
      mkdir("grindir/../a");
     31e:	00001517          	auipc	a0,0x1
     322:	ea250513          	addi	a0,a0,-350 # 11c0 <malloc+0x124>
     326:	109000ef          	jal	ra,c2e <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     32a:	20200593          	li	a1,514
     32e:	00001517          	auipc	a0,0x1
     332:	eea50513          	addi	a0,a0,-278 # 1218 <malloc+0x17c>
     336:	0d1000ef          	jal	ra,c06 <open>
     33a:	0b5000ef          	jal	ra,bee <close>
      unlink("a/a");
     33e:	00001517          	auipc	a0,0x1
     342:	eea50513          	addi	a0,a0,-278 # 1228 <malloc+0x18c>
     346:	0d1000ef          	jal	ra,c16 <unlink>
     34a:	bb55                	j	fe <go+0x8a>
      mkdir("/../b");
     34c:	00001517          	auipc	a0,0x1
     350:	ee450513          	addi	a0,a0,-284 # 1230 <malloc+0x194>
     354:	0db000ef          	jal	ra,c2e <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     358:	20200593          	li	a1,514
     35c:	00001517          	auipc	a0,0x1
     360:	edc50513          	addi	a0,a0,-292 # 1238 <malloc+0x19c>
     364:	0a3000ef          	jal	ra,c06 <open>
     368:	087000ef          	jal	ra,bee <close>
      unlink("b/b");
     36c:	00001517          	auipc	a0,0x1
     370:	edc50513          	addi	a0,a0,-292 # 1248 <malloc+0x1ac>
     374:	0a3000ef          	jal	ra,c16 <unlink>
     378:	b359                	j	fe <go+0x8a>
      unlink("b");
     37a:	00001517          	auipc	a0,0x1
     37e:	e9650513          	addi	a0,a0,-362 # 1210 <malloc+0x174>
     382:	095000ef          	jal	ra,c16 <unlink>
      link("../grindir/./../a", "../b");
     386:	00001597          	auipc	a1,0x1
     38a:	e6258593          	addi	a1,a1,-414 # 11e8 <malloc+0x14c>
     38e:	00001517          	auipc	a0,0x1
     392:	ec250513          	addi	a0,a0,-318 # 1250 <malloc+0x1b4>
     396:	091000ef          	jal	ra,c26 <link>
     39a:	b395                	j	fe <go+0x8a>
      unlink("../grindir/../a");
     39c:	00001517          	auipc	a0,0x1
     3a0:	ecc50513          	addi	a0,a0,-308 # 1268 <malloc+0x1cc>
     3a4:	073000ef          	jal	ra,c16 <unlink>
      link(".././b", "/grindir/../a");
     3a8:	00001597          	auipc	a1,0x1
     3ac:	e4858593          	addi	a1,a1,-440 # 11f0 <malloc+0x154>
     3b0:	00001517          	auipc	a0,0x1
     3b4:	ec850513          	addi	a0,a0,-312 # 1278 <malloc+0x1dc>
     3b8:	06f000ef          	jal	ra,c26 <link>
     3bc:	b389                	j	fe <go+0x8a>
      int pid = fork();
     3be:	001000ef          	jal	ra,bbe <fork>
      if(pid == 0){
     3c2:	c519                	beqz	a0,3d0 <go+0x35c>
      } else if(pid < 0){
     3c4:	00054863          	bltz	a0,3d4 <go+0x360>
      wait(0);
     3c8:	4501                	li	a0,0
     3ca:	005000ef          	jal	ra,bce <wait>
     3ce:	bb05                	j	fe <go+0x8a>
        exit(0);
     3d0:	7f6000ef          	jal	ra,bc6 <exit>
        printf("grind: fork failed\n");
     3d4:	00001517          	auipc	a0,0x1
     3d8:	eac50513          	addi	a0,a0,-340 # 1280 <malloc+0x1e4>
     3dc:	407000ef          	jal	ra,fe2 <printf>
        exit(1);
     3e0:	4505                	li	a0,1
     3e2:	7e4000ef          	jal	ra,bc6 <exit>
      int pid = fork();
     3e6:	7d8000ef          	jal	ra,bbe <fork>
      if(pid == 0){
     3ea:	c519                	beqz	a0,3f8 <go+0x384>
      } else if(pid < 0){
     3ec:	00054d63          	bltz	a0,406 <go+0x392>
      wait(0);
     3f0:	4501                	li	a0,0
     3f2:	7dc000ef          	jal	ra,bce <wait>
     3f6:	b321                	j	fe <go+0x8a>
        fork();
     3f8:	7c6000ef          	jal	ra,bbe <fork>
        fork();
     3fc:	7c2000ef          	jal	ra,bbe <fork>
        exit(0);
     400:	4501                	li	a0,0
     402:	7c4000ef          	jal	ra,bc6 <exit>
        printf("grind: fork failed\n");
     406:	00001517          	auipc	a0,0x1
     40a:	e7a50513          	addi	a0,a0,-390 # 1280 <malloc+0x1e4>
     40e:	3d5000ef          	jal	ra,fe2 <printf>
        exit(1);
     412:	4505                	li	a0,1
     414:	7b2000ef          	jal	ra,bc6 <exit>
      sbrk(6011);
     418:	6505                	lui	a0,0x1
     41a:	77b50513          	addi	a0,a0,1915 # 177b <digits+0x30b>
     41e:	774000ef          	jal	ra,b92 <sbrk>
     422:	b9f1                	j	fe <go+0x8a>
      if(sbrk(0) > break0)
     424:	4501                	li	a0,0
     426:	76c000ef          	jal	ra,b92 <sbrk>
     42a:	ccaafae3          	bgeu	s5,a0,fe <go+0x8a>
        sbrk(-(sbrk(0) - break0));
     42e:	4501                	li	a0,0
     430:	762000ef          	jal	ra,b92 <sbrk>
     434:	40aa853b          	subw	a0,s5,a0
     438:	75a000ef          	jal	ra,b92 <sbrk>
     43c:	b1c9                	j	fe <go+0x8a>
      int pid = fork();
     43e:	780000ef          	jal	ra,bbe <fork>
     442:	8b2a                	mv	s6,a0
      if(pid == 0){
     444:	c10d                	beqz	a0,466 <go+0x3f2>
      } else if(pid < 0){
     446:	02054d63          	bltz	a0,480 <go+0x40c>
      if(chdir("../grindir/..") != 0){
     44a:	00001517          	auipc	a0,0x1
     44e:	e4e50513          	addi	a0,a0,-434 # 1298 <malloc+0x1fc>
     452:	7e4000ef          	jal	ra,c36 <chdir>
     456:	ed15                	bnez	a0,492 <go+0x41e>
      kill(pid);
     458:	855a                	mv	a0,s6
     45a:	79c000ef          	jal	ra,bf6 <kill>
      wait(0);
     45e:	4501                	li	a0,0
     460:	76e000ef          	jal	ra,bce <wait>
     464:	b969                	j	fe <go+0x8a>
        close(open("a", O_CREATE|O_RDWR));
     466:	20200593          	li	a1,514
     46a:	00001517          	auipc	a0,0x1
     46e:	df650513          	addi	a0,a0,-522 # 1260 <malloc+0x1c4>
     472:	794000ef          	jal	ra,c06 <open>
     476:	778000ef          	jal	ra,bee <close>
        exit(0);
     47a:	4501                	li	a0,0
     47c:	74a000ef          	jal	ra,bc6 <exit>
        printf("grind: fork failed\n");
     480:	00001517          	auipc	a0,0x1
     484:	e0050513          	addi	a0,a0,-512 # 1280 <malloc+0x1e4>
     488:	35b000ef          	jal	ra,fe2 <printf>
        exit(1);
     48c:	4505                	li	a0,1
     48e:	738000ef          	jal	ra,bc6 <exit>
        printf("grind: chdir failed\n");
     492:	00001517          	auipc	a0,0x1
     496:	e1650513          	addi	a0,a0,-490 # 12a8 <malloc+0x20c>
     49a:	349000ef          	jal	ra,fe2 <printf>
        exit(1);
     49e:	4505                	li	a0,1
     4a0:	726000ef          	jal	ra,bc6 <exit>
      int pid = fork();
     4a4:	71a000ef          	jal	ra,bbe <fork>
      if(pid == 0){
     4a8:	c519                	beqz	a0,4b6 <go+0x442>
      } else if(pid < 0){
     4aa:	00054d63          	bltz	a0,4c4 <go+0x450>
      wait(0);
     4ae:	4501                	li	a0,0
     4b0:	71e000ef          	jal	ra,bce <wait>
     4b4:	b1a9                	j	fe <go+0x8a>
        kill(getpid());
     4b6:	790000ef          	jal	ra,c46 <getpid>
     4ba:	73c000ef          	jal	ra,bf6 <kill>
        exit(0);
     4be:	4501                	li	a0,0
     4c0:	706000ef          	jal	ra,bc6 <exit>
        printf("grind: fork failed\n");
     4c4:	00001517          	auipc	a0,0x1
     4c8:	dbc50513          	addi	a0,a0,-580 # 1280 <malloc+0x1e4>
     4cc:	317000ef          	jal	ra,fe2 <printf>
        exit(1);
     4d0:	4505                	li	a0,1
     4d2:	6f4000ef          	jal	ra,bc6 <exit>
      if(pipe(fds) < 0){
     4d6:	fa840513          	addi	a0,s0,-88
     4da:	6fc000ef          	jal	ra,bd6 <pipe>
     4de:	02054363          	bltz	a0,504 <go+0x490>
      int pid = fork();
     4e2:	6dc000ef          	jal	ra,bbe <fork>
      if(pid == 0){
     4e6:	c905                	beqz	a0,516 <go+0x4a2>
      } else if(pid < 0){
     4e8:	08054263          	bltz	a0,56c <go+0x4f8>
      close(fds[0]);
     4ec:	fa842503          	lw	a0,-88(s0)
     4f0:	6fe000ef          	jal	ra,bee <close>
      close(fds[1]);
     4f4:	fac42503          	lw	a0,-84(s0)
     4f8:	6f6000ef          	jal	ra,bee <close>
      wait(0);
     4fc:	4501                	li	a0,0
     4fe:	6d0000ef          	jal	ra,bce <wait>
     502:	bef5                	j	fe <go+0x8a>
        printf("grind: pipe failed\n");
     504:	00001517          	auipc	a0,0x1
     508:	dbc50513          	addi	a0,a0,-580 # 12c0 <malloc+0x224>
     50c:	2d7000ef          	jal	ra,fe2 <printf>
        exit(1);
     510:	4505                	li	a0,1
     512:	6b4000ef          	jal	ra,bc6 <exit>
        fork();
     516:	6a8000ef          	jal	ra,bbe <fork>
        fork();
     51a:	6a4000ef          	jal	ra,bbe <fork>
        if(write(fds[1], "x", 1) != 1)
     51e:	4605                	li	a2,1
     520:	00001597          	auipc	a1,0x1
     524:	db858593          	addi	a1,a1,-584 # 12d8 <malloc+0x23c>
     528:	fac42503          	lw	a0,-84(s0)
     52c:	6ba000ef          	jal	ra,be6 <write>
     530:	4785                	li	a5,1
     532:	00f51f63          	bne	a0,a5,550 <go+0x4dc>
        if(read(fds[0], &c, 1) != 1)
     536:	4605                	li	a2,1
     538:	fa040593          	addi	a1,s0,-96
     53c:	fa842503          	lw	a0,-88(s0)
     540:	69e000ef          	jal	ra,bde <read>
     544:	4785                	li	a5,1
     546:	00f51c63          	bne	a0,a5,55e <go+0x4ea>
        exit(0);
     54a:	4501                	li	a0,0
     54c:	67a000ef          	jal	ra,bc6 <exit>
          printf("grind: pipe write failed\n");
     550:	00001517          	auipc	a0,0x1
     554:	d9050513          	addi	a0,a0,-624 # 12e0 <malloc+0x244>
     558:	28b000ef          	jal	ra,fe2 <printf>
     55c:	bfe9                	j	536 <go+0x4c2>
          printf("grind: pipe read failed\n");
     55e:	00001517          	auipc	a0,0x1
     562:	da250513          	addi	a0,a0,-606 # 1300 <malloc+0x264>
     566:	27d000ef          	jal	ra,fe2 <printf>
     56a:	b7c5                	j	54a <go+0x4d6>
        printf("grind: fork failed\n");
     56c:	00001517          	auipc	a0,0x1
     570:	d1450513          	addi	a0,a0,-748 # 1280 <malloc+0x1e4>
     574:	26f000ef          	jal	ra,fe2 <printf>
        exit(1);
     578:	4505                	li	a0,1
     57a:	64c000ef          	jal	ra,bc6 <exit>
      int pid = fork();
     57e:	640000ef          	jal	ra,bbe <fork>
      if(pid == 0){
     582:	c519                	beqz	a0,590 <go+0x51c>
      } else if(pid < 0){
     584:	04054f63          	bltz	a0,5e2 <go+0x56e>
      wait(0);
     588:	4501                	li	a0,0
     58a:	644000ef          	jal	ra,bce <wait>
     58e:	be85                	j	fe <go+0x8a>
        unlink("a");
     590:	00001517          	auipc	a0,0x1
     594:	cd050513          	addi	a0,a0,-816 # 1260 <malloc+0x1c4>
     598:	67e000ef          	jal	ra,c16 <unlink>
        mkdir("a");
     59c:	00001517          	auipc	a0,0x1
     5a0:	cc450513          	addi	a0,a0,-828 # 1260 <malloc+0x1c4>
     5a4:	68a000ef          	jal	ra,c2e <mkdir>
        chdir("a");
     5a8:	00001517          	auipc	a0,0x1
     5ac:	cb850513          	addi	a0,a0,-840 # 1260 <malloc+0x1c4>
     5b0:	686000ef          	jal	ra,c36 <chdir>
        unlink("../a");
     5b4:	00001517          	auipc	a0,0x1
     5b8:	c1450513          	addi	a0,a0,-1004 # 11c8 <malloc+0x12c>
     5bc:	65a000ef          	jal	ra,c16 <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     5c0:	20200593          	li	a1,514
     5c4:	00001517          	auipc	a0,0x1
     5c8:	d1450513          	addi	a0,a0,-748 # 12d8 <malloc+0x23c>
     5cc:	63a000ef          	jal	ra,c06 <open>
        unlink("x");
     5d0:	00001517          	auipc	a0,0x1
     5d4:	d0850513          	addi	a0,a0,-760 # 12d8 <malloc+0x23c>
     5d8:	63e000ef          	jal	ra,c16 <unlink>
        exit(0);
     5dc:	4501                	li	a0,0
     5de:	5e8000ef          	jal	ra,bc6 <exit>
        printf("grind: fork failed\n");
     5e2:	00001517          	auipc	a0,0x1
     5e6:	c9e50513          	addi	a0,a0,-866 # 1280 <malloc+0x1e4>
     5ea:	1f9000ef          	jal	ra,fe2 <printf>
        exit(1);
     5ee:	4505                	li	a0,1
     5f0:	5d6000ef          	jal	ra,bc6 <exit>
      unlink("c");
     5f4:	00001517          	auipc	a0,0x1
     5f8:	d2c50513          	addi	a0,a0,-724 # 1320 <malloc+0x284>
     5fc:	61a000ef          	jal	ra,c16 <unlink>
      int fd1 = open("c", O_CREATE|O_RDWR);
     600:	20200593          	li	a1,514
     604:	00001517          	auipc	a0,0x1
     608:	d1c50513          	addi	a0,a0,-740 # 1320 <malloc+0x284>
     60c:	5fa000ef          	jal	ra,c06 <open>
     610:	8b2a                	mv	s6,a0
      if(fd1 < 0){
     612:	04054763          	bltz	a0,660 <go+0x5ec>
      if(write(fd1, "x", 1) != 1){
     616:	4605                	li	a2,1
     618:	00001597          	auipc	a1,0x1
     61c:	cc058593          	addi	a1,a1,-832 # 12d8 <malloc+0x23c>
     620:	5c6000ef          	jal	ra,be6 <write>
     624:	4785                	li	a5,1
     626:	04f51663          	bne	a0,a5,672 <go+0x5fe>
      if(fstat(fd1, &st) != 0){
     62a:	fa840593          	addi	a1,s0,-88
     62e:	855a                	mv	a0,s6
     630:	5ee000ef          	jal	ra,c1e <fstat>
     634:	e921                	bnez	a0,684 <go+0x610>
      if(st.size != 1){
     636:	fb843583          	ld	a1,-72(s0)
     63a:	4785                	li	a5,1
     63c:	04f59d63          	bne	a1,a5,696 <go+0x622>
      if(st.ino > 200){
     640:	fac42583          	lw	a1,-84(s0)
     644:	0c800793          	li	a5,200
     648:	06b7e163          	bltu	a5,a1,6aa <go+0x636>
      close(fd1);
     64c:	855a                	mv	a0,s6
     64e:	5a0000ef          	jal	ra,bee <close>
      unlink("c");
     652:	00001517          	auipc	a0,0x1
     656:	cce50513          	addi	a0,a0,-818 # 1320 <malloc+0x284>
     65a:	5bc000ef          	jal	ra,c16 <unlink>
     65e:	b445                	j	fe <go+0x8a>
        printf("grind: create c failed\n");
     660:	00001517          	auipc	a0,0x1
     664:	cc850513          	addi	a0,a0,-824 # 1328 <malloc+0x28c>
     668:	17b000ef          	jal	ra,fe2 <printf>
        exit(1);
     66c:	4505                	li	a0,1
     66e:	558000ef          	jal	ra,bc6 <exit>
        printf("grind: write c failed\n");
     672:	00001517          	auipc	a0,0x1
     676:	cce50513          	addi	a0,a0,-818 # 1340 <malloc+0x2a4>
     67a:	169000ef          	jal	ra,fe2 <printf>
        exit(1);
     67e:	4505                	li	a0,1
     680:	546000ef          	jal	ra,bc6 <exit>
        printf("grind: fstat failed\n");
     684:	00001517          	auipc	a0,0x1
     688:	cd450513          	addi	a0,a0,-812 # 1358 <malloc+0x2bc>
     68c:	157000ef          	jal	ra,fe2 <printf>
        exit(1);
     690:	4505                	li	a0,1
     692:	534000ef          	jal	ra,bc6 <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     696:	2581                	sext.w	a1,a1
     698:	00001517          	auipc	a0,0x1
     69c:	cd850513          	addi	a0,a0,-808 # 1370 <malloc+0x2d4>
     6a0:	143000ef          	jal	ra,fe2 <printf>
        exit(1);
     6a4:	4505                	li	a0,1
     6a6:	520000ef          	jal	ra,bc6 <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     6aa:	00001517          	auipc	a0,0x1
     6ae:	cee50513          	addi	a0,a0,-786 # 1398 <malloc+0x2fc>
     6b2:	131000ef          	jal	ra,fe2 <printf>
        exit(1);
     6b6:	4505                	li	a0,1
     6b8:	50e000ef          	jal	ra,bc6 <exit>
        fprintf(2, "grind: pipe failed\n");
     6bc:	00001597          	auipc	a1,0x1
     6c0:	c0458593          	addi	a1,a1,-1020 # 12c0 <malloc+0x224>
     6c4:	4509                	li	a0,2
     6c6:	0f3000ef          	jal	ra,fb8 <fprintf>
        exit(1);
     6ca:	4505                	li	a0,1
     6cc:	4fa000ef          	jal	ra,bc6 <exit>
        fprintf(2, "grind: pipe failed\n");
     6d0:	00001597          	auipc	a1,0x1
     6d4:	bf058593          	addi	a1,a1,-1040 # 12c0 <malloc+0x224>
     6d8:	4509                	li	a0,2
     6da:	0df000ef          	jal	ra,fb8 <fprintf>
        exit(1);
     6de:	4505                	li	a0,1
     6e0:	4e6000ef          	jal	ra,bc6 <exit>
        close(bb[0]);
     6e4:	fa042503          	lw	a0,-96(s0)
     6e8:	506000ef          	jal	ra,bee <close>
        close(bb[1]);
     6ec:	fa442503          	lw	a0,-92(s0)
     6f0:	4fe000ef          	jal	ra,bee <close>
        close(aa[0]);
     6f4:	f9842503          	lw	a0,-104(s0)
     6f8:	4f6000ef          	jal	ra,bee <close>
        close(1);
     6fc:	4505                	li	a0,1
     6fe:	4f0000ef          	jal	ra,bee <close>
        if(dup(aa[1]) != 1){
     702:	f9c42503          	lw	a0,-100(s0)
     706:	538000ef          	jal	ra,c3e <dup>
     70a:	4785                	li	a5,1
     70c:	00f50c63          	beq	a0,a5,724 <go+0x6b0>
          fprintf(2, "grind: dup failed\n");
     710:	00001597          	auipc	a1,0x1
     714:	cb058593          	addi	a1,a1,-848 # 13c0 <malloc+0x324>
     718:	4509                	li	a0,2
     71a:	09f000ef          	jal	ra,fb8 <fprintf>
          exit(1);
     71e:	4505                	li	a0,1
     720:	4a6000ef          	jal	ra,bc6 <exit>
        close(aa[1]);
     724:	f9c42503          	lw	a0,-100(s0)
     728:	4c6000ef          	jal	ra,bee <close>
        char *args[3] = { "echo", "hi", 0 };
     72c:	00001797          	auipc	a5,0x1
     730:	cac78793          	addi	a5,a5,-852 # 13d8 <malloc+0x33c>
     734:	faf43423          	sd	a5,-88(s0)
     738:	00001797          	auipc	a5,0x1
     73c:	ca878793          	addi	a5,a5,-856 # 13e0 <malloc+0x344>
     740:	faf43823          	sd	a5,-80(s0)
     744:	fa043c23          	sd	zero,-72(s0)
        exec("grindir/../echo", args);
     748:	fa840593          	addi	a1,s0,-88
     74c:	00001517          	auipc	a0,0x1
     750:	c9c50513          	addi	a0,a0,-868 # 13e8 <malloc+0x34c>
     754:	4aa000ef          	jal	ra,bfe <exec>
        fprintf(2, "grind: echo: not found\n");
     758:	00001597          	auipc	a1,0x1
     75c:	ca058593          	addi	a1,a1,-864 # 13f8 <malloc+0x35c>
     760:	4509                	li	a0,2
     762:	057000ef          	jal	ra,fb8 <fprintf>
        exit(2);
     766:	4509                	li	a0,2
     768:	45e000ef          	jal	ra,bc6 <exit>
        fprintf(2, "grind: fork failed\n");
     76c:	00001597          	auipc	a1,0x1
     770:	b1458593          	addi	a1,a1,-1260 # 1280 <malloc+0x1e4>
     774:	4509                	li	a0,2
     776:	043000ef          	jal	ra,fb8 <fprintf>
        exit(3);
     77a:	450d                	li	a0,3
     77c:	44a000ef          	jal	ra,bc6 <exit>
        close(aa[1]);
     780:	f9c42503          	lw	a0,-100(s0)
     784:	46a000ef          	jal	ra,bee <close>
        close(bb[0]);
     788:	fa042503          	lw	a0,-96(s0)
     78c:	462000ef          	jal	ra,bee <close>
        close(0);
     790:	4501                	li	a0,0
     792:	45c000ef          	jal	ra,bee <close>
        if(dup(aa[0]) != 0){
     796:	f9842503          	lw	a0,-104(s0)
     79a:	4a4000ef          	jal	ra,c3e <dup>
     79e:	c919                	beqz	a0,7b4 <go+0x740>
          fprintf(2, "grind: dup failed\n");
     7a0:	00001597          	auipc	a1,0x1
     7a4:	c2058593          	addi	a1,a1,-992 # 13c0 <malloc+0x324>
     7a8:	4509                	li	a0,2
     7aa:	00f000ef          	jal	ra,fb8 <fprintf>
          exit(4);
     7ae:	4511                	li	a0,4
     7b0:	416000ef          	jal	ra,bc6 <exit>
        close(aa[0]);
     7b4:	f9842503          	lw	a0,-104(s0)
     7b8:	436000ef          	jal	ra,bee <close>
        close(1);
     7bc:	4505                	li	a0,1
     7be:	430000ef          	jal	ra,bee <close>
        if(dup(bb[1]) != 1){
     7c2:	fa442503          	lw	a0,-92(s0)
     7c6:	478000ef          	jal	ra,c3e <dup>
     7ca:	4785                	li	a5,1
     7cc:	00f50c63          	beq	a0,a5,7e4 <go+0x770>
          fprintf(2, "grind: dup failed\n");
     7d0:	00001597          	auipc	a1,0x1
     7d4:	bf058593          	addi	a1,a1,-1040 # 13c0 <malloc+0x324>
     7d8:	4509                	li	a0,2
     7da:	7de000ef          	jal	ra,fb8 <fprintf>
          exit(5);
     7de:	4515                	li	a0,5
     7e0:	3e6000ef          	jal	ra,bc6 <exit>
        close(bb[1]);
     7e4:	fa442503          	lw	a0,-92(s0)
     7e8:	406000ef          	jal	ra,bee <close>
        char *args[2] = { "cat", 0 };
     7ec:	00001797          	auipc	a5,0x1
     7f0:	c2478793          	addi	a5,a5,-988 # 1410 <malloc+0x374>
     7f4:	faf43423          	sd	a5,-88(s0)
     7f8:	fa043823          	sd	zero,-80(s0)
        exec("/cat", args);
     7fc:	fa840593          	addi	a1,s0,-88
     800:	00001517          	auipc	a0,0x1
     804:	c1850513          	addi	a0,a0,-1000 # 1418 <malloc+0x37c>
     808:	3f6000ef          	jal	ra,bfe <exec>
        fprintf(2, "grind: cat: not found\n");
     80c:	00001597          	auipc	a1,0x1
     810:	c1458593          	addi	a1,a1,-1004 # 1420 <malloc+0x384>
     814:	4509                	li	a0,2
     816:	7a2000ef          	jal	ra,fb8 <fprintf>
        exit(6);
     81a:	4519                	li	a0,6
     81c:	3aa000ef          	jal	ra,bc6 <exit>
        fprintf(2, "grind: fork failed\n");
     820:	00001597          	auipc	a1,0x1
     824:	a6058593          	addi	a1,a1,-1440 # 1280 <malloc+0x1e4>
     828:	4509                	li	a0,2
     82a:	78e000ef          	jal	ra,fb8 <fprintf>
        exit(7);
     82e:	451d                	li	a0,7
     830:	396000ef          	jal	ra,bc6 <exit>

0000000000000834 <iter>:
  }
}

void
iter()
{
     834:	7179                	addi	sp,sp,-48
     836:	f406                	sd	ra,40(sp)
     838:	f022                	sd	s0,32(sp)
     83a:	ec26                	sd	s1,24(sp)
     83c:	e84a                	sd	s2,16(sp)
     83e:	1800                	addi	s0,sp,48
  unlink("a");
     840:	00001517          	auipc	a0,0x1
     844:	a2050513          	addi	a0,a0,-1504 # 1260 <malloc+0x1c4>
     848:	3ce000ef          	jal	ra,c16 <unlink>
  unlink("b");
     84c:	00001517          	auipc	a0,0x1
     850:	9c450513          	addi	a0,a0,-1596 # 1210 <malloc+0x174>
     854:	3c2000ef          	jal	ra,c16 <unlink>
  
  int pid1 = fork();
     858:	366000ef          	jal	ra,bbe <fork>
  if(pid1 < 0){
     85c:	00054f63          	bltz	a0,87a <iter+0x46>
     860:	84aa                	mv	s1,a0
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid1 == 0){
     862:	e50d                	bnez	a0,88c <iter+0x58>
    rand_next ^= 31;
     864:	00001717          	auipc	a4,0x1
     868:	79c70713          	addi	a4,a4,1948 # 2000 <rand_next>
     86c:	631c                	ld	a5,0(a4)
     86e:	01f7c793          	xori	a5,a5,31
     872:	e31c                	sd	a5,0(a4)
    go(0);
     874:	4501                	li	a0,0
     876:	ffeff0ef          	jal	ra,74 <go>
    printf("grind: fork failed\n");
     87a:	00001517          	auipc	a0,0x1
     87e:	a0650513          	addi	a0,a0,-1530 # 1280 <malloc+0x1e4>
     882:	760000ef          	jal	ra,fe2 <printf>
    exit(1);
     886:	4505                	li	a0,1
     888:	33e000ef          	jal	ra,bc6 <exit>
    exit(0);
  }

  int pid2 = fork();
     88c:	332000ef          	jal	ra,bbe <fork>
     890:	892a                	mv	s2,a0
  if(pid2 < 0){
     892:	02054063          	bltz	a0,8b2 <iter+0x7e>
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid2 == 0){
     896:	e51d                	bnez	a0,8c4 <iter+0x90>
    rand_next ^= 7177;
     898:	00001697          	auipc	a3,0x1
     89c:	76868693          	addi	a3,a3,1896 # 2000 <rand_next>
     8a0:	629c                	ld	a5,0(a3)
     8a2:	6709                	lui	a4,0x2
     8a4:	c0970713          	addi	a4,a4,-1015 # 1c09 <digits+0x799>
     8a8:	8fb9                	xor	a5,a5,a4
     8aa:	e29c                	sd	a5,0(a3)
    go(1);
     8ac:	4505                	li	a0,1
     8ae:	fc6ff0ef          	jal	ra,74 <go>
    printf("grind: fork failed\n");
     8b2:	00001517          	auipc	a0,0x1
     8b6:	9ce50513          	addi	a0,a0,-1586 # 1280 <malloc+0x1e4>
     8ba:	728000ef          	jal	ra,fe2 <printf>
    exit(1);
     8be:	4505                	li	a0,1
     8c0:	306000ef          	jal	ra,bc6 <exit>
    exit(0);
  }

  int st1 = -1;
     8c4:	57fd                	li	a5,-1
     8c6:	fcf42e23          	sw	a5,-36(s0)
  wait(&st1);
     8ca:	fdc40513          	addi	a0,s0,-36
     8ce:	300000ef          	jal	ra,bce <wait>
  if(st1 != 0){
     8d2:	fdc42783          	lw	a5,-36(s0)
     8d6:	eb99                	bnez	a5,8ec <iter+0xb8>
    kill(pid1);
    kill(pid2);
  }
  int st2 = -1;
     8d8:	57fd                	li	a5,-1
     8da:	fcf42c23          	sw	a5,-40(s0)
  wait(&st2);
     8de:	fd840513          	addi	a0,s0,-40
     8e2:	2ec000ef          	jal	ra,bce <wait>

  exit(0);
     8e6:	4501                	li	a0,0
     8e8:	2de000ef          	jal	ra,bc6 <exit>
    kill(pid1);
     8ec:	8526                	mv	a0,s1
     8ee:	308000ef          	jal	ra,bf6 <kill>
    kill(pid2);
     8f2:	854a                	mv	a0,s2
     8f4:	302000ef          	jal	ra,bf6 <kill>
     8f8:	b7c5                	j	8d8 <iter+0xa4>

00000000000008fa <main>:
}

int
main()
{
     8fa:	1101                	addi	sp,sp,-32
     8fc:	ec06                	sd	ra,24(sp)
     8fe:	e822                	sd	s0,16(sp)
     900:	e426                	sd	s1,8(sp)
     902:	1000                	addi	s0,sp,32
    }
    if(pid > 0){
      wait(0);
    }
    pause(20);
    rand_next += 1;
     904:	00001497          	auipc	s1,0x1
     908:	6fc48493          	addi	s1,s1,1788 # 2000 <rand_next>
     90c:	a809                	j	91e <main+0x24>
      iter();
     90e:	f27ff0ef          	jal	ra,834 <iter>
    pause(20);
     912:	4551                	li	a0,20
     914:	342000ef          	jal	ra,c56 <pause>
    rand_next += 1;
     918:	609c                	ld	a5,0(s1)
     91a:	0785                	addi	a5,a5,1
     91c:	e09c                	sd	a5,0(s1)
    int pid = fork();
     91e:	2a0000ef          	jal	ra,bbe <fork>
    if(pid == 0){
     922:	d575                	beqz	a0,90e <main+0x14>
    if(pid > 0){
     924:	fea057e3          	blez	a0,912 <main+0x18>
      wait(0);
     928:	4501                	li	a0,0
     92a:	2a4000ef          	jal	ra,bce <wait>
     92e:	b7d5                	j	912 <main+0x18>

0000000000000930 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
     930:	1141                	addi	sp,sp,-16
     932:	e406                	sd	ra,8(sp)
     934:	e022                	sd	s0,0(sp)
     936:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
     938:	fc3ff0ef          	jal	ra,8fa <main>
  exit(r);
     93c:	28a000ef          	jal	ra,bc6 <exit>

0000000000000940 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     940:	1141                	addi	sp,sp,-16
     942:	e422                	sd	s0,8(sp)
     944:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     946:	87aa                	mv	a5,a0
     948:	0585                	addi	a1,a1,1
     94a:	0785                	addi	a5,a5,1
     94c:	fff5c703          	lbu	a4,-1(a1)
     950:	fee78fa3          	sb	a4,-1(a5)
     954:	fb75                	bnez	a4,948 <strcpy+0x8>
    ;
  return os;
}
     956:	6422                	ld	s0,8(sp)
     958:	0141                	addi	sp,sp,16
     95a:	8082                	ret

000000000000095c <strcmp>:

int
strcmp(const char *p, const char *q)
{
     95c:	1141                	addi	sp,sp,-16
     95e:	e422                	sd	s0,8(sp)
     960:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     962:	00054783          	lbu	a5,0(a0)
     966:	cb91                	beqz	a5,97a <strcmp+0x1e>
     968:	0005c703          	lbu	a4,0(a1)
     96c:	00f71763          	bne	a4,a5,97a <strcmp+0x1e>
    p++, q++;
     970:	0505                	addi	a0,a0,1
     972:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     974:	00054783          	lbu	a5,0(a0)
     978:	fbe5                	bnez	a5,968 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     97a:	0005c503          	lbu	a0,0(a1)
}
     97e:	40a7853b          	subw	a0,a5,a0
     982:	6422                	ld	s0,8(sp)
     984:	0141                	addi	sp,sp,16
     986:	8082                	ret

0000000000000988 <strlen>:

uint
strlen(const char *s)
{
     988:	1141                	addi	sp,sp,-16
     98a:	e422                	sd	s0,8(sp)
     98c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     98e:	00054783          	lbu	a5,0(a0)
     992:	cf91                	beqz	a5,9ae <strlen+0x26>
     994:	0505                	addi	a0,a0,1
     996:	87aa                	mv	a5,a0
     998:	4685                	li	a3,1
     99a:	9e89                	subw	a3,a3,a0
     99c:	00f6853b          	addw	a0,a3,a5
     9a0:	0785                	addi	a5,a5,1
     9a2:	fff7c703          	lbu	a4,-1(a5)
     9a6:	fb7d                	bnez	a4,99c <strlen+0x14>
    ;
  return n;
}
     9a8:	6422                	ld	s0,8(sp)
     9aa:	0141                	addi	sp,sp,16
     9ac:	8082                	ret
  for(n = 0; s[n]; n++)
     9ae:	4501                	li	a0,0
     9b0:	bfe5                	j	9a8 <strlen+0x20>

00000000000009b2 <memset>:

void*
memset(void *dst, int c, uint n)
{
     9b2:	1141                	addi	sp,sp,-16
     9b4:	e422                	sd	s0,8(sp)
     9b6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     9b8:	ca19                	beqz	a2,9ce <memset+0x1c>
     9ba:	87aa                	mv	a5,a0
     9bc:	1602                	slli	a2,a2,0x20
     9be:	9201                	srli	a2,a2,0x20
     9c0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     9c4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     9c8:	0785                	addi	a5,a5,1
     9ca:	fee79de3          	bne	a5,a4,9c4 <memset+0x12>
  }
  return dst;
}
     9ce:	6422                	ld	s0,8(sp)
     9d0:	0141                	addi	sp,sp,16
     9d2:	8082                	ret

00000000000009d4 <strchr>:

char*
strchr(const char *s, char c)
{
     9d4:	1141                	addi	sp,sp,-16
     9d6:	e422                	sd	s0,8(sp)
     9d8:	0800                	addi	s0,sp,16
  for(; *s; s++)
     9da:	00054783          	lbu	a5,0(a0)
     9de:	cb99                	beqz	a5,9f4 <strchr+0x20>
    if(*s == c)
     9e0:	00f58763          	beq	a1,a5,9ee <strchr+0x1a>
  for(; *s; s++)
     9e4:	0505                	addi	a0,a0,1
     9e6:	00054783          	lbu	a5,0(a0)
     9ea:	fbfd                	bnez	a5,9e0 <strchr+0xc>
      return (char*)s;
  return 0;
     9ec:	4501                	li	a0,0
}
     9ee:	6422                	ld	s0,8(sp)
     9f0:	0141                	addi	sp,sp,16
     9f2:	8082                	ret
  return 0;
     9f4:	4501                	li	a0,0
     9f6:	bfe5                	j	9ee <strchr+0x1a>

00000000000009f8 <gets>:

char*
gets(char *buf, int max)
{
     9f8:	711d                	addi	sp,sp,-96
     9fa:	ec86                	sd	ra,88(sp)
     9fc:	e8a2                	sd	s0,80(sp)
     9fe:	e4a6                	sd	s1,72(sp)
     a00:	e0ca                	sd	s2,64(sp)
     a02:	fc4e                	sd	s3,56(sp)
     a04:	f852                	sd	s4,48(sp)
     a06:	f456                	sd	s5,40(sp)
     a08:	f05a                	sd	s6,32(sp)
     a0a:	ec5e                	sd	s7,24(sp)
     a0c:	1080                	addi	s0,sp,96
     a0e:	8baa                	mv	s7,a0
     a10:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     a12:	892a                	mv	s2,a0
     a14:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     a16:	4aa9                	li	s5,10
     a18:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     a1a:	89a6                	mv	s3,s1
     a1c:	2485                	addiw	s1,s1,1
     a1e:	0344d663          	bge	s1,s4,a4a <gets+0x52>
    cc = read(0, &c, 1);
     a22:	4605                	li	a2,1
     a24:	faf40593          	addi	a1,s0,-81
     a28:	4501                	li	a0,0
     a2a:	1b4000ef          	jal	ra,bde <read>
    if(cc < 1)
     a2e:	00a05e63          	blez	a0,a4a <gets+0x52>
    buf[i++] = c;
     a32:	faf44783          	lbu	a5,-81(s0)
     a36:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     a3a:	01578763          	beq	a5,s5,a48 <gets+0x50>
     a3e:	0905                	addi	s2,s2,1
     a40:	fd679de3          	bne	a5,s6,a1a <gets+0x22>
  for(i=0; i+1 < max; ){
     a44:	89a6                	mv	s3,s1
     a46:	a011                	j	a4a <gets+0x52>
     a48:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     a4a:	99de                	add	s3,s3,s7
     a4c:	00098023          	sb	zero,0(s3)
  return buf;
}
     a50:	855e                	mv	a0,s7
     a52:	60e6                	ld	ra,88(sp)
     a54:	6446                	ld	s0,80(sp)
     a56:	64a6                	ld	s1,72(sp)
     a58:	6906                	ld	s2,64(sp)
     a5a:	79e2                	ld	s3,56(sp)
     a5c:	7a42                	ld	s4,48(sp)
     a5e:	7aa2                	ld	s5,40(sp)
     a60:	7b02                	ld	s6,32(sp)
     a62:	6be2                	ld	s7,24(sp)
     a64:	6125                	addi	sp,sp,96
     a66:	8082                	ret

0000000000000a68 <stat>:

int
stat(const char *n, struct stat *st)
{
     a68:	1101                	addi	sp,sp,-32
     a6a:	ec06                	sd	ra,24(sp)
     a6c:	e822                	sd	s0,16(sp)
     a6e:	e426                	sd	s1,8(sp)
     a70:	e04a                	sd	s2,0(sp)
     a72:	1000                	addi	s0,sp,32
     a74:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     a76:	4581                	li	a1,0
     a78:	18e000ef          	jal	ra,c06 <open>
  if(fd < 0)
     a7c:	02054163          	bltz	a0,a9e <stat+0x36>
     a80:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     a82:	85ca                	mv	a1,s2
     a84:	19a000ef          	jal	ra,c1e <fstat>
     a88:	892a                	mv	s2,a0
  close(fd);
     a8a:	8526                	mv	a0,s1
     a8c:	162000ef          	jal	ra,bee <close>
  return r;
}
     a90:	854a                	mv	a0,s2
     a92:	60e2                	ld	ra,24(sp)
     a94:	6442                	ld	s0,16(sp)
     a96:	64a2                	ld	s1,8(sp)
     a98:	6902                	ld	s2,0(sp)
     a9a:	6105                	addi	sp,sp,32
     a9c:	8082                	ret
    return -1;
     a9e:	597d                	li	s2,-1
     aa0:	bfc5                	j	a90 <stat+0x28>

0000000000000aa2 <atoi>:

int
atoi(const char *s)
{
     aa2:	1141                	addi	sp,sp,-16
     aa4:	e422                	sd	s0,8(sp)
     aa6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     aa8:	00054603          	lbu	a2,0(a0)
     aac:	fd06079b          	addiw	a5,a2,-48
     ab0:	0ff7f793          	andi	a5,a5,255
     ab4:	4725                	li	a4,9
     ab6:	02f76963          	bltu	a4,a5,ae8 <atoi+0x46>
     aba:	86aa                	mv	a3,a0
  n = 0;
     abc:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     abe:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     ac0:	0685                	addi	a3,a3,1
     ac2:	0025179b          	slliw	a5,a0,0x2
     ac6:	9fa9                	addw	a5,a5,a0
     ac8:	0017979b          	slliw	a5,a5,0x1
     acc:	9fb1                	addw	a5,a5,a2
     ace:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     ad2:	0006c603          	lbu	a2,0(a3)
     ad6:	fd06071b          	addiw	a4,a2,-48
     ada:	0ff77713          	andi	a4,a4,255
     ade:	fee5f1e3          	bgeu	a1,a4,ac0 <atoi+0x1e>
  return n;
}
     ae2:	6422                	ld	s0,8(sp)
     ae4:	0141                	addi	sp,sp,16
     ae6:	8082                	ret
  n = 0;
     ae8:	4501                	li	a0,0
     aea:	bfe5                	j	ae2 <atoi+0x40>

0000000000000aec <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     aec:	1141                	addi	sp,sp,-16
     aee:	e422                	sd	s0,8(sp)
     af0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     af2:	02b57463          	bgeu	a0,a1,b1a <memmove+0x2e>
    while(n-- > 0)
     af6:	00c05f63          	blez	a2,b14 <memmove+0x28>
     afa:	1602                	slli	a2,a2,0x20
     afc:	9201                	srli	a2,a2,0x20
     afe:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     b02:	872a                	mv	a4,a0
      *dst++ = *src++;
     b04:	0585                	addi	a1,a1,1
     b06:	0705                	addi	a4,a4,1
     b08:	fff5c683          	lbu	a3,-1(a1)
     b0c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     b10:	fee79ae3          	bne	a5,a4,b04 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     b14:	6422                	ld	s0,8(sp)
     b16:	0141                	addi	sp,sp,16
     b18:	8082                	ret
    dst += n;
     b1a:	00c50733          	add	a4,a0,a2
    src += n;
     b1e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     b20:	fec05ae3          	blez	a2,b14 <memmove+0x28>
     b24:	fff6079b          	addiw	a5,a2,-1
     b28:	1782                	slli	a5,a5,0x20
     b2a:	9381                	srli	a5,a5,0x20
     b2c:	fff7c793          	not	a5,a5
     b30:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     b32:	15fd                	addi	a1,a1,-1
     b34:	177d                	addi	a4,a4,-1
     b36:	0005c683          	lbu	a3,0(a1)
     b3a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     b3e:	fee79ae3          	bne	a5,a4,b32 <memmove+0x46>
     b42:	bfc9                	j	b14 <memmove+0x28>

0000000000000b44 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     b44:	1141                	addi	sp,sp,-16
     b46:	e422                	sd	s0,8(sp)
     b48:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     b4a:	ca05                	beqz	a2,b7a <memcmp+0x36>
     b4c:	fff6069b          	addiw	a3,a2,-1
     b50:	1682                	slli	a3,a3,0x20
     b52:	9281                	srli	a3,a3,0x20
     b54:	0685                	addi	a3,a3,1
     b56:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     b58:	00054783          	lbu	a5,0(a0)
     b5c:	0005c703          	lbu	a4,0(a1)
     b60:	00e79863          	bne	a5,a4,b70 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     b64:	0505                	addi	a0,a0,1
    p2++;
     b66:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     b68:	fed518e3          	bne	a0,a3,b58 <memcmp+0x14>
  }
  return 0;
     b6c:	4501                	li	a0,0
     b6e:	a019                	j	b74 <memcmp+0x30>
      return *p1 - *p2;
     b70:	40e7853b          	subw	a0,a5,a4
}
     b74:	6422                	ld	s0,8(sp)
     b76:	0141                	addi	sp,sp,16
     b78:	8082                	ret
  return 0;
     b7a:	4501                	li	a0,0
     b7c:	bfe5                	j	b74 <memcmp+0x30>

0000000000000b7e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     b7e:	1141                	addi	sp,sp,-16
     b80:	e406                	sd	ra,8(sp)
     b82:	e022                	sd	s0,0(sp)
     b84:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     b86:	f67ff0ef          	jal	ra,aec <memmove>
}
     b8a:	60a2                	ld	ra,8(sp)
     b8c:	6402                	ld	s0,0(sp)
     b8e:	0141                	addi	sp,sp,16
     b90:	8082                	ret

0000000000000b92 <sbrk>:

char *
sbrk(int n) {
     b92:	1141                	addi	sp,sp,-16
     b94:	e406                	sd	ra,8(sp)
     b96:	e022                	sd	s0,0(sp)
     b98:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
     b9a:	4585                	li	a1,1
     b9c:	0b2000ef          	jal	ra,c4e <sys_sbrk>
}
     ba0:	60a2                	ld	ra,8(sp)
     ba2:	6402                	ld	s0,0(sp)
     ba4:	0141                	addi	sp,sp,16
     ba6:	8082                	ret

0000000000000ba8 <sbrklazy>:

char *
sbrklazy(int n) {
     ba8:	1141                	addi	sp,sp,-16
     baa:	e406                	sd	ra,8(sp)
     bac:	e022                	sd	s0,0(sp)
     bae:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
     bb0:	4589                	li	a1,2
     bb2:	09c000ef          	jal	ra,c4e <sys_sbrk>
}
     bb6:	60a2                	ld	ra,8(sp)
     bb8:	6402                	ld	s0,0(sp)
     bba:	0141                	addi	sp,sp,16
     bbc:	8082                	ret

0000000000000bbe <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     bbe:	4885                	li	a7,1
 ecall
     bc0:	00000073          	ecall
 ret
     bc4:	8082                	ret

0000000000000bc6 <exit>:
.global exit
exit:
 li a7, SYS_exit
     bc6:	4889                	li	a7,2
 ecall
     bc8:	00000073          	ecall
 ret
     bcc:	8082                	ret

0000000000000bce <wait>:
.global wait
wait:
 li a7, SYS_wait
     bce:	488d                	li	a7,3
 ecall
     bd0:	00000073          	ecall
 ret
     bd4:	8082                	ret

0000000000000bd6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     bd6:	4891                	li	a7,4
 ecall
     bd8:	00000073          	ecall
 ret
     bdc:	8082                	ret

0000000000000bde <read>:
.global read
read:
 li a7, SYS_read
     bde:	4895                	li	a7,5
 ecall
     be0:	00000073          	ecall
 ret
     be4:	8082                	ret

0000000000000be6 <write>:
.global write
write:
 li a7, SYS_write
     be6:	48c1                	li	a7,16
 ecall
     be8:	00000073          	ecall
 ret
     bec:	8082                	ret

0000000000000bee <close>:
.global close
close:
 li a7, SYS_close
     bee:	48d5                	li	a7,21
 ecall
     bf0:	00000073          	ecall
 ret
     bf4:	8082                	ret

0000000000000bf6 <kill>:
.global kill
kill:
 li a7, SYS_kill
     bf6:	4899                	li	a7,6
 ecall
     bf8:	00000073          	ecall
 ret
     bfc:	8082                	ret

0000000000000bfe <exec>:
.global exec
exec:
 li a7, SYS_exec
     bfe:	489d                	li	a7,7
 ecall
     c00:	00000073          	ecall
 ret
     c04:	8082                	ret

0000000000000c06 <open>:
.global open
open:
 li a7, SYS_open
     c06:	48bd                	li	a7,15
 ecall
     c08:	00000073          	ecall
 ret
     c0c:	8082                	ret

0000000000000c0e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     c0e:	48c5                	li	a7,17
 ecall
     c10:	00000073          	ecall
 ret
     c14:	8082                	ret

0000000000000c16 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     c16:	48c9                	li	a7,18
 ecall
     c18:	00000073          	ecall
 ret
     c1c:	8082                	ret

0000000000000c1e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     c1e:	48a1                	li	a7,8
 ecall
     c20:	00000073          	ecall
 ret
     c24:	8082                	ret

0000000000000c26 <link>:
.global link
link:
 li a7, SYS_link
     c26:	48cd                	li	a7,19
 ecall
     c28:	00000073          	ecall
 ret
     c2c:	8082                	ret

0000000000000c2e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     c2e:	48d1                	li	a7,20
 ecall
     c30:	00000073          	ecall
 ret
     c34:	8082                	ret

0000000000000c36 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     c36:	48a5                	li	a7,9
 ecall
     c38:	00000073          	ecall
 ret
     c3c:	8082                	ret

0000000000000c3e <dup>:
.global dup
dup:
 li a7, SYS_dup
     c3e:	48a9                	li	a7,10
 ecall
     c40:	00000073          	ecall
 ret
     c44:	8082                	ret

0000000000000c46 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     c46:	48ad                	li	a7,11
 ecall
     c48:	00000073          	ecall
 ret
     c4c:	8082                	ret

0000000000000c4e <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
     c4e:	48b1                	li	a7,12
 ecall
     c50:	00000073          	ecall
 ret
     c54:	8082                	ret

0000000000000c56 <pause>:
.global pause
pause:
 li a7, SYS_pause
     c56:	48b5                	li	a7,13
 ecall
     c58:	00000073          	ecall
 ret
     c5c:	8082                	ret

0000000000000c5e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     c5e:	48b9                	li	a7,14
 ecall
     c60:	00000073          	ecall
 ret
     c64:	8082                	ret

0000000000000c66 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     c66:	1101                	addi	sp,sp,-32
     c68:	ec06                	sd	ra,24(sp)
     c6a:	e822                	sd	s0,16(sp)
     c6c:	1000                	addi	s0,sp,32
     c6e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     c72:	4605                	li	a2,1
     c74:	fef40593          	addi	a1,s0,-17
     c78:	f6fff0ef          	jal	ra,be6 <write>
}
     c7c:	60e2                	ld	ra,24(sp)
     c7e:	6442                	ld	s0,16(sp)
     c80:	6105                	addi	sp,sp,32
     c82:	8082                	ret

0000000000000c84 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
     c84:	715d                	addi	sp,sp,-80
     c86:	e486                	sd	ra,72(sp)
     c88:	e0a2                	sd	s0,64(sp)
     c8a:	fc26                	sd	s1,56(sp)
     c8c:	f84a                	sd	s2,48(sp)
     c8e:	f44e                	sd	s3,40(sp)
     c90:	0880                	addi	s0,sp,80
     c92:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
     c94:	c299                	beqz	a3,c9a <printint+0x16>
     c96:	0805c163          	bltz	a1,d18 <printint+0x94>
  neg = 0;
     c9a:	4881                	li	a7,0
     c9c:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
     ca0:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
     ca2:	00000517          	auipc	a0,0x0
     ca6:	7ce50513          	addi	a0,a0,1998 # 1470 <digits>
     caa:	883e                	mv	a6,a5
     cac:	2785                	addiw	a5,a5,1
     cae:	02c5f733          	remu	a4,a1,a2
     cb2:	972a                	add	a4,a4,a0
     cb4:	00074703          	lbu	a4,0(a4)
     cb8:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
     cbc:	872e                	mv	a4,a1
     cbe:	02c5d5b3          	divu	a1,a1,a2
     cc2:	0685                	addi	a3,a3,1
     cc4:	fec773e3          	bgeu	a4,a2,caa <printint+0x26>
  if(neg)
     cc8:	00088b63          	beqz	a7,cde <printint+0x5a>
    buf[i++] = '-';
     ccc:	fd040713          	addi	a4,s0,-48
     cd0:	97ba                	add	a5,a5,a4
     cd2:	02d00713          	li	a4,45
     cd6:	fee78423          	sb	a4,-24(a5)
     cda:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
     cde:	02f05663          	blez	a5,d0a <printint+0x86>
     ce2:	fb840713          	addi	a4,s0,-72
     ce6:	00f704b3          	add	s1,a4,a5
     cea:	fff70993          	addi	s3,a4,-1
     cee:	99be                	add	s3,s3,a5
     cf0:	37fd                	addiw	a5,a5,-1
     cf2:	1782                	slli	a5,a5,0x20
     cf4:	9381                	srli	a5,a5,0x20
     cf6:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
     cfa:	fff4c583          	lbu	a1,-1(s1)
     cfe:	854a                	mv	a0,s2
     d00:	f67ff0ef          	jal	ra,c66 <putc>
  while(--i >= 0)
     d04:	14fd                	addi	s1,s1,-1
     d06:	ff349ae3          	bne	s1,s3,cfa <printint+0x76>
}
     d0a:	60a6                	ld	ra,72(sp)
     d0c:	6406                	ld	s0,64(sp)
     d0e:	74e2                	ld	s1,56(sp)
     d10:	7942                	ld	s2,48(sp)
     d12:	79a2                	ld	s3,40(sp)
     d14:	6161                	addi	sp,sp,80
     d16:	8082                	ret
    x = -xx;
     d18:	40b005b3          	neg	a1,a1
    neg = 1;
     d1c:	4885                	li	a7,1
    x = -xx;
     d1e:	bfbd                	j	c9c <printint+0x18>

0000000000000d20 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     d20:	7119                	addi	sp,sp,-128
     d22:	fc86                	sd	ra,120(sp)
     d24:	f8a2                	sd	s0,112(sp)
     d26:	f4a6                	sd	s1,104(sp)
     d28:	f0ca                	sd	s2,96(sp)
     d2a:	ecce                	sd	s3,88(sp)
     d2c:	e8d2                	sd	s4,80(sp)
     d2e:	e4d6                	sd	s5,72(sp)
     d30:	e0da                	sd	s6,64(sp)
     d32:	fc5e                	sd	s7,56(sp)
     d34:	f862                	sd	s8,48(sp)
     d36:	f466                	sd	s9,40(sp)
     d38:	f06a                	sd	s10,32(sp)
     d3a:	ec6e                	sd	s11,24(sp)
     d3c:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     d3e:	0005c903          	lbu	s2,0(a1)
     d42:	24090c63          	beqz	s2,f9a <vprintf+0x27a>
     d46:	8b2a                	mv	s6,a0
     d48:	8a2e                	mv	s4,a1
     d4a:	8bb2                	mv	s7,a2
  state = 0;
     d4c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
     d4e:	4481                	li	s1,0
     d50:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
     d52:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
     d56:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
     d5a:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
     d5e:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     d62:	00000c97          	auipc	s9,0x0
     d66:	70ec8c93          	addi	s9,s9,1806 # 1470 <digits>
     d6a:	a005                	j	d8a <vprintf+0x6a>
        putc(fd, c0);
     d6c:	85ca                	mv	a1,s2
     d6e:	855a                	mv	a0,s6
     d70:	ef7ff0ef          	jal	ra,c66 <putc>
     d74:	a019                	j	d7a <vprintf+0x5a>
    } else if(state == '%'){
     d76:	03598263          	beq	s3,s5,d9a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
     d7a:	2485                	addiw	s1,s1,1
     d7c:	8726                	mv	a4,s1
     d7e:	009a07b3          	add	a5,s4,s1
     d82:	0007c903          	lbu	s2,0(a5)
     d86:	20090a63          	beqz	s2,f9a <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
     d8a:	0009079b          	sext.w	a5,s2
    if(state == 0){
     d8e:	fe0994e3          	bnez	s3,d76 <vprintf+0x56>
      if(c0 == '%'){
     d92:	fd579de3          	bne	a5,s5,d6c <vprintf+0x4c>
        state = '%';
     d96:	89be                	mv	s3,a5
     d98:	b7cd                	j	d7a <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
     d9a:	c3c1                	beqz	a5,e1a <vprintf+0xfa>
     d9c:	00ea06b3          	add	a3,s4,a4
     da0:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
     da4:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
     da6:	c681                	beqz	a3,dae <vprintf+0x8e>
     da8:	9752                	add	a4,a4,s4
     daa:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
     dae:	03878e63          	beq	a5,s8,dea <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
     db2:	05a78863          	beq	a5,s10,e02 <vprintf+0xe2>
      } else if(c0 == 'u'){
     db6:	0db78b63          	beq	a5,s11,e8c <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
     dba:	07800713          	li	a4,120
     dbe:	10e78d63          	beq	a5,a4,ed8 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
     dc2:	07000713          	li	a4,112
     dc6:	14e78263          	beq	a5,a4,f0a <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
     dca:	06300713          	li	a4,99
     dce:	16e78f63          	beq	a5,a4,f4c <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
     dd2:	07300713          	li	a4,115
     dd6:	18e78563          	beq	a5,a4,f60 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
     dda:	05579063          	bne	a5,s5,e1a <vprintf+0xfa>
        putc(fd, '%');
     dde:	85d6                	mv	a1,s5
     de0:	855a                	mv	a0,s6
     de2:	e85ff0ef          	jal	ra,c66 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
     de6:	4981                	li	s3,0
     de8:	bf49                	j	d7a <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
     dea:	008b8913          	addi	s2,s7,8
     dee:	4685                	li	a3,1
     df0:	4629                	li	a2,10
     df2:	000ba583          	lw	a1,0(s7)
     df6:	855a                	mv	a0,s6
     df8:	e8dff0ef          	jal	ra,c84 <printint>
     dfc:	8bca                	mv	s7,s2
      state = 0;
     dfe:	4981                	li	s3,0
     e00:	bfad                	j	d7a <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
     e02:	03868663          	beq	a3,s8,e2e <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     e06:	05a68163          	beq	a3,s10,e48 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
     e0a:	09b68d63          	beq	a3,s11,ea4 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
     e0e:	03a68f63          	beq	a3,s10,e4c <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
     e12:	07800793          	li	a5,120
     e16:	0cf68d63          	beq	a3,a5,ef0 <vprintf+0x1d0>
        putc(fd, '%');
     e1a:	85d6                	mv	a1,s5
     e1c:	855a                	mv	a0,s6
     e1e:	e49ff0ef          	jal	ra,c66 <putc>
        putc(fd, c0);
     e22:	85ca                	mv	a1,s2
     e24:	855a                	mv	a0,s6
     e26:	e41ff0ef          	jal	ra,c66 <putc>
      state = 0;
     e2a:	4981                	li	s3,0
     e2c:	b7b9                	j	d7a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     e2e:	008b8913          	addi	s2,s7,8
     e32:	4685                	li	a3,1
     e34:	4629                	li	a2,10
     e36:	000bb583          	ld	a1,0(s7)
     e3a:	855a                	mv	a0,s6
     e3c:	e49ff0ef          	jal	ra,c84 <printint>
        i += 1;
     e40:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
     e42:	8bca                	mv	s7,s2
      state = 0;
     e44:	4981                	li	s3,0
        i += 1;
     e46:	bf15                	j	d7a <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     e48:	03860563          	beq	a2,s8,e72 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
     e4c:	07b60963          	beq	a2,s11,ebe <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
     e50:	07800793          	li	a5,120
     e54:	fcf613e3          	bne	a2,a5,e1a <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
     e58:	008b8913          	addi	s2,s7,8
     e5c:	4681                	li	a3,0
     e5e:	4641                	li	a2,16
     e60:	000bb583          	ld	a1,0(s7)
     e64:	855a                	mv	a0,s6
     e66:	e1fff0ef          	jal	ra,c84 <printint>
        i += 2;
     e6a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
     e6c:	8bca                	mv	s7,s2
      state = 0;
     e6e:	4981                	li	s3,0
        i += 2;
     e70:	b729                	j	d7a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     e72:	008b8913          	addi	s2,s7,8
     e76:	4685                	li	a3,1
     e78:	4629                	li	a2,10
     e7a:	000bb583          	ld	a1,0(s7)
     e7e:	855a                	mv	a0,s6
     e80:	e05ff0ef          	jal	ra,c84 <printint>
        i += 2;
     e84:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
     e86:	8bca                	mv	s7,s2
      state = 0;
     e88:	4981                	li	s3,0
        i += 2;
     e8a:	bdc5                	j	d7a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
     e8c:	008b8913          	addi	s2,s7,8
     e90:	4681                	li	a3,0
     e92:	4629                	li	a2,10
     e94:	000be583          	lwu	a1,0(s7)
     e98:	855a                	mv	a0,s6
     e9a:	debff0ef          	jal	ra,c84 <printint>
     e9e:	8bca                	mv	s7,s2
      state = 0;
     ea0:	4981                	li	s3,0
     ea2:	bde1                	j	d7a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     ea4:	008b8913          	addi	s2,s7,8
     ea8:	4681                	li	a3,0
     eaa:	4629                	li	a2,10
     eac:	000bb583          	ld	a1,0(s7)
     eb0:	855a                	mv	a0,s6
     eb2:	dd3ff0ef          	jal	ra,c84 <printint>
        i += 1;
     eb6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
     eb8:	8bca                	mv	s7,s2
      state = 0;
     eba:	4981                	li	s3,0
        i += 1;
     ebc:	bd7d                	j	d7a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     ebe:	008b8913          	addi	s2,s7,8
     ec2:	4681                	li	a3,0
     ec4:	4629                	li	a2,10
     ec6:	000bb583          	ld	a1,0(s7)
     eca:	855a                	mv	a0,s6
     ecc:	db9ff0ef          	jal	ra,c84 <printint>
        i += 2;
     ed0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
     ed2:	8bca                	mv	s7,s2
      state = 0;
     ed4:	4981                	li	s3,0
        i += 2;
     ed6:	b555                	j	d7a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
     ed8:	008b8913          	addi	s2,s7,8
     edc:	4681                	li	a3,0
     ede:	4641                	li	a2,16
     ee0:	000be583          	lwu	a1,0(s7)
     ee4:	855a                	mv	a0,s6
     ee6:	d9fff0ef          	jal	ra,c84 <printint>
     eea:	8bca                	mv	s7,s2
      state = 0;
     eec:	4981                	li	s3,0
     eee:	b571                	j	d7a <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
     ef0:	008b8913          	addi	s2,s7,8
     ef4:	4681                	li	a3,0
     ef6:	4641                	li	a2,16
     ef8:	000bb583          	ld	a1,0(s7)
     efc:	855a                	mv	a0,s6
     efe:	d87ff0ef          	jal	ra,c84 <printint>
        i += 1;
     f02:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
     f04:	8bca                	mv	s7,s2
      state = 0;
     f06:	4981                	li	s3,0
        i += 1;
     f08:	bd8d                	j	d7a <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
     f0a:	008b8793          	addi	a5,s7,8
     f0e:	f8f43423          	sd	a5,-120(s0)
     f12:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
     f16:	03000593          	li	a1,48
     f1a:	855a                	mv	a0,s6
     f1c:	d4bff0ef          	jal	ra,c66 <putc>
  putc(fd, 'x');
     f20:	07800593          	li	a1,120
     f24:	855a                	mv	a0,s6
     f26:	d41ff0ef          	jal	ra,c66 <putc>
     f2a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     f2c:	03c9d793          	srli	a5,s3,0x3c
     f30:	97e6                	add	a5,a5,s9
     f32:	0007c583          	lbu	a1,0(a5)
     f36:	855a                	mv	a0,s6
     f38:	d2fff0ef          	jal	ra,c66 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     f3c:	0992                	slli	s3,s3,0x4
     f3e:	397d                	addiw	s2,s2,-1
     f40:	fe0916e3          	bnez	s2,f2c <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
     f44:	f8843b83          	ld	s7,-120(s0)
      state = 0;
     f48:	4981                	li	s3,0
     f4a:	bd05                	j	d7a <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
     f4c:	008b8913          	addi	s2,s7,8
     f50:	000bc583          	lbu	a1,0(s7)
     f54:	855a                	mv	a0,s6
     f56:	d11ff0ef          	jal	ra,c66 <putc>
     f5a:	8bca                	mv	s7,s2
      state = 0;
     f5c:	4981                	li	s3,0
     f5e:	bd31                	j	d7a <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
     f60:	008b8993          	addi	s3,s7,8
     f64:	000bb903          	ld	s2,0(s7)
     f68:	00090f63          	beqz	s2,f86 <vprintf+0x266>
        for(; *s; s++)
     f6c:	00094583          	lbu	a1,0(s2)
     f70:	c195                	beqz	a1,f94 <vprintf+0x274>
          putc(fd, *s);
     f72:	855a                	mv	a0,s6
     f74:	cf3ff0ef          	jal	ra,c66 <putc>
        for(; *s; s++)
     f78:	0905                	addi	s2,s2,1
     f7a:	00094583          	lbu	a1,0(s2)
     f7e:	f9f5                	bnez	a1,f72 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
     f80:	8bce                	mv	s7,s3
      state = 0;
     f82:	4981                	li	s3,0
     f84:	bbdd                	j	d7a <vprintf+0x5a>
          s = "(null)";
     f86:	00000917          	auipc	s2,0x0
     f8a:	4e290913          	addi	s2,s2,1250 # 1468 <malloc+0x3cc>
        for(; *s; s++)
     f8e:	02800593          	li	a1,40
     f92:	b7c5                	j	f72 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
     f94:	8bce                	mv	s7,s3
      state = 0;
     f96:	4981                	li	s3,0
     f98:	b3cd                	j	d7a <vprintf+0x5a>
    }
  }
}
     f9a:	70e6                	ld	ra,120(sp)
     f9c:	7446                	ld	s0,112(sp)
     f9e:	74a6                	ld	s1,104(sp)
     fa0:	7906                	ld	s2,96(sp)
     fa2:	69e6                	ld	s3,88(sp)
     fa4:	6a46                	ld	s4,80(sp)
     fa6:	6aa6                	ld	s5,72(sp)
     fa8:	6b06                	ld	s6,64(sp)
     faa:	7be2                	ld	s7,56(sp)
     fac:	7c42                	ld	s8,48(sp)
     fae:	7ca2                	ld	s9,40(sp)
     fb0:	7d02                	ld	s10,32(sp)
     fb2:	6de2                	ld	s11,24(sp)
     fb4:	6109                	addi	sp,sp,128
     fb6:	8082                	ret

0000000000000fb8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
     fb8:	715d                	addi	sp,sp,-80
     fba:	ec06                	sd	ra,24(sp)
     fbc:	e822                	sd	s0,16(sp)
     fbe:	1000                	addi	s0,sp,32
     fc0:	e010                	sd	a2,0(s0)
     fc2:	e414                	sd	a3,8(s0)
     fc4:	e818                	sd	a4,16(s0)
     fc6:	ec1c                	sd	a5,24(s0)
     fc8:	03043023          	sd	a6,32(s0)
     fcc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
     fd0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
     fd4:	8622                	mv	a2,s0
     fd6:	d4bff0ef          	jal	ra,d20 <vprintf>
}
     fda:	60e2                	ld	ra,24(sp)
     fdc:	6442                	ld	s0,16(sp)
     fde:	6161                	addi	sp,sp,80
     fe0:	8082                	ret

0000000000000fe2 <printf>:

void
printf(const char *fmt, ...)
{
     fe2:	711d                	addi	sp,sp,-96
     fe4:	ec06                	sd	ra,24(sp)
     fe6:	e822                	sd	s0,16(sp)
     fe8:	1000                	addi	s0,sp,32
     fea:	e40c                	sd	a1,8(s0)
     fec:	e810                	sd	a2,16(s0)
     fee:	ec14                	sd	a3,24(s0)
     ff0:	f018                	sd	a4,32(s0)
     ff2:	f41c                	sd	a5,40(s0)
     ff4:	03043823          	sd	a6,48(s0)
     ff8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
     ffc:	00840613          	addi	a2,s0,8
    1000:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1004:	85aa                	mv	a1,a0
    1006:	4505                	li	a0,1
    1008:	d19ff0ef          	jal	ra,d20 <vprintf>
}
    100c:	60e2                	ld	ra,24(sp)
    100e:	6442                	ld	s0,16(sp)
    1010:	6125                	addi	sp,sp,96
    1012:	8082                	ret

0000000000001014 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1014:	1141                	addi	sp,sp,-16
    1016:	e422                	sd	s0,8(sp)
    1018:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    101a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    101e:	00001797          	auipc	a5,0x1
    1022:	ff27b783          	ld	a5,-14(a5) # 2010 <freep>
    1026:	a805                	j	1056 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1028:	4618                	lw	a4,8(a2)
    102a:	9db9                	addw	a1,a1,a4
    102c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1030:	6398                	ld	a4,0(a5)
    1032:	6318                	ld	a4,0(a4)
    1034:	fee53823          	sd	a4,-16(a0)
    1038:	a091                	j	107c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    103a:	ff852703          	lw	a4,-8(a0)
    103e:	9e39                	addw	a2,a2,a4
    1040:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    1042:	ff053703          	ld	a4,-16(a0)
    1046:	e398                	sd	a4,0(a5)
    1048:	a099                	j	108e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    104a:	6398                	ld	a4,0(a5)
    104c:	00e7e463          	bltu	a5,a4,1054 <free+0x40>
    1050:	00e6ea63          	bltu	a3,a4,1064 <free+0x50>
{
    1054:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1056:	fed7fae3          	bgeu	a5,a3,104a <free+0x36>
    105a:	6398                	ld	a4,0(a5)
    105c:	00e6e463          	bltu	a3,a4,1064 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1060:	fee7eae3          	bltu	a5,a4,1054 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    1064:	ff852583          	lw	a1,-8(a0)
    1068:	6390                	ld	a2,0(a5)
    106a:	02059713          	slli	a4,a1,0x20
    106e:	9301                	srli	a4,a4,0x20
    1070:	0712                	slli	a4,a4,0x4
    1072:	9736                	add	a4,a4,a3
    1074:	fae60ae3          	beq	a2,a4,1028 <free+0x14>
    bp->s.ptr = p->s.ptr;
    1078:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    107c:	4790                	lw	a2,8(a5)
    107e:	02061713          	slli	a4,a2,0x20
    1082:	9301                	srli	a4,a4,0x20
    1084:	0712                	slli	a4,a4,0x4
    1086:	973e                	add	a4,a4,a5
    1088:	fae689e3          	beq	a3,a4,103a <free+0x26>
  } else
    p->s.ptr = bp;
    108c:	e394                	sd	a3,0(a5)
  freep = p;
    108e:	00001717          	auipc	a4,0x1
    1092:	f8f73123          	sd	a5,-126(a4) # 2010 <freep>
}
    1096:	6422                	ld	s0,8(sp)
    1098:	0141                	addi	sp,sp,16
    109a:	8082                	ret

000000000000109c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    109c:	7139                	addi	sp,sp,-64
    109e:	fc06                	sd	ra,56(sp)
    10a0:	f822                	sd	s0,48(sp)
    10a2:	f426                	sd	s1,40(sp)
    10a4:	f04a                	sd	s2,32(sp)
    10a6:	ec4e                	sd	s3,24(sp)
    10a8:	e852                	sd	s4,16(sp)
    10aa:	e456                	sd	s5,8(sp)
    10ac:	e05a                	sd	s6,0(sp)
    10ae:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    10b0:	02051493          	slli	s1,a0,0x20
    10b4:	9081                	srli	s1,s1,0x20
    10b6:	04bd                	addi	s1,s1,15
    10b8:	8091                	srli	s1,s1,0x4
    10ba:	0014899b          	addiw	s3,s1,1
    10be:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    10c0:	00001517          	auipc	a0,0x1
    10c4:	f5053503          	ld	a0,-176(a0) # 2010 <freep>
    10c8:	c515                	beqz	a0,10f4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    10ca:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    10cc:	4798                	lw	a4,8(a5)
    10ce:	02977f63          	bgeu	a4,s1,110c <malloc+0x70>
    10d2:	8a4e                	mv	s4,s3
    10d4:	0009871b          	sext.w	a4,s3
    10d8:	6685                	lui	a3,0x1
    10da:	00d77363          	bgeu	a4,a3,10e0 <malloc+0x44>
    10de:	6a05                	lui	s4,0x1
    10e0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    10e4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    10e8:	00001917          	auipc	s2,0x1
    10ec:	f2890913          	addi	s2,s2,-216 # 2010 <freep>
  if(p == SBRK_ERROR)
    10f0:	5afd                	li	s5,-1
    10f2:	a0bd                	j	1160 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
    10f4:	00001797          	auipc	a5,0x1
    10f8:	31478793          	addi	a5,a5,788 # 2408 <base>
    10fc:	00001717          	auipc	a4,0x1
    1100:	f0f73a23          	sd	a5,-236(a4) # 2010 <freep>
    1104:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    1106:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    110a:	b7e1                	j	10d2 <malloc+0x36>
      if(p->s.size == nunits)
    110c:	02e48b63          	beq	s1,a4,1142 <malloc+0xa6>
        p->s.size -= nunits;
    1110:	4137073b          	subw	a4,a4,s3
    1114:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1116:	1702                	slli	a4,a4,0x20
    1118:	9301                	srli	a4,a4,0x20
    111a:	0712                	slli	a4,a4,0x4
    111c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    111e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1122:	00001717          	auipc	a4,0x1
    1126:	eea73723          	sd	a0,-274(a4) # 2010 <freep>
      return (void*)(p + 1);
    112a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    112e:	70e2                	ld	ra,56(sp)
    1130:	7442                	ld	s0,48(sp)
    1132:	74a2                	ld	s1,40(sp)
    1134:	7902                	ld	s2,32(sp)
    1136:	69e2                	ld	s3,24(sp)
    1138:	6a42                	ld	s4,16(sp)
    113a:	6aa2                	ld	s5,8(sp)
    113c:	6b02                	ld	s6,0(sp)
    113e:	6121                	addi	sp,sp,64
    1140:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    1142:	6398                	ld	a4,0(a5)
    1144:	e118                	sd	a4,0(a0)
    1146:	bff1                	j	1122 <malloc+0x86>
  hp->s.size = nu;
    1148:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    114c:	0541                	addi	a0,a0,16
    114e:	ec7ff0ef          	jal	ra,1014 <free>
  return freep;
    1152:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    1156:	dd61                	beqz	a0,112e <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1158:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    115a:	4798                	lw	a4,8(a5)
    115c:	fa9778e3          	bgeu	a4,s1,110c <malloc+0x70>
    if(p == freep)
    1160:	00093703          	ld	a4,0(s2)
    1164:	853e                	mv	a0,a5
    1166:	fef719e3          	bne	a4,a5,1158 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
    116a:	8552                	mv	a0,s4
    116c:	a27ff0ef          	jal	ra,b92 <sbrk>
  if(p == SBRK_ERROR)
    1170:	fd551ce3          	bne	a0,s5,1148 <malloc+0xac>
        return 0;
    1174:	4501                	li	a0,0
    1176:	bf65                	j	112e <malloc+0x92>
