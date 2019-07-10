#!/bin/bash

ls > /tmp/zipfilenames_$(basename `pwd`).txt
sed -i 's/.zip//g' /tmp/zipfilenames_$(basename `pwd`).txt
echo "Input commit messages are : "
cat  /tmp/zipfilenames_$(basename `pwd`).txt
# Creating a loop for processing each package
while IFS='' read -r zipname <&3 || [[ -n "$zipname" ]]; do 

	unzip -l $zipname.zip > zipcontent_$zipname.txt
	echo "Executing the file movement for commit message : $zipname "
	unzip $zipname.zip
	cd $zipname/
	awk '{print $4}' ../zipcontent_$zipname.txt > ../zipcontent1_$zipname.txt
	sed -i 's/'$zipname'//g' ../zipcontent1_$zipname.txt
	#grep -n "/*\." ../zipcontent1_$zipname.txt | awk -F  ":" '{print $2}' > ../zipcontent2_$zipname.txt
	while IFS='' read -r file_full_path <&3 || [[ -n "$file_full_path" ]]; do
        file_name=`echo ${file_full_path##*/}`
        if test !  -f $file_name;
        then
                echo $file_full_path >> ../zipcontent1_1_$zipname.txt
        fi
	done 3< "../zipcontent1_$zipname.txt"
	tail -n +3 ../zipcontent1_1_$zipname.txt > ../zipcontent2_$zipname.txt
	sed -i 's/\/[^\/]*$//' ../zipcontent2_$zipname.txt
	sort ../zipcontent2_$zipname.txt | uniq > ../zipcontent3_$zipname.txt
	sed -i '/^\s*$/d' ../zipcontent3_$zipname.txt
	
	while IFS='' read -r line <&3 || [[ -n "$line" ]]; do
			echo "Text read from file: $line"
			server_path=`grep -m1 $line/= ${p:environment/Scripts_path}/${p:environment/target_location_property} | cut -d "=" -f2`
			echo `pwd`
			echo "Performing dos2unix conversion"
			${p:environment/Scripts_path}/dos2unix .$line/*
			file_type=`grep -m1 $line/= ${p:environment/Scripts_path}/${p:environment/target_location_property} | cut -d "=" -f3`
			echo "File group is $file_type"
            if [ "$file_type" = "dstage" ];
			then 
				echo "Copying $zipname commit message content to $server_path on `hostname`"
				ls .$line/ > ../folder_content.txt
				${p:environment/Scripts_path}/dos2unix ../folder_content.txt
				while IFS='' read -r file_name <&3 || [[ -n "$file_name" ]]; do
				echo "Copying .$line/$file_name to location $server_path "
				source_path=$(echo -e `pwd`)
				pbrun cp -p -f $source_path$line/$file_name $server_path
				pbrun chgrp $file_type $server_path$file_name
				chmod 554 $server_path$file_name
				done 3< "../folder_content.txt"
			elif [ "$file_type" = "teradata" ];
			then 
				echo "Copying $zipname commit message content to $server_path on `hostname`"
				ls .$line/ > ../folder_content.txt
				${p:environment/Scripts_path}/dos2unix ../folder_content.txt
				while IFS='' read -r file_name <&3 || [[ -n "$file_name" ]]; do
				echo "Copying .$line/$file_name to location $server_path "
				source_path=$(echo -e `pwd`)
				pbrun cp -p -f $source_path$line/$file_name $server_path
				pbrun chgrp $file_type $server_path$file_name
				chmod 554 $server_path$file_name
				done 3< "../folder_content.txt"
			elif [ "$file_type" = "autosys_users" ];
			then 
				echo "Copying $zipname commit message content to $server_path on `hostname`"
				ls .$line/ > ../folder_content.txt
				${p:environment/Scripts_path}/dos2unix ../folder_content.txt
				while IFS='' read -r file_name <&3 || [[ -n "$file_name" ]]; do
				echo "Copying .$line/$file_name to location $server_path "
				source_path=$(echo -e `pwd`)
				pbrun cp -p -f $source_path$line/$file_name $server_path
				pbrun chgrp $file_type $server_path$file_name
				chmod 774 $server_path$file_name
				done 3< "../folder_content.txt"
			elif [ "$file_type" = "dba" ];
			then 
				echo "Copying $zipname commit message content to $server_path on `hostname`"
				ls .$line/ > ../folder_content.txt
				${p:environment/Scripts_path}/dos2unix ../folder_content.txt
				while IFS='' read -r file_name <&3 || [[ -n "$file_name" ]]; do
				echo "Copying .$line/$file_name to location $server_path "
				source_path=$(echo -e `pwd`)
				pbrun cp -p -f $source_path$line/$file_name $server_path
				pbrun chgrp $file_type $server_path$file_name
				chmod 554 $server_path$file_name
				done 3< "../folder_content.txt"
			elif [ "$file_type" = "enb" ];
			then 
				echo "Copying $zipname commit message content to $server_path on `hostname`"
				ls .$line/ > ../folder_content.txt
				${p:environment/Scripts_path}/dos2unix ../folder_content.txt
				file_own=`grep -m1 $line/= ${p:environment/Scripts_path}${p:environment/target_location_property} | cut -d "=" -f4`
				while IFS='' read -r file_name <&3 || [[ -n "$file_name" ]]; do
					k=`echo $file_name | cut -d '.' -f2`
					echo $k
					if [ "$k" = "sh" ];
					then 
						echo "Copying .$line/$file_name to location $server_path "
						source_path=$(echo -e `pwd`)
						pbrun cp -p -f $source_path$line/$file_name $server_path
						pbrun chgrp $file_type $server_path$file_name
						pbrun chown $file_own $server_path$file_name
						pbrun chmod 554 $server_path$file_name
					fi
				done 3< "../folder_content.txt"
			elif [ "$file_type" = "fin" ];
			then 
				echo "Copying $zipname commit message content to $server_path on `hostname`"
				ls .$line/ > ../folder_content.txt
				${p:environment/Scripts_path}/dos2unix ../folder_content.txt
				file_own=`grep -m1 $line/= ${p:environment/Scripts_path}${p:environment/target_location_property} | cut -d "=" -f4`
				while IFS='' read -r file_name <&3 || [[ -n "$file_name" ]]; do
				echo "Copying .$line/$file_name to location $server_path "
				source_path=$(echo -e `pwd`)
				pbrun cp -p -f $source_path$line/$file_name $server_path
				pbrun chgrp $file_type $server_path$file_name
				pbrun chown $file_own $server_path$file_name
				pbrun chmod 554 $server_path$file_name
				done 3< "../folder_content.txt"
			elif [ "$file_type" = "ecare_admins" ];
			then 
				echo "Copying $zipname commit message content to $server_path on `hostname`"
				ls .$line/ > ../folder_content.txt
				${p:environment/Scripts_path}/dos2unix ../folder_content.txt
				file_own=`grep -m1 $line/= ${p:environment/Scripts_path}${p:environment/target_location_property} | cut -d "=" -f4`
				
				while IFS='' read -r file_name <&3 || [[ -n "$file_name" ]]; do
				echo "Copying .$line/$file_name to location $server_path "
				source_path=$(echo -e `pwd`)
				pbrun cp -p -f $source_path$line/$file_name $server_path
				pbrun chgrp $file_type $server_path$file_name
				pbrun chown $file_own $server_path$file_name
				pbrun chmod 554 $server_path$file_name
				done 3< "../folder_content.txt"
			elif [ "$file_type" = "etl" ];
			then 
				echo "Copying $zipname commit message content to $server_path on `hostname`"
				ls .$line/ > ../folder_content.txt
				${p:environment/Scripts_path}/dos2unix ../folder_content.txt
				file_own=`grep -m1 $line/= ${p:environment/Scripts_path}${p:environment/target_location_property} | cut -d "=" -f4`
				
				while IFS='' read -r file_name <&3 || [[ -n "$file_name" ]]; do
				echo "Copying .$line/$file_name to location $server_path "
				source_path=$(echo -e `pwd`)
				pbrun cp -p -f $source_path$line/$file_name $server_path
				pbrun chgrp $file_type $server_path$file_name
				pbrun chown $file_own $server_path$file_name
				pbrun chmod 554 $server_path$file_name
				done 3< "../folder_content.txt"
			elif [ "$file_type" = "opfrmwkusr" ];
			then 
				echo "Copying $zipname commit message content to $server_path on `hostname`"
				ls .$line/ > ../folder_content.txt
				${p:environment/Scripts_path}/dos2unix ../folder_content.txt
				file_own=`grep -m1 $line/= ${p:environment/Scripts_path}${p:environment/target_location_property} | cut -d "=" -f4`
				
				while IFS='' read -r file_name <&3 || [[ -n "$file_name" ]]; do
				echo "Copying .$line/$file_name to location $server_path "
				source_path=$(echo -e `pwd`)
				pbrun cp -p -f $source_path$line/$file_name $server_path
				pbrun chgrp $file_type $server_path$file_name
				pbrun chown $file_own $server_path$file_name
				pbrun chmod 554 $server_path$file_name
				done 3< "../folder_content.txt"
			elif [ "$file_type" = "opohieopusr" ];
			then 
				echo "Copying $zipname commit message content to $server_path on `hostname`"
				ls .$line/ > ../folder_content.txt
				${p:environment/Scripts_path}/dos2unix ../folder_content.txt
				file_own=`grep -m1 $line/= ${p:environment/Scripts_path}${p:environment/target_location_property} | cut -d "=" -f4`
				
				while IFS='' read -r file_name <&3 || [[ -n "$file_name" ]]; do
				echo "Copying .$line/$file_name to location $server_path "
				source_path=$(echo -e `pwd`)
				pbrun cp -p -f $source_path$line/$file_name $server_path
				pbrun chgrp $file_type $server_path$file_name
				pbrun chown $file_own $server_path$file_name
				pbrun chmod 554 $server_path$file_name
				done 3< "../folder_content.txt"
			elif [ "$file_type" = "otohieopusr" ];
			then 
				echo "Copying $zipname commit message content to $server_path on `hostname`"
				ls .$line/ > ../folder_content.txt
				${p:environment/Scripts_path}/dos2unix ../folder_content.txt
				file_own=`grep -m1 $line/= ${p:environment/Scripts_path}${p:environment/target_location_property} | cut -d "=" -f4`
				
				while IFS='' read -r file_name <&3 || [[ -n "$file_name" ]]; do
				echo "Copying .$line/$file_name to location $server_path "
				source_path=$(echo -e `pwd`)
				pbrun cp -p -f $source_path$line/$file_name $server_path
				pbrun chgrp $file_type $server_path$file_name
				pbrun chown $file_own $server_path$file_name
				pbrun chmod 554 $server_path$file_name
				done 3< "../folder_content.txt"
			elif [ "$file_type" = "ediadmin" ];
			then 
				echo "Copying $zipname commit message content to $server_path on `hostname`"
				ls .$line/ > ../folder_content.txt
				${p:environment/Scripts_path}/dos2unix ../folder_content.txt
				file_own=`grep -m1 $line/= ${p:environment/Scripts_path}${p:environment/target_location_property} | cut -d "=" -f4`
				
				while IFS='' read -r file_name <&3 || [[ -n "$file_name" ]]; do
				echo "Copying .$line/$file_name to location $server_path "
				source_path=$(echo -e `pwd`)
				pbrun cp -p -f $source_path$line/$file_name $server_path
				pbrun chgrp $file_type $server_path$file_name
				pbrun chown $file_own $server_path$file_name
				pbrun chmod 554 $server_path$file_name
				done 3< "../folder_content.txt"
			elif [ "$file_type" = "npi" ];
			then 
				echo "Copying $zipname commit message content to $server_path on `hostname`"
				ls .$line/ > ../folder_content.txt
				${p:environment/Scripts_path}/dos2unix ../folder_content.txt
				file_own=`grep -m1 $line/= ${p:environment/Scripts_path}${p:environment/target_location_property} | cut -d "=" -f4`
				
				while IFS='' read -r file_name <&3 || [[ -n "$file_name" ]]; do
				echo "Copying .$line/$file_name to location $server_path "
				source_path=$(echo -e `pwd`)
				pbrun cp -p -f $source_path$line/$file_name $server_path
				pbrun chgrp $file_type $server_path$file_name
				pbrun chown $file_own $server_path$file_name
				pbrun chmod 554 $server_path$file_name
				done 3< "../folder_content.txt"
			elif [ "$file_type" = "imgtrk" ];
			then 
				echo "Copying $zipname commit message content to $server_path on `hostname`"
				ls .$line/ > ../folder_content.txt
				${p:environment/Scripts_path}/dos2unix ../folder_content.txt
				file_own=`grep -m1 $line/= ${p:environment/Scripts_path}${p:environment/target_location_property} | cut -d "=" -f4`
				
				while IFS='' read -r file_name <&3 || [[ -n "$file_name" ]]; do
				echo "Copying .$line/$file_name to location $server_path "
				source_path=$(echo -e `pwd`)
				pbrun cp -p -f $source_path$line/$file_name $server_path
				pbrun chgrp $file_type $server_path$file_name
				pbrun chown $file_own $server_path$file_name
				pbrun chmod 554 $server_path$file_name
				done 3< "../folder_content.txt"
			elif [ "$file_type" = "opocsausr" ];
			then 
				echo "Copying $zipname commit message content to $server_path on `hostname`"
				ls .$line/ > ../folder_content.txt
				${p:environment/Scripts_path}/dos2unix ../folder_content.txt
				file_own=`grep -m1 $line/= ${p:environment/Scripts_path}${p:environment/target_location_property} | cut -d "=" -f4`
				
				while IFS='' read -r file_name <&3 || [[ -n "$file_name" ]]; do
				echo "Copying .$line/$file_name to location $server_path "
				source_path=$(echo -e `pwd`)
				pbrun cp -p -f $source_path$line/$file_name $server_path
				pbrun chgrp $file_type $server_path$file_name
				pbrun chown $file_own $server_path$file_name
				pbrun chmod 554 $server_path$file_name
				done 3< "../folder_content.txt"
			elif [ "$file_type" = "ohi_developers" ];
			then 
				echo "Copying $zipname commit message content to $server_path on `hostname`"
				ls .$line/ > ../folder_content.txt
				${p:environment/Scripts_path}/dos2unix ../folder_content.txt
				file_own=`grep -m1 $line/= ${p:environment/Scripts_path}${p:environment/target_location_property} | cut -d "=" -f4`
				
				while IFS='' read -r file_name <&3 || [[ -n "$file_name" ]]; do
				echo "Copying .$line/$file_name to location $server_path "
				source_path=$(echo -e `pwd`)
				pbrun cp -p -f $source_path$line/$file_name $server_path
				pbrun chgrp $file_type $server_path$file_name
				pbrun chown $file_own $server_path$file_name
				pbrun chmod 554 $server_path$file_name
				done 3< "../folder_content.txt"
			elif [ "$file_type" = "ndmgroup" ];
			then 
				echo "Copying $zipname commit message content to $server_path on `hostname`"
				ls .$line/ > ../folder_content.txt
				${p:environment/Scripts_path}/dos2unix ../folder_content.txt
				file_own=`grep -m1 $line/= ${p:environment/Scripts_path}${p:environment/target_location_property} | cut -d "=" -f4`
				
				while IFS='' read -r file_name <&3 || [[ -n "$file_name" ]]; do
				echo "Copying .$line/$file_name to location $server_path "
				source_path=$(echo -e `pwd`)
				pbrun cp -p -f $source_path$line/$file_name $server_path
				pbrun chgrp $file_type $server_path$file_name
				pbrun chown $file_own $server_path$file_name
				pbrun chmod 554 $server_path$file_name
				done 3< "../folder_content.txt"
			elif [ "$file_type" = "otocsausr" ];
			then 
				echo "Copying $zipname commit message content to $server_path on `hostname`"
				ls .$line/ > ../folder_content.txt
				${p:environment/Scripts_path}/dos2unix ../folder_content.txt
				file_own=`grep -m1 $line/= ${p:environment/Scripts_path}${p:environment/target_location_property} | cut -d "=" -f4`
				
				while IFS='' read -r file_name <&3 || [[ -n "$file_name" ]]; do
				echo "Copying .$line/$file_name to location $server_path "
				source_path=$(echo -e `pwd`)
				pbrun cp -p -f $source_path$line/$file_name $server_path
				pbrun chgrp $file_type $server_path$file_name
				pbrun chown $file_own $server_path$file_name
				pbrun chmod 554 $server_path$file_name
				done 3< "../folder_content.txt"
			elif [ "$file_type" = "amsadmins" ];
			then 
				echo "Copying $zipname commit message content to $server_path on `hostname`"
				ls .$line/ > ../folder_content.txt
				${p:environment/Scripts_path}/dos2unix ../folder_content.txt
				file_own=`grep -m1 $line/= ${p:environment/Scripts_path}${p:environment/target_location_property} | cut -d "=" -f4`
				
				while IFS='' read -r file_name <&3 || [[ -n "$file_name" ]]; do
				echo "Copying .$line/$file_name to location $server_path "
				source_path=$(echo -e `pwd`)
				pbrun cp -p -f $source_path$line/$file_name $server_path
				pbrun chgrp $file_type $server_path$file_name
				pbrun chown $file_own $server_path$file_name
				pbrun chmod 554 $server_path$file_name
				done 3< "../folder_content.txt"
				elif [ "$file_type" = "behlth" ];
			then 
				echo "Copying $zipname commit message content to $server_path on `hostname`"
				ls .$line/ > ../folder_content.txt
				${p:environment/Scripts_path}/dos2unix ../folder_content.txt
				file_own=`grep -m1 $line/= ${p:environment/Scripts_path}${p:environment/target_location_property} | cut -d "=" -f4`
				
				while IFS='' read -r file_name <&3 || [[ -n "$file_name" ]]; do
				echo "Copying .$line/$file_name to location $server_path "
				source_path=$(echo -e `pwd`)
				pbrun cp -p -f $source_path$line/$file_name $server_path
				pbrun chgrp $file_type $server_path$file_name
				pbrun chown $file_own $server_path$file_name
				pbrun chmod 554 $server_path$file_name
				done 3< "../folder_content.txt"
			elif [ "$file_type" = "stg" ];
			then 
				echo "Copying $zipname commit message content to $server_path on `hostname`"
				ls .$line/ > ../folder_content.txt
				${p:environment/Scripts_path}/dos2unix ../folder_content.txt
				file_own=`grep -m1 $line/= ${p:environment/Scripts_path}${p:environment/target_location_property} | cut -d "=" -f4`
				
				while IFS='' read -r file_name <&3 || [[ -n "$file_name" ]]; do
				echo "Copying .$line/$file_name to location $server_path "
				source_path=$(echo -e `pwd`)
				pbrun cp -p -f $source_path$line/$file_name $server_path
				pbrun chgrp $file_type $server_path$file_name
				pbrun chown $file_own $server_path$file_name
				pbrun chmod 554 $server_path$file_name
				done 3< "../folder_content.txt"
			elif [ "$file_type" = "amsadmins" ];
			then 
				echo "Copying $zipname commit message content to $server_path on `hostname`"
				ls .$line/ > ../folder_content.txt
				${p:environment/Scripts_path}/dos2unix ../folder_content.txt
				file_own=`grep -m1 $line/= ${p:environment/Scripts_path}${p:environment/target_location_property} | cut -d "=" -f4`
				
				while IFS='' read -r file_name <&3 || [[ -n "$file_name" ]]; do
				echo "Copying .$line/$file_name to location $server_path "
				source_path=$(echo -e `pwd`)
				pbrun cp -p -f $source_path$line/$file_name $server_path
				pbrun chgrp $file_type $server_path$file_name
				pbrun chown $file_own $server_path$file_name
				pbrun chmod 554 $server_path$file_name
				done 3< "../folder_content.txt"
			elif [ "$file_type" = "" ];
			then
				echo "There is no entry of $line/ path in ${p:environment/target_location_property} file, Please check the file uploaded to codestation or cross check the property file."
				exit 1
			else
				echo "There is no group with name $file_type please provide a valid group "
				exit 2
			
fi			
			
	done 3< "../zipcontent3_$zipname.txt"
	cd ../
done 3< "/tmp/zipfilenames_$(basename `pwd`).txt"
