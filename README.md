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
2. Project Specification
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
    12) Instructions: The following 18 instructions are required to decode:
          ORI, MOVEA, MOVE, NOP, MOVEM, LEA, ADDQ, BRA, BSR, MOVEQ, DIVU, SUB, CMP, MULU, ADD, ADDA, ASL, ASR
          The rest 25 instructions are optional for the purpose of giving you up to 10 extra credits:
          ANDI, SUBI, ADDI, EORI, CMPI, CLR, NOT, EXT, TRAP, STOP, RTE, RTS, JSR, JMP, SUBQ, BEQ, DIVS, OR, EOR, MULS, AND, LSL, LSR, ROL, ROR
 3. Project Progress Reports
     These reports intend to pace your project work and to examine the on-going project contribution of each student. Each report must follow the format specified below:
     1) Title: Get started with the title "CSS422, Quarter 20XX" (such as CSS422, Winter 2020).
     2) Report #: Distinguish weeks 1 - 4 (but not 5 unlike the other professor and sections). 
     3) Names: List all team member names.
     4) Meeting times and locations: Indicate when and where you had team meetings.
     5) Progress: Summarize what work has been done during the reporting period for each person.
     6) Plan: List up what each of you will have to do for the next reporting period.
4. Deliverables
   All students:
      1) Peer evaluation: Submit an individual peer evaluation separately named "evaluation.pdf" or "evaluation.docx". If you do not submit a peer evaluation, you will receive an automatic 4 point deduction from your grade on the project. No exceptions! Group representatives: The representative of each group must submit the deliverables of the project work in one zipped file. These include the following three items.
      2) Source code: Submit the source code named "disassembler.X68". No multiple source files, please to expedite the grading work.
      3) Documentation: Submit the document named "finalreport.pdf" or "finalreport.docx". The document must include the following sections: Section 1. Specification: Write in 1 page about how to run your program and what it can do. Section 2. Implementation: Write in 1 page of your internal implementation. Section 3. Test Plans: Write in 1 page about how you tested your disassembler. Section 4. Challenges: Describe any problems you have encountered but could not fix (1 page). Section 5. Team Assignments: Clarify who did what and how (in 1 page).
      4) Video clip: Submit a video clip that demonstrates your program execution. Please see the following instructions to create a video clip. Your video must be named “demo.mp4” or “demo.mov”.
      5) Slides: Submit slides you used in your demo as “demo.ppt” or “demo.pptx”. Please see in instructions below on what slides you need to get prepared.
