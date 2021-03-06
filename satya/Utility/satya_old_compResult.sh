#!/bin/ksh 

. $PDIR/Utility/commonUtils.sh

. $PDIR/Utility/SystemConfig.dat
export finalResult="$serviceName/$serviceName.$customerName.log"
export cdrFromCAS=$1
export sippXMLResultFile=$PDIR/$serviceName/$2
export sippXMLStatusFile=$PDIR/$serviceName/SIPP_XML_Status.txt
export bugID=""


if [ "$serviceName" == "MPH" ]
then
	cdrLocalFile=$PDIR/$serviceName/XML-$customerName/$3/cdr.txt
else
	createSIPPDataFile $3.cdr.csv $customerName
	cdrLocalFile=$PDIR/$serviceName/Swap/$3.cdr.csv
fi


logger "in compResult: $cdrFromCAS, $sippXMLResultFile and $cdrLocalFile"

### set the CDR fields information for your service like ATF, VPN, E911 etc ###

atfFields_Axtel="SRVEND SERVICE_ID DATA_RECORD_ID SERVICE_BILLING_ID CALLING_PARTY CALLED_PARTY TERMINATE_NUMBER NULL NULL NULL NULL NULL DOW_ROUTING TOD_ROUTING PERCENTAGE_ROUTING CYCLIC_BASED_ROUTING CC_BASED_ROUTING GEO_ROUTING CALL_PROMPTER EN_ROUTE_ANN DOY_ROUTING DIALLED_NUMBER_DECISION COURTESY_RESPONSE NO_ANSWER NULL NULL NULL NULL ORIG_PC TERM_PC ACCESS_CODE ACTION_CODE CAUSE_CODE NULL CALL_Q_PARAM AC_CODE AUTH_CODE EXT_CODE PIN DIGITS CPC ROUTING_NUMBER LNP_INDICATOR CALL_TRF CALL_TRF_COR_ID CHARGE_INFO OTG DTG RELEASE_CAUSE DIRECTION_OF_REL P_CHARGE_INFO OLI MAX_CALL_DUR MAX_CALL_DUR_FLAG N_T_C A_T_C"


#atfFields="SRVEND SERVICE_ID DATA_RECORD_ID SERVICE_BILLING_ID CALLING_PARTY CALLED_PARTY TERMINATE_NUMBER NULL NULL NULL NULL NULL NUMBER_OF_TIMES_DoW_USED NUMBER_OF_TIMES_ToD_USED NUMBER_OF_TIMES_PERCENTAGE_ROUTING_USED NUMBER_OF_TIMES_CYCLIC_ROUTING_USED NUMBER_OF_TIMES_ORIGIN_BASED_ROUTING_USED NUMBER_OF_TIMES_IVR_MENU_ROUTING_USED NUMBER_OF_TIMES_ENROUTE_MSG_ROUTING_USED NUMBER_OF_TIMES_DoY_ROUTING_USED NUMBER_OF_TIMES_DIALED_PATTERN_ROUTING_USED NUMBER_OF_TIMES_COURTESY_MSG_ROUTING_USED NUMBER_OF_TIMES_ALTERNATE_ROUTING_USED CALL_QUEU_PARAMS NULL NULL NULL NULL ORIGIN_POINT_CODE ACCESS_CODE ACCOUNT_CODE AUTH_CODE EXTN_CODE PIN_CODE IVR_MENU_DIGITS CALLING_PARTY_CATEGORY ROUTING_NUMBER NUMBER_PORTABILITY_IND CALL_TRANSFERRED_IND CALL_TRANSFER_CORRELATION_ID P_CHARGE_VECTOR ORIG_TRUNK_GROUP DESTINATION_TRUNK_GROUP ACTION_CODE CAUSE_CODE RELEASE_CAUSE DIR_RELEASE NULL P_SIG_INFO OLI"

atfFields="SRVEND SERVICE_ID DATA_RECORD_ID SERVICE_BILLING_ID CALLING_PARTY CALLED_PARTY TERMINATE_NUMBER NULL NULL NULL NULL NULL NUMBER_OF_TIMES_DoW_USED NUMBER_OF_TIMES_ToD_USED NUMBER_OF_TIMES_PERCENTAGE_ROUTING_USED NUMBER_OF_TIMES_CYCLIC_ROUTING_USED NUMBER_OF_TIMES_ORIGIN_BASED_ROUTING_USED NUMBER_OF_TIMES_IVR_MENU_ROUTING_USED NUMBER_OF_TIMES_ENROUTE_MSG_ROUTING_USED NUMBER_OF_TIMES_DoY_ROUTING_USED NUMBER_OF_TIMES_DIALED_PATTERN_ROUTING_USED NUMBER_OF_TIMES_COURTESY_MSG_ROUTING_USED NUMBER_OF_TIMES_ALTERNATE_ROUTING_USED NULL NULL NULL NULL NULL ORIGIN_POINT_CODE ACCESS_CODE ACCOUNT_CODE AUTH_CODE EXTN_CODE PIN_CODE IVR_MENU_DIGITS CALLING_PARTY_CATEGORY ROUTING_NUMBER NUMBER_PORTABILITY_IND CALL_TRANSFERRED_IND CALL_TRANSFER_CORRELATION_ID P_CHARGE_VECTOR ORIG_TRUNK_GROUP DESTINATION_TRUNK_GROUP ACTION_CODE CAUSE_CODE RELEASE_CAUSE DIR_RELEASE NULL P_SIG_INFO OLI"

e911Fields="SRVEND VERSION_ID SERVICE_ID CALLED_PARTY PAI CALLING_PARTY ORIGIN_IP_ADDRESS NULL NULL NULL NULL TERMINATE_NUMBER REDIRECT_IP STATUS_CODE NULL NULL NULL GOVT_RESP_STATUS_CODE CODIGO MATCH_FOUND Reserved1 Reserved2 Reserved3 NULL"

acFields="SRVEND VERSION_ID SERVICE_ID DATA_RECORD_ID CALLED_PARTY PAI CHARGE_NUMBER OTG NULL NULL NULL NULL NULL NULL DESTINATION_NU NULL ACCOUNT_CODE CAUSE_CODE ACTION_CODE AC_VALIDATION_FLAG AC_CALL_STATUS SUB_ID COLLECTED_DIGITS REL_REASON_CODE PROTOCOL P-CHARGE-VECTOR E_M_I RN NPDI NULL NULL CALLING_Part_FROM"

cdivFields="Identifier Service_Id Data_Record_Id Called_Number Calling_Number NULL NULL NULL NULL NULL NULL Contractor_Number Redirecting_Number TMR NULL RedirectionCounterRx Subscriber_Status Type Group_ID Charge_Profile_ID ChargeProfileValues NULL NULL CV_Profile_ID Ann_Profile_ID CDIV_Features_Provisioned CDIV_Feature_Applied Translated_Calling_Number No_Answer_Timer Redirection_Number Redirection_Index RedirectionAnnFlag NumberNotificationFlag NULL NULL Delete_Digit_Num NULL NULL IVR_Played Call_chained Cause_Code Cause_Value Action_Code Service_Status Unavailable_Ann_Flag Out-of-range_Ann_Flag Redirection_No_Answer_Timer Group_Prefix Time_pattern_Group_Name Group_name Path_Switch_Signaling SubscribedPrefix RedirectionPrefix NULL NULL PathSwitchFlag PathSwitchDestinationNumber FT Flag Release Reason Code"

izziFields="SRVEND VERSION_ID SERVICE_ID CALLED_PARTY_NUMBER CALLING_PARTY_PAI CALLING_NUMBER_FROM NULL NULL NULL NULL NULL NULL NULL LIST_OF_TRANSALTED_NUMBERS_RETURNED_BY_LNP REQUEST_URI_FOR_LNP DESTINATION_ROUTING_NUMBER RELAESE_CAUSE DIGITS_ENTERED_BY_USER NULL DIRECTION_OF_RELEASE LOGICAL_CAUSE_CODE LNP_GATEWAY_ID IZZI_PREFIX_MATCHED"

#lnpFields="Identifier ServiceID Data_record_ID Calling_Party_Number Dialed_Number Physical_Destination Start_Time Month Date Time_Zone Call_Duration Originating_Call_Leg_ID Terminating_Call_Leg_ID Destination_Prefix Originating_Prefix Originating_IP_Address Terminating_IP_Address Originating_Point_Code Terminating_Point_Code Action_Code Cause_Code Auto_Correction_Flag Guidance_Setting_Flag"

lnpFields="Identifier ServiceID Data_record_ID Calling_Party_Number Dialed_Number Physical_Destination NULL NULL NULL NULL Call_Duration NULL NULL Destination_Prefix Originating_Prefix NULL NULL Originating_Point_Code Terminating_Point_Code Action_Code Cause_Code Auto_Correction_Flag Guidance_Setting_Flag"

bestellnpFields="ID VERSION SERVICE_ID CLUSTER_ID ENT_ID ENT_NAME CLG_PARTY_ID DIALED_NUM TRANSLATED_NUM NULL TIMEZONE_OFFSET CALL_DUR NULL TERM_PREFIX ORIG_PREFIX ACCESS_PREFIX ROUTING_INDEX ORIGIN_SIP_INFO ORIGIN_INAP_INFO IS_IVR_CALL CORRELATION_ID ACTION_CODE CAUSE_CODE FT_CALL_FLAG"

vpnFields="Identifier Version_ID Data_Record_ID Service_ID Calling_Party_VPN_A_User_Id Calling_Party_Number PN_of_Calling_Party_A NULL Dialed_number Charge_Number_of_Calling_party_A Type_of_Destination Called_Party_PNP_number Physical_Destination NULL NULL NULL NULL NULL NULL NULL VPN_Cause_Code Type_of_Calling-Party Type_of_VPN_Call_for_A_to_B_leg Number_of_IVR_interactions VPN_Release_Call_Cause_Code Cost_Center_of_Calling_Party_VPN-A Private_Call_indicator_for_VPN-A Call_Forwarding Initial_Called_Party_Number Private_Call_indicator_for_VPN-B Called_Party_VPN_B_User_Id PN_of_Called_Party_B Charge_Number_of_Called_Party_VPN-B Type_of_VPN_Call_for_B_to_C Cost_Center_of_Called_Party_VPN-B Country_Code_of_VPN-A Country_Code_of_VPN-B NULL NULL CUG_of_A_party CUG_of_B_party Dialed_Number_of_C_Party Charge_Number_of_C_party Routing_Number_of_C_party PNP_Number_of_C_party CC_Of_C_party Type_of_C_party Account_Code_of_Calling_Party_VPN-A Type_of_VPN_Call_from_A_to_C CUG_of_C_party Authorization_Code_of_Calling_Party_VPN-A Calling_Station_Identifier_for_VPN-A Calling_Station_Identifier_for_VPN-B NETWORK_TRANSACTION NULL NULL"

if [ "$serviceName" == "ATF" ] || [ "$serviceName" == "MPH" ]
then
	if [ "$customerName" == "Axtel" ]
	then
		set -A cdrFields $atfFields_Axtel
	else 	set -A cdrFields $atfFields
	fi
elif [ "$serviceName" == "AccountCode" ]
then
	set -A cdrFields $acFields
elif [ "$serviceName" == "CDIV" ]
then
	set -A cdrFields $cdivFields
elif [ "$serviceName" == "E911" ]
then
	set -A cdrFields $e911Fields
elif [ "$serviceName" == "VPN" ]
then
	set -A cdrFields $vpnFields
elif [ "$serviceName" == "IZZI" ]
then
        set -A cdrFields $izziFields
elif [ "$serviceName" == "BestelLNP" ]
then
        set -A cdrFields $bestellnpFields
else	set -A cdrFields $lnpFields

fi

export result="PASS"
export XMLResult=""

checkXMLStatus ()
{

 #   OUTGOING:A,ACTION:START,TESTCASEID:[$vTestCaseID],CALLID:[call_id] in $serviceName/SIPP_XML_Status.txt
 #   OUTGOING:A,ACTION:FINISHED,TESTCASEID:[$vTestCaseID],CALLID:[call_id] in $serviceName/SIPP_XML_Status.txt

	grep ":$1" $sippXMLStatusFile > tmpStatus

	cat tmpStatus | while read LINE; do
		xf1=`echo $LINE | cut -d "," -f1`
		xf2=`echo $xf1 | cut -d ":" -f2`
		xf3=`echo $LINE | cut -d "," -f2`
		xf4=`echo $xf3 | cut -d ":" -f2`
	
		XMLResult="$XMLResult $xf2=$xf4, "
		
	done
	
	start=`grep "START" tmpStatus | wc -l`
	finish=`grep "FINISHED" tmpStatus | wc -l`
	if [ "$start" == "$finish" ] && [ "$start" != 0 ]
	then
		result="PASS"
		XMLResult="Call Finished successfully at all SIPP agents : $XMLResult"
	else
		result="FAIL"
		XMLResult="Call NOT Finished properly at all SIPP agents  : $XMLResult"
	fi
}


parseCDR ()
{	
	IFS=","
	set -A newLine $1
	unset IFS
	### expected XML result file is TestCaseID:callID ###
	f1=`echo ${newLine[0]} | cut -d ":" -f2`
	c1=`echo ${newLine[1]} | cut -d ":" -f2`
	
	inc=`echo $c1| grep "@"`
	if [ "x$inc" != "x" ]
	then
		echo "this is INC calls"
		callID="$c1"
	else 	callID="$f1///$c1"
	fi

	logger "processing call ID: $callID"

	## initializing final result pass at start"
	result="PASS"
	XMLResult=""
	

	checkXMLStatus $c1
	delta="none"	
	if [ "$cdrFromCAS" != "OFF" ]
	then
			recordedCDR=`cat $cdrLocalFile | grep -w $f1`
			IFS=","
			set -A fileCDR $recordedCDR
			countA="${#fileCDR[@]}"

			cdrCASLine=`cat $cdrFromCAS | grep $callID`
			logger "CDR from CAS is $cdrCASLine"
			set -A cdr $cdrCASLine
			unset IFS
			countC="${#cdr[@]}"
			logger "total CDR fields = $countC"
			delta="none"

			if [ "$countC" == 0 ] 
			then
				echo "NOT ABLE TO GET CDR FROM CAS. PLEASE CHECK CDRs on CAS"
				logger "NOT ABLE TO GET CDR FROM CAS. PLEASE CHECK CDRs on CAS"
				delta="NOT ABLE TO GET CDR FROM CAS. PLEASE CHECK CDRs on CAS"
				result="FAIL"

			fi
			if [ "$countA" == 0 ] 
			then
				echo "NOT ABLE TO GET CDR FROM LOCAL. PLEASE CHECK CDRs FILE ON LOCAL"
				logger "NOT ABLE TO GET CDR FROM LOCAL. PLEASE CHECK CDRs FILE ON LOCAL"
				delta="NOT ABLE TO GET CDR FROM LOCAL. PLEASE CHECK CDRs FILE ON LOCAL"
				result="FAIL"

			fi

			printf "\n------------------- parsing CDR results for $callID ------------------\n"  >>  $reportFile 2>&1

			for (( i=1; i<$countA; i++ ))
			do

				if [ "${cdrFields[$i]}" != "NULL" ]
				then

					if [ "${fileCDR[$i]}" == "${cdr[$i]}" ] 
					then
						printf "%-50s = %-15s Vs       %-15s\n" ${cdrFields[$i]} ${cdr[$i]}  ${fileCDR[$i]} >> $reportFile 2>&1
					else  	
						printf "%-50s = %-15s Vs       %-15s		*** FAIL *** \n" ${cdrFields[$i]} ${cdr[$i]}  ${fileCDR[$i]}	 >>  $reportFile 2>&1
						result="FAIL"
						delta="${cdrFields[$i]} - ${cdr[$i]} - ${fileCDR[$i]}"	
					fi
				fi
			done
			#unset IFS
			printf "------------------- parsing CDR results for $callID: DONE ------------------\n"  >>  $reportFile 2>&1
				printf "TestCase:%-35s = %-10s\n" $callID $result >>  $finalResult 2>&1

	else
		cdrCASLine="CDR verification is turned OFF"
		delta="none"
	fi

	testCaseID=`echo $callID|cut -d "/" -f1 ` 
	id=$((id+1))
	
	fea=$2
	FEATURE_NAME=`echo $fea | tr '[:lower:]' '[:upper:]'`


	if [ "$result" == "FAIL" ] 
	then
		bugID=`grep "$testCaseID" $bugFileID | cut -d ":" -f2`
		if [ "$bugID" == "" ]
		then
			bugInfo="    New Test Case Failed"
		else	bugInfo="    BUGID=$bugID"
		fi
	fi
#	getBugID $testCaseID
#	bugID=$( getBugID $testCaseID )
#	getBugID $testCaseID
#	bugID=$?

	echo "<div style=display:none ><Testcase><FeatureName>$FEATURE_NAME</FeatureName><TestCaseID>T-$id:$testCaseID</TestCaseID><Description>$callID $bugInfo</Description><Result>$result</Result><Steps><Step id=0 status=Info>Actual CAS CDR: $cdrCASLine</Step><Step id=1 status=Info>Mismatch CDR Result: $delta</Step><Step id=2 status=Info>XML Files Result: $XMLResult</Step></Steps></Testcase></div>" >> $serviceName/$serviceName.$customerName.html
bugInfo=""
bugID=""

}

export reportFile="$serviceName/detailCDR.$customerName.$3.log"
export testCaseID=""
export id=0
egrep -v "^#|^[ ]*$" $sippXMLResultFile | while read LINE ; do
	parseCDR $LINE $3
done

#echo "going to check release version info"
#echo "getReleaseVersionInfo $serviceName $customerName"
#getReleaseVersionInfo $serviceName $customerName

#echo "exit from release version info"


