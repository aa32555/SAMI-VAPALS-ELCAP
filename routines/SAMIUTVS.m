SAMIUTVS ;ven/arc/lgc - UNIT TEST for SAMIVSTS ; 1/16/19 9:09am
 ;;18.0;SAMI;;
 ;
 ; VA-PALS will be using Sam Habiel's [KBANSCAU] broker
 ;   to pull information from the VA server into the
 ;   VA-PALS client and, to push TIU notes generated by
 ;   VA-PALS forms onto the VA server.
 ; Using this broker between VistA instances requires
 ;   not only the IP and Port for the server be known,
 ;   but also, that the Access and Verify of the user
 ;   on the server be sent across as well.  This is
 ;   required as the user on the server must have the
 ;   necessary Context menu(s) allowing use of the
 ;   Remote Procedure(s).
 ; Six parameters have been added to the client
 ;   VistA to prevent the necessity of hard coding
 ;   certain values and to allow for default values for others.
 ;   SAMI PORT
 ;   SAMI IP ADDRESS
 ;   SAMI ACCVER
 ;   SAMI DEFAULT PROVIDER
 ;   SAMI DEFAULT STATIOn NUMBER
 ;   SAMI TIU NOTE PRINT NAME
 ;   SAMI DEFAULT CLINIC IEN
 ;   SAMI SYSTEM TEST PATIENT DFN
 ; Note that the user selected must have active
 ;   credentials on both the Client and Server systems
 ;   and the following Broker context menu.
 ;      OR CPRS GUI CHART
 ;
 ; @section 0 primary development
 ;
 ; @routine-credits
 ; @primary-dev: Larry Carlson (lgc)
 ;  larry@fiscientific.com
 ; @primary-dev-org: Vista Expertise Network (ven)
 ;  http://vistaexpertise.net
 ; @copyright: 2012/2018, ven, all rights reserved
 ; @license: Apache 2.0
 ;  https://www.apache.org/licenses/LICENSE-2.0.html
 ;
 ; @application: SAMI
 ; @version: 18.0
 ; @patch-list: none yet
 ;
 ; @sac-exemption
 ;  sac 2.2.8 Vendor specific subroutines may not be called directly
 ;   except by Kernel, Mailman, & VA Fileman.
 ;  sac 2.3.3.2 No VistA package may use the following intrinsic
 ;   (system) variables unless they are accessed using Kernel or VA
 ;   FileMan supported references: $D[EVICE], $I[O], $K[EY],
 ;   $P[RINCIPAL], $ROLES, $ST[ACK], $SY[STEM], $Z*.
 ;   (Exemptions: Kernel & VA Fileman)
 ;  sac 2.9.1: Application software must use documented Kernel
 ;   supported references to perform all platform specific functions.
 ;   (Exemptions: Kernel & VA Fileman)
 ;  ============== UNIT TESTS ======================
 ;  NOTE: Unit tests will pull data using the local
 ;       client VistA files rather than risk degrading
 ;       large datasets in use.  NEVERTHELESS, it is
 ;       recommended that UNIT TESTS be run when
 ;       VA-PALS is not in use as some Graphstore globals
 ;       are temporarily moved while testing is running.
 ;
 ; @to-do
 ;
 ; @section 1 code
 ;
START I $t(^%ut)="" W !,"*** UNIT TEST NOT INSTALLEd ***" q
 d EN^%ut($t(+0),2)
 Q
 ;
STARTUP n utsuccess
 Q
 ;
SHUTDOWN ; ZEXCEPT: utsuccess
 k utsuccess
 Q
 ;
UTMGPH ; @TEST - Test making 'patient-lookup' Graphstore
 i '$d(^KBAP("ALLPTS")) d  q
 .  d FAIL^%ut("^KBAP(""ALLPTS"") must exist for TESTING")
 ;
 d MKGPH^SAMIVSTS ; Rebuild 'patient-lookup' Graphstore
 ; Check that the Graphstore was built
 n ptlkup s ptlkup="^%wd(17.040801,""B"",""patient-lookup"")"
 n si s si=$o(@ptlkup@(0))
 i '$g(si) d  q
 . d FAIL^%ut("MKGPH entry did not build 'patient-lookup' Graphstore")
 ;
 n node,snode,root,gien,dfn,PTDATA
 ;
 s root=$$setroot^%wd("patient-lookup")
 ;
 S node=$na(^KBAP("ALLPTS")),snode=$p(node,")")
 s utsuccess=1
 F  S node=$Q(@node) q:node'[snode  d  q:'utsuccess
 . S PTDATA=@node
 . S dfn=$p(PTDATA,"^",12)
 . s gien=$o(@root@("dfn",dfn,0))
 . i '$g(gien) s utsuccess=0 q
 .;
 .; Now compare the entries in this Graphstore node with
 .;  the information in the respective ^KBAP("ALLPTS" node
 . i '$o(@root@("last5",$p(PTDATA,"^",9),0)) s utsuccess=0 q
 . i '$l($p(PTDATA,"^")) s utsuccess=0 q
 . i '$o(@root@("name",$p(PTDATA,"^"),0)) s utsuccess=0 q
 . i '$l($p(PTDATA,"^",4)) s utsuccess=0 q
 . i '$o(@root@("name",$p(PTDATA,"^",4),0)) s utsuccess=0 q
 . i '$o(@root@("saminame",$p(PTDATA,"^",4),0)) s utsuccess=0 q
 ;
 i 'utsuccess d  q
 . d FAIL^%ut("'patient-lookup' Graphstore incorrectly built")
 d CHKEQ^%ut(utsuccess,1,"Testing Complete Graphstore build  FAILED!")
 q
 ;
UTAPTS ; @TEST - Test pulling patient data through broker
 k ^KBAP("ALLPTS UNITTEST")
 d ALLPTS1^SAMIVSTS("ALLPTS UNITTEST")
 ;                in file 2         in ALLPTS
 ;  NAME            piece 1          piece 1
 ;  sex             piece 2          piece 6
 ;  birthdate       piece 3 fmdt     piece 10 (yyyymmdd)
 ;
 ; Pull NAME from file 2 B cross
 ;   Get NAME,sex,birthdate,build last5
 ; Pull entry in Graphstore using last5
 ;   Knowing gien get NAME,sex,birthdate
 ; Compare
 n NAME2,SEX2,DOB2,LAST52,DFN2
 n NODE2,NODEG,gien
 n root s root=$$setroot^%wd("patient-lookup")
 s utsuccess=1
 S DFN2=0
 f  s DFN2=$o(^DPT(DFN2)) q:'DFN2  d  q:'utsuccess
 . s NODE2=$g(^DPT(DFN2,0))
 . s NAME2=$p(NODE2,"^")
 . s SEX2=$$UP^XLFSTR($e($p(NODE2,"^",2)))
 . s DOB2=$$FMTHL7^XLFDT($p(NODE2,"^",3))
 . s DOB2=$e(DOB2,1,4)_"-"_$e(DOB2,5,6)_"-"_$e(DOB2,7,8)
 . s gien=$o(@root@("dfn",DFN2,0))
 . s LAST52=$$UP^XLFSTR($e(NAME2))_$e($p(NODE2,"^",9),6,9)
 . i '$g(gien) s utsuccess=0 q
 . i '$d(@root@("name",NAME2,gien)) s utsuccess=0 q
 . i '($p($g(@root@(gien,"gender")),"^")=SEX2) d  q
 .. s utsuccess=0
 . i '$d(@root@("last5",LAST52,gien)) s utsuccess=0 q
 . i '($g(@root@(gien,"sbdob"))=DOB2) s utsuccess=0 q
 k ^KBAP("ALLPTS UNITTEST")
 i 'utsuccess d  q
 . d FAIL^%ut("KBAP(""ALLPTS UNITTEST"") incorrectly built")
 d CHKEQ^%ut(utsuccess,1,"Testing pulling patients through broker FAILED!")
 q
 ;
UTPRVDS ; @TEST - Pulling Providers through the broker
 k ^KBAP("UNIT TEST PROVIDERS")
 n root s root=$$setroot^%wd("providers")
 m ^KBAP("UNIT TEST PROVIDERS")=@root
 s utsuccess=1
 n SAMIPVDS
 s SAMIPVDS=$$PRVDRS^SAMIVSTS
 i '$g(SAMIPVDS) d  q
 . m @root=^KBAP("UNIT TEST PROVIDERS") k ^KBAP("UNIT TEST PROVIDERS")
 . d FAIL^%ut("No providers pulled through broker")
 n ien,DUZG,NAMEG
 f ien=1:1:$g(SAMIPVDS) d  q:'utsuccess
 . s DUZG=@root@(ien,"duz")
 . s NAMEG=@root@(ien,"name")
 . i '$d(^XUSEC("PROVIDER",DUZG)) s utsuccess=0 q
 .; i '$$ACTIVE^XUSER(DUZG) s utsuccess=0 q
 . i '($$UP^XLFSTR(NAMEG))=($$UP^XLFSTR($p($g(^VA(200,DUZG,0)),"^"))) d  q
 .. s utsuccess=0
 m @root=^KBAP("UNIT TEST PROVIDERS") k ^KBAP("UNIT TEST PROVIDERS")
 d CHKEQ^%ut(utsuccess,1,"Testing pulling Providers through broker FAILED!")
 q
 ;
UTRMDRS ; @TEST - Pulling Reminders through the broker
 k ^KBAP("UNIT TEST REMINDERS")
 n root s root=$$setroot^%wd("reminders")
 m ^KBAP("UNIT TEST REMINDERS")=@root
 s utsuccess=1
 n SAMIREMINDERS
 S SAMIREMINDERS=$$RMDRS^SAMIVSTS
 i '$g(SAMIREMINDERS) d  q
 . m @root=^KBAP("UNIT TEST REMINDERS")
 . k ^KBAP("UNIT TEST REMINDERS")
 . d FAIL^%ut("No reminders pulled through broker")
 n IENV,IENG,NAMEG,PNAMEG,TYPEG
 f IENG=1:1:$g(SAMIREMINDERS) d  q:'utsuccess
 . s NAMEG=@root@(IENG,"name") ; Mixed case
 . s PNAMEG=@root@(IENG,"printname") ; All caps
 . s TYPEG=@root@(IENG,"type")
 . s IENV=@root@(IENG,"ien")
 . I TYPEG="R" d  q:'utsuccess
 .. i '$d(^PXD(811.9,"B",PNAMEG,IENV)) s utsuccess=0 q
 .. i '$d(^PXD(811.9,"D",NAMEG,IENV)) s utsuccess=0 q
 . I TYPEG="C" d  q:'utsuccess
 .. i '($g(^PXRMD(811.7,IENV,0))=NAMEG) s utsuccess=0 q
 m @root=^KBAP("UNIT TEST REMINDERS")
 k ^KBAP("UNIT TEST REMINDERS")
 d CHKEQ^%ut(utsuccess,1,"Testing pulling Reminders through broker FAILED!")
 q
 ;
 ;
UTCLNC ; @TEST - Pulling Clinics through the broker
 k ^KBAP("UNIT TEST CLINICS")
 n root s root=$$setroot^%wd("clinics")
 m ^KBAP("UNIT TEST CLINICS")=@root
 s utsuccess=1
 n SAMICLNC
 s SAMICLNC=$$CLINICS^SAMIVSTS
 i '$g(SAMICLNC) d  q
 . m @root=^KBAP("UNIT TEST CLINICS")
 . k ^KBAP("UNIT TEST CLINICS")
 . d FAIL^%ut("No clinics pulled through broker")
 n IENG,IENV,NAMEG
 f IENG=1:1:$g(SAMICLNC) d  q:'utsuccess
 . s NAMEG=@root@(IENG,"name")
 . s IENV=@root@(IENG,"ien")
 . i '$d(^SC("B",NAMEG,IENV)) s utsuccess=0 q
 m @root=^KBAP("UNIT TEST CLINICS")
 k ^KBAP("UNIT TEST CLINICS")
 d CHKEQ^%ut(utsuccess,1,"Testing pulling Clinics through broker FAILED!")
 q
 ;
 ;
UTHF ; @TEST - Pulling Health Factors through the broker
 k ^KBAP("UNIT TEST HEALTH FACTORS")
 n root s root=$$setroot^%wd("health-factors")
 m ^KBAP("UNIT TEST HEALTH FACTORS")=@root
 s utsuccess=1
 n SAMIHF
 S SAMIHF=$$HLTHFCT^SAMIVSTS
 i '$g(SAMIHF) d  q
 . m @root=^KBAP("UNIT TEST HEALTH FACTORS")
 . k ^KBAP("UNIT TEST HEALTH FACTORS")
 . d FAIL^%ut("No health factors pulled through broker")
 n IENV,IENG,NAMEG
 f IENG=1:1:$g(SAMIHF) d  q:'utsuccess
 . s NAMEG=@root@(IENG,"name")
 . s IENV=@root@(IENG,"ien")
 . i '($p($g(^AUTTHF(IENV,0)),"^")=NAMEG) s utsuccess=0 q
 m @root=^KBAP("UNIT TEST HEALTH FACTORS")
 k ^KBAP("UNIT TEST HEALTH FACTORS")
 d CHKEQ^%ut(utsuccess,1,"Testing pulling Health Factors through broker FAILED!")
 q
 ;
UTCLRG ; @TEST - Clear a Graphstore of entries
 n root s root=$$setroot^%wd("providers")
 k ^KBAP("UNIT TEST CLRGRPH") M ^KBAP("UNIT TEST CLRGRPH")=@root
 n cnt s cnt=$o(@root@("A"),-1)
 i 'cnt d  q
 . d FAIL^%ut("No 'providers found' entry")
 s cnt=$$CLRGRPS^SAMIVSTS("providers"),cnt=$o(@root@("A"),-1)
 m @root=^KBAP("UNIT TEST CLRGRPH") k ^KBAP("UNIT TEST CLRGRPH")
 d CHKEQ^%ut(cnt,0,"Clear Graphstore FAILED!")
 q
EOR ; End of Routine SAMIUTVS
