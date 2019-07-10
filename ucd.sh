version='${p:Run SVN Export Script and Identify Version/currentRunVersion}'
ucd_command='${p:AGENT_HOME}/opt/udclient/udclient -username sv_ubc -authtoken dbafa318-8639-4992-8760-114cd58bd840 -weburl https://lnapp039a:8443'

echo "-----------------------"
echo "Create json file to request application Process"
echo "-----------------------"

cat << EOF > $version.json
{
  "application": "${p:application_name}",
  "description": "Requesting deployment",
  "applicationProcess": "${p:applicationProcess_name}",
  "environment": "${p:environment_name}",
  "onlyChanged": "false",
 
  "versions": [
    {
      "version": "$version",
      "component": "${p:comp_name}"
    }
  ]
}
EOF

echo "-----------------------"
echo "Json file contnet"
echo "-----------------------"
cat $version.json

echo "-----------------------"
echo "Run Application Process"
echo "-----------------------"
$ucd_command requestApplicationProcess $version.json > /tmp/request_$version.json
 

 Request_ID=(`cat /tmp/request_$version.json | python -mjson.tool | grep -Po '(?<="requestId": ")[^"]*'`)
 for (( j = 1 ; j >= 1; j++ ))
 do
	k=(`$ucd_command getApplicationProcessRequestStatus -request $Request_ID | python -mjson.tool | grep -Po '(?<="result": ")[^"]*'`)
		if [ "${k[0]}" != "NONE" ] ; then
			if [ "${k[0]}" == "FAULTED" ] ; then
                   
			echo "================================================="
			echo "File movement process has been FAULTED"
			echo "Link to File Movement Process: https://lnapp039a.hphc.org:8443/#applicationProcessRequest/$Request_ID"
			echo "================================================="
			exit 1
			fi
		echo "================================================="
		echo "File movement process has been SUCCEEDED "
		echo "Link to File Movement Process: https://lnapp039a.hphc.org:8443/#applicationProcessRequest/$Request_ID"
		echo "================================================="
		
		break
		fi
 done
 
$ucd_command addVersionLink -component ${p:comp_name} -version $version -linkName "Link to File Movement Log" -link "https://lnapp039a.hphc.org:8443/#applicationProcessRequest/$Request_ID"