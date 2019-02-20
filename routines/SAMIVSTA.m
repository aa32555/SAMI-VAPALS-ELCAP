SAMIVSTA ;;ven/lgc - M2M Broker to build TIU for VA-PALS ; 20190220Z19:27
 ;;18.0;SAMI;;
 ;
 ;@license: see routine SAMIUL
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
 ;   SAMI DEFAULT STATION NUMBER
 ;   SAMI TIU NOTE PRINT NAME
 ;   SAMI DEFAULT CLINIC IEN
 ;   SAMI SYSTEM TEST PATIENT DFN
 ; Note that the user selected must have active
 ;   credentials on both the Client and Server systems
 ;   and the following Broker context menu.
 ;      OR CPRS GUI CHART
 ;
 ;
 ;@routine-credits
 ;@primary development organization: Vista Expertise Network
 ;@primary-dev: Larry G. Carlson (lgc)
 ;@primary-dev: Alexis R. Carlson (arc)
 ;@additional-dev: Linda M. R. Yaw (lmry)
 ;@copyright:
 ;@license: see routine SAMIUL
 ;
 ;@last-updated: 2019-02-20
 ;@application: VA-PALS
 ;@version: 1.0
 ;
 ;@sac-exemption
 ; sac 2.2.8 Vendor specific subroutines may not be called directly
 ;  except by Kernel, Mailman, & VA Fileman.
 ; sac 2.3.3.2 No VistA package may use the following intrinsic
 ;  (system) variables unless they are accessed using Kernel or VA
 ;  FileMan supported references: $D[EVICE], $I[O], $K[EY],
 ;  $P[RINCIPAL], $ROLES, $ST[ACK], $SY[STEM], $Z*.
 ;  (Exemptions: Kernel & VA Fileman)
 ; sac 2.9.1: Application software must use documented Kernel
 ;  supported references to perform all platform specific functions.
 ;  (Exemptions: Kernel & VA Fileman)
 ;
 quit  ; not from top
 ;
 ;@called-by
 ;  SAMIHOM4  [$$SV2VISTA^SAMIVSTA(.SAMIFILTER)]
 ;@calls
 ;  TASKIT^SAMIVSTA
 ;@input
 ;  filter("studyid")  = VA-PALS study ID e.g. XXX00812
 ;  filter("form")    = "siform-" + date e.g. siform-2018-05-18
 ;@output
 ;  if successful sets tiuien in @vals@("tiuien") node 
 ;   in Graphstore
 ;  if called as extrinsic function, returns tiu ien
 ;@tests
 ;  UTTASK^SAMIUTVA
SV2VISTA(filter) ;
 if '$Q do  quit
 . new ZTSAVE,ZTRTN,ZTDESC,ZTDTH,ZTIO,ZTQUEUED,ZTREQ,ZTSK,X,Y
 . set ZTDESC="SAMIVSTA BUILDING NEW TIU NOTE"
 . set ZTDTH=$H
 . set ZTIO=""
 . set ZTSAVE("filter(")=""
 . set ZTRTN="TASKIT^SAMIVSTA"
 . do ^%ZTLOAD
 ;
 ;
 ;@called-by
 ;  SV2VISTA^SAMIVSTA
 ;@calls
 ;  $$GET^XPAR
 ;  $$setroot^%wd
 ;@input
 ;@output
 ;@tests
 ; UTTASK^SAMIUTVA
 ;Setup all variables into Graphstore
TASKIT new samikey,vals,root,dest,provduz,ptdfn,tiutitlepn
 new tiutitleien,tiuien,X,Y,SAMIXD
 new clinien,si
 set tiuien=0
 ;
 set provduz=$get(filter("DUZ"))
 if 'provduz do
 . set provduz=$$GET^XPAR("SYS","SAMI DEFAULT PROVIDER DUZ",,"Q")
 if '$get(provduz) quit:$Q 0  quit
 ;
 set clinien=$get(filter("clinicien"))
 if 'clinien do
 . set clinien=$$GET^XPAR("SYS","SAMI DEFAULT CLINIC IEN",,"Q")
 if '$get(clinien) quit:$Q 0  quit
 ;
 set tiutitlepn=$$GET^XPAR("SYS","SAMI NOTE TITLE PRINT NAME",,"Q")
 set tiutitleien=$order(^TIU(8925.1,"D",tiutitlepn,0))
 if '$get(tiutitleien) quit:$Q 0  quit
 ;
 set si=$get(filter("studyid")) ; e.g."XXX00001"
 if '$length($get(si)) quit:$Q 0  quit
 ;
 set root=$$setroot^%wd("vapals-patients")
 ; e.g. root = ^%wd(17.040801,23)
 ;
 set samikey=$g(filter("form"))
 if (samikey'["siform") quit:$Q 0  quit
 i '($length(samikey,"-")=4) quit:$Q 0  quit
 ; e.g. samikey="siform-2018-11-13"
 ;
 set vals=$name(@root@("graph",si,samikey))
 ; e.g. vals="^%wd(17.040801,23,""graph"",""XXX00001"",""siform-2018-11-13"")"
 ;
 set ptdfn=@vals@("dfn")
 if '$get(ptdfn) quit:$Q 0  quit
 ;
 set dest=$name(@vals@("note"))
 ; e.g. dest="^%wd(17.040801,23,""graph"",""XXX00333"",""siform-2018-11-13"",""note"")"
 ;
 ;
 ;@called-by
 ;@calls
 ;  BLDTIU^SAMIVSTA
 ;@input
 ;@output
 ;   tiuien = 0 : Building new tiu stubb failed
 ;   tiuien = n : IEN into file #8925 for new note stubb
 ;@tests
 ; Build the new tiu stubb.
NEWTIU d BLDTIU(.tiuien,ptdfn,tiutitleien,provduz,clinien)
 if 'tiuien quit:$Q 0  quit
 ; For unit testing. Save new tiuien
 if $data(%ut) set ^TMP("UNIT TEST","UTTASK^SAMIUTVA")=tiuien
 ;
 ;
 ;@called-by
 ;@calls
 ;  SETTEXT^SAMIVSTA
 ;@input
 ;@output
 ;@tests
 ; Set text in the note
NEWTXT d SETTEXT(.tiuien,dest)
 set:(tiuien>0) @vals@("tiuien")=tiuien
 if '$get(tiuien) quit:$Q 0  quit
 ; 
 ;
 ;@called-by
 ;  ENCNTR^SAMIVSTA
 ;@calls
 ;  VISTSTR^SAMIVSTA
 ;  BLDENCTR^SAMIVSTA
 ;  $$KSAVE^SAMIVSTA
 ;@input
 ;@output
 ;@tests
 ;   UTTASK^SAMIUTVA
 ; Update the encounter
ENCNTR new VSTR set VSTR=$$VISTSTR(tiuien)
 quit:'($length(VSTR,";")=3) tiuien
 ; Time to build the HF array for the next call
 new SAMIHFARR
 set SAMIHFARR(1)="HDR^0^^"_VSTR
 set SAMIHFARR(2)="VST^DT^"_$P(VSTR,";",2)
 set SAMIHFARR(3)="VST^PT^"_ptdfn
 set SAMIHFARR(4)="VST^HL^"_$P(VSTR,";")
 set SAMIHFARR(5)="VST^VC^"_$P(VSTR,";",3)
 set SAMIHFARR(6)="PRV^"_provduz_"^^^"_$P($G(^VA(200,provduz,0)),"^")_"^1"
 set SAMIHFARR(7)="POV+^F17.210^COUNSELING AND SCREENING^Nicotine dependence, cigarettes, uncomplicated^1^^0^^^1"
 set SAMIHFARR(8)="COM^1^@"
 set SAMIHFARR(9)="HF+^999001^LUNG SCREENING HF^LCS-ENROLLED^@^^^^^2^"
 set SAMIHFARR(10)="COM^2^@"
 set SAMIHFARR(11)="CPT+^99203^NEW PATIENT^Intermediate Exam  26-35 Min^1^71^^^0^3^"
 set SAMIHFARR(12)="COM^3^@"
 do BLDENCTR(.tiuien,.SAMIHFARR)
 if $get(tiuien),$get(provduz) do
 . new ASave set ASave=$$KASAVE(provduz,tiuien)
 if $get(tiuien) quit:$Q 0  quit
 quit:$Q 0  quit
 ;
 ;
 ;@rpi - TIU CREATE RECORD
 ;@called-by
 ;  ENCNTR^SAMIVSTA
 ;@calls
 ;  $$HTFM^XLFDT($H)
 ;  M2M^SAMIM2M
 ;@input
 ;   tiuien  : variable by reference for tiuien
 ;   dfn     : IEN into PATIENT [#2] file
 ;   title   : TIU title IEN into TIU DOCUMENT DEFINITION [#8925.1]
 ;   user    : DUZ of user generating TIU document
 ;   clinien : IEN of clinic in HOSPITAL LOCATION [#44]
 ;@output
 ;   ien of new TIU note. 0=failure
 ;@tests
 ;   UTBLDTIU^SAMIUTVA
 ; Build a TIU and VISIT stubb
BLDTIU(tiuien,dfn,title,user,clinien) ;
 new cntxt,rmprc,console,cntopen,SAMIARR,SAMIXD
 kill tiuien set tiuien=0
 quit:'$get(dfn)
 quit:'$get(title)
 quit:'$get(user)
 quit:'$get(clinien)
 new vdt set vdt=$$HTFM^XLFDT($horolog) ; Visit date
 new vstr set vstr=clinien_";"_vdt_";A"
 new suppress set suppress=1
 new noasf set noasf=1
 set cntxt="OR CPRS GUI CHART"
 set rmprc="TIU CREATE RECORD"
 set (console,cntopen)=0
 ;
 set SAMIARR(1)=dfn
 set SAMIARR(2)=title
 set SAMIARR(3)=""
 set SAMIARR(4)=""
 set SAMIARR(5)=""
 ;
 new SAMIPOO
 set SAMIPOO(1202)=user
 set SAMIPOO(1301)=$$HTFM^XLFDT($H) ; REFERENCE DATE
 set SAMIPOO(1205)=clinien
 set SAMIPOO(1701)=""
 set SAMIARR(6)="@SAMIPOO"
 ;
 set SAMIARR(7)=vstr
 set SAMIARR(8)=suppress
 do M2M^SAMIM2M(.SAMIXD,cntxt,rmprc,console,cntopen,.SAMIARR)
 set tiuien=+$get(SAMIXD)
 quit
 ;
 ;
 ;@rpi - TIU SET DOCUMENT TEXT
 ;@called-by
 ;  $$SETTEXT^SAMIVSTA
 ;@calls
 ;  M2M^SAMIM2M
 ;@input
 ;   tiuien   = IEN of tiu note stubb in file #8925 by reference
 ;   dest     = indirection pointer to tiu note text
 ;                in the "VA-PALS patients" graph store
 ;@output
 ;   tiuien  = 0 if filing failed, the TIU IEN if successful
 ;@tests
 ;  UTSTEXT^SAMIUTVA
 ;Set text in existing tiu note stubb
SETTEXT(tiuien,dest) ;
 set tiuien=+$get(tiuien)
 quit:'$get(tiuien)
 quit:'$data(dest)
 new snode set snode=$piece(dest,")")
 ;
 new cntxt,rmprc,console,cntnopen,SAMIARR,SAMIXD
 set cntxt="OR CPRS GUI CHART"
 set rmprc="TIU SET DOCUMENT TEXT"
 set (console,cntnopen)=0
 new suppress set suppress=0
 ;
 set SAMIARR(1)=tiuien
 ;
 new SAMIPOO,cnt,node,snode
 set SAMIPOO("HDR")="1^1"
 set node=dest,snode=$P(node,")")
 for  set node=$query(@node) quit:node'[snode  do
 . set cnt=$get(cnt)+1
 . set SAMIPOO("TEXT",cnt,0)=@node
 set SAMIARR(2)="@SAMIPOO"
 ;
 set SAMIARR(3)=suppress
 ;
 do M2M^SAMIM2M(.SAMIXD,cntxt,rmprc,console,cntnopen,.SAMIARR)
 ;
 ;@called-by
 ;  ENCNTR^SAMIVSTA
 ;@calls
 ;@input
 ;@output
 ;@tests
STXT1 set tiuien=+$get(SAMIXD)
 quit
 ;
 ;
 ;@rpi - ORWPCE SAVE
 ;@called-by
 ;  $$BLDENCTR^SAMIVSTA
 ;@calls
 ;  $$VISTSTR^SAMIVSTA
 ;@input
 ;   tiuien  = IEN of note in 8925
 ;   hfarray = array by reference of Health Factors e.g.
 ;@output
 ;   tiuien  = 0 failed to file encounter
 ;           = IEN of note in 8925 if successful
 ;@tests
 ;  UTENCTR^SAMIUTVA
 ; Add encounter information to a tiu note
BLDENCTR(tiuien,SAMIUHFA) ;
 ;
 if '$get(tiuien) quit:$Q 0  quit
 if '$d(SAMIUHFA) quit:$Q 0  quit
 new VSTR set VSTR=$$VISTSTR(tiuien)
 if '($length(VSTR,";")=3) quit:$Q 0  quit
 ;
 new suppress set suppress=0
 new cntxt,rmprc,console,cntnopen,SAMIARR
 set cntxt="OR CPRS GUI CHART"
 set rmprc="ORWPCE SAVE"
 set (console,cntnopen)=0
 ;
 ;@called-by
 ;@calls
 ;@input
 ;@output
 ;@tests
HFARRAY kill SAMIARR
 set SAMIARR(1)="@SAMIUHFA"
 ;
 ;@called-by
 ;@calls
 ;@input
 ;@output
 ;@tests
SPRS set SAMIARR(2)=suppress
 ;
 ;@called-by
 ;@calls
 ;  M2M^SAMIM2M
 ;@input
 ;@output
 ;@tests
ENCTR3 set SAMIARR(3)=VSTR
 ;
 do M2M^SAMIM2M(.SAMIXD,cntxt,rmprc,console,cntnopen,.SAMIARR)
 quit:$Q tiuien  quit
 ;
 ;
 ;
 ;@rpi - TIU UPDATE ADDITIONAL SIGNERS
 ;@called-by
 ;@calls
 ;  $$setroot^%wd
 ;@input
 ;@output
 ;@tests
 ; Additional Signers
 ; Enter
 ;  filter("studyid")  = VA-PALS study ID e.g. XXX00812
 ;  filter("form"))    = "siform-" + date e.g. siform-2018-05-18
 ;  filter("add signers")) = array of additional signers
 ;          e.g. filter("add signers",1)="72[^King,Matt]"
 ;          e.g. filter("add signers",2)="64[^Smith,Mary]"
 ; Exit
 ;  if successful sets tiuien in @vals@("add signers") node
 ;   in Graphstore
 ;  if called as extrinsic
 ;     0  = adding signer(s) failed
 ;     1  = adding signer(s) successful
ADDSGNRS(filter) ;
 if '$data(filter("add signers")) quit:$Q 0  quit
 ;
 ; Setup all variables into Graphstore
 new si,root,vals,tiuien
 ;
 set si=$get(filter("studyid")) ; e.g."XXX00333"
 quit:'$length($g(si))
 ;
 set root=$$setroot^%wd("vapals-patients")
 ; e.g. root = ^%wd(17.040801,23)
 ;
 set samikey=$get(filter("form"))
 if (samikey'["siform") quit:$Q 0  quit
 if '($length(samikey,"-")=4) quit:$Q 0  quit
 ; e.g. samikey="siform-2018-06-04"
 ;
 set vals=$name(@root@("graph",si,samikey))
 ; e.g. vals="^%wd(17.040801,23,""graph"",""XXX00333"",""siform-2018-06-04"")"
 ;
 set tiuien=@vals@("tiuien")
 if '$get(tiuien) quit:$Q 0  quit
 ;
 ;
 ;@called-by
 ;@calls
 ;  $$KASAVE^SAMIVSTA
 ;@input
 ;@output
 ;@tests
 ;  UTADDNS^SAMIUTVA
ADDSIGN new cntxt,rmprc,console,cntnopen,SAMIARR,SAMIXD
 set (console,cntnopen)=0
 set cntxt="OR CPRS GUI CHART"
 set rmprc="TIU UPDATE ADDITIONAL SIGNERS"
 ;
 kill SAMIARR
 set SAMIARR(1)=tiuien
 ;
 new SAMIPOO
 merge SAMIPOO=filter("add signers")
 set SAMIARR(2)="@SAMIPOO"
 ;
 do M2M^SAMIM2M(.SAMIXD,cntxt,rmprc,console,cntnopen,.SAMIARR)
 ;
 ; Clear ASAVE nodes
 if $data(SAMIPOO) do
 . new cnt,ASave set cnt=0
 . for  set cnt=$O(SAMIPOO(cnt)) quit:'cnt  do
 .. set ASave=$$KASAVE($piece(SAMIPOO(cnt),"^"),tiuien)
 ;
 ; If not UNIT TEST update Graphstore
 if +$get(SAMIXD),'$get(%ut) do  quit:$Q 1
 . new cnt set cnt=0
 . for  set cnt=$O(SAMIPOO(cnt)) quit:'cnt  do
 ..  set @vals@("add signers",cnt)=SAMIPOO(cnt)
 ;
 ; if doing UNIT TEST update utsuccess
 if $get(%ut),$data(utsuccess) do
 . set utsuccess=($get(SAMIXD)>0)
 quit
 ;
 ;
 ;@rpi - TIU CREATE ADDENDUM RECORD
 ;@called-by
 ;@calls
 ;  $$HTFM^XLFDT
 ;  M2M^SAMIM2M
 ;@input
 ;   tiuaien   = variable by reference for new TIU
 ;               addendum IEN into 8925
 ;   tiuien    = IEN of note in 8925 to which we
 ;               wish to add an addendum
 ;   userduz   = DUZ [IEN into file 200] of the user
 ;               building the addendum
 ;@output
 ;  if called as extrinsic
 ;   0 = unsuccessful in adding addendum
 ;   n = ien of new addendum in 8925
 ;@tests
 ;   UTADDND^SAMIUTVA
 ; Build a tiu addendum
TIUADND(tiuien,userduz) ;
 ;
 if '$get(tiuien) quit:$Q 0  quit
 if '$get(userduz) quit:$Q 0  quit
 ;
 new cntxt,rmprc,console,cntnopen,SAMIARR,SAMIXD
 set (console,cntnopen)=0
 set cntxt="OR CPRS GUI CHART"
 set rmprc="TIU CREATE ADDENDUM RECORD"
 ;
 kill SAMIARR
 set SAMIARR(1)=tiuien
 ;
 new SAMIPOO
 set SAMIPOO(1202)=userduz
 set SAMIPOO(1301)=$$HTFM^XLFDT($horolog) ; REFERENCE DATE
 set SAMIARR(2)="@SAMIPOO"
 ;
 new noasf set noasf=1 ; Do not commit
 set SAMIARR(8)=noasf
 ;
 do M2M^SAMIM2M(.SAMIXD,cntxt,rmprc,console,cntnopen,.SAMIARR)
 ;
 if (+$get(SAMIXD)>0) quit:$Q +$get(SAMIXD)
quit:$Q 0  quit
 ;
 ;
 ;@rpi - ORWPCE NOTEVSTR
 ;@called-by
 ;@calls
 ;  M2M^SAMIM2M
 ;@input
 ;   tiuien = IEN of TIU note in 8925
 ;@output
 ;   0 = failed to obtain VSTR for TIU
 ;   else VSTR string
 ;@tests
 ;  UTVSTR^SAMIUTVA
 ;  UTENCTR^SAMIUTVA
VISTSTR(tiuien) ;
 if '$get(tiuien) quit 0
 new cntxt,rmprc,console,cntnopen,SAMIARR,SAMIXD,X,Y
 set (console,cntnopen)=0
 set cntxt="OR CPRS GUI CHART"
 set rmprc="ORWPCE NOTEVSTR"
 set SAMIARR(1)=tiuien
 do M2M^SAMIM2M(.SAMIXD,cntxt,rmprc,console,cntnopen,.SAMIARR)
 set:'$g(SAMIXD) SAMIXD=0
 quit SAMIXD
 ;
 ;
 ;@rpi - SCMC PATIENT INFO
 ;@called-by
 ;   PTINFO^KBAIPTIN
 ;   SAMIHOM3
 ;@calls
 ;  M2M^SAMIM2M
 ;  $$setroot^%wd
 ;  $$FMTHL7^XLFDT
 ;  $$URBRUR^SAMIVSTA
 ;@input
 ;   DFN   = IEN of patient into file 2
 ;@output
 ;   Sets additional nodes in patient's Graphstore
 ;   If called as extrinsic
 ;      0   = unable to identify patient
 ;      1^dfn = lookup of patient successful
 ;      2^dfn = and update of Graphstore successful
 ;@tests
 ;  UTPTINF^SAMIUTVA
 ; Pull patient information from the server and
 ;   push into the 'patient-lookup' Graphstore
PTINFO(dfn) ;
 new cntxt,rmprc,console,cntnopen,SAMIARR,SAMIXD
 new X,rslt
 set rslt=0
 set cntxt="SCMC PCMMR APP PROXY MENU"
 set rmprc="SCMC PATIENT INFO"
 set console=0
 set cntnopen=0
 new ssn set ssn=""
 if '$g(dfn) quit:$Q rslt  quit
 set SAMIARR(1)=dfn
 ;
 do M2M^SAMIM2M(.SAMIXD,cntxt,rmprc,console,cntnopen,.SAMIARR)
 ; Update patient-lookup entry for this patient
 new root set root=$$setroot^%wd("patient-lookup")
 new name,node,gien
 if '(dfn=$p(SAMIXD,"^",1)) q:$Q rslt  q
 set rslt="1^"_dfn
 new node set node=$name(@root@("dfn",dfn))
 set node=$Q(@node)
 set gien=+$piece(node,",",5)
 if '$get(gien) quit:$Q rslt  quit
 set rslt="2^"_dfn
 set ssn=$piece(SAMIXD,"^",3)
 new dob set dob=$$FMTHL7^XLFDT($piece(SAMIXD,"^",4))
 set dob=$extract(dob,1,4)_"-"_$extract(dob,5,6)_"-"_$extract(dob,7,8)
 quit:'(dob=@root@(gien,"sbdob"))
 set @root@(gien,"ssn")=$piece(SAMIXD,"^",3)
 set:+$piece(SAMIXD,"^",3) @root@("ssn",$piece(SAMIXD,"^",3))=gien
 set @root@(gien,"icn")=$piece(SAMIXD,"^",18)
 set:+$piece(SAMIXD,"^",18) @root@("icn",$piece(SAMIXD,"^",18))=gien
 ; Pull state abbreviation
 new dic5ien if $length($piece(SAMIXD,"^",13)) set dic5ien=$order(^DIC(5,"B",$piece(SAMIXD,"^",13),0))
 new StateABB set StateABB=$piece($get(^DIC(5,+$get(dic5ien),0)),"^",2)
 set @root@(gien,"age")=$piece(SAMIXD,"^",5)
 set @root@(gien,"sex")=$piece(SAMIXD,"^",6)
 set @root@(gien,"marital status")=$piece(SAMIXD,"^",7)
 set @root@(gien,"active duty")=$piece(SAMIXD,"^",8)
 set @root@(gien,"address1")=$piece(SAMIXD,"^",9)
 set @root@(gien,"address2")=$piece(SAMIXD,"^",10)
 set @root@(gien,"address3")=$piece(SAMIXD,"^",11)
 set @root@(gien,"city")=$piece(SAMIXD,"^",12)
 set @root@(gien,"state")=$get(StateABB)
 set @root@(gien,"zip")=$piece(SAMIXD,"^",14)
 set @root@(gien,"county")=$piece(SAMIXD,"^",15)
 set @root@(gien,"phone")=$piece(SAMIXD,"^",16)
 set @root@(gien,"sensitive patient")=$piece(SAMIXD,"^",17)
 ; Now get rural or urban and push into both the 
 ;   "patient-lookup" and "vapals-patients" Graphstores
 if $piece(SAMIXD,"^",14) do
 . new UrbanRural set UrbanRural=$$URBRUR^SAMIVSTA($piece(SAMIXD,"^",14))
 . set @root@(gien,"samiru")=UrbanRural
 . set root=$$setroot^%wd("vapals-patients")
 . set gien=$order(@root@("dfn",dfn,0))
 . set:gien @root@(gien,"samiru")=UrbanRural
 quit:$Q rslt  quit
 ;
 ;
 ;
 ;@rpi - ORWPT ID INFO
 ;@called-by
 ;@calls
 ;  M2M^SAMIM2M
 ;@input
 ;   DFN   = IEN of patient into file 2
 ;@output
 ;   Sets additional nodes in patient's Graphstore
 ;   If called as extrinsic
 ;      0   = unable to identify patient
 ;      1^SSN = lookup of patient successful
 ;      2^SSN = and update of Graphstore successful
 ;@tests
 ;  UTSSN^SAMIUTVA
 ; Pull patient SSN from the server and
 ;   push into the 'patient-lookup' Graphstore
PTSSN(dfn) ;
 new cntxt,rmprc,console,cntnopen,SAMIARR,SAMIXD
 set cntxt="OR CPRS GUI CHART"
 set rmprc="ORWPT ID INFO"
 set (console,cntnopen)=0
 new ssn set ssn=0
 if '$get(dfn) quit:$Q ssn  quit
 set SAMIARR(1)=dfn
 kill SAMIXD
 do M2M^SAMIM2M(.SAMIXD,cntxt,rmprc,console,cntnopen,.SAMIARR)
 if '$get(SAMIXD) quit:$Q ssn  quit
 set ssn="1^"_$piece(SAMIXD,"^")
 ;
 ;@called-by
 ;@calls
 ;  $$setroot^%wd
 ;  $$FMTHL7^XLFDT
 ;@input
 ;@output
 ;@tests
PTSSN1 new root set root=$$setroot^%wd("patient-lookup")
 new name,node,gien
 set name=$piece(SAMIXD,"^",8)
 new node set node=$name(@root@("name",name))
 set node=$Q(@node)
 if ($piece(node,",",4)_","_$piece(node,",",5))[name set gien=+$piece(node,",",6)
 if '$get(gien) quit:$Q ssn  quit
 new dob set dob=$$FMTHL7^XLFDT($piece(SAMIXD,"^",2))
 set dob=$extract(dob,1,4)_"-"_$extract(dob,5,6)_"-"_$extract(dob,7,8)
 if '(dob=@root@(gien,"sbdob")) quit:$Q ssn  quit
 new last5 set last5=$extract(name)_$extract(SAMIXD,6,9)
 if '(last5=@root@(gien,"last5")) quit:$Q ssn  quit
 set @root@(gien,"ssn")=$piece(SAMIXD,"^")
 set @root@("ssn",$piece(SAMIXD,"^"))=gien
 set ssn="2^"_$piece(SAMIXD,"^")
 quit:$Q ssn  quit
 ;
 ;
 ;@API-code: $$SIGNTIU^SAMIVSTA
 ;@called-by
 ;@calls
 ;  $$GET^XPAR
 ;  $$GET1^DIQ
 ;  ES^TIURS
 ;@input
 ;   tiuien = ien of note in 8925
 ;@output
 ;   0 = failure, 1 = successful
 ;@tests
 ;  UTSIGN^SAMIUTVA
 ;  UTADDND^SAMIUTVA
 ; Sign a TIU note is ONLY FOR UNIT TESTING as it skips
 ;   over authorization processes.
SIGNTIU(tiuda) ;
 ; some code pulled from SIGN in TIUSRVP2
 new X,tiud0,tiud12,signer,cosigner
 new provduz,tiues
 set provduz=$$GET^XPAR("SYS","SAMI DEFAULT PROVIDER DUZ",,"Q")
 set tiud0=$get(^TIU(8925,+tiuda,0)),tiud12=$get(^TIU(8925,+tiuda,12))
 set signer=$piece(tiud12,U,4),cosigner=$piece(tiud12,U,8)
 set tiues=1_U_$$GET1^DIQ(200,+DUZ,20.2)_U_$$GET1^DIQ(200,+DUZ,20.3)
 new status set status=$piece(^TIU(8925,tiuda,0),"^",5)
 quit:'(status=5) 0
 do ES^TIURS(tiuda,tiues)
 set status=$piece(^TIU(8925,tiuda,0),"^",5)
 quit (status=7)
 quit
 ;
 ;@API-code: $$DELTIU^SAMIVSTA
 ;@called-by
 ;@calls
 ;  $$VISTSTR^SAMIVSTA
 ;  DELETE^TIUSRVP
 ;  DELETE^ORWPCE
 ;@input
 ;   tiuien = ien of note in 8925
 ;@output
 ;   0 = failure, 1 = successful
 ;@tests
 ;  UTDELTIU^SAMIUTVA
 ;  SAMIUTH3
 ; Delete an unsigned tiu note
DELTIU(tiuien) ;
 new Y set Y=0
 quit:'$g(tiuien) 0
 new ptdfn set ptdfn=$piece($get(^TIU(8925,tiuien,0)),"^",2)
 quit:'$get(ptdfn) 0  quit:'$data(^DPT(ptdfn)) 0
 new vstr set vstr=$$VISTSTR(tiuien)
 quit:'($length(vstr,";")=3) 0
 new SAMIPOO
 ; Delete the tiu note
 do DELETE^TIUSRVP(.SAMIPOO,tiuien)
 ; SAMIPOO successful if = 0
 quit:'($get(SAMIPOO)=0) 0
 do DELETE^ORWPCE(.SAMIPOO,vstr,ptdfn)
 quit:($g(Y)=-1) 0
 quit 1
 ;
 ;
 ;
 ;@API-code: $$UrbanRural^SAMIVSTA(zipcode)
 ;@called-by
 ;  SAMIRU
 ;  SAMIHOM3
 ;@calls
 ;  $$setroot^%wd
 ;  $$GET^XPAR
 ;@input
 ;  zip code
 ;@output
 ;   n = failure to find definition
 ;   r : 'rural' or u: 'urban' zip found in Graphstore
 ;@tests
 ;  UTURBR^SAMIUTVA
URBRUR(zipcode) ;
 if $get(zipcode)<501 quit "n"
 new root
 set root=$$setroot^%wd("NCHS Urban-Rural")
 quit:'$d(@root@("zip",+zipcode)) "n"
 new samiru,ruca30
 set ruca30=$$GET^XPAR("SYS","SAMI URBAN/RURAL INDEX VALUE",,"Q")
 set:'$get(ruca30) ruca30=1.1
 set samiru=@root@("zip",+zipcode)
 set samiru=$s(samiru>ruca30:"r",1:"u")
 quit samiru
 ;
 ;
 ;@API-code: $$KASAVE^SAMIVSTA
 ;@called-by
 ;@calls
 ;@input
 ;   tiuien   = ien of note in 8925
 ;   provider = duz of provider
 ;@output
 ;   0 = failure, 1 = successful
 ;@tests
 ;  UTKASAVE^SAMIUTVA
 ; Clear the "ASAVE" cross reference to prevent CPRS
 ;  call to prevent TIU WAS THIS SAVED? broker call 
 ;  returning error message
KASAVE(provider,tiuien) ;
 quit:'$get(tiuien) 0
 quit:'$get(provider) 0
 quit:'$d(^TIU(8925,tiuien)) 0
 kill ^TIU(8925,"ASAVE",provider,tiuien)
 quit 1
 ;
EOR ; End of routine SAMIVSTA
