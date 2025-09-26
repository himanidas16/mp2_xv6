
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
    80000004:	86010113          	addi	sp,sp,-1952 # 80007860 <stack0>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffddc97>
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
    8000010a:	096020ef          	jal	ra,800021a0 <either_copyin>
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
    80000172:	0000f517          	auipc	a0,0xf
    80000176:	6ee50513          	addi	a0,a0,1774 # 8000f860 <cons>
    8000017a:	1f3000ef          	jal	ra,80000b6c <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000017e:	0000f497          	auipc	s1,0xf
    80000182:	6e248493          	addi	s1,s1,1762 # 8000f860 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000186:	0000f917          	auipc	s2,0xf
    8000018a:	77290913          	addi	s2,s2,1906 # 8000f8f8 <cons+0x98>
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
    800001a4:	660010ef          	jal	ra,80001804 <myproc>
    800001a8:	68b010ef          	jal	ra,80002032 <killed>
    800001ac:	e125                	bnez	a0,8000020c <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800001ae:	85a6                	mv	a1,s1
    800001b0:	854a                	mv	a0,s2
    800001b2:	449010ef          	jal	ra,80001dfa <sleep>
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
    800001ea:	76d010ef          	jal	ra,80002156 <either_copyout>
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
    800001fa:	0000f517          	auipc	a0,0xf
    800001fe:	66650513          	addi	a0,a0,1638 # 8000f860 <cons>
    80000202:	203000ef          	jal	ra,80000c04 <release>

  return target - n;
    80000206:	413b053b          	subw	a0,s6,s3
    8000020a:	a801                	j	8000021a <consoleread+0xce>
        release(&cons.lock);
    8000020c:	0000f517          	auipc	a0,0xf
    80000210:	65450513          	addi	a0,a0,1620 # 8000f860 <cons>
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
    8000023e:	0000f717          	auipc	a4,0xf
    80000242:	6af72d23          	sw	a5,1722(a4) # 8000f8f8 <cons+0x98>
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
    80000288:	0000f517          	auipc	a0,0xf
    8000028c:	5d850513          	addi	a0,a0,1496 # 8000f860 <cons>
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
    800002aa:	741010ef          	jal	ra,800021ea <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ae:	0000f517          	auipc	a0,0xf
    800002b2:	5b250513          	addi	a0,a0,1458 # 8000f860 <cons>
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
    800002ce:	0000f717          	auipc	a4,0xf
    800002d2:	59270713          	addi	a4,a4,1426 # 8000f860 <cons>
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
    800002f4:	0000f797          	auipc	a5,0xf
    800002f8:	56c78793          	addi	a5,a5,1388 # 8000f860 <cons>
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
    80000322:	0000f797          	auipc	a5,0xf
    80000326:	5d67a783          	lw	a5,1494(a5) # 8000f8f8 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f6f71fe3          	bne	a4,a5,800002ae <consoleintr+0x34>
    80000334:	a04d                	j	800003d6 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80000336:	0000f717          	auipc	a4,0xf
    8000033a:	52a70713          	addi	a4,a4,1322 # 8000f860 <cons>
    8000033e:	0a072783          	lw	a5,160(a4)
    80000342:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000346:	0000f497          	auipc	s1,0xf
    8000034a:	51a48493          	addi	s1,s1,1306 # 8000f860 <cons>
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
    80000382:	4e270713          	addi	a4,a4,1250 # 8000f860 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f2f700e3          	beq	a4,a5,800002ae <consoleintr+0x34>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	0000f717          	auipc	a4,0xf
    80000398:	56f72623          	sw	a5,1388(a4) # 8000f900 <cons+0xa0>
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
    800003b6:	4ae78793          	addi	a5,a5,1198 # 8000f860 <cons>
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
    800003da:	52c7a323          	sw	a2,1318(a5) # 8000f8fc <cons+0x9c>
        wakeup(&cons.r);
    800003de:	0000f517          	auipc	a0,0xf
    800003e2:	51a50513          	addi	a0,a0,1306 # 8000f8f8 <cons+0x98>
    800003e6:	261010ef          	jal	ra,80001e46 <wakeup>
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
    80000400:	46450513          	addi	a0,a0,1124 # 8000f860 <cons>
    80000404:	6e8000ef          	jal	ra,80000aec <initlock>

  uartinit();
    80000408:	3e2000ef          	jal	ra,800007ea <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	0001f797          	auipc	a5,0x1f
    80000410:	5c478793          	addi	a5,a5,1476 # 8001f9d0 <devsw>
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
    800004fa:	33e7a783          	lw	a5,830(a5) # 80007834 <panicking>
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
    80000538:	3d450513          	addi	a0,a0,980 # 8000f908 <pr>
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
    80000756:	0e27a783          	lw	a5,226(a5) # 80007834 <panicking>
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
    80000780:	18c50513          	addi	a0,a0,396 # 8000f908 <pr>
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
    8000079e:	0927ad23          	sw	s2,154(a5) # 80007834 <panicking>
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
    800007c0:	0727aa23          	sw	s2,116(a5) # 80007830 <panicked>
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
    800007da:	13250513          	addi	a0,a0,306 # 8000f908 <pr>
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
    80000826:	0fe50513          	addi	a0,a0,254 # 8000f920 <tx_lock>
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
    80000854:	0d050513          	addi	a0,a0,208 # 8000f920 <tx_lock>
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
    80000872:	fce48493          	addi	s1,s1,-50 # 8000783c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000876:	0000f997          	auipc	s3,0xf
    8000087a:	0aa98993          	addi	s3,s3,170 # 8000f920 <tx_lock>
    8000087e:	00007917          	auipc	s2,0x7
    80000882:	fba90913          	addi	s2,s2,-70 # 80007838 <tx_chan>
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
    80000892:	568010ef          	jal	ra,80001dfa <sleep>
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
    800008b6:	06e50513          	addi	a0,a0,110 # 8000f920 <tx_lock>
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
    800008e4:	f547a783          	lw	a5,-172(a5) # 80007834 <panicking>
    800008e8:	cb89                	beqz	a5,800008fa <uartputc_sync+0x26>
    push_off();

  if(panicked){
    800008ea:	00007797          	auipc	a5,0x7
    800008ee:	f467a783          	lw	a5,-186(a5) # 80007830 <panicked>
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
    8000091a:	f1e7a783          	lw	a5,-226(a5) # 80007834 <panicking>
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
    8000096e:	fb650513          	addi	a0,a0,-74 # 8000f920 <tx_lock>
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
    80000984:	fa050513          	addi	a0,a0,-96 # 8000f920 <tx_lock>
    80000988:	27c000ef          	jal	ra,80000c04 <release>

  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000098c:	54fd                	li	s1,-1
    8000098e:	a831                	j	800009aa <uartintr+0x52>
    tx_busy = 0;
    80000990:	00007797          	auipc	a5,0x7
    80000994:	ea07a623          	sw	zero,-340(a5) # 8000783c <tx_busy>
    wakeup(&tx_chan);
    80000998:	00007517          	auipc	a0,0x7
    8000099c:	ea050513          	addi	a0,a0,-352 # 80007838 <tx_chan>
    800009a0:	4a6010ef          	jal	ra,80001e46 <wakeup>
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
    800009d0:	00020797          	auipc	a5,0x20
    800009d4:	19878793          	addi	a5,a5,408 # 80020b68 <end>
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
    800009f0:	f4c90913          	addi	s2,s2,-180 # 8000f938 <kmem>
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
    80000a7c:	ec050513          	addi	a0,a0,-320 # 8000f938 <kmem>
    80000a80:	06c000ef          	jal	ra,80000aec <initlock>
  freerange(end, (void*)PHYSTOP);
    80000a84:	45c5                	li	a1,17
    80000a86:	05ee                	slli	a1,a1,0x1b
    80000a88:	00020517          	auipc	a0,0x20
    80000a8c:	0e050513          	addi	a0,a0,224 # 80020b68 <end>
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
    80000aaa:	e9248493          	addi	s1,s1,-366 # 8000f938 <kmem>
    80000aae:	8526                	mv	a0,s1
    80000ab0:	0bc000ef          	jal	ra,80000b6c <acquire>
  r = kmem.freelist;
    80000ab4:	6c84                	ld	s1,24(s1)
  if(r)
    80000ab6:	c485                	beqz	s1,80000ade <kalloc+0x42>
    kmem.freelist = r->next;
    80000ab8:	609c                	ld	a5,0(s1)
    80000aba:	0000f517          	auipc	a0,0xf
    80000abe:	e7e50513          	addi	a0,a0,-386 # 8000f938 <kmem>
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
    80000ae2:	e5a50513          	addi	a0,a0,-422 # 8000f938 <kmem>
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
    80000b16:	4d3000ef          	jal	ra,800017e8 <mycpu>
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
    80000b44:	4a5000ef          	jal	ra,800017e8 <mycpu>
    80000b48:	5d3c                	lw	a5,120(a0)
    80000b4a:	cb99                	beqz	a5,80000b60 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b4c:	49d000ef          	jal	ra,800017e8 <mycpu>
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
    80000b60:	489000ef          	jal	ra,800017e8 <mycpu>
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
    80000b94:	455000ef          	jal	ra,800017e8 <mycpu>
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
    80000bb8:	431000ef          	jal	ra,800017e8 <mycpu>
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
    80000dea:	1ef000ef          	jal	ra,800017d8 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000dee:	00007717          	auipc	a4,0x7
    80000df2:	a5270713          	addi	a4,a4,-1454 # 80007840 <started>
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
    80000e02:	1d7000ef          	jal	ra,800017d8 <cpuid>
    80000e06:	85aa                	mv	a1,a0
    80000e08:	00006517          	auipc	a0,0x6
    80000e0c:	2a850513          	addi	a0,a0,680 # 800070b0 <digits+0x78>
    80000e10:	eb4ff0ef          	jal	ra,800004c4 <printf>
    kvminithart();    // turn on paging
    80000e14:	080000ef          	jal	ra,80000e94 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e18:	502010ef          	jal	ra,8000231a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e1c:	3c8040ef          	jal	ra,800051e4 <plicinithart>
  }

  scheduler();        
    80000e20:	643000ef          	jal	ra,80001c62 <scheduler>
    consoleinit();
    80000e24:	dc8ff0ef          	jal	ra,800003ec <consoleinit>
    printfinit();
    80000e28:	99fff0ef          	jal	ra,800007c6 <printfinit>
    printf("\n");
    80000e2c:	00006517          	auipc	a0,0x6
    80000e30:	29450513          	addi	a0,a0,660 # 800070c0 <digits+0x88>
    80000e34:	e90ff0ef          	jal	ra,800004c4 <printf>
    printf("xv6 kernel is booting\n");
    80000e38:	00006517          	auipc	a0,0x6
    80000e3c:	26050513          	addi	a0,a0,608 # 80007098 <digits+0x60>
    80000e40:	e84ff0ef          	jal	ra,800004c4 <printf>
    printf("\n");
    80000e44:	00006517          	auipc	a0,0x6
    80000e48:	27c50513          	addi	a0,a0,636 # 800070c0 <digits+0x88>
    80000e4c:	e78ff0ef          	jal	ra,800004c4 <printf>
    kinit();         // physical page allocator
    80000e50:	c19ff0ef          	jal	ra,80000a68 <kinit>
    kvminit();       // create kernel page table
    80000e54:	2ca000ef          	jal	ra,8000111e <kvminit>
    kvminithart();   // turn on paging
    80000e58:	03c000ef          	jal	ra,80000e94 <kvminithart>
    procinit();      // process table
    80000e5c:	0d5000ef          	jal	ra,80001730 <procinit>
    trapinit();      // trap vectors
    80000e60:	496010ef          	jal	ra,800022f6 <trapinit>
    trapinithart();  // install kernel trap vector
    80000e64:	4b6010ef          	jal	ra,8000231a <trapinithart>
    plicinit();      // set up interrupt controller
    80000e68:	366040ef          	jal	ra,800051ce <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000e6c:	378040ef          	jal	ra,800051e4 <plicinithart>
    binit();         // buffer cache
    80000e70:	329010ef          	jal	ra,80002998 <binit>
    iinit();         // inode table
    80000e74:	09c020ef          	jal	ra,80002f10 <iinit>
    fileinit();      // file table
    80000e78:	77d020ef          	jal	ra,80003df4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000e7c:	458040ef          	jal	ra,800052d4 <virtio_disk_init>
    userinit();      // first user process
    80000e80:	44b000ef          	jal	ra,80001aca <userinit>
    __sync_synchronize();
    80000e84:	0ff0000f          	fence
    started = 1;
    80000e88:	4785                	li	a5,1
    80000e8a:	00007717          	auipc	a4,0x7
    80000e8e:	9af72b23          	sw	a5,-1610(a4) # 80007840 <started>
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
    80000ea2:	9aa7b783          	ld	a5,-1622(a5) # 80007848 <kernel_pagetable>
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
    8000110c:	59a000ef          	jal	ra,800016a6 <proc_mapstacks>
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
    8000112a:	00006797          	auipc	a5,0x6
    8000112e:	70a7bf23          	sd	a0,1822(a5) # 80007848 <kernel_pagetable>
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
  return mem;
}

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
{
    800014e0:	7179                	addi	sp,sp,-48
    800014e2:	f406                	sd	ra,40(sp)
    800014e4:	f022                	sd	s0,32(sp)
    800014e6:	ec26                	sd	s1,24(sp)
    800014e8:	e84a                	sd	s2,16(sp)
    800014ea:	e44e                	sd	s3,8(sp)
    800014ec:	e052                	sd	s4,0(sp)
    800014ee:	1800                	addi	s0,sp,48
    800014f0:	89aa                	mv	s3,a0
    800014f2:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    800014f4:	310000ef          	jal	ra,80001804 <myproc>
  if (va >= p->sz)
    800014f8:	653c                	ld	a5,72(a0)
    800014fa:	00f4ec63          	bltu	s1,a5,80001512 <vmfault+0x32>
    return 0;
    800014fe:	4981                	li	s3,0
}
    80001500:	854e                	mv	a0,s3
    80001502:	70a2                	ld	ra,40(sp)
    80001504:	7402                	ld	s0,32(sp)
    80001506:	64e2                	ld	s1,24(sp)
    80001508:	6942                	ld	s2,16(sp)
    8000150a:	69a2                	ld	s3,8(sp)
    8000150c:	6a02                	ld	s4,0(sp)
    8000150e:	6145                	addi	sp,sp,48
    80001510:	8082                	ret
    80001512:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    80001514:	75fd                	lui	a1,0xfffff
    80001516:	8ced                	and	s1,s1,a1
  if(ismapped(pagetable, va)) {
    80001518:	85a6                	mv	a1,s1
    8000151a:	854e                	mv	a0,s3
    8000151c:	fa5ff0ef          	jal	ra,800014c0 <ismapped>
    return 0;
    80001520:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    80001522:	fd79                	bnez	a0,80001500 <vmfault+0x20>
  mem = (uint64) kalloc();
    80001524:	d78ff0ef          	jal	ra,80000a9c <kalloc>
    80001528:	8a2a                	mv	s4,a0
  if(mem == 0)
    8000152a:	d979                	beqz	a0,80001500 <vmfault+0x20>
  mem = (uint64) kalloc();
    8000152c:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    8000152e:	6605                	lui	a2,0x1
    80001530:	4581                	li	a1,0
    80001532:	f0eff0ef          	jal	ra,80000c40 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    80001536:	4759                	li	a4,22
    80001538:	86d2                	mv	a3,s4
    8000153a:	6605                	lui	a2,0x1
    8000153c:	85a6                	mv	a1,s1
    8000153e:	05093503          	ld	a0,80(s2) # 1050 <_entry-0x7fffefb0>
    80001542:	a53ff0ef          	jal	ra,80000f94 <mappages>
    80001546:	dd4d                	beqz	a0,80001500 <vmfault+0x20>
    kfree((void *)mem);
    80001548:	8552                	mv	a0,s4
    8000154a:	c72ff0ef          	jal	ra,800009bc <kfree>
    return 0;
    8000154e:	4981                	li	s3,0
    80001550:	bf45                	j	80001500 <vmfault+0x20>

0000000080001552 <copyout>:
  while(len > 0){
    80001552:	cec1                	beqz	a3,800015ea <copyout+0x98>
{
    80001554:	711d                	addi	sp,sp,-96
    80001556:	ec86                	sd	ra,88(sp)
    80001558:	e8a2                	sd	s0,80(sp)
    8000155a:	e4a6                	sd	s1,72(sp)
    8000155c:	e0ca                	sd	s2,64(sp)
    8000155e:	fc4e                	sd	s3,56(sp)
    80001560:	f852                	sd	s4,48(sp)
    80001562:	f456                	sd	s5,40(sp)
    80001564:	f05a                	sd	s6,32(sp)
    80001566:	ec5e                	sd	s7,24(sp)
    80001568:	e862                	sd	s8,16(sp)
    8000156a:	e466                	sd	s9,8(sp)
    8000156c:	e06a                	sd	s10,0(sp)
    8000156e:	1080                	addi	s0,sp,96
    80001570:	8c2a                	mv	s8,a0
    80001572:	8b2e                	mv	s6,a1
    80001574:	8bb2                	mv	s7,a2
    80001576:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    80001578:	74fd                	lui	s1,0xfffff
    8000157a:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    8000157c:	57fd                	li	a5,-1
    8000157e:	83e9                	srli	a5,a5,0x1a
    80001580:	0697e763          	bltu	a5,s1,800015ee <copyout+0x9c>
    80001584:	6d05                	lui	s10,0x1
    80001586:	8cbe                	mv	s9,a5
    80001588:	a015                	j	800015ac <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000158a:	409b0533          	sub	a0,s6,s1
    8000158e:	0009861b          	sext.w	a2,s3
    80001592:	85de                	mv	a1,s7
    80001594:	954a                	add	a0,a0,s2
    80001596:	f06ff0ef          	jal	ra,80000c9c <memmove>
    len -= n;
    8000159a:	413a0a33          	sub	s4,s4,s3
    src += n;
    8000159e:	9bce                	add	s7,s7,s3
  while(len > 0){
    800015a0:	040a0363          	beqz	s4,800015e6 <copyout+0x94>
    if(va0 >= MAXVA)
    800015a4:	055ce763          	bltu	s9,s5,800015f2 <copyout+0xa0>
    va0 = PGROUNDDOWN(dstva);
    800015a8:	84d6                	mv	s1,s5
    dstva = va0 + PGSIZE;
    800015aa:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    800015ac:	85a6                	mv	a1,s1
    800015ae:	8562                	mv	a0,s8
    800015b0:	9a7ff0ef          	jal	ra,80000f56 <walkaddr>
    800015b4:	892a                	mv	s2,a0
    if(pa0 == 0) {
    800015b6:	e901                	bnez	a0,800015c6 <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800015b8:	4601                	li	a2,0
    800015ba:	85a6                	mv	a1,s1
    800015bc:	8562                	mv	a0,s8
    800015be:	f23ff0ef          	jal	ra,800014e0 <vmfault>
    800015c2:	892a                	mv	s2,a0
    800015c4:	c90d                	beqz	a0,800015f6 <copyout+0xa4>
    pte = walk(pagetable, va0, 0);
    800015c6:	4601                	li	a2,0
    800015c8:	85a6                	mv	a1,s1
    800015ca:	8562                	mv	a0,s8
    800015cc:	8f1ff0ef          	jal	ra,80000ebc <walk>
    if((*pte & PTE_W) == 0)
    800015d0:	611c                	ld	a5,0(a0)
    800015d2:	8b91                	andi	a5,a5,4
    800015d4:	c39d                	beqz	a5,800015fa <copyout+0xa8>
    n = PGSIZE - (dstva - va0);
    800015d6:	01a48ab3          	add	s5,s1,s10
    800015da:	416a89b3          	sub	s3,s5,s6
    if(n > len)
    800015de:	fb3a76e3          	bgeu	s4,s3,8000158a <copyout+0x38>
    800015e2:	89d2                	mv	s3,s4
    800015e4:	b75d                	j	8000158a <copyout+0x38>
  return 0;
    800015e6:	4501                	li	a0,0
    800015e8:	a811                	j	800015fc <copyout+0xaa>
    800015ea:	4501                	li	a0,0
}
    800015ec:	8082                	ret
      return -1;
    800015ee:	557d                	li	a0,-1
    800015f0:	a031                	j	800015fc <copyout+0xaa>
    800015f2:	557d                	li	a0,-1
    800015f4:	a021                	j	800015fc <copyout+0xaa>
        return -1;
    800015f6:	557d                	li	a0,-1
    800015f8:	a011                	j	800015fc <copyout+0xaa>
      return -1;
    800015fa:	557d                	li	a0,-1
}
    800015fc:	60e6                	ld	ra,88(sp)
    800015fe:	6446                	ld	s0,80(sp)
    80001600:	64a6                	ld	s1,72(sp)
    80001602:	6906                	ld	s2,64(sp)
    80001604:	79e2                	ld	s3,56(sp)
    80001606:	7a42                	ld	s4,48(sp)
    80001608:	7aa2                	ld	s5,40(sp)
    8000160a:	7b02                	ld	s6,32(sp)
    8000160c:	6be2                	ld	s7,24(sp)
    8000160e:	6c42                	ld	s8,16(sp)
    80001610:	6ca2                	ld	s9,8(sp)
    80001612:	6d02                	ld	s10,0(sp)
    80001614:	6125                	addi	sp,sp,96
    80001616:	8082                	ret

0000000080001618 <copyin>:
  while(len > 0){
    80001618:	c6c9                	beqz	a3,800016a2 <copyin+0x8a>
{
    8000161a:	715d                	addi	sp,sp,-80
    8000161c:	e486                	sd	ra,72(sp)
    8000161e:	e0a2                	sd	s0,64(sp)
    80001620:	fc26                	sd	s1,56(sp)
    80001622:	f84a                	sd	s2,48(sp)
    80001624:	f44e                	sd	s3,40(sp)
    80001626:	f052                	sd	s4,32(sp)
    80001628:	ec56                	sd	s5,24(sp)
    8000162a:	e85a                	sd	s6,16(sp)
    8000162c:	e45e                	sd	s7,8(sp)
    8000162e:	e062                	sd	s8,0(sp)
    80001630:	0880                	addi	s0,sp,80
    80001632:	8baa                	mv	s7,a0
    80001634:	8aae                	mv	s5,a1
    80001636:	8932                	mv	s2,a2
    80001638:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    8000163a:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    8000163c:	6b05                	lui	s6,0x1
    8000163e:	a035                	j	8000166a <copyin+0x52>
    80001640:	412984b3          	sub	s1,s3,s2
    80001644:	94da                	add	s1,s1,s6
    if(n > len)
    80001646:	009a7363          	bgeu	s4,s1,8000164c <copyin+0x34>
    8000164a:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000164c:	413905b3          	sub	a1,s2,s3
    80001650:	0004861b          	sext.w	a2,s1
    80001654:	95aa                	add	a1,a1,a0
    80001656:	8556                	mv	a0,s5
    80001658:	e44ff0ef          	jal	ra,80000c9c <memmove>
    len -= n;
    8000165c:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001660:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001662:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001666:	020a0163          	beqz	s4,80001688 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    8000166a:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    8000166e:	85ce                	mv	a1,s3
    80001670:	855e                	mv	a0,s7
    80001672:	8e5ff0ef          	jal	ra,80000f56 <walkaddr>
    if(pa0 == 0) {
    80001676:	f569                	bnez	a0,80001640 <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001678:	4601                	li	a2,0
    8000167a:	85ce                	mv	a1,s3
    8000167c:	855e                	mv	a0,s7
    8000167e:	e63ff0ef          	jal	ra,800014e0 <vmfault>
    80001682:	fd5d                	bnez	a0,80001640 <copyin+0x28>
        return -1;
    80001684:	557d                	li	a0,-1
    80001686:	a011                	j	8000168a <copyin+0x72>
  return 0;
    80001688:	4501                	li	a0,0
}
    8000168a:	60a6                	ld	ra,72(sp)
    8000168c:	6406                	ld	s0,64(sp)
    8000168e:	74e2                	ld	s1,56(sp)
    80001690:	7942                	ld	s2,48(sp)
    80001692:	79a2                	ld	s3,40(sp)
    80001694:	7a02                	ld	s4,32(sp)
    80001696:	6ae2                	ld	s5,24(sp)
    80001698:	6b42                	ld	s6,16(sp)
    8000169a:	6ba2                	ld	s7,8(sp)
    8000169c:	6c02                	ld	s8,0(sp)
    8000169e:	6161                	addi	sp,sp,80
    800016a0:	8082                	ret
  return 0;
    800016a2:	4501                	li	a0,0
}
    800016a4:	8082                	ret

00000000800016a6 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800016a6:	7139                	addi	sp,sp,-64
    800016a8:	fc06                	sd	ra,56(sp)
    800016aa:	f822                	sd	s0,48(sp)
    800016ac:	f426                	sd	s1,40(sp)
    800016ae:	f04a                	sd	s2,32(sp)
    800016b0:	ec4e                	sd	s3,24(sp)
    800016b2:	e852                	sd	s4,16(sp)
    800016b4:	e456                	sd	s5,8(sp)
    800016b6:	e05a                	sd	s6,0(sp)
    800016b8:	0080                	addi	s0,sp,64
    800016ba:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800016bc:	0000e497          	auipc	s1,0xe
    800016c0:	6cc48493          	addi	s1,s1,1740 # 8000fd88 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800016c4:	8b26                	mv	s6,s1
    800016c6:	00006a97          	auipc	s5,0x6
    800016ca:	93aa8a93          	addi	s5,s5,-1734 # 80007000 <etext>
    800016ce:	04000937          	lui	s2,0x4000
    800016d2:	197d                	addi	s2,s2,-1
    800016d4:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800016d6:	00014a17          	auipc	s4,0x14
    800016da:	0b2a0a13          	addi	s4,s4,178 # 80015788 <tickslock>
    char *pa = kalloc();
    800016de:	bbeff0ef          	jal	ra,80000a9c <kalloc>
    800016e2:	862a                	mv	a2,a0
    if(pa == 0)
    800016e4:	c121                	beqz	a0,80001724 <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    800016e6:	416485b3          	sub	a1,s1,s6
    800016ea:	858d                	srai	a1,a1,0x3
    800016ec:	000ab783          	ld	a5,0(s5)
    800016f0:	02f585b3          	mul	a1,a1,a5
    800016f4:	2585                	addiw	a1,a1,1
    800016f6:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800016fa:	4719                	li	a4,6
    800016fc:	6685                	lui	a3,0x1
    800016fe:	40b905b3          	sub	a1,s2,a1
    80001702:	854e                	mv	a0,s3
    80001704:	941ff0ef          	jal	ra,80001044 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001708:	16848493          	addi	s1,s1,360
    8000170c:	fd4499e3          	bne	s1,s4,800016de <proc_mapstacks+0x38>
  }
}
    80001710:	70e2                	ld	ra,56(sp)
    80001712:	7442                	ld	s0,48(sp)
    80001714:	74a2                	ld	s1,40(sp)
    80001716:	7902                	ld	s2,32(sp)
    80001718:	69e2                	ld	s3,24(sp)
    8000171a:	6a42                	ld	s4,16(sp)
    8000171c:	6aa2                	ld	s5,8(sp)
    8000171e:	6b02                	ld	s6,0(sp)
    80001720:	6121                	addi	sp,sp,64
    80001722:	8082                	ret
      panic("kalloc");
    80001724:	00006517          	auipc	a0,0x6
    80001728:	a4c50513          	addi	a0,a0,-1460 # 80007170 <digits+0x138>
    8000172c:	85eff0ef          	jal	ra,8000078a <panic>

0000000080001730 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001730:	7139                	addi	sp,sp,-64
    80001732:	fc06                	sd	ra,56(sp)
    80001734:	f822                	sd	s0,48(sp)
    80001736:	f426                	sd	s1,40(sp)
    80001738:	f04a                	sd	s2,32(sp)
    8000173a:	ec4e                	sd	s3,24(sp)
    8000173c:	e852                	sd	s4,16(sp)
    8000173e:	e456                	sd	s5,8(sp)
    80001740:	e05a                	sd	s6,0(sp)
    80001742:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001744:	00006597          	auipc	a1,0x6
    80001748:	a3458593          	addi	a1,a1,-1484 # 80007178 <digits+0x140>
    8000174c:	0000e517          	auipc	a0,0xe
    80001750:	20c50513          	addi	a0,a0,524 # 8000f958 <pid_lock>
    80001754:	b98ff0ef          	jal	ra,80000aec <initlock>
  initlock(&wait_lock, "wait_lock");
    80001758:	00006597          	auipc	a1,0x6
    8000175c:	a2858593          	addi	a1,a1,-1496 # 80007180 <digits+0x148>
    80001760:	0000e517          	auipc	a0,0xe
    80001764:	21050513          	addi	a0,a0,528 # 8000f970 <wait_lock>
    80001768:	b84ff0ef          	jal	ra,80000aec <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000176c:	0000e497          	auipc	s1,0xe
    80001770:	61c48493          	addi	s1,s1,1564 # 8000fd88 <proc>
      initlock(&p->lock, "proc");
    80001774:	00006b17          	auipc	s6,0x6
    80001778:	a1cb0b13          	addi	s6,s6,-1508 # 80007190 <digits+0x158>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000177c:	8aa6                	mv	s5,s1
    8000177e:	00006a17          	auipc	s4,0x6
    80001782:	882a0a13          	addi	s4,s4,-1918 # 80007000 <etext>
    80001786:	04000937          	lui	s2,0x4000
    8000178a:	197d                	addi	s2,s2,-1
    8000178c:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000178e:	00014997          	auipc	s3,0x14
    80001792:	ffa98993          	addi	s3,s3,-6 # 80015788 <tickslock>
      initlock(&p->lock, "proc");
    80001796:	85da                	mv	a1,s6
    80001798:	8526                	mv	a0,s1
    8000179a:	b52ff0ef          	jal	ra,80000aec <initlock>
      p->state = UNUSED;
    8000179e:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800017a2:	415487b3          	sub	a5,s1,s5
    800017a6:	878d                	srai	a5,a5,0x3
    800017a8:	000a3703          	ld	a4,0(s4)
    800017ac:	02e787b3          	mul	a5,a5,a4
    800017b0:	2785                	addiw	a5,a5,1
    800017b2:	00d7979b          	slliw	a5,a5,0xd
    800017b6:	40f907b3          	sub	a5,s2,a5
    800017ba:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800017bc:	16848493          	addi	s1,s1,360
    800017c0:	fd349be3          	bne	s1,s3,80001796 <procinit+0x66>
  }
}
    800017c4:	70e2                	ld	ra,56(sp)
    800017c6:	7442                	ld	s0,48(sp)
    800017c8:	74a2                	ld	s1,40(sp)
    800017ca:	7902                	ld	s2,32(sp)
    800017cc:	69e2                	ld	s3,24(sp)
    800017ce:	6a42                	ld	s4,16(sp)
    800017d0:	6aa2                	ld	s5,8(sp)
    800017d2:	6b02                	ld	s6,0(sp)
    800017d4:	6121                	addi	sp,sp,64
    800017d6:	8082                	ret

00000000800017d8 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800017d8:	1141                	addi	sp,sp,-16
    800017da:	e422                	sd	s0,8(sp)
    800017dc:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800017de:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800017e0:	2501                	sext.w	a0,a0
    800017e2:	6422                	ld	s0,8(sp)
    800017e4:	0141                	addi	sp,sp,16
    800017e6:	8082                	ret

00000000800017e8 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800017e8:	1141                	addi	sp,sp,-16
    800017ea:	e422                	sd	s0,8(sp)
    800017ec:	0800                	addi	s0,sp,16
    800017ee:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800017f0:	2781                	sext.w	a5,a5
    800017f2:	079e                	slli	a5,a5,0x7
  return c;
}
    800017f4:	0000e517          	auipc	a0,0xe
    800017f8:	19450513          	addi	a0,a0,404 # 8000f988 <cpus>
    800017fc:	953e                	add	a0,a0,a5
    800017fe:	6422                	ld	s0,8(sp)
    80001800:	0141                	addi	sp,sp,16
    80001802:	8082                	ret

0000000080001804 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001804:	1101                	addi	sp,sp,-32
    80001806:	ec06                	sd	ra,24(sp)
    80001808:	e822                	sd	s0,16(sp)
    8000180a:	e426                	sd	s1,8(sp)
    8000180c:	1000                	addi	s0,sp,32
  push_off();
    8000180e:	b1eff0ef          	jal	ra,80000b2c <push_off>
    80001812:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001814:	2781                	sext.w	a5,a5
    80001816:	079e                	slli	a5,a5,0x7
    80001818:	0000e717          	auipc	a4,0xe
    8000181c:	14070713          	addi	a4,a4,320 # 8000f958 <pid_lock>
    80001820:	97ba                	add	a5,a5,a4
    80001822:	7b84                	ld	s1,48(a5)
  pop_off();
    80001824:	b8cff0ef          	jal	ra,80000bb0 <pop_off>
  return p;
}
    80001828:	8526                	mv	a0,s1
    8000182a:	60e2                	ld	ra,24(sp)
    8000182c:	6442                	ld	s0,16(sp)
    8000182e:	64a2                	ld	s1,8(sp)
    80001830:	6105                	addi	sp,sp,32
    80001832:	8082                	ret

0000000080001834 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001834:	7179                	addi	sp,sp,-48
    80001836:	f406                	sd	ra,40(sp)
    80001838:	f022                	sd	s0,32(sp)
    8000183a:	ec26                	sd	s1,24(sp)
    8000183c:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    8000183e:	fc7ff0ef          	jal	ra,80001804 <myproc>
    80001842:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001844:	bc0ff0ef          	jal	ra,80000c04 <release>

  if (first) {
    80001848:	00006797          	auipc	a5,0x6
    8000184c:	fd87a783          	lw	a5,-40(a5) # 80007820 <first.1>
    80001850:	cf8d                	beqz	a5,8000188a <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001852:	4505                	li	a0,1
    80001854:	36d010ef          	jal	ra,800033c0 <fsinit>

    first = 0;
    80001858:	00006797          	auipc	a5,0x6
    8000185c:	fc07a423          	sw	zero,-56(a5) # 80007820 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001860:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001864:	00006517          	auipc	a0,0x6
    80001868:	93450513          	addi	a0,a0,-1740 # 80007198 <digits+0x160>
    8000186c:	fca43823          	sd	a0,-48(s0)
    80001870:	fc043c23          	sd	zero,-40(s0)
    80001874:	fd040593          	addi	a1,s0,-48
    80001878:	3e7020ef          	jal	ra,8000445e <kexec>
    8000187c:	6cbc                	ld	a5,88(s1)
    8000187e:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001880:	6cbc                	ld	a5,88(s1)
    80001882:	7bb8                	ld	a4,112(a5)
    80001884:	57fd                	li	a5,-1
    80001886:	02f70d63          	beq	a4,a5,800018c0 <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    8000188a:	2a9000ef          	jal	ra,80002332 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000188e:	68a8                	ld	a0,80(s1)
    80001890:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001892:	04000737          	lui	a4,0x4000
    80001896:	00005797          	auipc	a5,0x5
    8000189a:	80678793          	addi	a5,a5,-2042 # 8000609c <userret>
    8000189e:	00004697          	auipc	a3,0x4
    800018a2:	76268693          	addi	a3,a3,1890 # 80006000 <_trampoline>
    800018a6:	8f95                	sub	a5,a5,a3
    800018a8:	177d                	addi	a4,a4,-1
    800018aa:	0732                	slli	a4,a4,0xc
    800018ac:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800018ae:	577d                	li	a4,-1
    800018b0:	177e                	slli	a4,a4,0x3f
    800018b2:	8d59                	or	a0,a0,a4
    800018b4:	9782                	jalr	a5
}
    800018b6:	70a2                	ld	ra,40(sp)
    800018b8:	7402                	ld	s0,32(sp)
    800018ba:	64e2                	ld	s1,24(sp)
    800018bc:	6145                	addi	sp,sp,48
    800018be:	8082                	ret
      panic("exec");
    800018c0:	00006517          	auipc	a0,0x6
    800018c4:	8e050513          	addi	a0,a0,-1824 # 800071a0 <digits+0x168>
    800018c8:	ec3fe0ef          	jal	ra,8000078a <panic>

00000000800018cc <allocpid>:
{
    800018cc:	1101                	addi	sp,sp,-32
    800018ce:	ec06                	sd	ra,24(sp)
    800018d0:	e822                	sd	s0,16(sp)
    800018d2:	e426                	sd	s1,8(sp)
    800018d4:	e04a                	sd	s2,0(sp)
    800018d6:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800018d8:	0000e917          	auipc	s2,0xe
    800018dc:	08090913          	addi	s2,s2,128 # 8000f958 <pid_lock>
    800018e0:	854a                	mv	a0,s2
    800018e2:	a8aff0ef          	jal	ra,80000b6c <acquire>
  pid = nextpid;
    800018e6:	00006797          	auipc	a5,0x6
    800018ea:	f3e78793          	addi	a5,a5,-194 # 80007824 <nextpid>
    800018ee:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800018f0:	0014871b          	addiw	a4,s1,1
    800018f4:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800018f6:	854a                	mv	a0,s2
    800018f8:	b0cff0ef          	jal	ra,80000c04 <release>
}
    800018fc:	8526                	mv	a0,s1
    800018fe:	60e2                	ld	ra,24(sp)
    80001900:	6442                	ld	s0,16(sp)
    80001902:	64a2                	ld	s1,8(sp)
    80001904:	6902                	ld	s2,0(sp)
    80001906:	6105                	addi	sp,sp,32
    80001908:	8082                	ret

000000008000190a <proc_pagetable>:
{
    8000190a:	1101                	addi	sp,sp,-32
    8000190c:	ec06                	sd	ra,24(sp)
    8000190e:	e822                	sd	s0,16(sp)
    80001910:	e426                	sd	s1,8(sp)
    80001912:	e04a                	sd	s2,0(sp)
    80001914:	1000                	addi	s0,sp,32
    80001916:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001918:	823ff0ef          	jal	ra,8000113a <uvmcreate>
    8000191c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000191e:	cd05                	beqz	a0,80001956 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001920:	4729                	li	a4,10
    80001922:	00004697          	auipc	a3,0x4
    80001926:	6de68693          	addi	a3,a3,1758 # 80006000 <_trampoline>
    8000192a:	6605                	lui	a2,0x1
    8000192c:	040005b7          	lui	a1,0x4000
    80001930:	15fd                	addi	a1,a1,-1
    80001932:	05b2                	slli	a1,a1,0xc
    80001934:	e60ff0ef          	jal	ra,80000f94 <mappages>
    80001938:	02054663          	bltz	a0,80001964 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    8000193c:	4719                	li	a4,6
    8000193e:	05893683          	ld	a3,88(s2)
    80001942:	6605                	lui	a2,0x1
    80001944:	020005b7          	lui	a1,0x2000
    80001948:	15fd                	addi	a1,a1,-1
    8000194a:	05b6                	slli	a1,a1,0xd
    8000194c:	8526                	mv	a0,s1
    8000194e:	e46ff0ef          	jal	ra,80000f94 <mappages>
    80001952:	00054f63          	bltz	a0,80001970 <proc_pagetable+0x66>
}
    80001956:	8526                	mv	a0,s1
    80001958:	60e2                	ld	ra,24(sp)
    8000195a:	6442                	ld	s0,16(sp)
    8000195c:	64a2                	ld	s1,8(sp)
    8000195e:	6902                	ld	s2,0(sp)
    80001960:	6105                	addi	sp,sp,32
    80001962:	8082                	ret
    uvmfree(pagetable, 0);
    80001964:	4581                	li	a1,0
    80001966:	8526                	mv	a0,s1
    80001968:	9b1ff0ef          	jal	ra,80001318 <uvmfree>
    return 0;
    8000196c:	4481                	li	s1,0
    8000196e:	b7e5                	j	80001956 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001970:	4681                	li	a3,0
    80001972:	4605                	li	a2,1
    80001974:	040005b7          	lui	a1,0x4000
    80001978:	15fd                	addi	a1,a1,-1
    8000197a:	05b2                	slli	a1,a1,0xc
    8000197c:	8526                	mv	a0,s1
    8000197e:	fe2ff0ef          	jal	ra,80001160 <uvmunmap>
    uvmfree(pagetable, 0);
    80001982:	4581                	li	a1,0
    80001984:	8526                	mv	a0,s1
    80001986:	993ff0ef          	jal	ra,80001318 <uvmfree>
    return 0;
    8000198a:	4481                	li	s1,0
    8000198c:	b7e9                	j	80001956 <proc_pagetable+0x4c>

000000008000198e <proc_freepagetable>:
{
    8000198e:	1101                	addi	sp,sp,-32
    80001990:	ec06                	sd	ra,24(sp)
    80001992:	e822                	sd	s0,16(sp)
    80001994:	e426                	sd	s1,8(sp)
    80001996:	e04a                	sd	s2,0(sp)
    80001998:	1000                	addi	s0,sp,32
    8000199a:	84aa                	mv	s1,a0
    8000199c:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000199e:	4681                	li	a3,0
    800019a0:	4605                	li	a2,1
    800019a2:	040005b7          	lui	a1,0x4000
    800019a6:	15fd                	addi	a1,a1,-1
    800019a8:	05b2                	slli	a1,a1,0xc
    800019aa:	fb6ff0ef          	jal	ra,80001160 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    800019ae:	4681                	li	a3,0
    800019b0:	4605                	li	a2,1
    800019b2:	020005b7          	lui	a1,0x2000
    800019b6:	15fd                	addi	a1,a1,-1
    800019b8:	05b6                	slli	a1,a1,0xd
    800019ba:	8526                	mv	a0,s1
    800019bc:	fa4ff0ef          	jal	ra,80001160 <uvmunmap>
  uvmfree(pagetable, sz);
    800019c0:	85ca                	mv	a1,s2
    800019c2:	8526                	mv	a0,s1
    800019c4:	955ff0ef          	jal	ra,80001318 <uvmfree>
}
    800019c8:	60e2                	ld	ra,24(sp)
    800019ca:	6442                	ld	s0,16(sp)
    800019cc:	64a2                	ld	s1,8(sp)
    800019ce:	6902                	ld	s2,0(sp)
    800019d0:	6105                	addi	sp,sp,32
    800019d2:	8082                	ret

00000000800019d4 <freeproc>:
{
    800019d4:	1101                	addi	sp,sp,-32
    800019d6:	ec06                	sd	ra,24(sp)
    800019d8:	e822                	sd	s0,16(sp)
    800019da:	e426                	sd	s1,8(sp)
    800019dc:	1000                	addi	s0,sp,32
    800019de:	84aa                	mv	s1,a0
  if(p->trapframe)
    800019e0:	6d28                	ld	a0,88(a0)
    800019e2:	c119                	beqz	a0,800019e8 <freeproc+0x14>
    kfree((void*)p->trapframe);
    800019e4:	fd9fe0ef          	jal	ra,800009bc <kfree>
  p->trapframe = 0;
    800019e8:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    800019ec:	68a8                	ld	a0,80(s1)
    800019ee:	c501                	beqz	a0,800019f6 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    800019f0:	64ac                	ld	a1,72(s1)
    800019f2:	f9dff0ef          	jal	ra,8000198e <proc_freepagetable>
  p->pagetable = 0;
    800019f6:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    800019fa:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    800019fe:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001a02:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001a06:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001a0a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001a0e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001a12:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001a16:	0004ac23          	sw	zero,24(s1)
}
    80001a1a:	60e2                	ld	ra,24(sp)
    80001a1c:	6442                	ld	s0,16(sp)
    80001a1e:	64a2                	ld	s1,8(sp)
    80001a20:	6105                	addi	sp,sp,32
    80001a22:	8082                	ret

0000000080001a24 <allocproc>:
{
    80001a24:	1101                	addi	sp,sp,-32
    80001a26:	ec06                	sd	ra,24(sp)
    80001a28:	e822                	sd	s0,16(sp)
    80001a2a:	e426                	sd	s1,8(sp)
    80001a2c:	e04a                	sd	s2,0(sp)
    80001a2e:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a30:	0000e497          	auipc	s1,0xe
    80001a34:	35848493          	addi	s1,s1,856 # 8000fd88 <proc>
    80001a38:	00014917          	auipc	s2,0x14
    80001a3c:	d5090913          	addi	s2,s2,-688 # 80015788 <tickslock>
    acquire(&p->lock);
    80001a40:	8526                	mv	a0,s1
    80001a42:	92aff0ef          	jal	ra,80000b6c <acquire>
    if(p->state == UNUSED) {
    80001a46:	4c9c                	lw	a5,24(s1)
    80001a48:	cb91                	beqz	a5,80001a5c <allocproc+0x38>
      release(&p->lock);
    80001a4a:	8526                	mv	a0,s1
    80001a4c:	9b8ff0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a50:	16848493          	addi	s1,s1,360
    80001a54:	ff2496e3          	bne	s1,s2,80001a40 <allocproc+0x1c>
  return 0;
    80001a58:	4481                	li	s1,0
    80001a5a:	a089                	j	80001a9c <allocproc+0x78>
  p->pid = allocpid();
    80001a5c:	e71ff0ef          	jal	ra,800018cc <allocpid>
    80001a60:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001a62:	4785                	li	a5,1
    80001a64:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001a66:	836ff0ef          	jal	ra,80000a9c <kalloc>
    80001a6a:	892a                	mv	s2,a0
    80001a6c:	eca8                	sd	a0,88(s1)
    80001a6e:	cd15                	beqz	a0,80001aaa <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001a70:	8526                	mv	a0,s1
    80001a72:	e99ff0ef          	jal	ra,8000190a <proc_pagetable>
    80001a76:	892a                	mv	s2,a0
    80001a78:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001a7a:	c121                	beqz	a0,80001aba <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001a7c:	07000613          	li	a2,112
    80001a80:	4581                	li	a1,0
    80001a82:	06048513          	addi	a0,s1,96
    80001a86:	9baff0ef          	jal	ra,80000c40 <memset>
  p->context.ra = (uint64)forkret;
    80001a8a:	00000797          	auipc	a5,0x0
    80001a8e:	daa78793          	addi	a5,a5,-598 # 80001834 <forkret>
    80001a92:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001a94:	60bc                	ld	a5,64(s1)
    80001a96:	6705                	lui	a4,0x1
    80001a98:	97ba                	add	a5,a5,a4
    80001a9a:	f4bc                	sd	a5,104(s1)
}
    80001a9c:	8526                	mv	a0,s1
    80001a9e:	60e2                	ld	ra,24(sp)
    80001aa0:	6442                	ld	s0,16(sp)
    80001aa2:	64a2                	ld	s1,8(sp)
    80001aa4:	6902                	ld	s2,0(sp)
    80001aa6:	6105                	addi	sp,sp,32
    80001aa8:	8082                	ret
    freeproc(p);
    80001aaa:	8526                	mv	a0,s1
    80001aac:	f29ff0ef          	jal	ra,800019d4 <freeproc>
    release(&p->lock);
    80001ab0:	8526                	mv	a0,s1
    80001ab2:	952ff0ef          	jal	ra,80000c04 <release>
    return 0;
    80001ab6:	84ca                	mv	s1,s2
    80001ab8:	b7d5                	j	80001a9c <allocproc+0x78>
    freeproc(p);
    80001aba:	8526                	mv	a0,s1
    80001abc:	f19ff0ef          	jal	ra,800019d4 <freeproc>
    release(&p->lock);
    80001ac0:	8526                	mv	a0,s1
    80001ac2:	942ff0ef          	jal	ra,80000c04 <release>
    return 0;
    80001ac6:	84ca                	mv	s1,s2
    80001ac8:	bfd1                	j	80001a9c <allocproc+0x78>

0000000080001aca <userinit>:
{
    80001aca:	1101                	addi	sp,sp,-32
    80001acc:	ec06                	sd	ra,24(sp)
    80001ace:	e822                	sd	s0,16(sp)
    80001ad0:	e426                	sd	s1,8(sp)
    80001ad2:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ad4:	f51ff0ef          	jal	ra,80001a24 <allocproc>
    80001ad8:	84aa                	mv	s1,a0
  initproc = p;
    80001ada:	00006797          	auipc	a5,0x6
    80001ade:	d6a7bb23          	sd	a0,-650(a5) # 80007850 <initproc>
  p->cwd = namei("/");
    80001ae2:	00005517          	auipc	a0,0x5
    80001ae6:	6c650513          	addi	a0,a0,1734 # 800071a8 <digits+0x170>
    80001aea:	5d5010ef          	jal	ra,800038be <namei>
    80001aee:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001af2:	478d                	li	a5,3
    80001af4:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001af6:	8526                	mv	a0,s1
    80001af8:	90cff0ef          	jal	ra,80000c04 <release>
}
    80001afc:	60e2                	ld	ra,24(sp)
    80001afe:	6442                	ld	s0,16(sp)
    80001b00:	64a2                	ld	s1,8(sp)
    80001b02:	6105                	addi	sp,sp,32
    80001b04:	8082                	ret

0000000080001b06 <growproc>:
{
    80001b06:	1101                	addi	sp,sp,-32
    80001b08:	ec06                	sd	ra,24(sp)
    80001b0a:	e822                	sd	s0,16(sp)
    80001b0c:	e426                	sd	s1,8(sp)
    80001b0e:	e04a                	sd	s2,0(sp)
    80001b10:	1000                	addi	s0,sp,32
    80001b12:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001b14:	cf1ff0ef          	jal	ra,80001804 <myproc>
    80001b18:	84aa                	mv	s1,a0
  sz = p->sz;
    80001b1a:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001b1c:	01204c63          	bgtz	s2,80001b34 <growproc+0x2e>
  } else if(n < 0){
    80001b20:	02094463          	bltz	s2,80001b48 <growproc+0x42>
  p->sz = sz;
    80001b24:	e4ac                	sd	a1,72(s1)
  return 0;
    80001b26:	4501                	li	a0,0
}
    80001b28:	60e2                	ld	ra,24(sp)
    80001b2a:	6442                	ld	s0,16(sp)
    80001b2c:	64a2                	ld	s1,8(sp)
    80001b2e:	6902                	ld	s2,0(sp)
    80001b30:	6105                	addi	sp,sp,32
    80001b32:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001b34:	4691                	li	a3,4
    80001b36:	00b90633          	add	a2,s2,a1
    80001b3a:	6928                	ld	a0,80(a0)
    80001b3c:	ee4ff0ef          	jal	ra,80001220 <uvmalloc>
    80001b40:	85aa                	mv	a1,a0
    80001b42:	f16d                	bnez	a0,80001b24 <growproc+0x1e>
      return -1;
    80001b44:	557d                	li	a0,-1
    80001b46:	b7cd                	j	80001b28 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001b48:	00b90633          	add	a2,s2,a1
    80001b4c:	6928                	ld	a0,80(a0)
    80001b4e:	e8eff0ef          	jal	ra,800011dc <uvmdealloc>
    80001b52:	85aa                	mv	a1,a0
    80001b54:	bfc1                	j	80001b24 <growproc+0x1e>

0000000080001b56 <kfork>:
{
    80001b56:	7139                	addi	sp,sp,-64
    80001b58:	fc06                	sd	ra,56(sp)
    80001b5a:	f822                	sd	s0,48(sp)
    80001b5c:	f426                	sd	s1,40(sp)
    80001b5e:	f04a                	sd	s2,32(sp)
    80001b60:	ec4e                	sd	s3,24(sp)
    80001b62:	e852                	sd	s4,16(sp)
    80001b64:	e456                	sd	s5,8(sp)
    80001b66:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001b68:	c9dff0ef          	jal	ra,80001804 <myproc>
    80001b6c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001b6e:	eb7ff0ef          	jal	ra,80001a24 <allocproc>
    80001b72:	0e050663          	beqz	a0,80001c5e <kfork+0x108>
    80001b76:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001b78:	048ab603          	ld	a2,72(s5)
    80001b7c:	692c                	ld	a1,80(a0)
    80001b7e:	050ab503          	ld	a0,80(s5)
    80001b82:	fc6ff0ef          	jal	ra,80001348 <uvmcopy>
    80001b86:	04054863          	bltz	a0,80001bd6 <kfork+0x80>
  np->sz = p->sz;
    80001b8a:	048ab783          	ld	a5,72(s5)
    80001b8e:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001b92:	058ab683          	ld	a3,88(s5)
    80001b96:	87b6                	mv	a5,a3
    80001b98:	058a3703          	ld	a4,88(s4)
    80001b9c:	12068693          	addi	a3,a3,288
    80001ba0:	0007b803          	ld	a6,0(a5)
    80001ba4:	6788                	ld	a0,8(a5)
    80001ba6:	6b8c                	ld	a1,16(a5)
    80001ba8:	6f90                	ld	a2,24(a5)
    80001baa:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001bae:	e708                	sd	a0,8(a4)
    80001bb0:	eb0c                	sd	a1,16(a4)
    80001bb2:	ef10                	sd	a2,24(a4)
    80001bb4:	02078793          	addi	a5,a5,32
    80001bb8:	02070713          	addi	a4,a4,32
    80001bbc:	fed792e3          	bne	a5,a3,80001ba0 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001bc0:	058a3783          	ld	a5,88(s4)
    80001bc4:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001bc8:	0d0a8493          	addi	s1,s5,208
    80001bcc:	0d0a0913          	addi	s2,s4,208
    80001bd0:	150a8993          	addi	s3,s5,336
    80001bd4:	a829                	j	80001bee <kfork+0x98>
    freeproc(np);
    80001bd6:	8552                	mv	a0,s4
    80001bd8:	dfdff0ef          	jal	ra,800019d4 <freeproc>
    release(&np->lock);
    80001bdc:	8552                	mv	a0,s4
    80001bde:	826ff0ef          	jal	ra,80000c04 <release>
    return -1;
    80001be2:	597d                	li	s2,-1
    80001be4:	a09d                	j	80001c4a <kfork+0xf4>
  for(i = 0; i < NOFILE; i++)
    80001be6:	04a1                	addi	s1,s1,8
    80001be8:	0921                	addi	s2,s2,8
    80001bea:	01348963          	beq	s1,s3,80001bfc <kfork+0xa6>
    if(p->ofile[i])
    80001bee:	6088                	ld	a0,0(s1)
    80001bf0:	d97d                	beqz	a0,80001be6 <kfork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    80001bf2:	284020ef          	jal	ra,80003e76 <filedup>
    80001bf6:	00a93023          	sd	a0,0(s2)
    80001bfa:	b7f5                	j	80001be6 <kfork+0x90>
  np->cwd = idup(p->cwd);
    80001bfc:	150ab503          	ld	a0,336(s5)
    80001c00:	49a010ef          	jal	ra,8000309a <idup>
    80001c04:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001c08:	4641                	li	a2,16
    80001c0a:	158a8593          	addi	a1,s5,344
    80001c0e:	158a0513          	addi	a0,s4,344
    80001c12:	974ff0ef          	jal	ra,80000d86 <safestrcpy>
  pid = np->pid;
    80001c16:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001c1a:	8552                	mv	a0,s4
    80001c1c:	fe9fe0ef          	jal	ra,80000c04 <release>
  acquire(&wait_lock);
    80001c20:	0000e497          	auipc	s1,0xe
    80001c24:	d5048493          	addi	s1,s1,-688 # 8000f970 <wait_lock>
    80001c28:	8526                	mv	a0,s1
    80001c2a:	f43fe0ef          	jal	ra,80000b6c <acquire>
  np->parent = p;
    80001c2e:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001c32:	8526                	mv	a0,s1
    80001c34:	fd1fe0ef          	jal	ra,80000c04 <release>
  acquire(&np->lock);
    80001c38:	8552                	mv	a0,s4
    80001c3a:	f33fe0ef          	jal	ra,80000b6c <acquire>
  np->state = RUNNABLE;
    80001c3e:	478d                	li	a5,3
    80001c40:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001c44:	8552                	mv	a0,s4
    80001c46:	fbffe0ef          	jal	ra,80000c04 <release>
}
    80001c4a:	854a                	mv	a0,s2
    80001c4c:	70e2                	ld	ra,56(sp)
    80001c4e:	7442                	ld	s0,48(sp)
    80001c50:	74a2                	ld	s1,40(sp)
    80001c52:	7902                	ld	s2,32(sp)
    80001c54:	69e2                	ld	s3,24(sp)
    80001c56:	6a42                	ld	s4,16(sp)
    80001c58:	6aa2                	ld	s5,8(sp)
    80001c5a:	6121                	addi	sp,sp,64
    80001c5c:	8082                	ret
    return -1;
    80001c5e:	597d                	li	s2,-1
    80001c60:	b7ed                	j	80001c4a <kfork+0xf4>

0000000080001c62 <scheduler>:
{
    80001c62:	715d                	addi	sp,sp,-80
    80001c64:	e486                	sd	ra,72(sp)
    80001c66:	e0a2                	sd	s0,64(sp)
    80001c68:	fc26                	sd	s1,56(sp)
    80001c6a:	f84a                	sd	s2,48(sp)
    80001c6c:	f44e                	sd	s3,40(sp)
    80001c6e:	f052                	sd	s4,32(sp)
    80001c70:	ec56                	sd	s5,24(sp)
    80001c72:	e85a                	sd	s6,16(sp)
    80001c74:	e45e                	sd	s7,8(sp)
    80001c76:	e062                	sd	s8,0(sp)
    80001c78:	0880                	addi	s0,sp,80
    80001c7a:	8792                	mv	a5,tp
  int id = r_tp();
    80001c7c:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001c7e:	00779b13          	slli	s6,a5,0x7
    80001c82:	0000e717          	auipc	a4,0xe
    80001c86:	cd670713          	addi	a4,a4,-810 # 8000f958 <pid_lock>
    80001c8a:	975a                	add	a4,a4,s6
    80001c8c:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001c90:	0000e717          	auipc	a4,0xe
    80001c94:	d0070713          	addi	a4,a4,-768 # 8000f990 <cpus+0x8>
    80001c98:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001c9a:	4c11                	li	s8,4
        c->proc = p;
    80001c9c:	079e                	slli	a5,a5,0x7
    80001c9e:	0000ea17          	auipc	s4,0xe
    80001ca2:	cbaa0a13          	addi	s4,s4,-838 # 8000f958 <pid_lock>
    80001ca6:	9a3e                	add	s4,s4,a5
        found = 1;
    80001ca8:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001caa:	00014997          	auipc	s3,0x14
    80001cae:	ade98993          	addi	s3,s3,-1314 # 80015788 <tickslock>
    80001cb2:	a83d                	j	80001cf0 <scheduler+0x8e>
      release(&p->lock);
    80001cb4:	8526                	mv	a0,s1
    80001cb6:	f4ffe0ef          	jal	ra,80000c04 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001cba:	16848493          	addi	s1,s1,360
    80001cbe:	03348563          	beq	s1,s3,80001ce8 <scheduler+0x86>
      acquire(&p->lock);
    80001cc2:	8526                	mv	a0,s1
    80001cc4:	ea9fe0ef          	jal	ra,80000b6c <acquire>
      if(p->state == RUNNABLE) {
    80001cc8:	4c9c                	lw	a5,24(s1)
    80001cca:	ff2795e3          	bne	a5,s2,80001cb4 <scheduler+0x52>
        p->state = RUNNING;
    80001cce:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001cd2:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001cd6:	06048593          	addi	a1,s1,96
    80001cda:	855a                	mv	a0,s6
    80001cdc:	5b0000ef          	jal	ra,8000228c <swtch>
        c->proc = 0;
    80001ce0:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001ce4:	8ade                	mv	s5,s7
    80001ce6:	b7f9                	j	80001cb4 <scheduler+0x52>
    if(found == 0) {
    80001ce8:	000a9463          	bnez	s5,80001cf0 <scheduler+0x8e>
      asm volatile("wfi");
    80001cec:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001cf0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001cf4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001cf8:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001cfc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001d00:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d02:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001d06:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d08:	0000e497          	auipc	s1,0xe
    80001d0c:	08048493          	addi	s1,s1,128 # 8000fd88 <proc>
      if(p->state == RUNNABLE) {
    80001d10:	490d                	li	s2,3
    80001d12:	bf45                	j	80001cc2 <scheduler+0x60>

0000000080001d14 <sched>:
{
    80001d14:	7179                	addi	sp,sp,-48
    80001d16:	f406                	sd	ra,40(sp)
    80001d18:	f022                	sd	s0,32(sp)
    80001d1a:	ec26                	sd	s1,24(sp)
    80001d1c:	e84a                	sd	s2,16(sp)
    80001d1e:	e44e                	sd	s3,8(sp)
    80001d20:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001d22:	ae3ff0ef          	jal	ra,80001804 <myproc>
    80001d26:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001d28:	ddbfe0ef          	jal	ra,80000b02 <holding>
    80001d2c:	c92d                	beqz	a0,80001d9e <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d2e:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001d30:	2781                	sext.w	a5,a5
    80001d32:	079e                	slli	a5,a5,0x7
    80001d34:	0000e717          	auipc	a4,0xe
    80001d38:	c2470713          	addi	a4,a4,-988 # 8000f958 <pid_lock>
    80001d3c:	97ba                	add	a5,a5,a4
    80001d3e:	0a87a703          	lw	a4,168(a5)
    80001d42:	4785                	li	a5,1
    80001d44:	06f71363          	bne	a4,a5,80001daa <sched+0x96>
  if(p->state == RUNNING)
    80001d48:	4c98                	lw	a4,24(s1)
    80001d4a:	4791                	li	a5,4
    80001d4c:	06f70563          	beq	a4,a5,80001db6 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d50:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001d54:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001d56:	e7b5                	bnez	a5,80001dc2 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d58:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001d5a:	0000e917          	auipc	s2,0xe
    80001d5e:	bfe90913          	addi	s2,s2,-1026 # 8000f958 <pid_lock>
    80001d62:	2781                	sext.w	a5,a5
    80001d64:	079e                	slli	a5,a5,0x7
    80001d66:	97ca                	add	a5,a5,s2
    80001d68:	0ac7a983          	lw	s3,172(a5)
    80001d6c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001d6e:	2781                	sext.w	a5,a5
    80001d70:	079e                	slli	a5,a5,0x7
    80001d72:	0000e597          	auipc	a1,0xe
    80001d76:	c1e58593          	addi	a1,a1,-994 # 8000f990 <cpus+0x8>
    80001d7a:	95be                	add	a1,a1,a5
    80001d7c:	06048513          	addi	a0,s1,96
    80001d80:	50c000ef          	jal	ra,8000228c <swtch>
    80001d84:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001d86:	2781                	sext.w	a5,a5
    80001d88:	079e                	slli	a5,a5,0x7
    80001d8a:	97ca                	add	a5,a5,s2
    80001d8c:	0b37a623          	sw	s3,172(a5)
}
    80001d90:	70a2                	ld	ra,40(sp)
    80001d92:	7402                	ld	s0,32(sp)
    80001d94:	64e2                	ld	s1,24(sp)
    80001d96:	6942                	ld	s2,16(sp)
    80001d98:	69a2                	ld	s3,8(sp)
    80001d9a:	6145                	addi	sp,sp,48
    80001d9c:	8082                	ret
    panic("sched p->lock");
    80001d9e:	00005517          	auipc	a0,0x5
    80001da2:	41250513          	addi	a0,a0,1042 # 800071b0 <digits+0x178>
    80001da6:	9e5fe0ef          	jal	ra,8000078a <panic>
    panic("sched locks");
    80001daa:	00005517          	auipc	a0,0x5
    80001dae:	41650513          	addi	a0,a0,1046 # 800071c0 <digits+0x188>
    80001db2:	9d9fe0ef          	jal	ra,8000078a <panic>
    panic("sched RUNNING");
    80001db6:	00005517          	auipc	a0,0x5
    80001dba:	41a50513          	addi	a0,a0,1050 # 800071d0 <digits+0x198>
    80001dbe:	9cdfe0ef          	jal	ra,8000078a <panic>
    panic("sched interruptible");
    80001dc2:	00005517          	auipc	a0,0x5
    80001dc6:	41e50513          	addi	a0,a0,1054 # 800071e0 <digits+0x1a8>
    80001dca:	9c1fe0ef          	jal	ra,8000078a <panic>

0000000080001dce <yield>:
{
    80001dce:	1101                	addi	sp,sp,-32
    80001dd0:	ec06                	sd	ra,24(sp)
    80001dd2:	e822                	sd	s0,16(sp)
    80001dd4:	e426                	sd	s1,8(sp)
    80001dd6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001dd8:	a2dff0ef          	jal	ra,80001804 <myproc>
    80001ddc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001dde:	d8ffe0ef          	jal	ra,80000b6c <acquire>
  p->state = RUNNABLE;
    80001de2:	478d                	li	a5,3
    80001de4:	cc9c                	sw	a5,24(s1)
  sched();
    80001de6:	f2fff0ef          	jal	ra,80001d14 <sched>
  release(&p->lock);
    80001dea:	8526                	mv	a0,s1
    80001dec:	e19fe0ef          	jal	ra,80000c04 <release>
}
    80001df0:	60e2                	ld	ra,24(sp)
    80001df2:	6442                	ld	s0,16(sp)
    80001df4:	64a2                	ld	s1,8(sp)
    80001df6:	6105                	addi	sp,sp,32
    80001df8:	8082                	ret

0000000080001dfa <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001dfa:	7179                	addi	sp,sp,-48
    80001dfc:	f406                	sd	ra,40(sp)
    80001dfe:	f022                	sd	s0,32(sp)
    80001e00:	ec26                	sd	s1,24(sp)
    80001e02:	e84a                	sd	s2,16(sp)
    80001e04:	e44e                	sd	s3,8(sp)
    80001e06:	1800                	addi	s0,sp,48
    80001e08:	89aa                	mv	s3,a0
    80001e0a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001e0c:	9f9ff0ef          	jal	ra,80001804 <myproc>
    80001e10:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001e12:	d5bfe0ef          	jal	ra,80000b6c <acquire>
  release(lk);
    80001e16:	854a                	mv	a0,s2
    80001e18:	dedfe0ef          	jal	ra,80000c04 <release>

  // Go to sleep.
  p->chan = chan;
    80001e1c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001e20:	4789                	li	a5,2
    80001e22:	cc9c                	sw	a5,24(s1)

  sched();
    80001e24:	ef1ff0ef          	jal	ra,80001d14 <sched>

  // Tidy up.
  p->chan = 0;
    80001e28:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001e2c:	8526                	mv	a0,s1
    80001e2e:	dd7fe0ef          	jal	ra,80000c04 <release>
  acquire(lk);
    80001e32:	854a                	mv	a0,s2
    80001e34:	d39fe0ef          	jal	ra,80000b6c <acquire>
}
    80001e38:	70a2                	ld	ra,40(sp)
    80001e3a:	7402                	ld	s0,32(sp)
    80001e3c:	64e2                	ld	s1,24(sp)
    80001e3e:	6942                	ld	s2,16(sp)
    80001e40:	69a2                	ld	s3,8(sp)
    80001e42:	6145                	addi	sp,sp,48
    80001e44:	8082                	ret

0000000080001e46 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001e46:	7139                	addi	sp,sp,-64
    80001e48:	fc06                	sd	ra,56(sp)
    80001e4a:	f822                	sd	s0,48(sp)
    80001e4c:	f426                	sd	s1,40(sp)
    80001e4e:	f04a                	sd	s2,32(sp)
    80001e50:	ec4e                	sd	s3,24(sp)
    80001e52:	e852                	sd	s4,16(sp)
    80001e54:	e456                	sd	s5,8(sp)
    80001e56:	0080                	addi	s0,sp,64
    80001e58:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001e5a:	0000e497          	auipc	s1,0xe
    80001e5e:	f2e48493          	addi	s1,s1,-210 # 8000fd88 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001e62:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001e64:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e66:	00014917          	auipc	s2,0x14
    80001e6a:	92290913          	addi	s2,s2,-1758 # 80015788 <tickslock>
    80001e6e:	a801                	j	80001e7e <wakeup+0x38>
      }
      release(&p->lock);
    80001e70:	8526                	mv	a0,s1
    80001e72:	d93fe0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e76:	16848493          	addi	s1,s1,360
    80001e7a:	03248263          	beq	s1,s2,80001e9e <wakeup+0x58>
    if(p != myproc()){
    80001e7e:	987ff0ef          	jal	ra,80001804 <myproc>
    80001e82:	fea48ae3          	beq	s1,a0,80001e76 <wakeup+0x30>
      acquire(&p->lock);
    80001e86:	8526                	mv	a0,s1
    80001e88:	ce5fe0ef          	jal	ra,80000b6c <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001e8c:	4c9c                	lw	a5,24(s1)
    80001e8e:	ff3791e3          	bne	a5,s3,80001e70 <wakeup+0x2a>
    80001e92:	709c                	ld	a5,32(s1)
    80001e94:	fd479ee3          	bne	a5,s4,80001e70 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001e98:	0154ac23          	sw	s5,24(s1)
    80001e9c:	bfd1                	j	80001e70 <wakeup+0x2a>
    }
  }
}
    80001e9e:	70e2                	ld	ra,56(sp)
    80001ea0:	7442                	ld	s0,48(sp)
    80001ea2:	74a2                	ld	s1,40(sp)
    80001ea4:	7902                	ld	s2,32(sp)
    80001ea6:	69e2                	ld	s3,24(sp)
    80001ea8:	6a42                	ld	s4,16(sp)
    80001eaa:	6aa2                	ld	s5,8(sp)
    80001eac:	6121                	addi	sp,sp,64
    80001eae:	8082                	ret

0000000080001eb0 <reparent>:
{
    80001eb0:	7179                	addi	sp,sp,-48
    80001eb2:	f406                	sd	ra,40(sp)
    80001eb4:	f022                	sd	s0,32(sp)
    80001eb6:	ec26                	sd	s1,24(sp)
    80001eb8:	e84a                	sd	s2,16(sp)
    80001eba:	e44e                	sd	s3,8(sp)
    80001ebc:	e052                	sd	s4,0(sp)
    80001ebe:	1800                	addi	s0,sp,48
    80001ec0:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ec2:	0000e497          	auipc	s1,0xe
    80001ec6:	ec648493          	addi	s1,s1,-314 # 8000fd88 <proc>
      pp->parent = initproc;
    80001eca:	00006a17          	auipc	s4,0x6
    80001ece:	986a0a13          	addi	s4,s4,-1658 # 80007850 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ed2:	00014997          	auipc	s3,0x14
    80001ed6:	8b698993          	addi	s3,s3,-1866 # 80015788 <tickslock>
    80001eda:	a029                	j	80001ee4 <reparent+0x34>
    80001edc:	16848493          	addi	s1,s1,360
    80001ee0:	01348b63          	beq	s1,s3,80001ef6 <reparent+0x46>
    if(pp->parent == p){
    80001ee4:	7c9c                	ld	a5,56(s1)
    80001ee6:	ff279be3          	bne	a5,s2,80001edc <reparent+0x2c>
      pp->parent = initproc;
    80001eea:	000a3503          	ld	a0,0(s4)
    80001eee:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001ef0:	f57ff0ef          	jal	ra,80001e46 <wakeup>
    80001ef4:	b7e5                	j	80001edc <reparent+0x2c>
}
    80001ef6:	70a2                	ld	ra,40(sp)
    80001ef8:	7402                	ld	s0,32(sp)
    80001efa:	64e2                	ld	s1,24(sp)
    80001efc:	6942                	ld	s2,16(sp)
    80001efe:	69a2                	ld	s3,8(sp)
    80001f00:	6a02                	ld	s4,0(sp)
    80001f02:	6145                	addi	sp,sp,48
    80001f04:	8082                	ret

0000000080001f06 <kexit>:
{
    80001f06:	7179                	addi	sp,sp,-48
    80001f08:	f406                	sd	ra,40(sp)
    80001f0a:	f022                	sd	s0,32(sp)
    80001f0c:	ec26                	sd	s1,24(sp)
    80001f0e:	e84a                	sd	s2,16(sp)
    80001f10:	e44e                	sd	s3,8(sp)
    80001f12:	e052                	sd	s4,0(sp)
    80001f14:	1800                	addi	s0,sp,48
    80001f16:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001f18:	8edff0ef          	jal	ra,80001804 <myproc>
    80001f1c:	89aa                	mv	s3,a0
  if(p == initproc)
    80001f1e:	00006797          	auipc	a5,0x6
    80001f22:	9327b783          	ld	a5,-1742(a5) # 80007850 <initproc>
    80001f26:	0d050493          	addi	s1,a0,208
    80001f2a:	15050913          	addi	s2,a0,336
    80001f2e:	00a79f63          	bne	a5,a0,80001f4c <kexit+0x46>
    panic("init exiting");
    80001f32:	00005517          	auipc	a0,0x5
    80001f36:	2c650513          	addi	a0,a0,710 # 800071f8 <digits+0x1c0>
    80001f3a:	851fe0ef          	jal	ra,8000078a <panic>
      fileclose(f);
    80001f3e:	77f010ef          	jal	ra,80003ebc <fileclose>
      p->ofile[fd] = 0;
    80001f42:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001f46:	04a1                	addi	s1,s1,8
    80001f48:	01248563          	beq	s1,s2,80001f52 <kexit+0x4c>
    if(p->ofile[fd]){
    80001f4c:	6088                	ld	a0,0(s1)
    80001f4e:	f965                	bnez	a0,80001f3e <kexit+0x38>
    80001f50:	bfdd                	j	80001f46 <kexit+0x40>
  begin_op();
    80001f52:	35d010ef          	jal	ra,80003aae <begin_op>
  iput(p->cwd);
    80001f56:	1509b503          	ld	a0,336(s3)
    80001f5a:	2f4010ef          	jal	ra,8000324e <iput>
  end_op();
    80001f5e:	3c1010ef          	jal	ra,80003b1e <end_op>
  p->cwd = 0;
    80001f62:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80001f66:	0000e497          	auipc	s1,0xe
    80001f6a:	a0a48493          	addi	s1,s1,-1526 # 8000f970 <wait_lock>
    80001f6e:	8526                	mv	a0,s1
    80001f70:	bfdfe0ef          	jal	ra,80000b6c <acquire>
  reparent(p);
    80001f74:	854e                	mv	a0,s3
    80001f76:	f3bff0ef          	jal	ra,80001eb0 <reparent>
  wakeup(p->parent);
    80001f7a:	0389b503          	ld	a0,56(s3)
    80001f7e:	ec9ff0ef          	jal	ra,80001e46 <wakeup>
  acquire(&p->lock);
    80001f82:	854e                	mv	a0,s3
    80001f84:	be9fe0ef          	jal	ra,80000b6c <acquire>
  p->xstate = status;
    80001f88:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80001f8c:	4795                	li	a5,5
    80001f8e:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80001f92:	8526                	mv	a0,s1
    80001f94:	c71fe0ef          	jal	ra,80000c04 <release>
  sched();
    80001f98:	d7dff0ef          	jal	ra,80001d14 <sched>
  panic("zombie exit");
    80001f9c:	00005517          	auipc	a0,0x5
    80001fa0:	26c50513          	addi	a0,a0,620 # 80007208 <digits+0x1d0>
    80001fa4:	fe6fe0ef          	jal	ra,8000078a <panic>

0000000080001fa8 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80001fa8:	7179                	addi	sp,sp,-48
    80001faa:	f406                	sd	ra,40(sp)
    80001fac:	f022                	sd	s0,32(sp)
    80001fae:	ec26                	sd	s1,24(sp)
    80001fb0:	e84a                	sd	s2,16(sp)
    80001fb2:	e44e                	sd	s3,8(sp)
    80001fb4:	1800                	addi	s0,sp,48
    80001fb6:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80001fb8:	0000e497          	auipc	s1,0xe
    80001fbc:	dd048493          	addi	s1,s1,-560 # 8000fd88 <proc>
    80001fc0:	00013997          	auipc	s3,0x13
    80001fc4:	7c898993          	addi	s3,s3,1992 # 80015788 <tickslock>
    acquire(&p->lock);
    80001fc8:	8526                	mv	a0,s1
    80001fca:	ba3fe0ef          	jal	ra,80000b6c <acquire>
    if(p->pid == pid){
    80001fce:	589c                	lw	a5,48(s1)
    80001fd0:	01278b63          	beq	a5,s2,80001fe6 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80001fd4:	8526                	mv	a0,s1
    80001fd6:	c2ffe0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80001fda:	16848493          	addi	s1,s1,360
    80001fde:	ff3495e3          	bne	s1,s3,80001fc8 <kkill+0x20>
  }
  return -1;
    80001fe2:	557d                	li	a0,-1
    80001fe4:	a819                	j	80001ffa <kkill+0x52>
      p->killed = 1;
    80001fe6:	4785                	li	a5,1
    80001fe8:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80001fea:	4c98                	lw	a4,24(s1)
    80001fec:	4789                	li	a5,2
    80001fee:	00f70d63          	beq	a4,a5,80002008 <kkill+0x60>
      release(&p->lock);
    80001ff2:	8526                	mv	a0,s1
    80001ff4:	c11fe0ef          	jal	ra,80000c04 <release>
      return 0;
    80001ff8:	4501                	li	a0,0
}
    80001ffa:	70a2                	ld	ra,40(sp)
    80001ffc:	7402                	ld	s0,32(sp)
    80001ffe:	64e2                	ld	s1,24(sp)
    80002000:	6942                	ld	s2,16(sp)
    80002002:	69a2                	ld	s3,8(sp)
    80002004:	6145                	addi	sp,sp,48
    80002006:	8082                	ret
        p->state = RUNNABLE;
    80002008:	478d                	li	a5,3
    8000200a:	cc9c                	sw	a5,24(s1)
    8000200c:	b7dd                	j	80001ff2 <kkill+0x4a>

000000008000200e <setkilled>:

void
setkilled(struct proc *p)
{
    8000200e:	1101                	addi	sp,sp,-32
    80002010:	ec06                	sd	ra,24(sp)
    80002012:	e822                	sd	s0,16(sp)
    80002014:	e426                	sd	s1,8(sp)
    80002016:	1000                	addi	s0,sp,32
    80002018:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000201a:	b53fe0ef          	jal	ra,80000b6c <acquire>
  p->killed = 1;
    8000201e:	4785                	li	a5,1
    80002020:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002022:	8526                	mv	a0,s1
    80002024:	be1fe0ef          	jal	ra,80000c04 <release>
}
    80002028:	60e2                	ld	ra,24(sp)
    8000202a:	6442                	ld	s0,16(sp)
    8000202c:	64a2                	ld	s1,8(sp)
    8000202e:	6105                	addi	sp,sp,32
    80002030:	8082                	ret

0000000080002032 <killed>:

int
killed(struct proc *p)
{
    80002032:	1101                	addi	sp,sp,-32
    80002034:	ec06                	sd	ra,24(sp)
    80002036:	e822                	sd	s0,16(sp)
    80002038:	e426                	sd	s1,8(sp)
    8000203a:	e04a                	sd	s2,0(sp)
    8000203c:	1000                	addi	s0,sp,32
    8000203e:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002040:	b2dfe0ef          	jal	ra,80000b6c <acquire>
  k = p->killed;
    80002044:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002048:	8526                	mv	a0,s1
    8000204a:	bbbfe0ef          	jal	ra,80000c04 <release>
  return k;
}
    8000204e:	854a                	mv	a0,s2
    80002050:	60e2                	ld	ra,24(sp)
    80002052:	6442                	ld	s0,16(sp)
    80002054:	64a2                	ld	s1,8(sp)
    80002056:	6902                	ld	s2,0(sp)
    80002058:	6105                	addi	sp,sp,32
    8000205a:	8082                	ret

000000008000205c <kwait>:
{
    8000205c:	715d                	addi	sp,sp,-80
    8000205e:	e486                	sd	ra,72(sp)
    80002060:	e0a2                	sd	s0,64(sp)
    80002062:	fc26                	sd	s1,56(sp)
    80002064:	f84a                	sd	s2,48(sp)
    80002066:	f44e                	sd	s3,40(sp)
    80002068:	f052                	sd	s4,32(sp)
    8000206a:	ec56                	sd	s5,24(sp)
    8000206c:	e85a                	sd	s6,16(sp)
    8000206e:	e45e                	sd	s7,8(sp)
    80002070:	e062                	sd	s8,0(sp)
    80002072:	0880                	addi	s0,sp,80
    80002074:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002076:	f8eff0ef          	jal	ra,80001804 <myproc>
    8000207a:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000207c:	0000e517          	auipc	a0,0xe
    80002080:	8f450513          	addi	a0,a0,-1804 # 8000f970 <wait_lock>
    80002084:	ae9fe0ef          	jal	ra,80000b6c <acquire>
    havekids = 0;
    80002088:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000208a:	4a15                	li	s4,5
        havekids = 1;
    8000208c:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000208e:	00013997          	auipc	s3,0x13
    80002092:	6fa98993          	addi	s3,s3,1786 # 80015788 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002096:	0000ec17          	auipc	s8,0xe
    8000209a:	8dac0c13          	addi	s8,s8,-1830 # 8000f970 <wait_lock>
    havekids = 0;
    8000209e:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800020a0:	0000e497          	auipc	s1,0xe
    800020a4:	ce848493          	addi	s1,s1,-792 # 8000fd88 <proc>
    800020a8:	a899                	j	800020fe <kwait+0xa2>
          pid = pp->pid;
    800020aa:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800020ae:	000b0c63          	beqz	s6,800020c6 <kwait+0x6a>
    800020b2:	4691                	li	a3,4
    800020b4:	02c48613          	addi	a2,s1,44
    800020b8:	85da                	mv	a1,s6
    800020ba:	05093503          	ld	a0,80(s2)
    800020be:	c94ff0ef          	jal	ra,80001552 <copyout>
    800020c2:	00054f63          	bltz	a0,800020e0 <kwait+0x84>
          freeproc(pp);
    800020c6:	8526                	mv	a0,s1
    800020c8:	90dff0ef          	jal	ra,800019d4 <freeproc>
          release(&pp->lock);
    800020cc:	8526                	mv	a0,s1
    800020ce:	b37fe0ef          	jal	ra,80000c04 <release>
          release(&wait_lock);
    800020d2:	0000e517          	auipc	a0,0xe
    800020d6:	89e50513          	addi	a0,a0,-1890 # 8000f970 <wait_lock>
    800020da:	b2bfe0ef          	jal	ra,80000c04 <release>
          return pid;
    800020de:	a891                	j	80002132 <kwait+0xd6>
            release(&pp->lock);
    800020e0:	8526                	mv	a0,s1
    800020e2:	b23fe0ef          	jal	ra,80000c04 <release>
            release(&wait_lock);
    800020e6:	0000e517          	auipc	a0,0xe
    800020ea:	88a50513          	addi	a0,a0,-1910 # 8000f970 <wait_lock>
    800020ee:	b17fe0ef          	jal	ra,80000c04 <release>
            return -1;
    800020f2:	59fd                	li	s3,-1
    800020f4:	a83d                	j	80002132 <kwait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800020f6:	16848493          	addi	s1,s1,360
    800020fa:	03348063          	beq	s1,s3,8000211a <kwait+0xbe>
      if(pp->parent == p){
    800020fe:	7c9c                	ld	a5,56(s1)
    80002100:	ff279be3          	bne	a5,s2,800020f6 <kwait+0x9a>
        acquire(&pp->lock);
    80002104:	8526                	mv	a0,s1
    80002106:	a67fe0ef          	jal	ra,80000b6c <acquire>
        if(pp->state == ZOMBIE){
    8000210a:	4c9c                	lw	a5,24(s1)
    8000210c:	f9478fe3          	beq	a5,s4,800020aa <kwait+0x4e>
        release(&pp->lock);
    80002110:	8526                	mv	a0,s1
    80002112:	af3fe0ef          	jal	ra,80000c04 <release>
        havekids = 1;
    80002116:	8756                	mv	a4,s5
    80002118:	bff9                	j	800020f6 <kwait+0x9a>
    if(!havekids || killed(p)){
    8000211a:	c709                	beqz	a4,80002124 <kwait+0xc8>
    8000211c:	854a                	mv	a0,s2
    8000211e:	f15ff0ef          	jal	ra,80002032 <killed>
    80002122:	c50d                	beqz	a0,8000214c <kwait+0xf0>
      release(&wait_lock);
    80002124:	0000e517          	auipc	a0,0xe
    80002128:	84c50513          	addi	a0,a0,-1972 # 8000f970 <wait_lock>
    8000212c:	ad9fe0ef          	jal	ra,80000c04 <release>
      return -1;
    80002130:	59fd                	li	s3,-1
}
    80002132:	854e                	mv	a0,s3
    80002134:	60a6                	ld	ra,72(sp)
    80002136:	6406                	ld	s0,64(sp)
    80002138:	74e2                	ld	s1,56(sp)
    8000213a:	7942                	ld	s2,48(sp)
    8000213c:	79a2                	ld	s3,40(sp)
    8000213e:	7a02                	ld	s4,32(sp)
    80002140:	6ae2                	ld	s5,24(sp)
    80002142:	6b42                	ld	s6,16(sp)
    80002144:	6ba2                	ld	s7,8(sp)
    80002146:	6c02                	ld	s8,0(sp)
    80002148:	6161                	addi	sp,sp,80
    8000214a:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000214c:	85e2                	mv	a1,s8
    8000214e:	854a                	mv	a0,s2
    80002150:	cabff0ef          	jal	ra,80001dfa <sleep>
    havekids = 0;
    80002154:	b7a9                	j	8000209e <kwait+0x42>

0000000080002156 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002156:	7179                	addi	sp,sp,-48
    80002158:	f406                	sd	ra,40(sp)
    8000215a:	f022                	sd	s0,32(sp)
    8000215c:	ec26                	sd	s1,24(sp)
    8000215e:	e84a                	sd	s2,16(sp)
    80002160:	e44e                	sd	s3,8(sp)
    80002162:	e052                	sd	s4,0(sp)
    80002164:	1800                	addi	s0,sp,48
    80002166:	84aa                	mv	s1,a0
    80002168:	892e                	mv	s2,a1
    8000216a:	89b2                	mv	s3,a2
    8000216c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000216e:	e96ff0ef          	jal	ra,80001804 <myproc>
  if(user_dst){
    80002172:	cc99                	beqz	s1,80002190 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002174:	86d2                	mv	a3,s4
    80002176:	864e                	mv	a2,s3
    80002178:	85ca                	mv	a1,s2
    8000217a:	6928                	ld	a0,80(a0)
    8000217c:	bd6ff0ef          	jal	ra,80001552 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002180:	70a2                	ld	ra,40(sp)
    80002182:	7402                	ld	s0,32(sp)
    80002184:	64e2                	ld	s1,24(sp)
    80002186:	6942                	ld	s2,16(sp)
    80002188:	69a2                	ld	s3,8(sp)
    8000218a:	6a02                	ld	s4,0(sp)
    8000218c:	6145                	addi	sp,sp,48
    8000218e:	8082                	ret
    memmove((char *)dst, src, len);
    80002190:	000a061b          	sext.w	a2,s4
    80002194:	85ce                	mv	a1,s3
    80002196:	854a                	mv	a0,s2
    80002198:	b05fe0ef          	jal	ra,80000c9c <memmove>
    return 0;
    8000219c:	8526                	mv	a0,s1
    8000219e:	b7cd                	j	80002180 <either_copyout+0x2a>

00000000800021a0 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800021a0:	7179                	addi	sp,sp,-48
    800021a2:	f406                	sd	ra,40(sp)
    800021a4:	f022                	sd	s0,32(sp)
    800021a6:	ec26                	sd	s1,24(sp)
    800021a8:	e84a                	sd	s2,16(sp)
    800021aa:	e44e                	sd	s3,8(sp)
    800021ac:	e052                	sd	s4,0(sp)
    800021ae:	1800                	addi	s0,sp,48
    800021b0:	892a                	mv	s2,a0
    800021b2:	84ae                	mv	s1,a1
    800021b4:	89b2                	mv	s3,a2
    800021b6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800021b8:	e4cff0ef          	jal	ra,80001804 <myproc>
  if(user_src){
    800021bc:	cc99                	beqz	s1,800021da <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800021be:	86d2                	mv	a3,s4
    800021c0:	864e                	mv	a2,s3
    800021c2:	85ca                	mv	a1,s2
    800021c4:	6928                	ld	a0,80(a0)
    800021c6:	c52ff0ef          	jal	ra,80001618 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800021ca:	70a2                	ld	ra,40(sp)
    800021cc:	7402                	ld	s0,32(sp)
    800021ce:	64e2                	ld	s1,24(sp)
    800021d0:	6942                	ld	s2,16(sp)
    800021d2:	69a2                	ld	s3,8(sp)
    800021d4:	6a02                	ld	s4,0(sp)
    800021d6:	6145                	addi	sp,sp,48
    800021d8:	8082                	ret
    memmove(dst, (char*)src, len);
    800021da:	000a061b          	sext.w	a2,s4
    800021de:	85ce                	mv	a1,s3
    800021e0:	854a                	mv	a0,s2
    800021e2:	abbfe0ef          	jal	ra,80000c9c <memmove>
    return 0;
    800021e6:	8526                	mv	a0,s1
    800021e8:	b7cd                	j	800021ca <either_copyin+0x2a>

00000000800021ea <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800021ea:	715d                	addi	sp,sp,-80
    800021ec:	e486                	sd	ra,72(sp)
    800021ee:	e0a2                	sd	s0,64(sp)
    800021f0:	fc26                	sd	s1,56(sp)
    800021f2:	f84a                	sd	s2,48(sp)
    800021f4:	f44e                	sd	s3,40(sp)
    800021f6:	f052                	sd	s4,32(sp)
    800021f8:	ec56                	sd	s5,24(sp)
    800021fa:	e85a                	sd	s6,16(sp)
    800021fc:	e45e                	sd	s7,8(sp)
    800021fe:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002200:	00005517          	auipc	a0,0x5
    80002204:	ec050513          	addi	a0,a0,-320 # 800070c0 <digits+0x88>
    80002208:	abcfe0ef          	jal	ra,800004c4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000220c:	0000e497          	auipc	s1,0xe
    80002210:	cd448493          	addi	s1,s1,-812 # 8000fee0 <proc+0x158>
    80002214:	00013917          	auipc	s2,0x13
    80002218:	6cc90913          	addi	s2,s2,1740 # 800158e0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000221c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000221e:	00005997          	auipc	s3,0x5
    80002222:	ffa98993          	addi	s3,s3,-6 # 80007218 <digits+0x1e0>
    printf("%d %s %s", p->pid, state, p->name);
    80002226:	00005a97          	auipc	s5,0x5
    8000222a:	ffaa8a93          	addi	s5,s5,-6 # 80007220 <digits+0x1e8>
    printf("\n");
    8000222e:	00005a17          	auipc	s4,0x5
    80002232:	e92a0a13          	addi	s4,s4,-366 # 800070c0 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002236:	00005b97          	auipc	s7,0x5
    8000223a:	02ab8b93          	addi	s7,s7,42 # 80007260 <states.0>
    8000223e:	a829                	j	80002258 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002240:	ed86a583          	lw	a1,-296(a3)
    80002244:	8556                	mv	a0,s5
    80002246:	a7efe0ef          	jal	ra,800004c4 <printf>
    printf("\n");
    8000224a:	8552                	mv	a0,s4
    8000224c:	a78fe0ef          	jal	ra,800004c4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002250:	16848493          	addi	s1,s1,360
    80002254:	03248163          	beq	s1,s2,80002276 <procdump+0x8c>
    if(p->state == UNUSED)
    80002258:	86a6                	mv	a3,s1
    8000225a:	ec04a783          	lw	a5,-320(s1)
    8000225e:	dbed                	beqz	a5,80002250 <procdump+0x66>
      state = "???";
    80002260:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002262:	fcfb6fe3          	bltu	s6,a5,80002240 <procdump+0x56>
    80002266:	1782                	slli	a5,a5,0x20
    80002268:	9381                	srli	a5,a5,0x20
    8000226a:	078e                	slli	a5,a5,0x3
    8000226c:	97de                	add	a5,a5,s7
    8000226e:	6390                	ld	a2,0(a5)
    80002270:	fa61                	bnez	a2,80002240 <procdump+0x56>
      state = "???";
    80002272:	864e                	mv	a2,s3
    80002274:	b7f1                	j	80002240 <procdump+0x56>
  }
}
    80002276:	60a6                	ld	ra,72(sp)
    80002278:	6406                	ld	s0,64(sp)
    8000227a:	74e2                	ld	s1,56(sp)
    8000227c:	7942                	ld	s2,48(sp)
    8000227e:	79a2                	ld	s3,40(sp)
    80002280:	7a02                	ld	s4,32(sp)
    80002282:	6ae2                	ld	s5,24(sp)
    80002284:	6b42                	ld	s6,16(sp)
    80002286:	6ba2                	ld	s7,8(sp)
    80002288:	6161                	addi	sp,sp,80
    8000228a:	8082                	ret

000000008000228c <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    8000228c:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002290:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002294:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002296:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002298:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    8000229c:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800022a0:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800022a4:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800022a8:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800022ac:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800022b0:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800022b4:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800022b8:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800022bc:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800022c0:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800022c4:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800022c8:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800022ca:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800022cc:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800022d0:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800022d4:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800022d8:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800022dc:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800022e0:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800022e4:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800022e8:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800022ec:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800022f0:	0685bd83          	ld	s11,104(a1)
        
        ret
    800022f4:	8082                	ret

00000000800022f6 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800022f6:	1141                	addi	sp,sp,-16
    800022f8:	e406                	sd	ra,8(sp)
    800022fa:	e022                	sd	s0,0(sp)
    800022fc:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800022fe:	00005597          	auipc	a1,0x5
    80002302:	f9258593          	addi	a1,a1,-110 # 80007290 <states.0+0x30>
    80002306:	00013517          	auipc	a0,0x13
    8000230a:	48250513          	addi	a0,a0,1154 # 80015788 <tickslock>
    8000230e:	fdefe0ef          	jal	ra,80000aec <initlock>
}
    80002312:	60a2                	ld	ra,8(sp)
    80002314:	6402                	ld	s0,0(sp)
    80002316:	0141                	addi	sp,sp,16
    80002318:	8082                	ret

000000008000231a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000231a:	1141                	addi	sp,sp,-16
    8000231c:	e422                	sd	s0,8(sp)
    8000231e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002320:	00003797          	auipc	a5,0x3
    80002324:	e5078793          	addi	a5,a5,-432 # 80005170 <kernelvec>
    80002328:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000232c:	6422                	ld	s0,8(sp)
    8000232e:	0141                	addi	sp,sp,16
    80002330:	8082                	ret

0000000080002332 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002332:	1141                	addi	sp,sp,-16
    80002334:	e406                	sd	ra,8(sp)
    80002336:	e022                	sd	s0,0(sp)
    80002338:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000233a:	ccaff0ef          	jal	ra,80001804 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000233e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002342:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002344:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002348:	04000737          	lui	a4,0x4000
    8000234c:	00004797          	auipc	a5,0x4
    80002350:	cb478793          	addi	a5,a5,-844 # 80006000 <_trampoline>
    80002354:	00004697          	auipc	a3,0x4
    80002358:	cac68693          	addi	a3,a3,-852 # 80006000 <_trampoline>
    8000235c:	8f95                	sub	a5,a5,a3
    8000235e:	177d                	addi	a4,a4,-1
    80002360:	0732                	slli	a4,a4,0xc
    80002362:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002364:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002368:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000236a:	18002773          	csrr	a4,satp
    8000236e:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002370:	6d38                	ld	a4,88(a0)
    80002372:	613c                	ld	a5,64(a0)
    80002374:	6685                	lui	a3,0x1
    80002376:	97b6                	add	a5,a5,a3
    80002378:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000237a:	6d3c                	ld	a5,88(a0)
    8000237c:	00000717          	auipc	a4,0x0
    80002380:	0f470713          	addi	a4,a4,244 # 80002470 <usertrap>
    80002384:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002386:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002388:	8712                	mv	a4,tp
    8000238a:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000238c:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002390:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002394:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002398:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000239c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000239e:	6f9c                	ld	a5,24(a5)
    800023a0:	14179073          	csrw	sepc,a5
}
    800023a4:	60a2                	ld	ra,8(sp)
    800023a6:	6402                	ld	s0,0(sp)
    800023a8:	0141                	addi	sp,sp,16
    800023aa:	8082                	ret

00000000800023ac <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800023ac:	1101                	addi	sp,sp,-32
    800023ae:	ec06                	sd	ra,24(sp)
    800023b0:	e822                	sd	s0,16(sp)
    800023b2:	e426                	sd	s1,8(sp)
    800023b4:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800023b6:	c22ff0ef          	jal	ra,800017d8 <cpuid>
    800023ba:	cd19                	beqz	a0,800023d8 <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    800023bc:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800023c0:	000f4737          	lui	a4,0xf4
    800023c4:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800023c8:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800023ca:	14d79073          	csrw	0x14d,a5
}
    800023ce:	60e2                	ld	ra,24(sp)
    800023d0:	6442                	ld	s0,16(sp)
    800023d2:	64a2                	ld	s1,8(sp)
    800023d4:	6105                	addi	sp,sp,32
    800023d6:	8082                	ret
    acquire(&tickslock);
    800023d8:	00013497          	auipc	s1,0x13
    800023dc:	3b048493          	addi	s1,s1,944 # 80015788 <tickslock>
    800023e0:	8526                	mv	a0,s1
    800023e2:	f8afe0ef          	jal	ra,80000b6c <acquire>
    ticks++;
    800023e6:	00005517          	auipc	a0,0x5
    800023ea:	47250513          	addi	a0,a0,1138 # 80007858 <ticks>
    800023ee:	411c                	lw	a5,0(a0)
    800023f0:	2785                	addiw	a5,a5,1
    800023f2:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800023f4:	a53ff0ef          	jal	ra,80001e46 <wakeup>
    release(&tickslock);
    800023f8:	8526                	mv	a0,s1
    800023fa:	80bfe0ef          	jal	ra,80000c04 <release>
    800023fe:	bf7d                	j	800023bc <clockintr+0x10>

0000000080002400 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002400:	1101                	addi	sp,sp,-32
    80002402:	ec06                	sd	ra,24(sp)
    80002404:	e822                	sd	s0,16(sp)
    80002406:	e426                	sd	s1,8(sp)
    80002408:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000240a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    8000240e:	57fd                	li	a5,-1
    80002410:	17fe                	slli	a5,a5,0x3f
    80002412:	07a5                	addi	a5,a5,9
    80002414:	00f70d63          	beq	a4,a5,8000242e <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002418:	57fd                	li	a5,-1
    8000241a:	17fe                	slli	a5,a5,0x3f
    8000241c:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    8000241e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002420:	04f70463          	beq	a4,a5,80002468 <devintr+0x68>
  }
}
    80002424:	60e2                	ld	ra,24(sp)
    80002426:	6442                	ld	s0,16(sp)
    80002428:	64a2                	ld	s1,8(sp)
    8000242a:	6105                	addi	sp,sp,32
    8000242c:	8082                	ret
    int irq = plic_claim();
    8000242e:	5eb020ef          	jal	ra,80005218 <plic_claim>
    80002432:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002434:	47a9                	li	a5,10
    80002436:	02f50363          	beq	a0,a5,8000245c <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    8000243a:	4785                	li	a5,1
    8000243c:	02f50363          	beq	a0,a5,80002462 <devintr+0x62>
    return 1;
    80002440:	4505                	li	a0,1
    } else if(irq){
    80002442:	d0ed                	beqz	s1,80002424 <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80002444:	85a6                	mv	a1,s1
    80002446:	00005517          	auipc	a0,0x5
    8000244a:	e5250513          	addi	a0,a0,-430 # 80007298 <states.0+0x38>
    8000244e:	876fe0ef          	jal	ra,800004c4 <printf>
      plic_complete(irq);
    80002452:	8526                	mv	a0,s1
    80002454:	5e5020ef          	jal	ra,80005238 <plic_complete>
    return 1;
    80002458:	4505                	li	a0,1
    8000245a:	b7e9                	j	80002424 <devintr+0x24>
      uartintr();
    8000245c:	cfcfe0ef          	jal	ra,80000958 <uartintr>
    80002460:	bfcd                	j	80002452 <devintr+0x52>
      virtio_disk_intr();
    80002462:	246030ef          	jal	ra,800056a8 <virtio_disk_intr>
    80002466:	b7f5                	j	80002452 <devintr+0x52>
    clockintr();
    80002468:	f45ff0ef          	jal	ra,800023ac <clockintr>
    return 2;
    8000246c:	4509                	li	a0,2
    8000246e:	bf5d                	j	80002424 <devintr+0x24>

0000000080002470 <usertrap>:
{
    80002470:	1101                	addi	sp,sp,-32
    80002472:	ec06                	sd	ra,24(sp)
    80002474:	e822                	sd	s0,16(sp)
    80002476:	e426                	sd	s1,8(sp)
    80002478:	e04a                	sd	s2,0(sp)
    8000247a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000247c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002480:	1007f793          	andi	a5,a5,256
    80002484:	eba5                	bnez	a5,800024f4 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002486:	00003797          	auipc	a5,0x3
    8000248a:	cea78793          	addi	a5,a5,-790 # 80005170 <kernelvec>
    8000248e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002492:	b72ff0ef          	jal	ra,80001804 <myproc>
    80002496:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002498:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000249a:	14102773          	csrr	a4,sepc
    8000249e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800024a0:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800024a4:	47a1                	li	a5,8
    800024a6:	04f70d63          	beq	a4,a5,80002500 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    800024aa:	f57ff0ef          	jal	ra,80002400 <devintr>
    800024ae:	892a                	mv	s2,a0
    800024b0:	e945                	bnez	a0,80002560 <usertrap+0xf0>
    800024b2:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800024b6:	47bd                	li	a5,15
    800024b8:	08f70863          	beq	a4,a5,80002548 <usertrap+0xd8>
    800024bc:	14202773          	csrr	a4,scause
    800024c0:	47b5                	li	a5,13
    800024c2:	08f70363          	beq	a4,a5,80002548 <usertrap+0xd8>
    800024c6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800024ca:	5890                	lw	a2,48(s1)
    800024cc:	00005517          	auipc	a0,0x5
    800024d0:	e0c50513          	addi	a0,a0,-500 # 800072d8 <states.0+0x78>
    800024d4:	ff1fd0ef          	jal	ra,800004c4 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800024d8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800024dc:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800024e0:	00005517          	auipc	a0,0x5
    800024e4:	e2850513          	addi	a0,a0,-472 # 80007308 <states.0+0xa8>
    800024e8:	fddfd0ef          	jal	ra,800004c4 <printf>
    setkilled(p);
    800024ec:	8526                	mv	a0,s1
    800024ee:	b21ff0ef          	jal	ra,8000200e <setkilled>
    800024f2:	a035                	j	8000251e <usertrap+0xae>
    panic("usertrap: not from user mode");
    800024f4:	00005517          	auipc	a0,0x5
    800024f8:	dc450513          	addi	a0,a0,-572 # 800072b8 <states.0+0x58>
    800024fc:	a8efe0ef          	jal	ra,8000078a <panic>
    if(killed(p))
    80002500:	b33ff0ef          	jal	ra,80002032 <killed>
    80002504:	ed15                	bnez	a0,80002540 <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002506:	6cb8                	ld	a4,88(s1)
    80002508:	6f1c                	ld	a5,24(a4)
    8000250a:	0791                	addi	a5,a5,4
    8000250c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000250e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002512:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002516:	10079073          	csrw	sstatus,a5
    syscall();
    8000251a:	246000ef          	jal	ra,80002760 <syscall>
  if(killed(p))
    8000251e:	8526                	mv	a0,s1
    80002520:	b13ff0ef          	jal	ra,80002032 <killed>
    80002524:	e139                	bnez	a0,8000256a <usertrap+0xfa>
  prepare_return();
    80002526:	e0dff0ef          	jal	ra,80002332 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000252a:	68a8                	ld	a0,80(s1)
    8000252c:	8131                	srli	a0,a0,0xc
    8000252e:	57fd                	li	a5,-1
    80002530:	17fe                	slli	a5,a5,0x3f
    80002532:	8d5d                	or	a0,a0,a5
}
    80002534:	60e2                	ld	ra,24(sp)
    80002536:	6442                	ld	s0,16(sp)
    80002538:	64a2                	ld	s1,8(sp)
    8000253a:	6902                	ld	s2,0(sp)
    8000253c:	6105                	addi	sp,sp,32
    8000253e:	8082                	ret
      kexit(-1);
    80002540:	557d                	li	a0,-1
    80002542:	9c5ff0ef          	jal	ra,80001f06 <kexit>
    80002546:	b7c1                	j	80002506 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002548:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000254c:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002550:	164d                	addi	a2,a2,-13
    80002552:	00163613          	seqz	a2,a2
    80002556:	68a8                	ld	a0,80(s1)
    80002558:	f89fe0ef          	jal	ra,800014e0 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000255c:	f169                	bnez	a0,8000251e <usertrap+0xae>
    8000255e:	b7a5                	j	800024c6 <usertrap+0x56>
  if(killed(p))
    80002560:	8526                	mv	a0,s1
    80002562:	ad1ff0ef          	jal	ra,80002032 <killed>
    80002566:	c511                	beqz	a0,80002572 <usertrap+0x102>
    80002568:	a011                	j	8000256c <usertrap+0xfc>
    8000256a:	4901                	li	s2,0
    kexit(-1);
    8000256c:	557d                	li	a0,-1
    8000256e:	999ff0ef          	jal	ra,80001f06 <kexit>
  if(which_dev == 2)
    80002572:	4789                	li	a5,2
    80002574:	faf919e3          	bne	s2,a5,80002526 <usertrap+0xb6>
    yield();
    80002578:	857ff0ef          	jal	ra,80001dce <yield>
    8000257c:	b76d                	j	80002526 <usertrap+0xb6>

000000008000257e <kerneltrap>:
{
    8000257e:	7179                	addi	sp,sp,-48
    80002580:	f406                	sd	ra,40(sp)
    80002582:	f022                	sd	s0,32(sp)
    80002584:	ec26                	sd	s1,24(sp)
    80002586:	e84a                	sd	s2,16(sp)
    80002588:	e44e                	sd	s3,8(sp)
    8000258a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000258c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002590:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002594:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002598:	1004f793          	andi	a5,s1,256
    8000259c:	c795                	beqz	a5,800025c8 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000259e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800025a2:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800025a4:	eb85                	bnez	a5,800025d4 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    800025a6:	e5bff0ef          	jal	ra,80002400 <devintr>
    800025aa:	c91d                	beqz	a0,800025e0 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    800025ac:	4789                	li	a5,2
    800025ae:	04f50a63          	beq	a0,a5,80002602 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800025b2:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025b6:	10049073          	csrw	sstatus,s1
}
    800025ba:	70a2                	ld	ra,40(sp)
    800025bc:	7402                	ld	s0,32(sp)
    800025be:	64e2                	ld	s1,24(sp)
    800025c0:	6942                	ld	s2,16(sp)
    800025c2:	69a2                	ld	s3,8(sp)
    800025c4:	6145                	addi	sp,sp,48
    800025c6:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800025c8:	00005517          	auipc	a0,0x5
    800025cc:	d6850513          	addi	a0,a0,-664 # 80007330 <states.0+0xd0>
    800025d0:	9bafe0ef          	jal	ra,8000078a <panic>
    panic("kerneltrap: interrupts enabled");
    800025d4:	00005517          	auipc	a0,0x5
    800025d8:	d8450513          	addi	a0,a0,-636 # 80007358 <states.0+0xf8>
    800025dc:	9aefe0ef          	jal	ra,8000078a <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025e0:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800025e4:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800025e8:	85ce                	mv	a1,s3
    800025ea:	00005517          	auipc	a0,0x5
    800025ee:	d8e50513          	addi	a0,a0,-626 # 80007378 <states.0+0x118>
    800025f2:	ed3fd0ef          	jal	ra,800004c4 <printf>
    panic("kerneltrap");
    800025f6:	00005517          	auipc	a0,0x5
    800025fa:	daa50513          	addi	a0,a0,-598 # 800073a0 <states.0+0x140>
    800025fe:	98cfe0ef          	jal	ra,8000078a <panic>
  if(which_dev == 2 && myproc() != 0)
    80002602:	a02ff0ef          	jal	ra,80001804 <myproc>
    80002606:	d555                	beqz	a0,800025b2 <kerneltrap+0x34>
    yield();
    80002608:	fc6ff0ef          	jal	ra,80001dce <yield>
    8000260c:	b75d                	j	800025b2 <kerneltrap+0x34>

000000008000260e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000260e:	1101                	addi	sp,sp,-32
    80002610:	ec06                	sd	ra,24(sp)
    80002612:	e822                	sd	s0,16(sp)
    80002614:	e426                	sd	s1,8(sp)
    80002616:	1000                	addi	s0,sp,32
    80002618:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000261a:	9eaff0ef          	jal	ra,80001804 <myproc>
  switch (n) {
    8000261e:	4795                	li	a5,5
    80002620:	0497e163          	bltu	a5,s1,80002662 <argraw+0x54>
    80002624:	048a                	slli	s1,s1,0x2
    80002626:	00005717          	auipc	a4,0x5
    8000262a:	db270713          	addi	a4,a4,-590 # 800073d8 <states.0+0x178>
    8000262e:	94ba                	add	s1,s1,a4
    80002630:	409c                	lw	a5,0(s1)
    80002632:	97ba                	add	a5,a5,a4
    80002634:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002636:	6d3c                	ld	a5,88(a0)
    80002638:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000263a:	60e2                	ld	ra,24(sp)
    8000263c:	6442                	ld	s0,16(sp)
    8000263e:	64a2                	ld	s1,8(sp)
    80002640:	6105                	addi	sp,sp,32
    80002642:	8082                	ret
    return p->trapframe->a1;
    80002644:	6d3c                	ld	a5,88(a0)
    80002646:	7fa8                	ld	a0,120(a5)
    80002648:	bfcd                	j	8000263a <argraw+0x2c>
    return p->trapframe->a2;
    8000264a:	6d3c                	ld	a5,88(a0)
    8000264c:	63c8                	ld	a0,128(a5)
    8000264e:	b7f5                	j	8000263a <argraw+0x2c>
    return p->trapframe->a3;
    80002650:	6d3c                	ld	a5,88(a0)
    80002652:	67c8                	ld	a0,136(a5)
    80002654:	b7dd                	j	8000263a <argraw+0x2c>
    return p->trapframe->a4;
    80002656:	6d3c                	ld	a5,88(a0)
    80002658:	6bc8                	ld	a0,144(a5)
    8000265a:	b7c5                	j	8000263a <argraw+0x2c>
    return p->trapframe->a5;
    8000265c:	6d3c                	ld	a5,88(a0)
    8000265e:	6fc8                	ld	a0,152(a5)
    80002660:	bfe9                	j	8000263a <argraw+0x2c>
  panic("argraw");
    80002662:	00005517          	auipc	a0,0x5
    80002666:	d4e50513          	addi	a0,a0,-690 # 800073b0 <states.0+0x150>
    8000266a:	920fe0ef          	jal	ra,8000078a <panic>

000000008000266e <fetchaddr>:
{
    8000266e:	1101                	addi	sp,sp,-32
    80002670:	ec06                	sd	ra,24(sp)
    80002672:	e822                	sd	s0,16(sp)
    80002674:	e426                	sd	s1,8(sp)
    80002676:	e04a                	sd	s2,0(sp)
    80002678:	1000                	addi	s0,sp,32
    8000267a:	84aa                	mv	s1,a0
    8000267c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000267e:	986ff0ef          	jal	ra,80001804 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002682:	653c                	ld	a5,72(a0)
    80002684:	02f4f663          	bgeu	s1,a5,800026b0 <fetchaddr+0x42>
    80002688:	00848713          	addi	a4,s1,8
    8000268c:	02e7e463          	bltu	a5,a4,800026b4 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002690:	46a1                	li	a3,8
    80002692:	8626                	mv	a2,s1
    80002694:	85ca                	mv	a1,s2
    80002696:	6928                	ld	a0,80(a0)
    80002698:	f81fe0ef          	jal	ra,80001618 <copyin>
    8000269c:	00a03533          	snez	a0,a0
    800026a0:	40a00533          	neg	a0,a0
}
    800026a4:	60e2                	ld	ra,24(sp)
    800026a6:	6442                	ld	s0,16(sp)
    800026a8:	64a2                	ld	s1,8(sp)
    800026aa:	6902                	ld	s2,0(sp)
    800026ac:	6105                	addi	sp,sp,32
    800026ae:	8082                	ret
    return -1;
    800026b0:	557d                	li	a0,-1
    800026b2:	bfcd                	j	800026a4 <fetchaddr+0x36>
    800026b4:	557d                	li	a0,-1
    800026b6:	b7fd                	j	800026a4 <fetchaddr+0x36>

00000000800026b8 <fetchstr>:
{
    800026b8:	7179                	addi	sp,sp,-48
    800026ba:	f406                	sd	ra,40(sp)
    800026bc:	f022                	sd	s0,32(sp)
    800026be:	ec26                	sd	s1,24(sp)
    800026c0:	e84a                	sd	s2,16(sp)
    800026c2:	e44e                	sd	s3,8(sp)
    800026c4:	1800                	addi	s0,sp,48
    800026c6:	892a                	mv	s2,a0
    800026c8:	84ae                	mv	s1,a1
    800026ca:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800026cc:	938ff0ef          	jal	ra,80001804 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800026d0:	86ce                	mv	a3,s3
    800026d2:	864a                	mv	a2,s2
    800026d4:	85a6                	mv	a1,s1
    800026d6:	6928                	ld	a0,80(a0)
    800026d8:	d39fe0ef          	jal	ra,80001410 <copyinstr>
    800026dc:	00054c63          	bltz	a0,800026f4 <fetchstr+0x3c>
  return strlen(buf);
    800026e0:	8526                	mv	a0,s1
    800026e2:	ed6fe0ef          	jal	ra,80000db8 <strlen>
}
    800026e6:	70a2                	ld	ra,40(sp)
    800026e8:	7402                	ld	s0,32(sp)
    800026ea:	64e2                	ld	s1,24(sp)
    800026ec:	6942                	ld	s2,16(sp)
    800026ee:	69a2                	ld	s3,8(sp)
    800026f0:	6145                	addi	sp,sp,48
    800026f2:	8082                	ret
    return -1;
    800026f4:	557d                	li	a0,-1
    800026f6:	bfc5                	j	800026e6 <fetchstr+0x2e>

00000000800026f8 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800026f8:	1101                	addi	sp,sp,-32
    800026fa:	ec06                	sd	ra,24(sp)
    800026fc:	e822                	sd	s0,16(sp)
    800026fe:	e426                	sd	s1,8(sp)
    80002700:	1000                	addi	s0,sp,32
    80002702:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002704:	f0bff0ef          	jal	ra,8000260e <argraw>
    80002708:	c088                	sw	a0,0(s1)
}
    8000270a:	60e2                	ld	ra,24(sp)
    8000270c:	6442                	ld	s0,16(sp)
    8000270e:	64a2                	ld	s1,8(sp)
    80002710:	6105                	addi	sp,sp,32
    80002712:	8082                	ret

0000000080002714 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002714:	1101                	addi	sp,sp,-32
    80002716:	ec06                	sd	ra,24(sp)
    80002718:	e822                	sd	s0,16(sp)
    8000271a:	e426                	sd	s1,8(sp)
    8000271c:	1000                	addi	s0,sp,32
    8000271e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002720:	eefff0ef          	jal	ra,8000260e <argraw>
    80002724:	e088                	sd	a0,0(s1)
}
    80002726:	60e2                	ld	ra,24(sp)
    80002728:	6442                	ld	s0,16(sp)
    8000272a:	64a2                	ld	s1,8(sp)
    8000272c:	6105                	addi	sp,sp,32
    8000272e:	8082                	ret

0000000080002730 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002730:	7179                	addi	sp,sp,-48
    80002732:	f406                	sd	ra,40(sp)
    80002734:	f022                	sd	s0,32(sp)
    80002736:	ec26                	sd	s1,24(sp)
    80002738:	e84a                	sd	s2,16(sp)
    8000273a:	1800                	addi	s0,sp,48
    8000273c:	84ae                	mv	s1,a1
    8000273e:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002740:	fd840593          	addi	a1,s0,-40
    80002744:	fd1ff0ef          	jal	ra,80002714 <argaddr>
  return fetchstr(addr, buf, max);
    80002748:	864a                	mv	a2,s2
    8000274a:	85a6                	mv	a1,s1
    8000274c:	fd843503          	ld	a0,-40(s0)
    80002750:	f69ff0ef          	jal	ra,800026b8 <fetchstr>
}
    80002754:	70a2                	ld	ra,40(sp)
    80002756:	7402                	ld	s0,32(sp)
    80002758:	64e2                	ld	s1,24(sp)
    8000275a:	6942                	ld	s2,16(sp)
    8000275c:	6145                	addi	sp,sp,48
    8000275e:	8082                	ret

0000000080002760 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002760:	1101                	addi	sp,sp,-32
    80002762:	ec06                	sd	ra,24(sp)
    80002764:	e822                	sd	s0,16(sp)
    80002766:	e426                	sd	s1,8(sp)
    80002768:	e04a                	sd	s2,0(sp)
    8000276a:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000276c:	898ff0ef          	jal	ra,80001804 <myproc>
    80002770:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002772:	05853903          	ld	s2,88(a0)
    80002776:	0a893783          	ld	a5,168(s2)
    8000277a:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000277e:	37fd                	addiw	a5,a5,-1
    80002780:	4751                	li	a4,20
    80002782:	00f76f63          	bltu	a4,a5,800027a0 <syscall+0x40>
    80002786:	00369713          	slli	a4,a3,0x3
    8000278a:	00005797          	auipc	a5,0x5
    8000278e:	c6678793          	addi	a5,a5,-922 # 800073f0 <syscalls>
    80002792:	97ba                	add	a5,a5,a4
    80002794:	639c                	ld	a5,0(a5)
    80002796:	c789                	beqz	a5,800027a0 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002798:	9782                	jalr	a5
    8000279a:	06a93823          	sd	a0,112(s2)
    8000279e:	a829                	j	800027b8 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800027a0:	15848613          	addi	a2,s1,344
    800027a4:	588c                	lw	a1,48(s1)
    800027a6:	00005517          	auipc	a0,0x5
    800027aa:	c1250513          	addi	a0,a0,-1006 # 800073b8 <states.0+0x158>
    800027ae:	d17fd0ef          	jal	ra,800004c4 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800027b2:	6cbc                	ld	a5,88(s1)
    800027b4:	577d                	li	a4,-1
    800027b6:	fbb8                	sd	a4,112(a5)
  }
}
    800027b8:	60e2                	ld	ra,24(sp)
    800027ba:	6442                	ld	s0,16(sp)
    800027bc:	64a2                	ld	s1,8(sp)
    800027be:	6902                	ld	s2,0(sp)
    800027c0:	6105                	addi	sp,sp,32
    800027c2:	8082                	ret

00000000800027c4 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    800027c4:	1101                	addi	sp,sp,-32
    800027c6:	ec06                	sd	ra,24(sp)
    800027c8:	e822                	sd	s0,16(sp)
    800027ca:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800027cc:	fec40593          	addi	a1,s0,-20
    800027d0:	4501                	li	a0,0
    800027d2:	f27ff0ef          	jal	ra,800026f8 <argint>
  kexit(n);
    800027d6:	fec42503          	lw	a0,-20(s0)
    800027da:	f2cff0ef          	jal	ra,80001f06 <kexit>
  return 0;  // not reached
}
    800027de:	4501                	li	a0,0
    800027e0:	60e2                	ld	ra,24(sp)
    800027e2:	6442                	ld	s0,16(sp)
    800027e4:	6105                	addi	sp,sp,32
    800027e6:	8082                	ret

00000000800027e8 <sys_getpid>:

uint64
sys_getpid(void)
{
    800027e8:	1141                	addi	sp,sp,-16
    800027ea:	e406                	sd	ra,8(sp)
    800027ec:	e022                	sd	s0,0(sp)
    800027ee:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800027f0:	814ff0ef          	jal	ra,80001804 <myproc>
}
    800027f4:	5908                	lw	a0,48(a0)
    800027f6:	60a2                	ld	ra,8(sp)
    800027f8:	6402                	ld	s0,0(sp)
    800027fa:	0141                	addi	sp,sp,16
    800027fc:	8082                	ret

00000000800027fe <sys_fork>:

uint64
sys_fork(void)
{
    800027fe:	1141                	addi	sp,sp,-16
    80002800:	e406                	sd	ra,8(sp)
    80002802:	e022                	sd	s0,0(sp)
    80002804:	0800                	addi	s0,sp,16
  return kfork();
    80002806:	b50ff0ef          	jal	ra,80001b56 <kfork>
}
    8000280a:	60a2                	ld	ra,8(sp)
    8000280c:	6402                	ld	s0,0(sp)
    8000280e:	0141                	addi	sp,sp,16
    80002810:	8082                	ret

0000000080002812 <sys_wait>:

uint64
sys_wait(void)
{
    80002812:	1101                	addi	sp,sp,-32
    80002814:	ec06                	sd	ra,24(sp)
    80002816:	e822                	sd	s0,16(sp)
    80002818:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    8000281a:	fe840593          	addi	a1,s0,-24
    8000281e:	4501                	li	a0,0
    80002820:	ef5ff0ef          	jal	ra,80002714 <argaddr>
  return kwait(p);
    80002824:	fe843503          	ld	a0,-24(s0)
    80002828:	835ff0ef          	jal	ra,8000205c <kwait>
}
    8000282c:	60e2                	ld	ra,24(sp)
    8000282e:	6442                	ld	s0,16(sp)
    80002830:	6105                	addi	sp,sp,32
    80002832:	8082                	ret

0000000080002834 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002834:	7179                	addi	sp,sp,-48
    80002836:	f406                	sd	ra,40(sp)
    80002838:	f022                	sd	s0,32(sp)
    8000283a:	ec26                	sd	s1,24(sp)
    8000283c:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    8000283e:	fd840593          	addi	a1,s0,-40
    80002842:	4501                	li	a0,0
    80002844:	eb5ff0ef          	jal	ra,800026f8 <argint>
  argint(1, &t);
    80002848:	fdc40593          	addi	a1,s0,-36
    8000284c:	4505                	li	a0,1
    8000284e:	eabff0ef          	jal	ra,800026f8 <argint>
  addr = myproc()->sz;
    80002852:	fb3fe0ef          	jal	ra,80001804 <myproc>
    80002856:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002858:	fdc42703          	lw	a4,-36(s0)
    8000285c:	4785                	li	a5,1
    8000285e:	02f70163          	beq	a4,a5,80002880 <sys_sbrk+0x4c>
    80002862:	fd842783          	lw	a5,-40(s0)
    80002866:	0007cd63          	bltz	a5,80002880 <sys_sbrk+0x4c>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    8000286a:	97a6                	add	a5,a5,s1
    8000286c:	0297e863          	bltu	a5,s1,8000289c <sys_sbrk+0x68>
      return -1;
    myproc()->sz += n;
    80002870:	f95fe0ef          	jal	ra,80001804 <myproc>
    80002874:	fd842703          	lw	a4,-40(s0)
    80002878:	653c                	ld	a5,72(a0)
    8000287a:	97ba                	add	a5,a5,a4
    8000287c:	e53c                	sd	a5,72(a0)
    8000287e:	a039                	j	8000288c <sys_sbrk+0x58>
    if(growproc(n) < 0) {
    80002880:	fd842503          	lw	a0,-40(s0)
    80002884:	a82ff0ef          	jal	ra,80001b06 <growproc>
    80002888:	00054863          	bltz	a0,80002898 <sys_sbrk+0x64>
  }
  return addr;
}
    8000288c:	8526                	mv	a0,s1
    8000288e:	70a2                	ld	ra,40(sp)
    80002890:	7402                	ld	s0,32(sp)
    80002892:	64e2                	ld	s1,24(sp)
    80002894:	6145                	addi	sp,sp,48
    80002896:	8082                	ret
      return -1;
    80002898:	54fd                	li	s1,-1
    8000289a:	bfcd                	j	8000288c <sys_sbrk+0x58>
      return -1;
    8000289c:	54fd                	li	s1,-1
    8000289e:	b7fd                	j	8000288c <sys_sbrk+0x58>

00000000800028a0 <sys_pause>:

uint64
sys_pause(void)
{
    800028a0:	7139                	addi	sp,sp,-64
    800028a2:	fc06                	sd	ra,56(sp)
    800028a4:	f822                	sd	s0,48(sp)
    800028a6:	f426                	sd	s1,40(sp)
    800028a8:	f04a                	sd	s2,32(sp)
    800028aa:	ec4e                	sd	s3,24(sp)
    800028ac:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800028ae:	fcc40593          	addi	a1,s0,-52
    800028b2:	4501                	li	a0,0
    800028b4:	e45ff0ef          	jal	ra,800026f8 <argint>
  if(n < 0)
    800028b8:	fcc42783          	lw	a5,-52(s0)
    800028bc:	0607c563          	bltz	a5,80002926 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    800028c0:	00013517          	auipc	a0,0x13
    800028c4:	ec850513          	addi	a0,a0,-312 # 80015788 <tickslock>
    800028c8:	aa4fe0ef          	jal	ra,80000b6c <acquire>
  ticks0 = ticks;
    800028cc:	00005917          	auipc	s2,0x5
    800028d0:	f8c92903          	lw	s2,-116(s2) # 80007858 <ticks>
  while(ticks - ticks0 < n){
    800028d4:	fcc42783          	lw	a5,-52(s0)
    800028d8:	cb8d                	beqz	a5,8000290a <sys_pause+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800028da:	00013997          	auipc	s3,0x13
    800028de:	eae98993          	addi	s3,s3,-338 # 80015788 <tickslock>
    800028e2:	00005497          	auipc	s1,0x5
    800028e6:	f7648493          	addi	s1,s1,-138 # 80007858 <ticks>
    if(killed(myproc())){
    800028ea:	f1bfe0ef          	jal	ra,80001804 <myproc>
    800028ee:	f44ff0ef          	jal	ra,80002032 <killed>
    800028f2:	ed0d                	bnez	a0,8000292c <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    800028f4:	85ce                	mv	a1,s3
    800028f6:	8526                	mv	a0,s1
    800028f8:	d02ff0ef          	jal	ra,80001dfa <sleep>
  while(ticks - ticks0 < n){
    800028fc:	409c                	lw	a5,0(s1)
    800028fe:	412787bb          	subw	a5,a5,s2
    80002902:	fcc42703          	lw	a4,-52(s0)
    80002906:	fee7e2e3          	bltu	a5,a4,800028ea <sys_pause+0x4a>
  }
  release(&tickslock);
    8000290a:	00013517          	auipc	a0,0x13
    8000290e:	e7e50513          	addi	a0,a0,-386 # 80015788 <tickslock>
    80002912:	af2fe0ef          	jal	ra,80000c04 <release>
  return 0;
    80002916:	4501                	li	a0,0
}
    80002918:	70e2                	ld	ra,56(sp)
    8000291a:	7442                	ld	s0,48(sp)
    8000291c:	74a2                	ld	s1,40(sp)
    8000291e:	7902                	ld	s2,32(sp)
    80002920:	69e2                	ld	s3,24(sp)
    80002922:	6121                	addi	sp,sp,64
    80002924:	8082                	ret
    n = 0;
    80002926:	fc042623          	sw	zero,-52(s0)
    8000292a:	bf59                	j	800028c0 <sys_pause+0x20>
      release(&tickslock);
    8000292c:	00013517          	auipc	a0,0x13
    80002930:	e5c50513          	addi	a0,a0,-420 # 80015788 <tickslock>
    80002934:	ad0fe0ef          	jal	ra,80000c04 <release>
      return -1;
    80002938:	557d                	li	a0,-1
    8000293a:	bff9                	j	80002918 <sys_pause+0x78>

000000008000293c <sys_kill>:

uint64
sys_kill(void)
{
    8000293c:	1101                	addi	sp,sp,-32
    8000293e:	ec06                	sd	ra,24(sp)
    80002940:	e822                	sd	s0,16(sp)
    80002942:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002944:	fec40593          	addi	a1,s0,-20
    80002948:	4501                	li	a0,0
    8000294a:	dafff0ef          	jal	ra,800026f8 <argint>
  return kkill(pid);
    8000294e:	fec42503          	lw	a0,-20(s0)
    80002952:	e56ff0ef          	jal	ra,80001fa8 <kkill>
}
    80002956:	60e2                	ld	ra,24(sp)
    80002958:	6442                	ld	s0,16(sp)
    8000295a:	6105                	addi	sp,sp,32
    8000295c:	8082                	ret

000000008000295e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000295e:	1101                	addi	sp,sp,-32
    80002960:	ec06                	sd	ra,24(sp)
    80002962:	e822                	sd	s0,16(sp)
    80002964:	e426                	sd	s1,8(sp)
    80002966:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002968:	00013517          	auipc	a0,0x13
    8000296c:	e2050513          	addi	a0,a0,-480 # 80015788 <tickslock>
    80002970:	9fcfe0ef          	jal	ra,80000b6c <acquire>
  xticks = ticks;
    80002974:	00005497          	auipc	s1,0x5
    80002978:	ee44a483          	lw	s1,-284(s1) # 80007858 <ticks>
  release(&tickslock);
    8000297c:	00013517          	auipc	a0,0x13
    80002980:	e0c50513          	addi	a0,a0,-500 # 80015788 <tickslock>
    80002984:	a80fe0ef          	jal	ra,80000c04 <release>
  return xticks;
}
    80002988:	02049513          	slli	a0,s1,0x20
    8000298c:	9101                	srli	a0,a0,0x20
    8000298e:	60e2                	ld	ra,24(sp)
    80002990:	6442                	ld	s0,16(sp)
    80002992:	64a2                	ld	s1,8(sp)
    80002994:	6105                	addi	sp,sp,32
    80002996:	8082                	ret

0000000080002998 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002998:	7179                	addi	sp,sp,-48
    8000299a:	f406                	sd	ra,40(sp)
    8000299c:	f022                	sd	s0,32(sp)
    8000299e:	ec26                	sd	s1,24(sp)
    800029a0:	e84a                	sd	s2,16(sp)
    800029a2:	e44e                	sd	s3,8(sp)
    800029a4:	e052                	sd	s4,0(sp)
    800029a6:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800029a8:	00005597          	auipc	a1,0x5
    800029ac:	af858593          	addi	a1,a1,-1288 # 800074a0 <syscalls+0xb0>
    800029b0:	00013517          	auipc	a0,0x13
    800029b4:	df050513          	addi	a0,a0,-528 # 800157a0 <bcache>
    800029b8:	934fe0ef          	jal	ra,80000aec <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800029bc:	0001b797          	auipc	a5,0x1b
    800029c0:	de478793          	addi	a5,a5,-540 # 8001d7a0 <bcache+0x8000>
    800029c4:	0001b717          	auipc	a4,0x1b
    800029c8:	04470713          	addi	a4,a4,68 # 8001da08 <bcache+0x8268>
    800029cc:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800029d0:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800029d4:	00013497          	auipc	s1,0x13
    800029d8:	de448493          	addi	s1,s1,-540 # 800157b8 <bcache+0x18>
    b->next = bcache.head.next;
    800029dc:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800029de:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800029e0:	00005a17          	auipc	s4,0x5
    800029e4:	ac8a0a13          	addi	s4,s4,-1336 # 800074a8 <syscalls+0xb8>
    b->next = bcache.head.next;
    800029e8:	2b893783          	ld	a5,696(s2)
    800029ec:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800029ee:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800029f2:	85d2                	mv	a1,s4
    800029f4:	01048513          	addi	a0,s1,16
    800029f8:	2fe010ef          	jal	ra,80003cf6 <initsleeplock>
    bcache.head.next->prev = b;
    800029fc:	2b893783          	ld	a5,696(s2)
    80002a00:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002a02:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002a06:	45848493          	addi	s1,s1,1112
    80002a0a:	fd349fe3          	bne	s1,s3,800029e8 <binit+0x50>
  }
}
    80002a0e:	70a2                	ld	ra,40(sp)
    80002a10:	7402                	ld	s0,32(sp)
    80002a12:	64e2                	ld	s1,24(sp)
    80002a14:	6942                	ld	s2,16(sp)
    80002a16:	69a2                	ld	s3,8(sp)
    80002a18:	6a02                	ld	s4,0(sp)
    80002a1a:	6145                	addi	sp,sp,48
    80002a1c:	8082                	ret

0000000080002a1e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002a1e:	7179                	addi	sp,sp,-48
    80002a20:	f406                	sd	ra,40(sp)
    80002a22:	f022                	sd	s0,32(sp)
    80002a24:	ec26                	sd	s1,24(sp)
    80002a26:	e84a                	sd	s2,16(sp)
    80002a28:	e44e                	sd	s3,8(sp)
    80002a2a:	1800                	addi	s0,sp,48
    80002a2c:	892a                	mv	s2,a0
    80002a2e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002a30:	00013517          	auipc	a0,0x13
    80002a34:	d7050513          	addi	a0,a0,-656 # 800157a0 <bcache>
    80002a38:	934fe0ef          	jal	ra,80000b6c <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002a3c:	0001b497          	auipc	s1,0x1b
    80002a40:	01c4b483          	ld	s1,28(s1) # 8001da58 <bcache+0x82b8>
    80002a44:	0001b797          	auipc	a5,0x1b
    80002a48:	fc478793          	addi	a5,a5,-60 # 8001da08 <bcache+0x8268>
    80002a4c:	02f48b63          	beq	s1,a5,80002a82 <bread+0x64>
    80002a50:	873e                	mv	a4,a5
    80002a52:	a021                	j	80002a5a <bread+0x3c>
    80002a54:	68a4                	ld	s1,80(s1)
    80002a56:	02e48663          	beq	s1,a4,80002a82 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002a5a:	449c                	lw	a5,8(s1)
    80002a5c:	ff279ce3          	bne	a5,s2,80002a54 <bread+0x36>
    80002a60:	44dc                	lw	a5,12(s1)
    80002a62:	ff3799e3          	bne	a5,s3,80002a54 <bread+0x36>
      b->refcnt++;
    80002a66:	40bc                	lw	a5,64(s1)
    80002a68:	2785                	addiw	a5,a5,1
    80002a6a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002a6c:	00013517          	auipc	a0,0x13
    80002a70:	d3450513          	addi	a0,a0,-716 # 800157a0 <bcache>
    80002a74:	990fe0ef          	jal	ra,80000c04 <release>
      acquiresleep(&b->lock);
    80002a78:	01048513          	addi	a0,s1,16
    80002a7c:	2b0010ef          	jal	ra,80003d2c <acquiresleep>
      return b;
    80002a80:	a889                	j	80002ad2 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002a82:	0001b497          	auipc	s1,0x1b
    80002a86:	fce4b483          	ld	s1,-50(s1) # 8001da50 <bcache+0x82b0>
    80002a8a:	0001b797          	auipc	a5,0x1b
    80002a8e:	f7e78793          	addi	a5,a5,-130 # 8001da08 <bcache+0x8268>
    80002a92:	00f48863          	beq	s1,a5,80002aa2 <bread+0x84>
    80002a96:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002a98:	40bc                	lw	a5,64(s1)
    80002a9a:	cb91                	beqz	a5,80002aae <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002a9c:	64a4                	ld	s1,72(s1)
    80002a9e:	fee49de3          	bne	s1,a4,80002a98 <bread+0x7a>
  panic("bget: no buffers");
    80002aa2:	00005517          	auipc	a0,0x5
    80002aa6:	a0e50513          	addi	a0,a0,-1522 # 800074b0 <syscalls+0xc0>
    80002aaa:	ce1fd0ef          	jal	ra,8000078a <panic>
      b->dev = dev;
    80002aae:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002ab2:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002ab6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002aba:	4785                	li	a5,1
    80002abc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002abe:	00013517          	auipc	a0,0x13
    80002ac2:	ce250513          	addi	a0,a0,-798 # 800157a0 <bcache>
    80002ac6:	93efe0ef          	jal	ra,80000c04 <release>
      acquiresleep(&b->lock);
    80002aca:	01048513          	addi	a0,s1,16
    80002ace:	25e010ef          	jal	ra,80003d2c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002ad2:	409c                	lw	a5,0(s1)
    80002ad4:	cb89                	beqz	a5,80002ae6 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002ad6:	8526                	mv	a0,s1
    80002ad8:	70a2                	ld	ra,40(sp)
    80002ada:	7402                	ld	s0,32(sp)
    80002adc:	64e2                	ld	s1,24(sp)
    80002ade:	6942                	ld	s2,16(sp)
    80002ae0:	69a2                	ld	s3,8(sp)
    80002ae2:	6145                	addi	sp,sp,48
    80002ae4:	8082                	ret
    virtio_disk_rw(b, 0);
    80002ae6:	4581                	li	a1,0
    80002ae8:	8526                	mv	a0,s1
    80002aea:	1a3020ef          	jal	ra,8000548c <virtio_disk_rw>
    b->valid = 1;
    80002aee:	4785                	li	a5,1
    80002af0:	c09c                	sw	a5,0(s1)
  return b;
    80002af2:	b7d5                	j	80002ad6 <bread+0xb8>

0000000080002af4 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002af4:	1101                	addi	sp,sp,-32
    80002af6:	ec06                	sd	ra,24(sp)
    80002af8:	e822                	sd	s0,16(sp)
    80002afa:	e426                	sd	s1,8(sp)
    80002afc:	1000                	addi	s0,sp,32
    80002afe:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002b00:	0541                	addi	a0,a0,16
    80002b02:	2a8010ef          	jal	ra,80003daa <holdingsleep>
    80002b06:	c911                	beqz	a0,80002b1a <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002b08:	4585                	li	a1,1
    80002b0a:	8526                	mv	a0,s1
    80002b0c:	181020ef          	jal	ra,8000548c <virtio_disk_rw>
}
    80002b10:	60e2                	ld	ra,24(sp)
    80002b12:	6442                	ld	s0,16(sp)
    80002b14:	64a2                	ld	s1,8(sp)
    80002b16:	6105                	addi	sp,sp,32
    80002b18:	8082                	ret
    panic("bwrite");
    80002b1a:	00005517          	auipc	a0,0x5
    80002b1e:	9ae50513          	addi	a0,a0,-1618 # 800074c8 <syscalls+0xd8>
    80002b22:	c69fd0ef          	jal	ra,8000078a <panic>

0000000080002b26 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002b26:	1101                	addi	sp,sp,-32
    80002b28:	ec06                	sd	ra,24(sp)
    80002b2a:	e822                	sd	s0,16(sp)
    80002b2c:	e426                	sd	s1,8(sp)
    80002b2e:	e04a                	sd	s2,0(sp)
    80002b30:	1000                	addi	s0,sp,32
    80002b32:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002b34:	01050913          	addi	s2,a0,16
    80002b38:	854a                	mv	a0,s2
    80002b3a:	270010ef          	jal	ra,80003daa <holdingsleep>
    80002b3e:	c13d                	beqz	a0,80002ba4 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80002b40:	854a                	mv	a0,s2
    80002b42:	230010ef          	jal	ra,80003d72 <releasesleep>

  acquire(&bcache.lock);
    80002b46:	00013517          	auipc	a0,0x13
    80002b4a:	c5a50513          	addi	a0,a0,-934 # 800157a0 <bcache>
    80002b4e:	81efe0ef          	jal	ra,80000b6c <acquire>
  b->refcnt--;
    80002b52:	40bc                	lw	a5,64(s1)
    80002b54:	37fd                	addiw	a5,a5,-1
    80002b56:	0007871b          	sext.w	a4,a5
    80002b5a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002b5c:	eb05                	bnez	a4,80002b8c <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002b5e:	68bc                	ld	a5,80(s1)
    80002b60:	64b8                	ld	a4,72(s1)
    80002b62:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002b64:	64bc                	ld	a5,72(s1)
    80002b66:	68b8                	ld	a4,80(s1)
    80002b68:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002b6a:	0001b797          	auipc	a5,0x1b
    80002b6e:	c3678793          	addi	a5,a5,-970 # 8001d7a0 <bcache+0x8000>
    80002b72:	2b87b703          	ld	a4,696(a5)
    80002b76:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002b78:	0001b717          	auipc	a4,0x1b
    80002b7c:	e9070713          	addi	a4,a4,-368 # 8001da08 <bcache+0x8268>
    80002b80:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002b82:	2b87b703          	ld	a4,696(a5)
    80002b86:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002b88:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002b8c:	00013517          	auipc	a0,0x13
    80002b90:	c1450513          	addi	a0,a0,-1004 # 800157a0 <bcache>
    80002b94:	870fe0ef          	jal	ra,80000c04 <release>
}
    80002b98:	60e2                	ld	ra,24(sp)
    80002b9a:	6442                	ld	s0,16(sp)
    80002b9c:	64a2                	ld	s1,8(sp)
    80002b9e:	6902                	ld	s2,0(sp)
    80002ba0:	6105                	addi	sp,sp,32
    80002ba2:	8082                	ret
    panic("brelse");
    80002ba4:	00005517          	auipc	a0,0x5
    80002ba8:	92c50513          	addi	a0,a0,-1748 # 800074d0 <syscalls+0xe0>
    80002bac:	bdffd0ef          	jal	ra,8000078a <panic>

0000000080002bb0 <bpin>:

void
bpin(struct buf *b) {
    80002bb0:	1101                	addi	sp,sp,-32
    80002bb2:	ec06                	sd	ra,24(sp)
    80002bb4:	e822                	sd	s0,16(sp)
    80002bb6:	e426                	sd	s1,8(sp)
    80002bb8:	1000                	addi	s0,sp,32
    80002bba:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002bbc:	00013517          	auipc	a0,0x13
    80002bc0:	be450513          	addi	a0,a0,-1052 # 800157a0 <bcache>
    80002bc4:	fa9fd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt++;
    80002bc8:	40bc                	lw	a5,64(s1)
    80002bca:	2785                	addiw	a5,a5,1
    80002bcc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002bce:	00013517          	auipc	a0,0x13
    80002bd2:	bd250513          	addi	a0,a0,-1070 # 800157a0 <bcache>
    80002bd6:	82efe0ef          	jal	ra,80000c04 <release>
}
    80002bda:	60e2                	ld	ra,24(sp)
    80002bdc:	6442                	ld	s0,16(sp)
    80002bde:	64a2                	ld	s1,8(sp)
    80002be0:	6105                	addi	sp,sp,32
    80002be2:	8082                	ret

0000000080002be4 <bunpin>:

void
bunpin(struct buf *b) {
    80002be4:	1101                	addi	sp,sp,-32
    80002be6:	ec06                	sd	ra,24(sp)
    80002be8:	e822                	sd	s0,16(sp)
    80002bea:	e426                	sd	s1,8(sp)
    80002bec:	1000                	addi	s0,sp,32
    80002bee:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002bf0:	00013517          	auipc	a0,0x13
    80002bf4:	bb050513          	addi	a0,a0,-1104 # 800157a0 <bcache>
    80002bf8:	f75fd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt--;
    80002bfc:	40bc                	lw	a5,64(s1)
    80002bfe:	37fd                	addiw	a5,a5,-1
    80002c00:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002c02:	00013517          	auipc	a0,0x13
    80002c06:	b9e50513          	addi	a0,a0,-1122 # 800157a0 <bcache>
    80002c0a:	ffbfd0ef          	jal	ra,80000c04 <release>
}
    80002c0e:	60e2                	ld	ra,24(sp)
    80002c10:	6442                	ld	s0,16(sp)
    80002c12:	64a2                	ld	s1,8(sp)
    80002c14:	6105                	addi	sp,sp,32
    80002c16:	8082                	ret

0000000080002c18 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002c18:	1101                	addi	sp,sp,-32
    80002c1a:	ec06                	sd	ra,24(sp)
    80002c1c:	e822                	sd	s0,16(sp)
    80002c1e:	e426                	sd	s1,8(sp)
    80002c20:	e04a                	sd	s2,0(sp)
    80002c22:	1000                	addi	s0,sp,32
    80002c24:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002c26:	00d5d59b          	srliw	a1,a1,0xd
    80002c2a:	0001b797          	auipc	a5,0x1b
    80002c2e:	2527a783          	lw	a5,594(a5) # 8001de7c <sb+0x1c>
    80002c32:	9dbd                	addw	a1,a1,a5
    80002c34:	debff0ef          	jal	ra,80002a1e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002c38:	0074f713          	andi	a4,s1,7
    80002c3c:	4785                	li	a5,1
    80002c3e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002c42:	14ce                	slli	s1,s1,0x33
    80002c44:	90d9                	srli	s1,s1,0x36
    80002c46:	00950733          	add	a4,a0,s1
    80002c4a:	05874703          	lbu	a4,88(a4)
    80002c4e:	00e7f6b3          	and	a3,a5,a4
    80002c52:	c29d                	beqz	a3,80002c78 <bfree+0x60>
    80002c54:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002c56:	94aa                	add	s1,s1,a0
    80002c58:	fff7c793          	not	a5,a5
    80002c5c:	8ff9                	and	a5,a5,a4
    80002c5e:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80002c62:	7d1000ef          	jal	ra,80003c32 <log_write>
  brelse(bp);
    80002c66:	854a                	mv	a0,s2
    80002c68:	ebfff0ef          	jal	ra,80002b26 <brelse>
}
    80002c6c:	60e2                	ld	ra,24(sp)
    80002c6e:	6442                	ld	s0,16(sp)
    80002c70:	64a2                	ld	s1,8(sp)
    80002c72:	6902                	ld	s2,0(sp)
    80002c74:	6105                	addi	sp,sp,32
    80002c76:	8082                	ret
    panic("freeing free block");
    80002c78:	00005517          	auipc	a0,0x5
    80002c7c:	86050513          	addi	a0,a0,-1952 # 800074d8 <syscalls+0xe8>
    80002c80:	b0bfd0ef          	jal	ra,8000078a <panic>

0000000080002c84 <balloc>:
{
    80002c84:	711d                	addi	sp,sp,-96
    80002c86:	ec86                	sd	ra,88(sp)
    80002c88:	e8a2                	sd	s0,80(sp)
    80002c8a:	e4a6                	sd	s1,72(sp)
    80002c8c:	e0ca                	sd	s2,64(sp)
    80002c8e:	fc4e                	sd	s3,56(sp)
    80002c90:	f852                	sd	s4,48(sp)
    80002c92:	f456                	sd	s5,40(sp)
    80002c94:	f05a                	sd	s6,32(sp)
    80002c96:	ec5e                	sd	s7,24(sp)
    80002c98:	e862                	sd	s8,16(sp)
    80002c9a:	e466                	sd	s9,8(sp)
    80002c9c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002c9e:	0001b797          	auipc	a5,0x1b
    80002ca2:	1c67a783          	lw	a5,454(a5) # 8001de64 <sb+0x4>
    80002ca6:	0e078163          	beqz	a5,80002d88 <balloc+0x104>
    80002caa:	8baa                	mv	s7,a0
    80002cac:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002cae:	0001bb17          	auipc	s6,0x1b
    80002cb2:	1b2b0b13          	addi	s6,s6,434 # 8001de60 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002cb6:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002cb8:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002cba:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002cbc:	6c89                	lui	s9,0x2
    80002cbe:	a0b5                	j	80002d2a <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002cc0:	974a                	add	a4,a4,s2
    80002cc2:	8fd5                	or	a5,a5,a3
    80002cc4:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80002cc8:	854a                	mv	a0,s2
    80002cca:	769000ef          	jal	ra,80003c32 <log_write>
        brelse(bp);
    80002cce:	854a                	mv	a0,s2
    80002cd0:	e57ff0ef          	jal	ra,80002b26 <brelse>
  bp = bread(dev, bno);
    80002cd4:	85a6                	mv	a1,s1
    80002cd6:	855e                	mv	a0,s7
    80002cd8:	d47ff0ef          	jal	ra,80002a1e <bread>
    80002cdc:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002cde:	40000613          	li	a2,1024
    80002ce2:	4581                	li	a1,0
    80002ce4:	05850513          	addi	a0,a0,88
    80002ce8:	f59fd0ef          	jal	ra,80000c40 <memset>
  log_write(bp);
    80002cec:	854a                	mv	a0,s2
    80002cee:	745000ef          	jal	ra,80003c32 <log_write>
  brelse(bp);
    80002cf2:	854a                	mv	a0,s2
    80002cf4:	e33ff0ef          	jal	ra,80002b26 <brelse>
}
    80002cf8:	8526                	mv	a0,s1
    80002cfa:	60e6                	ld	ra,88(sp)
    80002cfc:	6446                	ld	s0,80(sp)
    80002cfe:	64a6                	ld	s1,72(sp)
    80002d00:	6906                	ld	s2,64(sp)
    80002d02:	79e2                	ld	s3,56(sp)
    80002d04:	7a42                	ld	s4,48(sp)
    80002d06:	7aa2                	ld	s5,40(sp)
    80002d08:	7b02                	ld	s6,32(sp)
    80002d0a:	6be2                	ld	s7,24(sp)
    80002d0c:	6c42                	ld	s8,16(sp)
    80002d0e:	6ca2                	ld	s9,8(sp)
    80002d10:	6125                	addi	sp,sp,96
    80002d12:	8082                	ret
    brelse(bp);
    80002d14:	854a                	mv	a0,s2
    80002d16:	e11ff0ef          	jal	ra,80002b26 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002d1a:	015c87bb          	addw	a5,s9,s5
    80002d1e:	00078a9b          	sext.w	s5,a5
    80002d22:	004b2703          	lw	a4,4(s6)
    80002d26:	06eaf163          	bgeu	s5,a4,80002d88 <balloc+0x104>
    bp = bread(dev, BBLOCK(b, sb));
    80002d2a:	41fad79b          	sraiw	a5,s5,0x1f
    80002d2e:	0137d79b          	srliw	a5,a5,0x13
    80002d32:	015787bb          	addw	a5,a5,s5
    80002d36:	40d7d79b          	sraiw	a5,a5,0xd
    80002d3a:	01cb2583          	lw	a1,28(s6)
    80002d3e:	9dbd                	addw	a1,a1,a5
    80002d40:	855e                	mv	a0,s7
    80002d42:	cddff0ef          	jal	ra,80002a1e <bread>
    80002d46:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002d48:	004b2503          	lw	a0,4(s6)
    80002d4c:	000a849b          	sext.w	s1,s5
    80002d50:	8662                	mv	a2,s8
    80002d52:	fca4f1e3          	bgeu	s1,a0,80002d14 <balloc+0x90>
      m = 1 << (bi % 8);
    80002d56:	41f6579b          	sraiw	a5,a2,0x1f
    80002d5a:	01d7d69b          	srliw	a3,a5,0x1d
    80002d5e:	00c6873b          	addw	a4,a3,a2
    80002d62:	00777793          	andi	a5,a4,7
    80002d66:	9f95                	subw	a5,a5,a3
    80002d68:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002d6c:	4037571b          	sraiw	a4,a4,0x3
    80002d70:	00e906b3          	add	a3,s2,a4
    80002d74:	0586c683          	lbu	a3,88(a3) # 1058 <_entry-0x7fffefa8>
    80002d78:	00d7f5b3          	and	a1,a5,a3
    80002d7c:	d1b1                	beqz	a1,80002cc0 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002d7e:	2605                	addiw	a2,a2,1
    80002d80:	2485                	addiw	s1,s1,1
    80002d82:	fd4618e3          	bne	a2,s4,80002d52 <balloc+0xce>
    80002d86:	b779                	j	80002d14 <balloc+0x90>
  printf("balloc: out of blocks\n");
    80002d88:	00004517          	auipc	a0,0x4
    80002d8c:	76850513          	addi	a0,a0,1896 # 800074f0 <syscalls+0x100>
    80002d90:	f34fd0ef          	jal	ra,800004c4 <printf>
  return 0;
    80002d94:	4481                	li	s1,0
    80002d96:	b78d                	j	80002cf8 <balloc+0x74>

0000000080002d98 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002d98:	7179                	addi	sp,sp,-48
    80002d9a:	f406                	sd	ra,40(sp)
    80002d9c:	f022                	sd	s0,32(sp)
    80002d9e:	ec26                	sd	s1,24(sp)
    80002da0:	e84a                	sd	s2,16(sp)
    80002da2:	e44e                	sd	s3,8(sp)
    80002da4:	e052                	sd	s4,0(sp)
    80002da6:	1800                	addi	s0,sp,48
    80002da8:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002daa:	47ad                	li	a5,11
    80002dac:	02b7e563          	bltu	a5,a1,80002dd6 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002db0:	02059493          	slli	s1,a1,0x20
    80002db4:	9081                	srli	s1,s1,0x20
    80002db6:	048a                	slli	s1,s1,0x2
    80002db8:	94aa                	add	s1,s1,a0
    80002dba:	0504a903          	lw	s2,80(s1)
    80002dbe:	06091663          	bnez	s2,80002e2a <bmap+0x92>
      addr = balloc(ip->dev);
    80002dc2:	4108                	lw	a0,0(a0)
    80002dc4:	ec1ff0ef          	jal	ra,80002c84 <balloc>
    80002dc8:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002dcc:	04090f63          	beqz	s2,80002e2a <bmap+0x92>
        return 0;
      ip->addrs[bn] = addr;
    80002dd0:	0524a823          	sw	s2,80(s1)
    80002dd4:	a899                	j	80002e2a <bmap+0x92>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002dd6:	ff45849b          	addiw	s1,a1,-12
    80002dda:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002dde:	0ff00793          	li	a5,255
    80002de2:	06e7eb63          	bltu	a5,a4,80002e58 <bmap+0xc0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002de6:	08052903          	lw	s2,128(a0)
    80002dea:	00091b63          	bnez	s2,80002e00 <bmap+0x68>
      addr = balloc(ip->dev);
    80002dee:	4108                	lw	a0,0(a0)
    80002df0:	e95ff0ef          	jal	ra,80002c84 <balloc>
    80002df4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002df8:	02090963          	beqz	s2,80002e2a <bmap+0x92>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002dfc:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80002e00:	85ca                	mv	a1,s2
    80002e02:	0009a503          	lw	a0,0(s3)
    80002e06:	c19ff0ef          	jal	ra,80002a1e <bread>
    80002e0a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002e0c:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002e10:	02049593          	slli	a1,s1,0x20
    80002e14:	9181                	srli	a1,a1,0x20
    80002e16:	058a                	slli	a1,a1,0x2
    80002e18:	00b784b3          	add	s1,a5,a1
    80002e1c:	0004a903          	lw	s2,0(s1)
    80002e20:	00090e63          	beqz	s2,80002e3c <bmap+0xa4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002e24:	8552                	mv	a0,s4
    80002e26:	d01ff0ef          	jal	ra,80002b26 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80002e2a:	854a                	mv	a0,s2
    80002e2c:	70a2                	ld	ra,40(sp)
    80002e2e:	7402                	ld	s0,32(sp)
    80002e30:	64e2                	ld	s1,24(sp)
    80002e32:	6942                	ld	s2,16(sp)
    80002e34:	69a2                	ld	s3,8(sp)
    80002e36:	6a02                	ld	s4,0(sp)
    80002e38:	6145                	addi	sp,sp,48
    80002e3a:	8082                	ret
      addr = balloc(ip->dev);
    80002e3c:	0009a503          	lw	a0,0(s3)
    80002e40:	e45ff0ef          	jal	ra,80002c84 <balloc>
    80002e44:	0005091b          	sext.w	s2,a0
      if(addr){
    80002e48:	fc090ee3          	beqz	s2,80002e24 <bmap+0x8c>
        a[bn] = addr;
    80002e4c:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002e50:	8552                	mv	a0,s4
    80002e52:	5e1000ef          	jal	ra,80003c32 <log_write>
    80002e56:	b7f9                	j	80002e24 <bmap+0x8c>
  panic("bmap: out of range");
    80002e58:	00004517          	auipc	a0,0x4
    80002e5c:	6b050513          	addi	a0,a0,1712 # 80007508 <syscalls+0x118>
    80002e60:	92bfd0ef          	jal	ra,8000078a <panic>

0000000080002e64 <iget>:
{
    80002e64:	7179                	addi	sp,sp,-48
    80002e66:	f406                	sd	ra,40(sp)
    80002e68:	f022                	sd	s0,32(sp)
    80002e6a:	ec26                	sd	s1,24(sp)
    80002e6c:	e84a                	sd	s2,16(sp)
    80002e6e:	e44e                	sd	s3,8(sp)
    80002e70:	e052                	sd	s4,0(sp)
    80002e72:	1800                	addi	s0,sp,48
    80002e74:	89aa                	mv	s3,a0
    80002e76:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002e78:	0001b517          	auipc	a0,0x1b
    80002e7c:	00850513          	addi	a0,a0,8 # 8001de80 <itable>
    80002e80:	cedfd0ef          	jal	ra,80000b6c <acquire>
  empty = 0;
    80002e84:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002e86:	0001b497          	auipc	s1,0x1b
    80002e8a:	01248493          	addi	s1,s1,18 # 8001de98 <itable+0x18>
    80002e8e:	0001d697          	auipc	a3,0x1d
    80002e92:	a9a68693          	addi	a3,a3,-1382 # 8001f928 <log>
    80002e96:	a039                	j	80002ea4 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002e98:	02090963          	beqz	s2,80002eca <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002e9c:	08848493          	addi	s1,s1,136
    80002ea0:	02d48863          	beq	s1,a3,80002ed0 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002ea4:	449c                	lw	a5,8(s1)
    80002ea6:	fef059e3          	blez	a5,80002e98 <iget+0x34>
    80002eaa:	4098                	lw	a4,0(s1)
    80002eac:	ff3716e3          	bne	a4,s3,80002e98 <iget+0x34>
    80002eb0:	40d8                	lw	a4,4(s1)
    80002eb2:	ff4713e3          	bne	a4,s4,80002e98 <iget+0x34>
      ip->ref++;
    80002eb6:	2785                	addiw	a5,a5,1
    80002eb8:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002eba:	0001b517          	auipc	a0,0x1b
    80002ebe:	fc650513          	addi	a0,a0,-58 # 8001de80 <itable>
    80002ec2:	d43fd0ef          	jal	ra,80000c04 <release>
      return ip;
    80002ec6:	8926                	mv	s2,s1
    80002ec8:	a02d                	j	80002ef2 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002eca:	fbe9                	bnez	a5,80002e9c <iget+0x38>
    80002ecc:	8926                	mv	s2,s1
    80002ece:	b7f9                	j	80002e9c <iget+0x38>
  if(empty == 0)
    80002ed0:	02090a63          	beqz	s2,80002f04 <iget+0xa0>
  ip->dev = dev;
    80002ed4:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002ed8:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002edc:	4785                	li	a5,1
    80002ede:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002ee2:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002ee6:	0001b517          	auipc	a0,0x1b
    80002eea:	f9a50513          	addi	a0,a0,-102 # 8001de80 <itable>
    80002eee:	d17fd0ef          	jal	ra,80000c04 <release>
}
    80002ef2:	854a                	mv	a0,s2
    80002ef4:	70a2                	ld	ra,40(sp)
    80002ef6:	7402                	ld	s0,32(sp)
    80002ef8:	64e2                	ld	s1,24(sp)
    80002efa:	6942                	ld	s2,16(sp)
    80002efc:	69a2                	ld	s3,8(sp)
    80002efe:	6a02                	ld	s4,0(sp)
    80002f00:	6145                	addi	sp,sp,48
    80002f02:	8082                	ret
    panic("iget: no inodes");
    80002f04:	00004517          	auipc	a0,0x4
    80002f08:	61c50513          	addi	a0,a0,1564 # 80007520 <syscalls+0x130>
    80002f0c:	87ffd0ef          	jal	ra,8000078a <panic>

0000000080002f10 <iinit>:
{
    80002f10:	7179                	addi	sp,sp,-48
    80002f12:	f406                	sd	ra,40(sp)
    80002f14:	f022                	sd	s0,32(sp)
    80002f16:	ec26                	sd	s1,24(sp)
    80002f18:	e84a                	sd	s2,16(sp)
    80002f1a:	e44e                	sd	s3,8(sp)
    80002f1c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002f1e:	00004597          	auipc	a1,0x4
    80002f22:	61258593          	addi	a1,a1,1554 # 80007530 <syscalls+0x140>
    80002f26:	0001b517          	auipc	a0,0x1b
    80002f2a:	f5a50513          	addi	a0,a0,-166 # 8001de80 <itable>
    80002f2e:	bbffd0ef          	jal	ra,80000aec <initlock>
  for(i = 0; i < NINODE; i++) {
    80002f32:	0001b497          	auipc	s1,0x1b
    80002f36:	f7648493          	addi	s1,s1,-138 # 8001dea8 <itable+0x28>
    80002f3a:	0001d997          	auipc	s3,0x1d
    80002f3e:	9fe98993          	addi	s3,s3,-1538 # 8001f938 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80002f42:	00004917          	auipc	s2,0x4
    80002f46:	5f690913          	addi	s2,s2,1526 # 80007538 <syscalls+0x148>
    80002f4a:	85ca                	mv	a1,s2
    80002f4c:	8526                	mv	a0,s1
    80002f4e:	5a9000ef          	jal	ra,80003cf6 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002f52:	08848493          	addi	s1,s1,136
    80002f56:	ff349ae3          	bne	s1,s3,80002f4a <iinit+0x3a>
}
    80002f5a:	70a2                	ld	ra,40(sp)
    80002f5c:	7402                	ld	s0,32(sp)
    80002f5e:	64e2                	ld	s1,24(sp)
    80002f60:	6942                	ld	s2,16(sp)
    80002f62:	69a2                	ld	s3,8(sp)
    80002f64:	6145                	addi	sp,sp,48
    80002f66:	8082                	ret

0000000080002f68 <ialloc>:
{
    80002f68:	715d                	addi	sp,sp,-80
    80002f6a:	e486                	sd	ra,72(sp)
    80002f6c:	e0a2                	sd	s0,64(sp)
    80002f6e:	fc26                	sd	s1,56(sp)
    80002f70:	f84a                	sd	s2,48(sp)
    80002f72:	f44e                	sd	s3,40(sp)
    80002f74:	f052                	sd	s4,32(sp)
    80002f76:	ec56                	sd	s5,24(sp)
    80002f78:	e85a                	sd	s6,16(sp)
    80002f7a:	e45e                	sd	s7,8(sp)
    80002f7c:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80002f7e:	0001b717          	auipc	a4,0x1b
    80002f82:	eee72703          	lw	a4,-274(a4) # 8001de6c <sb+0xc>
    80002f86:	4785                	li	a5,1
    80002f88:	04e7f663          	bgeu	a5,a4,80002fd4 <ialloc+0x6c>
    80002f8c:	8aaa                	mv	s5,a0
    80002f8e:	8bae                	mv	s7,a1
    80002f90:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002f92:	0001ba17          	auipc	s4,0x1b
    80002f96:	ecea0a13          	addi	s4,s4,-306 # 8001de60 <sb>
    80002f9a:	00048b1b          	sext.w	s6,s1
    80002f9e:	0044d793          	srli	a5,s1,0x4
    80002fa2:	018a2583          	lw	a1,24(s4)
    80002fa6:	9dbd                	addw	a1,a1,a5
    80002fa8:	8556                	mv	a0,s5
    80002faa:	a75ff0ef          	jal	ra,80002a1e <bread>
    80002fae:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002fb0:	05850993          	addi	s3,a0,88
    80002fb4:	00f4f793          	andi	a5,s1,15
    80002fb8:	079a                	slli	a5,a5,0x6
    80002fba:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002fbc:	00099783          	lh	a5,0(s3)
    80002fc0:	cf85                	beqz	a5,80002ff8 <ialloc+0x90>
    brelse(bp);
    80002fc2:	b65ff0ef          	jal	ra,80002b26 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80002fc6:	0485                	addi	s1,s1,1
    80002fc8:	00ca2703          	lw	a4,12(s4)
    80002fcc:	0004879b          	sext.w	a5,s1
    80002fd0:	fce7e5e3          	bltu	a5,a4,80002f9a <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80002fd4:	00004517          	auipc	a0,0x4
    80002fd8:	56c50513          	addi	a0,a0,1388 # 80007540 <syscalls+0x150>
    80002fdc:	ce8fd0ef          	jal	ra,800004c4 <printf>
  return 0;
    80002fe0:	4501                	li	a0,0
}
    80002fe2:	60a6                	ld	ra,72(sp)
    80002fe4:	6406                	ld	s0,64(sp)
    80002fe6:	74e2                	ld	s1,56(sp)
    80002fe8:	7942                	ld	s2,48(sp)
    80002fea:	79a2                	ld	s3,40(sp)
    80002fec:	7a02                	ld	s4,32(sp)
    80002fee:	6ae2                	ld	s5,24(sp)
    80002ff0:	6b42                	ld	s6,16(sp)
    80002ff2:	6ba2                	ld	s7,8(sp)
    80002ff4:	6161                	addi	sp,sp,80
    80002ff6:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80002ff8:	04000613          	li	a2,64
    80002ffc:	4581                	li	a1,0
    80002ffe:	854e                	mv	a0,s3
    80003000:	c41fd0ef          	jal	ra,80000c40 <memset>
      dip->type = type;
    80003004:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003008:	854a                	mv	a0,s2
    8000300a:	429000ef          	jal	ra,80003c32 <log_write>
      brelse(bp);
    8000300e:	854a                	mv	a0,s2
    80003010:	b17ff0ef          	jal	ra,80002b26 <brelse>
      return iget(dev, inum);
    80003014:	85da                	mv	a1,s6
    80003016:	8556                	mv	a0,s5
    80003018:	e4dff0ef          	jal	ra,80002e64 <iget>
    8000301c:	b7d9                	j	80002fe2 <ialloc+0x7a>

000000008000301e <iupdate>:
{
    8000301e:	1101                	addi	sp,sp,-32
    80003020:	ec06                	sd	ra,24(sp)
    80003022:	e822                	sd	s0,16(sp)
    80003024:	e426                	sd	s1,8(sp)
    80003026:	e04a                	sd	s2,0(sp)
    80003028:	1000                	addi	s0,sp,32
    8000302a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000302c:	415c                	lw	a5,4(a0)
    8000302e:	0047d79b          	srliw	a5,a5,0x4
    80003032:	0001b597          	auipc	a1,0x1b
    80003036:	e465a583          	lw	a1,-442(a1) # 8001de78 <sb+0x18>
    8000303a:	9dbd                	addw	a1,a1,a5
    8000303c:	4108                	lw	a0,0(a0)
    8000303e:	9e1ff0ef          	jal	ra,80002a1e <bread>
    80003042:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003044:	05850793          	addi	a5,a0,88
    80003048:	40c8                	lw	a0,4(s1)
    8000304a:	893d                	andi	a0,a0,15
    8000304c:	051a                	slli	a0,a0,0x6
    8000304e:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003050:	04449703          	lh	a4,68(s1)
    80003054:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003058:	04649703          	lh	a4,70(s1)
    8000305c:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003060:	04849703          	lh	a4,72(s1)
    80003064:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003068:	04a49703          	lh	a4,74(s1)
    8000306c:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003070:	44f8                	lw	a4,76(s1)
    80003072:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003074:	03400613          	li	a2,52
    80003078:	05048593          	addi	a1,s1,80
    8000307c:	0531                	addi	a0,a0,12
    8000307e:	c1ffd0ef          	jal	ra,80000c9c <memmove>
  log_write(bp);
    80003082:	854a                	mv	a0,s2
    80003084:	3af000ef          	jal	ra,80003c32 <log_write>
  brelse(bp);
    80003088:	854a                	mv	a0,s2
    8000308a:	a9dff0ef          	jal	ra,80002b26 <brelse>
}
    8000308e:	60e2                	ld	ra,24(sp)
    80003090:	6442                	ld	s0,16(sp)
    80003092:	64a2                	ld	s1,8(sp)
    80003094:	6902                	ld	s2,0(sp)
    80003096:	6105                	addi	sp,sp,32
    80003098:	8082                	ret

000000008000309a <idup>:
{
    8000309a:	1101                	addi	sp,sp,-32
    8000309c:	ec06                	sd	ra,24(sp)
    8000309e:	e822                	sd	s0,16(sp)
    800030a0:	e426                	sd	s1,8(sp)
    800030a2:	1000                	addi	s0,sp,32
    800030a4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800030a6:	0001b517          	auipc	a0,0x1b
    800030aa:	dda50513          	addi	a0,a0,-550 # 8001de80 <itable>
    800030ae:	abffd0ef          	jal	ra,80000b6c <acquire>
  ip->ref++;
    800030b2:	449c                	lw	a5,8(s1)
    800030b4:	2785                	addiw	a5,a5,1
    800030b6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800030b8:	0001b517          	auipc	a0,0x1b
    800030bc:	dc850513          	addi	a0,a0,-568 # 8001de80 <itable>
    800030c0:	b45fd0ef          	jal	ra,80000c04 <release>
}
    800030c4:	8526                	mv	a0,s1
    800030c6:	60e2                	ld	ra,24(sp)
    800030c8:	6442                	ld	s0,16(sp)
    800030ca:	64a2                	ld	s1,8(sp)
    800030cc:	6105                	addi	sp,sp,32
    800030ce:	8082                	ret

00000000800030d0 <ilock>:
{
    800030d0:	1101                	addi	sp,sp,-32
    800030d2:	ec06                	sd	ra,24(sp)
    800030d4:	e822                	sd	s0,16(sp)
    800030d6:	e426                	sd	s1,8(sp)
    800030d8:	e04a                	sd	s2,0(sp)
    800030da:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800030dc:	c105                	beqz	a0,800030fc <ilock+0x2c>
    800030de:	84aa                	mv	s1,a0
    800030e0:	451c                	lw	a5,8(a0)
    800030e2:	00f05d63          	blez	a5,800030fc <ilock+0x2c>
  acquiresleep(&ip->lock);
    800030e6:	0541                	addi	a0,a0,16
    800030e8:	445000ef          	jal	ra,80003d2c <acquiresleep>
  if(ip->valid == 0){
    800030ec:	40bc                	lw	a5,64(s1)
    800030ee:	cf89                	beqz	a5,80003108 <ilock+0x38>
}
    800030f0:	60e2                	ld	ra,24(sp)
    800030f2:	6442                	ld	s0,16(sp)
    800030f4:	64a2                	ld	s1,8(sp)
    800030f6:	6902                	ld	s2,0(sp)
    800030f8:	6105                	addi	sp,sp,32
    800030fa:	8082                	ret
    panic("ilock");
    800030fc:	00004517          	auipc	a0,0x4
    80003100:	45c50513          	addi	a0,a0,1116 # 80007558 <syscalls+0x168>
    80003104:	e86fd0ef          	jal	ra,8000078a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003108:	40dc                	lw	a5,4(s1)
    8000310a:	0047d79b          	srliw	a5,a5,0x4
    8000310e:	0001b597          	auipc	a1,0x1b
    80003112:	d6a5a583          	lw	a1,-662(a1) # 8001de78 <sb+0x18>
    80003116:	9dbd                	addw	a1,a1,a5
    80003118:	4088                	lw	a0,0(s1)
    8000311a:	905ff0ef          	jal	ra,80002a1e <bread>
    8000311e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003120:	05850593          	addi	a1,a0,88
    80003124:	40dc                	lw	a5,4(s1)
    80003126:	8bbd                	andi	a5,a5,15
    80003128:	079a                	slli	a5,a5,0x6
    8000312a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000312c:	00059783          	lh	a5,0(a1)
    80003130:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003134:	00259783          	lh	a5,2(a1)
    80003138:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000313c:	00459783          	lh	a5,4(a1)
    80003140:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003144:	00659783          	lh	a5,6(a1)
    80003148:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000314c:	459c                	lw	a5,8(a1)
    8000314e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003150:	03400613          	li	a2,52
    80003154:	05b1                	addi	a1,a1,12
    80003156:	05048513          	addi	a0,s1,80
    8000315a:	b43fd0ef          	jal	ra,80000c9c <memmove>
    brelse(bp);
    8000315e:	854a                	mv	a0,s2
    80003160:	9c7ff0ef          	jal	ra,80002b26 <brelse>
    ip->valid = 1;
    80003164:	4785                	li	a5,1
    80003166:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003168:	04449783          	lh	a5,68(s1)
    8000316c:	f3d1                	bnez	a5,800030f0 <ilock+0x20>
      panic("ilock: no type");
    8000316e:	00004517          	auipc	a0,0x4
    80003172:	3f250513          	addi	a0,a0,1010 # 80007560 <syscalls+0x170>
    80003176:	e14fd0ef          	jal	ra,8000078a <panic>

000000008000317a <iunlock>:
{
    8000317a:	1101                	addi	sp,sp,-32
    8000317c:	ec06                	sd	ra,24(sp)
    8000317e:	e822                	sd	s0,16(sp)
    80003180:	e426                	sd	s1,8(sp)
    80003182:	e04a                	sd	s2,0(sp)
    80003184:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003186:	c505                	beqz	a0,800031ae <iunlock+0x34>
    80003188:	84aa                	mv	s1,a0
    8000318a:	01050913          	addi	s2,a0,16
    8000318e:	854a                	mv	a0,s2
    80003190:	41b000ef          	jal	ra,80003daa <holdingsleep>
    80003194:	cd09                	beqz	a0,800031ae <iunlock+0x34>
    80003196:	449c                	lw	a5,8(s1)
    80003198:	00f05b63          	blez	a5,800031ae <iunlock+0x34>
  releasesleep(&ip->lock);
    8000319c:	854a                	mv	a0,s2
    8000319e:	3d5000ef          	jal	ra,80003d72 <releasesleep>
}
    800031a2:	60e2                	ld	ra,24(sp)
    800031a4:	6442                	ld	s0,16(sp)
    800031a6:	64a2                	ld	s1,8(sp)
    800031a8:	6902                	ld	s2,0(sp)
    800031aa:	6105                	addi	sp,sp,32
    800031ac:	8082                	ret
    panic("iunlock");
    800031ae:	00004517          	auipc	a0,0x4
    800031b2:	3c250513          	addi	a0,a0,962 # 80007570 <syscalls+0x180>
    800031b6:	dd4fd0ef          	jal	ra,8000078a <panic>

00000000800031ba <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800031ba:	7179                	addi	sp,sp,-48
    800031bc:	f406                	sd	ra,40(sp)
    800031be:	f022                	sd	s0,32(sp)
    800031c0:	ec26                	sd	s1,24(sp)
    800031c2:	e84a                	sd	s2,16(sp)
    800031c4:	e44e                	sd	s3,8(sp)
    800031c6:	e052                	sd	s4,0(sp)
    800031c8:	1800                	addi	s0,sp,48
    800031ca:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800031cc:	05050493          	addi	s1,a0,80
    800031d0:	08050913          	addi	s2,a0,128
    800031d4:	a021                	j	800031dc <itrunc+0x22>
    800031d6:	0491                	addi	s1,s1,4
    800031d8:	01248b63          	beq	s1,s2,800031ee <itrunc+0x34>
    if(ip->addrs[i]){
    800031dc:	408c                	lw	a1,0(s1)
    800031de:	dde5                	beqz	a1,800031d6 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800031e0:	0009a503          	lw	a0,0(s3)
    800031e4:	a35ff0ef          	jal	ra,80002c18 <bfree>
      ip->addrs[i] = 0;
    800031e8:	0004a023          	sw	zero,0(s1)
    800031ec:	b7ed                	j	800031d6 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800031ee:	0809a583          	lw	a1,128(s3)
    800031f2:	ed91                	bnez	a1,8000320e <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800031f4:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800031f8:	854e                	mv	a0,s3
    800031fa:	e25ff0ef          	jal	ra,8000301e <iupdate>
}
    800031fe:	70a2                	ld	ra,40(sp)
    80003200:	7402                	ld	s0,32(sp)
    80003202:	64e2                	ld	s1,24(sp)
    80003204:	6942                	ld	s2,16(sp)
    80003206:	69a2                	ld	s3,8(sp)
    80003208:	6a02                	ld	s4,0(sp)
    8000320a:	6145                	addi	sp,sp,48
    8000320c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000320e:	0009a503          	lw	a0,0(s3)
    80003212:	80dff0ef          	jal	ra,80002a1e <bread>
    80003216:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003218:	05850493          	addi	s1,a0,88
    8000321c:	45850913          	addi	s2,a0,1112
    80003220:	a021                	j	80003228 <itrunc+0x6e>
    80003222:	0491                	addi	s1,s1,4
    80003224:	01248963          	beq	s1,s2,80003236 <itrunc+0x7c>
      if(a[j])
    80003228:	408c                	lw	a1,0(s1)
    8000322a:	dde5                	beqz	a1,80003222 <itrunc+0x68>
        bfree(ip->dev, a[j]);
    8000322c:	0009a503          	lw	a0,0(s3)
    80003230:	9e9ff0ef          	jal	ra,80002c18 <bfree>
    80003234:	b7fd                	j	80003222 <itrunc+0x68>
    brelse(bp);
    80003236:	8552                	mv	a0,s4
    80003238:	8efff0ef          	jal	ra,80002b26 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000323c:	0809a583          	lw	a1,128(s3)
    80003240:	0009a503          	lw	a0,0(s3)
    80003244:	9d5ff0ef          	jal	ra,80002c18 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003248:	0809a023          	sw	zero,128(s3)
    8000324c:	b765                	j	800031f4 <itrunc+0x3a>

000000008000324e <iput>:
{
    8000324e:	1101                	addi	sp,sp,-32
    80003250:	ec06                	sd	ra,24(sp)
    80003252:	e822                	sd	s0,16(sp)
    80003254:	e426                	sd	s1,8(sp)
    80003256:	e04a                	sd	s2,0(sp)
    80003258:	1000                	addi	s0,sp,32
    8000325a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000325c:	0001b517          	auipc	a0,0x1b
    80003260:	c2450513          	addi	a0,a0,-988 # 8001de80 <itable>
    80003264:	909fd0ef          	jal	ra,80000b6c <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003268:	4498                	lw	a4,8(s1)
    8000326a:	4785                	li	a5,1
    8000326c:	02f70163          	beq	a4,a5,8000328e <iput+0x40>
  ip->ref--;
    80003270:	449c                	lw	a5,8(s1)
    80003272:	37fd                	addiw	a5,a5,-1
    80003274:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003276:	0001b517          	auipc	a0,0x1b
    8000327a:	c0a50513          	addi	a0,a0,-1014 # 8001de80 <itable>
    8000327e:	987fd0ef          	jal	ra,80000c04 <release>
}
    80003282:	60e2                	ld	ra,24(sp)
    80003284:	6442                	ld	s0,16(sp)
    80003286:	64a2                	ld	s1,8(sp)
    80003288:	6902                	ld	s2,0(sp)
    8000328a:	6105                	addi	sp,sp,32
    8000328c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000328e:	40bc                	lw	a5,64(s1)
    80003290:	d3e5                	beqz	a5,80003270 <iput+0x22>
    80003292:	04a49783          	lh	a5,74(s1)
    80003296:	ffe9                	bnez	a5,80003270 <iput+0x22>
    acquiresleep(&ip->lock);
    80003298:	01048913          	addi	s2,s1,16
    8000329c:	854a                	mv	a0,s2
    8000329e:	28f000ef          	jal	ra,80003d2c <acquiresleep>
    release(&itable.lock);
    800032a2:	0001b517          	auipc	a0,0x1b
    800032a6:	bde50513          	addi	a0,a0,-1058 # 8001de80 <itable>
    800032aa:	95bfd0ef          	jal	ra,80000c04 <release>
    itrunc(ip);
    800032ae:	8526                	mv	a0,s1
    800032b0:	f0bff0ef          	jal	ra,800031ba <itrunc>
    ip->type = 0;
    800032b4:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800032b8:	8526                	mv	a0,s1
    800032ba:	d65ff0ef          	jal	ra,8000301e <iupdate>
    ip->valid = 0;
    800032be:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800032c2:	854a                	mv	a0,s2
    800032c4:	2af000ef          	jal	ra,80003d72 <releasesleep>
    acquire(&itable.lock);
    800032c8:	0001b517          	auipc	a0,0x1b
    800032cc:	bb850513          	addi	a0,a0,-1096 # 8001de80 <itable>
    800032d0:	89dfd0ef          	jal	ra,80000b6c <acquire>
    800032d4:	bf71                	j	80003270 <iput+0x22>

00000000800032d6 <iunlockput>:
{
    800032d6:	1101                	addi	sp,sp,-32
    800032d8:	ec06                	sd	ra,24(sp)
    800032da:	e822                	sd	s0,16(sp)
    800032dc:	e426                	sd	s1,8(sp)
    800032de:	1000                	addi	s0,sp,32
    800032e0:	84aa                	mv	s1,a0
  iunlock(ip);
    800032e2:	e99ff0ef          	jal	ra,8000317a <iunlock>
  iput(ip);
    800032e6:	8526                	mv	a0,s1
    800032e8:	f67ff0ef          	jal	ra,8000324e <iput>
}
    800032ec:	60e2                	ld	ra,24(sp)
    800032ee:	6442                	ld	s0,16(sp)
    800032f0:	64a2                	ld	s1,8(sp)
    800032f2:	6105                	addi	sp,sp,32
    800032f4:	8082                	ret

00000000800032f6 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800032f6:	0001b717          	auipc	a4,0x1b
    800032fa:	b7672703          	lw	a4,-1162(a4) # 8001de6c <sb+0xc>
    800032fe:	4785                	li	a5,1
    80003300:	0ae7ff63          	bgeu	a5,a4,800033be <ireclaim+0xc8>
{
    80003304:	7139                	addi	sp,sp,-64
    80003306:	fc06                	sd	ra,56(sp)
    80003308:	f822                	sd	s0,48(sp)
    8000330a:	f426                	sd	s1,40(sp)
    8000330c:	f04a                	sd	s2,32(sp)
    8000330e:	ec4e                	sd	s3,24(sp)
    80003310:	e852                	sd	s4,16(sp)
    80003312:	e456                	sd	s5,8(sp)
    80003314:	e05a                	sd	s6,0(sp)
    80003316:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003318:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000331a:	00050a1b          	sext.w	s4,a0
    8000331e:	0001ba97          	auipc	s5,0x1b
    80003322:	b42a8a93          	addi	s5,s5,-1214 # 8001de60 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003326:	00004b17          	auipc	s6,0x4
    8000332a:	252b0b13          	addi	s6,s6,594 # 80007578 <syscalls+0x188>
    8000332e:	a099                	j	80003374 <ireclaim+0x7e>
    80003330:	85ce                	mv	a1,s3
    80003332:	855a                	mv	a0,s6
    80003334:	990fd0ef          	jal	ra,800004c4 <printf>
      ip = iget(dev, inum);
    80003338:	85ce                	mv	a1,s3
    8000333a:	8552                	mv	a0,s4
    8000333c:	b29ff0ef          	jal	ra,80002e64 <iget>
    80003340:	89aa                	mv	s3,a0
    brelse(bp);
    80003342:	854a                	mv	a0,s2
    80003344:	fe2ff0ef          	jal	ra,80002b26 <brelse>
    if (ip) {
    80003348:	00098f63          	beqz	s3,80003366 <ireclaim+0x70>
      begin_op();
    8000334c:	762000ef          	jal	ra,80003aae <begin_op>
      ilock(ip);
    80003350:	854e                	mv	a0,s3
    80003352:	d7fff0ef          	jal	ra,800030d0 <ilock>
      iunlock(ip);
    80003356:	854e                	mv	a0,s3
    80003358:	e23ff0ef          	jal	ra,8000317a <iunlock>
      iput(ip);
    8000335c:	854e                	mv	a0,s3
    8000335e:	ef1ff0ef          	jal	ra,8000324e <iput>
      end_op();
    80003362:	7bc000ef          	jal	ra,80003b1e <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003366:	0485                	addi	s1,s1,1
    80003368:	00caa703          	lw	a4,12(s5)
    8000336c:	0004879b          	sext.w	a5,s1
    80003370:	02e7fd63          	bgeu	a5,a4,800033aa <ireclaim+0xb4>
    80003374:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003378:	0044d793          	srli	a5,s1,0x4
    8000337c:	018aa583          	lw	a1,24(s5)
    80003380:	9dbd                	addw	a1,a1,a5
    80003382:	8552                	mv	a0,s4
    80003384:	e9aff0ef          	jal	ra,80002a1e <bread>
    80003388:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000338a:	05850793          	addi	a5,a0,88
    8000338e:	00f9f713          	andi	a4,s3,15
    80003392:	071a                	slli	a4,a4,0x6
    80003394:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003396:	00079703          	lh	a4,0(a5)
    8000339a:	c701                	beqz	a4,800033a2 <ireclaim+0xac>
    8000339c:	00679783          	lh	a5,6(a5)
    800033a0:	dbc1                	beqz	a5,80003330 <ireclaim+0x3a>
    brelse(bp);
    800033a2:	854a                	mv	a0,s2
    800033a4:	f82ff0ef          	jal	ra,80002b26 <brelse>
    if (ip) {
    800033a8:	bf7d                	j	80003366 <ireclaim+0x70>
}
    800033aa:	70e2                	ld	ra,56(sp)
    800033ac:	7442                	ld	s0,48(sp)
    800033ae:	74a2                	ld	s1,40(sp)
    800033b0:	7902                	ld	s2,32(sp)
    800033b2:	69e2                	ld	s3,24(sp)
    800033b4:	6a42                	ld	s4,16(sp)
    800033b6:	6aa2                	ld	s5,8(sp)
    800033b8:	6b02                	ld	s6,0(sp)
    800033ba:	6121                	addi	sp,sp,64
    800033bc:	8082                	ret
    800033be:	8082                	ret

00000000800033c0 <fsinit>:
fsinit(int dev) {
    800033c0:	7179                	addi	sp,sp,-48
    800033c2:	f406                	sd	ra,40(sp)
    800033c4:	f022                	sd	s0,32(sp)
    800033c6:	ec26                	sd	s1,24(sp)
    800033c8:	e84a                	sd	s2,16(sp)
    800033ca:	e44e                	sd	s3,8(sp)
    800033cc:	1800                	addi	s0,sp,48
    800033ce:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800033d0:	4585                	li	a1,1
    800033d2:	e4cff0ef          	jal	ra,80002a1e <bread>
    800033d6:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800033d8:	0001b997          	auipc	s3,0x1b
    800033dc:	a8898993          	addi	s3,s3,-1400 # 8001de60 <sb>
    800033e0:	02000613          	li	a2,32
    800033e4:	05850593          	addi	a1,a0,88
    800033e8:	854e                	mv	a0,s3
    800033ea:	8b3fd0ef          	jal	ra,80000c9c <memmove>
  brelse(bp);
    800033ee:	854a                	mv	a0,s2
    800033f0:	f36ff0ef          	jal	ra,80002b26 <brelse>
  if(sb.magic != FSMAGIC)
    800033f4:	0009a703          	lw	a4,0(s3)
    800033f8:	102037b7          	lui	a5,0x10203
    800033fc:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003400:	02f71363          	bne	a4,a5,80003426 <fsinit+0x66>
  initlog(dev, &sb);
    80003404:	0001b597          	auipc	a1,0x1b
    80003408:	a5c58593          	addi	a1,a1,-1444 # 8001de60 <sb>
    8000340c:	8526                	mv	a0,s1
    8000340e:	616000ef          	jal	ra,80003a24 <initlog>
  ireclaim(dev);
    80003412:	8526                	mv	a0,s1
    80003414:	ee3ff0ef          	jal	ra,800032f6 <ireclaim>
}
    80003418:	70a2                	ld	ra,40(sp)
    8000341a:	7402                	ld	s0,32(sp)
    8000341c:	64e2                	ld	s1,24(sp)
    8000341e:	6942                	ld	s2,16(sp)
    80003420:	69a2                	ld	s3,8(sp)
    80003422:	6145                	addi	sp,sp,48
    80003424:	8082                	ret
    panic("invalid file system");
    80003426:	00004517          	auipc	a0,0x4
    8000342a:	17250513          	addi	a0,a0,370 # 80007598 <syscalls+0x1a8>
    8000342e:	b5cfd0ef          	jal	ra,8000078a <panic>

0000000080003432 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003432:	1141                	addi	sp,sp,-16
    80003434:	e422                	sd	s0,8(sp)
    80003436:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003438:	411c                	lw	a5,0(a0)
    8000343a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000343c:	415c                	lw	a5,4(a0)
    8000343e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003440:	04451783          	lh	a5,68(a0)
    80003444:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003448:	04a51783          	lh	a5,74(a0)
    8000344c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003450:	04c56783          	lwu	a5,76(a0)
    80003454:	e99c                	sd	a5,16(a1)
}
    80003456:	6422                	ld	s0,8(sp)
    80003458:	0141                	addi	sp,sp,16
    8000345a:	8082                	ret

000000008000345c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000345c:	457c                	lw	a5,76(a0)
    8000345e:	0cd7ef63          	bltu	a5,a3,8000353c <readi+0xe0>
{
    80003462:	7159                	addi	sp,sp,-112
    80003464:	f486                	sd	ra,104(sp)
    80003466:	f0a2                	sd	s0,96(sp)
    80003468:	eca6                	sd	s1,88(sp)
    8000346a:	e8ca                	sd	s2,80(sp)
    8000346c:	e4ce                	sd	s3,72(sp)
    8000346e:	e0d2                	sd	s4,64(sp)
    80003470:	fc56                	sd	s5,56(sp)
    80003472:	f85a                	sd	s6,48(sp)
    80003474:	f45e                	sd	s7,40(sp)
    80003476:	f062                	sd	s8,32(sp)
    80003478:	ec66                	sd	s9,24(sp)
    8000347a:	e86a                	sd	s10,16(sp)
    8000347c:	e46e                	sd	s11,8(sp)
    8000347e:	1880                	addi	s0,sp,112
    80003480:	8b2a                	mv	s6,a0
    80003482:	8bae                	mv	s7,a1
    80003484:	8a32                	mv	s4,a2
    80003486:	84b6                	mv	s1,a3
    80003488:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000348a:	9f35                	addw	a4,a4,a3
    return 0;
    8000348c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000348e:	08d76663          	bltu	a4,a3,8000351a <readi+0xbe>
  if(off + n > ip->size)
    80003492:	00e7f463          	bgeu	a5,a4,8000349a <readi+0x3e>
    n = ip->size - off;
    80003496:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000349a:	080a8f63          	beqz	s5,80003538 <readi+0xdc>
    8000349e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800034a0:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800034a4:	5c7d                	li	s8,-1
    800034a6:	a80d                	j	800034d8 <readi+0x7c>
    800034a8:	020d1d93          	slli	s11,s10,0x20
    800034ac:	020ddd93          	srli	s11,s11,0x20
    800034b0:	05890793          	addi	a5,s2,88
    800034b4:	86ee                	mv	a3,s11
    800034b6:	963e                	add	a2,a2,a5
    800034b8:	85d2                	mv	a1,s4
    800034ba:	855e                	mv	a0,s7
    800034bc:	c9bfe0ef          	jal	ra,80002156 <either_copyout>
    800034c0:	05850763          	beq	a0,s8,8000350e <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800034c4:	854a                	mv	a0,s2
    800034c6:	e60ff0ef          	jal	ra,80002b26 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800034ca:	013d09bb          	addw	s3,s10,s3
    800034ce:	009d04bb          	addw	s1,s10,s1
    800034d2:	9a6e                	add	s4,s4,s11
    800034d4:	0559f163          	bgeu	s3,s5,80003516 <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    800034d8:	00a4d59b          	srliw	a1,s1,0xa
    800034dc:	855a                	mv	a0,s6
    800034de:	8bbff0ef          	jal	ra,80002d98 <bmap>
    800034e2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800034e6:	c985                	beqz	a1,80003516 <readi+0xba>
    bp = bread(ip->dev, addr);
    800034e8:	000b2503          	lw	a0,0(s6)
    800034ec:	d32ff0ef          	jal	ra,80002a1e <bread>
    800034f0:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800034f2:	3ff4f613          	andi	a2,s1,1023
    800034f6:	40cc87bb          	subw	a5,s9,a2
    800034fa:	413a873b          	subw	a4,s5,s3
    800034fe:	8d3e                	mv	s10,a5
    80003500:	2781                	sext.w	a5,a5
    80003502:	0007069b          	sext.w	a3,a4
    80003506:	faf6f1e3          	bgeu	a3,a5,800034a8 <readi+0x4c>
    8000350a:	8d3a                	mv	s10,a4
    8000350c:	bf71                	j	800034a8 <readi+0x4c>
      brelse(bp);
    8000350e:	854a                	mv	a0,s2
    80003510:	e16ff0ef          	jal	ra,80002b26 <brelse>
      tot = -1;
    80003514:	59fd                	li	s3,-1
  }
  return tot;
    80003516:	0009851b          	sext.w	a0,s3
}
    8000351a:	70a6                	ld	ra,104(sp)
    8000351c:	7406                	ld	s0,96(sp)
    8000351e:	64e6                	ld	s1,88(sp)
    80003520:	6946                	ld	s2,80(sp)
    80003522:	69a6                	ld	s3,72(sp)
    80003524:	6a06                	ld	s4,64(sp)
    80003526:	7ae2                	ld	s5,56(sp)
    80003528:	7b42                	ld	s6,48(sp)
    8000352a:	7ba2                	ld	s7,40(sp)
    8000352c:	7c02                	ld	s8,32(sp)
    8000352e:	6ce2                	ld	s9,24(sp)
    80003530:	6d42                	ld	s10,16(sp)
    80003532:	6da2                	ld	s11,8(sp)
    80003534:	6165                	addi	sp,sp,112
    80003536:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003538:	89d6                	mv	s3,s5
    8000353a:	bff1                	j	80003516 <readi+0xba>
    return 0;
    8000353c:	4501                	li	a0,0
}
    8000353e:	8082                	ret

0000000080003540 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003540:	457c                	lw	a5,76(a0)
    80003542:	0ed7ea63          	bltu	a5,a3,80003636 <writei+0xf6>
{
    80003546:	7159                	addi	sp,sp,-112
    80003548:	f486                	sd	ra,104(sp)
    8000354a:	f0a2                	sd	s0,96(sp)
    8000354c:	eca6                	sd	s1,88(sp)
    8000354e:	e8ca                	sd	s2,80(sp)
    80003550:	e4ce                	sd	s3,72(sp)
    80003552:	e0d2                	sd	s4,64(sp)
    80003554:	fc56                	sd	s5,56(sp)
    80003556:	f85a                	sd	s6,48(sp)
    80003558:	f45e                	sd	s7,40(sp)
    8000355a:	f062                	sd	s8,32(sp)
    8000355c:	ec66                	sd	s9,24(sp)
    8000355e:	e86a                	sd	s10,16(sp)
    80003560:	e46e                	sd	s11,8(sp)
    80003562:	1880                	addi	s0,sp,112
    80003564:	8aaa                	mv	s5,a0
    80003566:	8bae                	mv	s7,a1
    80003568:	8a32                	mv	s4,a2
    8000356a:	8936                	mv	s2,a3
    8000356c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000356e:	00e687bb          	addw	a5,a3,a4
    80003572:	0cd7e463          	bltu	a5,a3,8000363a <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003576:	00043737          	lui	a4,0x43
    8000357a:	0cf76263          	bltu	a4,a5,8000363e <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000357e:	0a0b0a63          	beqz	s6,80003632 <writei+0xf2>
    80003582:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003584:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003588:	5c7d                	li	s8,-1
    8000358a:	a825                	j	800035c2 <writei+0x82>
    8000358c:	020d1d93          	slli	s11,s10,0x20
    80003590:	020ddd93          	srli	s11,s11,0x20
    80003594:	05848793          	addi	a5,s1,88
    80003598:	86ee                	mv	a3,s11
    8000359a:	8652                	mv	a2,s4
    8000359c:	85de                	mv	a1,s7
    8000359e:	953e                	add	a0,a0,a5
    800035a0:	c01fe0ef          	jal	ra,800021a0 <either_copyin>
    800035a4:	05850a63          	beq	a0,s8,800035f8 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    800035a8:	8526                	mv	a0,s1
    800035aa:	688000ef          	jal	ra,80003c32 <log_write>
    brelse(bp);
    800035ae:	8526                	mv	a0,s1
    800035b0:	d76ff0ef          	jal	ra,80002b26 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800035b4:	013d09bb          	addw	s3,s10,s3
    800035b8:	012d093b          	addw	s2,s10,s2
    800035bc:	9a6e                	add	s4,s4,s11
    800035be:	0569f063          	bgeu	s3,s6,800035fe <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800035c2:	00a9559b          	srliw	a1,s2,0xa
    800035c6:	8556                	mv	a0,s5
    800035c8:	fd0ff0ef          	jal	ra,80002d98 <bmap>
    800035cc:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800035d0:	c59d                	beqz	a1,800035fe <writei+0xbe>
    bp = bread(ip->dev, addr);
    800035d2:	000aa503          	lw	a0,0(s5)
    800035d6:	c48ff0ef          	jal	ra,80002a1e <bread>
    800035da:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800035dc:	3ff97513          	andi	a0,s2,1023
    800035e0:	40ac87bb          	subw	a5,s9,a0
    800035e4:	413b073b          	subw	a4,s6,s3
    800035e8:	8d3e                	mv	s10,a5
    800035ea:	2781                	sext.w	a5,a5
    800035ec:	0007069b          	sext.w	a3,a4
    800035f0:	f8f6fee3          	bgeu	a3,a5,8000358c <writei+0x4c>
    800035f4:	8d3a                	mv	s10,a4
    800035f6:	bf59                	j	8000358c <writei+0x4c>
      brelse(bp);
    800035f8:	8526                	mv	a0,s1
    800035fa:	d2cff0ef          	jal	ra,80002b26 <brelse>
  }

  if(off > ip->size)
    800035fe:	04caa783          	lw	a5,76(s5)
    80003602:	0127f463          	bgeu	a5,s2,8000360a <writei+0xca>
    ip->size = off;
    80003606:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000360a:	8556                	mv	a0,s5
    8000360c:	a13ff0ef          	jal	ra,8000301e <iupdate>

  return tot;
    80003610:	0009851b          	sext.w	a0,s3
}
    80003614:	70a6                	ld	ra,104(sp)
    80003616:	7406                	ld	s0,96(sp)
    80003618:	64e6                	ld	s1,88(sp)
    8000361a:	6946                	ld	s2,80(sp)
    8000361c:	69a6                	ld	s3,72(sp)
    8000361e:	6a06                	ld	s4,64(sp)
    80003620:	7ae2                	ld	s5,56(sp)
    80003622:	7b42                	ld	s6,48(sp)
    80003624:	7ba2                	ld	s7,40(sp)
    80003626:	7c02                	ld	s8,32(sp)
    80003628:	6ce2                	ld	s9,24(sp)
    8000362a:	6d42                	ld	s10,16(sp)
    8000362c:	6da2                	ld	s11,8(sp)
    8000362e:	6165                	addi	sp,sp,112
    80003630:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003632:	89da                	mv	s3,s6
    80003634:	bfd9                	j	8000360a <writei+0xca>
    return -1;
    80003636:	557d                	li	a0,-1
}
    80003638:	8082                	ret
    return -1;
    8000363a:	557d                	li	a0,-1
    8000363c:	bfe1                	j	80003614 <writei+0xd4>
    return -1;
    8000363e:	557d                	li	a0,-1
    80003640:	bfd1                	j	80003614 <writei+0xd4>

0000000080003642 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003642:	1141                	addi	sp,sp,-16
    80003644:	e406                	sd	ra,8(sp)
    80003646:	e022                	sd	s0,0(sp)
    80003648:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000364a:	4639                	li	a2,14
    8000364c:	ec0fd0ef          	jal	ra,80000d0c <strncmp>
}
    80003650:	60a2                	ld	ra,8(sp)
    80003652:	6402                	ld	s0,0(sp)
    80003654:	0141                	addi	sp,sp,16
    80003656:	8082                	ret

0000000080003658 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003658:	7139                	addi	sp,sp,-64
    8000365a:	fc06                	sd	ra,56(sp)
    8000365c:	f822                	sd	s0,48(sp)
    8000365e:	f426                	sd	s1,40(sp)
    80003660:	f04a                	sd	s2,32(sp)
    80003662:	ec4e                	sd	s3,24(sp)
    80003664:	e852                	sd	s4,16(sp)
    80003666:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003668:	04451703          	lh	a4,68(a0)
    8000366c:	4785                	li	a5,1
    8000366e:	00f71a63          	bne	a4,a5,80003682 <dirlookup+0x2a>
    80003672:	892a                	mv	s2,a0
    80003674:	89ae                	mv	s3,a1
    80003676:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003678:	457c                	lw	a5,76(a0)
    8000367a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000367c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000367e:	e39d                	bnez	a5,800036a4 <dirlookup+0x4c>
    80003680:	a095                	j	800036e4 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003682:	00004517          	auipc	a0,0x4
    80003686:	f2e50513          	addi	a0,a0,-210 # 800075b0 <syscalls+0x1c0>
    8000368a:	900fd0ef          	jal	ra,8000078a <panic>
      panic("dirlookup read");
    8000368e:	00004517          	auipc	a0,0x4
    80003692:	f3a50513          	addi	a0,a0,-198 # 800075c8 <syscalls+0x1d8>
    80003696:	8f4fd0ef          	jal	ra,8000078a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000369a:	24c1                	addiw	s1,s1,16
    8000369c:	04c92783          	lw	a5,76(s2)
    800036a0:	04f4f163          	bgeu	s1,a5,800036e2 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800036a4:	4741                	li	a4,16
    800036a6:	86a6                	mv	a3,s1
    800036a8:	fc040613          	addi	a2,s0,-64
    800036ac:	4581                	li	a1,0
    800036ae:	854a                	mv	a0,s2
    800036b0:	dadff0ef          	jal	ra,8000345c <readi>
    800036b4:	47c1                	li	a5,16
    800036b6:	fcf51ce3          	bne	a0,a5,8000368e <dirlookup+0x36>
    if(de.inum == 0)
    800036ba:	fc045783          	lhu	a5,-64(s0)
    800036be:	dff1                	beqz	a5,8000369a <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    800036c0:	fc240593          	addi	a1,s0,-62
    800036c4:	854e                	mv	a0,s3
    800036c6:	f7dff0ef          	jal	ra,80003642 <namecmp>
    800036ca:	f961                	bnez	a0,8000369a <dirlookup+0x42>
      if(poff)
    800036cc:	000a0463          	beqz	s4,800036d4 <dirlookup+0x7c>
        *poff = off;
    800036d0:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800036d4:	fc045583          	lhu	a1,-64(s0)
    800036d8:	00092503          	lw	a0,0(s2)
    800036dc:	f88ff0ef          	jal	ra,80002e64 <iget>
    800036e0:	a011                	j	800036e4 <dirlookup+0x8c>
  return 0;
    800036e2:	4501                	li	a0,0
}
    800036e4:	70e2                	ld	ra,56(sp)
    800036e6:	7442                	ld	s0,48(sp)
    800036e8:	74a2                	ld	s1,40(sp)
    800036ea:	7902                	ld	s2,32(sp)
    800036ec:	69e2                	ld	s3,24(sp)
    800036ee:	6a42                	ld	s4,16(sp)
    800036f0:	6121                	addi	sp,sp,64
    800036f2:	8082                	ret

00000000800036f4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800036f4:	711d                	addi	sp,sp,-96
    800036f6:	ec86                	sd	ra,88(sp)
    800036f8:	e8a2                	sd	s0,80(sp)
    800036fa:	e4a6                	sd	s1,72(sp)
    800036fc:	e0ca                	sd	s2,64(sp)
    800036fe:	fc4e                	sd	s3,56(sp)
    80003700:	f852                	sd	s4,48(sp)
    80003702:	f456                	sd	s5,40(sp)
    80003704:	f05a                	sd	s6,32(sp)
    80003706:	ec5e                	sd	s7,24(sp)
    80003708:	e862                	sd	s8,16(sp)
    8000370a:	e466                	sd	s9,8(sp)
    8000370c:	1080                	addi	s0,sp,96
    8000370e:	84aa                	mv	s1,a0
    80003710:	8aae                	mv	s5,a1
    80003712:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003714:	00054703          	lbu	a4,0(a0)
    80003718:	02f00793          	li	a5,47
    8000371c:	00f70f63          	beq	a4,a5,8000373a <namex+0x46>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003720:	8e4fe0ef          	jal	ra,80001804 <myproc>
    80003724:	15053503          	ld	a0,336(a0)
    80003728:	973ff0ef          	jal	ra,8000309a <idup>
    8000372c:	89aa                	mv	s3,a0
  while(*path == '/')
    8000372e:	02f00913          	li	s2,47
  len = path - s;
    80003732:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003734:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003736:	4b85                	li	s7,1
    80003738:	a861                	j	800037d0 <namex+0xdc>
    ip = iget(ROOTDEV, ROOTINO);
    8000373a:	4585                	li	a1,1
    8000373c:	4505                	li	a0,1
    8000373e:	f26ff0ef          	jal	ra,80002e64 <iget>
    80003742:	89aa                	mv	s3,a0
    80003744:	b7ed                	j	8000372e <namex+0x3a>
      iunlockput(ip);
    80003746:	854e                	mv	a0,s3
    80003748:	b8fff0ef          	jal	ra,800032d6 <iunlockput>
      return 0;
    8000374c:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000374e:	854e                	mv	a0,s3
    80003750:	60e6                	ld	ra,88(sp)
    80003752:	6446                	ld	s0,80(sp)
    80003754:	64a6                	ld	s1,72(sp)
    80003756:	6906                	ld	s2,64(sp)
    80003758:	79e2                	ld	s3,56(sp)
    8000375a:	7a42                	ld	s4,48(sp)
    8000375c:	7aa2                	ld	s5,40(sp)
    8000375e:	7b02                	ld	s6,32(sp)
    80003760:	6be2                	ld	s7,24(sp)
    80003762:	6c42                	ld	s8,16(sp)
    80003764:	6ca2                	ld	s9,8(sp)
    80003766:	6125                	addi	sp,sp,96
    80003768:	8082                	ret
      iunlock(ip);
    8000376a:	854e                	mv	a0,s3
    8000376c:	a0fff0ef          	jal	ra,8000317a <iunlock>
      return ip;
    80003770:	bff9                	j	8000374e <namex+0x5a>
      iunlockput(ip);
    80003772:	854e                	mv	a0,s3
    80003774:	b63ff0ef          	jal	ra,800032d6 <iunlockput>
      return 0;
    80003778:	89e6                	mv	s3,s9
    8000377a:	bfd1                	j	8000374e <namex+0x5a>
  len = path - s;
    8000377c:	40b48633          	sub	a2,s1,a1
    80003780:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003784:	079c5c63          	bge	s8,s9,800037fc <namex+0x108>
    memmove(name, s, DIRSIZ);
    80003788:	4639                	li	a2,14
    8000378a:	8552                	mv	a0,s4
    8000378c:	d10fd0ef          	jal	ra,80000c9c <memmove>
  while(*path == '/')
    80003790:	0004c783          	lbu	a5,0(s1)
    80003794:	01279763          	bne	a5,s2,800037a2 <namex+0xae>
    path++;
    80003798:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000379a:	0004c783          	lbu	a5,0(s1)
    8000379e:	ff278de3          	beq	a5,s2,80003798 <namex+0xa4>
    ilock(ip);
    800037a2:	854e                	mv	a0,s3
    800037a4:	92dff0ef          	jal	ra,800030d0 <ilock>
    if(ip->type != T_DIR){
    800037a8:	04499783          	lh	a5,68(s3)
    800037ac:	f9779de3          	bne	a5,s7,80003746 <namex+0x52>
    if(nameiparent && *path == '\0'){
    800037b0:	000a8563          	beqz	s5,800037ba <namex+0xc6>
    800037b4:	0004c783          	lbu	a5,0(s1)
    800037b8:	dbcd                	beqz	a5,8000376a <namex+0x76>
    if((next = dirlookup(ip, name, 0)) == 0){
    800037ba:	865a                	mv	a2,s6
    800037bc:	85d2                	mv	a1,s4
    800037be:	854e                	mv	a0,s3
    800037c0:	e99ff0ef          	jal	ra,80003658 <dirlookup>
    800037c4:	8caa                	mv	s9,a0
    800037c6:	d555                	beqz	a0,80003772 <namex+0x7e>
    iunlockput(ip);
    800037c8:	854e                	mv	a0,s3
    800037ca:	b0dff0ef          	jal	ra,800032d6 <iunlockput>
    ip = next;
    800037ce:	89e6                	mv	s3,s9
  while(*path == '/')
    800037d0:	0004c783          	lbu	a5,0(s1)
    800037d4:	05279363          	bne	a5,s2,8000381a <namex+0x126>
    path++;
    800037d8:	0485                	addi	s1,s1,1
  while(*path == '/')
    800037da:	0004c783          	lbu	a5,0(s1)
    800037de:	ff278de3          	beq	a5,s2,800037d8 <namex+0xe4>
  if(*path == 0)
    800037e2:	c78d                	beqz	a5,8000380c <namex+0x118>
    path++;
    800037e4:	85a6                	mv	a1,s1
  len = path - s;
    800037e6:	8cda                	mv	s9,s6
    800037e8:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800037ea:	01278963          	beq	a5,s2,800037fc <namex+0x108>
    800037ee:	d7d9                	beqz	a5,8000377c <namex+0x88>
    path++;
    800037f0:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800037f2:	0004c783          	lbu	a5,0(s1)
    800037f6:	ff279ce3          	bne	a5,s2,800037ee <namex+0xfa>
    800037fa:	b749                	j	8000377c <namex+0x88>
    memmove(name, s, len);
    800037fc:	2601                	sext.w	a2,a2
    800037fe:	8552                	mv	a0,s4
    80003800:	c9cfd0ef          	jal	ra,80000c9c <memmove>
    name[len] = 0;
    80003804:	9cd2                	add	s9,s9,s4
    80003806:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000380a:	b759                	j	80003790 <namex+0x9c>
  if(nameiparent){
    8000380c:	f40a81e3          	beqz	s5,8000374e <namex+0x5a>
    iput(ip);
    80003810:	854e                	mv	a0,s3
    80003812:	a3dff0ef          	jal	ra,8000324e <iput>
    return 0;
    80003816:	4981                	li	s3,0
    80003818:	bf1d                	j	8000374e <namex+0x5a>
  if(*path == 0)
    8000381a:	dbed                	beqz	a5,8000380c <namex+0x118>
  while(*path != '/' && *path != 0)
    8000381c:	0004c783          	lbu	a5,0(s1)
    80003820:	85a6                	mv	a1,s1
    80003822:	b7f1                	j	800037ee <namex+0xfa>

0000000080003824 <dirlink>:
{
    80003824:	7139                	addi	sp,sp,-64
    80003826:	fc06                	sd	ra,56(sp)
    80003828:	f822                	sd	s0,48(sp)
    8000382a:	f426                	sd	s1,40(sp)
    8000382c:	f04a                	sd	s2,32(sp)
    8000382e:	ec4e                	sd	s3,24(sp)
    80003830:	e852                	sd	s4,16(sp)
    80003832:	0080                	addi	s0,sp,64
    80003834:	892a                	mv	s2,a0
    80003836:	8a2e                	mv	s4,a1
    80003838:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000383a:	4601                	li	a2,0
    8000383c:	e1dff0ef          	jal	ra,80003658 <dirlookup>
    80003840:	e52d                	bnez	a0,800038aa <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003842:	04c92483          	lw	s1,76(s2)
    80003846:	c48d                	beqz	s1,80003870 <dirlink+0x4c>
    80003848:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000384a:	4741                	li	a4,16
    8000384c:	86a6                	mv	a3,s1
    8000384e:	fc040613          	addi	a2,s0,-64
    80003852:	4581                	li	a1,0
    80003854:	854a                	mv	a0,s2
    80003856:	c07ff0ef          	jal	ra,8000345c <readi>
    8000385a:	47c1                	li	a5,16
    8000385c:	04f51b63          	bne	a0,a5,800038b2 <dirlink+0x8e>
    if(de.inum == 0)
    80003860:	fc045783          	lhu	a5,-64(s0)
    80003864:	c791                	beqz	a5,80003870 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003866:	24c1                	addiw	s1,s1,16
    80003868:	04c92783          	lw	a5,76(s2)
    8000386c:	fcf4efe3          	bltu	s1,a5,8000384a <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003870:	4639                	li	a2,14
    80003872:	85d2                	mv	a1,s4
    80003874:	fc240513          	addi	a0,s0,-62
    80003878:	cd0fd0ef          	jal	ra,80000d48 <strncpy>
  de.inum = inum;
    8000387c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003880:	4741                	li	a4,16
    80003882:	86a6                	mv	a3,s1
    80003884:	fc040613          	addi	a2,s0,-64
    80003888:	4581                	li	a1,0
    8000388a:	854a                	mv	a0,s2
    8000388c:	cb5ff0ef          	jal	ra,80003540 <writei>
    80003890:	1541                	addi	a0,a0,-16
    80003892:	00a03533          	snez	a0,a0
    80003896:	40a00533          	neg	a0,a0
}
    8000389a:	70e2                	ld	ra,56(sp)
    8000389c:	7442                	ld	s0,48(sp)
    8000389e:	74a2                	ld	s1,40(sp)
    800038a0:	7902                	ld	s2,32(sp)
    800038a2:	69e2                	ld	s3,24(sp)
    800038a4:	6a42                	ld	s4,16(sp)
    800038a6:	6121                	addi	sp,sp,64
    800038a8:	8082                	ret
    iput(ip);
    800038aa:	9a5ff0ef          	jal	ra,8000324e <iput>
    return -1;
    800038ae:	557d                	li	a0,-1
    800038b0:	b7ed                	j	8000389a <dirlink+0x76>
      panic("dirlink read");
    800038b2:	00004517          	auipc	a0,0x4
    800038b6:	d2650513          	addi	a0,a0,-730 # 800075d8 <syscalls+0x1e8>
    800038ba:	ed1fc0ef          	jal	ra,8000078a <panic>

00000000800038be <namei>:

struct inode*
namei(char *path)
{
    800038be:	1101                	addi	sp,sp,-32
    800038c0:	ec06                	sd	ra,24(sp)
    800038c2:	e822                	sd	s0,16(sp)
    800038c4:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800038c6:	fe040613          	addi	a2,s0,-32
    800038ca:	4581                	li	a1,0
    800038cc:	e29ff0ef          	jal	ra,800036f4 <namex>
}
    800038d0:	60e2                	ld	ra,24(sp)
    800038d2:	6442                	ld	s0,16(sp)
    800038d4:	6105                	addi	sp,sp,32
    800038d6:	8082                	ret

00000000800038d8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800038d8:	1141                	addi	sp,sp,-16
    800038da:	e406                	sd	ra,8(sp)
    800038dc:	e022                	sd	s0,0(sp)
    800038de:	0800                	addi	s0,sp,16
    800038e0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800038e2:	4585                	li	a1,1
    800038e4:	e11ff0ef          	jal	ra,800036f4 <namex>
}
    800038e8:	60a2                	ld	ra,8(sp)
    800038ea:	6402                	ld	s0,0(sp)
    800038ec:	0141                	addi	sp,sp,16
    800038ee:	8082                	ret

00000000800038f0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800038f0:	1101                	addi	sp,sp,-32
    800038f2:	ec06                	sd	ra,24(sp)
    800038f4:	e822                	sd	s0,16(sp)
    800038f6:	e426                	sd	s1,8(sp)
    800038f8:	e04a                	sd	s2,0(sp)
    800038fa:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800038fc:	0001c917          	auipc	s2,0x1c
    80003900:	02c90913          	addi	s2,s2,44 # 8001f928 <log>
    80003904:	01892583          	lw	a1,24(s2)
    80003908:	02492503          	lw	a0,36(s2)
    8000390c:	912ff0ef          	jal	ra,80002a1e <bread>
    80003910:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003912:	02892683          	lw	a3,40(s2)
    80003916:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003918:	02d05763          	blez	a3,80003946 <write_head+0x56>
    8000391c:	0001c797          	auipc	a5,0x1c
    80003920:	03878793          	addi	a5,a5,56 # 8001f954 <log+0x2c>
    80003924:	05c50713          	addi	a4,a0,92
    80003928:	36fd                	addiw	a3,a3,-1
    8000392a:	1682                	slli	a3,a3,0x20
    8000392c:	9281                	srli	a3,a3,0x20
    8000392e:	068a                	slli	a3,a3,0x2
    80003930:	0001c617          	auipc	a2,0x1c
    80003934:	02860613          	addi	a2,a2,40 # 8001f958 <log+0x30>
    80003938:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000393a:	4390                	lw	a2,0(a5)
    8000393c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000393e:	0791                	addi	a5,a5,4
    80003940:	0711                	addi	a4,a4,4
    80003942:	fed79ce3          	bne	a5,a3,8000393a <write_head+0x4a>
  }
  bwrite(buf);
    80003946:	8526                	mv	a0,s1
    80003948:	9acff0ef          	jal	ra,80002af4 <bwrite>
  brelse(buf);
    8000394c:	8526                	mv	a0,s1
    8000394e:	9d8ff0ef          	jal	ra,80002b26 <brelse>
}
    80003952:	60e2                	ld	ra,24(sp)
    80003954:	6442                	ld	s0,16(sp)
    80003956:	64a2                	ld	s1,8(sp)
    80003958:	6902                	ld	s2,0(sp)
    8000395a:	6105                	addi	sp,sp,32
    8000395c:	8082                	ret

000000008000395e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000395e:	0001c797          	auipc	a5,0x1c
    80003962:	ff27a783          	lw	a5,-14(a5) # 8001f950 <log+0x28>
    80003966:	0af05e63          	blez	a5,80003a22 <install_trans+0xc4>
{
    8000396a:	715d                	addi	sp,sp,-80
    8000396c:	e486                	sd	ra,72(sp)
    8000396e:	e0a2                	sd	s0,64(sp)
    80003970:	fc26                	sd	s1,56(sp)
    80003972:	f84a                	sd	s2,48(sp)
    80003974:	f44e                	sd	s3,40(sp)
    80003976:	f052                	sd	s4,32(sp)
    80003978:	ec56                	sd	s5,24(sp)
    8000397a:	e85a                	sd	s6,16(sp)
    8000397c:	e45e                	sd	s7,8(sp)
    8000397e:	0880                	addi	s0,sp,80
    80003980:	8b2a                	mv	s6,a0
    80003982:	0001ca97          	auipc	s5,0x1c
    80003986:	fd2a8a93          	addi	s5,s5,-46 # 8001f954 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000398a:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    8000398c:	00004b97          	auipc	s7,0x4
    80003990:	c5cb8b93          	addi	s7,s7,-932 # 800075e8 <syscalls+0x1f8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003994:	0001ca17          	auipc	s4,0x1c
    80003998:	f94a0a13          	addi	s4,s4,-108 # 8001f928 <log>
    8000399c:	a025                	j	800039c4 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    8000399e:	000aa603          	lw	a2,0(s5)
    800039a2:	85ce                	mv	a1,s3
    800039a4:	855e                	mv	a0,s7
    800039a6:	b1ffc0ef          	jal	ra,800004c4 <printf>
    800039aa:	a839                	j	800039c8 <install_trans+0x6a>
    brelse(lbuf);
    800039ac:	854a                	mv	a0,s2
    800039ae:	978ff0ef          	jal	ra,80002b26 <brelse>
    brelse(dbuf);
    800039b2:	8526                	mv	a0,s1
    800039b4:	972ff0ef          	jal	ra,80002b26 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800039b8:	2985                	addiw	s3,s3,1
    800039ba:	0a91                	addi	s5,s5,4
    800039bc:	028a2783          	lw	a5,40(s4)
    800039c0:	04f9d663          	bge	s3,a5,80003a0c <install_trans+0xae>
    if(recovering) {
    800039c4:	fc0b1de3          	bnez	s6,8000399e <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800039c8:	018a2583          	lw	a1,24(s4)
    800039cc:	013585bb          	addw	a1,a1,s3
    800039d0:	2585                	addiw	a1,a1,1
    800039d2:	024a2503          	lw	a0,36(s4)
    800039d6:	848ff0ef          	jal	ra,80002a1e <bread>
    800039da:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800039dc:	000aa583          	lw	a1,0(s5)
    800039e0:	024a2503          	lw	a0,36(s4)
    800039e4:	83aff0ef          	jal	ra,80002a1e <bread>
    800039e8:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800039ea:	40000613          	li	a2,1024
    800039ee:	05890593          	addi	a1,s2,88
    800039f2:	05850513          	addi	a0,a0,88
    800039f6:	aa6fd0ef          	jal	ra,80000c9c <memmove>
    bwrite(dbuf);  // write dst to disk
    800039fa:	8526                	mv	a0,s1
    800039fc:	8f8ff0ef          	jal	ra,80002af4 <bwrite>
    if(recovering == 0)
    80003a00:	fa0b16e3          	bnez	s6,800039ac <install_trans+0x4e>
      bunpin(dbuf);
    80003a04:	8526                	mv	a0,s1
    80003a06:	9deff0ef          	jal	ra,80002be4 <bunpin>
    80003a0a:	b74d                	j	800039ac <install_trans+0x4e>
}
    80003a0c:	60a6                	ld	ra,72(sp)
    80003a0e:	6406                	ld	s0,64(sp)
    80003a10:	74e2                	ld	s1,56(sp)
    80003a12:	7942                	ld	s2,48(sp)
    80003a14:	79a2                	ld	s3,40(sp)
    80003a16:	7a02                	ld	s4,32(sp)
    80003a18:	6ae2                	ld	s5,24(sp)
    80003a1a:	6b42                	ld	s6,16(sp)
    80003a1c:	6ba2                	ld	s7,8(sp)
    80003a1e:	6161                	addi	sp,sp,80
    80003a20:	8082                	ret
    80003a22:	8082                	ret

0000000080003a24 <initlog>:
{
    80003a24:	7179                	addi	sp,sp,-48
    80003a26:	f406                	sd	ra,40(sp)
    80003a28:	f022                	sd	s0,32(sp)
    80003a2a:	ec26                	sd	s1,24(sp)
    80003a2c:	e84a                	sd	s2,16(sp)
    80003a2e:	e44e                	sd	s3,8(sp)
    80003a30:	1800                	addi	s0,sp,48
    80003a32:	892a                	mv	s2,a0
    80003a34:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003a36:	0001c497          	auipc	s1,0x1c
    80003a3a:	ef248493          	addi	s1,s1,-270 # 8001f928 <log>
    80003a3e:	00004597          	auipc	a1,0x4
    80003a42:	bca58593          	addi	a1,a1,-1078 # 80007608 <syscalls+0x218>
    80003a46:	8526                	mv	a0,s1
    80003a48:	8a4fd0ef          	jal	ra,80000aec <initlock>
  log.start = sb->logstart;
    80003a4c:	0149a583          	lw	a1,20(s3)
    80003a50:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003a52:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003a56:	854a                	mv	a0,s2
    80003a58:	fc7fe0ef          	jal	ra,80002a1e <bread>
  log.lh.n = lh->n;
    80003a5c:	4d34                	lw	a3,88(a0)
    80003a5e:	d494                	sw	a3,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003a60:	02d05563          	blez	a3,80003a8a <initlog+0x66>
    80003a64:	05c50793          	addi	a5,a0,92
    80003a68:	0001c717          	auipc	a4,0x1c
    80003a6c:	eec70713          	addi	a4,a4,-276 # 8001f954 <log+0x2c>
    80003a70:	36fd                	addiw	a3,a3,-1
    80003a72:	1682                	slli	a3,a3,0x20
    80003a74:	9281                	srli	a3,a3,0x20
    80003a76:	068a                	slli	a3,a3,0x2
    80003a78:	06050613          	addi	a2,a0,96
    80003a7c:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80003a7e:	4390                	lw	a2,0(a5)
    80003a80:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003a82:	0791                	addi	a5,a5,4
    80003a84:	0711                	addi	a4,a4,4
    80003a86:	fed79ce3          	bne	a5,a3,80003a7e <initlog+0x5a>
  brelse(buf);
    80003a8a:	89cff0ef          	jal	ra,80002b26 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003a8e:	4505                	li	a0,1
    80003a90:	ecfff0ef          	jal	ra,8000395e <install_trans>
  log.lh.n = 0;
    80003a94:	0001c797          	auipc	a5,0x1c
    80003a98:	ea07ae23          	sw	zero,-324(a5) # 8001f950 <log+0x28>
  write_head(); // clear the log
    80003a9c:	e55ff0ef          	jal	ra,800038f0 <write_head>
}
    80003aa0:	70a2                	ld	ra,40(sp)
    80003aa2:	7402                	ld	s0,32(sp)
    80003aa4:	64e2                	ld	s1,24(sp)
    80003aa6:	6942                	ld	s2,16(sp)
    80003aa8:	69a2                	ld	s3,8(sp)
    80003aaa:	6145                	addi	sp,sp,48
    80003aac:	8082                	ret

0000000080003aae <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003aae:	1101                	addi	sp,sp,-32
    80003ab0:	ec06                	sd	ra,24(sp)
    80003ab2:	e822                	sd	s0,16(sp)
    80003ab4:	e426                	sd	s1,8(sp)
    80003ab6:	e04a                	sd	s2,0(sp)
    80003ab8:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003aba:	0001c517          	auipc	a0,0x1c
    80003abe:	e6e50513          	addi	a0,a0,-402 # 8001f928 <log>
    80003ac2:	8aafd0ef          	jal	ra,80000b6c <acquire>
  while(1){
    if(log.committing){
    80003ac6:	0001c497          	auipc	s1,0x1c
    80003aca:	e6248493          	addi	s1,s1,-414 # 8001f928 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003ace:	4979                	li	s2,30
    80003ad0:	a029                	j	80003ada <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003ad2:	85a6                	mv	a1,s1
    80003ad4:	8526                	mv	a0,s1
    80003ad6:	b24fe0ef          	jal	ra,80001dfa <sleep>
    if(log.committing){
    80003ada:	509c                	lw	a5,32(s1)
    80003adc:	fbfd                	bnez	a5,80003ad2 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003ade:	4cdc                	lw	a5,28(s1)
    80003ae0:	0017871b          	addiw	a4,a5,1
    80003ae4:	0007069b          	sext.w	a3,a4
    80003ae8:	0027179b          	slliw	a5,a4,0x2
    80003aec:	9fb9                	addw	a5,a5,a4
    80003aee:	0017979b          	slliw	a5,a5,0x1
    80003af2:	5498                	lw	a4,40(s1)
    80003af4:	9fb9                	addw	a5,a5,a4
    80003af6:	00f95763          	bge	s2,a5,80003b04 <begin_op+0x56>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003afa:	85a6                	mv	a1,s1
    80003afc:	8526                	mv	a0,s1
    80003afe:	afcfe0ef          	jal	ra,80001dfa <sleep>
    80003b02:	bfe1                	j	80003ada <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003b04:	0001c517          	auipc	a0,0x1c
    80003b08:	e2450513          	addi	a0,a0,-476 # 8001f928 <log>
    80003b0c:	cd54                	sw	a3,28(a0)
      release(&log.lock);
    80003b0e:	8f6fd0ef          	jal	ra,80000c04 <release>
      break;
    }
  }
}
    80003b12:	60e2                	ld	ra,24(sp)
    80003b14:	6442                	ld	s0,16(sp)
    80003b16:	64a2                	ld	s1,8(sp)
    80003b18:	6902                	ld	s2,0(sp)
    80003b1a:	6105                	addi	sp,sp,32
    80003b1c:	8082                	ret

0000000080003b1e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003b1e:	7139                	addi	sp,sp,-64
    80003b20:	fc06                	sd	ra,56(sp)
    80003b22:	f822                	sd	s0,48(sp)
    80003b24:	f426                	sd	s1,40(sp)
    80003b26:	f04a                	sd	s2,32(sp)
    80003b28:	ec4e                	sd	s3,24(sp)
    80003b2a:	e852                	sd	s4,16(sp)
    80003b2c:	e456                	sd	s5,8(sp)
    80003b2e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003b30:	0001c497          	auipc	s1,0x1c
    80003b34:	df848493          	addi	s1,s1,-520 # 8001f928 <log>
    80003b38:	8526                	mv	a0,s1
    80003b3a:	832fd0ef          	jal	ra,80000b6c <acquire>
  log.outstanding -= 1;
    80003b3e:	4cdc                	lw	a5,28(s1)
    80003b40:	37fd                	addiw	a5,a5,-1
    80003b42:	0007891b          	sext.w	s2,a5
    80003b46:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003b48:	509c                	lw	a5,32(s1)
    80003b4a:	ef9d                	bnez	a5,80003b88 <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    80003b4c:	04091463          	bnez	s2,80003b94 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003b50:	0001c497          	auipc	s1,0x1c
    80003b54:	dd848493          	addi	s1,s1,-552 # 8001f928 <log>
    80003b58:	4785                	li	a5,1
    80003b5a:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003b5c:	8526                	mv	a0,s1
    80003b5e:	8a6fd0ef          	jal	ra,80000c04 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003b62:	549c                	lw	a5,40(s1)
    80003b64:	04f04b63          	bgtz	a5,80003bba <end_op+0x9c>
    acquire(&log.lock);
    80003b68:	0001c497          	auipc	s1,0x1c
    80003b6c:	dc048493          	addi	s1,s1,-576 # 8001f928 <log>
    80003b70:	8526                	mv	a0,s1
    80003b72:	ffbfc0ef          	jal	ra,80000b6c <acquire>
    log.committing = 0;
    80003b76:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003b7a:	8526                	mv	a0,s1
    80003b7c:	acafe0ef          	jal	ra,80001e46 <wakeup>
    release(&log.lock);
    80003b80:	8526                	mv	a0,s1
    80003b82:	882fd0ef          	jal	ra,80000c04 <release>
}
    80003b86:	a00d                	j	80003ba8 <end_op+0x8a>
    panic("log.committing");
    80003b88:	00004517          	auipc	a0,0x4
    80003b8c:	a8850513          	addi	a0,a0,-1400 # 80007610 <syscalls+0x220>
    80003b90:	bfbfc0ef          	jal	ra,8000078a <panic>
    wakeup(&log);
    80003b94:	0001c497          	auipc	s1,0x1c
    80003b98:	d9448493          	addi	s1,s1,-620 # 8001f928 <log>
    80003b9c:	8526                	mv	a0,s1
    80003b9e:	aa8fe0ef          	jal	ra,80001e46 <wakeup>
  release(&log.lock);
    80003ba2:	8526                	mv	a0,s1
    80003ba4:	860fd0ef          	jal	ra,80000c04 <release>
}
    80003ba8:	70e2                	ld	ra,56(sp)
    80003baa:	7442                	ld	s0,48(sp)
    80003bac:	74a2                	ld	s1,40(sp)
    80003bae:	7902                	ld	s2,32(sp)
    80003bb0:	69e2                	ld	s3,24(sp)
    80003bb2:	6a42                	ld	s4,16(sp)
    80003bb4:	6aa2                	ld	s5,8(sp)
    80003bb6:	6121                	addi	sp,sp,64
    80003bb8:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bba:	0001ca97          	auipc	s5,0x1c
    80003bbe:	d9aa8a93          	addi	s5,s5,-614 # 8001f954 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003bc2:	0001ca17          	auipc	s4,0x1c
    80003bc6:	d66a0a13          	addi	s4,s4,-666 # 8001f928 <log>
    80003bca:	018a2583          	lw	a1,24(s4)
    80003bce:	012585bb          	addw	a1,a1,s2
    80003bd2:	2585                	addiw	a1,a1,1
    80003bd4:	024a2503          	lw	a0,36(s4)
    80003bd8:	e47fe0ef          	jal	ra,80002a1e <bread>
    80003bdc:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003bde:	000aa583          	lw	a1,0(s5)
    80003be2:	024a2503          	lw	a0,36(s4)
    80003be6:	e39fe0ef          	jal	ra,80002a1e <bread>
    80003bea:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003bec:	40000613          	li	a2,1024
    80003bf0:	05850593          	addi	a1,a0,88
    80003bf4:	05848513          	addi	a0,s1,88
    80003bf8:	8a4fd0ef          	jal	ra,80000c9c <memmove>
    bwrite(to);  // write the log
    80003bfc:	8526                	mv	a0,s1
    80003bfe:	ef7fe0ef          	jal	ra,80002af4 <bwrite>
    brelse(from);
    80003c02:	854e                	mv	a0,s3
    80003c04:	f23fe0ef          	jal	ra,80002b26 <brelse>
    brelse(to);
    80003c08:	8526                	mv	a0,s1
    80003c0a:	f1dfe0ef          	jal	ra,80002b26 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c0e:	2905                	addiw	s2,s2,1
    80003c10:	0a91                	addi	s5,s5,4
    80003c12:	028a2783          	lw	a5,40(s4)
    80003c16:	faf94ae3          	blt	s2,a5,80003bca <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003c1a:	cd7ff0ef          	jal	ra,800038f0 <write_head>
    install_trans(0); // Now install writes to home locations
    80003c1e:	4501                	li	a0,0
    80003c20:	d3fff0ef          	jal	ra,8000395e <install_trans>
    log.lh.n = 0;
    80003c24:	0001c797          	auipc	a5,0x1c
    80003c28:	d207a623          	sw	zero,-724(a5) # 8001f950 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003c2c:	cc5ff0ef          	jal	ra,800038f0 <write_head>
    80003c30:	bf25                	j	80003b68 <end_op+0x4a>

0000000080003c32 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003c32:	1101                	addi	sp,sp,-32
    80003c34:	ec06                	sd	ra,24(sp)
    80003c36:	e822                	sd	s0,16(sp)
    80003c38:	e426                	sd	s1,8(sp)
    80003c3a:	e04a                	sd	s2,0(sp)
    80003c3c:	1000                	addi	s0,sp,32
    80003c3e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003c40:	0001c917          	auipc	s2,0x1c
    80003c44:	ce890913          	addi	s2,s2,-792 # 8001f928 <log>
    80003c48:	854a                	mv	a0,s2
    80003c4a:	f23fc0ef          	jal	ra,80000b6c <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003c4e:	02892603          	lw	a2,40(s2)
    80003c52:	47f5                	li	a5,29
    80003c54:	04c7cc63          	blt	a5,a2,80003cac <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003c58:	0001c797          	auipc	a5,0x1c
    80003c5c:	cec7a783          	lw	a5,-788(a5) # 8001f944 <log+0x1c>
    80003c60:	04f05c63          	blez	a5,80003cb8 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003c64:	4781                	li	a5,0
    80003c66:	04c05f63          	blez	a2,80003cc4 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003c6a:	44cc                	lw	a1,12(s1)
    80003c6c:	0001c717          	auipc	a4,0x1c
    80003c70:	ce870713          	addi	a4,a4,-792 # 8001f954 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003c74:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003c76:	4314                	lw	a3,0(a4)
    80003c78:	04b68663          	beq	a3,a1,80003cc4 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003c7c:	2785                	addiw	a5,a5,1
    80003c7e:	0711                	addi	a4,a4,4
    80003c80:	fef61be3          	bne	a2,a5,80003c76 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003c84:	0621                	addi	a2,a2,8
    80003c86:	060a                	slli	a2,a2,0x2
    80003c88:	0001c797          	auipc	a5,0x1c
    80003c8c:	ca078793          	addi	a5,a5,-864 # 8001f928 <log>
    80003c90:	963e                	add	a2,a2,a5
    80003c92:	44dc                	lw	a5,12(s1)
    80003c94:	c65c                	sw	a5,12(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003c96:	8526                	mv	a0,s1
    80003c98:	f19fe0ef          	jal	ra,80002bb0 <bpin>
    log.lh.n++;
    80003c9c:	0001c717          	auipc	a4,0x1c
    80003ca0:	c8c70713          	addi	a4,a4,-884 # 8001f928 <log>
    80003ca4:	571c                	lw	a5,40(a4)
    80003ca6:	2785                	addiw	a5,a5,1
    80003ca8:	d71c                	sw	a5,40(a4)
    80003caa:	a815                	j	80003cde <log_write+0xac>
    panic("too big a transaction");
    80003cac:	00004517          	auipc	a0,0x4
    80003cb0:	97450513          	addi	a0,a0,-1676 # 80007620 <syscalls+0x230>
    80003cb4:	ad7fc0ef          	jal	ra,8000078a <panic>
    panic("log_write outside of trans");
    80003cb8:	00004517          	auipc	a0,0x4
    80003cbc:	98050513          	addi	a0,a0,-1664 # 80007638 <syscalls+0x248>
    80003cc0:	acbfc0ef          	jal	ra,8000078a <panic>
  log.lh.block[i] = b->blockno;
    80003cc4:	00878713          	addi	a4,a5,8
    80003cc8:	00271693          	slli	a3,a4,0x2
    80003ccc:	0001c717          	auipc	a4,0x1c
    80003cd0:	c5c70713          	addi	a4,a4,-932 # 8001f928 <log>
    80003cd4:	9736                	add	a4,a4,a3
    80003cd6:	44d4                	lw	a3,12(s1)
    80003cd8:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003cda:	faf60ee3          	beq	a2,a5,80003c96 <log_write+0x64>
  }
  release(&log.lock);
    80003cde:	0001c517          	auipc	a0,0x1c
    80003ce2:	c4a50513          	addi	a0,a0,-950 # 8001f928 <log>
    80003ce6:	f1ffc0ef          	jal	ra,80000c04 <release>
}
    80003cea:	60e2                	ld	ra,24(sp)
    80003cec:	6442                	ld	s0,16(sp)
    80003cee:	64a2                	ld	s1,8(sp)
    80003cf0:	6902                	ld	s2,0(sp)
    80003cf2:	6105                	addi	sp,sp,32
    80003cf4:	8082                	ret

0000000080003cf6 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003cf6:	1101                	addi	sp,sp,-32
    80003cf8:	ec06                	sd	ra,24(sp)
    80003cfa:	e822                	sd	s0,16(sp)
    80003cfc:	e426                	sd	s1,8(sp)
    80003cfe:	e04a                	sd	s2,0(sp)
    80003d00:	1000                	addi	s0,sp,32
    80003d02:	84aa                	mv	s1,a0
    80003d04:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003d06:	00004597          	auipc	a1,0x4
    80003d0a:	95258593          	addi	a1,a1,-1710 # 80007658 <syscalls+0x268>
    80003d0e:	0521                	addi	a0,a0,8
    80003d10:	dddfc0ef          	jal	ra,80000aec <initlock>
  lk->name = name;
    80003d14:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003d18:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003d1c:	0204a423          	sw	zero,40(s1)
}
    80003d20:	60e2                	ld	ra,24(sp)
    80003d22:	6442                	ld	s0,16(sp)
    80003d24:	64a2                	ld	s1,8(sp)
    80003d26:	6902                	ld	s2,0(sp)
    80003d28:	6105                	addi	sp,sp,32
    80003d2a:	8082                	ret

0000000080003d2c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003d2c:	1101                	addi	sp,sp,-32
    80003d2e:	ec06                	sd	ra,24(sp)
    80003d30:	e822                	sd	s0,16(sp)
    80003d32:	e426                	sd	s1,8(sp)
    80003d34:	e04a                	sd	s2,0(sp)
    80003d36:	1000                	addi	s0,sp,32
    80003d38:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003d3a:	00850913          	addi	s2,a0,8
    80003d3e:	854a                	mv	a0,s2
    80003d40:	e2dfc0ef          	jal	ra,80000b6c <acquire>
  while (lk->locked) {
    80003d44:	409c                	lw	a5,0(s1)
    80003d46:	c799                	beqz	a5,80003d54 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003d48:	85ca                	mv	a1,s2
    80003d4a:	8526                	mv	a0,s1
    80003d4c:	8aefe0ef          	jal	ra,80001dfa <sleep>
  while (lk->locked) {
    80003d50:	409c                	lw	a5,0(s1)
    80003d52:	fbfd                	bnez	a5,80003d48 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003d54:	4785                	li	a5,1
    80003d56:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003d58:	aadfd0ef          	jal	ra,80001804 <myproc>
    80003d5c:	591c                	lw	a5,48(a0)
    80003d5e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003d60:	854a                	mv	a0,s2
    80003d62:	ea3fc0ef          	jal	ra,80000c04 <release>
}
    80003d66:	60e2                	ld	ra,24(sp)
    80003d68:	6442                	ld	s0,16(sp)
    80003d6a:	64a2                	ld	s1,8(sp)
    80003d6c:	6902                	ld	s2,0(sp)
    80003d6e:	6105                	addi	sp,sp,32
    80003d70:	8082                	ret

0000000080003d72 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003d72:	1101                	addi	sp,sp,-32
    80003d74:	ec06                	sd	ra,24(sp)
    80003d76:	e822                	sd	s0,16(sp)
    80003d78:	e426                	sd	s1,8(sp)
    80003d7a:	e04a                	sd	s2,0(sp)
    80003d7c:	1000                	addi	s0,sp,32
    80003d7e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003d80:	00850913          	addi	s2,a0,8
    80003d84:	854a                	mv	a0,s2
    80003d86:	de7fc0ef          	jal	ra,80000b6c <acquire>
  lk->locked = 0;
    80003d8a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003d8e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003d92:	8526                	mv	a0,s1
    80003d94:	8b2fe0ef          	jal	ra,80001e46 <wakeup>
  release(&lk->lk);
    80003d98:	854a                	mv	a0,s2
    80003d9a:	e6bfc0ef          	jal	ra,80000c04 <release>
}
    80003d9e:	60e2                	ld	ra,24(sp)
    80003da0:	6442                	ld	s0,16(sp)
    80003da2:	64a2                	ld	s1,8(sp)
    80003da4:	6902                	ld	s2,0(sp)
    80003da6:	6105                	addi	sp,sp,32
    80003da8:	8082                	ret

0000000080003daa <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003daa:	7179                	addi	sp,sp,-48
    80003dac:	f406                	sd	ra,40(sp)
    80003dae:	f022                	sd	s0,32(sp)
    80003db0:	ec26                	sd	s1,24(sp)
    80003db2:	e84a                	sd	s2,16(sp)
    80003db4:	e44e                	sd	s3,8(sp)
    80003db6:	1800                	addi	s0,sp,48
    80003db8:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003dba:	00850913          	addi	s2,a0,8
    80003dbe:	854a                	mv	a0,s2
    80003dc0:	dadfc0ef          	jal	ra,80000b6c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003dc4:	409c                	lw	a5,0(s1)
    80003dc6:	ef89                	bnez	a5,80003de0 <holdingsleep+0x36>
    80003dc8:	4481                	li	s1,0
  release(&lk->lk);
    80003dca:	854a                	mv	a0,s2
    80003dcc:	e39fc0ef          	jal	ra,80000c04 <release>
  return r;
}
    80003dd0:	8526                	mv	a0,s1
    80003dd2:	70a2                	ld	ra,40(sp)
    80003dd4:	7402                	ld	s0,32(sp)
    80003dd6:	64e2                	ld	s1,24(sp)
    80003dd8:	6942                	ld	s2,16(sp)
    80003dda:	69a2                	ld	s3,8(sp)
    80003ddc:	6145                	addi	sp,sp,48
    80003dde:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80003de0:	0284a983          	lw	s3,40(s1)
    80003de4:	a21fd0ef          	jal	ra,80001804 <myproc>
    80003de8:	5904                	lw	s1,48(a0)
    80003dea:	413484b3          	sub	s1,s1,s3
    80003dee:	0014b493          	seqz	s1,s1
    80003df2:	bfe1                	j	80003dca <holdingsleep+0x20>

0000000080003df4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003df4:	1141                	addi	sp,sp,-16
    80003df6:	e406                	sd	ra,8(sp)
    80003df8:	e022                	sd	s0,0(sp)
    80003dfa:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003dfc:	00004597          	auipc	a1,0x4
    80003e00:	86c58593          	addi	a1,a1,-1940 # 80007668 <syscalls+0x278>
    80003e04:	0001c517          	auipc	a0,0x1c
    80003e08:	c6c50513          	addi	a0,a0,-916 # 8001fa70 <ftable>
    80003e0c:	ce1fc0ef          	jal	ra,80000aec <initlock>
}
    80003e10:	60a2                	ld	ra,8(sp)
    80003e12:	6402                	ld	s0,0(sp)
    80003e14:	0141                	addi	sp,sp,16
    80003e16:	8082                	ret

0000000080003e18 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003e18:	1101                	addi	sp,sp,-32
    80003e1a:	ec06                	sd	ra,24(sp)
    80003e1c:	e822                	sd	s0,16(sp)
    80003e1e:	e426                	sd	s1,8(sp)
    80003e20:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003e22:	0001c517          	auipc	a0,0x1c
    80003e26:	c4e50513          	addi	a0,a0,-946 # 8001fa70 <ftable>
    80003e2a:	d43fc0ef          	jal	ra,80000b6c <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003e2e:	0001c497          	auipc	s1,0x1c
    80003e32:	c5a48493          	addi	s1,s1,-934 # 8001fa88 <ftable+0x18>
    80003e36:	0001d717          	auipc	a4,0x1d
    80003e3a:	bf270713          	addi	a4,a4,-1038 # 80020a28 <disk>
    if(f->ref == 0){
    80003e3e:	40dc                	lw	a5,4(s1)
    80003e40:	cf89                	beqz	a5,80003e5a <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003e42:	02848493          	addi	s1,s1,40
    80003e46:	fee49ce3          	bne	s1,a4,80003e3e <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003e4a:	0001c517          	auipc	a0,0x1c
    80003e4e:	c2650513          	addi	a0,a0,-986 # 8001fa70 <ftable>
    80003e52:	db3fc0ef          	jal	ra,80000c04 <release>
  return 0;
    80003e56:	4481                	li	s1,0
    80003e58:	a809                	j	80003e6a <filealloc+0x52>
      f->ref = 1;
    80003e5a:	4785                	li	a5,1
    80003e5c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003e5e:	0001c517          	auipc	a0,0x1c
    80003e62:	c1250513          	addi	a0,a0,-1006 # 8001fa70 <ftable>
    80003e66:	d9ffc0ef          	jal	ra,80000c04 <release>
}
    80003e6a:	8526                	mv	a0,s1
    80003e6c:	60e2                	ld	ra,24(sp)
    80003e6e:	6442                	ld	s0,16(sp)
    80003e70:	64a2                	ld	s1,8(sp)
    80003e72:	6105                	addi	sp,sp,32
    80003e74:	8082                	ret

0000000080003e76 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003e76:	1101                	addi	sp,sp,-32
    80003e78:	ec06                	sd	ra,24(sp)
    80003e7a:	e822                	sd	s0,16(sp)
    80003e7c:	e426                	sd	s1,8(sp)
    80003e7e:	1000                	addi	s0,sp,32
    80003e80:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003e82:	0001c517          	auipc	a0,0x1c
    80003e86:	bee50513          	addi	a0,a0,-1042 # 8001fa70 <ftable>
    80003e8a:	ce3fc0ef          	jal	ra,80000b6c <acquire>
  if(f->ref < 1)
    80003e8e:	40dc                	lw	a5,4(s1)
    80003e90:	02f05063          	blez	a5,80003eb0 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003e94:	2785                	addiw	a5,a5,1
    80003e96:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003e98:	0001c517          	auipc	a0,0x1c
    80003e9c:	bd850513          	addi	a0,a0,-1064 # 8001fa70 <ftable>
    80003ea0:	d65fc0ef          	jal	ra,80000c04 <release>
  return f;
}
    80003ea4:	8526                	mv	a0,s1
    80003ea6:	60e2                	ld	ra,24(sp)
    80003ea8:	6442                	ld	s0,16(sp)
    80003eaa:	64a2                	ld	s1,8(sp)
    80003eac:	6105                	addi	sp,sp,32
    80003eae:	8082                	ret
    panic("filedup");
    80003eb0:	00003517          	auipc	a0,0x3
    80003eb4:	7c050513          	addi	a0,a0,1984 # 80007670 <syscalls+0x280>
    80003eb8:	8d3fc0ef          	jal	ra,8000078a <panic>

0000000080003ebc <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003ebc:	7139                	addi	sp,sp,-64
    80003ebe:	fc06                	sd	ra,56(sp)
    80003ec0:	f822                	sd	s0,48(sp)
    80003ec2:	f426                	sd	s1,40(sp)
    80003ec4:	f04a                	sd	s2,32(sp)
    80003ec6:	ec4e                	sd	s3,24(sp)
    80003ec8:	e852                	sd	s4,16(sp)
    80003eca:	e456                	sd	s5,8(sp)
    80003ecc:	0080                	addi	s0,sp,64
    80003ece:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003ed0:	0001c517          	auipc	a0,0x1c
    80003ed4:	ba050513          	addi	a0,a0,-1120 # 8001fa70 <ftable>
    80003ed8:	c95fc0ef          	jal	ra,80000b6c <acquire>
  if(f->ref < 1)
    80003edc:	40dc                	lw	a5,4(s1)
    80003ede:	04f05963          	blez	a5,80003f30 <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    80003ee2:	37fd                	addiw	a5,a5,-1
    80003ee4:	0007871b          	sext.w	a4,a5
    80003ee8:	c0dc                	sw	a5,4(s1)
    80003eea:	04e04963          	bgtz	a4,80003f3c <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003eee:	0004a903          	lw	s2,0(s1)
    80003ef2:	0094ca83          	lbu	s5,9(s1)
    80003ef6:	0104ba03          	ld	s4,16(s1)
    80003efa:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003efe:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003f02:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003f06:	0001c517          	auipc	a0,0x1c
    80003f0a:	b6a50513          	addi	a0,a0,-1174 # 8001fa70 <ftable>
    80003f0e:	cf7fc0ef          	jal	ra,80000c04 <release>

  if(ff.type == FD_PIPE){
    80003f12:	4785                	li	a5,1
    80003f14:	04f90363          	beq	s2,a5,80003f5a <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003f18:	3979                	addiw	s2,s2,-2
    80003f1a:	4785                	li	a5,1
    80003f1c:	0327e663          	bltu	a5,s2,80003f48 <fileclose+0x8c>
    begin_op();
    80003f20:	b8fff0ef          	jal	ra,80003aae <begin_op>
    iput(ff.ip);
    80003f24:	854e                	mv	a0,s3
    80003f26:	b28ff0ef          	jal	ra,8000324e <iput>
    end_op();
    80003f2a:	bf5ff0ef          	jal	ra,80003b1e <end_op>
    80003f2e:	a829                	j	80003f48 <fileclose+0x8c>
    panic("fileclose");
    80003f30:	00003517          	auipc	a0,0x3
    80003f34:	74850513          	addi	a0,a0,1864 # 80007678 <syscalls+0x288>
    80003f38:	853fc0ef          	jal	ra,8000078a <panic>
    release(&ftable.lock);
    80003f3c:	0001c517          	auipc	a0,0x1c
    80003f40:	b3450513          	addi	a0,a0,-1228 # 8001fa70 <ftable>
    80003f44:	cc1fc0ef          	jal	ra,80000c04 <release>
  }
}
    80003f48:	70e2                	ld	ra,56(sp)
    80003f4a:	7442                	ld	s0,48(sp)
    80003f4c:	74a2                	ld	s1,40(sp)
    80003f4e:	7902                	ld	s2,32(sp)
    80003f50:	69e2                	ld	s3,24(sp)
    80003f52:	6a42                	ld	s4,16(sp)
    80003f54:	6aa2                	ld	s5,8(sp)
    80003f56:	6121                	addi	sp,sp,64
    80003f58:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003f5a:	85d6                	mv	a1,s5
    80003f5c:	8552                	mv	a0,s4
    80003f5e:	2ec000ef          	jal	ra,8000424a <pipeclose>
    80003f62:	b7dd                	j	80003f48 <fileclose+0x8c>

0000000080003f64 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003f64:	715d                	addi	sp,sp,-80
    80003f66:	e486                	sd	ra,72(sp)
    80003f68:	e0a2                	sd	s0,64(sp)
    80003f6a:	fc26                	sd	s1,56(sp)
    80003f6c:	f84a                	sd	s2,48(sp)
    80003f6e:	f44e                	sd	s3,40(sp)
    80003f70:	0880                	addi	s0,sp,80
    80003f72:	84aa                	mv	s1,a0
    80003f74:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003f76:	88ffd0ef          	jal	ra,80001804 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003f7a:	409c                	lw	a5,0(s1)
    80003f7c:	37f9                	addiw	a5,a5,-2
    80003f7e:	4705                	li	a4,1
    80003f80:	02f76f63          	bltu	a4,a5,80003fbe <filestat+0x5a>
    80003f84:	892a                	mv	s2,a0
    ilock(f->ip);
    80003f86:	6c88                	ld	a0,24(s1)
    80003f88:	948ff0ef          	jal	ra,800030d0 <ilock>
    stati(f->ip, &st);
    80003f8c:	fb840593          	addi	a1,s0,-72
    80003f90:	6c88                	ld	a0,24(s1)
    80003f92:	ca0ff0ef          	jal	ra,80003432 <stati>
    iunlock(f->ip);
    80003f96:	6c88                	ld	a0,24(s1)
    80003f98:	9e2ff0ef          	jal	ra,8000317a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003f9c:	46e1                	li	a3,24
    80003f9e:	fb840613          	addi	a2,s0,-72
    80003fa2:	85ce                	mv	a1,s3
    80003fa4:	05093503          	ld	a0,80(s2)
    80003fa8:	daafd0ef          	jal	ra,80001552 <copyout>
    80003fac:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80003fb0:	60a6                	ld	ra,72(sp)
    80003fb2:	6406                	ld	s0,64(sp)
    80003fb4:	74e2                	ld	s1,56(sp)
    80003fb6:	7942                	ld	s2,48(sp)
    80003fb8:	79a2                	ld	s3,40(sp)
    80003fba:	6161                	addi	sp,sp,80
    80003fbc:	8082                	ret
  return -1;
    80003fbe:	557d                	li	a0,-1
    80003fc0:	bfc5                	j	80003fb0 <filestat+0x4c>

0000000080003fc2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003fc2:	7179                	addi	sp,sp,-48
    80003fc4:	f406                	sd	ra,40(sp)
    80003fc6:	f022                	sd	s0,32(sp)
    80003fc8:	ec26                	sd	s1,24(sp)
    80003fca:	e84a                	sd	s2,16(sp)
    80003fcc:	e44e                	sd	s3,8(sp)
    80003fce:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003fd0:	00854783          	lbu	a5,8(a0)
    80003fd4:	cbc1                	beqz	a5,80004064 <fileread+0xa2>
    80003fd6:	84aa                	mv	s1,a0
    80003fd8:	89ae                	mv	s3,a1
    80003fda:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003fdc:	411c                	lw	a5,0(a0)
    80003fde:	4705                	li	a4,1
    80003fe0:	04e78363          	beq	a5,a4,80004026 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003fe4:	470d                	li	a4,3
    80003fe6:	04e78563          	beq	a5,a4,80004030 <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003fea:	4709                	li	a4,2
    80003fec:	06e79663          	bne	a5,a4,80004058 <fileread+0x96>
    ilock(f->ip);
    80003ff0:	6d08                	ld	a0,24(a0)
    80003ff2:	8deff0ef          	jal	ra,800030d0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003ff6:	874a                	mv	a4,s2
    80003ff8:	5094                	lw	a3,32(s1)
    80003ffa:	864e                	mv	a2,s3
    80003ffc:	4585                	li	a1,1
    80003ffe:	6c88                	ld	a0,24(s1)
    80004000:	c5cff0ef          	jal	ra,8000345c <readi>
    80004004:	892a                	mv	s2,a0
    80004006:	00a05563          	blez	a0,80004010 <fileread+0x4e>
      f->off += r;
    8000400a:	509c                	lw	a5,32(s1)
    8000400c:	9fa9                	addw	a5,a5,a0
    8000400e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004010:	6c88                	ld	a0,24(s1)
    80004012:	968ff0ef          	jal	ra,8000317a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004016:	854a                	mv	a0,s2
    80004018:	70a2                	ld	ra,40(sp)
    8000401a:	7402                	ld	s0,32(sp)
    8000401c:	64e2                	ld	s1,24(sp)
    8000401e:	6942                	ld	s2,16(sp)
    80004020:	69a2                	ld	s3,8(sp)
    80004022:	6145                	addi	sp,sp,48
    80004024:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004026:	6908                	ld	a0,16(a0)
    80004028:	34e000ef          	jal	ra,80004376 <piperead>
    8000402c:	892a                	mv	s2,a0
    8000402e:	b7e5                	j	80004016 <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004030:	02451783          	lh	a5,36(a0)
    80004034:	03079693          	slli	a3,a5,0x30
    80004038:	92c1                	srli	a3,a3,0x30
    8000403a:	4725                	li	a4,9
    8000403c:	02d76663          	bltu	a4,a3,80004068 <fileread+0xa6>
    80004040:	0792                	slli	a5,a5,0x4
    80004042:	0001c717          	auipc	a4,0x1c
    80004046:	98e70713          	addi	a4,a4,-1650 # 8001f9d0 <devsw>
    8000404a:	97ba                	add	a5,a5,a4
    8000404c:	639c                	ld	a5,0(a5)
    8000404e:	cf99                	beqz	a5,8000406c <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    80004050:	4505                	li	a0,1
    80004052:	9782                	jalr	a5
    80004054:	892a                	mv	s2,a0
    80004056:	b7c1                	j	80004016 <fileread+0x54>
    panic("fileread");
    80004058:	00003517          	auipc	a0,0x3
    8000405c:	63050513          	addi	a0,a0,1584 # 80007688 <syscalls+0x298>
    80004060:	f2afc0ef          	jal	ra,8000078a <panic>
    return -1;
    80004064:	597d                	li	s2,-1
    80004066:	bf45                	j	80004016 <fileread+0x54>
      return -1;
    80004068:	597d                	li	s2,-1
    8000406a:	b775                	j	80004016 <fileread+0x54>
    8000406c:	597d                	li	s2,-1
    8000406e:	b765                	j	80004016 <fileread+0x54>

0000000080004070 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004070:	715d                	addi	sp,sp,-80
    80004072:	e486                	sd	ra,72(sp)
    80004074:	e0a2                	sd	s0,64(sp)
    80004076:	fc26                	sd	s1,56(sp)
    80004078:	f84a                	sd	s2,48(sp)
    8000407a:	f44e                	sd	s3,40(sp)
    8000407c:	f052                	sd	s4,32(sp)
    8000407e:	ec56                	sd	s5,24(sp)
    80004080:	e85a                	sd	s6,16(sp)
    80004082:	e45e                	sd	s7,8(sp)
    80004084:	e062                	sd	s8,0(sp)
    80004086:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004088:	00954783          	lbu	a5,9(a0)
    8000408c:	0e078863          	beqz	a5,8000417c <filewrite+0x10c>
    80004090:	892a                	mv	s2,a0
    80004092:	8aae                	mv	s5,a1
    80004094:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004096:	411c                	lw	a5,0(a0)
    80004098:	4705                	li	a4,1
    8000409a:	02e78263          	beq	a5,a4,800040be <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000409e:	470d                	li	a4,3
    800040a0:	02e78463          	beq	a5,a4,800040c8 <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800040a4:	4709                	li	a4,2
    800040a6:	0ce79563          	bne	a5,a4,80004170 <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800040aa:	0ac05163          	blez	a2,8000414c <filewrite+0xdc>
    int i = 0;
    800040ae:	4981                	li	s3,0
    800040b0:	6b05                	lui	s6,0x1
    800040b2:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800040b6:	6b85                	lui	s7,0x1
    800040b8:	c00b8b9b          	addiw	s7,s7,-1024
    800040bc:	a041                	j	8000413c <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800040be:	6908                	ld	a0,16(a0)
    800040c0:	1e2000ef          	jal	ra,800042a2 <pipewrite>
    800040c4:	8a2a                	mv	s4,a0
    800040c6:	a071                	j	80004152 <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800040c8:	02451783          	lh	a5,36(a0)
    800040cc:	03079693          	slli	a3,a5,0x30
    800040d0:	92c1                	srli	a3,a3,0x30
    800040d2:	4725                	li	a4,9
    800040d4:	0ad76663          	bltu	a4,a3,80004180 <filewrite+0x110>
    800040d8:	0792                	slli	a5,a5,0x4
    800040da:	0001c717          	auipc	a4,0x1c
    800040de:	8f670713          	addi	a4,a4,-1802 # 8001f9d0 <devsw>
    800040e2:	97ba                	add	a5,a5,a4
    800040e4:	679c                	ld	a5,8(a5)
    800040e6:	cfd9                	beqz	a5,80004184 <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    800040e8:	4505                	li	a0,1
    800040ea:	9782                	jalr	a5
    800040ec:	8a2a                	mv	s4,a0
    800040ee:	a095                	j	80004152 <filewrite+0xe2>
    800040f0:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800040f4:	9bbff0ef          	jal	ra,80003aae <begin_op>
      ilock(f->ip);
    800040f8:	01893503          	ld	a0,24(s2)
    800040fc:	fd5fe0ef          	jal	ra,800030d0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004100:	8762                	mv	a4,s8
    80004102:	02092683          	lw	a3,32(s2)
    80004106:	01598633          	add	a2,s3,s5
    8000410a:	4585                	li	a1,1
    8000410c:	01893503          	ld	a0,24(s2)
    80004110:	c30ff0ef          	jal	ra,80003540 <writei>
    80004114:	84aa                	mv	s1,a0
    80004116:	00a05763          	blez	a0,80004124 <filewrite+0xb4>
        f->off += r;
    8000411a:	02092783          	lw	a5,32(s2)
    8000411e:	9fa9                	addw	a5,a5,a0
    80004120:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004124:	01893503          	ld	a0,24(s2)
    80004128:	852ff0ef          	jal	ra,8000317a <iunlock>
      end_op();
    8000412c:	9f3ff0ef          	jal	ra,80003b1e <end_op>

      if(r != n1){
    80004130:	009c1f63          	bne	s8,s1,8000414e <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    80004134:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004138:	0149db63          	bge	s3,s4,8000414e <filewrite+0xde>
      int n1 = n - i;
    8000413c:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004140:	84be                	mv	s1,a5
    80004142:	2781                	sext.w	a5,a5
    80004144:	fafb56e3          	bge	s6,a5,800040f0 <filewrite+0x80>
    80004148:	84de                	mv	s1,s7
    8000414a:	b75d                	j	800040f0 <filewrite+0x80>
    int i = 0;
    8000414c:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000414e:	013a1f63          	bne	s4,s3,8000416c <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004152:	8552                	mv	a0,s4
    80004154:	60a6                	ld	ra,72(sp)
    80004156:	6406                	ld	s0,64(sp)
    80004158:	74e2                	ld	s1,56(sp)
    8000415a:	7942                	ld	s2,48(sp)
    8000415c:	79a2                	ld	s3,40(sp)
    8000415e:	7a02                	ld	s4,32(sp)
    80004160:	6ae2                	ld	s5,24(sp)
    80004162:	6b42                	ld	s6,16(sp)
    80004164:	6ba2                	ld	s7,8(sp)
    80004166:	6c02                	ld	s8,0(sp)
    80004168:	6161                	addi	sp,sp,80
    8000416a:	8082                	ret
    ret = (i == n ? n : -1);
    8000416c:	5a7d                	li	s4,-1
    8000416e:	b7d5                	j	80004152 <filewrite+0xe2>
    panic("filewrite");
    80004170:	00003517          	auipc	a0,0x3
    80004174:	52850513          	addi	a0,a0,1320 # 80007698 <syscalls+0x2a8>
    80004178:	e12fc0ef          	jal	ra,8000078a <panic>
    return -1;
    8000417c:	5a7d                	li	s4,-1
    8000417e:	bfd1                	j	80004152 <filewrite+0xe2>
      return -1;
    80004180:	5a7d                	li	s4,-1
    80004182:	bfc1                	j	80004152 <filewrite+0xe2>
    80004184:	5a7d                	li	s4,-1
    80004186:	b7f1                	j	80004152 <filewrite+0xe2>

0000000080004188 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004188:	7179                	addi	sp,sp,-48
    8000418a:	f406                	sd	ra,40(sp)
    8000418c:	f022                	sd	s0,32(sp)
    8000418e:	ec26                	sd	s1,24(sp)
    80004190:	e84a                	sd	s2,16(sp)
    80004192:	e44e                	sd	s3,8(sp)
    80004194:	e052                	sd	s4,0(sp)
    80004196:	1800                	addi	s0,sp,48
    80004198:	84aa                	mv	s1,a0
    8000419a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000419c:	0005b023          	sd	zero,0(a1)
    800041a0:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800041a4:	c75ff0ef          	jal	ra,80003e18 <filealloc>
    800041a8:	e088                	sd	a0,0(s1)
    800041aa:	cd35                	beqz	a0,80004226 <pipealloc+0x9e>
    800041ac:	c6dff0ef          	jal	ra,80003e18 <filealloc>
    800041b0:	00aa3023          	sd	a0,0(s4)
    800041b4:	c52d                	beqz	a0,8000421e <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800041b6:	8e7fc0ef          	jal	ra,80000a9c <kalloc>
    800041ba:	892a                	mv	s2,a0
    800041bc:	cd31                	beqz	a0,80004218 <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    800041be:	4985                	li	s3,1
    800041c0:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800041c4:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800041c8:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800041cc:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800041d0:	00003597          	auipc	a1,0x3
    800041d4:	4d858593          	addi	a1,a1,1240 # 800076a8 <syscalls+0x2b8>
    800041d8:	915fc0ef          	jal	ra,80000aec <initlock>
  (*f0)->type = FD_PIPE;
    800041dc:	609c                	ld	a5,0(s1)
    800041de:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800041e2:	609c                	ld	a5,0(s1)
    800041e4:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800041e8:	609c                	ld	a5,0(s1)
    800041ea:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800041ee:	609c                	ld	a5,0(s1)
    800041f0:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800041f4:	000a3783          	ld	a5,0(s4)
    800041f8:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800041fc:	000a3783          	ld	a5,0(s4)
    80004200:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004204:	000a3783          	ld	a5,0(s4)
    80004208:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000420c:	000a3783          	ld	a5,0(s4)
    80004210:	0127b823          	sd	s2,16(a5)
  return 0;
    80004214:	4501                	li	a0,0
    80004216:	a005                	j	80004236 <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004218:	6088                	ld	a0,0(s1)
    8000421a:	e501                	bnez	a0,80004222 <pipealloc+0x9a>
    8000421c:	a029                	j	80004226 <pipealloc+0x9e>
    8000421e:	6088                	ld	a0,0(s1)
    80004220:	c11d                	beqz	a0,80004246 <pipealloc+0xbe>
    fileclose(*f0);
    80004222:	c9bff0ef          	jal	ra,80003ebc <fileclose>
  if(*f1)
    80004226:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000422a:	557d                	li	a0,-1
  if(*f1)
    8000422c:	c789                	beqz	a5,80004236 <pipealloc+0xae>
    fileclose(*f1);
    8000422e:	853e                	mv	a0,a5
    80004230:	c8dff0ef          	jal	ra,80003ebc <fileclose>
  return -1;
    80004234:	557d                	li	a0,-1
}
    80004236:	70a2                	ld	ra,40(sp)
    80004238:	7402                	ld	s0,32(sp)
    8000423a:	64e2                	ld	s1,24(sp)
    8000423c:	6942                	ld	s2,16(sp)
    8000423e:	69a2                	ld	s3,8(sp)
    80004240:	6a02                	ld	s4,0(sp)
    80004242:	6145                	addi	sp,sp,48
    80004244:	8082                	ret
  return -1;
    80004246:	557d                	li	a0,-1
    80004248:	b7fd                	j	80004236 <pipealloc+0xae>

000000008000424a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000424a:	1101                	addi	sp,sp,-32
    8000424c:	ec06                	sd	ra,24(sp)
    8000424e:	e822                	sd	s0,16(sp)
    80004250:	e426                	sd	s1,8(sp)
    80004252:	e04a                	sd	s2,0(sp)
    80004254:	1000                	addi	s0,sp,32
    80004256:	84aa                	mv	s1,a0
    80004258:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000425a:	913fc0ef          	jal	ra,80000b6c <acquire>
  if(writable){
    8000425e:	02090763          	beqz	s2,8000428c <pipeclose+0x42>
    pi->writeopen = 0;
    80004262:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004266:	21848513          	addi	a0,s1,536
    8000426a:	bddfd0ef          	jal	ra,80001e46 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000426e:	2204b783          	ld	a5,544(s1)
    80004272:	e785                	bnez	a5,8000429a <pipeclose+0x50>
    release(&pi->lock);
    80004274:	8526                	mv	a0,s1
    80004276:	98ffc0ef          	jal	ra,80000c04 <release>
    kfree((char*)pi);
    8000427a:	8526                	mv	a0,s1
    8000427c:	f40fc0ef          	jal	ra,800009bc <kfree>
  } else
    release(&pi->lock);
}
    80004280:	60e2                	ld	ra,24(sp)
    80004282:	6442                	ld	s0,16(sp)
    80004284:	64a2                	ld	s1,8(sp)
    80004286:	6902                	ld	s2,0(sp)
    80004288:	6105                	addi	sp,sp,32
    8000428a:	8082                	ret
    pi->readopen = 0;
    8000428c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004290:	21c48513          	addi	a0,s1,540
    80004294:	bb3fd0ef          	jal	ra,80001e46 <wakeup>
    80004298:	bfd9                	j	8000426e <pipeclose+0x24>
    release(&pi->lock);
    8000429a:	8526                	mv	a0,s1
    8000429c:	969fc0ef          	jal	ra,80000c04 <release>
}
    800042a0:	b7c5                	j	80004280 <pipeclose+0x36>

00000000800042a2 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800042a2:	711d                	addi	sp,sp,-96
    800042a4:	ec86                	sd	ra,88(sp)
    800042a6:	e8a2                	sd	s0,80(sp)
    800042a8:	e4a6                	sd	s1,72(sp)
    800042aa:	e0ca                	sd	s2,64(sp)
    800042ac:	fc4e                	sd	s3,56(sp)
    800042ae:	f852                	sd	s4,48(sp)
    800042b0:	f456                	sd	s5,40(sp)
    800042b2:	f05a                	sd	s6,32(sp)
    800042b4:	ec5e                	sd	s7,24(sp)
    800042b6:	e862                	sd	s8,16(sp)
    800042b8:	1080                	addi	s0,sp,96
    800042ba:	84aa                	mv	s1,a0
    800042bc:	8aae                	mv	s5,a1
    800042be:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800042c0:	d44fd0ef          	jal	ra,80001804 <myproc>
    800042c4:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800042c6:	8526                	mv	a0,s1
    800042c8:	8a5fc0ef          	jal	ra,80000b6c <acquire>
  while(i < n){
    800042cc:	09405c63          	blez	s4,80004364 <pipewrite+0xc2>
  int i = 0;
    800042d0:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800042d2:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800042d4:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800042d8:	21c48b93          	addi	s7,s1,540
    800042dc:	a81d                	j	80004312 <pipewrite+0x70>
      release(&pi->lock);
    800042de:	8526                	mv	a0,s1
    800042e0:	925fc0ef          	jal	ra,80000c04 <release>
      return -1;
    800042e4:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800042e6:	854a                	mv	a0,s2
    800042e8:	60e6                	ld	ra,88(sp)
    800042ea:	6446                	ld	s0,80(sp)
    800042ec:	64a6                	ld	s1,72(sp)
    800042ee:	6906                	ld	s2,64(sp)
    800042f0:	79e2                	ld	s3,56(sp)
    800042f2:	7a42                	ld	s4,48(sp)
    800042f4:	7aa2                	ld	s5,40(sp)
    800042f6:	7b02                	ld	s6,32(sp)
    800042f8:	6be2                	ld	s7,24(sp)
    800042fa:	6c42                	ld	s8,16(sp)
    800042fc:	6125                	addi	sp,sp,96
    800042fe:	8082                	ret
      wakeup(&pi->nread);
    80004300:	8562                	mv	a0,s8
    80004302:	b45fd0ef          	jal	ra,80001e46 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004306:	85a6                	mv	a1,s1
    80004308:	855e                	mv	a0,s7
    8000430a:	af1fd0ef          	jal	ra,80001dfa <sleep>
  while(i < n){
    8000430e:	05495c63          	bge	s2,s4,80004366 <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    80004312:	2204a783          	lw	a5,544(s1)
    80004316:	d7e1                	beqz	a5,800042de <pipewrite+0x3c>
    80004318:	854e                	mv	a0,s3
    8000431a:	d19fd0ef          	jal	ra,80002032 <killed>
    8000431e:	f161                	bnez	a0,800042de <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004320:	2184a783          	lw	a5,536(s1)
    80004324:	21c4a703          	lw	a4,540(s1)
    80004328:	2007879b          	addiw	a5,a5,512
    8000432c:	fcf70ae3          	beq	a4,a5,80004300 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004330:	4685                	li	a3,1
    80004332:	01590633          	add	a2,s2,s5
    80004336:	faf40593          	addi	a1,s0,-81
    8000433a:	0509b503          	ld	a0,80(s3)
    8000433e:	adafd0ef          	jal	ra,80001618 <copyin>
    80004342:	03650263          	beq	a0,s6,80004366 <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004346:	21c4a783          	lw	a5,540(s1)
    8000434a:	0017871b          	addiw	a4,a5,1
    8000434e:	20e4ae23          	sw	a4,540(s1)
    80004352:	1ff7f793          	andi	a5,a5,511
    80004356:	97a6                	add	a5,a5,s1
    80004358:	faf44703          	lbu	a4,-81(s0)
    8000435c:	00e78c23          	sb	a4,24(a5)
      i++;
    80004360:	2905                	addiw	s2,s2,1
    80004362:	b775                	j	8000430e <pipewrite+0x6c>
  int i = 0;
    80004364:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004366:	21848513          	addi	a0,s1,536
    8000436a:	addfd0ef          	jal	ra,80001e46 <wakeup>
  release(&pi->lock);
    8000436e:	8526                	mv	a0,s1
    80004370:	895fc0ef          	jal	ra,80000c04 <release>
  return i;
    80004374:	bf8d                	j	800042e6 <pipewrite+0x44>

0000000080004376 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004376:	715d                	addi	sp,sp,-80
    80004378:	e486                	sd	ra,72(sp)
    8000437a:	e0a2                	sd	s0,64(sp)
    8000437c:	fc26                	sd	s1,56(sp)
    8000437e:	f84a                	sd	s2,48(sp)
    80004380:	f44e                	sd	s3,40(sp)
    80004382:	f052                	sd	s4,32(sp)
    80004384:	ec56                	sd	s5,24(sp)
    80004386:	e85a                	sd	s6,16(sp)
    80004388:	0880                	addi	s0,sp,80
    8000438a:	84aa                	mv	s1,a0
    8000438c:	892e                	mv	s2,a1
    8000438e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004390:	c74fd0ef          	jal	ra,80001804 <myproc>
    80004394:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004396:	8526                	mv	a0,s1
    80004398:	fd4fc0ef          	jal	ra,80000b6c <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000439c:	2184a703          	lw	a4,536(s1)
    800043a0:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800043a4:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800043a8:	02f71363          	bne	a4,a5,800043ce <piperead+0x58>
    800043ac:	2244a783          	lw	a5,548(s1)
    800043b0:	cf99                	beqz	a5,800043ce <piperead+0x58>
    if(killed(pr)){
    800043b2:	8552                	mv	a0,s4
    800043b4:	c7ffd0ef          	jal	ra,80002032 <killed>
    800043b8:	e141                	bnez	a0,80004438 <piperead+0xc2>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800043ba:	85a6                	mv	a1,s1
    800043bc:	854e                	mv	a0,s3
    800043be:	a3dfd0ef          	jal	ra,80001dfa <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800043c2:	2184a703          	lw	a4,536(s1)
    800043c6:	21c4a783          	lw	a5,540(s1)
    800043ca:	fef701e3          	beq	a4,a5,800043ac <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800043ce:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800043d0:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800043d2:	05505163          	blez	s5,80004414 <piperead+0x9e>
    if(pi->nread == pi->nwrite)
    800043d6:	2184a783          	lw	a5,536(s1)
    800043da:	21c4a703          	lw	a4,540(s1)
    800043de:	02f70b63          	beq	a4,a5,80004414 <piperead+0x9e>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800043e2:	0017871b          	addiw	a4,a5,1
    800043e6:	20e4ac23          	sw	a4,536(s1)
    800043ea:	1ff7f793          	andi	a5,a5,511
    800043ee:	97a6                	add	a5,a5,s1
    800043f0:	0187c783          	lbu	a5,24(a5)
    800043f4:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800043f8:	4685                	li	a3,1
    800043fa:	fbf40613          	addi	a2,s0,-65
    800043fe:	85ca                	mv	a1,s2
    80004400:	050a3503          	ld	a0,80(s4)
    80004404:	94efd0ef          	jal	ra,80001552 <copyout>
    80004408:	01650663          	beq	a0,s6,80004414 <piperead+0x9e>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000440c:	2985                	addiw	s3,s3,1
    8000440e:	0905                	addi	s2,s2,1
    80004410:	fd3a93e3          	bne	s5,s3,800043d6 <piperead+0x60>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004414:	21c48513          	addi	a0,s1,540
    80004418:	a2ffd0ef          	jal	ra,80001e46 <wakeup>
  release(&pi->lock);
    8000441c:	8526                	mv	a0,s1
    8000441e:	fe6fc0ef          	jal	ra,80000c04 <release>
  return i;
}
    80004422:	854e                	mv	a0,s3
    80004424:	60a6                	ld	ra,72(sp)
    80004426:	6406                	ld	s0,64(sp)
    80004428:	74e2                	ld	s1,56(sp)
    8000442a:	7942                	ld	s2,48(sp)
    8000442c:	79a2                	ld	s3,40(sp)
    8000442e:	7a02                	ld	s4,32(sp)
    80004430:	6ae2                	ld	s5,24(sp)
    80004432:	6b42                	ld	s6,16(sp)
    80004434:	6161                	addi	sp,sp,80
    80004436:	8082                	ret
      release(&pi->lock);
    80004438:	8526                	mv	a0,s1
    8000443a:	fcafc0ef          	jal	ra,80000c04 <release>
      return -1;
    8000443e:	59fd                	li	s3,-1
    80004440:	b7cd                	j	80004422 <piperead+0xac>

0000000080004442 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004442:	1141                	addi	sp,sp,-16
    80004444:	e422                	sd	s0,8(sp)
    80004446:	0800                	addi	s0,sp,16
    80004448:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000444a:	8905                	andi	a0,a0,1
    8000444c:	c111                	beqz	a0,80004450 <flags2perm+0xe>
      perm = PTE_X;
    8000444e:	4521                	li	a0,8
    if(flags & 0x2)
    80004450:	8b89                	andi	a5,a5,2
    80004452:	c399                	beqz	a5,80004458 <flags2perm+0x16>
      perm |= PTE_W;
    80004454:	00456513          	ori	a0,a0,4
    return perm;
}
    80004458:	6422                	ld	s0,8(sp)
    8000445a:	0141                	addi	sp,sp,16
    8000445c:	8082                	ret

000000008000445e <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    8000445e:	de010113          	addi	sp,sp,-544
    80004462:	20113c23          	sd	ra,536(sp)
    80004466:	20813823          	sd	s0,528(sp)
    8000446a:	20913423          	sd	s1,520(sp)
    8000446e:	21213023          	sd	s2,512(sp)
    80004472:	ffce                	sd	s3,504(sp)
    80004474:	fbd2                	sd	s4,496(sp)
    80004476:	f7d6                	sd	s5,488(sp)
    80004478:	f3da                	sd	s6,480(sp)
    8000447a:	efde                	sd	s7,472(sp)
    8000447c:	ebe2                	sd	s8,464(sp)
    8000447e:	e7e6                	sd	s9,456(sp)
    80004480:	e3ea                	sd	s10,448(sp)
    80004482:	ff6e                	sd	s11,440(sp)
    80004484:	1400                	addi	s0,sp,544
    80004486:	892a                	mv	s2,a0
    80004488:	dea43423          	sd	a0,-536(s0)
    8000448c:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004490:	b74fd0ef          	jal	ra,80001804 <myproc>
    80004494:	84aa                	mv	s1,a0

  begin_op();
    80004496:	e18ff0ef          	jal	ra,80003aae <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    8000449a:	854a                	mv	a0,s2
    8000449c:	c22ff0ef          	jal	ra,800038be <namei>
    800044a0:	c13d                	beqz	a0,80004506 <kexec+0xa8>
    800044a2:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800044a4:	c2dfe0ef          	jal	ra,800030d0 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800044a8:	04000713          	li	a4,64
    800044ac:	4681                	li	a3,0
    800044ae:	e5040613          	addi	a2,s0,-432
    800044b2:	4581                	li	a1,0
    800044b4:	8556                	mv	a0,s5
    800044b6:	fa7fe0ef          	jal	ra,8000345c <readi>
    800044ba:	04000793          	li	a5,64
    800044be:	00f51a63          	bne	a0,a5,800044d2 <kexec+0x74>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    800044c2:	e5042703          	lw	a4,-432(s0)
    800044c6:	464c47b7          	lui	a5,0x464c4
    800044ca:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800044ce:	04f70063          	beq	a4,a5,8000450e <kexec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800044d2:	8556                	mv	a0,s5
    800044d4:	e03fe0ef          	jal	ra,800032d6 <iunlockput>
    end_op();
    800044d8:	e46ff0ef          	jal	ra,80003b1e <end_op>
  }
  return -1;
    800044dc:	557d                	li	a0,-1
}
    800044de:	21813083          	ld	ra,536(sp)
    800044e2:	21013403          	ld	s0,528(sp)
    800044e6:	20813483          	ld	s1,520(sp)
    800044ea:	20013903          	ld	s2,512(sp)
    800044ee:	79fe                	ld	s3,504(sp)
    800044f0:	7a5e                	ld	s4,496(sp)
    800044f2:	7abe                	ld	s5,488(sp)
    800044f4:	7b1e                	ld	s6,480(sp)
    800044f6:	6bfe                	ld	s7,472(sp)
    800044f8:	6c5e                	ld	s8,464(sp)
    800044fa:	6cbe                	ld	s9,456(sp)
    800044fc:	6d1e                	ld	s10,448(sp)
    800044fe:	7dfa                	ld	s11,440(sp)
    80004500:	22010113          	addi	sp,sp,544
    80004504:	8082                	ret
    end_op();
    80004506:	e18ff0ef          	jal	ra,80003b1e <end_op>
    return -1;
    8000450a:	557d                	li	a0,-1
    8000450c:	bfc9                	j	800044de <kexec+0x80>
  if((pagetable = proc_pagetable(p)) == 0)
    8000450e:	8526                	mv	a0,s1
    80004510:	bfafd0ef          	jal	ra,8000190a <proc_pagetable>
    80004514:	8b2a                	mv	s6,a0
    80004516:	dd55                	beqz	a0,800044d2 <kexec+0x74>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004518:	e7042783          	lw	a5,-400(s0)
    8000451c:	e8845703          	lhu	a4,-376(s0)
    80004520:	c325                	beqz	a4,80004580 <kexec+0x122>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004522:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004524:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004528:	6a05                	lui	s4,0x1
    8000452a:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    8000452e:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004532:	6d85                	lui	s11,0x1
    80004534:	7d7d                	lui	s10,0xfffff
    80004536:	a411                	j	8000473a <kexec+0x2dc>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004538:	00003517          	auipc	a0,0x3
    8000453c:	17850513          	addi	a0,a0,376 # 800076b0 <syscalls+0x2c0>
    80004540:	a4afc0ef          	jal	ra,8000078a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004544:	874a                	mv	a4,s2
    80004546:	009c86bb          	addw	a3,s9,s1
    8000454a:	4581                	li	a1,0
    8000454c:	8556                	mv	a0,s5
    8000454e:	f0ffe0ef          	jal	ra,8000345c <readi>
    80004552:	2501                	sext.w	a0,a0
    80004554:	18a91263          	bne	s2,a0,800046d8 <kexec+0x27a>
  for(i = 0; i < sz; i += PGSIZE){
    80004558:	009d84bb          	addw	s1,s11,s1
    8000455c:	013d09bb          	addw	s3,s10,s3
    80004560:	1b74fd63          	bgeu	s1,s7,8000471a <kexec+0x2bc>
    pa = walkaddr(pagetable, va + i);
    80004564:	02049593          	slli	a1,s1,0x20
    80004568:	9181                	srli	a1,a1,0x20
    8000456a:	95e2                	add	a1,a1,s8
    8000456c:	855a                	mv	a0,s6
    8000456e:	9e9fc0ef          	jal	ra,80000f56 <walkaddr>
    80004572:	862a                	mv	a2,a0
    if(pa == 0)
    80004574:	d171                	beqz	a0,80004538 <kexec+0xda>
      n = PGSIZE;
    80004576:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004578:	fd49f6e3          	bgeu	s3,s4,80004544 <kexec+0xe6>
      n = sz - i;
    8000457c:	894e                	mv	s2,s3
    8000457e:	b7d9                	j	80004544 <kexec+0xe6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004580:	4901                	li	s2,0
  iunlockput(ip);
    80004582:	8556                	mv	a0,s5
    80004584:	d53fe0ef          	jal	ra,800032d6 <iunlockput>
  end_op();
    80004588:	d96ff0ef          	jal	ra,80003b1e <end_op>
  p = myproc();
    8000458c:	a78fd0ef          	jal	ra,80001804 <myproc>
    80004590:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004592:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004596:	6785                	lui	a5,0x1
    80004598:	17fd                	addi	a5,a5,-1
    8000459a:	993e                	add	s2,s2,a5
    8000459c:	77fd                	lui	a5,0xfffff
    8000459e:	00f977b3          	and	a5,s2,a5
    800045a2:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800045a6:	4691                	li	a3,4
    800045a8:	6609                	lui	a2,0x2
    800045aa:	963e                	add	a2,a2,a5
    800045ac:	85be                	mv	a1,a5
    800045ae:	855a                	mv	a0,s6
    800045b0:	c71fc0ef          	jal	ra,80001220 <uvmalloc>
    800045b4:	8c2a                	mv	s8,a0
  ip = 0;
    800045b6:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800045b8:	12050063          	beqz	a0,800046d8 <kexec+0x27a>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800045bc:	75f9                	lui	a1,0xffffe
    800045be:	95aa                	add	a1,a1,a0
    800045c0:	855a                	mv	a0,s6
    800045c2:	e25fc0ef          	jal	ra,800013e6 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800045c6:	7afd                	lui	s5,0xfffff
    800045c8:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800045ca:	df043783          	ld	a5,-528(s0)
    800045ce:	6388                	ld	a0,0(a5)
    800045d0:	c135                	beqz	a0,80004634 <kexec+0x1d6>
    800045d2:	e9040993          	addi	s3,s0,-368
    800045d6:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800045da:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800045dc:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800045de:	fdafc0ef          	jal	ra,80000db8 <strlen>
    800045e2:	0015079b          	addiw	a5,a0,1
    800045e6:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800045ea:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800045ee:	11596a63          	bltu	s2,s5,80004702 <kexec+0x2a4>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800045f2:	df043d83          	ld	s11,-528(s0)
    800045f6:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800045fa:	8552                	mv	a0,s4
    800045fc:	fbcfc0ef          	jal	ra,80000db8 <strlen>
    80004600:	0015069b          	addiw	a3,a0,1
    80004604:	8652                	mv	a2,s4
    80004606:	85ca                	mv	a1,s2
    80004608:	855a                	mv	a0,s6
    8000460a:	f49fc0ef          	jal	ra,80001552 <copyout>
    8000460e:	0e054e63          	bltz	a0,8000470a <kexec+0x2ac>
    ustack[argc] = sp;
    80004612:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004616:	0485                	addi	s1,s1,1
    80004618:	008d8793          	addi	a5,s11,8
    8000461c:	def43823          	sd	a5,-528(s0)
    80004620:	008db503          	ld	a0,8(s11)
    80004624:	c911                	beqz	a0,80004638 <kexec+0x1da>
    if(argc >= MAXARG)
    80004626:	09a1                	addi	s3,s3,8
    80004628:	fb3c9be3          	bne	s9,s3,800045de <kexec+0x180>
  sz = sz1;
    8000462c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004630:	4a81                	li	s5,0
    80004632:	a05d                	j	800046d8 <kexec+0x27a>
  sp = sz;
    80004634:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004636:	4481                	li	s1,0
  ustack[argc] = 0;
    80004638:	00349793          	slli	a5,s1,0x3
    8000463c:	f9040713          	addi	a4,s0,-112
    80004640:	97ba                	add	a5,a5,a4
    80004642:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffde398>
  sp -= (argc+1) * sizeof(uint64);
    80004646:	00148693          	addi	a3,s1,1
    8000464a:	068e                	slli	a3,a3,0x3
    8000464c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004650:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004654:	01597663          	bgeu	s2,s5,80004660 <kexec+0x202>
  sz = sz1;
    80004658:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000465c:	4a81                	li	s5,0
    8000465e:	a8ad                	j	800046d8 <kexec+0x27a>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004660:	e9040613          	addi	a2,s0,-368
    80004664:	85ca                	mv	a1,s2
    80004666:	855a                	mv	a0,s6
    80004668:	eebfc0ef          	jal	ra,80001552 <copyout>
    8000466c:	0a054363          	bltz	a0,80004712 <kexec+0x2b4>
  p->trapframe->a1 = sp;
    80004670:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80004674:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004678:	de843783          	ld	a5,-536(s0)
    8000467c:	0007c703          	lbu	a4,0(a5)
    80004680:	cf11                	beqz	a4,8000469c <kexec+0x23e>
    80004682:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004684:	02f00693          	li	a3,47
    80004688:	a039                	j	80004696 <kexec+0x238>
      last = s+1;
    8000468a:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000468e:	0785                	addi	a5,a5,1
    80004690:	fff7c703          	lbu	a4,-1(a5)
    80004694:	c701                	beqz	a4,8000469c <kexec+0x23e>
    if(*s == '/')
    80004696:	fed71ce3          	bne	a4,a3,8000468e <kexec+0x230>
    8000469a:	bfc5                	j	8000468a <kexec+0x22c>
  safestrcpy(p->name, last, sizeof(p->name));
    8000469c:	4641                	li	a2,16
    8000469e:	de843583          	ld	a1,-536(s0)
    800046a2:	158b8513          	addi	a0,s7,344
    800046a6:	ee0fc0ef          	jal	ra,80000d86 <safestrcpy>
  oldpagetable = p->pagetable;
    800046aa:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800046ae:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800046b2:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800046b6:	058bb783          	ld	a5,88(s7)
    800046ba:	e6843703          	ld	a4,-408(s0)
    800046be:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800046c0:	058bb783          	ld	a5,88(s7)
    800046c4:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800046c8:	85ea                	mv	a1,s10
    800046ca:	ac4fd0ef          	jal	ra,8000198e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800046ce:	0004851b          	sext.w	a0,s1
    800046d2:	b531                	j	800044de <kexec+0x80>
    800046d4:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800046d8:	df843583          	ld	a1,-520(s0)
    800046dc:	855a                	mv	a0,s6
    800046de:	ab0fd0ef          	jal	ra,8000198e <proc_freepagetable>
  if(ip){
    800046e2:	de0a98e3          	bnez	s5,800044d2 <kexec+0x74>
  return -1;
    800046e6:	557d                	li	a0,-1
    800046e8:	bbdd                	j	800044de <kexec+0x80>
    800046ea:	df243c23          	sd	s2,-520(s0)
    800046ee:	b7ed                	j	800046d8 <kexec+0x27a>
    800046f0:	df243c23          	sd	s2,-520(s0)
    800046f4:	b7d5                	j	800046d8 <kexec+0x27a>
    800046f6:	df243c23          	sd	s2,-520(s0)
    800046fa:	bff9                	j	800046d8 <kexec+0x27a>
    800046fc:	df243c23          	sd	s2,-520(s0)
    80004700:	bfe1                	j	800046d8 <kexec+0x27a>
  sz = sz1;
    80004702:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004706:	4a81                	li	s5,0
    80004708:	bfc1                	j	800046d8 <kexec+0x27a>
  sz = sz1;
    8000470a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000470e:	4a81                	li	s5,0
    80004710:	b7e1                	j	800046d8 <kexec+0x27a>
  sz = sz1;
    80004712:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004716:	4a81                	li	s5,0
    80004718:	b7c1                	j	800046d8 <kexec+0x27a>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000471a:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000471e:	e0843783          	ld	a5,-504(s0)
    80004722:	0017869b          	addiw	a3,a5,1
    80004726:	e0d43423          	sd	a3,-504(s0)
    8000472a:	e0043783          	ld	a5,-512(s0)
    8000472e:	0387879b          	addiw	a5,a5,56
    80004732:	e8845703          	lhu	a4,-376(s0)
    80004736:	e4e6d6e3          	bge	a3,a4,80004582 <kexec+0x124>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000473a:	2781                	sext.w	a5,a5
    8000473c:	e0f43023          	sd	a5,-512(s0)
    80004740:	03800713          	li	a4,56
    80004744:	86be                	mv	a3,a5
    80004746:	e1840613          	addi	a2,s0,-488
    8000474a:	4581                	li	a1,0
    8000474c:	8556                	mv	a0,s5
    8000474e:	d0ffe0ef          	jal	ra,8000345c <readi>
    80004752:	03800793          	li	a5,56
    80004756:	f6f51fe3          	bne	a0,a5,800046d4 <kexec+0x276>
    if(ph.type != ELF_PROG_LOAD)
    8000475a:	e1842783          	lw	a5,-488(s0)
    8000475e:	4705                	li	a4,1
    80004760:	fae79fe3          	bne	a5,a4,8000471e <kexec+0x2c0>
    if(ph.memsz < ph.filesz)
    80004764:	e4043483          	ld	s1,-448(s0)
    80004768:	e3843783          	ld	a5,-456(s0)
    8000476c:	f6f4efe3          	bltu	s1,a5,800046ea <kexec+0x28c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004770:	e2843783          	ld	a5,-472(s0)
    80004774:	94be                	add	s1,s1,a5
    80004776:	f6f4ede3          	bltu	s1,a5,800046f0 <kexec+0x292>
    if(ph.vaddr % PGSIZE != 0)
    8000477a:	de043703          	ld	a4,-544(s0)
    8000477e:	8ff9                	and	a5,a5,a4
    80004780:	fbbd                	bnez	a5,800046f6 <kexec+0x298>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004782:	e1c42503          	lw	a0,-484(s0)
    80004786:	cbdff0ef          	jal	ra,80004442 <flags2perm>
    8000478a:	86aa                	mv	a3,a0
    8000478c:	8626                	mv	a2,s1
    8000478e:	85ca                	mv	a1,s2
    80004790:	855a                	mv	a0,s6
    80004792:	a8ffc0ef          	jal	ra,80001220 <uvmalloc>
    80004796:	dea43c23          	sd	a0,-520(s0)
    8000479a:	d12d                	beqz	a0,800046fc <kexec+0x29e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000479c:	e2843c03          	ld	s8,-472(s0)
    800047a0:	e2042c83          	lw	s9,-480(s0)
    800047a4:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800047a8:	f60b89e3          	beqz	s7,8000471a <kexec+0x2bc>
    800047ac:	89de                	mv	s3,s7
    800047ae:	4481                	li	s1,0
    800047b0:	bb55                	j	80004564 <kexec+0x106>

00000000800047b2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800047b2:	7179                	addi	sp,sp,-48
    800047b4:	f406                	sd	ra,40(sp)
    800047b6:	f022                	sd	s0,32(sp)
    800047b8:	ec26                	sd	s1,24(sp)
    800047ba:	e84a                	sd	s2,16(sp)
    800047bc:	1800                	addi	s0,sp,48
    800047be:	892e                	mv	s2,a1
    800047c0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800047c2:	fdc40593          	addi	a1,s0,-36
    800047c6:	f33fd0ef          	jal	ra,800026f8 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800047ca:	fdc42703          	lw	a4,-36(s0)
    800047ce:	47bd                	li	a5,15
    800047d0:	02e7e963          	bltu	a5,a4,80004802 <argfd+0x50>
    800047d4:	830fd0ef          	jal	ra,80001804 <myproc>
    800047d8:	fdc42703          	lw	a4,-36(s0)
    800047dc:	01a70793          	addi	a5,a4,26
    800047e0:	078e                	slli	a5,a5,0x3
    800047e2:	953e                	add	a0,a0,a5
    800047e4:	611c                	ld	a5,0(a0)
    800047e6:	c385                	beqz	a5,80004806 <argfd+0x54>
    return -1;
  if(pfd)
    800047e8:	00090463          	beqz	s2,800047f0 <argfd+0x3e>
    *pfd = fd;
    800047ec:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800047f0:	4501                	li	a0,0
  if(pf)
    800047f2:	c091                	beqz	s1,800047f6 <argfd+0x44>
    *pf = f;
    800047f4:	e09c                	sd	a5,0(s1)
}
    800047f6:	70a2                	ld	ra,40(sp)
    800047f8:	7402                	ld	s0,32(sp)
    800047fa:	64e2                	ld	s1,24(sp)
    800047fc:	6942                	ld	s2,16(sp)
    800047fe:	6145                	addi	sp,sp,48
    80004800:	8082                	ret
    return -1;
    80004802:	557d                	li	a0,-1
    80004804:	bfcd                	j	800047f6 <argfd+0x44>
    80004806:	557d                	li	a0,-1
    80004808:	b7fd                	j	800047f6 <argfd+0x44>

000000008000480a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000480a:	1101                	addi	sp,sp,-32
    8000480c:	ec06                	sd	ra,24(sp)
    8000480e:	e822                	sd	s0,16(sp)
    80004810:	e426                	sd	s1,8(sp)
    80004812:	1000                	addi	s0,sp,32
    80004814:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004816:	feffc0ef          	jal	ra,80001804 <myproc>
    8000481a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000481c:	0d050793          	addi	a5,a0,208
    80004820:	4501                	li	a0,0
    80004822:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004824:	6398                	ld	a4,0(a5)
    80004826:	cb19                	beqz	a4,8000483c <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004828:	2505                	addiw	a0,a0,1
    8000482a:	07a1                	addi	a5,a5,8
    8000482c:	fed51ce3          	bne	a0,a3,80004824 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004830:	557d                	li	a0,-1
}
    80004832:	60e2                	ld	ra,24(sp)
    80004834:	6442                	ld	s0,16(sp)
    80004836:	64a2                	ld	s1,8(sp)
    80004838:	6105                	addi	sp,sp,32
    8000483a:	8082                	ret
      p->ofile[fd] = f;
    8000483c:	01a50793          	addi	a5,a0,26
    80004840:	078e                	slli	a5,a5,0x3
    80004842:	963e                	add	a2,a2,a5
    80004844:	e204                	sd	s1,0(a2)
      return fd;
    80004846:	b7f5                	j	80004832 <fdalloc+0x28>

0000000080004848 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004848:	715d                	addi	sp,sp,-80
    8000484a:	e486                	sd	ra,72(sp)
    8000484c:	e0a2                	sd	s0,64(sp)
    8000484e:	fc26                	sd	s1,56(sp)
    80004850:	f84a                	sd	s2,48(sp)
    80004852:	f44e                	sd	s3,40(sp)
    80004854:	f052                	sd	s4,32(sp)
    80004856:	ec56                	sd	s5,24(sp)
    80004858:	e85a                	sd	s6,16(sp)
    8000485a:	0880                	addi	s0,sp,80
    8000485c:	8b2e                	mv	s6,a1
    8000485e:	89b2                	mv	s3,a2
    80004860:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004862:	fb040593          	addi	a1,s0,-80
    80004866:	872ff0ef          	jal	ra,800038d8 <nameiparent>
    8000486a:	84aa                	mv	s1,a0
    8000486c:	10050b63          	beqz	a0,80004982 <create+0x13a>
    return 0;

  ilock(dp);
    80004870:	861fe0ef          	jal	ra,800030d0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004874:	4601                	li	a2,0
    80004876:	fb040593          	addi	a1,s0,-80
    8000487a:	8526                	mv	a0,s1
    8000487c:	dddfe0ef          	jal	ra,80003658 <dirlookup>
    80004880:	8aaa                	mv	s5,a0
    80004882:	c521                	beqz	a0,800048ca <create+0x82>
    iunlockput(dp);
    80004884:	8526                	mv	a0,s1
    80004886:	a51fe0ef          	jal	ra,800032d6 <iunlockput>
    ilock(ip);
    8000488a:	8556                	mv	a0,s5
    8000488c:	845fe0ef          	jal	ra,800030d0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004890:	000b059b          	sext.w	a1,s6
    80004894:	4789                	li	a5,2
    80004896:	02f59563          	bne	a1,a5,800048c0 <create+0x78>
    8000489a:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffde4dc>
    8000489e:	37f9                	addiw	a5,a5,-2
    800048a0:	17c2                	slli	a5,a5,0x30
    800048a2:	93c1                	srli	a5,a5,0x30
    800048a4:	4705                	li	a4,1
    800048a6:	00f76d63          	bltu	a4,a5,800048c0 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800048aa:	8556                	mv	a0,s5
    800048ac:	60a6                	ld	ra,72(sp)
    800048ae:	6406                	ld	s0,64(sp)
    800048b0:	74e2                	ld	s1,56(sp)
    800048b2:	7942                	ld	s2,48(sp)
    800048b4:	79a2                	ld	s3,40(sp)
    800048b6:	7a02                	ld	s4,32(sp)
    800048b8:	6ae2                	ld	s5,24(sp)
    800048ba:	6b42                	ld	s6,16(sp)
    800048bc:	6161                	addi	sp,sp,80
    800048be:	8082                	ret
    iunlockput(ip);
    800048c0:	8556                	mv	a0,s5
    800048c2:	a15fe0ef          	jal	ra,800032d6 <iunlockput>
    return 0;
    800048c6:	4a81                	li	s5,0
    800048c8:	b7cd                	j	800048aa <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    800048ca:	85da                	mv	a1,s6
    800048cc:	4088                	lw	a0,0(s1)
    800048ce:	e9afe0ef          	jal	ra,80002f68 <ialloc>
    800048d2:	8a2a                	mv	s4,a0
    800048d4:	cd1d                	beqz	a0,80004912 <create+0xca>
  ilock(ip);
    800048d6:	ffafe0ef          	jal	ra,800030d0 <ilock>
  ip->major = major;
    800048da:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800048de:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800048e2:	4905                	li	s2,1
    800048e4:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800048e8:	8552                	mv	a0,s4
    800048ea:	f34fe0ef          	jal	ra,8000301e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800048ee:	000b059b          	sext.w	a1,s6
    800048f2:	03258563          	beq	a1,s2,8000491c <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    800048f6:	004a2603          	lw	a2,4(s4)
    800048fa:	fb040593          	addi	a1,s0,-80
    800048fe:	8526                	mv	a0,s1
    80004900:	f25fe0ef          	jal	ra,80003824 <dirlink>
    80004904:	06054363          	bltz	a0,8000496a <create+0x122>
  iunlockput(dp);
    80004908:	8526                	mv	a0,s1
    8000490a:	9cdfe0ef          	jal	ra,800032d6 <iunlockput>
  return ip;
    8000490e:	8ad2                	mv	s5,s4
    80004910:	bf69                	j	800048aa <create+0x62>
    iunlockput(dp);
    80004912:	8526                	mv	a0,s1
    80004914:	9c3fe0ef          	jal	ra,800032d6 <iunlockput>
    return 0;
    80004918:	8ad2                	mv	s5,s4
    8000491a:	bf41                	j	800048aa <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000491c:	004a2603          	lw	a2,4(s4)
    80004920:	00003597          	auipc	a1,0x3
    80004924:	db058593          	addi	a1,a1,-592 # 800076d0 <syscalls+0x2e0>
    80004928:	8552                	mv	a0,s4
    8000492a:	efbfe0ef          	jal	ra,80003824 <dirlink>
    8000492e:	02054e63          	bltz	a0,8000496a <create+0x122>
    80004932:	40d0                	lw	a2,4(s1)
    80004934:	00003597          	auipc	a1,0x3
    80004938:	da458593          	addi	a1,a1,-604 # 800076d8 <syscalls+0x2e8>
    8000493c:	8552                	mv	a0,s4
    8000493e:	ee7fe0ef          	jal	ra,80003824 <dirlink>
    80004942:	02054463          	bltz	a0,8000496a <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    80004946:	004a2603          	lw	a2,4(s4)
    8000494a:	fb040593          	addi	a1,s0,-80
    8000494e:	8526                	mv	a0,s1
    80004950:	ed5fe0ef          	jal	ra,80003824 <dirlink>
    80004954:	00054b63          	bltz	a0,8000496a <create+0x122>
    dp->nlink++;  // for ".."
    80004958:	04a4d783          	lhu	a5,74(s1)
    8000495c:	2785                	addiw	a5,a5,1
    8000495e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004962:	8526                	mv	a0,s1
    80004964:	ebafe0ef          	jal	ra,8000301e <iupdate>
    80004968:	b745                	j	80004908 <create+0xc0>
  ip->nlink = 0;
    8000496a:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000496e:	8552                	mv	a0,s4
    80004970:	eaefe0ef          	jal	ra,8000301e <iupdate>
  iunlockput(ip);
    80004974:	8552                	mv	a0,s4
    80004976:	961fe0ef          	jal	ra,800032d6 <iunlockput>
  iunlockput(dp);
    8000497a:	8526                	mv	a0,s1
    8000497c:	95bfe0ef          	jal	ra,800032d6 <iunlockput>
  return 0;
    80004980:	b72d                	j	800048aa <create+0x62>
    return 0;
    80004982:	8aaa                	mv	s5,a0
    80004984:	b71d                	j	800048aa <create+0x62>

0000000080004986 <sys_dup>:
{
    80004986:	7179                	addi	sp,sp,-48
    80004988:	f406                	sd	ra,40(sp)
    8000498a:	f022                	sd	s0,32(sp)
    8000498c:	ec26                	sd	s1,24(sp)
    8000498e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004990:	fd840613          	addi	a2,s0,-40
    80004994:	4581                	li	a1,0
    80004996:	4501                	li	a0,0
    80004998:	e1bff0ef          	jal	ra,800047b2 <argfd>
    return -1;
    8000499c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000499e:	00054f63          	bltz	a0,800049bc <sys_dup+0x36>
  if((fd=fdalloc(f)) < 0)
    800049a2:	fd843503          	ld	a0,-40(s0)
    800049a6:	e65ff0ef          	jal	ra,8000480a <fdalloc>
    800049aa:	84aa                	mv	s1,a0
    return -1;
    800049ac:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800049ae:	00054763          	bltz	a0,800049bc <sys_dup+0x36>
  filedup(f);
    800049b2:	fd843503          	ld	a0,-40(s0)
    800049b6:	cc0ff0ef          	jal	ra,80003e76 <filedup>
  return fd;
    800049ba:	87a6                	mv	a5,s1
}
    800049bc:	853e                	mv	a0,a5
    800049be:	70a2                	ld	ra,40(sp)
    800049c0:	7402                	ld	s0,32(sp)
    800049c2:	64e2                	ld	s1,24(sp)
    800049c4:	6145                	addi	sp,sp,48
    800049c6:	8082                	ret

00000000800049c8 <sys_read>:
{
    800049c8:	7179                	addi	sp,sp,-48
    800049ca:	f406                	sd	ra,40(sp)
    800049cc:	f022                	sd	s0,32(sp)
    800049ce:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800049d0:	fd840593          	addi	a1,s0,-40
    800049d4:	4505                	li	a0,1
    800049d6:	d3ffd0ef          	jal	ra,80002714 <argaddr>
  argint(2, &n);
    800049da:	fe440593          	addi	a1,s0,-28
    800049de:	4509                	li	a0,2
    800049e0:	d19fd0ef          	jal	ra,800026f8 <argint>
  if(argfd(0, 0, &f) < 0)
    800049e4:	fe840613          	addi	a2,s0,-24
    800049e8:	4581                	li	a1,0
    800049ea:	4501                	li	a0,0
    800049ec:	dc7ff0ef          	jal	ra,800047b2 <argfd>
    800049f0:	87aa                	mv	a5,a0
    return -1;
    800049f2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800049f4:	0007ca63          	bltz	a5,80004a08 <sys_read+0x40>
  return fileread(f, p, n);
    800049f8:	fe442603          	lw	a2,-28(s0)
    800049fc:	fd843583          	ld	a1,-40(s0)
    80004a00:	fe843503          	ld	a0,-24(s0)
    80004a04:	dbeff0ef          	jal	ra,80003fc2 <fileread>
}
    80004a08:	70a2                	ld	ra,40(sp)
    80004a0a:	7402                	ld	s0,32(sp)
    80004a0c:	6145                	addi	sp,sp,48
    80004a0e:	8082                	ret

0000000080004a10 <sys_write>:
{
    80004a10:	7179                	addi	sp,sp,-48
    80004a12:	f406                	sd	ra,40(sp)
    80004a14:	f022                	sd	s0,32(sp)
    80004a16:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004a18:	fd840593          	addi	a1,s0,-40
    80004a1c:	4505                	li	a0,1
    80004a1e:	cf7fd0ef          	jal	ra,80002714 <argaddr>
  argint(2, &n);
    80004a22:	fe440593          	addi	a1,s0,-28
    80004a26:	4509                	li	a0,2
    80004a28:	cd1fd0ef          	jal	ra,800026f8 <argint>
  if(argfd(0, 0, &f) < 0)
    80004a2c:	fe840613          	addi	a2,s0,-24
    80004a30:	4581                	li	a1,0
    80004a32:	4501                	li	a0,0
    80004a34:	d7fff0ef          	jal	ra,800047b2 <argfd>
    80004a38:	87aa                	mv	a5,a0
    return -1;
    80004a3a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004a3c:	0007ca63          	bltz	a5,80004a50 <sys_write+0x40>
  return filewrite(f, p, n);
    80004a40:	fe442603          	lw	a2,-28(s0)
    80004a44:	fd843583          	ld	a1,-40(s0)
    80004a48:	fe843503          	ld	a0,-24(s0)
    80004a4c:	e24ff0ef          	jal	ra,80004070 <filewrite>
}
    80004a50:	70a2                	ld	ra,40(sp)
    80004a52:	7402                	ld	s0,32(sp)
    80004a54:	6145                	addi	sp,sp,48
    80004a56:	8082                	ret

0000000080004a58 <sys_close>:
{
    80004a58:	1101                	addi	sp,sp,-32
    80004a5a:	ec06                	sd	ra,24(sp)
    80004a5c:	e822                	sd	s0,16(sp)
    80004a5e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004a60:	fe040613          	addi	a2,s0,-32
    80004a64:	fec40593          	addi	a1,s0,-20
    80004a68:	4501                	li	a0,0
    80004a6a:	d49ff0ef          	jal	ra,800047b2 <argfd>
    return -1;
    80004a6e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004a70:	02054063          	bltz	a0,80004a90 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004a74:	d91fc0ef          	jal	ra,80001804 <myproc>
    80004a78:	fec42783          	lw	a5,-20(s0)
    80004a7c:	07e9                	addi	a5,a5,26
    80004a7e:	078e                	slli	a5,a5,0x3
    80004a80:	97aa                	add	a5,a5,a0
    80004a82:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80004a86:	fe043503          	ld	a0,-32(s0)
    80004a8a:	c32ff0ef          	jal	ra,80003ebc <fileclose>
  return 0;
    80004a8e:	4781                	li	a5,0
}
    80004a90:	853e                	mv	a0,a5
    80004a92:	60e2                	ld	ra,24(sp)
    80004a94:	6442                	ld	s0,16(sp)
    80004a96:	6105                	addi	sp,sp,32
    80004a98:	8082                	ret

0000000080004a9a <sys_fstat>:
{
    80004a9a:	1101                	addi	sp,sp,-32
    80004a9c:	ec06                	sd	ra,24(sp)
    80004a9e:	e822                	sd	s0,16(sp)
    80004aa0:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004aa2:	fe040593          	addi	a1,s0,-32
    80004aa6:	4505                	li	a0,1
    80004aa8:	c6dfd0ef          	jal	ra,80002714 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004aac:	fe840613          	addi	a2,s0,-24
    80004ab0:	4581                	li	a1,0
    80004ab2:	4501                	li	a0,0
    80004ab4:	cffff0ef          	jal	ra,800047b2 <argfd>
    80004ab8:	87aa                	mv	a5,a0
    return -1;
    80004aba:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004abc:	0007c863          	bltz	a5,80004acc <sys_fstat+0x32>
  return filestat(f, st);
    80004ac0:	fe043583          	ld	a1,-32(s0)
    80004ac4:	fe843503          	ld	a0,-24(s0)
    80004ac8:	c9cff0ef          	jal	ra,80003f64 <filestat>
}
    80004acc:	60e2                	ld	ra,24(sp)
    80004ace:	6442                	ld	s0,16(sp)
    80004ad0:	6105                	addi	sp,sp,32
    80004ad2:	8082                	ret

0000000080004ad4 <sys_link>:
{
    80004ad4:	7169                	addi	sp,sp,-304
    80004ad6:	f606                	sd	ra,296(sp)
    80004ad8:	f222                	sd	s0,288(sp)
    80004ada:	ee26                	sd	s1,280(sp)
    80004adc:	ea4a                	sd	s2,272(sp)
    80004ade:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004ae0:	08000613          	li	a2,128
    80004ae4:	ed040593          	addi	a1,s0,-304
    80004ae8:	4501                	li	a0,0
    80004aea:	c47fd0ef          	jal	ra,80002730 <argstr>
    return -1;
    80004aee:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004af0:	0c054663          	bltz	a0,80004bbc <sys_link+0xe8>
    80004af4:	08000613          	li	a2,128
    80004af8:	f5040593          	addi	a1,s0,-176
    80004afc:	4505                	li	a0,1
    80004afe:	c33fd0ef          	jal	ra,80002730 <argstr>
    return -1;
    80004b02:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004b04:	0a054c63          	bltz	a0,80004bbc <sys_link+0xe8>
  begin_op();
    80004b08:	fa7fe0ef          	jal	ra,80003aae <begin_op>
  if((ip = namei(old)) == 0){
    80004b0c:	ed040513          	addi	a0,s0,-304
    80004b10:	daffe0ef          	jal	ra,800038be <namei>
    80004b14:	84aa                	mv	s1,a0
    80004b16:	c525                	beqz	a0,80004b7e <sys_link+0xaa>
  ilock(ip);
    80004b18:	db8fe0ef          	jal	ra,800030d0 <ilock>
  if(ip->type == T_DIR){
    80004b1c:	04449703          	lh	a4,68(s1)
    80004b20:	4785                	li	a5,1
    80004b22:	06f70263          	beq	a4,a5,80004b86 <sys_link+0xb2>
  ip->nlink++;
    80004b26:	04a4d783          	lhu	a5,74(s1)
    80004b2a:	2785                	addiw	a5,a5,1
    80004b2c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004b30:	8526                	mv	a0,s1
    80004b32:	cecfe0ef          	jal	ra,8000301e <iupdate>
  iunlock(ip);
    80004b36:	8526                	mv	a0,s1
    80004b38:	e42fe0ef          	jal	ra,8000317a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004b3c:	fd040593          	addi	a1,s0,-48
    80004b40:	f5040513          	addi	a0,s0,-176
    80004b44:	d95fe0ef          	jal	ra,800038d8 <nameiparent>
    80004b48:	892a                	mv	s2,a0
    80004b4a:	c921                	beqz	a0,80004b9a <sys_link+0xc6>
  ilock(dp);
    80004b4c:	d84fe0ef          	jal	ra,800030d0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004b50:	00092703          	lw	a4,0(s2)
    80004b54:	409c                	lw	a5,0(s1)
    80004b56:	02f71f63          	bne	a4,a5,80004b94 <sys_link+0xc0>
    80004b5a:	40d0                	lw	a2,4(s1)
    80004b5c:	fd040593          	addi	a1,s0,-48
    80004b60:	854a                	mv	a0,s2
    80004b62:	cc3fe0ef          	jal	ra,80003824 <dirlink>
    80004b66:	02054763          	bltz	a0,80004b94 <sys_link+0xc0>
  iunlockput(dp);
    80004b6a:	854a                	mv	a0,s2
    80004b6c:	f6afe0ef          	jal	ra,800032d6 <iunlockput>
  iput(ip);
    80004b70:	8526                	mv	a0,s1
    80004b72:	edcfe0ef          	jal	ra,8000324e <iput>
  end_op();
    80004b76:	fa9fe0ef          	jal	ra,80003b1e <end_op>
  return 0;
    80004b7a:	4781                	li	a5,0
    80004b7c:	a081                	j	80004bbc <sys_link+0xe8>
    end_op();
    80004b7e:	fa1fe0ef          	jal	ra,80003b1e <end_op>
    return -1;
    80004b82:	57fd                	li	a5,-1
    80004b84:	a825                	j	80004bbc <sys_link+0xe8>
    iunlockput(ip);
    80004b86:	8526                	mv	a0,s1
    80004b88:	f4efe0ef          	jal	ra,800032d6 <iunlockput>
    end_op();
    80004b8c:	f93fe0ef          	jal	ra,80003b1e <end_op>
    return -1;
    80004b90:	57fd                	li	a5,-1
    80004b92:	a02d                	j	80004bbc <sys_link+0xe8>
    iunlockput(dp);
    80004b94:	854a                	mv	a0,s2
    80004b96:	f40fe0ef          	jal	ra,800032d6 <iunlockput>
  ilock(ip);
    80004b9a:	8526                	mv	a0,s1
    80004b9c:	d34fe0ef          	jal	ra,800030d0 <ilock>
  ip->nlink--;
    80004ba0:	04a4d783          	lhu	a5,74(s1)
    80004ba4:	37fd                	addiw	a5,a5,-1
    80004ba6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004baa:	8526                	mv	a0,s1
    80004bac:	c72fe0ef          	jal	ra,8000301e <iupdate>
  iunlockput(ip);
    80004bb0:	8526                	mv	a0,s1
    80004bb2:	f24fe0ef          	jal	ra,800032d6 <iunlockput>
  end_op();
    80004bb6:	f69fe0ef          	jal	ra,80003b1e <end_op>
  return -1;
    80004bba:	57fd                	li	a5,-1
}
    80004bbc:	853e                	mv	a0,a5
    80004bbe:	70b2                	ld	ra,296(sp)
    80004bc0:	7412                	ld	s0,288(sp)
    80004bc2:	64f2                	ld	s1,280(sp)
    80004bc4:	6952                	ld	s2,272(sp)
    80004bc6:	6155                	addi	sp,sp,304
    80004bc8:	8082                	ret

0000000080004bca <sys_unlink>:
{
    80004bca:	7151                	addi	sp,sp,-240
    80004bcc:	f586                	sd	ra,232(sp)
    80004bce:	f1a2                	sd	s0,224(sp)
    80004bd0:	eda6                	sd	s1,216(sp)
    80004bd2:	e9ca                	sd	s2,208(sp)
    80004bd4:	e5ce                	sd	s3,200(sp)
    80004bd6:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004bd8:	08000613          	li	a2,128
    80004bdc:	f3040593          	addi	a1,s0,-208
    80004be0:	4501                	li	a0,0
    80004be2:	b4ffd0ef          	jal	ra,80002730 <argstr>
    80004be6:	12054b63          	bltz	a0,80004d1c <sys_unlink+0x152>
  begin_op();
    80004bea:	ec5fe0ef          	jal	ra,80003aae <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004bee:	fb040593          	addi	a1,s0,-80
    80004bf2:	f3040513          	addi	a0,s0,-208
    80004bf6:	ce3fe0ef          	jal	ra,800038d8 <nameiparent>
    80004bfa:	84aa                	mv	s1,a0
    80004bfc:	c54d                	beqz	a0,80004ca6 <sys_unlink+0xdc>
  ilock(dp);
    80004bfe:	cd2fe0ef          	jal	ra,800030d0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004c02:	00003597          	auipc	a1,0x3
    80004c06:	ace58593          	addi	a1,a1,-1330 # 800076d0 <syscalls+0x2e0>
    80004c0a:	fb040513          	addi	a0,s0,-80
    80004c0e:	a35fe0ef          	jal	ra,80003642 <namecmp>
    80004c12:	10050a63          	beqz	a0,80004d26 <sys_unlink+0x15c>
    80004c16:	00003597          	auipc	a1,0x3
    80004c1a:	ac258593          	addi	a1,a1,-1342 # 800076d8 <syscalls+0x2e8>
    80004c1e:	fb040513          	addi	a0,s0,-80
    80004c22:	a21fe0ef          	jal	ra,80003642 <namecmp>
    80004c26:	10050063          	beqz	a0,80004d26 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004c2a:	f2c40613          	addi	a2,s0,-212
    80004c2e:	fb040593          	addi	a1,s0,-80
    80004c32:	8526                	mv	a0,s1
    80004c34:	a25fe0ef          	jal	ra,80003658 <dirlookup>
    80004c38:	892a                	mv	s2,a0
    80004c3a:	0e050663          	beqz	a0,80004d26 <sys_unlink+0x15c>
  ilock(ip);
    80004c3e:	c92fe0ef          	jal	ra,800030d0 <ilock>
  if(ip->nlink < 1)
    80004c42:	04a91783          	lh	a5,74(s2)
    80004c46:	06f05463          	blez	a5,80004cae <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004c4a:	04491703          	lh	a4,68(s2)
    80004c4e:	4785                	li	a5,1
    80004c50:	06f70563          	beq	a4,a5,80004cba <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    80004c54:	4641                	li	a2,16
    80004c56:	4581                	li	a1,0
    80004c58:	fc040513          	addi	a0,s0,-64
    80004c5c:	fe5fb0ef          	jal	ra,80000c40 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004c60:	4741                	li	a4,16
    80004c62:	f2c42683          	lw	a3,-212(s0)
    80004c66:	fc040613          	addi	a2,s0,-64
    80004c6a:	4581                	li	a1,0
    80004c6c:	8526                	mv	a0,s1
    80004c6e:	8d3fe0ef          	jal	ra,80003540 <writei>
    80004c72:	47c1                	li	a5,16
    80004c74:	08f51563          	bne	a0,a5,80004cfe <sys_unlink+0x134>
  if(ip->type == T_DIR){
    80004c78:	04491703          	lh	a4,68(s2)
    80004c7c:	4785                	li	a5,1
    80004c7e:	08f70663          	beq	a4,a5,80004d0a <sys_unlink+0x140>
  iunlockput(dp);
    80004c82:	8526                	mv	a0,s1
    80004c84:	e52fe0ef          	jal	ra,800032d6 <iunlockput>
  ip->nlink--;
    80004c88:	04a95783          	lhu	a5,74(s2)
    80004c8c:	37fd                	addiw	a5,a5,-1
    80004c8e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004c92:	854a                	mv	a0,s2
    80004c94:	b8afe0ef          	jal	ra,8000301e <iupdate>
  iunlockput(ip);
    80004c98:	854a                	mv	a0,s2
    80004c9a:	e3cfe0ef          	jal	ra,800032d6 <iunlockput>
  end_op();
    80004c9e:	e81fe0ef          	jal	ra,80003b1e <end_op>
  return 0;
    80004ca2:	4501                	li	a0,0
    80004ca4:	a079                	j	80004d32 <sys_unlink+0x168>
    end_op();
    80004ca6:	e79fe0ef          	jal	ra,80003b1e <end_op>
    return -1;
    80004caa:	557d                	li	a0,-1
    80004cac:	a059                	j	80004d32 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80004cae:	00003517          	auipc	a0,0x3
    80004cb2:	a3250513          	addi	a0,a0,-1486 # 800076e0 <syscalls+0x2f0>
    80004cb6:	ad5fb0ef          	jal	ra,8000078a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004cba:	04c92703          	lw	a4,76(s2)
    80004cbe:	02000793          	li	a5,32
    80004cc2:	f8e7f9e3          	bgeu	a5,a4,80004c54 <sys_unlink+0x8a>
    80004cc6:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004cca:	4741                	li	a4,16
    80004ccc:	86ce                	mv	a3,s3
    80004cce:	f1840613          	addi	a2,s0,-232
    80004cd2:	4581                	li	a1,0
    80004cd4:	854a                	mv	a0,s2
    80004cd6:	f86fe0ef          	jal	ra,8000345c <readi>
    80004cda:	47c1                	li	a5,16
    80004cdc:	00f51b63          	bne	a0,a5,80004cf2 <sys_unlink+0x128>
    if(de.inum != 0)
    80004ce0:	f1845783          	lhu	a5,-232(s0)
    80004ce4:	ef95                	bnez	a5,80004d20 <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004ce6:	29c1                	addiw	s3,s3,16
    80004ce8:	04c92783          	lw	a5,76(s2)
    80004cec:	fcf9efe3          	bltu	s3,a5,80004cca <sys_unlink+0x100>
    80004cf0:	b795                	j	80004c54 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004cf2:	00003517          	auipc	a0,0x3
    80004cf6:	a0650513          	addi	a0,a0,-1530 # 800076f8 <syscalls+0x308>
    80004cfa:	a91fb0ef          	jal	ra,8000078a <panic>
    panic("unlink: writei");
    80004cfe:	00003517          	auipc	a0,0x3
    80004d02:	a1250513          	addi	a0,a0,-1518 # 80007710 <syscalls+0x320>
    80004d06:	a85fb0ef          	jal	ra,8000078a <panic>
    dp->nlink--;
    80004d0a:	04a4d783          	lhu	a5,74(s1)
    80004d0e:	37fd                	addiw	a5,a5,-1
    80004d10:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004d14:	8526                	mv	a0,s1
    80004d16:	b08fe0ef          	jal	ra,8000301e <iupdate>
    80004d1a:	b7a5                	j	80004c82 <sys_unlink+0xb8>
    return -1;
    80004d1c:	557d                	li	a0,-1
    80004d1e:	a811                	j	80004d32 <sys_unlink+0x168>
    iunlockput(ip);
    80004d20:	854a                	mv	a0,s2
    80004d22:	db4fe0ef          	jal	ra,800032d6 <iunlockput>
  iunlockput(dp);
    80004d26:	8526                	mv	a0,s1
    80004d28:	daefe0ef          	jal	ra,800032d6 <iunlockput>
  end_op();
    80004d2c:	df3fe0ef          	jal	ra,80003b1e <end_op>
  return -1;
    80004d30:	557d                	li	a0,-1
}
    80004d32:	70ae                	ld	ra,232(sp)
    80004d34:	740e                	ld	s0,224(sp)
    80004d36:	64ee                	ld	s1,216(sp)
    80004d38:	694e                	ld	s2,208(sp)
    80004d3a:	69ae                	ld	s3,200(sp)
    80004d3c:	616d                	addi	sp,sp,240
    80004d3e:	8082                	ret

0000000080004d40 <sys_open>:

uint64
sys_open(void)
{
    80004d40:	7131                	addi	sp,sp,-192
    80004d42:	fd06                	sd	ra,184(sp)
    80004d44:	f922                	sd	s0,176(sp)
    80004d46:	f526                	sd	s1,168(sp)
    80004d48:	f14a                	sd	s2,160(sp)
    80004d4a:	ed4e                	sd	s3,152(sp)
    80004d4c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004d4e:	f4c40593          	addi	a1,s0,-180
    80004d52:	4505                	li	a0,1
    80004d54:	9a5fd0ef          	jal	ra,800026f8 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004d58:	08000613          	li	a2,128
    80004d5c:	f5040593          	addi	a1,s0,-176
    80004d60:	4501                	li	a0,0
    80004d62:	9cffd0ef          	jal	ra,80002730 <argstr>
    80004d66:	87aa                	mv	a5,a0
    return -1;
    80004d68:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004d6a:	0807cd63          	bltz	a5,80004e04 <sys_open+0xc4>

  begin_op();
    80004d6e:	d41fe0ef          	jal	ra,80003aae <begin_op>

  if(omode & O_CREATE){
    80004d72:	f4c42783          	lw	a5,-180(s0)
    80004d76:	2007f793          	andi	a5,a5,512
    80004d7a:	c3c5                	beqz	a5,80004e1a <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004d7c:	4681                	li	a3,0
    80004d7e:	4601                	li	a2,0
    80004d80:	4589                	li	a1,2
    80004d82:	f5040513          	addi	a0,s0,-176
    80004d86:	ac3ff0ef          	jal	ra,80004848 <create>
    80004d8a:	84aa                	mv	s1,a0
    if(ip == 0){
    80004d8c:	c159                	beqz	a0,80004e12 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004d8e:	04449703          	lh	a4,68(s1)
    80004d92:	478d                	li	a5,3
    80004d94:	00f71763          	bne	a4,a5,80004da2 <sys_open+0x62>
    80004d98:	0464d703          	lhu	a4,70(s1)
    80004d9c:	47a5                	li	a5,9
    80004d9e:	0ae7e963          	bltu	a5,a4,80004e50 <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004da2:	876ff0ef          	jal	ra,80003e18 <filealloc>
    80004da6:	89aa                	mv	s3,a0
    80004da8:	0c050963          	beqz	a0,80004e7a <sys_open+0x13a>
    80004dac:	a5fff0ef          	jal	ra,8000480a <fdalloc>
    80004db0:	892a                	mv	s2,a0
    80004db2:	0c054163          	bltz	a0,80004e74 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004db6:	04449703          	lh	a4,68(s1)
    80004dba:	478d                	li	a5,3
    80004dbc:	0af70163          	beq	a4,a5,80004e5e <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004dc0:	4789                	li	a5,2
    80004dc2:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80004dc6:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80004dca:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80004dce:	f4c42783          	lw	a5,-180(s0)
    80004dd2:	0017c713          	xori	a4,a5,1
    80004dd6:	8b05                	andi	a4,a4,1
    80004dd8:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004ddc:	0037f713          	andi	a4,a5,3
    80004de0:	00e03733          	snez	a4,a4
    80004de4:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004de8:	4007f793          	andi	a5,a5,1024
    80004dec:	c791                	beqz	a5,80004df8 <sys_open+0xb8>
    80004dee:	04449703          	lh	a4,68(s1)
    80004df2:	4789                	li	a5,2
    80004df4:	06f70c63          	beq	a4,a5,80004e6c <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    80004df8:	8526                	mv	a0,s1
    80004dfa:	b80fe0ef          	jal	ra,8000317a <iunlock>
  end_op();
    80004dfe:	d21fe0ef          	jal	ra,80003b1e <end_op>

  return fd;
    80004e02:	854a                	mv	a0,s2
}
    80004e04:	70ea                	ld	ra,184(sp)
    80004e06:	744a                	ld	s0,176(sp)
    80004e08:	74aa                	ld	s1,168(sp)
    80004e0a:	790a                	ld	s2,160(sp)
    80004e0c:	69ea                	ld	s3,152(sp)
    80004e0e:	6129                	addi	sp,sp,192
    80004e10:	8082                	ret
      end_op();
    80004e12:	d0dfe0ef          	jal	ra,80003b1e <end_op>
      return -1;
    80004e16:	557d                	li	a0,-1
    80004e18:	b7f5                	j	80004e04 <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    80004e1a:	f5040513          	addi	a0,s0,-176
    80004e1e:	aa1fe0ef          	jal	ra,800038be <namei>
    80004e22:	84aa                	mv	s1,a0
    80004e24:	c115                	beqz	a0,80004e48 <sys_open+0x108>
    ilock(ip);
    80004e26:	aaafe0ef          	jal	ra,800030d0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004e2a:	04449703          	lh	a4,68(s1)
    80004e2e:	4785                	li	a5,1
    80004e30:	f4f71fe3          	bne	a4,a5,80004d8e <sys_open+0x4e>
    80004e34:	f4c42783          	lw	a5,-180(s0)
    80004e38:	d7ad                	beqz	a5,80004da2 <sys_open+0x62>
      iunlockput(ip);
    80004e3a:	8526                	mv	a0,s1
    80004e3c:	c9afe0ef          	jal	ra,800032d6 <iunlockput>
      end_op();
    80004e40:	cdffe0ef          	jal	ra,80003b1e <end_op>
      return -1;
    80004e44:	557d                	li	a0,-1
    80004e46:	bf7d                	j	80004e04 <sys_open+0xc4>
      end_op();
    80004e48:	cd7fe0ef          	jal	ra,80003b1e <end_op>
      return -1;
    80004e4c:	557d                	li	a0,-1
    80004e4e:	bf5d                	j	80004e04 <sys_open+0xc4>
    iunlockput(ip);
    80004e50:	8526                	mv	a0,s1
    80004e52:	c84fe0ef          	jal	ra,800032d6 <iunlockput>
    end_op();
    80004e56:	cc9fe0ef          	jal	ra,80003b1e <end_op>
    return -1;
    80004e5a:	557d                	li	a0,-1
    80004e5c:	b765                	j	80004e04 <sys_open+0xc4>
    f->type = FD_DEVICE;
    80004e5e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80004e62:	04649783          	lh	a5,70(s1)
    80004e66:	02f99223          	sh	a5,36(s3)
    80004e6a:	b785                	j	80004dca <sys_open+0x8a>
    itrunc(ip);
    80004e6c:	8526                	mv	a0,s1
    80004e6e:	b4cfe0ef          	jal	ra,800031ba <itrunc>
    80004e72:	b759                	j	80004df8 <sys_open+0xb8>
      fileclose(f);
    80004e74:	854e                	mv	a0,s3
    80004e76:	846ff0ef          	jal	ra,80003ebc <fileclose>
    iunlockput(ip);
    80004e7a:	8526                	mv	a0,s1
    80004e7c:	c5afe0ef          	jal	ra,800032d6 <iunlockput>
    end_op();
    80004e80:	c9ffe0ef          	jal	ra,80003b1e <end_op>
    return -1;
    80004e84:	557d                	li	a0,-1
    80004e86:	bfbd                	j	80004e04 <sys_open+0xc4>

0000000080004e88 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004e88:	7175                	addi	sp,sp,-144
    80004e8a:	e506                	sd	ra,136(sp)
    80004e8c:	e122                	sd	s0,128(sp)
    80004e8e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004e90:	c1ffe0ef          	jal	ra,80003aae <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004e94:	08000613          	li	a2,128
    80004e98:	f7040593          	addi	a1,s0,-144
    80004e9c:	4501                	li	a0,0
    80004e9e:	893fd0ef          	jal	ra,80002730 <argstr>
    80004ea2:	02054363          	bltz	a0,80004ec8 <sys_mkdir+0x40>
    80004ea6:	4681                	li	a3,0
    80004ea8:	4601                	li	a2,0
    80004eaa:	4585                	li	a1,1
    80004eac:	f7040513          	addi	a0,s0,-144
    80004eb0:	999ff0ef          	jal	ra,80004848 <create>
    80004eb4:	c911                	beqz	a0,80004ec8 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004eb6:	c20fe0ef          	jal	ra,800032d6 <iunlockput>
  end_op();
    80004eba:	c65fe0ef          	jal	ra,80003b1e <end_op>
  return 0;
    80004ebe:	4501                	li	a0,0
}
    80004ec0:	60aa                	ld	ra,136(sp)
    80004ec2:	640a                	ld	s0,128(sp)
    80004ec4:	6149                	addi	sp,sp,144
    80004ec6:	8082                	ret
    end_op();
    80004ec8:	c57fe0ef          	jal	ra,80003b1e <end_op>
    return -1;
    80004ecc:	557d                	li	a0,-1
    80004ece:	bfcd                	j	80004ec0 <sys_mkdir+0x38>

0000000080004ed0 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004ed0:	7135                	addi	sp,sp,-160
    80004ed2:	ed06                	sd	ra,152(sp)
    80004ed4:	e922                	sd	s0,144(sp)
    80004ed6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004ed8:	bd7fe0ef          	jal	ra,80003aae <begin_op>
  argint(1, &major);
    80004edc:	f6c40593          	addi	a1,s0,-148
    80004ee0:	4505                	li	a0,1
    80004ee2:	817fd0ef          	jal	ra,800026f8 <argint>
  argint(2, &minor);
    80004ee6:	f6840593          	addi	a1,s0,-152
    80004eea:	4509                	li	a0,2
    80004eec:	80dfd0ef          	jal	ra,800026f8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004ef0:	08000613          	li	a2,128
    80004ef4:	f7040593          	addi	a1,s0,-144
    80004ef8:	4501                	li	a0,0
    80004efa:	837fd0ef          	jal	ra,80002730 <argstr>
    80004efe:	02054563          	bltz	a0,80004f28 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004f02:	f6841683          	lh	a3,-152(s0)
    80004f06:	f6c41603          	lh	a2,-148(s0)
    80004f0a:	458d                	li	a1,3
    80004f0c:	f7040513          	addi	a0,s0,-144
    80004f10:	939ff0ef          	jal	ra,80004848 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004f14:	c911                	beqz	a0,80004f28 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004f16:	bc0fe0ef          	jal	ra,800032d6 <iunlockput>
  end_op();
    80004f1a:	c05fe0ef          	jal	ra,80003b1e <end_op>
  return 0;
    80004f1e:	4501                	li	a0,0
}
    80004f20:	60ea                	ld	ra,152(sp)
    80004f22:	644a                	ld	s0,144(sp)
    80004f24:	610d                	addi	sp,sp,160
    80004f26:	8082                	ret
    end_op();
    80004f28:	bf7fe0ef          	jal	ra,80003b1e <end_op>
    return -1;
    80004f2c:	557d                	li	a0,-1
    80004f2e:	bfcd                	j	80004f20 <sys_mknod+0x50>

0000000080004f30 <sys_chdir>:

uint64
sys_chdir(void)
{
    80004f30:	7135                	addi	sp,sp,-160
    80004f32:	ed06                	sd	ra,152(sp)
    80004f34:	e922                	sd	s0,144(sp)
    80004f36:	e526                	sd	s1,136(sp)
    80004f38:	e14a                	sd	s2,128(sp)
    80004f3a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004f3c:	8c9fc0ef          	jal	ra,80001804 <myproc>
    80004f40:	892a                	mv	s2,a0
  
  begin_op();
    80004f42:	b6dfe0ef          	jal	ra,80003aae <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004f46:	08000613          	li	a2,128
    80004f4a:	f6040593          	addi	a1,s0,-160
    80004f4e:	4501                	li	a0,0
    80004f50:	fe0fd0ef          	jal	ra,80002730 <argstr>
    80004f54:	04054163          	bltz	a0,80004f96 <sys_chdir+0x66>
    80004f58:	f6040513          	addi	a0,s0,-160
    80004f5c:	963fe0ef          	jal	ra,800038be <namei>
    80004f60:	84aa                	mv	s1,a0
    80004f62:	c915                	beqz	a0,80004f96 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80004f64:	96cfe0ef          	jal	ra,800030d0 <ilock>
  if(ip->type != T_DIR){
    80004f68:	04449703          	lh	a4,68(s1)
    80004f6c:	4785                	li	a5,1
    80004f6e:	02f71863          	bne	a4,a5,80004f9e <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80004f72:	8526                	mv	a0,s1
    80004f74:	a06fe0ef          	jal	ra,8000317a <iunlock>
  iput(p->cwd);
    80004f78:	15093503          	ld	a0,336(s2)
    80004f7c:	ad2fe0ef          	jal	ra,8000324e <iput>
  end_op();
    80004f80:	b9ffe0ef          	jal	ra,80003b1e <end_op>
  p->cwd = ip;
    80004f84:	14993823          	sd	s1,336(s2)
  return 0;
    80004f88:	4501                	li	a0,0
}
    80004f8a:	60ea                	ld	ra,152(sp)
    80004f8c:	644a                	ld	s0,144(sp)
    80004f8e:	64aa                	ld	s1,136(sp)
    80004f90:	690a                	ld	s2,128(sp)
    80004f92:	610d                	addi	sp,sp,160
    80004f94:	8082                	ret
    end_op();
    80004f96:	b89fe0ef          	jal	ra,80003b1e <end_op>
    return -1;
    80004f9a:	557d                	li	a0,-1
    80004f9c:	b7fd                	j	80004f8a <sys_chdir+0x5a>
    iunlockput(ip);
    80004f9e:	8526                	mv	a0,s1
    80004fa0:	b36fe0ef          	jal	ra,800032d6 <iunlockput>
    end_op();
    80004fa4:	b7bfe0ef          	jal	ra,80003b1e <end_op>
    return -1;
    80004fa8:	557d                	li	a0,-1
    80004faa:	b7c5                	j	80004f8a <sys_chdir+0x5a>

0000000080004fac <sys_exec>:

uint64
sys_exec(void)
{
    80004fac:	7145                	addi	sp,sp,-464
    80004fae:	e786                	sd	ra,456(sp)
    80004fb0:	e3a2                	sd	s0,448(sp)
    80004fb2:	ff26                	sd	s1,440(sp)
    80004fb4:	fb4a                	sd	s2,432(sp)
    80004fb6:	f74e                	sd	s3,424(sp)
    80004fb8:	f352                	sd	s4,416(sp)
    80004fba:	ef56                	sd	s5,408(sp)
    80004fbc:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80004fbe:	e3840593          	addi	a1,s0,-456
    80004fc2:	4505                	li	a0,1
    80004fc4:	f50fd0ef          	jal	ra,80002714 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80004fc8:	08000613          	li	a2,128
    80004fcc:	f4040593          	addi	a1,s0,-192
    80004fd0:	4501                	li	a0,0
    80004fd2:	f5efd0ef          	jal	ra,80002730 <argstr>
    80004fd6:	87aa                	mv	a5,a0
    return -1;
    80004fd8:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80004fda:	0a07c463          	bltz	a5,80005082 <sys_exec+0xd6>
  }
  memset(argv, 0, sizeof(argv));
    80004fde:	10000613          	li	a2,256
    80004fe2:	4581                	li	a1,0
    80004fe4:	e4040513          	addi	a0,s0,-448
    80004fe8:	c59fb0ef          	jal	ra,80000c40 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004fec:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80004ff0:	89a6                	mv	s3,s1
    80004ff2:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80004ff4:	02000a13          	li	s4,32
    80004ff8:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80004ffc:	00391793          	slli	a5,s2,0x3
    80005000:	e3040593          	addi	a1,s0,-464
    80005004:	e3843503          	ld	a0,-456(s0)
    80005008:	953e                	add	a0,a0,a5
    8000500a:	e64fd0ef          	jal	ra,8000266e <fetchaddr>
    8000500e:	02054663          	bltz	a0,8000503a <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    80005012:	e3043783          	ld	a5,-464(s0)
    80005016:	cf8d                	beqz	a5,80005050 <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005018:	a85fb0ef          	jal	ra,80000a9c <kalloc>
    8000501c:	85aa                	mv	a1,a0
    8000501e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005022:	cd01                	beqz	a0,8000503a <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005024:	6605                	lui	a2,0x1
    80005026:	e3043503          	ld	a0,-464(s0)
    8000502a:	e8efd0ef          	jal	ra,800026b8 <fetchstr>
    8000502e:	00054663          	bltz	a0,8000503a <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    80005032:	0905                	addi	s2,s2,1
    80005034:	09a1                	addi	s3,s3,8
    80005036:	fd4911e3          	bne	s2,s4,80004ff8 <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000503a:	10048913          	addi	s2,s1,256
    8000503e:	6088                	ld	a0,0(s1)
    80005040:	c121                	beqz	a0,80005080 <sys_exec+0xd4>
    kfree(argv[i]);
    80005042:	97bfb0ef          	jal	ra,800009bc <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005046:	04a1                	addi	s1,s1,8
    80005048:	ff249be3          	bne	s1,s2,8000503e <sys_exec+0x92>
  return -1;
    8000504c:	557d                	li	a0,-1
    8000504e:	a815                	j	80005082 <sys_exec+0xd6>
      argv[i] = 0;
    80005050:	0a8e                	slli	s5,s5,0x3
    80005052:	fc040793          	addi	a5,s0,-64
    80005056:	9abe                	add	s5,s5,a5
    80005058:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    8000505c:	e4040593          	addi	a1,s0,-448
    80005060:	f4040513          	addi	a0,s0,-192
    80005064:	bfaff0ef          	jal	ra,8000445e <kexec>
    80005068:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000506a:	10048993          	addi	s3,s1,256
    8000506e:	6088                	ld	a0,0(s1)
    80005070:	c511                	beqz	a0,8000507c <sys_exec+0xd0>
    kfree(argv[i]);
    80005072:	94bfb0ef          	jal	ra,800009bc <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005076:	04a1                	addi	s1,s1,8
    80005078:	ff349be3          	bne	s1,s3,8000506e <sys_exec+0xc2>
  return ret;
    8000507c:	854a                	mv	a0,s2
    8000507e:	a011                	j	80005082 <sys_exec+0xd6>
  return -1;
    80005080:	557d                	li	a0,-1
}
    80005082:	60be                	ld	ra,456(sp)
    80005084:	641e                	ld	s0,448(sp)
    80005086:	74fa                	ld	s1,440(sp)
    80005088:	795a                	ld	s2,432(sp)
    8000508a:	79ba                	ld	s3,424(sp)
    8000508c:	7a1a                	ld	s4,416(sp)
    8000508e:	6afa                	ld	s5,408(sp)
    80005090:	6179                	addi	sp,sp,464
    80005092:	8082                	ret

0000000080005094 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005094:	7139                	addi	sp,sp,-64
    80005096:	fc06                	sd	ra,56(sp)
    80005098:	f822                	sd	s0,48(sp)
    8000509a:	f426                	sd	s1,40(sp)
    8000509c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000509e:	f66fc0ef          	jal	ra,80001804 <myproc>
    800050a2:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800050a4:	fd840593          	addi	a1,s0,-40
    800050a8:	4501                	li	a0,0
    800050aa:	e6afd0ef          	jal	ra,80002714 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800050ae:	fc840593          	addi	a1,s0,-56
    800050b2:	fd040513          	addi	a0,s0,-48
    800050b6:	8d2ff0ef          	jal	ra,80004188 <pipealloc>
    return -1;
    800050ba:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800050bc:	0a054463          	bltz	a0,80005164 <sys_pipe+0xd0>
  fd0 = -1;
    800050c0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800050c4:	fd043503          	ld	a0,-48(s0)
    800050c8:	f42ff0ef          	jal	ra,8000480a <fdalloc>
    800050cc:	fca42223          	sw	a0,-60(s0)
    800050d0:	08054163          	bltz	a0,80005152 <sys_pipe+0xbe>
    800050d4:	fc843503          	ld	a0,-56(s0)
    800050d8:	f32ff0ef          	jal	ra,8000480a <fdalloc>
    800050dc:	fca42023          	sw	a0,-64(s0)
    800050e0:	06054063          	bltz	a0,80005140 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800050e4:	4691                	li	a3,4
    800050e6:	fc440613          	addi	a2,s0,-60
    800050ea:	fd843583          	ld	a1,-40(s0)
    800050ee:	68a8                	ld	a0,80(s1)
    800050f0:	c62fc0ef          	jal	ra,80001552 <copyout>
    800050f4:	00054e63          	bltz	a0,80005110 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800050f8:	4691                	li	a3,4
    800050fa:	fc040613          	addi	a2,s0,-64
    800050fe:	fd843583          	ld	a1,-40(s0)
    80005102:	0591                	addi	a1,a1,4
    80005104:	68a8                	ld	a0,80(s1)
    80005106:	c4cfc0ef          	jal	ra,80001552 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000510a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000510c:	04055c63          	bgez	a0,80005164 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005110:	fc442783          	lw	a5,-60(s0)
    80005114:	07e9                	addi	a5,a5,26
    80005116:	078e                	slli	a5,a5,0x3
    80005118:	97a6                	add	a5,a5,s1
    8000511a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000511e:	fc042503          	lw	a0,-64(s0)
    80005122:	0569                	addi	a0,a0,26
    80005124:	050e                	slli	a0,a0,0x3
    80005126:	94aa                	add	s1,s1,a0
    80005128:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000512c:	fd043503          	ld	a0,-48(s0)
    80005130:	d8dfe0ef          	jal	ra,80003ebc <fileclose>
    fileclose(wf);
    80005134:	fc843503          	ld	a0,-56(s0)
    80005138:	d85fe0ef          	jal	ra,80003ebc <fileclose>
    return -1;
    8000513c:	57fd                	li	a5,-1
    8000513e:	a01d                	j	80005164 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005140:	fc442783          	lw	a5,-60(s0)
    80005144:	0007c763          	bltz	a5,80005152 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005148:	07e9                	addi	a5,a5,26
    8000514a:	078e                	slli	a5,a5,0x3
    8000514c:	94be                	add	s1,s1,a5
    8000514e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005152:	fd043503          	ld	a0,-48(s0)
    80005156:	d67fe0ef          	jal	ra,80003ebc <fileclose>
    fileclose(wf);
    8000515a:	fc843503          	ld	a0,-56(s0)
    8000515e:	d5ffe0ef          	jal	ra,80003ebc <fileclose>
    return -1;
    80005162:	57fd                	li	a5,-1
}
    80005164:	853e                	mv	a0,a5
    80005166:	70e2                	ld	ra,56(sp)
    80005168:	7442                	ld	s0,48(sp)
    8000516a:	74a2                	ld	s1,40(sp)
    8000516c:	6121                	addi	sp,sp,64
    8000516e:	8082                	ret

0000000080005170 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005170:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005172:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005174:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005176:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005178:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000517a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000517c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000517e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005180:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005182:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005184:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005186:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005188:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000518a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000518c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000518e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005190:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005192:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005194:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005196:	be8fd0ef          	jal	ra,8000257e <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000519a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000519c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000519e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800051a0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800051a2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800051a4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800051a6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800051a8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800051aa:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800051ac:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800051ae:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800051b0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800051b2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800051b4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800051b6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800051b8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800051ba:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800051bc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800051be:	10200073          	sret
	...

00000000800051ce <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800051ce:	1141                	addi	sp,sp,-16
    800051d0:	e422                	sd	s0,8(sp)
    800051d2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800051d4:	0c0007b7          	lui	a5,0xc000
    800051d8:	4705                	li	a4,1
    800051da:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800051dc:	c3d8                	sw	a4,4(a5)
}
    800051de:	6422                	ld	s0,8(sp)
    800051e0:	0141                	addi	sp,sp,16
    800051e2:	8082                	ret

00000000800051e4 <plicinithart>:

void
plicinithart(void)
{
    800051e4:	1141                	addi	sp,sp,-16
    800051e6:	e406                	sd	ra,8(sp)
    800051e8:	e022                	sd	s0,0(sp)
    800051ea:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800051ec:	decfc0ef          	jal	ra,800017d8 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800051f0:	0085171b          	slliw	a4,a0,0x8
    800051f4:	0c0027b7          	lui	a5,0xc002
    800051f8:	97ba                	add	a5,a5,a4
    800051fa:	40200713          	li	a4,1026
    800051fe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005202:	00d5151b          	slliw	a0,a0,0xd
    80005206:	0c2017b7          	lui	a5,0xc201
    8000520a:	953e                	add	a0,a0,a5
    8000520c:	00052023          	sw	zero,0(a0)
}
    80005210:	60a2                	ld	ra,8(sp)
    80005212:	6402                	ld	s0,0(sp)
    80005214:	0141                	addi	sp,sp,16
    80005216:	8082                	ret

0000000080005218 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005218:	1141                	addi	sp,sp,-16
    8000521a:	e406                	sd	ra,8(sp)
    8000521c:	e022                	sd	s0,0(sp)
    8000521e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005220:	db8fc0ef          	jal	ra,800017d8 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005224:	00d5179b          	slliw	a5,a0,0xd
    80005228:	0c201537          	lui	a0,0xc201
    8000522c:	953e                	add	a0,a0,a5
  return irq;
}
    8000522e:	4148                	lw	a0,4(a0)
    80005230:	60a2                	ld	ra,8(sp)
    80005232:	6402                	ld	s0,0(sp)
    80005234:	0141                	addi	sp,sp,16
    80005236:	8082                	ret

0000000080005238 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005238:	1101                	addi	sp,sp,-32
    8000523a:	ec06                	sd	ra,24(sp)
    8000523c:	e822                	sd	s0,16(sp)
    8000523e:	e426                	sd	s1,8(sp)
    80005240:	1000                	addi	s0,sp,32
    80005242:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005244:	d94fc0ef          	jal	ra,800017d8 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005248:	00d5151b          	slliw	a0,a0,0xd
    8000524c:	0c2017b7          	lui	a5,0xc201
    80005250:	97aa                	add	a5,a5,a0
    80005252:	c3c4                	sw	s1,4(a5)
}
    80005254:	60e2                	ld	ra,24(sp)
    80005256:	6442                	ld	s0,16(sp)
    80005258:	64a2                	ld	s1,8(sp)
    8000525a:	6105                	addi	sp,sp,32
    8000525c:	8082                	ret

000000008000525e <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000525e:	1141                	addi	sp,sp,-16
    80005260:	e406                	sd	ra,8(sp)
    80005262:	e022                	sd	s0,0(sp)
    80005264:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005266:	479d                	li	a5,7
    80005268:	04a7ca63          	blt	a5,a0,800052bc <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    8000526c:	0001b797          	auipc	a5,0x1b
    80005270:	7bc78793          	addi	a5,a5,1980 # 80020a28 <disk>
    80005274:	97aa                	add	a5,a5,a0
    80005276:	0187c783          	lbu	a5,24(a5)
    8000527a:	e7b9                	bnez	a5,800052c8 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000527c:	00451613          	slli	a2,a0,0x4
    80005280:	0001b797          	auipc	a5,0x1b
    80005284:	7a878793          	addi	a5,a5,1960 # 80020a28 <disk>
    80005288:	6394                	ld	a3,0(a5)
    8000528a:	96b2                	add	a3,a3,a2
    8000528c:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005290:	6398                	ld	a4,0(a5)
    80005292:	9732                	add	a4,a4,a2
    80005294:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005298:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    8000529c:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800052a0:	953e                	add	a0,a0,a5
    800052a2:	4785                	li	a5,1
    800052a4:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    800052a8:	0001b517          	auipc	a0,0x1b
    800052ac:	79850513          	addi	a0,a0,1944 # 80020a40 <disk+0x18>
    800052b0:	b97fc0ef          	jal	ra,80001e46 <wakeup>
}
    800052b4:	60a2                	ld	ra,8(sp)
    800052b6:	6402                	ld	s0,0(sp)
    800052b8:	0141                	addi	sp,sp,16
    800052ba:	8082                	ret
    panic("free_desc 1");
    800052bc:	00002517          	auipc	a0,0x2
    800052c0:	46450513          	addi	a0,a0,1124 # 80007720 <syscalls+0x330>
    800052c4:	cc6fb0ef          	jal	ra,8000078a <panic>
    panic("free_desc 2");
    800052c8:	00002517          	auipc	a0,0x2
    800052cc:	46850513          	addi	a0,a0,1128 # 80007730 <syscalls+0x340>
    800052d0:	cbafb0ef          	jal	ra,8000078a <panic>

00000000800052d4 <virtio_disk_init>:
{
    800052d4:	1101                	addi	sp,sp,-32
    800052d6:	ec06                	sd	ra,24(sp)
    800052d8:	e822                	sd	s0,16(sp)
    800052da:	e426                	sd	s1,8(sp)
    800052dc:	e04a                	sd	s2,0(sp)
    800052de:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800052e0:	00002597          	auipc	a1,0x2
    800052e4:	46058593          	addi	a1,a1,1120 # 80007740 <syscalls+0x350>
    800052e8:	0001c517          	auipc	a0,0x1c
    800052ec:	86850513          	addi	a0,a0,-1944 # 80020b50 <disk+0x128>
    800052f0:	ffcfb0ef          	jal	ra,80000aec <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800052f4:	100017b7          	lui	a5,0x10001
    800052f8:	4398                	lw	a4,0(a5)
    800052fa:	2701                	sext.w	a4,a4
    800052fc:	747277b7          	lui	a5,0x74727
    80005300:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005304:	14f71063          	bne	a4,a5,80005444 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005308:	100017b7          	lui	a5,0x10001
    8000530c:	43dc                	lw	a5,4(a5)
    8000530e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005310:	4709                	li	a4,2
    80005312:	12e79963          	bne	a5,a4,80005444 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005316:	100017b7          	lui	a5,0x10001
    8000531a:	479c                	lw	a5,8(a5)
    8000531c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000531e:	12e79363          	bne	a5,a4,80005444 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005322:	100017b7          	lui	a5,0x10001
    80005326:	47d8                	lw	a4,12(a5)
    80005328:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000532a:	554d47b7          	lui	a5,0x554d4
    8000532e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005332:	10f71963          	bne	a4,a5,80005444 <virtio_disk_init+0x170>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005336:	100017b7          	lui	a5,0x10001
    8000533a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000533e:	4705                	li	a4,1
    80005340:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005342:	470d                	li	a4,3
    80005344:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005346:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005348:	c7ffe737          	lui	a4,0xc7ffe
    8000534c:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fddbf7>
    80005350:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005352:	2701                	sext.w	a4,a4
    80005354:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005356:	472d                	li	a4,11
    80005358:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    8000535a:	5bbc                	lw	a5,112(a5)
    8000535c:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005360:	8ba1                	andi	a5,a5,8
    80005362:	0e078763          	beqz	a5,80005450 <virtio_disk_init+0x17c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005366:	100017b7          	lui	a5,0x10001
    8000536a:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000536e:	43fc                	lw	a5,68(a5)
    80005370:	2781                	sext.w	a5,a5
    80005372:	0e079563          	bnez	a5,8000545c <virtio_disk_init+0x188>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005376:	100017b7          	lui	a5,0x10001
    8000537a:	5bdc                	lw	a5,52(a5)
    8000537c:	2781                	sext.w	a5,a5
  if(max == 0)
    8000537e:	0e078563          	beqz	a5,80005468 <virtio_disk_init+0x194>
  if(max < NUM)
    80005382:	471d                	li	a4,7
    80005384:	0ef77863          	bgeu	a4,a5,80005474 <virtio_disk_init+0x1a0>
  disk.desc = kalloc();
    80005388:	f14fb0ef          	jal	ra,80000a9c <kalloc>
    8000538c:	0001b497          	auipc	s1,0x1b
    80005390:	69c48493          	addi	s1,s1,1692 # 80020a28 <disk>
    80005394:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005396:	f06fb0ef          	jal	ra,80000a9c <kalloc>
    8000539a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000539c:	f00fb0ef          	jal	ra,80000a9c <kalloc>
    800053a0:	87aa                	mv	a5,a0
    800053a2:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800053a4:	6088                	ld	a0,0(s1)
    800053a6:	cd69                	beqz	a0,80005480 <virtio_disk_init+0x1ac>
    800053a8:	0001b717          	auipc	a4,0x1b
    800053ac:	68873703          	ld	a4,1672(a4) # 80020a30 <disk+0x8>
    800053b0:	cb61                	beqz	a4,80005480 <virtio_disk_init+0x1ac>
    800053b2:	c7f9                	beqz	a5,80005480 <virtio_disk_init+0x1ac>
  memset(disk.desc, 0, PGSIZE);
    800053b4:	6605                	lui	a2,0x1
    800053b6:	4581                	li	a1,0
    800053b8:	889fb0ef          	jal	ra,80000c40 <memset>
  memset(disk.avail, 0, PGSIZE);
    800053bc:	0001b497          	auipc	s1,0x1b
    800053c0:	66c48493          	addi	s1,s1,1644 # 80020a28 <disk>
    800053c4:	6605                	lui	a2,0x1
    800053c6:	4581                	li	a1,0
    800053c8:	6488                	ld	a0,8(s1)
    800053ca:	877fb0ef          	jal	ra,80000c40 <memset>
  memset(disk.used, 0, PGSIZE);
    800053ce:	6605                	lui	a2,0x1
    800053d0:	4581                	li	a1,0
    800053d2:	6888                	ld	a0,16(s1)
    800053d4:	86dfb0ef          	jal	ra,80000c40 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800053d8:	100017b7          	lui	a5,0x10001
    800053dc:	4721                	li	a4,8
    800053de:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800053e0:	4098                	lw	a4,0(s1)
    800053e2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800053e6:	40d8                	lw	a4,4(s1)
    800053e8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800053ec:	6498                	ld	a4,8(s1)
    800053ee:	0007069b          	sext.w	a3,a4
    800053f2:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800053f6:	9701                	srai	a4,a4,0x20
    800053f8:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800053fc:	6898                	ld	a4,16(s1)
    800053fe:	0007069b          	sext.w	a3,a4
    80005402:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005406:	9701                	srai	a4,a4,0x20
    80005408:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000540c:	4705                	li	a4,1
    8000540e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005410:	00e48c23          	sb	a4,24(s1)
    80005414:	00e48ca3          	sb	a4,25(s1)
    80005418:	00e48d23          	sb	a4,26(s1)
    8000541c:	00e48da3          	sb	a4,27(s1)
    80005420:	00e48e23          	sb	a4,28(s1)
    80005424:	00e48ea3          	sb	a4,29(s1)
    80005428:	00e48f23          	sb	a4,30(s1)
    8000542c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005430:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005434:	0727a823          	sw	s2,112(a5)
}
    80005438:	60e2                	ld	ra,24(sp)
    8000543a:	6442                	ld	s0,16(sp)
    8000543c:	64a2                	ld	s1,8(sp)
    8000543e:	6902                	ld	s2,0(sp)
    80005440:	6105                	addi	sp,sp,32
    80005442:	8082                	ret
    panic("could not find virtio disk");
    80005444:	00002517          	auipc	a0,0x2
    80005448:	30c50513          	addi	a0,a0,780 # 80007750 <syscalls+0x360>
    8000544c:	b3efb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk FEATURES_OK unset");
    80005450:	00002517          	auipc	a0,0x2
    80005454:	32050513          	addi	a0,a0,800 # 80007770 <syscalls+0x380>
    80005458:	b32fb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk should not be ready");
    8000545c:	00002517          	auipc	a0,0x2
    80005460:	33450513          	addi	a0,a0,820 # 80007790 <syscalls+0x3a0>
    80005464:	b26fb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk has no queue 0");
    80005468:	00002517          	auipc	a0,0x2
    8000546c:	34850513          	addi	a0,a0,840 # 800077b0 <syscalls+0x3c0>
    80005470:	b1afb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk max queue too short");
    80005474:	00002517          	auipc	a0,0x2
    80005478:	35c50513          	addi	a0,a0,860 # 800077d0 <syscalls+0x3e0>
    8000547c:	b0efb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk kalloc");
    80005480:	00002517          	auipc	a0,0x2
    80005484:	37050513          	addi	a0,a0,880 # 800077f0 <syscalls+0x400>
    80005488:	b02fb0ef          	jal	ra,8000078a <panic>

000000008000548c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000548c:	7119                	addi	sp,sp,-128
    8000548e:	fc86                	sd	ra,120(sp)
    80005490:	f8a2                	sd	s0,112(sp)
    80005492:	f4a6                	sd	s1,104(sp)
    80005494:	f0ca                	sd	s2,96(sp)
    80005496:	ecce                	sd	s3,88(sp)
    80005498:	e8d2                	sd	s4,80(sp)
    8000549a:	e4d6                	sd	s5,72(sp)
    8000549c:	e0da                	sd	s6,64(sp)
    8000549e:	fc5e                	sd	s7,56(sp)
    800054a0:	f862                	sd	s8,48(sp)
    800054a2:	f466                	sd	s9,40(sp)
    800054a4:	f06a                	sd	s10,32(sp)
    800054a6:	ec6e                	sd	s11,24(sp)
    800054a8:	0100                	addi	s0,sp,128
    800054aa:	8aaa                	mv	s5,a0
    800054ac:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800054ae:	00c52d03          	lw	s10,12(a0)
    800054b2:	001d1d1b          	slliw	s10,s10,0x1
    800054b6:	1d02                	slli	s10,s10,0x20
    800054b8:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800054bc:	0001b517          	auipc	a0,0x1b
    800054c0:	69450513          	addi	a0,a0,1684 # 80020b50 <disk+0x128>
    800054c4:	ea8fb0ef          	jal	ra,80000b6c <acquire>
  for(int i = 0; i < 3; i++){
    800054c8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800054ca:	44a1                	li	s1,8
      disk.free[i] = 0;
    800054cc:	0001bb97          	auipc	s7,0x1b
    800054d0:	55cb8b93          	addi	s7,s7,1372 # 80020a28 <disk>
  for(int i = 0; i < 3; i++){
    800054d4:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800054d6:	0001bc97          	auipc	s9,0x1b
    800054da:	67ac8c93          	addi	s9,s9,1658 # 80020b50 <disk+0x128>
    800054de:	a8a9                	j	80005538 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800054e0:	00fb8733          	add	a4,s7,a5
    800054e4:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800054e8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800054ea:	0207c563          	bltz	a5,80005514 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800054ee:	2905                	addiw	s2,s2,1
    800054f0:	0611                	addi	a2,a2,4
    800054f2:	05690863          	beq	s2,s6,80005542 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    800054f6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800054f8:	0001b717          	auipc	a4,0x1b
    800054fc:	53070713          	addi	a4,a4,1328 # 80020a28 <disk>
    80005500:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005502:	01874683          	lbu	a3,24(a4)
    80005506:	fee9                	bnez	a3,800054e0 <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80005508:	2785                	addiw	a5,a5,1
    8000550a:	0705                	addi	a4,a4,1
    8000550c:	fe979be3          	bne	a5,s1,80005502 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005510:	57fd                	li	a5,-1
    80005512:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005514:	01205b63          	blez	s2,8000552a <virtio_disk_rw+0x9e>
    80005518:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    8000551a:	000a2503          	lw	a0,0(s4)
    8000551e:	d41ff0ef          	jal	ra,8000525e <free_desc>
      for(int j = 0; j < i; j++)
    80005522:	2d85                	addiw	s11,s11,1
    80005524:	0a11                	addi	s4,s4,4
    80005526:	ffb91ae3          	bne	s2,s11,8000551a <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000552a:	85e6                	mv	a1,s9
    8000552c:	0001b517          	auipc	a0,0x1b
    80005530:	51450513          	addi	a0,a0,1300 # 80020a40 <disk+0x18>
    80005534:	8c7fc0ef          	jal	ra,80001dfa <sleep>
  for(int i = 0; i < 3; i++){
    80005538:	f8040a13          	addi	s4,s0,-128
{
    8000553c:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    8000553e:	894e                	mv	s2,s3
    80005540:	bf5d                	j	800054f6 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005542:	f8042583          	lw	a1,-128(s0)
    80005546:	00a58793          	addi	a5,a1,10
    8000554a:	0792                	slli	a5,a5,0x4

  if(write)
    8000554c:	0001b617          	auipc	a2,0x1b
    80005550:	4dc60613          	addi	a2,a2,1244 # 80020a28 <disk>
    80005554:	00f60733          	add	a4,a2,a5
    80005558:	018036b3          	snez	a3,s8
    8000555c:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000555e:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005562:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005566:	f6078693          	addi	a3,a5,-160
    8000556a:	6218                	ld	a4,0(a2)
    8000556c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000556e:	00878513          	addi	a0,a5,8
    80005572:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005574:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005576:	6208                	ld	a0,0(a2)
    80005578:	96aa                	add	a3,a3,a0
    8000557a:	4741                	li	a4,16
    8000557c:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000557e:	4705                	li	a4,1
    80005580:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80005584:	f8442703          	lw	a4,-124(s0)
    80005588:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000558c:	0712                	slli	a4,a4,0x4
    8000558e:	953a                	add	a0,a0,a4
    80005590:	058a8693          	addi	a3,s5,88
    80005594:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    80005596:	6208                	ld	a0,0(a2)
    80005598:	972a                	add	a4,a4,a0
    8000559a:	40000693          	li	a3,1024
    8000559e:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800055a0:	001c3c13          	seqz	s8,s8
    800055a4:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800055a6:	001c6c13          	ori	s8,s8,1
    800055aa:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800055ae:	f8842603          	lw	a2,-120(s0)
    800055b2:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800055b6:	0001b697          	auipc	a3,0x1b
    800055ba:	47268693          	addi	a3,a3,1138 # 80020a28 <disk>
    800055be:	00258713          	addi	a4,a1,2
    800055c2:	0712                	slli	a4,a4,0x4
    800055c4:	9736                	add	a4,a4,a3
    800055c6:	587d                	li	a6,-1
    800055c8:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800055cc:	0612                	slli	a2,a2,0x4
    800055ce:	9532                	add	a0,a0,a2
    800055d0:	f9078793          	addi	a5,a5,-112
    800055d4:	97b6                	add	a5,a5,a3
    800055d6:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    800055d8:	629c                	ld	a5,0(a3)
    800055da:	97b2                	add	a5,a5,a2
    800055dc:	4605                	li	a2,1
    800055de:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800055e0:	4509                	li	a0,2
    800055e2:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    800055e6:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800055ea:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800055ee:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800055f2:	6698                	ld	a4,8(a3)
    800055f4:	00275783          	lhu	a5,2(a4)
    800055f8:	8b9d                	andi	a5,a5,7
    800055fa:	0786                	slli	a5,a5,0x1
    800055fc:	97ba                	add	a5,a5,a4
    800055fe:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80005602:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005606:	6698                	ld	a4,8(a3)
    80005608:	00275783          	lhu	a5,2(a4)
    8000560c:	2785                	addiw	a5,a5,1
    8000560e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005612:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005616:	100017b7          	lui	a5,0x10001
    8000561a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000561e:	004aa783          	lw	a5,4(s5)
    80005622:	00c79f63          	bne	a5,a2,80005640 <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    80005626:	0001b917          	auipc	s2,0x1b
    8000562a:	52a90913          	addi	s2,s2,1322 # 80020b50 <disk+0x128>
  while(b->disk == 1) {
    8000562e:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80005630:	85ca                	mv	a1,s2
    80005632:	8556                	mv	a0,s5
    80005634:	fc6fc0ef          	jal	ra,80001dfa <sleep>
  while(b->disk == 1) {
    80005638:	004aa783          	lw	a5,4(s5)
    8000563c:	fe978ae3          	beq	a5,s1,80005630 <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    80005640:	f8042903          	lw	s2,-128(s0)
    80005644:	00290793          	addi	a5,s2,2
    80005648:	00479713          	slli	a4,a5,0x4
    8000564c:	0001b797          	auipc	a5,0x1b
    80005650:	3dc78793          	addi	a5,a5,988 # 80020a28 <disk>
    80005654:	97ba                	add	a5,a5,a4
    80005656:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000565a:	0001b997          	auipc	s3,0x1b
    8000565e:	3ce98993          	addi	s3,s3,974 # 80020a28 <disk>
    80005662:	00491713          	slli	a4,s2,0x4
    80005666:	0009b783          	ld	a5,0(s3)
    8000566a:	97ba                	add	a5,a5,a4
    8000566c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005670:	854a                	mv	a0,s2
    80005672:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005676:	be9ff0ef          	jal	ra,8000525e <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000567a:	8885                	andi	s1,s1,1
    8000567c:	f0fd                	bnez	s1,80005662 <virtio_disk_rw+0x1d6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000567e:	0001b517          	auipc	a0,0x1b
    80005682:	4d250513          	addi	a0,a0,1234 # 80020b50 <disk+0x128>
    80005686:	d7efb0ef          	jal	ra,80000c04 <release>
}
    8000568a:	70e6                	ld	ra,120(sp)
    8000568c:	7446                	ld	s0,112(sp)
    8000568e:	74a6                	ld	s1,104(sp)
    80005690:	7906                	ld	s2,96(sp)
    80005692:	69e6                	ld	s3,88(sp)
    80005694:	6a46                	ld	s4,80(sp)
    80005696:	6aa6                	ld	s5,72(sp)
    80005698:	6b06                	ld	s6,64(sp)
    8000569a:	7be2                	ld	s7,56(sp)
    8000569c:	7c42                	ld	s8,48(sp)
    8000569e:	7ca2                	ld	s9,40(sp)
    800056a0:	7d02                	ld	s10,32(sp)
    800056a2:	6de2                	ld	s11,24(sp)
    800056a4:	6109                	addi	sp,sp,128
    800056a6:	8082                	ret

00000000800056a8 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800056a8:	1101                	addi	sp,sp,-32
    800056aa:	ec06                	sd	ra,24(sp)
    800056ac:	e822                	sd	s0,16(sp)
    800056ae:	e426                	sd	s1,8(sp)
    800056b0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800056b2:	0001b497          	auipc	s1,0x1b
    800056b6:	37648493          	addi	s1,s1,886 # 80020a28 <disk>
    800056ba:	0001b517          	auipc	a0,0x1b
    800056be:	49650513          	addi	a0,a0,1174 # 80020b50 <disk+0x128>
    800056c2:	caafb0ef          	jal	ra,80000b6c <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800056c6:	10001737          	lui	a4,0x10001
    800056ca:	533c                	lw	a5,96(a4)
    800056cc:	8b8d                	andi	a5,a5,3
    800056ce:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800056d0:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800056d4:	689c                	ld	a5,16(s1)
    800056d6:	0204d703          	lhu	a4,32(s1)
    800056da:	0027d783          	lhu	a5,2(a5)
    800056de:	04f70663          	beq	a4,a5,8000572a <virtio_disk_intr+0x82>
    __sync_synchronize();
    800056e2:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800056e6:	6898                	ld	a4,16(s1)
    800056e8:	0204d783          	lhu	a5,32(s1)
    800056ec:	8b9d                	andi	a5,a5,7
    800056ee:	078e                	slli	a5,a5,0x3
    800056f0:	97ba                	add	a5,a5,a4
    800056f2:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800056f4:	00278713          	addi	a4,a5,2
    800056f8:	0712                	slli	a4,a4,0x4
    800056fa:	9726                	add	a4,a4,s1
    800056fc:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005700:	e321                	bnez	a4,80005740 <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005702:	0789                	addi	a5,a5,2
    80005704:	0792                	slli	a5,a5,0x4
    80005706:	97a6                	add	a5,a5,s1
    80005708:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000570a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000570e:	f38fc0ef          	jal	ra,80001e46 <wakeup>

    disk.used_idx += 1;
    80005712:	0204d783          	lhu	a5,32(s1)
    80005716:	2785                	addiw	a5,a5,1
    80005718:	17c2                	slli	a5,a5,0x30
    8000571a:	93c1                	srli	a5,a5,0x30
    8000571c:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005720:	6898                	ld	a4,16(s1)
    80005722:	00275703          	lhu	a4,2(a4)
    80005726:	faf71ee3          	bne	a4,a5,800056e2 <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    8000572a:	0001b517          	auipc	a0,0x1b
    8000572e:	42650513          	addi	a0,a0,1062 # 80020b50 <disk+0x128>
    80005732:	cd2fb0ef          	jal	ra,80000c04 <release>
}
    80005736:	60e2                	ld	ra,24(sp)
    80005738:	6442                	ld	s0,16(sp)
    8000573a:	64a2                	ld	s1,8(sp)
    8000573c:	6105                	addi	sp,sp,32
    8000573e:	8082                	ret
      panic("virtio_disk_intr status");
    80005740:	00002517          	auipc	a0,0x2
    80005744:	0c850513          	addi	a0,a0,200 # 80007808 <syscalls+0x418>
    80005748:	842fb0ef          	jal	ra,8000078a <panic>
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
