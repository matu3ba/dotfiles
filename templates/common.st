//====general
//====reference_manual
//====SHENNANIGAN
//====conventions
//====common

//====general
// https://infosys.beckhoff.com/english.php?content=../content/1033/tc3_userinterface/18014403202147467.html&id=
// use Separate LineIDs = TRUE

//====reference_manual
// SHENNANIGAN Beckhoff does not specify accessor specifier behavior of interfaces ANY_INT

// Function blocks (fb, Object Function block)
// * output and internal vars retained
// * fb is always called via an instance, which is a copy of the function block
// * access via fb_instance.var
//   - from outside fb instance access only to input and output vars of fb
//   (not to internal vars)
//	 - access to fb instance limited to POU instance where declared unless global
//	 - assign to fb vars (input, output) possible when calling the instance
// => access to non-input/output vars only via calling methods doing the work
// => property has get/set methods for This
// => unclear rules for references and pointers to vars, i guess identical
// or forbidden to hold for inputs and output vars?
// Methods (me, Method object)
// * me can access all vars of associated fb inst
// * all data of method temporary (stack vars) unless VAR_INST
// * VAR_INST for permanent only used in me var
// Properties (prop, Property object)
// * access specifiers PUBLIC, PRIVATE, PROTECTED, INTERNAL, FINAL, ABSTRACT
// Interfaces (itf, Object Interface, Implementation of an interface)
// * prefer composition over inheritance
// * drawback is possible boiler code from unused methods forced onto fb when
// using itf
TOOD: better summarize below
----
1. checking interface decls in compiler
* methods and properties associated with interface
* fbs corresponding to interface: make corresponding methods and properties available -> implement interface I_Sample
-> fb contains interface in the implements list
-> fb can implement one or more interfaces
* fb implementing interface must contain all methods and properties of interface; decl of methods+properties must
match decl in interface exactly
* fbs add fb-specific code to interface methods and properties. if interface implemented by several fbs,
you can use tzhe same method with params but different impl code in different fbs
* fbs implementing 1 or more interface, compiler checks fbs to meet interface decls. if element decls
in interface and fb differ, or if interface contains further els not included in fb, compiler reports error
2. calling methods and properties of fb instance via interface variable
* can use interfaces to call interface method or property of fb instance via interface var
* instantiate interface itfSample : ITF_sample and fbs implementing interface correctly
* assign interface variable to each instance of fb implementing interface correctly. if interface var
has not yet been assigned, var contains value 0 in online mode
* such impl enables use of different, but similar fbs via interface var in consistent manner. depending
on project state you can assign particular fb instance to interface var, for example, so
that call of interface methods and properties is identical, although a different fb instance is used,
depending on project state.
Interface type var is a ref to instance of fbs. TC always treats vars, defined as interfaces, as references.
__ISVALIDREF only possible for operands of type REFERENCE TO, not interface vars.
ATTENTION: In C++ can not be 0, but in Beckhoff for interfaces they can be like C function ptr.
Checking interface variable being assigned by fb instance, you can check the interface var <> 0
Declaring variables within an interface is not possible, interfaces have no part and no actions.
Only collections of properties and methods are defined.
----
// Inheritance (fbs using extends of fbs)
// * extends/inherits properties and functionalities of basic fb
// * methods with same name must match access specifier, return type, var itf
// * obtains properties and methods in addition to own ones, but NOT vars
// Inheritance (sts, structs using extends of structs)
// * st extends 1 other st, so that st obtains vars of basic st + it own vars
// Extending interfaces
// * interface can obtain interface methods and properties of basic interface in
// addition to own ones (INTERFACE I_Sub EXTENDS I_Base1, I_Base2)
// Method call
// * pFB^.SampleMethod(..) => pFB can point to inst of type of fb xor inst of derived fbs
// unless invalid ptr
// * iSample.SampleMethod => itf var can ref all insts of fbs impl the itf
// unless iSample was not=is still address with value 0
// * me calls other me of same fb => me can call me of ext fb with same name
// * me called via ref to fb => ref can point to inst of type of fb xor inst of derived fbs
// * assign VAR_IN_OUT var of basic fb ty to inst of derived fb ty
     => var can point to inst of ty of fb xor inst of derived fbs
// ABSTRACT concept
// * abstract fbs cannot be instanced and can contain abstract+non-abstract methods and props
// * abstract mes or props contain no impl like itfs
// * abstract fbs/props/mes therefore must be exted/impled to be instantiated
// FUNCTION = METHOD with 1 output, fn_name := output;

// References require access to complete structure, pointers not?
// https://stefanhenneken.net/2017/04/23/iec-61131-3-methods-properties-and-inheritance/

SUPER^ access parent fb
THIS^ required when me has local var which obscures var in fb

{attribute 'estimated-stack-usage' := '99'}

Advanced:
- Operating cases

Attribute pragmas https://infosys.beckhoff.com/english.php?content=../content/1033/tc3_plc_intro/2529556363.html&id=

//====SHENNANIGAN
// Beckhoff Engineering
// * Copy paste of ENUMs not possible with graphical list view, must use file view xor disable list view
// * Property references in libraries may not show up via show all references/shift-f12

//====conventions
//https://infosys.beckhoff.com/english.php?content=../content/1033/tc3_plc_intro/2529556363.html&id=

{attribute 'obsolete' := 'Stub for interface, do not use.'}
FUNCTION_BLOCK FB_obsolete IMPLEMENTS ITF_obsolete
  {attribute 'obsolete' := 'Stub for interface, do not use.'}
  PROPERTY obsolete_prop : INT
  ----
  {attribute 'obsolete' := 'Stub for interface, do not use.'}
  METHOD Activate : HRESULT
  
PROGRAM MAIN
  t1 := t1 + 1;
  // fb_obsolete.Activate();
  prop1 := fb_obsolete.obsolete_prop; // SHENNANIGAN: no warning
  //fb_obsolete.obsolete_prop := 1;
  
// Interfaces should not be trusted to return physical status of machine, unless explicit comment exists. 
// Interfaces without comments only describe, if the machine (controller) got the message delivered and machine does follow-up logic at some point to be checked.

// Beckhoff has no compile errors for exhaustive switch check to ensure all cases are handled
// comparable to -Wswitch-enum https://brevzin.github.io/c++/2019/08/01/enums-default/

// Beckhoff has no -INF/+INF for initialization of REAL/LREAL or it is not documented/unable to find

Selbsthaltung

Von https://github.com/tcunit/TcUnit.git

AnyTypeClass : IBaseLibrary.TypeClass;

CASE AnyTypeClass OF
IBaseLibrary.TypeClass.TYPE_BIT :
        {warning disable C0355}
        MEMCPY(destaddr := ADR(F_AnyToUnionValue.bitExpectedOrActual),
               srcAddr := AnyValue,
               n := AnySize);
        {warning enable C0355}
IBaseLibrary.TypeClass.TYPE_INTERFACE :
END_CASE

FUNCTION F_AnyTypeClassToString : STRING
VAR_INPUT
    AnyTypeClass : __SYSTEM.TYPE_CLASS;
END_VAR

    E_AssertionType.Type_UNDEFINED :
        F_AssertionTypeToString := 'UNDEFINED';


GETCPUCOUNTER();
F_GetCpuCounterAs64bit : LWORD := SHL(DWORD_TO_LWORD(CpuCounter.cpuCntHiDW), 32) + DWORD_TO_LWORD(CpuCounter.cpuCntLoDW);
TestSuiteName := F_RemoveInstancePathAndProjectNameFromTestInstancePath(TestInstancePath := TestInstancePath);
// Remove everything except the test suite name
FindPosition := FIND(STR1 := TestSuiteName, '.');
TestSuiteName := RIGHT(STR := TestSuiteName, SIZE := LEN(STR := TestSuiteName) - FindPosition);
F_GetTestSuiteNameFromTestInstancePath := TestSuiteName;

// Update the cycle count
CycleCount := TwinCAT_SystemInfoVarList._TaskInfo[GetCurrentTaskIndex.index].CycleCount;

F_GetMappingStatus
FAILED HRESULT < 0 (may be pending)
SUCCEEDED HRESULT >= 0

{attribute 'TcTypeSystem'}
(* Basic interface for images. *)
{attribute 'GUID' := '70D42C6D-6F4E-4719-8B29-2883D5D59B1C'}
{attribute 'c++_compatible'}
{attribute 'vtable_order' := 'Init;GetRowPointer;ReleaseRowPointer'}

TC3 > new project > TC HMI

WYSIWYG What You See Is What You Get principle: graphical editing of Desktop.view

git clone 'https://github.com/Beckhoff/TE2000_Client_Samples'
git clone 'https://github.com/Beckhoff/TF2000_Server_Samples'

vim TcHmiProject1.sln
vim TcHmiProject1/Desktop.view

//====common
Measure time difference
