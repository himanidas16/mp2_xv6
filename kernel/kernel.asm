
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00009117          	auipc	sp,0x9
    80000004:	d2010113          	addi	sp,sp,-736 # 80008d20 <stack0>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ff725d7>
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
    8000010a:	557020ef          	jal	ra,80002e60 <either_copyin>
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
    80000172:	00011517          	auipc	a0,0x11
    80000176:	bae50513          	addi	a0,a0,-1106 # 80010d20 <cons>
    8000017a:	1f3000ef          	jal	ra,80000b6c <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000017e:	00011497          	auipc	s1,0x11
    80000182:	ba248493          	addi	s1,s1,-1118 # 80010d20 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000186:	00011917          	auipc	s2,0x11
    8000018a:	c3290913          	addi	s2,s2,-974 # 80010db8 <cons+0x98>
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
    800001a4:	224020ef          	jal	ra,800023c8 <myproc>
    800001a8:	34f020ef          	jal	ra,80002cf6 <killed>
    800001ac:	e125                	bnez	a0,8000020c <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800001ae:	85a6                	mv	a1,s1
    800001b0:	854a                	mv	a0,s2
    800001b2:	0b9020ef          	jal	ra,80002a6a <sleep>
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
    800001ea:	42d020ef          	jal	ra,80002e16 <either_copyout>
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
    800001fa:	00011517          	auipc	a0,0x11
    800001fe:	b2650513          	addi	a0,a0,-1242 # 80010d20 <cons>
    80000202:	203000ef          	jal	ra,80000c04 <release>

  return target - n;
    80000206:	413b053b          	subw	a0,s6,s3
    8000020a:	a801                	j	8000021a <consoleread+0xce>
        release(&cons.lock);
    8000020c:	00011517          	auipc	a0,0x11
    80000210:	b1450513          	addi	a0,a0,-1260 # 80010d20 <cons>
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
    8000023e:	00011717          	auipc	a4,0x11
    80000242:	b6f72d23          	sw	a5,-1158(a4) # 80010db8 <cons+0x98>
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
    80000288:	00011517          	auipc	a0,0x11
    8000028c:	a9850513          	addi	a0,a0,-1384 # 80010d20 <cons>
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
    800002aa:	401020ef          	jal	ra,80002eaa <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ae:	00011517          	auipc	a0,0x11
    800002b2:	a7250513          	addi	a0,a0,-1422 # 80010d20 <cons>
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
    800002ce:	00011717          	auipc	a4,0x11
    800002d2:	a5270713          	addi	a4,a4,-1454 # 80010d20 <cons>
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
    800002f4:	00011797          	auipc	a5,0x11
    800002f8:	a2c78793          	addi	a5,a5,-1492 # 80010d20 <cons>
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
    80000322:	00011797          	auipc	a5,0x11
    80000326:	a967a783          	lw	a5,-1386(a5) # 80010db8 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f6f71fe3          	bne	a4,a5,800002ae <consoleintr+0x34>
    80000334:	a04d                	j	800003d6 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80000336:	00011717          	auipc	a4,0x11
    8000033a:	9ea70713          	addi	a4,a4,-1558 # 80010d20 <cons>
    8000033e:	0a072783          	lw	a5,160(a4)
    80000342:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000346:	00011497          	auipc	s1,0x11
    8000034a:	9da48493          	addi	s1,s1,-1574 # 80010d20 <cons>
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
    8000037e:	00011717          	auipc	a4,0x11
    80000382:	9a270713          	addi	a4,a4,-1630 # 80010d20 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f2f700e3          	beq	a4,a5,800002ae <consoleintr+0x34>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	00011717          	auipc	a4,0x11
    80000398:	a2f72623          	sw	a5,-1492(a4) # 80010dc0 <cons+0xa0>
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
    800003b2:	00011797          	auipc	a5,0x11
    800003b6:	96e78793          	addi	a5,a5,-1682 # 80010d20 <cons>
    800003ba:	0a07a703          	lw	a4,160(a5)
    800003be:	0017069b          	addiw	a3,a4,1
    800003c2:	0006861b          	sext.w	a2,a3
    800003c6:	0ad7a023          	sw	a3,160(a5)
    800003ca:	07f77713          	andi	a4,a4,127
    800003ce:	97ba                	add	a5,a5,a4
    800003d0:	4729                	li	a4,10
    800003d2:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003d6:	00011797          	auipc	a5,0x11
    800003da:	9ec7a323          	sw	a2,-1562(a5) # 80010dbc <cons+0x9c>
        wakeup(&cons.r);
    800003de:	00011517          	auipc	a0,0x11
    800003e2:	9da50513          	addi	a0,a0,-1574 # 80010db8 <cons+0x98>
    800003e6:	6d0020ef          	jal	ra,80002ab6 <wakeup>
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
    800003f4:	00008597          	auipc	a1,0x8
    800003f8:	c1c58593          	addi	a1,a1,-996 # 80008010 <etext+0x10>
    800003fc:	00011517          	auipc	a0,0x11
    80000400:	92450513          	addi	a0,a0,-1756 # 80010d20 <cons>
    80000404:	6e8000ef          	jal	ra,80000aec <initlock>

  uartinit();
    80000408:	3e2000ef          	jal	ra,800007ea <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	0008b797          	auipc	a5,0x8b
    80000410:	c8478793          	addi	a5,a5,-892 # 8008b090 <devsw>
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
    8000044a:	00008617          	auipc	a2,0x8
    8000044e:	bee60613          	addi	a2,a2,-1042 # 80008038 <digits>
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
    800004f6:	00008797          	auipc	a5,0x8
    800004fa:	7fe7a783          	lw	a5,2046(a5) # 80008cf4 <panicking>
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
    8000052a:	00008b97          	auipc	s7,0x8
    8000052e:	b0eb8b93          	addi	s7,s7,-1266 # 80008038 <digits>
    80000532:	a01d                	j	80000558 <printf+0x94>
    acquire(&pr.lock);
    80000534:	00011517          	auipc	a0,0x11
    80000538:	89450513          	addi	a0,a0,-1900 # 80010dc8 <pr>
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
    80000744:	00008917          	auipc	s2,0x8
    80000748:	8d490913          	addi	s2,s2,-1836 # 80008018 <etext+0x18>
      for(; *s; s++)
    8000074c:	02800513          	li	a0,40
    80000750:	b7dd                	j	80000736 <printf+0x272>
    }

  }
  va_end(ap);

  if(panicking == 0)
    80000752:	00008797          	auipc	a5,0x8
    80000756:	5a27a783          	lw	a5,1442(a5) # 80008cf4 <panicking>
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
    8000077c:	00010517          	auipc	a0,0x10
    80000780:	64c50513          	addi	a0,a0,1612 # 80010dc8 <pr>
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
    8000079a:	00008797          	auipc	a5,0x8
    8000079e:	5527ad23          	sw	s2,1370(a5) # 80008cf4 <panicking>
  printf("panic: ");
    800007a2:	00008517          	auipc	a0,0x8
    800007a6:	87e50513          	addi	a0,a0,-1922 # 80008020 <etext+0x20>
    800007aa:	d1bff0ef          	jal	ra,800004c4 <printf>
  printf("%s\n", s);
    800007ae:	85a6                	mv	a1,s1
    800007b0:	00008517          	auipc	a0,0x8
    800007b4:	87850513          	addi	a0,a0,-1928 # 80008028 <etext+0x28>
    800007b8:	d0dff0ef          	jal	ra,800004c4 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007bc:	00008797          	auipc	a5,0x8
    800007c0:	5327aa23          	sw	s2,1332(a5) # 80008cf0 <panicked>
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
    800007ce:	00008597          	auipc	a1,0x8
    800007d2:	86258593          	addi	a1,a1,-1950 # 80008030 <etext+0x30>
    800007d6:	00010517          	auipc	a0,0x10
    800007da:	5f250513          	addi	a0,a0,1522 # 80010dc8 <pr>
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
    8000081a:	00008597          	auipc	a1,0x8
    8000081e:	83658593          	addi	a1,a1,-1994 # 80008050 <digits+0x18>
    80000822:	00010517          	auipc	a0,0x10
    80000826:	5be50513          	addi	a0,a0,1470 # 80010de0 <tx_lock>
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
    80000850:	00010517          	auipc	a0,0x10
    80000854:	59050513          	addi	a0,a0,1424 # 80010de0 <tx_lock>
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
    8000086e:	00008497          	auipc	s1,0x8
    80000872:	48e48493          	addi	s1,s1,1166 # 80008cfc <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000876:	00010997          	auipc	s3,0x10
    8000087a:	56a98993          	addi	s3,s3,1386 # 80010de0 <tx_lock>
    8000087e:	00008917          	auipc	s2,0x8
    80000882:	47a90913          	addi	s2,s2,1146 # 80008cf8 <tx_chan>
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
    80000892:	1d8020ef          	jal	ra,80002a6a <sleep>
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
    800008b2:	00010517          	auipc	a0,0x10
    800008b6:	52e50513          	addi	a0,a0,1326 # 80010de0 <tx_lock>
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
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	4147a783          	lw	a5,1044(a5) # 80008cf4 <panicking>
    800008e8:	cb89                	beqz	a5,800008fa <uartputc_sync+0x26>
    push_off();

  if(panicked){
    800008ea:	00008797          	auipc	a5,0x8
    800008ee:	4067a783          	lw	a5,1030(a5) # 80008cf0 <panicked>
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
    80000916:	00008797          	auipc	a5,0x8
    8000091a:	3de7a783          	lw	a5,990(a5) # 80008cf4 <panicking>
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
    8000096a:	00010517          	auipc	a0,0x10
    8000096e:	47650513          	addi	a0,a0,1142 # 80010de0 <tx_lock>
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
    80000980:	00010517          	auipc	a0,0x10
    80000984:	46050513          	addi	a0,a0,1120 # 80010de0 <tx_lock>
    80000988:	27c000ef          	jal	ra,80000c04 <release>

  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000098c:	54fd                	li	s1,-1
    8000098e:	a831                	j	800009aa <uartintr+0x52>
    tx_busy = 0;
    80000990:	00008797          	auipc	a5,0x8
    80000994:	3607a623          	sw	zero,876(a5) # 80008cfc <tx_busy>
    wakeup(&tx_chan);
    80000998:	00008517          	auipc	a0,0x8
    8000099c:	36050513          	addi	a0,a0,864 # 80008cf8 <tx_chan>
    800009a0:	116020ef          	jal	ra,80002ab6 <wakeup>
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
    800009d0:	0008c797          	auipc	a5,0x8c
    800009d4:	85878793          	addi	a5,a5,-1960 # 8008c228 <end>
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
    800009ec:	00010917          	auipc	s2,0x10
    800009f0:	40c90913          	addi	s2,s2,1036 # 80010df8 <kmem>
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
    80000a16:	00007517          	auipc	a0,0x7
    80000a1a:	64250513          	addi	a0,a0,1602 # 80008058 <digits+0x20>
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
    80000a70:	00007597          	auipc	a1,0x7
    80000a74:	5f058593          	addi	a1,a1,1520 # 80008060 <digits+0x28>
    80000a78:	00010517          	auipc	a0,0x10
    80000a7c:	38050513          	addi	a0,a0,896 # 80010df8 <kmem>
    80000a80:	06c000ef          	jal	ra,80000aec <initlock>
  freerange(end, (void*)PHYSTOP);
    80000a84:	45c5                	li	a1,17
    80000a86:	05ee                	slli	a1,a1,0x1b
    80000a88:	0008b517          	auipc	a0,0x8b
    80000a8c:	7a050513          	addi	a0,a0,1952 # 8008c228 <end>
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
    80000aa6:	00010497          	auipc	s1,0x10
    80000aaa:	35248493          	addi	s1,s1,850 # 80010df8 <kmem>
    80000aae:	8526                	mv	a0,s1
    80000ab0:	0bc000ef          	jal	ra,80000b6c <acquire>
  r = kmem.freelist;
    80000ab4:	6c84                	ld	s1,24(s1)
  if(r)
    80000ab6:	c485                	beqz	s1,80000ade <kalloc+0x42>
    kmem.freelist = r->next;
    80000ab8:	609c                	ld	a5,0(s1)
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	33e50513          	addi	a0,a0,830 # 80010df8 <kmem>
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
    80000ade:	00010517          	auipc	a0,0x10
    80000ae2:	31a50513          	addi	a0,a0,794 # 80010df8 <kmem>
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
    80000b16:	097010ef          	jal	ra,800023ac <mycpu>
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
    80000b44:	069010ef          	jal	ra,800023ac <mycpu>
    80000b48:	5d3c                	lw	a5,120(a0)
    80000b4a:	cb99                	beqz	a5,80000b60 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b4c:	061010ef          	jal	ra,800023ac <mycpu>
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
    80000b60:	04d010ef          	jal	ra,800023ac <mycpu>
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
    80000b94:	019010ef          	jal	ra,800023ac <mycpu>
    80000b98:	e888                	sd	a0,16(s1)
}
    80000b9a:	60e2                	ld	ra,24(sp)
    80000b9c:	6442                	ld	s0,16(sp)
    80000b9e:	64a2                	ld	s1,8(sp)
    80000ba0:	6105                	addi	sp,sp,32
    80000ba2:	8082                	ret
    panic("acquire");
    80000ba4:	00007517          	auipc	a0,0x7
    80000ba8:	4c450513          	addi	a0,a0,1220 # 80008068 <digits+0x30>
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
    80000bb8:	7f4010ef          	jal	ra,800023ac <mycpu>
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
    80000bec:	00007517          	auipc	a0,0x7
    80000bf0:	48450513          	addi	a0,a0,1156 # 80008070 <digits+0x38>
    80000bf4:	b97ff0ef          	jal	ra,8000078a <panic>
    panic("pop_off");
    80000bf8:	00007517          	auipc	a0,0x7
    80000bfc:	49050513          	addi	a0,a0,1168 # 80008088 <digits+0x50>
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
    80000c34:	00007517          	auipc	a0,0x7
    80000c38:	45c50513          	addi	a0,a0,1116 # 80008090 <digits+0x58>
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
    80000dea:	5b2010ef          	jal	ra,8000239c <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000dee:	00008717          	auipc	a4,0x8
    80000df2:	f1270713          	addi	a4,a4,-238 # 80008d00 <started>
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
    80000e02:	59a010ef          	jal	ra,8000239c <cpuid>
    80000e06:	85aa                	mv	a1,a0
    80000e08:	00007517          	auipc	a0,0x7
    80000e0c:	2a850513          	addi	a0,a0,680 # 800080b0 <digits+0x78>
    80000e10:	eb4ff0ef          	jal	ra,800004c4 <printf>
    kvminithart();    // turn on paging
    80000e14:	080000ef          	jal	ra,80000e94 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e18:	1ca020ef          	jal	ra,80002fe2 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e1c:	298050ef          	jal	ra,800060b4 <plicinithart>
  }

  scheduler();        
    80000e20:	2ad010ef          	jal	ra,800028cc <scheduler>
    consoleinit();
    80000e24:	dc8ff0ef          	jal	ra,800003ec <consoleinit>
    printfinit();
    80000e28:	99fff0ef          	jal	ra,800007c6 <printfinit>
    printf("\n");
    80000e2c:	00007517          	auipc	a0,0x7
    80000e30:	4f450513          	addi	a0,a0,1268 # 80008320 <digits+0x2e8>
    80000e34:	e90ff0ef          	jal	ra,800004c4 <printf>
    printf("xv6 kernel is booting\n");
    80000e38:	00007517          	auipc	a0,0x7
    80000e3c:	26050513          	addi	a0,a0,608 # 80008098 <digits+0x60>
    80000e40:	e84ff0ef          	jal	ra,800004c4 <printf>
    printf("\n");
    80000e44:	00007517          	auipc	a0,0x7
    80000e48:	4dc50513          	addi	a0,a0,1244 # 80008320 <digits+0x2e8>
    80000e4c:	e78ff0ef          	jal	ra,800004c4 <printf>
    kinit();         // physical page allocator
    80000e50:	c19ff0ef          	jal	ra,80000a68 <kinit>
    kvminit();       // create kernel page table
    80000e54:	2ca000ef          	jal	ra,8000111e <kvminit>
    kvminithart();   // turn on paging
    80000e58:	03c000ef          	jal	ra,80000e94 <kvminithart>
    procinit();      // process table
    80000e5c:	490010ef          	jal	ra,800022ec <procinit>
    trapinit();      // trap vectors
    80000e60:	15e020ef          	jal	ra,80002fbe <trapinit>
    trapinithart();  // install kernel trap vector
    80000e64:	17e020ef          	jal	ra,80002fe2 <trapinithart>
    plicinit();      // set up interrupt controller
    80000e68:	236050ef          	jal	ra,8000609e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000e6c:	248050ef          	jal	ra,800060b4 <plicinithart>
    binit();         // buffer cache
    80000e70:	1af020ef          	jal	ra,8000381e <binit>
    iinit();         // inode table
    80000e74:	723020ef          	jal	ra,80003d96 <iinit>
    fileinit();      // file table
    80000e78:	603030ef          	jal	ra,80004c7a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000e7c:	328050ef          	jal	ra,800061a4 <virtio_disk_init>
    userinit();      // first user process
    80000e80:	0b5010ef          	jal	ra,80002734 <userinit>
    __sync_synchronize();
    80000e84:	0ff0000f          	fence
    started = 1;
    80000e88:	4785                	li	a5,1
    80000e8a:	00008717          	auipc	a4,0x8
    80000e8e:	e6f72b23          	sw	a5,-394(a4) # 80008d00 <started>
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
    80000e9e:	00008797          	auipc	a5,0x8
    80000ea2:	e6a7b783          	ld	a5,-406(a5) # 80008d08 <kernel_pagetable>
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
    80000ee2:	00007517          	auipc	a0,0x7
    80000ee6:	1e650513          	addi	a0,a0,486 # 800080c8 <digits+0x90>
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
    80000ff8:	00007517          	auipc	a0,0x7
    80000ffc:	0d850513          	addi	a0,a0,216 # 800080d0 <digits+0x98>
    80001000:	f8aff0ef          	jal	ra,8000078a <panic>
    panic("mappages: size not aligned");
    80001004:	00007517          	auipc	a0,0x7
    80001008:	0ec50513          	addi	a0,a0,236 # 800080f0 <digits+0xb8>
    8000100c:	f7eff0ef          	jal	ra,8000078a <panic>
    panic("mappages: size");
    80001010:	00007517          	auipc	a0,0x7
    80001014:	10050513          	addi	a0,a0,256 # 80008110 <digits+0xd8>
    80001018:	f72ff0ef          	jal	ra,8000078a <panic>
      panic("mappages: remap");
    8000101c:	00007517          	auipc	a0,0x7
    80001020:	10450513          	addi	a0,a0,260 # 80008120 <digits+0xe8>
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
    80001060:	00007517          	auipc	a0,0x7
    80001064:	0d050513          	addi	a0,a0,208 # 80008130 <digits+0xf8>
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
    800010be:	00007917          	auipc	s2,0x7
    800010c2:	f4290913          	addi	s2,s2,-190 # 80008000 <etext>
    800010c6:	4729                	li	a4,10
    800010c8:	80007697          	auipc	a3,0x80007
    800010cc:	f3868693          	addi	a3,a3,-200 # 8000 <_entry-0x7fff8000>
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
    800010f4:	00006617          	auipc	a2,0x6
    800010f8:	f0c60613          	addi	a2,a2,-244 # 80007000 <_trampoline>
    800010fc:	040005b7          	lui	a1,0x4000
    80001100:	15fd                	addi	a1,a1,-1
    80001102:	05b2                	slli	a1,a1,0xc
    80001104:	8526                	mv	a0,s1
    80001106:	f3fff0ef          	jal	ra,80001044 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000110a:	8526                	mv	a0,s1
    8000110c:	14e010ef          	jal	ra,8000225a <proc_mapstacks>
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
    8000112a:	00008797          	auipc	a5,0x8
    8000112e:	bca7bf23          	sd	a0,-1058(a5) # 80008d08 <kernel_pagetable>
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
    800011a0:	00007517          	auipc	a0,0x7
    800011a4:	f9850513          	addi	a0,a0,-104 # 80008138 <digits+0x100>
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
    800012f6:	00007517          	auipc	a0,0x7
    800012fa:	e5a50513          	addi	a0,a0,-422 # 80008150 <digits+0x118>
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
    80001404:	00007517          	auipc	a0,0x7
    80001408:	d5c50513          	addi	a0,a0,-676 # 80008160 <digits+0x128>
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

00000000800014e0 <add_resident_page>:

//changes 
// Add a page to the resident set
void add_resident_page(struct proc *p, uint64 va, int seq) {
    800014e0:	1141                	addi	sp,sp,-16
    800014e2:	e422                	sd	s0,8(sp)
    800014e4:	0800                	addi	s0,sp,16
  if(p->num_resident < MAX_RESIDENT_PAGES) {
    800014e6:	7c052703          	lw	a4,1984(a0)
    800014ea:	03f00793          	li	a5,63
    800014ee:	02e7c263          	blt	a5,a4,80001512 <add_resident_page+0x32>
    p->resident_pages[p->num_resident].va = va;
    800014f2:	00171793          	slli	a5,a4,0x1
    800014f6:	97ba                	add	a5,a5,a4
    800014f8:	078e                	slli	a5,a5,0x3
    800014fa:	97aa                	add	a5,a5,a0
    800014fc:	1cb7b023          	sd	a1,448(a5)
    p->resident_pages[p->num_resident].seq = seq;
    80001500:	1cc7a423          	sw	a2,456(a5)
    p->resident_pages[p->num_resident].is_dirty = 0;
    80001504:	1c07a623          	sw	zero,460(a5)
    p->resident_pages[p->num_resident].last_used_seq = seq;  // ADD THIS LINE
    80001508:	1cc7aa23          	sw	a2,468(a5)
    p->num_resident++;
    8000150c:	2705                	addiw	a4,a4,1
    8000150e:	7ce52023          	sw	a4,1984(a0)
  }
}
    80001512:	6422                	ld	s0,8(sp)
    80001514:	0141                	addi	sp,sp,16
    80001516:	8082                	ret

0000000080001518 <evict_page_fifo>:

// Find and evict the oldest resident page using FIFO
// Returns the physical address of the freed page
char* evict_page_fifo(struct proc *p, pagetable_t pagetable) {
    80001518:	715d                	addi	sp,sp,-80
    8000151a:	e486                	sd	ra,72(sp)
    8000151c:	e0a2                	sd	s0,64(sp)
    8000151e:	fc26                	sd	s1,56(sp)
    80001520:	f84a                	sd	s2,48(sp)
    80001522:	f44e                	sd	s3,40(sp)
    80001524:	f052                	sd	s4,32(sp)
    80001526:	ec56                	sd	s5,24(sp)
    80001528:	e85a                	sd	s6,16(sp)
    8000152a:	e45e                	sd	s7,8(sp)
    8000152c:	0880                	addi	s0,sp,80
    8000152e:	8aae                	mv	s5,a1
  if(p->num_resident == 0)
    80001530:	7c052583          	lw	a1,1984(a0)
    80001534:	1a058a63          	beqz	a1,800016e8 <evict_page_fifo+0x1d0>
    80001538:	84aa                	mv	s1,a0
    return 0;
  
  // Find victim with lowest sequence number (oldest)
  int victim_idx = 0;
  int min_seq = p->resident_pages[0].seq;
    8000153a:	1c852603          	lw	a2,456(a0)
  
  for(int i = 1; i < p->num_resident; i++) {
    8000153e:	4785                	li	a5,1
    80001540:	02b7d063          	bge	a5,a1,80001560 <evict_page_fifo+0x48>
    80001544:	1e050713          	addi	a4,a0,480
  int victim_idx = 0;
    80001548:	4901                	li	s2,0
    8000154a:	a029                	j	80001554 <evict_page_fifo+0x3c>
  for(int i = 1; i < p->num_resident; i++) {
    8000154c:	2785                	addiw	a5,a5,1
    8000154e:	0761                	addi	a4,a4,24
    80001550:	00f58963          	beq	a1,a5,80001562 <evict_page_fifo+0x4a>
    if(p->resident_pages[i].seq < min_seq) {
    80001554:	4314                	lw	a3,0(a4)
    80001556:	fec6dbe3          	bge	a3,a2,8000154c <evict_page_fifo+0x34>
      min_seq = p->resident_pages[i].seq;
    8000155a:	8636                	mv	a2,a3
    if(p->resident_pages[i].seq < min_seq) {
    8000155c:	893e                	mv	s2,a5
    8000155e:	b7fd                	j	8000154c <evict_page_fifo+0x34>
  int victim_idx = 0;
    80001560:	4901                	li	s2,0
      victim_idx = i;
    }
  }
  
  uint64 victim_va = p->resident_pages[victim_idx].va;
    80001562:	00191793          	slli	a5,s2,0x1
    80001566:	97ca                	add	a5,a5,s2
    80001568:	078e                	slli	a5,a5,0x3
    8000156a:	97a6                	add	a5,a5,s1
    8000156c:	1c07bb03          	ld	s6,448(a5)
  int victim_seq = p->resident_pages[victim_idx].seq;
  int is_dirty = p->resident_pages[victim_idx].is_dirty;
    80001570:	1cc7a983          	lw	s3,460(a5)
  
  // Log victim selection
  printf("[pid %d] VICTIM va=0x%lx seq=%d algo=FIFO\n", p->pid, victim_va, victim_seq);
    80001574:	1c87a683          	lw	a3,456(a5)
    80001578:	865a                	mv	a2,s6
    8000157a:	588c                	lw	a1,48(s1)
    8000157c:	00007517          	auipc	a0,0x7
    80001580:	bf450513          	addi	a0,a0,-1036 # 80008170 <digits+0x138>
    80001584:	f41fe0ef          	jal	ra,800004c4 <printf>
  printf("[pid %d] EVICT va=0x%lx state=%s\n", p->pid, victim_va, is_dirty ? "dirty" : "clean");
    80001588:	588c                	lw	a1,48(s1)
    8000158a:	16099163          	bnez	s3,800016ec <evict_page_fifo+0x1d4>
    8000158e:	00007697          	auipc	a3,0x7
    80001592:	cba68693          	addi	a3,a3,-838 # 80008248 <digits+0x210>
    80001596:	865a                	mv	a2,s6
    80001598:	00007517          	auipc	a0,0x7
    8000159c:	cb850513          	addi	a0,a0,-840 # 80008250 <digits+0x218>
    800015a0:	f25fe0ef          	jal	ra,800004c4 <printf>
  
  // Get physical address before unmapping
  uint64 pa = walkaddr(pagetable, victim_va);
    800015a4:	85da                	mv	a1,s6
    800015a6:	8556                	mv	a0,s5
    800015a8:	9afff0ef          	jal	ra,80000f56 <walkaddr>
    800015ac:	89aa                	mv	s3,a0
      printf("[pid %d] ERROR: no swap file\n", p->pid);
      setkilled(p);
      return 0;
    }
  } else {
    printf("[pid %d] DISCARD va=0x%lx\n", p->pid, victim_va);
    800015ae:	865a                	mv	a2,s6
    800015b0:	588c                	lw	a1,48(s1)
    800015b2:	00007517          	auipc	a0,0x7
    800015b6:	cc650513          	addi	a0,a0,-826 # 80008278 <digits+0x240>
    800015ba:	f0bfe0ef          	jal	ra,800004c4 <printf>
    800015be:	a059                	j	80001644 <evict_page_fifo+0x12c>
    if(slot == -1) {
    800015c0:	57fd                	li	a5,-1
    800015c2:	16fa0363          	beq	s4,a5,80001728 <evict_page_fifo+0x210>
    if(p->swapfile) {
    800015c6:	6785                	lui	a5,0x1
    800015c8:	97a6                	add	a5,a5,s1
    800015ca:	bd07bb83          	ld	s7,-1072(a5) # bd0 <_entry-0x7ffff430>
    800015ce:	100b8263          	beqz	s7,800016d2 <evict_page_fifo+0x1ba>
      p->swapfile->off = slot * PGSIZE;
    800015d2:	00ca179b          	slliw	a5,s4,0xc
    800015d6:	02fba023          	sw	a5,32(s7) # 1020 <_entry-0x7fffefe0>
      int written = filewrite(p->swapfile, pa, PGSIZE);
    800015da:	6b85                	lui	s7,0x1
    800015dc:	017487b3          	add	a5,s1,s7
    800015e0:	6605                	lui	a2,0x1
    800015e2:	85ce                	mv	a1,s3
    800015e4:	bd07b503          	ld	a0,-1072(a5)
    800015e8:	10f030ef          	jal	ra,80004ef6 <filewrite>
      if(written != PGSIZE) {
    800015ec:	0d751763          	bne	a0,s7,800016ba <evict_page_fifo+0x1a2>
      p->swap_slots[slot] = 1;
    800015f0:	2f8a0793          	addi	a5,s4,760 # fffffffffffff2f8 <end+0xffffffff7ff730d0>
    800015f4:	078a                	slli	a5,a5,0x2
    800015f6:	97a6                	add	a5,a5,s1
    800015f8:	4705                	li	a4,1
    800015fa:	c7d8                	sw	a4,12(a5)
      p->num_swap_slots_used++;
    800015fc:	6789                	lui	a5,0x2
    800015fe:	97a6                	add	a5,a5,s1
    80001600:	bec7a703          	lw	a4,-1044(a5) # 1bec <_entry-0x7fffe414>
    80001604:	2705                	addiw	a4,a4,1
    80001606:	bee7a623          	sw	a4,-1044(a5)
      if(p->num_swapped < MAX_RESIDENT_PAGES) {
    8000160a:	6785                	lui	a5,0x1
    8000160c:	97a6                	add	a5,a5,s1
    8000160e:	bc87a783          	lw	a5,-1080(a5) # bc8 <_entry-0x7ffff438>
    80001612:	03f00713          	li	a4,63
    80001616:	00f74e63          	blt	a4,a5,80001632 <evict_page_fifo+0x11a>
        p->swapped_pages[p->num_swapped].va = victim_va;
    8000161a:	00479713          	slli	a4,a5,0x4
    8000161e:	9726                	add	a4,a4,s1
    80001620:	7d673423          	sd	s6,1992(a4)
        p->swapped_pages[p->num_swapped].swap_slot = slot;
    80001624:	7d472823          	sw	s4,2000(a4)
        p->num_swapped++;
    80001628:	6705                	lui	a4,0x1
    8000162a:	9726                	add	a4,a4,s1
    8000162c:	2785                	addiw	a5,a5,1
    8000162e:	bcf72423          	sw	a5,-1080(a4) # bc8 <_entry-0x7ffff438>
      printf("[pid %d] SWAPOUT va=0x%lx slot=%d\n", p->pid, victim_va, slot);
    80001632:	86d2                	mv	a3,s4
    80001634:	865a                	mv	a2,s6
    80001636:	588c                	lw	a1,48(s1)
    80001638:	00007517          	auipc	a0,0x7
    8000163c:	bc850513          	addi	a0,a0,-1080 # 80008200 <digits+0x1c8>
    80001640:	e85fe0ef          	jal	ra,800004c4 <printf>
  }
  
  // Unmap the page
  uvmunmap(pagetable, victim_va, 1, 0);  // Don't free yet
    80001644:	4681                	li	a3,0
    80001646:	4605                	li	a2,1
    80001648:	85da                	mv	a1,s6
    8000164a:	8556                	mv	a0,s5
    8000164c:	b15ff0ef          	jal	ra,80001160 <uvmunmap>
  
  // Remove from resident set by shifting array
  for(int i = victim_idx; i < p->num_resident - 1; i++) {
    80001650:	7c04a703          	lw	a4,1984(s1)
    80001654:	fff7061b          	addiw	a2,a4,-1
    80001658:	0006079b          	sext.w	a5,a2
    8000165c:	04f95063          	bge	s2,a5,8000169c <evict_page_fifo+0x184>
    80001660:	00191793          	slli	a5,s2,0x1
    80001664:	97ca                	add	a5,a5,s2
    80001666:	078e                	slli	a5,a5,0x3
    80001668:	1c078793          	addi	a5,a5,448
    8000166c:	97a6                	add	a5,a5,s1
    8000166e:	ffe7069b          	addiw	a3,a4,-2
    80001672:	412686bb          	subw	a3,a3,s2
    80001676:	1682                	slli	a3,a3,0x20
    80001678:	9281                	srli	a3,a3,0x20
    8000167a:	9936                	add	s2,s2,a3
    8000167c:	00191693          	slli	a3,s2,0x1
    80001680:	96ca                	add	a3,a3,s2
    80001682:	068e                	slli	a3,a3,0x3
    80001684:	1d848713          	addi	a4,s1,472
    80001688:	96ba                	add	a3,a3,a4
    p->resident_pages[i] = p->resident_pages[i + 1];
    8000168a:	6f98                	ld	a4,24(a5)
    8000168c:	e398                	sd	a4,0(a5)
    8000168e:	7398                	ld	a4,32(a5)
    80001690:	e798                	sd	a4,8(a5)
    80001692:	7798                	ld	a4,40(a5)
    80001694:	eb98                	sd	a4,16(a5)
  for(int i = victim_idx; i < p->num_resident - 1; i++) {
    80001696:	07e1                	addi	a5,a5,24
    80001698:	fed799e3          	bne	a5,a3,8000168a <evict_page_fifo+0x172>
  }
  p->num_resident--;
    8000169c:	7cc4a023          	sw	a2,1984(s1)
  
  return (char*)pa;
    800016a0:	8bce                	mv	s7,s3
}
    800016a2:	855e                	mv	a0,s7
    800016a4:	60a6                	ld	ra,72(sp)
    800016a6:	6406                	ld	s0,64(sp)
    800016a8:	74e2                	ld	s1,56(sp)
    800016aa:	7942                	ld	s2,48(sp)
    800016ac:	79a2                	ld	s3,40(sp)
    800016ae:	7a02                	ld	s4,32(sp)
    800016b0:	6ae2                	ld	s5,24(sp)
    800016b2:	6b42                	ld	s6,16(sp)
    800016b4:	6ba2                	ld	s7,8(sp)
    800016b6:	6161                	addi	sp,sp,80
    800016b8:	8082                	ret
        printf("[pid %d] ERROR: swap write failed\n", p->pid);
    800016ba:	588c                	lw	a1,48(s1)
    800016bc:	00007517          	auipc	a0,0x7
    800016c0:	b1c50513          	addi	a0,a0,-1252 # 800081d8 <digits+0x1a0>
    800016c4:	e01fe0ef          	jal	ra,800004c4 <printf>
        setkilled(p);
    800016c8:	8526                	mv	a0,s1
    800016ca:	608010ef          	jal	ra,80002cd2 <setkilled>
        return 0;
    800016ce:	4b81                	li	s7,0
    800016d0:	bfc9                	j	800016a2 <evict_page_fifo+0x18a>
      printf("[pid %d] ERROR: no swap file\n", p->pid);
    800016d2:	588c                	lw	a1,48(s1)
    800016d4:	00007517          	auipc	a0,0x7
    800016d8:	b5450513          	addi	a0,a0,-1196 # 80008228 <digits+0x1f0>
    800016dc:	de9fe0ef          	jal	ra,800004c4 <printf>
      setkilled(p);
    800016e0:	8526                	mv	a0,s1
    800016e2:	5f0010ef          	jal	ra,80002cd2 <setkilled>
      return 0;
    800016e6:	bf75                	j	800016a2 <evict_page_fifo+0x18a>
    return 0;
    800016e8:	4b81                	li	s7,0
    800016ea:	bf65                	j	800016a2 <evict_page_fifo+0x18a>
  printf("[pid %d] EVICT va=0x%lx state=%s\n", p->pid, victim_va, is_dirty ? "dirty" : "clean");
    800016ec:	00007697          	auipc	a3,0x7
    800016f0:	bac68693          	addi	a3,a3,-1108 # 80008298 <digits+0x260>
    800016f4:	865a                	mv	a2,s6
    800016f6:	00007517          	auipc	a0,0x7
    800016fa:	b5a50513          	addi	a0,a0,-1190 # 80008250 <digits+0x218>
    800016fe:	dc7fe0ef          	jal	ra,800004c4 <printf>
  uint64 pa = walkaddr(pagetable, victim_va);
    80001702:	85da                	mv	a1,s6
    80001704:	8556                	mv	a0,s5
    80001706:	851ff0ef          	jal	ra,80000f56 <walkaddr>
    8000170a:	89aa                	mv	s3,a0
  if(is_dirty) {
    8000170c:	6785                	lui	a5,0x1
    8000170e:	bec78793          	addi	a5,a5,-1044 # bec <_entry-0x7ffff414>
    80001712:	97a6                	add	a5,a5,s1
  uint64 pa = walkaddr(pagetable, victim_va);
    80001714:	4a01                	li	s4,0
    for(int i = 0; i < 1024; i++) {
    80001716:	40000693          	li	a3,1024
      if(p->swap_slots[i] == 0) {
    8000171a:	4398                	lw	a4,0(a5)
    8000171c:	ea0702e3          	beqz	a4,800015c0 <evict_page_fifo+0xa8>
    for(int i = 0; i < 1024; i++) {
    80001720:	2a05                	addiw	s4,s4,1
    80001722:	0791                	addi	a5,a5,4
    80001724:	feda1be3          	bne	s4,a3,8000171a <evict_page_fifo+0x202>
      printf("[pid %d] SWAPFULL\n", p->pid);
    80001728:	588c                	lw	a1,48(s1)
    8000172a:	00007517          	auipc	a0,0x7
    8000172e:	a7650513          	addi	a0,a0,-1418 # 800081a0 <digits+0x168>
    80001732:	d93fe0ef          	jal	ra,800004c4 <printf>
      printf("[pid %d] KILL swap-exhausted\n", p->pid);
    80001736:	588c                	lw	a1,48(s1)
    80001738:	00007517          	auipc	a0,0x7
    8000173c:	a8050513          	addi	a0,a0,-1408 # 800081b8 <digits+0x180>
    80001740:	d85fe0ef          	jal	ra,800004c4 <printf>
      setkilled(p);
    80001744:	8526                	mv	a0,s1
    80001746:	58c010ef          	jal	ra,80002cd2 <setkilled>
      return 0;
    8000174a:	4b81                	li	s7,0
    8000174c:	bf99                	j	800016a2 <evict_page_fifo+0x18a>

000000008000174e <evict_page_lru>:
// LRU-based page replacement
char* evict_page_lru(struct proc *p, pagetable_t pagetable) {
    8000174e:	715d                	addi	sp,sp,-80
    80001750:	e486                	sd	ra,72(sp)
    80001752:	e0a2                	sd	s0,64(sp)
    80001754:	fc26                	sd	s1,56(sp)
    80001756:	f84a                	sd	s2,48(sp)
    80001758:	f44e                	sd	s3,40(sp)
    8000175a:	f052                	sd	s4,32(sp)
    8000175c:	ec56                	sd	s5,24(sp)
    8000175e:	e85a                	sd	s6,16(sp)
    80001760:	e45e                	sd	s7,8(sp)
    80001762:	0880                	addi	s0,sp,80
    80001764:	8aae                	mv	s5,a1
  if(p->num_resident == 0)
    80001766:	7c052583          	lw	a1,1984(a0)
    8000176a:	1a058a63          	beqz	a1,8000191e <evict_page_lru+0x1d0>
    8000176e:	84aa                	mv	s1,a0
    return 0;
  
  // Find victim with lowest last_used_seq (least recently used)
  int victim_idx = 0;
  int min_last_used = p->resident_pages[0].last_used_seq;
    80001770:	1d452603          	lw	a2,468(a0)
  
  for(int i = 1; i < p->num_resident; i++) {
    80001774:	4785                	li	a5,1
    80001776:	02b7d063          	bge	a5,a1,80001796 <evict_page_lru+0x48>
    8000177a:	1ec50713          	addi	a4,a0,492
  int victim_idx = 0;
    8000177e:	4901                	li	s2,0
    80001780:	a029                	j	8000178a <evict_page_lru+0x3c>
  for(int i = 1; i < p->num_resident; i++) {
    80001782:	2785                	addiw	a5,a5,1
    80001784:	0761                	addi	a4,a4,24
    80001786:	00f58963          	beq	a1,a5,80001798 <evict_page_lru+0x4a>
    if(p->resident_pages[i].last_used_seq < min_last_used) {
    8000178a:	4314                	lw	a3,0(a4)
    8000178c:	fec6dbe3          	bge	a3,a2,80001782 <evict_page_lru+0x34>
      min_last_used = p->resident_pages[i].last_used_seq;
    80001790:	8636                	mv	a2,a3
    if(p->resident_pages[i].last_used_seq < min_last_used) {
    80001792:	893e                	mv	s2,a5
    80001794:	b7fd                	j	80001782 <evict_page_lru+0x34>
  int victim_idx = 0;
    80001796:	4901                	li	s2,0
      victim_idx = i;
    }
  }
  
  uint64 victim_va = p->resident_pages[victim_idx].va;
    80001798:	00191793          	slli	a5,s2,0x1
    8000179c:	97ca                	add	a5,a5,s2
    8000179e:	078e                	slli	a5,a5,0x3
    800017a0:	97a6                	add	a5,a5,s1
    800017a2:	1c07bb03          	ld	s6,448(a5)
  int victim_seq = p->resident_pages[victim_idx].seq;
  int is_dirty = p->resident_pages[victim_idx].is_dirty;
    800017a6:	1cc7a983          	lw	s3,460(a5)
  
  // Log victim selection with algo=LRU
  printf("[pid %d] VICTIM va=0x%lx seq=%d algo=LRU\n", p->pid, victim_va, victim_seq);
    800017aa:	1c87a683          	lw	a3,456(a5)
    800017ae:	865a                	mv	a2,s6
    800017b0:	588c                	lw	a1,48(s1)
    800017b2:	00007517          	auipc	a0,0x7
    800017b6:	aee50513          	addi	a0,a0,-1298 # 800082a0 <digits+0x268>
    800017ba:	d0bfe0ef          	jal	ra,800004c4 <printf>
  printf("[pid %d] EVICT va=0x%lx state=%s\n", p->pid, victim_va, is_dirty ? "dirty" : "clean");
    800017be:	588c                	lw	a1,48(s1)
    800017c0:	16099163          	bnez	s3,80001922 <evict_page_lru+0x1d4>
    800017c4:	00007697          	auipc	a3,0x7
    800017c8:	a8468693          	addi	a3,a3,-1404 # 80008248 <digits+0x210>
    800017cc:	865a                	mv	a2,s6
    800017ce:	00007517          	auipc	a0,0x7
    800017d2:	a8250513          	addi	a0,a0,-1406 # 80008250 <digits+0x218>
    800017d6:	ceffe0ef          	jal	ra,800004c4 <printf>
  
  uint64 pa = walkaddr(pagetable, victim_va);
    800017da:	85da                	mv	a1,s6
    800017dc:	8556                	mv	a0,s5
    800017de:	f78ff0ef          	jal	ra,80000f56 <walkaddr>
    800017e2:	89aa                	mv	s3,a0
      setkilled(p);
      return 0;
    }
  } else {
    // CLEAN PAGE - Just discard
    printf("[pid %d] DISCARD va=0x%lx\n", p->pid, victim_va);
    800017e4:	865a                	mv	a2,s6
    800017e6:	588c                	lw	a1,48(s1)
    800017e8:	00007517          	auipc	a0,0x7
    800017ec:	a9050513          	addi	a0,a0,-1392 # 80008278 <digits+0x240>
    800017f0:	cd5fe0ef          	jal	ra,800004c4 <printf>
    800017f4:	a059                	j	8000187a <evict_page_lru+0x12c>
    if(slot == -1) {
    800017f6:	57fd                	li	a5,-1
    800017f8:	16fa0363          	beq	s4,a5,8000195e <evict_page_lru+0x210>
    if(p->swapfile) {
    800017fc:	6785                	lui	a5,0x1
    800017fe:	97a6                	add	a5,a5,s1
    80001800:	bd07bb83          	ld	s7,-1072(a5) # bd0 <_entry-0x7ffff430>
    80001804:	100b8263          	beqz	s7,80001908 <evict_page_lru+0x1ba>
      p->swapfile->off = slot * PGSIZE;
    80001808:	00ca179b          	slliw	a5,s4,0xc
    8000180c:	02fba023          	sw	a5,32(s7) # 1020 <_entry-0x7fffefe0>
      int written = filewrite(p->swapfile, pa, PGSIZE);
    80001810:	6b85                	lui	s7,0x1
    80001812:	017487b3          	add	a5,s1,s7
    80001816:	6605                	lui	a2,0x1
    80001818:	85ce                	mv	a1,s3
    8000181a:	bd07b503          	ld	a0,-1072(a5)
    8000181e:	6d8030ef          	jal	ra,80004ef6 <filewrite>
      if(written != PGSIZE) {
    80001822:	0d751763          	bne	a0,s7,800018f0 <evict_page_lru+0x1a2>
      p->swap_slots[slot] = 1;
    80001826:	2f8a0793          	addi	a5,s4,760
    8000182a:	078a                	slli	a5,a5,0x2
    8000182c:	97a6                	add	a5,a5,s1
    8000182e:	4705                	li	a4,1
    80001830:	c7d8                	sw	a4,12(a5)
      p->num_swap_slots_used++;
    80001832:	6789                	lui	a5,0x2
    80001834:	97a6                	add	a5,a5,s1
    80001836:	bec7a703          	lw	a4,-1044(a5) # 1bec <_entry-0x7fffe414>
    8000183a:	2705                	addiw	a4,a4,1
    8000183c:	bee7a623          	sw	a4,-1044(a5)
      if(p->num_swapped < MAX_RESIDENT_PAGES) {
    80001840:	6785                	lui	a5,0x1
    80001842:	97a6                	add	a5,a5,s1
    80001844:	bc87a783          	lw	a5,-1080(a5) # bc8 <_entry-0x7ffff438>
    80001848:	03f00713          	li	a4,63
    8000184c:	00f74e63          	blt	a4,a5,80001868 <evict_page_lru+0x11a>
        p->swapped_pages[p->num_swapped].va = victim_va;
    80001850:	00479713          	slli	a4,a5,0x4
    80001854:	9726                	add	a4,a4,s1
    80001856:	7d673423          	sd	s6,1992(a4)
        p->swapped_pages[p->num_swapped].swap_slot = slot;
    8000185a:	7d472823          	sw	s4,2000(a4)
        p->num_swapped++;
    8000185e:	6705                	lui	a4,0x1
    80001860:	9726                	add	a4,a4,s1
    80001862:	2785                	addiw	a5,a5,1
    80001864:	bcf72423          	sw	a5,-1080(a4) # bc8 <_entry-0x7ffff438>
      printf("[pid %d] SWAPOUT va=0x%lx slot=%d\n", p->pid, victim_va, slot);
    80001868:	86d2                	mv	a3,s4
    8000186a:	865a                	mv	a2,s6
    8000186c:	588c                	lw	a1,48(s1)
    8000186e:	00007517          	auipc	a0,0x7
    80001872:	99250513          	addi	a0,a0,-1646 # 80008200 <digits+0x1c8>
    80001876:	c4ffe0ef          	jal	ra,800004c4 <printf>
  }
  
  uvmunmap(pagetable, victim_va, 1, 0);
    8000187a:	4681                	li	a3,0
    8000187c:	4605                	li	a2,1
    8000187e:	85da                	mv	a1,s6
    80001880:	8556                	mv	a0,s5
    80001882:	8dfff0ef          	jal	ra,80001160 <uvmunmap>
  
  for(int i = victim_idx; i < p->num_resident - 1; i++) {
    80001886:	7c04a703          	lw	a4,1984(s1)
    8000188a:	fff7061b          	addiw	a2,a4,-1
    8000188e:	0006079b          	sext.w	a5,a2
    80001892:	04f95063          	bge	s2,a5,800018d2 <evict_page_lru+0x184>
    80001896:	00191793          	slli	a5,s2,0x1
    8000189a:	97ca                	add	a5,a5,s2
    8000189c:	078e                	slli	a5,a5,0x3
    8000189e:	1c078793          	addi	a5,a5,448
    800018a2:	97a6                	add	a5,a5,s1
    800018a4:	ffe7069b          	addiw	a3,a4,-2
    800018a8:	412686bb          	subw	a3,a3,s2
    800018ac:	1682                	slli	a3,a3,0x20
    800018ae:	9281                	srli	a3,a3,0x20
    800018b0:	9936                	add	s2,s2,a3
    800018b2:	00191693          	slli	a3,s2,0x1
    800018b6:	96ca                	add	a3,a3,s2
    800018b8:	068e                	slli	a3,a3,0x3
    800018ba:	1d848713          	addi	a4,s1,472
    800018be:	96ba                	add	a3,a3,a4
    p->resident_pages[i] = p->resident_pages[i + 1];
    800018c0:	6f98                	ld	a4,24(a5)
    800018c2:	e398                	sd	a4,0(a5)
    800018c4:	7398                	ld	a4,32(a5)
    800018c6:	e798                	sd	a4,8(a5)
    800018c8:	7798                	ld	a4,40(a5)
    800018ca:	eb98                	sd	a4,16(a5)
  for(int i = victim_idx; i < p->num_resident - 1; i++) {
    800018cc:	07e1                	addi	a5,a5,24
    800018ce:	fed799e3          	bne	a5,a3,800018c0 <evict_page_lru+0x172>
  }
  p->num_resident--;
    800018d2:	7cc4a023          	sw	a2,1984(s1)
  
  return (char*)pa;
    800018d6:	8bce                	mv	s7,s3
}
    800018d8:	855e                	mv	a0,s7
    800018da:	60a6                	ld	ra,72(sp)
    800018dc:	6406                	ld	s0,64(sp)
    800018de:	74e2                	ld	s1,56(sp)
    800018e0:	7942                	ld	s2,48(sp)
    800018e2:	79a2                	ld	s3,40(sp)
    800018e4:	7a02                	ld	s4,32(sp)
    800018e6:	6ae2                	ld	s5,24(sp)
    800018e8:	6b42                	ld	s6,16(sp)
    800018ea:	6ba2                	ld	s7,8(sp)
    800018ec:	6161                	addi	sp,sp,80
    800018ee:	8082                	ret
        printf("[pid %d] ERROR: swap write failed\n", p->pid);
    800018f0:	588c                	lw	a1,48(s1)
    800018f2:	00007517          	auipc	a0,0x7
    800018f6:	8e650513          	addi	a0,a0,-1818 # 800081d8 <digits+0x1a0>
    800018fa:	bcbfe0ef          	jal	ra,800004c4 <printf>
        setkilled(p);
    800018fe:	8526                	mv	a0,s1
    80001900:	3d2010ef          	jal	ra,80002cd2 <setkilled>
        return 0;
    80001904:	4b81                	li	s7,0
    80001906:	bfc9                	j	800018d8 <evict_page_lru+0x18a>
      printf("[pid %d] ERROR: no swap file\n", p->pid);
    80001908:	588c                	lw	a1,48(s1)
    8000190a:	00007517          	auipc	a0,0x7
    8000190e:	91e50513          	addi	a0,a0,-1762 # 80008228 <digits+0x1f0>
    80001912:	bb3fe0ef          	jal	ra,800004c4 <printf>
      setkilled(p);
    80001916:	8526                	mv	a0,s1
    80001918:	3ba010ef          	jal	ra,80002cd2 <setkilled>
      return 0;
    8000191c:	bf75                	j	800018d8 <evict_page_lru+0x18a>
    return 0;
    8000191e:	4b81                	li	s7,0
    80001920:	bf65                	j	800018d8 <evict_page_lru+0x18a>
  printf("[pid %d] EVICT va=0x%lx state=%s\n", p->pid, victim_va, is_dirty ? "dirty" : "clean");
    80001922:	00007697          	auipc	a3,0x7
    80001926:	97668693          	addi	a3,a3,-1674 # 80008298 <digits+0x260>
    8000192a:	865a                	mv	a2,s6
    8000192c:	00007517          	auipc	a0,0x7
    80001930:	92450513          	addi	a0,a0,-1756 # 80008250 <digits+0x218>
    80001934:	b91fe0ef          	jal	ra,800004c4 <printf>
  uint64 pa = walkaddr(pagetable, victim_va);
    80001938:	85da                	mv	a1,s6
    8000193a:	8556                	mv	a0,s5
    8000193c:	e1aff0ef          	jal	ra,80000f56 <walkaddr>
    80001940:	89aa                	mv	s3,a0
  if(is_dirty) {
    80001942:	6785                	lui	a5,0x1
    80001944:	bec78793          	addi	a5,a5,-1044 # bec <_entry-0x7ffff414>
    80001948:	97a6                	add	a5,a5,s1
  uint64 pa = walkaddr(pagetable, victim_va);
    8000194a:	4a01                	li	s4,0
    for(int i = 0; i < 1024; i++) {
    8000194c:	40000693          	li	a3,1024
      if(p->swap_slots[i] == 0) {
    80001950:	4398                	lw	a4,0(a5)
    80001952:	ea0702e3          	beqz	a4,800017f6 <evict_page_lru+0xa8>
    for(int i = 0; i < 1024; i++) {
    80001956:	2a05                	addiw	s4,s4,1
    80001958:	0791                	addi	a5,a5,4
    8000195a:	feda1be3          	bne	s4,a3,80001950 <evict_page_lru+0x202>
      printf("[pid %d] SWAPFULL\n", p->pid);
    8000195e:	588c                	lw	a1,48(s1)
    80001960:	00007517          	auipc	a0,0x7
    80001964:	84050513          	addi	a0,a0,-1984 # 800081a0 <digits+0x168>
    80001968:	b5dfe0ef          	jal	ra,800004c4 <printf>
      printf("[pid %d] KILL swap-exhausted\n", p->pid);
    8000196c:	588c                	lw	a1,48(s1)
    8000196e:	00007517          	auipc	a0,0x7
    80001972:	84a50513          	addi	a0,a0,-1974 # 800081b8 <digits+0x180>
    80001976:	b4ffe0ef          	jal	ra,800004c4 <printf>
      setkilled(p);
    8000197a:	8526                	mv	a0,s1
    8000197c:	356010ef          	jal	ra,80002cd2 <setkilled>
      return 0;
    80001980:	4b81                	li	s7,0
    80001982:	bf99                	j	800018d8 <evict_page_lru+0x18a>

0000000080001984 <find_swapped_page>:
// Check if a virtual address has been swapped out
// Returns swap slot number if found, -1 if not swapped
int find_swapped_page(struct proc *p, uint64 va) {
    80001984:	1141                	addi	sp,sp,-16
    80001986:	e422                	sd	s0,8(sp)
    80001988:	0800                	addi	s0,sp,16
  uint64 page_va = PGROUNDDOWN(va);
    8000198a:	77fd                	lui	a5,0xfffff
    8000198c:	8dfd                	and	a1,a1,a5
  for(int i = 0; i < p->num_swapped; i++) {
    8000198e:	6785                	lui	a5,0x1
    80001990:	97aa                	add	a5,a5,a0
    80001992:	bc87a603          	lw	a2,-1080(a5) # bc8 <_entry-0x7ffff438>
    80001996:	02c05663          	blez	a2,800019c2 <find_swapped_page+0x3e>
    8000199a:	7c850713          	addi	a4,a0,1992
    8000199e:	4781                	li	a5,0
    if(p->swapped_pages[i].va == page_va) {
    800019a0:	6314                	ld	a3,0(a4)
    800019a2:	00b68863          	beq	a3,a1,800019b2 <find_swapped_page+0x2e>
  for(int i = 0; i < p->num_swapped; i++) {
    800019a6:	2785                	addiw	a5,a5,1
    800019a8:	0741                	addi	a4,a4,16
    800019aa:	fec79be3          	bne	a5,a2,800019a0 <find_swapped_page+0x1c>
      return p->swapped_pages[i].swap_slot;
    }
  }
  return -1;
    800019ae:	557d                	li	a0,-1
    800019b0:	a031                	j	800019bc <find_swapped_page+0x38>
      return p->swapped_pages[i].swap_slot;
    800019b2:	07c78793          	addi	a5,a5,124
    800019b6:	0792                	slli	a5,a5,0x4
    800019b8:	97aa                	add	a5,a5,a0
    800019ba:	4b88                	lw	a0,16(a5)
}
    800019bc:	6422                	ld	s0,8(sp)
    800019be:	0141                	addi	sp,sp,16
    800019c0:	8082                	ret
  return -1;
    800019c2:	557d                	li	a0,-1
    800019c4:	bfe5                	j	800019bc <find_swapped_page+0x38>

00000000800019c6 <remove_swapped_page>:

// Remove a page from the swapped list
void remove_swapped_page(struct proc *p, uint64 va) {
    800019c6:	1141                	addi	sp,sp,-16
    800019c8:	e422                	sd	s0,8(sp)
    800019ca:	0800                	addi	s0,sp,16
  uint64 page_va = PGROUNDDOWN(va);
    800019cc:	77fd                	lui	a5,0xfffff
    800019ce:	8dfd                	and	a1,a1,a5
  for(int i = 0; i < p->num_swapped; i++) {
    800019d0:	6785                	lui	a5,0x1
    800019d2:	97aa                	add	a5,a5,a0
    800019d4:	bc87a683          	lw	a3,-1080(a5) # bc8 <_entry-0x7ffff438>
    800019d8:	04d05e63          	blez	a3,80001a34 <remove_swapped_page+0x6e>
    800019dc:	7c850793          	addi	a5,a0,1992
    800019e0:	4701                	li	a4,0
    if(p->swapped_pages[i].va == page_va) {
    800019e2:	6390                	ld	a2,0(a5)
    800019e4:	00b60763          	beq	a2,a1,800019f2 <remove_swapped_page+0x2c>
  for(int i = 0; i < p->num_swapped; i++) {
    800019e8:	2705                	addiw	a4,a4,1
    800019ea:	07c1                	addi	a5,a5,16
    800019ec:	fed71be3          	bne	a4,a3,800019e2 <remove_swapped_page+0x1c>
    800019f0:	a091                	j	80001a34 <remove_swapped_page+0x6e>
      // Shift remaining entries
      for(int j = i; j < p->num_swapped - 1; j++) {
    800019f2:	fff6861b          	addiw	a2,a3,-1
    800019f6:	0006079b          	sext.w	a5,a2
    800019fa:	02f75963          	bge	a4,a5,80001a2c <remove_swapped_page+0x66>
    800019fe:	00471793          	slli	a5,a4,0x4
    80001a02:	97aa                	add	a5,a5,a0
    80001a04:	36f9                	addiw	a3,a3,-2
    80001a06:	9e99                	subw	a3,a3,a4
    80001a08:	1682                	slli	a3,a3,0x20
    80001a0a:	9281                	srli	a3,a3,0x20
    80001a0c:	9736                	add	a4,a4,a3
    80001a0e:	0712                	slli	a4,a4,0x4
    80001a10:	01050693          	addi	a3,a0,16
    80001a14:	9736                	add	a4,a4,a3
        p->swapped_pages[j] = p->swapped_pages[j + 1];
    80001a16:	7d87b683          	ld	a3,2008(a5)
    80001a1a:	7cd7b423          	sd	a3,1992(a5)
    80001a1e:	7e07b683          	ld	a3,2016(a5)
    80001a22:	7cd7b823          	sd	a3,2000(a5)
      for(int j = i; j < p->num_swapped - 1; j++) {
    80001a26:	07c1                	addi	a5,a5,16
    80001a28:	fee797e3          	bne	a5,a4,80001a16 <remove_swapped_page+0x50>
      }
      p->num_swapped--;
    80001a2c:	6785                	lui	a5,0x1
    80001a2e:	953e                	add	a0,a0,a5
    80001a30:	bcc52423          	sw	a2,-1080(a0)
      return;
    }
  }
}
    80001a34:	6422                	ld	s0,8(sp)
    80001a36:	0141                	addi	sp,sp,16
    80001a38:	8082                	ret

0000000080001a3a <handle_write_fault>:
// Handle write to read-only page (mark dirty and upgrade permissions)
int handle_write_fault(pagetable_t pagetable, uint64 va) {
    80001a3a:	7179                	addi	sp,sp,-48
    80001a3c:	f406                	sd	ra,40(sp)
    80001a3e:	f022                	sd	s0,32(sp)
    80001a40:	ec26                	sd	s1,24(sp)
    80001a42:	e84a                	sd	s2,16(sp)
    80001a44:	e44e                	sd	s3,8(sp)
    80001a46:	1800                	addi	s0,sp,48
    80001a48:	89aa                	mv	s3,a0
    80001a4a:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    80001a4c:	17d000ef          	jal	ra,800023c8 <myproc>
    80001a50:	892a                	mv	s2,a0
  uint64 page_va = PGROUNDDOWN(va);
    80001a52:	75fd                	lui	a1,0xfffff
    80001a54:	8ced                	and	s1,s1,a1
  
  pte_t *pte = walk(pagetable, page_va, 0);
    80001a56:	4601                	li	a2,0
    80001a58:	85a6                	mv	a1,s1
    80001a5a:	854e                	mv	a0,s3
    80001a5c:	c60ff0ef          	jal	ra,80000ebc <walk>
  if(pte == 0 || (*pte & PTE_V) == 0) {
    80001a60:	c53d                	beqz	a0,80001ace <handle_write_fault+0x94>
    80001a62:	611c                	ld	a5,0(a0)
    80001a64:	0017f713          	andi	a4,a5,1
    80001a68:	c72d                	beqz	a4,80001ad2 <handle_write_fault+0x98>
    return -1;
  }
  
  if((*pte & PTE_W) == 0 && (*pte & PTE_U) != 0) {
    80001a6a:	8bd1                	andi	a5,a5,20
    80001a6c:	4741                	li	a4,16
    80001a6e:	06e79463          	bne	a5,a4,80001ad6 <handle_write_fault+0x9c>
    // Mark it dirty in our resident set
    for(int i = 0; i < p->num_resident; i++) {
    80001a72:	7c092603          	lw	a2,1984(s2) # 17c0 <_entry-0x7fffe840>
    80001a76:	04c05063          	blez	a2,80001ab6 <handle_write_fault+0x7c>
    80001a7a:	1c090713          	addi	a4,s2,448
    80001a7e:	4781                	li	a5,0
      if(p->resident_pages[i].va == page_va) {
    80001a80:	6314                	ld	a3,0(a4)
    80001a82:	00968763          	beq	a3,s1,80001a90 <handle_write_fault+0x56>
    for(int i = 0; i < p->num_resident; i++) {
    80001a86:	2785                	addiw	a5,a5,1
    80001a88:	0761                	addi	a4,a4,24
    80001a8a:	fec79be3          	bne	a5,a2,80001a80 <handle_write_fault+0x46>
    80001a8e:	a025                	j	80001ab6 <handle_write_fault+0x7c>
        p->resident_pages[i].is_dirty = 1;
    80001a90:	00179713          	slli	a4,a5,0x1
    80001a94:	00f706b3          	add	a3,a4,a5
    80001a98:	068e                	slli	a3,a3,0x3
    80001a9a:	96ca                	add	a3,a3,s2
    80001a9c:	4605                	li	a2,1
    80001a9e:	1cc6a623          	sw	a2,460(a3)
        p->resident_pages[i].last_used_seq = p->next_fifo_seq;  // ADD THIS LINE
    80001aa2:	19092683          	lw	a3,400(s2)
    80001aa6:	97ba                	add	a5,a5,a4
    80001aa8:	078e                	slli	a5,a5,0x3
    80001aaa:	97ca                	add	a5,a5,s2
    80001aac:	1cd7aa23          	sw	a3,468(a5) # 11d4 <_entry-0x7fffee2c>
        p->next_fifo_seq++;  // ADD THIS LINE
    80001ab0:	2685                	addiw	a3,a3,1
    80001ab2:	18d92823          	sw	a3,400(s2)
        break;
      }
    }
    
    *pte |= PTE_W;
    80001ab6:	611c                	ld	a5,0(a0)
    80001ab8:	0047e793          	ori	a5,a5,4
    80001abc:	e11c                	sd	a5,0(a0)
    return 0;
    80001abe:	4501                	li	a0,0
  }
  
  return -1;
}
    80001ac0:	70a2                	ld	ra,40(sp)
    80001ac2:	7402                	ld	s0,32(sp)
    80001ac4:	64e2                	ld	s1,24(sp)
    80001ac6:	6942                	ld	s2,16(sp)
    80001ac8:	69a2                	ld	s3,8(sp)
    80001aca:	6145                	addi	sp,sp,48
    80001acc:	8082                	ret
    return -1;
    80001ace:	557d                	li	a0,-1
    80001ad0:	bfc5                	j	80001ac0 <handle_write_fault+0x86>
    80001ad2:	557d                	li	a0,-1
    80001ad4:	b7f5                	j	80001ac0 <handle_write_fault+0x86>
  return -1;
    80001ad6:	557d                	li	a0,-1
    80001ad8:	b7e5                	j	80001ac0 <handle_write_fault+0x86>

0000000080001ada <vmfault>:


uint64
vmfault(pagetable_t pagetable, uint64 va, int is_write)
{
    80001ada:	715d                	addi	sp,sp,-80
    80001adc:	e486                	sd	ra,72(sp)
    80001ade:	e0a2                	sd	s0,64(sp)
    80001ae0:	fc26                	sd	s1,56(sp)
    80001ae2:	f84a                	sd	s2,48(sp)
    80001ae4:	f44e                	sd	s3,40(sp)
    80001ae6:	f052                	sd	s4,32(sp)
    80001ae8:	ec56                	sd	s5,24(sp)
    80001aea:	e85a                	sd	s6,16(sp)
    80001aec:	e45e                	sd	s7,8(sp)
    80001aee:	0880                	addi	s0,sp,80
    80001af0:	8aaa                	mv	s5,a0
    80001af2:	892e                	mv	s2,a1
    80001af4:	8b32                	mv	s6,a2
  struct proc *p = myproc();
    80001af6:	0d3000ef          	jal	ra,800023c8 <myproc>
    80001afa:	84aa                	mv	s1,a0
  char *mem;
  uint64 page_va = PGROUNDDOWN(va);
    80001afc:	79fd                	lui	s3,0xfffff
    80001afe:	013979b3          	and	s3,s2,s3
  
  // printf("[DEBUG] vmfault: va=0x%lx, p->sz=0x%lx, stack_range=[0x%lx,0x%lx)\n", 
  //        va, p->sz, p->sz - USERSTACK*PGSIZE, p->sz);
  
  // NEW - CHECK IF PAGE WAS SWAPPED OUT (ADD THIS FIRST)
  int swap_slot = find_swapped_page(p, va);
    80001b02:	85ca                	mv	a1,s2
    80001b04:	e81ff0ef          	jal	ra,80001984 <find_swapped_page>
  if(swap_slot >= 0) {
    80001b08:	16054463          	bltz	a0,80001c70 <vmfault+0x196>
    80001b0c:	8a2a                	mv	s4,a0
    // Page is in swap - reload it
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=swap\n", 
    80001b0e:	588c                	lw	a1,48(s1)
    80001b10:	00006697          	auipc	a3,0x6
    80001b14:	7c068693          	addi	a3,a3,1984 # 800082d0 <digits+0x298>
    80001b18:	000b1663          	bnez	s6,80001b24 <vmfault+0x4a>
    80001b1c:	00007697          	auipc	a3,0x7
    80001b20:	edc68693          	addi	a3,a3,-292 # 800089f8 <syscalls+0x1f8>
    80001b24:	864e                	mv	a2,s3
    80001b26:	00006517          	auipc	a0,0x6
    80001b2a:	7b250513          	addi	a0,a0,1970 # 800082d8 <digits+0x2a0>
    80001b2e:	997fe0ef          	jal	ra,800004c4 <printf>
            p->pid, page_va, is_write ? "write" : "read");
    
    // Allocate memory for the page
    if((mem = kalloc()) == 0) {
    80001b32:	f6bfe0ef          	jal	ra,80000a9c <kalloc>
    80001b36:	892a                	mv	s2,a0
    80001b38:	c569                	beqz	a0,80001c02 <vmfault+0x128>
    return -1;
  }
}
    
    // Read page from swap file
    if(p->swapfile) {
    80001b3a:	6785                	lui	a5,0x1
    80001b3c:	97a6                	add	a5,a5,s1
    80001b3e:	bd07b783          	ld	a5,-1072(a5) # bd0 <_entry-0x7ffff430>
    80001b42:	10078663          	beqz	a5,80001c4e <vmfault+0x174>
      p->swapfile->off = swap_slot * PGSIZE;
    80001b46:	00ca171b          	slliw	a4,s4,0xc
    80001b4a:	d398                	sw	a4,32(a5)
      int bytes_read = fileread(p->swapfile, (uint64)mem, PGSIZE);
    80001b4c:	8b4a                	mv	s6,s2
    80001b4e:	6b85                	lui	s7,0x1
    80001b50:	017487b3          	add	a5,s1,s7
    80001b54:	6605                	lui	a2,0x1
    80001b56:	85ca                	mv	a1,s2
    80001b58:	bd07b503          	ld	a0,-1072(a5)
    80001b5c:	2ec030ef          	jal	ra,80004e48 <fileread>
      if(bytes_read != PGSIZE) {
    80001b60:	0d751063          	bne	a0,s7,80001c20 <vmfault+0x146>
      kfree(mem);
      return -1;
    }
    
    // Free the swap slot
    p->swap_slots[swap_slot] = 0;
    80001b64:	2f8a0793          	addi	a5,s4,760
    80001b68:	078a                	slli	a5,a5,0x2
    80001b6a:	97a6                	add	a5,a5,s1
    80001b6c:	0007a623          	sw	zero,12(a5)
    p->num_swap_slots_used--;
    80001b70:	6789                	lui	a5,0x2
    80001b72:	97a6                	add	a5,a5,s1
    80001b74:	bec7a703          	lw	a4,-1044(a5) # 1bec <_entry-0x7fffe414>
    80001b78:	377d                	addiw	a4,a4,-1
    80001b7a:	bee7a623          	sw	a4,-1044(a5)
    
    // Remove from swapped list
    remove_swapped_page(p, page_va);
    80001b7e:	85ce                	mv	a1,s3
    80001b80:	8526                	mv	a0,s1
    80001b82:	e45ff0ef          	jal	ra,800019c6 <remove_swapped_page>
    
    printf("[pid %d] SWAPIN va=0x%lx slot=%d\n", p->pid, page_va, swap_slot);
    80001b86:	86d2                	mv	a3,s4
    80001b88:	864e                	mv	a2,s3
    80001b8a:	588c                	lw	a1,48(s1)
    80001b8c:	00006517          	auipc	a0,0x6
    80001b90:	7c450513          	addi	a0,a0,1988 # 80008350 <digits+0x318>
    80001b94:	931fe0ef          	jal	ra,800004c4 <printf>
    
    // Map the page
    // Map the page as READ-ONLY initially (will upgrade on first write)
if(mappages(pagetable, page_va, PGSIZE, (uint64)mem, PTE_R | PTE_U) < 0) {
    80001b98:	4749                	li	a4,18
    80001b9a:	86ca                	mv	a3,s2
    80001b9c:	6605                	lui	a2,0x1
    80001b9e:	85ce                	mv	a1,s3
    80001ba0:	8556                	mv	a0,s5
    80001ba2:	bf2ff0ef          	jal	ra,80000f94 <mappages>
    80001ba6:	0c054063          	bltz	a0,80001c66 <vmfault+0x18c>
      kfree(mem);
      return -1;
    }
    
    printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, page_va, p->next_fifo_seq);
    80001baa:	1904a683          	lw	a3,400(s1)
    80001bae:	864e                	mv	a2,s3
    80001bb0:	588c                	lw	a1,48(s1)
    80001bb2:	00006517          	auipc	a0,0x6
    80001bb6:	7c650513          	addi	a0,a0,1990 # 80008378 <digits+0x340>
    80001bba:	90bfe0ef          	jal	ra,800004c4 <printf>
    add_resident_page(p, page_va, p->next_fifo_seq);
    80001bbe:	1904a603          	lw	a2,400(s1)
    80001bc2:	85ce                	mv	a1,s3
    80001bc4:	8526                	mv	a0,s1
    80001bc6:	91bff0ef          	jal	ra,800014e0 <add_resident_page>
    p->next_fifo_seq++;
    80001bca:	1904a783          	lw	a5,400(s1)
    80001bce:	2785                	addiw	a5,a5,1
    80001bd0:	0007871b          	sext.w	a4,a5
    80001bd4:	18f4a823          	sw	a5,400(s1)
    
    if(p->next_fifo_seq >= 1000000) {
    80001bd8:	000f47b7          	lui	a5,0xf4
    80001bdc:	23f78793          	addi	a5,a5,575 # f423f <_entry-0x7ff0bdc1>
    80001be0:	04e7db63          	bge	a5,a4,80001c36 <vmfault+0x15c>
      for(int i = 0; i < p->num_resident; i++) {
    80001be4:	7c04a683          	lw	a3,1984(s1)
    80001be8:	00d05a63          	blez	a3,80001bfc <vmfault+0x122>
    80001bec:	1c848713          	addi	a4,s1,456
    80001bf0:	4781                	li	a5,0
        p->resident_pages[i].seq = i;
    80001bf2:	c31c                	sw	a5,0(a4)
      for(int i = 0; i < p->num_resident; i++) {
    80001bf4:	2785                	addiw	a5,a5,1
    80001bf6:	0761                	addi	a4,a4,24
    80001bf8:	fef69de3          	bne	a3,a5,80001bf2 <vmfault+0x118>
      }
      p->next_fifo_seq = p->num_resident;
    80001bfc:	18d4a823          	sw	a3,400(s1)
    80001c00:	a81d                	j	80001c36 <vmfault+0x15c>
  printf("[pid %d] MEMFULL\n", p->pid);
    80001c02:	588c                	lw	a1,48(s1)
    80001c04:	00006517          	auipc	a0,0x6
    80001c08:	70c50513          	addi	a0,a0,1804 # 80008310 <digits+0x2d8>
    80001c0c:	8b9fe0ef          	jal	ra,800004c4 <printf>
  mem = evict_page_fifo(p, pagetable);
    80001c10:	85d6                	mv	a1,s5
    80001c12:	8526                	mv	a0,s1
    80001c14:	905ff0ef          	jal	ra,80001518 <evict_page_fifo>
    80001c18:	892a                	mv	s2,a0
  if(mem == 0) {
    80001c1a:	f105                	bnez	a0,80001b3a <vmfault+0x60>
    return -1;
    80001c1c:	5b7d                	li	s6,-1
    80001c1e:	a821                	j	80001c36 <vmfault+0x15c>
        printf("[pid %d] ERROR: swap read failed\n", p->pid);
    80001c20:	588c                	lw	a1,48(s1)
    80001c22:	00006517          	auipc	a0,0x6
    80001c26:	70650513          	addi	a0,a0,1798 # 80008328 <digits+0x2f0>
    80001c2a:	89bfe0ef          	jal	ra,800004c4 <printf>
        kfree(mem);
    80001c2e:	854a                	mv	a0,s2
    80001c30:	d8dfe0ef          	jal	ra,800009bc <kfree>
        return -1;
    80001c34:	5b7d                	li	s6,-1
            p->pid, page_va, is_write ? "write" : "read");
    printf("[pid %d] KILL invalid-access va=0x%lx access=%s\n", 
            p->pid, page_va, is_write ? "write" : "read");
    return -1;
  }
    80001c36:	855a                	mv	a0,s6
    80001c38:	60a6                	ld	ra,72(sp)
    80001c3a:	6406                	ld	s0,64(sp)
    80001c3c:	74e2                	ld	s1,56(sp)
    80001c3e:	7942                	ld	s2,48(sp)
    80001c40:	79a2                	ld	s3,40(sp)
    80001c42:	7a02                	ld	s4,32(sp)
    80001c44:	6ae2                	ld	s5,24(sp)
    80001c46:	6b42                	ld	s6,16(sp)
    80001c48:	6ba2                	ld	s7,8(sp)
    80001c4a:	6161                	addi	sp,sp,80
    80001c4c:	8082                	ret
      printf("[pid %d] ERROR: no swap file\n", p->pid);
    80001c4e:	588c                	lw	a1,48(s1)
    80001c50:	00006517          	auipc	a0,0x6
    80001c54:	5d850513          	addi	a0,a0,1496 # 80008228 <digits+0x1f0>
    80001c58:	86dfe0ef          	jal	ra,800004c4 <printf>
      kfree(mem);
    80001c5c:	854a                	mv	a0,s2
    80001c5e:	d5ffe0ef          	jal	ra,800009bc <kfree>
      return -1;
    80001c62:	5b7d                	li	s6,-1
    80001c64:	bfc9                	j	80001c36 <vmfault+0x15c>
      kfree(mem);
    80001c66:	854a                	mv	a0,s2
    80001c68:	d55fe0ef          	jal	ra,800009bc <kfree>
      return -1;
    80001c6c:	5b7d                	li	s6,-1
    80001c6e:	b7e1                	j	80001c36 <vmfault+0x15c>
  if(va >= p->sz - USERSTACK*PGSIZE && va < p->sz) {
    80001c70:	64b8                	ld	a4,72(s1)
    80001c72:	77fd                	lui	a5,0xfffff
    80001c74:	97ba                	add	a5,a5,a4
    80001c76:	0ef96163          	bltu	s2,a5,80001d58 <vmfault+0x27e>
    80001c7a:	0ce97f63          	bgeu	s2,a4,80001d58 <vmfault+0x27e>
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=stack\n", 
    80001c7e:	588c                	lw	a1,48(s1)
    80001c80:	00006697          	auipc	a3,0x6
    80001c84:	65068693          	addi	a3,a3,1616 # 800082d0 <digits+0x298>
    80001c88:	000b1663          	bnez	s6,80001c94 <vmfault+0x1ba>
    80001c8c:	00007697          	auipc	a3,0x7
    80001c90:	d6c68693          	addi	a3,a3,-660 # 800089f8 <syscalls+0x1f8>
    80001c94:	864e                	mv	a2,s3
    80001c96:	00006517          	auipc	a0,0x6
    80001c9a:	70a50513          	addi	a0,a0,1802 # 800083a0 <digits+0x368>
    80001c9e:	827fe0ef          	jal	ra,800004c4 <printf>
   if((mem = kalloc()) == 0) {
    80001ca2:	dfbfe0ef          	jal	ra,80000a9c <kalloc>
    80001ca6:	892a                	mv	s2,a0
    80001ca8:	c541                	beqz	a0,80001d30 <vmfault+0x256>
    memset(mem, 0, PGSIZE);
    80001caa:	6605                	lui	a2,0x1
    80001cac:	4581                	li	a1,0
    80001cae:	854a                	mv	a0,s2
    80001cb0:	f91fe0ef          	jal	ra,80000c40 <memset>
if(mappages(pagetable, page_va, PGSIZE, (uint64)mem, PTE_R | PTE_U) < 0) {
    80001cb4:	8b4a                	mv	s6,s2
    80001cb6:	4749                	li	a4,18
    80001cb8:	86ca                	mv	a3,s2
    80001cba:	6605                	lui	a2,0x1
    80001cbc:	85ce                	mv	a1,s3
    80001cbe:	8556                	mv	a0,s5
    80001cc0:	ad4ff0ef          	jal	ra,80000f94 <mappages>
    80001cc4:	08054563          	bltz	a0,80001d4e <vmfault+0x274>
    printf("[pid %d] ALLOC va=0x%lx\n", p->pid, page_va);
    80001cc8:	864e                	mv	a2,s3
    80001cca:	588c                	lw	a1,48(s1)
    80001ccc:	00006517          	auipc	a0,0x6
    80001cd0:	70c50513          	addi	a0,a0,1804 # 800083d8 <digits+0x3a0>
    80001cd4:	ff0fe0ef          	jal	ra,800004c4 <printf>
    printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, page_va, p->next_fifo_seq);
    80001cd8:	1904a683          	lw	a3,400(s1)
    80001cdc:	864e                	mv	a2,s3
    80001cde:	588c                	lw	a1,48(s1)
    80001ce0:	00006517          	auipc	a0,0x6
    80001ce4:	69850513          	addi	a0,a0,1688 # 80008378 <digits+0x340>
    80001ce8:	fdcfe0ef          	jal	ra,800004c4 <printf>
    add_resident_page(p, page_va, p->next_fifo_seq);
    80001cec:	1904a603          	lw	a2,400(s1)
    80001cf0:	85ce                	mv	a1,s3
    80001cf2:	8526                	mv	a0,s1
    80001cf4:	fecff0ef          	jal	ra,800014e0 <add_resident_page>
    p->next_fifo_seq++;
    80001cf8:	1904a783          	lw	a5,400(s1)
    80001cfc:	2785                	addiw	a5,a5,1
    80001cfe:	0007871b          	sext.w	a4,a5
    80001d02:	18f4a823          	sw	a5,400(s1)
if(p->next_fifo_seq >= 1000000) {
    80001d06:	000f47b7          	lui	a5,0xf4
    80001d0a:	23f78793          	addi	a5,a5,575 # f423f <_entry-0x7ff0bdc1>
    80001d0e:	f2e7d4e3          	bge	a5,a4,80001c36 <vmfault+0x15c>
  for(int i = 0; i < p->num_resident; i++) {
    80001d12:	7c04a683          	lw	a3,1984(s1)
    80001d16:	00d05a63          	blez	a3,80001d2a <vmfault+0x250>
    80001d1a:	1c848713          	addi	a4,s1,456
    80001d1e:	4781                	li	a5,0
    p->resident_pages[i].seq = i;
    80001d20:	c31c                	sw	a5,0(a4)
  for(int i = 0; i < p->num_resident; i++) {
    80001d22:	2785                	addiw	a5,a5,1
    80001d24:	0761                	addi	a4,a4,24
    80001d26:	fed79de3          	bne	a5,a3,80001d20 <vmfault+0x246>
  p->next_fifo_seq = p->num_resident;
    80001d2a:	18d4a823          	sw	a3,400(s1)
    80001d2e:	b721                	j	80001c36 <vmfault+0x15c>
  printf("[pid %d] MEMFULL\n", p->pid);
    80001d30:	588c                	lw	a1,48(s1)
    80001d32:	00006517          	auipc	a0,0x6
    80001d36:	5de50513          	addi	a0,a0,1502 # 80008310 <digits+0x2d8>
    80001d3a:	f8afe0ef          	jal	ra,800004c4 <printf>
  mem = evict_page_fifo(p, pagetable);
    80001d3e:	85d6                	mv	a1,s5
    80001d40:	8526                	mv	a0,s1
    80001d42:	fd6ff0ef          	jal	ra,80001518 <evict_page_fifo>
    80001d46:	892a                	mv	s2,a0
  if(mem == 0) {
    80001d48:	f12d                	bnez	a0,80001caa <vmfault+0x1d0>
    return -1;
    80001d4a:	5b7d                	li	s6,-1
    80001d4c:	b5ed                	j	80001c36 <vmfault+0x15c>
      kfree(mem);
    80001d4e:	854a                	mv	a0,s2
    80001d50:	c6dfe0ef          	jal	ra,800009bc <kfree>
      return -1;
    80001d54:	5b7d                	li	s6,-1
    80001d56:	b5c5                	j	80001c36 <vmfault+0x15c>
  else if(va >= p->text_start && va < p->text_end) {
    80001d58:	1684b703          	ld	a4,360(s1)
    80001d5c:	12e96963          	bltu	s2,a4,80001e8e <vmfault+0x3b4>
    80001d60:	1704b703          	ld	a4,368(s1)
    80001d64:	12e97563          	bgeu	s2,a4,80001e8e <vmfault+0x3b4>
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=exec\n", 
    80001d68:	588c                	lw	a1,48(s1)
    80001d6a:	00006697          	auipc	a3,0x6
    80001d6e:	56668693          	addi	a3,a3,1382 # 800082d0 <digits+0x298>
    80001d72:	000b1663          	bnez	s6,80001d7e <vmfault+0x2a4>
    80001d76:	00007697          	auipc	a3,0x7
    80001d7a:	c8268693          	addi	a3,a3,-894 # 800089f8 <syscalls+0x1f8>
    80001d7e:	864e                	mv	a2,s3
    80001d80:	00006517          	auipc	a0,0x6
    80001d84:	67850513          	addi	a0,a0,1656 # 800083f8 <digits+0x3c0>
    80001d88:	f3cfe0ef          	jal	ra,800004c4 <printf>
  if((mem = kalloc()) == 0) {
    80001d8c:	d11fe0ef          	jal	ra,80000a9c <kalloc>
    80001d90:	892a                	mv	s2,a0
    80001d92:	c969                	beqz	a0,80001e64 <vmfault+0x38a>
    memset(mem, 0, PGSIZE);  // Zero-fill first
    80001d94:	6605                	lui	a2,0x1
    80001d96:	4581                	li	a1,0
    80001d98:	854a                	mv	a0,s2
    80001d9a:	ea7fe0ef          	jal	ra,80000c40 <memset>
    if(p->exec_inode && p->text_file_size > 0) {
    80001d9e:	1984b503          	ld	a0,408(s1)
    80001da2:	c139                	beqz	a0,80001de8 <vmfault+0x30e>
    80001da4:	1a84b783          	ld	a5,424(s1)
    80001da8:	c3a1                	beqz	a5,80001de8 <vmfault+0x30e>
      uint64 page_offset_in_segment = page_va - p->text_start;
    80001daa:	1684b683          	ld	a3,360(s1)
    80001dae:	40d98733          	sub	a4,s3,a3
      uint64 file_offset = p->text_file_offset + page_offset_in_segment;
    80001db2:	1a04ba03          	ld	s4,416(s1)
    80001db6:	9a3a                	add	s4,s4,a4
      if(page_offset_in_segment + PGSIZE > p->text_file_size) {
    80001db8:	6605                	lui	a2,0x1
    80001dba:	9732                	add	a4,a4,a2
      uint64 bytes_to_read = PGSIZE;
    80001dbc:	6b05                	lui	s6,0x1
      if(page_offset_in_segment + PGSIZE > p->text_file_size) {
    80001dbe:	00e7f563          	bgeu	a5,a4,80001dc8 <vmfault+0x2ee>
        bytes_to_read = p->text_file_size - page_offset_in_segment;
    80001dc2:	97b6                	add	a5,a5,a3
    80001dc4:	41378b33          	sub	s6,a5,s3
      ilock(p->exec_inode);
    80001dc8:	18e020ef          	jal	ra,80003f56 <ilock>
      readi(p->exec_inode, 0, (uint64)mem, file_offset, bytes_to_read);
    80001dcc:	000b071b          	sext.w	a4,s6
    80001dd0:	000a069b          	sext.w	a3,s4
    80001dd4:	864a                	mv	a2,s2
    80001dd6:	4581                	li	a1,0
    80001dd8:	1984b503          	ld	a0,408(s1)
    80001ddc:	506020ef          	jal	ra,800042e2 <readi>
      iunlock(p->exec_inode);
    80001de0:	1984b503          	ld	a0,408(s1)
    80001de4:	21c020ef          	jal	ra,80004000 <iunlock>
    if(mappages(pagetable, page_va, PGSIZE, (uint64)mem, PTE_R | PTE_X | PTE_U) < 0) {
    80001de8:	8b4a                	mv	s6,s2
    80001dea:	4769                	li	a4,26
    80001dec:	86ca                	mv	a3,s2
    80001dee:	6605                	lui	a2,0x1
    80001df0:	85ce                	mv	a1,s3
    80001df2:	8556                	mv	a0,s5
    80001df4:	9a0ff0ef          	jal	ra,80000f94 <mappages>
    80001df8:	08054663          	bltz	a0,80001e84 <vmfault+0x3aa>
    printf("[pid %d] LOADEXEC va=0x%lx\n", p->pid, page_va);
    80001dfc:	864e                	mv	a2,s3
    80001dfe:	588c                	lw	a1,48(s1)
    80001e00:	00006517          	auipc	a0,0x6
    80001e04:	63050513          	addi	a0,a0,1584 # 80008430 <digits+0x3f8>
    80001e08:	ebcfe0ef          	jal	ra,800004c4 <printf>
    printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, page_va, p->next_fifo_seq);
    80001e0c:	1904a683          	lw	a3,400(s1)
    80001e10:	864e                	mv	a2,s3
    80001e12:	588c                	lw	a1,48(s1)
    80001e14:	00006517          	auipc	a0,0x6
    80001e18:	56450513          	addi	a0,a0,1380 # 80008378 <digits+0x340>
    80001e1c:	ea8fe0ef          	jal	ra,800004c4 <printf>
    add_resident_page(p, page_va, p->next_fifo_seq);
    80001e20:	1904a603          	lw	a2,400(s1)
    80001e24:	85ce                	mv	a1,s3
    80001e26:	8526                	mv	a0,s1
    80001e28:	eb8ff0ef          	jal	ra,800014e0 <add_resident_page>
    p->next_fifo_seq++;
    80001e2c:	1904a783          	lw	a5,400(s1)
    80001e30:	2785                	addiw	a5,a5,1
    80001e32:	0007871b          	sext.w	a4,a5
    80001e36:	18f4a823          	sw	a5,400(s1)
if(p->next_fifo_seq >= 1000000) {
    80001e3a:	000f47b7          	lui	a5,0xf4
    80001e3e:	23f78793          	addi	a5,a5,575 # f423f <_entry-0x7ff0bdc1>
    80001e42:	dee7dae3          	bge	a5,a4,80001c36 <vmfault+0x15c>
  for(int i = 0; i < p->num_resident; i++) {
    80001e46:	7c04a683          	lw	a3,1984(s1)
    80001e4a:	00d05a63          	blez	a3,80001e5e <vmfault+0x384>
    80001e4e:	1c848713          	addi	a4,s1,456
    80001e52:	4781                	li	a5,0
    p->resident_pages[i].seq = i;
    80001e54:	c31c                	sw	a5,0(a4)
  for(int i = 0; i < p->num_resident; i++) {
    80001e56:	2785                	addiw	a5,a5,1
    80001e58:	0761                	addi	a4,a4,24
    80001e5a:	fed79de3          	bne	a5,a3,80001e54 <vmfault+0x37a>
  p->next_fifo_seq = p->num_resident;
    80001e5e:	18d4a823          	sw	a3,400(s1)
    80001e62:	bbd1                	j	80001c36 <vmfault+0x15c>
  printf("[pid %d] MEMFULL\n", p->pid);
    80001e64:	588c                	lw	a1,48(s1)
    80001e66:	00006517          	auipc	a0,0x6
    80001e6a:	4aa50513          	addi	a0,a0,1194 # 80008310 <digits+0x2d8>
    80001e6e:	e56fe0ef          	jal	ra,800004c4 <printf>
  mem = evict_page_fifo(p, pagetable);
    80001e72:	85d6                	mv	a1,s5
    80001e74:	8526                	mv	a0,s1
    80001e76:	ea2ff0ef          	jal	ra,80001518 <evict_page_fifo>
    80001e7a:	892a                	mv	s2,a0
  if(mem == 0) {
    80001e7c:	f0051ce3          	bnez	a0,80001d94 <vmfault+0x2ba>
    return -1;
    80001e80:	5b7d                	li	s6,-1
    80001e82:	bb55                	j	80001c36 <vmfault+0x15c>
      kfree(mem);
    80001e84:	854a                	mv	a0,s2
    80001e86:	b37fe0ef          	jal	ra,800009bc <kfree>
      return -1;
    80001e8a:	5b7d                	li	s6,-1
    80001e8c:	b36d                	j	80001c36 <vmfault+0x15c>
  else if(va >= p->data_start && va < p->data_end) {
    80001e8e:	1784b703          	ld	a4,376(s1)
    80001e92:	12e96963          	bltu	s2,a4,80001fc4 <vmfault+0x4ea>
    80001e96:	1804b703          	ld	a4,384(s1)
    80001e9a:	12e97563          	bgeu	s2,a4,80001fc4 <vmfault+0x4ea>
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=exec\n", 
    80001e9e:	588c                	lw	a1,48(s1)
    80001ea0:	00006697          	auipc	a3,0x6
    80001ea4:	43068693          	addi	a3,a3,1072 # 800082d0 <digits+0x298>
    80001ea8:	000b1663          	bnez	s6,80001eb4 <vmfault+0x3da>
    80001eac:	00007697          	auipc	a3,0x7
    80001eb0:	b4c68693          	addi	a3,a3,-1204 # 800089f8 <syscalls+0x1f8>
    80001eb4:	864e                	mv	a2,s3
    80001eb6:	00006517          	auipc	a0,0x6
    80001eba:	54250513          	addi	a0,a0,1346 # 800083f8 <digits+0x3c0>
    80001ebe:	e06fe0ef          	jal	ra,800004c4 <printf>
  if((mem = kalloc()) == 0) {
    80001ec2:	bdbfe0ef          	jal	ra,80000a9c <kalloc>
    80001ec6:	892a                	mv	s2,a0
    80001ec8:	c969                	beqz	a0,80001f9a <vmfault+0x4c0>
} memset(mem, 0, PGSIZE);  // Zero-fill first
    80001eca:	6605                	lui	a2,0x1
    80001ecc:	4581                	li	a1,0
    80001ece:	854a                	mv	a0,s2
    80001ed0:	d71fe0ef          	jal	ra,80000c40 <memset>
    if(p->exec_inode && p->data_file_size > 0) {
    80001ed4:	1984b503          	ld	a0,408(s1)
    80001ed8:	c139                	beqz	a0,80001f1e <vmfault+0x444>
    80001eda:	1b84b783          	ld	a5,440(s1)
    80001ede:	c3a1                	beqz	a5,80001f1e <vmfault+0x444>
      uint64 page_offset_in_segment = page_va - p->data_start;
    80001ee0:	1784b683          	ld	a3,376(s1)
    80001ee4:	40d98733          	sub	a4,s3,a3
      uint64 file_offset = p->data_file_offset + page_offset_in_segment;
    80001ee8:	1b04ba03          	ld	s4,432(s1)
    80001eec:	9a3a                	add	s4,s4,a4
      if(page_offset_in_segment + PGSIZE > p->data_file_size) {
    80001eee:	6605                	lui	a2,0x1
    80001ef0:	9732                	add	a4,a4,a2
      uint64 bytes_to_read = PGSIZE;
    80001ef2:	6b05                	lui	s6,0x1
      if(page_offset_in_segment + PGSIZE > p->data_file_size) {
    80001ef4:	00e7f563          	bgeu	a5,a4,80001efe <vmfault+0x424>
        bytes_to_read = p->data_file_size - page_offset_in_segment;
    80001ef8:	97b6                	add	a5,a5,a3
    80001efa:	41378b33          	sub	s6,a5,s3
      ilock(p->exec_inode);
    80001efe:	058020ef          	jal	ra,80003f56 <ilock>
      readi(p->exec_inode, 0, (uint64)mem, file_offset, bytes_to_read);
    80001f02:	000b071b          	sext.w	a4,s6
    80001f06:	000a069b          	sext.w	a3,s4
    80001f0a:	864a                	mv	a2,s2
    80001f0c:	4581                	li	a1,0
    80001f0e:	1984b503          	ld	a0,408(s1)
    80001f12:	3d0020ef          	jal	ra,800042e2 <readi>
      iunlock(p->exec_inode);
    80001f16:	1984b503          	ld	a0,408(s1)
    80001f1a:	0e6020ef          	jal	ra,80004000 <iunlock>
if(mappages(pagetable, page_va, PGSIZE, (uint64)mem, PTE_R | PTE_U) < 0) {
    80001f1e:	8b4a                	mv	s6,s2
    80001f20:	4749                	li	a4,18
    80001f22:	86ca                	mv	a3,s2
    80001f24:	6605                	lui	a2,0x1
    80001f26:	85ce                	mv	a1,s3
    80001f28:	8556                	mv	a0,s5
    80001f2a:	86aff0ef          	jal	ra,80000f94 <mappages>
    80001f2e:	08054663          	bltz	a0,80001fba <vmfault+0x4e0>
    printf("[pid %d] LOADEXEC va=0x%lx\n", p->pid, page_va);
    80001f32:	864e                	mv	a2,s3
    80001f34:	588c                	lw	a1,48(s1)
    80001f36:	00006517          	auipc	a0,0x6
    80001f3a:	4fa50513          	addi	a0,a0,1274 # 80008430 <digits+0x3f8>
    80001f3e:	d86fe0ef          	jal	ra,800004c4 <printf>
    printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, page_va, p->next_fifo_seq);
    80001f42:	1904a683          	lw	a3,400(s1)
    80001f46:	864e                	mv	a2,s3
    80001f48:	588c                	lw	a1,48(s1)
    80001f4a:	00006517          	auipc	a0,0x6
    80001f4e:	42e50513          	addi	a0,a0,1070 # 80008378 <digits+0x340>
    80001f52:	d72fe0ef          	jal	ra,800004c4 <printf>
    add_resident_page(p, page_va, p->next_fifo_seq);
    80001f56:	1904a603          	lw	a2,400(s1)
    80001f5a:	85ce                	mv	a1,s3
    80001f5c:	8526                	mv	a0,s1
    80001f5e:	d82ff0ef          	jal	ra,800014e0 <add_resident_page>
    p->next_fifo_seq++;
    80001f62:	1904a783          	lw	a5,400(s1)
    80001f66:	2785                	addiw	a5,a5,1
    80001f68:	0007871b          	sext.w	a4,a5
    80001f6c:	18f4a823          	sw	a5,400(s1)
if(p->next_fifo_seq >= 1000000) {
    80001f70:	000f47b7          	lui	a5,0xf4
    80001f74:	23f78793          	addi	a5,a5,575 # f423f <_entry-0x7ff0bdc1>
    80001f78:	cae7dfe3          	bge	a5,a4,80001c36 <vmfault+0x15c>
  for(int i = 0; i < p->num_resident; i++) {
    80001f7c:	7c04a683          	lw	a3,1984(s1)
    80001f80:	00d05a63          	blez	a3,80001f94 <vmfault+0x4ba>
    80001f84:	1c848713          	addi	a4,s1,456
    80001f88:	4781                	li	a5,0
    p->resident_pages[i].seq = i;
    80001f8a:	c31c                	sw	a5,0(a4)
  for(int i = 0; i < p->num_resident; i++) {
    80001f8c:	2785                	addiw	a5,a5,1
    80001f8e:	0761                	addi	a4,a4,24
    80001f90:	fed79de3          	bne	a5,a3,80001f8a <vmfault+0x4b0>
  p->next_fifo_seq = p->num_resident;
    80001f94:	18d4a823          	sw	a3,400(s1)
    80001f98:	b979                	j	80001c36 <vmfault+0x15c>
  printf("[pid %d] MEMFULL\n", p->pid);
    80001f9a:	588c                	lw	a1,48(s1)
    80001f9c:	00006517          	auipc	a0,0x6
    80001fa0:	37450513          	addi	a0,a0,884 # 80008310 <digits+0x2d8>
    80001fa4:	d20fe0ef          	jal	ra,800004c4 <printf>
  mem = evict_page_fifo(p, pagetable);
    80001fa8:	85d6                	mv	a1,s5
    80001faa:	8526                	mv	a0,s1
    80001fac:	d6cff0ef          	jal	ra,80001518 <evict_page_fifo>
    80001fb0:	892a                	mv	s2,a0
  if(mem == 0) {
    80001fb2:	f0051ce3          	bnez	a0,80001eca <vmfault+0x3f0>
    return -1;
    80001fb6:	5b7d                	li	s6,-1
    80001fb8:	b9bd                	j	80001c36 <vmfault+0x15c>
      kfree(mem);
    80001fba:	854a                	mv	a0,s2
    80001fbc:	a01fe0ef          	jal	ra,800009bc <kfree>
      return -1;
    80001fc0:	5b7d                	li	s6,-1
    80001fc2:	b995                	j	80001c36 <vmfault+0x15c>
  else if(va >= p->heap_start && va < p->sz - USERSTACK*PGSIZE) {
    80001fc4:	1884b703          	ld	a4,392(s1)
    80001fc8:	0ee96163          	bltu	s2,a4,800020aa <vmfault+0x5d0>
    80001fcc:	0cf97f63          	bgeu	s2,a5,800020aa <vmfault+0x5d0>
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=heap\n", 
    80001fd0:	588c                	lw	a1,48(s1)
    80001fd2:	00006697          	auipc	a3,0x6
    80001fd6:	2fe68693          	addi	a3,a3,766 # 800082d0 <digits+0x298>
    80001fda:	000b1663          	bnez	s6,80001fe6 <vmfault+0x50c>
    80001fde:	00007697          	auipc	a3,0x7
    80001fe2:	a1a68693          	addi	a3,a3,-1510 # 800089f8 <syscalls+0x1f8>
    80001fe6:	864e                	mv	a2,s3
    80001fe8:	00006517          	auipc	a0,0x6
    80001fec:	46850513          	addi	a0,a0,1128 # 80008450 <digits+0x418>
    80001ff0:	cd4fe0ef          	jal	ra,800004c4 <printf>
if((mem = kalloc()) == 0) {
    80001ff4:	aa9fe0ef          	jal	ra,80000a9c <kalloc>
    80001ff8:	892a                	mv	s2,a0
    80001ffa:	c541                	beqz	a0,80002082 <vmfault+0x5a8>
    memset(mem, 0, PGSIZE);
    80001ffc:	6605                	lui	a2,0x1
    80001ffe:	4581                	li	a1,0
    80002000:	854a                	mv	a0,s2
    80002002:	c3ffe0ef          	jal	ra,80000c40 <memset>
if(mappages(pagetable, page_va, PGSIZE, (uint64)mem, PTE_R | PTE_U) < 0) {
    80002006:	8b4a                	mv	s6,s2
    80002008:	4749                	li	a4,18
    8000200a:	86ca                	mv	a3,s2
    8000200c:	6605                	lui	a2,0x1
    8000200e:	85ce                	mv	a1,s3
    80002010:	8556                	mv	a0,s5
    80002012:	f83fe0ef          	jal	ra,80000f94 <mappages>
    80002016:	08054563          	bltz	a0,800020a0 <vmfault+0x5c6>
    printf("[pid %d] ALLOC va=0x%lx\n", p->pid, page_va);
    8000201a:	864e                	mv	a2,s3
    8000201c:	588c                	lw	a1,48(s1)
    8000201e:	00006517          	auipc	a0,0x6
    80002022:	3ba50513          	addi	a0,a0,954 # 800083d8 <digits+0x3a0>
    80002026:	c9efe0ef          	jal	ra,800004c4 <printf>
    printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, page_va, p->next_fifo_seq);
    8000202a:	1904a683          	lw	a3,400(s1)
    8000202e:	864e                	mv	a2,s3
    80002030:	588c                	lw	a1,48(s1)
    80002032:	00006517          	auipc	a0,0x6
    80002036:	34650513          	addi	a0,a0,838 # 80008378 <digits+0x340>
    8000203a:	c8afe0ef          	jal	ra,800004c4 <printf>
    add_resident_page(p, page_va, p->next_fifo_seq);
    8000203e:	1904a603          	lw	a2,400(s1)
    80002042:	85ce                	mv	a1,s3
    80002044:	8526                	mv	a0,s1
    80002046:	c9aff0ef          	jal	ra,800014e0 <add_resident_page>
    p->next_fifo_seq++;
    8000204a:	1904a783          	lw	a5,400(s1)
    8000204e:	2785                	addiw	a5,a5,1
    80002050:	0007871b          	sext.w	a4,a5
    80002054:	18f4a823          	sw	a5,400(s1)
if(p->next_fifo_seq >= 1000000) {
    80002058:	000f47b7          	lui	a5,0xf4
    8000205c:	23f78793          	addi	a5,a5,575 # f423f <_entry-0x7ff0bdc1>
    80002060:	bce7dbe3          	bge	a5,a4,80001c36 <vmfault+0x15c>
  for(int i = 0; i < p->num_resident; i++) {
    80002064:	7c04a683          	lw	a3,1984(s1)
    80002068:	00d05a63          	blez	a3,8000207c <vmfault+0x5a2>
    8000206c:	1c848713          	addi	a4,s1,456
    80002070:	4781                	li	a5,0
    p->resident_pages[i].seq = i;
    80002072:	c31c                	sw	a5,0(a4)
  for(int i = 0; i < p->num_resident; i++) {
    80002074:	2785                	addiw	a5,a5,1
    80002076:	0761                	addi	a4,a4,24
    80002078:	fed79de3          	bne	a5,a3,80002072 <vmfault+0x598>
  p->next_fifo_seq = p->num_resident;
    8000207c:	18d4a823          	sw	a3,400(s1)
    80002080:	be5d                	j	80001c36 <vmfault+0x15c>
  printf("[pid %d] MEMFULL\n", p->pid);
    80002082:	588c                	lw	a1,48(s1)
    80002084:	00006517          	auipc	a0,0x6
    80002088:	28c50513          	addi	a0,a0,652 # 80008310 <digits+0x2d8>
    8000208c:	c38fe0ef          	jal	ra,800004c4 <printf>
  mem = evict_page_fifo(p, pagetable);
    80002090:	85d6                	mv	a1,s5
    80002092:	8526                	mv	a0,s1
    80002094:	c84ff0ef          	jal	ra,80001518 <evict_page_fifo>
    80002098:	892a                	mv	s2,a0
  if(mem == 0) {
    8000209a:	f12d                	bnez	a0,80001ffc <vmfault+0x522>
    return -1;
    8000209c:	5b7d                	li	s6,-1
    8000209e:	be61                	j	80001c36 <vmfault+0x15c>
      kfree(mem);
    800020a0:	854a                	mv	a0,s2
    800020a2:	91bfe0ef          	jal	ra,800009bc <kfree>
      return -1;
    800020a6:	5b7d                	li	s6,-1
    800020a8:	b679                	j	80001c36 <vmfault+0x15c>
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=invalid\n", 
    800020aa:	588c                	lw	a1,48(s1)
    800020ac:	00006917          	auipc	s2,0x6
    800020b0:	22490913          	addi	s2,s2,548 # 800082d0 <digits+0x298>
    800020b4:	000b1663          	bnez	s6,800020c0 <vmfault+0x5e6>
    800020b8:	00007917          	auipc	s2,0x7
    800020bc:	94090913          	addi	s2,s2,-1728 # 800089f8 <syscalls+0x1f8>
    800020c0:	86ca                	mv	a3,s2
    800020c2:	864e                	mv	a2,s3
    800020c4:	00006517          	auipc	a0,0x6
    800020c8:	3c450513          	addi	a0,a0,964 # 80008488 <digits+0x450>
    800020cc:	bf8fe0ef          	jal	ra,800004c4 <printf>
    printf("[pid %d] KILL invalid-access va=0x%lx access=%s\n", 
    800020d0:	86ca                	mv	a3,s2
    800020d2:	864e                	mv	a2,s3
    800020d4:	588c                	lw	a1,48(s1)
    800020d6:	00006517          	auipc	a0,0x6
    800020da:	3ea50513          	addi	a0,a0,1002 # 800084c0 <digits+0x488>
    800020de:	be6fe0ef          	jal	ra,800004c4 <printf>
    return -1;
    800020e2:	5b7d                	li	s6,-1
    800020e4:	be89                	j	80001c36 <vmfault+0x15c>

00000000800020e6 <copyout>:
  while(len > 0){
    800020e6:	c6f9                	beqz	a3,800021b4 <copyout+0xce>
{
    800020e8:	711d                	addi	sp,sp,-96
    800020ea:	ec86                	sd	ra,88(sp)
    800020ec:	e8a2                	sd	s0,80(sp)
    800020ee:	e4a6                	sd	s1,72(sp)
    800020f0:	e0ca                	sd	s2,64(sp)
    800020f2:	fc4e                	sd	s3,56(sp)
    800020f4:	f852                	sd	s4,48(sp)
    800020f6:	f456                	sd	s5,40(sp)
    800020f8:	f05a                	sd	s6,32(sp)
    800020fa:	ec5e                	sd	s7,24(sp)
    800020fc:	e862                	sd	s8,16(sp)
    800020fe:	e466                	sd	s9,8(sp)
    80002100:	e06a                	sd	s10,0(sp)
    80002102:	1080                	addi	s0,sp,96
    80002104:	8b2a                	mv	s6,a0
    80002106:	8bae                	mv	s7,a1
    80002108:	8c32                	mv	s8,a2
    8000210a:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    8000210c:	74fd                	lui	s1,0xfffff
    8000210e:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80002110:	57fd                	li	a5,-1
    80002112:	83e9                	srli	a5,a5,0x1a
    80002114:	0a97e263          	bltu	a5,s1,800021b8 <copyout+0xd2>
    80002118:	6d05                	lui	s10,0x1
    8000211a:	8cbe                	mv	s9,a5
    8000211c:	a015                	j	80002140 <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000211e:	409b8533          	sub	a0,s7,s1
    80002122:	0009861b          	sext.w	a2,s3
    80002126:	85e2                	mv	a1,s8
    80002128:	954a                	add	a0,a0,s2
    8000212a:	b73fe0ef          	jal	ra,80000c9c <memmove>
    len -= n;
    8000212e:	413a8ab3          	sub	s5,s5,s3
    src += n;
    80002132:	9c4e                	add	s8,s8,s3
  while(len > 0){
    80002134:	060a8163          	beqz	s5,80002196 <copyout+0xb0>
    if(va0 >= MAXVA)
    80002138:	094ce263          	bltu	s9,s4,800021bc <copyout+0xd6>
    va0 = PGROUNDDOWN(dstva);
    8000213c:	84d2                	mv	s1,s4
    dstva = va0 + PGSIZE;
    8000213e:	8bd2                	mv	s7,s4
    pa0 = walkaddr(pagetable, va0);
    80002140:	85a6                	mv	a1,s1
    80002142:	855a                	mv	a0,s6
    80002144:	e13fe0ef          	jal	ra,80000f56 <walkaddr>
    80002148:	892a                	mv	s2,a0
    if(pa0 == 0) {
    8000214a:	e901                	bnez	a0,8000215a <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    8000214c:	4601                	li	a2,0
    8000214e:	85a6                	mv	a1,s1
    80002150:	855a                	mv	a0,s6
    80002152:	989ff0ef          	jal	ra,80001ada <vmfault>
    80002156:	892a                	mv	s2,a0
    80002158:	c525                	beqz	a0,800021c0 <copyout+0xda>
    pte = walk(pagetable, va0, 0);
    8000215a:	4601                	li	a2,0
    8000215c:	85a6                	mv	a1,s1
    8000215e:	855a                	mv	a0,s6
    80002160:	d5dfe0ef          	jal	ra,80000ebc <walk>
    if((*pte & PTE_W) == 0) {
    80002164:	611c                	ld	a5,0(a0)
    80002166:	0047f713          	andi	a4,a5,4
    8000216a:	ef11                	bnez	a4,80002186 <copyout+0xa0>
      if((*pte & PTE_U) != 0) {
    8000216c:	8bc1                	andi	a5,a5,16
    8000216e:	cbb9                	beqz	a5,800021c4 <copyout+0xde>
        if(handle_write_fault(pagetable, va0) < 0) {
    80002170:	85a6                	mv	a1,s1
    80002172:	855a                	mv	a0,s6
    80002174:	8c7ff0ef          	jal	ra,80001a3a <handle_write_fault>
    80002178:	04054863          	bltz	a0,800021c8 <copyout+0xe2>
        pte = walk(pagetable, va0, 0);
    8000217c:	4601                	li	a2,0
    8000217e:	85a6                	mv	a1,s1
    80002180:	855a                	mv	a0,s6
    80002182:	d3bfe0ef          	jal	ra,80000ebc <walk>
    n = PGSIZE - (dstva - va0);
    80002186:	01a48a33          	add	s4,s1,s10
    8000218a:	417a09b3          	sub	s3,s4,s7
    if(n > len)
    8000218e:	f93af8e3          	bgeu	s5,s3,8000211e <copyout+0x38>
    80002192:	89d6                	mv	s3,s5
    80002194:	b769                	j	8000211e <copyout+0x38>
  return 0;
    80002196:	4501                	li	a0,0
}
    80002198:	60e6                	ld	ra,88(sp)
    8000219a:	6446                	ld	s0,80(sp)
    8000219c:	64a6                	ld	s1,72(sp)
    8000219e:	6906                	ld	s2,64(sp)
    800021a0:	79e2                	ld	s3,56(sp)
    800021a2:	7a42                	ld	s4,48(sp)
    800021a4:	7aa2                	ld	s5,40(sp)
    800021a6:	7b02                	ld	s6,32(sp)
    800021a8:	6be2                	ld	s7,24(sp)
    800021aa:	6c42                	ld	s8,16(sp)
    800021ac:	6ca2                	ld	s9,8(sp)
    800021ae:	6d02                	ld	s10,0(sp)
    800021b0:	6125                	addi	sp,sp,96
    800021b2:	8082                	ret
  return 0;
    800021b4:	4501                	li	a0,0
}
    800021b6:	8082                	ret
      return -1;
    800021b8:	557d                	li	a0,-1
    800021ba:	bff9                	j	80002198 <copyout+0xb2>
    800021bc:	557d                	li	a0,-1
    800021be:	bfe9                	j	80002198 <copyout+0xb2>
        return -1;
    800021c0:	557d                	li	a0,-1
    800021c2:	bfd9                	j	80002198 <copyout+0xb2>
        return -1;
    800021c4:	557d                	li	a0,-1
    800021c6:	bfc9                	j	80002198 <copyout+0xb2>
          return -1;  // Can't write to this page
    800021c8:	557d                	li	a0,-1
    800021ca:	b7f9                	j	80002198 <copyout+0xb2>

00000000800021cc <copyin>:
  while(len > 0){
    800021cc:	c6c9                	beqz	a3,80002256 <copyin+0x8a>
{
    800021ce:	715d                	addi	sp,sp,-80
    800021d0:	e486                	sd	ra,72(sp)
    800021d2:	e0a2                	sd	s0,64(sp)
    800021d4:	fc26                	sd	s1,56(sp)
    800021d6:	f84a                	sd	s2,48(sp)
    800021d8:	f44e                	sd	s3,40(sp)
    800021da:	f052                	sd	s4,32(sp)
    800021dc:	ec56                	sd	s5,24(sp)
    800021de:	e85a                	sd	s6,16(sp)
    800021e0:	e45e                	sd	s7,8(sp)
    800021e2:	e062                	sd	s8,0(sp)
    800021e4:	0880                	addi	s0,sp,80
    800021e6:	8baa                	mv	s7,a0
    800021e8:	8aae                	mv	s5,a1
    800021ea:	8932                	mv	s2,a2
    800021ec:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    800021ee:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    800021f0:	6b05                	lui	s6,0x1
    800021f2:	a035                	j	8000221e <copyin+0x52>
    800021f4:	412984b3          	sub	s1,s3,s2
    800021f8:	94da                	add	s1,s1,s6
    if(n > len)
    800021fa:	009a7363          	bgeu	s4,s1,80002200 <copyin+0x34>
    800021fe:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80002200:	413905b3          	sub	a1,s2,s3
    80002204:	0004861b          	sext.w	a2,s1
    80002208:	95aa                	add	a1,a1,a0
    8000220a:	8556                	mv	a0,s5
    8000220c:	a91fe0ef          	jal	ra,80000c9c <memmove>
    len -= n;
    80002210:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80002214:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80002216:	01698933          	add	s2,s3,s6
  while(len > 0){
    8000221a:	020a0163          	beqz	s4,8000223c <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    8000221e:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80002222:	85ce                	mv	a1,s3
    80002224:	855e                	mv	a0,s7
    80002226:	d31fe0ef          	jal	ra,80000f56 <walkaddr>
    if(pa0 == 0) {
    8000222a:	f569                	bnez	a0,800021f4 <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    8000222c:	4601                	li	a2,0
    8000222e:	85ce                	mv	a1,s3
    80002230:	855e                	mv	a0,s7
    80002232:	8a9ff0ef          	jal	ra,80001ada <vmfault>
    80002236:	fd5d                	bnez	a0,800021f4 <copyin+0x28>
        return -1;
    80002238:	557d                	li	a0,-1
    8000223a:	a011                	j	8000223e <copyin+0x72>
  return 0;
    8000223c:	4501                	li	a0,0
}
    8000223e:	60a6                	ld	ra,72(sp)
    80002240:	6406                	ld	s0,64(sp)
    80002242:	74e2                	ld	s1,56(sp)
    80002244:	7942                	ld	s2,48(sp)
    80002246:	79a2                	ld	s3,40(sp)
    80002248:	7a02                	ld	s4,32(sp)
    8000224a:	6ae2                	ld	s5,24(sp)
    8000224c:	6b42                	ld	s6,16(sp)
    8000224e:	6ba2                	ld	s7,8(sp)
    80002250:	6c02                	ld	s8,0(sp)
    80002252:	6161                	addi	sp,sp,80
    80002254:	8082                	ret
  return 0;
    80002256:	4501                	li	a0,0
}
    80002258:	8082                	ret

000000008000225a <proc_mapstacks>:
// Helper function to format swap filename
// Converts number to string with leading zeros

void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000225a:	715d                	addi	sp,sp,-80
    8000225c:	e486                	sd	ra,72(sp)
    8000225e:	e0a2                	sd	s0,64(sp)
    80002260:	fc26                	sd	s1,56(sp)
    80002262:	f84a                	sd	s2,48(sp)
    80002264:	f44e                	sd	s3,40(sp)
    80002266:	f052                	sd	s4,32(sp)
    80002268:	ec56                	sd	s5,24(sp)
    8000226a:	e85a                	sd	s6,16(sp)
    8000226c:	e45e                	sd	s7,8(sp)
    8000226e:	0880                	addi	s0,sp,80
    80002270:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80002272:	0000f497          	auipc	s1,0xf
    80002276:	fd648493          	addi	s1,s1,-42 # 80011248 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000227a:	8ba6                	mv	s7,s1
    8000227c:	00006b17          	auipc	s6,0x6
    80002280:	d84b0b13          	addi	s6,s6,-636 # 80008000 <etext>
    80002284:	04000937          	lui	s2,0x4000
    80002288:	197d                	addi	s2,s2,-1
    8000228a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000228c:	6989                	lui	s3,0x2
    8000228e:	bf098993          	addi	s3,s3,-1040 # 1bf0 <_entry-0x7fffe410>
    80002292:	0007fa97          	auipc	s5,0x7f
    80002296:	bb6a8a93          	addi	s5,s5,-1098 # 80080e48 <tickslock>
    char *pa = kalloc();
    8000229a:	803fe0ef          	jal	ra,80000a9c <kalloc>
    8000229e:	862a                	mv	a2,a0
    if(pa == 0)
    800022a0:	c121                	beqz	a0,800022e0 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    800022a2:	417485b3          	sub	a1,s1,s7
    800022a6:	8591                	srai	a1,a1,0x4
    800022a8:	000b3783          	ld	a5,0(s6)
    800022ac:	02f585b3          	mul	a1,a1,a5
    800022b0:	2585                	addiw	a1,a1,1
    800022b2:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800022b6:	4719                	li	a4,6
    800022b8:	6685                	lui	a3,0x1
    800022ba:	40b905b3          	sub	a1,s2,a1
    800022be:	8552                	mv	a0,s4
    800022c0:	d85fe0ef          	jal	ra,80001044 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800022c4:	94ce                	add	s1,s1,s3
    800022c6:	fd549ae3          	bne	s1,s5,8000229a <proc_mapstacks+0x40>
  }
}
    800022ca:	60a6                	ld	ra,72(sp)
    800022cc:	6406                	ld	s0,64(sp)
    800022ce:	74e2                	ld	s1,56(sp)
    800022d0:	7942                	ld	s2,48(sp)
    800022d2:	79a2                	ld	s3,40(sp)
    800022d4:	7a02                	ld	s4,32(sp)
    800022d6:	6ae2                	ld	s5,24(sp)
    800022d8:	6b42                	ld	s6,16(sp)
    800022da:	6ba2                	ld	s7,8(sp)
    800022dc:	6161                	addi	sp,sp,80
    800022de:	8082                	ret
      panic("kalloc");
    800022e0:	00006517          	auipc	a0,0x6
    800022e4:	21850513          	addi	a0,a0,536 # 800084f8 <digits+0x4c0>
    800022e8:	ca2fe0ef          	jal	ra,8000078a <panic>

00000000800022ec <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800022ec:	715d                	addi	sp,sp,-80
    800022ee:	e486                	sd	ra,72(sp)
    800022f0:	e0a2                	sd	s0,64(sp)
    800022f2:	fc26                	sd	s1,56(sp)
    800022f4:	f84a                	sd	s2,48(sp)
    800022f6:	f44e                	sd	s3,40(sp)
    800022f8:	f052                	sd	s4,32(sp)
    800022fa:	ec56                	sd	s5,24(sp)
    800022fc:	e85a                	sd	s6,16(sp)
    800022fe:	e45e                	sd	s7,8(sp)
    80002300:	0880                	addi	s0,sp,80
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80002302:	00006597          	auipc	a1,0x6
    80002306:	1fe58593          	addi	a1,a1,510 # 80008500 <digits+0x4c8>
    8000230a:	0000f517          	auipc	a0,0xf
    8000230e:	b0e50513          	addi	a0,a0,-1266 # 80010e18 <pid_lock>
    80002312:	fdafe0ef          	jal	ra,80000aec <initlock>
  initlock(&wait_lock, "wait_lock");
    80002316:	00006597          	auipc	a1,0x6
    8000231a:	1f258593          	addi	a1,a1,498 # 80008508 <digits+0x4d0>
    8000231e:	0000f517          	auipc	a0,0xf
    80002322:	b1250513          	addi	a0,a0,-1262 # 80010e30 <wait_lock>
    80002326:	fc6fe0ef          	jal	ra,80000aec <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000232a:	0000f497          	auipc	s1,0xf
    8000232e:	f1e48493          	addi	s1,s1,-226 # 80011248 <proc>
      initlock(&p->lock, "proc");
    80002332:	00006b97          	auipc	s7,0x6
    80002336:	1e6b8b93          	addi	s7,s7,486 # 80008518 <digits+0x4e0>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000233a:	8b26                	mv	s6,s1
    8000233c:	00006a97          	auipc	s5,0x6
    80002340:	cc4a8a93          	addi	s5,s5,-828 # 80008000 <etext>
    80002344:	04000937          	lui	s2,0x4000
    80002348:	197d                	addi	s2,s2,-1
    8000234a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000234c:	6989                	lui	s3,0x2
    8000234e:	bf098993          	addi	s3,s3,-1040 # 1bf0 <_entry-0x7fffe410>
    80002352:	0007fa17          	auipc	s4,0x7f
    80002356:	af6a0a13          	addi	s4,s4,-1290 # 80080e48 <tickslock>
      initlock(&p->lock, "proc");
    8000235a:	85de                	mv	a1,s7
    8000235c:	8526                	mv	a0,s1
    8000235e:	f8efe0ef          	jal	ra,80000aec <initlock>
      p->state = UNUSED;
    80002362:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80002366:	416487b3          	sub	a5,s1,s6
    8000236a:	8791                	srai	a5,a5,0x4
    8000236c:	000ab703          	ld	a4,0(s5)
    80002370:	02e787b3          	mul	a5,a5,a4
    80002374:	2785                	addiw	a5,a5,1
    80002376:	00d7979b          	slliw	a5,a5,0xd
    8000237a:	40f907b3          	sub	a5,s2,a5
    8000237e:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80002380:	94ce                	add	s1,s1,s3
    80002382:	fd449ce3          	bne	s1,s4,8000235a <procinit+0x6e>
  }
}
    80002386:	60a6                	ld	ra,72(sp)
    80002388:	6406                	ld	s0,64(sp)
    8000238a:	74e2                	ld	s1,56(sp)
    8000238c:	7942                	ld	s2,48(sp)
    8000238e:	79a2                	ld	s3,40(sp)
    80002390:	7a02                	ld	s4,32(sp)
    80002392:	6ae2                	ld	s5,24(sp)
    80002394:	6b42                	ld	s6,16(sp)
    80002396:	6ba2                	ld	s7,8(sp)
    80002398:	6161                	addi	sp,sp,80
    8000239a:	8082                	ret

000000008000239c <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000239c:	1141                	addi	sp,sp,-16
    8000239e:	e422                	sd	s0,8(sp)
    800023a0:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800023a2:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800023a4:	2501                	sext.w	a0,a0
    800023a6:	6422                	ld	s0,8(sp)
    800023a8:	0141                	addi	sp,sp,16
    800023aa:	8082                	ret

00000000800023ac <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800023ac:	1141                	addi	sp,sp,-16
    800023ae:	e422                	sd	s0,8(sp)
    800023b0:	0800                	addi	s0,sp,16
    800023b2:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800023b4:	2781                	sext.w	a5,a5
    800023b6:	079e                	slli	a5,a5,0x7
  return c;
}
    800023b8:	0000f517          	auipc	a0,0xf
    800023bc:	a9050513          	addi	a0,a0,-1392 # 80010e48 <cpus>
    800023c0:	953e                	add	a0,a0,a5
    800023c2:	6422                	ld	s0,8(sp)
    800023c4:	0141                	addi	sp,sp,16
    800023c6:	8082                	ret

00000000800023c8 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800023c8:	1101                	addi	sp,sp,-32
    800023ca:	ec06                	sd	ra,24(sp)
    800023cc:	e822                	sd	s0,16(sp)
    800023ce:	e426                	sd	s1,8(sp)
    800023d0:	1000                	addi	s0,sp,32
  push_off();
    800023d2:	f5afe0ef          	jal	ra,80000b2c <push_off>
    800023d6:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800023d8:	2781                	sext.w	a5,a5
    800023da:	079e                	slli	a5,a5,0x7
    800023dc:	0000f717          	auipc	a4,0xf
    800023e0:	a3c70713          	addi	a4,a4,-1476 # 80010e18 <pid_lock>
    800023e4:	97ba                	add	a5,a5,a4
    800023e6:	7b84                	ld	s1,48(a5)
  pop_off();
    800023e8:	fc8fe0ef          	jal	ra,80000bb0 <pop_off>
  return p;
}
    800023ec:	8526                	mv	a0,s1
    800023ee:	60e2                	ld	ra,24(sp)
    800023f0:	6442                	ld	s0,16(sp)
    800023f2:	64a2                	ld	s1,8(sp)
    800023f4:	6105                	addi	sp,sp,32
    800023f6:	8082                	ret

00000000800023f8 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800023f8:	7179                	addi	sp,sp,-48
    800023fa:	f406                	sd	ra,40(sp)
    800023fc:	f022                	sd	s0,32(sp)
    800023fe:	ec26                	sd	s1,24(sp)
    80002400:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80002402:	fc7ff0ef          	jal	ra,800023c8 <myproc>
    80002406:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80002408:	ffcfe0ef          	jal	ra,80000c04 <release>

  if (first) {
    8000240c:	00007797          	auipc	a5,0x7
    80002410:	8d47a783          	lw	a5,-1836(a5) # 80008ce0 <first.1>
    80002414:	cf8d                	beqz	a5,8000244e <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80002416:	4505                	li	a0,1
    80002418:	62f010ef          	jal	ra,80004246 <fsinit>

    first = 0;
    8000241c:	00007797          	auipc	a5,0x7
    80002420:	8c07a223          	sw	zero,-1852(a5) # 80008ce0 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80002424:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80002428:	00006517          	auipc	a0,0x6
    8000242c:	0f850513          	addi	a0,a0,248 # 80008520 <digits+0x4e8>
    80002430:	fca43823          	sd	a0,-48(s0)
    80002434:	fc043c23          	sd	zero,-40(s0)
    80002438:	fd040593          	addi	a1,s0,-48
    8000243c:	6a9020ef          	jal	ra,800052e4 <kexec>
    80002440:	6cbc                	ld	a5,88(s1)
    80002442:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80002444:	6cbc                	ld	a5,88(s1)
    80002446:	7bb8                	ld	a4,112(a5)
    80002448:	57fd                	li	a5,-1
    8000244a:	02f70d63          	beq	a4,a5,80002484 <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    8000244e:	3ad000ef          	jal	ra,80002ffa <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002452:	68a8                	ld	a0,80(s1)
    80002454:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002456:	04000737          	lui	a4,0x4000
    8000245a:	00005797          	auipc	a5,0x5
    8000245e:	c4278793          	addi	a5,a5,-958 # 8000709c <userret>
    80002462:	00005697          	auipc	a3,0x5
    80002466:	b9e68693          	addi	a3,a3,-1122 # 80007000 <_trampoline>
    8000246a:	8f95                	sub	a5,a5,a3
    8000246c:	177d                	addi	a4,a4,-1
    8000246e:	0732                	slli	a4,a4,0xc
    80002470:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002472:	577d                	li	a4,-1
    80002474:	177e                	slli	a4,a4,0x3f
    80002476:	8d59                	or	a0,a0,a4
    80002478:	9782                	jalr	a5
}
    8000247a:	70a2                	ld	ra,40(sp)
    8000247c:	7402                	ld	s0,32(sp)
    8000247e:	64e2                	ld	s1,24(sp)
    80002480:	6145                	addi	sp,sp,48
    80002482:	8082                	ret
      panic("exec");
    80002484:	00006517          	auipc	a0,0x6
    80002488:	0a450513          	addi	a0,a0,164 # 80008528 <digits+0x4f0>
    8000248c:	afefe0ef          	jal	ra,8000078a <panic>

0000000080002490 <allocpid>:
{
    80002490:	1101                	addi	sp,sp,-32
    80002492:	ec06                	sd	ra,24(sp)
    80002494:	e822                	sd	s0,16(sp)
    80002496:	e426                	sd	s1,8(sp)
    80002498:	e04a                	sd	s2,0(sp)
    8000249a:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    8000249c:	0000f917          	auipc	s2,0xf
    800024a0:	97c90913          	addi	s2,s2,-1668 # 80010e18 <pid_lock>
    800024a4:	854a                	mv	a0,s2
    800024a6:	ec6fe0ef          	jal	ra,80000b6c <acquire>
  pid = nextpid;
    800024aa:	00007797          	auipc	a5,0x7
    800024ae:	83a78793          	addi	a5,a5,-1990 # 80008ce4 <nextpid>
    800024b2:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800024b4:	0014871b          	addiw	a4,s1,1
    800024b8:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800024ba:	854a                	mv	a0,s2
    800024bc:	f48fe0ef          	jal	ra,80000c04 <release>
}
    800024c0:	8526                	mv	a0,s1
    800024c2:	60e2                	ld	ra,24(sp)
    800024c4:	6442                	ld	s0,16(sp)
    800024c6:	64a2                	ld	s1,8(sp)
    800024c8:	6902                	ld	s2,0(sp)
    800024ca:	6105                	addi	sp,sp,32
    800024cc:	8082                	ret

00000000800024ce <proc_pagetable>:
{
    800024ce:	1101                	addi	sp,sp,-32
    800024d0:	ec06                	sd	ra,24(sp)
    800024d2:	e822                	sd	s0,16(sp)
    800024d4:	e426                	sd	s1,8(sp)
    800024d6:	e04a                	sd	s2,0(sp)
    800024d8:	1000                	addi	s0,sp,32
    800024da:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800024dc:	c5ffe0ef          	jal	ra,8000113a <uvmcreate>
    800024e0:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800024e2:	cd05                	beqz	a0,8000251a <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    800024e4:	4729                	li	a4,10
    800024e6:	00005697          	auipc	a3,0x5
    800024ea:	b1a68693          	addi	a3,a3,-1254 # 80007000 <_trampoline>
    800024ee:	6605                	lui	a2,0x1
    800024f0:	040005b7          	lui	a1,0x4000
    800024f4:	15fd                	addi	a1,a1,-1
    800024f6:	05b2                	slli	a1,a1,0xc
    800024f8:	a9dfe0ef          	jal	ra,80000f94 <mappages>
    800024fc:	02054663          	bltz	a0,80002528 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80002500:	4719                	li	a4,6
    80002502:	05893683          	ld	a3,88(s2)
    80002506:	6605                	lui	a2,0x1
    80002508:	020005b7          	lui	a1,0x2000
    8000250c:	15fd                	addi	a1,a1,-1
    8000250e:	05b6                	slli	a1,a1,0xd
    80002510:	8526                	mv	a0,s1
    80002512:	a83fe0ef          	jal	ra,80000f94 <mappages>
    80002516:	00054f63          	bltz	a0,80002534 <proc_pagetable+0x66>
}
    8000251a:	8526                	mv	a0,s1
    8000251c:	60e2                	ld	ra,24(sp)
    8000251e:	6442                	ld	s0,16(sp)
    80002520:	64a2                	ld	s1,8(sp)
    80002522:	6902                	ld	s2,0(sp)
    80002524:	6105                	addi	sp,sp,32
    80002526:	8082                	ret
    uvmfree(pagetable, 0);
    80002528:	4581                	li	a1,0
    8000252a:	8526                	mv	a0,s1
    8000252c:	dedfe0ef          	jal	ra,80001318 <uvmfree>
    return 0;
    80002530:	4481                	li	s1,0
    80002532:	b7e5                	j	8000251a <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80002534:	4681                	li	a3,0
    80002536:	4605                	li	a2,1
    80002538:	040005b7          	lui	a1,0x4000
    8000253c:	15fd                	addi	a1,a1,-1
    8000253e:	05b2                	slli	a1,a1,0xc
    80002540:	8526                	mv	a0,s1
    80002542:	c1ffe0ef          	jal	ra,80001160 <uvmunmap>
    uvmfree(pagetable, 0);
    80002546:	4581                	li	a1,0
    80002548:	8526                	mv	a0,s1
    8000254a:	dcffe0ef          	jal	ra,80001318 <uvmfree>
    return 0;
    8000254e:	4481                	li	s1,0
    80002550:	b7e9                	j	8000251a <proc_pagetable+0x4c>

0000000080002552 <proc_freepagetable>:
{
    80002552:	1101                	addi	sp,sp,-32
    80002554:	ec06                	sd	ra,24(sp)
    80002556:	e822                	sd	s0,16(sp)
    80002558:	e426                	sd	s1,8(sp)
    8000255a:	e04a                	sd	s2,0(sp)
    8000255c:	1000                	addi	s0,sp,32
    8000255e:	84aa                	mv	s1,a0
    80002560:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80002562:	4681                	li	a3,0
    80002564:	4605                	li	a2,1
    80002566:	040005b7          	lui	a1,0x4000
    8000256a:	15fd                	addi	a1,a1,-1
    8000256c:	05b2                	slli	a1,a1,0xc
    8000256e:	bf3fe0ef          	jal	ra,80001160 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80002572:	4681                	li	a3,0
    80002574:	4605                	li	a2,1
    80002576:	020005b7          	lui	a1,0x2000
    8000257a:	15fd                	addi	a1,a1,-1
    8000257c:	05b6                	slli	a1,a1,0xd
    8000257e:	8526                	mv	a0,s1
    80002580:	be1fe0ef          	jal	ra,80001160 <uvmunmap>
  uvmfree(pagetable, sz);
    80002584:	85ca                	mv	a1,s2
    80002586:	8526                	mv	a0,s1
    80002588:	d91fe0ef          	jal	ra,80001318 <uvmfree>
}
    8000258c:	60e2                	ld	ra,24(sp)
    8000258e:	6442                	ld	s0,16(sp)
    80002590:	64a2                	ld	s1,8(sp)
    80002592:	6902                	ld	s2,0(sp)
    80002594:	6105                	addi	sp,sp,32
    80002596:	8082                	ret

0000000080002598 <freeproc>:
{
    80002598:	1101                	addi	sp,sp,-32
    8000259a:	ec06                	sd	ra,24(sp)
    8000259c:	e822                	sd	s0,16(sp)
    8000259e:	e426                	sd	s1,8(sp)
    800025a0:	1000                	addi	s0,sp,32
    800025a2:	84aa                	mv	s1,a0
  if(p->trapframe)
    800025a4:	6d28                	ld	a0,88(a0)
    800025a6:	c119                	beqz	a0,800025ac <freeproc+0x14>
    kfree((void*)p->trapframe);
    800025a8:	c14fe0ef          	jal	ra,800009bc <kfree>
  p->trapframe = 0;
    800025ac:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    800025b0:	68a8                	ld	a0,80(s1)
    800025b2:	c501                	beqz	a0,800025ba <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    800025b4:	64ac                	ld	a1,72(s1)
    800025b6:	f9dff0ef          	jal	ra,80002552 <proc_freepagetable>
  p->pagetable = 0;
    800025ba:	0404b823          	sd	zero,80(s1)
  if(p->exec_inode) {
    800025be:	1984b503          	ld	a0,408(s1)
    800025c2:	c509                	beqz	a0,800025cc <freeproc+0x34>
    iput(p->exec_inode);
    800025c4:	311010ef          	jal	ra,800040d4 <iput>
    p->exec_inode = 0;
    800025c8:	1804bc23          	sd	zero,408(s1)
  p->sz = 0;
    800025cc:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    800025d0:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    800025d4:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    800025d8:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    800025dc:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    800025e0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    800025e4:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    800025e8:	0004ac23          	sw	zero,24(s1)
}
    800025ec:	60e2                	ld	ra,24(sp)
    800025ee:	6442                	ld	s0,16(sp)
    800025f0:	64a2                	ld	s1,8(sp)
    800025f2:	6105                	addi	sp,sp,32
    800025f4:	8082                	ret

00000000800025f6 <allocproc>:
{
    800025f6:	7179                	addi	sp,sp,-48
    800025f8:	f406                	sd	ra,40(sp)
    800025fa:	f022                	sd	s0,32(sp)
    800025fc:	ec26                	sd	s1,24(sp)
    800025fe:	e84a                	sd	s2,16(sp)
    80002600:	e44e                	sd	s3,8(sp)
    80002602:	e052                	sd	s4,0(sp)
    80002604:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80002606:	0000f497          	auipc	s1,0xf
    8000260a:	c4248493          	addi	s1,s1,-958 # 80011248 <proc>
    8000260e:	6989                	lui	s3,0x2
    80002610:	bf098993          	addi	s3,s3,-1040 # 1bf0 <_entry-0x7fffe410>
    80002614:	0007fa17          	auipc	s4,0x7f
    80002618:	834a0a13          	addi	s4,s4,-1996 # 80080e48 <tickslock>
    acquire(&p->lock);
    8000261c:	8926                	mv	s2,s1
    8000261e:	8526                	mv	a0,s1
    80002620:	d4cfe0ef          	jal	ra,80000b6c <acquire>
    if(p->state == UNUSED) {
    80002624:	4c9c                	lw	a5,24(s1)
    80002626:	cb89                	beqz	a5,80002638 <allocproc+0x42>
      release(&p->lock);
    80002628:	8526                	mv	a0,s1
    8000262a:	ddafe0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000262e:	94ce                	add	s1,s1,s3
    80002630:	ff4496e3          	bne	s1,s4,8000261c <allocproc+0x26>
  return 0;
    80002634:	4481                	li	s1,0
    80002636:	a0f1                	j	80002702 <allocproc+0x10c>
  p->pid = allocpid();
    80002638:	e59ff0ef          	jal	ra,80002490 <allocpid>
    8000263c:	d888                	sw	a0,48(s1)
  p->state = USED;
    8000263e:	4785                	li	a5,1
    80002640:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80002642:	c5afe0ef          	jal	ra,80000a9c <kalloc>
    80002646:	89aa                	mv	s3,a0
    80002648:	eca8                	sd	a0,88(s1)
    8000264a:	c569                	beqz	a0,80002714 <allocproc+0x11e>
  p->pagetable = proc_pagetable(p);
    8000264c:	8526                	mv	a0,s1
    8000264e:	e81ff0ef          	jal	ra,800024ce <proc_pagetable>
    80002652:	89aa                	mv	s3,a0
    80002654:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80002656:	c579                	beqz	a0,80002724 <allocproc+0x12e>
  memset(&p->context, 0, sizeof(p->context));
    80002658:	07000613          	li	a2,112
    8000265c:	4581                	li	a1,0
    8000265e:	06048513          	addi	a0,s1,96
    80002662:	ddefe0ef          	jal	ra,80000c40 <memset>
  p->context.ra = (uint64)forkret;
    80002666:	00000797          	auipc	a5,0x0
    8000266a:	d9278793          	addi	a5,a5,-622 # 800023f8 <forkret>
    8000266e:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80002670:	60bc                	ld	a5,64(s1)
    80002672:	6705                	lui	a4,0x1
    80002674:	97ba                	add	a5,a5,a4
    80002676:	f4bc                	sd	a5,104(s1)
  p->text_start = 0;
    80002678:	1604b423          	sd	zero,360(s1)
  p->text_end = 0;
    8000267c:	1604b823          	sd	zero,368(s1)
  p->data_start = 0;
    80002680:	1604bc23          	sd	zero,376(s1)
  p->data_end = 0;
    80002684:	1804b023          	sd	zero,384(s1)
  p->heap_start = 0;
    80002688:	1804b423          	sd	zero,392(s1)
  p->next_fifo_seq = 0;
    8000268c:	1804a823          	sw	zero,400(s1)
  p->exec_inode = 0;
    80002690:	1804bc23          	sd	zero,408(s1)
  p->num_resident = 0;
    80002694:	7c04a023          	sw	zero,1984(s1)
for(int i = 0; i < MAX_RESIDENT_PAGES; i++) {
    80002698:	1c048793          	addi	a5,s1,448
    8000269c:	7c048693          	addi	a3,s1,1984
    p->resident_pages[i].seq = -1;
    800026a0:	577d                	li	a4,-1
    p->resident_pages[i].va = 0;
    800026a2:	0007b023          	sd	zero,0(a5)
    p->resident_pages[i].seq = -1;
    800026a6:	c798                	sw	a4,8(a5)
    p->resident_pages[i].is_dirty = 0;
    800026a8:	0007a623          	sw	zero,12(a5)
    p->resident_pages[i].swap_slot = -1;
    800026ac:	cb98                	sw	a4,16(a5)
    p->resident_pages[i].last_used_seq = -1;  // ADD THIS LINE
    800026ae:	cbd8                	sw	a4,20(a5)
for(int i = 0; i < MAX_RESIDENT_PAGES; i++) {
    800026b0:	07e1                	addi	a5,a5,24
    800026b2:	fed798e3          	bne	a5,a3,800026a2 <allocproc+0xac>
    800026b6:	7c848793          	addi	a5,s1,1992
    800026ba:	6705                	lui	a4,0x1
    800026bc:	bc870713          	addi	a4,a4,-1080 # bc8 <_entry-0x7ffff438>
    800026c0:	974a                	add	a4,a4,s2
    p->swapped_pages[i].swap_slot = -1;
    800026c2:	56fd                	li	a3,-1
    p->swapped_pages[i].va = 0;
    800026c4:	0007b023          	sd	zero,0(a5)
    p->swapped_pages[i].swap_slot = -1;
    800026c8:	c794                	sw	a3,8(a5)
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) {
    800026ca:	07c1                	addi	a5,a5,16
    800026cc:	fee79ce3          	bne	a5,a4,800026c4 <allocproc+0xce>
  p->num_swapped = 0;
    800026d0:	6785                	lui	a5,0x1
    800026d2:	00f48733          	add	a4,s1,a5
    800026d6:	bc072423          	sw	zero,-1080(a4)
  p->swapfile = 0;                    // No swap file yet
    800026da:	bc073823          	sd	zero,-1072(a4)
  p->swap_filename[0] = '\0';         // Empty filename
    800026de:	bc070c23          	sb	zero,-1064(a4)
  p->num_swap_slots_used = 0;         // No slots used yet
    800026e2:	6709                	lui	a4,0x2
    800026e4:	00e486b3          	add	a3,s1,a4
    800026e8:	be06a623          	sw	zero,-1044(a3)
  for(int i = 0; i < 1024; i++) {
    800026ec:	bec78793          	addi	a5,a5,-1044 # bec <_entry-0x7ffff414>
    800026f0:	97a6                	add	a5,a5,s1
    800026f2:	bec70713          	addi	a4,a4,-1044 # 1bec <_entry-0x7fffe414>
    800026f6:	974a                	add	a4,a4,s2
    p->swap_slots[i] = 0;             // Mark all slots as free
    800026f8:	0007a023          	sw	zero,0(a5)
  for(int i = 0; i < 1024; i++) {
    800026fc:	0791                	addi	a5,a5,4
    800026fe:	fee79de3          	bne	a5,a4,800026f8 <allocproc+0x102>
}
    80002702:	8526                	mv	a0,s1
    80002704:	70a2                	ld	ra,40(sp)
    80002706:	7402                	ld	s0,32(sp)
    80002708:	64e2                	ld	s1,24(sp)
    8000270a:	6942                	ld	s2,16(sp)
    8000270c:	69a2                	ld	s3,8(sp)
    8000270e:	6a02                	ld	s4,0(sp)
    80002710:	6145                	addi	sp,sp,48
    80002712:	8082                	ret
    freeproc(p);
    80002714:	8526                	mv	a0,s1
    80002716:	e83ff0ef          	jal	ra,80002598 <freeproc>
    release(&p->lock);
    8000271a:	8526                	mv	a0,s1
    8000271c:	ce8fe0ef          	jal	ra,80000c04 <release>
    return 0;
    80002720:	84ce                	mv	s1,s3
    80002722:	b7c5                	j	80002702 <allocproc+0x10c>
    freeproc(p);
    80002724:	8526                	mv	a0,s1
    80002726:	e73ff0ef          	jal	ra,80002598 <freeproc>
    release(&p->lock);
    8000272a:	8526                	mv	a0,s1
    8000272c:	cd8fe0ef          	jal	ra,80000c04 <release>
    return 0;
    80002730:	84ce                	mv	s1,s3
    80002732:	bfc1                	j	80002702 <allocproc+0x10c>

0000000080002734 <userinit>:
{
    80002734:	1101                	addi	sp,sp,-32
    80002736:	ec06                	sd	ra,24(sp)
    80002738:	e822                	sd	s0,16(sp)
    8000273a:	e426                	sd	s1,8(sp)
    8000273c:	1000                	addi	s0,sp,32
  p = allocproc();
    8000273e:	eb9ff0ef          	jal	ra,800025f6 <allocproc>
    80002742:	84aa                	mv	s1,a0
  initproc = p;
    80002744:	00006797          	auipc	a5,0x6
    80002748:	5ca7b623          	sd	a0,1484(a5) # 80008d10 <initproc>
  p->cwd = namei("/");
    8000274c:	00006517          	auipc	a0,0x6
    80002750:	de450513          	addi	a0,a0,-540 # 80008530 <digits+0x4f8>
    80002754:	7f1010ef          	jal	ra,80004744 <namei>
    80002758:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    8000275c:	478d                	li	a5,3
    8000275e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80002760:	8526                	mv	a0,s1
    80002762:	ca2fe0ef          	jal	ra,80000c04 <release>
}
    80002766:	60e2                	ld	ra,24(sp)
    80002768:	6442                	ld	s0,16(sp)
    8000276a:	64a2                	ld	s1,8(sp)
    8000276c:	6105                	addi	sp,sp,32
    8000276e:	8082                	ret

0000000080002770 <growproc>:
{
    80002770:	1101                	addi	sp,sp,-32
    80002772:	ec06                	sd	ra,24(sp)
    80002774:	e822                	sd	s0,16(sp)
    80002776:	e426                	sd	s1,8(sp)
    80002778:	e04a                	sd	s2,0(sp)
    8000277a:	1000                	addi	s0,sp,32
    8000277c:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000277e:	c4bff0ef          	jal	ra,800023c8 <myproc>
    80002782:	84aa                	mv	s1,a0
  sz = p->sz;
    80002784:	652c                	ld	a1,72(a0)
  if(n > 0){
    80002786:	01204c63          	bgtz	s2,8000279e <growproc+0x2e>
  } else if(n < 0){
    8000278a:	02094463          	bltz	s2,800027b2 <growproc+0x42>
  p->sz = sz;
    8000278e:	e4ac                	sd	a1,72(s1)
  return 0;
    80002790:	4501                	li	a0,0
}
    80002792:	60e2                	ld	ra,24(sp)
    80002794:	6442                	ld	s0,16(sp)
    80002796:	64a2                	ld	s1,8(sp)
    80002798:	6902                	ld	s2,0(sp)
    8000279a:	6105                	addi	sp,sp,32
    8000279c:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    8000279e:	4691                	li	a3,4
    800027a0:	00b90633          	add	a2,s2,a1
    800027a4:	6928                	ld	a0,80(a0)
    800027a6:	a7bfe0ef          	jal	ra,80001220 <uvmalloc>
    800027aa:	85aa                	mv	a1,a0
    800027ac:	f16d                	bnez	a0,8000278e <growproc+0x1e>
      return -1;
    800027ae:	557d                	li	a0,-1
    800027b0:	b7cd                	j	80002792 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800027b2:	00b90633          	add	a2,s2,a1
    800027b6:	6928                	ld	a0,80(a0)
    800027b8:	a25fe0ef          	jal	ra,800011dc <uvmdealloc>
    800027bc:	85aa                	mv	a1,a0
    800027be:	bfc1                	j	8000278e <growproc+0x1e>

00000000800027c0 <kfork>:
{
    800027c0:	7139                	addi	sp,sp,-64
    800027c2:	fc06                	sd	ra,56(sp)
    800027c4:	f822                	sd	s0,48(sp)
    800027c6:	f426                	sd	s1,40(sp)
    800027c8:	f04a                	sd	s2,32(sp)
    800027ca:	ec4e                	sd	s3,24(sp)
    800027cc:	e852                	sd	s4,16(sp)
    800027ce:	e456                	sd	s5,8(sp)
    800027d0:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    800027d2:	bf7ff0ef          	jal	ra,800023c8 <myproc>
    800027d6:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    800027d8:	e1fff0ef          	jal	ra,800025f6 <allocproc>
    800027dc:	0e050663          	beqz	a0,800028c8 <kfork+0x108>
    800027e0:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800027e2:	048ab603          	ld	a2,72(s5)
    800027e6:	692c                	ld	a1,80(a0)
    800027e8:	050ab503          	ld	a0,80(s5)
    800027ec:	b5dfe0ef          	jal	ra,80001348 <uvmcopy>
    800027f0:	04054863          	bltz	a0,80002840 <kfork+0x80>
  np->sz = p->sz;
    800027f4:	048ab783          	ld	a5,72(s5)
    800027f8:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    800027fc:	058ab683          	ld	a3,88(s5)
    80002800:	87b6                	mv	a5,a3
    80002802:	058a3703          	ld	a4,88(s4)
    80002806:	12068693          	addi	a3,a3,288
    8000280a:	0007b803          	ld	a6,0(a5)
    8000280e:	6788                	ld	a0,8(a5)
    80002810:	6b8c                	ld	a1,16(a5)
    80002812:	6f90                	ld	a2,24(a5)
    80002814:	01073023          	sd	a6,0(a4)
    80002818:	e708                	sd	a0,8(a4)
    8000281a:	eb0c                	sd	a1,16(a4)
    8000281c:	ef10                	sd	a2,24(a4)
    8000281e:	02078793          	addi	a5,a5,32
    80002822:	02070713          	addi	a4,a4,32
    80002826:	fed792e3          	bne	a5,a3,8000280a <kfork+0x4a>
  np->trapframe->a0 = 0;
    8000282a:	058a3783          	ld	a5,88(s4)
    8000282e:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80002832:	0d0a8493          	addi	s1,s5,208
    80002836:	0d0a0913          	addi	s2,s4,208
    8000283a:	150a8993          	addi	s3,s5,336
    8000283e:	a829                	j	80002858 <kfork+0x98>
    freeproc(np);
    80002840:	8552                	mv	a0,s4
    80002842:	d57ff0ef          	jal	ra,80002598 <freeproc>
    release(&np->lock);
    80002846:	8552                	mv	a0,s4
    80002848:	bbcfe0ef          	jal	ra,80000c04 <release>
    return -1;
    8000284c:	597d                	li	s2,-1
    8000284e:	a09d                	j	800028b4 <kfork+0xf4>
  for(i = 0; i < NOFILE; i++)
    80002850:	04a1                	addi	s1,s1,8
    80002852:	0921                	addi	s2,s2,8
    80002854:	01348963          	beq	s1,s3,80002866 <kfork+0xa6>
    if(p->ofile[i])
    80002858:	6088                	ld	a0,0(s1)
    8000285a:	d97d                	beqz	a0,80002850 <kfork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    8000285c:	4a0020ef          	jal	ra,80004cfc <filedup>
    80002860:	00a93023          	sd	a0,0(s2)
    80002864:	b7f5                	j	80002850 <kfork+0x90>
  np->cwd = idup(p->cwd);
    80002866:	150ab503          	ld	a0,336(s5)
    8000286a:	6b6010ef          	jal	ra,80003f20 <idup>
    8000286e:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002872:	4641                	li	a2,16
    80002874:	158a8593          	addi	a1,s5,344
    80002878:	158a0513          	addi	a0,s4,344
    8000287c:	d0afe0ef          	jal	ra,80000d86 <safestrcpy>
  pid = np->pid;
    80002880:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80002884:	8552                	mv	a0,s4
    80002886:	b7efe0ef          	jal	ra,80000c04 <release>
  acquire(&wait_lock);
    8000288a:	0000e497          	auipc	s1,0xe
    8000288e:	5a648493          	addi	s1,s1,1446 # 80010e30 <wait_lock>
    80002892:	8526                	mv	a0,s1
    80002894:	ad8fe0ef          	jal	ra,80000b6c <acquire>
  np->parent = p;
    80002898:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    8000289c:	8526                	mv	a0,s1
    8000289e:	b66fe0ef          	jal	ra,80000c04 <release>
  acquire(&np->lock);
    800028a2:	8552                	mv	a0,s4
    800028a4:	ac8fe0ef          	jal	ra,80000b6c <acquire>
  np->state = RUNNABLE;
    800028a8:	478d                	li	a5,3
    800028aa:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    800028ae:	8552                	mv	a0,s4
    800028b0:	b54fe0ef          	jal	ra,80000c04 <release>
}
    800028b4:	854a                	mv	a0,s2
    800028b6:	70e2                	ld	ra,56(sp)
    800028b8:	7442                	ld	s0,48(sp)
    800028ba:	74a2                	ld	s1,40(sp)
    800028bc:	7902                	ld	s2,32(sp)
    800028be:	69e2                	ld	s3,24(sp)
    800028c0:	6a42                	ld	s4,16(sp)
    800028c2:	6aa2                	ld	s5,8(sp)
    800028c4:	6121                	addi	sp,sp,64
    800028c6:	8082                	ret
    return -1;
    800028c8:	597d                	li	s2,-1
    800028ca:	b7ed                	j	800028b4 <kfork+0xf4>

00000000800028cc <scheduler>:
{
    800028cc:	711d                	addi	sp,sp,-96
    800028ce:	ec86                	sd	ra,88(sp)
    800028d0:	e8a2                	sd	s0,80(sp)
    800028d2:	e4a6                	sd	s1,72(sp)
    800028d4:	e0ca                	sd	s2,64(sp)
    800028d6:	fc4e                	sd	s3,56(sp)
    800028d8:	f852                	sd	s4,48(sp)
    800028da:	f456                	sd	s5,40(sp)
    800028dc:	f05a                	sd	s6,32(sp)
    800028de:	ec5e                	sd	s7,24(sp)
    800028e0:	e862                	sd	s8,16(sp)
    800028e2:	e466                	sd	s9,8(sp)
    800028e4:	1080                	addi	s0,sp,96
    800028e6:	8792                	mv	a5,tp
  int id = r_tp();
    800028e8:	2781                	sext.w	a5,a5
  c->proc = 0;
    800028ea:	00779c13          	slli	s8,a5,0x7
    800028ee:	0000e717          	auipc	a4,0xe
    800028f2:	52a70713          	addi	a4,a4,1322 # 80010e18 <pid_lock>
    800028f6:	9762                	add	a4,a4,s8
    800028f8:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    800028fc:	0000e717          	auipc	a4,0xe
    80002900:	55470713          	addi	a4,a4,1364 # 80010e50 <cpus+0x8>
    80002904:	9c3a                	add	s8,s8,a4
        p->state = RUNNING;
    80002906:	4c91                	li	s9,4
        c->proc = p;
    80002908:	079e                	slli	a5,a5,0x7
    8000290a:	0000ea97          	auipc	s5,0xe
    8000290e:	50ea8a93          	addi	s5,s5,1294 # 80010e18 <pid_lock>
    80002912:	9abe                	add	s5,s5,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80002914:	6989                	lui	s3,0x2
    80002916:	bf098993          	addi	s3,s3,-1040 # 1bf0 <_entry-0x7fffe410>
    8000291a:	0007ea17          	auipc	s4,0x7e
    8000291e:	52ea0a13          	addi	s4,s4,1326 # 80080e48 <tickslock>
    80002922:	a835                	j	8000295e <scheduler+0x92>
      release(&p->lock);
    80002924:	8526                	mv	a0,s1
    80002926:	adefe0ef          	jal	ra,80000c04 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000292a:	94ce                	add	s1,s1,s3
    8000292c:	03448563          	beq	s1,s4,80002956 <scheduler+0x8a>
      acquire(&p->lock);
    80002930:	8526                	mv	a0,s1
    80002932:	a3afe0ef          	jal	ra,80000b6c <acquire>
      if(p->state == RUNNABLE) {
    80002936:	4c9c                	lw	a5,24(s1)
    80002938:	ff2796e3          	bne	a5,s2,80002924 <scheduler+0x58>
        p->state = RUNNING;
    8000293c:	0194ac23          	sw	s9,24(s1)
        c->proc = p;
    80002940:	029ab823          	sd	s1,48(s5)
        swtch(&c->context, &p->context);
    80002944:	06048593          	addi	a1,s1,96
    80002948:	8562                	mv	a0,s8
    8000294a:	60a000ef          	jal	ra,80002f54 <swtch>
        c->proc = 0;
    8000294e:	020ab823          	sd	zero,48(s5)
        found = 1;
    80002952:	8b5e                	mv	s6,s7
    80002954:	bfc1                	j	80002924 <scheduler+0x58>
    if(found == 0) {
    80002956:	000b1463          	bnez	s6,8000295e <scheduler+0x92>
      asm volatile("wfi");
    8000295a:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000295e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002962:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002966:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000296a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000296e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002970:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002974:	4b01                	li	s6,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002976:	0000f497          	auipc	s1,0xf
    8000297a:	8d248493          	addi	s1,s1,-1838 # 80011248 <proc>
      if(p->state == RUNNABLE) {
    8000297e:	490d                	li	s2,3
        found = 1;
    80002980:	4b85                	li	s7,1
    80002982:	b77d                	j	80002930 <scheduler+0x64>

0000000080002984 <sched>:
{
    80002984:	7179                	addi	sp,sp,-48
    80002986:	f406                	sd	ra,40(sp)
    80002988:	f022                	sd	s0,32(sp)
    8000298a:	ec26                	sd	s1,24(sp)
    8000298c:	e84a                	sd	s2,16(sp)
    8000298e:	e44e                	sd	s3,8(sp)
    80002990:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002992:	a37ff0ef          	jal	ra,800023c8 <myproc>
    80002996:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002998:	96afe0ef          	jal	ra,80000b02 <holding>
    8000299c:	c92d                	beqz	a0,80002a0e <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000299e:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800029a0:	2781                	sext.w	a5,a5
    800029a2:	079e                	slli	a5,a5,0x7
    800029a4:	0000e717          	auipc	a4,0xe
    800029a8:	47470713          	addi	a4,a4,1140 # 80010e18 <pid_lock>
    800029ac:	97ba                	add	a5,a5,a4
    800029ae:	0a87a703          	lw	a4,168(a5)
    800029b2:	4785                	li	a5,1
    800029b4:	06f71363          	bne	a4,a5,80002a1a <sched+0x96>
  if(p->state == RUNNING)
    800029b8:	4c98                	lw	a4,24(s1)
    800029ba:	4791                	li	a5,4
    800029bc:	06f70563          	beq	a4,a5,80002a26 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029c0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800029c4:	8b89                	andi	a5,a5,2
  if(intr_get())
    800029c6:	e7b5                	bnez	a5,80002a32 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    800029c8:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800029ca:	0000e917          	auipc	s2,0xe
    800029ce:	44e90913          	addi	s2,s2,1102 # 80010e18 <pid_lock>
    800029d2:	2781                	sext.w	a5,a5
    800029d4:	079e                	slli	a5,a5,0x7
    800029d6:	97ca                	add	a5,a5,s2
    800029d8:	0ac7a983          	lw	s3,172(a5)
    800029dc:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800029de:	2781                	sext.w	a5,a5
    800029e0:	079e                	slli	a5,a5,0x7
    800029e2:	0000e597          	auipc	a1,0xe
    800029e6:	46e58593          	addi	a1,a1,1134 # 80010e50 <cpus+0x8>
    800029ea:	95be                	add	a1,a1,a5
    800029ec:	06048513          	addi	a0,s1,96
    800029f0:	564000ef          	jal	ra,80002f54 <swtch>
    800029f4:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800029f6:	2781                	sext.w	a5,a5
    800029f8:	079e                	slli	a5,a5,0x7
    800029fa:	97ca                	add	a5,a5,s2
    800029fc:	0b37a623          	sw	s3,172(a5)
}
    80002a00:	70a2                	ld	ra,40(sp)
    80002a02:	7402                	ld	s0,32(sp)
    80002a04:	64e2                	ld	s1,24(sp)
    80002a06:	6942                	ld	s2,16(sp)
    80002a08:	69a2                	ld	s3,8(sp)
    80002a0a:	6145                	addi	sp,sp,48
    80002a0c:	8082                	ret
    panic("sched p->lock");
    80002a0e:	00006517          	auipc	a0,0x6
    80002a12:	b2a50513          	addi	a0,a0,-1238 # 80008538 <digits+0x500>
    80002a16:	d75fd0ef          	jal	ra,8000078a <panic>
    panic("sched locks");
    80002a1a:	00006517          	auipc	a0,0x6
    80002a1e:	b2e50513          	addi	a0,a0,-1234 # 80008548 <digits+0x510>
    80002a22:	d69fd0ef          	jal	ra,8000078a <panic>
    panic("sched RUNNING");
    80002a26:	00006517          	auipc	a0,0x6
    80002a2a:	b3250513          	addi	a0,a0,-1230 # 80008558 <digits+0x520>
    80002a2e:	d5dfd0ef          	jal	ra,8000078a <panic>
    panic("sched interruptible");
    80002a32:	00006517          	auipc	a0,0x6
    80002a36:	b3650513          	addi	a0,a0,-1226 # 80008568 <digits+0x530>
    80002a3a:	d51fd0ef          	jal	ra,8000078a <panic>

0000000080002a3e <yield>:
{
    80002a3e:	1101                	addi	sp,sp,-32
    80002a40:	ec06                	sd	ra,24(sp)
    80002a42:	e822                	sd	s0,16(sp)
    80002a44:	e426                	sd	s1,8(sp)
    80002a46:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002a48:	981ff0ef          	jal	ra,800023c8 <myproc>
    80002a4c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002a4e:	91efe0ef          	jal	ra,80000b6c <acquire>
  p->state = RUNNABLE;
    80002a52:	478d                	li	a5,3
    80002a54:	cc9c                	sw	a5,24(s1)
  sched();
    80002a56:	f2fff0ef          	jal	ra,80002984 <sched>
  release(&p->lock);
    80002a5a:	8526                	mv	a0,s1
    80002a5c:	9a8fe0ef          	jal	ra,80000c04 <release>
}
    80002a60:	60e2                	ld	ra,24(sp)
    80002a62:	6442                	ld	s0,16(sp)
    80002a64:	64a2                	ld	s1,8(sp)
    80002a66:	6105                	addi	sp,sp,32
    80002a68:	8082                	ret

0000000080002a6a <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002a6a:	7179                	addi	sp,sp,-48
    80002a6c:	f406                	sd	ra,40(sp)
    80002a6e:	f022                	sd	s0,32(sp)
    80002a70:	ec26                	sd	s1,24(sp)
    80002a72:	e84a                	sd	s2,16(sp)
    80002a74:	e44e                	sd	s3,8(sp)
    80002a76:	1800                	addi	s0,sp,48
    80002a78:	89aa                	mv	s3,a0
    80002a7a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a7c:	94dff0ef          	jal	ra,800023c8 <myproc>
    80002a80:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002a82:	8eafe0ef          	jal	ra,80000b6c <acquire>
  release(lk);
    80002a86:	854a                	mv	a0,s2
    80002a88:	97cfe0ef          	jal	ra,80000c04 <release>

  // Go to sleep.
  p->chan = chan;
    80002a8c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002a90:	4789                	li	a5,2
    80002a92:	cc9c                	sw	a5,24(s1)

  sched();
    80002a94:	ef1ff0ef          	jal	ra,80002984 <sched>

  // Tidy up.
  p->chan = 0;
    80002a98:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002a9c:	8526                	mv	a0,s1
    80002a9e:	966fe0ef          	jal	ra,80000c04 <release>
  acquire(lk);
    80002aa2:	854a                	mv	a0,s2
    80002aa4:	8c8fe0ef          	jal	ra,80000b6c <acquire>
}
    80002aa8:	70a2                	ld	ra,40(sp)
    80002aaa:	7402                	ld	s0,32(sp)
    80002aac:	64e2                	ld	s1,24(sp)
    80002aae:	6942                	ld	s2,16(sp)
    80002ab0:	69a2                	ld	s3,8(sp)
    80002ab2:	6145                	addi	sp,sp,48
    80002ab4:	8082                	ret

0000000080002ab6 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80002ab6:	7139                	addi	sp,sp,-64
    80002ab8:	fc06                	sd	ra,56(sp)
    80002aba:	f822                	sd	s0,48(sp)
    80002abc:	f426                	sd	s1,40(sp)
    80002abe:	f04a                	sd	s2,32(sp)
    80002ac0:	ec4e                	sd	s3,24(sp)
    80002ac2:	e852                	sd	s4,16(sp)
    80002ac4:	e456                	sd	s5,8(sp)
    80002ac6:	e05a                	sd	s6,0(sp)
    80002ac8:	0080                	addi	s0,sp,64
    80002aca:	8aaa                	mv	s5,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002acc:	0000e497          	auipc	s1,0xe
    80002ad0:	77c48493          	addi	s1,s1,1916 # 80011248 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002ad4:	4a09                	li	s4,2
        p->state = RUNNABLE;
    80002ad6:	4b0d                	li	s6,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002ad8:	6909                	lui	s2,0x2
    80002ada:	bf090913          	addi	s2,s2,-1040 # 1bf0 <_entry-0x7fffe410>
    80002ade:	0007e997          	auipc	s3,0x7e
    80002ae2:	36a98993          	addi	s3,s3,874 # 80080e48 <tickslock>
    80002ae6:	a039                	j	80002af4 <wakeup+0x3e>
      }
      release(&p->lock);
    80002ae8:	8526                	mv	a0,s1
    80002aea:	91afe0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002aee:	94ca                	add	s1,s1,s2
    80002af0:	03348263          	beq	s1,s3,80002b14 <wakeup+0x5e>
    if(p != myproc()){
    80002af4:	8d5ff0ef          	jal	ra,800023c8 <myproc>
    80002af8:	fea48be3          	beq	s1,a0,80002aee <wakeup+0x38>
      acquire(&p->lock);
    80002afc:	8526                	mv	a0,s1
    80002afe:	86efe0ef          	jal	ra,80000b6c <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002b02:	4c9c                	lw	a5,24(s1)
    80002b04:	ff4792e3          	bne	a5,s4,80002ae8 <wakeup+0x32>
    80002b08:	709c                	ld	a5,32(s1)
    80002b0a:	fd579fe3          	bne	a5,s5,80002ae8 <wakeup+0x32>
        p->state = RUNNABLE;
    80002b0e:	0164ac23          	sw	s6,24(s1)
    80002b12:	bfd9                	j	80002ae8 <wakeup+0x32>
    }
  }
}
    80002b14:	70e2                	ld	ra,56(sp)
    80002b16:	7442                	ld	s0,48(sp)
    80002b18:	74a2                	ld	s1,40(sp)
    80002b1a:	7902                	ld	s2,32(sp)
    80002b1c:	69e2                	ld	s3,24(sp)
    80002b1e:	6a42                	ld	s4,16(sp)
    80002b20:	6aa2                	ld	s5,8(sp)
    80002b22:	6b02                	ld	s6,0(sp)
    80002b24:	6121                	addi	sp,sp,64
    80002b26:	8082                	ret

0000000080002b28 <reparent>:
{
    80002b28:	7139                	addi	sp,sp,-64
    80002b2a:	fc06                	sd	ra,56(sp)
    80002b2c:	f822                	sd	s0,48(sp)
    80002b2e:	f426                	sd	s1,40(sp)
    80002b30:	f04a                	sd	s2,32(sp)
    80002b32:	ec4e                	sd	s3,24(sp)
    80002b34:	e852                	sd	s4,16(sp)
    80002b36:	e456                	sd	s5,8(sp)
    80002b38:	0080                	addi	s0,sp,64
    80002b3a:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002b3c:	0000e497          	auipc	s1,0xe
    80002b40:	70c48493          	addi	s1,s1,1804 # 80011248 <proc>
      pp->parent = initproc;
    80002b44:	00006a97          	auipc	s5,0x6
    80002b48:	1cca8a93          	addi	s5,s5,460 # 80008d10 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002b4c:	6909                	lui	s2,0x2
    80002b4e:	bf090913          	addi	s2,s2,-1040 # 1bf0 <_entry-0x7fffe410>
    80002b52:	0007ea17          	auipc	s4,0x7e
    80002b56:	2f6a0a13          	addi	s4,s4,758 # 80080e48 <tickslock>
    80002b5a:	a021                	j	80002b62 <reparent+0x3a>
    80002b5c:	94ca                	add	s1,s1,s2
    80002b5e:	01448b63          	beq	s1,s4,80002b74 <reparent+0x4c>
    if(pp->parent == p){
    80002b62:	7c9c                	ld	a5,56(s1)
    80002b64:	ff379ce3          	bne	a5,s3,80002b5c <reparent+0x34>
      pp->parent = initproc;
    80002b68:	000ab503          	ld	a0,0(s5)
    80002b6c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002b6e:	f49ff0ef          	jal	ra,80002ab6 <wakeup>
    80002b72:	b7ed                	j	80002b5c <reparent+0x34>
}
    80002b74:	70e2                	ld	ra,56(sp)
    80002b76:	7442                	ld	s0,48(sp)
    80002b78:	74a2                	ld	s1,40(sp)
    80002b7a:	7902                	ld	s2,32(sp)
    80002b7c:	69e2                	ld	s3,24(sp)
    80002b7e:	6a42                	ld	s4,16(sp)
    80002b80:	6aa2                	ld	s5,8(sp)
    80002b82:	6121                	addi	sp,sp,64
    80002b84:	8082                	ret

0000000080002b86 <kexit>:
{
    80002b86:	7179                	addi	sp,sp,-48
    80002b88:	f406                	sd	ra,40(sp)
    80002b8a:	f022                	sd	s0,32(sp)
    80002b8c:	ec26                	sd	s1,24(sp)
    80002b8e:	e84a                	sd	s2,16(sp)
    80002b90:	e44e                	sd	s3,8(sp)
    80002b92:	e052                	sd	s4,0(sp)
    80002b94:	1800                	addi	s0,sp,48
    80002b96:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002b98:	831ff0ef          	jal	ra,800023c8 <myproc>
  if(p == initproc)
    80002b9c:	00006797          	auipc	a5,0x6
    80002ba0:	1747b783          	ld	a5,372(a5) # 80008d10 <initproc>
    80002ba4:	02a78a63          	beq	a5,a0,80002bd8 <kexit+0x52>
    80002ba8:	892a                	mv	s2,a0
  if(p->swapfile) {
    80002baa:	6785                	lui	a5,0x1
    80002bac:	97aa                	add	a5,a5,a0
    80002bae:	bd07b783          	ld	a5,-1072(a5) # bd0 <_entry-0x7ffff430>
    80002bb2:	cf91                	beqz	a5,80002bce <kexit+0x48>
    printf("[pid %d] SWAPCLEANUP freed_slots=%d\n", p->pid, p->num_swap_slots_used);
    80002bb4:	6489                	lui	s1,0x2
    80002bb6:	94aa                	add	s1,s1,a0
    80002bb8:	bec4a603          	lw	a2,-1044(s1) # 1bec <_entry-0x7fffe414>
    80002bbc:	590c                	lw	a1,48(a0)
    80002bbe:	00006517          	auipc	a0,0x6
    80002bc2:	9d250513          	addi	a0,a0,-1582 # 80008590 <digits+0x558>
    80002bc6:	8fffd0ef          	jal	ra,800004c4 <printf>
    p->num_swap_slots_used = 0;
    80002bca:	be04a623          	sw	zero,-1044(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002bce:	0d090493          	addi	s1,s2,208
    80002bd2:	15090993          	addi	s3,s2,336
    80002bd6:	a831                	j	80002bf2 <kexit+0x6c>
    panic("init exiting");
    80002bd8:	00006517          	auipc	a0,0x6
    80002bdc:	9a850513          	addi	a0,a0,-1624 # 80008580 <digits+0x548>
    80002be0:	babfd0ef          	jal	ra,8000078a <panic>
      fileclose(f);
    80002be4:	15e020ef          	jal	ra,80004d42 <fileclose>
      p->ofile[fd] = 0;
    80002be8:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002bec:	04a1                	addi	s1,s1,8
    80002bee:	01348563          	beq	s1,s3,80002bf8 <kexit+0x72>
    if(p->ofile[fd]){
    80002bf2:	6088                	ld	a0,0(s1)
    80002bf4:	f965                	bnez	a0,80002be4 <kexit+0x5e>
    80002bf6:	bfdd                	j	80002bec <kexit+0x66>
  if(p->swapfile) {
    80002bf8:	6785                	lui	a5,0x1
    80002bfa:	97ca                	add	a5,a5,s2
    80002bfc:	bd07b503          	ld	a0,-1072(a5) # bd0 <_entry-0x7ffff430>
    80002c00:	c519                	beqz	a0,80002c0e <kexit+0x88>
    fileclose(p->swapfile);
    80002c02:	140020ef          	jal	ra,80004d42 <fileclose>
    p->swapfile = 0;
    80002c06:	6785                	lui	a5,0x1
    80002c08:	97ca                	add	a5,a5,s2
    80002c0a:	bc07b823          	sd	zero,-1072(a5) # bd0 <_entry-0x7ffff430>
  begin_op();
    80002c0e:	527010ef          	jal	ra,80004934 <begin_op>
  iput(p->cwd);
    80002c12:	15093503          	ld	a0,336(s2)
    80002c16:	4be010ef          	jal	ra,800040d4 <iput>
  end_op();
    80002c1a:	58b010ef          	jal	ra,800049a4 <end_op>
  p->cwd = 0;
    80002c1e:	14093823          	sd	zero,336(s2)
  acquire(&wait_lock);
    80002c22:	0000e497          	auipc	s1,0xe
    80002c26:	20e48493          	addi	s1,s1,526 # 80010e30 <wait_lock>
    80002c2a:	8526                	mv	a0,s1
    80002c2c:	f41fd0ef          	jal	ra,80000b6c <acquire>
  reparent(p);
    80002c30:	854a                	mv	a0,s2
    80002c32:	ef7ff0ef          	jal	ra,80002b28 <reparent>
  wakeup(p->parent);
    80002c36:	03893503          	ld	a0,56(s2)
    80002c3a:	e7dff0ef          	jal	ra,80002ab6 <wakeup>
  acquire(&p->lock);
    80002c3e:	854a                	mv	a0,s2
    80002c40:	f2dfd0ef          	jal	ra,80000b6c <acquire>
  p->xstate = status;
    80002c44:	03492623          	sw	s4,44(s2)
  p->state = ZOMBIE;
    80002c48:	4795                	li	a5,5
    80002c4a:	00f92c23          	sw	a5,24(s2)
  release(&wait_lock);
    80002c4e:	8526                	mv	a0,s1
    80002c50:	fb5fd0ef          	jal	ra,80000c04 <release>
  sched();
    80002c54:	d31ff0ef          	jal	ra,80002984 <sched>
  panic("zombie exit");
    80002c58:	00006517          	auipc	a0,0x6
    80002c5c:	96050513          	addi	a0,a0,-1696 # 800085b8 <digits+0x580>
    80002c60:	b2bfd0ef          	jal	ra,8000078a <panic>

0000000080002c64 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002c64:	7179                	addi	sp,sp,-48
    80002c66:	f406                	sd	ra,40(sp)
    80002c68:	f022                	sd	s0,32(sp)
    80002c6a:	ec26                	sd	s1,24(sp)
    80002c6c:	e84a                	sd	s2,16(sp)
    80002c6e:	e44e                	sd	s3,8(sp)
    80002c70:	e052                	sd	s4,0(sp)
    80002c72:	1800                	addi	s0,sp,48
    80002c74:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002c76:	0000e497          	auipc	s1,0xe
    80002c7a:	5d248493          	addi	s1,s1,1490 # 80011248 <proc>
    80002c7e:	6989                	lui	s3,0x2
    80002c80:	bf098993          	addi	s3,s3,-1040 # 1bf0 <_entry-0x7fffe410>
    80002c84:	0007ea17          	auipc	s4,0x7e
    80002c88:	1c4a0a13          	addi	s4,s4,452 # 80080e48 <tickslock>
    acquire(&p->lock);
    80002c8c:	8526                	mv	a0,s1
    80002c8e:	edffd0ef          	jal	ra,80000b6c <acquire>
    if(p->pid == pid){
    80002c92:	589c                	lw	a5,48(s1)
    80002c94:	01278a63          	beq	a5,s2,80002ca8 <kkill+0x44>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002c98:	8526                	mv	a0,s1
    80002c9a:	f6bfd0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002c9e:	94ce                	add	s1,s1,s3
    80002ca0:	ff4496e3          	bne	s1,s4,80002c8c <kkill+0x28>
  }
  return -1;
    80002ca4:	557d                	li	a0,-1
    80002ca6:	a819                	j	80002cbc <kkill+0x58>
      p->killed = 1;
    80002ca8:	4785                	li	a5,1
    80002caa:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002cac:	4c98                	lw	a4,24(s1)
    80002cae:	4789                	li	a5,2
    80002cb0:	00f70e63          	beq	a4,a5,80002ccc <kkill+0x68>
      release(&p->lock);
    80002cb4:	8526                	mv	a0,s1
    80002cb6:	f4ffd0ef          	jal	ra,80000c04 <release>
      return 0;
    80002cba:	4501                	li	a0,0
}
    80002cbc:	70a2                	ld	ra,40(sp)
    80002cbe:	7402                	ld	s0,32(sp)
    80002cc0:	64e2                	ld	s1,24(sp)
    80002cc2:	6942                	ld	s2,16(sp)
    80002cc4:	69a2                	ld	s3,8(sp)
    80002cc6:	6a02                	ld	s4,0(sp)
    80002cc8:	6145                	addi	sp,sp,48
    80002cca:	8082                	ret
        p->state = RUNNABLE;
    80002ccc:	478d                	li	a5,3
    80002cce:	cc9c                	sw	a5,24(s1)
    80002cd0:	b7d5                	j	80002cb4 <kkill+0x50>

0000000080002cd2 <setkilled>:

void
setkilled(struct proc *p)
{
    80002cd2:	1101                	addi	sp,sp,-32
    80002cd4:	ec06                	sd	ra,24(sp)
    80002cd6:	e822                	sd	s0,16(sp)
    80002cd8:	e426                	sd	s1,8(sp)
    80002cda:	1000                	addi	s0,sp,32
    80002cdc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002cde:	e8ffd0ef          	jal	ra,80000b6c <acquire>
  p->killed = 1;
    80002ce2:	4785                	li	a5,1
    80002ce4:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002ce6:	8526                	mv	a0,s1
    80002ce8:	f1dfd0ef          	jal	ra,80000c04 <release>
}
    80002cec:	60e2                	ld	ra,24(sp)
    80002cee:	6442                	ld	s0,16(sp)
    80002cf0:	64a2                	ld	s1,8(sp)
    80002cf2:	6105                	addi	sp,sp,32
    80002cf4:	8082                	ret

0000000080002cf6 <killed>:

int
killed(struct proc *p)
{
    80002cf6:	1101                	addi	sp,sp,-32
    80002cf8:	ec06                	sd	ra,24(sp)
    80002cfa:	e822                	sd	s0,16(sp)
    80002cfc:	e426                	sd	s1,8(sp)
    80002cfe:	e04a                	sd	s2,0(sp)
    80002d00:	1000                	addi	s0,sp,32
    80002d02:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002d04:	e69fd0ef          	jal	ra,80000b6c <acquire>
  k = p->killed;
    80002d08:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002d0c:	8526                	mv	a0,s1
    80002d0e:	ef7fd0ef          	jal	ra,80000c04 <release>
  return k;
}
    80002d12:	854a                	mv	a0,s2
    80002d14:	60e2                	ld	ra,24(sp)
    80002d16:	6442                	ld	s0,16(sp)
    80002d18:	64a2                	ld	s1,8(sp)
    80002d1a:	6902                	ld	s2,0(sp)
    80002d1c:	6105                	addi	sp,sp,32
    80002d1e:	8082                	ret

0000000080002d20 <kwait>:
{
    80002d20:	715d                	addi	sp,sp,-80
    80002d22:	e486                	sd	ra,72(sp)
    80002d24:	e0a2                	sd	s0,64(sp)
    80002d26:	fc26                	sd	s1,56(sp)
    80002d28:	f84a                	sd	s2,48(sp)
    80002d2a:	f44e                	sd	s3,40(sp)
    80002d2c:	f052                	sd	s4,32(sp)
    80002d2e:	ec56                	sd	s5,24(sp)
    80002d30:	e85a                	sd	s6,16(sp)
    80002d32:	e45e                	sd	s7,8(sp)
    80002d34:	0880                	addi	s0,sp,80
    80002d36:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002d38:	e90ff0ef          	jal	ra,800023c8 <myproc>
    80002d3c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002d3e:	0000e517          	auipc	a0,0xe
    80002d42:	0f250513          	addi	a0,a0,242 # 80010e30 <wait_lock>
    80002d46:	e27fd0ef          	jal	ra,80000b6c <acquire>
        if(pp->state == ZOMBIE){
    80002d4a:	4a95                	li	s5,5
        havekids = 1;
    80002d4c:	4b05                	li	s6,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002d4e:	6989                	lui	s3,0x2
    80002d50:	bf098993          	addi	s3,s3,-1040 # 1bf0 <_entry-0x7fffe410>
    80002d54:	0007ea17          	auipc	s4,0x7e
    80002d58:	0f4a0a13          	addi	s4,s4,244 # 80080e48 <tickslock>
    havekids = 0;
    80002d5c:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002d5e:	0000e497          	auipc	s1,0xe
    80002d62:	4ea48493          	addi	s1,s1,1258 # 80011248 <proc>
    80002d66:	a891                	j	80002dba <kwait+0x9a>
          pid = pp->pid;
    80002d68:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002d6c:	000b8c63          	beqz	s7,80002d84 <kwait+0x64>
    80002d70:	4691                	li	a3,4
    80002d72:	02c48613          	addi	a2,s1,44
    80002d76:	85de                	mv	a1,s7
    80002d78:	05093503          	ld	a0,80(s2)
    80002d7c:	b6aff0ef          	jal	ra,800020e6 <copyout>
    80002d80:	00054f63          	bltz	a0,80002d9e <kwait+0x7e>
          freeproc(pp);
    80002d84:	8526                	mv	a0,s1
    80002d86:	813ff0ef          	jal	ra,80002598 <freeproc>
          release(&pp->lock);
    80002d8a:	8526                	mv	a0,s1
    80002d8c:	e79fd0ef          	jal	ra,80000c04 <release>
          release(&wait_lock);
    80002d90:	0000e517          	auipc	a0,0xe
    80002d94:	0a050513          	addi	a0,a0,160 # 80010e30 <wait_lock>
    80002d98:	e6dfd0ef          	jal	ra,80000c04 <release>
          return pid;
    80002d9c:	a889                	j	80002dee <kwait+0xce>
            release(&pp->lock);
    80002d9e:	8526                	mv	a0,s1
    80002da0:	e65fd0ef          	jal	ra,80000c04 <release>
            release(&wait_lock);
    80002da4:	0000e517          	auipc	a0,0xe
    80002da8:	08c50513          	addi	a0,a0,140 # 80010e30 <wait_lock>
    80002dac:	e59fd0ef          	jal	ra,80000c04 <release>
            return -1;
    80002db0:	59fd                	li	s3,-1
    80002db2:	a835                	j	80002dee <kwait+0xce>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002db4:	94ce                	add	s1,s1,s3
    80002db6:	03448063          	beq	s1,s4,80002dd6 <kwait+0xb6>
      if(pp->parent == p){
    80002dba:	7c9c                	ld	a5,56(s1)
    80002dbc:	ff279ce3          	bne	a5,s2,80002db4 <kwait+0x94>
        acquire(&pp->lock);
    80002dc0:	8526                	mv	a0,s1
    80002dc2:	dabfd0ef          	jal	ra,80000b6c <acquire>
        if(pp->state == ZOMBIE){
    80002dc6:	4c9c                	lw	a5,24(s1)
    80002dc8:	fb5780e3          	beq	a5,s5,80002d68 <kwait+0x48>
        release(&pp->lock);
    80002dcc:	8526                	mv	a0,s1
    80002dce:	e37fd0ef          	jal	ra,80000c04 <release>
        havekids = 1;
    80002dd2:	875a                	mv	a4,s6
    80002dd4:	b7c5                	j	80002db4 <kwait+0x94>
    if(!havekids || killed(p)){
    80002dd6:	c709                	beqz	a4,80002de0 <kwait+0xc0>
    80002dd8:	854a                	mv	a0,s2
    80002dda:	f1dff0ef          	jal	ra,80002cf6 <killed>
    80002dde:	c505                	beqz	a0,80002e06 <kwait+0xe6>
      release(&wait_lock);
    80002de0:	0000e517          	auipc	a0,0xe
    80002de4:	05050513          	addi	a0,a0,80 # 80010e30 <wait_lock>
    80002de8:	e1dfd0ef          	jal	ra,80000c04 <release>
      return -1;
    80002dec:	59fd                	li	s3,-1
}
    80002dee:	854e                	mv	a0,s3
    80002df0:	60a6                	ld	ra,72(sp)
    80002df2:	6406                	ld	s0,64(sp)
    80002df4:	74e2                	ld	s1,56(sp)
    80002df6:	7942                	ld	s2,48(sp)
    80002df8:	79a2                	ld	s3,40(sp)
    80002dfa:	7a02                	ld	s4,32(sp)
    80002dfc:	6ae2                	ld	s5,24(sp)
    80002dfe:	6b42                	ld	s6,16(sp)
    80002e00:	6ba2                	ld	s7,8(sp)
    80002e02:	6161                	addi	sp,sp,80
    80002e04:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002e06:	0000e597          	auipc	a1,0xe
    80002e0a:	02a58593          	addi	a1,a1,42 # 80010e30 <wait_lock>
    80002e0e:	854a                	mv	a0,s2
    80002e10:	c5bff0ef          	jal	ra,80002a6a <sleep>
    havekids = 0;
    80002e14:	b7a1                	j	80002d5c <kwait+0x3c>

0000000080002e16 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002e16:	7179                	addi	sp,sp,-48
    80002e18:	f406                	sd	ra,40(sp)
    80002e1a:	f022                	sd	s0,32(sp)
    80002e1c:	ec26                	sd	s1,24(sp)
    80002e1e:	e84a                	sd	s2,16(sp)
    80002e20:	e44e                	sd	s3,8(sp)
    80002e22:	e052                	sd	s4,0(sp)
    80002e24:	1800                	addi	s0,sp,48
    80002e26:	84aa                	mv	s1,a0
    80002e28:	892e                	mv	s2,a1
    80002e2a:	89b2                	mv	s3,a2
    80002e2c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002e2e:	d9aff0ef          	jal	ra,800023c8 <myproc>
  if(user_dst){
    80002e32:	cc99                	beqz	s1,80002e50 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002e34:	86d2                	mv	a3,s4
    80002e36:	864e                	mv	a2,s3
    80002e38:	85ca                	mv	a1,s2
    80002e3a:	6928                	ld	a0,80(a0)
    80002e3c:	aaaff0ef          	jal	ra,800020e6 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002e40:	70a2                	ld	ra,40(sp)
    80002e42:	7402                	ld	s0,32(sp)
    80002e44:	64e2                	ld	s1,24(sp)
    80002e46:	6942                	ld	s2,16(sp)
    80002e48:	69a2                	ld	s3,8(sp)
    80002e4a:	6a02                	ld	s4,0(sp)
    80002e4c:	6145                	addi	sp,sp,48
    80002e4e:	8082                	ret
    memmove((char *)dst, src, len);
    80002e50:	000a061b          	sext.w	a2,s4
    80002e54:	85ce                	mv	a1,s3
    80002e56:	854a                	mv	a0,s2
    80002e58:	e45fd0ef          	jal	ra,80000c9c <memmove>
    return 0;
    80002e5c:	8526                	mv	a0,s1
    80002e5e:	b7cd                	j	80002e40 <either_copyout+0x2a>

0000000080002e60 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002e60:	7179                	addi	sp,sp,-48
    80002e62:	f406                	sd	ra,40(sp)
    80002e64:	f022                	sd	s0,32(sp)
    80002e66:	ec26                	sd	s1,24(sp)
    80002e68:	e84a                	sd	s2,16(sp)
    80002e6a:	e44e                	sd	s3,8(sp)
    80002e6c:	e052                	sd	s4,0(sp)
    80002e6e:	1800                	addi	s0,sp,48
    80002e70:	892a                	mv	s2,a0
    80002e72:	84ae                	mv	s1,a1
    80002e74:	89b2                	mv	s3,a2
    80002e76:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002e78:	d50ff0ef          	jal	ra,800023c8 <myproc>
  if(user_src){
    80002e7c:	cc99                	beqz	s1,80002e9a <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002e7e:	86d2                	mv	a3,s4
    80002e80:	864e                	mv	a2,s3
    80002e82:	85ca                	mv	a1,s2
    80002e84:	6928                	ld	a0,80(a0)
    80002e86:	b46ff0ef          	jal	ra,800021cc <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002e8a:	70a2                	ld	ra,40(sp)
    80002e8c:	7402                	ld	s0,32(sp)
    80002e8e:	64e2                	ld	s1,24(sp)
    80002e90:	6942                	ld	s2,16(sp)
    80002e92:	69a2                	ld	s3,8(sp)
    80002e94:	6a02                	ld	s4,0(sp)
    80002e96:	6145                	addi	sp,sp,48
    80002e98:	8082                	ret
    memmove(dst, (char*)src, len);
    80002e9a:	000a061b          	sext.w	a2,s4
    80002e9e:	85ce                	mv	a1,s3
    80002ea0:	854a                	mv	a0,s2
    80002ea2:	dfbfd0ef          	jal	ra,80000c9c <memmove>
    return 0;
    80002ea6:	8526                	mv	a0,s1
    80002ea8:	b7cd                	j	80002e8a <either_copyin+0x2a>

0000000080002eaa <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002eaa:	715d                	addi	sp,sp,-80
    80002eac:	e486                	sd	ra,72(sp)
    80002eae:	e0a2                	sd	s0,64(sp)
    80002eb0:	fc26                	sd	s1,56(sp)
    80002eb2:	f84a                	sd	s2,48(sp)
    80002eb4:	f44e                	sd	s3,40(sp)
    80002eb6:	f052                	sd	s4,32(sp)
    80002eb8:	ec56                	sd	s5,24(sp)
    80002eba:	e85a                	sd	s6,16(sp)
    80002ebc:	e45e                	sd	s7,8(sp)
    80002ebe:	e062                	sd	s8,0(sp)
    80002ec0:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002ec2:	00005517          	auipc	a0,0x5
    80002ec6:	45e50513          	addi	a0,a0,1118 # 80008320 <digits+0x2e8>
    80002eca:	dfafd0ef          	jal	ra,800004c4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002ece:	0000e497          	auipc	s1,0xe
    80002ed2:	4d248493          	addi	s1,s1,1234 # 800113a0 <proc+0x158>
    80002ed6:	0007e997          	auipc	s3,0x7e
    80002eda:	0ca98993          	addi	s3,s3,202 # 80080fa0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002ede:	4b95                	li	s7,5
      state = states[p->state];
    else
      state = "???";
    80002ee0:	00005a17          	auipc	s4,0x5
    80002ee4:	6e8a0a13          	addi	s4,s4,1768 # 800085c8 <digits+0x590>
    printf("%d %s %s", p->pid, state, p->name);
    80002ee8:	00005b17          	auipc	s6,0x5
    80002eec:	6e8b0b13          	addi	s6,s6,1768 # 800085d0 <digits+0x598>
    printf("\n");
    80002ef0:	00005a97          	auipc	s5,0x5
    80002ef4:	430a8a93          	addi	s5,s5,1072 # 80008320 <digits+0x2e8>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002ef8:	00005c17          	auipc	s8,0x5
    80002efc:	718c0c13          	addi	s8,s8,1816 # 80008610 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    80002f00:	6909                	lui	s2,0x2
    80002f02:	bf090913          	addi	s2,s2,-1040 # 1bf0 <_entry-0x7fffe410>
    80002f06:	a821                	j	80002f1e <procdump+0x74>
    printf("%d %s %s", p->pid, state, p->name);
    80002f08:	ed86a583          	lw	a1,-296(a3)
    80002f0c:	855a                	mv	a0,s6
    80002f0e:	db6fd0ef          	jal	ra,800004c4 <printf>
    printf("\n");
    80002f12:	8556                	mv	a0,s5
    80002f14:	db0fd0ef          	jal	ra,800004c4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002f18:	94ca                	add	s1,s1,s2
    80002f1a:	03348163          	beq	s1,s3,80002f3c <procdump+0x92>
    if(p->state == UNUSED)
    80002f1e:	86a6                	mv	a3,s1
    80002f20:	ec04a783          	lw	a5,-320(s1)
    80002f24:	dbf5                	beqz	a5,80002f18 <procdump+0x6e>
      state = "???";
    80002f26:	8652                	mv	a2,s4
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002f28:	fefbe0e3          	bltu	s7,a5,80002f08 <procdump+0x5e>
    80002f2c:	1782                	slli	a5,a5,0x20
    80002f2e:	9381                	srli	a5,a5,0x20
    80002f30:	078e                	slli	a5,a5,0x3
    80002f32:	97e2                	add	a5,a5,s8
    80002f34:	6390                	ld	a2,0(a5)
    80002f36:	fa69                	bnez	a2,80002f08 <procdump+0x5e>
      state = "???";
    80002f38:	8652                	mv	a2,s4
    80002f3a:	b7f9                	j	80002f08 <procdump+0x5e>
  }
}
    80002f3c:	60a6                	ld	ra,72(sp)
    80002f3e:	6406                	ld	s0,64(sp)
    80002f40:	74e2                	ld	s1,56(sp)
    80002f42:	7942                	ld	s2,48(sp)
    80002f44:	79a2                	ld	s3,40(sp)
    80002f46:	7a02                	ld	s4,32(sp)
    80002f48:	6ae2                	ld	s5,24(sp)
    80002f4a:	6b42                	ld	s6,16(sp)
    80002f4c:	6ba2                	ld	s7,8(sp)
    80002f4e:	6c02                	ld	s8,0(sp)
    80002f50:	6161                	addi	sp,sp,80
    80002f52:	8082                	ret

0000000080002f54 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002f54:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002f58:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002f5c:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002f5e:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002f60:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002f64:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002f68:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002f6c:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002f70:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002f74:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002f78:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002f7c:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002f80:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002f84:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002f88:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002f8c:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002f90:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002f92:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002f94:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002f98:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002f9c:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002fa0:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002fa4:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002fa8:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002fac:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002fb0:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002fb4:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002fb8:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002fbc:	8082                	ret

0000000080002fbe <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002fbe:	1141                	addi	sp,sp,-16
    80002fc0:	e406                	sd	ra,8(sp)
    80002fc2:	e022                	sd	s0,0(sp)
    80002fc4:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002fc6:	00005597          	auipc	a1,0x5
    80002fca:	67a58593          	addi	a1,a1,1658 # 80008640 <states.0+0x30>
    80002fce:	0007e517          	auipc	a0,0x7e
    80002fd2:	e7a50513          	addi	a0,a0,-390 # 80080e48 <tickslock>
    80002fd6:	b17fd0ef          	jal	ra,80000aec <initlock>
}
    80002fda:	60a2                	ld	ra,8(sp)
    80002fdc:	6402                	ld	s0,0(sp)
    80002fde:	0141                	addi	sp,sp,16
    80002fe0:	8082                	ret

0000000080002fe2 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002fe2:	1141                	addi	sp,sp,-16
    80002fe4:	e422                	sd	s0,8(sp)
    80002fe6:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002fe8:	00003797          	auipc	a5,0x3
    80002fec:	05878793          	addi	a5,a5,88 # 80006040 <kernelvec>
    80002ff0:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002ff4:	6422                	ld	s0,8(sp)
    80002ff6:	0141                	addi	sp,sp,16
    80002ff8:	8082                	ret

0000000080002ffa <prepare_return>:

//
// set up trapframe and control registers for a return to user space
//
void prepare_return(void)
{
    80002ffa:	1141                	addi	sp,sp,-16
    80002ffc:	e406                	sd	ra,8(sp)
    80002ffe:	e022                	sd	s0,0(sp)
    80003000:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80003002:	bc6ff0ef          	jal	ra,800023c8 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003006:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000300a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000300c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80003010:	04000737          	lui	a4,0x4000
    80003014:	00004797          	auipc	a5,0x4
    80003018:	fec78793          	addi	a5,a5,-20 # 80007000 <_trampoline>
    8000301c:	00004697          	auipc	a3,0x4
    80003020:	fe468693          	addi	a3,a3,-28 # 80007000 <_trampoline>
    80003024:	8f95                	sub	a5,a5,a3
    80003026:	177d                	addi	a4,a4,-1
    80003028:	0732                	slli	a4,a4,0xc
    8000302a:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000302c:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80003030:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80003032:	18002773          	csrr	a4,satp
    80003036:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80003038:	6d38                	ld	a4,88(a0)
    8000303a:	613c                	ld	a5,64(a0)
    8000303c:	6685                	lui	a3,0x1
    8000303e:	97b6                	add	a5,a5,a3
    80003040:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80003042:	6d3c                	ld	a5,88(a0)
    80003044:	00000717          	auipc	a4,0x0
    80003048:	0f470713          	addi	a4,a4,244 # 80003138 <usertrap>
    8000304c:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    8000304e:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80003050:	8712                	mv	a4,tp
    80003052:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003054:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80003058:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000305c:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003060:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80003064:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003066:	6f9c                	ld	a5,24(a5)
    80003068:	14179073          	csrw	sepc,a5
}
    8000306c:	60a2                	ld	ra,8(sp)
    8000306e:	6402                	ld	s0,0(sp)
    80003070:	0141                	addi	sp,sp,16
    80003072:	8082                	ret

0000000080003074 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80003074:	1101                	addi	sp,sp,-32
    80003076:	ec06                	sd	ra,24(sp)
    80003078:	e822                	sd	s0,16(sp)
    8000307a:	e426                	sd	s1,8(sp)
    8000307c:	1000                	addi	s0,sp,32
  if (cpuid() == 0)
    8000307e:	b1eff0ef          	jal	ra,8000239c <cpuid>
    80003082:	cd19                	beqz	a0,800030a0 <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    80003084:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80003088:	000f4737          	lui	a4,0xf4
    8000308c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80003090:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80003092:	14d79073          	csrw	0x14d,a5
}
    80003096:	60e2                	ld	ra,24(sp)
    80003098:	6442                	ld	s0,16(sp)
    8000309a:	64a2                	ld	s1,8(sp)
    8000309c:	6105                	addi	sp,sp,32
    8000309e:	8082                	ret
    acquire(&tickslock);
    800030a0:	0007e497          	auipc	s1,0x7e
    800030a4:	da848493          	addi	s1,s1,-600 # 80080e48 <tickslock>
    800030a8:	8526                	mv	a0,s1
    800030aa:	ac3fd0ef          	jal	ra,80000b6c <acquire>
    ticks++;
    800030ae:	00006517          	auipc	a0,0x6
    800030b2:	c6a50513          	addi	a0,a0,-918 # 80008d18 <ticks>
    800030b6:	411c                	lw	a5,0(a0)
    800030b8:	2785                	addiw	a5,a5,1
    800030ba:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800030bc:	9fbff0ef          	jal	ra,80002ab6 <wakeup>
    release(&tickslock);
    800030c0:	8526                	mv	a0,s1
    800030c2:	b43fd0ef          	jal	ra,80000c04 <release>
    800030c6:	bf7d                	j	80003084 <clockintr+0x10>

00000000800030c8 <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    800030c8:	1101                	addi	sp,sp,-32
    800030ca:	ec06                	sd	ra,24(sp)
    800030cc:	e822                	sd	s0,16(sp)
    800030ce:	e426                	sd	s1,8(sp)
    800030d0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800030d2:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L)
    800030d6:	57fd                	li	a5,-1
    800030d8:	17fe                	slli	a5,a5,0x3f
    800030da:	07a5                	addi	a5,a5,9
    800030dc:	00f70d63          	beq	a4,a5,800030f6 <devintr+0x2e>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000005L)
    800030e0:	57fd                	li	a5,-1
    800030e2:	17fe                	slli	a5,a5,0x3f
    800030e4:	0795                	addi	a5,a5,5
    clockintr();
    return 2;
  }
  else
  {
    return 0;
    800030e6:	4501                	li	a0,0
  else if (scause == 0x8000000000000005L)
    800030e8:	04f70463          	beq	a4,a5,80003130 <devintr+0x68>
  }
}
    800030ec:	60e2                	ld	ra,24(sp)
    800030ee:	6442                	ld	s0,16(sp)
    800030f0:	64a2                	ld	s1,8(sp)
    800030f2:	6105                	addi	sp,sp,32
    800030f4:	8082                	ret
    int irq = plic_claim();
    800030f6:	7f3020ef          	jal	ra,800060e8 <plic_claim>
    800030fa:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    800030fc:	47a9                	li	a5,10
    800030fe:	02f50363          	beq	a0,a5,80003124 <devintr+0x5c>
    else if (irq == VIRTIO0_IRQ)
    80003102:	4785                	li	a5,1
    80003104:	02f50363          	beq	a0,a5,8000312a <devintr+0x62>
    return 1;
    80003108:	4505                	li	a0,1
    else if (irq)
    8000310a:	d0ed                	beqz	s1,800030ec <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    8000310c:	85a6                	mv	a1,s1
    8000310e:	00005517          	auipc	a0,0x5
    80003112:	53a50513          	addi	a0,a0,1338 # 80008648 <states.0+0x38>
    80003116:	baefd0ef          	jal	ra,800004c4 <printf>
      plic_complete(irq);
    8000311a:	8526                	mv	a0,s1
    8000311c:	7ed020ef          	jal	ra,80006108 <plic_complete>
    return 1;
    80003120:	4505                	li	a0,1
    80003122:	b7e9                	j	800030ec <devintr+0x24>
      uartintr();
    80003124:	835fd0ef          	jal	ra,80000958 <uartintr>
    80003128:	bfcd                	j	8000311a <devintr+0x52>
      virtio_disk_intr();
    8000312a:	44e030ef          	jal	ra,80006578 <virtio_disk_intr>
    8000312e:	b7f5                	j	8000311a <devintr+0x52>
    clockintr();
    80003130:	f45ff0ef          	jal	ra,80003074 <clockintr>
    return 2;
    80003134:	4509                	li	a0,2
    80003136:	bf5d                	j	800030ec <devintr+0x24>

0000000080003138 <usertrap>:
{
    80003138:	7179                	addi	sp,sp,-48
    8000313a:	f406                	sd	ra,40(sp)
    8000313c:	f022                	sd	s0,32(sp)
    8000313e:	ec26                	sd	s1,24(sp)
    80003140:	e84a                	sd	s2,16(sp)
    80003142:	e44e                	sd	s3,8(sp)
    80003144:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003146:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    8000314a:	1007f793          	andi	a5,a5,256
    8000314e:	e3d9                	bnez	a5,800031d4 <usertrap+0x9c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003150:	00003797          	auipc	a5,0x3
    80003154:	ef078793          	addi	a5,a5,-272 # 80006040 <kernelvec>
    80003158:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000315c:	a6cff0ef          	jal	ra,800023c8 <myproc>
    80003160:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80003162:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003164:	14102773          	csrr	a4,sepc
    80003168:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000316a:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    8000316e:	47a1                	li	a5,8
    80003170:	06f70863          	beq	a4,a5,800031e0 <usertrap+0xa8>
  else if ((which_dev = devintr()) != 0)
    80003174:	f55ff0ef          	jal	ra,800030c8 <devintr>
    80003178:	892a                	mv	s2,a0
    8000317a:	10051c63          	bnez	a0,80003292 <usertrap+0x15a>
    8000317e:	14202773          	csrr	a4,scause
} else if(r_scause() == 12 || r_scause() == 13 || r_scause() == 15) {
    80003182:	47b1                	li	a5,12
    80003184:	00f70c63          	beq	a4,a5,8000319c <usertrap+0x64>
    80003188:	14202773          	csrr	a4,scause
    8000318c:	47b5                	li	a5,13
    8000318e:	00f70763          	beq	a4,a5,8000319c <usertrap+0x64>
    80003192:	14202773          	csrr	a4,scause
    80003196:	47bd                	li	a5,15
    80003198:	0cf71663          	bne	a4,a5,80003264 <usertrap+0x12c>
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000319c:	143029f3          	csrr	s3,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    800031a0:	14202973          	csrr	s2,scause
    pte_t *pte = walk(p->pagetable, PGROUNDDOWN(faulting_addr), 0);
    800031a4:	4601                	li	a2,0
    800031a6:	75fd                	lui	a1,0xfffff
    800031a8:	00b9f5b3          	and	a1,s3,a1
    800031ac:	68a8                	ld	a0,80(s1)
    800031ae:	d0ffd0ef          	jal	ra,80000ebc <walk>
    if(pte != 0 && (*pte & PTE_V) != 0) {
    800031b2:	c151                	beqz	a0,80003236 <usertrap+0xfe>
    800031b4:	611c                	ld	a5,0(a0)
    800031b6:	8b85                	andi	a5,a5,1
    800031b8:	cfbd                	beqz	a5,80003236 <usertrap+0xfe>
      if(is_write && handle_write_fault(p->pagetable, faulting_addr) == 0) {
    800031ba:	47bd                	li	a5,15
    800031bc:	06f90763          	beq	s2,a5,8000322a <usertrap+0xf2>
        printf("usertrap(): page fault on existing page\n");
    800031c0:	00005517          	auipc	a0,0x5
    800031c4:	4c850513          	addi	a0,a0,1224 # 80008688 <states.0+0x78>
    800031c8:	afcfd0ef          	jal	ra,800004c4 <printf>
        setkilled(p);
    800031cc:	8526                	mv	a0,s1
    800031ce:	b05ff0ef          	jal	ra,80002cd2 <setkilled>
    800031d2:	a035                	j	800031fe <usertrap+0xc6>
    panic("usertrap: not from user mode");
    800031d4:	00005517          	auipc	a0,0x5
    800031d8:	49450513          	addi	a0,a0,1172 # 80008668 <states.0+0x58>
    800031dc:	daefd0ef          	jal	ra,8000078a <panic>
    if (killed(p))
    800031e0:	b17ff0ef          	jal	ra,80002cf6 <killed>
    800031e4:	ed1d                	bnez	a0,80003222 <usertrap+0xea>
    p->trapframe->epc += 4;
    800031e6:	6cb8                	ld	a4,88(s1)
    800031e8:	6f1c                	ld	a5,24(a4)
    800031ea:	0791                	addi	a5,a5,4
    800031ec:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800031ee:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800031f2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800031f6:	10079073          	csrw	sstatus,a5
    syscall();
    800031fa:	298000ef          	jal	ra,80003492 <syscall>
  if (killed(p))
    800031fe:	8526                	mv	a0,s1
    80003200:	af7ff0ef          	jal	ra,80002cf6 <killed>
    80003204:	ed41                	bnez	a0,8000329c <usertrap+0x164>
  prepare_return();
    80003206:	df5ff0ef          	jal	ra,80002ffa <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000320a:	68a8                	ld	a0,80(s1)
    8000320c:	8131                	srli	a0,a0,0xc
    8000320e:	57fd                	li	a5,-1
    80003210:	17fe                	slli	a5,a5,0x3f
    80003212:	8d5d                	or	a0,a0,a5
}
    80003214:	70a2                	ld	ra,40(sp)
    80003216:	7402                	ld	s0,32(sp)
    80003218:	64e2                	ld	s1,24(sp)
    8000321a:	6942                	ld	s2,16(sp)
    8000321c:	69a2                	ld	s3,8(sp)
    8000321e:	6145                	addi	sp,sp,48
    80003220:	8082                	ret
      kexit(-1);
    80003222:	557d                	li	a0,-1
    80003224:	963ff0ef          	jal	ra,80002b86 <kexit>
    80003228:	bf7d                	j	800031e6 <usertrap+0xae>
      if(is_write && handle_write_fault(p->pagetable, faulting_addr) == 0) {
    8000322a:	85ce                	mv	a1,s3
    8000322c:	68a8                	ld	a0,80(s1)
    8000322e:	80dfe0ef          	jal	ra,80001a3a <handle_write_fault>
    80003232:	d571                	beqz	a0,800031fe <usertrap+0xc6>
    80003234:	b771                	j	800031c0 <usertrap+0x88>
    int is_write = (r_scause() == 15);
    80003236:	ff190613          	addi	a2,s2,-15
  uint64 result = vmfault(p->pagetable, faulting_addr, is_write);
    8000323a:	00163613          	seqz	a2,a2
    8000323e:	85ce                	mv	a1,s3
    80003240:	68a8                	ld	a0,80(s1)
    80003242:	899fe0ef          	jal	ra,80001ada <vmfault>
  if(result == 0 || result == (uint64)-1) {
    80003246:	157d                	addi	a0,a0,-1
    80003248:	57f5                	li	a5,-3
    8000324a:	faa7fae3          	bgeu	a5,a0,800031fe <usertrap+0xc6>
    printf("usertrap(): vmfault failed for addr 0x%lx\n", faulting_addr);
    8000324e:	85ce                	mv	a1,s3
    80003250:	00005517          	auipc	a0,0x5
    80003254:	46850513          	addi	a0,a0,1128 # 800086b8 <states.0+0xa8>
    80003258:	a6cfd0ef          	jal	ra,800004c4 <printf>
    setkilled(p);
    8000325c:	8526                	mv	a0,s1
    8000325e:	a75ff0ef          	jal	ra,80002cd2 <setkilled>
    80003262:	bf71                	j	800031fe <usertrap+0xc6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003264:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80003268:	5890                	lw	a2,48(s1)
    8000326a:	00005517          	auipc	a0,0x5
    8000326e:	47e50513          	addi	a0,a0,1150 # 800086e8 <states.0+0xd8>
    80003272:	a52fd0ef          	jal	ra,800004c4 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003276:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000327a:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000327e:	00005517          	auipc	a0,0x5
    80003282:	49a50513          	addi	a0,a0,1178 # 80008718 <states.0+0x108>
    80003286:	a3efd0ef          	jal	ra,800004c4 <printf>
    setkilled(p);
    8000328a:	8526                	mv	a0,s1
    8000328c:	a47ff0ef          	jal	ra,80002cd2 <setkilled>
    80003290:	b7bd                	j	800031fe <usertrap+0xc6>
  if (killed(p))
    80003292:	8526                	mv	a0,s1
    80003294:	a63ff0ef          	jal	ra,80002cf6 <killed>
    80003298:	c511                	beqz	a0,800032a4 <usertrap+0x16c>
    8000329a:	a011                	j	8000329e <usertrap+0x166>
    8000329c:	4901                	li	s2,0
    kexit(-1);
    8000329e:	557d                	li	a0,-1
    800032a0:	8e7ff0ef          	jal	ra,80002b86 <kexit>
  if (which_dev == 2)
    800032a4:	4789                	li	a5,2
    800032a6:	f6f910e3          	bne	s2,a5,80003206 <usertrap+0xce>
    yield();
    800032aa:	f94ff0ef          	jal	ra,80002a3e <yield>
    800032ae:	bfa1                	j	80003206 <usertrap+0xce>

00000000800032b0 <kerneltrap>:
{
    800032b0:	7179                	addi	sp,sp,-48
    800032b2:	f406                	sd	ra,40(sp)
    800032b4:	f022                	sd	s0,32(sp)
    800032b6:	ec26                	sd	s1,24(sp)
    800032b8:	e84a                	sd	s2,16(sp)
    800032ba:	e44e                	sd	s3,8(sp)
    800032bc:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800032be:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800032c2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800032c6:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    800032ca:	1004f793          	andi	a5,s1,256
    800032ce:	c795                	beqz	a5,800032fa <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800032d0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800032d4:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    800032d6:	eb85                	bnez	a5,80003306 <kerneltrap+0x56>
  if ((which_dev = devintr()) == 0)
    800032d8:	df1ff0ef          	jal	ra,800030c8 <devintr>
    800032dc:	c91d                	beqz	a0,80003312 <kerneltrap+0x62>
  if (which_dev == 2 && myproc() != 0)
    800032de:	4789                	li	a5,2
    800032e0:	04f50a63          	beq	a0,a5,80003334 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800032e4:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800032e8:	10049073          	csrw	sstatus,s1
}
    800032ec:	70a2                	ld	ra,40(sp)
    800032ee:	7402                	ld	s0,32(sp)
    800032f0:	64e2                	ld	s1,24(sp)
    800032f2:	6942                	ld	s2,16(sp)
    800032f4:	69a2                	ld	s3,8(sp)
    800032f6:	6145                	addi	sp,sp,48
    800032f8:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800032fa:	00005517          	auipc	a0,0x5
    800032fe:	44650513          	addi	a0,a0,1094 # 80008740 <states.0+0x130>
    80003302:	c88fd0ef          	jal	ra,8000078a <panic>
    panic("kerneltrap: interrupts enabled");
    80003306:	00005517          	auipc	a0,0x5
    8000330a:	46250513          	addi	a0,a0,1122 # 80008768 <states.0+0x158>
    8000330e:	c7cfd0ef          	jal	ra,8000078a <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003312:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003316:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    8000331a:	85ce                	mv	a1,s3
    8000331c:	00005517          	auipc	a0,0x5
    80003320:	46c50513          	addi	a0,a0,1132 # 80008788 <states.0+0x178>
    80003324:	9a0fd0ef          	jal	ra,800004c4 <printf>
    panic("kerneltrap");
    80003328:	00005517          	auipc	a0,0x5
    8000332c:	48850513          	addi	a0,a0,1160 # 800087b0 <states.0+0x1a0>
    80003330:	c5afd0ef          	jal	ra,8000078a <panic>
  if (which_dev == 2 && myproc() != 0)
    80003334:	894ff0ef          	jal	ra,800023c8 <myproc>
    80003338:	d555                	beqz	a0,800032e4 <kerneltrap+0x34>
    yield();
    8000333a:	f04ff0ef          	jal	ra,80002a3e <yield>
    8000333e:	b75d                	j	800032e4 <kerneltrap+0x34>

0000000080003340 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003340:	1101                	addi	sp,sp,-32
    80003342:	ec06                	sd	ra,24(sp)
    80003344:	e822                	sd	s0,16(sp)
    80003346:	e426                	sd	s1,8(sp)
    80003348:	1000                	addi	s0,sp,32
    8000334a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000334c:	87cff0ef          	jal	ra,800023c8 <myproc>
  switch (n) {
    80003350:	4795                	li	a5,5
    80003352:	0497e163          	bltu	a5,s1,80003394 <argraw+0x54>
    80003356:	048a                	slli	s1,s1,0x2
    80003358:	00005717          	auipc	a4,0x5
    8000335c:	49070713          	addi	a4,a4,1168 # 800087e8 <states.0+0x1d8>
    80003360:	94ba                	add	s1,s1,a4
    80003362:	409c                	lw	a5,0(s1)
    80003364:	97ba                	add	a5,a5,a4
    80003366:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80003368:	6d3c                	ld	a5,88(a0)
    8000336a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000336c:	60e2                	ld	ra,24(sp)
    8000336e:	6442                	ld	s0,16(sp)
    80003370:	64a2                	ld	s1,8(sp)
    80003372:	6105                	addi	sp,sp,32
    80003374:	8082                	ret
    return p->trapframe->a1;
    80003376:	6d3c                	ld	a5,88(a0)
    80003378:	7fa8                	ld	a0,120(a5)
    8000337a:	bfcd                	j	8000336c <argraw+0x2c>
    return p->trapframe->a2;
    8000337c:	6d3c                	ld	a5,88(a0)
    8000337e:	63c8                	ld	a0,128(a5)
    80003380:	b7f5                	j	8000336c <argraw+0x2c>
    return p->trapframe->a3;
    80003382:	6d3c                	ld	a5,88(a0)
    80003384:	67c8                	ld	a0,136(a5)
    80003386:	b7dd                	j	8000336c <argraw+0x2c>
    return p->trapframe->a4;
    80003388:	6d3c                	ld	a5,88(a0)
    8000338a:	6bc8                	ld	a0,144(a5)
    8000338c:	b7c5                	j	8000336c <argraw+0x2c>
    return p->trapframe->a5;
    8000338e:	6d3c                	ld	a5,88(a0)
    80003390:	6fc8                	ld	a0,152(a5)
    80003392:	bfe9                	j	8000336c <argraw+0x2c>
  panic("argraw");
    80003394:	00005517          	auipc	a0,0x5
    80003398:	42c50513          	addi	a0,a0,1068 # 800087c0 <states.0+0x1b0>
    8000339c:	beefd0ef          	jal	ra,8000078a <panic>

00000000800033a0 <fetchaddr>:
{
    800033a0:	1101                	addi	sp,sp,-32
    800033a2:	ec06                	sd	ra,24(sp)
    800033a4:	e822                	sd	s0,16(sp)
    800033a6:	e426                	sd	s1,8(sp)
    800033a8:	e04a                	sd	s2,0(sp)
    800033aa:	1000                	addi	s0,sp,32
    800033ac:	84aa                	mv	s1,a0
    800033ae:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800033b0:	818ff0ef          	jal	ra,800023c8 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800033b4:	653c                	ld	a5,72(a0)
    800033b6:	02f4f663          	bgeu	s1,a5,800033e2 <fetchaddr+0x42>
    800033ba:	00848713          	addi	a4,s1,8
    800033be:	02e7e463          	bltu	a5,a4,800033e6 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800033c2:	46a1                	li	a3,8
    800033c4:	8626                	mv	a2,s1
    800033c6:	85ca                	mv	a1,s2
    800033c8:	6928                	ld	a0,80(a0)
    800033ca:	e03fe0ef          	jal	ra,800021cc <copyin>
    800033ce:	00a03533          	snez	a0,a0
    800033d2:	40a00533          	neg	a0,a0
}
    800033d6:	60e2                	ld	ra,24(sp)
    800033d8:	6442                	ld	s0,16(sp)
    800033da:	64a2                	ld	s1,8(sp)
    800033dc:	6902                	ld	s2,0(sp)
    800033de:	6105                	addi	sp,sp,32
    800033e0:	8082                	ret
    return -1;
    800033e2:	557d                	li	a0,-1
    800033e4:	bfcd                	j	800033d6 <fetchaddr+0x36>
    800033e6:	557d                	li	a0,-1
    800033e8:	b7fd                	j	800033d6 <fetchaddr+0x36>

00000000800033ea <fetchstr>:
{
    800033ea:	7179                	addi	sp,sp,-48
    800033ec:	f406                	sd	ra,40(sp)
    800033ee:	f022                	sd	s0,32(sp)
    800033f0:	ec26                	sd	s1,24(sp)
    800033f2:	e84a                	sd	s2,16(sp)
    800033f4:	e44e                	sd	s3,8(sp)
    800033f6:	1800                	addi	s0,sp,48
    800033f8:	892a                	mv	s2,a0
    800033fa:	84ae                	mv	s1,a1
    800033fc:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800033fe:	fcbfe0ef          	jal	ra,800023c8 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80003402:	86ce                	mv	a3,s3
    80003404:	864a                	mv	a2,s2
    80003406:	85a6                	mv	a1,s1
    80003408:	6928                	ld	a0,80(a0)
    8000340a:	806fe0ef          	jal	ra,80001410 <copyinstr>
    8000340e:	00054c63          	bltz	a0,80003426 <fetchstr+0x3c>
  return strlen(buf);
    80003412:	8526                	mv	a0,s1
    80003414:	9a5fd0ef          	jal	ra,80000db8 <strlen>
}
    80003418:	70a2                	ld	ra,40(sp)
    8000341a:	7402                	ld	s0,32(sp)
    8000341c:	64e2                	ld	s1,24(sp)
    8000341e:	6942                	ld	s2,16(sp)
    80003420:	69a2                	ld	s3,8(sp)
    80003422:	6145                	addi	sp,sp,48
    80003424:	8082                	ret
    return -1;
    80003426:	557d                	li	a0,-1
    80003428:	bfc5                	j	80003418 <fetchstr+0x2e>

000000008000342a <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000342a:	1101                	addi	sp,sp,-32
    8000342c:	ec06                	sd	ra,24(sp)
    8000342e:	e822                	sd	s0,16(sp)
    80003430:	e426                	sd	s1,8(sp)
    80003432:	1000                	addi	s0,sp,32
    80003434:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003436:	f0bff0ef          	jal	ra,80003340 <argraw>
    8000343a:	c088                	sw	a0,0(s1)
}
    8000343c:	60e2                	ld	ra,24(sp)
    8000343e:	6442                	ld	s0,16(sp)
    80003440:	64a2                	ld	s1,8(sp)
    80003442:	6105                	addi	sp,sp,32
    80003444:	8082                	ret

0000000080003446 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80003446:	1101                	addi	sp,sp,-32
    80003448:	ec06                	sd	ra,24(sp)
    8000344a:	e822                	sd	s0,16(sp)
    8000344c:	e426                	sd	s1,8(sp)
    8000344e:	1000                	addi	s0,sp,32
    80003450:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003452:	eefff0ef          	jal	ra,80003340 <argraw>
    80003456:	e088                	sd	a0,0(s1)
}
    80003458:	60e2                	ld	ra,24(sp)
    8000345a:	6442                	ld	s0,16(sp)
    8000345c:	64a2                	ld	s1,8(sp)
    8000345e:	6105                	addi	sp,sp,32
    80003460:	8082                	ret

0000000080003462 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003462:	7179                	addi	sp,sp,-48
    80003464:	f406                	sd	ra,40(sp)
    80003466:	f022                	sd	s0,32(sp)
    80003468:	ec26                	sd	s1,24(sp)
    8000346a:	e84a                	sd	s2,16(sp)
    8000346c:	1800                	addi	s0,sp,48
    8000346e:	84ae                	mv	s1,a1
    80003470:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80003472:	fd840593          	addi	a1,s0,-40
    80003476:	fd1ff0ef          	jal	ra,80003446 <argaddr>
  return fetchstr(addr, buf, max);
    8000347a:	864a                	mv	a2,s2
    8000347c:	85a6                	mv	a1,s1
    8000347e:	fd843503          	ld	a0,-40(s0)
    80003482:	f69ff0ef          	jal	ra,800033ea <fetchstr>
}
    80003486:	70a2                	ld	ra,40(sp)
    80003488:	7402                	ld	s0,32(sp)
    8000348a:	64e2                	ld	s1,24(sp)
    8000348c:	6942                	ld	s2,16(sp)
    8000348e:	6145                	addi	sp,sp,48
    80003490:	8082                	ret

0000000080003492 <syscall>:
[SYS_memstat] sys_memstat,  // ADD THIS
};

void
syscall(void)
{
    80003492:	1101                	addi	sp,sp,-32
    80003494:	ec06                	sd	ra,24(sp)
    80003496:	e822                	sd	s0,16(sp)
    80003498:	e426                	sd	s1,8(sp)
    8000349a:	e04a                	sd	s2,0(sp)
    8000349c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000349e:	f2bfe0ef          	jal	ra,800023c8 <myproc>
    800034a2:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800034a4:	05853903          	ld	s2,88(a0)
    800034a8:	0a893783          	ld	a5,168(s2)
    800034ac:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800034b0:	37fd                	addiw	a5,a5,-1
    800034b2:	4755                	li	a4,21
    800034b4:	00f76f63          	bltu	a4,a5,800034d2 <syscall+0x40>
    800034b8:	00369713          	slli	a4,a3,0x3
    800034bc:	00005797          	auipc	a5,0x5
    800034c0:	34478793          	addi	a5,a5,836 # 80008800 <syscalls>
    800034c4:	97ba                	add	a5,a5,a4
    800034c6:	639c                	ld	a5,0(a5)
    800034c8:	c789                	beqz	a5,800034d2 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800034ca:	9782                	jalr	a5
    800034cc:	06a93823          	sd	a0,112(s2)
    800034d0:	a829                	j	800034ea <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800034d2:	15848613          	addi	a2,s1,344
    800034d6:	588c                	lw	a1,48(s1)
    800034d8:	00005517          	auipc	a0,0x5
    800034dc:	2f050513          	addi	a0,a0,752 # 800087c8 <states.0+0x1b8>
    800034e0:	fe5fc0ef          	jal	ra,800004c4 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800034e4:	6cbc                	ld	a5,88(s1)
    800034e6:	577d                	li	a4,-1
    800034e8:	fbb8                	sd	a4,112(a5)
  }
}
    800034ea:	60e2                	ld	ra,24(sp)
    800034ec:	6442                	ld	s0,16(sp)
    800034ee:	64a2                	ld	s1,8(sp)
    800034f0:	6902                	ld	s2,0(sp)
    800034f2:	6105                	addi	sp,sp,32
    800034f4:	8082                	ret

00000000800034f6 <sys_exit>:
#include "memstat.h"


uint64
sys_exit(void)
{
    800034f6:	1101                	addi	sp,sp,-32
    800034f8:	ec06                	sd	ra,24(sp)
    800034fa:	e822                	sd	s0,16(sp)
    800034fc:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800034fe:	fec40593          	addi	a1,s0,-20
    80003502:	4501                	li	a0,0
    80003504:	f27ff0ef          	jal	ra,8000342a <argint>
  kexit(n);
    80003508:	fec42503          	lw	a0,-20(s0)
    8000350c:	e7aff0ef          	jal	ra,80002b86 <kexit>
  return 0;  // not reached
}
    80003510:	4501                	li	a0,0
    80003512:	60e2                	ld	ra,24(sp)
    80003514:	6442                	ld	s0,16(sp)
    80003516:	6105                	addi	sp,sp,32
    80003518:	8082                	ret

000000008000351a <sys_getpid>:

uint64
sys_getpid(void)
{
    8000351a:	1141                	addi	sp,sp,-16
    8000351c:	e406                	sd	ra,8(sp)
    8000351e:	e022                	sd	s0,0(sp)
    80003520:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003522:	ea7fe0ef          	jal	ra,800023c8 <myproc>
}
    80003526:	5908                	lw	a0,48(a0)
    80003528:	60a2                	ld	ra,8(sp)
    8000352a:	6402                	ld	s0,0(sp)
    8000352c:	0141                	addi	sp,sp,16
    8000352e:	8082                	ret

0000000080003530 <sys_fork>:

uint64
sys_fork(void)
{
    80003530:	1141                	addi	sp,sp,-16
    80003532:	e406                	sd	ra,8(sp)
    80003534:	e022                	sd	s0,0(sp)
    80003536:	0800                	addi	s0,sp,16
  return kfork();
    80003538:	a88ff0ef          	jal	ra,800027c0 <kfork>
}
    8000353c:	60a2                	ld	ra,8(sp)
    8000353e:	6402                	ld	s0,0(sp)
    80003540:	0141                	addi	sp,sp,16
    80003542:	8082                	ret

0000000080003544 <sys_wait>:

uint64
sys_wait(void)
{
    80003544:	1101                	addi	sp,sp,-32
    80003546:	ec06                	sd	ra,24(sp)
    80003548:	e822                	sd	s0,16(sp)
    8000354a:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    8000354c:	fe840593          	addi	a1,s0,-24
    80003550:	4501                	li	a0,0
    80003552:	ef5ff0ef          	jal	ra,80003446 <argaddr>
  return kwait(p);
    80003556:	fe843503          	ld	a0,-24(s0)
    8000355a:	fc6ff0ef          	jal	ra,80002d20 <kwait>
}
    8000355e:	60e2                	ld	ra,24(sp)
    80003560:	6442                	ld	s0,16(sp)
    80003562:	6105                	addi	sp,sp,32
    80003564:	8082                	ret

0000000080003566 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003566:	7179                	addi	sp,sp,-48
    80003568:	f406                	sd	ra,40(sp)
    8000356a:	f022                	sd	s0,32(sp)
    8000356c:	ec26                	sd	s1,24(sp)
    8000356e:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80003570:	fd840593          	addi	a1,s0,-40
    80003574:	4501                	li	a0,0
    80003576:	eb5ff0ef          	jal	ra,8000342a <argint>
  argint(1, &t);
    8000357a:	fdc40593          	addi	a1,s0,-36
    8000357e:	4505                	li	a0,1
    80003580:	eabff0ef          	jal	ra,8000342a <argint>
  addr = myproc()->sz;
    80003584:	e45fe0ef          	jal	ra,800023c8 <myproc>
    80003588:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    8000358a:	fdc42703          	lw	a4,-36(s0)
    8000358e:	4785                	li	a5,1
    80003590:	02f70163          	beq	a4,a5,800035b2 <sys_sbrk+0x4c>
    80003594:	fd842783          	lw	a5,-40(s0)
    80003598:	0007cd63          	bltz	a5,800035b2 <sys_sbrk+0x4c>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    8000359c:	97a6                	add	a5,a5,s1
    8000359e:	0297e863          	bltu	a5,s1,800035ce <sys_sbrk+0x68>
      return -1;
    myproc()->sz += n;
    800035a2:	e27fe0ef          	jal	ra,800023c8 <myproc>
    800035a6:	fd842703          	lw	a4,-40(s0)
    800035aa:	653c                	ld	a5,72(a0)
    800035ac:	97ba                	add	a5,a5,a4
    800035ae:	e53c                	sd	a5,72(a0)
    800035b0:	a039                	j	800035be <sys_sbrk+0x58>
    if(growproc(n) < 0) {
    800035b2:	fd842503          	lw	a0,-40(s0)
    800035b6:	9baff0ef          	jal	ra,80002770 <growproc>
    800035ba:	00054863          	bltz	a0,800035ca <sys_sbrk+0x64>
  }
  return addr;
}
    800035be:	8526                	mv	a0,s1
    800035c0:	70a2                	ld	ra,40(sp)
    800035c2:	7402                	ld	s0,32(sp)
    800035c4:	64e2                	ld	s1,24(sp)
    800035c6:	6145                	addi	sp,sp,48
    800035c8:	8082                	ret
      return -1;
    800035ca:	54fd                	li	s1,-1
    800035cc:	bfcd                	j	800035be <sys_sbrk+0x58>
      return -1;
    800035ce:	54fd                	li	s1,-1
    800035d0:	b7fd                	j	800035be <sys_sbrk+0x58>

00000000800035d2 <sys_pause>:

uint64
sys_pause(void)
{
    800035d2:	7139                	addi	sp,sp,-64
    800035d4:	fc06                	sd	ra,56(sp)
    800035d6:	f822                	sd	s0,48(sp)
    800035d8:	f426                	sd	s1,40(sp)
    800035da:	f04a                	sd	s2,32(sp)
    800035dc:	ec4e                	sd	s3,24(sp)
    800035de:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800035e0:	fcc40593          	addi	a1,s0,-52
    800035e4:	4501                	li	a0,0
    800035e6:	e45ff0ef          	jal	ra,8000342a <argint>
  if(n < 0)
    800035ea:	fcc42783          	lw	a5,-52(s0)
    800035ee:	0607c563          	bltz	a5,80003658 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    800035f2:	0007e517          	auipc	a0,0x7e
    800035f6:	85650513          	addi	a0,a0,-1962 # 80080e48 <tickslock>
    800035fa:	d72fd0ef          	jal	ra,80000b6c <acquire>
  ticks0 = ticks;
    800035fe:	00005917          	auipc	s2,0x5
    80003602:	71a92903          	lw	s2,1818(s2) # 80008d18 <ticks>
  while(ticks - ticks0 < n){
    80003606:	fcc42783          	lw	a5,-52(s0)
    8000360a:	cb8d                	beqz	a5,8000363c <sys_pause+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000360c:	0007e997          	auipc	s3,0x7e
    80003610:	83c98993          	addi	s3,s3,-1988 # 80080e48 <tickslock>
    80003614:	00005497          	auipc	s1,0x5
    80003618:	70448493          	addi	s1,s1,1796 # 80008d18 <ticks>
    if(killed(myproc())){
    8000361c:	dadfe0ef          	jal	ra,800023c8 <myproc>
    80003620:	ed6ff0ef          	jal	ra,80002cf6 <killed>
    80003624:	ed0d                	bnez	a0,8000365e <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80003626:	85ce                	mv	a1,s3
    80003628:	8526                	mv	a0,s1
    8000362a:	c40ff0ef          	jal	ra,80002a6a <sleep>
  while(ticks - ticks0 < n){
    8000362e:	409c                	lw	a5,0(s1)
    80003630:	412787bb          	subw	a5,a5,s2
    80003634:	fcc42703          	lw	a4,-52(s0)
    80003638:	fee7e2e3          	bltu	a5,a4,8000361c <sys_pause+0x4a>
  }
  release(&tickslock);
    8000363c:	0007e517          	auipc	a0,0x7e
    80003640:	80c50513          	addi	a0,a0,-2036 # 80080e48 <tickslock>
    80003644:	dc0fd0ef          	jal	ra,80000c04 <release>
  return 0;
    80003648:	4501                	li	a0,0
}
    8000364a:	70e2                	ld	ra,56(sp)
    8000364c:	7442                	ld	s0,48(sp)
    8000364e:	74a2                	ld	s1,40(sp)
    80003650:	7902                	ld	s2,32(sp)
    80003652:	69e2                	ld	s3,24(sp)
    80003654:	6121                	addi	sp,sp,64
    80003656:	8082                	ret
    n = 0;
    80003658:	fc042623          	sw	zero,-52(s0)
    8000365c:	bf59                	j	800035f2 <sys_pause+0x20>
      release(&tickslock);
    8000365e:	0007d517          	auipc	a0,0x7d
    80003662:	7ea50513          	addi	a0,a0,2026 # 80080e48 <tickslock>
    80003666:	d9efd0ef          	jal	ra,80000c04 <release>
      return -1;
    8000366a:	557d                	li	a0,-1
    8000366c:	bff9                	j	8000364a <sys_pause+0x78>

000000008000366e <sys_kill>:

uint64
sys_kill(void)
{
    8000366e:	1101                	addi	sp,sp,-32
    80003670:	ec06                	sd	ra,24(sp)
    80003672:	e822                	sd	s0,16(sp)
    80003674:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003676:	fec40593          	addi	a1,s0,-20
    8000367a:	4501                	li	a0,0
    8000367c:	dafff0ef          	jal	ra,8000342a <argint>
  return kkill(pid);
    80003680:	fec42503          	lw	a0,-20(s0)
    80003684:	de0ff0ef          	jal	ra,80002c64 <kkill>
}
    80003688:	60e2                	ld	ra,24(sp)
    8000368a:	6442                	ld	s0,16(sp)
    8000368c:	6105                	addi	sp,sp,32
    8000368e:	8082                	ret

0000000080003690 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003690:	1101                	addi	sp,sp,-32
    80003692:	ec06                	sd	ra,24(sp)
    80003694:	e822                	sd	s0,16(sp)
    80003696:	e426                	sd	s1,8(sp)
    80003698:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000369a:	0007d517          	auipc	a0,0x7d
    8000369e:	7ae50513          	addi	a0,a0,1966 # 80080e48 <tickslock>
    800036a2:	ccafd0ef          	jal	ra,80000b6c <acquire>
  xticks = ticks;
    800036a6:	00005497          	auipc	s1,0x5
    800036aa:	6724a483          	lw	s1,1650(s1) # 80008d18 <ticks>
  release(&tickslock);
    800036ae:	0007d517          	auipc	a0,0x7d
    800036b2:	79a50513          	addi	a0,a0,1946 # 80080e48 <tickslock>
    800036b6:	d4efd0ef          	jal	ra,80000c04 <release>
  return xticks;
}
    800036ba:	02049513          	slli	a0,s1,0x20
    800036be:	9101                	srli	a0,a0,0x20
    800036c0:	60e2                	ld	ra,24(sp)
    800036c2:	6442                	ld	s0,16(sp)
    800036c4:	64a2                	ld	s1,8(sp)
    800036c6:	6105                	addi	sp,sp,32
    800036c8:	8082                	ret

00000000800036ca <sys_memstat>:


uint64
sys_memstat(void)
{
    800036ca:	81010113          	addi	sp,sp,-2032
    800036ce:	7e113423          	sd	ra,2024(sp)
    800036d2:	7e813023          	sd	s0,2016(sp)
    800036d6:	7c913c23          	sd	s1,2008(sp)
    800036da:	7f010413          	addi	s0,sp,2032
    800036de:	db010113          	addi	sp,sp,-592
  uint64 addr;
  struct proc *p = myproc();
    800036e2:	ce7fe0ef          	jal	ra,800023c8 <myproc>
    800036e6:	84aa                	mv	s1,a0
  struct proc_mem_stat stat;
  
  // Get user address where to store results
  argaddr(0, &addr);
    800036e8:	fd840593          	addi	a1,s0,-40
    800036ec:	4501                	li	a0,0
    800036ee:	d59ff0ef          	jal	ra,80003446 <argaddr>
  
  // Fill in basic info
  stat.pid = p->pid;
    800036f2:	777d                	lui	a4,0xfffff
    800036f4:	fe040793          	addi	a5,s0,-32
    800036f8:	973e                	add	a4,a4,a5
    800036fa:	589c                	lw	a5,48(s1)
    800036fc:	5ef72023          	sw	a5,1504(a4) # fffffffffffff5e0 <end+0xffffffff7ff733b8>
  stat.num_resident_pages = p->num_resident;
    80003700:	7c04a783          	lw	a5,1984(s1)
    80003704:	5ef72423          	sw	a5,1512(a4)
  stat.num_swapped_pages = p->num_swapped;
    80003708:	6685                	lui	a3,0x1
    8000370a:	00d487b3          	add	a5,s1,a3
    8000370e:	bc87a803          	lw	a6,-1080(a5)
    80003712:	5f072623          	sw	a6,1516(a4)
  stat.next_fifo_seq = p->next_fifo_seq;
    80003716:	1904a783          	lw	a5,400(s1)
    8000371a:	5ef72823          	sw	a5,1520(a4)
  
  // Calculate total pages (from 0 to p->sz)
  stat.num_pages_total = PGROUNDUP(p->sz) / PGSIZE;
    8000371e:	64bc                	ld	a5,72(s1)
    80003720:	16fd                	addi	a3,a3,-1
    80003722:	97b6                	add	a5,a5,a3
    80003724:	83b1                	srli	a5,a5,0xc
    80003726:	2781                	sext.w	a5,a5
    80003728:	5ef72223          	sw	a5,1508(a4)
  
  // Limit to MAX_PAGES_INFO
  int num_to_report = stat.num_pages_total;
  if(num_to_report > MAX_PAGES_INFO)
    8000372c:	8f3e                	mv	t5,a5
    8000372e:	08000713          	li	a4,128
    80003732:	00f75463          	bge	a4,a5,8000373a <sys_memstat+0x70>
    80003736:	08000f13          	li	t5,128
    8000373a:	2f01                	sext.w	t5,t5
    num_to_report = MAX_PAGES_INFO;
  
  // Fill in page information
  for(int i = 0; i < num_to_report; i++) {
    8000373c:	0af05763          	blez	a5,800037ea <sys_memstat+0x120>
    80003740:	757d                	lui	a0,0xfffff
    80003742:	fe040793          	addi	a5,s0,-32
    80003746:	953e                	add	a0,a0,a5
    80003748:	5f450513          	addi	a0,a0,1524 # fffffffffffff5f4 <end+0xffffffff7ff733cc>
    8000374c:	4601                	li	a2,0
    8000374e:	4881                	li	a7,0
    uint64 va = i * PGSIZE;
    stat.pages[i].va = va;
    stat.pages[i].state = UNMAPPED;
    stat.pages[i].is_dirty = 0;
    stat.pages[i].seq = -1;
    80003750:	5e7d                	li	t3,-1
      }
    }
    
    // If not resident, check if swapped
    if(!found_resident) {
      for(int j = 0; j < p->num_swapped; j++) {
    80003752:	4e81                	li	t4,0
        if(p->swapped_pages[j].va == va) {
          stat.pages[i].state = SWAPPED;
    80003754:	4389                	li	t2,2
        stat.pages[i].state = RESIDENT;
    80003756:	4285                	li	t0,1
  for(int i = 0; i < num_to_report; i++) {
    80003758:	6f85                	lui	t6,0x1
    8000375a:	a80d                	j	8000378c <sys_memstat+0xc2>
        stat.pages[i].state = RESIDENT;
    8000375c:	00532223          	sw	t0,4(t1)
        stat.pages[i].is_dirty = p->resident_pages[j].is_dirty;
    80003760:	00179713          	slli	a4,a5,0x1
    80003764:	00f706b3          	add	a3,a4,a5
    80003768:	068e                	slli	a3,a3,0x3
    8000376a:	96a6                	add	a3,a3,s1
    8000376c:	1cc6a683          	lw	a3,460(a3) # 11cc <_entry-0x7fffee34>
    80003770:	00d32423          	sw	a3,8(t1)
        stat.pages[i].seq = p->resident_pages[j].seq;
    80003774:	97ba                	add	a5,a5,a4
    80003776:	078e                	slli	a5,a5,0x3
    80003778:	97a6                	add	a5,a5,s1
    8000377a:	1c87a783          	lw	a5,456(a5)
    8000377e:	00f32623          	sw	a5,12(t1)
  for(int i = 0; i < num_to_report; i++) {
    80003782:	2885                	addiw	a7,a7,1
    80003784:	0551                	addi	a0,a0,20
    80003786:	967e                	add	a2,a2,t6
    80003788:	07e8d163          	bge	a7,t5,800037ea <sys_memstat+0x120>
    stat.pages[i].va = va;
    8000378c:	832a                	mv	t1,a0
    8000378e:	c110                	sw	a2,0(a0)
    stat.pages[i].state = UNMAPPED;
    80003790:	00052223          	sw	zero,4(a0)
    stat.pages[i].is_dirty = 0;
    80003794:	00052423          	sw	zero,8(a0)
    stat.pages[i].seq = -1;
    80003798:	01c52623          	sw	t3,12(a0)
    stat.pages[i].swap_slot = -1;
    8000379c:	01c52823          	sw	t3,16(a0)
    for(int j = 0; j < p->num_resident; j++) {
    800037a0:	7c04a583          	lw	a1,1984(s1)
    800037a4:	00b05c63          	blez	a1,800037bc <sys_memstat+0xf2>
    800037a8:	1c048713          	addi	a4,s1,448
    800037ac:	87f6                	mv	a5,t4
      if(p->resident_pages[j].va == va) {
    800037ae:	6314                	ld	a3,0(a4)
    800037b0:	fac686e3          	beq	a3,a2,8000375c <sys_memstat+0x92>
    for(int j = 0; j < p->num_resident; j++) {
    800037b4:	2785                	addiw	a5,a5,1
    800037b6:	0761                	addi	a4,a4,24
    800037b8:	feb79be3          	bne	a5,a1,800037ae <sys_memstat+0xe4>
      for(int j = 0; j < p->num_swapped; j++) {
    800037bc:	fd0053e3          	blez	a6,80003782 <sys_memstat+0xb8>
    800037c0:	7c848713          	addi	a4,s1,1992
    800037c4:	87f6                	mv	a5,t4
        if(p->swapped_pages[j].va == va) {
    800037c6:	6314                	ld	a3,0(a4)
    800037c8:	00c68763          	beq	a3,a2,800037d6 <sys_memstat+0x10c>
      for(int j = 0; j < p->num_swapped; j++) {
    800037cc:	2785                	addiw	a5,a5,1
    800037ce:	0741                	addi	a4,a4,16
    800037d0:	fef81be3          	bne	a6,a5,800037c6 <sys_memstat+0xfc>
    800037d4:	b77d                	j	80003782 <sys_memstat+0xb8>
          stat.pages[i].state = SWAPPED;
    800037d6:	00732223          	sw	t2,4(t1)
          stat.pages[i].swap_slot = p->swapped_pages[j].swap_slot;
    800037da:	07c78793          	addi	a5,a5,124
    800037de:	0792                	slli	a5,a5,0x4
    800037e0:	97a6                	add	a5,a5,s1
    800037e2:	4b9c                	lw	a5,16(a5)
    800037e4:	00f32823          	sw	a5,16(t1)
          break;
    800037e8:	bf69                	j	80003782 <sys_memstat+0xb8>
      }
    }
  }
  
  // Copy result to user space
  if(copyout(p->pagetable, addr, (char*)&stat, sizeof(stat)) < 0)
    800037ea:	6685                	lui	a3,0x1
    800037ec:	a1468693          	addi	a3,a3,-1516 # a14 <_entry-0x7ffff5ec>
    800037f0:	767d                	lui	a2,0xfffff
    800037f2:	5e060613          	addi	a2,a2,1504 # fffffffffffff5e0 <end+0xffffffff7ff733b8>
    800037f6:	fe040793          	addi	a5,s0,-32
    800037fa:	963e                	add	a2,a2,a5
    800037fc:	fd843583          	ld	a1,-40(s0)
    80003800:	68a8                	ld	a0,80(s1)
    80003802:	8e5fe0ef          	jal	ra,800020e6 <copyout>
    return -1;
  
  return 0;
}
    80003806:	957d                	srai	a0,a0,0x3f
    80003808:	25010113          	addi	sp,sp,592
    8000380c:	7e813083          	ld	ra,2024(sp)
    80003810:	7e013403          	ld	s0,2016(sp)
    80003814:	7d813483          	ld	s1,2008(sp)
    80003818:	7f010113          	addi	sp,sp,2032
    8000381c:	8082                	ret

000000008000381e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000381e:	7179                	addi	sp,sp,-48
    80003820:	f406                	sd	ra,40(sp)
    80003822:	f022                	sd	s0,32(sp)
    80003824:	ec26                	sd	s1,24(sp)
    80003826:	e84a                	sd	s2,16(sp)
    80003828:	e44e                	sd	s3,8(sp)
    8000382a:	e052                	sd	s4,0(sp)
    8000382c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000382e:	00005597          	auipc	a1,0x5
    80003832:	08a58593          	addi	a1,a1,138 # 800088b8 <syscalls+0xb8>
    80003836:	0007d517          	auipc	a0,0x7d
    8000383a:	62a50513          	addi	a0,a0,1578 # 80080e60 <bcache>
    8000383e:	aaefd0ef          	jal	ra,80000aec <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003842:	00085797          	auipc	a5,0x85
    80003846:	61e78793          	addi	a5,a5,1566 # 80088e60 <bcache+0x8000>
    8000384a:	00086717          	auipc	a4,0x86
    8000384e:	87e70713          	addi	a4,a4,-1922 # 800890c8 <bcache+0x8268>
    80003852:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003856:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000385a:	0007d497          	auipc	s1,0x7d
    8000385e:	61e48493          	addi	s1,s1,1566 # 80080e78 <bcache+0x18>
    b->next = bcache.head.next;
    80003862:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003864:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003866:	00005a17          	auipc	s4,0x5
    8000386a:	05aa0a13          	addi	s4,s4,90 # 800088c0 <syscalls+0xc0>
    b->next = bcache.head.next;
    8000386e:	2b893783          	ld	a5,696(s2)
    80003872:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003874:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003878:	85d2                	mv	a1,s4
    8000387a:	01048513          	addi	a0,s1,16
    8000387e:	2fe010ef          	jal	ra,80004b7c <initsleeplock>
    bcache.head.next->prev = b;
    80003882:	2b893783          	ld	a5,696(s2)
    80003886:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003888:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000388c:	45848493          	addi	s1,s1,1112
    80003890:	fd349fe3          	bne	s1,s3,8000386e <binit+0x50>
  }
}
    80003894:	70a2                	ld	ra,40(sp)
    80003896:	7402                	ld	s0,32(sp)
    80003898:	64e2                	ld	s1,24(sp)
    8000389a:	6942                	ld	s2,16(sp)
    8000389c:	69a2                	ld	s3,8(sp)
    8000389e:	6a02                	ld	s4,0(sp)
    800038a0:	6145                	addi	sp,sp,48
    800038a2:	8082                	ret

00000000800038a4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800038a4:	7179                	addi	sp,sp,-48
    800038a6:	f406                	sd	ra,40(sp)
    800038a8:	f022                	sd	s0,32(sp)
    800038aa:	ec26                	sd	s1,24(sp)
    800038ac:	e84a                	sd	s2,16(sp)
    800038ae:	e44e                	sd	s3,8(sp)
    800038b0:	1800                	addi	s0,sp,48
    800038b2:	892a                	mv	s2,a0
    800038b4:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800038b6:	0007d517          	auipc	a0,0x7d
    800038ba:	5aa50513          	addi	a0,a0,1450 # 80080e60 <bcache>
    800038be:	aaefd0ef          	jal	ra,80000b6c <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800038c2:	00086497          	auipc	s1,0x86
    800038c6:	8564b483          	ld	s1,-1962(s1) # 80089118 <bcache+0x82b8>
    800038ca:	00085797          	auipc	a5,0x85
    800038ce:	7fe78793          	addi	a5,a5,2046 # 800890c8 <bcache+0x8268>
    800038d2:	02f48b63          	beq	s1,a5,80003908 <bread+0x64>
    800038d6:	873e                	mv	a4,a5
    800038d8:	a021                	j	800038e0 <bread+0x3c>
    800038da:	68a4                	ld	s1,80(s1)
    800038dc:	02e48663          	beq	s1,a4,80003908 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    800038e0:	449c                	lw	a5,8(s1)
    800038e2:	ff279ce3          	bne	a5,s2,800038da <bread+0x36>
    800038e6:	44dc                	lw	a5,12(s1)
    800038e8:	ff3799e3          	bne	a5,s3,800038da <bread+0x36>
      b->refcnt++;
    800038ec:	40bc                	lw	a5,64(s1)
    800038ee:	2785                	addiw	a5,a5,1
    800038f0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800038f2:	0007d517          	auipc	a0,0x7d
    800038f6:	56e50513          	addi	a0,a0,1390 # 80080e60 <bcache>
    800038fa:	b0afd0ef          	jal	ra,80000c04 <release>
      acquiresleep(&b->lock);
    800038fe:	01048513          	addi	a0,s1,16
    80003902:	2b0010ef          	jal	ra,80004bb2 <acquiresleep>
      return b;
    80003906:	a889                	j	80003958 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003908:	00086497          	auipc	s1,0x86
    8000390c:	8084b483          	ld	s1,-2040(s1) # 80089110 <bcache+0x82b0>
    80003910:	00085797          	auipc	a5,0x85
    80003914:	7b878793          	addi	a5,a5,1976 # 800890c8 <bcache+0x8268>
    80003918:	00f48863          	beq	s1,a5,80003928 <bread+0x84>
    8000391c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000391e:	40bc                	lw	a5,64(s1)
    80003920:	cb91                	beqz	a5,80003934 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003922:	64a4                	ld	s1,72(s1)
    80003924:	fee49de3          	bne	s1,a4,8000391e <bread+0x7a>
  panic("bget: no buffers");
    80003928:	00005517          	auipc	a0,0x5
    8000392c:	fa050513          	addi	a0,a0,-96 # 800088c8 <syscalls+0xc8>
    80003930:	e5bfc0ef          	jal	ra,8000078a <panic>
      b->dev = dev;
    80003934:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003938:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000393c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003940:	4785                	li	a5,1
    80003942:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003944:	0007d517          	auipc	a0,0x7d
    80003948:	51c50513          	addi	a0,a0,1308 # 80080e60 <bcache>
    8000394c:	ab8fd0ef          	jal	ra,80000c04 <release>
      acquiresleep(&b->lock);
    80003950:	01048513          	addi	a0,s1,16
    80003954:	25e010ef          	jal	ra,80004bb2 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003958:	409c                	lw	a5,0(s1)
    8000395a:	cb89                	beqz	a5,8000396c <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000395c:	8526                	mv	a0,s1
    8000395e:	70a2                	ld	ra,40(sp)
    80003960:	7402                	ld	s0,32(sp)
    80003962:	64e2                	ld	s1,24(sp)
    80003964:	6942                	ld	s2,16(sp)
    80003966:	69a2                	ld	s3,8(sp)
    80003968:	6145                	addi	sp,sp,48
    8000396a:	8082                	ret
    virtio_disk_rw(b, 0);
    8000396c:	4581                	li	a1,0
    8000396e:	8526                	mv	a0,s1
    80003970:	1ed020ef          	jal	ra,8000635c <virtio_disk_rw>
    b->valid = 1;
    80003974:	4785                	li	a5,1
    80003976:	c09c                	sw	a5,0(s1)
  return b;
    80003978:	b7d5                	j	8000395c <bread+0xb8>

000000008000397a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000397a:	1101                	addi	sp,sp,-32
    8000397c:	ec06                	sd	ra,24(sp)
    8000397e:	e822                	sd	s0,16(sp)
    80003980:	e426                	sd	s1,8(sp)
    80003982:	1000                	addi	s0,sp,32
    80003984:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003986:	0541                	addi	a0,a0,16
    80003988:	2a8010ef          	jal	ra,80004c30 <holdingsleep>
    8000398c:	c911                	beqz	a0,800039a0 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000398e:	4585                	li	a1,1
    80003990:	8526                	mv	a0,s1
    80003992:	1cb020ef          	jal	ra,8000635c <virtio_disk_rw>
}
    80003996:	60e2                	ld	ra,24(sp)
    80003998:	6442                	ld	s0,16(sp)
    8000399a:	64a2                	ld	s1,8(sp)
    8000399c:	6105                	addi	sp,sp,32
    8000399e:	8082                	ret
    panic("bwrite");
    800039a0:	00005517          	auipc	a0,0x5
    800039a4:	f4050513          	addi	a0,a0,-192 # 800088e0 <syscalls+0xe0>
    800039a8:	de3fc0ef          	jal	ra,8000078a <panic>

00000000800039ac <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800039ac:	1101                	addi	sp,sp,-32
    800039ae:	ec06                	sd	ra,24(sp)
    800039b0:	e822                	sd	s0,16(sp)
    800039b2:	e426                	sd	s1,8(sp)
    800039b4:	e04a                	sd	s2,0(sp)
    800039b6:	1000                	addi	s0,sp,32
    800039b8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800039ba:	01050913          	addi	s2,a0,16
    800039be:	854a                	mv	a0,s2
    800039c0:	270010ef          	jal	ra,80004c30 <holdingsleep>
    800039c4:	c13d                	beqz	a0,80003a2a <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    800039c6:	854a                	mv	a0,s2
    800039c8:	230010ef          	jal	ra,80004bf8 <releasesleep>

  acquire(&bcache.lock);
    800039cc:	0007d517          	auipc	a0,0x7d
    800039d0:	49450513          	addi	a0,a0,1172 # 80080e60 <bcache>
    800039d4:	998fd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt--;
    800039d8:	40bc                	lw	a5,64(s1)
    800039da:	37fd                	addiw	a5,a5,-1
    800039dc:	0007871b          	sext.w	a4,a5
    800039e0:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800039e2:	eb05                	bnez	a4,80003a12 <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800039e4:	68bc                	ld	a5,80(s1)
    800039e6:	64b8                	ld	a4,72(s1)
    800039e8:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800039ea:	64bc                	ld	a5,72(s1)
    800039ec:	68b8                	ld	a4,80(s1)
    800039ee:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800039f0:	00085797          	auipc	a5,0x85
    800039f4:	47078793          	addi	a5,a5,1136 # 80088e60 <bcache+0x8000>
    800039f8:	2b87b703          	ld	a4,696(a5)
    800039fc:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800039fe:	00085717          	auipc	a4,0x85
    80003a02:	6ca70713          	addi	a4,a4,1738 # 800890c8 <bcache+0x8268>
    80003a06:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003a08:	2b87b703          	ld	a4,696(a5)
    80003a0c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003a0e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003a12:	0007d517          	auipc	a0,0x7d
    80003a16:	44e50513          	addi	a0,a0,1102 # 80080e60 <bcache>
    80003a1a:	9eafd0ef          	jal	ra,80000c04 <release>
}
    80003a1e:	60e2                	ld	ra,24(sp)
    80003a20:	6442                	ld	s0,16(sp)
    80003a22:	64a2                	ld	s1,8(sp)
    80003a24:	6902                	ld	s2,0(sp)
    80003a26:	6105                	addi	sp,sp,32
    80003a28:	8082                	ret
    panic("brelse");
    80003a2a:	00005517          	auipc	a0,0x5
    80003a2e:	ebe50513          	addi	a0,a0,-322 # 800088e8 <syscalls+0xe8>
    80003a32:	d59fc0ef          	jal	ra,8000078a <panic>

0000000080003a36 <bpin>:

void
bpin(struct buf *b) {
    80003a36:	1101                	addi	sp,sp,-32
    80003a38:	ec06                	sd	ra,24(sp)
    80003a3a:	e822                	sd	s0,16(sp)
    80003a3c:	e426                	sd	s1,8(sp)
    80003a3e:	1000                	addi	s0,sp,32
    80003a40:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003a42:	0007d517          	auipc	a0,0x7d
    80003a46:	41e50513          	addi	a0,a0,1054 # 80080e60 <bcache>
    80003a4a:	922fd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt++;
    80003a4e:	40bc                	lw	a5,64(s1)
    80003a50:	2785                	addiw	a5,a5,1
    80003a52:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003a54:	0007d517          	auipc	a0,0x7d
    80003a58:	40c50513          	addi	a0,a0,1036 # 80080e60 <bcache>
    80003a5c:	9a8fd0ef          	jal	ra,80000c04 <release>
}
    80003a60:	60e2                	ld	ra,24(sp)
    80003a62:	6442                	ld	s0,16(sp)
    80003a64:	64a2                	ld	s1,8(sp)
    80003a66:	6105                	addi	sp,sp,32
    80003a68:	8082                	ret

0000000080003a6a <bunpin>:

void
bunpin(struct buf *b) {
    80003a6a:	1101                	addi	sp,sp,-32
    80003a6c:	ec06                	sd	ra,24(sp)
    80003a6e:	e822                	sd	s0,16(sp)
    80003a70:	e426                	sd	s1,8(sp)
    80003a72:	1000                	addi	s0,sp,32
    80003a74:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003a76:	0007d517          	auipc	a0,0x7d
    80003a7a:	3ea50513          	addi	a0,a0,1002 # 80080e60 <bcache>
    80003a7e:	8eefd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt--;
    80003a82:	40bc                	lw	a5,64(s1)
    80003a84:	37fd                	addiw	a5,a5,-1
    80003a86:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003a88:	0007d517          	auipc	a0,0x7d
    80003a8c:	3d850513          	addi	a0,a0,984 # 80080e60 <bcache>
    80003a90:	974fd0ef          	jal	ra,80000c04 <release>
}
    80003a94:	60e2                	ld	ra,24(sp)
    80003a96:	6442                	ld	s0,16(sp)
    80003a98:	64a2                	ld	s1,8(sp)
    80003a9a:	6105                	addi	sp,sp,32
    80003a9c:	8082                	ret

0000000080003a9e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003a9e:	1101                	addi	sp,sp,-32
    80003aa0:	ec06                	sd	ra,24(sp)
    80003aa2:	e822                	sd	s0,16(sp)
    80003aa4:	e426                	sd	s1,8(sp)
    80003aa6:	e04a                	sd	s2,0(sp)
    80003aa8:	1000                	addi	s0,sp,32
    80003aaa:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003aac:	00d5d59b          	srliw	a1,a1,0xd
    80003ab0:	00086797          	auipc	a5,0x86
    80003ab4:	a8c7a783          	lw	a5,-1396(a5) # 8008953c <sb+0x1c>
    80003ab8:	9dbd                	addw	a1,a1,a5
    80003aba:	debff0ef          	jal	ra,800038a4 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003abe:	0074f713          	andi	a4,s1,7
    80003ac2:	4785                	li	a5,1
    80003ac4:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003ac8:	14ce                	slli	s1,s1,0x33
    80003aca:	90d9                	srli	s1,s1,0x36
    80003acc:	00950733          	add	a4,a0,s1
    80003ad0:	05874703          	lbu	a4,88(a4)
    80003ad4:	00e7f6b3          	and	a3,a5,a4
    80003ad8:	c29d                	beqz	a3,80003afe <bfree+0x60>
    80003ada:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003adc:	94aa                	add	s1,s1,a0
    80003ade:	fff7c793          	not	a5,a5
    80003ae2:	8ff9                	and	a5,a5,a4
    80003ae4:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003ae8:	7d1000ef          	jal	ra,80004ab8 <log_write>
  brelse(bp);
    80003aec:	854a                	mv	a0,s2
    80003aee:	ebfff0ef          	jal	ra,800039ac <brelse>
}
    80003af2:	60e2                	ld	ra,24(sp)
    80003af4:	6442                	ld	s0,16(sp)
    80003af6:	64a2                	ld	s1,8(sp)
    80003af8:	6902                	ld	s2,0(sp)
    80003afa:	6105                	addi	sp,sp,32
    80003afc:	8082                	ret
    panic("freeing free block");
    80003afe:	00005517          	auipc	a0,0x5
    80003b02:	df250513          	addi	a0,a0,-526 # 800088f0 <syscalls+0xf0>
    80003b06:	c85fc0ef          	jal	ra,8000078a <panic>

0000000080003b0a <balloc>:
{
    80003b0a:	711d                	addi	sp,sp,-96
    80003b0c:	ec86                	sd	ra,88(sp)
    80003b0e:	e8a2                	sd	s0,80(sp)
    80003b10:	e4a6                	sd	s1,72(sp)
    80003b12:	e0ca                	sd	s2,64(sp)
    80003b14:	fc4e                	sd	s3,56(sp)
    80003b16:	f852                	sd	s4,48(sp)
    80003b18:	f456                	sd	s5,40(sp)
    80003b1a:	f05a                	sd	s6,32(sp)
    80003b1c:	ec5e                	sd	s7,24(sp)
    80003b1e:	e862                	sd	s8,16(sp)
    80003b20:	e466                	sd	s9,8(sp)
    80003b22:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003b24:	00086797          	auipc	a5,0x86
    80003b28:	a007a783          	lw	a5,-1536(a5) # 80089524 <sb+0x4>
    80003b2c:	0e078163          	beqz	a5,80003c0e <balloc+0x104>
    80003b30:	8baa                	mv	s7,a0
    80003b32:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003b34:	00086b17          	auipc	s6,0x86
    80003b38:	9ecb0b13          	addi	s6,s6,-1556 # 80089520 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b3c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003b3e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b40:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003b42:	6c89                	lui	s9,0x2
    80003b44:	a0b5                	j	80003bb0 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003b46:	974a                	add	a4,a4,s2
    80003b48:	8fd5                	or	a5,a5,a3
    80003b4a:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003b4e:	854a                	mv	a0,s2
    80003b50:	769000ef          	jal	ra,80004ab8 <log_write>
        brelse(bp);
    80003b54:	854a                	mv	a0,s2
    80003b56:	e57ff0ef          	jal	ra,800039ac <brelse>
  bp = bread(dev, bno);
    80003b5a:	85a6                	mv	a1,s1
    80003b5c:	855e                	mv	a0,s7
    80003b5e:	d47ff0ef          	jal	ra,800038a4 <bread>
    80003b62:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003b64:	40000613          	li	a2,1024
    80003b68:	4581                	li	a1,0
    80003b6a:	05850513          	addi	a0,a0,88
    80003b6e:	8d2fd0ef          	jal	ra,80000c40 <memset>
  log_write(bp);
    80003b72:	854a                	mv	a0,s2
    80003b74:	745000ef          	jal	ra,80004ab8 <log_write>
  brelse(bp);
    80003b78:	854a                	mv	a0,s2
    80003b7a:	e33ff0ef          	jal	ra,800039ac <brelse>
}
    80003b7e:	8526                	mv	a0,s1
    80003b80:	60e6                	ld	ra,88(sp)
    80003b82:	6446                	ld	s0,80(sp)
    80003b84:	64a6                	ld	s1,72(sp)
    80003b86:	6906                	ld	s2,64(sp)
    80003b88:	79e2                	ld	s3,56(sp)
    80003b8a:	7a42                	ld	s4,48(sp)
    80003b8c:	7aa2                	ld	s5,40(sp)
    80003b8e:	7b02                	ld	s6,32(sp)
    80003b90:	6be2                	ld	s7,24(sp)
    80003b92:	6c42                	ld	s8,16(sp)
    80003b94:	6ca2                	ld	s9,8(sp)
    80003b96:	6125                	addi	sp,sp,96
    80003b98:	8082                	ret
    brelse(bp);
    80003b9a:	854a                	mv	a0,s2
    80003b9c:	e11ff0ef          	jal	ra,800039ac <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003ba0:	015c87bb          	addw	a5,s9,s5
    80003ba4:	00078a9b          	sext.w	s5,a5
    80003ba8:	004b2703          	lw	a4,4(s6)
    80003bac:	06eaf163          	bgeu	s5,a4,80003c0e <balloc+0x104>
    bp = bread(dev, BBLOCK(b, sb));
    80003bb0:	41fad79b          	sraiw	a5,s5,0x1f
    80003bb4:	0137d79b          	srliw	a5,a5,0x13
    80003bb8:	015787bb          	addw	a5,a5,s5
    80003bbc:	40d7d79b          	sraiw	a5,a5,0xd
    80003bc0:	01cb2583          	lw	a1,28(s6)
    80003bc4:	9dbd                	addw	a1,a1,a5
    80003bc6:	855e                	mv	a0,s7
    80003bc8:	cddff0ef          	jal	ra,800038a4 <bread>
    80003bcc:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003bce:	004b2503          	lw	a0,4(s6)
    80003bd2:	000a849b          	sext.w	s1,s5
    80003bd6:	8662                	mv	a2,s8
    80003bd8:	fca4f1e3          	bgeu	s1,a0,80003b9a <balloc+0x90>
      m = 1 << (bi % 8);
    80003bdc:	41f6579b          	sraiw	a5,a2,0x1f
    80003be0:	01d7d69b          	srliw	a3,a5,0x1d
    80003be4:	00c6873b          	addw	a4,a3,a2
    80003be8:	00777793          	andi	a5,a4,7
    80003bec:	9f95                	subw	a5,a5,a3
    80003bee:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003bf2:	4037571b          	sraiw	a4,a4,0x3
    80003bf6:	00e906b3          	add	a3,s2,a4
    80003bfa:	0586c683          	lbu	a3,88(a3)
    80003bfe:	00d7f5b3          	and	a1,a5,a3
    80003c02:	d1b1                	beqz	a1,80003b46 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003c04:	2605                	addiw	a2,a2,1
    80003c06:	2485                	addiw	s1,s1,1
    80003c08:	fd4618e3          	bne	a2,s4,80003bd8 <balloc+0xce>
    80003c0c:	b779                	j	80003b9a <balloc+0x90>
  printf("balloc: out of blocks\n");
    80003c0e:	00005517          	auipc	a0,0x5
    80003c12:	cfa50513          	addi	a0,a0,-774 # 80008908 <syscalls+0x108>
    80003c16:	8affc0ef          	jal	ra,800004c4 <printf>
  return 0;
    80003c1a:	4481                	li	s1,0
    80003c1c:	b78d                	j	80003b7e <balloc+0x74>

0000000080003c1e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003c1e:	7179                	addi	sp,sp,-48
    80003c20:	f406                	sd	ra,40(sp)
    80003c22:	f022                	sd	s0,32(sp)
    80003c24:	ec26                	sd	s1,24(sp)
    80003c26:	e84a                	sd	s2,16(sp)
    80003c28:	e44e                	sd	s3,8(sp)
    80003c2a:	e052                	sd	s4,0(sp)
    80003c2c:	1800                	addi	s0,sp,48
    80003c2e:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003c30:	47ad                	li	a5,11
    80003c32:	02b7e563          	bltu	a5,a1,80003c5c <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80003c36:	02059493          	slli	s1,a1,0x20
    80003c3a:	9081                	srli	s1,s1,0x20
    80003c3c:	048a                	slli	s1,s1,0x2
    80003c3e:	94aa                	add	s1,s1,a0
    80003c40:	0504a903          	lw	s2,80(s1)
    80003c44:	06091663          	bnez	s2,80003cb0 <bmap+0x92>
      addr = balloc(ip->dev);
    80003c48:	4108                	lw	a0,0(a0)
    80003c4a:	ec1ff0ef          	jal	ra,80003b0a <balloc>
    80003c4e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003c52:	04090f63          	beqz	s2,80003cb0 <bmap+0x92>
        return 0;
      ip->addrs[bn] = addr;
    80003c56:	0524a823          	sw	s2,80(s1)
    80003c5a:	a899                	j	80003cb0 <bmap+0x92>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003c5c:	ff45849b          	addiw	s1,a1,-12
    80003c60:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003c64:	0ff00793          	li	a5,255
    80003c68:	06e7eb63          	bltu	a5,a4,80003cde <bmap+0xc0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003c6c:	08052903          	lw	s2,128(a0)
    80003c70:	00091b63          	bnez	s2,80003c86 <bmap+0x68>
      addr = balloc(ip->dev);
    80003c74:	4108                	lw	a0,0(a0)
    80003c76:	e95ff0ef          	jal	ra,80003b0a <balloc>
    80003c7a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003c7e:	02090963          	beqz	s2,80003cb0 <bmap+0x92>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003c82:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003c86:	85ca                	mv	a1,s2
    80003c88:	0009a503          	lw	a0,0(s3)
    80003c8c:	c19ff0ef          	jal	ra,800038a4 <bread>
    80003c90:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003c92:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003c96:	02049593          	slli	a1,s1,0x20
    80003c9a:	9181                	srli	a1,a1,0x20
    80003c9c:	058a                	slli	a1,a1,0x2
    80003c9e:	00b784b3          	add	s1,a5,a1
    80003ca2:	0004a903          	lw	s2,0(s1)
    80003ca6:	00090e63          	beqz	s2,80003cc2 <bmap+0xa4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003caa:	8552                	mv	a0,s4
    80003cac:	d01ff0ef          	jal	ra,800039ac <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003cb0:	854a                	mv	a0,s2
    80003cb2:	70a2                	ld	ra,40(sp)
    80003cb4:	7402                	ld	s0,32(sp)
    80003cb6:	64e2                	ld	s1,24(sp)
    80003cb8:	6942                	ld	s2,16(sp)
    80003cba:	69a2                	ld	s3,8(sp)
    80003cbc:	6a02                	ld	s4,0(sp)
    80003cbe:	6145                	addi	sp,sp,48
    80003cc0:	8082                	ret
      addr = balloc(ip->dev);
    80003cc2:	0009a503          	lw	a0,0(s3)
    80003cc6:	e45ff0ef          	jal	ra,80003b0a <balloc>
    80003cca:	0005091b          	sext.w	s2,a0
      if(addr){
    80003cce:	fc090ee3          	beqz	s2,80003caa <bmap+0x8c>
        a[bn] = addr;
    80003cd2:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003cd6:	8552                	mv	a0,s4
    80003cd8:	5e1000ef          	jal	ra,80004ab8 <log_write>
    80003cdc:	b7f9                	j	80003caa <bmap+0x8c>
  panic("bmap: out of range");
    80003cde:	00005517          	auipc	a0,0x5
    80003ce2:	c4250513          	addi	a0,a0,-958 # 80008920 <syscalls+0x120>
    80003ce6:	aa5fc0ef          	jal	ra,8000078a <panic>

0000000080003cea <iget>:
{
    80003cea:	7179                	addi	sp,sp,-48
    80003cec:	f406                	sd	ra,40(sp)
    80003cee:	f022                	sd	s0,32(sp)
    80003cf0:	ec26                	sd	s1,24(sp)
    80003cf2:	e84a                	sd	s2,16(sp)
    80003cf4:	e44e                	sd	s3,8(sp)
    80003cf6:	e052                	sd	s4,0(sp)
    80003cf8:	1800                	addi	s0,sp,48
    80003cfa:	89aa                	mv	s3,a0
    80003cfc:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003cfe:	00086517          	auipc	a0,0x86
    80003d02:	84250513          	addi	a0,a0,-1982 # 80089540 <itable>
    80003d06:	e67fc0ef          	jal	ra,80000b6c <acquire>
  empty = 0;
    80003d0a:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003d0c:	00086497          	auipc	s1,0x86
    80003d10:	84c48493          	addi	s1,s1,-1972 # 80089558 <itable+0x18>
    80003d14:	00087697          	auipc	a3,0x87
    80003d18:	2d468693          	addi	a3,a3,724 # 8008afe8 <log>
    80003d1c:	a039                	j	80003d2a <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003d1e:	02090963          	beqz	s2,80003d50 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003d22:	08848493          	addi	s1,s1,136
    80003d26:	02d48863          	beq	s1,a3,80003d56 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003d2a:	449c                	lw	a5,8(s1)
    80003d2c:	fef059e3          	blez	a5,80003d1e <iget+0x34>
    80003d30:	4098                	lw	a4,0(s1)
    80003d32:	ff3716e3          	bne	a4,s3,80003d1e <iget+0x34>
    80003d36:	40d8                	lw	a4,4(s1)
    80003d38:	ff4713e3          	bne	a4,s4,80003d1e <iget+0x34>
      ip->ref++;
    80003d3c:	2785                	addiw	a5,a5,1
    80003d3e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003d40:	00086517          	auipc	a0,0x86
    80003d44:	80050513          	addi	a0,a0,-2048 # 80089540 <itable>
    80003d48:	ebdfc0ef          	jal	ra,80000c04 <release>
      return ip;
    80003d4c:	8926                	mv	s2,s1
    80003d4e:	a02d                	j	80003d78 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003d50:	fbe9                	bnez	a5,80003d22 <iget+0x38>
    80003d52:	8926                	mv	s2,s1
    80003d54:	b7f9                	j	80003d22 <iget+0x38>
  if(empty == 0)
    80003d56:	02090a63          	beqz	s2,80003d8a <iget+0xa0>
  ip->dev = dev;
    80003d5a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003d5e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003d62:	4785                	li	a5,1
    80003d64:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003d68:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003d6c:	00085517          	auipc	a0,0x85
    80003d70:	7d450513          	addi	a0,a0,2004 # 80089540 <itable>
    80003d74:	e91fc0ef          	jal	ra,80000c04 <release>
}
    80003d78:	854a                	mv	a0,s2
    80003d7a:	70a2                	ld	ra,40(sp)
    80003d7c:	7402                	ld	s0,32(sp)
    80003d7e:	64e2                	ld	s1,24(sp)
    80003d80:	6942                	ld	s2,16(sp)
    80003d82:	69a2                	ld	s3,8(sp)
    80003d84:	6a02                	ld	s4,0(sp)
    80003d86:	6145                	addi	sp,sp,48
    80003d88:	8082                	ret
    panic("iget: no inodes");
    80003d8a:	00005517          	auipc	a0,0x5
    80003d8e:	bae50513          	addi	a0,a0,-1106 # 80008938 <syscalls+0x138>
    80003d92:	9f9fc0ef          	jal	ra,8000078a <panic>

0000000080003d96 <iinit>:
{
    80003d96:	7179                	addi	sp,sp,-48
    80003d98:	f406                	sd	ra,40(sp)
    80003d9a:	f022                	sd	s0,32(sp)
    80003d9c:	ec26                	sd	s1,24(sp)
    80003d9e:	e84a                	sd	s2,16(sp)
    80003da0:	e44e                	sd	s3,8(sp)
    80003da2:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003da4:	00005597          	auipc	a1,0x5
    80003da8:	ba458593          	addi	a1,a1,-1116 # 80008948 <syscalls+0x148>
    80003dac:	00085517          	auipc	a0,0x85
    80003db0:	79450513          	addi	a0,a0,1940 # 80089540 <itable>
    80003db4:	d39fc0ef          	jal	ra,80000aec <initlock>
  for(i = 0; i < NINODE; i++) {
    80003db8:	00085497          	auipc	s1,0x85
    80003dbc:	7b048493          	addi	s1,s1,1968 # 80089568 <itable+0x28>
    80003dc0:	00087997          	auipc	s3,0x87
    80003dc4:	23898993          	addi	s3,s3,568 # 8008aff8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003dc8:	00005917          	auipc	s2,0x5
    80003dcc:	b8890913          	addi	s2,s2,-1144 # 80008950 <syscalls+0x150>
    80003dd0:	85ca                	mv	a1,s2
    80003dd2:	8526                	mv	a0,s1
    80003dd4:	5a9000ef          	jal	ra,80004b7c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003dd8:	08848493          	addi	s1,s1,136
    80003ddc:	ff349ae3          	bne	s1,s3,80003dd0 <iinit+0x3a>
}
    80003de0:	70a2                	ld	ra,40(sp)
    80003de2:	7402                	ld	s0,32(sp)
    80003de4:	64e2                	ld	s1,24(sp)
    80003de6:	6942                	ld	s2,16(sp)
    80003de8:	69a2                	ld	s3,8(sp)
    80003dea:	6145                	addi	sp,sp,48
    80003dec:	8082                	ret

0000000080003dee <ialloc>:
{
    80003dee:	715d                	addi	sp,sp,-80
    80003df0:	e486                	sd	ra,72(sp)
    80003df2:	e0a2                	sd	s0,64(sp)
    80003df4:	fc26                	sd	s1,56(sp)
    80003df6:	f84a                	sd	s2,48(sp)
    80003df8:	f44e                	sd	s3,40(sp)
    80003dfa:	f052                	sd	s4,32(sp)
    80003dfc:	ec56                	sd	s5,24(sp)
    80003dfe:	e85a                	sd	s6,16(sp)
    80003e00:	e45e                	sd	s7,8(sp)
    80003e02:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003e04:	00085717          	auipc	a4,0x85
    80003e08:	72872703          	lw	a4,1832(a4) # 8008952c <sb+0xc>
    80003e0c:	4785                	li	a5,1
    80003e0e:	04e7f663          	bgeu	a5,a4,80003e5a <ialloc+0x6c>
    80003e12:	8aaa                	mv	s5,a0
    80003e14:	8bae                	mv	s7,a1
    80003e16:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003e18:	00085a17          	auipc	s4,0x85
    80003e1c:	708a0a13          	addi	s4,s4,1800 # 80089520 <sb>
    80003e20:	00048b1b          	sext.w	s6,s1
    80003e24:	0044d793          	srli	a5,s1,0x4
    80003e28:	018a2583          	lw	a1,24(s4)
    80003e2c:	9dbd                	addw	a1,a1,a5
    80003e2e:	8556                	mv	a0,s5
    80003e30:	a75ff0ef          	jal	ra,800038a4 <bread>
    80003e34:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003e36:	05850993          	addi	s3,a0,88
    80003e3a:	00f4f793          	andi	a5,s1,15
    80003e3e:	079a                	slli	a5,a5,0x6
    80003e40:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003e42:	00099783          	lh	a5,0(s3)
    80003e46:	cf85                	beqz	a5,80003e7e <ialloc+0x90>
    brelse(bp);
    80003e48:	b65ff0ef          	jal	ra,800039ac <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003e4c:	0485                	addi	s1,s1,1
    80003e4e:	00ca2703          	lw	a4,12(s4)
    80003e52:	0004879b          	sext.w	a5,s1
    80003e56:	fce7e5e3          	bltu	a5,a4,80003e20 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003e5a:	00005517          	auipc	a0,0x5
    80003e5e:	afe50513          	addi	a0,a0,-1282 # 80008958 <syscalls+0x158>
    80003e62:	e62fc0ef          	jal	ra,800004c4 <printf>
  return 0;
    80003e66:	4501                	li	a0,0
}
    80003e68:	60a6                	ld	ra,72(sp)
    80003e6a:	6406                	ld	s0,64(sp)
    80003e6c:	74e2                	ld	s1,56(sp)
    80003e6e:	7942                	ld	s2,48(sp)
    80003e70:	79a2                	ld	s3,40(sp)
    80003e72:	7a02                	ld	s4,32(sp)
    80003e74:	6ae2                	ld	s5,24(sp)
    80003e76:	6b42                	ld	s6,16(sp)
    80003e78:	6ba2                	ld	s7,8(sp)
    80003e7a:	6161                	addi	sp,sp,80
    80003e7c:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003e7e:	04000613          	li	a2,64
    80003e82:	4581                	li	a1,0
    80003e84:	854e                	mv	a0,s3
    80003e86:	dbbfc0ef          	jal	ra,80000c40 <memset>
      dip->type = type;
    80003e8a:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003e8e:	854a                	mv	a0,s2
    80003e90:	429000ef          	jal	ra,80004ab8 <log_write>
      brelse(bp);
    80003e94:	854a                	mv	a0,s2
    80003e96:	b17ff0ef          	jal	ra,800039ac <brelse>
      return iget(dev, inum);
    80003e9a:	85da                	mv	a1,s6
    80003e9c:	8556                	mv	a0,s5
    80003e9e:	e4dff0ef          	jal	ra,80003cea <iget>
    80003ea2:	b7d9                	j	80003e68 <ialloc+0x7a>

0000000080003ea4 <iupdate>:
{
    80003ea4:	1101                	addi	sp,sp,-32
    80003ea6:	ec06                	sd	ra,24(sp)
    80003ea8:	e822                	sd	s0,16(sp)
    80003eaa:	e426                	sd	s1,8(sp)
    80003eac:	e04a                	sd	s2,0(sp)
    80003eae:	1000                	addi	s0,sp,32
    80003eb0:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003eb2:	415c                	lw	a5,4(a0)
    80003eb4:	0047d79b          	srliw	a5,a5,0x4
    80003eb8:	00085597          	auipc	a1,0x85
    80003ebc:	6805a583          	lw	a1,1664(a1) # 80089538 <sb+0x18>
    80003ec0:	9dbd                	addw	a1,a1,a5
    80003ec2:	4108                	lw	a0,0(a0)
    80003ec4:	9e1ff0ef          	jal	ra,800038a4 <bread>
    80003ec8:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003eca:	05850793          	addi	a5,a0,88
    80003ece:	40c8                	lw	a0,4(s1)
    80003ed0:	893d                	andi	a0,a0,15
    80003ed2:	051a                	slli	a0,a0,0x6
    80003ed4:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003ed6:	04449703          	lh	a4,68(s1)
    80003eda:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003ede:	04649703          	lh	a4,70(s1)
    80003ee2:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003ee6:	04849703          	lh	a4,72(s1)
    80003eea:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003eee:	04a49703          	lh	a4,74(s1)
    80003ef2:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003ef6:	44f8                	lw	a4,76(s1)
    80003ef8:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003efa:	03400613          	li	a2,52
    80003efe:	05048593          	addi	a1,s1,80
    80003f02:	0531                	addi	a0,a0,12
    80003f04:	d99fc0ef          	jal	ra,80000c9c <memmove>
  log_write(bp);
    80003f08:	854a                	mv	a0,s2
    80003f0a:	3af000ef          	jal	ra,80004ab8 <log_write>
  brelse(bp);
    80003f0e:	854a                	mv	a0,s2
    80003f10:	a9dff0ef          	jal	ra,800039ac <brelse>
}
    80003f14:	60e2                	ld	ra,24(sp)
    80003f16:	6442                	ld	s0,16(sp)
    80003f18:	64a2                	ld	s1,8(sp)
    80003f1a:	6902                	ld	s2,0(sp)
    80003f1c:	6105                	addi	sp,sp,32
    80003f1e:	8082                	ret

0000000080003f20 <idup>:
{
    80003f20:	1101                	addi	sp,sp,-32
    80003f22:	ec06                	sd	ra,24(sp)
    80003f24:	e822                	sd	s0,16(sp)
    80003f26:	e426                	sd	s1,8(sp)
    80003f28:	1000                	addi	s0,sp,32
    80003f2a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003f2c:	00085517          	auipc	a0,0x85
    80003f30:	61450513          	addi	a0,a0,1556 # 80089540 <itable>
    80003f34:	c39fc0ef          	jal	ra,80000b6c <acquire>
  ip->ref++;
    80003f38:	449c                	lw	a5,8(s1)
    80003f3a:	2785                	addiw	a5,a5,1
    80003f3c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003f3e:	00085517          	auipc	a0,0x85
    80003f42:	60250513          	addi	a0,a0,1538 # 80089540 <itable>
    80003f46:	cbffc0ef          	jal	ra,80000c04 <release>
}
    80003f4a:	8526                	mv	a0,s1
    80003f4c:	60e2                	ld	ra,24(sp)
    80003f4e:	6442                	ld	s0,16(sp)
    80003f50:	64a2                	ld	s1,8(sp)
    80003f52:	6105                	addi	sp,sp,32
    80003f54:	8082                	ret

0000000080003f56 <ilock>:
{
    80003f56:	1101                	addi	sp,sp,-32
    80003f58:	ec06                	sd	ra,24(sp)
    80003f5a:	e822                	sd	s0,16(sp)
    80003f5c:	e426                	sd	s1,8(sp)
    80003f5e:	e04a                	sd	s2,0(sp)
    80003f60:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003f62:	c105                	beqz	a0,80003f82 <ilock+0x2c>
    80003f64:	84aa                	mv	s1,a0
    80003f66:	451c                	lw	a5,8(a0)
    80003f68:	00f05d63          	blez	a5,80003f82 <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003f6c:	0541                	addi	a0,a0,16
    80003f6e:	445000ef          	jal	ra,80004bb2 <acquiresleep>
  if(ip->valid == 0){
    80003f72:	40bc                	lw	a5,64(s1)
    80003f74:	cf89                	beqz	a5,80003f8e <ilock+0x38>
}
    80003f76:	60e2                	ld	ra,24(sp)
    80003f78:	6442                	ld	s0,16(sp)
    80003f7a:	64a2                	ld	s1,8(sp)
    80003f7c:	6902                	ld	s2,0(sp)
    80003f7e:	6105                	addi	sp,sp,32
    80003f80:	8082                	ret
    panic("ilock");
    80003f82:	00005517          	auipc	a0,0x5
    80003f86:	9ee50513          	addi	a0,a0,-1554 # 80008970 <syscalls+0x170>
    80003f8a:	801fc0ef          	jal	ra,8000078a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003f8e:	40dc                	lw	a5,4(s1)
    80003f90:	0047d79b          	srliw	a5,a5,0x4
    80003f94:	00085597          	auipc	a1,0x85
    80003f98:	5a45a583          	lw	a1,1444(a1) # 80089538 <sb+0x18>
    80003f9c:	9dbd                	addw	a1,a1,a5
    80003f9e:	4088                	lw	a0,0(s1)
    80003fa0:	905ff0ef          	jal	ra,800038a4 <bread>
    80003fa4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003fa6:	05850593          	addi	a1,a0,88
    80003faa:	40dc                	lw	a5,4(s1)
    80003fac:	8bbd                	andi	a5,a5,15
    80003fae:	079a                	slli	a5,a5,0x6
    80003fb0:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003fb2:	00059783          	lh	a5,0(a1)
    80003fb6:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003fba:	00259783          	lh	a5,2(a1)
    80003fbe:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003fc2:	00459783          	lh	a5,4(a1)
    80003fc6:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003fca:	00659783          	lh	a5,6(a1)
    80003fce:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003fd2:	459c                	lw	a5,8(a1)
    80003fd4:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003fd6:	03400613          	li	a2,52
    80003fda:	05b1                	addi	a1,a1,12
    80003fdc:	05048513          	addi	a0,s1,80
    80003fe0:	cbdfc0ef          	jal	ra,80000c9c <memmove>
    brelse(bp);
    80003fe4:	854a                	mv	a0,s2
    80003fe6:	9c7ff0ef          	jal	ra,800039ac <brelse>
    ip->valid = 1;
    80003fea:	4785                	li	a5,1
    80003fec:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003fee:	04449783          	lh	a5,68(s1)
    80003ff2:	f3d1                	bnez	a5,80003f76 <ilock+0x20>
      panic("ilock: no type");
    80003ff4:	00005517          	auipc	a0,0x5
    80003ff8:	98450513          	addi	a0,a0,-1660 # 80008978 <syscalls+0x178>
    80003ffc:	f8efc0ef          	jal	ra,8000078a <panic>

0000000080004000 <iunlock>:
{
    80004000:	1101                	addi	sp,sp,-32
    80004002:	ec06                	sd	ra,24(sp)
    80004004:	e822                	sd	s0,16(sp)
    80004006:	e426                	sd	s1,8(sp)
    80004008:	e04a                	sd	s2,0(sp)
    8000400a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000400c:	c505                	beqz	a0,80004034 <iunlock+0x34>
    8000400e:	84aa                	mv	s1,a0
    80004010:	01050913          	addi	s2,a0,16
    80004014:	854a                	mv	a0,s2
    80004016:	41b000ef          	jal	ra,80004c30 <holdingsleep>
    8000401a:	cd09                	beqz	a0,80004034 <iunlock+0x34>
    8000401c:	449c                	lw	a5,8(s1)
    8000401e:	00f05b63          	blez	a5,80004034 <iunlock+0x34>
  releasesleep(&ip->lock);
    80004022:	854a                	mv	a0,s2
    80004024:	3d5000ef          	jal	ra,80004bf8 <releasesleep>
}
    80004028:	60e2                	ld	ra,24(sp)
    8000402a:	6442                	ld	s0,16(sp)
    8000402c:	64a2                	ld	s1,8(sp)
    8000402e:	6902                	ld	s2,0(sp)
    80004030:	6105                	addi	sp,sp,32
    80004032:	8082                	ret
    panic("iunlock");
    80004034:	00005517          	auipc	a0,0x5
    80004038:	95450513          	addi	a0,a0,-1708 # 80008988 <syscalls+0x188>
    8000403c:	f4efc0ef          	jal	ra,8000078a <panic>

0000000080004040 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004040:	7179                	addi	sp,sp,-48
    80004042:	f406                	sd	ra,40(sp)
    80004044:	f022                	sd	s0,32(sp)
    80004046:	ec26                	sd	s1,24(sp)
    80004048:	e84a                	sd	s2,16(sp)
    8000404a:	e44e                	sd	s3,8(sp)
    8000404c:	e052                	sd	s4,0(sp)
    8000404e:	1800                	addi	s0,sp,48
    80004050:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004052:	05050493          	addi	s1,a0,80
    80004056:	08050913          	addi	s2,a0,128
    8000405a:	a021                	j	80004062 <itrunc+0x22>
    8000405c:	0491                	addi	s1,s1,4
    8000405e:	01248b63          	beq	s1,s2,80004074 <itrunc+0x34>
    if(ip->addrs[i]){
    80004062:	408c                	lw	a1,0(s1)
    80004064:	dde5                	beqz	a1,8000405c <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80004066:	0009a503          	lw	a0,0(s3)
    8000406a:	a35ff0ef          	jal	ra,80003a9e <bfree>
      ip->addrs[i] = 0;
    8000406e:	0004a023          	sw	zero,0(s1)
    80004072:	b7ed                	j	8000405c <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80004074:	0809a583          	lw	a1,128(s3)
    80004078:	ed91                	bnez	a1,80004094 <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000407a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000407e:	854e                	mv	a0,s3
    80004080:	e25ff0ef          	jal	ra,80003ea4 <iupdate>
}
    80004084:	70a2                	ld	ra,40(sp)
    80004086:	7402                	ld	s0,32(sp)
    80004088:	64e2                	ld	s1,24(sp)
    8000408a:	6942                	ld	s2,16(sp)
    8000408c:	69a2                	ld	s3,8(sp)
    8000408e:	6a02                	ld	s4,0(sp)
    80004090:	6145                	addi	sp,sp,48
    80004092:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004094:	0009a503          	lw	a0,0(s3)
    80004098:	80dff0ef          	jal	ra,800038a4 <bread>
    8000409c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000409e:	05850493          	addi	s1,a0,88
    800040a2:	45850913          	addi	s2,a0,1112
    800040a6:	a021                	j	800040ae <itrunc+0x6e>
    800040a8:	0491                	addi	s1,s1,4
    800040aa:	01248963          	beq	s1,s2,800040bc <itrunc+0x7c>
      if(a[j])
    800040ae:	408c                	lw	a1,0(s1)
    800040b0:	dde5                	beqz	a1,800040a8 <itrunc+0x68>
        bfree(ip->dev, a[j]);
    800040b2:	0009a503          	lw	a0,0(s3)
    800040b6:	9e9ff0ef          	jal	ra,80003a9e <bfree>
    800040ba:	b7fd                	j	800040a8 <itrunc+0x68>
    brelse(bp);
    800040bc:	8552                	mv	a0,s4
    800040be:	8efff0ef          	jal	ra,800039ac <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800040c2:	0809a583          	lw	a1,128(s3)
    800040c6:	0009a503          	lw	a0,0(s3)
    800040ca:	9d5ff0ef          	jal	ra,80003a9e <bfree>
    ip->addrs[NDIRECT] = 0;
    800040ce:	0809a023          	sw	zero,128(s3)
    800040d2:	b765                	j	8000407a <itrunc+0x3a>

00000000800040d4 <iput>:
{
    800040d4:	1101                	addi	sp,sp,-32
    800040d6:	ec06                	sd	ra,24(sp)
    800040d8:	e822                	sd	s0,16(sp)
    800040da:	e426                	sd	s1,8(sp)
    800040dc:	e04a                	sd	s2,0(sp)
    800040de:	1000                	addi	s0,sp,32
    800040e0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800040e2:	00085517          	auipc	a0,0x85
    800040e6:	45e50513          	addi	a0,a0,1118 # 80089540 <itable>
    800040ea:	a83fc0ef          	jal	ra,80000b6c <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800040ee:	4498                	lw	a4,8(s1)
    800040f0:	4785                	li	a5,1
    800040f2:	02f70163          	beq	a4,a5,80004114 <iput+0x40>
  ip->ref--;
    800040f6:	449c                	lw	a5,8(s1)
    800040f8:	37fd                	addiw	a5,a5,-1
    800040fa:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800040fc:	00085517          	auipc	a0,0x85
    80004100:	44450513          	addi	a0,a0,1092 # 80089540 <itable>
    80004104:	b01fc0ef          	jal	ra,80000c04 <release>
}
    80004108:	60e2                	ld	ra,24(sp)
    8000410a:	6442                	ld	s0,16(sp)
    8000410c:	64a2                	ld	s1,8(sp)
    8000410e:	6902                	ld	s2,0(sp)
    80004110:	6105                	addi	sp,sp,32
    80004112:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004114:	40bc                	lw	a5,64(s1)
    80004116:	d3e5                	beqz	a5,800040f6 <iput+0x22>
    80004118:	04a49783          	lh	a5,74(s1)
    8000411c:	ffe9                	bnez	a5,800040f6 <iput+0x22>
    acquiresleep(&ip->lock);
    8000411e:	01048913          	addi	s2,s1,16
    80004122:	854a                	mv	a0,s2
    80004124:	28f000ef          	jal	ra,80004bb2 <acquiresleep>
    release(&itable.lock);
    80004128:	00085517          	auipc	a0,0x85
    8000412c:	41850513          	addi	a0,a0,1048 # 80089540 <itable>
    80004130:	ad5fc0ef          	jal	ra,80000c04 <release>
    itrunc(ip);
    80004134:	8526                	mv	a0,s1
    80004136:	f0bff0ef          	jal	ra,80004040 <itrunc>
    ip->type = 0;
    8000413a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000413e:	8526                	mv	a0,s1
    80004140:	d65ff0ef          	jal	ra,80003ea4 <iupdate>
    ip->valid = 0;
    80004144:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004148:	854a                	mv	a0,s2
    8000414a:	2af000ef          	jal	ra,80004bf8 <releasesleep>
    acquire(&itable.lock);
    8000414e:	00085517          	auipc	a0,0x85
    80004152:	3f250513          	addi	a0,a0,1010 # 80089540 <itable>
    80004156:	a17fc0ef          	jal	ra,80000b6c <acquire>
    8000415a:	bf71                	j	800040f6 <iput+0x22>

000000008000415c <iunlockput>:
{
    8000415c:	1101                	addi	sp,sp,-32
    8000415e:	ec06                	sd	ra,24(sp)
    80004160:	e822                	sd	s0,16(sp)
    80004162:	e426                	sd	s1,8(sp)
    80004164:	1000                	addi	s0,sp,32
    80004166:	84aa                	mv	s1,a0
  iunlock(ip);
    80004168:	e99ff0ef          	jal	ra,80004000 <iunlock>
  iput(ip);
    8000416c:	8526                	mv	a0,s1
    8000416e:	f67ff0ef          	jal	ra,800040d4 <iput>
}
    80004172:	60e2                	ld	ra,24(sp)
    80004174:	6442                	ld	s0,16(sp)
    80004176:	64a2                	ld	s1,8(sp)
    80004178:	6105                	addi	sp,sp,32
    8000417a:	8082                	ret

000000008000417c <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000417c:	00085717          	auipc	a4,0x85
    80004180:	3b072703          	lw	a4,944(a4) # 8008952c <sb+0xc>
    80004184:	4785                	li	a5,1
    80004186:	0ae7ff63          	bgeu	a5,a4,80004244 <ireclaim+0xc8>
{
    8000418a:	7139                	addi	sp,sp,-64
    8000418c:	fc06                	sd	ra,56(sp)
    8000418e:	f822                	sd	s0,48(sp)
    80004190:	f426                	sd	s1,40(sp)
    80004192:	f04a                	sd	s2,32(sp)
    80004194:	ec4e                	sd	s3,24(sp)
    80004196:	e852                	sd	s4,16(sp)
    80004198:	e456                	sd	s5,8(sp)
    8000419a:	e05a                	sd	s6,0(sp)
    8000419c:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000419e:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800041a0:	00050a1b          	sext.w	s4,a0
    800041a4:	00085a97          	auipc	s5,0x85
    800041a8:	37ca8a93          	addi	s5,s5,892 # 80089520 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    800041ac:	00004b17          	auipc	s6,0x4
    800041b0:	7e4b0b13          	addi	s6,s6,2020 # 80008990 <syscalls+0x190>
    800041b4:	a099                	j	800041fa <ireclaim+0x7e>
    800041b6:	85ce                	mv	a1,s3
    800041b8:	855a                	mv	a0,s6
    800041ba:	b0afc0ef          	jal	ra,800004c4 <printf>
      ip = iget(dev, inum);
    800041be:	85ce                	mv	a1,s3
    800041c0:	8552                	mv	a0,s4
    800041c2:	b29ff0ef          	jal	ra,80003cea <iget>
    800041c6:	89aa                	mv	s3,a0
    brelse(bp);
    800041c8:	854a                	mv	a0,s2
    800041ca:	fe2ff0ef          	jal	ra,800039ac <brelse>
    if (ip) {
    800041ce:	00098f63          	beqz	s3,800041ec <ireclaim+0x70>
      begin_op();
    800041d2:	762000ef          	jal	ra,80004934 <begin_op>
      ilock(ip);
    800041d6:	854e                	mv	a0,s3
    800041d8:	d7fff0ef          	jal	ra,80003f56 <ilock>
      iunlock(ip);
    800041dc:	854e                	mv	a0,s3
    800041de:	e23ff0ef          	jal	ra,80004000 <iunlock>
      iput(ip);
    800041e2:	854e                	mv	a0,s3
    800041e4:	ef1ff0ef          	jal	ra,800040d4 <iput>
      end_op();
    800041e8:	7bc000ef          	jal	ra,800049a4 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800041ec:	0485                	addi	s1,s1,1
    800041ee:	00caa703          	lw	a4,12(s5)
    800041f2:	0004879b          	sext.w	a5,s1
    800041f6:	02e7fd63          	bgeu	a5,a4,80004230 <ireclaim+0xb4>
    800041fa:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800041fe:	0044d793          	srli	a5,s1,0x4
    80004202:	018aa583          	lw	a1,24(s5)
    80004206:	9dbd                	addw	a1,a1,a5
    80004208:	8552                	mv	a0,s4
    8000420a:	e9aff0ef          	jal	ra,800038a4 <bread>
    8000420e:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80004210:	05850793          	addi	a5,a0,88
    80004214:	00f9f713          	andi	a4,s3,15
    80004218:	071a                	slli	a4,a4,0x6
    8000421a:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    8000421c:	00079703          	lh	a4,0(a5)
    80004220:	c701                	beqz	a4,80004228 <ireclaim+0xac>
    80004222:	00679783          	lh	a5,6(a5)
    80004226:	dbc1                	beqz	a5,800041b6 <ireclaim+0x3a>
    brelse(bp);
    80004228:	854a                	mv	a0,s2
    8000422a:	f82ff0ef          	jal	ra,800039ac <brelse>
    if (ip) {
    8000422e:	bf7d                	j	800041ec <ireclaim+0x70>
}
    80004230:	70e2                	ld	ra,56(sp)
    80004232:	7442                	ld	s0,48(sp)
    80004234:	74a2                	ld	s1,40(sp)
    80004236:	7902                	ld	s2,32(sp)
    80004238:	69e2                	ld	s3,24(sp)
    8000423a:	6a42                	ld	s4,16(sp)
    8000423c:	6aa2                	ld	s5,8(sp)
    8000423e:	6b02                	ld	s6,0(sp)
    80004240:	6121                	addi	sp,sp,64
    80004242:	8082                	ret
    80004244:	8082                	ret

0000000080004246 <fsinit>:
fsinit(int dev) {
    80004246:	7179                	addi	sp,sp,-48
    80004248:	f406                	sd	ra,40(sp)
    8000424a:	f022                	sd	s0,32(sp)
    8000424c:	ec26                	sd	s1,24(sp)
    8000424e:	e84a                	sd	s2,16(sp)
    80004250:	e44e                	sd	s3,8(sp)
    80004252:	1800                	addi	s0,sp,48
    80004254:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80004256:	4585                	li	a1,1
    80004258:	e4cff0ef          	jal	ra,800038a4 <bread>
    8000425c:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000425e:	00085997          	auipc	s3,0x85
    80004262:	2c298993          	addi	s3,s3,706 # 80089520 <sb>
    80004266:	02000613          	li	a2,32
    8000426a:	05850593          	addi	a1,a0,88
    8000426e:	854e                	mv	a0,s3
    80004270:	a2dfc0ef          	jal	ra,80000c9c <memmove>
  brelse(bp);
    80004274:	854a                	mv	a0,s2
    80004276:	f36ff0ef          	jal	ra,800039ac <brelse>
  if(sb.magic != FSMAGIC)
    8000427a:	0009a703          	lw	a4,0(s3)
    8000427e:	102037b7          	lui	a5,0x10203
    80004282:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80004286:	02f71363          	bne	a4,a5,800042ac <fsinit+0x66>
  initlog(dev, &sb);
    8000428a:	00085597          	auipc	a1,0x85
    8000428e:	29658593          	addi	a1,a1,662 # 80089520 <sb>
    80004292:	8526                	mv	a0,s1
    80004294:	616000ef          	jal	ra,800048aa <initlog>
  ireclaim(dev);
    80004298:	8526                	mv	a0,s1
    8000429a:	ee3ff0ef          	jal	ra,8000417c <ireclaim>
}
    8000429e:	70a2                	ld	ra,40(sp)
    800042a0:	7402                	ld	s0,32(sp)
    800042a2:	64e2                	ld	s1,24(sp)
    800042a4:	6942                	ld	s2,16(sp)
    800042a6:	69a2                	ld	s3,8(sp)
    800042a8:	6145                	addi	sp,sp,48
    800042aa:	8082                	ret
    panic("invalid file system");
    800042ac:	00004517          	auipc	a0,0x4
    800042b0:	70450513          	addi	a0,a0,1796 # 800089b0 <syscalls+0x1b0>
    800042b4:	cd6fc0ef          	jal	ra,8000078a <panic>

00000000800042b8 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800042b8:	1141                	addi	sp,sp,-16
    800042ba:	e422                	sd	s0,8(sp)
    800042bc:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800042be:	411c                	lw	a5,0(a0)
    800042c0:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800042c2:	415c                	lw	a5,4(a0)
    800042c4:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800042c6:	04451783          	lh	a5,68(a0)
    800042ca:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800042ce:	04a51783          	lh	a5,74(a0)
    800042d2:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800042d6:	04c56783          	lwu	a5,76(a0)
    800042da:	e99c                	sd	a5,16(a1)
}
    800042dc:	6422                	ld	s0,8(sp)
    800042de:	0141                	addi	sp,sp,16
    800042e0:	8082                	ret

00000000800042e2 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800042e2:	457c                	lw	a5,76(a0)
    800042e4:	0cd7ef63          	bltu	a5,a3,800043c2 <readi+0xe0>
{
    800042e8:	7159                	addi	sp,sp,-112
    800042ea:	f486                	sd	ra,104(sp)
    800042ec:	f0a2                	sd	s0,96(sp)
    800042ee:	eca6                	sd	s1,88(sp)
    800042f0:	e8ca                	sd	s2,80(sp)
    800042f2:	e4ce                	sd	s3,72(sp)
    800042f4:	e0d2                	sd	s4,64(sp)
    800042f6:	fc56                	sd	s5,56(sp)
    800042f8:	f85a                	sd	s6,48(sp)
    800042fa:	f45e                	sd	s7,40(sp)
    800042fc:	f062                	sd	s8,32(sp)
    800042fe:	ec66                	sd	s9,24(sp)
    80004300:	e86a                	sd	s10,16(sp)
    80004302:	e46e                	sd	s11,8(sp)
    80004304:	1880                	addi	s0,sp,112
    80004306:	8b2a                	mv	s6,a0
    80004308:	8bae                	mv	s7,a1
    8000430a:	8a32                	mv	s4,a2
    8000430c:	84b6                	mv	s1,a3
    8000430e:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004310:	9f35                	addw	a4,a4,a3
    return 0;
    80004312:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004314:	08d76663          	bltu	a4,a3,800043a0 <readi+0xbe>
  if(off + n > ip->size)
    80004318:	00e7f463          	bgeu	a5,a4,80004320 <readi+0x3e>
    n = ip->size - off;
    8000431c:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004320:	080a8f63          	beqz	s5,800043be <readi+0xdc>
    80004324:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004326:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000432a:	5c7d                	li	s8,-1
    8000432c:	a80d                	j	8000435e <readi+0x7c>
    8000432e:	020d1d93          	slli	s11,s10,0x20
    80004332:	020ddd93          	srli	s11,s11,0x20
    80004336:	05890793          	addi	a5,s2,88
    8000433a:	86ee                	mv	a3,s11
    8000433c:	963e                	add	a2,a2,a5
    8000433e:	85d2                	mv	a1,s4
    80004340:	855e                	mv	a0,s7
    80004342:	ad5fe0ef          	jal	ra,80002e16 <either_copyout>
    80004346:	05850763          	beq	a0,s8,80004394 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000434a:	854a                	mv	a0,s2
    8000434c:	e60ff0ef          	jal	ra,800039ac <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004350:	013d09bb          	addw	s3,s10,s3
    80004354:	009d04bb          	addw	s1,s10,s1
    80004358:	9a6e                	add	s4,s4,s11
    8000435a:	0559f163          	bgeu	s3,s5,8000439c <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    8000435e:	00a4d59b          	srliw	a1,s1,0xa
    80004362:	855a                	mv	a0,s6
    80004364:	8bbff0ef          	jal	ra,80003c1e <bmap>
    80004368:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000436c:	c985                	beqz	a1,8000439c <readi+0xba>
    bp = bread(ip->dev, addr);
    8000436e:	000b2503          	lw	a0,0(s6)
    80004372:	d32ff0ef          	jal	ra,800038a4 <bread>
    80004376:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004378:	3ff4f613          	andi	a2,s1,1023
    8000437c:	40cc87bb          	subw	a5,s9,a2
    80004380:	413a873b          	subw	a4,s5,s3
    80004384:	8d3e                	mv	s10,a5
    80004386:	2781                	sext.w	a5,a5
    80004388:	0007069b          	sext.w	a3,a4
    8000438c:	faf6f1e3          	bgeu	a3,a5,8000432e <readi+0x4c>
    80004390:	8d3a                	mv	s10,a4
    80004392:	bf71                	j	8000432e <readi+0x4c>
      brelse(bp);
    80004394:	854a                	mv	a0,s2
    80004396:	e16ff0ef          	jal	ra,800039ac <brelse>
      tot = -1;
    8000439a:	59fd                	li	s3,-1
  }
  return tot;
    8000439c:	0009851b          	sext.w	a0,s3
}
    800043a0:	70a6                	ld	ra,104(sp)
    800043a2:	7406                	ld	s0,96(sp)
    800043a4:	64e6                	ld	s1,88(sp)
    800043a6:	6946                	ld	s2,80(sp)
    800043a8:	69a6                	ld	s3,72(sp)
    800043aa:	6a06                	ld	s4,64(sp)
    800043ac:	7ae2                	ld	s5,56(sp)
    800043ae:	7b42                	ld	s6,48(sp)
    800043b0:	7ba2                	ld	s7,40(sp)
    800043b2:	7c02                	ld	s8,32(sp)
    800043b4:	6ce2                	ld	s9,24(sp)
    800043b6:	6d42                	ld	s10,16(sp)
    800043b8:	6da2                	ld	s11,8(sp)
    800043ba:	6165                	addi	sp,sp,112
    800043bc:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800043be:	89d6                	mv	s3,s5
    800043c0:	bff1                	j	8000439c <readi+0xba>
    return 0;
    800043c2:	4501                	li	a0,0
}
    800043c4:	8082                	ret

00000000800043c6 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800043c6:	457c                	lw	a5,76(a0)
    800043c8:	0ed7ea63          	bltu	a5,a3,800044bc <writei+0xf6>
{
    800043cc:	7159                	addi	sp,sp,-112
    800043ce:	f486                	sd	ra,104(sp)
    800043d0:	f0a2                	sd	s0,96(sp)
    800043d2:	eca6                	sd	s1,88(sp)
    800043d4:	e8ca                	sd	s2,80(sp)
    800043d6:	e4ce                	sd	s3,72(sp)
    800043d8:	e0d2                	sd	s4,64(sp)
    800043da:	fc56                	sd	s5,56(sp)
    800043dc:	f85a                	sd	s6,48(sp)
    800043de:	f45e                	sd	s7,40(sp)
    800043e0:	f062                	sd	s8,32(sp)
    800043e2:	ec66                	sd	s9,24(sp)
    800043e4:	e86a                	sd	s10,16(sp)
    800043e6:	e46e                	sd	s11,8(sp)
    800043e8:	1880                	addi	s0,sp,112
    800043ea:	8aaa                	mv	s5,a0
    800043ec:	8bae                	mv	s7,a1
    800043ee:	8a32                	mv	s4,a2
    800043f0:	8936                	mv	s2,a3
    800043f2:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800043f4:	00e687bb          	addw	a5,a3,a4
    800043f8:	0cd7e463          	bltu	a5,a3,800044c0 <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800043fc:	00043737          	lui	a4,0x43
    80004400:	0cf76263          	bltu	a4,a5,800044c4 <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004404:	0a0b0a63          	beqz	s6,800044b8 <writei+0xf2>
    80004408:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000440a:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000440e:	5c7d                	li	s8,-1
    80004410:	a825                	j	80004448 <writei+0x82>
    80004412:	020d1d93          	slli	s11,s10,0x20
    80004416:	020ddd93          	srli	s11,s11,0x20
    8000441a:	05848793          	addi	a5,s1,88
    8000441e:	86ee                	mv	a3,s11
    80004420:	8652                	mv	a2,s4
    80004422:	85de                	mv	a1,s7
    80004424:	953e                	add	a0,a0,a5
    80004426:	a3bfe0ef          	jal	ra,80002e60 <either_copyin>
    8000442a:	05850a63          	beq	a0,s8,8000447e <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000442e:	8526                	mv	a0,s1
    80004430:	688000ef          	jal	ra,80004ab8 <log_write>
    brelse(bp);
    80004434:	8526                	mv	a0,s1
    80004436:	d76ff0ef          	jal	ra,800039ac <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000443a:	013d09bb          	addw	s3,s10,s3
    8000443e:	012d093b          	addw	s2,s10,s2
    80004442:	9a6e                	add	s4,s4,s11
    80004444:	0569f063          	bgeu	s3,s6,80004484 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80004448:	00a9559b          	srliw	a1,s2,0xa
    8000444c:	8556                	mv	a0,s5
    8000444e:	fd0ff0ef          	jal	ra,80003c1e <bmap>
    80004452:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004456:	c59d                	beqz	a1,80004484 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80004458:	000aa503          	lw	a0,0(s5)
    8000445c:	c48ff0ef          	jal	ra,800038a4 <bread>
    80004460:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004462:	3ff97513          	andi	a0,s2,1023
    80004466:	40ac87bb          	subw	a5,s9,a0
    8000446a:	413b073b          	subw	a4,s6,s3
    8000446e:	8d3e                	mv	s10,a5
    80004470:	2781                	sext.w	a5,a5
    80004472:	0007069b          	sext.w	a3,a4
    80004476:	f8f6fee3          	bgeu	a3,a5,80004412 <writei+0x4c>
    8000447a:	8d3a                	mv	s10,a4
    8000447c:	bf59                	j	80004412 <writei+0x4c>
      brelse(bp);
    8000447e:	8526                	mv	a0,s1
    80004480:	d2cff0ef          	jal	ra,800039ac <brelse>
  }

  if(off > ip->size)
    80004484:	04caa783          	lw	a5,76(s5)
    80004488:	0127f463          	bgeu	a5,s2,80004490 <writei+0xca>
    ip->size = off;
    8000448c:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004490:	8556                	mv	a0,s5
    80004492:	a13ff0ef          	jal	ra,80003ea4 <iupdate>

  return tot;
    80004496:	0009851b          	sext.w	a0,s3
}
    8000449a:	70a6                	ld	ra,104(sp)
    8000449c:	7406                	ld	s0,96(sp)
    8000449e:	64e6                	ld	s1,88(sp)
    800044a0:	6946                	ld	s2,80(sp)
    800044a2:	69a6                	ld	s3,72(sp)
    800044a4:	6a06                	ld	s4,64(sp)
    800044a6:	7ae2                	ld	s5,56(sp)
    800044a8:	7b42                	ld	s6,48(sp)
    800044aa:	7ba2                	ld	s7,40(sp)
    800044ac:	7c02                	ld	s8,32(sp)
    800044ae:	6ce2                	ld	s9,24(sp)
    800044b0:	6d42                	ld	s10,16(sp)
    800044b2:	6da2                	ld	s11,8(sp)
    800044b4:	6165                	addi	sp,sp,112
    800044b6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800044b8:	89da                	mv	s3,s6
    800044ba:	bfd9                	j	80004490 <writei+0xca>
    return -1;
    800044bc:	557d                	li	a0,-1
}
    800044be:	8082                	ret
    return -1;
    800044c0:	557d                	li	a0,-1
    800044c2:	bfe1                	j	8000449a <writei+0xd4>
    return -1;
    800044c4:	557d                	li	a0,-1
    800044c6:	bfd1                	j	8000449a <writei+0xd4>

00000000800044c8 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800044c8:	1141                	addi	sp,sp,-16
    800044ca:	e406                	sd	ra,8(sp)
    800044cc:	e022                	sd	s0,0(sp)
    800044ce:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800044d0:	4639                	li	a2,14
    800044d2:	83bfc0ef          	jal	ra,80000d0c <strncmp>
}
    800044d6:	60a2                	ld	ra,8(sp)
    800044d8:	6402                	ld	s0,0(sp)
    800044da:	0141                	addi	sp,sp,16
    800044dc:	8082                	ret

00000000800044de <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800044de:	7139                	addi	sp,sp,-64
    800044e0:	fc06                	sd	ra,56(sp)
    800044e2:	f822                	sd	s0,48(sp)
    800044e4:	f426                	sd	s1,40(sp)
    800044e6:	f04a                	sd	s2,32(sp)
    800044e8:	ec4e                	sd	s3,24(sp)
    800044ea:	e852                	sd	s4,16(sp)
    800044ec:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800044ee:	04451703          	lh	a4,68(a0)
    800044f2:	4785                	li	a5,1
    800044f4:	00f71a63          	bne	a4,a5,80004508 <dirlookup+0x2a>
    800044f8:	892a                	mv	s2,a0
    800044fa:	89ae                	mv	s3,a1
    800044fc:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800044fe:	457c                	lw	a5,76(a0)
    80004500:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004502:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004504:	e39d                	bnez	a5,8000452a <dirlookup+0x4c>
    80004506:	a095                	j	8000456a <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80004508:	00004517          	auipc	a0,0x4
    8000450c:	4c050513          	addi	a0,a0,1216 # 800089c8 <syscalls+0x1c8>
    80004510:	a7afc0ef          	jal	ra,8000078a <panic>
      panic("dirlookup read");
    80004514:	00004517          	auipc	a0,0x4
    80004518:	4cc50513          	addi	a0,a0,1228 # 800089e0 <syscalls+0x1e0>
    8000451c:	a6efc0ef          	jal	ra,8000078a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004520:	24c1                	addiw	s1,s1,16
    80004522:	04c92783          	lw	a5,76(s2)
    80004526:	04f4f163          	bgeu	s1,a5,80004568 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000452a:	4741                	li	a4,16
    8000452c:	86a6                	mv	a3,s1
    8000452e:	fc040613          	addi	a2,s0,-64
    80004532:	4581                	li	a1,0
    80004534:	854a                	mv	a0,s2
    80004536:	dadff0ef          	jal	ra,800042e2 <readi>
    8000453a:	47c1                	li	a5,16
    8000453c:	fcf51ce3          	bne	a0,a5,80004514 <dirlookup+0x36>
    if(de.inum == 0)
    80004540:	fc045783          	lhu	a5,-64(s0)
    80004544:	dff1                	beqz	a5,80004520 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80004546:	fc240593          	addi	a1,s0,-62
    8000454a:	854e                	mv	a0,s3
    8000454c:	f7dff0ef          	jal	ra,800044c8 <namecmp>
    80004550:	f961                	bnez	a0,80004520 <dirlookup+0x42>
      if(poff)
    80004552:	000a0463          	beqz	s4,8000455a <dirlookup+0x7c>
        *poff = off;
    80004556:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000455a:	fc045583          	lhu	a1,-64(s0)
    8000455e:	00092503          	lw	a0,0(s2)
    80004562:	f88ff0ef          	jal	ra,80003cea <iget>
    80004566:	a011                	j	8000456a <dirlookup+0x8c>
  return 0;
    80004568:	4501                	li	a0,0
}
    8000456a:	70e2                	ld	ra,56(sp)
    8000456c:	7442                	ld	s0,48(sp)
    8000456e:	74a2                	ld	s1,40(sp)
    80004570:	7902                	ld	s2,32(sp)
    80004572:	69e2                	ld	s3,24(sp)
    80004574:	6a42                	ld	s4,16(sp)
    80004576:	6121                	addi	sp,sp,64
    80004578:	8082                	ret

000000008000457a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000457a:	711d                	addi	sp,sp,-96
    8000457c:	ec86                	sd	ra,88(sp)
    8000457e:	e8a2                	sd	s0,80(sp)
    80004580:	e4a6                	sd	s1,72(sp)
    80004582:	e0ca                	sd	s2,64(sp)
    80004584:	fc4e                	sd	s3,56(sp)
    80004586:	f852                	sd	s4,48(sp)
    80004588:	f456                	sd	s5,40(sp)
    8000458a:	f05a                	sd	s6,32(sp)
    8000458c:	ec5e                	sd	s7,24(sp)
    8000458e:	e862                	sd	s8,16(sp)
    80004590:	e466                	sd	s9,8(sp)
    80004592:	1080                	addi	s0,sp,96
    80004594:	84aa                	mv	s1,a0
    80004596:	8aae                	mv	s5,a1
    80004598:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000459a:	00054703          	lbu	a4,0(a0)
    8000459e:	02f00793          	li	a5,47
    800045a2:	00f70f63          	beq	a4,a5,800045c0 <namex+0x46>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800045a6:	e23fd0ef          	jal	ra,800023c8 <myproc>
    800045aa:	15053503          	ld	a0,336(a0)
    800045ae:	973ff0ef          	jal	ra,80003f20 <idup>
    800045b2:	89aa                	mv	s3,a0
  while(*path == '/')
    800045b4:	02f00913          	li	s2,47
  len = path - s;
    800045b8:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    800045ba:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800045bc:	4b85                	li	s7,1
    800045be:	a861                	j	80004656 <namex+0xdc>
    ip = iget(ROOTDEV, ROOTINO);
    800045c0:	4585                	li	a1,1
    800045c2:	4505                	li	a0,1
    800045c4:	f26ff0ef          	jal	ra,80003cea <iget>
    800045c8:	89aa                	mv	s3,a0
    800045ca:	b7ed                	j	800045b4 <namex+0x3a>
      iunlockput(ip);
    800045cc:	854e                	mv	a0,s3
    800045ce:	b8fff0ef          	jal	ra,8000415c <iunlockput>
      return 0;
    800045d2:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800045d4:	854e                	mv	a0,s3
    800045d6:	60e6                	ld	ra,88(sp)
    800045d8:	6446                	ld	s0,80(sp)
    800045da:	64a6                	ld	s1,72(sp)
    800045dc:	6906                	ld	s2,64(sp)
    800045de:	79e2                	ld	s3,56(sp)
    800045e0:	7a42                	ld	s4,48(sp)
    800045e2:	7aa2                	ld	s5,40(sp)
    800045e4:	7b02                	ld	s6,32(sp)
    800045e6:	6be2                	ld	s7,24(sp)
    800045e8:	6c42                	ld	s8,16(sp)
    800045ea:	6ca2                	ld	s9,8(sp)
    800045ec:	6125                	addi	sp,sp,96
    800045ee:	8082                	ret
      iunlock(ip);
    800045f0:	854e                	mv	a0,s3
    800045f2:	a0fff0ef          	jal	ra,80004000 <iunlock>
      return ip;
    800045f6:	bff9                	j	800045d4 <namex+0x5a>
      iunlockput(ip);
    800045f8:	854e                	mv	a0,s3
    800045fa:	b63ff0ef          	jal	ra,8000415c <iunlockput>
      return 0;
    800045fe:	89e6                	mv	s3,s9
    80004600:	bfd1                	j	800045d4 <namex+0x5a>
  len = path - s;
    80004602:	40b48633          	sub	a2,s1,a1
    80004606:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    8000460a:	079c5c63          	bge	s8,s9,80004682 <namex+0x108>
    memmove(name, s, DIRSIZ);
    8000460e:	4639                	li	a2,14
    80004610:	8552                	mv	a0,s4
    80004612:	e8afc0ef          	jal	ra,80000c9c <memmove>
  while(*path == '/')
    80004616:	0004c783          	lbu	a5,0(s1)
    8000461a:	01279763          	bne	a5,s2,80004628 <namex+0xae>
    path++;
    8000461e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004620:	0004c783          	lbu	a5,0(s1)
    80004624:	ff278de3          	beq	a5,s2,8000461e <namex+0xa4>
    ilock(ip);
    80004628:	854e                	mv	a0,s3
    8000462a:	92dff0ef          	jal	ra,80003f56 <ilock>
    if(ip->type != T_DIR){
    8000462e:	04499783          	lh	a5,68(s3)
    80004632:	f9779de3          	bne	a5,s7,800045cc <namex+0x52>
    if(nameiparent && *path == '\0'){
    80004636:	000a8563          	beqz	s5,80004640 <namex+0xc6>
    8000463a:	0004c783          	lbu	a5,0(s1)
    8000463e:	dbcd                	beqz	a5,800045f0 <namex+0x76>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004640:	865a                	mv	a2,s6
    80004642:	85d2                	mv	a1,s4
    80004644:	854e                	mv	a0,s3
    80004646:	e99ff0ef          	jal	ra,800044de <dirlookup>
    8000464a:	8caa                	mv	s9,a0
    8000464c:	d555                	beqz	a0,800045f8 <namex+0x7e>
    iunlockput(ip);
    8000464e:	854e                	mv	a0,s3
    80004650:	b0dff0ef          	jal	ra,8000415c <iunlockput>
    ip = next;
    80004654:	89e6                	mv	s3,s9
  while(*path == '/')
    80004656:	0004c783          	lbu	a5,0(s1)
    8000465a:	05279363          	bne	a5,s2,800046a0 <namex+0x126>
    path++;
    8000465e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004660:	0004c783          	lbu	a5,0(s1)
    80004664:	ff278de3          	beq	a5,s2,8000465e <namex+0xe4>
  if(*path == 0)
    80004668:	c78d                	beqz	a5,80004692 <namex+0x118>
    path++;
    8000466a:	85a6                	mv	a1,s1
  len = path - s;
    8000466c:	8cda                	mv	s9,s6
    8000466e:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004670:	01278963          	beq	a5,s2,80004682 <namex+0x108>
    80004674:	d7d9                	beqz	a5,80004602 <namex+0x88>
    path++;
    80004676:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004678:	0004c783          	lbu	a5,0(s1)
    8000467c:	ff279ce3          	bne	a5,s2,80004674 <namex+0xfa>
    80004680:	b749                	j	80004602 <namex+0x88>
    memmove(name, s, len);
    80004682:	2601                	sext.w	a2,a2
    80004684:	8552                	mv	a0,s4
    80004686:	e16fc0ef          	jal	ra,80000c9c <memmove>
    name[len] = 0;
    8000468a:	9cd2                	add	s9,s9,s4
    8000468c:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004690:	b759                	j	80004616 <namex+0x9c>
  if(nameiparent){
    80004692:	f40a81e3          	beqz	s5,800045d4 <namex+0x5a>
    iput(ip);
    80004696:	854e                	mv	a0,s3
    80004698:	a3dff0ef          	jal	ra,800040d4 <iput>
    return 0;
    8000469c:	4981                	li	s3,0
    8000469e:	bf1d                	j	800045d4 <namex+0x5a>
  if(*path == 0)
    800046a0:	dbed                	beqz	a5,80004692 <namex+0x118>
  while(*path != '/' && *path != 0)
    800046a2:	0004c783          	lbu	a5,0(s1)
    800046a6:	85a6                	mv	a1,s1
    800046a8:	b7f1                	j	80004674 <namex+0xfa>

00000000800046aa <dirlink>:
{
    800046aa:	7139                	addi	sp,sp,-64
    800046ac:	fc06                	sd	ra,56(sp)
    800046ae:	f822                	sd	s0,48(sp)
    800046b0:	f426                	sd	s1,40(sp)
    800046b2:	f04a                	sd	s2,32(sp)
    800046b4:	ec4e                	sd	s3,24(sp)
    800046b6:	e852                	sd	s4,16(sp)
    800046b8:	0080                	addi	s0,sp,64
    800046ba:	892a                	mv	s2,a0
    800046bc:	8a2e                	mv	s4,a1
    800046be:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800046c0:	4601                	li	a2,0
    800046c2:	e1dff0ef          	jal	ra,800044de <dirlookup>
    800046c6:	e52d                	bnez	a0,80004730 <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800046c8:	04c92483          	lw	s1,76(s2)
    800046cc:	c48d                	beqz	s1,800046f6 <dirlink+0x4c>
    800046ce:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800046d0:	4741                	li	a4,16
    800046d2:	86a6                	mv	a3,s1
    800046d4:	fc040613          	addi	a2,s0,-64
    800046d8:	4581                	li	a1,0
    800046da:	854a                	mv	a0,s2
    800046dc:	c07ff0ef          	jal	ra,800042e2 <readi>
    800046e0:	47c1                	li	a5,16
    800046e2:	04f51b63          	bne	a0,a5,80004738 <dirlink+0x8e>
    if(de.inum == 0)
    800046e6:	fc045783          	lhu	a5,-64(s0)
    800046ea:	c791                	beqz	a5,800046f6 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800046ec:	24c1                	addiw	s1,s1,16
    800046ee:	04c92783          	lw	a5,76(s2)
    800046f2:	fcf4efe3          	bltu	s1,a5,800046d0 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    800046f6:	4639                	li	a2,14
    800046f8:	85d2                	mv	a1,s4
    800046fa:	fc240513          	addi	a0,s0,-62
    800046fe:	e4afc0ef          	jal	ra,80000d48 <strncpy>
  de.inum = inum;
    80004702:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004706:	4741                	li	a4,16
    80004708:	86a6                	mv	a3,s1
    8000470a:	fc040613          	addi	a2,s0,-64
    8000470e:	4581                	li	a1,0
    80004710:	854a                	mv	a0,s2
    80004712:	cb5ff0ef          	jal	ra,800043c6 <writei>
    80004716:	1541                	addi	a0,a0,-16
    80004718:	00a03533          	snez	a0,a0
    8000471c:	40a00533          	neg	a0,a0
}
    80004720:	70e2                	ld	ra,56(sp)
    80004722:	7442                	ld	s0,48(sp)
    80004724:	74a2                	ld	s1,40(sp)
    80004726:	7902                	ld	s2,32(sp)
    80004728:	69e2                	ld	s3,24(sp)
    8000472a:	6a42                	ld	s4,16(sp)
    8000472c:	6121                	addi	sp,sp,64
    8000472e:	8082                	ret
    iput(ip);
    80004730:	9a5ff0ef          	jal	ra,800040d4 <iput>
    return -1;
    80004734:	557d                	li	a0,-1
    80004736:	b7ed                	j	80004720 <dirlink+0x76>
      panic("dirlink read");
    80004738:	00004517          	auipc	a0,0x4
    8000473c:	2b850513          	addi	a0,a0,696 # 800089f0 <syscalls+0x1f0>
    80004740:	84afc0ef          	jal	ra,8000078a <panic>

0000000080004744 <namei>:

struct inode*
namei(char *path)
{
    80004744:	1101                	addi	sp,sp,-32
    80004746:	ec06                	sd	ra,24(sp)
    80004748:	e822                	sd	s0,16(sp)
    8000474a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000474c:	fe040613          	addi	a2,s0,-32
    80004750:	4581                	li	a1,0
    80004752:	e29ff0ef          	jal	ra,8000457a <namex>
}
    80004756:	60e2                	ld	ra,24(sp)
    80004758:	6442                	ld	s0,16(sp)
    8000475a:	6105                	addi	sp,sp,32
    8000475c:	8082                	ret

000000008000475e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000475e:	1141                	addi	sp,sp,-16
    80004760:	e406                	sd	ra,8(sp)
    80004762:	e022                	sd	s0,0(sp)
    80004764:	0800                	addi	s0,sp,16
    80004766:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004768:	4585                	li	a1,1
    8000476a:	e11ff0ef          	jal	ra,8000457a <namex>
}
    8000476e:	60a2                	ld	ra,8(sp)
    80004770:	6402                	ld	s0,0(sp)
    80004772:	0141                	addi	sp,sp,16
    80004774:	8082                	ret

0000000080004776 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004776:	1101                	addi	sp,sp,-32
    80004778:	ec06                	sd	ra,24(sp)
    8000477a:	e822                	sd	s0,16(sp)
    8000477c:	e426                	sd	s1,8(sp)
    8000477e:	e04a                	sd	s2,0(sp)
    80004780:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004782:	00087917          	auipc	s2,0x87
    80004786:	86690913          	addi	s2,s2,-1946 # 8008afe8 <log>
    8000478a:	01892583          	lw	a1,24(s2)
    8000478e:	02492503          	lw	a0,36(s2)
    80004792:	912ff0ef          	jal	ra,800038a4 <bread>
    80004796:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004798:	02892683          	lw	a3,40(s2)
    8000479c:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000479e:	02d05763          	blez	a3,800047cc <write_head+0x56>
    800047a2:	00087797          	auipc	a5,0x87
    800047a6:	87278793          	addi	a5,a5,-1934 # 8008b014 <log+0x2c>
    800047aa:	05c50713          	addi	a4,a0,92
    800047ae:	36fd                	addiw	a3,a3,-1
    800047b0:	1682                	slli	a3,a3,0x20
    800047b2:	9281                	srli	a3,a3,0x20
    800047b4:	068a                	slli	a3,a3,0x2
    800047b6:	00087617          	auipc	a2,0x87
    800047ba:	86260613          	addi	a2,a2,-1950 # 8008b018 <log+0x30>
    800047be:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800047c0:	4390                	lw	a2,0(a5)
    800047c2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800047c4:	0791                	addi	a5,a5,4
    800047c6:	0711                	addi	a4,a4,4
    800047c8:	fed79ce3          	bne	a5,a3,800047c0 <write_head+0x4a>
  }
  bwrite(buf);
    800047cc:	8526                	mv	a0,s1
    800047ce:	9acff0ef          	jal	ra,8000397a <bwrite>
  brelse(buf);
    800047d2:	8526                	mv	a0,s1
    800047d4:	9d8ff0ef          	jal	ra,800039ac <brelse>
}
    800047d8:	60e2                	ld	ra,24(sp)
    800047da:	6442                	ld	s0,16(sp)
    800047dc:	64a2                	ld	s1,8(sp)
    800047de:	6902                	ld	s2,0(sp)
    800047e0:	6105                	addi	sp,sp,32
    800047e2:	8082                	ret

00000000800047e4 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800047e4:	00087797          	auipc	a5,0x87
    800047e8:	82c7a783          	lw	a5,-2004(a5) # 8008b010 <log+0x28>
    800047ec:	0af05e63          	blez	a5,800048a8 <install_trans+0xc4>
{
    800047f0:	715d                	addi	sp,sp,-80
    800047f2:	e486                	sd	ra,72(sp)
    800047f4:	e0a2                	sd	s0,64(sp)
    800047f6:	fc26                	sd	s1,56(sp)
    800047f8:	f84a                	sd	s2,48(sp)
    800047fa:	f44e                	sd	s3,40(sp)
    800047fc:	f052                	sd	s4,32(sp)
    800047fe:	ec56                	sd	s5,24(sp)
    80004800:	e85a                	sd	s6,16(sp)
    80004802:	e45e                	sd	s7,8(sp)
    80004804:	0880                	addi	s0,sp,80
    80004806:	8b2a                	mv	s6,a0
    80004808:	00087a97          	auipc	s5,0x87
    8000480c:	80ca8a93          	addi	s5,s5,-2036 # 8008b014 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004810:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004812:	00004b97          	auipc	s7,0x4
    80004816:	1eeb8b93          	addi	s7,s7,494 # 80008a00 <syscalls+0x200>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000481a:	00086a17          	auipc	s4,0x86
    8000481e:	7cea0a13          	addi	s4,s4,1998 # 8008afe8 <log>
    80004822:	a025                	j	8000484a <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004824:	000aa603          	lw	a2,0(s5)
    80004828:	85ce                	mv	a1,s3
    8000482a:	855e                	mv	a0,s7
    8000482c:	c99fb0ef          	jal	ra,800004c4 <printf>
    80004830:	a839                	j	8000484e <install_trans+0x6a>
    brelse(lbuf);
    80004832:	854a                	mv	a0,s2
    80004834:	978ff0ef          	jal	ra,800039ac <brelse>
    brelse(dbuf);
    80004838:	8526                	mv	a0,s1
    8000483a:	972ff0ef          	jal	ra,800039ac <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000483e:	2985                	addiw	s3,s3,1
    80004840:	0a91                	addi	s5,s5,4
    80004842:	028a2783          	lw	a5,40(s4)
    80004846:	04f9d663          	bge	s3,a5,80004892 <install_trans+0xae>
    if(recovering) {
    8000484a:	fc0b1de3          	bnez	s6,80004824 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000484e:	018a2583          	lw	a1,24(s4)
    80004852:	013585bb          	addw	a1,a1,s3
    80004856:	2585                	addiw	a1,a1,1
    80004858:	024a2503          	lw	a0,36(s4)
    8000485c:	848ff0ef          	jal	ra,800038a4 <bread>
    80004860:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004862:	000aa583          	lw	a1,0(s5)
    80004866:	024a2503          	lw	a0,36(s4)
    8000486a:	83aff0ef          	jal	ra,800038a4 <bread>
    8000486e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004870:	40000613          	li	a2,1024
    80004874:	05890593          	addi	a1,s2,88
    80004878:	05850513          	addi	a0,a0,88
    8000487c:	c20fc0ef          	jal	ra,80000c9c <memmove>
    bwrite(dbuf);  // write dst to disk
    80004880:	8526                	mv	a0,s1
    80004882:	8f8ff0ef          	jal	ra,8000397a <bwrite>
    if(recovering == 0)
    80004886:	fa0b16e3          	bnez	s6,80004832 <install_trans+0x4e>
      bunpin(dbuf);
    8000488a:	8526                	mv	a0,s1
    8000488c:	9deff0ef          	jal	ra,80003a6a <bunpin>
    80004890:	b74d                	j	80004832 <install_trans+0x4e>
}
    80004892:	60a6                	ld	ra,72(sp)
    80004894:	6406                	ld	s0,64(sp)
    80004896:	74e2                	ld	s1,56(sp)
    80004898:	7942                	ld	s2,48(sp)
    8000489a:	79a2                	ld	s3,40(sp)
    8000489c:	7a02                	ld	s4,32(sp)
    8000489e:	6ae2                	ld	s5,24(sp)
    800048a0:	6b42                	ld	s6,16(sp)
    800048a2:	6ba2                	ld	s7,8(sp)
    800048a4:	6161                	addi	sp,sp,80
    800048a6:	8082                	ret
    800048a8:	8082                	ret

00000000800048aa <initlog>:
{
    800048aa:	7179                	addi	sp,sp,-48
    800048ac:	f406                	sd	ra,40(sp)
    800048ae:	f022                	sd	s0,32(sp)
    800048b0:	ec26                	sd	s1,24(sp)
    800048b2:	e84a                	sd	s2,16(sp)
    800048b4:	e44e                	sd	s3,8(sp)
    800048b6:	1800                	addi	s0,sp,48
    800048b8:	892a                	mv	s2,a0
    800048ba:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800048bc:	00086497          	auipc	s1,0x86
    800048c0:	72c48493          	addi	s1,s1,1836 # 8008afe8 <log>
    800048c4:	00004597          	auipc	a1,0x4
    800048c8:	15c58593          	addi	a1,a1,348 # 80008a20 <syscalls+0x220>
    800048cc:	8526                	mv	a0,s1
    800048ce:	a1efc0ef          	jal	ra,80000aec <initlock>
  log.start = sb->logstart;
    800048d2:	0149a583          	lw	a1,20(s3)
    800048d6:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    800048d8:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    800048dc:	854a                	mv	a0,s2
    800048de:	fc7fe0ef          	jal	ra,800038a4 <bread>
  log.lh.n = lh->n;
    800048e2:	4d34                	lw	a3,88(a0)
    800048e4:	d494                	sw	a3,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    800048e6:	02d05563          	blez	a3,80004910 <initlog+0x66>
    800048ea:	05c50793          	addi	a5,a0,92
    800048ee:	00086717          	auipc	a4,0x86
    800048f2:	72670713          	addi	a4,a4,1830 # 8008b014 <log+0x2c>
    800048f6:	36fd                	addiw	a3,a3,-1
    800048f8:	1682                	slli	a3,a3,0x20
    800048fa:	9281                	srli	a3,a3,0x20
    800048fc:	068a                	slli	a3,a3,0x2
    800048fe:	06050613          	addi	a2,a0,96
    80004902:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004904:	4390                	lw	a2,0(a5)
    80004906:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004908:	0791                	addi	a5,a5,4
    8000490a:	0711                	addi	a4,a4,4
    8000490c:	fed79ce3          	bne	a5,a3,80004904 <initlog+0x5a>
  brelse(buf);
    80004910:	89cff0ef          	jal	ra,800039ac <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004914:	4505                	li	a0,1
    80004916:	ecfff0ef          	jal	ra,800047e4 <install_trans>
  log.lh.n = 0;
    8000491a:	00086797          	auipc	a5,0x86
    8000491e:	6e07ab23          	sw	zero,1782(a5) # 8008b010 <log+0x28>
  write_head(); // clear the log
    80004922:	e55ff0ef          	jal	ra,80004776 <write_head>
}
    80004926:	70a2                	ld	ra,40(sp)
    80004928:	7402                	ld	s0,32(sp)
    8000492a:	64e2                	ld	s1,24(sp)
    8000492c:	6942                	ld	s2,16(sp)
    8000492e:	69a2                	ld	s3,8(sp)
    80004930:	6145                	addi	sp,sp,48
    80004932:	8082                	ret

0000000080004934 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004934:	1101                	addi	sp,sp,-32
    80004936:	ec06                	sd	ra,24(sp)
    80004938:	e822                	sd	s0,16(sp)
    8000493a:	e426                	sd	s1,8(sp)
    8000493c:	e04a                	sd	s2,0(sp)
    8000493e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004940:	00086517          	auipc	a0,0x86
    80004944:	6a850513          	addi	a0,a0,1704 # 8008afe8 <log>
    80004948:	a24fc0ef          	jal	ra,80000b6c <acquire>
  while(1){
    if(log.committing){
    8000494c:	00086497          	auipc	s1,0x86
    80004950:	69c48493          	addi	s1,s1,1692 # 8008afe8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004954:	4979                	li	s2,30
    80004956:	a029                	j	80004960 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80004958:	85a6                	mv	a1,s1
    8000495a:	8526                	mv	a0,s1
    8000495c:	90efe0ef          	jal	ra,80002a6a <sleep>
    if(log.committing){
    80004960:	509c                	lw	a5,32(s1)
    80004962:	fbfd                	bnez	a5,80004958 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004964:	4cdc                	lw	a5,28(s1)
    80004966:	0017871b          	addiw	a4,a5,1
    8000496a:	0007069b          	sext.w	a3,a4
    8000496e:	0027179b          	slliw	a5,a4,0x2
    80004972:	9fb9                	addw	a5,a5,a4
    80004974:	0017979b          	slliw	a5,a5,0x1
    80004978:	5498                	lw	a4,40(s1)
    8000497a:	9fb9                	addw	a5,a5,a4
    8000497c:	00f95763          	bge	s2,a5,8000498a <begin_op+0x56>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004980:	85a6                	mv	a1,s1
    80004982:	8526                	mv	a0,s1
    80004984:	8e6fe0ef          	jal	ra,80002a6a <sleep>
    80004988:	bfe1                	j	80004960 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    8000498a:	00086517          	auipc	a0,0x86
    8000498e:	65e50513          	addi	a0,a0,1630 # 8008afe8 <log>
    80004992:	cd54                	sw	a3,28(a0)
      release(&log.lock);
    80004994:	a70fc0ef          	jal	ra,80000c04 <release>
      break;
    }
  }
}
    80004998:	60e2                	ld	ra,24(sp)
    8000499a:	6442                	ld	s0,16(sp)
    8000499c:	64a2                	ld	s1,8(sp)
    8000499e:	6902                	ld	s2,0(sp)
    800049a0:	6105                	addi	sp,sp,32
    800049a2:	8082                	ret

00000000800049a4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800049a4:	7139                	addi	sp,sp,-64
    800049a6:	fc06                	sd	ra,56(sp)
    800049a8:	f822                	sd	s0,48(sp)
    800049aa:	f426                	sd	s1,40(sp)
    800049ac:	f04a                	sd	s2,32(sp)
    800049ae:	ec4e                	sd	s3,24(sp)
    800049b0:	e852                	sd	s4,16(sp)
    800049b2:	e456                	sd	s5,8(sp)
    800049b4:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800049b6:	00086497          	auipc	s1,0x86
    800049ba:	63248493          	addi	s1,s1,1586 # 8008afe8 <log>
    800049be:	8526                	mv	a0,s1
    800049c0:	9acfc0ef          	jal	ra,80000b6c <acquire>
  log.outstanding -= 1;
    800049c4:	4cdc                	lw	a5,28(s1)
    800049c6:	37fd                	addiw	a5,a5,-1
    800049c8:	0007891b          	sext.w	s2,a5
    800049cc:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    800049ce:	509c                	lw	a5,32(s1)
    800049d0:	ef9d                	bnez	a5,80004a0e <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    800049d2:	04091463          	bnez	s2,80004a1a <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    800049d6:	00086497          	auipc	s1,0x86
    800049da:	61248493          	addi	s1,s1,1554 # 8008afe8 <log>
    800049de:	4785                	li	a5,1
    800049e0:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800049e2:	8526                	mv	a0,s1
    800049e4:	a20fc0ef          	jal	ra,80000c04 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800049e8:	549c                	lw	a5,40(s1)
    800049ea:	04f04b63          	bgtz	a5,80004a40 <end_op+0x9c>
    acquire(&log.lock);
    800049ee:	00086497          	auipc	s1,0x86
    800049f2:	5fa48493          	addi	s1,s1,1530 # 8008afe8 <log>
    800049f6:	8526                	mv	a0,s1
    800049f8:	974fc0ef          	jal	ra,80000b6c <acquire>
    log.committing = 0;
    800049fc:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80004a00:	8526                	mv	a0,s1
    80004a02:	8b4fe0ef          	jal	ra,80002ab6 <wakeup>
    release(&log.lock);
    80004a06:	8526                	mv	a0,s1
    80004a08:	9fcfc0ef          	jal	ra,80000c04 <release>
}
    80004a0c:	a00d                	j	80004a2e <end_op+0x8a>
    panic("log.committing");
    80004a0e:	00004517          	auipc	a0,0x4
    80004a12:	01a50513          	addi	a0,a0,26 # 80008a28 <syscalls+0x228>
    80004a16:	d75fb0ef          	jal	ra,8000078a <panic>
    wakeup(&log);
    80004a1a:	00086497          	auipc	s1,0x86
    80004a1e:	5ce48493          	addi	s1,s1,1486 # 8008afe8 <log>
    80004a22:	8526                	mv	a0,s1
    80004a24:	892fe0ef          	jal	ra,80002ab6 <wakeup>
  release(&log.lock);
    80004a28:	8526                	mv	a0,s1
    80004a2a:	9dafc0ef          	jal	ra,80000c04 <release>
}
    80004a2e:	70e2                	ld	ra,56(sp)
    80004a30:	7442                	ld	s0,48(sp)
    80004a32:	74a2                	ld	s1,40(sp)
    80004a34:	7902                	ld	s2,32(sp)
    80004a36:	69e2                	ld	s3,24(sp)
    80004a38:	6a42                	ld	s4,16(sp)
    80004a3a:	6aa2                	ld	s5,8(sp)
    80004a3c:	6121                	addi	sp,sp,64
    80004a3e:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a40:	00086a97          	auipc	s5,0x86
    80004a44:	5d4a8a93          	addi	s5,s5,1492 # 8008b014 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004a48:	00086a17          	auipc	s4,0x86
    80004a4c:	5a0a0a13          	addi	s4,s4,1440 # 8008afe8 <log>
    80004a50:	018a2583          	lw	a1,24(s4)
    80004a54:	012585bb          	addw	a1,a1,s2
    80004a58:	2585                	addiw	a1,a1,1
    80004a5a:	024a2503          	lw	a0,36(s4)
    80004a5e:	e47fe0ef          	jal	ra,800038a4 <bread>
    80004a62:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004a64:	000aa583          	lw	a1,0(s5)
    80004a68:	024a2503          	lw	a0,36(s4)
    80004a6c:	e39fe0ef          	jal	ra,800038a4 <bread>
    80004a70:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004a72:	40000613          	li	a2,1024
    80004a76:	05850593          	addi	a1,a0,88
    80004a7a:	05848513          	addi	a0,s1,88
    80004a7e:	a1efc0ef          	jal	ra,80000c9c <memmove>
    bwrite(to);  // write the log
    80004a82:	8526                	mv	a0,s1
    80004a84:	ef7fe0ef          	jal	ra,8000397a <bwrite>
    brelse(from);
    80004a88:	854e                	mv	a0,s3
    80004a8a:	f23fe0ef          	jal	ra,800039ac <brelse>
    brelse(to);
    80004a8e:	8526                	mv	a0,s1
    80004a90:	f1dfe0ef          	jal	ra,800039ac <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a94:	2905                	addiw	s2,s2,1
    80004a96:	0a91                	addi	s5,s5,4
    80004a98:	028a2783          	lw	a5,40(s4)
    80004a9c:	faf94ae3          	blt	s2,a5,80004a50 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004aa0:	cd7ff0ef          	jal	ra,80004776 <write_head>
    install_trans(0); // Now install writes to home locations
    80004aa4:	4501                	li	a0,0
    80004aa6:	d3fff0ef          	jal	ra,800047e4 <install_trans>
    log.lh.n = 0;
    80004aaa:	00086797          	auipc	a5,0x86
    80004aae:	5607a323          	sw	zero,1382(a5) # 8008b010 <log+0x28>
    write_head();    // Erase the transaction from the log
    80004ab2:	cc5ff0ef          	jal	ra,80004776 <write_head>
    80004ab6:	bf25                	j	800049ee <end_op+0x4a>

0000000080004ab8 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004ab8:	1101                	addi	sp,sp,-32
    80004aba:	ec06                	sd	ra,24(sp)
    80004abc:	e822                	sd	s0,16(sp)
    80004abe:	e426                	sd	s1,8(sp)
    80004ac0:	e04a                	sd	s2,0(sp)
    80004ac2:	1000                	addi	s0,sp,32
    80004ac4:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004ac6:	00086917          	auipc	s2,0x86
    80004aca:	52290913          	addi	s2,s2,1314 # 8008afe8 <log>
    80004ace:	854a                	mv	a0,s2
    80004ad0:	89cfc0ef          	jal	ra,80000b6c <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80004ad4:	02892603          	lw	a2,40(s2)
    80004ad8:	47f5                	li	a5,29
    80004ada:	04c7cc63          	blt	a5,a2,80004b32 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004ade:	00086797          	auipc	a5,0x86
    80004ae2:	5267a783          	lw	a5,1318(a5) # 8008b004 <log+0x1c>
    80004ae6:	04f05c63          	blez	a5,80004b3e <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004aea:	4781                	li	a5,0
    80004aec:	04c05f63          	blez	a2,80004b4a <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004af0:	44cc                	lw	a1,12(s1)
    80004af2:	00086717          	auipc	a4,0x86
    80004af6:	52270713          	addi	a4,a4,1314 # 8008b014 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004afa:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004afc:	4314                	lw	a3,0(a4)
    80004afe:	04b68663          	beq	a3,a1,80004b4a <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80004b02:	2785                	addiw	a5,a5,1
    80004b04:	0711                	addi	a4,a4,4
    80004b06:	fef61be3          	bne	a2,a5,80004afc <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004b0a:	0621                	addi	a2,a2,8
    80004b0c:	060a                	slli	a2,a2,0x2
    80004b0e:	00086797          	auipc	a5,0x86
    80004b12:	4da78793          	addi	a5,a5,1242 # 8008afe8 <log>
    80004b16:	963e                	add	a2,a2,a5
    80004b18:	44dc                	lw	a5,12(s1)
    80004b1a:	c65c                	sw	a5,12(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004b1c:	8526                	mv	a0,s1
    80004b1e:	f19fe0ef          	jal	ra,80003a36 <bpin>
    log.lh.n++;
    80004b22:	00086717          	auipc	a4,0x86
    80004b26:	4c670713          	addi	a4,a4,1222 # 8008afe8 <log>
    80004b2a:	571c                	lw	a5,40(a4)
    80004b2c:	2785                	addiw	a5,a5,1
    80004b2e:	d71c                	sw	a5,40(a4)
    80004b30:	a815                	j	80004b64 <log_write+0xac>
    panic("too big a transaction");
    80004b32:	00004517          	auipc	a0,0x4
    80004b36:	f0650513          	addi	a0,a0,-250 # 80008a38 <syscalls+0x238>
    80004b3a:	c51fb0ef          	jal	ra,8000078a <panic>
    panic("log_write outside of trans");
    80004b3e:	00004517          	auipc	a0,0x4
    80004b42:	f1250513          	addi	a0,a0,-238 # 80008a50 <syscalls+0x250>
    80004b46:	c45fb0ef          	jal	ra,8000078a <panic>
  log.lh.block[i] = b->blockno;
    80004b4a:	00878713          	addi	a4,a5,8
    80004b4e:	00271693          	slli	a3,a4,0x2
    80004b52:	00086717          	auipc	a4,0x86
    80004b56:	49670713          	addi	a4,a4,1174 # 8008afe8 <log>
    80004b5a:	9736                	add	a4,a4,a3
    80004b5c:	44d4                	lw	a3,12(s1)
    80004b5e:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004b60:	faf60ee3          	beq	a2,a5,80004b1c <log_write+0x64>
  }
  release(&log.lock);
    80004b64:	00086517          	auipc	a0,0x86
    80004b68:	48450513          	addi	a0,a0,1156 # 8008afe8 <log>
    80004b6c:	898fc0ef          	jal	ra,80000c04 <release>
}
    80004b70:	60e2                	ld	ra,24(sp)
    80004b72:	6442                	ld	s0,16(sp)
    80004b74:	64a2                	ld	s1,8(sp)
    80004b76:	6902                	ld	s2,0(sp)
    80004b78:	6105                	addi	sp,sp,32
    80004b7a:	8082                	ret

0000000080004b7c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004b7c:	1101                	addi	sp,sp,-32
    80004b7e:	ec06                	sd	ra,24(sp)
    80004b80:	e822                	sd	s0,16(sp)
    80004b82:	e426                	sd	s1,8(sp)
    80004b84:	e04a                	sd	s2,0(sp)
    80004b86:	1000                	addi	s0,sp,32
    80004b88:	84aa                	mv	s1,a0
    80004b8a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004b8c:	00004597          	auipc	a1,0x4
    80004b90:	ee458593          	addi	a1,a1,-284 # 80008a70 <syscalls+0x270>
    80004b94:	0521                	addi	a0,a0,8
    80004b96:	f57fb0ef          	jal	ra,80000aec <initlock>
  lk->name = name;
    80004b9a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004b9e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004ba2:	0204a423          	sw	zero,40(s1)
}
    80004ba6:	60e2                	ld	ra,24(sp)
    80004ba8:	6442                	ld	s0,16(sp)
    80004baa:	64a2                	ld	s1,8(sp)
    80004bac:	6902                	ld	s2,0(sp)
    80004bae:	6105                	addi	sp,sp,32
    80004bb0:	8082                	ret

0000000080004bb2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004bb2:	1101                	addi	sp,sp,-32
    80004bb4:	ec06                	sd	ra,24(sp)
    80004bb6:	e822                	sd	s0,16(sp)
    80004bb8:	e426                	sd	s1,8(sp)
    80004bba:	e04a                	sd	s2,0(sp)
    80004bbc:	1000                	addi	s0,sp,32
    80004bbe:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004bc0:	00850913          	addi	s2,a0,8
    80004bc4:	854a                	mv	a0,s2
    80004bc6:	fa7fb0ef          	jal	ra,80000b6c <acquire>
  while (lk->locked) {
    80004bca:	409c                	lw	a5,0(s1)
    80004bcc:	c799                	beqz	a5,80004bda <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004bce:	85ca                	mv	a1,s2
    80004bd0:	8526                	mv	a0,s1
    80004bd2:	e99fd0ef          	jal	ra,80002a6a <sleep>
  while (lk->locked) {
    80004bd6:	409c                	lw	a5,0(s1)
    80004bd8:	fbfd                	bnez	a5,80004bce <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004bda:	4785                	li	a5,1
    80004bdc:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004bde:	feafd0ef          	jal	ra,800023c8 <myproc>
    80004be2:	591c                	lw	a5,48(a0)
    80004be4:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004be6:	854a                	mv	a0,s2
    80004be8:	81cfc0ef          	jal	ra,80000c04 <release>
}
    80004bec:	60e2                	ld	ra,24(sp)
    80004bee:	6442                	ld	s0,16(sp)
    80004bf0:	64a2                	ld	s1,8(sp)
    80004bf2:	6902                	ld	s2,0(sp)
    80004bf4:	6105                	addi	sp,sp,32
    80004bf6:	8082                	ret

0000000080004bf8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004bf8:	1101                	addi	sp,sp,-32
    80004bfa:	ec06                	sd	ra,24(sp)
    80004bfc:	e822                	sd	s0,16(sp)
    80004bfe:	e426                	sd	s1,8(sp)
    80004c00:	e04a                	sd	s2,0(sp)
    80004c02:	1000                	addi	s0,sp,32
    80004c04:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004c06:	00850913          	addi	s2,a0,8
    80004c0a:	854a                	mv	a0,s2
    80004c0c:	f61fb0ef          	jal	ra,80000b6c <acquire>
  lk->locked = 0;
    80004c10:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004c14:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004c18:	8526                	mv	a0,s1
    80004c1a:	e9dfd0ef          	jal	ra,80002ab6 <wakeup>
  release(&lk->lk);
    80004c1e:	854a                	mv	a0,s2
    80004c20:	fe5fb0ef          	jal	ra,80000c04 <release>
}
    80004c24:	60e2                	ld	ra,24(sp)
    80004c26:	6442                	ld	s0,16(sp)
    80004c28:	64a2                	ld	s1,8(sp)
    80004c2a:	6902                	ld	s2,0(sp)
    80004c2c:	6105                	addi	sp,sp,32
    80004c2e:	8082                	ret

0000000080004c30 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004c30:	7179                	addi	sp,sp,-48
    80004c32:	f406                	sd	ra,40(sp)
    80004c34:	f022                	sd	s0,32(sp)
    80004c36:	ec26                	sd	s1,24(sp)
    80004c38:	e84a                	sd	s2,16(sp)
    80004c3a:	e44e                	sd	s3,8(sp)
    80004c3c:	1800                	addi	s0,sp,48
    80004c3e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004c40:	00850913          	addi	s2,a0,8
    80004c44:	854a                	mv	a0,s2
    80004c46:	f27fb0ef          	jal	ra,80000b6c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004c4a:	409c                	lw	a5,0(s1)
    80004c4c:	ef89                	bnez	a5,80004c66 <holdingsleep+0x36>
    80004c4e:	4481                	li	s1,0
  release(&lk->lk);
    80004c50:	854a                	mv	a0,s2
    80004c52:	fb3fb0ef          	jal	ra,80000c04 <release>
  return r;
}
    80004c56:	8526                	mv	a0,s1
    80004c58:	70a2                	ld	ra,40(sp)
    80004c5a:	7402                	ld	s0,32(sp)
    80004c5c:	64e2                	ld	s1,24(sp)
    80004c5e:	6942                	ld	s2,16(sp)
    80004c60:	69a2                	ld	s3,8(sp)
    80004c62:	6145                	addi	sp,sp,48
    80004c64:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004c66:	0284a983          	lw	s3,40(s1)
    80004c6a:	f5efd0ef          	jal	ra,800023c8 <myproc>
    80004c6e:	5904                	lw	s1,48(a0)
    80004c70:	413484b3          	sub	s1,s1,s3
    80004c74:	0014b493          	seqz	s1,s1
    80004c78:	bfe1                	j	80004c50 <holdingsleep+0x20>

0000000080004c7a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004c7a:	1141                	addi	sp,sp,-16
    80004c7c:	e406                	sd	ra,8(sp)
    80004c7e:	e022                	sd	s0,0(sp)
    80004c80:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004c82:	00004597          	auipc	a1,0x4
    80004c86:	dfe58593          	addi	a1,a1,-514 # 80008a80 <syscalls+0x280>
    80004c8a:	00086517          	auipc	a0,0x86
    80004c8e:	4a650513          	addi	a0,a0,1190 # 8008b130 <ftable>
    80004c92:	e5bfb0ef          	jal	ra,80000aec <initlock>
}
    80004c96:	60a2                	ld	ra,8(sp)
    80004c98:	6402                	ld	s0,0(sp)
    80004c9a:	0141                	addi	sp,sp,16
    80004c9c:	8082                	ret

0000000080004c9e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004c9e:	1101                	addi	sp,sp,-32
    80004ca0:	ec06                	sd	ra,24(sp)
    80004ca2:	e822                	sd	s0,16(sp)
    80004ca4:	e426                	sd	s1,8(sp)
    80004ca6:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004ca8:	00086517          	auipc	a0,0x86
    80004cac:	48850513          	addi	a0,a0,1160 # 8008b130 <ftable>
    80004cb0:	ebdfb0ef          	jal	ra,80000b6c <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004cb4:	00086497          	auipc	s1,0x86
    80004cb8:	49448493          	addi	s1,s1,1172 # 8008b148 <ftable+0x18>
    80004cbc:	00087717          	auipc	a4,0x87
    80004cc0:	42c70713          	addi	a4,a4,1068 # 8008c0e8 <disk>
    if(f->ref == 0){
    80004cc4:	40dc                	lw	a5,4(s1)
    80004cc6:	cf89                	beqz	a5,80004ce0 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004cc8:	02848493          	addi	s1,s1,40
    80004ccc:	fee49ce3          	bne	s1,a4,80004cc4 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004cd0:	00086517          	auipc	a0,0x86
    80004cd4:	46050513          	addi	a0,a0,1120 # 8008b130 <ftable>
    80004cd8:	f2dfb0ef          	jal	ra,80000c04 <release>
  return 0;
    80004cdc:	4481                	li	s1,0
    80004cde:	a809                	j	80004cf0 <filealloc+0x52>
      f->ref = 1;
    80004ce0:	4785                	li	a5,1
    80004ce2:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004ce4:	00086517          	auipc	a0,0x86
    80004ce8:	44c50513          	addi	a0,a0,1100 # 8008b130 <ftable>
    80004cec:	f19fb0ef          	jal	ra,80000c04 <release>
}
    80004cf0:	8526                	mv	a0,s1
    80004cf2:	60e2                	ld	ra,24(sp)
    80004cf4:	6442                	ld	s0,16(sp)
    80004cf6:	64a2                	ld	s1,8(sp)
    80004cf8:	6105                	addi	sp,sp,32
    80004cfa:	8082                	ret

0000000080004cfc <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004cfc:	1101                	addi	sp,sp,-32
    80004cfe:	ec06                	sd	ra,24(sp)
    80004d00:	e822                	sd	s0,16(sp)
    80004d02:	e426                	sd	s1,8(sp)
    80004d04:	1000                	addi	s0,sp,32
    80004d06:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004d08:	00086517          	auipc	a0,0x86
    80004d0c:	42850513          	addi	a0,a0,1064 # 8008b130 <ftable>
    80004d10:	e5dfb0ef          	jal	ra,80000b6c <acquire>
  if(f->ref < 1)
    80004d14:	40dc                	lw	a5,4(s1)
    80004d16:	02f05063          	blez	a5,80004d36 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004d1a:	2785                	addiw	a5,a5,1
    80004d1c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004d1e:	00086517          	auipc	a0,0x86
    80004d22:	41250513          	addi	a0,a0,1042 # 8008b130 <ftable>
    80004d26:	edffb0ef          	jal	ra,80000c04 <release>
  return f;
}
    80004d2a:	8526                	mv	a0,s1
    80004d2c:	60e2                	ld	ra,24(sp)
    80004d2e:	6442                	ld	s0,16(sp)
    80004d30:	64a2                	ld	s1,8(sp)
    80004d32:	6105                	addi	sp,sp,32
    80004d34:	8082                	ret
    panic("filedup");
    80004d36:	00004517          	auipc	a0,0x4
    80004d3a:	d5250513          	addi	a0,a0,-686 # 80008a88 <syscalls+0x288>
    80004d3e:	a4dfb0ef          	jal	ra,8000078a <panic>

0000000080004d42 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004d42:	7139                	addi	sp,sp,-64
    80004d44:	fc06                	sd	ra,56(sp)
    80004d46:	f822                	sd	s0,48(sp)
    80004d48:	f426                	sd	s1,40(sp)
    80004d4a:	f04a                	sd	s2,32(sp)
    80004d4c:	ec4e                	sd	s3,24(sp)
    80004d4e:	e852                	sd	s4,16(sp)
    80004d50:	e456                	sd	s5,8(sp)
    80004d52:	0080                	addi	s0,sp,64
    80004d54:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004d56:	00086517          	auipc	a0,0x86
    80004d5a:	3da50513          	addi	a0,a0,986 # 8008b130 <ftable>
    80004d5e:	e0ffb0ef          	jal	ra,80000b6c <acquire>
  if(f->ref < 1)
    80004d62:	40dc                	lw	a5,4(s1)
    80004d64:	04f05963          	blez	a5,80004db6 <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    80004d68:	37fd                	addiw	a5,a5,-1
    80004d6a:	0007871b          	sext.w	a4,a5
    80004d6e:	c0dc                	sw	a5,4(s1)
    80004d70:	04e04963          	bgtz	a4,80004dc2 <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004d74:	0004a903          	lw	s2,0(s1)
    80004d78:	0094ca83          	lbu	s5,9(s1)
    80004d7c:	0104ba03          	ld	s4,16(s1)
    80004d80:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004d84:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004d88:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004d8c:	00086517          	auipc	a0,0x86
    80004d90:	3a450513          	addi	a0,a0,932 # 8008b130 <ftable>
    80004d94:	e71fb0ef          	jal	ra,80000c04 <release>

  if(ff.type == FD_PIPE){
    80004d98:	4785                	li	a5,1
    80004d9a:	04f90363          	beq	s2,a5,80004de0 <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004d9e:	3979                	addiw	s2,s2,-2
    80004da0:	4785                	li	a5,1
    80004da2:	0327e663          	bltu	a5,s2,80004dce <fileclose+0x8c>
    begin_op();
    80004da6:	b8fff0ef          	jal	ra,80004934 <begin_op>
    iput(ff.ip);
    80004daa:	854e                	mv	a0,s3
    80004dac:	b28ff0ef          	jal	ra,800040d4 <iput>
    end_op();
    80004db0:	bf5ff0ef          	jal	ra,800049a4 <end_op>
    80004db4:	a829                	j	80004dce <fileclose+0x8c>
    panic("fileclose");
    80004db6:	00004517          	auipc	a0,0x4
    80004dba:	cda50513          	addi	a0,a0,-806 # 80008a90 <syscalls+0x290>
    80004dbe:	9cdfb0ef          	jal	ra,8000078a <panic>
    release(&ftable.lock);
    80004dc2:	00086517          	auipc	a0,0x86
    80004dc6:	36e50513          	addi	a0,a0,878 # 8008b130 <ftable>
    80004dca:	e3bfb0ef          	jal	ra,80000c04 <release>
  }
}
    80004dce:	70e2                	ld	ra,56(sp)
    80004dd0:	7442                	ld	s0,48(sp)
    80004dd2:	74a2                	ld	s1,40(sp)
    80004dd4:	7902                	ld	s2,32(sp)
    80004dd6:	69e2                	ld	s3,24(sp)
    80004dd8:	6a42                	ld	s4,16(sp)
    80004dda:	6aa2                	ld	s5,8(sp)
    80004ddc:	6121                	addi	sp,sp,64
    80004dde:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004de0:	85d6                	mv	a1,s5
    80004de2:	8552                	mv	a0,s4
    80004de4:	2ec000ef          	jal	ra,800050d0 <pipeclose>
    80004de8:	b7dd                	j	80004dce <fileclose+0x8c>

0000000080004dea <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004dea:	715d                	addi	sp,sp,-80
    80004dec:	e486                	sd	ra,72(sp)
    80004dee:	e0a2                	sd	s0,64(sp)
    80004df0:	fc26                	sd	s1,56(sp)
    80004df2:	f84a                	sd	s2,48(sp)
    80004df4:	f44e                	sd	s3,40(sp)
    80004df6:	0880                	addi	s0,sp,80
    80004df8:	84aa                	mv	s1,a0
    80004dfa:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004dfc:	dccfd0ef          	jal	ra,800023c8 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004e00:	409c                	lw	a5,0(s1)
    80004e02:	37f9                	addiw	a5,a5,-2
    80004e04:	4705                	li	a4,1
    80004e06:	02f76f63          	bltu	a4,a5,80004e44 <filestat+0x5a>
    80004e0a:	892a                	mv	s2,a0
    ilock(f->ip);
    80004e0c:	6c88                	ld	a0,24(s1)
    80004e0e:	948ff0ef          	jal	ra,80003f56 <ilock>
    stati(f->ip, &st);
    80004e12:	fb840593          	addi	a1,s0,-72
    80004e16:	6c88                	ld	a0,24(s1)
    80004e18:	ca0ff0ef          	jal	ra,800042b8 <stati>
    iunlock(f->ip);
    80004e1c:	6c88                	ld	a0,24(s1)
    80004e1e:	9e2ff0ef          	jal	ra,80004000 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004e22:	46e1                	li	a3,24
    80004e24:	fb840613          	addi	a2,s0,-72
    80004e28:	85ce                	mv	a1,s3
    80004e2a:	05093503          	ld	a0,80(s2)
    80004e2e:	ab8fd0ef          	jal	ra,800020e6 <copyout>
    80004e32:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004e36:	60a6                	ld	ra,72(sp)
    80004e38:	6406                	ld	s0,64(sp)
    80004e3a:	74e2                	ld	s1,56(sp)
    80004e3c:	7942                	ld	s2,48(sp)
    80004e3e:	79a2                	ld	s3,40(sp)
    80004e40:	6161                	addi	sp,sp,80
    80004e42:	8082                	ret
  return -1;
    80004e44:	557d                	li	a0,-1
    80004e46:	bfc5                	j	80004e36 <filestat+0x4c>

0000000080004e48 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004e48:	7179                	addi	sp,sp,-48
    80004e4a:	f406                	sd	ra,40(sp)
    80004e4c:	f022                	sd	s0,32(sp)
    80004e4e:	ec26                	sd	s1,24(sp)
    80004e50:	e84a                	sd	s2,16(sp)
    80004e52:	e44e                	sd	s3,8(sp)
    80004e54:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004e56:	00854783          	lbu	a5,8(a0)
    80004e5a:	cbc1                	beqz	a5,80004eea <fileread+0xa2>
    80004e5c:	84aa                	mv	s1,a0
    80004e5e:	89ae                	mv	s3,a1
    80004e60:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004e62:	411c                	lw	a5,0(a0)
    80004e64:	4705                	li	a4,1
    80004e66:	04e78363          	beq	a5,a4,80004eac <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004e6a:	470d                	li	a4,3
    80004e6c:	04e78563          	beq	a5,a4,80004eb6 <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004e70:	4709                	li	a4,2
    80004e72:	06e79663          	bne	a5,a4,80004ede <fileread+0x96>
    ilock(f->ip);
    80004e76:	6d08                	ld	a0,24(a0)
    80004e78:	8deff0ef          	jal	ra,80003f56 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004e7c:	874a                	mv	a4,s2
    80004e7e:	5094                	lw	a3,32(s1)
    80004e80:	864e                	mv	a2,s3
    80004e82:	4585                	li	a1,1
    80004e84:	6c88                	ld	a0,24(s1)
    80004e86:	c5cff0ef          	jal	ra,800042e2 <readi>
    80004e8a:	892a                	mv	s2,a0
    80004e8c:	00a05563          	blez	a0,80004e96 <fileread+0x4e>
      f->off += r;
    80004e90:	509c                	lw	a5,32(s1)
    80004e92:	9fa9                	addw	a5,a5,a0
    80004e94:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004e96:	6c88                	ld	a0,24(s1)
    80004e98:	968ff0ef          	jal	ra,80004000 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004e9c:	854a                	mv	a0,s2
    80004e9e:	70a2                	ld	ra,40(sp)
    80004ea0:	7402                	ld	s0,32(sp)
    80004ea2:	64e2                	ld	s1,24(sp)
    80004ea4:	6942                	ld	s2,16(sp)
    80004ea6:	69a2                	ld	s3,8(sp)
    80004ea8:	6145                	addi	sp,sp,48
    80004eaa:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004eac:	6908                	ld	a0,16(a0)
    80004eae:	34e000ef          	jal	ra,800051fc <piperead>
    80004eb2:	892a                	mv	s2,a0
    80004eb4:	b7e5                	j	80004e9c <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004eb6:	02451783          	lh	a5,36(a0)
    80004eba:	03079693          	slli	a3,a5,0x30
    80004ebe:	92c1                	srli	a3,a3,0x30
    80004ec0:	4725                	li	a4,9
    80004ec2:	02d76663          	bltu	a4,a3,80004eee <fileread+0xa6>
    80004ec6:	0792                	slli	a5,a5,0x4
    80004ec8:	00086717          	auipc	a4,0x86
    80004ecc:	1c870713          	addi	a4,a4,456 # 8008b090 <devsw>
    80004ed0:	97ba                	add	a5,a5,a4
    80004ed2:	639c                	ld	a5,0(a5)
    80004ed4:	cf99                	beqz	a5,80004ef2 <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    80004ed6:	4505                	li	a0,1
    80004ed8:	9782                	jalr	a5
    80004eda:	892a                	mv	s2,a0
    80004edc:	b7c1                	j	80004e9c <fileread+0x54>
    panic("fileread");
    80004ede:	00004517          	auipc	a0,0x4
    80004ee2:	bc250513          	addi	a0,a0,-1086 # 80008aa0 <syscalls+0x2a0>
    80004ee6:	8a5fb0ef          	jal	ra,8000078a <panic>
    return -1;
    80004eea:	597d                	li	s2,-1
    80004eec:	bf45                	j	80004e9c <fileread+0x54>
      return -1;
    80004eee:	597d                	li	s2,-1
    80004ef0:	b775                	j	80004e9c <fileread+0x54>
    80004ef2:	597d                	li	s2,-1
    80004ef4:	b765                	j	80004e9c <fileread+0x54>

0000000080004ef6 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004ef6:	715d                	addi	sp,sp,-80
    80004ef8:	e486                	sd	ra,72(sp)
    80004efa:	e0a2                	sd	s0,64(sp)
    80004efc:	fc26                	sd	s1,56(sp)
    80004efe:	f84a                	sd	s2,48(sp)
    80004f00:	f44e                	sd	s3,40(sp)
    80004f02:	f052                	sd	s4,32(sp)
    80004f04:	ec56                	sd	s5,24(sp)
    80004f06:	e85a                	sd	s6,16(sp)
    80004f08:	e45e                	sd	s7,8(sp)
    80004f0a:	e062                	sd	s8,0(sp)
    80004f0c:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004f0e:	00954783          	lbu	a5,9(a0)
    80004f12:	0e078863          	beqz	a5,80005002 <filewrite+0x10c>
    80004f16:	892a                	mv	s2,a0
    80004f18:	8aae                	mv	s5,a1
    80004f1a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004f1c:	411c                	lw	a5,0(a0)
    80004f1e:	4705                	li	a4,1
    80004f20:	02e78263          	beq	a5,a4,80004f44 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004f24:	470d                	li	a4,3
    80004f26:	02e78463          	beq	a5,a4,80004f4e <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004f2a:	4709                	li	a4,2
    80004f2c:	0ce79563          	bne	a5,a4,80004ff6 <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004f30:	0ac05163          	blez	a2,80004fd2 <filewrite+0xdc>
    int i = 0;
    80004f34:	4981                	li	s3,0
    80004f36:	6b05                	lui	s6,0x1
    80004f38:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004f3c:	6b85                	lui	s7,0x1
    80004f3e:	c00b8b9b          	addiw	s7,s7,-1024
    80004f42:	a041                	j	80004fc2 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004f44:	6908                	ld	a0,16(a0)
    80004f46:	1e2000ef          	jal	ra,80005128 <pipewrite>
    80004f4a:	8a2a                	mv	s4,a0
    80004f4c:	a071                	j	80004fd8 <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004f4e:	02451783          	lh	a5,36(a0)
    80004f52:	03079693          	slli	a3,a5,0x30
    80004f56:	92c1                	srli	a3,a3,0x30
    80004f58:	4725                	li	a4,9
    80004f5a:	0ad76663          	bltu	a4,a3,80005006 <filewrite+0x110>
    80004f5e:	0792                	slli	a5,a5,0x4
    80004f60:	00086717          	auipc	a4,0x86
    80004f64:	13070713          	addi	a4,a4,304 # 8008b090 <devsw>
    80004f68:	97ba                	add	a5,a5,a4
    80004f6a:	679c                	ld	a5,8(a5)
    80004f6c:	cfd9                	beqz	a5,8000500a <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    80004f6e:	4505                	li	a0,1
    80004f70:	9782                	jalr	a5
    80004f72:	8a2a                	mv	s4,a0
    80004f74:	a095                	j	80004fd8 <filewrite+0xe2>
    80004f76:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004f7a:	9bbff0ef          	jal	ra,80004934 <begin_op>
      ilock(f->ip);
    80004f7e:	01893503          	ld	a0,24(s2)
    80004f82:	fd5fe0ef          	jal	ra,80003f56 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004f86:	8762                	mv	a4,s8
    80004f88:	02092683          	lw	a3,32(s2)
    80004f8c:	01598633          	add	a2,s3,s5
    80004f90:	4585                	li	a1,1
    80004f92:	01893503          	ld	a0,24(s2)
    80004f96:	c30ff0ef          	jal	ra,800043c6 <writei>
    80004f9a:	84aa                	mv	s1,a0
    80004f9c:	00a05763          	blez	a0,80004faa <filewrite+0xb4>
        f->off += r;
    80004fa0:	02092783          	lw	a5,32(s2)
    80004fa4:	9fa9                	addw	a5,a5,a0
    80004fa6:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004faa:	01893503          	ld	a0,24(s2)
    80004fae:	852ff0ef          	jal	ra,80004000 <iunlock>
      end_op();
    80004fb2:	9f3ff0ef          	jal	ra,800049a4 <end_op>

      if(r != n1){
    80004fb6:	009c1f63          	bne	s8,s1,80004fd4 <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    80004fba:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004fbe:	0149db63          	bge	s3,s4,80004fd4 <filewrite+0xde>
      int n1 = n - i;
    80004fc2:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004fc6:	84be                	mv	s1,a5
    80004fc8:	2781                	sext.w	a5,a5
    80004fca:	fafb56e3          	bge	s6,a5,80004f76 <filewrite+0x80>
    80004fce:	84de                	mv	s1,s7
    80004fd0:	b75d                	j	80004f76 <filewrite+0x80>
    int i = 0;
    80004fd2:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004fd4:	013a1f63          	bne	s4,s3,80004ff2 <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004fd8:	8552                	mv	a0,s4
    80004fda:	60a6                	ld	ra,72(sp)
    80004fdc:	6406                	ld	s0,64(sp)
    80004fde:	74e2                	ld	s1,56(sp)
    80004fe0:	7942                	ld	s2,48(sp)
    80004fe2:	79a2                	ld	s3,40(sp)
    80004fe4:	7a02                	ld	s4,32(sp)
    80004fe6:	6ae2                	ld	s5,24(sp)
    80004fe8:	6b42                	ld	s6,16(sp)
    80004fea:	6ba2                	ld	s7,8(sp)
    80004fec:	6c02                	ld	s8,0(sp)
    80004fee:	6161                	addi	sp,sp,80
    80004ff0:	8082                	ret
    ret = (i == n ? n : -1);
    80004ff2:	5a7d                	li	s4,-1
    80004ff4:	b7d5                	j	80004fd8 <filewrite+0xe2>
    panic("filewrite");
    80004ff6:	00004517          	auipc	a0,0x4
    80004ffa:	aba50513          	addi	a0,a0,-1350 # 80008ab0 <syscalls+0x2b0>
    80004ffe:	f8cfb0ef          	jal	ra,8000078a <panic>
    return -1;
    80005002:	5a7d                	li	s4,-1
    80005004:	bfd1                	j	80004fd8 <filewrite+0xe2>
      return -1;
    80005006:	5a7d                	li	s4,-1
    80005008:	bfc1                	j	80004fd8 <filewrite+0xe2>
    8000500a:	5a7d                	li	s4,-1
    8000500c:	b7f1                	j	80004fd8 <filewrite+0xe2>

000000008000500e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000500e:	7179                	addi	sp,sp,-48
    80005010:	f406                	sd	ra,40(sp)
    80005012:	f022                	sd	s0,32(sp)
    80005014:	ec26                	sd	s1,24(sp)
    80005016:	e84a                	sd	s2,16(sp)
    80005018:	e44e                	sd	s3,8(sp)
    8000501a:	e052                	sd	s4,0(sp)
    8000501c:	1800                	addi	s0,sp,48
    8000501e:	84aa                	mv	s1,a0
    80005020:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005022:	0005b023          	sd	zero,0(a1)
    80005026:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000502a:	c75ff0ef          	jal	ra,80004c9e <filealloc>
    8000502e:	e088                	sd	a0,0(s1)
    80005030:	cd35                	beqz	a0,800050ac <pipealloc+0x9e>
    80005032:	c6dff0ef          	jal	ra,80004c9e <filealloc>
    80005036:	00aa3023          	sd	a0,0(s4)
    8000503a:	c52d                	beqz	a0,800050a4 <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000503c:	a61fb0ef          	jal	ra,80000a9c <kalloc>
    80005040:	892a                	mv	s2,a0
    80005042:	cd31                	beqz	a0,8000509e <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    80005044:	4985                	li	s3,1
    80005046:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000504a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000504e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005052:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005056:	00004597          	auipc	a1,0x4
    8000505a:	a6a58593          	addi	a1,a1,-1430 # 80008ac0 <syscalls+0x2c0>
    8000505e:	a8ffb0ef          	jal	ra,80000aec <initlock>
  (*f0)->type = FD_PIPE;
    80005062:	609c                	ld	a5,0(s1)
    80005064:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005068:	609c                	ld	a5,0(s1)
    8000506a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000506e:	609c                	ld	a5,0(s1)
    80005070:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005074:	609c                	ld	a5,0(s1)
    80005076:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000507a:	000a3783          	ld	a5,0(s4)
    8000507e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005082:	000a3783          	ld	a5,0(s4)
    80005086:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000508a:	000a3783          	ld	a5,0(s4)
    8000508e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005092:	000a3783          	ld	a5,0(s4)
    80005096:	0127b823          	sd	s2,16(a5)
  return 0;
    8000509a:	4501                	li	a0,0
    8000509c:	a005                	j	800050bc <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000509e:	6088                	ld	a0,0(s1)
    800050a0:	e501                	bnez	a0,800050a8 <pipealloc+0x9a>
    800050a2:	a029                	j	800050ac <pipealloc+0x9e>
    800050a4:	6088                	ld	a0,0(s1)
    800050a6:	c11d                	beqz	a0,800050cc <pipealloc+0xbe>
    fileclose(*f0);
    800050a8:	c9bff0ef          	jal	ra,80004d42 <fileclose>
  if(*f1)
    800050ac:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800050b0:	557d                	li	a0,-1
  if(*f1)
    800050b2:	c789                	beqz	a5,800050bc <pipealloc+0xae>
    fileclose(*f1);
    800050b4:	853e                	mv	a0,a5
    800050b6:	c8dff0ef          	jal	ra,80004d42 <fileclose>
  return -1;
    800050ba:	557d                	li	a0,-1
}
    800050bc:	70a2                	ld	ra,40(sp)
    800050be:	7402                	ld	s0,32(sp)
    800050c0:	64e2                	ld	s1,24(sp)
    800050c2:	6942                	ld	s2,16(sp)
    800050c4:	69a2                	ld	s3,8(sp)
    800050c6:	6a02                	ld	s4,0(sp)
    800050c8:	6145                	addi	sp,sp,48
    800050ca:	8082                	ret
  return -1;
    800050cc:	557d                	li	a0,-1
    800050ce:	b7fd                	j	800050bc <pipealloc+0xae>

00000000800050d0 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800050d0:	1101                	addi	sp,sp,-32
    800050d2:	ec06                	sd	ra,24(sp)
    800050d4:	e822                	sd	s0,16(sp)
    800050d6:	e426                	sd	s1,8(sp)
    800050d8:	e04a                	sd	s2,0(sp)
    800050da:	1000                	addi	s0,sp,32
    800050dc:	84aa                	mv	s1,a0
    800050de:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800050e0:	a8dfb0ef          	jal	ra,80000b6c <acquire>
  if(writable){
    800050e4:	02090763          	beqz	s2,80005112 <pipeclose+0x42>
    pi->writeopen = 0;
    800050e8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800050ec:	21848513          	addi	a0,s1,536
    800050f0:	9c7fd0ef          	jal	ra,80002ab6 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800050f4:	2204b783          	ld	a5,544(s1)
    800050f8:	e785                	bnez	a5,80005120 <pipeclose+0x50>
    release(&pi->lock);
    800050fa:	8526                	mv	a0,s1
    800050fc:	b09fb0ef          	jal	ra,80000c04 <release>
    kfree((char*)pi);
    80005100:	8526                	mv	a0,s1
    80005102:	8bbfb0ef          	jal	ra,800009bc <kfree>
  } else
    release(&pi->lock);
}
    80005106:	60e2                	ld	ra,24(sp)
    80005108:	6442                	ld	s0,16(sp)
    8000510a:	64a2                	ld	s1,8(sp)
    8000510c:	6902                	ld	s2,0(sp)
    8000510e:	6105                	addi	sp,sp,32
    80005110:	8082                	ret
    pi->readopen = 0;
    80005112:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005116:	21c48513          	addi	a0,s1,540
    8000511a:	99dfd0ef          	jal	ra,80002ab6 <wakeup>
    8000511e:	bfd9                	j	800050f4 <pipeclose+0x24>
    release(&pi->lock);
    80005120:	8526                	mv	a0,s1
    80005122:	ae3fb0ef          	jal	ra,80000c04 <release>
}
    80005126:	b7c5                	j	80005106 <pipeclose+0x36>

0000000080005128 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005128:	711d                	addi	sp,sp,-96
    8000512a:	ec86                	sd	ra,88(sp)
    8000512c:	e8a2                	sd	s0,80(sp)
    8000512e:	e4a6                	sd	s1,72(sp)
    80005130:	e0ca                	sd	s2,64(sp)
    80005132:	fc4e                	sd	s3,56(sp)
    80005134:	f852                	sd	s4,48(sp)
    80005136:	f456                	sd	s5,40(sp)
    80005138:	f05a                	sd	s6,32(sp)
    8000513a:	ec5e                	sd	s7,24(sp)
    8000513c:	e862                	sd	s8,16(sp)
    8000513e:	1080                	addi	s0,sp,96
    80005140:	84aa                	mv	s1,a0
    80005142:	8aae                	mv	s5,a1
    80005144:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005146:	a82fd0ef          	jal	ra,800023c8 <myproc>
    8000514a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000514c:	8526                	mv	a0,s1
    8000514e:	a1ffb0ef          	jal	ra,80000b6c <acquire>
  while(i < n){
    80005152:	09405c63          	blez	s4,800051ea <pipewrite+0xc2>
  int i = 0;
    80005156:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005158:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000515a:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000515e:	21c48b93          	addi	s7,s1,540
    80005162:	a81d                	j	80005198 <pipewrite+0x70>
      release(&pi->lock);
    80005164:	8526                	mv	a0,s1
    80005166:	a9ffb0ef          	jal	ra,80000c04 <release>
      return -1;
    8000516a:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000516c:	854a                	mv	a0,s2
    8000516e:	60e6                	ld	ra,88(sp)
    80005170:	6446                	ld	s0,80(sp)
    80005172:	64a6                	ld	s1,72(sp)
    80005174:	6906                	ld	s2,64(sp)
    80005176:	79e2                	ld	s3,56(sp)
    80005178:	7a42                	ld	s4,48(sp)
    8000517a:	7aa2                	ld	s5,40(sp)
    8000517c:	7b02                	ld	s6,32(sp)
    8000517e:	6be2                	ld	s7,24(sp)
    80005180:	6c42                	ld	s8,16(sp)
    80005182:	6125                	addi	sp,sp,96
    80005184:	8082                	ret
      wakeup(&pi->nread);
    80005186:	8562                	mv	a0,s8
    80005188:	92ffd0ef          	jal	ra,80002ab6 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000518c:	85a6                	mv	a1,s1
    8000518e:	855e                	mv	a0,s7
    80005190:	8dbfd0ef          	jal	ra,80002a6a <sleep>
  while(i < n){
    80005194:	05495c63          	bge	s2,s4,800051ec <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    80005198:	2204a783          	lw	a5,544(s1)
    8000519c:	d7e1                	beqz	a5,80005164 <pipewrite+0x3c>
    8000519e:	854e                	mv	a0,s3
    800051a0:	b57fd0ef          	jal	ra,80002cf6 <killed>
    800051a4:	f161                	bnez	a0,80005164 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800051a6:	2184a783          	lw	a5,536(s1)
    800051aa:	21c4a703          	lw	a4,540(s1)
    800051ae:	2007879b          	addiw	a5,a5,512
    800051b2:	fcf70ae3          	beq	a4,a5,80005186 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800051b6:	4685                	li	a3,1
    800051b8:	01590633          	add	a2,s2,s5
    800051bc:	faf40593          	addi	a1,s0,-81
    800051c0:	0509b503          	ld	a0,80(s3)
    800051c4:	808fd0ef          	jal	ra,800021cc <copyin>
    800051c8:	03650263          	beq	a0,s6,800051ec <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800051cc:	21c4a783          	lw	a5,540(s1)
    800051d0:	0017871b          	addiw	a4,a5,1
    800051d4:	20e4ae23          	sw	a4,540(s1)
    800051d8:	1ff7f793          	andi	a5,a5,511
    800051dc:	97a6                	add	a5,a5,s1
    800051de:	faf44703          	lbu	a4,-81(s0)
    800051e2:	00e78c23          	sb	a4,24(a5)
      i++;
    800051e6:	2905                	addiw	s2,s2,1
    800051e8:	b775                	j	80005194 <pipewrite+0x6c>
  int i = 0;
    800051ea:	4901                	li	s2,0
  wakeup(&pi->nread);
    800051ec:	21848513          	addi	a0,s1,536
    800051f0:	8c7fd0ef          	jal	ra,80002ab6 <wakeup>
  release(&pi->lock);
    800051f4:	8526                	mv	a0,s1
    800051f6:	a0ffb0ef          	jal	ra,80000c04 <release>
  return i;
    800051fa:	bf8d                	j	8000516c <pipewrite+0x44>

00000000800051fc <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800051fc:	715d                	addi	sp,sp,-80
    800051fe:	e486                	sd	ra,72(sp)
    80005200:	e0a2                	sd	s0,64(sp)
    80005202:	fc26                	sd	s1,56(sp)
    80005204:	f84a                	sd	s2,48(sp)
    80005206:	f44e                	sd	s3,40(sp)
    80005208:	f052                	sd	s4,32(sp)
    8000520a:	ec56                	sd	s5,24(sp)
    8000520c:	e85a                	sd	s6,16(sp)
    8000520e:	0880                	addi	s0,sp,80
    80005210:	84aa                	mv	s1,a0
    80005212:	892e                	mv	s2,a1
    80005214:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005216:	9b2fd0ef          	jal	ra,800023c8 <myproc>
    8000521a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000521c:	8526                	mv	a0,s1
    8000521e:	94ffb0ef          	jal	ra,80000b6c <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005222:	2184a703          	lw	a4,536(s1)
    80005226:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000522a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000522e:	02f71363          	bne	a4,a5,80005254 <piperead+0x58>
    80005232:	2244a783          	lw	a5,548(s1)
    80005236:	cf99                	beqz	a5,80005254 <piperead+0x58>
    if(killed(pr)){
    80005238:	8552                	mv	a0,s4
    8000523a:	abdfd0ef          	jal	ra,80002cf6 <killed>
    8000523e:	e141                	bnez	a0,800052be <piperead+0xc2>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005240:	85a6                	mv	a1,s1
    80005242:	854e                	mv	a0,s3
    80005244:	827fd0ef          	jal	ra,80002a6a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005248:	2184a703          	lw	a4,536(s1)
    8000524c:	21c4a783          	lw	a5,540(s1)
    80005250:	fef701e3          	beq	a4,a5,80005232 <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005254:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005256:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005258:	05505163          	blez	s5,8000529a <piperead+0x9e>
    if(pi->nread == pi->nwrite)
    8000525c:	2184a783          	lw	a5,536(s1)
    80005260:	21c4a703          	lw	a4,540(s1)
    80005264:	02f70b63          	beq	a4,a5,8000529a <piperead+0x9e>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005268:	0017871b          	addiw	a4,a5,1
    8000526c:	20e4ac23          	sw	a4,536(s1)
    80005270:	1ff7f793          	andi	a5,a5,511
    80005274:	97a6                	add	a5,a5,s1
    80005276:	0187c783          	lbu	a5,24(a5)
    8000527a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000527e:	4685                	li	a3,1
    80005280:	fbf40613          	addi	a2,s0,-65
    80005284:	85ca                	mv	a1,s2
    80005286:	050a3503          	ld	a0,80(s4)
    8000528a:	e5dfc0ef          	jal	ra,800020e6 <copyout>
    8000528e:	01650663          	beq	a0,s6,8000529a <piperead+0x9e>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005292:	2985                	addiw	s3,s3,1
    80005294:	0905                	addi	s2,s2,1
    80005296:	fd3a93e3          	bne	s5,s3,8000525c <piperead+0x60>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000529a:	21c48513          	addi	a0,s1,540
    8000529e:	819fd0ef          	jal	ra,80002ab6 <wakeup>
  release(&pi->lock);
    800052a2:	8526                	mv	a0,s1
    800052a4:	961fb0ef          	jal	ra,80000c04 <release>
  return i;
}
    800052a8:	854e                	mv	a0,s3
    800052aa:	60a6                	ld	ra,72(sp)
    800052ac:	6406                	ld	s0,64(sp)
    800052ae:	74e2                	ld	s1,56(sp)
    800052b0:	7942                	ld	s2,48(sp)
    800052b2:	79a2                	ld	s3,40(sp)
    800052b4:	7a02                	ld	s4,32(sp)
    800052b6:	6ae2                	ld	s5,24(sp)
    800052b8:	6b42                	ld	s6,16(sp)
    800052ba:	6161                	addi	sp,sp,80
    800052bc:	8082                	ret
      release(&pi->lock);
    800052be:	8526                	mv	a0,s1
    800052c0:	945fb0ef          	jal	ra,80000c04 <release>
      return -1;
    800052c4:	59fd                	li	s3,-1
    800052c6:	b7cd                	j	800052a8 <piperead+0xac>

00000000800052c8 <flags2perm>:

// static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800052c8:	1141                	addi	sp,sp,-16
    800052ca:	e422                	sd	s0,8(sp)
    800052cc:	0800                	addi	s0,sp,16
    800052ce:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800052d0:	8905                	andi	a0,a0,1
    800052d2:	c111                	beqz	a0,800052d6 <flags2perm+0xe>
      perm = PTE_X;
    800052d4:	4521                	li	a0,8
    if(flags & 0x2)
    800052d6:	8b89                	andi	a5,a5,2
    800052d8:	c399                	beqz	a5,800052de <flags2perm+0x16>
      perm |= PTE_W;
    800052da:	00456513          	ori	a0,a0,4
    return perm;
}
    800052de:	6422                	ld	s0,8(sp)
    800052e0:	0141                	addi	sp,sp,16
    800052e2:	8082                	ret

00000000800052e4 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800052e4:	7101                	addi	sp,sp,-512
    800052e6:	ff86                	sd	ra,504(sp)
    800052e8:	fba2                	sd	s0,496(sp)
    800052ea:	f7a6                	sd	s1,488(sp)
    800052ec:	f3ca                	sd	s2,480(sp)
    800052ee:	efce                	sd	s3,472(sp)
    800052f0:	ebd2                	sd	s4,464(sp)
    800052f2:	e7d6                	sd	s5,456(sp)
    800052f4:	e3da                	sd	s6,448(sp)
    800052f6:	ff5e                	sd	s7,440(sp)
    800052f8:	fb62                	sd	s8,432(sp)
    800052fa:	f766                	sd	s9,424(sp)
    800052fc:	f36a                	sd	s10,416(sp)
    800052fe:	ef6e                	sd	s11,408(sp)
    80005300:	0400                	addi	s0,sp,512
    80005302:	892a                	mv	s2,a0
    80005304:	84ae                	mv	s1,a1
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005306:	8c2fd0ef          	jal	ra,800023c8 <myproc>
    8000530a:	8baa                	mv	s7,a0

  begin_op();
    8000530c:	e28ff0ef          	jal	ra,80004934 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80005310:	854a                	mv	a0,s2
    80005312:	c32ff0ef          	jal	ra,80004744 <namei>
    80005316:	cd39                	beqz	a0,80005374 <kexec+0x90>
    80005318:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000531a:	c3dfe0ef          	jal	ra,80003f56 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000531e:	04000713          	li	a4,64
    80005322:	4681                	li	a3,0
    80005324:	e5040613          	addi	a2,s0,-432
    80005328:	4581                	li	a1,0
    8000532a:	8552                	mv	a0,s4
    8000532c:	fb7fe0ef          	jal	ra,800042e2 <readi>
    80005330:	04000793          	li	a5,64
    80005334:	00f51a63          	bne	a0,a5,80005348 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80005338:	e5042703          	lw	a4,-432(s0)
    8000533c:	464c47b7          	lui	a5,0x464c4
    80005340:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005344:	02f70c63          	beq	a4,a5,8000537c <kexec+0x98>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005348:	8552                	mv	a0,s4
    8000534a:	e13fe0ef          	jal	ra,8000415c <iunlockput>
    end_op();
    8000534e:	e56ff0ef          	jal	ra,800049a4 <end_op>
  }
  return -1;
    80005352:	557d                	li	a0,-1
}
    80005354:	70fe                	ld	ra,504(sp)
    80005356:	745e                	ld	s0,496(sp)
    80005358:	74be                	ld	s1,488(sp)
    8000535a:	791e                	ld	s2,480(sp)
    8000535c:	69fe                	ld	s3,472(sp)
    8000535e:	6a5e                	ld	s4,464(sp)
    80005360:	6abe                	ld	s5,456(sp)
    80005362:	6b1e                	ld	s6,448(sp)
    80005364:	7bfa                	ld	s7,440(sp)
    80005366:	7c5a                	ld	s8,432(sp)
    80005368:	7cba                	ld	s9,424(sp)
    8000536a:	7d1a                	ld	s10,416(sp)
    8000536c:	6dfa                	ld	s11,408(sp)
    8000536e:	20010113          	addi	sp,sp,512
    80005372:	8082                	ret
    end_op();
    80005374:	e30ff0ef          	jal	ra,800049a4 <end_op>
    return -1;
    80005378:	557d                	li	a0,-1
    8000537a:	bfe9                	j	80005354 <kexec+0x70>
  if((pagetable = proc_pagetable(p)) == 0)
    8000537c:	855e                	mv	a0,s7
    8000537e:	950fd0ef          	jal	ra,800024ce <proc_pagetable>
    80005382:	8b2a                	mv	s6,a0
    80005384:	d171                	beqz	a0,80005348 <kexec+0x64>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005386:	e7042983          	lw	s3,-400(s0)
    8000538a:	e8845783          	lhu	a5,-376(s0)
    8000538e:	cbc1                	beqz	a5,8000541e <kexec+0x13a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005390:	4a81                	li	s5,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005392:	4c01                	li	s8,0
    if(ph.type != ELF_PROG_LOAD)
    80005394:	4c85                	li	s9,1
    if(ph.vaddr % PGSIZE != 0)
    80005396:	6d05                	lui	s10,0x1
    80005398:	1d7d                	addi	s10,s10,-1
    8000539a:	a01d                	j	800053c0 <kexec+0xdc>
  p->data_start = ph.vaddr;
    8000539c:	16ebbc23          	sd	a4,376(s7) # 1178 <_entry-0x7fffee88>
  p->data_end = ph.vaddr + ph.memsz;
    800053a0:	18fbb023          	sd	a5,384(s7)
  p->data_file_offset = ph.off;
    800053a4:	e2043703          	ld	a4,-480(s0)
    800053a8:	1aebb823          	sd	a4,432(s7)
  p->data_file_size = ph.filesz;
    800053ac:	1adbbc23          	sd	a3,440(s7)
    sz = ph.vaddr + ph.memsz;  // Update size but don't allocate
    800053b0:	8abe                	mv	s5,a5
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800053b2:	2c05                	addiw	s8,s8,1
    800053b4:	0389899b          	addiw	s3,s3,56
    800053b8:	e8845783          	lhu	a5,-376(s0)
    800053bc:	06fc5263          	bge	s8,a5,80005420 <kexec+0x13c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800053c0:	2981                	sext.w	s3,s3
    800053c2:	03800713          	li	a4,56
    800053c6:	86ce                	mv	a3,s3
    800053c8:	e1840613          	addi	a2,s0,-488
    800053cc:	4581                	li	a1,0
    800053ce:	8552                	mv	a0,s4
    800053d0:	f13fe0ef          	jal	ra,800042e2 <readi>
    800053d4:	03800793          	li	a5,56
    800053d8:	1cf51263          	bne	a0,a5,8000559c <kexec+0x2b8>
    if(ph.type != ELF_PROG_LOAD)
    800053dc:	e1842783          	lw	a5,-488(s0)
    800053e0:	fd9799e3          	bne	a5,s9,800053b2 <kexec+0xce>
    if(ph.memsz < ph.filesz)
    800053e4:	e4043783          	ld	a5,-448(s0)
    800053e8:	e3843683          	ld	a3,-456(s0)
    800053ec:	1ad7e863          	bltu	a5,a3,8000559c <kexec+0x2b8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800053f0:	e2843703          	ld	a4,-472(s0)
    800053f4:	97ba                	add	a5,a5,a4
    800053f6:	1ae7e363          	bltu	a5,a4,8000559c <kexec+0x2b8>
    if(ph.vaddr % PGSIZE != 0)
    800053fa:	01a77633          	and	a2,a4,s10
    800053fe:	18061f63          	bnez	a2,8000559c <kexec+0x2b8>
if(i == 0) {  // First segment (typically text)
    80005402:	f80c1de3          	bnez	s8,8000539c <kexec+0xb8>
  p->text_start = ph.vaddr;
    80005406:	16ebb423          	sd	a4,360(s7)
  p->text_end = ph.vaddr + ph.memsz;
    8000540a:	16fbb823          	sd	a5,368(s7)
  p->text_file_offset = ph.off;
    8000540e:	e2043703          	ld	a4,-480(s0)
    80005412:	1aebb023          	sd	a4,416(s7)
  p->text_file_size = ph.filesz;
    80005416:	1adbb423          	sd	a3,424(s7)
    sz = ph.vaddr + ph.memsz;  // Update size but don't allocate
    8000541a:	8abe                	mv	s5,a5
    8000541c:	bf59                	j	800053b2 <kexec+0xce>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000541e:	4a81                	li	s5,0
  printf("[pid %d] INIT-LAZYMAP text=[0x%lx,0x%lx) data=[0x%lx,0x%lx) heap_start=0x%lx stack_top=0x%lx\n", 
    80005420:	180bb783          	ld	a5,384(s7)
    80005424:	6889                	lui	a7,0x2
    80005426:	98d6                	add	a7,a7,s5
    80005428:	883e                	mv	a6,a5
    8000542a:	178bb703          	ld	a4,376(s7)
    8000542e:	170bb683          	ld	a3,368(s7)
    80005432:	168bb603          	ld	a2,360(s7)
    80005436:	030ba583          	lw	a1,48(s7)
    8000543a:	00003517          	auipc	a0,0x3
    8000543e:	68e50513          	addi	a0,a0,1678 # 80008ac8 <syscalls+0x2c8>
    80005442:	882fb0ef          	jal	ra,800004c4 <printf>
  p->heap_start = p->data_end;
    80005446:	180bb783          	ld	a5,384(s7)
    8000544a:	18fbb423          	sd	a5,392(s7)
  p->swap_filename[0] = '/';
    8000544e:	6605                	lui	a2,0x1
    80005450:	00cb87b3          	add	a5,s7,a2
    80005454:	02f00713          	li	a4,47
    80005458:	bce78c23          	sb	a4,-1064(a5)
  p->swap_filename[1] = 'p';
    8000545c:	07000713          	li	a4,112
    80005460:	bce78ca3          	sb	a4,-1063(a5)
  p->swap_filename[2] = 'g';
    80005464:	06700693          	li	a3,103
    80005468:	bcd78d23          	sb	a3,-1062(a5)
  p->swap_filename[3] = 's';
    8000546c:	07300693          	li	a3,115
    80005470:	bcd78da3          	sb	a3,-1061(a5)
  p->swap_filename[4] = 'w';
    80005474:	07700693          	li	a3,119
    80005478:	bcd78e23          	sb	a3,-1060(a5)
  p->swap_filename[5] = 'p';
    8000547c:	bce78ea3          	sb	a4,-1059(a5)
  int pid_copy = p->pid;
    80005480:	030ba683          	lw	a3,48(s7)
  for(int i = 10; i >= 6; i--) {
    80005484:	be260793          	addi	a5,a2,-1054 # be2 <_entry-0x7ffff41e>
    80005488:	97de                	add	a5,a5,s7
    8000548a:	bdd60613          	addi	a2,a2,-1059
    8000548e:	965e                	add	a2,a2,s7
    p->swap_filename[i] = '0' + (pid_copy % 10);
    80005490:	45a9                	li	a1,10
    80005492:	02b6e73b          	remw	a4,a3,a1
    80005496:	0307071b          	addiw	a4,a4,48
    8000549a:	00e78023          	sb	a4,0(a5)
    pid_copy = pid_copy / 10;
    8000549e:	02b6c6bb          	divw	a3,a3,a1
  for(int i = 10; i >= 6; i--) {
    800054a2:	17fd                	addi	a5,a5,-1
    800054a4:	fec797e3          	bne	a5,a2,80005492 <kexec+0x1ae>
  p->swap_filename[11] = '\0';  // Null terminator
    800054a8:	6985                	lui	s3,0x1
    800054aa:	013b87b3          	add	a5,s7,s3
    800054ae:	be0781a3          	sb	zero,-1053(a5)
  begin_op();
    800054b2:	c82ff0ef          	jal	ra,80004934 <begin_op>
  struct inode *swap_ip = create(p->swap_filename, T_FILE, 0, 0);
    800054b6:	bd898993          	addi	s3,s3,-1064 # bd8 <_entry-0x7ffff428>
    800054ba:	99de                	add	s3,s3,s7
    800054bc:	4681                	li	a3,0
    800054be:	4601                	li	a2,0
    800054c0:	4589                	li	a1,2
    800054c2:	854e                	mv	a0,s3
    800054c4:	608000ef          	jal	ra,80005acc <create>
    800054c8:	8c2a                	mv	s8,a0
  if(swap_ip == 0) {
    800054ca:	0e050163          	beqz	a0,800055ac <kexec+0x2c8>
    p->swapfile = filealloc();
    800054ce:	fd0ff0ef          	jal	ra,80004c9e <filealloc>
    800054d2:	6785                	lui	a5,0x1
    800054d4:	97de                	add	a5,a5,s7
    800054d6:	bca7b823          	sd	a0,-1072(a5) # bd0 <_entry-0x7ffff430>
    if(p->swapfile == 0) {
    800054da:	0e050563          	beqz	a0,800055c4 <kexec+0x2e0>
      p->swapfile->type = FD_INODE;
    800054de:	4789                	li	a5,2
    800054e0:	c11c                	sw	a5,0(a0)
      p->swapfile->ip = swap_ip;
    800054e2:	6785                	lui	a5,0x1
    800054e4:	97de                	add	a5,a5,s7
    800054e6:	bd07b703          	ld	a4,-1072(a5) # bd0 <_entry-0x7ffff430>
    800054ea:	01873c23          	sd	s8,24(a4)
      p->swapfile->off = 0;
    800054ee:	bd07b703          	ld	a4,-1072(a5)
    800054f2:	02072023          	sw	zero,32(a4)
      p->swapfile->readable = 1;
    800054f6:	bd07b683          	ld	a3,-1072(a5)
    800054fa:	4705                	li	a4,1
    800054fc:	00e68423          	sb	a4,8(a3)
      p->swapfile->writable = 1;
    80005500:	bd07b783          	ld	a5,-1072(a5)
    80005504:	00e784a3          	sb	a4,9(a5)
      iunlock(swap_ip);
    80005508:	8562                	mv	a0,s8
    8000550a:	af7fe0ef          	jal	ra,80004000 <iunlock>
      end_op();
    8000550e:	c96ff0ef          	jal	ra,800049a4 <end_op>
  p->exec_inode = ip;
    80005512:	194bbc23          	sd	s4,408(s7)
  idup(ip);  // Increment reference count
    80005516:	8552                	mv	a0,s4
    80005518:	a09fe0ef          	jal	ra,80003f20 <idup>
  iunlockput(ip);
    8000551c:	8552                	mv	a0,s4
    8000551e:	c3ffe0ef          	jal	ra,8000415c <iunlockput>
  end_op();
    80005522:	c82ff0ef          	jal	ra,800049a4 <end_op>
  p = myproc();
    80005526:	ea3fc0ef          	jal	ra,800023c8 <myproc>
    8000552a:	8daa                	mv	s11,a0
  uint64 oldsz = p->sz;
    8000552c:	653c                	ld	a5,72(a0)
    8000552e:	e0f43423          	sd	a5,-504(s0)
  sz = PGROUNDUP(sz);
    80005532:	6785                	lui	a5,0x1
    80005534:	fff78c93          	addi	s9,a5,-1 # fff <_entry-0x7ffff001>
    80005538:	9cd6                	add	s9,s9,s5
    8000553a:	777d                	lui	a4,0xfffff
    8000553c:	00ecfcb3          	and	s9,s9,a4
  sz1 = sz + (USERSTACK+1)*PGSIZE;
    80005540:	6a89                	lui	s5,0x2
    80005542:	9ae6                	add	s5,s5,s9
  stackbase = sp - USERSTACK*PGSIZE;
    80005544:	9cbe                	add	s9,s9,a5
   p->sz = sz;
    80005546:	05553423          	sd	s5,72(a0)
  for(argc = 0; argv[argc]; argc++) {
    8000554a:	6088                	ld	a0,0(s1)
    8000554c:	c951                	beqz	a0,800055e0 <kexec+0x2fc>
    8000554e:	e9040b93          	addi	s7,s0,-368
    80005552:	f9040d13          	addi	s10,s0,-112
  sp = sz;
    80005556:	8a56                	mv	s4,s5
  for(argc = 0; argv[argc]; argc++) {
    80005558:	4981                	li	s3,0
    sp -= strlen(argv[argc]) + 1;
    8000555a:	85ffb0ef          	jal	ra,80000db8 <strlen>
    8000555e:	2505                	addiw	a0,a0,1
    80005560:	40aa0a33          	sub	s4,s4,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005564:	ff0a7a13          	andi	s4,s4,-16
    if(sp < stackbase)
    80005568:	119a6463          	bltu	s4,s9,80005670 <kexec+0x38c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0) {
    8000556c:	0004bc03          	ld	s8,0(s1)
    80005570:	8562                	mv	a0,s8
    80005572:	847fb0ef          	jal	ra,80000db8 <strlen>
    80005576:	0015069b          	addiw	a3,a0,1
    8000557a:	8662                	mv	a2,s8
    8000557c:	85d2                	mv	a1,s4
    8000557e:	855a                	mv	a0,s6
    80005580:	b67fc0ef          	jal	ra,800020e6 <copyout>
    80005584:	0e054863          	bltz	a0,80005674 <kexec+0x390>
    ustack[argc] = sp;
    80005588:	014bb023          	sd	s4,0(s7)
  for(argc = 0; argv[argc]; argc++) {
    8000558c:	0985                	addi	s3,s3,1
    8000558e:	04a1                	addi	s1,s1,8
    80005590:	6088                	ld	a0,0(s1)
    80005592:	c929                	beqz	a0,800055e4 <kexec+0x300>
    if(argc >= MAXARG)
    80005594:	0ba1                	addi	s7,s7,8
    80005596:	fd7d12e3          	bne	s10,s7,8000555a <kexec+0x276>
  ip = 0;
    8000559a:	4a01                	li	s4,0
    proc_freepagetable(pagetable, sz);
    8000559c:	85d6                	mv	a1,s5
    8000559e:	855a                	mv	a0,s6
    800055a0:	fb3fc0ef          	jal	ra,80002552 <proc_freepagetable>
  if(ip){
    800055a4:	da0a12e3          	bnez	s4,80005348 <kexec+0x64>
  return -1;
    800055a8:	557d                	li	a0,-1
    800055aa:	b36d                	j	80005354 <kexec+0x70>
    end_op();
    800055ac:	bf8ff0ef          	jal	ra,800049a4 <end_op>
    printf("[pid %d] ERROR: failed to create swap file %s\n", 
    800055b0:	864e                	mv	a2,s3
    800055b2:	030ba583          	lw	a1,48(s7)
    800055b6:	00003517          	auipc	a0,0x3
    800055ba:	57250513          	addi	a0,a0,1394 # 80008b28 <syscalls+0x328>
    800055be:	f07fa0ef          	jal	ra,800004c4 <printf>
    800055c2:	bf81                	j	80005512 <kexec+0x22e>
      iunlockput(swap_ip);
    800055c4:	8562                	mv	a0,s8
    800055c6:	b97fe0ef          	jal	ra,8000415c <iunlockput>
      end_op();
    800055ca:	bdaff0ef          	jal	ra,800049a4 <end_op>
      printf("[pid %d] ERROR: failed to allocate file\n", p->pid);
    800055ce:	030ba583          	lw	a1,48(s7)
    800055d2:	00003517          	auipc	a0,0x3
    800055d6:	58650513          	addi	a0,a0,1414 # 80008b58 <syscalls+0x358>
    800055da:	eebfa0ef          	jal	ra,800004c4 <printf>
    800055de:	bf15                	j	80005512 <kexec+0x22e>
  sp = sz;
    800055e0:	8a56                	mv	s4,s5
  for(argc = 0; argv[argc]; argc++) {
    800055e2:	4981                	li	s3,0
  ustack[argc] = 0;
    800055e4:	00399793          	slli	a5,s3,0x3
    800055e8:	f9040713          	addi	a4,s0,-112
    800055ec:	97ba                	add	a5,a5,a4
    800055ee:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800055f2:	00198693          	addi	a3,s3,1
    800055f6:	068e                	slli	a3,a3,0x3
    800055f8:	40da04b3          	sub	s1,s4,a3
  sp -= sp % 16;
    800055fc:	98c1                	andi	s1,s1,-16
  ip = 0;
    800055fe:	4a01                	li	s4,0
  if(sp < stackbase)
    80005600:	f994eee3          	bltu	s1,s9,8000559c <kexec+0x2b8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005604:	e9040613          	addi	a2,s0,-368
    80005608:	85a6                	mv	a1,s1
    8000560a:	855a                	mv	a0,s6
    8000560c:	adbfc0ef          	jal	ra,800020e6 <copyout>
    80005610:	06054463          	bltz	a0,80005678 <kexec+0x394>
  p->trapframe->a1 = sp;
    80005614:	058db783          	ld	a5,88(s11)
    80005618:	ffa4                	sd	s1,120(a5)
  for(last=s=path; *s; s++)
    8000561a:	00094703          	lbu	a4,0(s2)
    8000561e:	cf11                	beqz	a4,8000563a <kexec+0x356>
    80005620:	00190793          	addi	a5,s2,1
    if(*s == '/')
    80005624:	02f00693          	li	a3,47
    80005628:	a029                	j	80005632 <kexec+0x34e>
  for(last=s=path; *s; s++)
    8000562a:	0785                	addi	a5,a5,1
    8000562c:	fff7c703          	lbu	a4,-1(a5)
    80005630:	c709                	beqz	a4,8000563a <kexec+0x356>
    if(*s == '/')
    80005632:	fed71ce3          	bne	a4,a3,8000562a <kexec+0x346>
      last = s+1;
    80005636:	893e                	mv	s2,a5
    80005638:	bfcd                	j	8000562a <kexec+0x346>
  safestrcpy(p->name, last, sizeof(p->name));
    8000563a:	4641                	li	a2,16
    8000563c:	85ca                	mv	a1,s2
    8000563e:	158d8513          	addi	a0,s11,344
    80005642:	f44fb0ef          	jal	ra,80000d86 <safestrcpy>
  oldpagetable = p->pagetable;
    80005646:	050db503          	ld	a0,80(s11)
  p->pagetable = pagetable;
    8000564a:	056db823          	sd	s6,80(s11)
  p->sz = sz;
    8000564e:	055db423          	sd	s5,72(s11)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005652:	058db783          	ld	a5,88(s11)
    80005656:	e6843703          	ld	a4,-408(s0)
    8000565a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000565c:	058db783          	ld	a5,88(s11)
    80005660:	fb84                	sd	s1,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005662:	e0843583          	ld	a1,-504(s0)
    80005666:	eedfc0ef          	jal	ra,80002552 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000566a:	0009851b          	sext.w	a0,s3
    8000566e:	b1dd                	j	80005354 <kexec+0x70>
  ip = 0;
    80005670:	4a01                	li	s4,0
    80005672:	b72d                	j	8000559c <kexec+0x2b8>
    80005674:	4a01                	li	s4,0
    80005676:	b71d                	j	8000559c <kexec+0x2b8>
    80005678:	4a01                	li	s4,0
    8000567a:	b70d                	j	8000559c <kexec+0x2b8>

000000008000567c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000567c:	7179                	addi	sp,sp,-48
    8000567e:	f406                	sd	ra,40(sp)
    80005680:	f022                	sd	s0,32(sp)
    80005682:	ec26                	sd	s1,24(sp)
    80005684:	e84a                	sd	s2,16(sp)
    80005686:	1800                	addi	s0,sp,48
    80005688:	892e                	mv	s2,a1
    8000568a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000568c:	fdc40593          	addi	a1,s0,-36
    80005690:	d9bfd0ef          	jal	ra,8000342a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005694:	fdc42703          	lw	a4,-36(s0)
    80005698:	47bd                	li	a5,15
    8000569a:	02e7e963          	bltu	a5,a4,800056cc <argfd+0x50>
    8000569e:	d2bfc0ef          	jal	ra,800023c8 <myproc>
    800056a2:	fdc42703          	lw	a4,-36(s0)
    800056a6:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ff72df2>
    800056aa:	078e                	slli	a5,a5,0x3
    800056ac:	953e                	add	a0,a0,a5
    800056ae:	611c                	ld	a5,0(a0)
    800056b0:	c385                	beqz	a5,800056d0 <argfd+0x54>
    return -1;
  if(pfd)
    800056b2:	00090463          	beqz	s2,800056ba <argfd+0x3e>
    *pfd = fd;
    800056b6:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800056ba:	4501                	li	a0,0
  if(pf)
    800056bc:	c091                	beqz	s1,800056c0 <argfd+0x44>
    *pf = f;
    800056be:	e09c                	sd	a5,0(s1)
}
    800056c0:	70a2                	ld	ra,40(sp)
    800056c2:	7402                	ld	s0,32(sp)
    800056c4:	64e2                	ld	s1,24(sp)
    800056c6:	6942                	ld	s2,16(sp)
    800056c8:	6145                	addi	sp,sp,48
    800056ca:	8082                	ret
    return -1;
    800056cc:	557d                	li	a0,-1
    800056ce:	bfcd                	j	800056c0 <argfd+0x44>
    800056d0:	557d                	li	a0,-1
    800056d2:	b7fd                	j	800056c0 <argfd+0x44>

00000000800056d4 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800056d4:	1101                	addi	sp,sp,-32
    800056d6:	ec06                	sd	ra,24(sp)
    800056d8:	e822                	sd	s0,16(sp)
    800056da:	e426                	sd	s1,8(sp)
    800056dc:	1000                	addi	s0,sp,32
    800056de:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800056e0:	ce9fc0ef          	jal	ra,800023c8 <myproc>
    800056e4:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800056e6:	0d050793          	addi	a5,a0,208
    800056ea:	4501                	li	a0,0
    800056ec:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800056ee:	6398                	ld	a4,0(a5)
    800056f0:	cb19                	beqz	a4,80005706 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800056f2:	2505                	addiw	a0,a0,1
    800056f4:	07a1                	addi	a5,a5,8
    800056f6:	fed51ce3          	bne	a0,a3,800056ee <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800056fa:	557d                	li	a0,-1
}
    800056fc:	60e2                	ld	ra,24(sp)
    800056fe:	6442                	ld	s0,16(sp)
    80005700:	64a2                	ld	s1,8(sp)
    80005702:	6105                	addi	sp,sp,32
    80005704:	8082                	ret
      p->ofile[fd] = f;
    80005706:	01a50793          	addi	a5,a0,26
    8000570a:	078e                	slli	a5,a5,0x3
    8000570c:	963e                	add	a2,a2,a5
    8000570e:	e204                	sd	s1,0(a2)
      return fd;
    80005710:	b7f5                	j	800056fc <fdalloc+0x28>

0000000080005712 <sys_dup>:

uint64
sys_dup(void)
{
    80005712:	7179                	addi	sp,sp,-48
    80005714:	f406                	sd	ra,40(sp)
    80005716:	f022                	sd	s0,32(sp)
    80005718:	ec26                	sd	s1,24(sp)
    8000571a:	1800                	addi	s0,sp,48
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
    8000571c:	fd840613          	addi	a2,s0,-40
    80005720:	4581                	li	a1,0
    80005722:	4501                	li	a0,0
    80005724:	f59ff0ef          	jal	ra,8000567c <argfd>
    return -1;
    80005728:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000572a:	00054f63          	bltz	a0,80005748 <sys_dup+0x36>
  if((fd=fdalloc(f)) < 0)
    8000572e:	fd843503          	ld	a0,-40(s0)
    80005732:	fa3ff0ef          	jal	ra,800056d4 <fdalloc>
    80005736:	84aa                	mv	s1,a0
    return -1;
    80005738:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000573a:	00054763          	bltz	a0,80005748 <sys_dup+0x36>
  filedup(f);
    8000573e:	fd843503          	ld	a0,-40(s0)
    80005742:	dbaff0ef          	jal	ra,80004cfc <filedup>
  return fd;
    80005746:	87a6                	mv	a5,s1
}
    80005748:	853e                	mv	a0,a5
    8000574a:	70a2                	ld	ra,40(sp)
    8000574c:	7402                	ld	s0,32(sp)
    8000574e:	64e2                	ld	s1,24(sp)
    80005750:	6145                	addi	sp,sp,48
    80005752:	8082                	ret

0000000080005754 <sys_read>:

uint64
sys_read(void)
{
    80005754:	7179                	addi	sp,sp,-48
    80005756:	f406                	sd	ra,40(sp)
    80005758:	f022                	sd	s0,32(sp)
    8000575a:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  argaddr(1, &p);
    8000575c:	fd840593          	addi	a1,s0,-40
    80005760:	4505                	li	a0,1
    80005762:	ce5fd0ef          	jal	ra,80003446 <argaddr>
  argint(2, &n);
    80005766:	fe440593          	addi	a1,s0,-28
    8000576a:	4509                	li	a0,2
    8000576c:	cbffd0ef          	jal	ra,8000342a <argint>
  if(argfd(0, 0, &f) < 0)
    80005770:	fe840613          	addi	a2,s0,-24
    80005774:	4581                	li	a1,0
    80005776:	4501                	li	a0,0
    80005778:	f05ff0ef          	jal	ra,8000567c <argfd>
    8000577c:	87aa                	mv	a5,a0
    return -1;
    8000577e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005780:	0007ca63          	bltz	a5,80005794 <sys_read+0x40>
  return fileread(f, p, n);
    80005784:	fe442603          	lw	a2,-28(s0)
    80005788:	fd843583          	ld	a1,-40(s0)
    8000578c:	fe843503          	ld	a0,-24(s0)
    80005790:	eb8ff0ef          	jal	ra,80004e48 <fileread>
}
    80005794:	70a2                	ld	ra,40(sp)
    80005796:	7402                	ld	s0,32(sp)
    80005798:	6145                	addi	sp,sp,48
    8000579a:	8082                	ret

000000008000579c <sys_write>:

uint64
sys_write(void)
{
    8000579c:	7179                	addi	sp,sp,-48
    8000579e:	f406                	sd	ra,40(sp)
    800057a0:	f022                	sd	s0,32(sp)
    800057a2:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;
  
  argaddr(1, &p);
    800057a4:	fd840593          	addi	a1,s0,-40
    800057a8:	4505                	li	a0,1
    800057aa:	c9dfd0ef          	jal	ra,80003446 <argaddr>
  argint(2, &n);
    800057ae:	fe440593          	addi	a1,s0,-28
    800057b2:	4509                	li	a0,2
    800057b4:	c77fd0ef          	jal	ra,8000342a <argint>
  if(argfd(0, 0, &f) < 0)
    800057b8:	fe840613          	addi	a2,s0,-24
    800057bc:	4581                	li	a1,0
    800057be:	4501                	li	a0,0
    800057c0:	ebdff0ef          	jal	ra,8000567c <argfd>
    800057c4:	87aa                	mv	a5,a0
    return -1;
    800057c6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057c8:	0007ca63          	bltz	a5,800057dc <sys_write+0x40>

  return filewrite(f, p, n);
    800057cc:	fe442603          	lw	a2,-28(s0)
    800057d0:	fd843583          	ld	a1,-40(s0)
    800057d4:	fe843503          	ld	a0,-24(s0)
    800057d8:	f1eff0ef          	jal	ra,80004ef6 <filewrite>
}
    800057dc:	70a2                	ld	ra,40(sp)
    800057de:	7402                	ld	s0,32(sp)
    800057e0:	6145                	addi	sp,sp,48
    800057e2:	8082                	ret

00000000800057e4 <sys_close>:

uint64
sys_close(void)
{
    800057e4:	1101                	addi	sp,sp,-32
    800057e6:	ec06                	sd	ra,24(sp)
    800057e8:	e822                	sd	s0,16(sp)
    800057ea:	1000                	addi	s0,sp,32
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
    800057ec:	fe040613          	addi	a2,s0,-32
    800057f0:	fec40593          	addi	a1,s0,-20
    800057f4:	4501                	li	a0,0
    800057f6:	e87ff0ef          	jal	ra,8000567c <argfd>
    return -1;
    800057fa:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800057fc:	02054063          	bltz	a0,8000581c <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80005800:	bc9fc0ef          	jal	ra,800023c8 <myproc>
    80005804:	fec42783          	lw	a5,-20(s0)
    80005808:	07e9                	addi	a5,a5,26
    8000580a:	078e                	slli	a5,a5,0x3
    8000580c:	97aa                	add	a5,a5,a0
    8000580e:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005812:	fe043503          	ld	a0,-32(s0)
    80005816:	d2cff0ef          	jal	ra,80004d42 <fileclose>
  return 0;
    8000581a:	4781                	li	a5,0
}
    8000581c:	853e                	mv	a0,a5
    8000581e:	60e2                	ld	ra,24(sp)
    80005820:	6442                	ld	s0,16(sp)
    80005822:	6105                	addi	sp,sp,32
    80005824:	8082                	ret

0000000080005826 <sys_fstat>:

uint64
sys_fstat(void)
{
    80005826:	1101                	addi	sp,sp,-32
    80005828:	ec06                	sd	ra,24(sp)
    8000582a:	e822                	sd	s0,16(sp)
    8000582c:	1000                	addi	s0,sp,32
  struct file *f;
  uint64 st; // user pointer to struct stat

  argaddr(1, &st);
    8000582e:	fe040593          	addi	a1,s0,-32
    80005832:	4505                	li	a0,1
    80005834:	c13fd0ef          	jal	ra,80003446 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005838:	fe840613          	addi	a2,s0,-24
    8000583c:	4581                	li	a1,0
    8000583e:	4501                	li	a0,0
    80005840:	e3dff0ef          	jal	ra,8000567c <argfd>
    80005844:	87aa                	mv	a5,a0
    return -1;
    80005846:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005848:	0007c863          	bltz	a5,80005858 <sys_fstat+0x32>
  return filestat(f, st);
    8000584c:	fe043583          	ld	a1,-32(s0)
    80005850:	fe843503          	ld	a0,-24(s0)
    80005854:	d96ff0ef          	jal	ra,80004dea <filestat>
}
    80005858:	60e2                	ld	ra,24(sp)
    8000585a:	6442                	ld	s0,16(sp)
    8000585c:	6105                	addi	sp,sp,32
    8000585e:	8082                	ret

0000000080005860 <sys_link>:

// Create the path new as a link to the same inode as old.
uint64
sys_link(void)
{
    80005860:	7169                	addi	sp,sp,-304
    80005862:	f606                	sd	ra,296(sp)
    80005864:	f222                	sd	s0,288(sp)
    80005866:	ee26                	sd	s1,280(sp)
    80005868:	ea4a                	sd	s2,272(sp)
    8000586a:	1a00                	addi	s0,sp,304
  char name[DIRSIZ], new[MAXPATH], old[MAXPATH];
  struct inode *dp, *ip;

  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000586c:	08000613          	li	a2,128
    80005870:	ed040593          	addi	a1,s0,-304
    80005874:	4501                	li	a0,0
    80005876:	bedfd0ef          	jal	ra,80003462 <argstr>
    return -1;
    8000587a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000587c:	0c054663          	bltz	a0,80005948 <sys_link+0xe8>
    80005880:	08000613          	li	a2,128
    80005884:	f5040593          	addi	a1,s0,-176
    80005888:	4505                	li	a0,1
    8000588a:	bd9fd0ef          	jal	ra,80003462 <argstr>
    return -1;
    8000588e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005890:	0a054c63          	bltz	a0,80005948 <sys_link+0xe8>

  begin_op();
    80005894:	8a0ff0ef          	jal	ra,80004934 <begin_op>
  if((ip = namei(old)) == 0){
    80005898:	ed040513          	addi	a0,s0,-304
    8000589c:	ea9fe0ef          	jal	ra,80004744 <namei>
    800058a0:	84aa                	mv	s1,a0
    800058a2:	c525                	beqz	a0,8000590a <sys_link+0xaa>
    end_op();
    return -1;
  }

  ilock(ip);
    800058a4:	eb2fe0ef          	jal	ra,80003f56 <ilock>
  if(ip->type == T_DIR){
    800058a8:	04449703          	lh	a4,68(s1)
    800058ac:	4785                	li	a5,1
    800058ae:	06f70263          	beq	a4,a5,80005912 <sys_link+0xb2>
    iunlockput(ip);
    end_op();
    return -1;
  }

  ip->nlink++;
    800058b2:	04a4d783          	lhu	a5,74(s1)
    800058b6:	2785                	addiw	a5,a5,1
    800058b8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800058bc:	8526                	mv	a0,s1
    800058be:	de6fe0ef          	jal	ra,80003ea4 <iupdate>
  iunlock(ip);
    800058c2:	8526                	mv	a0,s1
    800058c4:	f3cfe0ef          	jal	ra,80004000 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
    800058c8:	fd040593          	addi	a1,s0,-48
    800058cc:	f5040513          	addi	a0,s0,-176
    800058d0:	e8ffe0ef          	jal	ra,8000475e <nameiparent>
    800058d4:	892a                	mv	s2,a0
    800058d6:	c921                	beqz	a0,80005926 <sys_link+0xc6>
    goto bad;
  ilock(dp);
    800058d8:	e7efe0ef          	jal	ra,80003f56 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800058dc:	00092703          	lw	a4,0(s2)
    800058e0:	409c                	lw	a5,0(s1)
    800058e2:	02f71f63          	bne	a4,a5,80005920 <sys_link+0xc0>
    800058e6:	40d0                	lw	a2,4(s1)
    800058e8:	fd040593          	addi	a1,s0,-48
    800058ec:	854a                	mv	a0,s2
    800058ee:	dbdfe0ef          	jal	ra,800046aa <dirlink>
    800058f2:	02054763          	bltz	a0,80005920 <sys_link+0xc0>
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
    800058f6:	854a                	mv	a0,s2
    800058f8:	865fe0ef          	jal	ra,8000415c <iunlockput>
  iput(ip);
    800058fc:	8526                	mv	a0,s1
    800058fe:	fd6fe0ef          	jal	ra,800040d4 <iput>

  end_op();
    80005902:	8a2ff0ef          	jal	ra,800049a4 <end_op>

  return 0;
    80005906:	4781                	li	a5,0
    80005908:	a081                	j	80005948 <sys_link+0xe8>
    end_op();
    8000590a:	89aff0ef          	jal	ra,800049a4 <end_op>
    return -1;
    8000590e:	57fd                	li	a5,-1
    80005910:	a825                	j	80005948 <sys_link+0xe8>
    iunlockput(ip);
    80005912:	8526                	mv	a0,s1
    80005914:	849fe0ef          	jal	ra,8000415c <iunlockput>
    end_op();
    80005918:	88cff0ef          	jal	ra,800049a4 <end_op>
    return -1;
    8000591c:	57fd                	li	a5,-1
    8000591e:	a02d                	j	80005948 <sys_link+0xe8>
    iunlockput(dp);
    80005920:	854a                	mv	a0,s2
    80005922:	83bfe0ef          	jal	ra,8000415c <iunlockput>

bad:
  ilock(ip);
    80005926:	8526                	mv	a0,s1
    80005928:	e2efe0ef          	jal	ra,80003f56 <ilock>
  ip->nlink--;
    8000592c:	04a4d783          	lhu	a5,74(s1)
    80005930:	37fd                	addiw	a5,a5,-1
    80005932:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005936:	8526                	mv	a0,s1
    80005938:	d6cfe0ef          	jal	ra,80003ea4 <iupdate>
  iunlockput(ip);
    8000593c:	8526                	mv	a0,s1
    8000593e:	81ffe0ef          	jal	ra,8000415c <iunlockput>
  end_op();
    80005942:	862ff0ef          	jal	ra,800049a4 <end_op>
  return -1;
    80005946:	57fd                	li	a5,-1
}
    80005948:	853e                	mv	a0,a5
    8000594a:	70b2                	ld	ra,296(sp)
    8000594c:	7412                	ld	s0,288(sp)
    8000594e:	64f2                	ld	s1,280(sp)
    80005950:	6952                	ld	s2,272(sp)
    80005952:	6155                	addi	sp,sp,304
    80005954:	8082                	ret

0000000080005956 <sys_unlink>:
  return 1;
}

uint64
sys_unlink(void)
{
    80005956:	7151                	addi	sp,sp,-240
    80005958:	f586                	sd	ra,232(sp)
    8000595a:	f1a2                	sd	s0,224(sp)
    8000595c:	eda6                	sd	s1,216(sp)
    8000595e:	e9ca                	sd	s2,208(sp)
    80005960:	e5ce                	sd	s3,200(sp)
    80005962:	1980                	addi	s0,sp,240
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], path[MAXPATH];
  uint off;

  if(argstr(0, path, MAXPATH) < 0)
    80005964:	08000613          	li	a2,128
    80005968:	f3040593          	addi	a1,s0,-208
    8000596c:	4501                	li	a0,0
    8000596e:	af5fd0ef          	jal	ra,80003462 <argstr>
    80005972:	12054b63          	bltz	a0,80005aa8 <sys_unlink+0x152>
    return -1;

  begin_op();
    80005976:	fbffe0ef          	jal	ra,80004934 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000597a:	fb040593          	addi	a1,s0,-80
    8000597e:	f3040513          	addi	a0,s0,-208
    80005982:	dddfe0ef          	jal	ra,8000475e <nameiparent>
    80005986:	84aa                	mv	s1,a0
    80005988:	c54d                	beqz	a0,80005a32 <sys_unlink+0xdc>
    end_op();
    return -1;
  }

  ilock(dp);
    8000598a:	dccfe0ef          	jal	ra,80003f56 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000598e:	00003597          	auipc	a1,0x3
    80005992:	1fa58593          	addi	a1,a1,506 # 80008b88 <syscalls+0x388>
    80005996:	fb040513          	addi	a0,s0,-80
    8000599a:	b2ffe0ef          	jal	ra,800044c8 <namecmp>
    8000599e:	10050a63          	beqz	a0,80005ab2 <sys_unlink+0x15c>
    800059a2:	00003597          	auipc	a1,0x3
    800059a6:	1ee58593          	addi	a1,a1,494 # 80008b90 <syscalls+0x390>
    800059aa:	fb040513          	addi	a0,s0,-80
    800059ae:	b1bfe0ef          	jal	ra,800044c8 <namecmp>
    800059b2:	10050063          	beqz	a0,80005ab2 <sys_unlink+0x15c>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    800059b6:	f2c40613          	addi	a2,s0,-212
    800059ba:	fb040593          	addi	a1,s0,-80
    800059be:	8526                	mv	a0,s1
    800059c0:	b1ffe0ef          	jal	ra,800044de <dirlookup>
    800059c4:	892a                	mv	s2,a0
    800059c6:	0e050663          	beqz	a0,80005ab2 <sys_unlink+0x15c>
    goto bad;
  ilock(ip);
    800059ca:	d8cfe0ef          	jal	ra,80003f56 <ilock>

  if(ip->nlink < 1)
    800059ce:	04a91783          	lh	a5,74(s2)
    800059d2:	06f05463          	blez	a5,80005a3a <sys_unlink+0xe4>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    800059d6:	04491703          	lh	a4,68(s2)
    800059da:	4785                	li	a5,1
    800059dc:	06f70563          	beq	a4,a5,80005a46 <sys_unlink+0xf0>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    800059e0:	4641                	li	a2,16
    800059e2:	4581                	li	a1,0
    800059e4:	fc040513          	addi	a0,s0,-64
    800059e8:	a58fb0ef          	jal	ra,80000c40 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800059ec:	4741                	li	a4,16
    800059ee:	f2c42683          	lw	a3,-212(s0)
    800059f2:	fc040613          	addi	a2,s0,-64
    800059f6:	4581                	li	a1,0
    800059f8:	8526                	mv	a0,s1
    800059fa:	9cdfe0ef          	jal	ra,800043c6 <writei>
    800059fe:	47c1                	li	a5,16
    80005a00:	08f51563          	bne	a0,a5,80005a8a <sys_unlink+0x134>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    80005a04:	04491703          	lh	a4,68(s2)
    80005a08:	4785                	li	a5,1
    80005a0a:	08f70663          	beq	a4,a5,80005a96 <sys_unlink+0x140>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    80005a0e:	8526                	mv	a0,s1
    80005a10:	f4cfe0ef          	jal	ra,8000415c <iunlockput>

  ip->nlink--;
    80005a14:	04a95783          	lhu	a5,74(s2)
    80005a18:	37fd                	addiw	a5,a5,-1
    80005a1a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005a1e:	854a                	mv	a0,s2
    80005a20:	c84fe0ef          	jal	ra,80003ea4 <iupdate>
  iunlockput(ip);
    80005a24:	854a                	mv	a0,s2
    80005a26:	f36fe0ef          	jal	ra,8000415c <iunlockput>

  end_op();
    80005a2a:	f7bfe0ef          	jal	ra,800049a4 <end_op>

  return 0;
    80005a2e:	4501                	li	a0,0
    80005a30:	a079                	j	80005abe <sys_unlink+0x168>
    end_op();
    80005a32:	f73fe0ef          	jal	ra,800049a4 <end_op>
    return -1;
    80005a36:	557d                	li	a0,-1
    80005a38:	a059                	j	80005abe <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80005a3a:	00003517          	auipc	a0,0x3
    80005a3e:	15e50513          	addi	a0,a0,350 # 80008b98 <syscalls+0x398>
    80005a42:	d49fa0ef          	jal	ra,8000078a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a46:	04c92703          	lw	a4,76(s2)
    80005a4a:	02000793          	li	a5,32
    80005a4e:	f8e7f9e3          	bgeu	a5,a4,800059e0 <sys_unlink+0x8a>
    80005a52:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a56:	4741                	li	a4,16
    80005a58:	86ce                	mv	a3,s3
    80005a5a:	f1840613          	addi	a2,s0,-232
    80005a5e:	4581                	li	a1,0
    80005a60:	854a                	mv	a0,s2
    80005a62:	881fe0ef          	jal	ra,800042e2 <readi>
    80005a66:	47c1                	li	a5,16
    80005a68:	00f51b63          	bne	a0,a5,80005a7e <sys_unlink+0x128>
    if(de.inum != 0)
    80005a6c:	f1845783          	lhu	a5,-232(s0)
    80005a70:	ef95                	bnez	a5,80005aac <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a72:	29c1                	addiw	s3,s3,16
    80005a74:	04c92783          	lw	a5,76(s2)
    80005a78:	fcf9efe3          	bltu	s3,a5,80005a56 <sys_unlink+0x100>
    80005a7c:	b795                	j	800059e0 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005a7e:	00003517          	auipc	a0,0x3
    80005a82:	13250513          	addi	a0,a0,306 # 80008bb0 <syscalls+0x3b0>
    80005a86:	d05fa0ef          	jal	ra,8000078a <panic>
    panic("unlink: writei");
    80005a8a:	00003517          	auipc	a0,0x3
    80005a8e:	13e50513          	addi	a0,a0,318 # 80008bc8 <syscalls+0x3c8>
    80005a92:	cf9fa0ef          	jal	ra,8000078a <panic>
    dp->nlink--;
    80005a96:	04a4d783          	lhu	a5,74(s1)
    80005a9a:	37fd                	addiw	a5,a5,-1
    80005a9c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005aa0:	8526                	mv	a0,s1
    80005aa2:	c02fe0ef          	jal	ra,80003ea4 <iupdate>
    80005aa6:	b7a5                	j	80005a0e <sys_unlink+0xb8>
    return -1;
    80005aa8:	557d                	li	a0,-1
    80005aaa:	a811                	j	80005abe <sys_unlink+0x168>
    iunlockput(ip);
    80005aac:	854a                	mv	a0,s2
    80005aae:	eaefe0ef          	jal	ra,8000415c <iunlockput>

bad:
  iunlockput(dp);
    80005ab2:	8526                	mv	a0,s1
    80005ab4:	ea8fe0ef          	jal	ra,8000415c <iunlockput>
  end_op();
    80005ab8:	eedfe0ef          	jal	ra,800049a4 <end_op>
  return -1;
    80005abc:	557d                	li	a0,-1
}
    80005abe:	70ae                	ld	ra,232(sp)
    80005ac0:	740e                	ld	s0,224(sp)
    80005ac2:	64ee                	ld	s1,216(sp)
    80005ac4:	694e                	ld	s2,208(sp)
    80005ac6:	69ae                	ld	s3,200(sp)
    80005ac8:	616d                	addi	sp,sp,240
    80005aca:	8082                	ret

0000000080005acc <create>:

 struct inode*
create(char *path, short type, short major, short minor)
{
    80005acc:	715d                	addi	sp,sp,-80
    80005ace:	e486                	sd	ra,72(sp)
    80005ad0:	e0a2                	sd	s0,64(sp)
    80005ad2:	fc26                	sd	s1,56(sp)
    80005ad4:	f84a                	sd	s2,48(sp)
    80005ad6:	f44e                	sd	s3,40(sp)
    80005ad8:	f052                	sd	s4,32(sp)
    80005ada:	ec56                	sd	s5,24(sp)
    80005adc:	e85a                	sd	s6,16(sp)
    80005ade:	0880                	addi	s0,sp,80
    80005ae0:	8b2e                	mv	s6,a1
    80005ae2:	89b2                	mv	s3,a2
    80005ae4:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005ae6:	fb040593          	addi	a1,s0,-80
    80005aea:	c75fe0ef          	jal	ra,8000475e <nameiparent>
    80005aee:	84aa                	mv	s1,a0
    80005af0:	10050b63          	beqz	a0,80005c06 <create+0x13a>
    return 0;

  ilock(dp);
    80005af4:	c62fe0ef          	jal	ra,80003f56 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005af8:	4601                	li	a2,0
    80005afa:	fb040593          	addi	a1,s0,-80
    80005afe:	8526                	mv	a0,s1
    80005b00:	9dffe0ef          	jal	ra,800044de <dirlookup>
    80005b04:	8aaa                	mv	s5,a0
    80005b06:	c521                	beqz	a0,80005b4e <create+0x82>
    iunlockput(dp);
    80005b08:	8526                	mv	a0,s1
    80005b0a:	e52fe0ef          	jal	ra,8000415c <iunlockput>
    ilock(ip);
    80005b0e:	8556                	mv	a0,s5
    80005b10:	c46fe0ef          	jal	ra,80003f56 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005b14:	000b059b          	sext.w	a1,s6
    80005b18:	4789                	li	a5,2
    80005b1a:	02f59563          	bne	a1,a5,80005b44 <create+0x78>
    80005b1e:	044ad783          	lhu	a5,68(s5) # 2044 <_entry-0x7fffdfbc>
    80005b22:	37f9                	addiw	a5,a5,-2
    80005b24:	17c2                	slli	a5,a5,0x30
    80005b26:	93c1                	srli	a5,a5,0x30
    80005b28:	4705                	li	a4,1
    80005b2a:	00f76d63          	bltu	a4,a5,80005b44 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005b2e:	8556                	mv	a0,s5
    80005b30:	60a6                	ld	ra,72(sp)
    80005b32:	6406                	ld	s0,64(sp)
    80005b34:	74e2                	ld	s1,56(sp)
    80005b36:	7942                	ld	s2,48(sp)
    80005b38:	79a2                	ld	s3,40(sp)
    80005b3a:	7a02                	ld	s4,32(sp)
    80005b3c:	6ae2                	ld	s5,24(sp)
    80005b3e:	6b42                	ld	s6,16(sp)
    80005b40:	6161                	addi	sp,sp,80
    80005b42:	8082                	ret
    iunlockput(ip);
    80005b44:	8556                	mv	a0,s5
    80005b46:	e16fe0ef          	jal	ra,8000415c <iunlockput>
    return 0;
    80005b4a:	4a81                	li	s5,0
    80005b4c:	b7cd                	j	80005b2e <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005b4e:	85da                	mv	a1,s6
    80005b50:	4088                	lw	a0,0(s1)
    80005b52:	a9cfe0ef          	jal	ra,80003dee <ialloc>
    80005b56:	8a2a                	mv	s4,a0
    80005b58:	cd1d                	beqz	a0,80005b96 <create+0xca>
  ilock(ip);
    80005b5a:	bfcfe0ef          	jal	ra,80003f56 <ilock>
  ip->major = major;
    80005b5e:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005b62:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005b66:	4905                	li	s2,1
    80005b68:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005b6c:	8552                	mv	a0,s4
    80005b6e:	b36fe0ef          	jal	ra,80003ea4 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005b72:	000b059b          	sext.w	a1,s6
    80005b76:	03258563          	beq	a1,s2,80005ba0 <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    80005b7a:	004a2603          	lw	a2,4(s4)
    80005b7e:	fb040593          	addi	a1,s0,-80
    80005b82:	8526                	mv	a0,s1
    80005b84:	b27fe0ef          	jal	ra,800046aa <dirlink>
    80005b88:	06054363          	bltz	a0,80005bee <create+0x122>
  iunlockput(dp);
    80005b8c:	8526                	mv	a0,s1
    80005b8e:	dcefe0ef          	jal	ra,8000415c <iunlockput>
  return ip;
    80005b92:	8ad2                	mv	s5,s4
    80005b94:	bf69                	j	80005b2e <create+0x62>
    iunlockput(dp);
    80005b96:	8526                	mv	a0,s1
    80005b98:	dc4fe0ef          	jal	ra,8000415c <iunlockput>
    return 0;
    80005b9c:	8ad2                	mv	s5,s4
    80005b9e:	bf41                	j	80005b2e <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005ba0:	004a2603          	lw	a2,4(s4)
    80005ba4:	00003597          	auipc	a1,0x3
    80005ba8:	fe458593          	addi	a1,a1,-28 # 80008b88 <syscalls+0x388>
    80005bac:	8552                	mv	a0,s4
    80005bae:	afdfe0ef          	jal	ra,800046aa <dirlink>
    80005bb2:	02054e63          	bltz	a0,80005bee <create+0x122>
    80005bb6:	40d0                	lw	a2,4(s1)
    80005bb8:	00003597          	auipc	a1,0x3
    80005bbc:	fd858593          	addi	a1,a1,-40 # 80008b90 <syscalls+0x390>
    80005bc0:	8552                	mv	a0,s4
    80005bc2:	ae9fe0ef          	jal	ra,800046aa <dirlink>
    80005bc6:	02054463          	bltz	a0,80005bee <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    80005bca:	004a2603          	lw	a2,4(s4)
    80005bce:	fb040593          	addi	a1,s0,-80
    80005bd2:	8526                	mv	a0,s1
    80005bd4:	ad7fe0ef          	jal	ra,800046aa <dirlink>
    80005bd8:	00054b63          	bltz	a0,80005bee <create+0x122>
    dp->nlink++;  // for ".."
    80005bdc:	04a4d783          	lhu	a5,74(s1)
    80005be0:	2785                	addiw	a5,a5,1
    80005be2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005be6:	8526                	mv	a0,s1
    80005be8:	abcfe0ef          	jal	ra,80003ea4 <iupdate>
    80005bec:	b745                	j	80005b8c <create+0xc0>
  ip->nlink = 0;
    80005bee:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005bf2:	8552                	mv	a0,s4
    80005bf4:	ab0fe0ef          	jal	ra,80003ea4 <iupdate>
  iunlockput(ip);
    80005bf8:	8552                	mv	a0,s4
    80005bfa:	d62fe0ef          	jal	ra,8000415c <iunlockput>
  iunlockput(dp);
    80005bfe:	8526                	mv	a0,s1
    80005c00:	d5cfe0ef          	jal	ra,8000415c <iunlockput>
  return 0;
    80005c04:	b72d                	j	80005b2e <create+0x62>
    return 0;
    80005c06:	8aaa                	mv	s5,a0
    80005c08:	b71d                	j	80005b2e <create+0x62>

0000000080005c0a <sys_open>:

uint64
sys_open(void)
{
    80005c0a:	7131                	addi	sp,sp,-192
    80005c0c:	fd06                	sd	ra,184(sp)
    80005c0e:	f922                	sd	s0,176(sp)
    80005c10:	f526                	sd	s1,168(sp)
    80005c12:	f14a                	sd	s2,160(sp)
    80005c14:	ed4e                	sd	s3,152(sp)
    80005c16:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005c18:	f4c40593          	addi	a1,s0,-180
    80005c1c:	4505                	li	a0,1
    80005c1e:	80dfd0ef          	jal	ra,8000342a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005c22:	08000613          	li	a2,128
    80005c26:	f5040593          	addi	a1,s0,-176
    80005c2a:	4501                	li	a0,0
    80005c2c:	837fd0ef          	jal	ra,80003462 <argstr>
    80005c30:	87aa                	mv	a5,a0
    return -1;
    80005c32:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005c34:	0807cd63          	bltz	a5,80005cce <sys_open+0xc4>

  begin_op();
    80005c38:	cfdfe0ef          	jal	ra,80004934 <begin_op>

  if(omode & O_CREATE){
    80005c3c:	f4c42783          	lw	a5,-180(s0)
    80005c40:	2007f793          	andi	a5,a5,512
    80005c44:	c3c5                	beqz	a5,80005ce4 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005c46:	4681                	li	a3,0
    80005c48:	4601                	li	a2,0
    80005c4a:	4589                	li	a1,2
    80005c4c:	f5040513          	addi	a0,s0,-176
    80005c50:	e7dff0ef          	jal	ra,80005acc <create>
    80005c54:	84aa                	mv	s1,a0
    if(ip == 0){
    80005c56:	c159                	beqz	a0,80005cdc <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005c58:	04449703          	lh	a4,68(s1)
    80005c5c:	478d                	li	a5,3
    80005c5e:	00f71763          	bne	a4,a5,80005c6c <sys_open+0x62>
    80005c62:	0464d703          	lhu	a4,70(s1)
    80005c66:	47a5                	li	a5,9
    80005c68:	0ae7e963          	bltu	a5,a4,80005d1a <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005c6c:	832ff0ef          	jal	ra,80004c9e <filealloc>
    80005c70:	89aa                	mv	s3,a0
    80005c72:	0c050963          	beqz	a0,80005d44 <sys_open+0x13a>
    80005c76:	a5fff0ef          	jal	ra,800056d4 <fdalloc>
    80005c7a:	892a                	mv	s2,a0
    80005c7c:	0c054163          	bltz	a0,80005d3e <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005c80:	04449703          	lh	a4,68(s1)
    80005c84:	478d                	li	a5,3
    80005c86:	0af70163          	beq	a4,a5,80005d28 <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005c8a:	4789                	li	a5,2
    80005c8c:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005c90:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005c94:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005c98:	f4c42783          	lw	a5,-180(s0)
    80005c9c:	0017c713          	xori	a4,a5,1
    80005ca0:	8b05                	andi	a4,a4,1
    80005ca2:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005ca6:	0037f713          	andi	a4,a5,3
    80005caa:	00e03733          	snez	a4,a4
    80005cae:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005cb2:	4007f793          	andi	a5,a5,1024
    80005cb6:	c791                	beqz	a5,80005cc2 <sys_open+0xb8>
    80005cb8:	04449703          	lh	a4,68(s1)
    80005cbc:	4789                	li	a5,2
    80005cbe:	06f70c63          	beq	a4,a5,80005d36 <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    80005cc2:	8526                	mv	a0,s1
    80005cc4:	b3cfe0ef          	jal	ra,80004000 <iunlock>
  end_op();
    80005cc8:	cddfe0ef          	jal	ra,800049a4 <end_op>

  return fd;
    80005ccc:	854a                	mv	a0,s2
}
    80005cce:	70ea                	ld	ra,184(sp)
    80005cd0:	744a                	ld	s0,176(sp)
    80005cd2:	74aa                	ld	s1,168(sp)
    80005cd4:	790a                	ld	s2,160(sp)
    80005cd6:	69ea                	ld	s3,152(sp)
    80005cd8:	6129                	addi	sp,sp,192
    80005cda:	8082                	ret
      end_op();
    80005cdc:	cc9fe0ef          	jal	ra,800049a4 <end_op>
      return -1;
    80005ce0:	557d                	li	a0,-1
    80005ce2:	b7f5                	j	80005cce <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    80005ce4:	f5040513          	addi	a0,s0,-176
    80005ce8:	a5dfe0ef          	jal	ra,80004744 <namei>
    80005cec:	84aa                	mv	s1,a0
    80005cee:	c115                	beqz	a0,80005d12 <sys_open+0x108>
    ilock(ip);
    80005cf0:	a66fe0ef          	jal	ra,80003f56 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005cf4:	04449703          	lh	a4,68(s1)
    80005cf8:	4785                	li	a5,1
    80005cfa:	f4f71fe3          	bne	a4,a5,80005c58 <sys_open+0x4e>
    80005cfe:	f4c42783          	lw	a5,-180(s0)
    80005d02:	d7ad                	beqz	a5,80005c6c <sys_open+0x62>
      iunlockput(ip);
    80005d04:	8526                	mv	a0,s1
    80005d06:	c56fe0ef          	jal	ra,8000415c <iunlockput>
      end_op();
    80005d0a:	c9bfe0ef          	jal	ra,800049a4 <end_op>
      return -1;
    80005d0e:	557d                	li	a0,-1
    80005d10:	bf7d                	j	80005cce <sys_open+0xc4>
      end_op();
    80005d12:	c93fe0ef          	jal	ra,800049a4 <end_op>
      return -1;
    80005d16:	557d                	li	a0,-1
    80005d18:	bf5d                	j	80005cce <sys_open+0xc4>
    iunlockput(ip);
    80005d1a:	8526                	mv	a0,s1
    80005d1c:	c40fe0ef          	jal	ra,8000415c <iunlockput>
    end_op();
    80005d20:	c85fe0ef          	jal	ra,800049a4 <end_op>
    return -1;
    80005d24:	557d                	li	a0,-1
    80005d26:	b765                	j	80005cce <sys_open+0xc4>
    f->type = FD_DEVICE;
    80005d28:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005d2c:	04649783          	lh	a5,70(s1)
    80005d30:	02f99223          	sh	a5,36(s3)
    80005d34:	b785                	j	80005c94 <sys_open+0x8a>
    itrunc(ip);
    80005d36:	8526                	mv	a0,s1
    80005d38:	b08fe0ef          	jal	ra,80004040 <itrunc>
    80005d3c:	b759                	j	80005cc2 <sys_open+0xb8>
      fileclose(f);
    80005d3e:	854e                	mv	a0,s3
    80005d40:	802ff0ef          	jal	ra,80004d42 <fileclose>
    iunlockput(ip);
    80005d44:	8526                	mv	a0,s1
    80005d46:	c16fe0ef          	jal	ra,8000415c <iunlockput>
    end_op();
    80005d4a:	c5bfe0ef          	jal	ra,800049a4 <end_op>
    return -1;
    80005d4e:	557d                	li	a0,-1
    80005d50:	bfbd                	j	80005cce <sys_open+0xc4>

0000000080005d52 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005d52:	7175                	addi	sp,sp,-144
    80005d54:	e506                	sd	ra,136(sp)
    80005d56:	e122                	sd	s0,128(sp)
    80005d58:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005d5a:	bdbfe0ef          	jal	ra,80004934 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005d5e:	08000613          	li	a2,128
    80005d62:	f7040593          	addi	a1,s0,-144
    80005d66:	4501                	li	a0,0
    80005d68:	efafd0ef          	jal	ra,80003462 <argstr>
    80005d6c:	02054363          	bltz	a0,80005d92 <sys_mkdir+0x40>
    80005d70:	4681                	li	a3,0
    80005d72:	4601                	li	a2,0
    80005d74:	4585                	li	a1,1
    80005d76:	f7040513          	addi	a0,s0,-144
    80005d7a:	d53ff0ef          	jal	ra,80005acc <create>
    80005d7e:	c911                	beqz	a0,80005d92 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d80:	bdcfe0ef          	jal	ra,8000415c <iunlockput>
  end_op();
    80005d84:	c21fe0ef          	jal	ra,800049a4 <end_op>
  return 0;
    80005d88:	4501                	li	a0,0
}
    80005d8a:	60aa                	ld	ra,136(sp)
    80005d8c:	640a                	ld	s0,128(sp)
    80005d8e:	6149                	addi	sp,sp,144
    80005d90:	8082                	ret
    end_op();
    80005d92:	c13fe0ef          	jal	ra,800049a4 <end_op>
    return -1;
    80005d96:	557d                	li	a0,-1
    80005d98:	bfcd                	j	80005d8a <sys_mkdir+0x38>

0000000080005d9a <sys_mknod>:

uint64
sys_mknod(void)
{
    80005d9a:	7135                	addi	sp,sp,-160
    80005d9c:	ed06                	sd	ra,152(sp)
    80005d9e:	e922                	sd	s0,144(sp)
    80005da0:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005da2:	b93fe0ef          	jal	ra,80004934 <begin_op>
  argint(1, &major);
    80005da6:	f6c40593          	addi	a1,s0,-148
    80005daa:	4505                	li	a0,1
    80005dac:	e7efd0ef          	jal	ra,8000342a <argint>
  argint(2, &minor);
    80005db0:	f6840593          	addi	a1,s0,-152
    80005db4:	4509                	li	a0,2
    80005db6:	e74fd0ef          	jal	ra,8000342a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005dba:	08000613          	li	a2,128
    80005dbe:	f7040593          	addi	a1,s0,-144
    80005dc2:	4501                	li	a0,0
    80005dc4:	e9efd0ef          	jal	ra,80003462 <argstr>
    80005dc8:	02054563          	bltz	a0,80005df2 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005dcc:	f6841683          	lh	a3,-152(s0)
    80005dd0:	f6c41603          	lh	a2,-148(s0)
    80005dd4:	458d                	li	a1,3
    80005dd6:	f7040513          	addi	a0,s0,-144
    80005dda:	cf3ff0ef          	jal	ra,80005acc <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005dde:	c911                	beqz	a0,80005df2 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005de0:	b7cfe0ef          	jal	ra,8000415c <iunlockput>
  end_op();
    80005de4:	bc1fe0ef          	jal	ra,800049a4 <end_op>
  return 0;
    80005de8:	4501                	li	a0,0
}
    80005dea:	60ea                	ld	ra,152(sp)
    80005dec:	644a                	ld	s0,144(sp)
    80005dee:	610d                	addi	sp,sp,160
    80005df0:	8082                	ret
    end_op();
    80005df2:	bb3fe0ef          	jal	ra,800049a4 <end_op>
    return -1;
    80005df6:	557d                	li	a0,-1
    80005df8:	bfcd                	j	80005dea <sys_mknod+0x50>

0000000080005dfa <sys_chdir>:

uint64
sys_chdir(void)
{
    80005dfa:	7135                	addi	sp,sp,-160
    80005dfc:	ed06                	sd	ra,152(sp)
    80005dfe:	e922                	sd	s0,144(sp)
    80005e00:	e526                	sd	s1,136(sp)
    80005e02:	e14a                	sd	s2,128(sp)
    80005e04:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005e06:	dc2fc0ef          	jal	ra,800023c8 <myproc>
    80005e0a:	892a                	mv	s2,a0
  
  begin_op();
    80005e0c:	b29fe0ef          	jal	ra,80004934 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005e10:	08000613          	li	a2,128
    80005e14:	f6040593          	addi	a1,s0,-160
    80005e18:	4501                	li	a0,0
    80005e1a:	e48fd0ef          	jal	ra,80003462 <argstr>
    80005e1e:	04054163          	bltz	a0,80005e60 <sys_chdir+0x66>
    80005e22:	f6040513          	addi	a0,s0,-160
    80005e26:	91ffe0ef          	jal	ra,80004744 <namei>
    80005e2a:	84aa                	mv	s1,a0
    80005e2c:	c915                	beqz	a0,80005e60 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005e2e:	928fe0ef          	jal	ra,80003f56 <ilock>
  if(ip->type != T_DIR){
    80005e32:	04449703          	lh	a4,68(s1)
    80005e36:	4785                	li	a5,1
    80005e38:	02f71863          	bne	a4,a5,80005e68 <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005e3c:	8526                	mv	a0,s1
    80005e3e:	9c2fe0ef          	jal	ra,80004000 <iunlock>
  iput(p->cwd);
    80005e42:	15093503          	ld	a0,336(s2)
    80005e46:	a8efe0ef          	jal	ra,800040d4 <iput>
  end_op();
    80005e4a:	b5bfe0ef          	jal	ra,800049a4 <end_op>
  p->cwd = ip;
    80005e4e:	14993823          	sd	s1,336(s2)
  return 0;
    80005e52:	4501                	li	a0,0
}
    80005e54:	60ea                	ld	ra,152(sp)
    80005e56:	644a                	ld	s0,144(sp)
    80005e58:	64aa                	ld	s1,136(sp)
    80005e5a:	690a                	ld	s2,128(sp)
    80005e5c:	610d                	addi	sp,sp,160
    80005e5e:	8082                	ret
    end_op();
    80005e60:	b45fe0ef          	jal	ra,800049a4 <end_op>
    return -1;
    80005e64:	557d                	li	a0,-1
    80005e66:	b7fd                	j	80005e54 <sys_chdir+0x5a>
    iunlockput(ip);
    80005e68:	8526                	mv	a0,s1
    80005e6a:	af2fe0ef          	jal	ra,8000415c <iunlockput>
    end_op();
    80005e6e:	b37fe0ef          	jal	ra,800049a4 <end_op>
    return -1;
    80005e72:	557d                	li	a0,-1
    80005e74:	b7c5                	j	80005e54 <sys_chdir+0x5a>

0000000080005e76 <sys_exec>:

uint64
sys_exec(void)
{
    80005e76:	7145                	addi	sp,sp,-464
    80005e78:	e786                	sd	ra,456(sp)
    80005e7a:	e3a2                	sd	s0,448(sp)
    80005e7c:	ff26                	sd	s1,440(sp)
    80005e7e:	fb4a                	sd	s2,432(sp)
    80005e80:	f74e                	sd	s3,424(sp)
    80005e82:	f352                	sd	s4,416(sp)
    80005e84:	ef56                	sd	s5,408(sp)
    80005e86:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005e88:	e3840593          	addi	a1,s0,-456
    80005e8c:	4505                	li	a0,1
    80005e8e:	db8fd0ef          	jal	ra,80003446 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005e92:	08000613          	li	a2,128
    80005e96:	f4040593          	addi	a1,s0,-192
    80005e9a:	4501                	li	a0,0
    80005e9c:	dc6fd0ef          	jal	ra,80003462 <argstr>
    80005ea0:	87aa                	mv	a5,a0
    return -1;
    80005ea2:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005ea4:	0a07c463          	bltz	a5,80005f4c <sys_exec+0xd6>
  }
  memset(argv, 0, sizeof(argv));
    80005ea8:	10000613          	li	a2,256
    80005eac:	4581                	li	a1,0
    80005eae:	e4040513          	addi	a0,s0,-448
    80005eb2:	d8ffa0ef          	jal	ra,80000c40 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005eb6:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005eba:	89a6                	mv	s3,s1
    80005ebc:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005ebe:	02000a13          	li	s4,32
    80005ec2:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005ec6:	00391793          	slli	a5,s2,0x3
    80005eca:	e3040593          	addi	a1,s0,-464
    80005ece:	e3843503          	ld	a0,-456(s0)
    80005ed2:	953e                	add	a0,a0,a5
    80005ed4:	cccfd0ef          	jal	ra,800033a0 <fetchaddr>
    80005ed8:	02054663          	bltz	a0,80005f04 <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    80005edc:	e3043783          	ld	a5,-464(s0)
    80005ee0:	cf8d                	beqz	a5,80005f1a <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005ee2:	bbbfa0ef          	jal	ra,80000a9c <kalloc>
    80005ee6:	85aa                	mv	a1,a0
    80005ee8:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005eec:	cd01                	beqz	a0,80005f04 <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005eee:	6605                	lui	a2,0x1
    80005ef0:	e3043503          	ld	a0,-464(s0)
    80005ef4:	cf6fd0ef          	jal	ra,800033ea <fetchstr>
    80005ef8:	00054663          	bltz	a0,80005f04 <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    80005efc:	0905                	addi	s2,s2,1
    80005efe:	09a1                	addi	s3,s3,8
    80005f00:	fd4911e3          	bne	s2,s4,80005ec2 <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f04:	10048913          	addi	s2,s1,256
    80005f08:	6088                	ld	a0,0(s1)
    80005f0a:	c121                	beqz	a0,80005f4a <sys_exec+0xd4>
    kfree(argv[i]);
    80005f0c:	ab1fa0ef          	jal	ra,800009bc <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f10:	04a1                	addi	s1,s1,8
    80005f12:	ff249be3          	bne	s1,s2,80005f08 <sys_exec+0x92>
  return -1;
    80005f16:	557d                	li	a0,-1
    80005f18:	a815                	j	80005f4c <sys_exec+0xd6>
      argv[i] = 0;
    80005f1a:	0a8e                	slli	s5,s5,0x3
    80005f1c:	fc040793          	addi	a5,s0,-64
    80005f20:	9abe                	add	s5,s5,a5
    80005f22:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    80005f26:	e4040593          	addi	a1,s0,-448
    80005f2a:	f4040513          	addi	a0,s0,-192
    80005f2e:	bb6ff0ef          	jal	ra,800052e4 <kexec>
    80005f32:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f34:	10048993          	addi	s3,s1,256
    80005f38:	6088                	ld	a0,0(s1)
    80005f3a:	c511                	beqz	a0,80005f46 <sys_exec+0xd0>
    kfree(argv[i]);
    80005f3c:	a81fa0ef          	jal	ra,800009bc <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f40:	04a1                	addi	s1,s1,8
    80005f42:	ff349be3          	bne	s1,s3,80005f38 <sys_exec+0xc2>
  return ret;
    80005f46:	854a                	mv	a0,s2
    80005f48:	a011                	j	80005f4c <sys_exec+0xd6>
  return -1;
    80005f4a:	557d                	li	a0,-1
}
    80005f4c:	60be                	ld	ra,456(sp)
    80005f4e:	641e                	ld	s0,448(sp)
    80005f50:	74fa                	ld	s1,440(sp)
    80005f52:	795a                	ld	s2,432(sp)
    80005f54:	79ba                	ld	s3,424(sp)
    80005f56:	7a1a                	ld	s4,416(sp)
    80005f58:	6afa                	ld	s5,408(sp)
    80005f5a:	6179                	addi	sp,sp,464
    80005f5c:	8082                	ret

0000000080005f5e <sys_pipe>:

uint64
sys_pipe(void)
{
    80005f5e:	7139                	addi	sp,sp,-64
    80005f60:	fc06                	sd	ra,56(sp)
    80005f62:	f822                	sd	s0,48(sp)
    80005f64:	f426                	sd	s1,40(sp)
    80005f66:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005f68:	c60fc0ef          	jal	ra,800023c8 <myproc>
    80005f6c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005f6e:	fd840593          	addi	a1,s0,-40
    80005f72:	4501                	li	a0,0
    80005f74:	cd2fd0ef          	jal	ra,80003446 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005f78:	fc840593          	addi	a1,s0,-56
    80005f7c:	fd040513          	addi	a0,s0,-48
    80005f80:	88eff0ef          	jal	ra,8000500e <pipealloc>
    return -1;
    80005f84:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005f86:	0a054463          	bltz	a0,8000602e <sys_pipe+0xd0>
  fd0 = -1;
    80005f8a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005f8e:	fd043503          	ld	a0,-48(s0)
    80005f92:	f42ff0ef          	jal	ra,800056d4 <fdalloc>
    80005f96:	fca42223          	sw	a0,-60(s0)
    80005f9a:	08054163          	bltz	a0,8000601c <sys_pipe+0xbe>
    80005f9e:	fc843503          	ld	a0,-56(s0)
    80005fa2:	f32ff0ef          	jal	ra,800056d4 <fdalloc>
    80005fa6:	fca42023          	sw	a0,-64(s0)
    80005faa:	06054063          	bltz	a0,8000600a <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005fae:	4691                	li	a3,4
    80005fb0:	fc440613          	addi	a2,s0,-60
    80005fb4:	fd843583          	ld	a1,-40(s0)
    80005fb8:	68a8                	ld	a0,80(s1)
    80005fba:	92cfc0ef          	jal	ra,800020e6 <copyout>
    80005fbe:	00054e63          	bltz	a0,80005fda <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005fc2:	4691                	li	a3,4
    80005fc4:	fc040613          	addi	a2,s0,-64
    80005fc8:	fd843583          	ld	a1,-40(s0)
    80005fcc:	0591                	addi	a1,a1,4
    80005fce:	68a8                	ld	a0,80(s1)
    80005fd0:	916fc0ef          	jal	ra,800020e6 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005fd4:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005fd6:	04055c63          	bgez	a0,8000602e <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005fda:	fc442783          	lw	a5,-60(s0)
    80005fde:	07e9                	addi	a5,a5,26
    80005fe0:	078e                	slli	a5,a5,0x3
    80005fe2:	97a6                	add	a5,a5,s1
    80005fe4:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005fe8:	fc042503          	lw	a0,-64(s0)
    80005fec:	0569                	addi	a0,a0,26
    80005fee:	050e                	slli	a0,a0,0x3
    80005ff0:	94aa                	add	s1,s1,a0
    80005ff2:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005ff6:	fd043503          	ld	a0,-48(s0)
    80005ffa:	d49fe0ef          	jal	ra,80004d42 <fileclose>
    fileclose(wf);
    80005ffe:	fc843503          	ld	a0,-56(s0)
    80006002:	d41fe0ef          	jal	ra,80004d42 <fileclose>
    return -1;
    80006006:	57fd                	li	a5,-1
    80006008:	a01d                	j	8000602e <sys_pipe+0xd0>
    if(fd0 >= 0)
    8000600a:	fc442783          	lw	a5,-60(s0)
    8000600e:	0007c763          	bltz	a5,8000601c <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80006012:	07e9                	addi	a5,a5,26
    80006014:	078e                	slli	a5,a5,0x3
    80006016:	94be                	add	s1,s1,a5
    80006018:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000601c:	fd043503          	ld	a0,-48(s0)
    80006020:	d23fe0ef          	jal	ra,80004d42 <fileclose>
    fileclose(wf);
    80006024:	fc843503          	ld	a0,-56(s0)
    80006028:	d1bfe0ef          	jal	ra,80004d42 <fileclose>
    return -1;
    8000602c:	57fd                	li	a5,-1
}
    8000602e:	853e                	mv	a0,a5
    80006030:	70e2                	ld	ra,56(sp)
    80006032:	7442                	ld	s0,48(sp)
    80006034:	74a2                	ld	s1,40(sp)
    80006036:	6121                	addi	sp,sp,64
    80006038:	8082                	ret
    8000603a:	0000                	unimp
    8000603c:	0000                	unimp
	...

0000000080006040 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80006040:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80006042:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80006044:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80006046:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80006048:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000604a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000604c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000604e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80006050:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80006052:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80006054:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80006056:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80006058:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000605a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000605c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000605e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80006060:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80006062:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80006064:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80006066:	a4afd0ef          	jal	ra,800032b0 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000606a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000606c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000606e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80006070:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80006072:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80006074:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80006076:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80006078:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000607a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000607c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000607e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80006080:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80006082:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80006084:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80006086:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80006088:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000608a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000608c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000608e:	10200073          	sret
	...

000000008000609e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000609e:	1141                	addi	sp,sp,-16
    800060a0:	e422                	sd	s0,8(sp)
    800060a2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800060a4:	0c0007b7          	lui	a5,0xc000
    800060a8:	4705                	li	a4,1
    800060aa:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800060ac:	c3d8                	sw	a4,4(a5)
}
    800060ae:	6422                	ld	s0,8(sp)
    800060b0:	0141                	addi	sp,sp,16
    800060b2:	8082                	ret

00000000800060b4 <plicinithart>:

void
plicinithart(void)
{
    800060b4:	1141                	addi	sp,sp,-16
    800060b6:	e406                	sd	ra,8(sp)
    800060b8:	e022                	sd	s0,0(sp)
    800060ba:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800060bc:	ae0fc0ef          	jal	ra,8000239c <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800060c0:	0085171b          	slliw	a4,a0,0x8
    800060c4:	0c0027b7          	lui	a5,0xc002
    800060c8:	97ba                	add	a5,a5,a4
    800060ca:	40200713          	li	a4,1026
    800060ce:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800060d2:	00d5151b          	slliw	a0,a0,0xd
    800060d6:	0c2017b7          	lui	a5,0xc201
    800060da:	953e                	add	a0,a0,a5
    800060dc:	00052023          	sw	zero,0(a0)
}
    800060e0:	60a2                	ld	ra,8(sp)
    800060e2:	6402                	ld	s0,0(sp)
    800060e4:	0141                	addi	sp,sp,16
    800060e6:	8082                	ret

00000000800060e8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800060e8:	1141                	addi	sp,sp,-16
    800060ea:	e406                	sd	ra,8(sp)
    800060ec:	e022                	sd	s0,0(sp)
    800060ee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800060f0:	aacfc0ef          	jal	ra,8000239c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800060f4:	00d5179b          	slliw	a5,a0,0xd
    800060f8:	0c201537          	lui	a0,0xc201
    800060fc:	953e                	add	a0,a0,a5
  return irq;
}
    800060fe:	4148                	lw	a0,4(a0)
    80006100:	60a2                	ld	ra,8(sp)
    80006102:	6402                	ld	s0,0(sp)
    80006104:	0141                	addi	sp,sp,16
    80006106:	8082                	ret

0000000080006108 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006108:	1101                	addi	sp,sp,-32
    8000610a:	ec06                	sd	ra,24(sp)
    8000610c:	e822                	sd	s0,16(sp)
    8000610e:	e426                	sd	s1,8(sp)
    80006110:	1000                	addi	s0,sp,32
    80006112:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006114:	a88fc0ef          	jal	ra,8000239c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006118:	00d5151b          	slliw	a0,a0,0xd
    8000611c:	0c2017b7          	lui	a5,0xc201
    80006120:	97aa                	add	a5,a5,a0
    80006122:	c3c4                	sw	s1,4(a5)
}
    80006124:	60e2                	ld	ra,24(sp)
    80006126:	6442                	ld	s0,16(sp)
    80006128:	64a2                	ld	s1,8(sp)
    8000612a:	6105                	addi	sp,sp,32
    8000612c:	8082                	ret

000000008000612e <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000612e:	1141                	addi	sp,sp,-16
    80006130:	e406                	sd	ra,8(sp)
    80006132:	e022                	sd	s0,0(sp)
    80006134:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006136:	479d                	li	a5,7
    80006138:	04a7ca63          	blt	a5,a0,8000618c <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    8000613c:	00086797          	auipc	a5,0x86
    80006140:	fac78793          	addi	a5,a5,-84 # 8008c0e8 <disk>
    80006144:	97aa                	add	a5,a5,a0
    80006146:	0187c783          	lbu	a5,24(a5)
    8000614a:	e7b9                	bnez	a5,80006198 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000614c:	00451613          	slli	a2,a0,0x4
    80006150:	00086797          	auipc	a5,0x86
    80006154:	f9878793          	addi	a5,a5,-104 # 8008c0e8 <disk>
    80006158:	6394                	ld	a3,0(a5)
    8000615a:	96b2                	add	a3,a3,a2
    8000615c:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006160:	6398                	ld	a4,0(a5)
    80006162:	9732                	add	a4,a4,a2
    80006164:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006168:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    8000616c:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006170:	953e                	add	a0,a0,a5
    80006172:	4785                	li	a5,1
    80006174:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006178:	00086517          	auipc	a0,0x86
    8000617c:	f8850513          	addi	a0,a0,-120 # 8008c100 <disk+0x18>
    80006180:	937fc0ef          	jal	ra,80002ab6 <wakeup>
}
    80006184:	60a2                	ld	ra,8(sp)
    80006186:	6402                	ld	s0,0(sp)
    80006188:	0141                	addi	sp,sp,16
    8000618a:	8082                	ret
    panic("free_desc 1");
    8000618c:	00003517          	auipc	a0,0x3
    80006190:	a4c50513          	addi	a0,a0,-1460 # 80008bd8 <syscalls+0x3d8>
    80006194:	df6fa0ef          	jal	ra,8000078a <panic>
    panic("free_desc 2");
    80006198:	00003517          	auipc	a0,0x3
    8000619c:	a5050513          	addi	a0,a0,-1456 # 80008be8 <syscalls+0x3e8>
    800061a0:	deafa0ef          	jal	ra,8000078a <panic>

00000000800061a4 <virtio_disk_init>:
{
    800061a4:	1101                	addi	sp,sp,-32
    800061a6:	ec06                	sd	ra,24(sp)
    800061a8:	e822                	sd	s0,16(sp)
    800061aa:	e426                	sd	s1,8(sp)
    800061ac:	e04a                	sd	s2,0(sp)
    800061ae:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800061b0:	00003597          	auipc	a1,0x3
    800061b4:	a4858593          	addi	a1,a1,-1464 # 80008bf8 <syscalls+0x3f8>
    800061b8:	00086517          	auipc	a0,0x86
    800061bc:	05850513          	addi	a0,a0,88 # 8008c210 <disk+0x128>
    800061c0:	92dfa0ef          	jal	ra,80000aec <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800061c4:	100017b7          	lui	a5,0x10001
    800061c8:	4398                	lw	a4,0(a5)
    800061ca:	2701                	sext.w	a4,a4
    800061cc:	747277b7          	lui	a5,0x74727
    800061d0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800061d4:	14f71063          	bne	a4,a5,80006314 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800061d8:	100017b7          	lui	a5,0x10001
    800061dc:	43dc                	lw	a5,4(a5)
    800061de:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800061e0:	4709                	li	a4,2
    800061e2:	12e79963          	bne	a5,a4,80006314 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061e6:	100017b7          	lui	a5,0x10001
    800061ea:	479c                	lw	a5,8(a5)
    800061ec:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800061ee:	12e79363          	bne	a5,a4,80006314 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800061f2:	100017b7          	lui	a5,0x10001
    800061f6:	47d8                	lw	a4,12(a5)
    800061f8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061fa:	554d47b7          	lui	a5,0x554d4
    800061fe:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006202:	10f71963          	bne	a4,a5,80006314 <virtio_disk_init+0x170>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006206:	100017b7          	lui	a5,0x10001
    8000620a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000620e:	4705                	li	a4,1
    80006210:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006212:	470d                	li	a4,3
    80006214:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006216:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006218:	c7ffe737          	lui	a4,0xc7ffe
    8000621c:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47f72537>
    80006220:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006222:	2701                	sext.w	a4,a4
    80006224:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006226:	472d                	li	a4,11
    80006228:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    8000622a:	5bbc                	lw	a5,112(a5)
    8000622c:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006230:	8ba1                	andi	a5,a5,8
    80006232:	0e078763          	beqz	a5,80006320 <virtio_disk_init+0x17c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006236:	100017b7          	lui	a5,0x10001
    8000623a:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000623e:	43fc                	lw	a5,68(a5)
    80006240:	2781                	sext.w	a5,a5
    80006242:	0e079563          	bnez	a5,8000632c <virtio_disk_init+0x188>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006246:	100017b7          	lui	a5,0x10001
    8000624a:	5bdc                	lw	a5,52(a5)
    8000624c:	2781                	sext.w	a5,a5
  if(max == 0)
    8000624e:	0e078563          	beqz	a5,80006338 <virtio_disk_init+0x194>
  if(max < NUM)
    80006252:	471d                	li	a4,7
    80006254:	0ef77863          	bgeu	a4,a5,80006344 <virtio_disk_init+0x1a0>
  disk.desc = kalloc();
    80006258:	845fa0ef          	jal	ra,80000a9c <kalloc>
    8000625c:	00086497          	auipc	s1,0x86
    80006260:	e8c48493          	addi	s1,s1,-372 # 8008c0e8 <disk>
    80006264:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006266:	837fa0ef          	jal	ra,80000a9c <kalloc>
    8000626a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000626c:	831fa0ef          	jal	ra,80000a9c <kalloc>
    80006270:	87aa                	mv	a5,a0
    80006272:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006274:	6088                	ld	a0,0(s1)
    80006276:	cd69                	beqz	a0,80006350 <virtio_disk_init+0x1ac>
    80006278:	00086717          	auipc	a4,0x86
    8000627c:	e7873703          	ld	a4,-392(a4) # 8008c0f0 <disk+0x8>
    80006280:	cb61                	beqz	a4,80006350 <virtio_disk_init+0x1ac>
    80006282:	c7f9                	beqz	a5,80006350 <virtio_disk_init+0x1ac>
  memset(disk.desc, 0, PGSIZE);
    80006284:	6605                	lui	a2,0x1
    80006286:	4581                	li	a1,0
    80006288:	9b9fa0ef          	jal	ra,80000c40 <memset>
  memset(disk.avail, 0, PGSIZE);
    8000628c:	00086497          	auipc	s1,0x86
    80006290:	e5c48493          	addi	s1,s1,-420 # 8008c0e8 <disk>
    80006294:	6605                	lui	a2,0x1
    80006296:	4581                	li	a1,0
    80006298:	6488                	ld	a0,8(s1)
    8000629a:	9a7fa0ef          	jal	ra,80000c40 <memset>
  memset(disk.used, 0, PGSIZE);
    8000629e:	6605                	lui	a2,0x1
    800062a0:	4581                	li	a1,0
    800062a2:	6888                	ld	a0,16(s1)
    800062a4:	99dfa0ef          	jal	ra,80000c40 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800062a8:	100017b7          	lui	a5,0x10001
    800062ac:	4721                	li	a4,8
    800062ae:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800062b0:	4098                	lw	a4,0(s1)
    800062b2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800062b6:	40d8                	lw	a4,4(s1)
    800062b8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800062bc:	6498                	ld	a4,8(s1)
    800062be:	0007069b          	sext.w	a3,a4
    800062c2:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800062c6:	9701                	srai	a4,a4,0x20
    800062c8:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800062cc:	6898                	ld	a4,16(s1)
    800062ce:	0007069b          	sext.w	a3,a4
    800062d2:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800062d6:	9701                	srai	a4,a4,0x20
    800062d8:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800062dc:	4705                	li	a4,1
    800062de:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800062e0:	00e48c23          	sb	a4,24(s1)
    800062e4:	00e48ca3          	sb	a4,25(s1)
    800062e8:	00e48d23          	sb	a4,26(s1)
    800062ec:	00e48da3          	sb	a4,27(s1)
    800062f0:	00e48e23          	sb	a4,28(s1)
    800062f4:	00e48ea3          	sb	a4,29(s1)
    800062f8:	00e48f23          	sb	a4,30(s1)
    800062fc:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006300:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006304:	0727a823          	sw	s2,112(a5)
}
    80006308:	60e2                	ld	ra,24(sp)
    8000630a:	6442                	ld	s0,16(sp)
    8000630c:	64a2                	ld	s1,8(sp)
    8000630e:	6902                	ld	s2,0(sp)
    80006310:	6105                	addi	sp,sp,32
    80006312:	8082                	ret
    panic("could not find virtio disk");
    80006314:	00003517          	auipc	a0,0x3
    80006318:	8f450513          	addi	a0,a0,-1804 # 80008c08 <syscalls+0x408>
    8000631c:	c6efa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk FEATURES_OK unset");
    80006320:	00003517          	auipc	a0,0x3
    80006324:	90850513          	addi	a0,a0,-1784 # 80008c28 <syscalls+0x428>
    80006328:	c62fa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk should not be ready");
    8000632c:	00003517          	auipc	a0,0x3
    80006330:	91c50513          	addi	a0,a0,-1764 # 80008c48 <syscalls+0x448>
    80006334:	c56fa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk has no queue 0");
    80006338:	00003517          	auipc	a0,0x3
    8000633c:	93050513          	addi	a0,a0,-1744 # 80008c68 <syscalls+0x468>
    80006340:	c4afa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk max queue too short");
    80006344:	00003517          	auipc	a0,0x3
    80006348:	94450513          	addi	a0,a0,-1724 # 80008c88 <syscalls+0x488>
    8000634c:	c3efa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk kalloc");
    80006350:	00003517          	auipc	a0,0x3
    80006354:	95850513          	addi	a0,a0,-1704 # 80008ca8 <syscalls+0x4a8>
    80006358:	c32fa0ef          	jal	ra,8000078a <panic>

000000008000635c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000635c:	7119                	addi	sp,sp,-128
    8000635e:	fc86                	sd	ra,120(sp)
    80006360:	f8a2                	sd	s0,112(sp)
    80006362:	f4a6                	sd	s1,104(sp)
    80006364:	f0ca                	sd	s2,96(sp)
    80006366:	ecce                	sd	s3,88(sp)
    80006368:	e8d2                	sd	s4,80(sp)
    8000636a:	e4d6                	sd	s5,72(sp)
    8000636c:	e0da                	sd	s6,64(sp)
    8000636e:	fc5e                	sd	s7,56(sp)
    80006370:	f862                	sd	s8,48(sp)
    80006372:	f466                	sd	s9,40(sp)
    80006374:	f06a                	sd	s10,32(sp)
    80006376:	ec6e                	sd	s11,24(sp)
    80006378:	0100                	addi	s0,sp,128
    8000637a:	8aaa                	mv	s5,a0
    8000637c:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000637e:	00c52d03          	lw	s10,12(a0)
    80006382:	001d1d1b          	slliw	s10,s10,0x1
    80006386:	1d02                	slli	s10,s10,0x20
    80006388:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    8000638c:	00086517          	auipc	a0,0x86
    80006390:	e8450513          	addi	a0,a0,-380 # 8008c210 <disk+0x128>
    80006394:	fd8fa0ef          	jal	ra,80000b6c <acquire>
  for(int i = 0; i < 3; i++){
    80006398:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000639a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000639c:	00086b97          	auipc	s7,0x86
    800063a0:	d4cb8b93          	addi	s7,s7,-692 # 8008c0e8 <disk>
  for(int i = 0; i < 3; i++){
    800063a4:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800063a6:	00086c97          	auipc	s9,0x86
    800063aa:	e6ac8c93          	addi	s9,s9,-406 # 8008c210 <disk+0x128>
    800063ae:	a8a9                	j	80006408 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800063b0:	00fb8733          	add	a4,s7,a5
    800063b4:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800063b8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800063ba:	0207c563          	bltz	a5,800063e4 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800063be:	2905                	addiw	s2,s2,1
    800063c0:	0611                	addi	a2,a2,4
    800063c2:	05690863          	beq	s2,s6,80006412 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    800063c6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800063c8:	00086717          	auipc	a4,0x86
    800063cc:	d2070713          	addi	a4,a4,-736 # 8008c0e8 <disk>
    800063d0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800063d2:	01874683          	lbu	a3,24(a4)
    800063d6:	fee9                	bnez	a3,800063b0 <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    800063d8:	2785                	addiw	a5,a5,1
    800063da:	0705                	addi	a4,a4,1
    800063dc:	fe979be3          	bne	a5,s1,800063d2 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800063e0:	57fd                	li	a5,-1
    800063e2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800063e4:	01205b63          	blez	s2,800063fa <virtio_disk_rw+0x9e>
    800063e8:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800063ea:	000a2503          	lw	a0,0(s4)
    800063ee:	d41ff0ef          	jal	ra,8000612e <free_desc>
      for(int j = 0; j < i; j++)
    800063f2:	2d85                	addiw	s11,s11,1
    800063f4:	0a11                	addi	s4,s4,4
    800063f6:	ffb91ae3          	bne	s2,s11,800063ea <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800063fa:	85e6                	mv	a1,s9
    800063fc:	00086517          	auipc	a0,0x86
    80006400:	d0450513          	addi	a0,a0,-764 # 8008c100 <disk+0x18>
    80006404:	e66fc0ef          	jal	ra,80002a6a <sleep>
  for(int i = 0; i < 3; i++){
    80006408:	f8040a13          	addi	s4,s0,-128
{
    8000640c:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    8000640e:	894e                	mv	s2,s3
    80006410:	bf5d                	j	800063c6 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006412:	f8042583          	lw	a1,-128(s0)
    80006416:	00a58793          	addi	a5,a1,10
    8000641a:	0792                	slli	a5,a5,0x4

  if(write)
    8000641c:	00086617          	auipc	a2,0x86
    80006420:	ccc60613          	addi	a2,a2,-820 # 8008c0e8 <disk>
    80006424:	00f60733          	add	a4,a2,a5
    80006428:	018036b3          	snez	a3,s8
    8000642c:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000642e:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006432:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006436:	f6078693          	addi	a3,a5,-160
    8000643a:	6218                	ld	a4,0(a2)
    8000643c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000643e:	00878513          	addi	a0,a5,8
    80006442:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006444:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006446:	6208                	ld	a0,0(a2)
    80006448:	96aa                	add	a3,a3,a0
    8000644a:	4741                	li	a4,16
    8000644c:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000644e:	4705                	li	a4,1
    80006450:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006454:	f8442703          	lw	a4,-124(s0)
    80006458:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000645c:	0712                	slli	a4,a4,0x4
    8000645e:	953a                	add	a0,a0,a4
    80006460:	058a8693          	addi	a3,s5,88
    80006464:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    80006466:	6208                	ld	a0,0(a2)
    80006468:	972a                	add	a4,a4,a0
    8000646a:	40000693          	li	a3,1024
    8000646e:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006470:	001c3c13          	seqz	s8,s8
    80006474:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006476:	001c6c13          	ori	s8,s8,1
    8000647a:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    8000647e:	f8842603          	lw	a2,-120(s0)
    80006482:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006486:	00086697          	auipc	a3,0x86
    8000648a:	c6268693          	addi	a3,a3,-926 # 8008c0e8 <disk>
    8000648e:	00258713          	addi	a4,a1,2
    80006492:	0712                	slli	a4,a4,0x4
    80006494:	9736                	add	a4,a4,a3
    80006496:	587d                	li	a6,-1
    80006498:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000649c:	0612                	slli	a2,a2,0x4
    8000649e:	9532                	add	a0,a0,a2
    800064a0:	f9078793          	addi	a5,a5,-112
    800064a4:	97b6                	add	a5,a5,a3
    800064a6:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    800064a8:	629c                	ld	a5,0(a3)
    800064aa:	97b2                	add	a5,a5,a2
    800064ac:	4605                	li	a2,1
    800064ae:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800064b0:	4509                	li	a0,2
    800064b2:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    800064b6:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800064ba:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800064be:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800064c2:	6698                	ld	a4,8(a3)
    800064c4:	00275783          	lhu	a5,2(a4)
    800064c8:	8b9d                	andi	a5,a5,7
    800064ca:	0786                	slli	a5,a5,0x1
    800064cc:	97ba                	add	a5,a5,a4
    800064ce:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800064d2:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800064d6:	6698                	ld	a4,8(a3)
    800064d8:	00275783          	lhu	a5,2(a4)
    800064dc:	2785                	addiw	a5,a5,1
    800064de:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800064e2:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800064e6:	100017b7          	lui	a5,0x10001
    800064ea:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800064ee:	004aa783          	lw	a5,4(s5)
    800064f2:	00c79f63          	bne	a5,a2,80006510 <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    800064f6:	00086917          	auipc	s2,0x86
    800064fa:	d1a90913          	addi	s2,s2,-742 # 8008c210 <disk+0x128>
  while(b->disk == 1) {
    800064fe:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006500:	85ca                	mv	a1,s2
    80006502:	8556                	mv	a0,s5
    80006504:	d66fc0ef          	jal	ra,80002a6a <sleep>
  while(b->disk == 1) {
    80006508:	004aa783          	lw	a5,4(s5)
    8000650c:	fe978ae3          	beq	a5,s1,80006500 <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    80006510:	f8042903          	lw	s2,-128(s0)
    80006514:	00290793          	addi	a5,s2,2
    80006518:	00479713          	slli	a4,a5,0x4
    8000651c:	00086797          	auipc	a5,0x86
    80006520:	bcc78793          	addi	a5,a5,-1076 # 8008c0e8 <disk>
    80006524:	97ba                	add	a5,a5,a4
    80006526:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000652a:	00086997          	auipc	s3,0x86
    8000652e:	bbe98993          	addi	s3,s3,-1090 # 8008c0e8 <disk>
    80006532:	00491713          	slli	a4,s2,0x4
    80006536:	0009b783          	ld	a5,0(s3)
    8000653a:	97ba                	add	a5,a5,a4
    8000653c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006540:	854a                	mv	a0,s2
    80006542:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006546:	be9ff0ef          	jal	ra,8000612e <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000654a:	8885                	andi	s1,s1,1
    8000654c:	f0fd                	bnez	s1,80006532 <virtio_disk_rw+0x1d6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000654e:	00086517          	auipc	a0,0x86
    80006552:	cc250513          	addi	a0,a0,-830 # 8008c210 <disk+0x128>
    80006556:	eaefa0ef          	jal	ra,80000c04 <release>
}
    8000655a:	70e6                	ld	ra,120(sp)
    8000655c:	7446                	ld	s0,112(sp)
    8000655e:	74a6                	ld	s1,104(sp)
    80006560:	7906                	ld	s2,96(sp)
    80006562:	69e6                	ld	s3,88(sp)
    80006564:	6a46                	ld	s4,80(sp)
    80006566:	6aa6                	ld	s5,72(sp)
    80006568:	6b06                	ld	s6,64(sp)
    8000656a:	7be2                	ld	s7,56(sp)
    8000656c:	7c42                	ld	s8,48(sp)
    8000656e:	7ca2                	ld	s9,40(sp)
    80006570:	7d02                	ld	s10,32(sp)
    80006572:	6de2                	ld	s11,24(sp)
    80006574:	6109                	addi	sp,sp,128
    80006576:	8082                	ret

0000000080006578 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006578:	1101                	addi	sp,sp,-32
    8000657a:	ec06                	sd	ra,24(sp)
    8000657c:	e822                	sd	s0,16(sp)
    8000657e:	e426                	sd	s1,8(sp)
    80006580:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006582:	00086497          	auipc	s1,0x86
    80006586:	b6648493          	addi	s1,s1,-1178 # 8008c0e8 <disk>
    8000658a:	00086517          	auipc	a0,0x86
    8000658e:	c8650513          	addi	a0,a0,-890 # 8008c210 <disk+0x128>
    80006592:	ddafa0ef          	jal	ra,80000b6c <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006596:	10001737          	lui	a4,0x10001
    8000659a:	533c                	lw	a5,96(a4)
    8000659c:	8b8d                	andi	a5,a5,3
    8000659e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800065a0:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800065a4:	689c                	ld	a5,16(s1)
    800065a6:	0204d703          	lhu	a4,32(s1)
    800065aa:	0027d783          	lhu	a5,2(a5)
    800065ae:	04f70663          	beq	a4,a5,800065fa <virtio_disk_intr+0x82>
    __sync_synchronize();
    800065b2:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800065b6:	6898                	ld	a4,16(s1)
    800065b8:	0204d783          	lhu	a5,32(s1)
    800065bc:	8b9d                	andi	a5,a5,7
    800065be:	078e                	slli	a5,a5,0x3
    800065c0:	97ba                	add	a5,a5,a4
    800065c2:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800065c4:	00278713          	addi	a4,a5,2
    800065c8:	0712                	slli	a4,a4,0x4
    800065ca:	9726                	add	a4,a4,s1
    800065cc:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800065d0:	e321                	bnez	a4,80006610 <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800065d2:	0789                	addi	a5,a5,2
    800065d4:	0792                	slli	a5,a5,0x4
    800065d6:	97a6                	add	a5,a5,s1
    800065d8:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800065da:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800065de:	cd8fc0ef          	jal	ra,80002ab6 <wakeup>

    disk.used_idx += 1;
    800065e2:	0204d783          	lhu	a5,32(s1)
    800065e6:	2785                	addiw	a5,a5,1
    800065e8:	17c2                	slli	a5,a5,0x30
    800065ea:	93c1                	srli	a5,a5,0x30
    800065ec:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800065f0:	6898                	ld	a4,16(s1)
    800065f2:	00275703          	lhu	a4,2(a4)
    800065f6:	faf71ee3          	bne	a4,a5,800065b2 <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    800065fa:	00086517          	auipc	a0,0x86
    800065fe:	c1650513          	addi	a0,a0,-1002 # 8008c210 <disk+0x128>
    80006602:	e02fa0ef          	jal	ra,80000c04 <release>
}
    80006606:	60e2                	ld	ra,24(sp)
    80006608:	6442                	ld	s0,16(sp)
    8000660a:	64a2                	ld	s1,8(sp)
    8000660c:	6105                	addi	sp,sp,32
    8000660e:	8082                	ret
      panic("virtio_disk_intr status");
    80006610:	00002517          	auipc	a0,0x2
    80006614:	6b050513          	addi	a0,a0,1712 # 80008cc0 <syscalls+0x4c0>
    80006618:	972fa0ef          	jal	ra,8000078a <panic>
	...

0000000080007000 <_trampoline>:
        # user page table.
        #

        # save user a0 in sscratch so
        # a0 can be used to get at TRAPFRAME.
        csrw sscratch, a0
    80007000:	14051073          	csrw	sscratch,a0

        # each process has a separate p->trapframe memory area,
        # but it's mapped to the same virtual address
        # (TRAPFRAME) in every process's user page table.
        li a0, TRAPFRAME
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
        
        # save the user registers in TRAPFRAME
        sd ra, 40(a0)
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
        sd sp, 48(a0)
    80007010:	02253823          	sd	sp,48(a0)
        sd gp, 56(a0)
    80007014:	02353c23          	sd	gp,56(a0)
        sd tp, 64(a0)
    80007018:	04453023          	sd	tp,64(a0)
        sd t0, 72(a0)
    8000701c:	04553423          	sd	t0,72(a0)
        sd t1, 80(a0)
    80007020:	04653823          	sd	t1,80(a0)
        sd t2, 88(a0)
    80007024:	04753c23          	sd	t2,88(a0)
        sd s0, 96(a0)
    80007028:	f120                	sd	s0,96(a0)
        sd s1, 104(a0)
    8000702a:	f524                	sd	s1,104(a0)
        sd a1, 120(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
        sd a2, 128(a0)
    8000702e:	e150                	sd	a2,128(a0)
        sd a3, 136(a0)
    80007030:	e554                	sd	a3,136(a0)
        sd a4, 144(a0)
    80007032:	e958                	sd	a4,144(a0)
        sd a5, 152(a0)
    80007034:	ed5c                	sd	a5,152(a0)
        sd a6, 160(a0)
    80007036:	0b053023          	sd	a6,160(a0)
        sd a7, 168(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
        sd s2, 176(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
        sd s3, 184(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
        sd s4, 192(a0)
    80007046:	0d453023          	sd	s4,192(a0)
        sd s5, 200(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
        sd s6, 208(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
        sd s7, 216(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
        sd s8, 224(a0)
    80007056:	0f853023          	sd	s8,224(a0)
        sd s9, 232(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
        sd s10, 240(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
        sd s11, 248(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
        sd t3, 256(a0)
    80007066:	11c53023          	sd	t3,256(a0)
        sd t4, 264(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
        sd t5, 272(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
        sd t6, 280(a0)
    80007072:	11f53c23          	sd	t6,280(a0)

	# save the user a0 in p->trapframe->a0
        csrr t0, sscratch
    80007076:	140022f3          	csrr	t0,sscratch
        sd t0, 112(a0)
    8000707a:	06553823          	sd	t0,112(a0)

        # initialize kernel stack pointer, from p->trapframe->kernel_sp
        ld sp, 8(a0)
    8000707e:	00853103          	ld	sp,8(a0)

        # make tp hold the current hartid, from p->trapframe->kernel_hartid
        ld tp, 32(a0)
    80007082:	02053203          	ld	tp,32(a0)

        # load the address of usertrap(), from p->trapframe->kernel_trap
        ld t0, 16(a0)
    80007086:	01053283          	ld	t0,16(a0)

        # fetch the kernel page table address, from p->trapframe->kernel_satp.
        ld t1, 0(a0)
    8000708a:	00053303          	ld	t1,0(a0)

        # wait for any previous memory operations to complete, so that
        # they use the user page table.
        sfence.vma zero, zero
    8000708e:	12000073          	sfence.vma

        # install the kernel page table.
        csrw satp, t1
    80007092:	18031073          	csrw	satp,t1

        # flush now-stale user entries from the TLB.
        sfence.vma zero, zero
    80007096:	12000073          	sfence.vma

        # call usertrap()
        jalr t0
    8000709a:	9282                	jalr	t0

000000008000709c <userret>:
userret:
        # usertrap() returns here, with user satp in a0.
        # return from kernel to user.

        # switch to the user page table.
        sfence.vma zero, zero
    8000709c:	12000073          	sfence.vma
        csrw satp, a0
    800070a0:	18051073          	csrw	satp,a0
        sfence.vma zero, zero
    800070a4:	12000073          	sfence.vma

        li a0, TRAPFRAME
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd

        # restore all but a0 from TRAPFRAME
        ld ra, 40(a0)
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
        ld sp, 48(a0)
    800070b4:	03053103          	ld	sp,48(a0)
        ld gp, 56(a0)
    800070b8:	03853183          	ld	gp,56(a0)
        ld tp, 64(a0)
    800070bc:	04053203          	ld	tp,64(a0)
        ld t0, 72(a0)
    800070c0:	04853283          	ld	t0,72(a0)
        ld t1, 80(a0)
    800070c4:	05053303          	ld	t1,80(a0)
        ld t2, 88(a0)
    800070c8:	05853383          	ld	t2,88(a0)
        ld s0, 96(a0)
    800070cc:	7120                	ld	s0,96(a0)
        ld s1, 104(a0)
    800070ce:	7524                	ld	s1,104(a0)
        ld a1, 120(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
        ld a2, 128(a0)
    800070d2:	6150                	ld	a2,128(a0)
        ld a3, 136(a0)
    800070d4:	6554                	ld	a3,136(a0)
        ld a4, 144(a0)
    800070d6:	6958                	ld	a4,144(a0)
        ld a5, 152(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
        ld a6, 160(a0)
    800070da:	0a053803          	ld	a6,160(a0)
        ld a7, 168(a0)
    800070de:	0a853883          	ld	a7,168(a0)
        ld s2, 176(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
        ld s3, 184(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
        ld s4, 192(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
        ld s5, 200(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
        ld s6, 208(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
        ld s7, 216(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
        ld s8, 224(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
        ld s9, 232(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
        ld s10, 240(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
        ld s11, 248(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
        ld t3, 256(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
        ld t4, 264(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
        ld t5, 272(a0)
    80007112:	11053f03          	ld	t5,272(a0)
        ld t6, 280(a0)
    80007116:	11853f83          	ld	t6,280(a0)

	# restore user a0
        ld a0, 112(a0)
    8000711a:	7928                	ld	a0,112(a0)
        
        # return to user mode and user pc.
        # usertrapret() set up sstatus and sepc.
        sret
    8000711c:	10200073          	sret
	...
