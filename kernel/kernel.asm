
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
    80000004:	c0010113          	addi	sp,sp,-1024 # 80007c00 <stack0>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdcaf7>
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
    8000010a:	3aa020ef          	jal	ra,800024b4 <either_copyin>
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
    80000176:	a8e50513          	addi	a0,a0,-1394 # 8000fc00 <cons>
    8000017a:	1f3000ef          	jal	ra,80000b6c <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000017e:	00010497          	auipc	s1,0x10
    80000182:	a8248493          	addi	s1,s1,-1406 # 8000fc00 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000186:	00010917          	auipc	s2,0x10
    8000018a:	b1290913          	addi	s2,s2,-1262 # 8000fc98 <cons+0x98>
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
    800001a4:	159010ef          	jal	ra,80001afc <myproc>
    800001a8:	19e020ef          	jal	ra,80002346 <killed>
    800001ac:	e125                	bnez	a0,8000020c <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800001ae:	85a6                	mv	a1,s1
    800001b0:	854a                	mv	a0,s2
    800001b2:	75d010ef          	jal	ra,8000210e <sleep>
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
    800001ea:	280020ef          	jal	ra,8000246a <either_copyout>
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
    800001fe:	a0650513          	addi	a0,a0,-1530 # 8000fc00 <cons>
    80000202:	203000ef          	jal	ra,80000c04 <release>

  return target - n;
    80000206:	413b053b          	subw	a0,s6,s3
    8000020a:	a801                	j	8000021a <consoleread+0xce>
        release(&cons.lock);
    8000020c:	00010517          	auipc	a0,0x10
    80000210:	9f450513          	addi	a0,a0,-1548 # 8000fc00 <cons>
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
    80000242:	a4f72d23          	sw	a5,-1446(a4) # 8000fc98 <cons+0x98>
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
    8000028c:	97850513          	addi	a0,a0,-1672 # 8000fc00 <cons>
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
    800002aa:	254020ef          	jal	ra,800024fe <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ae:	00010517          	auipc	a0,0x10
    800002b2:	95250513          	addi	a0,a0,-1710 # 8000fc00 <cons>
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
    800002d2:	93270713          	addi	a4,a4,-1742 # 8000fc00 <cons>
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
    800002f8:	90c78793          	addi	a5,a5,-1780 # 8000fc00 <cons>
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
    80000326:	9767a783          	lw	a5,-1674(a5) # 8000fc98 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f6f71fe3          	bne	a4,a5,800002ae <consoleintr+0x34>
    80000334:	a04d                	j	800003d6 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80000336:	00010717          	auipc	a4,0x10
    8000033a:	8ca70713          	addi	a4,a4,-1846 # 8000fc00 <cons>
    8000033e:	0a072783          	lw	a5,160(a4)
    80000342:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000346:	00010497          	auipc	s1,0x10
    8000034a:	8ba48493          	addi	s1,s1,-1862 # 8000fc00 <cons>
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
    8000037e:	00010717          	auipc	a4,0x10
    80000382:	88270713          	addi	a4,a4,-1918 # 8000fc00 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f2f700e3          	beq	a4,a5,800002ae <consoleintr+0x34>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	00010717          	auipc	a4,0x10
    80000398:	90f72623          	sw	a5,-1780(a4) # 8000fca0 <cons+0xa0>
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
    800003b2:	00010797          	auipc	a5,0x10
    800003b6:	84e78793          	addi	a5,a5,-1970 # 8000fc00 <cons>
    800003ba:	0a07a703          	lw	a4,160(a5)
    800003be:	0017069b          	addiw	a3,a4,1
    800003c2:	0006861b          	sext.w	a2,a3
    800003c6:	0ad7a023          	sw	a3,160(a5)
    800003ca:	07f77713          	andi	a4,a4,127
    800003ce:	97ba                	add	a5,a5,a4
    800003d0:	4729                	li	a4,10
    800003d2:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003d6:	00010797          	auipc	a5,0x10
    800003da:	8cc7a323          	sw	a2,-1850(a5) # 8000fc9c <cons+0x9c>
        wakeup(&cons.r);
    800003de:	00010517          	auipc	a0,0x10
    800003e2:	8ba50513          	addi	a0,a0,-1862 # 8000fc98 <cons+0x98>
    800003e6:	575010ef          	jal	ra,8000215a <wakeup>
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
    800003fc:	00010517          	auipc	a0,0x10
    80000400:	80450513          	addi	a0,a0,-2044 # 8000fc00 <cons>
    80000404:	6e8000ef          	jal	ra,80000aec <initlock>

  uartinit();
    80000408:	3e2000ef          	jal	ra,800007ea <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	00020797          	auipc	a5,0x20
    80000410:	76478793          	addi	a5,a5,1892 # 80020b70 <devsw>
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
    800004fa:	6de7a783          	lw	a5,1758(a5) # 80007bd4 <panicking>
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
    80000538:	77450513          	addi	a0,a0,1908 # 8000fca8 <pr>
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
    80000756:	4827a783          	lw	a5,1154(a5) # 80007bd4 <panicking>
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
    80000780:	52c50513          	addi	a0,a0,1324 # 8000fca8 <pr>
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
    8000079e:	4327ad23          	sw	s2,1082(a5) # 80007bd4 <panicking>
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
    800007c0:	4127aa23          	sw	s2,1044(a5) # 80007bd0 <panicked>
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
    800007da:	4d250513          	addi	a0,a0,1234 # 8000fca8 <pr>
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
    80000826:	49e50513          	addi	a0,a0,1182 # 8000fcc0 <tx_lock>
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
    80000854:	47050513          	addi	a0,a0,1136 # 8000fcc0 <tx_lock>
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
    80000872:	36e48493          	addi	s1,s1,878 # 80007bdc <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000876:	0000f997          	auipc	s3,0xf
    8000087a:	44a98993          	addi	s3,s3,1098 # 8000fcc0 <tx_lock>
    8000087e:	00007917          	auipc	s2,0x7
    80000882:	35a90913          	addi	s2,s2,858 # 80007bd8 <tx_chan>
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
    80000892:	07d010ef          	jal	ra,8000210e <sleep>
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
    800008b6:	40e50513          	addi	a0,a0,1038 # 8000fcc0 <tx_lock>
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
    800008e4:	2f47a783          	lw	a5,756(a5) # 80007bd4 <panicking>
    800008e8:	cb89                	beqz	a5,800008fa <uartputc_sync+0x26>
    push_off();

  if(panicked){
    800008ea:	00007797          	auipc	a5,0x7
    800008ee:	2e67a783          	lw	a5,742(a5) # 80007bd0 <panicked>
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
    8000091a:	2be7a783          	lw	a5,702(a5) # 80007bd4 <panicking>
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
    8000096e:	35650513          	addi	a0,a0,854 # 8000fcc0 <tx_lock>
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
    80000984:	34050513          	addi	a0,a0,832 # 8000fcc0 <tx_lock>
    80000988:	27c000ef          	jal	ra,80000c04 <release>

  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000098c:	54fd                	li	s1,-1
    8000098e:	a831                	j	800009aa <uartintr+0x52>
    tx_busy = 0;
    80000990:	00007797          	auipc	a5,0x7
    80000994:	2407a623          	sw	zero,588(a5) # 80007bdc <tx_busy>
    wakeup(&tx_chan);
    80000998:	00007517          	auipc	a0,0x7
    8000099c:	24050513          	addi	a0,a0,576 # 80007bd8 <tx_chan>
    800009a0:	7ba010ef          	jal	ra,8000215a <wakeup>
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
    800009d0:	00021797          	auipc	a5,0x21
    800009d4:	33878793          	addi	a5,a5,824 # 80021d08 <end>
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
    800009f0:	2ec90913          	addi	s2,s2,748 # 8000fcd8 <kmem>
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
    80000a7c:	26050513          	addi	a0,a0,608 # 8000fcd8 <kmem>
    80000a80:	06c000ef          	jal	ra,80000aec <initlock>
  freerange(end, (void*)PHYSTOP);
    80000a84:	45c5                	li	a1,17
    80000a86:	05ee                	slli	a1,a1,0x1b
    80000a88:	00021517          	auipc	a0,0x21
    80000a8c:	28050513          	addi	a0,a0,640 # 80021d08 <end>
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
    80000aaa:	23248493          	addi	s1,s1,562 # 8000fcd8 <kmem>
    80000aae:	8526                	mv	a0,s1
    80000ab0:	0bc000ef          	jal	ra,80000b6c <acquire>
  r = kmem.freelist;
    80000ab4:	6c84                	ld	s1,24(s1)
  if(r)
    80000ab6:	c485                	beqz	s1,80000ade <kalloc+0x42>
    kmem.freelist = r->next;
    80000ab8:	609c                	ld	a5,0(s1)
    80000aba:	0000f517          	auipc	a0,0xf
    80000abe:	21e50513          	addi	a0,a0,542 # 8000fcd8 <kmem>
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
    80000ae2:	1fa50513          	addi	a0,a0,506 # 8000fcd8 <kmem>
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
    80000b16:	7cb000ef          	jal	ra,80001ae0 <mycpu>
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
    80000b44:	79d000ef          	jal	ra,80001ae0 <mycpu>
    80000b48:	5d3c                	lw	a5,120(a0)
    80000b4a:	cb99                	beqz	a5,80000b60 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b4c:	795000ef          	jal	ra,80001ae0 <mycpu>
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
    80000b60:	781000ef          	jal	ra,80001ae0 <mycpu>
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
    80000b94:	74d000ef          	jal	ra,80001ae0 <mycpu>
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
    80000bb8:	729000ef          	jal	ra,80001ae0 <mycpu>
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
    80000dea:	4e7000ef          	jal	ra,80001ad0 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000dee:	00007717          	auipc	a4,0x7
    80000df2:	df270713          	addi	a4,a4,-526 # 80007be0 <started>
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
    80000e02:	4cf000ef          	jal	ra,80001ad0 <cpuid>
    80000e06:	85aa                	mv	a1,a0
    80000e08:	00006517          	auipc	a0,0x6
    80000e0c:	2a850513          	addi	a0,a0,680 # 800070b0 <digits+0x78>
    80000e10:	eb4ff0ef          	jal	ra,800004c4 <printf>
    kvminithart();    // turn on paging
    80000e14:	080000ef          	jal	ra,80000e94 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e18:	017010ef          	jal	ra,8000262e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e1c:	668040ef          	jal	ra,80005484 <plicinithart>
  }

  scheduler();        
    80000e20:	156010ef          	jal	ra,80001f76 <scheduler>
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
    80000e5c:	3cd000ef          	jal	ra,80001a28 <procinit>
    trapinit();      // trap vectors
    80000e60:	7aa010ef          	jal	ra,8000260a <trapinit>
    trapinithart();  // install kernel trap vector
    80000e64:	7ca010ef          	jal	ra,8000262e <trapinithart>
    plicinit();      // set up interrupt controller
    80000e68:	606040ef          	jal	ra,8000546e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000e6c:	618040ef          	jal	ra,80005484 <plicinithart>
    binit();         // buffer cache
    80000e70:	647010ef          	jal	ra,80002cb6 <binit>
    iinit();         // inode table
    80000e74:	3ba020ef          	jal	ra,8000322e <iinit>
    fileinit();      // file table
    80000e78:	29a030ef          	jal	ra,80004112 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000e7c:	6f8040ef          	jal	ra,80005574 <virtio_disk_init>
    userinit();      // first user process
    80000e80:	75f000ef          	jal	ra,80001dde <userinit>
    __sync_synchronize();
    80000e84:	0ff0000f          	fence
    started = 1;
    80000e88:	4785                	li	a5,1
    80000e8a:	00007717          	auipc	a4,0x7
    80000e8e:	d4f72b23          	sw	a5,-682(a4) # 80007be0 <started>
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
    80000ea2:	d4a7b783          	ld	a5,-694(a5) # 80007be8 <kernel_pagetable>
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
    8000110c:	093000ef          	jal	ra,8000199e <proc_mapstacks>
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
    8000112e:	aaa7bf23          	sd	a0,-1346(a5) # 80007be8 <kernel_pagetable>
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
    800014fa:	602000ef          	jal	ra,80001afc <myproc>
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
    80001520:	0b396963          	bltu	s2,s3,800015d2 <vmfault+0xf2>
    80001524:	0af97763          	bgeu	s2,a5,800015d2 <vmfault+0xf2>
    // Stack - allocate zero-filled page  
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=stack\n", 
    80001528:	588c                	lw	a1,48(s1)
    8000152a:	00006697          	auipc	a3,0x6
    8000152e:	c4668693          	addi	a3,a3,-954 # 80007170 <digits+0x138>
    80001532:	000a1663          	bnez	s4,8000153e <vmfault+0x5e>
    80001536:	00006697          	auipc	a3,0x6
    8000153a:	37268693          	addi	a3,a3,882 # 800078a8 <syscalls+0x1f0>
    8000153e:	865a                	mv	a2,s6
    80001540:	00006517          	auipc	a0,0x6
    80001544:	c8050513          	addi	a0,a0,-896 # 800071c0 <digits+0x188>
    80001548:	f7dfe0ef          	jal	ra,800004c4 <printf>
            p->pid, page_va, is_write ? "write" : "read");
    
    if((mem = kalloc()) == 0) {
    8000154c:	d50ff0ef          	jal	ra,80000a9c <kalloc>
    80001550:	892a                	mv	s2,a0
    80001552:	c135                	beqz	a0,800015b6 <vmfault+0xd6>
      printf("[pid %d] MEMFULL\n", p->pid);
      return -1;
    }
    memset(mem, 0, PGSIZE);
    80001554:	6605                	lui	a2,0x1
    80001556:	4581                	li	a1,0
    80001558:	ee8ff0ef          	jal	ra,80000c40 <memset>
    
    // Map the page
    if(mappages(pagetable, page_va, PGSIZE, (uint64)mem, PTE_R | PTE_W | PTE_U) < 0) {
    8000155c:	4759                	li	a4,22
    8000155e:	86ca                	mv	a3,s2
    80001560:	6605                	lui	a2,0x1
    80001562:	85da                	mv	a1,s6
    80001564:	8556                	mv	a0,s5
    80001566:	a2fff0ef          	jal	ra,80000f94 <mappages>
    8000156a:	04054f63          	bltz	a0,800015c8 <vmfault+0xe8>
      kfree(mem);
      return -1;
    }
    
    printf("[pid %d] ALLOC va=0x%lx\n", p->pid, page_va);
    8000156e:	865a                	mv	a2,s6
    80001570:	588c                	lw	a1,48(s1)
    80001572:	00006517          	auipc	a0,0x6
    80001576:	c9e50513          	addi	a0,a0,-866 # 80007210 <digits+0x1d8>
    8000157a:	f4bfe0ef          	jal	ra,800004c4 <printf>
    printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, page_va, p->next_fifo_seq++);
    8000157e:	1904a683          	lw	a3,400(s1)
    80001582:	0016879b          	addiw	a5,a3,1
    80001586:	18f4a823          	sw	a5,400(s1)
    8000158a:	865a                	mv	a2,s6
    8000158c:	588c                	lw	a1,48(s1)
    8000158e:	00006517          	auipc	a0,0x6
    80001592:	ca250513          	addi	a0,a0,-862 # 80007230 <digits+0x1f8>
    80001596:	f2ffe0ef          	jal	ra,800004c4 <printf>
    
    // Debug: verify stack mapping worked
    uint64 pa_check_stack = walkaddr(pagetable, page_va);
    8000159a:	85da                	mv	a1,s6
    8000159c:	8556                	mv	a0,s5
    8000159e:	9b9ff0ef          	jal	ra,80000f56 <walkaddr>
    800015a2:	862a                	mv	a2,a0
    printf("[DEBUG] After stack mapping: va=0x%lx -> pa=0x%lx\n", page_va, pa_check_stack);
    800015a4:	85da                	mv	a1,s6
    800015a6:	00006517          	auipc	a0,0x6
    800015aa:	cb250513          	addi	a0,a0,-846 # 80007258 <digits+0x220>
    800015ae:	f17fe0ef          	jal	ra,800004c4 <printf>
    
    return 0;
    800015b2:	4501                	li	a0,0
    800015b4:	a42d                	j	800017de <vmfault+0x2fe>
      printf("[pid %d] MEMFULL\n", p->pid);
    800015b6:	588c                	lw	a1,48(s1)
    800015b8:	00006517          	auipc	a0,0x6
    800015bc:	c4050513          	addi	a0,a0,-960 # 800071f8 <digits+0x1c0>
    800015c0:	f05fe0ef          	jal	ra,800004c4 <printf>
      return -1;
    800015c4:	557d                	li	a0,-1
    800015c6:	ac21                	j	800017de <vmfault+0x2fe>
      kfree(mem);
    800015c8:	854a                	mv	a0,s2
    800015ca:	bf2ff0ef          	jal	ra,800009bc <kfree>
      return -1;
    800015ce:	557d                	li	a0,-1
    800015d0:	a439                	j	800017de <vmfault+0x2fe>
  }
  else if(va >= p->text_start && va < p->text_end) {
    800015d2:	1684b783          	ld	a5,360(s1)
    800015d6:	0af96b63          	bltu	s2,a5,8000168c <vmfault+0x1ac>
    800015da:	1704b783          	ld	a5,368(s1)
    800015de:	0af97763          	bgeu	s2,a5,8000168c <vmfault+0x1ac>
    // Text segment - allocate and load from executable
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=exec\n", 
    800015e2:	588c                	lw	a1,48(s1)
    800015e4:	00006697          	auipc	a3,0x6
    800015e8:	b8c68693          	addi	a3,a3,-1140 # 80007170 <digits+0x138>
    800015ec:	000a1663          	bnez	s4,800015f8 <vmfault+0x118>
    800015f0:	00006697          	auipc	a3,0x6
    800015f4:	2b868693          	addi	a3,a3,696 # 800078a8 <syscalls+0x1f0>
    800015f8:	865a                	mv	a2,s6
    800015fa:	00006517          	auipc	a0,0x6
    800015fe:	c9650513          	addi	a0,a0,-874 # 80007290 <digits+0x258>
    80001602:	ec3fe0ef          	jal	ra,800004c4 <printf>
            p->pid, page_va, is_write ? "write" : "read");
    
    if((mem = kalloc()) == 0) {
    80001606:	c96ff0ef          	jal	ra,80000a9c <kalloc>
    8000160a:	892a                	mv	s2,a0
    8000160c:	c135                	beqz	a0,80001670 <vmfault+0x190>
      printf("[pid %d] MEMFULL\n", p->pid);
      return -1;
    }
    memset(mem, 0, PGSIZE);
    8000160e:	6605                	lui	a2,0x1
    80001610:	4581                	li	a1,0
    80001612:	e2eff0ef          	jal	ra,80000c40 <memset>
    
    // Map the page
    if(mappages(pagetable, page_va, PGSIZE, (uint64)mem, PTE_R | PTE_X | PTE_U) < 0) {
    80001616:	4769                	li	a4,26
    80001618:	86ca                	mv	a3,s2
    8000161a:	6605                	lui	a2,0x1
    8000161c:	85da                	mv	a1,s6
    8000161e:	8556                	mv	a0,s5
    80001620:	975ff0ef          	jal	ra,80000f94 <mappages>
    80001624:	04054f63          	bltz	a0,80001682 <vmfault+0x1a2>
      kfree(mem);
      return -1;
    }
    
    printf("[pid %d] LOADEXEC va=0x%lx\n", p->pid, page_va);
    80001628:	865a                	mv	a2,s6
    8000162a:	588c                	lw	a1,48(s1)
    8000162c:	00006517          	auipc	a0,0x6
    80001630:	c9c50513          	addi	a0,a0,-868 # 800072c8 <digits+0x290>
    80001634:	e91fe0ef          	jal	ra,800004c4 <printf>
    printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, page_va, p->next_fifo_seq++);
    80001638:	1904a683          	lw	a3,400(s1)
    8000163c:	0016879b          	addiw	a5,a3,1
    80001640:	18f4a823          	sw	a5,400(s1)
    80001644:	865a                	mv	a2,s6
    80001646:	588c                	lw	a1,48(s1)
    80001648:	00006517          	auipc	a0,0x6
    8000164c:	be850513          	addi	a0,a0,-1048 # 80007230 <digits+0x1f8>
    80001650:	e75fe0ef          	jal	ra,800004c4 <printf>
    
    // Debug: verify text mapping worked
    uint64 pa_check_text = walkaddr(pagetable, page_va);
    80001654:	85da                	mv	a1,s6
    80001656:	8556                	mv	a0,s5
    80001658:	8ffff0ef          	jal	ra,80000f56 <walkaddr>
    8000165c:	862a                	mv	a2,a0
    printf("[DEBUG] After text mapping: va=0x%lx -> pa=0x%lx\n", page_va, pa_check_text);
    8000165e:	85da                	mv	a1,s6
    80001660:	00006517          	auipc	a0,0x6
    80001664:	c8850513          	addi	a0,a0,-888 # 800072e8 <digits+0x2b0>
    80001668:	e5dfe0ef          	jal	ra,800004c4 <printf>
    
    return 0;
    8000166c:	4501                	li	a0,0
    8000166e:	aa85                	j	800017de <vmfault+0x2fe>
      printf("[pid %d] MEMFULL\n", p->pid);
    80001670:	588c                	lw	a1,48(s1)
    80001672:	00006517          	auipc	a0,0x6
    80001676:	b8650513          	addi	a0,a0,-1146 # 800071f8 <digits+0x1c0>
    8000167a:	e4bfe0ef          	jal	ra,800004c4 <printf>
      return -1;
    8000167e:	557d                	li	a0,-1
    80001680:	aab9                	j	800017de <vmfault+0x2fe>
      kfree(mem);
    80001682:	854a                	mv	a0,s2
    80001684:	b38ff0ef          	jal	ra,800009bc <kfree>
      return -1;
    80001688:	557d                	li	a0,-1
    8000168a:	aa91                	j	800017de <vmfault+0x2fe>
  }
  else if(va >= p->data_start && va < p->data_end) {
    8000168c:	1784b783          	ld	a5,376(s1)
    80001690:	0af96b63          	bltu	s2,a5,80001746 <vmfault+0x266>
    80001694:	1804b783          	ld	a5,384(s1)
    80001698:	0af97763          	bgeu	s2,a5,80001746 <vmfault+0x266>
    // Data segment - allocate and load from executable
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=exec\n", 
    8000169c:	588c                	lw	a1,48(s1)
    8000169e:	00006697          	auipc	a3,0x6
    800016a2:	ad268693          	addi	a3,a3,-1326 # 80007170 <digits+0x138>
    800016a6:	000a1663          	bnez	s4,800016b2 <vmfault+0x1d2>
    800016aa:	00006697          	auipc	a3,0x6
    800016ae:	1fe68693          	addi	a3,a3,510 # 800078a8 <syscalls+0x1f0>
    800016b2:	865a                	mv	a2,s6
    800016b4:	00006517          	auipc	a0,0x6
    800016b8:	bdc50513          	addi	a0,a0,-1060 # 80007290 <digits+0x258>
    800016bc:	e09fe0ef          	jal	ra,800004c4 <printf>
            p->pid, page_va, is_write ? "write" : "read");
    
    if((mem = kalloc()) == 0) {
    800016c0:	bdcff0ef          	jal	ra,80000a9c <kalloc>
    800016c4:	892a                	mv	s2,a0
    800016c6:	c135                	beqz	a0,8000172a <vmfault+0x24a>
      printf("[pid %d] MEMFULL\n", p->pid);
      return -1;
    }
    memset(mem, 0, PGSIZE);
    800016c8:	6605                	lui	a2,0x1
    800016ca:	4581                	li	a1,0
    800016cc:	d74ff0ef          	jal	ra,80000c40 <memset>
    
    // Map the page
    if(mappages(pagetable, page_va, PGSIZE, (uint64)mem, PTE_R | PTE_W | PTE_U) < 0) {
    800016d0:	4759                	li	a4,22
    800016d2:	86ca                	mv	a3,s2
    800016d4:	6605                	lui	a2,0x1
    800016d6:	85da                	mv	a1,s6
    800016d8:	8556                	mv	a0,s5
    800016da:	8bbff0ef          	jal	ra,80000f94 <mappages>
    800016de:	04054f63          	bltz	a0,8000173c <vmfault+0x25c>
      kfree(mem);
      return -1;
    }
    
    printf("[pid %d] LOADEXEC va=0x%lx\n", p->pid, page_va);
    800016e2:	865a                	mv	a2,s6
    800016e4:	588c                	lw	a1,48(s1)
    800016e6:	00006517          	auipc	a0,0x6
    800016ea:	be250513          	addi	a0,a0,-1054 # 800072c8 <digits+0x290>
    800016ee:	dd7fe0ef          	jal	ra,800004c4 <printf>
    printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, page_va, p->next_fifo_seq++);
    800016f2:	1904a683          	lw	a3,400(s1)
    800016f6:	0016879b          	addiw	a5,a3,1
    800016fa:	18f4a823          	sw	a5,400(s1)
    800016fe:	865a                	mv	a2,s6
    80001700:	588c                	lw	a1,48(s1)
    80001702:	00006517          	auipc	a0,0x6
    80001706:	b2e50513          	addi	a0,a0,-1234 # 80007230 <digits+0x1f8>
    8000170a:	dbbfe0ef          	jal	ra,800004c4 <printf>
    
    // Debug: verify data mapping worked
    uint64 pa_check_data = walkaddr(pagetable, page_va);
    8000170e:	85da                	mv	a1,s6
    80001710:	8556                	mv	a0,s5
    80001712:	845ff0ef          	jal	ra,80000f56 <walkaddr>
    80001716:	862a                	mv	a2,a0
    printf("[DEBUG] After data mapping: va=0x%lx -> pa=0x%lx\n", page_va, pa_check_data);
    80001718:	85da                	mv	a1,s6
    8000171a:	00006517          	auipc	a0,0x6
    8000171e:	c0650513          	addi	a0,a0,-1018 # 80007320 <digits+0x2e8>
    80001722:	da3fe0ef          	jal	ra,800004c4 <printf>
    
    return 0;
    80001726:	4501                	li	a0,0
    80001728:	a85d                	j	800017de <vmfault+0x2fe>
      printf("[pid %d] MEMFULL\n", p->pid);
    8000172a:	588c                	lw	a1,48(s1)
    8000172c:	00006517          	auipc	a0,0x6
    80001730:	acc50513          	addi	a0,a0,-1332 # 800071f8 <digits+0x1c0>
    80001734:	d91fe0ef          	jal	ra,800004c4 <printf>
      return -1;
    80001738:	557d                	li	a0,-1
    8000173a:	a055                	j	800017de <vmfault+0x2fe>
      kfree(mem);
    8000173c:	854a                	mv	a0,s2
    8000173e:	a7eff0ef          	jal	ra,800009bc <kfree>
      return -1;
    80001742:	557d                	li	a0,-1
    80001744:	a869                	j	800017de <vmfault+0x2fe>
  }
  else if(va >= p->heap_start && va < p->sz - USERSTACK*PGSIZE) {
    80001746:	1884b783          	ld	a5,392(s1)
    8000174a:	0cf96263          	bltu	s2,a5,8000180e <vmfault+0x32e>
    8000174e:	0d397063          	bgeu	s2,s3,8000180e <vmfault+0x32e>
    // Heap - allocate zero-filled page
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=heap\n", 
    80001752:	588c                	lw	a1,48(s1)
    80001754:	00006697          	auipc	a3,0x6
    80001758:	a1c68693          	addi	a3,a3,-1508 # 80007170 <digits+0x138>
    8000175c:	000a1663          	bnez	s4,80001768 <vmfault+0x288>
    80001760:	00006697          	auipc	a3,0x6
    80001764:	14868693          	addi	a3,a3,328 # 800078a8 <syscalls+0x1f0>
    80001768:	865a                	mv	a2,s6
    8000176a:	00006517          	auipc	a0,0x6
    8000176e:	bee50513          	addi	a0,a0,-1042 # 80007358 <digits+0x320>
    80001772:	d53fe0ef          	jal	ra,800004c4 <printf>
            p->pid, page_va, is_write ? "write" : "read");
    
    if((mem = kalloc()) == 0) {
    80001776:	b26ff0ef          	jal	ra,80000a9c <kalloc>
    8000177a:	892a                	mv	s2,a0
    8000177c:	c93d                	beqz	a0,800017f2 <vmfault+0x312>
      printf("[pid %d] MEMFULL\n", p->pid);
      return -1;
    }
    memset(mem, 0, PGSIZE);
    8000177e:	6605                	lui	a2,0x1
    80001780:	4581                	li	a1,0
    80001782:	cbeff0ef          	jal	ra,80000c40 <memset>
    
    // Map the page
    if(mappages(pagetable, page_va, PGSIZE, (uint64)mem, PTE_R | PTE_W | PTE_U) < 0) {
    80001786:	4759                	li	a4,22
    80001788:	86ca                	mv	a3,s2
    8000178a:	6605                	lui	a2,0x1
    8000178c:	85da                	mv	a1,s6
    8000178e:	8556                	mv	a0,s5
    80001790:	805ff0ef          	jal	ra,80000f94 <mappages>
    80001794:	06054863          	bltz	a0,80001804 <vmfault+0x324>
      kfree(mem);
      return -1;
    }
    
    printf("[pid %d] ALLOC va=0x%lx\n", p->pid, page_va);
    80001798:	865a                	mv	a2,s6
    8000179a:	588c                	lw	a1,48(s1)
    8000179c:	00006517          	auipc	a0,0x6
    800017a0:	a7450513          	addi	a0,a0,-1420 # 80007210 <digits+0x1d8>
    800017a4:	d21fe0ef          	jal	ra,800004c4 <printf>
    printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, page_va, p->next_fifo_seq++);
    800017a8:	1904a683          	lw	a3,400(s1)
    800017ac:	0016879b          	addiw	a5,a3,1
    800017b0:	18f4a823          	sw	a5,400(s1)
    800017b4:	865a                	mv	a2,s6
    800017b6:	588c                	lw	a1,48(s1)
    800017b8:	00006517          	auipc	a0,0x6
    800017bc:	a7850513          	addi	a0,a0,-1416 # 80007230 <digits+0x1f8>
    800017c0:	d05fe0ef          	jal	ra,800004c4 <printf>
    
    // Debug: verify heap mapping worked
    uint64 pa_check_heap = walkaddr(pagetable, page_va);
    800017c4:	85da                	mv	a1,s6
    800017c6:	8556                	mv	a0,s5
    800017c8:	f8eff0ef          	jal	ra,80000f56 <walkaddr>
    800017cc:	862a                	mv	a2,a0
    printf("[DEBUG] After heap mapping: va=0x%lx -> pa=0x%lx\n", page_va, pa_check_heap);
    800017ce:	85da                	mv	a1,s6
    800017d0:	00006517          	auipc	a0,0x6
    800017d4:	bc050513          	addi	a0,a0,-1088 # 80007390 <digits+0x358>
    800017d8:	cedfe0ef          	jal	ra,800004c4 <printf>
    
    return 0;
    800017dc:	4501                	li	a0,0
            p->pid, page_va, is_write ? "write" : "read");
    printf("[pid %d] KILL invalid-access va=0x%lx access=%s\n", 
            p->pid, page_va, is_write ? "write" : "read");
    return -1;
  }
    800017de:	70e2                	ld	ra,56(sp)
    800017e0:	7442                	ld	s0,48(sp)
    800017e2:	74a2                	ld	s1,40(sp)
    800017e4:	7902                	ld	s2,32(sp)
    800017e6:	69e2                	ld	s3,24(sp)
    800017e8:	6a42                	ld	s4,16(sp)
    800017ea:	6aa2                	ld	s5,8(sp)
    800017ec:	6b02                	ld	s6,0(sp)
    800017ee:	6121                	addi	sp,sp,64
    800017f0:	8082                	ret
      printf("[pid %d] MEMFULL\n", p->pid);
    800017f2:	588c                	lw	a1,48(s1)
    800017f4:	00006517          	auipc	a0,0x6
    800017f8:	a0450513          	addi	a0,a0,-1532 # 800071f8 <digits+0x1c0>
    800017fc:	cc9fe0ef          	jal	ra,800004c4 <printf>
      return -1;
    80001800:	557d                	li	a0,-1
    80001802:	bff1                	j	800017de <vmfault+0x2fe>
      kfree(mem);
    80001804:	854a                	mv	a0,s2
    80001806:	9b6ff0ef          	jal	ra,800009bc <kfree>
      return -1;
    8000180a:	557d                	li	a0,-1
    8000180c:	bfc9                	j	800017de <vmfault+0x2fe>
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=invalid\n", 
    8000180e:	588c                	lw	a1,48(s1)
    80001810:	00006917          	auipc	s2,0x6
    80001814:	96090913          	addi	s2,s2,-1696 # 80007170 <digits+0x138>
    80001818:	000a1663          	bnez	s4,80001824 <vmfault+0x344>
    8000181c:	00006917          	auipc	s2,0x6
    80001820:	08c90913          	addi	s2,s2,140 # 800078a8 <syscalls+0x1f0>
    80001824:	86ca                	mv	a3,s2
    80001826:	865a                	mv	a2,s6
    80001828:	00006517          	auipc	a0,0x6
    8000182c:	ba050513          	addi	a0,a0,-1120 # 800073c8 <digits+0x390>
    80001830:	c95fe0ef          	jal	ra,800004c4 <printf>
    printf("[pid %d] KILL invalid-access va=0x%lx access=%s\n", 
    80001834:	86ca                	mv	a3,s2
    80001836:	865a                	mv	a2,s6
    80001838:	588c                	lw	a1,48(s1)
    8000183a:	00006517          	auipc	a0,0x6
    8000183e:	bc650513          	addi	a0,a0,-1082 # 80007400 <digits+0x3c8>
    80001842:	c83fe0ef          	jal	ra,800004c4 <printf>
    return -1;
    80001846:	557d                	li	a0,-1
    80001848:	bf59                	j	800017de <vmfault+0x2fe>

000000008000184a <copyout>:
  while(len > 0){
    8000184a:	cec1                	beqz	a3,800018e2 <copyout+0x98>
{
    8000184c:	711d                	addi	sp,sp,-96
    8000184e:	ec86                	sd	ra,88(sp)
    80001850:	e8a2                	sd	s0,80(sp)
    80001852:	e4a6                	sd	s1,72(sp)
    80001854:	e0ca                	sd	s2,64(sp)
    80001856:	fc4e                	sd	s3,56(sp)
    80001858:	f852                	sd	s4,48(sp)
    8000185a:	f456                	sd	s5,40(sp)
    8000185c:	f05a                	sd	s6,32(sp)
    8000185e:	ec5e                	sd	s7,24(sp)
    80001860:	e862                	sd	s8,16(sp)
    80001862:	e466                	sd	s9,8(sp)
    80001864:	e06a                	sd	s10,0(sp)
    80001866:	1080                	addi	s0,sp,96
    80001868:	8c2a                	mv	s8,a0
    8000186a:	8b2e                	mv	s6,a1
    8000186c:	8bb2                	mv	s7,a2
    8000186e:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    80001870:	74fd                	lui	s1,0xfffff
    80001872:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001874:	57fd                	li	a5,-1
    80001876:	83e9                	srli	a5,a5,0x1a
    80001878:	0697e763          	bltu	a5,s1,800018e6 <copyout+0x9c>
    8000187c:	6d05                	lui	s10,0x1
    8000187e:	8cbe                	mv	s9,a5
    80001880:	a015                	j	800018a4 <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001882:	409b0533          	sub	a0,s6,s1
    80001886:	0009861b          	sext.w	a2,s3
    8000188a:	85de                	mv	a1,s7
    8000188c:	954a                	add	a0,a0,s2
    8000188e:	c0eff0ef          	jal	ra,80000c9c <memmove>
    len -= n;
    80001892:	413a0a33          	sub	s4,s4,s3
    src += n;
    80001896:	9bce                	add	s7,s7,s3
  while(len > 0){
    80001898:	040a0363          	beqz	s4,800018de <copyout+0x94>
    if(va0 >= MAXVA)
    8000189c:	055ce763          	bltu	s9,s5,800018ea <copyout+0xa0>
    va0 = PGROUNDDOWN(dstva);
    800018a0:	84d6                	mv	s1,s5
    dstva = va0 + PGSIZE;
    800018a2:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    800018a4:	85a6                	mv	a1,s1
    800018a6:	8562                	mv	a0,s8
    800018a8:	eaeff0ef          	jal	ra,80000f56 <walkaddr>
    800018ac:	892a                	mv	s2,a0
    if(pa0 == 0) {
    800018ae:	e901                	bnez	a0,800018be <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800018b0:	4601                	li	a2,0
    800018b2:	85a6                	mv	a1,s1
    800018b4:	8562                	mv	a0,s8
    800018b6:	c2bff0ef          	jal	ra,800014e0 <vmfault>
    800018ba:	892a                	mv	s2,a0
    800018bc:	c90d                	beqz	a0,800018ee <copyout+0xa4>
    pte = walk(pagetable, va0, 0);
    800018be:	4601                	li	a2,0
    800018c0:	85a6                	mv	a1,s1
    800018c2:	8562                	mv	a0,s8
    800018c4:	df8ff0ef          	jal	ra,80000ebc <walk>
    if((*pte & PTE_W) == 0)
    800018c8:	611c                	ld	a5,0(a0)
    800018ca:	8b91                	andi	a5,a5,4
    800018cc:	c39d                	beqz	a5,800018f2 <copyout+0xa8>
    n = PGSIZE - (dstva - va0);
    800018ce:	01a48ab3          	add	s5,s1,s10
    800018d2:	416a89b3          	sub	s3,s5,s6
    if(n > len)
    800018d6:	fb3a76e3          	bgeu	s4,s3,80001882 <copyout+0x38>
    800018da:	89d2                	mv	s3,s4
    800018dc:	b75d                	j	80001882 <copyout+0x38>
  return 0;
    800018de:	4501                	li	a0,0
    800018e0:	a811                	j	800018f4 <copyout+0xaa>
    800018e2:	4501                	li	a0,0
}
    800018e4:	8082                	ret
      return -1;
    800018e6:	557d                	li	a0,-1
    800018e8:	a031                	j	800018f4 <copyout+0xaa>
    800018ea:	557d                	li	a0,-1
    800018ec:	a021                	j	800018f4 <copyout+0xaa>
        return -1;
    800018ee:	557d                	li	a0,-1
    800018f0:	a011                	j	800018f4 <copyout+0xaa>
      return -1;
    800018f2:	557d                	li	a0,-1
}
    800018f4:	60e6                	ld	ra,88(sp)
    800018f6:	6446                	ld	s0,80(sp)
    800018f8:	64a6                	ld	s1,72(sp)
    800018fa:	6906                	ld	s2,64(sp)
    800018fc:	79e2                	ld	s3,56(sp)
    800018fe:	7a42                	ld	s4,48(sp)
    80001900:	7aa2                	ld	s5,40(sp)
    80001902:	7b02                	ld	s6,32(sp)
    80001904:	6be2                	ld	s7,24(sp)
    80001906:	6c42                	ld	s8,16(sp)
    80001908:	6ca2                	ld	s9,8(sp)
    8000190a:	6d02                	ld	s10,0(sp)
    8000190c:	6125                	addi	sp,sp,96
    8000190e:	8082                	ret

0000000080001910 <copyin>:
  while(len > 0){
    80001910:	c6c9                	beqz	a3,8000199a <copyin+0x8a>
{
    80001912:	715d                	addi	sp,sp,-80
    80001914:	e486                	sd	ra,72(sp)
    80001916:	e0a2                	sd	s0,64(sp)
    80001918:	fc26                	sd	s1,56(sp)
    8000191a:	f84a                	sd	s2,48(sp)
    8000191c:	f44e                	sd	s3,40(sp)
    8000191e:	f052                	sd	s4,32(sp)
    80001920:	ec56                	sd	s5,24(sp)
    80001922:	e85a                	sd	s6,16(sp)
    80001924:	e45e                	sd	s7,8(sp)
    80001926:	e062                	sd	s8,0(sp)
    80001928:	0880                	addi	s0,sp,80
    8000192a:	8baa                	mv	s7,a0
    8000192c:	8aae                	mv	s5,a1
    8000192e:	8932                	mv	s2,a2
    80001930:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001932:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001934:	6b05                	lui	s6,0x1
    80001936:	a035                	j	80001962 <copyin+0x52>
    80001938:	412984b3          	sub	s1,s3,s2
    8000193c:	94da                	add	s1,s1,s6
    if(n > len)
    8000193e:	009a7363          	bgeu	s4,s1,80001944 <copyin+0x34>
    80001942:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001944:	413905b3          	sub	a1,s2,s3
    80001948:	0004861b          	sext.w	a2,s1
    8000194c:	95aa                	add	a1,a1,a0
    8000194e:	8556                	mv	a0,s5
    80001950:	b4cff0ef          	jal	ra,80000c9c <memmove>
    len -= n;
    80001954:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001958:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    8000195a:	01698933          	add	s2,s3,s6
  while(len > 0){
    8000195e:	020a0163          	beqz	s4,80001980 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001962:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001966:	85ce                	mv	a1,s3
    80001968:	855e                	mv	a0,s7
    8000196a:	decff0ef          	jal	ra,80000f56 <walkaddr>
    if(pa0 == 0) {
    8000196e:	f569                	bnez	a0,80001938 <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001970:	4601                	li	a2,0
    80001972:	85ce                	mv	a1,s3
    80001974:	855e                	mv	a0,s7
    80001976:	b6bff0ef          	jal	ra,800014e0 <vmfault>
    8000197a:	fd5d                	bnez	a0,80001938 <copyin+0x28>
        return -1;
    8000197c:	557d                	li	a0,-1
    8000197e:	a011                	j	80001982 <copyin+0x72>
  return 0;
    80001980:	4501                	li	a0,0
}
    80001982:	60a6                	ld	ra,72(sp)
    80001984:	6406                	ld	s0,64(sp)
    80001986:	74e2                	ld	s1,56(sp)
    80001988:	7942                	ld	s2,48(sp)
    8000198a:	79a2                	ld	s3,40(sp)
    8000198c:	7a02                	ld	s4,32(sp)
    8000198e:	6ae2                	ld	s5,24(sp)
    80001990:	6b42                	ld	s6,16(sp)
    80001992:	6ba2                	ld	s7,8(sp)
    80001994:	6c02                	ld	s8,0(sp)
    80001996:	6161                	addi	sp,sp,80
    80001998:	8082                	ret
  return 0;
    8000199a:	4501                	li	a0,0
}
    8000199c:	8082                	ret

000000008000199e <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000199e:	7139                	addi	sp,sp,-64
    800019a0:	fc06                	sd	ra,56(sp)
    800019a2:	f822                	sd	s0,48(sp)
    800019a4:	f426                	sd	s1,40(sp)
    800019a6:	f04a                	sd	s2,32(sp)
    800019a8:	ec4e                	sd	s3,24(sp)
    800019aa:	e852                	sd	s4,16(sp)
    800019ac:	e456                	sd	s5,8(sp)
    800019ae:	e05a                	sd	s6,0(sp)
    800019b0:	0080                	addi	s0,sp,64
    800019b2:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800019b4:	0000e497          	auipc	s1,0xe
    800019b8:	77448493          	addi	s1,s1,1908 # 80010128 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800019bc:	8b26                	mv	s6,s1
    800019be:	00005a97          	auipc	s5,0x5
    800019c2:	642a8a93          	addi	s5,s5,1602 # 80007000 <etext>
    800019c6:	04000937          	lui	s2,0x4000
    800019ca:	197d                	addi	s2,s2,-1
    800019cc:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019ce:	00015a17          	auipc	s4,0x15
    800019d2:	f5aa0a13          	addi	s4,s4,-166 # 80016928 <tickslock>
    char *pa = kalloc();
    800019d6:	8c6ff0ef          	jal	ra,80000a9c <kalloc>
    800019da:	862a                	mv	a2,a0
    if(pa == 0)
    800019dc:	c121                	beqz	a0,80001a1c <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    800019de:	416485b3          	sub	a1,s1,s6
    800019e2:	8595                	srai	a1,a1,0x5
    800019e4:	000ab783          	ld	a5,0(s5)
    800019e8:	02f585b3          	mul	a1,a1,a5
    800019ec:	2585                	addiw	a1,a1,1
    800019ee:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019f2:	4719                	li	a4,6
    800019f4:	6685                	lui	a3,0x1
    800019f6:	40b905b3          	sub	a1,s2,a1
    800019fa:	854e                	mv	a0,s3
    800019fc:	e48ff0ef          	jal	ra,80001044 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a00:	1a048493          	addi	s1,s1,416
    80001a04:	fd4499e3          	bne	s1,s4,800019d6 <proc_mapstacks+0x38>
  }
}
    80001a08:	70e2                	ld	ra,56(sp)
    80001a0a:	7442                	ld	s0,48(sp)
    80001a0c:	74a2                	ld	s1,40(sp)
    80001a0e:	7902                	ld	s2,32(sp)
    80001a10:	69e2                	ld	s3,24(sp)
    80001a12:	6a42                	ld	s4,16(sp)
    80001a14:	6aa2                	ld	s5,8(sp)
    80001a16:	6b02                	ld	s6,0(sp)
    80001a18:	6121                	addi	sp,sp,64
    80001a1a:	8082                	ret
      panic("kalloc");
    80001a1c:	00006517          	auipc	a0,0x6
    80001a20:	a1c50513          	addi	a0,a0,-1508 # 80007438 <digits+0x400>
    80001a24:	d67fe0ef          	jal	ra,8000078a <panic>

0000000080001a28 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001a28:	7139                	addi	sp,sp,-64
    80001a2a:	fc06                	sd	ra,56(sp)
    80001a2c:	f822                	sd	s0,48(sp)
    80001a2e:	f426                	sd	s1,40(sp)
    80001a30:	f04a                	sd	s2,32(sp)
    80001a32:	ec4e                	sd	s3,24(sp)
    80001a34:	e852                	sd	s4,16(sp)
    80001a36:	e456                	sd	s5,8(sp)
    80001a38:	e05a                	sd	s6,0(sp)
    80001a3a:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001a3c:	00006597          	auipc	a1,0x6
    80001a40:	a0458593          	addi	a1,a1,-1532 # 80007440 <digits+0x408>
    80001a44:	0000e517          	auipc	a0,0xe
    80001a48:	2b450513          	addi	a0,a0,692 # 8000fcf8 <pid_lock>
    80001a4c:	8a0ff0ef          	jal	ra,80000aec <initlock>
  initlock(&wait_lock, "wait_lock");
    80001a50:	00006597          	auipc	a1,0x6
    80001a54:	9f858593          	addi	a1,a1,-1544 # 80007448 <digits+0x410>
    80001a58:	0000e517          	auipc	a0,0xe
    80001a5c:	2b850513          	addi	a0,a0,696 # 8000fd10 <wait_lock>
    80001a60:	88cff0ef          	jal	ra,80000aec <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a64:	0000e497          	auipc	s1,0xe
    80001a68:	6c448493          	addi	s1,s1,1732 # 80010128 <proc>
      initlock(&p->lock, "proc");
    80001a6c:	00006b17          	auipc	s6,0x6
    80001a70:	9ecb0b13          	addi	s6,s6,-1556 # 80007458 <digits+0x420>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001a74:	8aa6                	mv	s5,s1
    80001a76:	00005a17          	auipc	s4,0x5
    80001a7a:	58aa0a13          	addi	s4,s4,1418 # 80007000 <etext>
    80001a7e:	04000937          	lui	s2,0x4000
    80001a82:	197d                	addi	s2,s2,-1
    80001a84:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a86:	00015997          	auipc	s3,0x15
    80001a8a:	ea298993          	addi	s3,s3,-350 # 80016928 <tickslock>
      initlock(&p->lock, "proc");
    80001a8e:	85da                	mv	a1,s6
    80001a90:	8526                	mv	a0,s1
    80001a92:	85aff0ef          	jal	ra,80000aec <initlock>
      p->state = UNUSED;
    80001a96:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001a9a:	415487b3          	sub	a5,s1,s5
    80001a9e:	8795                	srai	a5,a5,0x5
    80001aa0:	000a3703          	ld	a4,0(s4)
    80001aa4:	02e787b3          	mul	a5,a5,a4
    80001aa8:	2785                	addiw	a5,a5,1
    80001aaa:	00d7979b          	slliw	a5,a5,0xd
    80001aae:	40f907b3          	sub	a5,s2,a5
    80001ab2:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ab4:	1a048493          	addi	s1,s1,416
    80001ab8:	fd349be3          	bne	s1,s3,80001a8e <procinit+0x66>
  }
}
    80001abc:	70e2                	ld	ra,56(sp)
    80001abe:	7442                	ld	s0,48(sp)
    80001ac0:	74a2                	ld	s1,40(sp)
    80001ac2:	7902                	ld	s2,32(sp)
    80001ac4:	69e2                	ld	s3,24(sp)
    80001ac6:	6a42                	ld	s4,16(sp)
    80001ac8:	6aa2                	ld	s5,8(sp)
    80001aca:	6b02                	ld	s6,0(sp)
    80001acc:	6121                	addi	sp,sp,64
    80001ace:	8082                	ret

0000000080001ad0 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001ad0:	1141                	addi	sp,sp,-16
    80001ad2:	e422                	sd	s0,8(sp)
    80001ad4:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ad6:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001ad8:	2501                	sext.w	a0,a0
    80001ada:	6422                	ld	s0,8(sp)
    80001adc:	0141                	addi	sp,sp,16
    80001ade:	8082                	ret

0000000080001ae0 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001ae0:	1141                	addi	sp,sp,-16
    80001ae2:	e422                	sd	s0,8(sp)
    80001ae4:	0800                	addi	s0,sp,16
    80001ae6:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001ae8:	2781                	sext.w	a5,a5
    80001aea:	079e                	slli	a5,a5,0x7
  return c;
}
    80001aec:	0000e517          	auipc	a0,0xe
    80001af0:	23c50513          	addi	a0,a0,572 # 8000fd28 <cpus>
    80001af4:	953e                	add	a0,a0,a5
    80001af6:	6422                	ld	s0,8(sp)
    80001af8:	0141                	addi	sp,sp,16
    80001afa:	8082                	ret

0000000080001afc <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001afc:	1101                	addi	sp,sp,-32
    80001afe:	ec06                	sd	ra,24(sp)
    80001b00:	e822                	sd	s0,16(sp)
    80001b02:	e426                	sd	s1,8(sp)
    80001b04:	1000                	addi	s0,sp,32
  push_off();
    80001b06:	826ff0ef          	jal	ra,80000b2c <push_off>
    80001b0a:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001b0c:	2781                	sext.w	a5,a5
    80001b0e:	079e                	slli	a5,a5,0x7
    80001b10:	0000e717          	auipc	a4,0xe
    80001b14:	1e870713          	addi	a4,a4,488 # 8000fcf8 <pid_lock>
    80001b18:	97ba                	add	a5,a5,a4
    80001b1a:	7b84                	ld	s1,48(a5)
  pop_off();
    80001b1c:	894ff0ef          	jal	ra,80000bb0 <pop_off>
  return p;
}
    80001b20:	8526                	mv	a0,s1
    80001b22:	60e2                	ld	ra,24(sp)
    80001b24:	6442                	ld	s0,16(sp)
    80001b26:	64a2                	ld	s1,8(sp)
    80001b28:	6105                	addi	sp,sp,32
    80001b2a:	8082                	ret

0000000080001b2c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001b2c:	7179                	addi	sp,sp,-48
    80001b2e:	f406                	sd	ra,40(sp)
    80001b30:	f022                	sd	s0,32(sp)
    80001b32:	ec26                	sd	s1,24(sp)
    80001b34:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001b36:	fc7ff0ef          	jal	ra,80001afc <myproc>
    80001b3a:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001b3c:	8c8ff0ef          	jal	ra,80000c04 <release>

  if (first) {
    80001b40:	00006797          	auipc	a5,0x6
    80001b44:	0807a783          	lw	a5,128(a5) # 80007bc0 <first.1>
    80001b48:	cf8d                	beqz	a5,80001b82 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001b4a:	4505                	li	a0,1
    80001b4c:	393010ef          	jal	ra,800036de <fsinit>

    first = 0;
    80001b50:	00006797          	auipc	a5,0x6
    80001b54:	0607a823          	sw	zero,112(a5) # 80007bc0 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001b58:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001b5c:	00006517          	auipc	a0,0x6
    80001b60:	90450513          	addi	a0,a0,-1788 # 80007460 <digits+0x428>
    80001b64:	fca43823          	sd	a0,-48(s0)
    80001b68:	fc043c23          	sd	zero,-40(s0)
    80001b6c:	fd040593          	addi	a1,s0,-48
    80001b70:	40d020ef          	jal	ra,8000477c <kexec>
    80001b74:	6cbc                	ld	a5,88(s1)
    80001b76:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001b78:	6cbc                	ld	a5,88(s1)
    80001b7a:	7bb8                	ld	a4,112(a5)
    80001b7c:	57fd                	li	a5,-1
    80001b7e:	02f70d63          	beq	a4,a5,80001bb8 <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001b82:	2c5000ef          	jal	ra,80002646 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001b86:	68a8                	ld	a0,80(s1)
    80001b88:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001b8a:	04000737          	lui	a4,0x4000
    80001b8e:	00004797          	auipc	a5,0x4
    80001b92:	50e78793          	addi	a5,a5,1294 # 8000609c <userret>
    80001b96:	00004697          	auipc	a3,0x4
    80001b9a:	46a68693          	addi	a3,a3,1130 # 80006000 <_trampoline>
    80001b9e:	8f95                	sub	a5,a5,a3
    80001ba0:	177d                	addi	a4,a4,-1
    80001ba2:	0732                	slli	a4,a4,0xc
    80001ba4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001ba6:	577d                	li	a4,-1
    80001ba8:	177e                	slli	a4,a4,0x3f
    80001baa:	8d59                	or	a0,a0,a4
    80001bac:	9782                	jalr	a5
}
    80001bae:	70a2                	ld	ra,40(sp)
    80001bb0:	7402                	ld	s0,32(sp)
    80001bb2:	64e2                	ld	s1,24(sp)
    80001bb4:	6145                	addi	sp,sp,48
    80001bb6:	8082                	ret
      panic("exec");
    80001bb8:	00006517          	auipc	a0,0x6
    80001bbc:	8b050513          	addi	a0,a0,-1872 # 80007468 <digits+0x430>
    80001bc0:	bcbfe0ef          	jal	ra,8000078a <panic>

0000000080001bc4 <allocpid>:
{
    80001bc4:	1101                	addi	sp,sp,-32
    80001bc6:	ec06                	sd	ra,24(sp)
    80001bc8:	e822                	sd	s0,16(sp)
    80001bca:	e426                	sd	s1,8(sp)
    80001bcc:	e04a                	sd	s2,0(sp)
    80001bce:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001bd0:	0000e917          	auipc	s2,0xe
    80001bd4:	12890913          	addi	s2,s2,296 # 8000fcf8 <pid_lock>
    80001bd8:	854a                	mv	a0,s2
    80001bda:	f93fe0ef          	jal	ra,80000b6c <acquire>
  pid = nextpid;
    80001bde:	00006797          	auipc	a5,0x6
    80001be2:	fe678793          	addi	a5,a5,-26 # 80007bc4 <nextpid>
    80001be6:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001be8:	0014871b          	addiw	a4,s1,1
    80001bec:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001bee:	854a                	mv	a0,s2
    80001bf0:	814ff0ef          	jal	ra,80000c04 <release>
}
    80001bf4:	8526                	mv	a0,s1
    80001bf6:	60e2                	ld	ra,24(sp)
    80001bf8:	6442                	ld	s0,16(sp)
    80001bfa:	64a2                	ld	s1,8(sp)
    80001bfc:	6902                	ld	s2,0(sp)
    80001bfe:	6105                	addi	sp,sp,32
    80001c00:	8082                	ret

0000000080001c02 <proc_pagetable>:
{
    80001c02:	1101                	addi	sp,sp,-32
    80001c04:	ec06                	sd	ra,24(sp)
    80001c06:	e822                	sd	s0,16(sp)
    80001c08:	e426                	sd	s1,8(sp)
    80001c0a:	e04a                	sd	s2,0(sp)
    80001c0c:	1000                	addi	s0,sp,32
    80001c0e:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c10:	d2aff0ef          	jal	ra,8000113a <uvmcreate>
    80001c14:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001c16:	cd05                	beqz	a0,80001c4e <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c18:	4729                	li	a4,10
    80001c1a:	00004697          	auipc	a3,0x4
    80001c1e:	3e668693          	addi	a3,a3,998 # 80006000 <_trampoline>
    80001c22:	6605                	lui	a2,0x1
    80001c24:	040005b7          	lui	a1,0x4000
    80001c28:	15fd                	addi	a1,a1,-1
    80001c2a:	05b2                	slli	a1,a1,0xc
    80001c2c:	b68ff0ef          	jal	ra,80000f94 <mappages>
    80001c30:	02054663          	bltz	a0,80001c5c <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c34:	4719                	li	a4,6
    80001c36:	05893683          	ld	a3,88(s2)
    80001c3a:	6605                	lui	a2,0x1
    80001c3c:	020005b7          	lui	a1,0x2000
    80001c40:	15fd                	addi	a1,a1,-1
    80001c42:	05b6                	slli	a1,a1,0xd
    80001c44:	8526                	mv	a0,s1
    80001c46:	b4eff0ef          	jal	ra,80000f94 <mappages>
    80001c4a:	00054f63          	bltz	a0,80001c68 <proc_pagetable+0x66>
}
    80001c4e:	8526                	mv	a0,s1
    80001c50:	60e2                	ld	ra,24(sp)
    80001c52:	6442                	ld	s0,16(sp)
    80001c54:	64a2                	ld	s1,8(sp)
    80001c56:	6902                	ld	s2,0(sp)
    80001c58:	6105                	addi	sp,sp,32
    80001c5a:	8082                	ret
    uvmfree(pagetable, 0);
    80001c5c:	4581                	li	a1,0
    80001c5e:	8526                	mv	a0,s1
    80001c60:	eb8ff0ef          	jal	ra,80001318 <uvmfree>
    return 0;
    80001c64:	4481                	li	s1,0
    80001c66:	b7e5                	j	80001c4e <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c68:	4681                	li	a3,0
    80001c6a:	4605                	li	a2,1
    80001c6c:	040005b7          	lui	a1,0x4000
    80001c70:	15fd                	addi	a1,a1,-1
    80001c72:	05b2                	slli	a1,a1,0xc
    80001c74:	8526                	mv	a0,s1
    80001c76:	ceaff0ef          	jal	ra,80001160 <uvmunmap>
    uvmfree(pagetable, 0);
    80001c7a:	4581                	li	a1,0
    80001c7c:	8526                	mv	a0,s1
    80001c7e:	e9aff0ef          	jal	ra,80001318 <uvmfree>
    return 0;
    80001c82:	4481                	li	s1,0
    80001c84:	b7e9                	j	80001c4e <proc_pagetable+0x4c>

0000000080001c86 <proc_freepagetable>:
{
    80001c86:	1101                	addi	sp,sp,-32
    80001c88:	ec06                	sd	ra,24(sp)
    80001c8a:	e822                	sd	s0,16(sp)
    80001c8c:	e426                	sd	s1,8(sp)
    80001c8e:	e04a                	sd	s2,0(sp)
    80001c90:	1000                	addi	s0,sp,32
    80001c92:	84aa                	mv	s1,a0
    80001c94:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c96:	4681                	li	a3,0
    80001c98:	4605                	li	a2,1
    80001c9a:	040005b7          	lui	a1,0x4000
    80001c9e:	15fd                	addi	a1,a1,-1
    80001ca0:	05b2                	slli	a1,a1,0xc
    80001ca2:	cbeff0ef          	jal	ra,80001160 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001ca6:	4681                	li	a3,0
    80001ca8:	4605                	li	a2,1
    80001caa:	020005b7          	lui	a1,0x2000
    80001cae:	15fd                	addi	a1,a1,-1
    80001cb0:	05b6                	slli	a1,a1,0xd
    80001cb2:	8526                	mv	a0,s1
    80001cb4:	cacff0ef          	jal	ra,80001160 <uvmunmap>
  uvmfree(pagetable, sz);
    80001cb8:	85ca                	mv	a1,s2
    80001cba:	8526                	mv	a0,s1
    80001cbc:	e5cff0ef          	jal	ra,80001318 <uvmfree>
}
    80001cc0:	60e2                	ld	ra,24(sp)
    80001cc2:	6442                	ld	s0,16(sp)
    80001cc4:	64a2                	ld	s1,8(sp)
    80001cc6:	6902                	ld	s2,0(sp)
    80001cc8:	6105                	addi	sp,sp,32
    80001cca:	8082                	ret

0000000080001ccc <freeproc>:
{
    80001ccc:	1101                	addi	sp,sp,-32
    80001cce:	ec06                	sd	ra,24(sp)
    80001cd0:	e822                	sd	s0,16(sp)
    80001cd2:	e426                	sd	s1,8(sp)
    80001cd4:	1000                	addi	s0,sp,32
    80001cd6:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001cd8:	6d28                	ld	a0,88(a0)
    80001cda:	c119                	beqz	a0,80001ce0 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001cdc:	ce1fe0ef          	jal	ra,800009bc <kfree>
  p->trapframe = 0;
    80001ce0:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001ce4:	68a8                	ld	a0,80(s1)
    80001ce6:	c501                	beqz	a0,80001cee <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001ce8:	64ac                	ld	a1,72(s1)
    80001cea:	f9dff0ef          	jal	ra,80001c86 <proc_freepagetable>
  p->pagetable = 0;
    80001cee:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001cf2:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001cf6:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001cfa:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001cfe:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001d02:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001d06:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001d0a:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001d0e:	0004ac23          	sw	zero,24(s1)
}
    80001d12:	60e2                	ld	ra,24(sp)
    80001d14:	6442                	ld	s0,16(sp)
    80001d16:	64a2                	ld	s1,8(sp)
    80001d18:	6105                	addi	sp,sp,32
    80001d1a:	8082                	ret

0000000080001d1c <allocproc>:
{
    80001d1c:	1101                	addi	sp,sp,-32
    80001d1e:	ec06                	sd	ra,24(sp)
    80001d20:	e822                	sd	s0,16(sp)
    80001d22:	e426                	sd	s1,8(sp)
    80001d24:	e04a                	sd	s2,0(sp)
    80001d26:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d28:	0000e497          	auipc	s1,0xe
    80001d2c:	40048493          	addi	s1,s1,1024 # 80010128 <proc>
    80001d30:	00015917          	auipc	s2,0x15
    80001d34:	bf890913          	addi	s2,s2,-1032 # 80016928 <tickslock>
    acquire(&p->lock);
    80001d38:	8526                	mv	a0,s1
    80001d3a:	e33fe0ef          	jal	ra,80000b6c <acquire>
    if(p->state == UNUSED) {
    80001d3e:	4c9c                	lw	a5,24(s1)
    80001d40:	cb91                	beqz	a5,80001d54 <allocproc+0x38>
      release(&p->lock);
    80001d42:	8526                	mv	a0,s1
    80001d44:	ec1fe0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d48:	1a048493          	addi	s1,s1,416
    80001d4c:	ff2496e3          	bne	s1,s2,80001d38 <allocproc+0x1c>
  return 0;
    80001d50:	4481                	li	s1,0
    80001d52:	a8b9                	j	80001db0 <allocproc+0x94>
  p->pid = allocpid();
    80001d54:	e71ff0ef          	jal	ra,80001bc4 <allocpid>
    80001d58:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001d5a:	4785                	li	a5,1
    80001d5c:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001d5e:	d3ffe0ef          	jal	ra,80000a9c <kalloc>
    80001d62:	892a                	mv	s2,a0
    80001d64:	eca8                	sd	a0,88(s1)
    80001d66:	cd21                	beqz	a0,80001dbe <allocproc+0xa2>
  p->pagetable = proc_pagetable(p);
    80001d68:	8526                	mv	a0,s1
    80001d6a:	e99ff0ef          	jal	ra,80001c02 <proc_pagetable>
    80001d6e:	892a                	mv	s2,a0
    80001d70:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001d72:	cd31                	beqz	a0,80001dce <allocproc+0xb2>
  memset(&p->context, 0, sizeof(p->context));
    80001d74:	07000613          	li	a2,112
    80001d78:	4581                	li	a1,0
    80001d7a:	06048513          	addi	a0,s1,96
    80001d7e:	ec3fe0ef          	jal	ra,80000c40 <memset>
  p->context.ra = (uint64)forkret;
    80001d82:	00000797          	auipc	a5,0x0
    80001d86:	daa78793          	addi	a5,a5,-598 # 80001b2c <forkret>
    80001d8a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d8c:	60bc                	ld	a5,64(s1)
    80001d8e:	6705                	lui	a4,0x1
    80001d90:	97ba                	add	a5,a5,a4
    80001d92:	f4bc                	sd	a5,104(s1)
  p->text_start = 0;
    80001d94:	1604b423          	sd	zero,360(s1)
  p->text_end = 0;
    80001d98:	1604b823          	sd	zero,368(s1)
  p->data_start = 0;
    80001d9c:	1604bc23          	sd	zero,376(s1)
  p->data_end = 0;
    80001da0:	1804b023          	sd	zero,384(s1)
  p->heap_start = 0;
    80001da4:	1804b423          	sd	zero,392(s1)
  p->next_fifo_seq = 0;
    80001da8:	1804a823          	sw	zero,400(s1)
  p->exec_inode = 0;
    80001dac:	1804bc23          	sd	zero,408(s1)
}
    80001db0:	8526                	mv	a0,s1
    80001db2:	60e2                	ld	ra,24(sp)
    80001db4:	6442                	ld	s0,16(sp)
    80001db6:	64a2                	ld	s1,8(sp)
    80001db8:	6902                	ld	s2,0(sp)
    80001dba:	6105                	addi	sp,sp,32
    80001dbc:	8082                	ret
    freeproc(p);
    80001dbe:	8526                	mv	a0,s1
    80001dc0:	f0dff0ef          	jal	ra,80001ccc <freeproc>
    release(&p->lock);
    80001dc4:	8526                	mv	a0,s1
    80001dc6:	e3ffe0ef          	jal	ra,80000c04 <release>
    return 0;
    80001dca:	84ca                	mv	s1,s2
    80001dcc:	b7d5                	j	80001db0 <allocproc+0x94>
    freeproc(p);
    80001dce:	8526                	mv	a0,s1
    80001dd0:	efdff0ef          	jal	ra,80001ccc <freeproc>
    release(&p->lock);
    80001dd4:	8526                	mv	a0,s1
    80001dd6:	e2ffe0ef          	jal	ra,80000c04 <release>
    return 0;
    80001dda:	84ca                	mv	s1,s2
    80001ddc:	bfd1                	j	80001db0 <allocproc+0x94>

0000000080001dde <userinit>:
{
    80001dde:	1101                	addi	sp,sp,-32
    80001de0:	ec06                	sd	ra,24(sp)
    80001de2:	e822                	sd	s0,16(sp)
    80001de4:	e426                	sd	s1,8(sp)
    80001de6:	1000                	addi	s0,sp,32
  p = allocproc();
    80001de8:	f35ff0ef          	jal	ra,80001d1c <allocproc>
    80001dec:	84aa                	mv	s1,a0
  initproc = p;
    80001dee:	00006797          	auipc	a5,0x6
    80001df2:	e0a7b123          	sd	a0,-510(a5) # 80007bf0 <initproc>
  p->cwd = namei("/");
    80001df6:	00005517          	auipc	a0,0x5
    80001dfa:	67a50513          	addi	a0,a0,1658 # 80007470 <digits+0x438>
    80001dfe:	5df010ef          	jal	ra,80003bdc <namei>
    80001e02:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001e06:	478d                	li	a5,3
    80001e08:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001e0a:	8526                	mv	a0,s1
    80001e0c:	df9fe0ef          	jal	ra,80000c04 <release>
}
    80001e10:	60e2                	ld	ra,24(sp)
    80001e12:	6442                	ld	s0,16(sp)
    80001e14:	64a2                	ld	s1,8(sp)
    80001e16:	6105                	addi	sp,sp,32
    80001e18:	8082                	ret

0000000080001e1a <growproc>:
{
    80001e1a:	1101                	addi	sp,sp,-32
    80001e1c:	ec06                	sd	ra,24(sp)
    80001e1e:	e822                	sd	s0,16(sp)
    80001e20:	e426                	sd	s1,8(sp)
    80001e22:	e04a                	sd	s2,0(sp)
    80001e24:	1000                	addi	s0,sp,32
    80001e26:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001e28:	cd5ff0ef          	jal	ra,80001afc <myproc>
    80001e2c:	84aa                	mv	s1,a0
  sz = p->sz;
    80001e2e:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001e30:	01204c63          	bgtz	s2,80001e48 <growproc+0x2e>
  } else if(n < 0){
    80001e34:	02094463          	bltz	s2,80001e5c <growproc+0x42>
  p->sz = sz;
    80001e38:	e4ac                	sd	a1,72(s1)
  return 0;
    80001e3a:	4501                	li	a0,0
}
    80001e3c:	60e2                	ld	ra,24(sp)
    80001e3e:	6442                	ld	s0,16(sp)
    80001e40:	64a2                	ld	s1,8(sp)
    80001e42:	6902                	ld	s2,0(sp)
    80001e44:	6105                	addi	sp,sp,32
    80001e46:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001e48:	4691                	li	a3,4
    80001e4a:	00b90633          	add	a2,s2,a1
    80001e4e:	6928                	ld	a0,80(a0)
    80001e50:	bd0ff0ef          	jal	ra,80001220 <uvmalloc>
    80001e54:	85aa                	mv	a1,a0
    80001e56:	f16d                	bnez	a0,80001e38 <growproc+0x1e>
      return -1;
    80001e58:	557d                	li	a0,-1
    80001e5a:	b7cd                	j	80001e3c <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e5c:	00b90633          	add	a2,s2,a1
    80001e60:	6928                	ld	a0,80(a0)
    80001e62:	b7aff0ef          	jal	ra,800011dc <uvmdealloc>
    80001e66:	85aa                	mv	a1,a0
    80001e68:	bfc1                	j	80001e38 <growproc+0x1e>

0000000080001e6a <kfork>:
{
    80001e6a:	7139                	addi	sp,sp,-64
    80001e6c:	fc06                	sd	ra,56(sp)
    80001e6e:	f822                	sd	s0,48(sp)
    80001e70:	f426                	sd	s1,40(sp)
    80001e72:	f04a                	sd	s2,32(sp)
    80001e74:	ec4e                	sd	s3,24(sp)
    80001e76:	e852                	sd	s4,16(sp)
    80001e78:	e456                	sd	s5,8(sp)
    80001e7a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e7c:	c81ff0ef          	jal	ra,80001afc <myproc>
    80001e80:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e82:	e9bff0ef          	jal	ra,80001d1c <allocproc>
    80001e86:	0e050663          	beqz	a0,80001f72 <kfork+0x108>
    80001e8a:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e8c:	048ab603          	ld	a2,72(s5)
    80001e90:	692c                	ld	a1,80(a0)
    80001e92:	050ab503          	ld	a0,80(s5)
    80001e96:	cb2ff0ef          	jal	ra,80001348 <uvmcopy>
    80001e9a:	04054863          	bltz	a0,80001eea <kfork+0x80>
  np->sz = p->sz;
    80001e9e:	048ab783          	ld	a5,72(s5)
    80001ea2:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001ea6:	058ab683          	ld	a3,88(s5)
    80001eaa:	87b6                	mv	a5,a3
    80001eac:	058a3703          	ld	a4,88(s4)
    80001eb0:	12068693          	addi	a3,a3,288
    80001eb4:	0007b803          	ld	a6,0(a5)
    80001eb8:	6788                	ld	a0,8(a5)
    80001eba:	6b8c                	ld	a1,16(a5)
    80001ebc:	6f90                	ld	a2,24(a5)
    80001ebe:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001ec2:	e708                	sd	a0,8(a4)
    80001ec4:	eb0c                	sd	a1,16(a4)
    80001ec6:	ef10                	sd	a2,24(a4)
    80001ec8:	02078793          	addi	a5,a5,32
    80001ecc:	02070713          	addi	a4,a4,32
    80001ed0:	fed792e3          	bne	a5,a3,80001eb4 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001ed4:	058a3783          	ld	a5,88(s4)
    80001ed8:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001edc:	0d0a8493          	addi	s1,s5,208
    80001ee0:	0d0a0913          	addi	s2,s4,208
    80001ee4:	150a8993          	addi	s3,s5,336
    80001ee8:	a829                	j	80001f02 <kfork+0x98>
    freeproc(np);
    80001eea:	8552                	mv	a0,s4
    80001eec:	de1ff0ef          	jal	ra,80001ccc <freeproc>
    release(&np->lock);
    80001ef0:	8552                	mv	a0,s4
    80001ef2:	d13fe0ef          	jal	ra,80000c04 <release>
    return -1;
    80001ef6:	597d                	li	s2,-1
    80001ef8:	a09d                	j	80001f5e <kfork+0xf4>
  for(i = 0; i < NOFILE; i++)
    80001efa:	04a1                	addi	s1,s1,8
    80001efc:	0921                	addi	s2,s2,8
    80001efe:	01348963          	beq	s1,s3,80001f10 <kfork+0xa6>
    if(p->ofile[i])
    80001f02:	6088                	ld	a0,0(s1)
    80001f04:	d97d                	beqz	a0,80001efa <kfork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f06:	28e020ef          	jal	ra,80004194 <filedup>
    80001f0a:	00a93023          	sd	a0,0(s2)
    80001f0e:	b7f5                	j	80001efa <kfork+0x90>
  np->cwd = idup(p->cwd);
    80001f10:	150ab503          	ld	a0,336(s5)
    80001f14:	4a4010ef          	jal	ra,800033b8 <idup>
    80001f18:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f1c:	4641                	li	a2,16
    80001f1e:	158a8593          	addi	a1,s5,344
    80001f22:	158a0513          	addi	a0,s4,344
    80001f26:	e61fe0ef          	jal	ra,80000d86 <safestrcpy>
  pid = np->pid;
    80001f2a:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001f2e:	8552                	mv	a0,s4
    80001f30:	cd5fe0ef          	jal	ra,80000c04 <release>
  acquire(&wait_lock);
    80001f34:	0000e497          	auipc	s1,0xe
    80001f38:	ddc48493          	addi	s1,s1,-548 # 8000fd10 <wait_lock>
    80001f3c:	8526                	mv	a0,s1
    80001f3e:	c2ffe0ef          	jal	ra,80000b6c <acquire>
  np->parent = p;
    80001f42:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001f46:	8526                	mv	a0,s1
    80001f48:	cbdfe0ef          	jal	ra,80000c04 <release>
  acquire(&np->lock);
    80001f4c:	8552                	mv	a0,s4
    80001f4e:	c1ffe0ef          	jal	ra,80000b6c <acquire>
  np->state = RUNNABLE;
    80001f52:	478d                	li	a5,3
    80001f54:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f58:	8552                	mv	a0,s4
    80001f5a:	cabfe0ef          	jal	ra,80000c04 <release>
}
    80001f5e:	854a                	mv	a0,s2
    80001f60:	70e2                	ld	ra,56(sp)
    80001f62:	7442                	ld	s0,48(sp)
    80001f64:	74a2                	ld	s1,40(sp)
    80001f66:	7902                	ld	s2,32(sp)
    80001f68:	69e2                	ld	s3,24(sp)
    80001f6a:	6a42                	ld	s4,16(sp)
    80001f6c:	6aa2                	ld	s5,8(sp)
    80001f6e:	6121                	addi	sp,sp,64
    80001f70:	8082                	ret
    return -1;
    80001f72:	597d                	li	s2,-1
    80001f74:	b7ed                	j	80001f5e <kfork+0xf4>

0000000080001f76 <scheduler>:
{
    80001f76:	715d                	addi	sp,sp,-80
    80001f78:	e486                	sd	ra,72(sp)
    80001f7a:	e0a2                	sd	s0,64(sp)
    80001f7c:	fc26                	sd	s1,56(sp)
    80001f7e:	f84a                	sd	s2,48(sp)
    80001f80:	f44e                	sd	s3,40(sp)
    80001f82:	f052                	sd	s4,32(sp)
    80001f84:	ec56                	sd	s5,24(sp)
    80001f86:	e85a                	sd	s6,16(sp)
    80001f88:	e45e                	sd	s7,8(sp)
    80001f8a:	e062                	sd	s8,0(sp)
    80001f8c:	0880                	addi	s0,sp,80
    80001f8e:	8792                	mv	a5,tp
  int id = r_tp();
    80001f90:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f92:	00779b13          	slli	s6,a5,0x7
    80001f96:	0000e717          	auipc	a4,0xe
    80001f9a:	d6270713          	addi	a4,a4,-670 # 8000fcf8 <pid_lock>
    80001f9e:	975a                	add	a4,a4,s6
    80001fa0:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001fa4:	0000e717          	auipc	a4,0xe
    80001fa8:	d8c70713          	addi	a4,a4,-628 # 8000fd30 <cpus+0x8>
    80001fac:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001fae:	4c11                	li	s8,4
        c->proc = p;
    80001fb0:	079e                	slli	a5,a5,0x7
    80001fb2:	0000ea17          	auipc	s4,0xe
    80001fb6:	d46a0a13          	addi	s4,s4,-698 # 8000fcf8 <pid_lock>
    80001fba:	9a3e                	add	s4,s4,a5
        found = 1;
    80001fbc:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fbe:	00015997          	auipc	s3,0x15
    80001fc2:	96a98993          	addi	s3,s3,-1686 # 80016928 <tickslock>
    80001fc6:	a83d                	j	80002004 <scheduler+0x8e>
      release(&p->lock);
    80001fc8:	8526                	mv	a0,s1
    80001fca:	c3bfe0ef          	jal	ra,80000c04 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fce:	1a048493          	addi	s1,s1,416
    80001fd2:	03348563          	beq	s1,s3,80001ffc <scheduler+0x86>
      acquire(&p->lock);
    80001fd6:	8526                	mv	a0,s1
    80001fd8:	b95fe0ef          	jal	ra,80000b6c <acquire>
      if(p->state == RUNNABLE) {
    80001fdc:	4c9c                	lw	a5,24(s1)
    80001fde:	ff2795e3          	bne	a5,s2,80001fc8 <scheduler+0x52>
        p->state = RUNNING;
    80001fe2:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001fe6:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001fea:	06048593          	addi	a1,s1,96
    80001fee:	855a                	mv	a0,s6
    80001ff0:	5b0000ef          	jal	ra,800025a0 <swtch>
        c->proc = 0;
    80001ff4:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001ff8:	8ade                	mv	s5,s7
    80001ffa:	b7f9                	j	80001fc8 <scheduler+0x52>
    if(found == 0) {
    80001ffc:	000a9463          	bnez	s5,80002004 <scheduler+0x8e>
      asm volatile("wfi");
    80002000:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002004:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002008:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000200c:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002010:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002014:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002016:	10079073          	csrw	sstatus,a5
    int found = 0;
    8000201a:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    8000201c:	0000e497          	auipc	s1,0xe
    80002020:	10c48493          	addi	s1,s1,268 # 80010128 <proc>
      if(p->state == RUNNABLE) {
    80002024:	490d                	li	s2,3
    80002026:	bf45                	j	80001fd6 <scheduler+0x60>

0000000080002028 <sched>:
{
    80002028:	7179                	addi	sp,sp,-48
    8000202a:	f406                	sd	ra,40(sp)
    8000202c:	f022                	sd	s0,32(sp)
    8000202e:	ec26                	sd	s1,24(sp)
    80002030:	e84a                	sd	s2,16(sp)
    80002032:	e44e                	sd	s3,8(sp)
    80002034:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002036:	ac7ff0ef          	jal	ra,80001afc <myproc>
    8000203a:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000203c:	ac7fe0ef          	jal	ra,80000b02 <holding>
    80002040:	c92d                	beqz	a0,800020b2 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002042:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002044:	2781                	sext.w	a5,a5
    80002046:	079e                	slli	a5,a5,0x7
    80002048:	0000e717          	auipc	a4,0xe
    8000204c:	cb070713          	addi	a4,a4,-848 # 8000fcf8 <pid_lock>
    80002050:	97ba                	add	a5,a5,a4
    80002052:	0a87a703          	lw	a4,168(a5)
    80002056:	4785                	li	a5,1
    80002058:	06f71363          	bne	a4,a5,800020be <sched+0x96>
  if(p->state == RUNNING)
    8000205c:	4c98                	lw	a4,24(s1)
    8000205e:	4791                	li	a5,4
    80002060:	06f70563          	beq	a4,a5,800020ca <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002064:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002068:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000206a:	e7b5                	bnez	a5,800020d6 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000206c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000206e:	0000e917          	auipc	s2,0xe
    80002072:	c8a90913          	addi	s2,s2,-886 # 8000fcf8 <pid_lock>
    80002076:	2781                	sext.w	a5,a5
    80002078:	079e                	slli	a5,a5,0x7
    8000207a:	97ca                	add	a5,a5,s2
    8000207c:	0ac7a983          	lw	s3,172(a5)
    80002080:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002082:	2781                	sext.w	a5,a5
    80002084:	079e                	slli	a5,a5,0x7
    80002086:	0000e597          	auipc	a1,0xe
    8000208a:	caa58593          	addi	a1,a1,-854 # 8000fd30 <cpus+0x8>
    8000208e:	95be                	add	a1,a1,a5
    80002090:	06048513          	addi	a0,s1,96
    80002094:	50c000ef          	jal	ra,800025a0 <swtch>
    80002098:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000209a:	2781                	sext.w	a5,a5
    8000209c:	079e                	slli	a5,a5,0x7
    8000209e:	97ca                	add	a5,a5,s2
    800020a0:	0b37a623          	sw	s3,172(a5)
}
    800020a4:	70a2                	ld	ra,40(sp)
    800020a6:	7402                	ld	s0,32(sp)
    800020a8:	64e2                	ld	s1,24(sp)
    800020aa:	6942                	ld	s2,16(sp)
    800020ac:	69a2                	ld	s3,8(sp)
    800020ae:	6145                	addi	sp,sp,48
    800020b0:	8082                	ret
    panic("sched p->lock");
    800020b2:	00005517          	auipc	a0,0x5
    800020b6:	3c650513          	addi	a0,a0,966 # 80007478 <digits+0x440>
    800020ba:	ed0fe0ef          	jal	ra,8000078a <panic>
    panic("sched locks");
    800020be:	00005517          	auipc	a0,0x5
    800020c2:	3ca50513          	addi	a0,a0,970 # 80007488 <digits+0x450>
    800020c6:	ec4fe0ef          	jal	ra,8000078a <panic>
    panic("sched RUNNING");
    800020ca:	00005517          	auipc	a0,0x5
    800020ce:	3ce50513          	addi	a0,a0,974 # 80007498 <digits+0x460>
    800020d2:	eb8fe0ef          	jal	ra,8000078a <panic>
    panic("sched interruptible");
    800020d6:	00005517          	auipc	a0,0x5
    800020da:	3d250513          	addi	a0,a0,978 # 800074a8 <digits+0x470>
    800020de:	eacfe0ef          	jal	ra,8000078a <panic>

00000000800020e2 <yield>:
{
    800020e2:	1101                	addi	sp,sp,-32
    800020e4:	ec06                	sd	ra,24(sp)
    800020e6:	e822                	sd	s0,16(sp)
    800020e8:	e426                	sd	s1,8(sp)
    800020ea:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020ec:	a11ff0ef          	jal	ra,80001afc <myproc>
    800020f0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020f2:	a7bfe0ef          	jal	ra,80000b6c <acquire>
  p->state = RUNNABLE;
    800020f6:	478d                	li	a5,3
    800020f8:	cc9c                	sw	a5,24(s1)
  sched();
    800020fa:	f2fff0ef          	jal	ra,80002028 <sched>
  release(&p->lock);
    800020fe:	8526                	mv	a0,s1
    80002100:	b05fe0ef          	jal	ra,80000c04 <release>
}
    80002104:	60e2                	ld	ra,24(sp)
    80002106:	6442                	ld	s0,16(sp)
    80002108:	64a2                	ld	s1,8(sp)
    8000210a:	6105                	addi	sp,sp,32
    8000210c:	8082                	ret

000000008000210e <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000210e:	7179                	addi	sp,sp,-48
    80002110:	f406                	sd	ra,40(sp)
    80002112:	f022                	sd	s0,32(sp)
    80002114:	ec26                	sd	s1,24(sp)
    80002116:	e84a                	sd	s2,16(sp)
    80002118:	e44e                	sd	s3,8(sp)
    8000211a:	1800                	addi	s0,sp,48
    8000211c:	89aa                	mv	s3,a0
    8000211e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002120:	9ddff0ef          	jal	ra,80001afc <myproc>
    80002124:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002126:	a47fe0ef          	jal	ra,80000b6c <acquire>
  release(lk);
    8000212a:	854a                	mv	a0,s2
    8000212c:	ad9fe0ef          	jal	ra,80000c04 <release>

  // Go to sleep.
  p->chan = chan;
    80002130:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002134:	4789                	li	a5,2
    80002136:	cc9c                	sw	a5,24(s1)

  sched();
    80002138:	ef1ff0ef          	jal	ra,80002028 <sched>

  // Tidy up.
  p->chan = 0;
    8000213c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002140:	8526                	mv	a0,s1
    80002142:	ac3fe0ef          	jal	ra,80000c04 <release>
  acquire(lk);
    80002146:	854a                	mv	a0,s2
    80002148:	a25fe0ef          	jal	ra,80000b6c <acquire>
}
    8000214c:	70a2                	ld	ra,40(sp)
    8000214e:	7402                	ld	s0,32(sp)
    80002150:	64e2                	ld	s1,24(sp)
    80002152:	6942                	ld	s2,16(sp)
    80002154:	69a2                	ld	s3,8(sp)
    80002156:	6145                	addi	sp,sp,48
    80002158:	8082                	ret

000000008000215a <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    8000215a:	7139                	addi	sp,sp,-64
    8000215c:	fc06                	sd	ra,56(sp)
    8000215e:	f822                	sd	s0,48(sp)
    80002160:	f426                	sd	s1,40(sp)
    80002162:	f04a                	sd	s2,32(sp)
    80002164:	ec4e                	sd	s3,24(sp)
    80002166:	e852                	sd	s4,16(sp)
    80002168:	e456                	sd	s5,8(sp)
    8000216a:	0080                	addi	s0,sp,64
    8000216c:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000216e:	0000e497          	auipc	s1,0xe
    80002172:	fba48493          	addi	s1,s1,-70 # 80010128 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002176:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002178:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000217a:	00014917          	auipc	s2,0x14
    8000217e:	7ae90913          	addi	s2,s2,1966 # 80016928 <tickslock>
    80002182:	a801                	j	80002192 <wakeup+0x38>
      }
      release(&p->lock);
    80002184:	8526                	mv	a0,s1
    80002186:	a7ffe0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000218a:	1a048493          	addi	s1,s1,416
    8000218e:	03248263          	beq	s1,s2,800021b2 <wakeup+0x58>
    if(p != myproc()){
    80002192:	96bff0ef          	jal	ra,80001afc <myproc>
    80002196:	fea48ae3          	beq	s1,a0,8000218a <wakeup+0x30>
      acquire(&p->lock);
    8000219a:	8526                	mv	a0,s1
    8000219c:	9d1fe0ef          	jal	ra,80000b6c <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800021a0:	4c9c                	lw	a5,24(s1)
    800021a2:	ff3791e3          	bne	a5,s3,80002184 <wakeup+0x2a>
    800021a6:	709c                	ld	a5,32(s1)
    800021a8:	fd479ee3          	bne	a5,s4,80002184 <wakeup+0x2a>
        p->state = RUNNABLE;
    800021ac:	0154ac23          	sw	s5,24(s1)
    800021b0:	bfd1                	j	80002184 <wakeup+0x2a>
    }
  }
}
    800021b2:	70e2                	ld	ra,56(sp)
    800021b4:	7442                	ld	s0,48(sp)
    800021b6:	74a2                	ld	s1,40(sp)
    800021b8:	7902                	ld	s2,32(sp)
    800021ba:	69e2                	ld	s3,24(sp)
    800021bc:	6a42                	ld	s4,16(sp)
    800021be:	6aa2                	ld	s5,8(sp)
    800021c0:	6121                	addi	sp,sp,64
    800021c2:	8082                	ret

00000000800021c4 <reparent>:
{
    800021c4:	7179                	addi	sp,sp,-48
    800021c6:	f406                	sd	ra,40(sp)
    800021c8:	f022                	sd	s0,32(sp)
    800021ca:	ec26                	sd	s1,24(sp)
    800021cc:	e84a                	sd	s2,16(sp)
    800021ce:	e44e                	sd	s3,8(sp)
    800021d0:	e052                	sd	s4,0(sp)
    800021d2:	1800                	addi	s0,sp,48
    800021d4:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021d6:	0000e497          	auipc	s1,0xe
    800021da:	f5248493          	addi	s1,s1,-174 # 80010128 <proc>
      pp->parent = initproc;
    800021de:	00006a17          	auipc	s4,0x6
    800021e2:	a12a0a13          	addi	s4,s4,-1518 # 80007bf0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021e6:	00014997          	auipc	s3,0x14
    800021ea:	74298993          	addi	s3,s3,1858 # 80016928 <tickslock>
    800021ee:	a029                	j	800021f8 <reparent+0x34>
    800021f0:	1a048493          	addi	s1,s1,416
    800021f4:	01348b63          	beq	s1,s3,8000220a <reparent+0x46>
    if(pp->parent == p){
    800021f8:	7c9c                	ld	a5,56(s1)
    800021fa:	ff279be3          	bne	a5,s2,800021f0 <reparent+0x2c>
      pp->parent = initproc;
    800021fe:	000a3503          	ld	a0,0(s4)
    80002202:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002204:	f57ff0ef          	jal	ra,8000215a <wakeup>
    80002208:	b7e5                	j	800021f0 <reparent+0x2c>
}
    8000220a:	70a2                	ld	ra,40(sp)
    8000220c:	7402                	ld	s0,32(sp)
    8000220e:	64e2                	ld	s1,24(sp)
    80002210:	6942                	ld	s2,16(sp)
    80002212:	69a2                	ld	s3,8(sp)
    80002214:	6a02                	ld	s4,0(sp)
    80002216:	6145                	addi	sp,sp,48
    80002218:	8082                	ret

000000008000221a <kexit>:
{
    8000221a:	7179                	addi	sp,sp,-48
    8000221c:	f406                	sd	ra,40(sp)
    8000221e:	f022                	sd	s0,32(sp)
    80002220:	ec26                	sd	s1,24(sp)
    80002222:	e84a                	sd	s2,16(sp)
    80002224:	e44e                	sd	s3,8(sp)
    80002226:	e052                	sd	s4,0(sp)
    80002228:	1800                	addi	s0,sp,48
    8000222a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000222c:	8d1ff0ef          	jal	ra,80001afc <myproc>
    80002230:	89aa                	mv	s3,a0
  if(p == initproc)
    80002232:	00006797          	auipc	a5,0x6
    80002236:	9be7b783          	ld	a5,-1602(a5) # 80007bf0 <initproc>
    8000223a:	0d050493          	addi	s1,a0,208
    8000223e:	15050913          	addi	s2,a0,336
    80002242:	00a79f63          	bne	a5,a0,80002260 <kexit+0x46>
    panic("init exiting");
    80002246:	00005517          	auipc	a0,0x5
    8000224a:	27a50513          	addi	a0,a0,634 # 800074c0 <digits+0x488>
    8000224e:	d3cfe0ef          	jal	ra,8000078a <panic>
      fileclose(f);
    80002252:	789010ef          	jal	ra,800041da <fileclose>
      p->ofile[fd] = 0;
    80002256:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000225a:	04a1                	addi	s1,s1,8
    8000225c:	01248563          	beq	s1,s2,80002266 <kexit+0x4c>
    if(p->ofile[fd]){
    80002260:	6088                	ld	a0,0(s1)
    80002262:	f965                	bnez	a0,80002252 <kexit+0x38>
    80002264:	bfdd                	j	8000225a <kexit+0x40>
  begin_op();
    80002266:	367010ef          	jal	ra,80003dcc <begin_op>
  iput(p->cwd);
    8000226a:	1509b503          	ld	a0,336(s3)
    8000226e:	2fe010ef          	jal	ra,8000356c <iput>
  end_op();
    80002272:	3cb010ef          	jal	ra,80003e3c <end_op>
  p->cwd = 0;
    80002276:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000227a:	0000e497          	auipc	s1,0xe
    8000227e:	a9648493          	addi	s1,s1,-1386 # 8000fd10 <wait_lock>
    80002282:	8526                	mv	a0,s1
    80002284:	8e9fe0ef          	jal	ra,80000b6c <acquire>
  reparent(p);
    80002288:	854e                	mv	a0,s3
    8000228a:	f3bff0ef          	jal	ra,800021c4 <reparent>
  wakeup(p->parent);
    8000228e:	0389b503          	ld	a0,56(s3)
    80002292:	ec9ff0ef          	jal	ra,8000215a <wakeup>
  acquire(&p->lock);
    80002296:	854e                	mv	a0,s3
    80002298:	8d5fe0ef          	jal	ra,80000b6c <acquire>
  p->xstate = status;
    8000229c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022a0:	4795                	li	a5,5
    800022a2:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800022a6:	8526                	mv	a0,s1
    800022a8:	95dfe0ef          	jal	ra,80000c04 <release>
  sched();
    800022ac:	d7dff0ef          	jal	ra,80002028 <sched>
  panic("zombie exit");
    800022b0:	00005517          	auipc	a0,0x5
    800022b4:	22050513          	addi	a0,a0,544 # 800074d0 <digits+0x498>
    800022b8:	cd2fe0ef          	jal	ra,8000078a <panic>

00000000800022bc <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800022bc:	7179                	addi	sp,sp,-48
    800022be:	f406                	sd	ra,40(sp)
    800022c0:	f022                	sd	s0,32(sp)
    800022c2:	ec26                	sd	s1,24(sp)
    800022c4:	e84a                	sd	s2,16(sp)
    800022c6:	e44e                	sd	s3,8(sp)
    800022c8:	1800                	addi	s0,sp,48
    800022ca:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800022cc:	0000e497          	auipc	s1,0xe
    800022d0:	e5c48493          	addi	s1,s1,-420 # 80010128 <proc>
    800022d4:	00014997          	auipc	s3,0x14
    800022d8:	65498993          	addi	s3,s3,1620 # 80016928 <tickslock>
    acquire(&p->lock);
    800022dc:	8526                	mv	a0,s1
    800022de:	88ffe0ef          	jal	ra,80000b6c <acquire>
    if(p->pid == pid){
    800022e2:	589c                	lw	a5,48(s1)
    800022e4:	01278b63          	beq	a5,s2,800022fa <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800022e8:	8526                	mv	a0,s1
    800022ea:	91bfe0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800022ee:	1a048493          	addi	s1,s1,416
    800022f2:	ff3495e3          	bne	s1,s3,800022dc <kkill+0x20>
  }
  return -1;
    800022f6:	557d                	li	a0,-1
    800022f8:	a819                	j	8000230e <kkill+0x52>
      p->killed = 1;
    800022fa:	4785                	li	a5,1
    800022fc:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800022fe:	4c98                	lw	a4,24(s1)
    80002300:	4789                	li	a5,2
    80002302:	00f70d63          	beq	a4,a5,8000231c <kkill+0x60>
      release(&p->lock);
    80002306:	8526                	mv	a0,s1
    80002308:	8fdfe0ef          	jal	ra,80000c04 <release>
      return 0;
    8000230c:	4501                	li	a0,0
}
    8000230e:	70a2                	ld	ra,40(sp)
    80002310:	7402                	ld	s0,32(sp)
    80002312:	64e2                	ld	s1,24(sp)
    80002314:	6942                	ld	s2,16(sp)
    80002316:	69a2                	ld	s3,8(sp)
    80002318:	6145                	addi	sp,sp,48
    8000231a:	8082                	ret
        p->state = RUNNABLE;
    8000231c:	478d                	li	a5,3
    8000231e:	cc9c                	sw	a5,24(s1)
    80002320:	b7dd                	j	80002306 <kkill+0x4a>

0000000080002322 <setkilled>:

void
setkilled(struct proc *p)
{
    80002322:	1101                	addi	sp,sp,-32
    80002324:	ec06                	sd	ra,24(sp)
    80002326:	e822                	sd	s0,16(sp)
    80002328:	e426                	sd	s1,8(sp)
    8000232a:	1000                	addi	s0,sp,32
    8000232c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000232e:	83ffe0ef          	jal	ra,80000b6c <acquire>
  p->killed = 1;
    80002332:	4785                	li	a5,1
    80002334:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002336:	8526                	mv	a0,s1
    80002338:	8cdfe0ef          	jal	ra,80000c04 <release>
}
    8000233c:	60e2                	ld	ra,24(sp)
    8000233e:	6442                	ld	s0,16(sp)
    80002340:	64a2                	ld	s1,8(sp)
    80002342:	6105                	addi	sp,sp,32
    80002344:	8082                	ret

0000000080002346 <killed>:

int
killed(struct proc *p)
{
    80002346:	1101                	addi	sp,sp,-32
    80002348:	ec06                	sd	ra,24(sp)
    8000234a:	e822                	sd	s0,16(sp)
    8000234c:	e426                	sd	s1,8(sp)
    8000234e:	e04a                	sd	s2,0(sp)
    80002350:	1000                	addi	s0,sp,32
    80002352:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002354:	819fe0ef          	jal	ra,80000b6c <acquire>
  k = p->killed;
    80002358:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000235c:	8526                	mv	a0,s1
    8000235e:	8a7fe0ef          	jal	ra,80000c04 <release>
  return k;
}
    80002362:	854a                	mv	a0,s2
    80002364:	60e2                	ld	ra,24(sp)
    80002366:	6442                	ld	s0,16(sp)
    80002368:	64a2                	ld	s1,8(sp)
    8000236a:	6902                	ld	s2,0(sp)
    8000236c:	6105                	addi	sp,sp,32
    8000236e:	8082                	ret

0000000080002370 <kwait>:
{
    80002370:	715d                	addi	sp,sp,-80
    80002372:	e486                	sd	ra,72(sp)
    80002374:	e0a2                	sd	s0,64(sp)
    80002376:	fc26                	sd	s1,56(sp)
    80002378:	f84a                	sd	s2,48(sp)
    8000237a:	f44e                	sd	s3,40(sp)
    8000237c:	f052                	sd	s4,32(sp)
    8000237e:	ec56                	sd	s5,24(sp)
    80002380:	e85a                	sd	s6,16(sp)
    80002382:	e45e                	sd	s7,8(sp)
    80002384:	e062                	sd	s8,0(sp)
    80002386:	0880                	addi	s0,sp,80
    80002388:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000238a:	f72ff0ef          	jal	ra,80001afc <myproc>
    8000238e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002390:	0000e517          	auipc	a0,0xe
    80002394:	98050513          	addi	a0,a0,-1664 # 8000fd10 <wait_lock>
    80002398:	fd4fe0ef          	jal	ra,80000b6c <acquire>
    havekids = 0;
    8000239c:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000239e:	4a15                	li	s4,5
        havekids = 1;
    800023a0:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023a2:	00014997          	auipc	s3,0x14
    800023a6:	58698993          	addi	s3,s3,1414 # 80016928 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023aa:	0000ec17          	auipc	s8,0xe
    800023ae:	966c0c13          	addi	s8,s8,-1690 # 8000fd10 <wait_lock>
    havekids = 0;
    800023b2:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023b4:	0000e497          	auipc	s1,0xe
    800023b8:	d7448493          	addi	s1,s1,-652 # 80010128 <proc>
    800023bc:	a899                	j	80002412 <kwait+0xa2>
          pid = pp->pid;
    800023be:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800023c2:	000b0c63          	beqz	s6,800023da <kwait+0x6a>
    800023c6:	4691                	li	a3,4
    800023c8:	02c48613          	addi	a2,s1,44
    800023cc:	85da                	mv	a1,s6
    800023ce:	05093503          	ld	a0,80(s2)
    800023d2:	c78ff0ef          	jal	ra,8000184a <copyout>
    800023d6:	00054f63          	bltz	a0,800023f4 <kwait+0x84>
          freeproc(pp);
    800023da:	8526                	mv	a0,s1
    800023dc:	8f1ff0ef          	jal	ra,80001ccc <freeproc>
          release(&pp->lock);
    800023e0:	8526                	mv	a0,s1
    800023e2:	823fe0ef          	jal	ra,80000c04 <release>
          release(&wait_lock);
    800023e6:	0000e517          	auipc	a0,0xe
    800023ea:	92a50513          	addi	a0,a0,-1750 # 8000fd10 <wait_lock>
    800023ee:	817fe0ef          	jal	ra,80000c04 <release>
          return pid;
    800023f2:	a891                	j	80002446 <kwait+0xd6>
            release(&pp->lock);
    800023f4:	8526                	mv	a0,s1
    800023f6:	80ffe0ef          	jal	ra,80000c04 <release>
            release(&wait_lock);
    800023fa:	0000e517          	auipc	a0,0xe
    800023fe:	91650513          	addi	a0,a0,-1770 # 8000fd10 <wait_lock>
    80002402:	803fe0ef          	jal	ra,80000c04 <release>
            return -1;
    80002406:	59fd                	li	s3,-1
    80002408:	a83d                	j	80002446 <kwait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000240a:	1a048493          	addi	s1,s1,416
    8000240e:	03348063          	beq	s1,s3,8000242e <kwait+0xbe>
      if(pp->parent == p){
    80002412:	7c9c                	ld	a5,56(s1)
    80002414:	ff279be3          	bne	a5,s2,8000240a <kwait+0x9a>
        acquire(&pp->lock);
    80002418:	8526                	mv	a0,s1
    8000241a:	f52fe0ef          	jal	ra,80000b6c <acquire>
        if(pp->state == ZOMBIE){
    8000241e:	4c9c                	lw	a5,24(s1)
    80002420:	f9478fe3          	beq	a5,s4,800023be <kwait+0x4e>
        release(&pp->lock);
    80002424:	8526                	mv	a0,s1
    80002426:	fdefe0ef          	jal	ra,80000c04 <release>
        havekids = 1;
    8000242a:	8756                	mv	a4,s5
    8000242c:	bff9                	j	8000240a <kwait+0x9a>
    if(!havekids || killed(p)){
    8000242e:	c709                	beqz	a4,80002438 <kwait+0xc8>
    80002430:	854a                	mv	a0,s2
    80002432:	f15ff0ef          	jal	ra,80002346 <killed>
    80002436:	c50d                	beqz	a0,80002460 <kwait+0xf0>
      release(&wait_lock);
    80002438:	0000e517          	auipc	a0,0xe
    8000243c:	8d850513          	addi	a0,a0,-1832 # 8000fd10 <wait_lock>
    80002440:	fc4fe0ef          	jal	ra,80000c04 <release>
      return -1;
    80002444:	59fd                	li	s3,-1
}
    80002446:	854e                	mv	a0,s3
    80002448:	60a6                	ld	ra,72(sp)
    8000244a:	6406                	ld	s0,64(sp)
    8000244c:	74e2                	ld	s1,56(sp)
    8000244e:	7942                	ld	s2,48(sp)
    80002450:	79a2                	ld	s3,40(sp)
    80002452:	7a02                	ld	s4,32(sp)
    80002454:	6ae2                	ld	s5,24(sp)
    80002456:	6b42                	ld	s6,16(sp)
    80002458:	6ba2                	ld	s7,8(sp)
    8000245a:	6c02                	ld	s8,0(sp)
    8000245c:	6161                	addi	sp,sp,80
    8000245e:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002460:	85e2                	mv	a1,s8
    80002462:	854a                	mv	a0,s2
    80002464:	cabff0ef          	jal	ra,8000210e <sleep>
    havekids = 0;
    80002468:	b7a9                	j	800023b2 <kwait+0x42>

000000008000246a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000246a:	7179                	addi	sp,sp,-48
    8000246c:	f406                	sd	ra,40(sp)
    8000246e:	f022                	sd	s0,32(sp)
    80002470:	ec26                	sd	s1,24(sp)
    80002472:	e84a                	sd	s2,16(sp)
    80002474:	e44e                	sd	s3,8(sp)
    80002476:	e052                	sd	s4,0(sp)
    80002478:	1800                	addi	s0,sp,48
    8000247a:	84aa                	mv	s1,a0
    8000247c:	892e                	mv	s2,a1
    8000247e:	89b2                	mv	s3,a2
    80002480:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002482:	e7aff0ef          	jal	ra,80001afc <myproc>
  if(user_dst){
    80002486:	cc99                	beqz	s1,800024a4 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002488:	86d2                	mv	a3,s4
    8000248a:	864e                	mv	a2,s3
    8000248c:	85ca                	mv	a1,s2
    8000248e:	6928                	ld	a0,80(a0)
    80002490:	bbaff0ef          	jal	ra,8000184a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002494:	70a2                	ld	ra,40(sp)
    80002496:	7402                	ld	s0,32(sp)
    80002498:	64e2                	ld	s1,24(sp)
    8000249a:	6942                	ld	s2,16(sp)
    8000249c:	69a2                	ld	s3,8(sp)
    8000249e:	6a02                	ld	s4,0(sp)
    800024a0:	6145                	addi	sp,sp,48
    800024a2:	8082                	ret
    memmove((char *)dst, src, len);
    800024a4:	000a061b          	sext.w	a2,s4
    800024a8:	85ce                	mv	a1,s3
    800024aa:	854a                	mv	a0,s2
    800024ac:	ff0fe0ef          	jal	ra,80000c9c <memmove>
    return 0;
    800024b0:	8526                	mv	a0,s1
    800024b2:	b7cd                	j	80002494 <either_copyout+0x2a>

00000000800024b4 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024b4:	7179                	addi	sp,sp,-48
    800024b6:	f406                	sd	ra,40(sp)
    800024b8:	f022                	sd	s0,32(sp)
    800024ba:	ec26                	sd	s1,24(sp)
    800024bc:	e84a                	sd	s2,16(sp)
    800024be:	e44e                	sd	s3,8(sp)
    800024c0:	e052                	sd	s4,0(sp)
    800024c2:	1800                	addi	s0,sp,48
    800024c4:	892a                	mv	s2,a0
    800024c6:	84ae                	mv	s1,a1
    800024c8:	89b2                	mv	s3,a2
    800024ca:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024cc:	e30ff0ef          	jal	ra,80001afc <myproc>
  if(user_src){
    800024d0:	cc99                	beqz	s1,800024ee <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800024d2:	86d2                	mv	a3,s4
    800024d4:	864e                	mv	a2,s3
    800024d6:	85ca                	mv	a1,s2
    800024d8:	6928                	ld	a0,80(a0)
    800024da:	c36ff0ef          	jal	ra,80001910 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024de:	70a2                	ld	ra,40(sp)
    800024e0:	7402                	ld	s0,32(sp)
    800024e2:	64e2                	ld	s1,24(sp)
    800024e4:	6942                	ld	s2,16(sp)
    800024e6:	69a2                	ld	s3,8(sp)
    800024e8:	6a02                	ld	s4,0(sp)
    800024ea:	6145                	addi	sp,sp,48
    800024ec:	8082                	ret
    memmove(dst, (char*)src, len);
    800024ee:	000a061b          	sext.w	a2,s4
    800024f2:	85ce                	mv	a1,s3
    800024f4:	854a                	mv	a0,s2
    800024f6:	fa6fe0ef          	jal	ra,80000c9c <memmove>
    return 0;
    800024fa:	8526                	mv	a0,s1
    800024fc:	b7cd                	j	800024de <either_copyin+0x2a>

00000000800024fe <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800024fe:	715d                	addi	sp,sp,-80
    80002500:	e486                	sd	ra,72(sp)
    80002502:	e0a2                	sd	s0,64(sp)
    80002504:	fc26                	sd	s1,56(sp)
    80002506:	f84a                	sd	s2,48(sp)
    80002508:	f44e                	sd	s3,40(sp)
    8000250a:	f052                	sd	s4,32(sp)
    8000250c:	ec56                	sd	s5,24(sp)
    8000250e:	e85a                	sd	s6,16(sp)
    80002510:	e45e                	sd	s7,8(sp)
    80002512:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002514:	00005517          	auipc	a0,0x5
    80002518:	cf450513          	addi	a0,a0,-780 # 80007208 <digits+0x1d0>
    8000251c:	fa9fd0ef          	jal	ra,800004c4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002520:	0000e497          	auipc	s1,0xe
    80002524:	d6048493          	addi	s1,s1,-672 # 80010280 <proc+0x158>
    80002528:	00014917          	auipc	s2,0x14
    8000252c:	55890913          	addi	s2,s2,1368 # 80016a80 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002530:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002532:	00005997          	auipc	s3,0x5
    80002536:	fae98993          	addi	s3,s3,-82 # 800074e0 <digits+0x4a8>
    printf("%d %s %s", p->pid, state, p->name);
    8000253a:	00005a97          	auipc	s5,0x5
    8000253e:	faea8a93          	addi	s5,s5,-82 # 800074e8 <digits+0x4b0>
    printf("\n");
    80002542:	00005a17          	auipc	s4,0x5
    80002546:	cc6a0a13          	addi	s4,s4,-826 # 80007208 <digits+0x1d0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000254a:	00005b97          	auipc	s7,0x5
    8000254e:	fdeb8b93          	addi	s7,s7,-34 # 80007528 <states.0>
    80002552:	a829                	j	8000256c <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002554:	ed86a583          	lw	a1,-296(a3)
    80002558:	8556                	mv	a0,s5
    8000255a:	f6bfd0ef          	jal	ra,800004c4 <printf>
    printf("\n");
    8000255e:	8552                	mv	a0,s4
    80002560:	f65fd0ef          	jal	ra,800004c4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002564:	1a048493          	addi	s1,s1,416
    80002568:	03248163          	beq	s1,s2,8000258a <procdump+0x8c>
    if(p->state == UNUSED)
    8000256c:	86a6                	mv	a3,s1
    8000256e:	ec04a783          	lw	a5,-320(s1)
    80002572:	dbed                	beqz	a5,80002564 <procdump+0x66>
      state = "???";
    80002574:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002576:	fcfb6fe3          	bltu	s6,a5,80002554 <procdump+0x56>
    8000257a:	1782                	slli	a5,a5,0x20
    8000257c:	9381                	srli	a5,a5,0x20
    8000257e:	078e                	slli	a5,a5,0x3
    80002580:	97de                	add	a5,a5,s7
    80002582:	6390                	ld	a2,0(a5)
    80002584:	fa61                	bnez	a2,80002554 <procdump+0x56>
      state = "???";
    80002586:	864e                	mv	a2,s3
    80002588:	b7f1                	j	80002554 <procdump+0x56>
  }
}
    8000258a:	60a6                	ld	ra,72(sp)
    8000258c:	6406                	ld	s0,64(sp)
    8000258e:	74e2                	ld	s1,56(sp)
    80002590:	7942                	ld	s2,48(sp)
    80002592:	79a2                	ld	s3,40(sp)
    80002594:	7a02                	ld	s4,32(sp)
    80002596:	6ae2                	ld	s5,24(sp)
    80002598:	6b42                	ld	s6,16(sp)
    8000259a:	6ba2                	ld	s7,8(sp)
    8000259c:	6161                	addi	sp,sp,80
    8000259e:	8082                	ret

00000000800025a0 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800025a0:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800025a4:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800025a8:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800025aa:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800025ac:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800025b0:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800025b4:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800025b8:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800025bc:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800025c0:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800025c4:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800025c8:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800025cc:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800025d0:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800025d4:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800025d8:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800025dc:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800025de:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800025e0:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800025e4:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800025e8:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800025ec:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800025f0:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800025f4:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800025f8:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800025fc:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002600:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002604:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002608:	8082                	ret

000000008000260a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000260a:	1141                	addi	sp,sp,-16
    8000260c:	e406                	sd	ra,8(sp)
    8000260e:	e022                	sd	s0,0(sp)
    80002610:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002612:	00005597          	auipc	a1,0x5
    80002616:	f4658593          	addi	a1,a1,-186 # 80007558 <states.0+0x30>
    8000261a:	00014517          	auipc	a0,0x14
    8000261e:	30e50513          	addi	a0,a0,782 # 80016928 <tickslock>
    80002622:	ccafe0ef          	jal	ra,80000aec <initlock>
}
    80002626:	60a2                	ld	ra,8(sp)
    80002628:	6402                	ld	s0,0(sp)
    8000262a:	0141                	addi	sp,sp,16
    8000262c:	8082                	ret

000000008000262e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000262e:	1141                	addi	sp,sp,-16
    80002630:	e422                	sd	s0,8(sp)
    80002632:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002634:	00003797          	auipc	a5,0x3
    80002638:	ddc78793          	addi	a5,a5,-548 # 80005410 <kernelvec>
    8000263c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002640:	6422                	ld	s0,8(sp)
    80002642:	0141                	addi	sp,sp,16
    80002644:	8082                	ret

0000000080002646 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002646:	1141                	addi	sp,sp,-16
    80002648:	e406                	sd	ra,8(sp)
    8000264a:	e022                	sd	s0,0(sp)
    8000264c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000264e:	caeff0ef          	jal	ra,80001afc <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002652:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002656:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002658:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000265c:	04000737          	lui	a4,0x4000
    80002660:	00004797          	auipc	a5,0x4
    80002664:	9a078793          	addi	a5,a5,-1632 # 80006000 <_trampoline>
    80002668:	00004697          	auipc	a3,0x4
    8000266c:	99868693          	addi	a3,a3,-1640 # 80006000 <_trampoline>
    80002670:	8f95                	sub	a5,a5,a3
    80002672:	177d                	addi	a4,a4,-1
    80002674:	0732                	slli	a4,a4,0xc
    80002676:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002678:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000267c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000267e:	18002773          	csrr	a4,satp
    80002682:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002684:	6d38                	ld	a4,88(a0)
    80002686:	613c                	ld	a5,64(a0)
    80002688:	6685                	lui	a3,0x1
    8000268a:	97b6                	add	a5,a5,a3
    8000268c:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000268e:	6d3c                	ld	a5,88(a0)
    80002690:	00000717          	auipc	a4,0x0
    80002694:	0f470713          	addi	a4,a4,244 # 80002784 <usertrap>
    80002698:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000269a:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000269c:	8712                	mv	a4,tp
    8000269e:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026a0:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026a4:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026a8:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026ac:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026b0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026b2:	6f9c                	ld	a5,24(a5)
    800026b4:	14179073          	csrw	sepc,a5
}
    800026b8:	60a2                	ld	ra,8(sp)
    800026ba:	6402                	ld	s0,0(sp)
    800026bc:	0141                	addi	sp,sp,16
    800026be:	8082                	ret

00000000800026c0 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800026c0:	1101                	addi	sp,sp,-32
    800026c2:	ec06                	sd	ra,24(sp)
    800026c4:	e822                	sd	s0,16(sp)
    800026c6:	e426                	sd	s1,8(sp)
    800026c8:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800026ca:	c06ff0ef          	jal	ra,80001ad0 <cpuid>
    800026ce:	cd19                	beqz	a0,800026ec <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    800026d0:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800026d4:	000f4737          	lui	a4,0xf4
    800026d8:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800026dc:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800026de:	14d79073          	csrw	0x14d,a5
}
    800026e2:	60e2                	ld	ra,24(sp)
    800026e4:	6442                	ld	s0,16(sp)
    800026e6:	64a2                	ld	s1,8(sp)
    800026e8:	6105                	addi	sp,sp,32
    800026ea:	8082                	ret
    acquire(&tickslock);
    800026ec:	00014497          	auipc	s1,0x14
    800026f0:	23c48493          	addi	s1,s1,572 # 80016928 <tickslock>
    800026f4:	8526                	mv	a0,s1
    800026f6:	c76fe0ef          	jal	ra,80000b6c <acquire>
    ticks++;
    800026fa:	00005517          	auipc	a0,0x5
    800026fe:	4fe50513          	addi	a0,a0,1278 # 80007bf8 <ticks>
    80002702:	411c                	lw	a5,0(a0)
    80002704:	2785                	addiw	a5,a5,1
    80002706:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002708:	a53ff0ef          	jal	ra,8000215a <wakeup>
    release(&tickslock);
    8000270c:	8526                	mv	a0,s1
    8000270e:	cf6fe0ef          	jal	ra,80000c04 <release>
    80002712:	bf7d                	j	800026d0 <clockintr+0x10>

0000000080002714 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002714:	1101                	addi	sp,sp,-32
    80002716:	ec06                	sd	ra,24(sp)
    80002718:	e822                	sd	s0,16(sp)
    8000271a:	e426                	sd	s1,8(sp)
    8000271c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000271e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002722:	57fd                	li	a5,-1
    80002724:	17fe                	slli	a5,a5,0x3f
    80002726:	07a5                	addi	a5,a5,9
    80002728:	00f70d63          	beq	a4,a5,80002742 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    8000272c:	57fd                	li	a5,-1
    8000272e:	17fe                	slli	a5,a5,0x3f
    80002730:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002732:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002734:	04f70463          	beq	a4,a5,8000277c <devintr+0x68>
  }
}
    80002738:	60e2                	ld	ra,24(sp)
    8000273a:	6442                	ld	s0,16(sp)
    8000273c:	64a2                	ld	s1,8(sp)
    8000273e:	6105                	addi	sp,sp,32
    80002740:	8082                	ret
    int irq = plic_claim();
    80002742:	577020ef          	jal	ra,800054b8 <plic_claim>
    80002746:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002748:	47a9                	li	a5,10
    8000274a:	02f50363          	beq	a0,a5,80002770 <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    8000274e:	4785                	li	a5,1
    80002750:	02f50363          	beq	a0,a5,80002776 <devintr+0x62>
    return 1;
    80002754:	4505                	li	a0,1
    } else if(irq){
    80002756:	d0ed                	beqz	s1,80002738 <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80002758:	85a6                	mv	a1,s1
    8000275a:	00005517          	auipc	a0,0x5
    8000275e:	e0650513          	addi	a0,a0,-506 # 80007560 <states.0+0x38>
    80002762:	d63fd0ef          	jal	ra,800004c4 <printf>
      plic_complete(irq);
    80002766:	8526                	mv	a0,s1
    80002768:	571020ef          	jal	ra,800054d8 <plic_complete>
    return 1;
    8000276c:	4505                	li	a0,1
    8000276e:	b7e9                	j	80002738 <devintr+0x24>
      uartintr();
    80002770:	9e8fe0ef          	jal	ra,80000958 <uartintr>
    80002774:	bfcd                	j	80002766 <devintr+0x52>
      virtio_disk_intr();
    80002776:	1d2030ef          	jal	ra,80005948 <virtio_disk_intr>
    8000277a:	b7f5                	j	80002766 <devintr+0x52>
    clockintr();
    8000277c:	f45ff0ef          	jal	ra,800026c0 <clockintr>
    return 2;
    80002780:	4509                	li	a0,2
    80002782:	bf5d                	j	80002738 <devintr+0x24>

0000000080002784 <usertrap>:
{
    80002784:	1101                	addi	sp,sp,-32
    80002786:	ec06                	sd	ra,24(sp)
    80002788:	e822                	sd	s0,16(sp)
    8000278a:	e426                	sd	s1,8(sp)
    8000278c:	e04a                	sd	s2,0(sp)
    8000278e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002790:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002794:	1007f793          	andi	a5,a5,256
    80002798:	efad                	bnez	a5,80002812 <usertrap+0x8e>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000279a:	00003797          	auipc	a5,0x3
    8000279e:	c7678793          	addi	a5,a5,-906 # 80005410 <kernelvec>
    800027a2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800027a6:	b56ff0ef          	jal	ra,80001afc <myproc>
    800027aa:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800027ac:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027ae:	14102773          	csrr	a4,sepc
    800027b2:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027b4:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800027b8:	47a1                	li	a5,8
    800027ba:	06f70263          	beq	a4,a5,8000281e <usertrap+0x9a>
  } else if((which_dev = devintr()) != 0){
    800027be:	f57ff0ef          	jal	ra,80002714 <devintr>
    800027c2:	892a                	mv	s2,a0
    800027c4:	ed4d                	bnez	a0,8000287e <usertrap+0xfa>
    800027c6:	14202773          	csrr	a4,scause
  } else if((r_scause() == 12 || r_scause() == 13 || r_scause() == 15) &&
    800027ca:	47b1                	li	a5,12
    800027cc:	08f70d63          	beq	a4,a5,80002866 <usertrap+0xe2>
    800027d0:	14202773          	csrr	a4,scause
    800027d4:	47b5                	li	a5,13
    800027d6:	08f70863          	beq	a4,a5,80002866 <usertrap+0xe2>
    800027da:	14202773          	csrr	a4,scause
    800027de:	47bd                	li	a5,15
    800027e0:	08f70363          	beq	a4,a5,80002866 <usertrap+0xe2>
    800027e4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800027e8:	5890                	lw	a2,48(s1)
    800027ea:	00005517          	auipc	a0,0x5
    800027ee:	db650513          	addi	a0,a0,-586 # 800075a0 <states.0+0x78>
    800027f2:	cd3fd0ef          	jal	ra,800004c4 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027f6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800027fa:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800027fe:	00005517          	auipc	a0,0x5
    80002802:	dd250513          	addi	a0,a0,-558 # 800075d0 <states.0+0xa8>
    80002806:	cbffd0ef          	jal	ra,800004c4 <printf>
    setkilled(p);
    8000280a:	8526                	mv	a0,s1
    8000280c:	b17ff0ef          	jal	ra,80002322 <setkilled>
    80002810:	a035                	j	8000283c <usertrap+0xb8>
    panic("usertrap: not from user mode");
    80002812:	00005517          	auipc	a0,0x5
    80002816:	d6e50513          	addi	a0,a0,-658 # 80007580 <states.0+0x58>
    8000281a:	f71fd0ef          	jal	ra,8000078a <panic>
    if(killed(p))
    8000281e:	b29ff0ef          	jal	ra,80002346 <killed>
    80002822:	ed15                	bnez	a0,8000285e <usertrap+0xda>
    p->trapframe->epc += 4;
    80002824:	6cb8                	ld	a4,88(s1)
    80002826:	6f1c                	ld	a5,24(a4)
    80002828:	0791                	addi	a5,a5,4
    8000282a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000282c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002830:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002834:	10079073          	csrw	sstatus,a5
    syscall();
    80002838:	246000ef          	jal	ra,80002a7e <syscall>
  if(killed(p))
    8000283c:	8526                	mv	a0,s1
    8000283e:	b09ff0ef          	jal	ra,80002346 <killed>
    80002842:	e139                	bnez	a0,80002888 <usertrap+0x104>
  prepare_return();
    80002844:	e03ff0ef          	jal	ra,80002646 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002848:	68a8                	ld	a0,80(s1)
    8000284a:	8131                	srli	a0,a0,0xc
    8000284c:	57fd                	li	a5,-1
    8000284e:	17fe                	slli	a5,a5,0x3f
    80002850:	8d5d                	or	a0,a0,a5
}
    80002852:	60e2                	ld	ra,24(sp)
    80002854:	6442                	ld	s0,16(sp)
    80002856:	64a2                	ld	s1,8(sp)
    80002858:	6902                	ld	s2,0(sp)
    8000285a:	6105                	addi	sp,sp,32
    8000285c:	8082                	ret
      kexit(-1);
    8000285e:	557d                	li	a0,-1
    80002860:	9bbff0ef          	jal	ra,8000221a <kexit>
    80002864:	b7c1                	j	80002824 <usertrap+0xa0>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002866:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000286a:	14202673          	csrr	a2,scause
          vmfault(p->pagetable, r_stval(), (r_scause() == 15)? 1 : 0) != 0) {
    8000286e:	1645                	addi	a2,a2,-15
    80002870:	00163613          	seqz	a2,a2
    80002874:	68a8                	ld	a0,80(s1)
    80002876:	c6bfe0ef          	jal	ra,800014e0 <vmfault>
  } else if((r_scause() == 12 || r_scause() == 13 || r_scause() == 15) &&
    8000287a:	f169                	bnez	a0,8000283c <usertrap+0xb8>
    8000287c:	b7a5                	j	800027e4 <usertrap+0x60>
  if(killed(p))
    8000287e:	8526                	mv	a0,s1
    80002880:	ac7ff0ef          	jal	ra,80002346 <killed>
    80002884:	c511                	beqz	a0,80002890 <usertrap+0x10c>
    80002886:	a011                	j	8000288a <usertrap+0x106>
    80002888:	4901                	li	s2,0
    kexit(-1);
    8000288a:	557d                	li	a0,-1
    8000288c:	98fff0ef          	jal	ra,8000221a <kexit>
  if(which_dev == 2)
    80002890:	4789                	li	a5,2
    80002892:	faf919e3          	bne	s2,a5,80002844 <usertrap+0xc0>
    yield();
    80002896:	84dff0ef          	jal	ra,800020e2 <yield>
    8000289a:	b76d                	j	80002844 <usertrap+0xc0>

000000008000289c <kerneltrap>:
{
    8000289c:	7179                	addi	sp,sp,-48
    8000289e:	f406                	sd	ra,40(sp)
    800028a0:	f022                	sd	s0,32(sp)
    800028a2:	ec26                	sd	s1,24(sp)
    800028a4:	e84a                	sd	s2,16(sp)
    800028a6:	e44e                	sd	s3,8(sp)
    800028a8:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028aa:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028ae:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028b2:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800028b6:	1004f793          	andi	a5,s1,256
    800028ba:	c795                	beqz	a5,800028e6 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028bc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800028c0:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800028c2:	eb85                	bnez	a5,800028f2 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    800028c4:	e51ff0ef          	jal	ra,80002714 <devintr>
    800028c8:	c91d                	beqz	a0,800028fe <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    800028ca:	4789                	li	a5,2
    800028cc:	04f50a63          	beq	a0,a5,80002920 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028d0:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028d4:	10049073          	csrw	sstatus,s1
}
    800028d8:	70a2                	ld	ra,40(sp)
    800028da:	7402                	ld	s0,32(sp)
    800028dc:	64e2                	ld	s1,24(sp)
    800028de:	6942                	ld	s2,16(sp)
    800028e0:	69a2                	ld	s3,8(sp)
    800028e2:	6145                	addi	sp,sp,48
    800028e4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800028e6:	00005517          	auipc	a0,0x5
    800028ea:	d1250513          	addi	a0,a0,-750 # 800075f8 <states.0+0xd0>
    800028ee:	e9dfd0ef          	jal	ra,8000078a <panic>
    panic("kerneltrap: interrupts enabled");
    800028f2:	00005517          	auipc	a0,0x5
    800028f6:	d2e50513          	addi	a0,a0,-722 # 80007620 <states.0+0xf8>
    800028fa:	e91fd0ef          	jal	ra,8000078a <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028fe:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002902:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002906:	85ce                	mv	a1,s3
    80002908:	00005517          	auipc	a0,0x5
    8000290c:	d3850513          	addi	a0,a0,-712 # 80007640 <states.0+0x118>
    80002910:	bb5fd0ef          	jal	ra,800004c4 <printf>
    panic("kerneltrap");
    80002914:	00005517          	auipc	a0,0x5
    80002918:	d5450513          	addi	a0,a0,-684 # 80007668 <states.0+0x140>
    8000291c:	e6ffd0ef          	jal	ra,8000078a <panic>
  if(which_dev == 2 && myproc() != 0)
    80002920:	9dcff0ef          	jal	ra,80001afc <myproc>
    80002924:	d555                	beqz	a0,800028d0 <kerneltrap+0x34>
    yield();
    80002926:	fbcff0ef          	jal	ra,800020e2 <yield>
    8000292a:	b75d                	j	800028d0 <kerneltrap+0x34>

000000008000292c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000292c:	1101                	addi	sp,sp,-32
    8000292e:	ec06                	sd	ra,24(sp)
    80002930:	e822                	sd	s0,16(sp)
    80002932:	e426                	sd	s1,8(sp)
    80002934:	1000                	addi	s0,sp,32
    80002936:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002938:	9c4ff0ef          	jal	ra,80001afc <myproc>
  switch (n) {
    8000293c:	4795                	li	a5,5
    8000293e:	0497e163          	bltu	a5,s1,80002980 <argraw+0x54>
    80002942:	048a                	slli	s1,s1,0x2
    80002944:	00005717          	auipc	a4,0x5
    80002948:	d5c70713          	addi	a4,a4,-676 # 800076a0 <states.0+0x178>
    8000294c:	94ba                	add	s1,s1,a4
    8000294e:	409c                	lw	a5,0(s1)
    80002950:	97ba                	add	a5,a5,a4
    80002952:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002954:	6d3c                	ld	a5,88(a0)
    80002956:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002958:	60e2                	ld	ra,24(sp)
    8000295a:	6442                	ld	s0,16(sp)
    8000295c:	64a2                	ld	s1,8(sp)
    8000295e:	6105                	addi	sp,sp,32
    80002960:	8082                	ret
    return p->trapframe->a1;
    80002962:	6d3c                	ld	a5,88(a0)
    80002964:	7fa8                	ld	a0,120(a5)
    80002966:	bfcd                	j	80002958 <argraw+0x2c>
    return p->trapframe->a2;
    80002968:	6d3c                	ld	a5,88(a0)
    8000296a:	63c8                	ld	a0,128(a5)
    8000296c:	b7f5                	j	80002958 <argraw+0x2c>
    return p->trapframe->a3;
    8000296e:	6d3c                	ld	a5,88(a0)
    80002970:	67c8                	ld	a0,136(a5)
    80002972:	b7dd                	j	80002958 <argraw+0x2c>
    return p->trapframe->a4;
    80002974:	6d3c                	ld	a5,88(a0)
    80002976:	6bc8                	ld	a0,144(a5)
    80002978:	b7c5                	j	80002958 <argraw+0x2c>
    return p->trapframe->a5;
    8000297a:	6d3c                	ld	a5,88(a0)
    8000297c:	6fc8                	ld	a0,152(a5)
    8000297e:	bfe9                	j	80002958 <argraw+0x2c>
  panic("argraw");
    80002980:	00005517          	auipc	a0,0x5
    80002984:	cf850513          	addi	a0,a0,-776 # 80007678 <states.0+0x150>
    80002988:	e03fd0ef          	jal	ra,8000078a <panic>

000000008000298c <fetchaddr>:
{
    8000298c:	1101                	addi	sp,sp,-32
    8000298e:	ec06                	sd	ra,24(sp)
    80002990:	e822                	sd	s0,16(sp)
    80002992:	e426                	sd	s1,8(sp)
    80002994:	e04a                	sd	s2,0(sp)
    80002996:	1000                	addi	s0,sp,32
    80002998:	84aa                	mv	s1,a0
    8000299a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000299c:	960ff0ef          	jal	ra,80001afc <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800029a0:	653c                	ld	a5,72(a0)
    800029a2:	02f4f663          	bgeu	s1,a5,800029ce <fetchaddr+0x42>
    800029a6:	00848713          	addi	a4,s1,8
    800029aa:	02e7e463          	bltu	a5,a4,800029d2 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800029ae:	46a1                	li	a3,8
    800029b0:	8626                	mv	a2,s1
    800029b2:	85ca                	mv	a1,s2
    800029b4:	6928                	ld	a0,80(a0)
    800029b6:	f5bfe0ef          	jal	ra,80001910 <copyin>
    800029ba:	00a03533          	snez	a0,a0
    800029be:	40a00533          	neg	a0,a0
}
    800029c2:	60e2                	ld	ra,24(sp)
    800029c4:	6442                	ld	s0,16(sp)
    800029c6:	64a2                	ld	s1,8(sp)
    800029c8:	6902                	ld	s2,0(sp)
    800029ca:	6105                	addi	sp,sp,32
    800029cc:	8082                	ret
    return -1;
    800029ce:	557d                	li	a0,-1
    800029d0:	bfcd                	j	800029c2 <fetchaddr+0x36>
    800029d2:	557d                	li	a0,-1
    800029d4:	b7fd                	j	800029c2 <fetchaddr+0x36>

00000000800029d6 <fetchstr>:
{
    800029d6:	7179                	addi	sp,sp,-48
    800029d8:	f406                	sd	ra,40(sp)
    800029da:	f022                	sd	s0,32(sp)
    800029dc:	ec26                	sd	s1,24(sp)
    800029de:	e84a                	sd	s2,16(sp)
    800029e0:	e44e                	sd	s3,8(sp)
    800029e2:	1800                	addi	s0,sp,48
    800029e4:	892a                	mv	s2,a0
    800029e6:	84ae                	mv	s1,a1
    800029e8:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800029ea:	912ff0ef          	jal	ra,80001afc <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800029ee:	86ce                	mv	a3,s3
    800029f0:	864a                	mv	a2,s2
    800029f2:	85a6                	mv	a1,s1
    800029f4:	6928                	ld	a0,80(a0)
    800029f6:	a1bfe0ef          	jal	ra,80001410 <copyinstr>
    800029fa:	00054c63          	bltz	a0,80002a12 <fetchstr+0x3c>
  return strlen(buf);
    800029fe:	8526                	mv	a0,s1
    80002a00:	bb8fe0ef          	jal	ra,80000db8 <strlen>
}
    80002a04:	70a2                	ld	ra,40(sp)
    80002a06:	7402                	ld	s0,32(sp)
    80002a08:	64e2                	ld	s1,24(sp)
    80002a0a:	6942                	ld	s2,16(sp)
    80002a0c:	69a2                	ld	s3,8(sp)
    80002a0e:	6145                	addi	sp,sp,48
    80002a10:	8082                	ret
    return -1;
    80002a12:	557d                	li	a0,-1
    80002a14:	bfc5                	j	80002a04 <fetchstr+0x2e>

0000000080002a16 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002a16:	1101                	addi	sp,sp,-32
    80002a18:	ec06                	sd	ra,24(sp)
    80002a1a:	e822                	sd	s0,16(sp)
    80002a1c:	e426                	sd	s1,8(sp)
    80002a1e:	1000                	addi	s0,sp,32
    80002a20:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a22:	f0bff0ef          	jal	ra,8000292c <argraw>
    80002a26:	c088                	sw	a0,0(s1)
}
    80002a28:	60e2                	ld	ra,24(sp)
    80002a2a:	6442                	ld	s0,16(sp)
    80002a2c:	64a2                	ld	s1,8(sp)
    80002a2e:	6105                	addi	sp,sp,32
    80002a30:	8082                	ret

0000000080002a32 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002a32:	1101                	addi	sp,sp,-32
    80002a34:	ec06                	sd	ra,24(sp)
    80002a36:	e822                	sd	s0,16(sp)
    80002a38:	e426                	sd	s1,8(sp)
    80002a3a:	1000                	addi	s0,sp,32
    80002a3c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a3e:	eefff0ef          	jal	ra,8000292c <argraw>
    80002a42:	e088                	sd	a0,0(s1)
}
    80002a44:	60e2                	ld	ra,24(sp)
    80002a46:	6442                	ld	s0,16(sp)
    80002a48:	64a2                	ld	s1,8(sp)
    80002a4a:	6105                	addi	sp,sp,32
    80002a4c:	8082                	ret

0000000080002a4e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002a4e:	7179                	addi	sp,sp,-48
    80002a50:	f406                	sd	ra,40(sp)
    80002a52:	f022                	sd	s0,32(sp)
    80002a54:	ec26                	sd	s1,24(sp)
    80002a56:	e84a                	sd	s2,16(sp)
    80002a58:	1800                	addi	s0,sp,48
    80002a5a:	84ae                	mv	s1,a1
    80002a5c:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002a5e:	fd840593          	addi	a1,s0,-40
    80002a62:	fd1ff0ef          	jal	ra,80002a32 <argaddr>
  return fetchstr(addr, buf, max);
    80002a66:	864a                	mv	a2,s2
    80002a68:	85a6                	mv	a1,s1
    80002a6a:	fd843503          	ld	a0,-40(s0)
    80002a6e:	f69ff0ef          	jal	ra,800029d6 <fetchstr>
}
    80002a72:	70a2                	ld	ra,40(sp)
    80002a74:	7402                	ld	s0,32(sp)
    80002a76:	64e2                	ld	s1,24(sp)
    80002a78:	6942                	ld	s2,16(sp)
    80002a7a:	6145                	addi	sp,sp,48
    80002a7c:	8082                	ret

0000000080002a7e <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002a7e:	1101                	addi	sp,sp,-32
    80002a80:	ec06                	sd	ra,24(sp)
    80002a82:	e822                	sd	s0,16(sp)
    80002a84:	e426                	sd	s1,8(sp)
    80002a86:	e04a                	sd	s2,0(sp)
    80002a88:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002a8a:	872ff0ef          	jal	ra,80001afc <myproc>
    80002a8e:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002a90:	05853903          	ld	s2,88(a0)
    80002a94:	0a893783          	ld	a5,168(s2)
    80002a98:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002a9c:	37fd                	addiw	a5,a5,-1
    80002a9e:	4751                	li	a4,20
    80002aa0:	00f76f63          	bltu	a4,a5,80002abe <syscall+0x40>
    80002aa4:	00369713          	slli	a4,a3,0x3
    80002aa8:	00005797          	auipc	a5,0x5
    80002aac:	c1078793          	addi	a5,a5,-1008 # 800076b8 <syscalls>
    80002ab0:	97ba                	add	a5,a5,a4
    80002ab2:	639c                	ld	a5,0(a5)
    80002ab4:	c789                	beqz	a5,80002abe <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002ab6:	9782                	jalr	a5
    80002ab8:	06a93823          	sd	a0,112(s2)
    80002abc:	a829                	j	80002ad6 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002abe:	15848613          	addi	a2,s1,344
    80002ac2:	588c                	lw	a1,48(s1)
    80002ac4:	00005517          	auipc	a0,0x5
    80002ac8:	bbc50513          	addi	a0,a0,-1092 # 80007680 <states.0+0x158>
    80002acc:	9f9fd0ef          	jal	ra,800004c4 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002ad0:	6cbc                	ld	a5,88(s1)
    80002ad2:	577d                	li	a4,-1
    80002ad4:	fbb8                	sd	a4,112(a5)
  }
}
    80002ad6:	60e2                	ld	ra,24(sp)
    80002ad8:	6442                	ld	s0,16(sp)
    80002ada:	64a2                	ld	s1,8(sp)
    80002adc:	6902                	ld	s2,0(sp)
    80002ade:	6105                	addi	sp,sp,32
    80002ae0:	8082                	ret

0000000080002ae2 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002ae2:	1101                	addi	sp,sp,-32
    80002ae4:	ec06                	sd	ra,24(sp)
    80002ae6:	e822                	sd	s0,16(sp)
    80002ae8:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002aea:	fec40593          	addi	a1,s0,-20
    80002aee:	4501                	li	a0,0
    80002af0:	f27ff0ef          	jal	ra,80002a16 <argint>
  kexit(n);
    80002af4:	fec42503          	lw	a0,-20(s0)
    80002af8:	f22ff0ef          	jal	ra,8000221a <kexit>
  return 0;  // not reached
}
    80002afc:	4501                	li	a0,0
    80002afe:	60e2                	ld	ra,24(sp)
    80002b00:	6442                	ld	s0,16(sp)
    80002b02:	6105                	addi	sp,sp,32
    80002b04:	8082                	ret

0000000080002b06 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002b06:	1141                	addi	sp,sp,-16
    80002b08:	e406                	sd	ra,8(sp)
    80002b0a:	e022                	sd	s0,0(sp)
    80002b0c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002b0e:	feffe0ef          	jal	ra,80001afc <myproc>
}
    80002b12:	5908                	lw	a0,48(a0)
    80002b14:	60a2                	ld	ra,8(sp)
    80002b16:	6402                	ld	s0,0(sp)
    80002b18:	0141                	addi	sp,sp,16
    80002b1a:	8082                	ret

0000000080002b1c <sys_fork>:

uint64
sys_fork(void)
{
    80002b1c:	1141                	addi	sp,sp,-16
    80002b1e:	e406                	sd	ra,8(sp)
    80002b20:	e022                	sd	s0,0(sp)
    80002b22:	0800                	addi	s0,sp,16
  return kfork();
    80002b24:	b46ff0ef          	jal	ra,80001e6a <kfork>
}
    80002b28:	60a2                	ld	ra,8(sp)
    80002b2a:	6402                	ld	s0,0(sp)
    80002b2c:	0141                	addi	sp,sp,16
    80002b2e:	8082                	ret

0000000080002b30 <sys_wait>:

uint64
sys_wait(void)
{
    80002b30:	1101                	addi	sp,sp,-32
    80002b32:	ec06                	sd	ra,24(sp)
    80002b34:	e822                	sd	s0,16(sp)
    80002b36:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002b38:	fe840593          	addi	a1,s0,-24
    80002b3c:	4501                	li	a0,0
    80002b3e:	ef5ff0ef          	jal	ra,80002a32 <argaddr>
  return kwait(p);
    80002b42:	fe843503          	ld	a0,-24(s0)
    80002b46:	82bff0ef          	jal	ra,80002370 <kwait>
}
    80002b4a:	60e2                	ld	ra,24(sp)
    80002b4c:	6442                	ld	s0,16(sp)
    80002b4e:	6105                	addi	sp,sp,32
    80002b50:	8082                	ret

0000000080002b52 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002b52:	7179                	addi	sp,sp,-48
    80002b54:	f406                	sd	ra,40(sp)
    80002b56:	f022                	sd	s0,32(sp)
    80002b58:	ec26                	sd	s1,24(sp)
    80002b5a:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002b5c:	fd840593          	addi	a1,s0,-40
    80002b60:	4501                	li	a0,0
    80002b62:	eb5ff0ef          	jal	ra,80002a16 <argint>
  argint(1, &t);
    80002b66:	fdc40593          	addi	a1,s0,-36
    80002b6a:	4505                	li	a0,1
    80002b6c:	eabff0ef          	jal	ra,80002a16 <argint>
  addr = myproc()->sz;
    80002b70:	f8dfe0ef          	jal	ra,80001afc <myproc>
    80002b74:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002b76:	fdc42703          	lw	a4,-36(s0)
    80002b7a:	4785                	li	a5,1
    80002b7c:	02f70163          	beq	a4,a5,80002b9e <sys_sbrk+0x4c>
    80002b80:	fd842783          	lw	a5,-40(s0)
    80002b84:	0007cd63          	bltz	a5,80002b9e <sys_sbrk+0x4c>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002b88:	97a6                	add	a5,a5,s1
    80002b8a:	0297e863          	bltu	a5,s1,80002bba <sys_sbrk+0x68>
      return -1;
    myproc()->sz += n;
    80002b8e:	f6ffe0ef          	jal	ra,80001afc <myproc>
    80002b92:	fd842703          	lw	a4,-40(s0)
    80002b96:	653c                	ld	a5,72(a0)
    80002b98:	97ba                	add	a5,a5,a4
    80002b9a:	e53c                	sd	a5,72(a0)
    80002b9c:	a039                	j	80002baa <sys_sbrk+0x58>
    if(growproc(n) < 0) {
    80002b9e:	fd842503          	lw	a0,-40(s0)
    80002ba2:	a78ff0ef          	jal	ra,80001e1a <growproc>
    80002ba6:	00054863          	bltz	a0,80002bb6 <sys_sbrk+0x64>
  }
  return addr;
}
    80002baa:	8526                	mv	a0,s1
    80002bac:	70a2                	ld	ra,40(sp)
    80002bae:	7402                	ld	s0,32(sp)
    80002bb0:	64e2                	ld	s1,24(sp)
    80002bb2:	6145                	addi	sp,sp,48
    80002bb4:	8082                	ret
      return -1;
    80002bb6:	54fd                	li	s1,-1
    80002bb8:	bfcd                	j	80002baa <sys_sbrk+0x58>
      return -1;
    80002bba:	54fd                	li	s1,-1
    80002bbc:	b7fd                	j	80002baa <sys_sbrk+0x58>

0000000080002bbe <sys_pause>:

uint64
sys_pause(void)
{
    80002bbe:	7139                	addi	sp,sp,-64
    80002bc0:	fc06                	sd	ra,56(sp)
    80002bc2:	f822                	sd	s0,48(sp)
    80002bc4:	f426                	sd	s1,40(sp)
    80002bc6:	f04a                	sd	s2,32(sp)
    80002bc8:	ec4e                	sd	s3,24(sp)
    80002bca:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002bcc:	fcc40593          	addi	a1,s0,-52
    80002bd0:	4501                	li	a0,0
    80002bd2:	e45ff0ef          	jal	ra,80002a16 <argint>
  if(n < 0)
    80002bd6:	fcc42783          	lw	a5,-52(s0)
    80002bda:	0607c563          	bltz	a5,80002c44 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002bde:	00014517          	auipc	a0,0x14
    80002be2:	d4a50513          	addi	a0,a0,-694 # 80016928 <tickslock>
    80002be6:	f87fd0ef          	jal	ra,80000b6c <acquire>
  ticks0 = ticks;
    80002bea:	00005917          	auipc	s2,0x5
    80002bee:	00e92903          	lw	s2,14(s2) # 80007bf8 <ticks>
  while(ticks - ticks0 < n){
    80002bf2:	fcc42783          	lw	a5,-52(s0)
    80002bf6:	cb8d                	beqz	a5,80002c28 <sys_pause+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002bf8:	00014997          	auipc	s3,0x14
    80002bfc:	d3098993          	addi	s3,s3,-720 # 80016928 <tickslock>
    80002c00:	00005497          	auipc	s1,0x5
    80002c04:	ff848493          	addi	s1,s1,-8 # 80007bf8 <ticks>
    if(killed(myproc())){
    80002c08:	ef5fe0ef          	jal	ra,80001afc <myproc>
    80002c0c:	f3aff0ef          	jal	ra,80002346 <killed>
    80002c10:	ed0d                	bnez	a0,80002c4a <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002c12:	85ce                	mv	a1,s3
    80002c14:	8526                	mv	a0,s1
    80002c16:	cf8ff0ef          	jal	ra,8000210e <sleep>
  while(ticks - ticks0 < n){
    80002c1a:	409c                	lw	a5,0(s1)
    80002c1c:	412787bb          	subw	a5,a5,s2
    80002c20:	fcc42703          	lw	a4,-52(s0)
    80002c24:	fee7e2e3          	bltu	a5,a4,80002c08 <sys_pause+0x4a>
  }
  release(&tickslock);
    80002c28:	00014517          	auipc	a0,0x14
    80002c2c:	d0050513          	addi	a0,a0,-768 # 80016928 <tickslock>
    80002c30:	fd5fd0ef          	jal	ra,80000c04 <release>
  return 0;
    80002c34:	4501                	li	a0,0
}
    80002c36:	70e2                	ld	ra,56(sp)
    80002c38:	7442                	ld	s0,48(sp)
    80002c3a:	74a2                	ld	s1,40(sp)
    80002c3c:	7902                	ld	s2,32(sp)
    80002c3e:	69e2                	ld	s3,24(sp)
    80002c40:	6121                	addi	sp,sp,64
    80002c42:	8082                	ret
    n = 0;
    80002c44:	fc042623          	sw	zero,-52(s0)
    80002c48:	bf59                	j	80002bde <sys_pause+0x20>
      release(&tickslock);
    80002c4a:	00014517          	auipc	a0,0x14
    80002c4e:	cde50513          	addi	a0,a0,-802 # 80016928 <tickslock>
    80002c52:	fb3fd0ef          	jal	ra,80000c04 <release>
      return -1;
    80002c56:	557d                	li	a0,-1
    80002c58:	bff9                	j	80002c36 <sys_pause+0x78>

0000000080002c5a <sys_kill>:

uint64
sys_kill(void)
{
    80002c5a:	1101                	addi	sp,sp,-32
    80002c5c:	ec06                	sd	ra,24(sp)
    80002c5e:	e822                	sd	s0,16(sp)
    80002c60:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002c62:	fec40593          	addi	a1,s0,-20
    80002c66:	4501                	li	a0,0
    80002c68:	dafff0ef          	jal	ra,80002a16 <argint>
  return kkill(pid);
    80002c6c:	fec42503          	lw	a0,-20(s0)
    80002c70:	e4cff0ef          	jal	ra,800022bc <kkill>
}
    80002c74:	60e2                	ld	ra,24(sp)
    80002c76:	6442                	ld	s0,16(sp)
    80002c78:	6105                	addi	sp,sp,32
    80002c7a:	8082                	ret

0000000080002c7c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002c7c:	1101                	addi	sp,sp,-32
    80002c7e:	ec06                	sd	ra,24(sp)
    80002c80:	e822                	sd	s0,16(sp)
    80002c82:	e426                	sd	s1,8(sp)
    80002c84:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002c86:	00014517          	auipc	a0,0x14
    80002c8a:	ca250513          	addi	a0,a0,-862 # 80016928 <tickslock>
    80002c8e:	edffd0ef          	jal	ra,80000b6c <acquire>
  xticks = ticks;
    80002c92:	00005497          	auipc	s1,0x5
    80002c96:	f664a483          	lw	s1,-154(s1) # 80007bf8 <ticks>
  release(&tickslock);
    80002c9a:	00014517          	auipc	a0,0x14
    80002c9e:	c8e50513          	addi	a0,a0,-882 # 80016928 <tickslock>
    80002ca2:	f63fd0ef          	jal	ra,80000c04 <release>
  return xticks;
}
    80002ca6:	02049513          	slli	a0,s1,0x20
    80002caa:	9101                	srli	a0,a0,0x20
    80002cac:	60e2                	ld	ra,24(sp)
    80002cae:	6442                	ld	s0,16(sp)
    80002cb0:	64a2                	ld	s1,8(sp)
    80002cb2:	6105                	addi	sp,sp,32
    80002cb4:	8082                	ret

0000000080002cb6 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002cb6:	7179                	addi	sp,sp,-48
    80002cb8:	f406                	sd	ra,40(sp)
    80002cba:	f022                	sd	s0,32(sp)
    80002cbc:	ec26                	sd	s1,24(sp)
    80002cbe:	e84a                	sd	s2,16(sp)
    80002cc0:	e44e                	sd	s3,8(sp)
    80002cc2:	e052                	sd	s4,0(sp)
    80002cc4:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002cc6:	00005597          	auipc	a1,0x5
    80002cca:	aa258593          	addi	a1,a1,-1374 # 80007768 <syscalls+0xb0>
    80002cce:	00014517          	auipc	a0,0x14
    80002cd2:	c7250513          	addi	a0,a0,-910 # 80016940 <bcache>
    80002cd6:	e17fd0ef          	jal	ra,80000aec <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002cda:	0001c797          	auipc	a5,0x1c
    80002cde:	c6678793          	addi	a5,a5,-922 # 8001e940 <bcache+0x8000>
    80002ce2:	0001c717          	auipc	a4,0x1c
    80002ce6:	ec670713          	addi	a4,a4,-314 # 8001eba8 <bcache+0x8268>
    80002cea:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002cee:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002cf2:	00014497          	auipc	s1,0x14
    80002cf6:	c6648493          	addi	s1,s1,-922 # 80016958 <bcache+0x18>
    b->next = bcache.head.next;
    80002cfa:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002cfc:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002cfe:	00005a17          	auipc	s4,0x5
    80002d02:	a72a0a13          	addi	s4,s4,-1422 # 80007770 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002d06:	2b893783          	ld	a5,696(s2)
    80002d0a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002d0c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002d10:	85d2                	mv	a1,s4
    80002d12:	01048513          	addi	a0,s1,16
    80002d16:	2fe010ef          	jal	ra,80004014 <initsleeplock>
    bcache.head.next->prev = b;
    80002d1a:	2b893783          	ld	a5,696(s2)
    80002d1e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002d20:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002d24:	45848493          	addi	s1,s1,1112
    80002d28:	fd349fe3          	bne	s1,s3,80002d06 <binit+0x50>
  }
}
    80002d2c:	70a2                	ld	ra,40(sp)
    80002d2e:	7402                	ld	s0,32(sp)
    80002d30:	64e2                	ld	s1,24(sp)
    80002d32:	6942                	ld	s2,16(sp)
    80002d34:	69a2                	ld	s3,8(sp)
    80002d36:	6a02                	ld	s4,0(sp)
    80002d38:	6145                	addi	sp,sp,48
    80002d3a:	8082                	ret

0000000080002d3c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002d3c:	7179                	addi	sp,sp,-48
    80002d3e:	f406                	sd	ra,40(sp)
    80002d40:	f022                	sd	s0,32(sp)
    80002d42:	ec26                	sd	s1,24(sp)
    80002d44:	e84a                	sd	s2,16(sp)
    80002d46:	e44e                	sd	s3,8(sp)
    80002d48:	1800                	addi	s0,sp,48
    80002d4a:	892a                	mv	s2,a0
    80002d4c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002d4e:	00014517          	auipc	a0,0x14
    80002d52:	bf250513          	addi	a0,a0,-1038 # 80016940 <bcache>
    80002d56:	e17fd0ef          	jal	ra,80000b6c <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002d5a:	0001c497          	auipc	s1,0x1c
    80002d5e:	e9e4b483          	ld	s1,-354(s1) # 8001ebf8 <bcache+0x82b8>
    80002d62:	0001c797          	auipc	a5,0x1c
    80002d66:	e4678793          	addi	a5,a5,-442 # 8001eba8 <bcache+0x8268>
    80002d6a:	02f48b63          	beq	s1,a5,80002da0 <bread+0x64>
    80002d6e:	873e                	mv	a4,a5
    80002d70:	a021                	j	80002d78 <bread+0x3c>
    80002d72:	68a4                	ld	s1,80(s1)
    80002d74:	02e48663          	beq	s1,a4,80002da0 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002d78:	449c                	lw	a5,8(s1)
    80002d7a:	ff279ce3          	bne	a5,s2,80002d72 <bread+0x36>
    80002d7e:	44dc                	lw	a5,12(s1)
    80002d80:	ff3799e3          	bne	a5,s3,80002d72 <bread+0x36>
      b->refcnt++;
    80002d84:	40bc                	lw	a5,64(s1)
    80002d86:	2785                	addiw	a5,a5,1
    80002d88:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d8a:	00014517          	auipc	a0,0x14
    80002d8e:	bb650513          	addi	a0,a0,-1098 # 80016940 <bcache>
    80002d92:	e73fd0ef          	jal	ra,80000c04 <release>
      acquiresleep(&b->lock);
    80002d96:	01048513          	addi	a0,s1,16
    80002d9a:	2b0010ef          	jal	ra,8000404a <acquiresleep>
      return b;
    80002d9e:	a889                	j	80002df0 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002da0:	0001c497          	auipc	s1,0x1c
    80002da4:	e504b483          	ld	s1,-432(s1) # 8001ebf0 <bcache+0x82b0>
    80002da8:	0001c797          	auipc	a5,0x1c
    80002dac:	e0078793          	addi	a5,a5,-512 # 8001eba8 <bcache+0x8268>
    80002db0:	00f48863          	beq	s1,a5,80002dc0 <bread+0x84>
    80002db4:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002db6:	40bc                	lw	a5,64(s1)
    80002db8:	cb91                	beqz	a5,80002dcc <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002dba:	64a4                	ld	s1,72(s1)
    80002dbc:	fee49de3          	bne	s1,a4,80002db6 <bread+0x7a>
  panic("bget: no buffers");
    80002dc0:	00005517          	auipc	a0,0x5
    80002dc4:	9b850513          	addi	a0,a0,-1608 # 80007778 <syscalls+0xc0>
    80002dc8:	9c3fd0ef          	jal	ra,8000078a <panic>
      b->dev = dev;
    80002dcc:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002dd0:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002dd4:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002dd8:	4785                	li	a5,1
    80002dda:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ddc:	00014517          	auipc	a0,0x14
    80002de0:	b6450513          	addi	a0,a0,-1180 # 80016940 <bcache>
    80002de4:	e21fd0ef          	jal	ra,80000c04 <release>
      acquiresleep(&b->lock);
    80002de8:	01048513          	addi	a0,s1,16
    80002dec:	25e010ef          	jal	ra,8000404a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002df0:	409c                	lw	a5,0(s1)
    80002df2:	cb89                	beqz	a5,80002e04 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002df4:	8526                	mv	a0,s1
    80002df6:	70a2                	ld	ra,40(sp)
    80002df8:	7402                	ld	s0,32(sp)
    80002dfa:	64e2                	ld	s1,24(sp)
    80002dfc:	6942                	ld	s2,16(sp)
    80002dfe:	69a2                	ld	s3,8(sp)
    80002e00:	6145                	addi	sp,sp,48
    80002e02:	8082                	ret
    virtio_disk_rw(b, 0);
    80002e04:	4581                	li	a1,0
    80002e06:	8526                	mv	a0,s1
    80002e08:	125020ef          	jal	ra,8000572c <virtio_disk_rw>
    b->valid = 1;
    80002e0c:	4785                	li	a5,1
    80002e0e:	c09c                	sw	a5,0(s1)
  return b;
    80002e10:	b7d5                	j	80002df4 <bread+0xb8>

0000000080002e12 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002e12:	1101                	addi	sp,sp,-32
    80002e14:	ec06                	sd	ra,24(sp)
    80002e16:	e822                	sd	s0,16(sp)
    80002e18:	e426                	sd	s1,8(sp)
    80002e1a:	1000                	addi	s0,sp,32
    80002e1c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002e1e:	0541                	addi	a0,a0,16
    80002e20:	2a8010ef          	jal	ra,800040c8 <holdingsleep>
    80002e24:	c911                	beqz	a0,80002e38 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002e26:	4585                	li	a1,1
    80002e28:	8526                	mv	a0,s1
    80002e2a:	103020ef          	jal	ra,8000572c <virtio_disk_rw>
}
    80002e2e:	60e2                	ld	ra,24(sp)
    80002e30:	6442                	ld	s0,16(sp)
    80002e32:	64a2                	ld	s1,8(sp)
    80002e34:	6105                	addi	sp,sp,32
    80002e36:	8082                	ret
    panic("bwrite");
    80002e38:	00005517          	auipc	a0,0x5
    80002e3c:	95850513          	addi	a0,a0,-1704 # 80007790 <syscalls+0xd8>
    80002e40:	94bfd0ef          	jal	ra,8000078a <panic>

0000000080002e44 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002e44:	1101                	addi	sp,sp,-32
    80002e46:	ec06                	sd	ra,24(sp)
    80002e48:	e822                	sd	s0,16(sp)
    80002e4a:	e426                	sd	s1,8(sp)
    80002e4c:	e04a                	sd	s2,0(sp)
    80002e4e:	1000                	addi	s0,sp,32
    80002e50:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002e52:	01050913          	addi	s2,a0,16
    80002e56:	854a                	mv	a0,s2
    80002e58:	270010ef          	jal	ra,800040c8 <holdingsleep>
    80002e5c:	c13d                	beqz	a0,80002ec2 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80002e5e:	854a                	mv	a0,s2
    80002e60:	230010ef          	jal	ra,80004090 <releasesleep>

  acquire(&bcache.lock);
    80002e64:	00014517          	auipc	a0,0x14
    80002e68:	adc50513          	addi	a0,a0,-1316 # 80016940 <bcache>
    80002e6c:	d01fd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt--;
    80002e70:	40bc                	lw	a5,64(s1)
    80002e72:	37fd                	addiw	a5,a5,-1
    80002e74:	0007871b          	sext.w	a4,a5
    80002e78:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002e7a:	eb05                	bnez	a4,80002eaa <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002e7c:	68bc                	ld	a5,80(s1)
    80002e7e:	64b8                	ld	a4,72(s1)
    80002e80:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002e82:	64bc                	ld	a5,72(s1)
    80002e84:	68b8                	ld	a4,80(s1)
    80002e86:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002e88:	0001c797          	auipc	a5,0x1c
    80002e8c:	ab878793          	addi	a5,a5,-1352 # 8001e940 <bcache+0x8000>
    80002e90:	2b87b703          	ld	a4,696(a5)
    80002e94:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002e96:	0001c717          	auipc	a4,0x1c
    80002e9a:	d1270713          	addi	a4,a4,-750 # 8001eba8 <bcache+0x8268>
    80002e9e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002ea0:	2b87b703          	ld	a4,696(a5)
    80002ea4:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002ea6:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002eaa:	00014517          	auipc	a0,0x14
    80002eae:	a9650513          	addi	a0,a0,-1386 # 80016940 <bcache>
    80002eb2:	d53fd0ef          	jal	ra,80000c04 <release>
}
    80002eb6:	60e2                	ld	ra,24(sp)
    80002eb8:	6442                	ld	s0,16(sp)
    80002eba:	64a2                	ld	s1,8(sp)
    80002ebc:	6902                	ld	s2,0(sp)
    80002ebe:	6105                	addi	sp,sp,32
    80002ec0:	8082                	ret
    panic("brelse");
    80002ec2:	00005517          	auipc	a0,0x5
    80002ec6:	8d650513          	addi	a0,a0,-1834 # 80007798 <syscalls+0xe0>
    80002eca:	8c1fd0ef          	jal	ra,8000078a <panic>

0000000080002ece <bpin>:

void
bpin(struct buf *b) {
    80002ece:	1101                	addi	sp,sp,-32
    80002ed0:	ec06                	sd	ra,24(sp)
    80002ed2:	e822                	sd	s0,16(sp)
    80002ed4:	e426                	sd	s1,8(sp)
    80002ed6:	1000                	addi	s0,sp,32
    80002ed8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002eda:	00014517          	auipc	a0,0x14
    80002ede:	a6650513          	addi	a0,a0,-1434 # 80016940 <bcache>
    80002ee2:	c8bfd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt++;
    80002ee6:	40bc                	lw	a5,64(s1)
    80002ee8:	2785                	addiw	a5,a5,1
    80002eea:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002eec:	00014517          	auipc	a0,0x14
    80002ef0:	a5450513          	addi	a0,a0,-1452 # 80016940 <bcache>
    80002ef4:	d11fd0ef          	jal	ra,80000c04 <release>
}
    80002ef8:	60e2                	ld	ra,24(sp)
    80002efa:	6442                	ld	s0,16(sp)
    80002efc:	64a2                	ld	s1,8(sp)
    80002efe:	6105                	addi	sp,sp,32
    80002f00:	8082                	ret

0000000080002f02 <bunpin>:

void
bunpin(struct buf *b) {
    80002f02:	1101                	addi	sp,sp,-32
    80002f04:	ec06                	sd	ra,24(sp)
    80002f06:	e822                	sd	s0,16(sp)
    80002f08:	e426                	sd	s1,8(sp)
    80002f0a:	1000                	addi	s0,sp,32
    80002f0c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f0e:	00014517          	auipc	a0,0x14
    80002f12:	a3250513          	addi	a0,a0,-1486 # 80016940 <bcache>
    80002f16:	c57fd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt--;
    80002f1a:	40bc                	lw	a5,64(s1)
    80002f1c:	37fd                	addiw	a5,a5,-1
    80002f1e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f20:	00014517          	auipc	a0,0x14
    80002f24:	a2050513          	addi	a0,a0,-1504 # 80016940 <bcache>
    80002f28:	cddfd0ef          	jal	ra,80000c04 <release>
}
    80002f2c:	60e2                	ld	ra,24(sp)
    80002f2e:	6442                	ld	s0,16(sp)
    80002f30:	64a2                	ld	s1,8(sp)
    80002f32:	6105                	addi	sp,sp,32
    80002f34:	8082                	ret

0000000080002f36 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002f36:	1101                	addi	sp,sp,-32
    80002f38:	ec06                	sd	ra,24(sp)
    80002f3a:	e822                	sd	s0,16(sp)
    80002f3c:	e426                	sd	s1,8(sp)
    80002f3e:	e04a                	sd	s2,0(sp)
    80002f40:	1000                	addi	s0,sp,32
    80002f42:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002f44:	00d5d59b          	srliw	a1,a1,0xd
    80002f48:	0001c797          	auipc	a5,0x1c
    80002f4c:	0d47a783          	lw	a5,212(a5) # 8001f01c <sb+0x1c>
    80002f50:	9dbd                	addw	a1,a1,a5
    80002f52:	debff0ef          	jal	ra,80002d3c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002f56:	0074f713          	andi	a4,s1,7
    80002f5a:	4785                	li	a5,1
    80002f5c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002f60:	14ce                	slli	s1,s1,0x33
    80002f62:	90d9                	srli	s1,s1,0x36
    80002f64:	00950733          	add	a4,a0,s1
    80002f68:	05874703          	lbu	a4,88(a4)
    80002f6c:	00e7f6b3          	and	a3,a5,a4
    80002f70:	c29d                	beqz	a3,80002f96 <bfree+0x60>
    80002f72:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002f74:	94aa                	add	s1,s1,a0
    80002f76:	fff7c793          	not	a5,a5
    80002f7a:	8ff9                	and	a5,a5,a4
    80002f7c:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80002f80:	7d1000ef          	jal	ra,80003f50 <log_write>
  brelse(bp);
    80002f84:	854a                	mv	a0,s2
    80002f86:	ebfff0ef          	jal	ra,80002e44 <brelse>
}
    80002f8a:	60e2                	ld	ra,24(sp)
    80002f8c:	6442                	ld	s0,16(sp)
    80002f8e:	64a2                	ld	s1,8(sp)
    80002f90:	6902                	ld	s2,0(sp)
    80002f92:	6105                	addi	sp,sp,32
    80002f94:	8082                	ret
    panic("freeing free block");
    80002f96:	00005517          	auipc	a0,0x5
    80002f9a:	80a50513          	addi	a0,a0,-2038 # 800077a0 <syscalls+0xe8>
    80002f9e:	fecfd0ef          	jal	ra,8000078a <panic>

0000000080002fa2 <balloc>:
{
    80002fa2:	711d                	addi	sp,sp,-96
    80002fa4:	ec86                	sd	ra,88(sp)
    80002fa6:	e8a2                	sd	s0,80(sp)
    80002fa8:	e4a6                	sd	s1,72(sp)
    80002faa:	e0ca                	sd	s2,64(sp)
    80002fac:	fc4e                	sd	s3,56(sp)
    80002fae:	f852                	sd	s4,48(sp)
    80002fb0:	f456                	sd	s5,40(sp)
    80002fb2:	f05a                	sd	s6,32(sp)
    80002fb4:	ec5e                	sd	s7,24(sp)
    80002fb6:	e862                	sd	s8,16(sp)
    80002fb8:	e466                	sd	s9,8(sp)
    80002fba:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002fbc:	0001c797          	auipc	a5,0x1c
    80002fc0:	0487a783          	lw	a5,72(a5) # 8001f004 <sb+0x4>
    80002fc4:	0e078163          	beqz	a5,800030a6 <balloc+0x104>
    80002fc8:	8baa                	mv	s7,a0
    80002fca:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002fcc:	0001cb17          	auipc	s6,0x1c
    80002fd0:	034b0b13          	addi	s6,s6,52 # 8001f000 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002fd4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002fd6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002fd8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002fda:	6c89                	lui	s9,0x2
    80002fdc:	a0b5                	j	80003048 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002fde:	974a                	add	a4,a4,s2
    80002fe0:	8fd5                	or	a5,a5,a3
    80002fe2:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80002fe6:	854a                	mv	a0,s2
    80002fe8:	769000ef          	jal	ra,80003f50 <log_write>
        brelse(bp);
    80002fec:	854a                	mv	a0,s2
    80002fee:	e57ff0ef          	jal	ra,80002e44 <brelse>
  bp = bread(dev, bno);
    80002ff2:	85a6                	mv	a1,s1
    80002ff4:	855e                	mv	a0,s7
    80002ff6:	d47ff0ef          	jal	ra,80002d3c <bread>
    80002ffa:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002ffc:	40000613          	li	a2,1024
    80003000:	4581                	li	a1,0
    80003002:	05850513          	addi	a0,a0,88
    80003006:	c3bfd0ef          	jal	ra,80000c40 <memset>
  log_write(bp);
    8000300a:	854a                	mv	a0,s2
    8000300c:	745000ef          	jal	ra,80003f50 <log_write>
  brelse(bp);
    80003010:	854a                	mv	a0,s2
    80003012:	e33ff0ef          	jal	ra,80002e44 <brelse>
}
    80003016:	8526                	mv	a0,s1
    80003018:	60e6                	ld	ra,88(sp)
    8000301a:	6446                	ld	s0,80(sp)
    8000301c:	64a6                	ld	s1,72(sp)
    8000301e:	6906                	ld	s2,64(sp)
    80003020:	79e2                	ld	s3,56(sp)
    80003022:	7a42                	ld	s4,48(sp)
    80003024:	7aa2                	ld	s5,40(sp)
    80003026:	7b02                	ld	s6,32(sp)
    80003028:	6be2                	ld	s7,24(sp)
    8000302a:	6c42                	ld	s8,16(sp)
    8000302c:	6ca2                	ld	s9,8(sp)
    8000302e:	6125                	addi	sp,sp,96
    80003030:	8082                	ret
    brelse(bp);
    80003032:	854a                	mv	a0,s2
    80003034:	e11ff0ef          	jal	ra,80002e44 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003038:	015c87bb          	addw	a5,s9,s5
    8000303c:	00078a9b          	sext.w	s5,a5
    80003040:	004b2703          	lw	a4,4(s6)
    80003044:	06eaf163          	bgeu	s5,a4,800030a6 <balloc+0x104>
    bp = bread(dev, BBLOCK(b, sb));
    80003048:	41fad79b          	sraiw	a5,s5,0x1f
    8000304c:	0137d79b          	srliw	a5,a5,0x13
    80003050:	015787bb          	addw	a5,a5,s5
    80003054:	40d7d79b          	sraiw	a5,a5,0xd
    80003058:	01cb2583          	lw	a1,28(s6)
    8000305c:	9dbd                	addw	a1,a1,a5
    8000305e:	855e                	mv	a0,s7
    80003060:	cddff0ef          	jal	ra,80002d3c <bread>
    80003064:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003066:	004b2503          	lw	a0,4(s6)
    8000306a:	000a849b          	sext.w	s1,s5
    8000306e:	8662                	mv	a2,s8
    80003070:	fca4f1e3          	bgeu	s1,a0,80003032 <balloc+0x90>
      m = 1 << (bi % 8);
    80003074:	41f6579b          	sraiw	a5,a2,0x1f
    80003078:	01d7d69b          	srliw	a3,a5,0x1d
    8000307c:	00c6873b          	addw	a4,a3,a2
    80003080:	00777793          	andi	a5,a4,7
    80003084:	9f95                	subw	a5,a5,a3
    80003086:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000308a:	4037571b          	sraiw	a4,a4,0x3
    8000308e:	00e906b3          	add	a3,s2,a4
    80003092:	0586c683          	lbu	a3,88(a3) # 1058 <_entry-0x7fffefa8>
    80003096:	00d7f5b3          	and	a1,a5,a3
    8000309a:	d1b1                	beqz	a1,80002fde <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000309c:	2605                	addiw	a2,a2,1
    8000309e:	2485                	addiw	s1,s1,1
    800030a0:	fd4618e3          	bne	a2,s4,80003070 <balloc+0xce>
    800030a4:	b779                	j	80003032 <balloc+0x90>
  printf("balloc: out of blocks\n");
    800030a6:	00004517          	auipc	a0,0x4
    800030aa:	71250513          	addi	a0,a0,1810 # 800077b8 <syscalls+0x100>
    800030ae:	c16fd0ef          	jal	ra,800004c4 <printf>
  return 0;
    800030b2:	4481                	li	s1,0
    800030b4:	b78d                	j	80003016 <balloc+0x74>

00000000800030b6 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800030b6:	7179                	addi	sp,sp,-48
    800030b8:	f406                	sd	ra,40(sp)
    800030ba:	f022                	sd	s0,32(sp)
    800030bc:	ec26                	sd	s1,24(sp)
    800030be:	e84a                	sd	s2,16(sp)
    800030c0:	e44e                	sd	s3,8(sp)
    800030c2:	e052                	sd	s4,0(sp)
    800030c4:	1800                	addi	s0,sp,48
    800030c6:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800030c8:	47ad                	li	a5,11
    800030ca:	02b7e563          	bltu	a5,a1,800030f4 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    800030ce:	02059493          	slli	s1,a1,0x20
    800030d2:	9081                	srli	s1,s1,0x20
    800030d4:	048a                	slli	s1,s1,0x2
    800030d6:	94aa                	add	s1,s1,a0
    800030d8:	0504a903          	lw	s2,80(s1)
    800030dc:	06091663          	bnez	s2,80003148 <bmap+0x92>
      addr = balloc(ip->dev);
    800030e0:	4108                	lw	a0,0(a0)
    800030e2:	ec1ff0ef          	jal	ra,80002fa2 <balloc>
    800030e6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800030ea:	04090f63          	beqz	s2,80003148 <bmap+0x92>
        return 0;
      ip->addrs[bn] = addr;
    800030ee:	0524a823          	sw	s2,80(s1)
    800030f2:	a899                	j	80003148 <bmap+0x92>
    }
    return addr;
  }
  bn -= NDIRECT;
    800030f4:	ff45849b          	addiw	s1,a1,-12
    800030f8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800030fc:	0ff00793          	li	a5,255
    80003100:	06e7eb63          	bltu	a5,a4,80003176 <bmap+0xc0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003104:	08052903          	lw	s2,128(a0)
    80003108:	00091b63          	bnez	s2,8000311e <bmap+0x68>
      addr = balloc(ip->dev);
    8000310c:	4108                	lw	a0,0(a0)
    8000310e:	e95ff0ef          	jal	ra,80002fa2 <balloc>
    80003112:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003116:	02090963          	beqz	s2,80003148 <bmap+0x92>
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000311a:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000311e:	85ca                	mv	a1,s2
    80003120:	0009a503          	lw	a0,0(s3)
    80003124:	c19ff0ef          	jal	ra,80002d3c <bread>
    80003128:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000312a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000312e:	02049593          	slli	a1,s1,0x20
    80003132:	9181                	srli	a1,a1,0x20
    80003134:	058a                	slli	a1,a1,0x2
    80003136:	00b784b3          	add	s1,a5,a1
    8000313a:	0004a903          	lw	s2,0(s1)
    8000313e:	00090e63          	beqz	s2,8000315a <bmap+0xa4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003142:	8552                	mv	a0,s4
    80003144:	d01ff0ef          	jal	ra,80002e44 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003148:	854a                	mv	a0,s2
    8000314a:	70a2                	ld	ra,40(sp)
    8000314c:	7402                	ld	s0,32(sp)
    8000314e:	64e2                	ld	s1,24(sp)
    80003150:	6942                	ld	s2,16(sp)
    80003152:	69a2                	ld	s3,8(sp)
    80003154:	6a02                	ld	s4,0(sp)
    80003156:	6145                	addi	sp,sp,48
    80003158:	8082                	ret
      addr = balloc(ip->dev);
    8000315a:	0009a503          	lw	a0,0(s3)
    8000315e:	e45ff0ef          	jal	ra,80002fa2 <balloc>
    80003162:	0005091b          	sext.w	s2,a0
      if(addr){
    80003166:	fc090ee3          	beqz	s2,80003142 <bmap+0x8c>
        a[bn] = addr;
    8000316a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000316e:	8552                	mv	a0,s4
    80003170:	5e1000ef          	jal	ra,80003f50 <log_write>
    80003174:	b7f9                	j	80003142 <bmap+0x8c>
  panic("bmap: out of range");
    80003176:	00004517          	auipc	a0,0x4
    8000317a:	65a50513          	addi	a0,a0,1626 # 800077d0 <syscalls+0x118>
    8000317e:	e0cfd0ef          	jal	ra,8000078a <panic>

0000000080003182 <iget>:
{
    80003182:	7179                	addi	sp,sp,-48
    80003184:	f406                	sd	ra,40(sp)
    80003186:	f022                	sd	s0,32(sp)
    80003188:	ec26                	sd	s1,24(sp)
    8000318a:	e84a                	sd	s2,16(sp)
    8000318c:	e44e                	sd	s3,8(sp)
    8000318e:	e052                	sd	s4,0(sp)
    80003190:	1800                	addi	s0,sp,48
    80003192:	89aa                	mv	s3,a0
    80003194:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003196:	0001c517          	auipc	a0,0x1c
    8000319a:	e8a50513          	addi	a0,a0,-374 # 8001f020 <itable>
    8000319e:	9cffd0ef          	jal	ra,80000b6c <acquire>
  empty = 0;
    800031a2:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800031a4:	0001c497          	auipc	s1,0x1c
    800031a8:	e9448493          	addi	s1,s1,-364 # 8001f038 <itable+0x18>
    800031ac:	0001e697          	auipc	a3,0x1e
    800031b0:	91c68693          	addi	a3,a3,-1764 # 80020ac8 <log>
    800031b4:	a039                	j	800031c2 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800031b6:	02090963          	beqz	s2,800031e8 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800031ba:	08848493          	addi	s1,s1,136
    800031be:	02d48863          	beq	s1,a3,800031ee <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800031c2:	449c                	lw	a5,8(s1)
    800031c4:	fef059e3          	blez	a5,800031b6 <iget+0x34>
    800031c8:	4098                	lw	a4,0(s1)
    800031ca:	ff3716e3          	bne	a4,s3,800031b6 <iget+0x34>
    800031ce:	40d8                	lw	a4,4(s1)
    800031d0:	ff4713e3          	bne	a4,s4,800031b6 <iget+0x34>
      ip->ref++;
    800031d4:	2785                	addiw	a5,a5,1
    800031d6:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800031d8:	0001c517          	auipc	a0,0x1c
    800031dc:	e4850513          	addi	a0,a0,-440 # 8001f020 <itable>
    800031e0:	a25fd0ef          	jal	ra,80000c04 <release>
      return ip;
    800031e4:	8926                	mv	s2,s1
    800031e6:	a02d                	j	80003210 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800031e8:	fbe9                	bnez	a5,800031ba <iget+0x38>
    800031ea:	8926                	mv	s2,s1
    800031ec:	b7f9                	j	800031ba <iget+0x38>
  if(empty == 0)
    800031ee:	02090a63          	beqz	s2,80003222 <iget+0xa0>
  ip->dev = dev;
    800031f2:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800031f6:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800031fa:	4785                	li	a5,1
    800031fc:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003200:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003204:	0001c517          	auipc	a0,0x1c
    80003208:	e1c50513          	addi	a0,a0,-484 # 8001f020 <itable>
    8000320c:	9f9fd0ef          	jal	ra,80000c04 <release>
}
    80003210:	854a                	mv	a0,s2
    80003212:	70a2                	ld	ra,40(sp)
    80003214:	7402                	ld	s0,32(sp)
    80003216:	64e2                	ld	s1,24(sp)
    80003218:	6942                	ld	s2,16(sp)
    8000321a:	69a2                	ld	s3,8(sp)
    8000321c:	6a02                	ld	s4,0(sp)
    8000321e:	6145                	addi	sp,sp,48
    80003220:	8082                	ret
    panic("iget: no inodes");
    80003222:	00004517          	auipc	a0,0x4
    80003226:	5c650513          	addi	a0,a0,1478 # 800077e8 <syscalls+0x130>
    8000322a:	d60fd0ef          	jal	ra,8000078a <panic>

000000008000322e <iinit>:
{
    8000322e:	7179                	addi	sp,sp,-48
    80003230:	f406                	sd	ra,40(sp)
    80003232:	f022                	sd	s0,32(sp)
    80003234:	ec26                	sd	s1,24(sp)
    80003236:	e84a                	sd	s2,16(sp)
    80003238:	e44e                	sd	s3,8(sp)
    8000323a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000323c:	00004597          	auipc	a1,0x4
    80003240:	5bc58593          	addi	a1,a1,1468 # 800077f8 <syscalls+0x140>
    80003244:	0001c517          	auipc	a0,0x1c
    80003248:	ddc50513          	addi	a0,a0,-548 # 8001f020 <itable>
    8000324c:	8a1fd0ef          	jal	ra,80000aec <initlock>
  for(i = 0; i < NINODE; i++) {
    80003250:	0001c497          	auipc	s1,0x1c
    80003254:	df848493          	addi	s1,s1,-520 # 8001f048 <itable+0x28>
    80003258:	0001e997          	auipc	s3,0x1e
    8000325c:	88098993          	addi	s3,s3,-1920 # 80020ad8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003260:	00004917          	auipc	s2,0x4
    80003264:	5a090913          	addi	s2,s2,1440 # 80007800 <syscalls+0x148>
    80003268:	85ca                	mv	a1,s2
    8000326a:	8526                	mv	a0,s1
    8000326c:	5a9000ef          	jal	ra,80004014 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003270:	08848493          	addi	s1,s1,136
    80003274:	ff349ae3          	bne	s1,s3,80003268 <iinit+0x3a>
}
    80003278:	70a2                	ld	ra,40(sp)
    8000327a:	7402                	ld	s0,32(sp)
    8000327c:	64e2                	ld	s1,24(sp)
    8000327e:	6942                	ld	s2,16(sp)
    80003280:	69a2                	ld	s3,8(sp)
    80003282:	6145                	addi	sp,sp,48
    80003284:	8082                	ret

0000000080003286 <ialloc>:
{
    80003286:	715d                	addi	sp,sp,-80
    80003288:	e486                	sd	ra,72(sp)
    8000328a:	e0a2                	sd	s0,64(sp)
    8000328c:	fc26                	sd	s1,56(sp)
    8000328e:	f84a                	sd	s2,48(sp)
    80003290:	f44e                	sd	s3,40(sp)
    80003292:	f052                	sd	s4,32(sp)
    80003294:	ec56                	sd	s5,24(sp)
    80003296:	e85a                	sd	s6,16(sp)
    80003298:	e45e                	sd	s7,8(sp)
    8000329a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000329c:	0001c717          	auipc	a4,0x1c
    800032a0:	d7072703          	lw	a4,-656(a4) # 8001f00c <sb+0xc>
    800032a4:	4785                	li	a5,1
    800032a6:	04e7f663          	bgeu	a5,a4,800032f2 <ialloc+0x6c>
    800032aa:	8aaa                	mv	s5,a0
    800032ac:	8bae                	mv	s7,a1
    800032ae:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800032b0:	0001ca17          	auipc	s4,0x1c
    800032b4:	d50a0a13          	addi	s4,s4,-688 # 8001f000 <sb>
    800032b8:	00048b1b          	sext.w	s6,s1
    800032bc:	0044d793          	srli	a5,s1,0x4
    800032c0:	018a2583          	lw	a1,24(s4)
    800032c4:	9dbd                	addw	a1,a1,a5
    800032c6:	8556                	mv	a0,s5
    800032c8:	a75ff0ef          	jal	ra,80002d3c <bread>
    800032cc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800032ce:	05850993          	addi	s3,a0,88
    800032d2:	00f4f793          	andi	a5,s1,15
    800032d6:	079a                	slli	a5,a5,0x6
    800032d8:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800032da:	00099783          	lh	a5,0(s3)
    800032de:	cf85                	beqz	a5,80003316 <ialloc+0x90>
    brelse(bp);
    800032e0:	b65ff0ef          	jal	ra,80002e44 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800032e4:	0485                	addi	s1,s1,1
    800032e6:	00ca2703          	lw	a4,12(s4)
    800032ea:	0004879b          	sext.w	a5,s1
    800032ee:	fce7e5e3          	bltu	a5,a4,800032b8 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800032f2:	00004517          	auipc	a0,0x4
    800032f6:	51650513          	addi	a0,a0,1302 # 80007808 <syscalls+0x150>
    800032fa:	9cafd0ef          	jal	ra,800004c4 <printf>
  return 0;
    800032fe:	4501                	li	a0,0
}
    80003300:	60a6                	ld	ra,72(sp)
    80003302:	6406                	ld	s0,64(sp)
    80003304:	74e2                	ld	s1,56(sp)
    80003306:	7942                	ld	s2,48(sp)
    80003308:	79a2                	ld	s3,40(sp)
    8000330a:	7a02                	ld	s4,32(sp)
    8000330c:	6ae2                	ld	s5,24(sp)
    8000330e:	6b42                	ld	s6,16(sp)
    80003310:	6ba2                	ld	s7,8(sp)
    80003312:	6161                	addi	sp,sp,80
    80003314:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003316:	04000613          	li	a2,64
    8000331a:	4581                	li	a1,0
    8000331c:	854e                	mv	a0,s3
    8000331e:	923fd0ef          	jal	ra,80000c40 <memset>
      dip->type = type;
    80003322:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003326:	854a                	mv	a0,s2
    80003328:	429000ef          	jal	ra,80003f50 <log_write>
      brelse(bp);
    8000332c:	854a                	mv	a0,s2
    8000332e:	b17ff0ef          	jal	ra,80002e44 <brelse>
      return iget(dev, inum);
    80003332:	85da                	mv	a1,s6
    80003334:	8556                	mv	a0,s5
    80003336:	e4dff0ef          	jal	ra,80003182 <iget>
    8000333a:	b7d9                	j	80003300 <ialloc+0x7a>

000000008000333c <iupdate>:
{
    8000333c:	1101                	addi	sp,sp,-32
    8000333e:	ec06                	sd	ra,24(sp)
    80003340:	e822                	sd	s0,16(sp)
    80003342:	e426                	sd	s1,8(sp)
    80003344:	e04a                	sd	s2,0(sp)
    80003346:	1000                	addi	s0,sp,32
    80003348:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000334a:	415c                	lw	a5,4(a0)
    8000334c:	0047d79b          	srliw	a5,a5,0x4
    80003350:	0001c597          	auipc	a1,0x1c
    80003354:	cc85a583          	lw	a1,-824(a1) # 8001f018 <sb+0x18>
    80003358:	9dbd                	addw	a1,a1,a5
    8000335a:	4108                	lw	a0,0(a0)
    8000335c:	9e1ff0ef          	jal	ra,80002d3c <bread>
    80003360:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003362:	05850793          	addi	a5,a0,88
    80003366:	40c8                	lw	a0,4(s1)
    80003368:	893d                	andi	a0,a0,15
    8000336a:	051a                	slli	a0,a0,0x6
    8000336c:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000336e:	04449703          	lh	a4,68(s1)
    80003372:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003376:	04649703          	lh	a4,70(s1)
    8000337a:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000337e:	04849703          	lh	a4,72(s1)
    80003382:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003386:	04a49703          	lh	a4,74(s1)
    8000338a:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000338e:	44f8                	lw	a4,76(s1)
    80003390:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003392:	03400613          	li	a2,52
    80003396:	05048593          	addi	a1,s1,80
    8000339a:	0531                	addi	a0,a0,12
    8000339c:	901fd0ef          	jal	ra,80000c9c <memmove>
  log_write(bp);
    800033a0:	854a                	mv	a0,s2
    800033a2:	3af000ef          	jal	ra,80003f50 <log_write>
  brelse(bp);
    800033a6:	854a                	mv	a0,s2
    800033a8:	a9dff0ef          	jal	ra,80002e44 <brelse>
}
    800033ac:	60e2                	ld	ra,24(sp)
    800033ae:	6442                	ld	s0,16(sp)
    800033b0:	64a2                	ld	s1,8(sp)
    800033b2:	6902                	ld	s2,0(sp)
    800033b4:	6105                	addi	sp,sp,32
    800033b6:	8082                	ret

00000000800033b8 <idup>:
{
    800033b8:	1101                	addi	sp,sp,-32
    800033ba:	ec06                	sd	ra,24(sp)
    800033bc:	e822                	sd	s0,16(sp)
    800033be:	e426                	sd	s1,8(sp)
    800033c0:	1000                	addi	s0,sp,32
    800033c2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800033c4:	0001c517          	auipc	a0,0x1c
    800033c8:	c5c50513          	addi	a0,a0,-932 # 8001f020 <itable>
    800033cc:	fa0fd0ef          	jal	ra,80000b6c <acquire>
  ip->ref++;
    800033d0:	449c                	lw	a5,8(s1)
    800033d2:	2785                	addiw	a5,a5,1
    800033d4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800033d6:	0001c517          	auipc	a0,0x1c
    800033da:	c4a50513          	addi	a0,a0,-950 # 8001f020 <itable>
    800033de:	827fd0ef          	jal	ra,80000c04 <release>
}
    800033e2:	8526                	mv	a0,s1
    800033e4:	60e2                	ld	ra,24(sp)
    800033e6:	6442                	ld	s0,16(sp)
    800033e8:	64a2                	ld	s1,8(sp)
    800033ea:	6105                	addi	sp,sp,32
    800033ec:	8082                	ret

00000000800033ee <ilock>:
{
    800033ee:	1101                	addi	sp,sp,-32
    800033f0:	ec06                	sd	ra,24(sp)
    800033f2:	e822                	sd	s0,16(sp)
    800033f4:	e426                	sd	s1,8(sp)
    800033f6:	e04a                	sd	s2,0(sp)
    800033f8:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800033fa:	c105                	beqz	a0,8000341a <ilock+0x2c>
    800033fc:	84aa                	mv	s1,a0
    800033fe:	451c                	lw	a5,8(a0)
    80003400:	00f05d63          	blez	a5,8000341a <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003404:	0541                	addi	a0,a0,16
    80003406:	445000ef          	jal	ra,8000404a <acquiresleep>
  if(ip->valid == 0){
    8000340a:	40bc                	lw	a5,64(s1)
    8000340c:	cf89                	beqz	a5,80003426 <ilock+0x38>
}
    8000340e:	60e2                	ld	ra,24(sp)
    80003410:	6442                	ld	s0,16(sp)
    80003412:	64a2                	ld	s1,8(sp)
    80003414:	6902                	ld	s2,0(sp)
    80003416:	6105                	addi	sp,sp,32
    80003418:	8082                	ret
    panic("ilock");
    8000341a:	00004517          	auipc	a0,0x4
    8000341e:	40650513          	addi	a0,a0,1030 # 80007820 <syscalls+0x168>
    80003422:	b68fd0ef          	jal	ra,8000078a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003426:	40dc                	lw	a5,4(s1)
    80003428:	0047d79b          	srliw	a5,a5,0x4
    8000342c:	0001c597          	auipc	a1,0x1c
    80003430:	bec5a583          	lw	a1,-1044(a1) # 8001f018 <sb+0x18>
    80003434:	9dbd                	addw	a1,a1,a5
    80003436:	4088                	lw	a0,0(s1)
    80003438:	905ff0ef          	jal	ra,80002d3c <bread>
    8000343c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000343e:	05850593          	addi	a1,a0,88
    80003442:	40dc                	lw	a5,4(s1)
    80003444:	8bbd                	andi	a5,a5,15
    80003446:	079a                	slli	a5,a5,0x6
    80003448:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000344a:	00059783          	lh	a5,0(a1)
    8000344e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003452:	00259783          	lh	a5,2(a1)
    80003456:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000345a:	00459783          	lh	a5,4(a1)
    8000345e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003462:	00659783          	lh	a5,6(a1)
    80003466:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000346a:	459c                	lw	a5,8(a1)
    8000346c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000346e:	03400613          	li	a2,52
    80003472:	05b1                	addi	a1,a1,12
    80003474:	05048513          	addi	a0,s1,80
    80003478:	825fd0ef          	jal	ra,80000c9c <memmove>
    brelse(bp);
    8000347c:	854a                	mv	a0,s2
    8000347e:	9c7ff0ef          	jal	ra,80002e44 <brelse>
    ip->valid = 1;
    80003482:	4785                	li	a5,1
    80003484:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003486:	04449783          	lh	a5,68(s1)
    8000348a:	f3d1                	bnez	a5,8000340e <ilock+0x20>
      panic("ilock: no type");
    8000348c:	00004517          	auipc	a0,0x4
    80003490:	39c50513          	addi	a0,a0,924 # 80007828 <syscalls+0x170>
    80003494:	af6fd0ef          	jal	ra,8000078a <panic>

0000000080003498 <iunlock>:
{
    80003498:	1101                	addi	sp,sp,-32
    8000349a:	ec06                	sd	ra,24(sp)
    8000349c:	e822                	sd	s0,16(sp)
    8000349e:	e426                	sd	s1,8(sp)
    800034a0:	e04a                	sd	s2,0(sp)
    800034a2:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800034a4:	c505                	beqz	a0,800034cc <iunlock+0x34>
    800034a6:	84aa                	mv	s1,a0
    800034a8:	01050913          	addi	s2,a0,16
    800034ac:	854a                	mv	a0,s2
    800034ae:	41b000ef          	jal	ra,800040c8 <holdingsleep>
    800034b2:	cd09                	beqz	a0,800034cc <iunlock+0x34>
    800034b4:	449c                	lw	a5,8(s1)
    800034b6:	00f05b63          	blez	a5,800034cc <iunlock+0x34>
  releasesleep(&ip->lock);
    800034ba:	854a                	mv	a0,s2
    800034bc:	3d5000ef          	jal	ra,80004090 <releasesleep>
}
    800034c0:	60e2                	ld	ra,24(sp)
    800034c2:	6442                	ld	s0,16(sp)
    800034c4:	64a2                	ld	s1,8(sp)
    800034c6:	6902                	ld	s2,0(sp)
    800034c8:	6105                	addi	sp,sp,32
    800034ca:	8082                	ret
    panic("iunlock");
    800034cc:	00004517          	auipc	a0,0x4
    800034d0:	36c50513          	addi	a0,a0,876 # 80007838 <syscalls+0x180>
    800034d4:	ab6fd0ef          	jal	ra,8000078a <panic>

00000000800034d8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800034d8:	7179                	addi	sp,sp,-48
    800034da:	f406                	sd	ra,40(sp)
    800034dc:	f022                	sd	s0,32(sp)
    800034de:	ec26                	sd	s1,24(sp)
    800034e0:	e84a                	sd	s2,16(sp)
    800034e2:	e44e                	sd	s3,8(sp)
    800034e4:	e052                	sd	s4,0(sp)
    800034e6:	1800                	addi	s0,sp,48
    800034e8:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800034ea:	05050493          	addi	s1,a0,80
    800034ee:	08050913          	addi	s2,a0,128
    800034f2:	a021                	j	800034fa <itrunc+0x22>
    800034f4:	0491                	addi	s1,s1,4
    800034f6:	01248b63          	beq	s1,s2,8000350c <itrunc+0x34>
    if(ip->addrs[i]){
    800034fa:	408c                	lw	a1,0(s1)
    800034fc:	dde5                	beqz	a1,800034f4 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800034fe:	0009a503          	lw	a0,0(s3)
    80003502:	a35ff0ef          	jal	ra,80002f36 <bfree>
      ip->addrs[i] = 0;
    80003506:	0004a023          	sw	zero,0(s1)
    8000350a:	b7ed                	j	800034f4 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000350c:	0809a583          	lw	a1,128(s3)
    80003510:	ed91                	bnez	a1,8000352c <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003512:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003516:	854e                	mv	a0,s3
    80003518:	e25ff0ef          	jal	ra,8000333c <iupdate>
}
    8000351c:	70a2                	ld	ra,40(sp)
    8000351e:	7402                	ld	s0,32(sp)
    80003520:	64e2                	ld	s1,24(sp)
    80003522:	6942                	ld	s2,16(sp)
    80003524:	69a2                	ld	s3,8(sp)
    80003526:	6a02                	ld	s4,0(sp)
    80003528:	6145                	addi	sp,sp,48
    8000352a:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000352c:	0009a503          	lw	a0,0(s3)
    80003530:	80dff0ef          	jal	ra,80002d3c <bread>
    80003534:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003536:	05850493          	addi	s1,a0,88
    8000353a:	45850913          	addi	s2,a0,1112
    8000353e:	a021                	j	80003546 <itrunc+0x6e>
    80003540:	0491                	addi	s1,s1,4
    80003542:	01248963          	beq	s1,s2,80003554 <itrunc+0x7c>
      if(a[j])
    80003546:	408c                	lw	a1,0(s1)
    80003548:	dde5                	beqz	a1,80003540 <itrunc+0x68>
        bfree(ip->dev, a[j]);
    8000354a:	0009a503          	lw	a0,0(s3)
    8000354e:	9e9ff0ef          	jal	ra,80002f36 <bfree>
    80003552:	b7fd                	j	80003540 <itrunc+0x68>
    brelse(bp);
    80003554:	8552                	mv	a0,s4
    80003556:	8efff0ef          	jal	ra,80002e44 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000355a:	0809a583          	lw	a1,128(s3)
    8000355e:	0009a503          	lw	a0,0(s3)
    80003562:	9d5ff0ef          	jal	ra,80002f36 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003566:	0809a023          	sw	zero,128(s3)
    8000356a:	b765                	j	80003512 <itrunc+0x3a>

000000008000356c <iput>:
{
    8000356c:	1101                	addi	sp,sp,-32
    8000356e:	ec06                	sd	ra,24(sp)
    80003570:	e822                	sd	s0,16(sp)
    80003572:	e426                	sd	s1,8(sp)
    80003574:	e04a                	sd	s2,0(sp)
    80003576:	1000                	addi	s0,sp,32
    80003578:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000357a:	0001c517          	auipc	a0,0x1c
    8000357e:	aa650513          	addi	a0,a0,-1370 # 8001f020 <itable>
    80003582:	deafd0ef          	jal	ra,80000b6c <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003586:	4498                	lw	a4,8(s1)
    80003588:	4785                	li	a5,1
    8000358a:	02f70163          	beq	a4,a5,800035ac <iput+0x40>
  ip->ref--;
    8000358e:	449c                	lw	a5,8(s1)
    80003590:	37fd                	addiw	a5,a5,-1
    80003592:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003594:	0001c517          	auipc	a0,0x1c
    80003598:	a8c50513          	addi	a0,a0,-1396 # 8001f020 <itable>
    8000359c:	e68fd0ef          	jal	ra,80000c04 <release>
}
    800035a0:	60e2                	ld	ra,24(sp)
    800035a2:	6442                	ld	s0,16(sp)
    800035a4:	64a2                	ld	s1,8(sp)
    800035a6:	6902                	ld	s2,0(sp)
    800035a8:	6105                	addi	sp,sp,32
    800035aa:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800035ac:	40bc                	lw	a5,64(s1)
    800035ae:	d3e5                	beqz	a5,8000358e <iput+0x22>
    800035b0:	04a49783          	lh	a5,74(s1)
    800035b4:	ffe9                	bnez	a5,8000358e <iput+0x22>
    acquiresleep(&ip->lock);
    800035b6:	01048913          	addi	s2,s1,16
    800035ba:	854a                	mv	a0,s2
    800035bc:	28f000ef          	jal	ra,8000404a <acquiresleep>
    release(&itable.lock);
    800035c0:	0001c517          	auipc	a0,0x1c
    800035c4:	a6050513          	addi	a0,a0,-1440 # 8001f020 <itable>
    800035c8:	e3cfd0ef          	jal	ra,80000c04 <release>
    itrunc(ip);
    800035cc:	8526                	mv	a0,s1
    800035ce:	f0bff0ef          	jal	ra,800034d8 <itrunc>
    ip->type = 0;
    800035d2:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800035d6:	8526                	mv	a0,s1
    800035d8:	d65ff0ef          	jal	ra,8000333c <iupdate>
    ip->valid = 0;
    800035dc:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800035e0:	854a                	mv	a0,s2
    800035e2:	2af000ef          	jal	ra,80004090 <releasesleep>
    acquire(&itable.lock);
    800035e6:	0001c517          	auipc	a0,0x1c
    800035ea:	a3a50513          	addi	a0,a0,-1478 # 8001f020 <itable>
    800035ee:	d7efd0ef          	jal	ra,80000b6c <acquire>
    800035f2:	bf71                	j	8000358e <iput+0x22>

00000000800035f4 <iunlockput>:
{
    800035f4:	1101                	addi	sp,sp,-32
    800035f6:	ec06                	sd	ra,24(sp)
    800035f8:	e822                	sd	s0,16(sp)
    800035fa:	e426                	sd	s1,8(sp)
    800035fc:	1000                	addi	s0,sp,32
    800035fe:	84aa                	mv	s1,a0
  iunlock(ip);
    80003600:	e99ff0ef          	jal	ra,80003498 <iunlock>
  iput(ip);
    80003604:	8526                	mv	a0,s1
    80003606:	f67ff0ef          	jal	ra,8000356c <iput>
}
    8000360a:	60e2                	ld	ra,24(sp)
    8000360c:	6442                	ld	s0,16(sp)
    8000360e:	64a2                	ld	s1,8(sp)
    80003610:	6105                	addi	sp,sp,32
    80003612:	8082                	ret

0000000080003614 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003614:	0001c717          	auipc	a4,0x1c
    80003618:	9f872703          	lw	a4,-1544(a4) # 8001f00c <sb+0xc>
    8000361c:	4785                	li	a5,1
    8000361e:	0ae7ff63          	bgeu	a5,a4,800036dc <ireclaim+0xc8>
{
    80003622:	7139                	addi	sp,sp,-64
    80003624:	fc06                	sd	ra,56(sp)
    80003626:	f822                	sd	s0,48(sp)
    80003628:	f426                	sd	s1,40(sp)
    8000362a:	f04a                	sd	s2,32(sp)
    8000362c:	ec4e                	sd	s3,24(sp)
    8000362e:	e852                	sd	s4,16(sp)
    80003630:	e456                	sd	s5,8(sp)
    80003632:	e05a                	sd	s6,0(sp)
    80003634:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003636:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003638:	00050a1b          	sext.w	s4,a0
    8000363c:	0001ca97          	auipc	s5,0x1c
    80003640:	9c4a8a93          	addi	s5,s5,-1596 # 8001f000 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003644:	00004b17          	auipc	s6,0x4
    80003648:	1fcb0b13          	addi	s6,s6,508 # 80007840 <syscalls+0x188>
    8000364c:	a099                	j	80003692 <ireclaim+0x7e>
    8000364e:	85ce                	mv	a1,s3
    80003650:	855a                	mv	a0,s6
    80003652:	e73fc0ef          	jal	ra,800004c4 <printf>
      ip = iget(dev, inum);
    80003656:	85ce                	mv	a1,s3
    80003658:	8552                	mv	a0,s4
    8000365a:	b29ff0ef          	jal	ra,80003182 <iget>
    8000365e:	89aa                	mv	s3,a0
    brelse(bp);
    80003660:	854a                	mv	a0,s2
    80003662:	fe2ff0ef          	jal	ra,80002e44 <brelse>
    if (ip) {
    80003666:	00098f63          	beqz	s3,80003684 <ireclaim+0x70>
      begin_op();
    8000366a:	762000ef          	jal	ra,80003dcc <begin_op>
      ilock(ip);
    8000366e:	854e                	mv	a0,s3
    80003670:	d7fff0ef          	jal	ra,800033ee <ilock>
      iunlock(ip);
    80003674:	854e                	mv	a0,s3
    80003676:	e23ff0ef          	jal	ra,80003498 <iunlock>
      iput(ip);
    8000367a:	854e                	mv	a0,s3
    8000367c:	ef1ff0ef          	jal	ra,8000356c <iput>
      end_op();
    80003680:	7bc000ef          	jal	ra,80003e3c <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003684:	0485                	addi	s1,s1,1
    80003686:	00caa703          	lw	a4,12(s5)
    8000368a:	0004879b          	sext.w	a5,s1
    8000368e:	02e7fd63          	bgeu	a5,a4,800036c8 <ireclaim+0xb4>
    80003692:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003696:	0044d793          	srli	a5,s1,0x4
    8000369a:	018aa583          	lw	a1,24(s5)
    8000369e:	9dbd                	addw	a1,a1,a5
    800036a0:	8552                	mv	a0,s4
    800036a2:	e9aff0ef          	jal	ra,80002d3c <bread>
    800036a6:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800036a8:	05850793          	addi	a5,a0,88
    800036ac:	00f9f713          	andi	a4,s3,15
    800036b0:	071a                	slli	a4,a4,0x6
    800036b2:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    800036b4:	00079703          	lh	a4,0(a5)
    800036b8:	c701                	beqz	a4,800036c0 <ireclaim+0xac>
    800036ba:	00679783          	lh	a5,6(a5)
    800036be:	dbc1                	beqz	a5,8000364e <ireclaim+0x3a>
    brelse(bp);
    800036c0:	854a                	mv	a0,s2
    800036c2:	f82ff0ef          	jal	ra,80002e44 <brelse>
    if (ip) {
    800036c6:	bf7d                	j	80003684 <ireclaim+0x70>
}
    800036c8:	70e2                	ld	ra,56(sp)
    800036ca:	7442                	ld	s0,48(sp)
    800036cc:	74a2                	ld	s1,40(sp)
    800036ce:	7902                	ld	s2,32(sp)
    800036d0:	69e2                	ld	s3,24(sp)
    800036d2:	6a42                	ld	s4,16(sp)
    800036d4:	6aa2                	ld	s5,8(sp)
    800036d6:	6b02                	ld	s6,0(sp)
    800036d8:	6121                	addi	sp,sp,64
    800036da:	8082                	ret
    800036dc:	8082                	ret

00000000800036de <fsinit>:
fsinit(int dev) {
    800036de:	7179                	addi	sp,sp,-48
    800036e0:	f406                	sd	ra,40(sp)
    800036e2:	f022                	sd	s0,32(sp)
    800036e4:	ec26                	sd	s1,24(sp)
    800036e6:	e84a                	sd	s2,16(sp)
    800036e8:	e44e                	sd	s3,8(sp)
    800036ea:	1800                	addi	s0,sp,48
    800036ec:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800036ee:	4585                	li	a1,1
    800036f0:	e4cff0ef          	jal	ra,80002d3c <bread>
    800036f4:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036f6:	0001c997          	auipc	s3,0x1c
    800036fa:	90a98993          	addi	s3,s3,-1782 # 8001f000 <sb>
    800036fe:	02000613          	li	a2,32
    80003702:	05850593          	addi	a1,a0,88
    80003706:	854e                	mv	a0,s3
    80003708:	d94fd0ef          	jal	ra,80000c9c <memmove>
  brelse(bp);
    8000370c:	854a                	mv	a0,s2
    8000370e:	f36ff0ef          	jal	ra,80002e44 <brelse>
  if(sb.magic != FSMAGIC)
    80003712:	0009a703          	lw	a4,0(s3)
    80003716:	102037b7          	lui	a5,0x10203
    8000371a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000371e:	02f71363          	bne	a4,a5,80003744 <fsinit+0x66>
  initlog(dev, &sb);
    80003722:	0001c597          	auipc	a1,0x1c
    80003726:	8de58593          	addi	a1,a1,-1826 # 8001f000 <sb>
    8000372a:	8526                	mv	a0,s1
    8000372c:	616000ef          	jal	ra,80003d42 <initlog>
  ireclaim(dev);
    80003730:	8526                	mv	a0,s1
    80003732:	ee3ff0ef          	jal	ra,80003614 <ireclaim>
}
    80003736:	70a2                	ld	ra,40(sp)
    80003738:	7402                	ld	s0,32(sp)
    8000373a:	64e2                	ld	s1,24(sp)
    8000373c:	6942                	ld	s2,16(sp)
    8000373e:	69a2                	ld	s3,8(sp)
    80003740:	6145                	addi	sp,sp,48
    80003742:	8082                	ret
    panic("invalid file system");
    80003744:	00004517          	auipc	a0,0x4
    80003748:	11c50513          	addi	a0,a0,284 # 80007860 <syscalls+0x1a8>
    8000374c:	83efd0ef          	jal	ra,8000078a <panic>

0000000080003750 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003750:	1141                	addi	sp,sp,-16
    80003752:	e422                	sd	s0,8(sp)
    80003754:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003756:	411c                	lw	a5,0(a0)
    80003758:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000375a:	415c                	lw	a5,4(a0)
    8000375c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000375e:	04451783          	lh	a5,68(a0)
    80003762:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003766:	04a51783          	lh	a5,74(a0)
    8000376a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000376e:	04c56783          	lwu	a5,76(a0)
    80003772:	e99c                	sd	a5,16(a1)
}
    80003774:	6422                	ld	s0,8(sp)
    80003776:	0141                	addi	sp,sp,16
    80003778:	8082                	ret

000000008000377a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000377a:	457c                	lw	a5,76(a0)
    8000377c:	0cd7ef63          	bltu	a5,a3,8000385a <readi+0xe0>
{
    80003780:	7159                	addi	sp,sp,-112
    80003782:	f486                	sd	ra,104(sp)
    80003784:	f0a2                	sd	s0,96(sp)
    80003786:	eca6                	sd	s1,88(sp)
    80003788:	e8ca                	sd	s2,80(sp)
    8000378a:	e4ce                	sd	s3,72(sp)
    8000378c:	e0d2                	sd	s4,64(sp)
    8000378e:	fc56                	sd	s5,56(sp)
    80003790:	f85a                	sd	s6,48(sp)
    80003792:	f45e                	sd	s7,40(sp)
    80003794:	f062                	sd	s8,32(sp)
    80003796:	ec66                	sd	s9,24(sp)
    80003798:	e86a                	sd	s10,16(sp)
    8000379a:	e46e                	sd	s11,8(sp)
    8000379c:	1880                	addi	s0,sp,112
    8000379e:	8b2a                	mv	s6,a0
    800037a0:	8bae                	mv	s7,a1
    800037a2:	8a32                	mv	s4,a2
    800037a4:	84b6                	mv	s1,a3
    800037a6:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800037a8:	9f35                	addw	a4,a4,a3
    return 0;
    800037aa:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800037ac:	08d76663          	bltu	a4,a3,80003838 <readi+0xbe>
  if(off + n > ip->size)
    800037b0:	00e7f463          	bgeu	a5,a4,800037b8 <readi+0x3e>
    n = ip->size - off;
    800037b4:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800037b8:	080a8f63          	beqz	s5,80003856 <readi+0xdc>
    800037bc:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800037be:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800037c2:	5c7d                	li	s8,-1
    800037c4:	a80d                	j	800037f6 <readi+0x7c>
    800037c6:	020d1d93          	slli	s11,s10,0x20
    800037ca:	020ddd93          	srli	s11,s11,0x20
    800037ce:	05890793          	addi	a5,s2,88
    800037d2:	86ee                	mv	a3,s11
    800037d4:	963e                	add	a2,a2,a5
    800037d6:	85d2                	mv	a1,s4
    800037d8:	855e                	mv	a0,s7
    800037da:	c91fe0ef          	jal	ra,8000246a <either_copyout>
    800037de:	05850763          	beq	a0,s8,8000382c <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800037e2:	854a                	mv	a0,s2
    800037e4:	e60ff0ef          	jal	ra,80002e44 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800037e8:	013d09bb          	addw	s3,s10,s3
    800037ec:	009d04bb          	addw	s1,s10,s1
    800037f0:	9a6e                	add	s4,s4,s11
    800037f2:	0559f163          	bgeu	s3,s5,80003834 <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    800037f6:	00a4d59b          	srliw	a1,s1,0xa
    800037fa:	855a                	mv	a0,s6
    800037fc:	8bbff0ef          	jal	ra,800030b6 <bmap>
    80003800:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003804:	c985                	beqz	a1,80003834 <readi+0xba>
    bp = bread(ip->dev, addr);
    80003806:	000b2503          	lw	a0,0(s6)
    8000380a:	d32ff0ef          	jal	ra,80002d3c <bread>
    8000380e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003810:	3ff4f613          	andi	a2,s1,1023
    80003814:	40cc87bb          	subw	a5,s9,a2
    80003818:	413a873b          	subw	a4,s5,s3
    8000381c:	8d3e                	mv	s10,a5
    8000381e:	2781                	sext.w	a5,a5
    80003820:	0007069b          	sext.w	a3,a4
    80003824:	faf6f1e3          	bgeu	a3,a5,800037c6 <readi+0x4c>
    80003828:	8d3a                	mv	s10,a4
    8000382a:	bf71                	j	800037c6 <readi+0x4c>
      brelse(bp);
    8000382c:	854a                	mv	a0,s2
    8000382e:	e16ff0ef          	jal	ra,80002e44 <brelse>
      tot = -1;
    80003832:	59fd                	li	s3,-1
  }
  return tot;
    80003834:	0009851b          	sext.w	a0,s3
}
    80003838:	70a6                	ld	ra,104(sp)
    8000383a:	7406                	ld	s0,96(sp)
    8000383c:	64e6                	ld	s1,88(sp)
    8000383e:	6946                	ld	s2,80(sp)
    80003840:	69a6                	ld	s3,72(sp)
    80003842:	6a06                	ld	s4,64(sp)
    80003844:	7ae2                	ld	s5,56(sp)
    80003846:	7b42                	ld	s6,48(sp)
    80003848:	7ba2                	ld	s7,40(sp)
    8000384a:	7c02                	ld	s8,32(sp)
    8000384c:	6ce2                	ld	s9,24(sp)
    8000384e:	6d42                	ld	s10,16(sp)
    80003850:	6da2                	ld	s11,8(sp)
    80003852:	6165                	addi	sp,sp,112
    80003854:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003856:	89d6                	mv	s3,s5
    80003858:	bff1                	j	80003834 <readi+0xba>
    return 0;
    8000385a:	4501                	li	a0,0
}
    8000385c:	8082                	ret

000000008000385e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000385e:	457c                	lw	a5,76(a0)
    80003860:	0ed7ea63          	bltu	a5,a3,80003954 <writei+0xf6>
{
    80003864:	7159                	addi	sp,sp,-112
    80003866:	f486                	sd	ra,104(sp)
    80003868:	f0a2                	sd	s0,96(sp)
    8000386a:	eca6                	sd	s1,88(sp)
    8000386c:	e8ca                	sd	s2,80(sp)
    8000386e:	e4ce                	sd	s3,72(sp)
    80003870:	e0d2                	sd	s4,64(sp)
    80003872:	fc56                	sd	s5,56(sp)
    80003874:	f85a                	sd	s6,48(sp)
    80003876:	f45e                	sd	s7,40(sp)
    80003878:	f062                	sd	s8,32(sp)
    8000387a:	ec66                	sd	s9,24(sp)
    8000387c:	e86a                	sd	s10,16(sp)
    8000387e:	e46e                	sd	s11,8(sp)
    80003880:	1880                	addi	s0,sp,112
    80003882:	8aaa                	mv	s5,a0
    80003884:	8bae                	mv	s7,a1
    80003886:	8a32                	mv	s4,a2
    80003888:	8936                	mv	s2,a3
    8000388a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000388c:	00e687bb          	addw	a5,a3,a4
    80003890:	0cd7e463          	bltu	a5,a3,80003958 <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003894:	00043737          	lui	a4,0x43
    80003898:	0cf76263          	bltu	a4,a5,8000395c <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000389c:	0a0b0a63          	beqz	s6,80003950 <writei+0xf2>
    800038a0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800038a2:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800038a6:	5c7d                	li	s8,-1
    800038a8:	a825                	j	800038e0 <writei+0x82>
    800038aa:	020d1d93          	slli	s11,s10,0x20
    800038ae:	020ddd93          	srli	s11,s11,0x20
    800038b2:	05848793          	addi	a5,s1,88
    800038b6:	86ee                	mv	a3,s11
    800038b8:	8652                	mv	a2,s4
    800038ba:	85de                	mv	a1,s7
    800038bc:	953e                	add	a0,a0,a5
    800038be:	bf7fe0ef          	jal	ra,800024b4 <either_copyin>
    800038c2:	05850a63          	beq	a0,s8,80003916 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    800038c6:	8526                	mv	a0,s1
    800038c8:	688000ef          	jal	ra,80003f50 <log_write>
    brelse(bp);
    800038cc:	8526                	mv	a0,s1
    800038ce:	d76ff0ef          	jal	ra,80002e44 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800038d2:	013d09bb          	addw	s3,s10,s3
    800038d6:	012d093b          	addw	s2,s10,s2
    800038da:	9a6e                	add	s4,s4,s11
    800038dc:	0569f063          	bgeu	s3,s6,8000391c <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800038e0:	00a9559b          	srliw	a1,s2,0xa
    800038e4:	8556                	mv	a0,s5
    800038e6:	fd0ff0ef          	jal	ra,800030b6 <bmap>
    800038ea:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800038ee:	c59d                	beqz	a1,8000391c <writei+0xbe>
    bp = bread(ip->dev, addr);
    800038f0:	000aa503          	lw	a0,0(s5)
    800038f4:	c48ff0ef          	jal	ra,80002d3c <bread>
    800038f8:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800038fa:	3ff97513          	andi	a0,s2,1023
    800038fe:	40ac87bb          	subw	a5,s9,a0
    80003902:	413b073b          	subw	a4,s6,s3
    80003906:	8d3e                	mv	s10,a5
    80003908:	2781                	sext.w	a5,a5
    8000390a:	0007069b          	sext.w	a3,a4
    8000390e:	f8f6fee3          	bgeu	a3,a5,800038aa <writei+0x4c>
    80003912:	8d3a                	mv	s10,a4
    80003914:	bf59                	j	800038aa <writei+0x4c>
      brelse(bp);
    80003916:	8526                	mv	a0,s1
    80003918:	d2cff0ef          	jal	ra,80002e44 <brelse>
  }

  if(off > ip->size)
    8000391c:	04caa783          	lw	a5,76(s5)
    80003920:	0127f463          	bgeu	a5,s2,80003928 <writei+0xca>
    ip->size = off;
    80003924:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003928:	8556                	mv	a0,s5
    8000392a:	a13ff0ef          	jal	ra,8000333c <iupdate>

  return tot;
    8000392e:	0009851b          	sext.w	a0,s3
}
    80003932:	70a6                	ld	ra,104(sp)
    80003934:	7406                	ld	s0,96(sp)
    80003936:	64e6                	ld	s1,88(sp)
    80003938:	6946                	ld	s2,80(sp)
    8000393a:	69a6                	ld	s3,72(sp)
    8000393c:	6a06                	ld	s4,64(sp)
    8000393e:	7ae2                	ld	s5,56(sp)
    80003940:	7b42                	ld	s6,48(sp)
    80003942:	7ba2                	ld	s7,40(sp)
    80003944:	7c02                	ld	s8,32(sp)
    80003946:	6ce2                	ld	s9,24(sp)
    80003948:	6d42                	ld	s10,16(sp)
    8000394a:	6da2                	ld	s11,8(sp)
    8000394c:	6165                	addi	sp,sp,112
    8000394e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003950:	89da                	mv	s3,s6
    80003952:	bfd9                	j	80003928 <writei+0xca>
    return -1;
    80003954:	557d                	li	a0,-1
}
    80003956:	8082                	ret
    return -1;
    80003958:	557d                	li	a0,-1
    8000395a:	bfe1                	j	80003932 <writei+0xd4>
    return -1;
    8000395c:	557d                	li	a0,-1
    8000395e:	bfd1                	j	80003932 <writei+0xd4>

0000000080003960 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003960:	1141                	addi	sp,sp,-16
    80003962:	e406                	sd	ra,8(sp)
    80003964:	e022                	sd	s0,0(sp)
    80003966:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003968:	4639                	li	a2,14
    8000396a:	ba2fd0ef          	jal	ra,80000d0c <strncmp>
}
    8000396e:	60a2                	ld	ra,8(sp)
    80003970:	6402                	ld	s0,0(sp)
    80003972:	0141                	addi	sp,sp,16
    80003974:	8082                	ret

0000000080003976 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003976:	7139                	addi	sp,sp,-64
    80003978:	fc06                	sd	ra,56(sp)
    8000397a:	f822                	sd	s0,48(sp)
    8000397c:	f426                	sd	s1,40(sp)
    8000397e:	f04a                	sd	s2,32(sp)
    80003980:	ec4e                	sd	s3,24(sp)
    80003982:	e852                	sd	s4,16(sp)
    80003984:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003986:	04451703          	lh	a4,68(a0)
    8000398a:	4785                	li	a5,1
    8000398c:	00f71a63          	bne	a4,a5,800039a0 <dirlookup+0x2a>
    80003990:	892a                	mv	s2,a0
    80003992:	89ae                	mv	s3,a1
    80003994:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003996:	457c                	lw	a5,76(a0)
    80003998:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000399a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000399c:	e39d                	bnez	a5,800039c2 <dirlookup+0x4c>
    8000399e:	a095                	j	80003a02 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    800039a0:	00004517          	auipc	a0,0x4
    800039a4:	ed850513          	addi	a0,a0,-296 # 80007878 <syscalls+0x1c0>
    800039a8:	de3fc0ef          	jal	ra,8000078a <panic>
      panic("dirlookup read");
    800039ac:	00004517          	auipc	a0,0x4
    800039b0:	ee450513          	addi	a0,a0,-284 # 80007890 <syscalls+0x1d8>
    800039b4:	dd7fc0ef          	jal	ra,8000078a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800039b8:	24c1                	addiw	s1,s1,16
    800039ba:	04c92783          	lw	a5,76(s2)
    800039be:	04f4f163          	bgeu	s1,a5,80003a00 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039c2:	4741                	li	a4,16
    800039c4:	86a6                	mv	a3,s1
    800039c6:	fc040613          	addi	a2,s0,-64
    800039ca:	4581                	li	a1,0
    800039cc:	854a                	mv	a0,s2
    800039ce:	dadff0ef          	jal	ra,8000377a <readi>
    800039d2:	47c1                	li	a5,16
    800039d4:	fcf51ce3          	bne	a0,a5,800039ac <dirlookup+0x36>
    if(de.inum == 0)
    800039d8:	fc045783          	lhu	a5,-64(s0)
    800039dc:	dff1                	beqz	a5,800039b8 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    800039de:	fc240593          	addi	a1,s0,-62
    800039e2:	854e                	mv	a0,s3
    800039e4:	f7dff0ef          	jal	ra,80003960 <namecmp>
    800039e8:	f961                	bnez	a0,800039b8 <dirlookup+0x42>
      if(poff)
    800039ea:	000a0463          	beqz	s4,800039f2 <dirlookup+0x7c>
        *poff = off;
    800039ee:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800039f2:	fc045583          	lhu	a1,-64(s0)
    800039f6:	00092503          	lw	a0,0(s2)
    800039fa:	f88ff0ef          	jal	ra,80003182 <iget>
    800039fe:	a011                	j	80003a02 <dirlookup+0x8c>
  return 0;
    80003a00:	4501                	li	a0,0
}
    80003a02:	70e2                	ld	ra,56(sp)
    80003a04:	7442                	ld	s0,48(sp)
    80003a06:	74a2                	ld	s1,40(sp)
    80003a08:	7902                	ld	s2,32(sp)
    80003a0a:	69e2                	ld	s3,24(sp)
    80003a0c:	6a42                	ld	s4,16(sp)
    80003a0e:	6121                	addi	sp,sp,64
    80003a10:	8082                	ret

0000000080003a12 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003a12:	711d                	addi	sp,sp,-96
    80003a14:	ec86                	sd	ra,88(sp)
    80003a16:	e8a2                	sd	s0,80(sp)
    80003a18:	e4a6                	sd	s1,72(sp)
    80003a1a:	e0ca                	sd	s2,64(sp)
    80003a1c:	fc4e                	sd	s3,56(sp)
    80003a1e:	f852                	sd	s4,48(sp)
    80003a20:	f456                	sd	s5,40(sp)
    80003a22:	f05a                	sd	s6,32(sp)
    80003a24:	ec5e                	sd	s7,24(sp)
    80003a26:	e862                	sd	s8,16(sp)
    80003a28:	e466                	sd	s9,8(sp)
    80003a2a:	1080                	addi	s0,sp,96
    80003a2c:	84aa                	mv	s1,a0
    80003a2e:	8aae                	mv	s5,a1
    80003a30:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003a32:	00054703          	lbu	a4,0(a0)
    80003a36:	02f00793          	li	a5,47
    80003a3a:	00f70f63          	beq	a4,a5,80003a58 <namex+0x46>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003a3e:	8befe0ef          	jal	ra,80001afc <myproc>
    80003a42:	15053503          	ld	a0,336(a0)
    80003a46:	973ff0ef          	jal	ra,800033b8 <idup>
    80003a4a:	89aa                	mv	s3,a0
  while(*path == '/')
    80003a4c:	02f00913          	li	s2,47
  len = path - s;
    80003a50:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003a52:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003a54:	4b85                	li	s7,1
    80003a56:	a861                	j	80003aee <namex+0xdc>
    ip = iget(ROOTDEV, ROOTINO);
    80003a58:	4585                	li	a1,1
    80003a5a:	4505                	li	a0,1
    80003a5c:	f26ff0ef          	jal	ra,80003182 <iget>
    80003a60:	89aa                	mv	s3,a0
    80003a62:	b7ed                	j	80003a4c <namex+0x3a>
      iunlockput(ip);
    80003a64:	854e                	mv	a0,s3
    80003a66:	b8fff0ef          	jal	ra,800035f4 <iunlockput>
      return 0;
    80003a6a:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003a6c:	854e                	mv	a0,s3
    80003a6e:	60e6                	ld	ra,88(sp)
    80003a70:	6446                	ld	s0,80(sp)
    80003a72:	64a6                	ld	s1,72(sp)
    80003a74:	6906                	ld	s2,64(sp)
    80003a76:	79e2                	ld	s3,56(sp)
    80003a78:	7a42                	ld	s4,48(sp)
    80003a7a:	7aa2                	ld	s5,40(sp)
    80003a7c:	7b02                	ld	s6,32(sp)
    80003a7e:	6be2                	ld	s7,24(sp)
    80003a80:	6c42                	ld	s8,16(sp)
    80003a82:	6ca2                	ld	s9,8(sp)
    80003a84:	6125                	addi	sp,sp,96
    80003a86:	8082                	ret
      iunlock(ip);
    80003a88:	854e                	mv	a0,s3
    80003a8a:	a0fff0ef          	jal	ra,80003498 <iunlock>
      return ip;
    80003a8e:	bff9                	j	80003a6c <namex+0x5a>
      iunlockput(ip);
    80003a90:	854e                	mv	a0,s3
    80003a92:	b63ff0ef          	jal	ra,800035f4 <iunlockput>
      return 0;
    80003a96:	89e6                	mv	s3,s9
    80003a98:	bfd1                	j	80003a6c <namex+0x5a>
  len = path - s;
    80003a9a:	40b48633          	sub	a2,s1,a1
    80003a9e:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003aa2:	079c5c63          	bge	s8,s9,80003b1a <namex+0x108>
    memmove(name, s, DIRSIZ);
    80003aa6:	4639                	li	a2,14
    80003aa8:	8552                	mv	a0,s4
    80003aaa:	9f2fd0ef          	jal	ra,80000c9c <memmove>
  while(*path == '/')
    80003aae:	0004c783          	lbu	a5,0(s1)
    80003ab2:	01279763          	bne	a5,s2,80003ac0 <namex+0xae>
    path++;
    80003ab6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ab8:	0004c783          	lbu	a5,0(s1)
    80003abc:	ff278de3          	beq	a5,s2,80003ab6 <namex+0xa4>
    ilock(ip);
    80003ac0:	854e                	mv	a0,s3
    80003ac2:	92dff0ef          	jal	ra,800033ee <ilock>
    if(ip->type != T_DIR){
    80003ac6:	04499783          	lh	a5,68(s3)
    80003aca:	f9779de3          	bne	a5,s7,80003a64 <namex+0x52>
    if(nameiparent && *path == '\0'){
    80003ace:	000a8563          	beqz	s5,80003ad8 <namex+0xc6>
    80003ad2:	0004c783          	lbu	a5,0(s1)
    80003ad6:	dbcd                	beqz	a5,80003a88 <namex+0x76>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003ad8:	865a                	mv	a2,s6
    80003ada:	85d2                	mv	a1,s4
    80003adc:	854e                	mv	a0,s3
    80003ade:	e99ff0ef          	jal	ra,80003976 <dirlookup>
    80003ae2:	8caa                	mv	s9,a0
    80003ae4:	d555                	beqz	a0,80003a90 <namex+0x7e>
    iunlockput(ip);
    80003ae6:	854e                	mv	a0,s3
    80003ae8:	b0dff0ef          	jal	ra,800035f4 <iunlockput>
    ip = next;
    80003aec:	89e6                	mv	s3,s9
  while(*path == '/')
    80003aee:	0004c783          	lbu	a5,0(s1)
    80003af2:	05279363          	bne	a5,s2,80003b38 <namex+0x126>
    path++;
    80003af6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003af8:	0004c783          	lbu	a5,0(s1)
    80003afc:	ff278de3          	beq	a5,s2,80003af6 <namex+0xe4>
  if(*path == 0)
    80003b00:	c78d                	beqz	a5,80003b2a <namex+0x118>
    path++;
    80003b02:	85a6                	mv	a1,s1
  len = path - s;
    80003b04:	8cda                	mv	s9,s6
    80003b06:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003b08:	01278963          	beq	a5,s2,80003b1a <namex+0x108>
    80003b0c:	d7d9                	beqz	a5,80003a9a <namex+0x88>
    path++;
    80003b0e:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003b10:	0004c783          	lbu	a5,0(s1)
    80003b14:	ff279ce3          	bne	a5,s2,80003b0c <namex+0xfa>
    80003b18:	b749                	j	80003a9a <namex+0x88>
    memmove(name, s, len);
    80003b1a:	2601                	sext.w	a2,a2
    80003b1c:	8552                	mv	a0,s4
    80003b1e:	97efd0ef          	jal	ra,80000c9c <memmove>
    name[len] = 0;
    80003b22:	9cd2                	add	s9,s9,s4
    80003b24:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003b28:	b759                	j	80003aae <namex+0x9c>
  if(nameiparent){
    80003b2a:	f40a81e3          	beqz	s5,80003a6c <namex+0x5a>
    iput(ip);
    80003b2e:	854e                	mv	a0,s3
    80003b30:	a3dff0ef          	jal	ra,8000356c <iput>
    return 0;
    80003b34:	4981                	li	s3,0
    80003b36:	bf1d                	j	80003a6c <namex+0x5a>
  if(*path == 0)
    80003b38:	dbed                	beqz	a5,80003b2a <namex+0x118>
  while(*path != '/' && *path != 0)
    80003b3a:	0004c783          	lbu	a5,0(s1)
    80003b3e:	85a6                	mv	a1,s1
    80003b40:	b7f1                	j	80003b0c <namex+0xfa>

0000000080003b42 <dirlink>:
{
    80003b42:	7139                	addi	sp,sp,-64
    80003b44:	fc06                	sd	ra,56(sp)
    80003b46:	f822                	sd	s0,48(sp)
    80003b48:	f426                	sd	s1,40(sp)
    80003b4a:	f04a                	sd	s2,32(sp)
    80003b4c:	ec4e                	sd	s3,24(sp)
    80003b4e:	e852                	sd	s4,16(sp)
    80003b50:	0080                	addi	s0,sp,64
    80003b52:	892a                	mv	s2,a0
    80003b54:	8a2e                	mv	s4,a1
    80003b56:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003b58:	4601                	li	a2,0
    80003b5a:	e1dff0ef          	jal	ra,80003976 <dirlookup>
    80003b5e:	e52d                	bnez	a0,80003bc8 <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b60:	04c92483          	lw	s1,76(s2)
    80003b64:	c48d                	beqz	s1,80003b8e <dirlink+0x4c>
    80003b66:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b68:	4741                	li	a4,16
    80003b6a:	86a6                	mv	a3,s1
    80003b6c:	fc040613          	addi	a2,s0,-64
    80003b70:	4581                	li	a1,0
    80003b72:	854a                	mv	a0,s2
    80003b74:	c07ff0ef          	jal	ra,8000377a <readi>
    80003b78:	47c1                	li	a5,16
    80003b7a:	04f51b63          	bne	a0,a5,80003bd0 <dirlink+0x8e>
    if(de.inum == 0)
    80003b7e:	fc045783          	lhu	a5,-64(s0)
    80003b82:	c791                	beqz	a5,80003b8e <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b84:	24c1                	addiw	s1,s1,16
    80003b86:	04c92783          	lw	a5,76(s2)
    80003b8a:	fcf4efe3          	bltu	s1,a5,80003b68 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003b8e:	4639                	li	a2,14
    80003b90:	85d2                	mv	a1,s4
    80003b92:	fc240513          	addi	a0,s0,-62
    80003b96:	9b2fd0ef          	jal	ra,80000d48 <strncpy>
  de.inum = inum;
    80003b9a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b9e:	4741                	li	a4,16
    80003ba0:	86a6                	mv	a3,s1
    80003ba2:	fc040613          	addi	a2,s0,-64
    80003ba6:	4581                	li	a1,0
    80003ba8:	854a                	mv	a0,s2
    80003baa:	cb5ff0ef          	jal	ra,8000385e <writei>
    80003bae:	1541                	addi	a0,a0,-16
    80003bb0:	00a03533          	snez	a0,a0
    80003bb4:	40a00533          	neg	a0,a0
}
    80003bb8:	70e2                	ld	ra,56(sp)
    80003bba:	7442                	ld	s0,48(sp)
    80003bbc:	74a2                	ld	s1,40(sp)
    80003bbe:	7902                	ld	s2,32(sp)
    80003bc0:	69e2                	ld	s3,24(sp)
    80003bc2:	6a42                	ld	s4,16(sp)
    80003bc4:	6121                	addi	sp,sp,64
    80003bc6:	8082                	ret
    iput(ip);
    80003bc8:	9a5ff0ef          	jal	ra,8000356c <iput>
    return -1;
    80003bcc:	557d                	li	a0,-1
    80003bce:	b7ed                	j	80003bb8 <dirlink+0x76>
      panic("dirlink read");
    80003bd0:	00004517          	auipc	a0,0x4
    80003bd4:	cd050513          	addi	a0,a0,-816 # 800078a0 <syscalls+0x1e8>
    80003bd8:	bb3fc0ef          	jal	ra,8000078a <panic>

0000000080003bdc <namei>:

struct inode*
namei(char *path)
{
    80003bdc:	1101                	addi	sp,sp,-32
    80003bde:	ec06                	sd	ra,24(sp)
    80003be0:	e822                	sd	s0,16(sp)
    80003be2:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003be4:	fe040613          	addi	a2,s0,-32
    80003be8:	4581                	li	a1,0
    80003bea:	e29ff0ef          	jal	ra,80003a12 <namex>
}
    80003bee:	60e2                	ld	ra,24(sp)
    80003bf0:	6442                	ld	s0,16(sp)
    80003bf2:	6105                	addi	sp,sp,32
    80003bf4:	8082                	ret

0000000080003bf6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003bf6:	1141                	addi	sp,sp,-16
    80003bf8:	e406                	sd	ra,8(sp)
    80003bfa:	e022                	sd	s0,0(sp)
    80003bfc:	0800                	addi	s0,sp,16
    80003bfe:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003c00:	4585                	li	a1,1
    80003c02:	e11ff0ef          	jal	ra,80003a12 <namex>
}
    80003c06:	60a2                	ld	ra,8(sp)
    80003c08:	6402                	ld	s0,0(sp)
    80003c0a:	0141                	addi	sp,sp,16
    80003c0c:	8082                	ret

0000000080003c0e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003c0e:	1101                	addi	sp,sp,-32
    80003c10:	ec06                	sd	ra,24(sp)
    80003c12:	e822                	sd	s0,16(sp)
    80003c14:	e426                	sd	s1,8(sp)
    80003c16:	e04a                	sd	s2,0(sp)
    80003c18:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003c1a:	0001d917          	auipc	s2,0x1d
    80003c1e:	eae90913          	addi	s2,s2,-338 # 80020ac8 <log>
    80003c22:	01892583          	lw	a1,24(s2)
    80003c26:	02492503          	lw	a0,36(s2)
    80003c2a:	912ff0ef          	jal	ra,80002d3c <bread>
    80003c2e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003c30:	02892683          	lw	a3,40(s2)
    80003c34:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003c36:	02d05763          	blez	a3,80003c64 <write_head+0x56>
    80003c3a:	0001d797          	auipc	a5,0x1d
    80003c3e:	eba78793          	addi	a5,a5,-326 # 80020af4 <log+0x2c>
    80003c42:	05c50713          	addi	a4,a0,92
    80003c46:	36fd                	addiw	a3,a3,-1
    80003c48:	1682                	slli	a3,a3,0x20
    80003c4a:	9281                	srli	a3,a3,0x20
    80003c4c:	068a                	slli	a3,a3,0x2
    80003c4e:	0001d617          	auipc	a2,0x1d
    80003c52:	eaa60613          	addi	a2,a2,-342 # 80020af8 <log+0x30>
    80003c56:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003c58:	4390                	lw	a2,0(a5)
    80003c5a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003c5c:	0791                	addi	a5,a5,4
    80003c5e:	0711                	addi	a4,a4,4
    80003c60:	fed79ce3          	bne	a5,a3,80003c58 <write_head+0x4a>
  }
  bwrite(buf);
    80003c64:	8526                	mv	a0,s1
    80003c66:	9acff0ef          	jal	ra,80002e12 <bwrite>
  brelse(buf);
    80003c6a:	8526                	mv	a0,s1
    80003c6c:	9d8ff0ef          	jal	ra,80002e44 <brelse>
}
    80003c70:	60e2                	ld	ra,24(sp)
    80003c72:	6442                	ld	s0,16(sp)
    80003c74:	64a2                	ld	s1,8(sp)
    80003c76:	6902                	ld	s2,0(sp)
    80003c78:	6105                	addi	sp,sp,32
    80003c7a:	8082                	ret

0000000080003c7c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c7c:	0001d797          	auipc	a5,0x1d
    80003c80:	e747a783          	lw	a5,-396(a5) # 80020af0 <log+0x28>
    80003c84:	0af05e63          	blez	a5,80003d40 <install_trans+0xc4>
{
    80003c88:	715d                	addi	sp,sp,-80
    80003c8a:	e486                	sd	ra,72(sp)
    80003c8c:	e0a2                	sd	s0,64(sp)
    80003c8e:	fc26                	sd	s1,56(sp)
    80003c90:	f84a                	sd	s2,48(sp)
    80003c92:	f44e                	sd	s3,40(sp)
    80003c94:	f052                	sd	s4,32(sp)
    80003c96:	ec56                	sd	s5,24(sp)
    80003c98:	e85a                	sd	s6,16(sp)
    80003c9a:	e45e                	sd	s7,8(sp)
    80003c9c:	0880                	addi	s0,sp,80
    80003c9e:	8b2a                	mv	s6,a0
    80003ca0:	0001da97          	auipc	s5,0x1d
    80003ca4:	e54a8a93          	addi	s5,s5,-428 # 80020af4 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ca8:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003caa:	00004b97          	auipc	s7,0x4
    80003cae:	c06b8b93          	addi	s7,s7,-1018 # 800078b0 <syscalls+0x1f8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003cb2:	0001da17          	auipc	s4,0x1d
    80003cb6:	e16a0a13          	addi	s4,s4,-490 # 80020ac8 <log>
    80003cba:	a025                	j	80003ce2 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003cbc:	000aa603          	lw	a2,0(s5)
    80003cc0:	85ce                	mv	a1,s3
    80003cc2:	855e                	mv	a0,s7
    80003cc4:	801fc0ef          	jal	ra,800004c4 <printf>
    80003cc8:	a839                	j	80003ce6 <install_trans+0x6a>
    brelse(lbuf);
    80003cca:	854a                	mv	a0,s2
    80003ccc:	978ff0ef          	jal	ra,80002e44 <brelse>
    brelse(dbuf);
    80003cd0:	8526                	mv	a0,s1
    80003cd2:	972ff0ef          	jal	ra,80002e44 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cd6:	2985                	addiw	s3,s3,1
    80003cd8:	0a91                	addi	s5,s5,4
    80003cda:	028a2783          	lw	a5,40(s4)
    80003cde:	04f9d663          	bge	s3,a5,80003d2a <install_trans+0xae>
    if(recovering) {
    80003ce2:	fc0b1de3          	bnez	s6,80003cbc <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003ce6:	018a2583          	lw	a1,24(s4)
    80003cea:	013585bb          	addw	a1,a1,s3
    80003cee:	2585                	addiw	a1,a1,1
    80003cf0:	024a2503          	lw	a0,36(s4)
    80003cf4:	848ff0ef          	jal	ra,80002d3c <bread>
    80003cf8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003cfa:	000aa583          	lw	a1,0(s5)
    80003cfe:	024a2503          	lw	a0,36(s4)
    80003d02:	83aff0ef          	jal	ra,80002d3c <bread>
    80003d06:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003d08:	40000613          	li	a2,1024
    80003d0c:	05890593          	addi	a1,s2,88
    80003d10:	05850513          	addi	a0,a0,88
    80003d14:	f89fc0ef          	jal	ra,80000c9c <memmove>
    bwrite(dbuf);  // write dst to disk
    80003d18:	8526                	mv	a0,s1
    80003d1a:	8f8ff0ef          	jal	ra,80002e12 <bwrite>
    if(recovering == 0)
    80003d1e:	fa0b16e3          	bnez	s6,80003cca <install_trans+0x4e>
      bunpin(dbuf);
    80003d22:	8526                	mv	a0,s1
    80003d24:	9deff0ef          	jal	ra,80002f02 <bunpin>
    80003d28:	b74d                	j	80003cca <install_trans+0x4e>
}
    80003d2a:	60a6                	ld	ra,72(sp)
    80003d2c:	6406                	ld	s0,64(sp)
    80003d2e:	74e2                	ld	s1,56(sp)
    80003d30:	7942                	ld	s2,48(sp)
    80003d32:	79a2                	ld	s3,40(sp)
    80003d34:	7a02                	ld	s4,32(sp)
    80003d36:	6ae2                	ld	s5,24(sp)
    80003d38:	6b42                	ld	s6,16(sp)
    80003d3a:	6ba2                	ld	s7,8(sp)
    80003d3c:	6161                	addi	sp,sp,80
    80003d3e:	8082                	ret
    80003d40:	8082                	ret

0000000080003d42 <initlog>:
{
    80003d42:	7179                	addi	sp,sp,-48
    80003d44:	f406                	sd	ra,40(sp)
    80003d46:	f022                	sd	s0,32(sp)
    80003d48:	ec26                	sd	s1,24(sp)
    80003d4a:	e84a                	sd	s2,16(sp)
    80003d4c:	e44e                	sd	s3,8(sp)
    80003d4e:	1800                	addi	s0,sp,48
    80003d50:	892a                	mv	s2,a0
    80003d52:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003d54:	0001d497          	auipc	s1,0x1d
    80003d58:	d7448493          	addi	s1,s1,-652 # 80020ac8 <log>
    80003d5c:	00004597          	auipc	a1,0x4
    80003d60:	b7458593          	addi	a1,a1,-1164 # 800078d0 <syscalls+0x218>
    80003d64:	8526                	mv	a0,s1
    80003d66:	d87fc0ef          	jal	ra,80000aec <initlock>
  log.start = sb->logstart;
    80003d6a:	0149a583          	lw	a1,20(s3)
    80003d6e:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003d70:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003d74:	854a                	mv	a0,s2
    80003d76:	fc7fe0ef          	jal	ra,80002d3c <bread>
  log.lh.n = lh->n;
    80003d7a:	4d34                	lw	a3,88(a0)
    80003d7c:	d494                	sw	a3,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003d7e:	02d05563          	blez	a3,80003da8 <initlog+0x66>
    80003d82:	05c50793          	addi	a5,a0,92
    80003d86:	0001d717          	auipc	a4,0x1d
    80003d8a:	d6e70713          	addi	a4,a4,-658 # 80020af4 <log+0x2c>
    80003d8e:	36fd                	addiw	a3,a3,-1
    80003d90:	1682                	slli	a3,a3,0x20
    80003d92:	9281                	srli	a3,a3,0x20
    80003d94:	068a                	slli	a3,a3,0x2
    80003d96:	06050613          	addi	a2,a0,96
    80003d9a:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80003d9c:	4390                	lw	a2,0(a5)
    80003d9e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003da0:	0791                	addi	a5,a5,4
    80003da2:	0711                	addi	a4,a4,4
    80003da4:	fed79ce3          	bne	a5,a3,80003d9c <initlog+0x5a>
  brelse(buf);
    80003da8:	89cff0ef          	jal	ra,80002e44 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003dac:	4505                	li	a0,1
    80003dae:	ecfff0ef          	jal	ra,80003c7c <install_trans>
  log.lh.n = 0;
    80003db2:	0001d797          	auipc	a5,0x1d
    80003db6:	d207af23          	sw	zero,-706(a5) # 80020af0 <log+0x28>
  write_head(); // clear the log
    80003dba:	e55ff0ef          	jal	ra,80003c0e <write_head>
}
    80003dbe:	70a2                	ld	ra,40(sp)
    80003dc0:	7402                	ld	s0,32(sp)
    80003dc2:	64e2                	ld	s1,24(sp)
    80003dc4:	6942                	ld	s2,16(sp)
    80003dc6:	69a2                	ld	s3,8(sp)
    80003dc8:	6145                	addi	sp,sp,48
    80003dca:	8082                	ret

0000000080003dcc <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003dcc:	1101                	addi	sp,sp,-32
    80003dce:	ec06                	sd	ra,24(sp)
    80003dd0:	e822                	sd	s0,16(sp)
    80003dd2:	e426                	sd	s1,8(sp)
    80003dd4:	e04a                	sd	s2,0(sp)
    80003dd6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003dd8:	0001d517          	auipc	a0,0x1d
    80003ddc:	cf050513          	addi	a0,a0,-784 # 80020ac8 <log>
    80003de0:	d8dfc0ef          	jal	ra,80000b6c <acquire>
  while(1){
    if(log.committing){
    80003de4:	0001d497          	auipc	s1,0x1d
    80003de8:	ce448493          	addi	s1,s1,-796 # 80020ac8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003dec:	4979                	li	s2,30
    80003dee:	a029                	j	80003df8 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003df0:	85a6                	mv	a1,s1
    80003df2:	8526                	mv	a0,s1
    80003df4:	b1afe0ef          	jal	ra,8000210e <sleep>
    if(log.committing){
    80003df8:	509c                	lw	a5,32(s1)
    80003dfa:	fbfd                	bnez	a5,80003df0 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003dfc:	4cdc                	lw	a5,28(s1)
    80003dfe:	0017871b          	addiw	a4,a5,1
    80003e02:	0007069b          	sext.w	a3,a4
    80003e06:	0027179b          	slliw	a5,a4,0x2
    80003e0a:	9fb9                	addw	a5,a5,a4
    80003e0c:	0017979b          	slliw	a5,a5,0x1
    80003e10:	5498                	lw	a4,40(s1)
    80003e12:	9fb9                	addw	a5,a5,a4
    80003e14:	00f95763          	bge	s2,a5,80003e22 <begin_op+0x56>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003e18:	85a6                	mv	a1,s1
    80003e1a:	8526                	mv	a0,s1
    80003e1c:	af2fe0ef          	jal	ra,8000210e <sleep>
    80003e20:	bfe1                	j	80003df8 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003e22:	0001d517          	auipc	a0,0x1d
    80003e26:	ca650513          	addi	a0,a0,-858 # 80020ac8 <log>
    80003e2a:	cd54                	sw	a3,28(a0)
      release(&log.lock);
    80003e2c:	dd9fc0ef          	jal	ra,80000c04 <release>
      break;
    }
  }
}
    80003e30:	60e2                	ld	ra,24(sp)
    80003e32:	6442                	ld	s0,16(sp)
    80003e34:	64a2                	ld	s1,8(sp)
    80003e36:	6902                	ld	s2,0(sp)
    80003e38:	6105                	addi	sp,sp,32
    80003e3a:	8082                	ret

0000000080003e3c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003e3c:	7139                	addi	sp,sp,-64
    80003e3e:	fc06                	sd	ra,56(sp)
    80003e40:	f822                	sd	s0,48(sp)
    80003e42:	f426                	sd	s1,40(sp)
    80003e44:	f04a                	sd	s2,32(sp)
    80003e46:	ec4e                	sd	s3,24(sp)
    80003e48:	e852                	sd	s4,16(sp)
    80003e4a:	e456                	sd	s5,8(sp)
    80003e4c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003e4e:	0001d497          	auipc	s1,0x1d
    80003e52:	c7a48493          	addi	s1,s1,-902 # 80020ac8 <log>
    80003e56:	8526                	mv	a0,s1
    80003e58:	d15fc0ef          	jal	ra,80000b6c <acquire>
  log.outstanding -= 1;
    80003e5c:	4cdc                	lw	a5,28(s1)
    80003e5e:	37fd                	addiw	a5,a5,-1
    80003e60:	0007891b          	sext.w	s2,a5
    80003e64:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003e66:	509c                	lw	a5,32(s1)
    80003e68:	ef9d                	bnez	a5,80003ea6 <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    80003e6a:	04091463          	bnez	s2,80003eb2 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003e6e:	0001d497          	auipc	s1,0x1d
    80003e72:	c5a48493          	addi	s1,s1,-934 # 80020ac8 <log>
    80003e76:	4785                	li	a5,1
    80003e78:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003e7a:	8526                	mv	a0,s1
    80003e7c:	d89fc0ef          	jal	ra,80000c04 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003e80:	549c                	lw	a5,40(s1)
    80003e82:	04f04b63          	bgtz	a5,80003ed8 <end_op+0x9c>
    acquire(&log.lock);
    80003e86:	0001d497          	auipc	s1,0x1d
    80003e8a:	c4248493          	addi	s1,s1,-958 # 80020ac8 <log>
    80003e8e:	8526                	mv	a0,s1
    80003e90:	cddfc0ef          	jal	ra,80000b6c <acquire>
    log.committing = 0;
    80003e94:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003e98:	8526                	mv	a0,s1
    80003e9a:	ac0fe0ef          	jal	ra,8000215a <wakeup>
    release(&log.lock);
    80003e9e:	8526                	mv	a0,s1
    80003ea0:	d65fc0ef          	jal	ra,80000c04 <release>
}
    80003ea4:	a00d                	j	80003ec6 <end_op+0x8a>
    panic("log.committing");
    80003ea6:	00004517          	auipc	a0,0x4
    80003eaa:	a3250513          	addi	a0,a0,-1486 # 800078d8 <syscalls+0x220>
    80003eae:	8ddfc0ef          	jal	ra,8000078a <panic>
    wakeup(&log);
    80003eb2:	0001d497          	auipc	s1,0x1d
    80003eb6:	c1648493          	addi	s1,s1,-1002 # 80020ac8 <log>
    80003eba:	8526                	mv	a0,s1
    80003ebc:	a9efe0ef          	jal	ra,8000215a <wakeup>
  release(&log.lock);
    80003ec0:	8526                	mv	a0,s1
    80003ec2:	d43fc0ef          	jal	ra,80000c04 <release>
}
    80003ec6:	70e2                	ld	ra,56(sp)
    80003ec8:	7442                	ld	s0,48(sp)
    80003eca:	74a2                	ld	s1,40(sp)
    80003ecc:	7902                	ld	s2,32(sp)
    80003ece:	69e2                	ld	s3,24(sp)
    80003ed0:	6a42                	ld	s4,16(sp)
    80003ed2:	6aa2                	ld	s5,8(sp)
    80003ed4:	6121                	addi	sp,sp,64
    80003ed6:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ed8:	0001da97          	auipc	s5,0x1d
    80003edc:	c1ca8a93          	addi	s5,s5,-996 # 80020af4 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003ee0:	0001da17          	auipc	s4,0x1d
    80003ee4:	be8a0a13          	addi	s4,s4,-1048 # 80020ac8 <log>
    80003ee8:	018a2583          	lw	a1,24(s4)
    80003eec:	012585bb          	addw	a1,a1,s2
    80003ef0:	2585                	addiw	a1,a1,1
    80003ef2:	024a2503          	lw	a0,36(s4)
    80003ef6:	e47fe0ef          	jal	ra,80002d3c <bread>
    80003efa:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003efc:	000aa583          	lw	a1,0(s5)
    80003f00:	024a2503          	lw	a0,36(s4)
    80003f04:	e39fe0ef          	jal	ra,80002d3c <bread>
    80003f08:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003f0a:	40000613          	li	a2,1024
    80003f0e:	05850593          	addi	a1,a0,88
    80003f12:	05848513          	addi	a0,s1,88
    80003f16:	d87fc0ef          	jal	ra,80000c9c <memmove>
    bwrite(to);  // write the log
    80003f1a:	8526                	mv	a0,s1
    80003f1c:	ef7fe0ef          	jal	ra,80002e12 <bwrite>
    brelse(from);
    80003f20:	854e                	mv	a0,s3
    80003f22:	f23fe0ef          	jal	ra,80002e44 <brelse>
    brelse(to);
    80003f26:	8526                	mv	a0,s1
    80003f28:	f1dfe0ef          	jal	ra,80002e44 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f2c:	2905                	addiw	s2,s2,1
    80003f2e:	0a91                	addi	s5,s5,4
    80003f30:	028a2783          	lw	a5,40(s4)
    80003f34:	faf94ae3          	blt	s2,a5,80003ee8 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003f38:	cd7ff0ef          	jal	ra,80003c0e <write_head>
    install_trans(0); // Now install writes to home locations
    80003f3c:	4501                	li	a0,0
    80003f3e:	d3fff0ef          	jal	ra,80003c7c <install_trans>
    log.lh.n = 0;
    80003f42:	0001d797          	auipc	a5,0x1d
    80003f46:	ba07a723          	sw	zero,-1106(a5) # 80020af0 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003f4a:	cc5ff0ef          	jal	ra,80003c0e <write_head>
    80003f4e:	bf25                	j	80003e86 <end_op+0x4a>

0000000080003f50 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003f50:	1101                	addi	sp,sp,-32
    80003f52:	ec06                	sd	ra,24(sp)
    80003f54:	e822                	sd	s0,16(sp)
    80003f56:	e426                	sd	s1,8(sp)
    80003f58:	e04a                	sd	s2,0(sp)
    80003f5a:	1000                	addi	s0,sp,32
    80003f5c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003f5e:	0001d917          	auipc	s2,0x1d
    80003f62:	b6a90913          	addi	s2,s2,-1174 # 80020ac8 <log>
    80003f66:	854a                	mv	a0,s2
    80003f68:	c05fc0ef          	jal	ra,80000b6c <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003f6c:	02892603          	lw	a2,40(s2)
    80003f70:	47f5                	li	a5,29
    80003f72:	04c7cc63          	blt	a5,a2,80003fca <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003f76:	0001d797          	auipc	a5,0x1d
    80003f7a:	b6e7a783          	lw	a5,-1170(a5) # 80020ae4 <log+0x1c>
    80003f7e:	04f05c63          	blez	a5,80003fd6 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003f82:	4781                	li	a5,0
    80003f84:	04c05f63          	blez	a2,80003fe2 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003f88:	44cc                	lw	a1,12(s1)
    80003f8a:	0001d717          	auipc	a4,0x1d
    80003f8e:	b6a70713          	addi	a4,a4,-1174 # 80020af4 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003f92:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003f94:	4314                	lw	a3,0(a4)
    80003f96:	04b68663          	beq	a3,a1,80003fe2 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003f9a:	2785                	addiw	a5,a5,1
    80003f9c:	0711                	addi	a4,a4,4
    80003f9e:	fef61be3          	bne	a2,a5,80003f94 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003fa2:	0621                	addi	a2,a2,8
    80003fa4:	060a                	slli	a2,a2,0x2
    80003fa6:	0001d797          	auipc	a5,0x1d
    80003faa:	b2278793          	addi	a5,a5,-1246 # 80020ac8 <log>
    80003fae:	963e                	add	a2,a2,a5
    80003fb0:	44dc                	lw	a5,12(s1)
    80003fb2:	c65c                	sw	a5,12(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003fb4:	8526                	mv	a0,s1
    80003fb6:	f19fe0ef          	jal	ra,80002ece <bpin>
    log.lh.n++;
    80003fba:	0001d717          	auipc	a4,0x1d
    80003fbe:	b0e70713          	addi	a4,a4,-1266 # 80020ac8 <log>
    80003fc2:	571c                	lw	a5,40(a4)
    80003fc4:	2785                	addiw	a5,a5,1
    80003fc6:	d71c                	sw	a5,40(a4)
    80003fc8:	a815                	j	80003ffc <log_write+0xac>
    panic("too big a transaction");
    80003fca:	00004517          	auipc	a0,0x4
    80003fce:	91e50513          	addi	a0,a0,-1762 # 800078e8 <syscalls+0x230>
    80003fd2:	fb8fc0ef          	jal	ra,8000078a <panic>
    panic("log_write outside of trans");
    80003fd6:	00004517          	auipc	a0,0x4
    80003fda:	92a50513          	addi	a0,a0,-1750 # 80007900 <syscalls+0x248>
    80003fde:	facfc0ef          	jal	ra,8000078a <panic>
  log.lh.block[i] = b->blockno;
    80003fe2:	00878713          	addi	a4,a5,8
    80003fe6:	00271693          	slli	a3,a4,0x2
    80003fea:	0001d717          	auipc	a4,0x1d
    80003fee:	ade70713          	addi	a4,a4,-1314 # 80020ac8 <log>
    80003ff2:	9736                	add	a4,a4,a3
    80003ff4:	44d4                	lw	a3,12(s1)
    80003ff6:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003ff8:	faf60ee3          	beq	a2,a5,80003fb4 <log_write+0x64>
  }
  release(&log.lock);
    80003ffc:	0001d517          	auipc	a0,0x1d
    80004000:	acc50513          	addi	a0,a0,-1332 # 80020ac8 <log>
    80004004:	c01fc0ef          	jal	ra,80000c04 <release>
}
    80004008:	60e2                	ld	ra,24(sp)
    8000400a:	6442                	ld	s0,16(sp)
    8000400c:	64a2                	ld	s1,8(sp)
    8000400e:	6902                	ld	s2,0(sp)
    80004010:	6105                	addi	sp,sp,32
    80004012:	8082                	ret

0000000080004014 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004014:	1101                	addi	sp,sp,-32
    80004016:	ec06                	sd	ra,24(sp)
    80004018:	e822                	sd	s0,16(sp)
    8000401a:	e426                	sd	s1,8(sp)
    8000401c:	e04a                	sd	s2,0(sp)
    8000401e:	1000                	addi	s0,sp,32
    80004020:	84aa                	mv	s1,a0
    80004022:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004024:	00004597          	auipc	a1,0x4
    80004028:	8fc58593          	addi	a1,a1,-1796 # 80007920 <syscalls+0x268>
    8000402c:	0521                	addi	a0,a0,8
    8000402e:	abffc0ef          	jal	ra,80000aec <initlock>
  lk->name = name;
    80004032:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004036:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000403a:	0204a423          	sw	zero,40(s1)
}
    8000403e:	60e2                	ld	ra,24(sp)
    80004040:	6442                	ld	s0,16(sp)
    80004042:	64a2                	ld	s1,8(sp)
    80004044:	6902                	ld	s2,0(sp)
    80004046:	6105                	addi	sp,sp,32
    80004048:	8082                	ret

000000008000404a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000404a:	1101                	addi	sp,sp,-32
    8000404c:	ec06                	sd	ra,24(sp)
    8000404e:	e822                	sd	s0,16(sp)
    80004050:	e426                	sd	s1,8(sp)
    80004052:	e04a                	sd	s2,0(sp)
    80004054:	1000                	addi	s0,sp,32
    80004056:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004058:	00850913          	addi	s2,a0,8
    8000405c:	854a                	mv	a0,s2
    8000405e:	b0ffc0ef          	jal	ra,80000b6c <acquire>
  while (lk->locked) {
    80004062:	409c                	lw	a5,0(s1)
    80004064:	c799                	beqz	a5,80004072 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004066:	85ca                	mv	a1,s2
    80004068:	8526                	mv	a0,s1
    8000406a:	8a4fe0ef          	jal	ra,8000210e <sleep>
  while (lk->locked) {
    8000406e:	409c                	lw	a5,0(s1)
    80004070:	fbfd                	bnez	a5,80004066 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004072:	4785                	li	a5,1
    80004074:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004076:	a87fd0ef          	jal	ra,80001afc <myproc>
    8000407a:	591c                	lw	a5,48(a0)
    8000407c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000407e:	854a                	mv	a0,s2
    80004080:	b85fc0ef          	jal	ra,80000c04 <release>
}
    80004084:	60e2                	ld	ra,24(sp)
    80004086:	6442                	ld	s0,16(sp)
    80004088:	64a2                	ld	s1,8(sp)
    8000408a:	6902                	ld	s2,0(sp)
    8000408c:	6105                	addi	sp,sp,32
    8000408e:	8082                	ret

0000000080004090 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
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
  lk->locked = 0;
    800040a8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800040ac:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800040b0:	8526                	mv	a0,s1
    800040b2:	8a8fe0ef          	jal	ra,8000215a <wakeup>
  release(&lk->lk);
    800040b6:	854a                	mv	a0,s2
    800040b8:	b4dfc0ef          	jal	ra,80000c04 <release>
}
    800040bc:	60e2                	ld	ra,24(sp)
    800040be:	6442                	ld	s0,16(sp)
    800040c0:	64a2                	ld	s1,8(sp)
    800040c2:	6902                	ld	s2,0(sp)
    800040c4:	6105                	addi	sp,sp,32
    800040c6:	8082                	ret

00000000800040c8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800040c8:	7179                	addi	sp,sp,-48
    800040ca:	f406                	sd	ra,40(sp)
    800040cc:	f022                	sd	s0,32(sp)
    800040ce:	ec26                	sd	s1,24(sp)
    800040d0:	e84a                	sd	s2,16(sp)
    800040d2:	e44e                	sd	s3,8(sp)
    800040d4:	1800                	addi	s0,sp,48
    800040d6:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800040d8:	00850913          	addi	s2,a0,8
    800040dc:	854a                	mv	a0,s2
    800040de:	a8ffc0ef          	jal	ra,80000b6c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800040e2:	409c                	lw	a5,0(s1)
    800040e4:	ef89                	bnez	a5,800040fe <holdingsleep+0x36>
    800040e6:	4481                	li	s1,0
  release(&lk->lk);
    800040e8:	854a                	mv	a0,s2
    800040ea:	b1bfc0ef          	jal	ra,80000c04 <release>
  return r;
}
    800040ee:	8526                	mv	a0,s1
    800040f0:	70a2                	ld	ra,40(sp)
    800040f2:	7402                	ld	s0,32(sp)
    800040f4:	64e2                	ld	s1,24(sp)
    800040f6:	6942                	ld	s2,16(sp)
    800040f8:	69a2                	ld	s3,8(sp)
    800040fa:	6145                	addi	sp,sp,48
    800040fc:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800040fe:	0284a983          	lw	s3,40(s1)
    80004102:	9fbfd0ef          	jal	ra,80001afc <myproc>
    80004106:	5904                	lw	s1,48(a0)
    80004108:	413484b3          	sub	s1,s1,s3
    8000410c:	0014b493          	seqz	s1,s1
    80004110:	bfe1                	j	800040e8 <holdingsleep+0x20>

0000000080004112 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004112:	1141                	addi	sp,sp,-16
    80004114:	e406                	sd	ra,8(sp)
    80004116:	e022                	sd	s0,0(sp)
    80004118:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000411a:	00004597          	auipc	a1,0x4
    8000411e:	81658593          	addi	a1,a1,-2026 # 80007930 <syscalls+0x278>
    80004122:	0001d517          	auipc	a0,0x1d
    80004126:	aee50513          	addi	a0,a0,-1298 # 80020c10 <ftable>
    8000412a:	9c3fc0ef          	jal	ra,80000aec <initlock>
}
    8000412e:	60a2                	ld	ra,8(sp)
    80004130:	6402                	ld	s0,0(sp)
    80004132:	0141                	addi	sp,sp,16
    80004134:	8082                	ret

0000000080004136 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004136:	1101                	addi	sp,sp,-32
    80004138:	ec06                	sd	ra,24(sp)
    8000413a:	e822                	sd	s0,16(sp)
    8000413c:	e426                	sd	s1,8(sp)
    8000413e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004140:	0001d517          	auipc	a0,0x1d
    80004144:	ad050513          	addi	a0,a0,-1328 # 80020c10 <ftable>
    80004148:	a25fc0ef          	jal	ra,80000b6c <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000414c:	0001d497          	auipc	s1,0x1d
    80004150:	adc48493          	addi	s1,s1,-1316 # 80020c28 <ftable+0x18>
    80004154:	0001e717          	auipc	a4,0x1e
    80004158:	a7470713          	addi	a4,a4,-1420 # 80021bc8 <disk>
    if(f->ref == 0){
    8000415c:	40dc                	lw	a5,4(s1)
    8000415e:	cf89                	beqz	a5,80004178 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004160:	02848493          	addi	s1,s1,40
    80004164:	fee49ce3          	bne	s1,a4,8000415c <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004168:	0001d517          	auipc	a0,0x1d
    8000416c:	aa850513          	addi	a0,a0,-1368 # 80020c10 <ftable>
    80004170:	a95fc0ef          	jal	ra,80000c04 <release>
  return 0;
    80004174:	4481                	li	s1,0
    80004176:	a809                	j	80004188 <filealloc+0x52>
      f->ref = 1;
    80004178:	4785                	li	a5,1
    8000417a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000417c:	0001d517          	auipc	a0,0x1d
    80004180:	a9450513          	addi	a0,a0,-1388 # 80020c10 <ftable>
    80004184:	a81fc0ef          	jal	ra,80000c04 <release>
}
    80004188:	8526                	mv	a0,s1
    8000418a:	60e2                	ld	ra,24(sp)
    8000418c:	6442                	ld	s0,16(sp)
    8000418e:	64a2                	ld	s1,8(sp)
    80004190:	6105                	addi	sp,sp,32
    80004192:	8082                	ret

0000000080004194 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004194:	1101                	addi	sp,sp,-32
    80004196:	ec06                	sd	ra,24(sp)
    80004198:	e822                	sd	s0,16(sp)
    8000419a:	e426                	sd	s1,8(sp)
    8000419c:	1000                	addi	s0,sp,32
    8000419e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800041a0:	0001d517          	auipc	a0,0x1d
    800041a4:	a7050513          	addi	a0,a0,-1424 # 80020c10 <ftable>
    800041a8:	9c5fc0ef          	jal	ra,80000b6c <acquire>
  if(f->ref < 1)
    800041ac:	40dc                	lw	a5,4(s1)
    800041ae:	02f05063          	blez	a5,800041ce <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800041b2:	2785                	addiw	a5,a5,1
    800041b4:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800041b6:	0001d517          	auipc	a0,0x1d
    800041ba:	a5a50513          	addi	a0,a0,-1446 # 80020c10 <ftable>
    800041be:	a47fc0ef          	jal	ra,80000c04 <release>
  return f;
}
    800041c2:	8526                	mv	a0,s1
    800041c4:	60e2                	ld	ra,24(sp)
    800041c6:	6442                	ld	s0,16(sp)
    800041c8:	64a2                	ld	s1,8(sp)
    800041ca:	6105                	addi	sp,sp,32
    800041cc:	8082                	ret
    panic("filedup");
    800041ce:	00003517          	auipc	a0,0x3
    800041d2:	76a50513          	addi	a0,a0,1898 # 80007938 <syscalls+0x280>
    800041d6:	db4fc0ef          	jal	ra,8000078a <panic>

00000000800041da <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800041da:	7139                	addi	sp,sp,-64
    800041dc:	fc06                	sd	ra,56(sp)
    800041de:	f822                	sd	s0,48(sp)
    800041e0:	f426                	sd	s1,40(sp)
    800041e2:	f04a                	sd	s2,32(sp)
    800041e4:	ec4e                	sd	s3,24(sp)
    800041e6:	e852                	sd	s4,16(sp)
    800041e8:	e456                	sd	s5,8(sp)
    800041ea:	0080                	addi	s0,sp,64
    800041ec:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800041ee:	0001d517          	auipc	a0,0x1d
    800041f2:	a2250513          	addi	a0,a0,-1502 # 80020c10 <ftable>
    800041f6:	977fc0ef          	jal	ra,80000b6c <acquire>
  if(f->ref < 1)
    800041fa:	40dc                	lw	a5,4(s1)
    800041fc:	04f05963          	blez	a5,8000424e <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    80004200:	37fd                	addiw	a5,a5,-1
    80004202:	0007871b          	sext.w	a4,a5
    80004206:	c0dc                	sw	a5,4(s1)
    80004208:	04e04963          	bgtz	a4,8000425a <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000420c:	0004a903          	lw	s2,0(s1)
    80004210:	0094ca83          	lbu	s5,9(s1)
    80004214:	0104ba03          	ld	s4,16(s1)
    80004218:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000421c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004220:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004224:	0001d517          	auipc	a0,0x1d
    80004228:	9ec50513          	addi	a0,a0,-1556 # 80020c10 <ftable>
    8000422c:	9d9fc0ef          	jal	ra,80000c04 <release>

  if(ff.type == FD_PIPE){
    80004230:	4785                	li	a5,1
    80004232:	04f90363          	beq	s2,a5,80004278 <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004236:	3979                	addiw	s2,s2,-2
    80004238:	4785                	li	a5,1
    8000423a:	0327e663          	bltu	a5,s2,80004266 <fileclose+0x8c>
    begin_op();
    8000423e:	b8fff0ef          	jal	ra,80003dcc <begin_op>
    iput(ff.ip);
    80004242:	854e                	mv	a0,s3
    80004244:	b28ff0ef          	jal	ra,8000356c <iput>
    end_op();
    80004248:	bf5ff0ef          	jal	ra,80003e3c <end_op>
    8000424c:	a829                	j	80004266 <fileclose+0x8c>
    panic("fileclose");
    8000424e:	00003517          	auipc	a0,0x3
    80004252:	6f250513          	addi	a0,a0,1778 # 80007940 <syscalls+0x288>
    80004256:	d34fc0ef          	jal	ra,8000078a <panic>
    release(&ftable.lock);
    8000425a:	0001d517          	auipc	a0,0x1d
    8000425e:	9b650513          	addi	a0,a0,-1610 # 80020c10 <ftable>
    80004262:	9a3fc0ef          	jal	ra,80000c04 <release>
  }
}
    80004266:	70e2                	ld	ra,56(sp)
    80004268:	7442                	ld	s0,48(sp)
    8000426a:	74a2                	ld	s1,40(sp)
    8000426c:	7902                	ld	s2,32(sp)
    8000426e:	69e2                	ld	s3,24(sp)
    80004270:	6a42                	ld	s4,16(sp)
    80004272:	6aa2                	ld	s5,8(sp)
    80004274:	6121                	addi	sp,sp,64
    80004276:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004278:	85d6                	mv	a1,s5
    8000427a:	8552                	mv	a0,s4
    8000427c:	2ec000ef          	jal	ra,80004568 <pipeclose>
    80004280:	b7dd                	j	80004266 <fileclose+0x8c>

0000000080004282 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004282:	715d                	addi	sp,sp,-80
    80004284:	e486                	sd	ra,72(sp)
    80004286:	e0a2                	sd	s0,64(sp)
    80004288:	fc26                	sd	s1,56(sp)
    8000428a:	f84a                	sd	s2,48(sp)
    8000428c:	f44e                	sd	s3,40(sp)
    8000428e:	0880                	addi	s0,sp,80
    80004290:	84aa                	mv	s1,a0
    80004292:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004294:	869fd0ef          	jal	ra,80001afc <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004298:	409c                	lw	a5,0(s1)
    8000429a:	37f9                	addiw	a5,a5,-2
    8000429c:	4705                	li	a4,1
    8000429e:	02f76f63          	bltu	a4,a5,800042dc <filestat+0x5a>
    800042a2:	892a                	mv	s2,a0
    ilock(f->ip);
    800042a4:	6c88                	ld	a0,24(s1)
    800042a6:	948ff0ef          	jal	ra,800033ee <ilock>
    stati(f->ip, &st);
    800042aa:	fb840593          	addi	a1,s0,-72
    800042ae:	6c88                	ld	a0,24(s1)
    800042b0:	ca0ff0ef          	jal	ra,80003750 <stati>
    iunlock(f->ip);
    800042b4:	6c88                	ld	a0,24(s1)
    800042b6:	9e2ff0ef          	jal	ra,80003498 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800042ba:	46e1                	li	a3,24
    800042bc:	fb840613          	addi	a2,s0,-72
    800042c0:	85ce                	mv	a1,s3
    800042c2:	05093503          	ld	a0,80(s2)
    800042c6:	d84fd0ef          	jal	ra,8000184a <copyout>
    800042ca:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800042ce:	60a6                	ld	ra,72(sp)
    800042d0:	6406                	ld	s0,64(sp)
    800042d2:	74e2                	ld	s1,56(sp)
    800042d4:	7942                	ld	s2,48(sp)
    800042d6:	79a2                	ld	s3,40(sp)
    800042d8:	6161                	addi	sp,sp,80
    800042da:	8082                	ret
  return -1;
    800042dc:	557d                	li	a0,-1
    800042de:	bfc5                	j	800042ce <filestat+0x4c>

00000000800042e0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800042e0:	7179                	addi	sp,sp,-48
    800042e2:	f406                	sd	ra,40(sp)
    800042e4:	f022                	sd	s0,32(sp)
    800042e6:	ec26                	sd	s1,24(sp)
    800042e8:	e84a                	sd	s2,16(sp)
    800042ea:	e44e                	sd	s3,8(sp)
    800042ec:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800042ee:	00854783          	lbu	a5,8(a0)
    800042f2:	cbc1                	beqz	a5,80004382 <fileread+0xa2>
    800042f4:	84aa                	mv	s1,a0
    800042f6:	89ae                	mv	s3,a1
    800042f8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800042fa:	411c                	lw	a5,0(a0)
    800042fc:	4705                	li	a4,1
    800042fe:	04e78363          	beq	a5,a4,80004344 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004302:	470d                	li	a4,3
    80004304:	04e78563          	beq	a5,a4,8000434e <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004308:	4709                	li	a4,2
    8000430a:	06e79663          	bne	a5,a4,80004376 <fileread+0x96>
    ilock(f->ip);
    8000430e:	6d08                	ld	a0,24(a0)
    80004310:	8deff0ef          	jal	ra,800033ee <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004314:	874a                	mv	a4,s2
    80004316:	5094                	lw	a3,32(s1)
    80004318:	864e                	mv	a2,s3
    8000431a:	4585                	li	a1,1
    8000431c:	6c88                	ld	a0,24(s1)
    8000431e:	c5cff0ef          	jal	ra,8000377a <readi>
    80004322:	892a                	mv	s2,a0
    80004324:	00a05563          	blez	a0,8000432e <fileread+0x4e>
      f->off += r;
    80004328:	509c                	lw	a5,32(s1)
    8000432a:	9fa9                	addw	a5,a5,a0
    8000432c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000432e:	6c88                	ld	a0,24(s1)
    80004330:	968ff0ef          	jal	ra,80003498 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004334:	854a                	mv	a0,s2
    80004336:	70a2                	ld	ra,40(sp)
    80004338:	7402                	ld	s0,32(sp)
    8000433a:	64e2                	ld	s1,24(sp)
    8000433c:	6942                	ld	s2,16(sp)
    8000433e:	69a2                	ld	s3,8(sp)
    80004340:	6145                	addi	sp,sp,48
    80004342:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004344:	6908                	ld	a0,16(a0)
    80004346:	34e000ef          	jal	ra,80004694 <piperead>
    8000434a:	892a                	mv	s2,a0
    8000434c:	b7e5                	j	80004334 <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000434e:	02451783          	lh	a5,36(a0)
    80004352:	03079693          	slli	a3,a5,0x30
    80004356:	92c1                	srli	a3,a3,0x30
    80004358:	4725                	li	a4,9
    8000435a:	02d76663          	bltu	a4,a3,80004386 <fileread+0xa6>
    8000435e:	0792                	slli	a5,a5,0x4
    80004360:	0001d717          	auipc	a4,0x1d
    80004364:	81070713          	addi	a4,a4,-2032 # 80020b70 <devsw>
    80004368:	97ba                	add	a5,a5,a4
    8000436a:	639c                	ld	a5,0(a5)
    8000436c:	cf99                	beqz	a5,8000438a <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    8000436e:	4505                	li	a0,1
    80004370:	9782                	jalr	a5
    80004372:	892a                	mv	s2,a0
    80004374:	b7c1                	j	80004334 <fileread+0x54>
    panic("fileread");
    80004376:	00003517          	auipc	a0,0x3
    8000437a:	5da50513          	addi	a0,a0,1498 # 80007950 <syscalls+0x298>
    8000437e:	c0cfc0ef          	jal	ra,8000078a <panic>
    return -1;
    80004382:	597d                	li	s2,-1
    80004384:	bf45                	j	80004334 <fileread+0x54>
      return -1;
    80004386:	597d                	li	s2,-1
    80004388:	b775                	j	80004334 <fileread+0x54>
    8000438a:	597d                	li	s2,-1
    8000438c:	b765                	j	80004334 <fileread+0x54>

000000008000438e <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000438e:	715d                	addi	sp,sp,-80
    80004390:	e486                	sd	ra,72(sp)
    80004392:	e0a2                	sd	s0,64(sp)
    80004394:	fc26                	sd	s1,56(sp)
    80004396:	f84a                	sd	s2,48(sp)
    80004398:	f44e                	sd	s3,40(sp)
    8000439a:	f052                	sd	s4,32(sp)
    8000439c:	ec56                	sd	s5,24(sp)
    8000439e:	e85a                	sd	s6,16(sp)
    800043a0:	e45e                	sd	s7,8(sp)
    800043a2:	e062                	sd	s8,0(sp)
    800043a4:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800043a6:	00954783          	lbu	a5,9(a0)
    800043aa:	0e078863          	beqz	a5,8000449a <filewrite+0x10c>
    800043ae:	892a                	mv	s2,a0
    800043b0:	8aae                	mv	s5,a1
    800043b2:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800043b4:	411c                	lw	a5,0(a0)
    800043b6:	4705                	li	a4,1
    800043b8:	02e78263          	beq	a5,a4,800043dc <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800043bc:	470d                	li	a4,3
    800043be:	02e78463          	beq	a5,a4,800043e6 <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800043c2:	4709                	li	a4,2
    800043c4:	0ce79563          	bne	a5,a4,8000448e <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800043c8:	0ac05163          	blez	a2,8000446a <filewrite+0xdc>
    int i = 0;
    800043cc:	4981                	li	s3,0
    800043ce:	6b05                	lui	s6,0x1
    800043d0:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800043d4:	6b85                	lui	s7,0x1
    800043d6:	c00b8b9b          	addiw	s7,s7,-1024
    800043da:	a041                	j	8000445a <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800043dc:	6908                	ld	a0,16(a0)
    800043de:	1e2000ef          	jal	ra,800045c0 <pipewrite>
    800043e2:	8a2a                	mv	s4,a0
    800043e4:	a071                	j	80004470 <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800043e6:	02451783          	lh	a5,36(a0)
    800043ea:	03079693          	slli	a3,a5,0x30
    800043ee:	92c1                	srli	a3,a3,0x30
    800043f0:	4725                	li	a4,9
    800043f2:	0ad76663          	bltu	a4,a3,8000449e <filewrite+0x110>
    800043f6:	0792                	slli	a5,a5,0x4
    800043f8:	0001c717          	auipc	a4,0x1c
    800043fc:	77870713          	addi	a4,a4,1912 # 80020b70 <devsw>
    80004400:	97ba                	add	a5,a5,a4
    80004402:	679c                	ld	a5,8(a5)
    80004404:	cfd9                	beqz	a5,800044a2 <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    80004406:	4505                	li	a0,1
    80004408:	9782                	jalr	a5
    8000440a:	8a2a                	mv	s4,a0
    8000440c:	a095                	j	80004470 <filewrite+0xe2>
    8000440e:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004412:	9bbff0ef          	jal	ra,80003dcc <begin_op>
      ilock(f->ip);
    80004416:	01893503          	ld	a0,24(s2)
    8000441a:	fd5fe0ef          	jal	ra,800033ee <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000441e:	8762                	mv	a4,s8
    80004420:	02092683          	lw	a3,32(s2)
    80004424:	01598633          	add	a2,s3,s5
    80004428:	4585                	li	a1,1
    8000442a:	01893503          	ld	a0,24(s2)
    8000442e:	c30ff0ef          	jal	ra,8000385e <writei>
    80004432:	84aa                	mv	s1,a0
    80004434:	00a05763          	blez	a0,80004442 <filewrite+0xb4>
        f->off += r;
    80004438:	02092783          	lw	a5,32(s2)
    8000443c:	9fa9                	addw	a5,a5,a0
    8000443e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004442:	01893503          	ld	a0,24(s2)
    80004446:	852ff0ef          	jal	ra,80003498 <iunlock>
      end_op();
    8000444a:	9f3ff0ef          	jal	ra,80003e3c <end_op>

      if(r != n1){
    8000444e:	009c1f63          	bne	s8,s1,8000446c <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    80004452:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004456:	0149db63          	bge	s3,s4,8000446c <filewrite+0xde>
      int n1 = n - i;
    8000445a:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    8000445e:	84be                	mv	s1,a5
    80004460:	2781                	sext.w	a5,a5
    80004462:	fafb56e3          	bge	s6,a5,8000440e <filewrite+0x80>
    80004466:	84de                	mv	s1,s7
    80004468:	b75d                	j	8000440e <filewrite+0x80>
    int i = 0;
    8000446a:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000446c:	013a1f63          	bne	s4,s3,8000448a <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004470:	8552                	mv	a0,s4
    80004472:	60a6                	ld	ra,72(sp)
    80004474:	6406                	ld	s0,64(sp)
    80004476:	74e2                	ld	s1,56(sp)
    80004478:	7942                	ld	s2,48(sp)
    8000447a:	79a2                	ld	s3,40(sp)
    8000447c:	7a02                	ld	s4,32(sp)
    8000447e:	6ae2                	ld	s5,24(sp)
    80004480:	6b42                	ld	s6,16(sp)
    80004482:	6ba2                	ld	s7,8(sp)
    80004484:	6c02                	ld	s8,0(sp)
    80004486:	6161                	addi	sp,sp,80
    80004488:	8082                	ret
    ret = (i == n ? n : -1);
    8000448a:	5a7d                	li	s4,-1
    8000448c:	b7d5                	j	80004470 <filewrite+0xe2>
    panic("filewrite");
    8000448e:	00003517          	auipc	a0,0x3
    80004492:	4d250513          	addi	a0,a0,1234 # 80007960 <syscalls+0x2a8>
    80004496:	af4fc0ef          	jal	ra,8000078a <panic>
    return -1;
    8000449a:	5a7d                	li	s4,-1
    8000449c:	bfd1                	j	80004470 <filewrite+0xe2>
      return -1;
    8000449e:	5a7d                	li	s4,-1
    800044a0:	bfc1                	j	80004470 <filewrite+0xe2>
    800044a2:	5a7d                	li	s4,-1
    800044a4:	b7f1                	j	80004470 <filewrite+0xe2>

00000000800044a6 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800044a6:	7179                	addi	sp,sp,-48
    800044a8:	f406                	sd	ra,40(sp)
    800044aa:	f022                	sd	s0,32(sp)
    800044ac:	ec26                	sd	s1,24(sp)
    800044ae:	e84a                	sd	s2,16(sp)
    800044b0:	e44e                	sd	s3,8(sp)
    800044b2:	e052                	sd	s4,0(sp)
    800044b4:	1800                	addi	s0,sp,48
    800044b6:	84aa                	mv	s1,a0
    800044b8:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800044ba:	0005b023          	sd	zero,0(a1)
    800044be:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800044c2:	c75ff0ef          	jal	ra,80004136 <filealloc>
    800044c6:	e088                	sd	a0,0(s1)
    800044c8:	cd35                	beqz	a0,80004544 <pipealloc+0x9e>
    800044ca:	c6dff0ef          	jal	ra,80004136 <filealloc>
    800044ce:	00aa3023          	sd	a0,0(s4)
    800044d2:	c52d                	beqz	a0,8000453c <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800044d4:	dc8fc0ef          	jal	ra,80000a9c <kalloc>
    800044d8:	892a                	mv	s2,a0
    800044da:	cd31                	beqz	a0,80004536 <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    800044dc:	4985                	li	s3,1
    800044de:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800044e2:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800044e6:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800044ea:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800044ee:	00003597          	auipc	a1,0x3
    800044f2:	48258593          	addi	a1,a1,1154 # 80007970 <syscalls+0x2b8>
    800044f6:	df6fc0ef          	jal	ra,80000aec <initlock>
  (*f0)->type = FD_PIPE;
    800044fa:	609c                	ld	a5,0(s1)
    800044fc:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004500:	609c                	ld	a5,0(s1)
    80004502:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004506:	609c                	ld	a5,0(s1)
    80004508:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000450c:	609c                	ld	a5,0(s1)
    8000450e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004512:	000a3783          	ld	a5,0(s4)
    80004516:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000451a:	000a3783          	ld	a5,0(s4)
    8000451e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004522:	000a3783          	ld	a5,0(s4)
    80004526:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000452a:	000a3783          	ld	a5,0(s4)
    8000452e:	0127b823          	sd	s2,16(a5)
  return 0;
    80004532:	4501                	li	a0,0
    80004534:	a005                	j	80004554 <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004536:	6088                	ld	a0,0(s1)
    80004538:	e501                	bnez	a0,80004540 <pipealloc+0x9a>
    8000453a:	a029                	j	80004544 <pipealloc+0x9e>
    8000453c:	6088                	ld	a0,0(s1)
    8000453e:	c11d                	beqz	a0,80004564 <pipealloc+0xbe>
    fileclose(*f0);
    80004540:	c9bff0ef          	jal	ra,800041da <fileclose>
  if(*f1)
    80004544:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004548:	557d                	li	a0,-1
  if(*f1)
    8000454a:	c789                	beqz	a5,80004554 <pipealloc+0xae>
    fileclose(*f1);
    8000454c:	853e                	mv	a0,a5
    8000454e:	c8dff0ef          	jal	ra,800041da <fileclose>
  return -1;
    80004552:	557d                	li	a0,-1
}
    80004554:	70a2                	ld	ra,40(sp)
    80004556:	7402                	ld	s0,32(sp)
    80004558:	64e2                	ld	s1,24(sp)
    8000455a:	6942                	ld	s2,16(sp)
    8000455c:	69a2                	ld	s3,8(sp)
    8000455e:	6a02                	ld	s4,0(sp)
    80004560:	6145                	addi	sp,sp,48
    80004562:	8082                	ret
  return -1;
    80004564:	557d                	li	a0,-1
    80004566:	b7fd                	j	80004554 <pipealloc+0xae>

0000000080004568 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004568:	1101                	addi	sp,sp,-32
    8000456a:	ec06                	sd	ra,24(sp)
    8000456c:	e822                	sd	s0,16(sp)
    8000456e:	e426                	sd	s1,8(sp)
    80004570:	e04a                	sd	s2,0(sp)
    80004572:	1000                	addi	s0,sp,32
    80004574:	84aa                	mv	s1,a0
    80004576:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004578:	df4fc0ef          	jal	ra,80000b6c <acquire>
  if(writable){
    8000457c:	02090763          	beqz	s2,800045aa <pipeclose+0x42>
    pi->writeopen = 0;
    80004580:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004584:	21848513          	addi	a0,s1,536
    80004588:	bd3fd0ef          	jal	ra,8000215a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000458c:	2204b783          	ld	a5,544(s1)
    80004590:	e785                	bnez	a5,800045b8 <pipeclose+0x50>
    release(&pi->lock);
    80004592:	8526                	mv	a0,s1
    80004594:	e70fc0ef          	jal	ra,80000c04 <release>
    kfree((char*)pi);
    80004598:	8526                	mv	a0,s1
    8000459a:	c22fc0ef          	jal	ra,800009bc <kfree>
  } else
    release(&pi->lock);
}
    8000459e:	60e2                	ld	ra,24(sp)
    800045a0:	6442                	ld	s0,16(sp)
    800045a2:	64a2                	ld	s1,8(sp)
    800045a4:	6902                	ld	s2,0(sp)
    800045a6:	6105                	addi	sp,sp,32
    800045a8:	8082                	ret
    pi->readopen = 0;
    800045aa:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800045ae:	21c48513          	addi	a0,s1,540
    800045b2:	ba9fd0ef          	jal	ra,8000215a <wakeup>
    800045b6:	bfd9                	j	8000458c <pipeclose+0x24>
    release(&pi->lock);
    800045b8:	8526                	mv	a0,s1
    800045ba:	e4afc0ef          	jal	ra,80000c04 <release>
}
    800045be:	b7c5                	j	8000459e <pipeclose+0x36>

00000000800045c0 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800045c0:	711d                	addi	sp,sp,-96
    800045c2:	ec86                	sd	ra,88(sp)
    800045c4:	e8a2                	sd	s0,80(sp)
    800045c6:	e4a6                	sd	s1,72(sp)
    800045c8:	e0ca                	sd	s2,64(sp)
    800045ca:	fc4e                	sd	s3,56(sp)
    800045cc:	f852                	sd	s4,48(sp)
    800045ce:	f456                	sd	s5,40(sp)
    800045d0:	f05a                	sd	s6,32(sp)
    800045d2:	ec5e                	sd	s7,24(sp)
    800045d4:	e862                	sd	s8,16(sp)
    800045d6:	1080                	addi	s0,sp,96
    800045d8:	84aa                	mv	s1,a0
    800045da:	8aae                	mv	s5,a1
    800045dc:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800045de:	d1efd0ef          	jal	ra,80001afc <myproc>
    800045e2:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800045e4:	8526                	mv	a0,s1
    800045e6:	d86fc0ef          	jal	ra,80000b6c <acquire>
  while(i < n){
    800045ea:	09405c63          	blez	s4,80004682 <pipewrite+0xc2>
  int i = 0;
    800045ee:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800045f0:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800045f2:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800045f6:	21c48b93          	addi	s7,s1,540
    800045fa:	a81d                	j	80004630 <pipewrite+0x70>
      release(&pi->lock);
    800045fc:	8526                	mv	a0,s1
    800045fe:	e06fc0ef          	jal	ra,80000c04 <release>
      return -1;
    80004602:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004604:	854a                	mv	a0,s2
    80004606:	60e6                	ld	ra,88(sp)
    80004608:	6446                	ld	s0,80(sp)
    8000460a:	64a6                	ld	s1,72(sp)
    8000460c:	6906                	ld	s2,64(sp)
    8000460e:	79e2                	ld	s3,56(sp)
    80004610:	7a42                	ld	s4,48(sp)
    80004612:	7aa2                	ld	s5,40(sp)
    80004614:	7b02                	ld	s6,32(sp)
    80004616:	6be2                	ld	s7,24(sp)
    80004618:	6c42                	ld	s8,16(sp)
    8000461a:	6125                	addi	sp,sp,96
    8000461c:	8082                	ret
      wakeup(&pi->nread);
    8000461e:	8562                	mv	a0,s8
    80004620:	b3bfd0ef          	jal	ra,8000215a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004624:	85a6                	mv	a1,s1
    80004626:	855e                	mv	a0,s7
    80004628:	ae7fd0ef          	jal	ra,8000210e <sleep>
  while(i < n){
    8000462c:	05495c63          	bge	s2,s4,80004684 <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    80004630:	2204a783          	lw	a5,544(s1)
    80004634:	d7e1                	beqz	a5,800045fc <pipewrite+0x3c>
    80004636:	854e                	mv	a0,s3
    80004638:	d0ffd0ef          	jal	ra,80002346 <killed>
    8000463c:	f161                	bnez	a0,800045fc <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000463e:	2184a783          	lw	a5,536(s1)
    80004642:	21c4a703          	lw	a4,540(s1)
    80004646:	2007879b          	addiw	a5,a5,512
    8000464a:	fcf70ae3          	beq	a4,a5,8000461e <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000464e:	4685                	li	a3,1
    80004650:	01590633          	add	a2,s2,s5
    80004654:	faf40593          	addi	a1,s0,-81
    80004658:	0509b503          	ld	a0,80(s3)
    8000465c:	ab4fd0ef          	jal	ra,80001910 <copyin>
    80004660:	03650263          	beq	a0,s6,80004684 <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004664:	21c4a783          	lw	a5,540(s1)
    80004668:	0017871b          	addiw	a4,a5,1
    8000466c:	20e4ae23          	sw	a4,540(s1)
    80004670:	1ff7f793          	andi	a5,a5,511
    80004674:	97a6                	add	a5,a5,s1
    80004676:	faf44703          	lbu	a4,-81(s0)
    8000467a:	00e78c23          	sb	a4,24(a5)
      i++;
    8000467e:	2905                	addiw	s2,s2,1
    80004680:	b775                	j	8000462c <pipewrite+0x6c>
  int i = 0;
    80004682:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004684:	21848513          	addi	a0,s1,536
    80004688:	ad3fd0ef          	jal	ra,8000215a <wakeup>
  release(&pi->lock);
    8000468c:	8526                	mv	a0,s1
    8000468e:	d76fc0ef          	jal	ra,80000c04 <release>
  return i;
    80004692:	bf8d                	j	80004604 <pipewrite+0x44>

0000000080004694 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004694:	715d                	addi	sp,sp,-80
    80004696:	e486                	sd	ra,72(sp)
    80004698:	e0a2                	sd	s0,64(sp)
    8000469a:	fc26                	sd	s1,56(sp)
    8000469c:	f84a                	sd	s2,48(sp)
    8000469e:	f44e                	sd	s3,40(sp)
    800046a0:	f052                	sd	s4,32(sp)
    800046a2:	ec56                	sd	s5,24(sp)
    800046a4:	e85a                	sd	s6,16(sp)
    800046a6:	0880                	addi	s0,sp,80
    800046a8:	84aa                	mv	s1,a0
    800046aa:	892e                	mv	s2,a1
    800046ac:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800046ae:	c4efd0ef          	jal	ra,80001afc <myproc>
    800046b2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800046b4:	8526                	mv	a0,s1
    800046b6:	cb6fc0ef          	jal	ra,80000b6c <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800046ba:	2184a703          	lw	a4,536(s1)
    800046be:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800046c2:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800046c6:	02f71363          	bne	a4,a5,800046ec <piperead+0x58>
    800046ca:	2244a783          	lw	a5,548(s1)
    800046ce:	cf99                	beqz	a5,800046ec <piperead+0x58>
    if(killed(pr)){
    800046d0:	8552                	mv	a0,s4
    800046d2:	c75fd0ef          	jal	ra,80002346 <killed>
    800046d6:	e141                	bnez	a0,80004756 <piperead+0xc2>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800046d8:	85a6                	mv	a1,s1
    800046da:	854e                	mv	a0,s3
    800046dc:	a33fd0ef          	jal	ra,8000210e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800046e0:	2184a703          	lw	a4,536(s1)
    800046e4:	21c4a783          	lw	a5,540(s1)
    800046e8:	fef701e3          	beq	a4,a5,800046ca <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800046ec:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800046ee:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800046f0:	05505163          	blez	s5,80004732 <piperead+0x9e>
    if(pi->nread == pi->nwrite)
    800046f4:	2184a783          	lw	a5,536(s1)
    800046f8:	21c4a703          	lw	a4,540(s1)
    800046fc:	02f70b63          	beq	a4,a5,80004732 <piperead+0x9e>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004700:	0017871b          	addiw	a4,a5,1
    80004704:	20e4ac23          	sw	a4,536(s1)
    80004708:	1ff7f793          	andi	a5,a5,511
    8000470c:	97a6                	add	a5,a5,s1
    8000470e:	0187c783          	lbu	a5,24(a5)
    80004712:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004716:	4685                	li	a3,1
    80004718:	fbf40613          	addi	a2,s0,-65
    8000471c:	85ca                	mv	a1,s2
    8000471e:	050a3503          	ld	a0,80(s4)
    80004722:	928fd0ef          	jal	ra,8000184a <copyout>
    80004726:	01650663          	beq	a0,s6,80004732 <piperead+0x9e>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000472a:	2985                	addiw	s3,s3,1
    8000472c:	0905                	addi	s2,s2,1
    8000472e:	fd3a93e3          	bne	s5,s3,800046f4 <piperead+0x60>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004732:	21c48513          	addi	a0,s1,540
    80004736:	a25fd0ef          	jal	ra,8000215a <wakeup>
  release(&pi->lock);
    8000473a:	8526                	mv	a0,s1
    8000473c:	cc8fc0ef          	jal	ra,80000c04 <release>
  return i;
}
    80004740:	854e                	mv	a0,s3
    80004742:	60a6                	ld	ra,72(sp)
    80004744:	6406                	ld	s0,64(sp)
    80004746:	74e2                	ld	s1,56(sp)
    80004748:	7942                	ld	s2,48(sp)
    8000474a:	79a2                	ld	s3,40(sp)
    8000474c:	7a02                	ld	s4,32(sp)
    8000474e:	6ae2                	ld	s5,24(sp)
    80004750:	6b42                	ld	s6,16(sp)
    80004752:	6161                	addi	sp,sp,80
    80004754:	8082                	ret
      release(&pi->lock);
    80004756:	8526                	mv	a0,s1
    80004758:	cacfc0ef          	jal	ra,80000c04 <release>
      return -1;
    8000475c:	59fd                	li	s3,-1
    8000475e:	b7cd                	j	80004740 <piperead+0xac>

0000000080004760 <flags2perm>:

// static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004760:	1141                	addi	sp,sp,-16
    80004762:	e422                	sd	s0,8(sp)
    80004764:	0800                	addi	s0,sp,16
    80004766:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004768:	8905                	andi	a0,a0,1
    8000476a:	c111                	beqz	a0,8000476e <flags2perm+0xe>
      perm = PTE_X;
    8000476c:	4521                	li	a0,8
    if(flags & 0x2)
    8000476e:	8b89                	andi	a5,a5,2
    80004770:	c399                	beqz	a5,80004776 <flags2perm+0x16>
      perm |= PTE_W;
    80004772:	00456513          	ori	a0,a0,4
    return perm;
}
    80004776:	6422                	ld	s0,8(sp)
    80004778:	0141                	addi	sp,sp,16
    8000477a:	8082                	ret

000000008000477c <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    8000477c:	7101                	addi	sp,sp,-512
    8000477e:	ff86                	sd	ra,504(sp)
    80004780:	fba2                	sd	s0,496(sp)
    80004782:	f7a6                	sd	s1,488(sp)
    80004784:	f3ca                	sd	s2,480(sp)
    80004786:	efce                	sd	s3,472(sp)
    80004788:	ebd2                	sd	s4,464(sp)
    8000478a:	e7d6                	sd	s5,456(sp)
    8000478c:	e3da                	sd	s6,448(sp)
    8000478e:	ff5e                	sd	s7,440(sp)
    80004790:	fb62                	sd	s8,432(sp)
    80004792:	f766                	sd	s9,424(sp)
    80004794:	f36a                	sd	s10,416(sp)
    80004796:	ef6e                	sd	s11,408(sp)
    80004798:	0400                	addi	s0,sp,512
    8000479a:	892a                	mv	s2,a0
    8000479c:	84ae                	mv	s1,a1
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000479e:	b5efd0ef          	jal	ra,80001afc <myproc>
    800047a2:	8c2a                	mv	s8,a0

  begin_op();
    800047a4:	e28ff0ef          	jal	ra,80003dcc <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    800047a8:	854a                	mv	a0,s2
    800047aa:	c32ff0ef          	jal	ra,80003bdc <namei>
    800047ae:	cd39                	beqz	a0,8000480c <kexec+0x90>
    800047b0:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800047b2:	c3dfe0ef          	jal	ra,800033ee <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800047b6:	04000713          	li	a4,64
    800047ba:	4681                	li	a3,0
    800047bc:	e5040613          	addi	a2,s0,-432
    800047c0:	4581                	li	a1,0
    800047c2:	8552                	mv	a0,s4
    800047c4:	fb7fe0ef          	jal	ra,8000377a <readi>
    800047c8:	04000793          	li	a5,64
    800047cc:	00f51a63          	bne	a0,a5,800047e0 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    800047d0:	e5042703          	lw	a4,-432(s0)
    800047d4:	464c47b7          	lui	a5,0x464c4
    800047d8:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800047dc:	02f70c63          	beq	a4,a5,80004814 <kexec+0x98>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800047e0:	8552                	mv	a0,s4
    800047e2:	e13fe0ef          	jal	ra,800035f4 <iunlockput>
    end_op();
    800047e6:	e56ff0ef          	jal	ra,80003e3c <end_op>
  }
  return -1;
    800047ea:	557d                	li	a0,-1
}
    800047ec:	70fe                	ld	ra,504(sp)
    800047ee:	745e                	ld	s0,496(sp)
    800047f0:	74be                	ld	s1,488(sp)
    800047f2:	791e                	ld	s2,480(sp)
    800047f4:	69fe                	ld	s3,472(sp)
    800047f6:	6a5e                	ld	s4,464(sp)
    800047f8:	6abe                	ld	s5,456(sp)
    800047fa:	6b1e                	ld	s6,448(sp)
    800047fc:	7bfa                	ld	s7,440(sp)
    800047fe:	7c5a                	ld	s8,432(sp)
    80004800:	7cba                	ld	s9,424(sp)
    80004802:	7d1a                	ld	s10,416(sp)
    80004804:	6dfa                	ld	s11,408(sp)
    80004806:	20010113          	addi	sp,sp,512
    8000480a:	8082                	ret
    end_op();
    8000480c:	e30ff0ef          	jal	ra,80003e3c <end_op>
    return -1;
    80004810:	557d                	li	a0,-1
    80004812:	bfe9                	j	800047ec <kexec+0x70>
  if((pagetable = proc_pagetable(p)) == 0)
    80004814:	8562                	mv	a0,s8
    80004816:	becfd0ef          	jal	ra,80001c02 <proc_pagetable>
    8000481a:	8b2a                	mv	s6,a0
    8000481c:	d171                	beqz	a0,800047e0 <kexec+0x64>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000481e:	e7042983          	lw	s3,-400(s0)
    80004822:	e8845783          	lhu	a5,-376(s0)
    80004826:	cfa5                	beqz	a5,8000489e <kexec+0x122>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004828:	4a81                	li	s5,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000482a:	4b81                	li	s7,0
    if(ph.type != ELF_PROG_LOAD)
    8000482c:	4c85                	li	s9,1
    if(ph.vaddr % PGSIZE != 0)
    8000482e:	6d05                	lui	s10,0x1
    80004830:	1d7d                	addi	s10,s10,-1
    80004832:	a829                	j	8000484c <kexec+0xd0>
      p->data_start = ph.vaddr;
    80004834:	16ec3c23          	sd	a4,376(s8)
      p->data_end = ph.vaddr + ph.memsz;
    80004838:	18fc3023          	sd	a5,384(s8)
    sz = ph.vaddr + ph.memsz;  // Update size but don't allocate
    8000483c:	8abe                	mv	s5,a5
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000483e:	2b85                	addiw	s7,s7,1
    80004840:	0389899b          	addiw	s3,s3,56
    80004844:	e8845783          	lhu	a5,-376(s0)
    80004848:	04fbdc63          	bge	s7,a5,800048a0 <kexec+0x124>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000484c:	2981                	sext.w	s3,s3
    8000484e:	03800713          	li	a4,56
    80004852:	86ce                	mv	a3,s3
    80004854:	e1840613          	addi	a2,s0,-488
    80004858:	4581                	li	a1,0
    8000485a:	8552                	mv	a0,s4
    8000485c:	f1ffe0ef          	jal	ra,8000377a <readi>
    80004860:	03800793          	li	a5,56
    80004864:	12f51063          	bne	a0,a5,80004984 <kexec+0x208>
    if(ph.type != ELF_PROG_LOAD)
    80004868:	e1842783          	lw	a5,-488(s0)
    8000486c:	fd9799e3          	bne	a5,s9,8000483e <kexec+0xc2>
    if(ph.memsz < ph.filesz)
    80004870:	e4043783          	ld	a5,-448(s0)
    80004874:	e3843703          	ld	a4,-456(s0)
    80004878:	10e7e663          	bltu	a5,a4,80004984 <kexec+0x208>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000487c:	e2843703          	ld	a4,-472(s0)
    80004880:	97ba                	add	a5,a5,a4
    80004882:	10e7e163          	bltu	a5,a4,80004984 <kexec+0x208>
    if(ph.vaddr % PGSIZE != 0)
    80004886:	01a776b3          	and	a3,a4,s10
    8000488a:	0e069d63          	bnez	a3,80004984 <kexec+0x208>
    if(i == 0) {  // First segment (typically text)
    8000488e:	fa0b93e3          	bnez	s7,80004834 <kexec+0xb8>
      p->text_start = ph.vaddr;
    80004892:	16ec3423          	sd	a4,360(s8)
      p->text_end = ph.vaddr + ph.memsz;
    80004896:	16fc3823          	sd	a5,368(s8)
    sz = ph.vaddr + ph.memsz;  // Update size but don't allocate
    8000489a:	8abe                	mv	s5,a5
    8000489c:	b74d                	j	8000483e <kexec+0xc2>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000489e:	4a81                	li	s5,0
  printf("[pid %d] INIT-LAZYMAP text=[0x%lx,0x%lx) data=[0x%lx,0x%lx) heap_start=0x%lx stack_top=0x%lx\n", 
    800048a0:	180c3783          	ld	a5,384(s8)
    800048a4:	6989                	lui	s3,0x2
    800048a6:	013a88b3          	add	a7,s5,s3
    800048aa:	883e                	mv	a6,a5
    800048ac:	178c3703          	ld	a4,376(s8)
    800048b0:	170c3683          	ld	a3,368(s8)
    800048b4:	168c3603          	ld	a2,360(s8)
    800048b8:	030c2583          	lw	a1,48(s8)
    800048bc:	00003517          	auipc	a0,0x3
    800048c0:	0bc50513          	addi	a0,a0,188 # 80007978 <syscalls+0x2c0>
    800048c4:	c01fb0ef          	jal	ra,800004c4 <printf>
  p->heap_start = p->data_end;
    800048c8:	180c3783          	ld	a5,384(s8)
    800048cc:	18fc3423          	sd	a5,392(s8)
  p->exec_inode = ip;
    800048d0:	194c3c23          	sd	s4,408(s8)
  idup(ip);  // Increment reference count
    800048d4:	8552                	mv	a0,s4
    800048d6:	ae3fe0ef          	jal	ra,800033b8 <idup>
  iunlockput(ip);
    800048da:	8552                	mv	a0,s4
    800048dc:	d19fe0ef          	jal	ra,800035f4 <iunlockput>
  end_op();
    800048e0:	d5cff0ef          	jal	ra,80003e3c <end_op>
  p = myproc();
    800048e4:	a18fd0ef          	jal	ra,80001afc <myproc>
    800048e8:	e0a43423          	sd	a0,-504(s0)
  uint64 oldsz = p->sz;
    800048ec:	653c                	ld	a5,72(a0)
    800048ee:	e0f43023          	sd	a5,-512(s0)
  sz = PGROUNDUP(sz);
    800048f2:	6785                	lui	a5,0x1
    800048f4:	fff78c93          	addi	s9,a5,-1 # fff <_entry-0x7ffff001>
    800048f8:	9cd6                	add	s9,s9,s5
    800048fa:	777d                	lui	a4,0xfffff
    800048fc:	00ecfcb3          	and	s9,s9,a4
  sz1 = sz + (USERSTACK+1)*PGSIZE;
    80004900:	013c8ab3          	add	s5,s9,s3
  stackbase = sp - USERSTACK*PGSIZE;
    80004904:	9cbe                	add	s9,s9,a5
   p->sz = sz;
    80004906:	05553423          	sd	s5,72(a0)
  for(argc = 0; argv[argc]; argc++) {
    8000490a:	6088                	ld	a0,0(s1)
    8000490c:	cd41                	beqz	a0,800049a4 <kexec+0x228>
    8000490e:	e9040b93          	addi	s7,s0,-368
  sp = sz;
    80004912:	8a56                	mv	s4,s5
  for(argc = 0; argv[argc]; argc++) {
    80004914:	4981                	li	s3,0
    printf("[DEBUG] About to copyout to sp=0x%lx, len=%d\n", sp, strlen(argv[argc]) + 1);
    80004916:	00003d17          	auipc	s10,0x3
    8000491a:	0c2d0d13          	addi	s10,s10,194 # 800079d8 <syscalls+0x320>
    printf("[DEBUG] copyout SUCCESS\n");
    8000491e:	00003d97          	auipc	s11,0x3
    80004922:	102d8d93          	addi	s11,s11,258 # 80007a20 <syscalls+0x368>
    sp -= strlen(argv[argc]) + 1;
    80004926:	c92fc0ef          	jal	ra,80000db8 <strlen>
    8000492a:	2505                	addiw	a0,a0,1
    8000492c:	40aa0a33          	sub	s4,s4,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004930:	ff0a7a13          	andi	s4,s4,-16
    if(sp < stackbase)
    80004934:	119a6b63          	bltu	s4,s9,80004a4a <kexec+0x2ce>
    printf("[DEBUG] About to copyout to sp=0x%lx, len=%d\n", sp, strlen(argv[argc]) + 1);
    80004938:	6088                	ld	a0,0(s1)
    8000493a:	c7efc0ef          	jal	ra,80000db8 <strlen>
    8000493e:	0015061b          	addiw	a2,a0,1
    80004942:	85d2                	mv	a1,s4
    80004944:	856a                	mv	a0,s10
    80004946:	b7ffb0ef          	jal	ra,800004c4 <printf>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0) {
    8000494a:	0004bc03          	ld	s8,0(s1)
    8000494e:	8562                	mv	a0,s8
    80004950:	c68fc0ef          	jal	ra,80000db8 <strlen>
    80004954:	0015069b          	addiw	a3,a0,1
    80004958:	8662                	mv	a2,s8
    8000495a:	85d2                	mv	a1,s4
    8000495c:	855a                	mv	a0,s6
    8000495e:	eedfc0ef          	jal	ra,8000184a <copyout>
    80004962:	02054963          	bltz	a0,80004994 <kexec+0x218>
    printf("[DEBUG] copyout SUCCESS\n");
    80004966:	856e                	mv	a0,s11
    80004968:	b5dfb0ef          	jal	ra,800004c4 <printf>
    ustack[argc] = sp;
    8000496c:	014bb023          	sd	s4,0(s7) # 1000 <_entry-0x7ffff000>
  for(argc = 0; argv[argc]; argc++) {
    80004970:	0985                	addi	s3,s3,1
    80004972:	04a1                	addi	s1,s1,8
    80004974:	6088                	ld	a0,0(s1)
    80004976:	c90d                	beqz	a0,800049a8 <kexec+0x22c>
    if(argc >= MAXARG)
    80004978:	0ba1                	addi	s7,s7,8
    8000497a:	f9040793          	addi	a5,s0,-112
    8000497e:	fb7794e3          	bne	a5,s7,80004926 <kexec+0x1aa>
  ip = 0;
    80004982:	4a01                	li	s4,0
    proc_freepagetable(pagetable, sz);
    80004984:	85d6                	mv	a1,s5
    80004986:	855a                	mv	a0,s6
    80004988:	afefd0ef          	jal	ra,80001c86 <proc_freepagetable>
  if(ip){
    8000498c:	e40a1ae3          	bnez	s4,800047e0 <kexec+0x64>
  return -1;
    80004990:	557d                	li	a0,-1
    80004992:	bda9                	j	800047ec <kexec+0x70>
      printf("[DEBUG] copyout FAILED\n");
    80004994:	00003517          	auipc	a0,0x3
    80004998:	07450513          	addi	a0,a0,116 # 80007a08 <syscalls+0x350>
    8000499c:	b29fb0ef          	jal	ra,800004c4 <printf>
  ip = 0;
    800049a0:	4a01                	li	s4,0
      goto bad;
    800049a2:	b7cd                	j	80004984 <kexec+0x208>
  sp = sz;
    800049a4:	8a56                	mv	s4,s5
  for(argc = 0; argv[argc]; argc++) {
    800049a6:	4981                	li	s3,0
  ustack[argc] = 0;
    800049a8:	00399793          	slli	a5,s3,0x3
    800049ac:	f9040713          	addi	a4,s0,-112
    800049b0:	97ba                	add	a5,a5,a4
    800049b2:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800049b6:	00198b93          	addi	s7,s3,1 # 2001 <_entry-0x7fffdfff>
    800049ba:	0b8e                	slli	s7,s7,0x3
    800049bc:	417a04b3          	sub	s1,s4,s7
  sp -= sp % 16;
    800049c0:	98c1                	andi	s1,s1,-16
  ip = 0;
    800049c2:	4a01                	li	s4,0
  if(sp < stackbase)
    800049c4:	fd94e0e3          	bltu	s1,s9,80004984 <kexec+0x208>
  printf("[DEBUG] copyout ustack to sp=0x%lx\n", sp);
    800049c8:	85a6                	mv	a1,s1
    800049ca:	00003517          	auipc	a0,0x3
    800049ce:	07650513          	addi	a0,a0,118 # 80007a40 <syscalls+0x388>
    800049d2:	af3fb0ef          	jal	ra,800004c4 <printf>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800049d6:	86de                	mv	a3,s7
    800049d8:	e9040613          	addi	a2,s0,-368
    800049dc:	85a6                	mv	a1,s1
    800049de:	855a                	mv	a0,s6
    800049e0:	e6bfc0ef          	jal	ra,8000184a <copyout>
    800049e4:	06054563          	bltz	a0,80004a4e <kexec+0x2d2>
  p->trapframe->a1 = sp;
    800049e8:	e0843783          	ld	a5,-504(s0)
    800049ec:	6fbc                	ld	a5,88(a5)
    800049ee:	ffa4                	sd	s1,120(a5)
  for(last=s=path; *s; s++)
    800049f0:	00094703          	lbu	a4,0(s2)
    800049f4:	cf11                	beqz	a4,80004a10 <kexec+0x294>
    800049f6:	00190793          	addi	a5,s2,1
    if(*s == '/')
    800049fa:	02f00693          	li	a3,47
    800049fe:	a029                	j	80004a08 <kexec+0x28c>
  for(last=s=path; *s; s++)
    80004a00:	0785                	addi	a5,a5,1
    80004a02:	fff7c703          	lbu	a4,-1(a5)
    80004a06:	c709                	beqz	a4,80004a10 <kexec+0x294>
    if(*s == '/')
    80004a08:	fed71ce3          	bne	a4,a3,80004a00 <kexec+0x284>
      last = s+1;
    80004a0c:	893e                	mv	s2,a5
    80004a0e:	bfcd                	j	80004a00 <kexec+0x284>
  safestrcpy(p->name, last, sizeof(p->name));
    80004a10:	4641                	li	a2,16
    80004a12:	85ca                	mv	a1,s2
    80004a14:	e0843903          	ld	s2,-504(s0)
    80004a18:	15890513          	addi	a0,s2,344
    80004a1c:	b6afc0ef          	jal	ra,80000d86 <safestrcpy>
  oldpagetable = p->pagetable;
    80004a20:	05093503          	ld	a0,80(s2)
  p->pagetable = pagetable;
    80004a24:	05693823          	sd	s6,80(s2)
  p->sz = sz;
    80004a28:	05593423          	sd	s5,72(s2)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004a2c:	05893783          	ld	a5,88(s2)
    80004a30:	e6843703          	ld	a4,-408(s0)
    80004a34:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004a36:	05893783          	ld	a5,88(s2)
    80004a3a:	fb84                	sd	s1,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004a3c:	e0043583          	ld	a1,-512(s0)
    80004a40:	a46fd0ef          	jal	ra,80001c86 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004a44:	0009851b          	sext.w	a0,s3
    80004a48:	b355                	j	800047ec <kexec+0x70>
  ip = 0;
    80004a4a:	4a01                	li	s4,0
    80004a4c:	bf25                	j	80004984 <kexec+0x208>
    80004a4e:	4a01                	li	s4,0
    80004a50:	bf15                	j	80004984 <kexec+0x208>

0000000080004a52 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004a52:	7179                	addi	sp,sp,-48
    80004a54:	f406                	sd	ra,40(sp)
    80004a56:	f022                	sd	s0,32(sp)
    80004a58:	ec26                	sd	s1,24(sp)
    80004a5a:	e84a                	sd	s2,16(sp)
    80004a5c:	1800                	addi	s0,sp,48
    80004a5e:	892e                	mv	s2,a1
    80004a60:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004a62:	fdc40593          	addi	a1,s0,-36
    80004a66:	fb1fd0ef          	jal	ra,80002a16 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004a6a:	fdc42703          	lw	a4,-36(s0)
    80004a6e:	47bd                	li	a5,15
    80004a70:	02e7e963          	bltu	a5,a4,80004aa2 <argfd+0x50>
    80004a74:	888fd0ef          	jal	ra,80001afc <myproc>
    80004a78:	fdc42703          	lw	a4,-36(s0)
    80004a7c:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffdd312>
    80004a80:	078e                	slli	a5,a5,0x3
    80004a82:	953e                	add	a0,a0,a5
    80004a84:	611c                	ld	a5,0(a0)
    80004a86:	c385                	beqz	a5,80004aa6 <argfd+0x54>
    return -1;
  if(pfd)
    80004a88:	00090463          	beqz	s2,80004a90 <argfd+0x3e>
    *pfd = fd;
    80004a8c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004a90:	4501                	li	a0,0
  if(pf)
    80004a92:	c091                	beqz	s1,80004a96 <argfd+0x44>
    *pf = f;
    80004a94:	e09c                	sd	a5,0(s1)
}
    80004a96:	70a2                	ld	ra,40(sp)
    80004a98:	7402                	ld	s0,32(sp)
    80004a9a:	64e2                	ld	s1,24(sp)
    80004a9c:	6942                	ld	s2,16(sp)
    80004a9e:	6145                	addi	sp,sp,48
    80004aa0:	8082                	ret
    return -1;
    80004aa2:	557d                	li	a0,-1
    80004aa4:	bfcd                	j	80004a96 <argfd+0x44>
    80004aa6:	557d                	li	a0,-1
    80004aa8:	b7fd                	j	80004a96 <argfd+0x44>

0000000080004aaa <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004aaa:	1101                	addi	sp,sp,-32
    80004aac:	ec06                	sd	ra,24(sp)
    80004aae:	e822                	sd	s0,16(sp)
    80004ab0:	e426                	sd	s1,8(sp)
    80004ab2:	1000                	addi	s0,sp,32
    80004ab4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004ab6:	846fd0ef          	jal	ra,80001afc <myproc>
    80004aba:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004abc:	0d050793          	addi	a5,a0,208
    80004ac0:	4501                	li	a0,0
    80004ac2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004ac4:	6398                	ld	a4,0(a5)
    80004ac6:	cb19                	beqz	a4,80004adc <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004ac8:	2505                	addiw	a0,a0,1
    80004aca:	07a1                	addi	a5,a5,8
    80004acc:	fed51ce3          	bne	a0,a3,80004ac4 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004ad0:	557d                	li	a0,-1
}
    80004ad2:	60e2                	ld	ra,24(sp)
    80004ad4:	6442                	ld	s0,16(sp)
    80004ad6:	64a2                	ld	s1,8(sp)
    80004ad8:	6105                	addi	sp,sp,32
    80004ada:	8082                	ret
      p->ofile[fd] = f;
    80004adc:	01a50793          	addi	a5,a0,26
    80004ae0:	078e                	slli	a5,a5,0x3
    80004ae2:	963e                	add	a2,a2,a5
    80004ae4:	e204                	sd	s1,0(a2)
      return fd;
    80004ae6:	b7f5                	j	80004ad2 <fdalloc+0x28>

0000000080004ae8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004ae8:	715d                	addi	sp,sp,-80
    80004aea:	e486                	sd	ra,72(sp)
    80004aec:	e0a2                	sd	s0,64(sp)
    80004aee:	fc26                	sd	s1,56(sp)
    80004af0:	f84a                	sd	s2,48(sp)
    80004af2:	f44e                	sd	s3,40(sp)
    80004af4:	f052                	sd	s4,32(sp)
    80004af6:	ec56                	sd	s5,24(sp)
    80004af8:	e85a                	sd	s6,16(sp)
    80004afa:	0880                	addi	s0,sp,80
    80004afc:	8b2e                	mv	s6,a1
    80004afe:	89b2                	mv	s3,a2
    80004b00:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004b02:	fb040593          	addi	a1,s0,-80
    80004b06:	8f0ff0ef          	jal	ra,80003bf6 <nameiparent>
    80004b0a:	84aa                	mv	s1,a0
    80004b0c:	10050b63          	beqz	a0,80004c22 <create+0x13a>
    return 0;

  ilock(dp);
    80004b10:	8dffe0ef          	jal	ra,800033ee <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004b14:	4601                	li	a2,0
    80004b16:	fb040593          	addi	a1,s0,-80
    80004b1a:	8526                	mv	a0,s1
    80004b1c:	e5bfe0ef          	jal	ra,80003976 <dirlookup>
    80004b20:	8aaa                	mv	s5,a0
    80004b22:	c521                	beqz	a0,80004b6a <create+0x82>
    iunlockput(dp);
    80004b24:	8526                	mv	a0,s1
    80004b26:	acffe0ef          	jal	ra,800035f4 <iunlockput>
    ilock(ip);
    80004b2a:	8556                	mv	a0,s5
    80004b2c:	8c3fe0ef          	jal	ra,800033ee <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004b30:	000b059b          	sext.w	a1,s6
    80004b34:	4789                	li	a5,2
    80004b36:	02f59563          	bne	a1,a5,80004b60 <create+0x78>
    80004b3a:	044ad783          	lhu	a5,68(s5)
    80004b3e:	37f9                	addiw	a5,a5,-2
    80004b40:	17c2                	slli	a5,a5,0x30
    80004b42:	93c1                	srli	a5,a5,0x30
    80004b44:	4705                	li	a4,1
    80004b46:	00f76d63          	bltu	a4,a5,80004b60 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004b4a:	8556                	mv	a0,s5
    80004b4c:	60a6                	ld	ra,72(sp)
    80004b4e:	6406                	ld	s0,64(sp)
    80004b50:	74e2                	ld	s1,56(sp)
    80004b52:	7942                	ld	s2,48(sp)
    80004b54:	79a2                	ld	s3,40(sp)
    80004b56:	7a02                	ld	s4,32(sp)
    80004b58:	6ae2                	ld	s5,24(sp)
    80004b5a:	6b42                	ld	s6,16(sp)
    80004b5c:	6161                	addi	sp,sp,80
    80004b5e:	8082                	ret
    iunlockput(ip);
    80004b60:	8556                	mv	a0,s5
    80004b62:	a93fe0ef          	jal	ra,800035f4 <iunlockput>
    return 0;
    80004b66:	4a81                	li	s5,0
    80004b68:	b7cd                	j	80004b4a <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004b6a:	85da                	mv	a1,s6
    80004b6c:	4088                	lw	a0,0(s1)
    80004b6e:	f18fe0ef          	jal	ra,80003286 <ialloc>
    80004b72:	8a2a                	mv	s4,a0
    80004b74:	cd1d                	beqz	a0,80004bb2 <create+0xca>
  ilock(ip);
    80004b76:	879fe0ef          	jal	ra,800033ee <ilock>
  ip->major = major;
    80004b7a:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004b7e:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004b82:	4905                	li	s2,1
    80004b84:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004b88:	8552                	mv	a0,s4
    80004b8a:	fb2fe0ef          	jal	ra,8000333c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004b8e:	000b059b          	sext.w	a1,s6
    80004b92:	03258563          	beq	a1,s2,80004bbc <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    80004b96:	004a2603          	lw	a2,4(s4)
    80004b9a:	fb040593          	addi	a1,s0,-80
    80004b9e:	8526                	mv	a0,s1
    80004ba0:	fa3fe0ef          	jal	ra,80003b42 <dirlink>
    80004ba4:	06054363          	bltz	a0,80004c0a <create+0x122>
  iunlockput(dp);
    80004ba8:	8526                	mv	a0,s1
    80004baa:	a4bfe0ef          	jal	ra,800035f4 <iunlockput>
  return ip;
    80004bae:	8ad2                	mv	s5,s4
    80004bb0:	bf69                	j	80004b4a <create+0x62>
    iunlockput(dp);
    80004bb2:	8526                	mv	a0,s1
    80004bb4:	a41fe0ef          	jal	ra,800035f4 <iunlockput>
    return 0;
    80004bb8:	8ad2                	mv	s5,s4
    80004bba:	bf41                	j	80004b4a <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004bbc:	004a2603          	lw	a2,4(s4)
    80004bc0:	00003597          	auipc	a1,0x3
    80004bc4:	ea858593          	addi	a1,a1,-344 # 80007a68 <syscalls+0x3b0>
    80004bc8:	8552                	mv	a0,s4
    80004bca:	f79fe0ef          	jal	ra,80003b42 <dirlink>
    80004bce:	02054e63          	bltz	a0,80004c0a <create+0x122>
    80004bd2:	40d0                	lw	a2,4(s1)
    80004bd4:	00003597          	auipc	a1,0x3
    80004bd8:	e9c58593          	addi	a1,a1,-356 # 80007a70 <syscalls+0x3b8>
    80004bdc:	8552                	mv	a0,s4
    80004bde:	f65fe0ef          	jal	ra,80003b42 <dirlink>
    80004be2:	02054463          	bltz	a0,80004c0a <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    80004be6:	004a2603          	lw	a2,4(s4)
    80004bea:	fb040593          	addi	a1,s0,-80
    80004bee:	8526                	mv	a0,s1
    80004bf0:	f53fe0ef          	jal	ra,80003b42 <dirlink>
    80004bf4:	00054b63          	bltz	a0,80004c0a <create+0x122>
    dp->nlink++;  // for ".."
    80004bf8:	04a4d783          	lhu	a5,74(s1)
    80004bfc:	2785                	addiw	a5,a5,1
    80004bfe:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004c02:	8526                	mv	a0,s1
    80004c04:	f38fe0ef          	jal	ra,8000333c <iupdate>
    80004c08:	b745                	j	80004ba8 <create+0xc0>
  ip->nlink = 0;
    80004c0a:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004c0e:	8552                	mv	a0,s4
    80004c10:	f2cfe0ef          	jal	ra,8000333c <iupdate>
  iunlockput(ip);
    80004c14:	8552                	mv	a0,s4
    80004c16:	9dffe0ef          	jal	ra,800035f4 <iunlockput>
  iunlockput(dp);
    80004c1a:	8526                	mv	a0,s1
    80004c1c:	9d9fe0ef          	jal	ra,800035f4 <iunlockput>
  return 0;
    80004c20:	b72d                	j	80004b4a <create+0x62>
    return 0;
    80004c22:	8aaa                	mv	s5,a0
    80004c24:	b71d                	j	80004b4a <create+0x62>

0000000080004c26 <sys_dup>:
{
    80004c26:	7179                	addi	sp,sp,-48
    80004c28:	f406                	sd	ra,40(sp)
    80004c2a:	f022                	sd	s0,32(sp)
    80004c2c:	ec26                	sd	s1,24(sp)
    80004c2e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004c30:	fd840613          	addi	a2,s0,-40
    80004c34:	4581                	li	a1,0
    80004c36:	4501                	li	a0,0
    80004c38:	e1bff0ef          	jal	ra,80004a52 <argfd>
    return -1;
    80004c3c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004c3e:	00054f63          	bltz	a0,80004c5c <sys_dup+0x36>
  if((fd=fdalloc(f)) < 0)
    80004c42:	fd843503          	ld	a0,-40(s0)
    80004c46:	e65ff0ef          	jal	ra,80004aaa <fdalloc>
    80004c4a:	84aa                	mv	s1,a0
    return -1;
    80004c4c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004c4e:	00054763          	bltz	a0,80004c5c <sys_dup+0x36>
  filedup(f);
    80004c52:	fd843503          	ld	a0,-40(s0)
    80004c56:	d3eff0ef          	jal	ra,80004194 <filedup>
  return fd;
    80004c5a:	87a6                	mv	a5,s1
}
    80004c5c:	853e                	mv	a0,a5
    80004c5e:	70a2                	ld	ra,40(sp)
    80004c60:	7402                	ld	s0,32(sp)
    80004c62:	64e2                	ld	s1,24(sp)
    80004c64:	6145                	addi	sp,sp,48
    80004c66:	8082                	ret

0000000080004c68 <sys_read>:
{
    80004c68:	7179                	addi	sp,sp,-48
    80004c6a:	f406                	sd	ra,40(sp)
    80004c6c:	f022                	sd	s0,32(sp)
    80004c6e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004c70:	fd840593          	addi	a1,s0,-40
    80004c74:	4505                	li	a0,1
    80004c76:	dbdfd0ef          	jal	ra,80002a32 <argaddr>
  argint(2, &n);
    80004c7a:	fe440593          	addi	a1,s0,-28
    80004c7e:	4509                	li	a0,2
    80004c80:	d97fd0ef          	jal	ra,80002a16 <argint>
  if(argfd(0, 0, &f) < 0)
    80004c84:	fe840613          	addi	a2,s0,-24
    80004c88:	4581                	li	a1,0
    80004c8a:	4501                	li	a0,0
    80004c8c:	dc7ff0ef          	jal	ra,80004a52 <argfd>
    80004c90:	87aa                	mv	a5,a0
    return -1;
    80004c92:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c94:	0007ca63          	bltz	a5,80004ca8 <sys_read+0x40>
  return fileread(f, p, n);
    80004c98:	fe442603          	lw	a2,-28(s0)
    80004c9c:	fd843583          	ld	a1,-40(s0)
    80004ca0:	fe843503          	ld	a0,-24(s0)
    80004ca4:	e3cff0ef          	jal	ra,800042e0 <fileread>
}
    80004ca8:	70a2                	ld	ra,40(sp)
    80004caa:	7402                	ld	s0,32(sp)
    80004cac:	6145                	addi	sp,sp,48
    80004cae:	8082                	ret

0000000080004cb0 <sys_write>:
{
    80004cb0:	7179                	addi	sp,sp,-48
    80004cb2:	f406                	sd	ra,40(sp)
    80004cb4:	f022                	sd	s0,32(sp)
    80004cb6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004cb8:	fd840593          	addi	a1,s0,-40
    80004cbc:	4505                	li	a0,1
    80004cbe:	d75fd0ef          	jal	ra,80002a32 <argaddr>
  argint(2, &n);
    80004cc2:	fe440593          	addi	a1,s0,-28
    80004cc6:	4509                	li	a0,2
    80004cc8:	d4ffd0ef          	jal	ra,80002a16 <argint>
  if(argfd(0, 0, &f) < 0)
    80004ccc:	fe840613          	addi	a2,s0,-24
    80004cd0:	4581                	li	a1,0
    80004cd2:	4501                	li	a0,0
    80004cd4:	d7fff0ef          	jal	ra,80004a52 <argfd>
    80004cd8:	87aa                	mv	a5,a0
    return -1;
    80004cda:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004cdc:	0007ca63          	bltz	a5,80004cf0 <sys_write+0x40>
  return filewrite(f, p, n);
    80004ce0:	fe442603          	lw	a2,-28(s0)
    80004ce4:	fd843583          	ld	a1,-40(s0)
    80004ce8:	fe843503          	ld	a0,-24(s0)
    80004cec:	ea2ff0ef          	jal	ra,8000438e <filewrite>
}
    80004cf0:	70a2                	ld	ra,40(sp)
    80004cf2:	7402                	ld	s0,32(sp)
    80004cf4:	6145                	addi	sp,sp,48
    80004cf6:	8082                	ret

0000000080004cf8 <sys_close>:
{
    80004cf8:	1101                	addi	sp,sp,-32
    80004cfa:	ec06                	sd	ra,24(sp)
    80004cfc:	e822                	sd	s0,16(sp)
    80004cfe:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004d00:	fe040613          	addi	a2,s0,-32
    80004d04:	fec40593          	addi	a1,s0,-20
    80004d08:	4501                	li	a0,0
    80004d0a:	d49ff0ef          	jal	ra,80004a52 <argfd>
    return -1;
    80004d0e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004d10:	02054063          	bltz	a0,80004d30 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004d14:	de9fc0ef          	jal	ra,80001afc <myproc>
    80004d18:	fec42783          	lw	a5,-20(s0)
    80004d1c:	07e9                	addi	a5,a5,26
    80004d1e:	078e                	slli	a5,a5,0x3
    80004d20:	97aa                	add	a5,a5,a0
    80004d22:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80004d26:	fe043503          	ld	a0,-32(s0)
    80004d2a:	cb0ff0ef          	jal	ra,800041da <fileclose>
  return 0;
    80004d2e:	4781                	li	a5,0
}
    80004d30:	853e                	mv	a0,a5
    80004d32:	60e2                	ld	ra,24(sp)
    80004d34:	6442                	ld	s0,16(sp)
    80004d36:	6105                	addi	sp,sp,32
    80004d38:	8082                	ret

0000000080004d3a <sys_fstat>:
{
    80004d3a:	1101                	addi	sp,sp,-32
    80004d3c:	ec06                	sd	ra,24(sp)
    80004d3e:	e822                	sd	s0,16(sp)
    80004d40:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004d42:	fe040593          	addi	a1,s0,-32
    80004d46:	4505                	li	a0,1
    80004d48:	cebfd0ef          	jal	ra,80002a32 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004d4c:	fe840613          	addi	a2,s0,-24
    80004d50:	4581                	li	a1,0
    80004d52:	4501                	li	a0,0
    80004d54:	cffff0ef          	jal	ra,80004a52 <argfd>
    80004d58:	87aa                	mv	a5,a0
    return -1;
    80004d5a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d5c:	0007c863          	bltz	a5,80004d6c <sys_fstat+0x32>
  return filestat(f, st);
    80004d60:	fe043583          	ld	a1,-32(s0)
    80004d64:	fe843503          	ld	a0,-24(s0)
    80004d68:	d1aff0ef          	jal	ra,80004282 <filestat>
}
    80004d6c:	60e2                	ld	ra,24(sp)
    80004d6e:	6442                	ld	s0,16(sp)
    80004d70:	6105                	addi	sp,sp,32
    80004d72:	8082                	ret

0000000080004d74 <sys_link>:
{
    80004d74:	7169                	addi	sp,sp,-304
    80004d76:	f606                	sd	ra,296(sp)
    80004d78:	f222                	sd	s0,288(sp)
    80004d7a:	ee26                	sd	s1,280(sp)
    80004d7c:	ea4a                	sd	s2,272(sp)
    80004d7e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d80:	08000613          	li	a2,128
    80004d84:	ed040593          	addi	a1,s0,-304
    80004d88:	4501                	li	a0,0
    80004d8a:	cc5fd0ef          	jal	ra,80002a4e <argstr>
    return -1;
    80004d8e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d90:	0c054663          	bltz	a0,80004e5c <sys_link+0xe8>
    80004d94:	08000613          	li	a2,128
    80004d98:	f5040593          	addi	a1,s0,-176
    80004d9c:	4505                	li	a0,1
    80004d9e:	cb1fd0ef          	jal	ra,80002a4e <argstr>
    return -1;
    80004da2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004da4:	0a054c63          	bltz	a0,80004e5c <sys_link+0xe8>
  begin_op();
    80004da8:	824ff0ef          	jal	ra,80003dcc <begin_op>
  if((ip = namei(old)) == 0){
    80004dac:	ed040513          	addi	a0,s0,-304
    80004db0:	e2dfe0ef          	jal	ra,80003bdc <namei>
    80004db4:	84aa                	mv	s1,a0
    80004db6:	c525                	beqz	a0,80004e1e <sys_link+0xaa>
  ilock(ip);
    80004db8:	e36fe0ef          	jal	ra,800033ee <ilock>
  if(ip->type == T_DIR){
    80004dbc:	04449703          	lh	a4,68(s1)
    80004dc0:	4785                	li	a5,1
    80004dc2:	06f70263          	beq	a4,a5,80004e26 <sys_link+0xb2>
  ip->nlink++;
    80004dc6:	04a4d783          	lhu	a5,74(s1)
    80004dca:	2785                	addiw	a5,a5,1
    80004dcc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004dd0:	8526                	mv	a0,s1
    80004dd2:	d6afe0ef          	jal	ra,8000333c <iupdate>
  iunlock(ip);
    80004dd6:	8526                	mv	a0,s1
    80004dd8:	ec0fe0ef          	jal	ra,80003498 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004ddc:	fd040593          	addi	a1,s0,-48
    80004de0:	f5040513          	addi	a0,s0,-176
    80004de4:	e13fe0ef          	jal	ra,80003bf6 <nameiparent>
    80004de8:	892a                	mv	s2,a0
    80004dea:	c921                	beqz	a0,80004e3a <sys_link+0xc6>
  ilock(dp);
    80004dec:	e02fe0ef          	jal	ra,800033ee <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004df0:	00092703          	lw	a4,0(s2)
    80004df4:	409c                	lw	a5,0(s1)
    80004df6:	02f71f63          	bne	a4,a5,80004e34 <sys_link+0xc0>
    80004dfa:	40d0                	lw	a2,4(s1)
    80004dfc:	fd040593          	addi	a1,s0,-48
    80004e00:	854a                	mv	a0,s2
    80004e02:	d41fe0ef          	jal	ra,80003b42 <dirlink>
    80004e06:	02054763          	bltz	a0,80004e34 <sys_link+0xc0>
  iunlockput(dp);
    80004e0a:	854a                	mv	a0,s2
    80004e0c:	fe8fe0ef          	jal	ra,800035f4 <iunlockput>
  iput(ip);
    80004e10:	8526                	mv	a0,s1
    80004e12:	f5afe0ef          	jal	ra,8000356c <iput>
  end_op();
    80004e16:	826ff0ef          	jal	ra,80003e3c <end_op>
  return 0;
    80004e1a:	4781                	li	a5,0
    80004e1c:	a081                	j	80004e5c <sys_link+0xe8>
    end_op();
    80004e1e:	81eff0ef          	jal	ra,80003e3c <end_op>
    return -1;
    80004e22:	57fd                	li	a5,-1
    80004e24:	a825                	j	80004e5c <sys_link+0xe8>
    iunlockput(ip);
    80004e26:	8526                	mv	a0,s1
    80004e28:	fccfe0ef          	jal	ra,800035f4 <iunlockput>
    end_op();
    80004e2c:	810ff0ef          	jal	ra,80003e3c <end_op>
    return -1;
    80004e30:	57fd                	li	a5,-1
    80004e32:	a02d                	j	80004e5c <sys_link+0xe8>
    iunlockput(dp);
    80004e34:	854a                	mv	a0,s2
    80004e36:	fbefe0ef          	jal	ra,800035f4 <iunlockput>
  ilock(ip);
    80004e3a:	8526                	mv	a0,s1
    80004e3c:	db2fe0ef          	jal	ra,800033ee <ilock>
  ip->nlink--;
    80004e40:	04a4d783          	lhu	a5,74(s1)
    80004e44:	37fd                	addiw	a5,a5,-1
    80004e46:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004e4a:	8526                	mv	a0,s1
    80004e4c:	cf0fe0ef          	jal	ra,8000333c <iupdate>
  iunlockput(ip);
    80004e50:	8526                	mv	a0,s1
    80004e52:	fa2fe0ef          	jal	ra,800035f4 <iunlockput>
  end_op();
    80004e56:	fe7fe0ef          	jal	ra,80003e3c <end_op>
  return -1;
    80004e5a:	57fd                	li	a5,-1
}
    80004e5c:	853e                	mv	a0,a5
    80004e5e:	70b2                	ld	ra,296(sp)
    80004e60:	7412                	ld	s0,288(sp)
    80004e62:	64f2                	ld	s1,280(sp)
    80004e64:	6952                	ld	s2,272(sp)
    80004e66:	6155                	addi	sp,sp,304
    80004e68:	8082                	ret

0000000080004e6a <sys_unlink>:
{
    80004e6a:	7151                	addi	sp,sp,-240
    80004e6c:	f586                	sd	ra,232(sp)
    80004e6e:	f1a2                	sd	s0,224(sp)
    80004e70:	eda6                	sd	s1,216(sp)
    80004e72:	e9ca                	sd	s2,208(sp)
    80004e74:	e5ce                	sd	s3,200(sp)
    80004e76:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004e78:	08000613          	li	a2,128
    80004e7c:	f3040593          	addi	a1,s0,-208
    80004e80:	4501                	li	a0,0
    80004e82:	bcdfd0ef          	jal	ra,80002a4e <argstr>
    80004e86:	12054b63          	bltz	a0,80004fbc <sys_unlink+0x152>
  begin_op();
    80004e8a:	f43fe0ef          	jal	ra,80003dcc <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004e8e:	fb040593          	addi	a1,s0,-80
    80004e92:	f3040513          	addi	a0,s0,-208
    80004e96:	d61fe0ef          	jal	ra,80003bf6 <nameiparent>
    80004e9a:	84aa                	mv	s1,a0
    80004e9c:	c54d                	beqz	a0,80004f46 <sys_unlink+0xdc>
  ilock(dp);
    80004e9e:	d50fe0ef          	jal	ra,800033ee <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004ea2:	00003597          	auipc	a1,0x3
    80004ea6:	bc658593          	addi	a1,a1,-1082 # 80007a68 <syscalls+0x3b0>
    80004eaa:	fb040513          	addi	a0,s0,-80
    80004eae:	ab3fe0ef          	jal	ra,80003960 <namecmp>
    80004eb2:	10050a63          	beqz	a0,80004fc6 <sys_unlink+0x15c>
    80004eb6:	00003597          	auipc	a1,0x3
    80004eba:	bba58593          	addi	a1,a1,-1094 # 80007a70 <syscalls+0x3b8>
    80004ebe:	fb040513          	addi	a0,s0,-80
    80004ec2:	a9ffe0ef          	jal	ra,80003960 <namecmp>
    80004ec6:	10050063          	beqz	a0,80004fc6 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004eca:	f2c40613          	addi	a2,s0,-212
    80004ece:	fb040593          	addi	a1,s0,-80
    80004ed2:	8526                	mv	a0,s1
    80004ed4:	aa3fe0ef          	jal	ra,80003976 <dirlookup>
    80004ed8:	892a                	mv	s2,a0
    80004eda:	0e050663          	beqz	a0,80004fc6 <sys_unlink+0x15c>
  ilock(ip);
    80004ede:	d10fe0ef          	jal	ra,800033ee <ilock>
  if(ip->nlink < 1)
    80004ee2:	04a91783          	lh	a5,74(s2)
    80004ee6:	06f05463          	blez	a5,80004f4e <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004eea:	04491703          	lh	a4,68(s2)
    80004eee:	4785                	li	a5,1
    80004ef0:	06f70563          	beq	a4,a5,80004f5a <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    80004ef4:	4641                	li	a2,16
    80004ef6:	4581                	li	a1,0
    80004ef8:	fc040513          	addi	a0,s0,-64
    80004efc:	d45fb0ef          	jal	ra,80000c40 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f00:	4741                	li	a4,16
    80004f02:	f2c42683          	lw	a3,-212(s0)
    80004f06:	fc040613          	addi	a2,s0,-64
    80004f0a:	4581                	li	a1,0
    80004f0c:	8526                	mv	a0,s1
    80004f0e:	951fe0ef          	jal	ra,8000385e <writei>
    80004f12:	47c1                	li	a5,16
    80004f14:	08f51563          	bne	a0,a5,80004f9e <sys_unlink+0x134>
  if(ip->type == T_DIR){
    80004f18:	04491703          	lh	a4,68(s2)
    80004f1c:	4785                	li	a5,1
    80004f1e:	08f70663          	beq	a4,a5,80004faa <sys_unlink+0x140>
  iunlockput(dp);
    80004f22:	8526                	mv	a0,s1
    80004f24:	ed0fe0ef          	jal	ra,800035f4 <iunlockput>
  ip->nlink--;
    80004f28:	04a95783          	lhu	a5,74(s2)
    80004f2c:	37fd                	addiw	a5,a5,-1
    80004f2e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004f32:	854a                	mv	a0,s2
    80004f34:	c08fe0ef          	jal	ra,8000333c <iupdate>
  iunlockput(ip);
    80004f38:	854a                	mv	a0,s2
    80004f3a:	ebafe0ef          	jal	ra,800035f4 <iunlockput>
  end_op();
    80004f3e:	efffe0ef          	jal	ra,80003e3c <end_op>
  return 0;
    80004f42:	4501                	li	a0,0
    80004f44:	a079                	j	80004fd2 <sys_unlink+0x168>
    end_op();
    80004f46:	ef7fe0ef          	jal	ra,80003e3c <end_op>
    return -1;
    80004f4a:	557d                	li	a0,-1
    80004f4c:	a059                	j	80004fd2 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80004f4e:	00003517          	auipc	a0,0x3
    80004f52:	b2a50513          	addi	a0,a0,-1238 # 80007a78 <syscalls+0x3c0>
    80004f56:	835fb0ef          	jal	ra,8000078a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004f5a:	04c92703          	lw	a4,76(s2)
    80004f5e:	02000793          	li	a5,32
    80004f62:	f8e7f9e3          	bgeu	a5,a4,80004ef4 <sys_unlink+0x8a>
    80004f66:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f6a:	4741                	li	a4,16
    80004f6c:	86ce                	mv	a3,s3
    80004f6e:	f1840613          	addi	a2,s0,-232
    80004f72:	4581                	li	a1,0
    80004f74:	854a                	mv	a0,s2
    80004f76:	805fe0ef          	jal	ra,8000377a <readi>
    80004f7a:	47c1                	li	a5,16
    80004f7c:	00f51b63          	bne	a0,a5,80004f92 <sys_unlink+0x128>
    if(de.inum != 0)
    80004f80:	f1845783          	lhu	a5,-232(s0)
    80004f84:	ef95                	bnez	a5,80004fc0 <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004f86:	29c1                	addiw	s3,s3,16
    80004f88:	04c92783          	lw	a5,76(s2)
    80004f8c:	fcf9efe3          	bltu	s3,a5,80004f6a <sys_unlink+0x100>
    80004f90:	b795                	j	80004ef4 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004f92:	00003517          	auipc	a0,0x3
    80004f96:	afe50513          	addi	a0,a0,-1282 # 80007a90 <syscalls+0x3d8>
    80004f9a:	ff0fb0ef          	jal	ra,8000078a <panic>
    panic("unlink: writei");
    80004f9e:	00003517          	auipc	a0,0x3
    80004fa2:	b0a50513          	addi	a0,a0,-1270 # 80007aa8 <syscalls+0x3f0>
    80004fa6:	fe4fb0ef          	jal	ra,8000078a <panic>
    dp->nlink--;
    80004faa:	04a4d783          	lhu	a5,74(s1)
    80004fae:	37fd                	addiw	a5,a5,-1
    80004fb0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004fb4:	8526                	mv	a0,s1
    80004fb6:	b86fe0ef          	jal	ra,8000333c <iupdate>
    80004fba:	b7a5                	j	80004f22 <sys_unlink+0xb8>
    return -1;
    80004fbc:	557d                	li	a0,-1
    80004fbe:	a811                	j	80004fd2 <sys_unlink+0x168>
    iunlockput(ip);
    80004fc0:	854a                	mv	a0,s2
    80004fc2:	e32fe0ef          	jal	ra,800035f4 <iunlockput>
  iunlockput(dp);
    80004fc6:	8526                	mv	a0,s1
    80004fc8:	e2cfe0ef          	jal	ra,800035f4 <iunlockput>
  end_op();
    80004fcc:	e71fe0ef          	jal	ra,80003e3c <end_op>
  return -1;
    80004fd0:	557d                	li	a0,-1
}
    80004fd2:	70ae                	ld	ra,232(sp)
    80004fd4:	740e                	ld	s0,224(sp)
    80004fd6:	64ee                	ld	s1,216(sp)
    80004fd8:	694e                	ld	s2,208(sp)
    80004fda:	69ae                	ld	s3,200(sp)
    80004fdc:	616d                	addi	sp,sp,240
    80004fde:	8082                	ret

0000000080004fe0 <sys_open>:

uint64
sys_open(void)
{
    80004fe0:	7131                	addi	sp,sp,-192
    80004fe2:	fd06                	sd	ra,184(sp)
    80004fe4:	f922                	sd	s0,176(sp)
    80004fe6:	f526                	sd	s1,168(sp)
    80004fe8:	f14a                	sd	s2,160(sp)
    80004fea:	ed4e                	sd	s3,152(sp)
    80004fec:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004fee:	f4c40593          	addi	a1,s0,-180
    80004ff2:	4505                	li	a0,1
    80004ff4:	a23fd0ef          	jal	ra,80002a16 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004ff8:	08000613          	li	a2,128
    80004ffc:	f5040593          	addi	a1,s0,-176
    80005000:	4501                	li	a0,0
    80005002:	a4dfd0ef          	jal	ra,80002a4e <argstr>
    80005006:	87aa                	mv	a5,a0
    return -1;
    80005008:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000500a:	0807cd63          	bltz	a5,800050a4 <sys_open+0xc4>

  begin_op();
    8000500e:	dbffe0ef          	jal	ra,80003dcc <begin_op>

  if(omode & O_CREATE){
    80005012:	f4c42783          	lw	a5,-180(s0)
    80005016:	2007f793          	andi	a5,a5,512
    8000501a:	c3c5                	beqz	a5,800050ba <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    8000501c:	4681                	li	a3,0
    8000501e:	4601                	li	a2,0
    80005020:	4589                	li	a1,2
    80005022:	f5040513          	addi	a0,s0,-176
    80005026:	ac3ff0ef          	jal	ra,80004ae8 <create>
    8000502a:	84aa                	mv	s1,a0
    if(ip == 0){
    8000502c:	c159                	beqz	a0,800050b2 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000502e:	04449703          	lh	a4,68(s1)
    80005032:	478d                	li	a5,3
    80005034:	00f71763          	bne	a4,a5,80005042 <sys_open+0x62>
    80005038:	0464d703          	lhu	a4,70(s1)
    8000503c:	47a5                	li	a5,9
    8000503e:	0ae7e963          	bltu	a5,a4,800050f0 <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005042:	8f4ff0ef          	jal	ra,80004136 <filealloc>
    80005046:	89aa                	mv	s3,a0
    80005048:	0c050963          	beqz	a0,8000511a <sys_open+0x13a>
    8000504c:	a5fff0ef          	jal	ra,80004aaa <fdalloc>
    80005050:	892a                	mv	s2,a0
    80005052:	0c054163          	bltz	a0,80005114 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005056:	04449703          	lh	a4,68(s1)
    8000505a:	478d                	li	a5,3
    8000505c:	0af70163          	beq	a4,a5,800050fe <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005060:	4789                	li	a5,2
    80005062:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005066:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000506a:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000506e:	f4c42783          	lw	a5,-180(s0)
    80005072:	0017c713          	xori	a4,a5,1
    80005076:	8b05                	andi	a4,a4,1
    80005078:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000507c:	0037f713          	andi	a4,a5,3
    80005080:	00e03733          	snez	a4,a4
    80005084:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005088:	4007f793          	andi	a5,a5,1024
    8000508c:	c791                	beqz	a5,80005098 <sys_open+0xb8>
    8000508e:	04449703          	lh	a4,68(s1)
    80005092:	4789                	li	a5,2
    80005094:	06f70c63          	beq	a4,a5,8000510c <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    80005098:	8526                	mv	a0,s1
    8000509a:	bfefe0ef          	jal	ra,80003498 <iunlock>
  end_op();
    8000509e:	d9ffe0ef          	jal	ra,80003e3c <end_op>

  return fd;
    800050a2:	854a                	mv	a0,s2
}
    800050a4:	70ea                	ld	ra,184(sp)
    800050a6:	744a                	ld	s0,176(sp)
    800050a8:	74aa                	ld	s1,168(sp)
    800050aa:	790a                	ld	s2,160(sp)
    800050ac:	69ea                	ld	s3,152(sp)
    800050ae:	6129                	addi	sp,sp,192
    800050b0:	8082                	ret
      end_op();
    800050b2:	d8bfe0ef          	jal	ra,80003e3c <end_op>
      return -1;
    800050b6:	557d                	li	a0,-1
    800050b8:	b7f5                	j	800050a4 <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    800050ba:	f5040513          	addi	a0,s0,-176
    800050be:	b1ffe0ef          	jal	ra,80003bdc <namei>
    800050c2:	84aa                	mv	s1,a0
    800050c4:	c115                	beqz	a0,800050e8 <sys_open+0x108>
    ilock(ip);
    800050c6:	b28fe0ef          	jal	ra,800033ee <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800050ca:	04449703          	lh	a4,68(s1)
    800050ce:	4785                	li	a5,1
    800050d0:	f4f71fe3          	bne	a4,a5,8000502e <sys_open+0x4e>
    800050d4:	f4c42783          	lw	a5,-180(s0)
    800050d8:	d7ad                	beqz	a5,80005042 <sys_open+0x62>
      iunlockput(ip);
    800050da:	8526                	mv	a0,s1
    800050dc:	d18fe0ef          	jal	ra,800035f4 <iunlockput>
      end_op();
    800050e0:	d5dfe0ef          	jal	ra,80003e3c <end_op>
      return -1;
    800050e4:	557d                	li	a0,-1
    800050e6:	bf7d                	j	800050a4 <sys_open+0xc4>
      end_op();
    800050e8:	d55fe0ef          	jal	ra,80003e3c <end_op>
      return -1;
    800050ec:	557d                	li	a0,-1
    800050ee:	bf5d                	j	800050a4 <sys_open+0xc4>
    iunlockput(ip);
    800050f0:	8526                	mv	a0,s1
    800050f2:	d02fe0ef          	jal	ra,800035f4 <iunlockput>
    end_op();
    800050f6:	d47fe0ef          	jal	ra,80003e3c <end_op>
    return -1;
    800050fa:	557d                	li	a0,-1
    800050fc:	b765                	j	800050a4 <sys_open+0xc4>
    f->type = FD_DEVICE;
    800050fe:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005102:	04649783          	lh	a5,70(s1)
    80005106:	02f99223          	sh	a5,36(s3)
    8000510a:	b785                	j	8000506a <sys_open+0x8a>
    itrunc(ip);
    8000510c:	8526                	mv	a0,s1
    8000510e:	bcafe0ef          	jal	ra,800034d8 <itrunc>
    80005112:	b759                	j	80005098 <sys_open+0xb8>
      fileclose(f);
    80005114:	854e                	mv	a0,s3
    80005116:	8c4ff0ef          	jal	ra,800041da <fileclose>
    iunlockput(ip);
    8000511a:	8526                	mv	a0,s1
    8000511c:	cd8fe0ef          	jal	ra,800035f4 <iunlockput>
    end_op();
    80005120:	d1dfe0ef          	jal	ra,80003e3c <end_op>
    return -1;
    80005124:	557d                	li	a0,-1
    80005126:	bfbd                	j	800050a4 <sys_open+0xc4>

0000000080005128 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005128:	7175                	addi	sp,sp,-144
    8000512a:	e506                	sd	ra,136(sp)
    8000512c:	e122                	sd	s0,128(sp)
    8000512e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005130:	c9dfe0ef          	jal	ra,80003dcc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005134:	08000613          	li	a2,128
    80005138:	f7040593          	addi	a1,s0,-144
    8000513c:	4501                	li	a0,0
    8000513e:	911fd0ef          	jal	ra,80002a4e <argstr>
    80005142:	02054363          	bltz	a0,80005168 <sys_mkdir+0x40>
    80005146:	4681                	li	a3,0
    80005148:	4601                	li	a2,0
    8000514a:	4585                	li	a1,1
    8000514c:	f7040513          	addi	a0,s0,-144
    80005150:	999ff0ef          	jal	ra,80004ae8 <create>
    80005154:	c911                	beqz	a0,80005168 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005156:	c9efe0ef          	jal	ra,800035f4 <iunlockput>
  end_op();
    8000515a:	ce3fe0ef          	jal	ra,80003e3c <end_op>
  return 0;
    8000515e:	4501                	li	a0,0
}
    80005160:	60aa                	ld	ra,136(sp)
    80005162:	640a                	ld	s0,128(sp)
    80005164:	6149                	addi	sp,sp,144
    80005166:	8082                	ret
    end_op();
    80005168:	cd5fe0ef          	jal	ra,80003e3c <end_op>
    return -1;
    8000516c:	557d                	li	a0,-1
    8000516e:	bfcd                	j	80005160 <sys_mkdir+0x38>

0000000080005170 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005170:	7135                	addi	sp,sp,-160
    80005172:	ed06                	sd	ra,152(sp)
    80005174:	e922                	sd	s0,144(sp)
    80005176:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005178:	c55fe0ef          	jal	ra,80003dcc <begin_op>
  argint(1, &major);
    8000517c:	f6c40593          	addi	a1,s0,-148
    80005180:	4505                	li	a0,1
    80005182:	895fd0ef          	jal	ra,80002a16 <argint>
  argint(2, &minor);
    80005186:	f6840593          	addi	a1,s0,-152
    8000518a:	4509                	li	a0,2
    8000518c:	88bfd0ef          	jal	ra,80002a16 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005190:	08000613          	li	a2,128
    80005194:	f7040593          	addi	a1,s0,-144
    80005198:	4501                	li	a0,0
    8000519a:	8b5fd0ef          	jal	ra,80002a4e <argstr>
    8000519e:	02054563          	bltz	a0,800051c8 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800051a2:	f6841683          	lh	a3,-152(s0)
    800051a6:	f6c41603          	lh	a2,-148(s0)
    800051aa:	458d                	li	a1,3
    800051ac:	f7040513          	addi	a0,s0,-144
    800051b0:	939ff0ef          	jal	ra,80004ae8 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800051b4:	c911                	beqz	a0,800051c8 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800051b6:	c3efe0ef          	jal	ra,800035f4 <iunlockput>
  end_op();
    800051ba:	c83fe0ef          	jal	ra,80003e3c <end_op>
  return 0;
    800051be:	4501                	li	a0,0
}
    800051c0:	60ea                	ld	ra,152(sp)
    800051c2:	644a                	ld	s0,144(sp)
    800051c4:	610d                	addi	sp,sp,160
    800051c6:	8082                	ret
    end_op();
    800051c8:	c75fe0ef          	jal	ra,80003e3c <end_op>
    return -1;
    800051cc:	557d                	li	a0,-1
    800051ce:	bfcd                	j	800051c0 <sys_mknod+0x50>

00000000800051d0 <sys_chdir>:

uint64
sys_chdir(void)
{
    800051d0:	7135                	addi	sp,sp,-160
    800051d2:	ed06                	sd	ra,152(sp)
    800051d4:	e922                	sd	s0,144(sp)
    800051d6:	e526                	sd	s1,136(sp)
    800051d8:	e14a                	sd	s2,128(sp)
    800051da:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800051dc:	921fc0ef          	jal	ra,80001afc <myproc>
    800051e0:	892a                	mv	s2,a0
  
  begin_op();
    800051e2:	bebfe0ef          	jal	ra,80003dcc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800051e6:	08000613          	li	a2,128
    800051ea:	f6040593          	addi	a1,s0,-160
    800051ee:	4501                	li	a0,0
    800051f0:	85ffd0ef          	jal	ra,80002a4e <argstr>
    800051f4:	04054163          	bltz	a0,80005236 <sys_chdir+0x66>
    800051f8:	f6040513          	addi	a0,s0,-160
    800051fc:	9e1fe0ef          	jal	ra,80003bdc <namei>
    80005200:	84aa                	mv	s1,a0
    80005202:	c915                	beqz	a0,80005236 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005204:	9eafe0ef          	jal	ra,800033ee <ilock>
  if(ip->type != T_DIR){
    80005208:	04449703          	lh	a4,68(s1)
    8000520c:	4785                	li	a5,1
    8000520e:	02f71863          	bne	a4,a5,8000523e <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005212:	8526                	mv	a0,s1
    80005214:	a84fe0ef          	jal	ra,80003498 <iunlock>
  iput(p->cwd);
    80005218:	15093503          	ld	a0,336(s2)
    8000521c:	b50fe0ef          	jal	ra,8000356c <iput>
  end_op();
    80005220:	c1dfe0ef          	jal	ra,80003e3c <end_op>
  p->cwd = ip;
    80005224:	14993823          	sd	s1,336(s2)
  return 0;
    80005228:	4501                	li	a0,0
}
    8000522a:	60ea                	ld	ra,152(sp)
    8000522c:	644a                	ld	s0,144(sp)
    8000522e:	64aa                	ld	s1,136(sp)
    80005230:	690a                	ld	s2,128(sp)
    80005232:	610d                	addi	sp,sp,160
    80005234:	8082                	ret
    end_op();
    80005236:	c07fe0ef          	jal	ra,80003e3c <end_op>
    return -1;
    8000523a:	557d                	li	a0,-1
    8000523c:	b7fd                	j	8000522a <sys_chdir+0x5a>
    iunlockput(ip);
    8000523e:	8526                	mv	a0,s1
    80005240:	bb4fe0ef          	jal	ra,800035f4 <iunlockput>
    end_op();
    80005244:	bf9fe0ef          	jal	ra,80003e3c <end_op>
    return -1;
    80005248:	557d                	li	a0,-1
    8000524a:	b7c5                	j	8000522a <sys_chdir+0x5a>

000000008000524c <sys_exec>:

uint64
sys_exec(void)
{
    8000524c:	7145                	addi	sp,sp,-464
    8000524e:	e786                	sd	ra,456(sp)
    80005250:	e3a2                	sd	s0,448(sp)
    80005252:	ff26                	sd	s1,440(sp)
    80005254:	fb4a                	sd	s2,432(sp)
    80005256:	f74e                	sd	s3,424(sp)
    80005258:	f352                	sd	s4,416(sp)
    8000525a:	ef56                	sd	s5,408(sp)
    8000525c:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000525e:	e3840593          	addi	a1,s0,-456
    80005262:	4505                	li	a0,1
    80005264:	fcefd0ef          	jal	ra,80002a32 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005268:	08000613          	li	a2,128
    8000526c:	f4040593          	addi	a1,s0,-192
    80005270:	4501                	li	a0,0
    80005272:	fdcfd0ef          	jal	ra,80002a4e <argstr>
    80005276:	87aa                	mv	a5,a0
    return -1;
    80005278:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000527a:	0a07c463          	bltz	a5,80005322 <sys_exec+0xd6>
  }
  memset(argv, 0, sizeof(argv));
    8000527e:	10000613          	li	a2,256
    80005282:	4581                	li	a1,0
    80005284:	e4040513          	addi	a0,s0,-448
    80005288:	9b9fb0ef          	jal	ra,80000c40 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000528c:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005290:	89a6                	mv	s3,s1
    80005292:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005294:	02000a13          	li	s4,32
    80005298:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000529c:	00391793          	slli	a5,s2,0x3
    800052a0:	e3040593          	addi	a1,s0,-464
    800052a4:	e3843503          	ld	a0,-456(s0)
    800052a8:	953e                	add	a0,a0,a5
    800052aa:	ee2fd0ef          	jal	ra,8000298c <fetchaddr>
    800052ae:	02054663          	bltz	a0,800052da <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    800052b2:	e3043783          	ld	a5,-464(s0)
    800052b6:	cf8d                	beqz	a5,800052f0 <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800052b8:	fe4fb0ef          	jal	ra,80000a9c <kalloc>
    800052bc:	85aa                	mv	a1,a0
    800052be:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800052c2:	cd01                	beqz	a0,800052da <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800052c4:	6605                	lui	a2,0x1
    800052c6:	e3043503          	ld	a0,-464(s0)
    800052ca:	f0cfd0ef          	jal	ra,800029d6 <fetchstr>
    800052ce:	00054663          	bltz	a0,800052da <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    800052d2:	0905                	addi	s2,s2,1
    800052d4:	09a1                	addi	s3,s3,8
    800052d6:	fd4911e3          	bne	s2,s4,80005298 <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800052da:	10048913          	addi	s2,s1,256
    800052de:	6088                	ld	a0,0(s1)
    800052e0:	c121                	beqz	a0,80005320 <sys_exec+0xd4>
    kfree(argv[i]);
    800052e2:	edafb0ef          	jal	ra,800009bc <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800052e6:	04a1                	addi	s1,s1,8
    800052e8:	ff249be3          	bne	s1,s2,800052de <sys_exec+0x92>
  return -1;
    800052ec:	557d                	li	a0,-1
    800052ee:	a815                	j	80005322 <sys_exec+0xd6>
      argv[i] = 0;
    800052f0:	0a8e                	slli	s5,s5,0x3
    800052f2:	fc040793          	addi	a5,s0,-64
    800052f6:	9abe                	add	s5,s5,a5
    800052f8:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    800052fc:	e4040593          	addi	a1,s0,-448
    80005300:	f4040513          	addi	a0,s0,-192
    80005304:	c78ff0ef          	jal	ra,8000477c <kexec>
    80005308:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000530a:	10048993          	addi	s3,s1,256
    8000530e:	6088                	ld	a0,0(s1)
    80005310:	c511                	beqz	a0,8000531c <sys_exec+0xd0>
    kfree(argv[i]);
    80005312:	eaafb0ef          	jal	ra,800009bc <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005316:	04a1                	addi	s1,s1,8
    80005318:	ff349be3          	bne	s1,s3,8000530e <sys_exec+0xc2>
  return ret;
    8000531c:	854a                	mv	a0,s2
    8000531e:	a011                	j	80005322 <sys_exec+0xd6>
  return -1;
    80005320:	557d                	li	a0,-1
}
    80005322:	60be                	ld	ra,456(sp)
    80005324:	641e                	ld	s0,448(sp)
    80005326:	74fa                	ld	s1,440(sp)
    80005328:	795a                	ld	s2,432(sp)
    8000532a:	79ba                	ld	s3,424(sp)
    8000532c:	7a1a                	ld	s4,416(sp)
    8000532e:	6afa                	ld	s5,408(sp)
    80005330:	6179                	addi	sp,sp,464
    80005332:	8082                	ret

0000000080005334 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005334:	7139                	addi	sp,sp,-64
    80005336:	fc06                	sd	ra,56(sp)
    80005338:	f822                	sd	s0,48(sp)
    8000533a:	f426                	sd	s1,40(sp)
    8000533c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000533e:	fbefc0ef          	jal	ra,80001afc <myproc>
    80005342:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005344:	fd840593          	addi	a1,s0,-40
    80005348:	4501                	li	a0,0
    8000534a:	ee8fd0ef          	jal	ra,80002a32 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000534e:	fc840593          	addi	a1,s0,-56
    80005352:	fd040513          	addi	a0,s0,-48
    80005356:	950ff0ef          	jal	ra,800044a6 <pipealloc>
    return -1;
    8000535a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000535c:	0a054463          	bltz	a0,80005404 <sys_pipe+0xd0>
  fd0 = -1;
    80005360:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005364:	fd043503          	ld	a0,-48(s0)
    80005368:	f42ff0ef          	jal	ra,80004aaa <fdalloc>
    8000536c:	fca42223          	sw	a0,-60(s0)
    80005370:	08054163          	bltz	a0,800053f2 <sys_pipe+0xbe>
    80005374:	fc843503          	ld	a0,-56(s0)
    80005378:	f32ff0ef          	jal	ra,80004aaa <fdalloc>
    8000537c:	fca42023          	sw	a0,-64(s0)
    80005380:	06054063          	bltz	a0,800053e0 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005384:	4691                	li	a3,4
    80005386:	fc440613          	addi	a2,s0,-60
    8000538a:	fd843583          	ld	a1,-40(s0)
    8000538e:	68a8                	ld	a0,80(s1)
    80005390:	cbafc0ef          	jal	ra,8000184a <copyout>
    80005394:	00054e63          	bltz	a0,800053b0 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005398:	4691                	li	a3,4
    8000539a:	fc040613          	addi	a2,s0,-64
    8000539e:	fd843583          	ld	a1,-40(s0)
    800053a2:	0591                	addi	a1,a1,4
    800053a4:	68a8                	ld	a0,80(s1)
    800053a6:	ca4fc0ef          	jal	ra,8000184a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800053aa:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800053ac:	04055c63          	bgez	a0,80005404 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800053b0:	fc442783          	lw	a5,-60(s0)
    800053b4:	07e9                	addi	a5,a5,26
    800053b6:	078e                	slli	a5,a5,0x3
    800053b8:	97a6                	add	a5,a5,s1
    800053ba:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800053be:	fc042503          	lw	a0,-64(s0)
    800053c2:	0569                	addi	a0,a0,26
    800053c4:	050e                	slli	a0,a0,0x3
    800053c6:	94aa                	add	s1,s1,a0
    800053c8:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800053cc:	fd043503          	ld	a0,-48(s0)
    800053d0:	e0bfe0ef          	jal	ra,800041da <fileclose>
    fileclose(wf);
    800053d4:	fc843503          	ld	a0,-56(s0)
    800053d8:	e03fe0ef          	jal	ra,800041da <fileclose>
    return -1;
    800053dc:	57fd                	li	a5,-1
    800053de:	a01d                	j	80005404 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800053e0:	fc442783          	lw	a5,-60(s0)
    800053e4:	0007c763          	bltz	a5,800053f2 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800053e8:	07e9                	addi	a5,a5,26
    800053ea:	078e                	slli	a5,a5,0x3
    800053ec:	94be                	add	s1,s1,a5
    800053ee:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800053f2:	fd043503          	ld	a0,-48(s0)
    800053f6:	de5fe0ef          	jal	ra,800041da <fileclose>
    fileclose(wf);
    800053fa:	fc843503          	ld	a0,-56(s0)
    800053fe:	dddfe0ef          	jal	ra,800041da <fileclose>
    return -1;
    80005402:	57fd                	li	a5,-1
}
    80005404:	853e                	mv	a0,a5
    80005406:	70e2                	ld	ra,56(sp)
    80005408:	7442                	ld	s0,48(sp)
    8000540a:	74a2                	ld	s1,40(sp)
    8000540c:	6121                	addi	sp,sp,64
    8000540e:	8082                	ret

0000000080005410 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005410:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005412:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005414:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005416:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005418:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000541a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000541c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000541e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005420:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005422:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005424:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005426:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005428:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000542a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000542c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000542e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005430:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005432:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005434:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005436:	c66fd0ef          	jal	ra,8000289c <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000543a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000543c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000543e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005440:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005442:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005444:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005446:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005448:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000544a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000544c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000544e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005450:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005452:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005454:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005456:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005458:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000545a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000545c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000545e:	10200073          	sret
	...

000000008000546e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000546e:	1141                	addi	sp,sp,-16
    80005470:	e422                	sd	s0,8(sp)
    80005472:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005474:	0c0007b7          	lui	a5,0xc000
    80005478:	4705                	li	a4,1
    8000547a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000547c:	c3d8                	sw	a4,4(a5)
}
    8000547e:	6422                	ld	s0,8(sp)
    80005480:	0141                	addi	sp,sp,16
    80005482:	8082                	ret

0000000080005484 <plicinithart>:

void
plicinithart(void)
{
    80005484:	1141                	addi	sp,sp,-16
    80005486:	e406                	sd	ra,8(sp)
    80005488:	e022                	sd	s0,0(sp)
    8000548a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000548c:	e44fc0ef          	jal	ra,80001ad0 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005490:	0085171b          	slliw	a4,a0,0x8
    80005494:	0c0027b7          	lui	a5,0xc002
    80005498:	97ba                	add	a5,a5,a4
    8000549a:	40200713          	li	a4,1026
    8000549e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800054a2:	00d5151b          	slliw	a0,a0,0xd
    800054a6:	0c2017b7          	lui	a5,0xc201
    800054aa:	953e                	add	a0,a0,a5
    800054ac:	00052023          	sw	zero,0(a0)
}
    800054b0:	60a2                	ld	ra,8(sp)
    800054b2:	6402                	ld	s0,0(sp)
    800054b4:	0141                	addi	sp,sp,16
    800054b6:	8082                	ret

00000000800054b8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800054b8:	1141                	addi	sp,sp,-16
    800054ba:	e406                	sd	ra,8(sp)
    800054bc:	e022                	sd	s0,0(sp)
    800054be:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800054c0:	e10fc0ef          	jal	ra,80001ad0 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800054c4:	00d5179b          	slliw	a5,a0,0xd
    800054c8:	0c201537          	lui	a0,0xc201
    800054cc:	953e                	add	a0,a0,a5
  return irq;
}
    800054ce:	4148                	lw	a0,4(a0)
    800054d0:	60a2                	ld	ra,8(sp)
    800054d2:	6402                	ld	s0,0(sp)
    800054d4:	0141                	addi	sp,sp,16
    800054d6:	8082                	ret

00000000800054d8 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800054d8:	1101                	addi	sp,sp,-32
    800054da:	ec06                	sd	ra,24(sp)
    800054dc:	e822                	sd	s0,16(sp)
    800054de:	e426                	sd	s1,8(sp)
    800054e0:	1000                	addi	s0,sp,32
    800054e2:	84aa                	mv	s1,a0
  int hart = cpuid();
    800054e4:	decfc0ef          	jal	ra,80001ad0 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800054e8:	00d5151b          	slliw	a0,a0,0xd
    800054ec:	0c2017b7          	lui	a5,0xc201
    800054f0:	97aa                	add	a5,a5,a0
    800054f2:	c3c4                	sw	s1,4(a5)
}
    800054f4:	60e2                	ld	ra,24(sp)
    800054f6:	6442                	ld	s0,16(sp)
    800054f8:	64a2                	ld	s1,8(sp)
    800054fa:	6105                	addi	sp,sp,32
    800054fc:	8082                	ret

00000000800054fe <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800054fe:	1141                	addi	sp,sp,-16
    80005500:	e406                	sd	ra,8(sp)
    80005502:	e022                	sd	s0,0(sp)
    80005504:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005506:	479d                	li	a5,7
    80005508:	04a7ca63          	blt	a5,a0,8000555c <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    8000550c:	0001c797          	auipc	a5,0x1c
    80005510:	6bc78793          	addi	a5,a5,1724 # 80021bc8 <disk>
    80005514:	97aa                	add	a5,a5,a0
    80005516:	0187c783          	lbu	a5,24(a5)
    8000551a:	e7b9                	bnez	a5,80005568 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000551c:	00451613          	slli	a2,a0,0x4
    80005520:	0001c797          	auipc	a5,0x1c
    80005524:	6a878793          	addi	a5,a5,1704 # 80021bc8 <disk>
    80005528:	6394                	ld	a3,0(a5)
    8000552a:	96b2                	add	a3,a3,a2
    8000552c:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005530:	6398                	ld	a4,0(a5)
    80005532:	9732                	add	a4,a4,a2
    80005534:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005538:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    8000553c:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005540:	953e                	add	a0,a0,a5
    80005542:	4785                	li	a5,1
    80005544:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005548:	0001c517          	auipc	a0,0x1c
    8000554c:	69850513          	addi	a0,a0,1688 # 80021be0 <disk+0x18>
    80005550:	c0bfc0ef          	jal	ra,8000215a <wakeup>
}
    80005554:	60a2                	ld	ra,8(sp)
    80005556:	6402                	ld	s0,0(sp)
    80005558:	0141                	addi	sp,sp,16
    8000555a:	8082                	ret
    panic("free_desc 1");
    8000555c:	00002517          	auipc	a0,0x2
    80005560:	55c50513          	addi	a0,a0,1372 # 80007ab8 <syscalls+0x400>
    80005564:	a26fb0ef          	jal	ra,8000078a <panic>
    panic("free_desc 2");
    80005568:	00002517          	auipc	a0,0x2
    8000556c:	56050513          	addi	a0,a0,1376 # 80007ac8 <syscalls+0x410>
    80005570:	a1afb0ef          	jal	ra,8000078a <panic>

0000000080005574 <virtio_disk_init>:
{
    80005574:	1101                	addi	sp,sp,-32
    80005576:	ec06                	sd	ra,24(sp)
    80005578:	e822                	sd	s0,16(sp)
    8000557a:	e426                	sd	s1,8(sp)
    8000557c:	e04a                	sd	s2,0(sp)
    8000557e:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005580:	00002597          	auipc	a1,0x2
    80005584:	55858593          	addi	a1,a1,1368 # 80007ad8 <syscalls+0x420>
    80005588:	0001c517          	auipc	a0,0x1c
    8000558c:	76850513          	addi	a0,a0,1896 # 80021cf0 <disk+0x128>
    80005590:	d5cfb0ef          	jal	ra,80000aec <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005594:	100017b7          	lui	a5,0x10001
    80005598:	4398                	lw	a4,0(a5)
    8000559a:	2701                	sext.w	a4,a4
    8000559c:	747277b7          	lui	a5,0x74727
    800055a0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800055a4:	14f71063          	bne	a4,a5,800056e4 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800055a8:	100017b7          	lui	a5,0x10001
    800055ac:	43dc                	lw	a5,4(a5)
    800055ae:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800055b0:	4709                	li	a4,2
    800055b2:	12e79963          	bne	a5,a4,800056e4 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800055b6:	100017b7          	lui	a5,0x10001
    800055ba:	479c                	lw	a5,8(a5)
    800055bc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800055be:	12e79363          	bne	a5,a4,800056e4 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800055c2:	100017b7          	lui	a5,0x10001
    800055c6:	47d8                	lw	a4,12(a5)
    800055c8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800055ca:	554d47b7          	lui	a5,0x554d4
    800055ce:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800055d2:	10f71963          	bne	a4,a5,800056e4 <virtio_disk_init+0x170>
  *R(VIRTIO_MMIO_STATUS) = status;
    800055d6:	100017b7          	lui	a5,0x10001
    800055da:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800055de:	4705                	li	a4,1
    800055e0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800055e2:	470d                	li	a4,3
    800055e4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800055e6:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800055e8:	c7ffe737          	lui	a4,0xc7ffe
    800055ec:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdca57>
    800055f0:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800055f2:	2701                	sext.w	a4,a4
    800055f4:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800055f6:	472d                	li	a4,11
    800055f8:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800055fa:	5bbc                	lw	a5,112(a5)
    800055fc:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005600:	8ba1                	andi	a5,a5,8
    80005602:	0e078763          	beqz	a5,800056f0 <virtio_disk_init+0x17c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005606:	100017b7          	lui	a5,0x10001
    8000560a:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000560e:	43fc                	lw	a5,68(a5)
    80005610:	2781                	sext.w	a5,a5
    80005612:	0e079563          	bnez	a5,800056fc <virtio_disk_init+0x188>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005616:	100017b7          	lui	a5,0x10001
    8000561a:	5bdc                	lw	a5,52(a5)
    8000561c:	2781                	sext.w	a5,a5
  if(max == 0)
    8000561e:	0e078563          	beqz	a5,80005708 <virtio_disk_init+0x194>
  if(max < NUM)
    80005622:	471d                	li	a4,7
    80005624:	0ef77863          	bgeu	a4,a5,80005714 <virtio_disk_init+0x1a0>
  disk.desc = kalloc();
    80005628:	c74fb0ef          	jal	ra,80000a9c <kalloc>
    8000562c:	0001c497          	auipc	s1,0x1c
    80005630:	59c48493          	addi	s1,s1,1436 # 80021bc8 <disk>
    80005634:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005636:	c66fb0ef          	jal	ra,80000a9c <kalloc>
    8000563a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000563c:	c60fb0ef          	jal	ra,80000a9c <kalloc>
    80005640:	87aa                	mv	a5,a0
    80005642:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005644:	6088                	ld	a0,0(s1)
    80005646:	cd69                	beqz	a0,80005720 <virtio_disk_init+0x1ac>
    80005648:	0001c717          	auipc	a4,0x1c
    8000564c:	58873703          	ld	a4,1416(a4) # 80021bd0 <disk+0x8>
    80005650:	cb61                	beqz	a4,80005720 <virtio_disk_init+0x1ac>
    80005652:	c7f9                	beqz	a5,80005720 <virtio_disk_init+0x1ac>
  memset(disk.desc, 0, PGSIZE);
    80005654:	6605                	lui	a2,0x1
    80005656:	4581                	li	a1,0
    80005658:	de8fb0ef          	jal	ra,80000c40 <memset>
  memset(disk.avail, 0, PGSIZE);
    8000565c:	0001c497          	auipc	s1,0x1c
    80005660:	56c48493          	addi	s1,s1,1388 # 80021bc8 <disk>
    80005664:	6605                	lui	a2,0x1
    80005666:	4581                	li	a1,0
    80005668:	6488                	ld	a0,8(s1)
    8000566a:	dd6fb0ef          	jal	ra,80000c40 <memset>
  memset(disk.used, 0, PGSIZE);
    8000566e:	6605                	lui	a2,0x1
    80005670:	4581                	li	a1,0
    80005672:	6888                	ld	a0,16(s1)
    80005674:	dccfb0ef          	jal	ra,80000c40 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005678:	100017b7          	lui	a5,0x10001
    8000567c:	4721                	li	a4,8
    8000567e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005680:	4098                	lw	a4,0(s1)
    80005682:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005686:	40d8                	lw	a4,4(s1)
    80005688:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000568c:	6498                	ld	a4,8(s1)
    8000568e:	0007069b          	sext.w	a3,a4
    80005692:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005696:	9701                	srai	a4,a4,0x20
    80005698:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000569c:	6898                	ld	a4,16(s1)
    8000569e:	0007069b          	sext.w	a3,a4
    800056a2:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800056a6:	9701                	srai	a4,a4,0x20
    800056a8:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800056ac:	4705                	li	a4,1
    800056ae:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800056b0:	00e48c23          	sb	a4,24(s1)
    800056b4:	00e48ca3          	sb	a4,25(s1)
    800056b8:	00e48d23          	sb	a4,26(s1)
    800056bc:	00e48da3          	sb	a4,27(s1)
    800056c0:	00e48e23          	sb	a4,28(s1)
    800056c4:	00e48ea3          	sb	a4,29(s1)
    800056c8:	00e48f23          	sb	a4,30(s1)
    800056cc:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800056d0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800056d4:	0727a823          	sw	s2,112(a5)
}
    800056d8:	60e2                	ld	ra,24(sp)
    800056da:	6442                	ld	s0,16(sp)
    800056dc:	64a2                	ld	s1,8(sp)
    800056de:	6902                	ld	s2,0(sp)
    800056e0:	6105                	addi	sp,sp,32
    800056e2:	8082                	ret
    panic("could not find virtio disk");
    800056e4:	00002517          	auipc	a0,0x2
    800056e8:	40450513          	addi	a0,a0,1028 # 80007ae8 <syscalls+0x430>
    800056ec:	89efb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk FEATURES_OK unset");
    800056f0:	00002517          	auipc	a0,0x2
    800056f4:	41850513          	addi	a0,a0,1048 # 80007b08 <syscalls+0x450>
    800056f8:	892fb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk should not be ready");
    800056fc:	00002517          	auipc	a0,0x2
    80005700:	42c50513          	addi	a0,a0,1068 # 80007b28 <syscalls+0x470>
    80005704:	886fb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk has no queue 0");
    80005708:	00002517          	auipc	a0,0x2
    8000570c:	44050513          	addi	a0,a0,1088 # 80007b48 <syscalls+0x490>
    80005710:	87afb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk max queue too short");
    80005714:	00002517          	auipc	a0,0x2
    80005718:	45450513          	addi	a0,a0,1108 # 80007b68 <syscalls+0x4b0>
    8000571c:	86efb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk kalloc");
    80005720:	00002517          	auipc	a0,0x2
    80005724:	46850513          	addi	a0,a0,1128 # 80007b88 <syscalls+0x4d0>
    80005728:	862fb0ef          	jal	ra,8000078a <panic>

000000008000572c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000572c:	7119                	addi	sp,sp,-128
    8000572e:	fc86                	sd	ra,120(sp)
    80005730:	f8a2                	sd	s0,112(sp)
    80005732:	f4a6                	sd	s1,104(sp)
    80005734:	f0ca                	sd	s2,96(sp)
    80005736:	ecce                	sd	s3,88(sp)
    80005738:	e8d2                	sd	s4,80(sp)
    8000573a:	e4d6                	sd	s5,72(sp)
    8000573c:	e0da                	sd	s6,64(sp)
    8000573e:	fc5e                	sd	s7,56(sp)
    80005740:	f862                	sd	s8,48(sp)
    80005742:	f466                	sd	s9,40(sp)
    80005744:	f06a                	sd	s10,32(sp)
    80005746:	ec6e                	sd	s11,24(sp)
    80005748:	0100                	addi	s0,sp,128
    8000574a:	8aaa                	mv	s5,a0
    8000574c:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000574e:	00c52d03          	lw	s10,12(a0)
    80005752:	001d1d1b          	slliw	s10,s10,0x1
    80005756:	1d02                	slli	s10,s10,0x20
    80005758:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    8000575c:	0001c517          	auipc	a0,0x1c
    80005760:	59450513          	addi	a0,a0,1428 # 80021cf0 <disk+0x128>
    80005764:	c08fb0ef          	jal	ra,80000b6c <acquire>
  for(int i = 0; i < 3; i++){
    80005768:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000576a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000576c:	0001cb97          	auipc	s7,0x1c
    80005770:	45cb8b93          	addi	s7,s7,1116 # 80021bc8 <disk>
  for(int i = 0; i < 3; i++){
    80005774:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005776:	0001cc97          	auipc	s9,0x1c
    8000577a:	57ac8c93          	addi	s9,s9,1402 # 80021cf0 <disk+0x128>
    8000577e:	a8a9                	j	800057d8 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005780:	00fb8733          	add	a4,s7,a5
    80005784:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005788:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000578a:	0207c563          	bltz	a5,800057b4 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000578e:	2905                	addiw	s2,s2,1
    80005790:	0611                	addi	a2,a2,4
    80005792:	05690863          	beq	s2,s6,800057e2 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80005796:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005798:	0001c717          	auipc	a4,0x1c
    8000579c:	43070713          	addi	a4,a4,1072 # 80021bc8 <disk>
    800057a0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800057a2:	01874683          	lbu	a3,24(a4)
    800057a6:	fee9                	bnez	a3,80005780 <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    800057a8:	2785                	addiw	a5,a5,1
    800057aa:	0705                	addi	a4,a4,1
    800057ac:	fe979be3          	bne	a5,s1,800057a2 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800057b0:	57fd                	li	a5,-1
    800057b2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800057b4:	01205b63          	blez	s2,800057ca <virtio_disk_rw+0x9e>
    800057b8:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800057ba:	000a2503          	lw	a0,0(s4)
    800057be:	d41ff0ef          	jal	ra,800054fe <free_desc>
      for(int j = 0; j < i; j++)
    800057c2:	2d85                	addiw	s11,s11,1
    800057c4:	0a11                	addi	s4,s4,4
    800057c6:	ffb91ae3          	bne	s2,s11,800057ba <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800057ca:	85e6                	mv	a1,s9
    800057cc:	0001c517          	auipc	a0,0x1c
    800057d0:	41450513          	addi	a0,a0,1044 # 80021be0 <disk+0x18>
    800057d4:	93bfc0ef          	jal	ra,8000210e <sleep>
  for(int i = 0; i < 3; i++){
    800057d8:	f8040a13          	addi	s4,s0,-128
{
    800057dc:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800057de:	894e                	mv	s2,s3
    800057e0:	bf5d                	j	80005796 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800057e2:	f8042583          	lw	a1,-128(s0)
    800057e6:	00a58793          	addi	a5,a1,10
    800057ea:	0792                	slli	a5,a5,0x4

  if(write)
    800057ec:	0001c617          	auipc	a2,0x1c
    800057f0:	3dc60613          	addi	a2,a2,988 # 80021bc8 <disk>
    800057f4:	00f60733          	add	a4,a2,a5
    800057f8:	018036b3          	snez	a3,s8
    800057fc:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800057fe:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005802:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005806:	f6078693          	addi	a3,a5,-160
    8000580a:	6218                	ld	a4,0(a2)
    8000580c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000580e:	00878513          	addi	a0,a5,8
    80005812:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005814:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005816:	6208                	ld	a0,0(a2)
    80005818:	96aa                	add	a3,a3,a0
    8000581a:	4741                	li	a4,16
    8000581c:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000581e:	4705                	li	a4,1
    80005820:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80005824:	f8442703          	lw	a4,-124(s0)
    80005828:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000582c:	0712                	slli	a4,a4,0x4
    8000582e:	953a                	add	a0,a0,a4
    80005830:	058a8693          	addi	a3,s5,88
    80005834:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    80005836:	6208                	ld	a0,0(a2)
    80005838:	972a                	add	a4,a4,a0
    8000583a:	40000693          	li	a3,1024
    8000583e:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80005840:	001c3c13          	seqz	s8,s8
    80005844:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005846:	001c6c13          	ori	s8,s8,1
    8000584a:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    8000584e:	f8842603          	lw	a2,-120(s0)
    80005852:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005856:	0001c697          	auipc	a3,0x1c
    8000585a:	37268693          	addi	a3,a3,882 # 80021bc8 <disk>
    8000585e:	00258713          	addi	a4,a1,2
    80005862:	0712                	slli	a4,a4,0x4
    80005864:	9736                	add	a4,a4,a3
    80005866:	587d                	li	a6,-1
    80005868:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000586c:	0612                	slli	a2,a2,0x4
    8000586e:	9532                	add	a0,a0,a2
    80005870:	f9078793          	addi	a5,a5,-112
    80005874:	97b6                	add	a5,a5,a3
    80005876:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    80005878:	629c                	ld	a5,0(a3)
    8000587a:	97b2                	add	a5,a5,a2
    8000587c:	4605                	li	a2,1
    8000587e:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005880:	4509                	li	a0,2
    80005882:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    80005886:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000588a:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    8000588e:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005892:	6698                	ld	a4,8(a3)
    80005894:	00275783          	lhu	a5,2(a4)
    80005898:	8b9d                	andi	a5,a5,7
    8000589a:	0786                	slli	a5,a5,0x1
    8000589c:	97ba                	add	a5,a5,a4
    8000589e:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800058a2:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800058a6:	6698                	ld	a4,8(a3)
    800058a8:	00275783          	lhu	a5,2(a4)
    800058ac:	2785                	addiw	a5,a5,1
    800058ae:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800058b2:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800058b6:	100017b7          	lui	a5,0x10001
    800058ba:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800058be:	004aa783          	lw	a5,4(s5)
    800058c2:	00c79f63          	bne	a5,a2,800058e0 <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    800058c6:	0001c917          	auipc	s2,0x1c
    800058ca:	42a90913          	addi	s2,s2,1066 # 80021cf0 <disk+0x128>
  while(b->disk == 1) {
    800058ce:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800058d0:	85ca                	mv	a1,s2
    800058d2:	8556                	mv	a0,s5
    800058d4:	83bfc0ef          	jal	ra,8000210e <sleep>
  while(b->disk == 1) {
    800058d8:	004aa783          	lw	a5,4(s5)
    800058dc:	fe978ae3          	beq	a5,s1,800058d0 <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    800058e0:	f8042903          	lw	s2,-128(s0)
    800058e4:	00290793          	addi	a5,s2,2
    800058e8:	00479713          	slli	a4,a5,0x4
    800058ec:	0001c797          	auipc	a5,0x1c
    800058f0:	2dc78793          	addi	a5,a5,732 # 80021bc8 <disk>
    800058f4:	97ba                	add	a5,a5,a4
    800058f6:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800058fa:	0001c997          	auipc	s3,0x1c
    800058fe:	2ce98993          	addi	s3,s3,718 # 80021bc8 <disk>
    80005902:	00491713          	slli	a4,s2,0x4
    80005906:	0009b783          	ld	a5,0(s3)
    8000590a:	97ba                	add	a5,a5,a4
    8000590c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005910:	854a                	mv	a0,s2
    80005912:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005916:	be9ff0ef          	jal	ra,800054fe <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000591a:	8885                	andi	s1,s1,1
    8000591c:	f0fd                	bnez	s1,80005902 <virtio_disk_rw+0x1d6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000591e:	0001c517          	auipc	a0,0x1c
    80005922:	3d250513          	addi	a0,a0,978 # 80021cf0 <disk+0x128>
    80005926:	adefb0ef          	jal	ra,80000c04 <release>
}
    8000592a:	70e6                	ld	ra,120(sp)
    8000592c:	7446                	ld	s0,112(sp)
    8000592e:	74a6                	ld	s1,104(sp)
    80005930:	7906                	ld	s2,96(sp)
    80005932:	69e6                	ld	s3,88(sp)
    80005934:	6a46                	ld	s4,80(sp)
    80005936:	6aa6                	ld	s5,72(sp)
    80005938:	6b06                	ld	s6,64(sp)
    8000593a:	7be2                	ld	s7,56(sp)
    8000593c:	7c42                	ld	s8,48(sp)
    8000593e:	7ca2                	ld	s9,40(sp)
    80005940:	7d02                	ld	s10,32(sp)
    80005942:	6de2                	ld	s11,24(sp)
    80005944:	6109                	addi	sp,sp,128
    80005946:	8082                	ret

0000000080005948 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005948:	1101                	addi	sp,sp,-32
    8000594a:	ec06                	sd	ra,24(sp)
    8000594c:	e822                	sd	s0,16(sp)
    8000594e:	e426                	sd	s1,8(sp)
    80005950:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005952:	0001c497          	auipc	s1,0x1c
    80005956:	27648493          	addi	s1,s1,630 # 80021bc8 <disk>
    8000595a:	0001c517          	auipc	a0,0x1c
    8000595e:	39650513          	addi	a0,a0,918 # 80021cf0 <disk+0x128>
    80005962:	a0afb0ef          	jal	ra,80000b6c <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005966:	10001737          	lui	a4,0x10001
    8000596a:	533c                	lw	a5,96(a4)
    8000596c:	8b8d                	andi	a5,a5,3
    8000596e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005970:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005974:	689c                	ld	a5,16(s1)
    80005976:	0204d703          	lhu	a4,32(s1)
    8000597a:	0027d783          	lhu	a5,2(a5)
    8000597e:	04f70663          	beq	a4,a5,800059ca <virtio_disk_intr+0x82>
    __sync_synchronize();
    80005982:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005986:	6898                	ld	a4,16(s1)
    80005988:	0204d783          	lhu	a5,32(s1)
    8000598c:	8b9d                	andi	a5,a5,7
    8000598e:	078e                	slli	a5,a5,0x3
    80005990:	97ba                	add	a5,a5,a4
    80005992:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005994:	00278713          	addi	a4,a5,2
    80005998:	0712                	slli	a4,a4,0x4
    8000599a:	9726                	add	a4,a4,s1
    8000599c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800059a0:	e321                	bnez	a4,800059e0 <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800059a2:	0789                	addi	a5,a5,2
    800059a4:	0792                	slli	a5,a5,0x4
    800059a6:	97a6                	add	a5,a5,s1
    800059a8:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800059aa:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800059ae:	facfc0ef          	jal	ra,8000215a <wakeup>

    disk.used_idx += 1;
    800059b2:	0204d783          	lhu	a5,32(s1)
    800059b6:	2785                	addiw	a5,a5,1
    800059b8:	17c2                	slli	a5,a5,0x30
    800059ba:	93c1                	srli	a5,a5,0x30
    800059bc:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800059c0:	6898                	ld	a4,16(s1)
    800059c2:	00275703          	lhu	a4,2(a4)
    800059c6:	faf71ee3          	bne	a4,a5,80005982 <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    800059ca:	0001c517          	auipc	a0,0x1c
    800059ce:	32650513          	addi	a0,a0,806 # 80021cf0 <disk+0x128>
    800059d2:	a32fb0ef          	jal	ra,80000c04 <release>
}
    800059d6:	60e2                	ld	ra,24(sp)
    800059d8:	6442                	ld	s0,16(sp)
    800059da:	64a2                	ld	s1,8(sp)
    800059dc:	6105                	addi	sp,sp,32
    800059de:	8082                	ret
      panic("virtio_disk_intr status");
    800059e0:	00002517          	auipc	a0,0x2
    800059e4:	1c050513          	addi	a0,a0,448 # 80007ba0 <syscalls+0x4e8>
    800059e8:	da3fa0ef          	jal	ra,8000078a <panic>
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
