// Structured Text usually in PRG file
// HDR - Header file probably contains info about plc and program
// MNT - ??
// NAM - Probably contains map from address to name
// PRG - program file loads into plc or is file that is compiled or translated before loading into plc
// PRM - See above
// PRT - printable file containing rungs and comments

// VARs (STAT for static)
// INPUT %I* , OUTPUT %Q* , IN_OUT ? , IN_OUT_CONSTANT ?
// GLOBAL ? , TEMP ? , STAT ? , EXTERNAL ? , INST ? ,
// CONST ? , GENERIC CONSTANT ?
// PERSISTENT ? , RETAIN ?
// persistent data on power loss (+ function symbols)

// https://infosys.beckhoff.com/english.php?content=../content/1033/tcplclib_tc2_system/3622991755.html&id=
// https://infosys.beckhoff.com/english.php?content=../content/1033/tc3_plc_intro/2525041803.html&id=
// c:\TwinCAT\AdsApi\TcAdsDll\Include\TcAdsDef.h

// TwinCAT IO system Windows Kernel process needs >5 seconds to restart
// Master Devices need even longer

PROGRAM MAIN
VAR
  u32Counter0 AT %I*: UDINT;
  bIn0 AT %I*: BOOL;

  // timeout value of counter
  u64TimeoutWatchdog: ULINT := 1000000;
  u64TimestampWatchdog: ULINT := 0;

  u64TmpTimestamp: ULINT;

  u64Timestamp AT %Q*: ULINT;
  bResetWatchdog AT %Q*: BOOL;
  bOut0 AT %Q*: BOOL;
END_VAR

// A value is assigned to an input variable with :=
// A value is assigned to an output variable with =>

//         fbSampleA
//     -----------------
//  -->|nVar1     nOut1|-->
//     -----------------
fbSampleA.nVar1 := 33; // FB_SampleA is called and the value 33 is assigned to the variable nVar1
fbSampleA(); //  FB_SampleA is called, that's necessary for the following access to the output variable
nRes := fbSampleA.nOut1 // the output variable nOut1 of the FB1 is read

// output only block f_GetSystemTime should be always available

//      F_GetSystemTime
//     -----------------
//     |F_GetSystemTime|-->
//     -----------------
u64TmpTimestamp := Tc2_System.F_GetSystemTime;
u64Timestamp := u64TmpTimestamp;


IF bResetWatchdog THEN
  bResetWatchdog := false;
  u64TimestampWatchdog := u64TmpTimestamp;
END_IF
IF u64TmpTimestamp - u64TimestampWatchdog < u64TimeoutWatchdog THEN
  // timeout action
END_IF

// Live variable view:
// * Online view of the programming editor of an object: "inline monitoring"
// * Online view of the declaration editor of an object
// * Object-independent configurable watch lists
// PLC -> CX7000PLC -> CX7000PL Project -> POUs -> MAIN (PRG)

// https://infosys.beckhoff.com/english.php?content=../content/1033/tf5200_programming_manual/208400267.html&id=6992011668082302531
// idea macros
