# CSS422 Project
Title: A Disassembler for the Motorola MC68000 Microprocessor
1. Project Preface
    1) Project teams: This is a teamwork project. It is almost impossible to complete the entire project alone unless you are taking only this CSS422 section and can allocate 40+ hours for this project. Each team must consist of two students. Depending  on  the  class  size,  there  may  be  at  most  a  team  of  three  students.  However,  don't  start thinking  about  forming  a  team  of  three  from  the  beginning  of  your  work.  When  the  professor identifies the very last person who has a difficulty in finding her/his teammate, only one team of three students will be formed.You may dissolve your team while working on the project, however you are responsible to form a new team. No solo work allowed.
    2) Workload: Each student must contribute to the project in equal: 50% of the entire work in a two-student team or 33.3% of the work in a three-student team. You may partition the entire work into tasks,  each  with  the  same  work  amount  for  a  student,  or  completely  work  together  on  the  entire work, (i.e., in pair programming). The professor recommends the following work partition:
       a. Two-student team:
          i.    User interface and op code decoding 
          ii.    Effective address calculation
       b. Three-student team:
          i.    User interface and portion of effective address calculation
          ii.   Op code decoding
          iii.  The rest of effective address calculation
    3) Grading:  Your  work  will  be  graded  both  in  team  and  individually.  The  teamwork  grading  is based on the final deliverables including the source code and documentation, while each student's performance  is  graded  from  weekly  reports,  your  role  in  the  final  project  demo,  and  confidential peer evaluations.
    4) Cheating:  As  this  project  has  been  given  through  all  sections  over  years,  you  may  have  friends who have taken this course or may still have a copy of their project. Copying the project or part of the project from a former student or her/his GitHub is plagiarism and is NOT tolerated at all. Your project  will  be  compared  to  the  CSS422  instructors'  shared  database  of  former  projects.  Any plagiarism  is  reported  to  Office  of  Academic  Affair  and  filed  for  the  next  5  years,  in  which  case the cheating student wouldn't get a job that needs security clearance.
    5) Testing: The correctness of your program is tested through the following two steps:
        a. Assembling  Your  Program:  Assemble  your  program  with  Easy68K  and  load  it  in memory starting at $1000.
        b. Testing Your UI Part: Run your program and type various keyboard inputs to verify the correct execution of your UI implementation.
        c. Testing  Your  OpCode  and  EA  Analyzing  Part:  Load  test  programs  somewhere  in memory,  run  your  program,  give  correct  keyboard  inputs,  (i.e.,  a  correct  starting  and ending addresses of the test programs), and compare your execution and the source of the test programs.
3. Project Specification
   1) Write  an  inverse  assembler  (disassembler)  that  will  convert  a  memory  image  of  instructions  and data  back  to  the  MC68000  assembly  code  and  that  will  output  the  disassembled  code  to  the display. You will not be required to disassemble all of the instructions and addressing modes. The list of instructions and addressing modes is given below in item 12).
   2) If you want to see how a disassembler works, just take one of your homework problems and load it in memory at an address after your program. Then open a memory window and see the code in memory. You can also view it as disassembled code in the simulator.
   3) DO  NOT  USE  THE  TRAP  FUNCTION  60  FACILITY  OF  THE  SIMULATOR. You  must completely  develop  your  own  disassembler  algorithm.  If  the  professor  suspects  that  you  used TRAP  function  60,  he  will  use  a  search  tool  that  was  designed  to  scan  your  source  code  for  the TRAP function 60 calls. You can only use the simulator's text I/O function, Trap Function 15, and you can only use tasks with ID 0 to 14 of Trap Function 15. Task 15 and higher of Trap Function 15     cannot     be     used. Please see the available tasks of Trap Function 15: http://www.easy68k.com/QuickStart/TrapTasks.htm (Links to an external site.)
   4) Your program should be written from the start in the MC68000 assembly language while you may design  your  implementation  using  flow  charts,  block  diagrams,  and/or  abstract  code  in  C/C++. However, do not write the project in C or C++ and then cross-compile it to the MC68000 machine code.  It  is  really  easy  to  tell  that  your  code  was  generated  from  a  cross-compiler.  Besides,  it  is hard to keep track of the compiler-generated code by yourself.
   5) Your program should be ORG'ed at $1000.
   6) At startup, the program should display whatever welcome messages you want to display and then prompt  the  user  for  the starting  location and  the  ending  location (in  hexadecimal  format)  of  the code  to  be  disassembled.  The  program  should  scan  the  memory  region  and  output  the  memory addresses of the instructions and the assembly language instructions contained in that region to the display. Ultimately, you should be able to actually disassemble your own program to the display. However, due to the time constraints, your project will disassemble only 18 op code instructions at minimum (see item 12 below). Don't embed some test code in your disassembler program.
   7) The  display  should  show  one  screen  of  data  at  a  time,  hitting  the ENTER key  should  display  the next screen of information.
   8) The  program  should  be  able  to  realize  when  it  has  an  illegal  instruction  (i.e,  data)  and  should  be able  to  deal  with  it.  The  ultimate  error  handling  should  keep  scanning  the  rest  of  the  memory region  until  it  can  find  instructions  again  to  decode,  and  should  display  the  data  unable  to  be decode as:1000    DATA    $WXYZwhere $WXYZ is the hexadecimal number that couldn't be decoded. However, the minimum requirement is to simply print out an error message such as:Unsupported op codeInvalid op codeWrong sizeWrong EA mode/registerAnd thereafter go back to restart your program from its UI to receive the information of a new memory region.Your program should not crash because it can't decode an instruction.
   9) Address  displacements  or  offsets  should  be  properly  displayed  as  the  address  of  the  branch  and display that value. For example:  1000          BRA    993         * Branch to address 993is better.You should do a line-by-line disassembly, displaying the following columns:a- Memory location            b- Op-code            c- Operand
   10) When  it  completes  the  disassembly,  the  program  should  prompt  the  user  to  disassemble  another memory image, or prompt the user to quit.
   11) Required  op  code  and  addressing  mode:  below  is  the  list  of  CPU  instructions  and  addressing modes assigned for this final project:
         Effective Addressing Modes:
         a) Data Register Direct (mode 0)
         b) Address Register Direct (mode 1)
         c) Address Register Indirect (mode 2)
         d) Address Register Indirect with Post Increment (mode 3)
         e) Address Register Indirect with Pre Decrement (mode 4)
         f) Absolute Word Address (mode 7 subclass 0)
         g) Absolute Long Address (mode 7 subclass 1)
         h) Immediate Data (mode 7 subclass 4)
    12) Instructions: The following 18 instructions are required to decode. The rest 25 instructions are optional for the purpose of giving you up to 10 extra credits.
 3. Project Progress ReportsThese reports intend to pace your project work and to examine the on-going project contribution of each student. Each report must follow the format specified below:1)    Title: Get started with the title "CSS422, Quarter 20XX" (such as CSS422, Winter 2020).2)    Report #: Distinguish weeks 1 - 4 (but not 5 unlike the other professor and sections). 3)    Names: List all team member names.4)    Meeting times and locations: Indicate when and where you had team meetings.5)    Progress: Summarize what work has been done during the reporting period for each person like:Student NamesProgressMini MouseImplemented ....Donald DuckDesigned ....6)    Plan: List up what each of you will have to do for the next reporting period like:Student NamesPlaned WorkMini MouseIs planning to work on ...Donald DuckIs planning to work on ...
4. DeliverablesAll students:1)    Peer evaluation: Submit an individual peer evaluation separately named "evaluation.pdf" or "evaluation.docx". If you do not submit a peer evaluation, you will receive an automatic 4 point deduction from your grade on the project. No exceptions!Group representatives:The representative of each group must submit the deliverables of the project work in one zipped file. These include the following three items.2)    Source code: Submit the source code named "disassembler.X68". No multiple source files, please to expedite the grading work.3)    Documentation: Submit the document named "finalreport.pdf" or "finalreport.docx". The document must include the following sections:Section 1. Specification: Write in 1 page about how to run your program and what it can do.Section 2. Implementation: Write in 1 page of your internal implementation.Section 3. Test Plans: Write in 1 page about how you tested your disassembler.Section 4. Challenges: Describe any problems you have encountered but could not fix (1 page).Section 5. Team Assignments: Clarify who did what and how (in 1 page).4)    Video clip: Submit a video clip that demonstrates your program execution. Please see the following instructions to create a video clip. Your video must be named “demo.mp4” or “demo.mov”.5)    Slides: Submit slides you used in your demo as “demo.ppt” or “demo.pptx”. Please see in instructions below on what slides you need to get prepared.5. Project DemoEach group will demonstrate how your program works. The demo will have up to 5 minutes to present your program, including time for setup, and wrap-up. Use the following testing file: test_disasm.X68 (which you can find in Canvas/files) to show your demo.In your presentation, get prepared for the following 3 slides to explain your disassembler implementation.Slide #Contents1Flow charts or block diagrams of your program2List of I/O, opcode and EAs that have been completed3List of challenges that you encountered, solved, and/or couldn't fix.Your video clip should be named “demo.mp4” or “demo.mov”.6. Grading RubricsGrading itemsPointsEvaluationUser Interface (I/O)10Grading as an entire teamworkOp Code24(extra +10)Grading as an entire teamworkProgramEffective Address38Grading as an entire teamworkFinal Report10Grading as an entire teamworkConfidential Individual Peer Evaluation4Checking individual contributionProject Demo10Checking individual contribution10: excellent, 9: good 8: fair, 7: poorProgress Reports (4 times)4Checking individual contribution1: excellent, 0.9: good 0.8: fair, 0.7 poorEach student's less contribution(-15)Checking individual contribution-5: relatively 10% less contribution-10: relatively 20% less contribution-15: relatively 30% or less contribution
7. Simulator IssuesThe  following  is  the  information  shared  among  all  the  CSS422  instructors,  regarding  the  Easy68K simulator:Simulator Issues:There may be some issues with using the Easy68K as the project's only simulator package that I'm not yet aware  of. In  general,  the  simulator  is  very  forgiving when  it comes  to  displaying  the disassembled lines of code on its terminal screen. However, what might look OK to you on the screen, may actually appear  as  one  long  line  of  text  in  the  log  file  because  you  neglected  to  add carriage  return  <CR>  and line feed <LF> characters to the end of your output lines. Every line that you send to the screen should be terminated with the ASCII codes for CR and LF.It  is  to  your  advantage  to  print  out  the  output  file.  Easy68K  has  a  logging  function  that  will  capture everything that was output to the display. If your print-out is messed up, mine will also be messed up.There should only be the printable ASCII character set, CR and LF in your I/O to the screen.There will be an automatic deduction of 10 points from your grade if I have to go into the log file and create a printable output file because you forgot to add the proper formatting control characters or you added non-printable characters, such as a beep, to your output. Easy68K bugs:It seems like Easy68k simulator program contains several bugs. Here are the list of Easy68k bugs which are  captured  by  students  who  have  taken  this  class  previously.  I  strongly  urge  you  to  read  this  first  so that you do not have to struggle with this bug when it comes to debugging your own program.1. A MOVE.L operation with direct data going into a data register with the direct data being less than 5 bits causes the EASY68k to perform a MOVEQ instead of a MOVE.L. 2. Similar bugs can be found with most commands which have a “Q” variant. The 68K assembler seems to automatically use the less memory and processor intensive version of the command when possible. I assume this is to maximize the system’s efficiency and speed.3. The Easy68k Manual shows that a MOVE operation with the destination being an address register is an  invalid  operation,  and  should  be  a  MOVEA  operation.  However,  the  Easy68k  compiler  gives  no warning   or   errors   when   trying   to   perform   a   MOVE   with   the   destination   being   an   address register.   Because  the  Easy68k  shows  that  this  kind  of  operation  is  invalid,  the  program  will  display  a MOVEA in place of the MOVE when displaying the data. 4. Our  inverse  assembler  will  start  to  act  irregularly  and  will  start  to  display  error  messages  for  valid op-code  data  if  a  large  amount  of  data/operations  are  sent  through  the  inverse  assembler.  We encountered this problem when trying our test routine that tested all possible combinations of valid data for op-codes. We first thought it was our inverse assembler that was causing the irregular performance, but if you repeatedly perform the same action/operation, such as NOP, through the Easy68k assembler for  countless  times  the  Easy68k  starts  to  act  irregular,  which  results  in  our  inverse  assembler  acting irregular  as  well.  The  test  routine  that  tested  all  possible  combinations  of  valid  data  was  around  5,500 lines of code.
8. Addendum1)    Project managementKeep in your mind the following suggestions:a)Test your program with not only test_disasm.X68 (which is provided through Canvas) but also with your own test programs to consider various conditions.b)    Practice good software engineering test methodologies. For example, regression testing is a great way to make sure that fixing one bug doesn't introduce another one.c)Keep good logs of the errors, how to reproduce them and who owns the repair.d)    Once you begin to build your program it is a good idea to build it in stages, rather than go for the whole enchilada in one shot.e)Don't underestimate the importance of keeping tack of what version you are working on.f)Don't underestimate the importance of team dynamics. The most common reason is that one or more of the team members fail to meet their commitments and the other team members are stuck. Other situations involve teams where there are clashes of wills and a failure to compromise. In any case, before you formally organize as a team, you should read the handout provided by Prof. Freytag (Canvas/files/materials/Team Handbook.pdf).2)    I/O and Utility functionsThe user interface would like to implement the following subroutines:ERROR_HANDLERWhenever  an  error  occurs,  jump  to  this  subroutine  and  print  out  the corresponding message to the monitor.ATOIConvert   an   ASCII   string   into   an   integer.   An   should   receive   the beginning  address  of  a  given  ASCII  string  and  Dn  should  maintain  the string  length.  Return  the  corresponding  int  value  in  another  Dn.  Return $FFFFFFFF (or -1) upon an error.ITOAConvert  an  integer  into  an  ASCII  string.  An  points  to  the  beginning address  of  where  the  ASCII  string  is  generated.  Dn  includes  a  value  to be  converted  into  ASCII.  Another  Dn  shows  the  data  size  to  convert: byte, word, or long word.The program structure will be:  USER_INPUT:  START_ADDR:            ; prompt a start address; read a start address; validate the start address END_ADDR:; prompt an end address; read an end address; validate the end address DECODE_LOOP:; decoding the current addressJSR     OP_START       ; call the op code decoding routine.MOVE.B  #task13, D0LEA     buffer, A1     ; this buffer includes "address op_code, op1, op2"TRAP    #15; checking if a decode finished ; cmp  start_address, end_addressBLE     REPEAT_OR_FINISH; checking if the screen filled. If notBRA     DECODE_LOOPREPEAT_OR_FINISH:; check if a user wants to disasemble another code. If soBRA     USER_INPUT 3)    Instruction printingGet prepared for a buffer to maintain a decoded instruction and its operands:bufsize EQU     64      ; 64 characters would be good enoughbuffer  DS.B    bufsize ; a line of decoded data to print to screenEach time you start decoding a new instruction, don't forget to clear this buffer:
OP_DATA_CLR:        CLR.L   D3        MOVE.B  #bufsize, D3        ; D3 = bufsize as a counter        LEA     buffer, An          ; for ( int D3 = 64; D3 > 0; D3--)OP_DATA_CLR_LOOP:        MOVE.B  #0, (An)+           ;   (An)++ = $0;        SUBI    #1, D3    BGT     OP_DATA_CLR_LOOPUse one of address registers to point to "buffer", so that you can add characters to this buffer.LEA     buffer, An     ; An points to buffer (zero cleared)This buffer should include:MemoryAddress Instruction  Op1, Op2MemoryAddress  can  be  calculated  from  how  many  words  the  previous  instruction  needed.  The address  must  be  printed  out  in  hexadecimal.  You  need  a  space  between  MemoryAddress  and Instruction. That corresponds to $9 in ASCII.MOVE.B  #$9, (An)+          ; address' 'Each time you decode a new instruction, add its mnemonic to buffer like:  OP_MOVEA:      MOVE.B  #'M', (An)+            MOVE.B  #'O', (An)+            MOVE.B  #'V', (An)+            MOVE.B  #'E', (An)+    MOVE.B  #'A', (An)+After decoding the instruction, add operands to buffer.Finally, you will print out buffer:            MOVE.B  #task13, D0         ; cout << buffer << endl;            LEA     buffer, A1    TRAP    #154)    Instruction decodingConsider  the  op-codes  for  most  instructions.  If  you  look  at  the  4  most  significant  bits,  (DB12-DB15) you can group them into 16 categories. Consider the following table:Bits 15 through 12Operation0000Bit manipulation/MOVEP/Immediate0001Move Byte0010Move Long0011Move Word0100Miscellaneous0101ADDQ/SUBQ/Scc/DBcc0110BSR,BRA,Bcc0111MOVEQ1000OR/DIV/SBCD1001SUB/SUBX1010Unassigned1011CMP/EOR1100AND/MUL/ABCD/EXG1101ADD/ADDA/ADDX1110Shift/Rotate1111Special/ReservedSuppose we read an op code, 0100XXXXXXXXXXXX, where X can be anything. The first task is  to  isolate  the  pattern  0100  as  the  rightmost  bits  in  a  register  with  all  zeroes  in  every  other  bit 
position. The reason is that we can make use of one of the addressing modes of the 68K, address register indirect with index and displacement. Here is an example program:****************************************** Example of using a jump table to decode an instruction***************************************** System equatesstack            EQU      $A000example          EQU      %0100001000000001    ; An instruction (CLR.B D0)     shift            EQU     12                    ; Shift 12 bits * Program starts here                 ORG     $400OP_START         LEA     stack, SP             ; Load the SP                 LEA     jmp_table,A0          ; Index into the table                 CLR.L   D0                    ; Zero it                 MOVE.W  #example,D0           ; We'll play with it here                 MOVE.B  #shift,D1             ; Shift 12 bits to the right                   LSR.W   D1,D0                 ; Move the bits* Consider the next instruction. Why do we have to multiply the index * by 6? How many bytes does a single jump table entry require?                MULU        #6,D0               ; Form offset                    JSR          0(A0,D0)           ; Jump indirect with indexjmp_table      JMP         code0000               JMP         code0001               JMP         code0010               JMP         code0011               JMP         code0100               JMP         code0101               JMP         code0110               JMP         code0111               JMP         code1000               JMP         code1001               JMP         code1010               JMP         code1011               JMP         code1100               JMP         code1101               JMP         code1110               JMP         code1111* The following subroutines will get filled in as you decode the instructions.* For now, just exit gracefully.code0000       STOP        #$2700code0001       STOP        #$2700code0010       STOP        #$2700code0011       STOP        #$2700* Now we enter the next level of decoding. code0100       BRA        code0100code0101       STOP        #$2700code0110       STOP        #$2700code0111       STOP        #$2700code1000       STOP        #$2700code1001       STOP        #$2700code1010       STOP        #$2700  code1100       STOP        #$2700code1101       STOP        #$2700code1110       STOP        #$2700code1111       STOP        #$2700               END   $400 So  we  can  index  to  a  subroutine  through  the  jump  table.  Jumping  to  code0100,  we  have  many instructions  starting  with  0100:  MOVE  from  SR,  MOVE  to  CCR,  MOVE  to  SR,  NEGX,  CLR, 
NEG,  NOT,  EXT,  NBCD,  SWAP,  PEA,  ILLEGAL,  TAS,  TST,  TRAP,  LINK,  UNLK,  MOVE USP, RESET, NOP, STOP, RTE, RTS, TRAPV, RTR, JSR, JMP, MOVEM, LEA, and CHEK.Among them, let us focus on only CLR, NOT, EXT, TRAP, NOP, STOP, RTE, RTS, JSR, JMP, MOVEM, and LEA. Similar to the above jump table, we can create another table to index to each instruction.  code0100:                       MOVE.W  #example,D0     ANDI.W  #%0000111100000000, D0                      MOVE.B  #8, D1                      LSR.W   D1, D0        ; extract the 2nd nibble in D0                      MULU    #6, D0        ; compute the op_0100_table jump displacement                      LEA     op_0100_table, A0                      JMP     0(A0, D0)         ; jump to op_0100_table entry  op_0100_table:                      JMP     OP_UNSUPPORTED    ; 0: MOVE from SR not supported                      JMP     OP_LEA            ; 1: LEA An 1                      JMP     OP_CLR            ; 2: CLR                      JMP     OP_LEA            ; 3: LEA An 1                      JMP     OP_UNSUPPORTED    ; 4: MOVE from CCR not supported                      JMP     OP_LEA            ; 5: LEA An 1                      JMP     OP_NOT            ; 6: NOT                      JMP     OP_LEA            ; 7: LEA An 1                      JMP     OP_EXT_MOVEM      ; 8: EXT, MOVEM                      JMP     OP_LEA            ; 9: LEA An 1                      JMP     OP_UNSUPPORTED    ; A: ILLEGAL, TAS, TST not supported                      JMP     OP_LEA            ; B: LEA An 1                      JMP     OP_MOVEM          ; C: MOVEM                      JMP     OP_LEA            ; D: LEA An 1                      JMP     OP_JNRST          ; E: JMP, JSR, NOP, RTE, RTS, STOP, TRAP,                      JMP     OP_LEA            ; F: LEA An 1Then, we can jump to OP_CLR.  OP_CLR:MOVE.B  #'C', (An)+MOVE.B  #'L', (An)+                       MOVE.B  #'R', (An)+5)    Effective address calculationThe 16-bit op-code provides all that you need to know about decoding an instruction. It may have no operand, one operand, two operands, or immediate data as the first operand. This in turn means that  the  op-code  decoding  routine  must  instruct  the  effective  address  calculation  on  how  to calculate the effective address(es). The professor's suggestion is:The  op  code  decoder  specifies  which  EA  calculation  should  be  done.  For  instance,  Decoding ADDI can say to the EA calculator like:  OP_ADDI:            MOVE.B  #'A', (An)+            MOVE.B  #'D', (An)+            MOVE.B  #'D', (An)+            MOVE.B  #'I', (An)+            MOVE.L  #ea_type_immediate, D1     ; D1 distinguishes EA calculation.            JSR     EA_START                   ; call the EA calculation routine    JMP     OP_FINISHAnother example is decoding MOVE:   OP_MOVE:            MOVE.B  #'M', (An)+            MOVE.B  #'O', (An)+            MOVE.B  #'V', (An)+            MOVE.B  #'E', (An)+            MOVE.L  #ea_type_move, D1          ; D1 distinguishes EA calculation.            JSR     EA_START                   ; call the EA calculation routine    JMP     OP_FINISHImplement a jump table of different EA calculations
  EA_START:            LEA     EA_TYPE_TABLE, A0            MULU    #6, D1            JMP     0(A0, D1)           ; jump to each EA handling table entry  EA_FINISH:            ...            RTS  EA_TYPE_TABLE:            JMP     EA_IMMEDIATE        ; 0: ea_immediate            JMP     EA_MOVE             ; 1: ea_move            JMP     EA_LEA              ; 2: ea_lea            JMP     EA_DSTONLY          ; 3: ea_dstonly            JMP     EA_EXT              ; 4: ea_ext            JMP     EA_TRAP             ; 5: ea_trap            JMP     EA_QUICK            ; 6: ea_quick            JMP     EA_BRANCH           ; 7: ea_branch      ...            JMP     EA_FINISHThe person who takes charge of EA calculation must then implement each EA_XXXX routine.6)    Project referencesa)68K Instruction quick reference: http://www.easy68k.comb)    68K Opcodes cheat sheet: http://goldencrystal.free.fr/M68kOpcodes-v2.3.pdf (Links to an external site.)c)68K Tutorial: http://mrjester.hapisan.com/04_MC68/ (Links to an external site.)d)    68000 Assembler by Paul McKee: http://neo.dmcs.pl/pn/asembler_68000/asm.html (Links to an external site.)e)Test code example (very simplified version): Canvas/files/68K/test.X68f)Main program example (see how to include subroutine files): main.x68, strings.x68g)    Subroutine example: Canvas/files/68K/subroutine.x68h)    Branch example: Canvas/files/68K/Branch.X68i)Memory test example: Canvas/files/68K/memorytest.X68j)Absolute addressing example: Canvas/files/68K/AbsoluteAddressing.X68k)    Examples about "for loop" can be found from Canvas/files/68K/Summary 68KInstructionSet.pdf
