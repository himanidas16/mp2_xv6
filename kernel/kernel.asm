
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00008117          	auipc	sp,0x8
    80000004:	b2010113          	addi	sp,sp,-1248 # 80007b20 <stack0>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04a000ef          	jal	ra,80000060 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	0x14d,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc3d7>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	d6278793          	addi	a5,a5,-670 # 80000de2 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a2:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	ra,8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	7159                	addi	sp,sp,-112
    800000d2:	f486                	sd	ra,104(sp)
    800000d4:	f0a2                	sd	s0,96(sp)
    800000d6:	eca6                	sd	s1,88(sp)
    800000d8:	e8ca                	sd	s2,80(sp)
    800000da:	e4ce                	sd	s3,72(sp)
    800000dc:	e0d2                	sd	s4,64(sp)
    800000de:	fc56                	sd	s5,56(sp)
    800000e0:	f85a                	sd	s6,48(sp)
    800000e2:	f45e                	sd	s7,40(sp)
    800000e4:	f062                	sd	s8,32(sp)
    800000e6:	1880                	addi	s0,sp,112
  char buf[32];
  int i = 0;

  while(i < n){
    800000e8:	04c05463          	blez	a2,80000130 <consolewrite+0x60>
    800000ec:	8a2a                	mv	s4,a0
    800000ee:	8aae                	mv	s5,a1
    800000f0:	89b2                	mv	s3,a2
  int i = 0;
    800000f2:	4901                	li	s2,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000f4:	4bfd                	li	s7,31
    int nn = sizeof(buf);
    800000f6:	02000c13          	li	s8,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    800000fa:	5b7d                	li	s6,-1
    800000fc:	a025                	j	80000124 <consolewrite+0x54>
    800000fe:	86a6                	mv	a3,s1
    80000100:	01590633          	add	a2,s2,s5
    80000104:	85d2                	mv	a1,s4
    80000106:	f9040513          	addi	a0,s0,-112
    8000010a:	3f0020ef          	jal	ra,800024fa <either_copyin>
    8000010e:	03650263          	beq	a0,s6,80000132 <consolewrite+0x62>
      break;
    uartwrite(buf, nn);
    80000112:	85a6                	mv	a1,s1
    80000114:	f9040513          	addi	a0,s0,-112
    80000118:	71e000ef          	jal	ra,80000836 <uartwrite>
    i += nn;
    8000011c:	0124893b          	addw	s2,s1,s2
  while(i < n){
    80000120:	01395963          	bge	s2,s3,80000132 <consolewrite+0x62>
    if(nn > n - i)
    80000124:	412984bb          	subw	s1,s3,s2
    80000128:	fc9bdbe3          	bge	s7,s1,800000fe <consolewrite+0x2e>
    int nn = sizeof(buf);
    8000012c:	84e2                	mv	s1,s8
    8000012e:	bfc1                	j	800000fe <consolewrite+0x2e>
  int i = 0;
    80000130:	4901                	li	s2,0
  }

  return i;
}
    80000132:	854a                	mv	a0,s2
    80000134:	70a6                	ld	ra,104(sp)
    80000136:	7406                	ld	s0,96(sp)
    80000138:	64e6                	ld	s1,88(sp)
    8000013a:	6946                	ld	s2,80(sp)
    8000013c:	69a6                	ld	s3,72(sp)
    8000013e:	6a06                	ld	s4,64(sp)
    80000140:	7ae2                	ld	s5,56(sp)
    80000142:	7b42                	ld	s6,48(sp)
    80000144:	7ba2                	ld	s7,40(sp)
    80000146:	7c02                	ld	s8,32(sp)
    80000148:	6165                	addi	sp,sp,112
    8000014a:	8082                	ret

000000008000014c <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000014c:	7159                	addi	sp,sp,-112
    8000014e:	f486                	sd	ra,104(sp)
    80000150:	f0a2                	sd	s0,96(sp)
    80000152:	eca6                	sd	s1,88(sp)
    80000154:	e8ca                	sd	s2,80(sp)
    80000156:	e4ce                	sd	s3,72(sp)
    80000158:	e0d2                	sd	s4,64(sp)
    8000015a:	fc56                	sd	s5,56(sp)
    8000015c:	f85a                	sd	s6,48(sp)
    8000015e:	f45e                	sd	s7,40(sp)
    80000160:	f062                	sd	s8,32(sp)
    80000162:	ec66                	sd	s9,24(sp)
    80000164:	e86a                	sd	s10,16(sp)
    80000166:	1880                	addi	s0,sp,112
    80000168:	8aaa                	mv	s5,a0
    8000016a:	8a2e                	mv	s4,a1
    8000016c:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000016e:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000172:	00010517          	auipc	a0,0x10
    80000176:	9ae50513          	addi	a0,a0,-1618 # 8000fb20 <cons>
    8000017a:	1f3000ef          	jal	ra,80000b6c <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000017e:	00010497          	auipc	s1,0x10
    80000182:	9a248493          	addi	s1,s1,-1630 # 8000fb20 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000186:	00010917          	auipc	s2,0x10
    8000018a:	a3290913          	addi	s2,s2,-1486 # 8000fbb8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    8000018e:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000190:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    80000192:	4ca9                	li	s9,10
  while(n > 0){
    80000194:	07305363          	blez	s3,800001fa <consoleread+0xae>
    while(cons.r == cons.w){
    80000198:	0984a783          	lw	a5,152(s1)
    8000019c:	09c4a703          	lw	a4,156(s1)
    800001a0:	02f71163          	bne	a4,a5,800001c2 <consoleread+0x76>
      if(killed(myproc())){
    800001a4:	18f010ef          	jal	ra,80001b32 <myproc>
    800001a8:	1e4020ef          	jal	ra,8000238c <killed>
    800001ac:	e125                	bnez	a0,8000020c <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800001ae:	85a6                	mv	a1,s1
    800001b0:	854a                	mv	a0,s2
    800001b2:	7a3010ef          	jal	ra,80002154 <sleep>
    while(cons.r == cons.w){
    800001b6:	0984a783          	lw	a5,152(s1)
    800001ba:	09c4a703          	lw	a4,156(s1)
    800001be:	fef703e3          	beq	a4,a5,800001a4 <consoleread+0x58>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001c2:	0017871b          	addiw	a4,a5,1
    800001c6:	08e4ac23          	sw	a4,152(s1)
    800001ca:	07f7f713          	andi	a4,a5,127
    800001ce:	9726                	add	a4,a4,s1
    800001d0:	01874703          	lbu	a4,24(a4)
    800001d4:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001d8:	057d0f63          	beq	s10,s7,80000236 <consoleread+0xea>
    cbuf = c;
    800001dc:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001e0:	4685                	li	a3,1
    800001e2:	f9f40613          	addi	a2,s0,-97
    800001e6:	85d2                	mv	a1,s4
    800001e8:	8556                	mv	a0,s5
    800001ea:	2c6020ef          	jal	ra,800024b0 <either_copyout>
    800001ee:	01850663          	beq	a0,s8,800001fa <consoleread+0xae>
    dst++;
    800001f2:	0a05                	addi	s4,s4,1
    --n;
    800001f4:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    800001f6:	f99d1fe3          	bne	s10,s9,80000194 <consoleread+0x48>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    800001fa:	00010517          	auipc	a0,0x10
    800001fe:	92650513          	addi	a0,a0,-1754 # 8000fb20 <cons>
    80000202:	203000ef          	jal	ra,80000c04 <release>

  return target - n;
    80000206:	413b053b          	subw	a0,s6,s3
    8000020a:	a801                	j	8000021a <consoleread+0xce>
        release(&cons.lock);
    8000020c:	00010517          	auipc	a0,0x10
    80000210:	91450513          	addi	a0,a0,-1772 # 8000fb20 <cons>
    80000214:	1f1000ef          	jal	ra,80000c04 <release>
        return -1;
    80000218:	557d                	li	a0,-1
}
    8000021a:	70a6                	ld	ra,104(sp)
    8000021c:	7406                	ld	s0,96(sp)
    8000021e:	64e6                	ld	s1,88(sp)
    80000220:	6946                	ld	s2,80(sp)
    80000222:	69a6                	ld	s3,72(sp)
    80000224:	6a06                	ld	s4,64(sp)
    80000226:	7ae2                	ld	s5,56(sp)
    80000228:	7b42                	ld	s6,48(sp)
    8000022a:	7ba2                	ld	s7,40(sp)
    8000022c:	7c02                	ld	s8,32(sp)
    8000022e:	6ce2                	ld	s9,24(sp)
    80000230:	6d42                	ld	s10,16(sp)
    80000232:	6165                	addi	sp,sp,112
    80000234:	8082                	ret
      if(n < target){
    80000236:	0009871b          	sext.w	a4,s3
    8000023a:	fd6770e3          	bgeu	a4,s6,800001fa <consoleread+0xae>
        cons.r--;
    8000023e:	00010717          	auipc	a4,0x10
    80000242:	96f72d23          	sw	a5,-1670(a4) # 8000fbb8 <cons+0x98>
    80000246:	bf55                	j	800001fa <consoleread+0xae>

0000000080000248 <consputc>:
{
    80000248:	1141                	addi	sp,sp,-16
    8000024a:	e406                	sd	ra,8(sp)
    8000024c:	e022                	sd	s0,0(sp)
    8000024e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000250:	10000793          	li	a5,256
    80000254:	00f50863          	beq	a0,a5,80000264 <consputc+0x1c>
    uartputc_sync(c);
    80000258:	67c000ef          	jal	ra,800008d4 <uartputc_sync>
}
    8000025c:	60a2                	ld	ra,8(sp)
    8000025e:	6402                	ld	s0,0(sp)
    80000260:	0141                	addi	sp,sp,16
    80000262:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000264:	4521                	li	a0,8
    80000266:	66e000ef          	jal	ra,800008d4 <uartputc_sync>
    8000026a:	02000513          	li	a0,32
    8000026e:	666000ef          	jal	ra,800008d4 <uartputc_sync>
    80000272:	4521                	li	a0,8
    80000274:	660000ef          	jal	ra,800008d4 <uartputc_sync>
    80000278:	b7d5                	j	8000025c <consputc+0x14>

000000008000027a <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    8000027a:	1101                	addi	sp,sp,-32
    8000027c:	ec06                	sd	ra,24(sp)
    8000027e:	e822                	sd	s0,16(sp)
    80000280:	e426                	sd	s1,8(sp)
    80000282:	e04a                	sd	s2,0(sp)
    80000284:	1000                	addi	s0,sp,32
    80000286:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80000288:	00010517          	auipc	a0,0x10
    8000028c:	89850513          	addi	a0,a0,-1896 # 8000fb20 <cons>
    80000290:	0dd000ef          	jal	ra,80000b6c <acquire>

  switch(c){
    80000294:	47d5                	li	a5,21
    80000296:	0af48063          	beq	s1,a5,80000336 <consoleintr+0xbc>
    8000029a:	0297c663          	blt	a5,s1,800002c6 <consoleintr+0x4c>
    8000029e:	47a1                	li	a5,8
    800002a0:	0cf48f63          	beq	s1,a5,8000037e <consoleintr+0x104>
    800002a4:	47c1                	li	a5,16
    800002a6:	10f49063          	bne	s1,a5,800003a6 <consoleintr+0x12c>
  case C('P'):  // Print process list.
    procdump();
    800002aa:	29a020ef          	jal	ra,80002544 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ae:	00010517          	auipc	a0,0x10
    800002b2:	87250513          	addi	a0,a0,-1934 # 8000fb20 <cons>
    800002b6:	14f000ef          	jal	ra,80000c04 <release>
}
    800002ba:	60e2                	ld	ra,24(sp)
    800002bc:	6442                	ld	s0,16(sp)
    800002be:	64a2                	ld	s1,8(sp)
    800002c0:	6902                	ld	s2,0(sp)
    800002c2:	6105                	addi	sp,sp,32
    800002c4:	8082                	ret
  switch(c){
    800002c6:	07f00793          	li	a5,127
    800002ca:	0af48a63          	beq	s1,a5,8000037e <consoleintr+0x104>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002ce:	00010717          	auipc	a4,0x10
    800002d2:	85270713          	addi	a4,a4,-1966 # 8000fb20 <cons>
    800002d6:	0a072783          	lw	a5,160(a4)
    800002da:	09872703          	lw	a4,152(a4)
    800002de:	9f99                	subw	a5,a5,a4
    800002e0:	07f00713          	li	a4,127
    800002e4:	fcf765e3          	bltu	a4,a5,800002ae <consoleintr+0x34>
      c = (c == '\r') ? '\n' : c;
    800002e8:	47b5                	li	a5,13
    800002ea:	0cf48163          	beq	s1,a5,800003ac <consoleintr+0x132>
      consputc(c);
    800002ee:	8526                	mv	a0,s1
    800002f0:	f59ff0ef          	jal	ra,80000248 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002f4:	00010797          	auipc	a5,0x10
    800002f8:	82c78793          	addi	a5,a5,-2004 # 8000fb20 <cons>
    800002fc:	0a07a683          	lw	a3,160(a5)
    80000300:	0016871b          	addiw	a4,a3,1
    80000304:	0007061b          	sext.w	a2,a4
    80000308:	0ae7a023          	sw	a4,160(a5)
    8000030c:	07f6f693          	andi	a3,a3,127
    80000310:	97b6                	add	a5,a5,a3
    80000312:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000316:	47a9                	li	a5,10
    80000318:	0af48f63          	beq	s1,a5,800003d6 <consoleintr+0x15c>
    8000031c:	4791                	li	a5,4
    8000031e:	0af48c63          	beq	s1,a5,800003d6 <consoleintr+0x15c>
    80000322:	00010797          	auipc	a5,0x10
    80000326:	8967a783          	lw	a5,-1898(a5) # 8000fbb8 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f6f71fe3          	bne	a4,a5,800002ae <consoleintr+0x34>
    80000334:	a04d                	j	800003d6 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80000336:	0000f717          	auipc	a4,0xf
    8000033a:	7ea70713          	addi	a4,a4,2026 # 8000fb20 <cons>
    8000033e:	0a072783          	lw	a5,160(a4)
    80000342:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000346:	0000f497          	auipc	s1,0xf
    8000034a:	7da48493          	addi	s1,s1,2010 # 8000fb20 <cons>
    while(cons.e != cons.w &&
    8000034e:	4929                	li	s2,10
    80000350:	f4f70fe3          	beq	a4,a5,800002ae <consoleintr+0x34>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000354:	37fd                	addiw	a5,a5,-1
    80000356:	07f7f713          	andi	a4,a5,127
    8000035a:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000035c:	01874703          	lbu	a4,24(a4)
    80000360:	f52707e3          	beq	a4,s2,800002ae <consoleintr+0x34>
      cons.e--;
    80000364:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000368:	10000513          	li	a0,256
    8000036c:	eddff0ef          	jal	ra,80000248 <consputc>
    while(cons.e != cons.w &&
    80000370:	0a04a783          	lw	a5,160(s1)
    80000374:	09c4a703          	lw	a4,156(s1)
    80000378:	fcf71ee3          	bne	a4,a5,80000354 <consoleintr+0xda>
    8000037c:	bf0d                	j	800002ae <consoleintr+0x34>
    if(cons.e != cons.w){
    8000037e:	0000f717          	auipc	a4,0xf
    80000382:	7a270713          	addi	a4,a4,1954 # 8000fb20 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f2f700e3          	beq	a4,a5,800002ae <consoleintr+0x34>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	00010717          	auipc	a4,0x10
    80000398:	82f72623          	sw	a5,-2004(a4) # 8000fbc0 <cons+0xa0>
      consputc(BACKSPACE);
    8000039c:	10000513          	li	a0,256
    800003a0:	ea9ff0ef          	jal	ra,80000248 <consputc>
    800003a4:	b729                	j	800002ae <consoleintr+0x34>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003a6:	f00484e3          	beqz	s1,800002ae <consoleintr+0x34>
    800003aa:	b715                	j	800002ce <consoleintr+0x54>
      consputc(c);
    800003ac:	4529                	li	a0,10
    800003ae:	e9bff0ef          	jal	ra,80000248 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003b2:	0000f797          	auipc	a5,0xf
    800003b6:	76e78793          	addi	a5,a5,1902 # 8000fb20 <cons>
    800003ba:	0a07a703          	lw	a4,160(a5)
    800003be:	0017069b          	addiw	a3,a4,1
    800003c2:	0006861b          	sext.w	a2,a3
    800003c6:	0ad7a023          	sw	a3,160(a5)
    800003ca:	07f77713          	andi	a4,a4,127
    800003ce:	97ba                	add	a5,a5,a4
    800003d0:	4729                	li	a4,10
    800003d2:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003d6:	0000f797          	auipc	a5,0xf
    800003da:	7ec7a323          	sw	a2,2022(a5) # 8000fbbc <cons+0x9c>
        wakeup(&cons.r);
    800003de:	0000f517          	auipc	a0,0xf
    800003e2:	7da50513          	addi	a0,a0,2010 # 8000fbb8 <cons+0x98>
    800003e6:	5bb010ef          	jal	ra,800021a0 <wakeup>
    800003ea:	b5d1                	j	800002ae <consoleintr+0x34>

00000000800003ec <consoleinit>:

void
consoleinit(void)
{
    800003ec:	1141                	addi	sp,sp,-16
    800003ee:	e406                	sd	ra,8(sp)
    800003f0:	e022                	sd	s0,0(sp)
    800003f2:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800003f4:	00007597          	auipc	a1,0x7
    800003f8:	c1c58593          	addi	a1,a1,-996 # 80007010 <etext+0x10>
    800003fc:	0000f517          	auipc	a0,0xf
    80000400:	72450513          	addi	a0,a0,1828 # 8000fb20 <cons>
    80000404:	6e8000ef          	jal	ra,80000aec <initlock>

  uartinit();
    80000408:	3e2000ef          	jal	ra,800007ea <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	00021797          	auipc	a5,0x21
    80000410:	e8478793          	addi	a5,a5,-380 # 80021290 <devsw>
    80000414:	00000717          	auipc	a4,0x0
    80000418:	d3870713          	addi	a4,a4,-712 # 8000014c <consoleread>
    8000041c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000041e:	00000717          	auipc	a4,0x0
    80000422:	cb270713          	addi	a4,a4,-846 # 800000d0 <consolewrite>
    80000426:	ef98                	sd	a4,24(a5)
}
    80000428:	60a2                	ld	ra,8(sp)
    8000042a:	6402                	ld	s0,0(sp)
    8000042c:	0141                	addi	sp,sp,16
    8000042e:	8082                	ret

0000000080000430 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000430:	7139                	addi	sp,sp,-64
    80000432:	fc06                	sd	ra,56(sp)
    80000434:	f822                	sd	s0,48(sp)
    80000436:	f426                	sd	s1,40(sp)
    80000438:	f04a                	sd	s2,32(sp)
    8000043a:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    8000043c:	c219                	beqz	a2,80000442 <printint+0x12>
    8000043e:	06054f63          	bltz	a0,800004bc <printint+0x8c>
    x = -xx;
  else
    x = xx;
    80000442:	4881                	li	a7,0
    80000444:	fc840693          	addi	a3,s0,-56

  i = 0;
    80000448:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000044a:	00007617          	auipc	a2,0x7
    8000044e:	bee60613          	addi	a2,a2,-1042 # 80007038 <digits>
    80000452:	883e                	mv	a6,a5
    80000454:	2785                	addiw	a5,a5,1
    80000456:	02b57733          	remu	a4,a0,a1
    8000045a:	9732                	add	a4,a4,a2
    8000045c:	00074703          	lbu	a4,0(a4)
    80000460:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000464:	872a                	mv	a4,a0
    80000466:	02b55533          	divu	a0,a0,a1
    8000046a:	0685                	addi	a3,a3,1
    8000046c:	feb773e3          	bgeu	a4,a1,80000452 <printint+0x22>

  if(sign)
    80000470:	00088b63          	beqz	a7,80000486 <printint+0x56>
    buf[i++] = '-';
    80000474:	fe040713          	addi	a4,s0,-32
    80000478:	97ba                	add	a5,a5,a4
    8000047a:	02d00713          	li	a4,45
    8000047e:	fee78423          	sb	a4,-24(a5)
    80000482:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80000486:	02f05563          	blez	a5,800004b0 <printint+0x80>
    8000048a:	fc840713          	addi	a4,s0,-56
    8000048e:	00f704b3          	add	s1,a4,a5
    80000492:	fff70913          	addi	s2,a4,-1
    80000496:	993e                	add	s2,s2,a5
    80000498:	37fd                	addiw	a5,a5,-1
    8000049a:	1782                	slli	a5,a5,0x20
    8000049c:	9381                	srli	a5,a5,0x20
    8000049e:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004a2:	fff4c503          	lbu	a0,-1(s1)
    800004a6:	da3ff0ef          	jal	ra,80000248 <consputc>
  while(--i >= 0)
    800004aa:	14fd                	addi	s1,s1,-1
    800004ac:	ff249be3          	bne	s1,s2,800004a2 <printint+0x72>
}
    800004b0:	70e2                	ld	ra,56(sp)
    800004b2:	7442                	ld	s0,48(sp)
    800004b4:	74a2                	ld	s1,40(sp)
    800004b6:	7902                	ld	s2,32(sp)
    800004b8:	6121                	addi	sp,sp,64
    800004ba:	8082                	ret
    x = -xx;
    800004bc:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004c0:	4885                	li	a7,1
    x = -xx;
    800004c2:	b749                	j	80000444 <printint+0x14>

00000000800004c4 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004c4:	7131                	addi	sp,sp,-192
    800004c6:	fc86                	sd	ra,120(sp)
    800004c8:	f8a2                	sd	s0,112(sp)
    800004ca:	f4a6                	sd	s1,104(sp)
    800004cc:	f0ca                	sd	s2,96(sp)
    800004ce:	ecce                	sd	s3,88(sp)
    800004d0:	e8d2                	sd	s4,80(sp)
    800004d2:	e4d6                	sd	s5,72(sp)
    800004d4:	e0da                	sd	s6,64(sp)
    800004d6:	fc5e                	sd	s7,56(sp)
    800004d8:	f862                	sd	s8,48(sp)
    800004da:	f466                	sd	s9,40(sp)
    800004dc:	f06a                	sd	s10,32(sp)
    800004de:	ec6e                	sd	s11,24(sp)
    800004e0:	0100                	addi	s0,sp,128
    800004e2:	8a2a                	mv	s4,a0
    800004e4:	e40c                	sd	a1,8(s0)
    800004e6:	e810                	sd	a2,16(s0)
    800004e8:	ec14                	sd	a3,24(s0)
    800004ea:	f018                	sd	a4,32(s0)
    800004ec:	f41c                	sd	a5,40(s0)
    800004ee:	03043823          	sd	a6,48(s0)
    800004f2:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    800004f6:	00007797          	auipc	a5,0x7
    800004fa:	5fe7a783          	lw	a5,1534(a5) # 80007af4 <panicking>
    800004fe:	cb9d                	beqz	a5,80000534 <printf+0x70>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000500:	00840793          	addi	a5,s0,8
    80000504:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000508:	000a4503          	lbu	a0,0(s4)
    8000050c:	24050363          	beqz	a0,80000752 <printf+0x28e>
    80000510:	4981                	li	s3,0
    if(cx != '%'){
    80000512:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000516:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000051a:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000051e:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000522:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000526:	07000d93          	li	s11,112
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000052a:	00007b97          	auipc	s7,0x7
    8000052e:	b0eb8b93          	addi	s7,s7,-1266 # 80007038 <digits>
    80000532:	a01d                	j	80000558 <printf+0x94>
    acquire(&pr.lock);
    80000534:	0000f517          	auipc	a0,0xf
    80000538:	69450513          	addi	a0,a0,1684 # 8000fbc8 <pr>
    8000053c:	630000ef          	jal	ra,80000b6c <acquire>
    80000540:	b7c1                	j	80000500 <printf+0x3c>
      consputc(cx);
    80000542:	d07ff0ef          	jal	ra,80000248 <consputc>
      continue;
    80000546:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000548:	0014899b          	addiw	s3,s1,1
    8000054c:	013a07b3          	add	a5,s4,s3
    80000550:	0007c503          	lbu	a0,0(a5)
    80000554:	1e050f63          	beqz	a0,80000752 <printf+0x28e>
    if(cx != '%'){
    80000558:	ff5515e3          	bne	a0,s5,80000542 <printf+0x7e>
    i++;
    8000055c:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80000560:	009a07b3          	add	a5,s4,s1
    80000564:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000568:	1e090563          	beqz	s2,80000752 <printf+0x28e>
    8000056c:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000570:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000572:	c789                	beqz	a5,8000057c <printf+0xb8>
    80000574:	009a0733          	add	a4,s4,s1
    80000578:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    8000057c:	03690863          	beq	s2,s6,800005ac <printf+0xe8>
    } else if(c0 == 'l' && c1 == 'd'){
    80000580:	05890263          	beq	s2,s8,800005c4 <printf+0x100>
    } else if(c0 == 'u'){
    80000584:	0d990163          	beq	s2,s9,80000646 <printf+0x182>
    } else if(c0 == 'x'){
    80000588:	11a90863          	beq	s2,s10,80000698 <printf+0x1d4>
    } else if(c0 == 'p'){
    8000058c:	15b90163          	beq	s2,s11,800006ce <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    80000590:	06300793          	li	a5,99
    80000594:	16f90963          	beq	s2,a5,80000706 <printf+0x242>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    80000598:	07300793          	li	a5,115
    8000059c:	16f90f63          	beq	s2,a5,8000071a <printf+0x256>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005a0:	03591c63          	bne	s2,s5,800005d8 <printf+0x114>
      consputc('%');
    800005a4:	8556                	mv	a0,s5
    800005a6:	ca3ff0ef          	jal	ra,80000248 <consputc>
    800005aa:	bf79                	j	80000548 <printf+0x84>
      printint(va_arg(ap, int), 10, 1);
    800005ac:	f8843783          	ld	a5,-120(s0)
    800005b0:	00878713          	addi	a4,a5,8
    800005b4:	f8e43423          	sd	a4,-120(s0)
    800005b8:	4605                	li	a2,1
    800005ba:	45a9                	li	a1,10
    800005bc:	4388                	lw	a0,0(a5)
    800005be:	e73ff0ef          	jal	ra,80000430 <printint>
    800005c2:	b759                	j	80000548 <printf+0x84>
    } else if(c0 == 'l' && c1 == 'd'){
    800005c4:	03678163          	beq	a5,s6,800005e6 <printf+0x122>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005c8:	03878d63          	beq	a5,s8,80000602 <printf+0x13e>
    } else if(c0 == 'l' && c1 == 'u'){
    800005cc:	09978a63          	beq	a5,s9,80000660 <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800005d0:	03878b63          	beq	a5,s8,80000606 <printf+0x142>
    } else if(c0 == 'l' && c1 == 'x'){
    800005d4:	0da78f63          	beq	a5,s10,800006b2 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005d8:	8556                	mv	a0,s5
    800005da:	c6fff0ef          	jal	ra,80000248 <consputc>
      consputc(c0);
    800005de:	854a                	mv	a0,s2
    800005e0:	c69ff0ef          	jal	ra,80000248 <consputc>
    800005e4:	b795                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint64), 10, 1);
    800005e6:	f8843783          	ld	a5,-120(s0)
    800005ea:	00878713          	addi	a4,a5,8
    800005ee:	f8e43423          	sd	a4,-120(s0)
    800005f2:	4605                	li	a2,1
    800005f4:	45a9                	li	a1,10
    800005f6:	6388                	ld	a0,0(a5)
    800005f8:	e39ff0ef          	jal	ra,80000430 <printint>
      i += 1;
    800005fc:	0029849b          	addiw	s1,s3,2
    80000600:	b7a1                	j	80000548 <printf+0x84>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000602:	03668463          	beq	a3,s6,8000062a <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000606:	07968b63          	beq	a3,s9,8000067c <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000060a:	fda697e3          	bne	a3,s10,800005d8 <printf+0x114>
      printint(va_arg(ap, uint64), 16, 0);
    8000060e:	f8843783          	ld	a5,-120(s0)
    80000612:	00878713          	addi	a4,a5,8
    80000616:	f8e43423          	sd	a4,-120(s0)
    8000061a:	4601                	li	a2,0
    8000061c:	45c1                	li	a1,16
    8000061e:	6388                	ld	a0,0(a5)
    80000620:	e11ff0ef          	jal	ra,80000430 <printint>
      i += 2;
    80000624:	0039849b          	addiw	s1,s3,3
    80000628:	b705                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint64), 10, 1);
    8000062a:	f8843783          	ld	a5,-120(s0)
    8000062e:	00878713          	addi	a4,a5,8
    80000632:	f8e43423          	sd	a4,-120(s0)
    80000636:	4605                	li	a2,1
    80000638:	45a9                	li	a1,10
    8000063a:	6388                	ld	a0,0(a5)
    8000063c:	df5ff0ef          	jal	ra,80000430 <printint>
      i += 2;
    80000640:	0039849b          	addiw	s1,s3,3
    80000644:	b711                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint32), 10, 0);
    80000646:	f8843783          	ld	a5,-120(s0)
    8000064a:	00878713          	addi	a4,a5,8
    8000064e:	f8e43423          	sd	a4,-120(s0)
    80000652:	4601                	li	a2,0
    80000654:	45a9                	li	a1,10
    80000656:	0007e503          	lwu	a0,0(a5)
    8000065a:	dd7ff0ef          	jal	ra,80000430 <printint>
    8000065e:	b5ed                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint64), 10, 0);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4601                	li	a2,0
    8000066e:	45a9                	li	a1,10
    80000670:	6388                	ld	a0,0(a5)
    80000672:	dbfff0ef          	jal	ra,80000430 <printint>
      i += 1;
    80000676:	0029849b          	addiw	s1,s3,2
    8000067a:	b5f9                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint64), 10, 0);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4601                	li	a2,0
    8000068a:	45a9                	li	a1,10
    8000068c:	6388                	ld	a0,0(a5)
    8000068e:	da3ff0ef          	jal	ra,80000430 <printint>
      i += 2;
    80000692:	0039849b          	addiw	s1,s3,3
    80000696:	bd4d                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint32), 16, 0);
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	4601                	li	a2,0
    800006a6:	45c1                	li	a1,16
    800006a8:	0007e503          	lwu	a0,0(a5)
    800006ac:	d85ff0ef          	jal	ra,80000430 <printint>
    800006b0:	bd61                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint64), 16, 0);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4601                	li	a2,0
    800006c0:	45c1                	li	a1,16
    800006c2:	6388                	ld	a0,0(a5)
    800006c4:	d6dff0ef          	jal	ra,80000430 <printint>
      i += 1;
    800006c8:	0029849b          	addiw	s1,s3,2
    800006cc:	bdb5                	j	80000548 <printf+0x84>
      printptr(va_arg(ap, uint64));
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	addi	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006de:	03000513          	li	a0,48
    800006e2:	b67ff0ef          	jal	ra,80000248 <consputc>
  consputc('x');
    800006e6:	856a                	mv	a0,s10
    800006e8:	b61ff0ef          	jal	ra,80000248 <consputc>
    800006ec:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ee:	03c9d793          	srli	a5,s3,0x3c
    800006f2:	97de                	add	a5,a5,s7
    800006f4:	0007c503          	lbu	a0,0(a5)
    800006f8:	b51ff0ef          	jal	ra,80000248 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006fc:	0992                	slli	s3,s3,0x4
    800006fe:	397d                	addiw	s2,s2,-1
    80000700:	fe0917e3          	bnez	s2,800006ee <printf+0x22a>
    80000704:	b591                	j	80000548 <printf+0x84>
      consputc(va_arg(ap, uint));
    80000706:	f8843783          	ld	a5,-120(s0)
    8000070a:	00878713          	addi	a4,a5,8
    8000070e:	f8e43423          	sd	a4,-120(s0)
    80000712:	4388                	lw	a0,0(a5)
    80000714:	b35ff0ef          	jal	ra,80000248 <consputc>
    80000718:	bd05                	j	80000548 <printf+0x84>
      if((s = va_arg(ap, char*)) == 0)
    8000071a:	f8843783          	ld	a5,-120(s0)
    8000071e:	00878713          	addi	a4,a5,8
    80000722:	f8e43423          	sd	a4,-120(s0)
    80000726:	0007b903          	ld	s2,0(a5)
    8000072a:	00090d63          	beqz	s2,80000744 <printf+0x280>
      for(; *s; s++)
    8000072e:	00094503          	lbu	a0,0(s2)
    80000732:	e0050be3          	beqz	a0,80000548 <printf+0x84>
        consputc(*s);
    80000736:	b13ff0ef          	jal	ra,80000248 <consputc>
      for(; *s; s++)
    8000073a:	0905                	addi	s2,s2,1
    8000073c:	00094503          	lbu	a0,0(s2)
    80000740:	f97d                	bnez	a0,80000736 <printf+0x272>
    80000742:	b519                	j	80000548 <printf+0x84>
        s = "(null)";
    80000744:	00007917          	auipc	s2,0x7
    80000748:	8d490913          	addi	s2,s2,-1836 # 80007018 <etext+0x18>
      for(; *s; s++)
    8000074c:	02800513          	li	a0,40
    80000750:	b7dd                	j	80000736 <printf+0x272>
    }

  }
  va_end(ap);

  if(panicking == 0)
    80000752:	00007797          	auipc	a5,0x7
    80000756:	3a27a783          	lw	a5,930(a5) # 80007af4 <panicking>
    8000075a:	c38d                	beqz	a5,8000077c <printf+0x2b8>
    release(&pr.lock);

  return 0;
}
    8000075c:	4501                	li	a0,0
    8000075e:	70e6                	ld	ra,120(sp)
    80000760:	7446                	ld	s0,112(sp)
    80000762:	74a6                	ld	s1,104(sp)
    80000764:	7906                	ld	s2,96(sp)
    80000766:	69e6                	ld	s3,88(sp)
    80000768:	6a46                	ld	s4,80(sp)
    8000076a:	6aa6                	ld	s5,72(sp)
    8000076c:	6b06                	ld	s6,64(sp)
    8000076e:	7be2                	ld	s7,56(sp)
    80000770:	7c42                	ld	s8,48(sp)
    80000772:	7ca2                	ld	s9,40(sp)
    80000774:	7d02                	ld	s10,32(sp)
    80000776:	6de2                	ld	s11,24(sp)
    80000778:	6129                	addi	sp,sp,192
    8000077a:	8082                	ret
    release(&pr.lock);
    8000077c:	0000f517          	auipc	a0,0xf
    80000780:	44c50513          	addi	a0,a0,1100 # 8000fbc8 <pr>
    80000784:	480000ef          	jal	ra,80000c04 <release>
  return 0;
    80000788:	bfd1                	j	8000075c <printf+0x298>

000000008000078a <panic>:

void
panic(char *s)
{
    8000078a:	1101                	addi	sp,sp,-32
    8000078c:	ec06                	sd	ra,24(sp)
    8000078e:	e822                	sd	s0,16(sp)
    80000790:	e426                	sd	s1,8(sp)
    80000792:	e04a                	sd	s2,0(sp)
    80000794:	1000                	addi	s0,sp,32
    80000796:	84aa                	mv	s1,a0
  panicking = 1;
    80000798:	4905                	li	s2,1
    8000079a:	00007797          	auipc	a5,0x7
    8000079e:	3527ad23          	sw	s2,858(a5) # 80007af4 <panicking>
  printf("panic: ");
    800007a2:	00007517          	auipc	a0,0x7
    800007a6:	87e50513          	addi	a0,a0,-1922 # 80007020 <etext+0x20>
    800007aa:	d1bff0ef          	jal	ra,800004c4 <printf>
  printf("%s\n", s);
    800007ae:	85a6                	mv	a1,s1
    800007b0:	00007517          	auipc	a0,0x7
    800007b4:	87850513          	addi	a0,a0,-1928 # 80007028 <etext+0x28>
    800007b8:	d0dff0ef          	jal	ra,800004c4 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007bc:	00007797          	auipc	a5,0x7
    800007c0:	3327aa23          	sw	s2,820(a5) # 80007af0 <panicked>
  for(;;)
    800007c4:	a001                	j	800007c4 <panic+0x3a>

00000000800007c6 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007c6:	1141                	addi	sp,sp,-16
    800007c8:	e406                	sd	ra,8(sp)
    800007ca:	e022                	sd	s0,0(sp)
    800007cc:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    800007ce:	00007597          	auipc	a1,0x7
    800007d2:	86258593          	addi	a1,a1,-1950 # 80007030 <etext+0x30>
    800007d6:	0000f517          	auipc	a0,0xf
    800007da:	3f250513          	addi	a0,a0,1010 # 8000fbc8 <pr>
    800007de:	30e000ef          	jal	ra,80000aec <initlock>
}
    800007e2:	60a2                	ld	ra,8(sp)
    800007e4:	6402                	ld	s0,0(sp)
    800007e6:	0141                	addi	sp,sp,16
    800007e8:	8082                	ret

00000000800007ea <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    800007ea:	1141                	addi	sp,sp,-16
    800007ec:	e406                	sd	ra,8(sp)
    800007ee:	e022                	sd	s0,0(sp)
    800007f0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007f2:	100007b7          	lui	a5,0x10000
    800007f6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007fa:	f8000713          	li	a4,-128
    800007fe:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000802:	470d                	li	a4,3
    80000804:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000808:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000080c:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000810:	469d                	li	a3,7
    80000812:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000816:	00e780a3          	sb	a4,1(a5)

  initlock(&tx_lock, "uart");
    8000081a:	00007597          	auipc	a1,0x7
    8000081e:	83658593          	addi	a1,a1,-1994 # 80007050 <digits+0x18>
    80000822:	0000f517          	auipc	a0,0xf
    80000826:	3be50513          	addi	a0,a0,958 # 8000fbe0 <tx_lock>
    8000082a:	2c2000ef          	jal	ra,80000aec <initlock>
}
    8000082e:	60a2                	ld	ra,8(sp)
    80000830:	6402                	ld	s0,0(sp)
    80000832:	0141                	addi	sp,sp,16
    80000834:	8082                	ret

0000000080000836 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    80000836:	715d                	addi	sp,sp,-80
    80000838:	e486                	sd	ra,72(sp)
    8000083a:	e0a2                	sd	s0,64(sp)
    8000083c:	fc26                	sd	s1,56(sp)
    8000083e:	f84a                	sd	s2,48(sp)
    80000840:	f44e                	sd	s3,40(sp)
    80000842:	f052                	sd	s4,32(sp)
    80000844:	ec56                	sd	s5,24(sp)
    80000846:	e85a                	sd	s6,16(sp)
    80000848:	e45e                	sd	s7,8(sp)
    8000084a:	0880                	addi	s0,sp,80
    8000084c:	84aa                	mv	s1,a0
    8000084e:	8aae                	mv	s5,a1
  acquire(&tx_lock);
    80000850:	0000f517          	auipc	a0,0xf
    80000854:	39050513          	addi	a0,a0,912 # 8000fbe0 <tx_lock>
    80000858:	314000ef          	jal	ra,80000b6c <acquire>

  int i = 0;
  while(i < n){ 
    8000085c:	05505b63          	blez	s5,800008b2 <uartwrite+0x7c>
    80000860:	8a26                	mv	s4,s1
    80000862:	0485                	addi	s1,s1,1
    80000864:	3afd                	addiw	s5,s5,-1
    80000866:	1a82                	slli	s5,s5,0x20
    80000868:	020ada93          	srli	s5,s5,0x20
    8000086c:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    8000086e:	00007497          	auipc	s1,0x7
    80000872:	28e48493          	addi	s1,s1,654 # 80007afc <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000876:	0000f997          	auipc	s3,0xf
    8000087a:	36a98993          	addi	s3,s3,874 # 8000fbe0 <tx_lock>
    8000087e:	00007917          	auipc	s2,0x7
    80000882:	27a90913          	addi	s2,s2,634 # 80007af8 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    80000886:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    8000088a:	4b05                	li	s6,1
    8000088c:	a005                	j	800008ac <uartwrite+0x76>
      sleep(&tx_chan, &tx_lock);
    8000088e:	85ce                	mv	a1,s3
    80000890:	854a                	mv	a0,s2
    80000892:	0c3010ef          	jal	ra,80002154 <sleep>
    while(tx_busy != 0){
    80000896:	409c                	lw	a5,0(s1)
    80000898:	fbfd                	bnez	a5,8000088e <uartwrite+0x58>
    WriteReg(THR, buf[i]);
    8000089a:	000a4783          	lbu	a5,0(s4)
    8000089e:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    800008a2:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    800008a6:	0a05                	addi	s4,s4,1
    800008a8:	015a0563          	beq	s4,s5,800008b2 <uartwrite+0x7c>
    while(tx_busy != 0){
    800008ac:	409c                	lw	a5,0(s1)
    800008ae:	f3e5                	bnez	a5,8000088e <uartwrite+0x58>
    800008b0:	b7ed                	j	8000089a <uartwrite+0x64>
  }

  release(&tx_lock);
    800008b2:	0000f517          	auipc	a0,0xf
    800008b6:	32e50513          	addi	a0,a0,814 # 8000fbe0 <tx_lock>
    800008ba:	34a000ef          	jal	ra,80000c04 <release>
}
    800008be:	60a6                	ld	ra,72(sp)
    800008c0:	6406                	ld	s0,64(sp)
    800008c2:	74e2                	ld	s1,56(sp)
    800008c4:	7942                	ld	s2,48(sp)
    800008c6:	79a2                	ld	s3,40(sp)
    800008c8:	7a02                	ld	s4,32(sp)
    800008ca:	6ae2                	ld	s5,24(sp)
    800008cc:	6b42                	ld	s6,16(sp)
    800008ce:	6ba2                	ld	s7,8(sp)
    800008d0:	6161                	addi	sp,sp,80
    800008d2:	8082                	ret

00000000800008d4 <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800008d4:	1101                	addi	sp,sp,-32
    800008d6:	ec06                	sd	ra,24(sp)
    800008d8:	e822                	sd	s0,16(sp)
    800008da:	e426                	sd	s1,8(sp)
    800008dc:	1000                	addi	s0,sp,32
    800008de:	84aa                	mv	s1,a0
  if(panicking == 0)
    800008e0:	00007797          	auipc	a5,0x7
    800008e4:	2147a783          	lw	a5,532(a5) # 80007af4 <panicking>
    800008e8:	cb89                	beqz	a5,800008fa <uartputc_sync+0x26>
    push_off();

  if(panicked){
    800008ea:	00007797          	auipc	a5,0x7
    800008ee:	2067a783          	lw	a5,518(a5) # 80007af0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800008f2:	10000737          	lui	a4,0x10000
  if(panicked){
    800008f6:	c789                	beqz	a5,80000900 <uartputc_sync+0x2c>
    for(;;)
    800008f8:	a001                	j	800008f8 <uartputc_sync+0x24>
    push_off();
    800008fa:	232000ef          	jal	ra,80000b2c <push_off>
    800008fe:	b7f5                	j	800008ea <uartputc_sync+0x16>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000900:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000904:	0207f793          	andi	a5,a5,32
    80000908:	dfe5                	beqz	a5,80000900 <uartputc_sync+0x2c>
    ;
  WriteReg(THR, c);
    8000090a:	0ff4f513          	andi	a0,s1,255
    8000090e:	100007b7          	lui	a5,0x10000
    80000912:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80000916:	00007797          	auipc	a5,0x7
    8000091a:	1de7a783          	lw	a5,478(a5) # 80007af4 <panicking>
    8000091e:	c791                	beqz	a5,8000092a <uartputc_sync+0x56>
    pop_off();
}
    80000920:	60e2                	ld	ra,24(sp)
    80000922:	6442                	ld	s0,16(sp)
    80000924:	64a2                	ld	s1,8(sp)
    80000926:	6105                	addi	sp,sp,32
    80000928:	8082                	ret
    pop_off();
    8000092a:	286000ef          	jal	ra,80000bb0 <pop_off>
}
    8000092e:	bfcd                	j	80000920 <uartputc_sync+0x4c>

0000000080000930 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000930:	1141                	addi	sp,sp,-16
    80000932:	e422                	sd	s0,8(sp)
    80000934:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    80000936:	100007b7          	lui	a5,0x10000
    8000093a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000093e:	8b85                	andi	a5,a5,1
    80000940:	cb91                	beqz	a5,80000954 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000942:	100007b7          	lui	a5,0x10000
    80000946:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000094a:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000094e:	6422                	ld	s0,8(sp)
    80000950:	0141                	addi	sp,sp,16
    80000952:	8082                	ret
    return -1;
    80000954:	557d                	li	a0,-1
    80000956:	bfe5                	j	8000094e <uartgetc+0x1e>

0000000080000958 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000958:	1101                	addi	sp,sp,-32
    8000095a:	ec06                	sd	ra,24(sp)
    8000095c:	e822                	sd	s0,16(sp)
    8000095e:	e426                	sd	s1,8(sp)
    80000960:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    80000962:	100004b7          	lui	s1,0x10000
    80000966:	0024c783          	lbu	a5,2(s1) # 10000002 <_entry-0x6ffffffe>

  acquire(&tx_lock);
    8000096a:	0000f517          	auipc	a0,0xf
    8000096e:	27650513          	addi	a0,a0,630 # 8000fbe0 <tx_lock>
    80000972:	1fa000ef          	jal	ra,80000b6c <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    80000976:	0054c783          	lbu	a5,5(s1)
    8000097a:	0207f793          	andi	a5,a5,32
    8000097e:	eb89                	bnez	a5,80000990 <uartintr+0x38>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    80000980:	0000f517          	auipc	a0,0xf
    80000984:	26050513          	addi	a0,a0,608 # 8000fbe0 <tx_lock>
    80000988:	27c000ef          	jal	ra,80000c04 <release>

  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000098c:	54fd                	li	s1,-1
    8000098e:	a831                	j	800009aa <uartintr+0x52>
    tx_busy = 0;
    80000990:	00007797          	auipc	a5,0x7
    80000994:	1607a623          	sw	zero,364(a5) # 80007afc <tx_busy>
    wakeup(&tx_chan);
    80000998:	00007517          	auipc	a0,0x7
    8000099c:	16050513          	addi	a0,a0,352 # 80007af8 <tx_chan>
    800009a0:	001010ef          	jal	ra,800021a0 <wakeup>
    800009a4:	bff1                	j	80000980 <uartintr+0x28>
      break;
    consoleintr(c);
    800009a6:	8d5ff0ef          	jal	ra,8000027a <consoleintr>
    int c = uartgetc();
    800009aa:	f87ff0ef          	jal	ra,80000930 <uartgetc>
    if(c == -1)
    800009ae:	fe951ce3          	bne	a0,s1,800009a6 <uartintr+0x4e>
  }
}
    800009b2:	60e2                	ld	ra,24(sp)
    800009b4:	6442                	ld	s0,16(sp)
    800009b6:	64a2                	ld	s1,8(sp)
    800009b8:	6105                	addi	sp,sp,32
    800009ba:	8082                	ret

00000000800009bc <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009bc:	1101                	addi	sp,sp,-32
    800009be:	ec06                	sd	ra,24(sp)
    800009c0:	e822                	sd	s0,16(sp)
    800009c2:	e426                	sd	s1,8(sp)
    800009c4:	e04a                	sd	s2,0(sp)
    800009c6:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009c8:	03451793          	slli	a5,a0,0x34
    800009cc:	e7a9                	bnez	a5,80000a16 <kfree+0x5a>
    800009ce:	84aa                	mv	s1,a0
    800009d0:	00022797          	auipc	a5,0x22
    800009d4:	a5878793          	addi	a5,a5,-1448 # 80022428 <end>
    800009d8:	02f56f63          	bltu	a0,a5,80000a16 <kfree+0x5a>
    800009dc:	47c5                	li	a5,17
    800009de:	07ee                	slli	a5,a5,0x1b
    800009e0:	02f57b63          	bgeu	a0,a5,80000a16 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    800009e4:	6605                	lui	a2,0x1
    800009e6:	4585                	li	a1,1
    800009e8:	258000ef          	jal	ra,80000c40 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    800009ec:	0000f917          	auipc	s2,0xf
    800009f0:	20c90913          	addi	s2,s2,524 # 8000fbf8 <kmem>
    800009f4:	854a                	mv	a0,s2
    800009f6:	176000ef          	jal	ra,80000b6c <acquire>
  r->next = kmem.freelist;
    800009fa:	01893783          	ld	a5,24(s2)
    800009fe:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a00:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a04:	854a                	mv	a0,s2
    80000a06:	1fe000ef          	jal	ra,80000c04 <release>
}
    80000a0a:	60e2                	ld	ra,24(sp)
    80000a0c:	6442                	ld	s0,16(sp)
    80000a0e:	64a2                	ld	s1,8(sp)
    80000a10:	6902                	ld	s2,0(sp)
    80000a12:	6105                	addi	sp,sp,32
    80000a14:	8082                	ret
    panic("kfree");
    80000a16:	00006517          	auipc	a0,0x6
    80000a1a:	64250513          	addi	a0,a0,1602 # 80007058 <digits+0x20>
    80000a1e:	d6dff0ef          	jal	ra,8000078a <panic>

0000000080000a22 <freerange>:
{
    80000a22:	7179                	addi	sp,sp,-48
    80000a24:	f406                	sd	ra,40(sp)
    80000a26:	f022                	sd	s0,32(sp)
    80000a28:	ec26                	sd	s1,24(sp)
    80000a2a:	e84a                	sd	s2,16(sp)
    80000a2c:	e44e                	sd	s3,8(sp)
    80000a2e:	e052                	sd	s4,0(sp)
    80000a30:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a32:	6785                	lui	a5,0x1
    80000a34:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a38:	94aa                	add	s1,s1,a0
    80000a3a:	757d                	lui	a0,0xfffff
    80000a3c:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a3e:	94be                	add	s1,s1,a5
    80000a40:	0095ec63          	bltu	a1,s1,80000a58 <freerange+0x36>
    80000a44:	892e                	mv	s2,a1
    kfree(p);
    80000a46:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a48:	6985                	lui	s3,0x1
    kfree(p);
    80000a4a:	01448533          	add	a0,s1,s4
    80000a4e:	f6fff0ef          	jal	ra,800009bc <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a52:	94ce                	add	s1,s1,s3
    80000a54:	fe997be3          	bgeu	s2,s1,80000a4a <freerange+0x28>
}
    80000a58:	70a2                	ld	ra,40(sp)
    80000a5a:	7402                	ld	s0,32(sp)
    80000a5c:	64e2                	ld	s1,24(sp)
    80000a5e:	6942                	ld	s2,16(sp)
    80000a60:	69a2                	ld	s3,8(sp)
    80000a62:	6a02                	ld	s4,0(sp)
    80000a64:	6145                	addi	sp,sp,48
    80000a66:	8082                	ret

0000000080000a68 <kinit>:
{
    80000a68:	1141                	addi	sp,sp,-16
    80000a6a:	e406                	sd	ra,8(sp)
    80000a6c:	e022                	sd	s0,0(sp)
    80000a6e:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a70:	00006597          	auipc	a1,0x6
    80000a74:	5f058593          	addi	a1,a1,1520 # 80007060 <digits+0x28>
    80000a78:	0000f517          	auipc	a0,0xf
    80000a7c:	18050513          	addi	a0,a0,384 # 8000fbf8 <kmem>
    80000a80:	06c000ef          	jal	ra,80000aec <initlock>
  freerange(end, (void*)PHYSTOP);
    80000a84:	45c5                	li	a1,17
    80000a86:	05ee                	slli	a1,a1,0x1b
    80000a88:	00022517          	auipc	a0,0x22
    80000a8c:	9a050513          	addi	a0,a0,-1632 # 80022428 <end>
    80000a90:	f93ff0ef          	jal	ra,80000a22 <freerange>
}
    80000a94:	60a2                	ld	ra,8(sp)
    80000a96:	6402                	ld	s0,0(sp)
    80000a98:	0141                	addi	sp,sp,16
    80000a9a:	8082                	ret

0000000080000a9c <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000a9c:	1101                	addi	sp,sp,-32
    80000a9e:	ec06                	sd	ra,24(sp)
    80000aa0:	e822                	sd	s0,16(sp)
    80000aa2:	e426                	sd	s1,8(sp)
    80000aa4:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aa6:	0000f497          	auipc	s1,0xf
    80000aaa:	15248493          	addi	s1,s1,338 # 8000fbf8 <kmem>
    80000aae:	8526                	mv	a0,s1
    80000ab0:	0bc000ef          	jal	ra,80000b6c <acquire>
  r = kmem.freelist;
    80000ab4:	6c84                	ld	s1,24(s1)
  if(r)
    80000ab6:	c485                	beqz	s1,80000ade <kalloc+0x42>
    kmem.freelist = r->next;
    80000ab8:	609c                	ld	a5,0(s1)
    80000aba:	0000f517          	auipc	a0,0xf
    80000abe:	13e50513          	addi	a0,a0,318 # 8000fbf8 <kmem>
    80000ac2:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000ac4:	140000ef          	jal	ra,80000c04 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000ac8:	6605                	lui	a2,0x1
    80000aca:	4595                	li	a1,5
    80000acc:	8526                	mv	a0,s1
    80000ace:	172000ef          	jal	ra,80000c40 <memset>
  return (void*)r;
}
    80000ad2:	8526                	mv	a0,s1
    80000ad4:	60e2                	ld	ra,24(sp)
    80000ad6:	6442                	ld	s0,16(sp)
    80000ad8:	64a2                	ld	s1,8(sp)
    80000ada:	6105                	addi	sp,sp,32
    80000adc:	8082                	ret
  release(&kmem.lock);
    80000ade:	0000f517          	auipc	a0,0xf
    80000ae2:	11a50513          	addi	a0,a0,282 # 8000fbf8 <kmem>
    80000ae6:	11e000ef          	jal	ra,80000c04 <release>
  if(r)
    80000aea:	b7e5                	j	80000ad2 <kalloc+0x36>

0000000080000aec <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000aec:	1141                	addi	sp,sp,-16
    80000aee:	e422                	sd	s0,8(sp)
    80000af0:	0800                	addi	s0,sp,16
  lk->name = name;
    80000af2:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000af4:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000af8:	00053823          	sd	zero,16(a0)
}
    80000afc:	6422                	ld	s0,8(sp)
    80000afe:	0141                	addi	sp,sp,16
    80000b00:	8082                	ret

0000000080000b02 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b02:	411c                	lw	a5,0(a0)
    80000b04:	e399                	bnez	a5,80000b0a <holding+0x8>
    80000b06:	4501                	li	a0,0
  return r;
}
    80000b08:	8082                	ret
{
    80000b0a:	1101                	addi	sp,sp,-32
    80000b0c:	ec06                	sd	ra,24(sp)
    80000b0e:	e822                	sd	s0,16(sp)
    80000b10:	e426                	sd	s1,8(sp)
    80000b12:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b14:	6904                	ld	s1,16(a0)
    80000b16:	000010ef          	jal	ra,80001b16 <mycpu>
    80000b1a:	40a48533          	sub	a0,s1,a0
    80000b1e:	00153513          	seqz	a0,a0
}
    80000b22:	60e2                	ld	ra,24(sp)
    80000b24:	6442                	ld	s0,16(sp)
    80000b26:	64a2                	ld	s1,8(sp)
    80000b28:	6105                	addi	sp,sp,32
    80000b2a:	8082                	ret

0000000080000b2c <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b2c:	1101                	addi	sp,sp,-32
    80000b2e:	ec06                	sd	ra,24(sp)
    80000b30:	e822                	sd	s0,16(sp)
    80000b32:	e426                	sd	s1,8(sp)
    80000b34:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b36:	100024f3          	csrr	s1,sstatus
    80000b3a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b3e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b40:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000b44:	7d3000ef          	jal	ra,80001b16 <mycpu>
    80000b48:	5d3c                	lw	a5,120(a0)
    80000b4a:	cb99                	beqz	a5,80000b60 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b4c:	7cb000ef          	jal	ra,80001b16 <mycpu>
    80000b50:	5d3c                	lw	a5,120(a0)
    80000b52:	2785                	addiw	a5,a5,1
    80000b54:	dd3c                	sw	a5,120(a0)
}
    80000b56:	60e2                	ld	ra,24(sp)
    80000b58:	6442                	ld	s0,16(sp)
    80000b5a:	64a2                	ld	s1,8(sp)
    80000b5c:	6105                	addi	sp,sp,32
    80000b5e:	8082                	ret
    mycpu()->intena = old;
    80000b60:	7b7000ef          	jal	ra,80001b16 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000b64:	8085                	srli	s1,s1,0x1
    80000b66:	8885                	andi	s1,s1,1
    80000b68:	dd64                	sw	s1,124(a0)
    80000b6a:	b7cd                	j	80000b4c <push_off+0x20>

0000000080000b6c <acquire>:
{
    80000b6c:	1101                	addi	sp,sp,-32
    80000b6e:	ec06                	sd	ra,24(sp)
    80000b70:	e822                	sd	s0,16(sp)
    80000b72:	e426                	sd	s1,8(sp)
    80000b74:	1000                	addi	s0,sp,32
    80000b76:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000b78:	fb5ff0ef          	jal	ra,80000b2c <push_off>
  if(holding(lk))
    80000b7c:	8526                	mv	a0,s1
    80000b7e:	f85ff0ef          	jal	ra,80000b02 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000b82:	4705                	li	a4,1
  if(holding(lk))
    80000b84:	e105                	bnez	a0,80000ba4 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000b86:	87ba                	mv	a5,a4
    80000b88:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000b8c:	2781                	sext.w	a5,a5
    80000b8e:	ffe5                	bnez	a5,80000b86 <acquire+0x1a>
  __sync_synchronize();
    80000b90:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000b94:	783000ef          	jal	ra,80001b16 <mycpu>
    80000b98:	e888                	sd	a0,16(s1)
}
    80000b9a:	60e2                	ld	ra,24(sp)
    80000b9c:	6442                	ld	s0,16(sp)
    80000b9e:	64a2                	ld	s1,8(sp)
    80000ba0:	6105                	addi	sp,sp,32
    80000ba2:	8082                	ret
    panic("acquire");
    80000ba4:	00006517          	auipc	a0,0x6
    80000ba8:	4c450513          	addi	a0,a0,1220 # 80007068 <digits+0x30>
    80000bac:	bdfff0ef          	jal	ra,8000078a <panic>

0000000080000bb0 <pop_off>:

void
pop_off(void)
{
    80000bb0:	1141                	addi	sp,sp,-16
    80000bb2:	e406                	sd	ra,8(sp)
    80000bb4:	e022                	sd	s0,0(sp)
    80000bb6:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000bb8:	75f000ef          	jal	ra,80001b16 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bbc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000bc0:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000bc2:	e78d                	bnez	a5,80000bec <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000bc4:	5d3c                	lw	a5,120(a0)
    80000bc6:	02f05963          	blez	a5,80000bf8 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000bca:	37fd                	addiw	a5,a5,-1
    80000bcc:	0007871b          	sext.w	a4,a5
    80000bd0:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000bd2:	eb09                	bnez	a4,80000be4 <pop_off+0x34>
    80000bd4:	5d7c                	lw	a5,124(a0)
    80000bd6:	c799                	beqz	a5,80000be4 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bd8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000bdc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000be0:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000be4:	60a2                	ld	ra,8(sp)
    80000be6:	6402                	ld	s0,0(sp)
    80000be8:	0141                	addi	sp,sp,16
    80000bea:	8082                	ret
    panic("pop_off - interruptible");
    80000bec:	00006517          	auipc	a0,0x6
    80000bf0:	48450513          	addi	a0,a0,1156 # 80007070 <digits+0x38>
    80000bf4:	b97ff0ef          	jal	ra,8000078a <panic>
    panic("pop_off");
    80000bf8:	00006517          	auipc	a0,0x6
    80000bfc:	49050513          	addi	a0,a0,1168 # 80007088 <digits+0x50>
    80000c00:	b8bff0ef          	jal	ra,8000078a <panic>

0000000080000c04 <release>:
{
    80000c04:	1101                	addi	sp,sp,-32
    80000c06:	ec06                	sd	ra,24(sp)
    80000c08:	e822                	sd	s0,16(sp)
    80000c0a:	e426                	sd	s1,8(sp)
    80000c0c:	1000                	addi	s0,sp,32
    80000c0e:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c10:	ef3ff0ef          	jal	ra,80000b02 <holding>
    80000c14:	c105                	beqz	a0,80000c34 <release+0x30>
  lk->cpu = 0;
    80000c16:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c1a:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000c1e:	0f50000f          	fence	iorw,ow
    80000c22:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c26:	f8bff0ef          	jal	ra,80000bb0 <pop_off>
}
    80000c2a:	60e2                	ld	ra,24(sp)
    80000c2c:	6442                	ld	s0,16(sp)
    80000c2e:	64a2                	ld	s1,8(sp)
    80000c30:	6105                	addi	sp,sp,32
    80000c32:	8082                	ret
    panic("release");
    80000c34:	00006517          	auipc	a0,0x6
    80000c38:	45c50513          	addi	a0,a0,1116 # 80007090 <digits+0x58>
    80000c3c:	b4fff0ef          	jal	ra,8000078a <panic>

0000000080000c40 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000c40:	1141                	addi	sp,sp,-16
    80000c42:	e422                	sd	s0,8(sp)
    80000c44:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000c46:	ca19                	beqz	a2,80000c5c <memset+0x1c>
    80000c48:	87aa                	mv	a5,a0
    80000c4a:	1602                	slli	a2,a2,0x20
    80000c4c:	9201                	srli	a2,a2,0x20
    80000c4e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000c52:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000c56:	0785                	addi	a5,a5,1
    80000c58:	fee79de3          	bne	a5,a4,80000c52 <memset+0x12>
  }
  return dst;
}
    80000c5c:	6422                	ld	s0,8(sp)
    80000c5e:	0141                	addi	sp,sp,16
    80000c60:	8082                	ret

0000000080000c62 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000c62:	1141                	addi	sp,sp,-16
    80000c64:	e422                	sd	s0,8(sp)
    80000c66:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000c68:	ca05                	beqz	a2,80000c98 <memcmp+0x36>
    80000c6a:	fff6069b          	addiw	a3,a2,-1
    80000c6e:	1682                	slli	a3,a3,0x20
    80000c70:	9281                	srli	a3,a3,0x20
    80000c72:	0685                	addi	a3,a3,1
    80000c74:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000c76:	00054783          	lbu	a5,0(a0)
    80000c7a:	0005c703          	lbu	a4,0(a1)
    80000c7e:	00e79863          	bne	a5,a4,80000c8e <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000c82:	0505                	addi	a0,a0,1
    80000c84:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000c86:	fed518e3          	bne	a0,a3,80000c76 <memcmp+0x14>
  }

  return 0;
    80000c8a:	4501                	li	a0,0
    80000c8c:	a019                	j	80000c92 <memcmp+0x30>
      return *s1 - *s2;
    80000c8e:	40e7853b          	subw	a0,a5,a4
}
    80000c92:	6422                	ld	s0,8(sp)
    80000c94:	0141                	addi	sp,sp,16
    80000c96:	8082                	ret
  return 0;
    80000c98:	4501                	li	a0,0
    80000c9a:	bfe5                	j	80000c92 <memcmp+0x30>

0000000080000c9c <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000c9c:	1141                	addi	sp,sp,-16
    80000c9e:	e422                	sd	s0,8(sp)
    80000ca0:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000ca2:	c205                	beqz	a2,80000cc2 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000ca4:	02a5e263          	bltu	a1,a0,80000cc8 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000ca8:	1602                	slli	a2,a2,0x20
    80000caa:	9201                	srli	a2,a2,0x20
    80000cac:	00c587b3          	add	a5,a1,a2
{
    80000cb0:	872a                	mv	a4,a0
      *d++ = *s++;
    80000cb2:	0585                	addi	a1,a1,1
    80000cb4:	0705                	addi	a4,a4,1
    80000cb6:	fff5c683          	lbu	a3,-1(a1)
    80000cba:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000cbe:	fef59ae3          	bne	a1,a5,80000cb2 <memmove+0x16>

  return dst;
}
    80000cc2:	6422                	ld	s0,8(sp)
    80000cc4:	0141                	addi	sp,sp,16
    80000cc6:	8082                	ret
  if(s < d && s + n > d){
    80000cc8:	02061693          	slli	a3,a2,0x20
    80000ccc:	9281                	srli	a3,a3,0x20
    80000cce:	00d58733          	add	a4,a1,a3
    80000cd2:	fce57be3          	bgeu	a0,a4,80000ca8 <memmove+0xc>
    d += n;
    80000cd6:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000cd8:	fff6079b          	addiw	a5,a2,-1
    80000cdc:	1782                	slli	a5,a5,0x20
    80000cde:	9381                	srli	a5,a5,0x20
    80000ce0:	fff7c793          	not	a5,a5
    80000ce4:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000ce6:	177d                	addi	a4,a4,-1
    80000ce8:	16fd                	addi	a3,a3,-1
    80000cea:	00074603          	lbu	a2,0(a4)
    80000cee:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000cf2:	fee79ae3          	bne	a5,a4,80000ce6 <memmove+0x4a>
    80000cf6:	b7f1                	j	80000cc2 <memmove+0x26>

0000000080000cf8 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000cf8:	1141                	addi	sp,sp,-16
    80000cfa:	e406                	sd	ra,8(sp)
    80000cfc:	e022                	sd	s0,0(sp)
    80000cfe:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d00:	f9dff0ef          	jal	ra,80000c9c <memmove>
}
    80000d04:	60a2                	ld	ra,8(sp)
    80000d06:	6402                	ld	s0,0(sp)
    80000d08:	0141                	addi	sp,sp,16
    80000d0a:	8082                	ret

0000000080000d0c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d0c:	1141                	addi	sp,sp,-16
    80000d0e:	e422                	sd	s0,8(sp)
    80000d10:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d12:	ce11                	beqz	a2,80000d2e <strncmp+0x22>
    80000d14:	00054783          	lbu	a5,0(a0)
    80000d18:	cf89                	beqz	a5,80000d32 <strncmp+0x26>
    80000d1a:	0005c703          	lbu	a4,0(a1)
    80000d1e:	00f71a63          	bne	a4,a5,80000d32 <strncmp+0x26>
    n--, p++, q++;
    80000d22:	367d                	addiw	a2,a2,-1
    80000d24:	0505                	addi	a0,a0,1
    80000d26:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000d28:	f675                	bnez	a2,80000d14 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	a809                	j	80000d3e <strncmp+0x32>
    80000d2e:	4501                	li	a0,0
    80000d30:	a039                	j	80000d3e <strncmp+0x32>
  if(n == 0)
    80000d32:	ca09                	beqz	a2,80000d44 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000d34:	00054503          	lbu	a0,0(a0)
    80000d38:	0005c783          	lbu	a5,0(a1)
    80000d3c:	9d1d                	subw	a0,a0,a5
}
    80000d3e:	6422                	ld	s0,8(sp)
    80000d40:	0141                	addi	sp,sp,16
    80000d42:	8082                	ret
    return 0;
    80000d44:	4501                	li	a0,0
    80000d46:	bfe5                	j	80000d3e <strncmp+0x32>

0000000080000d48 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000d48:	1141                	addi	sp,sp,-16
    80000d4a:	e422                	sd	s0,8(sp)
    80000d4c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000d4e:	872a                	mv	a4,a0
    80000d50:	8832                	mv	a6,a2
    80000d52:	367d                	addiw	a2,a2,-1
    80000d54:	01005963          	blez	a6,80000d66 <strncpy+0x1e>
    80000d58:	0705                	addi	a4,a4,1
    80000d5a:	0005c783          	lbu	a5,0(a1)
    80000d5e:	fef70fa3          	sb	a5,-1(a4)
    80000d62:	0585                	addi	a1,a1,1
    80000d64:	f7f5                	bnez	a5,80000d50 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000d66:	86ba                	mv	a3,a4
    80000d68:	00c05c63          	blez	a2,80000d80 <strncpy+0x38>
    *s++ = 0;
    80000d6c:	0685                	addi	a3,a3,1
    80000d6e:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000d72:	fff6c793          	not	a5,a3
    80000d76:	9fb9                	addw	a5,a5,a4
    80000d78:	010787bb          	addw	a5,a5,a6
    80000d7c:	fef048e3          	bgtz	a5,80000d6c <strncpy+0x24>
  return os;
}
    80000d80:	6422                	ld	s0,8(sp)
    80000d82:	0141                	addi	sp,sp,16
    80000d84:	8082                	ret

0000000080000d86 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000d86:	1141                	addi	sp,sp,-16
    80000d88:	e422                	sd	s0,8(sp)
    80000d8a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000d8c:	02c05363          	blez	a2,80000db2 <safestrcpy+0x2c>
    80000d90:	fff6069b          	addiw	a3,a2,-1
    80000d94:	1682                	slli	a3,a3,0x20
    80000d96:	9281                	srli	a3,a3,0x20
    80000d98:	96ae                	add	a3,a3,a1
    80000d9a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000d9c:	00d58963          	beq	a1,a3,80000dae <safestrcpy+0x28>
    80000da0:	0585                	addi	a1,a1,1
    80000da2:	0785                	addi	a5,a5,1
    80000da4:	fff5c703          	lbu	a4,-1(a1)
    80000da8:	fee78fa3          	sb	a4,-1(a5)
    80000dac:	fb65                	bnez	a4,80000d9c <safestrcpy+0x16>
    ;
  *s = 0;
    80000dae:	00078023          	sb	zero,0(a5)
  return os;
}
    80000db2:	6422                	ld	s0,8(sp)
    80000db4:	0141                	addi	sp,sp,16
    80000db6:	8082                	ret

0000000080000db8 <strlen>:

int
strlen(const char *s)
{
    80000db8:	1141                	addi	sp,sp,-16
    80000dba:	e422                	sd	s0,8(sp)
    80000dbc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000dbe:	00054783          	lbu	a5,0(a0)
    80000dc2:	cf91                	beqz	a5,80000dde <strlen+0x26>
    80000dc4:	0505                	addi	a0,a0,1
    80000dc6:	87aa                	mv	a5,a0
    80000dc8:	4685                	li	a3,1
    80000dca:	9e89                	subw	a3,a3,a0
    80000dcc:	00f6853b          	addw	a0,a3,a5
    80000dd0:	0785                	addi	a5,a5,1
    80000dd2:	fff7c703          	lbu	a4,-1(a5)
    80000dd6:	fb7d                	bnez	a4,80000dcc <strlen+0x14>
    ;
  return n;
}
    80000dd8:	6422                	ld	s0,8(sp)
    80000dda:	0141                	addi	sp,sp,16
    80000ddc:	8082                	ret
  for(n = 0; s[n]; n++)
    80000dde:	4501                	li	a0,0
    80000de0:	bfe5                	j	80000dd8 <strlen+0x20>

0000000080000de2 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000de2:	1141                	addi	sp,sp,-16
    80000de4:	e406                	sd	ra,8(sp)
    80000de6:	e022                	sd	s0,0(sp)
    80000de8:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000dea:	51d000ef          	jal	ra,80001b06 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000dee:	00007717          	auipc	a4,0x7
    80000df2:	d1270713          	addi	a4,a4,-750 # 80007b00 <started>
  if(cpuid() == 0){
    80000df6:	c51d                	beqz	a0,80000e24 <main+0x42>
    while(started == 0)
    80000df8:	431c                	lw	a5,0(a4)
    80000dfa:	2781                	sext.w	a5,a5
    80000dfc:	dff5                	beqz	a5,80000df8 <main+0x16>
      ;
    __sync_synchronize();
    80000dfe:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e02:	505000ef          	jal	ra,80001b06 <cpuid>
    80000e06:	85aa                	mv	a1,a0
    80000e08:	00006517          	auipc	a0,0x6
    80000e0c:	2a850513          	addi	a0,a0,680 # 800070b0 <digits+0x78>
    80000e10:	eb4ff0ef          	jal	ra,800004c4 <printf>
    kvminithart();    // turn on paging
    80000e14:	080000ef          	jal	ra,80000e94 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e18:	05d010ef          	jal	ra,80002674 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e1c:	6c8040ef          	jal	ra,800054e4 <plicinithart>
  }

  scheduler();        
    80000e20:	19c010ef          	jal	ra,80001fbc <scheduler>
    consoleinit();
    80000e24:	dc8ff0ef          	jal	ra,800003ec <consoleinit>
    printfinit();
    80000e28:	99fff0ef          	jal	ra,800007c6 <printfinit>
    printf("\n");
    80000e2c:	00006517          	auipc	a0,0x6
    80000e30:	3dc50513          	addi	a0,a0,988 # 80007208 <digits+0x1d0>
    80000e34:	e90ff0ef          	jal	ra,800004c4 <printf>
    printf("xv6 kernel is booting\n");
    80000e38:	00006517          	auipc	a0,0x6
    80000e3c:	26050513          	addi	a0,a0,608 # 80007098 <digits+0x60>
    80000e40:	e84ff0ef          	jal	ra,800004c4 <printf>
    printf("\n");
    80000e44:	00006517          	auipc	a0,0x6
    80000e48:	3c450513          	addi	a0,a0,964 # 80007208 <digits+0x1d0>
    80000e4c:	e78ff0ef          	jal	ra,800004c4 <printf>
    kinit();         // physical page allocator
    80000e50:	c19ff0ef          	jal	ra,80000a68 <kinit>
    kvminit();       // create kernel page table
    80000e54:	2ca000ef          	jal	ra,8000111e <kvminit>
    kvminithart();   // turn on paging
    80000e58:	03c000ef          	jal	ra,80000e94 <kvminithart>
    procinit();      // process table
    80000e5c:	403000ef          	jal	ra,80001a5e <procinit>
    trapinit();      // trap vectors
    80000e60:	7f0010ef          	jal	ra,80002650 <trapinit>
    trapinithart();  // install kernel trap vector
    80000e64:	011010ef          	jal	ra,80002674 <trapinithart>
    plicinit();      // set up interrupt controller
    80000e68:	666040ef          	jal	ra,800054ce <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000e6c:	678040ef          	jal	ra,800054e4 <plicinithart>
    binit();         // buffer cache
    80000e70:	68d010ef          	jal	ra,80002cfc <binit>
    iinit();         // inode table
    80000e74:	400020ef          	jal	ra,80003274 <iinit>
    fileinit();      // file table
    80000e78:	2e0030ef          	jal	ra,80004158 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000e7c:	758040ef          	jal	ra,800055d4 <virtio_disk_init>
    userinit();      // first user process
    80000e80:	7a5000ef          	jal	ra,80001e24 <userinit>
    __sync_synchronize();
    80000e84:	0ff0000f          	fence
    started = 1;
    80000e88:	4785                	li	a5,1
    80000e8a:	00007717          	auipc	a4,0x7
    80000e8e:	c6f72b23          	sw	a5,-906(a4) # 80007b00 <started>
    80000e92:	b779                	j	80000e20 <main+0x3e>

0000000080000e94 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000e94:	1141                	addi	sp,sp,-16
    80000e96:	e422                	sd	s0,8(sp)
    80000e98:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000e9a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000e9e:	00007797          	auipc	a5,0x7
    80000ea2:	c6a7b783          	ld	a5,-918(a5) # 80007b08 <kernel_pagetable>
    80000ea6:	83b1                	srli	a5,a5,0xc
    80000ea8:	577d                	li	a4,-1
    80000eaa:	177e                	slli	a4,a4,0x3f
    80000eac:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000eae:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000eb2:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000eb6:	6422                	ld	s0,8(sp)
    80000eb8:	0141                	addi	sp,sp,16
    80000eba:	8082                	ret

0000000080000ebc <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000ebc:	7139                	addi	sp,sp,-64
    80000ebe:	fc06                	sd	ra,56(sp)
    80000ec0:	f822                	sd	s0,48(sp)
    80000ec2:	f426                	sd	s1,40(sp)
    80000ec4:	f04a                	sd	s2,32(sp)
    80000ec6:	ec4e                	sd	s3,24(sp)
    80000ec8:	e852                	sd	s4,16(sp)
    80000eca:	e456                	sd	s5,8(sp)
    80000ecc:	e05a                	sd	s6,0(sp)
    80000ece:	0080                	addi	s0,sp,64
    80000ed0:	84aa                	mv	s1,a0
    80000ed2:	89ae                	mv	s3,a1
    80000ed4:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000ed6:	57fd                	li	a5,-1
    80000ed8:	83e9                	srli	a5,a5,0x1a
    80000eda:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000edc:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000ede:	02b7fc63          	bgeu	a5,a1,80000f16 <walk+0x5a>
    panic("walk");
    80000ee2:	00006517          	auipc	a0,0x6
    80000ee6:	1e650513          	addi	a0,a0,486 # 800070c8 <digits+0x90>
    80000eea:	8a1ff0ef          	jal	ra,8000078a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000eee:	060a8263          	beqz	s5,80000f52 <walk+0x96>
    80000ef2:	babff0ef          	jal	ra,80000a9c <kalloc>
    80000ef6:	84aa                	mv	s1,a0
    80000ef8:	c139                	beqz	a0,80000f3e <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000efa:	6605                	lui	a2,0x1
    80000efc:	4581                	li	a1,0
    80000efe:	d43ff0ef          	jal	ra,80000c40 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f02:	00c4d793          	srli	a5,s1,0xc
    80000f06:	07aa                	slli	a5,a5,0xa
    80000f08:	0017e793          	ori	a5,a5,1
    80000f0c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f10:	3a5d                	addiw	s4,s4,-9
    80000f12:	036a0063          	beq	s4,s6,80000f32 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f16:	0149d933          	srl	s2,s3,s4
    80000f1a:	1ff97913          	andi	s2,s2,511
    80000f1e:	090e                	slli	s2,s2,0x3
    80000f20:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000f22:	00093483          	ld	s1,0(s2)
    80000f26:	0014f793          	andi	a5,s1,1
    80000f2a:	d3f1                	beqz	a5,80000eee <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f2c:	80a9                	srli	s1,s1,0xa
    80000f2e:	04b2                	slli	s1,s1,0xc
    80000f30:	b7c5                	j	80000f10 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000f32:	00c9d513          	srli	a0,s3,0xc
    80000f36:	1ff57513          	andi	a0,a0,511
    80000f3a:	050e                	slli	a0,a0,0x3
    80000f3c:	9526                	add	a0,a0,s1
}
    80000f3e:	70e2                	ld	ra,56(sp)
    80000f40:	7442                	ld	s0,48(sp)
    80000f42:	74a2                	ld	s1,40(sp)
    80000f44:	7902                	ld	s2,32(sp)
    80000f46:	69e2                	ld	s3,24(sp)
    80000f48:	6a42                	ld	s4,16(sp)
    80000f4a:	6aa2                	ld	s5,8(sp)
    80000f4c:	6b02                	ld	s6,0(sp)
    80000f4e:	6121                	addi	sp,sp,64
    80000f50:	8082                	ret
        return 0;
    80000f52:	4501                	li	a0,0
    80000f54:	b7ed                	j	80000f3e <walk+0x82>

0000000080000f56 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000f56:	57fd                	li	a5,-1
    80000f58:	83e9                	srli	a5,a5,0x1a
    80000f5a:	00b7f463          	bgeu	a5,a1,80000f62 <walkaddr+0xc>
    return 0;
    80000f5e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000f60:	8082                	ret
{
    80000f62:	1141                	addi	sp,sp,-16
    80000f64:	e406                	sd	ra,8(sp)
    80000f66:	e022                	sd	s0,0(sp)
    80000f68:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000f6a:	4601                	li	a2,0
    80000f6c:	f51ff0ef          	jal	ra,80000ebc <walk>
  if(pte == 0)
    80000f70:	c105                	beqz	a0,80000f90 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000f72:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000f74:	0117f693          	andi	a3,a5,17
    80000f78:	4745                	li	a4,17
    return 0;
    80000f7a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000f7c:	00e68663          	beq	a3,a4,80000f88 <walkaddr+0x32>
}
    80000f80:	60a2                	ld	ra,8(sp)
    80000f82:	6402                	ld	s0,0(sp)
    80000f84:	0141                	addi	sp,sp,16
    80000f86:	8082                	ret
  pa = PTE2PA(*pte);
    80000f88:	00a7d513          	srli	a0,a5,0xa
    80000f8c:	0532                	slli	a0,a0,0xc
  return pa;
    80000f8e:	bfcd                	j	80000f80 <walkaddr+0x2a>
    return 0;
    80000f90:	4501                	li	a0,0
    80000f92:	b7fd                	j	80000f80 <walkaddr+0x2a>

0000000080000f94 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000f94:	715d                	addi	sp,sp,-80
    80000f96:	e486                	sd	ra,72(sp)
    80000f98:	e0a2                	sd	s0,64(sp)
    80000f9a:	fc26                	sd	s1,56(sp)
    80000f9c:	f84a                	sd	s2,48(sp)
    80000f9e:	f44e                	sd	s3,40(sp)
    80000fa0:	f052                	sd	s4,32(sp)
    80000fa2:	ec56                	sd	s5,24(sp)
    80000fa4:	e85a                	sd	s6,16(sp)
    80000fa6:	e45e                	sd	s7,8(sp)
    80000fa8:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80000faa:	03459793          	slli	a5,a1,0x34
    80000fae:	e7a9                	bnez	a5,80000ff8 <mappages+0x64>
    80000fb0:	8aaa                	mv	s5,a0
    80000fb2:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80000fb4:	03461793          	slli	a5,a2,0x34
    80000fb8:	e7b1                	bnez	a5,80001004 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    80000fba:	ca39                	beqz	a2,80001010 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80000fbc:	79fd                	lui	s3,0xfffff
    80000fbe:	964e                	add	a2,a2,s3
    80000fc0:	00b609b3          	add	s3,a2,a1
  a = va;
    80000fc4:	892e                	mv	s2,a1
    80000fc6:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80000fca:	6b85                	lui	s7,0x1
    80000fcc:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80000fd0:	4605                	li	a2,1
    80000fd2:	85ca                	mv	a1,s2
    80000fd4:	8556                	mv	a0,s5
    80000fd6:	ee7ff0ef          	jal	ra,80000ebc <walk>
    80000fda:	c539                	beqz	a0,80001028 <mappages+0x94>
    if(*pte & PTE_V)
    80000fdc:	611c                	ld	a5,0(a0)
    80000fde:	8b85                	andi	a5,a5,1
    80000fe0:	ef95                	bnez	a5,8000101c <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80000fe2:	80b1                	srli	s1,s1,0xc
    80000fe4:	04aa                	slli	s1,s1,0xa
    80000fe6:	0164e4b3          	or	s1,s1,s6
    80000fea:	0014e493          	ori	s1,s1,1
    80000fee:	e104                	sd	s1,0(a0)
    if(a == last)
    80000ff0:	05390863          	beq	s2,s3,80001040 <mappages+0xac>
    a += PGSIZE;
    80000ff4:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80000ff6:	bfd9                	j	80000fcc <mappages+0x38>
    panic("mappages: va not aligned");
    80000ff8:	00006517          	auipc	a0,0x6
    80000ffc:	0d850513          	addi	a0,a0,216 # 800070d0 <digits+0x98>
    80001000:	f8aff0ef          	jal	ra,8000078a <panic>
    panic("mappages: size not aligned");
    80001004:	00006517          	auipc	a0,0x6
    80001008:	0ec50513          	addi	a0,a0,236 # 800070f0 <digits+0xb8>
    8000100c:	f7eff0ef          	jal	ra,8000078a <panic>
    panic("mappages: size");
    80001010:	00006517          	auipc	a0,0x6
    80001014:	10050513          	addi	a0,a0,256 # 80007110 <digits+0xd8>
    80001018:	f72ff0ef          	jal	ra,8000078a <panic>
      panic("mappages: remap");
    8000101c:	00006517          	auipc	a0,0x6
    80001020:	10450513          	addi	a0,a0,260 # 80007120 <digits+0xe8>
    80001024:	f66ff0ef          	jal	ra,8000078a <panic>
      return -1;
    80001028:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000102a:	60a6                	ld	ra,72(sp)
    8000102c:	6406                	ld	s0,64(sp)
    8000102e:	74e2                	ld	s1,56(sp)
    80001030:	7942                	ld	s2,48(sp)
    80001032:	79a2                	ld	s3,40(sp)
    80001034:	7a02                	ld	s4,32(sp)
    80001036:	6ae2                	ld	s5,24(sp)
    80001038:	6b42                	ld	s6,16(sp)
    8000103a:	6ba2                	ld	s7,8(sp)
    8000103c:	6161                	addi	sp,sp,80
    8000103e:	8082                	ret
  return 0;
    80001040:	4501                	li	a0,0
    80001042:	b7e5                	j	8000102a <mappages+0x96>

0000000080001044 <kvmmap>:
{
    80001044:	1141                	addi	sp,sp,-16
    80001046:	e406                	sd	ra,8(sp)
    80001048:	e022                	sd	s0,0(sp)
    8000104a:	0800                	addi	s0,sp,16
    8000104c:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000104e:	86b2                	mv	a3,a2
    80001050:	863e                	mv	a2,a5
    80001052:	f43ff0ef          	jal	ra,80000f94 <mappages>
    80001056:	e509                	bnez	a0,80001060 <kvmmap+0x1c>
}
    80001058:	60a2                	ld	ra,8(sp)
    8000105a:	6402                	ld	s0,0(sp)
    8000105c:	0141                	addi	sp,sp,16
    8000105e:	8082                	ret
    panic("kvmmap");
    80001060:	00006517          	auipc	a0,0x6
    80001064:	0d050513          	addi	a0,a0,208 # 80007130 <digits+0xf8>
    80001068:	f22ff0ef          	jal	ra,8000078a <panic>

000000008000106c <kvmmake>:
{
    8000106c:	1101                	addi	sp,sp,-32
    8000106e:	ec06                	sd	ra,24(sp)
    80001070:	e822                	sd	s0,16(sp)
    80001072:	e426                	sd	s1,8(sp)
    80001074:	e04a                	sd	s2,0(sp)
    80001076:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001078:	a25ff0ef          	jal	ra,80000a9c <kalloc>
    8000107c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000107e:	6605                	lui	a2,0x1
    80001080:	4581                	li	a1,0
    80001082:	bbfff0ef          	jal	ra,80000c40 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001086:	4719                	li	a4,6
    80001088:	6685                	lui	a3,0x1
    8000108a:	10000637          	lui	a2,0x10000
    8000108e:	100005b7          	lui	a1,0x10000
    80001092:	8526                	mv	a0,s1
    80001094:	fb1ff0ef          	jal	ra,80001044 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001098:	4719                	li	a4,6
    8000109a:	6685                	lui	a3,0x1
    8000109c:	10001637          	lui	a2,0x10001
    800010a0:	100015b7          	lui	a1,0x10001
    800010a4:	8526                	mv	a0,s1
    800010a6:	f9fff0ef          	jal	ra,80001044 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800010aa:	4719                	li	a4,6
    800010ac:	040006b7          	lui	a3,0x4000
    800010b0:	0c000637          	lui	a2,0xc000
    800010b4:	0c0005b7          	lui	a1,0xc000
    800010b8:	8526                	mv	a0,s1
    800010ba:	f8bff0ef          	jal	ra,80001044 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800010be:	00006917          	auipc	s2,0x6
    800010c2:	f4290913          	addi	s2,s2,-190 # 80007000 <etext>
    800010c6:	4729                	li	a4,10
    800010c8:	80006697          	auipc	a3,0x80006
    800010cc:	f3868693          	addi	a3,a3,-200 # 7000 <_entry-0x7fff9000>
    800010d0:	4605                	li	a2,1
    800010d2:	067e                	slli	a2,a2,0x1f
    800010d4:	85b2                	mv	a1,a2
    800010d6:	8526                	mv	a0,s1
    800010d8:	f6dff0ef          	jal	ra,80001044 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800010dc:	4719                	li	a4,6
    800010de:	46c5                	li	a3,17
    800010e0:	06ee                	slli	a3,a3,0x1b
    800010e2:	412686b3          	sub	a3,a3,s2
    800010e6:	864a                	mv	a2,s2
    800010e8:	85ca                	mv	a1,s2
    800010ea:	8526                	mv	a0,s1
    800010ec:	f59ff0ef          	jal	ra,80001044 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800010f0:	4729                	li	a4,10
    800010f2:	6685                	lui	a3,0x1
    800010f4:	00005617          	auipc	a2,0x5
    800010f8:	f0c60613          	addi	a2,a2,-244 # 80006000 <_trampoline>
    800010fc:	040005b7          	lui	a1,0x4000
    80001100:	15fd                	addi	a1,a1,-1
    80001102:	05b2                	slli	a1,a1,0xc
    80001104:	8526                	mv	a0,s1
    80001106:	f3fff0ef          	jal	ra,80001044 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000110a:	8526                	mv	a0,s1
    8000110c:	0c9000ef          	jal	ra,800019d4 <proc_mapstacks>
}
    80001110:	8526                	mv	a0,s1
    80001112:	60e2                	ld	ra,24(sp)
    80001114:	6442                	ld	s0,16(sp)
    80001116:	64a2                	ld	s1,8(sp)
    80001118:	6902                	ld	s2,0(sp)
    8000111a:	6105                	addi	sp,sp,32
    8000111c:	8082                	ret

000000008000111e <kvminit>:
{
    8000111e:	1141                	addi	sp,sp,-16
    80001120:	e406                	sd	ra,8(sp)
    80001122:	e022                	sd	s0,0(sp)
    80001124:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001126:	f47ff0ef          	jal	ra,8000106c <kvmmake>
    8000112a:	00007797          	auipc	a5,0x7
    8000112e:	9ca7bf23          	sd	a0,-1570(a5) # 80007b08 <kernel_pagetable>
}
    80001132:	60a2                	ld	ra,8(sp)
    80001134:	6402                	ld	s0,0(sp)
    80001136:	0141                	addi	sp,sp,16
    80001138:	8082                	ret

000000008000113a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000113a:	1101                	addi	sp,sp,-32
    8000113c:	ec06                	sd	ra,24(sp)
    8000113e:	e822                	sd	s0,16(sp)
    80001140:	e426                	sd	s1,8(sp)
    80001142:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001144:	959ff0ef          	jal	ra,80000a9c <kalloc>
    80001148:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000114a:	c509                	beqz	a0,80001154 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000114c:	6605                	lui	a2,0x1
    8000114e:	4581                	li	a1,0
    80001150:	af1ff0ef          	jal	ra,80000c40 <memset>
  return pagetable;
}
    80001154:	8526                	mv	a0,s1
    80001156:	60e2                	ld	ra,24(sp)
    80001158:	6442                	ld	s0,16(sp)
    8000115a:	64a2                	ld	s1,8(sp)
    8000115c:	6105                	addi	sp,sp,32
    8000115e:	8082                	ret

0000000080001160 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001160:	7139                	addi	sp,sp,-64
    80001162:	fc06                	sd	ra,56(sp)
    80001164:	f822                	sd	s0,48(sp)
    80001166:	f426                	sd	s1,40(sp)
    80001168:	f04a                	sd	s2,32(sp)
    8000116a:	ec4e                	sd	s3,24(sp)
    8000116c:	e852                	sd	s4,16(sp)
    8000116e:	e456                	sd	s5,8(sp)
    80001170:	e05a                	sd	s6,0(sp)
    80001172:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001174:	03459793          	slli	a5,a1,0x34
    80001178:	e785                	bnez	a5,800011a0 <uvmunmap+0x40>
    8000117a:	8a2a                	mv	s4,a0
    8000117c:	892e                	mv	s2,a1
    8000117e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001180:	0632                	slli	a2,a2,0xc
    80001182:	00b609b3          	add	s3,a2,a1
    80001186:	6b05                	lui	s6,0x1
    80001188:	0335e763          	bltu	a1,s3,800011b6 <uvmunmap+0x56>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000118c:	70e2                	ld	ra,56(sp)
    8000118e:	7442                	ld	s0,48(sp)
    80001190:	74a2                	ld	s1,40(sp)
    80001192:	7902                	ld	s2,32(sp)
    80001194:	69e2                	ld	s3,24(sp)
    80001196:	6a42                	ld	s4,16(sp)
    80001198:	6aa2                	ld	s5,8(sp)
    8000119a:	6b02                	ld	s6,0(sp)
    8000119c:	6121                	addi	sp,sp,64
    8000119e:	8082                	ret
    panic("uvmunmap: not aligned");
    800011a0:	00006517          	auipc	a0,0x6
    800011a4:	f9850513          	addi	a0,a0,-104 # 80007138 <digits+0x100>
    800011a8:	de2ff0ef          	jal	ra,8000078a <panic>
    *pte = 0;
    800011ac:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011b0:	995a                	add	s2,s2,s6
    800011b2:	fd397de3          	bgeu	s2,s3,8000118c <uvmunmap+0x2c>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    800011b6:	4601                	li	a2,0
    800011b8:	85ca                	mv	a1,s2
    800011ba:	8552                	mv	a0,s4
    800011bc:	d01ff0ef          	jal	ra,80000ebc <walk>
    800011c0:	84aa                	mv	s1,a0
    800011c2:	d57d                	beqz	a0,800011b0 <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    800011c4:	611c                	ld	a5,0(a0)
    800011c6:	0017f713          	andi	a4,a5,1
    800011ca:	d37d                	beqz	a4,800011b0 <uvmunmap+0x50>
    if(do_free){
    800011cc:	fe0a80e3          	beqz	s5,800011ac <uvmunmap+0x4c>
      uint64 pa = PTE2PA(*pte);
    800011d0:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    800011d2:	00c79513          	slli	a0,a5,0xc
    800011d6:	fe6ff0ef          	jal	ra,800009bc <kfree>
    800011da:	bfc9                	j	800011ac <uvmunmap+0x4c>

00000000800011dc <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800011dc:	1101                	addi	sp,sp,-32
    800011de:	ec06                	sd	ra,24(sp)
    800011e0:	e822                	sd	s0,16(sp)
    800011e2:	e426                	sd	s1,8(sp)
    800011e4:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800011e6:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800011e8:	00b67d63          	bgeu	a2,a1,80001202 <uvmdealloc+0x26>
    800011ec:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800011ee:	6785                	lui	a5,0x1
    800011f0:	17fd                	addi	a5,a5,-1
    800011f2:	00f60733          	add	a4,a2,a5
    800011f6:	767d                	lui	a2,0xfffff
    800011f8:	8f71                	and	a4,a4,a2
    800011fa:	97ae                	add	a5,a5,a1
    800011fc:	8ff1                	and	a5,a5,a2
    800011fe:	00f76863          	bltu	a4,a5,8000120e <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001202:	8526                	mv	a0,s1
    80001204:	60e2                	ld	ra,24(sp)
    80001206:	6442                	ld	s0,16(sp)
    80001208:	64a2                	ld	s1,8(sp)
    8000120a:	6105                	addi	sp,sp,32
    8000120c:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000120e:	8f99                	sub	a5,a5,a4
    80001210:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001212:	4685                	li	a3,1
    80001214:	0007861b          	sext.w	a2,a5
    80001218:	85ba                	mv	a1,a4
    8000121a:	f47ff0ef          	jal	ra,80001160 <uvmunmap>
    8000121e:	b7d5                	j	80001202 <uvmdealloc+0x26>

0000000080001220 <uvmalloc>:
  if(newsz < oldsz)
    80001220:	08b66963          	bltu	a2,a1,800012b2 <uvmalloc+0x92>
{
    80001224:	7139                	addi	sp,sp,-64
    80001226:	fc06                	sd	ra,56(sp)
    80001228:	f822                	sd	s0,48(sp)
    8000122a:	f426                	sd	s1,40(sp)
    8000122c:	f04a                	sd	s2,32(sp)
    8000122e:	ec4e                	sd	s3,24(sp)
    80001230:	e852                	sd	s4,16(sp)
    80001232:	e456                	sd	s5,8(sp)
    80001234:	e05a                	sd	s6,0(sp)
    80001236:	0080                	addi	s0,sp,64
    80001238:	8aaa                	mv	s5,a0
    8000123a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000123c:	6985                	lui	s3,0x1
    8000123e:	19fd                	addi	s3,s3,-1
    80001240:	95ce                	add	a1,a1,s3
    80001242:	79fd                	lui	s3,0xfffff
    80001244:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001248:	06c9f763          	bgeu	s3,a2,800012b6 <uvmalloc+0x96>
    8000124c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000124e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001252:	84bff0ef          	jal	ra,80000a9c <kalloc>
    80001256:	84aa                	mv	s1,a0
    if(mem == 0){
    80001258:	c11d                	beqz	a0,8000127e <uvmalloc+0x5e>
    memset(mem, 0, PGSIZE);
    8000125a:	6605                	lui	a2,0x1
    8000125c:	4581                	li	a1,0
    8000125e:	9e3ff0ef          	jal	ra,80000c40 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001262:	875a                	mv	a4,s6
    80001264:	86a6                	mv	a3,s1
    80001266:	6605                	lui	a2,0x1
    80001268:	85ca                	mv	a1,s2
    8000126a:	8556                	mv	a0,s5
    8000126c:	d29ff0ef          	jal	ra,80000f94 <mappages>
    80001270:	e51d                	bnez	a0,8000129e <uvmalloc+0x7e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001272:	6785                	lui	a5,0x1
    80001274:	993e                	add	s2,s2,a5
    80001276:	fd496ee3          	bltu	s2,s4,80001252 <uvmalloc+0x32>
  return newsz;
    8000127a:	8552                	mv	a0,s4
    8000127c:	a039                	j	8000128a <uvmalloc+0x6a>
      uvmdealloc(pagetable, a, oldsz);
    8000127e:	864e                	mv	a2,s3
    80001280:	85ca                	mv	a1,s2
    80001282:	8556                	mv	a0,s5
    80001284:	f59ff0ef          	jal	ra,800011dc <uvmdealloc>
      return 0;
    80001288:	4501                	li	a0,0
}
    8000128a:	70e2                	ld	ra,56(sp)
    8000128c:	7442                	ld	s0,48(sp)
    8000128e:	74a2                	ld	s1,40(sp)
    80001290:	7902                	ld	s2,32(sp)
    80001292:	69e2                	ld	s3,24(sp)
    80001294:	6a42                	ld	s4,16(sp)
    80001296:	6aa2                	ld	s5,8(sp)
    80001298:	6b02                	ld	s6,0(sp)
    8000129a:	6121                	addi	sp,sp,64
    8000129c:	8082                	ret
      kfree(mem);
    8000129e:	8526                	mv	a0,s1
    800012a0:	f1cff0ef          	jal	ra,800009bc <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800012a4:	864e                	mv	a2,s3
    800012a6:	85ca                	mv	a1,s2
    800012a8:	8556                	mv	a0,s5
    800012aa:	f33ff0ef          	jal	ra,800011dc <uvmdealloc>
      return 0;
    800012ae:	4501                	li	a0,0
    800012b0:	bfe9                	j	8000128a <uvmalloc+0x6a>
    return oldsz;
    800012b2:	852e                	mv	a0,a1
}
    800012b4:	8082                	ret
  return newsz;
    800012b6:	8532                	mv	a0,a2
    800012b8:	bfc9                	j	8000128a <uvmalloc+0x6a>

00000000800012ba <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800012ba:	7179                	addi	sp,sp,-48
    800012bc:	f406                	sd	ra,40(sp)
    800012be:	f022                	sd	s0,32(sp)
    800012c0:	ec26                	sd	s1,24(sp)
    800012c2:	e84a                	sd	s2,16(sp)
    800012c4:	e44e                	sd	s3,8(sp)
    800012c6:	e052                	sd	s4,0(sp)
    800012c8:	1800                	addi	s0,sp,48
    800012ca:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800012cc:	84aa                	mv	s1,a0
    800012ce:	6905                	lui	s2,0x1
    800012d0:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800012d2:	4985                	li	s3,1
    800012d4:	a811                	j	800012e8 <freewalk+0x2e>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800012d6:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800012d8:	0532                	slli	a0,a0,0xc
    800012da:	fe1ff0ef          	jal	ra,800012ba <freewalk>
      pagetable[i] = 0;
    800012de:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800012e2:	04a1                	addi	s1,s1,8
    800012e4:	01248f63          	beq	s1,s2,80001302 <freewalk+0x48>
    pte_t pte = pagetable[i];
    800012e8:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800012ea:	00f57793          	andi	a5,a0,15
    800012ee:	ff3784e3          	beq	a5,s3,800012d6 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800012f2:	8905                	andi	a0,a0,1
    800012f4:	d57d                	beqz	a0,800012e2 <freewalk+0x28>
      panic("freewalk: leaf");
    800012f6:	00006517          	auipc	a0,0x6
    800012fa:	e5a50513          	addi	a0,a0,-422 # 80007150 <digits+0x118>
    800012fe:	c8cff0ef          	jal	ra,8000078a <panic>
    }
  }
  kfree((void*)pagetable);
    80001302:	8552                	mv	a0,s4
    80001304:	eb8ff0ef          	jal	ra,800009bc <kfree>
}
    80001308:	70a2                	ld	ra,40(sp)
    8000130a:	7402                	ld	s0,32(sp)
    8000130c:	64e2                	ld	s1,24(sp)
    8000130e:	6942                	ld	s2,16(sp)
    80001310:	69a2                	ld	s3,8(sp)
    80001312:	6a02                	ld	s4,0(sp)
    80001314:	6145                	addi	sp,sp,48
    80001316:	8082                	ret

0000000080001318 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001318:	1101                	addi	sp,sp,-32
    8000131a:	ec06                	sd	ra,24(sp)
    8000131c:	e822                	sd	s0,16(sp)
    8000131e:	e426                	sd	s1,8(sp)
    80001320:	1000                	addi	s0,sp,32
    80001322:	84aa                	mv	s1,a0
  if(sz > 0)
    80001324:	e989                	bnez	a1,80001336 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001326:	8526                	mv	a0,s1
    80001328:	f93ff0ef          	jal	ra,800012ba <freewalk>
}
    8000132c:	60e2                	ld	ra,24(sp)
    8000132e:	6442                	ld	s0,16(sp)
    80001330:	64a2                	ld	s1,8(sp)
    80001332:	6105                	addi	sp,sp,32
    80001334:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001336:	6605                	lui	a2,0x1
    80001338:	167d                	addi	a2,a2,-1
    8000133a:	962e                	add	a2,a2,a1
    8000133c:	4685                	li	a3,1
    8000133e:	8231                	srli	a2,a2,0xc
    80001340:	4581                	li	a1,0
    80001342:	e1fff0ef          	jal	ra,80001160 <uvmunmap>
    80001346:	b7c5                	j	80001326 <uvmfree+0xe>

0000000080001348 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001348:	ce49                	beqz	a2,800013e2 <uvmcopy+0x9a>
{
    8000134a:	715d                	addi	sp,sp,-80
    8000134c:	e486                	sd	ra,72(sp)
    8000134e:	e0a2                	sd	s0,64(sp)
    80001350:	fc26                	sd	s1,56(sp)
    80001352:	f84a                	sd	s2,48(sp)
    80001354:	f44e                	sd	s3,40(sp)
    80001356:	f052                	sd	s4,32(sp)
    80001358:	ec56                	sd	s5,24(sp)
    8000135a:	e85a                	sd	s6,16(sp)
    8000135c:	e45e                	sd	s7,8(sp)
    8000135e:	0880                	addi	s0,sp,80
    80001360:	8aaa                	mv	s5,a0
    80001362:	8b2e                	mv	s6,a1
    80001364:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001366:	4481                	li	s1,0
    80001368:	a029                	j	80001372 <uvmcopy+0x2a>
    8000136a:	6785                	lui	a5,0x1
    8000136c:	94be                	add	s1,s1,a5
    8000136e:	0544fe63          	bgeu	s1,s4,800013ca <uvmcopy+0x82>
    if((pte = walk(old, i, 0)) == 0)
    80001372:	4601                	li	a2,0
    80001374:	85a6                	mv	a1,s1
    80001376:	8556                	mv	a0,s5
    80001378:	b45ff0ef          	jal	ra,80000ebc <walk>
    8000137c:	d57d                	beqz	a0,8000136a <uvmcopy+0x22>
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
    8000137e:	6118                	ld	a4,0(a0)
    80001380:	00177793          	andi	a5,a4,1
    80001384:	d3fd                	beqz	a5,8000136a <uvmcopy+0x22>
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    80001386:	00a75593          	srli	a1,a4,0xa
    8000138a:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000138e:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    80001392:	f0aff0ef          	jal	ra,80000a9c <kalloc>
    80001396:	89aa                	mv	s3,a0
    80001398:	c105                	beqz	a0,800013b8 <uvmcopy+0x70>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000139a:	6605                	lui	a2,0x1
    8000139c:	85de                	mv	a1,s7
    8000139e:	8ffff0ef          	jal	ra,80000c9c <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800013a2:	874a                	mv	a4,s2
    800013a4:	86ce                	mv	a3,s3
    800013a6:	6605                	lui	a2,0x1
    800013a8:	85a6                	mv	a1,s1
    800013aa:	855a                	mv	a0,s6
    800013ac:	be9ff0ef          	jal	ra,80000f94 <mappages>
    800013b0:	dd4d                	beqz	a0,8000136a <uvmcopy+0x22>
      kfree(mem);
    800013b2:	854e                	mv	a0,s3
    800013b4:	e08ff0ef          	jal	ra,800009bc <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800013b8:	4685                	li	a3,1
    800013ba:	00c4d613          	srli	a2,s1,0xc
    800013be:	4581                	li	a1,0
    800013c0:	855a                	mv	a0,s6
    800013c2:	d9fff0ef          	jal	ra,80001160 <uvmunmap>
  return -1;
    800013c6:	557d                	li	a0,-1
    800013c8:	a011                	j	800013cc <uvmcopy+0x84>
  return 0;
    800013ca:	4501                	li	a0,0
}
    800013cc:	60a6                	ld	ra,72(sp)
    800013ce:	6406                	ld	s0,64(sp)
    800013d0:	74e2                	ld	s1,56(sp)
    800013d2:	7942                	ld	s2,48(sp)
    800013d4:	79a2                	ld	s3,40(sp)
    800013d6:	7a02                	ld	s4,32(sp)
    800013d8:	6ae2                	ld	s5,24(sp)
    800013da:	6b42                	ld	s6,16(sp)
    800013dc:	6ba2                	ld	s7,8(sp)
    800013de:	6161                	addi	sp,sp,80
    800013e0:	8082                	ret
  return 0;
    800013e2:	4501                	li	a0,0
}
    800013e4:	8082                	ret

00000000800013e6 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800013e6:	1141                	addi	sp,sp,-16
    800013e8:	e406                	sd	ra,8(sp)
    800013ea:	e022                	sd	s0,0(sp)
    800013ec:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800013ee:	4601                	li	a2,0
    800013f0:	acdff0ef          	jal	ra,80000ebc <walk>
  if(pte == 0)
    800013f4:	c901                	beqz	a0,80001404 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800013f6:	611c                	ld	a5,0(a0)
    800013f8:	9bbd                	andi	a5,a5,-17
    800013fa:	e11c                	sd	a5,0(a0)
}
    800013fc:	60a2                	ld	ra,8(sp)
    800013fe:	6402                	ld	s0,0(sp)
    80001400:	0141                	addi	sp,sp,16
    80001402:	8082                	ret
    panic("uvmclear");
    80001404:	00006517          	auipc	a0,0x6
    80001408:	d5c50513          	addi	a0,a0,-676 # 80007160 <digits+0x128>
    8000140c:	b7eff0ef          	jal	ra,8000078a <panic>

0000000080001410 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001410:	c2d5                	beqz	a3,800014b4 <copyinstr+0xa4>
{
    80001412:	715d                	addi	sp,sp,-80
    80001414:	e486                	sd	ra,72(sp)
    80001416:	e0a2                	sd	s0,64(sp)
    80001418:	fc26                	sd	s1,56(sp)
    8000141a:	f84a                	sd	s2,48(sp)
    8000141c:	f44e                	sd	s3,40(sp)
    8000141e:	f052                	sd	s4,32(sp)
    80001420:	ec56                	sd	s5,24(sp)
    80001422:	e85a                	sd	s6,16(sp)
    80001424:	e45e                	sd	s7,8(sp)
    80001426:	0880                	addi	s0,sp,80
    80001428:	8a2a                	mv	s4,a0
    8000142a:	8b2e                	mv	s6,a1
    8000142c:	8bb2                	mv	s7,a2
    8000142e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001430:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001432:	6985                	lui	s3,0x1
    80001434:	a035                	j	80001460 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001436:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000143a:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000143c:	0017b793          	seqz	a5,a5
    80001440:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001444:	60a6                	ld	ra,72(sp)
    80001446:	6406                	ld	s0,64(sp)
    80001448:	74e2                	ld	s1,56(sp)
    8000144a:	7942                	ld	s2,48(sp)
    8000144c:	79a2                	ld	s3,40(sp)
    8000144e:	7a02                	ld	s4,32(sp)
    80001450:	6ae2                	ld	s5,24(sp)
    80001452:	6b42                	ld	s6,16(sp)
    80001454:	6ba2                	ld	s7,8(sp)
    80001456:	6161                	addi	sp,sp,80
    80001458:	8082                	ret
    srcva = va0 + PGSIZE;
    8000145a:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000145e:	c4b9                	beqz	s1,800014ac <copyinstr+0x9c>
    va0 = PGROUNDDOWN(srcva);
    80001460:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001464:	85ca                	mv	a1,s2
    80001466:	8552                	mv	a0,s4
    80001468:	aefff0ef          	jal	ra,80000f56 <walkaddr>
    if(pa0 == 0)
    8000146c:	c131                	beqz	a0,800014b0 <copyinstr+0xa0>
    n = PGSIZE - (srcva - va0);
    8000146e:	41790833          	sub	a6,s2,s7
    80001472:	984e                	add	a6,a6,s3
    if(n > max)
    80001474:	0104f363          	bgeu	s1,a6,8000147a <copyinstr+0x6a>
    80001478:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000147a:	955e                	add	a0,a0,s7
    8000147c:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001480:	fc080de3          	beqz	a6,8000145a <copyinstr+0x4a>
    80001484:	985a                	add	a6,a6,s6
    80001486:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001488:	41650633          	sub	a2,a0,s6
    8000148c:	14fd                	addi	s1,s1,-1
    8000148e:	9b26                	add	s6,s6,s1
    80001490:	00f60733          	add	a4,a2,a5
    80001494:	00074703          	lbu	a4,0(a4)
    80001498:	df59                	beqz	a4,80001436 <copyinstr+0x26>
        *dst = *p;
    8000149a:	00e78023          	sb	a4,0(a5)
      --max;
    8000149e:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800014a2:	0785                	addi	a5,a5,1
    while(n > 0){
    800014a4:	ff0796e3          	bne	a5,a6,80001490 <copyinstr+0x80>
      dst++;
    800014a8:	8b42                	mv	s6,a6
    800014aa:	bf45                	j	8000145a <copyinstr+0x4a>
    800014ac:	4781                	li	a5,0
    800014ae:	b779                	j	8000143c <copyinstr+0x2c>
      return -1;
    800014b0:	557d                	li	a0,-1
    800014b2:	bf49                	j	80001444 <copyinstr+0x34>
  int got_null = 0;
    800014b4:	4781                	li	a5,0
  if(got_null){
    800014b6:	0017b793          	seqz	a5,a5
    800014ba:	40f00533          	neg	a0,a5
}
    800014be:	8082                	ret

00000000800014c0 <ismapped>:
//   return mem;
// }

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800014c0:	1141                	addi	sp,sp,-16
    800014c2:	e406                	sd	ra,8(sp)
    800014c4:	e022                	sd	s0,0(sp)
    800014c6:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800014c8:	4601                	li	a2,0
    800014ca:	9f3ff0ef          	jal	ra,80000ebc <walk>
  if (pte == 0) {
    800014ce:	c519                	beqz	a0,800014dc <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    800014d0:	6108                	ld	a0,0(a0)
    return 0;
    800014d2:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800014d4:	60a2                	ld	ra,8(sp)
    800014d6:	6402                	ld	s0,0(sp)
    800014d8:	0141                	addi	sp,sp,16
    800014da:	8082                	ret
    return 0;
    800014dc:	4501                	li	a0,0
    800014de:	bfdd                	j	800014d4 <ismapped+0x14>

00000000800014e0 <vmfault>:

//changes 

uint64
vmfault(pagetable_t pagetable, uint64 va, int is_write)
{
    800014e0:	7139                	addi	sp,sp,-64
    800014e2:	fc06                	sd	ra,56(sp)
    800014e4:	f822                	sd	s0,48(sp)
    800014e6:	f426                	sd	s1,40(sp)
    800014e8:	f04a                	sd	s2,32(sp)
    800014ea:	ec4e                	sd	s3,24(sp)
    800014ec:	e852                	sd	s4,16(sp)
    800014ee:	e456                	sd	s5,8(sp)
    800014f0:	e05a                	sd	s6,0(sp)
    800014f2:	0080                	addi	s0,sp,64
    800014f4:	8aaa                	mv	s5,a0
    800014f6:	892e                	mv	s2,a1
    800014f8:	8a32                	mv	s4,a2
  struct proc *p = myproc();
    800014fa:	638000ef          	jal	ra,80001b32 <myproc>
    800014fe:	84aa                	mv	s1,a0
  char *mem;
  uint64 page_va = PGROUNDDOWN(va);
    80001500:	79fd                	lui	s3,0xfffff
    80001502:	01397b33          	and	s6,s2,s3
  
  printf("[DEBUG] vmfault: va=0x%lx, p->sz=0x%lx, stack_range=[0x%lx,0x%lx)\n", 
    80001506:	6530                	ld	a2,72(a0)
    80001508:	8732                	mv	a4,a2
    8000150a:	013606b3          	add	a3,a2,s3
    8000150e:	85ca                	mv	a1,s2
    80001510:	00006517          	auipc	a0,0x6
    80001514:	c6850513          	addi	a0,a0,-920 # 80007178 <digits+0x140>
    80001518:	fadfe0ef          	jal	ra,800004c4 <printf>
         va, p->sz, p->sz - USERSTACK*PGSIZE, p->sz);
  
  // Check if address is valid - CHECK STACK FIRST
  if(va >= p->sz - USERSTACK*PGSIZE && va < p->sz) {
    8000151c:	64bc                	ld	a5,72(s1)
    8000151e:	99be                	add	s3,s3,a5
    80001520:	09396d63          	bltu	s2,s3,800015ba <vmfault+0xda>
    80001524:	08f97b63          	bgeu	s2,a5,800015ba <vmfault+0xda>
    // Stack - allocate zero-filled page  
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=stack\n", 
    80001528:	588c                	lw	a1,48(s1)
    8000152a:	00006697          	auipc	a3,0x6
    8000152e:	c4668693          	addi	a3,a3,-954 # 80007170 <digits+0x138>
    80001532:	000a1663          	bnez	s4,8000153e <vmfault+0x5e>
    80001536:	00006697          	auipc	a3,0x6
    8000153a:	29268693          	addi	a3,a3,658 # 800077c8 <syscalls+0x1f0>
    8000153e:	865a                	mv	a2,s6
    80001540:	00006517          	auipc	a0,0x6
    80001544:	c8050513          	addi	a0,a0,-896 # 800071c0 <digits+0x188>
    80001548:	f7dfe0ef          	jal	ra,800004c4 <printf>
            p->pid, page_va, is_write ? "write" : "read");
    
    if((mem = kalloc()) == 0) {
    8000154c:	d50ff0ef          	jal	ra,80000a9c <kalloc>
    80001550:	89aa                	mv	s3,a0
    80001552:	c531                	beqz	a0,8000159e <vmfault+0xbe>
      printf("[pid %d] MEMFULL\n", p->pid);
      return -1;
    }
    memset(mem, 0, PGSIZE);
    80001554:	6605                	lui	a2,0x1
    80001556:	4581                	li	a1,0
    80001558:	ee8ff0ef          	jal	ra,80000c40 <memset>
    
    // Map the page
    if(mappages(pagetable, page_va, PGSIZE, (uint64)mem, PTE_R | PTE_W | PTE_U) < 0) {
    8000155c:	894e                	mv	s2,s3
    8000155e:	4759                	li	a4,22
    80001560:	86ce                	mv	a3,s3
    80001562:	6605                	lui	a2,0x1
    80001564:	85da                	mv	a1,s6
    80001566:	8556                	mv	a0,s5
    80001568:	a2dff0ef          	jal	ra,80000f94 <mappages>
    8000156c:	04054263          	bltz	a0,800015b0 <vmfault+0xd0>
      kfree(mem);
      return -1;
    }
    
    printf("[pid %d] ALLOC va=0x%lx\n", p->pid, page_va);
    80001570:	865a                	mv	a2,s6
    80001572:	588c                	lw	a1,48(s1)
    80001574:	00006517          	auipc	a0,0x6
    80001578:	c9c50513          	addi	a0,a0,-868 # 80007210 <digits+0x1d8>
    8000157c:	f49fe0ef          	jal	ra,800004c4 <printf>
    printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, page_va, p->next_fifo_seq++);
    80001580:	1904a683          	lw	a3,400(s1)
    80001584:	0016879b          	addiw	a5,a3,1
    80001588:	18f4a823          	sw	a5,400(s1)
    8000158c:	865a                	mv	a2,s6
    8000158e:	588c                	lw	a1,48(s1)
    80001590:	00006517          	auipc	a0,0x6
    80001594:	ca050513          	addi	a0,a0,-864 # 80007230 <digits+0x1f8>
    80001598:	f2dfe0ef          	jal	ra,800004c4 <printf>
    
    return (uint64)mem;
    8000159c:	ac9d                	j	80001812 <vmfault+0x332>
      printf("[pid %d] MEMFULL\n", p->pid);
    8000159e:	588c                	lw	a1,48(s1)
    800015a0:	00006517          	auipc	a0,0x6
    800015a4:	c5850513          	addi	a0,a0,-936 # 800071f8 <digits+0x1c0>
    800015a8:	f1dfe0ef          	jal	ra,800004c4 <printf>
      return -1;
    800015ac:	597d                	li	s2,-1
    800015ae:	a495                	j	80001812 <vmfault+0x332>
      kfree(mem);
    800015b0:	854e                	mv	a0,s3
    800015b2:	c0aff0ef          	jal	ra,800009bc <kfree>
      return -1;
    800015b6:	597d                	li	s2,-1
    800015b8:	aca9                	j	80001812 <vmfault+0x332>
  }
  else if(va >= p->text_start && va < p->text_end) {
    800015ba:	1684b783          	ld	a5,360(s1)
    800015be:	0ef96463          	bltu	s2,a5,800016a6 <vmfault+0x1c6>
    800015c2:	1704b783          	ld	a5,368(s1)
    800015c6:	0ef97063          	bgeu	s2,a5,800016a6 <vmfault+0x1c6>
    // Text segment - allocate and load from executable
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=exec\n", 
    800015ca:	588c                	lw	a1,48(s1)
    800015cc:	00006697          	auipc	a3,0x6
    800015d0:	ba468693          	addi	a3,a3,-1116 # 80007170 <digits+0x138>
    800015d4:	000a1663          	bnez	s4,800015e0 <vmfault+0x100>
    800015d8:	00006697          	auipc	a3,0x6
    800015dc:	1f068693          	addi	a3,a3,496 # 800077c8 <syscalls+0x1f0>
    800015e0:	865a                	mv	a2,s6
    800015e2:	00006517          	auipc	a0,0x6
    800015e6:	c7650513          	addi	a0,a0,-906 # 80007258 <digits+0x220>
    800015ea:	edbfe0ef          	jal	ra,800004c4 <printf>
            p->pid, page_va, is_write ? "write" : "read");
    
    if((mem = kalloc()) == 0) {
    800015ee:	caeff0ef          	jal	ra,80000a9c <kalloc>
    800015f2:	89aa                	mv	s3,a0
    800015f4:	c959                	beqz	a0,8000168a <vmfault+0x1aa>
      printf("[pid %d] MEMFULL\n", p->pid);
      return -1;
    }
    memset(mem, 0, PGSIZE);  // Zero-fill first
    800015f6:	6605                	lui	a2,0x1
    800015f8:	4581                	li	a1,0
    800015fa:	e46ff0ef          	jal	ra,80000c40 <memset>
    
    // Load actual program content from executable file
    if(p->exec_inode && p->text_file_size > 0) {
    800015fe:	1984b503          	ld	a0,408(s1)
    80001602:	c139                	beqz	a0,80001648 <vmfault+0x168>
    80001604:	1a84b783          	ld	a5,424(s1)
    80001608:	c3a1                	beqz	a5,80001648 <vmfault+0x168>
      uint64 page_offset_in_segment = page_va - p->text_start;
    8000160a:	1684b683          	ld	a3,360(s1)
    8000160e:	40db0733          	sub	a4,s6,a3
      uint64 file_offset = p->text_file_offset + page_offset_in_segment;
    80001612:	1a04b903          	ld	s2,416(s1)
    80001616:	993a                	add	s2,s2,a4
      uint64 bytes_to_read = PGSIZE;
      
      // Don't read beyond the segment
      if(page_offset_in_segment + PGSIZE > p->text_file_size) {
    80001618:	6605                	lui	a2,0x1
    8000161a:	9732                	add	a4,a4,a2
      uint64 bytes_to_read = PGSIZE;
    8000161c:	6a05                	lui	s4,0x1
      if(page_offset_in_segment + PGSIZE > p->text_file_size) {
    8000161e:	00e7f563          	bgeu	a5,a4,80001628 <vmfault+0x148>
        bytes_to_read = p->text_file_size - page_offset_in_segment;
    80001622:	97b6                	add	a5,a5,a3
    80001624:	41678a33          	sub	s4,a5,s6
      }
      
      // Read from executable file into the page
      ilock(p->exec_inode);
    80001628:	60d010ef          	jal	ra,80003434 <ilock>
      readi(p->exec_inode, 0, (uint64)mem, file_offset, bytes_to_read);
    8000162c:	000a071b          	sext.w	a4,s4
    80001630:	0009069b          	sext.w	a3,s2
    80001634:	864e                	mv	a2,s3
    80001636:	4581                	li	a1,0
    80001638:	1984b503          	ld	a0,408(s1)
    8000163c:	184020ef          	jal	ra,800037c0 <readi>
      iunlock(p->exec_inode);
    80001640:	1984b503          	ld	a0,408(s1)
    80001644:	69b010ef          	jal	ra,800034de <iunlock>
    }
    
    // Map the page
    if(mappages(pagetable, page_va, PGSIZE, (uint64)mem, PTE_R | PTE_X | PTE_U) < 0) {
    80001648:	894e                	mv	s2,s3
    8000164a:	4769                	li	a4,26
    8000164c:	86ce                	mv	a3,s3
    8000164e:	6605                	lui	a2,0x1
    80001650:	85da                	mv	a1,s6
    80001652:	8556                	mv	a0,s5
    80001654:	941ff0ef          	jal	ra,80000f94 <mappages>
    80001658:	04054263          	bltz	a0,8000169c <vmfault+0x1bc>
      kfree(mem);
      return -1;
    }
    
    printf("[pid %d] LOADEXEC va=0x%lx\n", p->pid, page_va);
    8000165c:	865a                	mv	a2,s6
    8000165e:	588c                	lw	a1,48(s1)
    80001660:	00006517          	auipc	a0,0x6
    80001664:	c3050513          	addi	a0,a0,-976 # 80007290 <digits+0x258>
    80001668:	e5dfe0ef          	jal	ra,800004c4 <printf>
    printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, page_va, p->next_fifo_seq++);
    8000166c:	1904a683          	lw	a3,400(s1)
    80001670:	0016879b          	addiw	a5,a3,1
    80001674:	18f4a823          	sw	a5,400(s1)
    80001678:	865a                	mv	a2,s6
    8000167a:	588c                	lw	a1,48(s1)
    8000167c:	00006517          	auipc	a0,0x6
    80001680:	bb450513          	addi	a0,a0,-1100 # 80007230 <digits+0x1f8>
    80001684:	e41fe0ef          	jal	ra,800004c4 <printf>
    
    return (uint64)mem;
    80001688:	a269                	j	80001812 <vmfault+0x332>
      printf("[pid %d] MEMFULL\n", p->pid);
    8000168a:	588c                	lw	a1,48(s1)
    8000168c:	00006517          	auipc	a0,0x6
    80001690:	b6c50513          	addi	a0,a0,-1172 # 800071f8 <digits+0x1c0>
    80001694:	e31fe0ef          	jal	ra,800004c4 <printf>
      return -1;
    80001698:	597d                	li	s2,-1
    8000169a:	aaa5                	j	80001812 <vmfault+0x332>
      kfree(mem);
    8000169c:	854e                	mv	a0,s3
    8000169e:	b1eff0ef          	jal	ra,800009bc <kfree>
      return -1;
    800016a2:	597d                	li	s2,-1
    800016a4:	a2bd                	j	80001812 <vmfault+0x332>
  }
  else if(va >= p->data_start && va < p->data_end) {
    800016a6:	1784b783          	ld	a5,376(s1)
    800016aa:	0ef96463          	bltu	s2,a5,80001792 <vmfault+0x2b2>
    800016ae:	1804b783          	ld	a5,384(s1)
    800016b2:	0ef97063          	bgeu	s2,a5,80001792 <vmfault+0x2b2>
    // Data segment - allocate and load from executable
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=exec\n", 
    800016b6:	588c                	lw	a1,48(s1)
    800016b8:	00006697          	auipc	a3,0x6
    800016bc:	ab868693          	addi	a3,a3,-1352 # 80007170 <digits+0x138>
    800016c0:	000a1663          	bnez	s4,800016cc <vmfault+0x1ec>
    800016c4:	00006697          	auipc	a3,0x6
    800016c8:	10468693          	addi	a3,a3,260 # 800077c8 <syscalls+0x1f0>
    800016cc:	865a                	mv	a2,s6
    800016ce:	00006517          	auipc	a0,0x6
    800016d2:	b8a50513          	addi	a0,a0,-1142 # 80007258 <digits+0x220>
    800016d6:	deffe0ef          	jal	ra,800004c4 <printf>
            p->pid, page_va, is_write ? "write" : "read");
    
    if((mem = kalloc()) == 0) {
    800016da:	bc2ff0ef          	jal	ra,80000a9c <kalloc>
    800016de:	89aa                	mv	s3,a0
    800016e0:	c959                	beqz	a0,80001776 <vmfault+0x296>
      printf("[pid %d] MEMFULL\n", p->pid);
      return -1;
    }
    memset(mem, 0, PGSIZE);  // Zero-fill first
    800016e2:	6605                	lui	a2,0x1
    800016e4:	4581                	li	a1,0
    800016e6:	d5aff0ef          	jal	ra,80000c40 <memset>
    
    // Load actual program content from executable file
    if(p->exec_inode && p->data_file_size > 0) {
    800016ea:	1984b503          	ld	a0,408(s1)
    800016ee:	c139                	beqz	a0,80001734 <vmfault+0x254>
    800016f0:	1b84b783          	ld	a5,440(s1)
    800016f4:	c3a1                	beqz	a5,80001734 <vmfault+0x254>
      uint64 page_offset_in_segment = page_va - p->data_start;
    800016f6:	1784b683          	ld	a3,376(s1)
    800016fa:	40db0733          	sub	a4,s6,a3
      uint64 file_offset = p->data_file_offset + page_offset_in_segment;
    800016fe:	1b04b903          	ld	s2,432(s1)
    80001702:	993a                	add	s2,s2,a4
      uint64 bytes_to_read = PGSIZE;
      
      // Don't read beyond the segment
      if(page_offset_in_segment + PGSIZE > p->data_file_size) {
    80001704:	6605                	lui	a2,0x1
    80001706:	9732                	add	a4,a4,a2
      uint64 bytes_to_read = PGSIZE;
    80001708:	6a05                	lui	s4,0x1
      if(page_offset_in_segment + PGSIZE > p->data_file_size) {
    8000170a:	00e7f563          	bgeu	a5,a4,80001714 <vmfault+0x234>
        bytes_to_read = p->data_file_size - page_offset_in_segment;
    8000170e:	97b6                	add	a5,a5,a3
    80001710:	41678a33          	sub	s4,a5,s6
      }
      
      // Read from executable file into the page
      ilock(p->exec_inode);
    80001714:	521010ef          	jal	ra,80003434 <ilock>
      readi(p->exec_inode, 0, (uint64)mem, file_offset, bytes_to_read);
    80001718:	000a071b          	sext.w	a4,s4
    8000171c:	0009069b          	sext.w	a3,s2
    80001720:	864e                	mv	a2,s3
    80001722:	4581                	li	a1,0
    80001724:	1984b503          	ld	a0,408(s1)
    80001728:	098020ef          	jal	ra,800037c0 <readi>
      iunlock(p->exec_inode);
    8000172c:	1984b503          	ld	a0,408(s1)
    80001730:	5af010ef          	jal	ra,800034de <iunlock>
    }
    
    // Map the page
    if(mappages(pagetable, page_va, PGSIZE, (uint64)mem, PTE_R | PTE_W | PTE_U) < 0) {
    80001734:	894e                	mv	s2,s3
    80001736:	4759                	li	a4,22
    80001738:	86ce                	mv	a3,s3
    8000173a:	6605                	lui	a2,0x1
    8000173c:	85da                	mv	a1,s6
    8000173e:	8556                	mv	a0,s5
    80001740:	855ff0ef          	jal	ra,80000f94 <mappages>
    80001744:	04054263          	bltz	a0,80001788 <vmfault+0x2a8>
      kfree(mem);
      return -1;
    }
    
    printf("[pid %d] LOADEXEC va=0x%lx\n", p->pid, page_va);
    80001748:	865a                	mv	a2,s6
    8000174a:	588c                	lw	a1,48(s1)
    8000174c:	00006517          	auipc	a0,0x6
    80001750:	b4450513          	addi	a0,a0,-1212 # 80007290 <digits+0x258>
    80001754:	d71fe0ef          	jal	ra,800004c4 <printf>
    printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, page_va, p->next_fifo_seq++);
    80001758:	1904a683          	lw	a3,400(s1)
    8000175c:	0016879b          	addiw	a5,a3,1
    80001760:	18f4a823          	sw	a5,400(s1)
    80001764:	865a                	mv	a2,s6
    80001766:	588c                	lw	a1,48(s1)
    80001768:	00006517          	auipc	a0,0x6
    8000176c:	ac850513          	addi	a0,a0,-1336 # 80007230 <digits+0x1f8>
    80001770:	d55fe0ef          	jal	ra,800004c4 <printf>
    
    return (uint64)mem;
    80001774:	a879                	j	80001812 <vmfault+0x332>
      printf("[pid %d] MEMFULL\n", p->pid);
    80001776:	588c                	lw	a1,48(s1)
    80001778:	00006517          	auipc	a0,0x6
    8000177c:	a8050513          	addi	a0,a0,-1408 # 800071f8 <digits+0x1c0>
    80001780:	d45fe0ef          	jal	ra,800004c4 <printf>
      return -1;
    80001784:	597d                	li	s2,-1
    80001786:	a071                	j	80001812 <vmfault+0x332>
      kfree(mem);
    80001788:	854e                	mv	a0,s3
    8000178a:	a32ff0ef          	jal	ra,800009bc <kfree>
      return -1;
    8000178e:	597d                	li	s2,-1
    80001790:	a049                	j	80001812 <vmfault+0x332>
  }
  else if(va >= p->heap_start && va < p->sz - USERSTACK*PGSIZE) {
    80001792:	1884b783          	ld	a5,392(s1)
    80001796:	0af96763          	bltu	s2,a5,80001844 <vmfault+0x364>
    8000179a:	0b397563          	bgeu	s2,s3,80001844 <vmfault+0x364>
    // Heap - allocate zero-filled page
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=heap\n", 
    8000179e:	588c                	lw	a1,48(s1)
    800017a0:	00006697          	auipc	a3,0x6
    800017a4:	9d068693          	addi	a3,a3,-1584 # 80007170 <digits+0x138>
    800017a8:	000a1663          	bnez	s4,800017b4 <vmfault+0x2d4>
    800017ac:	00006697          	auipc	a3,0x6
    800017b0:	01c68693          	addi	a3,a3,28 # 800077c8 <syscalls+0x1f0>
    800017b4:	865a                	mv	a2,s6
    800017b6:	00006517          	auipc	a0,0x6
    800017ba:	afa50513          	addi	a0,a0,-1286 # 800072b0 <digits+0x278>
    800017be:	d07fe0ef          	jal	ra,800004c4 <printf>
            p->pid, page_va, is_write ? "write" : "read");
    
    if((mem = kalloc()) == 0) {
    800017c2:	adaff0ef          	jal	ra,80000a9c <kalloc>
    800017c6:	89aa                	mv	s3,a0
    800017c8:	c125                	beqz	a0,80001828 <vmfault+0x348>
      printf("[pid %d] MEMFULL\n", p->pid);
      return -1;
    }
    memset(mem, 0, PGSIZE);
    800017ca:	6605                	lui	a2,0x1
    800017cc:	4581                	li	a1,0
    800017ce:	c72ff0ef          	jal	ra,80000c40 <memset>
    
    // Map the page
    if(mappages(pagetable, page_va, PGSIZE, (uint64)mem, PTE_R | PTE_W | PTE_U) < 0) {
    800017d2:	894e                	mv	s2,s3
    800017d4:	4759                	li	a4,22
    800017d6:	86ce                	mv	a3,s3
    800017d8:	6605                	lui	a2,0x1
    800017da:	85da                	mv	a1,s6
    800017dc:	8556                	mv	a0,s5
    800017de:	fb6ff0ef          	jal	ra,80000f94 <mappages>
    800017e2:	04054c63          	bltz	a0,8000183a <vmfault+0x35a>
      kfree(mem);
      return -1;
    }
    
    printf("[pid %d] ALLOC va=0x%lx\n", p->pid, page_va);
    800017e6:	865a                	mv	a2,s6
    800017e8:	588c                	lw	a1,48(s1)
    800017ea:	00006517          	auipc	a0,0x6
    800017ee:	a2650513          	addi	a0,a0,-1498 # 80007210 <digits+0x1d8>
    800017f2:	cd3fe0ef          	jal	ra,800004c4 <printf>
    printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, page_va, p->next_fifo_seq++);
    800017f6:	1904a683          	lw	a3,400(s1)
    800017fa:	0016879b          	addiw	a5,a3,1
    800017fe:	18f4a823          	sw	a5,400(s1)
    80001802:	865a                	mv	a2,s6
    80001804:	588c                	lw	a1,48(s1)
    80001806:	00006517          	auipc	a0,0x6
    8000180a:	a2a50513          	addi	a0,a0,-1494 # 80007230 <digits+0x1f8>
    8000180e:	cb7fe0ef          	jal	ra,800004c4 <printf>
            p->pid, page_va, is_write ? "write" : "read");
    printf("[pid %d] KILL invalid-access va=0x%lx access=%s\n", 
            p->pid, page_va, is_write ? "write" : "read");
    return -1;
  }
    80001812:	854a                	mv	a0,s2
    80001814:	70e2                	ld	ra,56(sp)
    80001816:	7442                	ld	s0,48(sp)
    80001818:	74a2                	ld	s1,40(sp)
    8000181a:	7902                	ld	s2,32(sp)
    8000181c:	69e2                	ld	s3,24(sp)
    8000181e:	6a42                	ld	s4,16(sp)
    80001820:	6aa2                	ld	s5,8(sp)
    80001822:	6b02                	ld	s6,0(sp)
    80001824:	6121                	addi	sp,sp,64
    80001826:	8082                	ret
      printf("[pid %d] MEMFULL\n", p->pid);
    80001828:	588c                	lw	a1,48(s1)
    8000182a:	00006517          	auipc	a0,0x6
    8000182e:	9ce50513          	addi	a0,a0,-1586 # 800071f8 <digits+0x1c0>
    80001832:	c93fe0ef          	jal	ra,800004c4 <printf>
      return -1;
    80001836:	597d                	li	s2,-1
    80001838:	bfe9                	j	80001812 <vmfault+0x332>
      kfree(mem);
    8000183a:	854e                	mv	a0,s3
    8000183c:	980ff0ef          	jal	ra,800009bc <kfree>
      return -1;
    80001840:	597d                	li	s2,-1
    80001842:	bfc1                	j	80001812 <vmfault+0x332>
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=invalid\n", 
    80001844:	588c                	lw	a1,48(s1)
    80001846:	00006917          	auipc	s2,0x6
    8000184a:	92a90913          	addi	s2,s2,-1750 # 80007170 <digits+0x138>
    8000184e:	000a1663          	bnez	s4,8000185a <vmfault+0x37a>
    80001852:	00006917          	auipc	s2,0x6
    80001856:	f7690913          	addi	s2,s2,-138 # 800077c8 <syscalls+0x1f0>
    8000185a:	86ca                	mv	a3,s2
    8000185c:	865a                	mv	a2,s6
    8000185e:	00006517          	auipc	a0,0x6
    80001862:	a8a50513          	addi	a0,a0,-1398 # 800072e8 <digits+0x2b0>
    80001866:	c5ffe0ef          	jal	ra,800004c4 <printf>
    printf("[pid %d] KILL invalid-access va=0x%lx access=%s\n", 
    8000186a:	86ca                	mv	a3,s2
    8000186c:	865a                	mv	a2,s6
    8000186e:	588c                	lw	a1,48(s1)
    80001870:	00006517          	auipc	a0,0x6
    80001874:	ab050513          	addi	a0,a0,-1360 # 80007320 <digits+0x2e8>
    80001878:	c4dfe0ef          	jal	ra,800004c4 <printf>
    return -1;
    8000187c:	597d                	li	s2,-1
    8000187e:	bf51                	j	80001812 <vmfault+0x332>

0000000080001880 <copyout>:
  while(len > 0){
    80001880:	cec1                	beqz	a3,80001918 <copyout+0x98>
{
    80001882:	711d                	addi	sp,sp,-96
    80001884:	ec86                	sd	ra,88(sp)
    80001886:	e8a2                	sd	s0,80(sp)
    80001888:	e4a6                	sd	s1,72(sp)
    8000188a:	e0ca                	sd	s2,64(sp)
    8000188c:	fc4e                	sd	s3,56(sp)
    8000188e:	f852                	sd	s4,48(sp)
    80001890:	f456                	sd	s5,40(sp)
    80001892:	f05a                	sd	s6,32(sp)
    80001894:	ec5e                	sd	s7,24(sp)
    80001896:	e862                	sd	s8,16(sp)
    80001898:	e466                	sd	s9,8(sp)
    8000189a:	e06a                	sd	s10,0(sp)
    8000189c:	1080                	addi	s0,sp,96
    8000189e:	8c2a                	mv	s8,a0
    800018a0:	8b2e                	mv	s6,a1
    800018a2:	8bb2                	mv	s7,a2
    800018a4:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    800018a6:	74fd                	lui	s1,0xfffff
    800018a8:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    800018aa:	57fd                	li	a5,-1
    800018ac:	83e9                	srli	a5,a5,0x1a
    800018ae:	0697e763          	bltu	a5,s1,8000191c <copyout+0x9c>
    800018b2:	6d05                	lui	s10,0x1
    800018b4:	8cbe                	mv	s9,a5
    800018b6:	a015                	j	800018da <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800018b8:	409b0533          	sub	a0,s6,s1
    800018bc:	0009861b          	sext.w	a2,s3
    800018c0:	85de                	mv	a1,s7
    800018c2:	954a                	add	a0,a0,s2
    800018c4:	bd8ff0ef          	jal	ra,80000c9c <memmove>
    len -= n;
    800018c8:	413a0a33          	sub	s4,s4,s3
    src += n;
    800018cc:	9bce                	add	s7,s7,s3
  while(len > 0){
    800018ce:	040a0363          	beqz	s4,80001914 <copyout+0x94>
    if(va0 >= MAXVA)
    800018d2:	055ce763          	bltu	s9,s5,80001920 <copyout+0xa0>
    va0 = PGROUNDDOWN(dstva);
    800018d6:	84d6                	mv	s1,s5
    dstva = va0 + PGSIZE;
    800018d8:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    800018da:	85a6                	mv	a1,s1
    800018dc:	8562                	mv	a0,s8
    800018de:	e78ff0ef          	jal	ra,80000f56 <walkaddr>
    800018e2:	892a                	mv	s2,a0
    if(pa0 == 0) {
    800018e4:	e901                	bnez	a0,800018f4 <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800018e6:	4601                	li	a2,0
    800018e8:	85a6                	mv	a1,s1
    800018ea:	8562                	mv	a0,s8
    800018ec:	bf5ff0ef          	jal	ra,800014e0 <vmfault>
    800018f0:	892a                	mv	s2,a0
    800018f2:	c90d                	beqz	a0,80001924 <copyout+0xa4>
    pte = walk(pagetable, va0, 0);
    800018f4:	4601                	li	a2,0
    800018f6:	85a6                	mv	a1,s1
    800018f8:	8562                	mv	a0,s8
    800018fa:	dc2ff0ef          	jal	ra,80000ebc <walk>
    if((*pte & PTE_W) == 0)
    800018fe:	611c                	ld	a5,0(a0)
    80001900:	8b91                	andi	a5,a5,4
    80001902:	c39d                	beqz	a5,80001928 <copyout+0xa8>
    n = PGSIZE - (dstva - va0);
    80001904:	01a48ab3          	add	s5,s1,s10
    80001908:	416a89b3          	sub	s3,s5,s6
    if(n > len)
    8000190c:	fb3a76e3          	bgeu	s4,s3,800018b8 <copyout+0x38>
    80001910:	89d2                	mv	s3,s4
    80001912:	b75d                	j	800018b8 <copyout+0x38>
  return 0;
    80001914:	4501                	li	a0,0
    80001916:	a811                	j	8000192a <copyout+0xaa>
    80001918:	4501                	li	a0,0
}
    8000191a:	8082                	ret
      return -1;
    8000191c:	557d                	li	a0,-1
    8000191e:	a031                	j	8000192a <copyout+0xaa>
    80001920:	557d                	li	a0,-1
    80001922:	a021                	j	8000192a <copyout+0xaa>
        return -1;
    80001924:	557d                	li	a0,-1
    80001926:	a011                	j	8000192a <copyout+0xaa>
      return -1;
    80001928:	557d                	li	a0,-1
}
    8000192a:	60e6                	ld	ra,88(sp)
    8000192c:	6446                	ld	s0,80(sp)
    8000192e:	64a6                	ld	s1,72(sp)
    80001930:	6906                	ld	s2,64(sp)
    80001932:	79e2                	ld	s3,56(sp)
    80001934:	7a42                	ld	s4,48(sp)
    80001936:	7aa2                	ld	s5,40(sp)
    80001938:	7b02                	ld	s6,32(sp)
    8000193a:	6be2                	ld	s7,24(sp)
    8000193c:	6c42                	ld	s8,16(sp)
    8000193e:	6ca2                	ld	s9,8(sp)
    80001940:	6d02                	ld	s10,0(sp)
    80001942:	6125                	addi	sp,sp,96
    80001944:	8082                	ret

0000000080001946 <copyin>:
  while(len > 0){
    80001946:	c6c9                	beqz	a3,800019d0 <copyin+0x8a>
{
    80001948:	715d                	addi	sp,sp,-80
    8000194a:	e486                	sd	ra,72(sp)
    8000194c:	e0a2                	sd	s0,64(sp)
    8000194e:	fc26                	sd	s1,56(sp)
    80001950:	f84a                	sd	s2,48(sp)
    80001952:	f44e                	sd	s3,40(sp)
    80001954:	f052                	sd	s4,32(sp)
    80001956:	ec56                	sd	s5,24(sp)
    80001958:	e85a                	sd	s6,16(sp)
    8000195a:	e45e                	sd	s7,8(sp)
    8000195c:	e062                	sd	s8,0(sp)
    8000195e:	0880                	addi	s0,sp,80
    80001960:	8baa                	mv	s7,a0
    80001962:	8aae                	mv	s5,a1
    80001964:	8932                	mv	s2,a2
    80001966:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001968:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    8000196a:	6b05                	lui	s6,0x1
    8000196c:	a035                	j	80001998 <copyin+0x52>
    8000196e:	412984b3          	sub	s1,s3,s2
    80001972:	94da                	add	s1,s1,s6
    if(n > len)
    80001974:	009a7363          	bgeu	s4,s1,8000197a <copyin+0x34>
    80001978:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000197a:	413905b3          	sub	a1,s2,s3
    8000197e:	0004861b          	sext.w	a2,s1
    80001982:	95aa                	add	a1,a1,a0
    80001984:	8556                	mv	a0,s5
    80001986:	b16ff0ef          	jal	ra,80000c9c <memmove>
    len -= n;
    8000198a:	409a0a33          	sub	s4,s4,s1
    dst += n;
    8000198e:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001990:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001994:	020a0163          	beqz	s4,800019b6 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001998:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    8000199c:	85ce                	mv	a1,s3
    8000199e:	855e                	mv	a0,s7
    800019a0:	db6ff0ef          	jal	ra,80000f56 <walkaddr>
    if(pa0 == 0) {
    800019a4:	f569                	bnez	a0,8000196e <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800019a6:	4601                	li	a2,0
    800019a8:	85ce                	mv	a1,s3
    800019aa:	855e                	mv	a0,s7
    800019ac:	b35ff0ef          	jal	ra,800014e0 <vmfault>
    800019b0:	fd5d                	bnez	a0,8000196e <copyin+0x28>
        return -1;
    800019b2:	557d                	li	a0,-1
    800019b4:	a011                	j	800019b8 <copyin+0x72>
  return 0;
    800019b6:	4501                	li	a0,0
}
    800019b8:	60a6                	ld	ra,72(sp)
    800019ba:	6406                	ld	s0,64(sp)
    800019bc:	74e2                	ld	s1,56(sp)
    800019be:	7942                	ld	s2,48(sp)
    800019c0:	79a2                	ld	s3,40(sp)
    800019c2:	7a02                	ld	s4,32(sp)
    800019c4:	6ae2                	ld	s5,24(sp)
    800019c6:	6b42                	ld	s6,16(sp)
    800019c8:	6ba2                	ld	s7,8(sp)
    800019ca:	6c02                	ld	s8,0(sp)
    800019cc:	6161                	addi	sp,sp,80
    800019ce:	8082                	ret
  return 0;
    800019d0:	4501                	li	a0,0
}
    800019d2:	8082                	ret

00000000800019d4 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800019d4:	7139                	addi	sp,sp,-64
    800019d6:	fc06                	sd	ra,56(sp)
    800019d8:	f822                	sd	s0,48(sp)
    800019da:	f426                	sd	s1,40(sp)
    800019dc:	f04a                	sd	s2,32(sp)
    800019de:	ec4e                	sd	s3,24(sp)
    800019e0:	e852                	sd	s4,16(sp)
    800019e2:	e456                	sd	s5,8(sp)
    800019e4:	e05a                	sd	s6,0(sp)
    800019e6:	0080                	addi	s0,sp,64
    800019e8:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800019ea:	0000e497          	auipc	s1,0xe
    800019ee:	65e48493          	addi	s1,s1,1630 # 80010048 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800019f2:	8b26                	mv	s6,s1
    800019f4:	00005a97          	auipc	s5,0x5
    800019f8:	60ca8a93          	addi	s5,s5,1548 # 80007000 <etext>
    800019fc:	04000937          	lui	s2,0x4000
    80001a00:	197d                	addi	s2,s2,-1
    80001a02:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a04:	00015a17          	auipc	s4,0x15
    80001a08:	644a0a13          	addi	s4,s4,1604 # 80017048 <tickslock>
    char *pa = kalloc();
    80001a0c:	890ff0ef          	jal	ra,80000a9c <kalloc>
    80001a10:	862a                	mv	a2,a0
    if(pa == 0)
    80001a12:	c121                	beqz	a0,80001a52 <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    80001a14:	416485b3          	sub	a1,s1,s6
    80001a18:	8599                	srai	a1,a1,0x6
    80001a1a:	000ab783          	ld	a5,0(s5)
    80001a1e:	02f585b3          	mul	a1,a1,a5
    80001a22:	2585                	addiw	a1,a1,1
    80001a24:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a28:	4719                	li	a4,6
    80001a2a:	6685                	lui	a3,0x1
    80001a2c:	40b905b3          	sub	a1,s2,a1
    80001a30:	854e                	mv	a0,s3
    80001a32:	e12ff0ef          	jal	ra,80001044 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a36:	1c048493          	addi	s1,s1,448
    80001a3a:	fd4499e3          	bne	s1,s4,80001a0c <proc_mapstacks+0x38>
  }
}
    80001a3e:	70e2                	ld	ra,56(sp)
    80001a40:	7442                	ld	s0,48(sp)
    80001a42:	74a2                	ld	s1,40(sp)
    80001a44:	7902                	ld	s2,32(sp)
    80001a46:	69e2                	ld	s3,24(sp)
    80001a48:	6a42                	ld	s4,16(sp)
    80001a4a:	6aa2                	ld	s5,8(sp)
    80001a4c:	6b02                	ld	s6,0(sp)
    80001a4e:	6121                	addi	sp,sp,64
    80001a50:	8082                	ret
      panic("kalloc");
    80001a52:	00006517          	auipc	a0,0x6
    80001a56:	90650513          	addi	a0,a0,-1786 # 80007358 <digits+0x320>
    80001a5a:	d31fe0ef          	jal	ra,8000078a <panic>

0000000080001a5e <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001a5e:	7139                	addi	sp,sp,-64
    80001a60:	fc06                	sd	ra,56(sp)
    80001a62:	f822                	sd	s0,48(sp)
    80001a64:	f426                	sd	s1,40(sp)
    80001a66:	f04a                	sd	s2,32(sp)
    80001a68:	ec4e                	sd	s3,24(sp)
    80001a6a:	e852                	sd	s4,16(sp)
    80001a6c:	e456                	sd	s5,8(sp)
    80001a6e:	e05a                	sd	s6,0(sp)
    80001a70:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001a72:	00006597          	auipc	a1,0x6
    80001a76:	8ee58593          	addi	a1,a1,-1810 # 80007360 <digits+0x328>
    80001a7a:	0000e517          	auipc	a0,0xe
    80001a7e:	19e50513          	addi	a0,a0,414 # 8000fc18 <pid_lock>
    80001a82:	86aff0ef          	jal	ra,80000aec <initlock>
  initlock(&wait_lock, "wait_lock");
    80001a86:	00006597          	auipc	a1,0x6
    80001a8a:	8e258593          	addi	a1,a1,-1822 # 80007368 <digits+0x330>
    80001a8e:	0000e517          	auipc	a0,0xe
    80001a92:	1a250513          	addi	a0,a0,418 # 8000fc30 <wait_lock>
    80001a96:	856ff0ef          	jal	ra,80000aec <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a9a:	0000e497          	auipc	s1,0xe
    80001a9e:	5ae48493          	addi	s1,s1,1454 # 80010048 <proc>
      initlock(&p->lock, "proc");
    80001aa2:	00006b17          	auipc	s6,0x6
    80001aa6:	8d6b0b13          	addi	s6,s6,-1834 # 80007378 <digits+0x340>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001aaa:	8aa6                	mv	s5,s1
    80001aac:	00005a17          	auipc	s4,0x5
    80001ab0:	554a0a13          	addi	s4,s4,1364 # 80007000 <etext>
    80001ab4:	04000937          	lui	s2,0x4000
    80001ab8:	197d                	addi	s2,s2,-1
    80001aba:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001abc:	00015997          	auipc	s3,0x15
    80001ac0:	58c98993          	addi	s3,s3,1420 # 80017048 <tickslock>
      initlock(&p->lock, "proc");
    80001ac4:	85da                	mv	a1,s6
    80001ac6:	8526                	mv	a0,s1
    80001ac8:	824ff0ef          	jal	ra,80000aec <initlock>
      p->state = UNUSED;
    80001acc:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001ad0:	415487b3          	sub	a5,s1,s5
    80001ad4:	8799                	srai	a5,a5,0x6
    80001ad6:	000a3703          	ld	a4,0(s4)
    80001ada:	02e787b3          	mul	a5,a5,a4
    80001ade:	2785                	addiw	a5,a5,1
    80001ae0:	00d7979b          	slliw	a5,a5,0xd
    80001ae4:	40f907b3          	sub	a5,s2,a5
    80001ae8:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aea:	1c048493          	addi	s1,s1,448
    80001aee:	fd349be3          	bne	s1,s3,80001ac4 <procinit+0x66>
  }
}
    80001af2:	70e2                	ld	ra,56(sp)
    80001af4:	7442                	ld	s0,48(sp)
    80001af6:	74a2                	ld	s1,40(sp)
    80001af8:	7902                	ld	s2,32(sp)
    80001afa:	69e2                	ld	s3,24(sp)
    80001afc:	6a42                	ld	s4,16(sp)
    80001afe:	6aa2                	ld	s5,8(sp)
    80001b00:	6b02                	ld	s6,0(sp)
    80001b02:	6121                	addi	sp,sp,64
    80001b04:	8082                	ret

0000000080001b06 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001b06:	1141                	addi	sp,sp,-16
    80001b08:	e422                	sd	s0,8(sp)
    80001b0a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b0c:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001b0e:	2501                	sext.w	a0,a0
    80001b10:	6422                	ld	s0,8(sp)
    80001b12:	0141                	addi	sp,sp,16
    80001b14:	8082                	ret

0000000080001b16 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001b16:	1141                	addi	sp,sp,-16
    80001b18:	e422                	sd	s0,8(sp)
    80001b1a:	0800                	addi	s0,sp,16
    80001b1c:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001b1e:	2781                	sext.w	a5,a5
    80001b20:	079e                	slli	a5,a5,0x7
  return c;
}
    80001b22:	0000e517          	auipc	a0,0xe
    80001b26:	12650513          	addi	a0,a0,294 # 8000fc48 <cpus>
    80001b2a:	953e                	add	a0,a0,a5
    80001b2c:	6422                	ld	s0,8(sp)
    80001b2e:	0141                	addi	sp,sp,16
    80001b30:	8082                	ret

0000000080001b32 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001b32:	1101                	addi	sp,sp,-32
    80001b34:	ec06                	sd	ra,24(sp)
    80001b36:	e822                	sd	s0,16(sp)
    80001b38:	e426                	sd	s1,8(sp)
    80001b3a:	1000                	addi	s0,sp,32
  push_off();
    80001b3c:	ff1fe0ef          	jal	ra,80000b2c <push_off>
    80001b40:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001b42:	2781                	sext.w	a5,a5
    80001b44:	079e                	slli	a5,a5,0x7
    80001b46:	0000e717          	auipc	a4,0xe
    80001b4a:	0d270713          	addi	a4,a4,210 # 8000fc18 <pid_lock>
    80001b4e:	97ba                	add	a5,a5,a4
    80001b50:	7b84                	ld	s1,48(a5)
  pop_off();
    80001b52:	85eff0ef          	jal	ra,80000bb0 <pop_off>
  return p;
}
    80001b56:	8526                	mv	a0,s1
    80001b58:	60e2                	ld	ra,24(sp)
    80001b5a:	6442                	ld	s0,16(sp)
    80001b5c:	64a2                	ld	s1,8(sp)
    80001b5e:	6105                	addi	sp,sp,32
    80001b60:	8082                	ret

0000000080001b62 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001b62:	7179                	addi	sp,sp,-48
    80001b64:	f406                	sd	ra,40(sp)
    80001b66:	f022                	sd	s0,32(sp)
    80001b68:	ec26                	sd	s1,24(sp)
    80001b6a:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001b6c:	fc7ff0ef          	jal	ra,80001b32 <myproc>
    80001b70:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001b72:	892ff0ef          	jal	ra,80000c04 <release>

  if (first) {
    80001b76:	00006797          	auipc	a5,0x6
    80001b7a:	f6a7a783          	lw	a5,-150(a5) # 80007ae0 <first.1>
    80001b7e:	cf8d                	beqz	a5,80001bb8 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001b80:	4505                	li	a0,1
    80001b82:	3a3010ef          	jal	ra,80003724 <fsinit>

    first = 0;
    80001b86:	00006797          	auipc	a5,0x6
    80001b8a:	f407ad23          	sw	zero,-166(a5) # 80007ae0 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001b8e:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001b92:	00005517          	auipc	a0,0x5
    80001b96:	7ee50513          	addi	a0,a0,2030 # 80007380 <digits+0x348>
    80001b9a:	fca43823          	sd	a0,-48(s0)
    80001b9e:	fc043c23          	sd	zero,-40(s0)
    80001ba2:	fd040593          	addi	a1,s0,-48
    80001ba6:	41d020ef          	jal	ra,800047c2 <kexec>
    80001baa:	6cbc                	ld	a5,88(s1)
    80001bac:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001bae:	6cbc                	ld	a5,88(s1)
    80001bb0:	7bb8                	ld	a4,112(a5)
    80001bb2:	57fd                	li	a5,-1
    80001bb4:	02f70d63          	beq	a4,a5,80001bee <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001bb8:	2d5000ef          	jal	ra,8000268c <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001bbc:	68a8                	ld	a0,80(s1)
    80001bbe:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001bc0:	04000737          	lui	a4,0x4000
    80001bc4:	00004797          	auipc	a5,0x4
    80001bc8:	4d878793          	addi	a5,a5,1240 # 8000609c <userret>
    80001bcc:	00004697          	auipc	a3,0x4
    80001bd0:	43468693          	addi	a3,a3,1076 # 80006000 <_trampoline>
    80001bd4:	8f95                	sub	a5,a5,a3
    80001bd6:	177d                	addi	a4,a4,-1
    80001bd8:	0732                	slli	a4,a4,0xc
    80001bda:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001bdc:	577d                	li	a4,-1
    80001bde:	177e                	slli	a4,a4,0x3f
    80001be0:	8d59                	or	a0,a0,a4
    80001be2:	9782                	jalr	a5
}
    80001be4:	70a2                	ld	ra,40(sp)
    80001be6:	7402                	ld	s0,32(sp)
    80001be8:	64e2                	ld	s1,24(sp)
    80001bea:	6145                	addi	sp,sp,48
    80001bec:	8082                	ret
      panic("exec");
    80001bee:	00005517          	auipc	a0,0x5
    80001bf2:	79a50513          	addi	a0,a0,1946 # 80007388 <digits+0x350>
    80001bf6:	b95fe0ef          	jal	ra,8000078a <panic>

0000000080001bfa <allocpid>:
{
    80001bfa:	1101                	addi	sp,sp,-32
    80001bfc:	ec06                	sd	ra,24(sp)
    80001bfe:	e822                	sd	s0,16(sp)
    80001c00:	e426                	sd	s1,8(sp)
    80001c02:	e04a                	sd	s2,0(sp)
    80001c04:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001c06:	0000e917          	auipc	s2,0xe
    80001c0a:	01290913          	addi	s2,s2,18 # 8000fc18 <pid_lock>
    80001c0e:	854a                	mv	a0,s2
    80001c10:	f5dfe0ef          	jal	ra,80000b6c <acquire>
  pid = nextpid;
    80001c14:	00006797          	auipc	a5,0x6
    80001c18:	ed078793          	addi	a5,a5,-304 # 80007ae4 <nextpid>
    80001c1c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001c1e:	0014871b          	addiw	a4,s1,1
    80001c22:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001c24:	854a                	mv	a0,s2
    80001c26:	fdffe0ef          	jal	ra,80000c04 <release>
}
    80001c2a:	8526                	mv	a0,s1
    80001c2c:	60e2                	ld	ra,24(sp)
    80001c2e:	6442                	ld	s0,16(sp)
    80001c30:	64a2                	ld	s1,8(sp)
    80001c32:	6902                	ld	s2,0(sp)
    80001c34:	6105                	addi	sp,sp,32
    80001c36:	8082                	ret

0000000080001c38 <proc_pagetable>:
{
    80001c38:	1101                	addi	sp,sp,-32
    80001c3a:	ec06                	sd	ra,24(sp)
    80001c3c:	e822                	sd	s0,16(sp)
    80001c3e:	e426                	sd	s1,8(sp)
    80001c40:	e04a                	sd	s2,0(sp)
    80001c42:	1000                	addi	s0,sp,32
    80001c44:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c46:	cf4ff0ef          	jal	ra,8000113a <uvmcreate>
    80001c4a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001c4c:	cd05                	beqz	a0,80001c84 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c4e:	4729                	li	a4,10
    80001c50:	00004697          	auipc	a3,0x4
    80001c54:	3b068693          	addi	a3,a3,944 # 80006000 <_trampoline>
    80001c58:	6605                	lui	a2,0x1
    80001c5a:	040005b7          	lui	a1,0x4000
    80001c5e:	15fd                	addi	a1,a1,-1
    80001c60:	05b2                	slli	a1,a1,0xc
    80001c62:	b32ff0ef          	jal	ra,80000f94 <mappages>
    80001c66:	02054663          	bltz	a0,80001c92 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c6a:	4719                	li	a4,6
    80001c6c:	05893683          	ld	a3,88(s2)
    80001c70:	6605                	lui	a2,0x1
    80001c72:	020005b7          	lui	a1,0x2000
    80001c76:	15fd                	addi	a1,a1,-1
    80001c78:	05b6                	slli	a1,a1,0xd
    80001c7a:	8526                	mv	a0,s1
    80001c7c:	b18ff0ef          	jal	ra,80000f94 <mappages>
    80001c80:	00054f63          	bltz	a0,80001c9e <proc_pagetable+0x66>
}
    80001c84:	8526                	mv	a0,s1
    80001c86:	60e2                	ld	ra,24(sp)
    80001c88:	6442                	ld	s0,16(sp)
    80001c8a:	64a2                	ld	s1,8(sp)
    80001c8c:	6902                	ld	s2,0(sp)
    80001c8e:	6105                	addi	sp,sp,32
    80001c90:	8082                	ret
    uvmfree(pagetable, 0);
    80001c92:	4581                	li	a1,0
    80001c94:	8526                	mv	a0,s1
    80001c96:	e82ff0ef          	jal	ra,80001318 <uvmfree>
    return 0;
    80001c9a:	4481                	li	s1,0
    80001c9c:	b7e5                	j	80001c84 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c9e:	4681                	li	a3,0
    80001ca0:	4605                	li	a2,1
    80001ca2:	040005b7          	lui	a1,0x4000
    80001ca6:	15fd                	addi	a1,a1,-1
    80001ca8:	05b2                	slli	a1,a1,0xc
    80001caa:	8526                	mv	a0,s1
    80001cac:	cb4ff0ef          	jal	ra,80001160 <uvmunmap>
    uvmfree(pagetable, 0);
    80001cb0:	4581                	li	a1,0
    80001cb2:	8526                	mv	a0,s1
    80001cb4:	e64ff0ef          	jal	ra,80001318 <uvmfree>
    return 0;
    80001cb8:	4481                	li	s1,0
    80001cba:	b7e9                	j	80001c84 <proc_pagetable+0x4c>

0000000080001cbc <proc_freepagetable>:
{
    80001cbc:	1101                	addi	sp,sp,-32
    80001cbe:	ec06                	sd	ra,24(sp)
    80001cc0:	e822                	sd	s0,16(sp)
    80001cc2:	e426                	sd	s1,8(sp)
    80001cc4:	e04a                	sd	s2,0(sp)
    80001cc6:	1000                	addi	s0,sp,32
    80001cc8:	84aa                	mv	s1,a0
    80001cca:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ccc:	4681                	li	a3,0
    80001cce:	4605                	li	a2,1
    80001cd0:	040005b7          	lui	a1,0x4000
    80001cd4:	15fd                	addi	a1,a1,-1
    80001cd6:	05b2                	slli	a1,a1,0xc
    80001cd8:	c88ff0ef          	jal	ra,80001160 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001cdc:	4681                	li	a3,0
    80001cde:	4605                	li	a2,1
    80001ce0:	020005b7          	lui	a1,0x2000
    80001ce4:	15fd                	addi	a1,a1,-1
    80001ce6:	05b6                	slli	a1,a1,0xd
    80001ce8:	8526                	mv	a0,s1
    80001cea:	c76ff0ef          	jal	ra,80001160 <uvmunmap>
  uvmfree(pagetable, sz);
    80001cee:	85ca                	mv	a1,s2
    80001cf0:	8526                	mv	a0,s1
    80001cf2:	e26ff0ef          	jal	ra,80001318 <uvmfree>
}
    80001cf6:	60e2                	ld	ra,24(sp)
    80001cf8:	6442                	ld	s0,16(sp)
    80001cfa:	64a2                	ld	s1,8(sp)
    80001cfc:	6902                	ld	s2,0(sp)
    80001cfe:	6105                	addi	sp,sp,32
    80001d00:	8082                	ret

0000000080001d02 <freeproc>:
{
    80001d02:	1101                	addi	sp,sp,-32
    80001d04:	ec06                	sd	ra,24(sp)
    80001d06:	e822                	sd	s0,16(sp)
    80001d08:	e426                	sd	s1,8(sp)
    80001d0a:	1000                	addi	s0,sp,32
    80001d0c:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001d0e:	6d28                	ld	a0,88(a0)
    80001d10:	c119                	beqz	a0,80001d16 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001d12:	cabfe0ef          	jal	ra,800009bc <kfree>
  p->trapframe = 0;
    80001d16:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001d1a:	68a8                	ld	a0,80(s1)
    80001d1c:	c501                	beqz	a0,80001d24 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001d1e:	64ac                	ld	a1,72(s1)
    80001d20:	f9dff0ef          	jal	ra,80001cbc <proc_freepagetable>
  p->pagetable = 0;
    80001d24:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001d28:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001d2c:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001d30:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001d34:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001d38:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001d3c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001d40:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001d44:	0004ac23          	sw	zero,24(s1)
}
    80001d48:	60e2                	ld	ra,24(sp)
    80001d4a:	6442                	ld	s0,16(sp)
    80001d4c:	64a2                	ld	s1,8(sp)
    80001d4e:	6105                	addi	sp,sp,32
    80001d50:	8082                	ret

0000000080001d52 <allocproc>:
{
    80001d52:	1101                	addi	sp,sp,-32
    80001d54:	ec06                	sd	ra,24(sp)
    80001d56:	e822                	sd	s0,16(sp)
    80001d58:	e426                	sd	s1,8(sp)
    80001d5a:	e04a                	sd	s2,0(sp)
    80001d5c:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d5e:	0000e497          	auipc	s1,0xe
    80001d62:	2ea48493          	addi	s1,s1,746 # 80010048 <proc>
    80001d66:	00015917          	auipc	s2,0x15
    80001d6a:	2e290913          	addi	s2,s2,738 # 80017048 <tickslock>
    acquire(&p->lock);
    80001d6e:	8526                	mv	a0,s1
    80001d70:	dfdfe0ef          	jal	ra,80000b6c <acquire>
    if(p->state == UNUSED) {
    80001d74:	4c9c                	lw	a5,24(s1)
    80001d76:	cb91                	beqz	a5,80001d8a <allocproc+0x38>
      release(&p->lock);
    80001d78:	8526                	mv	a0,s1
    80001d7a:	e8bfe0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d7e:	1c048493          	addi	s1,s1,448
    80001d82:	ff2496e3          	bne	s1,s2,80001d6e <allocproc+0x1c>
  return 0;
    80001d86:	4481                	li	s1,0
    80001d88:	a0bd                	j	80001df6 <allocproc+0xa4>
  p->pid = allocpid();
    80001d8a:	e71ff0ef          	jal	ra,80001bfa <allocpid>
    80001d8e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001d90:	4785                	li	a5,1
    80001d92:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001d94:	d09fe0ef          	jal	ra,80000a9c <kalloc>
    80001d98:	892a                	mv	s2,a0
    80001d9a:	eca8                	sd	a0,88(s1)
    80001d9c:	c525                	beqz	a0,80001e04 <allocproc+0xb2>
  p->pagetable = proc_pagetable(p);
    80001d9e:	8526                	mv	a0,s1
    80001da0:	e99ff0ef          	jal	ra,80001c38 <proc_pagetable>
    80001da4:	892a                	mv	s2,a0
    80001da6:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001da8:	c535                	beqz	a0,80001e14 <allocproc+0xc2>
  memset(&p->context, 0, sizeof(p->context));
    80001daa:	07000613          	li	a2,112
    80001dae:	4581                	li	a1,0
    80001db0:	06048513          	addi	a0,s1,96
    80001db4:	e8dfe0ef          	jal	ra,80000c40 <memset>
  p->context.ra = (uint64)forkret;
    80001db8:	00000797          	auipc	a5,0x0
    80001dbc:	daa78793          	addi	a5,a5,-598 # 80001b62 <forkret>
    80001dc0:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001dc2:	60bc                	ld	a5,64(s1)
    80001dc4:	6705                	lui	a4,0x1
    80001dc6:	97ba                	add	a5,a5,a4
    80001dc8:	f4bc                	sd	a5,104(s1)
  p->text_start = 0;
    80001dca:	1604b423          	sd	zero,360(s1)
  p->text_end = 0;
    80001dce:	1604b823          	sd	zero,368(s1)
  p->data_start = 0;
    80001dd2:	1604bc23          	sd	zero,376(s1)
  p->data_end = 0;
    80001dd6:	1804b023          	sd	zero,384(s1)
  p->heap_start = 0;
    80001dda:	1804b423          	sd	zero,392(s1)
  p->next_fifo_seq = 0;
    80001dde:	1804a823          	sw	zero,400(s1)
  p->exec_inode = 0;
    80001de2:	1804bc23          	sd	zero,408(s1)
  p->text_file_offset = 0;
    80001de6:	1a04b023          	sd	zero,416(s1)
p->text_file_size = 0;
    80001dea:	1a04b423          	sd	zero,424(s1)
p->data_file_offset = 0;
    80001dee:	1a04b823          	sd	zero,432(s1)
p->data_file_size = 0;
    80001df2:	1a04bc23          	sd	zero,440(s1)
}
    80001df6:	8526                	mv	a0,s1
    80001df8:	60e2                	ld	ra,24(sp)
    80001dfa:	6442                	ld	s0,16(sp)
    80001dfc:	64a2                	ld	s1,8(sp)
    80001dfe:	6902                	ld	s2,0(sp)
    80001e00:	6105                	addi	sp,sp,32
    80001e02:	8082                	ret
    freeproc(p);
    80001e04:	8526                	mv	a0,s1
    80001e06:	efdff0ef          	jal	ra,80001d02 <freeproc>
    release(&p->lock);
    80001e0a:	8526                	mv	a0,s1
    80001e0c:	df9fe0ef          	jal	ra,80000c04 <release>
    return 0;
    80001e10:	84ca                	mv	s1,s2
    80001e12:	b7d5                	j	80001df6 <allocproc+0xa4>
    freeproc(p);
    80001e14:	8526                	mv	a0,s1
    80001e16:	eedff0ef          	jal	ra,80001d02 <freeproc>
    release(&p->lock);
    80001e1a:	8526                	mv	a0,s1
    80001e1c:	de9fe0ef          	jal	ra,80000c04 <release>
    return 0;
    80001e20:	84ca                	mv	s1,s2
    80001e22:	bfd1                	j	80001df6 <allocproc+0xa4>

0000000080001e24 <userinit>:
{
    80001e24:	1101                	addi	sp,sp,-32
    80001e26:	ec06                	sd	ra,24(sp)
    80001e28:	e822                	sd	s0,16(sp)
    80001e2a:	e426                	sd	s1,8(sp)
    80001e2c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001e2e:	f25ff0ef          	jal	ra,80001d52 <allocproc>
    80001e32:	84aa                	mv	s1,a0
  initproc = p;
    80001e34:	00006797          	auipc	a5,0x6
    80001e38:	cca7be23          	sd	a0,-804(a5) # 80007b10 <initproc>
  p->cwd = namei("/");
    80001e3c:	00005517          	auipc	a0,0x5
    80001e40:	55450513          	addi	a0,a0,1364 # 80007390 <digits+0x358>
    80001e44:	5df010ef          	jal	ra,80003c22 <namei>
    80001e48:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001e4c:	478d                	li	a5,3
    80001e4e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001e50:	8526                	mv	a0,s1
    80001e52:	db3fe0ef          	jal	ra,80000c04 <release>
}
    80001e56:	60e2                	ld	ra,24(sp)
    80001e58:	6442                	ld	s0,16(sp)
    80001e5a:	64a2                	ld	s1,8(sp)
    80001e5c:	6105                	addi	sp,sp,32
    80001e5e:	8082                	ret

0000000080001e60 <growproc>:
{
    80001e60:	1101                	addi	sp,sp,-32
    80001e62:	ec06                	sd	ra,24(sp)
    80001e64:	e822                	sd	s0,16(sp)
    80001e66:	e426                	sd	s1,8(sp)
    80001e68:	e04a                	sd	s2,0(sp)
    80001e6a:	1000                	addi	s0,sp,32
    80001e6c:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001e6e:	cc5ff0ef          	jal	ra,80001b32 <myproc>
    80001e72:	84aa                	mv	s1,a0
  sz = p->sz;
    80001e74:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001e76:	01204c63          	bgtz	s2,80001e8e <growproc+0x2e>
  } else if(n < 0){
    80001e7a:	02094463          	bltz	s2,80001ea2 <growproc+0x42>
  p->sz = sz;
    80001e7e:	e4ac                	sd	a1,72(s1)
  return 0;
    80001e80:	4501                	li	a0,0
}
    80001e82:	60e2                	ld	ra,24(sp)
    80001e84:	6442                	ld	s0,16(sp)
    80001e86:	64a2                	ld	s1,8(sp)
    80001e88:	6902                	ld	s2,0(sp)
    80001e8a:	6105                	addi	sp,sp,32
    80001e8c:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001e8e:	4691                	li	a3,4
    80001e90:	00b90633          	add	a2,s2,a1
    80001e94:	6928                	ld	a0,80(a0)
    80001e96:	b8aff0ef          	jal	ra,80001220 <uvmalloc>
    80001e9a:	85aa                	mv	a1,a0
    80001e9c:	f16d                	bnez	a0,80001e7e <growproc+0x1e>
      return -1;
    80001e9e:	557d                	li	a0,-1
    80001ea0:	b7cd                	j	80001e82 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001ea2:	00b90633          	add	a2,s2,a1
    80001ea6:	6928                	ld	a0,80(a0)
    80001ea8:	b34ff0ef          	jal	ra,800011dc <uvmdealloc>
    80001eac:	85aa                	mv	a1,a0
    80001eae:	bfc1                	j	80001e7e <growproc+0x1e>

0000000080001eb0 <kfork>:
{
    80001eb0:	7139                	addi	sp,sp,-64
    80001eb2:	fc06                	sd	ra,56(sp)
    80001eb4:	f822                	sd	s0,48(sp)
    80001eb6:	f426                	sd	s1,40(sp)
    80001eb8:	f04a                	sd	s2,32(sp)
    80001eba:	ec4e                	sd	s3,24(sp)
    80001ebc:	e852                	sd	s4,16(sp)
    80001ebe:	e456                	sd	s5,8(sp)
    80001ec0:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001ec2:	c71ff0ef          	jal	ra,80001b32 <myproc>
    80001ec6:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001ec8:	e8bff0ef          	jal	ra,80001d52 <allocproc>
    80001ecc:	0e050663          	beqz	a0,80001fb8 <kfork+0x108>
    80001ed0:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001ed2:	048ab603          	ld	a2,72(s5)
    80001ed6:	692c                	ld	a1,80(a0)
    80001ed8:	050ab503          	ld	a0,80(s5)
    80001edc:	c6cff0ef          	jal	ra,80001348 <uvmcopy>
    80001ee0:	04054863          	bltz	a0,80001f30 <kfork+0x80>
  np->sz = p->sz;
    80001ee4:	048ab783          	ld	a5,72(s5)
    80001ee8:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001eec:	058ab683          	ld	a3,88(s5)
    80001ef0:	87b6                	mv	a5,a3
    80001ef2:	058a3703          	ld	a4,88(s4)
    80001ef6:	12068693          	addi	a3,a3,288
    80001efa:	0007b803          	ld	a6,0(a5)
    80001efe:	6788                	ld	a0,8(a5)
    80001f00:	6b8c                	ld	a1,16(a5)
    80001f02:	6f90                	ld	a2,24(a5)
    80001f04:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001f08:	e708                	sd	a0,8(a4)
    80001f0a:	eb0c                	sd	a1,16(a4)
    80001f0c:	ef10                	sd	a2,24(a4)
    80001f0e:	02078793          	addi	a5,a5,32
    80001f12:	02070713          	addi	a4,a4,32
    80001f16:	fed792e3          	bne	a5,a3,80001efa <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001f1a:	058a3783          	ld	a5,88(s4)
    80001f1e:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001f22:	0d0a8493          	addi	s1,s5,208
    80001f26:	0d0a0913          	addi	s2,s4,208
    80001f2a:	150a8993          	addi	s3,s5,336
    80001f2e:	a829                	j	80001f48 <kfork+0x98>
    freeproc(np);
    80001f30:	8552                	mv	a0,s4
    80001f32:	dd1ff0ef          	jal	ra,80001d02 <freeproc>
    release(&np->lock);
    80001f36:	8552                	mv	a0,s4
    80001f38:	ccdfe0ef          	jal	ra,80000c04 <release>
    return -1;
    80001f3c:	597d                	li	s2,-1
    80001f3e:	a09d                	j	80001fa4 <kfork+0xf4>
  for(i = 0; i < NOFILE; i++)
    80001f40:	04a1                	addi	s1,s1,8
    80001f42:	0921                	addi	s2,s2,8
    80001f44:	01348963          	beq	s1,s3,80001f56 <kfork+0xa6>
    if(p->ofile[i])
    80001f48:	6088                	ld	a0,0(s1)
    80001f4a:	d97d                	beqz	a0,80001f40 <kfork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f4c:	28e020ef          	jal	ra,800041da <filedup>
    80001f50:	00a93023          	sd	a0,0(s2)
    80001f54:	b7f5                	j	80001f40 <kfork+0x90>
  np->cwd = idup(p->cwd);
    80001f56:	150ab503          	ld	a0,336(s5)
    80001f5a:	4a4010ef          	jal	ra,800033fe <idup>
    80001f5e:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f62:	4641                	li	a2,16
    80001f64:	158a8593          	addi	a1,s5,344
    80001f68:	158a0513          	addi	a0,s4,344
    80001f6c:	e1bfe0ef          	jal	ra,80000d86 <safestrcpy>
  pid = np->pid;
    80001f70:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001f74:	8552                	mv	a0,s4
    80001f76:	c8ffe0ef          	jal	ra,80000c04 <release>
  acquire(&wait_lock);
    80001f7a:	0000e497          	auipc	s1,0xe
    80001f7e:	cb648493          	addi	s1,s1,-842 # 8000fc30 <wait_lock>
    80001f82:	8526                	mv	a0,s1
    80001f84:	be9fe0ef          	jal	ra,80000b6c <acquire>
  np->parent = p;
    80001f88:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001f8c:	8526                	mv	a0,s1
    80001f8e:	c77fe0ef          	jal	ra,80000c04 <release>
  acquire(&np->lock);
    80001f92:	8552                	mv	a0,s4
    80001f94:	bd9fe0ef          	jal	ra,80000b6c <acquire>
  np->state = RUNNABLE;
    80001f98:	478d                	li	a5,3
    80001f9a:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f9e:	8552                	mv	a0,s4
    80001fa0:	c65fe0ef          	jal	ra,80000c04 <release>
}
    80001fa4:	854a                	mv	a0,s2
    80001fa6:	70e2                	ld	ra,56(sp)
    80001fa8:	7442                	ld	s0,48(sp)
    80001faa:	74a2                	ld	s1,40(sp)
    80001fac:	7902                	ld	s2,32(sp)
    80001fae:	69e2                	ld	s3,24(sp)
    80001fb0:	6a42                	ld	s4,16(sp)
    80001fb2:	6aa2                	ld	s5,8(sp)
    80001fb4:	6121                	addi	sp,sp,64
    80001fb6:	8082                	ret
    return -1;
    80001fb8:	597d                	li	s2,-1
    80001fba:	b7ed                	j	80001fa4 <kfork+0xf4>

0000000080001fbc <scheduler>:
{
    80001fbc:	715d                	addi	sp,sp,-80
    80001fbe:	e486                	sd	ra,72(sp)
    80001fc0:	e0a2                	sd	s0,64(sp)
    80001fc2:	fc26                	sd	s1,56(sp)
    80001fc4:	f84a                	sd	s2,48(sp)
    80001fc6:	f44e                	sd	s3,40(sp)
    80001fc8:	f052                	sd	s4,32(sp)
    80001fca:	ec56                	sd	s5,24(sp)
    80001fcc:	e85a                	sd	s6,16(sp)
    80001fce:	e45e                	sd	s7,8(sp)
    80001fd0:	e062                	sd	s8,0(sp)
    80001fd2:	0880                	addi	s0,sp,80
    80001fd4:	8792                	mv	a5,tp
  int id = r_tp();
    80001fd6:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001fd8:	00779b13          	slli	s6,a5,0x7
    80001fdc:	0000e717          	auipc	a4,0xe
    80001fe0:	c3c70713          	addi	a4,a4,-964 # 8000fc18 <pid_lock>
    80001fe4:	975a                	add	a4,a4,s6
    80001fe6:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001fea:	0000e717          	auipc	a4,0xe
    80001fee:	c6670713          	addi	a4,a4,-922 # 8000fc50 <cpus+0x8>
    80001ff2:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001ff4:	4c11                	li	s8,4
        c->proc = p;
    80001ff6:	079e                	slli	a5,a5,0x7
    80001ff8:	0000ea17          	auipc	s4,0xe
    80001ffc:	c20a0a13          	addi	s4,s4,-992 # 8000fc18 <pid_lock>
    80002000:	9a3e                	add	s4,s4,a5
        found = 1;
    80002002:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80002004:	00015997          	auipc	s3,0x15
    80002008:	04498993          	addi	s3,s3,68 # 80017048 <tickslock>
    8000200c:	a83d                	j	8000204a <scheduler+0x8e>
      release(&p->lock);
    8000200e:	8526                	mv	a0,s1
    80002010:	bf5fe0ef          	jal	ra,80000c04 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002014:	1c048493          	addi	s1,s1,448
    80002018:	03348563          	beq	s1,s3,80002042 <scheduler+0x86>
      acquire(&p->lock);
    8000201c:	8526                	mv	a0,s1
    8000201e:	b4ffe0ef          	jal	ra,80000b6c <acquire>
      if(p->state == RUNNABLE) {
    80002022:	4c9c                	lw	a5,24(s1)
    80002024:	ff2795e3          	bne	a5,s2,8000200e <scheduler+0x52>
        p->state = RUNNING;
    80002028:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    8000202c:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80002030:	06048593          	addi	a1,s1,96
    80002034:	855a                	mv	a0,s6
    80002036:	5b0000ef          	jal	ra,800025e6 <swtch>
        c->proc = 0;
    8000203a:	020a3823          	sd	zero,48(s4)
        found = 1;
    8000203e:	8ade                	mv	s5,s7
    80002040:	b7f9                	j	8000200e <scheduler+0x52>
    if(found == 0) {
    80002042:	000a9463          	bnez	s5,8000204a <scheduler+0x8e>
      asm volatile("wfi");
    80002046:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000204a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000204e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002052:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002056:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000205a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000205c:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002060:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002062:	0000e497          	auipc	s1,0xe
    80002066:	fe648493          	addi	s1,s1,-26 # 80010048 <proc>
      if(p->state == RUNNABLE) {
    8000206a:	490d                	li	s2,3
    8000206c:	bf45                	j	8000201c <scheduler+0x60>

000000008000206e <sched>:
{
    8000206e:	7179                	addi	sp,sp,-48
    80002070:	f406                	sd	ra,40(sp)
    80002072:	f022                	sd	s0,32(sp)
    80002074:	ec26                	sd	s1,24(sp)
    80002076:	e84a                	sd	s2,16(sp)
    80002078:	e44e                	sd	s3,8(sp)
    8000207a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000207c:	ab7ff0ef          	jal	ra,80001b32 <myproc>
    80002080:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002082:	a81fe0ef          	jal	ra,80000b02 <holding>
    80002086:	c92d                	beqz	a0,800020f8 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002088:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000208a:	2781                	sext.w	a5,a5
    8000208c:	079e                	slli	a5,a5,0x7
    8000208e:	0000e717          	auipc	a4,0xe
    80002092:	b8a70713          	addi	a4,a4,-1142 # 8000fc18 <pid_lock>
    80002096:	97ba                	add	a5,a5,a4
    80002098:	0a87a703          	lw	a4,168(a5)
    8000209c:	4785                	li	a5,1
    8000209e:	06f71363          	bne	a4,a5,80002104 <sched+0x96>
  if(p->state == RUNNING)
    800020a2:	4c98                	lw	a4,24(s1)
    800020a4:	4791                	li	a5,4
    800020a6:	06f70563          	beq	a4,a5,80002110 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020aa:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020ae:	8b89                	andi	a5,a5,2
  if(intr_get())
    800020b0:	e7b5                	bnez	a5,8000211c <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020b2:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020b4:	0000e917          	auipc	s2,0xe
    800020b8:	b6490913          	addi	s2,s2,-1180 # 8000fc18 <pid_lock>
    800020bc:	2781                	sext.w	a5,a5
    800020be:	079e                	slli	a5,a5,0x7
    800020c0:	97ca                	add	a5,a5,s2
    800020c2:	0ac7a983          	lw	s3,172(a5)
    800020c6:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020c8:	2781                	sext.w	a5,a5
    800020ca:	079e                	slli	a5,a5,0x7
    800020cc:	0000e597          	auipc	a1,0xe
    800020d0:	b8458593          	addi	a1,a1,-1148 # 8000fc50 <cpus+0x8>
    800020d4:	95be                	add	a1,a1,a5
    800020d6:	06048513          	addi	a0,s1,96
    800020da:	50c000ef          	jal	ra,800025e6 <swtch>
    800020de:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020e0:	2781                	sext.w	a5,a5
    800020e2:	079e                	slli	a5,a5,0x7
    800020e4:	97ca                	add	a5,a5,s2
    800020e6:	0b37a623          	sw	s3,172(a5)
}
    800020ea:	70a2                	ld	ra,40(sp)
    800020ec:	7402                	ld	s0,32(sp)
    800020ee:	64e2                	ld	s1,24(sp)
    800020f0:	6942                	ld	s2,16(sp)
    800020f2:	69a2                	ld	s3,8(sp)
    800020f4:	6145                	addi	sp,sp,48
    800020f6:	8082                	ret
    panic("sched p->lock");
    800020f8:	00005517          	auipc	a0,0x5
    800020fc:	2a050513          	addi	a0,a0,672 # 80007398 <digits+0x360>
    80002100:	e8afe0ef          	jal	ra,8000078a <panic>
    panic("sched locks");
    80002104:	00005517          	auipc	a0,0x5
    80002108:	2a450513          	addi	a0,a0,676 # 800073a8 <digits+0x370>
    8000210c:	e7efe0ef          	jal	ra,8000078a <panic>
    panic("sched RUNNING");
    80002110:	00005517          	auipc	a0,0x5
    80002114:	2a850513          	addi	a0,a0,680 # 800073b8 <digits+0x380>
    80002118:	e72fe0ef          	jal	ra,8000078a <panic>
    panic("sched interruptible");
    8000211c:	00005517          	auipc	a0,0x5
    80002120:	2ac50513          	addi	a0,a0,684 # 800073c8 <digits+0x390>
    80002124:	e66fe0ef          	jal	ra,8000078a <panic>

0000000080002128 <yield>:
{
    80002128:	1101                	addi	sp,sp,-32
    8000212a:	ec06                	sd	ra,24(sp)
    8000212c:	e822                	sd	s0,16(sp)
    8000212e:	e426                	sd	s1,8(sp)
    80002130:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002132:	a01ff0ef          	jal	ra,80001b32 <myproc>
    80002136:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002138:	a35fe0ef          	jal	ra,80000b6c <acquire>
  p->state = RUNNABLE;
    8000213c:	478d                	li	a5,3
    8000213e:	cc9c                	sw	a5,24(s1)
  sched();
    80002140:	f2fff0ef          	jal	ra,8000206e <sched>
  release(&p->lock);
    80002144:	8526                	mv	a0,s1
    80002146:	abffe0ef          	jal	ra,80000c04 <release>
}
    8000214a:	60e2                	ld	ra,24(sp)
    8000214c:	6442                	ld	s0,16(sp)
    8000214e:	64a2                	ld	s1,8(sp)
    80002150:	6105                	addi	sp,sp,32
    80002152:	8082                	ret

0000000080002154 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002154:	7179                	addi	sp,sp,-48
    80002156:	f406                	sd	ra,40(sp)
    80002158:	f022                	sd	s0,32(sp)
    8000215a:	ec26                	sd	s1,24(sp)
    8000215c:	e84a                	sd	s2,16(sp)
    8000215e:	e44e                	sd	s3,8(sp)
    80002160:	1800                	addi	s0,sp,48
    80002162:	89aa                	mv	s3,a0
    80002164:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002166:	9cdff0ef          	jal	ra,80001b32 <myproc>
    8000216a:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000216c:	a01fe0ef          	jal	ra,80000b6c <acquire>
  release(lk);
    80002170:	854a                	mv	a0,s2
    80002172:	a93fe0ef          	jal	ra,80000c04 <release>

  // Go to sleep.
  p->chan = chan;
    80002176:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000217a:	4789                	li	a5,2
    8000217c:	cc9c                	sw	a5,24(s1)

  sched();
    8000217e:	ef1ff0ef          	jal	ra,8000206e <sched>

  // Tidy up.
  p->chan = 0;
    80002182:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002186:	8526                	mv	a0,s1
    80002188:	a7dfe0ef          	jal	ra,80000c04 <release>
  acquire(lk);
    8000218c:	854a                	mv	a0,s2
    8000218e:	9dffe0ef          	jal	ra,80000b6c <acquire>
}
    80002192:	70a2                	ld	ra,40(sp)
    80002194:	7402                	ld	s0,32(sp)
    80002196:	64e2                	ld	s1,24(sp)
    80002198:	6942                	ld	s2,16(sp)
    8000219a:	69a2                	ld	s3,8(sp)
    8000219c:	6145                	addi	sp,sp,48
    8000219e:	8082                	ret

00000000800021a0 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    800021a0:	7139                	addi	sp,sp,-64
    800021a2:	fc06                	sd	ra,56(sp)
    800021a4:	f822                	sd	s0,48(sp)
    800021a6:	f426                	sd	s1,40(sp)
    800021a8:	f04a                	sd	s2,32(sp)
    800021aa:	ec4e                	sd	s3,24(sp)
    800021ac:	e852                	sd	s4,16(sp)
    800021ae:	e456                	sd	s5,8(sp)
    800021b0:	0080                	addi	s0,sp,64
    800021b2:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800021b4:	0000e497          	auipc	s1,0xe
    800021b8:	e9448493          	addi	s1,s1,-364 # 80010048 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800021bc:	4989                	li	s3,2
        p->state = RUNNABLE;
    800021be:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800021c0:	00015917          	auipc	s2,0x15
    800021c4:	e8890913          	addi	s2,s2,-376 # 80017048 <tickslock>
    800021c8:	a801                	j	800021d8 <wakeup+0x38>
      }
      release(&p->lock);
    800021ca:	8526                	mv	a0,s1
    800021cc:	a39fe0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800021d0:	1c048493          	addi	s1,s1,448
    800021d4:	03248263          	beq	s1,s2,800021f8 <wakeup+0x58>
    if(p != myproc()){
    800021d8:	95bff0ef          	jal	ra,80001b32 <myproc>
    800021dc:	fea48ae3          	beq	s1,a0,800021d0 <wakeup+0x30>
      acquire(&p->lock);
    800021e0:	8526                	mv	a0,s1
    800021e2:	98bfe0ef          	jal	ra,80000b6c <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800021e6:	4c9c                	lw	a5,24(s1)
    800021e8:	ff3791e3          	bne	a5,s3,800021ca <wakeup+0x2a>
    800021ec:	709c                	ld	a5,32(s1)
    800021ee:	fd479ee3          	bne	a5,s4,800021ca <wakeup+0x2a>
        p->state = RUNNABLE;
    800021f2:	0154ac23          	sw	s5,24(s1)
    800021f6:	bfd1                	j	800021ca <wakeup+0x2a>
    }
  }
}
    800021f8:	70e2                	ld	ra,56(sp)
    800021fa:	7442                	ld	s0,48(sp)
    800021fc:	74a2                	ld	s1,40(sp)
    800021fe:	7902                	ld	s2,32(sp)
    80002200:	69e2                	ld	s3,24(sp)
    80002202:	6a42                	ld	s4,16(sp)
    80002204:	6aa2                	ld	s5,8(sp)
    80002206:	6121                	addi	sp,sp,64
    80002208:	8082                	ret

000000008000220a <reparent>:
{
    8000220a:	7179                	addi	sp,sp,-48
    8000220c:	f406                	sd	ra,40(sp)
    8000220e:	f022                	sd	s0,32(sp)
    80002210:	ec26                	sd	s1,24(sp)
    80002212:	e84a                	sd	s2,16(sp)
    80002214:	e44e                	sd	s3,8(sp)
    80002216:	e052                	sd	s4,0(sp)
    80002218:	1800                	addi	s0,sp,48
    8000221a:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000221c:	0000e497          	auipc	s1,0xe
    80002220:	e2c48493          	addi	s1,s1,-468 # 80010048 <proc>
      pp->parent = initproc;
    80002224:	00006a17          	auipc	s4,0x6
    80002228:	8eca0a13          	addi	s4,s4,-1812 # 80007b10 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000222c:	00015997          	auipc	s3,0x15
    80002230:	e1c98993          	addi	s3,s3,-484 # 80017048 <tickslock>
    80002234:	a029                	j	8000223e <reparent+0x34>
    80002236:	1c048493          	addi	s1,s1,448
    8000223a:	01348b63          	beq	s1,s3,80002250 <reparent+0x46>
    if(pp->parent == p){
    8000223e:	7c9c                	ld	a5,56(s1)
    80002240:	ff279be3          	bne	a5,s2,80002236 <reparent+0x2c>
      pp->parent = initproc;
    80002244:	000a3503          	ld	a0,0(s4)
    80002248:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000224a:	f57ff0ef          	jal	ra,800021a0 <wakeup>
    8000224e:	b7e5                	j	80002236 <reparent+0x2c>
}
    80002250:	70a2                	ld	ra,40(sp)
    80002252:	7402                	ld	s0,32(sp)
    80002254:	64e2                	ld	s1,24(sp)
    80002256:	6942                	ld	s2,16(sp)
    80002258:	69a2                	ld	s3,8(sp)
    8000225a:	6a02                	ld	s4,0(sp)
    8000225c:	6145                	addi	sp,sp,48
    8000225e:	8082                	ret

0000000080002260 <kexit>:
{
    80002260:	7179                	addi	sp,sp,-48
    80002262:	f406                	sd	ra,40(sp)
    80002264:	f022                	sd	s0,32(sp)
    80002266:	ec26                	sd	s1,24(sp)
    80002268:	e84a                	sd	s2,16(sp)
    8000226a:	e44e                	sd	s3,8(sp)
    8000226c:	e052                	sd	s4,0(sp)
    8000226e:	1800                	addi	s0,sp,48
    80002270:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002272:	8c1ff0ef          	jal	ra,80001b32 <myproc>
    80002276:	89aa                	mv	s3,a0
  if(p == initproc)
    80002278:	00006797          	auipc	a5,0x6
    8000227c:	8987b783          	ld	a5,-1896(a5) # 80007b10 <initproc>
    80002280:	0d050493          	addi	s1,a0,208
    80002284:	15050913          	addi	s2,a0,336
    80002288:	00a79f63          	bne	a5,a0,800022a6 <kexit+0x46>
    panic("init exiting");
    8000228c:	00005517          	auipc	a0,0x5
    80002290:	15450513          	addi	a0,a0,340 # 800073e0 <digits+0x3a8>
    80002294:	cf6fe0ef          	jal	ra,8000078a <panic>
      fileclose(f);
    80002298:	789010ef          	jal	ra,80004220 <fileclose>
      p->ofile[fd] = 0;
    8000229c:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800022a0:	04a1                	addi	s1,s1,8
    800022a2:	01248563          	beq	s1,s2,800022ac <kexit+0x4c>
    if(p->ofile[fd]){
    800022a6:	6088                	ld	a0,0(s1)
    800022a8:	f965                	bnez	a0,80002298 <kexit+0x38>
    800022aa:	bfdd                	j	800022a0 <kexit+0x40>
  begin_op();
    800022ac:	367010ef          	jal	ra,80003e12 <begin_op>
  iput(p->cwd);
    800022b0:	1509b503          	ld	a0,336(s3)
    800022b4:	2fe010ef          	jal	ra,800035b2 <iput>
  end_op();
    800022b8:	3cb010ef          	jal	ra,80003e82 <end_op>
  p->cwd = 0;
    800022bc:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800022c0:	0000e497          	auipc	s1,0xe
    800022c4:	97048493          	addi	s1,s1,-1680 # 8000fc30 <wait_lock>
    800022c8:	8526                	mv	a0,s1
    800022ca:	8a3fe0ef          	jal	ra,80000b6c <acquire>
  reparent(p);
    800022ce:	854e                	mv	a0,s3
    800022d0:	f3bff0ef          	jal	ra,8000220a <reparent>
  wakeup(p->parent);
    800022d4:	0389b503          	ld	a0,56(s3)
    800022d8:	ec9ff0ef          	jal	ra,800021a0 <wakeup>
  acquire(&p->lock);
    800022dc:	854e                	mv	a0,s3
    800022de:	88ffe0ef          	jal	ra,80000b6c <acquire>
  p->xstate = status;
    800022e2:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022e6:	4795                	li	a5,5
    800022e8:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800022ec:	8526                	mv	a0,s1
    800022ee:	917fe0ef          	jal	ra,80000c04 <release>
  sched();
    800022f2:	d7dff0ef          	jal	ra,8000206e <sched>
  panic("zombie exit");
    800022f6:	00005517          	auipc	a0,0x5
    800022fa:	0fa50513          	addi	a0,a0,250 # 800073f0 <digits+0x3b8>
    800022fe:	c8cfe0ef          	jal	ra,8000078a <panic>

0000000080002302 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002302:	7179                	addi	sp,sp,-48
    80002304:	f406                	sd	ra,40(sp)
    80002306:	f022                	sd	s0,32(sp)
    80002308:	ec26                	sd	s1,24(sp)
    8000230a:	e84a                	sd	s2,16(sp)
    8000230c:	e44e                	sd	s3,8(sp)
    8000230e:	1800                	addi	s0,sp,48
    80002310:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002312:	0000e497          	auipc	s1,0xe
    80002316:	d3648493          	addi	s1,s1,-714 # 80010048 <proc>
    8000231a:	00015997          	auipc	s3,0x15
    8000231e:	d2e98993          	addi	s3,s3,-722 # 80017048 <tickslock>
    acquire(&p->lock);
    80002322:	8526                	mv	a0,s1
    80002324:	849fe0ef          	jal	ra,80000b6c <acquire>
    if(p->pid == pid){
    80002328:	589c                	lw	a5,48(s1)
    8000232a:	01278b63          	beq	a5,s2,80002340 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000232e:	8526                	mv	a0,s1
    80002330:	8d5fe0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002334:	1c048493          	addi	s1,s1,448
    80002338:	ff3495e3          	bne	s1,s3,80002322 <kkill+0x20>
  }
  return -1;
    8000233c:	557d                	li	a0,-1
    8000233e:	a819                	j	80002354 <kkill+0x52>
      p->killed = 1;
    80002340:	4785                	li	a5,1
    80002342:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002344:	4c98                	lw	a4,24(s1)
    80002346:	4789                	li	a5,2
    80002348:	00f70d63          	beq	a4,a5,80002362 <kkill+0x60>
      release(&p->lock);
    8000234c:	8526                	mv	a0,s1
    8000234e:	8b7fe0ef          	jal	ra,80000c04 <release>
      return 0;
    80002352:	4501                	li	a0,0
}
    80002354:	70a2                	ld	ra,40(sp)
    80002356:	7402                	ld	s0,32(sp)
    80002358:	64e2                	ld	s1,24(sp)
    8000235a:	6942                	ld	s2,16(sp)
    8000235c:	69a2                	ld	s3,8(sp)
    8000235e:	6145                	addi	sp,sp,48
    80002360:	8082                	ret
        p->state = RUNNABLE;
    80002362:	478d                	li	a5,3
    80002364:	cc9c                	sw	a5,24(s1)
    80002366:	b7dd                	j	8000234c <kkill+0x4a>

0000000080002368 <setkilled>:

void
setkilled(struct proc *p)
{
    80002368:	1101                	addi	sp,sp,-32
    8000236a:	ec06                	sd	ra,24(sp)
    8000236c:	e822                	sd	s0,16(sp)
    8000236e:	e426                	sd	s1,8(sp)
    80002370:	1000                	addi	s0,sp,32
    80002372:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002374:	ff8fe0ef          	jal	ra,80000b6c <acquire>
  p->killed = 1;
    80002378:	4785                	li	a5,1
    8000237a:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000237c:	8526                	mv	a0,s1
    8000237e:	887fe0ef          	jal	ra,80000c04 <release>
}
    80002382:	60e2                	ld	ra,24(sp)
    80002384:	6442                	ld	s0,16(sp)
    80002386:	64a2                	ld	s1,8(sp)
    80002388:	6105                	addi	sp,sp,32
    8000238a:	8082                	ret

000000008000238c <killed>:

int
killed(struct proc *p)
{
    8000238c:	1101                	addi	sp,sp,-32
    8000238e:	ec06                	sd	ra,24(sp)
    80002390:	e822                	sd	s0,16(sp)
    80002392:	e426                	sd	s1,8(sp)
    80002394:	e04a                	sd	s2,0(sp)
    80002396:	1000                	addi	s0,sp,32
    80002398:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000239a:	fd2fe0ef          	jal	ra,80000b6c <acquire>
  k = p->killed;
    8000239e:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800023a2:	8526                	mv	a0,s1
    800023a4:	861fe0ef          	jal	ra,80000c04 <release>
  return k;
}
    800023a8:	854a                	mv	a0,s2
    800023aa:	60e2                	ld	ra,24(sp)
    800023ac:	6442                	ld	s0,16(sp)
    800023ae:	64a2                	ld	s1,8(sp)
    800023b0:	6902                	ld	s2,0(sp)
    800023b2:	6105                	addi	sp,sp,32
    800023b4:	8082                	ret

00000000800023b6 <kwait>:
{
    800023b6:	715d                	addi	sp,sp,-80
    800023b8:	e486                	sd	ra,72(sp)
    800023ba:	e0a2                	sd	s0,64(sp)
    800023bc:	fc26                	sd	s1,56(sp)
    800023be:	f84a                	sd	s2,48(sp)
    800023c0:	f44e                	sd	s3,40(sp)
    800023c2:	f052                	sd	s4,32(sp)
    800023c4:	ec56                	sd	s5,24(sp)
    800023c6:	e85a                	sd	s6,16(sp)
    800023c8:	e45e                	sd	s7,8(sp)
    800023ca:	e062                	sd	s8,0(sp)
    800023cc:	0880                	addi	s0,sp,80
    800023ce:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023d0:	f62ff0ef          	jal	ra,80001b32 <myproc>
    800023d4:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023d6:	0000e517          	auipc	a0,0xe
    800023da:	85a50513          	addi	a0,a0,-1958 # 8000fc30 <wait_lock>
    800023de:	f8efe0ef          	jal	ra,80000b6c <acquire>
    havekids = 0;
    800023e2:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800023e4:	4a15                	li	s4,5
        havekids = 1;
    800023e6:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023e8:	00015997          	auipc	s3,0x15
    800023ec:	c6098993          	addi	s3,s3,-928 # 80017048 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023f0:	0000ec17          	auipc	s8,0xe
    800023f4:	840c0c13          	addi	s8,s8,-1984 # 8000fc30 <wait_lock>
    havekids = 0;
    800023f8:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023fa:	0000e497          	auipc	s1,0xe
    800023fe:	c4e48493          	addi	s1,s1,-946 # 80010048 <proc>
    80002402:	a899                	j	80002458 <kwait+0xa2>
          pid = pp->pid;
    80002404:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002408:	000b0c63          	beqz	s6,80002420 <kwait+0x6a>
    8000240c:	4691                	li	a3,4
    8000240e:	02c48613          	addi	a2,s1,44
    80002412:	85da                	mv	a1,s6
    80002414:	05093503          	ld	a0,80(s2)
    80002418:	c68ff0ef          	jal	ra,80001880 <copyout>
    8000241c:	00054f63          	bltz	a0,8000243a <kwait+0x84>
          freeproc(pp);
    80002420:	8526                	mv	a0,s1
    80002422:	8e1ff0ef          	jal	ra,80001d02 <freeproc>
          release(&pp->lock);
    80002426:	8526                	mv	a0,s1
    80002428:	fdcfe0ef          	jal	ra,80000c04 <release>
          release(&wait_lock);
    8000242c:	0000e517          	auipc	a0,0xe
    80002430:	80450513          	addi	a0,a0,-2044 # 8000fc30 <wait_lock>
    80002434:	fd0fe0ef          	jal	ra,80000c04 <release>
          return pid;
    80002438:	a891                	j	8000248c <kwait+0xd6>
            release(&pp->lock);
    8000243a:	8526                	mv	a0,s1
    8000243c:	fc8fe0ef          	jal	ra,80000c04 <release>
            release(&wait_lock);
    80002440:	0000d517          	auipc	a0,0xd
    80002444:	7f050513          	addi	a0,a0,2032 # 8000fc30 <wait_lock>
    80002448:	fbcfe0ef          	jal	ra,80000c04 <release>
            return -1;
    8000244c:	59fd                	li	s3,-1
    8000244e:	a83d                	j	8000248c <kwait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002450:	1c048493          	addi	s1,s1,448
    80002454:	03348063          	beq	s1,s3,80002474 <kwait+0xbe>
      if(pp->parent == p){
    80002458:	7c9c                	ld	a5,56(s1)
    8000245a:	ff279be3          	bne	a5,s2,80002450 <kwait+0x9a>
        acquire(&pp->lock);
    8000245e:	8526                	mv	a0,s1
    80002460:	f0cfe0ef          	jal	ra,80000b6c <acquire>
        if(pp->state == ZOMBIE){
    80002464:	4c9c                	lw	a5,24(s1)
    80002466:	f9478fe3          	beq	a5,s4,80002404 <kwait+0x4e>
        release(&pp->lock);
    8000246a:	8526                	mv	a0,s1
    8000246c:	f98fe0ef          	jal	ra,80000c04 <release>
        havekids = 1;
    80002470:	8756                	mv	a4,s5
    80002472:	bff9                	j	80002450 <kwait+0x9a>
    if(!havekids || killed(p)){
    80002474:	c709                	beqz	a4,8000247e <kwait+0xc8>
    80002476:	854a                	mv	a0,s2
    80002478:	f15ff0ef          	jal	ra,8000238c <killed>
    8000247c:	c50d                	beqz	a0,800024a6 <kwait+0xf0>
      release(&wait_lock);
    8000247e:	0000d517          	auipc	a0,0xd
    80002482:	7b250513          	addi	a0,a0,1970 # 8000fc30 <wait_lock>
    80002486:	f7efe0ef          	jal	ra,80000c04 <release>
      return -1;
    8000248a:	59fd                	li	s3,-1
}
    8000248c:	854e                	mv	a0,s3
    8000248e:	60a6                	ld	ra,72(sp)
    80002490:	6406                	ld	s0,64(sp)
    80002492:	74e2                	ld	s1,56(sp)
    80002494:	7942                	ld	s2,48(sp)
    80002496:	79a2                	ld	s3,40(sp)
    80002498:	7a02                	ld	s4,32(sp)
    8000249a:	6ae2                	ld	s5,24(sp)
    8000249c:	6b42                	ld	s6,16(sp)
    8000249e:	6ba2                	ld	s7,8(sp)
    800024a0:	6c02                	ld	s8,0(sp)
    800024a2:	6161                	addi	sp,sp,80
    800024a4:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024a6:	85e2                	mv	a1,s8
    800024a8:	854a                	mv	a0,s2
    800024aa:	cabff0ef          	jal	ra,80002154 <sleep>
    havekids = 0;
    800024ae:	b7a9                	j	800023f8 <kwait+0x42>

00000000800024b0 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024b0:	7179                	addi	sp,sp,-48
    800024b2:	f406                	sd	ra,40(sp)
    800024b4:	f022                	sd	s0,32(sp)
    800024b6:	ec26                	sd	s1,24(sp)
    800024b8:	e84a                	sd	s2,16(sp)
    800024ba:	e44e                	sd	s3,8(sp)
    800024bc:	e052                	sd	s4,0(sp)
    800024be:	1800                	addi	s0,sp,48
    800024c0:	84aa                	mv	s1,a0
    800024c2:	892e                	mv	s2,a1
    800024c4:	89b2                	mv	s3,a2
    800024c6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024c8:	e6aff0ef          	jal	ra,80001b32 <myproc>
  if(user_dst){
    800024cc:	cc99                	beqz	s1,800024ea <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800024ce:	86d2                	mv	a3,s4
    800024d0:	864e                	mv	a2,s3
    800024d2:	85ca                	mv	a1,s2
    800024d4:	6928                	ld	a0,80(a0)
    800024d6:	baaff0ef          	jal	ra,80001880 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024da:	70a2                	ld	ra,40(sp)
    800024dc:	7402                	ld	s0,32(sp)
    800024de:	64e2                	ld	s1,24(sp)
    800024e0:	6942                	ld	s2,16(sp)
    800024e2:	69a2                	ld	s3,8(sp)
    800024e4:	6a02                	ld	s4,0(sp)
    800024e6:	6145                	addi	sp,sp,48
    800024e8:	8082                	ret
    memmove((char *)dst, src, len);
    800024ea:	000a061b          	sext.w	a2,s4
    800024ee:	85ce                	mv	a1,s3
    800024f0:	854a                	mv	a0,s2
    800024f2:	faafe0ef          	jal	ra,80000c9c <memmove>
    return 0;
    800024f6:	8526                	mv	a0,s1
    800024f8:	b7cd                	j	800024da <either_copyout+0x2a>

00000000800024fa <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024fa:	7179                	addi	sp,sp,-48
    800024fc:	f406                	sd	ra,40(sp)
    800024fe:	f022                	sd	s0,32(sp)
    80002500:	ec26                	sd	s1,24(sp)
    80002502:	e84a                	sd	s2,16(sp)
    80002504:	e44e                	sd	s3,8(sp)
    80002506:	e052                	sd	s4,0(sp)
    80002508:	1800                	addi	s0,sp,48
    8000250a:	892a                	mv	s2,a0
    8000250c:	84ae                	mv	s1,a1
    8000250e:	89b2                	mv	s3,a2
    80002510:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002512:	e20ff0ef          	jal	ra,80001b32 <myproc>
  if(user_src){
    80002516:	cc99                	beqz	s1,80002534 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002518:	86d2                	mv	a3,s4
    8000251a:	864e                	mv	a2,s3
    8000251c:	85ca                	mv	a1,s2
    8000251e:	6928                	ld	a0,80(a0)
    80002520:	c26ff0ef          	jal	ra,80001946 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002524:	70a2                	ld	ra,40(sp)
    80002526:	7402                	ld	s0,32(sp)
    80002528:	64e2                	ld	s1,24(sp)
    8000252a:	6942                	ld	s2,16(sp)
    8000252c:	69a2                	ld	s3,8(sp)
    8000252e:	6a02                	ld	s4,0(sp)
    80002530:	6145                	addi	sp,sp,48
    80002532:	8082                	ret
    memmove(dst, (char*)src, len);
    80002534:	000a061b          	sext.w	a2,s4
    80002538:	85ce                	mv	a1,s3
    8000253a:	854a                	mv	a0,s2
    8000253c:	f60fe0ef          	jal	ra,80000c9c <memmove>
    return 0;
    80002540:	8526                	mv	a0,s1
    80002542:	b7cd                	j	80002524 <either_copyin+0x2a>

0000000080002544 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002544:	715d                	addi	sp,sp,-80
    80002546:	e486                	sd	ra,72(sp)
    80002548:	e0a2                	sd	s0,64(sp)
    8000254a:	fc26                	sd	s1,56(sp)
    8000254c:	f84a                	sd	s2,48(sp)
    8000254e:	f44e                	sd	s3,40(sp)
    80002550:	f052                	sd	s4,32(sp)
    80002552:	ec56                	sd	s5,24(sp)
    80002554:	e85a                	sd	s6,16(sp)
    80002556:	e45e                	sd	s7,8(sp)
    80002558:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000255a:	00005517          	auipc	a0,0x5
    8000255e:	cae50513          	addi	a0,a0,-850 # 80007208 <digits+0x1d0>
    80002562:	f63fd0ef          	jal	ra,800004c4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002566:	0000e497          	auipc	s1,0xe
    8000256a:	c3a48493          	addi	s1,s1,-966 # 800101a0 <proc+0x158>
    8000256e:	00015917          	auipc	s2,0x15
    80002572:	c3290913          	addi	s2,s2,-974 # 800171a0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002576:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002578:	00005997          	auipc	s3,0x5
    8000257c:	e8898993          	addi	s3,s3,-376 # 80007400 <digits+0x3c8>
    printf("%d %s %s", p->pid, state, p->name);
    80002580:	00005a97          	auipc	s5,0x5
    80002584:	e88a8a93          	addi	s5,s5,-376 # 80007408 <digits+0x3d0>
    printf("\n");
    80002588:	00005a17          	auipc	s4,0x5
    8000258c:	c80a0a13          	addi	s4,s4,-896 # 80007208 <digits+0x1d0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002590:	00005b97          	auipc	s7,0x5
    80002594:	eb8b8b93          	addi	s7,s7,-328 # 80007448 <states.0>
    80002598:	a829                	j	800025b2 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000259a:	ed86a583          	lw	a1,-296(a3)
    8000259e:	8556                	mv	a0,s5
    800025a0:	f25fd0ef          	jal	ra,800004c4 <printf>
    printf("\n");
    800025a4:	8552                	mv	a0,s4
    800025a6:	f1ffd0ef          	jal	ra,800004c4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025aa:	1c048493          	addi	s1,s1,448
    800025ae:	03248163          	beq	s1,s2,800025d0 <procdump+0x8c>
    if(p->state == UNUSED)
    800025b2:	86a6                	mv	a3,s1
    800025b4:	ec04a783          	lw	a5,-320(s1)
    800025b8:	dbed                	beqz	a5,800025aa <procdump+0x66>
      state = "???";
    800025ba:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025bc:	fcfb6fe3          	bltu	s6,a5,8000259a <procdump+0x56>
    800025c0:	1782                	slli	a5,a5,0x20
    800025c2:	9381                	srli	a5,a5,0x20
    800025c4:	078e                	slli	a5,a5,0x3
    800025c6:	97de                	add	a5,a5,s7
    800025c8:	6390                	ld	a2,0(a5)
    800025ca:	fa61                	bnez	a2,8000259a <procdump+0x56>
      state = "???";
    800025cc:	864e                	mv	a2,s3
    800025ce:	b7f1                	j	8000259a <procdump+0x56>
  }
}
    800025d0:	60a6                	ld	ra,72(sp)
    800025d2:	6406                	ld	s0,64(sp)
    800025d4:	74e2                	ld	s1,56(sp)
    800025d6:	7942                	ld	s2,48(sp)
    800025d8:	79a2                	ld	s3,40(sp)
    800025da:	7a02                	ld	s4,32(sp)
    800025dc:	6ae2                	ld	s5,24(sp)
    800025de:	6b42                	ld	s6,16(sp)
    800025e0:	6ba2                	ld	s7,8(sp)
    800025e2:	6161                	addi	sp,sp,80
    800025e4:	8082                	ret

00000000800025e6 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800025e6:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800025ea:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800025ee:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800025f0:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800025f2:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800025f6:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800025fa:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800025fe:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002602:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002606:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    8000260a:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    8000260e:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002612:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002616:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    8000261a:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000261e:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002622:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002624:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002626:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    8000262a:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000262e:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002632:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002636:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    8000263a:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000263e:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002642:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002646:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    8000264a:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000264e:	8082                	ret

0000000080002650 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002650:	1141                	addi	sp,sp,-16
    80002652:	e406                	sd	ra,8(sp)
    80002654:	e022                	sd	s0,0(sp)
    80002656:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002658:	00005597          	auipc	a1,0x5
    8000265c:	e2058593          	addi	a1,a1,-480 # 80007478 <states.0+0x30>
    80002660:	00015517          	auipc	a0,0x15
    80002664:	9e850513          	addi	a0,a0,-1560 # 80017048 <tickslock>
    80002668:	c84fe0ef          	jal	ra,80000aec <initlock>
}
    8000266c:	60a2                	ld	ra,8(sp)
    8000266e:	6402                	ld	s0,0(sp)
    80002670:	0141                	addi	sp,sp,16
    80002672:	8082                	ret

0000000080002674 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002674:	1141                	addi	sp,sp,-16
    80002676:	e422                	sd	s0,8(sp)
    80002678:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000267a:	00003797          	auipc	a5,0x3
    8000267e:	df678793          	addi	a5,a5,-522 # 80005470 <kernelvec>
    80002682:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002686:	6422                	ld	s0,8(sp)
    80002688:	0141                	addi	sp,sp,16
    8000268a:	8082                	ret

000000008000268c <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000268c:	1141                	addi	sp,sp,-16
    8000268e:	e406                	sd	ra,8(sp)
    80002690:	e022                	sd	s0,0(sp)
    80002692:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002694:	c9eff0ef          	jal	ra,80001b32 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002698:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000269c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000269e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800026a2:	04000737          	lui	a4,0x4000
    800026a6:	00004797          	auipc	a5,0x4
    800026aa:	95a78793          	addi	a5,a5,-1702 # 80006000 <_trampoline>
    800026ae:	00004697          	auipc	a3,0x4
    800026b2:	95268693          	addi	a3,a3,-1710 # 80006000 <_trampoline>
    800026b6:	8f95                	sub	a5,a5,a3
    800026b8:	177d                	addi	a4,a4,-1
    800026ba:	0732                	slli	a4,a4,0xc
    800026bc:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026be:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026c2:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026c4:	18002773          	csrr	a4,satp
    800026c8:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026ca:	6d38                	ld	a4,88(a0)
    800026cc:	613c                	ld	a5,64(a0)
    800026ce:	6685                	lui	a3,0x1
    800026d0:	97b6                	add	a5,a5,a3
    800026d2:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026d4:	6d3c                	ld	a5,88(a0)
    800026d6:	00000717          	auipc	a4,0x0
    800026da:	0f470713          	addi	a4,a4,244 # 800027ca <usertrap>
    800026de:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026e0:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026e2:	8712                	mv	a4,tp
    800026e4:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026e6:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026ea:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026ee:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026f2:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026f6:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026f8:	6f9c                	ld	a5,24(a5)
    800026fa:	14179073          	csrw	sepc,a5
}
    800026fe:	60a2                	ld	ra,8(sp)
    80002700:	6402                	ld	s0,0(sp)
    80002702:	0141                	addi	sp,sp,16
    80002704:	8082                	ret

0000000080002706 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002706:	1101                	addi	sp,sp,-32
    80002708:	ec06                	sd	ra,24(sp)
    8000270a:	e822                	sd	s0,16(sp)
    8000270c:	e426                	sd	s1,8(sp)
    8000270e:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002710:	bf6ff0ef          	jal	ra,80001b06 <cpuid>
    80002714:	cd19                	beqz	a0,80002732 <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002716:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000271a:	000f4737          	lui	a4,0xf4
    8000271e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002722:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002724:	14d79073          	csrw	0x14d,a5
}
    80002728:	60e2                	ld	ra,24(sp)
    8000272a:	6442                	ld	s0,16(sp)
    8000272c:	64a2                	ld	s1,8(sp)
    8000272e:	6105                	addi	sp,sp,32
    80002730:	8082                	ret
    acquire(&tickslock);
    80002732:	00015497          	auipc	s1,0x15
    80002736:	91648493          	addi	s1,s1,-1770 # 80017048 <tickslock>
    8000273a:	8526                	mv	a0,s1
    8000273c:	c30fe0ef          	jal	ra,80000b6c <acquire>
    ticks++;
    80002740:	00005517          	auipc	a0,0x5
    80002744:	3d850513          	addi	a0,a0,984 # 80007b18 <ticks>
    80002748:	411c                	lw	a5,0(a0)
    8000274a:	2785                	addiw	a5,a5,1
    8000274c:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000274e:	a53ff0ef          	jal	ra,800021a0 <wakeup>
    release(&tickslock);
    80002752:	8526                	mv	a0,s1
    80002754:	cb0fe0ef          	jal	ra,80000c04 <release>
    80002758:	bf7d                	j	80002716 <clockintr+0x10>

000000008000275a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000275a:	1101                	addi	sp,sp,-32
    8000275c:	ec06                	sd	ra,24(sp)
    8000275e:	e822                	sd	s0,16(sp)
    80002760:	e426                	sd	s1,8(sp)
    80002762:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002764:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002768:	57fd                	li	a5,-1
    8000276a:	17fe                	slli	a5,a5,0x3f
    8000276c:	07a5                	addi	a5,a5,9
    8000276e:	00f70d63          	beq	a4,a5,80002788 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002772:	57fd                	li	a5,-1
    80002774:	17fe                	slli	a5,a5,0x3f
    80002776:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002778:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    8000277a:	04f70463          	beq	a4,a5,800027c2 <devintr+0x68>
  }
}
    8000277e:	60e2                	ld	ra,24(sp)
    80002780:	6442                	ld	s0,16(sp)
    80002782:	64a2                	ld	s1,8(sp)
    80002784:	6105                	addi	sp,sp,32
    80002786:	8082                	ret
    int irq = plic_claim();
    80002788:	591020ef          	jal	ra,80005518 <plic_claim>
    8000278c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000278e:	47a9                	li	a5,10
    80002790:	02f50363          	beq	a0,a5,800027b6 <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80002794:	4785                	li	a5,1
    80002796:	02f50363          	beq	a0,a5,800027bc <devintr+0x62>
    return 1;
    8000279a:	4505                	li	a0,1
    } else if(irq){
    8000279c:	d0ed                	beqz	s1,8000277e <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    8000279e:	85a6                	mv	a1,s1
    800027a0:	00005517          	auipc	a0,0x5
    800027a4:	ce050513          	addi	a0,a0,-800 # 80007480 <states.0+0x38>
    800027a8:	d1dfd0ef          	jal	ra,800004c4 <printf>
      plic_complete(irq);
    800027ac:	8526                	mv	a0,s1
    800027ae:	58b020ef          	jal	ra,80005538 <plic_complete>
    return 1;
    800027b2:	4505                	li	a0,1
    800027b4:	b7e9                	j	8000277e <devintr+0x24>
      uartintr();
    800027b6:	9a2fe0ef          	jal	ra,80000958 <uartintr>
    800027ba:	bfcd                	j	800027ac <devintr+0x52>
      virtio_disk_intr();
    800027bc:	1ec030ef          	jal	ra,800059a8 <virtio_disk_intr>
    800027c0:	b7f5                	j	800027ac <devintr+0x52>
    clockintr();
    800027c2:	f45ff0ef          	jal	ra,80002706 <clockintr>
    return 2;
    800027c6:	4509                	li	a0,2
    800027c8:	bf5d                	j	8000277e <devintr+0x24>

00000000800027ca <usertrap>:
{
    800027ca:	1101                	addi	sp,sp,-32
    800027cc:	ec06                	sd	ra,24(sp)
    800027ce:	e822                	sd	s0,16(sp)
    800027d0:	e426                	sd	s1,8(sp)
    800027d2:	e04a                	sd	s2,0(sp)
    800027d4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027d6:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800027da:	1007f793          	andi	a5,a5,256
    800027de:	efad                	bnez	a5,80002858 <usertrap+0x8e>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027e0:	00003797          	auipc	a5,0x3
    800027e4:	c9078793          	addi	a5,a5,-880 # 80005470 <kernelvec>
    800027e8:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800027ec:	b46ff0ef          	jal	ra,80001b32 <myproc>
    800027f0:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800027f2:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027f4:	14102773          	csrr	a4,sepc
    800027f8:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027fa:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800027fe:	47a1                	li	a5,8
    80002800:	06f70263          	beq	a4,a5,80002864 <usertrap+0x9a>
  } else if((which_dev = devintr()) != 0){
    80002804:	f57ff0ef          	jal	ra,8000275a <devintr>
    80002808:	892a                	mv	s2,a0
    8000280a:	ed4d                	bnez	a0,800028c4 <usertrap+0xfa>
    8000280c:	14202773          	csrr	a4,scause
  } else if((r_scause() == 12 || r_scause() == 13 || r_scause() == 15) &&
    80002810:	47b1                	li	a5,12
    80002812:	08f70d63          	beq	a4,a5,800028ac <usertrap+0xe2>
    80002816:	14202773          	csrr	a4,scause
    8000281a:	47b5                	li	a5,13
    8000281c:	08f70863          	beq	a4,a5,800028ac <usertrap+0xe2>
    80002820:	14202773          	csrr	a4,scause
    80002824:	47bd                	li	a5,15
    80002826:	08f70363          	beq	a4,a5,800028ac <usertrap+0xe2>
    8000282a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000282e:	5890                	lw	a2,48(s1)
    80002830:	00005517          	auipc	a0,0x5
    80002834:	c9050513          	addi	a0,a0,-880 # 800074c0 <states.0+0x78>
    80002838:	c8dfd0ef          	jal	ra,800004c4 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000283c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002840:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002844:	00005517          	auipc	a0,0x5
    80002848:	cac50513          	addi	a0,a0,-852 # 800074f0 <states.0+0xa8>
    8000284c:	c79fd0ef          	jal	ra,800004c4 <printf>
    setkilled(p);
    80002850:	8526                	mv	a0,s1
    80002852:	b17ff0ef          	jal	ra,80002368 <setkilled>
    80002856:	a035                	j	80002882 <usertrap+0xb8>
    panic("usertrap: not from user mode");
    80002858:	00005517          	auipc	a0,0x5
    8000285c:	c4850513          	addi	a0,a0,-952 # 800074a0 <states.0+0x58>
    80002860:	f2bfd0ef          	jal	ra,8000078a <panic>
    if(killed(p))
    80002864:	b29ff0ef          	jal	ra,8000238c <killed>
    80002868:	ed15                	bnez	a0,800028a4 <usertrap+0xda>
    p->trapframe->epc += 4;
    8000286a:	6cb8                	ld	a4,88(s1)
    8000286c:	6f1c                	ld	a5,24(a4)
    8000286e:	0791                	addi	a5,a5,4
    80002870:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002872:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002876:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000287a:	10079073          	csrw	sstatus,a5
    syscall();
    8000287e:	246000ef          	jal	ra,80002ac4 <syscall>
  if(killed(p))
    80002882:	8526                	mv	a0,s1
    80002884:	b09ff0ef          	jal	ra,8000238c <killed>
    80002888:	e139                	bnez	a0,800028ce <usertrap+0x104>
  prepare_return();
    8000288a:	e03ff0ef          	jal	ra,8000268c <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000288e:	68a8                	ld	a0,80(s1)
    80002890:	8131                	srli	a0,a0,0xc
    80002892:	57fd                	li	a5,-1
    80002894:	17fe                	slli	a5,a5,0x3f
    80002896:	8d5d                	or	a0,a0,a5
}
    80002898:	60e2                	ld	ra,24(sp)
    8000289a:	6442                	ld	s0,16(sp)
    8000289c:	64a2                	ld	s1,8(sp)
    8000289e:	6902                	ld	s2,0(sp)
    800028a0:	6105                	addi	sp,sp,32
    800028a2:	8082                	ret
      kexit(-1);
    800028a4:	557d                	li	a0,-1
    800028a6:	9bbff0ef          	jal	ra,80002260 <kexit>
    800028aa:	b7c1                	j	8000286a <usertrap+0xa0>
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028ac:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028b0:	14202673          	csrr	a2,scause
          vmfault(p->pagetable, r_stval(), (r_scause() == 15)? 1 : 0) != 0) {
    800028b4:	1645                	addi	a2,a2,-15
    800028b6:	00163613          	seqz	a2,a2
    800028ba:	68a8                	ld	a0,80(s1)
    800028bc:	c25fe0ef          	jal	ra,800014e0 <vmfault>
  } else if((r_scause() == 12 || r_scause() == 13 || r_scause() == 15) &&
    800028c0:	f169                	bnez	a0,80002882 <usertrap+0xb8>
    800028c2:	b7a5                	j	8000282a <usertrap+0x60>
  if(killed(p))
    800028c4:	8526                	mv	a0,s1
    800028c6:	ac7ff0ef          	jal	ra,8000238c <killed>
    800028ca:	c511                	beqz	a0,800028d6 <usertrap+0x10c>
    800028cc:	a011                	j	800028d0 <usertrap+0x106>
    800028ce:	4901                	li	s2,0
    kexit(-1);
    800028d0:	557d                	li	a0,-1
    800028d2:	98fff0ef          	jal	ra,80002260 <kexit>
  if(which_dev == 2)
    800028d6:	4789                	li	a5,2
    800028d8:	faf919e3          	bne	s2,a5,8000288a <usertrap+0xc0>
    yield();
    800028dc:	84dff0ef          	jal	ra,80002128 <yield>
    800028e0:	b76d                	j	8000288a <usertrap+0xc0>

00000000800028e2 <kerneltrap>:
{
    800028e2:	7179                	addi	sp,sp,-48
    800028e4:	f406                	sd	ra,40(sp)
    800028e6:	f022                	sd	s0,32(sp)
    800028e8:	ec26                	sd	s1,24(sp)
    800028ea:	e84a                	sd	s2,16(sp)
    800028ec:	e44e                	sd	s3,8(sp)
    800028ee:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028f0:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028f4:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028f8:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800028fc:	1004f793          	andi	a5,s1,256
    80002900:	c795                	beqz	a5,8000292c <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002902:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002906:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002908:	eb85                	bnez	a5,80002938 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    8000290a:	e51ff0ef          	jal	ra,8000275a <devintr>
    8000290e:	c91d                	beqz	a0,80002944 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002910:	4789                	li	a5,2
    80002912:	04f50a63          	beq	a0,a5,80002966 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002916:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000291a:	10049073          	csrw	sstatus,s1
}
    8000291e:	70a2                	ld	ra,40(sp)
    80002920:	7402                	ld	s0,32(sp)
    80002922:	64e2                	ld	s1,24(sp)
    80002924:	6942                	ld	s2,16(sp)
    80002926:	69a2                	ld	s3,8(sp)
    80002928:	6145                	addi	sp,sp,48
    8000292a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000292c:	00005517          	auipc	a0,0x5
    80002930:	bec50513          	addi	a0,a0,-1044 # 80007518 <states.0+0xd0>
    80002934:	e57fd0ef          	jal	ra,8000078a <panic>
    panic("kerneltrap: interrupts enabled");
    80002938:	00005517          	auipc	a0,0x5
    8000293c:	c0850513          	addi	a0,a0,-1016 # 80007540 <states.0+0xf8>
    80002940:	e4bfd0ef          	jal	ra,8000078a <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002944:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002948:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    8000294c:	85ce                	mv	a1,s3
    8000294e:	00005517          	auipc	a0,0x5
    80002952:	c1250513          	addi	a0,a0,-1006 # 80007560 <states.0+0x118>
    80002956:	b6ffd0ef          	jal	ra,800004c4 <printf>
    panic("kerneltrap");
    8000295a:	00005517          	auipc	a0,0x5
    8000295e:	c2e50513          	addi	a0,a0,-978 # 80007588 <states.0+0x140>
    80002962:	e29fd0ef          	jal	ra,8000078a <panic>
  if(which_dev == 2 && myproc() != 0)
    80002966:	9ccff0ef          	jal	ra,80001b32 <myproc>
    8000296a:	d555                	beqz	a0,80002916 <kerneltrap+0x34>
    yield();
    8000296c:	fbcff0ef          	jal	ra,80002128 <yield>
    80002970:	b75d                	j	80002916 <kerneltrap+0x34>

0000000080002972 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002972:	1101                	addi	sp,sp,-32
    80002974:	ec06                	sd	ra,24(sp)
    80002976:	e822                	sd	s0,16(sp)
    80002978:	e426                	sd	s1,8(sp)
    8000297a:	1000                	addi	s0,sp,32
    8000297c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000297e:	9b4ff0ef          	jal	ra,80001b32 <myproc>
  switch (n) {
    80002982:	4795                	li	a5,5
    80002984:	0497e163          	bltu	a5,s1,800029c6 <argraw+0x54>
    80002988:	048a                	slli	s1,s1,0x2
    8000298a:	00005717          	auipc	a4,0x5
    8000298e:	c3670713          	addi	a4,a4,-970 # 800075c0 <states.0+0x178>
    80002992:	94ba                	add	s1,s1,a4
    80002994:	409c                	lw	a5,0(s1)
    80002996:	97ba                	add	a5,a5,a4
    80002998:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000299a:	6d3c                	ld	a5,88(a0)
    8000299c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000299e:	60e2                	ld	ra,24(sp)
    800029a0:	6442                	ld	s0,16(sp)
    800029a2:	64a2                	ld	s1,8(sp)
    800029a4:	6105                	addi	sp,sp,32
    800029a6:	8082                	ret
    return p->trapframe->a1;
    800029a8:	6d3c                	ld	a5,88(a0)
    800029aa:	7fa8                	ld	a0,120(a5)
    800029ac:	bfcd                	j	8000299e <argraw+0x2c>
    return p->trapframe->a2;
    800029ae:	6d3c                	ld	a5,88(a0)
    800029b0:	63c8                	ld	a0,128(a5)
    800029b2:	b7f5                	j	8000299e <argraw+0x2c>
    return p->trapframe->a3;
    800029b4:	6d3c                	ld	a5,88(a0)
    800029b6:	67c8                	ld	a0,136(a5)
    800029b8:	b7dd                	j	8000299e <argraw+0x2c>
    return p->trapframe->a4;
    800029ba:	6d3c                	ld	a5,88(a0)
    800029bc:	6bc8                	ld	a0,144(a5)
    800029be:	b7c5                	j	8000299e <argraw+0x2c>
    return p->trapframe->a5;
    800029c0:	6d3c                	ld	a5,88(a0)
    800029c2:	6fc8                	ld	a0,152(a5)
    800029c4:	bfe9                	j	8000299e <argraw+0x2c>
  panic("argraw");
    800029c6:	00005517          	auipc	a0,0x5
    800029ca:	bd250513          	addi	a0,a0,-1070 # 80007598 <states.0+0x150>
    800029ce:	dbdfd0ef          	jal	ra,8000078a <panic>

00000000800029d2 <fetchaddr>:
{
    800029d2:	1101                	addi	sp,sp,-32
    800029d4:	ec06                	sd	ra,24(sp)
    800029d6:	e822                	sd	s0,16(sp)
    800029d8:	e426                	sd	s1,8(sp)
    800029da:	e04a                	sd	s2,0(sp)
    800029dc:	1000                	addi	s0,sp,32
    800029de:	84aa                	mv	s1,a0
    800029e0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800029e2:	950ff0ef          	jal	ra,80001b32 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800029e6:	653c                	ld	a5,72(a0)
    800029e8:	02f4f663          	bgeu	s1,a5,80002a14 <fetchaddr+0x42>
    800029ec:	00848713          	addi	a4,s1,8
    800029f0:	02e7e463          	bltu	a5,a4,80002a18 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800029f4:	46a1                	li	a3,8
    800029f6:	8626                	mv	a2,s1
    800029f8:	85ca                	mv	a1,s2
    800029fa:	6928                	ld	a0,80(a0)
    800029fc:	f4bfe0ef          	jal	ra,80001946 <copyin>
    80002a00:	00a03533          	snez	a0,a0
    80002a04:	40a00533          	neg	a0,a0
}
    80002a08:	60e2                	ld	ra,24(sp)
    80002a0a:	6442                	ld	s0,16(sp)
    80002a0c:	64a2                	ld	s1,8(sp)
    80002a0e:	6902                	ld	s2,0(sp)
    80002a10:	6105                	addi	sp,sp,32
    80002a12:	8082                	ret
    return -1;
    80002a14:	557d                	li	a0,-1
    80002a16:	bfcd                	j	80002a08 <fetchaddr+0x36>
    80002a18:	557d                	li	a0,-1
    80002a1a:	b7fd                	j	80002a08 <fetchaddr+0x36>

0000000080002a1c <fetchstr>:
{
    80002a1c:	7179                	addi	sp,sp,-48
    80002a1e:	f406                	sd	ra,40(sp)
    80002a20:	f022                	sd	s0,32(sp)
    80002a22:	ec26                	sd	s1,24(sp)
    80002a24:	e84a                	sd	s2,16(sp)
    80002a26:	e44e                	sd	s3,8(sp)
    80002a28:	1800                	addi	s0,sp,48
    80002a2a:	892a                	mv	s2,a0
    80002a2c:	84ae                	mv	s1,a1
    80002a2e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a30:	902ff0ef          	jal	ra,80001b32 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002a34:	86ce                	mv	a3,s3
    80002a36:	864a                	mv	a2,s2
    80002a38:	85a6                	mv	a1,s1
    80002a3a:	6928                	ld	a0,80(a0)
    80002a3c:	9d5fe0ef          	jal	ra,80001410 <copyinstr>
    80002a40:	00054c63          	bltz	a0,80002a58 <fetchstr+0x3c>
  return strlen(buf);
    80002a44:	8526                	mv	a0,s1
    80002a46:	b72fe0ef          	jal	ra,80000db8 <strlen>
}
    80002a4a:	70a2                	ld	ra,40(sp)
    80002a4c:	7402                	ld	s0,32(sp)
    80002a4e:	64e2                	ld	s1,24(sp)
    80002a50:	6942                	ld	s2,16(sp)
    80002a52:	69a2                	ld	s3,8(sp)
    80002a54:	6145                	addi	sp,sp,48
    80002a56:	8082                	ret
    return -1;
    80002a58:	557d                	li	a0,-1
    80002a5a:	bfc5                	j	80002a4a <fetchstr+0x2e>

0000000080002a5c <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002a5c:	1101                	addi	sp,sp,-32
    80002a5e:	ec06                	sd	ra,24(sp)
    80002a60:	e822                	sd	s0,16(sp)
    80002a62:	e426                	sd	s1,8(sp)
    80002a64:	1000                	addi	s0,sp,32
    80002a66:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a68:	f0bff0ef          	jal	ra,80002972 <argraw>
    80002a6c:	c088                	sw	a0,0(s1)
}
    80002a6e:	60e2                	ld	ra,24(sp)
    80002a70:	6442                	ld	s0,16(sp)
    80002a72:	64a2                	ld	s1,8(sp)
    80002a74:	6105                	addi	sp,sp,32
    80002a76:	8082                	ret

0000000080002a78 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002a78:	1101                	addi	sp,sp,-32
    80002a7a:	ec06                	sd	ra,24(sp)
    80002a7c:	e822                	sd	s0,16(sp)
    80002a7e:	e426                	sd	s1,8(sp)
    80002a80:	1000                	addi	s0,sp,32
    80002a82:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a84:	eefff0ef          	jal	ra,80002972 <argraw>
    80002a88:	e088                	sd	a0,0(s1)
}
    80002a8a:	60e2                	ld	ra,24(sp)
    80002a8c:	6442                	ld	s0,16(sp)
    80002a8e:	64a2                	ld	s1,8(sp)
    80002a90:	6105                	addi	sp,sp,32
    80002a92:	8082                	ret

0000000080002a94 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002a94:	7179                	addi	sp,sp,-48
    80002a96:	f406                	sd	ra,40(sp)
    80002a98:	f022                	sd	s0,32(sp)
    80002a9a:	ec26                	sd	s1,24(sp)
    80002a9c:	e84a                	sd	s2,16(sp)
    80002a9e:	1800                	addi	s0,sp,48
    80002aa0:	84ae                	mv	s1,a1
    80002aa2:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002aa4:	fd840593          	addi	a1,s0,-40
    80002aa8:	fd1ff0ef          	jal	ra,80002a78 <argaddr>
  return fetchstr(addr, buf, max);
    80002aac:	864a                	mv	a2,s2
    80002aae:	85a6                	mv	a1,s1
    80002ab0:	fd843503          	ld	a0,-40(s0)
    80002ab4:	f69ff0ef          	jal	ra,80002a1c <fetchstr>
}
    80002ab8:	70a2                	ld	ra,40(sp)
    80002aba:	7402                	ld	s0,32(sp)
    80002abc:	64e2                	ld	s1,24(sp)
    80002abe:	6942                	ld	s2,16(sp)
    80002ac0:	6145                	addi	sp,sp,48
    80002ac2:	8082                	ret

0000000080002ac4 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002ac4:	1101                	addi	sp,sp,-32
    80002ac6:	ec06                	sd	ra,24(sp)
    80002ac8:	e822                	sd	s0,16(sp)
    80002aca:	e426                	sd	s1,8(sp)
    80002acc:	e04a                	sd	s2,0(sp)
    80002ace:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002ad0:	862ff0ef          	jal	ra,80001b32 <myproc>
    80002ad4:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002ad6:	05853903          	ld	s2,88(a0)
    80002ada:	0a893783          	ld	a5,168(s2)
    80002ade:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002ae2:	37fd                	addiw	a5,a5,-1
    80002ae4:	4751                	li	a4,20
    80002ae6:	00f76f63          	bltu	a4,a5,80002b04 <syscall+0x40>
    80002aea:	00369713          	slli	a4,a3,0x3
    80002aee:	00005797          	auipc	a5,0x5
    80002af2:	aea78793          	addi	a5,a5,-1302 # 800075d8 <syscalls>
    80002af6:	97ba                	add	a5,a5,a4
    80002af8:	639c                	ld	a5,0(a5)
    80002afa:	c789                	beqz	a5,80002b04 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002afc:	9782                	jalr	a5
    80002afe:	06a93823          	sd	a0,112(s2)
    80002b02:	a829                	j	80002b1c <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b04:	15848613          	addi	a2,s1,344
    80002b08:	588c                	lw	a1,48(s1)
    80002b0a:	00005517          	auipc	a0,0x5
    80002b0e:	a9650513          	addi	a0,a0,-1386 # 800075a0 <states.0+0x158>
    80002b12:	9b3fd0ef          	jal	ra,800004c4 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002b16:	6cbc                	ld	a5,88(s1)
    80002b18:	577d                	li	a4,-1
    80002b1a:	fbb8                	sd	a4,112(a5)
  }
}
    80002b1c:	60e2                	ld	ra,24(sp)
    80002b1e:	6442                	ld	s0,16(sp)
    80002b20:	64a2                	ld	s1,8(sp)
    80002b22:	6902                	ld	s2,0(sp)
    80002b24:	6105                	addi	sp,sp,32
    80002b26:	8082                	ret

0000000080002b28 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002b28:	1101                	addi	sp,sp,-32
    80002b2a:	ec06                	sd	ra,24(sp)
    80002b2c:	e822                	sd	s0,16(sp)
    80002b2e:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002b30:	fec40593          	addi	a1,s0,-20
    80002b34:	4501                	li	a0,0
    80002b36:	f27ff0ef          	jal	ra,80002a5c <argint>
  kexit(n);
    80002b3a:	fec42503          	lw	a0,-20(s0)
    80002b3e:	f22ff0ef          	jal	ra,80002260 <kexit>
  return 0;  // not reached
}
    80002b42:	4501                	li	a0,0
    80002b44:	60e2                	ld	ra,24(sp)
    80002b46:	6442                	ld	s0,16(sp)
    80002b48:	6105                	addi	sp,sp,32
    80002b4a:	8082                	ret

0000000080002b4c <sys_getpid>:

uint64
sys_getpid(void)
{
    80002b4c:	1141                	addi	sp,sp,-16
    80002b4e:	e406                	sd	ra,8(sp)
    80002b50:	e022                	sd	s0,0(sp)
    80002b52:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002b54:	fdffe0ef          	jal	ra,80001b32 <myproc>
}
    80002b58:	5908                	lw	a0,48(a0)
    80002b5a:	60a2                	ld	ra,8(sp)
    80002b5c:	6402                	ld	s0,0(sp)
    80002b5e:	0141                	addi	sp,sp,16
    80002b60:	8082                	ret

0000000080002b62 <sys_fork>:

uint64
sys_fork(void)
{
    80002b62:	1141                	addi	sp,sp,-16
    80002b64:	e406                	sd	ra,8(sp)
    80002b66:	e022                	sd	s0,0(sp)
    80002b68:	0800                	addi	s0,sp,16
  return kfork();
    80002b6a:	b46ff0ef          	jal	ra,80001eb0 <kfork>
}
    80002b6e:	60a2                	ld	ra,8(sp)
    80002b70:	6402                	ld	s0,0(sp)
    80002b72:	0141                	addi	sp,sp,16
    80002b74:	8082                	ret

0000000080002b76 <sys_wait>:

uint64
sys_wait(void)
{
    80002b76:	1101                	addi	sp,sp,-32
    80002b78:	ec06                	sd	ra,24(sp)
    80002b7a:	e822                	sd	s0,16(sp)
    80002b7c:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002b7e:	fe840593          	addi	a1,s0,-24
    80002b82:	4501                	li	a0,0
    80002b84:	ef5ff0ef          	jal	ra,80002a78 <argaddr>
  return kwait(p);
    80002b88:	fe843503          	ld	a0,-24(s0)
    80002b8c:	82bff0ef          	jal	ra,800023b6 <kwait>
}
    80002b90:	60e2                	ld	ra,24(sp)
    80002b92:	6442                	ld	s0,16(sp)
    80002b94:	6105                	addi	sp,sp,32
    80002b96:	8082                	ret

0000000080002b98 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002b98:	7179                	addi	sp,sp,-48
    80002b9a:	f406                	sd	ra,40(sp)
    80002b9c:	f022                	sd	s0,32(sp)
    80002b9e:	ec26                	sd	s1,24(sp)
    80002ba0:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002ba2:	fd840593          	addi	a1,s0,-40
    80002ba6:	4501                	li	a0,0
    80002ba8:	eb5ff0ef          	jal	ra,80002a5c <argint>
  argint(1, &t);
    80002bac:	fdc40593          	addi	a1,s0,-36
    80002bb0:	4505                	li	a0,1
    80002bb2:	eabff0ef          	jal	ra,80002a5c <argint>
  addr = myproc()->sz;
    80002bb6:	f7dfe0ef          	jal	ra,80001b32 <myproc>
    80002bba:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002bbc:	fdc42703          	lw	a4,-36(s0)
    80002bc0:	4785                	li	a5,1
    80002bc2:	02f70163          	beq	a4,a5,80002be4 <sys_sbrk+0x4c>
    80002bc6:	fd842783          	lw	a5,-40(s0)
    80002bca:	0007cd63          	bltz	a5,80002be4 <sys_sbrk+0x4c>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002bce:	97a6                	add	a5,a5,s1
    80002bd0:	0297e863          	bltu	a5,s1,80002c00 <sys_sbrk+0x68>
      return -1;
    myproc()->sz += n;
    80002bd4:	f5ffe0ef          	jal	ra,80001b32 <myproc>
    80002bd8:	fd842703          	lw	a4,-40(s0)
    80002bdc:	653c                	ld	a5,72(a0)
    80002bde:	97ba                	add	a5,a5,a4
    80002be0:	e53c                	sd	a5,72(a0)
    80002be2:	a039                	j	80002bf0 <sys_sbrk+0x58>
    if(growproc(n) < 0) {
    80002be4:	fd842503          	lw	a0,-40(s0)
    80002be8:	a78ff0ef          	jal	ra,80001e60 <growproc>
    80002bec:	00054863          	bltz	a0,80002bfc <sys_sbrk+0x64>
  }
  return addr;
}
    80002bf0:	8526                	mv	a0,s1
    80002bf2:	70a2                	ld	ra,40(sp)
    80002bf4:	7402                	ld	s0,32(sp)
    80002bf6:	64e2                	ld	s1,24(sp)
    80002bf8:	6145                	addi	sp,sp,48
    80002bfa:	8082                	ret
      return -1;
    80002bfc:	54fd                	li	s1,-1
    80002bfe:	bfcd                	j	80002bf0 <sys_sbrk+0x58>
      return -1;
    80002c00:	54fd                	li	s1,-1
    80002c02:	b7fd                	j	80002bf0 <sys_sbrk+0x58>

0000000080002c04 <sys_pause>:

uint64
sys_pause(void)
{
    80002c04:	7139                	addi	sp,sp,-64
    80002c06:	fc06                	sd	ra,56(sp)
    80002c08:	f822                	sd	s0,48(sp)
    80002c0a:	f426                	sd	s1,40(sp)
    80002c0c:	f04a                	sd	s2,32(sp)
    80002c0e:	ec4e                	sd	s3,24(sp)
    80002c10:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002c12:	fcc40593          	addi	a1,s0,-52
    80002c16:	4501                	li	a0,0
    80002c18:	e45ff0ef          	jal	ra,80002a5c <argint>
  if(n < 0)
    80002c1c:	fcc42783          	lw	a5,-52(s0)
    80002c20:	0607c563          	bltz	a5,80002c8a <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002c24:	00014517          	auipc	a0,0x14
    80002c28:	42450513          	addi	a0,a0,1060 # 80017048 <tickslock>
    80002c2c:	f41fd0ef          	jal	ra,80000b6c <acquire>
  ticks0 = ticks;
    80002c30:	00005917          	auipc	s2,0x5
    80002c34:	ee892903          	lw	s2,-280(s2) # 80007b18 <ticks>
  while(ticks - ticks0 < n){
    80002c38:	fcc42783          	lw	a5,-52(s0)
    80002c3c:	cb8d                	beqz	a5,80002c6e <sys_pause+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002c3e:	00014997          	auipc	s3,0x14
    80002c42:	40a98993          	addi	s3,s3,1034 # 80017048 <tickslock>
    80002c46:	00005497          	auipc	s1,0x5
    80002c4a:	ed248493          	addi	s1,s1,-302 # 80007b18 <ticks>
    if(killed(myproc())){
    80002c4e:	ee5fe0ef          	jal	ra,80001b32 <myproc>
    80002c52:	f3aff0ef          	jal	ra,8000238c <killed>
    80002c56:	ed0d                	bnez	a0,80002c90 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002c58:	85ce                	mv	a1,s3
    80002c5a:	8526                	mv	a0,s1
    80002c5c:	cf8ff0ef          	jal	ra,80002154 <sleep>
  while(ticks - ticks0 < n){
    80002c60:	409c                	lw	a5,0(s1)
    80002c62:	412787bb          	subw	a5,a5,s2
    80002c66:	fcc42703          	lw	a4,-52(s0)
    80002c6a:	fee7e2e3          	bltu	a5,a4,80002c4e <sys_pause+0x4a>
  }
  release(&tickslock);
    80002c6e:	00014517          	auipc	a0,0x14
    80002c72:	3da50513          	addi	a0,a0,986 # 80017048 <tickslock>
    80002c76:	f8ffd0ef          	jal	ra,80000c04 <release>
  return 0;
    80002c7a:	4501                	li	a0,0
}
    80002c7c:	70e2                	ld	ra,56(sp)
    80002c7e:	7442                	ld	s0,48(sp)
    80002c80:	74a2                	ld	s1,40(sp)
    80002c82:	7902                	ld	s2,32(sp)
    80002c84:	69e2                	ld	s3,24(sp)
    80002c86:	6121                	addi	sp,sp,64
    80002c88:	8082                	ret
    n = 0;
    80002c8a:	fc042623          	sw	zero,-52(s0)
    80002c8e:	bf59                	j	80002c24 <sys_pause+0x20>
      release(&tickslock);
    80002c90:	00014517          	auipc	a0,0x14
    80002c94:	3b850513          	addi	a0,a0,952 # 80017048 <tickslock>
    80002c98:	f6dfd0ef          	jal	ra,80000c04 <release>
      return -1;
    80002c9c:	557d                	li	a0,-1
    80002c9e:	bff9                	j	80002c7c <sys_pause+0x78>

0000000080002ca0 <sys_kill>:

uint64
sys_kill(void)
{
    80002ca0:	1101                	addi	sp,sp,-32
    80002ca2:	ec06                	sd	ra,24(sp)
    80002ca4:	e822                	sd	s0,16(sp)
    80002ca6:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002ca8:	fec40593          	addi	a1,s0,-20
    80002cac:	4501                	li	a0,0
    80002cae:	dafff0ef          	jal	ra,80002a5c <argint>
  return kkill(pid);
    80002cb2:	fec42503          	lw	a0,-20(s0)
    80002cb6:	e4cff0ef          	jal	ra,80002302 <kkill>
}
    80002cba:	60e2                	ld	ra,24(sp)
    80002cbc:	6442                	ld	s0,16(sp)
    80002cbe:	6105                	addi	sp,sp,32
    80002cc0:	8082                	ret

0000000080002cc2 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002cc2:	1101                	addi	sp,sp,-32
    80002cc4:	ec06                	sd	ra,24(sp)
    80002cc6:	e822                	sd	s0,16(sp)
    80002cc8:	e426                	sd	s1,8(sp)
    80002cca:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ccc:	00014517          	auipc	a0,0x14
    80002cd0:	37c50513          	addi	a0,a0,892 # 80017048 <tickslock>
    80002cd4:	e99fd0ef          	jal	ra,80000b6c <acquire>
  xticks = ticks;
    80002cd8:	00005497          	auipc	s1,0x5
    80002cdc:	e404a483          	lw	s1,-448(s1) # 80007b18 <ticks>
  release(&tickslock);
    80002ce0:	00014517          	auipc	a0,0x14
    80002ce4:	36850513          	addi	a0,a0,872 # 80017048 <tickslock>
    80002ce8:	f1dfd0ef          	jal	ra,80000c04 <release>
  return xticks;
}
    80002cec:	02049513          	slli	a0,s1,0x20
    80002cf0:	9101                	srli	a0,a0,0x20
    80002cf2:	60e2                	ld	ra,24(sp)
    80002cf4:	6442                	ld	s0,16(sp)
    80002cf6:	64a2                	ld	s1,8(sp)
    80002cf8:	6105                	addi	sp,sp,32
    80002cfa:	8082                	ret

0000000080002cfc <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002cfc:	7179                	addi	sp,sp,-48
    80002cfe:	f406                	sd	ra,40(sp)
    80002d00:	f022                	sd	s0,32(sp)
    80002d02:	ec26                	sd	s1,24(sp)
    80002d04:	e84a                	sd	s2,16(sp)
    80002d06:	e44e                	sd	s3,8(sp)
    80002d08:	e052                	sd	s4,0(sp)
    80002d0a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002d0c:	00005597          	auipc	a1,0x5
    80002d10:	97c58593          	addi	a1,a1,-1668 # 80007688 <syscalls+0xb0>
    80002d14:	00014517          	auipc	a0,0x14
    80002d18:	34c50513          	addi	a0,a0,844 # 80017060 <bcache>
    80002d1c:	dd1fd0ef          	jal	ra,80000aec <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002d20:	0001c797          	auipc	a5,0x1c
    80002d24:	34078793          	addi	a5,a5,832 # 8001f060 <bcache+0x8000>
    80002d28:	0001c717          	auipc	a4,0x1c
    80002d2c:	5a070713          	addi	a4,a4,1440 # 8001f2c8 <bcache+0x8268>
    80002d30:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002d34:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002d38:	00014497          	auipc	s1,0x14
    80002d3c:	34048493          	addi	s1,s1,832 # 80017078 <bcache+0x18>
    b->next = bcache.head.next;
    80002d40:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002d42:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002d44:	00005a17          	auipc	s4,0x5
    80002d48:	94ca0a13          	addi	s4,s4,-1716 # 80007690 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002d4c:	2b893783          	ld	a5,696(s2)
    80002d50:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002d52:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002d56:	85d2                	mv	a1,s4
    80002d58:	01048513          	addi	a0,s1,16
    80002d5c:	2fe010ef          	jal	ra,8000405a <initsleeplock>
    bcache.head.next->prev = b;
    80002d60:	2b893783          	ld	a5,696(s2)
    80002d64:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002d66:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002d6a:	45848493          	addi	s1,s1,1112
    80002d6e:	fd349fe3          	bne	s1,s3,80002d4c <binit+0x50>
  }
}
    80002d72:	70a2                	ld	ra,40(sp)
    80002d74:	7402                	ld	s0,32(sp)
    80002d76:	64e2                	ld	s1,24(sp)
    80002d78:	6942                	ld	s2,16(sp)
    80002d7a:	69a2                	ld	s3,8(sp)
    80002d7c:	6a02                	ld	s4,0(sp)
    80002d7e:	6145                	addi	sp,sp,48
    80002d80:	8082                	ret

0000000080002d82 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002d82:	7179                	addi	sp,sp,-48
    80002d84:	f406                	sd	ra,40(sp)
    80002d86:	f022                	sd	s0,32(sp)
    80002d88:	ec26                	sd	s1,24(sp)
    80002d8a:	e84a                	sd	s2,16(sp)
    80002d8c:	e44e                	sd	s3,8(sp)
    80002d8e:	1800                	addi	s0,sp,48
    80002d90:	892a                	mv	s2,a0
    80002d92:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002d94:	00014517          	auipc	a0,0x14
    80002d98:	2cc50513          	addi	a0,a0,716 # 80017060 <bcache>
    80002d9c:	dd1fd0ef          	jal	ra,80000b6c <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002da0:	0001c497          	auipc	s1,0x1c
    80002da4:	5784b483          	ld	s1,1400(s1) # 8001f318 <bcache+0x82b8>
    80002da8:	0001c797          	auipc	a5,0x1c
    80002dac:	52078793          	addi	a5,a5,1312 # 8001f2c8 <bcache+0x8268>
    80002db0:	02f48b63          	beq	s1,a5,80002de6 <bread+0x64>
    80002db4:	873e                	mv	a4,a5
    80002db6:	a021                	j	80002dbe <bread+0x3c>
    80002db8:	68a4                	ld	s1,80(s1)
    80002dba:	02e48663          	beq	s1,a4,80002de6 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002dbe:	449c                	lw	a5,8(s1)
    80002dc0:	ff279ce3          	bne	a5,s2,80002db8 <bread+0x36>
    80002dc4:	44dc                	lw	a5,12(s1)
    80002dc6:	ff3799e3          	bne	a5,s3,80002db8 <bread+0x36>
      b->refcnt++;
    80002dca:	40bc                	lw	a5,64(s1)
    80002dcc:	2785                	addiw	a5,a5,1
    80002dce:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002dd0:	00014517          	auipc	a0,0x14
    80002dd4:	29050513          	addi	a0,a0,656 # 80017060 <bcache>
    80002dd8:	e2dfd0ef          	jal	ra,80000c04 <release>
      acquiresleep(&b->lock);
    80002ddc:	01048513          	addi	a0,s1,16
    80002de0:	2b0010ef          	jal	ra,80004090 <acquiresleep>
      return b;
    80002de4:	a889                	j	80002e36 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002de6:	0001c497          	auipc	s1,0x1c
    80002dea:	52a4b483          	ld	s1,1322(s1) # 8001f310 <bcache+0x82b0>
    80002dee:	0001c797          	auipc	a5,0x1c
    80002df2:	4da78793          	addi	a5,a5,1242 # 8001f2c8 <bcache+0x8268>
    80002df6:	00f48863          	beq	s1,a5,80002e06 <bread+0x84>
    80002dfa:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002dfc:	40bc                	lw	a5,64(s1)
    80002dfe:	cb91                	beqz	a5,80002e12 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e00:	64a4                	ld	s1,72(s1)
    80002e02:	fee49de3          	bne	s1,a4,80002dfc <bread+0x7a>
  panic("bget: no buffers");
    80002e06:	00005517          	auipc	a0,0x5
    80002e0a:	89250513          	addi	a0,a0,-1902 # 80007698 <syscalls+0xc0>
    80002e0e:	97dfd0ef          	jal	ra,8000078a <panic>
      b->dev = dev;
    80002e12:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002e16:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002e1a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002e1e:	4785                	li	a5,1
    80002e20:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e22:	00014517          	auipc	a0,0x14
    80002e26:	23e50513          	addi	a0,a0,574 # 80017060 <bcache>
    80002e2a:	ddbfd0ef          	jal	ra,80000c04 <release>
      acquiresleep(&b->lock);
    80002e2e:	01048513          	addi	a0,s1,16
    80002e32:	25e010ef          	jal	ra,80004090 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002e36:	409c                	lw	a5,0(s1)
    80002e38:	cb89                	beqz	a5,80002e4a <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002e3a:	8526                	mv	a0,s1
    80002e3c:	70a2                	ld	ra,40(sp)
    80002e3e:	7402                	ld	s0,32(sp)
    80002e40:	64e2                	ld	s1,24(sp)
    80002e42:	6942                	ld	s2,16(sp)
    80002e44:	69a2                	ld	s3,8(sp)
    80002e46:	6145                	addi	sp,sp,48
    80002e48:	8082                	ret
    virtio_disk_rw(b, 0);
    80002e4a:	4581                	li	a1,0
    80002e4c:	8526                	mv	a0,s1
    80002e4e:	13f020ef          	jal	ra,8000578c <virtio_disk_rw>
    b->valid = 1;
    80002e52:	4785                	li	a5,1
    80002e54:	c09c                	sw	a5,0(s1)
  return b;
    80002e56:	b7d5                	j	80002e3a <bread+0xb8>

0000000080002e58 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002e58:	1101                	addi	sp,sp,-32
    80002e5a:	ec06                	sd	ra,24(sp)
    80002e5c:	e822                	sd	s0,16(sp)
    80002e5e:	e426                	sd	s1,8(sp)
    80002e60:	1000                	addi	s0,sp,32
    80002e62:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002e64:	0541                	addi	a0,a0,16
    80002e66:	2a8010ef          	jal	ra,8000410e <holdingsleep>
    80002e6a:	c911                	beqz	a0,80002e7e <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002e6c:	4585                	li	a1,1
    80002e6e:	8526                	mv	a0,s1
    80002e70:	11d020ef          	jal	ra,8000578c <virtio_disk_rw>
}
    80002e74:	60e2                	ld	ra,24(sp)
    80002e76:	6442                	ld	s0,16(sp)
    80002e78:	64a2                	ld	s1,8(sp)
    80002e7a:	6105                	addi	sp,sp,32
    80002e7c:	8082                	ret
    panic("bwrite");
    80002e7e:	00005517          	auipc	a0,0x5
    80002e82:	83250513          	addi	a0,a0,-1998 # 800076b0 <syscalls+0xd8>
    80002e86:	905fd0ef          	jal	ra,8000078a <panic>

0000000080002e8a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002e8a:	1101                	addi	sp,sp,-32
    80002e8c:	ec06                	sd	ra,24(sp)
    80002e8e:	e822                	sd	s0,16(sp)
    80002e90:	e426                	sd	s1,8(sp)
    80002e92:	e04a                	sd	s2,0(sp)
    80002e94:	1000                	addi	s0,sp,32
    80002e96:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002e98:	01050913          	addi	s2,a0,16
    80002e9c:	854a                	mv	a0,s2
    80002e9e:	270010ef          	jal	ra,8000410e <holdingsleep>
    80002ea2:	c13d                	beqz	a0,80002f08 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80002ea4:	854a                	mv	a0,s2
    80002ea6:	230010ef          	jal	ra,800040d6 <releasesleep>

  acquire(&bcache.lock);
    80002eaa:	00014517          	auipc	a0,0x14
    80002eae:	1b650513          	addi	a0,a0,438 # 80017060 <bcache>
    80002eb2:	cbbfd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt--;
    80002eb6:	40bc                	lw	a5,64(s1)
    80002eb8:	37fd                	addiw	a5,a5,-1
    80002eba:	0007871b          	sext.w	a4,a5
    80002ebe:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002ec0:	eb05                	bnez	a4,80002ef0 <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002ec2:	68bc                	ld	a5,80(s1)
    80002ec4:	64b8                	ld	a4,72(s1)
    80002ec6:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002ec8:	64bc                	ld	a5,72(s1)
    80002eca:	68b8                	ld	a4,80(s1)
    80002ecc:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002ece:	0001c797          	auipc	a5,0x1c
    80002ed2:	19278793          	addi	a5,a5,402 # 8001f060 <bcache+0x8000>
    80002ed6:	2b87b703          	ld	a4,696(a5)
    80002eda:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002edc:	0001c717          	auipc	a4,0x1c
    80002ee0:	3ec70713          	addi	a4,a4,1004 # 8001f2c8 <bcache+0x8268>
    80002ee4:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002ee6:	2b87b703          	ld	a4,696(a5)
    80002eea:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002eec:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002ef0:	00014517          	auipc	a0,0x14
    80002ef4:	17050513          	addi	a0,a0,368 # 80017060 <bcache>
    80002ef8:	d0dfd0ef          	jal	ra,80000c04 <release>
}
    80002efc:	60e2                	ld	ra,24(sp)
    80002efe:	6442                	ld	s0,16(sp)
    80002f00:	64a2                	ld	s1,8(sp)
    80002f02:	6902                	ld	s2,0(sp)
    80002f04:	6105                	addi	sp,sp,32
    80002f06:	8082                	ret
    panic("brelse");
    80002f08:	00004517          	auipc	a0,0x4
    80002f0c:	7b050513          	addi	a0,a0,1968 # 800076b8 <syscalls+0xe0>
    80002f10:	87bfd0ef          	jal	ra,8000078a <panic>

0000000080002f14 <bpin>:

void
bpin(struct buf *b) {
    80002f14:	1101                	addi	sp,sp,-32
    80002f16:	ec06                	sd	ra,24(sp)
    80002f18:	e822                	sd	s0,16(sp)
    80002f1a:	e426                	sd	s1,8(sp)
    80002f1c:	1000                	addi	s0,sp,32
    80002f1e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f20:	00014517          	auipc	a0,0x14
    80002f24:	14050513          	addi	a0,a0,320 # 80017060 <bcache>
    80002f28:	c45fd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt++;
    80002f2c:	40bc                	lw	a5,64(s1)
    80002f2e:	2785                	addiw	a5,a5,1
    80002f30:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f32:	00014517          	auipc	a0,0x14
    80002f36:	12e50513          	addi	a0,a0,302 # 80017060 <bcache>
    80002f3a:	ccbfd0ef          	jal	ra,80000c04 <release>
}
    80002f3e:	60e2                	ld	ra,24(sp)
    80002f40:	6442                	ld	s0,16(sp)
    80002f42:	64a2                	ld	s1,8(sp)
    80002f44:	6105                	addi	sp,sp,32
    80002f46:	8082                	ret

0000000080002f48 <bunpin>:

void
bunpin(struct buf *b) {
    80002f48:	1101                	addi	sp,sp,-32
    80002f4a:	ec06                	sd	ra,24(sp)
    80002f4c:	e822                	sd	s0,16(sp)
    80002f4e:	e426                	sd	s1,8(sp)
    80002f50:	1000                	addi	s0,sp,32
    80002f52:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f54:	00014517          	auipc	a0,0x14
    80002f58:	10c50513          	addi	a0,a0,268 # 80017060 <bcache>
    80002f5c:	c11fd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt--;
    80002f60:	40bc                	lw	a5,64(s1)
    80002f62:	37fd                	addiw	a5,a5,-1
    80002f64:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f66:	00014517          	auipc	a0,0x14
    80002f6a:	0fa50513          	addi	a0,a0,250 # 80017060 <bcache>
    80002f6e:	c97fd0ef          	jal	ra,80000c04 <release>
}
    80002f72:	60e2                	ld	ra,24(sp)
    80002f74:	6442                	ld	s0,16(sp)
    80002f76:	64a2                	ld	s1,8(sp)
    80002f78:	6105                	addi	sp,sp,32
    80002f7a:	8082                	ret

0000000080002f7c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002f7c:	1101                	addi	sp,sp,-32
    80002f7e:	ec06                	sd	ra,24(sp)
    80002f80:	e822                	sd	s0,16(sp)
    80002f82:	e426                	sd	s1,8(sp)
    80002f84:	e04a                	sd	s2,0(sp)
    80002f86:	1000                	addi	s0,sp,32
    80002f88:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002f8a:	00d5d59b          	srliw	a1,a1,0xd
    80002f8e:	0001c797          	auipc	a5,0x1c
    80002f92:	7ae7a783          	lw	a5,1966(a5) # 8001f73c <sb+0x1c>
    80002f96:	9dbd                	addw	a1,a1,a5
    80002f98:	debff0ef          	jal	ra,80002d82 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002f9c:	0074f713          	andi	a4,s1,7
    80002fa0:	4785                	li	a5,1
    80002fa2:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002fa6:	14ce                	slli	s1,s1,0x33
    80002fa8:	90d9                	srli	s1,s1,0x36
    80002faa:	00950733          	add	a4,a0,s1
    80002fae:	05874703          	lbu	a4,88(a4)
    80002fb2:	00e7f6b3          	and	a3,a5,a4
    80002fb6:	c29d                	beqz	a3,80002fdc <bfree+0x60>
    80002fb8:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002fba:	94aa                	add	s1,s1,a0
    80002fbc:	fff7c793          	not	a5,a5
    80002fc0:	8ff9                	and	a5,a5,a4
    80002fc2:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80002fc6:	7d1000ef          	jal	ra,80003f96 <log_write>
  brelse(bp);
    80002fca:	854a                	mv	a0,s2
    80002fcc:	ebfff0ef          	jal	ra,80002e8a <brelse>
}
    80002fd0:	60e2                	ld	ra,24(sp)
    80002fd2:	6442                	ld	s0,16(sp)
    80002fd4:	64a2                	ld	s1,8(sp)
    80002fd6:	6902                	ld	s2,0(sp)
    80002fd8:	6105                	addi	sp,sp,32
    80002fda:	8082                	ret
    panic("freeing free block");
    80002fdc:	00004517          	auipc	a0,0x4
    80002fe0:	6e450513          	addi	a0,a0,1764 # 800076c0 <syscalls+0xe8>
    80002fe4:	fa6fd0ef          	jal	ra,8000078a <panic>

0000000080002fe8 <balloc>:
{
    80002fe8:	711d                	addi	sp,sp,-96
    80002fea:	ec86                	sd	ra,88(sp)
    80002fec:	e8a2                	sd	s0,80(sp)
    80002fee:	e4a6                	sd	s1,72(sp)
    80002ff0:	e0ca                	sd	s2,64(sp)
    80002ff2:	fc4e                	sd	s3,56(sp)
    80002ff4:	f852                	sd	s4,48(sp)
    80002ff6:	f456                	sd	s5,40(sp)
    80002ff8:	f05a                	sd	s6,32(sp)
    80002ffa:	ec5e                	sd	s7,24(sp)
    80002ffc:	e862                	sd	s8,16(sp)
    80002ffe:	e466                	sd	s9,8(sp)
    80003000:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003002:	0001c797          	auipc	a5,0x1c
    80003006:	7227a783          	lw	a5,1826(a5) # 8001f724 <sb+0x4>
    8000300a:	0e078163          	beqz	a5,800030ec <balloc+0x104>
    8000300e:	8baa                	mv	s7,a0
    80003010:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003012:	0001cb17          	auipc	s6,0x1c
    80003016:	70eb0b13          	addi	s6,s6,1806 # 8001f720 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000301a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000301c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000301e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003020:	6c89                	lui	s9,0x2
    80003022:	a0b5                	j	8000308e <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003024:	974a                	add	a4,a4,s2
    80003026:	8fd5                	or	a5,a5,a3
    80003028:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000302c:	854a                	mv	a0,s2
    8000302e:	769000ef          	jal	ra,80003f96 <log_write>
        brelse(bp);
    80003032:	854a                	mv	a0,s2
    80003034:	e57ff0ef          	jal	ra,80002e8a <brelse>
  bp = bread(dev, bno);
    80003038:	85a6                	mv	a1,s1
    8000303a:	855e                	mv	a0,s7
    8000303c:	d47ff0ef          	jal	ra,80002d82 <bread>
    80003040:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003042:	40000613          	li	a2,1024
    80003046:	4581                	li	a1,0
    80003048:	05850513          	addi	a0,a0,88
    8000304c:	bf5fd0ef          	jal	ra,80000c40 <memset>
  log_write(bp);
    80003050:	854a                	mv	a0,s2
    80003052:	745000ef          	jal	ra,80003f96 <log_write>
  brelse(bp);
    80003056:	854a                	mv	a0,s2
    80003058:	e33ff0ef          	jal	ra,80002e8a <brelse>
}
    8000305c:	8526                	mv	a0,s1
    8000305e:	60e6                	ld	ra,88(sp)
    80003060:	6446                	ld	s0,80(sp)
    80003062:	64a6                	ld	s1,72(sp)
    80003064:	6906                	ld	s2,64(sp)
    80003066:	79e2                	ld	s3,56(sp)
    80003068:	7a42                	ld	s4,48(sp)
    8000306a:	7aa2                	ld	s5,40(sp)
    8000306c:	7b02                	ld	s6,32(sp)
    8000306e:	6be2                	ld	s7,24(sp)
    80003070:	6c42                	ld	s8,16(sp)
    80003072:	6ca2                	ld	s9,8(sp)
    80003074:	6125                	addi	sp,sp,96
    80003076:	8082                	ret
    brelse(bp);
    80003078:	854a                	mv	a0,s2
    8000307a:	e11ff0ef          	jal	ra,80002e8a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000307e:	015c87bb          	addw	a5,s9,s5
    80003082:	00078a9b          	sext.w	s5,a5
    80003086:	004b2703          	lw	a4,4(s6)
    8000308a:	06eaf163          	bgeu	s5,a4,800030ec <balloc+0x104>
    bp = bread(dev, BBLOCK(b, sb));
    8000308e:	41fad79b          	sraiw	a5,s5,0x1f
    80003092:	0137d79b          	srliw	a5,a5,0x13
    80003096:	015787bb          	addw	a5,a5,s5
    8000309a:	40d7d79b          	sraiw	a5,a5,0xd
    8000309e:	01cb2583          	lw	a1,28(s6)
    800030a2:	9dbd                	addw	a1,a1,a5
    800030a4:	855e                	mv	a0,s7
    800030a6:	cddff0ef          	jal	ra,80002d82 <bread>
    800030aa:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030ac:	004b2503          	lw	a0,4(s6)
    800030b0:	000a849b          	sext.w	s1,s5
    800030b4:	8662                	mv	a2,s8
    800030b6:	fca4f1e3          	bgeu	s1,a0,80003078 <balloc+0x90>
      m = 1 << (bi % 8);
    800030ba:	41f6579b          	sraiw	a5,a2,0x1f
    800030be:	01d7d69b          	srliw	a3,a5,0x1d
    800030c2:	00c6873b          	addw	a4,a3,a2
    800030c6:	00777793          	andi	a5,a4,7
    800030ca:	9f95                	subw	a5,a5,a3
    800030cc:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800030d0:	4037571b          	sraiw	a4,a4,0x3
    800030d4:	00e906b3          	add	a3,s2,a4
    800030d8:	0586c683          	lbu	a3,88(a3) # 1058 <_entry-0x7fffefa8>
    800030dc:	00d7f5b3          	and	a1,a5,a3
    800030e0:	d1b1                	beqz	a1,80003024 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030e2:	2605                	addiw	a2,a2,1
    800030e4:	2485                	addiw	s1,s1,1
    800030e6:	fd4618e3          	bne	a2,s4,800030b6 <balloc+0xce>
    800030ea:	b779                	j	80003078 <balloc+0x90>
  printf("balloc: out of blocks\n");
    800030ec:	00004517          	auipc	a0,0x4
    800030f0:	5ec50513          	addi	a0,a0,1516 # 800076d8 <syscalls+0x100>
    800030f4:	bd0fd0ef          	jal	ra,800004c4 <printf>
  return 0;
    800030f8:	4481                	li	s1,0
    800030fa:	b78d                	j	8000305c <balloc+0x74>

00000000800030fc <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800030fc:	7179                	addi	sp,sp,-48
    800030fe:	f406                	sd	ra,40(sp)
    80003100:	f022                	sd	s0,32(sp)
    80003102:	ec26                	sd	s1,24(sp)
    80003104:	e84a                	sd	s2,16(sp)
    80003106:	e44e                	sd	s3,8(sp)
    80003108:	e052                	sd	s4,0(sp)
    8000310a:	1800                	addi	s0,sp,48
    8000310c:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000310e:	47ad                	li	a5,11
    80003110:	02b7e563          	bltu	a5,a1,8000313a <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80003114:	02059493          	slli	s1,a1,0x20
    80003118:	9081                	srli	s1,s1,0x20
    8000311a:	048a                	slli	s1,s1,0x2
    8000311c:	94aa                	add	s1,s1,a0
    8000311e:	0504a903          	lw	s2,80(s1)
    80003122:	06091663          	bnez	s2,8000318e <bmap+0x92>
      addr = balloc(ip->dev);
    80003126:	4108                	lw	a0,0(a0)
    80003128:	ec1ff0ef          	jal	ra,80002fe8 <balloc>
    8000312c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003130:	04090f63          	beqz	s2,8000318e <bmap+0x92>
        return 0;
      ip->addrs[bn] = addr;
    80003134:	0524a823          	sw	s2,80(s1)
    80003138:	a899                	j	8000318e <bmap+0x92>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000313a:	ff45849b          	addiw	s1,a1,-12
    8000313e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003142:	0ff00793          	li	a5,255
    80003146:	06e7eb63          	bltu	a5,a4,800031bc <bmap+0xc0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000314a:	08052903          	lw	s2,128(a0)
    8000314e:	00091b63          	bnez	s2,80003164 <bmap+0x68>
      addr = balloc(ip->dev);
    80003152:	4108                	lw	a0,0(a0)
    80003154:	e95ff0ef          	jal	ra,80002fe8 <balloc>
    80003158:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000315c:	02090963          	beqz	s2,8000318e <bmap+0x92>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003160:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003164:	85ca                	mv	a1,s2
    80003166:	0009a503          	lw	a0,0(s3)
    8000316a:	c19ff0ef          	jal	ra,80002d82 <bread>
    8000316e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003170:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003174:	02049593          	slli	a1,s1,0x20
    80003178:	9181                	srli	a1,a1,0x20
    8000317a:	058a                	slli	a1,a1,0x2
    8000317c:	00b784b3          	add	s1,a5,a1
    80003180:	0004a903          	lw	s2,0(s1)
    80003184:	00090e63          	beqz	s2,800031a0 <bmap+0xa4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003188:	8552                	mv	a0,s4
    8000318a:	d01ff0ef          	jal	ra,80002e8a <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000318e:	854a                	mv	a0,s2
    80003190:	70a2                	ld	ra,40(sp)
    80003192:	7402                	ld	s0,32(sp)
    80003194:	64e2                	ld	s1,24(sp)
    80003196:	6942                	ld	s2,16(sp)
    80003198:	69a2                	ld	s3,8(sp)
    8000319a:	6a02                	ld	s4,0(sp)
    8000319c:	6145                	addi	sp,sp,48
    8000319e:	8082                	ret
      addr = balloc(ip->dev);
    800031a0:	0009a503          	lw	a0,0(s3)
    800031a4:	e45ff0ef          	jal	ra,80002fe8 <balloc>
    800031a8:	0005091b          	sext.w	s2,a0
      if(addr){
    800031ac:	fc090ee3          	beqz	s2,80003188 <bmap+0x8c>
        a[bn] = addr;
    800031b0:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800031b4:	8552                	mv	a0,s4
    800031b6:	5e1000ef          	jal	ra,80003f96 <log_write>
    800031ba:	b7f9                	j	80003188 <bmap+0x8c>
  panic("bmap: out of range");
    800031bc:	00004517          	auipc	a0,0x4
    800031c0:	53450513          	addi	a0,a0,1332 # 800076f0 <syscalls+0x118>
    800031c4:	dc6fd0ef          	jal	ra,8000078a <panic>

00000000800031c8 <iget>:
{
    800031c8:	7179                	addi	sp,sp,-48
    800031ca:	f406                	sd	ra,40(sp)
    800031cc:	f022                	sd	s0,32(sp)
    800031ce:	ec26                	sd	s1,24(sp)
    800031d0:	e84a                	sd	s2,16(sp)
    800031d2:	e44e                	sd	s3,8(sp)
    800031d4:	e052                	sd	s4,0(sp)
    800031d6:	1800                	addi	s0,sp,48
    800031d8:	89aa                	mv	s3,a0
    800031da:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800031dc:	0001c517          	auipc	a0,0x1c
    800031e0:	56450513          	addi	a0,a0,1380 # 8001f740 <itable>
    800031e4:	989fd0ef          	jal	ra,80000b6c <acquire>
  empty = 0;
    800031e8:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800031ea:	0001c497          	auipc	s1,0x1c
    800031ee:	56e48493          	addi	s1,s1,1390 # 8001f758 <itable+0x18>
    800031f2:	0001e697          	auipc	a3,0x1e
    800031f6:	ff668693          	addi	a3,a3,-10 # 800211e8 <log>
    800031fa:	a039                	j	80003208 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800031fc:	02090963          	beqz	s2,8000322e <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003200:	08848493          	addi	s1,s1,136
    80003204:	02d48863          	beq	s1,a3,80003234 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003208:	449c                	lw	a5,8(s1)
    8000320a:	fef059e3          	blez	a5,800031fc <iget+0x34>
    8000320e:	4098                	lw	a4,0(s1)
    80003210:	ff3716e3          	bne	a4,s3,800031fc <iget+0x34>
    80003214:	40d8                	lw	a4,4(s1)
    80003216:	ff4713e3          	bne	a4,s4,800031fc <iget+0x34>
      ip->ref++;
    8000321a:	2785                	addiw	a5,a5,1
    8000321c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000321e:	0001c517          	auipc	a0,0x1c
    80003222:	52250513          	addi	a0,a0,1314 # 8001f740 <itable>
    80003226:	9dffd0ef          	jal	ra,80000c04 <release>
      return ip;
    8000322a:	8926                	mv	s2,s1
    8000322c:	a02d                	j	80003256 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000322e:	fbe9                	bnez	a5,80003200 <iget+0x38>
    80003230:	8926                	mv	s2,s1
    80003232:	b7f9                	j	80003200 <iget+0x38>
  if(empty == 0)
    80003234:	02090a63          	beqz	s2,80003268 <iget+0xa0>
  ip->dev = dev;
    80003238:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000323c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003240:	4785                	li	a5,1
    80003242:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003246:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000324a:	0001c517          	auipc	a0,0x1c
    8000324e:	4f650513          	addi	a0,a0,1270 # 8001f740 <itable>
    80003252:	9b3fd0ef          	jal	ra,80000c04 <release>
}
    80003256:	854a                	mv	a0,s2
    80003258:	70a2                	ld	ra,40(sp)
    8000325a:	7402                	ld	s0,32(sp)
    8000325c:	64e2                	ld	s1,24(sp)
    8000325e:	6942                	ld	s2,16(sp)
    80003260:	69a2                	ld	s3,8(sp)
    80003262:	6a02                	ld	s4,0(sp)
    80003264:	6145                	addi	sp,sp,48
    80003266:	8082                	ret
    panic("iget: no inodes");
    80003268:	00004517          	auipc	a0,0x4
    8000326c:	4a050513          	addi	a0,a0,1184 # 80007708 <syscalls+0x130>
    80003270:	d1afd0ef          	jal	ra,8000078a <panic>

0000000080003274 <iinit>:
{
    80003274:	7179                	addi	sp,sp,-48
    80003276:	f406                	sd	ra,40(sp)
    80003278:	f022                	sd	s0,32(sp)
    8000327a:	ec26                	sd	s1,24(sp)
    8000327c:	e84a                	sd	s2,16(sp)
    8000327e:	e44e                	sd	s3,8(sp)
    80003280:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003282:	00004597          	auipc	a1,0x4
    80003286:	49658593          	addi	a1,a1,1174 # 80007718 <syscalls+0x140>
    8000328a:	0001c517          	auipc	a0,0x1c
    8000328e:	4b650513          	addi	a0,a0,1206 # 8001f740 <itable>
    80003292:	85bfd0ef          	jal	ra,80000aec <initlock>
  for(i = 0; i < NINODE; i++) {
    80003296:	0001c497          	auipc	s1,0x1c
    8000329a:	4d248493          	addi	s1,s1,1234 # 8001f768 <itable+0x28>
    8000329e:	0001e997          	auipc	s3,0x1e
    800032a2:	f5a98993          	addi	s3,s3,-166 # 800211f8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800032a6:	00004917          	auipc	s2,0x4
    800032aa:	47a90913          	addi	s2,s2,1146 # 80007720 <syscalls+0x148>
    800032ae:	85ca                	mv	a1,s2
    800032b0:	8526                	mv	a0,s1
    800032b2:	5a9000ef          	jal	ra,8000405a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800032b6:	08848493          	addi	s1,s1,136
    800032ba:	ff349ae3          	bne	s1,s3,800032ae <iinit+0x3a>
}
    800032be:	70a2                	ld	ra,40(sp)
    800032c0:	7402                	ld	s0,32(sp)
    800032c2:	64e2                	ld	s1,24(sp)
    800032c4:	6942                	ld	s2,16(sp)
    800032c6:	69a2                	ld	s3,8(sp)
    800032c8:	6145                	addi	sp,sp,48
    800032ca:	8082                	ret

00000000800032cc <ialloc>:
{
    800032cc:	715d                	addi	sp,sp,-80
    800032ce:	e486                	sd	ra,72(sp)
    800032d0:	e0a2                	sd	s0,64(sp)
    800032d2:	fc26                	sd	s1,56(sp)
    800032d4:	f84a                	sd	s2,48(sp)
    800032d6:	f44e                	sd	s3,40(sp)
    800032d8:	f052                	sd	s4,32(sp)
    800032da:	ec56                	sd	s5,24(sp)
    800032dc:	e85a                	sd	s6,16(sp)
    800032de:	e45e                	sd	s7,8(sp)
    800032e0:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800032e2:	0001c717          	auipc	a4,0x1c
    800032e6:	44a72703          	lw	a4,1098(a4) # 8001f72c <sb+0xc>
    800032ea:	4785                	li	a5,1
    800032ec:	04e7f663          	bgeu	a5,a4,80003338 <ialloc+0x6c>
    800032f0:	8aaa                	mv	s5,a0
    800032f2:	8bae                	mv	s7,a1
    800032f4:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800032f6:	0001ca17          	auipc	s4,0x1c
    800032fa:	42aa0a13          	addi	s4,s4,1066 # 8001f720 <sb>
    800032fe:	00048b1b          	sext.w	s6,s1
    80003302:	0044d793          	srli	a5,s1,0x4
    80003306:	018a2583          	lw	a1,24(s4)
    8000330a:	9dbd                	addw	a1,a1,a5
    8000330c:	8556                	mv	a0,s5
    8000330e:	a75ff0ef          	jal	ra,80002d82 <bread>
    80003312:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003314:	05850993          	addi	s3,a0,88
    80003318:	00f4f793          	andi	a5,s1,15
    8000331c:	079a                	slli	a5,a5,0x6
    8000331e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003320:	00099783          	lh	a5,0(s3)
    80003324:	cf85                	beqz	a5,8000335c <ialloc+0x90>
    brelse(bp);
    80003326:	b65ff0ef          	jal	ra,80002e8a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000332a:	0485                	addi	s1,s1,1
    8000332c:	00ca2703          	lw	a4,12(s4)
    80003330:	0004879b          	sext.w	a5,s1
    80003334:	fce7e5e3          	bltu	a5,a4,800032fe <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003338:	00004517          	auipc	a0,0x4
    8000333c:	3f050513          	addi	a0,a0,1008 # 80007728 <syscalls+0x150>
    80003340:	984fd0ef          	jal	ra,800004c4 <printf>
  return 0;
    80003344:	4501                	li	a0,0
}
    80003346:	60a6                	ld	ra,72(sp)
    80003348:	6406                	ld	s0,64(sp)
    8000334a:	74e2                	ld	s1,56(sp)
    8000334c:	7942                	ld	s2,48(sp)
    8000334e:	79a2                	ld	s3,40(sp)
    80003350:	7a02                	ld	s4,32(sp)
    80003352:	6ae2                	ld	s5,24(sp)
    80003354:	6b42                	ld	s6,16(sp)
    80003356:	6ba2                	ld	s7,8(sp)
    80003358:	6161                	addi	sp,sp,80
    8000335a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000335c:	04000613          	li	a2,64
    80003360:	4581                	li	a1,0
    80003362:	854e                	mv	a0,s3
    80003364:	8ddfd0ef          	jal	ra,80000c40 <memset>
      dip->type = type;
    80003368:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000336c:	854a                	mv	a0,s2
    8000336e:	429000ef          	jal	ra,80003f96 <log_write>
      brelse(bp);
    80003372:	854a                	mv	a0,s2
    80003374:	b17ff0ef          	jal	ra,80002e8a <brelse>
      return iget(dev, inum);
    80003378:	85da                	mv	a1,s6
    8000337a:	8556                	mv	a0,s5
    8000337c:	e4dff0ef          	jal	ra,800031c8 <iget>
    80003380:	b7d9                	j	80003346 <ialloc+0x7a>

0000000080003382 <iupdate>:
{
    80003382:	1101                	addi	sp,sp,-32
    80003384:	ec06                	sd	ra,24(sp)
    80003386:	e822                	sd	s0,16(sp)
    80003388:	e426                	sd	s1,8(sp)
    8000338a:	e04a                	sd	s2,0(sp)
    8000338c:	1000                	addi	s0,sp,32
    8000338e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003390:	415c                	lw	a5,4(a0)
    80003392:	0047d79b          	srliw	a5,a5,0x4
    80003396:	0001c597          	auipc	a1,0x1c
    8000339a:	3a25a583          	lw	a1,930(a1) # 8001f738 <sb+0x18>
    8000339e:	9dbd                	addw	a1,a1,a5
    800033a0:	4108                	lw	a0,0(a0)
    800033a2:	9e1ff0ef          	jal	ra,80002d82 <bread>
    800033a6:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800033a8:	05850793          	addi	a5,a0,88
    800033ac:	40c8                	lw	a0,4(s1)
    800033ae:	893d                	andi	a0,a0,15
    800033b0:	051a                	slli	a0,a0,0x6
    800033b2:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800033b4:	04449703          	lh	a4,68(s1)
    800033b8:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800033bc:	04649703          	lh	a4,70(s1)
    800033c0:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800033c4:	04849703          	lh	a4,72(s1)
    800033c8:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800033cc:	04a49703          	lh	a4,74(s1)
    800033d0:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800033d4:	44f8                	lw	a4,76(s1)
    800033d6:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800033d8:	03400613          	li	a2,52
    800033dc:	05048593          	addi	a1,s1,80
    800033e0:	0531                	addi	a0,a0,12
    800033e2:	8bbfd0ef          	jal	ra,80000c9c <memmove>
  log_write(bp);
    800033e6:	854a                	mv	a0,s2
    800033e8:	3af000ef          	jal	ra,80003f96 <log_write>
  brelse(bp);
    800033ec:	854a                	mv	a0,s2
    800033ee:	a9dff0ef          	jal	ra,80002e8a <brelse>
}
    800033f2:	60e2                	ld	ra,24(sp)
    800033f4:	6442                	ld	s0,16(sp)
    800033f6:	64a2                	ld	s1,8(sp)
    800033f8:	6902                	ld	s2,0(sp)
    800033fa:	6105                	addi	sp,sp,32
    800033fc:	8082                	ret

00000000800033fe <idup>:
{
    800033fe:	1101                	addi	sp,sp,-32
    80003400:	ec06                	sd	ra,24(sp)
    80003402:	e822                	sd	s0,16(sp)
    80003404:	e426                	sd	s1,8(sp)
    80003406:	1000                	addi	s0,sp,32
    80003408:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000340a:	0001c517          	auipc	a0,0x1c
    8000340e:	33650513          	addi	a0,a0,822 # 8001f740 <itable>
    80003412:	f5afd0ef          	jal	ra,80000b6c <acquire>
  ip->ref++;
    80003416:	449c                	lw	a5,8(s1)
    80003418:	2785                	addiw	a5,a5,1
    8000341a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000341c:	0001c517          	auipc	a0,0x1c
    80003420:	32450513          	addi	a0,a0,804 # 8001f740 <itable>
    80003424:	fe0fd0ef          	jal	ra,80000c04 <release>
}
    80003428:	8526                	mv	a0,s1
    8000342a:	60e2                	ld	ra,24(sp)
    8000342c:	6442                	ld	s0,16(sp)
    8000342e:	64a2                	ld	s1,8(sp)
    80003430:	6105                	addi	sp,sp,32
    80003432:	8082                	ret

0000000080003434 <ilock>:
{
    80003434:	1101                	addi	sp,sp,-32
    80003436:	ec06                	sd	ra,24(sp)
    80003438:	e822                	sd	s0,16(sp)
    8000343a:	e426                	sd	s1,8(sp)
    8000343c:	e04a                	sd	s2,0(sp)
    8000343e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003440:	c105                	beqz	a0,80003460 <ilock+0x2c>
    80003442:	84aa                	mv	s1,a0
    80003444:	451c                	lw	a5,8(a0)
    80003446:	00f05d63          	blez	a5,80003460 <ilock+0x2c>
  acquiresleep(&ip->lock);
    8000344a:	0541                	addi	a0,a0,16
    8000344c:	445000ef          	jal	ra,80004090 <acquiresleep>
  if(ip->valid == 0){
    80003450:	40bc                	lw	a5,64(s1)
    80003452:	cf89                	beqz	a5,8000346c <ilock+0x38>
}
    80003454:	60e2                	ld	ra,24(sp)
    80003456:	6442                	ld	s0,16(sp)
    80003458:	64a2                	ld	s1,8(sp)
    8000345a:	6902                	ld	s2,0(sp)
    8000345c:	6105                	addi	sp,sp,32
    8000345e:	8082                	ret
    panic("ilock");
    80003460:	00004517          	auipc	a0,0x4
    80003464:	2e050513          	addi	a0,a0,736 # 80007740 <syscalls+0x168>
    80003468:	b22fd0ef          	jal	ra,8000078a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000346c:	40dc                	lw	a5,4(s1)
    8000346e:	0047d79b          	srliw	a5,a5,0x4
    80003472:	0001c597          	auipc	a1,0x1c
    80003476:	2c65a583          	lw	a1,710(a1) # 8001f738 <sb+0x18>
    8000347a:	9dbd                	addw	a1,a1,a5
    8000347c:	4088                	lw	a0,0(s1)
    8000347e:	905ff0ef          	jal	ra,80002d82 <bread>
    80003482:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003484:	05850593          	addi	a1,a0,88
    80003488:	40dc                	lw	a5,4(s1)
    8000348a:	8bbd                	andi	a5,a5,15
    8000348c:	079a                	slli	a5,a5,0x6
    8000348e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003490:	00059783          	lh	a5,0(a1)
    80003494:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003498:	00259783          	lh	a5,2(a1)
    8000349c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800034a0:	00459783          	lh	a5,4(a1)
    800034a4:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800034a8:	00659783          	lh	a5,6(a1)
    800034ac:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800034b0:	459c                	lw	a5,8(a1)
    800034b2:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800034b4:	03400613          	li	a2,52
    800034b8:	05b1                	addi	a1,a1,12
    800034ba:	05048513          	addi	a0,s1,80
    800034be:	fdefd0ef          	jal	ra,80000c9c <memmove>
    brelse(bp);
    800034c2:	854a                	mv	a0,s2
    800034c4:	9c7ff0ef          	jal	ra,80002e8a <brelse>
    ip->valid = 1;
    800034c8:	4785                	li	a5,1
    800034ca:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800034cc:	04449783          	lh	a5,68(s1)
    800034d0:	f3d1                	bnez	a5,80003454 <ilock+0x20>
      panic("ilock: no type");
    800034d2:	00004517          	auipc	a0,0x4
    800034d6:	27650513          	addi	a0,a0,630 # 80007748 <syscalls+0x170>
    800034da:	ab0fd0ef          	jal	ra,8000078a <panic>

00000000800034de <iunlock>:
{
    800034de:	1101                	addi	sp,sp,-32
    800034e0:	ec06                	sd	ra,24(sp)
    800034e2:	e822                	sd	s0,16(sp)
    800034e4:	e426                	sd	s1,8(sp)
    800034e6:	e04a                	sd	s2,0(sp)
    800034e8:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800034ea:	c505                	beqz	a0,80003512 <iunlock+0x34>
    800034ec:	84aa                	mv	s1,a0
    800034ee:	01050913          	addi	s2,a0,16
    800034f2:	854a                	mv	a0,s2
    800034f4:	41b000ef          	jal	ra,8000410e <holdingsleep>
    800034f8:	cd09                	beqz	a0,80003512 <iunlock+0x34>
    800034fa:	449c                	lw	a5,8(s1)
    800034fc:	00f05b63          	blez	a5,80003512 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003500:	854a                	mv	a0,s2
    80003502:	3d5000ef          	jal	ra,800040d6 <releasesleep>
}
    80003506:	60e2                	ld	ra,24(sp)
    80003508:	6442                	ld	s0,16(sp)
    8000350a:	64a2                	ld	s1,8(sp)
    8000350c:	6902                	ld	s2,0(sp)
    8000350e:	6105                	addi	sp,sp,32
    80003510:	8082                	ret
    panic("iunlock");
    80003512:	00004517          	auipc	a0,0x4
    80003516:	24650513          	addi	a0,a0,582 # 80007758 <syscalls+0x180>
    8000351a:	a70fd0ef          	jal	ra,8000078a <panic>

000000008000351e <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000351e:	7179                	addi	sp,sp,-48
    80003520:	f406                	sd	ra,40(sp)
    80003522:	f022                	sd	s0,32(sp)
    80003524:	ec26                	sd	s1,24(sp)
    80003526:	e84a                	sd	s2,16(sp)
    80003528:	e44e                	sd	s3,8(sp)
    8000352a:	e052                	sd	s4,0(sp)
    8000352c:	1800                	addi	s0,sp,48
    8000352e:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003530:	05050493          	addi	s1,a0,80
    80003534:	08050913          	addi	s2,a0,128
    80003538:	a021                	j	80003540 <itrunc+0x22>
    8000353a:	0491                	addi	s1,s1,4
    8000353c:	01248b63          	beq	s1,s2,80003552 <itrunc+0x34>
    if(ip->addrs[i]){
    80003540:	408c                	lw	a1,0(s1)
    80003542:	dde5                	beqz	a1,8000353a <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003544:	0009a503          	lw	a0,0(s3)
    80003548:	a35ff0ef          	jal	ra,80002f7c <bfree>
      ip->addrs[i] = 0;
    8000354c:	0004a023          	sw	zero,0(s1)
    80003550:	b7ed                	j	8000353a <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003552:	0809a583          	lw	a1,128(s3)
    80003556:	ed91                	bnez	a1,80003572 <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003558:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000355c:	854e                	mv	a0,s3
    8000355e:	e25ff0ef          	jal	ra,80003382 <iupdate>
}
    80003562:	70a2                	ld	ra,40(sp)
    80003564:	7402                	ld	s0,32(sp)
    80003566:	64e2                	ld	s1,24(sp)
    80003568:	6942                	ld	s2,16(sp)
    8000356a:	69a2                	ld	s3,8(sp)
    8000356c:	6a02                	ld	s4,0(sp)
    8000356e:	6145                	addi	sp,sp,48
    80003570:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003572:	0009a503          	lw	a0,0(s3)
    80003576:	80dff0ef          	jal	ra,80002d82 <bread>
    8000357a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000357c:	05850493          	addi	s1,a0,88
    80003580:	45850913          	addi	s2,a0,1112
    80003584:	a021                	j	8000358c <itrunc+0x6e>
    80003586:	0491                	addi	s1,s1,4
    80003588:	01248963          	beq	s1,s2,8000359a <itrunc+0x7c>
      if(a[j])
    8000358c:	408c                	lw	a1,0(s1)
    8000358e:	dde5                	beqz	a1,80003586 <itrunc+0x68>
        bfree(ip->dev, a[j]);
    80003590:	0009a503          	lw	a0,0(s3)
    80003594:	9e9ff0ef          	jal	ra,80002f7c <bfree>
    80003598:	b7fd                	j	80003586 <itrunc+0x68>
    brelse(bp);
    8000359a:	8552                	mv	a0,s4
    8000359c:	8efff0ef          	jal	ra,80002e8a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800035a0:	0809a583          	lw	a1,128(s3)
    800035a4:	0009a503          	lw	a0,0(s3)
    800035a8:	9d5ff0ef          	jal	ra,80002f7c <bfree>
    ip->addrs[NDIRECT] = 0;
    800035ac:	0809a023          	sw	zero,128(s3)
    800035b0:	b765                	j	80003558 <itrunc+0x3a>

00000000800035b2 <iput>:
{
    800035b2:	1101                	addi	sp,sp,-32
    800035b4:	ec06                	sd	ra,24(sp)
    800035b6:	e822                	sd	s0,16(sp)
    800035b8:	e426                	sd	s1,8(sp)
    800035ba:	e04a                	sd	s2,0(sp)
    800035bc:	1000                	addi	s0,sp,32
    800035be:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800035c0:	0001c517          	auipc	a0,0x1c
    800035c4:	18050513          	addi	a0,a0,384 # 8001f740 <itable>
    800035c8:	da4fd0ef          	jal	ra,80000b6c <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800035cc:	4498                	lw	a4,8(s1)
    800035ce:	4785                	li	a5,1
    800035d0:	02f70163          	beq	a4,a5,800035f2 <iput+0x40>
  ip->ref--;
    800035d4:	449c                	lw	a5,8(s1)
    800035d6:	37fd                	addiw	a5,a5,-1
    800035d8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800035da:	0001c517          	auipc	a0,0x1c
    800035de:	16650513          	addi	a0,a0,358 # 8001f740 <itable>
    800035e2:	e22fd0ef          	jal	ra,80000c04 <release>
}
    800035e6:	60e2                	ld	ra,24(sp)
    800035e8:	6442                	ld	s0,16(sp)
    800035ea:	64a2                	ld	s1,8(sp)
    800035ec:	6902                	ld	s2,0(sp)
    800035ee:	6105                	addi	sp,sp,32
    800035f0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800035f2:	40bc                	lw	a5,64(s1)
    800035f4:	d3e5                	beqz	a5,800035d4 <iput+0x22>
    800035f6:	04a49783          	lh	a5,74(s1)
    800035fa:	ffe9                	bnez	a5,800035d4 <iput+0x22>
    acquiresleep(&ip->lock);
    800035fc:	01048913          	addi	s2,s1,16
    80003600:	854a                	mv	a0,s2
    80003602:	28f000ef          	jal	ra,80004090 <acquiresleep>
    release(&itable.lock);
    80003606:	0001c517          	auipc	a0,0x1c
    8000360a:	13a50513          	addi	a0,a0,314 # 8001f740 <itable>
    8000360e:	df6fd0ef          	jal	ra,80000c04 <release>
    itrunc(ip);
    80003612:	8526                	mv	a0,s1
    80003614:	f0bff0ef          	jal	ra,8000351e <itrunc>
    ip->type = 0;
    80003618:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000361c:	8526                	mv	a0,s1
    8000361e:	d65ff0ef          	jal	ra,80003382 <iupdate>
    ip->valid = 0;
    80003622:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003626:	854a                	mv	a0,s2
    80003628:	2af000ef          	jal	ra,800040d6 <releasesleep>
    acquire(&itable.lock);
    8000362c:	0001c517          	auipc	a0,0x1c
    80003630:	11450513          	addi	a0,a0,276 # 8001f740 <itable>
    80003634:	d38fd0ef          	jal	ra,80000b6c <acquire>
    80003638:	bf71                	j	800035d4 <iput+0x22>

000000008000363a <iunlockput>:
{
    8000363a:	1101                	addi	sp,sp,-32
    8000363c:	ec06                	sd	ra,24(sp)
    8000363e:	e822                	sd	s0,16(sp)
    80003640:	e426                	sd	s1,8(sp)
    80003642:	1000                	addi	s0,sp,32
    80003644:	84aa                	mv	s1,a0
  iunlock(ip);
    80003646:	e99ff0ef          	jal	ra,800034de <iunlock>
  iput(ip);
    8000364a:	8526                	mv	a0,s1
    8000364c:	f67ff0ef          	jal	ra,800035b2 <iput>
}
    80003650:	60e2                	ld	ra,24(sp)
    80003652:	6442                	ld	s0,16(sp)
    80003654:	64a2                	ld	s1,8(sp)
    80003656:	6105                	addi	sp,sp,32
    80003658:	8082                	ret

000000008000365a <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000365a:	0001c717          	auipc	a4,0x1c
    8000365e:	0d272703          	lw	a4,210(a4) # 8001f72c <sb+0xc>
    80003662:	4785                	li	a5,1
    80003664:	0ae7ff63          	bgeu	a5,a4,80003722 <ireclaim+0xc8>
{
    80003668:	7139                	addi	sp,sp,-64
    8000366a:	fc06                	sd	ra,56(sp)
    8000366c:	f822                	sd	s0,48(sp)
    8000366e:	f426                	sd	s1,40(sp)
    80003670:	f04a                	sd	s2,32(sp)
    80003672:	ec4e                	sd	s3,24(sp)
    80003674:	e852                	sd	s4,16(sp)
    80003676:	e456                	sd	s5,8(sp)
    80003678:	e05a                	sd	s6,0(sp)
    8000367a:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000367c:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000367e:	00050a1b          	sext.w	s4,a0
    80003682:	0001ca97          	auipc	s5,0x1c
    80003686:	09ea8a93          	addi	s5,s5,158 # 8001f720 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    8000368a:	00004b17          	auipc	s6,0x4
    8000368e:	0d6b0b13          	addi	s6,s6,214 # 80007760 <syscalls+0x188>
    80003692:	a099                	j	800036d8 <ireclaim+0x7e>
    80003694:	85ce                	mv	a1,s3
    80003696:	855a                	mv	a0,s6
    80003698:	e2dfc0ef          	jal	ra,800004c4 <printf>
      ip = iget(dev, inum);
    8000369c:	85ce                	mv	a1,s3
    8000369e:	8552                	mv	a0,s4
    800036a0:	b29ff0ef          	jal	ra,800031c8 <iget>
    800036a4:	89aa                	mv	s3,a0
    brelse(bp);
    800036a6:	854a                	mv	a0,s2
    800036a8:	fe2ff0ef          	jal	ra,80002e8a <brelse>
    if (ip) {
    800036ac:	00098f63          	beqz	s3,800036ca <ireclaim+0x70>
      begin_op();
    800036b0:	762000ef          	jal	ra,80003e12 <begin_op>
      ilock(ip);
    800036b4:	854e                	mv	a0,s3
    800036b6:	d7fff0ef          	jal	ra,80003434 <ilock>
      iunlock(ip);
    800036ba:	854e                	mv	a0,s3
    800036bc:	e23ff0ef          	jal	ra,800034de <iunlock>
      iput(ip);
    800036c0:	854e                	mv	a0,s3
    800036c2:	ef1ff0ef          	jal	ra,800035b2 <iput>
      end_op();
    800036c6:	7bc000ef          	jal	ra,80003e82 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800036ca:	0485                	addi	s1,s1,1
    800036cc:	00caa703          	lw	a4,12(s5)
    800036d0:	0004879b          	sext.w	a5,s1
    800036d4:	02e7fd63          	bgeu	a5,a4,8000370e <ireclaim+0xb4>
    800036d8:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800036dc:	0044d793          	srli	a5,s1,0x4
    800036e0:	018aa583          	lw	a1,24(s5)
    800036e4:	9dbd                	addw	a1,a1,a5
    800036e6:	8552                	mv	a0,s4
    800036e8:	e9aff0ef          	jal	ra,80002d82 <bread>
    800036ec:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800036ee:	05850793          	addi	a5,a0,88
    800036f2:	00f9f713          	andi	a4,s3,15
    800036f6:	071a                	slli	a4,a4,0x6
    800036f8:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    800036fa:	00079703          	lh	a4,0(a5)
    800036fe:	c701                	beqz	a4,80003706 <ireclaim+0xac>
    80003700:	00679783          	lh	a5,6(a5)
    80003704:	dbc1                	beqz	a5,80003694 <ireclaim+0x3a>
    brelse(bp);
    80003706:	854a                	mv	a0,s2
    80003708:	f82ff0ef          	jal	ra,80002e8a <brelse>
    if (ip) {
    8000370c:	bf7d                	j	800036ca <ireclaim+0x70>
}
    8000370e:	70e2                	ld	ra,56(sp)
    80003710:	7442                	ld	s0,48(sp)
    80003712:	74a2                	ld	s1,40(sp)
    80003714:	7902                	ld	s2,32(sp)
    80003716:	69e2                	ld	s3,24(sp)
    80003718:	6a42                	ld	s4,16(sp)
    8000371a:	6aa2                	ld	s5,8(sp)
    8000371c:	6b02                	ld	s6,0(sp)
    8000371e:	6121                	addi	sp,sp,64
    80003720:	8082                	ret
    80003722:	8082                	ret

0000000080003724 <fsinit>:
fsinit(int dev) {
    80003724:	7179                	addi	sp,sp,-48
    80003726:	f406                	sd	ra,40(sp)
    80003728:	f022                	sd	s0,32(sp)
    8000372a:	ec26                	sd	s1,24(sp)
    8000372c:	e84a                	sd	s2,16(sp)
    8000372e:	e44e                	sd	s3,8(sp)
    80003730:	1800                	addi	s0,sp,48
    80003732:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003734:	4585                	li	a1,1
    80003736:	e4cff0ef          	jal	ra,80002d82 <bread>
    8000373a:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000373c:	0001c997          	auipc	s3,0x1c
    80003740:	fe498993          	addi	s3,s3,-28 # 8001f720 <sb>
    80003744:	02000613          	li	a2,32
    80003748:	05850593          	addi	a1,a0,88
    8000374c:	854e                	mv	a0,s3
    8000374e:	d4efd0ef          	jal	ra,80000c9c <memmove>
  brelse(bp);
    80003752:	854a                	mv	a0,s2
    80003754:	f36ff0ef          	jal	ra,80002e8a <brelse>
  if(sb.magic != FSMAGIC)
    80003758:	0009a703          	lw	a4,0(s3)
    8000375c:	102037b7          	lui	a5,0x10203
    80003760:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003764:	02f71363          	bne	a4,a5,8000378a <fsinit+0x66>
  initlog(dev, &sb);
    80003768:	0001c597          	auipc	a1,0x1c
    8000376c:	fb858593          	addi	a1,a1,-72 # 8001f720 <sb>
    80003770:	8526                	mv	a0,s1
    80003772:	616000ef          	jal	ra,80003d88 <initlog>
  ireclaim(dev);
    80003776:	8526                	mv	a0,s1
    80003778:	ee3ff0ef          	jal	ra,8000365a <ireclaim>
}
    8000377c:	70a2                	ld	ra,40(sp)
    8000377e:	7402                	ld	s0,32(sp)
    80003780:	64e2                	ld	s1,24(sp)
    80003782:	6942                	ld	s2,16(sp)
    80003784:	69a2                	ld	s3,8(sp)
    80003786:	6145                	addi	sp,sp,48
    80003788:	8082                	ret
    panic("invalid file system");
    8000378a:	00004517          	auipc	a0,0x4
    8000378e:	ff650513          	addi	a0,a0,-10 # 80007780 <syscalls+0x1a8>
    80003792:	ff9fc0ef          	jal	ra,8000078a <panic>

0000000080003796 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003796:	1141                	addi	sp,sp,-16
    80003798:	e422                	sd	s0,8(sp)
    8000379a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000379c:	411c                	lw	a5,0(a0)
    8000379e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800037a0:	415c                	lw	a5,4(a0)
    800037a2:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800037a4:	04451783          	lh	a5,68(a0)
    800037a8:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800037ac:	04a51783          	lh	a5,74(a0)
    800037b0:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800037b4:	04c56783          	lwu	a5,76(a0)
    800037b8:	e99c                	sd	a5,16(a1)
}
    800037ba:	6422                	ld	s0,8(sp)
    800037bc:	0141                	addi	sp,sp,16
    800037be:	8082                	ret

00000000800037c0 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800037c0:	457c                	lw	a5,76(a0)
    800037c2:	0cd7ef63          	bltu	a5,a3,800038a0 <readi+0xe0>
{
    800037c6:	7159                	addi	sp,sp,-112
    800037c8:	f486                	sd	ra,104(sp)
    800037ca:	f0a2                	sd	s0,96(sp)
    800037cc:	eca6                	sd	s1,88(sp)
    800037ce:	e8ca                	sd	s2,80(sp)
    800037d0:	e4ce                	sd	s3,72(sp)
    800037d2:	e0d2                	sd	s4,64(sp)
    800037d4:	fc56                	sd	s5,56(sp)
    800037d6:	f85a                	sd	s6,48(sp)
    800037d8:	f45e                	sd	s7,40(sp)
    800037da:	f062                	sd	s8,32(sp)
    800037dc:	ec66                	sd	s9,24(sp)
    800037de:	e86a                	sd	s10,16(sp)
    800037e0:	e46e                	sd	s11,8(sp)
    800037e2:	1880                	addi	s0,sp,112
    800037e4:	8b2a                	mv	s6,a0
    800037e6:	8bae                	mv	s7,a1
    800037e8:	8a32                	mv	s4,a2
    800037ea:	84b6                	mv	s1,a3
    800037ec:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800037ee:	9f35                	addw	a4,a4,a3
    return 0;
    800037f0:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800037f2:	08d76663          	bltu	a4,a3,8000387e <readi+0xbe>
  if(off + n > ip->size)
    800037f6:	00e7f463          	bgeu	a5,a4,800037fe <readi+0x3e>
    n = ip->size - off;
    800037fa:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800037fe:	080a8f63          	beqz	s5,8000389c <readi+0xdc>
    80003802:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003804:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003808:	5c7d                	li	s8,-1
    8000380a:	a80d                	j	8000383c <readi+0x7c>
    8000380c:	020d1d93          	slli	s11,s10,0x20
    80003810:	020ddd93          	srli	s11,s11,0x20
    80003814:	05890793          	addi	a5,s2,88
    80003818:	86ee                	mv	a3,s11
    8000381a:	963e                	add	a2,a2,a5
    8000381c:	85d2                	mv	a1,s4
    8000381e:	855e                	mv	a0,s7
    80003820:	c91fe0ef          	jal	ra,800024b0 <either_copyout>
    80003824:	05850763          	beq	a0,s8,80003872 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003828:	854a                	mv	a0,s2
    8000382a:	e60ff0ef          	jal	ra,80002e8a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000382e:	013d09bb          	addw	s3,s10,s3
    80003832:	009d04bb          	addw	s1,s10,s1
    80003836:	9a6e                	add	s4,s4,s11
    80003838:	0559f163          	bgeu	s3,s5,8000387a <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    8000383c:	00a4d59b          	srliw	a1,s1,0xa
    80003840:	855a                	mv	a0,s6
    80003842:	8bbff0ef          	jal	ra,800030fc <bmap>
    80003846:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000384a:	c985                	beqz	a1,8000387a <readi+0xba>
    bp = bread(ip->dev, addr);
    8000384c:	000b2503          	lw	a0,0(s6)
    80003850:	d32ff0ef          	jal	ra,80002d82 <bread>
    80003854:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003856:	3ff4f613          	andi	a2,s1,1023
    8000385a:	40cc87bb          	subw	a5,s9,a2
    8000385e:	413a873b          	subw	a4,s5,s3
    80003862:	8d3e                	mv	s10,a5
    80003864:	2781                	sext.w	a5,a5
    80003866:	0007069b          	sext.w	a3,a4
    8000386a:	faf6f1e3          	bgeu	a3,a5,8000380c <readi+0x4c>
    8000386e:	8d3a                	mv	s10,a4
    80003870:	bf71                	j	8000380c <readi+0x4c>
      brelse(bp);
    80003872:	854a                	mv	a0,s2
    80003874:	e16ff0ef          	jal	ra,80002e8a <brelse>
      tot = -1;
    80003878:	59fd                	li	s3,-1
  }
  return tot;
    8000387a:	0009851b          	sext.w	a0,s3
}
    8000387e:	70a6                	ld	ra,104(sp)
    80003880:	7406                	ld	s0,96(sp)
    80003882:	64e6                	ld	s1,88(sp)
    80003884:	6946                	ld	s2,80(sp)
    80003886:	69a6                	ld	s3,72(sp)
    80003888:	6a06                	ld	s4,64(sp)
    8000388a:	7ae2                	ld	s5,56(sp)
    8000388c:	7b42                	ld	s6,48(sp)
    8000388e:	7ba2                	ld	s7,40(sp)
    80003890:	7c02                	ld	s8,32(sp)
    80003892:	6ce2                	ld	s9,24(sp)
    80003894:	6d42                	ld	s10,16(sp)
    80003896:	6da2                	ld	s11,8(sp)
    80003898:	6165                	addi	sp,sp,112
    8000389a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000389c:	89d6                	mv	s3,s5
    8000389e:	bff1                	j	8000387a <readi+0xba>
    return 0;
    800038a0:	4501                	li	a0,0
}
    800038a2:	8082                	ret

00000000800038a4 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800038a4:	457c                	lw	a5,76(a0)
    800038a6:	0ed7ea63          	bltu	a5,a3,8000399a <writei+0xf6>
{
    800038aa:	7159                	addi	sp,sp,-112
    800038ac:	f486                	sd	ra,104(sp)
    800038ae:	f0a2                	sd	s0,96(sp)
    800038b0:	eca6                	sd	s1,88(sp)
    800038b2:	e8ca                	sd	s2,80(sp)
    800038b4:	e4ce                	sd	s3,72(sp)
    800038b6:	e0d2                	sd	s4,64(sp)
    800038b8:	fc56                	sd	s5,56(sp)
    800038ba:	f85a                	sd	s6,48(sp)
    800038bc:	f45e                	sd	s7,40(sp)
    800038be:	f062                	sd	s8,32(sp)
    800038c0:	ec66                	sd	s9,24(sp)
    800038c2:	e86a                	sd	s10,16(sp)
    800038c4:	e46e                	sd	s11,8(sp)
    800038c6:	1880                	addi	s0,sp,112
    800038c8:	8aaa                	mv	s5,a0
    800038ca:	8bae                	mv	s7,a1
    800038cc:	8a32                	mv	s4,a2
    800038ce:	8936                	mv	s2,a3
    800038d0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800038d2:	00e687bb          	addw	a5,a3,a4
    800038d6:	0cd7e463          	bltu	a5,a3,8000399e <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800038da:	00043737          	lui	a4,0x43
    800038de:	0cf76263          	bltu	a4,a5,800039a2 <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800038e2:	0a0b0a63          	beqz	s6,80003996 <writei+0xf2>
    800038e6:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800038e8:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800038ec:	5c7d                	li	s8,-1
    800038ee:	a825                	j	80003926 <writei+0x82>
    800038f0:	020d1d93          	slli	s11,s10,0x20
    800038f4:	020ddd93          	srli	s11,s11,0x20
    800038f8:	05848793          	addi	a5,s1,88
    800038fc:	86ee                	mv	a3,s11
    800038fe:	8652                	mv	a2,s4
    80003900:	85de                	mv	a1,s7
    80003902:	953e                	add	a0,a0,a5
    80003904:	bf7fe0ef          	jal	ra,800024fa <either_copyin>
    80003908:	05850a63          	beq	a0,s8,8000395c <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000390c:	8526                	mv	a0,s1
    8000390e:	688000ef          	jal	ra,80003f96 <log_write>
    brelse(bp);
    80003912:	8526                	mv	a0,s1
    80003914:	d76ff0ef          	jal	ra,80002e8a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003918:	013d09bb          	addw	s3,s10,s3
    8000391c:	012d093b          	addw	s2,s10,s2
    80003920:	9a6e                	add	s4,s4,s11
    80003922:	0569f063          	bgeu	s3,s6,80003962 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003926:	00a9559b          	srliw	a1,s2,0xa
    8000392a:	8556                	mv	a0,s5
    8000392c:	fd0ff0ef          	jal	ra,800030fc <bmap>
    80003930:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003934:	c59d                	beqz	a1,80003962 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003936:	000aa503          	lw	a0,0(s5)
    8000393a:	c48ff0ef          	jal	ra,80002d82 <bread>
    8000393e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003940:	3ff97513          	andi	a0,s2,1023
    80003944:	40ac87bb          	subw	a5,s9,a0
    80003948:	413b073b          	subw	a4,s6,s3
    8000394c:	8d3e                	mv	s10,a5
    8000394e:	2781                	sext.w	a5,a5
    80003950:	0007069b          	sext.w	a3,a4
    80003954:	f8f6fee3          	bgeu	a3,a5,800038f0 <writei+0x4c>
    80003958:	8d3a                	mv	s10,a4
    8000395a:	bf59                	j	800038f0 <writei+0x4c>
      brelse(bp);
    8000395c:	8526                	mv	a0,s1
    8000395e:	d2cff0ef          	jal	ra,80002e8a <brelse>
  }

  if(off > ip->size)
    80003962:	04caa783          	lw	a5,76(s5)
    80003966:	0127f463          	bgeu	a5,s2,8000396e <writei+0xca>
    ip->size = off;
    8000396a:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000396e:	8556                	mv	a0,s5
    80003970:	a13ff0ef          	jal	ra,80003382 <iupdate>

  return tot;
    80003974:	0009851b          	sext.w	a0,s3
}
    80003978:	70a6                	ld	ra,104(sp)
    8000397a:	7406                	ld	s0,96(sp)
    8000397c:	64e6                	ld	s1,88(sp)
    8000397e:	6946                	ld	s2,80(sp)
    80003980:	69a6                	ld	s3,72(sp)
    80003982:	6a06                	ld	s4,64(sp)
    80003984:	7ae2                	ld	s5,56(sp)
    80003986:	7b42                	ld	s6,48(sp)
    80003988:	7ba2                	ld	s7,40(sp)
    8000398a:	7c02                	ld	s8,32(sp)
    8000398c:	6ce2                	ld	s9,24(sp)
    8000398e:	6d42                	ld	s10,16(sp)
    80003990:	6da2                	ld	s11,8(sp)
    80003992:	6165                	addi	sp,sp,112
    80003994:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003996:	89da                	mv	s3,s6
    80003998:	bfd9                	j	8000396e <writei+0xca>
    return -1;
    8000399a:	557d                	li	a0,-1
}
    8000399c:	8082                	ret
    return -1;
    8000399e:	557d                	li	a0,-1
    800039a0:	bfe1                	j	80003978 <writei+0xd4>
    return -1;
    800039a2:	557d                	li	a0,-1
    800039a4:	bfd1                	j	80003978 <writei+0xd4>

00000000800039a6 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800039a6:	1141                	addi	sp,sp,-16
    800039a8:	e406                	sd	ra,8(sp)
    800039aa:	e022                	sd	s0,0(sp)
    800039ac:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800039ae:	4639                	li	a2,14
    800039b0:	b5cfd0ef          	jal	ra,80000d0c <strncmp>
}
    800039b4:	60a2                	ld	ra,8(sp)
    800039b6:	6402                	ld	s0,0(sp)
    800039b8:	0141                	addi	sp,sp,16
    800039ba:	8082                	ret

00000000800039bc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800039bc:	7139                	addi	sp,sp,-64
    800039be:	fc06                	sd	ra,56(sp)
    800039c0:	f822                	sd	s0,48(sp)
    800039c2:	f426                	sd	s1,40(sp)
    800039c4:	f04a                	sd	s2,32(sp)
    800039c6:	ec4e                	sd	s3,24(sp)
    800039c8:	e852                	sd	s4,16(sp)
    800039ca:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800039cc:	04451703          	lh	a4,68(a0)
    800039d0:	4785                	li	a5,1
    800039d2:	00f71a63          	bne	a4,a5,800039e6 <dirlookup+0x2a>
    800039d6:	892a                	mv	s2,a0
    800039d8:	89ae                	mv	s3,a1
    800039da:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800039dc:	457c                	lw	a5,76(a0)
    800039de:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800039e0:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800039e2:	e39d                	bnez	a5,80003a08 <dirlookup+0x4c>
    800039e4:	a095                	j	80003a48 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    800039e6:	00004517          	auipc	a0,0x4
    800039ea:	db250513          	addi	a0,a0,-590 # 80007798 <syscalls+0x1c0>
    800039ee:	d9dfc0ef          	jal	ra,8000078a <panic>
      panic("dirlookup read");
    800039f2:	00004517          	auipc	a0,0x4
    800039f6:	dbe50513          	addi	a0,a0,-578 # 800077b0 <syscalls+0x1d8>
    800039fa:	d91fc0ef          	jal	ra,8000078a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800039fe:	24c1                	addiw	s1,s1,16
    80003a00:	04c92783          	lw	a5,76(s2)
    80003a04:	04f4f163          	bgeu	s1,a5,80003a46 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a08:	4741                	li	a4,16
    80003a0a:	86a6                	mv	a3,s1
    80003a0c:	fc040613          	addi	a2,s0,-64
    80003a10:	4581                	li	a1,0
    80003a12:	854a                	mv	a0,s2
    80003a14:	dadff0ef          	jal	ra,800037c0 <readi>
    80003a18:	47c1                	li	a5,16
    80003a1a:	fcf51ce3          	bne	a0,a5,800039f2 <dirlookup+0x36>
    if(de.inum == 0)
    80003a1e:	fc045783          	lhu	a5,-64(s0)
    80003a22:	dff1                	beqz	a5,800039fe <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003a24:	fc240593          	addi	a1,s0,-62
    80003a28:	854e                	mv	a0,s3
    80003a2a:	f7dff0ef          	jal	ra,800039a6 <namecmp>
    80003a2e:	f961                	bnez	a0,800039fe <dirlookup+0x42>
      if(poff)
    80003a30:	000a0463          	beqz	s4,80003a38 <dirlookup+0x7c>
        *poff = off;
    80003a34:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003a38:	fc045583          	lhu	a1,-64(s0)
    80003a3c:	00092503          	lw	a0,0(s2)
    80003a40:	f88ff0ef          	jal	ra,800031c8 <iget>
    80003a44:	a011                	j	80003a48 <dirlookup+0x8c>
  return 0;
    80003a46:	4501                	li	a0,0
}
    80003a48:	70e2                	ld	ra,56(sp)
    80003a4a:	7442                	ld	s0,48(sp)
    80003a4c:	74a2                	ld	s1,40(sp)
    80003a4e:	7902                	ld	s2,32(sp)
    80003a50:	69e2                	ld	s3,24(sp)
    80003a52:	6a42                	ld	s4,16(sp)
    80003a54:	6121                	addi	sp,sp,64
    80003a56:	8082                	ret

0000000080003a58 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003a58:	711d                	addi	sp,sp,-96
    80003a5a:	ec86                	sd	ra,88(sp)
    80003a5c:	e8a2                	sd	s0,80(sp)
    80003a5e:	e4a6                	sd	s1,72(sp)
    80003a60:	e0ca                	sd	s2,64(sp)
    80003a62:	fc4e                	sd	s3,56(sp)
    80003a64:	f852                	sd	s4,48(sp)
    80003a66:	f456                	sd	s5,40(sp)
    80003a68:	f05a                	sd	s6,32(sp)
    80003a6a:	ec5e                	sd	s7,24(sp)
    80003a6c:	e862                	sd	s8,16(sp)
    80003a6e:	e466                	sd	s9,8(sp)
    80003a70:	1080                	addi	s0,sp,96
    80003a72:	84aa                	mv	s1,a0
    80003a74:	8aae                	mv	s5,a1
    80003a76:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003a78:	00054703          	lbu	a4,0(a0)
    80003a7c:	02f00793          	li	a5,47
    80003a80:	00f70f63          	beq	a4,a5,80003a9e <namex+0x46>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003a84:	8aefe0ef          	jal	ra,80001b32 <myproc>
    80003a88:	15053503          	ld	a0,336(a0)
    80003a8c:	973ff0ef          	jal	ra,800033fe <idup>
    80003a90:	89aa                	mv	s3,a0
  while(*path == '/')
    80003a92:	02f00913          	li	s2,47
  len = path - s;
    80003a96:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003a98:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003a9a:	4b85                	li	s7,1
    80003a9c:	a861                	j	80003b34 <namex+0xdc>
    ip = iget(ROOTDEV, ROOTINO);
    80003a9e:	4585                	li	a1,1
    80003aa0:	4505                	li	a0,1
    80003aa2:	f26ff0ef          	jal	ra,800031c8 <iget>
    80003aa6:	89aa                	mv	s3,a0
    80003aa8:	b7ed                	j	80003a92 <namex+0x3a>
      iunlockput(ip);
    80003aaa:	854e                	mv	a0,s3
    80003aac:	b8fff0ef          	jal	ra,8000363a <iunlockput>
      return 0;
    80003ab0:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003ab2:	854e                	mv	a0,s3
    80003ab4:	60e6                	ld	ra,88(sp)
    80003ab6:	6446                	ld	s0,80(sp)
    80003ab8:	64a6                	ld	s1,72(sp)
    80003aba:	6906                	ld	s2,64(sp)
    80003abc:	79e2                	ld	s3,56(sp)
    80003abe:	7a42                	ld	s4,48(sp)
    80003ac0:	7aa2                	ld	s5,40(sp)
    80003ac2:	7b02                	ld	s6,32(sp)
    80003ac4:	6be2                	ld	s7,24(sp)
    80003ac6:	6c42                	ld	s8,16(sp)
    80003ac8:	6ca2                	ld	s9,8(sp)
    80003aca:	6125                	addi	sp,sp,96
    80003acc:	8082                	ret
      iunlock(ip);
    80003ace:	854e                	mv	a0,s3
    80003ad0:	a0fff0ef          	jal	ra,800034de <iunlock>
      return ip;
    80003ad4:	bff9                	j	80003ab2 <namex+0x5a>
      iunlockput(ip);
    80003ad6:	854e                	mv	a0,s3
    80003ad8:	b63ff0ef          	jal	ra,8000363a <iunlockput>
      return 0;
    80003adc:	89e6                	mv	s3,s9
    80003ade:	bfd1                	j	80003ab2 <namex+0x5a>
  len = path - s;
    80003ae0:	40b48633          	sub	a2,s1,a1
    80003ae4:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003ae8:	079c5c63          	bge	s8,s9,80003b60 <namex+0x108>
    memmove(name, s, DIRSIZ);
    80003aec:	4639                	li	a2,14
    80003aee:	8552                	mv	a0,s4
    80003af0:	9acfd0ef          	jal	ra,80000c9c <memmove>
  while(*path == '/')
    80003af4:	0004c783          	lbu	a5,0(s1)
    80003af8:	01279763          	bne	a5,s2,80003b06 <namex+0xae>
    path++;
    80003afc:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003afe:	0004c783          	lbu	a5,0(s1)
    80003b02:	ff278de3          	beq	a5,s2,80003afc <namex+0xa4>
    ilock(ip);
    80003b06:	854e                	mv	a0,s3
    80003b08:	92dff0ef          	jal	ra,80003434 <ilock>
    if(ip->type != T_DIR){
    80003b0c:	04499783          	lh	a5,68(s3)
    80003b10:	f9779de3          	bne	a5,s7,80003aaa <namex+0x52>
    if(nameiparent && *path == '\0'){
    80003b14:	000a8563          	beqz	s5,80003b1e <namex+0xc6>
    80003b18:	0004c783          	lbu	a5,0(s1)
    80003b1c:	dbcd                	beqz	a5,80003ace <namex+0x76>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003b1e:	865a                	mv	a2,s6
    80003b20:	85d2                	mv	a1,s4
    80003b22:	854e                	mv	a0,s3
    80003b24:	e99ff0ef          	jal	ra,800039bc <dirlookup>
    80003b28:	8caa                	mv	s9,a0
    80003b2a:	d555                	beqz	a0,80003ad6 <namex+0x7e>
    iunlockput(ip);
    80003b2c:	854e                	mv	a0,s3
    80003b2e:	b0dff0ef          	jal	ra,8000363a <iunlockput>
    ip = next;
    80003b32:	89e6                	mv	s3,s9
  while(*path == '/')
    80003b34:	0004c783          	lbu	a5,0(s1)
    80003b38:	05279363          	bne	a5,s2,80003b7e <namex+0x126>
    path++;
    80003b3c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003b3e:	0004c783          	lbu	a5,0(s1)
    80003b42:	ff278de3          	beq	a5,s2,80003b3c <namex+0xe4>
  if(*path == 0)
    80003b46:	c78d                	beqz	a5,80003b70 <namex+0x118>
    path++;
    80003b48:	85a6                	mv	a1,s1
  len = path - s;
    80003b4a:	8cda                	mv	s9,s6
    80003b4c:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003b4e:	01278963          	beq	a5,s2,80003b60 <namex+0x108>
    80003b52:	d7d9                	beqz	a5,80003ae0 <namex+0x88>
    path++;
    80003b54:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003b56:	0004c783          	lbu	a5,0(s1)
    80003b5a:	ff279ce3          	bne	a5,s2,80003b52 <namex+0xfa>
    80003b5e:	b749                	j	80003ae0 <namex+0x88>
    memmove(name, s, len);
    80003b60:	2601                	sext.w	a2,a2
    80003b62:	8552                	mv	a0,s4
    80003b64:	938fd0ef          	jal	ra,80000c9c <memmove>
    name[len] = 0;
    80003b68:	9cd2                	add	s9,s9,s4
    80003b6a:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003b6e:	b759                	j	80003af4 <namex+0x9c>
  if(nameiparent){
    80003b70:	f40a81e3          	beqz	s5,80003ab2 <namex+0x5a>
    iput(ip);
    80003b74:	854e                	mv	a0,s3
    80003b76:	a3dff0ef          	jal	ra,800035b2 <iput>
    return 0;
    80003b7a:	4981                	li	s3,0
    80003b7c:	bf1d                	j	80003ab2 <namex+0x5a>
  if(*path == 0)
    80003b7e:	dbed                	beqz	a5,80003b70 <namex+0x118>
  while(*path != '/' && *path != 0)
    80003b80:	0004c783          	lbu	a5,0(s1)
    80003b84:	85a6                	mv	a1,s1
    80003b86:	b7f1                	j	80003b52 <namex+0xfa>

0000000080003b88 <dirlink>:
{
    80003b88:	7139                	addi	sp,sp,-64
    80003b8a:	fc06                	sd	ra,56(sp)
    80003b8c:	f822                	sd	s0,48(sp)
    80003b8e:	f426                	sd	s1,40(sp)
    80003b90:	f04a                	sd	s2,32(sp)
    80003b92:	ec4e                	sd	s3,24(sp)
    80003b94:	e852                	sd	s4,16(sp)
    80003b96:	0080                	addi	s0,sp,64
    80003b98:	892a                	mv	s2,a0
    80003b9a:	8a2e                	mv	s4,a1
    80003b9c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003b9e:	4601                	li	a2,0
    80003ba0:	e1dff0ef          	jal	ra,800039bc <dirlookup>
    80003ba4:	e52d                	bnez	a0,80003c0e <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ba6:	04c92483          	lw	s1,76(s2)
    80003baa:	c48d                	beqz	s1,80003bd4 <dirlink+0x4c>
    80003bac:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bae:	4741                	li	a4,16
    80003bb0:	86a6                	mv	a3,s1
    80003bb2:	fc040613          	addi	a2,s0,-64
    80003bb6:	4581                	li	a1,0
    80003bb8:	854a                	mv	a0,s2
    80003bba:	c07ff0ef          	jal	ra,800037c0 <readi>
    80003bbe:	47c1                	li	a5,16
    80003bc0:	04f51b63          	bne	a0,a5,80003c16 <dirlink+0x8e>
    if(de.inum == 0)
    80003bc4:	fc045783          	lhu	a5,-64(s0)
    80003bc8:	c791                	beqz	a5,80003bd4 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bca:	24c1                	addiw	s1,s1,16
    80003bcc:	04c92783          	lw	a5,76(s2)
    80003bd0:	fcf4efe3          	bltu	s1,a5,80003bae <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003bd4:	4639                	li	a2,14
    80003bd6:	85d2                	mv	a1,s4
    80003bd8:	fc240513          	addi	a0,s0,-62
    80003bdc:	96cfd0ef          	jal	ra,80000d48 <strncpy>
  de.inum = inum;
    80003be0:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003be4:	4741                	li	a4,16
    80003be6:	86a6                	mv	a3,s1
    80003be8:	fc040613          	addi	a2,s0,-64
    80003bec:	4581                	li	a1,0
    80003bee:	854a                	mv	a0,s2
    80003bf0:	cb5ff0ef          	jal	ra,800038a4 <writei>
    80003bf4:	1541                	addi	a0,a0,-16
    80003bf6:	00a03533          	snez	a0,a0
    80003bfa:	40a00533          	neg	a0,a0
}
    80003bfe:	70e2                	ld	ra,56(sp)
    80003c00:	7442                	ld	s0,48(sp)
    80003c02:	74a2                	ld	s1,40(sp)
    80003c04:	7902                	ld	s2,32(sp)
    80003c06:	69e2                	ld	s3,24(sp)
    80003c08:	6a42                	ld	s4,16(sp)
    80003c0a:	6121                	addi	sp,sp,64
    80003c0c:	8082                	ret
    iput(ip);
    80003c0e:	9a5ff0ef          	jal	ra,800035b2 <iput>
    return -1;
    80003c12:	557d                	li	a0,-1
    80003c14:	b7ed                	j	80003bfe <dirlink+0x76>
      panic("dirlink read");
    80003c16:	00004517          	auipc	a0,0x4
    80003c1a:	baa50513          	addi	a0,a0,-1110 # 800077c0 <syscalls+0x1e8>
    80003c1e:	b6dfc0ef          	jal	ra,8000078a <panic>

0000000080003c22 <namei>:

struct inode*
namei(char *path)
{
    80003c22:	1101                	addi	sp,sp,-32
    80003c24:	ec06                	sd	ra,24(sp)
    80003c26:	e822                	sd	s0,16(sp)
    80003c28:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003c2a:	fe040613          	addi	a2,s0,-32
    80003c2e:	4581                	li	a1,0
    80003c30:	e29ff0ef          	jal	ra,80003a58 <namex>
}
    80003c34:	60e2                	ld	ra,24(sp)
    80003c36:	6442                	ld	s0,16(sp)
    80003c38:	6105                	addi	sp,sp,32
    80003c3a:	8082                	ret

0000000080003c3c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003c3c:	1141                	addi	sp,sp,-16
    80003c3e:	e406                	sd	ra,8(sp)
    80003c40:	e022                	sd	s0,0(sp)
    80003c42:	0800                	addi	s0,sp,16
    80003c44:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003c46:	4585                	li	a1,1
    80003c48:	e11ff0ef          	jal	ra,80003a58 <namex>
}
    80003c4c:	60a2                	ld	ra,8(sp)
    80003c4e:	6402                	ld	s0,0(sp)
    80003c50:	0141                	addi	sp,sp,16
    80003c52:	8082                	ret

0000000080003c54 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003c54:	1101                	addi	sp,sp,-32
    80003c56:	ec06                	sd	ra,24(sp)
    80003c58:	e822                	sd	s0,16(sp)
    80003c5a:	e426                	sd	s1,8(sp)
    80003c5c:	e04a                	sd	s2,0(sp)
    80003c5e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003c60:	0001d917          	auipc	s2,0x1d
    80003c64:	58890913          	addi	s2,s2,1416 # 800211e8 <log>
    80003c68:	01892583          	lw	a1,24(s2)
    80003c6c:	02492503          	lw	a0,36(s2)
    80003c70:	912ff0ef          	jal	ra,80002d82 <bread>
    80003c74:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003c76:	02892683          	lw	a3,40(s2)
    80003c7a:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003c7c:	02d05763          	blez	a3,80003caa <write_head+0x56>
    80003c80:	0001d797          	auipc	a5,0x1d
    80003c84:	59478793          	addi	a5,a5,1428 # 80021214 <log+0x2c>
    80003c88:	05c50713          	addi	a4,a0,92
    80003c8c:	36fd                	addiw	a3,a3,-1
    80003c8e:	1682                	slli	a3,a3,0x20
    80003c90:	9281                	srli	a3,a3,0x20
    80003c92:	068a                	slli	a3,a3,0x2
    80003c94:	0001d617          	auipc	a2,0x1d
    80003c98:	58460613          	addi	a2,a2,1412 # 80021218 <log+0x30>
    80003c9c:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003c9e:	4390                	lw	a2,0(a5)
    80003ca0:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003ca2:	0791                	addi	a5,a5,4
    80003ca4:	0711                	addi	a4,a4,4
    80003ca6:	fed79ce3          	bne	a5,a3,80003c9e <write_head+0x4a>
  }
  bwrite(buf);
    80003caa:	8526                	mv	a0,s1
    80003cac:	9acff0ef          	jal	ra,80002e58 <bwrite>
  brelse(buf);
    80003cb0:	8526                	mv	a0,s1
    80003cb2:	9d8ff0ef          	jal	ra,80002e8a <brelse>
}
    80003cb6:	60e2                	ld	ra,24(sp)
    80003cb8:	6442                	ld	s0,16(sp)
    80003cba:	64a2                	ld	s1,8(sp)
    80003cbc:	6902                	ld	s2,0(sp)
    80003cbe:	6105                	addi	sp,sp,32
    80003cc0:	8082                	ret

0000000080003cc2 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cc2:	0001d797          	auipc	a5,0x1d
    80003cc6:	54e7a783          	lw	a5,1358(a5) # 80021210 <log+0x28>
    80003cca:	0af05e63          	blez	a5,80003d86 <install_trans+0xc4>
{
    80003cce:	715d                	addi	sp,sp,-80
    80003cd0:	e486                	sd	ra,72(sp)
    80003cd2:	e0a2                	sd	s0,64(sp)
    80003cd4:	fc26                	sd	s1,56(sp)
    80003cd6:	f84a                	sd	s2,48(sp)
    80003cd8:	f44e                	sd	s3,40(sp)
    80003cda:	f052                	sd	s4,32(sp)
    80003cdc:	ec56                	sd	s5,24(sp)
    80003cde:	e85a                	sd	s6,16(sp)
    80003ce0:	e45e                	sd	s7,8(sp)
    80003ce2:	0880                	addi	s0,sp,80
    80003ce4:	8b2a                	mv	s6,a0
    80003ce6:	0001da97          	auipc	s5,0x1d
    80003cea:	52ea8a93          	addi	s5,s5,1326 # 80021214 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cee:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003cf0:	00004b97          	auipc	s7,0x4
    80003cf4:	ae0b8b93          	addi	s7,s7,-1312 # 800077d0 <syscalls+0x1f8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003cf8:	0001da17          	auipc	s4,0x1d
    80003cfc:	4f0a0a13          	addi	s4,s4,1264 # 800211e8 <log>
    80003d00:	a025                	j	80003d28 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d02:	000aa603          	lw	a2,0(s5)
    80003d06:	85ce                	mv	a1,s3
    80003d08:	855e                	mv	a0,s7
    80003d0a:	fbafc0ef          	jal	ra,800004c4 <printf>
    80003d0e:	a839                	j	80003d2c <install_trans+0x6a>
    brelse(lbuf);
    80003d10:	854a                	mv	a0,s2
    80003d12:	978ff0ef          	jal	ra,80002e8a <brelse>
    brelse(dbuf);
    80003d16:	8526                	mv	a0,s1
    80003d18:	972ff0ef          	jal	ra,80002e8a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d1c:	2985                	addiw	s3,s3,1
    80003d1e:	0a91                	addi	s5,s5,4
    80003d20:	028a2783          	lw	a5,40(s4)
    80003d24:	04f9d663          	bge	s3,a5,80003d70 <install_trans+0xae>
    if(recovering) {
    80003d28:	fc0b1de3          	bnez	s6,80003d02 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003d2c:	018a2583          	lw	a1,24(s4)
    80003d30:	013585bb          	addw	a1,a1,s3
    80003d34:	2585                	addiw	a1,a1,1
    80003d36:	024a2503          	lw	a0,36(s4)
    80003d3a:	848ff0ef          	jal	ra,80002d82 <bread>
    80003d3e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003d40:	000aa583          	lw	a1,0(s5)
    80003d44:	024a2503          	lw	a0,36(s4)
    80003d48:	83aff0ef          	jal	ra,80002d82 <bread>
    80003d4c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003d4e:	40000613          	li	a2,1024
    80003d52:	05890593          	addi	a1,s2,88
    80003d56:	05850513          	addi	a0,a0,88
    80003d5a:	f43fc0ef          	jal	ra,80000c9c <memmove>
    bwrite(dbuf);  // write dst to disk
    80003d5e:	8526                	mv	a0,s1
    80003d60:	8f8ff0ef          	jal	ra,80002e58 <bwrite>
    if(recovering == 0)
    80003d64:	fa0b16e3          	bnez	s6,80003d10 <install_trans+0x4e>
      bunpin(dbuf);
    80003d68:	8526                	mv	a0,s1
    80003d6a:	9deff0ef          	jal	ra,80002f48 <bunpin>
    80003d6e:	b74d                	j	80003d10 <install_trans+0x4e>
}
    80003d70:	60a6                	ld	ra,72(sp)
    80003d72:	6406                	ld	s0,64(sp)
    80003d74:	74e2                	ld	s1,56(sp)
    80003d76:	7942                	ld	s2,48(sp)
    80003d78:	79a2                	ld	s3,40(sp)
    80003d7a:	7a02                	ld	s4,32(sp)
    80003d7c:	6ae2                	ld	s5,24(sp)
    80003d7e:	6b42                	ld	s6,16(sp)
    80003d80:	6ba2                	ld	s7,8(sp)
    80003d82:	6161                	addi	sp,sp,80
    80003d84:	8082                	ret
    80003d86:	8082                	ret

0000000080003d88 <initlog>:
{
    80003d88:	7179                	addi	sp,sp,-48
    80003d8a:	f406                	sd	ra,40(sp)
    80003d8c:	f022                	sd	s0,32(sp)
    80003d8e:	ec26                	sd	s1,24(sp)
    80003d90:	e84a                	sd	s2,16(sp)
    80003d92:	e44e                	sd	s3,8(sp)
    80003d94:	1800                	addi	s0,sp,48
    80003d96:	892a                	mv	s2,a0
    80003d98:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003d9a:	0001d497          	auipc	s1,0x1d
    80003d9e:	44e48493          	addi	s1,s1,1102 # 800211e8 <log>
    80003da2:	00004597          	auipc	a1,0x4
    80003da6:	a4e58593          	addi	a1,a1,-1458 # 800077f0 <syscalls+0x218>
    80003daa:	8526                	mv	a0,s1
    80003dac:	d41fc0ef          	jal	ra,80000aec <initlock>
  log.start = sb->logstart;
    80003db0:	0149a583          	lw	a1,20(s3)
    80003db4:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003db6:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003dba:	854a                	mv	a0,s2
    80003dbc:	fc7fe0ef          	jal	ra,80002d82 <bread>
  log.lh.n = lh->n;
    80003dc0:	4d34                	lw	a3,88(a0)
    80003dc2:	d494                	sw	a3,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003dc4:	02d05563          	blez	a3,80003dee <initlog+0x66>
    80003dc8:	05c50793          	addi	a5,a0,92
    80003dcc:	0001d717          	auipc	a4,0x1d
    80003dd0:	44870713          	addi	a4,a4,1096 # 80021214 <log+0x2c>
    80003dd4:	36fd                	addiw	a3,a3,-1
    80003dd6:	1682                	slli	a3,a3,0x20
    80003dd8:	9281                	srli	a3,a3,0x20
    80003dda:	068a                	slli	a3,a3,0x2
    80003ddc:	06050613          	addi	a2,a0,96
    80003de0:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80003de2:	4390                	lw	a2,0(a5)
    80003de4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003de6:	0791                	addi	a5,a5,4
    80003de8:	0711                	addi	a4,a4,4
    80003dea:	fed79ce3          	bne	a5,a3,80003de2 <initlog+0x5a>
  brelse(buf);
    80003dee:	89cff0ef          	jal	ra,80002e8a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003df2:	4505                	li	a0,1
    80003df4:	ecfff0ef          	jal	ra,80003cc2 <install_trans>
  log.lh.n = 0;
    80003df8:	0001d797          	auipc	a5,0x1d
    80003dfc:	4007ac23          	sw	zero,1048(a5) # 80021210 <log+0x28>
  write_head(); // clear the log
    80003e00:	e55ff0ef          	jal	ra,80003c54 <write_head>
}
    80003e04:	70a2                	ld	ra,40(sp)
    80003e06:	7402                	ld	s0,32(sp)
    80003e08:	64e2                	ld	s1,24(sp)
    80003e0a:	6942                	ld	s2,16(sp)
    80003e0c:	69a2                	ld	s3,8(sp)
    80003e0e:	6145                	addi	sp,sp,48
    80003e10:	8082                	ret

0000000080003e12 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003e12:	1101                	addi	sp,sp,-32
    80003e14:	ec06                	sd	ra,24(sp)
    80003e16:	e822                	sd	s0,16(sp)
    80003e18:	e426                	sd	s1,8(sp)
    80003e1a:	e04a                	sd	s2,0(sp)
    80003e1c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003e1e:	0001d517          	auipc	a0,0x1d
    80003e22:	3ca50513          	addi	a0,a0,970 # 800211e8 <log>
    80003e26:	d47fc0ef          	jal	ra,80000b6c <acquire>
  while(1){
    if(log.committing){
    80003e2a:	0001d497          	auipc	s1,0x1d
    80003e2e:	3be48493          	addi	s1,s1,958 # 800211e8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003e32:	4979                	li	s2,30
    80003e34:	a029                	j	80003e3e <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003e36:	85a6                	mv	a1,s1
    80003e38:	8526                	mv	a0,s1
    80003e3a:	b1afe0ef          	jal	ra,80002154 <sleep>
    if(log.committing){
    80003e3e:	509c                	lw	a5,32(s1)
    80003e40:	fbfd                	bnez	a5,80003e36 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003e42:	4cdc                	lw	a5,28(s1)
    80003e44:	0017871b          	addiw	a4,a5,1
    80003e48:	0007069b          	sext.w	a3,a4
    80003e4c:	0027179b          	slliw	a5,a4,0x2
    80003e50:	9fb9                	addw	a5,a5,a4
    80003e52:	0017979b          	slliw	a5,a5,0x1
    80003e56:	5498                	lw	a4,40(s1)
    80003e58:	9fb9                	addw	a5,a5,a4
    80003e5a:	00f95763          	bge	s2,a5,80003e68 <begin_op+0x56>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003e5e:	85a6                	mv	a1,s1
    80003e60:	8526                	mv	a0,s1
    80003e62:	af2fe0ef          	jal	ra,80002154 <sleep>
    80003e66:	bfe1                	j	80003e3e <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003e68:	0001d517          	auipc	a0,0x1d
    80003e6c:	38050513          	addi	a0,a0,896 # 800211e8 <log>
    80003e70:	cd54                	sw	a3,28(a0)
      release(&log.lock);
    80003e72:	d93fc0ef          	jal	ra,80000c04 <release>
      break;
    }
  }
}
    80003e76:	60e2                	ld	ra,24(sp)
    80003e78:	6442                	ld	s0,16(sp)
    80003e7a:	64a2                	ld	s1,8(sp)
    80003e7c:	6902                	ld	s2,0(sp)
    80003e7e:	6105                	addi	sp,sp,32
    80003e80:	8082                	ret

0000000080003e82 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003e82:	7139                	addi	sp,sp,-64
    80003e84:	fc06                	sd	ra,56(sp)
    80003e86:	f822                	sd	s0,48(sp)
    80003e88:	f426                	sd	s1,40(sp)
    80003e8a:	f04a                	sd	s2,32(sp)
    80003e8c:	ec4e                	sd	s3,24(sp)
    80003e8e:	e852                	sd	s4,16(sp)
    80003e90:	e456                	sd	s5,8(sp)
    80003e92:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003e94:	0001d497          	auipc	s1,0x1d
    80003e98:	35448493          	addi	s1,s1,852 # 800211e8 <log>
    80003e9c:	8526                	mv	a0,s1
    80003e9e:	ccffc0ef          	jal	ra,80000b6c <acquire>
  log.outstanding -= 1;
    80003ea2:	4cdc                	lw	a5,28(s1)
    80003ea4:	37fd                	addiw	a5,a5,-1
    80003ea6:	0007891b          	sext.w	s2,a5
    80003eaa:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003eac:	509c                	lw	a5,32(s1)
    80003eae:	ef9d                	bnez	a5,80003eec <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    80003eb0:	04091463          	bnez	s2,80003ef8 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003eb4:	0001d497          	auipc	s1,0x1d
    80003eb8:	33448493          	addi	s1,s1,820 # 800211e8 <log>
    80003ebc:	4785                	li	a5,1
    80003ebe:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003ec0:	8526                	mv	a0,s1
    80003ec2:	d43fc0ef          	jal	ra,80000c04 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003ec6:	549c                	lw	a5,40(s1)
    80003ec8:	04f04b63          	bgtz	a5,80003f1e <end_op+0x9c>
    acquire(&log.lock);
    80003ecc:	0001d497          	auipc	s1,0x1d
    80003ed0:	31c48493          	addi	s1,s1,796 # 800211e8 <log>
    80003ed4:	8526                	mv	a0,s1
    80003ed6:	c97fc0ef          	jal	ra,80000b6c <acquire>
    log.committing = 0;
    80003eda:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003ede:	8526                	mv	a0,s1
    80003ee0:	ac0fe0ef          	jal	ra,800021a0 <wakeup>
    release(&log.lock);
    80003ee4:	8526                	mv	a0,s1
    80003ee6:	d1ffc0ef          	jal	ra,80000c04 <release>
}
    80003eea:	a00d                	j	80003f0c <end_op+0x8a>
    panic("log.committing");
    80003eec:	00004517          	auipc	a0,0x4
    80003ef0:	90c50513          	addi	a0,a0,-1780 # 800077f8 <syscalls+0x220>
    80003ef4:	897fc0ef          	jal	ra,8000078a <panic>
    wakeup(&log);
    80003ef8:	0001d497          	auipc	s1,0x1d
    80003efc:	2f048493          	addi	s1,s1,752 # 800211e8 <log>
    80003f00:	8526                	mv	a0,s1
    80003f02:	a9efe0ef          	jal	ra,800021a0 <wakeup>
  release(&log.lock);
    80003f06:	8526                	mv	a0,s1
    80003f08:	cfdfc0ef          	jal	ra,80000c04 <release>
}
    80003f0c:	70e2                	ld	ra,56(sp)
    80003f0e:	7442                	ld	s0,48(sp)
    80003f10:	74a2                	ld	s1,40(sp)
    80003f12:	7902                	ld	s2,32(sp)
    80003f14:	69e2                	ld	s3,24(sp)
    80003f16:	6a42                	ld	s4,16(sp)
    80003f18:	6aa2                	ld	s5,8(sp)
    80003f1a:	6121                	addi	sp,sp,64
    80003f1c:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f1e:	0001da97          	auipc	s5,0x1d
    80003f22:	2f6a8a93          	addi	s5,s5,758 # 80021214 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003f26:	0001da17          	auipc	s4,0x1d
    80003f2a:	2c2a0a13          	addi	s4,s4,706 # 800211e8 <log>
    80003f2e:	018a2583          	lw	a1,24(s4)
    80003f32:	012585bb          	addw	a1,a1,s2
    80003f36:	2585                	addiw	a1,a1,1
    80003f38:	024a2503          	lw	a0,36(s4)
    80003f3c:	e47fe0ef          	jal	ra,80002d82 <bread>
    80003f40:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003f42:	000aa583          	lw	a1,0(s5)
    80003f46:	024a2503          	lw	a0,36(s4)
    80003f4a:	e39fe0ef          	jal	ra,80002d82 <bread>
    80003f4e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003f50:	40000613          	li	a2,1024
    80003f54:	05850593          	addi	a1,a0,88
    80003f58:	05848513          	addi	a0,s1,88
    80003f5c:	d41fc0ef          	jal	ra,80000c9c <memmove>
    bwrite(to);  // write the log
    80003f60:	8526                	mv	a0,s1
    80003f62:	ef7fe0ef          	jal	ra,80002e58 <bwrite>
    brelse(from);
    80003f66:	854e                	mv	a0,s3
    80003f68:	f23fe0ef          	jal	ra,80002e8a <brelse>
    brelse(to);
    80003f6c:	8526                	mv	a0,s1
    80003f6e:	f1dfe0ef          	jal	ra,80002e8a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f72:	2905                	addiw	s2,s2,1
    80003f74:	0a91                	addi	s5,s5,4
    80003f76:	028a2783          	lw	a5,40(s4)
    80003f7a:	faf94ae3          	blt	s2,a5,80003f2e <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003f7e:	cd7ff0ef          	jal	ra,80003c54 <write_head>
    install_trans(0); // Now install writes to home locations
    80003f82:	4501                	li	a0,0
    80003f84:	d3fff0ef          	jal	ra,80003cc2 <install_trans>
    log.lh.n = 0;
    80003f88:	0001d797          	auipc	a5,0x1d
    80003f8c:	2807a423          	sw	zero,648(a5) # 80021210 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003f90:	cc5ff0ef          	jal	ra,80003c54 <write_head>
    80003f94:	bf25                	j	80003ecc <end_op+0x4a>

0000000080003f96 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003f96:	1101                	addi	sp,sp,-32
    80003f98:	ec06                	sd	ra,24(sp)
    80003f9a:	e822                	sd	s0,16(sp)
    80003f9c:	e426                	sd	s1,8(sp)
    80003f9e:	e04a                	sd	s2,0(sp)
    80003fa0:	1000                	addi	s0,sp,32
    80003fa2:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003fa4:	0001d917          	auipc	s2,0x1d
    80003fa8:	24490913          	addi	s2,s2,580 # 800211e8 <log>
    80003fac:	854a                	mv	a0,s2
    80003fae:	bbffc0ef          	jal	ra,80000b6c <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003fb2:	02892603          	lw	a2,40(s2)
    80003fb6:	47f5                	li	a5,29
    80003fb8:	04c7cc63          	blt	a5,a2,80004010 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003fbc:	0001d797          	auipc	a5,0x1d
    80003fc0:	2487a783          	lw	a5,584(a5) # 80021204 <log+0x1c>
    80003fc4:	04f05c63          	blez	a5,8000401c <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003fc8:	4781                	li	a5,0
    80003fca:	04c05f63          	blez	a2,80004028 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003fce:	44cc                	lw	a1,12(s1)
    80003fd0:	0001d717          	auipc	a4,0x1d
    80003fd4:	24470713          	addi	a4,a4,580 # 80021214 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003fd8:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003fda:	4314                	lw	a3,0(a4)
    80003fdc:	04b68663          	beq	a3,a1,80004028 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003fe0:	2785                	addiw	a5,a5,1
    80003fe2:	0711                	addi	a4,a4,4
    80003fe4:	fef61be3          	bne	a2,a5,80003fda <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003fe8:	0621                	addi	a2,a2,8
    80003fea:	060a                	slli	a2,a2,0x2
    80003fec:	0001d797          	auipc	a5,0x1d
    80003ff0:	1fc78793          	addi	a5,a5,508 # 800211e8 <log>
    80003ff4:	963e                	add	a2,a2,a5
    80003ff6:	44dc                	lw	a5,12(s1)
    80003ff8:	c65c                	sw	a5,12(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003ffa:	8526                	mv	a0,s1
    80003ffc:	f19fe0ef          	jal	ra,80002f14 <bpin>
    log.lh.n++;
    80004000:	0001d717          	auipc	a4,0x1d
    80004004:	1e870713          	addi	a4,a4,488 # 800211e8 <log>
    80004008:	571c                	lw	a5,40(a4)
    8000400a:	2785                	addiw	a5,a5,1
    8000400c:	d71c                	sw	a5,40(a4)
    8000400e:	a815                	j	80004042 <log_write+0xac>
    panic("too big a transaction");
    80004010:	00003517          	auipc	a0,0x3
    80004014:	7f850513          	addi	a0,a0,2040 # 80007808 <syscalls+0x230>
    80004018:	f72fc0ef          	jal	ra,8000078a <panic>
    panic("log_write outside of trans");
    8000401c:	00004517          	auipc	a0,0x4
    80004020:	80450513          	addi	a0,a0,-2044 # 80007820 <syscalls+0x248>
    80004024:	f66fc0ef          	jal	ra,8000078a <panic>
  log.lh.block[i] = b->blockno;
    80004028:	00878713          	addi	a4,a5,8
    8000402c:	00271693          	slli	a3,a4,0x2
    80004030:	0001d717          	auipc	a4,0x1d
    80004034:	1b870713          	addi	a4,a4,440 # 800211e8 <log>
    80004038:	9736                	add	a4,a4,a3
    8000403a:	44d4                	lw	a3,12(s1)
    8000403c:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000403e:	faf60ee3          	beq	a2,a5,80003ffa <log_write+0x64>
  }
  release(&log.lock);
    80004042:	0001d517          	auipc	a0,0x1d
    80004046:	1a650513          	addi	a0,a0,422 # 800211e8 <log>
    8000404a:	bbbfc0ef          	jal	ra,80000c04 <release>
}
    8000404e:	60e2                	ld	ra,24(sp)
    80004050:	6442                	ld	s0,16(sp)
    80004052:	64a2                	ld	s1,8(sp)
    80004054:	6902                	ld	s2,0(sp)
    80004056:	6105                	addi	sp,sp,32
    80004058:	8082                	ret

000000008000405a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000405a:	1101                	addi	sp,sp,-32
    8000405c:	ec06                	sd	ra,24(sp)
    8000405e:	e822                	sd	s0,16(sp)
    80004060:	e426                	sd	s1,8(sp)
    80004062:	e04a                	sd	s2,0(sp)
    80004064:	1000                	addi	s0,sp,32
    80004066:	84aa                	mv	s1,a0
    80004068:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000406a:	00003597          	auipc	a1,0x3
    8000406e:	7d658593          	addi	a1,a1,2006 # 80007840 <syscalls+0x268>
    80004072:	0521                	addi	a0,a0,8
    80004074:	a79fc0ef          	jal	ra,80000aec <initlock>
  lk->name = name;
    80004078:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000407c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004080:	0204a423          	sw	zero,40(s1)
}
    80004084:	60e2                	ld	ra,24(sp)
    80004086:	6442                	ld	s0,16(sp)
    80004088:	64a2                	ld	s1,8(sp)
    8000408a:	6902                	ld	s2,0(sp)
    8000408c:	6105                	addi	sp,sp,32
    8000408e:	8082                	ret

0000000080004090 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004090:	1101                	addi	sp,sp,-32
    80004092:	ec06                	sd	ra,24(sp)
    80004094:	e822                	sd	s0,16(sp)
    80004096:	e426                	sd	s1,8(sp)
    80004098:	e04a                	sd	s2,0(sp)
    8000409a:	1000                	addi	s0,sp,32
    8000409c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000409e:	00850913          	addi	s2,a0,8
    800040a2:	854a                	mv	a0,s2
    800040a4:	ac9fc0ef          	jal	ra,80000b6c <acquire>
  while (lk->locked) {
    800040a8:	409c                	lw	a5,0(s1)
    800040aa:	c799                	beqz	a5,800040b8 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800040ac:	85ca                	mv	a1,s2
    800040ae:	8526                	mv	a0,s1
    800040b0:	8a4fe0ef          	jal	ra,80002154 <sleep>
  while (lk->locked) {
    800040b4:	409c                	lw	a5,0(s1)
    800040b6:	fbfd                	bnez	a5,800040ac <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800040b8:	4785                	li	a5,1
    800040ba:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800040bc:	a77fd0ef          	jal	ra,80001b32 <myproc>
    800040c0:	591c                	lw	a5,48(a0)
    800040c2:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800040c4:	854a                	mv	a0,s2
    800040c6:	b3ffc0ef          	jal	ra,80000c04 <release>
}
    800040ca:	60e2                	ld	ra,24(sp)
    800040cc:	6442                	ld	s0,16(sp)
    800040ce:	64a2                	ld	s1,8(sp)
    800040d0:	6902                	ld	s2,0(sp)
    800040d2:	6105                	addi	sp,sp,32
    800040d4:	8082                	ret

00000000800040d6 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800040d6:	1101                	addi	sp,sp,-32
    800040d8:	ec06                	sd	ra,24(sp)
    800040da:	e822                	sd	s0,16(sp)
    800040dc:	e426                	sd	s1,8(sp)
    800040de:	e04a                	sd	s2,0(sp)
    800040e0:	1000                	addi	s0,sp,32
    800040e2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800040e4:	00850913          	addi	s2,a0,8
    800040e8:	854a                	mv	a0,s2
    800040ea:	a83fc0ef          	jal	ra,80000b6c <acquire>
  lk->locked = 0;
    800040ee:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800040f2:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800040f6:	8526                	mv	a0,s1
    800040f8:	8a8fe0ef          	jal	ra,800021a0 <wakeup>
  release(&lk->lk);
    800040fc:	854a                	mv	a0,s2
    800040fe:	b07fc0ef          	jal	ra,80000c04 <release>
}
    80004102:	60e2                	ld	ra,24(sp)
    80004104:	6442                	ld	s0,16(sp)
    80004106:	64a2                	ld	s1,8(sp)
    80004108:	6902                	ld	s2,0(sp)
    8000410a:	6105                	addi	sp,sp,32
    8000410c:	8082                	ret

000000008000410e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000410e:	7179                	addi	sp,sp,-48
    80004110:	f406                	sd	ra,40(sp)
    80004112:	f022                	sd	s0,32(sp)
    80004114:	ec26                	sd	s1,24(sp)
    80004116:	e84a                	sd	s2,16(sp)
    80004118:	e44e                	sd	s3,8(sp)
    8000411a:	1800                	addi	s0,sp,48
    8000411c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000411e:	00850913          	addi	s2,a0,8
    80004122:	854a                	mv	a0,s2
    80004124:	a49fc0ef          	jal	ra,80000b6c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004128:	409c                	lw	a5,0(s1)
    8000412a:	ef89                	bnez	a5,80004144 <holdingsleep+0x36>
    8000412c:	4481                	li	s1,0
  release(&lk->lk);
    8000412e:	854a                	mv	a0,s2
    80004130:	ad5fc0ef          	jal	ra,80000c04 <release>
  return r;
}
    80004134:	8526                	mv	a0,s1
    80004136:	70a2                	ld	ra,40(sp)
    80004138:	7402                	ld	s0,32(sp)
    8000413a:	64e2                	ld	s1,24(sp)
    8000413c:	6942                	ld	s2,16(sp)
    8000413e:	69a2                	ld	s3,8(sp)
    80004140:	6145                	addi	sp,sp,48
    80004142:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004144:	0284a983          	lw	s3,40(s1)
    80004148:	9ebfd0ef          	jal	ra,80001b32 <myproc>
    8000414c:	5904                	lw	s1,48(a0)
    8000414e:	413484b3          	sub	s1,s1,s3
    80004152:	0014b493          	seqz	s1,s1
    80004156:	bfe1                	j	8000412e <holdingsleep+0x20>

0000000080004158 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004158:	1141                	addi	sp,sp,-16
    8000415a:	e406                	sd	ra,8(sp)
    8000415c:	e022                	sd	s0,0(sp)
    8000415e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004160:	00003597          	auipc	a1,0x3
    80004164:	6f058593          	addi	a1,a1,1776 # 80007850 <syscalls+0x278>
    80004168:	0001d517          	auipc	a0,0x1d
    8000416c:	1c850513          	addi	a0,a0,456 # 80021330 <ftable>
    80004170:	97dfc0ef          	jal	ra,80000aec <initlock>
}
    80004174:	60a2                	ld	ra,8(sp)
    80004176:	6402                	ld	s0,0(sp)
    80004178:	0141                	addi	sp,sp,16
    8000417a:	8082                	ret

000000008000417c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000417c:	1101                	addi	sp,sp,-32
    8000417e:	ec06                	sd	ra,24(sp)
    80004180:	e822                	sd	s0,16(sp)
    80004182:	e426                	sd	s1,8(sp)
    80004184:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004186:	0001d517          	auipc	a0,0x1d
    8000418a:	1aa50513          	addi	a0,a0,426 # 80021330 <ftable>
    8000418e:	9dffc0ef          	jal	ra,80000b6c <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004192:	0001d497          	auipc	s1,0x1d
    80004196:	1b648493          	addi	s1,s1,438 # 80021348 <ftable+0x18>
    8000419a:	0001e717          	auipc	a4,0x1e
    8000419e:	14e70713          	addi	a4,a4,334 # 800222e8 <disk>
    if(f->ref == 0){
    800041a2:	40dc                	lw	a5,4(s1)
    800041a4:	cf89                	beqz	a5,800041be <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800041a6:	02848493          	addi	s1,s1,40
    800041aa:	fee49ce3          	bne	s1,a4,800041a2 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800041ae:	0001d517          	auipc	a0,0x1d
    800041b2:	18250513          	addi	a0,a0,386 # 80021330 <ftable>
    800041b6:	a4ffc0ef          	jal	ra,80000c04 <release>
  return 0;
    800041ba:	4481                	li	s1,0
    800041bc:	a809                	j	800041ce <filealloc+0x52>
      f->ref = 1;
    800041be:	4785                	li	a5,1
    800041c0:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800041c2:	0001d517          	auipc	a0,0x1d
    800041c6:	16e50513          	addi	a0,a0,366 # 80021330 <ftable>
    800041ca:	a3bfc0ef          	jal	ra,80000c04 <release>
}
    800041ce:	8526                	mv	a0,s1
    800041d0:	60e2                	ld	ra,24(sp)
    800041d2:	6442                	ld	s0,16(sp)
    800041d4:	64a2                	ld	s1,8(sp)
    800041d6:	6105                	addi	sp,sp,32
    800041d8:	8082                	ret

00000000800041da <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800041da:	1101                	addi	sp,sp,-32
    800041dc:	ec06                	sd	ra,24(sp)
    800041de:	e822                	sd	s0,16(sp)
    800041e0:	e426                	sd	s1,8(sp)
    800041e2:	1000                	addi	s0,sp,32
    800041e4:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800041e6:	0001d517          	auipc	a0,0x1d
    800041ea:	14a50513          	addi	a0,a0,330 # 80021330 <ftable>
    800041ee:	97ffc0ef          	jal	ra,80000b6c <acquire>
  if(f->ref < 1)
    800041f2:	40dc                	lw	a5,4(s1)
    800041f4:	02f05063          	blez	a5,80004214 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800041f8:	2785                	addiw	a5,a5,1
    800041fa:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800041fc:	0001d517          	auipc	a0,0x1d
    80004200:	13450513          	addi	a0,a0,308 # 80021330 <ftable>
    80004204:	a01fc0ef          	jal	ra,80000c04 <release>
  return f;
}
    80004208:	8526                	mv	a0,s1
    8000420a:	60e2                	ld	ra,24(sp)
    8000420c:	6442                	ld	s0,16(sp)
    8000420e:	64a2                	ld	s1,8(sp)
    80004210:	6105                	addi	sp,sp,32
    80004212:	8082                	ret
    panic("filedup");
    80004214:	00003517          	auipc	a0,0x3
    80004218:	64450513          	addi	a0,a0,1604 # 80007858 <syscalls+0x280>
    8000421c:	d6efc0ef          	jal	ra,8000078a <panic>

0000000080004220 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004220:	7139                	addi	sp,sp,-64
    80004222:	fc06                	sd	ra,56(sp)
    80004224:	f822                	sd	s0,48(sp)
    80004226:	f426                	sd	s1,40(sp)
    80004228:	f04a                	sd	s2,32(sp)
    8000422a:	ec4e                	sd	s3,24(sp)
    8000422c:	e852                	sd	s4,16(sp)
    8000422e:	e456                	sd	s5,8(sp)
    80004230:	0080                	addi	s0,sp,64
    80004232:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004234:	0001d517          	auipc	a0,0x1d
    80004238:	0fc50513          	addi	a0,a0,252 # 80021330 <ftable>
    8000423c:	931fc0ef          	jal	ra,80000b6c <acquire>
  if(f->ref < 1)
    80004240:	40dc                	lw	a5,4(s1)
    80004242:	04f05963          	blez	a5,80004294 <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    80004246:	37fd                	addiw	a5,a5,-1
    80004248:	0007871b          	sext.w	a4,a5
    8000424c:	c0dc                	sw	a5,4(s1)
    8000424e:	04e04963          	bgtz	a4,800042a0 <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004252:	0004a903          	lw	s2,0(s1)
    80004256:	0094ca83          	lbu	s5,9(s1)
    8000425a:	0104ba03          	ld	s4,16(s1)
    8000425e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004262:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004266:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000426a:	0001d517          	auipc	a0,0x1d
    8000426e:	0c650513          	addi	a0,a0,198 # 80021330 <ftable>
    80004272:	993fc0ef          	jal	ra,80000c04 <release>

  if(ff.type == FD_PIPE){
    80004276:	4785                	li	a5,1
    80004278:	04f90363          	beq	s2,a5,800042be <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000427c:	3979                	addiw	s2,s2,-2
    8000427e:	4785                	li	a5,1
    80004280:	0327e663          	bltu	a5,s2,800042ac <fileclose+0x8c>
    begin_op();
    80004284:	b8fff0ef          	jal	ra,80003e12 <begin_op>
    iput(ff.ip);
    80004288:	854e                	mv	a0,s3
    8000428a:	b28ff0ef          	jal	ra,800035b2 <iput>
    end_op();
    8000428e:	bf5ff0ef          	jal	ra,80003e82 <end_op>
    80004292:	a829                	j	800042ac <fileclose+0x8c>
    panic("fileclose");
    80004294:	00003517          	auipc	a0,0x3
    80004298:	5cc50513          	addi	a0,a0,1484 # 80007860 <syscalls+0x288>
    8000429c:	ceefc0ef          	jal	ra,8000078a <panic>
    release(&ftable.lock);
    800042a0:	0001d517          	auipc	a0,0x1d
    800042a4:	09050513          	addi	a0,a0,144 # 80021330 <ftable>
    800042a8:	95dfc0ef          	jal	ra,80000c04 <release>
  }
}
    800042ac:	70e2                	ld	ra,56(sp)
    800042ae:	7442                	ld	s0,48(sp)
    800042b0:	74a2                	ld	s1,40(sp)
    800042b2:	7902                	ld	s2,32(sp)
    800042b4:	69e2                	ld	s3,24(sp)
    800042b6:	6a42                	ld	s4,16(sp)
    800042b8:	6aa2                	ld	s5,8(sp)
    800042ba:	6121                	addi	sp,sp,64
    800042bc:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800042be:	85d6                	mv	a1,s5
    800042c0:	8552                	mv	a0,s4
    800042c2:	2ec000ef          	jal	ra,800045ae <pipeclose>
    800042c6:	b7dd                	j	800042ac <fileclose+0x8c>

00000000800042c8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800042c8:	715d                	addi	sp,sp,-80
    800042ca:	e486                	sd	ra,72(sp)
    800042cc:	e0a2                	sd	s0,64(sp)
    800042ce:	fc26                	sd	s1,56(sp)
    800042d0:	f84a                	sd	s2,48(sp)
    800042d2:	f44e                	sd	s3,40(sp)
    800042d4:	0880                	addi	s0,sp,80
    800042d6:	84aa                	mv	s1,a0
    800042d8:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800042da:	859fd0ef          	jal	ra,80001b32 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800042de:	409c                	lw	a5,0(s1)
    800042e0:	37f9                	addiw	a5,a5,-2
    800042e2:	4705                	li	a4,1
    800042e4:	02f76f63          	bltu	a4,a5,80004322 <filestat+0x5a>
    800042e8:	892a                	mv	s2,a0
    ilock(f->ip);
    800042ea:	6c88                	ld	a0,24(s1)
    800042ec:	948ff0ef          	jal	ra,80003434 <ilock>
    stati(f->ip, &st);
    800042f0:	fb840593          	addi	a1,s0,-72
    800042f4:	6c88                	ld	a0,24(s1)
    800042f6:	ca0ff0ef          	jal	ra,80003796 <stati>
    iunlock(f->ip);
    800042fa:	6c88                	ld	a0,24(s1)
    800042fc:	9e2ff0ef          	jal	ra,800034de <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004300:	46e1                	li	a3,24
    80004302:	fb840613          	addi	a2,s0,-72
    80004306:	85ce                	mv	a1,s3
    80004308:	05093503          	ld	a0,80(s2)
    8000430c:	d74fd0ef          	jal	ra,80001880 <copyout>
    80004310:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004314:	60a6                	ld	ra,72(sp)
    80004316:	6406                	ld	s0,64(sp)
    80004318:	74e2                	ld	s1,56(sp)
    8000431a:	7942                	ld	s2,48(sp)
    8000431c:	79a2                	ld	s3,40(sp)
    8000431e:	6161                	addi	sp,sp,80
    80004320:	8082                	ret
  return -1;
    80004322:	557d                	li	a0,-1
    80004324:	bfc5                	j	80004314 <filestat+0x4c>

0000000080004326 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004326:	7179                	addi	sp,sp,-48
    80004328:	f406                	sd	ra,40(sp)
    8000432a:	f022                	sd	s0,32(sp)
    8000432c:	ec26                	sd	s1,24(sp)
    8000432e:	e84a                	sd	s2,16(sp)
    80004330:	e44e                	sd	s3,8(sp)
    80004332:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004334:	00854783          	lbu	a5,8(a0)
    80004338:	cbc1                	beqz	a5,800043c8 <fileread+0xa2>
    8000433a:	84aa                	mv	s1,a0
    8000433c:	89ae                	mv	s3,a1
    8000433e:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004340:	411c                	lw	a5,0(a0)
    80004342:	4705                	li	a4,1
    80004344:	04e78363          	beq	a5,a4,8000438a <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004348:	470d                	li	a4,3
    8000434a:	04e78563          	beq	a5,a4,80004394 <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000434e:	4709                	li	a4,2
    80004350:	06e79663          	bne	a5,a4,800043bc <fileread+0x96>
    ilock(f->ip);
    80004354:	6d08                	ld	a0,24(a0)
    80004356:	8deff0ef          	jal	ra,80003434 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000435a:	874a                	mv	a4,s2
    8000435c:	5094                	lw	a3,32(s1)
    8000435e:	864e                	mv	a2,s3
    80004360:	4585                	li	a1,1
    80004362:	6c88                	ld	a0,24(s1)
    80004364:	c5cff0ef          	jal	ra,800037c0 <readi>
    80004368:	892a                	mv	s2,a0
    8000436a:	00a05563          	blez	a0,80004374 <fileread+0x4e>
      f->off += r;
    8000436e:	509c                	lw	a5,32(s1)
    80004370:	9fa9                	addw	a5,a5,a0
    80004372:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004374:	6c88                	ld	a0,24(s1)
    80004376:	968ff0ef          	jal	ra,800034de <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000437a:	854a                	mv	a0,s2
    8000437c:	70a2                	ld	ra,40(sp)
    8000437e:	7402                	ld	s0,32(sp)
    80004380:	64e2                	ld	s1,24(sp)
    80004382:	6942                	ld	s2,16(sp)
    80004384:	69a2                	ld	s3,8(sp)
    80004386:	6145                	addi	sp,sp,48
    80004388:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000438a:	6908                	ld	a0,16(a0)
    8000438c:	34e000ef          	jal	ra,800046da <piperead>
    80004390:	892a                	mv	s2,a0
    80004392:	b7e5                	j	8000437a <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004394:	02451783          	lh	a5,36(a0)
    80004398:	03079693          	slli	a3,a5,0x30
    8000439c:	92c1                	srli	a3,a3,0x30
    8000439e:	4725                	li	a4,9
    800043a0:	02d76663          	bltu	a4,a3,800043cc <fileread+0xa6>
    800043a4:	0792                	slli	a5,a5,0x4
    800043a6:	0001d717          	auipc	a4,0x1d
    800043aa:	eea70713          	addi	a4,a4,-278 # 80021290 <devsw>
    800043ae:	97ba                	add	a5,a5,a4
    800043b0:	639c                	ld	a5,0(a5)
    800043b2:	cf99                	beqz	a5,800043d0 <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    800043b4:	4505                	li	a0,1
    800043b6:	9782                	jalr	a5
    800043b8:	892a                	mv	s2,a0
    800043ba:	b7c1                	j	8000437a <fileread+0x54>
    panic("fileread");
    800043bc:	00003517          	auipc	a0,0x3
    800043c0:	4b450513          	addi	a0,a0,1204 # 80007870 <syscalls+0x298>
    800043c4:	bc6fc0ef          	jal	ra,8000078a <panic>
    return -1;
    800043c8:	597d                	li	s2,-1
    800043ca:	bf45                	j	8000437a <fileread+0x54>
      return -1;
    800043cc:	597d                	li	s2,-1
    800043ce:	b775                	j	8000437a <fileread+0x54>
    800043d0:	597d                	li	s2,-1
    800043d2:	b765                	j	8000437a <fileread+0x54>

00000000800043d4 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800043d4:	715d                	addi	sp,sp,-80
    800043d6:	e486                	sd	ra,72(sp)
    800043d8:	e0a2                	sd	s0,64(sp)
    800043da:	fc26                	sd	s1,56(sp)
    800043dc:	f84a                	sd	s2,48(sp)
    800043de:	f44e                	sd	s3,40(sp)
    800043e0:	f052                	sd	s4,32(sp)
    800043e2:	ec56                	sd	s5,24(sp)
    800043e4:	e85a                	sd	s6,16(sp)
    800043e6:	e45e                	sd	s7,8(sp)
    800043e8:	e062                	sd	s8,0(sp)
    800043ea:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800043ec:	00954783          	lbu	a5,9(a0)
    800043f0:	0e078863          	beqz	a5,800044e0 <filewrite+0x10c>
    800043f4:	892a                	mv	s2,a0
    800043f6:	8aae                	mv	s5,a1
    800043f8:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800043fa:	411c                	lw	a5,0(a0)
    800043fc:	4705                	li	a4,1
    800043fe:	02e78263          	beq	a5,a4,80004422 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004402:	470d                	li	a4,3
    80004404:	02e78463          	beq	a5,a4,8000442c <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004408:	4709                	li	a4,2
    8000440a:	0ce79563          	bne	a5,a4,800044d4 <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000440e:	0ac05163          	blez	a2,800044b0 <filewrite+0xdc>
    int i = 0;
    80004412:	4981                	li	s3,0
    80004414:	6b05                	lui	s6,0x1
    80004416:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    8000441a:	6b85                	lui	s7,0x1
    8000441c:	c00b8b9b          	addiw	s7,s7,-1024
    80004420:	a041                	j	800044a0 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004422:	6908                	ld	a0,16(a0)
    80004424:	1e2000ef          	jal	ra,80004606 <pipewrite>
    80004428:	8a2a                	mv	s4,a0
    8000442a:	a071                	j	800044b6 <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000442c:	02451783          	lh	a5,36(a0)
    80004430:	03079693          	slli	a3,a5,0x30
    80004434:	92c1                	srli	a3,a3,0x30
    80004436:	4725                	li	a4,9
    80004438:	0ad76663          	bltu	a4,a3,800044e4 <filewrite+0x110>
    8000443c:	0792                	slli	a5,a5,0x4
    8000443e:	0001d717          	auipc	a4,0x1d
    80004442:	e5270713          	addi	a4,a4,-430 # 80021290 <devsw>
    80004446:	97ba                	add	a5,a5,a4
    80004448:	679c                	ld	a5,8(a5)
    8000444a:	cfd9                	beqz	a5,800044e8 <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    8000444c:	4505                	li	a0,1
    8000444e:	9782                	jalr	a5
    80004450:	8a2a                	mv	s4,a0
    80004452:	a095                	j	800044b6 <filewrite+0xe2>
    80004454:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004458:	9bbff0ef          	jal	ra,80003e12 <begin_op>
      ilock(f->ip);
    8000445c:	01893503          	ld	a0,24(s2)
    80004460:	fd5fe0ef          	jal	ra,80003434 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004464:	8762                	mv	a4,s8
    80004466:	02092683          	lw	a3,32(s2)
    8000446a:	01598633          	add	a2,s3,s5
    8000446e:	4585                	li	a1,1
    80004470:	01893503          	ld	a0,24(s2)
    80004474:	c30ff0ef          	jal	ra,800038a4 <writei>
    80004478:	84aa                	mv	s1,a0
    8000447a:	00a05763          	blez	a0,80004488 <filewrite+0xb4>
        f->off += r;
    8000447e:	02092783          	lw	a5,32(s2)
    80004482:	9fa9                	addw	a5,a5,a0
    80004484:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004488:	01893503          	ld	a0,24(s2)
    8000448c:	852ff0ef          	jal	ra,800034de <iunlock>
      end_op();
    80004490:	9f3ff0ef          	jal	ra,80003e82 <end_op>

      if(r != n1){
    80004494:	009c1f63          	bne	s8,s1,800044b2 <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    80004498:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000449c:	0149db63          	bge	s3,s4,800044b2 <filewrite+0xde>
      int n1 = n - i;
    800044a0:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800044a4:	84be                	mv	s1,a5
    800044a6:	2781                	sext.w	a5,a5
    800044a8:	fafb56e3          	bge	s6,a5,80004454 <filewrite+0x80>
    800044ac:	84de                	mv	s1,s7
    800044ae:	b75d                	j	80004454 <filewrite+0x80>
    int i = 0;
    800044b0:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800044b2:	013a1f63          	bne	s4,s3,800044d0 <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800044b6:	8552                	mv	a0,s4
    800044b8:	60a6                	ld	ra,72(sp)
    800044ba:	6406                	ld	s0,64(sp)
    800044bc:	74e2                	ld	s1,56(sp)
    800044be:	7942                	ld	s2,48(sp)
    800044c0:	79a2                	ld	s3,40(sp)
    800044c2:	7a02                	ld	s4,32(sp)
    800044c4:	6ae2                	ld	s5,24(sp)
    800044c6:	6b42                	ld	s6,16(sp)
    800044c8:	6ba2                	ld	s7,8(sp)
    800044ca:	6c02                	ld	s8,0(sp)
    800044cc:	6161                	addi	sp,sp,80
    800044ce:	8082                	ret
    ret = (i == n ? n : -1);
    800044d0:	5a7d                	li	s4,-1
    800044d2:	b7d5                	j	800044b6 <filewrite+0xe2>
    panic("filewrite");
    800044d4:	00003517          	auipc	a0,0x3
    800044d8:	3ac50513          	addi	a0,a0,940 # 80007880 <syscalls+0x2a8>
    800044dc:	aaefc0ef          	jal	ra,8000078a <panic>
    return -1;
    800044e0:	5a7d                	li	s4,-1
    800044e2:	bfd1                	j	800044b6 <filewrite+0xe2>
      return -1;
    800044e4:	5a7d                	li	s4,-1
    800044e6:	bfc1                	j	800044b6 <filewrite+0xe2>
    800044e8:	5a7d                	li	s4,-1
    800044ea:	b7f1                	j	800044b6 <filewrite+0xe2>

00000000800044ec <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800044ec:	7179                	addi	sp,sp,-48
    800044ee:	f406                	sd	ra,40(sp)
    800044f0:	f022                	sd	s0,32(sp)
    800044f2:	ec26                	sd	s1,24(sp)
    800044f4:	e84a                	sd	s2,16(sp)
    800044f6:	e44e                	sd	s3,8(sp)
    800044f8:	e052                	sd	s4,0(sp)
    800044fa:	1800                	addi	s0,sp,48
    800044fc:	84aa                	mv	s1,a0
    800044fe:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004500:	0005b023          	sd	zero,0(a1)
    80004504:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004508:	c75ff0ef          	jal	ra,8000417c <filealloc>
    8000450c:	e088                	sd	a0,0(s1)
    8000450e:	cd35                	beqz	a0,8000458a <pipealloc+0x9e>
    80004510:	c6dff0ef          	jal	ra,8000417c <filealloc>
    80004514:	00aa3023          	sd	a0,0(s4)
    80004518:	c52d                	beqz	a0,80004582 <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000451a:	d82fc0ef          	jal	ra,80000a9c <kalloc>
    8000451e:	892a                	mv	s2,a0
    80004520:	cd31                	beqz	a0,8000457c <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    80004522:	4985                	li	s3,1
    80004524:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004528:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000452c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004530:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004534:	00003597          	auipc	a1,0x3
    80004538:	35c58593          	addi	a1,a1,860 # 80007890 <syscalls+0x2b8>
    8000453c:	db0fc0ef          	jal	ra,80000aec <initlock>
  (*f0)->type = FD_PIPE;
    80004540:	609c                	ld	a5,0(s1)
    80004542:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004546:	609c                	ld	a5,0(s1)
    80004548:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000454c:	609c                	ld	a5,0(s1)
    8000454e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004552:	609c                	ld	a5,0(s1)
    80004554:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004558:	000a3783          	ld	a5,0(s4)
    8000455c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004560:	000a3783          	ld	a5,0(s4)
    80004564:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004568:	000a3783          	ld	a5,0(s4)
    8000456c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004570:	000a3783          	ld	a5,0(s4)
    80004574:	0127b823          	sd	s2,16(a5)
  return 0;
    80004578:	4501                	li	a0,0
    8000457a:	a005                	j	8000459a <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000457c:	6088                	ld	a0,0(s1)
    8000457e:	e501                	bnez	a0,80004586 <pipealloc+0x9a>
    80004580:	a029                	j	8000458a <pipealloc+0x9e>
    80004582:	6088                	ld	a0,0(s1)
    80004584:	c11d                	beqz	a0,800045aa <pipealloc+0xbe>
    fileclose(*f0);
    80004586:	c9bff0ef          	jal	ra,80004220 <fileclose>
  if(*f1)
    8000458a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000458e:	557d                	li	a0,-1
  if(*f1)
    80004590:	c789                	beqz	a5,8000459a <pipealloc+0xae>
    fileclose(*f1);
    80004592:	853e                	mv	a0,a5
    80004594:	c8dff0ef          	jal	ra,80004220 <fileclose>
  return -1;
    80004598:	557d                	li	a0,-1
}
    8000459a:	70a2                	ld	ra,40(sp)
    8000459c:	7402                	ld	s0,32(sp)
    8000459e:	64e2                	ld	s1,24(sp)
    800045a0:	6942                	ld	s2,16(sp)
    800045a2:	69a2                	ld	s3,8(sp)
    800045a4:	6a02                	ld	s4,0(sp)
    800045a6:	6145                	addi	sp,sp,48
    800045a8:	8082                	ret
  return -1;
    800045aa:	557d                	li	a0,-1
    800045ac:	b7fd                	j	8000459a <pipealloc+0xae>

00000000800045ae <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800045ae:	1101                	addi	sp,sp,-32
    800045b0:	ec06                	sd	ra,24(sp)
    800045b2:	e822                	sd	s0,16(sp)
    800045b4:	e426                	sd	s1,8(sp)
    800045b6:	e04a                	sd	s2,0(sp)
    800045b8:	1000                	addi	s0,sp,32
    800045ba:	84aa                	mv	s1,a0
    800045bc:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800045be:	daefc0ef          	jal	ra,80000b6c <acquire>
  if(writable){
    800045c2:	02090763          	beqz	s2,800045f0 <pipeclose+0x42>
    pi->writeopen = 0;
    800045c6:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800045ca:	21848513          	addi	a0,s1,536
    800045ce:	bd3fd0ef          	jal	ra,800021a0 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800045d2:	2204b783          	ld	a5,544(s1)
    800045d6:	e785                	bnez	a5,800045fe <pipeclose+0x50>
    release(&pi->lock);
    800045d8:	8526                	mv	a0,s1
    800045da:	e2afc0ef          	jal	ra,80000c04 <release>
    kfree((char*)pi);
    800045de:	8526                	mv	a0,s1
    800045e0:	bdcfc0ef          	jal	ra,800009bc <kfree>
  } else
    release(&pi->lock);
}
    800045e4:	60e2                	ld	ra,24(sp)
    800045e6:	6442                	ld	s0,16(sp)
    800045e8:	64a2                	ld	s1,8(sp)
    800045ea:	6902                	ld	s2,0(sp)
    800045ec:	6105                	addi	sp,sp,32
    800045ee:	8082                	ret
    pi->readopen = 0;
    800045f0:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800045f4:	21c48513          	addi	a0,s1,540
    800045f8:	ba9fd0ef          	jal	ra,800021a0 <wakeup>
    800045fc:	bfd9                	j	800045d2 <pipeclose+0x24>
    release(&pi->lock);
    800045fe:	8526                	mv	a0,s1
    80004600:	e04fc0ef          	jal	ra,80000c04 <release>
}
    80004604:	b7c5                	j	800045e4 <pipeclose+0x36>

0000000080004606 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004606:	711d                	addi	sp,sp,-96
    80004608:	ec86                	sd	ra,88(sp)
    8000460a:	e8a2                	sd	s0,80(sp)
    8000460c:	e4a6                	sd	s1,72(sp)
    8000460e:	e0ca                	sd	s2,64(sp)
    80004610:	fc4e                	sd	s3,56(sp)
    80004612:	f852                	sd	s4,48(sp)
    80004614:	f456                	sd	s5,40(sp)
    80004616:	f05a                	sd	s6,32(sp)
    80004618:	ec5e                	sd	s7,24(sp)
    8000461a:	e862                	sd	s8,16(sp)
    8000461c:	1080                	addi	s0,sp,96
    8000461e:	84aa                	mv	s1,a0
    80004620:	8aae                	mv	s5,a1
    80004622:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004624:	d0efd0ef          	jal	ra,80001b32 <myproc>
    80004628:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000462a:	8526                	mv	a0,s1
    8000462c:	d40fc0ef          	jal	ra,80000b6c <acquire>
  while(i < n){
    80004630:	09405c63          	blez	s4,800046c8 <pipewrite+0xc2>
  int i = 0;
    80004634:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004636:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004638:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000463c:	21c48b93          	addi	s7,s1,540
    80004640:	a81d                	j	80004676 <pipewrite+0x70>
      release(&pi->lock);
    80004642:	8526                	mv	a0,s1
    80004644:	dc0fc0ef          	jal	ra,80000c04 <release>
      return -1;
    80004648:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000464a:	854a                	mv	a0,s2
    8000464c:	60e6                	ld	ra,88(sp)
    8000464e:	6446                	ld	s0,80(sp)
    80004650:	64a6                	ld	s1,72(sp)
    80004652:	6906                	ld	s2,64(sp)
    80004654:	79e2                	ld	s3,56(sp)
    80004656:	7a42                	ld	s4,48(sp)
    80004658:	7aa2                	ld	s5,40(sp)
    8000465a:	7b02                	ld	s6,32(sp)
    8000465c:	6be2                	ld	s7,24(sp)
    8000465e:	6c42                	ld	s8,16(sp)
    80004660:	6125                	addi	sp,sp,96
    80004662:	8082                	ret
      wakeup(&pi->nread);
    80004664:	8562                	mv	a0,s8
    80004666:	b3bfd0ef          	jal	ra,800021a0 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000466a:	85a6                	mv	a1,s1
    8000466c:	855e                	mv	a0,s7
    8000466e:	ae7fd0ef          	jal	ra,80002154 <sleep>
  while(i < n){
    80004672:	05495c63          	bge	s2,s4,800046ca <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    80004676:	2204a783          	lw	a5,544(s1)
    8000467a:	d7e1                	beqz	a5,80004642 <pipewrite+0x3c>
    8000467c:	854e                	mv	a0,s3
    8000467e:	d0ffd0ef          	jal	ra,8000238c <killed>
    80004682:	f161                	bnez	a0,80004642 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004684:	2184a783          	lw	a5,536(s1)
    80004688:	21c4a703          	lw	a4,540(s1)
    8000468c:	2007879b          	addiw	a5,a5,512
    80004690:	fcf70ae3          	beq	a4,a5,80004664 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004694:	4685                	li	a3,1
    80004696:	01590633          	add	a2,s2,s5
    8000469a:	faf40593          	addi	a1,s0,-81
    8000469e:	0509b503          	ld	a0,80(s3)
    800046a2:	aa4fd0ef          	jal	ra,80001946 <copyin>
    800046a6:	03650263          	beq	a0,s6,800046ca <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800046aa:	21c4a783          	lw	a5,540(s1)
    800046ae:	0017871b          	addiw	a4,a5,1
    800046b2:	20e4ae23          	sw	a4,540(s1)
    800046b6:	1ff7f793          	andi	a5,a5,511
    800046ba:	97a6                	add	a5,a5,s1
    800046bc:	faf44703          	lbu	a4,-81(s0)
    800046c0:	00e78c23          	sb	a4,24(a5)
      i++;
    800046c4:	2905                	addiw	s2,s2,1
    800046c6:	b775                	j	80004672 <pipewrite+0x6c>
  int i = 0;
    800046c8:	4901                	li	s2,0
  wakeup(&pi->nread);
    800046ca:	21848513          	addi	a0,s1,536
    800046ce:	ad3fd0ef          	jal	ra,800021a0 <wakeup>
  release(&pi->lock);
    800046d2:	8526                	mv	a0,s1
    800046d4:	d30fc0ef          	jal	ra,80000c04 <release>
  return i;
    800046d8:	bf8d                	j	8000464a <pipewrite+0x44>

00000000800046da <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800046da:	715d                	addi	sp,sp,-80
    800046dc:	e486                	sd	ra,72(sp)
    800046de:	e0a2                	sd	s0,64(sp)
    800046e0:	fc26                	sd	s1,56(sp)
    800046e2:	f84a                	sd	s2,48(sp)
    800046e4:	f44e                	sd	s3,40(sp)
    800046e6:	f052                	sd	s4,32(sp)
    800046e8:	ec56                	sd	s5,24(sp)
    800046ea:	e85a                	sd	s6,16(sp)
    800046ec:	0880                	addi	s0,sp,80
    800046ee:	84aa                	mv	s1,a0
    800046f0:	892e                	mv	s2,a1
    800046f2:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800046f4:	c3efd0ef          	jal	ra,80001b32 <myproc>
    800046f8:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800046fa:	8526                	mv	a0,s1
    800046fc:	c70fc0ef          	jal	ra,80000b6c <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004700:	2184a703          	lw	a4,536(s1)
    80004704:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004708:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000470c:	02f71363          	bne	a4,a5,80004732 <piperead+0x58>
    80004710:	2244a783          	lw	a5,548(s1)
    80004714:	cf99                	beqz	a5,80004732 <piperead+0x58>
    if(killed(pr)){
    80004716:	8552                	mv	a0,s4
    80004718:	c75fd0ef          	jal	ra,8000238c <killed>
    8000471c:	e141                	bnez	a0,8000479c <piperead+0xc2>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000471e:	85a6                	mv	a1,s1
    80004720:	854e                	mv	a0,s3
    80004722:	a33fd0ef          	jal	ra,80002154 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004726:	2184a703          	lw	a4,536(s1)
    8000472a:	21c4a783          	lw	a5,540(s1)
    8000472e:	fef701e3          	beq	a4,a5,80004710 <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004732:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004734:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004736:	05505163          	blez	s5,80004778 <piperead+0x9e>
    if(pi->nread == pi->nwrite)
    8000473a:	2184a783          	lw	a5,536(s1)
    8000473e:	21c4a703          	lw	a4,540(s1)
    80004742:	02f70b63          	beq	a4,a5,80004778 <piperead+0x9e>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004746:	0017871b          	addiw	a4,a5,1
    8000474a:	20e4ac23          	sw	a4,536(s1)
    8000474e:	1ff7f793          	andi	a5,a5,511
    80004752:	97a6                	add	a5,a5,s1
    80004754:	0187c783          	lbu	a5,24(a5)
    80004758:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000475c:	4685                	li	a3,1
    8000475e:	fbf40613          	addi	a2,s0,-65
    80004762:	85ca                	mv	a1,s2
    80004764:	050a3503          	ld	a0,80(s4)
    80004768:	918fd0ef          	jal	ra,80001880 <copyout>
    8000476c:	01650663          	beq	a0,s6,80004778 <piperead+0x9e>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004770:	2985                	addiw	s3,s3,1
    80004772:	0905                	addi	s2,s2,1
    80004774:	fd3a93e3          	bne	s5,s3,8000473a <piperead+0x60>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004778:	21c48513          	addi	a0,s1,540
    8000477c:	a25fd0ef          	jal	ra,800021a0 <wakeup>
  release(&pi->lock);
    80004780:	8526                	mv	a0,s1
    80004782:	c82fc0ef          	jal	ra,80000c04 <release>
  return i;
}
    80004786:	854e                	mv	a0,s3
    80004788:	60a6                	ld	ra,72(sp)
    8000478a:	6406                	ld	s0,64(sp)
    8000478c:	74e2                	ld	s1,56(sp)
    8000478e:	7942                	ld	s2,48(sp)
    80004790:	79a2                	ld	s3,40(sp)
    80004792:	7a02                	ld	s4,32(sp)
    80004794:	6ae2                	ld	s5,24(sp)
    80004796:	6b42                	ld	s6,16(sp)
    80004798:	6161                	addi	sp,sp,80
    8000479a:	8082                	ret
      release(&pi->lock);
    8000479c:	8526                	mv	a0,s1
    8000479e:	c66fc0ef          	jal	ra,80000c04 <release>
      return -1;
    800047a2:	59fd                	li	s3,-1
    800047a4:	b7cd                	j	80004786 <piperead+0xac>

00000000800047a6 <flags2perm>:

// static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800047a6:	1141                	addi	sp,sp,-16
    800047a8:	e422                	sd	s0,8(sp)
    800047aa:	0800                	addi	s0,sp,16
    800047ac:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800047ae:	8905                	andi	a0,a0,1
    800047b0:	c111                	beqz	a0,800047b4 <flags2perm+0xe>
      perm = PTE_X;
    800047b2:	4521                	li	a0,8
    if(flags & 0x2)
    800047b4:	8b89                	andi	a5,a5,2
    800047b6:	c399                	beqz	a5,800047bc <flags2perm+0x16>
      perm |= PTE_W;
    800047b8:	00456513          	ori	a0,a0,4
    return perm;
}
    800047bc:	6422                	ld	s0,8(sp)
    800047be:	0141                	addi	sp,sp,16
    800047c0:	8082                	ret

00000000800047c2 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800047c2:	7101                	addi	sp,sp,-512
    800047c4:	ff86                	sd	ra,504(sp)
    800047c6:	fba2                	sd	s0,496(sp)
    800047c8:	f7a6                	sd	s1,488(sp)
    800047ca:	f3ca                	sd	s2,480(sp)
    800047cc:	efce                	sd	s3,472(sp)
    800047ce:	ebd2                	sd	s4,464(sp)
    800047d0:	e7d6                	sd	s5,456(sp)
    800047d2:	e3da                	sd	s6,448(sp)
    800047d4:	ff5e                	sd	s7,440(sp)
    800047d6:	fb62                	sd	s8,432(sp)
    800047d8:	f766                	sd	s9,424(sp)
    800047da:	f36a                	sd	s10,416(sp)
    800047dc:	ef6e                	sd	s11,408(sp)
    800047de:	0400                	addi	s0,sp,512
    800047e0:	892a                	mv	s2,a0
    800047e2:	84ae                	mv	s1,a1
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800047e4:	b4efd0ef          	jal	ra,80001b32 <myproc>
    800047e8:	8baa                	mv	s7,a0

  begin_op();
    800047ea:	e28ff0ef          	jal	ra,80003e12 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    800047ee:	854a                	mv	a0,s2
    800047f0:	c32ff0ef          	jal	ra,80003c22 <namei>
    800047f4:	cd39                	beqz	a0,80004852 <kexec+0x90>
    800047f6:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800047f8:	c3dfe0ef          	jal	ra,80003434 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800047fc:	04000713          	li	a4,64
    80004800:	4681                	li	a3,0
    80004802:	e5040613          	addi	a2,s0,-432
    80004806:	4581                	li	a1,0
    80004808:	8552                	mv	a0,s4
    8000480a:	fb7fe0ef          	jal	ra,800037c0 <readi>
    8000480e:	04000793          	li	a5,64
    80004812:	00f51a63          	bne	a0,a5,80004826 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004816:	e5042703          	lw	a4,-432(s0)
    8000481a:	464c47b7          	lui	a5,0x464c4
    8000481e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004822:	02f70c63          	beq	a4,a5,8000485a <kexec+0x98>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004826:	8552                	mv	a0,s4
    80004828:	e13fe0ef          	jal	ra,8000363a <iunlockput>
    end_op();
    8000482c:	e56ff0ef          	jal	ra,80003e82 <end_op>
  }
  return -1;
    80004830:	557d                	li	a0,-1
}
    80004832:	70fe                	ld	ra,504(sp)
    80004834:	745e                	ld	s0,496(sp)
    80004836:	74be                	ld	s1,488(sp)
    80004838:	791e                	ld	s2,480(sp)
    8000483a:	69fe                	ld	s3,472(sp)
    8000483c:	6a5e                	ld	s4,464(sp)
    8000483e:	6abe                	ld	s5,456(sp)
    80004840:	6b1e                	ld	s6,448(sp)
    80004842:	7bfa                	ld	s7,440(sp)
    80004844:	7c5a                	ld	s8,432(sp)
    80004846:	7cba                	ld	s9,424(sp)
    80004848:	7d1a                	ld	s10,416(sp)
    8000484a:	6dfa                	ld	s11,408(sp)
    8000484c:	20010113          	addi	sp,sp,512
    80004850:	8082                	ret
    end_op();
    80004852:	e30ff0ef          	jal	ra,80003e82 <end_op>
    return -1;
    80004856:	557d                	li	a0,-1
    80004858:	bfe9                	j	80004832 <kexec+0x70>
  if((pagetable = proc_pagetable(p)) == 0)
    8000485a:	855e                	mv	a0,s7
    8000485c:	bdcfd0ef          	jal	ra,80001c38 <proc_pagetable>
    80004860:	8b2a                	mv	s6,a0
    80004862:	d171                	beqz	a0,80004826 <kexec+0x64>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004864:	e7042983          	lw	s3,-400(s0)
    80004868:	e8845783          	lhu	a5,-376(s0)
    8000486c:	cbc1                	beqz	a5,800048fc <kexec+0x13a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000486e:	4a81                	li	s5,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004870:	4c01                	li	s8,0
    if(ph.type != ELF_PROG_LOAD)
    80004872:	4c85                	li	s9,1
    if(ph.vaddr % PGSIZE != 0)
    80004874:	6d05                	lui	s10,0x1
    80004876:	1d7d                	addi	s10,s10,-1
    80004878:	a01d                	j	8000489e <kexec+0xdc>
  p->data_start = ph.vaddr;
    8000487a:	16ebbc23          	sd	a4,376(s7) # 1178 <_entry-0x7fffee88>
  p->data_end = ph.vaddr + ph.memsz;
    8000487e:	18fbb023          	sd	a5,384(s7)
  p->data_file_offset = ph.off;
    80004882:	e2043703          	ld	a4,-480(s0)
    80004886:	1aebb823          	sd	a4,432(s7)
  p->data_file_size = ph.filesz;
    8000488a:	1adbbc23          	sd	a3,440(s7)
    sz = ph.vaddr + ph.memsz;  // Update size but don't allocate
    8000488e:	8abe                	mv	s5,a5
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004890:	2c05                	addiw	s8,s8,1
    80004892:	0389899b          	addiw	s3,s3,56
    80004896:	e8845783          	lhu	a5,-376(s0)
    8000489a:	06fc5263          	bge	s8,a5,800048fe <kexec+0x13c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000489e:	2981                	sext.w	s3,s3
    800048a0:	03800713          	li	a4,56
    800048a4:	86ce                	mv	a3,s3
    800048a6:	e1840613          	addi	a2,s0,-488
    800048aa:	4581                	li	a1,0
    800048ac:	8552                	mv	a0,s4
    800048ae:	f13fe0ef          	jal	ra,800037c0 <readi>
    800048b2:	03800793          	li	a5,56
    800048b6:	12f51663          	bne	a0,a5,800049e2 <kexec+0x220>
    if(ph.type != ELF_PROG_LOAD)
    800048ba:	e1842783          	lw	a5,-488(s0)
    800048be:	fd9799e3          	bne	a5,s9,80004890 <kexec+0xce>
    if(ph.memsz < ph.filesz)
    800048c2:	e4043783          	ld	a5,-448(s0)
    800048c6:	e3843683          	ld	a3,-456(s0)
    800048ca:	10d7ec63          	bltu	a5,a3,800049e2 <kexec+0x220>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800048ce:	e2843703          	ld	a4,-472(s0)
    800048d2:	97ba                	add	a5,a5,a4
    800048d4:	10e7e763          	bltu	a5,a4,800049e2 <kexec+0x220>
    if(ph.vaddr % PGSIZE != 0)
    800048d8:	01a77633          	and	a2,a4,s10
    800048dc:	10061363          	bnez	a2,800049e2 <kexec+0x220>
if(i == 0) {  // First segment (typically text)
    800048e0:	f80c1de3          	bnez	s8,8000487a <kexec+0xb8>
  p->text_start = ph.vaddr;
    800048e4:	16ebb423          	sd	a4,360(s7)
  p->text_end = ph.vaddr + ph.memsz;
    800048e8:	16fbb823          	sd	a5,368(s7)
  p->text_file_offset = ph.off;
    800048ec:	e2043703          	ld	a4,-480(s0)
    800048f0:	1aebb023          	sd	a4,416(s7)
  p->text_file_size = ph.filesz;
    800048f4:	1adbb423          	sd	a3,424(s7)
    sz = ph.vaddr + ph.memsz;  // Update size but don't allocate
    800048f8:	8abe                	mv	s5,a5
    800048fa:	bf59                	j	80004890 <kexec+0xce>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800048fc:	4a81                	li	s5,0
  printf("[pid %d] INIT-LAZYMAP text=[0x%lx,0x%lx) data=[0x%lx,0x%lx) heap_start=0x%lx stack_top=0x%lx\n", 
    800048fe:	180bb783          	ld	a5,384(s7)
    80004902:	6989                	lui	s3,0x2
    80004904:	013a88b3          	add	a7,s5,s3
    80004908:	883e                	mv	a6,a5
    8000490a:	178bb703          	ld	a4,376(s7)
    8000490e:	170bb683          	ld	a3,368(s7)
    80004912:	168bb603          	ld	a2,360(s7)
    80004916:	030ba583          	lw	a1,48(s7)
    8000491a:	00003517          	auipc	a0,0x3
    8000491e:	f7e50513          	addi	a0,a0,-130 # 80007898 <syscalls+0x2c0>
    80004922:	ba3fb0ef          	jal	ra,800004c4 <printf>
  p->heap_start = p->data_end;
    80004926:	180bb783          	ld	a5,384(s7)
    8000492a:	18fbb423          	sd	a5,392(s7)
  p->exec_inode = ip;
    8000492e:	194bbc23          	sd	s4,408(s7)
  idup(ip);  // Increment reference count
    80004932:	8552                	mv	a0,s4
    80004934:	acbfe0ef          	jal	ra,800033fe <idup>
  iunlockput(ip);
    80004938:	8552                	mv	a0,s4
    8000493a:	d01fe0ef          	jal	ra,8000363a <iunlockput>
  end_op();
    8000493e:	d44ff0ef          	jal	ra,80003e82 <end_op>
  p = myproc();
    80004942:	9f0fd0ef          	jal	ra,80001b32 <myproc>
    80004946:	e0a43423          	sd	a0,-504(s0)
  uint64 oldsz = p->sz;
    8000494a:	653c                	ld	a5,72(a0)
    8000494c:	e0f43023          	sd	a5,-512(s0)
  sz = PGROUNDUP(sz);
    80004950:	6785                	lui	a5,0x1
    80004952:	fff78c93          	addi	s9,a5,-1 # fff <_entry-0x7ffff001>
    80004956:	9cd6                	add	s9,s9,s5
    80004958:	777d                	lui	a4,0xfffff
    8000495a:	00ecfcb3          	and	s9,s9,a4
  sz1 = sz + (USERSTACK+1)*PGSIZE;
    8000495e:	013c8ab3          	add	s5,s9,s3
  stackbase = sp - USERSTACK*PGSIZE;
    80004962:	9cbe                	add	s9,s9,a5
   p->sz = sz;
    80004964:	05553423          	sd	s5,72(a0)
  for(argc = 0; argv[argc]; argc++) {
    80004968:	6088                	ld	a0,0(s1)
    8000496a:	cd41                	beqz	a0,80004a02 <kexec+0x240>
    8000496c:	e9040b93          	addi	s7,s0,-368
  sp = sz;
    80004970:	8a56                	mv	s4,s5
  for(argc = 0; argv[argc]; argc++) {
    80004972:	4981                	li	s3,0
    printf("[DEBUG] About to copyout to sp=0x%lx, len=%d\n", sp, strlen(argv[argc]) + 1);
    80004974:	00003d17          	auipc	s10,0x3
    80004978:	f84d0d13          	addi	s10,s10,-124 # 800078f8 <syscalls+0x320>
    printf("[DEBUG] copyout SUCCESS\n");
    8000497c:	00003d97          	auipc	s11,0x3
    80004980:	fc4d8d93          	addi	s11,s11,-60 # 80007940 <syscalls+0x368>
    sp -= strlen(argv[argc]) + 1;
    80004984:	c34fc0ef          	jal	ra,80000db8 <strlen>
    80004988:	2505                	addiw	a0,a0,1
    8000498a:	40aa0a33          	sub	s4,s4,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000498e:	ff0a7a13          	andi	s4,s4,-16
    if(sp < stackbase)
    80004992:	119a6b63          	bltu	s4,s9,80004aa8 <kexec+0x2e6>
    printf("[DEBUG] About to copyout to sp=0x%lx, len=%d\n", sp, strlen(argv[argc]) + 1);
    80004996:	6088                	ld	a0,0(s1)
    80004998:	c20fc0ef          	jal	ra,80000db8 <strlen>
    8000499c:	0015061b          	addiw	a2,a0,1
    800049a0:	85d2                	mv	a1,s4
    800049a2:	856a                	mv	a0,s10
    800049a4:	b21fb0ef          	jal	ra,800004c4 <printf>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0) {
    800049a8:	0004bc03          	ld	s8,0(s1)
    800049ac:	8562                	mv	a0,s8
    800049ae:	c0afc0ef          	jal	ra,80000db8 <strlen>
    800049b2:	0015069b          	addiw	a3,a0,1
    800049b6:	8662                	mv	a2,s8
    800049b8:	85d2                	mv	a1,s4
    800049ba:	855a                	mv	a0,s6
    800049bc:	ec5fc0ef          	jal	ra,80001880 <copyout>
    800049c0:	02054963          	bltz	a0,800049f2 <kexec+0x230>
    printf("[DEBUG] copyout SUCCESS\n");
    800049c4:	856e                	mv	a0,s11
    800049c6:	afffb0ef          	jal	ra,800004c4 <printf>
    ustack[argc] = sp;
    800049ca:	014bb023          	sd	s4,0(s7)
  for(argc = 0; argv[argc]; argc++) {
    800049ce:	0985                	addi	s3,s3,1
    800049d0:	04a1                	addi	s1,s1,8
    800049d2:	6088                	ld	a0,0(s1)
    800049d4:	c90d                	beqz	a0,80004a06 <kexec+0x244>
    if(argc >= MAXARG)
    800049d6:	0ba1                	addi	s7,s7,8
    800049d8:	f9040793          	addi	a5,s0,-112
    800049dc:	fb7794e3          	bne	a5,s7,80004984 <kexec+0x1c2>
  ip = 0;
    800049e0:	4a01                	li	s4,0
    proc_freepagetable(pagetable, sz);
    800049e2:	85d6                	mv	a1,s5
    800049e4:	855a                	mv	a0,s6
    800049e6:	ad6fd0ef          	jal	ra,80001cbc <proc_freepagetable>
  if(ip){
    800049ea:	e20a1ee3          	bnez	s4,80004826 <kexec+0x64>
  return -1;
    800049ee:	557d                	li	a0,-1
    800049f0:	b589                	j	80004832 <kexec+0x70>
      printf("[DEBUG] copyout FAILED\n");
    800049f2:	00003517          	auipc	a0,0x3
    800049f6:	f3650513          	addi	a0,a0,-202 # 80007928 <syscalls+0x350>
    800049fa:	acbfb0ef          	jal	ra,800004c4 <printf>
  ip = 0;
    800049fe:	4a01                	li	s4,0
      goto bad;
    80004a00:	b7cd                	j	800049e2 <kexec+0x220>
  sp = sz;
    80004a02:	8a56                	mv	s4,s5
  for(argc = 0; argv[argc]; argc++) {
    80004a04:	4981                	li	s3,0
  ustack[argc] = 0;
    80004a06:	00399793          	slli	a5,s3,0x3
    80004a0a:	f9040713          	addi	a4,s0,-112
    80004a0e:	97ba                	add	a5,a5,a4
    80004a10:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004a14:	00198b93          	addi	s7,s3,1 # 2001 <_entry-0x7fffdfff>
    80004a18:	0b8e                	slli	s7,s7,0x3
    80004a1a:	417a04b3          	sub	s1,s4,s7
  sp -= sp % 16;
    80004a1e:	98c1                	andi	s1,s1,-16
  ip = 0;
    80004a20:	4a01                	li	s4,0
  if(sp < stackbase)
    80004a22:	fd94e0e3          	bltu	s1,s9,800049e2 <kexec+0x220>
  printf("[DEBUG] copyout ustack to sp=0x%lx\n", sp);
    80004a26:	85a6                	mv	a1,s1
    80004a28:	00003517          	auipc	a0,0x3
    80004a2c:	f3850513          	addi	a0,a0,-200 # 80007960 <syscalls+0x388>
    80004a30:	a95fb0ef          	jal	ra,800004c4 <printf>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004a34:	86de                	mv	a3,s7
    80004a36:	e9040613          	addi	a2,s0,-368
    80004a3a:	85a6                	mv	a1,s1
    80004a3c:	855a                	mv	a0,s6
    80004a3e:	e43fc0ef          	jal	ra,80001880 <copyout>
    80004a42:	06054563          	bltz	a0,80004aac <kexec+0x2ea>
  p->trapframe->a1 = sp;
    80004a46:	e0843783          	ld	a5,-504(s0)
    80004a4a:	6fbc                	ld	a5,88(a5)
    80004a4c:	ffa4                	sd	s1,120(a5)
  for(last=s=path; *s; s++)
    80004a4e:	00094703          	lbu	a4,0(s2)
    80004a52:	cf11                	beqz	a4,80004a6e <kexec+0x2ac>
    80004a54:	00190793          	addi	a5,s2,1
    if(*s == '/')
    80004a58:	02f00693          	li	a3,47
    80004a5c:	a029                	j	80004a66 <kexec+0x2a4>
  for(last=s=path; *s; s++)
    80004a5e:	0785                	addi	a5,a5,1
    80004a60:	fff7c703          	lbu	a4,-1(a5)
    80004a64:	c709                	beqz	a4,80004a6e <kexec+0x2ac>
    if(*s == '/')
    80004a66:	fed71ce3          	bne	a4,a3,80004a5e <kexec+0x29c>
      last = s+1;
    80004a6a:	893e                	mv	s2,a5
    80004a6c:	bfcd                	j	80004a5e <kexec+0x29c>
  safestrcpy(p->name, last, sizeof(p->name));
    80004a6e:	4641                	li	a2,16
    80004a70:	85ca                	mv	a1,s2
    80004a72:	e0843903          	ld	s2,-504(s0)
    80004a76:	15890513          	addi	a0,s2,344
    80004a7a:	b0cfc0ef          	jal	ra,80000d86 <safestrcpy>
  oldpagetable = p->pagetable;
    80004a7e:	05093503          	ld	a0,80(s2)
  p->pagetable = pagetable;
    80004a82:	05693823          	sd	s6,80(s2)
  p->sz = sz;
    80004a86:	05593423          	sd	s5,72(s2)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004a8a:	05893783          	ld	a5,88(s2)
    80004a8e:	e6843703          	ld	a4,-408(s0)
    80004a92:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004a94:	05893783          	ld	a5,88(s2)
    80004a98:	fb84                	sd	s1,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004a9a:	e0043583          	ld	a1,-512(s0)
    80004a9e:	a1efd0ef          	jal	ra,80001cbc <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004aa2:	0009851b          	sext.w	a0,s3
    80004aa6:	b371                	j	80004832 <kexec+0x70>
  ip = 0;
    80004aa8:	4a01                	li	s4,0
    80004aaa:	bf25                	j	800049e2 <kexec+0x220>
    80004aac:	4a01                	li	s4,0
    80004aae:	bf15                	j	800049e2 <kexec+0x220>

0000000080004ab0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004ab0:	7179                	addi	sp,sp,-48
    80004ab2:	f406                	sd	ra,40(sp)
    80004ab4:	f022                	sd	s0,32(sp)
    80004ab6:	ec26                	sd	s1,24(sp)
    80004ab8:	e84a                	sd	s2,16(sp)
    80004aba:	1800                	addi	s0,sp,48
    80004abc:	892e                	mv	s2,a1
    80004abe:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004ac0:	fdc40593          	addi	a1,s0,-36
    80004ac4:	f99fd0ef          	jal	ra,80002a5c <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004ac8:	fdc42703          	lw	a4,-36(s0)
    80004acc:	47bd                	li	a5,15
    80004ace:	02e7e963          	bltu	a5,a4,80004b00 <argfd+0x50>
    80004ad2:	860fd0ef          	jal	ra,80001b32 <myproc>
    80004ad6:	fdc42703          	lw	a4,-36(s0)
    80004ada:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffdcbf2>
    80004ade:	078e                	slli	a5,a5,0x3
    80004ae0:	953e                	add	a0,a0,a5
    80004ae2:	611c                	ld	a5,0(a0)
    80004ae4:	c385                	beqz	a5,80004b04 <argfd+0x54>
    return -1;
  if(pfd)
    80004ae6:	00090463          	beqz	s2,80004aee <argfd+0x3e>
    *pfd = fd;
    80004aea:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004aee:	4501                	li	a0,0
  if(pf)
    80004af0:	c091                	beqz	s1,80004af4 <argfd+0x44>
    *pf = f;
    80004af2:	e09c                	sd	a5,0(s1)
}
    80004af4:	70a2                	ld	ra,40(sp)
    80004af6:	7402                	ld	s0,32(sp)
    80004af8:	64e2                	ld	s1,24(sp)
    80004afa:	6942                	ld	s2,16(sp)
    80004afc:	6145                	addi	sp,sp,48
    80004afe:	8082                	ret
    return -1;
    80004b00:	557d                	li	a0,-1
    80004b02:	bfcd                	j	80004af4 <argfd+0x44>
    80004b04:	557d                	li	a0,-1
    80004b06:	b7fd                	j	80004af4 <argfd+0x44>

0000000080004b08 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004b08:	1101                	addi	sp,sp,-32
    80004b0a:	ec06                	sd	ra,24(sp)
    80004b0c:	e822                	sd	s0,16(sp)
    80004b0e:	e426                	sd	s1,8(sp)
    80004b10:	1000                	addi	s0,sp,32
    80004b12:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004b14:	81efd0ef          	jal	ra,80001b32 <myproc>
    80004b18:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004b1a:	0d050793          	addi	a5,a0,208
    80004b1e:	4501                	li	a0,0
    80004b20:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004b22:	6398                	ld	a4,0(a5)
    80004b24:	cb19                	beqz	a4,80004b3a <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004b26:	2505                	addiw	a0,a0,1
    80004b28:	07a1                	addi	a5,a5,8
    80004b2a:	fed51ce3          	bne	a0,a3,80004b22 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004b2e:	557d                	li	a0,-1
}
    80004b30:	60e2                	ld	ra,24(sp)
    80004b32:	6442                	ld	s0,16(sp)
    80004b34:	64a2                	ld	s1,8(sp)
    80004b36:	6105                	addi	sp,sp,32
    80004b38:	8082                	ret
      p->ofile[fd] = f;
    80004b3a:	01a50793          	addi	a5,a0,26
    80004b3e:	078e                	slli	a5,a5,0x3
    80004b40:	963e                	add	a2,a2,a5
    80004b42:	e204                	sd	s1,0(a2)
      return fd;
    80004b44:	b7f5                	j	80004b30 <fdalloc+0x28>

0000000080004b46 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004b46:	715d                	addi	sp,sp,-80
    80004b48:	e486                	sd	ra,72(sp)
    80004b4a:	e0a2                	sd	s0,64(sp)
    80004b4c:	fc26                	sd	s1,56(sp)
    80004b4e:	f84a                	sd	s2,48(sp)
    80004b50:	f44e                	sd	s3,40(sp)
    80004b52:	f052                	sd	s4,32(sp)
    80004b54:	ec56                	sd	s5,24(sp)
    80004b56:	e85a                	sd	s6,16(sp)
    80004b58:	0880                	addi	s0,sp,80
    80004b5a:	8b2e                	mv	s6,a1
    80004b5c:	89b2                	mv	s3,a2
    80004b5e:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004b60:	fb040593          	addi	a1,s0,-80
    80004b64:	8d8ff0ef          	jal	ra,80003c3c <nameiparent>
    80004b68:	84aa                	mv	s1,a0
    80004b6a:	10050b63          	beqz	a0,80004c80 <create+0x13a>
    return 0;

  ilock(dp);
    80004b6e:	8c7fe0ef          	jal	ra,80003434 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004b72:	4601                	li	a2,0
    80004b74:	fb040593          	addi	a1,s0,-80
    80004b78:	8526                	mv	a0,s1
    80004b7a:	e43fe0ef          	jal	ra,800039bc <dirlookup>
    80004b7e:	8aaa                	mv	s5,a0
    80004b80:	c521                	beqz	a0,80004bc8 <create+0x82>
    iunlockput(dp);
    80004b82:	8526                	mv	a0,s1
    80004b84:	ab7fe0ef          	jal	ra,8000363a <iunlockput>
    ilock(ip);
    80004b88:	8556                	mv	a0,s5
    80004b8a:	8abfe0ef          	jal	ra,80003434 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004b8e:	000b059b          	sext.w	a1,s6
    80004b92:	4789                	li	a5,2
    80004b94:	02f59563          	bne	a1,a5,80004bbe <create+0x78>
    80004b98:	044ad783          	lhu	a5,68(s5)
    80004b9c:	37f9                	addiw	a5,a5,-2
    80004b9e:	17c2                	slli	a5,a5,0x30
    80004ba0:	93c1                	srli	a5,a5,0x30
    80004ba2:	4705                	li	a4,1
    80004ba4:	00f76d63          	bltu	a4,a5,80004bbe <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004ba8:	8556                	mv	a0,s5
    80004baa:	60a6                	ld	ra,72(sp)
    80004bac:	6406                	ld	s0,64(sp)
    80004bae:	74e2                	ld	s1,56(sp)
    80004bb0:	7942                	ld	s2,48(sp)
    80004bb2:	79a2                	ld	s3,40(sp)
    80004bb4:	7a02                	ld	s4,32(sp)
    80004bb6:	6ae2                	ld	s5,24(sp)
    80004bb8:	6b42                	ld	s6,16(sp)
    80004bba:	6161                	addi	sp,sp,80
    80004bbc:	8082                	ret
    iunlockput(ip);
    80004bbe:	8556                	mv	a0,s5
    80004bc0:	a7bfe0ef          	jal	ra,8000363a <iunlockput>
    return 0;
    80004bc4:	4a81                	li	s5,0
    80004bc6:	b7cd                	j	80004ba8 <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004bc8:	85da                	mv	a1,s6
    80004bca:	4088                	lw	a0,0(s1)
    80004bcc:	f00fe0ef          	jal	ra,800032cc <ialloc>
    80004bd0:	8a2a                	mv	s4,a0
    80004bd2:	cd1d                	beqz	a0,80004c10 <create+0xca>
  ilock(ip);
    80004bd4:	861fe0ef          	jal	ra,80003434 <ilock>
  ip->major = major;
    80004bd8:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004bdc:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004be0:	4905                	li	s2,1
    80004be2:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004be6:	8552                	mv	a0,s4
    80004be8:	f9afe0ef          	jal	ra,80003382 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004bec:	000b059b          	sext.w	a1,s6
    80004bf0:	03258563          	beq	a1,s2,80004c1a <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    80004bf4:	004a2603          	lw	a2,4(s4)
    80004bf8:	fb040593          	addi	a1,s0,-80
    80004bfc:	8526                	mv	a0,s1
    80004bfe:	f8bfe0ef          	jal	ra,80003b88 <dirlink>
    80004c02:	06054363          	bltz	a0,80004c68 <create+0x122>
  iunlockput(dp);
    80004c06:	8526                	mv	a0,s1
    80004c08:	a33fe0ef          	jal	ra,8000363a <iunlockput>
  return ip;
    80004c0c:	8ad2                	mv	s5,s4
    80004c0e:	bf69                	j	80004ba8 <create+0x62>
    iunlockput(dp);
    80004c10:	8526                	mv	a0,s1
    80004c12:	a29fe0ef          	jal	ra,8000363a <iunlockput>
    return 0;
    80004c16:	8ad2                	mv	s5,s4
    80004c18:	bf41                	j	80004ba8 <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004c1a:	004a2603          	lw	a2,4(s4)
    80004c1e:	00003597          	auipc	a1,0x3
    80004c22:	d6a58593          	addi	a1,a1,-662 # 80007988 <syscalls+0x3b0>
    80004c26:	8552                	mv	a0,s4
    80004c28:	f61fe0ef          	jal	ra,80003b88 <dirlink>
    80004c2c:	02054e63          	bltz	a0,80004c68 <create+0x122>
    80004c30:	40d0                	lw	a2,4(s1)
    80004c32:	00003597          	auipc	a1,0x3
    80004c36:	d5e58593          	addi	a1,a1,-674 # 80007990 <syscalls+0x3b8>
    80004c3a:	8552                	mv	a0,s4
    80004c3c:	f4dfe0ef          	jal	ra,80003b88 <dirlink>
    80004c40:	02054463          	bltz	a0,80004c68 <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    80004c44:	004a2603          	lw	a2,4(s4)
    80004c48:	fb040593          	addi	a1,s0,-80
    80004c4c:	8526                	mv	a0,s1
    80004c4e:	f3bfe0ef          	jal	ra,80003b88 <dirlink>
    80004c52:	00054b63          	bltz	a0,80004c68 <create+0x122>
    dp->nlink++;  // for ".."
    80004c56:	04a4d783          	lhu	a5,74(s1)
    80004c5a:	2785                	addiw	a5,a5,1
    80004c5c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004c60:	8526                	mv	a0,s1
    80004c62:	f20fe0ef          	jal	ra,80003382 <iupdate>
    80004c66:	b745                	j	80004c06 <create+0xc0>
  ip->nlink = 0;
    80004c68:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004c6c:	8552                	mv	a0,s4
    80004c6e:	f14fe0ef          	jal	ra,80003382 <iupdate>
  iunlockput(ip);
    80004c72:	8552                	mv	a0,s4
    80004c74:	9c7fe0ef          	jal	ra,8000363a <iunlockput>
  iunlockput(dp);
    80004c78:	8526                	mv	a0,s1
    80004c7a:	9c1fe0ef          	jal	ra,8000363a <iunlockput>
  return 0;
    80004c7e:	b72d                	j	80004ba8 <create+0x62>
    return 0;
    80004c80:	8aaa                	mv	s5,a0
    80004c82:	b71d                	j	80004ba8 <create+0x62>

0000000080004c84 <sys_dup>:
{
    80004c84:	7179                	addi	sp,sp,-48
    80004c86:	f406                	sd	ra,40(sp)
    80004c88:	f022                	sd	s0,32(sp)
    80004c8a:	ec26                	sd	s1,24(sp)
    80004c8c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004c8e:	fd840613          	addi	a2,s0,-40
    80004c92:	4581                	li	a1,0
    80004c94:	4501                	li	a0,0
    80004c96:	e1bff0ef          	jal	ra,80004ab0 <argfd>
    return -1;
    80004c9a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004c9c:	00054f63          	bltz	a0,80004cba <sys_dup+0x36>
  if((fd=fdalloc(f)) < 0)
    80004ca0:	fd843503          	ld	a0,-40(s0)
    80004ca4:	e65ff0ef          	jal	ra,80004b08 <fdalloc>
    80004ca8:	84aa                	mv	s1,a0
    return -1;
    80004caa:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004cac:	00054763          	bltz	a0,80004cba <sys_dup+0x36>
  filedup(f);
    80004cb0:	fd843503          	ld	a0,-40(s0)
    80004cb4:	d26ff0ef          	jal	ra,800041da <filedup>
  return fd;
    80004cb8:	87a6                	mv	a5,s1
}
    80004cba:	853e                	mv	a0,a5
    80004cbc:	70a2                	ld	ra,40(sp)
    80004cbe:	7402                	ld	s0,32(sp)
    80004cc0:	64e2                	ld	s1,24(sp)
    80004cc2:	6145                	addi	sp,sp,48
    80004cc4:	8082                	ret

0000000080004cc6 <sys_read>:
{
    80004cc6:	7179                	addi	sp,sp,-48
    80004cc8:	f406                	sd	ra,40(sp)
    80004cca:	f022                	sd	s0,32(sp)
    80004ccc:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004cce:	fd840593          	addi	a1,s0,-40
    80004cd2:	4505                	li	a0,1
    80004cd4:	da5fd0ef          	jal	ra,80002a78 <argaddr>
  argint(2, &n);
    80004cd8:	fe440593          	addi	a1,s0,-28
    80004cdc:	4509                	li	a0,2
    80004cde:	d7ffd0ef          	jal	ra,80002a5c <argint>
  if(argfd(0, 0, &f) < 0)
    80004ce2:	fe840613          	addi	a2,s0,-24
    80004ce6:	4581                	li	a1,0
    80004ce8:	4501                	li	a0,0
    80004cea:	dc7ff0ef          	jal	ra,80004ab0 <argfd>
    80004cee:	87aa                	mv	a5,a0
    return -1;
    80004cf0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004cf2:	0007ca63          	bltz	a5,80004d06 <sys_read+0x40>
  return fileread(f, p, n);
    80004cf6:	fe442603          	lw	a2,-28(s0)
    80004cfa:	fd843583          	ld	a1,-40(s0)
    80004cfe:	fe843503          	ld	a0,-24(s0)
    80004d02:	e24ff0ef          	jal	ra,80004326 <fileread>
}
    80004d06:	70a2                	ld	ra,40(sp)
    80004d08:	7402                	ld	s0,32(sp)
    80004d0a:	6145                	addi	sp,sp,48
    80004d0c:	8082                	ret

0000000080004d0e <sys_write>:
{
    80004d0e:	7179                	addi	sp,sp,-48
    80004d10:	f406                	sd	ra,40(sp)
    80004d12:	f022                	sd	s0,32(sp)
    80004d14:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004d16:	fd840593          	addi	a1,s0,-40
    80004d1a:	4505                	li	a0,1
    80004d1c:	d5dfd0ef          	jal	ra,80002a78 <argaddr>
  argint(2, &n);
    80004d20:	fe440593          	addi	a1,s0,-28
    80004d24:	4509                	li	a0,2
    80004d26:	d37fd0ef          	jal	ra,80002a5c <argint>
  if(argfd(0, 0, &f) < 0)
    80004d2a:	fe840613          	addi	a2,s0,-24
    80004d2e:	4581                	li	a1,0
    80004d30:	4501                	li	a0,0
    80004d32:	d7fff0ef          	jal	ra,80004ab0 <argfd>
    80004d36:	87aa                	mv	a5,a0
    return -1;
    80004d38:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d3a:	0007ca63          	bltz	a5,80004d4e <sys_write+0x40>
  return filewrite(f, p, n);
    80004d3e:	fe442603          	lw	a2,-28(s0)
    80004d42:	fd843583          	ld	a1,-40(s0)
    80004d46:	fe843503          	ld	a0,-24(s0)
    80004d4a:	e8aff0ef          	jal	ra,800043d4 <filewrite>
}
    80004d4e:	70a2                	ld	ra,40(sp)
    80004d50:	7402                	ld	s0,32(sp)
    80004d52:	6145                	addi	sp,sp,48
    80004d54:	8082                	ret

0000000080004d56 <sys_close>:
{
    80004d56:	1101                	addi	sp,sp,-32
    80004d58:	ec06                	sd	ra,24(sp)
    80004d5a:	e822                	sd	s0,16(sp)
    80004d5c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004d5e:	fe040613          	addi	a2,s0,-32
    80004d62:	fec40593          	addi	a1,s0,-20
    80004d66:	4501                	li	a0,0
    80004d68:	d49ff0ef          	jal	ra,80004ab0 <argfd>
    return -1;
    80004d6c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004d6e:	02054063          	bltz	a0,80004d8e <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004d72:	dc1fc0ef          	jal	ra,80001b32 <myproc>
    80004d76:	fec42783          	lw	a5,-20(s0)
    80004d7a:	07e9                	addi	a5,a5,26
    80004d7c:	078e                	slli	a5,a5,0x3
    80004d7e:	97aa                	add	a5,a5,a0
    80004d80:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80004d84:	fe043503          	ld	a0,-32(s0)
    80004d88:	c98ff0ef          	jal	ra,80004220 <fileclose>
  return 0;
    80004d8c:	4781                	li	a5,0
}
    80004d8e:	853e                	mv	a0,a5
    80004d90:	60e2                	ld	ra,24(sp)
    80004d92:	6442                	ld	s0,16(sp)
    80004d94:	6105                	addi	sp,sp,32
    80004d96:	8082                	ret

0000000080004d98 <sys_fstat>:
{
    80004d98:	1101                	addi	sp,sp,-32
    80004d9a:	ec06                	sd	ra,24(sp)
    80004d9c:	e822                	sd	s0,16(sp)
    80004d9e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004da0:	fe040593          	addi	a1,s0,-32
    80004da4:	4505                	li	a0,1
    80004da6:	cd3fd0ef          	jal	ra,80002a78 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004daa:	fe840613          	addi	a2,s0,-24
    80004dae:	4581                	li	a1,0
    80004db0:	4501                	li	a0,0
    80004db2:	cffff0ef          	jal	ra,80004ab0 <argfd>
    80004db6:	87aa                	mv	a5,a0
    return -1;
    80004db8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004dba:	0007c863          	bltz	a5,80004dca <sys_fstat+0x32>
  return filestat(f, st);
    80004dbe:	fe043583          	ld	a1,-32(s0)
    80004dc2:	fe843503          	ld	a0,-24(s0)
    80004dc6:	d02ff0ef          	jal	ra,800042c8 <filestat>
}
    80004dca:	60e2                	ld	ra,24(sp)
    80004dcc:	6442                	ld	s0,16(sp)
    80004dce:	6105                	addi	sp,sp,32
    80004dd0:	8082                	ret

0000000080004dd2 <sys_link>:
{
    80004dd2:	7169                	addi	sp,sp,-304
    80004dd4:	f606                	sd	ra,296(sp)
    80004dd6:	f222                	sd	s0,288(sp)
    80004dd8:	ee26                	sd	s1,280(sp)
    80004dda:	ea4a                	sd	s2,272(sp)
    80004ddc:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004dde:	08000613          	li	a2,128
    80004de2:	ed040593          	addi	a1,s0,-304
    80004de6:	4501                	li	a0,0
    80004de8:	cadfd0ef          	jal	ra,80002a94 <argstr>
    return -1;
    80004dec:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004dee:	0c054663          	bltz	a0,80004eba <sys_link+0xe8>
    80004df2:	08000613          	li	a2,128
    80004df6:	f5040593          	addi	a1,s0,-176
    80004dfa:	4505                	li	a0,1
    80004dfc:	c99fd0ef          	jal	ra,80002a94 <argstr>
    return -1;
    80004e00:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004e02:	0a054c63          	bltz	a0,80004eba <sys_link+0xe8>
  begin_op();
    80004e06:	80cff0ef          	jal	ra,80003e12 <begin_op>
  if((ip = namei(old)) == 0){
    80004e0a:	ed040513          	addi	a0,s0,-304
    80004e0e:	e15fe0ef          	jal	ra,80003c22 <namei>
    80004e12:	84aa                	mv	s1,a0
    80004e14:	c525                	beqz	a0,80004e7c <sys_link+0xaa>
  ilock(ip);
    80004e16:	e1efe0ef          	jal	ra,80003434 <ilock>
  if(ip->type == T_DIR){
    80004e1a:	04449703          	lh	a4,68(s1)
    80004e1e:	4785                	li	a5,1
    80004e20:	06f70263          	beq	a4,a5,80004e84 <sys_link+0xb2>
  ip->nlink++;
    80004e24:	04a4d783          	lhu	a5,74(s1)
    80004e28:	2785                	addiw	a5,a5,1
    80004e2a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004e2e:	8526                	mv	a0,s1
    80004e30:	d52fe0ef          	jal	ra,80003382 <iupdate>
  iunlock(ip);
    80004e34:	8526                	mv	a0,s1
    80004e36:	ea8fe0ef          	jal	ra,800034de <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004e3a:	fd040593          	addi	a1,s0,-48
    80004e3e:	f5040513          	addi	a0,s0,-176
    80004e42:	dfbfe0ef          	jal	ra,80003c3c <nameiparent>
    80004e46:	892a                	mv	s2,a0
    80004e48:	c921                	beqz	a0,80004e98 <sys_link+0xc6>
  ilock(dp);
    80004e4a:	deafe0ef          	jal	ra,80003434 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004e4e:	00092703          	lw	a4,0(s2)
    80004e52:	409c                	lw	a5,0(s1)
    80004e54:	02f71f63          	bne	a4,a5,80004e92 <sys_link+0xc0>
    80004e58:	40d0                	lw	a2,4(s1)
    80004e5a:	fd040593          	addi	a1,s0,-48
    80004e5e:	854a                	mv	a0,s2
    80004e60:	d29fe0ef          	jal	ra,80003b88 <dirlink>
    80004e64:	02054763          	bltz	a0,80004e92 <sys_link+0xc0>
  iunlockput(dp);
    80004e68:	854a                	mv	a0,s2
    80004e6a:	fd0fe0ef          	jal	ra,8000363a <iunlockput>
  iput(ip);
    80004e6e:	8526                	mv	a0,s1
    80004e70:	f42fe0ef          	jal	ra,800035b2 <iput>
  end_op();
    80004e74:	80eff0ef          	jal	ra,80003e82 <end_op>
  return 0;
    80004e78:	4781                	li	a5,0
    80004e7a:	a081                	j	80004eba <sys_link+0xe8>
    end_op();
    80004e7c:	806ff0ef          	jal	ra,80003e82 <end_op>
    return -1;
    80004e80:	57fd                	li	a5,-1
    80004e82:	a825                	j	80004eba <sys_link+0xe8>
    iunlockput(ip);
    80004e84:	8526                	mv	a0,s1
    80004e86:	fb4fe0ef          	jal	ra,8000363a <iunlockput>
    end_op();
    80004e8a:	ff9fe0ef          	jal	ra,80003e82 <end_op>
    return -1;
    80004e8e:	57fd                	li	a5,-1
    80004e90:	a02d                	j	80004eba <sys_link+0xe8>
    iunlockput(dp);
    80004e92:	854a                	mv	a0,s2
    80004e94:	fa6fe0ef          	jal	ra,8000363a <iunlockput>
  ilock(ip);
    80004e98:	8526                	mv	a0,s1
    80004e9a:	d9afe0ef          	jal	ra,80003434 <ilock>
  ip->nlink--;
    80004e9e:	04a4d783          	lhu	a5,74(s1)
    80004ea2:	37fd                	addiw	a5,a5,-1
    80004ea4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004ea8:	8526                	mv	a0,s1
    80004eaa:	cd8fe0ef          	jal	ra,80003382 <iupdate>
  iunlockput(ip);
    80004eae:	8526                	mv	a0,s1
    80004eb0:	f8afe0ef          	jal	ra,8000363a <iunlockput>
  end_op();
    80004eb4:	fcffe0ef          	jal	ra,80003e82 <end_op>
  return -1;
    80004eb8:	57fd                	li	a5,-1
}
    80004eba:	853e                	mv	a0,a5
    80004ebc:	70b2                	ld	ra,296(sp)
    80004ebe:	7412                	ld	s0,288(sp)
    80004ec0:	64f2                	ld	s1,280(sp)
    80004ec2:	6952                	ld	s2,272(sp)
    80004ec4:	6155                	addi	sp,sp,304
    80004ec6:	8082                	ret

0000000080004ec8 <sys_unlink>:
{
    80004ec8:	7151                	addi	sp,sp,-240
    80004eca:	f586                	sd	ra,232(sp)
    80004ecc:	f1a2                	sd	s0,224(sp)
    80004ece:	eda6                	sd	s1,216(sp)
    80004ed0:	e9ca                	sd	s2,208(sp)
    80004ed2:	e5ce                	sd	s3,200(sp)
    80004ed4:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004ed6:	08000613          	li	a2,128
    80004eda:	f3040593          	addi	a1,s0,-208
    80004ede:	4501                	li	a0,0
    80004ee0:	bb5fd0ef          	jal	ra,80002a94 <argstr>
    80004ee4:	12054b63          	bltz	a0,8000501a <sys_unlink+0x152>
  begin_op();
    80004ee8:	f2bfe0ef          	jal	ra,80003e12 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004eec:	fb040593          	addi	a1,s0,-80
    80004ef0:	f3040513          	addi	a0,s0,-208
    80004ef4:	d49fe0ef          	jal	ra,80003c3c <nameiparent>
    80004ef8:	84aa                	mv	s1,a0
    80004efa:	c54d                	beqz	a0,80004fa4 <sys_unlink+0xdc>
  ilock(dp);
    80004efc:	d38fe0ef          	jal	ra,80003434 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004f00:	00003597          	auipc	a1,0x3
    80004f04:	a8858593          	addi	a1,a1,-1400 # 80007988 <syscalls+0x3b0>
    80004f08:	fb040513          	addi	a0,s0,-80
    80004f0c:	a9bfe0ef          	jal	ra,800039a6 <namecmp>
    80004f10:	10050a63          	beqz	a0,80005024 <sys_unlink+0x15c>
    80004f14:	00003597          	auipc	a1,0x3
    80004f18:	a7c58593          	addi	a1,a1,-1412 # 80007990 <syscalls+0x3b8>
    80004f1c:	fb040513          	addi	a0,s0,-80
    80004f20:	a87fe0ef          	jal	ra,800039a6 <namecmp>
    80004f24:	10050063          	beqz	a0,80005024 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004f28:	f2c40613          	addi	a2,s0,-212
    80004f2c:	fb040593          	addi	a1,s0,-80
    80004f30:	8526                	mv	a0,s1
    80004f32:	a8bfe0ef          	jal	ra,800039bc <dirlookup>
    80004f36:	892a                	mv	s2,a0
    80004f38:	0e050663          	beqz	a0,80005024 <sys_unlink+0x15c>
  ilock(ip);
    80004f3c:	cf8fe0ef          	jal	ra,80003434 <ilock>
  if(ip->nlink < 1)
    80004f40:	04a91783          	lh	a5,74(s2)
    80004f44:	06f05463          	blez	a5,80004fac <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004f48:	04491703          	lh	a4,68(s2)
    80004f4c:	4785                	li	a5,1
    80004f4e:	06f70563          	beq	a4,a5,80004fb8 <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    80004f52:	4641                	li	a2,16
    80004f54:	4581                	li	a1,0
    80004f56:	fc040513          	addi	a0,s0,-64
    80004f5a:	ce7fb0ef          	jal	ra,80000c40 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f5e:	4741                	li	a4,16
    80004f60:	f2c42683          	lw	a3,-212(s0)
    80004f64:	fc040613          	addi	a2,s0,-64
    80004f68:	4581                	li	a1,0
    80004f6a:	8526                	mv	a0,s1
    80004f6c:	939fe0ef          	jal	ra,800038a4 <writei>
    80004f70:	47c1                	li	a5,16
    80004f72:	08f51563          	bne	a0,a5,80004ffc <sys_unlink+0x134>
  if(ip->type == T_DIR){
    80004f76:	04491703          	lh	a4,68(s2)
    80004f7a:	4785                	li	a5,1
    80004f7c:	08f70663          	beq	a4,a5,80005008 <sys_unlink+0x140>
  iunlockput(dp);
    80004f80:	8526                	mv	a0,s1
    80004f82:	eb8fe0ef          	jal	ra,8000363a <iunlockput>
  ip->nlink--;
    80004f86:	04a95783          	lhu	a5,74(s2)
    80004f8a:	37fd                	addiw	a5,a5,-1
    80004f8c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004f90:	854a                	mv	a0,s2
    80004f92:	bf0fe0ef          	jal	ra,80003382 <iupdate>
  iunlockput(ip);
    80004f96:	854a                	mv	a0,s2
    80004f98:	ea2fe0ef          	jal	ra,8000363a <iunlockput>
  end_op();
    80004f9c:	ee7fe0ef          	jal	ra,80003e82 <end_op>
  return 0;
    80004fa0:	4501                	li	a0,0
    80004fa2:	a079                	j	80005030 <sys_unlink+0x168>
    end_op();
    80004fa4:	edffe0ef          	jal	ra,80003e82 <end_op>
    return -1;
    80004fa8:	557d                	li	a0,-1
    80004faa:	a059                	j	80005030 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80004fac:	00003517          	auipc	a0,0x3
    80004fb0:	9ec50513          	addi	a0,a0,-1556 # 80007998 <syscalls+0x3c0>
    80004fb4:	fd6fb0ef          	jal	ra,8000078a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004fb8:	04c92703          	lw	a4,76(s2)
    80004fbc:	02000793          	li	a5,32
    80004fc0:	f8e7f9e3          	bgeu	a5,a4,80004f52 <sys_unlink+0x8a>
    80004fc4:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004fc8:	4741                	li	a4,16
    80004fca:	86ce                	mv	a3,s3
    80004fcc:	f1840613          	addi	a2,s0,-232
    80004fd0:	4581                	li	a1,0
    80004fd2:	854a                	mv	a0,s2
    80004fd4:	fecfe0ef          	jal	ra,800037c0 <readi>
    80004fd8:	47c1                	li	a5,16
    80004fda:	00f51b63          	bne	a0,a5,80004ff0 <sys_unlink+0x128>
    if(de.inum != 0)
    80004fde:	f1845783          	lhu	a5,-232(s0)
    80004fe2:	ef95                	bnez	a5,8000501e <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004fe4:	29c1                	addiw	s3,s3,16
    80004fe6:	04c92783          	lw	a5,76(s2)
    80004fea:	fcf9efe3          	bltu	s3,a5,80004fc8 <sys_unlink+0x100>
    80004fee:	b795                	j	80004f52 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004ff0:	00003517          	auipc	a0,0x3
    80004ff4:	9c050513          	addi	a0,a0,-1600 # 800079b0 <syscalls+0x3d8>
    80004ff8:	f92fb0ef          	jal	ra,8000078a <panic>
    panic("unlink: writei");
    80004ffc:	00003517          	auipc	a0,0x3
    80005000:	9cc50513          	addi	a0,a0,-1588 # 800079c8 <syscalls+0x3f0>
    80005004:	f86fb0ef          	jal	ra,8000078a <panic>
    dp->nlink--;
    80005008:	04a4d783          	lhu	a5,74(s1)
    8000500c:	37fd                	addiw	a5,a5,-1
    8000500e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005012:	8526                	mv	a0,s1
    80005014:	b6efe0ef          	jal	ra,80003382 <iupdate>
    80005018:	b7a5                	j	80004f80 <sys_unlink+0xb8>
    return -1;
    8000501a:	557d                	li	a0,-1
    8000501c:	a811                	j	80005030 <sys_unlink+0x168>
    iunlockput(ip);
    8000501e:	854a                	mv	a0,s2
    80005020:	e1afe0ef          	jal	ra,8000363a <iunlockput>
  iunlockput(dp);
    80005024:	8526                	mv	a0,s1
    80005026:	e14fe0ef          	jal	ra,8000363a <iunlockput>
  end_op();
    8000502a:	e59fe0ef          	jal	ra,80003e82 <end_op>
  return -1;
    8000502e:	557d                	li	a0,-1
}
    80005030:	70ae                	ld	ra,232(sp)
    80005032:	740e                	ld	s0,224(sp)
    80005034:	64ee                	ld	s1,216(sp)
    80005036:	694e                	ld	s2,208(sp)
    80005038:	69ae                	ld	s3,200(sp)
    8000503a:	616d                	addi	sp,sp,240
    8000503c:	8082                	ret

000000008000503e <sys_open>:

uint64
sys_open(void)
{
    8000503e:	7131                	addi	sp,sp,-192
    80005040:	fd06                	sd	ra,184(sp)
    80005042:	f922                	sd	s0,176(sp)
    80005044:	f526                	sd	s1,168(sp)
    80005046:	f14a                	sd	s2,160(sp)
    80005048:	ed4e                	sd	s3,152(sp)
    8000504a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000504c:	f4c40593          	addi	a1,s0,-180
    80005050:	4505                	li	a0,1
    80005052:	a0bfd0ef          	jal	ra,80002a5c <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005056:	08000613          	li	a2,128
    8000505a:	f5040593          	addi	a1,s0,-176
    8000505e:	4501                	li	a0,0
    80005060:	a35fd0ef          	jal	ra,80002a94 <argstr>
    80005064:	87aa                	mv	a5,a0
    return -1;
    80005066:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005068:	0807cd63          	bltz	a5,80005102 <sys_open+0xc4>

  begin_op();
    8000506c:	da7fe0ef          	jal	ra,80003e12 <begin_op>

  if(omode & O_CREATE){
    80005070:	f4c42783          	lw	a5,-180(s0)
    80005074:	2007f793          	andi	a5,a5,512
    80005078:	c3c5                	beqz	a5,80005118 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    8000507a:	4681                	li	a3,0
    8000507c:	4601                	li	a2,0
    8000507e:	4589                	li	a1,2
    80005080:	f5040513          	addi	a0,s0,-176
    80005084:	ac3ff0ef          	jal	ra,80004b46 <create>
    80005088:	84aa                	mv	s1,a0
    if(ip == 0){
    8000508a:	c159                	beqz	a0,80005110 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000508c:	04449703          	lh	a4,68(s1)
    80005090:	478d                	li	a5,3
    80005092:	00f71763          	bne	a4,a5,800050a0 <sys_open+0x62>
    80005096:	0464d703          	lhu	a4,70(s1)
    8000509a:	47a5                	li	a5,9
    8000509c:	0ae7e963          	bltu	a5,a4,8000514e <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800050a0:	8dcff0ef          	jal	ra,8000417c <filealloc>
    800050a4:	89aa                	mv	s3,a0
    800050a6:	0c050963          	beqz	a0,80005178 <sys_open+0x13a>
    800050aa:	a5fff0ef          	jal	ra,80004b08 <fdalloc>
    800050ae:	892a                	mv	s2,a0
    800050b0:	0c054163          	bltz	a0,80005172 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800050b4:	04449703          	lh	a4,68(s1)
    800050b8:	478d                	li	a5,3
    800050ba:	0af70163          	beq	a4,a5,8000515c <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800050be:	4789                	li	a5,2
    800050c0:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800050c4:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800050c8:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    800050cc:	f4c42783          	lw	a5,-180(s0)
    800050d0:	0017c713          	xori	a4,a5,1
    800050d4:	8b05                	andi	a4,a4,1
    800050d6:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800050da:	0037f713          	andi	a4,a5,3
    800050de:	00e03733          	snez	a4,a4
    800050e2:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800050e6:	4007f793          	andi	a5,a5,1024
    800050ea:	c791                	beqz	a5,800050f6 <sys_open+0xb8>
    800050ec:	04449703          	lh	a4,68(s1)
    800050f0:	4789                	li	a5,2
    800050f2:	06f70c63          	beq	a4,a5,8000516a <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    800050f6:	8526                	mv	a0,s1
    800050f8:	be6fe0ef          	jal	ra,800034de <iunlock>
  end_op();
    800050fc:	d87fe0ef          	jal	ra,80003e82 <end_op>

  return fd;
    80005100:	854a                	mv	a0,s2
}
    80005102:	70ea                	ld	ra,184(sp)
    80005104:	744a                	ld	s0,176(sp)
    80005106:	74aa                	ld	s1,168(sp)
    80005108:	790a                	ld	s2,160(sp)
    8000510a:	69ea                	ld	s3,152(sp)
    8000510c:	6129                	addi	sp,sp,192
    8000510e:	8082                	ret
      end_op();
    80005110:	d73fe0ef          	jal	ra,80003e82 <end_op>
      return -1;
    80005114:	557d                	li	a0,-1
    80005116:	b7f5                	j	80005102 <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    80005118:	f5040513          	addi	a0,s0,-176
    8000511c:	b07fe0ef          	jal	ra,80003c22 <namei>
    80005120:	84aa                	mv	s1,a0
    80005122:	c115                	beqz	a0,80005146 <sys_open+0x108>
    ilock(ip);
    80005124:	b10fe0ef          	jal	ra,80003434 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005128:	04449703          	lh	a4,68(s1)
    8000512c:	4785                	li	a5,1
    8000512e:	f4f71fe3          	bne	a4,a5,8000508c <sys_open+0x4e>
    80005132:	f4c42783          	lw	a5,-180(s0)
    80005136:	d7ad                	beqz	a5,800050a0 <sys_open+0x62>
      iunlockput(ip);
    80005138:	8526                	mv	a0,s1
    8000513a:	d00fe0ef          	jal	ra,8000363a <iunlockput>
      end_op();
    8000513e:	d45fe0ef          	jal	ra,80003e82 <end_op>
      return -1;
    80005142:	557d                	li	a0,-1
    80005144:	bf7d                	j	80005102 <sys_open+0xc4>
      end_op();
    80005146:	d3dfe0ef          	jal	ra,80003e82 <end_op>
      return -1;
    8000514a:	557d                	li	a0,-1
    8000514c:	bf5d                	j	80005102 <sys_open+0xc4>
    iunlockput(ip);
    8000514e:	8526                	mv	a0,s1
    80005150:	ceafe0ef          	jal	ra,8000363a <iunlockput>
    end_op();
    80005154:	d2ffe0ef          	jal	ra,80003e82 <end_op>
    return -1;
    80005158:	557d                	li	a0,-1
    8000515a:	b765                	j	80005102 <sys_open+0xc4>
    f->type = FD_DEVICE;
    8000515c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005160:	04649783          	lh	a5,70(s1)
    80005164:	02f99223          	sh	a5,36(s3)
    80005168:	b785                	j	800050c8 <sys_open+0x8a>
    itrunc(ip);
    8000516a:	8526                	mv	a0,s1
    8000516c:	bb2fe0ef          	jal	ra,8000351e <itrunc>
    80005170:	b759                	j	800050f6 <sys_open+0xb8>
      fileclose(f);
    80005172:	854e                	mv	a0,s3
    80005174:	8acff0ef          	jal	ra,80004220 <fileclose>
    iunlockput(ip);
    80005178:	8526                	mv	a0,s1
    8000517a:	cc0fe0ef          	jal	ra,8000363a <iunlockput>
    end_op();
    8000517e:	d05fe0ef          	jal	ra,80003e82 <end_op>
    return -1;
    80005182:	557d                	li	a0,-1
    80005184:	bfbd                	j	80005102 <sys_open+0xc4>

0000000080005186 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005186:	7175                	addi	sp,sp,-144
    80005188:	e506                	sd	ra,136(sp)
    8000518a:	e122                	sd	s0,128(sp)
    8000518c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000518e:	c85fe0ef          	jal	ra,80003e12 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005192:	08000613          	li	a2,128
    80005196:	f7040593          	addi	a1,s0,-144
    8000519a:	4501                	li	a0,0
    8000519c:	8f9fd0ef          	jal	ra,80002a94 <argstr>
    800051a0:	02054363          	bltz	a0,800051c6 <sys_mkdir+0x40>
    800051a4:	4681                	li	a3,0
    800051a6:	4601                	li	a2,0
    800051a8:	4585                	li	a1,1
    800051aa:	f7040513          	addi	a0,s0,-144
    800051ae:	999ff0ef          	jal	ra,80004b46 <create>
    800051b2:	c911                	beqz	a0,800051c6 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800051b4:	c86fe0ef          	jal	ra,8000363a <iunlockput>
  end_op();
    800051b8:	ccbfe0ef          	jal	ra,80003e82 <end_op>
  return 0;
    800051bc:	4501                	li	a0,0
}
    800051be:	60aa                	ld	ra,136(sp)
    800051c0:	640a                	ld	s0,128(sp)
    800051c2:	6149                	addi	sp,sp,144
    800051c4:	8082                	ret
    end_op();
    800051c6:	cbdfe0ef          	jal	ra,80003e82 <end_op>
    return -1;
    800051ca:	557d                	li	a0,-1
    800051cc:	bfcd                	j	800051be <sys_mkdir+0x38>

00000000800051ce <sys_mknod>:

uint64
sys_mknod(void)
{
    800051ce:	7135                	addi	sp,sp,-160
    800051d0:	ed06                	sd	ra,152(sp)
    800051d2:	e922                	sd	s0,144(sp)
    800051d4:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800051d6:	c3dfe0ef          	jal	ra,80003e12 <begin_op>
  argint(1, &major);
    800051da:	f6c40593          	addi	a1,s0,-148
    800051de:	4505                	li	a0,1
    800051e0:	87dfd0ef          	jal	ra,80002a5c <argint>
  argint(2, &minor);
    800051e4:	f6840593          	addi	a1,s0,-152
    800051e8:	4509                	li	a0,2
    800051ea:	873fd0ef          	jal	ra,80002a5c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800051ee:	08000613          	li	a2,128
    800051f2:	f7040593          	addi	a1,s0,-144
    800051f6:	4501                	li	a0,0
    800051f8:	89dfd0ef          	jal	ra,80002a94 <argstr>
    800051fc:	02054563          	bltz	a0,80005226 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005200:	f6841683          	lh	a3,-152(s0)
    80005204:	f6c41603          	lh	a2,-148(s0)
    80005208:	458d                	li	a1,3
    8000520a:	f7040513          	addi	a0,s0,-144
    8000520e:	939ff0ef          	jal	ra,80004b46 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005212:	c911                	beqz	a0,80005226 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005214:	c26fe0ef          	jal	ra,8000363a <iunlockput>
  end_op();
    80005218:	c6bfe0ef          	jal	ra,80003e82 <end_op>
  return 0;
    8000521c:	4501                	li	a0,0
}
    8000521e:	60ea                	ld	ra,152(sp)
    80005220:	644a                	ld	s0,144(sp)
    80005222:	610d                	addi	sp,sp,160
    80005224:	8082                	ret
    end_op();
    80005226:	c5dfe0ef          	jal	ra,80003e82 <end_op>
    return -1;
    8000522a:	557d                	li	a0,-1
    8000522c:	bfcd                	j	8000521e <sys_mknod+0x50>

000000008000522e <sys_chdir>:

uint64
sys_chdir(void)
{
    8000522e:	7135                	addi	sp,sp,-160
    80005230:	ed06                	sd	ra,152(sp)
    80005232:	e922                	sd	s0,144(sp)
    80005234:	e526                	sd	s1,136(sp)
    80005236:	e14a                	sd	s2,128(sp)
    80005238:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000523a:	8f9fc0ef          	jal	ra,80001b32 <myproc>
    8000523e:	892a                	mv	s2,a0
  
  begin_op();
    80005240:	bd3fe0ef          	jal	ra,80003e12 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005244:	08000613          	li	a2,128
    80005248:	f6040593          	addi	a1,s0,-160
    8000524c:	4501                	li	a0,0
    8000524e:	847fd0ef          	jal	ra,80002a94 <argstr>
    80005252:	04054163          	bltz	a0,80005294 <sys_chdir+0x66>
    80005256:	f6040513          	addi	a0,s0,-160
    8000525a:	9c9fe0ef          	jal	ra,80003c22 <namei>
    8000525e:	84aa                	mv	s1,a0
    80005260:	c915                	beqz	a0,80005294 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005262:	9d2fe0ef          	jal	ra,80003434 <ilock>
  if(ip->type != T_DIR){
    80005266:	04449703          	lh	a4,68(s1)
    8000526a:	4785                	li	a5,1
    8000526c:	02f71863          	bne	a4,a5,8000529c <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005270:	8526                	mv	a0,s1
    80005272:	a6cfe0ef          	jal	ra,800034de <iunlock>
  iput(p->cwd);
    80005276:	15093503          	ld	a0,336(s2)
    8000527a:	b38fe0ef          	jal	ra,800035b2 <iput>
  end_op();
    8000527e:	c05fe0ef          	jal	ra,80003e82 <end_op>
  p->cwd = ip;
    80005282:	14993823          	sd	s1,336(s2)
  return 0;
    80005286:	4501                	li	a0,0
}
    80005288:	60ea                	ld	ra,152(sp)
    8000528a:	644a                	ld	s0,144(sp)
    8000528c:	64aa                	ld	s1,136(sp)
    8000528e:	690a                	ld	s2,128(sp)
    80005290:	610d                	addi	sp,sp,160
    80005292:	8082                	ret
    end_op();
    80005294:	beffe0ef          	jal	ra,80003e82 <end_op>
    return -1;
    80005298:	557d                	li	a0,-1
    8000529a:	b7fd                	j	80005288 <sys_chdir+0x5a>
    iunlockput(ip);
    8000529c:	8526                	mv	a0,s1
    8000529e:	b9cfe0ef          	jal	ra,8000363a <iunlockput>
    end_op();
    800052a2:	be1fe0ef          	jal	ra,80003e82 <end_op>
    return -1;
    800052a6:	557d                	li	a0,-1
    800052a8:	b7c5                	j	80005288 <sys_chdir+0x5a>

00000000800052aa <sys_exec>:

uint64
sys_exec(void)
{
    800052aa:	7145                	addi	sp,sp,-464
    800052ac:	e786                	sd	ra,456(sp)
    800052ae:	e3a2                	sd	s0,448(sp)
    800052b0:	ff26                	sd	s1,440(sp)
    800052b2:	fb4a                	sd	s2,432(sp)
    800052b4:	f74e                	sd	s3,424(sp)
    800052b6:	f352                	sd	s4,416(sp)
    800052b8:	ef56                	sd	s5,408(sp)
    800052ba:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800052bc:	e3840593          	addi	a1,s0,-456
    800052c0:	4505                	li	a0,1
    800052c2:	fb6fd0ef          	jal	ra,80002a78 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800052c6:	08000613          	li	a2,128
    800052ca:	f4040593          	addi	a1,s0,-192
    800052ce:	4501                	li	a0,0
    800052d0:	fc4fd0ef          	jal	ra,80002a94 <argstr>
    800052d4:	87aa                	mv	a5,a0
    return -1;
    800052d6:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800052d8:	0a07c463          	bltz	a5,80005380 <sys_exec+0xd6>
  }
  memset(argv, 0, sizeof(argv));
    800052dc:	10000613          	li	a2,256
    800052e0:	4581                	li	a1,0
    800052e2:	e4040513          	addi	a0,s0,-448
    800052e6:	95bfb0ef          	jal	ra,80000c40 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800052ea:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800052ee:	89a6                	mv	s3,s1
    800052f0:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800052f2:	02000a13          	li	s4,32
    800052f6:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800052fa:	00391793          	slli	a5,s2,0x3
    800052fe:	e3040593          	addi	a1,s0,-464
    80005302:	e3843503          	ld	a0,-456(s0)
    80005306:	953e                	add	a0,a0,a5
    80005308:	ecafd0ef          	jal	ra,800029d2 <fetchaddr>
    8000530c:	02054663          	bltz	a0,80005338 <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    80005310:	e3043783          	ld	a5,-464(s0)
    80005314:	cf8d                	beqz	a5,8000534e <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005316:	f86fb0ef          	jal	ra,80000a9c <kalloc>
    8000531a:	85aa                	mv	a1,a0
    8000531c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005320:	cd01                	beqz	a0,80005338 <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005322:	6605                	lui	a2,0x1
    80005324:	e3043503          	ld	a0,-464(s0)
    80005328:	ef4fd0ef          	jal	ra,80002a1c <fetchstr>
    8000532c:	00054663          	bltz	a0,80005338 <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    80005330:	0905                	addi	s2,s2,1
    80005332:	09a1                	addi	s3,s3,8
    80005334:	fd4911e3          	bne	s2,s4,800052f6 <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005338:	10048913          	addi	s2,s1,256
    8000533c:	6088                	ld	a0,0(s1)
    8000533e:	c121                	beqz	a0,8000537e <sys_exec+0xd4>
    kfree(argv[i]);
    80005340:	e7cfb0ef          	jal	ra,800009bc <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005344:	04a1                	addi	s1,s1,8
    80005346:	ff249be3          	bne	s1,s2,8000533c <sys_exec+0x92>
  return -1;
    8000534a:	557d                	li	a0,-1
    8000534c:	a815                	j	80005380 <sys_exec+0xd6>
      argv[i] = 0;
    8000534e:	0a8e                	slli	s5,s5,0x3
    80005350:	fc040793          	addi	a5,s0,-64
    80005354:	9abe                	add	s5,s5,a5
    80005356:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    8000535a:	e4040593          	addi	a1,s0,-448
    8000535e:	f4040513          	addi	a0,s0,-192
    80005362:	c60ff0ef          	jal	ra,800047c2 <kexec>
    80005366:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005368:	10048993          	addi	s3,s1,256
    8000536c:	6088                	ld	a0,0(s1)
    8000536e:	c511                	beqz	a0,8000537a <sys_exec+0xd0>
    kfree(argv[i]);
    80005370:	e4cfb0ef          	jal	ra,800009bc <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005374:	04a1                	addi	s1,s1,8
    80005376:	ff349be3          	bne	s1,s3,8000536c <sys_exec+0xc2>
  return ret;
    8000537a:	854a                	mv	a0,s2
    8000537c:	a011                	j	80005380 <sys_exec+0xd6>
  return -1;
    8000537e:	557d                	li	a0,-1
}
    80005380:	60be                	ld	ra,456(sp)
    80005382:	641e                	ld	s0,448(sp)
    80005384:	74fa                	ld	s1,440(sp)
    80005386:	795a                	ld	s2,432(sp)
    80005388:	79ba                	ld	s3,424(sp)
    8000538a:	7a1a                	ld	s4,416(sp)
    8000538c:	6afa                	ld	s5,408(sp)
    8000538e:	6179                	addi	sp,sp,464
    80005390:	8082                	ret

0000000080005392 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005392:	7139                	addi	sp,sp,-64
    80005394:	fc06                	sd	ra,56(sp)
    80005396:	f822                	sd	s0,48(sp)
    80005398:	f426                	sd	s1,40(sp)
    8000539a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000539c:	f96fc0ef          	jal	ra,80001b32 <myproc>
    800053a0:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800053a2:	fd840593          	addi	a1,s0,-40
    800053a6:	4501                	li	a0,0
    800053a8:	ed0fd0ef          	jal	ra,80002a78 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800053ac:	fc840593          	addi	a1,s0,-56
    800053b0:	fd040513          	addi	a0,s0,-48
    800053b4:	938ff0ef          	jal	ra,800044ec <pipealloc>
    return -1;
    800053b8:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800053ba:	0a054463          	bltz	a0,80005462 <sys_pipe+0xd0>
  fd0 = -1;
    800053be:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800053c2:	fd043503          	ld	a0,-48(s0)
    800053c6:	f42ff0ef          	jal	ra,80004b08 <fdalloc>
    800053ca:	fca42223          	sw	a0,-60(s0)
    800053ce:	08054163          	bltz	a0,80005450 <sys_pipe+0xbe>
    800053d2:	fc843503          	ld	a0,-56(s0)
    800053d6:	f32ff0ef          	jal	ra,80004b08 <fdalloc>
    800053da:	fca42023          	sw	a0,-64(s0)
    800053de:	06054063          	bltz	a0,8000543e <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800053e2:	4691                	li	a3,4
    800053e4:	fc440613          	addi	a2,s0,-60
    800053e8:	fd843583          	ld	a1,-40(s0)
    800053ec:	68a8                	ld	a0,80(s1)
    800053ee:	c92fc0ef          	jal	ra,80001880 <copyout>
    800053f2:	00054e63          	bltz	a0,8000540e <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800053f6:	4691                	li	a3,4
    800053f8:	fc040613          	addi	a2,s0,-64
    800053fc:	fd843583          	ld	a1,-40(s0)
    80005400:	0591                	addi	a1,a1,4
    80005402:	68a8                	ld	a0,80(s1)
    80005404:	c7cfc0ef          	jal	ra,80001880 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005408:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000540a:	04055c63          	bgez	a0,80005462 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    8000540e:	fc442783          	lw	a5,-60(s0)
    80005412:	07e9                	addi	a5,a5,26
    80005414:	078e                	slli	a5,a5,0x3
    80005416:	97a6                	add	a5,a5,s1
    80005418:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000541c:	fc042503          	lw	a0,-64(s0)
    80005420:	0569                	addi	a0,a0,26
    80005422:	050e                	slli	a0,a0,0x3
    80005424:	94aa                	add	s1,s1,a0
    80005426:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000542a:	fd043503          	ld	a0,-48(s0)
    8000542e:	df3fe0ef          	jal	ra,80004220 <fileclose>
    fileclose(wf);
    80005432:	fc843503          	ld	a0,-56(s0)
    80005436:	debfe0ef          	jal	ra,80004220 <fileclose>
    return -1;
    8000543a:	57fd                	li	a5,-1
    8000543c:	a01d                	j	80005462 <sys_pipe+0xd0>
    if(fd0 >= 0)
    8000543e:	fc442783          	lw	a5,-60(s0)
    80005442:	0007c763          	bltz	a5,80005450 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005446:	07e9                	addi	a5,a5,26
    80005448:	078e                	slli	a5,a5,0x3
    8000544a:	94be                	add	s1,s1,a5
    8000544c:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005450:	fd043503          	ld	a0,-48(s0)
    80005454:	dcdfe0ef          	jal	ra,80004220 <fileclose>
    fileclose(wf);
    80005458:	fc843503          	ld	a0,-56(s0)
    8000545c:	dc5fe0ef          	jal	ra,80004220 <fileclose>
    return -1;
    80005460:	57fd                	li	a5,-1
}
    80005462:	853e                	mv	a0,a5
    80005464:	70e2                	ld	ra,56(sp)
    80005466:	7442                	ld	s0,48(sp)
    80005468:	74a2                	ld	s1,40(sp)
    8000546a:	6121                	addi	sp,sp,64
    8000546c:	8082                	ret
	...

0000000080005470 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005470:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005472:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005474:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005476:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005478:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000547a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000547c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000547e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005480:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005482:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005484:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005486:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005488:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000548a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000548c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000548e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005490:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005492:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005494:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005496:	c4cfd0ef          	jal	ra,800028e2 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000549a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000549c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000549e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800054a0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800054a2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800054a4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800054a6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800054a8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800054aa:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800054ac:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800054ae:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800054b0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800054b2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800054b4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800054b6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800054b8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800054ba:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800054bc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800054be:	10200073          	sret
	...

00000000800054ce <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800054ce:	1141                	addi	sp,sp,-16
    800054d0:	e422                	sd	s0,8(sp)
    800054d2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800054d4:	0c0007b7          	lui	a5,0xc000
    800054d8:	4705                	li	a4,1
    800054da:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800054dc:	c3d8                	sw	a4,4(a5)
}
    800054de:	6422                	ld	s0,8(sp)
    800054e0:	0141                	addi	sp,sp,16
    800054e2:	8082                	ret

00000000800054e4 <plicinithart>:

void
plicinithart(void)
{
    800054e4:	1141                	addi	sp,sp,-16
    800054e6:	e406                	sd	ra,8(sp)
    800054e8:	e022                	sd	s0,0(sp)
    800054ea:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800054ec:	e1afc0ef          	jal	ra,80001b06 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800054f0:	0085171b          	slliw	a4,a0,0x8
    800054f4:	0c0027b7          	lui	a5,0xc002
    800054f8:	97ba                	add	a5,a5,a4
    800054fa:	40200713          	li	a4,1026
    800054fe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005502:	00d5151b          	slliw	a0,a0,0xd
    80005506:	0c2017b7          	lui	a5,0xc201
    8000550a:	953e                	add	a0,a0,a5
    8000550c:	00052023          	sw	zero,0(a0)
}
    80005510:	60a2                	ld	ra,8(sp)
    80005512:	6402                	ld	s0,0(sp)
    80005514:	0141                	addi	sp,sp,16
    80005516:	8082                	ret

0000000080005518 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005518:	1141                	addi	sp,sp,-16
    8000551a:	e406                	sd	ra,8(sp)
    8000551c:	e022                	sd	s0,0(sp)
    8000551e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005520:	de6fc0ef          	jal	ra,80001b06 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005524:	00d5179b          	slliw	a5,a0,0xd
    80005528:	0c201537          	lui	a0,0xc201
    8000552c:	953e                	add	a0,a0,a5
  return irq;
}
    8000552e:	4148                	lw	a0,4(a0)
    80005530:	60a2                	ld	ra,8(sp)
    80005532:	6402                	ld	s0,0(sp)
    80005534:	0141                	addi	sp,sp,16
    80005536:	8082                	ret

0000000080005538 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005538:	1101                	addi	sp,sp,-32
    8000553a:	ec06                	sd	ra,24(sp)
    8000553c:	e822                	sd	s0,16(sp)
    8000553e:	e426                	sd	s1,8(sp)
    80005540:	1000                	addi	s0,sp,32
    80005542:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005544:	dc2fc0ef          	jal	ra,80001b06 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005548:	00d5151b          	slliw	a0,a0,0xd
    8000554c:	0c2017b7          	lui	a5,0xc201
    80005550:	97aa                	add	a5,a5,a0
    80005552:	c3c4                	sw	s1,4(a5)
}
    80005554:	60e2                	ld	ra,24(sp)
    80005556:	6442                	ld	s0,16(sp)
    80005558:	64a2                	ld	s1,8(sp)
    8000555a:	6105                	addi	sp,sp,32
    8000555c:	8082                	ret

000000008000555e <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000555e:	1141                	addi	sp,sp,-16
    80005560:	e406                	sd	ra,8(sp)
    80005562:	e022                	sd	s0,0(sp)
    80005564:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005566:	479d                	li	a5,7
    80005568:	04a7ca63          	blt	a5,a0,800055bc <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    8000556c:	0001d797          	auipc	a5,0x1d
    80005570:	d7c78793          	addi	a5,a5,-644 # 800222e8 <disk>
    80005574:	97aa                	add	a5,a5,a0
    80005576:	0187c783          	lbu	a5,24(a5)
    8000557a:	e7b9                	bnez	a5,800055c8 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000557c:	00451613          	slli	a2,a0,0x4
    80005580:	0001d797          	auipc	a5,0x1d
    80005584:	d6878793          	addi	a5,a5,-664 # 800222e8 <disk>
    80005588:	6394                	ld	a3,0(a5)
    8000558a:	96b2                	add	a3,a3,a2
    8000558c:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005590:	6398                	ld	a4,0(a5)
    80005592:	9732                	add	a4,a4,a2
    80005594:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005598:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    8000559c:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800055a0:	953e                	add	a0,a0,a5
    800055a2:	4785                	li	a5,1
    800055a4:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    800055a8:	0001d517          	auipc	a0,0x1d
    800055ac:	d5850513          	addi	a0,a0,-680 # 80022300 <disk+0x18>
    800055b0:	bf1fc0ef          	jal	ra,800021a0 <wakeup>
}
    800055b4:	60a2                	ld	ra,8(sp)
    800055b6:	6402                	ld	s0,0(sp)
    800055b8:	0141                	addi	sp,sp,16
    800055ba:	8082                	ret
    panic("free_desc 1");
    800055bc:	00002517          	auipc	a0,0x2
    800055c0:	41c50513          	addi	a0,a0,1052 # 800079d8 <syscalls+0x400>
    800055c4:	9c6fb0ef          	jal	ra,8000078a <panic>
    panic("free_desc 2");
    800055c8:	00002517          	auipc	a0,0x2
    800055cc:	42050513          	addi	a0,a0,1056 # 800079e8 <syscalls+0x410>
    800055d0:	9bafb0ef          	jal	ra,8000078a <panic>

00000000800055d4 <virtio_disk_init>:
{
    800055d4:	1101                	addi	sp,sp,-32
    800055d6:	ec06                	sd	ra,24(sp)
    800055d8:	e822                	sd	s0,16(sp)
    800055da:	e426                	sd	s1,8(sp)
    800055dc:	e04a                	sd	s2,0(sp)
    800055de:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800055e0:	00002597          	auipc	a1,0x2
    800055e4:	41858593          	addi	a1,a1,1048 # 800079f8 <syscalls+0x420>
    800055e8:	0001d517          	auipc	a0,0x1d
    800055ec:	e2850513          	addi	a0,a0,-472 # 80022410 <disk+0x128>
    800055f0:	cfcfb0ef          	jal	ra,80000aec <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800055f4:	100017b7          	lui	a5,0x10001
    800055f8:	4398                	lw	a4,0(a5)
    800055fa:	2701                	sext.w	a4,a4
    800055fc:	747277b7          	lui	a5,0x74727
    80005600:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005604:	14f71063          	bne	a4,a5,80005744 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005608:	100017b7          	lui	a5,0x10001
    8000560c:	43dc                	lw	a5,4(a5)
    8000560e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005610:	4709                	li	a4,2
    80005612:	12e79963          	bne	a5,a4,80005744 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005616:	100017b7          	lui	a5,0x10001
    8000561a:	479c                	lw	a5,8(a5)
    8000561c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000561e:	12e79363          	bne	a5,a4,80005744 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005622:	100017b7          	lui	a5,0x10001
    80005626:	47d8                	lw	a4,12(a5)
    80005628:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000562a:	554d47b7          	lui	a5,0x554d4
    8000562e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005632:	10f71963          	bne	a4,a5,80005744 <virtio_disk_init+0x170>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005636:	100017b7          	lui	a5,0x10001
    8000563a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000563e:	4705                	li	a4,1
    80005640:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005642:	470d                	li	a4,3
    80005644:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005646:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005648:	c7ffe737          	lui	a4,0xc7ffe
    8000564c:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc337>
    80005650:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005652:	2701                	sext.w	a4,a4
    80005654:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005656:	472d                	li	a4,11
    80005658:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    8000565a:	5bbc                	lw	a5,112(a5)
    8000565c:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005660:	8ba1                	andi	a5,a5,8
    80005662:	0e078763          	beqz	a5,80005750 <virtio_disk_init+0x17c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005666:	100017b7          	lui	a5,0x10001
    8000566a:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000566e:	43fc                	lw	a5,68(a5)
    80005670:	2781                	sext.w	a5,a5
    80005672:	0e079563          	bnez	a5,8000575c <virtio_disk_init+0x188>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005676:	100017b7          	lui	a5,0x10001
    8000567a:	5bdc                	lw	a5,52(a5)
    8000567c:	2781                	sext.w	a5,a5
  if(max == 0)
    8000567e:	0e078563          	beqz	a5,80005768 <virtio_disk_init+0x194>
  if(max < NUM)
    80005682:	471d                	li	a4,7
    80005684:	0ef77863          	bgeu	a4,a5,80005774 <virtio_disk_init+0x1a0>
  disk.desc = kalloc();
    80005688:	c14fb0ef          	jal	ra,80000a9c <kalloc>
    8000568c:	0001d497          	auipc	s1,0x1d
    80005690:	c5c48493          	addi	s1,s1,-932 # 800222e8 <disk>
    80005694:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005696:	c06fb0ef          	jal	ra,80000a9c <kalloc>
    8000569a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000569c:	c00fb0ef          	jal	ra,80000a9c <kalloc>
    800056a0:	87aa                	mv	a5,a0
    800056a2:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800056a4:	6088                	ld	a0,0(s1)
    800056a6:	cd69                	beqz	a0,80005780 <virtio_disk_init+0x1ac>
    800056a8:	0001d717          	auipc	a4,0x1d
    800056ac:	c4873703          	ld	a4,-952(a4) # 800222f0 <disk+0x8>
    800056b0:	cb61                	beqz	a4,80005780 <virtio_disk_init+0x1ac>
    800056b2:	c7f9                	beqz	a5,80005780 <virtio_disk_init+0x1ac>
  memset(disk.desc, 0, PGSIZE);
    800056b4:	6605                	lui	a2,0x1
    800056b6:	4581                	li	a1,0
    800056b8:	d88fb0ef          	jal	ra,80000c40 <memset>
  memset(disk.avail, 0, PGSIZE);
    800056bc:	0001d497          	auipc	s1,0x1d
    800056c0:	c2c48493          	addi	s1,s1,-980 # 800222e8 <disk>
    800056c4:	6605                	lui	a2,0x1
    800056c6:	4581                	li	a1,0
    800056c8:	6488                	ld	a0,8(s1)
    800056ca:	d76fb0ef          	jal	ra,80000c40 <memset>
  memset(disk.used, 0, PGSIZE);
    800056ce:	6605                	lui	a2,0x1
    800056d0:	4581                	li	a1,0
    800056d2:	6888                	ld	a0,16(s1)
    800056d4:	d6cfb0ef          	jal	ra,80000c40 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800056d8:	100017b7          	lui	a5,0x10001
    800056dc:	4721                	li	a4,8
    800056de:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800056e0:	4098                	lw	a4,0(s1)
    800056e2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800056e6:	40d8                	lw	a4,4(s1)
    800056e8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800056ec:	6498                	ld	a4,8(s1)
    800056ee:	0007069b          	sext.w	a3,a4
    800056f2:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800056f6:	9701                	srai	a4,a4,0x20
    800056f8:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800056fc:	6898                	ld	a4,16(s1)
    800056fe:	0007069b          	sext.w	a3,a4
    80005702:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005706:	9701                	srai	a4,a4,0x20
    80005708:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000570c:	4705                	li	a4,1
    8000570e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005710:	00e48c23          	sb	a4,24(s1)
    80005714:	00e48ca3          	sb	a4,25(s1)
    80005718:	00e48d23          	sb	a4,26(s1)
    8000571c:	00e48da3          	sb	a4,27(s1)
    80005720:	00e48e23          	sb	a4,28(s1)
    80005724:	00e48ea3          	sb	a4,29(s1)
    80005728:	00e48f23          	sb	a4,30(s1)
    8000572c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005730:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005734:	0727a823          	sw	s2,112(a5)
}
    80005738:	60e2                	ld	ra,24(sp)
    8000573a:	6442                	ld	s0,16(sp)
    8000573c:	64a2                	ld	s1,8(sp)
    8000573e:	6902                	ld	s2,0(sp)
    80005740:	6105                	addi	sp,sp,32
    80005742:	8082                	ret
    panic("could not find virtio disk");
    80005744:	00002517          	auipc	a0,0x2
    80005748:	2c450513          	addi	a0,a0,708 # 80007a08 <syscalls+0x430>
    8000574c:	83efb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk FEATURES_OK unset");
    80005750:	00002517          	auipc	a0,0x2
    80005754:	2d850513          	addi	a0,a0,728 # 80007a28 <syscalls+0x450>
    80005758:	832fb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk should not be ready");
    8000575c:	00002517          	auipc	a0,0x2
    80005760:	2ec50513          	addi	a0,a0,748 # 80007a48 <syscalls+0x470>
    80005764:	826fb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk has no queue 0");
    80005768:	00002517          	auipc	a0,0x2
    8000576c:	30050513          	addi	a0,a0,768 # 80007a68 <syscalls+0x490>
    80005770:	81afb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk max queue too short");
    80005774:	00002517          	auipc	a0,0x2
    80005778:	31450513          	addi	a0,a0,788 # 80007a88 <syscalls+0x4b0>
    8000577c:	80efb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk kalloc");
    80005780:	00002517          	auipc	a0,0x2
    80005784:	32850513          	addi	a0,a0,808 # 80007aa8 <syscalls+0x4d0>
    80005788:	802fb0ef          	jal	ra,8000078a <panic>

000000008000578c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000578c:	7119                	addi	sp,sp,-128
    8000578e:	fc86                	sd	ra,120(sp)
    80005790:	f8a2                	sd	s0,112(sp)
    80005792:	f4a6                	sd	s1,104(sp)
    80005794:	f0ca                	sd	s2,96(sp)
    80005796:	ecce                	sd	s3,88(sp)
    80005798:	e8d2                	sd	s4,80(sp)
    8000579a:	e4d6                	sd	s5,72(sp)
    8000579c:	e0da                	sd	s6,64(sp)
    8000579e:	fc5e                	sd	s7,56(sp)
    800057a0:	f862                	sd	s8,48(sp)
    800057a2:	f466                	sd	s9,40(sp)
    800057a4:	f06a                	sd	s10,32(sp)
    800057a6:	ec6e                	sd	s11,24(sp)
    800057a8:	0100                	addi	s0,sp,128
    800057aa:	8aaa                	mv	s5,a0
    800057ac:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800057ae:	00c52d03          	lw	s10,12(a0)
    800057b2:	001d1d1b          	slliw	s10,s10,0x1
    800057b6:	1d02                	slli	s10,s10,0x20
    800057b8:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800057bc:	0001d517          	auipc	a0,0x1d
    800057c0:	c5450513          	addi	a0,a0,-940 # 80022410 <disk+0x128>
    800057c4:	ba8fb0ef          	jal	ra,80000b6c <acquire>
  for(int i = 0; i < 3; i++){
    800057c8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800057ca:	44a1                	li	s1,8
      disk.free[i] = 0;
    800057cc:	0001db97          	auipc	s7,0x1d
    800057d0:	b1cb8b93          	addi	s7,s7,-1252 # 800222e8 <disk>
  for(int i = 0; i < 3; i++){
    800057d4:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800057d6:	0001dc97          	auipc	s9,0x1d
    800057da:	c3ac8c93          	addi	s9,s9,-966 # 80022410 <disk+0x128>
    800057de:	a8a9                	j	80005838 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800057e0:	00fb8733          	add	a4,s7,a5
    800057e4:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800057e8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800057ea:	0207c563          	bltz	a5,80005814 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800057ee:	2905                	addiw	s2,s2,1
    800057f0:	0611                	addi	a2,a2,4
    800057f2:	05690863          	beq	s2,s6,80005842 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    800057f6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800057f8:	0001d717          	auipc	a4,0x1d
    800057fc:	af070713          	addi	a4,a4,-1296 # 800222e8 <disk>
    80005800:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005802:	01874683          	lbu	a3,24(a4)
    80005806:	fee9                	bnez	a3,800057e0 <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80005808:	2785                	addiw	a5,a5,1
    8000580a:	0705                	addi	a4,a4,1
    8000580c:	fe979be3          	bne	a5,s1,80005802 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005810:	57fd                	li	a5,-1
    80005812:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005814:	01205b63          	blez	s2,8000582a <virtio_disk_rw+0x9e>
    80005818:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    8000581a:	000a2503          	lw	a0,0(s4)
    8000581e:	d41ff0ef          	jal	ra,8000555e <free_desc>
      for(int j = 0; j < i; j++)
    80005822:	2d85                	addiw	s11,s11,1
    80005824:	0a11                	addi	s4,s4,4
    80005826:	ffb91ae3          	bne	s2,s11,8000581a <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000582a:	85e6                	mv	a1,s9
    8000582c:	0001d517          	auipc	a0,0x1d
    80005830:	ad450513          	addi	a0,a0,-1324 # 80022300 <disk+0x18>
    80005834:	921fc0ef          	jal	ra,80002154 <sleep>
  for(int i = 0; i < 3; i++){
    80005838:	f8040a13          	addi	s4,s0,-128
{
    8000583c:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    8000583e:	894e                	mv	s2,s3
    80005840:	bf5d                	j	800057f6 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005842:	f8042583          	lw	a1,-128(s0)
    80005846:	00a58793          	addi	a5,a1,10
    8000584a:	0792                	slli	a5,a5,0x4

  if(write)
    8000584c:	0001d617          	auipc	a2,0x1d
    80005850:	a9c60613          	addi	a2,a2,-1380 # 800222e8 <disk>
    80005854:	00f60733          	add	a4,a2,a5
    80005858:	018036b3          	snez	a3,s8
    8000585c:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000585e:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005862:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005866:	f6078693          	addi	a3,a5,-160
    8000586a:	6218                	ld	a4,0(a2)
    8000586c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000586e:	00878513          	addi	a0,a5,8
    80005872:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005874:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005876:	6208                	ld	a0,0(a2)
    80005878:	96aa                	add	a3,a3,a0
    8000587a:	4741                	li	a4,16
    8000587c:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000587e:	4705                	li	a4,1
    80005880:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80005884:	f8442703          	lw	a4,-124(s0)
    80005888:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000588c:	0712                	slli	a4,a4,0x4
    8000588e:	953a                	add	a0,a0,a4
    80005890:	058a8693          	addi	a3,s5,88
    80005894:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    80005896:	6208                	ld	a0,0(a2)
    80005898:	972a                	add	a4,a4,a0
    8000589a:	40000693          	li	a3,1024
    8000589e:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800058a0:	001c3c13          	seqz	s8,s8
    800058a4:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800058a6:	001c6c13          	ori	s8,s8,1
    800058aa:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800058ae:	f8842603          	lw	a2,-120(s0)
    800058b2:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800058b6:	0001d697          	auipc	a3,0x1d
    800058ba:	a3268693          	addi	a3,a3,-1486 # 800222e8 <disk>
    800058be:	00258713          	addi	a4,a1,2
    800058c2:	0712                	slli	a4,a4,0x4
    800058c4:	9736                	add	a4,a4,a3
    800058c6:	587d                	li	a6,-1
    800058c8:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800058cc:	0612                	slli	a2,a2,0x4
    800058ce:	9532                	add	a0,a0,a2
    800058d0:	f9078793          	addi	a5,a5,-112
    800058d4:	97b6                	add	a5,a5,a3
    800058d6:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    800058d8:	629c                	ld	a5,0(a3)
    800058da:	97b2                	add	a5,a5,a2
    800058dc:	4605                	li	a2,1
    800058de:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800058e0:	4509                	li	a0,2
    800058e2:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    800058e6:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800058ea:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800058ee:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800058f2:	6698                	ld	a4,8(a3)
    800058f4:	00275783          	lhu	a5,2(a4)
    800058f8:	8b9d                	andi	a5,a5,7
    800058fa:	0786                	slli	a5,a5,0x1
    800058fc:	97ba                	add	a5,a5,a4
    800058fe:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80005902:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005906:	6698                	ld	a4,8(a3)
    80005908:	00275783          	lhu	a5,2(a4)
    8000590c:	2785                	addiw	a5,a5,1
    8000590e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005912:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005916:	100017b7          	lui	a5,0x10001
    8000591a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000591e:	004aa783          	lw	a5,4(s5)
    80005922:	00c79f63          	bne	a5,a2,80005940 <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    80005926:	0001d917          	auipc	s2,0x1d
    8000592a:	aea90913          	addi	s2,s2,-1302 # 80022410 <disk+0x128>
  while(b->disk == 1) {
    8000592e:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80005930:	85ca                	mv	a1,s2
    80005932:	8556                	mv	a0,s5
    80005934:	821fc0ef          	jal	ra,80002154 <sleep>
  while(b->disk == 1) {
    80005938:	004aa783          	lw	a5,4(s5)
    8000593c:	fe978ae3          	beq	a5,s1,80005930 <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    80005940:	f8042903          	lw	s2,-128(s0)
    80005944:	00290793          	addi	a5,s2,2
    80005948:	00479713          	slli	a4,a5,0x4
    8000594c:	0001d797          	auipc	a5,0x1d
    80005950:	99c78793          	addi	a5,a5,-1636 # 800222e8 <disk>
    80005954:	97ba                	add	a5,a5,a4
    80005956:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000595a:	0001d997          	auipc	s3,0x1d
    8000595e:	98e98993          	addi	s3,s3,-1650 # 800222e8 <disk>
    80005962:	00491713          	slli	a4,s2,0x4
    80005966:	0009b783          	ld	a5,0(s3)
    8000596a:	97ba                	add	a5,a5,a4
    8000596c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005970:	854a                	mv	a0,s2
    80005972:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005976:	be9ff0ef          	jal	ra,8000555e <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000597a:	8885                	andi	s1,s1,1
    8000597c:	f0fd                	bnez	s1,80005962 <virtio_disk_rw+0x1d6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000597e:	0001d517          	auipc	a0,0x1d
    80005982:	a9250513          	addi	a0,a0,-1390 # 80022410 <disk+0x128>
    80005986:	a7efb0ef          	jal	ra,80000c04 <release>
}
    8000598a:	70e6                	ld	ra,120(sp)
    8000598c:	7446                	ld	s0,112(sp)
    8000598e:	74a6                	ld	s1,104(sp)
    80005990:	7906                	ld	s2,96(sp)
    80005992:	69e6                	ld	s3,88(sp)
    80005994:	6a46                	ld	s4,80(sp)
    80005996:	6aa6                	ld	s5,72(sp)
    80005998:	6b06                	ld	s6,64(sp)
    8000599a:	7be2                	ld	s7,56(sp)
    8000599c:	7c42                	ld	s8,48(sp)
    8000599e:	7ca2                	ld	s9,40(sp)
    800059a0:	7d02                	ld	s10,32(sp)
    800059a2:	6de2                	ld	s11,24(sp)
    800059a4:	6109                	addi	sp,sp,128
    800059a6:	8082                	ret

00000000800059a8 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800059a8:	1101                	addi	sp,sp,-32
    800059aa:	ec06                	sd	ra,24(sp)
    800059ac:	e822                	sd	s0,16(sp)
    800059ae:	e426                	sd	s1,8(sp)
    800059b0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800059b2:	0001d497          	auipc	s1,0x1d
    800059b6:	93648493          	addi	s1,s1,-1738 # 800222e8 <disk>
    800059ba:	0001d517          	auipc	a0,0x1d
    800059be:	a5650513          	addi	a0,a0,-1450 # 80022410 <disk+0x128>
    800059c2:	9aafb0ef          	jal	ra,80000b6c <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800059c6:	10001737          	lui	a4,0x10001
    800059ca:	533c                	lw	a5,96(a4)
    800059cc:	8b8d                	andi	a5,a5,3
    800059ce:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800059d0:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800059d4:	689c                	ld	a5,16(s1)
    800059d6:	0204d703          	lhu	a4,32(s1)
    800059da:	0027d783          	lhu	a5,2(a5)
    800059de:	04f70663          	beq	a4,a5,80005a2a <virtio_disk_intr+0x82>
    __sync_synchronize();
    800059e2:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800059e6:	6898                	ld	a4,16(s1)
    800059e8:	0204d783          	lhu	a5,32(s1)
    800059ec:	8b9d                	andi	a5,a5,7
    800059ee:	078e                	slli	a5,a5,0x3
    800059f0:	97ba                	add	a5,a5,a4
    800059f2:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800059f4:	00278713          	addi	a4,a5,2
    800059f8:	0712                	slli	a4,a4,0x4
    800059fa:	9726                	add	a4,a4,s1
    800059fc:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005a00:	e321                	bnez	a4,80005a40 <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005a02:	0789                	addi	a5,a5,2
    80005a04:	0792                	slli	a5,a5,0x4
    80005a06:	97a6                	add	a5,a5,s1
    80005a08:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005a0a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005a0e:	f92fc0ef          	jal	ra,800021a0 <wakeup>

    disk.used_idx += 1;
    80005a12:	0204d783          	lhu	a5,32(s1)
    80005a16:	2785                	addiw	a5,a5,1
    80005a18:	17c2                	slli	a5,a5,0x30
    80005a1a:	93c1                	srli	a5,a5,0x30
    80005a1c:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005a20:	6898                	ld	a4,16(s1)
    80005a22:	00275703          	lhu	a4,2(a4)
    80005a26:	faf71ee3          	bne	a4,a5,800059e2 <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    80005a2a:	0001d517          	auipc	a0,0x1d
    80005a2e:	9e650513          	addi	a0,a0,-1562 # 80022410 <disk+0x128>
    80005a32:	9d2fb0ef          	jal	ra,80000c04 <release>
}
    80005a36:	60e2                	ld	ra,24(sp)
    80005a38:	6442                	ld	s0,16(sp)
    80005a3a:	64a2                	ld	s1,8(sp)
    80005a3c:	6105                	addi	sp,sp,32
    80005a3e:	8082                	ret
      panic("virtio_disk_intr status");
    80005a40:	00002517          	auipc	a0,0x2
    80005a44:	08050513          	addi	a0,a0,128 # 80007ac0 <syscalls+0x4e8>
    80005a48:	d43fa0ef          	jal	ra,8000078a <panic>
	...

0000000080006000 <_trampoline>:
        # user page table.
        #

        # save user a0 in sscratch so
        # a0 can be used to get at TRAPFRAME.
        csrw sscratch, a0
    80006000:	14051073          	csrw	sscratch,a0

        # each process has a separate p->trapframe memory area,
        # but it's mapped to the same virtual address
        # (TRAPFRAME) in every process's user page table.
        li a0, TRAPFRAME
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1
    8000600a:	0536                	slli	a0,a0,0xd
        
        # save the user registers in TRAPFRAME
        sd ra, 40(a0)
    8000600c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
        sd sp, 48(a0)
    80006010:	02253823          	sd	sp,48(a0)
        sd gp, 56(a0)
    80006014:	02353c23          	sd	gp,56(a0)
        sd tp, 64(a0)
    80006018:	04453023          	sd	tp,64(a0)
        sd t0, 72(a0)
    8000601c:	04553423          	sd	t0,72(a0)
        sd t1, 80(a0)
    80006020:	04653823          	sd	t1,80(a0)
        sd t2, 88(a0)
    80006024:	04753c23          	sd	t2,88(a0)
        sd s0, 96(a0)
    80006028:	f120                	sd	s0,96(a0)
        sd s1, 104(a0)
    8000602a:	f524                	sd	s1,104(a0)
        sd a1, 120(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
        sd a2, 128(a0)
    8000602e:	e150                	sd	a2,128(a0)
        sd a3, 136(a0)
    80006030:	e554                	sd	a3,136(a0)
        sd a4, 144(a0)
    80006032:	e958                	sd	a4,144(a0)
        sd a5, 152(a0)
    80006034:	ed5c                	sd	a5,152(a0)
        sd a6, 160(a0)
    80006036:	0b053023          	sd	a6,160(a0)
        sd a7, 168(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
        sd s2, 176(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
        sd s3, 184(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
        sd s4, 192(a0)
    80006046:	0d453023          	sd	s4,192(a0)
        sd s5, 200(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
        sd s6, 208(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
        sd s7, 216(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
        sd s8, 224(a0)
    80006056:	0f853023          	sd	s8,224(a0)
        sd s9, 232(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
        sd s10, 240(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
        sd s11, 248(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
        sd t3, 256(a0)
    80006066:	11c53023          	sd	t3,256(a0)
        sd t4, 264(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
        sd t5, 272(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
        sd t6, 280(a0)
    80006072:	11f53c23          	sd	t6,280(a0)

	# save the user a0 in p->trapframe->a0
        csrr t0, sscratch
    80006076:	140022f3          	csrr	t0,sscratch
        sd t0, 112(a0)
    8000607a:	06553823          	sd	t0,112(a0)

        # initialize kernel stack pointer, from p->trapframe->kernel_sp
        ld sp, 8(a0)
    8000607e:	00853103          	ld	sp,8(a0)

        # make tp hold the current hartid, from p->trapframe->kernel_hartid
        ld tp, 32(a0)
    80006082:	02053203          	ld	tp,32(a0)

        # load the address of usertrap(), from p->trapframe->kernel_trap
        ld t0, 16(a0)
    80006086:	01053283          	ld	t0,16(a0)

        # fetch the kernel page table address, from p->trapframe->kernel_satp.
        ld t1, 0(a0)
    8000608a:	00053303          	ld	t1,0(a0)

        # wait for any previous memory operations to complete, so that
        # they use the user page table.
        sfence.vma zero, zero
    8000608e:	12000073          	sfence.vma

        # install the kernel page table.
        csrw satp, t1
    80006092:	18031073          	csrw	satp,t1

        # flush now-stale user entries from the TLB.
        sfence.vma zero, zero
    80006096:	12000073          	sfence.vma

        # call usertrap()
        jalr t0
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
userret:
        # usertrap() returns here, with user satp in a0.
        # return from kernel to user.

        # switch to the user page table.
        sfence.vma zero, zero
    8000609c:	12000073          	sfence.vma
        csrw satp, a0
    800060a0:	18051073          	csrw	satp,a0
        sfence.vma zero, zero
    800060a4:	12000073          	sfence.vma

        li a0, TRAPFRAME
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1
    800060ae:	0536                	slli	a0,a0,0xd

        # restore all but a0 from TRAPFRAME
        ld ra, 40(a0)
    800060b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
        ld sp, 48(a0)
    800060b4:	03053103          	ld	sp,48(a0)
        ld gp, 56(a0)
    800060b8:	03853183          	ld	gp,56(a0)
        ld tp, 64(a0)
    800060bc:	04053203          	ld	tp,64(a0)
        ld t0, 72(a0)
    800060c0:	04853283          	ld	t0,72(a0)
        ld t1, 80(a0)
    800060c4:	05053303          	ld	t1,80(a0)
        ld t2, 88(a0)
    800060c8:	05853383          	ld	t2,88(a0)
        ld s0, 96(a0)
    800060cc:	7120                	ld	s0,96(a0)
        ld s1, 104(a0)
    800060ce:	7524                	ld	s1,104(a0)
        ld a1, 120(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
        ld a2, 128(a0)
    800060d2:	6150                	ld	a2,128(a0)
        ld a3, 136(a0)
    800060d4:	6554                	ld	a3,136(a0)
        ld a4, 144(a0)
    800060d6:	6958                	ld	a4,144(a0)
        ld a5, 152(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
        ld a6, 160(a0)
    800060da:	0a053803          	ld	a6,160(a0)
        ld a7, 168(a0)
    800060de:	0a853883          	ld	a7,168(a0)
        ld s2, 176(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
        ld s3, 184(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
        ld s4, 192(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
        ld s5, 200(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
        ld s6, 208(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
        ld s7, 216(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
        ld s8, 224(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
        ld s9, 232(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
        ld s10, 240(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
        ld s11, 248(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
        ld t3, 256(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
        ld t4, 264(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
        ld t5, 272(a0)
    80006112:	11053f03          	ld	t5,272(a0)
        ld t6, 280(a0)
    80006116:	11853f83          	ld	t6,280(a0)

	# restore user a0
        ld a0, 112(a0)
    8000611a:	7928                	ld	a0,112(a0)
        
        # return to user mode and user pc.
        # usertrapret() set up sstatus and sepc.
        sret
    8000611c:	10200073          	sret
	...
