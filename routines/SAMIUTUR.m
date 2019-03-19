SAMIUTUR ;ven/lgc - UNIT TEST for SAMIUR,SAMIUR1,SAMIUR2 ; 3/18/19 2:21pm
 ;;18.0;SAMI;;
 ;
 ;@license: see routine SAMIUL
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
 ; @to-do
 ;
 ; @section 1 code
 ;
START i $t(^%ut)="" w !,"*** UNIT TEST NOT INSTALLED ***" q
 d EN^%ut($t(+0),2)
 q
 ;
 ;
STARTUP n utsuccess
 n root s root=$$setroot^%wd("vapals-patients")
 k @root@("graph","XXX00001")
 n SAMIUPOO D PLUTARR^SAMIUTST(.SAMIUPOO,"all XXX00001 forms")
 m @root@("graph","XXX00001")=SAMIUPOO
 ; Temporarily update sidc field in siform-2018-11-13 
 s @root@("graph","XXX00001","siform-2018-11-13","sidc")=$P($$HTE^XLFDT($H,5),"@")
 q
 ;
SHUTDOWN ; ZEXCEPT: utsuccess
 k utsuccess
 ; Replace sidc field in siform-2018-11-13
 n root s root=$$setroot^%wd("vapals-patients")
 s @root@("graph","XXX00001","siform-2018-11-13","sidc")="11/13/2018"
 k root
 q
 ;
 ;
UTQUIT ; @TEST - Quit at top of routine
 D ^SAMIUR
 d SUCCEED^%ut
 D ^SAMIUR2
 d SUCCEED^%ut
 q
 ;
UTWSRPT ; @TEST - generate a report based on parameters in filter
 ;wsReport(rtn,SAMIUFLTR)
 n rpttstr
 ;
 n SAMIUFLTR,pats,SAMIUPOO,cnt,root
 s SAMIUFLTR("samireporttype")="followup"
 s rpttstr="<input name=""samireporttype"" type=""hidden"" value=""followup""/>"
 s utsuccess=0
 d WSREPORT^SAMIUR(.SAMIUPOO,.SAMIUFLTR)
 s cnt=0 f  s cnt=$o(SAMIUPOO(cnt)) q:'cnt  i SAMIUPOO(cnt)[rpttstr s utsuccess=1
 d CHKEQ^%ut(utsuccess,1,"Testing wsReport for followup FAILED!")
 ;
 k SAMIUFLTR,SAMIUPOO
 s SAMIUFLTR("samireporttype")="activity"
 s rpttstr="<input name=""samireporttype"" type=""hidden"" value=""activity""/>"
 s utsuccess=0
 d WSREPORT^SAMIUR(.SAMIUPOO,.SAMIUFLTR)
 s cnt=0 f  s cnt=$o(SAMIUPOO(cnt)) q:'cnt  i SAMIUPOO(cnt)[rpttstr s utsuccess=1
 d CHKEQ^%ut(utsuccess,1,"Testing wsReport for activity FAILED!")
 ;
 k SAMIUFLTR
 s SAMIUFLTR("samireporttype")="enrollment"
 s rpttstr="<input name=""samireporttype"" type=""hidden"" value=""enrollment""/>"
 s utsuccess=0
 d WSREPORT^SAMIUR(.SAMIUPOO,.SAMIUFLTR)
 s cnt=0 f  s cnt=$o(SAMIUPOO(cnt)) q:'cnt  i SAMIUPOO(cnt)[rpttstr s utsuccess=1
 d CHKEQ^%ut(utsuccess,1,"Testing wsReport for enrollment FAILED!")
 ;
 k SAMIUFLTR
 s SAMIUFLTR("samireporttype")="missingct"
 s rpttstr="<input name=""samireporttype"" type=""hidden"" value=""missingct""/>"
 s utsuccess=1
 d WSREPORT^SAMIUR(.SAMIUPOO,.SAMIUFLTR)
 s cnt=0 f  s cnt=$o(SAMIUPOO(cnt)) q:'cnt  i SAMIUPOO(cnt)[rpttstr s utsuccess=1
 d CHKEQ^%ut(utsuccess,1,"Testing wsReport for enrollment FAILED!")
 ;
 k SAMIUFLTR
 s SAMIUFLTR("samireporttype")="incomplete"
 s rpttstr="<input name=""samireporttype"" type=""hidden"" value=""incomplete""/>"
 s utsuccess=1
 d WSREPORT^SAMIUR(.SAMIUPOO,.SAMIUFLTR)
 s cnt=0 f  s cnt=$o(SAMIUPOO(cnt)) q:'cnt  i SAMIUPOO(cnt)[rpttstr s utsuccess=1
 d CHKEQ^%ut(utsuccess,1,"Testing wsReport for enrollment FAILED!")
 ;
 k SAMIUFLTR
 s SAMIUFLTR("samireporttype")="outreach"
 s SAMIUFLTR("debug")=1
 s rpttstr="<input name=""samireporttype"" type=""hidden"" value=""outreach""/>"
 s utsuccess=1
 d WSREPORT^SAMIUR(.SAMIUPOO,.SAMIUFLTR)
 s cnt=0 f  s cnt=$o(SAMIUPOO(cnt)) q:'cnt  i SAMIUPOO(cnt)[rpttstr s utsuccess=1
 d CHKEQ^%ut(utsuccess,1,"Testing wsReport for enrollment FAILED!")
 q
 ;
UTSELCT ; @TEST - selects patient for the report
 ;select(pats,type)
 n SAMIUPATS,SAMITYPE,SAMIUDPHR,unplus30,unminus30,unowdate,udtphrase,SAMIUPOO
 n root s root=$$setroot^%wd("vapals-patients")
 ;
 s unplus30=$P($$FMTE^XLFDT($$FMADD^XLFDT($$HTFM^XLFDT($H),31),5),"@")
 s unminus30=$P($$FMTE^XLFDT($$FMADD^XLFDT($$HTFM^XLFDT($H),-31),5),"@")
 s unowdate=$P($$FMTE^XLFDT($$HTFM^XLFDT($H),5),"@")
 ;
 s SAMITYPE="",SAMIUDPHR=""
 s udtphrase=" as of "_unowdate
 d SELECT^SAMIUR(.SAMIUPATS,SAMITYPE,.SAMIUDPHR)
 s utsuccess=(SAMIUDPHR=udtphrase)
 i utsuccess,$d(SAMIUPATS) d
 . n node,cnt s node=$na(SAMIUPATS),cnt=0
 . f  s node=$q(@node) q:node=""  d
 .. s:cnt<3 cnt=cnt+1
 .. i cnt=1,'(@node="") s utsuccess=0 q
 .. i cnt=2,'($qs(node,3)="cefud") s utsuccess=0 q
 .. i cnt=3 s cnt=0 i '($qs(node,3)="edate") s utsuccess=0 q
 d CHKEQ^%ut(utsuccess,1,"Testing type=null patient report FAILED!")
 ;
 k SAMIUPATS
 s SAMITYPE="followup",SAMIUDPHR=""
 s udtphrase=" before "_unplus30
 d SELECT^SAMIUR1(.SAMIUPATS,SAMITYPE,.SAMIUDPHR)
 s utsuccess=(SAMIUDPHR=udtphrase)
 i utsuccess,$d(pats) d
 . n node,cnt s node=$na(pats),cnt=0
 . f  s node=$q(@node) q:node=""  d  q:'utsuccess
 .. s:cnt<3 cnt=cnt+1
 .. i cnt=1,'(@node="") s utsuccess=0 q
 .. i cnt=2,'($qs(node,3)="cefud") s utsuccess=0 q
 .. i cnt=3 s cnt=0 i '($qs(node,3)="edate") s utsuccess=0
 d CHKEQ^%ut(utsuccess,1,"Testing followup patient report FAILED!")
 ;
 k SAMIUPATS
 s SAMITYPE="activity",SAMIUDPHR=""
 s udtphrase=" after "_unminus30
 d SELECT^SAMIUR(.SAMIUPATS,SAMITYPE,.SAMIUDPHR)
 s utsuccess=(SAMIUDPHR=udtphrase)
 i utsuccess,$d(pats) d
 . n node,cnt s node=$na(pats),cnt=0
 . f  s node=$q(@node) q:node=""  d  q:'utsuccess
 .. s:cnt<3 cnt=cnt+1
 .. i cnt=1,'(@node="") s utsuccess=0 q
 .. i cnt=2,'($qs(node,3)="cefud") s utsuccess=0 q
 .. i cnt=3 s cnt=0 i '($qs(node,3)="edate") s utsuccess=0
 d CHKEQ^%ut(utsuccess,1,"Testing activity patient report FAILED!")
 ;
 k SAMIUPATS
 s SAMITYPE="enrollment",SAMIUDPHR=""
 s udtphrase=" as of "_unowdate
 d SELECT^SAMIUR(.SAMIUPATS,SAMITYPE,.SAMIUDPHR)
 s utsuccess=(SAMIUDPHR=udtphrase)
 i utsuccess,$d(pats) d
 . n node,cnt s node=$na(pats),cnt=0
 . f  s node=$q(@node) q:node=""  d  q:'utsuccess
 .. s:cnt<3 cnt=cnt+1
 .. i cnt=1,'(@node="") s utsuccess=0 q
 .. i cnt=2,'($qs(node,3)="cefud") s utsuccess=0 q
 .. i cnt=3 s cnt=0 i '($qs(node,3)="edate") s utsuccess=0
 d CHKEQ^%ut(utsuccess,1,"Testing enrollment patient report FAILED!")
 ;
 k SAMIUPATS
 s SAMITYPE="missingct",SAMIUDPHR=""
 d SELECT^SAMIUR(.SAMIUPATS,SAMITYPE,.SAMIUDPHR)
 s utsuccess=($g(SAMIUDPHR)="")
 d CHKEQ^%ut(utsuccess,1,"Testing missingct patient report FAILED!")
 ;
 k SAMIUPATS
 s SAMITYPE="incomplete",SAMIUDPHR=""
 d SELECT^SAMIUR(.SAMIUPATS,SAMITYPE,.SAMIUDPHR)
 s utsuccess=($g(SAMIUDPHR)="")
 d CHKEQ^%ut(utsuccess,1,"Testing incomplete patient report FAILED!")
 ;
 k SAMIUPATS
 s SAMITYPE="outreach",SAMIUDPHR=""
 d SELECT^SAMIUR(.SAMIUPATS,SAMITYPE,.SAMIUDPHR)
 s utsuccess=($g(SAMIUDPHR)="")
 d CHKEQ^%ut(utsuccess,1,"Testing outreach patient report FAILED!")
 q
 ;
UTPNAME ; @TEST - extrinsic returns the PAGE NAME for the report
 ;PNAME(type)
 n str
 s str=$$PNAME^SAMIUR("followup","-test text")
 s utsuccess=(str="Followup next 30 days --test text")
 d CHKEQ^%ut(utsuccess,1,"Testing extrinsic returns followup PAGE NAME FAILED!")
 ;
 s str=$$PNAME^SAMIUR("activity","-test text")
 s utsuccess=(str="Activity last 30 days --test text")
 d CHKEQ^%ut(utsuccess,1,"Testing extrinsic returns activity PAGE NAME FAILED!")
 ;
 s str=$$PNAME^SAMIUR("missingct","-test text")
 s utsuccess=(str="Intake but no CT Evaluation-test text")
 d CHKEQ^%ut(utsuccess,1,"Testing extrinsic returns missingct PAGE NAME FAILED!")
 ;
 s str=$$PNAME^SAMIUR("incomplete","-test text")
 s utsuccess=(str="Incomplete Forms-test text")
 d CHKEQ^%ut(utsuccess,1,"Testing extrinsic returns incomplete PAGE NAME FAILED!")
 ;
 s str=$$PNAME^SAMIUR("outreach","-test text")
 s utsuccess=(str="Outreach-test text")
 d CHKEQ^%ut(utsuccess,1,"Testing extrinsic returns outreach PAGE NAME FAILED!")
 ;
 s str=$$PNAME^SAMIUR("enrollment","-test text")
 s utsuccess=(str="Enrollment-test text")
 d CHKEQ^%ut(utsuccess,1,"Testing extrinsic returns enrollment PAGE NAME FAILED!")
 ;
 s str=$$PNAME^SAMIUR("XXX","-test text")
 s utsuccess=(str="")
 d CHKEQ^%ut(utsuccess,1,"Testing extrinsic returns XXX PAGE NAME FAILED!")
 q
 ;
 ;
EOR ;End of routine SAMIUTUR
