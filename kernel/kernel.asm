
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
    80000004:	bd010113          	addi	sp,sp,-1072 # 80007bd0 <stack0>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffcc127>
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
    8000010a:	698020ef          	jal	ra,800027a2 <either_copyin>
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
    80000176:	a5e50513          	addi	a0,a0,-1442 # 8000fbd0 <cons>
    8000017a:	1f3000ef          	jal	ra,80000b6c <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000017e:	00010497          	auipc	s1,0x10
    80000182:	a5248493          	addi	s1,s1,-1454 # 8000fbd0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000186:	00010917          	auipc	s2,0x10
    8000018a:	ae290913          	addi	s2,s2,-1310 # 8000fc68 <cons+0x98>
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
    800001a4:	437010ef          	jal	ra,80001dda <myproc>
    800001a8:	48c020ef          	jal	ra,80002634 <killed>
    800001ac:	e125                	bnez	a0,8000020c <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800001ae:	85a6                	mv	a1,s1
    800001b0:	854a                	mv	a0,s2
    800001b2:	24a020ef          	jal	ra,800023fc <sleep>
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
    800001ea:	56e020ef          	jal	ra,80002758 <either_copyout>
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
    800001fe:	9d650513          	addi	a0,a0,-1578 # 8000fbd0 <cons>
    80000202:	203000ef          	jal	ra,80000c04 <release>

  return target - n;
    80000206:	413b053b          	subw	a0,s6,s3
    8000020a:	a801                	j	8000021a <consoleread+0xce>
        release(&cons.lock);
    8000020c:	00010517          	auipc	a0,0x10
    80000210:	9c450513          	addi	a0,a0,-1596 # 8000fbd0 <cons>
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
    80000242:	a2f72523          	sw	a5,-1494(a4) # 8000fc68 <cons+0x98>
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
    8000028c:	94850513          	addi	a0,a0,-1720 # 8000fbd0 <cons>
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
    800002aa:	542020ef          	jal	ra,800027ec <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ae:	00010517          	auipc	a0,0x10
    800002b2:	92250513          	addi	a0,a0,-1758 # 8000fbd0 <cons>
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
    800002d2:	90270713          	addi	a4,a4,-1790 # 8000fbd0 <cons>
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
    800002f8:	8dc78793          	addi	a5,a5,-1828 # 8000fbd0 <cons>
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
    80000326:	9467a783          	lw	a5,-1722(a5) # 8000fc68 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f6f71fe3          	bne	a4,a5,800002ae <consoleintr+0x34>
    80000334:	a04d                	j	800003d6 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80000336:	00010717          	auipc	a4,0x10
    8000033a:	89a70713          	addi	a4,a4,-1894 # 8000fbd0 <cons>
    8000033e:	0a072783          	lw	a5,160(a4)
    80000342:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000346:	00010497          	auipc	s1,0x10
    8000034a:	88a48493          	addi	s1,s1,-1910 # 8000fbd0 <cons>
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
    80000382:	85270713          	addi	a4,a4,-1966 # 8000fbd0 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f2f700e3          	beq	a4,a5,800002ae <consoleintr+0x34>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	00010717          	auipc	a4,0x10
    80000398:	8cf72e23          	sw	a5,-1828(a4) # 8000fc70 <cons+0xa0>
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
    800003b6:	81e78793          	addi	a5,a5,-2018 # 8000fbd0 <cons>
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
    800003da:	88c7ab23          	sw	a2,-1898(a5) # 8000fc6c <cons+0x9c>
        wakeup(&cons.r);
    800003de:	00010517          	auipc	a0,0x10
    800003e2:	88a50513          	addi	a0,a0,-1910 # 8000fc68 <cons+0x98>
    800003e6:	062020ef          	jal	ra,80002448 <wakeup>
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
    80000400:	7d450513          	addi	a0,a0,2004 # 8000fbd0 <cons>
    80000404:	6e8000ef          	jal	ra,80000aec <initlock>

  uartinit();
    80000408:	3e2000ef          	jal	ra,800007ea <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	00031797          	auipc	a5,0x31
    80000410:	13478793          	addi	a5,a5,308 # 80031540 <devsw>
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
    800004fa:	6ae7a783          	lw	a5,1710(a5) # 80007ba4 <panicking>
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
    80000538:	74450513          	addi	a0,a0,1860 # 8000fc78 <pr>
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
    80000756:	4527a783          	lw	a5,1106(a5) # 80007ba4 <panicking>
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
    80000780:	4fc50513          	addi	a0,a0,1276 # 8000fc78 <pr>
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
    8000079e:	4127a523          	sw	s2,1034(a5) # 80007ba4 <panicking>
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
    800007c0:	3f27a223          	sw	s2,996(a5) # 80007ba0 <panicked>
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
    800007da:	4a250513          	addi	a0,a0,1186 # 8000fc78 <pr>
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
    80000826:	46e50513          	addi	a0,a0,1134 # 8000fc90 <tx_lock>
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
    80000854:	44050513          	addi	a0,a0,1088 # 8000fc90 <tx_lock>
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
    80000872:	33e48493          	addi	s1,s1,830 # 80007bac <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000876:	0000f997          	auipc	s3,0xf
    8000087a:	41a98993          	addi	s3,s3,1050 # 8000fc90 <tx_lock>
    8000087e:	00007917          	auipc	s2,0x7
    80000882:	32a90913          	addi	s2,s2,810 # 80007ba8 <tx_chan>
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
    80000892:	36b010ef          	jal	ra,800023fc <sleep>
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
    800008b6:	3de50513          	addi	a0,a0,990 # 8000fc90 <tx_lock>
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
    800008e4:	2c47a783          	lw	a5,708(a5) # 80007ba4 <panicking>
    800008e8:	cb89                	beqz	a5,800008fa <uartputc_sync+0x26>
    push_off();

  if(panicked){
    800008ea:	00007797          	auipc	a5,0x7
    800008ee:	2b67a783          	lw	a5,694(a5) # 80007ba0 <panicked>
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
    8000091a:	28e7a783          	lw	a5,654(a5) # 80007ba4 <panicking>
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
    8000096e:	32650513          	addi	a0,a0,806 # 8000fc90 <tx_lock>
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
    80000984:	31050513          	addi	a0,a0,784 # 8000fc90 <tx_lock>
    80000988:	27c000ef          	jal	ra,80000c04 <release>

  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000098c:	54fd                	li	s1,-1
    8000098e:	a831                	j	800009aa <uartintr+0x52>
    tx_busy = 0;
    80000990:	00007797          	auipc	a5,0x7
    80000994:	2007ae23          	sw	zero,540(a5) # 80007bac <tx_busy>
    wakeup(&tx_chan);
    80000998:	00007517          	auipc	a0,0x7
    8000099c:	21050513          	addi	a0,a0,528 # 80007ba8 <tx_chan>
    800009a0:	2a9010ef          	jal	ra,80002448 <wakeup>
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
    800009d0:	00032797          	auipc	a5,0x32
    800009d4:	d0878793          	addi	a5,a5,-760 # 800326d8 <end>
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
    800009f0:	2bc90913          	addi	s2,s2,700 # 8000fca8 <kmem>
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
    80000a7c:	23050513          	addi	a0,a0,560 # 8000fca8 <kmem>
    80000a80:	06c000ef          	jal	ra,80000aec <initlock>
  freerange(end, (void*)PHYSTOP);
    80000a84:	45c5                	li	a1,17
    80000a86:	05ee                	slli	a1,a1,0x1b
    80000a88:	00032517          	auipc	a0,0x32
    80000a8c:	c5050513          	addi	a0,a0,-944 # 800326d8 <end>
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
    80000aaa:	20248493          	addi	s1,s1,514 # 8000fca8 <kmem>
    80000aae:	8526                	mv	a0,s1
    80000ab0:	0bc000ef          	jal	ra,80000b6c <acquire>
  r = kmem.freelist;
    80000ab4:	6c84                	ld	s1,24(s1)
  if(r)
    80000ab6:	c485                	beqz	s1,80000ade <kalloc+0x42>
    kmem.freelist = r->next;
    80000ab8:	609c                	ld	a5,0(s1)
    80000aba:	0000f517          	auipc	a0,0xf
    80000abe:	1ee50513          	addi	a0,a0,494 # 8000fca8 <kmem>
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
    80000ae2:	1ca50513          	addi	a0,a0,458 # 8000fca8 <kmem>
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
    80000b16:	2a8010ef          	jal	ra,80001dbe <mycpu>
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
    80000b44:	27a010ef          	jal	ra,80001dbe <mycpu>
    80000b48:	5d3c                	lw	a5,120(a0)
    80000b4a:	cb99                	beqz	a5,80000b60 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b4c:	272010ef          	jal	ra,80001dbe <mycpu>
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
    80000b60:	25e010ef          	jal	ra,80001dbe <mycpu>
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
    80000b94:	22a010ef          	jal	ra,80001dbe <mycpu>
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
    80000bb8:	206010ef          	jal	ra,80001dbe <mycpu>
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
    80000dea:	7c5000ef          	jal	ra,80001dae <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000dee:	00007717          	auipc	a4,0x7
    80000df2:	dc270713          	addi	a4,a4,-574 # 80007bb0 <started>
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
    80000e02:	7ad000ef          	jal	ra,80001dae <cpuid>
    80000e06:	85aa                	mv	a1,a0
    80000e08:	00006517          	auipc	a0,0x6
    80000e0c:	2a850513          	addi	a0,a0,680 # 800070b0 <digits+0x78>
    80000e10:	eb4ff0ef          	jal	ra,800004c4 <printf>
    kvminithart();    // turn on paging
    80000e14:	080000ef          	jal	ra,80000e94 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e18:	305010ef          	jal	ra,8000291c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e1c:	179040ef          	jal	ra,80005794 <plicinithart>
  }

  scheduler();        
    80000e20:	444010ef          	jal	ra,80002264 <scheduler>
    consoleinit();
    80000e24:	dc8ff0ef          	jal	ra,800003ec <consoleinit>
    printfinit();
    80000e28:	99fff0ef          	jal	ra,800007c6 <printfinit>
    printf("\n");
    80000e2c:	00006517          	auipc	a0,0x6
    80000e30:	3c450513          	addi	a0,a0,964 # 800071f0 <digits+0x1b8>
    80000e34:	e90ff0ef          	jal	ra,800004c4 <printf>
    printf("xv6 kernel is booting\n");
    80000e38:	00006517          	auipc	a0,0x6
    80000e3c:	26050513          	addi	a0,a0,608 # 80007098 <digits+0x60>
    80000e40:	e84ff0ef          	jal	ra,800004c4 <printf>
    printf("\n");
    80000e44:	00006517          	auipc	a0,0x6
    80000e48:	3ac50513          	addi	a0,a0,940 # 800071f0 <digits+0x1b8>
    80000e4c:	e78ff0ef          	jal	ra,800004c4 <printf>
    kinit();         // physical page allocator
    80000e50:	c19ff0ef          	jal	ra,80000a68 <kinit>
    kvminit();       // create kernel page table
    80000e54:	2ca000ef          	jal	ra,8000111e <kvminit>
    kvminithart();   // turn on paging
    80000e58:	03c000ef          	jal	ra,80000e94 <kvminithart>
    procinit();      // process table
    80000e5c:	6ab000ef          	jal	ra,80001d06 <procinit>
    trapinit();      // trap vectors
    80000e60:	299010ef          	jal	ra,800028f8 <trapinit>
    trapinithart();  // install kernel trap vector
    80000e64:	2b9010ef          	jal	ra,8000291c <trapinithart>
    plicinit();      // set up interrupt controller
    80000e68:	117040ef          	jal	ra,8000577e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000e6c:	129040ef          	jal	ra,80005794 <plicinithart>
    binit();         // buffer cache
    80000e70:	134020ef          	jal	ra,80002fa4 <binit>
    iinit();         // inode table
    80000e74:	6a8020ef          	jal	ra,8000351c <iinit>
    fileinit();      // file table
    80000e78:	588030ef          	jal	ra,80004400 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000e7c:	209040ef          	jal	ra,80005884 <virtio_disk_init>
    userinit();      // first user process
    80000e80:	24c010ef          	jal	ra,800020cc <userinit>
    __sync_synchronize();
    80000e84:	0ff0000f          	fence
    started = 1;
    80000e88:	4785                	li	a5,1
    80000e8a:	00007717          	auipc	a4,0x7
    80000e8e:	d2f72323          	sw	a5,-730(a4) # 80007bb0 <started>
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
    80000ea2:	d1a7b783          	ld	a5,-742(a5) # 80007bb8 <kernel_pagetable>
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
    8000110c:	371000ef          	jal	ra,80001c7c <proc_mapstacks>
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
    8000112e:	a8a7b723          	sd	a0,-1394(a5) # 80007bb8 <kernel_pagetable>
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

00000000800014e0 <add_resident_page>:

//changes 
// Add a page to the resident set
void add_resident_page(struct proc *p, uint64 va, int seq) {
    800014e0:	1141                	addi	sp,sp,-16
    800014e2:	e422                	sd	s0,8(sp)
    800014e4:	0800                	addi	s0,sp,16
  if(p->num_resident < MAX_RESIDENT_PAGES) {
    800014e6:	5c052783          	lw	a5,1472(a0)
    800014ea:	03f00713          	li	a4,63
    800014ee:	00f74e63          	blt	a4,a5,8000150a <add_resident_page+0x2a>
    p->resident_pages[p->num_resident].va = va;
    800014f2:	00479713          	slli	a4,a5,0x4
    800014f6:	972a                	add	a4,a4,a0
    800014f8:	1cb73023          	sd	a1,448(a4)
    p->resident_pages[p->num_resident].seq = seq;
    800014fc:	1cc72423          	sw	a2,456(a4)
    p->resident_pages[p->num_resident].is_dirty = 0;  // Start as clean
    80001500:	1c072623          	sw	zero,460(a4)
    p->num_resident++;
    80001504:	2785                	addiw	a5,a5,1
    80001506:	5cf52023          	sw	a5,1472(a0)
  }
}
    8000150a:	6422                	ld	s0,8(sp)
    8000150c:	0141                	addi	sp,sp,16
    8000150e:	8082                	ret

0000000080001510 <evict_page_fifo>:

// Find and evict the oldest resident page using FIFO
// Returns the physical address of the freed page
char* evict_page_fifo(struct proc *p, pagetable_t pagetable) {
  if(p->num_resident == 0)
    80001510:	5c052803          	lw	a6,1472(a0)
    80001514:	0a080b63          	beqz	a6,800015ca <evict_page_fifo+0xba>
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
    8000152e:	892a                	mv	s2,a0
    80001530:	8aae                	mv	s5,a1
    return 0;
  
  // Find victim with lowest sequence number (oldest)
  int victim_idx = 0;
  int min_seq = p->resident_pages[0].seq;
    80001532:	1c852603          	lw	a2,456(a0)
  
  for(int i = 1; i < p->num_resident; i++) {
    80001536:	4785                	li	a5,1
    80001538:	0307d063          	bge	a5,a6,80001558 <evict_page_fifo+0x48>
    8000153c:	1d850713          	addi	a4,a0,472
  int victim_idx = 0;
    80001540:	4a01                	li	s4,0
    80001542:	a029                	j	8000154c <evict_page_fifo+0x3c>
  for(int i = 1; i < p->num_resident; i++) {
    80001544:	2785                	addiw	a5,a5,1
    80001546:	0741                	addi	a4,a4,16
    80001548:	00f80963          	beq	a6,a5,8000155a <evict_page_fifo+0x4a>
    if(p->resident_pages[i].seq < min_seq) {
    8000154c:	4314                	lw	a3,0(a4)
    8000154e:	fec6dbe3          	bge	a3,a2,80001544 <evict_page_fifo+0x34>
      min_seq = p->resident_pages[i].seq;
    80001552:	8636                	mv	a2,a3
    if(p->resident_pages[i].seq < min_seq) {
    80001554:	8a3e                	mv	s4,a5
    80001556:	b7fd                	j	80001544 <evict_page_fifo+0x34>
  int victim_idx = 0;
    80001558:	4a01                	li	s4,0
      victim_idx = i;
    }
  }
  
  uint64 victim_va = p->resident_pages[victim_idx].va;
    8000155a:	8b52                	mv	s6,s4
    8000155c:	004a1793          	slli	a5,s4,0x4
    80001560:	00f904b3          	add	s1,s2,a5
    80001564:	1c04bb83          	ld	s7,448(s1)
  int victim_seq = p->resident_pages[victim_idx].seq;
  int is_dirty = p->resident_pages[victim_idx].is_dirty;
    80001568:	1cc4a983          	lw	s3,460(s1)
  
  // Log victim selection
  printf("[pid %d] VICTIM va=0x%lx seq=%d algo=FIFO\n", p->pid, victim_va, victim_seq);
    8000156c:	1c84a683          	lw	a3,456(s1)
    80001570:	865e                	mv	a2,s7
    80001572:	03092583          	lw	a1,48(s2) # 1030 <_entry-0x7fffefd0>
    80001576:	00006517          	auipc	a0,0x6
    8000157a:	bfa50513          	addi	a0,a0,-1030 # 80007170 <digits+0x138>
    8000157e:	f47fe0ef          	jal	ra,800004c4 <printf>
  printf("[pid %d] EVICT va=0x%lx state=%s\n", p->pid, victim_va, is_dirty ? "dirty" : "clean");
    80001582:	03092583          	lw	a1,48(s2)
    80001586:	04099463          	bnez	s3,800015ce <evict_page_fifo+0xbe>
    8000158a:	00006697          	auipc	a3,0x6
    8000158e:	c6e68693          	addi	a3,a3,-914 # 800071f8 <digits+0x1c0>
    80001592:	865e                	mv	a2,s7
    80001594:	00006517          	auipc	a0,0x6
    80001598:	c1450513          	addi	a0,a0,-1004 # 800071a8 <digits+0x170>
    8000159c:	f29fe0ef          	jal	ra,800004c4 <printf>
  
  // Get physical address before unmapping
  uint64 pa = walkaddr(pagetable, victim_va);
    800015a0:	85de                	mv	a1,s7
    800015a2:	8556                	mv	a0,s5
    800015a4:	9b3ff0ef          	jal	ra,80000f56 <walkaddr>
    800015a8:	89aa                	mv	s3,a0
  
  // Unmap the page
  uvmunmap(pagetable, victim_va, 1, 0);  // Don't free yet
    800015aa:	4681                	li	a3,0
    800015ac:	4605                	li	a2,1
    800015ae:	85de                	mv	a1,s7
    800015b0:	8556                	mv	a0,s5
    800015b2:	bafff0ef          	jal	ra,80001160 <uvmunmap>
  
  if(is_dirty) {
    // TODO: Swap out dirty page (Part 3)
    printf("[pid %d] SWAPOUT va=0x%lx slot=0\n", p->pid, victim_va);
  } else {
    printf("[pid %d] DISCARD va=0x%lx\n", p->pid, victim_va);
    800015b6:	865e                	mv	a2,s7
    800015b8:	03092583          	lw	a1,48(s2)
    800015bc:	00006517          	auipc	a0,0x6
    800015c0:	c4450513          	addi	a0,a0,-956 # 80007200 <digits+0x1c8>
    800015c4:	f01fe0ef          	jal	ra,800004c4 <printf>
    800015c8:	a091                	j	8000160c <evict_page_fifo+0xfc>
    return 0;
    800015ca:	4501                	li	a0,0
    p->resident_pages[i] = p->resident_pages[i + 1];
  }
  p->num_resident--;
  
  return (char*)pa;
}
    800015cc:	8082                	ret
  printf("[pid %d] EVICT va=0x%lx state=%s\n", p->pid, victim_va, is_dirty ? "dirty" : "clean");
    800015ce:	00006697          	auipc	a3,0x6
    800015d2:	bd268693          	addi	a3,a3,-1070 # 800071a0 <digits+0x168>
    800015d6:	865e                	mv	a2,s7
    800015d8:	00006517          	auipc	a0,0x6
    800015dc:	bd050513          	addi	a0,a0,-1072 # 800071a8 <digits+0x170>
    800015e0:	ee5fe0ef          	jal	ra,800004c4 <printf>
  uint64 pa = walkaddr(pagetable, victim_va);
    800015e4:	85de                	mv	a1,s7
    800015e6:	8556                	mv	a0,s5
    800015e8:	96fff0ef          	jal	ra,80000f56 <walkaddr>
    800015ec:	89aa                	mv	s3,a0
  uvmunmap(pagetable, victim_va, 1, 0);  // Don't free yet
    800015ee:	4681                	li	a3,0
    800015f0:	4605                	li	a2,1
    800015f2:	85de                	mv	a1,s7
    800015f4:	8556                	mv	a0,s5
    800015f6:	b6bff0ef          	jal	ra,80001160 <uvmunmap>
    printf("[pid %d] SWAPOUT va=0x%lx slot=0\n", p->pid, victim_va);
    800015fa:	865e                	mv	a2,s7
    800015fc:	03092583          	lw	a1,48(s2)
    80001600:	00006517          	auipc	a0,0x6
    80001604:	bd050513          	addi	a0,a0,-1072 # 800071d0 <digits+0x198>
    80001608:	ebdfe0ef          	jal	ra,800004c4 <printf>
  for(int i = victim_idx; i < p->num_resident - 1; i++) {
    8000160c:	5c092703          	lw	a4,1472(s2)
    80001610:	fff7061b          	addiw	a2,a4,-1
    80001614:	0006079b          	sext.w	a5,a2
    80001618:	02fa5863          	bge	s4,a5,80001648 <evict_page_fifo+0x138>
    8000161c:	87a6                	mv	a5,s1
    8000161e:	3779                	addiw	a4,a4,-2
    80001620:	4147073b          	subw	a4,a4,s4
    80001624:	1702                	slli	a4,a4,0x20
    80001626:	9301                	srli	a4,a4,0x20
    80001628:	975a                	add	a4,a4,s6
    8000162a:	0712                	slli	a4,a4,0x4
    8000162c:	01090693          	addi	a3,s2,16
    80001630:	9736                	add	a4,a4,a3
    p->resident_pages[i] = p->resident_pages[i + 1];
    80001632:	1d07b683          	ld	a3,464(a5)
    80001636:	1cd7b023          	sd	a3,448(a5)
    8000163a:	1d87b683          	ld	a3,472(a5)
    8000163e:	1cd7b423          	sd	a3,456(a5)
  for(int i = victim_idx; i < p->num_resident - 1; i++) {
    80001642:	07c1                	addi	a5,a5,16
    80001644:	fee797e3          	bne	a5,a4,80001632 <evict_page_fifo+0x122>
  p->num_resident--;
    80001648:	5cc92023          	sw	a2,1472(s2)
  return (char*)pa;
    8000164c:	854e                	mv	a0,s3
}
    8000164e:	60a6                	ld	ra,72(sp)
    80001650:	6406                	ld	s0,64(sp)
    80001652:	74e2                	ld	s1,56(sp)
    80001654:	7942                	ld	s2,48(sp)
    80001656:	79a2                	ld	s3,40(sp)
    80001658:	7a02                	ld	s4,32(sp)
    8000165a:	6ae2                	ld	s5,24(sp)
    8000165c:	6b42                	ld	s6,16(sp)
    8000165e:	6ba2                	ld	s7,8(sp)
    80001660:	6161                	addi	sp,sp,80
    80001662:	8082                	ret

0000000080001664 <vmfault>:


uint64
vmfault(pagetable_t pagetable, uint64 va, int is_write)
{
    80001664:	7139                	addi	sp,sp,-64
    80001666:	fc06                	sd	ra,56(sp)
    80001668:	f822                	sd	s0,48(sp)
    8000166a:	f426                	sd	s1,40(sp)
    8000166c:	f04a                	sd	s2,32(sp)
    8000166e:	ec4e                	sd	s3,24(sp)
    80001670:	e852                	sd	s4,16(sp)
    80001672:	e456                	sd	s5,8(sp)
    80001674:	e05a                	sd	s6,0(sp)
    80001676:	0080                	addi	s0,sp,64
    80001678:	8aaa                	mv	s5,a0
    8000167a:	892e                	mv	s2,a1
    8000167c:	8b32                	mv	s6,a2
  struct proc *p = myproc();
    8000167e:	75c000ef          	jal	ra,80001dda <myproc>
    80001682:	84aa                	mv	s1,a0
  char *mem;
  uint64 page_va = PGROUNDDOWN(va);
    80001684:	79fd                	lui	s3,0xfffff
    80001686:	01397a33          	and	s4,s2,s3
  
  printf("[DEBUG] vmfault: va=0x%lx, p->sz=0x%lx, stack_range=[0x%lx,0x%lx)\n", 
    8000168a:	6530                	ld	a2,72(a0)
    8000168c:	8732                	mv	a4,a2
    8000168e:	013606b3          	add	a3,a2,s3
    80001692:	85ca                	mv	a1,s2
    80001694:	00006517          	auipc	a0,0x6
    80001698:	b9450513          	addi	a0,a0,-1132 # 80007228 <digits+0x1f0>
    8000169c:	e29fe0ef          	jal	ra,800004c4 <printf>
         va, p->sz, p->sz - USERSTACK*PGSIZE, p->sz);
  
  // Check if address is valid - CHECK STACK FIRST
  if(va >= p->sz - USERSTACK*PGSIZE && va < p->sz) {
    800016a0:	64bc                	ld	a5,72(s1)
    800016a2:	99be                	add	s3,s3,a5
    800016a4:	0f396163          	bltu	s2,s3,80001786 <vmfault+0x122>
    800016a8:	0cf97f63          	bgeu	s2,a5,80001786 <vmfault+0x122>
    // Stack - allocate zero-filled page  
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=stack\n", 
    800016ac:	588c                	lw	a1,48(s1)
    800016ae:	00006697          	auipc	a3,0x6
    800016b2:	b7268693          	addi	a3,a3,-1166 # 80007220 <digits+0x1e8>
    800016b6:	000b1663          	bnez	s6,800016c2 <vmfault+0x5e>
    800016ba:	00006697          	auipc	a3,0x6
    800016be:	1be68693          	addi	a3,a3,446 # 80007878 <syscalls+0x1f0>
    800016c2:	8652                	mv	a2,s4
    800016c4:	00006517          	auipc	a0,0x6
    800016c8:	bac50513          	addi	a0,a0,-1108 # 80007270 <digits+0x238>
    800016cc:	df9fe0ef          	jal	ra,800004c4 <printf>
            p->pid, page_va, is_write ? "write" : "read");
    
   if((mem = kalloc()) == 0) {
    800016d0:	bccff0ef          	jal	ra,80000a9c <kalloc>
    800016d4:	892a                	mv	s2,a0
    800016d6:	c541                	beqz	a0,8000175e <vmfault+0xfa>
  mem = evict_page_fifo(p, pagetable);
  if(mem == 0) {
    return -1;
  }
}
    memset(mem, 0, PGSIZE);
    800016d8:	6605                	lui	a2,0x1
    800016da:	4581                	li	a1,0
    800016dc:	854a                	mv	a0,s2
    800016de:	d62ff0ef          	jal	ra,80000c40 <memset>
    
    // Map the page
    if(mappages(pagetable, page_va, PGSIZE, (uint64)mem, PTE_R | PTE_W | PTE_U) < 0) {
    800016e2:	89ca                	mv	s3,s2
    800016e4:	4759                	li	a4,22
    800016e6:	86ca                	mv	a3,s2
    800016e8:	6605                	lui	a2,0x1
    800016ea:	85d2                	mv	a1,s4
    800016ec:	8556                	mv	a0,s5
    800016ee:	8a7ff0ef          	jal	ra,80000f94 <mappages>
    800016f2:	08054563          	bltz	a0,8000177c <vmfault+0x118>
      kfree(mem);
      return -1;
    }
    
    printf("[pid %d] ALLOC va=0x%lx\n", p->pid, page_va);
    800016f6:	8652                	mv	a2,s4
    800016f8:	588c                	lw	a1,48(s1)
    800016fa:	00006517          	auipc	a0,0x6
    800016fe:	bc650513          	addi	a0,a0,-1082 # 800072c0 <digits+0x288>
    80001702:	dc3fe0ef          	jal	ra,800004c4 <printf>
    printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, page_va, p->next_fifo_seq);
    80001706:	1904a683          	lw	a3,400(s1)
    8000170a:	8652                	mv	a2,s4
    8000170c:	588c                	lw	a1,48(s1)
    8000170e:	00006517          	auipc	a0,0x6
    80001712:	bd250513          	addi	a0,a0,-1070 # 800072e0 <digits+0x2a8>
    80001716:	daffe0ef          	jal	ra,800004c4 <printf>
    add_resident_page(p, page_va, p->next_fifo_seq);
    8000171a:	1904a603          	lw	a2,400(s1)
    8000171e:	85d2                	mv	a1,s4
    80001720:	8526                	mv	a0,s1
    80001722:	dbfff0ef          	jal	ra,800014e0 <add_resident_page>
    p->next_fifo_seq++;
    80001726:	1904a783          	lw	a5,400(s1)
    8000172a:	2785                	addiw	a5,a5,1
    8000172c:	0007871b          	sext.w	a4,a5
    80001730:	18f4a823          	sw	a5,400(s1)
    
    // Add wraparound handling here
if(p->next_fifo_seq >= 1000000) {
    80001734:	000f47b7          	lui	a5,0xf4
    80001738:	23f78793          	addi	a5,a5,575 # f423f <_entry-0x7ff0bdc1>
    8000173c:	3ce7db63          	bge	a5,a4,80001b12 <vmfault+0x4ae>
  for(int i = 0; i < p->num_resident; i++) {
    80001740:	5c04a683          	lw	a3,1472(s1)
    80001744:	00d05a63          	blez	a3,80001758 <vmfault+0xf4>
    80001748:	1c848713          	addi	a4,s1,456
    8000174c:	4781                	li	a5,0
    p->resident_pages[i].seq = i;
    8000174e:	c31c                	sw	a5,0(a4)
  for(int i = 0; i < p->num_resident; i++) {
    80001750:	2785                	addiw	a5,a5,1
    80001752:	0741                	addi	a4,a4,16
    80001754:	fef69de3          	bne	a3,a5,8000174e <vmfault+0xea>
  }
  p->next_fifo_seq = p->num_resident;
    80001758:	18d4a823          	sw	a3,400(s1)
    8000175c:	ae5d                	j	80001b12 <vmfault+0x4ae>
  printf("[pid %d] MEMFULL\n", p->pid);
    8000175e:	588c                	lw	a1,48(s1)
    80001760:	00006517          	auipc	a0,0x6
    80001764:	b4850513          	addi	a0,a0,-1208 # 800072a8 <digits+0x270>
    80001768:	d5dfe0ef          	jal	ra,800004c4 <printf>
  mem = evict_page_fifo(p, pagetable);
    8000176c:	85d6                	mv	a1,s5
    8000176e:	8526                	mv	a0,s1
    80001770:	da1ff0ef          	jal	ra,80001510 <evict_page_fifo>
    80001774:	892a                	mv	s2,a0
  if(mem == 0) {
    80001776:	f12d                	bnez	a0,800016d8 <vmfault+0x74>
    return -1;
    80001778:	59fd                	li	s3,-1
    8000177a:	ae61                	j	80001b12 <vmfault+0x4ae>
      kfree(mem);
    8000177c:	854a                	mv	a0,s2
    8000177e:	a3eff0ef          	jal	ra,800009bc <kfree>
      return -1;
    80001782:	59fd                	li	s3,-1
    80001784:	a679                	j	80001b12 <vmfault+0x4ae>
}

    return (uint64)mem;
  }
  else if(va >= p->text_start && va < p->text_end) {
    80001786:	1684b783          	ld	a5,360(s1)
    8000178a:	12f96963          	bltu	s2,a5,800018bc <vmfault+0x258>
    8000178e:	1704b783          	ld	a5,368(s1)
    80001792:	12f97563          	bgeu	s2,a5,800018bc <vmfault+0x258>
    // Text segment - allocate and load from executable
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=exec\n", 
    80001796:	588c                	lw	a1,48(s1)
    80001798:	00006697          	auipc	a3,0x6
    8000179c:	a8868693          	addi	a3,a3,-1400 # 80007220 <digits+0x1e8>
    800017a0:	000b1663          	bnez	s6,800017ac <vmfault+0x148>
    800017a4:	00006697          	auipc	a3,0x6
    800017a8:	0d468693          	addi	a3,a3,212 # 80007878 <syscalls+0x1f0>
    800017ac:	8652                	mv	a2,s4
    800017ae:	00006517          	auipc	a0,0x6
    800017b2:	b5a50513          	addi	a0,a0,-1190 # 80007308 <digits+0x2d0>
    800017b6:	d0ffe0ef          	jal	ra,800004c4 <printf>
            p->pid, page_va, is_write ? "write" : "read");
    
  if((mem = kalloc()) == 0) {
    800017ba:	ae2ff0ef          	jal	ra,80000a9c <kalloc>
    800017be:	892a                	mv	s2,a0
    800017c0:	c969                	beqz	a0,80001892 <vmfault+0x22e>
  mem = evict_page_fifo(p, pagetable);
  if(mem == 0) {
    return -1;
  }
}
    memset(mem, 0, PGSIZE);  // Zero-fill first
    800017c2:	6605                	lui	a2,0x1
    800017c4:	4581                	li	a1,0
    800017c6:	854a                	mv	a0,s2
    800017c8:	c78ff0ef          	jal	ra,80000c40 <memset>
    
    // Load actual program content from executable file
    if(p->exec_inode && p->text_file_size > 0) {
    800017cc:	1984b503          	ld	a0,408(s1)
    800017d0:	c139                	beqz	a0,80001816 <vmfault+0x1b2>
    800017d2:	1a84b783          	ld	a5,424(s1)
    800017d6:	c3a1                	beqz	a5,80001816 <vmfault+0x1b2>
      uint64 page_offset_in_segment = page_va - p->text_start;
    800017d8:	1684b683          	ld	a3,360(s1)
    800017dc:	40da0733          	sub	a4,s4,a3
      uint64 file_offset = p->text_file_offset + page_offset_in_segment;
    800017e0:	1a04b983          	ld	s3,416(s1)
    800017e4:	99ba                	add	s3,s3,a4
      uint64 bytes_to_read = PGSIZE;
      
      // Don't read beyond the segment
      if(page_offset_in_segment + PGSIZE > p->text_file_size) {
    800017e6:	6605                	lui	a2,0x1
    800017e8:	9732                	add	a4,a4,a2
      uint64 bytes_to_read = PGSIZE;
    800017ea:	6b05                	lui	s6,0x1
      if(page_offset_in_segment + PGSIZE > p->text_file_size) {
    800017ec:	00e7f563          	bgeu	a5,a4,800017f6 <vmfault+0x192>
        bytes_to_read = p->text_file_size - page_offset_in_segment;
    800017f0:	97b6                	add	a5,a5,a3
    800017f2:	41478b33          	sub	s6,a5,s4
      }
      
      // Read from executable file into the page
      ilock(p->exec_inode);
    800017f6:	6e7010ef          	jal	ra,800036dc <ilock>
      readi(p->exec_inode, 0, (uint64)mem, file_offset, bytes_to_read);
    800017fa:	000b071b          	sext.w	a4,s6
    800017fe:	0009869b          	sext.w	a3,s3
    80001802:	864a                	mv	a2,s2
    80001804:	4581                	li	a1,0
    80001806:	1984b503          	ld	a0,408(s1)
    8000180a:	25e020ef          	jal	ra,80003a68 <readi>
      iunlock(p->exec_inode);
    8000180e:	1984b503          	ld	a0,408(s1)
    80001812:	775010ef          	jal	ra,80003786 <iunlock>
    }
    
    // Map the page
    if(mappages(pagetable, page_va, PGSIZE, (uint64)mem, PTE_R | PTE_X | PTE_U) < 0) {
    80001816:	89ca                	mv	s3,s2
    80001818:	4769                	li	a4,26
    8000181a:	86ca                	mv	a3,s2
    8000181c:	6605                	lui	a2,0x1
    8000181e:	85d2                	mv	a1,s4
    80001820:	8556                	mv	a0,s5
    80001822:	f72ff0ef          	jal	ra,80000f94 <mappages>
    80001826:	08054663          	bltz	a0,800018b2 <vmfault+0x24e>
      kfree(mem);
      return -1;
    }
    
    printf("[pid %d] LOADEXEC va=0x%lx\n", p->pid, page_va);
    8000182a:	8652                	mv	a2,s4
    8000182c:	588c                	lw	a1,48(s1)
    8000182e:	00006517          	auipc	a0,0x6
    80001832:	b1250513          	addi	a0,a0,-1262 # 80007340 <digits+0x308>
    80001836:	c8ffe0ef          	jal	ra,800004c4 <printf>
    printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, page_va, p->next_fifo_seq);
    8000183a:	1904a683          	lw	a3,400(s1)
    8000183e:	8652                	mv	a2,s4
    80001840:	588c                	lw	a1,48(s1)
    80001842:	00006517          	auipc	a0,0x6
    80001846:	a9e50513          	addi	a0,a0,-1378 # 800072e0 <digits+0x2a8>
    8000184a:	c7bfe0ef          	jal	ra,800004c4 <printf>
    add_resident_page(p, page_va, p->next_fifo_seq);
    8000184e:	1904a603          	lw	a2,400(s1)
    80001852:	85d2                	mv	a1,s4
    80001854:	8526                	mv	a0,s1
    80001856:	c8bff0ef          	jal	ra,800014e0 <add_resident_page>
    p->next_fifo_seq++;
    8000185a:	1904a783          	lw	a5,400(s1)
    8000185e:	2785                	addiw	a5,a5,1
    80001860:	0007871b          	sext.w	a4,a5
    80001864:	18f4a823          	sw	a5,400(s1)
    // Add wraparound handling here
if(p->next_fifo_seq >= 1000000) {
    80001868:	000f47b7          	lui	a5,0xf4
    8000186c:	23f78793          	addi	a5,a5,575 # f423f <_entry-0x7ff0bdc1>
    80001870:	2ae7d163          	bge	a5,a4,80001b12 <vmfault+0x4ae>
  for(int i = 0; i < p->num_resident; i++) {
    80001874:	5c04a683          	lw	a3,1472(s1)
    80001878:	00d05a63          	blez	a3,8000188c <vmfault+0x228>
    8000187c:	1c848713          	addi	a4,s1,456
    80001880:	4781                	li	a5,0
    p->resident_pages[i].seq = i;
    80001882:	c31c                	sw	a5,0(a4)
  for(int i = 0; i < p->num_resident; i++) {
    80001884:	2785                	addiw	a5,a5,1
    80001886:	0741                	addi	a4,a4,16
    80001888:	fed79de3          	bne	a5,a3,80001882 <vmfault+0x21e>
  }
  p->next_fifo_seq = p->num_resident;
    8000188c:	18d4a823          	sw	a3,400(s1)
    80001890:	a449                	j	80001b12 <vmfault+0x4ae>
  printf("[pid %d] MEMFULL\n", p->pid);
    80001892:	588c                	lw	a1,48(s1)
    80001894:	00006517          	auipc	a0,0x6
    80001898:	a1450513          	addi	a0,a0,-1516 # 800072a8 <digits+0x270>
    8000189c:	c29fe0ef          	jal	ra,800004c4 <printf>
  mem = evict_page_fifo(p, pagetable);
    800018a0:	85d6                	mv	a1,s5
    800018a2:	8526                	mv	a0,s1
    800018a4:	c6dff0ef          	jal	ra,80001510 <evict_page_fifo>
    800018a8:	892a                	mv	s2,a0
  if(mem == 0) {
    800018aa:	f0051ce3          	bnez	a0,800017c2 <vmfault+0x15e>
    return -1;
    800018ae:	59fd                	li	s3,-1
    800018b0:	a48d                	j	80001b12 <vmfault+0x4ae>
      kfree(mem);
    800018b2:	854a                	mv	a0,s2
    800018b4:	908ff0ef          	jal	ra,800009bc <kfree>
      return -1;
    800018b8:	59fd                	li	s3,-1
    800018ba:	aca1                	j	80001b12 <vmfault+0x4ae>
}
    return (uint64)mem;
  }
  else if(va >= p->data_start && va < p->data_end) {
    800018bc:	1784b783          	ld	a5,376(s1)
    800018c0:	12f96963          	bltu	s2,a5,800019f2 <vmfault+0x38e>
    800018c4:	1804b783          	ld	a5,384(s1)
    800018c8:	12f97563          	bgeu	s2,a5,800019f2 <vmfault+0x38e>
    // Data segment - allocate and load from executable
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=exec\n", 
    800018cc:	588c                	lw	a1,48(s1)
    800018ce:	00006697          	auipc	a3,0x6
    800018d2:	95268693          	addi	a3,a3,-1710 # 80007220 <digits+0x1e8>
    800018d6:	000b1663          	bnez	s6,800018e2 <vmfault+0x27e>
    800018da:	00006697          	auipc	a3,0x6
    800018de:	f9e68693          	addi	a3,a3,-98 # 80007878 <syscalls+0x1f0>
    800018e2:	8652                	mv	a2,s4
    800018e4:	00006517          	auipc	a0,0x6
    800018e8:	a2450513          	addi	a0,a0,-1500 # 80007308 <digits+0x2d0>
    800018ec:	bd9fe0ef          	jal	ra,800004c4 <printf>
            p->pid, page_va, is_write ? "write" : "read");
    
  if((mem = kalloc()) == 0) {
    800018f0:	9acff0ef          	jal	ra,80000a9c <kalloc>
    800018f4:	892a                	mv	s2,a0
    800018f6:	c969                	beqz	a0,800019c8 <vmfault+0x364>
  mem = evict_page_fifo(p, pagetable);
  if(mem == 0) {
    return -1;
  }
}
    memset(mem, 0, PGSIZE);  // Zero-fill first
    800018f8:	6605                	lui	a2,0x1
    800018fa:	4581                	li	a1,0
    800018fc:	854a                	mv	a0,s2
    800018fe:	b42ff0ef          	jal	ra,80000c40 <memset>
    
    // Load actual program content from executable file
    if(p->exec_inode && p->data_file_size > 0) {
    80001902:	1984b503          	ld	a0,408(s1)
    80001906:	c139                	beqz	a0,8000194c <vmfault+0x2e8>
    80001908:	1b84b783          	ld	a5,440(s1)
    8000190c:	c3a1                	beqz	a5,8000194c <vmfault+0x2e8>
      uint64 page_offset_in_segment = page_va - p->data_start;
    8000190e:	1784b683          	ld	a3,376(s1)
    80001912:	40da0733          	sub	a4,s4,a3
      uint64 file_offset = p->data_file_offset + page_offset_in_segment;
    80001916:	1b04b983          	ld	s3,432(s1)
    8000191a:	99ba                	add	s3,s3,a4
      uint64 bytes_to_read = PGSIZE;
      
      // Don't read beyond the segment
      if(page_offset_in_segment + PGSIZE > p->data_file_size) {
    8000191c:	6605                	lui	a2,0x1
    8000191e:	9732                	add	a4,a4,a2
      uint64 bytes_to_read = PGSIZE;
    80001920:	6b05                	lui	s6,0x1
      if(page_offset_in_segment + PGSIZE > p->data_file_size) {
    80001922:	00e7f563          	bgeu	a5,a4,8000192c <vmfault+0x2c8>
        bytes_to_read = p->data_file_size - page_offset_in_segment;
    80001926:	97b6                	add	a5,a5,a3
    80001928:	41478b33          	sub	s6,a5,s4
      }
      
      // Read from executable file into the page
      ilock(p->exec_inode);
    8000192c:	5b1010ef          	jal	ra,800036dc <ilock>
      readi(p->exec_inode, 0, (uint64)mem, file_offset, bytes_to_read);
    80001930:	000b071b          	sext.w	a4,s6
    80001934:	0009869b          	sext.w	a3,s3
    80001938:	864a                	mv	a2,s2
    8000193a:	4581                	li	a1,0
    8000193c:	1984b503          	ld	a0,408(s1)
    80001940:	128020ef          	jal	ra,80003a68 <readi>
      iunlock(p->exec_inode);
    80001944:	1984b503          	ld	a0,408(s1)
    80001948:	63f010ef          	jal	ra,80003786 <iunlock>
    }
    
    // Map the page
    if(mappages(pagetable, page_va, PGSIZE, (uint64)mem, PTE_R | PTE_W | PTE_U) < 0) {
    8000194c:	89ca                	mv	s3,s2
    8000194e:	4759                	li	a4,22
    80001950:	86ca                	mv	a3,s2
    80001952:	6605                	lui	a2,0x1
    80001954:	85d2                	mv	a1,s4
    80001956:	8556                	mv	a0,s5
    80001958:	e3cff0ef          	jal	ra,80000f94 <mappages>
    8000195c:	08054663          	bltz	a0,800019e8 <vmfault+0x384>
      kfree(mem);
      return -1;
    }
    
    printf("[pid %d] LOADEXEC va=0x%lx\n", p->pid, page_va);
    80001960:	8652                	mv	a2,s4
    80001962:	588c                	lw	a1,48(s1)
    80001964:	00006517          	auipc	a0,0x6
    80001968:	9dc50513          	addi	a0,a0,-1572 # 80007340 <digits+0x308>
    8000196c:	b59fe0ef          	jal	ra,800004c4 <printf>
    printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, page_va, p->next_fifo_seq);
    80001970:	1904a683          	lw	a3,400(s1)
    80001974:	8652                	mv	a2,s4
    80001976:	588c                	lw	a1,48(s1)
    80001978:	00006517          	auipc	a0,0x6
    8000197c:	96850513          	addi	a0,a0,-1688 # 800072e0 <digits+0x2a8>
    80001980:	b45fe0ef          	jal	ra,800004c4 <printf>
    add_resident_page(p, page_va, p->next_fifo_seq);
    80001984:	1904a603          	lw	a2,400(s1)
    80001988:	85d2                	mv	a1,s4
    8000198a:	8526                	mv	a0,s1
    8000198c:	b55ff0ef          	jal	ra,800014e0 <add_resident_page>
    p->next_fifo_seq++;
    80001990:	1904a783          	lw	a5,400(s1)
    80001994:	2785                	addiw	a5,a5,1
    80001996:	0007871b          	sext.w	a4,a5
    8000199a:	18f4a823          	sw	a5,400(s1)
    // Add wraparound handling here
if(p->next_fifo_seq >= 1000000) {
    8000199e:	000f47b7          	lui	a5,0xf4
    800019a2:	23f78793          	addi	a5,a5,575 # f423f <_entry-0x7ff0bdc1>
    800019a6:	16e7d663          	bge	a5,a4,80001b12 <vmfault+0x4ae>
  for(int i = 0; i < p->num_resident; i++) {
    800019aa:	5c04a683          	lw	a3,1472(s1)
    800019ae:	00d05a63          	blez	a3,800019c2 <vmfault+0x35e>
    800019b2:	1c848713          	addi	a4,s1,456
    800019b6:	4781                	li	a5,0
    p->resident_pages[i].seq = i;
    800019b8:	c31c                	sw	a5,0(a4)
  for(int i = 0; i < p->num_resident; i++) {
    800019ba:	2785                	addiw	a5,a5,1
    800019bc:	0741                	addi	a4,a4,16
    800019be:	fed79de3          	bne	a5,a3,800019b8 <vmfault+0x354>
  }
  p->next_fifo_seq = p->num_resident;
    800019c2:	18d4a823          	sw	a3,400(s1)
    800019c6:	a2b1                	j	80001b12 <vmfault+0x4ae>
  printf("[pid %d] MEMFULL\n", p->pid);
    800019c8:	588c                	lw	a1,48(s1)
    800019ca:	00006517          	auipc	a0,0x6
    800019ce:	8de50513          	addi	a0,a0,-1826 # 800072a8 <digits+0x270>
    800019d2:	af3fe0ef          	jal	ra,800004c4 <printf>
  mem = evict_page_fifo(p, pagetable);
    800019d6:	85d6                	mv	a1,s5
    800019d8:	8526                	mv	a0,s1
    800019da:	b37ff0ef          	jal	ra,80001510 <evict_page_fifo>
    800019de:	892a                	mv	s2,a0
  if(mem == 0) {
    800019e0:	f0051ce3          	bnez	a0,800018f8 <vmfault+0x294>
    return -1;
    800019e4:	59fd                	li	s3,-1
    800019e6:	a235                	j	80001b12 <vmfault+0x4ae>
      kfree(mem);
    800019e8:	854a                	mv	a0,s2
    800019ea:	fd3fe0ef          	jal	ra,800009bc <kfree>
      return -1;
    800019ee:	59fd                	li	s3,-1
    800019f0:	a20d                	j	80001b12 <vmfault+0x4ae>
}
    return (uint64)mem;
  }
  else if(va >= p->heap_start && va < p->sz - USERSTACK*PGSIZE) {
    800019f2:	1884b783          	ld	a5,392(s1)
    800019f6:	0ef96163          	bltu	s2,a5,80001ad8 <vmfault+0x474>
    800019fa:	0d397f63          	bgeu	s2,s3,80001ad8 <vmfault+0x474>
    // Heap - allocate zero-filled page
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=heap\n", 
    800019fe:	588c                	lw	a1,48(s1)
    80001a00:	00006697          	auipc	a3,0x6
    80001a04:	82068693          	addi	a3,a3,-2016 # 80007220 <digits+0x1e8>
    80001a08:	000b1663          	bnez	s6,80001a14 <vmfault+0x3b0>
    80001a0c:	00006697          	auipc	a3,0x6
    80001a10:	e6c68693          	addi	a3,a3,-404 # 80007878 <syscalls+0x1f0>
    80001a14:	8652                	mv	a2,s4
    80001a16:	00006517          	auipc	a0,0x6
    80001a1a:	94a50513          	addi	a0,a0,-1718 # 80007360 <digits+0x328>
    80001a1e:	aa7fe0ef          	jal	ra,800004c4 <printf>
            p->pid, page_va, is_write ? "write" : "read");
    
if((mem = kalloc()) == 0) {
    80001a22:	87aff0ef          	jal	ra,80000a9c <kalloc>
    80001a26:	892a                	mv	s2,a0
    80001a28:	c541                	beqz	a0,80001ab0 <vmfault+0x44c>
  mem = evict_page_fifo(p, pagetable);
  if(mem == 0) {
    return -1;
  }
}
    memset(mem, 0, PGSIZE);
    80001a2a:	6605                	lui	a2,0x1
    80001a2c:	4581                	li	a1,0
    80001a2e:	854a                	mv	a0,s2
    80001a30:	a10ff0ef          	jal	ra,80000c40 <memset>
    
    // Map the page
    if(mappages(pagetable, page_va, PGSIZE, (uint64)mem, PTE_R | PTE_W | PTE_U) < 0) {
    80001a34:	89ca                	mv	s3,s2
    80001a36:	4759                	li	a4,22
    80001a38:	86ca                	mv	a3,s2
    80001a3a:	6605                	lui	a2,0x1
    80001a3c:	85d2                	mv	a1,s4
    80001a3e:	8556                	mv	a0,s5
    80001a40:	d54ff0ef          	jal	ra,80000f94 <mappages>
    80001a44:	08054563          	bltz	a0,80001ace <vmfault+0x46a>
      kfree(mem);
      return -1;
    }
    
    printf("[pid %d] ALLOC va=0x%lx\n", p->pid, page_va);
    80001a48:	8652                	mv	a2,s4
    80001a4a:	588c                	lw	a1,48(s1)
    80001a4c:	00006517          	auipc	a0,0x6
    80001a50:	87450513          	addi	a0,a0,-1932 # 800072c0 <digits+0x288>
    80001a54:	a71fe0ef          	jal	ra,800004c4 <printf>
    printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, page_va, p->next_fifo_seq);
    80001a58:	1904a683          	lw	a3,400(s1)
    80001a5c:	8652                	mv	a2,s4
    80001a5e:	588c                	lw	a1,48(s1)
    80001a60:	00006517          	auipc	a0,0x6
    80001a64:	88050513          	addi	a0,a0,-1920 # 800072e0 <digits+0x2a8>
    80001a68:	a5dfe0ef          	jal	ra,800004c4 <printf>
    add_resident_page(p, page_va, p->next_fifo_seq);
    80001a6c:	1904a603          	lw	a2,400(s1)
    80001a70:	85d2                	mv	a1,s4
    80001a72:	8526                	mv	a0,s1
    80001a74:	a6dff0ef          	jal	ra,800014e0 <add_resident_page>
    p->next_fifo_seq++;
    80001a78:	1904a783          	lw	a5,400(s1)
    80001a7c:	2785                	addiw	a5,a5,1
    80001a7e:	0007871b          	sext.w	a4,a5
    80001a82:	18f4a823          	sw	a5,400(s1)
    // Add wraparound handling here
if(p->next_fifo_seq >= 1000000) {
    80001a86:	000f47b7          	lui	a5,0xf4
    80001a8a:	23f78793          	addi	a5,a5,575 # f423f <_entry-0x7ff0bdc1>
    80001a8e:	08e7d263          	bge	a5,a4,80001b12 <vmfault+0x4ae>
  for(int i = 0; i < p->num_resident; i++) {
    80001a92:	5c04a683          	lw	a3,1472(s1)
    80001a96:	00d05a63          	blez	a3,80001aaa <vmfault+0x446>
    80001a9a:	1c848713          	addi	a4,s1,456
    80001a9e:	4781                	li	a5,0
    p->resident_pages[i].seq = i;
    80001aa0:	c31c                	sw	a5,0(a4)
  for(int i = 0; i < p->num_resident; i++) {
    80001aa2:	2785                	addiw	a5,a5,1
    80001aa4:	0741                	addi	a4,a4,16
    80001aa6:	fed79de3          	bne	a5,a3,80001aa0 <vmfault+0x43c>
  }
  p->next_fifo_seq = p->num_resident;
    80001aaa:	18d4a823          	sw	a3,400(s1)
    80001aae:	a095                	j	80001b12 <vmfault+0x4ae>
  printf("[pid %d] MEMFULL\n", p->pid);
    80001ab0:	588c                	lw	a1,48(s1)
    80001ab2:	00005517          	auipc	a0,0x5
    80001ab6:	7f650513          	addi	a0,a0,2038 # 800072a8 <digits+0x270>
    80001aba:	a0bfe0ef          	jal	ra,800004c4 <printf>
  mem = evict_page_fifo(p, pagetable);
    80001abe:	85d6                	mv	a1,s5
    80001ac0:	8526                	mv	a0,s1
    80001ac2:	a4fff0ef          	jal	ra,80001510 <evict_page_fifo>
    80001ac6:	892a                	mv	s2,a0
  if(mem == 0) {
    80001ac8:	f12d                	bnez	a0,80001a2a <vmfault+0x3c6>
    return -1;
    80001aca:	59fd                	li	s3,-1
    80001acc:	a099                	j	80001b12 <vmfault+0x4ae>
      kfree(mem);
    80001ace:	854a                	mv	a0,s2
    80001ad0:	eedfe0ef          	jal	ra,800009bc <kfree>
      return -1;
    80001ad4:	59fd                	li	s3,-1
    80001ad6:	a835                	j	80001b12 <vmfault+0x4ae>
}
    return (uint64)mem;
  }
  else {
    // Invalid access - kill process
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=invalid\n", 
    80001ad8:	588c                	lw	a1,48(s1)
    80001ada:	00005917          	auipc	s2,0x5
    80001ade:	74690913          	addi	s2,s2,1862 # 80007220 <digits+0x1e8>
    80001ae2:	000b1663          	bnez	s6,80001aee <vmfault+0x48a>
    80001ae6:	00006917          	auipc	s2,0x6
    80001aea:	d9290913          	addi	s2,s2,-622 # 80007878 <syscalls+0x1f0>
    80001aee:	86ca                	mv	a3,s2
    80001af0:	8652                	mv	a2,s4
    80001af2:	00006517          	auipc	a0,0x6
    80001af6:	8a650513          	addi	a0,a0,-1882 # 80007398 <digits+0x360>
    80001afa:	9cbfe0ef          	jal	ra,800004c4 <printf>
            p->pid, page_va, is_write ? "write" : "read");
    printf("[pid %d] KILL invalid-access va=0x%lx access=%s\n", 
    80001afe:	86ca                	mv	a3,s2
    80001b00:	8652                	mv	a2,s4
    80001b02:	588c                	lw	a1,48(s1)
    80001b04:	00006517          	auipc	a0,0x6
    80001b08:	8cc50513          	addi	a0,a0,-1844 # 800073d0 <digits+0x398>
    80001b0c:	9b9fe0ef          	jal	ra,800004c4 <printf>
            p->pid, page_va, is_write ? "write" : "read");
    return -1;
    80001b10:	59fd                	li	s3,-1
  }
    80001b12:	854e                	mv	a0,s3
    80001b14:	70e2                	ld	ra,56(sp)
    80001b16:	7442                	ld	s0,48(sp)
    80001b18:	74a2                	ld	s1,40(sp)
    80001b1a:	7902                	ld	s2,32(sp)
    80001b1c:	69e2                	ld	s3,24(sp)
    80001b1e:	6a42                	ld	s4,16(sp)
    80001b20:	6aa2                	ld	s5,8(sp)
    80001b22:	6b02                	ld	s6,0(sp)
    80001b24:	6121                	addi	sp,sp,64
    80001b26:	8082                	ret

0000000080001b28 <copyout>:
  while(len > 0){
    80001b28:	cec1                	beqz	a3,80001bc0 <copyout+0x98>
{
    80001b2a:	711d                	addi	sp,sp,-96
    80001b2c:	ec86                	sd	ra,88(sp)
    80001b2e:	e8a2                	sd	s0,80(sp)
    80001b30:	e4a6                	sd	s1,72(sp)
    80001b32:	e0ca                	sd	s2,64(sp)
    80001b34:	fc4e                	sd	s3,56(sp)
    80001b36:	f852                	sd	s4,48(sp)
    80001b38:	f456                	sd	s5,40(sp)
    80001b3a:	f05a                	sd	s6,32(sp)
    80001b3c:	ec5e                	sd	s7,24(sp)
    80001b3e:	e862                	sd	s8,16(sp)
    80001b40:	e466                	sd	s9,8(sp)
    80001b42:	e06a                	sd	s10,0(sp)
    80001b44:	1080                	addi	s0,sp,96
    80001b46:	8c2a                	mv	s8,a0
    80001b48:	8b2e                	mv	s6,a1
    80001b4a:	8bb2                	mv	s7,a2
    80001b4c:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    80001b4e:	74fd                	lui	s1,0xfffff
    80001b50:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001b52:	57fd                	li	a5,-1
    80001b54:	83e9                	srli	a5,a5,0x1a
    80001b56:	0697e763          	bltu	a5,s1,80001bc4 <copyout+0x9c>
    80001b5a:	6d05                	lui	s10,0x1
    80001b5c:	8cbe                	mv	s9,a5
    80001b5e:	a015                	j	80001b82 <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001b60:	409b0533          	sub	a0,s6,s1
    80001b64:	0009861b          	sext.w	a2,s3
    80001b68:	85de                	mv	a1,s7
    80001b6a:	954a                	add	a0,a0,s2
    80001b6c:	930ff0ef          	jal	ra,80000c9c <memmove>
    len -= n;
    80001b70:	413a0a33          	sub	s4,s4,s3
    src += n;
    80001b74:	9bce                	add	s7,s7,s3
  while(len > 0){
    80001b76:	040a0363          	beqz	s4,80001bbc <copyout+0x94>
    if(va0 >= MAXVA)
    80001b7a:	055ce763          	bltu	s9,s5,80001bc8 <copyout+0xa0>
    va0 = PGROUNDDOWN(dstva);
    80001b7e:	84d6                	mv	s1,s5
    dstva = va0 + PGSIZE;
    80001b80:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    80001b82:	85a6                	mv	a1,s1
    80001b84:	8562                	mv	a0,s8
    80001b86:	bd0ff0ef          	jal	ra,80000f56 <walkaddr>
    80001b8a:	892a                	mv	s2,a0
    if(pa0 == 0) {
    80001b8c:	e901                	bnez	a0,80001b9c <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001b8e:	4601                	li	a2,0
    80001b90:	85a6                	mv	a1,s1
    80001b92:	8562                	mv	a0,s8
    80001b94:	ad1ff0ef          	jal	ra,80001664 <vmfault>
    80001b98:	892a                	mv	s2,a0
    80001b9a:	c90d                	beqz	a0,80001bcc <copyout+0xa4>
    pte = walk(pagetable, va0, 0);
    80001b9c:	4601                	li	a2,0
    80001b9e:	85a6                	mv	a1,s1
    80001ba0:	8562                	mv	a0,s8
    80001ba2:	b1aff0ef          	jal	ra,80000ebc <walk>
    if((*pte & PTE_W) == 0)
    80001ba6:	611c                	ld	a5,0(a0)
    80001ba8:	8b91                	andi	a5,a5,4
    80001baa:	c39d                	beqz	a5,80001bd0 <copyout+0xa8>
    n = PGSIZE - (dstva - va0);
    80001bac:	01a48ab3          	add	s5,s1,s10
    80001bb0:	416a89b3          	sub	s3,s5,s6
    if(n > len)
    80001bb4:	fb3a76e3          	bgeu	s4,s3,80001b60 <copyout+0x38>
    80001bb8:	89d2                	mv	s3,s4
    80001bba:	b75d                	j	80001b60 <copyout+0x38>
  return 0;
    80001bbc:	4501                	li	a0,0
    80001bbe:	a811                	j	80001bd2 <copyout+0xaa>
    80001bc0:	4501                	li	a0,0
}
    80001bc2:	8082                	ret
      return -1;
    80001bc4:	557d                	li	a0,-1
    80001bc6:	a031                	j	80001bd2 <copyout+0xaa>
    80001bc8:	557d                	li	a0,-1
    80001bca:	a021                	j	80001bd2 <copyout+0xaa>
        return -1;
    80001bcc:	557d                	li	a0,-1
    80001bce:	a011                	j	80001bd2 <copyout+0xaa>
      return -1;
    80001bd0:	557d                	li	a0,-1
}
    80001bd2:	60e6                	ld	ra,88(sp)
    80001bd4:	6446                	ld	s0,80(sp)
    80001bd6:	64a6                	ld	s1,72(sp)
    80001bd8:	6906                	ld	s2,64(sp)
    80001bda:	79e2                	ld	s3,56(sp)
    80001bdc:	7a42                	ld	s4,48(sp)
    80001bde:	7aa2                	ld	s5,40(sp)
    80001be0:	7b02                	ld	s6,32(sp)
    80001be2:	6be2                	ld	s7,24(sp)
    80001be4:	6c42                	ld	s8,16(sp)
    80001be6:	6ca2                	ld	s9,8(sp)
    80001be8:	6d02                	ld	s10,0(sp)
    80001bea:	6125                	addi	sp,sp,96
    80001bec:	8082                	ret

0000000080001bee <copyin>:
  while(len > 0){
    80001bee:	c6c9                	beqz	a3,80001c78 <copyin+0x8a>
{
    80001bf0:	715d                	addi	sp,sp,-80
    80001bf2:	e486                	sd	ra,72(sp)
    80001bf4:	e0a2                	sd	s0,64(sp)
    80001bf6:	fc26                	sd	s1,56(sp)
    80001bf8:	f84a                	sd	s2,48(sp)
    80001bfa:	f44e                	sd	s3,40(sp)
    80001bfc:	f052                	sd	s4,32(sp)
    80001bfe:	ec56                	sd	s5,24(sp)
    80001c00:	e85a                	sd	s6,16(sp)
    80001c02:	e45e                	sd	s7,8(sp)
    80001c04:	e062                	sd	s8,0(sp)
    80001c06:	0880                	addi	s0,sp,80
    80001c08:	8baa                	mv	s7,a0
    80001c0a:	8aae                	mv	s5,a1
    80001c0c:	8932                	mv	s2,a2
    80001c0e:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001c10:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001c12:	6b05                	lui	s6,0x1
    80001c14:	a035                	j	80001c40 <copyin+0x52>
    80001c16:	412984b3          	sub	s1,s3,s2
    80001c1a:	94da                	add	s1,s1,s6
    if(n > len)
    80001c1c:	009a7363          	bgeu	s4,s1,80001c22 <copyin+0x34>
    80001c20:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001c22:	413905b3          	sub	a1,s2,s3
    80001c26:	0004861b          	sext.w	a2,s1
    80001c2a:	95aa                	add	a1,a1,a0
    80001c2c:	8556                	mv	a0,s5
    80001c2e:	86eff0ef          	jal	ra,80000c9c <memmove>
    len -= n;
    80001c32:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001c36:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001c38:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001c3c:	020a0163          	beqz	s4,80001c5e <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001c40:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001c44:	85ce                	mv	a1,s3
    80001c46:	855e                	mv	a0,s7
    80001c48:	b0eff0ef          	jal	ra,80000f56 <walkaddr>
    if(pa0 == 0) {
    80001c4c:	f569                	bnez	a0,80001c16 <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001c4e:	4601                	li	a2,0
    80001c50:	85ce                	mv	a1,s3
    80001c52:	855e                	mv	a0,s7
    80001c54:	a11ff0ef          	jal	ra,80001664 <vmfault>
    80001c58:	fd5d                	bnez	a0,80001c16 <copyin+0x28>
        return -1;
    80001c5a:	557d                	li	a0,-1
    80001c5c:	a011                	j	80001c60 <copyin+0x72>
  return 0;
    80001c5e:	4501                	li	a0,0
}
    80001c60:	60a6                	ld	ra,72(sp)
    80001c62:	6406                	ld	s0,64(sp)
    80001c64:	74e2                	ld	s1,56(sp)
    80001c66:	7942                	ld	s2,48(sp)
    80001c68:	79a2                	ld	s3,40(sp)
    80001c6a:	7a02                	ld	s4,32(sp)
    80001c6c:	6ae2                	ld	s5,24(sp)
    80001c6e:	6b42                	ld	s6,16(sp)
    80001c70:	6ba2                	ld	s7,8(sp)
    80001c72:	6c02                	ld	s8,0(sp)
    80001c74:	6161                	addi	sp,sp,80
    80001c76:	8082                	ret
  return 0;
    80001c78:	4501                	li	a0,0
}
    80001c7a:	8082                	ret

0000000080001c7c <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001c7c:	7139                	addi	sp,sp,-64
    80001c7e:	fc06                	sd	ra,56(sp)
    80001c80:	f822                	sd	s0,48(sp)
    80001c82:	f426                	sd	s1,40(sp)
    80001c84:	f04a                	sd	s2,32(sp)
    80001c86:	ec4e                	sd	s3,24(sp)
    80001c88:	e852                	sd	s4,16(sp)
    80001c8a:	e456                	sd	s5,8(sp)
    80001c8c:	e05a                	sd	s6,0(sp)
    80001c8e:	0080                	addi	s0,sp,64
    80001c90:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c92:	0000e497          	auipc	s1,0xe
    80001c96:	46648493          	addi	s1,s1,1126 # 800100f8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001c9a:	8b26                	mv	s6,s1
    80001c9c:	00005a97          	auipc	s5,0x5
    80001ca0:	364a8a93          	addi	s5,s5,868 # 80007000 <etext>
    80001ca4:	04000937          	lui	s2,0x4000
    80001ca8:	197d                	addi	s2,s2,-1
    80001caa:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cac:	00025a17          	auipc	s4,0x25
    80001cb0:	64ca0a13          	addi	s4,s4,1612 # 800272f8 <tickslock>
    char *pa = kalloc();
    80001cb4:	de9fe0ef          	jal	ra,80000a9c <kalloc>
    80001cb8:	862a                	mv	a2,a0
    if(pa == 0)
    80001cba:	c121                	beqz	a0,80001cfa <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    80001cbc:	416485b3          	sub	a1,s1,s6
    80001cc0:	858d                	srai	a1,a1,0x3
    80001cc2:	000ab783          	ld	a5,0(s5)
    80001cc6:	02f585b3          	mul	a1,a1,a5
    80001cca:	2585                	addiw	a1,a1,1
    80001ccc:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001cd0:	4719                	li	a4,6
    80001cd2:	6685                	lui	a3,0x1
    80001cd4:	40b905b3          	sub	a1,s2,a1
    80001cd8:	854e                	mv	a0,s3
    80001cda:	b6aff0ef          	jal	ra,80001044 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cde:	5c848493          	addi	s1,s1,1480
    80001ce2:	fd4499e3          	bne	s1,s4,80001cb4 <proc_mapstacks+0x38>
  }
}
    80001ce6:	70e2                	ld	ra,56(sp)
    80001ce8:	7442                	ld	s0,48(sp)
    80001cea:	74a2                	ld	s1,40(sp)
    80001cec:	7902                	ld	s2,32(sp)
    80001cee:	69e2                	ld	s3,24(sp)
    80001cf0:	6a42                	ld	s4,16(sp)
    80001cf2:	6aa2                	ld	s5,8(sp)
    80001cf4:	6b02                	ld	s6,0(sp)
    80001cf6:	6121                	addi	sp,sp,64
    80001cf8:	8082                	ret
      panic("kalloc");
    80001cfa:	00005517          	auipc	a0,0x5
    80001cfe:	70e50513          	addi	a0,a0,1806 # 80007408 <digits+0x3d0>
    80001d02:	a89fe0ef          	jal	ra,8000078a <panic>

0000000080001d06 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001d06:	7139                	addi	sp,sp,-64
    80001d08:	fc06                	sd	ra,56(sp)
    80001d0a:	f822                	sd	s0,48(sp)
    80001d0c:	f426                	sd	s1,40(sp)
    80001d0e:	f04a                	sd	s2,32(sp)
    80001d10:	ec4e                	sd	s3,24(sp)
    80001d12:	e852                	sd	s4,16(sp)
    80001d14:	e456                	sd	s5,8(sp)
    80001d16:	e05a                	sd	s6,0(sp)
    80001d18:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001d1a:	00005597          	auipc	a1,0x5
    80001d1e:	6f658593          	addi	a1,a1,1782 # 80007410 <digits+0x3d8>
    80001d22:	0000e517          	auipc	a0,0xe
    80001d26:	fa650513          	addi	a0,a0,-90 # 8000fcc8 <pid_lock>
    80001d2a:	dc3fe0ef          	jal	ra,80000aec <initlock>
  initlock(&wait_lock, "wait_lock");
    80001d2e:	00005597          	auipc	a1,0x5
    80001d32:	6ea58593          	addi	a1,a1,1770 # 80007418 <digits+0x3e0>
    80001d36:	0000e517          	auipc	a0,0xe
    80001d3a:	faa50513          	addi	a0,a0,-86 # 8000fce0 <wait_lock>
    80001d3e:	daffe0ef          	jal	ra,80000aec <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d42:	0000e497          	auipc	s1,0xe
    80001d46:	3b648493          	addi	s1,s1,950 # 800100f8 <proc>
      initlock(&p->lock, "proc");
    80001d4a:	00005b17          	auipc	s6,0x5
    80001d4e:	6deb0b13          	addi	s6,s6,1758 # 80007428 <digits+0x3f0>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001d52:	8aa6                	mv	s5,s1
    80001d54:	00005a17          	auipc	s4,0x5
    80001d58:	2aca0a13          	addi	s4,s4,684 # 80007000 <etext>
    80001d5c:	04000937          	lui	s2,0x4000
    80001d60:	197d                	addi	s2,s2,-1
    80001d62:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d64:	00025997          	auipc	s3,0x25
    80001d68:	59498993          	addi	s3,s3,1428 # 800272f8 <tickslock>
      initlock(&p->lock, "proc");
    80001d6c:	85da                	mv	a1,s6
    80001d6e:	8526                	mv	a0,s1
    80001d70:	d7dfe0ef          	jal	ra,80000aec <initlock>
      p->state = UNUSED;
    80001d74:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001d78:	415487b3          	sub	a5,s1,s5
    80001d7c:	878d                	srai	a5,a5,0x3
    80001d7e:	000a3703          	ld	a4,0(s4)
    80001d82:	02e787b3          	mul	a5,a5,a4
    80001d86:	2785                	addiw	a5,a5,1
    80001d88:	00d7979b          	slliw	a5,a5,0xd
    80001d8c:	40f907b3          	sub	a5,s2,a5
    80001d90:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d92:	5c848493          	addi	s1,s1,1480
    80001d96:	fd349be3          	bne	s1,s3,80001d6c <procinit+0x66>
  }
}
    80001d9a:	70e2                	ld	ra,56(sp)
    80001d9c:	7442                	ld	s0,48(sp)
    80001d9e:	74a2                	ld	s1,40(sp)
    80001da0:	7902                	ld	s2,32(sp)
    80001da2:	69e2                	ld	s3,24(sp)
    80001da4:	6a42                	ld	s4,16(sp)
    80001da6:	6aa2                	ld	s5,8(sp)
    80001da8:	6b02                	ld	s6,0(sp)
    80001daa:	6121                	addi	sp,sp,64
    80001dac:	8082                	ret

0000000080001dae <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001dae:	1141                	addi	sp,sp,-16
    80001db0:	e422                	sd	s0,8(sp)
    80001db2:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001db4:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001db6:	2501                	sext.w	a0,a0
    80001db8:	6422                	ld	s0,8(sp)
    80001dba:	0141                	addi	sp,sp,16
    80001dbc:	8082                	ret

0000000080001dbe <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001dbe:	1141                	addi	sp,sp,-16
    80001dc0:	e422                	sd	s0,8(sp)
    80001dc2:	0800                	addi	s0,sp,16
    80001dc4:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001dc6:	2781                	sext.w	a5,a5
    80001dc8:	079e                	slli	a5,a5,0x7
  return c;
}
    80001dca:	0000e517          	auipc	a0,0xe
    80001dce:	f2e50513          	addi	a0,a0,-210 # 8000fcf8 <cpus>
    80001dd2:	953e                	add	a0,a0,a5
    80001dd4:	6422                	ld	s0,8(sp)
    80001dd6:	0141                	addi	sp,sp,16
    80001dd8:	8082                	ret

0000000080001dda <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001dda:	1101                	addi	sp,sp,-32
    80001ddc:	ec06                	sd	ra,24(sp)
    80001dde:	e822                	sd	s0,16(sp)
    80001de0:	e426                	sd	s1,8(sp)
    80001de2:	1000                	addi	s0,sp,32
  push_off();
    80001de4:	d49fe0ef          	jal	ra,80000b2c <push_off>
    80001de8:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001dea:	2781                	sext.w	a5,a5
    80001dec:	079e                	slli	a5,a5,0x7
    80001dee:	0000e717          	auipc	a4,0xe
    80001df2:	eda70713          	addi	a4,a4,-294 # 8000fcc8 <pid_lock>
    80001df6:	97ba                	add	a5,a5,a4
    80001df8:	7b84                	ld	s1,48(a5)
  pop_off();
    80001dfa:	db7fe0ef          	jal	ra,80000bb0 <pop_off>
  return p;
}
    80001dfe:	8526                	mv	a0,s1
    80001e00:	60e2                	ld	ra,24(sp)
    80001e02:	6442                	ld	s0,16(sp)
    80001e04:	64a2                	ld	s1,8(sp)
    80001e06:	6105                	addi	sp,sp,32
    80001e08:	8082                	ret

0000000080001e0a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001e0a:	7179                	addi	sp,sp,-48
    80001e0c:	f406                	sd	ra,40(sp)
    80001e0e:	f022                	sd	s0,32(sp)
    80001e10:	ec26                	sd	s1,24(sp)
    80001e12:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001e14:	fc7ff0ef          	jal	ra,80001dda <myproc>
    80001e18:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001e1a:	debfe0ef          	jal	ra,80000c04 <release>

  if (first) {
    80001e1e:	00006797          	auipc	a5,0x6
    80001e22:	d727a783          	lw	a5,-654(a5) # 80007b90 <first.1>
    80001e26:	cf8d                	beqz	a5,80001e60 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001e28:	4505                	li	a0,1
    80001e2a:	3a3010ef          	jal	ra,800039cc <fsinit>

    first = 0;
    80001e2e:	00006797          	auipc	a5,0x6
    80001e32:	d607a123          	sw	zero,-670(a5) # 80007b90 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001e36:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001e3a:	00005517          	auipc	a0,0x5
    80001e3e:	5f650513          	addi	a0,a0,1526 # 80007430 <digits+0x3f8>
    80001e42:	fca43823          	sd	a0,-48(s0)
    80001e46:	fc043c23          	sd	zero,-40(s0)
    80001e4a:	fd040593          	addi	a1,s0,-48
    80001e4e:	41d020ef          	jal	ra,80004a6a <kexec>
    80001e52:	6cbc                	ld	a5,88(s1)
    80001e54:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001e56:	6cbc                	ld	a5,88(s1)
    80001e58:	7bb8                	ld	a4,112(a5)
    80001e5a:	57fd                	li	a5,-1
    80001e5c:	02f70d63          	beq	a4,a5,80001e96 <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001e60:	2d5000ef          	jal	ra,80002934 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001e64:	68a8                	ld	a0,80(s1)
    80001e66:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001e68:	04000737          	lui	a4,0x4000
    80001e6c:	00004797          	auipc	a5,0x4
    80001e70:	23078793          	addi	a5,a5,560 # 8000609c <userret>
    80001e74:	00004697          	auipc	a3,0x4
    80001e78:	18c68693          	addi	a3,a3,396 # 80006000 <_trampoline>
    80001e7c:	8f95                	sub	a5,a5,a3
    80001e7e:	177d                	addi	a4,a4,-1
    80001e80:	0732                	slli	a4,a4,0xc
    80001e82:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001e84:	577d                	li	a4,-1
    80001e86:	177e                	slli	a4,a4,0x3f
    80001e88:	8d59                	or	a0,a0,a4
    80001e8a:	9782                	jalr	a5
}
    80001e8c:	70a2                	ld	ra,40(sp)
    80001e8e:	7402                	ld	s0,32(sp)
    80001e90:	64e2                	ld	s1,24(sp)
    80001e92:	6145                	addi	sp,sp,48
    80001e94:	8082                	ret
      panic("exec");
    80001e96:	00005517          	auipc	a0,0x5
    80001e9a:	5a250513          	addi	a0,a0,1442 # 80007438 <digits+0x400>
    80001e9e:	8edfe0ef          	jal	ra,8000078a <panic>

0000000080001ea2 <allocpid>:
{
    80001ea2:	1101                	addi	sp,sp,-32
    80001ea4:	ec06                	sd	ra,24(sp)
    80001ea6:	e822                	sd	s0,16(sp)
    80001ea8:	e426                	sd	s1,8(sp)
    80001eaa:	e04a                	sd	s2,0(sp)
    80001eac:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001eae:	0000e917          	auipc	s2,0xe
    80001eb2:	e1a90913          	addi	s2,s2,-486 # 8000fcc8 <pid_lock>
    80001eb6:	854a                	mv	a0,s2
    80001eb8:	cb5fe0ef          	jal	ra,80000b6c <acquire>
  pid = nextpid;
    80001ebc:	00006797          	auipc	a5,0x6
    80001ec0:	cd878793          	addi	a5,a5,-808 # 80007b94 <nextpid>
    80001ec4:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ec6:	0014871b          	addiw	a4,s1,1
    80001eca:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ecc:	854a                	mv	a0,s2
    80001ece:	d37fe0ef          	jal	ra,80000c04 <release>
}
    80001ed2:	8526                	mv	a0,s1
    80001ed4:	60e2                	ld	ra,24(sp)
    80001ed6:	6442                	ld	s0,16(sp)
    80001ed8:	64a2                	ld	s1,8(sp)
    80001eda:	6902                	ld	s2,0(sp)
    80001edc:	6105                	addi	sp,sp,32
    80001ede:	8082                	ret

0000000080001ee0 <proc_pagetable>:
{
    80001ee0:	1101                	addi	sp,sp,-32
    80001ee2:	ec06                	sd	ra,24(sp)
    80001ee4:	e822                	sd	s0,16(sp)
    80001ee6:	e426                	sd	s1,8(sp)
    80001ee8:	e04a                	sd	s2,0(sp)
    80001eea:	1000                	addi	s0,sp,32
    80001eec:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001eee:	a4cff0ef          	jal	ra,8000113a <uvmcreate>
    80001ef2:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001ef4:	cd05                	beqz	a0,80001f2c <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ef6:	4729                	li	a4,10
    80001ef8:	00004697          	auipc	a3,0x4
    80001efc:	10868693          	addi	a3,a3,264 # 80006000 <_trampoline>
    80001f00:	6605                	lui	a2,0x1
    80001f02:	040005b7          	lui	a1,0x4000
    80001f06:	15fd                	addi	a1,a1,-1
    80001f08:	05b2                	slli	a1,a1,0xc
    80001f0a:	88aff0ef          	jal	ra,80000f94 <mappages>
    80001f0e:	02054663          	bltz	a0,80001f3a <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001f12:	4719                	li	a4,6
    80001f14:	05893683          	ld	a3,88(s2)
    80001f18:	6605                	lui	a2,0x1
    80001f1a:	020005b7          	lui	a1,0x2000
    80001f1e:	15fd                	addi	a1,a1,-1
    80001f20:	05b6                	slli	a1,a1,0xd
    80001f22:	8526                	mv	a0,s1
    80001f24:	870ff0ef          	jal	ra,80000f94 <mappages>
    80001f28:	00054f63          	bltz	a0,80001f46 <proc_pagetable+0x66>
}
    80001f2c:	8526                	mv	a0,s1
    80001f2e:	60e2                	ld	ra,24(sp)
    80001f30:	6442                	ld	s0,16(sp)
    80001f32:	64a2                	ld	s1,8(sp)
    80001f34:	6902                	ld	s2,0(sp)
    80001f36:	6105                	addi	sp,sp,32
    80001f38:	8082                	ret
    uvmfree(pagetable, 0);
    80001f3a:	4581                	li	a1,0
    80001f3c:	8526                	mv	a0,s1
    80001f3e:	bdaff0ef          	jal	ra,80001318 <uvmfree>
    return 0;
    80001f42:	4481                	li	s1,0
    80001f44:	b7e5                	j	80001f2c <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f46:	4681                	li	a3,0
    80001f48:	4605                	li	a2,1
    80001f4a:	040005b7          	lui	a1,0x4000
    80001f4e:	15fd                	addi	a1,a1,-1
    80001f50:	05b2                	slli	a1,a1,0xc
    80001f52:	8526                	mv	a0,s1
    80001f54:	a0cff0ef          	jal	ra,80001160 <uvmunmap>
    uvmfree(pagetable, 0);
    80001f58:	4581                	li	a1,0
    80001f5a:	8526                	mv	a0,s1
    80001f5c:	bbcff0ef          	jal	ra,80001318 <uvmfree>
    return 0;
    80001f60:	4481                	li	s1,0
    80001f62:	b7e9                	j	80001f2c <proc_pagetable+0x4c>

0000000080001f64 <proc_freepagetable>:
{
    80001f64:	1101                	addi	sp,sp,-32
    80001f66:	ec06                	sd	ra,24(sp)
    80001f68:	e822                	sd	s0,16(sp)
    80001f6a:	e426                	sd	s1,8(sp)
    80001f6c:	e04a                	sd	s2,0(sp)
    80001f6e:	1000                	addi	s0,sp,32
    80001f70:	84aa                	mv	s1,a0
    80001f72:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f74:	4681                	li	a3,0
    80001f76:	4605                	li	a2,1
    80001f78:	040005b7          	lui	a1,0x4000
    80001f7c:	15fd                	addi	a1,a1,-1
    80001f7e:	05b2                	slli	a1,a1,0xc
    80001f80:	9e0ff0ef          	jal	ra,80001160 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001f84:	4681                	li	a3,0
    80001f86:	4605                	li	a2,1
    80001f88:	020005b7          	lui	a1,0x2000
    80001f8c:	15fd                	addi	a1,a1,-1
    80001f8e:	05b6                	slli	a1,a1,0xd
    80001f90:	8526                	mv	a0,s1
    80001f92:	9ceff0ef          	jal	ra,80001160 <uvmunmap>
  uvmfree(pagetable, sz);
    80001f96:	85ca                	mv	a1,s2
    80001f98:	8526                	mv	a0,s1
    80001f9a:	b7eff0ef          	jal	ra,80001318 <uvmfree>
}
    80001f9e:	60e2                	ld	ra,24(sp)
    80001fa0:	6442                	ld	s0,16(sp)
    80001fa2:	64a2                	ld	s1,8(sp)
    80001fa4:	6902                	ld	s2,0(sp)
    80001fa6:	6105                	addi	sp,sp,32
    80001fa8:	8082                	ret

0000000080001faa <freeproc>:
{
    80001faa:	1101                	addi	sp,sp,-32
    80001fac:	ec06                	sd	ra,24(sp)
    80001fae:	e822                	sd	s0,16(sp)
    80001fb0:	e426                	sd	s1,8(sp)
    80001fb2:	1000                	addi	s0,sp,32
    80001fb4:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001fb6:	6d28                	ld	a0,88(a0)
    80001fb8:	c119                	beqz	a0,80001fbe <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001fba:	a03fe0ef          	jal	ra,800009bc <kfree>
  p->trapframe = 0;
    80001fbe:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001fc2:	68a8                	ld	a0,80(s1)
    80001fc4:	c501                	beqz	a0,80001fcc <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001fc6:	64ac                	ld	a1,72(s1)
    80001fc8:	f9dff0ef          	jal	ra,80001f64 <proc_freepagetable>
  p->pagetable = 0;
    80001fcc:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001fd0:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001fd4:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001fd8:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001fdc:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001fe0:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001fe4:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001fe8:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001fec:	0004ac23          	sw	zero,24(s1)
}
    80001ff0:	60e2                	ld	ra,24(sp)
    80001ff2:	6442                	ld	s0,16(sp)
    80001ff4:	64a2                	ld	s1,8(sp)
    80001ff6:	6105                	addi	sp,sp,32
    80001ff8:	8082                	ret

0000000080001ffa <allocproc>:
{
    80001ffa:	1101                	addi	sp,sp,-32
    80001ffc:	ec06                	sd	ra,24(sp)
    80001ffe:	e822                	sd	s0,16(sp)
    80002000:	e426                	sd	s1,8(sp)
    80002002:	e04a                	sd	s2,0(sp)
    80002004:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80002006:	0000e497          	auipc	s1,0xe
    8000200a:	0f248493          	addi	s1,s1,242 # 800100f8 <proc>
    8000200e:	00025917          	auipc	s2,0x25
    80002012:	2ea90913          	addi	s2,s2,746 # 800272f8 <tickslock>
    acquire(&p->lock);
    80002016:	8526                	mv	a0,s1
    80002018:	b55fe0ef          	jal	ra,80000b6c <acquire>
    if(p->state == UNUSED) {
    8000201c:	4c9c                	lw	a5,24(s1)
    8000201e:	cb91                	beqz	a5,80002032 <allocproc+0x38>
      release(&p->lock);
    80002020:	8526                	mv	a0,s1
    80002022:	be3fe0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002026:	5c848493          	addi	s1,s1,1480
    8000202a:	ff2496e3          	bne	s1,s2,80002016 <allocproc+0x1c>
  return 0;
    8000202e:	4481                	li	s1,0
    80002030:	a0bd                	j	8000209e <allocproc+0xa4>
  p->pid = allocpid();
    80002032:	e71ff0ef          	jal	ra,80001ea2 <allocpid>
    80002036:	d888                	sw	a0,48(s1)
  p->state = USED;
    80002038:	4785                	li	a5,1
    8000203a:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    8000203c:	a61fe0ef          	jal	ra,80000a9c <kalloc>
    80002040:	892a                	mv	s2,a0
    80002042:	eca8                	sd	a0,88(s1)
    80002044:	c525                	beqz	a0,800020ac <allocproc+0xb2>
  p->pagetable = proc_pagetable(p);
    80002046:	8526                	mv	a0,s1
    80002048:	e99ff0ef          	jal	ra,80001ee0 <proc_pagetable>
    8000204c:	892a                	mv	s2,a0
    8000204e:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80002050:	c535                	beqz	a0,800020bc <allocproc+0xc2>
  memset(&p->context, 0, sizeof(p->context));
    80002052:	07000613          	li	a2,112
    80002056:	4581                	li	a1,0
    80002058:	06048513          	addi	a0,s1,96
    8000205c:	be5fe0ef          	jal	ra,80000c40 <memset>
  p->context.ra = (uint64)forkret;
    80002060:	00000797          	auipc	a5,0x0
    80002064:	daa78793          	addi	a5,a5,-598 # 80001e0a <forkret>
    80002068:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    8000206a:	60bc                	ld	a5,64(s1)
    8000206c:	6705                	lui	a4,0x1
    8000206e:	97ba                	add	a5,a5,a4
    80002070:	f4bc                	sd	a5,104(s1)
  p->text_start = 0;
    80002072:	1604b423          	sd	zero,360(s1)
  p->text_end = 0;
    80002076:	1604b823          	sd	zero,368(s1)
  p->data_start = 0;
    8000207a:	1604bc23          	sd	zero,376(s1)
  p->data_end = 0;
    8000207e:	1804b023          	sd	zero,384(s1)
  p->heap_start = 0;
    80002082:	1804b423          	sd	zero,392(s1)
  p->next_fifo_seq = 0;
    80002086:	1804a823          	sw	zero,400(s1)
  p->exec_inode = 0;
    8000208a:	1804bc23          	sd	zero,408(s1)
  p->text_file_offset = 0;
    8000208e:	1a04b023          	sd	zero,416(s1)
p->text_file_size = 0;
    80002092:	1a04b423          	sd	zero,424(s1)
p->data_file_offset = 0;
    80002096:	1a04b823          	sd	zero,432(s1)
p->data_file_size = 0;
    8000209a:	1a04bc23          	sd	zero,440(s1)
}
    8000209e:	8526                	mv	a0,s1
    800020a0:	60e2                	ld	ra,24(sp)
    800020a2:	6442                	ld	s0,16(sp)
    800020a4:	64a2                	ld	s1,8(sp)
    800020a6:	6902                	ld	s2,0(sp)
    800020a8:	6105                	addi	sp,sp,32
    800020aa:	8082                	ret
    freeproc(p);
    800020ac:	8526                	mv	a0,s1
    800020ae:	efdff0ef          	jal	ra,80001faa <freeproc>
    release(&p->lock);
    800020b2:	8526                	mv	a0,s1
    800020b4:	b51fe0ef          	jal	ra,80000c04 <release>
    return 0;
    800020b8:	84ca                	mv	s1,s2
    800020ba:	b7d5                	j	8000209e <allocproc+0xa4>
    freeproc(p);
    800020bc:	8526                	mv	a0,s1
    800020be:	eedff0ef          	jal	ra,80001faa <freeproc>
    release(&p->lock);
    800020c2:	8526                	mv	a0,s1
    800020c4:	b41fe0ef          	jal	ra,80000c04 <release>
    return 0;
    800020c8:	84ca                	mv	s1,s2
    800020ca:	bfd1                	j	8000209e <allocproc+0xa4>

00000000800020cc <userinit>:
{
    800020cc:	1101                	addi	sp,sp,-32
    800020ce:	ec06                	sd	ra,24(sp)
    800020d0:	e822                	sd	s0,16(sp)
    800020d2:	e426                	sd	s1,8(sp)
    800020d4:	1000                	addi	s0,sp,32
  p = allocproc();
    800020d6:	f25ff0ef          	jal	ra,80001ffa <allocproc>
    800020da:	84aa                	mv	s1,a0
  initproc = p;
    800020dc:	00006797          	auipc	a5,0x6
    800020e0:	aea7b223          	sd	a0,-1308(a5) # 80007bc0 <initproc>
  p->cwd = namei("/");
    800020e4:	00005517          	auipc	a0,0x5
    800020e8:	35c50513          	addi	a0,a0,860 # 80007440 <digits+0x408>
    800020ec:	5df010ef          	jal	ra,80003eca <namei>
    800020f0:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    800020f4:	478d                	li	a5,3
    800020f6:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    800020f8:	8526                	mv	a0,s1
    800020fa:	b0bfe0ef          	jal	ra,80000c04 <release>
}
    800020fe:	60e2                	ld	ra,24(sp)
    80002100:	6442                	ld	s0,16(sp)
    80002102:	64a2                	ld	s1,8(sp)
    80002104:	6105                	addi	sp,sp,32
    80002106:	8082                	ret

0000000080002108 <growproc>:
{
    80002108:	1101                	addi	sp,sp,-32
    8000210a:	ec06                	sd	ra,24(sp)
    8000210c:	e822                	sd	s0,16(sp)
    8000210e:	e426                	sd	s1,8(sp)
    80002110:	e04a                	sd	s2,0(sp)
    80002112:	1000                	addi	s0,sp,32
    80002114:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80002116:	cc5ff0ef          	jal	ra,80001dda <myproc>
    8000211a:	84aa                	mv	s1,a0
  sz = p->sz;
    8000211c:	652c                	ld	a1,72(a0)
  if(n > 0){
    8000211e:	01204c63          	bgtz	s2,80002136 <growproc+0x2e>
  } else if(n < 0){
    80002122:	02094463          	bltz	s2,8000214a <growproc+0x42>
  p->sz = sz;
    80002126:	e4ac                	sd	a1,72(s1)
  return 0;
    80002128:	4501                	li	a0,0
}
    8000212a:	60e2                	ld	ra,24(sp)
    8000212c:	6442                	ld	s0,16(sp)
    8000212e:	64a2                	ld	s1,8(sp)
    80002130:	6902                	ld	s2,0(sp)
    80002132:	6105                	addi	sp,sp,32
    80002134:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80002136:	4691                	li	a3,4
    80002138:	00b90633          	add	a2,s2,a1
    8000213c:	6928                	ld	a0,80(a0)
    8000213e:	8e2ff0ef          	jal	ra,80001220 <uvmalloc>
    80002142:	85aa                	mv	a1,a0
    80002144:	f16d                	bnez	a0,80002126 <growproc+0x1e>
      return -1;
    80002146:	557d                	li	a0,-1
    80002148:	b7cd                	j	8000212a <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000214a:	00b90633          	add	a2,s2,a1
    8000214e:	6928                	ld	a0,80(a0)
    80002150:	88cff0ef          	jal	ra,800011dc <uvmdealloc>
    80002154:	85aa                	mv	a1,a0
    80002156:	bfc1                	j	80002126 <growproc+0x1e>

0000000080002158 <kfork>:
{
    80002158:	7139                	addi	sp,sp,-64
    8000215a:	fc06                	sd	ra,56(sp)
    8000215c:	f822                	sd	s0,48(sp)
    8000215e:	f426                	sd	s1,40(sp)
    80002160:	f04a                	sd	s2,32(sp)
    80002162:	ec4e                	sd	s3,24(sp)
    80002164:	e852                	sd	s4,16(sp)
    80002166:	e456                	sd	s5,8(sp)
    80002168:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    8000216a:	c71ff0ef          	jal	ra,80001dda <myproc>
    8000216e:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80002170:	e8bff0ef          	jal	ra,80001ffa <allocproc>
    80002174:	0e050663          	beqz	a0,80002260 <kfork+0x108>
    80002178:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000217a:	048ab603          	ld	a2,72(s5)
    8000217e:	692c                	ld	a1,80(a0)
    80002180:	050ab503          	ld	a0,80(s5)
    80002184:	9c4ff0ef          	jal	ra,80001348 <uvmcopy>
    80002188:	04054863          	bltz	a0,800021d8 <kfork+0x80>
  np->sz = p->sz;
    8000218c:	048ab783          	ld	a5,72(s5)
    80002190:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80002194:	058ab683          	ld	a3,88(s5)
    80002198:	87b6                	mv	a5,a3
    8000219a:	058a3703          	ld	a4,88(s4)
    8000219e:	12068693          	addi	a3,a3,288
    800021a2:	0007b803          	ld	a6,0(a5)
    800021a6:	6788                	ld	a0,8(a5)
    800021a8:	6b8c                	ld	a1,16(a5)
    800021aa:	6f90                	ld	a2,24(a5)
    800021ac:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    800021b0:	e708                	sd	a0,8(a4)
    800021b2:	eb0c                	sd	a1,16(a4)
    800021b4:	ef10                	sd	a2,24(a4)
    800021b6:	02078793          	addi	a5,a5,32
    800021ba:	02070713          	addi	a4,a4,32
    800021be:	fed792e3          	bne	a5,a3,800021a2 <kfork+0x4a>
  np->trapframe->a0 = 0;
    800021c2:	058a3783          	ld	a5,88(s4)
    800021c6:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    800021ca:	0d0a8493          	addi	s1,s5,208
    800021ce:	0d0a0913          	addi	s2,s4,208
    800021d2:	150a8993          	addi	s3,s5,336
    800021d6:	a829                	j	800021f0 <kfork+0x98>
    freeproc(np);
    800021d8:	8552                	mv	a0,s4
    800021da:	dd1ff0ef          	jal	ra,80001faa <freeproc>
    release(&np->lock);
    800021de:	8552                	mv	a0,s4
    800021e0:	a25fe0ef          	jal	ra,80000c04 <release>
    return -1;
    800021e4:	597d                	li	s2,-1
    800021e6:	a09d                	j	8000224c <kfork+0xf4>
  for(i = 0; i < NOFILE; i++)
    800021e8:	04a1                	addi	s1,s1,8
    800021ea:	0921                	addi	s2,s2,8
    800021ec:	01348963          	beq	s1,s3,800021fe <kfork+0xa6>
    if(p->ofile[i])
    800021f0:	6088                	ld	a0,0(s1)
    800021f2:	d97d                	beqz	a0,800021e8 <kfork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    800021f4:	28e020ef          	jal	ra,80004482 <filedup>
    800021f8:	00a93023          	sd	a0,0(s2)
    800021fc:	b7f5                	j	800021e8 <kfork+0x90>
  np->cwd = idup(p->cwd);
    800021fe:	150ab503          	ld	a0,336(s5)
    80002202:	4a4010ef          	jal	ra,800036a6 <idup>
    80002206:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000220a:	4641                	li	a2,16
    8000220c:	158a8593          	addi	a1,s5,344
    80002210:	158a0513          	addi	a0,s4,344
    80002214:	b73fe0ef          	jal	ra,80000d86 <safestrcpy>
  pid = np->pid;
    80002218:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    8000221c:	8552                	mv	a0,s4
    8000221e:	9e7fe0ef          	jal	ra,80000c04 <release>
  acquire(&wait_lock);
    80002222:	0000e497          	auipc	s1,0xe
    80002226:	abe48493          	addi	s1,s1,-1346 # 8000fce0 <wait_lock>
    8000222a:	8526                	mv	a0,s1
    8000222c:	941fe0ef          	jal	ra,80000b6c <acquire>
  np->parent = p;
    80002230:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80002234:	8526                	mv	a0,s1
    80002236:	9cffe0ef          	jal	ra,80000c04 <release>
  acquire(&np->lock);
    8000223a:	8552                	mv	a0,s4
    8000223c:	931fe0ef          	jal	ra,80000b6c <acquire>
  np->state = RUNNABLE;
    80002240:	478d                	li	a5,3
    80002242:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80002246:	8552                	mv	a0,s4
    80002248:	9bdfe0ef          	jal	ra,80000c04 <release>
}
    8000224c:	854a                	mv	a0,s2
    8000224e:	70e2                	ld	ra,56(sp)
    80002250:	7442                	ld	s0,48(sp)
    80002252:	74a2                	ld	s1,40(sp)
    80002254:	7902                	ld	s2,32(sp)
    80002256:	69e2                	ld	s3,24(sp)
    80002258:	6a42                	ld	s4,16(sp)
    8000225a:	6aa2                	ld	s5,8(sp)
    8000225c:	6121                	addi	sp,sp,64
    8000225e:	8082                	ret
    return -1;
    80002260:	597d                	li	s2,-1
    80002262:	b7ed                	j	8000224c <kfork+0xf4>

0000000080002264 <scheduler>:
{
    80002264:	715d                	addi	sp,sp,-80
    80002266:	e486                	sd	ra,72(sp)
    80002268:	e0a2                	sd	s0,64(sp)
    8000226a:	fc26                	sd	s1,56(sp)
    8000226c:	f84a                	sd	s2,48(sp)
    8000226e:	f44e                	sd	s3,40(sp)
    80002270:	f052                	sd	s4,32(sp)
    80002272:	ec56                	sd	s5,24(sp)
    80002274:	e85a                	sd	s6,16(sp)
    80002276:	e45e                	sd	s7,8(sp)
    80002278:	e062                	sd	s8,0(sp)
    8000227a:	0880                	addi	s0,sp,80
    8000227c:	8792                	mv	a5,tp
  int id = r_tp();
    8000227e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002280:	00779b13          	slli	s6,a5,0x7
    80002284:	0000e717          	auipc	a4,0xe
    80002288:	a4470713          	addi	a4,a4,-1468 # 8000fcc8 <pid_lock>
    8000228c:	975a                	add	a4,a4,s6
    8000228e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80002292:	0000e717          	auipc	a4,0xe
    80002296:	a6e70713          	addi	a4,a4,-1426 # 8000fd00 <cpus+0x8>
    8000229a:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    8000229c:	4c11                	li	s8,4
        c->proc = p;
    8000229e:	079e                	slli	a5,a5,0x7
    800022a0:	0000ea17          	auipc	s4,0xe
    800022a4:	a28a0a13          	addi	s4,s4,-1496 # 8000fcc8 <pid_lock>
    800022a8:	9a3e                	add	s4,s4,a5
        found = 1;
    800022aa:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    800022ac:	00025997          	auipc	s3,0x25
    800022b0:	04c98993          	addi	s3,s3,76 # 800272f8 <tickslock>
    800022b4:	a83d                	j	800022f2 <scheduler+0x8e>
      release(&p->lock);
    800022b6:	8526                	mv	a0,s1
    800022b8:	94dfe0ef          	jal	ra,80000c04 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800022bc:	5c848493          	addi	s1,s1,1480
    800022c0:	03348563          	beq	s1,s3,800022ea <scheduler+0x86>
      acquire(&p->lock);
    800022c4:	8526                	mv	a0,s1
    800022c6:	8a7fe0ef          	jal	ra,80000b6c <acquire>
      if(p->state == RUNNABLE) {
    800022ca:	4c9c                	lw	a5,24(s1)
    800022cc:	ff2795e3          	bne	a5,s2,800022b6 <scheduler+0x52>
        p->state = RUNNING;
    800022d0:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    800022d4:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    800022d8:	06048593          	addi	a1,s1,96
    800022dc:	855a                	mv	a0,s6
    800022de:	5b0000ef          	jal	ra,8000288e <swtch>
        c->proc = 0;
    800022e2:	020a3823          	sd	zero,48(s4)
        found = 1;
    800022e6:	8ade                	mv	s5,s7
    800022e8:	b7f9                	j	800022b6 <scheduler+0x52>
    if(found == 0) {
    800022ea:	000a9463          	bnez	s5,800022f2 <scheduler+0x8e>
      asm volatile("wfi");
    800022ee:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022f2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800022f6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800022fa:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022fe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002302:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002304:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002308:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    8000230a:	0000e497          	auipc	s1,0xe
    8000230e:	dee48493          	addi	s1,s1,-530 # 800100f8 <proc>
      if(p->state == RUNNABLE) {
    80002312:	490d                	li	s2,3
    80002314:	bf45                	j	800022c4 <scheduler+0x60>

0000000080002316 <sched>:
{
    80002316:	7179                	addi	sp,sp,-48
    80002318:	f406                	sd	ra,40(sp)
    8000231a:	f022                	sd	s0,32(sp)
    8000231c:	ec26                	sd	s1,24(sp)
    8000231e:	e84a                	sd	s2,16(sp)
    80002320:	e44e                	sd	s3,8(sp)
    80002322:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002324:	ab7ff0ef          	jal	ra,80001dda <myproc>
    80002328:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000232a:	fd8fe0ef          	jal	ra,80000b02 <holding>
    8000232e:	c92d                	beqz	a0,800023a0 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002330:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002332:	2781                	sext.w	a5,a5
    80002334:	079e                	slli	a5,a5,0x7
    80002336:	0000e717          	auipc	a4,0xe
    8000233a:	99270713          	addi	a4,a4,-1646 # 8000fcc8 <pid_lock>
    8000233e:	97ba                	add	a5,a5,a4
    80002340:	0a87a703          	lw	a4,168(a5)
    80002344:	4785                	li	a5,1
    80002346:	06f71363          	bne	a4,a5,800023ac <sched+0x96>
  if(p->state == RUNNING)
    8000234a:	4c98                	lw	a4,24(s1)
    8000234c:	4791                	li	a5,4
    8000234e:	06f70563          	beq	a4,a5,800023b8 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002352:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002356:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002358:	e7b5                	bnez	a5,800023c4 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000235a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000235c:	0000e917          	auipc	s2,0xe
    80002360:	96c90913          	addi	s2,s2,-1684 # 8000fcc8 <pid_lock>
    80002364:	2781                	sext.w	a5,a5
    80002366:	079e                	slli	a5,a5,0x7
    80002368:	97ca                	add	a5,a5,s2
    8000236a:	0ac7a983          	lw	s3,172(a5)
    8000236e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002370:	2781                	sext.w	a5,a5
    80002372:	079e                	slli	a5,a5,0x7
    80002374:	0000e597          	auipc	a1,0xe
    80002378:	98c58593          	addi	a1,a1,-1652 # 8000fd00 <cpus+0x8>
    8000237c:	95be                	add	a1,a1,a5
    8000237e:	06048513          	addi	a0,s1,96
    80002382:	50c000ef          	jal	ra,8000288e <swtch>
    80002386:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002388:	2781                	sext.w	a5,a5
    8000238a:	079e                	slli	a5,a5,0x7
    8000238c:	97ca                	add	a5,a5,s2
    8000238e:	0b37a623          	sw	s3,172(a5)
}
    80002392:	70a2                	ld	ra,40(sp)
    80002394:	7402                	ld	s0,32(sp)
    80002396:	64e2                	ld	s1,24(sp)
    80002398:	6942                	ld	s2,16(sp)
    8000239a:	69a2                	ld	s3,8(sp)
    8000239c:	6145                	addi	sp,sp,48
    8000239e:	8082                	ret
    panic("sched p->lock");
    800023a0:	00005517          	auipc	a0,0x5
    800023a4:	0a850513          	addi	a0,a0,168 # 80007448 <digits+0x410>
    800023a8:	be2fe0ef          	jal	ra,8000078a <panic>
    panic("sched locks");
    800023ac:	00005517          	auipc	a0,0x5
    800023b0:	0ac50513          	addi	a0,a0,172 # 80007458 <digits+0x420>
    800023b4:	bd6fe0ef          	jal	ra,8000078a <panic>
    panic("sched RUNNING");
    800023b8:	00005517          	auipc	a0,0x5
    800023bc:	0b050513          	addi	a0,a0,176 # 80007468 <digits+0x430>
    800023c0:	bcafe0ef          	jal	ra,8000078a <panic>
    panic("sched interruptible");
    800023c4:	00005517          	auipc	a0,0x5
    800023c8:	0b450513          	addi	a0,a0,180 # 80007478 <digits+0x440>
    800023cc:	bbefe0ef          	jal	ra,8000078a <panic>

00000000800023d0 <yield>:
{
    800023d0:	1101                	addi	sp,sp,-32
    800023d2:	ec06                	sd	ra,24(sp)
    800023d4:	e822                	sd	s0,16(sp)
    800023d6:	e426                	sd	s1,8(sp)
    800023d8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800023da:	a01ff0ef          	jal	ra,80001dda <myproc>
    800023de:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800023e0:	f8cfe0ef          	jal	ra,80000b6c <acquire>
  p->state = RUNNABLE;
    800023e4:	478d                	li	a5,3
    800023e6:	cc9c                	sw	a5,24(s1)
  sched();
    800023e8:	f2fff0ef          	jal	ra,80002316 <sched>
  release(&p->lock);
    800023ec:	8526                	mv	a0,s1
    800023ee:	817fe0ef          	jal	ra,80000c04 <release>
}
    800023f2:	60e2                	ld	ra,24(sp)
    800023f4:	6442                	ld	s0,16(sp)
    800023f6:	64a2                	ld	s1,8(sp)
    800023f8:	6105                	addi	sp,sp,32
    800023fa:	8082                	ret

00000000800023fc <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800023fc:	7179                	addi	sp,sp,-48
    800023fe:	f406                	sd	ra,40(sp)
    80002400:	f022                	sd	s0,32(sp)
    80002402:	ec26                	sd	s1,24(sp)
    80002404:	e84a                	sd	s2,16(sp)
    80002406:	e44e                	sd	s3,8(sp)
    80002408:	1800                	addi	s0,sp,48
    8000240a:	89aa                	mv	s3,a0
    8000240c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000240e:	9cdff0ef          	jal	ra,80001dda <myproc>
    80002412:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002414:	f58fe0ef          	jal	ra,80000b6c <acquire>
  release(lk);
    80002418:	854a                	mv	a0,s2
    8000241a:	feafe0ef          	jal	ra,80000c04 <release>

  // Go to sleep.
  p->chan = chan;
    8000241e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002422:	4789                	li	a5,2
    80002424:	cc9c                	sw	a5,24(s1)

  sched();
    80002426:	ef1ff0ef          	jal	ra,80002316 <sched>

  // Tidy up.
  p->chan = 0;
    8000242a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000242e:	8526                	mv	a0,s1
    80002430:	fd4fe0ef          	jal	ra,80000c04 <release>
  acquire(lk);
    80002434:	854a                	mv	a0,s2
    80002436:	f36fe0ef          	jal	ra,80000b6c <acquire>
}
    8000243a:	70a2                	ld	ra,40(sp)
    8000243c:	7402                	ld	s0,32(sp)
    8000243e:	64e2                	ld	s1,24(sp)
    80002440:	6942                	ld	s2,16(sp)
    80002442:	69a2                	ld	s3,8(sp)
    80002444:	6145                	addi	sp,sp,48
    80002446:	8082                	ret

0000000080002448 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80002448:	7139                	addi	sp,sp,-64
    8000244a:	fc06                	sd	ra,56(sp)
    8000244c:	f822                	sd	s0,48(sp)
    8000244e:	f426                	sd	s1,40(sp)
    80002450:	f04a                	sd	s2,32(sp)
    80002452:	ec4e                	sd	s3,24(sp)
    80002454:	e852                	sd	s4,16(sp)
    80002456:	e456                	sd	s5,8(sp)
    80002458:	0080                	addi	s0,sp,64
    8000245a:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000245c:	0000e497          	auipc	s1,0xe
    80002460:	c9c48493          	addi	s1,s1,-868 # 800100f8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002464:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002466:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002468:	00025917          	auipc	s2,0x25
    8000246c:	e9090913          	addi	s2,s2,-368 # 800272f8 <tickslock>
    80002470:	a801                	j	80002480 <wakeup+0x38>
      }
      release(&p->lock);
    80002472:	8526                	mv	a0,s1
    80002474:	f90fe0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002478:	5c848493          	addi	s1,s1,1480
    8000247c:	03248263          	beq	s1,s2,800024a0 <wakeup+0x58>
    if(p != myproc()){
    80002480:	95bff0ef          	jal	ra,80001dda <myproc>
    80002484:	fea48ae3          	beq	s1,a0,80002478 <wakeup+0x30>
      acquire(&p->lock);
    80002488:	8526                	mv	a0,s1
    8000248a:	ee2fe0ef          	jal	ra,80000b6c <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000248e:	4c9c                	lw	a5,24(s1)
    80002490:	ff3791e3          	bne	a5,s3,80002472 <wakeup+0x2a>
    80002494:	709c                	ld	a5,32(s1)
    80002496:	fd479ee3          	bne	a5,s4,80002472 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000249a:	0154ac23          	sw	s5,24(s1)
    8000249e:	bfd1                	j	80002472 <wakeup+0x2a>
    }
  }
}
    800024a0:	70e2                	ld	ra,56(sp)
    800024a2:	7442                	ld	s0,48(sp)
    800024a4:	74a2                	ld	s1,40(sp)
    800024a6:	7902                	ld	s2,32(sp)
    800024a8:	69e2                	ld	s3,24(sp)
    800024aa:	6a42                	ld	s4,16(sp)
    800024ac:	6aa2                	ld	s5,8(sp)
    800024ae:	6121                	addi	sp,sp,64
    800024b0:	8082                	ret

00000000800024b2 <reparent>:
{
    800024b2:	7179                	addi	sp,sp,-48
    800024b4:	f406                	sd	ra,40(sp)
    800024b6:	f022                	sd	s0,32(sp)
    800024b8:	ec26                	sd	s1,24(sp)
    800024ba:	e84a                	sd	s2,16(sp)
    800024bc:	e44e                	sd	s3,8(sp)
    800024be:	e052                	sd	s4,0(sp)
    800024c0:	1800                	addi	s0,sp,48
    800024c2:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800024c4:	0000e497          	auipc	s1,0xe
    800024c8:	c3448493          	addi	s1,s1,-972 # 800100f8 <proc>
      pp->parent = initproc;
    800024cc:	00005a17          	auipc	s4,0x5
    800024d0:	6f4a0a13          	addi	s4,s4,1780 # 80007bc0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800024d4:	00025997          	auipc	s3,0x25
    800024d8:	e2498993          	addi	s3,s3,-476 # 800272f8 <tickslock>
    800024dc:	a029                	j	800024e6 <reparent+0x34>
    800024de:	5c848493          	addi	s1,s1,1480
    800024e2:	01348b63          	beq	s1,s3,800024f8 <reparent+0x46>
    if(pp->parent == p){
    800024e6:	7c9c                	ld	a5,56(s1)
    800024e8:	ff279be3          	bne	a5,s2,800024de <reparent+0x2c>
      pp->parent = initproc;
    800024ec:	000a3503          	ld	a0,0(s4)
    800024f0:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800024f2:	f57ff0ef          	jal	ra,80002448 <wakeup>
    800024f6:	b7e5                	j	800024de <reparent+0x2c>
}
    800024f8:	70a2                	ld	ra,40(sp)
    800024fa:	7402                	ld	s0,32(sp)
    800024fc:	64e2                	ld	s1,24(sp)
    800024fe:	6942                	ld	s2,16(sp)
    80002500:	69a2                	ld	s3,8(sp)
    80002502:	6a02                	ld	s4,0(sp)
    80002504:	6145                	addi	sp,sp,48
    80002506:	8082                	ret

0000000080002508 <kexit>:
{
    80002508:	7179                	addi	sp,sp,-48
    8000250a:	f406                	sd	ra,40(sp)
    8000250c:	f022                	sd	s0,32(sp)
    8000250e:	ec26                	sd	s1,24(sp)
    80002510:	e84a                	sd	s2,16(sp)
    80002512:	e44e                	sd	s3,8(sp)
    80002514:	e052                	sd	s4,0(sp)
    80002516:	1800                	addi	s0,sp,48
    80002518:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000251a:	8c1ff0ef          	jal	ra,80001dda <myproc>
    8000251e:	89aa                	mv	s3,a0
  if(p == initproc)
    80002520:	00005797          	auipc	a5,0x5
    80002524:	6a07b783          	ld	a5,1696(a5) # 80007bc0 <initproc>
    80002528:	0d050493          	addi	s1,a0,208
    8000252c:	15050913          	addi	s2,a0,336
    80002530:	00a79f63          	bne	a5,a0,8000254e <kexit+0x46>
    panic("init exiting");
    80002534:	00005517          	auipc	a0,0x5
    80002538:	f5c50513          	addi	a0,a0,-164 # 80007490 <digits+0x458>
    8000253c:	a4efe0ef          	jal	ra,8000078a <panic>
      fileclose(f);
    80002540:	789010ef          	jal	ra,800044c8 <fileclose>
      p->ofile[fd] = 0;
    80002544:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002548:	04a1                	addi	s1,s1,8
    8000254a:	01248563          	beq	s1,s2,80002554 <kexit+0x4c>
    if(p->ofile[fd]){
    8000254e:	6088                	ld	a0,0(s1)
    80002550:	f965                	bnez	a0,80002540 <kexit+0x38>
    80002552:	bfdd                	j	80002548 <kexit+0x40>
  begin_op();
    80002554:	367010ef          	jal	ra,800040ba <begin_op>
  iput(p->cwd);
    80002558:	1509b503          	ld	a0,336(s3)
    8000255c:	2fe010ef          	jal	ra,8000385a <iput>
  end_op();
    80002560:	3cb010ef          	jal	ra,8000412a <end_op>
  p->cwd = 0;
    80002564:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002568:	0000d497          	auipc	s1,0xd
    8000256c:	77848493          	addi	s1,s1,1912 # 8000fce0 <wait_lock>
    80002570:	8526                	mv	a0,s1
    80002572:	dfafe0ef          	jal	ra,80000b6c <acquire>
  reparent(p);
    80002576:	854e                	mv	a0,s3
    80002578:	f3bff0ef          	jal	ra,800024b2 <reparent>
  wakeup(p->parent);
    8000257c:	0389b503          	ld	a0,56(s3)
    80002580:	ec9ff0ef          	jal	ra,80002448 <wakeup>
  acquire(&p->lock);
    80002584:	854e                	mv	a0,s3
    80002586:	de6fe0ef          	jal	ra,80000b6c <acquire>
  p->xstate = status;
    8000258a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000258e:	4795                	li	a5,5
    80002590:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002594:	8526                	mv	a0,s1
    80002596:	e6efe0ef          	jal	ra,80000c04 <release>
  sched();
    8000259a:	d7dff0ef          	jal	ra,80002316 <sched>
  panic("zombie exit");
    8000259e:	00005517          	auipc	a0,0x5
    800025a2:	f0250513          	addi	a0,a0,-254 # 800074a0 <digits+0x468>
    800025a6:	9e4fe0ef          	jal	ra,8000078a <panic>

00000000800025aa <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800025aa:	7179                	addi	sp,sp,-48
    800025ac:	f406                	sd	ra,40(sp)
    800025ae:	f022                	sd	s0,32(sp)
    800025b0:	ec26                	sd	s1,24(sp)
    800025b2:	e84a                	sd	s2,16(sp)
    800025b4:	e44e                	sd	s3,8(sp)
    800025b6:	1800                	addi	s0,sp,48
    800025b8:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800025ba:	0000e497          	auipc	s1,0xe
    800025be:	b3e48493          	addi	s1,s1,-1218 # 800100f8 <proc>
    800025c2:	00025997          	auipc	s3,0x25
    800025c6:	d3698993          	addi	s3,s3,-714 # 800272f8 <tickslock>
    acquire(&p->lock);
    800025ca:	8526                	mv	a0,s1
    800025cc:	da0fe0ef          	jal	ra,80000b6c <acquire>
    if(p->pid == pid){
    800025d0:	589c                	lw	a5,48(s1)
    800025d2:	01278b63          	beq	a5,s2,800025e8 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800025d6:	8526                	mv	a0,s1
    800025d8:	e2cfe0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800025dc:	5c848493          	addi	s1,s1,1480
    800025e0:	ff3495e3          	bne	s1,s3,800025ca <kkill+0x20>
  }
  return -1;
    800025e4:	557d                	li	a0,-1
    800025e6:	a819                	j	800025fc <kkill+0x52>
      p->killed = 1;
    800025e8:	4785                	li	a5,1
    800025ea:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800025ec:	4c98                	lw	a4,24(s1)
    800025ee:	4789                	li	a5,2
    800025f0:	00f70d63          	beq	a4,a5,8000260a <kkill+0x60>
      release(&p->lock);
    800025f4:	8526                	mv	a0,s1
    800025f6:	e0efe0ef          	jal	ra,80000c04 <release>
      return 0;
    800025fa:	4501                	li	a0,0
}
    800025fc:	70a2                	ld	ra,40(sp)
    800025fe:	7402                	ld	s0,32(sp)
    80002600:	64e2                	ld	s1,24(sp)
    80002602:	6942                	ld	s2,16(sp)
    80002604:	69a2                	ld	s3,8(sp)
    80002606:	6145                	addi	sp,sp,48
    80002608:	8082                	ret
        p->state = RUNNABLE;
    8000260a:	478d                	li	a5,3
    8000260c:	cc9c                	sw	a5,24(s1)
    8000260e:	b7dd                	j	800025f4 <kkill+0x4a>

0000000080002610 <setkilled>:

void
setkilled(struct proc *p)
{
    80002610:	1101                	addi	sp,sp,-32
    80002612:	ec06                	sd	ra,24(sp)
    80002614:	e822                	sd	s0,16(sp)
    80002616:	e426                	sd	s1,8(sp)
    80002618:	1000                	addi	s0,sp,32
    8000261a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000261c:	d50fe0ef          	jal	ra,80000b6c <acquire>
  p->killed = 1;
    80002620:	4785                	li	a5,1
    80002622:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002624:	8526                	mv	a0,s1
    80002626:	ddefe0ef          	jal	ra,80000c04 <release>
}
    8000262a:	60e2                	ld	ra,24(sp)
    8000262c:	6442                	ld	s0,16(sp)
    8000262e:	64a2                	ld	s1,8(sp)
    80002630:	6105                	addi	sp,sp,32
    80002632:	8082                	ret

0000000080002634 <killed>:

int
killed(struct proc *p)
{
    80002634:	1101                	addi	sp,sp,-32
    80002636:	ec06                	sd	ra,24(sp)
    80002638:	e822                	sd	s0,16(sp)
    8000263a:	e426                	sd	s1,8(sp)
    8000263c:	e04a                	sd	s2,0(sp)
    8000263e:	1000                	addi	s0,sp,32
    80002640:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002642:	d2afe0ef          	jal	ra,80000b6c <acquire>
  k = p->killed;
    80002646:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000264a:	8526                	mv	a0,s1
    8000264c:	db8fe0ef          	jal	ra,80000c04 <release>
  return k;
}
    80002650:	854a                	mv	a0,s2
    80002652:	60e2                	ld	ra,24(sp)
    80002654:	6442                	ld	s0,16(sp)
    80002656:	64a2                	ld	s1,8(sp)
    80002658:	6902                	ld	s2,0(sp)
    8000265a:	6105                	addi	sp,sp,32
    8000265c:	8082                	ret

000000008000265e <kwait>:
{
    8000265e:	715d                	addi	sp,sp,-80
    80002660:	e486                	sd	ra,72(sp)
    80002662:	e0a2                	sd	s0,64(sp)
    80002664:	fc26                	sd	s1,56(sp)
    80002666:	f84a                	sd	s2,48(sp)
    80002668:	f44e                	sd	s3,40(sp)
    8000266a:	f052                	sd	s4,32(sp)
    8000266c:	ec56                	sd	s5,24(sp)
    8000266e:	e85a                	sd	s6,16(sp)
    80002670:	e45e                	sd	s7,8(sp)
    80002672:	e062                	sd	s8,0(sp)
    80002674:	0880                	addi	s0,sp,80
    80002676:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002678:	f62ff0ef          	jal	ra,80001dda <myproc>
    8000267c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000267e:	0000d517          	auipc	a0,0xd
    80002682:	66250513          	addi	a0,a0,1634 # 8000fce0 <wait_lock>
    80002686:	ce6fe0ef          	jal	ra,80000b6c <acquire>
    havekids = 0;
    8000268a:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000268c:	4a15                	li	s4,5
        havekids = 1;
    8000268e:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002690:	00025997          	auipc	s3,0x25
    80002694:	c6898993          	addi	s3,s3,-920 # 800272f8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002698:	0000dc17          	auipc	s8,0xd
    8000269c:	648c0c13          	addi	s8,s8,1608 # 8000fce0 <wait_lock>
    havekids = 0;
    800026a0:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800026a2:	0000e497          	auipc	s1,0xe
    800026a6:	a5648493          	addi	s1,s1,-1450 # 800100f8 <proc>
    800026aa:	a899                	j	80002700 <kwait+0xa2>
          pid = pp->pid;
    800026ac:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800026b0:	000b0c63          	beqz	s6,800026c8 <kwait+0x6a>
    800026b4:	4691                	li	a3,4
    800026b6:	02c48613          	addi	a2,s1,44
    800026ba:	85da                	mv	a1,s6
    800026bc:	05093503          	ld	a0,80(s2)
    800026c0:	c68ff0ef          	jal	ra,80001b28 <copyout>
    800026c4:	00054f63          	bltz	a0,800026e2 <kwait+0x84>
          freeproc(pp);
    800026c8:	8526                	mv	a0,s1
    800026ca:	8e1ff0ef          	jal	ra,80001faa <freeproc>
          release(&pp->lock);
    800026ce:	8526                	mv	a0,s1
    800026d0:	d34fe0ef          	jal	ra,80000c04 <release>
          release(&wait_lock);
    800026d4:	0000d517          	auipc	a0,0xd
    800026d8:	60c50513          	addi	a0,a0,1548 # 8000fce0 <wait_lock>
    800026dc:	d28fe0ef          	jal	ra,80000c04 <release>
          return pid;
    800026e0:	a891                	j	80002734 <kwait+0xd6>
            release(&pp->lock);
    800026e2:	8526                	mv	a0,s1
    800026e4:	d20fe0ef          	jal	ra,80000c04 <release>
            release(&wait_lock);
    800026e8:	0000d517          	auipc	a0,0xd
    800026ec:	5f850513          	addi	a0,a0,1528 # 8000fce0 <wait_lock>
    800026f0:	d14fe0ef          	jal	ra,80000c04 <release>
            return -1;
    800026f4:	59fd                	li	s3,-1
    800026f6:	a83d                	j	80002734 <kwait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800026f8:	5c848493          	addi	s1,s1,1480
    800026fc:	03348063          	beq	s1,s3,8000271c <kwait+0xbe>
      if(pp->parent == p){
    80002700:	7c9c                	ld	a5,56(s1)
    80002702:	ff279be3          	bne	a5,s2,800026f8 <kwait+0x9a>
        acquire(&pp->lock);
    80002706:	8526                	mv	a0,s1
    80002708:	c64fe0ef          	jal	ra,80000b6c <acquire>
        if(pp->state == ZOMBIE){
    8000270c:	4c9c                	lw	a5,24(s1)
    8000270e:	f9478fe3          	beq	a5,s4,800026ac <kwait+0x4e>
        release(&pp->lock);
    80002712:	8526                	mv	a0,s1
    80002714:	cf0fe0ef          	jal	ra,80000c04 <release>
        havekids = 1;
    80002718:	8756                	mv	a4,s5
    8000271a:	bff9                	j	800026f8 <kwait+0x9a>
    if(!havekids || killed(p)){
    8000271c:	c709                	beqz	a4,80002726 <kwait+0xc8>
    8000271e:	854a                	mv	a0,s2
    80002720:	f15ff0ef          	jal	ra,80002634 <killed>
    80002724:	c50d                	beqz	a0,8000274e <kwait+0xf0>
      release(&wait_lock);
    80002726:	0000d517          	auipc	a0,0xd
    8000272a:	5ba50513          	addi	a0,a0,1466 # 8000fce0 <wait_lock>
    8000272e:	cd6fe0ef          	jal	ra,80000c04 <release>
      return -1;
    80002732:	59fd                	li	s3,-1
}
    80002734:	854e                	mv	a0,s3
    80002736:	60a6                	ld	ra,72(sp)
    80002738:	6406                	ld	s0,64(sp)
    8000273a:	74e2                	ld	s1,56(sp)
    8000273c:	7942                	ld	s2,48(sp)
    8000273e:	79a2                	ld	s3,40(sp)
    80002740:	7a02                	ld	s4,32(sp)
    80002742:	6ae2                	ld	s5,24(sp)
    80002744:	6b42                	ld	s6,16(sp)
    80002746:	6ba2                	ld	s7,8(sp)
    80002748:	6c02                	ld	s8,0(sp)
    8000274a:	6161                	addi	sp,sp,80
    8000274c:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000274e:	85e2                	mv	a1,s8
    80002750:	854a                	mv	a0,s2
    80002752:	cabff0ef          	jal	ra,800023fc <sleep>
    havekids = 0;
    80002756:	b7a9                	j	800026a0 <kwait+0x42>

0000000080002758 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002758:	7179                	addi	sp,sp,-48
    8000275a:	f406                	sd	ra,40(sp)
    8000275c:	f022                	sd	s0,32(sp)
    8000275e:	ec26                	sd	s1,24(sp)
    80002760:	e84a                	sd	s2,16(sp)
    80002762:	e44e                	sd	s3,8(sp)
    80002764:	e052                	sd	s4,0(sp)
    80002766:	1800                	addi	s0,sp,48
    80002768:	84aa                	mv	s1,a0
    8000276a:	892e                	mv	s2,a1
    8000276c:	89b2                	mv	s3,a2
    8000276e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002770:	e6aff0ef          	jal	ra,80001dda <myproc>
  if(user_dst){
    80002774:	cc99                	beqz	s1,80002792 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002776:	86d2                	mv	a3,s4
    80002778:	864e                	mv	a2,s3
    8000277a:	85ca                	mv	a1,s2
    8000277c:	6928                	ld	a0,80(a0)
    8000277e:	baaff0ef          	jal	ra,80001b28 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002782:	70a2                	ld	ra,40(sp)
    80002784:	7402                	ld	s0,32(sp)
    80002786:	64e2                	ld	s1,24(sp)
    80002788:	6942                	ld	s2,16(sp)
    8000278a:	69a2                	ld	s3,8(sp)
    8000278c:	6a02                	ld	s4,0(sp)
    8000278e:	6145                	addi	sp,sp,48
    80002790:	8082                	ret
    memmove((char *)dst, src, len);
    80002792:	000a061b          	sext.w	a2,s4
    80002796:	85ce                	mv	a1,s3
    80002798:	854a                	mv	a0,s2
    8000279a:	d02fe0ef          	jal	ra,80000c9c <memmove>
    return 0;
    8000279e:	8526                	mv	a0,s1
    800027a0:	b7cd                	j	80002782 <either_copyout+0x2a>

00000000800027a2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800027a2:	7179                	addi	sp,sp,-48
    800027a4:	f406                	sd	ra,40(sp)
    800027a6:	f022                	sd	s0,32(sp)
    800027a8:	ec26                	sd	s1,24(sp)
    800027aa:	e84a                	sd	s2,16(sp)
    800027ac:	e44e                	sd	s3,8(sp)
    800027ae:	e052                	sd	s4,0(sp)
    800027b0:	1800                	addi	s0,sp,48
    800027b2:	892a                	mv	s2,a0
    800027b4:	84ae                	mv	s1,a1
    800027b6:	89b2                	mv	s3,a2
    800027b8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800027ba:	e20ff0ef          	jal	ra,80001dda <myproc>
  if(user_src){
    800027be:	cc99                	beqz	s1,800027dc <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800027c0:	86d2                	mv	a3,s4
    800027c2:	864e                	mv	a2,s3
    800027c4:	85ca                	mv	a1,s2
    800027c6:	6928                	ld	a0,80(a0)
    800027c8:	c26ff0ef          	jal	ra,80001bee <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800027cc:	70a2                	ld	ra,40(sp)
    800027ce:	7402                	ld	s0,32(sp)
    800027d0:	64e2                	ld	s1,24(sp)
    800027d2:	6942                	ld	s2,16(sp)
    800027d4:	69a2                	ld	s3,8(sp)
    800027d6:	6a02                	ld	s4,0(sp)
    800027d8:	6145                	addi	sp,sp,48
    800027da:	8082                	ret
    memmove(dst, (char*)src, len);
    800027dc:	000a061b          	sext.w	a2,s4
    800027e0:	85ce                	mv	a1,s3
    800027e2:	854a                	mv	a0,s2
    800027e4:	cb8fe0ef          	jal	ra,80000c9c <memmove>
    return 0;
    800027e8:	8526                	mv	a0,s1
    800027ea:	b7cd                	j	800027cc <either_copyin+0x2a>

00000000800027ec <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800027ec:	715d                	addi	sp,sp,-80
    800027ee:	e486                	sd	ra,72(sp)
    800027f0:	e0a2                	sd	s0,64(sp)
    800027f2:	fc26                	sd	s1,56(sp)
    800027f4:	f84a                	sd	s2,48(sp)
    800027f6:	f44e                	sd	s3,40(sp)
    800027f8:	f052                	sd	s4,32(sp)
    800027fa:	ec56                	sd	s5,24(sp)
    800027fc:	e85a                	sd	s6,16(sp)
    800027fe:	e45e                	sd	s7,8(sp)
    80002800:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002802:	00005517          	auipc	a0,0x5
    80002806:	9ee50513          	addi	a0,a0,-1554 # 800071f0 <digits+0x1b8>
    8000280a:	cbbfd0ef          	jal	ra,800004c4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000280e:	0000e497          	auipc	s1,0xe
    80002812:	a4248493          	addi	s1,s1,-1470 # 80010250 <proc+0x158>
    80002816:	00025917          	auipc	s2,0x25
    8000281a:	c3a90913          	addi	s2,s2,-966 # 80027450 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000281e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002820:	00005997          	auipc	s3,0x5
    80002824:	c9098993          	addi	s3,s3,-880 # 800074b0 <digits+0x478>
    printf("%d %s %s", p->pid, state, p->name);
    80002828:	00005a97          	auipc	s5,0x5
    8000282c:	c90a8a93          	addi	s5,s5,-880 # 800074b8 <digits+0x480>
    printf("\n");
    80002830:	00005a17          	auipc	s4,0x5
    80002834:	9c0a0a13          	addi	s4,s4,-1600 # 800071f0 <digits+0x1b8>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002838:	00005b97          	auipc	s7,0x5
    8000283c:	cc0b8b93          	addi	s7,s7,-832 # 800074f8 <states.0>
    80002840:	a829                	j	8000285a <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002842:	ed86a583          	lw	a1,-296(a3)
    80002846:	8556                	mv	a0,s5
    80002848:	c7dfd0ef          	jal	ra,800004c4 <printf>
    printf("\n");
    8000284c:	8552                	mv	a0,s4
    8000284e:	c77fd0ef          	jal	ra,800004c4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002852:	5c848493          	addi	s1,s1,1480
    80002856:	03248163          	beq	s1,s2,80002878 <procdump+0x8c>
    if(p->state == UNUSED)
    8000285a:	86a6                	mv	a3,s1
    8000285c:	ec04a783          	lw	a5,-320(s1)
    80002860:	dbed                	beqz	a5,80002852 <procdump+0x66>
      state = "???";
    80002862:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002864:	fcfb6fe3          	bltu	s6,a5,80002842 <procdump+0x56>
    80002868:	1782                	slli	a5,a5,0x20
    8000286a:	9381                	srli	a5,a5,0x20
    8000286c:	078e                	slli	a5,a5,0x3
    8000286e:	97de                	add	a5,a5,s7
    80002870:	6390                	ld	a2,0(a5)
    80002872:	fa61                	bnez	a2,80002842 <procdump+0x56>
      state = "???";
    80002874:	864e                	mv	a2,s3
    80002876:	b7f1                	j	80002842 <procdump+0x56>
  }
}
    80002878:	60a6                	ld	ra,72(sp)
    8000287a:	6406                	ld	s0,64(sp)
    8000287c:	74e2                	ld	s1,56(sp)
    8000287e:	7942                	ld	s2,48(sp)
    80002880:	79a2                	ld	s3,40(sp)
    80002882:	7a02                	ld	s4,32(sp)
    80002884:	6ae2                	ld	s5,24(sp)
    80002886:	6b42                	ld	s6,16(sp)
    80002888:	6ba2                	ld	s7,8(sp)
    8000288a:	6161                	addi	sp,sp,80
    8000288c:	8082                	ret

000000008000288e <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    8000288e:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002892:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002896:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002898:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    8000289a:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    8000289e:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800028a2:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800028a6:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800028aa:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800028ae:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800028b2:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800028b6:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800028ba:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800028be:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800028c2:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800028c6:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800028ca:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800028cc:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800028ce:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800028d2:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800028d6:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800028da:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800028de:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800028e2:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800028e6:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800028ea:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800028ee:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800028f2:	0685bd83          	ld	s11,104(a1)
        
        ret
    800028f6:	8082                	ret

00000000800028f8 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800028f8:	1141                	addi	sp,sp,-16
    800028fa:	e406                	sd	ra,8(sp)
    800028fc:	e022                	sd	s0,0(sp)
    800028fe:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002900:	00005597          	auipc	a1,0x5
    80002904:	c2858593          	addi	a1,a1,-984 # 80007528 <states.0+0x30>
    80002908:	00025517          	auipc	a0,0x25
    8000290c:	9f050513          	addi	a0,a0,-1552 # 800272f8 <tickslock>
    80002910:	9dcfe0ef          	jal	ra,80000aec <initlock>
}
    80002914:	60a2                	ld	ra,8(sp)
    80002916:	6402                	ld	s0,0(sp)
    80002918:	0141                	addi	sp,sp,16
    8000291a:	8082                	ret

000000008000291c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000291c:	1141                	addi	sp,sp,-16
    8000291e:	e422                	sd	s0,8(sp)
    80002920:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002922:	00003797          	auipc	a5,0x3
    80002926:	dfe78793          	addi	a5,a5,-514 # 80005720 <kernelvec>
    8000292a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000292e:	6422                	ld	s0,8(sp)
    80002930:	0141                	addi	sp,sp,16
    80002932:	8082                	ret

0000000080002934 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002934:	1141                	addi	sp,sp,-16
    80002936:	e406                	sd	ra,8(sp)
    80002938:	e022                	sd	s0,0(sp)
    8000293a:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000293c:	c9eff0ef          	jal	ra,80001dda <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002940:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002944:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002946:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000294a:	04000737          	lui	a4,0x4000
    8000294e:	00003797          	auipc	a5,0x3
    80002952:	6b278793          	addi	a5,a5,1714 # 80006000 <_trampoline>
    80002956:	00003697          	auipc	a3,0x3
    8000295a:	6aa68693          	addi	a3,a3,1706 # 80006000 <_trampoline>
    8000295e:	8f95                	sub	a5,a5,a3
    80002960:	177d                	addi	a4,a4,-1
    80002962:	0732                	slli	a4,a4,0xc
    80002964:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002966:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000296a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000296c:	18002773          	csrr	a4,satp
    80002970:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002972:	6d38                	ld	a4,88(a0)
    80002974:	613c                	ld	a5,64(a0)
    80002976:	6685                	lui	a3,0x1
    80002978:	97b6                	add	a5,a5,a3
    8000297a:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000297c:	6d3c                	ld	a5,88(a0)
    8000297e:	00000717          	auipc	a4,0x0
    80002982:	0f470713          	addi	a4,a4,244 # 80002a72 <usertrap>
    80002986:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002988:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000298a:	8712                	mv	a4,tp
    8000298c:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000298e:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002992:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002996:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000299a:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000299e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029a0:	6f9c                	ld	a5,24(a5)
    800029a2:	14179073          	csrw	sepc,a5
}
    800029a6:	60a2                	ld	ra,8(sp)
    800029a8:	6402                	ld	s0,0(sp)
    800029aa:	0141                	addi	sp,sp,16
    800029ac:	8082                	ret

00000000800029ae <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800029ae:	1101                	addi	sp,sp,-32
    800029b0:	ec06                	sd	ra,24(sp)
    800029b2:	e822                	sd	s0,16(sp)
    800029b4:	e426                	sd	s1,8(sp)
    800029b6:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800029b8:	bf6ff0ef          	jal	ra,80001dae <cpuid>
    800029bc:	cd19                	beqz	a0,800029da <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    800029be:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800029c2:	000f4737          	lui	a4,0xf4
    800029c6:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800029ca:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800029cc:	14d79073          	csrw	0x14d,a5
}
    800029d0:	60e2                	ld	ra,24(sp)
    800029d2:	6442                	ld	s0,16(sp)
    800029d4:	64a2                	ld	s1,8(sp)
    800029d6:	6105                	addi	sp,sp,32
    800029d8:	8082                	ret
    acquire(&tickslock);
    800029da:	00025497          	auipc	s1,0x25
    800029de:	91e48493          	addi	s1,s1,-1762 # 800272f8 <tickslock>
    800029e2:	8526                	mv	a0,s1
    800029e4:	988fe0ef          	jal	ra,80000b6c <acquire>
    ticks++;
    800029e8:	00005517          	auipc	a0,0x5
    800029ec:	1e050513          	addi	a0,a0,480 # 80007bc8 <ticks>
    800029f0:	411c                	lw	a5,0(a0)
    800029f2:	2785                	addiw	a5,a5,1
    800029f4:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800029f6:	a53ff0ef          	jal	ra,80002448 <wakeup>
    release(&tickslock);
    800029fa:	8526                	mv	a0,s1
    800029fc:	a08fe0ef          	jal	ra,80000c04 <release>
    80002a00:	bf7d                	j	800029be <clockintr+0x10>

0000000080002a02 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002a02:	1101                	addi	sp,sp,-32
    80002a04:	ec06                	sd	ra,24(sp)
    80002a06:	e822                	sd	s0,16(sp)
    80002a08:	e426                	sd	s1,8(sp)
    80002a0a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a0c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002a10:	57fd                	li	a5,-1
    80002a12:	17fe                	slli	a5,a5,0x3f
    80002a14:	07a5                	addi	a5,a5,9
    80002a16:	00f70d63          	beq	a4,a5,80002a30 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002a1a:	57fd                	li	a5,-1
    80002a1c:	17fe                	slli	a5,a5,0x3f
    80002a1e:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002a20:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002a22:	04f70463          	beq	a4,a5,80002a6a <devintr+0x68>
  }
}
    80002a26:	60e2                	ld	ra,24(sp)
    80002a28:	6442                	ld	s0,16(sp)
    80002a2a:	64a2                	ld	s1,8(sp)
    80002a2c:	6105                	addi	sp,sp,32
    80002a2e:	8082                	ret
    int irq = plic_claim();
    80002a30:	599020ef          	jal	ra,800057c8 <plic_claim>
    80002a34:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a36:	47a9                	li	a5,10
    80002a38:	02f50363          	beq	a0,a5,80002a5e <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80002a3c:	4785                	li	a5,1
    80002a3e:	02f50363          	beq	a0,a5,80002a64 <devintr+0x62>
    return 1;
    80002a42:	4505                	li	a0,1
    } else if(irq){
    80002a44:	d0ed                	beqz	s1,80002a26 <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a46:	85a6                	mv	a1,s1
    80002a48:	00005517          	auipc	a0,0x5
    80002a4c:	ae850513          	addi	a0,a0,-1304 # 80007530 <states.0+0x38>
    80002a50:	a75fd0ef          	jal	ra,800004c4 <printf>
      plic_complete(irq);
    80002a54:	8526                	mv	a0,s1
    80002a56:	593020ef          	jal	ra,800057e8 <plic_complete>
    return 1;
    80002a5a:	4505                	li	a0,1
    80002a5c:	b7e9                	j	80002a26 <devintr+0x24>
      uartintr();
    80002a5e:	efbfd0ef          	jal	ra,80000958 <uartintr>
    80002a62:	bfcd                	j	80002a54 <devintr+0x52>
      virtio_disk_intr();
    80002a64:	1f4030ef          	jal	ra,80005c58 <virtio_disk_intr>
    80002a68:	b7f5                	j	80002a54 <devintr+0x52>
    clockintr();
    80002a6a:	f45ff0ef          	jal	ra,800029ae <clockintr>
    return 2;
    80002a6e:	4509                	li	a0,2
    80002a70:	bf5d                	j	80002a26 <devintr+0x24>

0000000080002a72 <usertrap>:
{
    80002a72:	1101                	addi	sp,sp,-32
    80002a74:	ec06                	sd	ra,24(sp)
    80002a76:	e822                	sd	s0,16(sp)
    80002a78:	e426                	sd	s1,8(sp)
    80002a7a:	e04a                	sd	s2,0(sp)
    80002a7c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a7e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002a82:	1007f793          	andi	a5,a5,256
    80002a86:	efad                	bnez	a5,80002b00 <usertrap+0x8e>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a88:	00003797          	auipc	a5,0x3
    80002a8c:	c9878793          	addi	a5,a5,-872 # 80005720 <kernelvec>
    80002a90:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a94:	b46ff0ef          	jal	ra,80001dda <myproc>
    80002a98:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a9a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a9c:	14102773          	csrr	a4,sepc
    80002aa0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002aa2:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002aa6:	47a1                	li	a5,8
    80002aa8:	06f70263          	beq	a4,a5,80002b0c <usertrap+0x9a>
  } else if((which_dev = devintr()) != 0){
    80002aac:	f57ff0ef          	jal	ra,80002a02 <devintr>
    80002ab0:	892a                	mv	s2,a0
    80002ab2:	ed4d                	bnez	a0,80002b6c <usertrap+0xfa>
    80002ab4:	14202773          	csrr	a4,scause
  } else if((r_scause() == 12 || r_scause() == 13 || r_scause() == 15) &&
    80002ab8:	47b1                	li	a5,12
    80002aba:	08f70d63          	beq	a4,a5,80002b54 <usertrap+0xe2>
    80002abe:	14202773          	csrr	a4,scause
    80002ac2:	47b5                	li	a5,13
    80002ac4:	08f70863          	beq	a4,a5,80002b54 <usertrap+0xe2>
    80002ac8:	14202773          	csrr	a4,scause
    80002acc:	47bd                	li	a5,15
    80002ace:	08f70363          	beq	a4,a5,80002b54 <usertrap+0xe2>
    80002ad2:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002ad6:	5890                	lw	a2,48(s1)
    80002ad8:	00005517          	auipc	a0,0x5
    80002adc:	a9850513          	addi	a0,a0,-1384 # 80007570 <states.0+0x78>
    80002ae0:	9e5fd0ef          	jal	ra,800004c4 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ae4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ae8:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002aec:	00005517          	auipc	a0,0x5
    80002af0:	ab450513          	addi	a0,a0,-1356 # 800075a0 <states.0+0xa8>
    80002af4:	9d1fd0ef          	jal	ra,800004c4 <printf>
    setkilled(p);
    80002af8:	8526                	mv	a0,s1
    80002afa:	b17ff0ef          	jal	ra,80002610 <setkilled>
    80002afe:	a035                	j	80002b2a <usertrap+0xb8>
    panic("usertrap: not from user mode");
    80002b00:	00005517          	auipc	a0,0x5
    80002b04:	a5050513          	addi	a0,a0,-1456 # 80007550 <states.0+0x58>
    80002b08:	c83fd0ef          	jal	ra,8000078a <panic>
    if(killed(p))
    80002b0c:	b29ff0ef          	jal	ra,80002634 <killed>
    80002b10:	ed15                	bnez	a0,80002b4c <usertrap+0xda>
    p->trapframe->epc += 4;
    80002b12:	6cb8                	ld	a4,88(s1)
    80002b14:	6f1c                	ld	a5,24(a4)
    80002b16:	0791                	addi	a5,a5,4
    80002b18:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b1a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b1e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b22:	10079073          	csrw	sstatus,a5
    syscall();
    80002b26:	246000ef          	jal	ra,80002d6c <syscall>
  if(killed(p))
    80002b2a:	8526                	mv	a0,s1
    80002b2c:	b09ff0ef          	jal	ra,80002634 <killed>
    80002b30:	e139                	bnez	a0,80002b76 <usertrap+0x104>
  prepare_return();
    80002b32:	e03ff0ef          	jal	ra,80002934 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b36:	68a8                	ld	a0,80(s1)
    80002b38:	8131                	srli	a0,a0,0xc
    80002b3a:	57fd                	li	a5,-1
    80002b3c:	17fe                	slli	a5,a5,0x3f
    80002b3e:	8d5d                	or	a0,a0,a5
}
    80002b40:	60e2                	ld	ra,24(sp)
    80002b42:	6442                	ld	s0,16(sp)
    80002b44:	64a2                	ld	s1,8(sp)
    80002b46:	6902                	ld	s2,0(sp)
    80002b48:	6105                	addi	sp,sp,32
    80002b4a:	8082                	ret
      kexit(-1);
    80002b4c:	557d                	li	a0,-1
    80002b4e:	9bbff0ef          	jal	ra,80002508 <kexit>
    80002b52:	b7c1                	j	80002b12 <usertrap+0xa0>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b54:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b58:	14202673          	csrr	a2,scause
          vmfault(p->pagetable, r_stval(), (r_scause() == 15)? 1 : 0) != 0) {
    80002b5c:	1645                	addi	a2,a2,-15
    80002b5e:	00163613          	seqz	a2,a2
    80002b62:	68a8                	ld	a0,80(s1)
    80002b64:	b01fe0ef          	jal	ra,80001664 <vmfault>
  } else if((r_scause() == 12 || r_scause() == 13 || r_scause() == 15) &&
    80002b68:	f169                	bnez	a0,80002b2a <usertrap+0xb8>
    80002b6a:	b7a5                	j	80002ad2 <usertrap+0x60>
  if(killed(p))
    80002b6c:	8526                	mv	a0,s1
    80002b6e:	ac7ff0ef          	jal	ra,80002634 <killed>
    80002b72:	c511                	beqz	a0,80002b7e <usertrap+0x10c>
    80002b74:	a011                	j	80002b78 <usertrap+0x106>
    80002b76:	4901                	li	s2,0
    kexit(-1);
    80002b78:	557d                	li	a0,-1
    80002b7a:	98fff0ef          	jal	ra,80002508 <kexit>
  if(which_dev == 2)
    80002b7e:	4789                	li	a5,2
    80002b80:	faf919e3          	bne	s2,a5,80002b32 <usertrap+0xc0>
    yield();
    80002b84:	84dff0ef          	jal	ra,800023d0 <yield>
    80002b88:	b76d                	j	80002b32 <usertrap+0xc0>

0000000080002b8a <kerneltrap>:
{
    80002b8a:	7179                	addi	sp,sp,-48
    80002b8c:	f406                	sd	ra,40(sp)
    80002b8e:	f022                	sd	s0,32(sp)
    80002b90:	ec26                	sd	s1,24(sp)
    80002b92:	e84a                	sd	s2,16(sp)
    80002b94:	e44e                	sd	s3,8(sp)
    80002b96:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b98:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b9c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ba0:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002ba4:	1004f793          	andi	a5,s1,256
    80002ba8:	c795                	beqz	a5,80002bd4 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002baa:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002bae:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002bb0:	eb85                	bnez	a5,80002be0 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002bb2:	e51ff0ef          	jal	ra,80002a02 <devintr>
    80002bb6:	c91d                	beqz	a0,80002bec <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002bb8:	4789                	li	a5,2
    80002bba:	04f50a63          	beq	a0,a5,80002c0e <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002bbe:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bc2:	10049073          	csrw	sstatus,s1
}
    80002bc6:	70a2                	ld	ra,40(sp)
    80002bc8:	7402                	ld	s0,32(sp)
    80002bca:	64e2                	ld	s1,24(sp)
    80002bcc:	6942                	ld	s2,16(sp)
    80002bce:	69a2                	ld	s3,8(sp)
    80002bd0:	6145                	addi	sp,sp,48
    80002bd2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002bd4:	00005517          	auipc	a0,0x5
    80002bd8:	9f450513          	addi	a0,a0,-1548 # 800075c8 <states.0+0xd0>
    80002bdc:	baffd0ef          	jal	ra,8000078a <panic>
    panic("kerneltrap: interrupts enabled");
    80002be0:	00005517          	auipc	a0,0x5
    80002be4:	a1050513          	addi	a0,a0,-1520 # 800075f0 <states.0+0xf8>
    80002be8:	ba3fd0ef          	jal	ra,8000078a <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bec:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bf0:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002bf4:	85ce                	mv	a1,s3
    80002bf6:	00005517          	auipc	a0,0x5
    80002bfa:	a1a50513          	addi	a0,a0,-1510 # 80007610 <states.0+0x118>
    80002bfe:	8c7fd0ef          	jal	ra,800004c4 <printf>
    panic("kerneltrap");
    80002c02:	00005517          	auipc	a0,0x5
    80002c06:	a3650513          	addi	a0,a0,-1482 # 80007638 <states.0+0x140>
    80002c0a:	b81fd0ef          	jal	ra,8000078a <panic>
  if(which_dev == 2 && myproc() != 0)
    80002c0e:	9ccff0ef          	jal	ra,80001dda <myproc>
    80002c12:	d555                	beqz	a0,80002bbe <kerneltrap+0x34>
    yield();
    80002c14:	fbcff0ef          	jal	ra,800023d0 <yield>
    80002c18:	b75d                	j	80002bbe <kerneltrap+0x34>

0000000080002c1a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c1a:	1101                	addi	sp,sp,-32
    80002c1c:	ec06                	sd	ra,24(sp)
    80002c1e:	e822                	sd	s0,16(sp)
    80002c20:	e426                	sd	s1,8(sp)
    80002c22:	1000                	addi	s0,sp,32
    80002c24:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c26:	9b4ff0ef          	jal	ra,80001dda <myproc>
  switch (n) {
    80002c2a:	4795                	li	a5,5
    80002c2c:	0497e163          	bltu	a5,s1,80002c6e <argraw+0x54>
    80002c30:	048a                	slli	s1,s1,0x2
    80002c32:	00005717          	auipc	a4,0x5
    80002c36:	a3e70713          	addi	a4,a4,-1474 # 80007670 <states.0+0x178>
    80002c3a:	94ba                	add	s1,s1,a4
    80002c3c:	409c                	lw	a5,0(s1)
    80002c3e:	97ba                	add	a5,a5,a4
    80002c40:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002c42:	6d3c                	ld	a5,88(a0)
    80002c44:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c46:	60e2                	ld	ra,24(sp)
    80002c48:	6442                	ld	s0,16(sp)
    80002c4a:	64a2                	ld	s1,8(sp)
    80002c4c:	6105                	addi	sp,sp,32
    80002c4e:	8082                	ret
    return p->trapframe->a1;
    80002c50:	6d3c                	ld	a5,88(a0)
    80002c52:	7fa8                	ld	a0,120(a5)
    80002c54:	bfcd                	j	80002c46 <argraw+0x2c>
    return p->trapframe->a2;
    80002c56:	6d3c                	ld	a5,88(a0)
    80002c58:	63c8                	ld	a0,128(a5)
    80002c5a:	b7f5                	j	80002c46 <argraw+0x2c>
    return p->trapframe->a3;
    80002c5c:	6d3c                	ld	a5,88(a0)
    80002c5e:	67c8                	ld	a0,136(a5)
    80002c60:	b7dd                	j	80002c46 <argraw+0x2c>
    return p->trapframe->a4;
    80002c62:	6d3c                	ld	a5,88(a0)
    80002c64:	6bc8                	ld	a0,144(a5)
    80002c66:	b7c5                	j	80002c46 <argraw+0x2c>
    return p->trapframe->a5;
    80002c68:	6d3c                	ld	a5,88(a0)
    80002c6a:	6fc8                	ld	a0,152(a5)
    80002c6c:	bfe9                	j	80002c46 <argraw+0x2c>
  panic("argraw");
    80002c6e:	00005517          	auipc	a0,0x5
    80002c72:	9da50513          	addi	a0,a0,-1574 # 80007648 <states.0+0x150>
    80002c76:	b15fd0ef          	jal	ra,8000078a <panic>

0000000080002c7a <fetchaddr>:
{
    80002c7a:	1101                	addi	sp,sp,-32
    80002c7c:	ec06                	sd	ra,24(sp)
    80002c7e:	e822                	sd	s0,16(sp)
    80002c80:	e426                	sd	s1,8(sp)
    80002c82:	e04a                	sd	s2,0(sp)
    80002c84:	1000                	addi	s0,sp,32
    80002c86:	84aa                	mv	s1,a0
    80002c88:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c8a:	950ff0ef          	jal	ra,80001dda <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002c8e:	653c                	ld	a5,72(a0)
    80002c90:	02f4f663          	bgeu	s1,a5,80002cbc <fetchaddr+0x42>
    80002c94:	00848713          	addi	a4,s1,8
    80002c98:	02e7e463          	bltu	a5,a4,80002cc0 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002c9c:	46a1                	li	a3,8
    80002c9e:	8626                	mv	a2,s1
    80002ca0:	85ca                	mv	a1,s2
    80002ca2:	6928                	ld	a0,80(a0)
    80002ca4:	f4bfe0ef          	jal	ra,80001bee <copyin>
    80002ca8:	00a03533          	snez	a0,a0
    80002cac:	40a00533          	neg	a0,a0
}
    80002cb0:	60e2                	ld	ra,24(sp)
    80002cb2:	6442                	ld	s0,16(sp)
    80002cb4:	64a2                	ld	s1,8(sp)
    80002cb6:	6902                	ld	s2,0(sp)
    80002cb8:	6105                	addi	sp,sp,32
    80002cba:	8082                	ret
    return -1;
    80002cbc:	557d                	li	a0,-1
    80002cbe:	bfcd                	j	80002cb0 <fetchaddr+0x36>
    80002cc0:	557d                	li	a0,-1
    80002cc2:	b7fd                	j	80002cb0 <fetchaddr+0x36>

0000000080002cc4 <fetchstr>:
{
    80002cc4:	7179                	addi	sp,sp,-48
    80002cc6:	f406                	sd	ra,40(sp)
    80002cc8:	f022                	sd	s0,32(sp)
    80002cca:	ec26                	sd	s1,24(sp)
    80002ccc:	e84a                	sd	s2,16(sp)
    80002cce:	e44e                	sd	s3,8(sp)
    80002cd0:	1800                	addi	s0,sp,48
    80002cd2:	892a                	mv	s2,a0
    80002cd4:	84ae                	mv	s1,a1
    80002cd6:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002cd8:	902ff0ef          	jal	ra,80001dda <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002cdc:	86ce                	mv	a3,s3
    80002cde:	864a                	mv	a2,s2
    80002ce0:	85a6                	mv	a1,s1
    80002ce2:	6928                	ld	a0,80(a0)
    80002ce4:	f2cfe0ef          	jal	ra,80001410 <copyinstr>
    80002ce8:	00054c63          	bltz	a0,80002d00 <fetchstr+0x3c>
  return strlen(buf);
    80002cec:	8526                	mv	a0,s1
    80002cee:	8cafe0ef          	jal	ra,80000db8 <strlen>
}
    80002cf2:	70a2                	ld	ra,40(sp)
    80002cf4:	7402                	ld	s0,32(sp)
    80002cf6:	64e2                	ld	s1,24(sp)
    80002cf8:	6942                	ld	s2,16(sp)
    80002cfa:	69a2                	ld	s3,8(sp)
    80002cfc:	6145                	addi	sp,sp,48
    80002cfe:	8082                	ret
    return -1;
    80002d00:	557d                	li	a0,-1
    80002d02:	bfc5                	j	80002cf2 <fetchstr+0x2e>

0000000080002d04 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002d04:	1101                	addi	sp,sp,-32
    80002d06:	ec06                	sd	ra,24(sp)
    80002d08:	e822                	sd	s0,16(sp)
    80002d0a:	e426                	sd	s1,8(sp)
    80002d0c:	1000                	addi	s0,sp,32
    80002d0e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d10:	f0bff0ef          	jal	ra,80002c1a <argraw>
    80002d14:	c088                	sw	a0,0(s1)
}
    80002d16:	60e2                	ld	ra,24(sp)
    80002d18:	6442                	ld	s0,16(sp)
    80002d1a:	64a2                	ld	s1,8(sp)
    80002d1c:	6105                	addi	sp,sp,32
    80002d1e:	8082                	ret

0000000080002d20 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002d20:	1101                	addi	sp,sp,-32
    80002d22:	ec06                	sd	ra,24(sp)
    80002d24:	e822                	sd	s0,16(sp)
    80002d26:	e426                	sd	s1,8(sp)
    80002d28:	1000                	addi	s0,sp,32
    80002d2a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d2c:	eefff0ef          	jal	ra,80002c1a <argraw>
    80002d30:	e088                	sd	a0,0(s1)
}
    80002d32:	60e2                	ld	ra,24(sp)
    80002d34:	6442                	ld	s0,16(sp)
    80002d36:	64a2                	ld	s1,8(sp)
    80002d38:	6105                	addi	sp,sp,32
    80002d3a:	8082                	ret

0000000080002d3c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d3c:	7179                	addi	sp,sp,-48
    80002d3e:	f406                	sd	ra,40(sp)
    80002d40:	f022                	sd	s0,32(sp)
    80002d42:	ec26                	sd	s1,24(sp)
    80002d44:	e84a                	sd	s2,16(sp)
    80002d46:	1800                	addi	s0,sp,48
    80002d48:	84ae                	mv	s1,a1
    80002d4a:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002d4c:	fd840593          	addi	a1,s0,-40
    80002d50:	fd1ff0ef          	jal	ra,80002d20 <argaddr>
  return fetchstr(addr, buf, max);
    80002d54:	864a                	mv	a2,s2
    80002d56:	85a6                	mv	a1,s1
    80002d58:	fd843503          	ld	a0,-40(s0)
    80002d5c:	f69ff0ef          	jal	ra,80002cc4 <fetchstr>
}
    80002d60:	70a2                	ld	ra,40(sp)
    80002d62:	7402                	ld	s0,32(sp)
    80002d64:	64e2                	ld	s1,24(sp)
    80002d66:	6942                	ld	s2,16(sp)
    80002d68:	6145                	addi	sp,sp,48
    80002d6a:	8082                	ret

0000000080002d6c <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002d6c:	1101                	addi	sp,sp,-32
    80002d6e:	ec06                	sd	ra,24(sp)
    80002d70:	e822                	sd	s0,16(sp)
    80002d72:	e426                	sd	s1,8(sp)
    80002d74:	e04a                	sd	s2,0(sp)
    80002d76:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002d78:	862ff0ef          	jal	ra,80001dda <myproc>
    80002d7c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002d7e:	05853903          	ld	s2,88(a0)
    80002d82:	0a893783          	ld	a5,168(s2)
    80002d86:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002d8a:	37fd                	addiw	a5,a5,-1
    80002d8c:	4751                	li	a4,20
    80002d8e:	00f76f63          	bltu	a4,a5,80002dac <syscall+0x40>
    80002d92:	00369713          	slli	a4,a3,0x3
    80002d96:	00005797          	auipc	a5,0x5
    80002d9a:	8f278793          	addi	a5,a5,-1806 # 80007688 <syscalls>
    80002d9e:	97ba                	add	a5,a5,a4
    80002da0:	639c                	ld	a5,0(a5)
    80002da2:	c789                	beqz	a5,80002dac <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002da4:	9782                	jalr	a5
    80002da6:	06a93823          	sd	a0,112(s2)
    80002daa:	a829                	j	80002dc4 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002dac:	15848613          	addi	a2,s1,344
    80002db0:	588c                	lw	a1,48(s1)
    80002db2:	00005517          	auipc	a0,0x5
    80002db6:	89e50513          	addi	a0,a0,-1890 # 80007650 <states.0+0x158>
    80002dba:	f0afd0ef          	jal	ra,800004c4 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002dbe:	6cbc                	ld	a5,88(s1)
    80002dc0:	577d                	li	a4,-1
    80002dc2:	fbb8                	sd	a4,112(a5)
  }
}
    80002dc4:	60e2                	ld	ra,24(sp)
    80002dc6:	6442                	ld	s0,16(sp)
    80002dc8:	64a2                	ld	s1,8(sp)
    80002dca:	6902                	ld	s2,0(sp)
    80002dcc:	6105                	addi	sp,sp,32
    80002dce:	8082                	ret

0000000080002dd0 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002dd0:	1101                	addi	sp,sp,-32
    80002dd2:	ec06                	sd	ra,24(sp)
    80002dd4:	e822                	sd	s0,16(sp)
    80002dd6:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002dd8:	fec40593          	addi	a1,s0,-20
    80002ddc:	4501                	li	a0,0
    80002dde:	f27ff0ef          	jal	ra,80002d04 <argint>
  kexit(n);
    80002de2:	fec42503          	lw	a0,-20(s0)
    80002de6:	f22ff0ef          	jal	ra,80002508 <kexit>
  return 0;  // not reached
}
    80002dea:	4501                	li	a0,0
    80002dec:	60e2                	ld	ra,24(sp)
    80002dee:	6442                	ld	s0,16(sp)
    80002df0:	6105                	addi	sp,sp,32
    80002df2:	8082                	ret

0000000080002df4 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002df4:	1141                	addi	sp,sp,-16
    80002df6:	e406                	sd	ra,8(sp)
    80002df8:	e022                	sd	s0,0(sp)
    80002dfa:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002dfc:	fdffe0ef          	jal	ra,80001dda <myproc>
}
    80002e00:	5908                	lw	a0,48(a0)
    80002e02:	60a2                	ld	ra,8(sp)
    80002e04:	6402                	ld	s0,0(sp)
    80002e06:	0141                	addi	sp,sp,16
    80002e08:	8082                	ret

0000000080002e0a <sys_fork>:

uint64
sys_fork(void)
{
    80002e0a:	1141                	addi	sp,sp,-16
    80002e0c:	e406                	sd	ra,8(sp)
    80002e0e:	e022                	sd	s0,0(sp)
    80002e10:	0800                	addi	s0,sp,16
  return kfork();
    80002e12:	b46ff0ef          	jal	ra,80002158 <kfork>
}
    80002e16:	60a2                	ld	ra,8(sp)
    80002e18:	6402                	ld	s0,0(sp)
    80002e1a:	0141                	addi	sp,sp,16
    80002e1c:	8082                	ret

0000000080002e1e <sys_wait>:

uint64
sys_wait(void)
{
    80002e1e:	1101                	addi	sp,sp,-32
    80002e20:	ec06                	sd	ra,24(sp)
    80002e22:	e822                	sd	s0,16(sp)
    80002e24:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002e26:	fe840593          	addi	a1,s0,-24
    80002e2a:	4501                	li	a0,0
    80002e2c:	ef5ff0ef          	jal	ra,80002d20 <argaddr>
  return kwait(p);
    80002e30:	fe843503          	ld	a0,-24(s0)
    80002e34:	82bff0ef          	jal	ra,8000265e <kwait>
}
    80002e38:	60e2                	ld	ra,24(sp)
    80002e3a:	6442                	ld	s0,16(sp)
    80002e3c:	6105                	addi	sp,sp,32
    80002e3e:	8082                	ret

0000000080002e40 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002e40:	7179                	addi	sp,sp,-48
    80002e42:	f406                	sd	ra,40(sp)
    80002e44:	f022                	sd	s0,32(sp)
    80002e46:	ec26                	sd	s1,24(sp)
    80002e48:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002e4a:	fd840593          	addi	a1,s0,-40
    80002e4e:	4501                	li	a0,0
    80002e50:	eb5ff0ef          	jal	ra,80002d04 <argint>
  argint(1, &t);
    80002e54:	fdc40593          	addi	a1,s0,-36
    80002e58:	4505                	li	a0,1
    80002e5a:	eabff0ef          	jal	ra,80002d04 <argint>
  addr = myproc()->sz;
    80002e5e:	f7dfe0ef          	jal	ra,80001dda <myproc>
    80002e62:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002e64:	fdc42703          	lw	a4,-36(s0)
    80002e68:	4785                	li	a5,1
    80002e6a:	02f70163          	beq	a4,a5,80002e8c <sys_sbrk+0x4c>
    80002e6e:	fd842783          	lw	a5,-40(s0)
    80002e72:	0007cd63          	bltz	a5,80002e8c <sys_sbrk+0x4c>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002e76:	97a6                	add	a5,a5,s1
    80002e78:	0297e863          	bltu	a5,s1,80002ea8 <sys_sbrk+0x68>
      return -1;
    myproc()->sz += n;
    80002e7c:	f5ffe0ef          	jal	ra,80001dda <myproc>
    80002e80:	fd842703          	lw	a4,-40(s0)
    80002e84:	653c                	ld	a5,72(a0)
    80002e86:	97ba                	add	a5,a5,a4
    80002e88:	e53c                	sd	a5,72(a0)
    80002e8a:	a039                	j	80002e98 <sys_sbrk+0x58>
    if(growproc(n) < 0) {
    80002e8c:	fd842503          	lw	a0,-40(s0)
    80002e90:	a78ff0ef          	jal	ra,80002108 <growproc>
    80002e94:	00054863          	bltz	a0,80002ea4 <sys_sbrk+0x64>
  }
  return addr;
}
    80002e98:	8526                	mv	a0,s1
    80002e9a:	70a2                	ld	ra,40(sp)
    80002e9c:	7402                	ld	s0,32(sp)
    80002e9e:	64e2                	ld	s1,24(sp)
    80002ea0:	6145                	addi	sp,sp,48
    80002ea2:	8082                	ret
      return -1;
    80002ea4:	54fd                	li	s1,-1
    80002ea6:	bfcd                	j	80002e98 <sys_sbrk+0x58>
      return -1;
    80002ea8:	54fd                	li	s1,-1
    80002eaa:	b7fd                	j	80002e98 <sys_sbrk+0x58>

0000000080002eac <sys_pause>:

uint64
sys_pause(void)
{
    80002eac:	7139                	addi	sp,sp,-64
    80002eae:	fc06                	sd	ra,56(sp)
    80002eb0:	f822                	sd	s0,48(sp)
    80002eb2:	f426                	sd	s1,40(sp)
    80002eb4:	f04a                	sd	s2,32(sp)
    80002eb6:	ec4e                	sd	s3,24(sp)
    80002eb8:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002eba:	fcc40593          	addi	a1,s0,-52
    80002ebe:	4501                	li	a0,0
    80002ec0:	e45ff0ef          	jal	ra,80002d04 <argint>
  if(n < 0)
    80002ec4:	fcc42783          	lw	a5,-52(s0)
    80002ec8:	0607c563          	bltz	a5,80002f32 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002ecc:	00024517          	auipc	a0,0x24
    80002ed0:	42c50513          	addi	a0,a0,1068 # 800272f8 <tickslock>
    80002ed4:	c99fd0ef          	jal	ra,80000b6c <acquire>
  ticks0 = ticks;
    80002ed8:	00005917          	auipc	s2,0x5
    80002edc:	cf092903          	lw	s2,-784(s2) # 80007bc8 <ticks>
  while(ticks - ticks0 < n){
    80002ee0:	fcc42783          	lw	a5,-52(s0)
    80002ee4:	cb8d                	beqz	a5,80002f16 <sys_pause+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002ee6:	00024997          	auipc	s3,0x24
    80002eea:	41298993          	addi	s3,s3,1042 # 800272f8 <tickslock>
    80002eee:	00005497          	auipc	s1,0x5
    80002ef2:	cda48493          	addi	s1,s1,-806 # 80007bc8 <ticks>
    if(killed(myproc())){
    80002ef6:	ee5fe0ef          	jal	ra,80001dda <myproc>
    80002efa:	f3aff0ef          	jal	ra,80002634 <killed>
    80002efe:	ed0d                	bnez	a0,80002f38 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002f00:	85ce                	mv	a1,s3
    80002f02:	8526                	mv	a0,s1
    80002f04:	cf8ff0ef          	jal	ra,800023fc <sleep>
  while(ticks - ticks0 < n){
    80002f08:	409c                	lw	a5,0(s1)
    80002f0a:	412787bb          	subw	a5,a5,s2
    80002f0e:	fcc42703          	lw	a4,-52(s0)
    80002f12:	fee7e2e3          	bltu	a5,a4,80002ef6 <sys_pause+0x4a>
  }
  release(&tickslock);
    80002f16:	00024517          	auipc	a0,0x24
    80002f1a:	3e250513          	addi	a0,a0,994 # 800272f8 <tickslock>
    80002f1e:	ce7fd0ef          	jal	ra,80000c04 <release>
  return 0;
    80002f22:	4501                	li	a0,0
}
    80002f24:	70e2                	ld	ra,56(sp)
    80002f26:	7442                	ld	s0,48(sp)
    80002f28:	74a2                	ld	s1,40(sp)
    80002f2a:	7902                	ld	s2,32(sp)
    80002f2c:	69e2                	ld	s3,24(sp)
    80002f2e:	6121                	addi	sp,sp,64
    80002f30:	8082                	ret
    n = 0;
    80002f32:	fc042623          	sw	zero,-52(s0)
    80002f36:	bf59                	j	80002ecc <sys_pause+0x20>
      release(&tickslock);
    80002f38:	00024517          	auipc	a0,0x24
    80002f3c:	3c050513          	addi	a0,a0,960 # 800272f8 <tickslock>
    80002f40:	cc5fd0ef          	jal	ra,80000c04 <release>
      return -1;
    80002f44:	557d                	li	a0,-1
    80002f46:	bff9                	j	80002f24 <sys_pause+0x78>

0000000080002f48 <sys_kill>:

uint64
sys_kill(void)
{
    80002f48:	1101                	addi	sp,sp,-32
    80002f4a:	ec06                	sd	ra,24(sp)
    80002f4c:	e822                	sd	s0,16(sp)
    80002f4e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002f50:	fec40593          	addi	a1,s0,-20
    80002f54:	4501                	li	a0,0
    80002f56:	dafff0ef          	jal	ra,80002d04 <argint>
  return kkill(pid);
    80002f5a:	fec42503          	lw	a0,-20(s0)
    80002f5e:	e4cff0ef          	jal	ra,800025aa <kkill>
}
    80002f62:	60e2                	ld	ra,24(sp)
    80002f64:	6442                	ld	s0,16(sp)
    80002f66:	6105                	addi	sp,sp,32
    80002f68:	8082                	ret

0000000080002f6a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002f6a:	1101                	addi	sp,sp,-32
    80002f6c:	ec06                	sd	ra,24(sp)
    80002f6e:	e822                	sd	s0,16(sp)
    80002f70:	e426                	sd	s1,8(sp)
    80002f72:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002f74:	00024517          	auipc	a0,0x24
    80002f78:	38450513          	addi	a0,a0,900 # 800272f8 <tickslock>
    80002f7c:	bf1fd0ef          	jal	ra,80000b6c <acquire>
  xticks = ticks;
    80002f80:	00005497          	auipc	s1,0x5
    80002f84:	c484a483          	lw	s1,-952(s1) # 80007bc8 <ticks>
  release(&tickslock);
    80002f88:	00024517          	auipc	a0,0x24
    80002f8c:	37050513          	addi	a0,a0,880 # 800272f8 <tickslock>
    80002f90:	c75fd0ef          	jal	ra,80000c04 <release>
  return xticks;
}
    80002f94:	02049513          	slli	a0,s1,0x20
    80002f98:	9101                	srli	a0,a0,0x20
    80002f9a:	60e2                	ld	ra,24(sp)
    80002f9c:	6442                	ld	s0,16(sp)
    80002f9e:	64a2                	ld	s1,8(sp)
    80002fa0:	6105                	addi	sp,sp,32
    80002fa2:	8082                	ret

0000000080002fa4 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002fa4:	7179                	addi	sp,sp,-48
    80002fa6:	f406                	sd	ra,40(sp)
    80002fa8:	f022                	sd	s0,32(sp)
    80002faa:	ec26                	sd	s1,24(sp)
    80002fac:	e84a                	sd	s2,16(sp)
    80002fae:	e44e                	sd	s3,8(sp)
    80002fb0:	e052                	sd	s4,0(sp)
    80002fb2:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002fb4:	00004597          	auipc	a1,0x4
    80002fb8:	78458593          	addi	a1,a1,1924 # 80007738 <syscalls+0xb0>
    80002fbc:	00024517          	auipc	a0,0x24
    80002fc0:	35450513          	addi	a0,a0,852 # 80027310 <bcache>
    80002fc4:	b29fd0ef          	jal	ra,80000aec <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002fc8:	0002c797          	auipc	a5,0x2c
    80002fcc:	34878793          	addi	a5,a5,840 # 8002f310 <bcache+0x8000>
    80002fd0:	0002c717          	auipc	a4,0x2c
    80002fd4:	5a870713          	addi	a4,a4,1448 # 8002f578 <bcache+0x8268>
    80002fd8:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002fdc:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002fe0:	00024497          	auipc	s1,0x24
    80002fe4:	34848493          	addi	s1,s1,840 # 80027328 <bcache+0x18>
    b->next = bcache.head.next;
    80002fe8:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002fea:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002fec:	00004a17          	auipc	s4,0x4
    80002ff0:	754a0a13          	addi	s4,s4,1876 # 80007740 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002ff4:	2b893783          	ld	a5,696(s2)
    80002ff8:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002ffa:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002ffe:	85d2                	mv	a1,s4
    80003000:	01048513          	addi	a0,s1,16
    80003004:	2fe010ef          	jal	ra,80004302 <initsleeplock>
    bcache.head.next->prev = b;
    80003008:	2b893783          	ld	a5,696(s2)
    8000300c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000300e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003012:	45848493          	addi	s1,s1,1112
    80003016:	fd349fe3          	bne	s1,s3,80002ff4 <binit+0x50>
  }
}
    8000301a:	70a2                	ld	ra,40(sp)
    8000301c:	7402                	ld	s0,32(sp)
    8000301e:	64e2                	ld	s1,24(sp)
    80003020:	6942                	ld	s2,16(sp)
    80003022:	69a2                	ld	s3,8(sp)
    80003024:	6a02                	ld	s4,0(sp)
    80003026:	6145                	addi	sp,sp,48
    80003028:	8082                	ret

000000008000302a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000302a:	7179                	addi	sp,sp,-48
    8000302c:	f406                	sd	ra,40(sp)
    8000302e:	f022                	sd	s0,32(sp)
    80003030:	ec26                	sd	s1,24(sp)
    80003032:	e84a                	sd	s2,16(sp)
    80003034:	e44e                	sd	s3,8(sp)
    80003036:	1800                	addi	s0,sp,48
    80003038:	892a                	mv	s2,a0
    8000303a:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000303c:	00024517          	auipc	a0,0x24
    80003040:	2d450513          	addi	a0,a0,724 # 80027310 <bcache>
    80003044:	b29fd0ef          	jal	ra,80000b6c <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003048:	0002c497          	auipc	s1,0x2c
    8000304c:	5804b483          	ld	s1,1408(s1) # 8002f5c8 <bcache+0x82b8>
    80003050:	0002c797          	auipc	a5,0x2c
    80003054:	52878793          	addi	a5,a5,1320 # 8002f578 <bcache+0x8268>
    80003058:	02f48b63          	beq	s1,a5,8000308e <bread+0x64>
    8000305c:	873e                	mv	a4,a5
    8000305e:	a021                	j	80003066 <bread+0x3c>
    80003060:	68a4                	ld	s1,80(s1)
    80003062:	02e48663          	beq	s1,a4,8000308e <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80003066:	449c                	lw	a5,8(s1)
    80003068:	ff279ce3          	bne	a5,s2,80003060 <bread+0x36>
    8000306c:	44dc                	lw	a5,12(s1)
    8000306e:	ff3799e3          	bne	a5,s3,80003060 <bread+0x36>
      b->refcnt++;
    80003072:	40bc                	lw	a5,64(s1)
    80003074:	2785                	addiw	a5,a5,1
    80003076:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003078:	00024517          	auipc	a0,0x24
    8000307c:	29850513          	addi	a0,a0,664 # 80027310 <bcache>
    80003080:	b85fd0ef          	jal	ra,80000c04 <release>
      acquiresleep(&b->lock);
    80003084:	01048513          	addi	a0,s1,16
    80003088:	2b0010ef          	jal	ra,80004338 <acquiresleep>
      return b;
    8000308c:	a889                	j	800030de <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000308e:	0002c497          	auipc	s1,0x2c
    80003092:	5324b483          	ld	s1,1330(s1) # 8002f5c0 <bcache+0x82b0>
    80003096:	0002c797          	auipc	a5,0x2c
    8000309a:	4e278793          	addi	a5,a5,1250 # 8002f578 <bcache+0x8268>
    8000309e:	00f48863          	beq	s1,a5,800030ae <bread+0x84>
    800030a2:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800030a4:	40bc                	lw	a5,64(s1)
    800030a6:	cb91                	beqz	a5,800030ba <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030a8:	64a4                	ld	s1,72(s1)
    800030aa:	fee49de3          	bne	s1,a4,800030a4 <bread+0x7a>
  panic("bget: no buffers");
    800030ae:	00004517          	auipc	a0,0x4
    800030b2:	69a50513          	addi	a0,a0,1690 # 80007748 <syscalls+0xc0>
    800030b6:	ed4fd0ef          	jal	ra,8000078a <panic>
      b->dev = dev;
    800030ba:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800030be:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800030c2:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800030c6:	4785                	li	a5,1
    800030c8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030ca:	00024517          	auipc	a0,0x24
    800030ce:	24650513          	addi	a0,a0,582 # 80027310 <bcache>
    800030d2:	b33fd0ef          	jal	ra,80000c04 <release>
      acquiresleep(&b->lock);
    800030d6:	01048513          	addi	a0,s1,16
    800030da:	25e010ef          	jal	ra,80004338 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800030de:	409c                	lw	a5,0(s1)
    800030e0:	cb89                	beqz	a5,800030f2 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800030e2:	8526                	mv	a0,s1
    800030e4:	70a2                	ld	ra,40(sp)
    800030e6:	7402                	ld	s0,32(sp)
    800030e8:	64e2                	ld	s1,24(sp)
    800030ea:	6942                	ld	s2,16(sp)
    800030ec:	69a2                	ld	s3,8(sp)
    800030ee:	6145                	addi	sp,sp,48
    800030f0:	8082                	ret
    virtio_disk_rw(b, 0);
    800030f2:	4581                	li	a1,0
    800030f4:	8526                	mv	a0,s1
    800030f6:	147020ef          	jal	ra,80005a3c <virtio_disk_rw>
    b->valid = 1;
    800030fa:	4785                	li	a5,1
    800030fc:	c09c                	sw	a5,0(s1)
  return b;
    800030fe:	b7d5                	j	800030e2 <bread+0xb8>

0000000080003100 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003100:	1101                	addi	sp,sp,-32
    80003102:	ec06                	sd	ra,24(sp)
    80003104:	e822                	sd	s0,16(sp)
    80003106:	e426                	sd	s1,8(sp)
    80003108:	1000                	addi	s0,sp,32
    8000310a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000310c:	0541                	addi	a0,a0,16
    8000310e:	2a8010ef          	jal	ra,800043b6 <holdingsleep>
    80003112:	c911                	beqz	a0,80003126 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003114:	4585                	li	a1,1
    80003116:	8526                	mv	a0,s1
    80003118:	125020ef          	jal	ra,80005a3c <virtio_disk_rw>
}
    8000311c:	60e2                	ld	ra,24(sp)
    8000311e:	6442                	ld	s0,16(sp)
    80003120:	64a2                	ld	s1,8(sp)
    80003122:	6105                	addi	sp,sp,32
    80003124:	8082                	ret
    panic("bwrite");
    80003126:	00004517          	auipc	a0,0x4
    8000312a:	63a50513          	addi	a0,a0,1594 # 80007760 <syscalls+0xd8>
    8000312e:	e5cfd0ef          	jal	ra,8000078a <panic>

0000000080003132 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003132:	1101                	addi	sp,sp,-32
    80003134:	ec06                	sd	ra,24(sp)
    80003136:	e822                	sd	s0,16(sp)
    80003138:	e426                	sd	s1,8(sp)
    8000313a:	e04a                	sd	s2,0(sp)
    8000313c:	1000                	addi	s0,sp,32
    8000313e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003140:	01050913          	addi	s2,a0,16
    80003144:	854a                	mv	a0,s2
    80003146:	270010ef          	jal	ra,800043b6 <holdingsleep>
    8000314a:	c13d                	beqz	a0,800031b0 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    8000314c:	854a                	mv	a0,s2
    8000314e:	230010ef          	jal	ra,8000437e <releasesleep>

  acquire(&bcache.lock);
    80003152:	00024517          	auipc	a0,0x24
    80003156:	1be50513          	addi	a0,a0,446 # 80027310 <bcache>
    8000315a:	a13fd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt--;
    8000315e:	40bc                	lw	a5,64(s1)
    80003160:	37fd                	addiw	a5,a5,-1
    80003162:	0007871b          	sext.w	a4,a5
    80003166:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003168:	eb05                	bnez	a4,80003198 <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000316a:	68bc                	ld	a5,80(s1)
    8000316c:	64b8                	ld	a4,72(s1)
    8000316e:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003170:	64bc                	ld	a5,72(s1)
    80003172:	68b8                	ld	a4,80(s1)
    80003174:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003176:	0002c797          	auipc	a5,0x2c
    8000317a:	19a78793          	addi	a5,a5,410 # 8002f310 <bcache+0x8000>
    8000317e:	2b87b703          	ld	a4,696(a5)
    80003182:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003184:	0002c717          	auipc	a4,0x2c
    80003188:	3f470713          	addi	a4,a4,1012 # 8002f578 <bcache+0x8268>
    8000318c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000318e:	2b87b703          	ld	a4,696(a5)
    80003192:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003194:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003198:	00024517          	auipc	a0,0x24
    8000319c:	17850513          	addi	a0,a0,376 # 80027310 <bcache>
    800031a0:	a65fd0ef          	jal	ra,80000c04 <release>
}
    800031a4:	60e2                	ld	ra,24(sp)
    800031a6:	6442                	ld	s0,16(sp)
    800031a8:	64a2                	ld	s1,8(sp)
    800031aa:	6902                	ld	s2,0(sp)
    800031ac:	6105                	addi	sp,sp,32
    800031ae:	8082                	ret
    panic("brelse");
    800031b0:	00004517          	auipc	a0,0x4
    800031b4:	5b850513          	addi	a0,a0,1464 # 80007768 <syscalls+0xe0>
    800031b8:	dd2fd0ef          	jal	ra,8000078a <panic>

00000000800031bc <bpin>:

void
bpin(struct buf *b) {
    800031bc:	1101                	addi	sp,sp,-32
    800031be:	ec06                	sd	ra,24(sp)
    800031c0:	e822                	sd	s0,16(sp)
    800031c2:	e426                	sd	s1,8(sp)
    800031c4:	1000                	addi	s0,sp,32
    800031c6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800031c8:	00024517          	auipc	a0,0x24
    800031cc:	14850513          	addi	a0,a0,328 # 80027310 <bcache>
    800031d0:	99dfd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt++;
    800031d4:	40bc                	lw	a5,64(s1)
    800031d6:	2785                	addiw	a5,a5,1
    800031d8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031da:	00024517          	auipc	a0,0x24
    800031de:	13650513          	addi	a0,a0,310 # 80027310 <bcache>
    800031e2:	a23fd0ef          	jal	ra,80000c04 <release>
}
    800031e6:	60e2                	ld	ra,24(sp)
    800031e8:	6442                	ld	s0,16(sp)
    800031ea:	64a2                	ld	s1,8(sp)
    800031ec:	6105                	addi	sp,sp,32
    800031ee:	8082                	ret

00000000800031f0 <bunpin>:

void
bunpin(struct buf *b) {
    800031f0:	1101                	addi	sp,sp,-32
    800031f2:	ec06                	sd	ra,24(sp)
    800031f4:	e822                	sd	s0,16(sp)
    800031f6:	e426                	sd	s1,8(sp)
    800031f8:	1000                	addi	s0,sp,32
    800031fa:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800031fc:	00024517          	auipc	a0,0x24
    80003200:	11450513          	addi	a0,a0,276 # 80027310 <bcache>
    80003204:	969fd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt--;
    80003208:	40bc                	lw	a5,64(s1)
    8000320a:	37fd                	addiw	a5,a5,-1
    8000320c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000320e:	00024517          	auipc	a0,0x24
    80003212:	10250513          	addi	a0,a0,258 # 80027310 <bcache>
    80003216:	9effd0ef          	jal	ra,80000c04 <release>
}
    8000321a:	60e2                	ld	ra,24(sp)
    8000321c:	6442                	ld	s0,16(sp)
    8000321e:	64a2                	ld	s1,8(sp)
    80003220:	6105                	addi	sp,sp,32
    80003222:	8082                	ret

0000000080003224 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003224:	1101                	addi	sp,sp,-32
    80003226:	ec06                	sd	ra,24(sp)
    80003228:	e822                	sd	s0,16(sp)
    8000322a:	e426                	sd	s1,8(sp)
    8000322c:	e04a                	sd	s2,0(sp)
    8000322e:	1000                	addi	s0,sp,32
    80003230:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003232:	00d5d59b          	srliw	a1,a1,0xd
    80003236:	0002c797          	auipc	a5,0x2c
    8000323a:	7b67a783          	lw	a5,1974(a5) # 8002f9ec <sb+0x1c>
    8000323e:	9dbd                	addw	a1,a1,a5
    80003240:	debff0ef          	jal	ra,8000302a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003244:	0074f713          	andi	a4,s1,7
    80003248:	4785                	li	a5,1
    8000324a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000324e:	14ce                	slli	s1,s1,0x33
    80003250:	90d9                	srli	s1,s1,0x36
    80003252:	00950733          	add	a4,a0,s1
    80003256:	05874703          	lbu	a4,88(a4)
    8000325a:	00e7f6b3          	and	a3,a5,a4
    8000325e:	c29d                	beqz	a3,80003284 <bfree+0x60>
    80003260:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003262:	94aa                	add	s1,s1,a0
    80003264:	fff7c793          	not	a5,a5
    80003268:	8ff9                	and	a5,a5,a4
    8000326a:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000326e:	7d1000ef          	jal	ra,8000423e <log_write>
  brelse(bp);
    80003272:	854a                	mv	a0,s2
    80003274:	ebfff0ef          	jal	ra,80003132 <brelse>
}
    80003278:	60e2                	ld	ra,24(sp)
    8000327a:	6442                	ld	s0,16(sp)
    8000327c:	64a2                	ld	s1,8(sp)
    8000327e:	6902                	ld	s2,0(sp)
    80003280:	6105                	addi	sp,sp,32
    80003282:	8082                	ret
    panic("freeing free block");
    80003284:	00004517          	auipc	a0,0x4
    80003288:	4ec50513          	addi	a0,a0,1260 # 80007770 <syscalls+0xe8>
    8000328c:	cfefd0ef          	jal	ra,8000078a <panic>

0000000080003290 <balloc>:
{
    80003290:	711d                	addi	sp,sp,-96
    80003292:	ec86                	sd	ra,88(sp)
    80003294:	e8a2                	sd	s0,80(sp)
    80003296:	e4a6                	sd	s1,72(sp)
    80003298:	e0ca                	sd	s2,64(sp)
    8000329a:	fc4e                	sd	s3,56(sp)
    8000329c:	f852                	sd	s4,48(sp)
    8000329e:	f456                	sd	s5,40(sp)
    800032a0:	f05a                	sd	s6,32(sp)
    800032a2:	ec5e                	sd	s7,24(sp)
    800032a4:	e862                	sd	s8,16(sp)
    800032a6:	e466                	sd	s9,8(sp)
    800032a8:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800032aa:	0002c797          	auipc	a5,0x2c
    800032ae:	72a7a783          	lw	a5,1834(a5) # 8002f9d4 <sb+0x4>
    800032b2:	0e078163          	beqz	a5,80003394 <balloc+0x104>
    800032b6:	8baa                	mv	s7,a0
    800032b8:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800032ba:	0002cb17          	auipc	s6,0x2c
    800032be:	716b0b13          	addi	s6,s6,1814 # 8002f9d0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032c2:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800032c4:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032c6:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800032c8:	6c89                	lui	s9,0x2
    800032ca:	a0b5                	j	80003336 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    800032cc:	974a                	add	a4,a4,s2
    800032ce:	8fd5                	or	a5,a5,a3
    800032d0:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800032d4:	854a                	mv	a0,s2
    800032d6:	769000ef          	jal	ra,8000423e <log_write>
        brelse(bp);
    800032da:	854a                	mv	a0,s2
    800032dc:	e57ff0ef          	jal	ra,80003132 <brelse>
  bp = bread(dev, bno);
    800032e0:	85a6                	mv	a1,s1
    800032e2:	855e                	mv	a0,s7
    800032e4:	d47ff0ef          	jal	ra,8000302a <bread>
    800032e8:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800032ea:	40000613          	li	a2,1024
    800032ee:	4581                	li	a1,0
    800032f0:	05850513          	addi	a0,a0,88
    800032f4:	94dfd0ef          	jal	ra,80000c40 <memset>
  log_write(bp);
    800032f8:	854a                	mv	a0,s2
    800032fa:	745000ef          	jal	ra,8000423e <log_write>
  brelse(bp);
    800032fe:	854a                	mv	a0,s2
    80003300:	e33ff0ef          	jal	ra,80003132 <brelse>
}
    80003304:	8526                	mv	a0,s1
    80003306:	60e6                	ld	ra,88(sp)
    80003308:	6446                	ld	s0,80(sp)
    8000330a:	64a6                	ld	s1,72(sp)
    8000330c:	6906                	ld	s2,64(sp)
    8000330e:	79e2                	ld	s3,56(sp)
    80003310:	7a42                	ld	s4,48(sp)
    80003312:	7aa2                	ld	s5,40(sp)
    80003314:	7b02                	ld	s6,32(sp)
    80003316:	6be2                	ld	s7,24(sp)
    80003318:	6c42                	ld	s8,16(sp)
    8000331a:	6ca2                	ld	s9,8(sp)
    8000331c:	6125                	addi	sp,sp,96
    8000331e:	8082                	ret
    brelse(bp);
    80003320:	854a                	mv	a0,s2
    80003322:	e11ff0ef          	jal	ra,80003132 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003326:	015c87bb          	addw	a5,s9,s5
    8000332a:	00078a9b          	sext.w	s5,a5
    8000332e:	004b2703          	lw	a4,4(s6)
    80003332:	06eaf163          	bgeu	s5,a4,80003394 <balloc+0x104>
    bp = bread(dev, BBLOCK(b, sb));
    80003336:	41fad79b          	sraiw	a5,s5,0x1f
    8000333a:	0137d79b          	srliw	a5,a5,0x13
    8000333e:	015787bb          	addw	a5,a5,s5
    80003342:	40d7d79b          	sraiw	a5,a5,0xd
    80003346:	01cb2583          	lw	a1,28(s6)
    8000334a:	9dbd                	addw	a1,a1,a5
    8000334c:	855e                	mv	a0,s7
    8000334e:	cddff0ef          	jal	ra,8000302a <bread>
    80003352:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003354:	004b2503          	lw	a0,4(s6)
    80003358:	000a849b          	sext.w	s1,s5
    8000335c:	8662                	mv	a2,s8
    8000335e:	fca4f1e3          	bgeu	s1,a0,80003320 <balloc+0x90>
      m = 1 << (bi % 8);
    80003362:	41f6579b          	sraiw	a5,a2,0x1f
    80003366:	01d7d69b          	srliw	a3,a5,0x1d
    8000336a:	00c6873b          	addw	a4,a3,a2
    8000336e:	00777793          	andi	a5,a4,7
    80003372:	9f95                	subw	a5,a5,a3
    80003374:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003378:	4037571b          	sraiw	a4,a4,0x3
    8000337c:	00e906b3          	add	a3,s2,a4
    80003380:	0586c683          	lbu	a3,88(a3) # 1058 <_entry-0x7fffefa8>
    80003384:	00d7f5b3          	and	a1,a5,a3
    80003388:	d1b1                	beqz	a1,800032cc <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000338a:	2605                	addiw	a2,a2,1
    8000338c:	2485                	addiw	s1,s1,1
    8000338e:	fd4618e3          	bne	a2,s4,8000335e <balloc+0xce>
    80003392:	b779                	j	80003320 <balloc+0x90>
  printf("balloc: out of blocks\n");
    80003394:	00004517          	auipc	a0,0x4
    80003398:	3f450513          	addi	a0,a0,1012 # 80007788 <syscalls+0x100>
    8000339c:	928fd0ef          	jal	ra,800004c4 <printf>
  return 0;
    800033a0:	4481                	li	s1,0
    800033a2:	b78d                	j	80003304 <balloc+0x74>

00000000800033a4 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800033a4:	7179                	addi	sp,sp,-48
    800033a6:	f406                	sd	ra,40(sp)
    800033a8:	f022                	sd	s0,32(sp)
    800033aa:	ec26                	sd	s1,24(sp)
    800033ac:	e84a                	sd	s2,16(sp)
    800033ae:	e44e                	sd	s3,8(sp)
    800033b0:	e052                	sd	s4,0(sp)
    800033b2:	1800                	addi	s0,sp,48
    800033b4:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800033b6:	47ad                	li	a5,11
    800033b8:	02b7e563          	bltu	a5,a1,800033e2 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    800033bc:	02059493          	slli	s1,a1,0x20
    800033c0:	9081                	srli	s1,s1,0x20
    800033c2:	048a                	slli	s1,s1,0x2
    800033c4:	94aa                	add	s1,s1,a0
    800033c6:	0504a903          	lw	s2,80(s1)
    800033ca:	06091663          	bnez	s2,80003436 <bmap+0x92>
      addr = balloc(ip->dev);
    800033ce:	4108                	lw	a0,0(a0)
    800033d0:	ec1ff0ef          	jal	ra,80003290 <balloc>
    800033d4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800033d8:	04090f63          	beqz	s2,80003436 <bmap+0x92>
        return 0;
      ip->addrs[bn] = addr;
    800033dc:	0524a823          	sw	s2,80(s1)
    800033e0:	a899                	j	80003436 <bmap+0x92>
    }
    return addr;
  }
  bn -= NDIRECT;
    800033e2:	ff45849b          	addiw	s1,a1,-12
    800033e6:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800033ea:	0ff00793          	li	a5,255
    800033ee:	06e7eb63          	bltu	a5,a4,80003464 <bmap+0xc0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800033f2:	08052903          	lw	s2,128(a0)
    800033f6:	00091b63          	bnez	s2,8000340c <bmap+0x68>
      addr = balloc(ip->dev);
    800033fa:	4108                	lw	a0,0(a0)
    800033fc:	e95ff0ef          	jal	ra,80003290 <balloc>
    80003400:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003404:	02090963          	beqz	s2,80003436 <bmap+0x92>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003408:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000340c:	85ca                	mv	a1,s2
    8000340e:	0009a503          	lw	a0,0(s3)
    80003412:	c19ff0ef          	jal	ra,8000302a <bread>
    80003416:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003418:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000341c:	02049593          	slli	a1,s1,0x20
    80003420:	9181                	srli	a1,a1,0x20
    80003422:	058a                	slli	a1,a1,0x2
    80003424:	00b784b3          	add	s1,a5,a1
    80003428:	0004a903          	lw	s2,0(s1)
    8000342c:	00090e63          	beqz	s2,80003448 <bmap+0xa4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003430:	8552                	mv	a0,s4
    80003432:	d01ff0ef          	jal	ra,80003132 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003436:	854a                	mv	a0,s2
    80003438:	70a2                	ld	ra,40(sp)
    8000343a:	7402                	ld	s0,32(sp)
    8000343c:	64e2                	ld	s1,24(sp)
    8000343e:	6942                	ld	s2,16(sp)
    80003440:	69a2                	ld	s3,8(sp)
    80003442:	6a02                	ld	s4,0(sp)
    80003444:	6145                	addi	sp,sp,48
    80003446:	8082                	ret
      addr = balloc(ip->dev);
    80003448:	0009a503          	lw	a0,0(s3)
    8000344c:	e45ff0ef          	jal	ra,80003290 <balloc>
    80003450:	0005091b          	sext.w	s2,a0
      if(addr){
    80003454:	fc090ee3          	beqz	s2,80003430 <bmap+0x8c>
        a[bn] = addr;
    80003458:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000345c:	8552                	mv	a0,s4
    8000345e:	5e1000ef          	jal	ra,8000423e <log_write>
    80003462:	b7f9                	j	80003430 <bmap+0x8c>
  panic("bmap: out of range");
    80003464:	00004517          	auipc	a0,0x4
    80003468:	33c50513          	addi	a0,a0,828 # 800077a0 <syscalls+0x118>
    8000346c:	b1efd0ef          	jal	ra,8000078a <panic>

0000000080003470 <iget>:
{
    80003470:	7179                	addi	sp,sp,-48
    80003472:	f406                	sd	ra,40(sp)
    80003474:	f022                	sd	s0,32(sp)
    80003476:	ec26                	sd	s1,24(sp)
    80003478:	e84a                	sd	s2,16(sp)
    8000347a:	e44e                	sd	s3,8(sp)
    8000347c:	e052                	sd	s4,0(sp)
    8000347e:	1800                	addi	s0,sp,48
    80003480:	89aa                	mv	s3,a0
    80003482:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003484:	0002c517          	auipc	a0,0x2c
    80003488:	56c50513          	addi	a0,a0,1388 # 8002f9f0 <itable>
    8000348c:	ee0fd0ef          	jal	ra,80000b6c <acquire>
  empty = 0;
    80003490:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003492:	0002c497          	auipc	s1,0x2c
    80003496:	57648493          	addi	s1,s1,1398 # 8002fa08 <itable+0x18>
    8000349a:	0002e697          	auipc	a3,0x2e
    8000349e:	ffe68693          	addi	a3,a3,-2 # 80031498 <log>
    800034a2:	a039                	j	800034b0 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034a4:	02090963          	beqz	s2,800034d6 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800034a8:	08848493          	addi	s1,s1,136
    800034ac:	02d48863          	beq	s1,a3,800034dc <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800034b0:	449c                	lw	a5,8(s1)
    800034b2:	fef059e3          	blez	a5,800034a4 <iget+0x34>
    800034b6:	4098                	lw	a4,0(s1)
    800034b8:	ff3716e3          	bne	a4,s3,800034a4 <iget+0x34>
    800034bc:	40d8                	lw	a4,4(s1)
    800034be:	ff4713e3          	bne	a4,s4,800034a4 <iget+0x34>
      ip->ref++;
    800034c2:	2785                	addiw	a5,a5,1
    800034c4:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800034c6:	0002c517          	auipc	a0,0x2c
    800034ca:	52a50513          	addi	a0,a0,1322 # 8002f9f0 <itable>
    800034ce:	f36fd0ef          	jal	ra,80000c04 <release>
      return ip;
    800034d2:	8926                	mv	s2,s1
    800034d4:	a02d                	j	800034fe <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034d6:	fbe9                	bnez	a5,800034a8 <iget+0x38>
    800034d8:	8926                	mv	s2,s1
    800034da:	b7f9                	j	800034a8 <iget+0x38>
  if(empty == 0)
    800034dc:	02090a63          	beqz	s2,80003510 <iget+0xa0>
  ip->dev = dev;
    800034e0:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800034e4:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800034e8:	4785                	li	a5,1
    800034ea:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800034ee:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800034f2:	0002c517          	auipc	a0,0x2c
    800034f6:	4fe50513          	addi	a0,a0,1278 # 8002f9f0 <itable>
    800034fa:	f0afd0ef          	jal	ra,80000c04 <release>
}
    800034fe:	854a                	mv	a0,s2
    80003500:	70a2                	ld	ra,40(sp)
    80003502:	7402                	ld	s0,32(sp)
    80003504:	64e2                	ld	s1,24(sp)
    80003506:	6942                	ld	s2,16(sp)
    80003508:	69a2                	ld	s3,8(sp)
    8000350a:	6a02                	ld	s4,0(sp)
    8000350c:	6145                	addi	sp,sp,48
    8000350e:	8082                	ret
    panic("iget: no inodes");
    80003510:	00004517          	auipc	a0,0x4
    80003514:	2a850513          	addi	a0,a0,680 # 800077b8 <syscalls+0x130>
    80003518:	a72fd0ef          	jal	ra,8000078a <panic>

000000008000351c <iinit>:
{
    8000351c:	7179                	addi	sp,sp,-48
    8000351e:	f406                	sd	ra,40(sp)
    80003520:	f022                	sd	s0,32(sp)
    80003522:	ec26                	sd	s1,24(sp)
    80003524:	e84a                	sd	s2,16(sp)
    80003526:	e44e                	sd	s3,8(sp)
    80003528:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000352a:	00004597          	auipc	a1,0x4
    8000352e:	29e58593          	addi	a1,a1,670 # 800077c8 <syscalls+0x140>
    80003532:	0002c517          	auipc	a0,0x2c
    80003536:	4be50513          	addi	a0,a0,1214 # 8002f9f0 <itable>
    8000353a:	db2fd0ef          	jal	ra,80000aec <initlock>
  for(i = 0; i < NINODE; i++) {
    8000353e:	0002c497          	auipc	s1,0x2c
    80003542:	4da48493          	addi	s1,s1,1242 # 8002fa18 <itable+0x28>
    80003546:	0002e997          	auipc	s3,0x2e
    8000354a:	f6298993          	addi	s3,s3,-158 # 800314a8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000354e:	00004917          	auipc	s2,0x4
    80003552:	28290913          	addi	s2,s2,642 # 800077d0 <syscalls+0x148>
    80003556:	85ca                	mv	a1,s2
    80003558:	8526                	mv	a0,s1
    8000355a:	5a9000ef          	jal	ra,80004302 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000355e:	08848493          	addi	s1,s1,136
    80003562:	ff349ae3          	bne	s1,s3,80003556 <iinit+0x3a>
}
    80003566:	70a2                	ld	ra,40(sp)
    80003568:	7402                	ld	s0,32(sp)
    8000356a:	64e2                	ld	s1,24(sp)
    8000356c:	6942                	ld	s2,16(sp)
    8000356e:	69a2                	ld	s3,8(sp)
    80003570:	6145                	addi	sp,sp,48
    80003572:	8082                	ret

0000000080003574 <ialloc>:
{
    80003574:	715d                	addi	sp,sp,-80
    80003576:	e486                	sd	ra,72(sp)
    80003578:	e0a2                	sd	s0,64(sp)
    8000357a:	fc26                	sd	s1,56(sp)
    8000357c:	f84a                	sd	s2,48(sp)
    8000357e:	f44e                	sd	s3,40(sp)
    80003580:	f052                	sd	s4,32(sp)
    80003582:	ec56                	sd	s5,24(sp)
    80003584:	e85a                	sd	s6,16(sp)
    80003586:	e45e                	sd	s7,8(sp)
    80003588:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000358a:	0002c717          	auipc	a4,0x2c
    8000358e:	45272703          	lw	a4,1106(a4) # 8002f9dc <sb+0xc>
    80003592:	4785                	li	a5,1
    80003594:	04e7f663          	bgeu	a5,a4,800035e0 <ialloc+0x6c>
    80003598:	8aaa                	mv	s5,a0
    8000359a:	8bae                	mv	s7,a1
    8000359c:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000359e:	0002ca17          	auipc	s4,0x2c
    800035a2:	432a0a13          	addi	s4,s4,1074 # 8002f9d0 <sb>
    800035a6:	00048b1b          	sext.w	s6,s1
    800035aa:	0044d793          	srli	a5,s1,0x4
    800035ae:	018a2583          	lw	a1,24(s4)
    800035b2:	9dbd                	addw	a1,a1,a5
    800035b4:	8556                	mv	a0,s5
    800035b6:	a75ff0ef          	jal	ra,8000302a <bread>
    800035ba:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800035bc:	05850993          	addi	s3,a0,88
    800035c0:	00f4f793          	andi	a5,s1,15
    800035c4:	079a                	slli	a5,a5,0x6
    800035c6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800035c8:	00099783          	lh	a5,0(s3)
    800035cc:	cf85                	beqz	a5,80003604 <ialloc+0x90>
    brelse(bp);
    800035ce:	b65ff0ef          	jal	ra,80003132 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800035d2:	0485                	addi	s1,s1,1
    800035d4:	00ca2703          	lw	a4,12(s4)
    800035d8:	0004879b          	sext.w	a5,s1
    800035dc:	fce7e5e3          	bltu	a5,a4,800035a6 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800035e0:	00004517          	auipc	a0,0x4
    800035e4:	1f850513          	addi	a0,a0,504 # 800077d8 <syscalls+0x150>
    800035e8:	eddfc0ef          	jal	ra,800004c4 <printf>
  return 0;
    800035ec:	4501                	li	a0,0
}
    800035ee:	60a6                	ld	ra,72(sp)
    800035f0:	6406                	ld	s0,64(sp)
    800035f2:	74e2                	ld	s1,56(sp)
    800035f4:	7942                	ld	s2,48(sp)
    800035f6:	79a2                	ld	s3,40(sp)
    800035f8:	7a02                	ld	s4,32(sp)
    800035fa:	6ae2                	ld	s5,24(sp)
    800035fc:	6b42                	ld	s6,16(sp)
    800035fe:	6ba2                	ld	s7,8(sp)
    80003600:	6161                	addi	sp,sp,80
    80003602:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003604:	04000613          	li	a2,64
    80003608:	4581                	li	a1,0
    8000360a:	854e                	mv	a0,s3
    8000360c:	e34fd0ef          	jal	ra,80000c40 <memset>
      dip->type = type;
    80003610:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003614:	854a                	mv	a0,s2
    80003616:	429000ef          	jal	ra,8000423e <log_write>
      brelse(bp);
    8000361a:	854a                	mv	a0,s2
    8000361c:	b17ff0ef          	jal	ra,80003132 <brelse>
      return iget(dev, inum);
    80003620:	85da                	mv	a1,s6
    80003622:	8556                	mv	a0,s5
    80003624:	e4dff0ef          	jal	ra,80003470 <iget>
    80003628:	b7d9                	j	800035ee <ialloc+0x7a>

000000008000362a <iupdate>:
{
    8000362a:	1101                	addi	sp,sp,-32
    8000362c:	ec06                	sd	ra,24(sp)
    8000362e:	e822                	sd	s0,16(sp)
    80003630:	e426                	sd	s1,8(sp)
    80003632:	e04a                	sd	s2,0(sp)
    80003634:	1000                	addi	s0,sp,32
    80003636:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003638:	415c                	lw	a5,4(a0)
    8000363a:	0047d79b          	srliw	a5,a5,0x4
    8000363e:	0002c597          	auipc	a1,0x2c
    80003642:	3aa5a583          	lw	a1,938(a1) # 8002f9e8 <sb+0x18>
    80003646:	9dbd                	addw	a1,a1,a5
    80003648:	4108                	lw	a0,0(a0)
    8000364a:	9e1ff0ef          	jal	ra,8000302a <bread>
    8000364e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003650:	05850793          	addi	a5,a0,88
    80003654:	40c8                	lw	a0,4(s1)
    80003656:	893d                	andi	a0,a0,15
    80003658:	051a                	slli	a0,a0,0x6
    8000365a:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000365c:	04449703          	lh	a4,68(s1)
    80003660:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003664:	04649703          	lh	a4,70(s1)
    80003668:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000366c:	04849703          	lh	a4,72(s1)
    80003670:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003674:	04a49703          	lh	a4,74(s1)
    80003678:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000367c:	44f8                	lw	a4,76(s1)
    8000367e:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003680:	03400613          	li	a2,52
    80003684:	05048593          	addi	a1,s1,80
    80003688:	0531                	addi	a0,a0,12
    8000368a:	e12fd0ef          	jal	ra,80000c9c <memmove>
  log_write(bp);
    8000368e:	854a                	mv	a0,s2
    80003690:	3af000ef          	jal	ra,8000423e <log_write>
  brelse(bp);
    80003694:	854a                	mv	a0,s2
    80003696:	a9dff0ef          	jal	ra,80003132 <brelse>
}
    8000369a:	60e2                	ld	ra,24(sp)
    8000369c:	6442                	ld	s0,16(sp)
    8000369e:	64a2                	ld	s1,8(sp)
    800036a0:	6902                	ld	s2,0(sp)
    800036a2:	6105                	addi	sp,sp,32
    800036a4:	8082                	ret

00000000800036a6 <idup>:
{
    800036a6:	1101                	addi	sp,sp,-32
    800036a8:	ec06                	sd	ra,24(sp)
    800036aa:	e822                	sd	s0,16(sp)
    800036ac:	e426                	sd	s1,8(sp)
    800036ae:	1000                	addi	s0,sp,32
    800036b0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800036b2:	0002c517          	auipc	a0,0x2c
    800036b6:	33e50513          	addi	a0,a0,830 # 8002f9f0 <itable>
    800036ba:	cb2fd0ef          	jal	ra,80000b6c <acquire>
  ip->ref++;
    800036be:	449c                	lw	a5,8(s1)
    800036c0:	2785                	addiw	a5,a5,1
    800036c2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800036c4:	0002c517          	auipc	a0,0x2c
    800036c8:	32c50513          	addi	a0,a0,812 # 8002f9f0 <itable>
    800036cc:	d38fd0ef          	jal	ra,80000c04 <release>
}
    800036d0:	8526                	mv	a0,s1
    800036d2:	60e2                	ld	ra,24(sp)
    800036d4:	6442                	ld	s0,16(sp)
    800036d6:	64a2                	ld	s1,8(sp)
    800036d8:	6105                	addi	sp,sp,32
    800036da:	8082                	ret

00000000800036dc <ilock>:
{
    800036dc:	1101                	addi	sp,sp,-32
    800036de:	ec06                	sd	ra,24(sp)
    800036e0:	e822                	sd	s0,16(sp)
    800036e2:	e426                	sd	s1,8(sp)
    800036e4:	e04a                	sd	s2,0(sp)
    800036e6:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800036e8:	c105                	beqz	a0,80003708 <ilock+0x2c>
    800036ea:	84aa                	mv	s1,a0
    800036ec:	451c                	lw	a5,8(a0)
    800036ee:	00f05d63          	blez	a5,80003708 <ilock+0x2c>
  acquiresleep(&ip->lock);
    800036f2:	0541                	addi	a0,a0,16
    800036f4:	445000ef          	jal	ra,80004338 <acquiresleep>
  if(ip->valid == 0){
    800036f8:	40bc                	lw	a5,64(s1)
    800036fa:	cf89                	beqz	a5,80003714 <ilock+0x38>
}
    800036fc:	60e2                	ld	ra,24(sp)
    800036fe:	6442                	ld	s0,16(sp)
    80003700:	64a2                	ld	s1,8(sp)
    80003702:	6902                	ld	s2,0(sp)
    80003704:	6105                	addi	sp,sp,32
    80003706:	8082                	ret
    panic("ilock");
    80003708:	00004517          	auipc	a0,0x4
    8000370c:	0e850513          	addi	a0,a0,232 # 800077f0 <syscalls+0x168>
    80003710:	87afd0ef          	jal	ra,8000078a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003714:	40dc                	lw	a5,4(s1)
    80003716:	0047d79b          	srliw	a5,a5,0x4
    8000371a:	0002c597          	auipc	a1,0x2c
    8000371e:	2ce5a583          	lw	a1,718(a1) # 8002f9e8 <sb+0x18>
    80003722:	9dbd                	addw	a1,a1,a5
    80003724:	4088                	lw	a0,0(s1)
    80003726:	905ff0ef          	jal	ra,8000302a <bread>
    8000372a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000372c:	05850593          	addi	a1,a0,88
    80003730:	40dc                	lw	a5,4(s1)
    80003732:	8bbd                	andi	a5,a5,15
    80003734:	079a                	slli	a5,a5,0x6
    80003736:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003738:	00059783          	lh	a5,0(a1)
    8000373c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003740:	00259783          	lh	a5,2(a1)
    80003744:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003748:	00459783          	lh	a5,4(a1)
    8000374c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003750:	00659783          	lh	a5,6(a1)
    80003754:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003758:	459c                	lw	a5,8(a1)
    8000375a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000375c:	03400613          	li	a2,52
    80003760:	05b1                	addi	a1,a1,12
    80003762:	05048513          	addi	a0,s1,80
    80003766:	d36fd0ef          	jal	ra,80000c9c <memmove>
    brelse(bp);
    8000376a:	854a                	mv	a0,s2
    8000376c:	9c7ff0ef          	jal	ra,80003132 <brelse>
    ip->valid = 1;
    80003770:	4785                	li	a5,1
    80003772:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003774:	04449783          	lh	a5,68(s1)
    80003778:	f3d1                	bnez	a5,800036fc <ilock+0x20>
      panic("ilock: no type");
    8000377a:	00004517          	auipc	a0,0x4
    8000377e:	07e50513          	addi	a0,a0,126 # 800077f8 <syscalls+0x170>
    80003782:	808fd0ef          	jal	ra,8000078a <panic>

0000000080003786 <iunlock>:
{
    80003786:	1101                	addi	sp,sp,-32
    80003788:	ec06                	sd	ra,24(sp)
    8000378a:	e822                	sd	s0,16(sp)
    8000378c:	e426                	sd	s1,8(sp)
    8000378e:	e04a                	sd	s2,0(sp)
    80003790:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003792:	c505                	beqz	a0,800037ba <iunlock+0x34>
    80003794:	84aa                	mv	s1,a0
    80003796:	01050913          	addi	s2,a0,16
    8000379a:	854a                	mv	a0,s2
    8000379c:	41b000ef          	jal	ra,800043b6 <holdingsleep>
    800037a0:	cd09                	beqz	a0,800037ba <iunlock+0x34>
    800037a2:	449c                	lw	a5,8(s1)
    800037a4:	00f05b63          	blez	a5,800037ba <iunlock+0x34>
  releasesleep(&ip->lock);
    800037a8:	854a                	mv	a0,s2
    800037aa:	3d5000ef          	jal	ra,8000437e <releasesleep>
}
    800037ae:	60e2                	ld	ra,24(sp)
    800037b0:	6442                	ld	s0,16(sp)
    800037b2:	64a2                	ld	s1,8(sp)
    800037b4:	6902                	ld	s2,0(sp)
    800037b6:	6105                	addi	sp,sp,32
    800037b8:	8082                	ret
    panic("iunlock");
    800037ba:	00004517          	auipc	a0,0x4
    800037be:	04e50513          	addi	a0,a0,78 # 80007808 <syscalls+0x180>
    800037c2:	fc9fc0ef          	jal	ra,8000078a <panic>

00000000800037c6 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800037c6:	7179                	addi	sp,sp,-48
    800037c8:	f406                	sd	ra,40(sp)
    800037ca:	f022                	sd	s0,32(sp)
    800037cc:	ec26                	sd	s1,24(sp)
    800037ce:	e84a                	sd	s2,16(sp)
    800037d0:	e44e                	sd	s3,8(sp)
    800037d2:	e052                	sd	s4,0(sp)
    800037d4:	1800                	addi	s0,sp,48
    800037d6:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800037d8:	05050493          	addi	s1,a0,80
    800037dc:	08050913          	addi	s2,a0,128
    800037e0:	a021                	j	800037e8 <itrunc+0x22>
    800037e2:	0491                	addi	s1,s1,4
    800037e4:	01248b63          	beq	s1,s2,800037fa <itrunc+0x34>
    if(ip->addrs[i]){
    800037e8:	408c                	lw	a1,0(s1)
    800037ea:	dde5                	beqz	a1,800037e2 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800037ec:	0009a503          	lw	a0,0(s3)
    800037f0:	a35ff0ef          	jal	ra,80003224 <bfree>
      ip->addrs[i] = 0;
    800037f4:	0004a023          	sw	zero,0(s1)
    800037f8:	b7ed                	j	800037e2 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800037fa:	0809a583          	lw	a1,128(s3)
    800037fe:	ed91                	bnez	a1,8000381a <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003800:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003804:	854e                	mv	a0,s3
    80003806:	e25ff0ef          	jal	ra,8000362a <iupdate>
}
    8000380a:	70a2                	ld	ra,40(sp)
    8000380c:	7402                	ld	s0,32(sp)
    8000380e:	64e2                	ld	s1,24(sp)
    80003810:	6942                	ld	s2,16(sp)
    80003812:	69a2                	ld	s3,8(sp)
    80003814:	6a02                	ld	s4,0(sp)
    80003816:	6145                	addi	sp,sp,48
    80003818:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000381a:	0009a503          	lw	a0,0(s3)
    8000381e:	80dff0ef          	jal	ra,8000302a <bread>
    80003822:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003824:	05850493          	addi	s1,a0,88
    80003828:	45850913          	addi	s2,a0,1112
    8000382c:	a021                	j	80003834 <itrunc+0x6e>
    8000382e:	0491                	addi	s1,s1,4
    80003830:	01248963          	beq	s1,s2,80003842 <itrunc+0x7c>
      if(a[j])
    80003834:	408c                	lw	a1,0(s1)
    80003836:	dde5                	beqz	a1,8000382e <itrunc+0x68>
        bfree(ip->dev, a[j]);
    80003838:	0009a503          	lw	a0,0(s3)
    8000383c:	9e9ff0ef          	jal	ra,80003224 <bfree>
    80003840:	b7fd                	j	8000382e <itrunc+0x68>
    brelse(bp);
    80003842:	8552                	mv	a0,s4
    80003844:	8efff0ef          	jal	ra,80003132 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003848:	0809a583          	lw	a1,128(s3)
    8000384c:	0009a503          	lw	a0,0(s3)
    80003850:	9d5ff0ef          	jal	ra,80003224 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003854:	0809a023          	sw	zero,128(s3)
    80003858:	b765                	j	80003800 <itrunc+0x3a>

000000008000385a <iput>:
{
    8000385a:	1101                	addi	sp,sp,-32
    8000385c:	ec06                	sd	ra,24(sp)
    8000385e:	e822                	sd	s0,16(sp)
    80003860:	e426                	sd	s1,8(sp)
    80003862:	e04a                	sd	s2,0(sp)
    80003864:	1000                	addi	s0,sp,32
    80003866:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003868:	0002c517          	auipc	a0,0x2c
    8000386c:	18850513          	addi	a0,a0,392 # 8002f9f0 <itable>
    80003870:	afcfd0ef          	jal	ra,80000b6c <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003874:	4498                	lw	a4,8(s1)
    80003876:	4785                	li	a5,1
    80003878:	02f70163          	beq	a4,a5,8000389a <iput+0x40>
  ip->ref--;
    8000387c:	449c                	lw	a5,8(s1)
    8000387e:	37fd                	addiw	a5,a5,-1
    80003880:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003882:	0002c517          	auipc	a0,0x2c
    80003886:	16e50513          	addi	a0,a0,366 # 8002f9f0 <itable>
    8000388a:	b7afd0ef          	jal	ra,80000c04 <release>
}
    8000388e:	60e2                	ld	ra,24(sp)
    80003890:	6442                	ld	s0,16(sp)
    80003892:	64a2                	ld	s1,8(sp)
    80003894:	6902                	ld	s2,0(sp)
    80003896:	6105                	addi	sp,sp,32
    80003898:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000389a:	40bc                	lw	a5,64(s1)
    8000389c:	d3e5                	beqz	a5,8000387c <iput+0x22>
    8000389e:	04a49783          	lh	a5,74(s1)
    800038a2:	ffe9                	bnez	a5,8000387c <iput+0x22>
    acquiresleep(&ip->lock);
    800038a4:	01048913          	addi	s2,s1,16
    800038a8:	854a                	mv	a0,s2
    800038aa:	28f000ef          	jal	ra,80004338 <acquiresleep>
    release(&itable.lock);
    800038ae:	0002c517          	auipc	a0,0x2c
    800038b2:	14250513          	addi	a0,a0,322 # 8002f9f0 <itable>
    800038b6:	b4efd0ef          	jal	ra,80000c04 <release>
    itrunc(ip);
    800038ba:	8526                	mv	a0,s1
    800038bc:	f0bff0ef          	jal	ra,800037c6 <itrunc>
    ip->type = 0;
    800038c0:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800038c4:	8526                	mv	a0,s1
    800038c6:	d65ff0ef          	jal	ra,8000362a <iupdate>
    ip->valid = 0;
    800038ca:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800038ce:	854a                	mv	a0,s2
    800038d0:	2af000ef          	jal	ra,8000437e <releasesleep>
    acquire(&itable.lock);
    800038d4:	0002c517          	auipc	a0,0x2c
    800038d8:	11c50513          	addi	a0,a0,284 # 8002f9f0 <itable>
    800038dc:	a90fd0ef          	jal	ra,80000b6c <acquire>
    800038e0:	bf71                	j	8000387c <iput+0x22>

00000000800038e2 <iunlockput>:
{
    800038e2:	1101                	addi	sp,sp,-32
    800038e4:	ec06                	sd	ra,24(sp)
    800038e6:	e822                	sd	s0,16(sp)
    800038e8:	e426                	sd	s1,8(sp)
    800038ea:	1000                	addi	s0,sp,32
    800038ec:	84aa                	mv	s1,a0
  iunlock(ip);
    800038ee:	e99ff0ef          	jal	ra,80003786 <iunlock>
  iput(ip);
    800038f2:	8526                	mv	a0,s1
    800038f4:	f67ff0ef          	jal	ra,8000385a <iput>
}
    800038f8:	60e2                	ld	ra,24(sp)
    800038fa:	6442                	ld	s0,16(sp)
    800038fc:	64a2                	ld	s1,8(sp)
    800038fe:	6105                	addi	sp,sp,32
    80003900:	8082                	ret

0000000080003902 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003902:	0002c717          	auipc	a4,0x2c
    80003906:	0da72703          	lw	a4,218(a4) # 8002f9dc <sb+0xc>
    8000390a:	4785                	li	a5,1
    8000390c:	0ae7ff63          	bgeu	a5,a4,800039ca <ireclaim+0xc8>
{
    80003910:	7139                	addi	sp,sp,-64
    80003912:	fc06                	sd	ra,56(sp)
    80003914:	f822                	sd	s0,48(sp)
    80003916:	f426                	sd	s1,40(sp)
    80003918:	f04a                	sd	s2,32(sp)
    8000391a:	ec4e                	sd	s3,24(sp)
    8000391c:	e852                	sd	s4,16(sp)
    8000391e:	e456                	sd	s5,8(sp)
    80003920:	e05a                	sd	s6,0(sp)
    80003922:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003924:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003926:	00050a1b          	sext.w	s4,a0
    8000392a:	0002ca97          	auipc	s5,0x2c
    8000392e:	0a6a8a93          	addi	s5,s5,166 # 8002f9d0 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003932:	00004b17          	auipc	s6,0x4
    80003936:	edeb0b13          	addi	s6,s6,-290 # 80007810 <syscalls+0x188>
    8000393a:	a099                	j	80003980 <ireclaim+0x7e>
    8000393c:	85ce                	mv	a1,s3
    8000393e:	855a                	mv	a0,s6
    80003940:	b85fc0ef          	jal	ra,800004c4 <printf>
      ip = iget(dev, inum);
    80003944:	85ce                	mv	a1,s3
    80003946:	8552                	mv	a0,s4
    80003948:	b29ff0ef          	jal	ra,80003470 <iget>
    8000394c:	89aa                	mv	s3,a0
    brelse(bp);
    8000394e:	854a                	mv	a0,s2
    80003950:	fe2ff0ef          	jal	ra,80003132 <brelse>
    if (ip) {
    80003954:	00098f63          	beqz	s3,80003972 <ireclaim+0x70>
      begin_op();
    80003958:	762000ef          	jal	ra,800040ba <begin_op>
      ilock(ip);
    8000395c:	854e                	mv	a0,s3
    8000395e:	d7fff0ef          	jal	ra,800036dc <ilock>
      iunlock(ip);
    80003962:	854e                	mv	a0,s3
    80003964:	e23ff0ef          	jal	ra,80003786 <iunlock>
      iput(ip);
    80003968:	854e                	mv	a0,s3
    8000396a:	ef1ff0ef          	jal	ra,8000385a <iput>
      end_op();
    8000396e:	7bc000ef          	jal	ra,8000412a <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003972:	0485                	addi	s1,s1,1
    80003974:	00caa703          	lw	a4,12(s5)
    80003978:	0004879b          	sext.w	a5,s1
    8000397c:	02e7fd63          	bgeu	a5,a4,800039b6 <ireclaim+0xb4>
    80003980:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003984:	0044d793          	srli	a5,s1,0x4
    80003988:	018aa583          	lw	a1,24(s5)
    8000398c:	9dbd                	addw	a1,a1,a5
    8000398e:	8552                	mv	a0,s4
    80003990:	e9aff0ef          	jal	ra,8000302a <bread>
    80003994:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003996:	05850793          	addi	a5,a0,88
    8000399a:	00f9f713          	andi	a4,s3,15
    8000399e:	071a                	slli	a4,a4,0x6
    800039a0:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    800039a2:	00079703          	lh	a4,0(a5)
    800039a6:	c701                	beqz	a4,800039ae <ireclaim+0xac>
    800039a8:	00679783          	lh	a5,6(a5)
    800039ac:	dbc1                	beqz	a5,8000393c <ireclaim+0x3a>
    brelse(bp);
    800039ae:	854a                	mv	a0,s2
    800039b0:	f82ff0ef          	jal	ra,80003132 <brelse>
    if (ip) {
    800039b4:	bf7d                	j	80003972 <ireclaim+0x70>
}
    800039b6:	70e2                	ld	ra,56(sp)
    800039b8:	7442                	ld	s0,48(sp)
    800039ba:	74a2                	ld	s1,40(sp)
    800039bc:	7902                	ld	s2,32(sp)
    800039be:	69e2                	ld	s3,24(sp)
    800039c0:	6a42                	ld	s4,16(sp)
    800039c2:	6aa2                	ld	s5,8(sp)
    800039c4:	6b02                	ld	s6,0(sp)
    800039c6:	6121                	addi	sp,sp,64
    800039c8:	8082                	ret
    800039ca:	8082                	ret

00000000800039cc <fsinit>:
fsinit(int dev) {
    800039cc:	7179                	addi	sp,sp,-48
    800039ce:	f406                	sd	ra,40(sp)
    800039d0:	f022                	sd	s0,32(sp)
    800039d2:	ec26                	sd	s1,24(sp)
    800039d4:	e84a                	sd	s2,16(sp)
    800039d6:	e44e                	sd	s3,8(sp)
    800039d8:	1800                	addi	s0,sp,48
    800039da:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800039dc:	4585                	li	a1,1
    800039de:	e4cff0ef          	jal	ra,8000302a <bread>
    800039e2:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800039e4:	0002c997          	auipc	s3,0x2c
    800039e8:	fec98993          	addi	s3,s3,-20 # 8002f9d0 <sb>
    800039ec:	02000613          	li	a2,32
    800039f0:	05850593          	addi	a1,a0,88
    800039f4:	854e                	mv	a0,s3
    800039f6:	aa6fd0ef          	jal	ra,80000c9c <memmove>
  brelse(bp);
    800039fa:	854a                	mv	a0,s2
    800039fc:	f36ff0ef          	jal	ra,80003132 <brelse>
  if(sb.magic != FSMAGIC)
    80003a00:	0009a703          	lw	a4,0(s3)
    80003a04:	102037b7          	lui	a5,0x10203
    80003a08:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003a0c:	02f71363          	bne	a4,a5,80003a32 <fsinit+0x66>
  initlog(dev, &sb);
    80003a10:	0002c597          	auipc	a1,0x2c
    80003a14:	fc058593          	addi	a1,a1,-64 # 8002f9d0 <sb>
    80003a18:	8526                	mv	a0,s1
    80003a1a:	616000ef          	jal	ra,80004030 <initlog>
  ireclaim(dev);
    80003a1e:	8526                	mv	a0,s1
    80003a20:	ee3ff0ef          	jal	ra,80003902 <ireclaim>
}
    80003a24:	70a2                	ld	ra,40(sp)
    80003a26:	7402                	ld	s0,32(sp)
    80003a28:	64e2                	ld	s1,24(sp)
    80003a2a:	6942                	ld	s2,16(sp)
    80003a2c:	69a2                	ld	s3,8(sp)
    80003a2e:	6145                	addi	sp,sp,48
    80003a30:	8082                	ret
    panic("invalid file system");
    80003a32:	00004517          	auipc	a0,0x4
    80003a36:	dfe50513          	addi	a0,a0,-514 # 80007830 <syscalls+0x1a8>
    80003a3a:	d51fc0ef          	jal	ra,8000078a <panic>

0000000080003a3e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003a3e:	1141                	addi	sp,sp,-16
    80003a40:	e422                	sd	s0,8(sp)
    80003a42:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003a44:	411c                	lw	a5,0(a0)
    80003a46:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003a48:	415c                	lw	a5,4(a0)
    80003a4a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003a4c:	04451783          	lh	a5,68(a0)
    80003a50:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003a54:	04a51783          	lh	a5,74(a0)
    80003a58:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a5c:	04c56783          	lwu	a5,76(a0)
    80003a60:	e99c                	sd	a5,16(a1)
}
    80003a62:	6422                	ld	s0,8(sp)
    80003a64:	0141                	addi	sp,sp,16
    80003a66:	8082                	ret

0000000080003a68 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a68:	457c                	lw	a5,76(a0)
    80003a6a:	0cd7ef63          	bltu	a5,a3,80003b48 <readi+0xe0>
{
    80003a6e:	7159                	addi	sp,sp,-112
    80003a70:	f486                	sd	ra,104(sp)
    80003a72:	f0a2                	sd	s0,96(sp)
    80003a74:	eca6                	sd	s1,88(sp)
    80003a76:	e8ca                	sd	s2,80(sp)
    80003a78:	e4ce                	sd	s3,72(sp)
    80003a7a:	e0d2                	sd	s4,64(sp)
    80003a7c:	fc56                	sd	s5,56(sp)
    80003a7e:	f85a                	sd	s6,48(sp)
    80003a80:	f45e                	sd	s7,40(sp)
    80003a82:	f062                	sd	s8,32(sp)
    80003a84:	ec66                	sd	s9,24(sp)
    80003a86:	e86a                	sd	s10,16(sp)
    80003a88:	e46e                	sd	s11,8(sp)
    80003a8a:	1880                	addi	s0,sp,112
    80003a8c:	8b2a                	mv	s6,a0
    80003a8e:	8bae                	mv	s7,a1
    80003a90:	8a32                	mv	s4,a2
    80003a92:	84b6                	mv	s1,a3
    80003a94:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003a96:	9f35                	addw	a4,a4,a3
    return 0;
    80003a98:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a9a:	08d76663          	bltu	a4,a3,80003b26 <readi+0xbe>
  if(off + n > ip->size)
    80003a9e:	00e7f463          	bgeu	a5,a4,80003aa6 <readi+0x3e>
    n = ip->size - off;
    80003aa2:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003aa6:	080a8f63          	beqz	s5,80003b44 <readi+0xdc>
    80003aaa:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003aac:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003ab0:	5c7d                	li	s8,-1
    80003ab2:	a80d                	j	80003ae4 <readi+0x7c>
    80003ab4:	020d1d93          	slli	s11,s10,0x20
    80003ab8:	020ddd93          	srli	s11,s11,0x20
    80003abc:	05890793          	addi	a5,s2,88
    80003ac0:	86ee                	mv	a3,s11
    80003ac2:	963e                	add	a2,a2,a5
    80003ac4:	85d2                	mv	a1,s4
    80003ac6:	855e                	mv	a0,s7
    80003ac8:	c91fe0ef          	jal	ra,80002758 <either_copyout>
    80003acc:	05850763          	beq	a0,s8,80003b1a <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003ad0:	854a                	mv	a0,s2
    80003ad2:	e60ff0ef          	jal	ra,80003132 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ad6:	013d09bb          	addw	s3,s10,s3
    80003ada:	009d04bb          	addw	s1,s10,s1
    80003ade:	9a6e                	add	s4,s4,s11
    80003ae0:	0559f163          	bgeu	s3,s5,80003b22 <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    80003ae4:	00a4d59b          	srliw	a1,s1,0xa
    80003ae8:	855a                	mv	a0,s6
    80003aea:	8bbff0ef          	jal	ra,800033a4 <bmap>
    80003aee:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003af2:	c985                	beqz	a1,80003b22 <readi+0xba>
    bp = bread(ip->dev, addr);
    80003af4:	000b2503          	lw	a0,0(s6)
    80003af8:	d32ff0ef          	jal	ra,8000302a <bread>
    80003afc:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003afe:	3ff4f613          	andi	a2,s1,1023
    80003b02:	40cc87bb          	subw	a5,s9,a2
    80003b06:	413a873b          	subw	a4,s5,s3
    80003b0a:	8d3e                	mv	s10,a5
    80003b0c:	2781                	sext.w	a5,a5
    80003b0e:	0007069b          	sext.w	a3,a4
    80003b12:	faf6f1e3          	bgeu	a3,a5,80003ab4 <readi+0x4c>
    80003b16:	8d3a                	mv	s10,a4
    80003b18:	bf71                	j	80003ab4 <readi+0x4c>
      brelse(bp);
    80003b1a:	854a                	mv	a0,s2
    80003b1c:	e16ff0ef          	jal	ra,80003132 <brelse>
      tot = -1;
    80003b20:	59fd                	li	s3,-1
  }
  return tot;
    80003b22:	0009851b          	sext.w	a0,s3
}
    80003b26:	70a6                	ld	ra,104(sp)
    80003b28:	7406                	ld	s0,96(sp)
    80003b2a:	64e6                	ld	s1,88(sp)
    80003b2c:	6946                	ld	s2,80(sp)
    80003b2e:	69a6                	ld	s3,72(sp)
    80003b30:	6a06                	ld	s4,64(sp)
    80003b32:	7ae2                	ld	s5,56(sp)
    80003b34:	7b42                	ld	s6,48(sp)
    80003b36:	7ba2                	ld	s7,40(sp)
    80003b38:	7c02                	ld	s8,32(sp)
    80003b3a:	6ce2                	ld	s9,24(sp)
    80003b3c:	6d42                	ld	s10,16(sp)
    80003b3e:	6da2                	ld	s11,8(sp)
    80003b40:	6165                	addi	sp,sp,112
    80003b42:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b44:	89d6                	mv	s3,s5
    80003b46:	bff1                	j	80003b22 <readi+0xba>
    return 0;
    80003b48:	4501                	li	a0,0
}
    80003b4a:	8082                	ret

0000000080003b4c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b4c:	457c                	lw	a5,76(a0)
    80003b4e:	0ed7ea63          	bltu	a5,a3,80003c42 <writei+0xf6>
{
    80003b52:	7159                	addi	sp,sp,-112
    80003b54:	f486                	sd	ra,104(sp)
    80003b56:	f0a2                	sd	s0,96(sp)
    80003b58:	eca6                	sd	s1,88(sp)
    80003b5a:	e8ca                	sd	s2,80(sp)
    80003b5c:	e4ce                	sd	s3,72(sp)
    80003b5e:	e0d2                	sd	s4,64(sp)
    80003b60:	fc56                	sd	s5,56(sp)
    80003b62:	f85a                	sd	s6,48(sp)
    80003b64:	f45e                	sd	s7,40(sp)
    80003b66:	f062                	sd	s8,32(sp)
    80003b68:	ec66                	sd	s9,24(sp)
    80003b6a:	e86a                	sd	s10,16(sp)
    80003b6c:	e46e                	sd	s11,8(sp)
    80003b6e:	1880                	addi	s0,sp,112
    80003b70:	8aaa                	mv	s5,a0
    80003b72:	8bae                	mv	s7,a1
    80003b74:	8a32                	mv	s4,a2
    80003b76:	8936                	mv	s2,a3
    80003b78:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b7a:	00e687bb          	addw	a5,a3,a4
    80003b7e:	0cd7e463          	bltu	a5,a3,80003c46 <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b82:	00043737          	lui	a4,0x43
    80003b86:	0cf76263          	bltu	a4,a5,80003c4a <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b8a:	0a0b0a63          	beqz	s6,80003c3e <writei+0xf2>
    80003b8e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b90:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b94:	5c7d                	li	s8,-1
    80003b96:	a825                	j	80003bce <writei+0x82>
    80003b98:	020d1d93          	slli	s11,s10,0x20
    80003b9c:	020ddd93          	srli	s11,s11,0x20
    80003ba0:	05848793          	addi	a5,s1,88
    80003ba4:	86ee                	mv	a3,s11
    80003ba6:	8652                	mv	a2,s4
    80003ba8:	85de                	mv	a1,s7
    80003baa:	953e                	add	a0,a0,a5
    80003bac:	bf7fe0ef          	jal	ra,800027a2 <either_copyin>
    80003bb0:	05850a63          	beq	a0,s8,80003c04 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003bb4:	8526                	mv	a0,s1
    80003bb6:	688000ef          	jal	ra,8000423e <log_write>
    brelse(bp);
    80003bba:	8526                	mv	a0,s1
    80003bbc:	d76ff0ef          	jal	ra,80003132 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bc0:	013d09bb          	addw	s3,s10,s3
    80003bc4:	012d093b          	addw	s2,s10,s2
    80003bc8:	9a6e                	add	s4,s4,s11
    80003bca:	0569f063          	bgeu	s3,s6,80003c0a <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003bce:	00a9559b          	srliw	a1,s2,0xa
    80003bd2:	8556                	mv	a0,s5
    80003bd4:	fd0ff0ef          	jal	ra,800033a4 <bmap>
    80003bd8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003bdc:	c59d                	beqz	a1,80003c0a <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003bde:	000aa503          	lw	a0,0(s5)
    80003be2:	c48ff0ef          	jal	ra,8000302a <bread>
    80003be6:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003be8:	3ff97513          	andi	a0,s2,1023
    80003bec:	40ac87bb          	subw	a5,s9,a0
    80003bf0:	413b073b          	subw	a4,s6,s3
    80003bf4:	8d3e                	mv	s10,a5
    80003bf6:	2781                	sext.w	a5,a5
    80003bf8:	0007069b          	sext.w	a3,a4
    80003bfc:	f8f6fee3          	bgeu	a3,a5,80003b98 <writei+0x4c>
    80003c00:	8d3a                	mv	s10,a4
    80003c02:	bf59                	j	80003b98 <writei+0x4c>
      brelse(bp);
    80003c04:	8526                	mv	a0,s1
    80003c06:	d2cff0ef          	jal	ra,80003132 <brelse>
  }

  if(off > ip->size)
    80003c0a:	04caa783          	lw	a5,76(s5)
    80003c0e:	0127f463          	bgeu	a5,s2,80003c16 <writei+0xca>
    ip->size = off;
    80003c12:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003c16:	8556                	mv	a0,s5
    80003c18:	a13ff0ef          	jal	ra,8000362a <iupdate>

  return tot;
    80003c1c:	0009851b          	sext.w	a0,s3
}
    80003c20:	70a6                	ld	ra,104(sp)
    80003c22:	7406                	ld	s0,96(sp)
    80003c24:	64e6                	ld	s1,88(sp)
    80003c26:	6946                	ld	s2,80(sp)
    80003c28:	69a6                	ld	s3,72(sp)
    80003c2a:	6a06                	ld	s4,64(sp)
    80003c2c:	7ae2                	ld	s5,56(sp)
    80003c2e:	7b42                	ld	s6,48(sp)
    80003c30:	7ba2                	ld	s7,40(sp)
    80003c32:	7c02                	ld	s8,32(sp)
    80003c34:	6ce2                	ld	s9,24(sp)
    80003c36:	6d42                	ld	s10,16(sp)
    80003c38:	6da2                	ld	s11,8(sp)
    80003c3a:	6165                	addi	sp,sp,112
    80003c3c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c3e:	89da                	mv	s3,s6
    80003c40:	bfd9                	j	80003c16 <writei+0xca>
    return -1;
    80003c42:	557d                	li	a0,-1
}
    80003c44:	8082                	ret
    return -1;
    80003c46:	557d                	li	a0,-1
    80003c48:	bfe1                	j	80003c20 <writei+0xd4>
    return -1;
    80003c4a:	557d                	li	a0,-1
    80003c4c:	bfd1                	j	80003c20 <writei+0xd4>

0000000080003c4e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c4e:	1141                	addi	sp,sp,-16
    80003c50:	e406                	sd	ra,8(sp)
    80003c52:	e022                	sd	s0,0(sp)
    80003c54:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003c56:	4639                	li	a2,14
    80003c58:	8b4fd0ef          	jal	ra,80000d0c <strncmp>
}
    80003c5c:	60a2                	ld	ra,8(sp)
    80003c5e:	6402                	ld	s0,0(sp)
    80003c60:	0141                	addi	sp,sp,16
    80003c62:	8082                	ret

0000000080003c64 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c64:	7139                	addi	sp,sp,-64
    80003c66:	fc06                	sd	ra,56(sp)
    80003c68:	f822                	sd	s0,48(sp)
    80003c6a:	f426                	sd	s1,40(sp)
    80003c6c:	f04a                	sd	s2,32(sp)
    80003c6e:	ec4e                	sd	s3,24(sp)
    80003c70:	e852                	sd	s4,16(sp)
    80003c72:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c74:	04451703          	lh	a4,68(a0)
    80003c78:	4785                	li	a5,1
    80003c7a:	00f71a63          	bne	a4,a5,80003c8e <dirlookup+0x2a>
    80003c7e:	892a                	mv	s2,a0
    80003c80:	89ae                	mv	s3,a1
    80003c82:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c84:	457c                	lw	a5,76(a0)
    80003c86:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c88:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c8a:	e39d                	bnez	a5,80003cb0 <dirlookup+0x4c>
    80003c8c:	a095                	j	80003cf0 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003c8e:	00004517          	auipc	a0,0x4
    80003c92:	bba50513          	addi	a0,a0,-1094 # 80007848 <syscalls+0x1c0>
    80003c96:	af5fc0ef          	jal	ra,8000078a <panic>
      panic("dirlookup read");
    80003c9a:	00004517          	auipc	a0,0x4
    80003c9e:	bc650513          	addi	a0,a0,-1082 # 80007860 <syscalls+0x1d8>
    80003ca2:	ae9fc0ef          	jal	ra,8000078a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ca6:	24c1                	addiw	s1,s1,16
    80003ca8:	04c92783          	lw	a5,76(s2)
    80003cac:	04f4f163          	bgeu	s1,a5,80003cee <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003cb0:	4741                	li	a4,16
    80003cb2:	86a6                	mv	a3,s1
    80003cb4:	fc040613          	addi	a2,s0,-64
    80003cb8:	4581                	li	a1,0
    80003cba:	854a                	mv	a0,s2
    80003cbc:	dadff0ef          	jal	ra,80003a68 <readi>
    80003cc0:	47c1                	li	a5,16
    80003cc2:	fcf51ce3          	bne	a0,a5,80003c9a <dirlookup+0x36>
    if(de.inum == 0)
    80003cc6:	fc045783          	lhu	a5,-64(s0)
    80003cca:	dff1                	beqz	a5,80003ca6 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003ccc:	fc240593          	addi	a1,s0,-62
    80003cd0:	854e                	mv	a0,s3
    80003cd2:	f7dff0ef          	jal	ra,80003c4e <namecmp>
    80003cd6:	f961                	bnez	a0,80003ca6 <dirlookup+0x42>
      if(poff)
    80003cd8:	000a0463          	beqz	s4,80003ce0 <dirlookup+0x7c>
        *poff = off;
    80003cdc:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003ce0:	fc045583          	lhu	a1,-64(s0)
    80003ce4:	00092503          	lw	a0,0(s2)
    80003ce8:	f88ff0ef          	jal	ra,80003470 <iget>
    80003cec:	a011                	j	80003cf0 <dirlookup+0x8c>
  return 0;
    80003cee:	4501                	li	a0,0
}
    80003cf0:	70e2                	ld	ra,56(sp)
    80003cf2:	7442                	ld	s0,48(sp)
    80003cf4:	74a2                	ld	s1,40(sp)
    80003cf6:	7902                	ld	s2,32(sp)
    80003cf8:	69e2                	ld	s3,24(sp)
    80003cfa:	6a42                	ld	s4,16(sp)
    80003cfc:	6121                	addi	sp,sp,64
    80003cfe:	8082                	ret

0000000080003d00 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003d00:	711d                	addi	sp,sp,-96
    80003d02:	ec86                	sd	ra,88(sp)
    80003d04:	e8a2                	sd	s0,80(sp)
    80003d06:	e4a6                	sd	s1,72(sp)
    80003d08:	e0ca                	sd	s2,64(sp)
    80003d0a:	fc4e                	sd	s3,56(sp)
    80003d0c:	f852                	sd	s4,48(sp)
    80003d0e:	f456                	sd	s5,40(sp)
    80003d10:	f05a                	sd	s6,32(sp)
    80003d12:	ec5e                	sd	s7,24(sp)
    80003d14:	e862                	sd	s8,16(sp)
    80003d16:	e466                	sd	s9,8(sp)
    80003d18:	1080                	addi	s0,sp,96
    80003d1a:	84aa                	mv	s1,a0
    80003d1c:	8aae                	mv	s5,a1
    80003d1e:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003d20:	00054703          	lbu	a4,0(a0)
    80003d24:	02f00793          	li	a5,47
    80003d28:	00f70f63          	beq	a4,a5,80003d46 <namex+0x46>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003d2c:	8aefe0ef          	jal	ra,80001dda <myproc>
    80003d30:	15053503          	ld	a0,336(a0)
    80003d34:	973ff0ef          	jal	ra,800036a6 <idup>
    80003d38:	89aa                	mv	s3,a0
  while(*path == '/')
    80003d3a:	02f00913          	li	s2,47
  len = path - s;
    80003d3e:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003d40:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003d42:	4b85                	li	s7,1
    80003d44:	a861                	j	80003ddc <namex+0xdc>
    ip = iget(ROOTDEV, ROOTINO);
    80003d46:	4585                	li	a1,1
    80003d48:	4505                	li	a0,1
    80003d4a:	f26ff0ef          	jal	ra,80003470 <iget>
    80003d4e:	89aa                	mv	s3,a0
    80003d50:	b7ed                	j	80003d3a <namex+0x3a>
      iunlockput(ip);
    80003d52:	854e                	mv	a0,s3
    80003d54:	b8fff0ef          	jal	ra,800038e2 <iunlockput>
      return 0;
    80003d58:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d5a:	854e                	mv	a0,s3
    80003d5c:	60e6                	ld	ra,88(sp)
    80003d5e:	6446                	ld	s0,80(sp)
    80003d60:	64a6                	ld	s1,72(sp)
    80003d62:	6906                	ld	s2,64(sp)
    80003d64:	79e2                	ld	s3,56(sp)
    80003d66:	7a42                	ld	s4,48(sp)
    80003d68:	7aa2                	ld	s5,40(sp)
    80003d6a:	7b02                	ld	s6,32(sp)
    80003d6c:	6be2                	ld	s7,24(sp)
    80003d6e:	6c42                	ld	s8,16(sp)
    80003d70:	6ca2                	ld	s9,8(sp)
    80003d72:	6125                	addi	sp,sp,96
    80003d74:	8082                	ret
      iunlock(ip);
    80003d76:	854e                	mv	a0,s3
    80003d78:	a0fff0ef          	jal	ra,80003786 <iunlock>
      return ip;
    80003d7c:	bff9                	j	80003d5a <namex+0x5a>
      iunlockput(ip);
    80003d7e:	854e                	mv	a0,s3
    80003d80:	b63ff0ef          	jal	ra,800038e2 <iunlockput>
      return 0;
    80003d84:	89e6                	mv	s3,s9
    80003d86:	bfd1                	j	80003d5a <namex+0x5a>
  len = path - s;
    80003d88:	40b48633          	sub	a2,s1,a1
    80003d8c:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003d90:	079c5c63          	bge	s8,s9,80003e08 <namex+0x108>
    memmove(name, s, DIRSIZ);
    80003d94:	4639                	li	a2,14
    80003d96:	8552                	mv	a0,s4
    80003d98:	f05fc0ef          	jal	ra,80000c9c <memmove>
  while(*path == '/')
    80003d9c:	0004c783          	lbu	a5,0(s1)
    80003da0:	01279763          	bne	a5,s2,80003dae <namex+0xae>
    path++;
    80003da4:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003da6:	0004c783          	lbu	a5,0(s1)
    80003daa:	ff278de3          	beq	a5,s2,80003da4 <namex+0xa4>
    ilock(ip);
    80003dae:	854e                	mv	a0,s3
    80003db0:	92dff0ef          	jal	ra,800036dc <ilock>
    if(ip->type != T_DIR){
    80003db4:	04499783          	lh	a5,68(s3)
    80003db8:	f9779de3          	bne	a5,s7,80003d52 <namex+0x52>
    if(nameiparent && *path == '\0'){
    80003dbc:	000a8563          	beqz	s5,80003dc6 <namex+0xc6>
    80003dc0:	0004c783          	lbu	a5,0(s1)
    80003dc4:	dbcd                	beqz	a5,80003d76 <namex+0x76>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003dc6:	865a                	mv	a2,s6
    80003dc8:	85d2                	mv	a1,s4
    80003dca:	854e                	mv	a0,s3
    80003dcc:	e99ff0ef          	jal	ra,80003c64 <dirlookup>
    80003dd0:	8caa                	mv	s9,a0
    80003dd2:	d555                	beqz	a0,80003d7e <namex+0x7e>
    iunlockput(ip);
    80003dd4:	854e                	mv	a0,s3
    80003dd6:	b0dff0ef          	jal	ra,800038e2 <iunlockput>
    ip = next;
    80003dda:	89e6                	mv	s3,s9
  while(*path == '/')
    80003ddc:	0004c783          	lbu	a5,0(s1)
    80003de0:	05279363          	bne	a5,s2,80003e26 <namex+0x126>
    path++;
    80003de4:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003de6:	0004c783          	lbu	a5,0(s1)
    80003dea:	ff278de3          	beq	a5,s2,80003de4 <namex+0xe4>
  if(*path == 0)
    80003dee:	c78d                	beqz	a5,80003e18 <namex+0x118>
    path++;
    80003df0:	85a6                	mv	a1,s1
  len = path - s;
    80003df2:	8cda                	mv	s9,s6
    80003df4:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003df6:	01278963          	beq	a5,s2,80003e08 <namex+0x108>
    80003dfa:	d7d9                	beqz	a5,80003d88 <namex+0x88>
    path++;
    80003dfc:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003dfe:	0004c783          	lbu	a5,0(s1)
    80003e02:	ff279ce3          	bne	a5,s2,80003dfa <namex+0xfa>
    80003e06:	b749                	j	80003d88 <namex+0x88>
    memmove(name, s, len);
    80003e08:	2601                	sext.w	a2,a2
    80003e0a:	8552                	mv	a0,s4
    80003e0c:	e91fc0ef          	jal	ra,80000c9c <memmove>
    name[len] = 0;
    80003e10:	9cd2                	add	s9,s9,s4
    80003e12:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003e16:	b759                	j	80003d9c <namex+0x9c>
  if(nameiparent){
    80003e18:	f40a81e3          	beqz	s5,80003d5a <namex+0x5a>
    iput(ip);
    80003e1c:	854e                	mv	a0,s3
    80003e1e:	a3dff0ef          	jal	ra,8000385a <iput>
    return 0;
    80003e22:	4981                	li	s3,0
    80003e24:	bf1d                	j	80003d5a <namex+0x5a>
  if(*path == 0)
    80003e26:	dbed                	beqz	a5,80003e18 <namex+0x118>
  while(*path != '/' && *path != 0)
    80003e28:	0004c783          	lbu	a5,0(s1)
    80003e2c:	85a6                	mv	a1,s1
    80003e2e:	b7f1                	j	80003dfa <namex+0xfa>

0000000080003e30 <dirlink>:
{
    80003e30:	7139                	addi	sp,sp,-64
    80003e32:	fc06                	sd	ra,56(sp)
    80003e34:	f822                	sd	s0,48(sp)
    80003e36:	f426                	sd	s1,40(sp)
    80003e38:	f04a                	sd	s2,32(sp)
    80003e3a:	ec4e                	sd	s3,24(sp)
    80003e3c:	e852                	sd	s4,16(sp)
    80003e3e:	0080                	addi	s0,sp,64
    80003e40:	892a                	mv	s2,a0
    80003e42:	8a2e                	mv	s4,a1
    80003e44:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e46:	4601                	li	a2,0
    80003e48:	e1dff0ef          	jal	ra,80003c64 <dirlookup>
    80003e4c:	e52d                	bnez	a0,80003eb6 <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e4e:	04c92483          	lw	s1,76(s2)
    80003e52:	c48d                	beqz	s1,80003e7c <dirlink+0x4c>
    80003e54:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e56:	4741                	li	a4,16
    80003e58:	86a6                	mv	a3,s1
    80003e5a:	fc040613          	addi	a2,s0,-64
    80003e5e:	4581                	li	a1,0
    80003e60:	854a                	mv	a0,s2
    80003e62:	c07ff0ef          	jal	ra,80003a68 <readi>
    80003e66:	47c1                	li	a5,16
    80003e68:	04f51b63          	bne	a0,a5,80003ebe <dirlink+0x8e>
    if(de.inum == 0)
    80003e6c:	fc045783          	lhu	a5,-64(s0)
    80003e70:	c791                	beqz	a5,80003e7c <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e72:	24c1                	addiw	s1,s1,16
    80003e74:	04c92783          	lw	a5,76(s2)
    80003e78:	fcf4efe3          	bltu	s1,a5,80003e56 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003e7c:	4639                	li	a2,14
    80003e7e:	85d2                	mv	a1,s4
    80003e80:	fc240513          	addi	a0,s0,-62
    80003e84:	ec5fc0ef          	jal	ra,80000d48 <strncpy>
  de.inum = inum;
    80003e88:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e8c:	4741                	li	a4,16
    80003e8e:	86a6                	mv	a3,s1
    80003e90:	fc040613          	addi	a2,s0,-64
    80003e94:	4581                	li	a1,0
    80003e96:	854a                	mv	a0,s2
    80003e98:	cb5ff0ef          	jal	ra,80003b4c <writei>
    80003e9c:	1541                	addi	a0,a0,-16
    80003e9e:	00a03533          	snez	a0,a0
    80003ea2:	40a00533          	neg	a0,a0
}
    80003ea6:	70e2                	ld	ra,56(sp)
    80003ea8:	7442                	ld	s0,48(sp)
    80003eaa:	74a2                	ld	s1,40(sp)
    80003eac:	7902                	ld	s2,32(sp)
    80003eae:	69e2                	ld	s3,24(sp)
    80003eb0:	6a42                	ld	s4,16(sp)
    80003eb2:	6121                	addi	sp,sp,64
    80003eb4:	8082                	ret
    iput(ip);
    80003eb6:	9a5ff0ef          	jal	ra,8000385a <iput>
    return -1;
    80003eba:	557d                	li	a0,-1
    80003ebc:	b7ed                	j	80003ea6 <dirlink+0x76>
      panic("dirlink read");
    80003ebe:	00004517          	auipc	a0,0x4
    80003ec2:	9b250513          	addi	a0,a0,-1614 # 80007870 <syscalls+0x1e8>
    80003ec6:	8c5fc0ef          	jal	ra,8000078a <panic>

0000000080003eca <namei>:

struct inode*
namei(char *path)
{
    80003eca:	1101                	addi	sp,sp,-32
    80003ecc:	ec06                	sd	ra,24(sp)
    80003ece:	e822                	sd	s0,16(sp)
    80003ed0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003ed2:	fe040613          	addi	a2,s0,-32
    80003ed6:	4581                	li	a1,0
    80003ed8:	e29ff0ef          	jal	ra,80003d00 <namex>
}
    80003edc:	60e2                	ld	ra,24(sp)
    80003ede:	6442                	ld	s0,16(sp)
    80003ee0:	6105                	addi	sp,sp,32
    80003ee2:	8082                	ret

0000000080003ee4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003ee4:	1141                	addi	sp,sp,-16
    80003ee6:	e406                	sd	ra,8(sp)
    80003ee8:	e022                	sd	s0,0(sp)
    80003eea:	0800                	addi	s0,sp,16
    80003eec:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003eee:	4585                	li	a1,1
    80003ef0:	e11ff0ef          	jal	ra,80003d00 <namex>
}
    80003ef4:	60a2                	ld	ra,8(sp)
    80003ef6:	6402                	ld	s0,0(sp)
    80003ef8:	0141                	addi	sp,sp,16
    80003efa:	8082                	ret

0000000080003efc <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003efc:	1101                	addi	sp,sp,-32
    80003efe:	ec06                	sd	ra,24(sp)
    80003f00:	e822                	sd	s0,16(sp)
    80003f02:	e426                	sd	s1,8(sp)
    80003f04:	e04a                	sd	s2,0(sp)
    80003f06:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003f08:	0002d917          	auipc	s2,0x2d
    80003f0c:	59090913          	addi	s2,s2,1424 # 80031498 <log>
    80003f10:	01892583          	lw	a1,24(s2)
    80003f14:	02492503          	lw	a0,36(s2)
    80003f18:	912ff0ef          	jal	ra,8000302a <bread>
    80003f1c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003f1e:	02892683          	lw	a3,40(s2)
    80003f22:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003f24:	02d05763          	blez	a3,80003f52 <write_head+0x56>
    80003f28:	0002d797          	auipc	a5,0x2d
    80003f2c:	59c78793          	addi	a5,a5,1436 # 800314c4 <log+0x2c>
    80003f30:	05c50713          	addi	a4,a0,92
    80003f34:	36fd                	addiw	a3,a3,-1
    80003f36:	1682                	slli	a3,a3,0x20
    80003f38:	9281                	srli	a3,a3,0x20
    80003f3a:	068a                	slli	a3,a3,0x2
    80003f3c:	0002d617          	auipc	a2,0x2d
    80003f40:	58c60613          	addi	a2,a2,1420 # 800314c8 <log+0x30>
    80003f44:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003f46:	4390                	lw	a2,0(a5)
    80003f48:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003f4a:	0791                	addi	a5,a5,4
    80003f4c:	0711                	addi	a4,a4,4
    80003f4e:	fed79ce3          	bne	a5,a3,80003f46 <write_head+0x4a>
  }
  bwrite(buf);
    80003f52:	8526                	mv	a0,s1
    80003f54:	9acff0ef          	jal	ra,80003100 <bwrite>
  brelse(buf);
    80003f58:	8526                	mv	a0,s1
    80003f5a:	9d8ff0ef          	jal	ra,80003132 <brelse>
}
    80003f5e:	60e2                	ld	ra,24(sp)
    80003f60:	6442                	ld	s0,16(sp)
    80003f62:	64a2                	ld	s1,8(sp)
    80003f64:	6902                	ld	s2,0(sp)
    80003f66:	6105                	addi	sp,sp,32
    80003f68:	8082                	ret

0000000080003f6a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f6a:	0002d797          	auipc	a5,0x2d
    80003f6e:	5567a783          	lw	a5,1366(a5) # 800314c0 <log+0x28>
    80003f72:	0af05e63          	blez	a5,8000402e <install_trans+0xc4>
{
    80003f76:	715d                	addi	sp,sp,-80
    80003f78:	e486                	sd	ra,72(sp)
    80003f7a:	e0a2                	sd	s0,64(sp)
    80003f7c:	fc26                	sd	s1,56(sp)
    80003f7e:	f84a                	sd	s2,48(sp)
    80003f80:	f44e                	sd	s3,40(sp)
    80003f82:	f052                	sd	s4,32(sp)
    80003f84:	ec56                	sd	s5,24(sp)
    80003f86:	e85a                	sd	s6,16(sp)
    80003f88:	e45e                	sd	s7,8(sp)
    80003f8a:	0880                	addi	s0,sp,80
    80003f8c:	8b2a                	mv	s6,a0
    80003f8e:	0002da97          	auipc	s5,0x2d
    80003f92:	536a8a93          	addi	s5,s5,1334 # 800314c4 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f96:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003f98:	00004b97          	auipc	s7,0x4
    80003f9c:	8e8b8b93          	addi	s7,s7,-1816 # 80007880 <syscalls+0x1f8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003fa0:	0002da17          	auipc	s4,0x2d
    80003fa4:	4f8a0a13          	addi	s4,s4,1272 # 80031498 <log>
    80003fa8:	a025                	j	80003fd0 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003faa:	000aa603          	lw	a2,0(s5)
    80003fae:	85ce                	mv	a1,s3
    80003fb0:	855e                	mv	a0,s7
    80003fb2:	d12fc0ef          	jal	ra,800004c4 <printf>
    80003fb6:	a839                	j	80003fd4 <install_trans+0x6a>
    brelse(lbuf);
    80003fb8:	854a                	mv	a0,s2
    80003fba:	978ff0ef          	jal	ra,80003132 <brelse>
    brelse(dbuf);
    80003fbe:	8526                	mv	a0,s1
    80003fc0:	972ff0ef          	jal	ra,80003132 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fc4:	2985                	addiw	s3,s3,1
    80003fc6:	0a91                	addi	s5,s5,4
    80003fc8:	028a2783          	lw	a5,40(s4)
    80003fcc:	04f9d663          	bge	s3,a5,80004018 <install_trans+0xae>
    if(recovering) {
    80003fd0:	fc0b1de3          	bnez	s6,80003faa <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003fd4:	018a2583          	lw	a1,24(s4)
    80003fd8:	013585bb          	addw	a1,a1,s3
    80003fdc:	2585                	addiw	a1,a1,1
    80003fde:	024a2503          	lw	a0,36(s4)
    80003fe2:	848ff0ef          	jal	ra,8000302a <bread>
    80003fe6:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003fe8:	000aa583          	lw	a1,0(s5)
    80003fec:	024a2503          	lw	a0,36(s4)
    80003ff0:	83aff0ef          	jal	ra,8000302a <bread>
    80003ff4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003ff6:	40000613          	li	a2,1024
    80003ffa:	05890593          	addi	a1,s2,88
    80003ffe:	05850513          	addi	a0,a0,88
    80004002:	c9bfc0ef          	jal	ra,80000c9c <memmove>
    bwrite(dbuf);  // write dst to disk
    80004006:	8526                	mv	a0,s1
    80004008:	8f8ff0ef          	jal	ra,80003100 <bwrite>
    if(recovering == 0)
    8000400c:	fa0b16e3          	bnez	s6,80003fb8 <install_trans+0x4e>
      bunpin(dbuf);
    80004010:	8526                	mv	a0,s1
    80004012:	9deff0ef          	jal	ra,800031f0 <bunpin>
    80004016:	b74d                	j	80003fb8 <install_trans+0x4e>
}
    80004018:	60a6                	ld	ra,72(sp)
    8000401a:	6406                	ld	s0,64(sp)
    8000401c:	74e2                	ld	s1,56(sp)
    8000401e:	7942                	ld	s2,48(sp)
    80004020:	79a2                	ld	s3,40(sp)
    80004022:	7a02                	ld	s4,32(sp)
    80004024:	6ae2                	ld	s5,24(sp)
    80004026:	6b42                	ld	s6,16(sp)
    80004028:	6ba2                	ld	s7,8(sp)
    8000402a:	6161                	addi	sp,sp,80
    8000402c:	8082                	ret
    8000402e:	8082                	ret

0000000080004030 <initlog>:
{
    80004030:	7179                	addi	sp,sp,-48
    80004032:	f406                	sd	ra,40(sp)
    80004034:	f022                	sd	s0,32(sp)
    80004036:	ec26                	sd	s1,24(sp)
    80004038:	e84a                	sd	s2,16(sp)
    8000403a:	e44e                	sd	s3,8(sp)
    8000403c:	1800                	addi	s0,sp,48
    8000403e:	892a                	mv	s2,a0
    80004040:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004042:	0002d497          	auipc	s1,0x2d
    80004046:	45648493          	addi	s1,s1,1110 # 80031498 <log>
    8000404a:	00004597          	auipc	a1,0x4
    8000404e:	85658593          	addi	a1,a1,-1962 # 800078a0 <syscalls+0x218>
    80004052:	8526                	mv	a0,s1
    80004054:	a99fc0ef          	jal	ra,80000aec <initlock>
  log.start = sb->logstart;
    80004058:	0149a583          	lw	a1,20(s3)
    8000405c:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    8000405e:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004062:	854a                	mv	a0,s2
    80004064:	fc7fe0ef          	jal	ra,8000302a <bread>
  log.lh.n = lh->n;
    80004068:	4d34                	lw	a3,88(a0)
    8000406a:	d494                	sw	a3,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000406c:	02d05563          	blez	a3,80004096 <initlog+0x66>
    80004070:	05c50793          	addi	a5,a0,92
    80004074:	0002d717          	auipc	a4,0x2d
    80004078:	45070713          	addi	a4,a4,1104 # 800314c4 <log+0x2c>
    8000407c:	36fd                	addiw	a3,a3,-1
    8000407e:	1682                	slli	a3,a3,0x20
    80004080:	9281                	srli	a3,a3,0x20
    80004082:	068a                	slli	a3,a3,0x2
    80004084:	06050613          	addi	a2,a0,96
    80004088:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000408a:	4390                	lw	a2,0(a5)
    8000408c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000408e:	0791                	addi	a5,a5,4
    80004090:	0711                	addi	a4,a4,4
    80004092:	fed79ce3          	bne	a5,a3,8000408a <initlog+0x5a>
  brelse(buf);
    80004096:	89cff0ef          	jal	ra,80003132 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000409a:	4505                	li	a0,1
    8000409c:	ecfff0ef          	jal	ra,80003f6a <install_trans>
  log.lh.n = 0;
    800040a0:	0002d797          	auipc	a5,0x2d
    800040a4:	4207a023          	sw	zero,1056(a5) # 800314c0 <log+0x28>
  write_head(); // clear the log
    800040a8:	e55ff0ef          	jal	ra,80003efc <write_head>
}
    800040ac:	70a2                	ld	ra,40(sp)
    800040ae:	7402                	ld	s0,32(sp)
    800040b0:	64e2                	ld	s1,24(sp)
    800040b2:	6942                	ld	s2,16(sp)
    800040b4:	69a2                	ld	s3,8(sp)
    800040b6:	6145                	addi	sp,sp,48
    800040b8:	8082                	ret

00000000800040ba <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800040ba:	1101                	addi	sp,sp,-32
    800040bc:	ec06                	sd	ra,24(sp)
    800040be:	e822                	sd	s0,16(sp)
    800040c0:	e426                	sd	s1,8(sp)
    800040c2:	e04a                	sd	s2,0(sp)
    800040c4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800040c6:	0002d517          	auipc	a0,0x2d
    800040ca:	3d250513          	addi	a0,a0,978 # 80031498 <log>
    800040ce:	a9ffc0ef          	jal	ra,80000b6c <acquire>
  while(1){
    if(log.committing){
    800040d2:	0002d497          	auipc	s1,0x2d
    800040d6:	3c648493          	addi	s1,s1,966 # 80031498 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800040da:	4979                	li	s2,30
    800040dc:	a029                	j	800040e6 <begin_op+0x2c>
      sleep(&log, &log.lock);
    800040de:	85a6                	mv	a1,s1
    800040e0:	8526                	mv	a0,s1
    800040e2:	b1afe0ef          	jal	ra,800023fc <sleep>
    if(log.committing){
    800040e6:	509c                	lw	a5,32(s1)
    800040e8:	fbfd                	bnez	a5,800040de <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800040ea:	4cdc                	lw	a5,28(s1)
    800040ec:	0017871b          	addiw	a4,a5,1
    800040f0:	0007069b          	sext.w	a3,a4
    800040f4:	0027179b          	slliw	a5,a4,0x2
    800040f8:	9fb9                	addw	a5,a5,a4
    800040fa:	0017979b          	slliw	a5,a5,0x1
    800040fe:	5498                	lw	a4,40(s1)
    80004100:	9fb9                	addw	a5,a5,a4
    80004102:	00f95763          	bge	s2,a5,80004110 <begin_op+0x56>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004106:	85a6                	mv	a1,s1
    80004108:	8526                	mv	a0,s1
    8000410a:	af2fe0ef          	jal	ra,800023fc <sleep>
    8000410e:	bfe1                	j	800040e6 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80004110:	0002d517          	auipc	a0,0x2d
    80004114:	38850513          	addi	a0,a0,904 # 80031498 <log>
    80004118:	cd54                	sw	a3,28(a0)
      release(&log.lock);
    8000411a:	aebfc0ef          	jal	ra,80000c04 <release>
      break;
    }
  }
}
    8000411e:	60e2                	ld	ra,24(sp)
    80004120:	6442                	ld	s0,16(sp)
    80004122:	64a2                	ld	s1,8(sp)
    80004124:	6902                	ld	s2,0(sp)
    80004126:	6105                	addi	sp,sp,32
    80004128:	8082                	ret

000000008000412a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000412a:	7139                	addi	sp,sp,-64
    8000412c:	fc06                	sd	ra,56(sp)
    8000412e:	f822                	sd	s0,48(sp)
    80004130:	f426                	sd	s1,40(sp)
    80004132:	f04a                	sd	s2,32(sp)
    80004134:	ec4e                	sd	s3,24(sp)
    80004136:	e852                	sd	s4,16(sp)
    80004138:	e456                	sd	s5,8(sp)
    8000413a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000413c:	0002d497          	auipc	s1,0x2d
    80004140:	35c48493          	addi	s1,s1,860 # 80031498 <log>
    80004144:	8526                	mv	a0,s1
    80004146:	a27fc0ef          	jal	ra,80000b6c <acquire>
  log.outstanding -= 1;
    8000414a:	4cdc                	lw	a5,28(s1)
    8000414c:	37fd                	addiw	a5,a5,-1
    8000414e:	0007891b          	sext.w	s2,a5
    80004152:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80004154:	509c                	lw	a5,32(s1)
    80004156:	ef9d                	bnez	a5,80004194 <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    80004158:	04091463          	bnez	s2,800041a0 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    8000415c:	0002d497          	auipc	s1,0x2d
    80004160:	33c48493          	addi	s1,s1,828 # 80031498 <log>
    80004164:	4785                	li	a5,1
    80004166:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004168:	8526                	mv	a0,s1
    8000416a:	a9bfc0ef          	jal	ra,80000c04 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000416e:	549c                	lw	a5,40(s1)
    80004170:	04f04b63          	bgtz	a5,800041c6 <end_op+0x9c>
    acquire(&log.lock);
    80004174:	0002d497          	auipc	s1,0x2d
    80004178:	32448493          	addi	s1,s1,804 # 80031498 <log>
    8000417c:	8526                	mv	a0,s1
    8000417e:	9effc0ef          	jal	ra,80000b6c <acquire>
    log.committing = 0;
    80004182:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80004186:	8526                	mv	a0,s1
    80004188:	ac0fe0ef          	jal	ra,80002448 <wakeup>
    release(&log.lock);
    8000418c:	8526                	mv	a0,s1
    8000418e:	a77fc0ef          	jal	ra,80000c04 <release>
}
    80004192:	a00d                	j	800041b4 <end_op+0x8a>
    panic("log.committing");
    80004194:	00003517          	auipc	a0,0x3
    80004198:	71450513          	addi	a0,a0,1812 # 800078a8 <syscalls+0x220>
    8000419c:	deefc0ef          	jal	ra,8000078a <panic>
    wakeup(&log);
    800041a0:	0002d497          	auipc	s1,0x2d
    800041a4:	2f848493          	addi	s1,s1,760 # 80031498 <log>
    800041a8:	8526                	mv	a0,s1
    800041aa:	a9efe0ef          	jal	ra,80002448 <wakeup>
  release(&log.lock);
    800041ae:	8526                	mv	a0,s1
    800041b0:	a55fc0ef          	jal	ra,80000c04 <release>
}
    800041b4:	70e2                	ld	ra,56(sp)
    800041b6:	7442                	ld	s0,48(sp)
    800041b8:	74a2                	ld	s1,40(sp)
    800041ba:	7902                	ld	s2,32(sp)
    800041bc:	69e2                	ld	s3,24(sp)
    800041be:	6a42                	ld	s4,16(sp)
    800041c0:	6aa2                	ld	s5,8(sp)
    800041c2:	6121                	addi	sp,sp,64
    800041c4:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800041c6:	0002da97          	auipc	s5,0x2d
    800041ca:	2fea8a93          	addi	s5,s5,766 # 800314c4 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800041ce:	0002da17          	auipc	s4,0x2d
    800041d2:	2caa0a13          	addi	s4,s4,714 # 80031498 <log>
    800041d6:	018a2583          	lw	a1,24(s4)
    800041da:	012585bb          	addw	a1,a1,s2
    800041de:	2585                	addiw	a1,a1,1
    800041e0:	024a2503          	lw	a0,36(s4)
    800041e4:	e47fe0ef          	jal	ra,8000302a <bread>
    800041e8:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800041ea:	000aa583          	lw	a1,0(s5)
    800041ee:	024a2503          	lw	a0,36(s4)
    800041f2:	e39fe0ef          	jal	ra,8000302a <bread>
    800041f6:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800041f8:	40000613          	li	a2,1024
    800041fc:	05850593          	addi	a1,a0,88
    80004200:	05848513          	addi	a0,s1,88
    80004204:	a99fc0ef          	jal	ra,80000c9c <memmove>
    bwrite(to);  // write the log
    80004208:	8526                	mv	a0,s1
    8000420a:	ef7fe0ef          	jal	ra,80003100 <bwrite>
    brelse(from);
    8000420e:	854e                	mv	a0,s3
    80004210:	f23fe0ef          	jal	ra,80003132 <brelse>
    brelse(to);
    80004214:	8526                	mv	a0,s1
    80004216:	f1dfe0ef          	jal	ra,80003132 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000421a:	2905                	addiw	s2,s2,1
    8000421c:	0a91                	addi	s5,s5,4
    8000421e:	028a2783          	lw	a5,40(s4)
    80004222:	faf94ae3          	blt	s2,a5,800041d6 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004226:	cd7ff0ef          	jal	ra,80003efc <write_head>
    install_trans(0); // Now install writes to home locations
    8000422a:	4501                	li	a0,0
    8000422c:	d3fff0ef          	jal	ra,80003f6a <install_trans>
    log.lh.n = 0;
    80004230:	0002d797          	auipc	a5,0x2d
    80004234:	2807a823          	sw	zero,656(a5) # 800314c0 <log+0x28>
    write_head();    // Erase the transaction from the log
    80004238:	cc5ff0ef          	jal	ra,80003efc <write_head>
    8000423c:	bf25                	j	80004174 <end_op+0x4a>

000000008000423e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000423e:	1101                	addi	sp,sp,-32
    80004240:	ec06                	sd	ra,24(sp)
    80004242:	e822                	sd	s0,16(sp)
    80004244:	e426                	sd	s1,8(sp)
    80004246:	e04a                	sd	s2,0(sp)
    80004248:	1000                	addi	s0,sp,32
    8000424a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000424c:	0002d917          	auipc	s2,0x2d
    80004250:	24c90913          	addi	s2,s2,588 # 80031498 <log>
    80004254:	854a                	mv	a0,s2
    80004256:	917fc0ef          	jal	ra,80000b6c <acquire>
  if (log.lh.n >= LOGBLOCKS)
    8000425a:	02892603          	lw	a2,40(s2)
    8000425e:	47f5                	li	a5,29
    80004260:	04c7cc63          	blt	a5,a2,800042b8 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004264:	0002d797          	auipc	a5,0x2d
    80004268:	2507a783          	lw	a5,592(a5) # 800314b4 <log+0x1c>
    8000426c:	04f05c63          	blez	a5,800042c4 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004270:	4781                	li	a5,0
    80004272:	04c05f63          	blez	a2,800042d0 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004276:	44cc                	lw	a1,12(s1)
    80004278:	0002d717          	auipc	a4,0x2d
    8000427c:	24c70713          	addi	a4,a4,588 # 800314c4 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004280:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004282:	4314                	lw	a3,0(a4)
    80004284:	04b68663          	beq	a3,a1,800042d0 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80004288:	2785                	addiw	a5,a5,1
    8000428a:	0711                	addi	a4,a4,4
    8000428c:	fef61be3          	bne	a2,a5,80004282 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004290:	0621                	addi	a2,a2,8
    80004292:	060a                	slli	a2,a2,0x2
    80004294:	0002d797          	auipc	a5,0x2d
    80004298:	20478793          	addi	a5,a5,516 # 80031498 <log>
    8000429c:	963e                	add	a2,a2,a5
    8000429e:	44dc                	lw	a5,12(s1)
    800042a0:	c65c                	sw	a5,12(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800042a2:	8526                	mv	a0,s1
    800042a4:	f19fe0ef          	jal	ra,800031bc <bpin>
    log.lh.n++;
    800042a8:	0002d717          	auipc	a4,0x2d
    800042ac:	1f070713          	addi	a4,a4,496 # 80031498 <log>
    800042b0:	571c                	lw	a5,40(a4)
    800042b2:	2785                	addiw	a5,a5,1
    800042b4:	d71c                	sw	a5,40(a4)
    800042b6:	a815                	j	800042ea <log_write+0xac>
    panic("too big a transaction");
    800042b8:	00003517          	auipc	a0,0x3
    800042bc:	60050513          	addi	a0,a0,1536 # 800078b8 <syscalls+0x230>
    800042c0:	ccafc0ef          	jal	ra,8000078a <panic>
    panic("log_write outside of trans");
    800042c4:	00003517          	auipc	a0,0x3
    800042c8:	60c50513          	addi	a0,a0,1548 # 800078d0 <syscalls+0x248>
    800042cc:	cbefc0ef          	jal	ra,8000078a <panic>
  log.lh.block[i] = b->blockno;
    800042d0:	00878713          	addi	a4,a5,8
    800042d4:	00271693          	slli	a3,a4,0x2
    800042d8:	0002d717          	auipc	a4,0x2d
    800042dc:	1c070713          	addi	a4,a4,448 # 80031498 <log>
    800042e0:	9736                	add	a4,a4,a3
    800042e2:	44d4                	lw	a3,12(s1)
    800042e4:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800042e6:	faf60ee3          	beq	a2,a5,800042a2 <log_write+0x64>
  }
  release(&log.lock);
    800042ea:	0002d517          	auipc	a0,0x2d
    800042ee:	1ae50513          	addi	a0,a0,430 # 80031498 <log>
    800042f2:	913fc0ef          	jal	ra,80000c04 <release>
}
    800042f6:	60e2                	ld	ra,24(sp)
    800042f8:	6442                	ld	s0,16(sp)
    800042fa:	64a2                	ld	s1,8(sp)
    800042fc:	6902                	ld	s2,0(sp)
    800042fe:	6105                	addi	sp,sp,32
    80004300:	8082                	ret

0000000080004302 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004302:	1101                	addi	sp,sp,-32
    80004304:	ec06                	sd	ra,24(sp)
    80004306:	e822                	sd	s0,16(sp)
    80004308:	e426                	sd	s1,8(sp)
    8000430a:	e04a                	sd	s2,0(sp)
    8000430c:	1000                	addi	s0,sp,32
    8000430e:	84aa                	mv	s1,a0
    80004310:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004312:	00003597          	auipc	a1,0x3
    80004316:	5de58593          	addi	a1,a1,1502 # 800078f0 <syscalls+0x268>
    8000431a:	0521                	addi	a0,a0,8
    8000431c:	fd0fc0ef          	jal	ra,80000aec <initlock>
  lk->name = name;
    80004320:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004324:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004328:	0204a423          	sw	zero,40(s1)
}
    8000432c:	60e2                	ld	ra,24(sp)
    8000432e:	6442                	ld	s0,16(sp)
    80004330:	64a2                	ld	s1,8(sp)
    80004332:	6902                	ld	s2,0(sp)
    80004334:	6105                	addi	sp,sp,32
    80004336:	8082                	ret

0000000080004338 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004338:	1101                	addi	sp,sp,-32
    8000433a:	ec06                	sd	ra,24(sp)
    8000433c:	e822                	sd	s0,16(sp)
    8000433e:	e426                	sd	s1,8(sp)
    80004340:	e04a                	sd	s2,0(sp)
    80004342:	1000                	addi	s0,sp,32
    80004344:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004346:	00850913          	addi	s2,a0,8
    8000434a:	854a                	mv	a0,s2
    8000434c:	821fc0ef          	jal	ra,80000b6c <acquire>
  while (lk->locked) {
    80004350:	409c                	lw	a5,0(s1)
    80004352:	c799                	beqz	a5,80004360 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004354:	85ca                	mv	a1,s2
    80004356:	8526                	mv	a0,s1
    80004358:	8a4fe0ef          	jal	ra,800023fc <sleep>
  while (lk->locked) {
    8000435c:	409c                	lw	a5,0(s1)
    8000435e:	fbfd                	bnez	a5,80004354 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004360:	4785                	li	a5,1
    80004362:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004364:	a77fd0ef          	jal	ra,80001dda <myproc>
    80004368:	591c                	lw	a5,48(a0)
    8000436a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000436c:	854a                	mv	a0,s2
    8000436e:	897fc0ef          	jal	ra,80000c04 <release>
}
    80004372:	60e2                	ld	ra,24(sp)
    80004374:	6442                	ld	s0,16(sp)
    80004376:	64a2                	ld	s1,8(sp)
    80004378:	6902                	ld	s2,0(sp)
    8000437a:	6105                	addi	sp,sp,32
    8000437c:	8082                	ret

000000008000437e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000437e:	1101                	addi	sp,sp,-32
    80004380:	ec06                	sd	ra,24(sp)
    80004382:	e822                	sd	s0,16(sp)
    80004384:	e426                	sd	s1,8(sp)
    80004386:	e04a                	sd	s2,0(sp)
    80004388:	1000                	addi	s0,sp,32
    8000438a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000438c:	00850913          	addi	s2,a0,8
    80004390:	854a                	mv	a0,s2
    80004392:	fdafc0ef          	jal	ra,80000b6c <acquire>
  lk->locked = 0;
    80004396:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000439a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000439e:	8526                	mv	a0,s1
    800043a0:	8a8fe0ef          	jal	ra,80002448 <wakeup>
  release(&lk->lk);
    800043a4:	854a                	mv	a0,s2
    800043a6:	85ffc0ef          	jal	ra,80000c04 <release>
}
    800043aa:	60e2                	ld	ra,24(sp)
    800043ac:	6442                	ld	s0,16(sp)
    800043ae:	64a2                	ld	s1,8(sp)
    800043b0:	6902                	ld	s2,0(sp)
    800043b2:	6105                	addi	sp,sp,32
    800043b4:	8082                	ret

00000000800043b6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800043b6:	7179                	addi	sp,sp,-48
    800043b8:	f406                	sd	ra,40(sp)
    800043ba:	f022                	sd	s0,32(sp)
    800043bc:	ec26                	sd	s1,24(sp)
    800043be:	e84a                	sd	s2,16(sp)
    800043c0:	e44e                	sd	s3,8(sp)
    800043c2:	1800                	addi	s0,sp,48
    800043c4:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800043c6:	00850913          	addi	s2,a0,8
    800043ca:	854a                	mv	a0,s2
    800043cc:	fa0fc0ef          	jal	ra,80000b6c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800043d0:	409c                	lw	a5,0(s1)
    800043d2:	ef89                	bnez	a5,800043ec <holdingsleep+0x36>
    800043d4:	4481                	li	s1,0
  release(&lk->lk);
    800043d6:	854a                	mv	a0,s2
    800043d8:	82dfc0ef          	jal	ra,80000c04 <release>
  return r;
}
    800043dc:	8526                	mv	a0,s1
    800043de:	70a2                	ld	ra,40(sp)
    800043e0:	7402                	ld	s0,32(sp)
    800043e2:	64e2                	ld	s1,24(sp)
    800043e4:	6942                	ld	s2,16(sp)
    800043e6:	69a2                	ld	s3,8(sp)
    800043e8:	6145                	addi	sp,sp,48
    800043ea:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800043ec:	0284a983          	lw	s3,40(s1)
    800043f0:	9ebfd0ef          	jal	ra,80001dda <myproc>
    800043f4:	5904                	lw	s1,48(a0)
    800043f6:	413484b3          	sub	s1,s1,s3
    800043fa:	0014b493          	seqz	s1,s1
    800043fe:	bfe1                	j	800043d6 <holdingsleep+0x20>

0000000080004400 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004400:	1141                	addi	sp,sp,-16
    80004402:	e406                	sd	ra,8(sp)
    80004404:	e022                	sd	s0,0(sp)
    80004406:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004408:	00003597          	auipc	a1,0x3
    8000440c:	4f858593          	addi	a1,a1,1272 # 80007900 <syscalls+0x278>
    80004410:	0002d517          	auipc	a0,0x2d
    80004414:	1d050513          	addi	a0,a0,464 # 800315e0 <ftable>
    80004418:	ed4fc0ef          	jal	ra,80000aec <initlock>
}
    8000441c:	60a2                	ld	ra,8(sp)
    8000441e:	6402                	ld	s0,0(sp)
    80004420:	0141                	addi	sp,sp,16
    80004422:	8082                	ret

0000000080004424 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004424:	1101                	addi	sp,sp,-32
    80004426:	ec06                	sd	ra,24(sp)
    80004428:	e822                	sd	s0,16(sp)
    8000442a:	e426                	sd	s1,8(sp)
    8000442c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000442e:	0002d517          	auipc	a0,0x2d
    80004432:	1b250513          	addi	a0,a0,434 # 800315e0 <ftable>
    80004436:	f36fc0ef          	jal	ra,80000b6c <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000443a:	0002d497          	auipc	s1,0x2d
    8000443e:	1be48493          	addi	s1,s1,446 # 800315f8 <ftable+0x18>
    80004442:	0002e717          	auipc	a4,0x2e
    80004446:	15670713          	addi	a4,a4,342 # 80032598 <disk>
    if(f->ref == 0){
    8000444a:	40dc                	lw	a5,4(s1)
    8000444c:	cf89                	beqz	a5,80004466 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000444e:	02848493          	addi	s1,s1,40
    80004452:	fee49ce3          	bne	s1,a4,8000444a <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004456:	0002d517          	auipc	a0,0x2d
    8000445a:	18a50513          	addi	a0,a0,394 # 800315e0 <ftable>
    8000445e:	fa6fc0ef          	jal	ra,80000c04 <release>
  return 0;
    80004462:	4481                	li	s1,0
    80004464:	a809                	j	80004476 <filealloc+0x52>
      f->ref = 1;
    80004466:	4785                	li	a5,1
    80004468:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000446a:	0002d517          	auipc	a0,0x2d
    8000446e:	17650513          	addi	a0,a0,374 # 800315e0 <ftable>
    80004472:	f92fc0ef          	jal	ra,80000c04 <release>
}
    80004476:	8526                	mv	a0,s1
    80004478:	60e2                	ld	ra,24(sp)
    8000447a:	6442                	ld	s0,16(sp)
    8000447c:	64a2                	ld	s1,8(sp)
    8000447e:	6105                	addi	sp,sp,32
    80004480:	8082                	ret

0000000080004482 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004482:	1101                	addi	sp,sp,-32
    80004484:	ec06                	sd	ra,24(sp)
    80004486:	e822                	sd	s0,16(sp)
    80004488:	e426                	sd	s1,8(sp)
    8000448a:	1000                	addi	s0,sp,32
    8000448c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000448e:	0002d517          	auipc	a0,0x2d
    80004492:	15250513          	addi	a0,a0,338 # 800315e0 <ftable>
    80004496:	ed6fc0ef          	jal	ra,80000b6c <acquire>
  if(f->ref < 1)
    8000449a:	40dc                	lw	a5,4(s1)
    8000449c:	02f05063          	blez	a5,800044bc <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800044a0:	2785                	addiw	a5,a5,1
    800044a2:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800044a4:	0002d517          	auipc	a0,0x2d
    800044a8:	13c50513          	addi	a0,a0,316 # 800315e0 <ftable>
    800044ac:	f58fc0ef          	jal	ra,80000c04 <release>
  return f;
}
    800044b0:	8526                	mv	a0,s1
    800044b2:	60e2                	ld	ra,24(sp)
    800044b4:	6442                	ld	s0,16(sp)
    800044b6:	64a2                	ld	s1,8(sp)
    800044b8:	6105                	addi	sp,sp,32
    800044ba:	8082                	ret
    panic("filedup");
    800044bc:	00003517          	auipc	a0,0x3
    800044c0:	44c50513          	addi	a0,a0,1100 # 80007908 <syscalls+0x280>
    800044c4:	ac6fc0ef          	jal	ra,8000078a <panic>

00000000800044c8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800044c8:	7139                	addi	sp,sp,-64
    800044ca:	fc06                	sd	ra,56(sp)
    800044cc:	f822                	sd	s0,48(sp)
    800044ce:	f426                	sd	s1,40(sp)
    800044d0:	f04a                	sd	s2,32(sp)
    800044d2:	ec4e                	sd	s3,24(sp)
    800044d4:	e852                	sd	s4,16(sp)
    800044d6:	e456                	sd	s5,8(sp)
    800044d8:	0080                	addi	s0,sp,64
    800044da:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800044dc:	0002d517          	auipc	a0,0x2d
    800044e0:	10450513          	addi	a0,a0,260 # 800315e0 <ftable>
    800044e4:	e88fc0ef          	jal	ra,80000b6c <acquire>
  if(f->ref < 1)
    800044e8:	40dc                	lw	a5,4(s1)
    800044ea:	04f05963          	blez	a5,8000453c <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    800044ee:	37fd                	addiw	a5,a5,-1
    800044f0:	0007871b          	sext.w	a4,a5
    800044f4:	c0dc                	sw	a5,4(s1)
    800044f6:	04e04963          	bgtz	a4,80004548 <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800044fa:	0004a903          	lw	s2,0(s1)
    800044fe:	0094ca83          	lbu	s5,9(s1)
    80004502:	0104ba03          	ld	s4,16(s1)
    80004506:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000450a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000450e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004512:	0002d517          	auipc	a0,0x2d
    80004516:	0ce50513          	addi	a0,a0,206 # 800315e0 <ftable>
    8000451a:	eeafc0ef          	jal	ra,80000c04 <release>

  if(ff.type == FD_PIPE){
    8000451e:	4785                	li	a5,1
    80004520:	04f90363          	beq	s2,a5,80004566 <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004524:	3979                	addiw	s2,s2,-2
    80004526:	4785                	li	a5,1
    80004528:	0327e663          	bltu	a5,s2,80004554 <fileclose+0x8c>
    begin_op();
    8000452c:	b8fff0ef          	jal	ra,800040ba <begin_op>
    iput(ff.ip);
    80004530:	854e                	mv	a0,s3
    80004532:	b28ff0ef          	jal	ra,8000385a <iput>
    end_op();
    80004536:	bf5ff0ef          	jal	ra,8000412a <end_op>
    8000453a:	a829                	j	80004554 <fileclose+0x8c>
    panic("fileclose");
    8000453c:	00003517          	auipc	a0,0x3
    80004540:	3d450513          	addi	a0,a0,980 # 80007910 <syscalls+0x288>
    80004544:	a46fc0ef          	jal	ra,8000078a <panic>
    release(&ftable.lock);
    80004548:	0002d517          	auipc	a0,0x2d
    8000454c:	09850513          	addi	a0,a0,152 # 800315e0 <ftable>
    80004550:	eb4fc0ef          	jal	ra,80000c04 <release>
  }
}
    80004554:	70e2                	ld	ra,56(sp)
    80004556:	7442                	ld	s0,48(sp)
    80004558:	74a2                	ld	s1,40(sp)
    8000455a:	7902                	ld	s2,32(sp)
    8000455c:	69e2                	ld	s3,24(sp)
    8000455e:	6a42                	ld	s4,16(sp)
    80004560:	6aa2                	ld	s5,8(sp)
    80004562:	6121                	addi	sp,sp,64
    80004564:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004566:	85d6                	mv	a1,s5
    80004568:	8552                	mv	a0,s4
    8000456a:	2ec000ef          	jal	ra,80004856 <pipeclose>
    8000456e:	b7dd                	j	80004554 <fileclose+0x8c>

0000000080004570 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004570:	715d                	addi	sp,sp,-80
    80004572:	e486                	sd	ra,72(sp)
    80004574:	e0a2                	sd	s0,64(sp)
    80004576:	fc26                	sd	s1,56(sp)
    80004578:	f84a                	sd	s2,48(sp)
    8000457a:	f44e                	sd	s3,40(sp)
    8000457c:	0880                	addi	s0,sp,80
    8000457e:	84aa                	mv	s1,a0
    80004580:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004582:	859fd0ef          	jal	ra,80001dda <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004586:	409c                	lw	a5,0(s1)
    80004588:	37f9                	addiw	a5,a5,-2
    8000458a:	4705                	li	a4,1
    8000458c:	02f76f63          	bltu	a4,a5,800045ca <filestat+0x5a>
    80004590:	892a                	mv	s2,a0
    ilock(f->ip);
    80004592:	6c88                	ld	a0,24(s1)
    80004594:	948ff0ef          	jal	ra,800036dc <ilock>
    stati(f->ip, &st);
    80004598:	fb840593          	addi	a1,s0,-72
    8000459c:	6c88                	ld	a0,24(s1)
    8000459e:	ca0ff0ef          	jal	ra,80003a3e <stati>
    iunlock(f->ip);
    800045a2:	6c88                	ld	a0,24(s1)
    800045a4:	9e2ff0ef          	jal	ra,80003786 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800045a8:	46e1                	li	a3,24
    800045aa:	fb840613          	addi	a2,s0,-72
    800045ae:	85ce                	mv	a1,s3
    800045b0:	05093503          	ld	a0,80(s2)
    800045b4:	d74fd0ef          	jal	ra,80001b28 <copyout>
    800045b8:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800045bc:	60a6                	ld	ra,72(sp)
    800045be:	6406                	ld	s0,64(sp)
    800045c0:	74e2                	ld	s1,56(sp)
    800045c2:	7942                	ld	s2,48(sp)
    800045c4:	79a2                	ld	s3,40(sp)
    800045c6:	6161                	addi	sp,sp,80
    800045c8:	8082                	ret
  return -1;
    800045ca:	557d                	li	a0,-1
    800045cc:	bfc5                	j	800045bc <filestat+0x4c>

00000000800045ce <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800045ce:	7179                	addi	sp,sp,-48
    800045d0:	f406                	sd	ra,40(sp)
    800045d2:	f022                	sd	s0,32(sp)
    800045d4:	ec26                	sd	s1,24(sp)
    800045d6:	e84a                	sd	s2,16(sp)
    800045d8:	e44e                	sd	s3,8(sp)
    800045da:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800045dc:	00854783          	lbu	a5,8(a0)
    800045e0:	cbc1                	beqz	a5,80004670 <fileread+0xa2>
    800045e2:	84aa                	mv	s1,a0
    800045e4:	89ae                	mv	s3,a1
    800045e6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800045e8:	411c                	lw	a5,0(a0)
    800045ea:	4705                	li	a4,1
    800045ec:	04e78363          	beq	a5,a4,80004632 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800045f0:	470d                	li	a4,3
    800045f2:	04e78563          	beq	a5,a4,8000463c <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800045f6:	4709                	li	a4,2
    800045f8:	06e79663          	bne	a5,a4,80004664 <fileread+0x96>
    ilock(f->ip);
    800045fc:	6d08                	ld	a0,24(a0)
    800045fe:	8deff0ef          	jal	ra,800036dc <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004602:	874a                	mv	a4,s2
    80004604:	5094                	lw	a3,32(s1)
    80004606:	864e                	mv	a2,s3
    80004608:	4585                	li	a1,1
    8000460a:	6c88                	ld	a0,24(s1)
    8000460c:	c5cff0ef          	jal	ra,80003a68 <readi>
    80004610:	892a                	mv	s2,a0
    80004612:	00a05563          	blez	a0,8000461c <fileread+0x4e>
      f->off += r;
    80004616:	509c                	lw	a5,32(s1)
    80004618:	9fa9                	addw	a5,a5,a0
    8000461a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000461c:	6c88                	ld	a0,24(s1)
    8000461e:	968ff0ef          	jal	ra,80003786 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004622:	854a                	mv	a0,s2
    80004624:	70a2                	ld	ra,40(sp)
    80004626:	7402                	ld	s0,32(sp)
    80004628:	64e2                	ld	s1,24(sp)
    8000462a:	6942                	ld	s2,16(sp)
    8000462c:	69a2                	ld	s3,8(sp)
    8000462e:	6145                	addi	sp,sp,48
    80004630:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004632:	6908                	ld	a0,16(a0)
    80004634:	34e000ef          	jal	ra,80004982 <piperead>
    80004638:	892a                	mv	s2,a0
    8000463a:	b7e5                	j	80004622 <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000463c:	02451783          	lh	a5,36(a0)
    80004640:	03079693          	slli	a3,a5,0x30
    80004644:	92c1                	srli	a3,a3,0x30
    80004646:	4725                	li	a4,9
    80004648:	02d76663          	bltu	a4,a3,80004674 <fileread+0xa6>
    8000464c:	0792                	slli	a5,a5,0x4
    8000464e:	0002d717          	auipc	a4,0x2d
    80004652:	ef270713          	addi	a4,a4,-270 # 80031540 <devsw>
    80004656:	97ba                	add	a5,a5,a4
    80004658:	639c                	ld	a5,0(a5)
    8000465a:	cf99                	beqz	a5,80004678 <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    8000465c:	4505                	li	a0,1
    8000465e:	9782                	jalr	a5
    80004660:	892a                	mv	s2,a0
    80004662:	b7c1                	j	80004622 <fileread+0x54>
    panic("fileread");
    80004664:	00003517          	auipc	a0,0x3
    80004668:	2bc50513          	addi	a0,a0,700 # 80007920 <syscalls+0x298>
    8000466c:	91efc0ef          	jal	ra,8000078a <panic>
    return -1;
    80004670:	597d                	li	s2,-1
    80004672:	bf45                	j	80004622 <fileread+0x54>
      return -1;
    80004674:	597d                	li	s2,-1
    80004676:	b775                	j	80004622 <fileread+0x54>
    80004678:	597d                	li	s2,-1
    8000467a:	b765                	j	80004622 <fileread+0x54>

000000008000467c <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000467c:	715d                	addi	sp,sp,-80
    8000467e:	e486                	sd	ra,72(sp)
    80004680:	e0a2                	sd	s0,64(sp)
    80004682:	fc26                	sd	s1,56(sp)
    80004684:	f84a                	sd	s2,48(sp)
    80004686:	f44e                	sd	s3,40(sp)
    80004688:	f052                	sd	s4,32(sp)
    8000468a:	ec56                	sd	s5,24(sp)
    8000468c:	e85a                	sd	s6,16(sp)
    8000468e:	e45e                	sd	s7,8(sp)
    80004690:	e062                	sd	s8,0(sp)
    80004692:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004694:	00954783          	lbu	a5,9(a0)
    80004698:	0e078863          	beqz	a5,80004788 <filewrite+0x10c>
    8000469c:	892a                	mv	s2,a0
    8000469e:	8aae                	mv	s5,a1
    800046a0:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800046a2:	411c                	lw	a5,0(a0)
    800046a4:	4705                	li	a4,1
    800046a6:	02e78263          	beq	a5,a4,800046ca <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046aa:	470d                	li	a4,3
    800046ac:	02e78463          	beq	a5,a4,800046d4 <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800046b0:	4709                	li	a4,2
    800046b2:	0ce79563          	bne	a5,a4,8000477c <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800046b6:	0ac05163          	blez	a2,80004758 <filewrite+0xdc>
    int i = 0;
    800046ba:	4981                	li	s3,0
    800046bc:	6b05                	lui	s6,0x1
    800046be:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800046c2:	6b85                	lui	s7,0x1
    800046c4:	c00b8b9b          	addiw	s7,s7,-1024
    800046c8:	a041                	j	80004748 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800046ca:	6908                	ld	a0,16(a0)
    800046cc:	1e2000ef          	jal	ra,800048ae <pipewrite>
    800046d0:	8a2a                	mv	s4,a0
    800046d2:	a071                	j	8000475e <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800046d4:	02451783          	lh	a5,36(a0)
    800046d8:	03079693          	slli	a3,a5,0x30
    800046dc:	92c1                	srli	a3,a3,0x30
    800046de:	4725                	li	a4,9
    800046e0:	0ad76663          	bltu	a4,a3,8000478c <filewrite+0x110>
    800046e4:	0792                	slli	a5,a5,0x4
    800046e6:	0002d717          	auipc	a4,0x2d
    800046ea:	e5a70713          	addi	a4,a4,-422 # 80031540 <devsw>
    800046ee:	97ba                	add	a5,a5,a4
    800046f0:	679c                	ld	a5,8(a5)
    800046f2:	cfd9                	beqz	a5,80004790 <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    800046f4:	4505                	li	a0,1
    800046f6:	9782                	jalr	a5
    800046f8:	8a2a                	mv	s4,a0
    800046fa:	a095                	j	8000475e <filewrite+0xe2>
    800046fc:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004700:	9bbff0ef          	jal	ra,800040ba <begin_op>
      ilock(f->ip);
    80004704:	01893503          	ld	a0,24(s2)
    80004708:	fd5fe0ef          	jal	ra,800036dc <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000470c:	8762                	mv	a4,s8
    8000470e:	02092683          	lw	a3,32(s2)
    80004712:	01598633          	add	a2,s3,s5
    80004716:	4585                	li	a1,1
    80004718:	01893503          	ld	a0,24(s2)
    8000471c:	c30ff0ef          	jal	ra,80003b4c <writei>
    80004720:	84aa                	mv	s1,a0
    80004722:	00a05763          	blez	a0,80004730 <filewrite+0xb4>
        f->off += r;
    80004726:	02092783          	lw	a5,32(s2)
    8000472a:	9fa9                	addw	a5,a5,a0
    8000472c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004730:	01893503          	ld	a0,24(s2)
    80004734:	852ff0ef          	jal	ra,80003786 <iunlock>
      end_op();
    80004738:	9f3ff0ef          	jal	ra,8000412a <end_op>

      if(r != n1){
    8000473c:	009c1f63          	bne	s8,s1,8000475a <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    80004740:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004744:	0149db63          	bge	s3,s4,8000475a <filewrite+0xde>
      int n1 = n - i;
    80004748:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    8000474c:	84be                	mv	s1,a5
    8000474e:	2781                	sext.w	a5,a5
    80004750:	fafb56e3          	bge	s6,a5,800046fc <filewrite+0x80>
    80004754:	84de                	mv	s1,s7
    80004756:	b75d                	j	800046fc <filewrite+0x80>
    int i = 0;
    80004758:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000475a:	013a1f63          	bne	s4,s3,80004778 <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000475e:	8552                	mv	a0,s4
    80004760:	60a6                	ld	ra,72(sp)
    80004762:	6406                	ld	s0,64(sp)
    80004764:	74e2                	ld	s1,56(sp)
    80004766:	7942                	ld	s2,48(sp)
    80004768:	79a2                	ld	s3,40(sp)
    8000476a:	7a02                	ld	s4,32(sp)
    8000476c:	6ae2                	ld	s5,24(sp)
    8000476e:	6b42                	ld	s6,16(sp)
    80004770:	6ba2                	ld	s7,8(sp)
    80004772:	6c02                	ld	s8,0(sp)
    80004774:	6161                	addi	sp,sp,80
    80004776:	8082                	ret
    ret = (i == n ? n : -1);
    80004778:	5a7d                	li	s4,-1
    8000477a:	b7d5                	j	8000475e <filewrite+0xe2>
    panic("filewrite");
    8000477c:	00003517          	auipc	a0,0x3
    80004780:	1b450513          	addi	a0,a0,436 # 80007930 <syscalls+0x2a8>
    80004784:	806fc0ef          	jal	ra,8000078a <panic>
    return -1;
    80004788:	5a7d                	li	s4,-1
    8000478a:	bfd1                	j	8000475e <filewrite+0xe2>
      return -1;
    8000478c:	5a7d                	li	s4,-1
    8000478e:	bfc1                	j	8000475e <filewrite+0xe2>
    80004790:	5a7d                	li	s4,-1
    80004792:	b7f1                	j	8000475e <filewrite+0xe2>

0000000080004794 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004794:	7179                	addi	sp,sp,-48
    80004796:	f406                	sd	ra,40(sp)
    80004798:	f022                	sd	s0,32(sp)
    8000479a:	ec26                	sd	s1,24(sp)
    8000479c:	e84a                	sd	s2,16(sp)
    8000479e:	e44e                	sd	s3,8(sp)
    800047a0:	e052                	sd	s4,0(sp)
    800047a2:	1800                	addi	s0,sp,48
    800047a4:	84aa                	mv	s1,a0
    800047a6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800047a8:	0005b023          	sd	zero,0(a1)
    800047ac:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800047b0:	c75ff0ef          	jal	ra,80004424 <filealloc>
    800047b4:	e088                	sd	a0,0(s1)
    800047b6:	cd35                	beqz	a0,80004832 <pipealloc+0x9e>
    800047b8:	c6dff0ef          	jal	ra,80004424 <filealloc>
    800047bc:	00aa3023          	sd	a0,0(s4)
    800047c0:	c52d                	beqz	a0,8000482a <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800047c2:	adafc0ef          	jal	ra,80000a9c <kalloc>
    800047c6:	892a                	mv	s2,a0
    800047c8:	cd31                	beqz	a0,80004824 <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    800047ca:	4985                	li	s3,1
    800047cc:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800047d0:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800047d4:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800047d8:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800047dc:	00003597          	auipc	a1,0x3
    800047e0:	16458593          	addi	a1,a1,356 # 80007940 <syscalls+0x2b8>
    800047e4:	b08fc0ef          	jal	ra,80000aec <initlock>
  (*f0)->type = FD_PIPE;
    800047e8:	609c                	ld	a5,0(s1)
    800047ea:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800047ee:	609c                	ld	a5,0(s1)
    800047f0:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800047f4:	609c                	ld	a5,0(s1)
    800047f6:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800047fa:	609c                	ld	a5,0(s1)
    800047fc:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004800:	000a3783          	ld	a5,0(s4)
    80004804:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004808:	000a3783          	ld	a5,0(s4)
    8000480c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004810:	000a3783          	ld	a5,0(s4)
    80004814:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004818:	000a3783          	ld	a5,0(s4)
    8000481c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004820:	4501                	li	a0,0
    80004822:	a005                	j	80004842 <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004824:	6088                	ld	a0,0(s1)
    80004826:	e501                	bnez	a0,8000482e <pipealloc+0x9a>
    80004828:	a029                	j	80004832 <pipealloc+0x9e>
    8000482a:	6088                	ld	a0,0(s1)
    8000482c:	c11d                	beqz	a0,80004852 <pipealloc+0xbe>
    fileclose(*f0);
    8000482e:	c9bff0ef          	jal	ra,800044c8 <fileclose>
  if(*f1)
    80004832:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004836:	557d                	li	a0,-1
  if(*f1)
    80004838:	c789                	beqz	a5,80004842 <pipealloc+0xae>
    fileclose(*f1);
    8000483a:	853e                	mv	a0,a5
    8000483c:	c8dff0ef          	jal	ra,800044c8 <fileclose>
  return -1;
    80004840:	557d                	li	a0,-1
}
    80004842:	70a2                	ld	ra,40(sp)
    80004844:	7402                	ld	s0,32(sp)
    80004846:	64e2                	ld	s1,24(sp)
    80004848:	6942                	ld	s2,16(sp)
    8000484a:	69a2                	ld	s3,8(sp)
    8000484c:	6a02                	ld	s4,0(sp)
    8000484e:	6145                	addi	sp,sp,48
    80004850:	8082                	ret
  return -1;
    80004852:	557d                	li	a0,-1
    80004854:	b7fd                	j	80004842 <pipealloc+0xae>

0000000080004856 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004856:	1101                	addi	sp,sp,-32
    80004858:	ec06                	sd	ra,24(sp)
    8000485a:	e822                	sd	s0,16(sp)
    8000485c:	e426                	sd	s1,8(sp)
    8000485e:	e04a                	sd	s2,0(sp)
    80004860:	1000                	addi	s0,sp,32
    80004862:	84aa                	mv	s1,a0
    80004864:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004866:	b06fc0ef          	jal	ra,80000b6c <acquire>
  if(writable){
    8000486a:	02090763          	beqz	s2,80004898 <pipeclose+0x42>
    pi->writeopen = 0;
    8000486e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004872:	21848513          	addi	a0,s1,536
    80004876:	bd3fd0ef          	jal	ra,80002448 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000487a:	2204b783          	ld	a5,544(s1)
    8000487e:	e785                	bnez	a5,800048a6 <pipeclose+0x50>
    release(&pi->lock);
    80004880:	8526                	mv	a0,s1
    80004882:	b82fc0ef          	jal	ra,80000c04 <release>
    kfree((char*)pi);
    80004886:	8526                	mv	a0,s1
    80004888:	934fc0ef          	jal	ra,800009bc <kfree>
  } else
    release(&pi->lock);
}
    8000488c:	60e2                	ld	ra,24(sp)
    8000488e:	6442                	ld	s0,16(sp)
    80004890:	64a2                	ld	s1,8(sp)
    80004892:	6902                	ld	s2,0(sp)
    80004894:	6105                	addi	sp,sp,32
    80004896:	8082                	ret
    pi->readopen = 0;
    80004898:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000489c:	21c48513          	addi	a0,s1,540
    800048a0:	ba9fd0ef          	jal	ra,80002448 <wakeup>
    800048a4:	bfd9                	j	8000487a <pipeclose+0x24>
    release(&pi->lock);
    800048a6:	8526                	mv	a0,s1
    800048a8:	b5cfc0ef          	jal	ra,80000c04 <release>
}
    800048ac:	b7c5                	j	8000488c <pipeclose+0x36>

00000000800048ae <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800048ae:	711d                	addi	sp,sp,-96
    800048b0:	ec86                	sd	ra,88(sp)
    800048b2:	e8a2                	sd	s0,80(sp)
    800048b4:	e4a6                	sd	s1,72(sp)
    800048b6:	e0ca                	sd	s2,64(sp)
    800048b8:	fc4e                	sd	s3,56(sp)
    800048ba:	f852                	sd	s4,48(sp)
    800048bc:	f456                	sd	s5,40(sp)
    800048be:	f05a                	sd	s6,32(sp)
    800048c0:	ec5e                	sd	s7,24(sp)
    800048c2:	e862                	sd	s8,16(sp)
    800048c4:	1080                	addi	s0,sp,96
    800048c6:	84aa                	mv	s1,a0
    800048c8:	8aae                	mv	s5,a1
    800048ca:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800048cc:	d0efd0ef          	jal	ra,80001dda <myproc>
    800048d0:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800048d2:	8526                	mv	a0,s1
    800048d4:	a98fc0ef          	jal	ra,80000b6c <acquire>
  while(i < n){
    800048d8:	09405c63          	blez	s4,80004970 <pipewrite+0xc2>
  int i = 0;
    800048dc:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800048de:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800048e0:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800048e4:	21c48b93          	addi	s7,s1,540
    800048e8:	a81d                	j	8000491e <pipewrite+0x70>
      release(&pi->lock);
    800048ea:	8526                	mv	a0,s1
    800048ec:	b18fc0ef          	jal	ra,80000c04 <release>
      return -1;
    800048f0:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800048f2:	854a                	mv	a0,s2
    800048f4:	60e6                	ld	ra,88(sp)
    800048f6:	6446                	ld	s0,80(sp)
    800048f8:	64a6                	ld	s1,72(sp)
    800048fa:	6906                	ld	s2,64(sp)
    800048fc:	79e2                	ld	s3,56(sp)
    800048fe:	7a42                	ld	s4,48(sp)
    80004900:	7aa2                	ld	s5,40(sp)
    80004902:	7b02                	ld	s6,32(sp)
    80004904:	6be2                	ld	s7,24(sp)
    80004906:	6c42                	ld	s8,16(sp)
    80004908:	6125                	addi	sp,sp,96
    8000490a:	8082                	ret
      wakeup(&pi->nread);
    8000490c:	8562                	mv	a0,s8
    8000490e:	b3bfd0ef          	jal	ra,80002448 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004912:	85a6                	mv	a1,s1
    80004914:	855e                	mv	a0,s7
    80004916:	ae7fd0ef          	jal	ra,800023fc <sleep>
  while(i < n){
    8000491a:	05495c63          	bge	s2,s4,80004972 <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    8000491e:	2204a783          	lw	a5,544(s1)
    80004922:	d7e1                	beqz	a5,800048ea <pipewrite+0x3c>
    80004924:	854e                	mv	a0,s3
    80004926:	d0ffd0ef          	jal	ra,80002634 <killed>
    8000492a:	f161                	bnez	a0,800048ea <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000492c:	2184a783          	lw	a5,536(s1)
    80004930:	21c4a703          	lw	a4,540(s1)
    80004934:	2007879b          	addiw	a5,a5,512
    80004938:	fcf70ae3          	beq	a4,a5,8000490c <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000493c:	4685                	li	a3,1
    8000493e:	01590633          	add	a2,s2,s5
    80004942:	faf40593          	addi	a1,s0,-81
    80004946:	0509b503          	ld	a0,80(s3)
    8000494a:	aa4fd0ef          	jal	ra,80001bee <copyin>
    8000494e:	03650263          	beq	a0,s6,80004972 <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004952:	21c4a783          	lw	a5,540(s1)
    80004956:	0017871b          	addiw	a4,a5,1
    8000495a:	20e4ae23          	sw	a4,540(s1)
    8000495e:	1ff7f793          	andi	a5,a5,511
    80004962:	97a6                	add	a5,a5,s1
    80004964:	faf44703          	lbu	a4,-81(s0)
    80004968:	00e78c23          	sb	a4,24(a5)
      i++;
    8000496c:	2905                	addiw	s2,s2,1
    8000496e:	b775                	j	8000491a <pipewrite+0x6c>
  int i = 0;
    80004970:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004972:	21848513          	addi	a0,s1,536
    80004976:	ad3fd0ef          	jal	ra,80002448 <wakeup>
  release(&pi->lock);
    8000497a:	8526                	mv	a0,s1
    8000497c:	a88fc0ef          	jal	ra,80000c04 <release>
  return i;
    80004980:	bf8d                	j	800048f2 <pipewrite+0x44>

0000000080004982 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004982:	715d                	addi	sp,sp,-80
    80004984:	e486                	sd	ra,72(sp)
    80004986:	e0a2                	sd	s0,64(sp)
    80004988:	fc26                	sd	s1,56(sp)
    8000498a:	f84a                	sd	s2,48(sp)
    8000498c:	f44e                	sd	s3,40(sp)
    8000498e:	f052                	sd	s4,32(sp)
    80004990:	ec56                	sd	s5,24(sp)
    80004992:	e85a                	sd	s6,16(sp)
    80004994:	0880                	addi	s0,sp,80
    80004996:	84aa                	mv	s1,a0
    80004998:	892e                	mv	s2,a1
    8000499a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000499c:	c3efd0ef          	jal	ra,80001dda <myproc>
    800049a0:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800049a2:	8526                	mv	a0,s1
    800049a4:	9c8fc0ef          	jal	ra,80000b6c <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800049a8:	2184a703          	lw	a4,536(s1)
    800049ac:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800049b0:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800049b4:	02f71363          	bne	a4,a5,800049da <piperead+0x58>
    800049b8:	2244a783          	lw	a5,548(s1)
    800049bc:	cf99                	beqz	a5,800049da <piperead+0x58>
    if(killed(pr)){
    800049be:	8552                	mv	a0,s4
    800049c0:	c75fd0ef          	jal	ra,80002634 <killed>
    800049c4:	e141                	bnez	a0,80004a44 <piperead+0xc2>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800049c6:	85a6                	mv	a1,s1
    800049c8:	854e                	mv	a0,s3
    800049ca:	a33fd0ef          	jal	ra,800023fc <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800049ce:	2184a703          	lw	a4,536(s1)
    800049d2:	21c4a783          	lw	a5,540(s1)
    800049d6:	fef701e3          	beq	a4,a5,800049b8 <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800049da:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800049dc:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800049de:	05505163          	blez	s5,80004a20 <piperead+0x9e>
    if(pi->nread == pi->nwrite)
    800049e2:	2184a783          	lw	a5,536(s1)
    800049e6:	21c4a703          	lw	a4,540(s1)
    800049ea:	02f70b63          	beq	a4,a5,80004a20 <piperead+0x9e>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800049ee:	0017871b          	addiw	a4,a5,1
    800049f2:	20e4ac23          	sw	a4,536(s1)
    800049f6:	1ff7f793          	andi	a5,a5,511
    800049fa:	97a6                	add	a5,a5,s1
    800049fc:	0187c783          	lbu	a5,24(a5)
    80004a00:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004a04:	4685                	li	a3,1
    80004a06:	fbf40613          	addi	a2,s0,-65
    80004a0a:	85ca                	mv	a1,s2
    80004a0c:	050a3503          	ld	a0,80(s4)
    80004a10:	918fd0ef          	jal	ra,80001b28 <copyout>
    80004a14:	01650663          	beq	a0,s6,80004a20 <piperead+0x9e>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004a18:	2985                	addiw	s3,s3,1
    80004a1a:	0905                	addi	s2,s2,1
    80004a1c:	fd3a93e3          	bne	s5,s3,800049e2 <piperead+0x60>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004a20:	21c48513          	addi	a0,s1,540
    80004a24:	a25fd0ef          	jal	ra,80002448 <wakeup>
  release(&pi->lock);
    80004a28:	8526                	mv	a0,s1
    80004a2a:	9dafc0ef          	jal	ra,80000c04 <release>
  return i;
}
    80004a2e:	854e                	mv	a0,s3
    80004a30:	60a6                	ld	ra,72(sp)
    80004a32:	6406                	ld	s0,64(sp)
    80004a34:	74e2                	ld	s1,56(sp)
    80004a36:	7942                	ld	s2,48(sp)
    80004a38:	79a2                	ld	s3,40(sp)
    80004a3a:	7a02                	ld	s4,32(sp)
    80004a3c:	6ae2                	ld	s5,24(sp)
    80004a3e:	6b42                	ld	s6,16(sp)
    80004a40:	6161                	addi	sp,sp,80
    80004a42:	8082                	ret
      release(&pi->lock);
    80004a44:	8526                	mv	a0,s1
    80004a46:	9befc0ef          	jal	ra,80000c04 <release>
      return -1;
    80004a4a:	59fd                	li	s3,-1
    80004a4c:	b7cd                	j	80004a2e <piperead+0xac>

0000000080004a4e <flags2perm>:

// static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004a4e:	1141                	addi	sp,sp,-16
    80004a50:	e422                	sd	s0,8(sp)
    80004a52:	0800                	addi	s0,sp,16
    80004a54:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004a56:	8905                	andi	a0,a0,1
    80004a58:	c111                	beqz	a0,80004a5c <flags2perm+0xe>
      perm = PTE_X;
    80004a5a:	4521                	li	a0,8
    if(flags & 0x2)
    80004a5c:	8b89                	andi	a5,a5,2
    80004a5e:	c399                	beqz	a5,80004a64 <flags2perm+0x16>
      perm |= PTE_W;
    80004a60:	00456513          	ori	a0,a0,4
    return perm;
}
    80004a64:	6422                	ld	s0,8(sp)
    80004a66:	0141                	addi	sp,sp,16
    80004a68:	8082                	ret

0000000080004a6a <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004a6a:	7101                	addi	sp,sp,-512
    80004a6c:	ff86                	sd	ra,504(sp)
    80004a6e:	fba2                	sd	s0,496(sp)
    80004a70:	f7a6                	sd	s1,488(sp)
    80004a72:	f3ca                	sd	s2,480(sp)
    80004a74:	efce                	sd	s3,472(sp)
    80004a76:	ebd2                	sd	s4,464(sp)
    80004a78:	e7d6                	sd	s5,456(sp)
    80004a7a:	e3da                	sd	s6,448(sp)
    80004a7c:	ff5e                	sd	s7,440(sp)
    80004a7e:	fb62                	sd	s8,432(sp)
    80004a80:	f766                	sd	s9,424(sp)
    80004a82:	f36a                	sd	s10,416(sp)
    80004a84:	ef6e                	sd	s11,408(sp)
    80004a86:	0400                	addi	s0,sp,512
    80004a88:	892a                	mv	s2,a0
    80004a8a:	84ae                	mv	s1,a1
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004a8c:	b4efd0ef          	jal	ra,80001dda <myproc>
    80004a90:	8baa                	mv	s7,a0

  begin_op();
    80004a92:	e28ff0ef          	jal	ra,800040ba <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004a96:	854a                	mv	a0,s2
    80004a98:	c32ff0ef          	jal	ra,80003eca <namei>
    80004a9c:	cd39                	beqz	a0,80004afa <kexec+0x90>
    80004a9e:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004aa0:	c3dfe0ef          	jal	ra,800036dc <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004aa4:	04000713          	li	a4,64
    80004aa8:	4681                	li	a3,0
    80004aaa:	e5040613          	addi	a2,s0,-432
    80004aae:	4581                	li	a1,0
    80004ab0:	8552                	mv	a0,s4
    80004ab2:	fb7fe0ef          	jal	ra,80003a68 <readi>
    80004ab6:	04000793          	li	a5,64
    80004aba:	00f51a63          	bne	a0,a5,80004ace <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004abe:	e5042703          	lw	a4,-432(s0)
    80004ac2:	464c47b7          	lui	a5,0x464c4
    80004ac6:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004aca:	02f70c63          	beq	a4,a5,80004b02 <kexec+0x98>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004ace:	8552                	mv	a0,s4
    80004ad0:	e13fe0ef          	jal	ra,800038e2 <iunlockput>
    end_op();
    80004ad4:	e56ff0ef          	jal	ra,8000412a <end_op>
  }
  return -1;
    80004ad8:	557d                	li	a0,-1
}
    80004ada:	70fe                	ld	ra,504(sp)
    80004adc:	745e                	ld	s0,496(sp)
    80004ade:	74be                	ld	s1,488(sp)
    80004ae0:	791e                	ld	s2,480(sp)
    80004ae2:	69fe                	ld	s3,472(sp)
    80004ae4:	6a5e                	ld	s4,464(sp)
    80004ae6:	6abe                	ld	s5,456(sp)
    80004ae8:	6b1e                	ld	s6,448(sp)
    80004aea:	7bfa                	ld	s7,440(sp)
    80004aec:	7c5a                	ld	s8,432(sp)
    80004aee:	7cba                	ld	s9,424(sp)
    80004af0:	7d1a                	ld	s10,416(sp)
    80004af2:	6dfa                	ld	s11,408(sp)
    80004af4:	20010113          	addi	sp,sp,512
    80004af8:	8082                	ret
    end_op();
    80004afa:	e30ff0ef          	jal	ra,8000412a <end_op>
    return -1;
    80004afe:	557d                	li	a0,-1
    80004b00:	bfe9                	j	80004ada <kexec+0x70>
  if((pagetable = proc_pagetable(p)) == 0)
    80004b02:	855e                	mv	a0,s7
    80004b04:	bdcfd0ef          	jal	ra,80001ee0 <proc_pagetable>
    80004b08:	8b2a                	mv	s6,a0
    80004b0a:	d171                	beqz	a0,80004ace <kexec+0x64>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004b0c:	e7042983          	lw	s3,-400(s0)
    80004b10:	e8845783          	lhu	a5,-376(s0)
    80004b14:	cbc1                	beqz	a5,80004ba4 <kexec+0x13a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004b16:	4a81                	li	s5,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004b18:	4c01                	li	s8,0
    if(ph.type != ELF_PROG_LOAD)
    80004b1a:	4c85                	li	s9,1
    if(ph.vaddr % PGSIZE != 0)
    80004b1c:	6d05                	lui	s10,0x1
    80004b1e:	1d7d                	addi	s10,s10,-1
    80004b20:	a01d                	j	80004b46 <kexec+0xdc>
  p->data_start = ph.vaddr;
    80004b22:	16ebbc23          	sd	a4,376(s7) # 1178 <_entry-0x7fffee88>
  p->data_end = ph.vaddr + ph.memsz;
    80004b26:	18fbb023          	sd	a5,384(s7)
  p->data_file_offset = ph.off;
    80004b2a:	e2043703          	ld	a4,-480(s0)
    80004b2e:	1aebb823          	sd	a4,432(s7)
  p->data_file_size = ph.filesz;
    80004b32:	1adbbc23          	sd	a3,440(s7)
    sz = ph.vaddr + ph.memsz;  // Update size but don't allocate
    80004b36:	8abe                	mv	s5,a5
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004b38:	2c05                	addiw	s8,s8,1
    80004b3a:	0389899b          	addiw	s3,s3,56
    80004b3e:	e8845783          	lhu	a5,-376(s0)
    80004b42:	06fc5263          	bge	s8,a5,80004ba6 <kexec+0x13c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004b46:	2981                	sext.w	s3,s3
    80004b48:	03800713          	li	a4,56
    80004b4c:	86ce                	mv	a3,s3
    80004b4e:	e1840613          	addi	a2,s0,-488
    80004b52:	4581                	li	a1,0
    80004b54:	8552                	mv	a0,s4
    80004b56:	f13fe0ef          	jal	ra,80003a68 <readi>
    80004b5a:	03800793          	li	a5,56
    80004b5e:	12f51663          	bne	a0,a5,80004c8a <kexec+0x220>
    if(ph.type != ELF_PROG_LOAD)
    80004b62:	e1842783          	lw	a5,-488(s0)
    80004b66:	fd9799e3          	bne	a5,s9,80004b38 <kexec+0xce>
    if(ph.memsz < ph.filesz)
    80004b6a:	e4043783          	ld	a5,-448(s0)
    80004b6e:	e3843683          	ld	a3,-456(s0)
    80004b72:	10d7ec63          	bltu	a5,a3,80004c8a <kexec+0x220>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004b76:	e2843703          	ld	a4,-472(s0)
    80004b7a:	97ba                	add	a5,a5,a4
    80004b7c:	10e7e763          	bltu	a5,a4,80004c8a <kexec+0x220>
    if(ph.vaddr % PGSIZE != 0)
    80004b80:	01a77633          	and	a2,a4,s10
    80004b84:	10061363          	bnez	a2,80004c8a <kexec+0x220>
if(i == 0) {  // First segment (typically text)
    80004b88:	f80c1de3          	bnez	s8,80004b22 <kexec+0xb8>
  p->text_start = ph.vaddr;
    80004b8c:	16ebb423          	sd	a4,360(s7)
  p->text_end = ph.vaddr + ph.memsz;
    80004b90:	16fbb823          	sd	a5,368(s7)
  p->text_file_offset = ph.off;
    80004b94:	e2043703          	ld	a4,-480(s0)
    80004b98:	1aebb023          	sd	a4,416(s7)
  p->text_file_size = ph.filesz;
    80004b9c:	1adbb423          	sd	a3,424(s7)
    sz = ph.vaddr + ph.memsz;  // Update size but don't allocate
    80004ba0:	8abe                	mv	s5,a5
    80004ba2:	bf59                	j	80004b38 <kexec+0xce>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ba4:	4a81                	li	s5,0
  printf("[pid %d] INIT-LAZYMAP text=[0x%lx,0x%lx) data=[0x%lx,0x%lx) heap_start=0x%lx stack_top=0x%lx\n", 
    80004ba6:	180bb783          	ld	a5,384(s7)
    80004baa:	6989                	lui	s3,0x2
    80004bac:	013a88b3          	add	a7,s5,s3
    80004bb0:	883e                	mv	a6,a5
    80004bb2:	178bb703          	ld	a4,376(s7)
    80004bb6:	170bb683          	ld	a3,368(s7)
    80004bba:	168bb603          	ld	a2,360(s7)
    80004bbe:	030ba583          	lw	a1,48(s7)
    80004bc2:	00003517          	auipc	a0,0x3
    80004bc6:	d8650513          	addi	a0,a0,-634 # 80007948 <syscalls+0x2c0>
    80004bca:	8fbfb0ef          	jal	ra,800004c4 <printf>
  p->heap_start = p->data_end;
    80004bce:	180bb783          	ld	a5,384(s7)
    80004bd2:	18fbb423          	sd	a5,392(s7)
  p->exec_inode = ip;
    80004bd6:	194bbc23          	sd	s4,408(s7)
  idup(ip);  // Increment reference count
    80004bda:	8552                	mv	a0,s4
    80004bdc:	acbfe0ef          	jal	ra,800036a6 <idup>
  iunlockput(ip);
    80004be0:	8552                	mv	a0,s4
    80004be2:	d01fe0ef          	jal	ra,800038e2 <iunlockput>
  end_op();
    80004be6:	d44ff0ef          	jal	ra,8000412a <end_op>
  p = myproc();
    80004bea:	9f0fd0ef          	jal	ra,80001dda <myproc>
    80004bee:	e0a43423          	sd	a0,-504(s0)
  uint64 oldsz = p->sz;
    80004bf2:	653c                	ld	a5,72(a0)
    80004bf4:	e0f43023          	sd	a5,-512(s0)
  sz = PGROUNDUP(sz);
    80004bf8:	6785                	lui	a5,0x1
    80004bfa:	fff78c93          	addi	s9,a5,-1 # fff <_entry-0x7ffff001>
    80004bfe:	9cd6                	add	s9,s9,s5
    80004c00:	777d                	lui	a4,0xfffff
    80004c02:	00ecfcb3          	and	s9,s9,a4
  sz1 = sz + (USERSTACK+1)*PGSIZE;
    80004c06:	013c8ab3          	add	s5,s9,s3
  stackbase = sp - USERSTACK*PGSIZE;
    80004c0a:	9cbe                	add	s9,s9,a5
   p->sz = sz;
    80004c0c:	05553423          	sd	s5,72(a0)
  for(argc = 0; argv[argc]; argc++) {
    80004c10:	6088                	ld	a0,0(s1)
    80004c12:	cd41                	beqz	a0,80004caa <kexec+0x240>
    80004c14:	e9040b93          	addi	s7,s0,-368
  sp = sz;
    80004c18:	8a56                	mv	s4,s5
  for(argc = 0; argv[argc]; argc++) {
    80004c1a:	4981                	li	s3,0
    printf("[DEBUG] About to copyout to sp=0x%lx, len=%d\n", sp, strlen(argv[argc]) + 1);
    80004c1c:	00003d17          	auipc	s10,0x3
    80004c20:	d8cd0d13          	addi	s10,s10,-628 # 800079a8 <syscalls+0x320>
    printf("[DEBUG] copyout SUCCESS\n");
    80004c24:	00003d97          	auipc	s11,0x3
    80004c28:	dccd8d93          	addi	s11,s11,-564 # 800079f0 <syscalls+0x368>
    sp -= strlen(argv[argc]) + 1;
    80004c2c:	98cfc0ef          	jal	ra,80000db8 <strlen>
    80004c30:	2505                	addiw	a0,a0,1
    80004c32:	40aa0a33          	sub	s4,s4,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004c36:	ff0a7a13          	andi	s4,s4,-16
    if(sp < stackbase)
    80004c3a:	119a6b63          	bltu	s4,s9,80004d50 <kexec+0x2e6>
    printf("[DEBUG] About to copyout to sp=0x%lx, len=%d\n", sp, strlen(argv[argc]) + 1);
    80004c3e:	6088                	ld	a0,0(s1)
    80004c40:	978fc0ef          	jal	ra,80000db8 <strlen>
    80004c44:	0015061b          	addiw	a2,a0,1
    80004c48:	85d2                	mv	a1,s4
    80004c4a:	856a                	mv	a0,s10
    80004c4c:	879fb0ef          	jal	ra,800004c4 <printf>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0) {
    80004c50:	0004bc03          	ld	s8,0(s1)
    80004c54:	8562                	mv	a0,s8
    80004c56:	962fc0ef          	jal	ra,80000db8 <strlen>
    80004c5a:	0015069b          	addiw	a3,a0,1
    80004c5e:	8662                	mv	a2,s8
    80004c60:	85d2                	mv	a1,s4
    80004c62:	855a                	mv	a0,s6
    80004c64:	ec5fc0ef          	jal	ra,80001b28 <copyout>
    80004c68:	02054963          	bltz	a0,80004c9a <kexec+0x230>
    printf("[DEBUG] copyout SUCCESS\n");
    80004c6c:	856e                	mv	a0,s11
    80004c6e:	857fb0ef          	jal	ra,800004c4 <printf>
    ustack[argc] = sp;
    80004c72:	014bb023          	sd	s4,0(s7)
  for(argc = 0; argv[argc]; argc++) {
    80004c76:	0985                	addi	s3,s3,1
    80004c78:	04a1                	addi	s1,s1,8
    80004c7a:	6088                	ld	a0,0(s1)
    80004c7c:	c90d                	beqz	a0,80004cae <kexec+0x244>
    if(argc >= MAXARG)
    80004c7e:	0ba1                	addi	s7,s7,8
    80004c80:	f9040793          	addi	a5,s0,-112
    80004c84:	fb7794e3          	bne	a5,s7,80004c2c <kexec+0x1c2>
  ip = 0;
    80004c88:	4a01                	li	s4,0
    proc_freepagetable(pagetable, sz);
    80004c8a:	85d6                	mv	a1,s5
    80004c8c:	855a                	mv	a0,s6
    80004c8e:	ad6fd0ef          	jal	ra,80001f64 <proc_freepagetable>
  if(ip){
    80004c92:	e20a1ee3          	bnez	s4,80004ace <kexec+0x64>
  return -1;
    80004c96:	557d                	li	a0,-1
    80004c98:	b589                	j	80004ada <kexec+0x70>
      printf("[DEBUG] copyout FAILED\n");
    80004c9a:	00003517          	auipc	a0,0x3
    80004c9e:	d3e50513          	addi	a0,a0,-706 # 800079d8 <syscalls+0x350>
    80004ca2:	823fb0ef          	jal	ra,800004c4 <printf>
  ip = 0;
    80004ca6:	4a01                	li	s4,0
      goto bad;
    80004ca8:	b7cd                	j	80004c8a <kexec+0x220>
  sp = sz;
    80004caa:	8a56                	mv	s4,s5
  for(argc = 0; argv[argc]; argc++) {
    80004cac:	4981                	li	s3,0
  ustack[argc] = 0;
    80004cae:	00399793          	slli	a5,s3,0x3
    80004cb2:	f9040713          	addi	a4,s0,-112
    80004cb6:	97ba                	add	a5,a5,a4
    80004cb8:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004cbc:	00198b93          	addi	s7,s3,1 # 2001 <_entry-0x7fffdfff>
    80004cc0:	0b8e                	slli	s7,s7,0x3
    80004cc2:	417a04b3          	sub	s1,s4,s7
  sp -= sp % 16;
    80004cc6:	98c1                	andi	s1,s1,-16
  ip = 0;
    80004cc8:	4a01                	li	s4,0
  if(sp < stackbase)
    80004cca:	fd94e0e3          	bltu	s1,s9,80004c8a <kexec+0x220>
  printf("[DEBUG] copyout ustack to sp=0x%lx\n", sp);
    80004cce:	85a6                	mv	a1,s1
    80004cd0:	00003517          	auipc	a0,0x3
    80004cd4:	d4050513          	addi	a0,a0,-704 # 80007a10 <syscalls+0x388>
    80004cd8:	fecfb0ef          	jal	ra,800004c4 <printf>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004cdc:	86de                	mv	a3,s7
    80004cde:	e9040613          	addi	a2,s0,-368
    80004ce2:	85a6                	mv	a1,s1
    80004ce4:	855a                	mv	a0,s6
    80004ce6:	e43fc0ef          	jal	ra,80001b28 <copyout>
    80004cea:	06054563          	bltz	a0,80004d54 <kexec+0x2ea>
  p->trapframe->a1 = sp;
    80004cee:	e0843783          	ld	a5,-504(s0)
    80004cf2:	6fbc                	ld	a5,88(a5)
    80004cf4:	ffa4                	sd	s1,120(a5)
  for(last=s=path; *s; s++)
    80004cf6:	00094703          	lbu	a4,0(s2)
    80004cfa:	cf11                	beqz	a4,80004d16 <kexec+0x2ac>
    80004cfc:	00190793          	addi	a5,s2,1
    if(*s == '/')
    80004d00:	02f00693          	li	a3,47
    80004d04:	a029                	j	80004d0e <kexec+0x2a4>
  for(last=s=path; *s; s++)
    80004d06:	0785                	addi	a5,a5,1
    80004d08:	fff7c703          	lbu	a4,-1(a5)
    80004d0c:	c709                	beqz	a4,80004d16 <kexec+0x2ac>
    if(*s == '/')
    80004d0e:	fed71ce3          	bne	a4,a3,80004d06 <kexec+0x29c>
      last = s+1;
    80004d12:	893e                	mv	s2,a5
    80004d14:	bfcd                	j	80004d06 <kexec+0x29c>
  safestrcpy(p->name, last, sizeof(p->name));
    80004d16:	4641                	li	a2,16
    80004d18:	85ca                	mv	a1,s2
    80004d1a:	e0843903          	ld	s2,-504(s0)
    80004d1e:	15890513          	addi	a0,s2,344
    80004d22:	864fc0ef          	jal	ra,80000d86 <safestrcpy>
  oldpagetable = p->pagetable;
    80004d26:	05093503          	ld	a0,80(s2)
  p->pagetable = pagetable;
    80004d2a:	05693823          	sd	s6,80(s2)
  p->sz = sz;
    80004d2e:	05593423          	sd	s5,72(s2)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004d32:	05893783          	ld	a5,88(s2)
    80004d36:	e6843703          	ld	a4,-408(s0)
    80004d3a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004d3c:	05893783          	ld	a5,88(s2)
    80004d40:	fb84                	sd	s1,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004d42:	e0043583          	ld	a1,-512(s0)
    80004d46:	a1efd0ef          	jal	ra,80001f64 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004d4a:	0009851b          	sext.w	a0,s3
    80004d4e:	b371                	j	80004ada <kexec+0x70>
  ip = 0;
    80004d50:	4a01                	li	s4,0
    80004d52:	bf25                	j	80004c8a <kexec+0x220>
    80004d54:	4a01                	li	s4,0
    80004d56:	bf15                	j	80004c8a <kexec+0x220>

0000000080004d58 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004d58:	7179                	addi	sp,sp,-48
    80004d5a:	f406                	sd	ra,40(sp)
    80004d5c:	f022                	sd	s0,32(sp)
    80004d5e:	ec26                	sd	s1,24(sp)
    80004d60:	e84a                	sd	s2,16(sp)
    80004d62:	1800                	addi	s0,sp,48
    80004d64:	892e                	mv	s2,a1
    80004d66:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004d68:	fdc40593          	addi	a1,s0,-36
    80004d6c:	f99fd0ef          	jal	ra,80002d04 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004d70:	fdc42703          	lw	a4,-36(s0)
    80004d74:	47bd                	li	a5,15
    80004d76:	02e7e963          	bltu	a5,a4,80004da8 <argfd+0x50>
    80004d7a:	860fd0ef          	jal	ra,80001dda <myproc>
    80004d7e:	fdc42703          	lw	a4,-36(s0)
    80004d82:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffcc942>
    80004d86:	078e                	slli	a5,a5,0x3
    80004d88:	953e                	add	a0,a0,a5
    80004d8a:	611c                	ld	a5,0(a0)
    80004d8c:	c385                	beqz	a5,80004dac <argfd+0x54>
    return -1;
  if(pfd)
    80004d8e:	00090463          	beqz	s2,80004d96 <argfd+0x3e>
    *pfd = fd;
    80004d92:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004d96:	4501                	li	a0,0
  if(pf)
    80004d98:	c091                	beqz	s1,80004d9c <argfd+0x44>
    *pf = f;
    80004d9a:	e09c                	sd	a5,0(s1)
}
    80004d9c:	70a2                	ld	ra,40(sp)
    80004d9e:	7402                	ld	s0,32(sp)
    80004da0:	64e2                	ld	s1,24(sp)
    80004da2:	6942                	ld	s2,16(sp)
    80004da4:	6145                	addi	sp,sp,48
    80004da6:	8082                	ret
    return -1;
    80004da8:	557d                	li	a0,-1
    80004daa:	bfcd                	j	80004d9c <argfd+0x44>
    80004dac:	557d                	li	a0,-1
    80004dae:	b7fd                	j	80004d9c <argfd+0x44>

0000000080004db0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004db0:	1101                	addi	sp,sp,-32
    80004db2:	ec06                	sd	ra,24(sp)
    80004db4:	e822                	sd	s0,16(sp)
    80004db6:	e426                	sd	s1,8(sp)
    80004db8:	1000                	addi	s0,sp,32
    80004dba:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004dbc:	81efd0ef          	jal	ra,80001dda <myproc>
    80004dc0:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004dc2:	0d050793          	addi	a5,a0,208
    80004dc6:	4501                	li	a0,0
    80004dc8:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004dca:	6398                	ld	a4,0(a5)
    80004dcc:	cb19                	beqz	a4,80004de2 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004dce:	2505                	addiw	a0,a0,1
    80004dd0:	07a1                	addi	a5,a5,8
    80004dd2:	fed51ce3          	bne	a0,a3,80004dca <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004dd6:	557d                	li	a0,-1
}
    80004dd8:	60e2                	ld	ra,24(sp)
    80004dda:	6442                	ld	s0,16(sp)
    80004ddc:	64a2                	ld	s1,8(sp)
    80004dde:	6105                	addi	sp,sp,32
    80004de0:	8082                	ret
      p->ofile[fd] = f;
    80004de2:	01a50793          	addi	a5,a0,26
    80004de6:	078e                	slli	a5,a5,0x3
    80004de8:	963e                	add	a2,a2,a5
    80004dea:	e204                	sd	s1,0(a2)
      return fd;
    80004dec:	b7f5                	j	80004dd8 <fdalloc+0x28>

0000000080004dee <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004dee:	715d                	addi	sp,sp,-80
    80004df0:	e486                	sd	ra,72(sp)
    80004df2:	e0a2                	sd	s0,64(sp)
    80004df4:	fc26                	sd	s1,56(sp)
    80004df6:	f84a                	sd	s2,48(sp)
    80004df8:	f44e                	sd	s3,40(sp)
    80004dfa:	f052                	sd	s4,32(sp)
    80004dfc:	ec56                	sd	s5,24(sp)
    80004dfe:	e85a                	sd	s6,16(sp)
    80004e00:	0880                	addi	s0,sp,80
    80004e02:	8b2e                	mv	s6,a1
    80004e04:	89b2                	mv	s3,a2
    80004e06:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004e08:	fb040593          	addi	a1,s0,-80
    80004e0c:	8d8ff0ef          	jal	ra,80003ee4 <nameiparent>
    80004e10:	84aa                	mv	s1,a0
    80004e12:	10050b63          	beqz	a0,80004f28 <create+0x13a>
    return 0;

  ilock(dp);
    80004e16:	8c7fe0ef          	jal	ra,800036dc <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004e1a:	4601                	li	a2,0
    80004e1c:	fb040593          	addi	a1,s0,-80
    80004e20:	8526                	mv	a0,s1
    80004e22:	e43fe0ef          	jal	ra,80003c64 <dirlookup>
    80004e26:	8aaa                	mv	s5,a0
    80004e28:	c521                	beqz	a0,80004e70 <create+0x82>
    iunlockput(dp);
    80004e2a:	8526                	mv	a0,s1
    80004e2c:	ab7fe0ef          	jal	ra,800038e2 <iunlockput>
    ilock(ip);
    80004e30:	8556                	mv	a0,s5
    80004e32:	8abfe0ef          	jal	ra,800036dc <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004e36:	000b059b          	sext.w	a1,s6
    80004e3a:	4789                	li	a5,2
    80004e3c:	02f59563          	bne	a1,a5,80004e66 <create+0x78>
    80004e40:	044ad783          	lhu	a5,68(s5)
    80004e44:	37f9                	addiw	a5,a5,-2
    80004e46:	17c2                	slli	a5,a5,0x30
    80004e48:	93c1                	srli	a5,a5,0x30
    80004e4a:	4705                	li	a4,1
    80004e4c:	00f76d63          	bltu	a4,a5,80004e66 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004e50:	8556                	mv	a0,s5
    80004e52:	60a6                	ld	ra,72(sp)
    80004e54:	6406                	ld	s0,64(sp)
    80004e56:	74e2                	ld	s1,56(sp)
    80004e58:	7942                	ld	s2,48(sp)
    80004e5a:	79a2                	ld	s3,40(sp)
    80004e5c:	7a02                	ld	s4,32(sp)
    80004e5e:	6ae2                	ld	s5,24(sp)
    80004e60:	6b42                	ld	s6,16(sp)
    80004e62:	6161                	addi	sp,sp,80
    80004e64:	8082                	ret
    iunlockput(ip);
    80004e66:	8556                	mv	a0,s5
    80004e68:	a7bfe0ef          	jal	ra,800038e2 <iunlockput>
    return 0;
    80004e6c:	4a81                	li	s5,0
    80004e6e:	b7cd                	j	80004e50 <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004e70:	85da                	mv	a1,s6
    80004e72:	4088                	lw	a0,0(s1)
    80004e74:	f00fe0ef          	jal	ra,80003574 <ialloc>
    80004e78:	8a2a                	mv	s4,a0
    80004e7a:	cd1d                	beqz	a0,80004eb8 <create+0xca>
  ilock(ip);
    80004e7c:	861fe0ef          	jal	ra,800036dc <ilock>
  ip->major = major;
    80004e80:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004e84:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004e88:	4905                	li	s2,1
    80004e8a:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004e8e:	8552                	mv	a0,s4
    80004e90:	f9afe0ef          	jal	ra,8000362a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004e94:	000b059b          	sext.w	a1,s6
    80004e98:	03258563          	beq	a1,s2,80004ec2 <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    80004e9c:	004a2603          	lw	a2,4(s4)
    80004ea0:	fb040593          	addi	a1,s0,-80
    80004ea4:	8526                	mv	a0,s1
    80004ea6:	f8bfe0ef          	jal	ra,80003e30 <dirlink>
    80004eaa:	06054363          	bltz	a0,80004f10 <create+0x122>
  iunlockput(dp);
    80004eae:	8526                	mv	a0,s1
    80004eb0:	a33fe0ef          	jal	ra,800038e2 <iunlockput>
  return ip;
    80004eb4:	8ad2                	mv	s5,s4
    80004eb6:	bf69                	j	80004e50 <create+0x62>
    iunlockput(dp);
    80004eb8:	8526                	mv	a0,s1
    80004eba:	a29fe0ef          	jal	ra,800038e2 <iunlockput>
    return 0;
    80004ebe:	8ad2                	mv	s5,s4
    80004ec0:	bf41                	j	80004e50 <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004ec2:	004a2603          	lw	a2,4(s4)
    80004ec6:	00003597          	auipc	a1,0x3
    80004eca:	b7258593          	addi	a1,a1,-1166 # 80007a38 <syscalls+0x3b0>
    80004ece:	8552                	mv	a0,s4
    80004ed0:	f61fe0ef          	jal	ra,80003e30 <dirlink>
    80004ed4:	02054e63          	bltz	a0,80004f10 <create+0x122>
    80004ed8:	40d0                	lw	a2,4(s1)
    80004eda:	00003597          	auipc	a1,0x3
    80004ede:	b6658593          	addi	a1,a1,-1178 # 80007a40 <syscalls+0x3b8>
    80004ee2:	8552                	mv	a0,s4
    80004ee4:	f4dfe0ef          	jal	ra,80003e30 <dirlink>
    80004ee8:	02054463          	bltz	a0,80004f10 <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    80004eec:	004a2603          	lw	a2,4(s4)
    80004ef0:	fb040593          	addi	a1,s0,-80
    80004ef4:	8526                	mv	a0,s1
    80004ef6:	f3bfe0ef          	jal	ra,80003e30 <dirlink>
    80004efa:	00054b63          	bltz	a0,80004f10 <create+0x122>
    dp->nlink++;  // for ".."
    80004efe:	04a4d783          	lhu	a5,74(s1)
    80004f02:	2785                	addiw	a5,a5,1
    80004f04:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004f08:	8526                	mv	a0,s1
    80004f0a:	f20fe0ef          	jal	ra,8000362a <iupdate>
    80004f0e:	b745                	j	80004eae <create+0xc0>
  ip->nlink = 0;
    80004f10:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004f14:	8552                	mv	a0,s4
    80004f16:	f14fe0ef          	jal	ra,8000362a <iupdate>
  iunlockput(ip);
    80004f1a:	8552                	mv	a0,s4
    80004f1c:	9c7fe0ef          	jal	ra,800038e2 <iunlockput>
  iunlockput(dp);
    80004f20:	8526                	mv	a0,s1
    80004f22:	9c1fe0ef          	jal	ra,800038e2 <iunlockput>
  return 0;
    80004f26:	b72d                	j	80004e50 <create+0x62>
    return 0;
    80004f28:	8aaa                	mv	s5,a0
    80004f2a:	b71d                	j	80004e50 <create+0x62>

0000000080004f2c <sys_dup>:
{
    80004f2c:	7179                	addi	sp,sp,-48
    80004f2e:	f406                	sd	ra,40(sp)
    80004f30:	f022                	sd	s0,32(sp)
    80004f32:	ec26                	sd	s1,24(sp)
    80004f34:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004f36:	fd840613          	addi	a2,s0,-40
    80004f3a:	4581                	li	a1,0
    80004f3c:	4501                	li	a0,0
    80004f3e:	e1bff0ef          	jal	ra,80004d58 <argfd>
    return -1;
    80004f42:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004f44:	00054f63          	bltz	a0,80004f62 <sys_dup+0x36>
  if((fd=fdalloc(f)) < 0)
    80004f48:	fd843503          	ld	a0,-40(s0)
    80004f4c:	e65ff0ef          	jal	ra,80004db0 <fdalloc>
    80004f50:	84aa                	mv	s1,a0
    return -1;
    80004f52:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004f54:	00054763          	bltz	a0,80004f62 <sys_dup+0x36>
  filedup(f);
    80004f58:	fd843503          	ld	a0,-40(s0)
    80004f5c:	d26ff0ef          	jal	ra,80004482 <filedup>
  return fd;
    80004f60:	87a6                	mv	a5,s1
}
    80004f62:	853e                	mv	a0,a5
    80004f64:	70a2                	ld	ra,40(sp)
    80004f66:	7402                	ld	s0,32(sp)
    80004f68:	64e2                	ld	s1,24(sp)
    80004f6a:	6145                	addi	sp,sp,48
    80004f6c:	8082                	ret

0000000080004f6e <sys_read>:
{
    80004f6e:	7179                	addi	sp,sp,-48
    80004f70:	f406                	sd	ra,40(sp)
    80004f72:	f022                	sd	s0,32(sp)
    80004f74:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f76:	fd840593          	addi	a1,s0,-40
    80004f7a:	4505                	li	a0,1
    80004f7c:	da5fd0ef          	jal	ra,80002d20 <argaddr>
  argint(2, &n);
    80004f80:	fe440593          	addi	a1,s0,-28
    80004f84:	4509                	li	a0,2
    80004f86:	d7ffd0ef          	jal	ra,80002d04 <argint>
  if(argfd(0, 0, &f) < 0)
    80004f8a:	fe840613          	addi	a2,s0,-24
    80004f8e:	4581                	li	a1,0
    80004f90:	4501                	li	a0,0
    80004f92:	dc7ff0ef          	jal	ra,80004d58 <argfd>
    80004f96:	87aa                	mv	a5,a0
    return -1;
    80004f98:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004f9a:	0007ca63          	bltz	a5,80004fae <sys_read+0x40>
  return fileread(f, p, n);
    80004f9e:	fe442603          	lw	a2,-28(s0)
    80004fa2:	fd843583          	ld	a1,-40(s0)
    80004fa6:	fe843503          	ld	a0,-24(s0)
    80004faa:	e24ff0ef          	jal	ra,800045ce <fileread>
}
    80004fae:	70a2                	ld	ra,40(sp)
    80004fb0:	7402                	ld	s0,32(sp)
    80004fb2:	6145                	addi	sp,sp,48
    80004fb4:	8082                	ret

0000000080004fb6 <sys_write>:
{
    80004fb6:	7179                	addi	sp,sp,-48
    80004fb8:	f406                	sd	ra,40(sp)
    80004fba:	f022                	sd	s0,32(sp)
    80004fbc:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004fbe:	fd840593          	addi	a1,s0,-40
    80004fc2:	4505                	li	a0,1
    80004fc4:	d5dfd0ef          	jal	ra,80002d20 <argaddr>
  argint(2, &n);
    80004fc8:	fe440593          	addi	a1,s0,-28
    80004fcc:	4509                	li	a0,2
    80004fce:	d37fd0ef          	jal	ra,80002d04 <argint>
  if(argfd(0, 0, &f) < 0)
    80004fd2:	fe840613          	addi	a2,s0,-24
    80004fd6:	4581                	li	a1,0
    80004fd8:	4501                	li	a0,0
    80004fda:	d7fff0ef          	jal	ra,80004d58 <argfd>
    80004fde:	87aa                	mv	a5,a0
    return -1;
    80004fe0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004fe2:	0007ca63          	bltz	a5,80004ff6 <sys_write+0x40>
  return filewrite(f, p, n);
    80004fe6:	fe442603          	lw	a2,-28(s0)
    80004fea:	fd843583          	ld	a1,-40(s0)
    80004fee:	fe843503          	ld	a0,-24(s0)
    80004ff2:	e8aff0ef          	jal	ra,8000467c <filewrite>
}
    80004ff6:	70a2                	ld	ra,40(sp)
    80004ff8:	7402                	ld	s0,32(sp)
    80004ffa:	6145                	addi	sp,sp,48
    80004ffc:	8082                	ret

0000000080004ffe <sys_close>:
{
    80004ffe:	1101                	addi	sp,sp,-32
    80005000:	ec06                	sd	ra,24(sp)
    80005002:	e822                	sd	s0,16(sp)
    80005004:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005006:	fe040613          	addi	a2,s0,-32
    8000500a:	fec40593          	addi	a1,s0,-20
    8000500e:	4501                	li	a0,0
    80005010:	d49ff0ef          	jal	ra,80004d58 <argfd>
    return -1;
    80005014:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005016:	02054063          	bltz	a0,80005036 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    8000501a:	dc1fc0ef          	jal	ra,80001dda <myproc>
    8000501e:	fec42783          	lw	a5,-20(s0)
    80005022:	07e9                	addi	a5,a5,26
    80005024:	078e                	slli	a5,a5,0x3
    80005026:	97aa                	add	a5,a5,a0
    80005028:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000502c:	fe043503          	ld	a0,-32(s0)
    80005030:	c98ff0ef          	jal	ra,800044c8 <fileclose>
  return 0;
    80005034:	4781                	li	a5,0
}
    80005036:	853e                	mv	a0,a5
    80005038:	60e2                	ld	ra,24(sp)
    8000503a:	6442                	ld	s0,16(sp)
    8000503c:	6105                	addi	sp,sp,32
    8000503e:	8082                	ret

0000000080005040 <sys_fstat>:
{
    80005040:	1101                	addi	sp,sp,-32
    80005042:	ec06                	sd	ra,24(sp)
    80005044:	e822                	sd	s0,16(sp)
    80005046:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005048:	fe040593          	addi	a1,s0,-32
    8000504c:	4505                	li	a0,1
    8000504e:	cd3fd0ef          	jal	ra,80002d20 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005052:	fe840613          	addi	a2,s0,-24
    80005056:	4581                	li	a1,0
    80005058:	4501                	li	a0,0
    8000505a:	cffff0ef          	jal	ra,80004d58 <argfd>
    8000505e:	87aa                	mv	a5,a0
    return -1;
    80005060:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005062:	0007c863          	bltz	a5,80005072 <sys_fstat+0x32>
  return filestat(f, st);
    80005066:	fe043583          	ld	a1,-32(s0)
    8000506a:	fe843503          	ld	a0,-24(s0)
    8000506e:	d02ff0ef          	jal	ra,80004570 <filestat>
}
    80005072:	60e2                	ld	ra,24(sp)
    80005074:	6442                	ld	s0,16(sp)
    80005076:	6105                	addi	sp,sp,32
    80005078:	8082                	ret

000000008000507a <sys_link>:
{
    8000507a:	7169                	addi	sp,sp,-304
    8000507c:	f606                	sd	ra,296(sp)
    8000507e:	f222                	sd	s0,288(sp)
    80005080:	ee26                	sd	s1,280(sp)
    80005082:	ea4a                	sd	s2,272(sp)
    80005084:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005086:	08000613          	li	a2,128
    8000508a:	ed040593          	addi	a1,s0,-304
    8000508e:	4501                	li	a0,0
    80005090:	cadfd0ef          	jal	ra,80002d3c <argstr>
    return -1;
    80005094:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005096:	0c054663          	bltz	a0,80005162 <sys_link+0xe8>
    8000509a:	08000613          	li	a2,128
    8000509e:	f5040593          	addi	a1,s0,-176
    800050a2:	4505                	li	a0,1
    800050a4:	c99fd0ef          	jal	ra,80002d3c <argstr>
    return -1;
    800050a8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050aa:	0a054c63          	bltz	a0,80005162 <sys_link+0xe8>
  begin_op();
    800050ae:	80cff0ef          	jal	ra,800040ba <begin_op>
  if((ip = namei(old)) == 0){
    800050b2:	ed040513          	addi	a0,s0,-304
    800050b6:	e15fe0ef          	jal	ra,80003eca <namei>
    800050ba:	84aa                	mv	s1,a0
    800050bc:	c525                	beqz	a0,80005124 <sys_link+0xaa>
  ilock(ip);
    800050be:	e1efe0ef          	jal	ra,800036dc <ilock>
  if(ip->type == T_DIR){
    800050c2:	04449703          	lh	a4,68(s1)
    800050c6:	4785                	li	a5,1
    800050c8:	06f70263          	beq	a4,a5,8000512c <sys_link+0xb2>
  ip->nlink++;
    800050cc:	04a4d783          	lhu	a5,74(s1)
    800050d0:	2785                	addiw	a5,a5,1
    800050d2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800050d6:	8526                	mv	a0,s1
    800050d8:	d52fe0ef          	jal	ra,8000362a <iupdate>
  iunlock(ip);
    800050dc:	8526                	mv	a0,s1
    800050de:	ea8fe0ef          	jal	ra,80003786 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800050e2:	fd040593          	addi	a1,s0,-48
    800050e6:	f5040513          	addi	a0,s0,-176
    800050ea:	dfbfe0ef          	jal	ra,80003ee4 <nameiparent>
    800050ee:	892a                	mv	s2,a0
    800050f0:	c921                	beqz	a0,80005140 <sys_link+0xc6>
  ilock(dp);
    800050f2:	deafe0ef          	jal	ra,800036dc <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800050f6:	00092703          	lw	a4,0(s2)
    800050fa:	409c                	lw	a5,0(s1)
    800050fc:	02f71f63          	bne	a4,a5,8000513a <sys_link+0xc0>
    80005100:	40d0                	lw	a2,4(s1)
    80005102:	fd040593          	addi	a1,s0,-48
    80005106:	854a                	mv	a0,s2
    80005108:	d29fe0ef          	jal	ra,80003e30 <dirlink>
    8000510c:	02054763          	bltz	a0,8000513a <sys_link+0xc0>
  iunlockput(dp);
    80005110:	854a                	mv	a0,s2
    80005112:	fd0fe0ef          	jal	ra,800038e2 <iunlockput>
  iput(ip);
    80005116:	8526                	mv	a0,s1
    80005118:	f42fe0ef          	jal	ra,8000385a <iput>
  end_op();
    8000511c:	80eff0ef          	jal	ra,8000412a <end_op>
  return 0;
    80005120:	4781                	li	a5,0
    80005122:	a081                	j	80005162 <sys_link+0xe8>
    end_op();
    80005124:	806ff0ef          	jal	ra,8000412a <end_op>
    return -1;
    80005128:	57fd                	li	a5,-1
    8000512a:	a825                	j	80005162 <sys_link+0xe8>
    iunlockput(ip);
    8000512c:	8526                	mv	a0,s1
    8000512e:	fb4fe0ef          	jal	ra,800038e2 <iunlockput>
    end_op();
    80005132:	ff9fe0ef          	jal	ra,8000412a <end_op>
    return -1;
    80005136:	57fd                	li	a5,-1
    80005138:	a02d                	j	80005162 <sys_link+0xe8>
    iunlockput(dp);
    8000513a:	854a                	mv	a0,s2
    8000513c:	fa6fe0ef          	jal	ra,800038e2 <iunlockput>
  ilock(ip);
    80005140:	8526                	mv	a0,s1
    80005142:	d9afe0ef          	jal	ra,800036dc <ilock>
  ip->nlink--;
    80005146:	04a4d783          	lhu	a5,74(s1)
    8000514a:	37fd                	addiw	a5,a5,-1
    8000514c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005150:	8526                	mv	a0,s1
    80005152:	cd8fe0ef          	jal	ra,8000362a <iupdate>
  iunlockput(ip);
    80005156:	8526                	mv	a0,s1
    80005158:	f8afe0ef          	jal	ra,800038e2 <iunlockput>
  end_op();
    8000515c:	fcffe0ef          	jal	ra,8000412a <end_op>
  return -1;
    80005160:	57fd                	li	a5,-1
}
    80005162:	853e                	mv	a0,a5
    80005164:	70b2                	ld	ra,296(sp)
    80005166:	7412                	ld	s0,288(sp)
    80005168:	64f2                	ld	s1,280(sp)
    8000516a:	6952                	ld	s2,272(sp)
    8000516c:	6155                	addi	sp,sp,304
    8000516e:	8082                	ret

0000000080005170 <sys_unlink>:
{
    80005170:	7151                	addi	sp,sp,-240
    80005172:	f586                	sd	ra,232(sp)
    80005174:	f1a2                	sd	s0,224(sp)
    80005176:	eda6                	sd	s1,216(sp)
    80005178:	e9ca                	sd	s2,208(sp)
    8000517a:	e5ce                	sd	s3,200(sp)
    8000517c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000517e:	08000613          	li	a2,128
    80005182:	f3040593          	addi	a1,s0,-208
    80005186:	4501                	li	a0,0
    80005188:	bb5fd0ef          	jal	ra,80002d3c <argstr>
    8000518c:	12054b63          	bltz	a0,800052c2 <sys_unlink+0x152>
  begin_op();
    80005190:	f2bfe0ef          	jal	ra,800040ba <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005194:	fb040593          	addi	a1,s0,-80
    80005198:	f3040513          	addi	a0,s0,-208
    8000519c:	d49fe0ef          	jal	ra,80003ee4 <nameiparent>
    800051a0:	84aa                	mv	s1,a0
    800051a2:	c54d                	beqz	a0,8000524c <sys_unlink+0xdc>
  ilock(dp);
    800051a4:	d38fe0ef          	jal	ra,800036dc <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800051a8:	00003597          	auipc	a1,0x3
    800051ac:	89058593          	addi	a1,a1,-1904 # 80007a38 <syscalls+0x3b0>
    800051b0:	fb040513          	addi	a0,s0,-80
    800051b4:	a9bfe0ef          	jal	ra,80003c4e <namecmp>
    800051b8:	10050a63          	beqz	a0,800052cc <sys_unlink+0x15c>
    800051bc:	00003597          	auipc	a1,0x3
    800051c0:	88458593          	addi	a1,a1,-1916 # 80007a40 <syscalls+0x3b8>
    800051c4:	fb040513          	addi	a0,s0,-80
    800051c8:	a87fe0ef          	jal	ra,80003c4e <namecmp>
    800051cc:	10050063          	beqz	a0,800052cc <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800051d0:	f2c40613          	addi	a2,s0,-212
    800051d4:	fb040593          	addi	a1,s0,-80
    800051d8:	8526                	mv	a0,s1
    800051da:	a8bfe0ef          	jal	ra,80003c64 <dirlookup>
    800051de:	892a                	mv	s2,a0
    800051e0:	0e050663          	beqz	a0,800052cc <sys_unlink+0x15c>
  ilock(ip);
    800051e4:	cf8fe0ef          	jal	ra,800036dc <ilock>
  if(ip->nlink < 1)
    800051e8:	04a91783          	lh	a5,74(s2)
    800051ec:	06f05463          	blez	a5,80005254 <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800051f0:	04491703          	lh	a4,68(s2)
    800051f4:	4785                	li	a5,1
    800051f6:	06f70563          	beq	a4,a5,80005260 <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    800051fa:	4641                	li	a2,16
    800051fc:	4581                	li	a1,0
    800051fe:	fc040513          	addi	a0,s0,-64
    80005202:	a3ffb0ef          	jal	ra,80000c40 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005206:	4741                	li	a4,16
    80005208:	f2c42683          	lw	a3,-212(s0)
    8000520c:	fc040613          	addi	a2,s0,-64
    80005210:	4581                	li	a1,0
    80005212:	8526                	mv	a0,s1
    80005214:	939fe0ef          	jal	ra,80003b4c <writei>
    80005218:	47c1                	li	a5,16
    8000521a:	08f51563          	bne	a0,a5,800052a4 <sys_unlink+0x134>
  if(ip->type == T_DIR){
    8000521e:	04491703          	lh	a4,68(s2)
    80005222:	4785                	li	a5,1
    80005224:	08f70663          	beq	a4,a5,800052b0 <sys_unlink+0x140>
  iunlockput(dp);
    80005228:	8526                	mv	a0,s1
    8000522a:	eb8fe0ef          	jal	ra,800038e2 <iunlockput>
  ip->nlink--;
    8000522e:	04a95783          	lhu	a5,74(s2)
    80005232:	37fd                	addiw	a5,a5,-1
    80005234:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005238:	854a                	mv	a0,s2
    8000523a:	bf0fe0ef          	jal	ra,8000362a <iupdate>
  iunlockput(ip);
    8000523e:	854a                	mv	a0,s2
    80005240:	ea2fe0ef          	jal	ra,800038e2 <iunlockput>
  end_op();
    80005244:	ee7fe0ef          	jal	ra,8000412a <end_op>
  return 0;
    80005248:	4501                	li	a0,0
    8000524a:	a079                	j	800052d8 <sys_unlink+0x168>
    end_op();
    8000524c:	edffe0ef          	jal	ra,8000412a <end_op>
    return -1;
    80005250:	557d                	li	a0,-1
    80005252:	a059                	j	800052d8 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80005254:	00002517          	auipc	a0,0x2
    80005258:	7f450513          	addi	a0,a0,2036 # 80007a48 <syscalls+0x3c0>
    8000525c:	d2efb0ef          	jal	ra,8000078a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005260:	04c92703          	lw	a4,76(s2)
    80005264:	02000793          	li	a5,32
    80005268:	f8e7f9e3          	bgeu	a5,a4,800051fa <sys_unlink+0x8a>
    8000526c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005270:	4741                	li	a4,16
    80005272:	86ce                	mv	a3,s3
    80005274:	f1840613          	addi	a2,s0,-232
    80005278:	4581                	li	a1,0
    8000527a:	854a                	mv	a0,s2
    8000527c:	fecfe0ef          	jal	ra,80003a68 <readi>
    80005280:	47c1                	li	a5,16
    80005282:	00f51b63          	bne	a0,a5,80005298 <sys_unlink+0x128>
    if(de.inum != 0)
    80005286:	f1845783          	lhu	a5,-232(s0)
    8000528a:	ef95                	bnez	a5,800052c6 <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000528c:	29c1                	addiw	s3,s3,16
    8000528e:	04c92783          	lw	a5,76(s2)
    80005292:	fcf9efe3          	bltu	s3,a5,80005270 <sys_unlink+0x100>
    80005296:	b795                	j	800051fa <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005298:	00002517          	auipc	a0,0x2
    8000529c:	7c850513          	addi	a0,a0,1992 # 80007a60 <syscalls+0x3d8>
    800052a0:	ceafb0ef          	jal	ra,8000078a <panic>
    panic("unlink: writei");
    800052a4:	00002517          	auipc	a0,0x2
    800052a8:	7d450513          	addi	a0,a0,2004 # 80007a78 <syscalls+0x3f0>
    800052ac:	cdefb0ef          	jal	ra,8000078a <panic>
    dp->nlink--;
    800052b0:	04a4d783          	lhu	a5,74(s1)
    800052b4:	37fd                	addiw	a5,a5,-1
    800052b6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800052ba:	8526                	mv	a0,s1
    800052bc:	b6efe0ef          	jal	ra,8000362a <iupdate>
    800052c0:	b7a5                	j	80005228 <sys_unlink+0xb8>
    return -1;
    800052c2:	557d                	li	a0,-1
    800052c4:	a811                	j	800052d8 <sys_unlink+0x168>
    iunlockput(ip);
    800052c6:	854a                	mv	a0,s2
    800052c8:	e1afe0ef          	jal	ra,800038e2 <iunlockput>
  iunlockput(dp);
    800052cc:	8526                	mv	a0,s1
    800052ce:	e14fe0ef          	jal	ra,800038e2 <iunlockput>
  end_op();
    800052d2:	e59fe0ef          	jal	ra,8000412a <end_op>
  return -1;
    800052d6:	557d                	li	a0,-1
}
    800052d8:	70ae                	ld	ra,232(sp)
    800052da:	740e                	ld	s0,224(sp)
    800052dc:	64ee                	ld	s1,216(sp)
    800052de:	694e                	ld	s2,208(sp)
    800052e0:	69ae                	ld	s3,200(sp)
    800052e2:	616d                	addi	sp,sp,240
    800052e4:	8082                	ret

00000000800052e6 <sys_open>:

uint64
sys_open(void)
{
    800052e6:	7131                	addi	sp,sp,-192
    800052e8:	fd06                	sd	ra,184(sp)
    800052ea:	f922                	sd	s0,176(sp)
    800052ec:	f526                	sd	s1,168(sp)
    800052ee:	f14a                	sd	s2,160(sp)
    800052f0:	ed4e                	sd	s3,152(sp)
    800052f2:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800052f4:	f4c40593          	addi	a1,s0,-180
    800052f8:	4505                	li	a0,1
    800052fa:	a0bfd0ef          	jal	ra,80002d04 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800052fe:	08000613          	li	a2,128
    80005302:	f5040593          	addi	a1,s0,-176
    80005306:	4501                	li	a0,0
    80005308:	a35fd0ef          	jal	ra,80002d3c <argstr>
    8000530c:	87aa                	mv	a5,a0
    return -1;
    8000530e:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005310:	0807cd63          	bltz	a5,800053aa <sys_open+0xc4>

  begin_op();
    80005314:	da7fe0ef          	jal	ra,800040ba <begin_op>

  if(omode & O_CREATE){
    80005318:	f4c42783          	lw	a5,-180(s0)
    8000531c:	2007f793          	andi	a5,a5,512
    80005320:	c3c5                	beqz	a5,800053c0 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005322:	4681                	li	a3,0
    80005324:	4601                	li	a2,0
    80005326:	4589                	li	a1,2
    80005328:	f5040513          	addi	a0,s0,-176
    8000532c:	ac3ff0ef          	jal	ra,80004dee <create>
    80005330:	84aa                	mv	s1,a0
    if(ip == 0){
    80005332:	c159                	beqz	a0,800053b8 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005334:	04449703          	lh	a4,68(s1)
    80005338:	478d                	li	a5,3
    8000533a:	00f71763          	bne	a4,a5,80005348 <sys_open+0x62>
    8000533e:	0464d703          	lhu	a4,70(s1)
    80005342:	47a5                	li	a5,9
    80005344:	0ae7e963          	bltu	a5,a4,800053f6 <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005348:	8dcff0ef          	jal	ra,80004424 <filealloc>
    8000534c:	89aa                	mv	s3,a0
    8000534e:	0c050963          	beqz	a0,80005420 <sys_open+0x13a>
    80005352:	a5fff0ef          	jal	ra,80004db0 <fdalloc>
    80005356:	892a                	mv	s2,a0
    80005358:	0c054163          	bltz	a0,8000541a <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000535c:	04449703          	lh	a4,68(s1)
    80005360:	478d                	li	a5,3
    80005362:	0af70163          	beq	a4,a5,80005404 <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005366:	4789                	li	a5,2
    80005368:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000536c:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005370:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005374:	f4c42783          	lw	a5,-180(s0)
    80005378:	0017c713          	xori	a4,a5,1
    8000537c:	8b05                	andi	a4,a4,1
    8000537e:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005382:	0037f713          	andi	a4,a5,3
    80005386:	00e03733          	snez	a4,a4
    8000538a:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000538e:	4007f793          	andi	a5,a5,1024
    80005392:	c791                	beqz	a5,8000539e <sys_open+0xb8>
    80005394:	04449703          	lh	a4,68(s1)
    80005398:	4789                	li	a5,2
    8000539a:	06f70c63          	beq	a4,a5,80005412 <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    8000539e:	8526                	mv	a0,s1
    800053a0:	be6fe0ef          	jal	ra,80003786 <iunlock>
  end_op();
    800053a4:	d87fe0ef          	jal	ra,8000412a <end_op>

  return fd;
    800053a8:	854a                	mv	a0,s2
}
    800053aa:	70ea                	ld	ra,184(sp)
    800053ac:	744a                	ld	s0,176(sp)
    800053ae:	74aa                	ld	s1,168(sp)
    800053b0:	790a                	ld	s2,160(sp)
    800053b2:	69ea                	ld	s3,152(sp)
    800053b4:	6129                	addi	sp,sp,192
    800053b6:	8082                	ret
      end_op();
    800053b8:	d73fe0ef          	jal	ra,8000412a <end_op>
      return -1;
    800053bc:	557d                	li	a0,-1
    800053be:	b7f5                	j	800053aa <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    800053c0:	f5040513          	addi	a0,s0,-176
    800053c4:	b07fe0ef          	jal	ra,80003eca <namei>
    800053c8:	84aa                	mv	s1,a0
    800053ca:	c115                	beqz	a0,800053ee <sys_open+0x108>
    ilock(ip);
    800053cc:	b10fe0ef          	jal	ra,800036dc <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800053d0:	04449703          	lh	a4,68(s1)
    800053d4:	4785                	li	a5,1
    800053d6:	f4f71fe3          	bne	a4,a5,80005334 <sys_open+0x4e>
    800053da:	f4c42783          	lw	a5,-180(s0)
    800053de:	d7ad                	beqz	a5,80005348 <sys_open+0x62>
      iunlockput(ip);
    800053e0:	8526                	mv	a0,s1
    800053e2:	d00fe0ef          	jal	ra,800038e2 <iunlockput>
      end_op();
    800053e6:	d45fe0ef          	jal	ra,8000412a <end_op>
      return -1;
    800053ea:	557d                	li	a0,-1
    800053ec:	bf7d                	j	800053aa <sys_open+0xc4>
      end_op();
    800053ee:	d3dfe0ef          	jal	ra,8000412a <end_op>
      return -1;
    800053f2:	557d                	li	a0,-1
    800053f4:	bf5d                	j	800053aa <sys_open+0xc4>
    iunlockput(ip);
    800053f6:	8526                	mv	a0,s1
    800053f8:	ceafe0ef          	jal	ra,800038e2 <iunlockput>
    end_op();
    800053fc:	d2ffe0ef          	jal	ra,8000412a <end_op>
    return -1;
    80005400:	557d                	li	a0,-1
    80005402:	b765                	j	800053aa <sys_open+0xc4>
    f->type = FD_DEVICE;
    80005404:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005408:	04649783          	lh	a5,70(s1)
    8000540c:	02f99223          	sh	a5,36(s3)
    80005410:	b785                	j	80005370 <sys_open+0x8a>
    itrunc(ip);
    80005412:	8526                	mv	a0,s1
    80005414:	bb2fe0ef          	jal	ra,800037c6 <itrunc>
    80005418:	b759                	j	8000539e <sys_open+0xb8>
      fileclose(f);
    8000541a:	854e                	mv	a0,s3
    8000541c:	8acff0ef          	jal	ra,800044c8 <fileclose>
    iunlockput(ip);
    80005420:	8526                	mv	a0,s1
    80005422:	cc0fe0ef          	jal	ra,800038e2 <iunlockput>
    end_op();
    80005426:	d05fe0ef          	jal	ra,8000412a <end_op>
    return -1;
    8000542a:	557d                	li	a0,-1
    8000542c:	bfbd                	j	800053aa <sys_open+0xc4>

000000008000542e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000542e:	7175                	addi	sp,sp,-144
    80005430:	e506                	sd	ra,136(sp)
    80005432:	e122                	sd	s0,128(sp)
    80005434:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005436:	c85fe0ef          	jal	ra,800040ba <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000543a:	08000613          	li	a2,128
    8000543e:	f7040593          	addi	a1,s0,-144
    80005442:	4501                	li	a0,0
    80005444:	8f9fd0ef          	jal	ra,80002d3c <argstr>
    80005448:	02054363          	bltz	a0,8000546e <sys_mkdir+0x40>
    8000544c:	4681                	li	a3,0
    8000544e:	4601                	li	a2,0
    80005450:	4585                	li	a1,1
    80005452:	f7040513          	addi	a0,s0,-144
    80005456:	999ff0ef          	jal	ra,80004dee <create>
    8000545a:	c911                	beqz	a0,8000546e <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000545c:	c86fe0ef          	jal	ra,800038e2 <iunlockput>
  end_op();
    80005460:	ccbfe0ef          	jal	ra,8000412a <end_op>
  return 0;
    80005464:	4501                	li	a0,0
}
    80005466:	60aa                	ld	ra,136(sp)
    80005468:	640a                	ld	s0,128(sp)
    8000546a:	6149                	addi	sp,sp,144
    8000546c:	8082                	ret
    end_op();
    8000546e:	cbdfe0ef          	jal	ra,8000412a <end_op>
    return -1;
    80005472:	557d                	li	a0,-1
    80005474:	bfcd                	j	80005466 <sys_mkdir+0x38>

0000000080005476 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005476:	7135                	addi	sp,sp,-160
    80005478:	ed06                	sd	ra,152(sp)
    8000547a:	e922                	sd	s0,144(sp)
    8000547c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000547e:	c3dfe0ef          	jal	ra,800040ba <begin_op>
  argint(1, &major);
    80005482:	f6c40593          	addi	a1,s0,-148
    80005486:	4505                	li	a0,1
    80005488:	87dfd0ef          	jal	ra,80002d04 <argint>
  argint(2, &minor);
    8000548c:	f6840593          	addi	a1,s0,-152
    80005490:	4509                	li	a0,2
    80005492:	873fd0ef          	jal	ra,80002d04 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005496:	08000613          	li	a2,128
    8000549a:	f7040593          	addi	a1,s0,-144
    8000549e:	4501                	li	a0,0
    800054a0:	89dfd0ef          	jal	ra,80002d3c <argstr>
    800054a4:	02054563          	bltz	a0,800054ce <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800054a8:	f6841683          	lh	a3,-152(s0)
    800054ac:	f6c41603          	lh	a2,-148(s0)
    800054b0:	458d                	li	a1,3
    800054b2:	f7040513          	addi	a0,s0,-144
    800054b6:	939ff0ef          	jal	ra,80004dee <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800054ba:	c911                	beqz	a0,800054ce <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800054bc:	c26fe0ef          	jal	ra,800038e2 <iunlockput>
  end_op();
    800054c0:	c6bfe0ef          	jal	ra,8000412a <end_op>
  return 0;
    800054c4:	4501                	li	a0,0
}
    800054c6:	60ea                	ld	ra,152(sp)
    800054c8:	644a                	ld	s0,144(sp)
    800054ca:	610d                	addi	sp,sp,160
    800054cc:	8082                	ret
    end_op();
    800054ce:	c5dfe0ef          	jal	ra,8000412a <end_op>
    return -1;
    800054d2:	557d                	li	a0,-1
    800054d4:	bfcd                	j	800054c6 <sys_mknod+0x50>

00000000800054d6 <sys_chdir>:

uint64
sys_chdir(void)
{
    800054d6:	7135                	addi	sp,sp,-160
    800054d8:	ed06                	sd	ra,152(sp)
    800054da:	e922                	sd	s0,144(sp)
    800054dc:	e526                	sd	s1,136(sp)
    800054de:	e14a                	sd	s2,128(sp)
    800054e0:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800054e2:	8f9fc0ef          	jal	ra,80001dda <myproc>
    800054e6:	892a                	mv	s2,a0
  
  begin_op();
    800054e8:	bd3fe0ef          	jal	ra,800040ba <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800054ec:	08000613          	li	a2,128
    800054f0:	f6040593          	addi	a1,s0,-160
    800054f4:	4501                	li	a0,0
    800054f6:	847fd0ef          	jal	ra,80002d3c <argstr>
    800054fa:	04054163          	bltz	a0,8000553c <sys_chdir+0x66>
    800054fe:	f6040513          	addi	a0,s0,-160
    80005502:	9c9fe0ef          	jal	ra,80003eca <namei>
    80005506:	84aa                	mv	s1,a0
    80005508:	c915                	beqz	a0,8000553c <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000550a:	9d2fe0ef          	jal	ra,800036dc <ilock>
  if(ip->type != T_DIR){
    8000550e:	04449703          	lh	a4,68(s1)
    80005512:	4785                	li	a5,1
    80005514:	02f71863          	bne	a4,a5,80005544 <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005518:	8526                	mv	a0,s1
    8000551a:	a6cfe0ef          	jal	ra,80003786 <iunlock>
  iput(p->cwd);
    8000551e:	15093503          	ld	a0,336(s2)
    80005522:	b38fe0ef          	jal	ra,8000385a <iput>
  end_op();
    80005526:	c05fe0ef          	jal	ra,8000412a <end_op>
  p->cwd = ip;
    8000552a:	14993823          	sd	s1,336(s2)
  return 0;
    8000552e:	4501                	li	a0,0
}
    80005530:	60ea                	ld	ra,152(sp)
    80005532:	644a                	ld	s0,144(sp)
    80005534:	64aa                	ld	s1,136(sp)
    80005536:	690a                	ld	s2,128(sp)
    80005538:	610d                	addi	sp,sp,160
    8000553a:	8082                	ret
    end_op();
    8000553c:	beffe0ef          	jal	ra,8000412a <end_op>
    return -1;
    80005540:	557d                	li	a0,-1
    80005542:	b7fd                	j	80005530 <sys_chdir+0x5a>
    iunlockput(ip);
    80005544:	8526                	mv	a0,s1
    80005546:	b9cfe0ef          	jal	ra,800038e2 <iunlockput>
    end_op();
    8000554a:	be1fe0ef          	jal	ra,8000412a <end_op>
    return -1;
    8000554e:	557d                	li	a0,-1
    80005550:	b7c5                	j	80005530 <sys_chdir+0x5a>

0000000080005552 <sys_exec>:

uint64
sys_exec(void)
{
    80005552:	7145                	addi	sp,sp,-464
    80005554:	e786                	sd	ra,456(sp)
    80005556:	e3a2                	sd	s0,448(sp)
    80005558:	ff26                	sd	s1,440(sp)
    8000555a:	fb4a                	sd	s2,432(sp)
    8000555c:	f74e                	sd	s3,424(sp)
    8000555e:	f352                	sd	s4,416(sp)
    80005560:	ef56                	sd	s5,408(sp)
    80005562:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005564:	e3840593          	addi	a1,s0,-456
    80005568:	4505                	li	a0,1
    8000556a:	fb6fd0ef          	jal	ra,80002d20 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000556e:	08000613          	li	a2,128
    80005572:	f4040593          	addi	a1,s0,-192
    80005576:	4501                	li	a0,0
    80005578:	fc4fd0ef          	jal	ra,80002d3c <argstr>
    8000557c:	87aa                	mv	a5,a0
    return -1;
    8000557e:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005580:	0a07c463          	bltz	a5,80005628 <sys_exec+0xd6>
  }
  memset(argv, 0, sizeof(argv));
    80005584:	10000613          	li	a2,256
    80005588:	4581                	li	a1,0
    8000558a:	e4040513          	addi	a0,s0,-448
    8000558e:	eb2fb0ef          	jal	ra,80000c40 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005592:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005596:	89a6                	mv	s3,s1
    80005598:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000559a:	02000a13          	li	s4,32
    8000559e:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800055a2:	00391793          	slli	a5,s2,0x3
    800055a6:	e3040593          	addi	a1,s0,-464
    800055aa:	e3843503          	ld	a0,-456(s0)
    800055ae:	953e                	add	a0,a0,a5
    800055b0:	ecafd0ef          	jal	ra,80002c7a <fetchaddr>
    800055b4:	02054663          	bltz	a0,800055e0 <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    800055b8:	e3043783          	ld	a5,-464(s0)
    800055bc:	cf8d                	beqz	a5,800055f6 <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800055be:	cdefb0ef          	jal	ra,80000a9c <kalloc>
    800055c2:	85aa                	mv	a1,a0
    800055c4:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800055c8:	cd01                	beqz	a0,800055e0 <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800055ca:	6605                	lui	a2,0x1
    800055cc:	e3043503          	ld	a0,-464(s0)
    800055d0:	ef4fd0ef          	jal	ra,80002cc4 <fetchstr>
    800055d4:	00054663          	bltz	a0,800055e0 <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    800055d8:	0905                	addi	s2,s2,1
    800055da:	09a1                	addi	s3,s3,8
    800055dc:	fd4911e3          	bne	s2,s4,8000559e <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055e0:	10048913          	addi	s2,s1,256
    800055e4:	6088                	ld	a0,0(s1)
    800055e6:	c121                	beqz	a0,80005626 <sys_exec+0xd4>
    kfree(argv[i]);
    800055e8:	bd4fb0ef          	jal	ra,800009bc <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055ec:	04a1                	addi	s1,s1,8
    800055ee:	ff249be3          	bne	s1,s2,800055e4 <sys_exec+0x92>
  return -1;
    800055f2:	557d                	li	a0,-1
    800055f4:	a815                	j	80005628 <sys_exec+0xd6>
      argv[i] = 0;
    800055f6:	0a8e                	slli	s5,s5,0x3
    800055f8:	fc040793          	addi	a5,s0,-64
    800055fc:	9abe                	add	s5,s5,a5
    800055fe:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    80005602:	e4040593          	addi	a1,s0,-448
    80005606:	f4040513          	addi	a0,s0,-192
    8000560a:	c60ff0ef          	jal	ra,80004a6a <kexec>
    8000560e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005610:	10048993          	addi	s3,s1,256
    80005614:	6088                	ld	a0,0(s1)
    80005616:	c511                	beqz	a0,80005622 <sys_exec+0xd0>
    kfree(argv[i]);
    80005618:	ba4fb0ef          	jal	ra,800009bc <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000561c:	04a1                	addi	s1,s1,8
    8000561e:	ff349be3          	bne	s1,s3,80005614 <sys_exec+0xc2>
  return ret;
    80005622:	854a                	mv	a0,s2
    80005624:	a011                	j	80005628 <sys_exec+0xd6>
  return -1;
    80005626:	557d                	li	a0,-1
}
    80005628:	60be                	ld	ra,456(sp)
    8000562a:	641e                	ld	s0,448(sp)
    8000562c:	74fa                	ld	s1,440(sp)
    8000562e:	795a                	ld	s2,432(sp)
    80005630:	79ba                	ld	s3,424(sp)
    80005632:	7a1a                	ld	s4,416(sp)
    80005634:	6afa                	ld	s5,408(sp)
    80005636:	6179                	addi	sp,sp,464
    80005638:	8082                	ret

000000008000563a <sys_pipe>:

uint64
sys_pipe(void)
{
    8000563a:	7139                	addi	sp,sp,-64
    8000563c:	fc06                	sd	ra,56(sp)
    8000563e:	f822                	sd	s0,48(sp)
    80005640:	f426                	sd	s1,40(sp)
    80005642:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005644:	f96fc0ef          	jal	ra,80001dda <myproc>
    80005648:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000564a:	fd840593          	addi	a1,s0,-40
    8000564e:	4501                	li	a0,0
    80005650:	ed0fd0ef          	jal	ra,80002d20 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005654:	fc840593          	addi	a1,s0,-56
    80005658:	fd040513          	addi	a0,s0,-48
    8000565c:	938ff0ef          	jal	ra,80004794 <pipealloc>
    return -1;
    80005660:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005662:	0a054463          	bltz	a0,8000570a <sys_pipe+0xd0>
  fd0 = -1;
    80005666:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000566a:	fd043503          	ld	a0,-48(s0)
    8000566e:	f42ff0ef          	jal	ra,80004db0 <fdalloc>
    80005672:	fca42223          	sw	a0,-60(s0)
    80005676:	08054163          	bltz	a0,800056f8 <sys_pipe+0xbe>
    8000567a:	fc843503          	ld	a0,-56(s0)
    8000567e:	f32ff0ef          	jal	ra,80004db0 <fdalloc>
    80005682:	fca42023          	sw	a0,-64(s0)
    80005686:	06054063          	bltz	a0,800056e6 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000568a:	4691                	li	a3,4
    8000568c:	fc440613          	addi	a2,s0,-60
    80005690:	fd843583          	ld	a1,-40(s0)
    80005694:	68a8                	ld	a0,80(s1)
    80005696:	c92fc0ef          	jal	ra,80001b28 <copyout>
    8000569a:	00054e63          	bltz	a0,800056b6 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000569e:	4691                	li	a3,4
    800056a0:	fc040613          	addi	a2,s0,-64
    800056a4:	fd843583          	ld	a1,-40(s0)
    800056a8:	0591                	addi	a1,a1,4
    800056aa:	68a8                	ld	a0,80(s1)
    800056ac:	c7cfc0ef          	jal	ra,80001b28 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800056b0:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800056b2:	04055c63          	bgez	a0,8000570a <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800056b6:	fc442783          	lw	a5,-60(s0)
    800056ba:	07e9                	addi	a5,a5,26
    800056bc:	078e                	slli	a5,a5,0x3
    800056be:	97a6                	add	a5,a5,s1
    800056c0:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800056c4:	fc042503          	lw	a0,-64(s0)
    800056c8:	0569                	addi	a0,a0,26
    800056ca:	050e                	slli	a0,a0,0x3
    800056cc:	94aa                	add	s1,s1,a0
    800056ce:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800056d2:	fd043503          	ld	a0,-48(s0)
    800056d6:	df3fe0ef          	jal	ra,800044c8 <fileclose>
    fileclose(wf);
    800056da:	fc843503          	ld	a0,-56(s0)
    800056de:	debfe0ef          	jal	ra,800044c8 <fileclose>
    return -1;
    800056e2:	57fd                	li	a5,-1
    800056e4:	a01d                	j	8000570a <sys_pipe+0xd0>
    if(fd0 >= 0)
    800056e6:	fc442783          	lw	a5,-60(s0)
    800056ea:	0007c763          	bltz	a5,800056f8 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800056ee:	07e9                	addi	a5,a5,26
    800056f0:	078e                	slli	a5,a5,0x3
    800056f2:	94be                	add	s1,s1,a5
    800056f4:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800056f8:	fd043503          	ld	a0,-48(s0)
    800056fc:	dcdfe0ef          	jal	ra,800044c8 <fileclose>
    fileclose(wf);
    80005700:	fc843503          	ld	a0,-56(s0)
    80005704:	dc5fe0ef          	jal	ra,800044c8 <fileclose>
    return -1;
    80005708:	57fd                	li	a5,-1
}
    8000570a:	853e                	mv	a0,a5
    8000570c:	70e2                	ld	ra,56(sp)
    8000570e:	7442                	ld	s0,48(sp)
    80005710:	74a2                	ld	s1,40(sp)
    80005712:	6121                	addi	sp,sp,64
    80005714:	8082                	ret
	...

0000000080005720 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005720:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005722:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005724:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005726:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005728:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000572a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000572c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000572e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005730:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005732:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005734:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005736:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005738:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000573a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000573c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000573e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005740:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005742:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005744:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005746:	c44fd0ef          	jal	ra,80002b8a <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000574a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000574c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000574e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005750:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005752:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005754:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005756:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005758:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000575a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000575c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000575e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005760:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005762:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005764:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005766:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005768:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000576a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000576c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000576e:	10200073          	sret
	...

000000008000577e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000577e:	1141                	addi	sp,sp,-16
    80005780:	e422                	sd	s0,8(sp)
    80005782:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005784:	0c0007b7          	lui	a5,0xc000
    80005788:	4705                	li	a4,1
    8000578a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000578c:	c3d8                	sw	a4,4(a5)
}
    8000578e:	6422                	ld	s0,8(sp)
    80005790:	0141                	addi	sp,sp,16
    80005792:	8082                	ret

0000000080005794 <plicinithart>:

void
plicinithart(void)
{
    80005794:	1141                	addi	sp,sp,-16
    80005796:	e406                	sd	ra,8(sp)
    80005798:	e022                	sd	s0,0(sp)
    8000579a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000579c:	e12fc0ef          	jal	ra,80001dae <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800057a0:	0085171b          	slliw	a4,a0,0x8
    800057a4:	0c0027b7          	lui	a5,0xc002
    800057a8:	97ba                	add	a5,a5,a4
    800057aa:	40200713          	li	a4,1026
    800057ae:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800057b2:	00d5151b          	slliw	a0,a0,0xd
    800057b6:	0c2017b7          	lui	a5,0xc201
    800057ba:	953e                	add	a0,a0,a5
    800057bc:	00052023          	sw	zero,0(a0)
}
    800057c0:	60a2                	ld	ra,8(sp)
    800057c2:	6402                	ld	s0,0(sp)
    800057c4:	0141                	addi	sp,sp,16
    800057c6:	8082                	ret

00000000800057c8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800057c8:	1141                	addi	sp,sp,-16
    800057ca:	e406                	sd	ra,8(sp)
    800057cc:	e022                	sd	s0,0(sp)
    800057ce:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800057d0:	ddefc0ef          	jal	ra,80001dae <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800057d4:	00d5179b          	slliw	a5,a0,0xd
    800057d8:	0c201537          	lui	a0,0xc201
    800057dc:	953e                	add	a0,a0,a5
  return irq;
}
    800057de:	4148                	lw	a0,4(a0)
    800057e0:	60a2                	ld	ra,8(sp)
    800057e2:	6402                	ld	s0,0(sp)
    800057e4:	0141                	addi	sp,sp,16
    800057e6:	8082                	ret

00000000800057e8 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800057e8:	1101                	addi	sp,sp,-32
    800057ea:	ec06                	sd	ra,24(sp)
    800057ec:	e822                	sd	s0,16(sp)
    800057ee:	e426                	sd	s1,8(sp)
    800057f0:	1000                	addi	s0,sp,32
    800057f2:	84aa                	mv	s1,a0
  int hart = cpuid();
    800057f4:	dbafc0ef          	jal	ra,80001dae <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800057f8:	00d5151b          	slliw	a0,a0,0xd
    800057fc:	0c2017b7          	lui	a5,0xc201
    80005800:	97aa                	add	a5,a5,a0
    80005802:	c3c4                	sw	s1,4(a5)
}
    80005804:	60e2                	ld	ra,24(sp)
    80005806:	6442                	ld	s0,16(sp)
    80005808:	64a2                	ld	s1,8(sp)
    8000580a:	6105                	addi	sp,sp,32
    8000580c:	8082                	ret

000000008000580e <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000580e:	1141                	addi	sp,sp,-16
    80005810:	e406                	sd	ra,8(sp)
    80005812:	e022                	sd	s0,0(sp)
    80005814:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005816:	479d                	li	a5,7
    80005818:	04a7ca63          	blt	a5,a0,8000586c <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    8000581c:	0002d797          	auipc	a5,0x2d
    80005820:	d7c78793          	addi	a5,a5,-644 # 80032598 <disk>
    80005824:	97aa                	add	a5,a5,a0
    80005826:	0187c783          	lbu	a5,24(a5)
    8000582a:	e7b9                	bnez	a5,80005878 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000582c:	00451613          	slli	a2,a0,0x4
    80005830:	0002d797          	auipc	a5,0x2d
    80005834:	d6878793          	addi	a5,a5,-664 # 80032598 <disk>
    80005838:	6394                	ld	a3,0(a5)
    8000583a:	96b2                	add	a3,a3,a2
    8000583c:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005840:	6398                	ld	a4,0(a5)
    80005842:	9732                	add	a4,a4,a2
    80005844:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005848:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    8000584c:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005850:	953e                	add	a0,a0,a5
    80005852:	4785                	li	a5,1
    80005854:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005858:	0002d517          	auipc	a0,0x2d
    8000585c:	d5850513          	addi	a0,a0,-680 # 800325b0 <disk+0x18>
    80005860:	be9fc0ef          	jal	ra,80002448 <wakeup>
}
    80005864:	60a2                	ld	ra,8(sp)
    80005866:	6402                	ld	s0,0(sp)
    80005868:	0141                	addi	sp,sp,16
    8000586a:	8082                	ret
    panic("free_desc 1");
    8000586c:	00002517          	auipc	a0,0x2
    80005870:	21c50513          	addi	a0,a0,540 # 80007a88 <syscalls+0x400>
    80005874:	f17fa0ef          	jal	ra,8000078a <panic>
    panic("free_desc 2");
    80005878:	00002517          	auipc	a0,0x2
    8000587c:	22050513          	addi	a0,a0,544 # 80007a98 <syscalls+0x410>
    80005880:	f0bfa0ef          	jal	ra,8000078a <panic>

0000000080005884 <virtio_disk_init>:
{
    80005884:	1101                	addi	sp,sp,-32
    80005886:	ec06                	sd	ra,24(sp)
    80005888:	e822                	sd	s0,16(sp)
    8000588a:	e426                	sd	s1,8(sp)
    8000588c:	e04a                	sd	s2,0(sp)
    8000588e:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005890:	00002597          	auipc	a1,0x2
    80005894:	21858593          	addi	a1,a1,536 # 80007aa8 <syscalls+0x420>
    80005898:	0002d517          	auipc	a0,0x2d
    8000589c:	e2850513          	addi	a0,a0,-472 # 800326c0 <disk+0x128>
    800058a0:	a4cfb0ef          	jal	ra,80000aec <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800058a4:	100017b7          	lui	a5,0x10001
    800058a8:	4398                	lw	a4,0(a5)
    800058aa:	2701                	sext.w	a4,a4
    800058ac:	747277b7          	lui	a5,0x74727
    800058b0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800058b4:	14f71063          	bne	a4,a5,800059f4 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800058b8:	100017b7          	lui	a5,0x10001
    800058bc:	43dc                	lw	a5,4(a5)
    800058be:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800058c0:	4709                	li	a4,2
    800058c2:	12e79963          	bne	a5,a4,800059f4 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800058c6:	100017b7          	lui	a5,0x10001
    800058ca:	479c                	lw	a5,8(a5)
    800058cc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800058ce:	12e79363          	bne	a5,a4,800059f4 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800058d2:	100017b7          	lui	a5,0x10001
    800058d6:	47d8                	lw	a4,12(a5)
    800058d8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800058da:	554d47b7          	lui	a5,0x554d4
    800058de:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800058e2:	10f71963          	bne	a4,a5,800059f4 <virtio_disk_init+0x170>
  *R(VIRTIO_MMIO_STATUS) = status;
    800058e6:	100017b7          	lui	a5,0x10001
    800058ea:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800058ee:	4705                	li	a4,1
    800058f0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800058f2:	470d                	li	a4,3
    800058f4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800058f6:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800058f8:	c7ffe737          	lui	a4,0xc7ffe
    800058fc:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fcc087>
    80005900:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005902:	2701                	sext.w	a4,a4
    80005904:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005906:	472d                	li	a4,11
    80005908:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    8000590a:	5bbc                	lw	a5,112(a5)
    8000590c:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005910:	8ba1                	andi	a5,a5,8
    80005912:	0e078763          	beqz	a5,80005a00 <virtio_disk_init+0x17c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005916:	100017b7          	lui	a5,0x10001
    8000591a:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000591e:	43fc                	lw	a5,68(a5)
    80005920:	2781                	sext.w	a5,a5
    80005922:	0e079563          	bnez	a5,80005a0c <virtio_disk_init+0x188>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005926:	100017b7          	lui	a5,0x10001
    8000592a:	5bdc                	lw	a5,52(a5)
    8000592c:	2781                	sext.w	a5,a5
  if(max == 0)
    8000592e:	0e078563          	beqz	a5,80005a18 <virtio_disk_init+0x194>
  if(max < NUM)
    80005932:	471d                	li	a4,7
    80005934:	0ef77863          	bgeu	a4,a5,80005a24 <virtio_disk_init+0x1a0>
  disk.desc = kalloc();
    80005938:	964fb0ef          	jal	ra,80000a9c <kalloc>
    8000593c:	0002d497          	auipc	s1,0x2d
    80005940:	c5c48493          	addi	s1,s1,-932 # 80032598 <disk>
    80005944:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005946:	956fb0ef          	jal	ra,80000a9c <kalloc>
    8000594a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000594c:	950fb0ef          	jal	ra,80000a9c <kalloc>
    80005950:	87aa                	mv	a5,a0
    80005952:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005954:	6088                	ld	a0,0(s1)
    80005956:	cd69                	beqz	a0,80005a30 <virtio_disk_init+0x1ac>
    80005958:	0002d717          	auipc	a4,0x2d
    8000595c:	c4873703          	ld	a4,-952(a4) # 800325a0 <disk+0x8>
    80005960:	cb61                	beqz	a4,80005a30 <virtio_disk_init+0x1ac>
    80005962:	c7f9                	beqz	a5,80005a30 <virtio_disk_init+0x1ac>
  memset(disk.desc, 0, PGSIZE);
    80005964:	6605                	lui	a2,0x1
    80005966:	4581                	li	a1,0
    80005968:	ad8fb0ef          	jal	ra,80000c40 <memset>
  memset(disk.avail, 0, PGSIZE);
    8000596c:	0002d497          	auipc	s1,0x2d
    80005970:	c2c48493          	addi	s1,s1,-980 # 80032598 <disk>
    80005974:	6605                	lui	a2,0x1
    80005976:	4581                	li	a1,0
    80005978:	6488                	ld	a0,8(s1)
    8000597a:	ac6fb0ef          	jal	ra,80000c40 <memset>
  memset(disk.used, 0, PGSIZE);
    8000597e:	6605                	lui	a2,0x1
    80005980:	4581                	li	a1,0
    80005982:	6888                	ld	a0,16(s1)
    80005984:	abcfb0ef          	jal	ra,80000c40 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005988:	100017b7          	lui	a5,0x10001
    8000598c:	4721                	li	a4,8
    8000598e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005990:	4098                	lw	a4,0(s1)
    80005992:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005996:	40d8                	lw	a4,4(s1)
    80005998:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000599c:	6498                	ld	a4,8(s1)
    8000599e:	0007069b          	sext.w	a3,a4
    800059a2:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800059a6:	9701                	srai	a4,a4,0x20
    800059a8:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800059ac:	6898                	ld	a4,16(s1)
    800059ae:	0007069b          	sext.w	a3,a4
    800059b2:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800059b6:	9701                	srai	a4,a4,0x20
    800059b8:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800059bc:	4705                	li	a4,1
    800059be:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800059c0:	00e48c23          	sb	a4,24(s1)
    800059c4:	00e48ca3          	sb	a4,25(s1)
    800059c8:	00e48d23          	sb	a4,26(s1)
    800059cc:	00e48da3          	sb	a4,27(s1)
    800059d0:	00e48e23          	sb	a4,28(s1)
    800059d4:	00e48ea3          	sb	a4,29(s1)
    800059d8:	00e48f23          	sb	a4,30(s1)
    800059dc:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800059e0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800059e4:	0727a823          	sw	s2,112(a5)
}
    800059e8:	60e2                	ld	ra,24(sp)
    800059ea:	6442                	ld	s0,16(sp)
    800059ec:	64a2                	ld	s1,8(sp)
    800059ee:	6902                	ld	s2,0(sp)
    800059f0:	6105                	addi	sp,sp,32
    800059f2:	8082                	ret
    panic("could not find virtio disk");
    800059f4:	00002517          	auipc	a0,0x2
    800059f8:	0c450513          	addi	a0,a0,196 # 80007ab8 <syscalls+0x430>
    800059fc:	d8ffa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk FEATURES_OK unset");
    80005a00:	00002517          	auipc	a0,0x2
    80005a04:	0d850513          	addi	a0,a0,216 # 80007ad8 <syscalls+0x450>
    80005a08:	d83fa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk should not be ready");
    80005a0c:	00002517          	auipc	a0,0x2
    80005a10:	0ec50513          	addi	a0,a0,236 # 80007af8 <syscalls+0x470>
    80005a14:	d77fa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk has no queue 0");
    80005a18:	00002517          	auipc	a0,0x2
    80005a1c:	10050513          	addi	a0,a0,256 # 80007b18 <syscalls+0x490>
    80005a20:	d6bfa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk max queue too short");
    80005a24:	00002517          	auipc	a0,0x2
    80005a28:	11450513          	addi	a0,a0,276 # 80007b38 <syscalls+0x4b0>
    80005a2c:	d5ffa0ef          	jal	ra,8000078a <panic>
    panic("virtio disk kalloc");
    80005a30:	00002517          	auipc	a0,0x2
    80005a34:	12850513          	addi	a0,a0,296 # 80007b58 <syscalls+0x4d0>
    80005a38:	d53fa0ef          	jal	ra,8000078a <panic>

0000000080005a3c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005a3c:	7119                	addi	sp,sp,-128
    80005a3e:	fc86                	sd	ra,120(sp)
    80005a40:	f8a2                	sd	s0,112(sp)
    80005a42:	f4a6                	sd	s1,104(sp)
    80005a44:	f0ca                	sd	s2,96(sp)
    80005a46:	ecce                	sd	s3,88(sp)
    80005a48:	e8d2                	sd	s4,80(sp)
    80005a4a:	e4d6                	sd	s5,72(sp)
    80005a4c:	e0da                	sd	s6,64(sp)
    80005a4e:	fc5e                	sd	s7,56(sp)
    80005a50:	f862                	sd	s8,48(sp)
    80005a52:	f466                	sd	s9,40(sp)
    80005a54:	f06a                	sd	s10,32(sp)
    80005a56:	ec6e                	sd	s11,24(sp)
    80005a58:	0100                	addi	s0,sp,128
    80005a5a:	8aaa                	mv	s5,a0
    80005a5c:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005a5e:	00c52d03          	lw	s10,12(a0)
    80005a62:	001d1d1b          	slliw	s10,s10,0x1
    80005a66:	1d02                	slli	s10,s10,0x20
    80005a68:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80005a6c:	0002d517          	auipc	a0,0x2d
    80005a70:	c5450513          	addi	a0,a0,-940 # 800326c0 <disk+0x128>
    80005a74:	8f8fb0ef          	jal	ra,80000b6c <acquire>
  for(int i = 0; i < 3; i++){
    80005a78:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005a7a:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005a7c:	0002db97          	auipc	s7,0x2d
    80005a80:	b1cb8b93          	addi	s7,s7,-1252 # 80032598 <disk>
  for(int i = 0; i < 3; i++){
    80005a84:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005a86:	0002dc97          	auipc	s9,0x2d
    80005a8a:	c3ac8c93          	addi	s9,s9,-966 # 800326c0 <disk+0x128>
    80005a8e:	a8a9                	j	80005ae8 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005a90:	00fb8733          	add	a4,s7,a5
    80005a94:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005a98:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005a9a:	0207c563          	bltz	a5,80005ac4 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005a9e:	2905                	addiw	s2,s2,1
    80005aa0:	0611                	addi	a2,a2,4
    80005aa2:	05690863          	beq	s2,s6,80005af2 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80005aa6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005aa8:	0002d717          	auipc	a4,0x2d
    80005aac:	af070713          	addi	a4,a4,-1296 # 80032598 <disk>
    80005ab0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005ab2:	01874683          	lbu	a3,24(a4)
    80005ab6:	fee9                	bnez	a3,80005a90 <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80005ab8:	2785                	addiw	a5,a5,1
    80005aba:	0705                	addi	a4,a4,1
    80005abc:	fe979be3          	bne	a5,s1,80005ab2 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005ac0:	57fd                	li	a5,-1
    80005ac2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005ac4:	01205b63          	blez	s2,80005ada <virtio_disk_rw+0x9e>
    80005ac8:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80005aca:	000a2503          	lw	a0,0(s4)
    80005ace:	d41ff0ef          	jal	ra,8000580e <free_desc>
      for(int j = 0; j < i; j++)
    80005ad2:	2d85                	addiw	s11,s11,1
    80005ad4:	0a11                	addi	s4,s4,4
    80005ad6:	ffb91ae3          	bne	s2,s11,80005aca <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005ada:	85e6                	mv	a1,s9
    80005adc:	0002d517          	auipc	a0,0x2d
    80005ae0:	ad450513          	addi	a0,a0,-1324 # 800325b0 <disk+0x18>
    80005ae4:	919fc0ef          	jal	ra,800023fc <sleep>
  for(int i = 0; i < 3; i++){
    80005ae8:	f8040a13          	addi	s4,s0,-128
{
    80005aec:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80005aee:	894e                	mv	s2,s3
    80005af0:	bf5d                	j	80005aa6 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005af2:	f8042583          	lw	a1,-128(s0)
    80005af6:	00a58793          	addi	a5,a1,10
    80005afa:	0792                	slli	a5,a5,0x4

  if(write)
    80005afc:	0002d617          	auipc	a2,0x2d
    80005b00:	a9c60613          	addi	a2,a2,-1380 # 80032598 <disk>
    80005b04:	00f60733          	add	a4,a2,a5
    80005b08:	018036b3          	snez	a3,s8
    80005b0c:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005b0e:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005b12:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005b16:	f6078693          	addi	a3,a5,-160
    80005b1a:	6218                	ld	a4,0(a2)
    80005b1c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b1e:	00878513          	addi	a0,a5,8
    80005b22:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005b24:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005b26:	6208                	ld	a0,0(a2)
    80005b28:	96aa                	add	a3,a3,a0
    80005b2a:	4741                	li	a4,16
    80005b2c:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005b2e:	4705                	li	a4,1
    80005b30:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80005b34:	f8442703          	lw	a4,-124(s0)
    80005b38:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005b3c:	0712                	slli	a4,a4,0x4
    80005b3e:	953a                	add	a0,a0,a4
    80005b40:	058a8693          	addi	a3,s5,88
    80005b44:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    80005b46:	6208                	ld	a0,0(a2)
    80005b48:	972a                	add	a4,a4,a0
    80005b4a:	40000693          	li	a3,1024
    80005b4e:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80005b50:	001c3c13          	seqz	s8,s8
    80005b54:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005b56:	001c6c13          	ori	s8,s8,1
    80005b5a:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005b5e:	f8842603          	lw	a2,-120(s0)
    80005b62:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005b66:	0002d697          	auipc	a3,0x2d
    80005b6a:	a3268693          	addi	a3,a3,-1486 # 80032598 <disk>
    80005b6e:	00258713          	addi	a4,a1,2
    80005b72:	0712                	slli	a4,a4,0x4
    80005b74:	9736                	add	a4,a4,a3
    80005b76:	587d                	li	a6,-1
    80005b78:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005b7c:	0612                	slli	a2,a2,0x4
    80005b7e:	9532                	add	a0,a0,a2
    80005b80:	f9078793          	addi	a5,a5,-112
    80005b84:	97b6                	add	a5,a5,a3
    80005b86:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    80005b88:	629c                	ld	a5,0(a3)
    80005b8a:	97b2                	add	a5,a5,a2
    80005b8c:	4605                	li	a2,1
    80005b8e:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005b90:	4509                	li	a0,2
    80005b92:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    80005b96:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005b9a:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80005b9e:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005ba2:	6698                	ld	a4,8(a3)
    80005ba4:	00275783          	lhu	a5,2(a4)
    80005ba8:	8b9d                	andi	a5,a5,7
    80005baa:	0786                	slli	a5,a5,0x1
    80005bac:	97ba                	add	a5,a5,a4
    80005bae:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80005bb2:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005bb6:	6698                	ld	a4,8(a3)
    80005bb8:	00275783          	lhu	a5,2(a4)
    80005bbc:	2785                	addiw	a5,a5,1
    80005bbe:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005bc2:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005bc6:	100017b7          	lui	a5,0x10001
    80005bca:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005bce:	004aa783          	lw	a5,4(s5)
    80005bd2:	00c79f63          	bne	a5,a2,80005bf0 <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    80005bd6:	0002d917          	auipc	s2,0x2d
    80005bda:	aea90913          	addi	s2,s2,-1302 # 800326c0 <disk+0x128>
  while(b->disk == 1) {
    80005bde:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80005be0:	85ca                	mv	a1,s2
    80005be2:	8556                	mv	a0,s5
    80005be4:	819fc0ef          	jal	ra,800023fc <sleep>
  while(b->disk == 1) {
    80005be8:	004aa783          	lw	a5,4(s5)
    80005bec:	fe978ae3          	beq	a5,s1,80005be0 <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    80005bf0:	f8042903          	lw	s2,-128(s0)
    80005bf4:	00290793          	addi	a5,s2,2
    80005bf8:	00479713          	slli	a4,a5,0x4
    80005bfc:	0002d797          	auipc	a5,0x2d
    80005c00:	99c78793          	addi	a5,a5,-1636 # 80032598 <disk>
    80005c04:	97ba                	add	a5,a5,a4
    80005c06:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005c0a:	0002d997          	auipc	s3,0x2d
    80005c0e:	98e98993          	addi	s3,s3,-1650 # 80032598 <disk>
    80005c12:	00491713          	slli	a4,s2,0x4
    80005c16:	0009b783          	ld	a5,0(s3)
    80005c1a:	97ba                	add	a5,a5,a4
    80005c1c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005c20:	854a                	mv	a0,s2
    80005c22:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005c26:	be9ff0ef          	jal	ra,8000580e <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005c2a:	8885                	andi	s1,s1,1
    80005c2c:	f0fd                	bnez	s1,80005c12 <virtio_disk_rw+0x1d6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005c2e:	0002d517          	auipc	a0,0x2d
    80005c32:	a9250513          	addi	a0,a0,-1390 # 800326c0 <disk+0x128>
    80005c36:	fcffa0ef          	jal	ra,80000c04 <release>
}
    80005c3a:	70e6                	ld	ra,120(sp)
    80005c3c:	7446                	ld	s0,112(sp)
    80005c3e:	74a6                	ld	s1,104(sp)
    80005c40:	7906                	ld	s2,96(sp)
    80005c42:	69e6                	ld	s3,88(sp)
    80005c44:	6a46                	ld	s4,80(sp)
    80005c46:	6aa6                	ld	s5,72(sp)
    80005c48:	6b06                	ld	s6,64(sp)
    80005c4a:	7be2                	ld	s7,56(sp)
    80005c4c:	7c42                	ld	s8,48(sp)
    80005c4e:	7ca2                	ld	s9,40(sp)
    80005c50:	7d02                	ld	s10,32(sp)
    80005c52:	6de2                	ld	s11,24(sp)
    80005c54:	6109                	addi	sp,sp,128
    80005c56:	8082                	ret

0000000080005c58 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005c58:	1101                	addi	sp,sp,-32
    80005c5a:	ec06                	sd	ra,24(sp)
    80005c5c:	e822                	sd	s0,16(sp)
    80005c5e:	e426                	sd	s1,8(sp)
    80005c60:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005c62:	0002d497          	auipc	s1,0x2d
    80005c66:	93648493          	addi	s1,s1,-1738 # 80032598 <disk>
    80005c6a:	0002d517          	auipc	a0,0x2d
    80005c6e:	a5650513          	addi	a0,a0,-1450 # 800326c0 <disk+0x128>
    80005c72:	efbfa0ef          	jal	ra,80000b6c <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005c76:	10001737          	lui	a4,0x10001
    80005c7a:	533c                	lw	a5,96(a4)
    80005c7c:	8b8d                	andi	a5,a5,3
    80005c7e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005c80:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005c84:	689c                	ld	a5,16(s1)
    80005c86:	0204d703          	lhu	a4,32(s1)
    80005c8a:	0027d783          	lhu	a5,2(a5)
    80005c8e:	04f70663          	beq	a4,a5,80005cda <virtio_disk_intr+0x82>
    __sync_synchronize();
    80005c92:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005c96:	6898                	ld	a4,16(s1)
    80005c98:	0204d783          	lhu	a5,32(s1)
    80005c9c:	8b9d                	andi	a5,a5,7
    80005c9e:	078e                	slli	a5,a5,0x3
    80005ca0:	97ba                	add	a5,a5,a4
    80005ca2:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005ca4:	00278713          	addi	a4,a5,2
    80005ca8:	0712                	slli	a4,a4,0x4
    80005caa:	9726                	add	a4,a4,s1
    80005cac:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005cb0:	e321                	bnez	a4,80005cf0 <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005cb2:	0789                	addi	a5,a5,2
    80005cb4:	0792                	slli	a5,a5,0x4
    80005cb6:	97a6                	add	a5,a5,s1
    80005cb8:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005cba:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005cbe:	f8afc0ef          	jal	ra,80002448 <wakeup>

    disk.used_idx += 1;
    80005cc2:	0204d783          	lhu	a5,32(s1)
    80005cc6:	2785                	addiw	a5,a5,1
    80005cc8:	17c2                	slli	a5,a5,0x30
    80005cca:	93c1                	srli	a5,a5,0x30
    80005ccc:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005cd0:	6898                	ld	a4,16(s1)
    80005cd2:	00275703          	lhu	a4,2(a4)
    80005cd6:	faf71ee3          	bne	a4,a5,80005c92 <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    80005cda:	0002d517          	auipc	a0,0x2d
    80005cde:	9e650513          	addi	a0,a0,-1562 # 800326c0 <disk+0x128>
    80005ce2:	f23fa0ef          	jal	ra,80000c04 <release>
}
    80005ce6:	60e2                	ld	ra,24(sp)
    80005ce8:	6442                	ld	s0,16(sp)
    80005cea:	64a2                	ld	s1,8(sp)
    80005cec:	6105                	addi	sp,sp,32
    80005cee:	8082                	ret
      panic("virtio_disk_intr status");
    80005cf0:	00002517          	auipc	a0,0x2
    80005cf4:	e8050513          	addi	a0,a0,-384 # 80007b70 <syscalls+0x4e8>
    80005cf8:	a93fa0ef          	jal	ra,8000078a <panic>
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
